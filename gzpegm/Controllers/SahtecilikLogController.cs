using gzpegm.Cont;
using gzpegm.Models;
using gzpegm.Services;
using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    public class SahtecilikLogController : Controller
    {
        private readonly SahtecilikLogService _logService;

        public SahtecilikLogController()
        {
            _logService = new SahtecilikLogService();
        }

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

        private bool IsAdmin(E_User user)
        {
            if (user == null) return false;
            var auths = (user.fldAuth ?? "").Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries).Select(x => x.Trim()).ToList();
            return auths.Contains("2") || string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase);
        }

        private string GetClientIp()
        {
            string ip = Request.ServerVariables["HTTP_X_FORWARDED_FOR"];
            if (!string.IsNullOrEmpty(ip))
            {
                string[] parts = ip.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                if (parts.Length > 0) return parts[0].Trim();
            }
            return Request.UserHostAddress ?? Request.ServerVariables["REMOTE_ADDR"] ?? "Bilinmiyor";
        }

        // =========================================================================
        // 1. GEÇİŞ LOGLAMA API (Hesaplama, UserBox veya Yardımcı üzerinden AJAX çağrısı)
        // =========================================================================
        [HttpPost]
        public ActionResult LogGecis(string kaynak, string ulke, string hedefUrl, string detay)
        {
            try
            {
                var user = GetCurrentUser();
                int? userId = user?.fldId;
                string sicil = user?.fldSicil ?? "Misafir";
                string fullName = user != null ? $"{user.fldName} {user.fldLastName}".Trim() : "Giriş Yapılmamış";
                string border = user?.fldBorder ?? "";
                string ip = GetClientIp();

                bool ok = _logService.LogGecis(userId, sicil, fullName, border, kaynak, ulke, ip, hedefUrl, detay);
                return Json(new { success = ok });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, error = ex.Message });
            }
        }

        // =========================================================================
        // 2. YÖNETİCİ DENETİM SAYFASI (YALNIZCA ADMİN GÖREBİLİR!)
        // =========================================================================
        [HttpGet]
        [Route("Sahtecilik-Denetim-Loglari")]
        public ActionResult Index(string search = null, string kaynak = null, string ulke = null, DateTime? startDate = null, DateTime? endDate = null, int page = 1, int pageSize = 25)
        {
            var currentUser = GetCurrentUser();
            if (currentUser == null)
            {
                return RedirectToAction("Index", "Giris");
            }

            if (!IsAdmin(currentUser))
            {
                TempData["msgError"] = "Yetkisiz Erişim: Sahtecilik Denetim ve Güvenlik Logları ekranı yalnızca Sistem Yöneticilerine (Admin) açıktır.";
                return RedirectToAction("Index", "Home");
            }

            ViewBag.CurrentUser = currentUser;
            ViewBag.IsAdmin = true;

            var model = _logService.GetLogs(search, kaynak, ulke, startDate, endDate, page, pageSize);
            return View(model);
        }

        // =========================================================================
        // 3. EXCEL / CSV DIŞA AKTARIM (YALNIZCA ADMİN GÖREBİLİR!)
        // =========================================================================
        [HttpGet]
        [Route("Sahtecilik-Denetim-Loglari/Export")]
        public ActionResult Export(string search = null, string kaynak = null, string ulke = null, DateTime? startDate = null, DateTime? endDate = null)
        {
            var currentUser = GetCurrentUser();
            if (currentUser == null || !IsAdmin(currentUser))
            {
                return new HttpStatusCodeResult(403, "Bu işlem için yetkiniz bulunmamaktadır.");
            }

            // Tüm filtrelenmiş verileri getir (sayfalama olmadan - 5000 max)
            var model = _logService.GetLogs(search, kaynak, ulke, startDate, endDate, 1, 5000);

            var sb = new StringBuilder();
            // UTF-8 BOM ekle ki Excel Türkçe karakterleri doğru göstersin
            sb.Append('\uFEFF');
            sb.AppendLine("ID;Tarih;Saat;Sicil No;Personel Adı Soyadı;Görev Yeri / Kapı;Kaynak Sayfa;İşlem Türü;Seçilen Ülke;İncelenen Belge;IP Adresi;Detay");

            foreach (var item in model.Logs)
            {
                string line = string.Format("{0};{1};{2};{3};{4};{5};{6};{7};{8};{9};{10};{11}",
                    item.Id,
                    item.IslemTarihi.ToString("dd.MM.yyyy"),
                    item.IslemTarihi.ToString("HH:mm:ss"),
                    EscapeCsv(item.UserSicil),
                    EscapeCsv(item.UserName),
                    EscapeCsv(item.UserBorder),
                    EscapeCsv(item.KaynakSayfa),
                    EscapeCsv(item.IslemTipi),
                    EscapeCsv(item.SecilenUlke),
                    EscapeCsv(item.IncelenenBelgeBaslik),
                    EscapeCsv(item.IpAddress),
                    EscapeCsv(item.Detay)
                );
                sb.AppendLine(line);
            }

            byte[] buffer = Encoding.UTF8.GetBytes(sb.ToString());
            string fileName = $"Sahtecilik_Denetim_Loglari_{DateTime.Now:yyyyMMdd_HHmm}.csv";
            return File(buffer, "text/csv", fileName);
        }

        private string EscapeCsv(string val)
        {
            if (string.IsNullOrEmpty(val)) return "";
            return val.Replace(";", " ").Replace("\r", " ").Replace("\n", " ").Trim();
        }
    }
}
