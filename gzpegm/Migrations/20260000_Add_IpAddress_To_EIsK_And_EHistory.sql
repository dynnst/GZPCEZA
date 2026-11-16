-- ============================================================
-- Migration : IP Adresi Sütunları
-- Tarih      : 2026
-- Açıklama   : E_IsK ve E_History tablolarına fldIpAddress
--              sütunu eklenir. İşlemi gerçekleştiren personelin
--              IP adresi kayıt altına alınır.
-- ============================================================

-- Yerel geliştirme ortamında zaten uygulandı.
-- Canlı sunucuda çalıştırılacak.

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'E_IsK' AND COLUMN_NAME = 'fldIpAddress'
)
BEGIN
    ALTER TABLE E_IsK ADD fldIpAddress nvarchar(50) NULL;
    PRINT 'E_IsK.fldIpAddress sütunu eklendi.';
END
ELSE
BEGIN
    PRINT 'E_IsK.fldIpAddress zaten mevcut, atlandı.';
END

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'E_History' AND COLUMN_NAME = 'fldIpAddress'
)
BEGIN
    ALTER TABLE E_History ADD fldIpAddress nvarchar(50) NULL;
    PRINT 'E_History.fldIpAddress sütunu eklendi.';
END
ELSE
BEGIN
    PRINT 'E_History.fldIpAddress zaten mevcut, atlandı.';
END
