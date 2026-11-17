using gzpegm.Cont;
using gzpegm.Helpers;
using gzpegm.Models;
using System;
using System.Data.Entity;
using System.IO;
using System.Linq;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize(Users = "2,6")]
    public class CategoryController : Controller
    {
        private GZPEGM1 db = new GZPEGM1();

        // Listeleme
        public ActionResult Index()
        {
            var categories = db.Categories
                .Include(c => c.Courses)
                .OrderBy(x => x.CategoryName)
                .ToList();
            return View(categories);
        }

        // Ekleme
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult AddCategory(string CategoryName, string Description)
        {
            if (string.IsNullOrWhiteSpace(CategoryName))
            {
                TempData["msgError"] = "Kategori adı boş olamaz.";
                return RedirectToAction("Index");
            }

            var exists = db.Categories.Any(x => x.CategoryName == CategoryName);
            if (exists)
            {
                TempData["msgError"] = "Bu kategori zaten mevcut!";
                return RedirectToAction("Index");
            }

            var cat = new Categories
            {
                CategoryName = CategoryName,
                Description = Description,
                IsActive = true
            };

            db.Categories.Add(cat);
            db.SaveChanges();

            TempData["msgSuccess"] = "Kategori başarıyla eklendi.";
            return RedirectToAction("Index");
        }

        // AJAX ile kategori ekleme (DocumentTerms sayfasında kullanılan)
        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult AddCategoryAjax(string categoryName)
        {
            if (string.IsNullOrWhiteSpace(categoryName))
            {
                return Json(new { success = false, message = "Kategori adı boş olamaz." });
            }

            var exists = db.Categories.Any(x => x.CategoryName == categoryName);
            if (exists)
            {
                return Json(new { success = false, message = "Bu kategori zaten mevcut!" });
            }

            try
            {
                var cat = new Categories
                {
                    CategoryName = categoryName,
                    Description = "",
                    IsActive = true
                };

                db.Categories.Add(cat);
                db.SaveChanges();

                return Json(new { success = true, name = categoryName });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = "Hata: " + ex.Message });
            }
        }

        // Düzenleme
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult EditCategory(int CategoryId, string CategoryName, string Description, bool IsActive)
        {
            var cat = db.Categories.Find(CategoryId);
            if (cat == null)
            {
                TempData["msgError"] = "Kategori bulunamadı!";
                return RedirectToAction("Index");
            }

            cat.CategoryName = CategoryName;
            cat.Description = Description;
            cat.IsActive = IsActive;

            db.SaveChanges();

            TempData["msgSuccess"] = "Kategori güncellendi.";
            return RedirectToAction("Index");
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteCategory(int id)
        {
            var cat = db.Categories.Find(id);
            if (cat == null)
            {
                TempData["msgError"] = "Kategori bulunamadı.";
                return RedirectToAction("Index");
            }

            // Eğer pasif yapılmak isteniyorsa, bağlı aktif kurs var mı kontrol et
            if (cat.IsActive)
            {
                var hasActiveCourses = db.Courses.Any(c => c.CategoryId == id && c.IsActive && (c.IsDeleted == null || c.IsDeleted == false));
                if (hasActiveCourses)
                {
                    TempData["msgError"] = "Bu kategoriye bağlı aktif kurslar bulunduğu için pasife alınamaz. Önce kursları pasife alınız.";
                    return RedirectToAction("Index");
                }
                cat.IsActive = false;
                db.SaveChanges();
                TempData["msgSuccess"] = "Kategori başarıyla pasife alındı.";
            }
            else
            {
                cat.IsActive = true;
                db.SaveChanges();
                TempData["msgSuccess"] = "Kategori başarıyla aktifleştirildi.";
            }

            return RedirectToAction("Index");
        }

        // Kategoriyi ve bağlı tüm kursları ilişkili verileriyle birlikte tamamen sil
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ForceDeleteCategory(int id)
        {
            var cat = db.Categories.Find(id);
            if (cat == null)
            {
                TempData["msgError"] = "Kategori bulunamadı.";
                return RedirectToAction("Index");
            }

            using (var transaction = db.Database.BeginTransaction())
            {
                try
                {
                    var coursesToDelete = db.Courses.Where(c => c.CategoryId == id).ToList();
                    var courseIds = coursesToDelete.Select(c => c.CourseId).ToList();

                    if (courseIds.Any())
                    {
                        // A. Sertifikaları temizle
                        var certs = db.Certificate.Where(c => courseIds.Contains(c.CourseId)).ToList();
                        if (certs.Any()) db.Certificate.RemoveRange(certs);

                        var certReqs = db.CertificateRequest.Where(r => courseIds.Contains(r.CourseId)).ToList();
                        if (certReqs.Any()) db.CertificateRequest.RemoveRange(certReqs);

                        // B. Sınavları temizle
                        var exams = db.Exam.Where(e => courseIds.Contains(e.CourseId)).ToList();
                        var examIds = exams.Select(e => e.ExamId).ToList();

                        if (examIds.Any())
                        {
                            var examResults = db.ExamResult.Where(er => examIds.Contains(er.ExamId)).ToList();
                            var examResultIds = examResults.Select(er => er.ExamResultId).ToList();

                            if (examResultIds.Any())
                            {
                                var answers = db.Answer.Where(a => examResultIds.Contains(a.ExamResultId)).ToList();
                                if (answers.Any()) db.Answer.RemoveRange(answers);
                                db.ExamResult.RemoveRange(examResults);
                            }

                            var questions = db.Question.Where(q => examIds.Contains(q.ExamId)).ToList();
                            var questionIds = questions.Select(q => q.QuestionId).ToList();

                            if (questionIds.Any())
                            {
                                var media = db.QuestionMedia.Where(m => questionIds.Contains(m.QuestionId)).ToList();
                                foreach (var m in media)
                                {
                                    if (!string.IsNullOrWhiteSpace(m.MediaPath))
                                    {
                                        var p = m.MediaPath.StartsWith("~/", StringComparison.Ordinal)
                                            ? FileStorageHelper.MapPath(Server, m.MediaPath)
                                            : FileStorageHelper.MapUrlToPhysicalPath(Server, m.MediaPath);
                                        try { if (System.IO.File.Exists(p)) System.IO.File.Delete(p); } catch { }
                                    }
                                }
                                db.QuestionMedia.RemoveRange(media);

                                var options = db.QuestionOption.Where(o => questionIds.Contains(o.QuestionId)).ToList();
                                db.QuestionOption.RemoveRange(options);

                                db.Question.RemoveRange(questions);
                            }

                            db.Exam.RemoveRange(exams);
                        }

                        // C. Yorumlar
                        var reviews = db.CourseReviews.Where(cr => courseIds.Contains(cr.CourseId)).ToList();
                        if (reviews.Any()) db.CourseReviews.RemoveRange(reviews);

                        // D. Kayıtlar
                        var enrollments = db.CourseEnrollments.Where(ce => courseIds.Contains(ce.CourseId)).ToList();
                        if (enrollments.Any()) db.CourseEnrollments.RemoveRange(enrollments);

                        // E. İçerikler
                        string uploadPath = FileStorageHelper.MapPath(Server, "~/files/Egitim/");
                        var contents = db.CourseContents.Where(cc => courseIds.Contains(cc.CourseId)).ToList();
                        foreach (var cc in contents)
                        {
                            if (!string.IsNullOrEmpty(cc.FilePath))
                            {
                                var p = Path.Combine(uploadPath, cc.FilePath);
                                try { if (System.IO.File.Exists(p)) System.IO.File.Delete(p); } catch { }
                            }
                        }
                        if (contents.Any()) db.CourseContents.RemoveRange(contents);

                        // F. Kurs dosyaları
                        foreach (var course in coursesToDelete)
                        {
                            if (!string.IsNullOrEmpty(course.CoverImage))
                            {
                                var p = Path.Combine(uploadPath, course.CoverImage);
                                try { if (System.IO.File.Exists(p)) System.IO.File.Delete(p); } catch { }
                            }
                            if (!string.IsNullOrEmpty(course.ResourceFile))
                            {
                                var p = Path.Combine(uploadPath, course.ResourceFile);
                                try { if (System.IO.File.Exists(p)) System.IO.File.Delete(p); } catch { }
                            }
                        }

                        db.Courses.RemoveRange(coursesToDelete);
                    }

                    // G. Kategoriyi sil
                    db.Categories.Remove(cat);
                    db.SaveChanges();

                    transaction.Commit();

                    TempData["msgSuccess"] = $"Kategori ve bağlı {coursesToDelete.Count} ders kalıcı olarak başarıyla silindi.";
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    TempData["msgError"] = "Kategori silinirken bir hata oluştu: " + ex.Message;
                }
            }

            return RedirectToAction("Index");
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing) db?.Dispose();
            base.Dispose(disposing);
        }
    }
}
