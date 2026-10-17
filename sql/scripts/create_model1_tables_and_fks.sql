-- Hedef veritabanýný ayarlayýn
USE [YourDatabase]; 
GO

-- __MigrationHistory
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[__MigrationHistory]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[__MigrationHistory](
    [MigrationId] nvarchar(255) NOT NULL PRIMARY KEY,
    [Model] varbinary(max) NOT NULL,
    [ProductVersion] nvarchar(32) NOT NULL
);
END
GO

-- Airline
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Airline]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[Airline](
    [Id] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [IATACode] nvarchar(7) NOT NULL,
    [Name] nvarchar(150) NOT NULL,
    [Country] nvarchar(100) NULL,
    [IsActive] bit NOT NULL,
    [IsUserDefined] bit NULL,
    [CreatedDate] datetime NULL
);
END
GO

-- Answer
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Answer]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[Answer](
    [AnswerId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ExamResultId] int NOT NULL,
    [QuestionId] int NOT NULL,
    [OptionId] int NULL,
    [TextAnswer] nvarchar(max) NULL
);
END
GO

-- Categories
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Categories]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[Categories](
    [CategoryId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [CategoryName] nvarchar(200) NOT NULL,
    [Description] nvarchar(max) NULL,
    [IsActive] bit NOT NULL
);
END
GO

-- Certificate
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Certificate]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[Certificate](
    [CertificateId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [UserId] int NOT NULL,
    [CourseId] int NOT NULL,
    [ExamResultId] int NULL,
    [CertificateNumber] nvarchar(50) NOT NULL,
    [FilePath] nvarchar(500) NULL,
    [IssuedDate] datetime NOT NULL,
    [Score] int NOT NULL,
    [IsActive] bit NOT NULL,
    [CreatedAt] datetime NOT NULL
);
END
GO

-- CourseContents
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CourseContents]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[CourseContents](
    [ContentId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [CourseId] int NOT NULL,
    [ContentType] nvarchar(20) NOT NULL,
    [ContentTitle] nvarchar(200) NULL,
    [FilePath] nvarchar(500) NOT NULL,
    [CreatedDate] datetime NULL,
    [ContentDescription] nvarchar(max) NULL
);
END
GO

-- CourseEnrollments
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CourseEnrollments]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[CourseEnrollments](
    [EnrollmentId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [CourseId] int NOT NULL,
    [UserId] int NOT NULL,
    [EnrollmentDate] datetime NULL,
    [IsDrawEntry] bit NOT NULL,
    [DrawEntryDate] datetime NULL
);
END
GO

-- CourseReviews
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CourseReviews]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[CourseReviews](
    [ReviewId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [CourseId] int NOT NULL,
    [UserId] int NOT NULL,
    [Rating] tinyint NOT NULL,
    [Comment] nvarchar(max) NULL,
    [CreatedDate] datetime NOT NULL,
    [IsApproved] bit NOT NULL,
    [ApprovedBy] int NULL,
    [ApprovedDate] datetime NULL
);
END
GO

-- Courses
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Courses]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[Courses](
    [CourseId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [CourseTitle] nvarchar(200) NOT NULL,
    [CourseDescription] nvarchar(max) NULL,
    [CoverImage] nvarchar(max) NULL,
    [CreatedBy] int NOT NULL,
    [CreatedDate] datetime NULL,
    [CategoryId] int NOT NULL,
    [ResourceFile] nvarchar(max) NULL,
    [IsActive] bit NOT NULL,
    [IsDeleted] bit NULL
);
END
GO

-- DocumentTerms
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DocumentTerms]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[DocumentTerms](
    [Id] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Term] nvarchar(200) NOT NULL,
    [Slug] nvarchar(250) NOT NULL,
    [Category] nvarchar(100) NOT NULL,
    [Definition] nvarchar(max) NOT NULL,
    [DetailedDescription] nvarchar(max) NULL,
    [ImageUrl] nvarchar(500) NULL,
    [RelatedTerms] nvarchar(500) NULL,
    [IsActive] bit NOT NULL,
    [CreatedAt] datetime NULL,
    [UpdatedAt] datetime NULL,
    [Sicil] nvarchar(50) NULL,
    [AdSoyad] nvarchar(200) NULL
);
END
GO

