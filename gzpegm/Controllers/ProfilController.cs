using CryptoHelper;
using gzpegm.Cont;
using gzpegm.Helpers;
using gzpegm.Models;
using System;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Collections.Generic;
using gzpegm.Models.ViewModels;

namespace gzpegm.Controllers
{
    [UserAuthorize]
    public class ProfileController : Controller
    {
        private readonly GZPEGM1 db = new GZPEGM1();

        private int? GetCurrentUserId()
        {
            HttpCookie cookie = Request.Cookies["Token"];
            if (cookie == null) return null;

            Token token = new Token();
            var tokenData = token.GetToken(cookie.Value);
            if (tokenData == null) return null;

            return tokenData.fldUserId;
        }

        [HttpGet]
        [Route("Profil")]
        public ActionResult Index()
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return RedirectToAction("Index", "Giris");

            var user = db.E_User.FirstOrDefault(x => x.fldId == userId);
            if (user == null)
                return RedirectToAction("Index", "Giris");

            try
            {
                // prepare statistics for profile view
                string fullname = (user.fldName ?? "").Trim() + " " + (user.fldLastName ?? "").Trim();
                string sicil = (user.fldSicil ?? "").Trim();

                // load all history rows that have a fldUser (we will match user ownership in-memory)
                var allWithUser = db.E_History
                    .Where(h => h.fldUser != null)
                    .ToList();

                // match records that belong to this user (by sicil or fullname or plain sicil)
                var matched = allWithUser.Where(h =>
                {
                    var fu = (h.fldUser ?? "").Trim();
                    if (string.IsNullOrEmpty(fu)) return false;
                    var ns = fu.ToLowerInvariant();
                    if (!string.IsNullOrEmpty(sicil))
                    {
                        var nsicil = sicil.ToLowerInvariant();
                        if (ns.StartsWith(nsicil + "|")) return true;
                        if (ns == nsicil) return true; // plain sicil stored
                        // also accept pipe-split first token equals sicil
                        var idx = ns.IndexOf('|');
                        if (idx > 0)
                        {
                            var first = ns.Substring(0, idx).Trim();
                            if (first == nsicil) return true;
                        }
                    }
                    if (!string.IsNullOrEmpty(fullname) && ns == fullname.ToLowerInvariant()) return true;
                    return false;
                }).ToList();

                // group matched histories by border so we can show per-border counts
                var groupedByBorder = matched
                    .GroupBy(h => (h.fldBorder ?? "-"))
                    .Select(g => new { Border = g.Key, Count = g.Count(), Items = g.ToList() })
                    .OrderByDescending(x => x.Count)
                    .ToList();

                // current border-specific histories (used for main stats)
                var currentHistories = groupedByBorder.Where(g => string.Equals(g.Border, user.fldBorder, StringComparison.OrdinalIgnoreCase))
                    .SelectMany(g => g.Items).ToList();

                // if user has no entries in current border, currentHistories will be empty
                ViewBag.TotalHistory = currentHistories.Count;

                // most active day (based on currentHistories)
                var mostActive = currentHistories
                    .Where(h => h.fldDatetime.HasValue)
                    .GroupBy(h => h.fldDatetime.Value.Date)
                    .Select(g => new { Date = g.Key, Count = g.Count() })
                    .OrderByDescending(x => x.Count)
                    .FirstOrDefault();
                ViewBag.MostActiveDay = mostActive != null ? mostActive.Date.ToString("dd.MM.yyyy") : null;
                ViewBag.MostActiveDayCount = mostActive != null ? mostActive.Count : 0;

                // total penalty amount (try parse fldPMoney)
                decimal totalPenalty = 0;
                foreach (var h in currentHistories)
                {
                    var s = (h.fldPMoney ?? "").Trim();
                    if (string.IsNullOrEmpty(s)) continue;
                    // try to extract numeric from string
                    var cleaned = System.Text.RegularExpressions.Regex.Replace(s, "[^0-9,.-]", "");
                    cleaned = cleaned.Replace(',', '.');
                    if (decimal.TryParse(cleaned, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out var val))
                        totalPenalty += val;
                }
                ViewBag.TotalPenalty = totalPenalty;

                // rank among personnel by total penalty within same border (use allWithUser filtered to same border)
                var perSicilSums = allWithUser
                    .Where(h => string.Equals(h.fldBorder, user.fldBorder, StringComparison.OrdinalIgnoreCase) && h.fldUser != null)
                    .ToList()
                    .Select(h => new { h.fldUser, h.fldPMoney })
                    .Select(item => new { Sicil = (item.fldUser ?? "").Split('|').FirstOrDefault()?.Trim(), Money = item.fldPMoney })
                    .Where(x => !string.IsNullOrEmpty(x.Sicil))
                    .GroupBy(x => x.Sicil)
                    .Select(g => new
                    {
                        Sicil = g.Key,
                        Sum = g.Sum(z =>
                        {
                            var cleaned = System.Text.RegularExpressions.Regex.Replace((z.Money ?? ""), "[^0-9,.-]", "").Replace(',', '.');
                            if (decimal.TryParse(cleaned, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out var v)) return v;
                            return 0;
                        })
                    })
                    .OrderByDescending(x => x.Sum)
                    .ToList();

                int rank = -1;
                for (int i = 0; i < perSicilSums.Count; i++)
                {
                    if (string.Equals(perSicilSums[i].Sicil, sicil, StringComparison.OrdinalIgnoreCase)) { rank = i + 1; break; }
                }
                ViewBag.PenaltyRank = rank > 0 ? rank : (int?)null;

                // top country where user applied penalties (based on currentHistories)
                var topCountry = currentHistories
                    .GroupBy(h => (h.fldCountry ?? "-"))
                    .Select(g => new { Country = g.Key, Count = g.Count(), Sum = g.Sum(h =>
                    {
                        var cleaned = System.Text.RegularExpressions.Regex.Replace((h.fldPMoney ?? ""), "[^0-9,.-]", "").Replace(',', '.');
                        if (decimal.TryParse(cleaned, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out var v)) return v;
                        return 0;
                    }) })
                    .OrderByDescending(x => x.Count)
                    .FirstOrDefault();
                if (topCountry != null)
                {
                    ViewBag.TopCountry = topCountry.Country;
                    ViewBag.TopCountryCount = topCountry.Count;
                }

                // E_Inad stats (use Sicil field)
                var inadQuery = db.E_Inad.AsQueryable();
                if (!string.IsNullOrEmpty(sicil)) inadQuery = inadQuery.Where(i => i.Sicil == sicil);
                var inadTop = inadQuery
                    .GroupBy(i => new { Country = i.GeldigiYer, Reason = i.InadSebep })
                    .Select(g => new { g.Key.Country, g.Key.Reason, Count = g.Count() })
                    .OrderByDescending(x => x.Count)
                    .FirstOrDefault();
                if (inadTop != null)
                {
                    ViewBag.InadTopCountry = inadTop.Country;
                    ViewBag.InadTopReason = inadTop.Reason;
                    ViewBag.InadTopCount = inadTop.Count;
                }

                // Provide per-border stats for this user so view can show previous borders
                var borderStats = new List<ProfileBorderStat>();
                foreach (var g in groupedByBorder)
                {
                    // sum of fldPMoney for this border
                    decimal sum = 0;
                    foreach (var h in g.Items)
                    {
                        var cleaned = System.Text.RegularExpressions.Regex.Replace((h.fldPMoney ?? ""), "[^0-9,.-]", "").Replace(',', '.');
                        if (decimal.TryParse(cleaned, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out var v)) sum += v;
                    }

                    // most active day for this border
                    var most = g.Items.Where(h => h.fldDatetime.HasValue)
                        .GroupBy(h => h.fldDatetime.Value.Date)
                        .Select(x => new { Date = x.Key, Count = x.Count() })
                        .OrderByDescending(x => x.Count).FirstOrDefault();
                    string mostDay = most != null ? most.Date.ToString("dd.MM.yyyy") : null;

                    // samples: first 10 records formatted
                    var samples = g.Items.OrderByDescending(h => h.fldDatetime).Take(10)
                        .Select(h => new ProfileSample {
                            Id = h.fldId,
                            Date = h.fldDatetime,
                            Country = h.fldCountry,
                            Penalty = h.fldPMoney,
                            User = h.fldUser
                        }).ToList();

                    borderStats.Add(new ProfileBorderStat { Border = g.Border, Count = g.Count, Sum = sum, MostActiveDay = mostDay, Samples = samples });
                }

                ViewBag.BorderHistory = borderStats;

                // courses/enrollments and exam results
                var enrolledCount = db.CourseEnrollments.Count(e => e.UserId == user.fldId);
                var examCount = db.ExamResult.Count(er => er.UserId == user.fldId);
                ViewBag.EnrolledCoursesCount = enrolledCount;
                ViewBag.ExamResultsCount = examCount;

                // load borders for dropdown
                ViewBag.Borders = db.E_Border.OrderBy(b => b.fldName).ToList();

                // last message
                var lastMessage = db.E_Messages.Where(m => m.fldRecipientId == user.fldId && m.fldIsDeletedByRecipient == false)
                    .OrderByDescending(m => m.fldDateTime).FirstOrDefault();
                if (lastMessage != null)
                {
                    ViewBag.LastMessageSubject = lastMessage.fldSubject;
                    ViewBag.LastMessageText = lastMessage.fldMessage;
                    ViewBag.LastMessageDate = lastMessage.fldDateTime;
                }

                // small chart: last 12 months history counts for this user
                var monthCounts = new List<int>();
                for (int m = 11; m >= 0; m--)
                {
                    var from = DateTime.Now.AddMonths(-m);
                    var start = new DateTime(from.Year, from.Month, 1);
                    var end = start.AddMonths(1);
                    var cnt = currentHistories.Count(h => h.fldDatetime.HasValue && h.fldDatetime.Value >= start && h.fldDatetime.Value < end);
                    monthCounts.Add(cnt);
                }
                ViewBag.HistoryChart = monthCounts;
                ViewBag.TahditStats = new TahditFormLogService().GetStatistics(null, null, null, user.fldId, user.fldSicil);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Profile stats error: " + ex.Message);
            }

