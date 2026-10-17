using gzpegm.Cont;
using gzpegm.Helpers;
using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Entity.Core.EntityClient;
using System.Data.SqlClient;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    /// <summary>
    /// Sunucu sağlık kontrolü için basit endpoint
    /// </summary>
    public class HealthController : Controller
    {
        // GET: /Health
        public ActionResult Index()
        {
            return Content("OK", "text/plain");
        }

        // GET: /Health/Check
        public ActionResult Check()
        {
            try
            {
                // Veritabanı bağlantısı kontrolü
                using (var db = new Models.GZPEGM1())
                {
                    var dbHealthy = db.Database.Exists();
                    if (dbHealthy)
                    {
                        return Content("OK", "text/plain");
                    }
                }
            }
            catch
            {
                Response.StatusCode = 503; // Service Unavailable
                return Content("Database Error", "text/plain");
            }

            Response.StatusCode = 503;
            return Content("Error", "text/plain");
        }

        [UserAuthorize(Users = "2")]
        [Route("SistemSaglik")]
        public ActionResult Dashboard()
        {
            var model = BuildHealthReport();
            return View(model);
        }

        private SystemHealthViewModel BuildHealthReport()
        {
            var model = new SystemHealthViewModel
            {
                GeneratedAt = DateTime.Now,
                ApplicationPath = AppDomain.CurrentDomain.BaseDirectory,
                PublicBaseUrl = ConfigurationManager.AppSettings["PublicBaseUrl"],
                ExternalFileStorageRoot = FileStorageHelper.GetConfiguredRoot(),
                MachineName = Environment.MachineName,
                UserName = Environment.UserName,
                OperatingSystem = Environment.OSVersion.ToString(),
                DotNetVersion = Environment.Version.ToString(),
                Is64BitProcess = Environment.Is64BitProcess,
                ServerSoftware = Request.ServerVariables["SERVER_SOFTWARE"],
                AppPoolName = Request.ServerVariables["APP_POOL_ID"],
                ProcessName = Process.GetCurrentProcess().ProcessName,
                ServerRole = ServerFailoverHelper.GetCurrentServerRole(),
                PrimaryServerUrl = ServerFailoverHelper.PrimaryServerUrl,
                BackupServerUrl = ServerFailoverHelper.BackupServerUrl,
                IsPrimaryServerOnline = ServerFailoverHelper.CheckIfPrimaryIsOnline(),
                IsRedirectActive = ServerFailoverHelper.IsBackupServer && ServerFailoverHelper.CheckIfPrimaryIsOnline(),
                LocalIPAddresses = ServerFailoverHelper.GetLocalIPv4Addresses()
            };

            model.Database = CheckDatabase();
            model.StorageChecks.Add(CheckFolder("Dış Dosya Depolama Kökü", model.ExternalFileStorageRoot, true));
            model.StorageChecks.Add(CheckFolder("Upload Klasörü", FileStorageHelper.MapPath(Server, "~/Uploads/"), true));
            model.StorageChecks.Add(CheckFolder("Eğitim / Dosya Klasörü", FileStorageHelper.MapPath(Server, "~/files/"), true));
            model.StorageChecks.Add(CheckFolder("CCC Klasörü", FileStorageHelper.MapPath(Server, "~/ccc/"), true));
            model.StorageChecks.Add(CheckFolder("Log Klasörü", Server.MapPath("~/Logs/"), true));
            model.StorageChecks.Add(CheckFolder("App_Data Klasörü", Server.MapPath("~/App_Data/"), false));

            var diskRoots = model.StorageChecks
                .Where(x => !string.IsNullOrWhiteSpace(x.Path))
                .Select(x => Path.GetPathRoot(x.Path))
                .Where(x => !string.IsNullOrWhiteSpace(x))
                .Distinct(StringComparer.OrdinalIgnoreCase);

            foreach (var root in diskRoots)
            {
                model.Disks.Add(CheckDisk(root));
            }

            model.OverallStatus = CalculateOverallStatus(model);
            return model;
        }

        private HealthCheckItem CheckDatabase()
        {
            var item = new HealthCheckItem
            {
                Name = "Veritabanı Bağlantısı",
                Category = "Database"
            };

            try
            {
                var sw = Stopwatch.StartNew();
                using (var db = new GZPEGM1())
                {
                    var exists = db.Database.Exists();
                    var userCount = exists ? db.E_User.Count() : 0;
                    sw.Stop();

                    item.Status = exists ? HealthStatus.Ok : HealthStatus.Error;
                    item.Message = exists
                        ? $"Bağlantı başarılı. Kullanıcı sayısı: {userCount}. Süre: {sw.ElapsedMilliseconds} ms."
                        : "Veritabanı bulunamadı veya erişilemiyor.";
                    item.Path = GetDatabaseSummary();
                }
            }
            catch (Exception ex)
            {
                item.Status = HealthStatus.Error;
                item.Message = "Veritabanı kontrolünde hata: " + ex.Message;
                item.Path = GetDatabaseSummary();
            }

            return item;
        }

        private HealthCheckItem CheckFolder(string name, string path, bool testWrite)
        {
            var item = new HealthCheckItem
            {
                Name = name,
                Category = "Storage",
                Path = path
            };

            if (string.IsNullOrWhiteSpace(path))
            {
                item.Status = HealthStatus.Warning;
                item.Message = "Yol tanımlı değil.";
                return item;
            }

            try
            {
                Directory.CreateDirectory(path);
                var exists = Directory.Exists(path);
                if (!exists)
                {
                    item.Status = HealthStatus.Error;
                    item.Message = "Klasör oluşturulamadı veya bulunamadı.";
                    return item;
                }

                if (testWrite)
                {
                    var testFile = Path.Combine(path, ".health_write_test_" + Guid.NewGuid().ToString("N") + ".tmp");
                    System.IO.File.WriteAllText(testFile, "ok");
                    System.IO.File.Delete(testFile);
                    item.Message = "Klasör mevcut ve yazma/silme izni var.";
                }
                else
                {
                    item.Message = "Klasör mevcut.";
                }

                item.Status = HealthStatus.Ok;
            }
            catch (Exception ex)
            {
                item.Status = HealthStatus.Error;
                item.Message = "Klasör kontrolünde hata: " + ex.Message;
            }

            return item;
        }

        private DiskHealthItem CheckDisk(string root)
        {
            var item = new DiskHealthItem { Name = root };
            try
            {
                var drive = new DriveInfo(root);
                item.TotalBytes = drive.TotalSize;
                item.FreeBytes = drive.AvailableFreeSpace;
                item.Status = item.FreePercent < 10 ? HealthStatus.Error : item.FreePercent < 20 ? HealthStatus.Warning : HealthStatus.Ok;
                item.Message = item.Status == HealthStatus.Ok
                    ? "Disk alanı yeterli görünüyor."
                    : item.Status == HealthStatus.Warning
                        ? "Disk alanı azalmış; temizlik planlanmalı."
                        : "Disk alanı kritik seviyede.";
            }
            catch (Exception ex)
            {
                item.Status = HealthStatus.Error;
                item.Message = "Disk bilgisi okunamadı: " + ex.Message;
            }

            return item;
        }

        private string GetDatabaseSummary()
        {
            try
            {
                var cs = ConfigurationManager.ConnectionStrings["GZPEGM1"]?.ConnectionString;
                if (string.IsNullOrWhiteSpace(cs)) return "GZPEGM1 connection string bulunamadı.";

                var entityBuilder = new EntityConnectionStringBuilder(cs);
                var sqlBuilder = new SqlConnectionStringBuilder(entityBuilder.ProviderConnectionString);
                return $"Sunucu: {sqlBuilder.DataSource}, Veritabanı: {sqlBuilder.InitialCatalog}";
            }
            catch
            {
                return "Veritabanı bağlantı özeti okunamadı.";
            }
        }

        private HealthStatus CalculateOverallStatus(SystemHealthViewModel model)
        {
            var statuses = new List<HealthStatus> { model.Database.Status };
            statuses.AddRange(model.StorageChecks.Select(x => x.Status));
            statuses.AddRange(model.Disks.Select(x => x.Status));

            if (statuses.Any(x => x == HealthStatus.Error)) return HealthStatus.Error;
            if (statuses.Any(x => x == HealthStatus.Warning)) return HealthStatus.Warning;
            return HealthStatus.Ok;
        }
    }

    public enum HealthStatus
    {
        Ok,
        Warning,
        Error
    }

    public class SystemHealthViewModel
    {
        public DateTime GeneratedAt { get; set; }
        public HealthStatus OverallStatus { get; set; }
        public HealthCheckItem Database { get; set; }
        public List<HealthCheckItem> StorageChecks { get; set; } = new List<HealthCheckItem>();
        public List<DiskHealthItem> Disks { get; set; } = new List<DiskHealthItem>();
        public string ApplicationPath { get; set; }
        public string PublicBaseUrl { get; set; }
        public string ExternalFileStorageRoot { get; set; }
        public string MachineName { get; set; }
        public string UserName { get; set; }
        public string OperatingSystem { get; set; }
        public string DotNetVersion { get; set; }
        public bool Is64BitProcess { get; set; }
        public string ServerSoftware { get; set; }
        public string AppPoolName { get; set; }
        public string ProcessName { get; set; }
        public string ServerRole { get; set; }
        public string PrimaryServerUrl { get; set; }
        public string BackupServerUrl { get; set; }
        public bool IsPrimaryServerOnline { get; set; }
        public bool IsRedirectActive { get; set; }
        public string[] LocalIPAddresses { get; set; }
    }

    public class HealthCheckItem
    {
        public string Category { get; set; }
        public string Name { get; set; }
        public HealthStatus Status { get; set; }
        public string Message { get; set; }
        public string Path { get; set; }
    }

    public class DiskHealthItem
    {
        public string Name { get; set; }
        public HealthStatus Status { get; set; }
        public string Message { get; set; }
        public long TotalBytes { get; set; }
        public long FreeBytes { get; set; }
        public decimal FreePercent => TotalBytes <= 0 ? 0 : Math.Round((decimal)FreeBytes * 100 / TotalBytes, 2);
    }
}
