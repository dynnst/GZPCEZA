using gzpegm.Cont;
using gzpegm.Helpers;
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
    [UserAuthorize(Users = "2,6")]
    public class ExamController : Controller
    {
        private GZPEGM1 db = new GZPEGM1();

        // Kullanıcı bilgisi alma - CourseController ile aynı
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

        private bool HasAccessToPage(E_User user)
        {
            if (user == null) return false;
            if (string.IsNullOrWhiteSpace(user.Role)) return false;

            return user.Role.Equals("Admin", StringComparison.OrdinalIgnoreCase)
                || user.Role.Equals("Teacher", StringComparison.OrdinalIgnoreCase);
        }

        private bool CanModifyExam(E_User user, Exam exam)
        {
            if (user == null || exam == null || string.IsNullOrWhiteSpace(user.Role))
                return false;

            if (user.Role.Equals("Admin", StringComparison.OrdinalIgnoreCase))
                return true;

            if (user.Role.Equals("Teacher", StringComparison.OrdinalIgnoreCase))
            {
                return db.Courses.Any(c => c.CourseId == exam.CourseId && c.CreatedBy == user.fldId);
            }

            return false;
        }

        private void DeleteQuestionMediaFiles(IEnumerable<QuestionMedia> mediaFiles)
        {
            foreach (var media in mediaFiles)
            {
                var path = media.MediaPath != null && media.MediaPath.StartsWith("~/", StringComparison.Ordinal)
                    ? FileStorageHelper.MapPath(Server, media.MediaPath)
                    : FileStorageHelper.MapUrlToPhysicalPath(Server, media.MediaPath);

                if (path != null && System.IO.File.Exists(path))
                    System.IO.File.Delete(path);
            }
        }

        public ActionResult Index(int? editExamId = null)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null)
                {
                    TempData["msgError"] = "Lütfen sisteme giriş yapın.";
                    return RedirectToAction("Login", "Account");
                }

                if (!HasAccessToPage(user))
                {
                    TempData["msgError"] = "Bu sayfaya erişim yetkiniz yok.";
                    return RedirectToAction("Index", "Home");
                }

                // Rol bazlı sınav sorgusu
                IQueryable<Exam> examQuery = db.Exam.Where(e => e.IsArchived != true);

                if (user.Role == "Teacher")
                {
                    // Öğretmen sadece kendi oluşturduğu kursların sınavlarını görsün
                    examQuery = from e in db.Exam
                                join c in db.Courses on e.CourseId equals c.CourseId
                                where c.CreatedBy == user.fldId && e.IsArchived != true
                                select e;
                }

                var exams = (from e in examQuery
                             join c in db.Courses on e.CourseId equals c.CourseId
                             join u in db.E_User on c.CreatedBy equals u.fldId
                             select new ExamViewModel
                             {
                                 ExamId = e.ExamId,
                                 ExamTitle = e.Title,
                                 ExamDescription = e.Description,
                                 CourseId = e.CourseId,
                                 CourseTitle = c.CourseTitle,
                                 CourseCoverImage = c.CoverImage,
                                 CourseCreatorFullName = u.fldName + " " + u.fldLastName,
                                 Duration = e.DurationMinutes ?? 0,
                                 PassingScore = e.PassingScore ?? 0,
                                 IsActive = e.IsActive,
                                 CreatedDate = e.CreatedAt,
                                 QuestionCount = db.Question.Count(q => q.ExamId == e.ExamId)
                             })
                             .OrderBy(e => e.ExamTitle)
                             .ToList();

                // ViewBag.Courses: Rol bazlı kurs listesi (tip güvenli)
                if (user.Role == "Teacher")
                {
                    ViewBag.Courses = (from c in db.Courses
                                       join u in db.E_User on c.CreatedBy equals u.fldId
                                       where c.IsDeleted != true && c.CreatedBy == user.fldId
                                       select new ExamViewModel
                                       {
                                           CourseId = c.CourseId,
                                           CourseTitle = c.CourseTitle,
                                           CourseCreatorFullName = u.fldName + " " + u.fldLastName
                                       }).ToList();
                }
                else
                {
                    ViewBag.Courses = (from c in db.Courses
                                       join u in db.E_User on c.CreatedBy equals u.fldId
                                       where c.IsDeleted != true
                                       select new ExamViewModel
                                       {
                                           CourseId = c.CourseId,
                                           CourseTitle = c.CourseTitle,
                                           CourseCreatorFullName = u.fldName + " " + u.fldLastName
                                       }).ToList();
                }

                ViewBag.EditExamId = editExamId;
                return View(exams);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Exam Index Error: {ex.Message}");
                TempData["msgError"] = "Sınavlar yüklenirken bir hata oluştu.";
                return View(new List<ExamViewModel>());
            }
        }
        // ---------------- CREATE ----------------
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(ExamViewModel model)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null) { TempData["msgError"] = "Kullanıcı bilgisi bulunamadı."; return RedirectToAction("Index"); }
                if (!HasAccessToPage(user)) { TempData["msgError"] = "Yetkiniz yok."; return RedirectToAction("Index"); }
                if (!ModelState.IsValid) { TempData["msgError"] = "Geçersiz veri."; return RedirectToAction("Index"); }

                // Seçilen kurs öğretmenin kendi kursu mu kontrol et
                var course = db.Courses.Find(model.CourseId);
                if (course == null || (user.Role == "Teacher" && course.CreatedBy != user.fldId))
                {
                    TempData["msgError"] = "Seçilen kurs için sınav oluşturma yetkiniz yok.";
                    return RedirectToAction("Index");
                }

                var exam = new Exam
                {
                    Title = model.ExamTitle,
                    Description = model.ExamDescription,
                    CourseId = model.CourseId,
                    DurationMinutes = model.Duration,
                    PassingScore = model.PassingScore,
                    IsActive = true,
                    CreatedAt = DateTime.Now,
                    IsArchived = false
                };

                db.Exam.Add(exam);
                db.SaveChanges();

                TempData["msgSuccess"] = "Sınav başarıyla eklendi.";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Exam Create Error: {ex.Message}");
                TempData["msgError"] = "Sınav eklenirken bir hata oluştu: " + ex.Message;
            }
            return RedirectToAction("Index");
        }
        // ---------------- EDIT ----------------
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(ExamViewModel model)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null) { TempData["msgError"] = "Kullanıcı bilgisi bulunamadı."; return RedirectToAction("Index"); }
                if (!HasAccessToPage(user)) { TempData["msgError"] = "Yetkiniz yok."; return RedirectToAction("Index"); }
                if (!ModelState.IsValid) { TempData["msgError"] = "Geçersiz veri."; return RedirectToAction("Index"); }

                var exam = db.Exam.Find(model.ExamId);
                if (exam == null) { TempData["msgError"] = "Sınav bulunamadı."; return RedirectToAction("Index"); }
                if (!CanModifyExam(user, exam)) { TempData["msgError"] = "Bu sınavı düzenleme yetkiniz yok."; return RedirectToAction("Index"); }

                var selectedCourse = db.Courses.Find(model.CourseId);
                if (selectedCourse == null || (user.Role == "Teacher" && selectedCourse.CreatedBy != user.fldId))
                {
                    TempData["msgError"] = "Seçilen kurs için sınav düzenleme yetkiniz yok.";
                    return RedirectToAction("Index");
                }

                exam.Title = model.ExamTitle;
                exam.Description = model.ExamDescription;
                exam.CourseId = model.CourseId;
                exam.DurationMinutes = model.Duration;
                exam.PassingScore = model.PassingScore;

                db.Entry(exam).State = EntityState.Modified;
                db.SaveChanges();

                TempData["msgSuccess"] = "Sınav başarıyla güncellendi.";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Exam Edit Error: {ex.Message}");
                TempData["msgError"] = "Sınav güncellenirken bir hata oluştu: " + ex.Message;
            }
            return RedirectToAction("Index");
        }

        // ---------------- DELETE ----------------
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(int id)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null) { TempData["msgError"] = "Kullanıcı bilgisi bulunamadı."; return RedirectToAction("Index"); }
                if (!HasAccessToPage(user)) { TempData["msgError"] = "Yetkiniz yok."; return RedirectToAction("Index"); }

                var exam = db.Exam.Find(id);
                if (exam == null) { TempData["msgError"] = "Sınav bulunamadı!"; return RedirectToAction("Index"); }
                if (!CanModifyExam(user, exam)) { TempData["msgError"] = "Bu sınavı silme yetkiniz yok."; return RedirectToAction("Index"); }

                var questionIds = db.Question
                    .Where(q => q.ExamId == id)
                    .Select(q => q.QuestionId)
                    .ToList();

                bool hasExamResults = db.ExamResult.Any(r => r.ExamId == id);
                bool hasAnswers = questionIds.Any() && db.Answer.Any(a => questionIds.Contains(a.QuestionId));

                if (hasExamResults || hasAnswers)
                {
                    exam.IsActive = false;
                    exam.IsArchived = true;
                    db.Entry(exam).State = EntityState.Modified;
                    db.SaveChanges();

                    TempData["msgWarning"] = "Bu sınava ait cevap/sonuç kayıtları olduğu için fiziksel silinmedi; sınav arşivlendi ve öğrenci tarafında gizlendi.";
                    return RedirectToAction("Index");
                }

                using (var tx = db.Database.BeginTransaction())
                {
                    try
                    {
                        if (questionIds.Any())
                        {
                            var mediaFiles = db.QuestionMedia.Where(m => questionIds.Contains(m.QuestionId)).ToList();
                            DeleteQuestionMediaFiles(mediaFiles);
                            db.QuestionMedia.RemoveRange(mediaFiles);

                            var options = db.QuestionOption.Where(o => questionIds.Contains(o.QuestionId)).ToList();
                            db.QuestionOption.RemoveRange(options);

                            var questions = db.Question.Where(q => q.ExamId == id).ToList();
                            db.Question.RemoveRange(questions);
                        }

                        db.Exam.Remove(exam);
                        db.SaveChanges();
                        tx.Commit();
                    }
                    catch
                    {
                        tx.Rollback();
                        throw;
                    }
                }

                TempData["msgSuccess"] = "Sınav başarıyla silindi.";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Exam Delete Error: {ex.Message}");
                TempData["msgError"] = "Sınav silinirken bir hata oluştu: " + ex.Message;
            }
            return RedirectToAction("Index");
        }

        // ---------------- TOGGLE STATUS ----------------
        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult ToggleStatus(int id)
        {
            var user = GetCurrentUser();
            if (user == null || !HasAccessToPage(user))
                return Json(new { success = false, message = "Yetkiniz yok." });

            var exam = db.Exam.Find(id);
            if (exam != null)
            {
                if (!CanModifyExam(user, exam))
                    return Json(new { success = false, message = "Bu sınavın durumunu değiştirme yetkiniz yok." });
                if (exam.IsArchived == true)
                    return Json(new { success = false, message = "Arşivlenmiş sınavın durumu değiştirilemez." });

                exam.IsActive = !exam.IsActive;
                db.SaveChanges();
                return Json(new { success = true, isActive = exam.IsActive });
            }

            return Json(new { success = false, message = "Sınav bulunamadı." });
        }

        [HttpGet]
        public JsonResult GetExam(int id)
        {
            var user = GetCurrentUser();
            if (user == null || !HasAccessToPage(user))
                return Json(new { success = false, message = "Yetkiniz yok." }, JsonRequestBehavior.AllowGet);

            var exam = db.Exam.Find(id);
            if (exam == null)
                return Json(new { success = false, message = "Sınav bulunamadı." }, JsonRequestBehavior.AllowGet);

            if (!CanModifyExam(user, exam))
                return Json(new { success = false, message = "Bu sınavı düzenleme yetkiniz yok." }, JsonRequestBehavior.AllowGet);

            return Json(new
            {
                success = true,
                examId = exam.ExamId,
                examTitle = exam.Title,
                examDescription = exam.Description,
                courseId = exam.CourseId,
                duration = exam.DurationMinutes ?? 60,
                passingScore = exam.PassingScore ?? 60,
                isActive = exam.IsActive
            }, JsonRequestBehavior.AllowGet);
        }

        // ---------------- GET EXAM RESULTS (Admin / Teacher) ----------------
        public ActionResult Results(int id)
        {
            var user = GetCurrentUser();
            if (user == null)
            {
                TempData["msgError"] = "Sonuçları görüntülemek için giriş yapmalısınız.";
                return RedirectToAction("Login", "Account");
            }

            if (!HasAccessToPage(user))
            {
                TempData["msgError"] = "Bu sayfaya erişim yetkiniz yok.";
                return RedirectToAction("Index");
            }

            var exam = db.Exam.Find(id);
            if (exam == null)
            {
                TempData["msgError"] = "Sınav bulunamadı.";
                return RedirectToAction("Index");
            }

            // Öğretmen ise sadece kendi oluşturduğu kursa ait sınavların sonuçlarını görebilsin
            var course = db.Courses.Find(exam.CourseId);
            if (user.Role == "Teacher" && (course == null || course.CreatedBy != user.fldId))
            {
                TempData["msgError"] = "Bu sınavın sonuçlarını görme yetkiniz yok.";
                return RedirectToAction("Index");
            }

            int maxScore = db.Question.Where(q => q.ExamId == id).Sum(q => (int?)q.Points) ?? 0;

            // Sorguyu önce veritabanında çek, sonra in-memory dönüştür
            var rawResults = (from er in db.ExamResult
                              join u in db.E_User on er.UserId equals u.fldId into uj
                              from u in uj.DefaultIfEmpty()
                              where er.ExamId == id && er.Status == 1
                              orderby er.FinishedAt descending
                              select new
                              {
                                  er.ExamResultId,
                                  er.UserId,
                                  UserName = (u != null ? (u.fldName + " " + u.fldLastName) : "—"),
                                  er.Score,
                                  er.StartedAt,
                                  er.FinishedAt
                              }).ToList();

            var results = rawResults.Select(r =>
            {
                double perc = maxScore > 0 ? Math.Round(((double)(r.Score ?? 0) / maxScore) * 100, 1) : 0;
                return new ExamResultListItemViewModel
                {
                    ExamResultId = r.ExamResultId,
                    UserId = r.UserId,
                    UserFullName = r.UserName,
                    TotalScore = (int?)(r.Score) ?? 0,
                    MaxScore = maxScore,
                    Percentage = perc,
                    IsPassed = perc >= (exam.PassingScore ?? 60),
                    StartTime = r.StartedAt,
                    EndTime = r.FinishedAt,
                    Duration = (r.StartedAt.HasValue && r.FinishedAt.HasValue) ? (r.FinishedAt.Value - r.StartedAt.Value) : TimeSpan.Zero
                };
            }).ToList();

            ViewBag.ExamTitle = exam.Title;
            return View(results);
        }
        // ---------------- GET EXAM DETAILS ----------------
        public ActionResult Details(int id)
        {
            var user = GetCurrentUser();
            if (user == null) return RedirectToAction("Login", "Account");

            // JOIN kullanarak detayları al
            var examDetails = (from e in db.Exam
                               join c in db.Courses on e.CourseId equals c.CourseId
                               where e.ExamId == id
                               select new ExamViewModel
                               {
                                   ExamId = e.ExamId,
                                   ExamTitle = e.Title,
                                   ExamDescription = e.Description,
                                   CourseId = e.CourseId,
                                   CourseTitle = c.CourseTitle,
                                   Duration = e.DurationMinutes ?? 0,
                                   PassingScore = e.PassingScore ?? 0,
                                   IsActive = e.IsActive,
                                   QuestionCount = db.Question.Count(q => q.ExamId == e.ExamId)
                               }).FirstOrDefault();

            if (examDetails == null)
            {
                TempData["msgError"] = "Sınav bulunamadı.";
                return RedirectToAction("Index");
            }

            var exam = db.Exam.Find(id);
            if (!CanModifyExam(user, exam))
            {
                TempData["msgError"] = "Bu sınav detayını görüntüleme yetkiniz yok.";
                return RedirectToAction("Index");
            }

            return View(examDetails);
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing) db?.Dispose();
            base.Dispose(disposing);
        }
    }
}