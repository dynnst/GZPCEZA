USE[CEZA]
GO

-- =============================================
    --TABLOLAR(mevcut ise atla)
-- =============================================

    IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = '__MigrationHistory' AND xtype = 'U')
CREATE TABLE[dbo].[__MigrationHistory](
        [MigrationId]    NVARCHAR(255) NOT NULL,
        [Model]          VARBINARY(MAX) NOT NULL,
        [ProductVersion] NVARCHAR(32)  NOT NULL,
        CONSTRAINT[PK___MigrationHistory] PRIMARY KEY([MigrationId])
    );
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'E_User' AND xtype = 'U')
CREATE TABLE[dbo].[E_User](
    [fldId]                  INT           IDENTITY(1, 1) NOT NULL,
    [fldSicil]               NVARCHAR(MAX) NULL,
    [fldName]                NVARCHAR(MAX) NULL,
    [fldLastName]            NVARCHAR(MAX) NULL,
    [fldPhone]               NVARCHAR(MAX) NULL,
    [fldEmail]               NVARCHAR(MAX) NULL,
    [fldTitle]               NVARCHAR(MAX) NULL,
    [fldDeputy]              NVARCHAR(MAX) NULL,
    [fldPicture]             NVARCHAR(MAX) NULL,
    [fldAuth]                NVARCHAR(MAX) NULL,
    [fldSubAuth]             NVARCHAR(MAX) NULL,
    [fldPassword]            NVARCHAR(MAX) NULL,
    [fldDateTime]            DATETIME      NULL,
    [fldBorder]              NVARCHAR(MAX) NULL,
    [fldActive]              NCHAR(1)      NULL,
    [Role]                   NVARCHAR(20)  NOT NULL,
    [LastLogin]              DATETIME      NULL,
    [XP]                     INT           NOT NULL DEFAULT 0,
    [Level]                  INT           NOT NULL DEFAULT 0,
    [IsActive]               BIT           NULL,
    [TeacherRequestStatus]   TINYINT       NULL,
    [TeacherRequestDate]     DATETIME      NULL,
    CONSTRAINT[PK_E_User] PRIMARY KEY([fldId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'tbl_TempUser' AND xtype = 'U')
CREATE TABLE[dbo].[tbl_TempUser](
    [fldId]       INT           IDENTITY(1, 1) NOT NULL,
    [fldSicil]    NVARCHAR(MAX) NULL,
    [fldName]     NVARCHAR(MAX) NULL,
    [fldLastName] NVARCHAR(MAX) NULL,
    [fldPhone]    NVARCHAR(MAX) NULL,
    [fldEmail]    NVARCHAR(MAX) NULL,
    [fldTitle]    NVARCHAR(MAX) NULL,
    [fldDeputy]   NVARCHAR(MAX) NULL,
    CONSTRAINT[PK_tbl_TempUser] PRIMARY KEY([fldId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'E_Token' AND xtype = 'U')
CREATE TABLE[dbo].[E_Token](
    [fldId]       INT           IDENTITY(1, 1) NOT NULL,
    [fldUserId]   INT           NULL,
    [fldToken]    NVARCHAR(MAX) NULL,
    [fldDateTime] DATETIME      NULL,
    [fldIp]       NVARCHAR(50)  NULL,
    CONSTRAINT[PK_E_Token] PRIMARY KEY([fldId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'E_Border' AND xtype = 'U')
CREATE TABLE[dbo].[E_Border](
    [fldId]   INT           IDENTITY(1, 1) NOT NULL,
    [fldName] NVARCHAR(MAX) NULL,
    CONSTRAINT[PK_E_Border] PRIMARY KEY([fldId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'E_AUH' AND xtype = 'U')
CREATE TABLE[dbo].[E_AUH](
    [fldId]          INT           IDENTITY(1, 1) NOT NULL,
    [fldCountry]     NVARCHAR(MAX) NULL,
    [fldFirstMounth] NVARCHAR(MAX) NULL,
    [fldKat]         NVARCHAR(MAX) NULL,
    [fldDayStart]    NVARCHAR(MAX) NULL,
    [fldDayKat]      NVARCHAR(MAX) NULL,
    [fldToM]         NVARCHAR(MAX) NULL,
    CONSTRAINT[PK_E_AUH] PRIMARY KEY([fldId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'E_UVR' AND xtype = 'U')
CREATE TABLE[dbo].[E_UVR](
    [fldId]            INT           IDENTITY(1, 1) NOT NULL,
    [fldCountry]       NVARCHAR(MAX) NULL,
    [fldCalculateType] INT           NULL,
    [fldPassportType]  INT           NULL,
    [fldVisaStatus]    INT           NULL,
    [fldDay]           INT           NULL,
    [fldLong]          INT           NULL,
    [fldOneTime]       INT           NULL,
    [fldHB]            TINYINT       NULL,
    CONSTRAINT[PK_E_UVR] PRIMARY KEY([fldId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'E_Exchange' AND xtype = 'U')
CREATE TABLE[dbo].[E_Exchange](
    [fldId]     INT          IDENTITY(1, 1) NOT NULL,
    [fldEuro]   NVARCHAR(50) NULL,
    [fldDollar] NVARCHAR(50) NULL,
    [fldPaund]  NVARCHAR(50) NULL,
    CONSTRAINT[PK_E_Exchange] PRIMARY KEY([fldId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'E_Defter' AND xtype = 'U')
CREATE TABLE[dbo].[E_Defter](
    [fldId]          INT          IDENTITY(1, 1) NOT NULL,
    [fldPrice]       NVARCHAR(25) NULL,
    [fldTypeofMoney] NVARCHAR(50) NULL,
    CONSTRAINT[PK_E_Defter] PRIMARY KEY([fldId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'E_TGVH' AND xtype = 'U')
CREATE TABLE[dbo].[E_TGVH](
    [fldId]          INT          IDENTITY(1, 1) NOT NULL,
    [fldPrice]       NVARCHAR(25) NULL,
    [fldTypeofMoney] NVARCHAR(25) NULL,
    [fldYear]        NVARCHAR(25) NULL,
    CONSTRAINT[PK_E_TGVH] PRIMARY KEY([fldId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'E_TKOD' AND xtype = 'U')
CREATE TABLE[dbo].[E_TKOD](
    [fldId]        INT          IDENTITY(1, 1) NOT NULL,
    [fldCode]      NVARCHAR(50) NULL,
    [fldPTime]     NVARCHAR(50) NULL,
    [fldStart]     INT          NULL,
    [fldFinish]    INT          NULL,
    [fldIdariCode] NVARCHAR(50) NULL,
    [fldPaid]      TINYINT      NULL,
    CONSTRAINT[PK_E_TKOD] PRIMARY KEY([fldId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'E_Forms' AND xtype = 'U')
CREATE TABLE[dbo].[E_Forms](
    [fldId]         INT           IDENTITY(1, 1) NOT NULL,
    [fldGB]         NVARCHAR(MAX) NULL,
    [fldDE]         NVARCHAR(MAX) NULL,
    [fldRU]         NVARCHAR(MAX) NULL,
    [fldIR]         NVARCHAR(MAX) NULL,
    [fldGBC]        NVARCHAR(MAX) NULL,
    [fldDEC]        NVARCHAR(MAX) NULL,
    [fldRUC]        NVARCHAR(MAX) NULL,
    [fldIRC]        NVARCHAR(MAX) NULL,
    [fldIRKC]       NVARCHAR(MAX) NULL,
    [fldIRK]        NVARCHAR(MAX) NULL,
    [fldFransizca]  NVARCHAR(MAX) NULL,
    [fldFransizcaC] NVARCHAR(MAX) NULL,
    CONSTRAINT[PK_E_Forms] PRIMARY KEY([fldId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'E_History' AND xtype = 'U')
CREATE TABLE[dbo].[E_History](
    [fldId]         INT           IDENTITY(1, 1) NOT NULL,
    [fldStart]      DATETIME      NULL,
    [fldShouldExit] DATETIME      NULL,
    [fldBirthDate]  DATETIME      NULL,
    [fldCountry]    NVARCHAR(MAX) NULL,
    [fldPenalty]    NVARCHAR(MAX) NULL,
    [fldPMoney]     NVARCHAR(MAX) NULL,
    [fldUser]       NVARCHAR(MAX) NULL,
    [fldBorder]     NVARCHAR(MAX) NULL,
    [fldDatetime]   DATETIME      NULL,
    CONSTRAINT[PK_E_History] PRIMARY KEY([fldId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'E_IsK' AND xtype = 'U')
CREATE TABLE[dbo].[E_IsK](
    [fldId]          INT           IDENTITY(1, 1) NOT NULL,
    [fldDatetime]    DATETIME      NULL,
    [fldName]        NVARCHAR(MAX) NULL,
    [fldPassport]    NVARCHAR(MAX) NULL,
    [fldIdn]         NVARCHAR(MAX) NULL,
    [fldOrgin]       NVARCHAR(MAX) NULL,
    [fldBirthdate]   DATE          NULL,
    [fldForm]        NVARCHAR(MAX) NULL,
    [fldPassControl] NVARCHAR(MAX) NULL,
    [fldApproval]    NVARCHAR(MAX) NULL,
    [fldBorder]      NVARCHAR(MAX) NULL,
    [fldVisa]        NVARCHAR(MAX) NULL,
    [fldPMoney]      NVARCHAR(MAX) NULL,
    [fldPicture]     NVARCHAR(MAX) NULL,
    CONSTRAINT[PK_E_IsK] PRIMARY KEY([fldId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'E_Sartli' AND xtype = 'U')
CREATE TABLE[dbo].[E_Sartli](
    [fldId]     INT           IDENTITY(1, 1) NOT NULL,
    [fldBy]     VARCHAR(150)  NULL,
    [fldOrgin]  NVARCHAR(50)  NULL,
    [fldBdate]  DATE          NULL,
    [fldDate]   DATETIME      NULL,
    [fldName]   NVARCHAR(250) NULL,
    [fldBorder] NVARCHAR(500) NULL,
    CONSTRAINT[PK_E_Sartli] PRIMARY KEY([fldId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'E_Inad' AND xtype = 'U')
CREATE TABLE[dbo].[E_Inad](
    [InadId]                INT           IDENTITY(1, 1) NOT NULL,
    [TarihSaat]             DATE          NULL,
    [AdSoyad]               NCHAR(50)     NULL,
    [DogumT]                DATE          NULL,
    [DogumY]                NVARCHAR(50)  NULL,
    [Cinsiyet]              NVARCHAR(10)  NULL,
    [Uyruk]                 NCHAR(250)    NULL,
    [PasaportNo]            NCHAR(20)     NULL,
    [BelgeNo]               NVARCHAR(20)  NULL,
    [PasaportTuru]          NCHAR(50)     NULL,
    [Beyan]                 NVARCHAR(100) NULL,
    [GelenUcusNo]           NVARCHAR(10)  NULL,
    [GelenHavayolu]         NVARCHAR(150) NULL,
    [GeldigiYer]            NCHAR(250)    NULL,
    [GeldigiTarihSaat]      DATETIME      NULL,
    [InadSebepAciklama]     NVARCHAR(MAX) NULL,
    [InadSebep]             NVARCHAR(MAX) NULL,
    [GidenHavayolu]         NVARCHAR(150) NULL,
    [GidisUcusNo]           NVARCHAR(10)  NULL,
    [GidisYer]              NCHAR(250)    NULL,
    [GidisTarihSaat]        DATETIME      NULL,
    [Personel]              NVARCHAR(MAX) NULL,
    [UstAramaEsya]          NVARCHAR(MAX) NULL,
    [UcagaNakil]            NVARCHAR(MAX) NULL,
    [OzelGuvenlik]          NVARCHAR(50)  NULL,
    [YerHizmetleriPersonel] NVARCHAR(50)  NULL,
    [YerHizmetleri]         NCHAR(250)    NULL,
    [Refakat]               NVARCHAR(250) NULL,
    [Kapi]                  NVARCHAR(MAX) NULL,
    [Valilik]               NVARCHAR(MAX) NULL,
    [Durum]                 NVARCHAR(MAX) NULL,
    [Sicil]                 NVARCHAR(MAX) NULL,
    CONSTRAINT[PK_E_Inad] PRIMARY KEY([InadId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'E_Messages' AND xtype = 'U')
CREATE TABLE[dbo].[E_Messages](
    [fldId]                   INT           IDENTITY(1, 1) NOT NULL,
    [fldSendByName]           NVARCHAR(MAX) NULL,
    [fldSendBySicil]          NVARCHAR(MAX) NULL,
    [fldSendByPhone]          NVARCHAR(MAX) NULL,
    [fldSendByMail]           NVARCHAR(MAX) NULL,
    [fldDateTime]             DATETIME      NULL,
    [fldMessage]              NVARCHAR(MAX) NULL,
    [fldSenderId]             INT           NULL,
    [fldSenderRole]           NVARCHAR(20)  NULL,
    [fldRecipientId]          INT           NULL,
    [fldRecipientRole]        NVARCHAR(20)  NULL,
    [fldSubject]              NVARCHAR(200) NULL,
    [fldIsRead]               BIT           NOT NULL DEFAULT 0,
    [fldReadDateTime]         DATETIME      NULL,
    [fldIsDeletedBySender]    BIT           NOT NULL DEFAULT 0,
    [fldIsDeletedByRecipient] BIT           NOT NULL DEFAULT 0,
    [fldParentMessageId]      INT           NULL,
    [fldIsReply]              BIT           NOT NULL DEFAULT 0,
    CONSTRAINT[PK_E_Messages] PRIMARY KEY([fldId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'Airline' AND xtype = 'U')
CREATE TABLE[dbo].[Airline](
    [Id]            INT           IDENTITY(1, 1) NOT NULL,
    [IATACode]      NVARCHAR(7)   NOT NULL,
    [Name]          NVARCHAR(150) NOT NULL,
    [Country]       NVARCHAR(100) NULL,
    [IsActive]      BIT           NOT NULL,
    [IsUserDefined] BIT           NULL,
    [CreatedDate]   DATETIME      NULL,
    CONSTRAINT[PK_Airline] PRIMARY KEY([Id])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'Categories' AND xtype = 'U')
CREATE TABLE[dbo].[Categories](
    [CategoryId]   INT           IDENTITY(1, 1) NOT NULL,
    [CategoryName] NVARCHAR(200) NOT NULL,
    [Description]  NVARCHAR(MAX) NULL,
    [IsActive]     BIT           NOT NULL,
    CONSTRAINT[PK_Categories] PRIMARY KEY([CategoryId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'Courses' AND xtype = 'U')
CREATE TABLE[dbo].[Courses](
    [CourseId]          INT           IDENTITY(1, 1) NOT NULL,
    [CourseTitle]       NVARCHAR(200) NOT NULL,
    [CourseDescription] NVARCHAR(MAX) NULL,
    [CoverImage]        NVARCHAR(MAX) NULL,
    [CreatedBy]         INT           NOT NULL,
    [CreatedDate]       DATETIME      NULL,
    [CategoryId]        INT           NOT NULL,
    [ResourceFile]      NVARCHAR(MAX) NULL,
    [IsActive]          BIT           NOT NULL,
    [IsDeleted]         BIT           NULL,
    CONSTRAINT[PK_Courses] PRIMARY KEY([CourseId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'CourseContents' AND xtype = 'U')
CREATE TABLE[dbo].[CourseContents](
    [ContentId]          INT           IDENTITY(1, 1) NOT NULL,
    [CourseId]           INT           NOT NULL,
    [ContentType]        NVARCHAR(20)  NOT NULL,
    [ContentTitle]       NVARCHAR(200) NULL,
    [FilePath]           NVARCHAR(500) NOT NULL,
    [CreatedDate]        DATETIME      NULL,
    [ContentDescription] NVARCHAR(MAX) NULL,
    CONSTRAINT[PK_CourseContents] PRIMARY KEY([ContentId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'CourseEnrollments' AND xtype = 'U')
CREATE TABLE[dbo].[CourseEnrollments](
    [EnrollmentId]   INT      IDENTITY(1, 1) NOT NULL,
    [CourseId]       INT      NOT NULL,
    [UserId]         INT      NOT NULL,
    [EnrollmentDate] DATETIME NULL,
    [IsDrawEntry]    BIT      NOT NULL DEFAULT 0,
    [DrawEntryDate]  DATETIME NULL,
    CONSTRAINT[PK_CourseEnrollments] PRIMARY KEY([EnrollmentId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'CourseReviews' AND xtype = 'U')
CREATE TABLE[dbo].[CourseReviews](
    [ReviewId]     INT           IDENTITY(1, 1) NOT NULL,
    [CourseId]     INT           NOT NULL,
    [UserId]       INT           NOT NULL,
    [Rating]       TINYINT       NOT NULL,
    [Comment]      NVARCHAR(MAX) NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [IsApproved]   BIT           NOT NULL DEFAULT 0,
    [ApprovedBy]   INT           NULL,
    [ApprovedDate] DATETIME      NULL,
    CONSTRAINT[PK_CourseReviews] PRIMARY KEY([ReviewId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'Exam' AND xtype = 'U')
CREATE TABLE[dbo].[Exam](
    [ExamId]          INT           IDENTITY(1, 1) NOT NULL,
    [CourseId]        INT           NOT NULL,
    [Title]           NVARCHAR(200) NOT NULL,
    [Description]     NVARCHAR(MAX) NULL,
    [DurationMinutes] INT           NULL,
    [PassingScore]    INT           NULL,
    [IsActive]        BIT           NOT NULL,
    [CreatedAt]       DATETIME      NOT NULL,
    [IsArchived]      BIT           NULL,
    CONSTRAINT[PK_Exam] PRIMARY KEY([ExamId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'ExamResult' AND xtype = 'U')
CREATE TABLE[dbo].[ExamResult](
    [ExamResultId] INT          IDENTITY(1, 1) NOT NULL,
    [ExamId]       INT          NOT NULL,
    [UserId]       INT          NULL,
    [Score]        DECIMAL(5, 2) NULL,
    [StartedAt]    DATETIME     NULL,
    [FinishedAt]   DATETIME     NULL,
    [Status]       TINYINT      NOT NULL,
    CONSTRAINT[PK_ExamResult] PRIMARY KEY([ExamResultId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'Question' AND xtype = 'U')
CREATE TABLE[dbo].[Question](
    [QuestionId]   INT           IDENTITY(1, 1) NOT NULL,
    [ExamId]       INT           NOT NULL,
    [Text]         NVARCHAR(MAX) NOT NULL,
    [QuestionType] TINYINT       NOT NULL,
    [Points]       INT           NOT NULL,
    [SortOrder]    INT           NOT NULL,
    [IsActive]     BIT           NULL,
    CONSTRAINT[PK_Question] PRIMARY KEY([QuestionId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'QuestionOption' AND xtype = 'U')
CREATE TABLE[dbo].[QuestionOption](
    [OptionId]   INT           IDENTITY(1, 1) NOT NULL,
    [QuestionId] INT           NOT NULL,
    [Text]       NVARCHAR(MAX) NOT NULL,
    [IsCorrect]  BIT           NOT NULL,
    [SortOrder]  INT           NOT NULL,
    CONSTRAINT[PK_QuestionOption] PRIMARY KEY([OptionId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'QuestionMedia' AND xtype = 'U')
CREATE TABLE[dbo].[QuestionMedia](
    [MediaId]    INT           IDENTITY(1, 1) NOT NULL,
    [QuestionId] INT           NOT NULL,
    [MediaType]  TINYINT       NOT NULL,
    [MediaPath]  NVARCHAR(MAX) NOT NULL,
    [SortOrder]  INT           NOT NULL,
    [CreatedAt]  DATETIME      NOT NULL,
    CONSTRAINT[PK_QuestionMedia] PRIMARY KEY([MediaId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'Answer' AND xtype = 'U')
CREATE TABLE[dbo].[Answer](
    [AnswerId]     INT           IDENTITY(1, 1) NOT NULL,
    [ExamResultId] INT           NOT NULL,
    [QuestionId]   INT           NOT NULL,
    [OptionId]     INT           NULL,
    [TextAnswer]   NVARCHAR(MAX) NULL,
    CONSTRAINT[PK_Answer] PRIMARY KEY([AnswerId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'Certificate' AND xtype = 'U')
CREATE TABLE[dbo].[Certificate](
    [CertificateId]     INT           IDENTITY(1, 1) NOT NULL,
    [UserId]            INT           NOT NULL,
    [CourseId]          INT           NOT NULL,
    [ExamResultId]      INT           NULL,
    [CertificateNumber] NVARCHAR(50)  NOT NULL,
    [FilePath]          NVARCHAR(500) NULL,
    [IssuedDate]        DATETIME      NOT NULL,
    [Score]             INT           NOT NULL,
    [IsActive]          BIT           NOT NULL,
    [CreatedAt]         DATETIME      NOT NULL,
    CONSTRAINT[PK_Certificate] PRIMARY KEY([CertificateId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'CertificateRequest' AND xtype = 'U')
CREATE TABLE[dbo].[CertificateRequest](
    [RequestId]     INT           IDENTITY(1, 1) NOT NULL,
    [UserId]        INT           NOT NULL,
    [CourseId]      INT           NOT NULL,
    [RequestDate]   DATETIME      NOT NULL,
    [Status]        TINYINT       NOT NULL,
    [AdminNote]     NVARCHAR(500) NULL,
    [ProcessedDate] DATETIME      NULL,
    [ProcessedBy]   INT           NULL,
    CONSTRAINT[PK_CertificateRequest] PRIMARY KEY([RequestId])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'DocumentTerms' AND xtype = 'U')
CREATE TABLE[dbo].[DocumentTerms](
    [Id]                  INT           IDENTITY(1, 1) NOT NULL,
    [Term]                NVARCHAR(200) NOT NULL,
    [Slug]                NVARCHAR(250) NOT NULL,
    [Category]            NVARCHAR(100) NOT NULL,
    [Definition]          NVARCHAR(MAX) NOT NULL,
    [DetailedDescription] NVARCHAR(MAX) NULL,
    [ImageUrl]            NVARCHAR(500) NULL,
    [RelatedTerms]        NVARCHAR(500) NULL,
    [IsActive]            BIT           NOT NULL,
    [CreatedAt]           DATETIME      NULL,
    [UpdatedAt]           DATETIME      NULL,
    [Sicil]               NVARCHAR(50)  NULL,
    [AdSoyad]             NVARCHAR(200) NULL,
    CONSTRAINT[PK_DocumentTerms] PRIMARY KEY([Id])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'TahditKod' AND xtype = 'U')
CREATE TABLE[dbo].[TahditKod](
    [Id]           INT           IDENTITY(1, 1) NOT NULL,
    [Kod]          NVARCHAR(20)  NOT NULL,
    [Aciklama]     NVARCHAR(500) NOT NULL,
    [SureAy]       INT           NULL,
    [Aktif]        BIT           NOT NULL,
    [GirisGelirse] NVARCHAR(MAX) NULL,
    [CikisGelirse] NVARCHAR(MAX) NULL,
    [TahditMedia]  NVARCHAR(MAX) NULL,
    CONSTRAINT[PK_TahditKod] PRIMARY KEY([Id])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'SorguCevaplari' AND xtype = 'U')
CREATE TABLE[dbo].[SorguCevaplari](
    [Id]               INT           IDENTITY(1, 1) NOT NULL,
    [AnahtarKelimeler] NVARCHAR(200) NOT NULL,
    [Cevap]            NVARCHAR(MAX) NOT NULL,
    [Kategori]         NVARCHAR(100) NULL,
    [Aktif]            BIT           NULL,
    [OlusturmaTarihi]  DATETIME      NULL,
    [ResimUrl]         NVARCHAR(MAX) NULL,
    CONSTRAINT[PK_SorguCevaplari] PRIMARY KEY([Id])
);
GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'SorguLoglari' AND xtype = 'U')
CREATE TABLE[dbo].[SorguLoglari](
    [Id]           INT            IDENTITY(1, 1) NOT NULL,
    [Soru]         NVARCHAR(500)  NOT NULL,
    [Cevap]        NVARCHAR(1000) NULL,
    [KullaniciAdi] NVARCHAR(100)  NULL,
    [IpAdresi]     NVARCHAR(50)   NULL,
    [Tarih]        DATETIME       NULL,
    [BasariDurumu] BIT            NULL,
    CONSTRAINT[PK_SorguLoglari] PRIMARY KEY([Id])
);
GO

-- =============================================
-- GENEL KOLON TAMAMLAMA
-- CREATE TABLE listesine gore eksik kolonlari ekler.
-- Mevcut satirlara veri basmamak icin sonradan eklenen kolonlar NULL kabul eder.
-- =============================================
IF OBJECT_ID(N'dbo.__MigrationHistory', N'U') IS NOT NULL AND COL_LENGTH('dbo.__MigrationHistory', 'Model') IS NULL
    ALTER TABLE [dbo].[__MigrationHistory] ADD [Model] VARBINARY(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.__MigrationHistory', N'U') IS NOT NULL AND COL_LENGTH('dbo.__MigrationHistory', 'ProductVersion') IS NULL
    ALTER TABLE [dbo].[__MigrationHistory] ADD [ProductVersion] NVARCHAR(32) NULL;
GO

IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_User', 'fldSicil') IS NULL
    ALTER TABLE [dbo].[E_User] ADD [fldSicil] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_User', 'fldName') IS NULL
    ALTER TABLE [dbo].[E_User] ADD [fldName] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_User', 'fldLastName') IS NULL
    ALTER TABLE [dbo].[E_User] ADD [fldLastName] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_User', 'fldPhone') IS NULL
    ALTER TABLE [dbo].[E_User] ADD [fldPhone] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_User', 'fldEmail') IS NULL
    ALTER TABLE [dbo].[E_User] ADD [fldEmail] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_User', 'fldTitle') IS NULL
    ALTER TABLE [dbo].[E_User] ADD [fldTitle] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_User', 'fldDeputy') IS NULL
    ALTER TABLE [dbo].[E_User] ADD [fldDeputy] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_User', 'fldPicture') IS NULL
    ALTER TABLE [dbo].[E_User] ADD [fldPicture] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_User', 'fldAuth') IS NULL
    ALTER TABLE [dbo].[E_User] ADD [fldAuth] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_User', 'fldSubAuth') IS NULL
    ALTER TABLE [dbo].[E_User] ADD [fldSubAuth] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_User', 'fldPassword') IS NULL
    ALTER TABLE [dbo].[E_User] ADD [fldPassword] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_User', 'fldDateTime') IS NULL
    ALTER TABLE [dbo].[E_User] ADD [fldDateTime] DATETIME      NULL;
GO

IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_User', 'fldBorder') IS NULL
    ALTER TABLE [dbo].[E_User] ADD [fldBorder] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_User', 'fldActive') IS NULL
    ALTER TABLE [dbo].[E_User] ADD [fldActive] NCHAR(1)      NULL;
GO

IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_User', 'Role') IS NULL
    ALTER TABLE [dbo].[E_User] ADD [Role] NVARCHAR(20) NULL;
GO

IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_User', 'LastLogin') IS NULL
    ALTER TABLE [dbo].[E_User] ADD [LastLogin] DATETIME      NULL;
GO

IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_User', 'XP') IS NULL
    ALTER TABLE [dbo].[E_User] ADD [XP] INT NULL;
GO

IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_User', 'Level') IS NULL
    ALTER TABLE [dbo].[E_User] ADD [Level] INT NULL;
GO

IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_User', 'IsActive') IS NULL
    ALTER TABLE [dbo].[E_User] ADD [IsActive] BIT           NULL;
GO

IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_User', 'TeacherRequestStatus') IS NULL
    ALTER TABLE [dbo].[E_User] ADD [TeacherRequestStatus] TINYINT       NULL;
GO

IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_User', 'TeacherRequestDate') IS NULL
    ALTER TABLE [dbo].[E_User] ADD [TeacherRequestDate] DATETIME      NULL;
GO

IF OBJECT_ID(N'dbo.tbl_TempUser', N'U') IS NOT NULL AND COL_LENGTH('dbo.tbl_TempUser', 'fldSicil') IS NULL
    ALTER TABLE [dbo].[tbl_TempUser] ADD [fldSicil] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.tbl_TempUser', N'U') IS NOT NULL AND COL_LENGTH('dbo.tbl_TempUser', 'fldName') IS NULL
    ALTER TABLE [dbo].[tbl_TempUser] ADD [fldName] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.tbl_TempUser', N'U') IS NOT NULL AND COL_LENGTH('dbo.tbl_TempUser', 'fldLastName') IS NULL
    ALTER TABLE [dbo].[tbl_TempUser] ADD [fldLastName] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.tbl_TempUser', N'U') IS NOT NULL AND COL_LENGTH('dbo.tbl_TempUser', 'fldPhone') IS NULL
    ALTER TABLE [dbo].[tbl_TempUser] ADD [fldPhone] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.tbl_TempUser', N'U') IS NOT NULL AND COL_LENGTH('dbo.tbl_TempUser', 'fldEmail') IS NULL
    ALTER TABLE [dbo].[tbl_TempUser] ADD [fldEmail] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.tbl_TempUser', N'U') IS NOT NULL AND COL_LENGTH('dbo.tbl_TempUser', 'fldTitle') IS NULL
    ALTER TABLE [dbo].[tbl_TempUser] ADD [fldTitle] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.tbl_TempUser', N'U') IS NOT NULL AND COL_LENGTH('dbo.tbl_TempUser', 'fldDeputy') IS NULL
    ALTER TABLE [dbo].[tbl_TempUser] ADD [fldDeputy] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Token', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Token', 'fldUserId') IS NULL
    ALTER TABLE [dbo].[E_Token] ADD [fldUserId] INT           NULL;
GO

IF OBJECT_ID(N'dbo.E_Token', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Token', 'fldToken') IS NULL
    ALTER TABLE [dbo].[E_Token] ADD [fldToken] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Token', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Token', 'fldDateTime') IS NULL
    ALTER TABLE [dbo].[E_Token] ADD [fldDateTime] DATETIME      NULL;
GO

IF OBJECT_ID(N'dbo.E_Token', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Token', 'fldIp') IS NULL
    ALTER TABLE [dbo].[E_Token] ADD [fldIp] NVARCHAR(50)  NULL;
GO

IF OBJECT_ID(N'dbo.E_Border', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Border', 'fldName') IS NULL
    ALTER TABLE [dbo].[E_Border] ADD [fldName] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_AUH', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_AUH', 'fldCountry') IS NULL
    ALTER TABLE [dbo].[E_AUH] ADD [fldCountry] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_AUH', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_AUH', 'fldFirstMounth') IS NULL
    ALTER TABLE [dbo].[E_AUH] ADD [fldFirstMounth] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_AUH', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_AUH', 'fldKat') IS NULL
    ALTER TABLE [dbo].[E_AUH] ADD [fldKat] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_AUH', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_AUH', 'fldDayStart') IS NULL
    ALTER TABLE [dbo].[E_AUH] ADD [fldDayStart] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_AUH', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_AUH', 'fldDayKat') IS NULL
    ALTER TABLE [dbo].[E_AUH] ADD [fldDayKat] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_AUH', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_AUH', 'fldToM') IS NULL
    ALTER TABLE [dbo].[E_AUH] ADD [fldToM] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_UVR', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_UVR', 'fldCountry') IS NULL
    ALTER TABLE [dbo].[E_UVR] ADD [fldCountry] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_UVR', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_UVR', 'fldCalculateType') IS NULL
    ALTER TABLE [dbo].[E_UVR] ADD [fldCalculateType] INT           NULL;
GO

IF OBJECT_ID(N'dbo.E_UVR', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_UVR', 'fldPassportType') IS NULL
    ALTER TABLE [dbo].[E_UVR] ADD [fldPassportType] INT           NULL;
GO

IF OBJECT_ID(N'dbo.E_UVR', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_UVR', 'fldVisaStatus') IS NULL
    ALTER TABLE [dbo].[E_UVR] ADD [fldVisaStatus] INT           NULL;
GO

IF OBJECT_ID(N'dbo.E_UVR', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_UVR', 'fldDay') IS NULL
    ALTER TABLE [dbo].[E_UVR] ADD [fldDay] INT           NULL;
GO

IF OBJECT_ID(N'dbo.E_UVR', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_UVR', 'fldLong') IS NULL
    ALTER TABLE [dbo].[E_UVR] ADD [fldLong] INT           NULL;
GO

IF OBJECT_ID(N'dbo.E_UVR', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_UVR', 'fldOneTime') IS NULL
    ALTER TABLE [dbo].[E_UVR] ADD [fldOneTime] INT           NULL;
GO

IF OBJECT_ID(N'dbo.E_UVR', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_UVR', 'fldHB') IS NULL
    ALTER TABLE [dbo].[E_UVR] ADD [fldHB] TINYINT       NULL;
GO

IF OBJECT_ID(N'dbo.E_Exchange', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Exchange', 'fldEuro') IS NULL
    ALTER TABLE [dbo].[E_Exchange] ADD [fldEuro] NVARCHAR(50) NULL;
GO

IF OBJECT_ID(N'dbo.E_Exchange', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Exchange', 'fldDollar') IS NULL
    ALTER TABLE [dbo].[E_Exchange] ADD [fldDollar] NVARCHAR(50) NULL;
GO

IF OBJECT_ID(N'dbo.E_Exchange', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Exchange', 'fldPaund') IS NULL
    ALTER TABLE [dbo].[E_Exchange] ADD [fldPaund] NVARCHAR(50) NULL;
GO

IF OBJECT_ID(N'dbo.E_Defter', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Defter', 'fldPrice') IS NULL
    ALTER TABLE [dbo].[E_Defter] ADD [fldPrice] NVARCHAR(25) NULL;
GO

IF OBJECT_ID(N'dbo.E_Defter', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Defter', 'fldTypeofMoney') IS NULL
    ALTER TABLE [dbo].[E_Defter] ADD [fldTypeofMoney] NVARCHAR(50) NULL;
GO

IF OBJECT_ID(N'dbo.E_TGVH', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_TGVH', 'fldPrice') IS NULL
    ALTER TABLE [dbo].[E_TGVH] ADD [fldPrice] NVARCHAR(25) NULL;
GO

IF OBJECT_ID(N'dbo.E_TGVH', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_TGVH', 'fldTypeofMoney') IS NULL
    ALTER TABLE [dbo].[E_TGVH] ADD [fldTypeofMoney] NVARCHAR(25) NULL;
GO

IF OBJECT_ID(N'dbo.E_TGVH', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_TGVH', 'fldYear') IS NULL
    ALTER TABLE [dbo].[E_TGVH] ADD [fldYear] NVARCHAR(25) NULL;
GO

IF OBJECT_ID(N'dbo.E_TKOD', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_TKOD', 'fldCode') IS NULL
    ALTER TABLE [dbo].[E_TKOD] ADD [fldCode] NVARCHAR(50) NULL;
GO

IF OBJECT_ID(N'dbo.E_TKOD', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_TKOD', 'fldPTime') IS NULL
    ALTER TABLE [dbo].[E_TKOD] ADD [fldPTime] NVARCHAR(50) NULL;
GO

IF OBJECT_ID(N'dbo.E_TKOD', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_TKOD', 'fldStart') IS NULL
    ALTER TABLE [dbo].[E_TKOD] ADD [fldStart] INT          NULL;
GO

IF OBJECT_ID(N'dbo.E_TKOD', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_TKOD', 'fldFinish') IS NULL
    ALTER TABLE [dbo].[E_TKOD] ADD [fldFinish] INT          NULL;
GO

IF OBJECT_ID(N'dbo.E_TKOD', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_TKOD', 'fldIdariCode') IS NULL
    ALTER TABLE [dbo].[E_TKOD] ADD [fldIdariCode] NVARCHAR(50) NULL;
GO

IF OBJECT_ID(N'dbo.E_TKOD', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_TKOD', 'fldPaid') IS NULL
    ALTER TABLE [dbo].[E_TKOD] ADD [fldPaid] TINYINT      NULL;
GO

IF OBJECT_ID(N'dbo.E_Forms', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Forms', 'fldGB') IS NULL
    ALTER TABLE [dbo].[E_Forms] ADD [fldGB] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Forms', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Forms', 'fldDE') IS NULL
    ALTER TABLE [dbo].[E_Forms] ADD [fldDE] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Forms', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Forms', 'fldRU') IS NULL
    ALTER TABLE [dbo].[E_Forms] ADD [fldRU] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Forms', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Forms', 'fldIR') IS NULL
    ALTER TABLE [dbo].[E_Forms] ADD [fldIR] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Forms', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Forms', 'fldGBC') IS NULL
    ALTER TABLE [dbo].[E_Forms] ADD [fldGBC] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Forms', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Forms', 'fldDEC') IS NULL
    ALTER TABLE [dbo].[E_Forms] ADD [fldDEC] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Forms', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Forms', 'fldRUC') IS NULL
    ALTER TABLE [dbo].[E_Forms] ADD [fldRUC] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Forms', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Forms', 'fldIRC') IS NULL
    ALTER TABLE [dbo].[E_Forms] ADD [fldIRC] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Forms', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Forms', 'fldIRKC') IS NULL
    ALTER TABLE [dbo].[E_Forms] ADD [fldIRKC] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Forms', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Forms', 'fldIRK') IS NULL
    ALTER TABLE [dbo].[E_Forms] ADD [fldIRK] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Forms', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Forms', 'fldFransizca') IS NULL
    ALTER TABLE [dbo].[E_Forms] ADD [fldFransizca] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Forms', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Forms', 'fldFransizcaC') IS NULL
    ALTER TABLE [dbo].[E_Forms] ADD [fldFransizcaC] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_History', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_History', 'fldStart') IS NULL
    ALTER TABLE [dbo].[E_History] ADD [fldStart] DATETIME      NULL;
GO

IF OBJECT_ID(N'dbo.E_History', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_History', 'fldShouldExit') IS NULL
    ALTER TABLE [dbo].[E_History] ADD [fldShouldExit] DATETIME      NULL;
GO

IF OBJECT_ID(N'dbo.E_History', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_History', 'fldBirthDate') IS NULL
    ALTER TABLE [dbo].[E_History] ADD [fldBirthDate] DATETIME      NULL;
GO

IF OBJECT_ID(N'dbo.E_History', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_History', 'fldCountry') IS NULL
    ALTER TABLE [dbo].[E_History] ADD [fldCountry] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_History', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_History', 'fldPenalty') IS NULL
    ALTER TABLE [dbo].[E_History] ADD [fldPenalty] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_History', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_History', 'fldPMoney') IS NULL
    ALTER TABLE [dbo].[E_History] ADD [fldPMoney] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_History', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_History', 'fldUser') IS NULL
    ALTER TABLE [dbo].[E_History] ADD [fldUser] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_History', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_History', 'fldBorder') IS NULL
    ALTER TABLE [dbo].[E_History] ADD [fldBorder] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_History', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_History', 'fldDatetime') IS NULL
    ALTER TABLE [dbo].[E_History] ADD [fldDatetime] DATETIME      NULL;
GO

IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_IsK', 'fldDatetime') IS NULL
    ALTER TABLE [dbo].[E_IsK] ADD [fldDatetime] DATETIME      NULL;
GO

IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_IsK', 'fldName') IS NULL
    ALTER TABLE [dbo].[E_IsK] ADD [fldName] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_IsK', 'fldPassport') IS NULL
    ALTER TABLE [dbo].[E_IsK] ADD [fldPassport] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_IsK', 'fldIdn') IS NULL
    ALTER TABLE [dbo].[E_IsK] ADD [fldIdn] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_IsK', 'fldOrgin') IS NULL
    ALTER TABLE [dbo].[E_IsK] ADD [fldOrgin] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_IsK', 'fldBirthdate') IS NULL
    ALTER TABLE [dbo].[E_IsK] ADD [fldBirthdate] DATE          NULL;
GO

IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_IsK', 'fldForm') IS NULL
    ALTER TABLE [dbo].[E_IsK] ADD [fldForm] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_IsK', 'fldPassControl') IS NULL
    ALTER TABLE [dbo].[E_IsK] ADD [fldPassControl] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_IsK', 'fldApproval') IS NULL
    ALTER TABLE [dbo].[E_IsK] ADD [fldApproval] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_IsK', 'fldBorder') IS NULL
    ALTER TABLE [dbo].[E_IsK] ADD [fldBorder] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_IsK', 'fldVisa') IS NULL
    ALTER TABLE [dbo].[E_IsK] ADD [fldVisa] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_IsK', 'fldPMoney') IS NULL
    ALTER TABLE [dbo].[E_IsK] ADD [fldPMoney] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_IsK', 'fldPicture') IS NULL
    ALTER TABLE [dbo].[E_IsK] ADD [fldPicture] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Sartli', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Sartli', 'fldBy') IS NULL
    ALTER TABLE [dbo].[E_Sartli] ADD [fldBy] VARCHAR(150)  NULL;
GO

IF OBJECT_ID(N'dbo.E_Sartli', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Sartli', 'fldOrgin') IS NULL
    ALTER TABLE [dbo].[E_Sartli] ADD [fldOrgin] NVARCHAR(50)  NULL;
GO

IF OBJECT_ID(N'dbo.E_Sartli', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Sartli', 'fldBdate') IS NULL
    ALTER TABLE [dbo].[E_Sartli] ADD [fldBdate] DATE          NULL;
GO

IF OBJECT_ID(N'dbo.E_Sartli', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Sartli', 'fldDate') IS NULL
    ALTER TABLE [dbo].[E_Sartli] ADD [fldDate] DATETIME      NULL;
GO

IF OBJECT_ID(N'dbo.E_Sartli', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Sartli', 'fldName') IS NULL
    ALTER TABLE [dbo].[E_Sartli] ADD [fldName] NVARCHAR(250) NULL;
GO

IF OBJECT_ID(N'dbo.E_Sartli', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Sartli', 'fldBorder') IS NULL
    ALTER TABLE [dbo].[E_Sartli] ADD [fldBorder] NVARCHAR(500) NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'TarihSaat') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [TarihSaat] DATE          NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'AdSoyad') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [AdSoyad] NCHAR(50)     NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'DogumT') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [DogumT] DATE          NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'DogumY') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [DogumY] NVARCHAR(50)  NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'Cinsiyet') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [Cinsiyet] NVARCHAR(10)  NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'Uyruk') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [Uyruk] NCHAR(250)    NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'PasaportNo') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [PasaportNo] NCHAR(20)     NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'BelgeNo') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [BelgeNo] NVARCHAR(20)  NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'PasaportTuru') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [PasaportTuru] NCHAR(50)     NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'Beyan') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [Beyan] NVARCHAR(100) NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'GelenUcusNo') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [GelenUcusNo] NVARCHAR(10)  NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'GelenHavayolu') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [GelenHavayolu] NVARCHAR(150) NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'GeldigiYer') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [GeldigiYer] NCHAR(250)    NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'GeldigiTarihSaat') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [GeldigiTarihSaat] DATETIME      NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'InadSebepAciklama') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [InadSebepAciklama] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'InadSebep') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [InadSebep] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'GidenHavayolu') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [GidenHavayolu] NVARCHAR(150) NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'GidisUcusNo') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [GidisUcusNo] NVARCHAR(10)  NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'GidisYer') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [GidisYer] NCHAR(250)    NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'GidisTarihSaat') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [GidisTarihSaat] DATETIME      NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'Personel') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [Personel] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'UstAramaEsya') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [UstAramaEsya] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'UcagaNakil') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [UcagaNakil] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'OzelGuvenlik') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [OzelGuvenlik] NVARCHAR(50)  NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'YerHizmetleriPersonel') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [YerHizmetleriPersonel] NVARCHAR(50)  NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'YerHizmetleri') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [YerHizmetleri] NCHAR(250)    NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'Refakat') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [Refakat] NVARCHAR(250) NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'Kapi') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [Kapi] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'Valilik') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [Valilik] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'Durum') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [Durum] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Inad', 'Sicil') IS NULL
    ALTER TABLE [dbo].[E_Inad] ADD [Sicil] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Messages', 'fldSendByName') IS NULL
    ALTER TABLE [dbo].[E_Messages] ADD [fldSendByName] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Messages', 'fldSendBySicil') IS NULL
    ALTER TABLE [dbo].[E_Messages] ADD [fldSendBySicil] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Messages', 'fldSendByPhone') IS NULL
    ALTER TABLE [dbo].[E_Messages] ADD [fldSendByPhone] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Messages', 'fldSendByMail') IS NULL
    ALTER TABLE [dbo].[E_Messages] ADD [fldSendByMail] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Messages', 'fldDateTime') IS NULL
    ALTER TABLE [dbo].[E_Messages] ADD [fldDateTime] DATETIME      NULL;
GO

IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Messages', 'fldMessage') IS NULL
    ALTER TABLE [dbo].[E_Messages] ADD [fldMessage] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Messages', 'fldSenderId') IS NULL
    ALTER TABLE [dbo].[E_Messages] ADD [fldSenderId] INT           NULL;
GO

IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Messages', 'fldSenderRole') IS NULL
    ALTER TABLE [dbo].[E_Messages] ADD [fldSenderRole] NVARCHAR(20)  NULL;
GO

IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Messages', 'fldRecipientId') IS NULL
    ALTER TABLE [dbo].[E_Messages] ADD [fldRecipientId] INT           NULL;
GO

IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Messages', 'fldRecipientRole') IS NULL
    ALTER TABLE [dbo].[E_Messages] ADD [fldRecipientRole] NVARCHAR(20)  NULL;
GO

IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Messages', 'fldSubject') IS NULL
    ALTER TABLE [dbo].[E_Messages] ADD [fldSubject] NVARCHAR(200) NULL;
GO

IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Messages', 'fldIsRead') IS NULL
    ALTER TABLE [dbo].[E_Messages] ADD [fldIsRead] BIT NULL;
GO

IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Messages', 'fldReadDateTime') IS NULL
    ALTER TABLE [dbo].[E_Messages] ADD [fldReadDateTime] DATETIME      NULL;
GO

IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Messages', 'fldIsDeletedBySender') IS NULL
    ALTER TABLE [dbo].[E_Messages] ADD [fldIsDeletedBySender] BIT NULL;
GO

IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Messages', 'fldIsDeletedByRecipient') IS NULL
    ALTER TABLE [dbo].[E_Messages] ADD [fldIsDeletedByRecipient] BIT NULL;
GO

IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Messages', 'fldParentMessageId') IS NULL
    ALTER TABLE [dbo].[E_Messages] ADD [fldParentMessageId] INT           NULL;
GO

IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH('dbo.E_Messages', 'fldIsReply') IS NULL
    ALTER TABLE [dbo].[E_Messages] ADD [fldIsReply] BIT NULL;
GO

IF OBJECT_ID(N'dbo.Airline', N'U') IS NOT NULL AND COL_LENGTH('dbo.Airline', 'IATACode') IS NULL
    ALTER TABLE [dbo].[Airline] ADD [IATACode] NVARCHAR(7) NULL;
GO

IF OBJECT_ID(N'dbo.Airline', N'U') IS NOT NULL AND COL_LENGTH('dbo.Airline', 'Name') IS NULL
    ALTER TABLE [dbo].[Airline] ADD [Name] NVARCHAR(150) NULL;
GO

IF OBJECT_ID(N'dbo.Airline', N'U') IS NOT NULL AND COL_LENGTH('dbo.Airline', 'Country') IS NULL
    ALTER TABLE [dbo].[Airline] ADD [Country] NVARCHAR(100) NULL;
GO

IF OBJECT_ID(N'dbo.Airline', N'U') IS NOT NULL AND COL_LENGTH('dbo.Airline', 'IsActive') IS NULL
    ALTER TABLE [dbo].[Airline] ADD [IsActive] BIT NULL;
GO

IF OBJECT_ID(N'dbo.Airline', N'U') IS NOT NULL AND COL_LENGTH('dbo.Airline', 'IsUserDefined') IS NULL
    ALTER TABLE [dbo].[Airline] ADD [IsUserDefined] BIT           NULL;
GO

IF OBJECT_ID(N'dbo.Airline', N'U') IS NOT NULL AND COL_LENGTH('dbo.Airline', 'CreatedDate') IS NULL
    ALTER TABLE [dbo].[Airline] ADD [CreatedDate] DATETIME      NULL;
GO

IF OBJECT_ID(N'dbo.Categories', N'U') IS NOT NULL AND COL_LENGTH('dbo.Categories', 'CategoryName') IS NULL
    ALTER TABLE [dbo].[Categories] ADD [CategoryName] NVARCHAR(200) NULL;
GO

IF OBJECT_ID(N'dbo.Categories', N'U') IS NOT NULL AND COL_LENGTH('dbo.Categories', 'Description') IS NULL
    ALTER TABLE [dbo].[Categories] ADD [Description] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.Categories', N'U') IS NOT NULL AND COL_LENGTH('dbo.Categories', 'IsActive') IS NULL
    ALTER TABLE [dbo].[Categories] ADD [IsActive] BIT NULL;
GO

IF OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL AND COL_LENGTH('dbo.Courses', 'CourseTitle') IS NULL
    ALTER TABLE [dbo].[Courses] ADD [CourseTitle] NVARCHAR(200) NULL;
GO

IF OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL AND COL_LENGTH('dbo.Courses', 'CourseDescription') IS NULL
    ALTER TABLE [dbo].[Courses] ADD [CourseDescription] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL AND COL_LENGTH('dbo.Courses', 'CoverImage') IS NULL
    ALTER TABLE [dbo].[Courses] ADD [CoverImage] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL AND COL_LENGTH('dbo.Courses', 'CreatedBy') IS NULL
    ALTER TABLE [dbo].[Courses] ADD [CreatedBy] INT NULL;
GO

IF OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL AND COL_LENGTH('dbo.Courses', 'CreatedDate') IS NULL
    ALTER TABLE [dbo].[Courses] ADD [CreatedDate] DATETIME      NULL;
GO

IF OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL AND COL_LENGTH('dbo.Courses', 'CategoryId') IS NULL
    ALTER TABLE [dbo].[Courses] ADD [CategoryId] INT NULL;
GO

IF OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL AND COL_LENGTH('dbo.Courses', 'ResourceFile') IS NULL
    ALTER TABLE [dbo].[Courses] ADD [ResourceFile] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL AND COL_LENGTH('dbo.Courses', 'IsActive') IS NULL
    ALTER TABLE [dbo].[Courses] ADD [IsActive] BIT NULL;
GO

IF OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL AND COL_LENGTH('dbo.Courses', 'IsDeleted') IS NULL
    ALTER TABLE [dbo].[Courses] ADD [IsDeleted] BIT           NULL;
GO

IF OBJECT_ID(N'dbo.CourseContents', N'U') IS NOT NULL AND COL_LENGTH('dbo.CourseContents', 'CourseId') IS NULL
    ALTER TABLE [dbo].[CourseContents] ADD [CourseId] INT NULL;
GO

IF OBJECT_ID(N'dbo.CourseContents', N'U') IS NOT NULL AND COL_LENGTH('dbo.CourseContents', 'ContentType') IS NULL
    ALTER TABLE [dbo].[CourseContents] ADD [ContentType] NVARCHAR(20) NULL;
GO

IF OBJECT_ID(N'dbo.CourseContents', N'U') IS NOT NULL AND COL_LENGTH('dbo.CourseContents', 'ContentTitle') IS NULL
    ALTER TABLE [dbo].[CourseContents] ADD [ContentTitle] NVARCHAR(200) NULL;
GO

IF OBJECT_ID(N'dbo.CourseContents', N'U') IS NOT NULL AND COL_LENGTH('dbo.CourseContents', 'FilePath') IS NULL
    ALTER TABLE [dbo].[CourseContents] ADD [FilePath] NVARCHAR(500) NULL;
GO

IF OBJECT_ID(N'dbo.CourseContents', N'U') IS NOT NULL AND COL_LENGTH('dbo.CourseContents', 'CreatedDate') IS NULL
    ALTER TABLE [dbo].[CourseContents] ADD [CreatedDate] DATETIME      NULL;
GO

IF OBJECT_ID(N'dbo.CourseContents', N'U') IS NOT NULL AND COL_LENGTH('dbo.CourseContents', 'ContentDescription') IS NULL
    ALTER TABLE [dbo].[CourseContents] ADD [ContentDescription] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.CourseEnrollments', N'U') IS NOT NULL AND COL_LENGTH('dbo.CourseEnrollments', 'CourseId') IS NULL
    ALTER TABLE [dbo].[CourseEnrollments] ADD [CourseId] INT NULL;
GO

IF OBJECT_ID(N'dbo.CourseEnrollments', N'U') IS NOT NULL AND COL_LENGTH('dbo.CourseEnrollments', 'UserId') IS NULL
    ALTER TABLE [dbo].[CourseEnrollments] ADD [UserId] INT NULL;
GO

IF OBJECT_ID(N'dbo.CourseEnrollments', N'U') IS NOT NULL AND COL_LENGTH('dbo.CourseEnrollments', 'EnrollmentDate') IS NULL
    ALTER TABLE [dbo].[CourseEnrollments] ADD [EnrollmentDate] DATETIME NULL;
GO

IF OBJECT_ID(N'dbo.CourseEnrollments', N'U') IS NOT NULL AND COL_LENGTH('dbo.CourseEnrollments', 'IsDrawEntry') IS NULL
    ALTER TABLE [dbo].[CourseEnrollments] ADD [IsDrawEntry] BIT NULL;
GO

IF OBJECT_ID(N'dbo.CourseEnrollments', N'U') IS NOT NULL AND COL_LENGTH('dbo.CourseEnrollments', 'DrawEntryDate') IS NULL
    ALTER TABLE [dbo].[CourseEnrollments] ADD [DrawEntryDate] DATETIME NULL;
GO

IF OBJECT_ID(N'dbo.CourseReviews', N'U') IS NOT NULL AND COL_LENGTH('dbo.CourseReviews', 'CourseId') IS NULL
    ALTER TABLE [dbo].[CourseReviews] ADD [CourseId] INT NULL;
GO

IF OBJECT_ID(N'dbo.CourseReviews', N'U') IS NOT NULL AND COL_LENGTH('dbo.CourseReviews', 'UserId') IS NULL
    ALTER TABLE [dbo].[CourseReviews] ADD [UserId] INT NULL;
GO

IF OBJECT_ID(N'dbo.CourseReviews', N'U') IS NOT NULL AND COL_LENGTH('dbo.CourseReviews', 'Rating') IS NULL
    ALTER TABLE [dbo].[CourseReviews] ADD [Rating] TINYINT NULL;
GO

IF OBJECT_ID(N'dbo.CourseReviews', N'U') IS NOT NULL AND COL_LENGTH('dbo.CourseReviews', 'Comment') IS NULL
    ALTER TABLE [dbo].[CourseReviews] ADD [Comment] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.CourseReviews', N'U') IS NOT NULL AND COL_LENGTH('dbo.CourseReviews', 'CreatedDate') IS NULL
    ALTER TABLE [dbo].[CourseReviews] ADD [CreatedDate] DATETIME NULL;
GO

IF OBJECT_ID(N'dbo.CourseReviews', N'U') IS NOT NULL AND COL_LENGTH('dbo.CourseReviews', 'IsApproved') IS NULL
    ALTER TABLE [dbo].[CourseReviews] ADD [IsApproved] BIT NULL;
GO

IF OBJECT_ID(N'dbo.CourseReviews', N'U') IS NOT NULL AND COL_LENGTH('dbo.CourseReviews', 'ApprovedBy') IS NULL
    ALTER TABLE [dbo].[CourseReviews] ADD [ApprovedBy] INT           NULL;
GO

IF OBJECT_ID(N'dbo.CourseReviews', N'U') IS NOT NULL AND COL_LENGTH('dbo.CourseReviews', 'ApprovedDate') IS NULL
    ALTER TABLE [dbo].[CourseReviews] ADD [ApprovedDate] DATETIME      NULL;
GO

IF OBJECT_ID(N'dbo.Exam', N'U') IS NOT NULL AND COL_LENGTH('dbo.Exam', 'CourseId') IS NULL
    ALTER TABLE [dbo].[Exam] ADD [CourseId] INT NULL;
GO

IF OBJECT_ID(N'dbo.Exam', N'U') IS NOT NULL AND COL_LENGTH('dbo.Exam', 'Title') IS NULL
    ALTER TABLE [dbo].[Exam] ADD [Title] NVARCHAR(200) NULL;
GO

IF OBJECT_ID(N'dbo.Exam', N'U') IS NOT NULL AND COL_LENGTH('dbo.Exam', 'Description') IS NULL
    ALTER TABLE [dbo].[Exam] ADD [Description] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.Exam', N'U') IS NOT NULL AND COL_LENGTH('dbo.Exam', 'DurationMinutes') IS NULL
    ALTER TABLE [dbo].[Exam] ADD [DurationMinutes] INT           NULL;
GO

IF OBJECT_ID(N'dbo.Exam', N'U') IS NOT NULL AND COL_LENGTH('dbo.Exam', 'PassingScore') IS NULL
    ALTER TABLE [dbo].[Exam] ADD [PassingScore] INT           NULL;
GO

IF OBJECT_ID(N'dbo.Exam', N'U') IS NOT NULL AND COL_LENGTH('dbo.Exam', 'IsActive') IS NULL
    ALTER TABLE [dbo].[Exam] ADD [IsActive] BIT NULL;
GO

IF OBJECT_ID(N'dbo.Exam', N'U') IS NOT NULL AND COL_LENGTH('dbo.Exam', 'CreatedAt') IS NULL
    ALTER TABLE [dbo].[Exam] ADD [CreatedAt] DATETIME NULL;
GO

IF OBJECT_ID(N'dbo.Exam', N'U') IS NOT NULL AND COL_LENGTH('dbo.Exam', 'IsArchived') IS NULL
    ALTER TABLE [dbo].[Exam] ADD [IsArchived] BIT           NULL;
GO

IF OBJECT_ID(N'dbo.ExamResult', N'U') IS NOT NULL AND COL_LENGTH('dbo.ExamResult', 'ExamId') IS NULL
    ALTER TABLE [dbo].[ExamResult] ADD [ExamId] INT NULL;
GO

IF OBJECT_ID(N'dbo.ExamResult', N'U') IS NOT NULL AND COL_LENGTH('dbo.ExamResult', 'UserId') IS NULL
    ALTER TABLE [dbo].[ExamResult] ADD [UserId] INT          NULL;
GO

IF OBJECT_ID(N'dbo.ExamResult', N'U') IS NOT NULL AND COL_LENGTH('dbo.ExamResult', 'Score') IS NULL
    ALTER TABLE [dbo].[ExamResult] ADD [Score] DECIMAL(5, 2) NULL;
GO

IF OBJECT_ID(N'dbo.ExamResult', N'U') IS NOT NULL AND COL_LENGTH('dbo.ExamResult', 'StartedAt') IS NULL
    ALTER TABLE [dbo].[ExamResult] ADD [StartedAt] DATETIME     NULL;
GO

IF OBJECT_ID(N'dbo.ExamResult', N'U') IS NOT NULL AND COL_LENGTH('dbo.ExamResult', 'FinishedAt') IS NULL
    ALTER TABLE [dbo].[ExamResult] ADD [FinishedAt] DATETIME     NULL;
GO

IF OBJECT_ID(N'dbo.ExamResult', N'U') IS NOT NULL AND COL_LENGTH('dbo.ExamResult', 'Status') IS NULL
    ALTER TABLE [dbo].[ExamResult] ADD [Status] TINYINT NULL;
GO

IF OBJECT_ID(N'dbo.Question', N'U') IS NOT NULL AND COL_LENGTH('dbo.Question', 'ExamId') IS NULL
    ALTER TABLE [dbo].[Question] ADD [ExamId] INT NULL;
GO

IF OBJECT_ID(N'dbo.Question', N'U') IS NOT NULL AND COL_LENGTH('dbo.Question', 'Text') IS NULL
    ALTER TABLE [dbo].[Question] ADD [Text] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.Question', N'U') IS NOT NULL AND COL_LENGTH('dbo.Question', 'QuestionType') IS NULL
    ALTER TABLE [dbo].[Question] ADD [QuestionType] TINYINT NULL;
GO

IF OBJECT_ID(N'dbo.Question', N'U') IS NOT NULL AND COL_LENGTH('dbo.Question', 'Points') IS NULL
    ALTER TABLE [dbo].[Question] ADD [Points] INT NULL;
GO

IF OBJECT_ID(N'dbo.Question', N'U') IS NOT NULL AND COL_LENGTH('dbo.Question', 'SortOrder') IS NULL
    ALTER TABLE [dbo].[Question] ADD [SortOrder] INT NULL;
GO

IF OBJECT_ID(N'dbo.Question', N'U') IS NOT NULL AND COL_LENGTH('dbo.Question', 'IsActive') IS NULL
    ALTER TABLE [dbo].[Question] ADD [IsActive] BIT           NULL;
GO

IF OBJECT_ID(N'dbo.QuestionOption', N'U') IS NOT NULL AND COL_LENGTH('dbo.QuestionOption', 'QuestionId') IS NULL
    ALTER TABLE [dbo].[QuestionOption] ADD [QuestionId] INT NULL;
GO

IF OBJECT_ID(N'dbo.QuestionOption', N'U') IS NOT NULL AND COL_LENGTH('dbo.QuestionOption', 'Text') IS NULL
    ALTER TABLE [dbo].[QuestionOption] ADD [Text] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.QuestionOption', N'U') IS NOT NULL AND COL_LENGTH('dbo.QuestionOption', 'IsCorrect') IS NULL
    ALTER TABLE [dbo].[QuestionOption] ADD [IsCorrect] BIT NULL;
GO

IF OBJECT_ID(N'dbo.QuestionOption', N'U') IS NOT NULL AND COL_LENGTH('dbo.QuestionOption', 'SortOrder') IS NULL
    ALTER TABLE [dbo].[QuestionOption] ADD [SortOrder] INT NULL;
GO

IF OBJECT_ID(N'dbo.QuestionMedia', N'U') IS NOT NULL AND COL_LENGTH('dbo.QuestionMedia', 'QuestionId') IS NULL
    ALTER TABLE [dbo].[QuestionMedia] ADD [QuestionId] INT NULL;
GO

IF OBJECT_ID(N'dbo.QuestionMedia', N'U') IS NOT NULL AND COL_LENGTH('dbo.QuestionMedia', 'MediaType') IS NULL
    ALTER TABLE [dbo].[QuestionMedia] ADD [MediaType] TINYINT NULL;
GO

IF OBJECT_ID(N'dbo.QuestionMedia', N'U') IS NOT NULL AND COL_LENGTH('dbo.QuestionMedia', 'MediaPath') IS NULL
    ALTER TABLE [dbo].[QuestionMedia] ADD [MediaPath] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.QuestionMedia', N'U') IS NOT NULL AND COL_LENGTH('dbo.QuestionMedia', 'SortOrder') IS NULL
    ALTER TABLE [dbo].[QuestionMedia] ADD [SortOrder] INT NULL;
GO

IF OBJECT_ID(N'dbo.QuestionMedia', N'U') IS NOT NULL AND COL_LENGTH('dbo.QuestionMedia', 'CreatedAt') IS NULL
    ALTER TABLE [dbo].[QuestionMedia] ADD [CreatedAt] DATETIME NULL;
GO

IF OBJECT_ID(N'dbo.Answer', N'U') IS NOT NULL AND COL_LENGTH('dbo.Answer', 'ExamResultId') IS NULL
    ALTER TABLE [dbo].[Answer] ADD [ExamResultId] INT NULL;
GO

IF OBJECT_ID(N'dbo.Answer', N'U') IS NOT NULL AND COL_LENGTH('dbo.Answer', 'QuestionId') IS NULL
    ALTER TABLE [dbo].[Answer] ADD [QuestionId] INT NULL;
GO

IF OBJECT_ID(N'dbo.Answer', N'U') IS NOT NULL AND COL_LENGTH('dbo.Answer', 'OptionId') IS NULL
    ALTER TABLE [dbo].[Answer] ADD [OptionId] INT           NULL;
GO

IF OBJECT_ID(N'dbo.Answer', N'U') IS NOT NULL AND COL_LENGTH('dbo.Answer', 'TextAnswer') IS NULL
    ALTER TABLE [dbo].[Answer] ADD [TextAnswer] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.Certificate', N'U') IS NOT NULL AND COL_LENGTH('dbo.Certificate', 'UserId') IS NULL
    ALTER TABLE [dbo].[Certificate] ADD [UserId] INT NULL;
GO

IF OBJECT_ID(N'dbo.Certificate', N'U') IS NOT NULL AND COL_LENGTH('dbo.Certificate', 'CourseId') IS NULL
    ALTER TABLE [dbo].[Certificate] ADD [CourseId] INT NULL;
GO

IF OBJECT_ID(N'dbo.Certificate', N'U') IS NOT NULL AND COL_LENGTH('dbo.Certificate', 'ExamResultId') IS NULL
    ALTER TABLE [dbo].[Certificate] ADD [ExamResultId] INT           NULL;
GO

IF OBJECT_ID(N'dbo.Certificate', N'U') IS NOT NULL AND COL_LENGTH('dbo.Certificate', 'CertificateNumber') IS NULL
    ALTER TABLE [dbo].[Certificate] ADD [CertificateNumber] NVARCHAR(50) NULL;
GO

IF OBJECT_ID(N'dbo.Certificate', N'U') IS NOT NULL AND COL_LENGTH('dbo.Certificate', 'FilePath') IS NULL
    ALTER TABLE [dbo].[Certificate] ADD [FilePath] NVARCHAR(500) NULL;
GO

IF OBJECT_ID(N'dbo.Certificate', N'U') IS NOT NULL AND COL_LENGTH('dbo.Certificate', 'IssuedDate') IS NULL
    ALTER TABLE [dbo].[Certificate] ADD [IssuedDate] DATETIME NULL;
GO

IF OBJECT_ID(N'dbo.Certificate', N'U') IS NOT NULL AND COL_LENGTH('dbo.Certificate', 'Score') IS NULL
    ALTER TABLE [dbo].[Certificate] ADD [Score] INT NULL;
GO

IF OBJECT_ID(N'dbo.Certificate', N'U') IS NOT NULL AND COL_LENGTH('dbo.Certificate', 'IsActive') IS NULL
    ALTER TABLE [dbo].[Certificate] ADD [IsActive] BIT NULL;
GO

IF OBJECT_ID(N'dbo.Certificate', N'U') IS NOT NULL AND COL_LENGTH('dbo.Certificate', 'CreatedAt') IS NULL
    ALTER TABLE [dbo].[Certificate] ADD [CreatedAt] DATETIME NULL;
GO

IF OBJECT_ID(N'dbo.CertificateRequest', N'U') IS NOT NULL AND COL_LENGTH('dbo.CertificateRequest', 'UserId') IS NULL
    ALTER TABLE [dbo].[CertificateRequest] ADD [UserId] INT NULL;
GO

IF OBJECT_ID(N'dbo.CertificateRequest', N'U') IS NOT NULL AND COL_LENGTH('dbo.CertificateRequest', 'CourseId') IS NULL
    ALTER TABLE [dbo].[CertificateRequest] ADD [CourseId] INT NULL;
GO

IF OBJECT_ID(N'dbo.CertificateRequest', N'U') IS NOT NULL AND COL_LENGTH('dbo.CertificateRequest', 'RequestDate') IS NULL
    ALTER TABLE [dbo].[CertificateRequest] ADD [RequestDate] DATETIME NULL;
GO

IF OBJECT_ID(N'dbo.CertificateRequest', N'U') IS NOT NULL AND COL_LENGTH('dbo.CertificateRequest', 'Status') IS NULL
    ALTER TABLE [dbo].[CertificateRequest] ADD [Status] TINYINT NULL;
GO

IF OBJECT_ID(N'dbo.CertificateRequest', N'U') IS NOT NULL AND COL_LENGTH('dbo.CertificateRequest', 'AdminNote') IS NULL
    ALTER TABLE [dbo].[CertificateRequest] ADD [AdminNote] NVARCHAR(500) NULL;
GO

IF OBJECT_ID(N'dbo.CertificateRequest', N'U') IS NOT NULL AND COL_LENGTH('dbo.CertificateRequest', 'ProcessedDate') IS NULL
    ALTER TABLE [dbo].[CertificateRequest] ADD [ProcessedDate] DATETIME      NULL;
GO

IF OBJECT_ID(N'dbo.CertificateRequest', N'U') IS NOT NULL AND COL_LENGTH('dbo.CertificateRequest', 'ProcessedBy') IS NULL
    ALTER TABLE [dbo].[CertificateRequest] ADD [ProcessedBy] INT           NULL;
GO

IF OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NOT NULL AND COL_LENGTH('dbo.DocumentTerms', 'Term') IS NULL
    ALTER TABLE [dbo].[DocumentTerms] ADD [Term] NVARCHAR(200) NULL;
GO

IF OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NOT NULL AND COL_LENGTH('dbo.DocumentTerms', 'Slug') IS NULL
    ALTER TABLE [dbo].[DocumentTerms] ADD [Slug] NVARCHAR(250) NULL;
GO

IF OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NOT NULL AND COL_LENGTH('dbo.DocumentTerms', 'Category') IS NULL
    ALTER TABLE [dbo].[DocumentTerms] ADD [Category] NVARCHAR(100) NULL;
GO

IF OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NOT NULL AND COL_LENGTH('dbo.DocumentTerms', 'Definition') IS NULL
    ALTER TABLE [dbo].[DocumentTerms] ADD [Definition] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NOT NULL AND COL_LENGTH('dbo.DocumentTerms', 'DetailedDescription') IS NULL
    ALTER TABLE [dbo].[DocumentTerms] ADD [DetailedDescription] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NOT NULL AND COL_LENGTH('dbo.DocumentTerms', 'ImageUrl') IS NULL
    ALTER TABLE [dbo].[DocumentTerms] ADD [ImageUrl] NVARCHAR(500) NULL;
GO

IF OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NOT NULL AND COL_LENGTH('dbo.DocumentTerms', 'RelatedTerms') IS NULL
    ALTER TABLE [dbo].[DocumentTerms] ADD [RelatedTerms] NVARCHAR(500) NULL;
GO

IF OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NOT NULL AND COL_LENGTH('dbo.DocumentTerms', 'IsActive') IS NULL
    ALTER TABLE [dbo].[DocumentTerms] ADD [IsActive] BIT NULL;
GO

IF OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NOT NULL AND COL_LENGTH('dbo.DocumentTerms', 'CreatedAt') IS NULL
    ALTER TABLE [dbo].[DocumentTerms] ADD [CreatedAt] DATETIME      NULL;
GO

IF OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NOT NULL AND COL_LENGTH('dbo.DocumentTerms', 'UpdatedAt') IS NULL
    ALTER TABLE [dbo].[DocumentTerms] ADD [UpdatedAt] DATETIME      NULL;
GO

IF OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NOT NULL AND COL_LENGTH('dbo.DocumentTerms', 'Sicil') IS NULL
    ALTER TABLE [dbo].[DocumentTerms] ADD [Sicil] NVARCHAR(50)  NULL;
GO

IF OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NOT NULL AND COL_LENGTH('dbo.DocumentTerms', 'AdSoyad') IS NULL
    ALTER TABLE [dbo].[DocumentTerms] ADD [AdSoyad] NVARCHAR(200) NULL;
GO

IF OBJECT_ID(N'dbo.TahditKod', N'U') IS NOT NULL AND COL_LENGTH('dbo.TahditKod', 'Kod') IS NULL
    ALTER TABLE [dbo].[TahditKod] ADD [Kod] NVARCHAR(20) NULL;
GO

IF OBJECT_ID(N'dbo.TahditKod', N'U') IS NOT NULL AND COL_LENGTH('dbo.TahditKod', 'Aciklama') IS NULL
    ALTER TABLE [dbo].[TahditKod] ADD [Aciklama] NVARCHAR(500) NULL;
GO

IF OBJECT_ID(N'dbo.TahditKod', N'U') IS NOT NULL AND COL_LENGTH('dbo.TahditKod', 'SureAy') IS NULL
    ALTER TABLE [dbo].[TahditKod] ADD [SureAy] INT           NULL;
GO

IF OBJECT_ID(N'dbo.TahditKod', N'U') IS NOT NULL AND COL_LENGTH('dbo.TahditKod', 'Aktif') IS NULL
    ALTER TABLE [dbo].[TahditKod] ADD [Aktif] BIT NULL;
GO

IF OBJECT_ID(N'dbo.TahditKod', N'U') IS NOT NULL AND COL_LENGTH('dbo.TahditKod', 'GirisGelirse') IS NULL
    ALTER TABLE [dbo].[TahditKod] ADD [GirisGelirse] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.TahditKod', N'U') IS NOT NULL AND COL_LENGTH('dbo.TahditKod', 'CikisGelirse') IS NULL
    ALTER TABLE [dbo].[TahditKod] ADD [CikisGelirse] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.TahditKod', N'U') IS NOT NULL AND COL_LENGTH('dbo.TahditKod', 'TahditMedia') IS NULL
    ALTER TABLE [dbo].[TahditKod] ADD [TahditMedia] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.SorguCevaplari', N'U') IS NOT NULL AND COL_LENGTH('dbo.SorguCevaplari', 'AnahtarKelimeler') IS NULL
    ALTER TABLE [dbo].[SorguCevaplari] ADD [AnahtarKelimeler] NVARCHAR(200) NULL;
GO

IF OBJECT_ID(N'dbo.SorguCevaplari', N'U') IS NOT NULL AND COL_LENGTH('dbo.SorguCevaplari', 'Cevap') IS NULL
    ALTER TABLE [dbo].[SorguCevaplari] ADD [Cevap] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.SorguCevaplari', N'U') IS NOT NULL AND COL_LENGTH('dbo.SorguCevaplari', 'Kategori') IS NULL
    ALTER TABLE [dbo].[SorguCevaplari] ADD [Kategori] NVARCHAR(100) NULL;
GO

IF OBJECT_ID(N'dbo.SorguCevaplari', N'U') IS NOT NULL AND COL_LENGTH('dbo.SorguCevaplari', 'Aktif') IS NULL
    ALTER TABLE [dbo].[SorguCevaplari] ADD [Aktif] BIT           NULL;
GO

IF OBJECT_ID(N'dbo.SorguCevaplari', N'U') IS NOT NULL AND COL_LENGTH('dbo.SorguCevaplari', 'OlusturmaTarihi') IS NULL
    ALTER TABLE [dbo].[SorguCevaplari] ADD [OlusturmaTarihi] DATETIME      NULL;
GO

IF OBJECT_ID(N'dbo.SorguCevaplari', N'U') IS NOT NULL AND COL_LENGTH('dbo.SorguCevaplari', 'ResimUrl') IS NULL
    ALTER TABLE [dbo].[SorguCevaplari] ADD [ResimUrl] NVARCHAR(MAX) NULL;
GO

IF OBJECT_ID(N'dbo.SorguLoglari', N'U') IS NOT NULL AND COL_LENGTH('dbo.SorguLoglari', 'Soru') IS NULL
    ALTER TABLE [dbo].[SorguLoglari] ADD [Soru] NVARCHAR(500) NULL;
GO

IF OBJECT_ID(N'dbo.SorguLoglari', N'U') IS NOT NULL AND COL_LENGTH('dbo.SorguLoglari', 'Cevap') IS NULL
    ALTER TABLE [dbo].[SorguLoglari] ADD [Cevap] NVARCHAR(1000) NULL;
GO

IF OBJECT_ID(N'dbo.SorguLoglari', N'U') IS NOT NULL AND COL_LENGTH('dbo.SorguLoglari', 'KullaniciAdi') IS NULL
    ALTER TABLE [dbo].[SorguLoglari] ADD [KullaniciAdi] NVARCHAR(100)  NULL;
GO

IF OBJECT_ID(N'dbo.SorguLoglari', N'U') IS NOT NULL AND COL_LENGTH('dbo.SorguLoglari', 'IpAdresi') IS NULL
    ALTER TABLE [dbo].[SorguLoglari] ADD [IpAdresi] NVARCHAR(50)   NULL;
GO

IF OBJECT_ID(N'dbo.SorguLoglari', N'U') IS NOT NULL AND COL_LENGTH('dbo.SorguLoglari', 'Tarih') IS NULL
    ALTER TABLE [dbo].[SorguLoglari] ADD [Tarih] DATETIME       NULL;
GO

IF OBJECT_ID(N'dbo.SorguLoglari', N'U') IS NOT NULL AND COL_LENGTH('dbo.SorguLoglari', 'BasariDurumu') IS NULL
    ALTER TABLE [dbo].[SorguLoglari] ADD [BasariDurumu] BIT            NULL;
GO



-- =============================================
    --FOREIGN KEY İLİŞKİLERİ(mevcut ise atla)
-- =============================================

    IF NOT EXISTS(SELECT * FROM sys.foreign_keys WHERE name = 'FK_Answer_ExamResult')
    ALTER TABLE [dbo].[Answer] WITH NOCHECK ADD CONSTRAINT[FK_Answer_ExamResult]
    FOREIGN KEY([ExamResultId]) REFERENCES[dbo].[ExamResult]([ExamResultId]);
GO

IF NOT EXISTS(SELECT * FROM sys.foreign_keys WHERE name = 'FK_Answer_Option')
    ALTER TABLE [dbo].[Answer] WITH NOCHECK ADD CONSTRAINT[FK_Answer_Option]
    FOREIGN KEY([OptionId]) REFERENCES[dbo].[QuestionOption]([OptionId]);
GO

IF NOT EXISTS(SELECT * FROM sys.foreign_keys WHERE name = 'FK_Answer_Question')
    ALTER TABLE [dbo].[Answer] WITH NOCHECK ADD CONSTRAINT[FK_Answer_Question]
    FOREIGN KEY([QuestionId]) REFERENCES[dbo].[Question]([QuestionId]);
GO

IF NOT EXISTS(SELECT * FROM sys.foreign_keys WHERE name = 'FK_Certificate_Course')
    ALTER TABLE [dbo].[Certificate] WITH NOCHECK ADD CONSTRAINT[FK_Certificate_Course]
    FOREIGN KEY([CourseId]) REFERENCES[dbo].[Courses]([CourseId]);
GO

IF NOT EXISTS(SELECT * FROM sys.foreign_keys WHERE name = 'FK_Certificate_ExamResult')
    ALTER TABLE [dbo].[Certificate] WITH NOCHECK ADD CONSTRAINT[FK_Certificate_ExamResult]
    FOREIGN KEY([ExamResultId]) REFERENCES[dbo].[ExamResult]([ExamResultId]);
GO

IF NOT EXISTS(SELECT * FROM sys.foreign_keys WHERE name = 'FK_Certificate_User')
    ALTER TABLE [dbo].[Certificate] WITH NOCHECK ADD CONSTRAINT[FK_Certificate_User]
    FOREIGN KEY([UserId]) REFERENCES[dbo].[E_User]([fldId]);
GO

IF NOT EXISTS(SELECT * FROM sys.foreign_keys WHERE name = 'FK_CourseContents_Course')
    ALTER TABLE [dbo].[CourseContents] WITH NOCHECK ADD CONSTRAINT[FK_CourseContents_Course]
    FOREIGN KEY([CourseId]) REFERENCES[dbo].[Courses]([CourseId]);
GO

IF NOT EXISTS(SELECT * FROM sys.foreign_keys WHERE name = 'FK_CourseEnrollments_Course')
    ALTER TABLE [dbo].[CourseEnrollments] WITH NOCHECK ADD CONSTRAINT[FK_CourseEnrollments_Course]
    FOREIGN KEY([CourseId]) REFERENCES[dbo].[Courses]([CourseId]);
GO

IF NOT EXISTS(SELECT * FROM sys.foreign_keys WHERE name = 'FK_CourseEnrollments_User')
    ALTER TABLE [dbo].[CourseEnrollments] WITH NOCHECK ADD CONSTRAINT[FK_CourseEnrollments_User]
    FOREIGN KEY([UserId]) REFERENCES[dbo].[E_User]([fldId]);
GO

IF NOT EXISTS(SELECT * FROM sys.foreign_keys WHERE name = 'FK_CourseReviews_Course')
    ALTER TABLE [dbo].[CourseReviews] WITH NOCHECK ADD CONSTRAINT[FK_CourseReviews_Course]
    FOREIGN KEY([CourseId]) REFERENCES[dbo].[Courses]([CourseId]);
GO

IF NOT EXISTS(SELECT * FROM sys.foreign_keys WHERE name = 'FK_CourseReviews_User')
    ALTER TABLE [dbo].[CourseReviews] WITH NOCHECK ADD CONSTRAINT[FK_CourseReviews_User]
    FOREIGN KEY([UserId])
REFERENCES[dbo].[E_User]([fldId]);
GO
IF NOT EXISTS(SELECT * FROM sys.foreign_keys WHERE name = 'FK_CourseReviews_ApprovedBy')
    ALTER TABLE [dbo].[CourseReviews] WITH NOCHECK ADD CONSTRAINT[FK_CourseReviews_ApprovedBy]
    FOREIGN KEY([ApprovedBy]) REFERENCES[dbo].[E_User]([fldId]);
GO

IF NOT EXISTS(SELECT * FROM sys.foreign_keys WHERE name = 'FK_Courses_Category')
    ALTER TABLE [dbo].[Courses] WITH NOCHECK ADD CONSTRAINT[FK_Courses_Category]
    FOREIGN KEY([CategoryId]) REFERENCES[dbo].[Categories]([CategoryId]);
GO

IF NOT EXISTS(SELECT * FROM sys.foreign_keys WHERE name = 'FK_Courses_CreatedBy')
    ALTER TABLE [dbo].[Courses] WITH NOCHECK ADD CONSTRAINT[FK_Courses_CreatedBy]
    FOREIGN KEY([CreatedBy]) REFERENCES[dbo].[E_User]([fldId]);
GO

IF NOT EXISTS(SELECT * FROM sys.foreign_keys WHERE name = 'FK_E_Messages_Sender')
    ALTER TABLE [dbo].[E_Messages] WITH NOCHECK ADD CONSTRAINT[FK_E_Messages_Sender]
    FOREIGN KEY([fldSenderId]) REFERENCES[dbo].[E_User]([fldId]);
GO

IF NOT EXISTS(SELECT * FROM sys.foreign_keys WHERE name = 'FK_E_Messages_Recipient')
    ALTER TABLE [dbo].[E_Messages] WITH NOCHECK ADD CONSTRAINT[FK_E_Messages_Recipient]
    FOREIGN KEY([fldRecipientId]) REFERENCES[dbo].[E_User]([fldId]);
GO

IF NOT EXISTS(SELECT * FROM sys.foreign_keys WHERE name = 'FK_E_Messages_Parent')
    ALTER TABLE [dbo].[E_Messages] WITH NOCHECK ADD CONSTRAINT[FK_E_Messages_Parent]
    FOREIGN KEY([fldParentMessageId]) REFERENCES[dbo].[E_Messages]([fldId]);
GO

IF NOT EXISTS(SELECT * FROM sys.foreign_keys WHERE name = 'FK_ExamResult_Exam')
    ALTER TABLE [dbo].[ExamResult] WITH NOCHECK ADD CONSTRAINT[FK_ExamResult_Exam]
    FOREIGN KEY([ExamId]) REFERENCES[dbo].[Exam]([ExamId]);
GO

IF NOT EXISTS(SELECT * FROM sys.foreign_keys WHERE name = 'FK_Question_Exam')
    ALTER TABLE [dbo].[Question] WITH NOCHECK ADD CONSTRAINT[FK_Question_Exam]
    FOREIGN KEY([ExamId]) REFERENCES[dbo].[Exam]([ExamId]);
GO

IF NOT EXISTS(SELECT * FROM sys.foreign_keys WHERE name = 'FK_QuestionMedia_Question')
    ALTER TABLE [dbo].[QuestionMedia] WITH NOCHECK ADD CONSTRAINT[FK_QuestionMedia_Question]
    FOREIGN KEY([QuestionId]) REFERENCES[dbo].[Question]([QuestionId]);
GO

IF NOT EXISTS(SELECT * FROM sys.foreign_keys WHERE name = 'FK_QuestionOption_Question')
    ALTER TABLE [dbo].[QuestionOption] WITH NOCHECK ADD CONSTRAINT[FK_QuestionOption_Question]
    FOREIGN KEY([QuestionId]) REFERENCES[dbo].[Question]([QuestionId]);
GO

-- =============================================
-- SONRADAN EKLENEN KOLONLAR / TABLOLAR / INDEXLER
-- Veri silmez, mevcut satirlarda deger degisikligi yapmaz.
-- =============================================

IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.E_Messages', 'fldIsApproved') IS NULL
        ALTER TABLE [dbo].[E_Messages] ADD [fldIsApproved] BIT NULL;

    IF COL_LENGTH('dbo.E_Messages', 'fldApprovedBy') IS NULL
        ALTER TABLE [dbo].[E_Messages] ADD [fldApprovedBy] INT NULL;

    IF COL_LENGTH('dbo.E_Messages', 'fldApprovedDateTime') IS NULL
        ALTER TABLE [dbo].[E_Messages] ADD [fldApprovedDateTime] DATETIME NULL;
END
GO

IF OBJECT_ID(N'dbo.TahditFormLog', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[TahditFormLog]
    (
        [Id] INT IDENTITY(1,1) NOT NULL CONSTRAINT [PK_TahditFormLog] PRIMARY KEY,
        [CreatedAt] DATETIME NOT NULL,
        [TahditCode] NVARCHAR(50) NULL,
        [IdariTahditCode] NVARCHAR(50) NULL,
        [PenaltyDay] INT NOT NULL CONSTRAINT [DF_TahditFormLog_PenaltyDay] DEFAULT(0),
        [PenaltyMonth] INT NOT NULL CONSTRAINT [DF_TahditFormLog_PenaltyMonth] DEFAULT(0),
        [PenaltyTotalDay] INT NOT NULL CONSTRAINT [DF_TahditFormLog_PenaltyTotalDay] DEFAULT(0),
        [PaymentType] NVARCHAR(20) NULL,
        [VisaType] INT NOT NULL CONSTRAINT [DF_TahditFormLog_VisaType] DEFAULT(0),
        [Country] NVARCHAR(150) NULL,
        [Border] NVARCHAR(150) NULL,
        [UserId] INT NULL,
        [UserSicil] NVARCHAR(50) NULL,
        [UserDisplayName] NVARCHAR(200) NULL,
        [PassengerName] NVARCHAR(200) NULL,
        [PassportNo] NVARCHAR(80) NULL,
        [FormMoney] NVARCHAR(80) NULL
    );
END
GO

IF OBJECT_ID(N'dbo.TahditFormLog', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.TahditFormLog', 'CreatedAt') IS NULL
        ALTER TABLE [dbo].[TahditFormLog] ADD [CreatedAt] DATETIME NULL;
    IF COL_LENGTH('dbo.TahditFormLog', 'TahditCode') IS NULL
        ALTER TABLE [dbo].[TahditFormLog] ADD [TahditCode] NVARCHAR(50) NULL;
    IF COL_LENGTH('dbo.TahditFormLog', 'IdariTahditCode') IS NULL
        ALTER TABLE [dbo].[TahditFormLog] ADD [IdariTahditCode] NVARCHAR(50) NULL;
    IF COL_LENGTH('dbo.TahditFormLog', 'PenaltyDay') IS NULL
        ALTER TABLE [dbo].[TahditFormLog] ADD [PenaltyDay] INT NULL;
    IF COL_LENGTH('dbo.TahditFormLog', 'PenaltyMonth') IS NULL
        ALTER TABLE [dbo].[TahditFormLog] ADD [PenaltyMonth] INT NULL;
    IF COL_LENGTH('dbo.TahditFormLog', 'PenaltyTotalDay') IS NULL
        ALTER TABLE [dbo].[TahditFormLog] ADD [PenaltyTotalDay] INT NULL;
    IF COL_LENGTH('dbo.TahditFormLog', 'PaymentType') IS NULL
        ALTER TABLE [dbo].[TahditFormLog] ADD [PaymentType] NVARCHAR(20) NULL;
    IF COL_LENGTH('dbo.TahditFormLog', 'VisaType') IS NULL
        ALTER TABLE [dbo].[TahditFormLog] ADD [VisaType] INT NULL;
    IF COL_LENGTH('dbo.TahditFormLog', 'Country') IS NULL
        ALTER TABLE [dbo].[TahditFormLog] ADD [Country] NVARCHAR(150) NULL;
    IF COL_LENGTH('dbo.TahditFormLog', 'Border') IS NULL
        ALTER TABLE [dbo].[TahditFormLog] ADD [Border] NVARCHAR(150) NULL;
    IF COL_LENGTH('dbo.TahditFormLog', 'UserId') IS NULL
        ALTER TABLE [dbo].[TahditFormLog] ADD [UserId] INT NULL;
    IF COL_LENGTH('dbo.TahditFormLog', 'UserSicil') IS NULL
        ALTER TABLE [dbo].[TahditFormLog] ADD [UserSicil] NVARCHAR(50) NULL;
    IF COL_LENGTH('dbo.TahditFormLog', 'UserDisplayName') IS NULL
        ALTER TABLE [dbo].[TahditFormLog] ADD [UserDisplayName] NVARCHAR(200) NULL;
    IF COL_LENGTH('dbo.TahditFormLog', 'PassengerName') IS NULL
        ALTER TABLE [dbo].[TahditFormLog] ADD [PassengerName] NVARCHAR(200) NULL;
    IF COL_LENGTH('dbo.TahditFormLog', 'PassportNo') IS NULL
        ALTER TABLE [dbo].[TahditFormLog] ADD [PassportNo] NVARCHAR(80) NULL;
    IF COL_LENGTH('dbo.TahditFormLog', 'FormMoney') IS NULL
        ALTER TABLE [dbo].[TahditFormLog] ADD [FormMoney] NVARCHAR(80) NULL;
END
GO

-- =============================================
-- FOREIGN KEY TAMAMLAMA
-- WITH NOCHECK mevcut veriyi tarayip degistirmez; yeni kayitlarda iliskiyi uygular.
-- =============================================

IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL
   AND OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL
   AND COL_LENGTH('dbo.E_Messages', 'fldApprovedBy') IS NOT NULL
   AND NOT EXISTS(SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_E_Messages_ApprovedBy')
BEGIN
    ALTER TABLE [dbo].[E_Messages] WITH NOCHECK
    ADD CONSTRAINT [FK_E_Messages_ApprovedBy]
    FOREIGN KEY([fldApprovedBy]) REFERENCES [dbo].[E_User]([fldId]);
END
GO

-- =============================================
-- INDEX TAMAMLAMA
-- =============================================

IF OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL
   AND COL_LENGTH('dbo.Courses', 'CourseTitle') IS NOT NULL
   AND NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name = 'IX_Courses_Title' AND object_id = OBJECT_ID(N'dbo.Courses'))
    CREATE INDEX [IX_Courses_Title] ON [dbo].[Courses]([CourseTitle]);
GO

IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL
   AND COL_LENGTH('dbo.E_Messages', 'fldIsApproved') IS NOT NULL
   AND COL_LENGTH('dbo.E_Messages', 'fldDateTime') IS NOT NULL
   AND NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name = 'IX_E_Messages_IsApproved' AND object_id = OBJECT_ID(N'dbo.E_Messages'))
    CREATE INDEX [IX_E_Messages_IsApproved] ON [dbo].[E_Messages]([fldIsApproved], [fldDateTime]);
GO

IF OBJECT_ID(N'dbo.TahditKod', N'U') IS NOT NULL
   AND COL_LENGTH('dbo.TahditKod', 'Aktif') IS NOT NULL
   AND COL_LENGTH('dbo.TahditKod', 'Kod') IS NOT NULL
   AND NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name = 'IX_TahditKod_Aktif_Kod' AND object_id = OBJECT_ID(N'dbo.TahditKod'))
    CREATE INDEX [IX_TahditKod_Aktif_Kod] ON [dbo].[TahditKod]([Aktif], [Kod]);
GO

IF OBJECT_ID(N'dbo.TahditFormLog', N'U') IS NOT NULL
   AND COL_LENGTH('dbo.TahditFormLog', 'CreatedAt') IS NOT NULL
   AND NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name = 'IX_TahditFormLog_CreatedAt' AND object_id = OBJECT_ID(N'dbo.TahditFormLog'))
    CREATE INDEX [IX_TahditFormLog_CreatedAt] ON [dbo].[TahditFormLog]([CreatedAt]);
GO

IF OBJECT_ID(N'dbo.TahditFormLog', N'U') IS NOT NULL
   AND COL_LENGTH('dbo.TahditFormLog', 'TahditCode') IS NOT NULL
   AND COL_LENGTH('dbo.TahditFormLog', 'CreatedAt') IS NOT NULL
   AND NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name = 'IX_TahditFormLog_CodeCreatedAt' AND object_id = OBJECT_ID(N'dbo.TahditFormLog'))
    CREATE INDEX [IX_TahditFormLog_CodeCreatedAt] ON [dbo].[TahditFormLog]([TahditCode], [CreatedAt]);
GO

IF OBJECT_ID(N'dbo.TahditFormLog', N'U') IS NOT NULL
   AND COL_LENGTH('dbo.TahditFormLog', 'Border') IS NOT NULL
   AND COL_LENGTH('dbo.TahditFormLog', 'CreatedAt') IS NOT NULL
   AND NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name = 'IX_TahditFormLog_BorderCreatedAt' AND object_id = OBJECT_ID(N'dbo.TahditFormLog'))
    CREATE INDEX [IX_TahditFormLog_BorderCreatedAt] ON [dbo].[TahditFormLog]([Border], [CreatedAt]);
GO

IF OBJECT_ID(N'dbo.TahditFormLog', N'U') IS NOT NULL
   AND COL_LENGTH('dbo.TahditFormLog', 'UserId') IS NOT NULL
   AND COL_LENGTH('dbo.TahditFormLog', 'UserSicil') IS NOT NULL
   AND COL_LENGTH('dbo.TahditFormLog', 'CreatedAt') IS NOT NULL
   AND NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name = 'IX_TahditFormLog_UserCreatedAt' AND object_id = OBJECT_ID(N'dbo.TahditFormLog'))
    CREATE INDEX [IX_TahditFormLog_UserCreatedAt] ON [dbo].[TahditFormLog]([UserId], [UserSicil], [CreatedAt]);
GO


IF OBJECT_ID(N'dbo.PasswordResetRequests', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[PasswordResetRequests] (
        [RequestId] int IDENTITY(1,1) NOT NULL CONSTRAINT [PK_PasswordResetRequests] PRIMARY KEY,
        [UserId] int NOT NULL,
        [PendingPasswordHash] nvarchar(255) NOT NULL,
        [RequestedAt] datetime NOT NULL CONSTRAINT [DF_PasswordResetRequests_RequestedAt] DEFAULT (GETDATE()),
        [Status] nvarchar(20) NOT NULL CONSTRAINT [DF_PasswordResetRequests_Status] DEFAULT ('Pending'),
        [ApprovedAt] datetime NULL,
        [ApprovedByUserId] int NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PasswordResetRequests_StatusRequestedAt' AND object_id = OBJECT_ID(N'dbo.PasswordResetRequests'))
    CREATE INDEX [IX_PasswordResetRequests_StatusRequestedAt] ON [dbo].[PasswordResetRequests]([Status], [RequestedAt]);
GO

PRINT 'CEZA schema repair tamamlandi. Veri silme/guncelleme yapilmadi.';
GO





