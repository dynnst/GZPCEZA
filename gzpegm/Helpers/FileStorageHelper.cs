using System;
using System.Configuration;
using System.IO;
using System.Web;

namespace gzpegm.Helpers
{
    /// <summary>
    /// Özel depolama kökü: <c>ExternalFileStorageRoot</c> doluysa ~/Uploads, ~/files ve ~/ccc bu klasörün altına yazılır/okunur.
    /// Boşsa veya belirtilen dizin bu bilgisayarda mevcut değilse <see cref="HttpServerUtilityBase.MapPath"/> kullanır.
    /// </summary>
    public static class FileStorageHelper
    {
        private const string AppSettingKey = "ExternalFileStorageRoot";

        public static string GetConfiguredRoot()
        {
            var v = ConfigurationManager.AppSettings[AppSettingKey];
            if (string.IsNullOrWhiteSpace(v)) return null;
            try
            {
                var full = Path.GetFullPath(v.Trim());
                if (!Directory.Exists(full))
                {
                    // Belirtilen dış depolama klasörü bu bilgisayarda mevcut değilse varsayılan yerel yola dön
                    return null;
                }
                return full;
            }
            catch
            {
                return null;
            }
        }

        /// <param name="appRelativePath">Örn. ~/Uploads/DocumentTerms/ veya ~/files/Egitim/</param>
        public static string MapPath(HttpServerUtilityBase server, string appRelativePath)
        {
            if (server == null) throw new ArgumentNullException(nameof(server));
            if (string.IsNullOrWhiteSpace(appRelativePath))
                throw new ArgumentException(@"~/ ile başlayan bir yol verin.", nameof(appRelativePath));

            if (!appRelativePath.StartsWith("~/", StringComparison.Ordinal))
                appRelativePath = "~/" + appRelativePath.TrimStart('~', '/');

            var root = GetConfiguredRoot();
            if (root == null)
                return Path.GetFullPath(server.MapPath(appRelativePath));

            var tail = appRelativePath.Substring(2).Trim().Replace('/', Path.DirectorySeparatorChar);
            var combined = string.IsNullOrEmpty(tail) ? root : Path.Combine(root, tail);
            return Path.GetFullPath(combined);
        }

        /// <param name="urlPath">Örn. /Uploads/DocumentTerms/x.jpg</param>
        public static string MapUrlToPhysicalPath(HttpServerUtilityBase server, string urlPath)
        {
            if (server == null || string.IsNullOrWhiteSpace(urlPath)) return null;
            urlPath = urlPath.Trim();
            if (!urlPath.StartsWith("/", StringComparison.Ordinal))
                urlPath = "/" + urlPath;
            return MapPath(server, "~" + urlPath);
        }
    }
}
