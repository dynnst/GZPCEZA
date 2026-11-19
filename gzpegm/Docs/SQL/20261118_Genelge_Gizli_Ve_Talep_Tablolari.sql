-- CEZAM - Genelgeler Gizli Belge & Talep Yonetim Tablolari
-- Olusturma Tarihi: 18 Kasim 2026

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'E_GenelgeGizli')
BEGIN
    CREATE TABLE E_GenelgeGizli (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        ItemIdentifier NVARCHAR(300) NOT NULL UNIQUE,
        IsConfidential BIT NOT NULL DEFAULT 1,
        MarkedByUserId INT NULL,
        MarkedDate DATETIME NOT NULL DEFAULT GETDATE(),
        Note NVARCHAR(500) NULL
    );
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'E_GenelgeTalep')
BEGIN
    CREATE TABLE E_GenelgeTalep (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        ItemIdentifier NVARCHAR(300) NOT NULL,
        ItemTitle NVARCHAR(500) NOT NULL,
        UserId INT NOT NULL,
        UserSicil NVARCHAR(50) NULL,
        UserName NVARCHAR(150) NULL,
        RequestDate DATETIME NOT NULL DEFAULT GETDATE(),
        Reason NVARCHAR(1000) NULL,
        Status NVARCHAR(30) NOT NULL DEFAULT 'Bekliyor', -- 'Bekliyor', 'Onaylandi', 'Reddedildi'
        ReviewedByUserId INT NULL,
        ReviewDate DATETIME NULL,
        ExpiryDate DATETIME NULL,
        ReviewNote NVARCHAR(500) NULL
    );
    CREATE INDEX IX_GenelgeTalep_User ON E_GenelgeTalep(UserId, ItemIdentifier, Status);
END
GO
