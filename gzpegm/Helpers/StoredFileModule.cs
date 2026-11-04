using System;
using System.IO;
using System.Web;
using System.Web.Hosting;

namespace gzpegm.Helpers
{
    /// <summary>
    /// Resim ve dosya isteklerini (files, Uploads, ccc) IIS seviyesinde akıllı yakalar.
    /// 1. Dosya projenin kendi klasöründe varsa anında güvenle sunar (Home logosu, mevcut kurslar ve profil resimleri asla bozulmaz).
    /// 2. Dosya projede yoksa masaüstü, harici HDD veya yapılandırılmış ExternalFileStorageRoot klasörünün
    ///    hem alt klasörlerinde hem de doğrudan ana dizininde arar ve anında stream eder.
    /// 3. URL-decode (%20, boşluk, Türkçe karakter) desteği ile tüm dosya adlarını eksiksiz bulur.
    /// Bu sayede IIS üzerinde hiçbir Sanal Dizin (Virtual Directory) ayarı yapmaya gerek kalmaz.
    /// </summary>
    public class StoredFileModule : IHttpModule
    {
        public void Init(HttpApplication context)
        {
            context.BeginRequest += OnBeginRequest;
        }

        public void Dispose()
        {
        }

        private void OnBeginRequest(object sender, EventArgs e)
        {
            var app = sender as HttpApplication;
            if (app == null) return;

            var request = app.Request;
            var rawPath = request.AppRelativeCurrentExecutionFilePath;
            if (string.IsNullOrEmpty(rawPath)) return;

            // Sadece ~/files/, ~/Uploads/, ~/ccc/ isteklerini kontrol et
            if (!rawPath.StartsWith("~/files/", StringComparison.OrdinalIgnoreCase) &&
                !rawPath.StartsWith("~/Uploads/", StringComparison.OrdinalIgnoreCase) &&
                !rawPath.StartsWith("~/ccc/", StringComparison.OrdinalIgnoreCase))
            {
                return;
            }

            // URL decode işlemi: %20, boşluklar, parantezler ve Türkçe karakterler için
            string decodedPath = HttpUtility.UrlDecode(rawPath);

            // 1. Öncelik: Dosya web sitesinin kendi fiziksel klasöründe zaten var mı?
            try
            {
                var localPhysical = HostingEnvironment.MapPath(decodedPath);
                if (!string.IsNullOrEmpty(localPhysical) && File.Exists(localPhysical))
                {
                    // Dosya yerel sitede mevcut - doğrudan güvenli stream et (logo, favicon ve yerel kurs resimleri)
                    ServeFile(app, localPhysical);
                    return;
                }
            }
            catch
            {
            }

            // 2. Öncelik: Harici depolama kökünü ve tüm olası veri klasörlerini ara
            var relativeTail = decodedPath.Substring(2).Replace('/', Path.DirectorySeparatorChar);
            string foundPath = FindPhysicalFile(relativeTail);

            if (!string.IsNullOrEmpty(foundPath) && File.Exists(foundPath))
            {
                ServeFile(app, foundPath);
            }
        }

        private static string FindPhysicalFile(string relativeTail)
        {
            string fileName = Path.GetFileName(relativeTail);
            string withoutFirstSegment = null;
            var slashIdx = relativeTail.IndexOf(Path.DirectorySeparatorChar);
            if (slashIdx >= 0)
            {
                withoutFirstSegment = relativeTail.Substring(slashIdx + 1);
            }

            // A) Web.config ExternalFileStorageRoot
            try
            {
                var configuredRoot = FileStorageHelper.GetConfiguredRoot();
                var match = ProbeRoot(configuredRoot, relativeTail, withoutFirstSegment, fileName);
                if (!string.IsNullOrEmpty(match)) return match;
            }
            catch
            {
            }

            // B) Bilinen tüm harici sürücü, masaüstü ve veri klasörleri
            string[] candidateRoots = new[]
            {
                @"C:\Users\313258\Desktop\veri",
                @"C:\Users\Naşit\Desktop\veri",
                @"C:\Users\fb\Desktop\veri",
                @"C:\veri",
                @"D:\veri",
                @"E:\veri",
                @"F:\veri",
                Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory), "veri")
            };

            foreach (var cand in candidateRoots)
            {
                try
                {
                    var match = ProbeRoot(cand, relativeTail, withoutFirstSegment, fileName);
                    if (!string.IsNullOrEmpty(match)) return match;
                }
                catch
                {
                }
            }

            return null;
        }

        private static string ProbeRoot(string root, string relativeTail, string withoutFirstSegment, string fileName)
        {
            if (string.IsNullOrWhiteSpace(root) || !Directory.Exists(root))
                return null;

            // 1. root\files\Egitim\dosya.jpg
            var p1 = Path.Combine(root, relativeTail);
            if (File.Exists(p1)) return p1;

            // 2. root\Egitim\dosya.jpg
            if (!string.IsNullOrEmpty(withoutFirstSegment))
            {
                var p2 = Path.Combine(root, withoutFirstSegment);
                if (File.Exists(p2)) return p2;
            }

            // 3. root\dosya.jpg (Kullanıcı resimleri doğrudan veri klasörüne düz attıysa)
            if (!string.IsNullOrEmpty(fileName))
            {
                var p3 = Path.Combine(root, fileName);
                if (File.Exists(p3)) return p3;

                // 4. Alt dizinlerde derinlemesine hızlı arama (örn. veri\kurslar\dosya.jpg veya veri\resimler\dosya.jpg)
                try
                {
                    var matches = Directory.GetFiles(root, fileName, SearchOption.AllDirectories);
                    if (matches != null && matches.Length > 0)
                        return matches[0];
                }
                catch
                {
                }
            }

            return null;
        }

        private static void ServeFile(HttpApplication app, string filePath)
        {
            try
            {
                var response = app.Response;
                response.Clear();
                response.ClearHeaders();
                response.ContentType = MimeMapping.GetMimeMapping(filePath);
                response.Cache.SetCacheability(HttpCacheability.Public);
                response.Cache.SetMaxAge(TimeSpan.FromDays(7));
                response.WriteFile(filePath);
                response.Flush();
                app.CompleteRequest();
            }
            catch
            {
            }
        }
    }
}
