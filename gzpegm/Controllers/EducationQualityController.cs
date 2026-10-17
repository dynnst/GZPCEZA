using gzpegm.Cont;
using gzpegm.Helpers;
using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize(Users = "2,6")]
    public class EducationQualityController : Controller
    {
        private readonly GZPEGM1 db = new GZPEGM1();

        [HttpGet]
        [Route("EgitimKaliteRaporu")]
        public ActionResult Index()
        {
            var model = BuildReport();
            return View(model);
        }

        private EducationQualityReportViewModel BuildReport()
        {
            var model = new EducationQualityReportViewModel { GeneratedAt = DateTime.Now };

            var courses = db.Courses.AsNoTracking()
                .Where(x => x.IsDeleted != true)
                .OrderByDescending(x => x.CreatedDate)
                .ThenByDescending(x => x.CourseId)
                .ToList();

            var courseIds = courses.Select(x => x.CourseId).ToList();
            var contents = db.CourseContents.AsNoTracking().Where(x => courseIds.Contains(x.CourseId)).ToList();
            var exams = db.Exam.AsNoTracking().Where(x => courseIds.Contains(x.CourseId)).ToList();
            var examIds = exams.Select(x => x.ExamId).ToList();
            var questions = db.Question.AsNoTracking().Where(x => examIds.Contains(x.ExamId)).ToList();
            var questionIds = questions.Select(x => x.QuestionId).ToList();
            var options = db.QuestionOption.AsNoTracking().Where(x => questionIds.Contains(x.QuestionId)).ToList();
            var media = db.QuestionMedia.AsNoTracking().Where(x => questionIds.Contains(x.QuestionId)).ToList();

            foreach (var course in courses)
            {
                var item = new EducationQualityCourseItem
                {
                    CourseId = course.CourseId,
                    CourseTitle = course.CourseTitle,
                    IsActive = course.IsActive,
                    CreatedDate = course.CreatedDate,
                    ContentCount = contents.Count(x => x.CourseId == course.CourseId),
                    ExamCount = exams.Count(x => x.CourseId == course.CourseId)
                };

                CheckCourse(course, item);

                var courseContents = contents.Where(x => x.CourseId == course.CourseId).ToList();
                foreach (var content in courseContents) CheckContent(content, item);

                var courseExams = exams.Where(x => x.CourseId == course.CourseId).ToList();
                foreach (var exam in courseExams)
                {
                    var examQuestions = questions.Where(x => x.ExamId == exam.ExamId).ToList();
                    var examQuestionIds = examQuestions.Select(x => x.QuestionId).ToList();
                    item.QuestionCount += examQuestions.Count;
                    item.MediaCount += media.Count(x => examQuestionIds.Contains(x.QuestionId));

                    CheckExam(exam, examQuestions, item);

                    foreach (var question in examQuestions)
                    {
                        var questionOptions = options.Where(x => x.QuestionId == question.QuestionId).ToList();
                        var questionMedia = media.Where(x => x.QuestionId == question.QuestionId).ToList();
                        CheckQuestion(question, questionOptions, questionMedia, item);
                    }
                }

                item.ErrorCount = item.Issues.Count(x => x.Severity == "Error");
                item.WarningCount = item.Issues.Count(x => x.Severity == "Warning");
                model.Courses.Add(item);
            }

            model.TotalCourses = model.Courses.Count;
            model.PublishedCourses = model.Courses.Count(x => x.IsActive);
            model.TotalErrors = model.Courses.Sum(x => x.ErrorCount);
            model.TotalWarnings = model.Courses.Sum(x => x.WarningCount);
            model.TotalContents = model.Courses.Sum(x => x.ContentCount);
            model.TotalExams = model.Courses.Sum(x => x.ExamCount);
            model.TotalQuestions = model.Courses.Sum(x => x.QuestionCount);
            return model;
        }

        private void CheckCourse(Courses course, EducationQualityCourseItem item)
        {
            var editUrl = Url.Action("Index", "Course", new { editCourseId = course.CourseId });
            IssueIf(item, string.IsNullOrWhiteSpace(course.CourseTitle), "Error", "Kurs", "Kurs başlığı boş.", editUrl);
            IssueIf(item, string.IsNullOrWhiteSpace(course.CourseDescription), "Warning", "Kurs", "Kurs açıklaması boş.", editUrl);
            IssueIf(item, HasMojibake(course.CourseTitle) || HasMojibake(course.CourseDescription), "Warning", "Karakter", "Kurs başlığı/açıklamasında karakter bozukluğu olabilir.", editUrl);
            IssueIf(item, string.IsNullOrWhiteSpace(course.CoverImage), "Warning", "Görsel", "Kapak görseli seçilmemiş.", editUrl);

            if (!string.IsNullOrWhiteSpace(course.CoverImage) && !StoredFileExists(course.CoverImage, false))
                AddIssue(item, "Error", "Görsel", "Kapak görseli dosyası bulunamadı.", editUrl);

            if (!string.IsNullOrWhiteSpace(course.ResourceFile) && !StoredFileExists(course.ResourceFile, false))
                AddIssue(item, "Error", "Dosya", "Ana eğitim dosyası bulunamadı.", Url.Action("ManageContents", "Course", new { courseId = course.CourseId }));
        }

        private void CheckContent(CourseContents content, EducationQualityCourseItem item)
        {
            var editUrl = Url.Action("ManageContents", "Course", new { courseId = content.CourseId });
            IssueIf(item, string.IsNullOrWhiteSpace(content.ContentTitle), "Error", "İçerik", "Başlığı boş içerik var.", editUrl);
            IssueIf(item, string.IsNullOrWhiteSpace(content.FilePath), "Error", "İçerik", (content.ContentTitle ?? "İçerik") + " için dosya yolu boş.", editUrl);
            IssueIf(item, HasMojibake(content.ContentTitle) || HasMojibake(content.ContentDescription), "Warning", "Karakter", (content.ContentTitle ?? "İçerik") + " alanında karakter bozukluğu olabilir.", editUrl);

            if (!string.IsNullOrWhiteSpace(content.FilePath) && !StoredFileExists(content.FilePath, false))
                AddIssue(item, "Error", "İçerik", (content.ContentTitle ?? "İçerik") + " dosyası bulunamadı.", editUrl);
        }

        private void CheckExam(Exam exam, List<Question> questions, EducationQualityCourseItem item)
        {
            var examEdit = Url.Action("Index", "Exam", new { editExamId = exam.ExamId });
            var questionEdit = Url.Action("Index", "Question", new { examId = exam.ExamId });
            IssueIf(item, string.IsNullOrWhiteSpace(exam.Title), "Error", "Sınav", "Sınav başlığı boş.", examEdit);
            IssueIf(item, !exam.DurationMinutes.HasValue || exam.DurationMinutes <= 0, "Error", "Sınav", (exam.Title ?? "Sınav") + " süresi geçersiz.", examEdit);
            IssueIf(item, !exam.PassingScore.HasValue || exam.PassingScore < 1 || exam.PassingScore > 100, "Error", "Sınav", (exam.Title ?? "Sınav") + " geçme puanı 1-100 arasında olmalı.", examEdit);
            IssueIf(item, HasMojibake(exam.Title) || HasMojibake(exam.Description), "Warning", "Karakter", (exam.Title ?? "Sınav") + " metninde karakter bozukluğu olabilir.", examEdit);
            IssueIf(item, !questions.Any(), "Error", "Sorular", (exam.Title ?? "Sınav") + " için soru yok.", questionEdit);
            IssueIf(item, questions.Any() && questions.Count < 5, "Warning", "Sorular", (exam.Title ?? "Sınav") + " yalnızca " + questions.Count + " soru içeriyor.", questionEdit);
        }

        private void CheckQuestion(Question question, List<QuestionOption> options, List<QuestionMedia> media, EducationQualityCourseItem item)
        {
            var questionEdit = Url.Action("Index", "Question", new { examId = question.ExamId });
            IssueIf(item, string.IsNullOrWhiteSpace(question.Text), "Error", "Sorular", "Metni boş soru var. Soru ID: " + question.QuestionId, questionEdit);
            IssueIf(item, question.Points <= 0, "Error", "Sorular", "Puanı geçersiz soru var. Soru ID: " + question.QuestionId, questionEdit);
            IssueIf(item, HasMojibake(question.Text), "Warning", "Karakter", "Soru metninde karakter bozukluğu olabilir. Soru ID: " + question.QuestionId, questionEdit);

            if (question.QuestionType == 1)
            {
                IssueIf(item, options.Count < 2, "Error", "Şıklar", "En az iki şıkkı olmayan soru var. Soru ID: " + question.QuestionId, questionEdit);
                IssueIf(item, options.Count(x => x.IsCorrect) != 1, "Error", "Şıklar", "Tam olarak bir doğru cevabı olmayan soru var. Soru ID: " + question.QuestionId, questionEdit);
                IssueIf(item, options.Any(x => string.IsNullOrWhiteSpace(x.Text)), "Error", "Şıklar", "Metni boş şık var. Soru ID: " + question.QuestionId, questionEdit);
                IssueIf(item, options.Any(x => HasMojibake(x.Text)), "Warning", "Karakter", "Şık metninde karakter bozukluğu olabilir. Soru ID: " + question.QuestionId, questionEdit);
            }

            foreach (var mediaItem in media)
            {
                if (!StoredFileExists(mediaItem.MediaPath, true))
                    AddIssue(item, "Error", "Medya", "Soru medya dosyası bulunamadı. Soru ID: " + question.QuestionId, questionEdit);
            }
        }

        private void IssueIf(EducationQualityCourseItem item, bool condition, string severity, string area, string message, string editUrl)
        {
            if (condition) AddIssue(item, severity, area, message, editUrl);
        }

        private void AddIssue(EducationQualityCourseItem item, string severity, string area, string message, string editUrl)
        {
            item.Issues.Add(new EducationQualityIssue { Severity = severity, Area = area, Message = message, EditUrl = editUrl });
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

        private static bool HasMojibake(string value)
        {
            if (string.IsNullOrWhiteSpace(value)) return false;
            return Regex.IsMatch(value, "[ÃÄÅ�]{1,}") || value.Contains("Â") || value.Contains("�");
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing) db.Dispose();
            base.Dispose(disposing);
        }
    }

    public class EducationQualityReportViewModel
    {
        public DateTime GeneratedAt { get; set; }
        public int TotalCourses { get; set; }
        public int PublishedCourses { get; set; }
        public int TotalContents { get; set; }
        public int TotalExams { get; set; }
        public int TotalQuestions { get; set; }
        public int TotalErrors { get; set; }
        public int TotalWarnings { get; set; }
        public List<EducationQualityCourseItem> Courses { get; set; } = new List<EducationQualityCourseItem>();
    }

    public class EducationQualityCourseItem
    {
        public int CourseId { get; set; }
        public string CourseTitle { get; set; }
        public bool IsActive { get; set; }
        public DateTime? CreatedDate { get; set; }
        public int ContentCount { get; set; }
        public int ExamCount { get; set; }
        public int QuestionCount { get; set; }
        public int MediaCount { get; set; }
        public int ErrorCount { get; set; }
        public int WarningCount { get; set; }
        public List<EducationQualityIssue> Issues { get; set; } = new List<EducationQualityIssue>();
    }

    public class EducationQualityIssue
    {
        public string Severity { get; set; }
        public string Area { get; set; }
        public string Message { get; set; }
        public string EditUrl { get; set; }
    }
}
