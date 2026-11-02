-- =========================================================================================
-- Script: 11_CREATE_PCINFO_DEVICE_INVENTORY_TABLE.sql
-- Veritabanı: CEZA
-- Modül: PCInfo ve Bilgi İşlem / Donanım Envanter Yönetimi
-- Açıklama: Hudut kapısındaki sunucular, gişe bilgisayarları, pasaport okuyucular,
--           monitörler, IP kameralar ve çevre birimlerinin envanter takip tablosu.
-- =========================================================================================

USE [CEZA];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_PCInfoDevices' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[tbl_PCInfoDevices]
    (
        [Id]                   INT IDENTITY(1,1) NOT NULL,
        [AssetTag]             NVARCHAR(64) NULL,                       -- Demirbaş No (Örn: GZP-EGM-2026-001)
        [Category]             INT NOT NULL DEFAULT 1,                  -- 1: Masaüstü, 2: Laptop, 3: Monitör, 4: Kamera, 5: Pasaport/Optik Okuyucu, 6: Biyometrik, 7: Yazıcı, 8: UPS, 9: Switch/Ağ, 10: Sunucu, 99: Diğer
        [Brand]                NVARCHAR(128) NOT NULL DEFAULT '',       -- Marka / Üretici (HP, Dell, Hikvision, 3M, Regula vb.)
        [Model]                NVARCHAR(128) NOT NULL DEFAULT '',       -- Model Adı
        [SerialNumber]         NVARCHAR(128) NOT NULL DEFAULT '',       -- Seri Numarası
        [Location]             NVARCHAR(256) NOT NULL DEFAULT '',       -- Mevki / Gişe / Kulübe (Örn: Gelen Yolcu Gişe-1, VIP, Büro)
        [RoomNumber]           NVARCHAR(64) NULL,                       -- Oda / Birim No
        [AssignedPerson]       NVARCHAR(128) NULL,                      -- Zimmetli Personel / Sicil
        [ProcurementDate]      DATETIME NULL,                           -- Tedarik Tarihi
        [DeliveryDate]         DATETIME NULL,                           -- Teslim Tarihi
        [WarrantyExpiryDate]   DATETIME NULL,                           -- Garanti Bitiş Tarihi
        [Status]               INT NOT NULL DEFAULT 1,                  -- 1: Kullanımda / Faal, 2: Depoda / Yedek, 3: Arızalı, 4: Hurda
        [IpAddress]            NVARCHAR(64) NULL,                       -- IP Adresi
        [MacAddress]           NVARCHAR(64) NULL,                       -- MAC Adresi
        [ImagePath]            NVARCHAR(500) NULL,                      -- Cihaz Fotoğraf Yolu
        [Notes]                NVARCHAR(2000) NULL,                     -- Notlar / Açıklama
        [TechnicalDetailsJson] NVARCHAR(MAX) NULL,                      -- Detaylı CPU, RAM, Disk, Monitör JSON dökümü
        [CreatedAt]            DATETIME NOT NULL DEFAULT GETDATE(),     -- Kayıt Tarihi
        [UpdatedAt]            DATETIME NOT NULL DEFAULT GETDATE(),     -- Son Güncelleme

        CONSTRAINT [PK_tbl_PCInfoDevices] PRIMARY KEY CLUSTERED ([Id] ASC)
    );

    PRINT 'tbl_PCInfoDevices tablosu basariyla olusturuldu.';
END
ELSE
BEGIN
    PRINT 'tbl_PCInfoDevices tablosu zaten mevcut.';
END
GO

-- İndeksler (Hızlı filtreleme ve sorgulama için)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_PCInfoDevices_AssetTag' AND object_id = OBJECT_ID('dbo.tbl_PCInfoDevices'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_tbl_PCInfoDevices_AssetTag] ON [dbo].[tbl_PCInfoDevices] ([AssetTag] ASC);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_PCInfoDevices_SerialNumber' AND object_id = OBJECT_ID('dbo.tbl_PCInfoDevices'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_tbl_PCInfoDevices_SerialNumber] ON [dbo].[tbl_PCInfoDevices] ([SerialNumber] ASC);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_PCInfoDevices_IpAddress' AND object_id = OBJECT_ID('dbo.tbl_PCInfoDevices'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_tbl_PCInfoDevices_IpAddress] ON [dbo].[tbl_PCInfoDevices] ([IpAddress] ASC);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_PCInfoDevices_Location' AND object_id = OBJECT_ID('dbo.tbl_PCInfoDevices'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_tbl_PCInfoDevices_Location] ON [dbo].[tbl_PCInfoDevices] ([Location] ASC);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tbl_PCInfoDevices_Status_Category' AND object_id = OBJECT_ID('dbo.tbl_PCInfoDevices'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_tbl_PCInfoDevices_Status_Category] ON [dbo].[tbl_PCInfoDevices] ([Status] ASC, [Category] ASC);
END
GO
