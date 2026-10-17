using gzpegm.Cont;
using gzpegm.Helpers;
using gzpegm.Models;
using gzpegm.Models.ViewModels;
using gzpegm.Services;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize(Users = "2")]
    public class EducationPackageController : Controller
    {
        private readonly GZPEGM1 db = new GZPEGM1();

        private EducationPackageService Service => new EducationPackageService(db, Server);

        public ActionResult Index()
        {
            var model = new EducationPackageIndexViewModel
            {
                CourseCount = db.Courses.Count(x => x.IsDeleted != true),
                DraftCount = db.Courses.Count(x => x.IsDeleted != true && !x.IsActive)
            };
            try
            {
                var logs = Service.GetLogs();
                model.ImportCount = logs.Count;
                model.LastImportDate = logs.Select(x => (DateTime?)x.ImportedDate).FirstOrDefault();
            }
            catch { ViewBag.SchemaMissing = true; }
            return View(model);
        }

        [HttpGet]
        public ActionResult Export()
        {
            return View(BuildExportModel(new EducationPackageExportViewModel()));
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult Export(EducationPackageExportViewModel model)
        {
            if (!ModelState.IsValid) return View(BuildExportModel(model));
            try
            {
                ValidateExportReady(model.CourseId);
                string fileName;
                var bytes = Service.Export(model, CurrentUserId(), out fileName);
                return File(bytes, "application/octet-stream", fileName);
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("", ex.Message);
                return View(BuildExportModel(model));
            }
        }

        [HttpGet]
        public ActionResult Import()
        {
            ViewBag.MaximumPackageMb = Service.MaximumPackageBytes / 1024 / 1024;
            return View(new EducationPackageImportViewModel());
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult Import(EducationPackageImportViewModel model)
        {
            ViewBag.MaximumPackageMb = Service.MaximumPackageBytes / 1024 / 1024;
            if (model.PackageFile == null || model.PackageFile.ContentLength == 0)
                ModelState.AddModelError("PackageFile", "Bir .cezapkg dosyası seçin.");
            else if (!string.Equals(System.IO.Path.GetExtension(model.PackageFile.FileName), ".cezapkg", StringComparison.OrdinalIgnoreCase))
                ModelState.AddModelError("PackageFile", "Yalnızca .cezapkg uzantılı dosya kabul edilir.");
            if (!ModelState.IsValid) return View(model);

            try
            {
                var result = Service.Import(model.PackageFile.InputStream, model.PackageFile.FileName, model.Mode, CurrentUserId());
                TempData[result.Success ? "msgSuccess" : "msgError"] = result.Message;
                if (result.Success && result.CourseId.HasValue) return RedirectToAction("Review", new { id = result.CourseId.Value });
                return RedirectToAction(result.Success ? "Logs" : "Import");
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("", ex.Message);
                return View(model);
            }
        }

        public ActionResult Logs()
        {
            try { return View(Service.GetLogs()); }
            catch (Exception ex)
            {
                TempData["msgError"] = "Import log tablosu okunamadı. SQL kurulum scriptini çalıştırın. " + ex.Message;
                return View(Enumerable.Empty<EducationPackageImportLog>().ToList());
            }
        }

        [HttpGet]
        public ActionResult PradoImport()
        {
            var service = new PradoCourseImportService(db, Server);
            ViewBag.MaximumPackageMb = service.MaximumZipBytes / 1024 / 1024;
            return View(new PradoCourseImportViewModel());
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult PradoImport(PradoCourseImportViewModel model)
        {
            var service = new PradoCourseImportService(db, Server);
            ViewBag.MaximumPackageMb = service.MaximumZipBytes / 1024 / 1024;
            if (model.ZipFile == null || model.ZipFile.ContentLength == 0)
                ModelState.AddModelError("ZipFile", "Kaydettiğiniz web sayfasını ve görsel klasörünü içeren ZIP dosyasını seçin.");
            else if (!string.Equals(System.IO.Path.GetExtension(model.ZipFile.FileName), ".zip", StringComparison.OrdinalIgnoreCase))
                ModelState.AddModelError("ZipFile", "Bu alanda yalnızca .zip dosyası kabul edilir.");
            if (model.CoverMode == CourseCoverMode.CustomUpload && (model.CustomCoverFile == null || model.CustomCoverFile.ContentLength == 0))
                ModelState.AddModelError("CustomCoverFile", "Özel kapak seçeneği için bir görsel yükleyin.");
            if (!ModelState.IsValid) return View(model);
            try
            {
                var result = service.Import(model.ZipFile.InputStream, model.ZipFile.FileName, model, CurrentUserId());
                if (result == null) throw new InvalidOperationException("İçe aktarım sonucu alınamadı.");
                TempData["msgSuccess"] = result.Message;
                if (result.TitleMissing)
                    TempData["msgWarningTitleMissing"] = "Kaynak sayfadan kurs başlığı bulunamadı. Lütfen manuel başlık ekleyiniz.";
                return RedirectToAction("Review", new { id = result.CourseId });
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("", ex.Message);
                return View(model);
            }
        }

        public ActionResult Drafts()
        {
            var drafts = db.Courses.AsNoTracking()
                .Where(x => x.IsDeleted != true && !x.IsActive)
                .OrderByDescending(x => x.CreatedDate)
                .ToList();
            return View(drafts);
        }

        public ActionResult Review(int? id = null)
        {
            if (!id.HasValue || id.Value <= 0)
            {
                var defaultDraft = db.Courses.AsNoTracking()
                    .Where(x => x.IsDeleted != true && !x.IsActive)
                    .OrderByDescending(x => x.CreatedDate)
                    .Select(x => (int?)x.CourseId)
                    .FirstOrDefault();

                if (defaultDraft.HasValue)
                {
                    return RedirectToAction("Review", new { id = defaultDraft.Value });
                }

                var anyCourse = db.Courses.AsNoTracking()
                    .Where(x => x.IsDeleted != true)
                    .OrderByDescending(x => x.CreatedDate)
                    .Select(x => (int?)x.CourseId)
                    .FirstOrDefault();

                if (anyCourse.HasValue)
                {
                    return RedirectToAction("Review", new { id = anyCourse.Value });
                }

                TempData["msgInfo"] = "İncelenebilecek herhangi bir eğitim veya taslak kurs bulunamadı.";
                return RedirectToAction("Drafts");
            }

            var model = BuildReviewModel(id.Value);
            if (model == null) return HttpNotFound("Kurs bulunamadı.");
            return View(model);
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult Publish(int id)
        {
            var model = BuildReviewModel(id);
            if (model == null) return HttpNotFound("Kurs bulunamadı.");
            if (!model.CanPublish)
            {
                TempData["msgError"] = "Zorunlu hatalar düzeltilmeden eğitim yayınlanamaz.";
                return RedirectToAction("Review", new { id });
            }

            using (var transaction = db.Database.BeginTransaction())
            {
                try
                {
                    var course = db.Courses.Find(id);
                    course.IsActive = true;
                    var exams = db.Exam.Where(x => x.CourseId == id).ToList();
                    foreach (var exam in exams) { exam.IsActive = true; exam.IsArchived = false; }
                    var examIds = exams.Select(x => x.ExamId).ToList();
                    foreach (var question in db.Question.Where(x => examIds.Contains(x.ExamId))) question.IsActive = true;
                    db.SaveChanges();
                    transaction.Commit();
                    CacheService.Remove("AllActiveCourses");
                    CacheService.Remove("Landing_ActiveCoursePreview_v1");
                    TempData["msgSuccess"] = "Eğitim, sınavlar ve sorular kontrol edilerek yayınlandı.";
                    return RedirectToAction("Details", "Course", new { id });
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    System.Diagnostics.Trace.TraceError("EducationPackage Publish hatası - CourseId={0}: {1}", id, ex);
                    TempData["msgError"] = "Yayınlama işlemi tamamlanamadı: " + ex.Message;
                    return RedirectToAction("Review", new { id });
                }
            }
        }

        private EducationReviewViewModel BuildReviewModel(int courseId)
        {
            var course = db.Courses.AsNoTracking().FirstOrDefault(x => x.CourseId == courseId && x.IsDeleted != true);
            if (course == null) return null;
            var model = new EducationReviewViewModel
            {
                CourseId = course.CourseId,
                CourseTitle = course.CourseTitle,
                CourseDescription = course.CourseDescription,
                CoverImageUrl = string.IsNullOrWhiteSpace(course.CoverImage) ? null : Url.Content("~/files/Egitim/" + course.CoverImage.TrimStart('/', '~')),
                IsPublished = course.IsActive
            };
            Action<string, string, string, string> issue = (severity, area, message, editUrl) => model.Issues.Add(new EducationReviewIssueViewModel { Severity = severity, Area = area, Message = message, EditUrl = editUrl });
            var courseEdit = Url.Action("Index", "Course", new { editCourseId = courseId });
            var contentEdit = Url.Action("ManageContents", "Course", new { courseId = courseId });

            if (string.IsNullOrWhiteSpace(course.CourseTitle)) issue("Error", "Kurs", "Kurs başlığı boş.", courseEdit);
            else if (course.CourseTitle.StartsWith("WEB-", StringComparison.OrdinalIgnoreCase)) issue("Warning", "Kurs", "Otomatik başlığı kontrol edin.", courseEdit);
            if (string.IsNullOrWhiteSpace(course.CourseDescription)) issue("Warning", "Kurs", "Kurs açıklaması boş.", courseEdit);
            if (string.IsNullOrWhiteSpace(course.CoverImage)) issue("Warning", "Kurs", "Kapak görseli seçilmemiş.", courseEdit);
            else if (!StoredFileExists(course.CoverImage, false)) issue("Error", "Kurs", "Kapak görseli dosyası bulunamadı.", courseEdit);
            if (!string.IsNullOrWhiteSpace(course.ResourceFile) && !StoredFileExists(course.ResourceFile, false)) issue("Error", "Kurs", "Ana eğitim dosyası bulunamadı.", contentEdit);

            var contents = db.CourseContents.AsNoTracking().Where(x => x.CourseId == courseId).ToList();
            model.ContentCount = contents.Count;
            if (!contents.Any()) issue("Error", "İçerik", "Kursa ait eğitim içeriği yok.", contentEdit);
            foreach (var content in contents)
            {
                if (string.IsNullOrWhiteSpace(content.ContentTitle)) issue("Error", "İçerik", "Başlığı boş içerik var.", contentEdit);
                if (string.IsNullOrWhiteSpace(content.FilePath) || !StoredFileExists(content.FilePath, false)) issue("Error", "İçerik", (content.ContentTitle ?? "İçerik") + " dosyası bulunamadı.", contentEdit);
            }

            var exams = db.Exam.AsNoTracking().Where(x => x.CourseId == courseId).ToList();
            if (!exams.Any()) issue("Error", "Sınav", "Kursa ait sınav yok.", Url.Action("Index", "Exam"));

            // Tüm soru, şık ve medyaları tek sorguda çek — N+1 önleme
            var allExamIds = exams.Select(x => x.ExamId).ToList();
            var allQuestions = allExamIds.Any()
                ? db.Question.AsNoTracking().Where(x => allExamIds.Contains(x.ExamId)).ToList()
                : new List<Question>();
            var allQuestionIds = allQuestions.Select(x => x.QuestionId).ToList();
            var allOptions = allQuestionIds.Any()
                ? db.QuestionOption.AsNoTracking().Where(x => allQuestionIds.Contains(x.QuestionId)).ToList()
                : new List<QuestionOption>();
            var allMedia = allQuestionIds.Any()
                ? db.QuestionMedia.AsNoTracking().Where(x => allQuestionIds.Contains(x.QuestionId)).ToList()
                : new List<QuestionMedia>();

            foreach (var exam in exams)
            {
                var questions = allQuestions.Where(x => x.ExamId == exam.ExamId).ToList();
                var questionIds = questions.Select(x => x.QuestionId).ToList();
                var mediaForExam = allMedia.Where(x => questionIds.Contains(x.QuestionId)).ToList();
                model.Exams.Add(new EducationReviewExamViewModel { ExamId = exam.ExamId, Title = exam.Title, Duration = exam.DurationMinutes ?? 0, PassingScore = exam.PassingScore ?? 0, QuestionCount = questions.Count, MediaCount = mediaForExam.Count });
                var examEdit = Url.Action("Index", "Exam", new { editExamId = exam.ExamId });
                var questionEdit = Url.Action("Index", "Question", new { examId = exam.ExamId });
                if (string.IsNullOrWhiteSpace(exam.Title)) issue("Error", "Sınav", "Sınav başlığı boş.", examEdit);
                if (!exam.DurationMinutes.HasValue || exam.DurationMinutes <= 0) issue("Error", "Sınav", (exam.Title ?? "Sınav") + " süresi geçersiz.", examEdit);
                if (!exam.PassingScore.HasValue || exam.PassingScore < 1 || exam.PassingScore > 100) issue("Error", "Sınav", (exam.Title ?? "Sınav") + " geçme puanı 1-100 arasında olmalı.", examEdit);
                if (!questions.Any()) issue("Error", "Sorular", (exam.Title ?? "Sınav") + " için soru yok.", questionEdit);
                else if (questions.Count < 5) issue("Warning", "Sorular", (exam.Title ?? "Sınav") + " yalnızca " + questions.Count + " soru içeriyor.", questionEdit);
                foreach (var question in questions)
                {
                    if (string.IsNullOrWhiteSpace(question.Text)) issue("Error", "Sorular", "Metni boş soru var.", questionEdit);
                    if (question.Points <= 0) issue("Error", "Sorular", "Puanı geçersiz soru var.", questionEdit);
                    if (question.QuestionType == 1)
                    {
                        var options = allOptions.Where(x => x.QuestionId == question.QuestionId).ToList();
                        if (options.Count < 2) issue("Error", "Şıklar", "En az iki şıkkı olmayan soru var.", questionEdit);
                        if (options.Count(x => x.IsCorrect) != 1) issue("Error", "Şıklar", "Tam olarak bir doğru cevabı olmayan soru var.", questionEdit);
                    }
                    foreach (var media in allMedia.Where(x => x.QuestionId == question.QuestionId))
                        if (!StoredFileExists(media.MediaPath, true)) issue("Error", "Medya", "Soru görseli veya medyası bulunamadı.", questionEdit);
                }
            }
            return model;
        }

        private bool StoredFileExists(string value, bool questionMedia)
        {
            if (string.IsNullOrWhiteSpace(value)) return false;
            if (value.StartsWith("http", StringComparison.OrdinalIgnoreCase)) return true;
            var clean = value.Trim().TrimStart('~', '/').Replace('/', Path.DirectorySeparatorChar);
            if (clean.StartsWith("files" + Path.DirectorySeparatorChar, StringComparison.OrdinalIgnoreCase)) clean = clean.Substring(6);
            var root = questionMedia ? "~/files/" : "~/files/Egitim/";
            return System.IO.File.Exists(FileStorageHelper.MapPath(Server, root + clean.Replace(Path.DirectorySeparatorChar, '/')));
        }

        private EducationPackageExportViewModel BuildExportModel(EducationPackageExportViewModel model)
        {
            var courses = db.Courses.AsNoTracking()
                .Where(x => x.IsDeleted != true)
                .OrderBy(x => x.CourseTitle)
                .ToList();

            var courseIds = courses.Select(x => x.CourseId).ToList();
            var examIds = db.Exam.AsNoTracking()
                .Where(x => courseIds.Contains(x.CourseId))
                .Select(x => new { x.ExamId, x.CourseId })
                .ToList();
            var examIdList = examIds.Select(x => x.ExamId).ToList();
            var contentCounts = db.CourseContents.AsNoTracking()
                .Where(x => courseIds.Contains(x.CourseId))
                .GroupBy(x => x.CourseId)
                .Select(x => new { CourseId = x.Key, Count = x.Count() })
                .ToDictionary(x => x.CourseId, x => x.Count);
            var questionCounts = db.Question.AsNoTracking()
                .Where(x => examIdList.Contains(x.ExamId))
                .GroupBy(x => x.ExamId)
                .Select(x => new { ExamId = x.Key, Count = x.Count() })
                .ToDictionary(x => x.ExamId, x => x.Count);

            model.CourseSummaries = courses.Select(course =>
            {
                var courseExamIds = examIds.Where(x => x.CourseId == course.CourseId).Select(x => x.ExamId).ToList();
                return new EducationPackageExportCourseSummary
                {
                    CourseId = course.CourseId,
                    CourseTitle = course.CourseTitle,
                    IsActive = course.IsActive,
                    ContentCount = contentCounts.ContainsKey(course.CourseId) ? contentCounts[course.CourseId] : 0,
                    ExamCount = courseExamIds.Count,
                    QuestionCount = courseExamIds.Sum(examId => questionCounts.ContainsKey(examId) ? questionCounts[examId] : 0)
                };
            }).ToList();

            model.Courses = new List<SelectListItem>(); // Dropdown kaldırıldı, tablo seçimi kullanılıyor
            return model;
        }

        private void ValidateExportReady(int courseId)
        {
            var course = db.Courses.AsNoTracking().FirstOrDefault(x => x.CourseId == courseId && x.IsDeleted != true);
            if (course == null) throw new InvalidOperationException("Paketlenecek kurs bulunamadı.");
            // İçerik, sınav veya soru eksikliği artık dışa aktarmayı engellemez.
            // Eksik olan alanlar paketle birlikte taşınmaz; içe aktarımda taslak olarak oluşturulur.
        }

        private int CurrentUserId()
        {
            var cookie = Request.Cookies["Token"];
            if (cookie == null) throw new HttpException(401, "Oturum bulunamadı.");
            var tokenData = new Token().GetToken(cookie.Value);
            int id;
            if (tokenData?.fldUserId == null || !int.TryParse(tokenData.fldUserId.ToString(), out id) || id <= 0)
                throw new HttpException(401, "Geçerli kullanıcı bulunamadı.");
            var user = new User().GetUserById(id);
            if (user == null || !string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase))
                throw new HttpException(403, "Bu işlem yalnızca admin içindir.");
            return id;
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing) db.Dispose();
            base.Dispose(disposing);
        }
    }
}
