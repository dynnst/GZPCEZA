using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq; // 🔥 ZORUNLU – TÜM HATALARI ÇÖZER

namespace gzpegm.Models.ViewModels
{
    public class ExamResultViewModel
    {
        public int ExamResultId { get; set; }
        public int ExamId { get; set; }
        public string ExamTitle { get; set; }
        public string ExamDescription { get; set; }
        public string CourseTitle { get; set; }
        public int TotalScore { get; set; }
        public int MaxScore { get; set; }
        public double Percentage { get; set; }
        public bool IsPassed { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public TimeSpan Duration { get; set; }

        // Listeyi varsayılan başlatma ile güvenli hale getirdim
        public List<AnswerResultViewModel> Answers { get; set; }
            = new List<AnswerResultViewModel>();

        // 🔹 LINQ KULLANIYOR → System.Linq şart
        public int CorrectCount =>
            Answers != null ? Answers.Count(a => a != null && a.IsCorrect) : 0;

        public int WrongCount =>
            Answers != null ? Answers.Count(a => a != null && !a.IsCorrect) : 0;

        public string DisplayPercentage =>
            Percentage.ToString("F1", CultureInfo.InvariantCulture) + " %";

        public string SortDateIso =>
            (EndTime ?? StartTime).ToString("o");

        public double DurationSeconds =>
            Duration.TotalSeconds;
    }

    public class AnswerResultViewModel
    {
        public int QuestionId { get; set; }
        public string QuestionText { get; set; }

        public int? SelectedOptionId { get; set; }

        public string UserAnswer { get; set; }
        public string CorrectAnswer { get; set; }

        public bool IsCorrect { get; set; }
        public int PointsEarned { get; set; }
        public int MaxPoints { get; set; }

        public List<QuestionMediaViewModel> MediaFiles { get; set; }
            = new List<QuestionMediaViewModel>();

        public List<QuestionOptionResultViewModel> Options { get; set; }
            = new List<QuestionOptionResultViewModel>();
    }

    public class QuestionOptionResultViewModel
    {
        public int OptionId { get; set; }
        public string OptionText { get; set; }
        public bool IsCorrect { get; set; }
        public int SortOrder { get; set; }
    }
}
