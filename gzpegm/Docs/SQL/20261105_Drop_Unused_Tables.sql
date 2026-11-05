/*
================================================================================
CEZAM - KULLANILMAYAN ATIL TABLOLARI TEMİZLEME SCRİPTİ (CANLI ORTAM İÇİN)
Tarih: 05.11.2026
Açıklama:
Bu script, projenin kaynak kodlarında kesinlikle kullanılmayan (0 referans)
veya eski/iptal edilmiş modüllerden (Chat, ChatRobot, geçici yedek) kalan
atıl tabloları güvenli (idempotent / hata vermez) şekilde siler.

Bu işlem canlı veritabanında çalıştırıldığında projenin çalışmasına 
hiçbir olumsuz etkisi olmayacaktır.
================================================================================
*/

USE [CEZA];
GO

SET NOCOUNT ON;

PRINT N'========================================================================';
PRINT N'CEZAM ATIL TABLO TEMİZLEME BAŞLATILIYOR...';
PRINT N'========================================================================';

-- 1. E_UVR_Backup_Before_WorkPermit (Eski çalışma izni öncesi geçici yedek tablosu)
IF OBJECT_ID(N'dbo.E_UVR_Backup_Before_WorkPermit', N'U') IS NOT NULL
BEGIN
    DROP TABLE [dbo].[E_UVR_Backup_Before_WorkPermit];
    PRINT N'[OK] dbo.E_UVR_Backup_Before_WorkPermit tablosu başarıyla silindi.';
END
ELSE
BEGIN
    PRINT N'[BİLGİ] dbo.E_UVR_Backup_Before_WorkPermit tablosu zaten mevcut değil.';
END
GO

-- 2. ChatMessages (2024 yılında iptal edilen Sohbet modülü tablosu)
IF OBJECT_ID(N'dbo.ChatMessages', N'U') IS NOT NULL
BEGIN
    DROP TABLE [dbo].[ChatMessages];
    PRINT N'[OK] dbo.ChatMessages tablosu başarıyla silindi.';
END
ELSE
BEGIN
    PRINT N'[BİLGİ] dbo.ChatMessages tablosu zaten mevcut değil.';
END
GO

-- 3. ChatOnlineUsers (2024 yılında iptal edilen Sohbet modülü tablosu)
IF OBJECT_ID(N'dbo.ChatOnlineUsers', N'U') IS NOT NULL
BEGIN
    DROP TABLE [dbo].[ChatOnlineUsers];
    PRINT N'[OK] dbo.ChatOnlineUsers tablosu başarıyla silindi.';
END
ELSE
BEGIN
    PRINT N'[BİLGİ] dbo.ChatOnlineUsers tablosu zaten mevcut değil.';
END
GO

-- 4. SorguCevaplari (2024 yılında iptal edilen ChatRobot modülü tablosu)
IF OBJECT_ID(N'dbo.SorguCevaplari', N'U') IS NOT NULL
BEGIN
    DROP TABLE [dbo].[SorguCevaplari];
    PRINT N'[OK] dbo.SorguCevaplari tablosu başarıyla silindi.';
END
ELSE
BEGIN
    PRINT N'[BİLGİ] dbo.SorguCevaplari tablosu zaten mevcut değil.';
END
GO

-- 5. SorguLoglari (2024 yılında iptal edilen ChatRobot modülü log tablosu)
IF OBJECT_ID(N'dbo.SorguLoglari', N'U') IS NOT NULL
BEGIN
    DROP TABLE [dbo].[SorguLoglari];
    PRINT N'[OK] dbo.SorguLoglari tablosu başarıyla silindi.';
END
ELSE
BEGIN
    PRINT N'[BİLGİ] dbo.SorguLoglari tablosu zaten mevcut değil.';
END
GO

/*
--------------------------------------------------------------------------------
NOT: 'E_Dilekce' ve 'DocumentTerms' Tabloları Hakkında:
--------------------------------------------------------------------------------
Projede dilekçe veya belge sözlüğü oluşturan aktif bir modül bulunmamaktadır.
Yalnızca kullanıcı silinirken bu tablolara güvenlik amaçlı pasif bir kontrol
yapılmaktadır. İleride bu tabloları da tamamen kaldırmak isterseniz 
aşağıdaki satırları açıp çalıştırabilirsiniz:

-- IF OBJECT_ID(N'dbo.E_Dilekce', N'U') IS NOT NULL
-- BEGIN
--     DROP TABLE [dbo].[E_Dilekce];
--     PRINT N'[OK] dbo.E_Dilekce tablosu silindi.';
-- END
-- GO

-- IF OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NOT NULL
-- BEGIN
--     DROP TABLE [dbo].[DocumentTerms];
--     PRINT N'[OK] dbo.DocumentTerms tablosu silindi.';
-- END
-- GO
--------------------------------------------------------------------------------
*/

PRINT N'========================================================================';
PRINT N'CEZAM ATIL TABLO TEMİZLEME İŞLEMİ BAŞARIYLA TAMAMLANDI.';
PRINT N'========================================================================';
GO
