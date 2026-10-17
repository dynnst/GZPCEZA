-- ==========================================================================
-- CEZAM VÄ°ZE VE CEZA HESAPLAMA SÄ°STEMÄ° - VERÄ°TABANI ÅEMASI
-- Dosya: 01_CREATE_ALL_TABLES_AND_CONSTRAINTS.sql
-- Tarih: 17.10.2026 23:21:32
-- Hedef: SQL Server 2016+ / LocalDB / Express / Standard / Enterprise
-- AÃ§Ä±klama: CEZA veritabanÄ±nÄ± ve tÃ¼m tablolarÄ±, birincil anahtarlarÄ±, indeksleri ve yabancÄ± anahtarlarÄ± oluÅŸturur.
-- ==========================================================================

IF DB_ID('CEZA') IS NULL
BEGIN
    PRINT 'CEZA veritabani olusturuluyor...';
    CREATE DATABASE [CEZA];
END
GO

USE [CEZA];
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Airline]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Airline](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IATACode] [nvarchar](7) NOT NULL,
	[Name] [nvarchar](150) NOT NULL,
	[Country] [nvarchar](100) NULL,
	[IsActive] [bit] NOT NULL,
	[IsUserDefined] [bit] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_Airline] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Answer]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Answer](
	[AnswerId] [int] IDENTITY(1,1) NOT NULL,
	[ExamResultId] [int] NOT NULL,
	[QuestionId] [int] NOT NULL,
	[OptionId] [int] NULL,
	[TextAnswer] [nvarchar](max) NULL,
 CONSTRAINT [PK_Answer] PRIMARY KEY CLUSTERED 
(
	[AnswerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Answer]') AND name = N'IX_FK_Answer_ExamResult')
CREATE NONCLUSTERED INDEX [IX_FK_Answer_ExamResult] ON [dbo].[Answer]
(
	[ExamResultId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Answer]') AND name = N'IX_FK_Answer_Option')
CREATE NONCLUSTERED INDEX [IX_FK_Answer_Option] ON [dbo].[Answer]
(
	[OptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Answer]') AND name = N'IX_FK_Answer_Question')
CREATE NONCLUSTERED INDEX [IX_FK_Answer_Question] ON [dbo].[Answer]
(
	[QuestionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Categories]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Categories](
	[CategoryId] [int] IDENTITY(1,1) NOT NULL,
	[CategoryName] [nvarchar](200) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Categories] PRIMARY KEY CLUSTERED 
(
	[CategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Certificate]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Certificate](
	[CertificateId] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[CourseId] [int] NOT NULL,
	[ExamResultId] [int] NULL,
	[CertificateNumber] [nvarchar](50) NOT NULL,
	[FilePath] [nvarchar](500) NULL,
	[IssuedDate] [datetime] NOT NULL,
	[Score] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
 CONSTRAINT [PK_Certificate] PRIMARY KEY CLUSTERED 
(
	[CertificateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Certificate]') AND name = N'IX_FK_Certificate_Course')
CREATE NONCLUSTERED INDEX [IX_FK_Certificate_Course] ON [dbo].[Certificate]
(
	[CourseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Certificate]') AND name = N'IX_FK_Certificate_ExamResult')
CREATE NONCLUSTERED INDEX [IX_FK_Certificate_ExamResult] ON [dbo].[Certificate]
(
	[ExamResultId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Certificate]') AND name = N'IX_FK_Certificate_User')
CREATE NONCLUSTERED INDEX [IX_FK_Certificate_User] ON [dbo].[Certificate]
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CertificateRequest]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[CertificateRequest](
	[RequestId] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[CourseId] [int] NOT NULL,
	[RequestDate] [datetime] NOT NULL,
	[Status] [tinyint] NOT NULL,
	[AdminNote] [nvarchar](500) NULL,
	[ProcessedDate] [datetime] NULL,
	[ProcessedBy] [int] NULL,
 CONSTRAINT [PK_CertificateRequest] PRIMARY KEY CLUSTERED 
(
	[RequestId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChatMessages]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ChatMessages](
	[ChatMessageId] [int] IDENTITY(1,1) NOT NULL,
	[SenderId] [int] NOT NULL,
	[RecipientId] [int] NOT NULL,
	[MessageText] [nvarchar](2000) NULL,
	[ImagePath] [nvarchar](500) NULL,
	[CreatedAt] [datetime] NOT NULL,
	[ReadAt] [datetime] NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_ChatMessages] PRIMARY KEY CLUSTERED 
(
	[ChatMessageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[ChatMessages]') AND name = N'IX_ChatMessages_Pair')
CREATE NONCLUSTERED INDEX [IX_ChatMessages_Pair] ON [dbo].[ChatMessages]
(
	[SenderId] ASC,
	[RecipientId] ASC,
	[ChatMessageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[ChatMessages]') AND name = N'IX_ChatMessages_RecipientRead')
CREATE NONCLUSTERED INDEX [IX_ChatMessages_RecipientRead] ON [dbo].[ChatMessages]
(
	[RecipientId] ASC,
	[ReadAt] ASC,
	[ChatMessageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[ChatMessages]') AND name = N'IX_ChatMessages_Room')
CREATE NONCLUSTERED INDEX [IX_ChatMessages_Room] ON [dbo].[ChatMessages]
(
	[RecipientId] ASC,
	[ChatMessageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_ChatMessages_CreatedAt]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[ChatMessages] ADD  CONSTRAINT [DF_ChatMessages_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_ChatMessages_IsDeleted]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[ChatMessages] ADD  CONSTRAINT [DF_ChatMessages_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
END

GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChatOnlineUsers]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ChatOnlineUsers](
	[UserId] [int] NOT NULL,
	[LastSeen] [datetime] NOT NULL,
	[LastPage] [nvarchar](500) NULL,
 CONSTRAINT [PK_ChatOnlineUsers] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[ChatOnlineUsers]') AND name = N'IX_ChatOnlineUsers_LastSeen')
CREATE NONCLUSTERED INDEX [IX_ChatOnlineUsers_LastSeen] ON [dbo].[ChatOnlineUsers]
(
	[LastSeen] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CourseContents]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[CourseContents](
	[ContentId] [int] IDENTITY(1,1) NOT NULL,
	[CourseId] [int] NOT NULL,
	[ContentType] [nvarchar](20) NOT NULL,
	[ContentTitle] [nvarchar](200) NULL,
	[FilePath] [nvarchar](500) NOT NULL,
	[CreatedDate] [datetime] NULL,
	[ContentDescription] [nvarchar](max) NULL,
 CONSTRAINT [PK_CourseContents] PRIMARY KEY CLUSTERED 
(
	[ContentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CourseContents]') AND name = N'IX_FK_CourseContents_Course')
CREATE NONCLUSTERED INDEX [IX_FK_CourseContents_Course] ON [dbo].[CourseContents]
(
	[CourseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CourseEnrollments]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[CourseEnrollments](
	[EnrollmentId] [int] IDENTITY(1,1) NOT NULL,
	[CourseId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[EnrollmentDate] [datetime] NULL,
	[IsDrawEntry] [bit] NOT NULL,
	[DrawEntryDate] [datetime] NULL,
 CONSTRAINT [PK_CourseEnrollments] PRIMARY KEY CLUSTERED 
(
	[EnrollmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CourseEnrollments]') AND name = N'IX_FK_CourseEnrollments_Course')
CREATE NONCLUSTERED INDEX [IX_FK_CourseEnrollments_Course] ON [dbo].[CourseEnrollments]
(
	[CourseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CourseEnrollments]') AND name = N'IX_FK_CourseEnrollments_User')
CREATE NONCLUSTERED INDEX [IX_FK_CourseEnrollments_User] ON [dbo].[CourseEnrollments]
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CourseReviews]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[CourseReviews](
	[ReviewId] [int] IDENTITY(1,1) NOT NULL,
	[CourseId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[Rating] [tinyint] NOT NULL,
	[Comment] [nvarchar](max) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[IsApproved] [bit] NOT NULL,
	[ApprovedBy] [int] NULL,
	[ApprovedDate] [datetime] NULL,
 CONSTRAINT [PK_CourseReviews] PRIMARY KEY CLUSTERED 
(
	[ReviewId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CourseReviews]') AND name = N'IX_FK_CourseReviews_ApprovedBy')
CREATE NONCLUSTERED INDEX [IX_FK_CourseReviews_ApprovedBy] ON [dbo].[CourseReviews]
(
	[ApprovedBy] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CourseReviews]') AND name = N'IX_FK_CourseReviews_Course')
CREATE NONCLUSTERED INDEX [IX_FK_CourseReviews_Course] ON [dbo].[CourseReviews]
(
	[CourseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CourseReviews]') AND name = N'IX_FK_CourseReviews_User')
CREATE NONCLUSTERED INDEX [IX_FK_CourseReviews_User] ON [dbo].[CourseReviews]
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Courses]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Courses](
	[CourseId] [int] IDENTITY(1,1) NOT NULL,
	[CourseTitle] [nvarchar](200) NOT NULL,
	[CourseDescription] [nvarchar](max) NULL,
	[CoverImage] [nvarchar](max) NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [datetime] NULL,
	[CategoryId] [int] NOT NULL,
	[ResourceFile] [nvarchar](max) NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_Courses] PRIMARY KEY CLUSTERED 
(
	[CourseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Courses]') AND name = N'IX_FK_Courses_Category')
CREATE NONCLUSTERED INDEX [IX_FK_Courses_Category] ON [dbo].[Courses]
(
	[CategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Courses]') AND name = N'IX_FK_Courses_CreatedBy')
CREATE NONCLUSTERED INDEX [IX_FK_Courses_CreatedBy] ON [dbo].[Courses]
(
	[CreatedBy] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DocumentTerms]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[DocumentTerms](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Term] [nvarchar](200) NOT NULL,
	[Slug] [nvarchar](250) NOT NULL,
	[Category] [nvarchar](100) NOT NULL,
	[Definition] [nvarchar](max) NOT NULL,
	[DetailedDescription] [nvarchar](max) NULL,
	[ImageUrl] [nvarchar](500) NULL,
	[RelatedTerms] [nvarchar](500) NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedAt] [datetime] NULL,
	[UpdatedAt] [datetime] NULL,
	[Sicil] [nvarchar](50) NULL,
	[AdSoyad] [nvarchar](200) NULL,
 CONSTRAINT [PK_DocumentTerms] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_AUH]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[E_AUH](
	[fldId] [int] IDENTITY(1,1) NOT NULL,
	[fldCountry] [nvarchar](max) NULL,
	[fldFirstMounth] [nvarchar](max) NULL,
	[fldKat] [nvarchar](max) NULL,
	[fldDayStart] [nvarchar](max) NULL,
	[fldDayKat] [nvarchar](max) NULL,
	[fldToM] [nvarchar](max) NULL,
 CONSTRAINT [PK_E_AUH] PRIMARY KEY CLUSTERED 
(
	[fldId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_Border]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[E_Border](
	[fldId] [int] IDENTITY(1,1) NOT NULL,
	[fldName] [nvarchar](max) NULL,
 CONSTRAINT [PK_E_Border] PRIMARY KEY CLUSTERED 
(
	[fldId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_Defter]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[E_Defter](
	[fldId] [int] IDENTITY(1,1) NOT NULL,
	[fldPrice] [nvarchar](25) NULL,
	[fldTypeofMoney] [nvarchar](50) NULL,
 CONSTRAINT [PK_E_Defter] PRIMARY KEY CLUSTERED 
(
	[fldId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_Dilekce]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[E_Dilekce](
	[DilekceId] [int] IDENTITY(1,1) NOT NULL,
	[AdSoyad] [nvarchar](100) NULL,
	[DogumTarih] [date] NULL,
	[DogumYeri] [nvarchar](250) NULL,
	[PasaportNo] [nvarchar](250) NULL,
	[KimlikNo] [nvarchar](250) NULL,
	[Adres] [nvarchar](250) NULL,
	[Telefon] [nchar](20) NULL,
	[Uyruk] [nvarchar](500) NULL,
	[DilekceTarih] [date] NULL,
	[Tarih1] [date] NULL,
	[Tarih2] [date] NULL,
	[DilekceSebep] [nvarchar](max) NULL,
	[Valilik] [nvarchar](500) NULL,
	[DosyaNo] [nchar](50) NULL,
	[Unvan] [nvarchar](500) NULL,
	[Aciklama] [nvarchar](max) NULL,
	[Sicil] [nvarchar](max) NULL,
 CONSTRAINT [PK_E_DilekceGirisCikis] PRIMARY KEY CLUSTERED 
(
	[DilekceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_Exchange]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[E_Exchange](
	[fldId] [int] IDENTITY(1,1) NOT NULL,
	[fldEuro] [nvarchar](50) NULL,
	[fldDollar] [nvarchar](50) NULL,
	[fldPaund] [nvarchar](50) NULL,
 CONSTRAINT [PK_E_Exchange] PRIMARY KEY CLUSTERED 
(
	[fldId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_Forms]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[E_Forms](
	[fldId] [int] IDENTITY(1,1) NOT NULL,
	[fldGB] [nvarchar](max) NULL,
	[fldDE] [nvarchar](max) NULL,
	[fldRU] [nvarchar](max) NULL,
	[fldIR] [nvarchar](max) NULL,
	[fldGBC] [nvarchar](max) NULL,
	[fldDEC] [nvarchar](max) NULL,
	[fldRUC] [nvarchar](max) NULL,
	[fldIRC] [nvarchar](max) NULL,
	[fldIRKC] [nvarchar](max) NULL,
	[fldIRK] [nvarchar](max) NULL,
	[fldFransizca] [nvarchar](max) NULL,
	[fldFransizcaC] [nvarchar](max) NULL,
 CONSTRAINT [PK_E_Forms] PRIMARY KEY CLUSTERED 
(
	[fldId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_History]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[E_History](
	[fldId] [int] IDENTITY(1,1) NOT NULL,
	[fldStart] [datetime] NULL,
	[fldShouldExit] [datetime] NULL,
	[fldBirthDate] [datetime] NULL,
	[fldCountry] [nvarchar](max) NULL,
	[fldPenalty] [nvarchar](max) NULL,
	[fldPMoney] [nvarchar](max) NULL,
	[fldUser] [nvarchar](max) NULL,
	[fldBorder] [nvarchar](max) NULL,
	[fldDatetime] [datetime] NULL,
 CONSTRAINT [PK_E_History] PRIMARY KEY CLUSTERED 
(
	[fldId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[E_History]') AND name = N'IX_E_History_Datetime')
CREATE NONCLUSTERED INDEX [IX_E_History_Datetime] ON [dbo].[E_History]
(
	[fldDatetime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_Inad]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[E_Inad](
	[InadId] [int] IDENTITY(1,1) NOT NULL,
	[TarihSaat] [date] NULL,
	[AdSoyad] [nchar](50) NULL,
	[DogumT] [date] NULL,
	[DogumY] [nvarchar](50) NULL,
	[Cinsiyet] [nvarchar](10) NULL,
	[Uyruk] [nchar](250) NULL,
	[PasaportNo] [nchar](20) NULL,
	[BelgeNo] [nvarchar](20) NULL,
	[PasaportTuru] [nchar](50) NULL,
	[Beyan] [nvarchar](100) NULL,
	[GelenUcusNo] [nvarchar](10) NULL,
	[GelenHavayolu] [nvarchar](150) NULL,
	[GeldigiYer] [nchar](250) NULL,
	[GeldigiTarihSaat] [datetime] NULL,
	[InadSebepAciklama] [nvarchar](max) NULL,
	[InadSebep] [nvarchar](max) NULL,
	[GidenHavayolu] [nvarchar](150) NULL,
	[GidisUcusNo] [nvarchar](10) NULL,
	[GidisYer] [nchar](250) NULL,
	[GidisTarihSaat] [datetime] NULL,
	[Personel] [nvarchar](max) NULL,
	[UstAramaEsya] [nvarchar](max) NULL,
	[UcagaNakil] [nvarchar](max) NULL,
	[OzelGuvenlik] [nvarchar](50) NULL,
	[YerHizmetleriPersonel] [nvarchar](50) NULL,
	[YerHizmetleri] [nchar](250) NULL,
	[Refakat] [nvarchar](250) NULL,
	[Kapi] [nvarchar](max) NULL,
	[Valilik] [nvarchar](max) NULL,
	[Durum] [nvarchar](max) NULL,
	[Sicil] [nvarchar](max) NULL,
 CONSTRAINT [PK_E_Inad] PRIMARY KEY CLUSTERED 
(
	[InadId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_IsK]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[E_IsK](
	[fldId] [int] IDENTITY(1,1) NOT NULL,
	[fldDatetime] [datetime] NULL,
	[fldName] [nvarchar](max) NULL,
	[fldPassport] [nvarchar](max) NULL,
	[fldIdn] [nvarchar](max) NULL,
	[fldOrgin] [nvarchar](max) NULL,
	[fldBirthdate] [date] NULL,
	[fldForm] [nvarchar](max) NULL,
	[fldPassControl] [nvarchar](max) NULL,
	[fldApproval] [nvarchar](max) NULL,
	[fldBorder] [nvarchar](max) NULL,
	[fldVisa] [nvarchar](max) NULL,
	[fldPMoney] [nvarchar](max) NULL,
	[fldPicture] [nvarchar](max) NULL,
 CONSTRAINT [PK_E_IsK] PRIMARY KEY CLUSTERED 
(
	[fldId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_Messages]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[E_Messages](
	[fldId] [int] IDENTITY(1,1) NOT NULL,
	[fldSendByName] [nvarchar](max) NULL,
	[fldSendBySicil] [nvarchar](max) NULL,
	[fldSendByPhone] [nvarchar](max) NULL,
	[fldSendByMail] [nvarchar](max) NULL,
	[fldDateTime] [datetime] NULL,
	[fldMessage] [nvarchar](max) NULL,
	[fldSenderId] [int] NULL,
	[fldSenderRole] [nvarchar](20) NULL,
	[fldRecipientId] [int] NULL,
	[fldRecipientRole] [nvarchar](20) NULL,
	[fldSubject] [nvarchar](200) NULL,
	[fldIsRead] [bit] NOT NULL,
	[fldReadDateTime] [datetime] NULL,
	[fldIsDeletedBySender] [bit] NOT NULL,
	[fldIsDeletedByRecipient] [bit] NOT NULL,
	[fldParentMessageId] [int] NULL,
	[fldIsReply] [bit] NOT NULL,
	[fldIsApproved] [bit] NOT NULL,
	[fldApprovedBy] [int] NULL,
	[fldApprovedDateTime] [datetime] NULL,
 CONSTRAINT [PK_E_Messages] PRIMARY KEY CLUSTERED 
(
	[fldId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[E_Messages]') AND name = N'IX_E_Messages_DateTime')
CREATE NONCLUSTERED INDEX [IX_E_Messages_DateTime] ON [dbo].[E_Messages]
(
	[fldDateTime] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[E_Messages]') AND name = N'IX_E_Messages_ParentMessageId')
CREATE NONCLUSTERED INDEX [IX_E_Messages_ParentMessageId] ON [dbo].[E_Messages]
(
	[fldParentMessageId] ASC
)
WHERE ([fldParentMessageId] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[E_Messages]') AND name = N'IX_E_Messages_RecipientId')
CREATE NONCLUSTERED INDEX [IX_E_Messages_RecipientId] ON [dbo].[E_Messages]
(
	[fldRecipientId] ASC
)
INCLUDE([fldIsRead],[fldIsDeletedByRecipient],[fldDateTime]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[E_Messages]') AND name = N'IX_E_Messages_SenderId')
CREATE NONCLUSTERED INDEX [IX_E_Messages_SenderId] ON [dbo].[E_Messages]
(
	[fldSenderId] ASC
)
INCLUDE([fldIsDeletedBySender],[fldDateTime]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__E_Message__fldIs__119F9925]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[E_Messages] ADD  DEFAULT ((0)) FOR [fldIsRead]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__E_Message__fldIs__1293BD5E]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[E_Messages] ADD  DEFAULT ((0)) FOR [fldIsDeletedBySender]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__E_Message__fldIs__1387E197]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[E_Messages] ADD  DEFAULT ((0)) FOR [fldIsDeletedByRecipient]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__E_Message__fldIs__147C05D0]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[E_Messages] ADD  DEFAULT ((0)) FOR [fldIsReply]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__E_Message__fldIs__546180BB]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[E_Messages] ADD  DEFAULT ((0)) FOR [fldIsApproved]
END

GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_Sartli]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[E_Sartli](
	[fldId] [int] IDENTITY(1,1) NOT NULL,
	[fldBy] [varchar](150) NULL,
	[fldOrgin] [nvarchar](50) NULL,
	[fldBdate] [date] NULL,
	[fldDate] [datetime] NULL,
	[fldName] [nvarchar](250) NULL,
	[fldBorder] [nvarchar](500) NULL,
 CONSTRAINT [PK_E_Sartli] PRIMARY KEY CLUSTERED 
(
	[fldId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_TGVH]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[E_TGVH](
	[fldId] [int] IDENTITY(1,1) NOT NULL,
	[fldPrice] [nvarchar](25) NULL,
	[fldTypeofMoney] [nvarchar](25) NULL,
	[fldYear] [nvarchar](25) NULL,
 CONSTRAINT [PK_E_TGVH] PRIMARY KEY CLUSTERED 
(
	[fldId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
SET ANSI_PADDING ON

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[E_TGVH]') AND name = N'IX_E_TGVH_Year')
CREATE NONCLUSTERED INDEX [IX_E_TGVH_Year] ON [dbo].[E_TGVH]
(
	[fldYear] ASC
)
INCLUDE([fldPrice],[fldTypeofMoney]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_TKOD]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[E_TKOD](
	[fldId] [int] IDENTITY(1,1) NOT NULL,
	[fldCode] [nvarchar](50) NULL,
	[fldPTime] [nvarchar](50) NULL,
	[fldStart] [int] NULL,
	[fldFinish] [int] NULL,
	[fldIdariCode] [nvarchar](50) NULL,
	[fldPaid] [tinyint] NULL,
 CONSTRAINT [PK_E_TKOD] PRIMARY KEY CLUSTERED 
(
	[fldId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[E_TKOD]') AND name = N'IX_E_TKOD_Paid_Start_Finish')
CREATE NONCLUSTERED INDEX [IX_E_TKOD_Paid_Start_Finish] ON [dbo].[E_TKOD]
(
	[fldPaid] ASC,
	[fldStart] ASC,
	[fldFinish] ASC
)
INCLUDE([fldCode],[fldIdariCode],[fldPTime]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_Token]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[E_Token](
	[fldId] [int] IDENTITY(1,1) NOT NULL,
	[fldUserId] [int] NULL,
	[fldToken] [nvarchar](max) NULL,
	[fldDateTime] [datetime] NULL,
	[fldIp] [nvarchar](50) NULL,
 CONSTRAINT [PK_E_Token] PRIMARY KEY CLUSTERED 
(
	[fldId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_User]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[E_User](
	[fldId] [int] IDENTITY(1,1) NOT NULL,
	[fldSicil] [nvarchar](max) NULL,
	[fldName] [nvarchar](max) NULL,
	[fldLastName] [nvarchar](max) NULL,
	[fldPhone] [nvarchar](max) NULL,
	[fldEmail] [nvarchar](max) NULL,
	[fldTitle] [nvarchar](max) NULL,
	[fldDeputy] [nvarchar](max) NULL,
	[fldPicture] [nvarchar](max) NULL,
	[fldAuth] [nvarchar](max) NULL,
	[fldSubAuth] [nvarchar](max) NULL,
	[fldPassword] [nvarchar](max) NULL,
	[fldDateTime] [datetime] NULL,
	[fldBorder] [nvarchar](max) NULL,
	[fldActive] [nchar](1) NULL,
	[Role] [nvarchar](20) NOT NULL,
	[LastLogin] [datetime] NULL,
	[XP] [int] NOT NULL,
	[Level] [int] NOT NULL,
	[IsActive] [bit] NULL,
	[TeacherRequestStatus] [tinyint] NULL,
	[TeacherRequestDate] [datetime] NULL,
 CONSTRAINT [PK_E_User] PRIMARY KEY CLUSTERED 
(
	[fldId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__E_User__Role__7CA47C3F]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[E_User] ADD  DEFAULT ('User') FOR [Role]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__E_User__XP__7D98A078]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[E_User] ADD  DEFAULT ((0)) FOR [XP]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__E_User__Level__7E8CC4B1]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[E_User] ADD  DEFAULT ((1)) FOR [Level]
END

GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_UVR]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[E_UVR](
	[fldId] [int] IDENTITY(1,1) NOT NULL,
	[fldCountry] [nvarchar](max) NULL,
	[fldCalculateType] [int] NULL,
	[fldPassportType] [int] NULL,
	[fldVisaStatus] [int] NULL,
	[fldDay] [int] NULL,
	[fldLong] [int] NULL,
	[fldOneTime] [int] NULL,
	[fldHB] [tinyint] NULL,
 CONSTRAINT [PK_E_UVR] PRIMARY KEY CLUSTERED 
(
	[fldId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_UVR_Backup_Before_WorkPermit]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[E_UVR_Backup_Before_WorkPermit](
	[fldId] [int] IDENTITY(1,1) NOT NULL,
	[fldCountry] [nvarchar](max) NULL,
	[fldCalculateType] [int] NULL,
	[fldPassportType] [int] NULL,
	[fldVisaStatus] [int] NULL,
	[fldDay] [int] NULL,
	[fldLong] [int] NULL,
	[fldOneTime] [int] NULL,
	[fldHB] [tinyint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EducationPackageImportLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[EducationPackageImportLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PackageCode] [nvarchar](100) NULL,
	[PackageTitle] [nvarchar](300) NULL,
	[PackageVersion] [nvarchar](30) NULL,
	[SourceDocumentCode] [nvarchar](100) NULL,
	[ImportedCourseId] [int] NULL,
	[ImportedExamId] [int] NULL,
	[ImportedByUserId] [int] NOT NULL,
	[ImportedDate] [datetime] NOT NULL,
	[FileName] [nvarchar](260) NULL,
	[Status] [nvarchar](30) NOT NULL,
	[Message] [nvarchar](2000) NULL,
 CONSTRAINT [PK_EducationPackageImportLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[EducationPackageImportLog]') AND name = N'IX_EducationPackageImportLog_Date')
CREATE NONCLUSTERED INDEX [IX_EducationPackageImportLog_Date] ON [dbo].[EducationPackageImportLog]
(
	[ImportedDate] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[EducationPackageImportLog]') AND name = N'IX_EducationPackageImportLog_Package')
CREATE NONCLUSTERED INDEX [IX_EducationPackageImportLog_Package] ON [dbo].[EducationPackageImportLog]
(
	[PackageCode] ASC,
	[PackageVersion] ASC,
	[Status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_EducationPackageImportLog_ImportedDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[EducationPackageImportLog] ADD  CONSTRAINT [DF_EducationPackageImportLog_ImportedDate]  DEFAULT (getdate()) FOR [ImportedDate]
END

GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Exam]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Exam](
	[ExamId] [int] IDENTITY(1,1) NOT NULL,
	[CourseId] [int] NOT NULL,
	[Title] [nvarchar](200) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[DurationMinutes] [int] NULL,
	[PassingScore] [int] NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
	[IsArchived] [bit] NULL,
 CONSTRAINT [PK_Exam] PRIMARY KEY CLUSTERED 
(
	[ExamId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ExamResult]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ExamResult](
	[ExamResultId] [int] IDENTITY(1,1) NOT NULL,
	[ExamId] [int] NOT NULL,
	[UserId] [int] NULL,
	[Score] [decimal](5, 2) NULL,
	[StartedAt] [datetime] NULL,
	[FinishedAt] [datetime] NULL,
	[Status] [tinyint] NOT NULL,
 CONSTRAINT [PK_ExamResult] PRIMARY KEY CLUSTERED 
(
	[ExamResultId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[ExamResult]') AND name = N'IX_FK_ExamResult_Exam')
CREATE NONCLUSTERED INDEX [IX_FK_ExamResult_Exam] ON [dbo].[ExamResult]
(
	[ExamId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PasswordResetRequests]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PasswordResetRequests](
	[RequestId] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[PendingPasswordHash] [nvarchar](255) NOT NULL,
	[RequestedAt] [datetime] NOT NULL,
	[Status] [nvarchar](20) NOT NULL,
	[ApprovedAt] [datetime] NULL,
	[ApprovedByUserId] [int] NULL,
 CONSTRAINT [PK_PasswordResetRequests] PRIMARY KEY CLUSTERED 
(
	[RequestId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
SET ANSI_PADDING ON

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[PasswordResetRequests]') AND name = N'IX_PasswordResetRequests_StatusRequestedAt')
CREATE NONCLUSTERED INDEX [IX_PasswordResetRequests_StatusRequestedAt] ON [dbo].[PasswordResetRequests]
(
	[Status] ASC,
	[RequestedAt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_PasswordResetRequests_RequestedAt]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[PasswordResetRequests] ADD  CONSTRAINT [DF_PasswordResetRequests_RequestedAt]  DEFAULT (getdate()) FOR [RequestedAt]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_PasswordResetRequests_Status]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[PasswordResetRequests] ADD  CONSTRAINT [DF_PasswordResetRequests_Status]  DEFAULT ('Pending') FOR [Status]
END

GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Question]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Question](
	[QuestionId] [int] IDENTITY(1,1) NOT NULL,
	[ExamId] [int] NOT NULL,
	[Text] [nvarchar](max) NOT NULL,
	[QuestionType] [tinyint] NOT NULL,
	[Points] [int] NOT NULL,
	[SortOrder] [int] NOT NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_Question] PRIMARY KEY CLUSTERED 
(
	[QuestionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Question]') AND name = N'IX_FK_Question_Exam')
CREATE NONCLUSTERED INDEX [IX_FK_Question_Exam] ON [dbo].[Question]
(
	[ExamId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[QuestionMedia]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[QuestionMedia](
	[MediaId] [int] IDENTITY(1,1) NOT NULL,
	[QuestionId] [int] NOT NULL,
	[MediaType] [tinyint] NOT NULL,
	[MediaPath] [nvarchar](max) NOT NULL,
	[SortOrder] [int] NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
 CONSTRAINT [PK_QuestionMedia] PRIMARY KEY CLUSTERED 
(
	[MediaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[QuestionMedia]') AND name = N'IX_FK_QuestionMedia_Question')
CREATE NONCLUSTERED INDEX [IX_FK_QuestionMedia_Question] ON [dbo].[QuestionMedia]
(
	[QuestionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[QuestionOption]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[QuestionOption](
	[OptionId] [int] IDENTITY(1,1) NOT NULL,
	[QuestionId] [int] NOT NULL,
	[Text] [nvarchar](max) NOT NULL,
	[IsCorrect] [bit] NOT NULL,
	[SortOrder] [int] NOT NULL,
 CONSTRAINT [PK_QuestionOption] PRIMARY KEY CLUSTERED 
(
	[OptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[QuestionOption]') AND name = N'IX_FK_QuestionOption_Question')
CREATE NONCLUSTERED INDEX [IX_FK_QuestionOption_Question] ON [dbo].[QuestionOption]
(
	[QuestionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SorguCevaplari]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SorguCevaplari](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[AnahtarKelimeler] [nvarchar](200) NOT NULL,
	[Cevap] [nvarchar](max) NOT NULL,
	[Kategori] [nvarchar](100) NULL,
	[Aktif] [bit] NULL,
	[OlusturmaTarihi] [datetime] NULL,
	[ResimUrl] [nvarchar](max) NULL,
 CONSTRAINT [PK_SorguCevaplari] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SorguLoglari]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SorguLoglari](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Soru] [nvarchar](500) NOT NULL,
	[Cevap] [nvarchar](1000) NULL,
	[KullaniciAdi] [nvarchar](100) NULL,
	[IpAdresi] [nvarchar](50) NULL,
	[Tarih] [datetime] NULL,
	[BasariDurumu] [bit] NULL,
 CONSTRAINT [PK_SorguLoglari] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TahditFormLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[TahditFormLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
	[TahditCode] [nvarchar](50) NULL,
	[IdariTahditCode] [nvarchar](50) NULL,
	[PenaltyDay] [int] NOT NULL,
	[PenaltyMonth] [int] NOT NULL,
	[PenaltyTotalDay] [int] NOT NULL,
	[PaymentType] [nvarchar](20) NULL,
	[VisaType] [int] NOT NULL,
	[Country] [nvarchar](150) NULL,
	[Border] [nvarchar](150) NULL,
	[UserId] [int] NULL,
	[UserSicil] [nvarchar](50) NULL,
	[UserDisplayName] [nvarchar](200) NULL,
	[PassengerName] [nvarchar](200) NULL,
	[PassportNo] [nvarchar](80) NULL,
	[FormMoney] [nvarchar](80) NULL,
 CONSTRAINT [PK_TahditFormLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
SET ANSI_PADDING ON

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[TahditFormLog]') AND name = N'IX_TahditFormLog_BorderCreatedAt')
CREATE NONCLUSTERED INDEX [IX_TahditFormLog_BorderCreatedAt] ON [dbo].[TahditFormLog]
(
	[Border] ASC,
	[CreatedAt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[TahditFormLog]') AND name = N'IX_TahditFormLog_CodeCreatedAt')
CREATE NONCLUSTERED INDEX [IX_TahditFormLog_CodeCreatedAt] ON [dbo].[TahditFormLog]
(
	[TahditCode] ASC,
	[CreatedAt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[TahditFormLog]') AND name = N'IX_TahditFormLog_CreatedAt')
CREATE NONCLUSTERED INDEX [IX_TahditFormLog_CreatedAt] ON [dbo].[TahditFormLog]
(
	[CreatedAt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[TahditFormLog]') AND name = N'IX_TahditFormLog_UserCreatedAt')
CREATE NONCLUSTERED INDEX [IX_TahditFormLog_UserCreatedAt] ON [dbo].[TahditFormLog]
(
	[UserId] ASC,
	[UserSicil] ASC,
	[CreatedAt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TahditFormLog_PenaltyDay]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TahditFormLog] ADD  CONSTRAINT [DF_TahditFormLog_PenaltyDay]  DEFAULT ((0)) FOR [PenaltyDay]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TahditFormLog_PenaltyMonth]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TahditFormLog] ADD  CONSTRAINT [DF_TahditFormLog_PenaltyMonth]  DEFAULT ((0)) FOR [PenaltyMonth]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TahditFormLog_PenaltyTotalDay]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TahditFormLog] ADD  CONSTRAINT [DF_TahditFormLog_PenaltyTotalDay]  DEFAULT ((0)) FOR [PenaltyTotalDay]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TahditFormLog_VisaType]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TahditFormLog] ADD  CONSTRAINT [DF_TahditFormLog_VisaType]  DEFAULT ((0)) FOR [VisaType]
END

GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TahditKod]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[TahditKod](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Kod] [nvarchar](max) NOT NULL,
	[Aciklama] [nvarchar](max) NOT NULL,
	[SureAy] [int] NULL,
	[Aktif] [bit] NOT NULL,
	[GirisGelirse] [nvarchar](max) NULL,
	[CikisGelirse] [nvarchar](max) NULL,
	[TahditMedia] [nvarchar](max) NULL,
	[CreatedAt] [datetime] NULL,
	[CreatedByUserId] [int] NULL,
	[CreatedBySicil] [nvarchar](50) NULL,
	[CreatedByName] [nvarchar](200) NULL,
 CONSTRAINT [PK_TahditKod] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbl_TempUser]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbl_TempUser](
	[fldId] [int] IDENTITY(1,1) NOT NULL,
	[fldSicil] [nvarchar](max) NULL,
	[fldName] [nvarchar](max) NULL,
	[fldLastName] [nvarchar](max) NULL,
	[fldPhone] [nvarchar](max) NULL,
	[fldEmail] [nvarchar](max) NULL,
	[fldTitle] [nvarchar](max) NULL,
	[fldDeputy] [nvarchar](max) NULL,
 CONSTRAINT [PK_tbl_TempUser] PRIMARY KEY CLUSTERED 
(
	[fldId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

-- ==========================================================================
-- YABANCI ANAHTARLAR (FOREIGN KEYS)
-- ==========================================================================

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Answer_ExamResult]') AND parent_object_id = OBJECT_ID(N'[dbo].[Answer]'))
ALTER TABLE [dbo].[Answer]  WITH CHECK ADD  CONSTRAINT [FK_Answer_ExamResult] FOREIGN KEY([ExamResultId])
REFERENCES [dbo].[ExamResult] ([ExamResultId])
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Answer_ExamResult]') AND parent_object_id = OBJECT_ID(N'[dbo].[Answer]'))
ALTER TABLE [dbo].[Answer] CHECK CONSTRAINT [FK_Answer_ExamResult]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Answer_Option]') AND parent_object_id = OBJECT_ID(N'[dbo].[Answer]'))
ALTER TABLE [dbo].[Answer]  WITH CHECK ADD  CONSTRAINT [FK_Answer_Option] FOREIGN KEY([OptionId])
REFERENCES [dbo].[QuestionOption] ([OptionId])
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Answer_Option]') AND parent_object_id = OBJECT_ID(N'[dbo].[Answer]'))
ALTER TABLE [dbo].[Answer] CHECK CONSTRAINT [FK_Answer_Option]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Answer_Question]') AND parent_object_id = OBJECT_ID(N'[dbo].[Answer]'))
ALTER TABLE [dbo].[Answer]  WITH CHECK ADD  CONSTRAINT [FK_Answer_Question] FOREIGN KEY([QuestionId])
REFERENCES [dbo].[Question] ([QuestionId])
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Answer_Question]') AND parent_object_id = OBJECT_ID(N'[dbo].[Answer]'))
ALTER TABLE [dbo].[Answer] CHECK CONSTRAINT [FK_Answer_Question]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Certificate_Course]') AND parent_object_id = OBJECT_ID(N'[dbo].[Certificate]'))
ALTER TABLE [dbo].[Certificate]  WITH CHECK ADD  CONSTRAINT [FK_Certificate_Course] FOREIGN KEY([CourseId])
REFERENCES [dbo].[Courses] ([CourseId])
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Certificate_Course]') AND parent_object_id = OBJECT_ID(N'[dbo].[Certificate]'))
ALTER TABLE [dbo].[Certificate] CHECK CONSTRAINT [FK_Certificate_Course]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Certificate_ExamResult]') AND parent_object_id = OBJECT_ID(N'[dbo].[Certificate]'))
ALTER TABLE [dbo].[Certificate]  WITH CHECK ADD  CONSTRAINT [FK_Certificate_ExamResult] FOREIGN KEY([ExamResultId])
REFERENCES [dbo].[ExamResult] ([ExamResultId])
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Certificate_ExamResult]') AND parent_object_id = OBJECT_ID(N'[dbo].[Certificate]'))
ALTER TABLE [dbo].[Certificate] CHECK CONSTRAINT [FK_Certificate_ExamResult]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Certificate_User]') AND parent_object_id = OBJECT_ID(N'[dbo].[Certificate]'))
ALTER TABLE [dbo].[Certificate]  WITH CHECK ADD  CONSTRAINT [FK_Certificate_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[E_User] ([fldId])
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Certificate_User]') AND parent_object_id = OBJECT_ID(N'[dbo].[Certificate]'))
ALTER TABLE [dbo].[Certificate] CHECK CONSTRAINT [FK_Certificate_User]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CourseContents_Course]') AND parent_object_id = OBJECT_ID(N'[dbo].[CourseContents]'))
ALTER TABLE [dbo].[CourseContents]  WITH CHECK ADD  CONSTRAINT [FK_CourseContents_Course] FOREIGN KEY([CourseId])
REFERENCES [dbo].[Courses] ([CourseId])
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CourseContents_Course]') AND parent_object_id = OBJECT_ID(N'[dbo].[CourseContents]'))
ALTER TABLE [dbo].[CourseContents] CHECK CONSTRAINT [FK_CourseContents_Course]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CourseEnrollments_Course]') AND parent_object_id = OBJECT_ID(N'[dbo].[CourseEnrollments]'))
ALTER TABLE [dbo].[CourseEnrollments]  WITH CHECK ADD  CONSTRAINT [FK_CourseEnrollments_Course] FOREIGN KEY([CourseId])
REFERENCES [dbo].[Courses] ([CourseId])
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CourseEnrollments_Course]') AND parent_object_id = OBJECT_ID(N'[dbo].[CourseEnrollments]'))
ALTER TABLE [dbo].[CourseEnrollments] CHECK CONSTRAINT [FK_CourseEnrollments_Course]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CourseEnrollments_User]') AND parent_object_id = OBJECT_ID(N'[dbo].[CourseEnrollments]'))
ALTER TABLE [dbo].[CourseEnrollments]  WITH CHECK ADD  CONSTRAINT [FK_CourseEnrollments_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[E_User] ([fldId])
ON DELETE CASCADE
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CourseEnrollments_User]') AND parent_object_id = OBJECT_ID(N'[dbo].[CourseEnrollments]'))
ALTER TABLE [dbo].[CourseEnrollments] CHECK CONSTRAINT [FK_CourseEnrollments_User]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CourseReviews_ApprovedBy]') AND parent_object_id = OBJECT_ID(N'[dbo].[CourseReviews]'))
ALTER TABLE [dbo].[CourseReviews]  WITH CHECK ADD  CONSTRAINT [FK_CourseReviews_ApprovedBy] FOREIGN KEY([ApprovedBy])
REFERENCES [dbo].[E_User] ([fldId])
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CourseReviews_ApprovedBy]') AND parent_object_id = OBJECT_ID(N'[dbo].[CourseReviews]'))
ALTER TABLE [dbo].[CourseReviews] CHECK CONSTRAINT [FK_CourseReviews_ApprovedBy]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CourseReviews_Course]') AND parent_object_id = OBJECT_ID(N'[dbo].[CourseReviews]'))
ALTER TABLE [dbo].[CourseReviews]  WITH CHECK ADD  CONSTRAINT [FK_CourseReviews_Course] FOREIGN KEY([CourseId])
REFERENCES [dbo].[Courses] ([CourseId])
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CourseReviews_Course]') AND parent_object_id = OBJECT_ID(N'[dbo].[CourseReviews]'))
ALTER TABLE [dbo].[CourseReviews] CHECK CONSTRAINT [FK_CourseReviews_Course]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CourseReviews_User]') AND parent_object_id = OBJECT_ID(N'[dbo].[CourseReviews]'))
ALTER TABLE [dbo].[CourseReviews]  WITH CHECK ADD  CONSTRAINT [FK_CourseReviews_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[E_User] ([fldId])
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CourseReviews_User]') AND parent_object_id = OBJECT_ID(N'[dbo].[CourseReviews]'))
ALTER TABLE [dbo].[CourseReviews] CHECK CONSTRAINT [FK_CourseReviews_User]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Courses_Category]') AND parent_object_id = OBJECT_ID(N'[dbo].[Courses]'))
ALTER TABLE [dbo].[Courses]  WITH CHECK ADD  CONSTRAINT [FK_Courses_Category] FOREIGN KEY([CategoryId])
REFERENCES [dbo].[Categories] ([CategoryId])
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Courses_Category]') AND parent_object_id = OBJECT_ID(N'[dbo].[Courses]'))
ALTER TABLE [dbo].[Courses] CHECK CONSTRAINT [FK_Courses_Category]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Courses_CreatedBy]') AND parent_object_id = OBJECT_ID(N'[dbo].[Courses]'))
ALTER TABLE [dbo].[Courses]  WITH CHECK ADD  CONSTRAINT [FK_Courses_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[E_User] ([fldId])
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Courses_CreatedBy]') AND parent_object_id = OBJECT_ID(N'[dbo].[Courses]'))
ALTER TABLE [dbo].[Courses] CHECK CONSTRAINT [FK_Courses_CreatedBy]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_E_Messages_ApprovedBy]') AND parent_object_id = OBJECT_ID(N'[dbo].[E_Messages]'))
ALTER TABLE [dbo].[E_Messages]  WITH CHECK ADD  CONSTRAINT [FK_E_Messages_ApprovedBy] FOREIGN KEY([fldApprovedBy])
REFERENCES [dbo].[E_User] ([fldId])
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_E_Messages_ApprovedBy]') AND parent_object_id = OBJECT_ID(N'[dbo].[E_Messages]'))
ALTER TABLE [dbo].[E_Messages] CHECK CONSTRAINT [FK_E_Messages_ApprovedBy]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_E_Messages_Parent]') AND parent_object_id = OBJECT_ID(N'[dbo].[E_Messages]'))
ALTER TABLE [dbo].[E_Messages]  WITH CHECK ADD  CONSTRAINT [FK_E_Messages_Parent] FOREIGN KEY([fldParentMessageId])
REFERENCES [dbo].[E_Messages] ([fldId])
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_E_Messages_Parent]') AND parent_object_id = OBJECT_ID(N'[dbo].[E_Messages]'))
ALTER TABLE [dbo].[E_Messages] CHECK CONSTRAINT [FK_E_Messages_Parent]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_E_Messages_Recipient]') AND parent_object_id = OBJECT_ID(N'[dbo].[E_Messages]'))
ALTER TABLE [dbo].[E_Messages]  WITH CHECK ADD  CONSTRAINT [FK_E_Messages_Recipient] FOREIGN KEY([fldRecipientId])
REFERENCES [dbo].[E_User] ([fldId])
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_E_Messages_Recipient]') AND parent_object_id = OBJECT_ID(N'[dbo].[E_Messages]'))
ALTER TABLE [dbo].[E_Messages] CHECK CONSTRAINT [FK_E_Messages_Recipient]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_E_Messages_Sender]') AND parent_object_id = OBJECT_ID(N'[dbo].[E_Messages]'))
ALTER TABLE [dbo].[E_Messages]  WITH CHECK ADD  CONSTRAINT [FK_E_Messages_Sender] FOREIGN KEY([fldSenderId])
REFERENCES [dbo].[E_User] ([fldId])
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_E_Messages_Sender]') AND parent_object_id = OBJECT_ID(N'[dbo].[E_Messages]'))
ALTER TABLE [dbo].[E_Messages] CHECK CONSTRAINT [FK_E_Messages_Sender]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ExamResult_Exam]') AND parent_object_id = OBJECT_ID(N'[dbo].[ExamResult]'))
ALTER TABLE [dbo].[ExamResult]  WITH CHECK ADD  CONSTRAINT [FK_ExamResult_Exam] FOREIGN KEY([ExamId])
REFERENCES [dbo].[Exam] ([ExamId])
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ExamResult_Exam]') AND parent_object_id = OBJECT_ID(N'[dbo].[ExamResult]'))
ALTER TABLE [dbo].[ExamResult] CHECK CONSTRAINT [FK_ExamResult_Exam]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Question_Exam]') AND parent_object_id = OBJECT_ID(N'[dbo].[Question]'))
ALTER TABLE [dbo].[Question]  WITH CHECK ADD  CONSTRAINT [FK_Question_Exam] FOREIGN KEY([ExamId])
REFERENCES [dbo].[Exam] ([ExamId])
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Question_Exam]') AND parent_object_id = OBJECT_ID(N'[dbo].[Question]'))
ALTER TABLE [dbo].[Question] CHECK CONSTRAINT [FK_Question_Exam]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_QuestionMedia_Question]') AND parent_object_id = OBJECT_ID(N'[dbo].[QuestionMedia]'))
ALTER TABLE [dbo].[QuestionMedia]  WITH CHECK ADD  CONSTRAINT [FK_QuestionMedia_Question] FOREIGN KEY([QuestionId])
REFERENCES [dbo].[Question] ([QuestionId])
ON DELETE CASCADE
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_QuestionMedia_Question]') AND parent_object_id = OBJECT_ID(N'[dbo].[QuestionMedia]'))
ALTER TABLE [dbo].[QuestionMedia] CHECK CONSTRAINT [FK_QuestionMedia_Question]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_QuestionOption_Question]') AND parent_object_id = OBJECT_ID(N'[dbo].[QuestionOption]'))
ALTER TABLE [dbo].[QuestionOption]  WITH CHECK ADD  CONSTRAINT [FK_QuestionOption_Question] FOREIGN KEY([QuestionId])
REFERENCES [dbo].[Question] ([QuestionId])
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_QuestionOption_Question]') AND parent_object_id = OBJECT_ID(N'[dbo].[QuestionOption]'))
ALTER TABLE [dbo].[QuestionOption] CHECK CONSTRAINT [FK_QuestionOption_Question]
GO

