-- ====================================================================================
-- HUDUT KAPILARI DİNAMİK İSTATİSTİK VE FAALİYET RAPORLAMA MODÜLÜ (HUDUT-STAT)
-- Tablolar, İlişkiler ve Standart Büro Şablonları (Günlük Veri Girişi Mimarisi)
-- ====================================================================================

-- 1. Hudut Kapısı Birimleri / Büro Amirlikleri
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Stat_Department')
BEGIN
    CREATE TABLE [dbo].[Stat_Department] (
        [DepartmentId] INT IDENTITY(1,1) PRIMARY KEY,
        [BorderId] INT NULL, -- NULL ise tüm kapılarda geçerli standart birim, dolu ise kapıya özel
        [DepartmentName] NVARCHAR(150) NOT NULL,
        [Code] NVARCHAR(50) NULL,
        [DisplayOrder] INT NOT NULL DEFAULT 0,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE()
    );
END;

-- 2. Birime Ait Tablo Şablonları
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Stat_TableTemplate')
BEGIN
    CREATE TABLE [dbo].[Stat_TableTemplate] (
        [TableId] INT IDENTITY(1,1) PRIMARY KEY,
        [DepartmentId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Stat_Department]([DepartmentId]) ON DELETE CASCADE,
        [TableTitle] NVARCHAR(200) NOT NULL,
        [Description] NVARCHAR(500) NULL,
        [DisplayOrder] INT NOT NULL DEFAULT 0,
        [IsActive] BIT NOT NULL DEFAULT 1
    );
END;

-- 3. Tablodaki Gösterge / İşlem Satırları
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Stat_RowItem')
BEGIN
    CREATE TABLE [dbo].[Stat_RowItem] (
        [RowId] INT IDENTITY(1,1) PRIMARY KEY,
        [TableId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Stat_TableTemplate]([TableId]) ON DELETE CASCADE,
        [RowTitle] NVARCHAR(200) NOT NULL,
        [Unit] NVARCHAR(50) NOT NULL DEFAULT N'Adet', -- Kişi, Adet, Sayı
        [DisplayOrder] INT NOT NULL DEFAULT 0,
        [IsActive] BIT NOT NULL DEFAULT 1
    );
END;

-- 4. Günlük Sayısal Veri Girişleri (Hücre Değerleri)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Stat_DailyValue')
BEGIN
    CREATE TABLE [dbo].[Stat_DailyValue] (
        [ValueId] BIGINT IDENTITY(1,1) PRIMARY KEY,
        [BorderId] INT NOT NULL, -- E_Border.fldId
        [RowId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Stat_RowItem]([RowId]) ON DELETE CASCADE,
        [EntryDate] DATE NOT NULL, -- Günlük giriş tarihi (YYYY-MM-DD)
        [Value] DECIMAL(18,2) NOT NULL DEFAULT 0,
        [Note] NVARCHAR(250) NULL,
        [UpdatedByUserId] INT NULL,
        [LastUpdated] DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT [UQ_Stat_DailyValue] UNIQUE ([BorderId], [RowId], [EntryDate])
    );
    CREATE INDEX [IX_Stat_DailyValue_Filter] ON [dbo].[Stat_DailyValue] ([BorderId], [EntryDate], [RowId]);
END;

-- 5. Kapı ve Birim Bazlı Kullanıcı Yetkilendirmeleri
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Stat_UserPermission')
BEGIN
    CREATE TABLE [dbo].[Stat_UserPermission] (
        [PermissionId] INT IDENTITY(1,1) PRIMARY KEY,
        [UserId] INT NOT NULL,    -- E_User.fldId
        [BorderId] INT NOT NULL,  -- E_Border.fldId
        [DepartmentId] INT NULL,  -- NULL ise Kapı Admini (tüm birimlere yetkili)
        [PermissionRole] NVARCHAR(50) NOT NULL, -- 'KapiAdmin', 'BirimEditor', 'Viewer'
        [AssignedDate] DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT [UQ_Stat_UserPermission] UNIQUE ([UserId], [BorderId], [DepartmentId])
    );
END;

-- ====================================================================================
-- STANDART BAŞLANGIÇ BÜRO, TABLO VE GÖSTERGE VERİLERİ (SEED DATA)
-- ====================================================================================

