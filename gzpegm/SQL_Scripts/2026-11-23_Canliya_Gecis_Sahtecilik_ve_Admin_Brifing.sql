-- ====================================================================================================
-- T.C. İÇİŞLERİ BAKANLIĞI - EMNİYET GENEL MÜDÜRLÜĞÜ
-- GÖÇMEN KAÇAKÇILIĞIYLA MÜCADELE VE HUDUT KAPILARI DAİRE BAŞKANLIĞI
-- GZPCEZA OTOMASYONU - CANLI VERİTABANI GÜNCELLEME BETİĞİ
-- TARİH: 23.11.2026 (Saat 09:00 ve Sonrası Yapılan Tüm Değişiklikler)
-- KAPSAM: 
--   1. E_SahtecilikLog Tablosu ve Denetim İndeksleri (Sahtecilik Geçiş & Belge İnceleme Takibi)
--   2. Yönetici Operasyonel Brifing ve İstatistik Sistemi Performans İndeksleri
--   3. CezaParametre ve E_Duyuru Tabloları Güvenlik Kontrolleri
-- ====================================================================================================

USE [CEZA];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

PRINT '====================================================================================';
PRINT '>>> 23.11.2026 CANLI VERİTABANI GÜNCELLEME İŞLEMLERİ BAŞLATILIYOR...';
PRINT '====================================================================================';
GO

-- ====================================================================================================
-- BÖLÜM 1: SAHTECİLİK DENETİM VE GEÇİŞ LOGLARI (E_SahtecilikLog)
-- ====================================================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'E_SahtecilikLog' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    PRINT '-> [1/3] E_SahtecilikLog tablosu oluşturuluyor...';
    
    CREATE TABLE [dbo].[E_SahtecilikLog]
    (
        [Id]                   INT IDENTITY(1,1) NOT NULL,
        [UserId]               INT NULL,
        [UserSicil]            NVARCHAR(50) NULL,
        [UserName]             NVARCHAR(150) NULL,
        [UserBorder]           NVARCHAR(100) NULL,
        [KaynakSayfa]          NVARCHAR(50) NOT NULL, -- 'Hesaplama', 'UserBox', 'Yardımcı', 'Sahtecilik Portalı', 'SSO'
        [IslemTipi]            NVARCHAR(50) NOT NULL, -- 'Portal Geçişi', 'Belge İnceleme', 'Arama & Filtreleme'
        [SecilenUlke]          NVARCHAR(100) NULL,
        [IncelenenBelgeId]     INT NULL,
        [IncelenenBelgeBaslik] NVARCHAR(300) NULL,
        [IslemTarihi]          DATETIME NOT NULL CONSTRAINT [DF_E_SahtecilikLog_IslemTarihi] DEFAULT (GETDATE()),
        [IpAddress]            NVARCHAR(50) NULL,
        [HedefUrl]             NVARCHAR(500) NULL,
        [Detay]                NVARCHAR(1000) NULL,
        CONSTRAINT [PK_E_SahtecilikLog] PRIMARY KEY CLUSTERED ([Id] ASC)
    );
    
    PRINT '✓ E_SahtecilikLog tablosu başarıyla oluşturuldu.';
END
ELSE
BEGIN
    PRINT '-> [1/3] E_SahtecilikLog tablosu zaten mevcut.';
END
GO

-- E_SahtecilikLog İndeksleri
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SahtecilikLog_Tarih' AND object_id = OBJECT_ID('dbo.E_SahtecilikLog'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_SahtecilikLog_Tarih] 
    ON [dbo].[E_SahtecilikLog] ([IslemTarihi] DESC)
    INCLUDE ([UserSicil], [KaynakSayfa], [IslemTipi], [SecilenUlke]);
    PRINT '✓ IX_SahtecilikLog_Tarih indeksi oluşturuldu.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SahtecilikLog_Sicil' AND object_id = OBJECT_ID('dbo.E_SahtecilikLog'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_SahtecilikLog_Sicil] 
    ON [dbo].[E_SahtecilikLog] ([UserSicil] ASC)
    INCLUDE ([IslemTarihi], [KaynakSayfa]);
    PRINT '✓ IX_SahtecilikLog_Sicil indeksi oluşturuldu.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SahtecilikLog_Kaynak' AND object_id = OBJECT_ID('dbo.E_SahtecilikLog'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_SahtecilikLog_Kaynak] 
    ON [dbo].[E_SahtecilikLog] ([KaynakSayfa] ASC, [IslemTipi] ASC)
    INCLUDE ([IslemTarihi]);
    PRINT '✓ IX_SahtecilikLog_Kaynak indeksi oluşturuldu.';
