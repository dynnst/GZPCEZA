-- =========================================================================
-- E_Inad Tablosu Kolon Doğrulama ve Eksik Kolon Ekleme Scripti
-- Tarih: 11.11.2026
-- Açıklama: E_Inad tablosunda gerekli alanların varlığını kontrol eder,
--           eksik olanları veri kaybı olmadan güvenli bir şekilde ekler.
-- =========================================================================

USE [GZP_PORTAL]; -- Gerekirse veritabanı adınızı buraya göre güncelleyebilirsiniz.
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

PRINT '---------------------------------------------------------';
PRINT 'E_Inad tablosu kolon doğrulama işlemi başlatılıyor...';
PRINT '---------------------------------------------------------';

-- Tablonun varlığını kontrol et
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'E_Inad')
BEGIN
    PRINT '[HATA] E_Inad tablosu veritabanında bulunamadı!';
END
ELSE
BEGIN
    -- 1. Sicil kolonu (Tespit eden personel sicili)
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'E_Inad' AND COLUMN_NAME = 'Sicil')
    BEGIN
        ALTER TABLE [dbo].[E_Inad] ADD [Sicil] NVARCHAR(50) NULL;
        PRINT '-> [Sicil] kolonu eklendi.';
    END
    ELSE
    BEGIN
        PRINT 'OK: [Sicil] kolonu zaten mevcut.';
    END

    -- 2. Beyan kolonu (Beyan esası)
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'E_Inad' AND COLUMN_NAME = 'Beyan')
    BEGIN
        ALTER TABLE [dbo].[E_Inad] ADD [Beyan] NVARCHAR(250) NULL;
        PRINT '-> [Beyan] kolonu eklendi.';
    END
    ELSE
    BEGIN
        PRINT 'OK: [Beyan] kolonu zaten mevcut.';
    END

    -- 3. Refakat kolonu (Refakat durumu)
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'E_Inad' AND COLUMN_NAME = 'Refakat')
    BEGIN
        ALTER TABLE [dbo].[E_Inad] ADD [Refakat] NVARCHAR(100) NULL;
        PRINT '-> [Refakat] kolonu eklendi.';
    END
    ELSE
    BEGIN
        PRINT 'OK: [Refakat] kolonu zaten mevcut.';
    END

    -- 4. OzelGuvenlik kolonu
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'E_Inad' AND COLUMN_NAME = 'OzelGuvenlik')
    BEGIN
        ALTER TABLE [dbo].[E_Inad] ADD [OzelGuvenlik] NVARCHAR(150) NULL;
        PRINT '-> [OzelGuvenlik] kolonu eklendi.';
    END
    ELSE
    BEGIN
        PRINT 'OK: [OzelGuvenlik] kolonu zaten mevcut.';
    END

    -- 5. YerHizmetleriPersonel kolonu
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'E_Inad' AND COLUMN_NAME = 'YerHizmetleriPersonel')
    BEGIN
        ALTER TABLE [dbo].[E_Inad] ADD [YerHizmetleriPersonel] NVARCHAR(150) NULL;
        PRINT '-> [YerHizmetleriPersonel] kolonu eklendi.';
    END
    ELSE
    BEGIN
        PRINT 'OK: [YerHizmetleriPersonel] kolonu zaten mevcut.';
    END

    -- 6. YerHizmetleri (Firma) kolonu
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'E_Inad' AND COLUMN_NAME = 'YerHizmetleri')
    BEGIN
        ALTER TABLE [dbo].[E_Inad] ADD [YerHizmetleri] NVARCHAR(150) NULL;
        PRINT '-> [YerHizmetleri] kolonu eklendi.';
    END
    ELSE
    BEGIN
        PRINT 'OK: [YerHizmetleri] kolonu zaten mevcut.';
    END

    -- 7. UcagaNakil (Sevk / Nakil Şekli) kolonu
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'E_Inad' AND COLUMN_NAME = 'UcagaNakil')
    BEGIN
        ALTER TABLE [dbo].[E_Inad] ADD [UcagaNakil] NVARCHAR(250) NULL;
        PRINT '-> [UcagaNakil] kolonu eklendi.';
    END
    ELSE
    BEGIN
        PRINT 'OK: [UcagaNakil] kolonu zaten mevcut.';
    END

    -- 8. UstAramaEsya kolonu
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'E_Inad' AND COLUMN_NAME = 'UstAramaEsya')
    BEGIN
        ALTER TABLE [dbo].[E_Inad] ADD [UstAramaEsya] NVARCHAR(MAX) NULL;
        PRINT '-> [UstAramaEsya] kolonu eklendi.';
    END
    ELSE
    BEGIN
        PRINT 'OK: [UstAramaEsya] kolonu zaten mevcut.';
    END

    -- 9. KimlikNo kolonu
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'E_Inad' AND COLUMN_NAME = 'KimlikNo')
    BEGIN
        ALTER TABLE [dbo].[E_Inad] ADD [KimlikNo] NVARCHAR(50) NULL;
        PRINT '-> [KimlikNo] kolonu eklendi.';
    END
    ELSE
    BEGIN
        PRINT 'OK: [KimlikNo] kolonu zaten mevcut.';
    END

    PRINT '---------------------------------------------------------';
    PRINT '[BAŞARILI] E_Inad tablosu tüm kolonları doğrulandı ve güncellendi.';
    PRINT '---------------------------------------------------------';
END
GO
