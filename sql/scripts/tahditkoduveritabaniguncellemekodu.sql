BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @nullable varchar(3);

    -- Kod sütunu
    SELECT @nullable = ISNULL(IS_NULLABLE,'NO')
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'TahditKod' AND COLUMN_NAME = 'Kod';

    IF EXISTS(
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'TahditKod' AND COLUMN_NAME = 'Kod'
        AND (DATA_TYPE <> 'nvarchar' OR (DATA_TYPE = 'nvarchar' AND CHARACTER_MAXIMUM_LENGTH <> -1))
    )
    BEGIN
        IF @nullable = 'YES'
            EXEC('ALTER TABLE dbo.TahditKod ALTER COLUMN Kod NVARCHAR(MAX) NULL;');
        ELSE
            EXEC('ALTER TABLE dbo.TahditKod ALTER COLUMN Kod NVARCHAR(MAX) NOT NULL;');
        PRINT 'Kod column altered to NVARCHAR(MAX)';
    END
    ELSE
        PRINT 'Kod already NVARCHAR(MAX)';

    -- Aciklama sütunu
    SELECT @nullable = ISNULL(IS_NULLABLE,'NO')
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'TahditKod' AND COLUMN_NAME = 'Aciklama';

    IF EXISTS(
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'TahditKod' AND COLUMN_NAME = 'Aciklama'
        AND (DATA_TYPE <> 'nvarchar' OR (DATA_TYPE = 'nvarchar' AND CHARACTER_MAXIMUM_LENGTH <> -1))
    )
    BEGIN
        IF @nullable = 'YES'
            EXEC('ALTER TABLE dbo.TahditKod ALTER COLUMN Aciklama NVARCHAR(MAX) NULL;');
        ELSE
            EXEC('ALTER TABLE dbo.TahditKod ALTER COLUMN Aciklama NVARCHAR(MAX) NOT NULL;');
        PRINT 'Aciklama column altered to NVARCHAR(MAX)';
    END
    ELSE
        PRINT 'Aciklama already NVARCHAR(MAX)';

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @err NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Error during schema update: %s',16,1,@err);
END CATCH;