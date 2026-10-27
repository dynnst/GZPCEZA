/*
====================================================================================================
    CEZAM - E_History ve E_IsK Mükerrer Kayıtları Güvenle Temizleme Scripti
====================================================================================================
    Hedef : 10.7.202.75 (veya Yerel CEZA Veritabanı)
    Amaç  : HIST istatistik ekranındaki mükerrer kayıtları ve şişmiş istatistikleri düzeltir.
    Mantık: Aynı dakika içinde, aynı kullanıcı, aynı ülke, kapı, doğum tarihi, giriş-çıkış
            tarihleri, ceza süresi ve tutarla eklenmiş mükerrer kopyaları temizler.
            Her işlemin İLK ORİJİNAL kaydı (en küçük fldId) KORUNUR.
====================================================================================================
*/

USE [CEZA];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

PRINT N'====================================================================================';
PRINT N'  CEZAM - MÜKERRER KAYIT TEMİZLEME İŞLEMİ BAŞLADI';
PRINT N'====================================================================================';

-- 1. E_History TABLOSU MÜKERRER TEMİZLİĞİ
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @HistoryBefore INT = 0;
    DECLARE @HistoryAfter INT = 0;
    DECLARE @HistoryDeleted INT = 0;

    SELECT @HistoryBefore = COUNT(*) FROM dbo.E_History;

    ;WITH CTE_History AS
    (
        SELECT 
            fldId,
            ROW_NUMBER() OVER 
            (
                PARTITION BY 
                    CAST(fldDatetime AS DATE),
                    DATEPART(hour, fldDatetime),
                    DATEPART(minute, fldDatetime),
                    ISNULL(CAST(fldUser AS NVARCHAR(250)), N''),
                    ISNULL(fldStart, '1900-01-01'),
                    ISNULL(fldShouldExit, '1900-01-01'),
                    ISNULL(fldBirthDate, '1900-01-01'),
                    ISNULL(CAST(fldCountry AS NVARCHAR(250)), N''),
                    ISNULL(CAST(fldPenalty AS NVARCHAR(500)), N''),
                    ISNULL(CAST(fldPMoney AS NVARCHAR(100)), N''),
                    ISNULL(CAST(fldBorder AS NVARCHAR(250)), N'')
                ORDER BY fldId ASC -- En küçük fldId orijinal kabul edilir ve KORUNUR
            ) AS RowNum
        FROM dbo.E_History
    )
    DELETE FROM CTE_History
    WHERE RowNum > 1;

    SET @HistoryDeleted = @@ROWCOUNT;
    SELECT @HistoryAfter = COUNT(*) FROM dbo.E_History;

    COMMIT TRANSACTION;

    PRINT N'';
    PRINT N'[1/2] E_History TABLOSU:';
    PRINT N'   -> Temizleme Öncesi Toplam Kayıt : ' + CAST(@HistoryBefore AS NVARCHAR(10));
    PRINT N'   -> SİLİNEN Mükerrer Kopya Sayısı : ' + CAST(@HistoryDeleted AS NVARCHAR(10));
    PRINT N'   -> Kalan Orijinal Kayıt Sayısı   : ' + CAST(@HistoryAfter AS NVARCHAR(10));
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT N'[HATA - E_History] ' + ERROR_MESSAGE();
END CATCH;

-- 2. E_IsK TABLOSU MÜKERRER TEMİZLİĞİ
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @IsKBefore INT = 0;
    DECLARE @IsKAfter INT = 0;
    DECLARE @IsKDeleted INT = 0;

    SELECT @IsKBefore = COUNT(*) FROM dbo.E_IsK;

    ;WITH CTE_IsK AS
    (
        SELECT 
            fldId,
            ROW_NUMBER() OVER 
            (
                PARTITION BY 
                    ISNULL(fldDatetime, '1900-01-01'),
                    ISNULL(LTRIM(RTRIM(CAST(fldPassport AS NVARCHAR(100)))), N''),
                    ISNULL(LTRIM(RTRIM(CAST(fldName AS NVARCHAR(250)))), N''),
                    ISNULL(fldBirthdate, '1900-01-01'),
                    ISNULL(CAST(fldBorder AS NVARCHAR(100)), N'')
                ORDER BY fldId ASC
            ) AS RowNum
        FROM dbo.E_IsK
    )
    DELETE FROM CTE_IsK
    WHERE RowNum > 1;

    SET @IsKDeleted = @@ROWCOUNT;
    SELECT @IsKAfter = COUNT(*) FROM dbo.E_IsK;

    COMMIT TRANSACTION;

    PRINT N'';
    PRINT N'[2/2] E_IsK TABLOSU:';
    PRINT N'   -> Temizleme Öncesi Toplam Kayıt : ' + CAST(@IsKBefore AS NVARCHAR(10));
    PRINT N'   -> SİLİNEN Mükerrer Kopya Sayısı : ' + CAST(@IsKDeleted AS NVARCHAR(10));
    PRINT N'   -> Kalan Orijinal Kayıt Sayısı   : ' + CAST(@IsKAfter AS NVARCHAR(10));
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT N'[HATA - E_IsK] ' + ERROR_MESSAGE();
END CATCH;

PRINT N'';
PRINT N'====================================================================================';
PRINT N'  MÜKERRER TEMİZLİĞİ TAMAMLANDI! TÜM FAZLA KOPYALAR SİLİNDİ, HER KAYIT TEKE İNDİRİLDİ.';
PRINT N'====================================================================================';
GO