            return View("~/Views/Profil/Index.cshtml", user);
        }

        // ✅ TEK KAYDET BUTONU
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult SaveProfile(
            HttpPostedFileBase PictureFile,
            string currentpass,
            string newpass,
            string confirmpass,
            string fldName,
            string fldLastName,
            string fldPhone,
            string fldEmail,
            string fldTitle,
            string fldDeputy)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return RedirectToAction("Index", "Giris");

            var user = db.E_User.FirstOrDefault(x => x.fldId == userId);
            if (user == null)
                return RedirectToAction("Index", "Giris");

            // ================= KİMLİK BİLGİLERİ =================
            if (!string.IsNullOrWhiteSpace(fldName))
                user.fldName = fldName.Trim();

            if (!string.IsNullOrWhiteSpace(fldLastName))
                user.fldLastName = fldLastName.Trim();

            if (!string.IsNullOrWhiteSpace(fldPhone))
                user.fldPhone = fldPhone.Trim();

            if (!string.IsNullOrWhiteSpace(fldEmail))
                user.fldEmail = fldEmail.Trim();

            if (!string.IsNullOrWhiteSpace(fldTitle))
                user.fldTitle = fldTitle.Trim();

            if (!string.IsNullOrWhiteSpace(fldDeputy))
                user.fldDeputy = fldDeputy.Trim();

