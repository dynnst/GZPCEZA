using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;

namespace gzpegm.Services
{
    public class SahtecilikLogService
    {
        private static bool _schemaEnsured = false;
        private static readonly object _schemaLock = new object();

        public static void EnsureSchema(GZPEGM1 db = null)
        {
            if (_schemaEnsured) return;
            lock (_schemaLock)
            {
                if (_schemaEnsured) return;
                try
                {
                    Action<GZPEGM1> exec = (context) =>
                    {
                        var sql = @"
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'E_SahtecilikLog' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[E_SahtecilikLog]
    (
        [Id]                   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [UserId]               INT NULL,
        [UserSicil]            NVARCHAR(50) NULL,
        [UserName]             NVARCHAR(150) NULL,
        [UserBorder]           NVARCHAR(100) NULL,
        [KaynakSayfa]          NVARCHAR(50) NOT NULL, -- 'Hesaplama', 'UserBox', 'Yardımcı', 'Sahtecilik Portalı'
        [IslemTipi]            NVARCHAR(50) NOT NULL, -- 'Portal Geçişi', 'Belge İnceleme', 'Arama'
        [SecilenUlke]          NVARCHAR(100) NULL,
        [IncelenenBelgeId]     INT NULL,
        [IncelenenBelgeBaslik] NVARCHAR(300) NULL,
        [IslemTarihi]          DATETIME NOT NULL DEFAULT GETDATE(),
        [IpAddress]            NVARCHAR(50) NULL,
        [HedefUrl]             NVARCHAR(500) NULL,
        [Detay]                NVARCHAR(1000) NULL
    );

    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SahtecilikLog_Tarih')
        CREATE INDEX [IX_SahtecilikLog_Tarih] ON [dbo].[E_SahtecilikLog]([IslemTarihi] DESC);

    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SahtecilikLog_Sicil')
        CREATE INDEX [IX_SahtecilikLog_Sicil] ON [dbo].[E_SahtecilikLog]([UserSicil]);

    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SahtecilikLog_Kaynak')
        CREATE INDEX [IX_SahtecilikLog_Kaynak] ON [dbo].[E_SahtecilikLog]([KaynakSayfa]);
END;";
                        context.Database.ExecuteSqlCommand(sql);
                    };

                    if (db != null)
                    {
                        exec(db);
                    }
                    else
                    {
                        using (var temp = new GZPEGM1())
                        {
                            exec(temp);
                        }
                    }
                    _schemaEnsured = true;
                }
                catch { }
            }
        }

