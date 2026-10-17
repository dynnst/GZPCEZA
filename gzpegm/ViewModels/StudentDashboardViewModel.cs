using System;
using System.Collections.Generic;

namespace gzpegm.ViewModels
{
    public class StudentDashboardViewModel
    {
        public string CurrentUserName { get; set; }

        public int EnrolledCoursesCount { get; set; }
        public int CompletedExamsCount { get; set; }
        public int PassedExamsCount { get; set; }
        public int AverageScore { get; set; }

        // Yeni alanlar
        public int AverageExamDurationMinutes { get; set; }
        public int TotalExamTimeMinutes { get; set; }
        public DateTime? LastExamAt { get; set; }

        public List<RecentExamViewModel> RecentExams { get; set; }
    }

    public class RecentExamViewModel
    {
        public string ExamTitle { get; set; }
        public string CourseTitle { get; set; }

        public int Score { get; set; }
        public int MaxScore { get; set; }

        public decimal Percentage { get; set; }
        public bool IsPassed { get; set; }

        public DateTime FinishedAt { get; set; }
    }
}
