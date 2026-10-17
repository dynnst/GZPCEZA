using gzpegm.Models;
using System.Linq;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    public class raporController : Controller
    {
        [Route("rapor/{Id:int}")]
        public ActionResult Index(int Id)
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                var data = _db.E_TKOD.Where(c => c.fldId == Id).SingleOrDefault();
                return View(data);
            }

        }
    }
}