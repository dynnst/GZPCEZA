-- ====================================================================================================
-- CEZAM / GZP EGM - HAVALİMANI EMNİYET ŞUBE MÜDÜRLÜĞÜ BRİFİNG VE İSTATİSTİK VERİTABANI BETİĞİ
-- Dosya Adı: 05_HAVALIMANI_BRIFING_VE_ISTATISTIK_VERILERI.sql
-- Sınıflandırma: HİZMETE ÖZEL
-- Kapsam: 13 Büro Teşkilatı, 2025-2026 İç/Dış Hat Yolcu & Uçak İstatistikleri,
--         İlk 10 Ülke Yolcu Dağılımı, 14 Yıllık INAD İcmali, YTS Sorguları, CCTV ve Trafik Verileri.
-- ====================================================================================================

SET NOCOUNT ON;
GO

-- 1. BÜRO TEŞKİLATI TABLOSU
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'E_HavalimaniBuro')
BEGIN
    CREATE TABLE [dbo].[E_HavalimaniBuro] (
        [Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [BuroKodu] NVARCHAR(20) NOT NULL,
        [BuroAdi] NVARCHAR(150) NOT NULL,
        [KisaAd] NVARCHAR(100) NOT NULL,
        [SorumlulukAlani] NVARCHAR(500) NULL,
        [Ikon] NVARCHAR(50) NULL,
        [Renk] NVARCHAR(20) NULL,
        [SiraNo] INT NOT NULL DEFAULT(0),
        [AktifMi] BIT NOT NULL DEFAULT(1)
    );
END
GO

-- 2. YOLCU VE UÇAK İSTATİSTİKLERİ TABLOSU
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'E_HavalimaniYolcuUcak')
BEGIN
    CREATE TABLE [dbo].[E_HavalimaniYolcuUcak] (
        [Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [Kategori] NVARCHAR(50) NOT NULL, -- 'İç Hatlar Yolcu', 'İç Hatlar Uçak', 'Dış Hatlar Yolcu', 'Dış Hatlar Uçak'
        [Tur] NVARCHAR(50) NOT NULL,      -- 'Gelen', 'Giden', 'Toplam'
        [Yil2025Eylul] INT NOT NULL DEFAULT(0),
        [Yil2026Eylul] INT NOT NULL DEFAULT(0),
        [FarkEylul] INT NOT NULL DEFAULT(0),
        [YuzdeEylul] DECIMAL(6,2) NOT NULL DEFAULT(0),
        [Yil2025DokuzAy] INT NOT NULL DEFAULT(0),
        [Yil2026DokuzAy] INT NOT NULL DEFAULT(0),
        [FarkDokuzAy] INT NOT NULL DEFAULT(0),
        [YuzdeDokuzAy] DECIMAL(6,2) NOT NULL DEFAULT(0)
    );
END
GO

-- 3. DIŞ HATLAR İLK 10 ÜLKE DAĞILIMI TABLOSU
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'E_HavalimaniUlkeIstatistik')
BEGIN
    CREATE TABLE [dbo].[E_HavalimaniUlkeIstatistik] (
        [Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [Yil] INT NOT NULL DEFAULT(2026),
        [Donem] NVARCHAR(50) NOT NULL DEFAULT('9 Aylık'),
        [SiraNo] INT NOT NULL,
        [UlkeAdi] NVARCHAR(100) NOT NULL,
        [Bayrak] NVARCHAR(10) NULL,
        [GelenYolcu] INT NOT NULL DEFAULT(0),
        [GidenYolcu] INT NOT NULL DEFAULT(0),
        [ToplamYolcu] INT NOT NULL DEFAULT(0),
        [YolcuPayiYuzde] DECIMAL(6,2) NOT NULL DEFAULT(0)
    );
END
GO

-- 4. KABUL EDİLMEYEN YOLCULAR (INAD) 14 YILLIK İCMAL TABLOSU
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'E_HavalimaniInadIcmal')
BEGIN
    CREATE TABLE [dbo].[E_HavalimaniInadIcmal] (
        [Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [SiraNo] INT NOT NULL,
        [Gerekce] NVARCHAR(250) NOT NULL,
        [Yil2013] INT NOT NULL DEFAULT(0),
        [Yil2014] INT NOT NULL DEFAULT(0),
        [Yil2015] INT NOT NULL DEFAULT(0),
        [Yil2016] INT NOT NULL DEFAULT(0),
        [Yil2017] INT NOT NULL DEFAULT(0),
        [Yil2018] INT NOT NULL DEFAULT(0),
        [Yil2019] INT NOT NULL DEFAULT(0),
        [Yil2020] INT NOT NULL DEFAULT(0),
        [Yil2021] INT NOT NULL DEFAULT(0),
        [Yil2022] INT NOT NULL DEFAULT(0),
        [Yil2023] INT NOT NULL DEFAULT(0),
        [Yil2024] INT NOT NULL DEFAULT(0),
        [Yil2025] INT NOT NULL DEFAULT(0),
        [Yil2026] INT NOT NULL DEFAULT(0),
        [ToplamVaka] INT NOT NULL DEFAULT(0),
        [PayYuzdesi] DECIMAL(6,2) NOT NULL DEFAULT(0)
    );
END
GO

-- 5. YTS (YABANCI TERÖRİST SAVAŞÇI) AYLIK SORGU TABLOSU
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'E_HavalimaniYtsSorgu')
BEGIN
    CREATE TABLE [dbo].[E_HavalimaniYtsSorgu] (
        [Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [AyNo] INT NOT NULL,
        [AyAdi] NVARCHAR(20) NOT NULL,
        [Yil2024] INT NOT NULL DEFAULT(0),
        [Yil2025] INT NOT NULL DEFAULT(0),
        [Yil2026] INT NOT NULL DEFAULT(0)
    );
END
GO

-- 6. CCTV KAMERA ENVANTERİ TABLOSU
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'E_HavalimaniCctvEnvanter')
BEGIN
    CREATE TABLE [dbo].[E_HavalimaniCctvEnvanter] (
        [Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [Bolge] NVARCHAR(100) NOT NULL,
        [SabitIp] INT NOT NULL DEFAULT(0),
        [SabitAnalog] INT NOT NULL DEFAULT(0),
        [SabitToplam] INT NOT NULL DEFAULT(0),
        [HareketliIp] INT NOT NULL DEFAULT(0),
        [HareketliAnalog] INT NOT NULL DEFAULT(0),
        [HareketliToplam] INT NOT NULL DEFAULT(0),
        [GenelToplam] INT NOT NULL DEFAULT(0)
    );
END
GO

-- ====================================================================================================
-- VERİ TOHUMLAMA (SEED DATA)
-- ====================================================================================================

-- 1. BÜROLAR
TRUNCATE TABLE [dbo].[E_HavalimaniBuro];
INSERT INTO [dbo].[E_HavalimaniBuro] ([BuroKodu], [BuroAdi], [KisaAd], [SorumlulukAlani], [Ikon], [Renk], [SiraNo])
VALUES
('B-1', N'İdari Büro Amirliği', N'İdari Büro', N'Gelen/Giden evrak akışı, personel özlük ve lojistik yönetim.', 'fas fa-folder-open', '#2563eb', 1),
('B-2', N'Eğitim ve Denetim Büro Amirliği', N'Eğitim & Denetim', N'Hizmet içi mesleki eğitimler ve birimler arası mevzuat denetimi.', 'fas fa-chalkboard-teacher', '#4f46e5', 2),
('B-3', N'Güvenlik Hizmetleri Büro Amirliği', N'Güvenlik Hizmetleri', N'Ana nizamiye, çevre güvenliği, devriye ve araç arama noktaları.', 'fas fa-shield-alt', '#059669', 3),
('B-4', N'İç Hatlar Büro Amirliği', N'İç Hatlar', N'İç hatlar yolcu ve uçak giriş-çıkış genel asayiş denetimi.', 'fas fa-plane-arrival', '#0284c7', 4),
('B-5', N'Dış Hatlar Büro Amirliği', N'Dış Hatlar', N'Dış hatlar hudut kapısı geliş/gidiş ve uçak operasyonları.', 'fas fa-globe-americas', '#7c3aed', 5),
('B-6', N'VIP Protokol Büro Amirliği', N'VIP Büro', N'Devlet ricali, protokol heyetleri ve VIP salonu güvenlik işlemleri.', 'fas fa-crown', '#d97706', 6),
('B-7', N'Pasaport Kontrol Büro Amirliği', N'Pasaport Kontrol', N'Yurda giriş ve çıkış yapan yolcuların pasaport muayenesi.', 'fas fa-passport', '#dc2626', 7),
('B-8', N'Kabul Edilmeyen Yolcular ve Sınırdışı Büro Amirliği', N'INAD & Sınırdışı', N'INAD yolcu tespiti, refakat, geri gönderme ve sınırdışı işlemleri.', 'fas fa-ban', '#e11d48', 8),
('B-9', N'Seyahat Belgesi İnceleme ve Risk Analizi Büro Amirliği', N'Risk Analizi & Sahtecilik', N'Sahte seyahat belgeleri tespiti, 2. hat inceleme ve YTS takibi.', 'fas fa-search-plus', '#0d9488', 9),
('B-10', N'Suç Önleme ve Soruşturma Büro Amirliği', N'Suç Önleme & Soruşturma', N'Adli asayiş olayları, suç icmali, GBT-UYAP ve aranan şahıslar.', 'fas fa-user-secret', '#b91c1c', 10),
('B-11', N'Trafik Denetleme Büro Amirliği', N'Trafik Denetleme', N'Havalimanı nizamiyesi, terminal önü otopark ve güzergah trafiği.', 'fas fa-car-side', '#ca8a04', 11),
('B-12', N'Bilgi Teknolojileri Büro Amirliği', N'Bilgi Teknolojileri', N'CCTV kameraları, PTS, PolNet ağı ve tahdit sorgu/işlemleri.', 'fas fa-laptop-code', '#3b82f6', 12),
('B-13', N'Hava Polisi ve Uluslararası İrtibat Noktası Büro Amirliği', N'Hava Polisi', N'Sivil havacılık uçuş güvenliği ve uluslararası kolluk irtibatı.', 'fas fa-fighter-jet', '#1e293b', 13);
GO

-- 2. YOLCU VE UÇAK İSTATİSTİKLERİ
TRUNCATE TABLE [dbo].[E_HavalimaniYolcuUcak];
INSERT INTO [dbo].[E_HavalimaniYolcuUcak]
([Kategori], [Tur], [Yil2025Eylul], [Yil2026Eylul], [FarkEylul], [YuzdeEylul], [Yil2025DokuzAy], [Yil2026DokuzAy], [FarkDokuzAy], [YuzdeDokuzAy])
VALUES
(N'İç Hatlar Yolcu', N'Gelen Yolcu', 23272, 20689, -2583, -11.0, 168345, 160111, -8234, -5.0),
(N'İç Hatlar Yolcu', N'Giden Yolcu', 24402, 21446, -2956, -12.0, 166880, 156781, -10099, -6.0),
(N'İç Hatlar Yolcu', N'Toplam Yolcu', 47674, 42135, -5539, -12.0, 335225, 316892, -18333, -5.0),
(N'İç Hatlar Uçak', N'Gelen Uçak', 150, 133, -17, -11.3, 1153, 1042, -111, -9.6),
(N'İç Hatlar Uçak', N'Giden Uçak', 150, 133, -17, -11.3, 1149, 1040, -109, -9.5),
(N'İç Hatlar Uçak', N'Toplam Uçak', 300, 266, -34, -11.3, 2302, 2082, -220, -9.6),
(N'Dış Hatlar Yolcu', N'Gelen Yolcu', 38918, 37413, -1505, -4.0, 241532, 213265, -28267, -12.0),
(N'Dış Hatlar Yolcu', N'Giden Yolcu', 45725, 35343, -10382, -23.0, 230107, 203476, -26631, -12.0),
(N'Dış Hatlar Yolcu', N'Toplam Yolcu', 84643, 72756, -11887, -14.0, 471639, 416741, -54898, -12.0),
(N'Dış Hatlar Uçak', N'Gelen Uçak', 263, 223, -40, -15.2, 1429, 1286, -143, -10.0),
(N'Dış Hatlar Uçak', N'Giden Uçak', 263, 223, -40, -15.2, 1432, 1287, -145, -10.1),
(N'Dış Hatlar Uçak', N'Toplam Uçak', 526, 446, -80, -15.2, 2861, 2573, -288, -10.1);
GO

-- 3. DIŞ HATLAR İLK 10 ÜLKE
TRUNCATE TABLE [dbo].[E_HavalimaniUlkeIstatistik];
INSERT INTO [dbo].[E_HavalimaniUlkeIstatistik]
([Yil], [Donem], [SiraNo], [UlkeAdi], [Bayrak], [GelenYolcu], [GidenYolcu], [ToplamYolcu], [YolcuPayiYuzde])
VALUES
(2026, N'9 Aylık', 1, N'Rusya Federasyonu', N'🇷🇺', 59786, 55472, 115258, 27.66),
(2026, N'9 Aylık', 2, N'Danimarka', N'🇩🇰', 43759, 41656, 85415, 20.50),
(2026, N'9 Aylık', 3, N'Finlandiya', N'🇫🇮', 26144, 25171, 51315, 12.31),
(2026, N'9 Aylık', 4, N'Norveç', N'🇳🇴', 24280, 22949, 47229, 11.33),
(2026, N'9 Aylık', 5, N'İsveç', N'🇸🇪', 13340, 12971, 26311, 6.31),
(2026, N'9 Aylık', 6, N'Kazakistan', N'🇰🇿', 12665, 11848, 24513, 5.88),
(2026, N'9 Aylık', 7, N'Hollanda', N'🇳🇱', 8747, 8650, 17397, 4.17),
(2026, N'9 Aylık', 8, N'İran', N'🇮🇷', 6992, 6707, 13699, 3.29),
(2026, N'9 Aylık', 9, N'Almanya', N'🇩🇪', 5497, 5662, 11159, 2.68),
(2026, N'9 Aylık', 10, N'Türkiye', N'🇹🇷', 4692, 5042, 9734, 2.34),
(2026, N'9 Aylık', 11, N'Diğer Ülkeler', N'🌐', 7363, 7348, 14711, 3.53);
GO

-- 4. INAD 14 YILLIK İCMAL
TRUNCATE TABLE [dbo].[E_HavalimaniInadIcmal];
INSERT INTO [dbo].[E_HavalimaniInadIcmal]
([SiraNo], [Gerekce], [Yil2013], [Yil2014], [Yil2015], [Yil2016], [Yil2017], [Yil2018], [Yil2019], [Yil2020], [Yil2021], [Yil2022], [Yil2023], [Yil2024], [Yil2025], [Yil2026], [ToplamVaka], [PayYuzdesi])
VALUES
(1, N'Geçerli Seyahat Belgesine Sahip Olmayan', 2, 4, 4, 7, 2, 8, 2, 1, 0, 0, 2, 9, 1, 6, 48, 9.6),
(2, N'Türkiye''ye Girişi Sakıncalı Görülmesi', 0, 0, 0, 0, 0, 0, 2, 0, 1, 1, 0, 3, 2, 0, 9, 1.8),
(3, N'Yeterli Maddi İmkana Sahip Olmaması', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0),
(4, N'Hakkında Türkiye''ye Giriş Yasağı Bulunması', 0, 0, 0, 5, 8, 6, 18, 10, 30, 6, 16, 22, 14, 8, 143, 28.7),
(5, N'Giriş Vizesinin Olmaması', 17, 13, 60, 10, 7, 5, 4, 0, 4, 4, 3, 6, 6, 0, 139, 27.9),
(6, N'Pasaport Süresinin Yetersiz Olması', 0, 0, 0, 0, 8, 9, 7, 0, 2, 1, 2, 10, 5, 7, 51, 10.2),
(7, N'Sahte Pasaport', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 18, 9, 0, 35, 7.0),
(8, N'Pasaportta Tahrifat Yapılmış Olması', 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 3, 6, 7, 2, 20, 4.0),
(9, N'Sahte Vize / İkamet', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0.2),
(10, N'Çalıntı Belge', 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0.2),
(11, N'180 Günde 90 Gün Uygulamasının İhlali', 2, 0, 2, 0, 0, 1, 1, 0, 0, 0, 0, 0, 18, 13, 37, 7.4),
(12, N'Diğer Sebepler', 0, 1, 3, 1, 4, 1, 0, 0, 2, 1, 0, 0, 1, 1, 15, 3.0);
GO

-- 5. YTS SORGULARI
TRUNCATE TABLE [dbo].[E_HavalimaniYtsSorgu];
INSERT INTO [dbo].[E_HavalimaniYtsSorgu] ([AyNo], [AyAdi], [Yil2024], [Yil2025], [Yil2026])
VALUES
(1, N'Ocak', 185, 192, 202),
(2, N'Şubat', 128, 142, 115),
(3, N'Mart', 161, 174, 166),
(4, N'Nisan', 159, 204, 166),
(5, N'Mayıs', 183, 240, 141),
(6, N'Haziran', 157, 194, 138),
(7, N'Temmuz', 158, 200, 116),
(8, N'Ağustos', 85, 170, 105),
(9, N'Eylül', 80, 129, 104),
(10, N'Ekim', 107, 131, 0),
(11, N'Kasım', 41, 92, 0),
(12, N'Aralık', 61, 93, 0);
GO

-- 6. CCTV KAMERA ENVANTERİ
TRUNCATE TABLE [dbo].[E_HavalimaniCctvEnvanter];
INSERT INTO [dbo].[E_HavalimaniCctvEnvanter]
([Bolge], [SabitIp], [SabitAnalog], [SabitToplam], [HareketliIp], [HareketliAnalog], [HareketliToplam], [GenelToplam])
VALUES
(N'Terminal Dışı / Çevre', 19, 22, 41, 5, 0, 5, 46),
(N'Terminal İçi Salonlar', 41, 47, 88, 8, 0, 8, 96),
(N'Pist - Apron Sahası', 88, 18, 106, 15, 0, 15, 121),
(N'GENEL TOPLAM', 148, 87, 235, 28, 0, 28, 263);
GO

PRINT 'Havalimanı Brifing ve İstatistik veritabanı kurulumu ve seed işlemi başarıyla tamamlandı.';
GO
