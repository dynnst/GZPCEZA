using System;

namespace gzpegm.ViewModels
{
    public class RecentActivityViewModel
    {
        public string UserName { get; set; }
        public string ExamTitle { get; set; }
        public int Score { get; set; }
        public int MaxScore { get; set; }
        public decimal Percentage { get; set; }
        public DateTime? FinishedAt { get; set; }
    }
}