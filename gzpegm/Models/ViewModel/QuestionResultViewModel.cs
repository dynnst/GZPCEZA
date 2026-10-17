using gzpegm.Models.ViewModels;
using System.Collections.Generic;

namespace gzpegm.Models.ViewModel
{
    public class QuestionResultViewModel
    {
        public int QuestionId { get; set; }
        public string QuestionText { get; set; }
        public int Points { get; set; }

        // Tüm seçenekler
        public List<QuestionOptionViewModel> Options { get; set; }

        // Öğrenci hangi seçeneği işaretledi?
        public int? SelectedOptionId { get; set; }

        // Doğru seçenek hangisi?
        public int CorrectOptionId { get; set; }

        // Soru doğru mu yanıtlanmış?
        public bool IsCorrect { get; set; }
    }

}