using System.Collections.Generic;

namespace gzpegm.ViewModels
{
    public class DashboardViewModel
    {
        public int TotalCourses { get; set; }
        public int TotalExams { get; set; }
        public int TotalStudents { get; set; }
        public int TotalEnrollments { get; set; }

        // Yeni eklenen istatistikler
        public int ActiveStudentsLast7Days { get; set; }
        public int AverageExamDurationMinutes { get; set; }

        // JSON serileþtirilmiþ chart verileri (view'da Chart.js için ham JSON kullanýlýyor)
        public string EnrollmentDatesJson { get; set; }
        public string EnrollmentCountsJson { get; set; }
        public string PopularCourseTitlesJson { get; set; }
        public string PopularCourseCountsJson { get; set; }
        public string ExamTitlesJson { get; set; }
        public string ExamPassedCountsJson { get; set; }
        public string ExamFailedCountsJson { get; set; }

        public List<RecentActivityViewModel> RecentActivities { get; set; }
        public List<TopStudentViewModel> TopStudents { get; set; }

        // Eðer view kullanýcý objesine ihtiyaç duyuyorsa:
        public Models.E_User CurrentUser { get; set; }

        // Yeni: Bekleyen onay bekleyen öðe sayýlarý (admin bildirimleri için)
        public int PendingCourseReviewsCount { get; set; }
        public int PendingLandingCommentsCount { get; set; }
        public int PendingCertificateRequestsCount { get; set; }
    }
}