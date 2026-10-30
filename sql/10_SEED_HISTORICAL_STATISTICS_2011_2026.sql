-- ====================================================================================
-- 10_SEED_HISTORICAL_STATISTICS_2011_2026.sql
-- 2011 - 2026 Yılları Arası Tüm Bürolar ve Göstergeler İçin Gerçekçi Günlük İstatistik Verisi
-- ====================================================================================

USE [CEZA];
GO

SET NOCOUNT ON;
PRINT N'2011-2026 Yılları arası tarihsel istatistik verileri oluşturuluyor...';

-- 1. Geçici Tarih Cetveli (01.01.2011 - 31.10.2026 = 5.783 Gün)
IF OBJECT_ID('tempdb..#DateDim') IS NOT NULL DROP TABLE #DateDim;

;WITH N10 AS (SELECT n FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) t(n)),
Numbers AS (
    SELECT a.n + b.n*10 + c.n*100 + d.n*1000 AS n
    FROM N10 a CROSS JOIN N10 b CROSS JOIN N10 c CROSS JOIN N10 d
),
Dates AS (
    SELECT DATEADD(DAY, n, '2011-01-01') AS d
    FROM Numbers
    WHERE n <= DATEDIFF(DAY, '2011-01-01', '2026-10-31')
)
SELECT 
    d AS EntryDate,
    YEAR(d) AS Y,
    MONTH(d) AS M,
    DAY(d) AS DayNum,
    -- Yıllık Trend Katsayısı (2011'den itibaren büyüme, 2020 pandemi düşüşü, 2021-2026 güçlü toparlanma)
    CASE 
        WHEN YEAR(d) = 2011 THEN 0.70
        WHEN YEAR(d) = 2012 THEN 0.74
        WHEN YEAR(d) = 2013 THEN 0.78
        WHEN YEAR(d) = 2014 THEN 0.82
        WHEN YEAR(d) = 2015 THEN 0.86
        WHEN YEAR(d) = 2016 THEN 0.80
        WHEN YEAR(d) = 2017 THEN 0.88
        WHEN YEAR(d) = 2018 THEN 0.95
        WHEN YEAR(d) = 2019 THEN 1.05
        WHEN YEAR(d) = 2020 THEN 0.45 -- Pandemi kısıtlamaları
        WHEN YEAR(d) = 2021 THEN 0.72
        WHEN YEAR(d) = 2022 THEN 0.94
        WHEN YEAR(d) = 2023 THEN 1.08
        WHEN YEAR(d) = 2024 THEN 1.16
        WHEN YEAR(d) = 2025 THEN 1.22
        ELSE 1.28
    END AS YearFactor,
    -- Aylık Sezonsallık Katsayısı (Mayıs - Ekim yaz turizm sezonu)
    CASE 
        WHEN MONTH(d) = 1 THEN 0.65
        WHEN MONTH(d) = 2 THEN 0.60
        WHEN MONTH(d) = 3 THEN 0.75
        WHEN MONTH(d) = 4 THEN 0.90
        WHEN MONTH(d) = 5 THEN 1.30
        WHEN MONTH(d) = 6 THEN 1.55
        WHEN MONTH(d) = 7 THEN 1.80
        WHEN MONTH(d) = 8 THEN 1.85
        WHEN MONTH(d) = 9 THEN 1.50
        WHEN MONTH(d) = 10 THEN 1.15
        WHEN MONTH(d) = 11 THEN 0.70
        ELSE 0.70
    END AS MonthFactor
INTO #DateDim
FROM Dates;

CREATE CLUSTERED INDEX IX_DateDim_d ON #DateDim(EntryDate);

PRINT N'Tarih cetveli hazırlandı (' + CAST(@@ROWCOUNT AS NVARCHAR(20)) + N' gün).';

-- 2. Hedef Kapılar ve Katsayıları
IF OBJECT_ID('tempdb..#Borders') IS NOT NULL DROP TABLE #Borders;
CREATE TABLE #Borders (
    BorderId INT PRIMARY KEY,
    BorderName NVARCHAR(150),
    GateType NVARCHAR(20), -- 'AIR', 'SEA'
    ScaleFactor DECIMAL(6,2)
);

INSERT INTO #Borders (BorderId, BorderName, GateType, ScaleFactor) VALUES
(14, N'ANTALYA GAZİPAŞA HAVA LİMANI', 'AIR', 1.00),
(5, N'ANTALYA HAVA LİMANI', 'AIR', 3.20),
(152, N'ÇANAKKALE YAT LİMANI DENİZ HUDUT KAPI', 'SEA', 0.45),
(88, N'ÇEŞME DENİZ HUDUT KAPISI', 'SEA', 0.60),
(6, N'İSTANBUL HAVALİMANI', 'AIR', 4.50);

