using CryptoHelper;
using gzpegm.Helpers;
using gzpegm.Cont;
using gzpegm.Models;
using System;
using System.Linq;
using System.Collections.Generic;
using System.Configuration;
using Newtonsoft.Json;
using System.Web;
using System.Web.Mvc;
using System.Data.SqlClient;
using System.Security.Cryptography;

namespace gzpegm.Controllers
{
    public class GirisController : Controller
    {
        // Çıkış
        [HttpGet]
        [Route("Cikis")]
        public ActionResult Logout()
        {
            HttpCookie UserCookie = Request.Cookies["Token"];
            if (UserCookie != null)
            {
                Token token = new Token();
                var check = token.GetToken(UserCookie.Value);
                if (check?.fldUserId != null) token.RemoveToken(Convert.ToInt32(check.fldUserId));

                UserCookie.Expires = DateTime.Now.AddDays(-1);
                Response.Cookies.Add(UserCookie);
            }

            var landingUrl = Url.Action("Index", "Landing") ?? "/";
            return Redirect(landingUrl);
        }

        // Login sayfası (GET)
        [HttpGet]
        [Route("Giris")]
        public ActionResult LoginPage(string returnUrl, bool direct = false)
        {
            ViewBag.ReturnUrl = Url.IsLocalUrl(returnUrl) ? returnUrl : null;
            if (!direct && string.IsNullOrWhiteSpace(ViewBag.ReturnUrl as string))
            {
                return RedirectToAction("Index", "Landing");
            }
            return View("Index"); // Views/Giris/Index.cshtml
        }

        [HttpGet]
        public ActionResult Index(string returnUrl, bool direct = false)
        {
            return LoginPage(returnUrl, direct);
        }