END
GO


-- ====================================================================================================
-- BÖLÜM 2: YÖNETİCİ OPERASYONEL BRİFİNG VE İSTATİSTİK RAPORLAMA İNDEKSLERİ
-- (24 Saatlik, Saatlik, Günlük, Haftalık, Aylık, Yıllık Anlık Sorgu Performansı İçin)
-- ====================================================================================================
PRINT '-> [2/3] Operasyonel Brifing performans indeksleri doğrulanıyor...';
GO

-- 1. E_History (Ceza Hesaplama Geçmişi)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_E_History_fldDatetime' AND object_id = OBJECT_ID('dbo.E_History'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_E_History_fldDatetime] 
    ON [dbo].[E_History] ([fldDatetime] DESC)
    INCLUDE ([fldCountry], [fldBorder], [fldPMoney], [fldUser]);
    PRINT '✓ IX_E_History_fldDatetime indeksi oluşturuldu.';
END
GO

-- 2. E_IsK (Ceza Form / Tutanak Kayıtları)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_E_IsK_fldDatetime' AND object_id = OBJECT_ID('dbo.E_IsK'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_E_IsK_fldDatetime] 
    ON [dbo].[E_IsK] ([fldDatetime] DESC)
    INCLUDE ([fldForm], [fldOrgin], [fldBorder], [fldApproval]);
    PRINT '✓ IX_E_IsK_fldDatetime indeksi oluşturuldu.';
END
GO

-- 3. TahditFormLog (Tahdit Tutanak Çıkartma Logları)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_TahditFormLog_CreatedAt' AND object_id = OBJECT_ID('dbo.TahditFormLog'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_TahditFormLog_CreatedAt] 
    ON [dbo].[TahditFormLog] ([CreatedAt] DESC)
    INCLUDE ([TahditCode], [Country], [Border], [UserSicil]);
    PRINT '✓ IX_TahditFormLog_CreatedAt indeksi oluşturuldu.';
END
GO

-- 4. E_Sartli (V-84 Şartlı Vize Girişleri)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_E_Sartli_fldDate' AND object_id = OBJECT_ID('dbo.E_Sartli'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_E_Sartli_fldDate] 
    ON [dbo].[E_Sartli] ([fldDate] DESC)
    INCLUDE ([fldOrgin], [fldBorder], [fldBy]);
    PRINT '✓ IX_E_Sartli_fldDate indeksi oluşturuldu.';
END
GO

-- 5. E_Inad (İnad Yolcu İşlemleri)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_E_Inad_TarihSaat' AND object_id = OBJECT_ID('dbo.E_Inad'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_E_Inad_TarihSaat] 
    ON [dbo].[E_Inad] ([TarihSaat] DESC)
    INCLUDE ([Uyruk], [Kapi], [Durum], [GelenHavayolu]);
    PRINT '✓ IX_E_Inad_TarihSaat indeksi oluşturuldu.';
END
GO

-- 6. CourseEnrollments (Eğitim Kurs Kayıtları)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_CourseEnrollments_Date' AND object_id = OBJECT_ID('dbo.CourseEnrollments'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_CourseEnrollments_Date] 
    ON [dbo].[CourseEnrollments] ([EnrollmentDate] DESC)
    INCLUDE ([CourseId], [UserId]);
    PRINT '✓ IX_CourseEnrollments_Date indeksi oluşturuldu.';
END
GO

