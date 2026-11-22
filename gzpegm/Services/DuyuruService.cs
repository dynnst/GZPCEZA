using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;

namespace gzpegm.Services
{
    public class DuyuruService
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
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'E_Duyuru')
BEGIN
    CREATE TABLE dbo.E_Duyuru (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Baslik NVARCHAR(250) NOT NULL,
        Icerik NVARCHAR(MAX) NOT NULL,
        Kategori NVARCHAR(50) NOT NULL DEFAULT 'Genel',
        Oncelik INT NOT NULL DEFAULT 1,
        OlusturanUserId INT NULL,
        OlusturanAd NVARCHAR(150) NOT NULL,
        OlusturanSicil NVARCHAR(50) NULL,
        OlusturanRol NVARCHAR(50) NULL,
        Tarih DATETIME NOT NULL DEFAULT GETDATE(),
        Aktif BIT NOT NULL DEFAULT 1,
        GecerlilikTarihi DATETIME NULL
    );
    CREATE NONCLUSTERED INDEX IX_E_Duyuru_Aktif_Tarih ON dbo.E_Duyuru (Aktif, Tarih DESC);
END

-- Tablo boşsa başlangıç operasyonel duyuruları ekle
IF (SELECT COUNT(*) FROM dbo.E_Duyuru WHERE Aktif = 1) = 0
BEGIN
    INSERT INTO dbo.E_Duyuru (Baslik, Icerik, Kategori, Oncelik, OlusturanAd, OlusturanRol, Tarih, Aktif)
    VALUES 
    (N'2026 Yılı Mali Harç ve İdari Para Cezası Tarifesi Yürürlüktedir',
     N'2026 yılı için yeniden değerleme oranı (%25,49) sonrasında vize ve ikamet ihlali harçları güncellenmiştir. 1-90 gün günlük harç 467,60 TL, defter bedeli 1.345,00 TL ve 5326 s.K. m.32 idari para cezası 1.854,00 TL olarak uygulanacaktır.',
     N'Mevzuat', 3, N'Sistem Yöneticisi', N'Sistem Yöneticisi (Admin)', GETDATE(), 1),

    (N'Tahdit Kodları ve Şartlı Vize (V-84) İşlemleri Uygulama Esasları',
     N'Hudut kapılarımızda yolcu giriş ve çıkış işlemlerinde tahdit kodlarına ilişkin şerhlerin hassasiyetle kontrol edilmesi, V-84 taahhüt belgelerinin eksiksiz tanzim edilmesi gerekmektedir.',
     N'Genel', 2, N'Eğitim Birimi', N'Eğitim Birimi (Öğretmen)', DATEADD(MINUTE, -30, GETDATE()), 1);
