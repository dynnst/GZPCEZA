-- =====================================================================
-- CEZAM - VERİTABANI PERFORMANS VE HIZLANDIRMA İNDEKSLERİ
-- =====================================================================
-- Bu script, gişe ceza hesaplama ve sorgulamalarının sıfır gecikmeyle
-- (donma/kasma olmadan) çalışması için kritik indeksleri oluşturur.
-- =====================================================================

USE [CEZA];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- 1. E_History: Sınır Kapısı ve Kullanıcıya Göre Anlık Sorgu İndeksi
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[E_History]') AND name = N'IX_E_History_Border_User')
BEGIN
    PRINT N'[1/2] E_History tablosu için IX_E_History_Border_User indeksi oluşturuluyor...';
    CREATE NONCLUSTERED INDEX [IX_E_History_Border_User] ON [dbo].[E_History]
    (
        [fldBorder] ASC,
        [fldUser] ASC
    )
    INCLUDE ([fldDatetime], [fldTotal], [fldPenalty], [fldCountry])
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
    PRINT N'✓ E_History indeksi başarıyla tamamlandı.';
END
ELSE
BEGIN
    PRINT N'-> E_History indeksi zaten mevcut.';
END
GO

-- 2. E_IsK: Pasaport ve Tarihe Göre Hızlı Arama İndeksi
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[E_IsK]') AND name = N'IX_E_IsK_Passport_Datetime')
BEGIN
    PRINT N'[2/2] E_IsK tablosu için IX_E_IsK_Passport_Datetime indeksi oluşturuluyor...';
    CREATE NONCLUSTERED INDEX [IX_E_IsK_Passport_Datetime] ON [dbo].[E_IsK]
    (
        [fldPassport] ASC,
        [fldDatetime] DESC
    )
    INCLUDE ([fldName], [fldIdn], [fldOrgin], [fldBorder])
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
    PRINT N'✓ E_IsK indeksi başarıyla tamamlandı.';
END
ELSE
BEGIN
    PRINT N'-> E_IsK indeksi zaten mevcut.';
END
GO

PRINT N'=====================================================================';
PRINT N'TÜM PERFORMANS İNDEKSLERİ BAŞARIYLA TAMAMLANDI.';
PRINT N'=====================================================================';
GO
