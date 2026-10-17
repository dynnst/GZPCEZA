using System.Web.Mvc;

namespace gzpegm.Controllers
{
    public class KosullarController : Controller
    {
        [Route("Kosullar")]
        public ActionResult Index()
        {
            return View();
        }
    }
}