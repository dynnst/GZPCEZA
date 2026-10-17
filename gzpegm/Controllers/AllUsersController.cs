using gzpegm.Cont;
using gzpegm.Helpers;
using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize(Users = "2")]
    public class AllUsersController : Controller
    {
        private sealed class OrphanCandidateInfo
        {
            public int fldId { get; set; }
            public string fldSicil { get; set; }
            public string fldName { get; set; }
            public string fldLastName { get; set; }
            public DateTime? LastLogin { get; set; }
            public DateTime? fldDateTime { get; set; }
        }

        private sealed class PendingPasswordData
        {
            public int RequestId { get; set; }
            public int UserId { get; set; }
            public string PendingPasswordHash { get; set; }
        }

        public string ConvertToString(string[] array)
        {
            if (array == null || array.Length == 0) return string.Empty;
            return string.Join(",", array);
        }

        [HttpGet]
        [Route("GetOrphanCandidates")]
        [Route("AllUsers/GetOrphanCandidates")]
        public JsonResult GetOrphanCandidates(int months = 3)
        {
            using (var db = new GZPEGM1())
            {
                try
                {
                    var candidates = GetOrphanCandidateUsers(db, months)
                        .Select(u => new
                        {
                            u.fldId,
                            u.fldSicil,
                            u.fldName,
                            u.fldLastName
                        })
                        .ToList();

                    return Json(new { total = candidates.Count, users = candidates }, JsonRequestBehavior.AllowGet);
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Trace.TraceError($"GetOrphanCandidates Error: {ex.Message}");
                    return Json(new { total = 0, users = new List<object>(), error = ex.Message }, JsonRequestBehavior.AllowGet);
                }
            }
        }

        private List<OrphanCandidateInfo> GetOrphanCandidateUsers(GZPEGM1 db, int months)
        {
            var prelim = db.E_User
                .AsNoTracking()
                .Where(u => u.Role == null || u.Role != "Admin")
                .Select(u => new OrphanCandidateInfo
                {
                    fldId = u.fldId,
                    fldSicil = u.fldSicil,
                    fldName = u.fldName,
                    fldLastName = u.fldLastName,
                    LastLogin = u.LastLogin,
                    fldDateTime = u.fldDateTime
                })
                .ToList()
                .Where(u => IsInactiveForMonths(u.LastLogin, u.fldDateTime, months))
                .ToList();

            if (!prelim.Any())
                return prelim;

            var courseEnrolledIds = db.CourseEnrollments.Select(e => e.UserId).Distinct().ToList();
            var certificateIds = db.Certificate.Select(c => c.UserId).Distinct().ToList();
            var certificateRequestUserIds = db.CertificateRequest.Select(c => c.UserId);
            var certificateRequestProcessorIds = db.CertificateRequest
                .Where(c => c.ProcessedBy.HasValue)
                .Select(c => c.ProcessedBy.Value);
            var certificateRequestIds = certificateRequestUserIds
                .Union(certificateRequestProcessorIds)
                .Distinct()
                .ToList();
            var reviewIds = db.CourseReviews.Select(r => r.UserId).Distinct().ToList();
            var examResultIds = db.ExamResult.Where(r => r.UserId.HasValue).Select(r => r.UserId.Value).Distinct().ToList();
            var createdCourseIds = db.Courses.Select(c => c.CreatedBy).Distinct().ToList();
            var inadSicils = db.E_Inad.Where(i => i.Sicil != null).Select(i => i.Sicil).Distinct().ToList();
            var dilekceSicils = db.E_Dilekce.Where(d => d.Sicil != null).Select(d => d.Sicil).Distinct().ToList();
            var documentSicils = db.DocumentTerms.Where(d => d.Sicil != null).Select(d => d.Sicil).Distinct().ToList();
            var historyNames = db.E_History.Where(h => h.fldUser != null).Select(h => h.fldUser).Distinct().ToList();

            var candidates = prelim.Where(u =>
            {
                if (courseEnrolledIds.Contains(u.fldId)) return false;
                if (certificateIds.Contains(u.fldId)) return false;
                if (certificateRequestIds.Contains(u.fldId)) return false;
                if (reviewIds.Contains(u.fldId)) return false;
                if (examResultIds.Contains(u.fldId)) return false;
                if (createdCourseIds.Contains(u.fldId)) return false;

                var sicil = (u.fldSicil ?? string.Empty).Trim();
                if (!string.IsNullOrWhiteSpace(sicil))
                {
                    if (inadSicils.Any(x => string.Equals((x ?? string.Empty).Trim(), sicil, StringComparison.OrdinalIgnoreCase))) return false;
                    if (dilekceSicils.Any(x => string.Equals((x ?? string.Empty).Trim(), sicil, StringComparison.OrdinalIgnoreCase))) return false;
                    if (documentSicils.Any(x => string.Equals((x ?? string.Empty).Trim(), sicil, StringComparison.OrdinalIgnoreCase))) return false;
                }

                var fullName = ((u.fldName ?? "") + " " + (u.fldLastName ?? "")).Trim();
                if (historyNames.Any(h => IsSameHistoryUser(h, sicil, fullName))) return false;

                return true;
            }).ToList();

            return candidates;
        }

        // Tek bir yetim kullanıcıyı siler (AJAX için)
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Route("DeleteOrphanUser")]
        [Route("AllUsers/DeleteOrphanUser")]
        public JsonResult DeleteOrphanUser(int id, int months = 3)
        {
            using (var db = new GZPEGM1())
            {
                var user = db.E_User.Find(id);
                if (user == null)
                    return Json(new { ok = false, message = "Kullanıcı bulunamadı.", id = id }, JsonRequestBehavior.AllowGet);

                if (user.Role == "Admin")
                    return Json(new { ok = false, message = "Admin hesap silinemez.", id = id }, JsonRequestBehavior.AllowGet);

                var fullName = ((user.fldName ?? "") + " " + (user.fldLastName ?? "")).Trim();
                if (!IsInactiveForMonths(user.LastLogin, user.fldDateTime, months) || HasUserActivity(db, id, user.fldSicil, fullName))
                {
                    return Json(new { ok = false, id = id, name = fullName, message = $"Kullanıcı silinmedi. Silme için kullanıcının en az {months} aydır inaktif olması ve hiçbir işlem/eğitim kaydının bulunmaması gerekir." }, JsonRequestBehavior.AllowGet);
                }

                try
                {
                    CleanupUserReferencesBeforeDelete(db, id);
                    var tokens = db.E_Token.Where(t => t.fldUserId == id).ToList();
                    if (tokens.Any()) db.E_Token.RemoveRange(tokens);

                    db.E_User.Remove(user);
                    db.SaveChanges();

                    return Json(new { ok = true, id = id, name = fullName }, JsonRequestBehavior.AllowGet);
                }
                catch (System.Data.Entity.Infrastructure.DbUpdateConcurrencyException)
                {
                    return Json(new { ok = true, id = id, name = fullName, message = "Kullanıcı zaten silinmişti." }, JsonRequestBehavior.AllowGet);
                }
                catch (Exception ex)
                {
                    return Json(new { ok = false, message = GetInnermostExceptionMessage(ex), id = id }, JsonRequestBehavior.AllowGet);
                }
            }
        }
        //
        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult ApproveTeacher(int id)
        {
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    var user = _db.E_User.SingleOrDefault(u => u.fldId == id);
                    if (user == null)
                        return Json(new { status = "error", message = "Kullanıcı bulunamadı." });

                    user.Role = "Teacher";

                    if (string.IsNullOrEmpty(user.fldAuth))
                    {
                        user.fldAuth = "6";
                    }
                    else
                    {
                        var existingAuths = user.fldAuth.Split(',').Select(a => a.Trim()).ToList();

                        if (!existingAuths.Contains("6"))
                        {
                            existingAuths.Add("6");
                            user.fldAuth = string.Join(",", existingAuths);
                        }
                    }

                    user.TeacherRequestStatus = 1;
                    _db.SaveChanges();

                    return Json(new { status = "ok" });
                }
            }
            catch (Exception ex)
            {
                return Json(new { status = "error", message = ex.Message });
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult RejectTeacher(int id)
        {
            using (GZPEGM1 db = new GZPEGM1())
            {
                var user = db.E_User.FirstOrDefault(x => x.fldId == id);
                if (user == null)
                    return Json(new { status = "error" });

                user.TeacherRequestStatus = 2;
                user.Role = "Student";
                user.fldAuth = "3";

                db.SaveChanges();

                return Json(new { status = "ok" });
            }
        }

        [Route("Kullanıcılar")]
        public ActionResult Index()
        {
            gzpegm.Cont.User user = new User();
            Border border = new Border();
            Usermodel model = new Usermodel();

            model.user = user.GetAllUsers();
            model.tempuser = user.GetAllTempUsers();
            model.borders = border.GetAll();

            using (var db = new GZPEGM1())
            {
                model.teacherRequests = db.E_User
                    .Where(u => u.TeacherRequestStatus == 0)
                    .ToList();

                var thirtyMinutesAgo = DateTime.Now.AddMinutes(-30);
                var list = db.E_User
                    .AsNoTracking()
                    .Where(u => u.LastLogin.HasValue && u.LastLogin.Value >= thirtyMinutesAgo)
                    .Select(u => new UserViewModel
                    {
                        fldId = u.fldId,
                        fldName = u.fldName,
                        fldLastName = u.fldLastName,
                        fldSicil = u.fldSicil,
                        fldEmail = u.fldEmail,
                        fldPhone = u.fldPhone,
                        LastLogin = u.LastLogin,
                        LastIP = db.E_Token
                                    .Where(t => t.fldUserId == u.fldId)
                                    .OrderByDescending(t => t.fldDateTime)
                                    .Select(t => t.fldIp)
                                    .FirstOrDefault(),
                        RegisterDate = u.fldDateTime,
                        fldActive = u.fldActive,
                        fldAuth = u.fldAuth,
                        fldTitle = u.fldTitle,
                        fldDeputy = u.fldDeputy,
                        Role = u.Role
                    })
                    .ToList();

                model.onlineUsers = list
                    .GroupBy(u => u.fldId)
                    .Select(g => g.OrderByDescending(x => x.LastLogin).FirstOrDefault())
                    .ToList();



                // ✅ YENİ: Pasif/Aktif kullanıcılar (son giriş tarihleri ile)
                var inactiveUsersList = db.E_User
.AsNoTracking()
.Select(u => new UserViewModel
{
    fldId = u.fldId,
    fldSicil = u.fldSicil,
    fldName = u.fldName,
    fldLastName = u.fldLastName,
    fldEmail = u.fldEmail,
    fldPhone = u.fldPhone,
    fldAuth = u.fldAuth,
    fldActive = u.fldActive,
    LastLogin = u.LastLogin
                      ?? db.E_Token
                          .Where(t => t.fldUserId == u.fldId)
                          .OrderByDescending(t => t.fldDateTime)
                          .Select(t => (DateTime?)t.fldDateTime)
                          .FirstOrDefault(),
    RegisterDate = u.fldDateTime,
    fldTitle = u.fldTitle,
    fldDeputy = u.fldDeputy,
    Role = u.Role
})
      .ToList();

                model.inactiveUsers = inactiveUsersList;
            }

            model.onlineUsers = model.onlineUsers ?? new List<UserViewModel>();
            model.inactiveUsers = model.inactiveUsers ?? new List<UserViewModel>();

            return View(model);
        }

        [HttpGet]
        [Route("Kullanıcılar/Şifre-Sıfırlama-Talepleri")]
        public ActionResult PasswordResetRequests()
        {
            using (var db = new GZPEGM1())
            {
                var requests = db.Database.SqlQuery<gzpegm.Models.ViewModels.PasswordResetRequestViewModel>(@"
                    SELECT r.RequestId, r.UserId, u.fldSicil AS Sicil,
                           LTRIM(RTRIM(ISNULL(u.fldName, '') + ' ' + ISNULL(u.fldLastName, ''))) AS FullName,
                           u.fldEmail AS Email, r.RequestedAt, r.Status
                    FROM dbo.PasswordResetRequests r
                    INNER JOIN dbo.E_User u ON u.fldId = r.UserId
                    WHERE r.Status = 'Pending'
                    ORDER BY r.RequestedAt ASC").ToList();

                return View(requests);
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [Route("Kullanıcılar/Şifre-Sıfırlama-Talepleri/Onayla")]
        public ActionResult ApprovePasswordResetRequest(int requestId)
        {
            if (requestId <= 0)
            {
                TempData["msgError"] = "Geçersiz şifre sıfırlama talebi.";
                return RedirectToAction("PasswordResetRequests");
            }

            var adminUser = GetCurrentUser();
            if (adminUser == null)
            {
                TempData["msgError"] = "Yönetici bilgisi doğrulanamadı.";
                return RedirectToAction("PasswordResetRequests");
            }

            using (var db = new GZPEGM1())
            using (var transaction = db.Database.BeginTransaction())
            {
                try
                {
                    var request = db.Database.SqlQuery<PendingPasswordData>(
                        "SELECT RequestId, UserId, PendingPasswordHash FROM dbo.PasswordResetRequests WHERE RequestId = @requestId AND Status = 'Pending'",
                        new System.Data.SqlClient.SqlParameter("@requestId", requestId)).SingleOrDefault();

                    if (request == null)
                    {
                        TempData["msgError"] = "Talep bulunamadı veya daha önce işleme alınmış.";
                        transaction.Rollback();
                        return RedirectToAction("PasswordResetRequests");
                    }

                    var affected = db.Database.ExecuteSqlCommand(@"
                        UPDATE dbo.PasswordResetRequests
                        SET Status = 'Approved', ApprovedAt = GETDATE(), ApprovedByUserId = @adminUserId
                        WHERE RequestId = @requestId AND Status = 'Pending'",
                        new System.Data.SqlClient.SqlParameter("@adminUserId", adminUser.fldId),
                        new System.Data.SqlClient.SqlParameter("@requestId", requestId));

                    if (affected != 1)
                    {
                        TempData["msgError"] = "Talep işlenemedi; listeyi yenileyip tekrar deneyin.";
                        transaction.Rollback();
                        return RedirectToAction("PasswordResetRequests");
                    }

                    var user = db.E_User.SingleOrDefault(x => x.fldId == request.UserId);
                    if (user == null)
                    {
                        TempData["msgError"] = "Talep sahibinin kullanıcı kaydı bulunamadı.";
                        transaction.Rollback();
                        return RedirectToAction("PasswordResetRequests");
                    }

                    user.fldPassword = request.PendingPasswordHash;
                    db.E_Messages.Add(new E_Messages
                    {
                        fldSenderId = adminUser.fldId,
                        fldSendByName = ((adminUser.fldName ?? "") + " " + (adminUser.fldLastName ?? "")).Trim(),
                        fldSendBySicil = adminUser.fldSicil,
                        fldSenderRole = adminUser.Role,
                        fldRecipientId = user.fldId,
                        fldRecipientRole = user.Role,
                        fldSubject = "Şifre sıfırlama talebiniz onaylandı",
                        fldMessage = "Şifre sıfırlama talebiniz yönetici tarafından onaylandı. Talep sırasında ekranda gösterilen yeni şifrenizle sisteme giriş yapabilirsiniz.",
                        fldDateTime = DateTime.Now,
                        fldIsRead = false,
                        fldIsDeletedBySender = false,
                        fldIsDeletedByRecipient = false,
                        fldIsReply = false,
                        fldIsApproved = true
                    });
                    db.SaveChanges();
                    transaction.Commit();

                    TempData["msgSuccess"] = "Talep onaylandı. Yeni şifre etkinleştirildi ve personele sistem içi bildirim gönderildi.";
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    System.Diagnostics.Trace.TraceError("Password reset approval error: " + ex);
                    TempData["msgError"] = "Şifre sıfırlama talebi onaylanamadı.";
                }
            }

            return RedirectToAction("PasswordResetRequests");
        }

        private E_User GetCurrentUser()
        {
            var cookie = Request.Cookies["Token"];
            if (cookie == null) return null;

            var tokenData = new Token().GetToken(cookie.Value);
            if (tokenData == null || !int.TryParse(tokenData.fldUserId?.ToString(), out int userId))
                return null;

            return new User().GetUserById(userId);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [Route("Adduser")]
        public ActionResult Index(string NameUser, string LastNameUser, string TitleUser, string DeputyUser,
                         string PhoneUser, string EmailUser, string SicilUser, string[] PermiUser,
                         string BorderUser, string UserRole)
        {
            gzpegm.Cont.User user = new User();
            Border border = new Border();
            Usermodel model = new Usermodel();


            var check = user.Check(0, SicilUser);
            if (check != null)
            {
                ViewBag.GeneralWarningMessage = "Bu sicil numarası daha önce kaydedilmiş..!";
                ViewBag.GeneralDynamicScripts = "$('#general-warning').click();";
                model.user = user.GetAllUsers();
                model.tempuser = user.GetAllTempUsers();
                model.borders = border.GetAll();
                return View(model);
            }
            else
            {
                // Rastgele parola üreten kod kaldırıldı; sabit başlangıç şifresi kullanılıyor.
                string fldAuthValue = ConvertToString(PermiUser);
                if (!string.IsNullOrEmpty(UserRole))
                {
                    switch (UserRole.ToLower())
                    {
                        case "admin":
                            fldAuthValue = string.IsNullOrWhiteSpace(fldAuthValue) ? "1,2,3,4,5,6" : (fldAuthValue.Contains("2") ? fldAuthValue : fldAuthValue + ",2");
                            break;
                        case "teacher":
                            fldAuthValue = string.IsNullOrWhiteSpace(fldAuthValue) ? "6" : (fldAuthValue.Contains("6") ? fldAuthValue : fldAuthValue + ",6");
                            break;
                        case "student":
                            fldAuthValue = string.IsNullOrWhiteSpace(fldAuthValue) ? "3" : (fldAuthValue.Contains("3") ? fldAuthValue : fldAuthValue + ",3");
                            break;
                    }
                }
                string pass = CryptoHelper.Crypto.HashPassword("123459");
                user.AddUser(SicilUser, NameUser, LastNameUser, PhoneUser, EmailUser,
                TitleUser, DeputyUser, "", fldAuthValue, "0", pass, BorderUser, UserRole);
                ViewBag.GeneralSuccessMessage = "Kullanıcı başarılı bir şekilde kaydedilmiştir..!";
                ViewBag.GeneralDynamicScripts = "$('#general-success').click();";
                model.user = user.GetAllUsers();
                model.tempuser = user.GetAllTempUsers();
                model.borders = border.GetAll();
                return View(model);
            }

        }
        [Route("Edituser")]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Index(int EditUserId, string editNameUser, string editLastNameUser, string editTitleUser,
        string editDeputyUser, string editPhoneUser, string editEmailUser, string editSicilUser,
        string[] editPermiUser, string editBorderUser, string editUserRole)
        {
            gzpegm.Cont.User user = new User();
            Usermodel model = new Usermodel();
            Border border = new Border();

            var check = user.Check(EditUserId, editSicilUser);
            if (check != null)
            {
                ViewBag.GeneralWarningMessage = "Bu sicil numarası daha önce kaydedilmiş..!";
                ViewBag.GeneralDynamicScripts = "$('#general-warning').click();";
            }
            else
            {
                // ✅ Multiselect değerini direkt al
                string fldAuthValue = editPermiUser != null
                    ? string.Join(",", editPermiUser)
                    : "";

                user.EditUser(EditUserId, editSicilUser, editNameUser, editLastNameUser, editPhoneUser,
                editEmailUser, editTitleUser, editDeputyUser, "",
                fldAuthValue, "0", editBorderUser, editUserRole);

                ViewBag.GeneralSuccessMessage = "Kullanıcı başarılı bir şekilde güncellenmiştir..!";
                ViewBag.GeneralDynamicScripts = "$('#general-success').click();";
            }

            model.user = user.GetAllUsers();
            model.tempuser = user.GetAllTempUsers();
            model.borders = border.GetAll();

            var fiveMinutesAgo = DateTime.Now.AddMinutes(-5);
            using (var db = new GZPEGM1())
            {
                var list = db.E_User
      .AsNoTracking()
      .Where(u => u.LastLogin.HasValue && u.LastLogin.Value >= fiveMinutesAgo)
      .Select(u => new UserViewModel
      {
          fldId = u.fldId,
          fldName = u.fldName,
          fldLastName = u.fldLastName,
          fldSicil = u.fldSicil,
          fldEmail = u.fldEmail,
          fldPhone = u.fldPhone,
          LastLogin = u.LastLogin,
          LastIP = db.E_Token
                      .Where(t => t.fldUserId == u.fldId)
                      .OrderByDescending(t => t.fldDateTime)
                      .Select(t => t.fldIp)
                      .FirstOrDefault(),
          RegisterDate = u.fldDateTime,
          fldActive = u.fldActive,
          fldAuth = u.fldAuth,
          fldTitle = u.fldTitle,
          fldDeputy = u.fldDeputy,
          Role = u.Role
      })
      .ToList();

                model.onlineUsers = list
                    .GroupBy(u => u.fldId)
                    .Select(g => g.OrderByDescending(x => x.LastLogin).FirstOrDefault())
                    .ToList();
            }

            model.onlineUsers = model.onlineUsers ?? new List<UserViewModel>();
            return View(model);
        }

        [Route("Getuser")]
        public JsonResult GetUser(int fldId)
        {
            gzpegm.Cont.User user = new User();
            var UData = user.GetUserById(fldId);
            if (UData == null)
                return Json(new { success = false, message = "Kullanıcı bulunamadı." }, JsonRequestBehavior.AllowGet);

            return Json(new { success = true, ID = fldId, Name = UData.fldName, LastName = UData.fldLastName, Title = UData.fldTitle, Deputy = UData.fldDeputy, Phone = UData.fldPhone, Email = UData.fldEmail, Sicil = UData.fldSicil, Permi = UData.fldAuth, Border = UData.fldBorder, Role = UData.Role }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [Route("resetpass")]
        public JsonResult resetpass(int fldId)
        {
            try
            {
                gzpegm.Cont.User user = new User();
                string pass = CryptoHelper.Crypto.HashPassword("123459");
                user.ChangePass(fldId, pass);
                return Json(new { ok = true, M = "Şifreniz başarılı bir şekilde sıfırlanmıştır." }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { ok = false, M = "Şifre sıfırlanamadı: " + ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [Route("submituser")]
        public JsonResult submituser(int Id)
        {
            gzpegm.Cont.User user = new User();
            var tempuser = user.GetTempUserById(Id);
            if (tempuser == null)
                return Json(new { Message = "Bilinmeyen bir hata oluştu...(code : 1995)", Url = "/Kullanıcılar" }, JsonRequestBehavior.AllowGet);

            string pass = CryptoHelper.Crypto.HashPassword("123459");

            user.AddUser(tempuser.fldSicil, tempuser.fldName, tempuser.fldLastName,
                        tempuser.fldPhone, tempuser.fldEmail, tempuser.fldTitle,
                        tempuser.fldDeputy, "", "3", "0", pass, tempuser.fldDeputy, "Student");

            user.DeleteTempUser(Id);
            return Json(new { Message = "Kullanıcıya başarılı bir şekilde onay verilmiştir...", Url = "/Kullanıcılar" }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [Route("deletetempuser")]
        public JsonResult deletetempuser(int Id)
        {
            gzpegm.Cont.User user = new User();
            user.DeleteTempUser(Id);
            return Json(new { Message = "Geçici kullanıcı başarılı bir şekilde silinmiştir...", Url = "/Kullanıcılar" }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [Route("deleteuser")]
        public JsonResult deleteuser(int Id)
        {
            using (var db = new GZPEGM1())
            {
                var user = db.E_User.Find(Id);
                if (user == null)
                    return Json(new { ok = false, Message = "Kullanıcı bulunamadı." }, JsonRequestBehavior.AllowGet);

                if (string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase))
                    return Json(new { ok = false, Message = "Admin kullanıcı silinemez." }, JsonRequestBehavior.AllowGet);

                var fullName = ((user.fldName ?? "") + " " + (user.fldLastName ?? "")).Trim();
                if (!IsInactiveForMonths(user.LastLogin, user.fldDateTime, 3) || HasUserActivity(db, Id, user.fldSicil, fullName))
                {
                    return Json(new { ok = false, Message = "Kullanıcı silinmedi. Silme için kullanıcının en az 3 aydır inaktif olması ve hiçbir işlem/eğitim kaydının bulunmaması gerekir." }, JsonRequestBehavior.AllowGet);
                }

                try
                {
                    CleanupUserReferencesBeforeDelete(db, Id);
                    var tokens = db.E_Token.Where(t => t.fldUserId == Id).ToList();
                    if (tokens.Any()) db.E_Token.RemoveRange(tokens);

                    db.E_User.Remove(user);
                    db.SaveChanges();
                    return Json(new { ok = true, Message = "Kullanıcı başarılı bir şekilde silinmiştir...", Url = "/Kullanıcılar" }, JsonRequestBehavior.AllowGet);
                }
                catch (Exception ex)
                {
                    return Json(new { ok = false, Message = "Kullanıcı silinemedi: " + GetInnermostExceptionMessage(ex) }, JsonRequestBehavior.AllowGet);
                }
            }
        }

        // ✅ YENİ: Kullanıcıyı pasife al (InactiveUser'dan taşıdık)
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Route("SetInactive")]
        public ActionResult SetInactive(int id)
        {
            using (var db = new GZPEGM1())
            {
                var user = db.E_User.Find(id);
                if (user == null)
                {
                    TempData["Error"] = "Kullanıcı bulunamadı.";
                    return RedirectToAction("Index");
                }

                if (string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase))
                {
                    TempData["Error"] = "Admin kullanıcı pasife alınamaz.";
                    return RedirectToAction("Index");
                }

                try
                {
                    SetUserInactive(user);
                    db.SaveChanges();
                    TempData["Success"] = "Kullanıcı başarıyla pasife alındı.";
                }
                catch (Exception ex)
                {
                    TempData["Error"] = "İşlem başarısız: " + ex.Message;
                }
            }

            return RedirectToAction("Index");
        }

        // ✅ YENİ: Kullanıcıyı aktifleştir (InactiveUser'dan taşıdık)
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Route("SetActive")]
        public ActionResult SetActive(int id)
        {
            using (var db = new GZPEGM1())
            {
                var user = db.E_User.Find(id);
                if (user == null)
                {
                    TempData["Error"] = "Kullanıcı bulunamadı.";
                    return RedirectToAction("Index");
                }

                try
                {
                    user.IsActive = true;
                    user.fldActive = "1";
                    db.SaveChanges();
                    TempData["Success"] = "Kullanıcı başarıyla aktifleştirildi.";
                }
                catch (Exception ex)
                {
                    TempData["Error"] = "İşlem başarısız: " + ex.Message;
                }
            }

            return RedirectToAction("Index");
        }

        // ✅ YENİ: Tüm kullanıcıları aynı anda aktifleştir (Adminler hariç)
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Route("SetAllActive")]
        public ActionResult SetAllActive()
        {
            try
            {
                using (var db = new GZPEGM1())
                {
                    // Tek seferde, performanslı güncelleme (Admin hesaplarını güncelleme)
                    string sql = @"
UPDATE E_User
SET IsActive = 1, fldActive = '1'
WHERE ISNULL(Role, '') <> 'Admin' AND (ISNULL(IsActive, 0) = 0 OR ISNULL(fldActive, '0') = '0')
";
                    int affected = db.Database.ExecuteSqlCommand(sql);
                    if (Request.IsAjaxRequest())
                    {
                        return Json(new { success = true, affected = affected, message = $"{affected} kullanıcı başarıyla aktifleştirildi." });
                    }
                    TempData["Success"] = $"{affected} kullanıcı başarıyla aktifleştirildi.";
                }
            }
            catch (Exception ex)
            {
                if (Request.IsAjaxRequest())
                {
                    return Json(new { success = false, message = "İşlem başarısız: " + ex.Message });
                }
                TempData["Error"] = "İşlem başarısız: " + ex.Message;
            }

            return RedirectToAction("Index");
        }

        // ✅ YENİ: Kullanıcı geçmişini göster (InactiveUser'dan taşıdık)
        [Route("UserHistory")]
        public ActionResult UserHistory(int userId)
        {
            using (var db = new GZPEGM1())
            {
                var user = db.E_User.Find(userId);
                if (user == null)
                    return HttpNotFound();

                string fullName = user.fldName.Trim() + " " + user.fldLastName.Trim();

                var history = db.E_History
                                .Where(h => h.fldUser == fullName)
                                .OrderByDescending(h => h.fldDatetime)
                                .ToList();

                ViewBag.UserName = fullName;
                return View(history);
            }
        }

        // ✅ YENİ: PDF export (InactiveUser'dan taşıdık)
        [Route("ExportHistoryPDF")]
        public ActionResult ExportHistoryPDF(int userId)
        {
            using (var db = new GZPEGM1())
            {
                var user = db.E_User.Find(userId);
                if (user == null)
                    return HttpNotFound();

                string fullName = user.fldName.Trim() + " " + user.fldLastName.Trim();
                var history = db.E_History
                                .Where(h => h.fldUser == fullName)
                                .OrderByDescending(h => h.fldDatetime)
                                .ToList();

                using (MemoryStream ms = new MemoryStream())
                {
                    iTextSharp.text.Document doc = new iTextSharp.text.Document(iTextSharp.text.PageSize.A4, 10, 10, 10, 10);
                    iTextSharp.text.pdf.PdfWriter.GetInstance(doc, ms);
                    doc.Open();
                    doc.Add(new iTextSharp.text.Paragraph($"{fullName} Kullanıcısının İşlem Geçmişi"));
                    doc.Add(new iTextSharp.text.Paragraph(" "));

                    iTextSharp.text.pdf.PdfPTable table = new iTextSharp.text.pdf.PdfPTable(9);
                    table.WidthPercentage = 100;

                    string[] headers = { "#", "İşlem Tarihi", "Başlangıç", "Çıkış", "Doğum Tarihi", "Ülke", "Ceza", "Para", "Sınır" };
                    foreach (var h in headers)
                    {
                        table.AddCell(new iTextSharp.text.Phrase(h));
                    }

                    int counter = 1;
                    foreach (var h in history)
                    {
                        table.AddCell(counter.ToString());
                        table.AddCell(h.fldDatetime?.ToString("dd.MM.yyyy HH:mm") ?? "");
                        table.AddCell(h.fldStart?.ToString("dd.MM.yyyy HH:mm") ?? "");
                        table.AddCell(h.fldShouldExit?.ToString("dd.MM.yyyy HH:mm") ?? "");
                        table.AddCell(h.fldBirthDate?.ToString("dd.MM.yyyy") ?? "");
                        table.AddCell(h.fldCountry ?? "");
                        table.AddCell(h.fldPenalty ?? "");
                        table.AddCell(h.fldPMoney ?? "");
                        table.AddCell(h.fldBorder ?? "");
                        counter++;
                    }

                    doc.Add(table);
                    doc.Close();

                    return File(ms.ToArray(), "application/pdf", $"{fullName}_History.pdf");
                }
            }
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Route("SetAllActiveProgress")]
        public JsonResult SetAllActiveProgress()
        {
            using (var db = new GZPEGM1())
            {
                var users = db.E_User
                    .Where(x => (x.Role == null || x.Role != "Admin") && (x.IsActive == false || x.fldActive == "0"))
                    .ToList();

                int total = users.Count;
                int processed = 0;

                foreach (var user in users)
                {
                    user.IsActive = true;
                    user.fldActive = "1";
                    processed++;
                }

                db.SaveChanges();

                return Json(new { total = total, processed = processed });
            }
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Route("BulkActivateAll")]
        [Route("AllUsers/BulkActivateAll")]
        public JsonResult BulkActivateAll()
        {
            try
            {
                using (var db = new GZPEGM1())
                {
                    string sql = @"
UPDATE E_User
SET IsActive = 1, fldActive = '1'
WHERE ISNULL(Role, '') <> 'Admin'
  AND (ISNULL(IsActive, 0) = 0 OR ISNULL(fldActive, '0') = '0')
";
                    int affected = db.Database.ExecuteSqlCommand(sql);
                    return Json(new { success = true, affected = affected, message = $"{affected} kullanıcı başarıyla aktifleştirildi." });
                }
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = "Aktifleştirme sırasında hata oluştu: " + ex.Message });
            }
        }

        [HttpGet]
        [Route("GetInactivityCandidateCount")]
        [Route("AllUsers/GetInactivityCandidateCount")]
        public JsonResult GetInactivityCandidateCount(int months = 3)
        {
            try
            {
                using (var db = new GZPEGM1())
                {
                    var threshold = DateTime.Now.AddMonths(-months);
                    string countSql = @"
SELECT COUNT(*)
FROM E_User
WHERE ISNULL(Role, '') <> 'Admin'
  AND ( (LastLogin IS NOT NULL AND LastLogin < @threshold)
        OR (LastLogin IS NULL AND fldDateTime IS NOT NULL AND fldDateTime < @threshold) )
  AND (ISNULL(IsActive, 0) = 1 OR ISNULL(fldActive, '0') = '1')";

                    var param = new System.Data.SqlClient.SqlParameter("@threshold", threshold);
                    int candidateCount = db.Database.SqlQuery<int>(countSql, param).FirstOrDefault();

                    int totalPassive = db.Database.SqlQuery<int>(@"
SELECT COUNT(*)
FROM E_User
WHERE ISNULL(Role, '') <> 'Admin'
  AND (ISNULL(IsActive, 0) = 0 OR ISNULL(fldActive, '0') = '0')").FirstOrDefault();

                    int totalActive = db.Database.SqlQuery<int>(@"
SELECT COUNT(*)
FROM E_User
WHERE ISNULL(Role, '') <> 'Admin'
  AND (ISNULL(IsActive, 0) = 1 OR ISNULL(fldActive, '0') = '1')").FirstOrDefault();

                    return Json(new { success = true, count = candidateCount, totalPassive = totalPassive, totalActive = totalActive, months = months }, JsonRequestBehavior.AllowGet);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"GetInactivityCandidateCount Error: {ex.Message}");
                return Json(new { success = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [Route("SetInactiveByInactivity")]
        [Route("AllUsers/SetInactiveByInactivity")]
        public ActionResult SetInactiveByInactivity(int months = 3)
        {
            // Controller'da zaten [UserAuthorize(Users = "2")] varsa sadece yetkili çalıştırır.
            DateTime threshold = DateTime.Now.AddMonths(-months);

            try
            {
                using (var db = new GZPEGM1())
                {
                    // Parametreli, tek seferde güncelleme (admin hariç, zaten aktif olanlar)
                    string sql = @"
UPDATE E_User
SET IsActive = 0, fldActive = '0'
WHERE ISNULL(Role, '') <> 'Admin'
  AND ( (LastLogin IS NOT NULL AND LastLogin < @threshold)
        OR (LastLogin IS NULL AND fldDateTime IS NOT NULL AND fldDateTime < @threshold) )
  AND (ISNULL(IsActive, 0) = 1 OR ISNULL(fldActive, '0') = '1')
";
                    var param = new System.Data.SqlClient.SqlParameter("@threshold", threshold);
                    int affected = db.Database.ExecuteSqlCommand(sql, param);

                    if (Request.IsAjaxRequest() || Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                    {
                        return Json(new { success = true, affected = affected, message = $"{affected} kullanıcı {months} ay ve üzeri inaktif olduğu için pasife alındı." });
                    }
                    TempData["Success"] = $"{affected} kullanıcı {months} ay ve üzeri inaktif olduğu için pasife alındı.";
                }
            }
            catch (Exception ex)
            {
                if (Request.IsAjaxRequest() || Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                {
                    return Json(new { success = false, message = "İşlem sırasında hata oluştu: " + ex.Message });
                }
                TempData["Error"] = "İşlem sırasında hata oluştu: " + ex.Message;
            }

            return RedirectToAction("Index");
        }

        // GET: pasif kullanıcıları getir (id ve isim)
        [HttpGet]
        public JsonResult GetPassiveUsers()
        {
            using (var db = new GZPEGM1())
            {
                var users = db.E_User
     .Where(x => (x.Role == null || x.Role != "Admin") && (x.IsActive != true || x.fldActive == "0"))
     .Select(u => new { u.fldId, Name = (u.fldName ?? "") + " " + (u.fldLastName ?? "") })
     .ToList();

                return Json(new { total = users.Count, users = users }, JsonRequestBehavior.AllowGet);
            }
        }
        // Yetim kullanıcı kontrol işlemlerini detaylı şekilde gerçekleştir
        [HttpGet]
        [Route("CheckOrphanCandidatesDetailed")]
        [Route("AllUsers/CheckOrphanCandidatesDetailed")]
        public JsonResult CheckOrphanCandidatesDetailed(int months = 3)
        {
            var checks = new List<string>();

            using (var db = new GZPEGM1())
            {
                try
                {
                    checks.Add("✓ Yönetici olmayan kullanıcılar filtreleniyor...");

                    var prelim = db.E_User
                        .AsNoTracking()
                        .Where(u => u.Role == null || u.Role != "Admin")
                        .Select(u => new { u.fldId, u.fldSicil, u.fldName, u.fldLastName, u.LastLogin, u.fldDateTime })
                        .ToList();
                    prelim = prelim.Where(u => IsInactiveForMonths(u.LastLogin, u.fldDateTime, months)).ToList();

                    checks.Add($"✓ {months} ay inaktif kullanıcı bulundu: {prelim.Count}");
                    checks.Add("✓ Kurs kayıtları kontrol ediliyor...");

                    var courseEnrolledIds = db.CourseEnrollments.Select(e => e.UserId).Distinct().ToList();
                    var withoutCourse = prelim.Where(u => !courseEnrolledIds.Contains(u.fldId)).ToList();
                    checks.Add($"✓ Kurs kaydı olmayan: {withoutCourse.Count}");

                    checks.Add("✓ Sertifika kayıtları kontrol ediliyor...");
                    var certificateIds = db.Certificate.Select(c => c.UserId).Distinct().ToList();
                    var withoutCertificate = withoutCourse.Where(u => !certificateIds.Contains(u.fldId)).ToList();
                    checks.Add($"✓ Sertifika kaydı olmayan: {withoutCertificate.Count}");

                    checks.Add("✓ Sertifika talepleri kontrol ediliyor...");
                    var certificateRequestUserIds = db.CertificateRequest.Select(c => c.UserId);
                    var certificateRequestProcessorIds = db.CertificateRequest.Where(c => c.ProcessedBy.HasValue).Select(c => c.ProcessedBy.Value);
                    var certificateRequestIds = certificateRequestUserIds.Union(certificateRequestProcessorIds).Distinct().ToList();
                    var withoutCertificateRequest = withoutCertificate.Where(u => !certificateRequestIds.Contains(u.fldId)).ToList();
                    checks.Add($"✓ Sertifika talebi olmayan: {withoutCertificateRequest.Count}");

                    checks.Add("✓ Kurs yorumları kontrol ediliyor...");
                    var reviewIds = db.CourseReviews.Select(r => r.UserId).Distinct().ToList();
                    var withoutReview = withoutCertificateRequest.Where(u => !reviewIds.Contains(u.fldId)).ToList();
                    checks.Add($"✓ Kurs yorumu olmayan: {withoutReview.Count}");

                    checks.Add("✓ Sınav sonuçları kontrol ediliyor...");
                    var examResultIds = db.ExamResult.Where(r => r.UserId.HasValue).Select(r => r.UserId.Value).Distinct().ToList();
                    var withoutExamResult = withoutReview.Where(u => !examResultIds.Contains(u.fldId)).ToList();
                    checks.Add($"✓ Sınav kaydı olmayan: {withoutExamResult.Count}");

                    checks.Add("✓ Oluşturulan kurslar kontrol ediliyor...");
                    var createdCourseIds = db.Courses.Select(c => c.CreatedBy).Distinct().ToList();
                    var withoutCreatedCourse = withoutExamResult.Where(u => !createdCourseIds.Contains(u.fldId)).ToList();
                    checks.Add($"✓ Oluşturulan kurs olmayan: {withoutCreatedCourse.Count}");

                    checks.Add("✓ İNAD kayıtları kontrol ediliyor...");
                    var inadSicils = db.E_Inad.Select(i => i.Sicil).Distinct().ToList();
                    var withoutInad = withoutCreatedCourse.Where(u => !inadSicils.Contains(u.fldSicil)).ToList();
                    checks.Add($"✓ İNAD kaydı olmayan: {withoutInad.Count}");

                    checks.Add("✓ Dilekçe ve doküman kayıtları kontrol ediliyor...");
                    var dilekceSicils = db.E_Dilekce.Select(d => d.Sicil).Distinct().ToList();
                    var documentSicils = db.DocumentTerms.Select(d => d.Sicil).Distinct().ToList();
                    var withoutDocuments = withoutInad
                        .Where(u => !dilekceSicils.Contains(u.fldSicil) && !documentSicils.Contains(u.fldSicil))
                        .ToList();
                    checks.Add($"✓ Dilekçe/doküman kaydı olmayan: {withoutDocuments.Count}");

                    checks.Add("✓ İşlem geçmişi kontrol ediliyor...");
                    var historyNames = db.E_History.Select(h => h.fldUser).Distinct().ToList();
                    var candidates = withoutDocuments.Where(u =>
                    {
                        string fullName = ((u.fldName ?? "") + " " + (u.fldLastName ?? "")).Trim();
                        string sicil = (u.fldSicil ?? "").Trim();
                        return !historyNames.Any(h => IsSameHistoryUser(h, sicil, fullName));
                    }).ToList();
                    checks.Add($"✓ İşlem geçmişi olmayan: {candidates.Count}");

                    checks.Add($"✅ SONUÇ: {candidates.Count} silinebilir yetim kullanıcı bulundu!");

                    var candidateList = candidates.Select(u => new
                    {
                        u.fldId,
                        u.fldSicil,
                        u.fldName,
                        u.fldLastName,
                        FullName = string.Format("{0} {1}", u.fldName ?? "", u.fldLastName ?? "").Trim(),
                        LastLogin = u.LastLogin.HasValue ? u.LastLogin.Value.ToString("dd.MM.yyyy HH:mm") : "Hiç giriş yapmamış",
                        RegisterDate = u.fldDateTime.HasValue ? u.fldDateTime.Value.ToString("dd.MM.yyyy") : "-"
                    }).ToList();

                    return Json(new { total = candidates.Count, users = candidateList, checks = checks }, JsonRequestBehavior.AllowGet);
                }
                catch (Exception ex)
                {
                    checks.Add($"❌ HATA: {ex.Message}");
                    System.Diagnostics.Trace.TraceError($"CheckOrphanCandidatesDetailed Error: {ex.Message}");
                    return Json(new { total = 0, users = new List<object>(), checks = checks, error = ex.Message }, JsonRequestBehavior.AllowGet);
                }
            }
        }
        // POST: tek bir kullanıcıyı aktifleştir
        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult ActivateUser(int id)
        {
            using (var db = new GZPEGM1())
            {
                var user = db.E_User.Find(id);
                if (user == null)
                    return Json(new { ok = false, message = "Kullanıcı bulunamadı", id = id });

                try
                {
                    user.IsActive = true;
                    user.fldActive = "1";
                    db.SaveChanges();

                    return Json(new { ok = true, id = id, name = (user.fldName ?? "") + " " + (user.fldLastName ?? "") });
                }
                catch (Exception ex)
                {
                    return Json(new { ok = false, message = ex.Message, id = id });
                }
            }
        }
        private bool HasUserActivity(GZPEGM1 db, int fldId, string sicil, string fullName)
        {
            try
            {
                // Kurs ve sınav ilişkileri
                if (db.CourseEnrollments.Any(e => e.UserId == fldId))
                    return true;

                if (db.Certificate.Any(c => c.UserId == fldId))
                    return true;

                if (db.CertificateRequest.Any(c => c.UserId == fldId || c.ProcessedBy == fldId))
                    return true;

                if (db.CourseReviews.Any(r => r.UserId == fldId))
                    return true;

                if (db.ExamResult.Any(r => r.UserId == fldId))
                    return true;

                if (db.Courses.Any(c => c.CreatedBy == fldId))
                    return true;

                // E_Inad: sicil ile eşleştir - null ve whitespace kontrolü
                if (!string.IsNullOrWhiteSpace(sicil))
                {
                    var normalizedSicil = sicil.Trim();
                    if (db.E_Inad.Any(i => i.Sicil != null && i.Sicil.Trim() == normalizedSicil))
                        return true;

                    if (db.E_Dilekce.Any(d => d.Sicil != null && d.Sicil.Trim() == normalizedSicil))
                        return true;

                    if (db.DocumentTerms.Any(d => d.Sicil != null && d.Sicil.Trim() == normalizedSicil))
                        return true;
                }

                var historySicil = (sicil ?? "").Trim();
                var historyName = (fullName ?? "").Trim();
                if (!string.IsNullOrWhiteSpace(historySicil) &&
                    db.E_History.Any(h => h.fldUser != null &&
                        (h.fldUser.Trim() == historySicil || h.fldUser.Trim().StartsWith(historySicil + "|"))))
                    return true;

                if (!string.IsNullOrWhiteSpace(historyName) &&
                    db.E_History.Any(h => h.fldUser != null && h.fldUser.Trim() == historyName))
                    return true;

                return false;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"HasUserActivity Error: {ex.Message}");
                // Hata durumunda güvenli tarafta kal: ilişki var sayılacak
                return true;
            }
        }

        private static bool IsInactiveForMonths(DateTime? lastLogin, DateTime? registerDate, int months)
        {
            var threshold = DateTime.Now.AddMonths(-months);
            if (lastLogin.HasValue) return lastLogin.Value < threshold;
            return registerDate.HasValue && registerDate.Value < threshold;
        }

        private static void CleanupUserReferencesBeforeDelete(GZPEGM1 db, int userId)
        {
            var approvedReviews = db.CourseReviews.Where(r => r.ApprovedBy == userId).ToList();
            foreach (var review in approvedReviews)
            {
                review.ApprovedBy = null;
            }

            var processedRequests = db.CertificateRequest.Where(r => r.ProcessedBy == userId).ToList();
            foreach (var request in processedRequests)
            {
                request.ProcessedBy = null;
            }

            var approvedMessages = db.E_Messages.Where(m => m.fldApprovedBy == userId).ToList();
            foreach (var message in approvedMessages)
            {
                message.fldApprovedBy = null;
            }

            var senderMessages = db.E_Messages.Where(m => m.fldSenderId == userId).ToList();
            foreach (var message in senderMessages)
            {
                message.fldSenderId = null;
            }

            var recipientMessages = db.E_Messages.Where(m => m.fldRecipientId == userId).ToList();
            foreach (var message in recipientMessages)
            {
                message.fldRecipientId = null;
            }

            CleanupMeetingReferencesBeforeDelete(db, userId);
        }

        private static void CleanupMeetingReferencesBeforeDelete(GZPEGM1 db, int userId)
        {
            const string sql = @"
IF OBJECT_ID(N'dbo.Meetings', N'U') IS NOT NULL
BEGIN
    CREATE TABLE #UserMeetingIds (MeetingId INT PRIMARY KEY);

    IF COL_LENGTH(N'dbo.Meetings', N'UserId') IS NOT NULL
    BEGIN
        INSERT INTO #UserMeetingIds (MeetingId)
        SELECT Id
        FROM dbo.Meetings
        WHERE UserId = @userId;
    END

    IF COL_LENGTH(N'dbo.Meetings', N'CreatedBy') IS NOT NULL
    BEGIN
        INSERT INTO #UserMeetingIds (MeetingId)
        SELECT Id
        FROM dbo.Meetings
        WHERE CreatedBy = @userId
          AND Id NOT IN (SELECT MeetingId FROM #UserMeetingIds);
    END

    IF OBJECT_ID(N'dbo.MeetingAnswers', N'U') IS NOT NULL
    BEGIN
        IF COL_LENGTH(N'dbo.MeetingAnswers', N'UserId') IS NOT NULL
            DELETE FROM dbo.MeetingAnswers WHERE UserId = @userId;

        IF COL_LENGTH(N'dbo.MeetingAnswers', N'MeetingQuestionId') IS NOT NULL
           AND OBJECT_ID(N'dbo.MeetingQuestions', N'U') IS NOT NULL
           AND COL_LENGTH(N'dbo.MeetingQuestions', N'Id') IS NOT NULL
           AND COL_LENGTH(N'dbo.MeetingQuestions', N'MeetingId') IS NOT NULL
            DELETE ma
            FROM dbo.MeetingAnswers ma
            INNER JOIN dbo.MeetingQuestions mq ON mq.Id = ma.MeetingQuestionId
            INNER JOIN #UserMeetingIds umi ON umi.MeetingId = mq.MeetingId;
    END

    IF OBJECT_ID(N'dbo.MeetingFiles', N'U') IS NOT NULL
    BEGIN
        IF COL_LENGTH(N'dbo.MeetingFiles', N'UserId') IS NOT NULL
            DELETE FROM dbo.MeetingFiles WHERE UserId = @userId;

        IF COL_LENGTH(N'dbo.MeetingFiles', N'MeetingId') IS NOT NULL
            DELETE mf
            FROM dbo.MeetingFiles mf
            INNER JOIN #UserMeetingIds umi ON umi.MeetingId = mf.MeetingId;
    END

    IF OBJECT_ID(N'dbo.MeetingMessages', N'U') IS NOT NULL
    BEGIN
        IF COL_LENGTH(N'dbo.MeetingMessages', N'UserId') IS NOT NULL
            DELETE FROM dbo.MeetingMessages WHERE UserId = @userId;

        IF COL_LENGTH(N'dbo.MeetingMessages', N'MeetingId') IS NOT NULL
            DELETE mm
            FROM dbo.MeetingMessages mm
            INNER JOIN #UserMeetingIds umi ON umi.MeetingId = mm.MeetingId;
    END

    IF OBJECT_ID(N'dbo.MeetingParticipants', N'U') IS NOT NULL
    BEGIN
        IF COL_LENGTH(N'dbo.MeetingParticipants', N'UserId') IS NOT NULL
            DELETE FROM dbo.MeetingParticipants WHERE UserId = @userId;

        IF COL_LENGTH(N'dbo.MeetingParticipants', N'MeetingId') IS NOT NULL
            DELETE mp
            FROM dbo.MeetingParticipants mp
            INNER JOIN #UserMeetingIds umi ON umi.MeetingId = mp.MeetingId;
    END

    IF OBJECT_ID(N'dbo.MeetingQuestions', N'U') IS NOT NULL
    BEGIN
        IF COL_LENGTH(N'dbo.MeetingQuestions', N'MeetingId') IS NOT NULL
            DELETE mq
            FROM dbo.MeetingQuestions mq
            INNER JOIN #UserMeetingIds umi ON umi.MeetingId = mq.MeetingId;
    END

    IF EXISTS (SELECT 1 FROM #UserMeetingIds)
    BEGIN
        IF COL_LENGTH(N'dbo.Meetings', N'Id') IS NOT NULL
            DELETE m
            FROM dbo.Meetings m
            INNER JOIN #UserMeetingIds umi ON umi.MeetingId = m.Id;
    END

    DROP TABLE #UserMeetingIds;
END";

            db.Database.ExecuteSqlCommand(sql, new System.Data.SqlClient.SqlParameter("@userId", userId));
        }

        private static string GetInnermostExceptionMessage(Exception exception)
        {
            if (exception == null)
                return "Bilinmeyen hata.";

            var current = exception;
            while (current.InnerException != null)
            {
                current = current.InnerException;
            }

            return current.Message;
        }

        private static void SetUserInactive(E_User user)
        {
            user.IsActive = false;
            user.fldActive = "0";
        }

        private static bool IsSameHistoryUser(string historyUser, string sicil, string fullName)
        {
            if (string.IsNullOrWhiteSpace(historyUser)) return false;

            var value = historyUser.Trim();
            var normalizedSicil = (sicil ?? "").Trim();
            var normalizedName = (fullName ?? "").Trim();

            if (!string.IsNullOrWhiteSpace(normalizedSicil) &&
                (string.Equals(value, normalizedSicil, StringComparison.OrdinalIgnoreCase) ||
                 value.StartsWith(normalizedSicil + "|", StringComparison.OrdinalIgnoreCase)))
                return true;

            return !string.IsNullOrWhiteSpace(normalizedName) &&
                   string.Equals(value, normalizedName, StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>
        /// KarÅŸÄ± sunucu (10.7.202.75 / 10.7.202.76) ile yerel kullanÄ±cÄ± listesini karÅŸÄ±laÅŸtÄ±rÄ±r.
        /// Eksik personelleri JSON olarak dÃ¶ner.
        /// </summary>
        [HttpGet]
        [Route("AllUsers/CompareWithRemoteServer")]
        public JsonResult CompareWithRemoteServer()
        {
            try
            {
                var result = ServerFailoverHelper.CompareWithRemoteServer();
                return Json(result, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { Success = false, ErrorMessage = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        /// <summary>
        /// SeÃ§ilen veya tÃ¼m eksik personelleri karÅŸÄ± sunucudan yerel veritabanÄ±na aktarÄ±r.
        /// </summary>
        [HttpPost]
        [Route("AllUsers/SyncUsersFromRemoteServer")]
        public JsonResult SyncUsersFromRemoteServer(List<string> sicils)
        {
            try
            {
                int count = ServerFailoverHelper.SyncMissingUsersFromRemote(sicils);
                return Json(new { success = true, count = count, message = count + " personel başarıyla yerel sisteme aktarıldı." });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = "Senkronizasyon hatası: " + ex.Message });
            }
        }
    }
}





