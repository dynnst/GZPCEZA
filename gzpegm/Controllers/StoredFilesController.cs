using gzpegm.Helpers;
using System.IO;
using System.Web;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    /// <summary>
    /// Dosyalar harici depolama klasorundeyken dogrudan IIS tarafindan sunulamaz.
    /// Bu controller yapilandirilmis harici depolama kokunden, alternatif veri klasorlerinden
    /// veya proje icinden dosyalari arayip guvenle stream eder.
    /// </summary>
    [AllowAnonymous]
    public class StoredFilesController : Controller
    {
        [AcceptVerbs(HttpVerbs.Get | HttpVerbs.Head)]
        [Route("Uploads/{*path}")]
        public ActionResult ServeUploads(string path) => Serve("Uploads", path);

        [AcceptVerbs(HttpVerbs.Get | HttpVerbs.Head)]
        [Route("files/{*path}")]
        public ActionResult ServeFiles(string path) => Serve("files", path);

        [AcceptVerbs(HttpVerbs.Get | HttpVerbs.Head)]
        [Route("ccc/{*path}")]
        public ActionResult ServeCcc(string path) => Serve("ccc", path);

        private ActionResult Serve(string rootSegment, string path)
        {
            if (string.IsNullOrWhiteSpace(path))
                return HttpNotFound();

            path = HttpUtility.UrlDecode(path).Trim().Replace('/', Path.DirectorySeparatorChar);
            if (path.StartsWith(Path.DirectorySeparatorChar.ToString()))
                path = path.TrimStart(Path.DirectorySeparatorChar);

            // 1. Ana hedef: FileStorageHelper ile yapilandirilmis yol (ExternalFileStorageRoot + rootSegment + path)
            try
            {
                var basePath = FileStorageHelper.MapPath(Server, "~/" + rootSegment + "/");
                var fullPath = Path.GetFullPath(Path.Combine(basePath, path));
                var baseNorm = Path.GetFullPath(basePath);
                if (!baseNorm.EndsWith(Path.DirectorySeparatorChar.ToString()))
                    baseNorm += Path.DirectorySeparatorChar;

                if (fullPath.StartsWith(baseNorm, System.StringComparison.OrdinalIgnoreCase) && System.IO.File.Exists(fullPath))
                {
                    return ServeFile(fullPath);
                }
            }
            catch
            {
            }

            // 2. Fallback: Kullanici ExternalFileStorageRoot'u dogrudan dosya klasoru yapmissa (rootSegment olmadan)
            try
            {
                var configuredRoot = FileStorageHelper.GetConfiguredRoot();
                if (!string.IsNullOrEmpty(configuredRoot))
                {
                    var directPath = Path.GetFullPath(Path.Combine(configuredRoot, path));
                    var confNorm = Path.GetFullPath(configuredRoot);
                    if (!confNorm.EndsWith(Path.DirectorySeparatorChar.ToString()))
                        confNorm += Path.DirectorySeparatorChar;

                    if (directPath.StartsWith(confNorm, System.StringComparison.OrdinalIgnoreCase) && System.IO.File.Exists(directPath))
                    {
                        return ServeFile(directPath);
                    }
                }
            }
            catch
            {
            }

            // 3. Fallback: Proje ici orijinal dizini kontrol et (Server.MapPath)
            try
            {
                var fallbackBase = Path.GetFullPath(Server.MapPath("~/" + rootSegment + "/"));
                if (!fallbackBase.EndsWith(Path.DirectorySeparatorChar.ToString()))
                    fallbackBase += Path.DirectorySeparatorChar;

                var fallbackPath = Path.GetFullPath(Path.Combine(fallbackBase, path));
                if (fallbackPath.StartsWith(fallbackBase, System.StringComparison.OrdinalIgnoreCase) && System.IO.File.Exists(fallbackPath))
                {
                    return ServeFile(fallbackPath);
                }
            }
            catch
            {
            }

            // 4. Fallback: Bilinen alternatif veri klasorlerini tara
            try
            {
                string[] extraCandidates = new[]
                {
                    @"C:\veri",
                    @"D:\veri",
                    @"C:\Users\Naşit\Desktop\veri",
                    @"C:\Users\313258\Desktop\veri",
                    @"C:\Users\fb\Desktop\veri"
                };

                foreach (var candidate in extraCandidates)
                {
                    if (Directory.Exists(candidate))
                    {
                        var candidateWithSegment = Path.Combine(candidate, rootSegment, path);
                        if (System.IO.File.Exists(candidateWithSegment))
                        {
                            return ServeFile(candidateWithSegment);
                        }
                        var candidateDirect = Path.Combine(candidate, path);
                        if (System.IO.File.Exists(candidateDirect))
                        {
                            return ServeFile(candidateDirect);
                        }
                    }
                }
            }
            catch
            {
            }

            return HttpNotFound();
        }

        private ActionResult ServeFile(string filePath)
        {
            var contentType = MimeMapping.GetMimeMapping(filePath);
            Response.Cache.SetCacheability(HttpCacheability.Public);
            Response.Cache.SetMaxAge(System.TimeSpan.FromDays(7));
            return File(filePath, contentType);
        }
    }
}