using System;
namespace gzpegm.Models.ViewModel
{
    public class EnrollmentViewModel
    {
        public int EnrollmentId { get; set; }
        public int CourseId { get; set; }
        public string CourseTitle { get; set; }
        public int UserId { get; set; }
        public string UserFullName { get; set; }
        public string UserEmail { get; set; }
        public DateTime? EnrollmentDate { get; set; }
    }
}