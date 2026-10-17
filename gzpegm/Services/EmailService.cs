using System;
using System.Configuration;
using System.Net;
using System.Net.Mail;
using System.Threading.Tasks;

namespace gzpegm.Services
{
    public class EmailService
    {
        private readonly string _smtpHost;
        private readonly int _smtpPort;
        private readonly string _smtpUsername;
        private readonly string _smtpPassword;
        private readonly string _fromEmail;
        private readonly string _fromName;
        private readonly bool _enableSsl;

        public EmailService()
        {
            _smtpHost = ConfigurationManager.AppSettings["SmtpHost"] ?? "smtp.gmail.com";
            _smtpPort = int.Parse(ConfigurationManager.AppSettings["SmtpPort"] ?? "587");
            _smtpUsername = ConfigurationManager.AppSettings["SmtpUsername"] ?? "";
            _smtpPassword = ConfigurationManager.AppSettings["SmtpPassword"] ?? "";
            _fromEmail = ConfigurationManager.AppSettings["FromEmail"] ?? "";
            _fromName = ConfigurationManager.AppSettings["FromName"] ?? "GZPEGM Eğitim Sistemi";
            _enableSsl = bool.Parse(ConfigurationManager.AppSettings["SmtpEnableSsl"] ?? "true");
        }

        public async Task<bool> SendEmailAsync(string toEmail, string subject, string body, bool isHtml = true)
        {
            try
            {
                using (var message = new MailMessage())
                {
                    message.From = new MailAddress(_fromEmail, _fromName);
                    message.To.Add(new MailAddress(toEmail));
                    message.Subject = subject;
                    message.Body = body;
                    message.IsBodyHtml = isHtml;

                    using (var client = new SmtpClient(_smtpHost, _smtpPort))
                    {
                        client.Credentials = new NetworkCredential(_smtpUsername, _smtpPassword);
                        client.EnableSsl = _enableSsl;
                        await client.SendMailAsync(message);
                    }
                }
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Email Send Error: {ex.Message}");
                return false;
            }
        }

        // Sınav sonucu bildirimi
        public async Task SendExamResultEmailAsync(string toEmail, string userName, string examTitle, int score, int maxScore, bool isPassed)
        {
            string subject = $"Sınav Sonucunuz: {examTitle}";
            string body = GetExamResultEmailTemplate(userName, examTitle, score, maxScore, isPassed);
            await SendEmailAsync(toEmail, subject, body);
        }

        // Kursa kayıt bildirimi
        public async Task SendCourseEnrollmentEmailAsync(string toEmail, string userName, string courseTitle)
        {
            string subject = $"Kursa Kayıt Onayı: {courseTitle}";
            string body = GetCourseEnrollmentEmailTemplate(userName, courseTitle);
            await SendEmailAsync(toEmail, subject, body);
        }

        // Sertifika kazanma bildirimi
        public async Task SendCertificateEmailAsync(string toEmail, string userName, string courseTitle, string certificateUrl)
        {
            string subject = $"🎓 Tebrikler! Sertifikanız Hazır: {courseTitle}";
            string body = GetCertificateEmailTemplate(userName, courseTitle, certificateUrl);
            await SendEmailAsync(toEmail, subject, body);
        }

        // Sınav hatırlatma bildirimi
        public async Task SendExamReminderEmailAsync(string toEmail, string userName, string examTitle, DateTime examDate)
        {
            string subject = $"Sınav Hatırlatması: {examTitle}";
            string body = GetExamReminderEmailTemplate(userName, examTitle, examDate);
            await SendEmailAsync(toEmail, subject, body);
        }

        // Şifre sıfırlama e-postası
        public async Task SendPasswordResetEmailAsync(string toEmail, string fullName, string sicil, string newPassword)
        {
            // @egm.gov.tr kontrolü
            if (!toEmail.EndsWith("@egm.gov.tr", StringComparison.OrdinalIgnoreCase))
            {
                throw new InvalidOperationException("Sadece @egm.gov.tr uzantılı e-posta adresleri desteklenmektedir.");
            }

            string subject = "🔐 Şifre Sıfırlama İşlemi - GZPEGM Eğitim Sistemi";
            string body = GetPasswordResetEmailTemplate(fullName, sicil, newPassword);
            await SendEmailAsync(toEmail, subject, body);
        }

