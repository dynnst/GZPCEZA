-- CEZA SAFE SCHEMA SYNC - veri silmez
-- Eksik tablo/kolon/PK/FK/indeks ekler. Mevcut satırlara DELETE/UPDATE yapmaz.
-- Eksik kolonlar mevcut veriyi bozmamak için NULL eklenir. FK ilişkileri mevcut veri hatasından etkilenmesin diye WITH NOCHECK eklenir.
SET NOCOUNT ON;
GO
IF OBJECT_ID(N'dbo.__MigrationHistory', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[__MigrationHistory] (
        [MigrationId] nvarchar(255) NOT NULL,
        [Model] varbinary(MAX) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL
    );
END
GO
IF OBJECT_ID(N'dbo.__MigrationHistory', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.__MigrationHistory', N'MigrationId') IS NULL
BEGIN
    ALTER TABLE [dbo].[__MigrationHistory] ADD [MigrationId] nvarchar(255) NULL;
END
GO
IF OBJECT_ID(N'dbo.__MigrationHistory', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.__MigrationHistory', N'Model') IS NULL
BEGIN
    ALTER TABLE [dbo].[__MigrationHistory] ADD [Model] varbinary(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.__MigrationHistory', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.__MigrationHistory', N'ProductVersion') IS NULL
BEGIN
    ALTER TABLE [dbo].[__MigrationHistory] ADD [ProductVersion] nvarchar(32) NULL;
END
GO

IF OBJECT_ID(N'dbo.Airline', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Airline] (
        [Id] int IDENTITY(1,1) NOT NULL,
        [IATACode] nvarchar(7) NOT NULL,
        [Name] nvarchar(150) NOT NULL,
        [Country] nvarchar(100) NULL,
        [IsActive] bit NOT NULL,
        [IsUserDefined] bit NULL,
        [CreatedDate] datetime NULL
    );
END
GO
IF OBJECT_ID(N'dbo.Airline', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Airline', N'IATACode') IS NULL
BEGIN
    ALTER TABLE [dbo].[Airline] ADD [IATACode] nvarchar(7) NULL;
END
GO
IF OBJECT_ID(N'dbo.Airline', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Airline', N'Name') IS NULL
BEGIN
    ALTER TABLE [dbo].[Airline] ADD [Name] nvarchar(150) NULL;
END
GO
IF OBJECT_ID(N'dbo.Airline', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Airline', N'Country') IS NULL
BEGIN
    ALTER TABLE [dbo].[Airline] ADD [Country] nvarchar(100) NULL;
END
GO
IF OBJECT_ID(N'dbo.Airline', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Airline', N'IsActive') IS NULL
BEGIN
    ALTER TABLE [dbo].[Airline] ADD [IsActive] bit NULL;
END
GO
IF OBJECT_ID(N'dbo.Airline', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Airline', N'IsUserDefined') IS NULL
BEGIN
    ALTER TABLE [dbo].[Airline] ADD [IsUserDefined] bit NULL;
END
GO
IF OBJECT_ID(N'dbo.Airline', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Airline', N'CreatedDate') IS NULL
BEGIN
    ALTER TABLE [dbo].[Airline] ADD [CreatedDate] datetime NULL;
END
GO

IF OBJECT_ID(N'dbo.Answer', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Answer] (
        [AnswerId] int IDENTITY(1,1) NOT NULL,
        [ExamResultId] int NOT NULL,
        [QuestionId] int NOT NULL,
        [OptionId] int NULL,
        [TextAnswer] nvarchar(MAX) NULL
    );
END
GO
IF OBJECT_ID(N'dbo.Answer', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Answer', N'ExamResultId') IS NULL
BEGIN
    ALTER TABLE [dbo].[Answer] ADD [ExamResultId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.Answer', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Answer', N'QuestionId') IS NULL
BEGIN
    ALTER TABLE [dbo].[Answer] ADD [QuestionId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.Answer', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Answer', N'OptionId') IS NULL
BEGIN
    ALTER TABLE [dbo].[Answer] ADD [OptionId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.Answer', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Answer', N'TextAnswer') IS NULL
BEGIN
    ALTER TABLE [dbo].[Answer] ADD [TextAnswer] nvarchar(MAX) NULL;
END
GO

IF OBJECT_ID(N'dbo.Categories', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Categories] (
        [CategoryId] int IDENTITY(1,1) NOT NULL,
        [CategoryName] nvarchar(200) NOT NULL,
        [Description] nvarchar(MAX) NULL,
        [IsActive] bit NOT NULL
    );
END
GO
IF OBJECT_ID(N'dbo.Categories', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Categories', N'CategoryName') IS NULL
BEGIN
    ALTER TABLE [dbo].[Categories] ADD [CategoryName] nvarchar(200) NULL;
END
GO
IF OBJECT_ID(N'dbo.Categories', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Categories', N'Description') IS NULL
BEGIN
    ALTER TABLE [dbo].[Categories] ADD [Description] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.Categories', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Categories', N'IsActive') IS NULL
BEGIN
    ALTER TABLE [dbo].[Categories] ADD [IsActive] bit NULL;
END
GO

IF OBJECT_ID(N'dbo.Certificate', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Certificate] (
        [CertificateId] int IDENTITY(1,1) NOT NULL,
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
IF OBJECT_ID(N'dbo.Certificate', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Certificate', N'UserId') IS NULL
BEGIN
    ALTER TABLE [dbo].[Certificate] ADD [UserId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.Certificate', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Certificate', N'CourseId') IS NULL
BEGIN
    ALTER TABLE [dbo].[Certificate] ADD [CourseId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.Certificate', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Certificate', N'ExamResultId') IS NULL
BEGIN
    ALTER TABLE [dbo].[Certificate] ADD [ExamResultId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.Certificate', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Certificate', N'CertificateNumber') IS NULL
BEGIN
    ALTER TABLE [dbo].[Certificate] ADD [CertificateNumber] nvarchar(50) NULL;
END
GO
IF OBJECT_ID(N'dbo.Certificate', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Certificate', N'FilePath') IS NULL
BEGIN
    ALTER TABLE [dbo].[Certificate] ADD [FilePath] nvarchar(500) NULL;
END
GO
IF OBJECT_ID(N'dbo.Certificate', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Certificate', N'IssuedDate') IS NULL
BEGIN
    ALTER TABLE [dbo].[Certificate] ADD [IssuedDate] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.Certificate', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Certificate', N'Score') IS NULL
BEGIN
    ALTER TABLE [dbo].[Certificate] ADD [Score] int NULL;
END
GO
IF OBJECT_ID(N'dbo.Certificate', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Certificate', N'IsActive') IS NULL
BEGIN
    ALTER TABLE [dbo].[Certificate] ADD [IsActive] bit NULL;
END
GO
IF OBJECT_ID(N'dbo.Certificate', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Certificate', N'CreatedAt') IS NULL
BEGIN
    ALTER TABLE [dbo].[Certificate] ADD [CreatedAt] datetime NULL;
END
GO

IF OBJECT_ID(N'dbo.CertificateRequest', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[CertificateRequest] (
        [RequestId] int IDENTITY(1,1) NOT NULL,
        [UserId] int NOT NULL,
        [CourseId] int NOT NULL,
        [RequestDate] datetime NOT NULL,
        [Status] tinyint NOT NULL,
        [AdminNote] nvarchar(500) NULL,
        [ProcessedDate] datetime NULL,
        [ProcessedBy] int NULL
    );
END
GO
IF OBJECT_ID(N'dbo.CertificateRequest', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.CertificateRequest', N'UserId') IS NULL
BEGIN
    ALTER TABLE [dbo].[CertificateRequest] ADD [UserId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.CertificateRequest', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.CertificateRequest', N'CourseId') IS NULL
BEGIN
    ALTER TABLE [dbo].[CertificateRequest] ADD [CourseId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.CertificateRequest', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.CertificateRequest', N'RequestDate') IS NULL
BEGIN
    ALTER TABLE [dbo].[CertificateRequest] ADD [RequestDate] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.CertificateRequest', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.CertificateRequest', N'Status') IS NULL
BEGIN
    ALTER TABLE [dbo].[CertificateRequest] ADD [Status] tinyint NULL;
END
GO
IF OBJECT_ID(N'dbo.CertificateRequest', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.CertificateRequest', N'AdminNote') IS NULL
BEGIN
    ALTER TABLE [dbo].[CertificateRequest] ADD [AdminNote] nvarchar(500) NULL;
END
GO
IF OBJECT_ID(N'dbo.CertificateRequest', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.CertificateRequest', N'ProcessedDate') IS NULL
BEGIN
    ALTER TABLE [dbo].[CertificateRequest] ADD [ProcessedDate] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.CertificateRequest', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.CertificateRequest', N'ProcessedBy') IS NULL
BEGIN
    ALTER TABLE [dbo].[CertificateRequest] ADD [ProcessedBy] int NULL;
END
GO

IF OBJECT_ID(N'dbo.ChatMessages', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ChatMessages] (
        [ChatMessageId] int IDENTITY(1,1) NOT NULL,
        [SenderId] int NOT NULL,
        [RecipientId] int NOT NULL,
        [MessageText] nvarchar(2000) NULL,
        [ImagePath] nvarchar(500) NULL,
        [CreatedAt] datetime NOT NULL CONSTRAINT [DF_ChatMessages_CreatedAt] DEFAULT (getdate()),
        [ReadAt] datetime NULL,
        [IsDeleted] bit NOT NULL CONSTRAINT [DF_ChatMessages_IsDeleted] DEFAULT ((0))
    );
END
GO
IF OBJECT_ID(N'dbo.ChatMessages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.ChatMessages', N'SenderId') IS NULL
BEGIN
    ALTER TABLE [dbo].[ChatMessages] ADD [SenderId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.ChatMessages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.ChatMessages', N'RecipientId') IS NULL
BEGIN
    ALTER TABLE [dbo].[ChatMessages] ADD [RecipientId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.ChatMessages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.ChatMessages', N'MessageText') IS NULL
BEGIN
    ALTER TABLE [dbo].[ChatMessages] ADD [MessageText] nvarchar(2000) NULL;
END
GO
IF OBJECT_ID(N'dbo.ChatMessages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.ChatMessages', N'ImagePath') IS NULL
BEGIN
    ALTER TABLE [dbo].[ChatMessages] ADD [ImagePath] nvarchar(500) NULL;
END
GO
IF OBJECT_ID(N'dbo.ChatMessages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.ChatMessages', N'CreatedAt') IS NULL
BEGIN
    ALTER TABLE [dbo].[ChatMessages] ADD [CreatedAt] datetime NULL DEFAULT (getdate());
END
GO
IF OBJECT_ID(N'dbo.ChatMessages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.ChatMessages', N'ReadAt') IS NULL
BEGIN
    ALTER TABLE [dbo].[ChatMessages] ADD [ReadAt] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.ChatMessages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.ChatMessages', N'IsDeleted') IS NULL
BEGIN
    ALTER TABLE [dbo].[ChatMessages] ADD [IsDeleted] bit NULL DEFAULT ((0));
END
GO

IF OBJECT_ID(N'dbo.ChatOnlineUsers', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ChatOnlineUsers] (
        [UserId] int NOT NULL,
        [LastSeen] datetime NOT NULL,
        [LastPage] nvarchar(500) NULL
    );
END
GO
IF OBJECT_ID(N'dbo.ChatOnlineUsers', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.ChatOnlineUsers', N'UserId') IS NULL
BEGIN
    ALTER TABLE [dbo].[ChatOnlineUsers] ADD [UserId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.ChatOnlineUsers', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.ChatOnlineUsers', N'LastSeen') IS NULL
BEGIN
    ALTER TABLE [dbo].[ChatOnlineUsers] ADD [LastSeen] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.ChatOnlineUsers', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.ChatOnlineUsers', N'LastPage') IS NULL
BEGIN
    ALTER TABLE [dbo].[ChatOnlineUsers] ADD [LastPage] nvarchar(500) NULL;
END
GO

IF OBJECT_ID(N'dbo.CourseContents', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[CourseContents] (
        [ContentId] int IDENTITY(1,1) NOT NULL,
        [CourseId] int NOT NULL,
        [ContentType] nvarchar(20) NOT NULL,
        [ContentTitle] nvarchar(200) NULL,
        [FilePath] nvarchar(500) NOT NULL,
        [CreatedDate] datetime NULL,
        [ContentDescription] nvarchar(MAX) NULL
    );
END
GO
IF OBJECT_ID(N'dbo.CourseContents', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.CourseContents', N'CourseId') IS NULL
BEGIN
    ALTER TABLE [dbo].[CourseContents] ADD [CourseId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.CourseContents', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.CourseContents', N'ContentType') IS NULL
BEGIN
    ALTER TABLE [dbo].[CourseContents] ADD [ContentType] nvarchar(20) NULL;
END
GO
IF OBJECT_ID(N'dbo.CourseContents', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.CourseContents', N'ContentTitle') IS NULL
BEGIN
    ALTER TABLE [dbo].[CourseContents] ADD [ContentTitle] nvarchar(200) NULL;
END
GO
IF OBJECT_ID(N'dbo.CourseContents', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.CourseContents', N'FilePath') IS NULL
BEGIN
    ALTER TABLE [dbo].[CourseContents] ADD [FilePath] nvarchar(500) NULL;
END
GO
IF OBJECT_ID(N'dbo.CourseContents', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.CourseContents', N'CreatedDate') IS NULL
BEGIN
    ALTER TABLE [dbo].[CourseContents] ADD [CreatedDate] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.CourseContents', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.CourseContents', N'ContentDescription') IS NULL
BEGIN
    ALTER TABLE [dbo].[CourseContents] ADD [ContentDescription] nvarchar(MAX) NULL;
END
GO

IF OBJECT_ID(N'dbo.CourseEnrollments', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[CourseEnrollments] (
        [EnrollmentId] int IDENTITY(1,1) NOT NULL,
        [CourseId] int NOT NULL,
        [UserId] int NOT NULL,
        [EnrollmentDate] datetime NULL,
        [IsDrawEntry] bit NOT NULL,
        [DrawEntryDate] datetime NULL
    );
END
GO
IF OBJECT_ID(N'dbo.CourseEnrollments', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.CourseEnrollments', N'CourseId') IS NULL
BEGIN
    ALTER TABLE [dbo].[CourseEnrollments] ADD [CourseId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.CourseEnrollments', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.CourseEnrollments', N'UserId') IS NULL
BEGIN
    ALTER TABLE [dbo].[CourseEnrollments] ADD [UserId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.CourseEnrollments', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.CourseEnrollments', N'EnrollmentDate') IS NULL
BEGIN
    ALTER TABLE [dbo].[CourseEnrollments] ADD [EnrollmentDate] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.CourseEnrollments', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.CourseEnrollments', N'IsDrawEntry') IS NULL
BEGIN
    ALTER TABLE [dbo].[CourseEnrollments] ADD [IsDrawEntry] bit NULL;
END
GO
IF OBJECT_ID(N'dbo.CourseEnrollments', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.CourseEnrollments', N'DrawEntryDate') IS NULL
BEGIN
    ALTER TABLE [dbo].[CourseEnrollments] ADD [DrawEntryDate] datetime NULL;
END
GO

IF OBJECT_ID(N'dbo.CourseReviews', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[CourseReviews] (
        [ReviewId] int IDENTITY(1,1) NOT NULL,
        [CourseId] int NOT NULL,
        [UserId] int NOT NULL,
        [Rating] tinyint NOT NULL,
        [Comment] nvarchar(MAX) NULL,
        [CreatedDate] datetime NOT NULL,
        [IsApproved] bit NOT NULL,
        [ApprovedBy] int NULL,
        [ApprovedDate] datetime NULL
    );
END
GO
IF OBJECT_ID(N'dbo.CourseReviews', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.CourseReviews', N'CourseId') IS NULL
BEGIN
    ALTER TABLE [dbo].[CourseReviews] ADD [CourseId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.CourseReviews', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.CourseReviews', N'UserId') IS NULL
BEGIN
    ALTER TABLE [dbo].[CourseReviews] ADD [UserId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.CourseReviews', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.CourseReviews', N'Rating') IS NULL
BEGIN
    ALTER TABLE [dbo].[CourseReviews] ADD [Rating] tinyint NULL;
END
GO
IF OBJECT_ID(N'dbo.CourseReviews', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.CourseReviews', N'Comment') IS NULL
BEGIN
    ALTER TABLE [dbo].[CourseReviews] ADD [Comment] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.CourseReviews', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.CourseReviews', N'CreatedDate') IS NULL
BEGIN
    ALTER TABLE [dbo].[CourseReviews] ADD [CreatedDate] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.CourseReviews', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.CourseReviews', N'IsApproved') IS NULL
BEGIN
    ALTER TABLE [dbo].[CourseReviews] ADD [IsApproved] bit NULL;
END
GO
IF OBJECT_ID(N'dbo.CourseReviews', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.CourseReviews', N'ApprovedBy') IS NULL
BEGIN
    ALTER TABLE [dbo].[CourseReviews] ADD [ApprovedBy] int NULL;
END
GO
IF OBJECT_ID(N'dbo.CourseReviews', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.CourseReviews', N'ApprovedDate') IS NULL
BEGIN
    ALTER TABLE [dbo].[CourseReviews] ADD [ApprovedDate] datetime NULL;
END
GO

IF OBJECT_ID(N'dbo.Courses', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Courses] (
        [CourseId] int IDENTITY(1,1) NOT NULL,
        [CourseTitle] nvarchar(200) NOT NULL,
        [CourseDescription] nvarchar(MAX) NULL,
        [CoverImage] nvarchar(MAX) NULL,
        [CreatedBy] int NOT NULL,
        [CreatedDate] datetime NULL,
        [CategoryId] int NOT NULL,
        [ResourceFile] nvarchar(MAX) NULL,
        [IsActive] bit NOT NULL,
        [IsDeleted] bit NULL
    );
END
GO
IF OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Courses', N'CourseTitle') IS NULL
BEGIN
    ALTER TABLE [dbo].[Courses] ADD [CourseTitle] nvarchar(200) NULL;
END
GO
IF OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Courses', N'CourseDescription') IS NULL
BEGIN
    ALTER TABLE [dbo].[Courses] ADD [CourseDescription] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Courses', N'CoverImage') IS NULL
BEGIN
    ALTER TABLE [dbo].[Courses] ADD [CoverImage] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Courses', N'CreatedBy') IS NULL
BEGIN
    ALTER TABLE [dbo].[Courses] ADD [CreatedBy] int NULL;
END
GO
IF OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Courses', N'CreatedDate') IS NULL
BEGIN
    ALTER TABLE [dbo].[Courses] ADD [CreatedDate] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Courses', N'CategoryId') IS NULL
BEGIN
    ALTER TABLE [dbo].[Courses] ADD [CategoryId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Courses', N'ResourceFile') IS NULL
BEGIN
    ALTER TABLE [dbo].[Courses] ADD [ResourceFile] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Courses', N'IsActive') IS NULL
BEGIN
    ALTER TABLE [dbo].[Courses] ADD [IsActive] bit NULL;
END
GO
IF OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Courses', N'IsDeleted') IS NULL
BEGIN
    ALTER TABLE [dbo].[Courses] ADD [IsDeleted] bit NULL;
END
GO

IF OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[DocumentTerms] (
        [Id] int IDENTITY(1,1) NOT NULL,
        [Term] nvarchar(200) NOT NULL,
        [Slug] nvarchar(250) NOT NULL,
        [Category] nvarchar(100) NOT NULL,
        [Definition] nvarchar(MAX) NOT NULL,
        [DetailedDescription] nvarchar(MAX) NULL,
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
IF OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.DocumentTerms', N'Term') IS NULL
BEGIN
    ALTER TABLE [dbo].[DocumentTerms] ADD [Term] nvarchar(200) NULL;
END
GO
IF OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.DocumentTerms', N'Slug') IS NULL
BEGIN
    ALTER TABLE [dbo].[DocumentTerms] ADD [Slug] nvarchar(250) NULL;
END
GO
IF OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.DocumentTerms', N'Category') IS NULL
BEGIN
    ALTER TABLE [dbo].[DocumentTerms] ADD [Category] nvarchar(100) NULL;
END
GO
IF OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.DocumentTerms', N'Definition') IS NULL
BEGIN
    ALTER TABLE [dbo].[DocumentTerms] ADD [Definition] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.DocumentTerms', N'DetailedDescription') IS NULL
BEGIN
    ALTER TABLE [dbo].[DocumentTerms] ADD [DetailedDescription] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.DocumentTerms', N'ImageUrl') IS NULL
BEGIN
    ALTER TABLE [dbo].[DocumentTerms] ADD [ImageUrl] nvarchar(500) NULL;
END
GO
IF OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.DocumentTerms', N'RelatedTerms') IS NULL
BEGIN
    ALTER TABLE [dbo].[DocumentTerms] ADD [RelatedTerms] nvarchar(500) NULL;
END
GO
IF OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.DocumentTerms', N'IsActive') IS NULL
BEGIN
    ALTER TABLE [dbo].[DocumentTerms] ADD [IsActive] bit NULL;
END
GO
IF OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.DocumentTerms', N'CreatedAt') IS NULL
BEGIN
    ALTER TABLE [dbo].[DocumentTerms] ADD [CreatedAt] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.DocumentTerms', N'UpdatedAt') IS NULL
BEGIN
    ALTER TABLE [dbo].[DocumentTerms] ADD [UpdatedAt] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.DocumentTerms', N'Sicil') IS NULL
BEGIN
    ALTER TABLE [dbo].[DocumentTerms] ADD [Sicil] nvarchar(50) NULL;
END
GO
IF OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.DocumentTerms', N'AdSoyad') IS NULL
BEGIN
    ALTER TABLE [dbo].[DocumentTerms] ADD [AdSoyad] nvarchar(200) NULL;
END
GO

IF OBJECT_ID(N'dbo.E_AUH', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[E_AUH] (
        [fldId] int IDENTITY(1,1) NOT NULL,
        [fldCountry] nvarchar(MAX) NULL,
        [fldFirstMounth] nvarchar(MAX) NULL,
        [fldKat] nvarchar(MAX) NULL,
        [fldDayStart] nvarchar(MAX) NULL,
        [fldDayKat] nvarchar(MAX) NULL,
        [fldToM] nvarchar(MAX) NULL
    );
END
GO
IF OBJECT_ID(N'dbo.E_AUH', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_AUH', N'fldCountry') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_AUH] ADD [fldCountry] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_AUH', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_AUH', N'fldFirstMounth') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_AUH] ADD [fldFirstMounth] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_AUH', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_AUH', N'fldKat') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_AUH] ADD [fldKat] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_AUH', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_AUH', N'fldDayStart') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_AUH] ADD [fldDayStart] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_AUH', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_AUH', N'fldDayKat') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_AUH] ADD [fldDayKat] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_AUH', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_AUH', N'fldToM') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_AUH] ADD [fldToM] nvarchar(MAX) NULL;
END
GO

IF OBJECT_ID(N'dbo.E_Border', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[E_Border] (
        [fldId] int IDENTITY(1,1) NOT NULL,
        [fldName] nvarchar(MAX) NULL
    );
END
GO
IF OBJECT_ID(N'dbo.E_Border', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Border', N'fldName') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Border] ADD [fldName] nvarchar(MAX) NULL;
END
GO

IF OBJECT_ID(N'dbo.E_Defter', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[E_Defter] (
        [fldId] int IDENTITY(1,1) NOT NULL,
        [fldPrice] nvarchar(25) NULL,
        [fldTypeofMoney] nvarchar(50) NULL
    );
END
GO
IF OBJECT_ID(N'dbo.E_Defter', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Defter', N'fldPrice') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Defter] ADD [fldPrice] nvarchar(25) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Defter', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Defter', N'fldTypeofMoney') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Defter] ADD [fldTypeofMoney] nvarchar(50) NULL;
END
GO

IF OBJECT_ID(N'dbo.E_Dilekce', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[E_Dilekce] (
        [DilekceId] int IDENTITY(1,1) NOT NULL,
        [AdSoyad] nvarchar(100) NULL,
        [DogumTarih] date NULL,
        [DogumYeri] nvarchar(250) NULL,
        [PasaportNo] nvarchar(250) NULL,
        [KimlikNo] nvarchar(250) NULL,
        [Adres] nvarchar(250) NULL,
        [Telefon] nchar(20) NULL,
        [Uyruk] nvarchar(500) NULL,
        [DilekceTarih] date NULL,
        [Tarih1] date NULL,
        [Tarih2] date NULL,
        [DilekceSebep] nvarchar(MAX) NULL,
        [Valilik] nvarchar(500) NULL,
        [DosyaNo] nchar(50) NULL,
        [Unvan] nvarchar(500) NULL,
        [Aciklama] nvarchar(MAX) NULL,
        [Sicil] nvarchar(MAX) NULL
    );
END
GO
IF OBJECT_ID(N'dbo.E_Dilekce', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Dilekce', N'AdSoyad') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Dilekce] ADD [AdSoyad] nvarchar(100) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Dilekce', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Dilekce', N'DogumTarih') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Dilekce] ADD [DogumTarih] date NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Dilekce', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Dilekce', N'DogumYeri') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Dilekce] ADD [DogumYeri] nvarchar(250) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Dilekce', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Dilekce', N'PasaportNo') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Dilekce] ADD [PasaportNo] nvarchar(250) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Dilekce', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Dilekce', N'KimlikNo') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Dilekce] ADD [KimlikNo] nvarchar(250) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Dilekce', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Dilekce', N'Adres') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Dilekce] ADD [Adres] nvarchar(250) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Dilekce', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Dilekce', N'Telefon') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Dilekce] ADD [Telefon] nchar(20) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Dilekce', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Dilekce', N'Uyruk') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Dilekce] ADD [Uyruk] nvarchar(500) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Dilekce', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Dilekce', N'DilekceTarih') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Dilekce] ADD [DilekceTarih] date NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Dilekce', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Dilekce', N'Tarih1') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Dilekce] ADD [Tarih1] date NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Dilekce', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Dilekce', N'Tarih2') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Dilekce] ADD [Tarih2] date NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Dilekce', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Dilekce', N'DilekceSebep') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Dilekce] ADD [DilekceSebep] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Dilekce', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Dilekce', N'Valilik') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Dilekce] ADD [Valilik] nvarchar(500) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Dilekce', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Dilekce', N'DosyaNo') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Dilekce] ADD [DosyaNo] nchar(50) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Dilekce', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Dilekce', N'Unvan') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Dilekce] ADD [Unvan] nvarchar(500) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Dilekce', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Dilekce', N'Aciklama') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Dilekce] ADD [Aciklama] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Dilekce', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Dilekce', N'Sicil') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Dilekce] ADD [Sicil] nvarchar(MAX) NULL;
END
GO

IF OBJECT_ID(N'dbo.E_Exchange', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[E_Exchange] (
        [fldId] int IDENTITY(1,1) NOT NULL,
        [fldEuro] nvarchar(50) NULL,
        [fldDollar] nvarchar(50) NULL,
        [fldPaund] nvarchar(50) NULL
    );
END
GO
IF OBJECT_ID(N'dbo.E_Exchange', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Exchange', N'fldEuro') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Exchange] ADD [fldEuro] nvarchar(50) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Exchange', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Exchange', N'fldDollar') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Exchange] ADD [fldDollar] nvarchar(50) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Exchange', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Exchange', N'fldPaund') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Exchange] ADD [fldPaund] nvarchar(50) NULL;
END
GO

IF OBJECT_ID(N'dbo.E_Forms', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[E_Forms] (
        [fldId] int IDENTITY(1,1) NOT NULL,
        [fldGB] nvarchar(MAX) NULL,
        [fldDE] nvarchar(MAX) NULL,
        [fldRU] nvarchar(MAX) NULL,
        [fldIR] nvarchar(MAX) NULL,
        [fldGBC] nvarchar(MAX) NULL,
        [fldDEC] nvarchar(MAX) NULL,
        [fldRUC] nvarchar(MAX) NULL,
        [fldIRC] nvarchar(MAX) NULL,
        [fldIRKC] nvarchar(MAX) NULL,
        [fldIRK] nvarchar(MAX) NULL,
        [fldFransizca] nvarchar(MAX) NULL,
        [fldFransizcaC] nvarchar(MAX) NULL
    );
END
GO
IF OBJECT_ID(N'dbo.E_Forms', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Forms', N'fldGB') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Forms] ADD [fldGB] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Forms', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Forms', N'fldDE') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Forms] ADD [fldDE] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Forms', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Forms', N'fldRU') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Forms] ADD [fldRU] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Forms', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Forms', N'fldIR') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Forms] ADD [fldIR] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Forms', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Forms', N'fldGBC') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Forms] ADD [fldGBC] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Forms', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Forms', N'fldDEC') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Forms] ADD [fldDEC] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Forms', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Forms', N'fldRUC') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Forms] ADD [fldRUC] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Forms', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Forms', N'fldIRC') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Forms] ADD [fldIRC] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Forms', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Forms', N'fldIRKC') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Forms] ADD [fldIRKC] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Forms', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Forms', N'fldIRK') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Forms] ADD [fldIRK] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Forms', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Forms', N'fldFransizca') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Forms] ADD [fldFransizca] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Forms', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Forms', N'fldFransizcaC') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Forms] ADD [fldFransizcaC] nvarchar(MAX) NULL;
END
GO

IF OBJECT_ID(N'dbo.E_History', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[E_History] (
        [fldId] int IDENTITY(1,1) NOT NULL,
        [fldStart] datetime NULL,
        [fldShouldExit] datetime NULL,
        [fldBirthDate] datetime NULL,
        [fldCountry] nvarchar(MAX) NULL,
        [fldPenalty] nvarchar(MAX) NULL,
        [fldPMoney] nvarchar(MAX) NULL,
        [fldUser] nvarchar(MAX) NULL,
        [fldBorder] nvarchar(MAX) NULL,
        [fldDatetime] datetime NULL
    );
END
GO
IF OBJECT_ID(N'dbo.E_History', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_History', N'fldStart') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_History] ADD [fldStart] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.E_History', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_History', N'fldShouldExit') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_History] ADD [fldShouldExit] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.E_History', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_History', N'fldBirthDate') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_History] ADD [fldBirthDate] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.E_History', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_History', N'fldCountry') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_History] ADD [fldCountry] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_History', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_History', N'fldPenalty') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_History] ADD [fldPenalty] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_History', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_History', N'fldPMoney') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_History] ADD [fldPMoney] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_History', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_History', N'fldUser') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_History] ADD [fldUser] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_History', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_History', N'fldBorder') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_History] ADD [fldBorder] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_History', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_History', N'fldDatetime') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_History] ADD [fldDatetime] datetime NULL;
END
GO

IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[E_Inad] (
        [InadId] int IDENTITY(1,1) NOT NULL,
        [TarihSaat] date NULL,
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
        [InadSebepAciklama] nvarchar(MAX) NULL,
        [InadSebep] nvarchar(MAX) NULL,
        [GidenHavayolu] nvarchar(150) NULL,
        [GidisUcusNo] nvarchar(10) NULL,
        [GidisYer] nchar(250) NULL,
        [GidisTarihSaat] datetime NULL,
        [Personel] nvarchar(MAX) NULL,
        [UstAramaEsya] nvarchar(MAX) NULL,
        [UcagaNakil] nvarchar(MAX) NULL,
        [OzelGuvenlik] nvarchar(50) NULL,
        [YerHizmetleriPersonel] nvarchar(50) NULL,
        [YerHizmetleri] nchar(250) NULL,
        [Refakat] nvarchar(250) NULL,
        [Kapi] nvarchar(MAX) NULL,
        [Valilik] nvarchar(MAX) NULL,
        [Durum] nvarchar(MAX) NULL,
        [Sicil] nvarchar(MAX) NULL
    );
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'TarihSaat') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [TarihSaat] date NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'AdSoyad') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [AdSoyad] nchar(50) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'DogumT') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [DogumT] date NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'DogumY') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [DogumY] nvarchar(50) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'Cinsiyet') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [Cinsiyet] nvarchar(10) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'Uyruk') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [Uyruk] nchar(250) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'PasaportNo') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [PasaportNo] nchar(20) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'BelgeNo') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [BelgeNo] nvarchar(20) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'PasaportTuru') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [PasaportTuru] nchar(50) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'Beyan') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [Beyan] nvarchar(100) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'GelenUcusNo') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [GelenUcusNo] nvarchar(10) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'GelenHavayolu') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [GelenHavayolu] nvarchar(150) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'GeldigiYer') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [GeldigiYer] nchar(250) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'GeldigiTarihSaat') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [GeldigiTarihSaat] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'InadSebepAciklama') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [InadSebepAciklama] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'InadSebep') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [InadSebep] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'GidenHavayolu') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [GidenHavayolu] nvarchar(150) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'GidisUcusNo') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [GidisUcusNo] nvarchar(10) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'GidisYer') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [GidisYer] nchar(250) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'GidisTarihSaat') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [GidisTarihSaat] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'Personel') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [Personel] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'UstAramaEsya') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [UstAramaEsya] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'UcagaNakil') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [UcagaNakil] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'OzelGuvenlik') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [OzelGuvenlik] nvarchar(50) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'YerHizmetleriPersonel') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [YerHizmetleriPersonel] nvarchar(50) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'YerHizmetleri') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [YerHizmetleri] nchar(250) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'Refakat') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [Refakat] nvarchar(250) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'Kapi') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [Kapi] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'Valilik') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [Valilik] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'Durum') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [Durum] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Inad', N'Sicil') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD [Sicil] nvarchar(MAX) NULL;
END
GO

IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[E_IsK] (
        [fldId] int IDENTITY(1,1) NOT NULL,
        [fldDatetime] datetime NULL,
        [fldName] nvarchar(MAX) NULL,
        [fldPassport] nvarchar(MAX) NULL,
        [fldIdn] nvarchar(MAX) NULL,
        [fldOrgin] nvarchar(MAX) NULL,
        [fldBirthdate] date NULL,
        [fldForm] nvarchar(MAX) NULL,
        [fldPassControl] nvarchar(MAX) NULL,
        [fldApproval] nvarchar(MAX) NULL,
        [fldBorder] nvarchar(MAX) NULL,
        [fldVisa] nvarchar(MAX) NULL,
        [fldPMoney] nvarchar(MAX) NULL,
        [fldPicture] nvarchar(MAX) NULL
    );
END
GO
IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_IsK', N'fldDatetime') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_IsK] ADD [fldDatetime] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_IsK', N'fldName') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_IsK] ADD [fldName] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_IsK', N'fldPassport') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_IsK] ADD [fldPassport] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_IsK', N'fldIdn') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_IsK] ADD [fldIdn] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_IsK', N'fldOrgin') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_IsK] ADD [fldOrgin] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_IsK', N'fldBirthdate') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_IsK] ADD [fldBirthdate] date NULL;
END
GO
IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_IsK', N'fldForm') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_IsK] ADD [fldForm] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_IsK', N'fldPassControl') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_IsK] ADD [fldPassControl] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_IsK', N'fldApproval') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_IsK] ADD [fldApproval] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_IsK', N'fldBorder') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_IsK] ADD [fldBorder] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_IsK', N'fldVisa') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_IsK] ADD [fldVisa] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_IsK', N'fldPMoney') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_IsK] ADD [fldPMoney] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_IsK', N'fldPicture') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_IsK] ADD [fldPicture] nvarchar(MAX) NULL;
END
GO

IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[E_Messages] (
        [fldId] int IDENTITY(1,1) NOT NULL,
        [fldSendByName] nvarchar(MAX) NULL,
        [fldSendBySicil] nvarchar(MAX) NULL,
        [fldSendByPhone] nvarchar(MAX) NULL,
        [fldSendByMail] nvarchar(MAX) NULL,
        [fldDateTime] datetime NULL,
        [fldMessage] nvarchar(MAX) NULL,
        [fldSenderId] int NULL,
        [fldSenderRole] nvarchar(20) NULL,
        [fldRecipientId] int NULL,
        [fldRecipientRole] nvarchar(20) NULL,
        [fldSubject] nvarchar(200) NULL,
        [fldIsRead] bit NOT NULL CONSTRAINT [DF__E_Message__fldIs__119F9925] DEFAULT ((0)),
        [fldReadDateTime] datetime NULL,
        [fldIsDeletedBySender] bit NOT NULL CONSTRAINT [DF__E_Message__fldIs__1293BD5E] DEFAULT ((0)),
        [fldIsDeletedByRecipient] bit NOT NULL CONSTRAINT [DF__E_Message__fldIs__1387E197] DEFAULT ((0)),
        [fldParentMessageId] int NULL,
        [fldIsReply] bit NOT NULL CONSTRAINT [DF__E_Message__fldIs__147C05D0] DEFAULT ((0)),
        [fldIsApproved] bit NOT NULL CONSTRAINT [DF__E_Message__fldIs__546180BB] DEFAULT ((0)),
        [fldApprovedBy] int NULL,
        [fldApprovedDateTime] datetime NULL
    );
END
GO
IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Messages', N'fldSendByName') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Messages] ADD [fldSendByName] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Messages', N'fldSendBySicil') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Messages] ADD [fldSendBySicil] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Messages', N'fldSendByPhone') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Messages] ADD [fldSendByPhone] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Messages', N'fldSendByMail') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Messages] ADD [fldSendByMail] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Messages', N'fldDateTime') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Messages] ADD [fldDateTime] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Messages', N'fldMessage') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Messages] ADD [fldMessage] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Messages', N'fldSenderId') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Messages] ADD [fldSenderId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Messages', N'fldSenderRole') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Messages] ADD [fldSenderRole] nvarchar(20) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Messages', N'fldRecipientId') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Messages] ADD [fldRecipientId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Messages', N'fldRecipientRole') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Messages] ADD [fldRecipientRole] nvarchar(20) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Messages', N'fldSubject') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Messages] ADD [fldSubject] nvarchar(200) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Messages', N'fldIsRead') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Messages] ADD [fldIsRead] bit NULL DEFAULT ((0));
END
GO
IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Messages', N'fldReadDateTime') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Messages] ADD [fldReadDateTime] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Messages', N'fldIsDeletedBySender') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Messages] ADD [fldIsDeletedBySender] bit NULL DEFAULT ((0));
END
GO
IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Messages', N'fldIsDeletedByRecipient') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Messages] ADD [fldIsDeletedByRecipient] bit NULL DEFAULT ((0));
END
GO
IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Messages', N'fldParentMessageId') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Messages] ADD [fldParentMessageId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Messages', N'fldIsReply') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Messages] ADD [fldIsReply] bit NULL DEFAULT ((0));
END
GO
IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Messages', N'fldIsApproved') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Messages] ADD [fldIsApproved] bit NULL DEFAULT ((0));
END
GO
IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Messages', N'fldApprovedBy') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Messages] ADD [fldApprovedBy] int NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Messages', N'fldApprovedDateTime') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Messages] ADD [fldApprovedDateTime] datetime NULL;
END
GO

