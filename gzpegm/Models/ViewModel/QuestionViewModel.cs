using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace gzpegm.Models.ViewModels
{
    public class QuestionViewModel : IValidatableObject
    {
        public int QuestionId { get; set; }

        [Required(ErrorMessage = "Sınav seçimi zorunludur")]
        public int ExamId { get; set; }

        [Required(ErrorMessage = "Soru metni zorunludur")]
        [StringLength(1000, ErrorMessage = "Soru metni en fazla 1000 karakter olabilir")]
        public string QuestionText { get; set; }

        [Required(ErrorMessage = "Soru tipi zorunludur")]
        public string QuestionType { get; set; } // MultipleChoice, TrueFalse, Text

        [Range(1, 100, ErrorMessage = "Puan 1-100 arasında olmalıdır")]
        public int Points { get; set; }

        public int SortOrder { get; set; }

        public bool IsActive { get; set; } // ✅ Soru aktif mi?

        // Çoktan seçmeli seçenekler
        public List<QuestionOptionViewModel> Options { get; set; }

        // Görüntüleme için
        public string ExamTitle { get; set; }

        public List<HttpPostedFileBase> ImageFiles { get; set; }
        public List<HttpPostedFileBase> VideoFiles { get; set; }
        public List<QuestionMediaViewModel> MediaFiles { get; set; }

        // Server-side validation: MultipleChoice için kurallar
        public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
        {
            if (QuestionType == "MultipleChoice" || QuestionType == "TrueFalse")
            {
                if (Options == null || !Options.Any(o => !string.IsNullOrWhiteSpace(o.OptionText)))
                {
                    yield return new ValidationResult("En az bir seçenek girilmelidir.", new[] { nameof(Options) });
                }

                if (Options == null || !Options.Any(o => o.IsCorrect))
                {
                    yield return new ValidationResult("En az bir doğru seçenek işaretlenmelidir.", new[] { nameof(Options) });
                }
            }

            yield break;
        }
    }

    public class QuestionOptionViewModel
    {
        public int OptionId { get; set; }
        public int QuestionId { get; set; }

        [Required(ErrorMessage = "Seçenek metni zorunludur")]
        [StringLength(500, ErrorMessage = "Seçenek metni en fazla 500 karakter olabilir")]
        public string OptionText { get; set; }

        public bool IsCorrect { get; set; }
        public int SortOrder { get; set; }
    }

    // ✅ QuestionMediaViewModel artık QuestionMediaViewModel.cs'de tanımlandığı için buradan kaldırıldı
}
