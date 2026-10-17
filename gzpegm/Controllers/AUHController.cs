using gzpegm.Cont;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize(Users = "2")] // Admin = 2, Sistem Tanımlama = 2
    public class AUHController : Controller
    {

        [Route("AUH")]
        public ActionResult Index()
        {
            contauh contauh = new contauh();
            var data = contauh.GetAllAUH();
            return View(data);
        }
        [Route("AddAUH")]
        public ActionResult Index(string CountryAUH, string FirstMounthAUH, string KatSAUH, string DaySAUH, string DayKAUH, string TOMAUH)
        {
            contauh contauh = new contauh();
            var check = contauh.Check(0, CountryAUH);
            if (check != null)
            {
                ViewBag.GeneralWarningMessage = "Bu ülkeye daha önce kayıt yapılmıştır..!";
                ViewBag.GeneralDynamicScripts = "$('#general-warning').click();";
                var data = contauh.GetAllAUH();
                return View(data);
            }
            else
            {
                contauh.AddAUH(CountryAUH, FirstMounthAUH, KatSAUH, DaySAUH, DayKAUH, TOMAUH);
                ViewBag.GeneralSuccessMessage = "Aylık Ülke HARCI başarılı bir şekilde kaydedilmiştir..!";
                ViewBag.GeneralDynamicScripts = "$('#general-success').click();";
                var data = contauh.GetAllAUH();
                return View(data);
            }
        }
        [Route("EditAUH")]
        public ActionResult Index(int EditAUHId, string editCountryAUH, string editFirstMounthAUH, string editKatSAUH, string editDaySAUH, string editDayKAUH, string editTOMAUH)
        {
            contauh contauh = new contauh();
            var check = contauh.Check(EditAUHId, editCountryAUH);
            if (check != null)
            {
                ViewBag.GeneralWarningMessage = "Bu ülkeye daha önce kayıt yapılmıştır..!";
                ViewBag.GeneralDynamicScripts = "$('#general-warning').click();";
                var data = contauh.GetAllAUH();
                return View(data);
            }
            else
            {
                contauh.EditAUH(EditAUHId, editCountryAUH, editFirstMounthAUH, editKatSAUH, editDaySAUH, editDayKAUH, editTOMAUH);
                ViewBag.GeneralSuccessMessage = "Aylık Ülke HARCI başarılı bir şekilde güncellenmiştir..!";
                ViewBag.GeneralDynamicScripts = "$('#general-success').click();";
                var data = contauh.GetAllAUH();
                return View(data);
            }
        }
        [Route("DeleteAuh")]
        public JsonResult Index(int Id)
        {
            contauh contauh = new contauh();
            contauh.DeleteAUH(Id);
            return Json(new { Message = "Başarılı bir şekilde silinmiştir.", Url = "/Auh" }, JsonRequestBehavior.AllowGet);
        }
    }
}