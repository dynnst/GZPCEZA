using System;
using System.Collections.Generic;

namespace gzpegm.Models.ViewModels
{
    public class BuroTanimi
    {
        public string Kod { get; set; }
        public string Ad { get; set; }
        public string KisaAd { get; set; }
        public string SorumlulukAlani { get; set; }
        public string Ikon { get; set; }
        public string Renk { get; set; }
    }

    public class YolcuUcakKarsilastirma
    {
        public string Kategori { get; set; }
        public string Tur { get; set; } // Gelen, Giden, Toplam
        public int Sayi2025Eylul { get; set; }
        public int Sayi2026Eylul { get; set; }
        public int FarkEylul { get; set; }
        public double YuzdeEylul { get; set; }
        public int Sayi2025DokuzAy { get; set; }
        public int Sayi2026DokuzAy { get; set; }
        public int FarkDokuzAy { get; set; }
        public double YuzdeDokuzAy { get; set; }
    }

    public class UlkeYolcuDagilimi
    {
        public int Sira { get; set; }
        public string Ulke { get; set; }
        public string Bayrak { get; set; }
        public int Gelen { get; set; }
        public int Giden { get; set; }
        public int Toplam { get; set; }
        public double Oran { get; set; }
    }

    public class InadGerekceIcmal
    {
        public int Sira { get; set; }
        public string Gerekce { get; set; }
        public int[] Yillar { get; set; } = new int[14]; // 2013 to 2026
        public int Toplam { get; set; }
        public double Yuzde { get; set; }
    }

    public class YtsAylikSorgu
    {
        public string Ay { get; set; }
        public int Yil2024 { get; set; }
        public int Yil2025 { get; set; }
        public int Yil2026 { get; set; }
    }

    public class CctvBolgeEnvanteri
    {
        public string Bolge { get; set; }
        public int SabitIp { get; set; }
        public int SabitAnalog { get; set; }
        public int SabitToplam { get; set; }
        public int HareketliIp { get; set; }
        public int HareketliAnalog { get; set; }
        public int HareketliToplam { get; set; }
        public int Toplam { get; set; }
    }

    public class SucIcmalKaydi
    {
        public string SucAdi { get; set; }
        public int Yil2025Ay { get; set; }
        public int Yil2026Ay { get; set; }
        public int FarkAy { get; set; }
        public int Yil2025SekizAy { get; set; }
        public int Yil2026SekizAy { get; set; }
        public int FarkSekizAy { get; set; }
        public double YuzdeDegisim { get; set; }
    }

    public class TrafikDenetimKaydi
    {
        public string FaaliyetAdi { get; set; }
        public string Ags2026 { get; set; }
        public string Eyl2026 { get; set; }
        public string YuzdeAy { get; set; }
        public string Ilk9Ay2025 { get; set; }
        public string Ilk9Ay2026 { get; set; }
        public string Yuzde9Ay { get; set; }
    }

    public class HavalimaniBrifingViewModel
    {
        public string Baslik { get; set; } = "Antalya Havalimanı Emniyet Şube Müdürlüğü";
        public string Donem { get; set; } = "2026 Yılı 9 Aylık Brifing ve İstatistik Raporu";
        public string Siniflandirma { get; set; } = "HİZMETE ÖZEL";

        // Özet KPI Metrikleri
        public int ToplamYolcu2026 { get; set; } = 733633; // 316.892 İç + 416.741 Dış
        public int ToplamUcak2026 { get; set; } = 4655;    // 2.082 İç + 2.573 Dış
        public int DisHatYolcu2026 { get; set; } = 416741;
        public int IcHatYolcu2026 { get; set; } = 316892;
        public int InadVakaSayisi { get; set; } = 499;     // 2013-2026 14 Yıllık Toplam
        public int Inad2026Sayisi { get; set; } = 37;      // 2026 Yılı
        public int ToplamKamera { get; set; } = 263;       // CCTV Toplamı
        public int YtsSorgu2026 { get; set; } = 1253;      // 2026 9 Aylık YTS
        public string TrafikCezaTutarTl { get; set; } = "1.449.005 ₺";
        public int GbtUyapSorgu { get; set; } = 6693;      // 2026 8 Aylık
        public int ArananSahisYakalanan { get; set; } = 42;
        public int TahditBakilanKisi { get; set; } = 1184;

        // Detay Listeleri
        public List<BuroTanimi> Burolar { get; set; } = new List<BuroTanimi>();
        public List<YolcuUcakKarsilastirma> YolcuUcakListesi { get; set; } = new List<YolcuUcakKarsilastirma>();
        public List<UlkeYolcuDagilimi> Ilk10Ulke { get; set; } = new List<UlkeYolcuDagilimi>();
        public List<InadGerekceIcmal> InadGerekceler { get; set; } = new List<InadGerekceIcmal>();
        public int[] InadYillikToplamlar { get; set; } = new int[14];
        public List<YtsAylikSorgu> YtsSorgular { get; set; } = new List<YtsAylikSorgu>();
        public List<CctvBolgeEnvanteri> CctvEnvanter { get; set; } = new List<CctvBolgeEnvanteri>();
        public List<SucIcmalKaydi> SucIcmalListesi { get; set; } = new List<SucIcmalKaydi>();
        public List<TrafikDenetimKaydi> TrafikFaaliyetleri { get; set; } = new List<TrafikDenetimKaydi>();
    }
}
