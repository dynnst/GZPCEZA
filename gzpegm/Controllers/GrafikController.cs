using gzpegm.Cont;
using gzpegm.Models;
using System;
using System.Data.Entity;
using System.Globalization;
using System.Linq;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize(Users = "2,3")]
    [RoutePrefix("Grafik")]
    public class GrafikController : Controller
    {
        private readonly GZPEGM1 db = new GZPEGM1();

        protected override void Dispose(bool disposing)
        {
            if (disposing)
                db.Dispose();
            base.Dispose(disposing);
        }

        private decimal SafeParseDecimal(string value)
        {
            if (string.IsNullOrEmpty(value)) return 0;

            value = value.Trim()
                .Replace("TL", string.Empty)
                .Replace("₺", string.Empty)
                .Replace(" ", string.Empty);

            decimal result;
            var cultures = new[]
            {
                new CultureInfo("tr-TR"),
                CultureInfo.InvariantCulture,
                new CultureInfo("en-US")
            };

            foreach (var culture in cultures)
            {
                if (decimal.TryParse(value, NumberStyles.Any, culture, out result))
                    return result;
            }

            return 0;
        }

        [NonAction]
        private E_User GetCurrentUser()
        {
            var userFromItems = HttpContext.Items["CurrentUser"] as E_User;
            if (userFromItems != null) return userFromItems;

            try
            {
                var cookie = Request.Cookies["Token"];
                if (cookie == null || string.IsNullOrWhiteSpace(cookie.Value)) return null;

                var tokenData = new Token().GetToken(cookie.Value);
                if (tokenData?.fldUserId == null) return null;

                if (!int.TryParse(tokenData.fldUserId.ToString(), out int userId)) return null;

                return new User().GetUserById(userId);
            }
            catch
            {
                return null;
            }
        }

        [NonAction]
        private bool IsAdminUser(E_User user)
        {
            if (user == null) return false;
            if (string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase)) return true;
            var auth = (user.fldAuth ?? string.Empty).Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries).Select(x => x.Trim());
            return auth.Contains("2");
        }

        [NonAction]
        private string ResolveEffectiveBorder(E_User user, string requestedBorder)
        {
            if (user == null) return string.Empty;

            // Admin: Tüm kapıları veya istediği tek bir kapıyı sorgulayabilir
            if (IsAdminUser(user))
            {
                if (string.Equals(requestedBorder, "all", StringComparison.OrdinalIgnoreCase))
                    return string.Empty;
                return (requestedBorder ?? string.Empty).Trim();
            }

            // Kapı Personeli (Role 3): Yetkisi KESİNLİKLE sadece kendi hudut kapısı ile sınırlıdır!
            // Dışarıdan gelen parametre güvenlik nedeniyle tamamen yok sayılır.
            return (user.fldBorder ?? string.Empty).Trim();
        }

        [Route("")]
        [Route("CezaGrafik")]
        public ActionResult CezaGrafik()
        {
            var user = GetCurrentUser();
            if (user == null)
                return RedirectToAction("Index", "Giris");

            bool isAdmin = IsAdminUser(user);
            string userBorder = (user.fldBorder ?? string.Empty).Trim();

            var themeCookie = Request.Cookies["theme"];
            ViewBag.CurrentTheme = themeCookie != null ? themeCookie.Value : "light";
            ViewBag.IsAdmin = isAdmin;
            ViewBag.UserBorder = userBorder;
            ViewBag.UserFullName = ((user.fldName ?? string.Empty) + " " + (user.fldLastName ?? string.Empty)).Trim();

            return View();
        }

        [HttpGet]
        [Route("ChartData")]
        public JsonResult ChartData(DateTime? startDate = null, DateTime? endDate = null, string country = null, string border = null)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null)
                    return Json(new { success = false, error = "Oturum süreniz dolmuş. Lütfen tekrar giriş yapınız." }, JsonRequestBehavior.AllowGet);

                bool isAdmin = IsAdminUser(user);
                string effectiveBorder = ResolveEffectiveBorder(user, border);

                if (!isAdmin && string.IsNullOrEmpty(effectiveBorder))
                {
                    return Json(new { success = false, error = "Bağlı olduğunuz hudut kapısı tanımlı değildir. Lütfen yöneticinizle iletişime geçiniz." }, JsonRequestBehavior.AllowGet);
                }

                IQueryable<E_History> historyQuery = db.E_History.AsNoTracking();
                if (startDate.HasValue)
                    historyQuery = historyQuery.Where(x => x.fldDatetime >= startDate.Value);
                if (endDate.HasValue)
                {
                    var end = endDate.Value.Date.AddDays(1).AddTicks(-1);
                    historyQuery = historyQuery.Where(x => x.fldDatetime <= end);
                }
                if (!string.IsNullOrEmpty(country) && country != "all")
                    historyQuery = historyQuery.Where(x => x.fldCountry == country);

                if (!string.IsNullOrEmpty(effectiveBorder))
                    historyQuery = historyQuery.Where(x => x.fldBorder == effectiveBorder);

                var historyData = historyQuery.ToList();
                var validDateHistory = historyData.Where(x => x.fldDatetime.HasValue).ToList();

                var ulkeTop = historyData
                    .GroupBy(x => string.IsNullOrEmpty(x.fldCountry) ? "Belirtilmemiş" : x.fldCountry)
                    .Select(g => new { Country = g.Key, Count = g.Count(), TotalMoney = g.Sum(x => SafeParseDecimal(x.fldPMoney)) })
                    .OrderByDescending(x => x.Count)
                    .Take(10)
                    .ToList();

                var ulkeParaTop = historyData
                    .GroupBy(x => string.IsNullOrEmpty(x.fldCountry) ? "Belirtilmemiş" : x.fldCountry)
                    .Select(g => new { Country = g.Key, Count = g.Count(), TotalMoney = g.Sum(x => SafeParseDecimal(x.fldPMoney)) })
                    .OrderByDescending(x => x.TotalMoney)
                    .Take(10)
                    .ToList();

                var kapiParaTop = historyData
                    .Where(x => !string.IsNullOrEmpty(x.fldBorder))
                    .GroupBy(x => x.fldBorder)
                    .Select(g => new { Border = g.Key, ToplamPara = g.Sum(x => SafeParseDecimal(x.fldPMoney)), Count = g.Count() })
                    .OrderByDescending(x => x.ToplamPara)
                    .Take(10)
                    .ToList();

                var penaltyTop = historyData
                    .Where(x => !string.IsNullOrEmpty(x.fldPenalty))
                    .GroupBy(x => x.fldPenalty)
                    .Select(g => new { Penalty = g.Key, Count = g.Count(), TotalMoney = g.Sum(x => SafeParseDecimal(x.fldPMoney)) })
                    .OrderByDescending(x => x.Count)
                    .Take(10)
                    .ToList();

                var monthlyTrend = validDateHistory
                    .GroupBy(x => new { Year = x.fldDatetime.Value.Year, Month = x.fldDatetime.Value.Month })
                    .Select(g => new
                    {
                        g.Key.Year,
                        g.Key.Month,
                        YearMonth = new DateTime(g.Key.Year, g.Key.Month, 1).ToString("yyyy-MM"),
                        Count = g.Count(),
                        TotalMoney = g.Sum(x => SafeParseDecimal(x.fldPMoney))
                    })
                    .OrderByDescending(x => x.Year)
                    .ThenByDescending(x => x.Month)
                    .Take(12)
                    .OrderBy(x => x.Year)
                    .ThenBy(x => x.Month)
                    .ToList();

                var dailyTrend = validDateHistory
                    .GroupBy(x => x.fldDatetime.Value.Date)
                    .Select(g => new
                    {
                        Date = g.Key,
                        DateStr = g.Key.ToString("dd.MM.yyyy"),
                        Count = g.Count(),
                        TotalMoney = g.Sum(x => SafeParseDecimal(x.fldPMoney))
                    })
                    .OrderByDescending(x => x.Date)
                    .Take(30)
                    .OrderBy(x => x.Date)
                    .ToList();

                var hourlyData = validDateHistory
                    .GroupBy(x => x.fldDatetime.Value.Hour)
                    .Select(g => new { Hour = g.Key, TimeRange = $"{g.Key:D2}:00-{g.Key:D2}:59", Count = g.Count() })
                    .OrderBy(x => x.Hour)
                    .ToList();

                var peakHourData = hourlyData.OrderByDescending(x => x.Count).Take(5).ToList();

                var personnelTop = historyData
                    .Where(x => !string.IsNullOrEmpty(x.fldUser))
                    .GroupBy(x => gzpegm.Helpers.HistoryUserHelper.GetGroupingKey(x.fldUser))
                    .Select(g => new
                    {
                        PersonnelName = gzpegm.Helpers.HistoryUserHelper.GetDisplayName(g.First().fldUser),
                        TransactionCount = g.Count(),
                        TotalMoney = g.Sum(x => SafeParseDecimal(x.fldPMoney)),
                        FirstTransaction = g.Where(x => x.fldDatetime.HasValue).Select(x => x.fldDatetime).DefaultIfEmpty().Min(),
                        LastTransaction = g.Where(x => x.fldDatetime.HasValue).Select(x => x.fldDatetime).DefaultIfEmpty().Max()
                    })
                    .OrderByDescending(x => x.TransactionCount)
                    .Take(10)
                    .ToList();

                IQueryable<E_Inad> inadQuery = db.E_Inad.AsNoTracking();
                if (startDate.HasValue) inadQuery = inadQuery.Where(x => x.TarihSaat >= startDate.Value);
                if (endDate.HasValue)
                {
                    var end = endDate.Value.Date.AddDays(1).AddTicks(-1);
                    inadQuery = inadQuery.Where(x => x.TarihSaat <= end);
                }
                if (!string.IsNullOrEmpty(effectiveBorder)) inadQuery = inadQuery.Where(x => x.Kapi == effectiveBorder);
                var inadData = inadQuery.ToList();

                var inadByCountry = inadData
                    .GroupBy(x => string.IsNullOrEmpty(x.Uyruk) ? "Belirtilmemiş" : x.Uyruk)
                    .Select(g => new { Country = g.Key, Count = g.Count() })
                    .OrderByDescending(x => x.Count)
                    .Take(10)
                    .ToList();

                var inadByReason = inadData
                    .GroupBy(x => string.IsNullOrEmpty(x.InadSebep) ? "Diğer" : x.InadSebep)
                    .Select(g => new { Reason = g.Key, Count = g.Count() })
                    .OrderByDescending(x => x.Count)
                    .Take(10)
                    .ToList();

                IQueryable<E_User> userQuery = db.E_User.AsNoTracking();
                if (!string.IsNullOrEmpty(effectiveBorder))
                    userQuery = userQuery.Where(x => x.fldBorder == effectiveBorder);
                var userData = userQuery.ToList();

                var userByBorderTop10 = userData
                    .Where(x => !string.IsNullOrEmpty(x.fldBorder))
                    .GroupBy(x => x.fldBorder)
                    .Select(g => new { Border = g.Key, Count = g.Count() })
                    .OrderByDescending(x => x.Count)
                    .Take(10)
                    .ToList();

                IQueryable<E_Sartli> sartliQuery = db.E_Sartli.AsNoTracking();
                if (startDate.HasValue) sartliQuery = sartliQuery.Where(x => x.fldDate >= startDate.Value);
                if (endDate.HasValue)
                {
                    var end = endDate.Value.Date.AddDays(1).AddTicks(-1);
                    sartliQuery = sartliQuery.Where(x => x.fldDate <= end);
                }
                if (!string.IsNullOrEmpty(effectiveBorder)) sartliQuery = sartliQuery.Where(x => x.fldBorder == effectiveBorder);
                var sartliData = sartliQuery.ToList();

                var sartliByBorder = sartliData
                    .Where(x => !string.IsNullOrEmpty(x.fldBorder))
                    .GroupBy(x => x.fldBorder)
                    .Select(g => new { Border = g.Key, Count = g.Count() })
                    .OrderByDescending(x => x.Count)
                    .Take(10)
                    .ToList();

                var userByRole = userData
                    .Where(x => !string.IsNullOrEmpty(x.Role))
                    .GroupBy(x => x.Role)
                    .Select(g => new { Role = g.Key, Count = g.Count() })
                    .OrderByDescending(x => x.Count)
                    .ToList();

                var examByCourse = (from exam in db.Exam.AsNoTracking()
                                    join course in db.Courses.AsNoTracking() on exam.CourseId equals course.CourseId
                                    where exam.IsActive == true
                                    group exam by course.CourseTitle into g
                                    select new { Course = g.Key ?? "Belirtilmemiş", Count = g.Count() })
                                    .OrderByDescending(x => x.Count)
                                    .Take(10)
                                    .ToList();

                var questionByExam = (from question in db.Question.AsNoTracking()
                                      join exam in db.Exam.AsNoTracking() on question.ExamId equals exam.ExamId
                                      group question by new { exam.ExamId, exam.Title } into g
                                      select new { ExamId = g.Key.ExamId, ExamTitle = g.Key.Title ?? "Belirtilmemiş", Count = g.Count() })
                                      .OrderByDescending(x => x.Count)
                                      .Take(10)
                                      .ToList();

                var totalMoney = historyData.Sum(x => SafeParseDecimal(x.fldPMoney));
                var tahditStats = new TahditFormLogService().GetStatistics(startDate, endDate, effectiveBorder, null, null);
                var maxMoneyRecord = historyData
                    .Select(x => new
                    {
                        Country = x.fldCountry,
                        Border = x.fldBorder,
                        User = gzpegm.Helpers.HistoryUserHelper.GetDisplayName(x.fldUser),
                        Date = x.fldDatetime,
                        Money = SafeParseDecimal(x.fldPMoney)
                    })
                    .OrderByDescending(x => x.Money)
                    .FirstOrDefault();

                return Json(new
                {
                    success = true,
                    summary = new
                    {
                        totalCalculations = historyData.Count,
                        totalMoney,
                        averageMoney = historyData.Count > 0 ? Math.Round(totalMoney / historyData.Count, 2) : 0,
                        countryCount = historyData.Where(x => !string.IsNullOrEmpty(x.fldCountry)).Select(x => x.fldCountry).Distinct().Count(),
                        borderCount = historyData.Where(x => !string.IsNullOrEmpty(x.fldBorder)).Select(x => x.fldBorder).Distinct().Count(),
                        inadCount = inadData.Count,
                        sartliCount = sartliData.Count,
                        tahditFormCount = tahditStats.AllTotal,
                        maxMoneyRecord
                    },
                    ulkeTop,
                    ulkeParaTop,
                    kapiParaTop,
                    penaltyTop,
                    monthlyTrend,
                    dailyTrend,
                    hourlyData,
                    peakHourData,
                    personnelTop,
                    inadByCountry,
                    inadByReason,
                    userByBorderTop10,
                    sartliByBorder,
                    userByRole,
                    examByCourse,
                    questionByExam,
                    tahditByCode = tahditStats.AllByCode,
                    tahditByBorder = tahditStats.AllByBorder,
                    tahditByUser = tahditStats.AllByUser.Take(10),
                    timestamp = DateTime.Now.ToString("o")
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"ChartData Error: {ex.Message}");
                return Json(new { success = false, error = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpGet]
        [Route("TopBorderMonthly")]
        public JsonResult TopBorderMonthly(DateTime? startDate = null, DateTime? endDate = null, string border = null)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null) return Json(new { success = false, error = "Oturum açınız." }, JsonRequestBehavior.AllowGet);
                bool isAdmin = IsAdminUser(user);
                string effectiveBorder = ResolveEffectiveBorder(user, border);
                if (!isAdmin && string.IsNullOrEmpty(effectiveBorder))
                    return Json(new { success = false, error = "Yetkili kapı bulunamadı." }, JsonRequestBehavior.AllowGet);

                IQueryable<E_History> query = db.E_History.AsNoTracking();
                if (startDate.HasValue) query = query.Where(x => x.fldDatetime >= startDate.Value);
                if (endDate.HasValue)
                {
                    var end = endDate.Value.Date.AddDays(1).AddTicks(-1);
                    query = query.Where(x => x.fldDatetime <= end);
                }
                if (!string.IsNullOrEmpty(effectiveBorder)) query = query.Where(x => x.fldBorder == effectiveBorder);

                var historyData = query.ToList();
                var topBorders = historyData.Where(x => !string.IsNullOrEmpty(x.fldBorder))
                    .GroupBy(x => x.fldBorder).Select(g => new { Border = g.Key, Count = g.Count() })
                    .OrderByDescending(x => x.Count).Take(2).Select(x => x.Border).ToList();

                var monthlyData = historyData.Where(x => x.fldDatetime.HasValue && topBorders.Contains(x.fldBorder))
                    .GroupBy(x => new { Year = x.fldDatetime.Value.Year, Month = x.fldDatetime.Value.Month, Border = x.fldBorder })
                    .Select(g => new { g.Key.Year, g.Key.Month, Border = g.Key.Border, Count = g.Count(), YearMonth = new DateTime(g.Key.Year, g.Key.Month, 1).ToString("yyyy-MM") })
                    .OrderBy(x => x.YearMonth).ToList();

                return Json(new { success = true, topBorders, monthlyData }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex) { return Json(new { success = false, error = ex.Message }, JsonRequestBehavior.AllowGet); }
        }

        [HttpGet]
        [Route("HourlyTimeRange")]
        public JsonResult HourlyTimeRange(DateTime? startDate = null, DateTime? endDate = null, string border = null)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null) return Json(new { success = false, error = "Oturum açınız." }, JsonRequestBehavior.AllowGet);
                bool isAdmin = IsAdminUser(user);
                string effectiveBorder = ResolveEffectiveBorder(user, border);
                if (!isAdmin && string.IsNullOrEmpty(effectiveBorder))
                    return Json(new { success = false, error = "Yetkili kapı bulunamadı." }, JsonRequestBehavior.AllowGet);

                IQueryable<E_History> query = db.E_History.AsNoTracking();
                if (startDate.HasValue) query = query.Where(x => x.fldDatetime >= startDate.Value);
                if (endDate.HasValue)
                {
                    var end = endDate.Value.Date.AddDays(1).AddTicks(-1);
                    query = query.Where(x => x.fldDatetime <= end);
                }
                if (!string.IsNullOrEmpty(effectiveBorder)) query = query.Where(x => x.fldBorder == effectiveBorder);

                var historyData = query.Where(x => x.fldDatetime.HasValue).ToList();
                var hourlyData = historyData.GroupBy(x => x.fldDatetime.Value.Hour)
                    .Select(g => new { Hour = g.Key, TimeRange = $"{g.Key:D2}:00-{g.Key:D2}:59", Count = g.Count() }).OrderBy(x => x.Hour).ToList();
                var peakHourData = hourlyData.OrderByDescending(x => x.Count).Take(5).ToList();

                return Json(new { success = true, hourlyData, peakHourData }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex) { return Json(new { success = false, error = ex.Message }, JsonRequestBehavior.AllowGet); }
        }

        [HttpGet]
        [Route("DailyFinesSummary")]
        public JsonResult DailyFinesSummary(DateTime? startDate = null, DateTime? endDate = null, string border = null)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null) return Json(new { success = false, error = "Oturum açınız." }, JsonRequestBehavior.AllowGet);
                bool isAdmin = IsAdminUser(user);
                string effectiveBorder = ResolveEffectiveBorder(user, border);
                if (!isAdmin && string.IsNullOrEmpty(effectiveBorder))
                    return Json(new { success = false, error = "Yetkili kapı bulunamadı." }, JsonRequestBehavior.AllowGet);

                IQueryable<E_History> query = db.E_History.AsNoTracking();
                if (startDate.HasValue) query = query.Where(x => x.fldDatetime >= startDate.Value);
                if (endDate.HasValue)
                {
                    var end = endDate.Value.Date.AddDays(1).AddTicks(-1);
                    query = query.Where(x => x.fldDatetime <= end);
                }
                if (!string.IsNullOrEmpty(effectiveBorder)) query = query.Where(x => x.fldBorder == effectiveBorder);

                var historyData = query.Where(x => x.fldDatetime.HasValue).ToList();
                var dailyData = historyData.GroupBy(x => x.fldDatetime.Value.Date)
                    .Select(g => new { Date = g.Key, DateStr = g.Key.ToString("yyyy-MM-dd"), DayName = g.Key.ToString("dddd", new CultureInfo("tr-TR")), Count = g.Count(), TotalMoney = g.Sum(x => SafeParseDecimal(x.fldPMoney)) })
                    .OrderByDescending(x => x.Date).Take(30).OrderBy(x => x.Date).ToList();

                var totalFines = historyData.Count;
                var avgPerDay = dailyData.Count > 0 ? (decimal)totalFines / dailyData.Count : 0;
                var maxDay = dailyData.OrderByDescending(x => x.Count).FirstOrDefault();
                var minDay = dailyData.OrderBy(x => x.Count).FirstOrDefault();

                return Json(new { success = true, dailyData, statistics = new { totalFines, avgPerDay = Math.Round(avgPerDay, 2), maxDay, minDay, daysCount = dailyData.Count } }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex) { return Json(new { success = false, error = ex.Message }, JsonRequestBehavior.AllowGet); }
        }

        [HttpGet]
        [Route("GetBorderTransactions")]
        public JsonResult GetBorderTransactions(DateTime? startDate = null, DateTime? endDate = null, string border = null)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null) return Json(new { success = false, error = "Oturum açınız." }, JsonRequestBehavior.AllowGet);
                bool isAdmin = IsAdminUser(user);
                string effectiveBorder = ResolveEffectiveBorder(user, border);
                if (!isAdmin && string.IsNullOrEmpty(effectiveBorder))
                    return Json(new { success = false, error = "Yetkili kapı bulunamadı." }, JsonRequestBehavior.AllowGet);

                IQueryable<E_History> query = db.E_History.AsNoTracking();
                if (startDate.HasValue) query = query.Where(x => x.fldDatetime >= startDate.Value);
                if (endDate.HasValue)
                {
                    var end = endDate.Value.Date.AddDays(1).AddTicks(-1);
                    query = query.Where(x => x.fldDatetime <= end);
                }
                if (!string.IsNullOrEmpty(effectiveBorder)) query = query.Where(x => x.fldBorder == effectiveBorder);

                var borderTransactions = query.ToList().Where(x => !string.IsNullOrEmpty(x.fldBorder))
                    .GroupBy(x => x.fldBorder).Select(g => new { Border = g.Key, TransactionCount = g.Count(), TotalMoney = g.Sum(x => SafeParseDecimal(x.fldPMoney)) })
                    .OrderByDescending(x => x.TransactionCount).ToList();

                return Json(new { success = true, borderTransactions }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex) { return Json(new { success = false, error = ex.Message }, JsonRequestBehavior.AllowGet); }
        }

        [HttpGet]
        [Route("TopPersonnelByTransactions")]
        public JsonResult TopPersonnelByTransactions(DateTime? startDate = null, DateTime? endDate = null, string border = null)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null) return Json(new { success = false, error = "Oturum açınız." }, JsonRequestBehavior.AllowGet);
                bool isAdmin = IsAdminUser(user);
                string effectiveBorder = ResolveEffectiveBorder(user, border);
                if (!isAdmin && string.IsNullOrEmpty(effectiveBorder))
                    return Json(new { success = false, error = "Yetkili kapı bulunamadı." }, JsonRequestBehavior.AllowGet);

                IQueryable<E_History> query = db.E_History.AsNoTracking();
                if (startDate.HasValue) query = query.Where(x => x.fldDatetime >= startDate.Value);
                if (endDate.HasValue)
                {
                    var end = endDate.Value.Date.AddDays(1).AddTicks(-1);
                    query = query.Where(x => x.fldDatetime <= end);
                }
                if (!string.IsNullOrEmpty(effectiveBorder)) query = query.Where(x => x.fldBorder == effectiveBorder);

                var historyData = query.Where(x => x.fldDatetime.HasValue && !string.IsNullOrEmpty(x.fldUser)).ToList();
                var topPersonnel = historyData
                    .GroupBy(x => gzpegm.Helpers.HistoryUserHelper.GetGroupingKey(x.fldUser))
                    .Select(g => new
                    {
                        PersonnelName = gzpegm.Helpers.HistoryUserHelper.GetDisplayName(g.First().fldUser),
                        TransactionCount = g.Count(),
                        TotalMoney = g.Sum(x => SafeParseDecimal(x.fldPMoney)),
                        FirstTransaction = g.Min(x => x.fldDatetime),
                        LastTransaction = g.Max(x => x.fldDatetime)
                    })
                    .OrderByDescending(x => x.TransactionCount)
                    .Take(10)
                    .ToList();

                return Json(new { success = true, topPersonnel }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, error = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpGet]
        [Route("GetBorders")]
        public JsonResult GetBorders()
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null)
                    return Json(new { success = false, error = "Oturum açınız." }, JsonRequestBehavior.AllowGet);

                bool isAdmin = IsAdminUser(user);
                if (!isAdmin)
                {
                    var userBorder = (user.fldBorder ?? string.Empty).Trim();
                    var singleBorder = !string.IsNullOrEmpty(userBorder)
                        ? new System.Collections.Generic.List<string> { userBorder }
                        : new System.Collections.Generic.List<string>();

                    return Json(new { success = true, borders = singleBorder, isAdmin = false, currentBorder = userBorder }, JsonRequestBehavior.AllowGet);
                }

                var borders = db.E_History.AsNoTracking()
                    .Where(x => !string.IsNullOrEmpty(x.fldBorder))
                    .Select(x => x.fldBorder)
                    .Distinct()
                    .OrderBy(x => x)
                    .ToList();

                return Json(new { success = true, borders, isAdmin = true }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex) { return Json(new { success = false, error = ex.Message }, JsonRequestBehavior.AllowGet); }
        }
    }
}
