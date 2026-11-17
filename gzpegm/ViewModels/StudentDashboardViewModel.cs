using System;
using System.Collections.Generic;

namespace gzpegm.ViewModels
{
    public class StudentDashboardViewModel
    {
        public string CurrentUserName { get; set; }
        public string CurrentUserFullName { get; set; }
        public string Sicil { get; set; }
        public string UserTitle { get; set; }
        public string BorderUnit { get; set; }
        public string Email { get; set; }
        public int XP { get; set; }
        public int Level { get; set; }

        public int EnrolledCoursesCount { get; set; }
        public int CompletedExamsCount { get; set; }
        public int PassedExamsCount { get; set; }
        public int AverageScore { get; set; }

        public int AverageExamDurationMinutes { get; set; }
        public int TotalExamTimeMinutes { get; set; }
        public DateTime? LastExamAt { get; set; }

        public int EarnedCertificatesCount { get; set; }
        public int PendingCertificatesCount { get; set; }
        public int AvailableExamsCount { get; set; }

        public List<RecentExamViewModel> RecentExams { get; set; }
        public List<StudentEnrolledCourseItemViewModel> EnrolledCourses { get; set; }
        public List<StudentCertificateSummaryViewModel> RecentCertificates { get; set; }
        public List<StudentAvailableExamSummaryViewModel> AvailableExams { get; set; }
    }

    public class RecentExamViewModel
    {
        public int ExamResultId { get; set; }
        public int ExamId { get; set; }
        public string ExamTitle { get; set; }
        public string CourseTitle { get; set; }

        public int Score { get; set; }
        public int MaxScore { get; set; }

        public decimal Percentage { get; set; }
        public bool IsPassed { get; set; }

        public DateTime FinishedAt { get; set; }
    }

    public class StudentEnrolledCourseItemViewModel
    {
        public int CourseId { get; set; }
        public string CourseTitle { get; set; }
        public string CategoryName { get; set; }
        public string CoverImage { get; set; }
        public DateTime? EnrolledDate { get; set; }
        public int ContentCount { get; set; }
        public bool HasExam { get; set; }
        public bool HasCertificate { get; set; }
    }

    public class StudentCertificateSummaryViewModel
    {
        public int CertificateId { get; set; }
        public string CertificateNumber { get; set; }
        public string CourseTitle { get; set; }
        public DateTime IssuedDate { get; set; }
        public int Score { get; set; }
    }

    public class StudentAvailableExamSummaryViewModel
    {
        public int ExamId { get; set; }
        public int CourseId { get; set; }
        public string Title { get; set; }
        public string CourseTitle { get; set; }
        public int DurationMinutes { get; set; }
        public int PassingScore { get; set; }
        public int QuestionCount { get; set; }
    }
}