IF OBJECT_ID(N'dbo.E_Sartli', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[E_Sartli] (
        [fldId] int IDENTITY(1,1) NOT NULL,
        [fldBy] varchar(150) NULL,
        [fldOrgin] nvarchar(50) NULL,
        [fldBdate] date NULL,
        [fldDate] datetime NULL,
        [fldName] nvarchar(250) NULL,
        [fldBorder] nvarchar(500) NULL
    );
END
GO
IF OBJECT_ID(N'dbo.E_Sartli', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Sartli', N'fldBy') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Sartli] ADD [fldBy] varchar(150) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Sartli', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Sartli', N'fldOrgin') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Sartli] ADD [fldOrgin] nvarchar(50) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Sartli', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Sartli', N'fldBdate') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Sartli] ADD [fldBdate] date NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Sartli', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Sartli', N'fldDate') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Sartli] ADD [fldDate] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Sartli', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Sartli', N'fldName') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Sartli] ADD [fldName] nvarchar(250) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Sartli', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Sartli', N'fldBorder') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Sartli] ADD [fldBorder] nvarchar(500) NULL;
END
GO

IF OBJECT_ID(N'dbo.E_TGVH', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[E_TGVH] (
        [fldId] int IDENTITY(1,1) NOT NULL,
        [fldPrice] nvarchar(25) NULL,
        [fldTypeofMoney] nvarchar(25) NULL,
        [fldYear] nvarchar(25) NULL
    );
END
GO
IF OBJECT_ID(N'dbo.E_TGVH', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_TGVH', N'fldPrice') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_TGVH] ADD [fldPrice] nvarchar(25) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_TGVH', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_TGVH', N'fldTypeofMoney') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_TGVH] ADD [fldTypeofMoney] nvarchar(25) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_TGVH', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_TGVH', N'fldYear') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_TGVH] ADD [fldYear] nvarchar(25) NULL;
END
GO

IF OBJECT_ID(N'dbo.E_TKOD', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[E_TKOD] (
        [fldId] int IDENTITY(1,1) NOT NULL,
        [fldCode] nvarchar(50) NULL,
        [fldPTime] nvarchar(50) NULL,
        [fldStart] int NULL,
        [fldFinish] int NULL,
        [fldIdariCode] nvarchar(50) NULL,
        [fldPaid] tinyint NULL
    );
END
GO
IF OBJECT_ID(N'dbo.E_TKOD', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_TKOD', N'fldCode') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_TKOD] ADD [fldCode] nvarchar(50) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_TKOD', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_TKOD', N'fldPTime') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_TKOD] ADD [fldPTime] nvarchar(50) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_TKOD', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_TKOD', N'fldStart') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_TKOD] ADD [fldStart] int NULL;
END
GO
IF OBJECT_ID(N'dbo.E_TKOD', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_TKOD', N'fldFinish') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_TKOD] ADD [fldFinish] int NULL;
END
GO
IF OBJECT_ID(N'dbo.E_TKOD', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_TKOD', N'fldIdariCode') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_TKOD] ADD [fldIdariCode] nvarchar(50) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_TKOD', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_TKOD', N'fldPaid') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_TKOD] ADD [fldPaid] tinyint NULL;
END
GO

IF OBJECT_ID(N'dbo.E_Token', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[E_Token] (
        [fldId] int IDENTITY(1,1) NOT NULL,
        [fldUserId] int NULL,
        [fldToken] nvarchar(MAX) NULL,
        [fldDateTime] datetime NULL,
        [fldIp] nvarchar(50) NULL
    );
END
GO
IF OBJECT_ID(N'dbo.E_Token', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Token', N'fldUserId') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Token] ADD [fldUserId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Token', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Token', N'fldToken') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Token] ADD [fldToken] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Token', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Token', N'fldDateTime') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Token] ADD [fldDateTime] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.E_Token', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_Token', N'fldIp') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_Token] ADD [fldIp] nvarchar(50) NULL;
END
GO

IF OBJECT_ID(N'dbo.E_User', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[E_User] (
        [fldId] int IDENTITY(1,1) NOT NULL,
        [fldSicil] nvarchar(MAX) NULL,
        [fldName] nvarchar(MAX) NULL,
        [fldLastName] nvarchar(MAX) NULL,
        [fldPhone] nvarchar(MAX) NULL,
        [fldEmail] nvarchar(MAX) NULL,
        [fldTitle] nvarchar(MAX) NULL,
        [fldDeputy] nvarchar(MAX) NULL,
        [fldPicture] nvarchar(MAX) NULL,
        [fldAuth] nvarchar(MAX) NULL,
        [fldSubAuth] nvarchar(MAX) NULL,
        [fldPassword] nvarchar(MAX) NULL,
        [fldDateTime] datetime NULL,
        [fldBorder] nvarchar(MAX) NULL,
        [fldActive] nchar(1) NULL,
        [Role] nvarchar(20) NOT NULL CONSTRAINT [DF__E_User__Role__7CA47C3F] DEFAULT ('User'),
        [LastLogin] datetime NULL,
        [XP] int NOT NULL CONSTRAINT [DF__E_User__XP__7D98A078] DEFAULT ((0)),
        [Level] int NOT NULL CONSTRAINT [DF__E_User__Level__7E8CC4B1] DEFAULT ((1)),
        [IsActive] bit NULL,
        [TeacherRequestStatus] tinyint NULL,
        [TeacherRequestDate] datetime NULL
    );
END
GO
IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_User', N'fldSicil') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_User] ADD [fldSicil] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_User', N'fldName') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_User] ADD [fldName] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_User', N'fldLastName') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_User] ADD [fldLastName] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_User', N'fldPhone') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_User] ADD [fldPhone] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_User', N'fldEmail') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_User] ADD [fldEmail] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_User', N'fldTitle') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_User] ADD [fldTitle] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_User', N'fldDeputy') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_User] ADD [fldDeputy] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_User', N'fldPicture') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_User] ADD [fldPicture] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_User', N'fldAuth') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_User] ADD [fldAuth] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_User', N'fldSubAuth') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_User] ADD [fldSubAuth] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_User', N'fldPassword') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_User] ADD [fldPassword] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_User', N'fldDateTime') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_User] ADD [fldDateTime] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_User', N'fldBorder') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_User] ADD [fldBorder] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_User', N'fldActive') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_User] ADD [fldActive] nchar(1) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_User', N'Role') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_User] ADD [Role] nvarchar(20) NULL DEFAULT ('User');
END
GO
IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_User', N'LastLogin') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_User] ADD [LastLogin] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_User', N'XP') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_User] ADD [XP] int NULL DEFAULT ((0));
END
GO
IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_User', N'Level') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_User] ADD [Level] int NULL DEFAULT ((1));
END
GO
IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_User', N'IsActive') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_User] ADD [IsActive] bit NULL;
END
GO
IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_User', N'TeacherRequestStatus') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_User] ADD [TeacherRequestStatus] tinyint NULL;
END
GO
IF OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_User', N'TeacherRequestDate') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_User] ADD [TeacherRequestDate] datetime NULL;
END
GO

