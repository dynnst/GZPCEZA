using gzpegm.Cont;
using gzpegm.Models;
using gzpegm.Models.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize]
    public class EskiIslemlerController : Controller
    {
        public ActionResult Index()
        {
            var user = GetCurrentUser();
            if (user == null) return RedirectToAction("Index", "Giris");

            var authValues = (user.fldAuth ?? string.Empty)
                .Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                .Select(x => x.Trim())
                .Where(x => !string.IsNullOrWhiteSpace(x))
                .ToList();

            if (string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase) && !authValues.Contains("2"))
                authValues.Add("2");

            var canSeeAdminOld = authValues.Contains("2") || authValues.Contains("4");
            var canCore = authValues.Contains("2") || authValues.Contains("3");

            var generalOps = new List<OldOperationLinkViewModel>
            {
                new OldOperationLinkViewModel { Title = "Ceza ve Tutanak Formları (OSISK)", Description = "Hudut kapısı ceza ve tebliğ-tebellüğ tutanakları arşivi", Url = Url.Content("~/OSISK"), Icon = "fas fa-file-invoice-dollar", Group = "Tutanaklar" },
                new OldOperationLinkViewModel { Title = "Hesaplama Geçmişi (OSHIST)", Description = "Yapılan ihlal ve harç hesaplama kayıtları", Url = Url.Content("~/OSHIST"), Icon = "fas fa-calculator", Group = "Hesaplamalar" },
                new OldOperationLinkViewModel { Title = "V-84 Şartlı Vize Kayıtları (OSVIZE)", Description = "Düzenlenen şartlı giriş vizeleri geçmişi", Url = Url.Content("~/OSVIZE"), Icon = "fas fa-stamp", Group = "Şartlı Vize" }
            };

            if (canCore)
            {
                generalOps.Add(new OldOperationLinkViewModel { Title = "İnad Yolcu Kayıtları (INAD)", Description = "Kabul Edilemez Yolcu (INAD) kayıt ve işlem geçmişi", Url = Url.Action("Index", "EInad"), Icon = "fas fa-clipboard-check", Group = "İnad" });
                generalOps.Add(new OldOperationLinkViewModel { Title = "Tahdit Sorgu & İşlem Logları", Description = "Tahdit kodları sorgu ve işlem log arşivi", Url = Url.Action("Index", "Tahdit"), Icon = "fas fa-ban", Group = "Tahdit" });
            }

            var model = new OldOperationsIndexViewModel
            {
                CanSeeAdminOperations = canSeeAdminOld,
                GeneralOperations = generalOps,
                AdminOperations = canSeeAdminOld
                    ? new List<OldOperationLinkViewModel>
                    {
                        new OldOperationLinkViewModel { Title = "Tüm Kapılar Ceza & Form Arşivi (ISK)", Description = "Sistem geneli tüm kapıların ceza tutanakları ve detaylı filtreleme", Url = Url.Content("~/ISK"), Icon = "fas fa-user-shield", Group = "Admin" },
                        new OldOperationLinkViewModel { Title = "Tüm Kapılar Hesaplama Arşivi (HIST)", Description = "Sistem geneli tüm hesaplamalar ve 24 saatlik akış", Url = Url.Content("~/HIST"), Icon = "fas fa-chart-line", Group = "Admin" },
                        new OldOperationLinkViewModel { Title = "Tüm Kapılar Şartlı Vize Arşivi (SVIZE)", Description = "Sistem geneli V-84 şartlı vize arşivi ve onay kayıtları", Url = Url.Content("~/SVIZE"), Icon = "fas fa-stamp", Group = "Admin" }
                    }
                    : new List<OldOperationLinkViewModel>()
            };

            return View(model);
        }

        private E_User GetCurrentUser()
        {
            var cookie = Request.Cookies["Token"];
            if (cookie == null) return null;
            var tokenData = new Token().GetToken(cookie.Value);
            int userId;
            if (tokenData?.fldUserId == null || !int.TryParse(tokenData.fldUserId.ToString(), out userId)) return null;
            return new User().GetUserById(userId);
        }
    }
}
