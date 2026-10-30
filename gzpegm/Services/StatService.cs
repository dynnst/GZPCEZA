using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Entity.Core.EntityClient;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using gzpegm.Models;

namespace gzpegm.Services
{
    public class StatDepartmentDto
    {
        public int DepartmentId { get; set; }
        public int? BorderId { get; set; }
        public string DepartmentName { get; set; }
        public string Code { get; set; }
        public int DisplayOrder { get; set; }
        public bool IsActive { get; set; }
        public List<StatTableDto> Tables { get; set; } = new List<StatTableDto>();
    }

    public class StatTableDto
    {
        public int TableId { get; set; }
        public int DepartmentId { get; set; }
        public string TableTitle { get; set; }
        public string Description { get; set; }
        public int DisplayOrder { get; set; }
        public List<StatRowDto> Rows { get; set; } = new List<StatRowDto>();
    }

    public class StatRowDto
    {
        public int RowId { get; set; }
        public int TableId { get; set; }
        public string RowTitle { get; set; }
        public string Unit { get; set; }
        public int DisplayOrder { get; set; }
        public decimal CurrentDayValue { get; set; }
        public string Note { get; set; }
    }

    public class StatReportRowDto
    {
        public int RowId { get; set; }
        public string RowTitle { get; set; }
        public string Unit { get; set; }
        public decimal MonthPrevYear { get; set; }   // Örn: 2025 Mayıs
        public decimal MonthCurrYear { get; set; }   // Örn: 2026 Mayıs
        public decimal YtdPrevYear { get; set; }     // Örn: 2025 5 Aylık Kümülatif
        public decimal YtdCurrYear { get; set; }     // Örn: 2026 5 Aylık Kümülatif
        public decimal MonthDiff => MonthCurrYear - MonthPrevYear;
        public decimal YtdDiff => YtdCurrYear - YtdPrevYear;

        public double MonthChangePercent
        {
            get
            {
                if (MonthPrevYear > 0)
                    return (double)((MonthCurrYear - MonthPrevYear) / MonthPrevYear * 100);
                if (MonthCurrYear > 0)
                    return 100.0;
                return 0.0;
            }
        }

        public double YtdChangePercent
        {
            get
            {
                if (YtdPrevYear > 0)
                    return (double)((YtdCurrYear - YtdPrevYear) / YtdPrevYear * 100);
                if (YtdCurrYear > 0)
                    return 100.0;
                return 0.0;
            }
        }
    }

    public class StatReportTableDto
    {
        public int TableId { get; set; }
        public string TableTitle { get; set; }
        public List<StatReportRowDto> Rows { get; set; } = new List<StatReportRowDto>();

        public decimal TotalMonthPrevYear => Rows.Sum(r => r.MonthPrevYear);
        public decimal TotalMonthCurrYear => Rows.Sum(r => r.MonthCurrYear);
        public decimal TotalYtdPrevYear => Rows.Sum(r => r.YtdPrevYear);
        public decimal TotalYtdCurrYear => Rows.Sum(r => r.YtdCurrYear);
        public decimal TotalMonthDiff => TotalMonthCurrYear - TotalMonthPrevYear;
        public decimal TotalYtdDiff => TotalYtdCurrYear - TotalYtdPrevYear;

        public double TotalMonthChangePercent
        {
            get
            {
                if (TotalMonthPrevYear > 0)
                    return (double)((TotalMonthCurrYear - TotalMonthPrevYear) / TotalMonthPrevYear * 100);
                if (TotalMonthCurrYear > 0)
                    return 100.0;
                return 0.0;
            }
        }

        public double TotalYtdChangePercent
        {
            get
            {
                if (TotalYtdPrevYear > 0)
                    return (double)((TotalYtdCurrYear - TotalYtdPrevYear) / TotalYtdPrevYear * 100);
                if (TotalYtdCurrYear > 0)
                    return 100.0;
                return 0.0;
            }
        }
    }

    public class StatReportDepartmentDto
    {
        public int DepartmentId { get; set; }
        public string DepartmentName { get; set; }
        public List<StatReportTableDto> Tables { get; set; } = new List<StatReportTableDto>();
    }

    public class StatUserPermissionDto
    {
        public int PermissionId { get; set; }
        public int UserId { get; set; }
        public string UserFullName { get; set; }
        public string UserSicil { get; set; }
        public string UserBorder { get; set; }
        public int BorderId { get; set; }
        public string BorderName { get; set; }
        public int? DepartmentId { get; set; }
        public string DepartmentName { get; set; }
        public string PermissionRole { get; set; } // 'KapiAdmin', 'BirimEditor', 'Viewer'
        public DateTime AssignedDate { get; set; }
    }

    public class StatUserListItemDto
    {
        public int UserId { get; set; }
        public string Sicil { get; set; }
        public string FullName { get; set; }
        public string Border { get; set; }
    }

    public class StatPeriodCriteria
    {
        public int BorderId { get; set; }
        public int? DepartmentId { get; set; }
        public string Mode { get; set; } = "month"; // "month" (Standart Ay & Kümülatif), "range" (Özel Tarih / Gün Aralığı)
        public int Year { get; set; } = DateTime.Today.Year;
        public int? CompareYear { get; set; } // Kıyaslanacak yıl (Örn: 2024, 2019 vb. Null ise otomatik Year - 1)
        public int Month { get; set; } = DateTime.Today.Month;
        public int CumulativeMonths { get; set; } = 0; // 0 = Otomatik (seçilen aya kadar), 1..12 arası (örn: 1, 3, 6, 8, 12)
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public DateTime? CompareStartDate { get; set; }
        public DateTime? CompareEndDate { get; set; }

        public DateTime P1CurrStart { get; set; }
        public DateTime P1CurrEnd { get; set; }
        public DateTime P1PrevStart { get; set; }
        public DateTime P1PrevEnd { get; set; }