IF OBJECT_ID(N'dbo.E_UVR', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[E_UVR] (
        [fldId] int IDENTITY(1,1) NOT NULL,
        [fldCountry] nvarchar(MAX) NULL,
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
IF OBJECT_ID(N'dbo.E_UVR', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_UVR', N'fldCountry') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_UVR] ADD [fldCountry] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_UVR', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_UVR', N'fldCalculateType') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_UVR] ADD [fldCalculateType] int NULL;
END
GO
IF OBJECT_ID(N'dbo.E_UVR', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_UVR', N'fldPassportType') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_UVR] ADD [fldPassportType] int NULL;
END
GO
IF OBJECT_ID(N'dbo.E_UVR', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_UVR', N'fldVisaStatus') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_UVR] ADD [fldVisaStatus] int NULL;
END
GO
IF OBJECT_ID(N'dbo.E_UVR', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_UVR', N'fldDay') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_UVR] ADD [fldDay] int NULL;
END
GO
IF OBJECT_ID(N'dbo.E_UVR', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_UVR', N'fldLong') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_UVR] ADD [fldLong] int NULL;
END
GO
IF OBJECT_ID(N'dbo.E_UVR', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_UVR', N'fldOneTime') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_UVR] ADD [fldOneTime] int NULL;
END
GO
IF OBJECT_ID(N'dbo.E_UVR', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_UVR', N'fldHB') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_UVR] ADD [fldHB] tinyint NULL;
END
GO

IF OBJECT_ID(N'dbo.E_UVR_Backup_Before_WorkPermit', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[E_UVR_Backup_Before_WorkPermit] (
        [fldId] int IDENTITY(1,1) NOT NULL,
        [fldCountry] nvarchar(MAX) NULL,
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
IF OBJECT_ID(N'dbo.E_UVR_Backup_Before_WorkPermit', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_UVR_Backup_Before_WorkPermit', N'fldCountry') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_UVR_Backup_Before_WorkPermit] ADD [fldCountry] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.E_UVR_Backup_Before_WorkPermit', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_UVR_Backup_Before_WorkPermit', N'fldCalculateType') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_UVR_Backup_Before_WorkPermit] ADD [fldCalculateType] int NULL;
END
GO
IF OBJECT_ID(N'dbo.E_UVR_Backup_Before_WorkPermit', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_UVR_Backup_Before_WorkPermit', N'fldPassportType') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_UVR_Backup_Before_WorkPermit] ADD [fldPassportType] int NULL;
END
GO
IF OBJECT_ID(N'dbo.E_UVR_Backup_Before_WorkPermit', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_UVR_Backup_Before_WorkPermit', N'fldVisaStatus') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_UVR_Backup_Before_WorkPermit] ADD [fldVisaStatus] int NULL;
END
GO
IF OBJECT_ID(N'dbo.E_UVR_Backup_Before_WorkPermit', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_UVR_Backup_Before_WorkPermit', N'fldDay') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_UVR_Backup_Before_WorkPermit] ADD [fldDay] int NULL;
END
GO
IF OBJECT_ID(N'dbo.E_UVR_Backup_Before_WorkPermit', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_UVR_Backup_Before_WorkPermit', N'fldLong') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_UVR_Backup_Before_WorkPermit] ADD [fldLong] int NULL;
END
GO
IF OBJECT_ID(N'dbo.E_UVR_Backup_Before_WorkPermit', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_UVR_Backup_Before_WorkPermit', N'fldOneTime') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_UVR_Backup_Before_WorkPermit] ADD [fldOneTime] int NULL;
END
GO
IF OBJECT_ID(N'dbo.E_UVR_Backup_Before_WorkPermit', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.E_UVR_Backup_Before_WorkPermit', N'fldHB') IS NULL
BEGIN
    ALTER TABLE [dbo].[E_UVR_Backup_Before_WorkPermit] ADD [fldHB] tinyint NULL;
END
GO

IF OBJECT_ID(N'dbo.EducationPackageImportLog', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[EducationPackageImportLog] (
        [Id] int IDENTITY(1,1) NOT NULL,
        [PackageCode] nvarchar(100) NULL,
        [PackageTitle] nvarchar(300) NULL,
        [PackageVersion] nvarchar(30) NULL,
        [SourceDocumentCode] nvarchar(100) NULL,
        [ImportedCourseId] int NULL,
        [ImportedExamId] int NULL,
        [ImportedByUserId] int NOT NULL,
        [ImportedDate] datetime NOT NULL CONSTRAINT [DF_EducationPackageImportLog_ImportedDate] DEFAULT (getdate()),
        [FileName] nvarchar(260) NULL,
        [Status] nvarchar(30) NOT NULL,
        [Message] nvarchar(2000) NULL
    );
END
GO
IF OBJECT_ID(N'dbo.EducationPackageImportLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.EducationPackageImportLog', N'PackageCode') IS NULL
BEGIN
    ALTER TABLE [dbo].[EducationPackageImportLog] ADD [PackageCode] nvarchar(100) NULL;
END
GO
IF OBJECT_ID(N'dbo.EducationPackageImportLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.EducationPackageImportLog', N'PackageTitle') IS NULL
BEGIN
    ALTER TABLE [dbo].[EducationPackageImportLog] ADD [PackageTitle] nvarchar(300) NULL;
END
GO
IF OBJECT_ID(N'dbo.EducationPackageImportLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.EducationPackageImportLog', N'PackageVersion') IS NULL
BEGIN
    ALTER TABLE [dbo].[EducationPackageImportLog] ADD [PackageVersion] nvarchar(30) NULL;
END
GO
IF OBJECT_ID(N'dbo.EducationPackageImportLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.EducationPackageImportLog', N'SourceDocumentCode') IS NULL
BEGIN
    ALTER TABLE [dbo].[EducationPackageImportLog] ADD [SourceDocumentCode] nvarchar(100) NULL;
END
GO
IF OBJECT_ID(N'dbo.EducationPackageImportLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.EducationPackageImportLog', N'ImportedCourseId') IS NULL
BEGIN
    ALTER TABLE [dbo].[EducationPackageImportLog] ADD [ImportedCourseId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.EducationPackageImportLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.EducationPackageImportLog', N'ImportedExamId') IS NULL
BEGIN
    ALTER TABLE [dbo].[EducationPackageImportLog] ADD [ImportedExamId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.EducationPackageImportLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.EducationPackageImportLog', N'ImportedByUserId') IS NULL
BEGIN
    ALTER TABLE [dbo].[EducationPackageImportLog] ADD [ImportedByUserId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.EducationPackageImportLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.EducationPackageImportLog', N'ImportedDate') IS NULL
BEGIN
    ALTER TABLE [dbo].[EducationPackageImportLog] ADD [ImportedDate] datetime NULL DEFAULT (getdate());
END
GO
IF OBJECT_ID(N'dbo.EducationPackageImportLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.EducationPackageImportLog', N'FileName') IS NULL
BEGIN
    ALTER TABLE [dbo].[EducationPackageImportLog] ADD [FileName] nvarchar(260) NULL;
END
GO
IF OBJECT_ID(N'dbo.EducationPackageImportLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.EducationPackageImportLog', N'Status') IS NULL
BEGIN
    ALTER TABLE [dbo].[EducationPackageImportLog] ADD [Status] nvarchar(30) NULL;
END
GO
IF OBJECT_ID(N'dbo.EducationPackageImportLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.EducationPackageImportLog', N'Message') IS NULL
BEGIN
    ALTER TABLE [dbo].[EducationPackageImportLog] ADD [Message] nvarchar(2000) NULL;
END
GO

IF OBJECT_ID(N'dbo.Exam', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Exam] (
        [ExamId] int IDENTITY(1,1) NOT NULL,
        [CourseId] int NOT NULL,
        [Title] nvarchar(200) NOT NULL,
        [Description] nvarchar(MAX) NULL,
        [DurationMinutes] int NULL,
        [PassingScore] int NULL,
        [IsActive] bit NOT NULL,
        [CreatedAt] datetime NOT NULL,
        [IsArchived] bit NULL
    );
END
GO
IF OBJECT_ID(N'dbo.Exam', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Exam', N'CourseId') IS NULL
BEGIN
    ALTER TABLE [dbo].[Exam] ADD [CourseId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.Exam', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Exam', N'Title') IS NULL
BEGIN
    ALTER TABLE [dbo].[Exam] ADD [Title] nvarchar(200) NULL;
END
GO
IF OBJECT_ID(N'dbo.Exam', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Exam', N'Description') IS NULL
BEGIN
    ALTER TABLE [dbo].[Exam] ADD [Description] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.Exam', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Exam', N'DurationMinutes') IS NULL
BEGIN
    ALTER TABLE [dbo].[Exam] ADD [DurationMinutes] int NULL;
END
GO
IF OBJECT_ID(N'dbo.Exam', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Exam', N'PassingScore') IS NULL
BEGIN
    ALTER TABLE [dbo].[Exam] ADD [PassingScore] int NULL;
END
GO
IF OBJECT_ID(N'dbo.Exam', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Exam', N'IsActive') IS NULL
BEGIN
    ALTER TABLE [dbo].[Exam] ADD [IsActive] bit NULL;
END
GO
IF OBJECT_ID(N'dbo.Exam', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Exam', N'CreatedAt') IS NULL
BEGIN
    ALTER TABLE [dbo].[Exam] ADD [CreatedAt] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.Exam', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Exam', N'IsArchived') IS NULL
BEGIN
    ALTER TABLE [dbo].[Exam] ADD [IsArchived] bit NULL;
END
GO

IF OBJECT_ID(N'dbo.ExamResult', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ExamResult] (
        [ExamResultId] int IDENTITY(1,1) NOT NULL,
        [ExamId] int NOT NULL,
        [UserId] int NULL,
        [Score] decimal(5,2) NULL,
        [StartedAt] datetime NULL,
        [FinishedAt] datetime NULL,
        [Status] tinyint NOT NULL
    );
END
GO
IF OBJECT_ID(N'dbo.ExamResult', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.ExamResult', N'ExamId') IS NULL
BEGIN
    ALTER TABLE [dbo].[ExamResult] ADD [ExamId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.ExamResult', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.ExamResult', N'UserId') IS NULL
BEGIN
    ALTER TABLE [dbo].[ExamResult] ADD [UserId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.ExamResult', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.ExamResult', N'Score') IS NULL
BEGIN
    ALTER TABLE [dbo].[ExamResult] ADD [Score] decimal(5,2) NULL;
END
GO
IF OBJECT_ID(N'dbo.ExamResult', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.ExamResult', N'StartedAt') IS NULL
BEGIN
    ALTER TABLE [dbo].[ExamResult] ADD [StartedAt] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.ExamResult', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.ExamResult', N'FinishedAt') IS NULL
BEGIN
    ALTER TABLE [dbo].[ExamResult] ADD [FinishedAt] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.ExamResult', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.ExamResult', N'Status') IS NULL
BEGIN
    ALTER TABLE [dbo].[ExamResult] ADD [Status] tinyint NULL;
END
GO

IF OBJECT_ID(N'dbo.Question', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Question] (
        [QuestionId] int IDENTITY(1,1) NOT NULL,
        [ExamId] int NOT NULL,
        [Text] nvarchar(MAX) NOT NULL,
        [QuestionType] tinyint NOT NULL,
        [Points] int NOT NULL,
        [SortOrder] int NOT NULL,
        [IsActive] bit NULL
    );
END
GO
IF OBJECT_ID(N'dbo.Question', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Question', N'ExamId') IS NULL
BEGIN
    ALTER TABLE [dbo].[Question] ADD [ExamId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.Question', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Question', N'Text') IS NULL
BEGIN
    ALTER TABLE [dbo].[Question] ADD [Text] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.Question', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Question', N'QuestionType') IS NULL
BEGIN
    ALTER TABLE [dbo].[Question] ADD [QuestionType] tinyint NULL;
END
GO
IF OBJECT_ID(N'dbo.Question', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Question', N'Points') IS NULL
BEGIN
    ALTER TABLE [dbo].[Question] ADD [Points] int NULL;
END
GO
IF OBJECT_ID(N'dbo.Question', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Question', N'SortOrder') IS NULL
BEGIN
    ALTER TABLE [dbo].[Question] ADD [SortOrder] int NULL;
END
GO
IF OBJECT_ID(N'dbo.Question', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.Question', N'IsActive') IS NULL
BEGIN
    ALTER TABLE [dbo].[Question] ADD [IsActive] bit NULL;
END
GO

IF OBJECT_ID(N'dbo.QuestionMedia', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[QuestionMedia] (
        [MediaId] int IDENTITY(1,1) NOT NULL,
        [QuestionId] int NOT NULL,
        [MediaType] tinyint NOT NULL,
        [MediaPath] nvarchar(MAX) NOT NULL,
        [SortOrder] int NOT NULL,
        [CreatedAt] datetime NOT NULL
    );
END
GO
IF OBJECT_ID(N'dbo.QuestionMedia', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.QuestionMedia', N'QuestionId') IS NULL
BEGIN
    ALTER TABLE [dbo].[QuestionMedia] ADD [QuestionId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.QuestionMedia', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.QuestionMedia', N'MediaType') IS NULL
BEGIN
    ALTER TABLE [dbo].[QuestionMedia] ADD [MediaType] tinyint NULL;
END
GO
IF OBJECT_ID(N'dbo.QuestionMedia', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.QuestionMedia', N'MediaPath') IS NULL
BEGIN
    ALTER TABLE [dbo].[QuestionMedia] ADD [MediaPath] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.QuestionMedia', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.QuestionMedia', N'SortOrder') IS NULL
BEGIN
    ALTER TABLE [dbo].[QuestionMedia] ADD [SortOrder] int NULL;
END
GO
IF OBJECT_ID(N'dbo.QuestionMedia', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.QuestionMedia', N'CreatedAt') IS NULL
BEGIN
    ALTER TABLE [dbo].[QuestionMedia] ADD [CreatedAt] datetime NULL;
END
GO

IF OBJECT_ID(N'dbo.QuestionOption', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[QuestionOption] (
        [OptionId] int IDENTITY(1,1) NOT NULL,
        [QuestionId] int NOT NULL,
        [Text] nvarchar(MAX) NOT NULL,
        [IsCorrect] bit NOT NULL,
        [SortOrder] int NOT NULL
    );
END
GO
IF OBJECT_ID(N'dbo.QuestionOption', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.QuestionOption', N'QuestionId') IS NULL
BEGIN
    ALTER TABLE [dbo].[QuestionOption] ADD [QuestionId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.QuestionOption', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.QuestionOption', N'Text') IS NULL
BEGIN
    ALTER TABLE [dbo].[QuestionOption] ADD [Text] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.QuestionOption', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.QuestionOption', N'IsCorrect') IS NULL
BEGIN
    ALTER TABLE [dbo].[QuestionOption] ADD [IsCorrect] bit NULL;
END
GO
IF OBJECT_ID(N'dbo.QuestionOption', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.QuestionOption', N'SortOrder') IS NULL
BEGIN
    ALTER TABLE [dbo].[QuestionOption] ADD [SortOrder] int NULL;
END
GO

IF OBJECT_ID(N'dbo.SorguCevaplari', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[SorguCevaplari] (
        [Id] int IDENTITY(1,1) NOT NULL,
        [AnahtarKelimeler] nvarchar(200) NOT NULL,
        [Cevap] nvarchar(MAX) NOT NULL,
        [Kategori] nvarchar(100) NULL,
        [Aktif] bit NULL,
        [OlusturmaTarihi] datetime NULL,
        [ResimUrl] nvarchar(MAX) NULL
    );
END
GO
IF OBJECT_ID(N'dbo.SorguCevaplari', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.SorguCevaplari', N'AnahtarKelimeler') IS NULL
BEGIN
    ALTER TABLE [dbo].[SorguCevaplari] ADD [AnahtarKelimeler] nvarchar(200) NULL;
END
GO
IF OBJECT_ID(N'dbo.SorguCevaplari', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.SorguCevaplari', N'Cevap') IS NULL
BEGIN
    ALTER TABLE [dbo].[SorguCevaplari] ADD [Cevap] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.SorguCevaplari', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.SorguCevaplari', N'Kategori') IS NULL
BEGIN
    ALTER TABLE [dbo].[SorguCevaplari] ADD [Kategori] nvarchar(100) NULL;
END
GO
IF OBJECT_ID(N'dbo.SorguCevaplari', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.SorguCevaplari', N'Aktif') IS NULL
BEGIN
    ALTER TABLE [dbo].[SorguCevaplari] ADD [Aktif] bit NULL;
END
GO
IF OBJECT_ID(N'dbo.SorguCevaplari', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.SorguCevaplari', N'OlusturmaTarihi') IS NULL
BEGIN
    ALTER TABLE [dbo].[SorguCevaplari] ADD [OlusturmaTarihi] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.SorguCevaplari', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.SorguCevaplari', N'ResimUrl') IS NULL
BEGIN
    ALTER TABLE [dbo].[SorguCevaplari] ADD [ResimUrl] nvarchar(MAX) NULL;
END
GO

IF OBJECT_ID(N'dbo.SorguLoglari', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[SorguLoglari] (
        [Id] int IDENTITY(1,1) NOT NULL,
        [Soru] nvarchar(500) NOT NULL,
        [Cevap] nvarchar(1000) NULL,
        [KullaniciAdi] nvarchar(100) NULL,
        [IpAdresi] nvarchar(50) NULL,
        [Tarih] datetime NULL,
        [BasariDurumu] bit NULL
    );
END
GO
IF OBJECT_ID(N'dbo.SorguLoglari', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.SorguLoglari', N'Soru') IS NULL
BEGIN
    ALTER TABLE [dbo].[SorguLoglari] ADD [Soru] nvarchar(500) NULL;
END
GO
IF OBJECT_ID(N'dbo.SorguLoglari', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.SorguLoglari', N'Cevap') IS NULL
BEGIN
    ALTER TABLE [dbo].[SorguLoglari] ADD [Cevap] nvarchar(1000) NULL;
END
GO
IF OBJECT_ID(N'dbo.SorguLoglari', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.SorguLoglari', N'KullaniciAdi') IS NULL
BEGIN
    ALTER TABLE [dbo].[SorguLoglari] ADD [KullaniciAdi] nvarchar(100) NULL;
END
GO
IF OBJECT_ID(N'dbo.SorguLoglari', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.SorguLoglari', N'IpAdresi') IS NULL
BEGIN
    ALTER TABLE [dbo].[SorguLoglari] ADD [IpAdresi] nvarchar(50) NULL;
END
GO
IF OBJECT_ID(N'dbo.SorguLoglari', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.SorguLoglari', N'Tarih') IS NULL
BEGIN
    ALTER TABLE [dbo].[SorguLoglari] ADD [Tarih] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.SorguLoglari', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.SorguLoglari', N'BasariDurumu') IS NULL
BEGIN
    ALTER TABLE [dbo].[SorguLoglari] ADD [BasariDurumu] bit NULL;
END
GO

IF OBJECT_ID(N'dbo.TahditFormLog', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[TahditFormLog] (
        [Id] int IDENTITY(1,1) NOT NULL,
        [CreatedAt] datetime NOT NULL,
        [TahditCode] nvarchar(50) NULL,
        [IdariTahditCode] nvarchar(50) NULL,
        [PenaltyDay] int NOT NULL CONSTRAINT [DF_TahditFormLog_PenaltyDay] DEFAULT ((0)),
        [PenaltyMonth] int NOT NULL CONSTRAINT [DF_TahditFormLog_PenaltyMonth] DEFAULT ((0)),
        [PenaltyTotalDay] int NOT NULL CONSTRAINT [DF_TahditFormLog_PenaltyTotalDay] DEFAULT ((0)),
        [PaymentType] nvarchar(20) NULL,
        [VisaType] int NOT NULL CONSTRAINT [DF_TahditFormLog_VisaType] DEFAULT ((0)),
        [Country] nvarchar(150) NULL,
        [Border] nvarchar(150) NULL,
        [UserId] int NULL,
        [UserSicil] nvarchar(50) NULL,
        [UserDisplayName] nvarchar(200) NULL,
        [PassengerName] nvarchar(200) NULL,
        [PassportNo] nvarchar(80) NULL,
        [FormMoney] nvarchar(80) NULL
    );
END
GO
IF OBJECT_ID(N'dbo.TahditFormLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditFormLog', N'CreatedAt') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditFormLog] ADD [CreatedAt] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.TahditFormLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditFormLog', N'TahditCode') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditFormLog] ADD [TahditCode] nvarchar(50) NULL;
END
GO
IF OBJECT_ID(N'dbo.TahditFormLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditFormLog', N'IdariTahditCode') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditFormLog] ADD [IdariTahditCode] nvarchar(50) NULL;
END
GO
IF OBJECT_ID(N'dbo.TahditFormLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditFormLog', N'PenaltyDay') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditFormLog] ADD [PenaltyDay] int NULL DEFAULT ((0));
END
GO
IF OBJECT_ID(N'dbo.TahditFormLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditFormLog', N'PenaltyMonth') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditFormLog] ADD [PenaltyMonth] int NULL DEFAULT ((0));
END
GO
IF OBJECT_ID(N'dbo.TahditFormLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditFormLog', N'PenaltyTotalDay') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditFormLog] ADD [PenaltyTotalDay] int NULL DEFAULT ((0));
END
GO
IF OBJECT_ID(N'dbo.TahditFormLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditFormLog', N'PaymentType') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditFormLog] ADD [PaymentType] nvarchar(20) NULL;
END
GO
IF OBJECT_ID(N'dbo.TahditFormLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditFormLog', N'VisaType') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditFormLog] ADD [VisaType] int NULL DEFAULT ((0));
END
GO
IF OBJECT_ID(N'dbo.TahditFormLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditFormLog', N'Country') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditFormLog] ADD [Country] nvarchar(150) NULL;
END
GO
IF OBJECT_ID(N'dbo.TahditFormLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditFormLog', N'Border') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditFormLog] ADD [Border] nvarchar(150) NULL;
END
GO
IF OBJECT_ID(N'dbo.TahditFormLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditFormLog', N'UserId') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditFormLog] ADD [UserId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.TahditFormLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditFormLog', N'UserSicil') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditFormLog] ADD [UserSicil] nvarchar(50) NULL;
END
GO
IF OBJECT_ID(N'dbo.TahditFormLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditFormLog', N'UserDisplayName') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditFormLog] ADD [UserDisplayName] nvarchar(200) NULL;
END
GO
IF OBJECT_ID(N'dbo.TahditFormLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditFormLog', N'PassengerName') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditFormLog] ADD [PassengerName] nvarchar(200) NULL;
END
GO
IF OBJECT_ID(N'dbo.TahditFormLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditFormLog', N'PassportNo') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditFormLog] ADD [PassportNo] nvarchar(80) NULL;
END
GO
IF OBJECT_ID(N'dbo.TahditFormLog', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditFormLog', N'FormMoney') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditFormLog] ADD [FormMoney] nvarchar(80) NULL;
END
GO

IF OBJECT_ID(N'dbo.TahditKod', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[TahditKod] (
        [Id] int IDENTITY(1,1) NOT NULL,
        [Kod] nvarchar(MAX) NOT NULL,
        [Aciklama] nvarchar(MAX) NOT NULL,
        [SureAy] int NULL,
        [Aktif] bit NOT NULL,
        [GirisGelirse] nvarchar(MAX) NULL,
        [CikisGelirse] nvarchar(MAX) NULL,
        [TahditMedia] nvarchar(MAX) NULL,
        [CreatedAt] datetime NULL,
        [CreatedByUserId] int NULL,
        [CreatedBySicil] nvarchar(50) NULL,
        [CreatedByName] nvarchar(200) NULL
    );
END
GO
IF OBJECT_ID(N'dbo.TahditKod', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditKod', N'Kod') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditKod] ADD [Kod] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.TahditKod', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditKod', N'Aciklama') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditKod] ADD [Aciklama] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.TahditKod', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditKod', N'SureAy') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditKod] ADD [SureAy] int NULL;
END
GO
IF OBJECT_ID(N'dbo.TahditKod', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditKod', N'Aktif') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditKod] ADD [Aktif] bit NULL;
END
GO
IF OBJECT_ID(N'dbo.TahditKod', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditKod', N'GirisGelirse') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditKod] ADD [GirisGelirse] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.TahditKod', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditKod', N'CikisGelirse') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditKod] ADD [CikisGelirse] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.TahditKod', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditKod', N'TahditMedia') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditKod] ADD [TahditMedia] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.TahditKod', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditKod', N'CreatedAt') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditKod] ADD [CreatedAt] datetime NULL;
END
GO
IF OBJECT_ID(N'dbo.TahditKod', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditKod', N'CreatedByUserId') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditKod] ADD [CreatedByUserId] int NULL;
END
GO
IF OBJECT_ID(N'dbo.TahditKod', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditKod', N'CreatedBySicil') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditKod] ADD [CreatedBySicil] nvarchar(50) NULL;
END
GO
IF OBJECT_ID(N'dbo.TahditKod', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.TahditKod', N'CreatedByName') IS NULL
BEGIN
    ALTER TABLE [dbo].[TahditKod] ADD [CreatedByName] nvarchar(200) NULL;
END
GO

IF OBJECT_ID(N'dbo.tbl_TempUser', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[tbl_TempUser] (
        [fldId] int IDENTITY(1,1) NOT NULL,
        [fldSicil] nvarchar(MAX) NULL,
        [fldName] nvarchar(MAX) NULL,
        [fldLastName] nvarchar(MAX) NULL,
        [fldPhone] nvarchar(MAX) NULL,
        [fldEmail] nvarchar(MAX) NULL,
        [fldTitle] nvarchar(MAX) NULL,
        [fldDeputy] nvarchar(MAX) NULL
    );
END
GO
IF OBJECT_ID(N'dbo.tbl_TempUser', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.tbl_TempUser', N'fldSicil') IS NULL
BEGIN
    ALTER TABLE [dbo].[tbl_TempUser] ADD [fldSicil] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.tbl_TempUser', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.tbl_TempUser', N'fldName') IS NULL
BEGIN
    ALTER TABLE [dbo].[tbl_TempUser] ADD [fldName] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.tbl_TempUser', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.tbl_TempUser', N'fldLastName') IS NULL
BEGIN
    ALTER TABLE [dbo].[tbl_TempUser] ADD [fldLastName] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.tbl_TempUser', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.tbl_TempUser', N'fldPhone') IS NULL
BEGIN
    ALTER TABLE [dbo].[tbl_TempUser] ADD [fldPhone] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.tbl_TempUser', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.tbl_TempUser', N'fldEmail') IS NULL
BEGIN
    ALTER TABLE [dbo].[tbl_TempUser] ADD [fldEmail] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.tbl_TempUser', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.tbl_TempUser', N'fldTitle') IS NULL
BEGIN
    ALTER TABLE [dbo].[tbl_TempUser] ADD [fldTitle] nvarchar(MAX) NULL;
END
GO
IF OBJECT_ID(N'dbo.tbl_TempUser', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.tbl_TempUser', N'fldDeputy') IS NULL
BEGIN
    ALTER TABLE [dbo].[tbl_TempUser] ADD [fldDeputy] nvarchar(MAX) NULL;
END
GO

IF OBJECT_ID(N'dbo.PK___MigrationHistory', N'PK') IS NULL AND OBJECT_ID(N'dbo.__MigrationHistory', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[__MigrationHistory] ADD CONSTRAINT [PK___MigrationHistory] PRIMARY KEY ([MigrationId]);
END
GO
IF OBJECT_ID(N'dbo.PK_Airline', N'PK') IS NULL AND OBJECT_ID(N'dbo.Airline', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[Airline] ADD CONSTRAINT [PK_Airline] PRIMARY KEY ([Id]);
END
GO
IF OBJECT_ID(N'dbo.PK_Answer', N'PK') IS NULL AND OBJECT_ID(N'dbo.Answer', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[Answer] ADD CONSTRAINT [PK_Answer] PRIMARY KEY ([AnswerId]);
END
GO
IF OBJECT_ID(N'dbo.PK_Categories', N'PK') IS NULL AND OBJECT_ID(N'dbo.Categories', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[Categories] ADD CONSTRAINT [PK_Categories] PRIMARY KEY ([CategoryId]);
END
GO
IF OBJECT_ID(N'dbo.PK_Certificate', N'PK') IS NULL AND OBJECT_ID(N'dbo.Certificate', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[Certificate] ADD CONSTRAINT [PK_Certificate] PRIMARY KEY ([CertificateId]);
END
GO
IF OBJECT_ID(N'dbo.PK_CertificateRequest', N'PK') IS NULL AND OBJECT_ID(N'dbo.CertificateRequest', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[CertificateRequest] ADD CONSTRAINT [PK_CertificateRequest] PRIMARY KEY ([RequestId]);
END
GO
IF OBJECT_ID(N'dbo.PK_ChatMessages', N'PK') IS NULL AND OBJECT_ID(N'dbo.ChatMessages', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[ChatMessages] ADD CONSTRAINT [PK_ChatMessages] PRIMARY KEY ([ChatMessageId]);
END
GO
IF OBJECT_ID(N'dbo.PK_ChatOnlineUsers', N'PK') IS NULL AND OBJECT_ID(N'dbo.ChatOnlineUsers', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[ChatOnlineUsers] ADD CONSTRAINT [PK_ChatOnlineUsers] PRIMARY KEY ([UserId]);
END
GO
IF OBJECT_ID(N'dbo.PK_CourseContents', N'PK') IS NULL AND OBJECT_ID(N'dbo.CourseContents', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[CourseContents] ADD CONSTRAINT [PK_CourseContents] PRIMARY KEY ([ContentId]);
END
GO
IF OBJECT_ID(N'dbo.PK_CourseEnrollments', N'PK') IS NULL AND OBJECT_ID(N'dbo.CourseEnrollments', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[CourseEnrollments] ADD CONSTRAINT [PK_CourseEnrollments] PRIMARY KEY ([EnrollmentId]);
END
GO
IF OBJECT_ID(N'dbo.PK_CourseReviews', N'PK') IS NULL AND OBJECT_ID(N'dbo.CourseReviews', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[CourseReviews] ADD CONSTRAINT [PK_CourseReviews] PRIMARY KEY ([ReviewId]);
END
GO
IF OBJECT_ID(N'dbo.PK_Courses', N'PK') IS NULL AND OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[Courses] ADD CONSTRAINT [PK_Courses] PRIMARY KEY ([CourseId]);
END
GO
IF OBJECT_ID(N'dbo.PK_DocumentTerms', N'PK') IS NULL AND OBJECT_ID(N'dbo.DocumentTerms', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[DocumentTerms] ADD CONSTRAINT [PK_DocumentTerms] PRIMARY KEY ([Id]);
END
GO
IF OBJECT_ID(N'dbo.PK_E_AUH', N'PK') IS NULL AND OBJECT_ID(N'dbo.E_AUH', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[E_AUH] ADD CONSTRAINT [PK_E_AUH] PRIMARY KEY ([fldId]);
END
GO
IF OBJECT_ID(N'dbo.PK_E_Border', N'PK') IS NULL AND OBJECT_ID(N'dbo.E_Border', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[E_Border] ADD CONSTRAINT [PK_E_Border] PRIMARY KEY ([fldId]);
END
GO
IF OBJECT_ID(N'dbo.PK_E_Defter', N'PK') IS NULL AND OBJECT_ID(N'dbo.E_Defter', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[E_Defter] ADD CONSTRAINT [PK_E_Defter] PRIMARY KEY ([fldId]);
END
GO
IF OBJECT_ID(N'dbo.PK_E_DilekceGirisCikis', N'PK') IS NULL AND OBJECT_ID(N'dbo.E_Dilekce', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[E_Dilekce] ADD CONSTRAINT [PK_E_DilekceGirisCikis] PRIMARY KEY ([DilekceId]);
END
GO
IF OBJECT_ID(N'dbo.PK_E_Exchange', N'PK') IS NULL AND OBJECT_ID(N'dbo.E_Exchange', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[E_Exchange] ADD CONSTRAINT [PK_E_Exchange] PRIMARY KEY ([fldId]);
END
GO
IF OBJECT_ID(N'dbo.PK_E_Forms', N'PK') IS NULL AND OBJECT_ID(N'dbo.E_Forms', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[E_Forms] ADD CONSTRAINT [PK_E_Forms] PRIMARY KEY ([fldId]);
END
GO
IF OBJECT_ID(N'dbo.PK_E_History', N'PK') IS NULL AND OBJECT_ID(N'dbo.E_History', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[E_History] ADD CONSTRAINT [PK_E_History] PRIMARY KEY ([fldId]);
END
GO
IF OBJECT_ID(N'dbo.PK_E_Inad', N'PK') IS NULL AND OBJECT_ID(N'dbo.E_Inad', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[E_Inad] ADD CONSTRAINT [PK_E_Inad] PRIMARY KEY ([InadId]);
END
GO
IF OBJECT_ID(N'dbo.PK_E_IsK', N'PK') IS NULL AND OBJECT_ID(N'dbo.E_IsK', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[E_IsK] ADD CONSTRAINT [PK_E_IsK] PRIMARY KEY ([fldId]);
END
GO
IF OBJECT_ID(N'dbo.PK_E_Messages', N'PK') IS NULL AND OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[E_Messages] ADD CONSTRAINT [PK_E_Messages] PRIMARY KEY ([fldId]);
END
GO
IF OBJECT_ID(N'dbo.PK_E_Sartli', N'PK') IS NULL AND OBJECT_ID(N'dbo.E_Sartli', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[E_Sartli] ADD CONSTRAINT [PK_E_Sartli] PRIMARY KEY ([fldId]);
END
GO
IF OBJECT_ID(N'dbo.PK_E_TGVH', N'PK') IS NULL AND OBJECT_ID(N'dbo.E_TGVH', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[E_TGVH] ADD CONSTRAINT [PK_E_TGVH] PRIMARY KEY ([fldId]);
END
GO
IF OBJECT_ID(N'dbo.PK_E_TKOD', N'PK') IS NULL AND OBJECT_ID(N'dbo.E_TKOD', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[E_TKOD] ADD CONSTRAINT [PK_E_TKOD] PRIMARY KEY ([fldId]);
END
GO
IF OBJECT_ID(N'dbo.PK_E_Token', N'PK') IS NULL AND OBJECT_ID(N'dbo.E_Token', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[E_Token] ADD CONSTRAINT [PK_E_Token] PRIMARY KEY ([fldId]);
END
GO
IF OBJECT_ID(N'dbo.PK_E_User', N'PK') IS NULL AND OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[E_User] ADD CONSTRAINT [PK_E_User] PRIMARY KEY ([fldId]);
END
GO
IF OBJECT_ID(N'dbo.PK_E_UVR', N'PK') IS NULL AND OBJECT_ID(N'dbo.E_UVR', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[E_UVR] ADD CONSTRAINT [PK_E_UVR] PRIMARY KEY ([fldId]);
END
GO
IF OBJECT_ID(N'dbo.PK_EducationPackageImportLog', N'PK') IS NULL AND OBJECT_ID(N'dbo.EducationPackageImportLog', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[EducationPackageImportLog] ADD CONSTRAINT [PK_EducationPackageImportLog] PRIMARY KEY ([Id]);
END
GO
IF OBJECT_ID(N'dbo.PK_Exam', N'PK') IS NULL AND OBJECT_ID(N'dbo.Exam', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[Exam] ADD CONSTRAINT [PK_Exam] PRIMARY KEY ([ExamId]);
END
GO
IF OBJECT_ID(N'dbo.PK_ExamResult', N'PK') IS NULL AND OBJECT_ID(N'dbo.ExamResult', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[ExamResult] ADD CONSTRAINT [PK_ExamResult] PRIMARY KEY ([ExamResultId]);
END
GO
IF OBJECT_ID(N'dbo.PK_Question', N'PK') IS NULL AND OBJECT_ID(N'dbo.Question', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[Question] ADD CONSTRAINT [PK_Question] PRIMARY KEY ([QuestionId]);
END
GO
IF OBJECT_ID(N'dbo.PK_QuestionMedia', N'PK') IS NULL AND OBJECT_ID(N'dbo.QuestionMedia', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[QuestionMedia] ADD CONSTRAINT [PK_QuestionMedia] PRIMARY KEY ([MediaId]);
END
GO
IF OBJECT_ID(N'dbo.PK_QuestionOption', N'PK') IS NULL AND OBJECT_ID(N'dbo.QuestionOption', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[QuestionOption] ADD CONSTRAINT [PK_QuestionOption] PRIMARY KEY ([OptionId]);
END
GO
IF OBJECT_ID(N'dbo.PK_SorguCevaplari', N'PK') IS NULL AND OBJECT_ID(N'dbo.SorguCevaplari', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[SorguCevaplari] ADD CONSTRAINT [PK_SorguCevaplari] PRIMARY KEY ([Id]);
END
GO
IF OBJECT_ID(N'dbo.PK_SorguLoglari', N'PK') IS NULL AND OBJECT_ID(N'dbo.SorguLoglari', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[SorguLoglari] ADD CONSTRAINT [PK_SorguLoglari] PRIMARY KEY ([Id]);
END
GO
IF OBJECT_ID(N'dbo.PK_TahditFormLog', N'PK') IS NULL AND OBJECT_ID(N'dbo.TahditFormLog', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[TahditFormLog] ADD CONSTRAINT [PK_TahditFormLog] PRIMARY KEY ([Id]);
END
GO
IF OBJECT_ID(N'dbo.PK_TahditKod', N'PK') IS NULL AND OBJECT_ID(N'dbo.TahditKod', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[TahditKod] ADD CONSTRAINT [PK_TahditKod] PRIMARY KEY ([Id]);
END
GO
IF OBJECT_ID(N'dbo.PK_tbl_TempUser', N'PK') IS NULL AND OBJECT_ID(N'dbo.tbl_TempUser', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[tbl_TempUser] ADD CONSTRAINT [PK_tbl_TempUser] PRIMARY KEY ([fldId]);
END
GO
IF OBJECT_ID(N'dbo.FK_Answer_ExamResult', N'F') IS NULL AND OBJECT_ID(N'dbo.Answer', N'U') IS NOT NULL AND OBJECT_ID(N'dbo.ExamResult', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[Answer] WITH NOCHECK ADD CONSTRAINT [FK_Answer_ExamResult] FOREIGN KEY ([ExamResultId]) REFERENCES [dbo].[ExamResult] ([ExamResultId]);
    ALTER TABLE [dbo].[Answer] CHECK CONSTRAINT [FK_Answer_ExamResult];
END
GO
IF OBJECT_ID(N'dbo.FK_Answer_Option', N'F') IS NULL AND OBJECT_ID(N'dbo.Answer', N'U') IS NOT NULL AND OBJECT_ID(N'dbo.QuestionOption', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[Answer] WITH NOCHECK ADD CONSTRAINT [FK_Answer_Option] FOREIGN KEY ([OptionId]) REFERENCES [dbo].[QuestionOption] ([OptionId]);
    ALTER TABLE [dbo].[Answer] CHECK CONSTRAINT [FK_Answer_Option];
END
GO
IF OBJECT_ID(N'dbo.FK_Answer_Question', N'F') IS NULL AND OBJECT_ID(N'dbo.Answer', N'U') IS NOT NULL AND OBJECT_ID(N'dbo.Question', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[Answer] WITH NOCHECK ADD CONSTRAINT [FK_Answer_Question] FOREIGN KEY ([QuestionId]) REFERENCES [dbo].[Question] ([QuestionId]);
    ALTER TABLE [dbo].[Answer] CHECK CONSTRAINT [FK_Answer_Question];
END
GO
IF OBJECT_ID(N'dbo.FK_Certificate_Course', N'F') IS NULL AND OBJECT_ID(N'dbo.Certificate', N'U') IS NOT NULL AND OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[Certificate] WITH NOCHECK ADD CONSTRAINT [FK_Certificate_Course] FOREIGN KEY ([CourseId]) REFERENCES [dbo].[Courses] ([CourseId]);
    ALTER TABLE [dbo].[Certificate] CHECK CONSTRAINT [FK_Certificate_Course];
END
GO
IF OBJECT_ID(N'dbo.FK_Certificate_ExamResult', N'F') IS NULL AND OBJECT_ID(N'dbo.Certificate', N'U') IS NOT NULL AND OBJECT_ID(N'dbo.ExamResult', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[Certificate] WITH NOCHECK ADD CONSTRAINT [FK_Certificate_ExamResult] FOREIGN KEY ([ExamResultId]) REFERENCES [dbo].[ExamResult] ([ExamResultId]);
    ALTER TABLE [dbo].[Certificate] CHECK CONSTRAINT [FK_Certificate_ExamResult];
END
GO
IF OBJECT_ID(N'dbo.FK_Certificate_User', N'F') IS NULL AND OBJECT_ID(N'dbo.Certificate', N'U') IS NOT NULL AND OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[Certificate] WITH NOCHECK ADD CONSTRAINT [FK_Certificate_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[E_User] ([fldId]);
    ALTER TABLE [dbo].[Certificate] CHECK CONSTRAINT [FK_Certificate_User];
END
GO
IF OBJECT_ID(N'dbo.FK_CourseContents_Course', N'F') IS NULL AND OBJECT_ID(N'dbo.CourseContents', N'U') IS NOT NULL AND OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[CourseContents] WITH NOCHECK ADD CONSTRAINT [FK_CourseContents_Course] FOREIGN KEY ([CourseId]) REFERENCES [dbo].[Courses] ([CourseId]);
    ALTER TABLE [dbo].[CourseContents] CHECK CONSTRAINT [FK_CourseContents_Course];
END
GO
IF OBJECT_ID(N'dbo.FK_CourseEnrollments_Course', N'F') IS NULL AND OBJECT_ID(N'dbo.CourseEnrollments', N'U') IS NOT NULL AND OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[CourseEnrollments] WITH NOCHECK ADD CONSTRAINT [FK_CourseEnrollments_Course] FOREIGN KEY ([CourseId]) REFERENCES [dbo].[Courses] ([CourseId]);
    ALTER TABLE [dbo].[CourseEnrollments] CHECK CONSTRAINT [FK_CourseEnrollments_Course];
END
GO
IF OBJECT_ID(N'dbo.FK_CourseEnrollments_User', N'F') IS NULL AND OBJECT_ID(N'dbo.CourseEnrollments', N'U') IS NOT NULL AND OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[CourseEnrollments] WITH NOCHECK ADD CONSTRAINT [FK_CourseEnrollments_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[E_User] ([fldId]);
    ALTER TABLE [dbo].[CourseEnrollments] CHECK CONSTRAINT [FK_CourseEnrollments_User];
END
GO
IF OBJECT_ID(N'dbo.FK_CourseReviews_ApprovedBy', N'F') IS NULL AND OBJECT_ID(N'dbo.CourseReviews', N'U') IS NOT NULL AND OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[CourseReviews] WITH NOCHECK ADD CONSTRAINT [FK_CourseReviews_ApprovedBy] FOREIGN KEY ([ApprovedBy]) REFERENCES [dbo].[E_User] ([fldId]);
    ALTER TABLE [dbo].[CourseReviews] CHECK CONSTRAINT [FK_CourseReviews_ApprovedBy];
END
GO
IF OBJECT_ID(N'dbo.FK_CourseReviews_Course', N'F') IS NULL AND OBJECT_ID(N'dbo.CourseReviews', N'U') IS NOT NULL AND OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[CourseReviews] WITH NOCHECK ADD CONSTRAINT [FK_CourseReviews_Course] FOREIGN KEY ([CourseId]) REFERENCES [dbo].[Courses] ([CourseId]);
    ALTER TABLE [dbo].[CourseReviews] CHECK CONSTRAINT [FK_CourseReviews_Course];
END
GO
IF OBJECT_ID(N'dbo.FK_CourseReviews_User', N'F') IS NULL AND OBJECT_ID(N'dbo.CourseReviews', N'U') IS NOT NULL AND OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[CourseReviews] WITH NOCHECK ADD CONSTRAINT [FK_CourseReviews_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[E_User] ([fldId]);
    ALTER TABLE [dbo].[CourseReviews] CHECK CONSTRAINT [FK_CourseReviews_User];
END
GO
IF OBJECT_ID(N'dbo.FK_Courses_Category', N'F') IS NULL AND OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL AND OBJECT_ID(N'dbo.Categories', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[Courses] WITH NOCHECK ADD CONSTRAINT [FK_Courses_Category] FOREIGN KEY ([CategoryId]) REFERENCES [dbo].[Categories] ([CategoryId]);
    ALTER TABLE [dbo].[Courses] CHECK CONSTRAINT [FK_Courses_Category];
END
GO
IF OBJECT_ID(N'dbo.FK_Courses_CreatedBy', N'F') IS NULL AND OBJECT_ID(N'dbo.Courses', N'U') IS NOT NULL AND OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[Courses] WITH NOCHECK ADD CONSTRAINT [FK_Courses_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[E_User] ([fldId]);
    ALTER TABLE [dbo].[Courses] CHECK CONSTRAINT [FK_Courses_CreatedBy];
END
GO
IF OBJECT_ID(N'dbo.FK_E_Messages_ApprovedBy', N'F') IS NULL AND OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[E_Messages] WITH NOCHECK ADD CONSTRAINT [FK_E_Messages_ApprovedBy] FOREIGN KEY ([fldApprovedBy]) REFERENCES [dbo].[E_User] ([fldId]);
    ALTER TABLE [dbo].[E_Messages] CHECK CONSTRAINT [FK_E_Messages_ApprovedBy];
END
GO
IF OBJECT_ID(N'dbo.FK_E_Messages_Parent', N'F') IS NULL AND OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[E_Messages] WITH NOCHECK ADD CONSTRAINT [FK_E_Messages_Parent] FOREIGN KEY ([fldParentMessageId]) REFERENCES [dbo].[E_Messages] ([fldId]);
    ALTER TABLE [dbo].[E_Messages] CHECK CONSTRAINT [FK_E_Messages_Parent];
END
GO
IF OBJECT_ID(N'dbo.FK_E_Messages_Recipient', N'F') IS NULL AND OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[E_Messages] WITH NOCHECK ADD CONSTRAINT [FK_E_Messages_Recipient] FOREIGN KEY ([fldRecipientId]) REFERENCES [dbo].[E_User] ([fldId]);
    ALTER TABLE [dbo].[E_Messages] CHECK CONSTRAINT [FK_E_Messages_Recipient];
END
GO
IF OBJECT_ID(N'dbo.FK_E_Messages_Sender', N'F') IS NULL AND OBJECT_ID(N'dbo.E_Messages', N'U') IS NOT NULL AND OBJECT_ID(N'dbo.E_User', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[E_Messages] WITH NOCHECK ADD CONSTRAINT [FK_E_Messages_Sender] FOREIGN KEY ([fldSenderId]) REFERENCES [dbo].[E_User] ([fldId]);
    ALTER TABLE [dbo].[E_Messages] CHECK CONSTRAINT [FK_E_Messages_Sender];
END
GO
IF OBJECT_ID(N'dbo.FK_ExamResult_Exam', N'F') IS NULL AND OBJECT_ID(N'dbo.ExamResult', N'U') IS NOT NULL AND OBJECT_ID(N'dbo.Exam', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[ExamResult] WITH NOCHECK ADD CONSTRAINT [FK_ExamResult_Exam] FOREIGN KEY ([ExamId]) REFERENCES [dbo].[Exam] ([ExamId]);
    ALTER TABLE [dbo].[ExamResult] CHECK CONSTRAINT [FK_ExamResult_Exam];
END
GO
IF OBJECT_ID(N'dbo.FK_Question_Exam', N'F') IS NULL AND OBJECT_ID(N'dbo.Question', N'U') IS NOT NULL AND OBJECT_ID(N'dbo.Exam', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[Question] WITH NOCHECK ADD CONSTRAINT [FK_Question_Exam] FOREIGN KEY ([ExamId]) REFERENCES [dbo].[Exam] ([ExamId]);
    ALTER TABLE [dbo].[Question] CHECK CONSTRAINT [FK_Question_Exam];
END
GO
IF OBJECT_ID(N'dbo.FK_QuestionMedia_Question', N'F') IS NULL AND OBJECT_ID(N'dbo.QuestionMedia', N'U') IS NOT NULL AND OBJECT_ID(N'dbo.Question', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[QuestionMedia] WITH NOCHECK ADD CONSTRAINT [FK_QuestionMedia_Question] FOREIGN KEY ([QuestionId]) REFERENCES [dbo].[Question] ([QuestionId]);
    ALTER TABLE [dbo].[QuestionMedia] CHECK CONSTRAINT [FK_QuestionMedia_Question];
END
GO
IF OBJECT_ID(N'dbo.FK_QuestionOption_Question', N'F') IS NULL AND OBJECT_ID(N'dbo.QuestionOption', N'U') IS NOT NULL AND OBJECT_ID(N'dbo.Question', N'U') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[QuestionOption] WITH NOCHECK ADD CONSTRAINT [FK_QuestionOption_Question] FOREIGN KEY ([QuestionId]) REFERENCES [dbo].[Question] ([QuestionId]);
    ALTER TABLE [dbo].[QuestionOption] CHECK CONSTRAINT [FK_QuestionOption_Question];
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_FK_Answer_ExamResult' AND object_id=OBJECT_ID(N'dbo.Answer'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_FK_Answer_ExamResult] ON [dbo].[Answer] ([ExamResultId] ASC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_FK_Answer_Option' AND object_id=OBJECT_ID(N'dbo.Answer'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_FK_Answer_Option] ON [dbo].[Answer] ([OptionId] ASC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_FK_Answer_Question' AND object_id=OBJECT_ID(N'dbo.Answer'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_FK_Answer_Question] ON [dbo].[Answer] ([QuestionId] ASC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_FK_Certificate_Course' AND object_id=OBJECT_ID(N'dbo.Certificate'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_FK_Certificate_Course] ON [dbo].[Certificate] ([CourseId] ASC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_FK_Certificate_ExamResult' AND object_id=OBJECT_ID(N'dbo.Certificate'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_FK_Certificate_ExamResult] ON [dbo].[Certificate] ([ExamResultId] ASC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_FK_Certificate_User' AND object_id=OBJECT_ID(N'dbo.Certificate'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_FK_Certificate_User] ON [dbo].[Certificate] ([UserId] ASC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_ChatMessages_Pair' AND object_id=OBJECT_ID(N'dbo.ChatMessages'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_ChatMessages_Pair] ON [dbo].[ChatMessages] ([SenderId] ASC, [RecipientId] ASC, [ChatMessageId] ASC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_ChatMessages_RecipientRead' AND object_id=OBJECT_ID(N'dbo.ChatMessages'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_ChatMessages_RecipientRead] ON [dbo].[ChatMessages] ([RecipientId] ASC, [ReadAt] ASC, [ChatMessageId] ASC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_ChatMessages_Room' AND object_id=OBJECT_ID(N'dbo.ChatMessages'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_ChatMessages_Room] ON [dbo].[ChatMessages] ([RecipientId] ASC, [ChatMessageId] ASC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_ChatOnlineUsers_LastSeen' AND object_id=OBJECT_ID(N'dbo.ChatOnlineUsers'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_ChatOnlineUsers_LastSeen] ON [dbo].[ChatOnlineUsers] ([LastSeen] DESC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_FK_CourseContents_Course' AND object_id=OBJECT_ID(N'dbo.CourseContents'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_FK_CourseContents_Course] ON [dbo].[CourseContents] ([CourseId] ASC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_FK_CourseEnrollments_Course' AND object_id=OBJECT_ID(N'dbo.CourseEnrollments'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_FK_CourseEnrollments_Course] ON [dbo].[CourseEnrollments] ([CourseId] ASC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_FK_CourseEnrollments_User' AND object_id=OBJECT_ID(N'dbo.CourseEnrollments'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_FK_CourseEnrollments_User] ON [dbo].[CourseEnrollments] ([UserId] ASC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_FK_CourseReviews_ApprovedBy' AND object_id=OBJECT_ID(N'dbo.CourseReviews'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_FK_CourseReviews_ApprovedBy] ON [dbo].[CourseReviews] ([ApprovedBy] ASC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_FK_CourseReviews_Course' AND object_id=OBJECT_ID(N'dbo.CourseReviews'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_FK_CourseReviews_Course] ON [dbo].[CourseReviews] ([CourseId] ASC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_FK_CourseReviews_User' AND object_id=OBJECT_ID(N'dbo.CourseReviews'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_FK_CourseReviews_User] ON [dbo].[CourseReviews] ([UserId] ASC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_FK_Courses_Category' AND object_id=OBJECT_ID(N'dbo.Courses'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_FK_Courses_Category] ON [dbo].[Courses] ([CategoryId] ASC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_FK_Courses_CreatedBy' AND object_id=OBJECT_ID(N'dbo.Courses'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_FK_Courses_CreatedBy] ON [dbo].[Courses] ([CreatedBy] ASC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_E_Messages_DateTime' AND object_id=OBJECT_ID(N'dbo.E_Messages'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_E_Messages_DateTime] ON [dbo].[E_Messages] ([fldDateTime] DESC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_E_Messages_ParentMessageId' AND object_id=OBJECT_ID(N'dbo.E_Messages'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_E_Messages_ParentMessageId] ON [dbo].[E_Messages] ([fldParentMessageId] ASC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_E_Messages_RecipientId' AND object_id=OBJECT_ID(N'dbo.E_Messages'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_E_Messages_RecipientId] ON [dbo].[E_Messages] ([fldRecipientId] ASC) INCLUDE ([fldDateTime], [fldIsDeletedByRecipient], [fldIsRead]);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_E_Messages_SenderId' AND object_id=OBJECT_ID(N'dbo.E_Messages'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_E_Messages_SenderId] ON [dbo].[E_Messages] ([fldSenderId] ASC) INCLUDE ([fldDateTime], [fldIsDeletedBySender]);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_EducationPackageImportLog_Date' AND object_id=OBJECT_ID(N'dbo.EducationPackageImportLog'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_EducationPackageImportLog_Date] ON [dbo].[EducationPackageImportLog] ([ImportedDate] DESC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_EducationPackageImportLog_Package' AND object_id=OBJECT_ID(N'dbo.EducationPackageImportLog'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_EducationPackageImportLog_Package] ON [dbo].[EducationPackageImportLog] ([PackageCode] ASC, [PackageVersion] ASC, [Status] ASC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_FK_ExamResult_Exam' AND object_id=OBJECT_ID(N'dbo.ExamResult'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_FK_ExamResult_Exam] ON [dbo].[ExamResult] ([ExamId] ASC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_FK_Question_Exam' AND object_id=OBJECT_ID(N'dbo.Question'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_FK_Question_Exam] ON [dbo].[Question] ([ExamId] ASC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_FK_QuestionMedia_Question' AND object_id=OBJECT_ID(N'dbo.QuestionMedia'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_FK_QuestionMedia_Question] ON [dbo].[QuestionMedia] ([QuestionId] ASC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_FK_QuestionOption_Question' AND object_id=OBJECT_ID(N'dbo.QuestionOption'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_FK_QuestionOption_Question] ON [dbo].[QuestionOption] ([QuestionId] ASC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_TahditFormLog_BorderCreatedAt' AND object_id=OBJECT_ID(N'dbo.TahditFormLog'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_TahditFormLog_BorderCreatedAt] ON [dbo].[TahditFormLog] ([Border] ASC, [CreatedAt] ASC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_TahditFormLog_CodeCreatedAt' AND object_id=OBJECT_ID(N'dbo.TahditFormLog'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_TahditFormLog_CodeCreatedAt] ON [dbo].[TahditFormLog] ([TahditCode] ASC, [CreatedAt] ASC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_TahditFormLog_CreatedAt' AND object_id=OBJECT_ID(N'dbo.TahditFormLog'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_TahditFormLog_CreatedAt] ON [dbo].[TahditFormLog] ([CreatedAt] ASC);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_TahditFormLog_UserCreatedAt' AND object_id=OBJECT_ID(N'dbo.TahditFormLog'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_TahditFormLog_UserCreatedAt] ON [dbo].[TahditFormLog] ([UserId] ASC, [UserSicil] ASC, [CreatedAt] ASC);
END
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
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_PasswordResetRequests_StatusRequestedAt' AND object_id=OBJECT_ID(N'dbo.PasswordResetRequests'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_PasswordResetRequests_StatusRequestedAt]
        ON [dbo].[PasswordResetRequests] ([Status] ASC, [RequestedAt] ASC);
END
GO
PRINT N'CEZA güvenli şema senkronizasyonu tamamlandı.';
