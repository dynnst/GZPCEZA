using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.NetworkInformation;
using System.Net.Sockets;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;

namespace gzpegm.Helpers
{
    /// <summary>
    /// EGM CEZAM Portalı - Akıllı Sunucu Yönlendirme, Yedeklilik (Failover) ve Çift Yönlü Kullanıcı Senkronizasyon Yardımcısı.
    /// Ana Sunucu (10.7.202.75) ile Yedek Sunucu (10.7.202.76) arasında
    /// IIS ARR / NLB gerektirmeden kod seviyesinde yönlendirme ve kullanıcı eşitleme sağlar.
    /// </summary>
    public static class ServerFailoverHelper
    {
        private static readonly object SyncLock = new object();
        private static bool _lastPrimaryCheckResult = false;
        private static DateTime _lastPrimaryCheckTime = DateTime.MinValue;

        public static string RoleSetting => ConfigurationManager.AppSettings["ServerRole"] ?? "Auto";
        public static string PrimaryServerUrl => (ConfigurationManager.AppSettings["PrimaryServerUrl"] ?? "http://10.7.202.75").TrimEnd('/');
        public static string BackupServerUrl => (ConfigurationManager.AppSettings["BackupServerUrl"] ?? "http://10.7.202.76").TrimEnd('/');
        public static string SyncSecret => ConfigurationManager.AppSettings["InternalSyncSecret"] ?? "GZPEGM-CEZAM-SYNC-KEY-2026";

        public static int HealthIntervalSeconds
        {
            get
            {
                if (int.TryParse(ConfigurationManager.AppSettings["FailoverHealthIntervalSeconds"], out int sec) && sec > 0)
                    return sec;
                return 5; // Varsayılan: 5 saniyelik önbellek
            }
        }

        public static int TimeoutMs
        {
            get
            {
                if (int.TryParse(ConfigurationManager.AppSettings["FailoverTimeoutMs"], out int ms) && ms > 0)
                    return ms;
                return 1500; // Maksimum 1.5 saniye bekleme
            }
        }

        /// <summary>
        /// Karşı/Eş sunucunun adresini döner (.75 ise .76'yı, .76 ise .75'i verir).
        /// </summary>
        public static string GetPairedServerUrl()
        {
            return IsBackupServer ? PrimaryServerUrl : BackupServerUrl;
        }

        /// <summary>
        /// Sunucunun aktif çalışma rolünü belirler: "Primary", "Backup" veya "Disabled"
        /// </summary>
        public static string GetCurrentServerRole()
        {
            var role = RoleSetting.Trim();
            if (string.Equals(role, "Primary", StringComparison.OrdinalIgnoreCase)) return "Primary";
            if (string.Equals(role, "Backup", StringComparison.OrdinalIgnoreCase)) return "Backup";
            if (string.Equals(role, "Disabled", StringComparison.OrdinalIgnoreCase)) return "Disabled";

            // "Auto" modunda makinenin kendi yerel IPv4 adreslerine bakılır
            try
            {
                var localIps = GetLocalIPv4Addresses();
                if (localIps.Contains("10.7.202.76"))
                    return "Backup";
                if (localIps.Contains("10.7.202.75"))
                    return "Primary";
            }
            catch
            {
                // IP tespiti başarısız olursa güvenli varsayılan olarak Primary kabul edilir
            }

            return "Primary";
        }

        public static bool IsBackupServer => string.Equals(GetCurrentServerRole(), "Backup", StringComparison.OrdinalIgnoreCase);

        public static bool IsPrimaryServer => string.Equals(GetCurrentServerRole(), "Primary", StringComparison.OrdinalIgnoreCase);

        /// <summary>
        /// Ana sunucunun (10.7.202.75) ayakta olup olmadığını kontrol eder.
        /// Sunucuya aşırı yük binmesini önlemek için sonuçlar hafızada saklanır.
        /// </summary>
        public static bool CheckIfPrimaryIsOnline(bool forceFreshCheck = false)
        {
            var now = DateTime.UtcNow;
            if (!forceFreshCheck && (now - _lastPrimaryCheckTime).TotalSeconds < HealthIntervalSeconds)
            {
                return _lastPrimaryCheckResult;
            }

            lock (SyncLock)
            {
                if (!forceFreshCheck && (DateTime.UtcNow - _lastPrimaryCheckTime).TotalSeconds < HealthIntervalSeconds)
                {
                    return _lastPrimaryCheckResult;
                }

                bool isOnline = PerformHttpHealthCheck(PrimaryServerUrl + "/Health/Check", TimeoutMs);
                _lastPrimaryCheckResult = isOnline;
                _lastPrimaryCheckTime = DateTime.UtcNow;
                return isOnline;
            }
        }

