using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Web.Mvc;

namespace gzpegm.Models.ViewModels
{
    public class SendMessageViewModel
    {
        [Required(ErrorMessage = "Alıcı seçilmelidir")]
        [Display(Name = "Alıcı")]
        public int RecipientId { get; set; }

        [Required(ErrorMessage = "Konu girilmelidir")]
        [StringLength(200, ErrorMessage = "Konu maksimum 200 karakter olabilir")]
        [Display(Name = "Konu")]
        public string Subject { get; set; }

        [Required(ErrorMessage = "Mesaj içeriği girilmelidir")]
        [StringLength(4000, ErrorMessage = "Mesaj maksimum 4000 karakter olabilir")]
        [Display(Name = "Mesaj")]
        [DataType(DataType.MultilineText)]
        public string Message { get; set; }

        public int? ParentMessageId { get; set; }

        // UI için
        public string RecipientName { get; set; }
        public List<SelectListItem> AvailableRecipients { get; set; }

        public SendMessageViewModel()
        {
            AvailableRecipients = new List<SelectListItem>();
        }
    }
}
