using Ganss.Xss;
using gzpegm.Cont;
using gzpegm.Helpers;
using gzpegm.Models;
using gzpegm.Models.ViewModels;
using gzpegm.Services;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    public class CourseController : Controller
    {
        private GZPEGM1 db = new GZPEGM1();
        private EmailService emailService = new EmailService();
        private Services.MessageService messageService = new Services.MessageService();

        private readonly string[] ALLOWED_IMAGE_EXTENSIONS = { ".jpg", ".jpeg", ".png", ".gif", ".bmp" };
        private readonly string[] ALLOWED_RESOURCE_EXTENSIONS = {
            ".pdf", ".doc", ".docx", ".ppt", ".pptx", ".xls", ".xlsx", ".zip", ".rar",
            ".mp4", ".avi", ".mov", ".wmv", ".flv", ".webm", ".mkv", ".m4v", ".3gp",
            // image uzantıları resource olarak da kabul edilsin
            ".jpg", ".jpeg", ".png", ".gif", ".bmp",
            ".html", ".htm"
        };
        private readonly string UPLOAD_PATH = "~/files/Egitim/";

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

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult UpdateTitle(int id, string CourseTitle)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null) { TempData["msgError"] = "Kullanıcı bilgisi bulunamadı."; return RedirectToAction("Details", new { id = id }); }
                var course = db.Courses.Find(id);
                if (course == null) { TempData["msgError"] = "Kurs bulunamadı."; return RedirectToAction("Index"); }
                if (!CanModifyCourse(user, course)) { TempData["msgError"] = "Bu işlemi yapmaya yetkiniz yok."; return RedirectToAction("Details", new { id = id }); }
                if (string.IsNullOrWhiteSpace(CourseTitle))
                {
                    TempData["msgError"] = "Başlık boş olamaz.";
                    TempData["msgWarningTitleMissing"] = "Lütfen kurs için geçerli bir başlık giriniz.";
                    return RedirectToAction("Details", new { id = id });
                }
                if (CourseTitle.Trim().Length > 300)
                {
                    TempData["msgError"] = "Kurs başlığı en fazla 300 karakter olabilir.";
                    TempData["msgWarningTitleMissing"] = "Lütfen daha kısa bir kurs başlığı giriniz.";
                    return RedirectToAction("Details", new { id = id });
                }
                course.CourseTitle = CourseTitle.Trim();
                db.Entry(course).State = EntityState.Modified;
                db.SaveChanges();
                TempData["msgSuccess"] = "Kurs başlığı güncellendi.";
                return RedirectToAction("Details", new { id = id });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"UpdateTitle Error: {ex.Message}");
                TempData["msgError"] = "Başlık güncellenirken hata oluştu.";
                return RedirectToAction("Details", new { id = id });
            }
        }
        // Aşağıdaki action'ı mevcut CourseController sınıfınızın içine uygun bir yere ekleyin.
        public ActionResult InstructorCourses(int teacherId, int page = 1)
        {
            try
            {
                var instructor = db.E_User.Find(teacherId);
                ViewBag.InstructorName = instructor != null ? (instructor.fldName + " " + instructor.fldLastName) : "Eğitmen";

                var courses = db.Courses
                                .Include(c => c.Categories)
                                .Where(c => c.IsActive && c.CreatedBy == teacherId)
                                .OrderByDescending(c => c.CreatedDate)
                                .Select(c => new CourseViewModel
                                {
                                    CourseId = c.CourseId,
                                    CourseTitle = c.CourseTitle,
                                    CourseDescription = c.CourseDescription,
                                    CoverImage = c.CoverImage,
                                    CreatedBy = c.CreatedBy,
                                    CreatedDate = c.CreatedDate,
                                    CategoryId = c.CategoryId,
                                    CategoryName = c.Categories.CategoryName,
                                    ResourceFile = c.ResourceFile
                                })
                                .ToList();

                // Basit sayfalandırma (opsiyonel)
                int pageSize = 9;
                int total = courses.Count;
                var paged = courses.Skip((page - 1) * pageSize).Take(pageSize).ToList();

                ViewBag.CurrentPage = page;
                ViewBag.TotalPages = (int)System.Math.Ceiling((double)total / pageSize);

                return View(paged);
            }
            catch (System.Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"InstructorCourses Error: {ex.Message}");
                TempData["msgError"] = "Eğitmen kursları yüklenirken hata oluştu.";
                return RedirectToAction("Index", "Landing");
            }
        }
        private string GetUploadPath()
        {
            string path = FileStorageHelper.MapPath(Server, UPLOAD_PATH);
            if (!path.EndsWith(Path.DirectorySeparatorChar.ToString()))
                path += Path.DirectorySeparatorChar;
            if (!Directory.Exists(path))
                Directory.CreateDirectory(path);
            return path;
        }

        private string SecureFileUpload(HttpPostedFileBase file, string uploadPath, string[] allowedExtensions, string fileType)
        {
            if (file == null || file.ContentLength == 0) return null;

            int maxFileSize = fileType.Contains("video") || IsVideoFile(file.FileName) ? 100 * 1024 * 1024 : 10 * 1024 * 1024;
            if (file.ContentLength > maxFileSize)
            {
                string sizeLimit = fileType.Contains("video") ? "100MB" : "10MB";
                throw new Exception($"{fileType} boyutu {sizeLimit}'tan büyük olamaz!");
            }

            string fileExtension = Path.GetExtension(file.FileName).ToLower();
            if (string.IsNullOrEmpty(fileExtension) || !allowedExtensions.Contains(fileExtension))
                throw new Exception($"Geçersiz {fileType} türü! İzin verilen uzantılar: {string.Join(", ", allowedExtensions)}");

            string safeFileName = $"{Guid.NewGuid()}_{Path.GetFileName(file.FileName)}";
            string fullPath = Path.Combine(uploadPath, safeFileName);

            fullPath = Path.GetFullPath(fullPath);
            var uploadRoot = Path.GetFullPath(uploadPath.TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar));
            if (!uploadRoot.EndsWith(Path.DirectorySeparatorChar.ToString()))
                uploadRoot += Path.DirectorySeparatorChar;
            if (!fullPath.StartsWith(uploadRoot, StringComparison.OrdinalIgnoreCase))
                throw new Exception("Geçersiz dosya yolu!");

            file.SaveAs(fullPath);
            return safeFileName;
        }

        private bool IsVideoFile(string fileName)
        {
            string[] videoExtensions = { ".mp4", ".avi", ".mov", ".wmv", ".flv", ".webm", ".mkv", ".m4v", ".3gp" };
            return videoExtensions.Contains(Path.GetExtension(fileName).ToLower());
        }

        private bool IsImageFile(string fileName)
        {
            string ext = Path.GetExtension(fileName).ToLower();
            return ALLOWED_IMAGE_EXTENSIONS.Contains(ext);
        }

        private bool IsHtmlContent(CourseContents content)
        {
            if (content == null) return false;

            var contentType = content.ContentType ?? string.Empty;
            var filePath = content.FilePath ?? string.Empty;
            return contentType.IndexOf("html", StringComparison.OrdinalIgnoreCase) >= 0
                || filePath.EndsWith(".html", StringComparison.OrdinalIgnoreCase)
                || filePath.EndsWith(".htm", StringComparison.OrdinalIgnoreCase);
        }

        private static string SanitizeOfflineCourseHtml(string html)
        {
            if (string.IsNullOrWhiteSpace(html)) return html;
            return Regex.Replace(
                html,
                "\\s(?:href|src)\\s*=\\s*([\"'])https?://.*?\\1",
                string.Empty,
                RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);
        }

        private string ResolveCourseContentPath(string filePath)
        {
            if (string.IsNullOrWhiteSpace(filePath))
                throw new InvalidOperationException("HTML dosya yolu bulunamadi.");

            if (filePath.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                throw new InvalidOperationException("Harici HTML baglantilari uygulama icinden duzenlenemez.");

            var relativePath = filePath.Trim().TrimStart('~', '/', '\\')
                .Replace('/', Path.DirectorySeparatorChar)
                .Replace('\\', Path.DirectorySeparatorChar);
            var storagePrefix = "files" + Path.DirectorySeparatorChar + "Egitim" + Path.DirectorySeparatorChar;
            if (relativePath.StartsWith(storagePrefix, StringComparison.OrdinalIgnoreCase))
                relativePath = relativePath.Substring(storagePrefix.Length);

            var uploadPath = GetUploadPath();
            var uploadRoot = Path.GetFullPath(uploadPath).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar)
                + Path.DirectorySeparatorChar;
            var physicalPath = Path.GetFullPath(Path.Combine(uploadRoot, relativePath));

            if (!physicalPath.StartsWith(uploadRoot, StringComparison.OrdinalIgnoreCase))
                throw new InvalidOperationException("Gecersiz HTML dosya yolu.");

            return physicalPath;
        }

        private string ReadHtmlContentFile(CourseContents content)
        {
            if (!IsHtmlContent(content)) return string.Empty;

            var physicalPath = ResolveCourseContentPath(content.FilePath);
            if (!System.IO.File.Exists(physicalPath))
                throw new FileNotFoundException("HTML dosyasi bulunamadi.", physicalPath);

            return System.IO.File.ReadAllText(physicalPath, Encoding.UTF8);
        }

        private void WriteHtmlContentFile(CourseContents content, string html)
        {
            // HTML içerik veya HTML dosya olmayan içeriği atla
            if (string.IsNullOrWhiteSpace(html)) return;
            if (!IsHtmlContent(content)) return;

            try
            {
                var currentExtension = Path.GetExtension(content.FilePath ?? string.Empty);
                if (string.IsNullOrWhiteSpace(content.FilePath)
                    || (!string.Equals(currentExtension, ".html", StringComparison.OrdinalIgnoreCase)
                        && !string.Equals(currentExtension, ".htm", StringComparison.OrdinalIgnoreCase)))
                {
                    content.FilePath = Guid.NewGuid().ToString("N") + ".html";
                    // FilePath'i database'e kaydet
                    db.Entry(content).State = EntityState.Modified;
                    db.SaveChanges();
                }

                var physicalPath = ResolveCourseContentPath(content.FilePath);
                var extension = Path.GetExtension(physicalPath);
                if (!string.Equals(extension, ".html", StringComparison.OrdinalIgnoreCase)
                    && !string.Equals(extension, ".htm", StringComparison.OrdinalIgnoreCase))
                    throw new InvalidOperationException("Yalnizca HTML icerikler bu alandan duzenlenebilir.");

                var directory = Path.GetDirectoryName(physicalPath);
                if (!Directory.Exists(directory))
                    Directory.CreateDirectory(directory);

                System.IO.File.WriteAllText(physicalPath, html, new UTF8Encoding(false));
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"WriteHtmlContentFile Error: {ex.Message}\n{ex.StackTrace}");
                throw;
            }
        }

        private bool CanModifyCourse(E_User user, Courses course)
        {
            if (user == null || course == null) return false;
            if (user.Role == "Admin") return true;
            if (user.Role == "Teacher" && course.CreatedBy == user.fldId) return true;
            return false;
        }

        private bool HasAccessToPage(E_User user)
        {
            return user != null && (user.Role == "Admin" || user.Role == "Teacher");
        }

        private ActionResult RedirectToLocalOrStudentIndex(string returnUrl)
        {
            if (!string.IsNullOrWhiteSpace(returnUrl) && Url.IsLocalUrl(returnUrl))
                return Redirect(returnUrl);

            return RedirectToAction("StudentIndex");
        }

        // CourseController.cs içine ekleyin

        [HttpPost]
        [ValidateAntiForgeryToken]
        [ValidateInput(false)]
        public ActionResult CreateFromHtmlFile(int categoryId, HttpPostedFileBase htmlFile)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null || !HasAccessToPage(user))
                {
                    TempData["msgError"] = "Yetkiniz yok.";
                    return RedirectToAction("Index");
                }

                if (htmlFile == null || htmlFile.ContentLength == 0 ||
                    !htmlFile.FileName.EndsWith(".html", StringComparison.OrdinalIgnoreCase))
                {
                    TempData["msgError"] = "Geçerli bir HTML dosyası seçiniz.";
                    return RedirectToAction("Index");
                }

                // Dosyayı kaydet
                string uploadPath = GetUploadPath();
                string savedFileName = SecureFileUpload(htmlFile, uploadPath,
                    new[] { ".html" }, "HTML dosyası");

                // HTML'den içerik çıkar
                string fullPath = Path.Combine(uploadPath, savedFileName);
                string description = ExtractDescriptionFromHtmlFile(fullPath);

                // Kategori kontrol et
                var category = db.Categories.Find(categoryId);
                if (category == null)
                {
                    TempData["msgError"] = "Kategori bulunamadı.";
                    return RedirectToAction("Index");
                }

                // Yeni kurs oluştur - CreatedDate HER ZAMAN SET EDILMELI!
                var course = new Courses
                {
                    CourseTitle = ExtractTitleFromHtmlFile(fullPath) ?? "HTML Dosyasından Oluşturulan Kurs",
                    CourseDescription = description,
                    ResourceFile = savedFileName,
                    CreatedBy = user.fldId,
                    CreatedDate = DateTime.Now,  // ✓ ZORUNLU!
                    CategoryId = categoryId,
                    IsActive = true,
                    IsDeleted = false
                };

                db.Courses.Add(course);
                db.SaveChanges();

                CacheService.Remove("AllActiveCourses");
                CacheService.Remove("Landing_ActiveCoursePreview_v1");

                TempData["msgSuccess"] = "Kurs HTML dosyasından başarıyla oluşturuldu.";
                return RedirectToAction("Index");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"CreateFromHtmlFile Error: {ex.Message}");
                TempData["msgError"] = "Kurs oluşturulurken hata: " + ex.Message;
                return RedirectToAction("Index");
            }
        }

        // HTML dosyasından title çıkar
        private string ExtractTitleFromHtmlFile(string filePath)
        {
            try
            {
                if (string.IsNullOrEmpty(filePath) || !System.IO.File.Exists(filePath))
                    return null;

                string htmlContent = System.IO.File.ReadAllText(filePath, System.Text.Encoding.UTF8);

                Match titleMatch = Regex.Match(htmlContent, "<title[^>]*>([^<]+)</title>", RegexOptions.IgnoreCase);
                if (titleMatch.Success)
                    return titleMatch.Groups[1].Value.Trim();

                return null;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"ExtractTitleFromHtmlFile Error: {ex.Message}");
                return null;
            }
        }

        // HTML dosyasından description çıkar
        private string ExtractDescriptionFromHtmlFile(string filePath)
        {
            try
            {
                if (string.IsNullOrEmpty(filePath) || !System.IO.File.Exists(filePath))
                    return null;

                string htmlContent = System.IO.File.ReadAllText(filePath, System.Text.Encoding.UTF8);

                // Meta description'ı bul
                Match descMatch = Regex.Match(
                    htmlContent,
                    "<meta[^>]*name=['\"]description['\"][^>]*content=['\"]([^'\"]+)['\"]",
                    RegexOptions.IgnoreCase);

                if (descMatch.Success)
                    return descMatch.Groups[1].Value.Trim();

                // Body içeriğini al
                Match bodyMatch = Regex.Match(htmlContent, "<body[^>]*>(.*?)</body>",
                    RegexOptions.IgnoreCase | RegexOptions.Singleline);

                if (bodyMatch.Success)
                {
                    string bodyContent = bodyMatch.Groups[1].Value;
                    // Script ve style taglarını kaldır
                    bodyContent = Regex.Replace(bodyContent, "<script[^>]*>.*?</script>", "",
                        RegexOptions.IgnoreCase | RegexOptions.Singleline);
                    bodyContent = Regex.Replace(bodyContent, "<style[^>]*>.*?</style>", "",
                        RegexOptions.IgnoreCase | RegexOptions.Singleline);

                    return bodyContent.Trim();
                }

                return null;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"ExtractDescriptionFromHtmlFile Error: {ex.Message}");
                return null;
            }
        }

        // ---------------- INDEX ----------------
        public ActionResult Index(int? editCourseId = null, int? manageCourseId = null)
        {
            // Mevcut kullanıcıyı alın (controller içinde GetCurrentUser metodunuz varsa onu kullanın)
            var user = GetCurrentUser();
            if (user == null)
            {
                TempData["msgError"] = "Lütfen giriş yapın.";
                return RedirectToAction("Login", "Account");
            }

            // Base sorgu (kategori ilişkisini view'da kullanıyorsanız Include ekleyin)
            var query = db.Courses
                          .Include("Categories")   // System.Data.Entity kullanılarak Include çalışır
                          .Include("CourseEnrollments") // include enrollments so view can use navigation count
                          .AsQueryable();

            // Rol bazlı filtreleme: Admin tümünü görür, Teacher yalnızca kendi oluşturduklarını görür
            if (!string.IsNullOrWhiteSpace(user.Role) && user.Role.Equals("Admin", StringComparison.OrdinalIgnoreCase))
            {
                // Admin: filtre yok (tüm kurslar)
            }
            else if (!string.IsNullOrWhiteSpace(user.Role) && user.Role.Equals("Teacher", StringComparison.OrdinalIgnoreCase))
            {
                query = query.Where(c => c.CreatedBy == user.fldId);
            }
            else
            {
                // Diğer roller (öğrenci vb.) için boş liste göstermek isterseniz:
                query = query.Where(c => false);
                // Alternatif: etkin (IsActive) kursları göstermek isterseniz:
                // query = query.Where(c => c.IsActive);
            }

            var courses = query.OrderBy(c => c.CourseTitle).ToList();

            // Oluşturanların isimlerini ViewBag ile gönder
            var creatorIds = courses.Select(c => c.CreatedBy).Distinct().ToList();
            var courseUsers = db.E_User
                                .Where(u => creatorIds.Contains(u.fldId))
                                .ToList()
                                .ToDictionary(u => u.fldId, u => (u.fldName + " " + u.fldLastName).Trim());

            // Kurslara ait öğrenci sayılarını hesapla ve ViewBag'e koy
            try
            {
                var courseIds = courses.Select(c => c.CourseId).ToList();
                var enrollmentCounts = db.CourseEnrollments
                                         .Where(e => courseIds.Contains(e.CourseId))
                                         .GroupBy(e => e.CourseId)
                                         .Select(g => new { CourseId = g.Key, Count = g.Count() })
                                         .ToDictionary(x => x.CourseId, x => x.Count);
                ViewBag.EnrollmentCounts = enrollmentCounts;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Index EnrollmentCounts Error: {ex.Message}");
                ViewBag.EnrollmentCounts = new Dictionary<int, int>();
            }

            ViewBag.CourseUsers = courseUsers;
            ViewBag.CurrentUser = user;
            ViewBag.Categories = db.Categories.Where(c => c.IsActive).ToList();

            ViewBag.EditCourseId = editCourseId;
            ViewBag.ManageCourseId = manageCourseId;
            return View(courses);
        }
        // using ifadelerinin zaten içinde olduğuna dikkat edin
        // (Action imzalarında ResourceHtml için [AllowHtml] eklendi, sanitize örneği yorum satırıyla verildi)
        // NuGet: Install-Package Ganss.XSS  (sanitize için önerilir)

        [HttpPost]
        [ValidateAntiForgeryToken]
        [ValidateInput(false)]
        public ActionResult Create(Courses model, HttpPostedFileBase CoverImageFile, HttpPostedFileBase ResourceFileUpload, string ResourceHtml)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null) { TempData["msgError"] = "Kullanıcı bilgisi bulunamadı."; return RedirectToAction("Index"); }
                if (!HasAccessToPage(user)) { TempData["msgError"] = "Yetkiniz yok."; return RedirectToAction("Index"); }
                if (!ModelState.IsValid) { TempData["msgError"] = "Geçersiz veri."; return RedirectToAction("Index"); }

                if (!string.IsNullOrWhiteSpace(ResourceHtml))
                {
                    // HTML sanitize: Ganss.XSS kullanın (NuGet: Install-Package HtmlSanitizer)
                    var sanitizer = new HtmlSanitizer();
                    // Açıkça izin verilen etiket/attribute ekleyin (link ve image için)
                    sanitizer.AllowedTags.Add("a");
                    sanitizer.AllowedTags.Add("img");
                    sanitizer.AllowedAttributes.Add("href");
                    sanitizer.AllowedAttributes.Add("target");
                    sanitizer.AllowedAttributes.Add("rel");
                    sanitizer.AllowedAttributes.Add("src");
                    sanitizer.AllowedAttributes.Add("alt");
                    sanitizer.AllowedAttributes.Add("title");
                    model.CourseDescription = SanitizeOfflineCourseHtml(sanitizer.Sanitize(ResourceHtml));
                }

                model.CreatedBy = user.fldId;
                model.CreatedDate = DateTime.Now;
                model.IsActive = true;

                string uploadPath = GetUploadPath();

                if (CoverImageFile != null && CoverImageFile.ContentLength > 0)
                    model.CoverImage = SecureFileUpload(CoverImageFile, uploadPath, ALLOWED_IMAGE_EXTENSIONS, "kapak görseli");

                if (ResourceFileUpload != null && ResourceFileUpload.ContentLength > 0)
                {
                    string fileType = IsVideoFile(ResourceFileUpload.FileName) ? "video" : (IsImageFile(ResourceFileUpload.FileName) ? "image" : "ek dosya");
                    model.ResourceFile = SecureFileUpload(ResourceFileUpload, uploadPath, ALLOWED_RESOURCE_EXTENSIONS, fileType);
                }

                db.Courses.Add(model);
                db.SaveChanges();

                CacheService.Remove("AllActiveCourses");
                CacheService.Remove("Landing_ActiveCoursePreview_v1");

                TempData["msgSuccess"] = "Ders başarıyla eklendi.";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Create Error: {ex.Message}");
                TempData["msgError"] = "Ders eklenirken bir hata oluştu: " + ex.Message;
            }
            return RedirectToAction("Index");
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        [ValidateInput(false)]
        public ActionResult Edit(Courses model, HttpPostedFileBase CoverImageFile, HttpPostedFileBase ResourceFileUpload, string ResourceHtml)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null) { TempData["msgError"] = "Kullanıcı bilgisi bulunamadı."; return RedirectToAction("Index"); }
                if (!HasAccessToPage(user)) { TempData["msgError"] = "Yetkiniz yok."; return RedirectToAction("Index"); }
                if (!ModelState.IsValid) { TempData["msgError"] = "Geçersiz veri."; return RedirectToAction("Index"); }

                var course = db.Courses.Find(model.CourseId);
                if (course == null) { TempData["msgError"] = "Ders bulunamadı."; return RedirectToAction("Index"); }
                if (!CanModifyCourse(user, course)) { TempData["msgError"] = "Yetkiniz yok."; return RedirectToAction("Index"); }

                if (!string.IsNullOrWhiteSpace(ResourceHtml))
                {
                    var sanitizer = new HtmlSanitizer();
                    sanitizer.AllowedTags.Add("a");
                    sanitizer.AllowedTags.Add("img");
                    sanitizer.AllowedAttributes.Add("href");
                    sanitizer.AllowedAttributes.Add("target");
                    sanitizer.AllowedAttributes.Add("rel");
                    sanitizer.AllowedAttributes.Add("src");
                    sanitizer.AllowedAttributes.Add("alt");
                    sanitizer.AllowedAttributes.Add("title");
                    course.CourseDescription = SanitizeOfflineCourseHtml(sanitizer.Sanitize(ResourceHtml));
                }
                else
                {
                    course.CourseDescription = model.CourseDescription;
                }

                course.CourseTitle = model.CourseTitle;
                course.CategoryId = model.CategoryId;

                string uploadPath = GetUploadPath();

                if (CoverImageFile != null && CoverImageFile.ContentLength > 0)
                {
                    if (!string.IsNullOrEmpty(course.CoverImage))
                    {
                        string oldFilePath = Path.Combine(uploadPath, course.CoverImage);
                        if (System.IO.File.Exists(oldFilePath)) System.IO.File.Delete(oldFilePath);
                    }
                    course.CoverImage = SecureFileUpload(CoverImageFile, uploadPath, ALLOWED_IMAGE_EXTENSIONS, "kapak görseli");
                }

                if (ResourceFileUpload != null && ResourceFileUpload.ContentLength > 0)
                {
                    if (!string.IsNullOrEmpty(course.ResourceFile))
                    {
                        string oldFilePath = Path.Combine(uploadPath, course.ResourceFile);
                        if (System.IO.File.Exists(oldFilePath)) System.IO.File.Delete(oldFilePath);
                    }
                    string fileType = IsVideoFile(ResourceFileUpload.FileName) ? "video" : (IsImageFile(ResourceFileUpload.FileName) ? "image" : "ek dosya");
                    course.ResourceFile = SecureFileUpload(ResourceFileUpload, uploadPath, ALLOWED_RESOURCE_EXTENSIONS, fileType);
                }

                db.Entry(course).State = EntityState.Modified;
                db.SaveChanges();

                CacheService.Remove("AllActiveCourses");
                CacheService.Remove("Landing_ActiveCoursePreview_v1");

                TempData["msgSuccess"] = "Ders başarıyla güncellendi.";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Edit Error: {ex.Message}");
                TempData["msgError"] = "Ders güncellenirken bir hata oluştu: " + ex.Message;
            }
            return RedirectToAction("Index");
        }
        [HttpPost]
        [ValidateAntiForgeryToken] // opsiyonel ama güvenlik için önerilir; JS tarafına token ekleyin
        public JsonResult UploadImage()
        {
            try
            {
                // Tüm oturum açmış kullanıcıların Summernote üzerinden resim yüklemesine izin ver
                var user = GetCurrentUser();
                if (user == null)
                    return Json(new { success = false, message = "Kullanıcı bilgisi bulunamadı." });

                if (Request.Files == null || Request.Files.Count == 0)
                    return Json(new { success = false, message = "Dosya bulunamadı." });

                var file = Request.Files[0] as HttpPostedFileBase;
                if (file == null || file.ContentLength == 0)
                    return Json(new { success = false, message = "Geçersiz dosya." });

                int maxFileSize = 5 * 1024 * 1024;
                if (file.ContentLength > maxFileSize)
                    return Json(new { success = false, message = "Resim boyutu 5MB'tan büyük olamaz." });

                if (!IsImageFile(file.FileName))
                    return Json(new { success = false, message = "Sadece resim dosyalarına izin verilir." });

                string uploadPath = GetUploadPath();
                string savedFileName = SecureFileUpload(file, uploadPath, ALLOWED_IMAGE_EXTENSIONS, "resim");

                string url = Url.Content("~/files/Egitim/" + savedFileName);
                return Json(new { success = true, url = url });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"UploadImage Error: {ex.Message}");
                return Json(new { success = false, message = ex.Message });
            }
        }
        // ... (diğer methodlar değişmedi) ...


        // ---------------- DELETE ----------------
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(int id)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null)
                {
                    TempData["msgError"] = "Kullanıcı bilgisi bulunamadı.";
                    return RedirectToAction("Index");
                }
                if (!HasAccessToPage(user))
                {
                    TempData["msgError"] = "Yetkiniz yok.";
                    return RedirectToAction("Index");
                }

                var course = db.Courses.Find(id);
                if (course == null)
                {
                    TempData["msgError"] = "Ders bulunamadı!";
                    return RedirectToAction("Index");
                }
                if (!CanModifyCourse(user, course))
                {
                    TempData["msgError"] = "Yetkiniz yok.";
                    return RedirectToAction("Index");
                }

                // Kontrol et: Kursa kayıtlı öğrenci var mı?
                bool hasEnrollments = db.CourseEnrollments.Any(e => e.CourseId == id);
                var courseExamIds = db.Exam
                    .Where(e => e.CourseId == id)
                    .Select(e => e.ExamId)
                    .ToList();

                var courseQuestionIds = courseExamIds.Any()
                    ? db.Question
                        .Where(q => courseExamIds.Contains(q.ExamId))
                        .Select(q => q.QuestionId)
                        .ToList()
                    : new List<int>();

                bool hasExamResults = courseExamIds.Any() && db.ExamResult.Any(r => courseExamIds.Contains(r.ExamId));
                bool hasExamAnswers = courseQuestionIds.Any() && db.Answer.Any(a => courseQuestionIds.Contains(a.QuestionId));
                bool hasExams = hasExamResults || hasExamAnswers;
                bool hasReviews = db.CourseReviews.Any(r => r.CourseId == id);
                bool hasCertificateRequests = db.CertificateRequest.Any(r => r.CourseId == id);
                bool hasCertificates =
                    (from certificate in db.Certificate
                     join examResult in db.ExamResult on certificate.ExamResultId equals examResult.ExamResultId
                     join exam in db.Exam on examResult.ExamId equals exam.ExamId
                     where exam.CourseId == id
                     select certificate.CertificateId).Any();

                var blockers = new List<string>();
                if (hasEnrollments) blockers.Add("öğrenci kayıtları");
                if (hasExams) blockers.Add("sınavlar");
                if (hasReviews) blockers.Add("yorumlar");
                if (hasCertificateRequests) blockers.Add("sertifika talepleri");
                if (hasCertificates) blockers.Add("oluşturulmuş sertifikalar");

                if (blockers.Any())
                {
                    TempData["msgError"] = "Bu kurs silinemedi çünkü bağlı kayıtlar var: " + string.Join(", ", blockers) + ". Önce bu kayıtları temizlemelisiniz.";
                    return RedirectToAction("Index");
                }

                string uploadPath = GetUploadPath();

                if (!string.IsNullOrEmpty(course.CoverImage))
                {
                    string coverPath = Path.Combine(uploadPath, course.CoverImage);
                    if (System.IO.File.Exists(coverPath))
                        System.IO.File.Delete(coverPath);
                }

                if (!string.IsNullOrEmpty(course.ResourceFile))
                {
                    string resourcePath = Path.Combine(uploadPath, course.ResourceFile);
                    if (System.IO.File.Exists(resourcePath))
                        System.IO.File.Delete(resourcePath);
                }

                // Kursa ait içerikleri de sil
                var contents = db.CourseContents.Where(c => c.CourseId == id).ToList();
                foreach (var content in contents)
                {
                    if (!string.IsNullOrEmpty(content.FilePath))
                    {
                        string contentPath = Path.Combine(uploadPath, content.FilePath);
                        if (System.IO.File.Exists(contentPath))
                            System.IO.File.Delete(contentPath);
                    }
                    db.CourseContents.Remove(content);
                }

                if (courseQuestionIds.Any())
                {
                    var mediaFiles = db.QuestionMedia.Where(m => courseQuestionIds.Contains(m.QuestionId)).ToList();
                    foreach (var media in mediaFiles)
                    {
                        if (!string.IsNullOrWhiteSpace(media.MediaPath))
                        {
                            var mediaPath = media.MediaPath.StartsWith("~/", StringComparison.Ordinal)
                                ? FileStorageHelper.MapPath(Server, media.MediaPath)
                                : FileStorageHelper.MapUrlToPhysicalPath(Server, media.MediaPath);

                            if (!string.IsNullOrWhiteSpace(mediaPath) && System.IO.File.Exists(mediaPath))
                                System.IO.File.Delete(mediaPath);
                        }
                    }

                    db.QuestionMedia.RemoveRange(mediaFiles);

                    var options = db.QuestionOption.Where(o => courseQuestionIds.Contains(o.QuestionId)).ToList();
                    db.QuestionOption.RemoveRange(options);

                    var questions = db.Question.Where(q => courseQuestionIds.Contains(q.QuestionId)).ToList();
                    db.Question.RemoveRange(questions);
                }

                if (courseExamIds.Any())
                {
                    var exams = db.Exam.Where(e => courseExamIds.Contains(e.ExamId)).ToList();
                    db.Exam.RemoveRange(exams);
                }

                db.Courses.Remove(course);
                db.SaveChanges();

                // Cache'i temizle
                CacheService.Remove("AllActiveCourses");
                CacheService.Remove("Landing_ActiveCoursePreview_v1");

                TempData["msgSuccess"] = "Ders başarıyla silindi.";
            }
            catch (DbUpdateException dbEx)
            {
                System.Diagnostics.Trace.TraceError($"Delete DbUpdateException: {dbEx.Message}");
                TempData["msgError"] = "Ders silinirken veri tabanı hatası oluştu. Lütfen öğrenci kayıtlarını kontrol edin.";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Delete Error: {ex.Message}");
                TempData["msgError"] = "Ders silinirken bir hata oluştu. Lütfen tekrar deneyiniz.";
            }
            return RedirectToAction("Index");
        }

        // Tüm öğretmenleri ve adminleri listele
        public ActionResult AllInstructors(int page = 1)
        {
            try
            {
                // Hem Teacher hem Admin rolleri
                var instructors = db.E_User
                    .Where(u => (u.Role == "Teacher" || u.Role == "Admin") && u.IsActive == true)
                    .OrderBy(u => u.fldName)
                    .ToList();

                // Her öğretmen/admin'in ders sayısını hesapla
                var courseCount = new Dictionary<int, int>();
                var studentCount = new Dictionary<int, int>();

                foreach (var instructor in instructors)
                {
                    int courseCountValue = db.Courses
                        .Where(c => c.CreatedBy == instructor.fldId && c.IsActive && (!c.IsDeleted.HasValue || !c.IsDeleted.Value))
                        .Count();
                    courseCount[instructor.fldId] = courseCountValue;

                    // Her kursa kayıtlı öğrenci sayısını topla
                    int studentCountValue = db.CourseEnrollments
                        .Where(e => db.Courses.Any(c => c.CourseId == e.CourseId && c.CreatedBy == instructor.fldId))
                        .Count();
                    studentCount[instructor.fldId] = studentCountValue;
                }

                int pageSize = 12;
                int total = instructors.Count;
                var paged = instructors.Skip((page - 1) * pageSize).Take(pageSize).ToList();

                ViewBag.CourseCount = courseCount;
                ViewBag.StudentCount = studentCount;
                ViewBag.CurrentPage = page;
                ViewBag.TotalPages = (int)Math.Ceiling((double)total / pageSize);

                return View(paged);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"AllInstructors Error: {ex.Message}");
                TempData["msgError"] = "Öğretmenler yüklenirken hata oluştu.";
                return RedirectToAction("StudentIndex");
            }
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult ToggleStatus(int id)
        {
            var user = GetCurrentUser();
            if (user == null || !HasAccessToPage(user))
                return Json(new { success = false, message = "Yetkiniz yok." });

            var course = db.Courses.Find(id);
            if (course != null && CanModifyCourse(user, course))
            {
                if (!course.IsActive && RequiresEducationReview(course.CourseId))
                    return Json(new
                    {
                        success = false,
                        message = "Bu eğitim otomatik oluşturulmuş bir taslaktır. Eğitim Paketleri > Kontrol Bekleyen Taslaklar ekranından doğrulayıp yayınlayın.",
                        reviewUrl = Url.Action("Review", "EducationPackage", new { id = course.CourseId })
                    });
                course.IsActive = !course.IsActive;
                db.SaveChanges();
                CacheService.Remove("AllActiveCourses");
                CacheService.Remove("Landing_ActiveCoursePreview_v1");
                return Json(new { success = true, isActive = course.IsActive });
            }

            return Json(new { success = false, message = "Ders bulunamadı veya yetkiniz yok." });
        }

        private bool RequiresEducationReview(int courseId)
        {
            if (db.Courses.Any(c => c.CourseId == courseId && c.Categories.CategoryName == "Web Kaynaklı Belge Eğitimleri")) return true;
            try
            {
                return db.Database.SqlQuery<int>("SELECT COUNT(1) FROM dbo.EducationPackageImportLog WHERE ImportedCourseId=@p0 AND Status='Success'", courseId).FirstOrDefault() > 0;
            }
            catch { return false; }
        }
        // ---------------- STUDENT INDEX ----------------
        public ActionResult StudentIndex(int page = 1)
        {
            var user = GetCurrentUser();
            if (user == null) return RedirectToAction("Login", "Account");

            // Cache'den kursları al (SADECE AKTİF KURSLAR)
            string cacheKey = "AllActiveCourses";
            var allCourses = CacheService.GetOrCreate(cacheKey, () =>
            {
                return db.Courses
                            .Include(c => c.Categories)
                            .Where(c => c.IsActive && (!c.IsDeleted.HasValue || !c.IsDeleted.Value)) // AKTİF + silinmemis kurslar
                            .Select(c => new CourseViewModel
                            {
                                CourseId = c.CourseId,
                                CourseTitle = c.CourseTitle,
                                CourseDescription = c.CourseDescription,
                                CoverImage = c.CoverImage,
                                CreatedBy = c.CreatedBy,
                                CreatedDate = c.CreatedDate,
                                CategoryId = c.CategoryId,
                                CategoryName = c.Categories.CategoryName,
                                IsActive = c.IsActive,
                                ResourceFile = c.ResourceFile
                            })
                            .ToList();
            }, 15); // 15 dakika cache

            var enrolledCourseIds = db.CourseEnrollments
                                      .Where(e => e.UserId == user.fldId)
                                      .Select(e => e.CourseId)
                                      .ToList();

            // TÜM AKTİF KURSLAR GÖSTERİLECEK (kayıtlı olunmayan kurslar da)
            var allActiveCoursesForDisplay = allCourses
                                            .OrderByDescending(c => c.CreatedDate)
                                            .ToList();

            // KAYITLI KURSLAR (sayfalandırma için)
            var enrolledCoursesAll = allCourses
                                    .Where(c => enrolledCourseIds.Contains(c.CourseId))
                                    .OrderByDescending(c => c.CreatedDate)
                                    .ToList();

            int pageSize = 8;
            int totalCourses = enrolledCoursesAll.Count;
            int totalPages = (int)Math.Ceiling((double)totalCourses / pageSize);

            var pagedEnrolledCourses = enrolledCoursesAll
                                        .Skip((page - 1) * pageSize)
                                        .Take(pageSize)
                                        .ToList();

            ViewBag.EnrolledCourses = pagedEnrolledCourses;
            ViewBag.EnrolledCourseIds = enrolledCourseIds;
            ViewBag.CurrentPage = page;
            ViewBag.TotalPages = totalPages;

            ViewBag.UserFirstName = user.fldName;
            ViewBag.UserLastName = user.fldLastName;

            return View(allActiveCoursesForDisplay); // AKTİF KURSLAR GÖNDER
        }
        // ---------------- ENROLL ----------------
        public ActionResult Enroll(int id, string returnUrl)
        {
            var user = GetCurrentUser();
            if (user == null)
            {
                TempData["msgError"] = "Kurs Detayı İçin Lütfen Giriş Yapınız. Hesabınız yok ise kayıt olunuz";
                return RedirectToAction("StudentIndex");
            }

            var course = db.Courses.Find(id);
            if (course == null || !course.IsActive)
            {
                TempData["msgError"] = "Kurs bulunamadı veya aktif değil.";
                return RedirectToAction("StudentIndex");
            }

            bool alreadyEnrolled = db.CourseEnrollments.Any(e => e.CourseId == id && e.UserId == user.fldId);
            if (alreadyEnrolled)
            {
                TempData["msgInfo"] = "Zaten bu kursa kayıtlısınız.";

                // GERİ DÖNÜŞ
                return RedirectToLocalOrStudentIndex(returnUrl);
            }

            var enrollment = new CourseEnrollments
            {
                CourseId = id,
                UserId = user.fldId,
                EnrollmentDate = DateTime.Now
            };
            db.CourseEnrollments.Add(enrollment);
            db.SaveChanges();

            // Email bildirimi gönder
            if (!string.IsNullOrEmpty(user.fldEmail))
            {
                try
                {
                    emailService.SendCourseEnrollmentEmailAsync(
                        user.fldEmail,
                        user.fldName + " " + user.fldLastName,
                        course.CourseTitle
                    ).Wait();
                }
                catch (Exception emailEx)
                {
                    System.Diagnostics.Trace.TraceError($"Email Send Error: {emailEx.Message}");
                }
            }

            TempData["msgSuccess"] = "Kursa başarıyla kayıt oldunuz!";

            // GERİ DÖNÜŞ — Kullanıcı aynı sayfaya döner
            return RedirectToLocalOrStudentIndex(returnUrl);
        }

        // Aşağıdaki metodu CourseController sınıfınızın içine uygun bir yere ekleyin.

        public ActionResult Enrollments(int? courseId, int page = 1)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null)
                {
                    TempData["msgError"] = "Lütfen sisteme giriş yapın.";
                    return RedirectToAction("Login", "Account");
                }

                // Sadece Admin tüm kayıtları görsün; Teacher ise yalnızca kendi kurslarına ait kayıtları görecek
                if (user.Role != "Admin" && user.Role != "Teacher")
                {
                    TempData["msgError"] = "Bu sayfaya erişim yetkiniz yok.";
                    return RedirectToAction("Index");
                }

                // Eager loading ile kullanıcı ve kurs bilgilerini al
                var query = db.CourseEnrollments
                              .Include(e => e.E_User)
                              .Include(e => e.Courses)
                              .AsQueryable();

                if (user.Role == "Teacher")
                {
                    // Teacher yalnızca kendi oluşturduğu kursların kayıtlarını görür
                    query = query.Where(e => e.Courses.CreatedBy == user.fldId);
                }

                if (courseId.HasValue)
                {
                    query = query.Where(e => e.CourseId == courseId.Value);
                }

                var enrollments = query
                    .OrderByDescending(e => e.EnrollmentDate)
                    .Select(e => new gzpegm.Models.ViewModel.EnrollmentViewModel
                    {
                        EnrollmentId = e.EnrollmentId,
                        CourseId = e.CourseId,
                        CourseTitle = e.Courses.CourseTitle,
                        UserId = e.UserId,
                        UserFullName = (e.E_User.fldName ?? "") + " " + (e.E_User.fldLastName ?? ""),
                        UserEmail = e.E_User.fldEmail,
                        EnrollmentDate = e.EnrollmentDate
                    })
                    .ToList();

                // View için yardımcı veriler
                ViewBag.CourseId = courseId;
                if (user.Role == "Teacher")
                {
                    ViewBag.Courses = db.Courses.Where(c => c.CreatedBy == user.fldId).ToList();
                }
                else
                {
                    ViewBag.Courses = db.Courses.OrderBy(c => c.CourseTitle).ToList();
                }

                return View(enrollments);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Enrollments Error: {ex.Message}");
                TempData["msgError"] = "Kayıtlar yüklenirken hata oluştu.";
                return RedirectToAction("Index");
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult RemoveEnrollment(int enrollmentId, int? courseId)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null)
                {
                    TempData["msgError"] = "Lütfen sisteme giriş yapın.";
                    return RedirectToAction("Login", "Account");
                }

                var enrollment = db.CourseEnrollments
                    .Include(e => e.Courses)
                    .Include(e => e.E_User)
                    .FirstOrDefault(e => e.EnrollmentId == enrollmentId);

                if (enrollment == null)
                {
                    TempData["msgError"] = "Kurs kaydı bulunamadı.";
                    return RedirectToAction("Enrollments", new { courseId = courseId });
                }

                var course = enrollment.Courses ?? db.Courses.Find(enrollment.CourseId);
                if (course == null)
                {
                    TempData["msgError"] = "Kurs bulunamadı.";
                    return RedirectToAction("Enrollments", new { courseId = courseId });
                }

                if (!CanModifyCourse(user, course))
                {
                    TempData["msgError"] = "Bu öğrenciyi dersten çıkarmaya yetkiniz yok.";
                    return RedirectToAction("Enrollments", new { courseId = courseId ?? enrollment.CourseId });
                }

                string studentName = enrollment.E_User != null
                    ? ((enrollment.E_User.fldName ?? "") + " " + (enrollment.E_User.fldLastName ?? "")).Trim()
                    : "Öğrenci";

                int redirectCourseId = courseId ?? enrollment.CourseId;

                db.CourseEnrollments.Remove(enrollment);
                db.SaveChanges();

                CacheService.Remove("AllActiveCourses");
                CacheService.Remove("Landing_ActiveCoursePreview_v1");

                TempData["msgSuccess"] = $"{studentName} dersten çıkarıldı.";
                return RedirectToAction("Enrollments", new { courseId = redirectCourseId });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"RemoveEnrollment Error: {ex}");
                TempData["msgError"] = "Öğrenci dersten çıkarılırken bir hata oluştu.";
                return RedirectToAction("Enrollments", new { courseId = courseId });
            }
        }
        // ---------------- DETAILS ----------------
        // Slider üzerinden tıklayınca otomatik kayıt + yönlendirme için eklendi
        public ActionResult EnrollAndGo(int id)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null)
                {
                    TempData["msgError"] = "Kursa kaydolmak için lütfen giriş yapınız.";
                    return RedirectToAction("LoginPage", "Giris", new { returnUrl = Url.Action("EnrollAndGo", "Course", new { id }), direct = true });
                }

                var course = db.Courses.FirstOrDefault(c => c.CourseId == id && c.IsActive);
                if (course == null)
                {
                    TempData["msgError"] = "Kurs bulunamadı.";
                    return RedirectToAction("Index", "Landing");
                }

                bool already = db.CourseEnrollments.Any(e => e.CourseId == id && e.UserId == user.fldId);
                if (!already)
                {
                    var enrollment = new CourseEnrollments
                    {
                        CourseId = id,
                        UserId = user.fldId,
                        EnrollmentDate = DateTime.Now
                    };
                    db.CourseEnrollments.Add(enrollment);
                    db.SaveChanges();
                }

                return RedirectToAction("Details", new { id = id });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"EnrollAndGo Error: {ex.Message}");
                TempData["msgError"] = "Kursa kaydolurken bir hata oluştu.";
                return RedirectToAction("Index", "Landing");
            }
        }

        public ActionResult Details(int id, bool publicView = false, bool preview = false)
        {
            var user = GetCurrentUser();
            // Eğer publicView true ise giriş yapmamış kullanıcıların da kurs detay sayfasını görüntülemesine izin ver
            if (user == null && !publicView)
            {
                TempData["msgError"] = "Kurs Detayı İçin Lütfen Giriş Yapınız. Hesabınız yok ise kayıt olunuz.";
                return RedirectToAction("Index", "Landing");
            }

            var courseQuery = db.Courses
                           .Include(c => c.CourseContents)
                           .Include(c => c.Categories)
                           .Where(c => c.CourseId == id && c.IsDeleted != true);

            if (!preview) courseQuery = courseQuery.Where(c => c.IsActive);

            var course = courseQuery.FirstOrDefault();

            if (course == null)
            {
                TempData["msgError"] = "Kurs bulunamadı.";
                return RedirectToAction("StudentIndex");
            }

            int? userId = user?.fldId;
            bool canManageCourse = user != null && CanModifyCourse(user, course);
            if (preview && !canManageCourse)
            {
                TempData["msgError"] = "Taslak kurs önizleme yetkiniz yok.";
                return RedirectToAction("StudentIndex");
            }

            bool isEnrolled = userId.HasValue && db.CourseEnrollments.Any(e => e.CourseId == id && e.UserId == userId.Value);
            bool canAccessCourseContent = isEnrolled || canManageCourse;
            // Eğer publicView parametresi true ise kayıtlı olmayan kullanıcılar için detay gösterilsin (sadece görüntüleme)
            if (!isEnrolled && !canManageCourse && !publicView)
            {
                TempData["msgError"] = "Bu kursun detaylarını görmek için önce kayıt olmalısınız.";
                return RedirectToAction("StudentIndex");
            }

            string defaultCourseCover = Url.Content("~/files/Egitim/91a7dd7d-56dc-41d3-a9bf-296a421966e2_155.jpg");
            string coverImagePath = string.IsNullOrEmpty(course.CoverImage) || course.CoverImage.StartsWith("http", StringComparison.OrdinalIgnoreCase)
                ? defaultCourseCover
                : Url.Content("~/files/Egitim/" + course.CoverImage);

            string resourceFilePath = string.IsNullOrEmpty(course.ResourceFile) ? null
                : (course.ResourceFile.StartsWith("http", StringComparison.OrdinalIgnoreCase) ? null : Url.Content("~/files/Egitim/" + course.ResourceFile));

            // --- Debugging: fiziksel dosya yolunu ve varlığını kontrol et ---
            string physicalPath = null;
            bool resourceExists = false;
            try
            {
                if (!string.IsNullOrEmpty(course.ResourceFile))
                {
                    if (course.ResourceFile.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                    {
                        // Dış URL assumed accessible (cannot check local file system)
                        physicalPath = null;
                        resourceExists = false;
                    }
                    else
                    {
                        physicalPath = FileStorageHelper.MapPath(Server, "~/files/Egitim/" + course.ResourceFile);
                        resourceExists = System.IO.File.Exists(physicalPath);
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Details Resource Check Error: {ex.Message}");
            }

            // ViewBag ile debug bilgilerini view'e gönder
            ViewBag.ResourceFilePath = resourceFilePath;
            ViewBag.ResourcePhysicalPath = physicalPath;
            ViewBag.ResourceExists = resourceExists;

            var model = new CourseViewModel
            {
                CourseId = course.CourseId,
                CourseTitle = course.CourseTitle,
                CourseDescription = course.CourseDescription,
                CoverImage = course.CoverImage,
                CoverImagePath = coverImagePath,
                CreatedBy = course.CreatedBy,
                CreatedDate = course.CreatedDate,
                CategoryId = course.CategoryId,
                CategoryName = course.Categories.CategoryName,
                IsActive = course.IsActive,
                ResourceFile = course.ResourceFile,
                ResourceFilePath = resourceFilePath,
                Contents = canAccessCourseContent ? course.CourseContents.ToList() : new List<CourseContents>()
            };

            // Kursa ait aktif sınavları getir
            var courseExams = canAccessCourseContent
                ? db.Exam
                    .Where(e => e.CourseId == id && e.IsActive == true)
                    .Select(e => new ExamViewModel
                    {
                        ExamId = e.ExamId,
                        ExamTitle = e.Title,
                        ExamDescription = e.Description,
                        Duration = e.DurationMinutes ?? 60,
                        PassingScore = e.PassingScore ?? 60,
                        QuestionCount = db.Question.Count(q => q.ExamId == e.ExamId && q.IsActive != false),
                        ExamResultId = (userId.HasValue ? db.ExamResult
                            .Where(er => er.ExamId == e.ExamId && er.UserId == userId.Value && er.Status == 1)
                            .Select(er => (int?)er.ExamResultId)
                            .FirstOrDefault() : (int?)null)
                    })
                    .ToList()
                : new List<ExamViewModel>();

            ViewBag.CourseExams = courseExams;
            ViewBag.CurrentUser = user;
            ViewBag.CanManageCourse = canManageCourse;

            // Kurs yorumları (sadece admin onaylı olanlar)
            try
            {
                var approvedReviews = db.Database
                    .SqlQuery<CourseReviewItemViewModel>(@"
SELECT r.ReviewId,
       r.CourseId,
       r.UserId,
       (ISNULL(u.fldName,'') + ' ' + ISNULL(u.fldLastName,'')) AS UserFullName,
       r.Rating,
       r.Comment,
       r.CreatedDate
FROM CourseReviews r
INNER JOIN E_User u ON u.fldId = r.UserId
WHERE r.CourseId = @p0 AND ISNULL(r.IsApproved, 0) = 1
ORDER BY r.CreatedDate DESC", id)
                    .ToList();

                model.ApprovedReviews = approvedReviews;
            }
            catch (Exception ex)
            {
                // DB'de IsApproved kolonu yoksa (migration uygulanmadıysa) sayfa bozulmasın
                System.Diagnostics.Trace.TraceError($"Details ApprovedReviews Error: {ex.Message}");
                model.ApprovedReviews = new List<CourseReviewItemViewModel>();
            }

            // Sertifika durumu
            bool allExamsDone = false;
            if (userId.HasValue)
            {
                allExamsDone = AllExamsCompleted(userId.Value, id);
            }
            ViewBag.AllExamsCompleted = allExamsDone;

            byte certStatus = 255; // Talep yok
            if (allExamsDone && userId.HasValue)
            {
                var certReq = db.CertificateRequest
                    .Where(r => r.UserId == userId.Value && r.CourseId == id)
                    .OrderByDescending(r => r.RequestDate)
                    .FirstOrDefault();

                if (certReq != null)
                    certStatus = certReq.Status;
            }
            ViewBag.CertificateStatus = certStatus;

            return View(model);
        }

        // ---------------- COURSE REVIEW (STUDENT) ----------------
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult AddReview(int courseId, byte rating, string comment)
        {
            var user = GetCurrentUser();
            if (user == null)
            {
                TempData["msgError"] = "Yorum yapmak için giriş yapmalısınız.";
                return RedirectToAction("StudentIndex");
            }

            // Kursa kayıtlı mı?
            bool isEnrolled = db.CourseEnrollments.Any(e => e.CourseId == courseId && e.UserId == user.fldId);
            if (!isEnrolled)
            {
                TempData["msgError"] = "Bu kursa kayıtlı değilsiniz.";
                return RedirectToAction("StudentIndex");
            }

            if (rating < 1 || rating > 5)
            {
                TempData["msgError"] = "Puan 1-5 arasında olmalıdır.";
                return RedirectToAction("Details", new { id = courseId });
            }

            if (string.IsNullOrWhiteSpace(comment))
            {
                TempData["msgError"] = "Yorum boş olamaz.";
                return RedirectToAction("Details", new { id = courseId });
            }

            // DB insert: IsApproved kolonu DB'de default 0 olmalı (beklemede)
            var review = new CourseReviews
            {
                CourseId = courseId,
                UserId = user.fldId,
                Rating = rating,
                Comment = comment.Trim(),
                CreatedDate = DateTime.Now
            };

            db.CourseReviews.Add(review);
            db.SaveChanges();

            TempData["msgSuccess"] = "Yorumunuz alındı. Admin onayından sonra yayınlanacaktır.";
            return RedirectToAction("Details", new { id = courseId });
        }

        // ---------------- COURSE REVIEW MODERATION (ADMIN) ----------------
        public ActionResult PendingReviews(int? courseId)
        {
            var user = GetCurrentUser();
            if (user == null) return RedirectToAction("Login", "Account");
            if (user.Role != "Admin" && user.Role != "Teacher")
            {
                TempData["msgError"] = "Bu sayfaya erişim yetkiniz yok.";
                return RedirectToAction("StudentIndex");
            }

            try
            {
                List<PendingCourseReviewItemViewModel> pending;

                if (user.Role == "Admin")
                {
                    pending = db.Database
                        .SqlQuery<PendingCourseReviewItemViewModel>(@"
SELECT r.ReviewId,
       r.CourseId,
       r.UserId,
       (ISNULL(u.fldName,'') + ' ' + ISNULL(u.fldLastName,'')) AS UserFullName,
       c.CourseTitle,
       r.Rating,
       r.Comment,
       r.CreatedDate
FROM CourseReviews r
INNER JOIN E_User u ON u.fldId = r.UserId
INNER JOIN Courses c ON c.CourseId = r.CourseId
WHERE ISNULL(r.IsApproved, 0) = 0
  AND (@p0 IS NULL OR r.CourseId = @p0)
ORDER BY r.CreatedDate DESC", (object)courseId ?? DBNull.Value)
                        .ToList();
                }
                else
                {
                    // Teacher: sadece kendi kurslarına ait bekleyen yorumları görebilsin
                    pending = db.Database
                        .SqlQuery<PendingCourseReviewItemViewModel>(@"
SELECT r.ReviewId,
       r.CourseId,
       r.UserId,
       (ISNULL(u.fldName,'') + ' ' + ISNULL(u.fldLastName,'')) AS UserFullName,
       c.CourseTitle,
       r.Rating,
       r.Comment,
       r.CreatedDate
FROM CourseReviews r
INNER JOIN E_User u ON u.fldId = r.UserId
INNER JOIN Courses c ON c.CourseId = r.CourseId
WHERE ISNULL(r.IsApproved, 0) = 0
  AND c.CreatedBy = @p1
  AND (@p0 IS NULL OR r.CourseId = @p0)
ORDER BY r.CreatedDate DESC", new object[] { (object)courseId ?? DBNull.Value, user.fldId })
                        .ToList();
                }

                ViewBag.CourseId = courseId;
                ViewBag.Courses = db.Courses.OrderBy(c => c.CourseTitle).ToList();
                return View(pending);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"PendingReviews Error: {ex.Message}");
                TempData["msgError"] = "Bekleyen yorumlar yüklenirken hata oluştu. (DB migration uygulanmış mı kontrol edin)";
                return RedirectToAction("Index");
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ApproveReview(int reviewId, int? courseId)
        {
            var user = GetCurrentUser();
            if (user == null) return RedirectToAction("Login", "Account");
            if (user.Role != "Admin" && user.Role != "Teacher")
            {
                TempData["msgError"] = "Yetkiniz yok.";
                return RedirectToAction("StudentIndex");
            }

            try
            {
                var review = db.CourseReviews.Find(reviewId);
                if (review == null)
                {
                    TempData["msgError"] = "Yorum bulunamadı.";
                    return RedirectToAction("PendingReviews", new { courseId = courseId });
                }

                var course = db.Courses.Find(review.CourseId);
                if (course == null)
                {
                    TempData["msgError"] = "İlgili kurs bulunamadı.";
                    return RedirectToAction("PendingReviews", new { courseId = courseId });
                }

                // Yetki kontrolü: Admin veya kurs sahibi (Teacher)
                bool canApprove = user.Role == "Admin" || (user.Role == "Teacher" && course.CreatedBy == user.fldId);
                if (!canApprove)
                {
                    TempData["msgError"] = "Bu yorumu onaylama yetkiniz yok.";
                    return RedirectToAction("StudentIndex");
                }

                review.IsApproved = true;
                review.ApprovedBy = user.fldId;
                review.ApprovedDate = DateTime.Now;

                db.Entry(review).State = System.Data.Entity.EntityState.Modified;
                db.SaveChanges();

                // Bildirim: yorumu yazan kullanıcıya onay bilgisi gönder
                try
                {
                    var subject = "Kursa yaptığınız yorum onaylandı";
                    string courseLink = null;
                    try { courseLink = Url.Action("Details", "Course", new { id = course.CourseId }, Request?.Url?.Scheme); } catch { courseLink = Url.Action("Details", "Course", new { id = course.CourseId }); }

                    var recipient = db.E_User.FirstOrDefault(u => u.fldId == review.UserId);
                    var recipientName = recipient != null ? (recipient.fldName + " " + recipient.fldLastName).Trim() : "";

                    var content = $"Merhaba {recipientName},\n\nKursa yaptığınız yorum onaylandı ve şimdi yayınlanmıştır.\nKurs: {course.CourseTitle}\n\nYorumunuzu görmek için: {courseLink}";

                    var result = messageService.SendMessage(user.fldId, review.UserId, subject, content);
                    if (!result.Success)
                    {
                        System.Diagnostics.Trace.TraceWarning($"ApproveReview: bildirim gönderilemedi. {result.ErrorMessage}");
                        // Fallback: doğrudan E_Messages tablosuna kayıt oluştur
                        try
                        {
                            var fallback = new E_Messages
                            {
                                fldSendByName = user.fldName + " " + user.fldLastName,
                                fldSendBySicil = user.fldSicil,
                                fldSendByPhone = user.fldPhone,
                                fldSendByMail = user.fldEmail,
                                fldDateTime = DateTime.Now,
                                fldMessage = content,
                                fldSenderId = user.fldId,
                                fldSenderRole = user.Role,
                                fldRecipientId = review.UserId,
                                fldRecipientRole = recipient != null ? recipient.Role : null,
                                fldSubject = subject,
                                fldIsRead = false,
                                fldIsDeletedBySender = false,
                                fldIsDeletedByRecipient = false,
                                fldIsReply = false
                            };
                            db.E_Messages.Add(fallback);
                            db.SaveChanges();
                            TempData["msgSuccess"] = "Yorum onaylandı ve kullanıcı bilgilendirildi. (Fallback)";
                        }
                        catch (Exception ex2)
                        {
                            System.Diagnostics.Trace.TraceError($"ApproveReview Fallback Error: {ex2.Message}");
                            TempData["msgInfo"] = "Yorum onaylandı. Ancak bildirim gönderilemedi.";
                        }
                    }
                    else
                    {
                        TempData["msgSuccess"] = "Yorum onaylandı ve kullanıcı bilgilendirildi.";
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Trace.TraceError($"ApproveReview Notification Error: {ex.Message}");
                    TempData["msgSuccess"] = "Yorum onaylandı.";
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"ApproveReview Error: {ex.Message}");
                TempData["msgError"] = "Yorum onaylanırken hata oluştu.";
            }

            return RedirectToAction("PendingReviews", new { courseId = courseId });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ReplyReview(int reviewId, string replyText, int? courseId)
        {
            var user = GetCurrentUser();
            if (user == null) return RedirectToAction("Login", "Account");

            try
            {
                var review = db.CourseReviews.Find(reviewId);
                if (review == null)
                {
                    TempData["msgError"] = "Yorum bulunamadı.";
                    return RedirectToAction("Details", new { id = courseId });
                }

                var course = db.Courses.Find(review.CourseId);
                if (!CanModifyCourse(user, course))
                {
                    TempData["msgError"] = "Bu işlemi yapmaya yetkiniz yok.";
                    return RedirectToAction("Details", new { id = review.CourseId });
                }

                if (string.IsNullOrWhiteSpace(replyText))
                {
                    TempData["msgError"] = "Cevap boş olamaz.";
                    return RedirectToAction("Details", new { id = review.CourseId });
                }

                // Marker format: [[ADMIN_REPLY]]AdminName||ISODate||ReplyText
                string marker = "[[ADMIN_REPLY]]";
                string adminName = (user.fldName + " " + user.fldLastName).Trim();
                string meta = adminName + "||" + DateTime.Now.ToString("o") + "||" + replyText.Trim();

                if (string.IsNullOrEmpty(review.Comment))
                    review.Comment = "";

                // Remove existing marker if present (replace reply)
                int idx = review.Comment.IndexOf(marker);
                if (idx >= 0)
                {
                    review.Comment = review.Comment.Substring(0, idx).TrimEnd();
                }

                review.Comment = review.Comment + "\n\n" + marker + meta;

                db.Entry(review).State = EntityState.Modified;
                db.SaveChanges();

                // Bildirim: kullanıcının gelen kutusuna sistem mesajı gönder
                try
                {
                    var subject = "Kursa yaptığınız yoruma cevap geldi";
                    string courseLink = null;
                    try { courseLink = Url.Action("Details", "Course", new { id = course.CourseId }, Request?.Url?.Scheme); } catch { courseLink = Url.Action("Details", "Course", new { id = course.CourseId }); }

                    var recipient = db.E_User.FirstOrDefault(u => u.fldId == review.UserId);
                    var recipientName = recipient != null ? (recipient.fldName + " " + recipient.fldLastName).Trim() : "";

                    var content = $"Merhaba {recipientName},\n\nKursa yaptığınız yoruma bir yanıt geldi.\nKurs: {course.CourseTitle}\n\nCevap: {replyText}\n\nKursa gitmek için: {courseLink}";

                    var result = messageService.SendMessage(user.fldId, review.UserId, subject, content);
                    if (!result.Success)
                    {
                        System.Diagnostics.Trace.TraceWarning($"ReplyReview: bildirim gönderilemedi. {result.ErrorMessage}");
                        TempData["msgInfo"] = "Cevap kaydedildi. Ancak kullanıcıya bildirim gönderilemedi.";
                    }
                    else
                    {
                        TempData["msgSuccess"] = "Cevap kaydedildi ve kullanıcı bilgilendirildi.";
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Trace.TraceError($"ReplyReview Notification Error: {ex.Message}");
                    TempData["msgSuccess"] = "Cevap kaydedildi.";
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"ReplyReview Error: {ex.Message}");
                TempData["msgError"] = "Cevap kaydedilirken hata oluştu.";
            }

            return RedirectToAction("Details", new { id = courseId });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteReview(int reviewId, int? courseId)
        {
            var user = GetCurrentUser();
            if (user == null) return RedirectToAction("Login", "Account");
            if (user.Role != "Admin" && user.Role != "Teacher")
            {
                TempData["msgError"] = "Yetkiniz yok.";
                return RedirectToAction("StudentIndex");
            }

            try
            {
                var review = db.CourseReviews.Find(reviewId);
                if (review == null)
                {
                    TempData["msgError"] = "Yorum bulunamadı.";
                    return RedirectToAction("PendingReviews", new { courseId = courseId });
                }

                var course = db.Courses.Find(review.CourseId);
                if (course == null)
                {
                    TempData["msgError"] = "İlgili kurs bulunamadı.";
                    return RedirectToAction("PendingReviews", new { courseId = courseId });
                }

                // Yetki kontrolü: Admin veya kurs sahibi (Teacher)
                bool canDelete = user.Role == "Admin" || (user.Role == "Teacher" && course.CreatedBy == user.fldId);
                if (!canDelete)
                {
                    TempData["msgError"] = "Bu yorumu silme yetkiniz yok.";
                    return RedirectToAction("StudentIndex");
                }

                db.CourseReviews.Remove(review);
                db.SaveChanges();

                TempData["msgSuccess"] = "Yorum silindi.";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"DeleteReview Error: {ex.Message}");
                TempData["msgError"] = "Yorum silinirken hata oluştu.";
            }

            return RedirectToAction("PendingReviews", new { courseId = courseId });
        }


        // ---------------- CREATE CONTENT ----------------
        [HttpPost]
        [ValidateAntiForgeryToken]
        [ValidateInput(false)]
        public ActionResult CreateContent(CourseContentViewModel model)
        {
            var user = GetCurrentUser();
            if (user == null) return RedirectToAction("StudentIndex");

            var course = db.Courses.FirstOrDefault(c => c.CourseId == model.CourseId);
            if (course == null)
            {
                TempData["msgError"] = "Kurs bulunamadı.";
                return RedirectToAction("StudentIndex");
            }

            if (user.Role != "Admin" && course.CreatedBy != user.fldId)
            {
                TempData["msgError"] = "Bu işlemi yapmaya yetkiniz yok.";
                return RedirectToAction("Details", new { id = model.CourseId });
            }

            string uploadPath = GetUploadPath();

            string savedFileName = null;
            try
            {
                if (model.FileUpload != null && model.FileUpload.ContentLength > 0)
                {
                    string fileType = IsVideoFile(model.FileUpload.FileName) ? "video" : (IsImageFile(model.FileUpload.FileName) ? "image" : "ek dosya");
                    savedFileName = SecureFileUpload(model.FileUpload, uploadPath, ALLOWED_RESOURCE_EXTENSIONS, fileType);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"CreateContent Upload Error: {ex.Message}");
                TempData["msgError"] = ex.Message;
                return RedirectToAction("Details", new { id = model.CourseId });
            }

            var content = new CourseContents
            {
                CourseId = model.CourseId,
                ContentTitle = model.ContentTitle ?? "Başlıksız",
                ContentDescription = model.ContentDescription,
                ContentType = model.ContentType ?? (model.FileUpload != null && model.FileUpload.ContentLength > 0
                    ? (IsVideoFile(model.FileUpload.FileName) ? "VIDEO" : (IsImageFile(model.FileUpload.FileName) ? "IMAGE" : "DOCUMENT"))
                    : "PDF"),
                FilePath = savedFileName,
                CreatedDate = DateTime.Now
            };

            db.CourseContents.Add(content);
            db.SaveChanges();

            // HTML dosyayı kayıt SONRASINDA yaz
            try
            {
                WriteHtmlContentFile(content, model.ContentHtml);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"CreateContent HTML Save Error: {ex.Message}");
                TempData["msgWarning"] = "İçerik eklendi, ancak HTML dosyası yazılamadı: " + ex.Message;
                return RedirectToAction("Details", new { id = model.CourseId });
            }

            TempData["msgSuccess"] = "İçerik başarıyla eklendi.";
            return RedirectToAction("Details", new { id = model.CourseId });
        }

        // ---------------- EDIT CONTENT ----------------
        [HttpPost]
        [ValidateAntiForgeryToken]
        [ValidateInput(false)]
        public ActionResult EditContent(CourseContentViewModel model)
        {
            var user = GetCurrentUser();
            if (user == null) return RedirectToAction("StudentIndex");

            var content = db.CourseContents.FirstOrDefault(c => c.ContentId == model.ContentId);
            if (content == null)
            {
                TempData["msgError"] = "İçerik bulunamadı.";
                return RedirectToAction("StudentIndex");
            }

            var course = db.Courses.FirstOrDefault(c => c.CourseId == content.CourseId);
            if (course == null || (user.Role != "Admin" && course.CreatedBy != user.fldId))
            {
                TempData["msgError"] = "Bu işlemi yapmaya yetkiniz yok.";
                return RedirectToAction("Details", new { id = content.CourseId });
            }

            string uploadPath = GetUploadPath();

            try
            {
                if (model.FileUpload != null && model.FileUpload.ContentLength > 0)
                {
                    // eski dosyayı sil
                    if (!string.IsNullOrEmpty(content.FilePath))
                    {
                        string oldPath = Path.Combine(uploadPath, content.FilePath);
                        if (System.IO.File.Exists(oldPath)) System.IO.File.Delete(oldPath);
                    }

                    string fileType = IsVideoFile(model.FileUpload.FileName) ? "video" : (IsImageFile(model.FileUpload.FileName) ? "image" : "ek dosya");
                    string savedFileName = SecureFileUpload(model.FileUpload, uploadPath, ALLOWED_RESOURCE_EXTENSIONS, fileType);
                    content.FilePath = savedFileName;

                    // ContentType da güncelle
                    content.ContentType = model.ContentType ?? (IsVideoFile(model.FileUpload.FileName) ? "VIDEO" : (IsImageFile(model.FileUpload.FileName) ? "IMAGE" : "DOCUMENT"));
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"EditContent Upload Error: {ex.Message}");
                TempData["msgError"] = ex.Message;
                return RedirectToAction("Details", new { id = content.CourseId });
            }

            content.ContentTitle = model.ContentTitle;
            content.ContentDescription = model.ContentDescription;
            content.ContentType = string.IsNullOrWhiteSpace(model.ContentType) ? content.ContentType : model.ContentType;

            db.Entry(content).State = EntityState.Modified;
            db.SaveChanges();

            // HTML dosyayı kayıt SONRASINDA yaz
            try
            {
                WriteHtmlContentFile(content, model.ContentHtml);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"EditContent HTML Save Error: {ex.Message}");
                TempData["msgWarning"] = "İçerik güncellendi, ancak HTML dosyası yazılamadı: " + ex.Message;
                if (Request.Form["ReturnToContentDetail"] == "true")
                    return RedirectToAction("ContentDetail", new { id = content.ContentId });
                return RedirectToAction("Details", new { id = content.CourseId });
            }

            TempData["msgSuccess"] = "İçerik başarıyla güncellendi.";
            if (Request.Form["ReturnToContentDetail"] == "true")
                return RedirectToAction("ContentDetail", new { id = content.ContentId });
            if (Request.Form["ReturnToManageContents"] == "true")
                return RedirectToAction("ManageContents", new { courseId = content.CourseId });

            return RedirectToAction("Details", new { id = content.CourseId });
        }

        // ---------------- CREATE CONTENT FROM MODAL ----------------
        [HttpPost]
        [ValidateAntiForgeryToken]
        [ValidateInput(false)]
        public JsonResult CreateContentFromModal(CourseContentViewModel model)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null)
                    return Json(new { success = false, message = "Kullanıcı bilgisi bulunamadı." });

                if (model == null || model.CourseId <= 0)
                    return Json(new { success = false, message = "Kurs bilgisi geçersiz." });

                var course = db.Courses.FirstOrDefault(c => c.CourseId == model.CourseId);
                if (course == null)
                    return Json(new { success = false, message = "Kurs bulunamadı." });

                if (!CanModifyCourse(user, course))
                    return Json(new { success = false, message = "Bu işlemi yapmaya yetkiniz yok." });

                if (string.IsNullOrWhiteSpace(model.ContentTitle))
                    return Json(new { success = false, message = "İçerik başlığı boş olamaz." });

                string uploadPath = GetUploadPath();
                string savedFileName = null;

                if (model.FileUpload != null && model.FileUpload.ContentLength > 0)
                {
                    string fileType = IsVideoFile(model.FileUpload.FileName) ? "video" : (IsImageFile(model.FileUpload.FileName) ? "image" : "ek dosya");
                    try
                    {
                        savedFileName = SecureFileUpload(model.FileUpload, uploadPath, ALLOWED_RESOURCE_EXTENSIONS, fileType);
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Trace.TraceError($"CreateContentFromModal Upload Error: {ex.Message}");
                        return Json(new { success = false, message = "Dosya yükleme hatası: " + ex.Message });
                    }
                }

                // ContentType belirle
                string contentType = model.ContentType;
                if (string.IsNullOrWhiteSpace(contentType))
                {
                    if (model.FileUpload != null && model.FileUpload.ContentLength > 0)
                        contentType = IsVideoFile(model.FileUpload.FileName) ? "VIDEO" : (IsImageFile(model.FileUpload.FileName) ? "IMAGE" : "DOCUMENT");
                    else
                        contentType = "HTML"; // Varsayılan olarak HTML
                }

                var content = new CourseContents
                {
                    CourseId = model.CourseId,
                    ContentTitle = model.ContentTitle.Trim() ?? "Başlıksız",
                    ContentDescription = model.ContentDescription ?? string.Empty,
                    ContentType = contentType,
                    FilePath = savedFileName,
                    CreatedDate = DateTime.Now
                };

                db.CourseContents.Add(content);
                db.SaveChanges();

                // HTML dosyayı kayıt SONRASINDA yaz
                try
                {
                    if (!string.IsNullOrWhiteSpace(model.ContentHtml))
                    {
                        WriteHtmlContentFile(content, model.ContentHtml);
                    }
                }
                catch (Exception htmlEx)
                {
                    System.Diagnostics.Trace.TraceError($"CreateContentFromModal HTML Write Warning: {htmlEx.Message}");
                    // HTML dosya yazma hatası kritik değildir - içerik zaten kaydedildi
                }

                return Json(new { success = true, message = "İçerik başarıyla eklendi." });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"CreateContentFromModal Error: {ex.Message}\n{ex.StackTrace}");
                return Json(new { success = false, message = "İçerik eklenirken hata oluştu: " + ex.Message });
            }
        }

        // -------- GET CONTENT DATA (JSON for Edit Modal) --------
        [HttpGet]
        public JsonResult GetContentData(int id)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null)
                    return Json(new { success = false, message = "Kullanıcı bilgisi bulunamadı." }, JsonRequestBehavior.AllowGet);

                var content = db.CourseContents.FirstOrDefault(c => c.ContentId == id);
                if (content == null)
                    return Json(new { success = false, message = "İçerik bulunamadı." }, JsonRequestBehavior.AllowGet);

                var course = db.Courses.FirstOrDefault(c => c.CourseId == content.CourseId);
                if (course == null || !CanModifyCourse(user, course))
                    return Json(new { success = false, message = "Bu içeriği yönetme yetkiniz yok." }, JsonRequestBehavior.AllowGet);

                string contentHtml = string.Empty;
                if (IsHtmlContent(content))
                {
                    try
                    {
                        contentHtml = ReadHtmlContentFile(content);
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Trace.TraceError($"GetContentData HTML Read Error: {ex.Message}");
                    }
                }

                if (string.IsNullOrWhiteSpace(contentHtml))
                {
                    contentHtml = content.ContentDescription ?? string.Empty;
                }

                return Json(new
                {
                    success = true,
                    contentId = content.ContentId,
                    courseId = content.CourseId,
                    title = content.ContentTitle ?? "",
                    description = content.ContentDescription ?? "",
                    contentType = content.ContentType ?? "HTML",
                    filePath = content.FilePath ?? "",
                    fileName = !string.IsNullOrEmpty(content.FilePath) ? Path.GetFileName(content.FilePath) : "",
                    contentHtml = contentHtml
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"GetContentData Error: {ex.Message}");
                return Json(new { success = false, message = "İçerik bilgisi yüklenirken hata oluştu: " + ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        // -------- UPDATE CONTENT FROM MODAL (JSON) --------
        [HttpPost]
        [ValidateAntiForgeryToken]
        [ValidateInput(false)]
        public JsonResult UpdateContentFromModal(CourseContentViewModel model)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null)
                    return Json(new { success = false, message = "Kullanıcı bilgisi bulunamadı." });

                if (model == null || model.ContentId <= 0)
                    return Json(new { success = false, message = "Geçersiz içerik ID'si." });

                var content = db.CourseContents.FirstOrDefault(c => c.ContentId == model.ContentId);
                if (content == null)
                    return Json(new { success = false, message = "İçerik bulunamadı." });

                var course = db.Courses.FirstOrDefault(c => c.CourseId == content.CourseId);
                if (course == null || !CanModifyCourse(user, course))
                    return Json(new { success = false, message = "Bu işlemi yapmaya yetkiniz yok." });

                if (string.IsNullOrWhiteSpace(model.ContentTitle))
                    return Json(new { success = false, message = "İçerik başlığı boş olamaz." });

                string uploadPath = GetUploadPath();

                if (model.FileUpload != null && model.FileUpload.ContentLength > 0)
                {
                    // Eski dosyayı sil
                    if (!string.IsNullOrEmpty(content.FilePath))
                    {
                        string oldPath = Path.Combine(uploadPath, content.FilePath);
                        if (System.IO.File.Exists(oldPath)) System.IO.File.Delete(oldPath);
                    }

                    string fileType = IsVideoFile(model.FileUpload.FileName) ? "video" : (IsImageFile(model.FileUpload.FileName) ? "image" : "ek dosya");
                    string savedFileName = SecureFileUpload(model.FileUpload, uploadPath, ALLOWED_RESOURCE_EXTENSIONS, fileType);
                    content.FilePath = savedFileName;
                }

                content.ContentTitle = model.ContentTitle.Trim();
                content.ContentDescription = model.ContentDescription ?? string.Empty;
                if (!string.IsNullOrWhiteSpace(model.ContentType))
                {
                    content.ContentType = model.ContentType;
                }

                db.Entry(content).State = EntityState.Modified;
                db.SaveChanges();

                // HTML dosyasını yaz
                try
                {
                    if (!string.IsNullOrWhiteSpace(model.ContentHtml))
                    {
                        WriteHtmlContentFile(content, model.ContentHtml);
                    }
                }
                catch (Exception htmlEx)
                {
                    System.Diagnostics.Trace.TraceError($"UpdateContentFromModal HTML Write Warning: {htmlEx.Message}");
                }

                return Json(new { success = true, message = "İçerik başarıyla güncellendi." });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"UpdateContentFromModal Error: {ex.Message}\n{ex.StackTrace}");
                return Json(new { success = false, message = "İçerik güncellenirken hata oluştu: " + ex.Message });
            }
        }

        public ActionResult GetCourseContents(int courseId)
        {
            var user = GetCurrentUser();
            if (user == null)
                return new HttpUnauthorizedResult();

            var course = db.Courses.FirstOrDefault(c => c.CourseId == courseId && c.IsDeleted != true);
            if (course == null)
                return HttpNotFound();

            bool canModify = CanModifyCourse(user, course);
            bool isEnrolled = db.CourseEnrollments.Any(e => e.CourseId == courseId && e.UserId == user.fldId);
            if ((!course.IsActive && !canModify) || (!isEnrolled && !canModify))
                return new HttpUnauthorizedResult();

            var contents = db.CourseContents
                             .Where(c => c.CourseId == courseId)
                             .OrderBy(c => c.ContentId)
                             .ToList();

            ViewBag.CourseId = courseId;
            ViewBag.CurrentUser = GetCurrentUser(); // mevcut kullanıcıyı ViewBag’e ekle

            return PartialView("_CourseContentsPartial", contents);
        }

        [HttpGet]
        public JsonResult GetContentHtml(int contentId)
        {
            try
            {
                var user = GetCurrentUser();
                var content = db.CourseContents.Include(c => c.Courses).FirstOrDefault(c => c.ContentId == contentId);
                if (user == null || content == null)
                    return Json(new { success = false, message = "Icerik veya kullanici bulunamadi." }, JsonRequestBehavior.AllowGet);

                if (!CanModifyCourse(user, content.Courses))
                    return Json(new { success = false, message = "Bu icerigi duzenleme yetkiniz yok." }, JsonRequestBehavior.AllowGet);

                if (!IsHtmlContent(content))
                    return Json(new { success = false, message = "Bu icerik HTML degil." }, JsonRequestBehavior.AllowGet);

                var html = ReadHtmlContentFile(content);
                return Json(new { success = true, html = html }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"GetContentHtml Error: {ex.Message}");
                return Json(new { success = false, message = "HTML icerik yuklenirken hata olustu: " + ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [ValidateInput(false)]
        public JsonResult EditContentFromModal(CourseContentViewModel model)
        {
            try
            {
                var user = GetCurrentUser();
                var content = db.CourseContents.FirstOrDefault(c => c.ContentId == model.ContentId);
                if (user == null || content == null) return Json(new { success = false, message = "İçerik veya kullanıcı bulunamadı." });
                var course = db.Courses.FirstOrDefault(c => c.CourseId == content.CourseId);
                if (course == null || !CanModifyCourse(user, course)) return Json(new { success = false, message = "Bu içeriği düzenleme yetkiniz yok." });
                if (string.IsNullOrWhiteSpace(model.ContentTitle)) return Json(new { success = false, message = "İçerik başlığı boş olamaz." });

                if (model.FileUpload != null && model.FileUpload.ContentLength > 0)
                {
                    var uploadPath = GetUploadPath();
                    var fileType = IsVideoFile(model.FileUpload.FileName) ? "video" : (IsImageFile(model.FileUpload.FileName) ? "image" : "ek dosya");
                    var savedFileName = SecureFileUpload(model.FileUpload, uploadPath, ALLOWED_RESOURCE_EXTENSIONS, fileType);
                    var oldFile = string.IsNullOrWhiteSpace(content.FilePath) ? null : Path.Combine(uploadPath, content.FilePath);
                    content.FilePath = savedFileName;
                    if (!string.IsNullOrWhiteSpace(oldFile) && System.IO.File.Exists(oldFile)) System.IO.File.Delete(oldFile);
                }

                content.ContentTitle = model.ContentTitle.Trim();
                content.ContentDescription = model.ContentDescription;
                content.ContentType = string.IsNullOrWhiteSpace(model.ContentType) ? content.ContentType : model.ContentType;

                // Database'e kaydet (HTML dosya yazma işleminden ÖNCE)
                db.SaveChanges();

                // Sonrasında HTML dosyayı yaz - hata olursa database değişiklikleri zaten kaydedilmiş olur
                try
                {
                    WriteHtmlContentFile(content, model.ContentHtml);
                }
                catch (Exception htmlEx)
                {
                    System.Diagnostics.Trace.TraceError($"EditContentFromModal HTML Write Warning: {htmlEx.Message}");
                    // HTML dosya yazma hatası kritik değildir - içerik zaten kaydedildi
                }

                return Json(new { success = true, message = "İçerik başarıyla güncellendi." });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"EditContentFromModal Error: {ex.Message}");
                return Json(new { success = false, message = "İçerik güncellenirken hata oluştu: " + ex.Message });
            }
        }

        // ---------------- DELETE CONTENT FROM MODAL ----------------
        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult DeleteContentFromModal(int contentId)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null)
                    return Json(new { success = false, message = "Kullanıcı bilgisi bulunamadı." });

                var content = db.CourseContents.FirstOrDefault(c => c.ContentId == contentId);
                if (content == null)
                    return Json(new { success = false, message = "İçerik bulunamadı." });

                var course = db.Courses.FirstOrDefault(c => c.CourseId == content.CourseId);
                if (course == null || !CanModifyCourse(user, course))
                    return Json(new { success = false, message = "Bu işlemi yapmaya yetkiniz yok." });

                string uploadPath = GetUploadPath();
                if (!string.IsNullOrEmpty(content.FilePath))
                {
                    string filePath = Path.Combine(uploadPath, content.FilePath);
                    if (System.IO.File.Exists(filePath))
                        System.IO.File.Delete(filePath);
                }

                db.CourseContents.Remove(content);
                db.SaveChanges();

                return Json(new { success = true, message = "İçerik başarıyla silindi." });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"DeleteContentFromModal Error: {ex.Message}");
                return Json(new { success = false, message = "İçerik silinirken hata: " + ex.Message });
            }
        }
        // ---------------- DELETE CONTENT ----------------
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteContent(int ContentId)
        {
            var user = GetCurrentUser();
            var content = db.CourseContents.FirstOrDefault(c => c.ContentId == ContentId);
            if (content == null) return RedirectToAction("StudentIndex");

            var course = db.Courses.FirstOrDefault(c => c.CourseId == content.CourseId);
            if (course == null || (user.Role != "Admin" && course.CreatedBy != user.fldId))
                return RedirectToAction("Details", new { id = content.CourseId });

            string uploadPath = GetUploadPath();
            if (!string.IsNullOrEmpty(content.FilePath))
            {
                string filePath = Path.Combine(uploadPath, content.FilePath);
                if (System.IO.File.Exists(filePath)) System.IO.File.Delete(filePath);
            }

            db.CourseContents.Remove(content);
            db.SaveChanges();

            TempData["msgSuccess"] = "İçerik başarıyla silindi.";
            if (Request.Form["ReturnToManageContents"] == "true" || Request.QueryString["returnToManage"] == "true")
                return RedirectToAction("ManageContents", new { courseId = content.CourseId });
            return RedirectToAction("Details", new { id = content.CourseId });
        }

        // -------- MANAGE CONTENTS (İçerik Yönetimi) --------
        [HttpGet]
        public ActionResult ManageContents(int? courseId)
        {
            try
            {
                Response.ContentEncoding = Encoding.UTF8;
                Response.Charset = "utf-8";

                var user = GetCurrentUser();
                if (user == null)
                {
                    TempData["msgError"] = "Kullanıcı bilgisi bulunamadı.";
                    return RedirectToAction("StudentIndex");
                }

                // courseId parametresi yoksa StudentIndex'e yönlendir
                if (!courseId.HasValue || courseId.Value <= 0)
                {
                    TempData["msgError"] = "Kurs seçilmedi. Lütfen bir kurs seçiniz.";
                    return RedirectToAction("StudentIndex");
                }

                var course = db.Courses.FirstOrDefault(c => c.CourseId == courseId.Value);
                if (course == null)
                {
                    TempData["msgError"] = "Kurs bulunamadı.";
                    return RedirectToAction("StudentIndex");
                }

                // Yetki kontrolü: Admin veya Kurs Sahibi Teacher
                if (user.Role != "Admin" && course.CreatedBy != user.fldId)
                {
                    TempData["msgError"] = "Bu kursun içeriklerini yönetme yetkiniz yok.";
                    return RedirectToAction("StudentIndex");
                }

                // CourseContents listesini getir
                var contents = db.CourseContents
                    .Where(c => c.CourseId == courseId.Value)
                    .OrderBy(c => c.ContentId)
                    .Select(c => new CourseContentItemViewModel
                    {
                        ContentId = c.ContentId,
                        ContentTitle = c.ContentTitle,
                        ContentDescription = c.ContentDescription,
                        ContentType = c.ContentType,
                        FilePath = c.FilePath,
                        CreatedDate = c.CreatedDate
                    })
                    .ToList();

                var model = new CourseContentViewModel
                {
                    CourseId = courseId.Value,
                    Contents = contents
                };

                ViewBag.CourseTitle = course.CourseTitle;
                ViewBag.CurrentUser = user;

                return View("ManageContents", model);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"ManageContents Error: {ex.Message}\n{ex.StackTrace}");
                TempData["msgError"] = "İçerikleri yüklerken hata oluştu: " + ex.Message;
                return RedirectToAction("StudentIndex");
            }
        }

        // -------- UPDATE CONTENTS (Batch Update) --------
        [HttpPost]
        [ValidateAntiForgeryToken]
        [ValidateInput(false)]
        public ActionResult UpdateContentsList(int courseId, List<CourseContentItemViewModel> contents)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null)
                {
                    TempData["msgError"] = "Kullanıcı bilgisi bulunamadı.";
                    return RedirectToAction("ManageContents", new { courseId = courseId });
                }

                var course = db.Courses.FirstOrDefault(c => c.CourseId == courseId);
                if (course == null)
                {
                    TempData["msgError"] = "Kurs bulunamadı.";
                    return RedirectToAction("StudentIndex");
                }

                // Yetki kontrolü
                if (user.Role != "Admin" && course.CreatedBy != user.fldId)
                {
                    TempData["msgError"] = "Bu işlemi yapmaya yetkiniz yok.";
                    return RedirectToAction("StudentIndex");
                }

                if (contents != null && contents.Count > 0)
                {
                    foreach (var item in contents)
                    {
                        var content = db.CourseContents.FirstOrDefault(c => c.ContentId == item.ContentId);
                        if (content != null)
                        {
                            content.ContentTitle = item.ContentTitle;
                            content.ContentDescription = item.ContentDescription;
                            content.ContentType = item.ContentType;

                            db.Entry(content).State = EntityState.Modified;
                        }
                    }

                    db.SaveChanges();
                    TempData["msgSuccess"] = "İçerikler başarıyla güncellendi.";
                }

                return RedirectToAction("ManageContents", new { courseId = courseId });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"UpdateContentsList Error: {ex.Message}");
                TempData["msgError"] = "İçerikler güncellenirken hata oluştu: " + ex.Message;
                return RedirectToAction("ManageContents", new { courseId = courseId });
            }
        }

        // ---------------- CONTENT DETAILS ----------------
        public ActionResult ContentDetail(int id) // ContentId
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null)
                {
                    TempData["msgError"] = "İçeriği görüntülemek için giriş yapmalısınız.";
                    return RedirectToAction("Login", "Account");
                }

                var content = db.CourseContents
                               .Include(c => c.Courses)
                               .Include(c => c.Courses.Categories)
                               .FirstOrDefault(c => c.ContentId == id);

                if (content == null)
                {
                    TempData["msgError"] = "İçerik bulunamadı.";
                    return RedirectToAction("StudentIndex");
                }

                // Kullanıcı bu kursa kayıtlı mı kontrol et
                bool isEnrolled = db.CourseEnrollments
                                   .Any(e => e.CourseId == content.CourseId && e.UserId == user.fldId);

                bool canAccess = isEnrolled ||
                                user.Role == "Admin" ||
                                content.Courses.CreatedBy == user.fldId;
                bool canModifyContent = CanModifyCourse(user, content.Courses);
                string contentHtml = null;

                if (!canAccess)
                {
                    TempData["msgError"] = "Bu içeriği görüntüleme yetkiniz yok.";
                    return RedirectToAction("Details", new { id = content.CourseId });
                }

                if (IsHtmlContent(content))
                {
                    try
                    {
                        contentHtml = ReadHtmlContentFile(content);
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Trace.TraceError($"ContentDetail HTML Read Error: {ex.Message}");
                        if (!string.IsNullOrWhiteSpace(content.ContentDescription) &&
                            (content.ContentDescription.IndexOf("<html", StringComparison.OrdinalIgnoreCase) >= 0 ||
                             content.ContentDescription.IndexOf("<meta", StringComparison.OrdinalIgnoreCase) >= 0 ||
                             content.ContentDescription.IndexOf("<div", StringComparison.OrdinalIgnoreCase) >= 0 ||
                             content.ContentDescription.IndexOf("<p", StringComparison.OrdinalIgnoreCase) >= 0 ||
                             content.ContentDescription.IndexOf("<style", StringComparison.OrdinalIgnoreCase) >= 0 ||
                             content.ContentDescription.IndexOf("<title", StringComparison.OrdinalIgnoreCase) >= 0))
                        {
                            contentHtml = content.ContentDescription;
                            try
                            {
                                WriteHtmlContentFile(content, contentHtml);
                            }
                            catch (Exception wEx)
                            {
                                System.Diagnostics.Trace.TraceError($"Auto-create HTML file error: {wEx.Message}");
                            }
                        }
                        else
                        {
                            TempData["msgError"] = "HTML dosyası okunamadı: " + ex.Message;
                        }
                    }

                    if (string.IsNullOrWhiteSpace(contentHtml) && !string.IsNullOrWhiteSpace(content.ContentDescription))
                    {
                        contentHtml = content.ContentDescription;
                    }
                }

                var model = new CourseContentViewModel
                {
                    ContentId = content.ContentId,
                    ContentTitle = content.ContentTitle,
                    ContentType = content.ContentType,
                    CourseId = content.CourseId,
                    ContentDescription = content.ContentDescription,
                    ContentHtml = contentHtml
                };


                // Ek bilgileri ViewBag ile gönder
                ViewBag.FilePath = content.FilePath;
                ViewBag.CreatedDate = content.CreatedDate;
                ViewBag.CourseTitle = content.Courses.CourseTitle;
                ViewBag.CourseDescription = content.Courses.CourseDescription;
                ViewBag.NextContentId = GetNextContentIdMethod(content.CourseId, content.ContentId);
                ViewBag.PreviousContentId = GetPreviousContentIdMethod(content.CourseId, content.ContentId);
                ViewBag.CurrentUser = user;
                ViewBag.CanModifyContent = canModifyContent;
                ViewBag.AllContents = db.CourseContents.Where(c => c.CourseId == content.CourseId).OrderBy(c => c.ContentId).ToList();

                // İçeriğe ait sınavları getir (kursa ait aktif sınavlar)
                var contentExams = db.Exam
                    .Where(e => e.CourseId == content.CourseId && e.IsActive == true)
                    .Select(e => new ExamViewModel
                    {
                        ExamId = e.ExamId,
                        ExamTitle = e.Title,
                        ExamDescription = e.Description,
                        Duration = e.DurationMinutes ?? 60,
                        PassingScore = e.PassingScore ?? 60,
                        QuestionCount = db.Question.Count(q => q.ExamId == e.ExamId),
                        ExamResultId = db.ExamResult
                            .Where(er => er.ExamId == e.ExamId && er.UserId == user.fldId && er.Status == 1)
                            .Select(er => (int?)er.ExamResultId)
                            .FirstOrDefault()
                    })
                    .ToList();

                ViewBag.ContentExams = contentExams;

                return View(model);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"ContentDetail Error: {ex.Message}");
                TempData["msgError"] = "İçerik yüklenirken hata oluştu.";
                return RedirectToAction("StudentIndex");
            }
        }

        public ActionResult DownloadContent(int id)
        {
            var user = GetCurrentUser();
            if (user == null) return new HttpStatusCodeResult(401, "İndirmek için giriş yapmalısınız.");

            var content = db.CourseContents.Include(c => c.Courses).FirstOrDefault(c => c.ContentId == id);
            if (content == null || string.IsNullOrWhiteSpace(content.FilePath)) return HttpNotFound("İçerik dosyası bulunamadı.");

            var canAccess = user.Role == "Admin"
                || content.Courses.CreatedBy == user.fldId
                || db.CourseEnrollments.Any(e => e.CourseId == content.CourseId && e.UserId == user.fldId);
            if (!canAccess) return new HttpStatusCodeResult(403, "Bu içeriği indirme yetkiniz yok.");
            if (content.FilePath.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                return new HttpStatusCodeResult(400, "Harici bağlantılar paketlenerek indirilemez.");

            var relativePath = content.FilePath.Trim().TrimStart('~', '/').Replace('/', Path.DirectorySeparatorChar);
            var storagePrefix = "files" + Path.DirectorySeparatorChar + "Egitim" + Path.DirectorySeparatorChar;
            if (relativePath.StartsWith(storagePrefix, StringComparison.OrdinalIgnoreCase))
                relativePath = relativePath.Substring(storagePrefix.Length);

            var basePath = FileStorageHelper.MapPath(Server, "~/files/Egitim/");
            var baseNormalized = Path.GetFullPath(basePath).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            var physicalPath = Path.GetFullPath(Path.Combine(baseNormalized, relativePath));
            if (!physicalPath.StartsWith(baseNormalized, StringComparison.OrdinalIgnoreCase))
                return new HttpStatusCodeResult(403, "Geçersiz içerik yolu.");
            if (!System.IO.File.Exists(physicalPath)) return HttpNotFound("İçerik dosyası bulunamadı.");

            var extension = Path.GetExtension(physicalPath);
            if (!string.Equals(extension, ".html", StringComparison.OrdinalIgnoreCase)
                && !string.Equals(extension, ".htm", StringComparison.OrdinalIgnoreCase))
                return File(physicalPath, MimeMapping.GetMimeMapping(physicalPath), Path.GetFileName(physicalPath));

            var directory = Path.GetDirectoryName(physicalPath);
            var relativeDirectory = Path.GetDirectoryName(relativePath)?.Replace(Path.DirectorySeparatorChar, '/').Trim('/');
            var urlPrefix = "/files/Egitim/" + (string.IsNullOrEmpty(relativeDirectory) ? "" : relativeDirectory + "/");
            var html = System.IO.File.ReadAllText(physicalPath, Encoding.UTF8)
                .Replace("\"" + urlPrefix, "\"")
                .Replace("'" + urlPrefix, "'");

            var output = new MemoryStream();
            using (var archive = new ZipArchive(output, ZipArchiveMode.Create, true, Encoding.UTF8))
            {
                var indexEntry = archive.CreateEntry("index.html", CompressionLevel.Optimal);
                using (var writer = new StreamWriter(indexEntry.Open(), new UTF8Encoding(false))) writer.Write(html);

                var allowed = new HashSet<string>(StringComparer.OrdinalIgnoreCase) { ".jpg", ".jpeg", ".png", ".gif", ".webp", ".bmp", ".svg", ".css" };
                foreach (var file in Directory.GetFiles(directory, "*.*", SearchOption.AllDirectories).Where(x => allowed.Contains(Path.GetExtension(x))))
                {
                    var entryName = file.Substring(directory.Length).TrimStart(Path.DirectorySeparatorChar).Replace(Path.DirectorySeparatorChar, '/');
                    archive.CreateEntryFromFile(file, entryName, CompressionLevel.Optimal);
                }
            }
            output.Position = 0;
            var safeTitle = string.Concat((content.ContentTitle ?? "egitim").Select(ch => Path.GetInvalidFileNameChars().Contains(ch) ? '_' : ch)).Trim();
            if (string.IsNullOrWhiteSpace(safeTitle)) safeTitle = "egitim";
            return File(output, "application/zip", safeTitle + "-cevrimdisi.zip");
        }

        private int? GetNextContentIdMethod(int courseId, int currentContentId)
        {
            var next = db.CourseContents
                        .Where(c => c.CourseId == courseId && c.ContentId > currentContentId)
                        .OrderBy(c => c.ContentId)
                        .Select(c => c.ContentId)
                        .FirstOrDefault();
            return next > 0 ? (int?)next : null;
        }

        private int? GetPreviousContentIdMethod(int courseId, int currentContentId)
        {
            var previous = db.CourseContents
                            .Where(c => c.CourseId == courseId && c.ContentId < currentContentId)
                            .OrderByDescending(c => c.ContentId)
                            .Select(c => c.ContentId)
                            .FirstOrDefault();
            return previous > 0 ? (int?)previous : null;
        }

        private int? GetNextContentId(int courseId, int currentContentId)
        {
            var next = db.CourseContents
                        .Where(c => c.CourseId == courseId && c.ContentId > currentContentId)
                        .OrderBy(c => c.ContentId)
                        .Select(c => c.ContentId)
                        .FirstOrDefault();
            return next > 0 ? next : (int?)null;
        }

        private int? GetPreviousContentId(int courseId, int currentContentId)
        {
            var previous = db.CourseContents
                            .Where(c => c.CourseId == courseId && c.ContentId < currentContentId)
                            .OrderByDescending(c => c.ContentId)
                            .Select(c => c.ContentId)
                            .FirstOrDefault();
            return previous > 0 ? previous : (int?)null;
        }

        // ---------------- CERTIFICATE REQUEST ----------------
        private bool AllExamsCompleted(int userId, int courseId)
        {
            var exams = db.Exam
                .Where(e => e.CourseId == courseId && e.IsActive == true)
                .Select(e => new
                {
                    e.ExamId,
                    PassingScore = e.PassingScore ?? 60,
                    MaxScore = db.Question
                        .Where(q => q.ExamId == e.ExamId && q.IsActive == true)
                        .Sum(q => (int?)q.Points) ?? 0
                })
                .ToList();

            if (!exams.Any()) return false;

            foreach (var exam in exams)
            {
                if (exam.MaxScore <= 0) return false;

                var bestScore = db.ExamResult
                    .Where(er => er.ExamId == exam.ExamId && er.UserId == userId && er.Status == 1)
                    .Select(er => er.Score)
                    .ToList()
                    .DefaultIfEmpty(0)
                    .Max() ?? 0;

                decimal percentage = (bestScore / exam.MaxScore) * 100;
                if (percentage < exam.PassingScore) return false;
            }
            return true;
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult RequestCertificate(int courseId)
        {
            var user = GetCurrentUser();
            if (user == null)
            {
                TempData["msgError"] = "Lütfen giriş yapın.";
                return RedirectToAction("Details", new { id = courseId });
            }

            bool isEnrolled = db.CourseEnrollments.Any(e => e.CourseId == courseId && e.UserId == user.fldId);
            if (!isEnrolled)
            {
                TempData["msgError"] = "Bu kursa kayıtlı değilsiniz.";
                return RedirectToAction("Details", new { id = courseId });
            }

            if (!AllExamsCompleted(user.fldId, courseId))
            {
                TempData["msgError"] = "Sertifika talep edebilmek için kursa ait tüm sınavları tamamlamanız gerekmektedir.";
                return RedirectToAction("Details", new { id = courseId });
            }

            bool existingRequest = db.CertificateRequest.Any(r =>
                r.UserId == user.fldId &&
                r.CourseId == courseId &&
                (r.Status == 0 || r.Status == 1));

            if (existingRequest)
            {
                TempData["msgInfo"] = "Bu kurs için zaten bir sertifika talebiniz bulunmaktadır.";
                return RedirectToAction("Details", new { id = courseId });
            }

            var request = new CertificateRequest
            {
                UserId = user.fldId,
                CourseId = courseId,
                RequestDate = DateTime.Now,
                Status = 0
            };

            db.CertificateRequest.Add(request);
            db.SaveChanges();

            TempData["msgSuccess"] = "Sertifika talebiniz alındı. Admin onayından sonra sertifikanız hazırlanacaktır.";
            return RedirectToAction("Details", new { id = courseId });
        }
        // ---------------- DRAW ENTRY ----------------
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ToggleDrawEntry(int courseId, bool join)
        {
            var user = GetCurrentUser();
            if (user == null) return RedirectToAction("Login", "Account");

            var enrollment = db.CourseEnrollments.FirstOrDefault(e => e.CourseId == courseId && e.UserId == user.fldId);
            if (enrollment == null)
            {
                TempData["msgError"] = "Kursa kayıtlı değilsiniz.";
                return RedirectToAction("Details", new { id = courseId });
            }

            enrollment.IsDrawEntry = join;
            enrollment.DrawEntryDate = join ? (DateTime?)DateTime.UtcNow : null;
            db.Entry(enrollment).State = System.Data.Entity.EntityState.Modified;
            db.SaveChanges();

            TempData["msgSuccess"] = join ? "Çekilişe kaydınız alındı." : "Çekilişten çıkarıldınız.";
            return RedirectToAction("Details", new { id = courseId });
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing) db?.Dispose();
            base.Dispose(disposing);
        }
    }

}
