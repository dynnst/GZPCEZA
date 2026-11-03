using gzpegm.Helpers;
using System.IO;
using System.Web;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    /// <summary>
    /// Dosyalar uygulama klasoru disindayken dogrudan statik dosya sunumu olmaz; bu eylemler yapilandirilmis kokten stream eder.
    /// </summary>
    [AllowAnonymous]
    public class StoredFilesController : Controller
    {
        [HttpGet]
        [Route("Uploads/{*path}")]
        public ActionResult ServeUploads(string path) => Serve("Uploads", path);

        [HttpGet]
        [Route("files/{*path}")]
        public ActionResult ServeFiles(string path) => Serve("files", path);

        [HttpGet]
        [Route("ccc/{*path}")]
        public ActionResult ServeCcc(string path) => Serve("ccc", path);

        private ActionResult Serve(string rootSegment, string path)
        {
            if (string.IsNullOrWhiteSpace(path))
                return HttpNotFound();

            path = path.Replace('/', Path.DirectorySeparatorChar);
            var basePath = FileStorageHelper.MapPath(Server, "~/" + rootSegment + "/");
            var fullPath = Path.GetFullPath(Path.Combine(basePath, path));
            var baseNorm = Path.GetFullPath(basePath);
            if (!baseNorm.EndsWith(Path.DirectorySeparatorChar.ToString()))
                baseNorm += Path.DirectorySeparatorChar;

            if (!fullPath.StartsWith(baseNorm, System.StringComparison.OrdinalIgnoreCase))
                return new HttpStatusCodeResult(403, "Gecersiz yol");

            if (!System.IO.File.Exists(fullPath))
            {
                // Fallback: Harici depolama kokunde bulunamazsa veya erisilemezse proje ici dizini kontrol et
                try
                {
                    var fallbackBase = Path.GetFullPath(Server.MapPath("~/" + rootSegment + "/"));
                    if (!fallbackBase.EndsWith(Path.DirectorySeparatorChar.ToString()))
                        fallbackBase += Path.DirectorySeparatorChar;

                    var fallbackPath = Path.GetFullPath(Path.Combine(fallbackBase, path));
                    if (fallbackPath.StartsWith(fallbackBase, System.StringComparison.OrdinalIgnoreCase) && System.IO.File.Exists(fallbackPath))
                    {
                        var fallbackContentType = MimeMapping.GetMimeMapping(fallbackPath);
                        return File(fallbackPath, fallbackContentType);
                    }
                }
                catch
                {
                }

                return HttpNotFound();
            }

            var contentType = MimeMapping.GetMimeMapping(fullPath);
            return File(fullPath, contentType);
        }
    }
}