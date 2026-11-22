-- =========================================================================================
-- Script: CANLI_ORTAM_TOPLU_GUNCELLEME_2026.sql
-- Veritabanı: CEZA (Canlı / Production Ortamı)
-- Tarih: 22 Kasım 2026
-- Amaç:
--   Canlı ortamdaki CEZA veritabanında henüz bulunmayan veya eksik olabilecek
--   yeni modül tablolarını (Duyuru, Gizli Genelge/Talep, Ceza Parametreleri)
--   tek seferde, güvenli ve idempotent (var olan verilere ASLA zarar vermeden) günceller.
--
-- Kapsam:
--   1. E_Duyuru (Operasyonel Bilgi & Duyuru Paneli)
--   2. E_GenelgeGizli (Gizli Belge Kilit Sistemi)
--   3. E_GenelgeTalep (Gizli Belge Erişim İzin Talep & Yönetim Sistemi)
--   4. CezaParametre (Dinamik Ceza, Harç ve Ülke Sınıflandırma Parametreleri)
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

PRINT '================================================================';
PRINT 'CEZA VERITABANI - CANLI ORTAM GUNCELLEMESI BASLATILIYOR...';
PRINT '================================================================';
GO

-- -----------------------------------------------------------------------------------------
-- 1. E_Duyuru Tablosu
-- -----------------------------------------------------------------------------------------
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

    PRINT '>> [OK] 1. E_Duyuru tablosu ve baslangic kayitlari olusturuldu.';
END
ELSE
BEGIN
    PRINT '>> [ATLANDI] 1. E_Duyuru tablosu zaten mevcut.';
END
GO

-- -----------------------------------------------------------------------------------------
-- 2. E_GenelgeGizli Tablosu
-- -----------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'E_GenelgeGizli' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[E_GenelgeGizli]
    (
        [Id]               INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [ItemIdentifier]   NVARCHAR(300)     NOT NULL UNIQUE,
        [IsConfidential]   BIT               NOT NULL DEFAULT 1,
        [MarkedByUserId]   INT               NULL,
        [MarkedDate]       DATETIME          NOT NULL DEFAULT GETDATE(),
        [Note]             NVARCHAR(500)     NULL
    );

    PRINT '>> [OK] 2. E_GenelgeGizli tablosu olusturuldu.';
END
ELSE
BEGIN
    PRINT '>> [ATLANDI] 2. E_GenelgeGizli tablosu zaten mevcut.';
END
GO

-- -----------------------------------------------------------------------------------------
-- 3. E_GenelgeTalep Tablosu
-- -----------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'E_GenelgeTalep' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[E_GenelgeTalep]
    (
        [Id]               INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [ItemIdentifier]   NVARCHAR(300)     NOT NULL,
        [ItemTitle]        NVARCHAR(500)     NOT NULL,
        [UserId]           INT               NOT NULL,
        [UserSicil]        NVARCHAR(50)      NULL,
        [UserName]         NVARCHAR(150)     NULL,
        [RequestDate]      DATETIME          NOT NULL DEFAULT GETDATE(),
        [Reason]           NVARCHAR(1000)    NULL,
        [Status]           NVARCHAR(30)      NOT NULL DEFAULT 'Bekliyor',
        [ReviewedByUserId] INT               NULL,
        [ReviewDate]       DATETIME          NULL,
        [ExpiryDate]       DATETIME          NULL,
        [ReviewNote]       NVARCHAR(500)     NULL
    );

    CREATE NONCLUSTERED INDEX [IX_GenelgeTalep_User] ON [dbo].[E_GenelgeTalep]([UserId], [ItemIdentifier], [Status]);
    CREATE NONCLUSTERED INDEX [IX_GenelgeTalep_Status] ON [dbo].[E_GenelgeTalep]([Status]);

    PRINT '>> [OK] 3. E_GenelgeTalep tablosu ve indeksleri olusturuldu.';
END
ELSE
BEGIN
    PRINT '>> [ATLANDI] 3. E_GenelgeTalep tablosu zaten mevcut.';
END
GO

-- -----------------------------------------------------------------------------------------
-- 4. CezaParametre Tablosu
-- -----------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CezaParametre' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[CezaParametre] (
        [ParamKey]         NVARCHAR(50)   NOT NULL PRIMARY KEY,
        [ParamValue]       NVARCHAR(MAX)  NOT NULL,
        [ParamTitle]       NVARCHAR(150)  NOT NULL,
        [ParamDescription] NVARCHAR(500)  NULL,
        [ParamGroup]       NVARCHAR(50)   NOT NULL,
        [UpdatedAt]        DATETIME       NOT NULL DEFAULT GETDATE(),
        [UpdatedBy]        NVARCHAR(100)  NULL
    );

    PRINT '>> [OK] 4. CezaParametre tablosu olusturuldu.';
END
ELSE
BEGIN
    PRINT '>> [ATLANDI] 4. CezaParametre tablosu zaten mevcut.';
END
GO

PRINT '================================================================';
PRINT 'CANLI ORTAM GUNCELLEMESI BASARIYLA TAMAMLANDI.';
PRINT '================================================================';
GO