        // Login işlemi (POST)
        [HttpPost]
        [Route("Login")]
        public ActionResult Login(string username, string pwd, string returnUrl)
        {
            var safeReturnUrl = Url.IsLocalUrl(returnUrl) ? returnUrl : null;
            User user = new User();
            Token token = new Token();
            var UserData = user.GetUserBySicilPass(username);

            // JIT Failover Senkronizasyonu: Kullanıcı bu yerel veritabanında yoksa eş sunucudan doğrula ve çek
            if (UserData == null)
            {
                UserData = ServerFailoverHelper.TrySyncUserFromRemote(username, pwd);
            }

            if (UserData == null || (UserData.IsActive.HasValue && !UserData.IsActive.Value) || string.Equals(UserData.fldActive, "0", StringComparison.OrdinalIgnoreCase))
            {
                ViewBag.ReturnUrl = safeReturnUrl;
                ViewBag.Error = "Hatalı Şifre, Sicil Numarası veya Kullanıcı Pasif!";
                return View("Index");
            }

            if (!Crypto.VerifyHashedPassword(UserData.fldPassword.Trim(), pwd.Trim()))
            {
                ViewBag.ReturnUrl = safeReturnUrl;
                ViewBag.Error = "Hatalı Şifre veya Sicil Numarası";
                return View("Index");
            }

            token.RemoveToken(UserData.fldId);

            string strToken = Crypto.HashPassword(UserData.fldId.ToString());

            HttpCookie UserCookie = new HttpCookie("Token", strToken)
            {
                Expires = DateTime.Now.AddHours(3),
                HttpOnly = true,
                Secure = Request.IsSecureConnection,
                SameSite = SameSiteMode.Lax
            };

            Response.Cookies.Add(UserCookie);

            string fldComputerIp = Request.ServerVariables["HTTP_X_FORWARDED_FOR"] ?? Request.UserHostAddress;

            token.AddToken(UserData.fldId, strToken, DateTime.Now, fldComputerIp);

            // Önceki LastLogin değerini saklayalım (DB güncellemeden önce) ve okunmamış mesaj + yeni kurs kontrollerini yapalım
            DateTime? previousLastLogin = UserData.LastLogin;

            string newCourseIds = null;
            int unreadCount = 0;
            try
            {
                using (var _db = new GZPEGM1())
                {
                    unreadCount = _db.E_Messages.Count(m => m.fldRecipientId == UserData.fldId && m.fldIsRead == false && m.fldIsDeletedByRecipient == false);

                    // Yeni kursları kontrol et — hangi kullanıcılara gönderileceği appSettings ile konfigüre edilebilir
                    var notifySetting = ConfigurationManager.AppSettings["NotifyNewCoursesTo"] ?? "Students"; // Students veya All

                    bool shouldNotify = false;
                    if (string.Equals(notifySetting, "All", StringComparison.OrdinalIgnoreCase))
                    {
                        shouldNotify = true;
                    }
                    else if (string.Equals(notifySetting, "Students", StringComparison.OrdinalIgnoreCase))
                    {
                        shouldNotify = string.Equals(UserData.Role, "Student", StringComparison.OrdinalIgnoreCase);
                    }

                    if (shouldNotify)
                    {
                        var newCoursesQuery = _db.Courses.Where(c => c.IsActive == true).OrderByDescending(c => c.CreatedDate);
                        if (previousLastLogin.HasValue)
                        {
                            newCoursesQuery = newCoursesQuery.Where(c => c.CreatedDate.HasValue && c.CreatedDate > previousLastLogin.Value).OrderByDescending(c => c.CreatedDate);
                        }

                        var newCourseCount = newCoursesQuery.Count();
                        if (newCourseCount > 0)
                        {
                        var briefs = newCoursesQuery
                            .Take(5)
                            .Select(c => new gzpegm.Models.CourseBrief { CourseId = c.CourseId, CourseTitle = c.CourseTitle, CoverImage = c.CoverImage, CreatedDate = c.CreatedDate })
                            .ToList();

                            // TempData'ya JSON string koy (serileştirme problemlerine karşı daha güvenli)
                            try
                            {
                                TempData["NewCoursesJson"] = JsonConvert.SerializeObject(briefs);
                            }
                            catch
                            {
                                // Fallback: boş bırak
                            }

                            // Ayrıca querystring ile course id'lerini gönder (fallback)
                            newCourseIds = string.Join(",", briefs.Select(b => b.CourseId));
                        }
                    }
                }
            }
            catch
            {
                // DB hatası olursa default yönlendirme ile devam
            }

            // Update last login AFTER we've captured previousLastLogin
            try
            {
                user.UpdateLastLogin(UserData.fldId, DateTime.Now, fldComputerIp);
            }
            catch { }

            if (!string.IsNullOrWhiteSpace(safeReturnUrl))
            {
                TempData.Remove("msgError");
                return Redirect(safeReturnUrl);
            }

            if (!string.IsNullOrEmpty(newCourseIds))
            {
                // Redirect to Home so Home/Index can show the unread-message modal (ForceUnreadModal)
                return RedirectToAction("Index", "Home", new { forceUnread = (unreadCount > 0 ? 1 : 0), newCourseIds = newCourseIds });
            }

            // Redirect to Home so Home/Index can show the unread-message modal (ForceUnreadModal)
            return RedirectToAction("Index", "Home", new { forceUnread = (unreadCount > 0 ? 1 : 0) });
        }

        /// <summary>
        /// Şifre Sıfırlama Sayfası
        /// İnternetsiz kurumsal ortamda kullanım için
        /// </summary>
        [HttpGet]
        [Route("SifreSifirla")]
        public ActionResult ResetPasswordPage()
        {
            return View("ResetPassword");
        }

        /// <summary>
        /// Şifre Sıfırlama İsteği
        /// Sicil numarası ve e-posta ile anında şifre sıfırlaması
        /// Yeni şifre direkt ekranda gösterilir
        /// </summary>
        [HttpPost]
        [Route("SifreSifirla")]
        [ValidateAntiForgeryToken]
        public ActionResult ResetPassword(string sicil, string email)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(sicil) || string.IsNullOrWhiteSpace(email))
                {
                    return Json(new { success = false, message = "Sicil numarası ve e-posta adresi gerekli!" });
                }

                User userCont = new User();
                var userData = userCont.GetUserBySicil(sicil.Trim());

                // Kullanıcı bulunamadı veya pasif
                if (userData == null)
                {
                    return Json(new { success = false, message = "Sicil numarası sistemde bulunamadı!" });
                }