-- E_Announce
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_Announce]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[E_Announce](
    [fldId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [fldPdateTime] datetime NULL,
    [fldType] int NULL,
    [fldTopic] nvarchar(max) NULL,
    [fldAnons] nvarchar(max) NULL,
    [fldPublishBy] nvarchar(max) NULL,
    [fldReadBy] nvarchar(max) NULL
);
END
GO

-- E_AUH
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_AUH]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[E_AUH](
    [fldId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [fldCountry] nvarchar(max) NULL,
    [fldFirstMounth] nvarchar(max) NULL,
    [fldKat] nvarchar(max) NULL,
    [fldDayStart] nvarchar(max) NULL,
    [fldDayKat] nvarchar(max) NULL,
    [fldToM] nvarchar(max) NULL
);
END
GO

-- E_Border
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_Border]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[E_Border](
    [fldId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [fldName] nvarchar(max) NULL
);
END
GO

-- E_Defter
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_Defter]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[E_Defter](
    [fldId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [fldPrice] nvarchar(25) NULL,
    [fldTypeofMoney] nvarchar(50) NULL
);
END
GO

-- E_Exchange
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_Exchange]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[E_Exchange](
    [fldId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [fldEuro] nvarchar(50) NULL,
    [fldDollar] nvarchar(50) NULL,
    [fldPaund] nvarchar(50) NULL
);
END
GO

-- E_Forms
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_Forms]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[E_Forms](
    [fldId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [fldGB] nvarchar(max) NULL,
    [fldDE] nvarchar(max) NULL,
    [fldRU] nvarchar(max) NULL,
    [fldIR] nvarchar(max) NULL,
    [fldGBC] nvarchar(max) NULL,
    [fldDEC] nvarchar(max) NULL,
    [fldRUC] nvarchar(max) NULL,
    [fldIRC] nvarchar(max) NULL,
    [fldIRKC] nvarchar(max) NULL,
    [fldIRK] nvarchar(max) NULL,
    [fldFransizca] nvarchar(max) NULL,
    [fldFransizcaC] nvarchar(max) NULL
);
END
GO

-- E_History
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_History]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[E_History](
    [fldId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [fldStart] datetime NULL,
    [fldShouldExit] datetime NULL,
    [fldBirthDate] datetime NULL,
    [fldCountry] nvarchar(max) NULL,
    [fldPenalty] nvarchar(max) NULL,
    [fldPMoney] nvarchar(max) NULL,
    [fldUser] nvarchar(max) NULL,
    [fldBorder] nvarchar(max) NULL,
    [fldDatetime] datetime NULL
);
END
GO

-- E_Inad
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_Inad]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[E_Inad](
    [InadId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [TarihSaat] datetime NULL,
    [AdSoyad] nchar(50) NULL,
    [DogumT] date NULL,
    [DogumY] nvarchar(50) NULL,
    [Cinsiyet] nvarchar(10) NULL,
    [Uyruk] nchar(250) NULL,
    [PasaportNo] nchar(20) NULL,
    [BelgeNo] nvarchar(20) NULL,
    [PasaportTuru] nchar(50) NULL,
    [Beyan] nvarchar(100) NULL,
    [GelenUcusNo] nvarchar(10) NULL,
    [GelenHavayolu] nvarchar(150) NULL,
    [GeldigiYer] nchar(250) NULL,
    [GeldigiTarihSaat] datetime NULL,
    [InadSebep] nvarchar(max) NULL,
    [GidenHavayolu] nvarchar(150) NULL,
    [GidisUcusNo] nvarchar(10) NULL,
    [GidisYer] nchar(250) NULL,
    [GidisTarihSaat] datetime NULL,
    [Personel] nvarchar(max) NULL,
    [UstAramaEsya] nvarchar(max) NULL,
    [UcagaNakil] nvarchar(max) NULL,
    [OzelGuvenlik] nvarchar(50) NULL,
    [YerHizmetleriPersonel] nvarchar(50) NULL,
    [YerHizmetleri] nchar(250) NULL,
    [Refakat] nvarchar(250) NULL,
    [Kapi] nvarchar(max) NULL,
    [Valilik] nvarchar(max) NULL,
    [Durum] nvarchar(max) NULL,
    [Sicil] nchar(6) NULL
);
END
GO

-- E_IsK
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_IsK]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[E_IsK](
    [fldId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [fldDatetime] datetime NULL,
    [fldName] nvarchar(max) NULL,
    [fldPassport] nvarchar(max) NULL,
    [fldIdn] nvarchar(max) NULL,
    [fldOrgin] nvarchar(max) NULL,
    [fldBirthdate] date NULL,
    [fldForm] nvarchar(max) NULL,
    [fldPassControl] nvarchar(max) NULL,
    [fldApproval] nvarchar(max) NULL,
    [fldBorder] nvarchar(max) NULL,
    [fldVisa] nvarchar(max) NULL,
    [fldPMoney] nvarchar(max) NULL,
    [fldPicture] nvarchar(max) NULL
);
END
GO

-- E_Messages
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_Messages]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[E_Messages](
    [fldId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [fldSendByName] nvarchar(max) NULL,
    [fldSendBySicil] nvarchar(max) NULL,
    [fldSendByPhone] nvarchar(max) NULL,
    [fldSendByMail] nvarchar(max) NULL,
    [fldDateTime] datetime NULL,
    [fldMessage] nvarchar(max) NULL
);
END
GO

-- E_Sartli
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_Sartli]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[E_Sartli](
    [fldId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [fldBy] varchar(150) NULL,
    [fldOrgin] nvarchar(50) NULL,
    [fldBdate] date NULL,
    [fldDate] datetime NULL,
    [fldName] nvarchar(250) NULL,
    [fldBorder] nvarchar(500) NULL
);
END
GO

-- E_TGVH
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_TGVH]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[E_TGVH](
    [fldId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [fldPrice] nvarchar(25) NULL,
    [fldTypeofMoney] nvarchar(25) NULL,
    [fldYear] nvarchar(25) NULL
);
END
GO

-- E_TKOD
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_TKOD]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[E_TKOD](
    [fldId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [fldCode] nvarchar(50) NULL,
    [fldPTime] nvarchar(50) NULL,
    [fldStart] int NULL,
    [fldFinish] int NULL,
    [fldIdariCode] nvarchar(50) NULL,
    [fldPaid] tinyint NULL
);
END
GO

-- E_Token
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_Token]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[E_Token](
    [fldId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [fldUserId] int NULL,
    [fldToken] nvarchar(max) NULL,
    [fldDateTime] datetime NULL,
    [fldIp] nvarchar(50) NULL
);
END
GO

-- E_User
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_User]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[E_User](
    [fldId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [fldSicil] nvarchar(max) NULL,
    [fldName] nvarchar(max) NULL,
    [fldLastName] nvarchar(max) NULL,
    [fldPhone] nvarchar(max) NULL,
    [fldEmail] nvarchar(max) NULL,
    [fldTitle] nvarchar(max) NULL,
    [fldDeputy] nvarchar(max) NULL,
    [fldPicture] nvarchar(max) NULL,
    [fldAuth] nvarchar(max) NULL,
    [fldSubAuth] nvarchar(max) NULL,
    [fldPassword] nvarchar(255) NOT NULL,
    [fldDateTime] datetime NULL,
    [fldBorder] nvarchar(max) NULL,
    [fldActive] nvarchar(1) NULL,
    [Role] nvarchar(20) NOT NULL,
    [LastLogin] datetime NULL,
    [XP] int NOT NULL,
    [Level] int NOT NULL,
    [IsActive] bit NULL,
    [TeacherRequestStatus] tinyint NULL,
    [TeacherRequestDate] datetime NULL
);
END
GO

-- E_UVR
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[E_UVR]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[E_UVR](
    [fldId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [fldCountry] nvarchar(max) NULL,
    [fldCalculateType] int NULL,
    [fldPassportType] int NULL,
    [fldVisaStatus] int NULL,
    [fldDay] int NULL,
    [fldLong] int NULL,
    [fldOneTime] int NULL,
    [fldHB] tinyint NULL
);
END
GO

-- Exam
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Exam]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[Exam](
    [ExamId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [CourseId] int NOT NULL,
    [Title] nvarchar(200) NOT NULL,
    [Description] nvarchar(max) NULL,
    [DurationMinutes] int NULL,
    [PassingScore] int NULL,
    [IsActive] bit NOT NULL,
    [CreatedAt] datetime NOT NULL,
    [IsArchived] bit NULL
);
END
GO

-- ExamResult
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ExamResult]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[ExamResult](
    [ExamResultId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ExamId] int NOT NULL,
    [UserId] int NULL,
    [Score] decimal(5,2) NULL,
    [StartedAt] datetime NULL,
    [FinishedAt] datetime NULL,
    [Status] tinyint NOT NULL
);
END
GO

-- Question
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Question]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[Question](
    [QuestionId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ExamId] int NOT NULL,
    [Text] nvarchar(max) NOT NULL,
    [QuestionType] tinyint NOT NULL,
    [Points] int NOT NULL,
    [SortOrder] int NOT NULL
);
END
GO

