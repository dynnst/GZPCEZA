using gzpegm.Helpers;
using System.IO;
using System.Web;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    /// <summary>
    /// Dosyalar uygulama klasörü dışındayken doğrudan statik dosya sunumu olmaz; bu eylemler yapılandırılmış kökten stream eder.
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
                return new HttpStatusCodeResult(403, "Geçersiz yol");

            if (!System.IO.File.Exists(fullPath))
                return HttpNotFound();

            var contentType = MimeMapping.GetMimeMapping(fullPath);
            return File(fullPath, contentType);
        }
    }
}
