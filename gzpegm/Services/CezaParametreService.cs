using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Entity.Core.EntityClient;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web;

namespace gzpegm.Services
{
    public class CezaParametreItem
    {
        public string ParamKey { get; set; }
        public string ParamValue { get; set; }
        public string ParamTitle { get; set; }
        public string ParamDescription { get; set; }
        public string ParamGroup { get; set; }
        public DateTime UpdatedAt { get; set; }
        public string UpdatedBy { get; set; }
    }

    public static class CezaParametreService
    {
        private const string CACHE_KEY = "CACHE_CEZA_PARAMETRE";
        private static readonly object _lock = new object();

        private static SqlConnection OpenConnection()
        {
            var setting = ConfigurationManager.ConnectionStrings["GZPEGM1"];
            if (setting == null || string.IsNullOrWhiteSpace(setting.ConnectionString))
            {
                var fallbackCon = new SqlConnection("Server=(localdb)\\MSSQLLocalDB;Database=CEZA;Integrated Security=True;");
                fallbackCon.Open();
                return fallbackCon;
            }

            var builder = new EntityConnectionStringBuilder(setting.ConnectionString);
            var con = new SqlConnection(builder.ProviderConnectionString);
            con.Open();
            return con;
        }

        public static void ClearCache()
        {
            try
            {
                HttpRuntime.Cache.Remove(CACHE_KEY);
            }
            catch { }
        }

        public static void EnsureSchema()
        {
            try
            {
                using (var con = OpenConnection())
                using (var cmd = con.CreateCommand())
                {
                    cmd.CommandText = @"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CezaParametre')
BEGIN
    CREATE TABLE dbo.CezaParametre (
        ParamKey NVARCHAR(50) NOT NULL PRIMARY KEY,
        ParamValue NVARCHAR(MAX) NOT NULL,
        ParamTitle NVARCHAR(150) NOT NULL,
        ParamDescription NVARCHAR(500) NULL,
        ParamGroup NVARCHAR(50) NOT NULL,
        UpdatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedBy NVARCHAR(100) NULL
    );

    INSERT INTO dbo.CezaParametre (ParamKey, ParamValue, ParamTitle, ParamDescription, ParamGroup, UpdatedAt, UpdatedBy)
    VALUES 
    ('V137_IDARI_CEZA', '20605', N'V-137 Terke Davet Süresi Aşımı İdari Para Cezası (TL)', N'6458 sayılı YUKK m. 53/54 gereğince terke davet süresini aşan yabancılara uygulanan idari para cezası tutarı.', 'Ceza', GETDATE(), 'SystemInit'),
    ('FGRUBU_DAY9_KAT', '467.6', N'F Grubu (Norveç vb.) 9. Gün Özel Basamak Sıçraması (TL)', N'POLNET Vize İhlal Cetveli uyarınca F Grubu (Norveç, Sırbistan vb.) için 9. günde uygulanan ara basamak tamamlama tutarı.', 'Basamak', GETDATE(), 'SystemInit'),
    ('KABAHATLER_M32_CEZA', '1854', N'Harçtan Muaf Ülkeler (G Grubu) İdari Yaptırım Tabanı (TL)', N'04.06.2013 tarihli ve 41139-5 sayılı EGM Genelgesi uyarınca ikamet harcından muaf tutulan G Grubu ülkeler için uygulanan 1 kat idari yaptırım tabanı (Yetişkinde 2 katı uygulanır).', 'Ceza', GETDATE(), 'SystemInit'),
    ('ULKE_FGRUBU', N'Norveç, Sırbistan, Fiji, Kuzey Mariana Adaları', N'F Grubu Ülkeleri (Özel Basamak Rejimi)', N'Özel kademeli günlük/aylık Türk Lirası artış cetveline tabi ülkeler.', 'Ulke', GETDATE(), 'SystemInit'),
    ('ULKE_GGRUBU', N'Danimarka, Kosova, Çek Cumhuriyeti, İrlanda, Nepal, Sri Lanka, Suriye, Türkmenistan', N'G Grubu Ülkeleri (Harçtan Muaf / İdari Yaptırım)', N'04.06.2013 tarih ve 41139-5 sayılı genelge ile ikamet harcından muaf olup Kabahatler Kanununa göre idari yaptırım uygulanan ülkeler.', 'Ulke', GETDATE(), 'SystemInit'),
    ('ULKE_BGRUBU', N'Filipinler, İsrail, Japonya, Kamboçya, Makedonya, Mali, Umman, Arnavutluk, Tacikistan', N'B Grubu Ülkeleri (Genelge 2011/68506)', N'1 aya kadar 0.5 USD/gün (5-14 USD), 1 aydan sonra 3.5 USD/ay uygulanan ülkeler.', 'Ulke', GETDATE(), 'SystemInit'),
    ('ULKE_CGRUBU', N'İspanya, Malta, Beyaz Rusya, Kuveyt, Belçika, Singapur, Tayvan, Cezayir, Lüksemburg, Ürdün', N'C Grubu Ülkeleri (Genelge 2011/68506)', N'1 aya kadar 0.4 USD/gün (4-9 USD), 1 aydan sonra 2.5 USD/ay uygulanan ülkeler.', 'Ulke', GETDATE(), 'SystemInit'),
    ('ULKE_DGRUBU', N'Hong Kong SAR - Çin, Mikronezya Federal Eyaletleri, Rusya Federasyonu, Etiyopya, Güney Kore', N'D Grubu Ülkeleri (Genelge 2011/68506)', N'1 aya kadar 0.3 USD/gün (3-7 USD), 1 aydan sonra 1.5 USD/ay uygulanan ülkeler.', 'Ulke', GETDATE(), 'SystemInit'),
    ('ULKE_EGRUBU', N'Fas, Fildişi Sahilleri, Irak, Sırbistan-Karadağ, Karadağ, Mısır, Tunus', N'E Grubu Ülkeleri (Genelge 2011/68506)', N'1 aya kadar 0.2 USD/gün (2-5 USD), 1 aydan sonra 0.5 USD/ay uygulanan ülkeler.', 'Ulke', GETDATE(), 'SystemInit');
END";
                    cmd.ExecuteNonQuery();
                }
            }
            catch { }
        }

