/*
====================================================================================================
    CEZAM - 76 Sunucusundan 75 Ana Sunucusuna Güvenli E_History ve E_IsK Aktarım & Senkronizasyon Scripti
====================================================================================================
    Kaynak Sunucu : 10.7.202.76 (veya ANHGZPCEZA)
    Hedef Sunucu  : 10.7.202.75 (Ana Sunucu - ANTHGZPSUNUCU\CEZA)
    Veritabanı    : CEZA
    Tablolar      : dbo.E_History & dbo.E_IsK

    ÖZELLİKLER:
      1. İdempotent (Mükerrerlik Korumalı): Bu scripti 100 kere de çalıştırsanız, 
         75'te zaten var olan kayıtları ATLAR; ASLA aynı kaydı ikinci kez yüklemez!
      2. Sadece 76'da yeni açılmış / eklenmiş kayıtları tespit edip 75'e ilave eder.
      3. fldId kolonları IDENTITY olduğu için hedef sunucu kendi ardışık ID'lerini üretir; ID çakışması yaşanmaz.
      4. İster SSMS üzerinden el ile F5 ile çalıştırın, ister SQL Agent Job ile otomatikleştirin.
====================================================================================================
*/

USE [CEZA];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

----------------------------------------------------------------------------------------------------
-- 1. ADIM: LINKED SERVER (10.7.202.76) KONTROLÜ VE OTOMATİK KURULUMU
----------------------------------------------------------------------------------------------------
DECLARE @SourceServer sysname = N'10.7.202.76';
DECLARE @SourceDb     sysname = N'CEZA';

IF NOT EXISTS (SELECT 1 FROM sys.servers WHERE name = @SourceServer)
BEGIN
    PRINT N'[BİLGİ] ' + @SourceServer + N' Linked Server tanımı bulunamadı, oluşturuluyor...';
    
    EXEC master.dbo.sp_addlinkedserver
        @server     = @SourceServer,
        @srvproduct = N'SQL Server';

    -- Windows Auth (useself=True)
    EXEC master.dbo.sp_addlinkedsrvlogin
        @rmtsrvname = @SourceServer,
        @useself    = N'True';

    EXEC master.dbo.sp_serveroption @server = @SourceServer, @optname = N'rpc', @optvalue = N'true';
    EXEC master.dbo.sp_serveroption @server = @SourceServer, @optname = N'rpc out', @optvalue = N'true';
    
    PRINT N'[BAŞARILI] ' + @SourceServer + N' Linked Server bağlantısı kuruldu.';
END
ELSE
BEGIN
    PRINT N'[BİLGİ] ' + @SourceServer + N' Linked Server zaten tanımlı.';
END
GO

----------------------------------------------------------------------------------------------------
-- 2. ADIM: BAĞLANTI TESTİ (TEST LINKED SERVER)
----------------------------------------------------------------------------------------------------
DECLARE @SourceServer sysname = N'10.7.202.76';
BEGIN TRY
    EXEC master.dbo.sp_testlinkedserver @server = @SourceServer;
    PRINT N'[BAŞARILI] ' + @SourceServer + N' sunucusuna bağlantı testi başarılı.';
END TRY
BEGIN CATCH
    PRINT N'[UYARI] ' + @SourceServer + N' bağlantı testi yanıt vermedi. Güvenlik duvarını (Port 1433) kontrol ediniz.';
    PRINT N'Hata Detayı: ' + ERROR_MESSAGE();
    -- Test başarısız olsa da işlemi devam ettirmeyi deneyeceğiz
END CATCH
GO