            // fldBorder may come from dropdown - allow empty/null
            var fldBorder = Request.Form["fldBorder"];
            if (!string.IsNullOrWhiteSpace(fldBorder)) user.fldBorder = fldBorder.Trim();

            // ================= FOTO =================
            if (PictureFile != null && PictureFile.ContentLength > 0)
            {
                string[] allowedExt = { ".jpg", ".jpeg", ".png", ".gif" };
                string ext = Path.GetExtension(PictureFile.FileName)?.ToLower();

                if (!allowedExt.Contains(ext))
                {
                    TempData["msgError"] = "Geçersiz resim formatı.";
                    return RedirectToAction("Index");
                }

                if (PictureFile.ContentLength > 2 * 1024 * 1024)
                {
                    TempData["msgError"] = "Resim 2MB'den büyük olamaz.";
                    return RedirectToAction("Index");
                }

                string folder = FileStorageHelper.MapPath(Server, "~/files/User/");
                if (!folder.EndsWith(Path.DirectorySeparatorChar.ToString()))
                    folder += Path.DirectorySeparatorChar;
                Directory.CreateDirectory(folder);

                if (!string.IsNullOrEmpty(user.fldPicture))
                {
                    string old = Path.Combine(folder, user.fldPicture);
                    if (System.IO.File.Exists(old))
                        System.IO.File.Delete(old);
                }

                string fileName = Guid.NewGuid().ToString("N") + ext;
                PictureFile.SaveAs(Path.Combine(folder, fileName));
                user.fldPicture = fileName;
            }