        public DateTime P2CurrStart { get; set; }
        public DateTime P2CurrEnd { get; set; }
        public DateTime P2PrevStart { get; set; }
        public DateTime P2PrevEnd { get; set; }

        public string P1GroupHeader { get; set; }
        public string P1CurrTitle { get; set; }
        public string P1PrevTitle { get; set; }

        public string P2GroupHeader { get; set; }
        public string P2CurrTitle { get; set; }
        public string P2PrevTitle { get; set; }

        public void ResolveDatesAndHeaders()
        {
            var culture = new CultureInfo("tr-TR");
            if (string.Equals(Mode, "range", StringComparison.OrdinalIgnoreCase) && StartDate.HasValue && EndDate.HasValue)
            {
                Mode = "range";
                P1CurrStart = StartDate.Value.Date;
                P1CurrEnd = EndDate.Value.Date;
                if (P1CurrEnd < P1CurrStart) P1CurrEnd = P1CurrStart;

                int daySpan = (P1CurrEnd - P1CurrStart).Days + 1;

                if (CompareStartDate.HasValue && CompareEndDate.HasValue)
                {
                    P1PrevStart = CompareStartDate.Value.Date;
                    P1PrevEnd = CompareEndDate.Value.Date;
                }
                else
                {
                    // Otomatik 1 yıl öncesinin aynı gün aralığı
                    P1PrevStart = P1CurrStart.AddYears(-1);
                    P1PrevEnd = P1CurrEnd.AddYears(-1);
                }

                P1GroupHeader = $"DÖNEM KARŞILAŞTIRMASI ({daySpan} GÜNLÜK)";
                P1CurrTitle = $"{P1CurrStart:dd.MM.yyyy} - {P1CurrEnd:dd.MM.yyyy}";
                P1PrevTitle = $"{P1PrevStart:dd.MM.yyyy} - {P1PrevEnd:dd.MM.yyyy}";

                // 2. KÜMÜLATİF DÖNEM: Yılbaşından seçilen bitiş tarihine kadar olan kümülatif gün
                P2CurrStart = new DateTime(P1CurrEnd.Year, 1, 1);
                P2CurrEnd = P1CurrEnd;

                P2PrevStart = new DateTime(P1PrevEnd.Year, 1, 1);
                P2PrevEnd = P1PrevEnd;

                int ytdDaySpan = (P2CurrEnd - P2CurrStart).Days + 1;
                P2GroupHeader = $"KÜMÜLATİF DÖNEM ({ytdDaySpan} GÜN)";
                P2CurrTitle = $"{P2CurrEnd.Year} ({P2CurrStart:dd.MM} - {P2CurrEnd:dd.MM})";
                P2PrevTitle = $"{P2PrevEnd.Year} ({P2PrevStart:dd.MM} - {P2PrevEnd:dd.MM})";
            }
            else
            {
                Mode = "month";
                if (Year < 2000 || Year > 2100) Year = DateTime.Today.Year;
                if (Month < 1 || Month > 12) Month = DateTime.Today.Month;
                int targetPrevYear = CompareYear.HasValue && CompareYear.Value >= 2000 ? CompareYear.Value : Year - 1;

                string monthName = culture.DateTimeFormat.GetMonthName(Month).ToUpper(culture);

                // 1. DÖNEM: Seçilen tek ay
                P1CurrStart = new DateTime(Year, Month, 1);
                P1CurrEnd = P1CurrStart.AddMonths(1).AddDays(-1);

                P1PrevStart = new DateTime(targetPrevYear, Month, 1);
                P1PrevEnd = P1PrevStart.AddMonths(1).AddDays(-1);

                P1GroupHeader = $"AYLIK KARŞILAŞTIRMA ({monthName} AYI)";
                P1CurrTitle = $"{Year} {monthName} AYI";
                P1PrevTitle = $"{targetPrevYear} {monthName} AYI";

                // 2. DÖNEM: Kümülatif Seçimi (1 aylık, 3 aylık, 6 aylık, 8 aylık vb.)
                int cumMonths = CumulativeMonths > 0 ? CumulativeMonths : Month;
                if (cumMonths > 12) cumMonths = 12;

                P2CurrStart = new DateTime(Year, 1, 1);
                P2CurrEnd = new DateTime(Year, cumMonths, 1).AddMonths(1).AddDays(-1);

                P2PrevStart = new DateTime(targetPrevYear, 1, 1);
                P2PrevEnd = new DateTime(targetPrevYear, cumMonths, 1).AddMonths(1).AddDays(-1);

                string cumSuffix = cumMonths == 12 ? "TÜM YIL (12 AYLIK)" : $"{cumMonths} AYLIK TOPLAM";
                P2GroupHeader = $"KÜMÜLATİF DÖNEM ({cumSuffix})";
                P2CurrTitle = $"{Year} {cumMonths} AYLIK";
                P2PrevTitle = $"{targetPrevYear} {cumMonths} AYLIK";
            }
        }
    }

    public static class StatService
    {
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

        public static int ResolveBorderId(E_User user)
        {
            if (user == null)
                return 14; // Varsayılan Gazipaşa

            try
            {
                using (var con = OpenConnection())
                using (var cmd = con.CreateCommand())
                {
                    // 1. Önce kullanıcının yetkilendirildiği kapıya bak (Öncelik: KapiAdmin, sonra BirimEditor)
                    cmd.CommandText = @"
                        SELECT TOP 1 BorderId 
                        FROM Stat_UserPermission 
                        WHERE UserId = @uid 
                        ORDER BY CASE WHEN PermissionRole = 'KapiAdmin' THEN 1 ELSE 2 END, PermissionId DESC";
                    cmd.Parameters.AddWithValue("@uid", user.fldId);
                    var permObj = cmd.ExecuteScalar();
                    if (permObj != null && permObj != DBNull.Value)
                    {
                        return Convert.ToInt32(permObj);
                    }

                    // 2. Özel bir yetki kaydı yoksa kullanıcının kendi fldBorder alanına göre eşleştir
                    if (!string.IsNullOrWhiteSpace(user.fldBorder))
                    {
                        cmd.Parameters.Clear();
                        cmd.CommandText = "SELECT TOP 1 fldId FROM E_Border WHERE fldName = @name OR fldName LIKE '%' + @name + '%' ORDER BY fldId";
                        cmd.Parameters.AddWithValue("@name", user.fldBorder.Trim());
                        var obj = cmd.ExecuteScalar();
                        if (obj != null && obj != DBNull.Value)
                            return Convert.ToInt32(obj);
                    }
                }
            }
            catch { }

            return 14;
        }

