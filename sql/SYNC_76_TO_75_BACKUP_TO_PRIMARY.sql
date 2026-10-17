/*
====================================================================================================
    CEZAM - 76 (Yedek) Sunucusundan 75 (Ana) Sunucusuna Güvenli Veri Aktarımı ve Senkronizasyon Scripti
====================================================================================================
    Kaynak (Yedek Sunucu) : 10.7.202.76 (veya ANHGZPCEZA)
    Hedef  (Ana Sunucu)   : 10.7.202.75 (veya ANTHGZPSUNUCU\CEZA)
    Veritabanı            : CEZA

    ÇALIŞTIRMA YERİ:
      Bu script 10.7.202.75 (Ana Sunucu) üzerinde SSMS (SQL Server Management Studio)
      veya SQL Server Agent Job içinde çalıştırılmalıdır.

    ÖZELLİKLER & GÜVENLİK:
      1. İdempotent (Mükerrerlik Korumalı): Script defalarca çalıştırılsa dahi
         asla aynı kayıtları mükerrer (duplicate) eklemez.
      2. Identity Kolon Koruması: Kaynak sunucudaki ID'ler çakışma yapmasın diye
         fldId ve Id kolonları hariç tutulur; hedef sunucu kendi ardışık ID'lerini üretir.
      3. Otomasyon Desteği: SQL Server Agent üzerinde zamanlanmış görev (Job) olarak
         her 15 dakikada, saatte bir veya her gece çalıştırılmaya tamamen uygundur.
====================================================================================================
*/

USE [CEZA];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

----------------------------------------------------------------------------------------------------
-- 1. ADIM: LINKED SERVER (BAĞLANTILI SUNUCU) KONTROLÜ VE TANIMLANMASI
----------------------------------------------------------------------------------------------------
DECLARE @BackupServer sysname = N'10.7.202.76'; -- 76 sunucusunun IP veya Instance adı
DECLARE @BackupDb     sysname = N'CEZA';

IF NOT EXISTS (SELECT 1 FROM sys.servers WHERE name = @BackupServer)
BEGIN
    PRINT N'[BILGI] ' + @BackupServer + N' Linked Server olarak tanimlanmamis, olusturuluyor...';
    
    EXEC master.dbo.sp_addlinkedserver
        @server     = @BackupServer,
        @srvproduct = N'SQL Server';

    -- Windows Authentication (useself=True) veya SQL Server kullanıcısı (sa vb.)
    EXEC master.dbo.sp_addlinkedsrvlogin
        @rmtsrvname = @BackupServer,
        @useself    = N'True';

    -- RPC ve Dağıtık İşlem Seçenekleri
    EXEC master.dbo.sp_serveroption @server = @BackupServer, @optname = N'rpc', @optvalue = N'true';
    EXEC master.dbo.sp_serveroption @server = @BackupServer, @optname = N'rpc out', @optvalue = N'true';
    
    PRINT N'[BASARILI] ' + @BackupServer + N' Linked Server basariyla olusturuldu.';
END
ELSE
BEGIN
    PRINT N'[BILGI] ' + @BackupServer + N' Linked Server zaten mevcut.';
END
GO

