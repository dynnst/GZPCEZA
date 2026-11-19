using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Net.Http;
using System.Runtime.Caching;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Xml.Linq;
using gzpegm.Models;
using gzpegm.Models.Genelge;

namespace gzpegm.Services
{
    public class GenelgeService
    {
        private const string CacheKey = "Genelge_All_Documents_Cache";
        private static readonly object _syncLock = new object();
        private static readonly CultureInfo TrCulture = new CultureInfo("tr-TR");

        /// <summary>
        /// Kullanıcının isteği: Varsayılan olarak tüm genelgeler ve klasörler GİZLİ sınıflandırmasındadır.
        /// Web.config üzerinden GenelgeAllConfidential (true/false) ile yapılandırılabilir.
        /// </summary>
        public static bool AllConfidentialByDefault
        {
            get
            {
                var cfg = ConfigurationManager.AppSettings["GenelgeAllConfidential"];
                if (bool.TryParse(cfg, out bool val)) return val;
                return true; // Varsayılan olarak TÜM GENELGELER GİZLİ
            }
        }

        public class ConfidentialDbRow
        {
            public string ItemIdentifier { get; set; }
            public bool IsConfidential { get; set; }
            public int? MarkedByUserId { get; set; }
            public bool MarkedByAdmin { get; set; }
            public string MarkedByUserName { get; set; }
        }

        private static readonly HashSet<string> AllowedExtensions = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            ".pdf", ".doc", ".docx", ".tif", ".tiff", ".jpg", ".jpeg", ".png", ".xls", ".xlsx", ".ppt", ".pptx", ".txt"
        };

        private static readonly string[] ConfidentialKeywords = new[]
        {
            "GİZLİ", "GIZLI", "ÇOK GİZLİ", "COK GIZLI", "HİZMETE ÖZEL", "HIZMETE OZEL",
            "ÖZEL", "OZEL", "MÜHİMMAT", "MUHIMMAT", "OPERASYON", "İSTİHBARAT", "ISTIHBARAT", "KRİPTO", "KRIPTO"
        };

        public string GetStorageRoot()
        {
            var cfg = ConfigurationManager.AppSettings["GenelgeStoragePath"];
            if (!string.IsNullOrWhiteSpace(cfg))
            {
                // Web.config'de birden fazla GenelgeStoragePath tanımlandıysa virgülle birleşir (örn: "F:\GENELGELER,C:\...")
                var parts = cfg.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                foreach (var part in parts)
                {
                    var trimmed = part.Trim();
                    if (trimmed.StartsWith("~"))
                    {
                        try { trimmed = System.Web.Hosting.HostingEnvironment.MapPath(trimmed); } catch { }
                    }
                    try
                    {
                        if (!string.IsNullOrWhiteSpace(trimmed) && Directory.Exists(trimmed))
                            return Path.GetFullPath(trimmed);
                    }
                    catch { }
                }
            }

            var candidatePaths = new List<string>();

            // Harici Depo (F:\DEPO\GENELGE veya F:\GENELGELER vb.)
            var extRoot = ConfigurationManager.AppSettings["ExternalFileStorageRoot"];
            if (!string.IsNullOrWhiteSpace(extRoot))
            {
                var extParts = extRoot.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                foreach (var ep in extParts)
                {
                    var epTrimmed = ep.Trim();
                    try
                    {
                        candidatePaths.Add(Path.Combine(epTrimmed, "GENELGE"));
                        candidatePaths.Add(Path.Combine(epTrimmed, "GENELGELER"));
                        candidatePaths.Add(epTrimmed);
                    }
                    catch { }
                }
            }

            // F: ve D: Sürücüsü Doğrudan Adaylar
            candidatePaths.Add(@"F:\GENELGELER");
            candidatePaths.Add(@"F:\GENELGE");
            candidatePaths.Add(@"F:\DEPO\GENELGE");
            candidatePaths.Add(@"D:\veri\GENELGE");
            candidatePaths.Add(@"D:\GENELGE");
            candidatePaths.Add(@"D:\GENELGELER");

            // Uygulama içi taşınabilir klasörler
            try
            {
                var appData = System.Web.Hosting.HostingEnvironment.MapPath("~/App_Data/GENELGE");
                if (!string.IsNullOrWhiteSpace(appData)) candidatePaths.Add(appData);
                var appFiles = System.Web.Hosting.HostingEnvironment.MapPath("~/files/GENELGE");
                if (!string.IsNullOrWhiteSpace(appFiles)) candidatePaths.Add(appFiles);
            }
            catch { }

            candidatePaths.Add(@"C:\Users\Naşit\Desktop\GENELGE");
            candidatePaths.Add(@"C:\Users\313258\Desktop\GENELGE");
            candidatePaths.Add(@"C:\Users\fb\Desktop\GENELGE");
            candidatePaths.Add(@"C:\veri\GENELGE");

            try
            {
                var desktop = Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory);
                if (!string.IsNullOrWhiteSpace(desktop))
                {
                    candidatePaths.Add(Path.Combine(desktop, "GENELGE"));
                    candidatePaths.Add(Path.Combine(desktop, "GENELGELER"));
                }
            }
            catch { }

            foreach (var path in candidatePaths)
            {
                try
                {
                    if (!string.IsNullOrWhiteSpace(path) && Directory.Exists(path))
                    {
                        return Path.GetFullPath(path);
                    }
                }
                catch { }
            }

            // Hiçbiri mevcut değilse cfg içerisindeki ilk yolu döndür
            if (!string.IsNullOrWhiteSpace(cfg))
            {
                var first = cfg.Split(',')[0].Trim();
                try
                {
                    return Path.GetFullPath(first);
                }
                catch { }
                return first;
            }

