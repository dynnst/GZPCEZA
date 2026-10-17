using gzpegm.Models;
using gzpegm.Models.ViewModels;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Entity.Core.EntityClient;
using System.Data.SqlClient;
using System.Linq;

namespace gzpegm.Cont
{
    public class TahditFormLogEntry
    {
        public string TahditCode { get; set; }
        public string IdariTahditCode { get; set; }
        public int PenaltyDay { get; set; }
        public int PenaltyMonth { get; set; }
        public int PenaltyTotalDay { get; set; }
        public string PaymentType { get; set; }
        public int VisaType { get; set; }
        public string Country { get; set; }
        public string Border { get; set; }
        public int? UserId { get; set; }
        public string UserSicil { get; set; }
        public string UserDisplayName { get; set; }
        public string PassengerName { get; set; }
        public string PassportNo { get; set; }
        public string FormMoney { get; set; }
    }

    public class TahditFormLogService
    {
        private const string TableName = "dbo.TahditFormLog";
        private const string EffectiveTahditCodeSql = @"
CASE
    WHEN NULLIF(LTRIM(RTRIM(TahditCode)), '') IS NULL
         OR UPPER(LTRIM(RTRIM(TahditCode))) IN ('-', '--', '---', 'YOK')
    THEN ISNULL(NULLIF(LTRIM(RTRIM(IdariTahditCode)), ''), '-')
    ELSE LTRIM(RTRIM(TahditCode))
END";
        private const string EffectiveIdariTahditCodeSql = "ISNULL(NULLIF(LTRIM(RTRIM(IdariTahditCode)), ''), '-')";
        private const string ValidCodeSql = "NULLIF(LTRIM(RTRIM(CodeValue)), '') IS NOT NULL AND UPPER(LTRIM(RTRIM(CodeValue))) NOT IN ('-', '--', '---', 'YOK')";

        public void Log(TahditFormLogEntry entry)
        {
            if (entry == null || string.IsNullOrWhiteSpace(entry.TahditCode))
                return;

            EnsureTable();

            using (var con = OpenConnection())
            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = @"
INSERT INTO dbo.TahditFormLog
(
    CreatedAt, TahditCode, IdariTahditCode, PenaltyDay, PenaltyMonth, PenaltyTotalDay,
    PaymentType, VisaType, Country, Border, UserId, UserSicil, UserDisplayName,
    PassengerName, PassportNo, FormMoney
)
VALUES
(
    @CreatedAt, @TahditCode, @IdariTahditCode, @PenaltyDay, @PenaltyMonth, @PenaltyTotalDay,
    @PaymentType, @VisaType, @Country, @Border, @UserId, @UserSicil, @UserDisplayName,
    @PassengerName, @PassportNo, @FormMoney
);";

                Add(cmd, "@CreatedAt", SqlDbType.DateTime, DateTime.Now);
                Add(cmd, "@TahditCode", SqlDbType.NVarChar, Normalize(entry.TahditCode), 50);
                Add(cmd, "@IdariTahditCode", SqlDbType.NVarChar, Normalize(entry.IdariTahditCode), 50);
                Add(cmd, "@PenaltyDay", SqlDbType.Int, entry.PenaltyDay);
                Add(cmd, "@PenaltyMonth", SqlDbType.Int, entry.PenaltyMonth);
                Add(cmd, "@PenaltyTotalDay", SqlDbType.Int, entry.PenaltyTotalDay);
                Add(cmd, "@PaymentType", SqlDbType.NVarChar, Normalize(entry.PaymentType), 20);
                Add(cmd, "@VisaType", SqlDbType.Int, entry.VisaType);
                Add(cmd, "@Country", SqlDbType.NVarChar, Normalize(entry.Country), 150);
                Add(cmd, "@Border", SqlDbType.NVarChar, Normalize(entry.Border), 150);
                Add(cmd, "@UserId", SqlDbType.Int, entry.UserId.HasValue ? (object)entry.UserId.Value : DBNull.Value);
                Add(cmd, "@UserSicil", SqlDbType.NVarChar, Normalize(entry.UserSicil), 50);
                Add(cmd, "@UserDisplayName", SqlDbType.NVarChar, Normalize(entry.UserDisplayName), 200);
                Add(cmd, "@PassengerName", SqlDbType.NVarChar, Normalize(entry.PassengerName), 200);
                Add(cmd, "@PassportNo", SqlDbType.NVarChar, Normalize(entry.PassportNo), 80);
                Add(cmd, "@FormMoney", SqlDbType.NVarChar, Normalize(entry.FormMoney), 80);
                cmd.ExecuteNonQuery();
            }
        }

