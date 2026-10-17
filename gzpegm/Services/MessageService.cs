using gzpegm.Models;
using gzpegm.Models.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;

namespace gzpegm.Services
{
    public class MessageService : IMessageService
    {
        private readonly GZPEGM1 _db;

        public MessageService()
        {
            _db = new GZPEGM1();
        }

        public MessageService(GZPEGM1 db)
        {
            _db = db;
        }

        public MessageResult SendMessage(int senderId, int recipientId, string subject, string content)
        {
            // Precondition checks
            if (senderId <= 0 || recipientId <= 0)
                return MessageResult.ErrorResult("Geçersiz kullanıcı ID");

            if (senderId == recipientId)
                return MessageResult.ErrorResult("Kendinize mesaj gönderemezsiniz");

            if (string.IsNullOrWhiteSpace(subject) || subject.Length > 200)
                return MessageResult.ErrorResult("Geçersiz konu");

            if (string.IsNullOrWhiteSpace(content) || content.Length > 4000)
                return MessageResult.ErrorResult("Geçersiz mesaj içeriği");

            using (var transaction = _db.Database.BeginTransaction())
            {
                try
                {
                    // Step 1: Fetch sender and recipient
                    var sender = _db.E_User.FirstOrDefault(u => u.fldId == senderId && (u.IsActive == true || u.fldActive == "1"));
                    var recipient = _db.E_User.FirstOrDefault(u => u.fldId == recipientId && (u.IsActive == true || u.fldActive == "1"));

                    if (sender == null)
                        return MessageResult.ErrorResult("Gönderen bulunamadı");

                    if (recipient == null)
                        return MessageResult.ErrorResult("Alıcı bulunamadı veya aktif değil");

                    // Step 2: Validate messaging permission
                    if (!ValidateMessagingPermission(sender.Role, recipient.Role))
                        return MessageResult.ErrorResult("Bu kullanıcıya mesaj gönderme yetkiniz yok");

                    // Step 3: Create message entity
                    var message = new E_Messages
                    {
                        fldSenderId = senderId,
                        fldSendByName = $"{sender.fldName} {sender.fldLastName}",
                        fldSendBySicil = sender.fldSicil,
                        fldSenderRole = sender.Role,
                        fldRecipientId = recipientId,
                        fldRecipientRole = recipient.Role,
                        fldSubject = subject.Trim(),
                        fldMessage = content.Trim(),
                        fldDateTime = DateTime.Now,
                        fldIsRead = false,
                        fldIsDeletedBySender = false,
                        fldIsDeletedByRecipient = false,
                        fldIsReply = false
                    };

                    // Step 4: Save to database
                    _db.E_Messages.Add(message);
                    _db.SaveChanges();

                    // Step 5: Commit transaction
                    transaction.Commit();

                    return MessageResult.SuccessResult(message.fldId, "Mesaj başarıyla gönderildi");
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    // Log exception here
                    return MessageResult.ErrorResult("Mesaj gönderilirken bir hata oluştu: " + ex.Message);
                }
            }
        }

        public bool ValidateMessagingPermission(string senderRole, string recipientRole)
        {
            if (string.IsNullOrWhiteSpace(senderRole) || string.IsNullOrWhiteSpace(recipientRole))
                return false;

            senderRole = senderRole.Trim();
            recipientRole = recipientRole.Trim();

            // Admin can send to everyone
            if (string.Equals(senderRole, "Admin", StringComparison.OrdinalIgnoreCase))
                return true;

            // Teacher can send to everyone
            if (string.Equals(senderRole, "Teacher", StringComparison.OrdinalIgnoreCase))
                return true;

            // Student can only send to Teacher or Admin (NOT to other Students)
            if (string.Equals(senderRole, "Student", StringComparison.OrdinalIgnoreCase))
            {
                return string.Equals(recipientRole, "Teacher", StringComparison.OrdinalIgnoreCase) ||
                       string.Equals(recipientRole, "Admin", StringComparison.OrdinalIgnoreCase);
            }

            return false;
        }