            // ================= ŞİFRE =================
            bool wantsPasswordChange =
                !string.IsNullOrWhiteSpace(currentpass) ||
                !string.IsNullOrWhiteSpace(newpass) ||
                !string.IsNullOrWhiteSpace(confirmpass);

            if (wantsPasswordChange)
            {
                if (string.IsNullOrWhiteSpace(currentpass) ||
                    string.IsNullOrWhiteSpace(newpass) ||
                    string.IsNullOrWhiteSpace(confirmpass))
                {
                    TempData["msgError"] = "Tüm şifre alanları doldurulmalıdır.";
                    return RedirectToAction("Index");
                }

                if (!Crypto.VerifyHashedPassword(user.fldPassword, currentpass))
                {
                    TempData["msgError"] = "Mevcut şifre yanlış.";
                    return RedirectToAction("Index");
                }

                if (newpass != confirmpass)
                {
                    TempData["msgError"] = "Yeni şifreler uyuşmuyor.";
                    return RedirectToAction("Index");
                }

                user.fldPassword = Crypto.HashPassword(newpass);
            }

            db.SaveChanges();
            TempData["msgSuccess"] = "Profil başarıyla güncellendi.";
            return RedirectToAction("Index");
        }

        // Return paged details for a given border for the current user
        [HttpGet]
        public JsonResult GetBorderDetails(string border, int page = 1, int pageSize = 10)
        {
            var userId = GetCurrentUserId();
            if (userId == null) return Json(new { success = false, message = "Not logged in" }, JsonRequestBehavior.AllowGet);

            var user = db.E_User.FirstOrDefault(x => x.fldId == userId);
            if (user == null) return Json(new { success = false, message = "User not found" }, JsonRequestBehavior.AllowGet);

            try
            {
                // build matched records as in Index
                string fullname = (user.fldName ?? "").Trim() + " " + (user.fldLastName ?? "").Trim();
                string sicil = (user.fldSicil ?? "").Trim();

                var allWithUser = db.E_History.Where(h => h.fldUser != null).ToList();
                var matched = allWithUser.Where(h =>
                {
                    var fu = (h.fldUser ?? "").Trim();
                    if (string.IsNullOrEmpty(fu)) return false;
                    var ns = fu.ToLowerInvariant();
                    if (!string.IsNullOrEmpty(sicil))
                    {
                        var nsicil = sicil.ToLowerInvariant();
                        if (ns.StartsWith(nsicil + "|")) return true;
                        if (ns == nsicil) return true;
                        var idx = ns.IndexOf('|');
                        if (idx > 0)
                        {
                            var first = ns.Substring(0, idx).Trim();
                            if (first == nsicil) return true;
                        }
                    }
                    if (!string.IsNullOrEmpty(fullname) && ns == fullname.ToLowerInvariant()) return true;
                    return false;
                }).ToList();

                var filtered = matched.Where(h => string.Equals(h.fldBorder ?? "", border ?? "", StringComparison.OrdinalIgnoreCase)).OrderByDescending(h => h.fldDatetime).ToList();
                var total = filtered.Count;
                var items = filtered.Skip((page - 1) * pageSize).Take(pageSize).Select(h => new
                {
                    fldId = h.fldId,
                    date = h.fldDatetime.HasValue ? h.fldDatetime.Value.ToString("o") : null,
                    country = h.fldCountry,
                    penalty = h.fldPMoney,
                    user = h.fldUser
                }).ToList();

                var csvUrl = Url.Action("ExportBorderCsv", new { border = border });

                return Json(new { success = true, total = total, page = page, pageSize = pageSize, items = items, csv = csvUrl }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpGet]
        public ActionResult ExportBorderCsv(string border)
        {
            var userId = GetCurrentUserId();
            if (userId == null) return new HttpStatusCodeResult(401);
            var user = db.E_User.FirstOrDefault(x => x.fldId == userId);
            if (user == null) return new HttpStatusCodeResult(401);

            // build matched as before
            string fullname = (user.fldName ?? "").Trim() + " " + (user.fldLastName ?? "").Trim();
            string sicil = (user.fldSicil ?? "").Trim();

            var allWithUser = db.E_History.Where(h => h.fldUser != null).ToList();
            var matched = allWithUser.Where(h =>
            {
                var fu = (h.fldUser ?? "").Trim();
                if (string.IsNullOrEmpty(fu)) return false;
                var ns = fu.ToLowerInvariant();
                if (!string.IsNullOrEmpty(sicil))
                {
                    var nsicil = sicil.ToLowerInvariant();
                    if (ns.StartsWith(nsicil + "|")) return true;
                    if (ns == nsicil) return true;
                    var idx = ns.IndexOf('|');
                    if (idx > 0)
                    {
                        var first = ns.Substring(0, idx).Trim();
                        if (first == nsicil) return true;
                    }
                }
                if (!string.IsNullOrEmpty(fullname) && ns == fullname.ToLowerInvariant()) return true;
                return false;
            }).ToList();

            var filtered = matched.Where(h => string.Equals(h.fldBorder ?? "", border ?? "", StringComparison.OrdinalIgnoreCase)).OrderByDescending(h => h.fldDatetime).ToList();

            var sb = new System.Text.StringBuilder();
            sb.AppendLine("Id;Tarih;Ülke;Ceza;Kullanıcı");
            foreach (var h in filtered)
            {
                var date = h.fldDatetime.HasValue ? h.fldDatetime.Value.ToString("dd.MM.yyyy HH:mm") : "";
                var line = string.Format("{0};{1};{2};{3};{4}", h.fldId, date, (h.fldCountry ?? ""), (h.fldPMoney ?? ""), (h.fldUser ?? ""));
                sb.AppendLine(line);
            }

            var bytes = System.Text.Encoding.UTF8.GetBytes(sb.ToString());
            var fileName = string.Format("border_{0}_history_{1}.csv", border ?? "all", DateTime.Now.ToString("yyyyMMddHHmm"));
            return File(bytes, "text/csv; charset=utf-8", fileName);
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing) db?.Dispose();
            base.Dispose(disposing);
        }
    }
}