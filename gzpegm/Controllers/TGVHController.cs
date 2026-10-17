using gzpegm.Cont;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize(Users = "2")] // Admin = 2, Sistem Tanımlama = 2
    public class TGVHController : Controller
    {
        [Route("tgvh")]
        public ActionResult Index()
        {
            tgvh tgvh = new tgvh();
            var data = tgvh.GetTGVH();
            return View(data);
        }
        [Route("AddTGVH")]
        public ActionResult Index(string miktar, string tarihi)
        {
            tgvh tgvh = new tgvh();
            //tgvh.EditTGVH(PriceTGVH, tomTGVH.Trim());
            var check = tgvh.checkTGVH(tarihi);
            if (check != null)
            {
                ViewBag.GeneralWarningMessage = "'Belirtilen tarihte kayıt mevcuttur..!";
                ViewBag.GeneralDynamicScripts = "$('#general-warning').click();";
                var dat = tgvh.GetTGVH();
                return View(dat);
            }
            ViewBag.GeneralSuccessMessage = "'Tek Giriş Vize Harcı' başarılı bir şekilde eklenmiştir..!";
            ViewBag.GeneralDynamicScripts = "$('#general-success').click();";
            tgvh.addTGVH(miktar, tarihi);
            var data = tgvh.GetTGVH();
            return View(data);
        }
        [Route("deletetgvh")]
        public JsonResult deletetgvh(int Id)
        {
            tgvh tgvh = new tgvh();
            tgvh.DeleteTGVH(Id);
            return Json(new { Message = "Başarılı bir şekilde silinmiştir.", Url = "/TGVH" }, JsonRequestBehavior.AllowGet);

        }
        [Route("Defter")]
        public ActionResult Defter()
        {
            tgvh tgvh = new tgvh();
            var data = tgvh.GetDefter();
            return View(data);
        }
        [Route("updateDefter")]
        public ActionResult Defter(string PriceDef, string tomDef)
        {
            tgvh tgvh = new tgvh();
            tgvh.EditDefter(PriceDef, tomDef.Trim());
            ViewBag.GeneralSuccessMessage = "'Defter Bedeli' başarılı bir şekilde güncellenmiştir..!";
            ViewBag.GeneralDynamicScripts = "$('#general-success').click();";
            var data = tgvh.GetDefter();
            return View(data);
        }
    }
}