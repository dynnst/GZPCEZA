using gzpegm.Cont;
using gzpegm.Models;
using gzpegm.Models.ViewModels;
using gzpegm.Services;
using System;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize(Users = "2,3,6")]
    public class MesajController : Controller
    {
        private readonly IMessageService _messageService;
        private readonly GZPEGM1 _db;

        public MesajController()
        {
            _db = new GZPEGM1();
            _messageService = new MessageService(_db);
        }

        private E_User GetCurrentUser()
        {
            try
            {
                HttpCookie cookie = Request.Cookies["Token"];
                if (cookie == null) return null;

                Token token = new Token();
                var data = token.GetToken(cookie.Value);
                if (data == null) return null;

                if (!int.TryParse(data.fldUserId?.ToString(), out int userId))
                    return null;

                User user = new User();
                return user.GetUserById(userId);
            }
            catch
            {
                return null;
            }
        }

        // GET: /Mesaj/Index
        [HttpGet]
        [Route("Mesaj/Index")]
        public ActionResult Index()
        {
            return RedirectToAction("Inbox");
        }

        // GET: /Mesaj/Inbox
        [HttpGet]
        [Route("Mesaj/Inbox")]
        public ActionResult Inbox(int page = 1)
        {
            var user = GetCurrentUser();
            if (user == null)
            {
                TempData["msgError"] = "Lütfen sisteme giriş yapın.";
                return RedirectToAction("Index", "Giris");
            }

            int pageSize = 20;
            var messages = _messageService.GetInbox(user.fldId, page, pageSize);

            // Pagination info
            int totalMessages = _db.E_Messages
                .Count(m => m.fldRecipientId == user.fldId && m.fldIsDeletedByRecipient == false);
            int totalPages = (int)Math.Ceiling(totalMessages / (double)pageSize);

            ViewBag.CurrentPage = page;
            ViewBag.TotalPages = totalPages;
            ViewBag.TotalMessages = totalMessages;
            ViewBag.UnreadCount = _messageService.GetUnreadCount(user.fldId);

            return View(messages);
        }

        // GET: /Mesaj/Sent
        [HttpGet]
        [Route("Mesaj/Sent")]
        public ActionResult Sent(int page = 1)
        {
            var user = GetCurrentUser();
            if (user == null)
            {
                TempData["msgError"] = "Lütfen sisteme giriş yapın.";
                return RedirectToAction("Index", "Giris");
            }

            int pageSize = 20;
            var messages = _messageService.GetSentMessages(user.fldId, page, pageSize);

            // Pagination info
            int totalMessages = _db.E_Messages
                .Count(m => m.fldSenderId == user.fldId && m.fldIsDeletedBySender == false);
            int totalPages = (int)Math.Ceiling(totalMessages / (double)pageSize);

            ViewBag.CurrentPage = page;
            ViewBag.TotalPages = totalPages;
            ViewBag.TotalMessages = totalMessages;

            return View(messages);
        }

        // GET: /Mesaj/BulkCompose (Admin only)
        [HttpGet]
        [Route("Mesaj/BulkCompose")]
        public ActionResult BulkCompose()
        {
            var user = GetCurrentUser();
            if (user == null)
            {
                TempData["msgError"] = "Lütfen sisteme giriş yapın.";
                return RedirectToAction("Index", "Giris");
            }

            // Check if user is Admin
            if (!string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase))
            {
                TempData["msgError"] = "Bu özelliğe sadece Admin kullanıcıları erişebilir.";
                return RedirectToAction("Inbox");
            }

            var model = new SendMessageViewModel();
            return View(model);
        }

        // POST: /Mesaj/SendBulk (Admin only)
        [HttpPost]
        [Route("Mesaj/SendBulk")]
        [ValidateAntiForgeryToken]
        public ActionResult SendBulk(SendMessageViewModel model)
        {
            var user = GetCurrentUser();
            if (user == null)
            {
                TempData["msgError"] = "Lütfen sisteme giriş yapın.";
                return RedirectToAction("Index", "Giris");
            }

            // Check if user is Admin
            if (!string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase))
            {
                TempData["msgError"] = "Bu özelliğe sadece Admin kullanıcıları erişebilir.";
                return RedirectToAction("Inbox");
            }

            ModelState.Remove("RecipientId");
            if (!ModelState.IsValid)
            {
                return View("BulkCompose", model);
            }

            // Validation
            if (string.IsNullOrWhiteSpace(model.Subject) || model.Subject.Length > 200)
            {
                TempData["msgError"] = "Geçersiz konu";
                return View("BulkCompose", model);
            }

            if (string.IsNullOrWhiteSpace(model.Message) || model.Message.Length > 4000)
            {
                TempData["msgError"] = "Geçersiz mesaj içeriği";
                return View("BulkCompose", model);
            }

            // Fallback synchronous behaviour (korunuyor) — AJAX ile yeni endpoint kullanılacak
            var allUsers = _db.E_User
                .Where(u => u.fldId != user.fldId && (u.IsActive == true || u.fldActive == "1"))
                .ToList();

            if (!allUsers.Any())
            {
                TempData["msgError"] = "Mesaj gönderilecek aktif kullanıcı bulunamadı.";
                return View("BulkCompose", model);
            }

            int successCount = 0;
            int failCount = 0;

            try
            {
                foreach (var recipient in allUsers)
                {
                    try
                    {
                        var message = new E_Messages
                        {
                            fldSenderId = user.fldId,
                            fldSendByName = $"{user.fldName} {user.fldLastName}",
                            fldSendBySicil = user.fldSicil,
                            fldSenderRole = user.Role,
                            fldRecipientId = recipient.fldId,
                            fldRecipientRole = recipient.Role,
                            fldSubject = model.Subject.Trim(),
                            fldMessage = model.Message.Trim(),
                            fldDateTime = DateTime.Now,
                            fldIsRead = false,
                            fldIsDeletedBySender = false,
                            fldIsDeletedByRecipient = false,
                            fldIsReply = false
                        };

                        _db.E_Messages.Add(message);
                        _db.SaveChanges();
                        successCount++;
                    }
                    catch
                    {
                        failCount++;
                    }
                }

                TempData["msgSuccess"] = $"Toplu mesaj gönderildi! Başarılı: {successCount}, Başarısız: {failCount}";
                return RedirectToAction("Sent");
            }
            catch (Exception ex)
            {
                TempData["msgError"] = "Toplu mesaj gönderilirken bir hata oluştu: " + ex.Message;
                return View("BulkCompose", model);
            }
        }

        // Yeni AJAX uç noktası: tek bir alıcıya mesaj gönder (modal ilerleme için)
        // Yeni AJAX uç noktası: tek bir alıcıya mesaj gönder (modal ilerleme için)
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Route("Mesaj/SendToRecipient")]
        public JsonResult SendToRecipient(int recipientId, string subject, string content)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null)
                    return Json(new { success = false, error = "Giriş yapın." });

                // Sadece Admin kullanıcıların toplu işlem yapması bekleniyor
                if (!string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase))
                    return Json(new { success = false, error = "Yetkiniz yok." });

                var result = _messageService.SendMessage(user.fldId, recipientId, subject, content);
                if (result.Success)
                {
                    return Json(new { success = true, messageId = result.MessageId, message = result.Message });
                }
                else
                {
                    return Json(new { success = false, error = result.ErrorMessage ?? "Hata oluştu" });
                }
            }
            catch (Exception ex)
            {
                // Hatanın ayrıntılarını döndürüyoruz; production ortamında loglayıp daha az detay dönün.
                System.Diagnostics.Trace.TraceError($"SendToRecipient Error: {ex}");
                return Json(new { success = false, error = "İşlem sırasında hata oluştu." });
            }
        }

        // GET: /Mesaj/Compose
        [HttpGet]
        [Route("Mesaj/Compose")]
        public ActionResult Compose(int? recipientId = null)
        {
            var user = GetCurrentUser();
            if (user == null)
            {
                TempData["msgError"] = "Lütfen sisteme giriş yapın.";
                return RedirectToAction("Index", "Giris");
            }

            var model = new SendMessageViewModel();

            // Get available recipients
            var recipients = _messageService.GetAvailableRecipients(user.fldId, user.Role);
            model.AvailableRecipients = recipients.Select(r => new SelectListItem
            {
                Value = r.UserId.ToString(),
                Text = $"{r.Name} ({r.Role})",
                Selected = recipientId.HasValue && r.UserId == recipientId.Value
            }).ToList();

            if (recipientId.HasValue)
            {
                model.RecipientId = recipientId.Value;
                var recipient = recipients.FirstOrDefault(r => r.UserId == recipientId.Value);
                if (recipient != null)
                    model.RecipientName = recipient.Name;
            }

            return View(model);
        }

        // POST: /Mesaj/Send
        [HttpPost]
        [Route("Mesaj/Send")]
        [ValidateAntiForgeryToken]
        public ActionResult Send(SendMessageViewModel model)
        {
            var user = GetCurrentUser();
            if (user == null)
            {
                TempData["msgError"] = "Lütfen sisteme giriş yapın.";
                return RedirectToAction("Index", "Giris");
            }

            if (!ModelState.IsValid)
            {
                // Reload recipients
                var recipients = _messageService.GetAvailableRecipients(user.fldId, user.Role);
                model.AvailableRecipients = recipients.Select(r => new SelectListItem
                {
                    Value = r.UserId.ToString(),
                    Text = $"{r.Name} ({r.Role})"
                }).ToList();

                return View("Compose", model);
            }

            var result = _messageService.SendMessage(user.fldId, model.RecipientId, model.Subject, model.Message);

            if (result.Success)
            {
                TempData["msgSuccess"] = result.Message;
                return RedirectToAction("Sent");
            }
            else
            {
                TempData["msgError"] = result.ErrorMessage;

                // Reload recipients
                var recipients = _messageService.GetAvailableRecipients(user.fldId, user.Role);
                model.AvailableRecipients = recipients.Select(r => new SelectListItem
                {
                    Value = r.UserId.ToString(),
                    Text = $"{r.Name} ({r.Role})"
                }).ToList();

                return View("Compose", model);
            }
        }

        // GET: /Mesaj/Details/{id}
        [HttpGet]
        [Route("Mesaj/Details/{id}")]
        public ActionResult Details(int id)
        {
            var user = GetCurrentUser();
            if (user == null)
            {
                TempData["msgError"] = "Lütfen sisteme giriş yapın.";
                return RedirectToAction("Index", "Giris");
            }

            var message = _messageService.GetMessageById(id, user.fldId);

            if (message == null)
            {
                TempData["msgError"] = "Mesaj bulunamadı veya erişim yetkiniz yok.";
                return RedirectToAction("Inbox");
            }

            // Auto mark as read if recipient
            if (message.RecipientId == user.fldId && !message.IsRead)
            {
                _messageService.MarkAsRead(id, user.fldId);
            }

            return View(message);
        }

        // POST: /Mesaj/Reply
        [HttpPost]
        [Route("Mesaj/Reply")]
        [ValidateAntiForgeryToken]
        public ActionResult Reply(int messageId, string replyContent)
        {
            var user = GetCurrentUser();
            if (user == null)
            {
                TempData["msgError"] = "Lütfen sisteme giriş yapın.";
                return RedirectToAction("Index", "Giris");
            }

            if (string.IsNullOrWhiteSpace(replyContent))
            {
                TempData["msgError"] = "Yanıt içeriği boş olamaz.";
                return RedirectToAction("Details", new { id = messageId });
            }

            var result = _messageService.ReplyToMessage(messageId, user.fldId, replyContent);

            if (result.Success)
            {
                TempData["msgSuccess"] = "Yanıt başarıyla gönderildi.";
            }
            else
            {
                TempData["msgError"] = result.ErrorMessage;
            }

            return RedirectToAction("Details", new { id = messageId });
        }

        // POST: /Mesaj/MarkAsRead/{id}
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Route("Mesaj/MarkAsRead/{id}")]
        public JsonResult MarkAsRead(int id)
        {
            var user = GetCurrentUser();
            if (user == null)
                return Json(new { success = false, message = "Giriş yapın." });

            bool success = _messageService.MarkAsRead(id, user.fldId);

            return Json(new { success = success });
        }

        // POST: /Mesaj/Delete/{id}
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Route("Mesaj/Delete/{id}")]
        public JsonResult Delete(int id)
        {
            var user = GetCurrentUser();
            if (user == null)
                return Json(new { success = false, message = "Giriş yapın." });

            bool success = _messageService.DeleteMessage(id, user.fldId);

            if (success)
                return Json(new { success = true, message = "Mesaj silindi." });
            else
                return Json(new { success = false, message = "Mesaj silinemedi." });
        }

        // GET: /Mesaj/GetUnreadCount
        [HttpGet]
        [Route("Mesaj/GetUnreadCount")]
        public JsonResult GetUnreadCount()
        {
            var user = GetCurrentUser();
            if (user == null)
                return Json(new { count = 0 }, JsonRequestBehavior.AllowGet);

            int count = _messageService.GetUnreadCount(user.fldId);

            return Json(new { count = count }, JsonRequestBehavior.AllowGet);
        }

        // GET: /Mesaj/GetRecipients
        [HttpGet]
        [Route("Mesaj/GetRecipients")]
        public JsonResult GetRecipients(string role = null)
        {
            var user = GetCurrentUser();
            if (user == null)
                return Json(new { success = false }, JsonRequestBehavior.AllowGet);

            var recipients = _messageService.GetAvailableRecipients(user.fldId, user.Role);

            return Json(new { success = true, recipients = recipients }, JsonRequestBehavior.AllowGet);
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                _db?.Dispose();
            }
            base.Dispose(disposing);
        }
    }
}
