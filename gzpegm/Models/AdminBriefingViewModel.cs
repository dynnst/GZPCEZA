using System;
using System.Collections.Generic;

namespace gzpegm.Models
{
    public class AdminBriefingViewModel
    {
        // -------------------------------------------------------------
        // DÖNEM VE ZAMAN ARALIĞI BİLGİLERİ
        // -------------------------------------------------------------
        public string SelectedPeriod { get; set; } = "24saat"; // 1saat, 3saat, 6saat, 12saat, 24saat, bugun, dun, haftalik, aylik, yillik, ozel
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public string PeriodLabel { get; set; }
        public DateTime GeneratedAt { get; set; } = DateTime.Now;
        public string GeneratedBySicil { get; set; }
        public string GeneratedByName { get; set; }

        // -------------------------------------------------------------
        // ANA OPERASYONEL METRİKLER (Kullanıcının talep ettiği göstergeler)
        // -------------------------------------------------------------
        /// <summary>
        /// Kaç ceza hesaplaması yapıldı
        /// </summary>
        public int HesaplamaCount { get; set; }

        /// <summary>
        /// Hesaplanan toplam idari para cezası (TL)
        /// </summary>
        public decimal HesaplamaTotalTutar { get; set; }

        /// <summary>
        /// Kaç ceza form (İSK) çıkartıldı / tanzim edildi
        /// </summary>
        public int CezaFormCikarmaCount { get; set; }

        /// <summary>
        /// Kaç tahdit tutanağı / tebligat formu çıkartıldı
        /// </summary>
        public int TahditFormCikarmaCount { get; set; }

        /// <summary>
        /// Toplam form / tutanak çıkartma sayısı
        /// </summary>
        public int ToplamFormCikarmaCount => CezaFormCikarmaCount + TahditFormCikarmaCount;

        /// <summary>
        /// Kaç V-84 şartlı giriş taahhüt işlemi yapıldı
        /// </summary>
        public int V84IslemCount { get; set; }

        /// <summary>
        /// Kaç İnad yolcu işlemi yapıldı
        /// </summary>
        public int InadIslemCount { get; set; }

        /// <summary>
        /// Kaç ders / kurs kaydı oluşturuldu
        /// </summary>
        public int DersKayitCount { get; set; }

        /// <summary>
        /// Kaç sınav tamamlandı
        /// </summary>
        public int SinavCount { get; set; }

        /// <summary>
        /// Tamamlanan sınavların ortalama puanı
        /// </summary>
        public double SinavOrtalamaPuan { get; set; }

        /// <summary>
        /// Kaç sahtecilik portalına yönlendirilme / geçiş yapıldı
        /// </summary>
        public int SahtecilikGecisCount { get; set; }

        /// <summary>
        /// Kaç referans belge incelendi / arandı (Sahtecilik)
        /// </summary>
        public int SahtecilikIncelemeCount { get; set; }

        /// <summary>
        /// Toplam Sahtecilik denetim işlem sayısı
        /// </summary>
        public int ToplamSahtecilikIslemCount => SahtecilikGecisCount + SahtecilikIncelemeCount;

        /// <summary>
        /// Kaç yeni kullanıcı kaydı oluşturuldu
        /// </summary>
        public int YeniKullaniciKayitCount { get; set; }

        /// <summary>
        /// Kaç şifremi unuttum / sıfırlama işlemi talep edildi
        /// </summary>
        public int SifremiUnuttumCount { get; set; }

        /// <summary>
        /// Şifre sıfırlama taleplerinden kaçı onaylanarak tamamlandı
        /// </summary>
        public int SifremiUnuttumOnaylananCount { get; set; }

        /// <summary>
        /// Sistem içi mesajlaşma sayısı
        /// </summary>
        public int MesajlasmaCount { get; set; }

        /// <summary>
        /// Gizli genelge erişim talep sayısı
        /// </summary>
        public int GenelgeTalepCount { get; set; }

        /// <summary>
        /// Toplam sistem etkileşim / işlem hacmi
        /// </summary>
        public int ToplamIslemHacmi => HesaplamaCount + ToplamFormCikarmaCount + V84IslemCount +
                                       InadIslemCount + DersKayitCount + SinavCount +
                                       ToplamSahtecilikIslemCount + YeniKullaniciKayitCount +
                                       SifremiUnuttumCount + MesajlasmaCount + GenelgeTalepCount;

        // -------------------------------------------------------------
        // DETAYLI DAĞILIM LİSTELERİ (Grafik & Tablolar İçin)
        // -------------------------------------------------------------
        public List<BriefingItemSummary> TopHesaplamaUlkeleri { get; set; } = new List<BriefingItemSummary>();
        public List<BriefingItemSummary> TopTahditKodlari { get; set; } = new List<BriefingItemSummary>();
        public List<BriefingItemSummary> TopInadUlkeleri { get; set; } = new List<BriefingItemSummary>();
        public List<BriefingItemSummary> TopV84Ulkeleri { get; set; } = new List<BriefingItemSummary>();
        public List<BriefingItemSummary> TopHudutKapilari { get; set; } = new List<BriefingItemSummary>();
        public List<BriefingItemSummary> TopAktifPersoneller { get; set; } = new List<BriefingItemSummary>();
        public List<RecentActivityItem> SonIslemler { get; set; } = new List<RecentActivityItem>();
    }

    public class BriefingItemSummary
    {
        public string Title { get; set; }
        public string SubTitle { get; set; }
        public int Count { get; set; }
        public decimal TotalAmount { get; set; }
        public double Percentage { get; set; }
    }

    public class RecentActivityItem
    {
        public DateTime Timestamp { get; set; }
        public string Module { get; set; }
        public string Description { get; set; }
        public string Officer { get; set; }
        public string Border { get; set; }
        public string BadgeClass { get; set; }
    }
}
