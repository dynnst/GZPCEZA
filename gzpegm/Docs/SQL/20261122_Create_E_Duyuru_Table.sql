-- =========================================================================================
-- Script: 20261122_Create_E_Duyuru_Table.sql
-- Veritabanı: CEZA
-- Modül: Operasyonel Bilgi & Duyuru Paneli (Admin & Öğretmen Duyuru Yönetimi)
-- Tarih: 22 Kasım 2026
-- =========================================================================================

IF DB_ID('CEZA') IS NOT NULL
BEGIN
    USE [CEZA];
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'E_Duyuru' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[E_Duyuru]
    (
        [Id]               INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [Baslik]           NVARCHAR(250)     NOT NULL,
        [Icerik]           NVARCHAR(MAX)     NOT NULL,
        [Kategori]         NVARCHAR(50)      NOT NULL DEFAULT 'Genel',
        [Oncelik]          INT               NOT NULL DEFAULT 1,
        [OlusturanUserId]  INT               NULL,
        [OlusturanAd]      NVARCHAR(150)     NOT NULL,
        [OlusturanSicil]   NVARCHAR(50)      NULL,
        [OlusturanRol]     NVARCHAR(50)      NULL,
        [Tarih]            DATETIME          NOT NULL DEFAULT GETDATE(),
        [Aktif]            BIT               NOT NULL DEFAULT 1,
        [GecerlilikTarihi] DATETIME          NULL
    );

    CREATE NONCLUSTERED INDEX [IX_E_Duyuru_Aktif_Tarih]
    ON [dbo].[E_Duyuru] ([Aktif], [Tarih] DESC)
    INCLUDE ([Baslik], [Kategori], [Oncelik], [OlusturanAd], [OlusturanRol]);

    INSERT INTO [dbo].[E_Duyuru] 
        ([Baslik], [Icerik], [Kategori], [Oncelik], [OlusturanAd], [OlusturanRol], [Tarih], [Aktif])
    VALUES 
    (N'2026 Yılı Mali Harç ve İdari Para Cezası Tarifesi Yürürlüktedir',
     N'2026 yılı için yeniden değerleme oranı (%25,49) sonrasında vize ve ikamet ihlali harçları güncellenmiştir. 1-90 gün günlük harç 467,60 TL, defter bedeli 1.345,00 TL ve 5326 s.K. m.32 idari para cezası 1.854,00 TL olarak uygulanacaktır.',
     N'Mevzuat', 3, N'Sistem Yöneticisi', N'Sistem Yöneticisi (Admin)', GETDATE(), 1),

    (N'Tahdit Kodları ve Şartlı Vize (V-84) İşlemleri Uygulama Esasları',
     N'Hudut kapılarımızda yolcu giriş ve çıkış işlemlerinde tahdit kodlarına ilişkin şerhlerin hassasiyetle kontrol edilmesi, V-84 taahhüt belgelerinin eksiksiz tanzim edilmesi gerekmektedir.',
     N'Genel', 2, N'Eğitim Birimi', N'Eğitim Birimi (Öğretmen)', DATEADD(MINUTE, -30, GETDATE()), 1);

    PRINT '>> [BASARILI] E_Duyuru tablosu basariyla olusturuldu.';
END
ELSE
BEGIN
    PRINT '>> [BILGI] E_Duyuru tablosu zaten mevcut.';
END
GO
