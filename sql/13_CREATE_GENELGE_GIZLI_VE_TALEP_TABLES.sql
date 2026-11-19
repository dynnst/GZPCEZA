-- =========================================================================================
-- Script: 13_CREATE_GENELGE_GIZLI_VE_TALEP_TABLES.sql
-- Veritabanı: CEZA
-- Modül: Genelgeler & Mevzuat Bilgi Bankası (Gizli Belge ve Erişim İzin Yönetimi)
-- Tarih: 18 Kasım 2026
-- Açıklama: 
--   1. E_GenelgeGizli: Yönetici tarafından 'Gizli / Hizmete Özel' işaretlenen belgeler.
--   2. E_GenelgeTalep: Personelin gizli belgelere erişebilmek için açtığı talep ve
--                      yöneticinin verdiği süreli (24 saat) veya süresiz onay kayıtları.
-- =========================================================================================

USE [CEZA];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Gizli Olarak İşaretlenen Belgeler Tablosu
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'E_GenelgeGizli' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[E_GenelgeGizli]
    (
        [Id]               INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [ItemIdentifier]   NVARCHAR(300) NOT NULL UNIQUE,          -- Klasör yolu veya dosya göreli yolu
        [IsConfidential]   BIT NOT NULL DEFAULT 1,                 -- 1: Gizli, 0: Açık
        [MarkedByUserId]   INT NULL,                               -- İşaretleyen Yönetici / Eğitimci User ID
        [MarkedDate]       DATETIME NOT NULL DEFAULT GETDATE(),    -- İşaretlenme Tarihi
        [Note]             NVARCHAR(500) NULL                      -- Açıklama / Gerekçe Notu
    );
    PRINT '>> E_GenelgeGizli tablosu basariyla olusturuldu.';
END
ELSE
BEGIN
    PRINT '>> E_GenelgeGizli tablosu zaten mevcut.';
END
GO

-- 2. Gizli Belge Erişim Talep ve Onay Tablosu
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'E_GenelgeTalep' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[E_GenelgeTalep]
    (
        [Id]               INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [ItemIdentifier]   NVARCHAR(300) NOT NULL,                 -- Talep edilen belgenin yolu
        [ItemTitle]        NVARCHAR(500) NOT NULL,                 -- Belge başlığı
        [UserId]           INT NOT NULL,                           -- Talep eden Personel User ID
        [UserSicil]        NVARCHAR(50) NULL,                      -- Personel Sicili
        [UserName]         NVARCHAR(150) NULL,                     -- Personel Adı Soyadı
        [RequestDate]      DATETIME NOT NULL DEFAULT GETDATE(),    -- Talep Tarihi
        [Reason]           NVARCHAR(1000) NULL,                    -- Görev Gerekçesi / Notu
        [Status]           NVARCHAR(30) NOT NULL DEFAULT 'Bekliyor', -- 'Bekliyor', 'Onaylandi', 'Reddedildi'
        [ReviewedByUserId] INT NULL,                               -- Onaylayan / Reddeden Yönetici ID
        [ReviewDate]       DATETIME NULL,                          -- Onay / Ret Tarihi
        [ExpiryDate]       DATETIME NULL,                          -- İzin Bitiş Tarihi (NULL: Süresiz, Dolu: 24 saat vb.)
        [ReviewNote]       NVARCHAR(500) NULL                      -- Yönetici Karar Notu
    );

    CREATE INDEX [IX_GenelgeTalep_User] ON [dbo].[E_GenelgeTalep]([UserId], [ItemIdentifier], [Status]);
    CREATE INDEX [IX_GenelgeTalep_Status] ON [dbo].[E_GenelgeTalep]([Status]);
    PRINT '>> E_GenelgeTalep tablosu ve indeksleri basariyla olusturuldu.';
END
ELSE
BEGIN
    PRINT '>> E_GenelgeTalep tablosu zaten mevcut.';
END
GO
