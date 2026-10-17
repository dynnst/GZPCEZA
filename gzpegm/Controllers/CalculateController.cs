using gzpegm.Cont;
using gzpegm.Models;
using System;
using System.Data.Entity;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize(Users = "2,3")] // Admin = 2, Ceza Islemleri = 3
    public class CalculateController : Controller
    {
        [Route("Hesaplama")]
        public ActionResult Index()
        {
            var currentUser = GetUser();
            if (currentUser != null)
            {
                string fullName = ((currentUser.fldName ?? "").Trim() + " " + (currentUser.fldLastName ?? "").Trim()).Trim();
                string sicil = (currentUser.fldSicil ?? "").Trim();
                ViewBag.OfficerName = !string.IsNullOrEmpty(sicil) ? fullName + " (" + sicil + ")" : fullName;
                ViewBag.OfficerBorder = currentUser.fldBorder;
            }
            return View();
        }

        [NonAction]
        public E_User GetUser()
        {
            HttpCookie userCookie = Request.Cookies["Token"];
            Token token = new Token();
            gzpegm.Cont.User user = new User();
            int userId = 0;

            if (userCookie != null)
            {
                var tokenData = token.GetToken(userCookie.Value.ToString());
                if (tokenData?.fldUserId != null)
                    int.TryParse(tokenData.fldUserId.ToString(), out userId);
            }

            return user.GetUserById(userId);
        }

        [HttpGet]
        public JsonResult GetHistoryCount()
        {
            try
            {
                var currentUser = GetUser();
                if (currentUser == null)
                    return Json(new { count = 0 }, JsonRequestBehavior.AllowGet);

                using (var db = new GZPEGM1())
                {
                    string fullName = ((currentUser.fldName ?? "").Trim() + " " + (currentUser.fldLastName ?? "").Trim()).Trim();
                    string sicil = (currentUser.fldSicil ?? "").Trim();

                    var query = db.E_History
                        .AsNoTracking()
                        .Where(h => h.fldUser != null);

                    if (!string.IsNullOrEmpty(currentUser.fldBorder))
                        query = query.Where(h => h.fldBorder == currentUser.fldBorder);

                    if (!string.IsNullOrEmpty(sicil))
                    {
                        string sicilPrefix = sicil + "|";
                        string userKey = !string.IsNullOrEmpty(fullName) ? sicil + "|" + fullName : null;

                        query = query.Where(h =>
                            h.fldUser == sicil ||
                            h.fldUser == fullName ||
                            h.fldUser == userKey ||
                            h.fldUser.StartsWith(sicilPrefix));
                    }
                    else
                    {
                        query = query.Where(h => h.fldUser == fullName);
                    }

                    var count = query.Count();

                    return Json(new { count }, JsonRequestBehavior.AllowGet);
                }
            }
            catch (Exception)
            {
                return Json(new { count = 0 }, JsonRequestBehavior.AllowGet);
            }
        }
    }
}
