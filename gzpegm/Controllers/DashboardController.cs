using gzpegm.Cont;
using gzpegm.Models;
using gzpegm.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize(Users = "2,3,6")]
    public class DashboardController : Controller
    {
        private GZPEGM1 db = new GZPEGM1();

        private IQueryable<E_Messages> LandingCommentsQuery()
        {
            return db.E_Messages.Where(m =>
                m.fldRecipientId == null &&
                (m.fldSubject == null || m.fldSubject == "") &&
                m.fldIsReply == false &&
                m.fldParentMessageId == null &&
                (
                    m.fldSenderRole == null ||
                    (
                        m.fldSenderRole != "Admin" &&
                        m.fldSenderRole != "Teacher"
                    )
                ) &&
                (
                    m.fldSenderId == null ||
                    !db.E_User.Any(u =>
                        u.fldId == m.fldSenderId.Value &&
                        (
                            u.Role == "Admin" ||
                            u.Role == "Teacher"
                        ))
                ) &&
                (
                    m.fldSendBySicil == null ||
                    m.fldSendBySicil == "" ||
                    !db.E_User.Any(u =>
                        u.fldSicil == m.fldSendBySicil &&
                        (
                            u.Role == "Admin" ||
                            u.Role == "Teacher"
                        ))
                ));
        }

        private E_User GetCurrentUser()
        {
            try
            {
                HttpCookie UserCookie = Request.Cookies["Token"];
                if (UserCookie == null) return null;

                Token token = new Token();
                var tokendata = token.GetToken(UserCookie.Value);
                if (tokendata == null) return null;

                int UserId = 0;
                int.TryParse(tokendata.fldUserId?.ToString(), out UserId);
                if (UserId == 0) return null;

                User user = new User();
                return user.GetUserById(UserId);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"GetCurrentUser Error: {ex.Message}");
                return null;
            }
        }

        // Admin/Teacher Dashboard
        public ActionResult Index()
        {
            var user = GetCurrentUser();
            if (user == null)
            {
                TempData["msgError"] = "Lütfen giriş yapın.";
                return RedirectToAction("Login", "Account");
            }

            if (user.Role != "Admin" && user.Role != "Teacher")
            {
                TempData["msgError"] = "Bu sayfaya erişim yetkiniz yok.";
                return RedirectToAction("Index", "Home");
            }

            var model = new DashboardViewModel();

            // Genel İstatistikler
            model.TotalCourses = db.Courses.Count(c => c.IsActive);
            model.TotalExams = db.Exam.Count(e => e.IsActive);
            model.TotalStudents = db.E_User.Count(u =>
                u.Role == "Student" &&
                (u.IsActive == true || u.fldActive == "1"));
            model.TotalEnrollments = db.CourseEnrollments.Count();

            // Son 30 gün kayıt grafiği
            var last30Days = DateTime.Now.AddDays(-30);
            var enrollmentsByDay = db.CourseEnrollments
                .Where(e => e.EnrollmentDate >= last30Days)
                .GroupBy(e => System.Data.Entity.DbFunctions.TruncateTime(e.EnrollmentDate))
                .Select(g => new
                {
                    Date = g.Key,
                    Count = g.Count()
                })
                .OrderBy(x => x.Date)
                .ToList();

            model.EnrollmentDatesJson = Newtonsoft.Json.JsonConvert.SerializeObject(
                enrollmentsByDay.Select(e => e.Date.Value.ToString("dd.MM")).ToList()
            );
            model.EnrollmentCountsJson = Newtonsoft.Json.JsonConvert.SerializeObject(
                enrollmentsByDay.Select(e => e.Count).ToList()
            );

            // En popüler kurslar
            var popularCourses = (from c in db.Courses
                                  join e in db.CourseEnrollments on c.CourseId equals e.CourseId into enrollments
                                  where c.IsActive
                                  select new
                                  {
                                      CourseTitle = c.CourseTitle,
                                      EnrollmentCount = enrollments.Count()
                                  })
                                 .OrderByDescending(x => x.EnrollmentCount)
                                 .Take(5)
                                 .ToList();

            model.PopularCourseTitlesJson = Newtonsoft.Json.JsonConvert.SerializeObject(
                popularCourses.Select(c => c.CourseTitle).ToList()
            );
            model.PopularCourseCountsJson = Newtonsoft.Json.JsonConvert.SerializeObject(
                popularCourses.Select(c => c.EnrollmentCount).ToList()
            );

            // Sınav başarı oranları
            var examStats = (from e in db.Exam
                             join er in db.ExamResult on e.ExamId equals er.ExamId
                             where e.IsActive && er.Status == 1
                             let maxScore = db.Question.Where(q => q.ExamId == e.ExamId).Sum(q => (int?)q.Points) ?? 1
                             let percentage = ((er.Score ?? 0) * 100m) / maxScore
                             let passingScore = e.PassingScore ?? 60
                             group new { IsPassed = percentage >= passingScore } by e.Title into g
                             select new
                             {
                                 ExamTitle = g.Key,
                                 PassedCount = g.Count(x => x.IsPassed),
                                 FailedCount = g.Count(x => !x.IsPassed),
                                 TotalCount = g.Count()
                             })
                            .OrderByDescending(x => x.TotalCount)
                            .Take(5)
                            .ToList();

            model.ExamTitlesJson = Newtonsoft.Json.JsonConvert.SerializeObject(
                examStats.Select(e => e.ExamTitle).ToList()
            );
            model.ExamPassedCountsJson = Newtonsoft.Json.JsonConvert.SerializeObject(
                examStats.Select(e => e.PassedCount).ToList()
            );
            model.ExamFailedCountsJson = Newtonsoft.Json.JsonConvert.SerializeObject(
                examStats.Select(e => e.FailedCount).ToList()
            );

            // Son aktiviteler — tipli listeye dönüştürme
            var recentActivities = db.ExamResult
                                   .Where(er => er.Status == 1)
                                   .OrderByDescending(er => er.FinishedAt)
                                   .Take(10)
                                   .ToList() // sorgu sonlandıktan sonra bellekte dönüştürme
                                   .Select(er =>
                                   {
                                       var userName = db.E_User
                                                        .Where(u => u.fldId == er.UserId)
                                                        .Select(u => u.fldName + " " + u.fldLastName)
                                                        .FirstOrDefault() ?? "—";

                                       var examTitle = db.Exam
                                                        .Where(e => e.ExamId == er.ExamId)
                                                        .Select(e => e.Title)
                                                        .FirstOrDefault() ?? "—";

                                       var maxScore = db.Question
                                                        .Where(q => q.ExamId == er.ExamId)
                                                        .Sum(q => (int?)q.Points) ?? 1;

                                       var rawScore = er.Score ?? 0m;
                                       var scoreInt = Convert.ToInt32(Math.Round(rawScore));
                                       var percentage = maxScore > 0 ? (rawScore * 100m) / maxScore : 0m;

                                       return new RecentActivityViewModel
                                       {
                                           UserName = userName,
                                           ExamTitle = examTitle,
                                           Score = scoreInt,
                                           MaxScore = maxScore,
                                           Percentage = percentage,
                                           FinishedAt = er.FinishedAt
                                       };
                                   })
                                   .ToList();

            model.RecentActivities = recentActivities;

            // Backwards compatibility: eski view'lar ViewBag.RecentActivities bekleyebilir.
            ViewBag.RecentActivities = recentActivities;

            // Ek: En başarılı öğrenci(ler) — tipli liste
            var topStudents = (from er in db.ExamResult
                               join e in db.Exam on er.ExamId equals e.ExamId
                               where er.Status == 1
                               let maxScore = db.Question.Where(q => q.ExamId == e.ExamId).Sum(q => (int?)q.Points) ?? 1
                               let percentage = maxScore > 0 ? ((er.Score ?? 0m) * 100m) / maxScore : 0m
                               select new { er.UserId, Percentage = percentage })
                              .ToList()
                              .GroupBy(x => x.UserId)
                              .Select(g => new
                              {
                                  UserId = g.Key,
                                  AveragePercentage = g.Average(x => (double)x.Percentage)
                              })
                              .OrderByDescending(x => x.AveragePercentage)
                              .Take(5)
                              .ToList()
                              .Select(x => new TopStudentViewModel
                              {
                                  Name = db.E_User.Where(u => u.fldId == x.UserId).Select(u => u.fldName + " " + u.fldLastName).FirstOrDefault() ?? "—",
                                  Avg = Convert.ToInt32(Math.Round(x.AveragePercentage))
                              })
                              .ToList();

            model.TopStudents = topStudents;
            ViewBag.TopStudents = topStudents;

            // Yeni: Son 7 gün aktif öğrenci sayısı (ExamResult tablosundan proxy olarak hesaplanıyor)
            var since7 = DateTime.Now.AddDays(-7);
            model.ActiveStudentsLast7Days = db.ExamResult
                .Where(er => er.Status == 1 && er.FinishedAt.HasValue && er.FinishedAt.Value >= since7)
                .Select(er => er.UserId)
                .Distinct()
                .Count();

            // Yeni: Ortalama sınav süresi (dakika)
            var durations = db.ExamResult
                .Where(er => er.Status == 1 && er.StartedAt.HasValue && er.FinishedAt.HasValue)
                .Select(er => System.Data.Entity.DbFunctions.DiffMinutes(er.StartedAt, er.FinishedAt))
                .ToList()
                .Where(d => d.HasValue)
                .Select(d => d.Value)
                .ToList();

            model.AverageExamDurationMinutes = durations.Count > 0
                ? Convert.ToInt32(Math.Round(durations.Average()))
                : 0;

            // Bekleyen onaylar - dashboard bildirimleri için
            model.PendingCourseReviewsCount = db.CourseReviews.Count(r => r.IsApproved == false);
            model.PendingLandingCommentsCount = LandingCommentsQuery().Count(m => m.fldIsApproved == false);
            model.PendingCertificateRequestsCount = db.CertificateRequest.Count(r => r.Status == 0);

            // Backwards compatibility: ViewBag de set edelim
            ViewBag.PendingCourseReviewsCount = model.PendingCourseReviewsCount;
            ViewBag.PendingLandingCommentsCount = model.PendingLandingCommentsCount;
            ViewBag.PendingCertificateRequestsCount = model.PendingCertificateRequestsCount;

            // Model'deki JSON alanları ile ViewBag uyumu (eski view kodları için)
            ViewBag.TotalCourses = model.TotalCourses;
            ViewBag.TotalExams = model.TotalExams;
            ViewBag.TotalStudents = model.TotalStudents;
            ViewBag.TotalEnrollments = model.TotalEnrollments;
            ViewBag.EnrollmentDates = model.EnrollmentDatesJson;
            ViewBag.EnrollmentCounts = model.EnrollmentCountsJson;
            ViewBag.PopularCourseTitles = model.PopularCourseTitlesJson;
            ViewBag.PopularCourseCounts = model.PopularCourseCountsJson;
            ViewBag.ExamTitles = model.ExamTitlesJson;
            ViewBag.ExamPassedCounts = model.ExamPassedCountsJson;
            ViewBag.ExamFailedCounts = model.ExamFailedCountsJson;

            // Yeni ViewBag değerleri (eski view'lar için)
            ViewBag.ActiveStudentsLast7Days = model.ActiveStudentsLast7Days;
            ViewBag.AverageExamDurationMinutes = model.AverageExamDurationMinutes;

            ViewBag.CurrentUser = user;
            model.CurrentUser = user;

            return View(model);
        }
        public ActionResult StudentDashboard()
        {
            var user = GetCurrentUser();
            if (user == null)
            {
                TempData["msgError"] = "Lütfen giriş yapın.";
                return RedirectToAction("Login", "Account");
            }

            var userId = user.fldId;

            // TEK SORGU İLE TÜM VERİYİ AL
            var examResults = (from er in db.ExamResult
                               join e in db.Exam on er.ExamId equals e.ExamId
                               join c in db.Courses on e.CourseId equals c.CourseId
                               where er.UserId == userId && er.Status == 1
                               select new
                               {
                                   er.ExamId,
                                   er.Score,
                                   er.FinishedAt,
                                   er.StartedAt,
                                   e.Title,
                                   e.PassingScore,
                                   c.CourseTitle,
                                   e.CourseId
                               }).ToList();

            // Sınav ID'lerini topla
            var examIds = examResults.Select(x => x.ExamId).Distinct().ToList();

            // TEK SORGU İLE TÜM MAX SCORELARI AL
            var maxScores = (from q in db.Question
                             where examIds.Contains(q.ExamId)
                             group q by q.ExamId into g
                             select new
                             {
                                 ExamId = g.Key,
                                 MaxScore = g.Sum(x => (int?)x.Points) ?? 1
                             }).ToDictionary(x => x.ExamId, x => x.MaxScore);

            var model = new StudentDashboardViewModel
            {
                CurrentUserName = user.fldName,
                EnrolledCoursesCount = db.CourseEnrollments.Count(e => e.UserId == userId),
                CompletedExamsCount = examResults.Count
            };

            // Hesaplamaları memory'de yap
            var examDetails = new List<ExamDetail>();
            foreach (var er in examResults)
            {
                var maxScore = maxScores.ContainsKey(er.ExamId) ? maxScores[er.ExamId] : 1;
                decimal score = er.Score ?? 0;
                decimal percentage = (score * 100m) / maxScore;

                examDetails.Add(new ExamDetail
                {
                    ExamId = er.ExamId,
                    Score = (int)score,
                    MaxScore = maxScore,
                    Percentage = percentage,
                    IsPassed = percentage >= (er.PassingScore ?? 60),
                    FinishedAt = er.FinishedAt.Value,
                    Title = er.Title,
                    CourseTitle = er.CourseTitle,
                    StartedAt = er.StartedAt
                });
            }

            model.PassedExamsCount = examDetails.Count(x => x.IsPassed);
            model.AverageScore = examDetails.Count > 0
                ? (int)Math.Round(examDetails.Average(x => x.Percentage))
                : 0;

            // Süre hesaplamaları - DateTime? kontrolü düzeltilmiş
            var durations = examDetails
                .Where(x => x.StartedAt.HasValue && x.FinishedAt != null)
                .Select(x => (x.FinishedAt - x.StartedAt.Value).TotalMinutes)
                .ToList();

            model.TotalExamTimeMinutes = durations.Count > 0 ? (int)Math.Round(durations.Sum()) : 0;
            model.AverageExamDurationMinutes = durations.Count > 0 ? (int)Math.Round(durations.Average()) : 0;
            model.LastExamAt = examDetails.Any() ? examDetails.Max(x => x.FinishedAt) : (DateTime?)null;

            // Son 5 sınav
            model.RecentExams = examDetails
                .OrderByDescending(x => x.FinishedAt)
                .Take(5)
                .Select(x => new RecentExamViewModel
                {
                    ExamTitle = x.Title,
                    CourseTitle = x.CourseTitle,
                    Score = x.Score,
                    MaxScore = x.MaxScore,
                    Percentage = x.Percentage,
                    IsPassed = x.IsPassed,
                    FinishedAt = x.FinishedAt
                })
                .ToList();

            return View(model);
        }

        // Yardımcı class
        public class ExamDetail
        {
            public int ExamId { get; set; }
            public int Score { get; set; }
            public int MaxScore { get; set; }
            public decimal Percentage { get; set; }
            public bool IsPassed { get; set; }
            public DateTime FinishedAt { get; set; }
            public DateTime? StartedAt { get; set; }
            public string Title { get; set; }
            public string CourseTitle { get; set; }
        }

        // Excel Export - Sınav Sonuçları
        public ActionResult ExportExamResults(int examId)
        {
            var user = GetCurrentUser();
            if (user == null || (user.Role != "Admin" && user.Role != "Teacher"))
            {
                TempData["msgError"] = "Yetkiniz yok.";
                return RedirectToAction("Index");
            }

            var exam = db.Exam.Find(examId);
            if (exam == null)
            {
                TempData["msgError"] = "Sınav bulunamadı.";
                return RedirectToAction("Index");
            }

            var results = (from er in db.ExamResult
                           join u in db.E_User on er.UserId equals u.fldId
                           where er.ExamId == examId && er.Status == 1
                           let maxScore = db.Question.Where(q => q.ExamId == examId).Sum(q => (int?)q.Points) ?? 1
                           let percentage = ((er.Score ?? 0) * 100m) / maxScore
                           orderby u.fldName, u.fldLastName
                           select new
                           {
                               Sicil = u.fldSicil,
                               Ad = u.fldName,
                               Soyad = u.fldLastName,
                               Puan = er.Score ?? 0,
                               MaxPuan = maxScore,
                               Yuzde = percentage,
                               BaslangicTarihi = er.StartedAt,
                               BitisTarihi = er.FinishedAt
                           }).ToList();

            using (var workbook = new ClosedXML.Excel.XLWorkbook())
            {
                var worksheet = workbook.Worksheets.Add("Sınav Sonuçları");

                // Başlık
                worksheet.Cell(1, 1).Value = "Sicil No";
                worksheet.Cell(1, 2).Value = "Ad";
                worksheet.Cell(1, 3).Value = "Soyad";
                worksheet.Cell(1, 4).Value = "Puan";
                worksheet.Cell(1, 5).Value = "Max Puan";
                worksheet.Cell(1, 6).Value = "Başarı %";
                worksheet.Cell(1, 7).Value = "Başlangıç";
                worksheet.Cell(1, 8).Value = "Bitiş";

                // Başlık stili
                var headerRange = worksheet.Range(1, 1, 1, 8);
                headerRange.Style.Font.Bold = true;
                headerRange.Style.Fill.BackgroundColor = ClosedXML.Excel.XLColor.LightBlue;

                // Veriler
                int row = 2;
                foreach (var result in results)
                {
                    worksheet.Cell(row, 1).Value = result.Sicil;
                    worksheet.Cell(row, 2).Value = result.Ad;
                    worksheet.Cell(row, 3).Value = result.Soyad;
                    worksheet.Cell(row, 4).Value = result.Puan;
                    worksheet.Cell(row, 5).Value = result.MaxPuan;
                    worksheet.Cell(row, 6).Value = $"{result.Yuzde:F1}%";
                    worksheet.Cell(row, 7).Value = result.BaslangicTarihi?.ToString("dd.MM.yyyy HH:mm");
                    worksheet.Cell(row, 8).Value = result.BitisTarihi?.ToString("dd.MM.yyyy HH:mm");
                    row++;
                }

                worksheet.Columns().AdjustToContents();

                using (var stream = new System.IO.MemoryStream())
                {
                    workbook.SaveAs(stream);
                    var content = stream.ToArray();
                    return File(content, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                        $"Sinav_Sonuclari_{exam.Title}_{DateTime.Now:yyyyMMdd}.xlsx");
                }
            }
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing) db?.Dispose();
            base.Dispose(disposing);
        }
    }
}