-- QuestionMedia
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[QuestionMedia]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[QuestionMedia](
    [MediaId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [QuestionId] int NOT NULL,
    [MediaType] tinyint NOT NULL,
    [MediaPath] nvarchar(max) NOT NULL,
    [SortOrder] int NOT NULL,
    [CreatedAt] datetime NOT NULL
);
END
GO

-- QuestionOption
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[QuestionOption]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[QuestionOption](
    [OptionId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [QuestionId] int NOT NULL,
    [Text] nvarchar(max) NOT NULL,
    [IsCorrect] bit NOT NULL,
    [SortOrder] int NOT NULL
);
END
GO

-- SorguCevaplari
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SorguCevaplari]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[SorguCevaplari](
    [Id] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [AnahtarKelimeler] nvarchar(200) NOT NULL,
    [Cevap] nvarchar(max) NOT NULL,
    [Kategori] nvarchar(100) NULL,
    [Aktif] bit NULL,
    [OlusturmaTarihi] datetime NULL,
    [ResimUrl] nvarchar(max) NULL
);
END
GO

-- SorguLoglari
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SorguLoglari]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[SorguLoglari](
    [Id] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Soru] nvarchar(500) NOT NULL,
    [Cevap] nvarchar(1000) NULL,
    [KullaniciAdi] nvarchar(100) NULL,
    [IpAdresi] nvarchar(50) NULL,
    [Tarih] datetime NULL,
    [BasariDurumu] bit NULL
);
END
GO

