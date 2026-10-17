/*
    CEZAM - Chat Sistemi Tablolari
    Bu script guvenli/idempotent hazirlanmistir:
    - Tablo yoksa olusturur.
    - Tablo varsa tekrar olusturmaz.
    - Eksik index varsa ekler.

    Not:
    Veritabani adiniz farkliysa USE satirini kendi ortaminiza gore degistirin.
*/

USE [CEZA];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.ChatMessages', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ChatMessages
    (
        ChatMessageId INT IDENTITY(1,1) NOT NULL,
        SenderId INT NOT NULL,
        RecipientId INT NOT NULL,
        MessageText NVARCHAR(2000) NULL,
        ImagePath NVARCHAR(500) NULL,
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_ChatMessages_CreatedAt DEFAULT(GETDATE()),
        ReadAt DATETIME NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_ChatMessages_IsDeleted DEFAULT(0),

        CONSTRAINT PK_ChatMessages PRIMARY KEY CLUSTERED (ChatMessageId ASC)
    );

    PRINT 'ChatMessages tablosu olusturuldu.';
END
ELSE
BEGIN
    PRINT 'ChatMessages tablosu zaten mevcut.';
END
GO

IF OBJECT_ID('dbo.ChatOnlineUsers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ChatOnlineUsers
    (
        UserId INT NOT NULL,
        LastSeen DATETIME NOT NULL,
        LastPage NVARCHAR(500) NULL,

        CONSTRAINT PK_ChatOnlineUsers PRIMARY KEY CLUSTERED (UserId ASC)
    );

    PRINT 'ChatOnlineUsers tablosu olusturuldu.';
END
ELSE
BEGIN
    PRINT 'ChatOnlineUsers tablosu zaten mevcut.';
END
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_ChatMessages_Pair'
      AND object_id = OBJECT_ID('dbo.ChatMessages')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_ChatMessages_Pair
    ON dbo.ChatMessages(SenderId, RecipientId, ChatMessageId);

    PRINT 'IX_ChatMessages_Pair indexi olusturuldu.';
END
ELSE
BEGIN
    PRINT 'IX_ChatMessages_Pair indexi zaten mevcut.';
END
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_ChatMessages_Room'
      AND object_id = OBJECT_ID('dbo.ChatMessages')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_ChatMessages_Room
    ON dbo.ChatMessages(RecipientId, ChatMessageId);

    PRINT 'IX_ChatMessages_Room indexi olusturuldu.';
END
ELSE
BEGIN
    PRINT 'IX_ChatMessages_Room indexi zaten mevcut.';
END
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_ChatMessages_RecipientRead'
      AND object_id = OBJECT_ID('dbo.ChatMessages')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_ChatMessages_RecipientRead
    ON dbo.ChatMessages(RecipientId, ReadAt, ChatMessageId);

    PRINT 'IX_ChatMessages_RecipientRead indexi olusturuldu.';
END
ELSE
BEGIN
    PRINT 'IX_ChatMessages_RecipientRead indexi zaten mevcut.';
END
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_ChatOnlineUsers_LastSeen'
      AND object_id = OBJECT_ID('dbo.ChatOnlineUsers')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_ChatOnlineUsers_LastSeen
    ON dbo.ChatOnlineUsers(LastSeen DESC);

    PRINT 'IX_ChatOnlineUsers_LastSeen indexi olusturuldu.';
END
ELSE
BEGIN
    PRINT 'IX_ChatOnlineUsers_LastSeen indexi zaten mevcut.';
END
GO

PRINT 'Chat sistemi tablo kurulumu tamamlandi.';
GO
