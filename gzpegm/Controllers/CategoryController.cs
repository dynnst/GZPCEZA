using gzpegm.Cont;
using gzpegm.Helpers;
using gzpegm.Models;
using System;
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
            var categories = db.Categories.OrderBy(x => x.CategoryName).ToList();
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

            // Kategoriye bağlı aktif kurs var mı kontrol et
            var hasActiveCourses = db.Courses.Any(c => c.CategoryId == id && c.IsActive);
            if (hasActiveCourses)
            {
                TempData["msgError"] = "Bu kategoriye bağlı aktif kurslar bulunduğu için silinemez. Önce kursları silin veya başka kategoriye taşıyın.";
                return RedirectToAction("Index");
            }

            // Fiziksel silme yerine pasife çek
            cat.IsActive = false;
            db.SaveChanges();

            TempData["msgSuccess"] = "Kategori pasife alındı.";
            return RedirectToAction("Index");
        }

        // Kategoriyi ve bağlı kursları tamamen sil (DİKKATLİ KULLANIN!)
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

            try
            {
                // Önce kategoriye bağlı kursları sil
                var coursesToDelete = db.Courses.Where(c => c.CategoryId == id).ToList();

                foreach (var course in coursesToDelete)
                {
                    // Kurs içeriklerini sil
                    var contents = db.CourseContents.Where(cc => cc.CourseId == course.CourseId).ToList();
                    db.CourseContents.RemoveRange(contents);

                    // Kurs kayıtlarını sil
                    var enrollments = db.CourseEnrollments.Where(ce => ce.CourseId == course.CourseId).ToList();
                    db.CourseEnrollments.RemoveRange(enrollments);

                    // Kurs değerlendirmelerini sil
                    var reviews = db.CourseReviews.Where(cr => cr.CourseId == course.CourseId).ToList();
                    db.CourseReviews.RemoveRange(reviews);

                    // Dosyaları sil
                    string uploadPath = FileStorageHelper.MapPath(Server, "~/files/Egitim/");
                    if (!string.IsNullOrEmpty(course.CoverImage))
                    {
                        string coverPath = Path.Combine(uploadPath, course.CoverImage);
                        if (System.IO.File.Exists(coverPath)) System.IO.File.Delete(coverPath);
                    }
                    if (!string.IsNullOrEmpty(course.ResourceFile))
                    {
                        string resourcePath = Path.Combine(uploadPath, course.ResourceFile);
                        if (System.IO.File.Exists(resourcePath)) System.IO.File.Delete(resourcePath);
                    }
                }

                // Kursları sil
                db.Courses.RemoveRange(coursesToDelete);

                // Kategoriyi sil
                db.Categories.Remove(cat);
                db.SaveChanges();

                TempData["msgSuccess"] = $"Kategori ve bağlı {coursesToDelete.Count} kurs tamamen silindi.";
            }
            catch (Exception ex)
            {
                TempData["msgError"] = "Silme işlemi sırasında hata oluştu: " + ex.Message;
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
