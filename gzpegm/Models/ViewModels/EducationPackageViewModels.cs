using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace gzpegm.Models.ViewModels
{
    public class EducationPackageIndexViewModel
    {
        public int CourseCount { get; set; }
        public int DraftCount { get; set; }
        public int ImportCount { get; set; }
        public DateTime? LastImportDate { get; set; }
    }

    public class EducationPackageExportViewModel
    {
        [Required]
        [Display(Name = "Kurs")]
        public int CourseId { get; set; }
        [Required, StringLength(100)]
        public string PackageCode { get; set; }
        [Required, StringLength(30)]
        public string PackageVersion { get; set; } = "1.0.0";
        [StringLength(20)]
        public string Language { get; set; } = "tr-TR";
        [StringLength(100)]
        public string Source { get; set; }
        [StringLength(1000)]
        public string SourceUrl { get; set; }
        [StringLength(100)]
        public string DocumentCode { get; set; }
        [StringLength(100)]
        public string CountryName { get; set; }
        [StringLength(100)]
        public string DocumentType { get; set; }
        public IEnumerable<System.Web.Mvc.SelectListItem> Courses { get; set; }
        public List<EducationPackageExportCourseSummary> CourseSummaries { get; set; } = new List<EducationPackageExportCourseSummary>();
    }

    public class EducationPackageExportCourseSummary
    {
        public int CourseId { get; set; }
        public string CourseTitle { get; set; }
        public bool IsActive { get; set; }
        public int ContentCount { get; set; }
        public int ExamCount { get; set; }
        public int QuestionCount { get; set; }
    }

    public enum EducationPackageImportMode
    {
        NewCourse = 1,
        UpdateExisting = 2,
        SkipIfExists = 3
    }

    public class EducationPackageImportViewModel
    {
        [Required]
        public HttpPostedFileBase PackageFile { get; set; }
        public EducationPackageImportMode Mode { get; set; } = EducationPackageImportMode.NewCourse;
    }

    public class EducationPackageManifest
    {
        public string PackageCode { get; set; }
        public string PackageTitle { get; set; }
        public string PackageVersion { get; set; }
        public string Language { get; set; }
        public DateTime CreatedAt { get; set; }
        public string Source { get; set; }
        public string SourceUrl { get; set; }
        public string DocumentCode { get; set; }
        public string CountryName { get; set; }
        public string DocumentType { get; set; }
        public bool RequiresInternet { get; set; }
    }

    public class EducationPackageCourse
    {
        public int? SourceId { get; set; }
        public string CourseKey { get; set; }
        public string CourseTitle { get; set; }
        public string CourseDescription { get; set; }
        public string CategoryName { get; set; }
        public bool IsActive { get; set; }
        public string CoverFileName { get; set; }
        public string ResourceFileName { get; set; }
    }

    public class EducationPackageContent
    {
        public int? SourceId { get; set; }
        public string ContentKey { get; set; }
        public string CourseKey { get; set; }
        public string ContentType { get; set; }
        public string ContentTitle { get; set; }
        public string ContentDescription { get; set; }
        public string FileName { get; set; }
        public int SortOrder { get; set; }
    }

    public class EducationPackageExam
    {
        public int? SourceId { get; set; }
        public string ExamKey { get; set; }
        public string CourseKey { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public int? DurationMinutes { get; set; }
        public int? PassingScore { get; set; }
        public bool IsActive { get; set; }
    }

    public class EducationPackageQuestion
    {
        public int? SourceId { get; set; }
        public string QuestionKey { get; set; }
        public string ExamKey { get; set; }
        public string Text { get; set; }
        public byte QuestionType { get; set; }
        public int Points { get; set; }
        public int SortOrder { get; set; }
        public List<EducationPackageOption> Options { get; set; } = new List<EducationPackageOption>();
        public List<EducationPackageMedia> Media { get; set; } = new List<EducationPackageMedia>();
    }

    public class EducationPackageOption
    {
        public int? SourceId { get; set; }
        public string OptionKey { get; set; }
        public string Text { get; set; }
        public bool IsCorrect { get; set; }
        public int SortOrder { get; set; }
    }

    public class EducationPackageMedia
    {
        public int? SourceId { get; set; }
        public string MediaKey { get; set; }
        public string FileName { get; set; }
        public byte MediaType { get; set; }
        public int SortOrder { get; set; }
    }

    public class EducationPackageImportResult
    {
        public bool Success { get; set; }
        public bool Skipped { get; set; }
        public string Message { get; set; }
        public int? CourseId { get; set; }
        public int? ExamId { get; set; }
    }

    public enum CourseCoverMode
    {
        Automatic = 1,
        SourceImage = 2,
        CustomUpload = 3
    }

    public class PradoCourseImportViewModel
    {
        [Required]
        [Display(Name = "PRADO HTML ZIP dosyası")]
        public HttpPostedFileBase ZipFile { get; set; }

        [StringLength(300)]
        [Display(Name = "Kurs başlığı (boş bırakılırsa otomatik)")]
        public string CourseTitle { get; set; }

        [Range(5, 30)]
        [Display(Name = "Oluşturulacak soru sayısı")]
        public int QuestionCount { get; set; } = 30;

        [Display(Name = "Kapak yöntemi")]
        public CourseCoverMode CoverMode { get; set; } = CourseCoverMode.Automatic;

        [Display(Name = "Özel kapak görseli")]
        public HttpPostedFileBase CustomCoverFile { get; set; }

        [Display(Name = "Kursu hemen aktif et")]
        public bool IsActive { get; set; } = false;
    }

    public class PradoCourseImportResult
    {
        public int CourseId { get; set; }
        public int ExamId { get; set; }
        public int ContentCount { get; set; }
        public int QuestionCount { get; set; }
        public string DocumentCode { get; set; }
        public string Message { get; set; }
        // If true, parser could not find a title and the course was created with a placeholder title.
        // Controller will show a warning and allow the user to edit the title immediately.
        public bool TitleMissing { get; set; }
    }

    public class EducationReviewIssueViewModel
    {
        public string Severity { get; set; }
        public string Area { get; set; }
        public string Message { get; set; }
        public string EditUrl { get; set; }
    }

    public class EducationReviewExamViewModel
    {
        public int ExamId { get; set; }
        public string Title { get; set; }
        public int Duration { get; set; }
        public int PassingScore { get; set; }
        public int QuestionCount { get; set; }
        public int MediaCount { get; set; }
    }

    public class EducationReviewViewModel
    {
        public int CourseId { get; set; }
        public string CourseTitle { get; set; }
        public string CourseDescription { get; set; }
        public string CoverImageUrl { get; set; }
        public bool IsPublished { get; set; }
        public int ContentCount { get; set; }
        public List<EducationReviewExamViewModel> Exams { get; set; } = new List<EducationReviewExamViewModel>();
        public List<EducationReviewIssueViewModel> Issues { get; set; } = new List<EducationReviewIssueViewModel>();
        public bool CanPublish => !Issues.Any(x => x.Severity == "Error");
    }
}