END
";
                        context.Database.ExecuteSqlCommand(System.Data.Entity.TransactionalBehavior.DoNotEnsureTransaction, sql);
                    };

                    if (db != null)
                    {
                        exec(db);
                    }
                    else
                    {
                        using (var tempDb = new GZPEGM1())
                        {
                            exec(tempDb);
                        }
                    }
                    _schemaEnsured = true;
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("Duyuru EnsureSchema hatası: " + ex.Message);
                }
            }
        }

        public static bool CanManage(E_User user)
        {
            if (user == null) return false;
            if (string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase)) return true;
            if (string.Equals(user.Role, "Ogretmen", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(user.Role, "Teacher", StringComparison.OrdinalIgnoreCase)) return true;

            var auth = (user.fldAuth ?? "").Trim();
            var codes = auth.Split(new[] { ',', ';', ' ' }, StringSplitOptions.RemoveEmptyEntries).Select(x => x.Trim()).ToList();
            if (codes.Contains("2") || codes.Contains("6")) return true;

            var title = (user.fldTitle ?? "").ToLowerInvariant();
            if (title.Contains("öğretmen") || title.Contains("ogretmen") || title.Contains("eğitmen") || title.Contains("egitmen")) return true;

            return false;
        }

        public List<DuyuruItem> GetActiveDuyurular(int count = 10)
        {
            EnsureSchema();
            var list = new List<DuyuruItem>();
            try
            {
                using (var db = new GZPEGM1())
                {
                    var sql = @"
SELECT TOP (@p0) 
    Id, Baslik, Icerik, Kategori, Oncelik, 
    OlusturanUserId, OlusturanAd, OlusturanSicil, OlusturanRol, 
    Tarih, Aktif, GecerlilikTarihi
FROM dbo.E_Duyuru
WHERE Aktif = 1 AND (GecerlilikTarihi IS NULL OR GecerlilikTarihi > GETDATE())
ORDER BY Oncelik DESC, Tarih DESC";

                    list = db.Database.SqlQuery<DuyuruItem>(sql, count).ToList();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Duyurular getirilirken hata: " + ex.Message);
            }
            return list;
        }

        public bool AddDuyuru(string baslik, string icerik, string kategori, int oncelik, E_User author, out string error)
        {
            error = null;
            if (!CanManage(author))
            {
                error = "Yetkisiz işlem: Duyuru ekleme yetkisi yalnızca Yöneticiler (Admin) ve Eğitimcilere (Öğretmen) aittir.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(baslik) || baslik.Trim().Length < 3)
            {
                error = "Duyuru başlığı en az 3 karakter olmalıdır.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(icerik) || icerik.Trim().Length < 5)
            {
                error = "Duyuru içeriği en az 5 karakter olmalıdır.";
                return false;
            }

            EnsureSchema();

            try
            {
                var auth = (author.fldAuth ?? "").Trim();
                var codes = auth.Split(new[] { ',', ';', ' ' }, StringSplitOptions.RemoveEmptyEntries).Select(x => x.Trim()).ToList();

                string roleLabel = "Görevli";
                if (string.Equals(author.Role, "Admin", StringComparison.OrdinalIgnoreCase) || codes.Contains("2"))
                {
                    roleLabel = "Sistem Yöneticisi (Admin)";
                }
                else if (codes.Contains("6") || string.Equals(author.Role, "Ogretmen", StringComparison.OrdinalIgnoreCase))
                {
                    roleLabel = "Eğitim Birimi (Öğretmen)";
                }

                string authorName = $"{author.fldName} {author.fldLastName}".Trim();
                if (string.IsNullOrWhiteSpace(authorName)) authorName = "Personel";

                using (var db = new GZPEGM1())
                {
                    var sql = @"
INSERT INTO dbo.E_Duyuru (Baslik, Icerik, Kategori, Oncelik, OlusturanUserId, OlusturanAd, OlusturanSicil, OlusturanRol, Tarih, Aktif)
VALUES (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, GETDATE(), 1)";

                    db.Database.ExecuteSqlCommand(sql,
                        baslik.Trim(),
                        icerik.Trim(),
                        string.IsNullOrWhiteSpace(kategori) ? "Genel" : kategori.Trim(),
                        oncelik < 1 ? 1 : (oncelik > 3 ? 3 : oncelik),
                        author.fldId,
                        authorName,
                        author.fldSicil ?? "",
                        roleLabel);
                }
                return true;
            }
            catch (Exception ex)
            {
                error = "Duyuru kaydedilirken veritabanı hatası oluştu: " + ex.Message;
                return false;
            }
        }

        public bool DeleteDuyuru(int id, E_User author, out string error)
        {
            error = null;
            if (!CanManage(author))
            {
                error = "Yetkisiz işlem: Duyuru silme yetkisi yalnızca Yöneticiler (Admin) ve Eğitimcilere (Öğretmen) aittir.";
                return false;
            }

            EnsureSchema();

            try
            {
                using (var db = new GZPEGM1())
                {
                    var sql = "UPDATE dbo.E_Duyuru SET Aktif = 0 WHERE Id = @p0";
                    db.Database.ExecuteSqlCommand(sql, id);
                }
                return true;
            }
            catch (Exception ex)
            {
                error = "Duyuru silinirken veritabanı hatası oluştu: " + ex.Message;
                return false;
            }
        }
    }
}
