using gzpegm.Cont;
using gzpegm.Helpers;
using gzpegm.Models;
using System;
using System.Data.Entity.Validation;
using System.IO;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize(Users = "2,6")]
    public class DocumentTermsController : Controller
    {
        private GZPEGM1 db = new GZPEGM1();

        // Kullanıcı bilgisi alma
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

        public ActionResult Index(string q = null)
        {
            // Oturum açan kullanıcıyı al
            var currentUser = GetCurrentUser();
            if (currentUser == null)
            {
                TempData["ErrorMessage"] = "Lütfen sisteme giriş yapın.";
                return RedirectToAction("Index", "Giris");
            }

            var set = db.Set<DocumentTerms>().AsQueryable();

            // Admin ise tüm terimleri görsün, diğer kullanıcılar sadece kendi eklediklerini (Sicil'e göre) görsün
            if (!string.Equals(currentUser.Role, "Admin", StringComparison.OrdinalIgnoreCase))
            {
                var sicil = (currentUser.fldSicil ?? "").Trim();
                set = set.Where(x => ((x.Sicil ?? "").Trim() == sicil));
            }

            if (!string.IsNullOrWhiteSpace(q))
            {
                string temiz = q.Trim();
                set = set.Where(x =>
                    (x.Term ?? "").Contains(temiz) ||
                    (x.Slug ?? "").Contains(temiz) ||
                    (x.Category ?? "").Contains(temiz) ||
                    (x.Definition ?? "").Contains(temiz));
            }

            var list = set.OrderByDescending(x => x.Id).ToList();

            if (TempData["SuccessMessage"] != null)
            {
                ViewBag.SuccessMessage = TempData["SuccessMessage"];
            }
            if (TempData["ErrorMessage"] != null)
            {
                ViewBag.ErrorMessage = TempData["ErrorMessage"];
            }

            return View(list);
        }

        public ActionResult Details(int? id)
        {
            if (id == null) return new HttpStatusCodeResult(400);
            var item = db.Set<DocumentTerms>().Find(id);
            if (item == null) return HttpNotFound();
            return View(item);
        }

        public ActionResult Create()
        {
            LoadCategories();
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [ValidateInput(false)]
        public ActionResult Create(DocumentTerms model, HttpPostedFileBase imageFile = null, string ImageUrl = null)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(model.Category))
                {
                    ModelState.AddModelError("Category", "Kategori seçilmelidir.");
                    LoadCategories();
                    return View(model);
                }

                if (string.IsNullOrWhiteSpace(model.Term))
                {
                    ModelState.AddModelError("Term", "Terim adı zorunludur.");
                    LoadCategories();
                    return View(model);
                }

                if (string.IsNullOrWhiteSpace(model.Definition))
                {
                    ModelState.AddModelError("Definition", "Tanım zorunludur.");
                    LoadCategories();
                    return View(model);
                }

                if (string.IsNullOrWhiteSpace(model.Slug))
                {
                    model.Slug = GenerateSlug(model.Term);
                }

                string finalImageUrl = null;

                if (imageFile != null && imageFile.ContentLength > 0)
                {
                    finalImageUrl = SaveFile(imageFile);
                    if (finalImageUrl == null)
                    {
                        ModelState.AddModelError("", "Resim yükleme başarısız veya desteklenmeyen format.");
                        LoadCategories();
                        return View(model);
                    }
                }
                else if (!string.IsNullOrWhiteSpace(ImageUrl))
                {
                    if (Uri.TryCreate(ImageUrl.Trim(), UriKind.Absolute, out Uri uriResult) &&
                        (uriResult.Scheme == Uri.UriSchemeHttp || uriResult.Scheme == Uri.UriSchemeHttps))
                    {
                        finalImageUrl = ImageUrl.Trim();
                    }
                    else
                    {
                        ModelState.AddModelError("", "Resim URL'si geçerli değil.");
                        LoadCategories();
                        return View(model);
                    }
                }

                model.ImageUrl = finalImageUrl;
                model.CreatedAt = DateTime.Now;
                model.UpdatedAt = null;

                // ✅ Oturum açan kullanıcı bilgisini al ve kaydet
                var currentUser = GetCurrentUser();
                if (currentUser != null)
                {
                    model.AdSoyad = $"{currentUser.fldName} {currentUser.fldLastName}".Trim();
                    model.Sicil = currentUser.fldSicil?.Trim();
                }

                db.Set<DocumentTerms>().Add(model);
                db.SaveChanges();

                TempData["SuccessMessage"] = "Terim başarıyla eklendi.";
                return RedirectToAction("Index");
            }
            catch (DbEntityValidationException ex)
            {
                var errorMessages = new System.Text.StringBuilder();
                foreach (var validationErrors in ex.EntityValidationErrors)
                {
                    foreach (var validationError in validationErrors.ValidationErrors)
                    {
                        errorMessages.AppendLine($"{validationError.PropertyName}: {validationError.ErrorMessage}");
                    }
                }
                ModelState.AddModelError("", "Veritabanı Hatası: " + errorMessages.ToString());
                LoadCategories();
                return View(model);
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("", "Hata: " + ex.Message);
                LoadCategories();
                return View(model);
            }
        }

        public ActionResult Edit(int? id)
        {
            if (id == null)
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);

            var item = db.Set<DocumentTerms>().Find(id);
            if (item == null)
                return HttpNotFound();

            LoadCategories();
            return View(item);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [ValidateInput(false)]
        public ActionResult Edit(DocumentTerms model, HttpPostedFileBase imageFile = null, string removeImage = null)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(model.Category))
                {
                    ModelState.AddModelError("Category", "Kategori seçilmelidir.");
                    LoadCategories();
                    return View(model);
                }

                var item = db.Set<DocumentTerms>().Find(model.Id);
                if (item == null)
                    return HttpNotFound();

                item.Term = model.Term?.Trim();

                if (string.IsNullOrWhiteSpace(model.Slug) || item.Term != model.Term)
                {
                    item.Slug = GenerateSlug(model.Term);
                }
                else
                {
                    item.Slug = model.Slug?.Trim();
                }

                item.Category = model.Category.Trim();
                item.Definition = model.Definition?.Trim();
                item.DetailedDescription = model.DetailedDescription?.Trim();
                item.RelatedTerms = model.RelatedTerms?.Trim();
                item.IsActive = model.IsActive;
                item.UpdatedAt = DateTime.Now;

                if (imageFile != null && imageFile.ContentLength > 0)
                {
                    var newUrl = SaveFile(imageFile);
                    if (newUrl != null)
                    {
                        if (!string.IsNullOrWhiteSpace(item.ImageUrl))
                            DeletePhysicalFile(item.ImageUrl);
                        item.ImageUrl = newUrl;
                    }
                }
                else if (removeImage == "1" && !string.IsNullOrWhiteSpace(item.ImageUrl))
                {
                    DeletePhysicalFile(item.ImageUrl);
                    item.ImageUrl = null;
                }

                db.SaveChanges();
                TempData["SuccessMessage"] = "Terim başarıyla güncellendi.";
                return RedirectToAction("Index");
            }
            catch (DbEntityValidationException ex)
            {
                var errorMessages = new System.Text.StringBuilder();
                foreach (var validationErrors in ex.EntityValidationErrors)
                {
                    foreach (var validationError in validationErrors.ValidationErrors)
                    {
                        errorMessages.AppendLine($"{validationError.PropertyName}: {validationError.ErrorMessage}");
                    }
                }
                TempData["ErrorMessage"] = "Veritabanı Hatası: " + errorMessages.ToString();
                LoadCategories();
                return View(model);
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = "Hata: " + ex.Message;
                LoadCategories();
                return View(model);
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult Delete(int id)
        {
            try
            {
                var item = db.Set<DocumentTerms>().Find(id);
                if (item == null)
                    return Json(new { success = false, message = "Kayıt bulunamadı." });

                if (!string.IsNullOrWhiteSpace(item.ImageUrl))
                    DeletePhysicalFile(item.ImageUrl);

                db.Set<DocumentTerms>().Remove(item);
                db.SaveChanges();

                return Json(new { success = true, message = "Terim başarıyla silindi." });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = "Silme hatası: " + ex.Message });
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult AddCategory(string categoryName)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(categoryName))
                    return Json(new { success = false, message = "Kategori adı boş olamaz." });

                categoryName = categoryName.Trim();

                var exists = db.Categories.Any(x => x.CategoryName.ToLower() == categoryName.ToLower());
                if (exists)
                    return Json(new { success = false, message = "Bu kategori zaten mevcut!" });

                var newCategory = new Categories
                {
                    CategoryName = categoryName,
                    IsActive = true
                };

                db.Categories.Add(newCategory);
                db.SaveChanges();

                return Json(new { success = true, message = "Kategori başarıyla eklendi.", id = newCategory.CategoryId, name = newCategory.CategoryName });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = "Hata: " + ex.Message });
            }
        }

        [HttpGet]
        public JsonResult GetCategories()
        {
            try
            {
                var categories = db.Categories
                    .Where(x => x.IsActive)
                    .OrderBy(x => x.CategoryName)
                    .Select(x => new { id = x.CategoryId, name = x.CategoryName })
                    .ToList();

                return Json(new { success = true, categories = categories }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult UploadImage(HttpPostedFileBase file)
        {
            try
            {
                if (file == null || file.ContentLength == 0)
                    return Json(new { success = false, message = "Dosya boş" });

                var ext = Path.GetExtension(file.FileName).ToLower();
                var allowed = new[] { ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp" };

                if (!allowed.Contains(ext))
                    return Json(new { success = false, message = "Desteklenmeyen dosya türü" });

                if (file.ContentLength > 5 * 1024 * 1024)
                    return Json(new { success = false, message = "Dosya çok büyük (Max 5MB)" });

                var fileName = Guid.NewGuid().ToString() + ext;
                var uploadPath = FileStorageHelper.MapPath(Server, "~/Uploads/DocumentTerms/");

                if (!Directory.Exists(uploadPath))
                    Directory.CreateDirectory(uploadPath);

                var fullPath = Path.Combine(uploadPath, fileName);
                file.SaveAs(fullPath);

                var fileUrl = $"/Uploads/DocumentTerms/{fileName}";

                return Json(new { success = true, url = fileUrl });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message });
            }
        }

        #region Yardımcı Metotlar

        private void LoadCategories()
        {
            var categories = db.Categories
                .Where(x => x.IsActive)
                .OrderBy(x => x.CategoryName)
                .Select(x => x.CategoryName)
                .ToList();

            ViewBag.Categories = categories;
        }

        private string GenerateSlug(string text)
        {
            if (string.IsNullOrWhiteSpace(text))
                return null;

            string slug = text.Trim().ToLower();

            var turkishMap = new System.Collections.Generic.Dictionary<char, char>
            {
                { 'ç', 'c' }, { 'ğ', 'g' }, { 'ı', 'i' }, { 'ö', 'o' }, { 'ş', 's' }, { 'ü', 'u' },
                { 'Ç', 'c' }, { 'Ğ', 'g' }, { 'İ', 'i' }, { 'Ö', 'o' }, { 'Ş', 's' }, { 'Ü', 'u' }
            };

            foreach (var pair in turkishMap)
            {
                slug = slug.Replace(pair.Key, pair.Value);
            }

            slug = System.Text.RegularExpressions.Regex.Replace(slug, @"[^a-z0-9\s-]", "");
            slug = System.Text.RegularExpressions.Regex.Replace(slug, @"\s+", "-");
            slug = System.Text.RegularExpressions.Regex.Replace(slug, @"-+", "-");
            slug = slug.Trim('-');

            return slug.Length > 0 ? slug : null;
        }

        private string SaveFile(HttpPostedFileBase file)
        {
            try
            {
                if (file == null || file.ContentLength == 0 || file.ContentLength > 5 * 1024 * 1024)
                    return null;

                var ext = Path.GetExtension(file.FileName).ToLower();
                var allowed = new[] { ".jpg", ".jpeg", ".png", ".webp", ".gif", ".bmp" };
                if (!allowed.Contains(ext))
                    return null;

                var safeFileName = Path.GetFileNameWithoutExtension(file.FileName)
                    .Replace(" ", "-").Replace("_", "-");

                foreach (var c in Path.GetInvalidFileNameChars())
                    safeFileName = safeFileName.Replace(c.ToString(), "");

                var uniqueName = $"{safeFileName}_{Guid.NewGuid():N}{ext}";
                var uploadPath = FileStorageHelper.MapPath(Server, "~/Uploads/DocumentTerms/");

                if (!Directory.Exists(uploadPath))
                {
                    Directory.CreateDirectory(uploadPath);
                }

                var fullPath = Path.Combine(uploadPath, uniqueName);
                file.SaveAs(fullPath);

                return $"/Uploads/DocumentTerms/{uniqueName}";
            }
            catch
            {
                return null;
            }
        }

        private void DeletePhysicalFile(string url)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(url) || !url.StartsWith("/Uploads/DocumentTerms/"))
                    return;

                var physicalPath = FileStorageHelper.MapUrlToPhysicalPath(Server, url);
                if (System.IO.File.Exists(physicalPath))
                    System.IO.File.Delete(physicalPath);
            }
            catch
            {
                // Sessiz hata
            }
        }

        #endregion

        protected override void Dispose(bool disposing)
        {
            if (disposing)
                db.Dispose();
            base.Dispose(disposing);
        }
    }
}
