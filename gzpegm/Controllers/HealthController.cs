using System.Web.Mvc;

namespace gzpegm.Controllers
{
    /// <summary>
    /// Sunucu sağlık kontrolü için basit endpoint
    /// </summary>
    public class HealthController : Controller
    {
        // GET: /Health
        public ActionResult Index()
        {
            return Content("OK", "text/plain");
        }

        // GET: /Health/Check
        public ActionResult Check()
        {
            try
            {
                using (var db = new Models.GZPEGM1())
                {
                    var dbHealthy = db.Database.Exists();
                    if (dbHealthy)
                    {
                        return Content("OK", "text/plain");
                    }
                }
            }
            catch
            {
                Response.StatusCode = 503;
                return Content("Database Error", "text/plain");
            }

            Response.StatusCode = 503;
            return Content("Error", "text/plain");
        }
    }
}
