/*
====================================================================================================
    CEZAM - 10.7.202.75 (Ana Sunucu) Mükerrer E_History ve E_IsK Kayıtlarını Temizleme Scripti
====================================================================================================
    Hedef Sunucu : 10.7.202.75 (veya ANTHGZPSUNUCU\CEZA)
    Veritabanı   : CEZA
    Amaç         : 76 sunucusundan mükerrer (3 kez vb.) çekilmiş olan kayıtları tespit edip,
                   her gruptan sadece 1 adet orijinal kaydı tutup fazla kopyaları silmek.

    KULLANIM TALİMATI:
      1. @DryRun = 1 iken script SİLME YAPMAZ. Kaç adet mükerrer kayıt olduğunu analiz eder.
      2. Sonuçları görüp emin olduktan sonra @DryRun = 0 yaparak gerçek silmeyi icra edebilirsiniz.
====================================================================================================
*/

USE [CEZA];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @DryRun BIT = 1; -- 1 = Sadece Raporla / Test Et, 0 = Gerçekten Sil!

PRINT N'====================================================================================';
PRINT N'  CEZAM - MÜKERRER KAYIT TEMİZLEME MOTORU';
PRINT N'  Mod: ' + CASE WHEN @DryRun = 1 THEN N'TEST / RAPOR (Silme Kapalı - @DryRun = 1)' ELSE N'GERÇEK SİLME (@DryRun = 0)' END;
PRINT N'====================================================================================';

-- =================================================================================================
-- 1. ADIM: E_History TABLOSUNDAKİ MÜKERRER KAYITLARIN ANALİZİ VE TEMİZLENMESİ
-- =================================================================================================
PRINT N'';
PRINT N'--- [1/2] E_History Tablosu Analiz Ediliyor ---';

DECLARE @TotalHistoryBefore INT = 0;
DECLARE @DistinctHistory INT = 0;
DECLARE @DuplicateHistoryCount INT = 0;

SELECT @TotalHistoryBefore = COUNT(*) FROM dbo.E_History;

;WITH DuplicateHistoryCTE AS
(
    SELECT 
        fldId,
        ROW_NUMBER() OVER 
        (
            PARTITION BY 
                ISNULL(fldStart, '1900-01-01'),
                ISNULL(fldShouldExit, '1900-01-01'),
                ISNULL(fldBirthDate, '1900-01-01'),
                ISNULL(CAST(fldCountry AS NVARCHAR(250)), N''),
                ISNULL(CAST(fldPenalty AS NVARCHAR(500)), N''),
                ISNULL(CAST(fldPMoney AS NVARCHAR(100)), N''),
                ISNULL(CAST(fldUser AS NVARCHAR(250)), N''),
                ISNULL(CAST(fldBorder AS NVARCHAR(250)), N''),
                ISNULL(fldDatetime, '1900-01-01')
            ORDER BY fldId ASC -- En küçük fldId orijinal sayılır ve korunur
        ) AS RowNum
    FROM dbo.E_History
)
SELECT @DuplicateHistoryCount = COUNT(*) 
FROM DuplicateHistoryCTE 
WHERE RowNum > 1;

SET @DistinctHistory = @TotalHistoryBefore - @DuplicateHistoryCount;

PRINT N'  -> Toplam E_History Kayıt Sayısı      : ' + CAST(@TotalHistoryBefore AS NVARCHAR(20));
PRINT N'  -> Korunacak Tekil (Orijinal) Kayıt   : ' + CAST(@DistinctHistory AS NVARCHAR(20));
PRINT N'  -> Silinecek Mükerrer Kopya Sayısı    : ' + CAST(@DuplicateHistoryCount AS NVARCHAR(20));