        public string FindIdariTahditCode(GZPEGM1 db, string tahditCode, string paymentType)
        {
            if (db == null || string.IsNullOrWhiteSpace(tahditCode))
                return "";

            byte paid;
            var normalizedCode = tahditCode.Trim();
            if (byte.TryParse((paymentType ?? "").Trim(), out paid))
            {
                var byPaid = db.E_TKOD.FirstOrDefaultAsyncSafe(x => x.fldCode == normalizedCode && x.fldPaid == paid);
                if (byPaid != null)
                    return byPaid.fldIdariCode ?? "";
            }

            var byCode = db.E_TKOD.FirstOrDefaultAsyncSafe(x => x.fldCode == normalizedCode);
            return byCode != null ? (byCode.fldIdariCode ?? "") : "";
        }

        public TahditStatisticsViewModel GetStatistics()
        {
            return GetStatistics(null, null, null, null, null);
        }

        public TahditStatisticsViewModel GetStatistics(DateTime? startDate, DateTime? endDate, string border, int? userId, string userSicil)
        {
            EnsureTable();
            var today = DateTime.Today;
            var tomorrow = today.AddDays(1);
            var filter = BuildFilter(startDate, endDate, border, userId, userSicil);
            var todayFilter = BuildFilter(today, today, border, userId, userSicil);

            var model = new TahditStatisticsViewModel();
            model.TodayTotal = CountCodeOccurrences(todayFilter);
            model.AllTotal = CountCodeOccurrences(filter);
            model.TodayByCode = GetCodeStats(todayFilter);
            model.AllByCode = GetCodeStats(filter);
            model.TodayByBorder = GetBorderStats(todayFilter);
            model.AllByBorder = GetBorderStats(filter);
            model.TodayByUser = GetUserStats(todayFilter);
            model.AllByUser = GetUserStats(filter);
            return model;
        }

