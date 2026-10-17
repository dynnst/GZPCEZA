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
            var model = new OldOperationsIndexViewModel
            {
                CanSeeAdminOperations = canSeeAdminOld,
                GeneralOperations = new List<OldOperationLinkViewModel>
                {
                    new OldOperationLinkViewModel { Title = "Eski Formlar", Description = "Genel eski form kayıtları", Url = Url.Content("~/OSISK"), Icon = "fas fa-folder-open", Group = "Genel" },
                    new OldOperationLinkViewModel { Title = "Eski Hesaplamalar", Description = "Genel eski hesaplama kayıtları", Url = Url.Content("~/OSHIST"), Icon = "fas fa-calculator", Group = "Genel" },
                    new OldOperationLinkViewModel { Title = "Eski Şartlı Vize", Description = "Genel eski şartlı vize kayıtları", Url = Url.Content("~/OSVIZE"), Icon = "fas fa-stamp", Group = "Genel" }
                },
                AdminOperations = canSeeAdminOld
                    ? new List<OldOperationLinkViewModel>
                    {
                        new OldOperationLinkViewModel { Title = "Eski Formlar (Admin)", Description = "Admin eski form kayıtları", Url = Url.Content("~/ISK"), Icon = "fas fa-user-shield", Group = "Admin" },
                        new OldOperationLinkViewModel { Title = "Eski Hesaplamalar (Admin)", Description = "Admin eski hesaplama kayıtları", Url = Url.Content("~/HIST"), Icon = "fas fa-chart-line", Group = "Admin" },
                        new OldOperationLinkViewModel { Title = "Eski Şartlı Vize (Admin)", Description = "Admin eski şartlı vize kayıtları", Url = Url.Content("~/SVIZE"), Icon = "fas fa-stamp", Group = "Admin" }
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