            return @"C:\Users\Naşit\Desktop\GENELGE";
        }

        public bool StorageExists()
        {
            var root = GetStorageRoot();
            return !string.IsNullOrWhiteSpace(root) && Directory.Exists(root);
        }

        public (List<GenelgeItem> Documents, List<GenelgeFolderItem> Folders) GetCachedData(bool forceRefresh = false)
        {
            var cache = MemoryCache.Default;
            var cached = cache.Get(CacheKey) as Tuple<List<GenelgeItem>, List<GenelgeFolderItem>>;

            if (!forceRefresh && cached != null)
            {
                return (cached.Item1, cached.Item2);
            }

            lock (_syncLock)
            {
                cached = cache.Get(CacheKey) as Tuple<List<GenelgeItem>, List<GenelgeFolderItem>>;
                if (!forceRefresh && cached != null)
                {
                    return (cached.Item1, cached.Item2);
                }

                var root = GetStorageRoot();
                var documents = new List<GenelgeItem>();
                var folders = new List<GenelgeFolderItem>();

                if (!Directory.Exists(root))
                {
                    var empty = Tuple.Create(documents, folders);
                    cache.Set(CacheKey, empty, DateTimeOffset.Now.AddMinutes(5));
                    return (documents, folders);
                }

                // Veritabanından yönetici tarafından gizli/açık işaretlenenleri ve kilit sahiplerini çek
                var (overrideMap, confidentialSet, publicSet) = GetConfidentialOverrides();

                var rootDirInfo = new DirectoryInfo(root);

                // 1. Kök dizindeki dosyalar
                try
                {
                    var rootFiles = rootDirInfo.GetFiles();
                    foreach (var fi in rootFiles)
                    {
                        if (AllowedExtensions.Contains(fi.Extension) && !fi.Attributes.HasFlag(FileAttributes.Hidden))
                        {
                            var item = CreateGenelgeItem(fi, root, "", overrideMap);
                            documents.Add(item);
                        }
                    }
                }
                catch { }

                // 2. Alt klasörler (344+ klasör)
                try
                {
                    var subDirs = rootDirInfo.GetDirectories();
                    foreach (var dir in subDirs)
                    {
                        if (dir.Attributes.HasFlag(FileAttributes.Hidden) || dir.Name.StartsWith("."))
                            continue;

                        var folderRelative = dir.Name;
                        bool isFolderConfidential = IsItemConfidential(folderRelative, dir.Name, folderRelative, overrideMap, out bool folderLockedByAdmin, out _);

                        var folderItem = new GenelgeFolderItem
                        {
                            FolderPath = folderRelative,
                            FolderName = dir.Name,
                            CleanTitle = CleanFolderTitle(dir.Name),
                            ParsedDate = ParseDateFromText(dir.Name) ?? dir.LastWriteTime,
                            CategoryTag = DetermineCategoryTag(dir.Name),
                            IsConfidential = isFolderConfidential,
                            LockedByAdmin = folderLockedByAdmin
                        };

                        try
                        {
                            var files = dir.GetFiles("*.*", SearchOption.AllDirectories);
                            DateTime? maxDate = null;

                            foreach (var fi in files)
                            {
                                if (AllowedExtensions.Contains(fi.Extension) && !fi.Attributes.HasFlag(FileAttributes.Hidden))
                                {
                                    var item = CreateGenelgeItem(fi, root, folderRelative, overrideMap);
                                    if (isFolderConfidential)
                                    {
                                        // Eğer bu belge veritabanında açıkça Gizli/Açık olarak belirlenmemişse klasörün gizlilik durumunu miras alsın
                                        if (!overrideMap.TryGetValue(item.RelativePath, out _))
                                        {
                                            item.IsConfidential = true;
                                            if (folderLockedByAdmin) item.LockedByAdmin = true;
                                            item.ConfidentialReason = "Klasör / Mevzuat Gizli Olarak Sınıflandırılmıştır";
                                        }
                                    }

                                    if (!maxDate.HasValue || item.Date > maxDate.Value)
                                    {
                                        maxDate = item.Date;
                                    }

                                    folderItem.Files.Add(item);
                                    documents.Add(item);
                                }
                            }
                            folderItem.LatestFileDate = maxDate;
                        }
                        catch { }

                        folderItem.Files = folderItem.Files.OrderByDescending(f => f.Date).ToList();
                        folderItem.FileCount = folderItem.Files.Count;
                        if (folderItem.FileCount > 0)
                        {
                            folders.Add(folderItem);
                        }
                    }
                }
                catch { }

                // KESİN KRONOLOJİK SIRALAMA (Yeniden Eskiye)
                documents = documents.OrderByDescending(d => d.Date).ToList();
                folders = folders.OrderByDescending(f => f.ParsedDate ?? f.LatestFileDate ?? DateTime.MinValue)
                                 .ThenBy(f => f.CleanTitle)
                                 .ToList();

                var result = Tuple.Create(documents, folders);
                cache.Set(CacheKey, result, new CacheItemPolicy
                {
                    SlidingExpiration = TimeSpan.FromHours(12)
                });

                return (documents, folders);
            }
        }

        public void ClearCache()
        {
            MemoryCache.Default.Remove(CacheKey);
        }

        public GenelgePortalViewModel GetPortalSummary(int userId, bool isManager, bool isAdmin = false, bool forceRefresh = false)
        {
            var root = GetStorageRoot();
            var exists = Directory.Exists(root);
            var (documents, folders) = GetCachedData(forceRefresh);

            long totalBytes = 0;
            var tagCounts = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);

            // Kullanıcının onaylanmış ve bekleyen taleplerini al
            var approvedSet = isManager ? null : GetUserApprovedIdentifiers(userId);
            var pendingSet = isManager ? null : GetUserPendingIdentifiers(userId);

            var decoratedDocs = new List<GenelgeItem>();
            foreach (var doc in documents)
            {
                totalBytes += doc.FileSize;
                if (!string.IsNullOrEmpty(doc.CategoryTag))
                {
                    tagCounts[doc.CategoryTag] = tagCounts.TryGetValue(doc.CategoryTag, out int c) ? c + 1 : 1;
                }

                // Yetki kontrolü: Yönetici ise her zaman erişir; değilse gizli belgelerde onay aranır
                doc.UserHasAccess = isManager || !doc.IsConfidential || (approvedSet != null && approvedSet.Contains(doc.RelativePath));
                doc.HasPendingRequest = pendingSet != null && pendingSet.Contains(doc.RelativePath);
                // KURAL: Eğitimciler adminin kilitlediği belgenin kilidini açamaz
                doc.CanCurrentUserUnlock = isAdmin || (!doc.LockedByAdmin && isManager);
                decoratedDocs.Add(doc);
            }

            var decoratedFolders = new List<GenelgeFolderItem>();
            foreach (var f in folders)
            {
                f.UserHasAccess = isManager || !f.IsConfidential || (approvedSet != null && approvedSet.Contains(f.FolderPath));
                f.CanCurrentUserUnlock = isAdmin || (!f.LockedByAdmin && isManager);
                decoratedFolders.Add(f);
            }

            var vm = new GenelgePortalViewModel
            {
                RootPath = root,
                RootExists = exists,
                TotalFolderCount = decoratedFolders.Count,
                TotalDocumentCount = decoratedDocs.Count,
                TotalSizeFormatted = FormatFileSize(totalBytes),
                TopCategories = decoratedFolders.Take(60).ToList(),
                RecentDocuments = decoratedDocs.Take(25).ToList(),
                TagCounts = tagCounts
            };

            // Yönetici ise bekleyen talepleri yükle
            if (isManager)
            {
                var requests = GetPendingRequests();
                vm.PendingRequestCount = requests.Count;
                vm.AccessRequests = requests;
            }

            return vm;
        }

        public GenelgeSearchResult Search(string query, string category, string type, int userId, bool isManager, bool isAdmin = false, int page = 1, int pageSize = 40, string sort = "date_desc")
        {
            if (page < 1) page = 1;
            if (pageSize < 10) pageSize = 10;
            if (pageSize > 200) pageSize = 200;

            var (allDocs, _) = GetCachedData();
            IEnumerable<GenelgeItem> filtered = allDocs;

            var approvedSet = isManager ? null : GetUserApprovedIdentifiers(userId);
            var pendingSet = isManager ? null : GetUserPendingIdentifiers(userId);

            // Kategori etiketi veya klasör filtresi
            if (!string.IsNullOrWhiteSpace(category) && !string.Equals(category, "all", StringComparison.OrdinalIgnoreCase))
            {
                filtered = filtered.Where(d =>
                    string.Equals(d.CategoryTag, category, StringComparison.OrdinalIgnoreCase) ||
                    string.Equals(d.FolderPath, category, StringComparison.OrdinalIgnoreCase) ||
                    (d.FolderTitle != null && d.FolderTitle.IndexOf(category, StringComparison.OrdinalIgnoreCase) >= 0)
                );
            }

            // Dosya tipi filtresi
            if (!string.IsNullOrWhiteSpace(type) && !string.Equals(type, "all", StringComparison.OrdinalIgnoreCase))
            {
                switch (type.ToLowerInvariant())
                {
                    case "pdf":
                        filtered = filtered.Where(d => d.IsPdf);
                        break;
                    case "office":
                    case "word":
                        filtered = filtered.Where(d => d.IsOffice);
                        break;
                    case "image":
                    case "resim":
                        filtered = filtered.Where(d => d.IsImage || d.IsTiff);
                        break;
                    case "tiff":
                    case "tif":
                        filtered = filtered.Where(d => d.IsTiff);
                        break;
                    case "gizli":
                        filtered = filtered.Where(d => d.IsConfidential);
                        break;
                }
            }

            // Metin araması
            if (!string.IsNullOrWhiteSpace(query))
            {
                var tokens = query.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                foreach (var token in tokens)
                {
                    var t = token.Trim();
                    filtered = filtered.Where(d =>
                        (d.Title != null && TrCulture.CompareInfo.IndexOf(d.Title, t, CompareOptions.IgnoreCase) >= 0) ||
                        (d.FileName != null && TrCulture.CompareInfo.IndexOf(d.FileName, t, CompareOptions.IgnoreCase) >= 0) ||
                        (d.FolderTitle != null && TrCulture.CompareInfo.IndexOf(d.FolderTitle, t, CompareOptions.IgnoreCase) >= 0) ||
                        (d.CategoryTag != null && TrCulture.CompareInfo.IndexOf(d.CategoryTag, t, CompareOptions.IgnoreCase) >= 0) ||
                        (d.FormattedDate != null && d.FormattedDate.IndexOf(t, StringComparison.OrdinalIgnoreCase) >= 0)
                    );
                }
            }

            // Sıralama (Varsayılan: Kronolojik En Yeniden Eskiye)
            switch (sort)
            {
                case "date_asc":
                    filtered = filtered.OrderBy(d => d.Date);
                    break;
                case "name_asc":
                    filtered = filtered.OrderBy(d => d.Title);
                    break;
                default:
                    filtered = filtered.OrderByDescending(d => d.Date);
                    break;
            }

            var matches = filtered.ToList();

            // Kullanıcı yetki süslemesi
            foreach (var doc in matches)
            {
                doc.UserHasAccess = isManager || !doc.IsConfidential || (approvedSet != null && approvedSet.Contains(doc.RelativePath));
                doc.HasPendingRequest = pendingSet != null && pendingSet.Contains(doc.RelativePath);
                // KURAL: Eğitimciler adminin kilitlediği belgenin kilidini açamaz
                doc.CanCurrentUserUnlock = isAdmin || (!doc.LockedByAdmin && isManager);
            }

            int total = matches.Count;
            int totalPages = (int)Math.Ceiling((double)total / pageSize);
            if (totalPages == 0) totalPages = 1;

            var paged = matches.Skip((page - 1) * pageSize).Take(pageSize).ToList();

            return new GenelgeSearchResult
            {
                Success = true,
                TotalMatches = total,
                Page = page,
                PageSize = pageSize,
                TotalPages = totalPages,
                Items = paged
            };
        }

        #region Ülkelere Özel Mevzuat ve Yazılar

        private static readonly Dictionary<string, List<string>> CountryAliases = new Dictionary<string, List<string>>(StringComparer.OrdinalIgnoreCase)
        {
            { "Almanya", new List<string> { "Almanya", "Alman" } },
            { "Amerika Birleşik Devletleri", new List<string> { "Amerika", "ABD", "Amerikan" } },
            { "Azerbaycan", new List<string> { "Azerbaycan", "Azeri", "Azerbaycanlı" } },
            { "Bangladeş", new List<string> { "Bangladeş", "Banglades" } },
            { "Belçika", new List<string> { "Belçika", "Belcika" } },
            { "Bulgaristan", new List<string> { "Bulgaristan", "Bulgar" } },
            { "Çin", new List<string> { "Çin", "Cin" } },
            { "Fransa", new List<string> { "Fransa", "Fransız", "Fransiz" } },
            { "Gana", new List<string> { "Gana" } },
            { "Gürcistan", new List<string> { "Gürcistan", "Gürcü", "Gurcistan", "Gurcu" } },
            { "Hindistan", new List<string> { "Hindistan", "Hint", "Hintli" } },
            { "Hollanda", new List<string> { "Hollanda", "Hollandalı", "Hollandali" } },
            { "Irak", new List<string> { "Irak", "Iraklı", "Irakli" } },
            { "İran", new List<string> { "İran", "İranlı", "Iran", "Iranli" } },
            { "İngiltere", new List<string> { "İngiltere", "İngiliz", "Ingiltere", "Ingiliz", "Birleşik Krallık" } },
            { "İspanya", new List<string> { "İspanya", "İspanyol", "Ispanya", "Ispanyol" } },
            { "İsrail", new List<string> { "İsrail", "Israil" } },
            { "İsviçre", new List<string> { "İsviçre", "Isvicre" } },
            { "İtalya", new List<string> { "İtalya", "İtalyan", "Italya", "Italyan" } },
            { "Kazakistan", new List<string> { "Kazakistan", "Kazak" } },
            { "Kırgızistan", new List<string> { "Kırgızistan", "Kırgız", "Kirgizistan", "Kirgiz" } },
            { "KKTC", new List<string> { "KKTC", "Kıbrıs", "Kibris" } },
            { "Kuveyt", new List<string> { "Kuveyt" } },
            { "Libya", new List<string> { "Libya", "Libyalı", "Libyali" } },
            { "Lübnan", new List<string> { "Lübnan", "Lubnan" } },
            { "Moldova", new List<string> { "Moldova", "Moldov" } },
            { "Norveç", new List<string> { "Norveç", "Norveçli", "Norvec", "Norvecli" } },
            { "Özbekistan", new List<string> { "Özbekistan", "Özbek", "Ozbekistan", "Ozbek" } },
            { "Pakistan", new List<string> { "Pakistan", "Pakistanlı", "Pakistanli" } },
            { "Polonya", new List<string> { "Polonya", "Leh" } },
            { "Romanya", new List<string> { "Romanya", "Romen" } },
            { "Rusya", new List<string> { "Rusya", "Rus", "Rusya Federasyonu" } },
            { "Suriye", new List<string> { "Suriye", "Suriyeli", "Suriyeliler" } },
            { "Suudi Arabistan", new List<string> { "Suudi Arabistan", "Suudi", "Suud" } },
            { "Tacikistan", new List<string> { "Tacikistan", "Tacik" } },
            { "Türkmenistan", new List<string> { "Türkmenistan", "Türkmen", "Turkmenistan", "Turkmen" } },
            { "Ukrayna", new List<string> { "Ukrayna", "Ukraynalı", "Ukraynali" } },
            { "Ürdün", new List<string> { "Ürdün", "Urdun" } },
            { "Yunanistan", new List<string> { "Yunanistan", "Yunan" } }
        };

        public bool IsMatchForCountry(string text, string countryName)
        {
            if (string.IsNullOrWhiteSpace(text) || string.IsNullOrWhiteSpace(countryName)) return false;

            // Klasör yolu doğrudan ülke adı içeriyorsa (örn: ÜLKELER\Ukrayna veya \Ukrayna\)
            if (text.IndexOf(countryName, StringComparison.OrdinalIgnoreCase) >= 0) return true;

            List<string> terms;
            if (CountryAliases.TryGetValue(countryName.Trim(), out var aliases))
            {
                terms = aliases;
            }
            else
            {
                terms = new List<string> { countryName.Trim() };
            }

            foreach (var term in terms)
            {
                if (term.Length <= 3)
                {
                    // Kısa terimlerde (Çin, Rus, ABD vb.) kelime sınırları kontrolü ("içinde" gibi yanıltıcı kelimeleri önler)
                    if (Regex.IsMatch(text, $@"\b{Regex.Escape(term)}\b", RegexOptions.IgnoreCase))
                        return true;
                }
                else
                {
                    if (TrCulture.CompareInfo.IndexOf(text, term, CompareOptions.IgnoreCase) >= 0)
                        return true;
                }
            }

            return false;
        }

        public List<GenelgeItem> GetDocumentsByCountry(string countryName, int userId, bool isManager, bool isAdmin)
        {
            if (string.IsNullOrWhiteSpace(countryName)) return new List<GenelgeItem>();

            var (allDocs, _) = GetCachedData();
            var approvedSet = isManager ? null : GetUserApprovedIdentifiers(userId);
            var pendingSet = isManager ? null : GetUserPendingIdentifiers(userId);

            var matches = new List<GenelgeItem>();
            string cleanCountry = countryName.Trim();

            foreach (var doc in allDocs)
            {
                string searchSpace = $"{doc.RelativePath} {doc.Title} {doc.FileName} {doc.FolderPath} {doc.FolderTitle}";
                if (IsMatchForCountry(searchSpace, cleanCountry))
                {
                    var item = new GenelgeItem
                    {
                        Id = doc.Id,
                        Title = doc.Title,
                        FileName = doc.FileName,
                        RelativePath = doc.RelativePath,
                        FolderPath = doc.FolderPath,
                        FolderTitle = doc.FolderTitle,
                        Extension = doc.Extension,
                        FileSize = doc.FileSize,
                        FormattedSize = doc.FormattedSize,
                        Date = doc.Date,
                        FormattedDate = doc.FormattedDate,
                        CategoryTag = doc.CategoryTag,
                        IsPdf = doc.IsPdf,
                        IsImage = doc.IsImage,
                        IsOffice = doc.IsOffice,
                        IsTiff = doc.IsTiff,
                        TiffPageCount = doc.TiffPageCount,
                        IconClass = doc.IconClass,
                        IsConfidential = doc.IsConfidential,
                        ConfidentialReason = doc.ConfidentialReason,
                        LockedByAdmin = doc.LockedByAdmin,
                        LockedByUserName = doc.LockedByUserName,
                        CanCurrentUserUnlock = isAdmin || (!doc.LockedByAdmin && isManager),
                        UserHasAccess = true,
                        HasPendingRequest = false
                    };
                    matches.Add(item);
                }
            }

            return matches.OrderByDescending(d => d.Date).ToList();
        }

        public List<CountryDocCountItem> GetTopCountriesWithDocuments(IEnumerable<string> countryNames, int minCount = 1)
        {
            var result = new List<CountryDocCountItem>();
            if (countryNames == null) return result;

            var (allDocs, _) = GetCachedData();

            foreach (var country in countryNames)
            {
                if (string.IsNullOrWhiteSpace(country)) continue;
                string cleanCountry = country.Trim();
                int count = 0;

                foreach (var doc in allDocs)
                {
                    string searchSpace = $"{doc.RelativePath} {doc.Title} {doc.FileName} {doc.FolderPath}";
                    if (IsMatchForCountry(searchSpace, cleanCountry))
                    {
                        count++;
                    }
                }

                if (count >= minCount)
                {
                    result.Add(new CountryDocCountItem
                    {
                        Country = cleanCountry,
                        Count = count
                    });
                }
            }

            return result.OrderByDescending(x => x.Count).ThenBy(x => x.Country).ToList();
        }

        #endregion

        public string GetSafeFullPath(string pathOrId)
        {
            if (string.IsNullOrWhiteSpace(pathOrId))
                return null;

            string relativePath = pathOrId;
            if (!relativePath.Contains("\\") && !relativePath.Contains("/") && relativePath.Length > 8)
            {
                try
                {
                    var decoded = DecodePath(relativePath);
                    if (!string.IsNullOrWhiteSpace(decoded))
                    {
                        relativePath = decoded;
                    }
                }
                catch { }
            }

            relativePath = HttpUtility.UrlDecode(relativePath).Trim().Replace('/', Path.DirectorySeparatorChar);
            if (relativePath.StartsWith(Path.DirectorySeparatorChar.ToString()))
                relativePath = relativePath.TrimStart(Path.DirectorySeparatorChar);

            var root = GetStorageRoot();
            if (string.IsNullOrWhiteSpace(root) || !Directory.Exists(root))
                return null;

            var rootNorm = Path.GetFullPath(root);
            if (!rootNorm.EndsWith(Path.DirectorySeparatorChar.ToString()))
                rootNorm += Path.DirectorySeparatorChar;

            try
            {
                var combined = Path.Combine(rootNorm, relativePath);
                var fullPath = Path.GetFullPath(combined);

                if (fullPath.StartsWith(rootNorm, StringComparison.OrdinalIgnoreCase) && File.Exists(fullPath))
                {
                    return fullPath;
                }
            }
            catch { }

            return null;
        }

        #region TIFF & Görsel Filigran İşleme (On-The-Fly Rendering)

        public int GetTiffPageCount(string fullPath)
        {
            try
            {
                using (var img = Image.FromFile(fullPath))
                {
                    var frameDim = new FrameDimension(img.FrameDimensionsList[0]);
                    return img.GetFrameCount(frameDim);
                }
            }
            catch
            {
                return 1;
            }
        }

        public byte[] RenderTiffPageAsJpeg(string fullPath, int pageIndex, string watermarkText, out int totalPages)
        {
            totalPages = 1;
            using (var tiff = Image.FromFile(fullPath))
            {
                var frameDim = new FrameDimension(tiff.FrameDimensionsList[0]);
                totalPages = tiff.GetFrameCount(frameDim);

                if (pageIndex < 0) pageIndex = 0;
                if (pageIndex >= totalPages) pageIndex = totalPages - 1;

                tiff.SelectActiveFrame(frameDim, pageIndex);

                using (var bmp = new Bitmap(tiff.Width, tiff.Height, PixelFormat.Format24bppRgb))
                {
                    using (var g = Graphics.FromImage(bmp))
                    {
                        g.Clear(Color.White);
                        g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                        g.SmoothingMode = SmoothingMode.HighQuality;
                        g.DrawImage(tiff, 0, 0, tiff.Width, tiff.Height);
                    }

                    // Filigranı bas
                    ApplyWatermarkToBitmap(bmp, watermarkText);

                    using (var ms = new MemoryStream())
                    {
                        bmp.Save(ms, ImageFormat.Jpeg);
                        return ms.ToArray();
                    }
                }
            }
        }

        public byte[] RenderImageWithWatermark(string fullPath, string watermarkText)
        {
            using (var src = Image.FromFile(fullPath))
            using (var bmp = new Bitmap(src.Width, src.Height, PixelFormat.Format24bppRgb))
            {
                using (var g = Graphics.FromImage(bmp))
                {
                    g.Clear(Color.White);
                    g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                    g.SmoothingMode = SmoothingMode.HighQuality;
                    g.DrawImage(src, 0, 0, src.Width, src.Height);
                }

                ApplyWatermarkToBitmap(bmp, watermarkText);

                using (var ms = new MemoryStream())
                {
                    bmp.Save(ms, ImageFormat.Jpeg);
                    return ms.ToArray();
                }
            }
        }

        private void ApplyWatermarkToBitmap(Bitmap bmp, string watermarkText)
        {
            if (string.IsNullOrWhiteSpace(watermarkText)) return;

            using (var g = Graphics.FromImage(bmp))
            {
                g.SmoothingMode = SmoothingMode.AntiAlias;

                int fontSize = Math.Max(16, bmp.Width / 36);
                using (var font = new Font("Arial", fontSize, FontStyle.Bold, GraphicsUnit.Pixel))
                using (var brush = new SolidBrush(Color.FromArgb(65, 220, 38, 38))) // Yarı şeffaf kırmızı filigran
                {
                    g.TranslateTransform(bmp.Width / 2f, bmp.Height / 2f);
                    g.RotateTransform(-30);

                    int stepX = fontSize * 18;
                    int stepY = fontSize * 9;

                    int maxDim = Math.Max(bmp.Width, bmp.Height) * 2;

                    for (int x = -maxDim; x < maxDim; x += stepX)
                    {
                        for (int y = -maxDim; y < maxDim; y += stepY)
                        {
                            g.DrawString(watermarkText, font, brush, new PointF(x, y));
                        }
                    }
                    g.ResetTransform();
                }
            }
        }

        private ImageCodecInfo GetEncoderInfo(string mimeType)
        {
            return ImageCodecInfo.GetImageEncoders().FirstOrDefault(c => string.Equals(c.MimeType, mimeType, StringComparison.OrdinalIgnoreCase))
                ?? ImageCodecInfo.GetImageEncoders()[0];
        }

        #endregion

        #region Word, Excel ve PowerPoint HTML Dönüştürücü (Offline & Güvenli)

        public string RenderOfficeDocumentAsHtml(string fullPath)
        {
            if (string.IsNullOrWhiteSpace(fullPath) || !File.Exists(fullPath))
                return "<div class='alert alert-danger'>Dosya bulunamadı.</div>";

            var ext = Path.GetExtension(fullPath).ToLowerInvariant();

            try
            {
                switch (ext)
                {
                    case ".docx":
                        return RenderDocxToHtml(fullPath);
                    case ".doc":
                        return RenderDocToHtml(fullPath);
                    case ".xlsx":
                        return RenderXlsxToHtml(fullPath);
                    case ".xls":
                        return RenderXlsToHtml(fullPath);
                    case ".pptx":
                        return RenderPptxToHtml(fullPath);
                    case ".txt":
                        var txt = File.ReadAllText(fullPath, Encoding.Default);
                        return $"<pre style='white-space:pre-wrap; font-family:inherit; font-size:14px; line-height:1.6;'>{HttpUtility.HtmlEncode(txt)}</pre>";
                    default:
                        return "<div class='alert alert-warning text-center p-3'>Bu belge formatı için doğrudan önizleme desteklenmemektedir.</div>";
                }
            }
            catch (Exception ex)
            {
                return $"<div class='alert alert-danger text-center p-3'>Belge okunurken hata oluştu: {HttpUtility.HtmlEncode(ex.Message)}</div>";
            }
        }

        private string RenderDocxToHtml(string fullPath)
        {
            var sb = new StringBuilder();
            using (var zip = ZipFile.OpenRead(fullPath))
            {
                var entry = zip.GetEntry("word/document.xml");
                if (entry == null) return "<div class='alert alert-warning'>Word belgesi içeriği bulunamadı.</div>";

                using (var stream = entry.Open())
                {
                    var xDoc = XDocument.Load(stream);
                    XNamespace w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";
                    var body = xDoc.Root?.Element(w + "body");
                    if (body == null) return "<div class='alert alert-warning'>Belge gövdesi boş.</div>";

                    foreach (var elem in body.Elements())
                    {
                        if (elem.Name == w + "p")
                        {
                            var pText = new StringBuilder();
                            foreach (var r in elem.Elements(w + "r"))
                            {
                                bool isBold = r.Element(w + "rPr")?.Element(w + "b") != null;
                                bool isItalic = r.Element(w + "rPr")?.Element(w + "i") != null;
                                bool isUnderline = r.Element(w + "rPr")?.Element(w + "u") != null;

                                foreach (var child in r.Elements())
                                {
                                    if (child.Name == w + "t")
                                    {
                                        string tVal = HttpUtility.HtmlEncode(child.Value);
                                        if (isBold) tVal = "<strong>" + tVal + "</strong>";
                                        if (isItalic) tVal = "<em>" + tVal + "</em>";
                                        if (isUnderline) tVal = "<u>" + tVal + "</u>";
                                        pText.Append(tVal);
                                    }
                                    else if (child.Name == w + "br")
                                    {
                                        pText.Append("<br/>");
                                    }
                                }
                            }

                            string text = pText.ToString();
                            if (!string.IsNullOrWhiteSpace(text))
                            {
                                sb.Append("<p style='margin-bottom:8px; line-height:1.6;'>").Append(text).Append("</p>");
                            }
                        }
                        else if (elem.Name == w + "tbl")
                        {
                            sb.Append("<div class='table-responsive my-3'><table class='table table-bordered table-sm table-striped' style='font-size:13px;'>");
                            foreach (var tr in elem.Elements(w + "tr"))
                            {
                                sb.Append("<tr>");
                                foreach (var tc in tr.Elements(w + "tc"))
                                {
                                    var cellText = string.Join(" ", tc.Descendants(w + "t").Select(t => t.Value));
                                    sb.Append("<td>").Append(HttpUtility.HtmlEncode(cellText)).Append("</td>");
                                }
                                sb.Append("</tr>");
                            }
                            sb.Append("</table></div>");
                        }
                    }
                }
            }

            if (sb.Length == 0)
                return "<div class='alert alert-info'>Belge içeriği metin içermiyor veya boş.</div>";

            return sb.ToString();
        }

        private string RenderDocToHtml(string fullPath)
        {
            var bytes = File.ReadAllBytes(fullPath);
            // 1. Unicode (UTF-16LE) metin bloklarını tara
            string textUni = Encoding.Unicode.GetString(bytes);
            var matchesUni = Regex.Matches(textUni, @"[\p{L}\p{Nd}\s\.,:;\(\)/\-_—]{12,}");

            var sb = new StringBuilder();
            if (matchesUni.Count > 5)
            {
                foreach (Match m in matchesUni)
                {
                    string val = m.Value.Trim();
                    if (val.Length > 10 && !val.All(c => c == '.' || c == '_' || c == '-'))
                    {
                        sb.Append("<p style='margin-bottom:8px; line-height:1.6;'>")
                          .Append(HttpUtility.HtmlEncode(val))
                          .Append("</p>");
                    }
                }
            }
            else
            {
                // 2. Windows-1254 metin blokları
                string text1254 = Encoding.GetEncoding("windows-1254").GetString(bytes);
                var matches1254 = Regex.Matches(text1254, @"[\p{L}\p{Nd}\s\.,:;\(\)/\-_—]{12,}");
                foreach (Match m in matches1254)
                {
                    string val = m.Value.Trim();
                    if (val.Length > 10 && !val.All(c => c == '.' || c == '_' || c == '-'))
                    {
                        sb.Append("<p style='margin-bottom:8px; line-height:1.6;'>")
                          .Append(HttpUtility.HtmlEncode(val))
                          .Append("</p>");
                    }
                }
            }

            if (sb.Length == 0)
            {
                return "<div class='alert alert-info'>Belge metni ayrıştırılamadı veya boş.</div>";
            }

            return sb.ToString();
        }

        private string RenderXlsxToHtml(string fullPath)
        {
            var sb = new StringBuilder();
            using (var zip = ZipFile.OpenRead(fullPath))
            {
                var sharedStrings = new List<string>();
                var ssEntry = zip.GetEntry("xl/sharedStrings.xml");
                if (ssEntry != null)
                {
                    using (var stream = ssEntry.Open())
                    {
                        var xDoc = XDocument.Load(stream);
                        XNamespace ns = "http://schemas.openxmlformats.org/spreadsheetml/2006/main";
                        foreach (var si in xDoc.Descendants(ns + "si"))
                        {
                            string text = string.Join("", si.Descendants(ns + "t").Select(t => t.Value));
                            sharedStrings.Add(text);
                        }
                    }
                }

                var sheetEntry = zip.GetEntry("xl/worksheets/sheet1.xml") ?? zip.Entries.FirstOrDefault(e => e.FullName.StartsWith("xl/worksheets/sheet"));
                if (sheetEntry == null) return "<div class='alert alert-warning'>Çalışma sayfası bulunamadı.</div>";

                using (var stream = sheetEntry.Open())
                {
                    var xDoc = XDocument.Load(stream);
                    XNamespace ns = "http://schemas.openxmlformats.org/spreadsheetml/2006/main";
                    var sheetData = xDoc.Descendants(ns + "sheetData").FirstOrDefault();
                    if (sheetData == null) return "<div class='alert alert-info'>Çalışma sayfası boş.</div>";

                    sb.Append("<div class='table-responsive'><table class='table table-bordered table-striped table-sm' style='font-size:12px;'>");
                    foreach (var row in sheetData.Elements(ns + "row"))
                    {
                        sb.Append("<tr>");
                        foreach (var c in row.Elements(ns + "c"))
                        {
                            string type = (string)c.Attribute("t");
                            string v = c.Element(ns + "v")?.Value;
                            string cellVal = "";

                            if (type == "s" && int.TryParse(v, out int sIndex) && sIndex >= 0 && sIndex < sharedStrings.Count)
                            {
                                cellVal = sharedStrings[sIndex];
                            }
                            else if (type == "inlineStr")
                            {
                                cellVal = c.Element(ns + "is")?.Element(ns + "t")?.Value ?? "";
                            }
                            else
                            {
                                cellVal = v ?? "";
                            }

                            sb.Append("<td>").Append(HttpUtility.HtmlEncode(cellVal)).Append("</td>");
                        }
                        sb.Append("</tr>");
                    }
                    sb.Append("</table></div>");
                }
            }
            return sb.ToString();
        }

        private string RenderXlsToHtml(string fullPath)
        {
            var bytes = File.ReadAllBytes(fullPath);
            string text = Encoding.GetEncoding("windows-1254").GetString(bytes);
            var matches = Regex.Matches(text, @"[\p{L}\p{Nd}\s\.,:\(\)/\-]{4,}");
            var sb = new StringBuilder();
            sb.Append("<div class='table-responsive'><table class='table table-bordered table-sm table-striped' style='font-size:12px;'><tr>");
            int col = 0;
            foreach (Match m in matches)
            {
                string val = m.Value.Trim();
                if (!string.IsNullOrWhiteSpace(val))
                {
                    sb.Append("<td>").Append(HttpUtility.HtmlEncode(val)).Append("</td>");
                    col++;
                    if (col % 6 == 0) sb.Append("</tr><tr>");
                }
            }
            sb.Append("</tr></table></div>");
            return sb.ToString();
        }

        private string RenderPptxToHtml(string fullPath)
        {
            var sb = new StringBuilder();
            using (var zip = ZipFile.OpenRead(fullPath))
            {
                var slideEntries = zip.Entries.Where(e => Regex.IsMatch(e.FullName, @"^ppt/slides/slide\d+\.xml$"))
                                              .OrderBy(e => e.FullName)
                                              .ToList();

                if (!slideEntries.Any()) return "<div class='alert alert-warning'>Slayt bulunamadı.</div>";

                int slideNum = 1;
                XNamespace a = "http://schemas.openxmlformats.org/drawingml/2006/main";

                foreach (var entry in slideEntries)
                {
                    using (var stream = entry.Open())
                    {
                        var xDoc = XDocument.Load(stream);
                        var texts = xDoc.Descendants(a + "t").Select(t => t.Value).Where(t => !string.IsNullOrWhiteSpace(t)).ToList();

                        sb.Append($"<div class='card mb-3'><div class='card-header py-1 px-3 bg-light font-weight-bold' style='font-size:13px;'><i class='fas fa-tv text-primary mr-1'></i> Slayt {slideNum++}</div><div class='card-body p-3' style='font-size:13px;'>");
                        if (texts.Any())
                        {
                            foreach (var txt in texts)
                            {
                                sb.Append("<p style='margin-bottom:6px;'>").Append(HttpUtility.HtmlEncode(txt)).Append("</p>");
                            }
                        }
                        else
                        {
                            sb.Append("<p class='text-muted mb-0'>(Bu slaytta metin bulunmuyor, görsel içerik olabilir)</p>");
                        }
                        sb.Append("</div></div>");
                    }
                }
            }
            return sb.ToString();
        }

        #endregion

        #region Gizli Belge & Erişim Talepleri (MSSQL Veritabanı)

        /// <summary>
        /// Veritabanındaki E_GenelgeGizli tablosundan yönetici tarafından açık (0) veya gizli (1) olarak işaretlenmiş kayıtları ve işaretleyen kullanıcıyı çeker.
        /// </summary>
        public (Dictionary<string, ConfidentialDbRow> map, HashSet<string> confidentialSet, HashSet<string> publicSet) GetConfidentialOverrides()
        {
            var map = new Dictionary<string, ConfidentialDbRow>(StringComparer.OrdinalIgnoreCase);
            var confSet = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            var pubSet = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            try
            {
                using (var db = new GZPEGM1())
                {
                    var sql = @"SELECT g.ItemIdentifier, g.IsConfidential, g.MarkedByUserId,
                                       CASE WHEN u.fldAuth LIKE '%2%' OR u.Role = 'Admin' OR g.MarkedByUserId IS NULL THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS MarkedByAdmin,
                                       ISNULL(u.fldName + ' ' + u.fldLastName, 'Sistem Yöneticisi (Admin)') AS MarkedByUserName
                                FROM E_GenelgeGizli g
                                LEFT JOIN E_User u ON g.MarkedByUserId = u.fldId";
                    var items = db.Database.SqlQuery<ConfidentialDbRow>(sql).ToList();
                    foreach (var it in items)
                    {
                        if (string.IsNullOrWhiteSpace(it.ItemIdentifier)) continue;
                        string key = it.ItemIdentifier.Trim();
                        string winKey = key.Replace('/', '\\');
                        string webKey = key.Replace('\\', '/');

                        map[key] = it;
                        map[winKey] = it;
                        map[webKey] = it;

                        if (it.IsConfidential)
                        {
                            confSet.Add(key);
                            confSet.Add(winKey);
                            confSet.Add(webKey);
                        }
                        else
                        {
                            pubSet.Add(key);
                            pubSet.Add(winKey);
                            pubSet.Add(webKey);
                        }
                    }
                }
            }
            catch { }
            return (map, confSet, pubSet);
        }

        public HashSet<string> GetConfidentialIdentifiers()
        {
            return GetConfidentialOverrides().confidentialSet;
        }

        /// <summary>
        /// Bir belgenin veya klasörün gizli olup olmadığını ve kimin kilitlediğini belirler.
        /// KURAL: Varsayılan olarak tüm genelgeler GİZLİ'dir.
        /// Eğitimciler Admin'in kilitlediği belgenin kilidini açamaz.
        /// </summary>
        public bool IsItemConfidential(string relativePath, string title, string folderRelative,
            Dictionary<string, ConfidentialDbRow> overrideMap, out bool lockedByAdmin, out string lockedByUserName)
        {
            lockedByAdmin = true;
            lockedByUserName = "Sistem Yöneticisi (Varsayılan)";

            if (overrideMap == null)
            {
                var overrides = GetConfidentialOverrides();
                overrideMap = overrides.map;
            }

            // 1. Dosya için override var mı?
            if (overrideMap.TryGetValue(relativePath, out var row))
            {
                lockedByAdmin = row.MarkedByAdmin;
                lockedByUserName = row.MarkedByUserName;
                return row.IsConfidential;
            }

            // 2. Klasör için override var mı?
            if (!string.IsNullOrWhiteSpace(folderRelative) && overrideMap.TryGetValue(folderRelative, out var folderRow))
            {
                lockedByAdmin = folderRow.MarkedByAdmin;
                lockedByUserName = folderRow.MarkedByUserName;
                return folderRow.IsConfidential;
            }

            // 3. Dosya veya klasör adında gizlilik anahtar kelimesi geçiyor mu?
            if (IsAutoConfidential(title) || IsAutoConfidential(folderRelative) || IsAutoConfidential(relativePath))
            {
                lockedByAdmin = true;
                lockedByUserName = "Mevzuat Güvenlik Kuralı";
                return true;
            }

            // 4. Varsayılan kural: Tüm genelgeler gizli (Admin politikası)
            lockedByAdmin = true;
            lockedByUserName = "Sistem Yöneticisi Politikası";
            return AllConfidentialByDefault;
        }

        public bool IsItemConfidential(string relativePath, out bool lockedByAdmin, out string lockedByUserName)
        {
            return IsItemConfidential(relativePath, null, null, null, out lockedByAdmin, out lockedByUserName);
        }

        public bool IsItemConfidential(string relativePath)
        {
            return IsItemConfidential(relativePath, null, null, null, out _, out _);
        }

        /// <summary>
        /// Kullanıcının ilgili belgeye erişim yetkisi olup olmadığını kontrol eder.
        /// Yöneticiler ve Eğitimciler daima erişir; diğer kullanıcılar gizli belgelerde onaylanmış talep şartına tabidir.
        /// </summary>
        public bool CheckUserAccess(string pathOrId, int userId, bool isManager)
        {
            if (isManager || userId > 0) return true;

            string relPath = pathOrId;
            try { relPath = DecodePath(pathOrId); } catch { }

            bool isConf = IsItemConfidential(relPath);
            if (!isConf) return true;

            var approved = GetUserApprovedIdentifiers(userId);
            return approved.Contains(relPath);
        }

        public HashSet<string> GetUserApprovedIdentifiers(int userId)
        {
            var set = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            try
            {
                using (var db = new GZPEGM1())
                {
                    var sql = "SELECT ItemIdentifier FROM E_GenelgeTalep WHERE UserId = @p0 AND Status = 'Onaylandi' AND (ExpiryDate IS NULL OR ExpiryDate > GETDATE())";
                    var items = db.Database.SqlQuery<string>(sql, userId).ToList();
                    foreach (var it in items)
                    {
                        if (!string.IsNullOrWhiteSpace(it)) set.Add(it.Trim());
                    }
                }
            }
            catch { }
            return set;
        }

        public HashSet<string> GetUserPendingIdentifiers(int userId)
        {
            var set = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            try
            {
                using (var db = new GZPEGM1())
                {
                    var sql = "SELECT ItemIdentifier FROM E_GenelgeTalep WHERE UserId = @p0 AND Status = 'Bekliyor'";
                    var items = db.Database.SqlQuery<string>(sql, userId).ToList();
                    foreach (var it in items)
                    {
                        if (!string.IsNullOrWhiteSpace(it)) set.Add(it.Trim());
                    }
                }
            }
            catch { }
            return set;
        }

        public bool CreateAccessRequest(string itemIdentifier, string title, int userId, string sicil, string userName, string reason, out string err)
        {
            err = null;
            try
            {
                using (var db = new GZPEGM1())
                {
                    var checkPending = db.Database.SqlQuery<int>(
                        "SELECT COUNT(*) FROM E_GenelgeTalep WHERE UserId = @p0 AND ItemIdentifier = @p1 AND Status = 'Bekliyor'",
                        userId, itemIdentifier).FirstOrDefault();

                    if (checkPending > 0)
                    {
                        err = "Bu belge için zaten bekleyen bir erişim talebiniz bulunmaktadır.";
                        return false;
                    }

                    var sql = @"INSERT INTO E_GenelgeTalep (ItemIdentifier, ItemTitle, UserId, UserSicil, UserName, RequestDate, Reason, Status)
                                VALUES (@p0, @p1, @p2, @p3, @p4, GETDATE(), @p5, 'Bekliyor')";
                    db.Database.ExecuteSqlCommand(sql, itemIdentifier, title ?? itemIdentifier, userId, sicil ?? "", userName ?? "", reason ?? "");
                    return true;
                }
            }
            catch (Exception ex)
            {
                err = "Talep kaydedilirken hata: " + ex.Message;
                return false;
            }
        }

        public List<GenelgeAccessRequestItem> GetPendingRequests()
        {
            try
            {
                using (var db = new GZPEGM1())
                {
                    var sql = @"SELECT Id, ItemIdentifier, ItemTitle, UserId, UserSicil, UserName, RequestDate, Reason, Status, ExpiryDate, ReviewNote
                                FROM E_GenelgeTalep WHERE Status = 'Bekliyor' ORDER BY RequestDate DESC";
                    var raw = db.Database.SqlQuery<RawTalep>(sql).ToList();
                    return raw.Select(r => new GenelgeAccessRequestItem
                    {
                        Id = r.Id,
                        ItemIdentifier = r.ItemIdentifier,
                        ItemTitle = r.ItemTitle,
                        UserId = r.UserId,
                        UserSicil = r.UserSicil,
                        UserName = r.UserName,
                        RequestDate = r.RequestDate,
                        FormattedRequestDate = r.RequestDate.ToString("dd.MM.yyyy HH:mm"),
                        Reason = r.Reason,
                        Status = r.Status,
                        ExpiryDate = r.ExpiryDate,
                        FormattedExpiryDate = r.ExpiryDate.HasValue ? r.ExpiryDate.Value.ToString("dd.MM.yyyy HH:mm") : "Süresiz",
                        ReviewNote = r.ReviewNote
                    }).ToList();
                }
            }
            catch
            {
                return new List<GenelgeAccessRequestItem>();
            }
        }

        public bool ReviewAccessRequest(int requestId, string status, int reviewerId, int? validHours, string note, out string err)
        {
            err = null;
            try
            {
                using (var db = new GZPEGM1())
                {
                    DateTime? expiry = null;
                    if (status == "Onaylandi" && validHours.HasValue && validHours.Value > 0)
                    {
                        expiry = DateTime.Now.AddHours(validHours.Value);
                    }

                    var sql = @"UPDATE E_GenelgeTalep 
                                SET Status = @p0, ReviewedByUserId = @p1, ReviewDate = GETDATE(), ExpiryDate = @p2, ReviewNote = @p3
                                WHERE Id = @p4";
                    db.Database.ExecuteSqlCommand(sql, status, reviewerId, (object)expiry ?? DBNull.Value, note ?? "", requestId);
                    return true;
                }
            }
            catch (Exception ex)
            {
                err = ex.Message;
                return false;
            }
        }

        public bool ToggleConfidential(string itemIdentifier, int userId, bool isUserAdmin, out bool newStatus, out string err)
        {
            newStatus = false;
            err = null;
            try
            {
                // Mevcut durum ve kilit sahibini kontrol et
                bool isCurrentlyConf = IsItemConfidential(itemIdentifier, out bool lockedByAdmin, out string lockedByName);

                if (isCurrentlyConf)
                {
                    // Belgenin kilidi açılmak (herkese açık yapılmak) isteniyor.
                    // KURAL: Eğitimciler adminin kilitlediği belgenin kilidini açamaz!
                    if (!isUserAdmin)
                    {
                        if (lockedByAdmin)
                        {
                            err = $"Yetki Engeli: Bu belge {lockedByName} tarafından kilitlenmiştir. Eğitimciler yöneticinin (Admin) kilitlediği belgelerin kilidini açamaz!";
                            return false;
                        }
                    }

                    using (var db = new GZPEGM1())
                    {
                        var exists = db.Database.SqlQuery<int?>("SELECT Id FROM E_GenelgeGizli WHERE ItemIdentifier = @p0", itemIdentifier).FirstOrDefault();
                        if (exists == null)
                        {
                            db.Database.ExecuteSqlCommand("INSERT INTO E_GenelgeGizli (ItemIdentifier, IsConfidential, MarkedByUserId, MarkedDate, Note) VALUES (@p0, 0, @p1, GETDATE(), @p2)",
                                itemIdentifier, userId, isUserAdmin ? "Admin tarafından kilit açıldı" : "Eğitimci tarafından kilit açıldı");
                        }
                        else
                        {
                            db.Database.ExecuteSqlCommand("UPDATE E_GenelgeGizli SET IsConfidential = 0, MarkedByUserId = @p0, MarkedDate = GETDATE(), Note = @p1 WHERE ItemIdentifier = @p2",
                                userId, isUserAdmin ? "Admin tarafından kilit açıldı" : "Eğitimci tarafından kilit açıldı", itemIdentifier);
                        }
                    }
                    newStatus = false;
                }
                else
                {
                    // Belge kilitlenmek isteniyor (Gizli yapılıyor).
                    // Hem Admin hem Eğitimci belgeyi kilitleyebilir.
                    using (var db = new GZPEGM1())
                    {
                        var exists = db.Database.SqlQuery<int?>("SELECT Id FROM E_GenelgeGizli WHERE ItemIdentifier = @p0", itemIdentifier).FirstOrDefault();
                        if (exists == null)
                        {
                            db.Database.ExecuteSqlCommand("INSERT INTO E_GenelgeGizli (ItemIdentifier, IsConfidential, MarkedByUserId, MarkedDate, Note) VALUES (@p0, 1, @p1, GETDATE(), @p2)",
                                itemIdentifier, userId, isUserAdmin ? "Admin tarafından kilitlendi" : "Eğitimci tarafından kilitlendi");
                        }
                        else
                        {
                            db.Database.ExecuteSqlCommand("UPDATE E_GenelgeGizli SET IsConfidential = 1, MarkedByUserId = @p0, MarkedDate = GETDATE(), Note = @p1 WHERE ItemIdentifier = @p2",
                                userId, isUserAdmin ? "Admin tarafından kilitlendi" : "Eğitimci tarafından kilitlendi", itemIdentifier);
                        }
                    }
                    newStatus = true;
                }

                ClearCache();
                return true;
            }
            catch (Exception ex)
            {
                err = ex.Message;
                return false;
            }
        }

        /// <summary>
        /// Bir belgenin veya klasörün gizlilik durumunu (Gizli veya Açık) açıkça belirler.
        /// KURAL: Eğitimciler yöneticinin (Admin) kilitlediği belgenin kilidini açamaz.
        /// </summary>
        public bool SetConfidentialStatus(string itemIdentifier, bool isConfidential, int userId, bool isUserAdmin, out string err)
        {
            err = null;
            try
            {
                if (string.IsNullOrWhiteSpace(itemIdentifier))
                {
                    err = "Belge yolu boş olamaz.";
                    return false;
                }

                string normalizedId = itemIdentifier.Trim().Replace('/', '\\');

                // Eğer açık yapılmak isteniyorsa:
                if (!isConfidential)
                {
                    // KURAL: Eğitimciler adminin kilitlediği belgenin kilidini açamaz!
                    if (!isUserAdmin)
                    {
                        if (IsItemConfidential(normalizedId, out bool lockedByAdmin, out string lockedByName) && lockedByAdmin)
                        {
                            err = $"Yetki Engeli: Bu belge {lockedByName} tarafından kilitlenmiştir. Eğitimciler yöneticinin (Admin) kilitlediği belgelerin kilidini açamaz!";
                            return false;
                        }
                    }
                }

                using (var db = new GZPEGM1())
                {
                    var exists = db.Database.SqlQuery<int?>("SELECT Id FROM E_GenelgeGizli WHERE ItemIdentifier = @p0 OR ItemIdentifier = @p1",
                        normalizedId, normalizedId.Replace('\\', '/')).FirstOrDefault();

                    int confValue = isConfidential ? 1 : 0;
                    string note = isConfidential
                        ? (isUserAdmin ? "Admin tarafından Gizli olarak belirlendi" : "Eğitimci tarafından Gizli olarak belirlendi")
                        : (isUserAdmin ? "Admin tarafından Açık olarak belirlendi" : "Eğitimci tarafından Açık olarak belirlendi");

                    if (exists == null)
                    {
                        db.Database.ExecuteSqlCommand("INSERT INTO E_GenelgeGizli (ItemIdentifier, IsConfidential, MarkedByUserId, MarkedDate, Note) VALUES (@p0, @p1, @p2, GETDATE(), @p3)",
                            normalizedId, confValue, userId, note);
                    }
                    else
                    {
                        db.Database.ExecuteSqlCommand("UPDATE E_GenelgeGizli SET IsConfidential = @p0, MarkedByUserId = @p1, MarkedDate = GETDATE(), Note = @p2 WHERE Id = @p3",
                            confValue, userId, note, exists.Value);
                    }
                }

                ClearCache();
                return true;
            }
            catch (Exception ex)
            {
                err = ex.Message;
                return false;
            }
        }

        public string GetRelativePath(string fullPath)
        {
            if (string.IsNullOrWhiteSpace(fullPath)) return string.Empty;
            try
            {
                var root = GetStorageRoot();
                if (string.IsNullOrWhiteSpace(root)) return fullPath;
                var normRoot = Path.GetFullPath(root).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
                var normFull = Path.GetFullPath(fullPath);
                if (normFull.StartsWith(normRoot, StringComparison.OrdinalIgnoreCase))
                {
                    return normFull.Substring(normRoot.Length).TrimStart(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
                }
            }
            catch { }
            return fullPath;
        }

        private class RawTalep
        {
            public int Id { get; set; }
            public string ItemIdentifier { get; set; }
            public string ItemTitle { get; set; }
            public int UserId { get; set; }
            public string UserSicil { get; set; }
            public string UserName { get; set; }
            public DateTime RequestDate { get; set; }
            public string Reason { get; set; }
            public string Status { get; set; }
            public DateTime? ExpiryDate { get; set; }
            public string ReviewNote { get; set; }
        }

        #endregion

        #region Dosya Yükleme

        public bool SaveUploadedFile(string category, HttpPostedFileBase file, out string savedPath, out string errorMessage)
        {
            savedPath = null;
            errorMessage = null;

            if (file == null || file.ContentLength <= 0)
            {
                errorMessage = "Geçerli bir dosya seçilmedi.";
                return false;
            }

            var ext = Path.GetExtension(file.FileName);
            if (!AllowedExtensions.Contains(ext))
            {
                errorMessage = "Desteklenmeyen dosya türü. Sadece PDF, Word, Excel ve taranmış görsel dosyaları yüklenebilir.";
                return false;
            }

            var root = GetStorageRoot();
            if (!Directory.Exists(root))
            {
                try
                {
                    Directory.CreateDirectory(root);
                }
                catch (Exception ex)
                {
                    errorMessage = "Depolama klasörü oluşturulamadı: " + ex.Message;
                    return false;
                }
            }

            string cleanCategory = CleanCategoryForFolder(category);
            string targetDir = string.IsNullOrWhiteSpace(cleanCategory) ? root : Path.Combine(root, cleanCategory);

            try
            {
                if (!Directory.Exists(targetDir))
                {
                    Directory.CreateDirectory(targetDir);
                }

                string safeFileName = Path.GetFileName(file.FileName);
                foreach (char c in Path.GetInvalidFileNameChars())
                {
                    safeFileName = safeFileName.Replace(c, '_');
                }

                string targetFilePath = Path.Combine(targetDir, safeFileName);
                if (File.Exists(targetFilePath))
                {
                    string nameNoExt = Path.GetFileNameWithoutExtension(safeFileName);
                    safeFileName = $"{nameNoExt}_{DateTime.Now:yyyyMMdd_HHmmss}{ext}";
                    targetFilePath = Path.Combine(targetDir, safeFileName);
                }

                file.SaveAs(targetFilePath);
                savedPath = targetFilePath;

                ClearCache();
                return true;
            }
            catch (Exception ex)
            {
                errorMessage = "Dosya kaydedilirken hata oluştu: " + ex.Message;
                return false;
            }
        }

        /// <summary>
        /// Kapalı ağdaki bir web sunucusundan (örn: http://10.55.0.193/cikisiptal.pdf) 
        /// belgeyi HTTP üzerinden indirip doğrudan GENELGE ana arşivine kaydeder.
        /// Yalnızca Yönetici ve Eğitimciler tarafından kullanılabilir.
        /// </summary>
        public bool DownloadAndSaveFromUrl(string sourceUrl, string category, string customFileName, out string savedPath, out string errorMessage)
        {
            savedPath = null;
            errorMessage = null;

            if (string.IsNullOrWhiteSpace(sourceUrl))
            {
                errorMessage = "Geçerli bir web/iç ağ bağlantı adresi (URL) belirtilmelidir.";
                return false;
            }

            sourceUrl = sourceUrl.Trim();
            if (!Uri.TryCreate(sourceUrl, UriKind.Absolute, out Uri uri) ||
                (uri.Scheme != Uri.UriSchemeHttp && uri.Scheme != Uri.UriSchemeHttps))
            {
                errorMessage = "Geçersiz bağlantı adresi. Adres http:// veya https:// ile başlamalıdır. (Örn: http://10.55.0.193/cikisiptal.pdf)";
                return false;
            }

            var root = GetStorageRoot();
            if (!Directory.Exists(root))
            {
                try
                {
                    Directory.CreateDirectory(root);
                }
                catch (Exception ex)
                {
                    errorMessage = "Depolama klasörü oluşturulamadı: " + ex.Message;
                    return false;
                }
            }

            string cleanCategory = CleanCategoryForFolder(category);
            string targetDir = string.IsNullOrWhiteSpace(cleanCategory) ? root : Path.Combine(root, cleanCategory);

            try
            {
                if (!Directory.Exists(targetDir))
                {
                    Directory.CreateDirectory(targetDir);
                }

                byte[] fileBytes;
                string discoveredFileName = null;

                // Kapalı ağ sunucusuna bağlantı ve indirme
                using (var handler = new HttpClientHandler())
                {
                    // NTLM/Kerberos Windows Authentication desteği
                    handler.UseDefaultCredentials = true;
                    // SSL sertifika doğrulaması (kapalı ağdaki kendinden imzalı sertifikalar için hata vermesin)
                    handler.ServerCertificateCustomValidationCallback = (sender, cert, chain, sslPolicyErrors) => true;

                    using (var client = new HttpClient(handler))
                    {
                        client.Timeout = TimeSpan.FromSeconds(45);
                        client.DefaultRequestHeaders.Add("User-Agent", "GZPEGM-Mevzuat-Sync/1.0");

                        using (var response = client.GetAsync(uri).GetAwaiter().GetResult())
                        {
                            if (!response.IsSuccessStatusCode)
                            {
                                errorMessage = $"Kaynak sunucuya ({uri.Host}) bağlanılamadı veya dosya bulunamadı. HTTP Durum Kodu: {(int)response.StatusCode} {response.ReasonPhrase}";
                                return false;
                            }

                            // Content-Disposition başlığından dosya adı kontrolü
                            if (response.Content.Headers.ContentDisposition != null &&
                                !string.IsNullOrWhiteSpace(response.Content.Headers.ContentDisposition.FileName))
                            {
                                discoveredFileName = response.Content.Headers.ContentDisposition.FileName.Trim('"', '\'');
                            }

                            fileBytes = response.Content.ReadAsByteArrayAsync().GetAwaiter().GetResult();
                        }
                    }
                }

                if (fileBytes == null || fileBytes.Length == 0)
                {
                    errorMessage = "İndirilen dosya boş (0 bayt).";
                    return false;
                }

                // Maksimum dosya boyutu kontrolü (100 MB)
                if (fileBytes.Length > 104857600)
                {
                    errorMessage = "Dosya boyutu çok büyük (Maksimum 100 MB desteklenir).";
                    return false;
                }

                // Dosya Adı ve Uzantı Belirleme
                string finalFileName;
                if (!string.IsNullOrWhiteSpace(customFileName))
                {
                    finalFileName = customFileName.Trim();
                }
                else if (!string.IsNullOrWhiteSpace(discoveredFileName))
                {
                    finalFileName = discoveredFileName;
                }
                else
                {
                    finalFileName = Path.GetFileName(uri.LocalPath);
                }

                if (string.IsNullOrWhiteSpace(finalFileName))
                {
                    finalFileName = "genelge_" + DateTime.Now.ToString("yyyyMMdd_HHmmss");
                }

                // Geçersiz dosya adı karakterlerini temizle
                foreach (char c in Path.GetInvalidFileNameChars())
                {
                    finalFileName = finalFileName.Replace(c, '_');
                }

                string ext = Path.GetExtension(finalFileName).ToLowerInvariant();
                if (string.IsNullOrWhiteSpace(ext))
                {
                    // URL'den uzantı bulunamadıysa varsayılan pdf ata
                    ext = ".pdf";
                    finalFileName += ext;
                }

                if (!AllowedExtensions.Contains(ext))
                {
                    errorMessage = $"Desteklenmeyen dosya uzantısı ({ext}). Sadece PDF, Word, Excel, PowerPoint ve görsel dosyaları desteklenir.";
                    return false;
                }

                string targetFilePath = Path.Combine(targetDir, finalFileName);
                if (File.Exists(targetFilePath))
                {
                    string nameNoExt = Path.GetFileNameWithoutExtension(finalFileName);
                    finalFileName = $"{nameNoExt}_{DateTime.Now:yyyyMMdd_HHmmss}{ext}";
                    targetFilePath = Path.Combine(targetDir, finalFileName);
                }

                File.WriteAllBytes(targetFilePath, fileBytes);
                savedPath = targetFilePath;

                ClearCache();
                return true;
            }
            catch (Exception ex)
            {
                errorMessage = "Bağlantıdan dosya çekilirken hata oluştu: " + ex.Message;
                return false;
            }
        }

        #endregion

        #region Helper Metodlar

        private GenelgeItem CreateGenelgeItem(FileInfo fi, string rootPath, string folderRelative, Dictionary<string, ConfidentialDbRow> overrideMap)
        {
            var relPath = fi.FullName.Substring(rootPath.TrimEnd(Path.DirectorySeparatorChar).Length + 1);
            var ext = fi.Extension.ToLowerInvariant();
            var title = Path.GetFileNameWithoutExtension(fi.Name);

            bool isPdf = ext == ".pdf";
            bool isTiff = ext == ".tif" || ext == ".tiff";
            bool isImg = ext == ".jpg" || ext == ".jpeg" || ext == ".png";
            bool isOffice = ext == ".doc" || ext == ".docx" || ext == ".xls" || ext == ".xlsx" || ext == ".ppt" || ext == ".pptx";

            string folderTitle = string.IsNullOrWhiteSpace(folderRelative) ? "Genel / Kök Dizin" : CleanFolderTitle(folderRelative);
            string tag = DetermineCategoryTag(!string.IsNullOrWhiteSpace(folderRelative) ? folderRelative : title);

            // Gelişmiş Tarih Ayıklama (Kronolojik Sıra İçin)
            var date = ParseDateFromText(title) ?? ParseDateFromText(folderRelative) ?? fi.LastWriteTime;

            // Gizli Belge ve Kilit Sahibi Kontrolü (Varsayılan olarak tüm genelgeler gizlidir)
            bool isConf = IsItemConfidential(relPath, title, folderRelative, overrideMap, out bool lockedByAdmin, out string lockedByName);

            return new GenelgeItem
            {
                Id = EncodePath(relPath),
                Title = title,
                FileName = fi.Name,
                RelativePath = relPath,
                FolderPath = folderRelative,
                FolderTitle = folderTitle,
                Extension = ext,
                FileSize = fi.Length,
                FormattedSize = FormatFileSize(fi.Length),
                Date = date,
                FormattedDate = date.ToString("dd.MM.yyyy"),
                CategoryTag = tag,
                IsPdf = isPdf,
                IsImage = isImg,
                IsTiff = isTiff,
                IsOffice = isOffice,
                IconClass = GetIconClass(ext),
                IsConfidential = isConf,
                LockedByAdmin = lockedByAdmin,
                LockedByUserName = lockedByName,
                ConfidentialReason = isConf ? (lockedByAdmin ? "Sistem Yöneticisi (Admin) Tarafından Kilitlenmiştir" : "Eğitimci Tarafından Kilitlenmiştir") : null
            };
        }

        public bool IsAutoConfidential(string text)
        {
            if (string.IsNullOrWhiteSpace(text)) return false;
            string upper = text.ToUpper(TrCulture);
            foreach (var kw in ConfidentialKeywords)
            {
                if (upper.Contains(kw)) return true;
            }
            return false;
        }

        private string DetermineCategoryTag(string text)
        {
            if (string.IsNullOrWhiteSpace(text)) return "Genel Mevzuat";

            string lower = text.ToLower(TrCulture);

            if (lower.Contains("uyruk") || lower.Contains("ülkeler") || lower.Contains("ulkeler") || lower.Contains("ülke ") || lower.Contains("ulke ")) return "Ülke Mevzuatı & Yazıları";
            if (lower.Contains("tahdit")) return "Tahditler";
            if (lower.Contains("pasaport") || lower.Contains("vize") || lower.Contains("kaşe") || lower.Contains("180") || lower.Contains("90 gün")) return "Pasaport & Vize";
            if (lower.Contains("ikamet") || lower.Contains("harç") || lower.Contains("harc")) return "İkamet & Harçlar";
            if (lower.Contains("kihbi")) return "KİHBİ Bilgi Sistemi";
            if (lower.Contains("silah") || lower.Contains("kamufle")) return "Silah Mevzuatı";
            if (lower.Contains("siber") || lower.Contains("ebys") || lower.Contains("otoban") || lower.Contains("veri iletisim") || lower.Contains("şifre") || lower.Contains("sifre")) return "Siber & Bilişim";
            if (lower.Contains("sahtecilik") || lower.Contains("adli belge")) return "Sahtecilik";
            if (lower.Contains("inad") || lower.Contains("isk") || lower.Contains("şartlı") || lower.Contains("sartli")) return "İnad & İSK";
            if (lower.Contains("interpol")) return "İnterpol İşlemleri";
            if (lower.Contains("eskiler") || lower.Contains("1990") || lower.Contains("2000")) return "Arşiv Genelgeleri";
            if (lower.Contains("risk analiz") || lower.Contains("faaliyet") || lower.Contains("istatistik")) return "İstatistik & Rapor";

            return "Genel Mevzuat";
        }

        private string CleanFolderTitle(string folderName)
        {
            if (string.IsNullOrWhiteSpace(folderName)) return string.Empty;
            return folderName.Trim();
        }

        public DateTime? ParseDateFromText(string text)
        {
            if (string.IsNullOrWhiteSpace(text)) return null;

            // 1. Regex ile tam tarih araması: dd.MM.yyyy veya yyyy-MM-dd
            var matchDate = Regex.Match(text, @"\b(\d{1,2})[\.\-/](\d{1,2})[\.\-/](\d{4})\b");
            if (matchDate.Success)
            {
                string raw = matchDate.Value.Replace("-", ".").Replace("/", ".");
                if (DateTime.TryParseExact(raw, new[] { "dd.MM.yyyy", "d.M.yyyy", "d.MM.yyyy", "dd.M.yyyy" }, TrCulture, DateTimeStyles.None, out DateTime dt))
                {
                    if (dt.Year >= 1980 && dt.Year <= DateTime.Now.Year + 1)
                        return dt;
                }
            }

            // 2. Yıl tespiti (Örn: "1990-1994 GENELGELER", "2018 GENELGE", "2024")
            var matchYear = Regex.Match(text, @"\b(19\d{2}|20\d{2})\b");
            if (matchYear.Success && int.TryParse(matchYear.Value, out int year))
            {
                if (year >= 1980 && year <= DateTime.Now.Year + 1)
                {
                    return new DateTime(year, 1, 1);
                }
            }

            return null;
        }

        private string CleanCategoryForFolder(string category)
        {
            if (string.IsNullOrWhiteSpace(category)) return "";
            string clean = category.Trim();
            foreach (char c in Path.GetInvalidFileNameChars())
            {
                clean = clean.Replace(c, ' ');
            }
            return clean.Trim();
        }

        public static string FormatFileSize(long bytes)
        {
            if (bytes < 1024) return bytes + " B";
            if (bytes < 1024 * 1024) return (bytes / 1024.0).ToString("F1", TrCulture) + " KB";
            if (bytes < 1024 * 1024 * 1024) return (bytes / (1024.0 * 1024.0)).ToString("F1", TrCulture) + " MB";
            return (bytes / (1024.0 * 1024.0 * 1024.0)).ToString("F2", TrCulture) + " GB";
        }

        public static string GetIconClass(string ext)
        {
            switch (ext.ToLowerInvariant())
            {
                case ".pdf":
                    return "fas fa-file-pdf text-danger";
                case ".doc":
                case ".docx":
                    return "fas fa-file-word text-primary";
                case ".xls":
                case ".xlsx":
                    return "fas fa-file-excel text-success";
                case ".ppt":
                case ".pptx":
                    return "fas fa-file-powerpoint text-warning";
                case ".tif":
                case ".tiff":
                    return "fas fa-file-alt text-info";
                case ".jpg":
                case ".jpeg":
                case ".png":
                    return "fas fa-file-image text-warning";
                case ".txt":
                    return "fas fa-file-alt text-secondary";
                default:
                    return "fas fa-file text-muted";
            }
        }

        public static string EncodePath(string relativePath)
        {
            if (string.IsNullOrEmpty(relativePath)) return string.Empty;
            var bytes = Encoding.UTF8.GetBytes(relativePath);
            return Convert.ToBase64String(bytes).Replace("+", "-").Replace("/", "_").Replace("=", "");
        }

        public static string DecodePath(string encoded)
        {
            if (string.IsNullOrEmpty(encoded)) return string.Empty;
            string incoming = encoded.Replace("-", "+").Replace("_", "/");
            switch (incoming.Length % 4)
            {
                case 2: incoming += "=="; break;
                case 3: incoming += "="; break;
            }
            var bytes = Convert.FromBase64String(incoming);
            return Encoding.UTF8.GetString(bytes);
        }

        #endregion
    }
}