        public List<MessageViewModel> GetInbox(int userId, int pageNumber, int pageSize)
        {
            if (pageNumber < 1) pageNumber = 1;
            if (pageSize <= 0 || pageSize > 100) pageSize = 20;

            var messages = _db.E_Messages
                .Where(m => m.fldRecipientId == userId && m.fldIsDeletedByRecipient == false)
                .OrderByDescending(m => m.fldDateTime)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .Select(m => new MessageViewModel
                {
                    MessageId = m.fldId,
                    SenderId = m.fldSenderId ?? 0,
                    SenderName = m.fldSendByName,
                    SenderRole = m.fldSenderRole,
                    RecipientId = m.fldRecipientId ?? 0,
                    Subject = m.fldSubject,
                    MessagePreview = m.fldMessage == null ? "" : (m.fldMessage.Length > 100 ? m.fldMessage.Substring(0, 100) + "..." : m.fldMessage),
                    SentDate = m.fldDateTime ?? DateTime.Now,
                    ReadDate = m.fldReadDateTime,
                    IsRead = m.fldIsRead,
                    IsReply = m.fldIsReply,
                    ParentMessageId = m.fldParentMessageId,
                    ReplyCount = _db.E_Messages.Count(r => r.fldParentMessageId == m.fldId)
                })
                .ToList();

            return messages;
        }

        public List<MessageViewModel> GetSentMessages(int userId, int pageNumber, int pageSize)
        {
            if (pageNumber < 1) pageNumber = 1;
            if (pageSize <= 0 || pageSize > 100) pageSize = 20;

            var messages = _db.E_Messages
                .Where(m => m.fldSenderId == userId && m.fldIsDeletedBySender == false)
                .OrderByDescending(m => m.fldDateTime)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToList()
                .Select(m => new MessageViewModel
                {
                    MessageId = m.fldId,
                    SenderId = m.fldSenderId ?? 0,
                    SenderName = m.fldSendByName,
                    RecipientId = m.fldRecipientId ?? 0,
                    RecipientName = GetRecipientName(m.fldRecipientId ?? 0),
                    RecipientRole = m.fldRecipientRole,
                    Subject = m.fldSubject,
                    MessagePreview = m.fldMessage == null ? "" : (m.fldMessage.Length > 100 ? m.fldMessage.Substring(0, 100) + "..." : m.fldMessage),
                    SentDate = m.fldDateTime ?? DateTime.Now,
                    ReadDate = m.fldReadDateTime,
                    IsRead = m.fldIsRead,
                    IsReply = m.fldIsReply,
                    ParentMessageId = m.fldParentMessageId,
                    ReplyCount = _db.E_Messages.Count(r => r.fldParentMessageId == m.fldId)
                })
                .ToList();

            return messages;
        }

        private string GetRecipientName(int recipientId)
        {
            var recipient = _db.E_User.FirstOrDefault(u => u.fldId == recipientId);
            return recipient != null ? $"{recipient.fldName} {recipient.fldLastName}" : "Bilinmeyen";
        }

        public MessageDetailViewModel GetMessageById(int messageId, int userId)
        {
            var message = _db.E_Messages.FirstOrDefault(m => m.fldId == messageId);

            if (message == null)
                return null;

            // Authorization check
            if (message.fldSenderId != userId && message.fldRecipientId != userId)
                return null;

            if (message.fldSenderId == userId && message.fldIsDeletedBySender)
                return null;

            if (message.fldRecipientId == userId && message.fldIsDeletedByRecipient)
                return null;

            var sender = _db.E_User.FirstOrDefault(u => u.fldId == message.fldSenderId);
            var recipient = _db.E_User.FirstOrDefault(u => u.fldId == message.fldRecipientId);

            var replies = _db.E_Messages
                .Where(m => m.fldParentMessageId == messageId &&
                    !(
                        (m.fldSenderId == userId && m.fldIsDeletedBySender) ||
                        (m.fldRecipientId == userId && m.fldIsDeletedByRecipient)
                    ))
                .OrderBy(m => m.fldDateTime)
                .Select(m => new MessageViewModel
                {
                    MessageId = m.fldId,
                    SenderId = m.fldSenderId ?? 0,
                    SenderName = m.fldSendByName,
                    SenderRole = m.fldSenderRole,
                    Subject = m.fldSubject,
                    MessagePreview = m.fldMessage,
                    SentDate = m.fldDateTime ?? DateTime.Now,
                    IsRead = m.fldIsRead
                })
                .ToList();

            var detail = new MessageDetailViewModel
            {
                MessageId = message.fldId,
                SenderId = message.fldSenderId ?? 0,
                SenderName = message.fldSendByName,
                SenderRole = message.fldSenderRole,
                SenderEmail = !string.IsNullOrWhiteSpace(message.fldSendByMail)
    ? message.fldSendByMail
    : sender?.fldEmail,
                RecipientId = message.fldRecipientId ?? 0,
                RecipientName = recipient != null ? $"{recipient.fldName} {recipient.fldLastName}" : "",
                RecipientRole = message.fldRecipientRole,
                Subject = message.fldSubject,
                Message = message.fldMessage,
                SentDate = message.fldDateTime ?? DateTime.Now,
                ReadDate = message.fldReadDateTime,
                IsRead = message.fldIsRead,
                ParentMessageId = message.fldParentMessageId,
                Replies = replies,
                CanReply =
    message.fldRecipientId == userId &&
    message.fldSenderId.HasValue,
                CanDelete = message.fldSenderId == userId || message.fldRecipientId == userId
            };

            return detail;
        }