        private static bool PerformHttpHealthCheck(string url, int timeoutMs)
        {
            try
            {
                var request = (HttpWebRequest)WebRequest.Create(url);
                request.Method = "GET";
                request.Timeout = timeoutMs;
                request.ReadWriteTimeout = timeoutMs;
                request.KeepAlive = false;

                using (var response = (HttpWebResponse)request.GetResponse())
                {
                    return response.StatusCode == HttpStatusCode.OK;
                }
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Gelen HTTP isteğinin ana sunucuya (10.7.202.75) yönlendirilmesi gerekip gerekmediğini denetler.
        /// </summary>
        public static bool ShouldRedirect(HttpContext context, out string targetUrl)
        {
            targetUrl = null;
            if (context == null || context.Request == null) return false;

            // Sadece Yedek Sunucu (10.7.202.76) yönlendirme yapar
            if (!IsBackupServer) return false;

            var path = context.Request.Path?.ToLowerInvariant() ?? "";

            // İstisnalar: Sağlık, log, senkronizasyon ve statik kaynaklar asla yönlendirilmez
            if (IsExemptPath(path)) return false;

            // Yönetici bypass kontrolü (forceLocal=1 veya bypassFailover=1 veya cookie)
            if (string.Equals(context.Request.QueryString["forceLocal"], "1", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(context.Request.QueryString["bypassFailover"], "1", StringComparison.OrdinalIgnoreCase) ||
                context.Request.Cookies["BypassFailover"] != null)
            {
                return false;
            }

            // Ana sunucunun durumuna bak
            bool primaryOnline = CheckIfPrimaryIsOnline();

            if (primaryOnline)
            {
                // Ana sunucu ayakta -> Kullanıcıyı şeffaf olarak ana sunucuya aktar
                targetUrl = PrimaryServerUrl + context.Request.RawUrl;
                return true;
            }

            // Ana sunucu ÇÖKMÜŞ -> Yönlendirme yapma, yedek sunucu hizmet versin!
            return false;
        }

        private static bool IsExemptPath(string path)
        {
            // Sağlık, hata ve senkronizasyon kontrol uç noktaları
            if (path.StartsWith("/health") ||
                path.StartsWith("/sistemsaglik") ||
                path.StartsWith("/hataloglari") ||
                path.StartsWith("/errorlogs") ||
                path.StartsWith("/internal-sync") ||
                path.StartsWith("/api/internal"))
                return true;

            // Statik dosya uzantıları
            if (path.EndsWith(".css") || path.EndsWith(".js") || path.EndsWith(".png") ||
                path.EndsWith(".jpg") || path.EndsWith(".jpeg") || path.EndsWith(".gif") ||
                path.EndsWith(".ico") || path.EndsWith(".svg") || path.EndsWith(".woff") ||
                path.EndsWith(".woff2") || path.EndsWith(".ttf") || path.EndsWith(".eot") ||
                path.EndsWith(".map"))
                return true;

            return false;
        }

        /// <summary>
        /// Sistemin şu anda acil durum (failover) modunda çalışıp çalışmadığını bildirir.
        /// </summary>
        public static bool IsOperatingInFailoverMode(HttpContextBase context = null)
        {
            if (!IsBackupServer) return false;

            // Yedek sunucudayız ve ana sunucu kapalıysa failover modundayız
            return !CheckIfPrimaryIsOnline();
        }

        public static bool IsOperatingInFailoverMode(HttpContext context)
        {
            if (!IsBackupServer) return false;
            return !CheckIfPrimaryIsOnline();
        }

        /// <summary>
        /// Yerel veritabanında bulunmayan bir kullanıcının karşı sunucuda bulunup bulunmadığını kontrol eder.
        /// Varsa yerel veritabanına ekler ve E_User nesnesini döner.
        /// </summary>
        public static E_User TrySyncUserFromRemote(string sicil, string password)
        {
            if (string.IsNullOrWhiteSpace(sicil) || string.IsNullOrWhiteSpace(password))
                return null;

            try
            {
                var remoteUrl = GetPairedServerUrl();
                if (string.IsNullOrWhiteSpace(remoteUrl))
                    return null;

                var endpoint = remoteUrl + "/internal-sync/verify-and-get-user";
                var secret = SyncSecret;

                var postData = "sicil=" + HttpUtility.UrlEncode(sicil.Trim()) +
                               "&password=" + HttpUtility.UrlEncode(password.Trim()) +
                               "&syncSecret=" + HttpUtility.UrlEncode(secret);

                var bytes = Encoding.UTF8.GetBytes(postData);

                var request = (HttpWebRequest)WebRequest.Create(endpoint);
                request.Method = "POST";
                request.ContentType = "application/x-www-form-urlencoded";
                request.Headers.Add("X-Internal-Sync-Token", secret);
                request.Timeout = 2500; // 2.5 saniye bekleme
                request.ContentLength = bytes.Length;

                using (var stream = request.GetRequestStream())
                {
                    stream.Write(bytes, 0, bytes.Length);
                }

                using (var response = (HttpWebResponse)request.GetResponse())
                using (var reader = new StreamReader(response.GetResponseStream(), Encoding.UTF8))
                {
                    var json = reader.ReadToEnd();
                    var serializer = new JavaScriptSerializer();
                    var dict = serializer.Deserialize<Dictionary<string, object>>(json);

                    if (dict != null && dict.ContainsKey("success") && Convert.ToBoolean(dict["success"]))
                    {
                        if (dict.ContainsKey("user") && dict["user"] is Dictionary<string, object> uDict)
                        {
                            using (var db = new GZPEGM1())
                            {
                                var cleanSicil = sicil.Trim();
                                var existing = db.E_User.FirstOrDefault(u => u.fldSicil.Trim() == cleanSicil);
                                if (existing != null)
                                    return existing;

                                var newUser = new E_User
                                {
                                    fldSicil = GetDictString(uDict, "fldSicil"),
                                    fldPassword = GetDictString(uDict, "fldPassword"),
                                    fldName = GetDictString(uDict, "fldName"),
                                    fldLastName = GetDictString(uDict, "fldLastName"),
                                    fldPhone = GetDictString(uDict, "fldPhone"),
                                    fldEmail = GetDictString(uDict, "fldEmail"),
                                    fldTitle = GetDictString(uDict, "fldTitle"),
                                    fldDeputy = GetDictString(uDict, "fldDeputy"),
                                    fldBorder = GetDictString(uDict, "fldBorder"),
                                    fldActive = GetDictString(uDict, "fldActive") ?? "1",
                                    IsActive = uDict.ContainsKey("IsActive") && uDict["IsActive"] != null ? Convert.ToBoolean(uDict["IsActive"]) : true,
                                    Role = GetDictString(uDict, "Role") ?? "Student",
                                    fldAuth = GetDictString(uDict, "fldAuth") ?? "3",
                                    fldPicture = GetDictString(uDict, "fldPicture"),
                                    fldDateTime = DateTime.Now,
                                    LastLogin = DateTime.Now
                                };

                                db.E_User.Add(newUser);
                                db.SaveChanges();

                                System.Diagnostics.Trace.TraceInformation($"[UserSync] Personel ({newUser.fldSicil}) karşı sunucudan ({remoteUrl}) yerel veritabanına otomatik olarak senkronize edildi.");
                                return newUser;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceWarning($"[UserSync Warning] Karşı sunucu ile kullanıcı doğrulama yapılamadı: {ex.Message}");
            }

            return null;
        }

        /// <summary>
        /// Karşı sunucudaki kullanıcıları yerel veritabanı ile karşılaştırır.
        /// Yerelde eksik olan kullanıcıların listesini döner.
        /// </summary>
        public static RemoteUserComparisonResult CompareWithRemoteServer()
        {
            var result = new RemoteUserComparisonResult();
            var remoteUrl = GetPairedServerUrl();
            result.RemoteServerUrl = remoteUrl;

            try
            {
                var endpoint = remoteUrl + "/internal-sync/users-summary?syncSecret=" + HttpUtility.UrlEncode(SyncSecret);
                var request = (HttpWebRequest)WebRequest.Create(endpoint);
                request.Method = "GET";
                request.Headers.Add("X-Internal-Sync-Token", SyncSecret);
                request.Timeout = 4000;

                using (var response = (HttpWebResponse)request.GetResponse())
                using (var reader = new StreamReader(response.GetResponseStream(), Encoding.UTF8))
                {
                    var json = reader.ReadToEnd();
                    var serializer = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };
                    var dict = serializer.Deserialize<Dictionary<string, object>>(json);

                    if (dict != null && dict.ContainsKey("success") && Convert.ToBoolean(dict["success"]))
                    {
                        var rawUsers = dict["users"] as System.Collections.ArrayList;
                        if (rawUsers != null)
                        {
                            var remoteUsers = new List<RemoteUserSummaryItem>();
                            foreach (Dictionary<string, object> u in rawUsers)
                            {
                                remoteUsers.Add(new RemoteUserSummaryItem
                                {
                                    Sicil = GetDictString(u, "Sicil"),
                                    FullName = GetDictString(u, "FullName"),
                                    Title = GetDictString(u, "Title"),
                                    Border = GetDictString(u, "Border"),
                                    Role = GetDictString(u, "Role"),
                                    Auth = GetDictString(u, "Auth"),
                                    IsActive = u.ContainsKey("IsActive") && Convert.ToBoolean(u["IsActive"])
                                });
                            }

                            using (var db = new GZPEGM1())
                            {
                                var localSicils = db.E_User
                                    .AsNoTracking()
                                    .Where(u => !string.IsNullOrEmpty(u.fldSicil))
                                    .Select(u => u.fldSicil.Trim())
                                    .ToList();

                                var localSicilSet = new HashSet<string>(localSicils, StringComparer.OrdinalIgnoreCase);

                                result.MissingUsers = remoteUsers
                                    .Where(r => !string.IsNullOrWhiteSpace(r.Sicil) && !localSicilSet.Contains(r.Sicil.Trim()))
                                    .ToList();

                                result.Success = true;
                                result.RemoteTotalCount = remoteUsers.Count;
                                result.LocalTotalCount = localSicils.Count;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                result.Success = false;
                result.ErrorMessage = "Karşı sunucuya (" + remoteUrl + ") bağlanılamadı: " + ex.Message;
            }

            return result;
        }

        /// <summary>
        /// Karşı sunucudaki eksik personelleri yerel veritabanına aktarır.
        /// </summary>
        public static int SyncMissingUsersFromRemote(List<string> specificSicils = null)
        {
            var remoteUrl = GetPairedServerUrl();
            if (string.IsNullOrWhiteSpace(remoteUrl)) return 0;

            if (specificSicils == null || !specificSicils.Any())
            {
                var comparison = CompareWithRemoteServer();
                if (!comparison.Success || !comparison.MissingUsers.Any())
                    return 0;
                specificSicils = comparison.MissingUsers.Select(u => u.Sicil).ToList();
            }

            try
            {
                var endpoint = remoteUrl + "/internal-sync/get-users-detail";
                var serializer = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };

                var postData = "syncSecret=" + HttpUtility.UrlEncode(SyncSecret);
                for (int i = 0; i < specificSicils.Count; i++)
                {
                    postData += "&sicils[" + i + "]=" + HttpUtility.UrlEncode(specificSicils[i].Trim());
                }

                var bytes = Encoding.UTF8.GetBytes(postData);

                var request = (HttpWebRequest)WebRequest.Create(endpoint);
                request.Method = "POST";
                request.ContentType = "application/x-www-form-urlencoded";
                request.Headers.Add("X-Internal-Sync-Token", SyncSecret);
                request.Timeout = 10000;
                request.ContentLength = bytes.Length;

                using (var stream = request.GetRequestStream())
                {
                    stream.Write(bytes, 0, bytes.Length);
                }

                using (var response = (HttpWebResponse)request.GetResponse())
                using (var reader = new StreamReader(response.GetResponseStream(), Encoding.UTF8))
                {
                    var json = reader.ReadToEnd();
                    var dict = serializer.Deserialize<Dictionary<string, object>>(json);

                    if (dict != null && dict.ContainsKey("success") && Convert.ToBoolean(dict["success"]))
                    {
                        var rawUsers = dict["users"] as System.Collections.ArrayList;
                        if (rawUsers != null)
                        {
                            int addedCount = 0;
                            using (var db = new GZPEGM1())
                            {
                                var existingSicils = new HashSet<string>(
                                    db.E_User.Select(u => u.fldSicil.Trim()).ToList(),
                                    StringComparer.OrdinalIgnoreCase
                                );

                                foreach (Dictionary<string, object> uDict in rawUsers)
                                {
                                    var sicil = GetDictString(uDict, "fldSicil");
                                    if (string.IsNullOrWhiteSpace(sicil) || existingSicils.Contains(sicil.Trim()))
                                        continue;

                                    var newUser = new E_User
                                    {
                                        fldSicil = sicil.Trim(),
                                        fldPassword = GetDictString(uDict, "fldPassword"),
                                        fldName = GetDictString(uDict, "fldName"),
                                        fldLastName = GetDictString(uDict, "fldLastName"),
                                        fldPhone = GetDictString(uDict, "fldPhone"),
                                        fldEmail = GetDictString(uDict, "fldEmail"),
                                        fldTitle = GetDictString(uDict, "fldTitle"),
                                        fldDeputy = GetDictString(uDict, "fldDeputy"),
                                        fldBorder = GetDictString(uDict, "fldBorder"),
                                        fldActive = GetDictString(uDict, "fldActive") ?? "1",
                                        IsActive = uDict.ContainsKey("IsActive") && uDict["IsActive"] != null ? Convert.ToBoolean(uDict["IsActive"]) : true,
                                        Role = GetDictString(uDict, "Role") ?? "Student",
                                        fldAuth = GetDictString(uDict, "fldAuth") ?? "3",
                                        fldPicture = GetDictString(uDict, "fldPicture"),
                                        fldDateTime = DateTime.Now,
                                        LastLogin = null
                                    };

                                    db.E_User.Add(newUser);
                                    existingSicils.Add(sicil.Trim());
                                    addedCount++;
                                }

                                if (addedCount > 0)
                                {
                                    db.SaveChanges();
                                }
                            }
                            return addedCount;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("[UserSync Error] Toplu senkronizasyon hatası: " + ex);
            }

            return 0;
        }

        private static string GetDictString(Dictionary<string, object> dict, string key)
        {
            if (dict != null && dict.ContainsKey(key) && dict[key] != null)
                return dict[key].ToString().Trim();
            return null;
        }

        /// <summary>
        /// Sunucu üzerindeki tüm etkin yerel IPv4 adreslerini döndürür.
        /// </summary>
        public static string[] GetLocalIPv4Addresses()
        {
            try
            {
                return NetworkInterface.GetAllNetworkInterfaces()
                    .Where(ni => ni.OperationalStatus == OperationalStatus.Up &&
                                 ni.NetworkInterfaceType != NetworkInterfaceType.Loopback)
                    .SelectMany(ni => ni.GetIPProperties().UnicastAddresses)
                    .Where(ua => ua.Address.AddressFamily == AddressFamily.InterNetwork)
                    .Select(ua => ua.Address.ToString())
                    .ToArray();
            }
            catch
            {
                return new string[0];
            }
        }
    }

    public class RemoteUserComparisonResult
    {
        public bool Success { get; set; }
        public string RemoteServerUrl { get; set; }
        public string ErrorMessage { get; set; }
        public int LocalTotalCount { get; set; }
        public int RemoteTotalCount { get; set; }
        public List<RemoteUserSummaryItem> MissingUsers { get; set; } = new List<RemoteUserSummaryItem>();
    }

    public class RemoteUserSummaryItem
    {
        public string Sicil { get; set; }
        public string FullName { get; set; }
        public string Title { get; set; }
        public string Border { get; set; }
        public string Role { get; set; }
        public string Auth { get; set; }
        public bool IsActive { get; set; }
    }
}
