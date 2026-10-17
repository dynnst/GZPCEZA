IF EXISTS (
    SELECT 1
    FROM sys.columns c
    INNER JOIN sys.tables t ON c.object_id = t.object_id
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.name = 'dbo'
      AND t.name = 'E_Inad'
      AND c.name = 'TarihSaat'
      AND TYPE_NAME(c.user_type_id) = 'date'
)
BEGIN
    ALTER TABLE [dbo].[E_Inad]
    ALTER COLUMN [TarihSaat] DATETIME NULL;
END