        private static string NormalizeTr(string s)
        {
            if (string.IsNullOrEmpty(s)) return "";
            return s.ToUpper(new CultureInfo("tr-TR"))
                .Replace("İ", "I")
                .Replace("Ğ", "G")
                .Replace("Ş", "S")
                .Replace("Ö", "O")
                .Replace("Ü", "U")
                .Replace("Ç", "C");
        }

        public static string ResolveValilikName(string borderName)
        {
            if (string.IsNullOrWhiteSpace(borderName))
                return "T.C. VALİLİĞİ";

            var culture = new CultureInfo("tr-TR");
            string bUpper = borderName.Trim().ToUpper(culture);
            string bClean = NormalizeTr(bUpper);

            if (bClean.Contains("DAIRE BASKANLIGI") || bClean.Contains("GENEL MUDURLUK"))
                return "EMNİYET GENEL MÜDÜRLÜĞÜ";

            var provinces = new (string OfficialName, string CleanKey)[]
            {
                ("AFYONKARAHİSAR", "AFYONKARAHISAR"),
                ("KAHRAMANMARAŞ", "KAHRAMANMARAS"),
                ("ŞANLIURFA", "SANLIURFA"),
                ("KIRKLARELİ", "KIRKLARELI"),
                ("DİYARBAKIR", "DIYARBAKIR"),
                ("ZONGULDAK", "ZONGULDAK"),
                ("GAZİANTEP", "GAZIANTEP"),
                ("GÜMÜŞHANE", "GUMUSHANE"),
                ("ÇANAKKALE", "CANAKKALE"),
                ("BALIKESİR", "BALIKESIR"),
                ("KASTAMONU", "KASTAMONU"),
                ("ESKİŞEHİR", "ESKISEHIR"),
                ("TEKİRDAĞ", "TEKIRDAG"),
                ("ERZİNCAN", "ERZINCAN"),
                ("ERZURUM", "ERZURUM"),
                ("ARDAHAN", "ARDAHAN"),
                ("ISPARTA", "ISPARTA"),
                ("İSTANBUL", "ISTANBUL"),
                ("ANTALYA", "ANTALYA"),
                ("GİRESUN", "GIRESUN"),
                ("HAKKARİ", "HAKKARI"),
                ("TRABZON", "TRABZON"),
                ("BAYBURT", "BAYBURT"),
                ("KARAMAN", "KARAMAN"),
                ("KIRIKKALE", "KIRIKKALE"),
                ("KIRŞEHİR", "KIRSEHIR"),
                ("KÜTAHYA", "KUTAHYA"),
                ("MALATYA", "MALATYA"),
                ("SAKARYA", "SAKARYA"),
                ("TUNCELİ", "TUNCELI"),
                ("AKSARAY", "AKSARAY"),
                ("BİLECİK", "BILECIK"),
                ("DENİZLİ", "DENIZLI"),
                ("KOCAELİ", "KOCAELI"),
                ("NEVŞEHİR", "NEVSEHIR"),
                ("OSMANİYE", "OSMANIYE"),
                ("BATMAN", "BATMAN"),
                ("BİNGÖL", "BINGOL"),
                ("BİTLİS", "BITLIS"),
                ("BURDUR", "BURDUR"),
                ("ÇANKIRI", "CANKIRI"),
                ("EDİRNE", "EDIRNE"),
                ("ELAZIĞ", "ELAZIG"),
                ("KARABÜK", "KARABUK"),
                ("MARDİN", "MARDIN"),
                ("MERSİN", "MERSIN"),
                ("SAMSUN", "SAMSUN"),
                ("YALOVA", "YALOVA"),
                ("ADANA", "ADANA"),
                ("BURSA", "BURSA"),
                ("ÇORUM", "CORUM"),
                ("DÜZCE", "DUZCE"),
                ("HATAY", "HATAY"),
                ("İZMİR", "IZMIR"),
                ("KİLİS", "KILIS"),
                ("KONYA", "KONYA"),
                ("MANİSA", "MANISA"),
                ("MUĞLA", "MUGLA"),
                ("NİĞDE", "NIGDE"),
                ("SİİRT", "SIIRT"),
                ("SİNOP", "SINOP"),
                ("SİVAS", "SIVAS"),
                ("ŞIRNAK", "SIRNAK"),
                ("TOKAT", "TOKAT"),
                ("UŞAK", "USAK"),
                ("AYDIN", "AYDIN"),
                ("BARTIN", "BARTIN"),
                ("ARTVİN", "ARTVIN"),
                ("IĞDIR", "IGDIR"),
                ("AĞRI", "AGRI"),
                ("BOLU", "BOLU"),
                ("KARS", "KARS"),
                ("ORDU", "ORDU"),
                ("RİZE", "RIZE"),
                ("VAN", "VAN"),
                ("AMASYA", "AMASYA"),
                ("ANKARA", "ANKARA"),
                ("KAYSERİ", "KAYSERI"),
                ("MUŞ", "MUS"),
                ("YOZGAT", "YOZGAT")
            };

            foreach (var p in provinces)
            {
                if (bClean.Contains(p.CleanKey))
                {
                    return p.OfficialName + " VALİLİĞİ";
                }
            }

            var districtMap = new (string CleanKey, string ProvinceName)[]
            {
                ("CESME", "İZMİR"),
                ("DIKILI", "İZMİR"),
                ("FOCA", "İZMİR"),
                ("SEFERIHISAR", "İZMİR"),
                ("ALIAGA", "İZMİR"),
                ("MARMARIS", "MUĞLA"),
                ("BODRUM", "MUĞLA"),
                ("DALAMAN", "MUĞLA"),
                ("FETHIYE", "MUĞLA"),
                ("DATCA", "MUĞLA"),
                ("YALIKAVAK", "MUĞLA"),
                ("GOCEK", "MUĞLA"),
                ("GULLUK", "MUĞLA"),
                ("TURGUT REIS", "MUĞLA"),
                ("TURGUTREIS", "MUĞLA"),
                ("BOZBURUN", "MUĞLA"),
                ("ISKENDERUN", "HATAY"),
                ("DORTYOL", "HATAY"),
                ("YAYLADAGI", "HATAY"),
                ("KUMLU", "HATAY"),
                ("ARSUZ", "HATAY"),
                ("MADENLI", "HATAY"),
                ("CILVEGOZU", "HATAY"),
                ("ISDEMIR", "HATAY"),
                ("CUKUROVA", "MERSİN"),
                ("TASUCU", "MERSİN"),
                ("AYDINCIK", "MERSİN"),
                ("YESILOVACIK", "MERSİN"),
                ("ERDEMLI", "MERSİN"),
                ("KUMKUYU", "MERSİN"),
                ("KAPADOKYA", "NEVŞEHİR"),
                ("KUSADASI", "AYDIN"),
                ("DIDIM", "AYDIN"),
                ("AYVALIK", "BALIKESİR"),
                ("BANDIRMA", "BALIKESİR"),
                ("MARMARA", "BALIKESİR"),
                ("KAPIKULE", "EDİRNE"),
                ("IPSALA", "EDİRNE"),
                ("HAMZABEYLI", "EDİRNE"),
                ("PAZARKULE", "EDİRNE"),
                ("UZUNKOPRU", "EDİRNE"),
                ("DEREKOY", "KIRKLARELİ"),
                ("IGNEADA", "KIRKLARELİ"),
                ("HOPA", "ARTVİN"),
                ("SARP", "ARTVİN"),
                ("BOZCAADA", "ÇANAKKALE"),
                ("GOKCEADA", "ÇANAKKALE"),
                ("KUCUKKUYU", "ÇANAKKALE"),
                ("KEPEZ", "ÇANAKKALE"),
                ("KARABIGA", "ÇANAKKALE"),
                ("ICDAS", "ÇANAKKALE"),
                ("ONCUPINAR", "KİLİS"),
                ("COBANBEY", "KİLİS"),
                ("ESENDERE", "HAKKARİ"),
                ("UZUMLU", "HAKKARİ"),
                ("DERECIK", "HAKKARİ"),
                ("DILUCU", "IĞDIR"),
                ("ALICAN", "IĞDIR"),
                ("TURKGOZU", "ARDAHAN"),
                ("AKTAS", "ARDAHAN"),
                ("KAPIKOY", "VAN"),
                ("GURBULAK", "AĞRI"),
                ("HABUR", "ŞIRNAK"),
                ("GAZIPASA", "ANTALYA"),
                ("ALANYA", "ANTALYA"),
                ("KAS", "ANTALYA"),
                ("FINIKE", "ANTALYA"),
                ("KEMER", "ANTALYA"),
                ("KOCA SEYIT", "BALIKESİR"),
                ("HASAN POLATKAN", "ESKİŞEHİR"),
                ("SULEYMAN DEMIREL", "ISPARTA"),
                ("ZAFER", "KÜTAHYA"),
                ("INCIRLIK", "ADANA"),
                ("CAYCUMA", "ZONGULDAK"),
                ("EREGLI", "ZONGULDAK"),
                ("MERZIFON", "AMASYA"),
                ("CENGIZ TOPEL", "KOCAELİ"),
                ("CORLU", "TEKİRDAĞ"),
                ("ASYAPORT", "TEKİRDAĞ"),
                ("BOTAS", "ADANA"),
                ("KARASU", "SAKARYA"),
                ("DERINCE", "KOCAELİ"),
                ("INEBOLU", "KASTAMONU"),
                ("UNYE", "ORDU"),
                ("FATSA", "ORDU"),
                ("NURI DEMIRAG", "SİVAS")
            };

            foreach (var d in districtMap)
            {
                if (bClean.Contains(d.CleanKey))
                {
                    return d.ProvinceName + " VALİLİĞİ";
                }
            }

            var parts = bUpper.Split(new char[] { ' ', '-', '_' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length > 0 && parts[0].Length >= 3)
            {
                return parts[0] + " VALİLİĞİ";
            }

            return "T.C. VALİLİĞİ";
        }

        public static bool IsSuperAdmin(E_User user)
        {
            if (user == null) return false;
            return string.Equals(user.Role?.Trim(), "Admin", StringComparison.OrdinalIgnoreCase);
        }

        public static bool IsKapiAdmin(E_User user, int borderId)
        {
            if (user == null) return false;
            if (IsSuperAdmin(user)) return true;

            try
            {
                using (var con = OpenConnection())
                using (var cmd = con.CreateCommand())
                {
                    cmd.CommandText = "SELECT COUNT(*) FROM Stat_UserPermission WHERE UserId = @uid AND BorderId = @bid AND PermissionRole = 'KapiAdmin'";
                    cmd.Parameters.AddWithValue("@uid", user.fldId);
                    cmd.Parameters.AddWithValue("@bid", borderId);
                    return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                }
            }
            catch { return false; }
        }

        public static bool IsAnyKapiAdmin(E_User user)
        {
            if (user == null) return false;
            if (IsSuperAdmin(user)) return true;

            try
            {
                using (var con = OpenConnection())
                using (var cmd = con.CreateCommand())
                {
                    cmd.CommandText = "SELECT COUNT(*) FROM Stat_UserPermission WHERE UserId = @uid AND PermissionRole = 'KapiAdmin'";
                    cmd.Parameters.AddWithValue("@uid", user.fldId);
                    return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                }
            }
            catch { return false; }
        }

        public static int? GetFirstAdminBorderId(E_User user)
        {
            if (user == null) return null;
            try
            {
                using (var con = OpenConnection())
                using (var cmd = con.CreateCommand())
                {
                    cmd.CommandText = "SELECT TOP 1 BorderId FROM Stat_UserPermission WHERE UserId = @uid AND PermissionRole = 'KapiAdmin' ORDER BY PermissionId DESC";
                    cmd.Parameters.AddWithValue("@uid", user.fldId);
                    var obj = cmd.ExecuteScalar();
                    if (obj != null && obj != DBNull.Value)
                        return Convert.ToInt32(obj);
                }
            }
            catch { }
            return null;
        }

        public static List<int> GetAdminBorderIds(E_User user)
        {
            var list = new List<int>();
            if (user == null) return list;
            try
            {
                using (var con = OpenConnection())
                using (var cmd = con.CreateCommand())
                {
                    cmd.CommandText = "SELECT DISTINCT BorderId FROM Stat_UserPermission WHERE UserId = @uid AND PermissionRole = 'KapiAdmin'";
                    cmd.Parameters.AddWithValue("@uid", user.fldId);
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            list.Add(r.GetInt32(0));
                        }
                    }
                }
            }
            catch { }
            return list;
        }

