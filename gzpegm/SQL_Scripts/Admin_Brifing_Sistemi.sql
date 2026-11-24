-- =========================================================================
-- T.C. İÇİŞLERİ BAKANLIĞI - EMNİYET GENEL MÜDÜRLÜĞÜ
-- GÖÇMEN KAÇAKÇILIĞIYLA MÜCADELE VE HUDUT KAPILARI DAİRE BAŞKANLIĞI
-- YÖNETİCİ OPERASYONEL BRİFİNG VE İSTATİSTİK RAPORLAMA SİSTEMİ VERİTABANI İNDEKSLERİ
-- =========================================================================

USE [CEZA];
GO

-- 1. E_History (Ceza Hesaplama Geçmişi) Tarih İndeksi
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_E_History_fldDatetime' AND object_id = OBJECT_ID('dbo.E_History'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_E_History_fldDatetime] 
    ON [dbo].[E_History] ([fldDatetime] DESC)
    INCLUDE ([fldCountry], [fldBorder], [fldPMoney], [fldUser]);
    PRINT '✓ E_History_fldDatetime indeksi oluşturuldu.';
END
GO

-- 2. E_IsK (İşlem / Ceza Form Kayıtları) Tarih İndeksi
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_E_IsK_fldDatetime' AND object_id = OBJECT_ID('dbo.E_IsK'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_E_IsK_fldDatetime] 
    ON [dbo].[E_IsK] ([fldDatetime] DESC)
    INCLUDE ([fldForm], [fldOrgin], [fldBorder], [fldApproval]);
    PRINT '✓ E_IsK_fldDatetime indeksi oluşturuldu.';
END
GO

-- 3. TahditFormLog (Tahdit Tutanak / Form Çıktıları) Tarih İndeksi
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_TahditFormLog_CreatedAt' AND object_id = OBJECT_ID('dbo.TahditFormLog'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_TahditFormLog_CreatedAt] 
    ON [dbo].[TahditFormLog] ([CreatedAt] DESC)
    INCLUDE ([TahditCode], [Country], [Border], [UserSicil]);
    PRINT '✓ TahditFormLog_CreatedAt indeksi oluşturuldu.';
END
GO

-- 4. E_Sartli (V-84 Şartlı Vize Girişleri) Tarih İndeksi
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_E_Sartli_fldDate' AND object_id = OBJECT_ID('dbo.E_Sartli'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_E_Sartli_fldDate] 
    ON [dbo].[E_Sartli] ([fldDate] DESC)
    INCLUDE ([fldOrgin], [fldBorder], [fldBy]);
    PRINT '✓ E_Sartli_fldDate indeksi oluşturuldu.';
END
GO

-- 5. E_Inad (İnad Yolcu İşlemleri) Tarih İndeksi
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_E_Inad_TarihSaat' AND object_id = OBJECT_ID('dbo.E_Inad'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_E_Inad_TarihSaat] 
    ON [dbo].[E_Inad] ([TarihSaat] DESC)
    INCLUDE ([Uyruk], [Kapi], [Durum], [GelenHavayolu]);
    PRINT '✓ E_Inad_TarihSaat indeksi oluşturuldu.';
END
GO

-- 6. CourseEnrollments (Eğitim Kurs Kayıtları) Tarih İndeksi
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_CourseEnrollments_Date' AND object_id = OBJECT_ID('dbo.CourseEnrollments'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_CourseEnrollments_Date] 
    ON [dbo].[CourseEnrollments] ([EnrollmentDate] DESC)
    INCLUDE ([CourseId], [UserId]);
    PRINT '✓ CourseEnrollments_Date indeksi oluşturuldu.';
END
GO

-- 7. ExamResult (Sınav Tamamlama Sonuçları) Tarih İndeksi
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ExamResult_FinishedAt' AND object_id = OBJECT_ID('dbo.ExamResult'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_ExamResult_FinishedAt] 
    ON [dbo].[ExamResult] ([FinishedAt] DESC)
    INCLUDE ([ExamId], [UserId], [Score], [Status]);
    PRINT '✓ ExamResult_FinishedAt indeksi oluşturuldu.';
END
GO

-- 8. E_SahtecilikLog (Sahtecilik Portalı Geçiş & İncelemeler) Tarih İndeksi
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SahtecilikLog_Tarih' AND object_id = OBJECT_ID('dbo.E_SahtecilikLog'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_SahtecilikLog_Tarih] 
    ON [dbo].[E_SahtecilikLog] ([IslemTarihi] DESC)
    INCLUDE ([UserSicil], [KaynakSayfa], [IslemTipi], [SecilenUlke]);
    PRINT '✓ E_SahtecilikLog_Tarih indeksi oluşturuldu.';
END
GO

-- 9. PasswordResetRequests (Şifremi Unuttum / Sıfırlama Talepleri) Tarih İndeksi
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PasswordResetRequests_RequestedAt' AND object_id = OBJECT_ID('dbo.PasswordResetRequests'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_PasswordResetRequests_RequestedAt] 
    ON [dbo].[PasswordResetRequests] ([RequestedAt] DESC)
    INCLUDE ([UserId], [Status], [ApprovedAt]);
    PRINT '✓ PasswordResetRequests_RequestedAt indeksi oluşturuldu.';
END
GO

PRINT 'Tüm Admin Brifing indeksleri başarıyla doğrulandı.';