IF NOT EXISTS (SELECT 1 FROM [dbo].[Stat_Department] WHERE [Code] = 'BT')
BEGIN
    -- 1. Bilgi Teknolojileri Büro Amirliği
    INSERT INTO [dbo].[Stat_Department] ([BorderId], [DepartmentName], [Code], [DisplayOrder], [IsActive])
    VALUES (NULL, N'BİLGİ TEKNOLOJİLERİ BÜRO AMİRLİĞİ', 'BT', 1, 1);
    DECLARE @btId INT = SCOPE_IDENTITY();

    -- Tablo: Sorunlu Yolcu
    INSERT INTO [dbo].[Stat_TableTemplate] ([DepartmentId], [TableTitle], [Description], [DisplayOrder], [IsActive])
    VALUES (@btId, N'SORUNLU YOLCU', N'Tahdit, belge talebi ve tahdit işlemleri istatistiği', 1, 1);
    DECLARE @tSorunlu INT = SCOPE_IDENTITY();

    INSERT INTO [dbo].[Stat_RowItem] ([TableId], [RowTitle], [Unit], [DisplayOrder], [IsActive]) VALUES
    (@tSorunlu, N'TAHDİT BAKILAN KİŞİ', N'Kişi', 1, 1),
    (@tSorunlu, N'BELGE TALEBİ', N'Adet', 2, 1),
    (@tSorunlu, N'TAHDİT EKLEME', N'Adet', 3, 1),
    (@tSorunlu, N'TAHDİT KALDIRMA', N'Adet', 4, 1);

    -- Tablo: Teknik Destek ve Donanım
    INSERT INTO [dbo].[Stat_TableTemplate] ([DepartmentId], [TableTitle], [Description], [DisplayOrder], [IsActive])
    VALUES (@btId, N'TEKNİK DESTEK VE CİHAZ BAKIMLARI', N'Pasaport okuyucu, bilgisayar ve Polnet donanım bakım takip', 2, 1);
    DECLARE @tTeknik INT = SCOPE_IDENTITY();

    INSERT INTO [dbo].[Stat_RowItem] ([TableId], [RowTitle], [Unit], [DisplayOrder], [IsActive]) VALUES
    (@tTeknik, N'OPTİK OKUYUCU BAKIM / MÜDAHALE', N'Adet', 1, 1),
    (@tTeknik, N'POLNET TERMİNAL / PC ARIZA', N'Adet', 2, 1),
    (@tTeknik, N'AĞ VE HABERLEŞME ARIZALARI', N'Adet', 3, 1);
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[Stat_Department] WHERE [Code] = 'ADLI')
BEGIN
    -- 2. Adli İşlemler Büro Amirliği
    INSERT INTO [dbo].[Stat_Department] ([BorderId], [DepartmentName], [Code], [DisplayOrder], [IsActive])
    VALUES (NULL, N'ADLİ İŞLEMLER BÜRO AMİRLİĞİ', 'ADLI', 2, 1);
    DECLARE @adliId INT = SCOPE_IDENTITY();

    INSERT INTO [dbo].[Stat_TableTemplate] ([DepartmentId], [TableTitle], [Description], [DisplayOrder], [IsActive])
    VALUES (@adliId, N'ADLİ İŞLEM VE YAKALAMA İSTATİSTİKLERİ', N'Hudut kapısında yakalanan veya adli işlem yapılan şahıslar', 1, 1);
    DECLARE @tAdli INT = SCOPE_IDENTITY();

    INSERT INTO [dbo].[Stat_RowItem] ([TableId], [RowTitle], [Unit], [DisplayOrder], [IsActive]) VALUES
    (@tAdli, N'ARANMASI BULUNAN ŞAHIS', N'Kişi', 1, 1),
    (@tAdli, N'SAHTE BELGE / PASAPORT YAKALAMA', N'Adet', 2, 1),
    (@tAdli, N'C.SAVCILIĞINA SEVK EDİLEN ŞAHIS', N'Kişi', 3, 1),
    (@tAdli, N'İFADESİ ALINARAK SERBEST BIRAKILAN', N'Kişi', 4, 1);
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[Stat_Department] WHERE [Code] = 'PASAPORT')
BEGIN
    -- 3. Pasaport Kontrol Büro Amirliği
    INSERT INTO [dbo].[Stat_Department] ([BorderId], [DepartmentName], [Code], [DisplayOrder], [IsActive])
    VALUES (NULL, N'PASAPORT KONTROL BÜRO AMİRLİĞİ', 'PASAPORT', 3, 1);
    DECLARE @pasId INT = SCOPE_IDENTITY();

    INSERT INTO [dbo].[Stat_TableTemplate] ([DepartmentId], [TableTitle], [Description], [DisplayOrder], [IsActive])
    VALUES (@pasId, N'GİRİŞ-ÇIKIŞ YOLCU İSTATİSTİKLERİ', N'Hudut kapısından giriş ve çıkış yapan genel yolcu sayıları', 1, 1);
    DECLARE @tPas INT = SCOPE_IDENTITY();

    INSERT INTO [dbo].[Stat_RowItem] ([TableId], [RowTitle], [Unit], [DisplayOrder], [IsActive]) VALUES
    (@tPas, N'TÜRK VATANDAŞI GİRİŞ', N'Kişi', 1, 1),
    (@tPas, N'TÜRK VATANDAŞI ÇIKIŞ', N'Kişi', 2, 1),
    (@tPas, N'YABANCI YOLCU GİRİŞ', N'Kişi', 3, 1),
    (@tPas, N'YABANCI YOLCU ÇIKIŞ', N'Kişi', 4, 1),
    (@tPas, N'İHLALLİ ÇIKIŞ YAPAN YOLCU (CEZA/V84)', N'Kişi', 5, 1),
    (@tPas, N'ŞARTLI GİRİŞ YAPAN YOLCU (V70/V77/Ç114)', N'Kişi', 6, 1);
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[Stat_Department] WHERE [Code] = 'IDARI')
BEGIN
    -- 4. İdari İşler Büro Amirliği
    INSERT INTO [dbo].[Stat_Department] ([BorderId], [DepartmentName], [Code], [DisplayOrder], [IsActive])
    VALUES (NULL, N'İDARİ İŞLER VE DESTEK HİZMETLERİ', 'IDARI', 4, 1);
    DECLARE @idariId INT = SCOPE_IDENTITY();

    INSERT INTO [dbo].[Stat_TableTemplate] ([DepartmentId], [TableTitle], [Description], [DisplayOrder], [IsActive])
    VALUES (@idariId, N'EVRAK VE PERSONEL İŞLEMLERİ', N'Gelen giden evrak ve personel idari işlemleri', 1, 1);
    DECLARE @tIdari INT = SCOPE_IDENTITY();

    INSERT INTO [dbo].[Stat_RowItem] ([TableId], [RowTitle], [Unit], [DisplayOrder], [IsActive]) VALUES
    (@tIdari, N'GELEN RESMİ EVRAK', N'Adet', 1, 1),
    (@tIdari, N'GİDEN RESMİ EVRAK', N'Adet', 2, 1),
    (@tIdari, N'TEBLİĞ / TEBELLÜĞ İŞLEMİ', N'Adet', 3, 1);
END;
