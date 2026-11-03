using System;
using System.Configuration;
using System.IO;
using System.Web;

namespace gzpegm.Helpers
{
    /// <summary>
    /// Ozel depolama koku: ExternalFileStorageRoot doluysa ~/Uploads, ~/files ve ~/ccc bu klasorun altina yazilir/okunur.
    /// Kullanici istedigi klasoru (yerel surucu veya ag paylasimi) belirtebilir.
    /// Bos veya ulasilamazsa Server.MapPath veya bilinen veri klasorlerine otomatik geri doner.
    /// </summary>
    public static class FileStorageHelper
    {
        private const string AppSettingKey = "ExternalFileStorageRoot";

        public static string GetConfiguredRoot()
        {
            var v = ConfigurationManager.AppSettings[AppSettingKey];
            if (!string.IsNullOrWhiteSpace(v))
            {
                try
                {
                    var trimmed = v.Trim();
                    var full = Path.GetFullPath(trimmed);

                    if (!Directory.Exists(full))
                    {
                        Directory.CreateDirectory(full);
                    }

                    if (Directory.Exists(full))
                    {
                        return full;
                    }
                }
                catch
                {
                }
            }

            // Fallback: Belirtilen harici klasor yoksa bilinen veri klasorlerini tara
            try
            {
                string[] candidates = new[]
                {
                    @"C:\veri",
                    @"D:\veri",
                    @"C:\Users\313258\Desktop\veri",
                    @"C:\Users\Naşit\Desktop\veri",
                    @"C:\Users\fb\Desktop\veri",
                    Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory), "veri")
                };

                foreach (var candidate in candidates)
                {
                    if (!string.IsNullOrWhiteSpace(candidate) && Directory.Exists(candidate))
                    {
                        return Path.GetFullPath(candidate);
                    }
                }
            }
            catch
            {
            }

            return null;
        }

        /// <param name="appRelativePath">Orn. ~/Uploads/DocumentTerms/ veya ~/files/Egitim/</param>
        public static string MapPath(HttpServerUtilityBase server, string appRelativePath)
        {
            if (server == null) throw new ArgumentNullException(nameof(server));
            if (string.IsNullOrWhiteSpace(appRelativePath))
                throw new ArgumentException(@"~/ ile baslayan bir yol verin.", nameof(appRelativePath));

            if (!appRelativePath.StartsWith("~/", StringComparison.Ordinal))
                appRelativePath = "~/" + appRelativePath.TrimStart('~', '/');

            var root = GetConfiguredRoot();
            if (root == null)
            {
                var local = Path.GetFullPath(server.MapPath(appRelativePath));
                EnsureDirectoryForPhysicalPath(local, appRelativePath);
                return local;
            }

            var tail = appRelativePath.Substring(2).Trim().Replace('/', Path.DirectorySeparatorChar);
            var combined = string.IsNullOrEmpty(tail) ? root : Path.Combine(root, tail);
            var fullCombined = Path.GetFullPath(combined);
            EnsureDirectoryForPhysicalPath(fullCombined, appRelativePath);
            return fullCombined;
        }

        /// <param name="urlPath">Orn. /Uploads/DocumentTerms/x.jpg</param>
        public static string MapUrlToPhysicalPath(HttpServerUtilityBase server, string urlPath)
        {
            if (server == null || string.IsNullOrWhiteSpace(urlPath)) return null;
            urlPath = urlPath.Trim();
            if (!urlPath.StartsWith("/", StringComparison.Ordinal))
                urlPath = "/" + urlPath;
            return MapPath(server, "~" + urlPath);
        }

        private static void EnsureDirectoryForPhysicalPath(string physicalPath, string appRelativePath)
        {
            try
            {
                if (appRelativePath.EndsWith("/"))
                {
                    if (!Directory.Exists(physicalPath))
                    {
                        Directory.CreateDirectory(physicalPath);
                    }
                }
                else
                {
                    var parent = Path.GetDirectoryName(physicalPath);
                    if (!string.IsNullOrEmpty(parent) && !Directory.Exists(parent))
                    {
                        Directory.CreateDirectory(parent);
                    }
                }
            }
            catch
            {
            }
        }
    }
}