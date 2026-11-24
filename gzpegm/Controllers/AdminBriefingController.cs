using gzpegm.Cont;
using gzpegm.Models;
using gzpegm.Services;
using System;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    public class AdminBriefingController : Controller
    {
        private readonly AdminBriefingService _briefingService;

        public AdminBriefingController()
        {
            _briefingService = new AdminBriefingService();
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

        // =========================================================================
        // 1. ADMIN OPERASYONEL BRİFİNG DASHBOARD
        // =========================================================================
        [HttpGet]
        [Route("Admin/Brifing")]
        [Route("AdminBriefing")]
        [Route("AdminBriefing/Index")]
        public ActionResult Index(string period = "24saat", DateTime? startDate = null, DateTime? endDate = null)
        {
            var user = GetCurrentUser();
            if (user == null)
            {
                TempData["msgError"] = "Lütfen önce sisteme giriş yapınız.";
                return RedirectToAction("Index", "Giris");
            }

            if (!IsAdmin(user))
            {
                TempData["msgError"] = "Bu alana sadece sistem yöneticileri (Admin) erişebilir.";
                return RedirectToAction("Index", "UserBox");
            }

            ViewBag.CurrentUser = user;
            ViewBag.AdminName = $"{user.fldName} {user.fldLastName}".Trim();
            ViewBag.AdminSicil = user.fldSicil ?? "";

            var model = _briefingService.GetBriefingData(period, startDate, endDate, user.fldSicil, $"{user.fldName} {user.fldLastName}".Trim());
            return View(model);
        }

        // =========================================================================
        // 2. RESMİ PDF BRİFİNG RAPORU İNDİRME
        // =========================================================================
        [HttpGet]
        [Route("Admin/Brifing/Pdf")]
        [Route("AdminBriefing/ExportPdf")]
        public ActionResult ExportPdf(string period = "24saat", DateTime? startDate = null, DateTime? endDate = null)
        {
            var user = GetCurrentUser();
            if (user == null)
            {
                return new HttpStatusCodeResult(401, "Giriş yapılmadı.");
            }

            if (!IsAdmin(user))
            {
                return new HttpStatusCodeResult(403, "Yetkisiz erişim. Sadece yönetici yetkisi olanlar PDF indirebilir.");
            }

            var adminName = $"{user.fldName} {user.fldLastName}".Trim();
            var adminSicil = user.fldSicil ?? "";
            var model = _briefingService.GetBriefingData(period, startDate, endDate, adminSicil, adminName);

            var pdfBytes = _briefingService.GenerateBriefingPdf(model, adminSicil, adminName);
            string safePeriod = (period ?? "24saat").Replace(" ", "_");
            string fileName = $"EGM_Operasyonel_Brifing_{safePeriod}_{DateTime.Now:yyyyMMdd_HHmm}.pdf";

            return File(pdfBytes, "application/pdf", fileName);
        }
    }
}