        public static bool CanEditDepartment(E_User user, int borderId, int departmentId)
        {
            if (user == null) return false;
            if (IsSuperAdmin(user)) return true;
            if (IsKapiAdmin(user, borderId)) return true;

            try
            {
                using (var con = OpenConnection())
                using (var cmd = con.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT COUNT(*) FROM Stat_UserPermission 
                        WHERE UserId = @uid AND BorderId = @bid 
                          AND (DepartmentId = @deptId OR DepartmentId IS NULL)";
                    cmd.Parameters.AddWithValue("@uid", user.fldId);
                    cmd.Parameters.AddWithValue("@bid", borderId);
                    cmd.Parameters.AddWithValue("@deptId", departmentId);
                    return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                }
            }
            catch { return false; }
        }

        public static List<StatDepartmentDto> GetDepartmentsWithStructure(int borderId, E_User user = null)
        {
            var list = new List<StatDepartmentDto>();
            bool isFullAdmin = user != null && (IsSuperAdmin(user) || IsKapiAdmin(user, borderId));

            using (var con = OpenConnection())
            {
                // 1. Departmanları getir (Kapıya özel veya genel olanlar)
                string deptSql = @"
                    SELECT DepartmentId, BorderId, DepartmentName, Code, DisplayOrder, IsActive
                    FROM Stat_Department
                    WHERE IsActive = 1 AND (BorderId IS NULL OR BorderId = @bid)
                    ORDER BY DisplayOrder, DepartmentName";

                var deptMap = new Dictionary<int, StatDepartmentDto>();
                using (var cmd = new SqlCommand(deptSql, con))
                {
                    cmd.Parameters.AddWithValue("@bid", borderId);
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            var d = new StatDepartmentDto
                            {
                                DepartmentId = r.GetInt32(0),
                                BorderId = r.IsDBNull(1) ? (int?)null : r.GetInt32(1),
                                DepartmentName = r.GetString(2),
                                Code = r.IsDBNull(3) ? "" : r.GetString(3),
                                DisplayOrder = r.GetInt32(4),
                                IsActive = r.GetBoolean(5)
                            };

                            // Yetki filtrelemesi
                            if (isFullAdmin || user == null || CanEditDepartment(user, borderId, d.DepartmentId))
                            {
                                deptMap[d.DepartmentId] = d;
                                list.Add(d);
                            }
                        }
                    }
                }

