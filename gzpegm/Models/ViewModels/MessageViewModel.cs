using System;

namespace gzpegm.Models.ViewModels
{
    public class MessageViewModel
    {
        public int MessageId { get; set; }
        public int SenderId { get; set; }
        public string SenderName { get; set; }
        public string SenderRole { get; set; }
        public int RecipientId { get; set; }
        public string RecipientName { get; set; }
        public string RecipientRole { get; set; }
        public string Subject { get; set; }
        public string MessagePreview { get; set; }
        public DateTime SentDate { get; set; }
        public DateTime? ReadDate { get; set; }
        public bool IsRead { get; set; }
        public bool IsReply { get; set; }
        public int? ParentMessageId { get; set; }
        public int ReplyCount { get; set; }

        // UI helper properties
        public string SentDateFormatted => SentDate.ToString("dd.MM.yyyy HH:mm");
        public string ReadDateFormatted => ReadDate?.ToString("dd.MM.yyyy HH:mm") ?? "-";
        public string StatusBadge => IsRead ? "Okundu" : "Okunmadı";
        public string StatusClass => IsRead ? "badge-success" : "badge-warning";
    }
}
