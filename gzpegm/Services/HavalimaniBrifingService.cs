using gzpegm.Models.ViewModels;
using System.Collections.Generic;

namespace gzpegm.Services
{
    public static class HavalimaniBrifingService
    {
        public static HavalimaniBrifingViewModel GetModel()
        {
            var model = new HavalimaniBrifingViewModel();

            // 1. Büro Teşkilat Yapısı
            model.Burolar = new List<BuroTanimi>
            {
                new BuroTanimi { Kod = "B-1", Ad = "İdari Büro Amirliği", KisaAd = "İdari Büro", SorumlulukAlani = "Gelen/Giden evrak akışı, personel özlük ve lojistik yönetim.", Ikon = "fas fa-folder-open", Renk = "#2563eb" },
                new BuroTanimi { Kod = "B-2", Ad = "Eğitim ve Denetim Büro Amirliği", KisaAd = "Eğitim & Denetim", SorumlulukAlani = "Hizmet içi mesleki eğitimler ve birimler arası mevzuat denetimi.", Ikon = "fas fa-chalkboard-teacher", Renk = "#4f46e5" },
                new BuroTanimi { Kod = "B-3", Ad = "Güvenlik Hizmetleri Büro Amirliği", KisaAd = "Güvenlik Hizmetleri", SorumlulukAlani = "Ana nizamiye, çevre güvenliği, devriye ve araç arama noktaları.", Ikon = "fas fa-shield-alt", Renk = "#059669" },
                new BuroTanimi { Kod = "B-4", Ad = "İç Hatlar Büro Amirliği", KisaAd = "İç Hatlar", SorumlulukAlani = "İç hatlar yolcu ve uçak giriş-çıkış genel asayiş denetimi.", Ikon = "fas fa-plane-arrival", Renk = "#0284c7" },
                new BuroTanimi { Kod = "B-5", Ad = "Dış Hatlar Büro Amirliği", KisaAd = "Dış Hatlar", SorumlulukAlani = "Dış hatlar hudut kapısı geliş/gidiş ve uçak operasyonları.", Ikon = "fas fa-globe-americas", Renk = "#7c3aed" },
                new BuroTanimi { Kod = "B-6", Ad = "VIP Protokol Büro Amirliği", KisaAd = "VIP Büro", SorumlulukAlani = "Devlet ricali, protokol heyetleri ve VIP salonu güvenlik işlemleri.", Ikon = "fas fa-crown", Renk = "#d97706" },
                new BuroTanimi { Kod = "B-7", Ad = "Pasaport Kontrol Büro Amirliği", KisaAd = "Pasaport Kontrol", SorumlulukAlani = "Yurda giriş ve çıkış yapan yolcuların pasaport muayenesi.", Ikon = "fas fa-passport", Renk = "#dc2626" },
                new BuroTanimi { Kod = "B-8", Ad = "Kabul Edilmeyen Yolcular ve Sınırdışı Büro Amirliği", KisaAd = "INAD & Sınırdışı", SorumlulukAlani = "INAD yolcu tespiti, refakat, geri gönderme ve sınırdışı işlemleri.", Ikon = "fas fa-ban", Renk = "#e11d48" },
                new BuroTanimi { Kod = "B-9", Ad = "Seyahat Belgesi İnceleme ve Risk Analizi Büro Amirliği", KisaAd = "Risk Analizi & Sahtecilik", SorumlulukAlani = "Sahte seyahat belgeleri tespiti, 2. hat inceleme ve YTS takibi.", Ikon = "fas fa-search-plus", Renk = "#0d9488" },
                new BuroTanimi { Kod = "B-10", Ad = "Suç Önleme ve Soruşturma Büro Amirliği", KisaAd = "Suç Önleme & Soruşturma", SorumlulukAlani = "Adli asayiş olayları, suç icmali, GBT-UYAP ve aranan şahıslar.", Ikon = "fas fa-user-secret", Renk = "#b91c1c" },
                new BuroTanimi { Kod = "B-11", Ad = "Trafik Denetleme Büro Amirliği", KisaAd = "Trafik Denetleme", SorumlulukAlani = "Havalimanı nizamiyesi, terminal önü otopark ve güzergah trafiği.", Ikon = "fas fa-car-side", Renk = "#ca8a04" },
                new BuroTanimi { Kod = "B-12", Ad = "Bilgi Teknolojileri Büro Amirliği", KisaAd = "Bilgi Teknolojileri", SorumlulukAlani = "CCTV kameraları, PTS, PolNet ağı ve tahdit sorgu/işlemleri.", Ikon = "fas fa-laptop-code", Renk = "#3b82f6" },
                new BuroTanimi { Kod = "B-13", Ad = "Hava Polisi ve Uluslararası İrtibat Noktası Büro Amirliği", KisaAd = "Hava Polisi", SorumlulukAlani = "Sivil havacılık uçuş güvenliği ve uluslararası kolluk irtibatı.", Ikon = "fas fa-fighter-jet", Renk = "#1e293b" }
            };

            // 2. Yolcu ve Uçak İstatistikleri (İç ve Dış Hatlar)
            model.YolcuUcakListesi = new List<YolcuUcakKarsilastirma>
            {
                // İç Hatlar Yolcu
                new YolcuUcakKarsilastirma { Kategori = "İç Hatlar Yolcu", Tur = "Gelen Yolcu", Sayi2025Eylul = 23272, Sayi2026Eylul = 20689, FarkEylul = -2583, YuzdeEylul = -11.0, Sayi2025DokuzAy = 168345, Sayi2026DokuzAy = 160111, FarkDokuzAy = -8234, YuzdeDokuzAy = -5.0 },
                new YolcuUcakKarsilastirma { Kategori = "İç Hatlar Yolcu", Tur = "Giden Yolcu", Sayi2025Eylul = 24402, Sayi2026Eylul = 21446, FarkEylul = -2956, YuzdeEylul = -12.0, Sayi2025DokuzAy = 166880, Sayi2026DokuzAy = 156781, FarkDokuzAy = -10099, YuzdeDokuzAy = -6.0 },
                new YolcuUcakKarsilastirma { Kategori = "İç Hatlar Yolcu", Tur = "Toplam Yolcu", Sayi2025Eylul = 47674, Sayi2026Eylul = 42135, FarkEylul = -5539, YuzdeEylul = -12.0, Sayi2025DokuzAy = 335225, Sayi2026DokuzAy = 316892, FarkDokuzAy = -18333, YuzdeDokuzAy = -5.0 },

                // İç Hatlar Uçak
                new YolcuUcakKarsilastirma { Kategori = "İç Hatlar Uçak", Tur = "Gelen Uçak", Sayi2025Eylul = 150, Sayi2026Eylul = 133, FarkEylul = -17, YuzdeEylul = -11.3, Sayi2025DokuzAy = 1153, Sayi2026DokuzAy = 1042, FarkDokuzAy = -111, YuzdeDokuzAy = -9.6 },
                new YolcuUcakKarsilastirma { Kategori = "İç Hatlar Uçak", Tur = "Giden Uçak", Sayi2025Eylul = 150, Sayi2026Eylul = 133, FarkEylul = -17, YuzdeEylul = -11.3, Sayi2025DokuzAy = 1149, Sayi2026DokuzAy = 1040, FarkDokuzAy = -109, YuzdeDokuzAy = -9.5 },
                new YolcuUcakKarsilastirma { Kategori = "İç Hatlar Uçak", Tur = "Toplam Uçak", Sayi2025Eylul = 300, Sayi2026Eylul = 266, FarkEylul = -34, YuzdeEylul = -11.3, Sayi2025DokuzAy = 2302, Sayi2026DokuzAy = 2082, FarkDokuzAy = -220, YuzdeDokuzAy = -9.6 },

                // Dış Hatlar Yolcu
                new YolcuUcakKarsilastirma { Kategori = "Dış Hatlar Yolcu", Tur = "Gelen Yolcu", Sayi2025Eylul = 38918, Sayi2026Eylul = 37413, FarkEylul = -1505, YuzdeEylul = -4.0, Sayi2025DokuzAy = 241532, Sayi2026DokuzAy = 213265, FarkDokuzAy = -28267, YuzdeDokuzAy = -12.0 },
                new YolcuUcakKarsilastirma { Kategori = "Dış Hatlar Yolcu", Tur = "Giden Yolcu", Sayi2025Eylul = 45725, Sayi2026Eylul = 35343, FarkEylul = -10382, YuzdeEylul = -23.0, Sayi2025DokuzAy = 230107, Sayi2026DokuzAy = 203476, FarkDokuzAy = -26631, YuzdeDokuzAy = -12.0 },
                new YolcuUcakKarsilastirma { Kategori = "Dış Hatlar Yolcu", Tur = "Toplam Yolcu", Sayi2025Eylul = 84643, Sayi2026Eylul = 72756, FarkEylul = -11887, YuzdeEylul = -14.0, Sayi2025DokuzAy = 471639, Sayi2026DokuzAy = 416741, FarkDokuzAy = -54898, YuzdeDokuzAy = -12.0 },

                // Dış Hatlar Uçak
                new YolcuUcakKarsilastirma { Kategori = "Dış Hatlar Uçak", Tur = "Gelen Uçak", Sayi2025Eylul = 263, Sayi2026Eylul = 223, FarkEylul = -40, YuzdeEylul = -15.2, Sayi2025DokuzAy = 1429, Sayi2026DokuzAy = 1286, FarkDokuzAy = -143, YuzdeDokuzAy = -10.0 },
                new YolcuUcakKarsilastirma { Kategori = "Dış Hatlar Uçak", Tur = "Giden Uçak", Sayi2025Eylul = 263, Sayi2026Eylul = 223, FarkEylul = -40, YuzdeEylul = -15.2, Sayi2025DokuzAy = 1432, Sayi2026DokuzAy = 1287, FarkDokuzAy = -145, YuzdeDokuzAy = -10.1 },
                new YolcuUcakKarsilastirma { Kategori = "Dış Hatlar Uçak", Tur = "Toplam Uçak", Sayi2025Eylul = 526, Sayi2026Eylul = 446, FarkEylul = -80, YuzdeEylul = -15.2, Sayi2025DokuzAy = 2861, Sayi2026DokuzAy = 2573, FarkDokuzAy = -288, YuzdeDokuzAy = -10.1 }
            };

            // 3. 2026 Yılı Dış Hatlar İlk 10 Ülke Yolcu Dağılımı
            model.Ilk10Ulke = new List<UlkeYolcuDagilimi>
            {
                new UlkeYolcuDagilimi { Sira = 1, Ulke = "Rusya Federasyonu", Bayrak = "🇷🇺", Gelen = 59786, Giden = 55472, Toplam = 115258, Oran = 27.66 },
                new UlkeYolcuDagilimi { Sira = 2, Ulke = "Danimarka", Bayrak = "🇩🇰", Gelen = 43759, Giden = 41656, Toplam = 85415, Oran = 20.50 },
                new UlkeYolcuDagilimi { Sira = 3, Ulke = "Finlandiya", Bayrak = "🇫🇮", Gelen = 26144, Giden = 25171, Toplam = 51315, Oran = 12.31 },
                new UlkeYolcuDagilimi { Sira = 4, Ulke = "Norveç", Bayrak = "🇳🇴", Gelen = 24280, Giden = 22949, Toplam = 47229, Oran = 11.33 },
                new UlkeYolcuDagilimi { Sira = 5, Ulke = "İsveç", Bayrak = "🇸🇪", Gelen = 13340, Giden = 12971, Toplam = 26311, Oran = 6.31 },
                new UlkeYolcuDagilimi { Sira = 6, Ulke = "Kazakistan", Bayrak = "🇰🇿", Gelen = 12665, Giden = 11848, Toplam = 24513, Oran = 5.88 },
                new UlkeYolcuDagilimi { Sira = 7, Ulke = "Hollanda", Bayrak = "🇳🇱", Gelen = 8747, Giden = 8650, Toplam = 17397, Oran = 4.17 },
                new UlkeYolcuDagilimi { Sira = 8, Ulke = "İran", Bayrak = "🇮🇷", Gelen = 6992, Giden = 6707, Toplam = 13699, Oran = 3.29 },
                new UlkeYolcuDagilimi { Sira = 9, Ulke = "Almanya", Bayrak = "🇩🇪", Gelen = 5497, Giden = 5662, Toplam = 11159, Oran = 2.68 },
                new UlkeYolcuDagilimi { Sira = 10, Ulke = "Türkiye", Bayrak = "🇹🇷", Gelen = 4692, Giden = 5042, Toplam = 9734, Oran = 2.34 },
                new UlkeYolcuDagilimi { Sira = 11, Ulke = "Diğer Ülkeler", Bayrak = "🌐", Gelen = 7363, Giden = 7348, Toplam = 14711, Oran = 3.53 }
            };

            // 4. INAD 2013-2026 Gerekçe İcmali
            model.InadGerekceler = new List<InadGerekceIcmal>
            {
                new InadGerekceIcmal { Sira = 1, Gerekce = "Geçerli Seyahat Belgesine Sahip Olmayan", Yillar = new int[] { 2, 4, 4, 7, 2, 8, 2, 1, 0, 0, 2, 9, 1, 6 }, Toplam = 48, Yuzde = 9.6 },
                new InadGerekceIcmal { Sira = 2, Gerekce = "Türkiye'ye Girişi Sakıncalı Görülmesi", Yillar = new int[] { 0, 0, 0, 0, 0, 0, 2, 0, 1, 1, 0, 3, 2, 0 }, Toplam = 9, Yuzde = 1.8 },
                new InadGerekceIcmal { Sira = 3, Gerekce = "Yeterli Maddi İmkana Sahip Olmaması", Yillar = new int[] { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, Toplam = 0, Yuzde = 0.0 },
                new InadGerekceIcmal { Sira = 4, Gerekce = "Hakkında Türkiye'ye Giriş Yasağı Bulunması", Yillar = new int[] { 0, 0, 0, 5, 8, 6, 18, 10, 30, 6, 16, 22, 14, 8 }, Toplam = 143, Yuzde = 28.7 },
                new InadGerekceIcmal { Sira = 5, Gerekce = "Giriş Vizesinin Olmaması", Yillar = new int[] { 17, 13, 60, 10, 7, 5, 4, 0, 4, 4, 3, 6, 6, 0 }, Toplam = 139, Yuzde = 27.9 },
                new InadGerekceIcmal { Sira = 6, Gerekce = "Pasaport Süresinin Yetersiz Olması", Yillar = new int[] { 0, 0, 0, 0, 8, 9, 7, 0, 2, 1, 2, 10, 5, 7 }, Toplam = 51, Yuzde = 10.2 },
                new InadGerekceIcmal { Sira = 7, Gerekce = "Sahte Pasaport", Yillar = new int[] { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 18, 9, 0 }, Toplam = 35, Yuzde = 7.0 },
                new InadGerekceIcmal { Sira = 8, Gerekce = "Pasaportta Tahrifat Yapılmış Olması", Yillar = new int[] { 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 3, 6, 7, 2 }, Toplam = 20, Yuzde = 4.0 },
                new InadGerekceIcmal { Sira = 9, Gerekce = "Sahte Vize / İkamet", Yillar = new int[] { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0 }, Toplam = 1, Yuzde = 0.2 },
                new InadGerekceIcmal { Sira = 10, Gerekce = "Çalıntı Belge", Yillar = new int[] { 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0 }, Toplam = 1, Yuzde = 0.2 },
                new InadGerekceIcmal { Sira = 11, Gerekce = "180 Günde 90 Gün Uygulamasının İhlali", Yillar = new int[] { 2, 0, 2, 0, 0, 1, 1, 0, 0, 0, 0, 0, 18, 13 }, Toplam = 37, Yuzde = 7.4 },
                new InadGerekceIcmal { Sira = 12, Gerekce = "Diğer Sebepler", Yillar = new int[] { 0, 1, 3, 1, 4, 1, 0, 0, 2, 1, 0, 0, 1, 1 }, Toplam = 15, Yuzde = 3.0 }
            };

            // Yıllara göre toplamlar [2013 - 2026]
            model.InadYillikToplamlar = new int[] { 21, 18, 69, 23, 29, 30, 36, 11, 39, 14, 34, 75, 63, 37 };

            // 5. YTS (Yabancı Terörist Savaşçı) Sorgu Verileri (2024 - 2026)
            model.YtsSorgular = new List<YtsAylikSorgu>
            {
                new YtsAylikSorgu { Ay = "Ocak", Yil2024 = 185, Yil2025 = 192, Yil2026 = 202 },
                new YtsAylikSorgu { Ay = "Şubat", Yil2024 = 128, Yil2025 = 142, Yil2026 = 115 },
                new YtsAylikSorgu { Ay = "Mart", Yil2024 = 161, Yil2025 = 174, Yil2026 = 166 },
                new YtsAylikSorgu { Ay = "Nisan", Yil2024 = 159, Yil2025 = 204, Yil2026 = 166 },
                new YtsAylikSorgu { Ay = "Mayıs", Yil2024 = 183, Yil2025 = 240, Yil2026 = 141 },
                new YtsAylikSorgu { Ay = "Haziran", Yil2024 = 157, Yil2025 = 194, Yil2026 = 138 },
                new YtsAylikSorgu { Ay = "Temmuz", Yil2024 = 158, Yil2025 = 200, Yil2026 = 116 },
                new YtsAylikSorgu { Ay = "Ağustos", Yil2024 = 85, Yil2025 = 170, Yil2026 = 105 },
                new YtsAylikSorgu { Ay = "Eylül", Yil2024 = 80, Yil2025 = 129, Yil2026 = 104 },
                new YtsAylikSorgu { Ay = "Ekim", Yil2024 = 107, Yil2025 = 131, Yil2026 = 0 },
                new YtsAylikSorgu { Ay = "Kasım", Yil2024 = 41, Yil2025 = 92, Yil2026 = 0 },
                new YtsAylikSorgu { Ay = "Aralık", Yil2024 = 61, Yil2025 = 93, Yil2026 = 0 }
            };

            // 6. CCTV Kamera Envanteri
            model.CctvEnvanter = new List<CctvBolgeEnvanteri>
            {
                new CctvBolgeEnvanteri { Bolge = "Terminal Dışı / Çevre", SabitIp = 19, SabitAnalog = 22, SabitToplam = 41, HareketliIp = 5, HareketliAnalog = 0, HareketliToplam = 5, Toplam = 46 },
                new CctvBolgeEnvanteri { Bolge = "Terminal İçi Salonlar", SabitIp = 41, SabitAnalog = 47, SabitToplam = 88, HareketliIp = 8, HareketliAnalog = 0, HareketliToplam = 8, Toplam = 96 },
                new CctvBolgeEnvanteri { Bolge = "Pist - Apron Sahası", SabitIp = 88, SabitAnalog = 18, SabitToplam = 106, HareketliIp = 15, HareketliAnalog = 0, HareketliToplam = 15, Toplam = 121 },
                new CctvBolgeEnvanteri { Bolge = "GENEL TOPLAM", SabitIp = 148, SabitAnalog = 87, SabitToplam = 235, HareketliIp = 28, HareketliAnalog = 0, HareketliToplam = 28, Toplam = 263 }
            };

            // 7. Suç İcmali & Asayiş Olayları (2025 - 2026 Karşılaştırmalı)
            model.SucIcmalListesi = new List<SucIcmalKaydi>
            {
                new SucIcmalKaydi { SucAdi = "Resmi Belgede Sahtecilik", Yil2025Ay = 1, Yil2026Ay = 0, FarkAy = -1, Yil2025SekizAy = 2, Yil2026SekizAy = 1, FarkSekizAy = -1, YuzdeDegisim = -50.0 },
                new SucIcmalKaydi { SucAdi = "Kişilerin Huzur ve Sükununu Bozma", Yil2025Ay = 0, Yil2026Ay = 1, FarkAy = 1, Yil2025SekizAy = 0, Yil2026SekizAy = 1, FarkSekizAy = 1, YuzdeDegisim = 100.0 },
                new SucIcmalKaydi { SucAdi = "Mala Zarar Verme", Yil2025Ay = 0, Yil2026Ay = 1, FarkAy = 1, Yil2025SekizAy = 0, Yil2026SekizAy = 1, FarkSekizAy = 1, YuzdeDegisim = 100.0 },
                new SucIcmalKaydi { SucAdi = "İş Kazası", Yil2025Ay = 0, Yil2026Ay = 0, FarkAy = 0, Yil2025SekizAy = 2, Yil2026SekizAy = 5, FarkSekizAy = 3, YuzdeDegisim = 150.0 },
                new SucIcmalKaydi { SucAdi = "Görevi Yaptırmamak İçin Direnme", Yil2025Ay = 0, Yil2026Ay = 1, FarkAy = 1, Yil2025SekizAy = 0, Yil2026SekizAy = 1, FarkSekizAy = 1, YuzdeDegisim = 100.0 },
                new SucIcmalKaydi { SucAdi = "Hakaret", Yil2025Ay = 0, Yil2026Ay = 1, FarkAy = 1, Yil2025SekizAy = 0, Yil2026SekizAy = 1, FarkSekizAy = 1, YuzdeDegisim = 100.0 },
                new SucIcmalKaydi { SucAdi = "Trafik Güvenliğini Tehlikeye Sokmak", Yil2025Ay = 0, Yil2026Ay = 0, FarkAy = 0, Yil2025SekizAy = 2, Yil2026SekizAy = 1, FarkSekizAy = -1, YuzdeDegisim = -50.0 },
                new SucIcmalKaydi { SucAdi = "Kasten Yaralama", Yil2025Ay = 0, Yil2026Ay = 1, FarkAy = 1, Yil2025SekizAy = 0, Yil2026SekizAy = 1, FarkSekizAy = 1, YuzdeDegisim = 100.0 }
            };

            // 8. Trafik Denetleme Ekip Faaliyetleri
            model.TrafikFaaliyetleri = new List<TrafikDenetimKaydi>
            {
                new TrafikDenetimKaydi { FaaliyetAdi = "Kontrol Edilen Araç Sayısı", Ags2026 = "1.201", Eyl2026 = "1.021", YuzdeAy = "% -14", Ilk9Ay2025 = "7.548", Ilk9Ay2026 = "7.685", Yuzde9Ay = "% +2" },
                new TrafikDenetimKaydi { FaaliyetAdi = "Ceza Yazılan Sürücü Sayısı", Ags2026 = "98", Eyl2026 = "49", YuzdeAy = "% -50", Ilk9Ay2025 = "714", Ilk9Ay2026 = "380", Yuzde9Ay = "% -46" },
                new TrafikDenetimKaydi { FaaliyetAdi = "Ceza Tutanağı Para Miktarı", Ags2026 = "168.454 ₺", Eyl2026 = "93.664 ₺", YuzdeAy = "% -44", Ilk9Ay2025 = "1.446.103 ₺", Ilk9Ay2026 = "1.449.005 ₺", Yuzde9Ay = "% +1" },
                new TrafikDenetimKaydi { FaaliyetAdi = "Trafikten Men Edilen Araç Sayısı", Ags2026 = "2", Eyl2026 = "1", YuzdeAy = "% -50", Ilk9Ay2025 = "9", Ilk9Ay2026 = "7", Yuzde9Ay = "% -22" },
                new TrafikDenetimKaydi { FaaliyetAdi = "Geçici Geri Alınan Sürücü Belgesi", Ags2026 = "0", Eyl2026 = "0", YuzdeAy = "% 0", Ilk9Ay2025 = "2", Ilk9Ay2026 = "2", Yuzde9Ay = "% 0" }
            };

            return model;
        }
    }
}