-- 3. RowItem Temel Değerleri
IF OBJECT_ID('tempdb..#RowBases') IS NOT NULL DROP TABLE #RowBases;
CREATE TABLE #RowBases (
    RowId INT PRIMARY KEY,
    BaseDaily DECIMAL(18,2),
    ApplyToSea BIT
);

INSERT INTO #RowBases (RowId, BaseDaily, ApplyToSea)
SELECT r.RowId,
    CASE r.RowId
        WHEN 1 THEN 4.50   -- TAHDİT BAKILAN KİŞİ
        WHEN 2 THEN 0.40   -- BELGE TALEBİ
        WHEN 3 THEN 1.30   -- TAHDİT EKLEME
        WHEN 4 THEN 2.00   -- TAHDİT KALDIRMA
        WHEN 5 THEN 0.30   -- OPTİK OKUYUCU BAKIM
        WHEN 6 THEN 0.20   -- POLNET TERMİNAL ARIZA
        WHEN 7 THEN 0.10   -- AĞ ARIZASI
        WHEN 8 THEN 1.10   -- ARANMASI BULUNAN ŞAHIS
        WHEN 9 THEN 0.35   -- SAHTE PASAPORT
        WHEN 10 THEN 0.75  -- SAVCILIĞA SEVK
        WHEN 11 THEN 0.60  -- İFADESİ ALINIP SERBEST
        WHEN 12 THEN 95.0  -- TÜRK VATANDAŞI GİRİŞ
        WHEN 13 THEN 90.0  -- TÜRK VATANDAŞI ÇIKIŞ
        WHEN 14 THEN 420.0 -- YABANCI YOLCU GİRİŞ
        WHEN 15 THEN 400.0 -- YABANCI YOLCU ÇIKIŞ
        WHEN 16 THEN 4.20  -- İHLALLİ ÇIKIŞ
        WHEN 17 THEN 2.60  -- ŞARTLI GİRİŞ
        WHEN 1002 THEN 5.50 -- GELEN DIŞ HAT UÇAK
        WHEN 1003 THEN 5.50 -- GİDEN DIŞ HAT UÇAK
        WHEN 1004 THEN 2.20 -- GELEN İÇ HAT UÇAK
        WHEN 1005 THEN 2.20 -- GİDEN İÇ HAT UÇAK
        WHEN 18 THEN 3.80  -- GELEN RESMİ EVRAK
        WHEN 19 THEN 3.20  -- GİDEN RESMİ EVRAK
        WHEN 20 THEN 1.80  -- TEBLİĞ / TEBELLÜĞ
        ELSE 2.00
    END,
    CASE 
        WHEN r.RowId IN (1002, 1003, 1004, 1005) THEN 0 -- Uçak seferleri deniz kapılarında 0 olur
        ELSE 1 
    END
FROM [dbo].[Stat_RowItem] r;

-- 4. Toplu Günlük Veri Üretimi
PRINT N'Günlük veriler hesaplanıyor ve yükleniyor...';

INSERT INTO [dbo].[Stat_DailyValue] ([BorderId], [RowId], [EntryDate], [Value], [Note], [UpdatedByUserId], [LastUpdated])
SELECT 
    b.BorderId,
    rb.RowId,
    d.EntryDate AS EntryDate,
    CASE 
        WHEN b.GateType = 'SEA' AND rb.ApplyToSea = 0 THEN 0
        ELSE 
            ROUND(
                rb.BaseDaily * b.ScaleFactor * d.YearFactor * d.MonthFactor * 
                (1.0 + (CAST(ABS(CHECKSUM(d.EntryDate, rb.RowId, b.BorderId)) % 25 - 12 AS DECIMAL(6,2)) / 100.0)),
                0
            )
    END AS [Value],
    NULL AS [Note],
    1 AS [UpdatedByUserId],
    GETDATE() AS [LastUpdated]
FROM #DateDim d
CROSS JOIN #Borders b
CROSS JOIN #RowBases rb
LEFT JOIN [dbo].[Stat_DailyValue] v 
    ON v.BorderId = b.BorderId AND v.RowId = rb.RowId AND v.EntryDate = d.EntryDate
WHERE v.ValueId IS NULL;

PRINT N'Temel veriler eklendi. Şimdi Gazipaşa (BorderId 14) için resmi brifing tablosu rakamları kalibre ediliyor...';

-- 5. Gazipaşa (BorderId 14) - Kullanıcının yüklediği fotoğraftaki 2025 ve 2026 brifing rakamlarını birebir eşitleme
-- Mayıs 2025: 134, 12, 41, 61 (5 Aylık: 422, 29, 237, 242)
-- Mayıs 2026: 141, 3, 34, 64 (5 Aylık: 381, 13, 126, 219)

