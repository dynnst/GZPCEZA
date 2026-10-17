SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'dbo.EducationPackageImportLog', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.EducationPackageImportLog
    (
        Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_EducationPackageImportLog PRIMARY KEY,
        PackageCode NVARCHAR(100) NULL,
        PackageTitle NVARCHAR(300) NULL,
        PackageVersion NVARCHAR(30) NULL,
        SourceDocumentCode NVARCHAR(100) NULL,
        ImportedCourseId INT NULL,
        ImportedExamId INT NULL,
        ImportedByUserId INT NOT NULL,
        ImportedDate DATETIME NOT NULL CONSTRAINT DF_EducationPackageImportLog_ImportedDate DEFAULT(GETDATE()),
        FileName NVARCHAR(260) NULL,
        Status NVARCHAR(30) NOT NULL,
        Message NVARCHAR(2000) NULL
    );

    CREATE INDEX IX_EducationPackageImportLog_Package
        ON dbo.EducationPackageImportLog(PackageCode, PackageVersion, Status);
    CREATE INDEX IX_EducationPackageImportLog_Date
        ON dbo.EducationPackageImportLog(ImportedDate DESC);
END;
