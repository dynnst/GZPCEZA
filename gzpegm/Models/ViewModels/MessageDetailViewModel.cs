using System;
using System.Collections.Generic;

namespace gzpegm.Models.ViewModels
{
    public class MessageDetailViewModel
    {
        public int MessageId { get; set; }
        public int SenderId { get; set; }
        public string SenderName { get; set; }
        public string SenderRole { get; set; }
        public string SenderEmail { get; set; }
        public int RecipientId { get; set; }
        public string RecipientName { get; set; }
        public string RecipientRole { get; set; }
        public string Subject { get; set; }
        public string Message { get; set; }
        public DateTime SentDate { get; set; }
        public DateTime? ReadDate { get; set; }
        public bool IsRead { get; set; }
        public int? ParentMessageId { get; set; }
        public List<MessageViewModel> Replies { get; set; }
        public bool CanReply { get; set; }
        public bool CanDelete { get; set; }

        // UI helper properties
        public string SentDateFormatted => SentDate.ToString("dd.MM.yyyy HH:mm");
        public string ReadDateFormatted => ReadDate?.ToString("dd.MM.yyyy HH:mm") ?? "Henüz okunmadı";

        public MessageDetailViewModel()
        {
            Replies = new List<MessageViewModel>();
        }
    }
}
