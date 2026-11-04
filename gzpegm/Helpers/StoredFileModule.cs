using System;
using System.IO;
using System.Web;
using System.Web.Hosting;

namespace gzpegm.Helpers
{
    /// <summary>
    /// Resim ve dosya isteklerini (files, Uploads, ccc) IIS seviyesinde akilli yakalar.
    /// 1. Dosya projenin kendi klasorunde varsa hic dokunmaz (IIS dogrudan sunar - logo ve mevcut kurslar bozulmaz).
    /// 2. Dosya projede yoksa masaustu, harici HDD veya yapilandirilmis ExternalFileStorageRoot klasorunu arar ve aninda stream eder.
    /// Bu sayede IIS uzerinde hicbir Sanal Dizin (Virtual Directory) ayari yapmaya gerek kalmaz.
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
            var path = request.AppRelativeCurrentExecutionFilePath;
            if (string.IsNullOrEmpty(path)) return;

            // Sadece ~/files/, ~/Uploads/, ~/ccc/ isteklerini kontrol et
            if (!path.StartsWith("~/files/", StringComparison.OrdinalIgnoreCase) &&
                !path.StartsWith("~/Uploads/", StringComparison.OrdinalIgnoreCase) &&
                !path.StartsWith("~/ccc/", StringComparison.OrdinalIgnoreCase))
            {
                return;
            }

            // 1. Oncelik: Dosya web sitesinin kendi fiziksel klasorunde zaten var mi?
            try
            {
                var localPhysical = HostingEnvironment.MapPath(path);
                if (!string.IsNullOrEmpty(localPhysical) && File.Exists(localPhysical))
                {
                    // Dosya yerel sitede mevcut, IIS dogal statik sunucusuna birak
                    return;
                }
            }
            catch
            {
            }

            // 2. Oncelik: Dosya yerelde yoksa harici depolama kokunu ve tum olasi veri klasorlerini ara
            var relativeTail = path.Substring(2).Replace('/', Path.DirectorySeparatorChar);

            string foundPath = FindPhysicalFile(relativeTail);
            if (!string.IsNullOrEmpty(foundPath) && File.Exists(foundPath))
            {
                ServeFile(app, foundPath);
            }
        }

        private static string FindPhysicalFile(string relativeTail)
        {
            // A) Web.config ExternalFileStorageRoot
            try
            {
                var root = FileStorageHelper.GetConfiguredRoot();
                if (!string.IsNullOrEmpty(root) && Directory.Exists(root))
                {
                    var p1 = Path.Combine(root, relativeTail);
                    if (File.Exists(p1)) return p1;

                    var slashIdx = relativeTail.IndexOf(Path.DirectorySeparatorChar);
                    if (slashIdx >= 0)
                    {
                        var withoutSegment = relativeTail.Substring(slashIdx + 1);
                        var p2 = Path.Combine(root, withoutSegment);
                        if (File.Exists(p2)) return p2;
                    }
                }
            }
            catch
            {
            }

            // B) Bilinen tum harici surucu, masaustu ve veri klasorleri
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
                    if (!string.IsNullOrWhiteSpace(cand) && Directory.Exists(cand))
                    {
                        var p1 = Path.Combine(cand, relativeTail);
                        if (File.Exists(p1)) return p1;

                        var slashIdx = relativeTail.IndexOf(Path.DirectorySeparatorChar);
                        if (slashIdx >= 0)
                        {
                            var withoutSegment = relativeTail.Substring(slashIdx + 1);
                            var p2 = Path.Combine(cand, withoutSegment);
                            if (File.Exists(p2)) return p2;
                        }
                    }
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
                response.TransmitFile(filePath);
                app.CompleteRequest();
            }
            catch
            {
            }
        }
    }
}