        public static List<CezaParametreItem> GetAllParams()
        {
            var cached = HttpRuntime.Cache[CACHE_KEY] as List<CezaParametreItem>;
            if (cached != null) return cached;

            lock (_lock)
            {
                cached = HttpRuntime.Cache[CACHE_KEY] as List<CezaParametreItem>;
                if (cached != null) return cached;

                var list = new List<CezaParametreItem>();
                try
                {
                    EnsureSchema();
                    using (var con = OpenConnection())
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = "SELECT ParamKey, ParamValue, ParamTitle, ParamDescription, ParamGroup, UpdatedAt, ISNULL(UpdatedBy, '') AS UpdatedBy FROM dbo.CezaParametre ORDER BY ParamGroup, ParamKey";
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                list.Add(new CezaParametreItem
                                {
                                    ParamKey = reader["ParamKey"].ToString(),
                                    ParamValue = reader["ParamValue"].ToString(),
                                    ParamTitle = reader["ParamTitle"].ToString(),
                                    ParamDescription = reader["ParamDescription"] == DBNull.Value ? "" : reader["ParamDescription"].ToString(),
                                    ParamGroup = reader["ParamGroup"].ToString(),
                                    UpdatedAt = Convert.ToDateTime(reader["UpdatedAt"]),
                                    UpdatedBy = reader["UpdatedBy"].ToString()
                                });
                            }
                        }
                    }
                }
                catch
                {
                    // Fallback to empty list in catastrophic DB disconnect
                }

                HttpRuntime.Cache.Insert(CACHE_KEY, list, null, System.Web.Caching.Cache.NoAbsoluteExpiration, TimeSpan.FromHours(12));
                return list;
            }
        }

        public static string GetParamString(string key, string fallback = "")
        {
            if (string.IsNullOrWhiteSpace(key)) return fallback;
            var all = GetAllParams();
            var item = all.FirstOrDefault(x => string.Equals(x.ParamKey, key, StringComparison.OrdinalIgnoreCase));
            return (item != null && !string.IsNullOrWhiteSpace(item.ParamValue)) ? item.ParamValue.Trim() : fallback;
        }

        public static double GetParamDouble(string key, double fallback = 0)
        {
            string val = GetParamString(key, null);
            if (string.IsNullOrWhiteSpace(val)) return fallback;
            val = val.Replace(",", ".");
            double d;
            if (double.TryParse(val, NumberStyles.Any, CultureInfo.InvariantCulture, out d))
                return d;
            return fallback;
        }

        public static string[] GetCountryList(string groupKey, string[] fallback)
        {
            string raw = GetParamString(groupKey, null);
            if (string.IsNullOrWhiteSpace(raw)) return fallback;

            var list = raw.Split(new[] { ',', ';', '\n', '\r' }, StringSplitOptions.RemoveEmptyEntries)
                          .Select(s => s.Trim())
                          .Where(s => !string.IsNullOrWhiteSpace(s))
                          .ToArray();

            return (list.Length > 0) ? list : fallback;
        }

        public static bool UpdateParam(string key, string value, string updatedBy)
        {
            if (string.IsNullOrWhiteSpace(key)) return false;
            try
            {
                EnsureSchema();
                using (var con = OpenConnection())
                using (var cmd = con.CreateCommand())
                {
                    cmd.CommandText = @"
UPDATE dbo.CezaParametre 
SET ParamValue = @val, UpdatedAt = GETDATE(), UpdatedBy = @by 
WHERE ParamKey = @key";
                    cmd.Parameters.AddWithValue("@val", value ?? "");
                    cmd.Parameters.AddWithValue("@by", string.IsNullOrWhiteSpace(updatedBy) ? "Sistem" : updatedBy.Trim());
                    cmd.Parameters.AddWithValue("@key", key.Trim());
                    int rows = cmd.ExecuteNonQuery();
                    ClearCache();
                    return rows > 0;
                }
            }
            catch
            {
                return false;
            }
        }
    }
}
