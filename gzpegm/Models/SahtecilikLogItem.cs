using System;
using System.Collections.Generic;

namespace gzpegm.Models
{
    public class SahtecilikLogItem
    {
        public int Id { get; set; }
        public int? UserId { get; set; }
        public string UserSicil { get; set; }
        public string UserName { get; set; }
        public string UserBorder { get; set; }
        public string KaynakSayfa { get; set; } // 'Hesaplama', 'UserBox', 'Yardımcı', 'Sahtecilik Portalı'
        public string IslemTipi { get; set; } // 'Portal Geçişi', 'Belge İnceleme', 'Arama'
        public string SecilenUlke { get; set; }
        public int? IncelenenBelgeId { get; set; }
        public string IncelenenBelgeBaslik { get; set; }
        public DateTime IslemTarihi { get; set; }
        public string IpAddress { get; set; }
        public string HedefUrl { get; set; }
        public string Detay { get; set; }

        public string FormattedTarih => IslemTarihi.ToString("dd.MM.yyyy HH:mm:ss");

        public string TimeAgo
        {
            get
            {
                var span = DateTime.Now - IslemTarihi;
                if (span.TotalMinutes < 1) return "Az önce";
                if (span.TotalMinutes < 60) return $"{(int)span.TotalMinutes} dk önce";
                if (span.TotalHours < 24) return $"{(int)span.TotalHours} saat önce";
                return $"{(int)span.TotalDays} gün önce";
            }
        }
    }

    public class SahtecilikLogViewModel
    {
        public List<SahtecilikLogItem> Logs { get; set; } = new List<SahtecilikLogItem>();
        public int TotalCount { get; set; }
        public int PageIndex { get; set; }
        public int PageSize { get; set; }
        public int TotalPages => (int)Math.Ceiling((double)TotalCount / (PageSize > 0 ? PageSize : 25));

        // Filtreler
        public string Search { get; set; }
        public string Kaynak { get; set; }
        public string Ulke { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }

        // Özet İstatistikler
        public int TodayCount { get; set; }
        public int WeekCount { get; set; }
        public int DistinctUserCount { get; set; }
        public List<KeyValuePair<string, int>> TopCountries { get; set; } = new List<KeyValuePair<string, int>>();
    }
}
