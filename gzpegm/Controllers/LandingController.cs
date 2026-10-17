using gzpegm.Cont;
using gzpegm.Models;
using gzpegm.Models.ViewModels;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    public class LandingController : Controller
    {
        private GZPEGM1 db = new GZPEGM1();

        private IQueryable<E_Messages> LandingCommentsQuery()
        {
            return db.E_Messages.Where(m =>
                // Landing yorumu, kullanıcılar arası özel/toplu mesaj değildir.
                m.fldRecipientId == null &&
                (m.fldSubject == null || m.fldSubject == "") &&
                m.fldIsReply == false &&
                m.fldParentMessageId == null &&

                // Admin ve öğretmenlerin gönderdiği kayıtlar yorum onay ekranına düşmesin.
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

        // Mevcut kullanıcıyı Cookie üzerinden al
        [NonAction]
        public E_User getuserby()
        {
            HttpCookie UserCookie = Request.Cookies["Token"];
            if (UserCookie == null) return null;

            Token token = new Token();
            var tokendata = token.GetToken(UserCookie.Value);
            if (tokendata == null) return null;

            int UserId = tokendata.fldUserId ?? 0;
            if (UserId == 0) return null;

            gzpegm.Cont.User user = new User();
            var uData = user.GetUserById(UserId);
            return uData;
        }

        // Yeni kurs id listesine göre kısa bilgileri döner (AJAX, fallback için)
        public JsonResult GetCoursesByIds(string ids)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(ids)) return Json(new List<object>(), JsonRequestBehavior.AllowGet);
                var idList = ids.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                                .Select(s => { int.TryParse(s, out var v); return v; })
                                .Where(v => v > 0).ToList();

                if (!idList.Any()) return Json(new List<object>(), JsonRequestBehavior.AllowGet);

                var briefs = db.Courses
                               .Where(c => idList.Contains(c.CourseId))
                               .OrderByDescending(c => c.CreatedDate)
                               .Select(c => new {
                                   CourseId = c.CourseId,
                                   CourseTitle = c.CourseTitle,
                                   CoverImage = c.CoverImage,
                                   CreatedDate = c.CreatedDate
                               })
                               .ToList();

                return Json(briefs, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"GetCoursesByIds Error: {ex}");
                return Json(new List<object>(), JsonRequestBehavior.AllowGet);
            }
        }

        public ActionResult Index()
        {
            // Landing ekranı hızlı açılmalı: tüm kursları değil, vitrin için son 12 kursu çekiyoruz.
            var courseList = gzpegm.Services.CacheService.GetOrCreate("Landing_ActiveCoursePreview_v1", () =>
            {
                return (from c in db.Courses.AsNoTracking()
                        join cat in db.Categories.AsNoTracking() on c.CategoryId equals cat.CategoryId
                        join u in db.E_User.AsNoTracking() on c.CreatedBy equals u.fldId into uj
                        from u in uj.DefaultIfEmpty()
                        where c.IsActive && (c.IsDeleted == null || c.IsDeleted == false)
                        orderby c.CreatedDate descending
                        select new CourseViewModel
                        {
                            CourseId = c.CourseId,
                            CourseTitle = c.CourseTitle,
                            CourseDescription = c.CourseDescription,
                            CoverImage = c.CoverImage,
                            CreatedBy = c.CreatedBy,
                            CreatedDate = c.CreatedDate,
                            CategoryId = c.CategoryId,
                            CategoryName = cat.CategoryName,
                            ResourceFile = c.ResourceFile,
                            InstructorName = u != null
                                ? ((u.fldName ?? "") + " " + (u.fldLastName ?? "")).Trim()
                                : "Bilinmeyen Eğitmen"
                        })
                    .Take(12)
                    .ToList();
            }, 10);

            var teacherList = gzpegm.Services.CacheService.GetOrCreate("Landing_TeachersPreview_v1", () =>
            {
                return db.E_User
                    .Where(u => (u.Role == "Admin" || u.Role == "Teacher") &&
                                (u.IsActive == null || u.IsActive == true))
                    .OrderBy(u => u.fldName)
                    .ThenBy(u => u.fldLastName)
                    .Take(12)
                    .AsNoTracking()
                    .ToList();
            }, 10);

            // Mevcut kullanıcı
            var currentUser = getuserby();

            // ViewModel oluştur
            var viewModel = new LandingViewModel
            {
                SliderCourses = courseList.Take(5).ToList(),
                LatestCourses = courseList.Take(8).ToList(),
                AllCourses = courseList,
                Teachers = teacherList,
                IsAuthenticated = currentUser != null,
                CurrentUser = currentUser,
                RecentExams = new List<LandingExamViewModel>() // varsayılan boş liste
            };

            // Sınav istatistiklerini önbellekten al (10 dk) - her istekte 25+ SQL çalıştırmayı önler
            try
            {
                var examStats = gzpegm.Services.CacheService.GetOrCreate("Landing_ExamAggregates_v2", () =>
                {
                    using (var statsDb = new GZPEGM1())
                    {
                        var data = new LandingExamAggregates();

                        // 1. Son 3 aktif sınav
                        var recentExamEntities = statsDb.Exam
                            .Where(e => e.IsActive == true)
                            .OrderByDescending(e => e.CreatedAt)
                            .Take(3)
                            .AsNoTracking()
                            .ToList();

                        var recentCourseIds = recentExamEntities.Select(e => e.CourseId).Distinct().ToList();
                        var courseTitles = statsDb.Courses
                            .AsNoTracking()
                            .Where(c => recentCourseIds.Contains(c.CourseId))
                            .ToDictionary(c => c.CourseId, c => c.CourseTitle);

                        var recentExamIds = recentExamEntities.Select(e => e.ExamId).ToList();
                        var examResults = statsDb.ExamResult
                            .AsNoTracking()
                            .Where(er => recentExamIds.Contains(er.ExamId) && er.Status == 1)
                            .GroupBy(er => er.ExamId)
                            .Select(g => new
                            {
                                ExamId = g.Key,
                                Count = g.Count(),
                                AvgScore = g.Average(er => (decimal?)er.Score) ?? 0m,
                                LastTaken = g.Max(er => (DateTime?)er.FinishedAt)
                            })
                            .ToDictionary(g => g.ExamId);

                        data.RecentExams = recentExamEntities.Select(e =>
                        {
                            courseTitles.TryGetValue(e.CourseId, out var cTitle);
                            examResults.TryGetValue(e.ExamId, out var res);
                            return new LandingExamViewModel
                            {
                                ExamId = e.ExamId,
                                ExamTitle = e.Title,
                                CourseTitle = cTitle ?? "Bilinmeyen Kurs",
                                ParticipantCount = res?.Count ?? 0,
                                AverageScore = res?.AvgScore ?? 0m,
                                CreatedDate = e.CreatedAt,
                                LastTakenDate = res?.LastTaken
                            };
                        }).ToList();

                        data.MostPopularExam = data.RecentExams.OrderByDescending(x => x.ParticipantCount).FirstOrDefault();

                        // 2. En çok girilen kurs
                        var topCourseGroup = statsDb.ExamResult
                            .Where(er => er.Status == 1)
                            .Join(statsDb.Exam, er => er.ExamId, ex => ex.ExamId, (er, ex) => new { ex.CourseId })
                            .GroupBy(x => x.CourseId)
                            .Select(g => new { CourseId = g.Key, Count = g.Count() })
                            .OrderByDescending(g => g.Count)
                            .FirstOrDefault();

                        if (topCourseGroup != null)
                        {
                            data.MostPopularCourse = statsDb.Courses.AsNoTracking()
                                .Where(c => c.CourseId == topCourseGroup.CourseId)
                                .Select(c => c.CourseTitle)
                                .FirstOrDefault() ?? string.Empty;
                            data.MostPopularCourseCount = topCourseGroup.Count;
                        }

                        // 3. Bu hafta girilen sınavlar (son 7 gün)
                        var weekStart = DateTime.Now.AddDays(-7);
                        var weeklyExamGroups = statsDb.ExamResult
                            .Where(er => er.Status == 1 && er.FinishedAt.HasValue && er.FinishedAt.Value >= weekStart)
                            .GroupBy(er => er.ExamId)
                            .Select(g => new { ExamId = g.Key, Count = g.Count(), LastTaken = g.Max(er => er.FinishedAt) })
                            .ToList();

                        var weeklyExamIds = weeklyExamGroups.Select(w => w.ExamId).ToList();
                        var weeklyExamsEntities = statsDb.Exam.AsNoTracking().Where(e => weeklyExamIds.Contains(e.ExamId)).ToList();
                        var weeklyCourseIds = weeklyExamsEntities.Select(e => e.CourseId).Distinct().ToList();
                        var weeklyCourseTitles = statsDb.Courses.AsNoTracking().Where(c => weeklyCourseIds.Contains(c.CourseId)).ToDictionary(c => c.CourseId, c => c.CourseTitle);
                        var weeklyExamsDict = weeklyExamsEntities.ToDictionary(e => e.ExamId);

                        data.WeeklyExams = weeklyExamGroups.Select(w =>
                        {
                            weeklyExamsDict.TryGetValue(w.ExamId, out var exEntity);
                            string cTitle = null;
                            if (exEntity != null) weeklyCourseTitles.TryGetValue(exEntity.CourseId, out cTitle);
                            return new LandingExamViewModel
                            {
                                ExamId = w.ExamId,
                                ExamTitle = exEntity?.Title ?? "Bilinmeyen Sınav",
                                CourseTitle = cTitle ?? "Bilinmeyen Kurs",
                                ParticipantCount = w.Count,
                                AverageScore = 0m,
                                LastTakenDate = w.LastTaken
                            };
                        }).ToList();

                        // 4. Genel toplamlar
                        data.TotalExamCount = statsDb.Exam.Count(e => e.IsActive == true);
                        data.TotalParticipantCount = statsDb.ExamResult.Count(er => er.Status == 1);
                        data.GlobalAverageScore = statsDb.ExamResult.Where(er => er.Score.HasValue).Average(er => (decimal?)er.Score) ?? 0m;
                        data.TotalExamResults = statsDb.ExamResult.Count();

                        return data;
                    }
                }, 10);

                if (examStats != null)
                {
                    viewModel.RecentExams = examStats.RecentExams;
                    viewModel.MostPopularExam = examStats.MostPopularExam;
                    viewModel.MostPopularCourse = examStats.MostPopularCourse;
                    viewModel.MostPopularCourseCount = examStats.MostPopularCourseCount;
                    viewModel.WeeklyExams = examStats.WeeklyExams;
                    viewModel.TotalExamCount = examStats.TotalExamCount;
                    viewModel.TotalParticipantCount = examStats.TotalParticipantCount;
                    viewModel.GlobalAverageScore = examStats.GlobalAverageScore;

                    ViewBag.TotalExams = examStats.TotalExamCount;
                    ViewBag.TotalExamResults = examStats.TotalExamResults;
                    ViewBag.SuccessfulExams = examStats.TotalParticipantCount;
                    ViewBag.AverageScore = examStats.GlobalAverageScore;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Landing exam stats error: {ex}");
                ViewBag.TotalExams = 0;
                ViewBag.TotalExamResults = 0;
                ViewBag.SuccessfulExams = 0;
                ViewBag.AverageScore = 0m;
            }

            // Son 6 onaylanmış yorumu LINQ ile çek, kullanıcı bilgisi ile birlikte
            try
            {
                var lastMessages = LandingCommentsQuery()
                    .Where(m => m.fldIsApproved == true) // ✅ Sadece onaylanmış mesajlar
                    .OrderByDescending(m => m.fldDateTime)
                    .Take(6)
                    .AsNoTracking()
                    .ToList();

                var commentSicils = lastMessages
                    .Select(m => m.fldSendBySicil)
                    .Where(s => !string.IsNullOrWhiteSpace(s))
                    .Distinct()
                    .ToList();

                var commentUsers = commentSicils.Any()
                    ? db.E_User
                        .AsNoTracking()
                        .Where(u => commentSicils.Contains(u.fldSicil))
                        .ToDictionary(u => u.fldSicil, u => u)
                    : new Dictionary<string, E_User>();

                viewModel.Comments = lastMessages
                    .Select(m =>
                    {
                        E_User user = null;
                        if (!string.IsNullOrWhiteSpace(m.fldSendBySicil))
                            commentUsers.TryGetValue(m.fldSendBySicil, out user);

                        return new LandingComment
                        {
                            Id = m.fldId,
                            Name = m.fldSendByName,
                            Message = m.fldMessage,
                            Date = m.fldDateTime,
                            Picture = user != null && !string.IsNullOrEmpty(user.fldPicture)
                                      ? user.fldPicture
                                      : Url.Content("~/files/user/police-xxl.png"),
                            User = user
                        };
                    })
                    .ToList();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Landing comments load error: {ex}");
                viewModel.Comments = new List<LandingComment>();
            }

            // TempData ile gelen yeni kurs bilgilerini ViewBag'e aktar (GirisController tarafından CourseBrief listesi olarak set ediliyor)
            // Öncelikle TempData varsa onu al
            // Öncelikle TempData JSON varsa onu dene
            if (TempData["NewCoursesJson"] != null)
            {
                try
                {
                    var json = TempData["NewCoursesJson"] as string;
                    if (!string.IsNullOrEmpty(json))
                    {
                        var briefs = Newtonsoft.Json.JsonConvert.DeserializeObject<System.Collections.Generic.List<gzpegm.Models.CourseBrief>>(json);
                        if (briefs != null && briefs.Count > 0)
                        {
                            ViewBag.NewCourseCount = briefs.Count;
                            ViewBag.NewCourseTitles = briefs;
                        }
                    }
                }
                catch { }
            }
            else if (TempData["NewCourses"] != null)
            {
                try
                {
                    var briefs = TempData["NewCourses"] as System.Collections.Generic.List<gzpegm.Models.CourseBrief>;
                    if (briefs != null && briefs.Count > 0)
                    {
                        ViewBag.NewCourseCount = briefs.Count;
                        ViewBag.NewCourseTitles = briefs; // list of CourseBrief
                    }
                }
                catch { }
            }

            // Ayrıca query string ile gelen course id'lerini al (fallback, TempData başarısızsa)
            var newCourseIdsQs = Request.QueryString["newCourseIds"];
            if (!string.IsNullOrEmpty(newCourseIdsQs) && (ViewBag.NewCourseTitles == null))
            {
                try
                {
                    var ids = newCourseIdsQs.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries).Select(s => int.TryParse(s, out var v) ? v : 0).Where(v => v > 0).ToList();
                    if (ids.Any())
                    {
                        var briefs = db.Courses.Where(c => ids.Contains(c.CourseId)).Select(c => new gzpegm.Models.CourseBrief { CourseId = c.CourseId, CourseTitle = c.CourseTitle, CoverImage = c.CoverImage, CreatedDate = c.CreatedDate }).ToList();
                        if (briefs != null && briefs.Count > 0)
                        {
                            ViewBag.NewCourseCount = briefs.Count;
                            ViewBag.NewCourseTitles = briefs;
                        }
                    }
                }
                catch { }
            }

            return View(viewModel);
        }
        // NOTE: Landing page client-side teacher request endpoint removed from UI.
        // Provides an endpoint for authenticated users to request to become a teacher.
        // Returns JSON: { status: "notLogin" | "alreadyTeacher" | "alreadyRequested" | "ok" }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult TeacherRequest()
        {
            try
            {
                var user = getuserby();
                if (user == null) return Json(new { status = "notLogin" });

                // If already admin or teacher
                if (!string.IsNullOrEmpty(user.Role) && (user.Role.Equals("Admin", StringComparison.OrdinalIgnoreCase)
                    || user.Role.Equals("Teacher", StringComparison.OrdinalIgnoreCase)))
                {
                    return Json(new { status = "alreadyTeacher" });
                }

                // If already requested and status==0 (pending)
                try
                {
                    var dbUser = db.E_User.Find(user.fldId);
                    if (dbUser == null) return Json(new { status = "notLogin" });

                    if (dbUser.TeacherRequestStatus == 0)
                    {
                        return Json(new { status = "alreadyRequested" });
                    }

                    dbUser.TeacherRequestStatus = 0; // pending
                    dbUser.TeacherRequestDate = DateTime.Now;
                    db.Entry(dbUser).State = EntityState.Modified;
                    db.SaveChanges();

                    return Json(new { status = "ok" });
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Trace.TraceError($"TeacherRequest Error: {ex.Message}");
                    return Json(new { status = "error", message = ex.Message });
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"TeacherRequest Outer Error: {ex.Message}");
                return Json(new { status = "error", message = ex.Message });
            }
        }

        // Aktif kategorileri getir (AJAX için)
        public ActionResult GetActiveCategories()
        {
            try
            {
                var activeCategories = db.Categories
                    .Where(c => c.IsActive)
                    .OrderBy(c => c.CategoryName)
                    .Select(c => new
                    {
                        CategoryId = c.CategoryId,
                        CategoryName = c.CategoryName,
                        CourseCount = c.Courses.Count(course => course.IsActive)
                    })
                    .ToList();

                return Json(activeCategories, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"GetActiveCategories Error: {ex.Message}");
                return Json(new { error = "Kategoriler yüklenirken hata oluştu." }, JsonRequestBehavior.AllowGet);
            }
        }

        // Kategoriye göre kursları getir
        public ActionResult CoursesByCategory(int categoryId, int page = 1, int pageSize = 9)
        {
            try
            {
                var category = db.Categories.Find(categoryId);
                if (category == null || !category.IsActive)
                {
                    TempData["msgError"] = "Kategori bulunamadı.";
                    return RedirectToAction("Index");
                }

                var totalCourses = db.Courses.Count(c => c.CategoryId == categoryId && c.IsActive);
                var totalPages = (int)Math.Ceiling((double)totalCourses / pageSize);

                var courses = db.Courses
                    .Include(c => c.E_User)
                    .Where(c => c.CategoryId == categoryId && c.IsActive)
                    .OrderByDescending(c => c.CreatedDate)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .Select(c => new CourseViewModel
                    {
                        CourseId = c.CourseId,
                        CourseTitle = c.CourseTitle,
                        CourseDescription = c.CourseDescription,
                        CoverImage = c.CoverImage,
                        CreatedDate = c.CreatedDate,
                        CreatedBy = c.CreatedBy,
                        CategoryId = c.CategoryId,
                        CategoryName = c.Categories.CategoryName,
                        ResourceFile = c.ResourceFile
                    })
                    .ToList();

                // Eğitmen bilgilerini ayrı olarak çek (LINQ to Entities sınırlaması nedeniyle)
                foreach (var course in courses)
                {
                    var instructor = db.E_User.Find(course.CreatedBy);
                    course.InstructorName = instructor != null ?
                        $"{instructor.fldName} {instructor.fldLastName}" : "Bilinmeyen Eğitmen";
                }

                ViewBag.CategoryName = category.CategoryName;
                ViewBag.CategoryId = categoryId;
                ViewBag.CurrentPage = page;
                ViewBag.TotalPages = totalPages;
                ViewBag.TotalCourses = totalCourses;

                return View(courses);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"CoursesByCategory Error: {ex.Message}");
                TempData["msgError"] = "Kurslar yüklenirken hata oluştu.";
                return RedirectToAction("Index");
            }
        }

        [HttpGet]
        [Route("Mesaj")]
        public ActionResult PublicMessage()
        {
            if (TempData["PublicMessageSuccess"] != null)
            {
                ViewBag.Success = TempData["PublicMessageSuccess"].ToString();
            }

            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [Route("Mesaj")]
        public ActionResult PublicMessage(
            string name,
            string email,
            string phone,
            string message)
        {
            try
            {
                name = (name ?? "").Trim();
                email = (email ?? "").Trim();
                phone = (phone ?? "").Trim();
                message = (message ?? "").Trim();

                if (string.IsNullOrWhiteSpace(name) ||
                    name.Length < 3 ||
                    name.Length > 100)
                {
                    ViewBag.Error =
                        "Lütfen geçerli bir ad soyad giriniz.";

                    return View();
                }

                if (string.IsNullOrWhiteSpace(email) ||
                    email.Length > 150)
                {
                    ViewBag.Error =
                        "Lütfen geçerli bir e-posta adresi giriniz.";

                    return View();
                }

                try
                {
                    var mailAddress =
                        new System.Net.Mail.MailAddress(email);

                    if (!string.Equals(
                            mailAddress.Address,
                            email,
                            StringComparison.OrdinalIgnoreCase))
                    {
                        ViewBag.Error =
                            "Lütfen geçerli bir e-posta adresi giriniz.";

                        return View();
                    }
                }
                catch
                {
                    ViewBag.Error =
                        "Lütfen geçerli bir e-posta adresi giriniz.";

                    return View();
                }

                if (string.IsNullOrWhiteSpace(phone) ||
                    phone.Length < 7 ||
                    phone.Length > 30 ||
                    !System.Text.RegularExpressions.Regex.IsMatch(
                        phone,
                        @"^[0-9+\s()\-]+$"))
                {
                    ViewBag.Error =
                        "Lütfen geçerli bir telefon numarası giriniz.";

                    return View();
                }

                if (string.IsNullOrWhiteSpace(message) ||
                    message.Length < 10 ||
                    message.Length > 4000)
                {
                    ViewBag.Error =
                        "Mesajınız 10 ile 4000 karakter arasında olmalıdır.";

                    return View();
                }

                // Sistemdeki aktif admini bul.
                var admin = db.E_User
                    .Where(u =>
                        u.Role == "Admin" &&
                        (u.IsActive == null || u.IsActive == true))
                    .OrderBy(u => u.fldId)
                    .FirstOrDefault();

                if (admin == null)
                {
                    System.Diagnostics.Trace.TraceError(
                        "PublicMessage Error: Aktif admin bulunamadı.");

                    ViewBag.Error =
                        "Mesajın iletileceği aktif yönetici bulunamadı.";

                    return View();
                }

                var publicMessage = new E_Messages
                {
                    // Sisteme kayıtlı olmadığı için gönderen kullanıcı ID'si boş.
                    fldSenderId = null,

                    // Mesaj doğrudan aktif admine atanır.
                    fldRecipientId = admin.fldId,

                    fldSendByName = name,
                    fldSendByMail = email,
                    fldSendByPhone = phone,

                    fldDateTime = DateTime.Now,

                    // Konu boş olmadığı için yorum olarak algılanmaz.
                    fldSubject = "Üye Olmadan Gönderilen Mesaj",

                    fldMessage = message,

                    // Sisteme giriş yapmamış kullanıcı.
                    fldSenderRole = "Guest",

                    fldIsRead = false,
                    fldIsDeletedBySender = false,
                    fldIsDeletedByRecipient = false,
                    fldIsReply = false,
                    fldParentMessageId = null,
                    fldIsApproved = false
                };

                db.E_Messages.Add(publicMessage);
                db.SaveChanges();

                TempData["PublicMessageSuccess"] =
                    "Mesajınız yöneticiye başarıyla iletilmiştir.";

                return RedirectToAction("PublicMessage");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(
                    $"PublicMessage Error: {ex}");

                ViewBag.Error =
                    "Mesaj gönderilirken bir hata oluştu. Lütfen tekrar deneyiniz.";

                return View();
            }
        }

        // Gizlilik Politikası Sayfası
        public ActionResult Privacy()
        {
            return View();
        }

        // Kullanım Koşulları Sayfası
        public ActionResult Terms()
        {
            return View();
        }

        // Yardım Merkezi Sayfası
        public ActionResult Help()
        {
            return View();
        }

        // Sık Sorulan Sorular Sayfası
        public ActionResult FAQ()
        {
            return View();
        }

        // ✅ Bekleyen Yorumlar
        public ActionResult PendingComments()
        {
            var currentUser = getuserby();

            if (currentUser == null ||
                !string.Equals(
                    currentUser.Role,
                    "Admin",
                    StringComparison.OrdinalIgnoreCase))
            {
                TempData["msgError"] = "Bu sayfaya erişim yetkiniz yok.";
                return RedirectToAction("Index");
            }

            try
            {
                var allPendingComments = LandingCommentsQuery()
                    .Where(m => m.fldIsApproved == false)
                    .OrderByDescending(m => m.fldDateTime)
                    .AsNoTracking()
                    .ToList();

                ViewBag.TotalRecords = allPendingComments.Count;

                return View(allPendingComments);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(
                    $"PendingComments Error: {ex}");

                TempData["msgError"] =
                    "Bekleyen yorumlar yüklenirken hata oluştu.";

                return RedirectToAction("Index");
            }
        }


        // ✅ Yorumu Onayla
        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult ApproveComment(int id)
        {
            var currentUser = getuserby();

            if (currentUser == null ||
                !string.Equals(
                    currentUser.Role,
                    "Admin",
                    StringComparison.OrdinalIgnoreCase))
            {
                return Json(new
                {
                    success = false,
                    message = "Bu işlem için yetkiniz yok."
                });
            }

            try
            {
                var comment = db.E_Messages.Find(id);

                if (comment == null)
                {
                    return Json(new
                    {
                        success = false,
                        message = "Yorum bulunamadı."
                    });
                }

                bool isLandingComment = LandingCommentsQuery().Any(m => m.fldId == id);
                if (!isLandingComment)
                {
                    return Json(new
                    {
                        success = false,
                        message = "Bu kayıt anasayfa yorumu değil. Özel/toplu mesajlar buradan onaylanamaz."
                    });
                }

                // Zaten onaylanmışsa tekrar işlem yapma
                if (comment.fldIsApproved)
                {
                    return Json(new
                    {
                        success = false,
                        message = "Bu yorum daha önce onaylanmış."
                    });
                }

                // Gönderen kullanıcıyı ID veya sicilden bul
                E_User sender = null;

                if (comment.fldSenderId.HasValue)
                {
                    sender = db.E_User
                        .FirstOrDefault(u =>
                            u.fldId == comment.fldSenderId.Value);
                }

                if (sender == null &&
                    !string.IsNullOrWhiteSpace(comment.fldSendBySicil))
                {
                    sender = db.E_User
                        .FirstOrDefault(u =>
                            u.fldSicil == comment.fldSendBySicil);
                }

                // Admin veya eğitmen mesajıysa onay ekranından işlem yapılmasını engelle
                var senderRole = sender != null
                    ? sender.Role
                    : comment.fldSenderRole;

                if (string.Equals(
                        senderRole,
                        "Admin",
                        StringComparison.OrdinalIgnoreCase) ||
                    string.Equals(
                        senderRole,
                        "Teacher",
                        StringComparison.OrdinalIgnoreCase))
                {
                    // Eski kayıt beklemede kaldıysa doğrudan onaylı hale getir
                    comment.fldIsApproved = true;
                    comment.fldApprovedBy = currentUser.fldId;
                    comment.fldApprovedDateTime = DateTime.Now;

                    db.SaveChanges();

                    return Json(new
                    {
                        success = true,
                        message = "Admin/Eğitmen mesajı otomatik olarak onaylandı."
                    });
                }

                comment.fldIsApproved = true;
                comment.fldApprovedBy = currentUser.fldId;
                comment.fldApprovedDateTime = DateTime.Now;

                db.SaveChanges();

                return Json(new
                {
                    success = true,
                    message = "Yorum başarıyla onaylandı."
                });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(
                    $"ApproveComment Error: {ex}");

                return Json(new
                {
                    success = false,
                    message = "Yorum onaylanırken bir hata oluştu."
                });
            }
        }

        // ✅ YENİ: Yorumu Reddet (AJAX)
        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult RejectComment(int id)
        {
            var currentUser = getuserby();
            if (currentUser == null || (currentUser.Role != "Admin"))
            {
                return Json(new { success = false, message = "Yetkiniz yok." });
            }

            var comment = db.E_Messages.Find(id);
            if (comment == null)
            {
                return Json(new { success = false, message = "Yorum bulunamadı." });
            }

            bool isLandingComment = LandingCommentsQuery().Any(m => m.fldId == id);
            if (!isLandingComment)
            {
                return Json(new
                {
                    success = false,
                    message = "Bu kayıt anasayfa yorumu değil. Özel/toplu mesajlar buradan silinemez."
                });
            }

            try
            {
                db.E_Messages.Remove(comment);
                db.SaveChanges();

                return Json(new { success = true, message = "Yorum reddedildi ve silindi." });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = "Hata: " + ex.Message });
            }
        }
        private class LandingExamAggregates
        {
            public List<LandingExamViewModel> RecentExams { get; set; } = new List<LandingExamViewModel>();
            public LandingExamViewModel MostPopularExam { get; set; }
            public string MostPopularCourse { get; set; } = string.Empty;
            public int MostPopularCourseCount { get; set; }
            public List<LandingExamViewModel> WeeklyExams { get; set; } = new List<LandingExamViewModel>();
            public int TotalExamCount { get; set; }
            public int TotalParticipantCount { get; set; }
            public decimal GlobalAverageScore { get; set; }
            public int TotalExamResults { get; set; }
        }
        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db?.Dispose();
            }
            base.Dispose(disposing);
        }
    }
}