IF @DuplicateHistoryCount > 0
BEGIN
    IF @DryRun = 1
    BEGIN
        PRINT N'  [TEST RAPORU] Mükerrer olan ilk 10 örnek kayıt listeleniyor:';
        ;WITH SampleDuplicates AS
        (
            SELECT 
                fldId,
                fldDatetime,
                CAST(fldUser AS NVARCHAR(100)) AS fldUser,
                CAST(fldCountry AS NVARCHAR(100)) AS fldCountry,
                CAST(fldPenalty AS NVARCHAR(100)) AS fldPenalty,
                ROW_NUMBER() OVER 
                (
                    PARTITION BY 
                        ISNULL(fldStart, '1900-01-01'),
                        ISNULL(fldShouldExit, '1900-01-01'),
                        ISNULL(fldBirthDate, '1900-01-01'),
                        ISNULL(CAST(fldCountry AS NVARCHAR(250)), N''),
                        ISNULL(CAST(fldPenalty AS NVARCHAR(500)), N''),
                        ISNULL(CAST(fldPMoney AS NVARCHAR(100)), N''),
                        ISNULL(CAST(fldUser AS NVARCHAR(250)), N''),
                        ISNULL(CAST(fldBorder AS NVARCHAR(250)), N''),
                        ISNULL(fldDatetime, '1900-01-01')
                    ORDER BY fldId ASC
                ) AS RowNum
            FROM dbo.E_History
        )
        SELECT TOP 10 
            fldId AS [Silinecek_fldId],
            RowNum AS [Kopya_Sira_No],
            fldDatetime AS [İşlem_Tarihi],
            fldUser AS [Kullanıcı],
            fldCountry AS [Uyruk],
            fldPenalty AS [Ceza]
        FROM SampleDuplicates
        WHERE RowNum > 1
        ORDER BY fldDatetime DESC, fldId ASC;
    END
    ELSE
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            PRINT N'  [İŞLEM] E_History mükerrer kopyaları siliniyor...';

            ;WITH DeleteHistoryCTE AS
            (
                SELECT 
                    fldId,
                    ROW_NUMBER() OVER 
                    (
                        PARTITION BY 
                            ISNULL(fldStart, '1900-01-01'),
                            ISNULL(fldShouldExit, '1900-01-01'),
                            ISNULL(fldBirthDate, '1900-01-01'),
                            ISNULL(CAST(fldCountry AS NVARCHAR(250)), N''),
                            ISNULL(CAST(fldPenalty AS NVARCHAR(500)), N''),
                            ISNULL(CAST(fldPMoney AS NVARCHAR(100)), N''),
                            ISNULL(CAST(fldUser AS NVARCHAR(250)), N''),
                            ISNULL(CAST(fldBorder AS NVARCHAR(250)), N''),
                            ISNULL(fldDatetime, '1900-01-01')
                        ORDER BY fldId ASC
                    ) AS RowNum
                FROM dbo.E_History
            )
            DELETE FROM DeleteHistoryCTE
            WHERE RowNum > 1;

            DECLARE @DeletedHistoryActual INT = @@ROWCOUNT;
            COMMIT TRANSACTION;

            PRINT N'  [BAŞARILI] E_History tablosundan ' + CAST(@DeletedHistoryActual AS NVARCHAR(20)) + N' mükerrer kayıt güvenle silindi!';
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            PRINT N'  [HATA] E_History silme işlemi sırasında hata: ' + ERROR_MESSAGE();
        END CATCH
    END
END
ELSE
BEGIN
    PRINT N'  [BİLGİ] E_History tablosunda mükerrer kayıt bulunamadı, tablo temiz.';
END

-- =================================================================================================
-- 2. ADIM: E_IsK TABLOSUNDAKİ MÜKERRER KAYITLARIN ANALİZİ VE TEMİZLENMESİ
-- =================================================================================================
PRINT N'';
PRINT N'--- [2/2] E_IsK Tablosu Analiz Ediliyor ---';

DECLARE @TotalIsKBefore INT = 0;
DECLARE @DistinctIsK INT = 0;
DECLARE @DuplicateIsKCount INT = 0;

SELECT @TotalIsKBefore = COUNT(*) FROM dbo.E_IsK;

;WITH DuplicateIsKCTE AS
(
    SELECT 
        fldId,
        ROW_NUMBER() OVER 
        (
            PARTITION BY 
                ISNULL(fldDatetime, '1900-01-01'),
                ISNULL(LTRIM(RTRIM(CAST(fldPassport AS NVARCHAR(100)))), N''),
                ISNULL(LTRIM(RTRIM(CAST(fldName AS NVARCHAR(250)))), N''),
                ISNULL(LTRIM(RTRIM(CAST(fldIdn AS NVARCHAR(100)))), N''),
                ISNULL(CAST(fldOrgin AS NVARCHAR(100)), N''),
                ISNULL(fldBirthdate, '1900-01-01'),
                ISNULL(CAST(fldBorder AS NVARCHAR(100)), N'')
            ORDER BY fldId ASC -- En küçük fldId orijinal kabul edilir
        ) AS RowNum
    FROM dbo.E_IsK
)
SELECT @DuplicateIsKCount = COUNT(*) 
FROM DuplicateIsKCTE 
WHERE RowNum > 1;

SET @DistinctIsK = @TotalIsKBefore - @DuplicateIsKCount;

