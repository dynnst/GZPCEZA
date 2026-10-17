using System;

namespace gzpegm.Models
{
    public class UserViewModel
    {
        public int fldId { get; set; }
        public string fldSicil { get; set; }
        public string fldName { get; set; }
        public string fldLastName { get; set; }
        public string fldEmail { get; set; }
        public string fldPhone { get; set; }
        public string fldAuth { get; set; }      // İşlem yetkileri
        public string fldActive { get; set; }    // Kullanıcı aktif mi?
        public string fldTitle { get; set; }     // Ünvan
        public string fldDeputy { get; set; }    // Görev Yeri

        public DateTime? LastLogin { get; set; } // Son giriş zamanı
        public string LastIP { get; set; }       // Son giriş IP
        public DateTime? RegisterDate { get; set; } // Kayıt tarihi
        public string Role { get; set; } // ✅ BU EKLENMELİ


    }



}