using System;

namespace gzpegm.Models.ViewModels
{
    public class ExamResultListItemViewModel
    {
        public int ExamResultId { get; set; }
        public int? UserId { get; set; }
        public string UserFullName { get; set; }
        public int TotalScore { get; set; }
        public int MaxScore { get; set; }
        public double Percentage { get; set; }
        public bool IsPassed { get; set; }
        public DateTime? StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public TimeSpan Duration { get; set; }
    }
}