        private int Count(QueryFilter filter)
        {
            using (var con = OpenConnection())
            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = "SELECT COUNT(1) FROM " + TableName + " " + filter.WhereClause;
                AddFilterParameters(cmd, filter);
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        private int CountCodeOccurrences(QueryFilter filter)
        {
            using (var con = OpenConnection())
            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = @"
WITH Filtered AS
(
    SELECT TahditCode, IdariTahditCode
    FROM dbo.TahditFormLog
    " + filter.WhereClause + @"
),
Codes AS
(
    SELECT " + EffectiveTahditCodeSql + @" AS CodeValue
    FROM Filtered
    UNION ALL
    SELECT " + EffectiveIdariTahditCodeSql + @" AS CodeValue
    FROM Filtered
    WHERE " + EffectiveIdariTahditCodeSql + @" <> '-'
      AND " + EffectiveIdariTahditCodeSql + @" <> " + EffectiveTahditCodeSql + @"
)
SELECT COUNT(1)
FROM Codes
WHERE " + ValidCodeSql + @";";
                AddFilterParameters(cmd, filter);
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        private List<TahditCodeStatItem> GetCodeStats(QueryFilter filter)
        {
            var list = new List<TahditCodeStatItem>();
            using (var con = OpenConnection())
            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = @"
WITH Filtered AS
(
    SELECT TahditCode, IdariTahditCode
    FROM dbo.TahditFormLog
    " + filter.WhereClause + @"
),
Codes AS
(
    SELECT " + EffectiveTahditCodeSql + @" AS CodeValue, " + EffectiveIdariTahditCodeSql + @" AS IdariTahditCode
    FROM Filtered
    UNION ALL
    SELECT " + EffectiveIdariTahditCodeSql + @" AS CodeValue, " + EffectiveIdariTahditCodeSql + @" AS IdariTahditCode
    FROM Filtered
    WHERE " + EffectiveIdariTahditCodeSql + @" <> '-'
      AND " + EffectiveIdariTahditCodeSql + @" <> " + EffectiveTahditCodeSql + @"
)
SELECT
    CodeValue AS TahditCode,
    ISNULL(NULLIF(IdariTahditCode, ''), '-') AS IdariTahditCode,
    COUNT(1) AS Count
FROM Codes
WHERE " + ValidCodeSql + @"
GROUP BY CodeValue, ISNULL(NULLIF(IdariTahditCode, ''), '-')
ORDER BY COUNT(1) DESC, TahditCode ASC;";
                AddFilterParameters(cmd, filter);
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        list.Add(new TahditCodeStatItem
                        {
                            TahditCode = r["TahditCode"].ToString(),
                            IdariTahditCode = r["IdariTahditCode"].ToString(),
                            Count = Convert.ToInt32(r["Count"])
                        });
                    }
                }
            }
            return list;
        }

        private List<TahditBorderStatItem> GetBorderStats(QueryFilter filter)
        {
            var list = new List<TahditBorderStatItem>();
            using (var con = OpenConnection())
            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = @"
WITH Filtered AS
(
    SELECT Border, TahditCode, IdariTahditCode
    FROM dbo.TahditFormLog
    " + filter.WhereClause + @"
),
Codes AS
(
    SELECT ISNULL(NULLIF(Border, ''), '-') AS Border, " + EffectiveTahditCodeSql + @" AS CodeValue, " + EffectiveIdariTahditCodeSql + @" AS IdariTahditCode
    FROM Filtered
    UNION ALL
    SELECT ISNULL(NULLIF(Border, ''), '-') AS Border, " + EffectiveIdariTahditCodeSql + @" AS CodeValue, " + EffectiveIdariTahditCodeSql + @" AS IdariTahditCode
    FROM Filtered
    WHERE " + EffectiveIdariTahditCodeSql + @" <> '-'
      AND " + EffectiveIdariTahditCodeSql + @" <> " + EffectiveTahditCodeSql + @"
)
SELECT TOP 30
    Border,
    CodeValue AS TahditCode,
    ISNULL(NULLIF(IdariTahditCode, ''), '-') AS IdariTahditCode,
    COUNT(1) AS Count
FROM Codes
WHERE " + ValidCodeSql + @"
GROUP BY Border, CodeValue, ISNULL(NULLIF(IdariTahditCode, ''), '-')
ORDER BY COUNT(1) DESC, Border ASC, TahditCode ASC;";
                AddFilterParameters(cmd, filter);
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        list.Add(new TahditBorderStatItem
                        {
                            Border = r["Border"].ToString(),
                            TahditCode = r["TahditCode"].ToString(),
                            IdariTahditCode = r["IdariTahditCode"].ToString(),
                            Count = Convert.ToInt32(r["Count"])
                        });
                    }
                }
            }
            return list;
        }

        private List<TahditUserStatItem> GetUserStats(QueryFilter filter)
        {
            var list = new List<TahditUserStatItem>();
            using (var con = OpenConnection())
            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = @"
WITH Filtered AS
(
    SELECT UserId, UserSicil, UserDisplayName, Border, TahditCode, IdariTahditCode
    FROM dbo.TahditFormLog
    " + filter.WhereClause + @"
),
Codes AS
(
    SELECT UserId, ISNULL(NULLIF(UserSicil, ''), '-') AS UserSicil, ISNULL(NULLIF(UserDisplayName, ''), '-') AS UserDisplayName,
           ISNULL(NULLIF(Border, ''), '-') AS Border, " + EffectiveTahditCodeSql + @" AS CodeValue, " + EffectiveIdariTahditCodeSql + @" AS IdariTahditCode
    FROM Filtered
    UNION ALL
    SELECT UserId, ISNULL(NULLIF(UserSicil, ''), '-') AS UserSicil, ISNULL(NULLIF(UserDisplayName, ''), '-') AS UserDisplayName,
           ISNULL(NULLIF(Border, ''), '-') AS Border, " + EffectiveIdariTahditCodeSql + @" AS CodeValue, " + EffectiveIdariTahditCodeSql + @" AS IdariTahditCode
    FROM Filtered
    WHERE " + EffectiveIdariTahditCodeSql + @" <> '-'
      AND " + EffectiveIdariTahditCodeSql + @" <> " + EffectiveTahditCodeSql + @"
)
SELECT TOP 30
    UserId,
    UserSicil,
    UserDisplayName,
    Border,
    CodeValue AS TahditCode,
    ISNULL(NULLIF(IdariTahditCode, ''), '-') AS IdariTahditCode,
    COUNT(1) AS Count
FROM Codes
WHERE " + ValidCodeSql + @"
GROUP BY UserId, UserSicil, UserDisplayName, Border, CodeValue, ISNULL(NULLIF(IdariTahditCode, ''), '-')
ORDER BY COUNT(1) DESC, UserDisplayName ASC, TahditCode ASC;";
                AddFilterParameters(cmd, filter);
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        list.Add(new TahditUserStatItem
                        {
                            UserId = r["UserId"] == DBNull.Value ? (int?)null : Convert.ToInt32(r["UserId"]),
                            UserSicil = r["UserSicil"].ToString(),
                            UserDisplayName = r["UserDisplayName"].ToString(),
                            Border = r["Border"].ToString(),
                            TahditCode = r["TahditCode"].ToString(),
                            IdariTahditCode = r["IdariTahditCode"].ToString(),
                            Count = Convert.ToInt32(r["Count"])
                        });
                    }
                }
            }
            return list;
        }

        private static QueryFilter BuildFilter(DateTime? start, DateTime? end, string border, int? userId, string userSicil)
        {
            var clauses = new List<string>();
            var filter = new QueryFilter
            {
                StartDate = start,
                EndDate = end.HasValue ? end.Value.Date.AddDays(1).AddTicks(-1) : (DateTime?)null,
                Border = Normalize(border),
                UserId = userId,
                UserSicil = Normalize(userSicil)
            };

            if (filter.StartDate.HasValue) clauses.Add("CreatedAt >= @StartDate");
            if (filter.EndDate.HasValue) clauses.Add("CreatedAt <= @EndDate");
            if (!string.IsNullOrWhiteSpace(filter.Border)) clauses.Add("Border = @Border");
            if (filter.UserId.HasValue) clauses.Add("UserId = @UserId");
            else if (!string.IsNullOrWhiteSpace(filter.UserSicil)) clauses.Add("UserSicil = @UserSicil");

            filter.WhereClause = clauses.Count > 0 ? "WHERE " + string.Join(" AND ", clauses) : "";
            return filter;
        }

        private static void AddFilterParameters(SqlCommand cmd, QueryFilter filter)
        {
            if (filter.StartDate.HasValue)
                Add(cmd, "@StartDate", SqlDbType.DateTime, filter.StartDate.Value);
            if (filter.EndDate.HasValue)
                Add(cmd, "@EndDate", SqlDbType.DateTime, filter.EndDate.Value);
            if (!string.IsNullOrWhiteSpace(filter.Border))
                Add(cmd, "@Border", SqlDbType.NVarChar, filter.Border, 150);
            if (filter.UserId.HasValue)
                Add(cmd, "@UserId", SqlDbType.Int, filter.UserId.Value);
            if (!string.IsNullOrWhiteSpace(filter.UserSicil))
                Add(cmd, "@UserSicil", SqlDbType.NVarChar, filter.UserSicil, 50);
        }

        private void EnsureTable()
        {
            using (var con = OpenConnection())
            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = @"
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

    CREATE INDEX IX_TahditFormLog_CreatedAt ON dbo.TahditFormLog(CreatedAt);
    CREATE INDEX IX_TahditFormLog_CodeCreatedAt ON dbo.TahditFormLog(TahditCode, CreatedAt);
    CREATE INDEX IX_TahditFormLog_BorderCreatedAt ON dbo.TahditFormLog(Border, CreatedAt);
    CREATE INDEX IX_TahditFormLog_UserCreatedAt ON dbo.TahditFormLog(UserId, UserSicil, CreatedAt);
END;";
                cmd.ExecuteNonQuery();
            }
        }

        private static SqlConnection OpenConnection()
        {
            var entityConnection = ConfigurationManager.ConnectionStrings["GZPEGM1"].ConnectionString;
            var builder = new EntityConnectionStringBuilder(entityConnection);
            var con = new SqlConnection(builder.ProviderConnectionString);
            con.Open();
            return con;
        }

        private static void Add(SqlCommand cmd, string name, SqlDbType type, object value, int size = 0)
        {
            var p = cmd.Parameters.Add(name, type);
            if (size > 0)
                p.Size = size;
            p.Value = value ?? DBNull.Value;
        }

        private static string Normalize(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? null : value.Trim();
        }

        private class QueryFilter
        {
            public string WhereClause { get; set; }
            public DateTime? StartDate { get; set; }
            public DateTime? EndDate { get; set; }
            public string Border { get; set; }
            public int? UserId { get; set; }
            public string UserSicil { get; set; }
        }
    }

    internal static class TkodQueryExtensions
    {
        public static E_TKOD FirstOrDefaultAsyncSafe(this System.Data.Entity.DbSet<E_TKOD> set, System.Linq.Expressions.Expression<Func<E_TKOD, bool>> predicate)
        {
            return set.FirstOrDefault(predicate);
        }
    }
}
