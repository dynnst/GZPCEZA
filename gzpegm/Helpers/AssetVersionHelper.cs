using System;
using System.IO;
using System.Web;

namespace gzpegm.Helpers
{
    public static class AssetVersionHelper
    {
        private static string _cachedCustomJsVersion = null;
        private static readonly object _lock = new object();

        public static string CustomJsVersion
        {
            get
            {
                if (_cachedCustomJsVersion != null)
                    return _cachedCustomJsVersion;

                lock (_lock)
                {
                    if (_cachedCustomJsVersion != null)
                        return _cachedCustomJsVersion;

                    try
                    {
                        string path = HttpContext.Current?.Server?.MapPath("~/js/custom.js");
                        if (!string.IsNullOrEmpty(path) && File.Exists(path))
                        {
                            return _cachedCustomJsVersion = File.GetLastWriteTimeUtc(path).Ticks.ToString();
                        }
                    }
                    catch { }

                    return _cachedCustomJsVersion = DateTime.UtcNow.Ticks.ToString();
                }
            }
        }
    }
}