-- TahditGrubu
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TahditGrubu]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[TahditGrubu](
    [Id] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Kod] nvarchar(5) NOT NULL,
    [Baslik] nvarchar(100) NOT NULL,
    [Aciklama] nvarchar(500) NULL,
    [Aktif] bit NOT NULL
);
END
GO

-- TahditKod
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TahditKod]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[TahditKod](
    [Id] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [TahditGrubuId] int NOT NULL,
    [Kod] nvarchar(20) NOT NULL,
    [Aciklama] nvarchar(500) NOT NULL,
    [SureAy] int NULL,
    [Aktif] bit NOT NULL,
    [GirisGelirse] nvarchar(max) NULL,
    [CikisGelirse] nvarchar(max) NULL
);
END
GO

-- tbl_TempUser
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbl_TempUser]') AND type = N'U')
BEGIN
CREATE TABLE [dbo].[tbl_TempUser](
    [fldId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [fldSicil] nvarchar(max) NULL,
    [fldName] nvarchar(max) NULL,
    [fldLastName] nvarchar(max) NULL,
    [fldPhone] nvarchar(max) NULL,
    [fldEmail] nvarchar(max) NULL,
    [fldTitle] nvarchar(max) NULL,
    [fldDeputy] nvarchar(max) NULL
);
END
GO

-- --------- Foreign Keys (ekleme: parent tablolar hazýrlanmýþ olmalý) ----------
-- Utility: add FK if not exists
-- FK_Answer_ExamResult
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Answer_ExamResult')
BEGIN
ALTER TABLE [dbo].[Answer] WITH CHECK ADD CONSTRAINT [FK_Answer_ExamResult] FOREIGN KEY([ExamResultId])
REFERENCES [dbo].[ExamResult]([ExamResultId]);
END
GO

-- FK_Answer_Option
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Answer_Option')
BEGIN
ALTER TABLE [dbo].[Answer] WITH CHECK ADD CONSTRAINT [FK_Answer_Option] FOREIGN KEY([OptionId])
REFERENCES [dbo].[QuestionOption]([OptionId]);
END
GO

-- FK_Answer_Question
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Answer_Question')
BEGIN
ALTER TABLE [dbo].[Answer] WITH CHECK ADD CONSTRAINT [FK_Answer_Question] FOREIGN KEY([QuestionId])
REFERENCES [dbo].[Question]([QuestionId]);
END
GO

-- FK_Certificate_Course
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Certificate_Course')
BEGIN
ALTER TABLE [dbo].[Certificate] WITH CHECK ADD CONSTRAINT [FK_Certificate_Course] FOREIGN KEY([CourseId])
REFERENCES [dbo].[Courses]([CourseId]);
END
GO

-- FK_Certificate_ExamResult
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Certificate_ExamResult')
BEGIN
ALTER TABLE [dbo].[Certificate] WITH CHECK ADD CONSTRAINT [FK_Certificate_ExamResult] FOREIGN KEY([ExamResultId])
REFERENCES [dbo].[ExamResult]([ExamResultId]);
END
GO

-- FK_Certificate_User
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Certificate_User')
BEGIN
ALTER TABLE [dbo].[Certificate] WITH CHECK ADD CONSTRAINT [FK_Certificate_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[E_User]([fldId]);
END
GO

-- FK_CourseContents_Course
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_CourseContents_Course')
BEGIN
ALTER TABLE [dbo].[CourseContents] WITH CHECK ADD CONSTRAINT [FK_CourseContents_Course] FOREIGN KEY([CourseId])
REFERENCES [dbo].[Courses]([CourseId]);
END
GO

-- FK_CourseEnrollments_Course
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_CourseEnrollments_Course')
BEGIN
ALTER TABLE [dbo].[CourseEnrollments] WITH CHECK ADD CONSTRAINT [FK_CourseEnrollments_Course] FOREIGN KEY([CourseId])
REFERENCES [dbo].[Courses]([CourseId]);
END
GO

-- FK_CourseEnrollments_User (ON DELETE CASCADE)
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_CourseEnrollments_User')
BEGIN
ALTER TABLE [dbo].[CourseEnrollments] WITH CHECK ADD CONSTRAINT [FK_CourseEnrollments_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[E_User]([fldId]) ON DELETE CASCADE;
END
GO

-- FK_CourseReviews_ApprovedBy
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_CourseReviews_ApprovedBy')
BEGIN
ALTER TABLE [dbo].[CourseReviews] WITH CHECK ADD CONSTRAINT [FK_CourseReviews_ApprovedBy] FOREIGN KEY([ApprovedBy])
REFERENCES [dbo].[E_User]([fldId]);
END
GO

-- FK_CourseReviews_Course
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_CourseReviews_Course')
BEGIN
ALTER TABLE [dbo].[CourseReviews] WITH CHECK ADD CONSTRAINT [FK_CourseReviews_Course] FOREIGN KEY([CourseId])
REFERENCES [dbo].[Courses]([CourseId]);
END
GO

-- FK_CourseReviews_User
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_CourseReviews_User')
BEGIN
ALTER TABLE [dbo].[CourseReviews] WITH CHECK ADD CONSTRAINT [FK_CourseReviews_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[E_User]([fldId]);
END
GO

-- FK_Courses_Category
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Courses_Category')
BEGIN
ALTER TABLE [dbo].[Courses] WITH CHECK ADD CONSTRAINT [FK_Courses_Category] FOREIGN KEY([CategoryId])
REFERENCES [dbo].[Categories]([CategoryId]);
END
GO

-- FK_Courses_CreatedBy
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Courses_CreatedBy')
BEGIN
ALTER TABLE [dbo].[Courses] WITH CHECK ADD CONSTRAINT [FK_Courses_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[E_User]([fldId]);
END
GO

-- FK_ExamResult_Exam
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ExamResult_Exam')
BEGIN
ALTER TABLE [dbo].[ExamResult] WITH CHECK ADD CONSTRAINT [FK_ExamResult_Exam] FOREIGN KEY([ExamId])
REFERENCES [dbo].[Exam]([ExamId]);
END
GO

-- FK_Question_Exam
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Question_Exam')
BEGIN
ALTER TABLE [dbo].[Question] WITH CHECK ADD CONSTRAINT [FK_Question_Exam] FOREIGN KEY([ExamId])
REFERENCES [dbo].[Exam]([ExamId]);
END
GO

-- FK_QuestionMedia_Question (ON DELETE CASCADE)
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_QuestionMedia_Question')
BEGIN
ALTER TABLE [dbo].[QuestionMedia] WITH CHECK ADD CONSTRAINT [FK_QuestionMedia_Question] FOREIGN KEY([QuestionId])
REFERENCES [dbo].[Question]([QuestionId]) ON DELETE CASCADE;
END
GO

-- FK_QuestionOption_Question
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_QuestionOption_Question')
BEGIN
ALTER TABLE [dbo].[QuestionOption] WITH CHECK ADD CONSTRAINT [FK_QuestionOption_Question] FOREIGN KEY([QuestionId])
REFERENCES [dbo].[Question]([QuestionId]);
END
GO

-- FK_TahditKod_TahditGrubu (ON DELETE CASCADE)
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_TahditKod_TahditGrubu')
BEGIN
ALTER TABLE [dbo].[TahditKod] WITH CHECK ADD CONSTRAINT [FK_TahditKod_TahditGrubu] FOREIGN KEY([TahditGrubuId])
REFERENCES [dbo].[TahditGrubu]([Id]) ON DELETE CASCADE;
END
GO

-- FK_Answer_Option: Note OptionId nullable; ensure referenced table exists before relying on the FK.
-- (All FK eklemeleri tamamlandý)
PRINT 'Model1 tables and foreign keys creation script executed (checks performed).';
GO