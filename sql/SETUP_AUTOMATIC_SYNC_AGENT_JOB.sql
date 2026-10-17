/*
====================================================================================================
    CEZAM - SQL Server Agent Otomatik Senkronizasyon Job Kurulum Scripti
====================================================================================================
    Açıklama:
      Bu script, 10.7.202.75 (Ana Sunucu) üzerindeki SQL Server Agent servisine
      "CEZAM_Sync_From_Backup_76" adında bir zamanlanmış görev (Job) ekler.

    Zamanlama Varsayılanı:
      - Her gün, saat 03:00'te otomatik çalışır.
      - İsteğe göre saat başı veya her 15 dakikada bir çalışacak şekilde de değiştirilebilir.

    Çalıştırma Yeri:
      10.7.202.75 sunucusunda SSMS üzerinde "sa" veya sysadmin yetkisiyle çalıştırın.
====================================================================================================
*/

USE [msdb];
GO

DECLARE @JobName        sysname       = N'CEZAM_Sync_From_Backup_76';
DECLARE @StepName       sysname       = N'Run_Sync_76_to_75';
DECLARE @ScheduleName   sysname       = N'CEZAM_Daily_Nightly_Sync';
DECLARE @DatabaseName   sysname       = N'CEZA';
DECLARE @SqlScriptPath  NVARCHAR(500) = N'C:\CEZAM\sql\SYNC_76_TO_75_BACKUP_TO_PRIMARY.sql';

-- 1. Varsa eski Job'ı temizle
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = @JobName)
BEGIN
    PRINT N'[BILGI] Eski ' + @JobName + N' gorevi kaldiriliyor...';
    EXEC msdb.dbo.sp_delete_job @job_name = @JobName, @delete_unused_schedule = 1;
END

-- 2. Yeni Job Oluştur
PRINT N'[BILGI] Yeni senkronizasyon gorevi olusturuluyor...';
EXEC msdb.dbo.sp_add_job
    @job_name              = @JobName,
    @enabled               = 1,
    @notify_level_eventlog = 2,
    @description           = N'76 Yedek Sunucusundan 75 Ana Sunucusuna yeni verileri mukerrerlik olmadan otomatik ceker.';

-- 3. Job Adımını Ekle (Sync Scriptini Çalıştırır)
-- Komut içeriği: SYNC_76_TO_75_BACKUP_TO_PRIMARY.sql scriptinin içeriğini doğrudan çağırır
EXEC msdb.dbo.sp_add_jobstep
    @job_name         = @JobName,
    @step_name        = @StepName,
    @subsystem        = N'TSQL',
    @database_name    = @DatabaseName,
    @command          = N'
