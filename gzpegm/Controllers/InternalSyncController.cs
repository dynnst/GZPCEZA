using CryptoHelper;
using gzpegm.Helpers;
using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    /// <summary>
    /// EGM CEZAM Portalı - Sunucular Arası Güvenli Kullanıcı Senkronizasyon API'si.
    /// 10.7.202.75 (Ana) ile 10.7.202.76 (Yedek) sunucuları arasında
    /// kullanıcıların çift yönlü senkronizasyonunu ve oturum doğrulamasını sağlar.
    /// </summary>
    public class InternalSyncController : Controller
    {
        private static string SyncSecret => ConfigurationManager.AppSettings["InternalSyncSecret"] ?? "GZPEGM-CEZAM-SYNC-KEY-2026";

        private bool ValidateSecurity()
        {
            var token = Request.Headers["X-Internal-Sync-Token"]
                        ?? Request.QueryString["syncSecret"]
                        ?? Request.Form["syncSecret"];

            if (string.IsNullOrWhiteSpace(token) || token.Trim() != SyncSecret.Trim())
            {
                return false;
            }

            return true;
        }

        /// <summary>
        /// Uzak sunucudan gelen sicil ve şifreyi doğrular. Geçerliyse kullanıcı profilini döner.
        /// </summary>
        [HttpPost]
        [Route("internal-sync/verify-and-get-user")]
        public JsonResult VerifyAndGetUser(string sicil, string password)
        {
            if (!ValidateSecurity())
                return Json(new { success = false, message = "Yetkisiz erişim." });

            if (string.IsNullOrWhiteSpace(sicil) || string.IsNullOrWhiteSpace(password))
                return Json(new { success = false, message = "Eksik parametre." });

            try
            {
                using (var db = new GZPEGM1())
                {
                    var cleanSicil = sicil.Trim();
                    var user = db.E_User.FirstOrDefault(u => u.fldSicil.Trim() == cleanSicil);
                    if (user == null)
                        return Json(new { success = false, message = "Kullanıcı bulunamadı." });

                    if ((user.IsActive.HasValue && !user.IsActive.Value) || string.Equals(user.fldActive, "0", StringComparison.OrdinalIgnoreCase))
                        return Json(new { success = false, message = "Kullanıcı pasif." });

                    if (!Crypto.VerifyHashedPassword(user.fldPassword.Trim(), password.Trim()))
                        return Json(new { success = false, message = "Şifre uyuşmuyor." });

                    return Json(new
                    {
                        success = true,
                        user = new
                        {
                            fldSicil = user.fldSicil?.Trim(),
                            fldPassword = user.fldPassword?.Trim(),
                            fldName = user.fldName?.Trim(),
                            fldLastName = user.fldLastName?.Trim(),
                            fldPhone = user.fldPhone?.Trim(),
                            fldEmail = user.fldEmail?.Trim(),
                            fldTitle = user.fldTitle?.Trim(),
                            fldDeputy = user.fldDeputy?.Trim(),
                            fldBorder = user.fldBorder?.Trim(),
                            fldActive = user.fldActive,
                            IsActive = user.IsActive,
                            Role = user.Role,
                            fldAuth = user.fldAuth,
                            fldPicture = user.fldPicture
                        }
                    });
                }
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = "Sunucu hatası: " + ex.Message });
            }
        }

        /// <summary>
        /// Bu sunucudaki tüm kullanıcıların özet listesini (Sicil, İsim, Rol vb.) döner.
        /// </summary>
        [HttpGet]
        [Route("internal-sync/users-summary")]
        public JsonResult GetUsersSummary()
        {
            if (!ValidateSecurity())
                return Json(new { success = false, message = "Yetkisiz erişim." }, JsonRequestBehavior.AllowGet);

            try
            {
                using (var db = new GZPEGM1())
                {
                    var users = db.E_User
                        .AsNoTracking()
                        .Where(u => !string.IsNullOrEmpty(u.fldSicil))
                        .ToList()
                        .Select(u => new
                        {
                            Sicil = u.fldSicil.Trim(),
                            FullName = string.Format("{0} {1}", u.fldName ?? "", u.fldLastName ?? "").Trim(),
                            Title = u.fldTitle ?? "-",
                            Border = u.fldBorder ?? "-",
                            Role = u.Role ?? "Kullanıcı",
                            Auth = u.fldAuth ?? "-",
                            IsActive = (u.IsActive == true || u.fldActive == "1")
                        })
                        .ToList();

                    return Json(new { success = true, count = users.Count, users = users }, JsonRequestBehavior.AllowGet);
                }
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = "Kullanıcı listesi alınamadı: " + ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        /// <summary>
        /// Belirtilen sicillere sahip kullanıcıların tam veritabanı kayıtlarını döner.
        /// </summary>
        [HttpPost]
        [Route("internal-sync/get-users-detail")]
        public JsonResult GetUsersDetail(List<string> sicils)
        {
            if (!ValidateSecurity())
                return Json(new { success = false, message = "Yetkisiz erişim." });

            if (sicils == null || !sicils.Any())
                return Json(new { success = false, message = "Sicil listesi boş." });

            try
            {
                using (var db = new GZPEGM1())
                {
                    var cleanSicils = sicils
                        .Where(s => !string.IsNullOrWhiteSpace(s))
                        .Select(s => s.Trim())
                        .Distinct(StringComparer.OrdinalIgnoreCase)
                        .ToList();

                    var allUsers = db.E_User.AsNoTracking().ToList();

                    var matchedUsers = allUsers
                        .Where(u => !string.IsNullOrWhiteSpace(u.fldSicil) && cleanSicils.Contains(u.fldSicil.Trim(), StringComparer.OrdinalIgnoreCase))
                        .Select(user => new
                        {
                            fldSicil = user.fldSicil?.Trim(),
                            fldPassword = user.fldPassword?.Trim(),
                            fldName = user.fldName?.Trim(),
                            fldLastName = user.fldLastName?.Trim(),
                            fldPhone = user.fldPhone?.Trim(),
                            fldEmail = user.fldEmail?.Trim(),
                            fldTitle = user.fldTitle?.Trim(),
                            fldDeputy = user.fldDeputy?.Trim(),
                            fldBorder = user.fldBorder?.Trim(),
                            fldActive = user.fldActive,
                            IsActive = user.IsActive,
                            Role = user.Role,
                            fldAuth = user.fldAuth,
                            fldPicture = user.fldPicture
                        })
                        .ToList();

                    return Json(new { success = true, count = matchedUsers.Count, users = matchedUsers });
                }
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = "Kullanıcı detayları alınamadı: " + ex.Message });
            }
        }
    }
}
