using System;
using System.IO;
using System.Web;

namespace gzpegm.Helpers
{
    public static class AssetVersionHelper
    {
        public static string GetVersion(string virtualPath)
        {
            if (string.IsNullOrWhiteSpace(virtualPath))
                return DateTime.UtcNow.Ticks.ToString();

            try
            {
                string cleanPath = virtualPath.Trim();
                string physicalPath = HttpContext.Current?.Server?.MapPath(cleanPath);
                if (!string.IsNullOrEmpty(physicalPath) && File.Exists(physicalPath))
                {
                    // Dosyanın fiziksel son değiştirilme tarihini (Ticks) döner.
                    // 1) Dosya değişmediği sürece bu sayı aynı kalır -> Tarayıcı dosyayı 0ms'de RAM/Disk önbelleğinden açar.
                    // 2) Siz dosyayı sunucuya yüklediğiniz/güncellediğiniz anda bu sayı otomatik değişir -> Tarayıcı eski önbelleği anında atıp yeni dosyayı çeker.
                    // Memurun tarayıcıyı sıfırlamasına veya Ctrl+F5 yapmasına gerek kalmaz!
                    return File.GetLastWriteTimeUtc(physicalPath).Ticks.ToString();
                }
            }
            catch { }

            return CustomJsVersion;
        }

        public static string CustomJsVersion
        {
            get
            {
                try
                {
                    string path = HttpContext.Current?.Server?.MapPath("~/js/custom.js");
                    if (!string.IsNullOrEmpty(path) && File.Exists(path))
                    {
                        return File.GetLastWriteTimeUtc(path).Ticks.ToString();
                    }
                }
                catch { }

                return DateTime.UtcNow.Ticks.ToString();
            }
        }
    }
}
