using System;
using System.Collections.Generic;

namespace gzpegm.Models.ViewModels
{
    public class StudentExamViewModel
    {
        public int ExamId { get; set; }
        public string ExamTitle { get; set; }
        public string ExamDescription { get; set; }
        public int CourseId { get; set; }
        public string CourseTitle { get; set; }
        public int Duration { get; set; }
        public int PassingScore { get; set; }
        public int TotalQuestions { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }

        public List<ExamQuestionViewModel> Questions { get; set; }

        // 🔒 Güvenlik için
        public StudentExamViewModel()
        {
            Questions = new List<ExamQuestionViewModel>();
        }
    }

    public class ExamQuestionViewModel
    {
        public int QuestionId { get; set; }
        public string QuestionText { get; set; }
        public string QuestionType { get; set; }
        public int Points { get; set; }
        public int SortOrder { get; set; }

        // Çoktan seçmeli için seçenekler
        public List<QuestionOptionViewModel> Options { get; set; }

        // ✅ SORUYA AİT MEDYALAR (RESİM / VİDEO)
        public List<QuestionMediaViewModel> MediaFiles { get; set; }

        // Kullanıcı cevabı
        public int? SelectedOptionId { get; set; }
        public string TextAnswer { get; set; }

        // 🔒 Güvenlik için
        public ExamQuestionViewModel()
        {
            Options = new List<QuestionOptionViewModel>();
            MediaFiles = new List<QuestionMediaViewModel>();
        }
    }
}
