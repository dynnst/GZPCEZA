using gzpegm.Cont;
using gzpegm.Models;
using System;
using System.Linq;
using System.Collections.Generic;
using System.Globalization;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize]
    public class HomeController : Controller
    {
        private bool IsLocalNetwork()
        {
            return !System.Net.NetworkInformation.NetworkInterface.GetIsNetworkAvailable();
        }


        [HttpGet]
        public ActionResult Yardimci()
        {
           

                return View();
           
           
        }


        [NonAction]
        public E_User getuserby()
        {
            try
            {
                HttpCookie UserCookie = Request.Cookies["Token"];
                if (UserCookie == null)
                {
                    if (IsLocalNetwork())
                    {
                        return new E_User
                        {
                            fldId = 1,
                            fldName = "Offline",
                            fldLastName = "User",
                            fldAuth = "0,2,5,6,3"
                        };
                    }
                    return null;
                }

                Token token = new Token();
                var tokendata = token.GetToken(UserCookie.Value);
                if (tokendata == null) return null;

                int UserId = 0;
                int.TryParse(tokendata.fldUserId?.ToString(), out UserId);

                User user = new User();
                return user.GetUserById(UserId);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Kullanıcı getirme hatası: {ex.Message}");
                return null;
            }
        }

        private bool UserHasAuth(E_User user, string requiredAuth)
        {
            if (user == null) return false;
            var auth = user.fldAuth ?? string.Empty;
            if (string.IsNullOrWhiteSpace(auth)) return false;

            var parts = auth.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            return parts.Any(p => p.Trim() == requiredAuth);
        }

        [HttpGet]
        public ActionResult Index()
        {
            try
            {
                // Kullanıcı bilgisini al
                var user = getuserby();
                ViewBag.User = user;

                ViewBag.UvrCountries = gzpegm.Services.CacheService.GetOrCreate("Home_UvrCountryNames_v1", () =>
                {
                    var contuvr = new Contuvr();
                    return contuvr.GetAllCountryNames();
                }, 30);

                // Sohbet sistemi iptal edildi

                LoadNewCourseNotification();

                // Cache ayarlarını yap
                SetCachePolicy();

                return View();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Index hatası: {ex.Message}");
                return View();
            }
        }

        private void LoadNewCourseNotification()
        {
            try
            {
                var loaded = false;

                if (TempData["NewCoursesJson"] != null)
                {
                    var json = TempData["NewCoursesJson"] as string;
                    if (!string.IsNullOrWhiteSpace(json))
                    {
                        var briefs = Newtonsoft.Json.JsonConvert.DeserializeObject<List<CourseBrief>>(json);
                        if (briefs != null && briefs.Count > 0)
                        {
                            ViewBag.NewCourseCount = briefs.Count;
                            ViewBag.NewCourseTitles = briefs;
                            loaded = true;
                        }
                    }
                }

                if (loaded) return;

                var newCourseIdsQs = Request.QueryString["newCourseIds"];
                if (string.IsNullOrWhiteSpace(newCourseIdsQs)) return;

                var ids = newCourseIdsQs
                    .Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                    .Select(s => int.TryParse(s, out var v) ? v : 0)
                    .Where(v => v > 0)
                    .Distinct()
                    .Take(5)
                    .ToList();

                if (!ids.Any()) return;

                using (var db = new GZPEGM1())
                {
                    var briefs = db.Courses
                        .Where(c => ids.Contains(c.CourseId) && c.IsActive == true && (c.IsDeleted == null || c.IsDeleted == false))
                        .OrderByDescending(c => c.CreatedDate)
                        .Select(c => new CourseBrief
                        {
                            CourseId = c.CourseId,
                            CourseTitle = c.CourseTitle,
                            CoverImage = c.CoverImage,
                            CreatedDate = c.CreatedDate
                        })
                        .ToList();

                    if (briefs.Count > 0)
                    {
                        ViewBag.NewCourseCount = briefs.Count;
                        ViewBag.NewCourseTitles = briefs;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Yeni kurs bildirimi hazırlanamadı: {ex.Message}");
            }
        }


        private static bool IsHistoryOwner(string historyUser, string sicil, string fullName)
        {
            if (string.IsNullOrWhiteSpace(historyUser)) return false;
            var value = historyUser.Trim();

            if (!string.IsNullOrWhiteSpace(sicil))
            {
                if (string.Equals(value, sicil, StringComparison.OrdinalIgnoreCase)) return true;
                if (value.StartsWith(sicil + "|", StringComparison.OrdinalIgnoreCase)) return true;
            }

            return !string.IsNullOrWhiteSpace(fullName) &&
                   string.Equals(value, fullName, StringComparison.OrdinalIgnoreCase);
        }

        private static decimal ParsePenalty(string money)
        {
            var cleaned = Regex.Replace(money ?? string.Empty, "[^0-9,.-]", "").Replace(',', '.');
            decimal value;
            return decimal.TryParse(cleaned, NumberStyles.Any, CultureInfo.InvariantCulture, out value) ? value : 0m;
        }

        /// <summary>
        /// Cache politikasını ayarlar.
        /// </summary>
        private void SetCachePolicy()
        {
            if (IsLocalNetwork())
            {
                Response.Cache.SetCacheability(HttpCacheability.Private);
                Response.Cache.SetMaxAge(TimeSpan.FromMinutes(5));
            }
        }

        /// <summary>
        /// V-84 yaş kontrolü için sunucu tarafı doğrulaması.
        /// Bu action client tarafındaki V-84 modal tarafından çağrılıyor.
        /// </summary>
        [HttpPost]
        [Route("ValidateV84Age")]
        [ValidateAntiForgeryToken]
        public JsonResult ValidateV84Age(string birthDate)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(birthDate))
                {
                    return Json(new { success = false, message = "Doğum tarihi boş." }, JsonRequestBehavior.AllowGet);
                }

                DateTime dob;
                if (!DateTime.TryParse(birthDate, out dob))
                {
                    if (!DateTime.TryParseExact(birthDate, new[] { "yyyy-MM-dd", "MM/dd/yyyy", "dd.MM.yyyy" },
                        System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out dob))
                    {
                        return Json(new { success = false, message = "Geçersiz tarih formatı." }, JsonRequestBehavior.AllowGet);
                    }
                }

                var today = DateTime.Today;
                int age = today.Year - dob.Year;
                if (dob > today.AddYears(-age)) age--;

                bool canGive = age < 10;
                string message = canGive ? "10 yaşını doldurmamış: V-84 Verilebilir" : "10 yaşını doldurduğu için V-84 Verilemez";

                return Json(new { success = true, canGive = canGive, age = age, message = message }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("ValidateV84Age ERROR: " + ex.Message);
                return Json(new { success = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }
    }
}