----------------------------------------------------------------------------------------------------
-- 3. ADIM: AKILLI & MÜKERRERLİK KORUMALI AKTARIM (TRANSACTION İÇİNDE)
----------------------------------------------------------------------------------------------------
BEGIN TRY
    BEGIN TRANSACTION;

    PRINT N'';
    PRINT N'====================================================================================';
    PRINT N'  SENKRONİZASYON BAŞLADI: [10.7.202.76] -> [10.7.202.75]';
    PRINT N'====================================================================================';

    -- =============================================================================================
    -- A) E_History TABLOSU SENKRONİZASYONU
    -- =============================================================================================
    DECLARE @InsertedHistory INT = 0;

    INSERT INTO dbo.E_History
    (
        fldStart,
        fldShouldExit,
        fldBirthDate,
        fldCountry,
        fldPenalty,
        fldPMoney,
        fldUser,
        fldBorder,
        fldDatetime
    )
    SELECT
        src.fldStart,
        src.fldShouldExit,
        src.fldBirthDate,
        src.fldCountry,
        src.fldPenalty,
        src.fldPMoney,
        src.fldUser,
        src.fldBorder,
        src.fldDatetime
    FROM [10.7.202.76].[CEZA].dbo.E_History AS src
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.E_History AS dst
        WHERE ISNULL(dst.fldDatetime, '1900-01-01')              = ISNULL(src.fldDatetime, '1900-01-01')
          AND ISNULL(CAST(dst.fldUser AS NVARCHAR(250)), N'')     = ISNULL(CAST(src.fldUser AS NVARCHAR(250)), N'')
          AND ISNULL(dst.fldStart, '1900-01-01')                 = ISNULL(src.fldStart, '1900-01-01')
          AND ISNULL(dst.fldShouldExit, '1900-01-01')            = ISNULL(src.fldShouldExit, '1900-01-01')
          AND ISNULL(CAST(dst.fldPenalty AS NVARCHAR(500)), N'') = ISNULL(CAST(src.fldPenalty AS NVARCHAR(500)), N'')
          AND ISNULL(CAST(dst.fldCountry AS NVARCHAR(250)), N'') = ISNULL(CAST(src.fldCountry AS NVARCHAR(250)), N'')
    );

    SET @InsertedHistory = @@ROWCOUNT;

    IF @InsertedHistory > 0
        PRINT N'-> [E_History] ' + CAST(@InsertedHistory AS NVARCHAR(10)) + N' YENİ kayıt 75 ana sunucusuna başarıyla aktarıldı.';
    ELSE
        PRINT N'-> [E_History] 0 yeni kayıt. (Tüm veriler zaten 75 sunucusunda mevcut, mükerrer kayıt engellendi).';

    -- =============================================================================================
    -- B) E_IsK TABLOSU SENKRONİZASYONU
    -- =============================================================================================
    DECLARE @InsertedIsK INT = 0;

    INSERT INTO dbo.E_IsK
    (
        fldDatetime,
        fldName,
        fldPassport,
        fldIdn,
        fldOrgin,
        fldBirthdate,
        fldForm,
        fldPassControl,
        fldApproval,
        fldBorder,
        fldVisa,
        fldPMoney,
        fldPicture
    )
    SELECT
        src.fldDatetime,
        src.fldName,
        src.fldPassport,
        src.fldIdn,
        src.fldOrgin,
        src.fldBirthdate,
        src.fldForm,
        src.fldPassControl,
        src.fldApproval,
        src.fldBorder,
        src.fldVisa,
        src.fldPMoney,
        src.fldPicture
    FROM [10.7.202.76].[CEZA].dbo.E_IsK AS src
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.E_IsK AS dst
        WHERE ISNULL(dst.fldDatetime, '1900-01-01')                                 = ISNULL(src.fldDatetime, '1900-01-01')
          AND ISNULL(LTRIM(RTRIM(CAST(dst.fldPassport AS NVARCHAR(100)))), N'')     = ISNULL(LTRIM(RTRIM(CAST(src.fldPassport AS NVARCHAR(100)))), N'')
          AND ISNULL(LTRIM(RTRIM(CAST(dst.fldName AS NVARCHAR(250)))), N'')         = ISNULL(LTRIM(RTRIM(CAST(src.fldName AS NVARCHAR(250)))), N'')
          AND ISNULL(CAST(dst.fldBorder AS NVARCHAR(100)), N'')                     = ISNULL(CAST(src.fldBorder AS NVARCHAR(100)), N'')
    );

    SET @InsertedIsK = @@ROWCOUNT;

    IF @InsertedIsK > 0
        PRINT N'-> [E_IsK] ' + CAST(@InsertedIsK AS NVARCHAR(10)) + N' YENİ yolcu işlem kaydı 75 ana sunucusuna başarıyla aktarıldı.';
    ELSE
        PRINT N'-> [E_IsK] 0 yeni kayıt. (Tüm yolcu işlem kayıtları zaten 75 sunucusunda mevcut, mükerrer kayıt engellendi).';

    COMMIT TRANSACTION;

    PRINT N'';
    PRINT N'====================================================================================';
    PRINT N'  SENKRONİZASYON İŞLEMİ BAŞARIYLA TAMAMLANDI!';
    PRINT N'  Toplam Eklenen: ' + CAST((@InsertedHistory + @InsertedIsK) AS NVARCHAR(10)) + N' yeni satır.';
    PRINT N'====================================================================================';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT N'';
    PRINT N'************************************************************************************';
    PRINT N'[HATA OLUŞTU - TÜM İŞLEMLER GERİ ALINDI]';
    PRINT N'Hata Mesajı   : ' + ERROR_MESSAGE();
    PRINT N'Hata Satırı   : ' + CAST(ERROR_LINE() AS NVARCHAR(10));
    PRINT N'Hata Numarası : ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
    PRINT N'************************************************************************************';
END CATCH;
GO
