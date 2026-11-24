using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using iTextSharp.text;
using iTextSharp.text.pdf;

namespace gzpegm.Services
{
    public class AdminBriefingService
    {
        public AdminBriefingViewModel GetBriefingData(string period, DateTime? customStart, DateTime? customEnd, string adminSicil, string adminName)
        {
            var now = DateTime.Now;
            DateTime start;
            DateTime end = now;
            string periodLabel;

            period = (period ?? "24saat").ToLowerInvariant();

            switch (period)
            {
                case "1saat":
                    start = now.AddHours(-1);
                    periodLabel = $"Son 1 Saat ({start:dd.MM.yyyy HH:mm} - {end:dd.MM.yyyy HH:mm})";
                    break;
                case "3saat":
                    start = now.AddHours(-3);
                    periodLabel = $"Son 3 Saat ({start:dd.MM.yyyy HH:mm} - {end:dd.MM.yyyy HH:mm})";
                    break;
                case "6saat":
                    start = now.AddHours(-6);
                    periodLabel = $"Son 6 Saat ({start:dd.MM.yyyy HH:mm} - {end:dd.MM.yyyy HH:mm})";
                    break;
                case "12saat":
                    start = now.AddHours(-12);
                    periodLabel = $"Son 12 Saat ({start:dd.MM.yyyy HH:mm} - {end:dd.MM.yyyy HH:mm})";
                    break;
                case "bugun":
                    start = DateTime.Today;
                    periodLabel = $"Bugün ({start:dd.MM.yyyy HH:mm} - {end:dd.MM.yyyy HH:mm})";
                    break;
                case "dun":
                    start = DateTime.Today.AddDays(-1);
                    end = DateTime.Today.AddTicks(-1);
                    periodLabel = $"Dün ({start:dd.MM.yyyy 00:00} - {end:dd.MM.yyyy 23:59})";
                    break;
                case "haftalik":
                    start = now.AddDays(-7);
                    periodLabel = $"Son 7 Gün (Haftalık: {start:dd.MM.yyyy HH:mm} - {end:dd.MM.yyyy HH:mm})";
                    break;
                case "aylik":
                    start = now.AddDays(-30);
                    periodLabel = $"Son 30 Gün (Aylık: {start:dd.MM.yyyy HH:mm} - {end:dd.MM.yyyy HH:mm})";
                    break;
                case "yillik":
                    start = now.AddDays(-365);
                    periodLabel = $"Son 365 Gün (Yıllık: {start:dd.MM.yyyy HH:mm} - {end:dd.MM.yyyy HH:mm})";
                    break;
                case "ozel":
                    start = customStart ?? now.AddHours(-24);
                    end = customEnd ?? now;
                    if (start > end)
                    {
                        var temp = start;
                        start = end;
                        end = temp;
                    }
                    periodLabel = $"Özel Tarih Aralığı ({start:dd.MM.yyyy HH:mm} - {end:dd.MM.yyyy HH:mm})";
                    break;
                case "24saat":
                default:
                    period = "24saat";
                    start = now.AddHours(-24);
                    periodLabel = $"Son 24 Saat ({start:dd.MM.yyyy HH:mm} - {end:dd.MM.yyyy HH:mm})";
                    break;
            }

            var model = new AdminBriefingViewModel
            {
                SelectedPeriod = period,
                StartDate = start,
                EndDate = end,
                PeriodLabel = periodLabel,
                GeneratedAt = now,
                GeneratedBySicil = adminSicil,
                GeneratedByName = adminName
            };

            using (var db = new GZPEGM1())
            {
                db.Configuration.AutoDetectChangesEnabled = false;

                // 1. HESAPLAMA METRİKLERİ (E_History)
                try
                {
                    model.HesaplamaCount = db.E_History
                        .AsNoTracking()
                        .Count(x => x.fldDatetime >= start && x.fldDatetime <= end);

                    var totalTutar = db.Database.SqlQuery<decimal?>(
                        @"SELECT ISNULL(SUM(TRY_CAST(REPLACE(REPLACE(fldPMoney, '.', ''), ',', '.') AS DECIMAL(18,2))), 0) 
                          FROM [dbo].[E_History] 
                          WHERE fldDatetime >= @p0 AND fldDatetime <= @p1",
                        new SqlParameter("@p0", start),
                        new SqlParameter("@p1", end)
                    ).FirstOrDefault();

                    model.HesaplamaTotalTutar = totalTutar ?? 0m;
                }
                catch
                {
                    model.HesaplamaCount = 0;
                    model.HesaplamaTotalTutar = 0m;
                }

                // 2. CEZA FORM ÇIKARTMA (E_IsK)
                try
                {
                    model.CezaFormCikarmaCount = db.E_IsK
                        .AsNoTracking()
                        .Count(x => x.fldDatetime >= start && x.fldDatetime <= end);
                }
                catch
                {
                    model.CezaFormCikarmaCount = 0;
                }

                // 3. TAHDİT TUTANAK / BİLDİRİM FORMU ÇIKARTMA (TahditFormLog)
                try
                {
                    model.TahditFormCikarmaCount = db.TahditFormLog
                        .AsNoTracking()
                        .Count(x => x.CreatedAt >= start && x.CreatedAt <= end);
                }
                catch
                {
                    model.TahditFormCikarmaCount = 0;
                }

                // 4. V-84 ŞARTLI GİRİŞ İŞLEMLERİ (E_Sartli)
                try
                {
                    model.V84IslemCount = db.E_Sartli
                        .AsNoTracking()
                        .Count(x => x.fldDate >= start && x.fldDate <= end);
                }
                catch
                {
                    model.V84IslemCount = 0;
                }

                // 5. İNAD YOLCU İŞLEMLERİ (E_Inad)
                try
                {
                    model.InadIslemCount = db.E_Inad
                        .AsNoTracking()
                        .Count(x => x.TarihSaat >= start && x.TarihSaat <= end);
                }
                catch
                {
                    model.InadIslemCount = 0;
                }

                // 6. DERS / KURS KAYITLARI (CourseEnrollments)
                try
                {
                    model.DersKayitCount = db.CourseEnrollments
                        .AsNoTracking()
                        .Count(x => x.EnrollmentDate >= start && x.EnrollmentDate <= end);
                }
                catch
                {
                    model.DersKayitCount = 0;
                }

                // 7. SINAV İŞLEMLERİ VE BAŞARI İSTATİSTİĞİ (ExamResult)
                try
                {
                    var exams = db.ExamResult
                        .AsNoTracking()
                        .Where(x => x.FinishedAt >= start && x.FinishedAt <= end)
                        .Select(x => x.Score)
                        .ToList();

                    model.SinavCount = exams.Count;
                    if (exams.Count > 0)
                    {
                        model.SinavOrtalamaPuan = Math.Round((double)exams.Average(), 1);
                    }
                }
                catch
                {
                    model.SinavCount = 0;
                    model.SinavOrtalamaPuan = 0.0;
                }

                // 8. SAHTECİLİK PORTALINA YÖNLENDİRİLME VE İNCELEME (E_SahtecilikLog)
                try
                {
                    // Schema kontrolü
                    SahtecilikLogService.EnsureSchema(db);

                    var sahtecilikGecis = db.Database.SqlQuery<int?>(
                        @"SELECT COUNT(1) FROM [dbo].[E_SahtecilikLog] 
                          WHERE IslemTipi = 'Portal Geçişi' AND IslemTarihi >= @p0 AND IslemTarihi <= @p1",
                        new SqlParameter("@p0", start),
                        new SqlParameter("@p1", end)
                    ).FirstOrDefault();
                    model.SahtecilikGecisCount = sahtecilikGecis ?? 0;

                    var sahtecilikInceleme = db.Database.SqlQuery<int?>(
                        @"SELECT COUNT(1) FROM [dbo].[E_SahtecilikLog] 
                          WHERE IslemTipi <> 'Portal Geçişi' AND IslemTarihi >= @p0 AND IslemTarihi <= @p1",
                        new SqlParameter("@p0", start),
                        new SqlParameter("@p1", end)
                    ).FirstOrDefault();
                    model.SahtecilikIncelemeCount = sahtecilikInceleme ?? 0;
                }
                catch
                {
                    model.SahtecilikGecisCount = 0;
                    model.SahtecilikIncelemeCount = 0;
                }

                // 9. YENİ KULLANICI KAYITLARI (E_User)
                try
                {
                    model.YeniKullaniciKayitCount = db.E_User
                        .AsNoTracking()
                        .Count(x => x.fldDateTime >= start && x.fldDateTime <= end);
                }
                catch
                {
                    model.YeniKullaniciKayitCount = 0;
                }

                // 10. ŞİFREMİ UNUTTUM / SIFIRLAMA TALEPLERİ (PasswordResetRequests)
                try
                {
                    var resetRequests = db.Database.SqlQuery<int?>(
                        @"SELECT COUNT(1) FROM [dbo].[PasswordResetRequests] 
                          WHERE RequestedAt >= @p0 AND RequestedAt <= @p1",
                        new SqlParameter("@p0", start),
                        new SqlParameter("@p1", end)
                    ).FirstOrDefault();
                    model.SifremiUnuttumCount = resetRequests ?? 0;

                    var resetApproved = db.Database.SqlQuery<int?>(
                        @"SELECT COUNT(1) FROM [dbo].[PasswordResetRequests] 
                          WHERE Status = 'Approved' AND ApprovedAt >= @p0 AND ApprovedAt <= @p1",
                        new SqlParameter("@p0", start),
                        new SqlParameter("@p1", end)
                    ).FirstOrDefault();
                    model.SifremiUnuttumOnaylananCount = resetApproved ?? 0;
                }
                catch
                {
                    model.SifremiUnuttumCount = 0;
                    model.SifremiUnuttumOnaylananCount = 0;
                }

                // 11. MESAJLAŞMA VE GENELGE TALEPLERİ
                try
                {
                    model.MesajlasmaCount = db.E_Messages
                        .AsNoTracking()
                        .Count(x => x.fldDateTime >= start && x.fldDateTime <= end);
                }
                catch
                {
                    model.MesajlasmaCount = 0;
                }

                try
                {
                    var genelgeReqs = db.Database.SqlQuery<int?>(
                        @"SELECT COUNT(1) FROM [dbo].[E_GenelgeTalep] 
                          WHERE RequestDate >= @p0 AND RequestDate <= @p1",
                        new SqlParameter("@p0", start),
                        new SqlParameter("@p1", end)
                    ).FirstOrDefault();
                    model.GenelgeTalepCount = genelgeReqs ?? 0;
                }
                catch
                {
                    model.GenelgeTalepCount = 0;
                }

                // =========================================================================
                // DETAYLI DAĞILIMLAR (GRAFİKLER & TABLOLAR İÇİN)
                // =========================================================================

                // Top Hesaplama Yapılan Ülkeler
                try
                {
                    var topUlkeRows = db.Database.SqlQuery<BriefingItemRaw>(
                        @"SELECT TOP 6 
                            ISNULL(fldCountry, 'Belirtilmemiş') AS Title,
                            COUNT(1) AS [Count],
                            ISNULL(SUM(TRY_CAST(REPLACE(REPLACE(fldPMoney, '.', ''), ',', '.') AS DECIMAL(18,2))), 0) AS TotalAmount
                          FROM [dbo].[E_History]
                          WHERE fldDatetime >= @p0 AND fldDatetime <= @p1
                          GROUP BY fldCountry
                          ORDER BY [Count] DESC",
                        new SqlParameter("@p0", start),
                        new SqlParameter("@p1", end)
                    ).ToList();

                    int topUlkeTotal = topUlkeRows.Sum(x => x.Count);
                    model.TopHesaplamaUlkeleri = topUlkeRows.Select(x => new BriefingItemSummary
                    {
                        Title = x.Title,
                        Count = x.Count,
                        TotalAmount = x.TotalAmount,
                        Percentage = topUlkeTotal > 0 ? Math.Round((double)x.Count * 100.0 / topUlkeTotal, 1) : 0
                    }).ToList();
                }
                catch { }

                // Top Tahdit Kodları
                try
                {
                    var topTahditRows = db.Database.SqlQuery<BriefingItemRaw>(
                        @"SELECT TOP 6 
                            ISNULL(TahditCode, 'Genel') AS Title,
                            COUNT(1) AS [Count],
                            0 AS TotalAmount
                          FROM [dbo].[TahditFormLog]
                          WHERE CreatedAt >= @p0 AND CreatedAt <= @p1
                          GROUP BY TahditCode
                          ORDER BY [Count] DESC",
                        new SqlParameter("@p0", start),
                        new SqlParameter("@p1", end)
                    ).ToList();

                    int topTahditTotal = topTahditRows.Sum(x => x.Count);
                    model.TopTahditKodlari = topTahditRows.Select(x => new BriefingItemSummary
                    {
                        Title = x.Title,
                        Count = x.Count,
                        Percentage = topTahditTotal > 0 ? Math.Round((double)x.Count * 100.0 / topTahditTotal, 1) : 0
                    }).ToList();
                }
                catch { }

                // Top İnad Uyrukları
                try
                {
                    var topInadRows = db.Database.SqlQuery<BriefingItemRaw>(
                        @"SELECT TOP 6 
                            ISNULL(RTRIM(LTRIM(Uyruk)), 'Belirtilmemiş') AS Title,
                            COUNT(1) AS [Count],
                            0 AS TotalAmount
                          FROM [dbo].[E_Inad]
                          WHERE TarihSaat >= @p0 AND TarihSaat <= @p1
                          GROUP BY RTRIM(LTRIM(Uyruk))
                          ORDER BY [Count] DESC",
                        new SqlParameter("@p0", start),
                        new SqlParameter("@p1", end)
                    ).ToList();

                    int topInadTotal = topInadRows.Sum(x => x.Count);
                    model.TopInadUlkeleri = topInadRows.Select(x => new BriefingItemSummary
                    {
                        Title = x.Title,
                        Count = x.Count,
                        Percentage = topInadTotal > 0 ? Math.Round((double)x.Count * 100.0 / topInadTotal, 1) : 0
                    }).ToList();
                }
                catch { }

                // Top V-84 Ülkeleri
                try
                {
                    var topV84Rows = db.Database.SqlQuery<BriefingItemRaw>(
                        @"SELECT TOP 6 
                            ISNULL(RTRIM(LTRIM(fldOrgin)), 'Belirtilmemiş') AS Title,
                            COUNT(1) AS [Count],
                            0 AS TotalAmount
                          FROM [dbo].[E_Sartli]
                          WHERE fldDate >= @p0 AND fldDate <= @p1
                          GROUP BY RTRIM(LTRIM(fldOrgin))
                          ORDER BY [Count] DESC",
                        new SqlParameter("@p0", start),
                        new SqlParameter("@p1", end)
                    ).ToList();

                    int topV84Total = topV84Rows.Sum(x => x.Count);
                    model.TopV84Ulkeleri = topV84Rows.Select(x => new BriefingItemSummary
                    {
                        Title = x.Title,
                        Count = x.Count,
                        Percentage = topV84Total > 0 ? Math.Round((double)x.Count * 100.0 / topV84Total, 1) : 0
                    }).ToList();
                }
                catch { }

                // En Aktif Hudut Kapıları
                try
                {
                    var topKapiRows = db.Database.SqlQuery<BriefingItemRaw>(
                        @"SELECT TOP 6 
                            Kapi AS Title,
                            SUM(Adet) AS [Count],
                            0 AS TotalAmount
                          FROM (
                              SELECT ISNULL(RTRIM(LTRIM(fldBorder)), 'Merkez') AS Kapi, COUNT(1) AS Adet FROM [dbo].[E_History] WHERE fldDatetime >= @p0 AND fldDatetime <= @p1 GROUP BY fldBorder
                              UNION ALL
                              SELECT ISNULL(RTRIM(LTRIM(Border)), 'Merkez') AS Kapi, COUNT(1) AS Adet FROM [dbo].[TahditFormLog] WHERE CreatedAt >= @p0 AND CreatedAt <= @p1 GROUP BY Border
                              UNION ALL
                              SELECT ISNULL(RTRIM(LTRIM(fldBorder)), 'Merkez') AS Kapi, COUNT(1) AS Adet FROM [dbo].[E_IsK] WHERE fldDatetime >= @p0 AND fldDatetime <= @p1 GROUP BY fldBorder
                              UNION ALL
                              SELECT ISNULL(RTRIM(LTRIM(Kapi)), 'Merkez') AS Kapi, COUNT(1) AS Adet FROM [dbo].[E_Inad] WHERE TarihSaat >= @p0 AND TarihSaat <= @p1 GROUP BY Kapi
                          ) T
                          WHERE Kapi <> '' AND Kapi IS NOT NULL
                          GROUP BY Kapi
                          ORDER BY [Count] DESC",
                        new SqlParameter("@p0", start),
                        new SqlParameter("@p1", end)
                    ).ToList();

                    int topKapiTotal = topKapiRows.Sum(x => x.Count);
                    model.TopHudutKapilari = topKapiRows.Select(x => new BriefingItemSummary
                    {
                        Title = x.Title,
                        Count = x.Count,
                        Percentage = topKapiTotal > 0 ? Math.Round((double)x.Count * 100.0 / topKapiTotal, 1) : 0
                    }).ToList();
                }
                catch { }

                // En Aktif Personeller
                try
                {
                    var topPersonelRows = db.Database.SqlQuery<BriefingItemRaw>(
                        @"SELECT TOP 6 
                            Personel AS Title,
                            SUM(Adet) AS [Count],
                            0 AS TotalAmount
                          FROM (
                              SELECT ISNULL(fldUser, 'Bilinmiyor') AS Personel, COUNT(1) AS Adet FROM [dbo].[E_History] WHERE fldDatetime >= @p0 AND fldDatetime <= @p1 GROUP BY fldUser
                              UNION ALL
                              SELECT ISNULL(UserDisplayName, ISNULL(UserSicil, 'Bilinmiyor')) AS Personel, COUNT(1) AS Adet FROM [dbo].[TahditFormLog] WHERE CreatedAt >= @p0 AND CreatedAt <= @p1 GROUP BY UserDisplayName, UserSicil
                              UNION ALL
                              SELECT ISNULL(Personel, ISNULL(Sicil, 'Bilinmiyor')) AS Personel, COUNT(1) AS Adet FROM [dbo].[E_Inad] WHERE TarihSaat >= @p0 AND TarihSaat <= @p1 GROUP BY Personel, Sicil
                              UNION ALL
                              SELECT ISNULL(fldBy, 'Bilinmiyor') AS Personel, COUNT(1) AS Adet FROM [dbo].[E_Sartli] WHERE fldDate >= @p0 AND fldDate <= @p1 GROUP BY fldBy
                          ) P
                          WHERE Personel <> '' AND Personel IS NOT NULL AND Personel <> 'Bilinmiyor'
                          GROUP BY Personel
                          ORDER BY [Count] DESC",
                        new SqlParameter("@p0", start),
                        new SqlParameter("@p1", end)
                    ).ToList();

                    int topPersonelTotal = topPersonelRows.Sum(x => x.Count);
                    model.TopAktifPersoneller = topPersonelRows.Select(x => new BriefingItemSummary
                    {
                        Title = x.Title,
                        Count = x.Count,
                        Percentage = topPersonelTotal > 0 ? Math.Round((double)x.Count * 100.0 / topPersonelTotal, 1) : 0
                    }).ToList();
                }
                catch { }

                // Son 15 Operasyonel İşlem Listesi
                try
                {
                    var recentRaw = db.Database.SqlQuery<RecentItemRaw>(
                        @"SELECT TOP 15 * FROM (
                            SELECT TOP 8 fldDatetime AS [Time], 'Ceza Hesaplama' AS Module, 
                                   (ISNULL(fldCountry, '') + ' - ' + ISNULL(fldPenalty, '') + ' (' + ISNULL(fldPMoney, '0') + ' TL)') AS [Desc], 
                                   ISNULL(fldUser, '') AS Officer, ISNULL(fldBorder, '') AS Border, 'badge-primary' AS Badge
                            FROM [dbo].[E_History] WHERE fldDatetime >= @p0 AND fldDatetime <= @p1
                            ORDER BY fldDatetime DESC

                            UNION ALL

                            SELECT TOP 5 CreatedAt AS [Time], 'Tahdit Tutanak' AS Module,
                                   (ISNULL(TahditCode, '') + ' - ' + ISNULL(PassengerName, '') + ' (' + ISNULL(Country, '') + ')') AS [Desc],
                                   ISNULL(UserDisplayName, ISNULL(UserSicil, '')) AS Officer, ISNULL(Border, '') AS Border, 'badge-warning' AS Badge
                            FROM [dbo].[TahditFormLog] WHERE CreatedAt >= @p0 AND CreatedAt <= @p1
                            ORDER BY CreatedAt DESC

                            UNION ALL

                            SELECT TOP 5 fldDate AS [Time], 'V-84 Şartlı Giriş' AS Module,
                                   (ISNULL(fldName, '') + ' (' + ISNULL(fldOrgin, '') + ')') AS [Desc],
                                   ISNULL(fldBy, '') AS Officer, ISNULL(fldBorder, '') AS Border, 'badge-info' AS Badge
                            FROM [dbo].[E_Sartli] WHERE fldDate >= @p0 AND fldDate <= @p1
                            ORDER BY fldDate DESC

                            UNION ALL

                            SELECT TOP 5 TarihSaat AS [Time], 'İnad Yolcu' AS Module,
                                   (ISNULL(RTRIM(LTRIM(AdSoyad)), '') + ' - ' + ISNULL(RTRIM(LTRIM(Uyruk)), '') + ' (' + ISNULL(RTRIM(LTRIM(InadSebep)), '') + ')') AS [Desc],
                                   ISNULL(Personel, ISNULL(Sicil, '')) AS Officer, ISNULL(Kapi, '') AS Border, 'badge-danger' AS Badge
                            FROM [dbo].[E_Inad] WHERE TarihSaat >= @p0 AND TarihSaat <= @p1
                            ORDER BY TarihSaat DESC

                            UNION ALL

                            SELECT TOP 5 IslemTarihi AS [Time], 'Sahtecilik Yönlendirme' AS Module,
                                   (ISNULL(IslemTipi, '') + ' - ' + ISNULL(KaynakSayfa, '') + ' (' + ISNULL(SecilenUlke, '') + ')') AS [Desc],
                                   ISNULL(UserName, ISNULL(UserSicil, '')) AS Officer, ISNULL(UserBorder, '') AS Border, 'badge-secondary' AS Badge
                            FROM [dbo].[E_SahtecilikLog] WHERE IslemTarihi >= @p0 AND IslemTarihi <= @p1
                            ORDER BY IslemTarihi DESC
                        ) U
                        ORDER BY [Time] DESC",
                        new SqlParameter("@p0", start),
                        new SqlParameter("@p1", end)
                    ).ToList();

                    model.SonIslemler = recentRaw.Select(x => new RecentActivityItem
                    {
                        Timestamp = x.Time,
                        Module = x.Module,
                        Description = x.Desc,
                        Officer = x.Officer,
                        Border = x.Border,
                        BadgeClass = x.Badge
                    }).ToList();
                }
                catch { }
            }