                if (deptMap.Count == 0) return list;

                // 2. Tablo şablonlarını getir
                string tableSql = @"
                    SELECT TableId, DepartmentId, TableTitle, Description, DisplayOrder
                    FROM Stat_TableTemplate
                    WHERE IsActive = 1 AND DepartmentId IN (" + string.Join(",", deptMap.Keys) + @")
                    ORDER BY DisplayOrder, TableTitle";

                var tableMap = new Dictionary<int, StatTableDto>();
                using (var cmd = new SqlCommand(tableSql, con))
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        var t = new StatTableDto
                        {
                            TableId = r.GetInt32(0),
                            DepartmentId = r.GetInt32(1),
                            TableTitle = r.GetString(2),
                            Description = r.IsDBNull(3) ? "" : r.GetString(3),
                            DisplayOrder = r.GetInt32(4)
                        };
                        tableMap[t.TableId] = t;
                        if (deptMap.TryGetValue(t.DepartmentId, out var dept))
                        {
                            dept.Tables.Add(t);
                        }
                    }
                }

                if (tableMap.Count == 0) return list;

                // 3. Gösterge satırlarını getir
                string rowSql = @"
                    SELECT RowId, TableId, RowTitle, Unit, DisplayOrder
                    FROM Stat_RowItem
                    WHERE IsActive = 1 AND TableId IN (" + string.Join(",", tableMap.Keys) + @")
                    ORDER BY DisplayOrder, RowTitle";

                using (var cmd = new SqlCommand(rowSql, con))
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        var row = new StatRowDto
                        {
                            RowId = r.GetInt32(0),
                            TableId = r.GetInt32(1),
                            RowTitle = r.GetString(2),
                            Unit = r.IsDBNull(3) ? "Adet" : r.GetString(3),
                            DisplayOrder = r.GetInt32(4)
                        };
                        if (tableMap.TryGetValue(row.TableId, out var tbl))
                        {
                            tbl.Rows.Add(row);
                        }
                    }
                }
            }

            return list;
        }

        public static List<StatDepartmentDto> GetDailyEntrySheet(int borderId, DateTime date, E_User user = null)
        {
            var depts = GetDepartmentsWithStructure(borderId, user);
            var rowValues = new Dictionary<int, decimal>();
            var rowNotes = new Dictionary<int, string>();

            using (var con = OpenConnection())
            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = "SELECT RowId, Value, Note FROM Stat_DailyValue WHERE BorderId = @bid AND EntryDate = @date";
                cmd.Parameters.AddWithValue("@bid", borderId);
                cmd.Parameters.AddWithValue("@date", date.Date);
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        int rowId = r.GetInt32(0);
                        decimal val = r.GetDecimal(1);
                        string note = r.IsDBNull(2) ? "" : r.GetString(2);
                        rowValues[rowId] = val;
                        rowNotes[rowId] = note;
                    }
                }
            }

            foreach (var d in depts)
            {
                foreach (var t in d.Tables)
                {
                    foreach (var r in t.Rows)
                    {
                        if (rowValues.TryGetValue(r.RowId, out decimal v))
                        {
                            r.CurrentDayValue = v;
                        }
                        if (rowNotes.TryGetValue(r.RowId, out string n))
                        {
                            r.Note = n;
                        }
                    }
                }
            }

            return depts;
        }

        public static bool SaveDailyValue(int borderId, int rowId, DateTime date, decimal value, string note, int userId)
        {
            using (var con = OpenConnection())
            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = @"
                    MERGE INTO Stat_DailyValue AS target
                    USING (SELECT @bid AS BorderId, @rid AS RowId, @date AS EntryDate) AS source
                    ON target.BorderId = source.BorderId AND target.RowId = source.RowId AND target.EntryDate = source.EntryDate
                    WHEN MATCHED THEN
                        UPDATE SET Value = @val, Note = @note, UpdatedByUserId = @uid, LastUpdated = GETDATE()
                    WHEN NOT MATCHED THEN
                        INSERT (BorderId, RowId, EntryDate, Value, Note, UpdatedByUserId, LastUpdated)
                        VALUES (@bid, @rid, @date, @val, @note, @uid, GETDATE());";

                cmd.Parameters.AddWithValue("@bid", borderId);
                cmd.Parameters.AddWithValue("@rid", rowId);
                cmd.Parameters.AddWithValue("@date", date.Date);
                cmd.Parameters.AddWithValue("@val", value);
                cmd.Parameters.AddWithValue("@note", string.IsNullOrWhiteSpace(note) ? (object)DBNull.Value : note.Trim());
                cmd.Parameters.AddWithValue("@uid", userId);

                return cmd.ExecuteNonQuery() > 0;
            }
        }

        public static List<StatReportDepartmentDto> GetComparativeReport(StatPeriodCriteria criteria)
        {
            if (criteria == null) criteria = new StatPeriodCriteria();
            criteria.ResolveDatesAndHeaders();

            var result = new List<StatReportDepartmentDto>();

            using (var con = OpenConnection())
            {
                // Filtre
                string deptFilter = criteria.DepartmentId.HasValue ? " AND d.DepartmentId = @did " : "";

                string sql = @"
                    SELECT 
                        d.DepartmentId, d.DepartmentName,
                        t.TableId, t.TableTitle,
                        r.RowId, r.RowTitle, r.Unit,
                        ISNULL(SUM(CASE WHEN v.EntryDate BETWEEN @p1pStart AND @p1pEnd THEN v.Value ELSE 0 END), 0) AS MonthPrevYear,
                        ISNULL(SUM(CASE WHEN v.EntryDate BETWEEN @p1cStart AND @p1cEnd THEN v.Value ELSE 0 END), 0) AS MonthCurrYear,
                        ISNULL(SUM(CASE WHEN v.EntryDate BETWEEN @p2pStart AND @p2pEnd THEN v.Value ELSE 0 END), 0) AS YtdPrevYear,
                        ISNULL(SUM(CASE WHEN v.EntryDate BETWEEN @p2cStart AND @p2cEnd THEN v.Value ELSE 0 END), 0) AS YtdCurrYear
                    FROM Stat_Department d
                    INNER JOIN Stat_TableTemplate t ON t.DepartmentId = d.DepartmentId AND t.IsActive = 1
                    INNER JOIN Stat_RowItem r ON r.TableId = t.TableId AND r.IsActive = 1
                    LEFT JOIN Stat_DailyValue v ON v.RowId = r.RowId AND v.BorderId = @bid
                    WHERE d.IsActive = 1 AND (d.BorderId IS NULL OR d.BorderId = @bid) " + deptFilter + @"
                    GROUP BY d.DepartmentId, d.DepartmentName, d.DisplayOrder,
                             t.TableId, t.TableTitle, t.DisplayOrder,
                             r.RowId, r.RowTitle, r.Unit, r.DisplayOrder
                    ORDER BY d.DisplayOrder, d.DepartmentName, t.DisplayOrder, t.TableTitle, r.DisplayOrder, r.RowTitle";

                var deptMap = new Dictionary<int, StatReportDepartmentDto>();
                var tableMap = new Dictionary<int, StatReportTableDto>();

                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@bid", criteria.BorderId);
                    cmd.Parameters.AddWithValue("@p1pStart", criteria.P1PrevStart);
                    cmd.Parameters.AddWithValue("@p1pEnd", criteria.P1PrevEnd);
                    cmd.Parameters.AddWithValue("@p1cStart", criteria.P1CurrStart);
                    cmd.Parameters.AddWithValue("@p1cEnd", criteria.P1CurrEnd);
                    cmd.Parameters.AddWithValue("@p2pStart", criteria.P2PrevStart);
                    cmd.Parameters.AddWithValue("@p2pEnd", criteria.P2PrevEnd);
                    cmd.Parameters.AddWithValue("@p2cStart", criteria.P2CurrStart);
                    cmd.Parameters.AddWithValue("@p2cEnd", criteria.P2CurrEnd);
                    if (criteria.DepartmentId.HasValue) cmd.Parameters.AddWithValue("@did", criteria.DepartmentId.Value);

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int dId = reader.GetInt32(0);
                            string dName = reader.GetString(1);
                            int tId = reader.GetInt32(2);
                            string tTitle = reader.GetString(3);
                            int rId = reader.GetInt32(4);
                            string rTitle = reader.GetString(5);
                            string unit = reader.IsDBNull(6) ? "Adet" : reader.GetString(6);
                            decimal mPrev = reader.GetDecimal(7);
                            decimal mCurr = reader.GetDecimal(8);
                            decimal yPrev = reader.GetDecimal(9);
                            decimal yCurr = reader.GetDecimal(10);

                            if (!deptMap.TryGetValue(dId, out var deptDto))
                            {
                                deptDto = new StatReportDepartmentDto { DepartmentId = dId, DepartmentName = dName };
                                deptMap[dId] = deptDto;
                                result.Add(deptDto);
                            }

                            if (!tableMap.TryGetValue(tId, out var tblDto))
                            {
                                tblDto = new StatReportTableDto { TableId = tId, TableTitle = tTitle };
                                tableMap[tId] = tblDto;
                                deptDto.Tables.Add(tblDto);
                            }

                            tblDto.Rows.Add(new StatReportRowDto
                            {
                                RowId = rId,
                                RowTitle = rTitle,
                                Unit = unit,
                                MonthPrevYear = mPrev,
                                MonthCurrYear = mCurr,
                                YtdPrevYear = yPrev,
                                YtdCurrYear = yCurr
                            });
                        }
                    }
                }
            }

            return result;
        }

        public static List<StatReportDepartmentDto> GetComparativeReport(int borderId, int? departmentId, int year, int month)
        {
            var crit = new StatPeriodCriteria
            {
                BorderId = borderId,
                DepartmentId = departmentId,
                Mode = "month",
                Year = year,
                Month = month,
                CumulativeMonths = month
            };
            return GetComparativeReport(crit);
        }

        // ====================================================================================
        // YALNIZCA ADMİN YÖNETİM METOTLARI (EKLEME / DÜZENLEME / SİLME)
        // ====================================================================================

        public static int SaveDepartment(int id, int? borderId, string name, string code, int order)
        {
            using (var con = OpenConnection())
            using (var cmd = con.CreateCommand())
            {
                if (id <= 0)
                {
                    cmd.CommandText = @"
                        INSERT INTO Stat_Department (BorderId, DepartmentName, Code, DisplayOrder, IsActive)
                        VALUES (@bid, @name, @code, @order, 1);
                        SELECT SCOPE_IDENTITY();";
                }
                else
                {
                    cmd.CommandText = @"
                        UPDATE Stat_Department 
                        SET DepartmentName = @name, Code = @code, DisplayOrder = @order, BorderId = @bid
                        WHERE DepartmentId = @id;
                        SELECT @id;";
                    cmd.Parameters.AddWithValue("@id", id);
                }

                cmd.Parameters.AddWithValue("@bid", borderId.HasValue ? (object)borderId.Value : DBNull.Value);
                cmd.Parameters.AddWithValue("@name", name.Trim());
                cmd.Parameters.AddWithValue("@code", string.IsNullOrWhiteSpace(code) ? (object)DBNull.Value : code.Trim());
                cmd.Parameters.AddWithValue("@order", order);

                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        public static int SaveTableTemplate(int id, int deptId, string title, string desc, int order)
        {
            using (var con = OpenConnection())
            using (var cmd = con.CreateCommand())
            {
                if (id <= 0)
                {
                    cmd.CommandText = @"
                        INSERT INTO Stat_TableTemplate (DepartmentId, TableTitle, Description, DisplayOrder, IsActive)
                        VALUES (@did, @title, @desc, @order, 1);
                        SELECT SCOPE_IDENTITY();";
                }
                else
                {
                    cmd.CommandText = @"
                        UPDATE Stat_TableTemplate
                        SET TableTitle = @title, Description = @desc, DisplayOrder = @order
                        WHERE TableId = @id;
                        SELECT @id;";
                    cmd.Parameters.AddWithValue("@id", id);
                }

                cmd.Parameters.AddWithValue("@did", deptId);
                cmd.Parameters.AddWithValue("@title", title.Trim());
                cmd.Parameters.AddWithValue("@desc", string.IsNullOrWhiteSpace(desc) ? (object)DBNull.Value : desc.Trim());
                cmd.Parameters.AddWithValue("@order", order);

                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        public static int SaveRowItem(int id, int tableId, string title, string unit, int order)
        {
            using (var con = OpenConnection())
            using (var cmd = con.CreateCommand())
            {
                if (id <= 0)
                {
                    cmd.CommandText = @"
                        INSERT INTO Stat_RowItem (TableId, RowTitle, Unit, DisplayOrder, IsActive)
                        VALUES (@tid, @title, @unit, @order, 1);
                        SELECT SCOPE_IDENTITY();";
                }
                else
                {
                    cmd.CommandText = @"
                        UPDATE Stat_RowItem
                        SET RowTitle = @title, Unit = @unit, DisplayOrder = @order
                        WHERE RowId = @id;
                        SELECT @id;";
                    cmd.Parameters.AddWithValue("@id", id);
                }

                cmd.Parameters.AddWithValue("@tid", tableId);
                cmd.Parameters.AddWithValue("@title", title.Trim());
                cmd.Parameters.AddWithValue("@unit", string.IsNullOrWhiteSpace(unit) ? "Adet" : unit.Trim());
                cmd.Parameters.AddWithValue("@order", order);

                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        public static bool DeleteDepartment(int id)
        {
            using (var con = OpenConnection())
            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = "UPDATE Stat_Department SET IsActive = 0 WHERE DepartmentId = @id";
                cmd.Parameters.AddWithValue("@id", id);
                return cmd.ExecuteNonQuery() > 0;
            }
        }

        public static bool DeleteTable(int id)
        {
            using (var con = OpenConnection())
            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = "UPDATE Stat_TableTemplate SET IsActive = 0 WHERE TableId = @id";
                cmd.Parameters.AddWithValue("@id", id);
                return cmd.ExecuteNonQuery() > 0;
            }
        }

        public static bool DeleteRow(int id)
        {
            using (var con = OpenConnection())
            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = "UPDATE Stat_RowItem SET IsActive = 0 WHERE RowId = @id";
                cmd.Parameters.AddWithValue("@id", id);
                return cmd.ExecuteNonQuery() > 0;
            }
        }

        // ====================================================================================
        // KULLANICI VE KAPI YETKİLENDİRME İŞLEMLERİ (STAT_USERPERMISSION)
        // ====================================================================================

        public static List<StatUserPermissionDto> GetPermissions(int borderId)
        {
            var list = new List<StatUserPermissionDto>();
            using (var con = OpenConnection())
            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = @"
                    SELECT 
                        p.PermissionId,
                        p.UserId,
                        ISNULL(u.fldName, '') + ' ' + ISNULL(u.fldLastName, '') AS UserFullName,
                        ISNULL(u.fldSicil, '') AS UserSicil,
                        ISNULL(u.fldBorder, '') AS UserBorder,
                        p.BorderId,
                        ISNULL(b.fldName, '') AS BorderName,
                        p.DepartmentId,
                        ISNULL(d.DepartmentName, 'Tüm Bürolar (Kapı Geneli)') AS DepartmentName,
                        p.PermissionRole,
                        p.AssignedDate
                    FROM Stat_UserPermission p
                    INNER JOIN E_User u ON p.UserId = u.fldId
                    INNER JOIN E_Border b ON p.BorderId = b.fldId
                    LEFT JOIN Stat_Department d ON p.DepartmentId = d.DepartmentId
                    WHERE p.BorderId = @bid
                    ORDER BY p.PermissionRole, u.fldName";
                cmd.Parameters.AddWithValue("@bid", borderId);

                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        list.Add(new StatUserPermissionDto
                        {
                            PermissionId = r.GetInt32(0),
                            UserId = r.GetInt32(1),
                            UserFullName = r.GetString(2),
                            UserSicil = r.GetString(3),
                            UserBorder = r.GetString(4),
                            BorderId = r.GetInt32(5),
                            BorderName = r.GetString(6),
                            DepartmentId = r.IsDBNull(7) ? (int?)null : r.GetInt32(7),
                            DepartmentName = r.GetString(8),
                            PermissionRole = r.GetString(9),
                            AssignedDate = r.GetDateTime(10)
                        });
                    }
                }
            }
            return list;
        }

        public static bool SavePermission(int permissionId, int userId, int borderId, int? departmentId, string role)
        {
            using (var con = OpenConnection())
            using (var cmd = con.CreateCommand())
            {
                if (permissionId <= 0)
                {
                    cmd.CommandText = @"
                        IF EXISTS (SELECT 1 FROM Stat_UserPermission WHERE UserId = @uid AND BorderId = @bid AND ((DepartmentId = @did) OR (DepartmentId IS NULL AND @did IS NULL)))
                        BEGIN
                            UPDATE Stat_UserPermission 
                            SET PermissionRole = @role, AssignedDate = GETDATE()
                            WHERE UserId = @uid AND BorderId = @bid AND ((DepartmentId = @did) OR (DepartmentId IS NULL AND @did IS NULL));
                        END
                        ELSE
                        BEGIN
                            INSERT INTO Stat_UserPermission (UserId, BorderId, DepartmentId, PermissionRole, AssignedDate)
                            VALUES (@uid, @bid, @did, @role, GETDATE());
                        END";
                }
                else
                {
                    cmd.CommandText = @"
                        UPDATE Stat_UserPermission 
                        SET UserId = @uid, BorderId = @bid, DepartmentId = @did, PermissionRole = @role, AssignedDate = GETDATE()
                        WHERE PermissionId = @pid";
                    cmd.Parameters.AddWithValue("@pid", permissionId);
                }

                cmd.Parameters.AddWithValue("@uid", userId);
                cmd.Parameters.AddWithValue("@bid", borderId);
                cmd.Parameters.AddWithValue("@did", departmentId.HasValue && departmentId.Value > 0 ? (object)departmentId.Value : DBNull.Value);
                cmd.Parameters.AddWithValue("@role", string.IsNullOrWhiteSpace(role) ? "BirimEditor" : role.Trim());

                return cmd.ExecuteNonQuery() > 0;
            }
        }

        public static bool DeletePermission(int permissionId)
        {
            using (var con = OpenConnection())
            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = "DELETE FROM Stat_UserPermission WHERE PermissionId = @pid";
                cmd.Parameters.AddWithValue("@pid", permissionId);
                return cmd.ExecuteNonQuery() > 0;
            }
        }

        public static List<StatUserListItemDto> GetAllUsers(int? borderId = null)
        {
            var list = new List<StatUserListItemDto>();
            using (var con = OpenConnection())
            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = @"
                    SELECT fldId, ISNULL(fldSicil, ''), ISNULL(fldName, '') + ' ' + ISNULL(fldLastName, ''), ISNULL(fldBorder, '') 
                    FROM E_User 
                    WHERE (IsActive = 1 OR fldActive = '1')
                    ORDER BY fldName, fldLastName";

                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        list.Add(new StatUserListItemDto
                        {
                            UserId = r.GetInt32(0),
                            Sicil = r.GetString(1),
                            FullName = r.GetString(2),
                            Border = r.GetString(3)
                        });
                    }
                }
            }
            return list;
        }
    }
}
