using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using gzpegm.Cont;
using gzpegm.Models;
using gzpegm.Models.Genelge;
using gzpegm.Services;

namespace gzpegm.Controllers
{
    [UserAuthorize]
    public class GenelgeController : Controller
    {
        private readonly GenelgeService _genelgeService;

        public GenelgeController()
        {
            _genelgeService = new GenelgeService();
        }

        #region Yetkilendirme ve Kullanıcı Bilgileri

        [NonAction]
        private E_User GetCurrentUser()
        {
            try
            {
                HttpCookie userCookie = Request.Cookies["Token"];
                if (userCookie == null || string.IsNullOrWhiteSpace(userCookie.Value)) return null;
                var tokenData = new Token().GetToken(userCookie.Value);
                if (tokenData?.fldUserId == null) return null;
                return new User().GetUserById(Convert.ToInt32(tokenData.fldUserId));
            }
            catch
            {
                return null;
            }
        }

        [NonAction]
        private bool IsAdmin(E_User user)
        {
            if (user == null) return false;
            var auths = (user.fldAuth ?? "").Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries).Select(x => x.Trim()).ToList();
            return auths.Contains("2") || string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase);
        }

        [NonAction]
        private bool CanManageGenelge(E_User user)
        {
            if (user == null) return false;
            var auths = (user.fldAuth ?? "").Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries).Select(x => x.Trim()).ToList();
            // 2: Sistem Yöneticisi (Admin), 6: Eğitimci (Teacher)
            return auths.Contains("2") || auths.Contains("6") ||
                   string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase) ||
                   string.Equals(user.Role, "Teacher", StringComparison.OrdinalIgnoreCase);
        }

        [NonAction]
        private string GetClientIp()
        {
            string ip = Request.ServerVariables["HTTP_X_FORWARDED_FOR"];
            if (string.IsNullOrWhiteSpace(ip) || string.Equals(ip, "unknown", StringComparison.OrdinalIgnoreCase))
                ip = Request.ServerVariables["REMOTE_ADDR"];
            if (string.IsNullOrWhiteSpace(ip))
                ip = Request.UserHostAddress ?? "10.7.202.75";
            return ip.Split(',')[0].Trim();
        }

        [NonAction]
        private string GetWatermarkText(E_User user)
        {
            string sicil = (user?.fldSicil ?? "313258").Trim();
            string name = user != null ? $"{user.fldName} {user.fldLastName}".Trim() : "Personel";
            string ip = GetClientIp();
            string time = DateTime.Now.ToString("dd.MM.yyyy HH:mm");
            return $"T.C. EGM • SİCİL: {sicil} • {name} • IP: {ip} • {time}";
        }

        #endregion

        #region Portal Görünümü & Arama

        [HttpGet]
        public ActionResult Index()
        {
            var currentUser = GetCurrentUser();
            bool canManage = CanManageGenelge(currentUser);
            bool isAdmin = IsAdmin(currentUser);
            int userId = currentUser?.fldId ?? 0;

            var model = _genelgeService.GetPortalSummary(userId, canManage, isAdmin);
            model.IsAdmin = isAdmin;
            model.CanManage = canManage;
            model.UserDisplayName = currentUser != null ? $"{currentUser.fldName} {currentUser.fldLastName}".Trim() : "Personel";
            model.UserSicil = currentUser?.fldSicil ?? "";
            model.UserIp = GetClientIp();

            try
            {
                ViewBag.UvrCountries = new Contuvr().GetAllCountryNames();
            }
            catch { }

            return View(model);
        }

        [HttpGet]
        public ActionResult Search(string q, string category, string type, int page = 1, int pageSize = 40, string sort = "date_desc")
        {
            var currentUser = GetCurrentUser();
            bool canManage = CanManageGenelge(currentUser);
            bool isAdmin = IsAdmin(currentUser);
            int userId = currentUser?.fldId ?? 0;

            var result = _genelgeService.Search(q, category, type, userId, canManage, isAdmin, page, pageSize, sort);
            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public ActionResult CategoryFiles(string folder, string sort = "date_desc")
        {
            if (string.IsNullOrWhiteSpace(folder))
            {
                return Json(new { success = false, message = "Geçersiz kategori." }, JsonRequestBehavior.AllowGet);
            }

            var currentUser = GetCurrentUser();
            bool canManage = CanManageGenelge(currentUser);
            bool isAdmin = IsAdmin(currentUser);
            int userId = currentUser?.fldId ?? 0;

            var (_, folders) = _genelgeService.GetCachedData();
            var matched = folders.FirstOrDefault(f =>
                string.Equals(f.FolderPath, folder, StringComparison.OrdinalIgnoreCase) ||
                string.Equals(f.FolderName, folder, StringComparison.OrdinalIgnoreCase));

            if (matched == null)
            {
                return Json(new { success = false, message = "Kategori bulunamadı." }, JsonRequestBehavior.AllowGet);
            }

            var approvedSet = canManage ? null : _genelgeService.GetUserApprovedIdentifiers(userId);
            var pendingSet = canManage ? null : _genelgeService.GetUserPendingIdentifiers(userId);

            IEnumerable<gzpegm.Models.Genelge.GenelgeItem> sortedFiles = matched.Files;
            switch (sort)
            {
                case "date_asc":
                    sortedFiles = sortedFiles.OrderBy(f => f.Date);
                    break;
                case "name_asc":
                    sortedFiles = sortedFiles.OrderBy(f => f.Title);
                    break;
                default:
                    sortedFiles = sortedFiles.OrderByDescending(f => f.Date);
                    break;
            }

            var files = sortedFiles.Select(d => new
            {
                d.Id,
                d.Title,
                d.FileName,
                d.RelativePath,
                d.Extension,
                d.FormattedSize,
                d.FormattedDate,
                Date = d.Date,
                Timestamp = d.Date.Ticks,
                d.IsPdf,
                d.IsImage,
                d.IsTiff,
                d.IsOffice,
                d.IconClass,
                d.IsConfidential,
                d.LockedByAdmin,
                d.LockedByUserName,
                CanCurrentUserUnlock = isAdmin || (!d.LockedByAdmin && canManage),
                UserHasAccess = canManage || !d.IsConfidential || (approvedSet != null && approvedSet.Contains(d.RelativePath)),
                HasPendingRequest = pendingSet != null && pendingSet.Contains(d.RelativePath)
            }).ToList();

            return Json(new
            {
                success = true,
                folderName = matched.FolderName,
                cleanTitle = matched.CleanTitle,
                tag = matched.CategoryTag,
                count = matched.FileCount,
                isConfidential = matched.IsConfidential,
                lockedByAdmin = matched.LockedByAdmin,
                canCurrentUserUnlock = isAdmin || (!matched.LockedByAdmin && canManage),
                userHasAccess = canManage || !matched.IsConfidential || (approvedSet != null && approvedSet.Contains(matched.FolderPath)),
                files = files
            }, JsonRequestBehavior.AllowGet);
        }

        #endregion

        #region Güvenli Belge Akışı (Canvas PDF, TIFF ve Filigranlı Görsel)

        [HttpGet]
        public ActionResult GetTiffInfo(string path)
        {
            if (string.IsNullOrWhiteSpace(path))
                return Json(new { success = false, message = "Dosya yolu boş." }, JsonRequestBehavior.AllowGet);

            var fullPath = _genelgeService.GetSafeFullPath(path);
            if (string.IsNullOrWhiteSpace(fullPath) || !System.IO.File.Exists(fullPath))
            {
                return Json(new { success = false, message = "Dosya bulunamadı." }, JsonRequestBehavior.AllowGet);
            }

            int pages = _genelgeService.GetTiffPageCount(fullPath);
            return Json(new
            {
                success = true,
                pageCount = pages,
                title = Path.GetFileNameWithoutExtension(fullPath)
            }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public ActionResult RenderTiff(string path, int page = 0)
        {
            var currentUser = GetCurrentUser();
            bool canManage = CanManageGenelge(currentUser);
            int userId = currentUser?.fldId ?? 0;

            var fullPath = _genelgeService.GetSafeFullPath(path);
            if (string.IsNullOrWhiteSpace(fullPath) || !System.IO.File.Exists(fullPath))
            {
                return HttpNotFound("Belge bulunamadı.");
            }

            // Gizli Belge Yetki Kontrolü
            if (!_genelgeService.CheckUserAccess(path, userId, canManage))
            {
                return new HttpStatusCodeResult(403, "Bu gizli belgeye erişim yetkiniz bulunmamaktadır.");
            }

            string watermark = GetWatermarkText(currentUser);
            byte[] jpegBytes = _genelgeService.RenderTiffPageAsJpeg(fullPath, page, watermark, out int totalPages);

            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            Response.Headers["Pragma"] = "no-cache";
            Response.Headers["Expires"] = "-1";
            Response.Headers["Content-Disposition"] = "inline; filename=\"preview.jpg\"";
            Response.Headers["X-Total-Pages"] = totalPages.ToString();

            return File(jpegBytes, "image/jpeg");
        }

        /// <summary>
        /// Word (.doc, .docx), Excel (.xls, .xlsx) ve PowerPoint (.pptx) belgelerini
        /// indirme olmadan tarayıcıda doğrudan A4 formatında HTML olarak render eder.
        /// </summary>
        [HttpGet]
        public ActionResult ViewOfficeHtml(string path)
        {
            if (string.IsNullOrWhiteSpace(path))
                return Json(new { success = false, message = "Belge yolu boş." }, JsonRequestBehavior.AllowGet);

            var currentUser = GetCurrentUser();
            bool canManage = CanManageGenelge(currentUser);
            int userId = currentUser?.fldId ?? 0;

            var fullPath = _genelgeService.GetSafeFullPath(path);
            if (string.IsNullOrWhiteSpace(fullPath) || !System.IO.File.Exists(fullPath))
            {
                return Json(new { success = false, message = "Belge bulunamadı." }, JsonRequestBehavior.AllowGet);
            }

            // Gizli Belge Yetki Kontrolü
            if (!_genelgeService.CheckUserAccess(path, userId, canManage))
            {
                return Json(new { success = false, message = "Bu gizli belgeye erişim yetkiniz bulunmamaktadır." }, JsonRequestBehavior.AllowGet);
            }

            string html = _genelgeService.RenderOfficeDocumentAsHtml(fullPath);
            return Json(new
            {
                success = true,
                title = Path.GetFileNameWithoutExtension(fullPath),
                fileName = Path.GetFileName(fullPath),
                extension = Path.GetExtension(fullPath).ToLowerInvariant(),
                html = html
            }, JsonRequestBehavior.AllowGet);
        }

        /// <summary>
        /// PDF.js Canvas okuyucusu için binary veri akışı.
        /// Doğrudan URL ile indirilmesini engeller; yalnızca portal içinden AJAX ile çağrılabilir.
        /// </summary>
        [HttpGet]
        public ActionResult ViewPdfData(string path)
        {
            if (string.IsNullOrWhiteSpace(path))
                return HttpNotFound("Belge yolu belirtilmedi.");

            var currentUser = GetCurrentUser();
            if (currentUser == null)
            {
                return new HttpStatusCodeResult(401, "Oturum açılmalıdır.");
            }

            bool canManage = CanManageGenelge(currentUser);
            int userId = currentUser.fldId;

            var fullPath = _genelgeService.GetSafeFullPath(path);
            if (string.IsNullOrWhiteSpace(fullPath) || !System.IO.File.Exists(fullPath))
            {
                return HttpNotFound("Belge bulunamadı.");
            }

            // Gizli Belge Yetki Kontrolü
            if (!_genelgeService.CheckUserAccess(path, userId, canManage))
            {
                return new HttpStatusCodeResult(403, "Bu gizli belgeye erişim yetkiniz bulunmamaktadır.");
            }

            // Doğrudan Adres Çubuğundan Çağrılmayı Engelle (Referrer kontrolü)
            var refHeader = Request.UrlReferrer;
            bool isFromPortal = refHeader != null && refHeader.Host.Equals(Request.Url.Host, StringComparison.OrdinalIgnoreCase);
            if (!isFromPortal && !Request.IsLocal)
            {
                return Content("<script>alert('EGM Güvenlik Uyarısı: Belgelere doğrudan bağlantı ile erişilemez. Lütfen portal içerisinden inceleyiniz.'); window.location.href='/Genelge';</script>");
            }

            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            Response.Headers["Pragma"] = "no-cache";
            Response.Headers["Expires"] = "-1";
            Response.Headers["Content-Disposition"] = "inline; filename=\"protected-stream.bin\"";

            return File(fullPath, "application/pdf");
        }

        /// <summary>
        /// Genelge ve resmi belgeleri ayrı tam sayfa pencerede / sekmede güvenli inceleme ekranı.
        /// </summary>
        [HttpGet]
        public ActionResult Viewer(string path)
        {
            if (string.IsNullOrWhiteSpace(path))
                return HttpNotFound("Belge yolu belirtilmedi.");

            var currentUser = GetCurrentUser();
            if (currentUser == null)
            {
                return RedirectToAction("Index", "Giris", new { returnUrl = Request.RawUrl });
            }

            bool canManage = CanManageGenelge(currentUser);
            int userId = currentUser.fldId;

            var fullPath = _genelgeService.GetSafeFullPath(path);
            if (string.IsNullOrWhiteSpace(fullPath) || !System.IO.File.Exists(fullPath))
            {
                return HttpNotFound("Belge bulunamadı veya sistemden kaldırılmış.");
            }

            // Gizli Belge Yetki Kontrolü
            if (!_genelgeService.CheckUserAccess(path, userId, canManage))
            {
                return Content("<script>alert('Bu gizli belgeye erişim yetkiniz bulunmamaktadır.'); window.close(); history.back();</script>");
            }

            var ext = Path.GetExtension(fullPath).ToLowerInvariant();
            string docType = "image";
            if (ext == ".pdf") docType = "pdf";
            else if (ext == ".tif" || ext == ".tiff") docType = "tiff";
            else if (ext == ".doc" || ext == ".docx" || ext == ".xls" || ext == ".xlsx" || ext == ".ppt" || ext == ".pptx") docType = "office";

            ViewBag.DocPath = path;
            ViewBag.DocTitle = !string.IsNullOrWhiteSpace(fullPath) ? Path.GetFileName(fullPath) : Path.GetFileName(path);
            ViewBag.DocType = docType;
            ViewBag.UserSicil = currentUser.fldSicil ?? currentUser.fldId.ToString();
            ViewBag.UserIp = Request.ServerVariables["HTTP_X_FORWARDED_FOR"] ?? Request.UserHostAddress;

            return View();
        }

        [HttpGet]
        public ActionResult ViewDocument(string path)
        {
            if (string.IsNullOrWhiteSpace(path))
                return HttpNotFound("Belge yolu belirtilmedi.");

            var currentUser = GetCurrentUser();
            bool canManage = CanManageGenelge(currentUser);
            int userId = currentUser?.fldId ?? 0;

            var fullPath = _genelgeService.GetSafeFullPath(path);
            if (string.IsNullOrWhiteSpace(fullPath) || !System.IO.File.Exists(fullPath))
            {
                return HttpNotFound("Belge bulunamadı veya erişim yetkiniz yok.");
            }

            // Gizli Belge Yetki Kontrolü
            if (!_genelgeService.CheckUserAccess(path, userId, canManage))
            {
                return Content("<script>alert('Bu gizli belgeye erişim yetkiniz bulunmamaktadır.'); history.back();</script>");
            }

            var ext = Path.GetExtension(fullPath).ToLowerInvariant();

            // PDF ise doğrudan iframe'e veya tarayıcıya vermek yerine güvenli Canvas akışına yönlendir
            if (ext == ".pdf")
            {
                return ViewPdfData(path);
            }

            // TIFF dosyaları
            if (ext == ".tif" || ext == ".tiff")
            {
                return RedirectToAction("RenderTiff", new { path = path, page = 0 });
            }

            // Resim dosyaları (JPG, PNG) -> Sunucuda filigran basılarak döndürülür
            if (ext == ".jpg" || ext == ".jpeg" || ext == ".png")
            {
                string watermark = GetWatermarkText(currentUser);
                byte[] watermarkedBytes = _genelgeService.RenderImageWithWatermark(fullPath, watermark);
                Response.Cache.SetCacheability(HttpCacheability.NoCache);
                Response.Cache.SetNoStore();
                Response.Headers["Pragma"] = "no-cache";
                Response.Headers["Expires"] = "-1";
                Response.Headers["Content-Disposition"] = "inline; filename=\"image.jpg\"";
                return File(watermarkedBytes, "image/jpeg");
            }

            return Content("<script>alert('Bu dosya türü yalnızca portal içi güvenli okuyucuda incelenebilir.'); window.close(); history.back();</script>");
        }

        [HttpGet]
        public ActionResult Download(string path)
        {
            // Doğrudan indirme yerine güvenli portal görüntüleyicisine yönlendirme uyarısı
            return Content("<script>alert('EGM Bilgi Güvenliği: Mevzuat ve genelge belgeleri güvenli inceleme amacıyla yalnızca portal üzerinden görüntülenebilmektedir.'); window.close(); history.back();</script>");
        }

        #endregion

        #region Gizli Belge Erişim Talepleri

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult RequestAccess(string path, string title, string reason)
        {
            var currentUser = GetCurrentUser();
            if (currentUser == null)
            {
                return Json(new { success = false, message = "Oturum süreniz dolmuş." });
            }

            string relPath = path;
            try { relPath = GenelgeService.DecodePath(path); } catch { }

            string userName = $"{currentUser.fldName} {currentUser.fldLastName}".Trim();
            string sicil = currentUser.fldSicil ?? "";

            bool ok = _genelgeService.CreateAccessRequest(relPath, title, currentUser.fldId, sicil, userName, reason, out string err);
            return Json(new { success = ok, message = ok ? "Erişim talebiniz yöneticilere iletildi. Onaylandığında belgeyi inceleyebilirsiniz." : err });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ReviewRequest(int requestId, string status, int? validHours, string note)
        {
            var currentUser = GetCurrentUser();
            if (!CanManageGenelge(currentUser))
            {
                return Json(new { success = false, message = "Bu işlem için yetkiniz bulunmamaktadır." });
            }

            bool ok = _genelgeService.ReviewAccessRequest(requestId, status, currentUser.fldId, validHours, note, out string err);
            return Json(new { success = ok, message = ok ? "Talep başarıyla güncellendi." : err });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ToggleConfidential(string path)
        {
            var currentUser = GetCurrentUser();
            if (!CanManageGenelge(currentUser))
            {
                return Json(new { success = false, message = "Bu işlem için yetkiniz bulunmamaktadır." });
            }

            bool isAdmin = IsAdmin(currentUser);
            string relPath = path;
            try { relPath = GenelgeService.DecodePath(path); } catch { }

            bool ok = _genelgeService.ToggleConfidential(relPath, currentUser.fldId, isAdmin, out bool newStatus, out string err);
            return Json(new
            {
                success = ok,
                isConfidential = newStatus,
                message = ok ? (newStatus ? "Belge GİZLİ olarak kilitlendi." : "Belgenin gizlilik kilidi açıldı (Herkese Açık).") : err
            });
        }

        #endregion

        #region Yönetici & Eğitimci İşlemleri (Yükleme ve Senkronizasyon)

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Upload(string category, string customCategory, HttpPostedFileBase file, string country = null, bool isConfidential = true)
        {
            var currentUser = GetCurrentUser();
            if (!CanManageGenelge(currentUser))
            {
                return Json(new { success = false, message = "Genelge yüklemek için yetkiniz (Yönetici veya Eğitimci) bulunmamaktadır." });
            }

            string finalCategory = !string.IsNullOrWhiteSpace(customCategory) ? customCategory.Trim() : (category ?? "").Trim();
            if (string.IsNullOrWhiteSpace(finalCategory))
            {
                finalCategory = "Genel Mevzuat";
            }

            // Ülkeye özel ilişkilendirme
            if (!string.IsNullOrWhiteSpace(country))
            {
                string cName = country.Trim();
                if (!string.IsNullOrWhiteSpace(customCategory))
                    finalCategory = Path.Combine("ÜLKELER", cName, customCategory.Trim());
                else if (!string.IsNullOrWhiteSpace(category) && category != "Genel Mevzuat")
                    finalCategory = Path.Combine("ÜLKELER", cName, category.Trim());
                else
                    finalCategory = Path.Combine("ÜLKELER", cName);
            }

            bool ok = _genelgeService.SaveUploadedFile(finalCategory, file, out string savedPath, out string err);
            if (!ok)
            {
                return Json(new { success = false, message = err ?? "Dosya yüklenirken hata oluştu." });
            }

            // Gizlilik derecesini kaydet
            string relPath = _genelgeService.GetRelativePath(savedPath);
            if (!string.IsNullOrWhiteSpace(relPath))
            {
                _genelgeService.SetConfidentialStatus(relPath, isConfidential, currentUser.fldId, IsAdmin(currentUser), out _);
            }

            string statusText = isConfidential ? "GİZLİ" : "AÇIK";
            return Json(new { success = true, message = $"Genelge başarıyla yüklendi ve [{statusText}] olarak arşive kaydedildi." });
        }

        /// <summary>
        /// Kapalı intranet ağından (örn: http://10.55.0.193/cikisiptal.pdf) URL ile genelge çeker ve arşive ekler.
        /// KESİN KURAL: Normal kullanıcılar bu işlemi yapamaz, yalnızca Yönetici ve Eğitimciler yapabilir.
        /// </summary>
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult FetchFromUrl(string sourceUrl, string category, string customCategory, string customFileName, string country = null, bool isConfidential = true)
        {
            var currentUser = GetCurrentUser();
            if (!CanManageGenelge(currentUser))
            {
                return Json(new { success = false, message = "Bu işlem için yetkiniz (Yönetici veya Eğitimci) bulunmamaktadır." });
            }

            string finalCategory = !string.IsNullOrWhiteSpace(customCategory) ? customCategory.Trim() : (category ?? "").Trim();
            if (string.IsNullOrWhiteSpace(finalCategory))
            {
                finalCategory = "Genel Mevzuat";
            }

            // Ülkeye özel ilişkilendirme
            if (!string.IsNullOrWhiteSpace(country))
            {
                string cName = country.Trim();
                if (!string.IsNullOrWhiteSpace(customCategory))
                    finalCategory = Path.Combine("ÜLKELER", cName, customCategory.Trim());
                else if (!string.IsNullOrWhiteSpace(category) && category != "Genel Mevzuat")
                    finalCategory = Path.Combine("ÜLKELER", cName, category.Trim());
                else
                    finalCategory = Path.Combine("ÜLKELER", cName);
            }

            bool ok = _genelgeService.DownloadAndSaveFromUrl(sourceUrl, finalCategory, customFileName, out string savedPath, out string err);
            if (!ok)
            {
                return Json(new { success = false, message = err ?? "Bağlantıdan dosya indirilemedi." });
            }

            // Gizlilik derecesini kaydet
            string relPath = _genelgeService.GetRelativePath(savedPath);
            if (!string.IsNullOrWhiteSpace(relPath))
            {
                _genelgeService.SetConfidentialStatus(relPath, isConfidential, currentUser.fldId, IsAdmin(currentUser), out _);
            }

            string fileName = Path.GetFileName(savedPath);
            string statusText = isConfidential ? "GİZLİ" : "AÇIK";
            return Json(new
            {
                success = true,
                message = $"'{fileName}' belgesi bağlantıdan başarıyla indirildi ve [{statusText}] olarak '{finalCategory}' arşivine eklendi.",
                fileName = fileName
            });
        }

        [HttpPost]
        public ActionResult Rescan()
        {
            var currentUser = GetCurrentUser();
            if (!CanManageGenelge(currentUser))
            {
                return Json(new { success = false, message = "Bu işlem için yetkiniz (Yönetici veya Eğitimci) bulunmamaktadır." });
            }

            try
            {
                string storagePath = _genelgeService.GetStorageRoot();
                if (string.IsNullOrWhiteSpace(storagePath) || !Directory.Exists(storagePath))
                {
                    return Json(new
                    {
                        success = false,
                        message = $"Depolama dizini bulunamadı veya erişilemedi!\nTanımlı Yol: '{storagePath}'\nLütfen Web.config GenelgeStoragePath ayarını ve IIS/Windows klasör erişim izinlerini kontrol ediniz."
                    });
                }

                _genelgeService.ClearCache();
                var data = _genelgeService.GetCachedData(true);
                return Json(new
                {
                    success = true,
                    message = $"Tarama tamamlandı!\nDepo Dizini: {storagePath}\nToplam {data.Folders.Count} konu başlığı ve {data.Documents.Count} belge güncellendi."
                });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = "Tarama sırasında hata oluştu: " + ex.Message });
            }
        }

        #region Ülke Belgeleri & Mevzuat Entegrasyonu

        [HttpGet]
        public JsonResult GetCountryDocuments(string country)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(country))
                {
                    return Json(new { success = false, message = "Ülke adı belirtilmelidir." }, JsonRequestBehavior.AllowGet);
                }

                var currentUser = GetCurrentUser();
                bool canManage = CanManageGenelge(currentUser);
                bool isAdmin = IsAdmin(currentUser);
                int userId = currentUser?.fldId ?? 0;

                string cleanCountry = country.Trim();
                var docs = _genelgeService.GetDocumentsByCountry(cleanCountry, userId, canManage, isAdmin);

                // UVR ve harç özeti
                var contUvr = new Contuvr();
                var uvr = contUvr.GetKaseVizeByCountry(cleanCountry);
                decimal perDayPrice = 10m;
                try
                {
                    var t = new gzpegm.Cont.tgvh();
                    perDayPrice = t.GetCurrentPrice(10m);
                }
                catch { }

                object regimeInfo = null;
                if (uvr != null)
                {
                    regimeInfo = new
                    {
                        country = uvr.fldCountry,
                        day = uvr.fldDay,
                        calculateType = uvr.fldCalculateType,
                        passportType = uvr.fldPassportType,
                        visaStatus = uvr.fldVisaStatus,
                        oneTime = uvr.fldOneTime,
                        harcByte = uvr.fldHB,
                        harcText = (uvr.fldHB.HasValue && uvr.fldHB.Value == 1) ? "Harca Tabi" : "Harçtan Muaf"
                    };
                }

                var docList = docs.Select(d => new
                {
                    id = d.Id,
                    title = d.Title,
                    fileName = d.FileName,
                    relativePath = d.RelativePath,
                    folderTitle = d.FolderTitle,
                    extension = d.Extension,
                    formattedSize = d.FormattedSize,
                    formattedDate = d.FormattedDate,
                    categoryTag = d.CategoryTag,
                    isPdf = d.IsPdf,
                    isOffice = d.IsOffice,
                    isImage = d.IsImage,
                    isTiff = d.IsTiff,
                    isConfidential = d.IsConfidential,
                    lockedByAdmin = d.LockedByAdmin,
                    canCurrentUserUnlock = d.CanCurrentUserUnlock,
                    userHasAccess = d.UserHasAccess,
                    hasPendingRequest = d.HasPendingRequest
                }).ToList();

                return Json(new
                {
                    success = true,
                    country = cleanCountry,
                    totalCount = docList.Count,
                    documents = docList,
                    regime = regimeInfo,
                    dailyPrice = perDayPrice
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = "Ülke belgeleri alınırken hata oluştu: " + ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpGet]
        public JsonResult GetCountryDocCounts()
        {
            try
            {
                var contUvr = new Contuvr();
                var allCountries = contUvr.GetAllCountryNames();
                var list = _genelgeService.GetTopCountriesWithDocuments(allCountries, minCount: 1);

                return Json(new
                {
                    success = true,
                    items = list
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        #endregion

        #endregion
    }
}