                if (userData.IsActive.HasValue && !userData.IsActive.Value || 
                    string.Equals(userData.fldActive, "0", StringComparison.OrdinalIgnoreCase))
                {
                    return Json(new { success = false, message = "Bu kullanıcı hesabı pasif durumdadır!" });
                }

                // Email doğrulama
                string userEmail = (userData.fldEmail ?? "").Trim().ToLower();
                if (!userEmail.Equals(email.Trim().ToLower(), StringComparison.OrdinalIgnoreCase))
                {
                    return Json(new { success = false, message = "E-posta adresi eşleşmiyor!" });
                }

                // Geçici şifre, sistemdeki kullanıcı adı olan sicil numarasıyla aynıdır.
                // Bu aşamada kullanıcının aktif şifresi DEĞİŞMEZ; sadece yönetici
                // onayı bekleyen bir talep oluşturulur.
                string newPassword = userData.fldSicil.Trim();
                string hashedPassword = Crypto.HashPassword(newPassword);

                using (var db = new GZPEGM1())
                using (var transaction = db.Database.BeginTransaction())
                {
                    // Aynı kullanıcı için bekleyen eski talepler geçersiz sayılır.
                    db.Database.ExecuteSqlCommand(
                        "UPDATE dbo.PasswordResetRequests SET Status = 'Superseded' WHERE UserId = @userId AND Status = 'Pending'",
                        new SqlParameter("@userId", userData.fldId));

                    db.Database.ExecuteSqlCommand(
                        "INSERT INTO dbo.PasswordResetRequests (UserId, PendingPasswordHash, RequestedAt, Status) VALUES (@userId, @passwordHash, GETDATE(), 'Pending')",
                        new SqlParameter("@userId", userData.fldId),
                        new SqlParameter("@passwordHash", hashedPassword));

                    transaction.Commit();
                }

                // Başarılı sonuç döndür
                string fullName = (userData.fldName ?? "") + " " + (userData.fldLastName ?? "");

                return Json(new
                {
                    success = true,
                    message = "Şifre sıfırlama talebiniz alındı. Yeni şifrenizi yönetici onayladıktan sonra kullanabilirsiniz.",
                    userInfo = new
                    {
                        sicil = userData.fldSicil,
                        adSoyad = fullName,
                        email = userData.fldEmail,
                        yeniSifre = newPassword
                    }
                });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Şifre sıfırlama hatası: {ex.Message}");
                return Json(new { success = false, message = "Bir hata oluştu: " + ex.Message });
            }
        }

        /// <summary>
        /// Güvenli şifre oluştur
        /// Büyük harf + küçük harf + sayı + sembol içerir
        /// </summary>
        private string GenerateSecurePassword()
        {
            const string uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
            const string lowercase = "abcdefghijklmnopqrstuvwxyz";
            const string numbers = "0123456789";
            const string symbols = "!@#$%^&*";

            var password = new List<char>();

            // Her türden en az 1 karakter ekle. Random yerine kriptografik
            // rastgele sayı üreteci kullanılır.
            password.Add(GetRandomCharacter(uppercase));
            password.Add(GetRandomCharacter(lowercase));
            password.Add(GetRandomCharacter(numbers));
            password.Add(GetRandomCharacter(symbols));

            // Kalan 4 karakteri rastgele seç
            string allChars = uppercase + lowercase + numbers + symbols;
            for (int i = 0; i < 4; i++)
            {
                password.Add(GetRandomCharacter(allChars));
            }

            // Karakterleri karıştır
            char[] chars = password.ToArray();
            for (int i = chars.Length - 1; i > 0; i--)
            {
                int randomIndex = GetRandomIndex(i + 1);
                char temp = chars[i];
                chars[i] = chars[randomIndex];
                chars[randomIndex] = temp;
            }

            return new string(chars);
        }

        private static char GetRandomCharacter(string characters)
        {
            return characters[GetRandomIndex(characters.Length)];
        }

        private static int GetRandomIndex(int maxExclusive)
        {
            using (var rng = RandomNumberGenerator.Create())
            {
                byte[] bytes = new byte[4];
                rng.GetBytes(bytes);
                return (int)(BitConverter.ToUInt32(bytes, 0) % (uint)maxExclusive);
            }
        }
    }
}