-- 7. ExamResult (Sınav Tamamlama Sonuçları)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ExamResult_FinishedAt' AND object_id = OBJECT_ID('dbo.ExamResult'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_ExamResult_FinishedAt] 
    ON [dbo].[ExamResult] ([FinishedAt] DESC)
    INCLUDE ([ExamId], [UserId], [Score], [Status]);
    PRINT '✓ IX_ExamResult_FinishedAt indeksi oluşturuldu.';
END
GO

-- 8. PasswordResetRequests (Şifre Sıfırlama Talepleri)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PasswordResetRequests_RequestedAt' AND object_id = OBJECT_ID('dbo.PasswordResetRequests'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_PasswordResetRequests_RequestedAt] 
    ON [dbo].[PasswordResetRequests] ([RequestedAt] DESC)
    INCLUDE ([UserId], [Status], [ApprovedAt]);
    PRINT '✓ IX_PasswordResetRequests_RequestedAt indeksi oluşturuldu.';
END
GO


-- ====================================================================================================
-- BÖLÜM 3: PARAMETRE VE DUYURU TABLOLARI KONTROLÜ (Gerekiyorsa Oluşturma)
-- ====================================================================================================
PRINT '-> [3/3] Parametre ve Duyuru tabloları kontrol ediliyor...';
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CezaParametre' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[CezaParametre]
    (
        [ParamKey]         NVARCHAR(50) NOT NULL PRIMARY KEY,
        [ParamValue]       NVARCHAR(500) NOT NULL,
        [ParamTitle]       NVARCHAR(150) NOT NULL,
        [ParamDescription] NVARCHAR(500) NULL,
        [ParamGroup]       NVARCHAR(50) NULL,
        [UpdatedAt]        DATETIME NOT NULL CONSTRAINT [DF_CezaParametre_UpdatedAt] DEFAULT (GETDATE()),
        [UpdatedBy]        NVARCHAR(50) NULL
    );
    PRINT '✓ CezaParametre tablosu oluşturuldu.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'E_Duyuru' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[E_Duyuru]
    (
        [Id]               INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [Baslik]           NVARCHAR(200) NOT NULL,
        [Icerik]           NVARCHAR(MAX) NOT NULL,
        [Kategori]         NVARCHAR(50) NOT NULL CONSTRAINT [DF_E_Duyuru_Kategori] DEFAULT ('Genel'),
        [Oncelik]          INT NOT NULL CONSTRAINT [DF_E_Duyuru_Oncelik] DEFAULT (1),
        [OlusturanUserId]  INT NULL,
        [OlusturanAd]      NVARCHAR(100) NULL,
        [OlusturanSicil]   NVARCHAR(50) NULL,
        [OlusturanRol]     NVARCHAR(50) NULL,
        [Tarih]            DATETIME NOT NULL CONSTRAINT [DF_E_Duyuru_Tarih] DEFAULT (GETDATE()),
        [Aktif]            BIT NOT NULL CONSTRAINT [DF_E_Duyuru_Aktif] DEFAULT (1),
        [GecerlilikTarihi] DATETIME NULL
    );
    PRINT '✓ E_Duyuru tablosu oluşturuldu.';
END
GO


-- ====================================================================================================
-- BÖLÜM 4: DOĞRULAMA VE ÖZET RAPORU
-- ====================================================================================================
PRINT '====================================================================================';
PRINT '>>> CANLI VERİTABANI GÜNCELLEMESİ BAŞARIYLA TAMAMLANDI!';
PRINT '====================================================================================';

SELECT 
    t.name AS [Tablo Adi],
    COUNT(i.index_id) AS [Toplam Indeks Sayisi]
FROM sys.tables t
LEFT JOIN sys.indexes i ON t.object_id = i.object_id
WHERE t.name IN ('E_SahtecilikLog', 'E_History', 'E_IsK', 'TahditFormLog', 'E_Sartli', 'E_Inad', 'CourseEnrollments', 'ExamResult', 'PasswordResetRequests', 'CezaParametre', 'E_Duyuru')
GROUP BY t.name
ORDER BY t.name;
GO
