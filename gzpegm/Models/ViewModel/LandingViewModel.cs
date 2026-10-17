using System;
using System.Collections.Generic;

namespace gzpegm.Models.ViewModels
{
    public class LandingViewModel
    {
        public List<CourseViewModel> SliderCourses { get; set; }
        public List<CourseViewModel> LatestCourses { get; set; }
        public List<CourseViewModel> AllCourses { get; set; }

        public List<E_User> Teachers { get; set; }

        public bool IsAuthenticated { get; set; }
        public E_User CurrentUser { get; set; }

        public List<LandingComment> Comments { get; set; }

        // SINAV TANITIM
        public List<LandingExamViewModel> RecentExams { get; set; }
        public LandingExamViewModel MostPopularExam { get; set; }
        public string MostPopularCourse { get; set; }
        public int MostPopularCourseCount { get; set; }
        public List<LandingExamViewModel> WeeklyExams { get; set; }

        public int TotalExamCount { get; set; }
        public int TotalParticipantCount { get; set; }
        public decimal GlobalAverageScore { get; set; }

        // 🔒 Constructor (ÇOK ÖNEMLİ)
        public LandingViewModel()
        {
            SliderCourses = new List<CourseViewModel>();
            LatestCourses = new List<CourseViewModel>();
            AllCourses = new List<CourseViewModel>();
            Teachers = new List<E_User>();
            Comments = new List<LandingComment>();
            RecentExams = new List<LandingExamViewModel>();
            WeeklyExams = new List<LandingExamViewModel>();
        }
    }

    public class CourseViewModel
    {
        public int CourseId { get; set; }
        public string CourseTitle { get; set; }
        public string CourseDescription { get; set; }
        public string CoverImage { get; set; }

        public int CreatedBy { get; set; }
        public DateTime? CreatedDate { get; set; }

        public int CategoryId { get; set; }
        public string CategoryName { get; set; }

        public bool IsActive { get; set; }
        public string ResourceFile { get; set; }

        public string InstructorName { get; set; }

        public string CoverImagePath { get; set; }
        public string ResourceFilePath { get; set; }

        public List<CourseContents> Contents { get; set; }

        // Kurs yorumları (sadece admin onaylı olanlar)
        public List<CourseReviewItemViewModel> ApprovedReviews { get; set; }

        public CourseViewModel()
        {
            Contents = new List<CourseContents>();
            ApprovedReviews = new List<CourseReviewItemViewModel>();
        }
    }

    public class CourseReviewItemViewModel
    {
        public int ReviewId { get; set; }
        public int CourseId { get; set; }
        public int UserId { get; set; }
        public string UserFullName { get; set; }
        public byte Rating { get; set; }
        public string Comment { get; set; }
        public DateTime CreatedDate { get; set; }
    }

    public class PendingCourseReviewItemViewModel : CourseReviewItemViewModel
    {
        public string CourseTitle { get; set; }
    }

    public class LandingComment
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Message { get; set; }
        public DateTime? Date { get; set; }
        public string Picture { get; set; }
        public E_User User { get; set; }
    }

    public class LandingExamViewModel
    {
        public int ExamId { get; set; }
        public string ExamTitle { get; set; }
        public string CourseTitle { get; set; }

        public int ParticipantCount { get; set; }
        public decimal AverageScore { get; set; }

        public DateTime? CreatedDate { get; set; }
        public DateTime? LastTakenDate { get; set; }
    }
}