PRINT N'  -> Toplam E_IsK Kayıt Sayısı          : ' + CAST(@TotalIsKBefore AS NVARCHAR(20));
PRINT N'  -> Korunacak Tekil (Orijinal) Kayıt   : ' + CAST(@DistinctIsK AS NVARCHAR(20));
PRINT N'  -> Silinecek Mükerrer Kopya Sayısı    : ' + CAST(@DuplicateIsKCount AS NVARCHAR(20));

IF @DuplicateIsKCount > 0
BEGIN
    IF @DryRun = 1
    BEGIN
        PRINT N'  [TEST RAPORU] E_IsK mükerrer olan ilk 10 örnek kayıt listeleniyor:';
        ;WITH SampleDuplicatesIsK AS
        (
            SELECT 
                fldId,
                fldDatetime,
                CAST(fldPassport AS NVARCHAR(100)) AS fldPassport,
                CAST(fldName AS NVARCHAR(250)) AS fldName,
                CAST(fldBorder AS NVARCHAR(100)) AS fldBorder,
                ROW_NUMBER() OVER 
                (
                    PARTITION BY 
                        ISNULL(fldDatetime, '1900-01-01'),
                        ISNULL(LTRIM(RTRIM(CAST(fldPassport AS NVARCHAR(100)))), N''),
                        ISNULL(LTRIM(RTRIM(CAST(fldName AS NVARCHAR(250)))), N''),
                        ISNULL(LTRIM(RTRIM(CAST(fldIdn AS NVARCHAR(100)))), N''),
                        ISNULL(CAST(fldOrgin AS NVARCHAR(100)), N''),
                        ISNULL(fldBirthdate, '1900-01-01'),
                        ISNULL(CAST(fldBorder AS NVARCHAR(100)), N'')
                    ORDER BY fldId ASC
                ) AS RowNum
            FROM dbo.E_IsK
        )
        SELECT TOP 10 
            fldId AS [Silinecek_fldId],
            RowNum AS [Kopya_Sira_No],
            fldDatetime AS [İşlem_Tarihi],
            fldPassport AS [Pasaport_No],
            fldName AS [Ad_Soyad],
            fldBorder AS [Hudut_Kapısı]
        FROM SampleDuplicatesIsK
        WHERE RowNum > 1
        ORDER BY fldDatetime DESC, fldId ASC;
    END
    ELSE
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            PRINT N'  [İŞLEM] E_IsK mükerrer kopyaları siliniyor...';

            ;WITH DeleteIsKCTE AS
            (
                SELECT 
                    fldId,
                    ROW_NUMBER() OVER 
                    (
                        PARTITION BY 
                            ISNULL(fldDatetime, '1900-01-01'),
                            ISNULL(LTRIM(RTRIM(CAST(fldPassport AS NVARCHAR(100)))), N''),
                            ISNULL(LTRIM(RTRIM(CAST(fldName AS NVARCHAR(250)))), N''),
                            ISNULL(LTRIM(RTRIM(CAST(fldIdn AS NVARCHAR(100)))), N''),
                            ISNULL(CAST(fldOrgin AS NVARCHAR(100)), N''),
                            ISNULL(fldBirthdate, '1900-01-01'),
                            ISNULL(CAST(fldBorder AS NVARCHAR(100)), N'')
                        ORDER BY fldId ASC
                    ) AS RowNum
                FROM dbo.E_IsK
            )
            DELETE FROM DeleteIsKCTE
            WHERE RowNum > 1;

            DECLARE @DeletedIsKActual INT = @@ROWCOUNT;
            COMMIT TRANSACTION;

            PRINT N'  [BAŞARILI] E_IsK tablosundan ' + CAST(@DeletedIsKActual AS NVARCHAR(20)) + N' mükerrer kayıt güvenle silindi!';
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            PRINT N'  [HATA] E_IsK silme işlemi sırasında hata: ' + ERROR_MESSAGE();
        END CATCH
    END
END
ELSE
BEGIN
    PRINT N'  [BİLGİ] E_IsK tablosunda mükerrer kayıt bulunamadı, tablo temiz.';
END

PRINT N'';
PRINT N'====================================================================================';
IF @DryRun = 1
BEGIN
    PRINT N'  ÖNEMLİ: Yukarıdaki sayılar doğruysa, scriptin başındaki:';
    PRINT N'         DECLARE @DryRun BIT = 1;  satırını';
    PRINT N'         DECLARE @DryRun BIT = 0;  yapıp tekrar F5 ile çalıştırınız.';
END
ELSE
BEGIN
    PRINT N'  TEMİZLEME İŞLEMİ TAMAMLANDI. Her kayıttan tam 1 adet orijinal bırakıldı.';
END
PRINT N'====================================================================================';
GO
