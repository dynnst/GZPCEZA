using System.Web.Mvc;

namespace gzpegm.Controllers
{
    /// <summary>
    /// Error handling controller for custom error pages (404, 403, 401, 405)
    /// </summary>
    public class ErrorController : Controller
    {
        [HttpGet]
        public ActionResult Index()
        {
            Response.StatusCode = 500;
            Response.TrySkipIisCustomErrors = true;
            return View();
        }

        [HttpGet]
        public ActionResult NotFound()
        {
            Response.StatusCode = 404;
            Response.TrySkipIisCustomErrors = true;
            return View();
        }

        [HttpGet]
        public ActionResult Forbidden()
        {
            Response.StatusCode = 403;
            Response.TrySkipIisCustomErrors = true;
            return View();
        }

        [HttpGet]
        public ActionResult MethodNotAllowed()
        {
            Response.StatusCode = 405;
            Response.TrySkipIisCustomErrors = true;
            return View();
        }

        [HttpGet]
        public ActionResult Unauthorized()
        {
            Response.StatusCode = 401;
            Response.TrySkipIisCustomErrors = true;
            return View();
        }
    }
}