        public bool LogGecis(int? userId, string userSicil, string userName, string userBorder, string kaynakSayfa, string secilenUlke, string ipAddress, string hedefUrl, string detay = null)
        {
            try
            {
                using (var db = new GZPEGM1())
                {
                    EnsureSchema(db);
                    var sql = @"
INSERT INTO E_SahtecilikLog 
(UserId, UserSicil, UserName, UserBorder, KaynakSayfa, IslemTipi, SecilenUlke, IslemTarihi, IpAddress, HedefUrl, Detay)
VALUES (@p0, @p1, @p2, @p3, @p4, @p5, @p6, GETDATE(), @p7, @p8, @p9)";

                    db.Database.ExecuteSqlCommand(sql,
                        (object)userId ?? DBNull.Value,
                        userSicil ?? "",
                        userName ?? "",
                        userBorder ?? "",
                        kaynakSayfa ?? "Hesaplama",
                        "Portal Geçişi",
                        (object)secilenUlke ?? DBNull.Value,
                        ipAddress ?? "",
                        hedefUrl ?? "",
                        detay ?? $"{kaynakSayfa} üzerinden Sahtecilik Portalı'na geçiş yapıldı."
                    );
                    return true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("SahtecilikLog error: " + ex.Message);
                return false;
            }
        }

        public SahtecilikLogViewModel GetLogs(string search = null, string kaynak = null, string ulke = null, DateTime? startDate = null, DateTime? endDate = null, int page = 1, int pageSize = 25)
        {
            var vm = new SahtecilikLogViewModel
            {
                Search = search,
                Kaynak = kaynak,
                Ulke = ulke,
                StartDate = startDate,
                EndDate = endDate,
                PageIndex = Math.Max(1, page),
                PageSize = pageSize > 0 ? pageSize : 25
            };

            try
            {
                using (var db = new GZPEGM1())
                {
                    EnsureSchema(db);

                    var whereBuilder = new StringBuilder(" WHERE 1=1 ");
                    var paramList = new List<object>();
                    int pIndex = 0;

                    if (!string.IsNullOrWhiteSpace(search))
                    {
                        var s = "%" + search.Trim() + "%";
                        whereBuilder.Append($" AND (UserSicil LIKE @p{pIndex} OR UserName LIKE @p{pIndex} OR UserBorder LIKE @p{pIndex} OR SecilenUlke LIKE @p{pIndex} OR IncelenenBelgeBaslik LIKE @p{pIndex} OR Detay LIKE @p{pIndex}) ");
                        paramList.Add(s);
                        pIndex++;
                    }

                    if (!string.IsNullOrWhiteSpace(kaynak) && kaynak != "Tümü")
                    {
                        whereBuilder.Append($" AND KaynakSayfa = @p{pIndex} ");
                        paramList.Add(kaynak.Trim());
                        pIndex++;
                    }

                    if (!string.IsNullOrWhiteSpace(ulke))
                    {
                        whereBuilder.Append($" AND SecilenUlke = @p{pIndex} ");
                        paramList.Add(ulke.Trim());
                        pIndex++;
                    }

                    if (startDate.HasValue)
                    {
                        whereBuilder.Append($" AND IslemTarihi >= @p{pIndex} ");
                        paramList.Add(startDate.Value.Date);
                        pIndex++;
                    }

                    if (endDate.HasValue)
                    {
                        whereBuilder.Append($" AND IslemTarihi <= @p{pIndex} ");
                        paramList.Add(endDate.Value.Date.AddDays(1).AddTicks(-1));
                        pIndex++;
                    }

                    // Toplam Kayıt Sayısı
                    var countSql = "SELECT COUNT(*) FROM E_SahtecilikLog " + whereBuilder.ToString();
                    vm.TotalCount = db.Database.SqlQuery<int>(countSql, paramList.ToArray()).FirstOrDefault();

                    // Sayfalanmış Veri
                    int skip = (vm.PageIndex - 1) * vm.PageSize;
                    var dataSql = $@"
SELECT Id, UserId, UserSicil, UserName, UserBorder, KaynakSayfa, IslemTipi, SecilenUlke, 
       IncelenenBelgeId, IncelenenBelgeBaslik, IslemTarihi, IpAddress, HedefUrl, Detay
FROM E_SahtecilikLog
{whereBuilder}
ORDER BY IslemTarihi DESC
OFFSET {skip} ROWS FETCH NEXT {vm.PageSize} ROWS ONLY";

                    vm.Logs = db.Database.SqlQuery<SahtecilikLogItem>(dataSql, paramList.ToArray()).ToList();

                    // İstatistikler (Bugün, Bu Hafta, Benzersiz Kullanıcılar, Popüler Ülkeler)
                    try
                    {
                        var todayStart = DateTime.Today;
                        var weekStart = DateTime.Today.AddDays(-7);

                        vm.TodayCount = db.Database.SqlQuery<int>(
                            "SELECT COUNT(*) FROM E_SahtecilikLog WHERE IslemTarihi >= @p0", todayStart).FirstOrDefault();

                        vm.WeekCount = db.Database.SqlQuery<int>(
                            "SELECT COUNT(*) FROM E_SahtecilikLog WHERE IslemTarihi >= @p0", weekStart).FirstOrDefault();

                        vm.DistinctUserCount = db.Database.SqlQuery<int>(
                            "SELECT COUNT(DISTINCT UserSicil) FROM E_SahtecilikLog WHERE UserSicil IS NOT NULL AND UserSicil <> ''").FirstOrDefault();

                        var topCountriesRaw = db.Database.SqlQuery<TopCountryRow>(@"
SELECT TOP 5 SecilenUlke AS Ulke, COUNT(*) AS Adet
FROM E_SahtecilikLog
WHERE SecilenUlke IS NOT NULL AND SecilenUlke <> ''
GROUP BY SecilenUlke
ORDER BY COUNT(*) DESC").ToList();

                        vm.TopCountries = topCountriesRaw
                            .Select(x => new KeyValuePair<string, int>(x.Ulke, x.Adet))
                            .ToList();
                    }
                    catch { }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("GetLogs Error: " + ex.Message);
            }

            return vm;
        }

        private class TopCountryRow
        {
            public string Ulke { get; set; }
            public int Adet { get; set; }
        }
    }
}
