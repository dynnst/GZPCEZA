/*
    Tahdit form istatistikleri icin log tablosu.

    Guvenli calisir:
    - Tablo yoksa olusturur.
    - Tablo varsa veriye dokunmaz.
    - Eksik indeksleri varsa ekler.
*/

IF OBJECT_ID(N'dbo.TahditFormLog', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TahditFormLog
    (
        Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TahditFormLog PRIMARY KEY,
        CreatedAt DATETIME NOT NULL,
        TahditCode NVARCHAR(50) NULL,
        IdariTahditCode NVARCHAR(50) NULL,
        PenaltyDay INT NOT NULL CONSTRAINT DF_TahditFormLog_PenaltyDay DEFAULT(0),
        PenaltyMonth INT NOT NULL CONSTRAINT DF_TahditFormLog_PenaltyMonth DEFAULT(0),
        PenaltyTotalDay INT NOT NULL CONSTRAINT DF_TahditFormLog_PenaltyTotalDay DEFAULT(0),
        PaymentType NVARCHAR(20) NULL,
        VisaType INT NOT NULL CONSTRAINT DF_TahditFormLog_VisaType DEFAULT(0),
        Country NVARCHAR(150) NULL,
        Border NVARCHAR(150) NULL,
        UserId INT NULL,
        UserSicil NVARCHAR(50) NULL,
        UserDisplayName NVARCHAR(200) NULL,
        PassengerName NVARCHAR(200) NULL,
        PassportNo NVARCHAR(80) NULL,
        FormMoney NVARCHAR(80) NULL
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_TahditFormLog_CreatedAt' AND object_id = OBJECT_ID(N'dbo.TahditFormLog'))
BEGIN
    CREATE INDEX IX_TahditFormLog_CreatedAt ON dbo.TahditFormLog(CreatedAt);
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_TahditFormLog_CodeCreatedAt' AND object_id = OBJECT_ID(N'dbo.TahditFormLog'))
BEGIN
    CREATE INDEX IX_TahditFormLog_CodeCreatedAt ON dbo.TahditFormLog(TahditCode, CreatedAt);
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_TahditFormLog_BorderCreatedAt' AND object_id = OBJECT_ID(N'dbo.TahditFormLog'))
BEGIN
    CREATE INDEX IX_TahditFormLog_BorderCreatedAt ON dbo.TahditFormLog(Border, CreatedAt);
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_TahditFormLog_UserCreatedAt' AND object_id = OBJECT_ID(N'dbo.TahditFormLog'))
BEGIN
    CREATE INDEX IX_TahditFormLog_UserCreatedAt ON dbo.TahditFormLog(UserId, UserSicil, CreatedAt);
END;
GO
