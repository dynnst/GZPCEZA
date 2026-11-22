using System;

namespace gzpegm.Models
{
    public class DuyuruItem
    {
        public int Id { get; set; }
        public string Baslik { get; set; }
        public string Icerik { get; set; }
        public string Kategori { get; set; } // 'Genel', 'Onemli', 'Acil', 'Mevzuat', 'Egitim'
        public int Oncelik { get; set; } // 1: Normal, 2: Önemli, 3: Acil
        public int? OlusturanUserId { get; set; }
        public string OlusturanAd { get; set; }
        public string OlusturanSicil { get; set; }
        public string OlusturanRol { get; set; } // 'Sistem Yöneticisi', 'Öğretmen / Eğitim Birimi'
        public DateTime Tarih { get; set; }
        public bool Aktif { get; set; }
        public DateTime? GecerlilikTarihi { get; set; }

        public string FormattedTarih => Tarih.ToString("dd.MM.yyyy HH:mm");

        public string TimeAgo
        {
            get
            {
                var diff = DateTime.Now - Tarih;
                if (diff.TotalMinutes < 1) return "Az önce";
                if (diff.TotalMinutes < 60) return $"{(int)diff.TotalMinutes} dk önce";
                if (diff.TotalHours < 24) return $"{(int)diff.TotalHours} saat önce";
                if (diff.TotalDays < 7) return $"{(int)diff.TotalDays} gün önce";
                return Tarih.ToString("dd.MM.yyyy");
            }
        }

        public string BadgeClass
        {
            get
            {
                switch ((Kategori ?? "").ToLowerInvariant())
                {
                    case "acil": return "badge-danger";
                    case "onemli": return "badge-warning";
                    case "mevzuat": return "badge-primary";
                    case "egitim": return "badge-info";
                    default: return "badge-secondary";
                }
            }
        }

        public string BadgeText
        {
            get
            {
                switch ((Kategori ?? "").ToLowerInvariant())
                {
                    case "acil": return "Acil";
                    case "onemli": return "Önemli";
                    case "mevzuat": return "Mevzuat";
                    case "egitim": return "Eğitim";
                    default: return "Genel";
                }
            }
        }
    }
}