----------------------------------------------------------------------------------------------------
-- 2. ADIM: TABLOLARIN ÇİFT YÖNLÜ GÜVENLİ SENKRONİZASYONU (TRANSACTION İÇİNDE)
----------------------------------------------------------------------------------------------------
BEGIN TRY
    BEGIN TRANSACTION;

    PRINT N'------------------------------------------------------------------';
    PRINT N'[SENKRONIZASYON BASLADI] 76 -> 75 Veri Aktarimi Yurutuluyor...';
    PRINT N'------------------------------------------------------------------';

    -- =========================================================================
    -- A) E_User: Yeni Personel Kayıtları ve Güncellemeler
    -- =========================================================================
    DECLARE @InsertedUsers INT = 0;

    INSERT INTO dbo.E_User
    (
        fldSicil,
        fldName,
        fldLastName,
        fldPhone,
        fldEmail,
        fldTitle,
        fldDeputy,
        fldPicture,
        fldAuth,
        fldSubAuth,
        fldPassword,
        fldDateTime,
        fldBorder,
        fldActive,
        Role,
        LastLogin,
        XP,
        Level,
        IsActive,
        TeacherRequestStatus,
        TeacherRequestDate
    )
    SELECT
        src.fldSicil,
        src.fldName,
        src.fldLastName,
        src.fldPhone,
        src.fldEmail,
        src.fldTitle,
        src.fldDeputy,
        src.fldPicture,
        src.fldAuth,
        src.fldSubAuth,
        src.fldPassword,
        src.fldDateTime,
        src.fldBorder,
        src.fldActive,
        ISNULL(src.Role, 'User'),
        src.LastLogin,
        ISNULL(src.XP, 0),
        ISNULL(src.Level, 1),
        ISNULL(src.IsActive, 1),
        src.TeacherRequestStatus,
        src.TeacherRequestDate
    FROM [10.7.202.76].[CEZA].dbo.E_User AS src
    WHERE src.fldSicil IS NOT NULL
      AND NOT EXISTS
      (
          SELECT 1
          FROM dbo.E_User AS dst
          WHERE LTRIM(RTRIM(dst.fldSicil)) = LTRIM(RTRIM(src.fldSicil))
      );

    SET @InsertedUsers = @@ROWCOUNT;
    PRINT N'-> E_User: ' + CAST(@InsertedUsers AS NVARCHAR(10)) + N' yeni personel kaydi eklendi.';

    -- =========================================================================
    -- B) E_History: Ceza Hesaplama ve Sorgulama Kayıtları
    -- =========================================================================
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
        WHERE ISNULL(dst.fldDatetime, '1900-01-01') = ISNULL(src.fldDatetime, '1900-01-01')
          AND ISNULL(dst.fldUser, '')               = ISNULL(src.fldUser, '')
          AND ISNULL(dst.fldStart, '1900-01-01')    = ISNULL(src.fldStart, '1900-01-01')
          AND ISNULL(dst.fldPenalty, '')            = ISNULL(src.fldPenalty, '')
    );

    SET @InsertedHistory = @@ROWCOUNT;
    PRINT N'-> E_History: ' + CAST(@InsertedHistory AS NVARCHAR(10)) + N' yeni ceza hesaplama kaydi eklendi.';

    -- =========================================================================
    -- C) E_IsK: Giriş-Çıkış / Pasaport / Vize İşlem Kayıtları
    -- =========================================================================
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
        WHERE ISNULL(dst.fldDatetime, '1900-01-01') = ISNULL(src.fldDatetime, '1900-01-01')
          AND ISNULL(LTRIM(RTRIM(dst.fldPassport)), '') = ISNULL(LTRIM(RTRIM(src.fldPassport)), '')
          AND ISNULL(dst.fldName, '')               = ISNULL(src.fldName, '')
    );

    SET @InsertedIsK = @@ROWCOUNT;
    PRINT N'-> E_IsK: ' + CAST(@InsertedIsK AS NVARCHAR(10)) + N' yeni yolcu islem kaydi eklendi.';

    -- =========================================================================
    -- D) TahditFormLog: Tahdit Form ve Sorgu Log Kayıtları
    -- =========================================================================
    DECLARE @InsertedTahditLog INT = 0;

    INSERT INTO dbo.TahditFormLog
    (
        CreatedAt,
        TahditCode,
        IdariTahditCode,
        PenaltyDay,
        PenaltyMonth,
        PenaltyTotalDay,
        PaymentType,
        VisaType,
        Country,
        Border,
        UserId,
        UserSicil,
        UserDisplayName,
        PassengerName,
        PassportNo,
        FormMoney
    )
    SELECT
        src.CreatedAt,
        src.TahditCode,
        src.IdariTahditCode,
        src.PenaltyDay,
        src.PenaltyMonth,
        src.PenaltyTotalDay,
        src.PaymentType,
        src.VisaType,
        src.Country,
        src.Border,
        src.UserId,
        src.UserSicil,
        src.UserDisplayName,
        src.PassengerName,
        src.PassportNo,
        src.FormMoney
    FROM [10.7.202.76].[CEZA].dbo.TahditFormLog AS src
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.TahditFormLog AS dst
        WHERE dst.CreatedAt = src.CreatedAt
          AND ISNULL(dst.UserSicil, '')  = ISNULL(src.UserSicil, '')
          AND ISNULL(dst.PassportNo, '') = ISNULL(src.PassportNo, '')
    );

    SET @InsertedTahditLog = @@ROWCOUNT;
    PRINT N'-> TahditFormLog: ' + CAST(@InsertedTahditLog AS NVARCHAR(10)) + N' yeni tahdit sorgu kaydi eklendi.';

    -- =========================================================================
    -- E) E_Sartli: V-84 Şartlı Giriş Kayıtları
    -- =========================================================================
    DECLARE @InsertedSartli INT = 0;

    INSERT INTO dbo.E_Sartli
    (
        fldBy,
        fldOrgin,
        fldBdate,
        fldDate,
        fldName,
        fldBorder
    )
    SELECT
        src.fldBy,
        src.fldOrgin,
        src.fldBdate,
        src.fldDate,
        src.fldName,
        src.fldBorder
    FROM [10.7.202.76].[CEZA].dbo.E_Sartli AS src
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.E_Sartli AS dst
        WHERE ISNULL(dst.fldDate, '1900-01-01') = ISNULL(src.fldDate, '1900-01-01')
          AND ISNULL(dst.fldName, '')           = ISNULL(src.fldName, '')
          AND ISNULL(dst.fldOrgin, '')          = ISNULL(src.fldOrgin, '')
    );

    SET @InsertedSartli = @@ROWCOUNT;
    PRINT N'-> E_Sartli: ' + CAST(@InsertedSartli AS NVARCHAR(10)) + N' yeni sartli giris kaydi eklendi.';

    -- =========================================================================
    -- F) E_Inad: INAD Yolcu İşlem Kayıtları
    -- =========================================================================
    DECLARE @InsertedInad INT = 0;

    IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL
    BEGIN
        INSERT INTO dbo.E_Inad
        (
            TarihSaat, AdSoyad, DogumT, DogumY, Cinsiyet, Uyruk, PasaportNo, BelgeNo,
            PasaportTuru, Beyan, GelenUcusNo, GelenHavayolu, GeldigiYer, GeldigiTarihSaat,
            InadSebepAciklama, InadSebep, GidenHavayolu, GidisUcusNo, GidisYer, GidisTarihSaat,
            Personel, UstAramaEsya, UcagaNakil, OzelGuvenlik, YerHizmetleriPersonel,
            YerHizmetleri, Refakat, Kapi, Valilik, Durum, Sicil
        )
        SELECT
            src.TarihSaat, src.AdSoyad, src.DogumT, src.DogumY, src.Cinsiyet, src.Uyruk, src.PasaportNo, src.BelgeNo,
            src.PasaportTuru, src.Beyan, src.GelenUcusNo, src.GelenHavayolu, src.GeldigiYer, src.GeldigiTarihSaat,
            src.InadSebepAciklama, src.InadSebep, src.GidenHavayolu, src.GidisUcusNo, src.GidisYer, src.GidisTarihSaat,
            src.Personel, src.UstAramaEsya, src.UcagaNakil, src.OzelGuvenlik, src.YerHizmetleriPersonel,
            src.YerHizmetleri, src.Refakat, src.Kapi, src.Valilik, src.Durum, src.Sicil
        FROM [10.7.202.76].[CEZA].dbo.E_Inad AS src
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.E_Inad AS dst
            WHERE ISNULL(dst.TarihSaat, '1900-01-01') = ISNULL(src.TarihSaat, '1900-01-01')
              AND ISNULL(LTRIM(RTRIM(dst.PasaportNo)), '') = ISNULL(LTRIM(RTRIM(src.PasaportNo)), '')
              AND ISNULL(dst.AdSoyad, '')              = ISNULL(src.AdSoyad, '')
        );

        SET @InsertedInad = @@ROWCOUNT;
        PRINT N'-> E_Inad: ' + CAST(@InsertedInad AS NVARCHAR(10)) + N' yeni INAD kaydi eklendi.';
    END

    -- =========================================================================
    -- G) E_Dilekce: Yolcu Dilekçe Kayıtları
    -- =========================================================================
    DECLARE @InsertedDilekce INT = 0;

    IF OBJECT_ID(N'dbo.E_Dilekce', N'U') IS NOT NULL
    BEGIN
        INSERT INTO dbo.E_Dilekce
        (
            AdSoyad, DogumTarih, DogumYeri, PasaportNo, Uyruk, Cinsiyet,
            GeldigiUlke, GeldigiTarih, Havayolu, UcusNo, GelisNedeni,
            Aciklama, PersonelSicil, PersonelAdSoyad, OlusturmaTarihi
        )
        SELECT
            src.AdSoyad, src.DogumTarih, src.DogumYeri, src.PasaportNo, src.Uyruk, src.Cinsiyet,
            src.GeldigiUlke, src.GeldigiTarih, src.Havayolu, src.UcusNo, src.GelisNedeni,
            src.Aciklama, src.PersonelSicil, src.PersonelAdSoyad, src.OlusturmaTarihi
        FROM [10.7.202.76].[CEZA].dbo.E_Dilekce AS src
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.E_Dilekce AS dst
            WHERE ISNULL(dst.OlusturmaTarihi, '1900-01-01') = ISNULL(src.OlusturmaTarihi, '1900-01-01')
              AND ISNULL(LTRIM(RTRIM(dst.PasaportNo)), '')   = ISNULL(LTRIM(RTRIM(src.PasaportNo)), '')
              AND ISNULL(dst.AdSoyad, '')                  = ISNULL(src.AdSoyad, '')
        );

        SET @InsertedDilekce = @@ROWCOUNT;
        PRINT N'-> E_Dilekce: ' + CAST(@InsertedDilekce AS NVARCHAR(10)) + N' yeni dilekce kaydi eklendi.';
    END

    -- =========================================================================
    -- H) ExamResult: Eğitim/Sınav Sonuçları
    -- =========================================================================
    DECLARE @InsertedExamResult INT = 0;

    IF OBJECT_ID(N'dbo.ExamResult', N'U') IS NOT NULL
    BEGIN
        INSERT INTO dbo.ExamResult
        (
            ExamId, UserId, Score, TotalQuestions, CorrectAnswers,
            WrongAnswers, EmptyAnswers, CompletedDate, IsSuccess, CertificateCode
        )
        SELECT
            src.ExamId,
            dstUser.fldId, -- 75'teki karşılık gelen User Id
            src.Score, src.TotalQuestions, src.CorrectAnswers,
            src.WrongAnswers, src.EmptyAnswers, src.CompletedDate, src.IsSuccess, src.CertificateCode
        FROM [10.7.202.76].[CEZA].dbo.ExamResult AS src
        INNER JOIN [10.7.202.76].[CEZA].dbo.E_User AS srcUser ON src.UserId = srcUser.fldId
        INNER JOIN dbo.E_User AS dstUser ON LTRIM(RTRIM(dstUser.fldSicil)) = LTRIM(RTRIM(srcUser.fldSicil))
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.ExamResult AS dst
            WHERE dst.ExamId = src.ExamId
              AND dst.UserId = dstUser.fldId
              AND dst.CompletedDate = src.CompletedDate
        );

        SET @InsertedExamResult = @@ROWCOUNT;
        PRINT N'-> ExamResult: ' + CAST(@InsertedExamResult AS NVARCHAR(10)) + N' yeni sinav sonucu eklendi.';
    END

    COMMIT TRANSACTION;

    PRINT N'------------------------------------------------------------------';
    PRINT N'[TAMAMLANDI] Senkronizasyon basariyla tamamlandi ve veriler kaydedildi.';
    PRINT N'------------------------------------------------------------------';

    -- Özet Sonuç Tablosu
    SELECT 
        @InsertedUsers        AS [Eklenen_E_User],
        @InsertedHistory      AS [Eklenen_E_History],
        @InsertedIsK          AS [Eklenen_E_IsK],
        @InsertedTahditLog    AS [Eklenen_TahditFormLog],
        @InsertedSartli       AS [Eklenen_E_Sartli],
        @InsertedInad         AS [Eklenen_E_Inad],
        @InsertedDilekce      AS [Eklenen_E_Dilekce],
        @InsertedExamResult   AS [Eklenen_ExamResult],
        GETDATE()             AS [Islem_Zamani];

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT N'------------------------------------------------------------------';
    PRINT N'[HATA] Senkronizasyon sirasinda hata olustu. Degisiklikler geri alindi (ROLLBACK).';
    PRINT N'Hata Mesaji: ' + ERROR_MESSAGE();
    PRINT N'Hata Satiri : ' + CAST(ERROR_LINE() AS NVARCHAR(10));
    PRINT N'------------------------------------------------------------------';

    THROW;
END CATCH;
GO