        public bool MarkAsRead(int messageId, int userId)
        {
            var message = _db.E_Messages.FirstOrDefault(m => m.fldId == messageId);

            if (message == null || message.fldRecipientId != userId)
                return false;

            if (message.fldIsRead)
                return true;

            message.fldIsRead = true;
            message.fldReadDateTime = DateTime.Now;
            _db.SaveChanges();

            return true;
        }

        public bool DeleteMessage(int messageId, int userId)
        {
            var message = _db.E_Messages.FirstOrDefault(m => m.fldId == messageId);

            if (message == null)
                return false;

            if (message.fldSenderId == userId)
            {
                message.fldIsDeletedBySender = true;
                _db.SaveChanges();
                return true;
            }

            if (message.fldRecipientId == userId)
            {
                message.fldIsDeletedByRecipient = true;
                _db.SaveChanges();
                return true;
            }

            return false;
        }

        public int GetUnreadCount(int userId)
        {
            return _db.E_Messages
                .Count(m => m.fldRecipientId == userId &&
                           m.fldIsRead == false &&
                           m.fldIsDeletedByRecipient == false);
        }

        public MessageResult ReplyToMessage(int messageId, int senderId, string content)
        {
            var parentMessage = _db.E_Messages.FirstOrDefault(m => m.fldId == messageId);

            if (parentMessage == null)
                return MessageResult.ErrorResult("Yanıtlanacak mesaj bulunamadı");

            if (parentMessage.fldRecipientId != senderId)
                return MessageResult.ErrorResult("Bu mesaja yanıt verme yetkiniz yok");

            int newRecipientId = parentMessage.fldSenderId ?? 0;
            string subject = "RE: " + (parentMessage.fldSubject ?? "");

            var result = SendMessage(senderId, newRecipientId, subject, content);

            if (result.Success)
            {
                var replyMessage = _db.E_Messages.FirstOrDefault(m => m.fldId == result.MessageId);
                if (replyMessage != null)
                {
                    replyMessage.fldIsReply = true;
                    replyMessage.fldParentMessageId = messageId;
                    _db.SaveChanges();
                }
            }

            return result;
        }

        public List<RecipientViewModel> GetAvailableRecipients(int userId, string userRole)
        {
            // Eski: var query = _db.E_User.Where(u => u.fldId != userId && u.IsActive == true);
            // Yeni: hem IsActive sütunu true olanları hem de fldActive == "1" olanları aktif kabul ediyoruz.
            var query = _db.E_User
                .Where(u => u.fldId != userId &&
                           (u.IsActive == true || u.fldActive == "1"));

            if (string.Equals(userRole, "Student", StringComparison.OrdinalIgnoreCase))
            {
                query = query.Where(u => u.Role == "Teacher" || u.Role == "Admin");
            }

            var recipients = query
                .OrderBy(u => u.Role)
                .ThenBy(u => u.fldName)
                .Select(u => new RecipientViewModel
                {
                    UserId = u.fldId,
                    Name = u.fldName + " " + u.fldLastName,
                    Role = u.Role,
                    Sicil = u.fldSicil
                })
                .ToList();

            return recipients;
        }

        public void Dispose()
        {
            _db?.Dispose();
        }
    }
}