            return model;
        }

        private class BriefingItemRaw
        {
            public string Title { get; set; }
            public int Count { get; set; }
            public decimal TotalAmount { get; set; }
        }

        private class RecentItemRaw
        {
            public DateTime Time { get; set; }
            public string Module { get; set; }
            public string Desc { get; set; }
            public string Officer { get; set; }
            public string Border { get; set; }
            public string Badge { get; set; }
        }

        // =========================================================================
        // RESMİ PDF BRİFİNG RAPORU OLUŞTURUCU (iTextSharp & Unicode Türkçe Font)
        // =========================================================================
        public byte[] GenerateBriefingPdf(AdminBriefingViewModel data, string adminSicil, string adminName)
        {
            using (var stream = new MemoryStream())
            {
                // Standart A4 dikey belge
                var document = new Document(PageSize.A4, 28, 28, 28, 28);
                PdfWriter.GetInstance(document, stream);
                document.Open();

                // Font tanımları (arial.ttf - tam Türkçe Unicode desteği)
                var fontHeaderTop = BuildUnicodeFont(8.5f, false, new BaseColor(100, 116, 139));
                var fontMainTitle = BuildUnicodeFont(13f, true, new BaseColor(15, 23, 42));
                var fontSubTitle = BuildUnicodeFont(10.5f, true, new BaseColor(30, 41, 59));
                var fontPeriod = BuildUnicodeFont(9.5f, true, new BaseColor(37, 99, 235));
                var fontTableHead = BuildUnicodeFont(8.5f, true, BaseColor.WHITE);
                var fontCellBold = BuildUnicodeFont(8f, true, new BaseColor(15, 23, 42));
                var fontCellRegular = BuildUnicodeFont(8f, false, new BaseColor(30, 41, 59));
                var fontCellMuted = BuildUnicodeFont(7.5f, false, new BaseColor(100, 116, 139));
                var fontFooter = BuildUnicodeFont(7.5f, false, new BaseColor(100, 116, 139));

                var brandNavy = new BaseColor(30, 58, 138); // #1e3a8a
                var brandSlate = new BaseColor(241, 245, 249); // #f1f5f9
                var brandAltRow = new BaseColor(248, 250, 252); // #f8fafc

                // 1. ÜST BİLGİ (T.C. İÇİŞLERİ BAKANLIĞI / EGM)
                var pTop1 = new Paragraph("T.C. İÇİŞLERİ BAKANLIĞI", fontHeaderTop) { Alignment = Element.ALIGN_CENTER };
                var pTop2 = new Paragraph("EMNİYET GENEL MÜDÜRLÜĞÜ", fontHeaderTop) { Alignment = Element.ALIGN_CENTER };
                var pTop3 = new Paragraph("GÖÇMEN KAÇAKÇILIĞIYLA MÜCADELE VE HUDUT KAPILARI DAİRE BAŞKANLIĞI", fontSubTitle) { Alignment = Element.ALIGN_CENTER };
                var pMain = new Paragraph("YÖNETİCİ OPERASYONEL BRİFİNG VE İSTATİSTİK RAPORU", fontMainTitle) { Alignment = Element.ALIGN_CENTER, SpacingBefore = 3f, SpacingAfter = 8f };

                document.Add(pTop1);
                document.Add(pTop2);
                document.Add(pTop3);
                document.Add(pMain);

                // 2. META BİLGİ TABLOSU (Dönem, Tarih, Oluşturan, Gizlilik)
                var metaTable = new PdfPTable(4) { WidthPercentage = 100 };
                metaTable.SetWidths(new float[] { 22f, 28f, 22f, 28f });
                metaTable.SpacingAfter = 12f;

                AddMetaCell(metaTable, "Rapor Dönemi:", fontCellBold, brandSlate);
                AddMetaCell(metaTable, data.PeriodLabel ?? data.SelectedPeriod, fontPeriod, BaseColor.WHITE);

                AddMetaCell(metaTable, "Rapor Tarihi:", fontCellBold, brandSlate);
                AddMetaCell(metaTable, data.GeneratedAt.ToString("dd.MM.yyyy HH:mm:ss"), fontCellRegular, BaseColor.WHITE);

                AddMetaCell(metaTable, "Brifingi Alan Yetkili:", fontCellBold, brandSlate);
                AddMetaCell(metaTable, $"{adminName} ({adminSicil})", fontCellRegular, BaseColor.WHITE);

                AddMetaCell(metaTable, "Gizlilik Derecesi:", fontCellBold, brandSlate);
                AddMetaCell(metaTable, "HİZMETE ÖZEL / YÖNETİCİ", fontCellBold, BaseColor.WHITE);

                document.Add(metaTable);

                // 3. ANA OPERASYONEL GÖSTERGELER TABLOSU (Kullanıcının talep ettiği ana metrikler)
                var pKpiHead = new Paragraph("1. GENEL OPERASYONEL FAALİYET ÖZETİ", fontSubTitle) { SpacingAfter = 5f };
                document.Add(pKpiHead);

                var kpiTable = new PdfPTable(4) { WidthPercentage = 100 };
                kpiTable.SetWidths(new float[] { 38f, 18f, 24f, 20f });
                kpiTable.SpacingAfter = 12f;

                AddHeaderCell(kpiTable, "Operasyon / Faaliyet Türü", fontTableHead, brandNavy);
                AddHeaderCell(kpiTable, "İşlem Adedi", fontTableHead, brandNavy, Element.ALIGN_CENTER);
                AddHeaderCell(kpiTable, "Mali / İstatistiki Veri", fontTableHead, brandNavy, Element.ALIGN_RIGHT);
                AddHeaderCell(kpiTable, "Oran / Açıklama", fontTableHead, brandNavy);

                // Satırlar
                AddDataRow(kpiTable, "Ceza Hesaplama İşlemleri", $"{data.HesaplamaCount:N0}", $"{data.HesaplamaTotalTutar:N2} TL", "Vize İhlal / Harç", fontCellBold, fontCellRegular, false);
                AddDataRow(kpiTable, "Ceza Form Çıkartma (İSK)", $"{data.CezaFormCikarmaCount:N0}", "-", "Tebligat / Tutanak", fontCellBold, fontCellRegular, true);
                AddDataRow(kpiTable, "Tahdit Tutanak Çıkartma", $"{data.TahditFormCikarmaCount:N0}", "-", "Yolcu Form Çıktısı", fontCellBold, fontCellRegular, false);
                AddDataRow(kpiTable, "V-84 Şartlı Giriş İşlemleri", $"{data.V84IslemCount:N0}", "-", "10 Günlük Taahhüt", fontCellBold, fontCellRegular, true);
                AddDataRow(kpiTable, "İnad Yolcu İşlemleri", $"{data.InadIslemCount:N0}", "-", "Kabul Edilemez Yolcu", fontCellBold, fontCellRegular, false);
                AddDataRow(kpiTable, "Eğitim & Kurs Kayıtları", $"{data.DersKayitCount:N0}", "-", "Personel Gelişimi", fontCellBold, fontCellRegular, true);
                AddDataRow(kpiTable, "Sınav Tamamlama İşlemleri", $"{data.SinavCount:N0}", $"Ort: {data.SinavOrtalamaPuan:N1} Puan", "Bilgi Değerlendirme", fontCellBold, fontCellRegular, false);
                AddDataRow(kpiTable, "Sahtecilik Portalı Geçişleri", $"{data.SahtecilikGecisCount:N0}", "-", "Portal Yönlendirme", fontCellBold, fontCellRegular, true);
                AddDataRow(kpiTable, "Sahtecilik Belge İncelemeleri", $"{data.SahtecilikIncelemeCount:N0}", "-", "Pasaport / Vize Sorgu", fontCellBold, fontCellRegular, false);
                AddDataRow(kpiTable, "Yeni Personel Kayıtları", $"{data.YeniKullaniciKayitCount:N0}", "-", "Yeni Kullanıcı Hesabı", fontCellBold, fontCellRegular, true);
                AddDataRow(kpiTable, "Şifremi Unuttum / Sıfırlama", $"{data.SifremiUnuttumCount:N0}", $"Onay: {data.SifremiUnuttumOnaylananCount}", "Güvenlik Talepleri", fontCellBold, fontCellRegular, false);
                AddDataRow(kpiTable, "Sistem İçi Mesajlaşma", $"{data.MesajlasmaCount:N0}", "-", "Dahili İletişim", fontCellBold, fontCellRegular, true);
                AddDataRow(kpiTable, "Gizli Genelge Erişim Talepleri", $"{data.GenelgeTalepCount:N0}", "-", "Onay Bekleyen / Biten", fontCellBold, fontCellRegular, false);

                // Toplam Satırı
                var totCell1 = new PdfPCell(new Phrase("TOPLAM OPERASYONEL İŞLEM HACMİ", fontCellBold))
                {
                    BackgroundColor = new BaseColor(226, 232, 240),
                    Padding = 5f
                };
                var totCell2 = new PdfPCell(new Phrase($"{data.ToplamIslemHacmi:N0}", fontCellBold))
                {
                    BackgroundColor = new BaseColor(226, 232, 240),
                    HorizontalAlignment = Element.ALIGN_CENTER,
                    Padding = 5f
                };
                var totCell3 = new PdfPCell(new Phrase($"{data.HesaplamaTotalTutar:N2} TL", fontCellBold))
                {
                    BackgroundColor = new BaseColor(226, 232, 240),
                    HorizontalAlignment = Element.ALIGN_RIGHT,
                    Padding = 5f
                };
                var totCell4 = new PdfPCell(new Phrase("Tüm Modüller", fontCellRegular))
                {
                    BackgroundColor = new BaseColor(226, 232, 240),
                    Padding = 5f
                };
                kpiTable.AddCell(totCell1);
                kpiTable.AddCell(totCell2);
                kpiTable.AddCell(totCell3);
                kpiTable.AddCell(totCell4);

                document.Add(kpiTable);

                // 4. DAĞILIM VE DETAY ANALİZİ (2 Sütunlu Yan Yana Tablolar)
                var pDistHead = new Paragraph("2. İŞLEM DAĞILIMLARI VE DETAY ANALİZİ", fontSubTitle) { SpacingAfter = 5f };
                document.Add(pDistHead);

                var splitTable = new PdfPTable(2) { WidthPercentage = 100 };
                splitTable.SetWidths(new float[] { 50f, 50f });
                splitTable.SpacingAfter = 12f;

                // Sol: Top Ceza Hesaplanan Ülkeler
                var leftSub = new PdfPTable(3) { WidthPercentage = 100 };
                leftSub.SetWidths(new float[] { 50f, 20f, 30f });
                AddHeaderCell(leftSub, "Ceza Hes. En Çok Yapılan Ülkeler", fontTableHead, brandNavy, Element.ALIGN_LEFT, 3);
                AddHeaderCell(leftSub, "Ülke", fontTableHead, new BaseColor(51, 65, 85));
                AddHeaderCell(leftSub, "Adet", fontTableHead, new BaseColor(51, 65, 85), Element.ALIGN_CENTER);
                AddHeaderCell(leftSub, "Toplam TL", fontTableHead, new BaseColor(51, 65, 85), Element.ALIGN_RIGHT);

                if (data.TopHesaplamaUlkeleri != null && data.TopHesaplamaUlkeleri.Count > 0)
                {
                    foreach (var u in data.TopHesaplamaUlkeleri.Take(5))
                    {
                        AddSmallCell(leftSub, u.Title, fontCellRegular);
                        AddSmallCell(leftSub, u.Count.ToString(), fontCellRegular, Element.ALIGN_CENTER);
                        AddSmallCell(leftSub, $"{u.TotalAmount:N0} TL", fontCellRegular, Element.ALIGN_RIGHT);
                    }
                }
                else
                {
                    var emptyCell = new PdfPCell(new Phrase("Dönemde kayıt bulunmamaktadır.", fontCellMuted)) { Colspan = 3, Padding = 4f, HorizontalAlignment = Element.ALIGN_CENTER };
                    leftSub.AddCell(emptyCell);
                }

                // Sağ: En Aktif Hudut Kapıları
                var rightSub = new PdfPTable(2) { WidthPercentage = 100 };
                rightSub.SetWidths(new float[] { 70f, 30f });
                AddHeaderCell(rightSub, "En Çok İşlem Yapılan Hudut Kapıları", fontTableHead, brandNavy, Element.ALIGN_LEFT, 2);
                AddHeaderCell(rightSub, "Hudut Kapısı", fontTableHead, new BaseColor(51, 65, 85));
                AddHeaderCell(rightSub, "Toplam İşlem", fontTableHead, new BaseColor(51, 65, 85), Element.ALIGN_CENTER);

                if (data.TopHudutKapilari != null && data.TopHudutKapilari.Count > 0)
                {
                    foreach (var k in data.TopHudutKapilari.Take(5))
                    {
                        AddSmallCell(rightSub, k.Title, fontCellRegular);
                        AddSmallCell(rightSub, k.Count.ToString(), fontCellRegular, Element.ALIGN_CENTER);
                    }
                }
                else
                {
                    var emptyCell = new PdfPCell(new Phrase("Dönemde kayıt bulunmamaktadır.", fontCellMuted)) { Colspan = 2, Padding = 4f, HorizontalAlignment = Element.ALIGN_CENTER };
                    rightSub.AddCell(emptyCell);
                }

                splitTable.AddCell(new PdfPCell(leftSub) { Border = Rectangle.NO_BORDER, PaddingRight = 4f });
                splitTable.AddCell(new PdfPCell(rightSub) { Border = Rectangle.NO_BORDER, PaddingLeft = 4f });

                document.Add(splitTable);

                // 5. İMZA / RAPOR ONAY BLOKU
                var signTable = new PdfPTable(2) { WidthPercentage = 100 };
                signTable.SetWidths(new float[] { 50f, 50f });
                signTable.SpacingBefore = 20f;

                var signLeft = new Paragraph($"Raporu Alan / İnceleyen:\n{adminName}\nSicil: {adminSicil}\nYönetici Paneli", fontCellRegular);
                var signRight = new Paragraph($"Tarih / Saat:\n{DateTime.Now:dd.MM.yyyy HH:mm:ss}\nSistem Yetki Kodu: 2 (Admin)\nElektronik Olarak İmzalanmıştır.", fontCellRegular) { Alignment = Element.ALIGN_RIGHT };

                signTable.AddCell(new PdfPCell(signLeft) { Border = Rectangle.NO_BORDER });
                signTable.AddCell(new PdfPCell(signRight) { Border = Rectangle.NO_BORDER });

                document.Add(signTable);

                // 6. ALT BİLGİ DİPNOTU
                var pFooter = new Paragraph("\n* Bu brifing raporu sistem yöneticisi talebi üzerine GZPCEZA Otomasyon Sistemi tarafından anlık veritabanı kayıtlarından otomatik olarak üretilmiştir. T.C. Emniyet Genel Müdürlüğü mevzuatına tabidir.", fontFooter) { Alignment = Element.ALIGN_CENTER };
                document.Add(pFooter);

                document.Close();
                return stream.ToArray();
            }
        }