        #region Email Templates

        private string GetExamResultEmailTemplate(string userName, string examTitle, int score, int maxScore, bool isPassed)
        {
            double percentage = (double)score / maxScore * 100;
            string statusColor = isPassed ? "#28a745" : "#dc3545";
            string statusText = isPassed ? "BAŞARILI" : "BAŞARISIZ";

            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <style>
        body {{ font-family: Arial, sans-serif; background-color: #f4f4f4; margin: 0; padding: 0; }}
        .container {{ max-width: 600px; margin: 20px auto; background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }}
        .header {{ background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; }}
        .content {{ padding: 30px; }}
        .score-box {{ background: #f8f9fa; border-left: 4px solid {statusColor}; padding: 20px; margin: 20px 0; border-radius: 5px; }}
        .score-big {{ font-size: 48px; font-weight: bold; color: {statusColor}; }}
        .status-badge {{ display: inline-block; background: {statusColor}; color: white; padding: 10px 20px; border-radius: 20px; font-weight: bold; }}
        .footer {{ background: #f8f9fa; padding: 20px; text-align: center; color: #666; font-size: 12px; }}
        .btn {{ display: inline-block; background: #667eea; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; margin-top: 20px; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>🎓 Sınav Sonucunuz</h1>
        </div>
        <div class='content'>
            <p>Merhaba <strong>{userName}</strong>,</p>
            <p><strong>{examTitle}</strong> sınavınız tamamlandı.</p>
            
            <div class='score-box'>
                <div style='text-align: center;'>
                    <div class='score-big'>{score}/{maxScore}</div>
                    <p style='font-size: 18px; color: #666;'>Başarı Oranı: %{percentage:F1}</p>
                    <span class='status-badge'>{statusText}</span>
                </div>
            </div>

            <p>{(isPassed ? "🎉 Tebrikler! Sınavı başarıyla geçtiniz." : "😔 Maalesef sınavı geçemediniz. Tekrar deneyebilirsiniz.")}</p>
            
            <div style='text-align: center;'>
                <a href='#' class='btn'>Detaylı Sonuçları Görüntüle</a>
            </div>
        </div>
        <div class='footer'>
            <p>Bu bir otomatik bildirimdir. Lütfen yanıtlamayın.</p>
            <p>&copy; 2024 GZPEGM Eğitim Sistemi</p>
        </div>
    </div>
</body>
</html>";
        }

        private string GetCourseEnrollmentEmailTemplate(string userName, string courseTitle)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <style>
        body {{ font-family: Arial, sans-serif; background-color: #f4f4f4; margin: 0; padding: 0; }}
        .container {{ max-width: 600px; margin: 20px auto; background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }}
        .header {{ background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; }}
        .content {{ padding: 30px; }}
        .course-box {{ background: #f8f9fa; padding: 20px; margin: 20px 0; border-radius: 5px; border-left: 4px solid #667eea; }}
        .footer {{ background: #f8f9fa; padding: 20px; text-align: center; color: #666; font-size: 12px; }}
        .btn {{ display: inline-block; background: #667eea; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; margin-top: 20px; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>✅ Kursa Kayıt Onayı</h1>
        </div>
        <div class='content'>
            <p>Merhaba <strong>{userName}</strong>,</p>
            <p>Aşağıdaki kursa başarıyla kayıt oldunuz:</p>
            
            <div class='course-box'>
                <h3 style='margin: 0; color: #667eea;'>📚 {courseTitle}</h3>
            </div>

            <p>✨ Kurs içeriklerine hemen erişebilir ve öğrenmeye başlayabilirsiniz.</p>
            
            <div style='text-align: center;'>
                <a href='#' class='btn'>Kursa Git</a>
            </div>
        </div>
        <div class='footer'>
            <p>Bu bir otomatik bildirimdir. Lütfen yanıtlamayın.</p>
            <p>&copy; 2024 GZPEGM Eğitim Sistemi</p>
        </div>
    </div>
</body>
</html>";
        }

        private string GetCertificateEmailTemplate(string userName, string courseTitle, string certificateUrl)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <style>
        body {{ font-family: Arial, sans-serif; background-color: #f4f4f4; margin: 0; padding: 0; }}
        .container {{ max-width: 600px; margin: 20px auto; background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }}
        .header {{ background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); color: white; padding: 30px; text-align: center; }}
        .content {{ padding: 30px; }}
        .certificate-box {{ background: linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%); padding: 30px; margin: 20px 0; border-radius: 10px; text-align: center; }}
        .footer {{ background: #f8f9fa; padding: 20px; text-align: center; color: #666; font-size: 12px; }}
        .btn {{ display: inline-block; background: #f5576c; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; margin-top: 20px; font-weight: bold; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>🎓 Tebrikler!</h1>
        </div>
        <div class='content'>
            <p>Merhaba <strong>{userName}</strong>,</p>
            
            <div class='certificate-box'>
                <h2 style='margin: 0; color: #f5576c;'>🏆 Sertifikanız Hazır!</h2>
                <p style='font-size: 18px; margin-top: 10px;'><strong>{courseTitle}</strong></p>
            </div>

            <p>🎉 Kursu başarıyla tamamladınız ve sertifikanızı kazandınız!</p>
            <p>Sertifikanızı aşağıdaki butondan indirebilirsiniz.</p>
            
            <div style='text-align: center;'>
                <a href='{certificateUrl}' class='btn'>📥 Sertifikayı İndir</a>
            </div>
        </div>
        <div class='footer'>
            <p>Bu bir otomatik bildirimdir. Lütfen yanıtlamayın.</p>
            <p>&copy; 2024 GZPEGM Eğitim Sistemi</p>
        </div>
    </div>
</body>
</html>";
        }

        private string GetExamReminderEmailTemplate(string userName, string examTitle, DateTime examDate)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <style>
        body {{ font-family: Arial, sans-serif; background-color: #f4f4f4; margin: 0; padding: 0; }}
        .container {{ max-width: 600px; margin: 20px auto; background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }}
        .header {{ background: linear-gradient(135deg, #ffa751 0%, #ffe259 100%); color: white; padding: 30px; text-align: center; }}
        .content {{ padding: 30px; }}
        .reminder-box {{ background: #fff3cd; border-left: 4px solid #ffc107; padding: 20px; margin: 20px 0; border-radius: 5px; }}
        .footer {{ background: #f8f9fa; padding: 20px; text-align: center; color: #666; font-size: 12px; }}
        .btn {{ display: inline-block; background: #ffa751; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; margin-top: 20px; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>⏰ Sınav Hatırlatması</h1>
        </div>
        <div class='content'>
            <p>Merhaba <strong>{userName}</strong>,</p>
            
            <div class='reminder-box'>
                <h3 style='margin: 0; color: #856404;'>📝 {examTitle}</h3>
                <p style='margin: 10px 0 0 0;'>Tarih: <strong>{examDate:dd.MM.yyyy HH:mm}</strong></p>
            </div>

            <p>⚠️ Sınavınız yaklaşıyor! Hazırlıklarınızı tamamlamayı unutmayın.</p>
            
            <div style='text-align: center;'>
                <a href='#' class='btn'>Sınava Git</a>
            </div>
        </div>
        <div class='footer'>
            <p>Bu bir otomatik bildirimdir. Lütfen yanıtlamayın.</p>
            <p>&copy; 2024 GZPEGM Eğitim Sistemi</p>
        </div>
    </div>
</body>
</html>";
        }

        #endregion

        private string GetPasswordResetEmailTemplate(string fullName, string sicil, string newPassword)
        {
            return $@"
<!DOCTYPE html>
<html lang='tr'>
<head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Şifre Sıfırlama</title>
    <style>
        body {{ font-family: 'Segoe UI', Arial, sans-serif; line-height: 1.6; color: #333; background-color: #f5f5f5; margin: 0; padding: 0; }}
        .container {{ max-width: 600px; margin: 20px auto; background-color: #fff; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); overflow: hidden; }}
        .header {{ background: linear-gradient(135deg, #1a237e 0%, #283593 100%); color: white; padding: 30px; text-align: center; }}
        .header h1 {{ margin: 0; font-size: 28px; font-weight: 700; }}
        .header p {{ margin: 10px 0 0; opacity: 0.9; font-size: 14px; }}
        .content {{ padding: 30px; }}
        .info-box {{ background-color: #f0f7ff; border-left: 4px solid #1976d2; padding: 15px; margin: 20px 0; border-radius: 4px; }}
        .info-box p {{ margin: 8px 0; font-size: 14px; }}
        .password-box {{ background-color: #fff3e0; border: 2px solid #ff9800; padding: 20px; margin: 20px 0; border-radius: 6px; text-align: center; }}
        .password-box .label {{ font-size: 12px; color: #666; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 10px; font-weight: 600; }}
        .password-box .password {{ font-family: 'Courier New', monospace; font-size: 18px; font-weight: bold; color: #d32f2f; letter-spacing: 2px; padding: 10px; background-color: #fafafa; border-radius: 4px; word-break: break-all; }}
        .warning {{ background-color: #ffebee; border-left: 4px solid #d32f2f; padding: 15px; margin: 20px 0; border-radius: 4px; color: #b71c1c; }}
        .warning strong {{ display: block; margin-bottom: 8px; }}
        .warning p {{ margin: 0; font-size: 13px; }}
        .instructions {{ background-color: #f5f5f5; padding: 15px; border-radius: 4px; margin: 20px 0; }}
        .instructions ol {{ margin: 0; padding-left: 20px; }}
        .instructions li {{ margin: 8px 0; font-size: 14px; }}
        .footer {{ background-color: #f5f5f5; padding: 20px; text-align: center; font-size: 12px; color: #666; border-top: 1px solid #ddd; }}
        .footer p {{ margin: 4px 0; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>🔐 Şifre Sıfırlama</h1>
            <p>GZPEGM Eğitim Sistemi</p>
        </div>
        <div class='content'>
            <p>Merhaba <strong>{System.Web.HttpUtility.HtmlEncode(fullName)}</strong>,</p>
            <p>Şifrenizi sıfırlama talebiniz karşılanmıştır. Aşağıda yeni şifreniz bulunmaktadır.</p>

            <div class='info-box'>
                <p><strong>Sicil Numarası:</strong> {System.Web.HttpUtility.HtmlEncode(sicil)}</p>
                <p><strong>Hesap E-postası:</strong> {System.Web.HttpUtility.HtmlEncode(fullName)}</p>
            </div>

            <div class='password-box'>
                <div class='label'>Yeni Şifreniz:</div>
                <div class='password'>{System.Web.HttpUtility.HtmlEncode(newPassword)}</div>
            </div>

            <div class='instructions'>
                <strong>Talimatlar:</strong>
                <ol>
                    <li>Yukarıdaki şifre ile sisteme giriş yapınız.</li>
                    <li><strong>İlk giriş sırasında şifrenizi mutlaka değiştiriniz.</strong></li>
                    <li>Yeni şifreniz güvenli bir yerde saklayınız.</li>
                    <li>Bu şifreyi başka kimseyle paylaşmayınız.</li>
                </ol>
            </div>

            <div class='warning'>
                <strong>⚠ Güvenlik Uyarısı</strong>
                <p>Bu e-postayı siz talep etmemişseniz, lütfen sistem yöneticisine bilgi veriniz. Bu e-posta otomatik olarak oluşturulmuştur, lütfen yanıt vermeyiniz.</p>
            </div>
        </div>
        <div class='footer'>
            <p><strong>&copy; T.C. İçişleri Bakanlığı Emniyet Genel Müdürlüğü</strong></p>
            <p>Bu otomatik e-postanın adresine yanıt vermeyin.</p>
        </div>
    </div>
</body>
</html>";
        }
    }
}