-- 76 Yedek Sunucudan 75 Ana Sunucuya Veri Aktarimi
EXEC sp_executesql N''
    INSERT INTO dbo.E_User (fldSicil, fldName, fldLastName, fldPhone, fldEmail, fldTitle, fldDeputy, fldPicture, fldAuth, fldSubAuth, fldPassword, fldDateTime, fldBorder, fldActive, Role, LastLogin, XP, Level, IsActive)
    SELECT src.fldSicil, src.fldName, src.fldLastName, src.fldPhone, src.fldEmail, src.fldTitle, src.fldDeputy, src.fldPicture, src.fldAuth, src.fldSubAuth, src.fldPassword, src.fldDateTime, src.fldBorder, src.fldActive, ISNULL(src.Role, ''''User''''), src.LastLogin, ISNULL(src.XP, 0), ISNULL(src.Level, 1), ISNULL(src.IsActive, 1)
    FROM [10.7.202.76].[CEZA].dbo.E_User AS src
    WHERE src.fldSicil IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.E_User AS dst WHERE LTRIM(RTRIM(dst.fldSicil)) = LTRIM(RTRIM(src.fldSicil)));

    INSERT INTO dbo.E_History (fldStart, fldShouldExit, fldBirthDate, fldCountry, fldPenalty, fldPMoney, fldUser, fldBorder, fldDatetime)
    SELECT src.fldStart, src.fldShouldExit, src.fldBirthDate, src.fldCountry, src.fldPenalty, src.fldPMoney, src.fldUser, src.fldBorder, src.fldDatetime
    FROM [10.7.202.76].[CEZA].dbo.E_History AS src
    WHERE NOT EXISTS (SELECT 1 FROM dbo.E_History AS dst WHERE ISNULL(dst.fldDatetime, ''''1900-01-01'''') = ISNULL(src.fldDatetime, ''''1900-01-01'''') AND ISNULL(dst.fldUser, '''''') = ISNULL(src.fldUser, '''''') AND ISNULL(dst.fldStart, ''''1900-01-01'''') = ISNULL(src.fldStart, ''''1900-01-01''''));

    INSERT INTO dbo.E_IsK (fldDatetime, fldName, fldPassport, fldIdn, fldOrgin, fldBirthdate, fldForm, fldPassControl, fldApproval, fldBorder, fldVisa, fldPMoney, fldPicture)
    SELECT src.fldDatetime, src.fldName, src.fldPassport, src.fldIdn, src.fldOrgin, src.fldBirthdate, src.fldForm, src.fldPassControl, src.fldApproval, src.fldBorder, src.fldVisa, src.fldPMoney, src.fldPicture
    FROM [10.7.202.76].[CEZA].dbo.E_IsK AS src
    WHERE NOT EXISTS (SELECT 1 FROM dbo.E_IsK AS dst WHERE ISNULL(dst.fldDatetime, ''''1900-01-01'''') = ISNULL(src.fldDatetime, ''''1900-01-01'''') AND ISNULL(LTRIM(RTRIM(dst.fldPassport)), '''''') = ISNULL(LTRIM(RTRIM(src.fldPassport)), ''''''));

    INSERT INTO dbo.TahditFormLog (CreatedAt, TahditCode, IdariTahditCode, PenaltyDay, PenaltyMonth, PenaltyTotalDay, PaymentType, VisaType, Country, Border, UserId, UserSicil, UserDisplayName, PassengerName, PassportNo, FormMoney)
    SELECT src.CreatedAt, src.TahditCode, src.IdariTahditCode, src.PenaltyDay, src.PenaltyMonth, src.PenaltyTotalDay, src.PaymentType, src.VisaType, src.Country, src.Border, src.UserId, src.UserSicil, src.UserDisplayName, src.PassengerName, src.PassportNo, src.FormMoney
    FROM [10.7.202.76].[CEZA].dbo.TahditFormLog AS src
    WHERE NOT EXISTS (SELECT 1 FROM dbo.TahditFormLog AS dst WHERE dst.CreatedAt = src.CreatedAt AND ISNULL(dst.UserSicil, '''''') = ISNULL(src.UserSicil, '''''') AND ISNULL(dst.PassportNo, '''''') = ISNULL(src.PassportNo, ''''''));

    INSERT INTO dbo.E_Sartli (fldBy, fldOrgin, fldBdate, fldDate, fldName, fldBorder)
    SELECT src.fldBy, src.fldOrgin, src.fldBdate, src.fldDate, src.fldName, src.fldBorder
    FROM [10.7.202.76].[CEZA].dbo.E_Sartli AS src
    WHERE NOT EXISTS (SELECT 1 FROM dbo.E_Sartli AS dst WHERE ISNULL(dst.fldDate, ''''1900-01-01'''') = ISNULL(src.fldDate, ''''1900-01-01'''') AND ISNULL(dst.fldName, '''''') = ISNULL(src.fldName, ''''''));
'';',
    @retry_attempts   = 3,
    @retry_interval   = 5;

-- 4. Zamanlama Tanımla (Her Gece Saat 03:00'te Çalışır)
EXEC msdb.dbo.sp_add_jobschedule
    @job_name               = @JobName,
    @name                   = @ScheduleName,
    @enabled                = 1,
    @freq_type              = 4,        -- Günlük (Daily)
    @freq_interval          = 1,        -- Her 1 günde bir
    @active_start_time      = 030000;   -- 03:00:00

-- 5. Hedef Sunucuya Ata
EXEC msdb.dbo.sp_add_jobserver
    @job_name    = @JobName,
    @server_name = N'(local)';

PRINT N'[BASARILI] SQL Server Agent Job ' + @JobName + N' basariyla olusturuldu ve zamanlandi.';
GO
