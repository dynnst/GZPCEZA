/*
    Ana sunucudan 2. sunucuya veri cekme scripti

    Kaynak SQL Server : ANTHGZPSUNUCU\CEZA
    Hedef SQL Server  : ANHGZPCEZA
    Veritabani        : CEZA

    Calistirma yeri:
      Bu scripti 2. sunucuda (ANHGZPCEZA), CEZA veritabani uzerinde calistirin.

    Notlar:
      - E_User aktariminda kriter fldSicil'dir. Hedefte ayni fldSicil varsa atlanir.
      - E_IsK ve E_History icin fldId aktarilmaz. Hedef sunucu yeni identity Id uretir.
      - E_IsK ve E_History icin dogal tekil kriter olmadigindan, script tekrar calistirilirsa
        bu iki tabloya ayni veriler tekrar eklenebilir. Id cakismasi olmaz.
*/

USE [CEZA];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @SourceServer sysname = N'ANTHGZPSUNUCU\CEZA';
DECLARE @SourceDb sysname = N'CEZA';

IF NOT EXISTS (SELECT 1 FROM sys.servers WHERE name = @SourceServer)
BEGIN
    EXEC master.dbo.sp_addlinkedserver
        @server = @SourceServer,
        @srvproduct = N'SQL Server';

    EXEC master.dbo.sp_addlinkedsrvlogin
        @rmtsrvname = @SourceServer,
        @useself = N'True';
END;
GO

BEGIN TRY
    BEGIN TRANSACTION;

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
        src.Role,
        src.LastLogin,
        src.XP,
        src.Level,
        src.IsActive,
        src.TeacherRequestStatus,
        src.TeacherRequestDate
    FROM [ANTHGZPSUNUCU\CEZA].[CEZA].dbo.E_User AS src
    WHERE src.fldSicil IS NOT NULL
      AND NOT EXISTS
      (
          SELECT 1
          FROM dbo.E_User AS dst
          WHERE dst.fldSicil = src.fldSicil
      );

    DECLARE @InsertedUsers int = @@ROWCOUNT;

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
    FROM [ANTHGZPSUNUCU\CEZA].[CEZA].dbo.E_IsK AS src;

    DECLARE @InsertedIsK int = @@ROWCOUNT;

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
    FROM [ANTHGZPSUNUCU\CEZA].[CEZA].dbo.E_History AS src;

    DECLARE @InsertedHistory int = @@ROWCOUNT;

    COMMIT TRANSACTION;

    SELECT
        @InsertedUsers AS Inserted_E_User,
        @InsertedIsK AS Inserted_E_IsK,
        @InsertedHistory AS Inserted_E_History;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO
