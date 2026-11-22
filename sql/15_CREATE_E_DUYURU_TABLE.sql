-- =========================================================================================
-- Script: 15_CREATE_E_DUYURU_TABLE.sql
-- Veritabanı: CEZA (Canlı veya Geliştirme Ortamı)
-- Modül: Operasyonel Bilgi & Duyuru Paneli (Admin & Öğretmen Duyuru Yönetimi)
-- Tarih: 22 Kasım 2026
-- Açıklama:
--   Hudut kapısı personeli için operasyonel bildirimler, mevzuat duyuruları,
--   eğitim ve acil duyuruların saklandığı 'E_Duyuru' tablosunu oluşturur.
--   Yalnızca Admin (Yetki 2) ve Öğretmenler (Yetki 6) duyuru yayınlayıp silebilir.
--   Bu betik güvenlidir (idempotent); mevcut tablolara ve verilere ASLA zarar vermez.
-- =========================================================================================

IF DB_ID('CEZA') IS NOT NULL
BEGIN
    USE [CEZA];
END
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- 1. E_Duyuru Tablosunun Kontrolü ve Oluşturulması
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'E_Duyuru' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[E_Duyuru]
    (
        [Id]               INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [Baslik]           NVARCHAR(250)     NOT NULL,
        [Icerik]           NVARCHAR(MAX)     NOT NULL,
        [Kategori]         NVARCHAR(50)      NOT NULL DEFAULT 'Genel',    -- 'Genel', 'Onemli', 'Acil', 'Mevzuat', 'Egitim'
        [Oncelik]          INT               NOT NULL DEFAULT 1,          -- 1: Standart, 2: Önemli, 3: Acil / Flaş
        [OlusturanUserId]  INT               NULL,                        -- Oluşturan Personel User ID
        [OlusturanAd]      NVARCHAR(150)     NOT NULL,                    -- Oluşturan Adı Soyadı
        [OlusturanSicil]   NVARCHAR(50)      NULL,                        -- Oluşturan Sicili
        [OlusturanRol]     NVARCHAR(50)      NULL,                        -- 'Sistem Yöneticisi (Admin)', 'Eğitim Birimi (Öğretmen)'
        [Tarih]            DATETIME          NOT NULL DEFAULT GETDATE(),  -- Yayın Tarihi
        [Aktif]            BIT               NOT NULL DEFAULT 1,          -- 1: Yayında, 0: Kaldırıldı (Soft Delete)
        [GecerlilikTarihi] DATETIME          NULL                         -- Opsiyonel Son Geçerlilik Tarihi
    );

    PRINT '>> [BASARILI] E_Duyuru tablosu basariyla olusturuldu.';
END
ELSE
BEGIN
    PRINT '>> [BILGI] E_Duyuru tablosu zaten mevcut.';
END
GO

-- 2. Performans İndeksinin Oluşturulması (Aktif ve Tarih Sıralaması)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_E_Duyuru_Aktif_Tarih' AND object_id = OBJECT_ID('dbo.E_Duyuru'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_E_Duyuru_Aktif_Tarih]
    ON [dbo].[E_Duyuru] ([Aktif], [Tarih] DESC)
    INCLUDE ([Baslik], [Kategori], [Oncelik], [OlusturanAd], [OlusturanRol]);

    PRINT '>> [BASARILI] IX_E_Duyuru_Aktif_Tarih indeksi olusturuldu.';
END
GO

-- 3. Başlangıç Operasyonel Duyurularının Güvenle Yüklenmesi
IF (SELECT COUNT(*) FROM [dbo].[E_Duyuru] WHERE [Aktif] = 1) = 0
BEGIN
    INSERT INTO [dbo].[E_Duyuru] 
        ([Baslik], [Icerik], [Kategori], [Oncelik], [OlusturanAd], [OlusturanRol], [Tarih], [Aktif])
    VALUES 
    (N'2026 Yılı Mali Harç ve İdari Para Cezası Tarifesi Yürürlüktedir',
     N'2026 yılı için yeniden değerleme oranı (%25,49) sonrasında vize ve ikamet ihlali harçları güncellenmiştir. 1-90 gün günlük harç 467,60 TL, defter bedeli 1.345,00 TL ve 5326 s.K. m.32 idari para cezası 1.854,00 TL olarak uygulanacaktır.',
     N'Mevzuat', 3, N'Sistem Yöneticisi', N'Sistem Yöneticisi (Admin)', GETDATE(), 1),

    (N'Tahdit Kodları ve Şartlı Vize (V-84) İşlemleri Uygulama Esasları',
     N'Hudut kapılarımızda yolcu giriş ve çıkış işlemlerinde tahdit kodlarına ilişkin şerhlerin hassasiyetle kontrol edilmesi, V-84 taahhüt belgelerinin eksiksiz tanzim edilmesi gerekmektedir.',
     N'Genel', 2, N'Eğitim Birimi', N'Eğitim Birimi (Öğretmen)', DATEADD(MINUTE, -30, GETDATE()), 1);

    PRINT '>> [BASARILI] Baslangic duyurulari sisteme yuklendi.';
END
ELSE
BEGIN
    PRINT '>> [BILGI] E_Duyuru tablosunda kayit bulundugu icin varsayilan duyuru yuklemesi atlandi.';
END
GO
