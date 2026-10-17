using gzpegm.Models.ViewModels;
using System.Collections.Generic;

namespace gzpegm.Services
{
    public interface IMessageService
    {
        MessageResult SendMessage(int senderId, int recipientId, string subject, string content);
        MessageResult ReplyToMessage(int messageId, int senderId, string content);
        List<MessageViewModel> GetInbox(int userId, int pageNumber, int pageSize);
        List<MessageViewModel> GetSentMessages(int userId, int pageNumber, int pageSize);
        MessageDetailViewModel GetMessageById(int messageId, int userId);
        bool MarkAsRead(int messageId, int userId);
        bool DeleteMessage(int messageId, int userId);
        int GetUnreadCount(int userId);
        bool ValidateMessagingPermission(string senderRole, string recipientRole);
        List<RecipientViewModel> GetAvailableRecipients(int userId, string userRole);
    }

    public class RecipientViewModel
    {
        public int UserId { get; set; }
        public string Name { get; set; }
        public string Role { get; set; }
        public string Sicil { get; set; }
    }
}
