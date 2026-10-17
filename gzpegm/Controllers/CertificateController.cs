using gzpegm.Cont;
using gzpegm.Models;
using gzpegm.Services;
using System;
using System.Data.Entity;
using System.Linq;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize(Users = "2,3,6")]
    public class CertificateController : Controller
    {
        private GZPEGM1 db = new GZPEGM1();
        private EmailService emailService = new EmailService();

        private E_User GetCurrentUser()
        {
            try
            {
                var cookie = Request.Cookies["Token"];
                if (cookie == null) return null;
                var token = new Token();
                var tokenData = token.GetToken(cookie.Value);
                if (tokenData == null) return null;
                int userId = 0;
                int.TryParse(tokenData.fldUserId?.ToString(), out userId);
                if (userId == 0) return null;
                var user = new User();
                return user.GetUserById(userId);
            }
            catch { return null; }
        }

        // Admin: Bekleyen sertifika talepleri
        public ActionResult PendingRequests()
        {
            var user = GetCurrentUser();
            if (user == null) return RedirectToAction("Index", "Landing");
            if (user.Role != "Admin")
            {
                TempData["msgError"] = "Bu sayfaya erişim yetkiniz yok.";
                return RedirectToAction("StudentIndex", "Course");
            }

            var requests = db.CertificateRequest
                .Where(r => r.Status == 0)
                .OrderByDescending(r => r.RequestDate)
                .ToList();

            var userIds = requests.Select(r => r.UserId).Distinct().ToList();
            var courseIds = requests.Select(r => r.CourseId).Distinct().ToList();
            var users = db.E_User.Where(u => userIds.Contains(u.fldId)).ToList();
            var courses = db.Courses.Where(c => courseIds.Contains(c.CourseId)).ToList();

            foreach (var r in requests)
            {
                r.E_User = users.FirstOrDefault(u => u.fldId == r.UserId);
                r.Courses = courses.FirstOrDefault(c => c.CourseId == r.CourseId);
            }

            return View(requests);
        }

        // Admin: Talebi onayla
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Approve(int requestId)
        {
            var admin = GetCurrentUser();
            if (admin == null || admin.Role != "Admin")
            {
                TempData["msgError"] = "Yetkiniz yok.";
                return RedirectToAction("PendingRequests");
            }

            try
            {
                var request = db.CertificateRequest.FirstOrDefault(r => r.RequestId == requestId);

                if (request == null)
                {
                    TempData["msgError"] = "Talep bulunamadı.";
                    return RedirectToAction("PendingRequests");
                }

                bool alreadyCertified = db.Certificate.Any(c =>
                    c.UserId == request.UserId && c.CourseId == request.CourseId);

                if (!alreadyCertified)
                {
                    var certificate = new Certificate
                    {
                        UserId = request.UserId,
                        CourseId = request.CourseId,
                        CertificateNumber = "CERT-" + DateTime.Now.ToString("yyyyMMdd") + "-" + request.RequestId.ToString("D5"),
                        IssuedDate = DateTime.Now,
                        Score = 0,
                        IsActive = true,
                        CreatedAt = DateTime.Now
                    };
                    db.Certificate.Add(certificate);
                }

                request.Status = 1;
                request.ProcessedDate = DateTime.Now;
                request.ProcessedBy = admin.fldId;
                db.SaveChanges();

                // Email gönder
                var user = db.E_User.FirstOrDefault(u => u.fldId == request.UserId);
                if (user != null && !string.IsNullOrEmpty(user.fldEmail))
                {
                    try
                    {
                        var course = db.Courses.FirstOrDefault(c => c.CourseId == request.CourseId);
                        string certUrl = Url.Action("MyCertificates", "Certificate", null, Request.Url.Scheme);
                        emailService.SendCertificateEmailAsync(
                            user.fldEmail,
                            user.fldName + " " + user.fldLastName,
                            course?.CourseTitle ?? "",
                            certUrl
                        ).Wait();
                    }
                    catch (Exception emailEx)
                    {
                        System.Diagnostics.Trace.TraceError($"Certificate Email Error: {emailEx.Message}");
                    }
                }

                TempData["msgSuccess"] = "Sertifika talebi onaylandı ve öğrenciye bildirim gönderildi.";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Certificate Approve Error: {ex.Message}");
                TempData["msgError"] = "Onaylama sırasında hata oluştu: " + ex.Message;
            }

            return RedirectToAction("PendingRequests");
        }

        // Admin: Talebi reddet
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Reject(int requestId, string adminNote)
        {
            var admin = GetCurrentUser();
            if (admin == null || admin.Role != "Admin")
            {
                TempData["msgError"] = "Yetkiniz yok.";
                return RedirectToAction("PendingRequests");
            }

            try
            {
                var request = db.CertificateRequest.Find(requestId);
                if (request == null)
                {
                    TempData["msgError"] = "Talep bulunamadı.";
                    return RedirectToAction("PendingRequests");
                }

                request.Status = 2;
                request.AdminNote = adminNote;
                request.ProcessedDate = DateTime.Now;
                request.ProcessedBy = admin.fldId;
                db.SaveChanges();

                TempData["msgSuccess"] = "Talep reddedildi.";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Certificate Reject Error: {ex.Message}");
                TempData["msgError"] = "Red işlemi sırasında hata oluştu.";
            }

            return RedirectToAction("PendingRequests");
        }

        // Öğrenci: Kendi sertifikaları
        public ActionResult MyCertificates()
        {
            var user = GetCurrentUser();
            if (user == null) return RedirectToAction("Index", "Landing");

            var certificates = db.Certificate
                .Include(c => c.Courses)
                .Where(c => c.UserId == user.fldId && c.IsActive)
                .OrderByDescending(c => c.IssuedDate)
                .ToList();

            ViewBag.CurrentUser = user;
            return View(certificates);
        }

        // Sertifikayı görüntüle (HTML olarak)
        public ActionResult ViewCertificate(int certificateId)
        {
            var user = GetCurrentUser();
            if (user == null) return RedirectToAction("Index", "Landing");

            var certificate = db.Certificate
                .Include(c => c.Courses)
                .FirstOrDefault(c => c.CertificateId == certificateId && c.UserId == user.fldId && c.IsActive);

            if (certificate == null)
            {
                TempData["msgError"] = "Sertifika bulunamadı veya erişim yetkiniz yok.";
                return RedirectToAction("MyCertificates");
            }

            ViewBag.CurrentUser = user;
            return View(certificate);
        }

        // Sertifikayı indir (PDF)
        public ActionResult DownloadCertificate(int certificateId)
        {
            var user = GetCurrentUser();
            if (user == null) return RedirectToAction("Index", "Landing");

            var certificate = db.Certificate
                .FirstOrDefault(c => c.CertificateId == certificateId && c.UserId == user.fldId && c.IsActive);

            if (certificate == null)
            {
                TempData["msgError"] = "Sertifika bulunamadı veya erişim yetkiniz yok.";
                return RedirectToAction("MyCertificates");
            }

            try
            {
                // Eğer FilePath varsa ve dosya mevcutsa, onu indir
                if (!string.IsNullOrEmpty(certificate.FilePath) && System.IO.File.Exists(certificate.FilePath))
                {
                    byte[] fileBytes = System.IO.File.ReadAllBytes(certificate.FilePath);
                    string fileName = $"Sertifika_{certificate.CertificateNumber}.pdf";
                    return File(fileBytes, "application/pdf", fileName);
                }
                else
                {
                    // Dosya yoksa HTML'i PDF'e dönüştürüp indir
                    // İleride iTextSharp, SelectPdf vb. kullanabilirsiniz
                    TempData["msgError"] = "Sertifika dosyası henüz hazırlanmadı.";
                    return RedirectToAction("MyCertificates");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Certificate Download Error: {ex.Message}");
                TempData["msgError"] = "Sertifika indirilirken hata oluştu.";
                return RedirectToAction("MyCertificates");
            }
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing) db.Dispose();
            base.Dispose(disposing);
        }
    }
}