        private static void AddMetaCell(PdfPTable table, string text, Font font, BaseColor bg)
        {
            var cell = new PdfPCell(new Phrase(text ?? "", font))
            {
                BackgroundColor = bg,
                Padding = 4f,
                BorderColor = new BaseColor(203, 213, 225)
            };
            table.AddCell(cell);
        }

        private static void AddHeaderCell(PdfPTable table, string text, Font font, BaseColor bg, int align = Element.ALIGN_LEFT, int colspan = 1)
        {
            var cell = new PdfPCell(new Phrase(text ?? "", font))
            {
                BackgroundColor = bg,
                HorizontalAlignment = align,
                Padding = 5f,
                Colspan = colspan,
                BorderColor = new BaseColor(148, 163, 184)
            };
            table.AddCell(cell);
        }

        private static void AddDataRow(PdfPTable table, string col1, string col2, string col3, string col4, Font boldFont, Font normalFont, bool alt)
        {
            var bg = alt ? new BaseColor(248, 250, 252) : BaseColor.WHITE;
            var border = new BaseColor(226, 232, 240);

            var c1 = new PdfPCell(new Phrase(col1 ?? "", boldFont)) { BackgroundColor = bg, BorderColor = border, Padding = 4.5f };
            var c2 = new PdfPCell(new Phrase(col2 ?? "", normalFont)) { BackgroundColor = bg, BorderColor = border, HorizontalAlignment = Element.ALIGN_CENTER, Padding = 4.5f };
            var c3 = new PdfPCell(new Phrase(col3 ?? "", normalFont)) { BackgroundColor = bg, BorderColor = border, HorizontalAlignment = Element.ALIGN_RIGHT, Padding = 4.5f };
            var c4 = new PdfPCell(new Phrase(col4 ?? "", normalFont)) { BackgroundColor = bg, BorderColor = border, Padding = 4.5f };

            table.AddCell(c1);
            table.AddCell(c2);
            table.AddCell(c3);
            table.AddCell(c4);
        }

        private static void AddSmallCell(PdfPTable table, string text, Font font, int align = Element.ALIGN_LEFT)
        {
            var cell = new PdfPCell(new Phrase(text ?? "", font))
            {
                HorizontalAlignment = align,
                Padding = 3.5f,
                BorderColor = new BaseColor(226, 232, 240)
            };
            table.AddCell(cell);
        }

        private static Font BuildUnicodeFont(float size, bool bold = false, BaseColor color = null)
        {
            var fontPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Fonts), "arial.ttf");
            if (!File.Exists(fontPath))
            {
                fontPath = "C:\\Windows\\Fonts\\arial.ttf";
            }

            var baseFont = BaseFont.CreateFont(fontPath, BaseFont.IDENTITY_H, BaseFont.EMBEDDED);
            return new Font(baseFont, size, bold ? Font.BOLD : Font.NORMAL, color ?? BaseColor.BLACK);
        }
    }
}
