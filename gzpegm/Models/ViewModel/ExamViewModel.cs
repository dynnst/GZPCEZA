using System;
using System.ComponentModel.DataAnnotations;

namespace gzpegm.Models.ViewModels
{
    public class ExamViewModel
    {
        public int ExamId { get; set; }

        [Required(ErrorMessage = "Sınav başlığı zorunludur")]
        [StringLength(200, ErrorMessage = "Sınav başlığı en fazla 200 karakter olabilir")]
        public string ExamTitle { get; set; }

        [StringLength(500, ErrorMessage = "Açıklama en fazla 500 karakter olabilir")]
        public string ExamDescription { get; set; }

        [Required(ErrorMessage = "Kurs seçimi zorunludur")]
        public int CourseId { get; set; }

        [Range(1, 300, ErrorMessage = "Süre 1-300 dakika arasında olmalıdır")]
        public int Duration { get; set; }

        [Range(0, 100, ErrorMessage = "Geçme notu 0-100 arasında olmalıdır")]
        public int PassingScore { get; set; }

        public bool IsActive { get; set; }
        public DateTime? CreatedDate { get; set; }

        // Görüntü için
        public string CourseTitle { get; set; }
        public string CourseCoverImage { get; set; }
        public string CourseCreatorFullName { get; set; } // <-- Yeni alan eklendi
        public int QuestionCount { get; set; }
        public bool CanTakeExam { get; set; }
        public int? ExamResultId { get; set; }

        // Öğrenci kursa kayıtlı mı?
        public bool IsStudentEnrolled { get; set; }
    }
}