-- Önce Mayıs 2025 ve Mayıs 2026 mevcut günlerini brifing toplamına ayarla
-- Mayıs 2025
UPDATE [dbo].[Stat_DailyValue] SET Value = 0 WHERE BorderId = 14 AND RowId IN (1,2,3,4) AND YEAR(EntryDate) = 2025 AND MONTH(EntryDate) = 5;
UPDATE [dbo].[Stat_DailyValue] SET Value = 134 WHERE BorderId = 14 AND RowId = 1 AND EntryDate = '2025-05-15';
UPDATE [dbo].[Stat_DailyValue] SET Value = 12  WHERE BorderId = 14 AND RowId = 2 AND EntryDate = '2025-05-15';
UPDATE [dbo].[Stat_DailyValue] SET Value = 41  WHERE BorderId = 14 AND RowId = 3 AND EntryDate = '2025-05-15';
UPDATE [dbo].[Stat_DailyValue] SET Value = 61  WHERE BorderId = 14 AND RowId = 4 AND EntryDate = '2025-05-15';

-- Ocak - Nisan 2025 Kümülatif farkını ayarla (5 Aylık hedef - Mayıs)
-- Row 1: 422 - 134 = 288 (Ocak - Nisan toplamı)
UPDATE [dbo].[Stat_DailyValue] SET Value = 0 WHERE BorderId = 14 AND RowId IN (1,2,3,4) AND YEAR(EntryDate) = 2025 AND MONTH(EntryDate) BETWEEN 1 AND 4;
UPDATE [dbo].[Stat_DailyValue] SET Value = 288 WHERE BorderId = 14 AND RowId = 1 AND EntryDate = '2025-03-15';
UPDATE [dbo].[Stat_DailyValue] SET Value = 17  WHERE BorderId = 14 AND RowId = 2 AND EntryDate = '2025-03-15'; -- 29 - 12 = 17
UPDATE [dbo].[Stat_DailyValue] SET Value = 196 WHERE BorderId = 14 AND RowId = 3 AND EntryDate = '2025-03-15'; -- 237 - 41 = 196
UPDATE [dbo].[Stat_DailyValue] SET Value = 181 WHERE BorderId = 14 AND RowId = 4 AND EntryDate = '2025-03-15'; -- 242 - 61 = 181

-- Mayıs 2026
UPDATE [dbo].[Stat_DailyValue] SET Value = 0 WHERE BorderId = 14 AND RowId IN (1,2,3,4) AND YEAR(EntryDate) = 2026 AND MONTH(EntryDate) = 5;
UPDATE [dbo].[Stat_DailyValue] SET Value = 141 WHERE BorderId = 14 AND RowId = 1 AND EntryDate = '2026-05-15';
UPDATE [dbo].[Stat_DailyValue] SET Value = 3   WHERE BorderId = 14 AND RowId = 2 AND EntryDate = '2026-05-15';
UPDATE [dbo].[Stat_DailyValue] SET Value = 34  WHERE BorderId = 14 AND RowId = 3 AND EntryDate = '2026-05-15';
UPDATE [dbo].[Stat_DailyValue] SET Value = 64  WHERE BorderId = 14 AND RowId = 4 AND EntryDate = '2026-05-15';

-- Ocak - Nisan 2026 Kümülatif farkını ayarla (5 Aylık hedef - Mayıs)
UPDATE [dbo].[Stat_DailyValue] SET Value = 0 WHERE BorderId = 14 AND RowId IN (1,2,3,4) AND YEAR(EntryDate) = 2026 AND MONTH(EntryDate) BETWEEN 1 AND 4;
UPDATE [dbo].[Stat_DailyValue] SET Value = 240 WHERE BorderId = 14 AND RowId = 1 AND EntryDate = '2026-03-15'; -- 381 - 141 = 240
UPDATE [dbo].[Stat_DailyValue] SET Value = 10  WHERE BorderId = 14 AND RowId = 2 AND EntryDate = '2026-03-15'; -- 13 - 3 = 10
UPDATE [dbo].[Stat_DailyValue] SET Value = 92  WHERE BorderId = 14 AND RowId = 3 AND EntryDate = '2026-03-15'; -- 126 - 34 = 92
UPDATE [dbo].[Stat_DailyValue] SET Value = 155 WHERE BorderId = 14 AND RowId = 4 AND EntryDate = '2026-03-15'; -- 219 - 64 = 155

-- Temizlik
DROP TABLE #DateDim;
DROP TABLE #Borders;
DROP TABLE #RowBases;

PRINT N'Yükleme tamamlandı. Yıllara göre kayıt sayıları:';
SELECT 
    b.fldName AS HudutKapisi,
    YEAR(v.EntryDate) AS Yil,
    COUNT(*) AS ToplamKayitSayisi,
    SUM(v.Value) AS ToplamIslemSayisi
FROM [dbo].[Stat_DailyValue] v
JOIN [dbo].[E_Border] b ON b.fldId = v.BorderId
GROUP BY b.fldName, YEAR(v.EntryDate)
ORDER BY b.fldName, Yil;
GO
