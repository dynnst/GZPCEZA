using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity.Validation;
using System.Linq;
using System.Web;

namespace gzpegm.Cont
{
    public class User
    {
        public List<tbl_TempUser> GetAllTempUsers()
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.tbl_TempUser.Where(c => c.fldId != 0).ToList();

            }
        }
        public List<E_User> GetAllUsers()
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {

                return _db.E_User.OrderByDescending(c => c.fldDateTime).ToList();
            }
        }
        public void ChangePass(int fldId, string Pass)
        {
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    E_User edit = _db.E_User.Where(c => c.fldId == fldId).SingleOrDefault();
                    if (edit == null) throw new Exception("Kullanıcı bulunamadı.");
                    edit.fldPassword = Pass;
                    _db.SaveChanges();
                }
            }
            catch (Exception exp)
            {
                throw new Exception("Hata Güncellenemedi - " + exp.Message.ToString(), exp);
            }
        }
        public E_User GetUserBySicilPass(string Sicil)
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_User.Where(c => c.fldSicil.Trim() == Sicil.Trim()).SingleOrDefault();
            }
        }
        public E_User Check(int fldId, string Sicil)
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_User.Where(c => c.fldId != fldId && c.fldSicil.Trim() == Sicil.Trim()).SingleOrDefault();
            }
        }
        public tbl_TempUser Checktemp(int fldId, string Sicil)
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.tbl_TempUser.Where(c => c.fldId != fldId && c.fldSicil.Trim() == Sicil.Trim()).SingleOrDefault();
            }
        }
        public E_User GetUserById(int fldId)
        {
            if (fldId <= 0)
                return null;

            var cacheKey = "CurrentUser:" + fldId;
            var items = HttpContext.Current?.Items;
            if (items != null && items.Contains(cacheKey))
                return items[cacheKey] as E_User;

            using (GZPEGM1 _db = new GZPEGM1())
            {
                var user = _db.E_User.SingleOrDefault(c => c.fldId == fldId);
                if (items != null)
                    items[cacheKey] = user;

                return user;
            }
        }
        public tbl_TempUser GetTempUserById(int fldId)
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.tbl_TempUser.Where(c => c.fldId == fldId).SingleOrDefault();
            }
        }
        public void AddTempUser(string Sicil, string Name, string LastName, string Phone, string Email, string Title, string Deputy)
        {
            var Addnew = new tbl_TempUser();
            Addnew.fldSicil = Sicil;
            Addnew.fldName = Name;
            Addnew.fldLastName = LastName;
            Addnew.fldPhone = Phone;
            Addnew.fldEmail = Email;
            Addnew.fldTitle = Title;
            Addnew.fldDeputy = Deputy;
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    _db.tbl_TempUser.Add(Addnew);
                    _db.SaveChanges();
                }
            }
            catch (Exception exp)
            {
                throw new Exception("Hata Eklenemedi - " + exp.Message.ToString(), exp);
            }
        }
        public void AddUser(string Sicil, string Name, string LastName, string Phone, string Email,
                    string Title, string Deputy, string Picture, string Auth,
                    string SubAuth, string Pass, string Border, string Role = "Student") // Role parametresi eklendi
        {
            // Role'e göre fldAuth'u senkronize et
            string finalAuth = Auth;
            if (Role == "Teacher")
            {
                // Teacher ise fldAuth'a "6" ekle (eğer yoksa)
                if (string.IsNullOrEmpty(finalAuth))
                {
                    finalAuth = "6";
                }
                else
                {
                    var authList = finalAuth.Split(',').Select(a => a.Trim()).ToList();
                    if (!authList.Contains("6"))
                    {
                        authList.Add("6");
                        finalAuth = string.Join(",", authList);
                    }
                }
            }
            else if (Role == "Admin")
            {
                // Admin ise fldAuth'a "2" ekle (eğer yoksa)
                if (string.IsNullOrEmpty(finalAuth))
                {
                    finalAuth = "2";
                }
                else
                {
                    var authList = finalAuth.Split(',').Select(a => a.Trim()).ToList();
                    if (!authList.Contains("2"))
                    {
                        authList.Add("2");
                        finalAuth = string.Join(",", authList);
                    }
                }
            }

            var Addnew = new E_User
            {
                fldSicil = Sicil,
                fldName = Name,
                fldLastName = LastName,
                fldPhone = Phone,
                fldEmail = Email,
                fldTitle = Title,
                fldDeputy = Deputy,
                fldPicture = Picture,
                fldAuth = finalAuth, // Senkronize edilmiş yetki
                fldSubAuth = SubAuth,
                fldPassword = Pass,
                fldDateTime = DateTime.Now,
                fldBorder = Border,
                fldActive = "1",
                IsActive = true,
                Role = string.IsNullOrEmpty(Role) ? "Student" : Role // ✅ Dinamik Role ataması
            };

            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    _db.E_User.Add(Addnew);
                    _db.SaveChanges();
                }
            }
            catch (DbEntityValidationException ex)
            {
                var errorMessages = ex.EntityValidationErrors
                    .SelectMany(eve => eve.ValidationErrors)
                    .Select(ve => ve.ErrorMessage);
                var fullErrorMessage = string.Join("; ", errorMessages);
                throw new Exception("Kullanıcı eklenemedi: " + fullErrorMessage);
            }
        }

        public void EditUser(int fldId, string Sicil, string Name, string LastName, string Phone, string Email, string Title,
                           string Deputy, string Picture, string Auth, string SubAuth, string Border, string Role)
        {
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    var edit = _db.E_User.SingleOrDefault(c => c.fldId == fldId);
                    if (edit == null)
                        throw new Exception("Kullanıcı bulunamadı.");

                    edit.fldSicil = Sicil;
                    edit.fldName = Name;
                    edit.fldLastName = LastName;
                    edit.fldPhone = Phone;
                    edit.fldEmail = Email;
                    edit.fldTitle = Title;
                    edit.fldDeputy = Deputy;
                    edit.fldPicture = Picture;
                    edit.fldSubAuth = SubAuth;
                    edit.fldBorder = Border;

                    // Role parametresi boş olsa bile DB'deki Role'u güncelle (ayrımı yapan alan Role'dür)
                    edit.Role = string.IsNullOrWhiteSpace(Role) ? edit.Role : Role;

                    // Auth listesini Auth parametresinden al (controller tarafından belirleniyor)
                    var finalAuth = Auth ?? string.Empty;
                    var authList = finalAuth
                        .Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                        .Select(a => a.Trim())
                        .Where(a => !string.IsNullOrEmpty(a))
                        .Distinct()
                        .ToList();

                    // Role'a göre gerekli ekleme/çıkarma işlemleri
                    if (edit.Role.Equals("Teacher", StringComparison.OrdinalIgnoreCase))
                    {
                        if (!authList.Contains("6")) authList.Add("6");
                        authList.RemoveAll(a => a == "2");
                    }
                    else if (edit.Role.Equals("Admin", StringComparison.OrdinalIgnoreCase))
                    {
                        if (!authList.Contains("2")) authList.Add("2");
                        authList.RemoveAll(a => a == "6");
                    }
                    else if (edit.Role.Equals("Student", StringComparison.OrdinalIgnoreCase))
                    {
                        authList.RemoveAll(a => a == "6" || a == "2");
                        if (!authList.Contains("3")) authList.Add("3");
                    }

                    edit.fldAuth = string.Join(",", authList);

                    _db.SaveChanges();
                }
            }
            catch (DbEntityValidationException ex)
            {
                var errorMessages = ex.EntityValidationErrors
                    .SelectMany(eve => eve.ValidationErrors)
                    .Select(ve => ve.ErrorMessage);
                var fullErrorMessage = string.Join("; ", errorMessages);
                throw new Exception("Kullanıcı güncellenemedi: " + fullErrorMessage);
            }
        }


        public void DeleteTempUser(int fldId)
        {
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    tbl_TempUser edit = _db.tbl_TempUser.Where(c => c.fldId == fldId).SingleOrDefault();
                    if (edit == null) throw new Exception("Geçici kullanıcı bulunamadı.");
                    _db.tbl_TempUser.Remove(edit);
                    _db.SaveChanges();
                }


            }
            catch (Exception exp)
            {
                throw new Exception("Hata Güncellenemedi - " + exp.Message.ToString(), exp);
            }
        }
        public void DeleteUser(int fldId)
        {
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    E_User edit = _db.E_User.Where(c => c.fldId == fldId).SingleOrDefault();
                    if (edit == null) throw new Exception("Kullanıcı bulunamadı.");
                    if (string.Equals(edit.Role, "Admin", StringComparison.OrdinalIgnoreCase)) throw new Exception("Admin kullanıcı silinemez.");
                    _db.E_User.Remove(edit);
                    _db.SaveChanges();
                }


            }
            catch (Exception exp)
            {
                throw new Exception("Hata Güncellenemedi - " + exp.Message.ToString(), exp);
            }
        }
        /// <summary>
        /// Kullanıcının son giriş zamanını, IP'sini ve aktif bayraklarını günceller.
        /// Login akışını bozmamak için hatayı yutmaktadır (log yoksa).
        /// </summary>
        public void UpdateLastLogin(int fldId, DateTime when, string ip = null)
        {
            try
            {
                using (var _db = new GZPEGM1())
                {
                    var user = _db.E_User.SingleOrDefault(u => u.fldId == fldId);
                    if (user != null)
                    {
                        user.LastLogin = when;
                        user.IsActive = true;
                        user.fldActive = "1";
                        _db.SaveChanges();
                    }
                }
            }
            catch
            {
                // Burada logging eklenebilir; login akışını bozmak istemiyoruz.
            }
        }

        /// <summary>
        /// Sicil numarasına göre kullanıcıyı bulur (Şifre sıfırlama için)
        /// </summary>
        public E_User GetUserBySicil(string sicil)
        {
            if (string.IsNullOrWhiteSpace(sicil))
                return null;

            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_User.Where(c => c.fldSicil.Trim() == sicil.Trim()).SingleOrDefault();
            }
        }

        /// <summary>
        /// Kullanıcının şifresini günceller (Şifre sıfırlama işlemi için)
        /// Hash edilmiş şifre beklenmektedir
        /// </summary>
        public void UpdatePassword(int fldId, string hashedPassword)
        {
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    E_User user = _db.E_User.Where(c => c.fldId == fldId).SingleOrDefault();
                    if (user == null)
                        throw new Exception("Kullanıcı bulunamadı.");

                    user.fldPassword = hashedPassword;
                    _db.SaveChanges();
                }
            }
            catch (Exception exp)
            {
                throw new Exception("Şifre güncellenemedi - " + exp.Message.ToString(), exp);
            }
        }

    }
}

