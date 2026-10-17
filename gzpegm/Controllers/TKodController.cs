using gzpegm.Cont;
using System;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize(Users = "2")] // Admin = 2, Sistem Tanımlama = 2
    public class TKodController : Controller
    {
        [Route("TKod")]
        public ActionResult Index()
        {
            ContTKod kod = new ContTKod();
            var data = kod.GetAllCodes();
            return View(data);
        }
        [Route("AddTKod")]
        public ActionResult Index(string codeTKOD, string sureTKOD, int startTKOD, int finishTKOD, string idariTKOD, string paymentTKOD)
        {
            ContTKod kod = new ContTKod();
            byte pstatus = Convert.ToByte(paymentTKOD);
            var check = kod.Check(0, codeTKOD, idariTKOD, pstatus);
            if (check != null)
            {
                ViewBag.GeneralWarningMessage = "Bu kod ve idari kod daha önce kayıt yapılmıştır..!";
                ViewBag.GeneralDynamicScripts = "$('#general-warning').click();";
                var data1 = kod.GetAllCodes();
                return View(data1);
            }
            kod.AddTKOD(codeTKOD, sureTKOD, startTKOD, finishTKOD, idariTKOD, pstatus);
            ViewBag.GeneralSuccessMessage = "Tahdit Kodu başarılı bir şekilde kaydedilmiştir..!";
            ViewBag.GeneralDynamicScripts = "$('#general-success').click();";
            var data = kod.GetAllCodes();
            return View(data);
        }
        [Route("EditTKod")]
        public ActionResult Index(int EditTKodId, string editcodeTKOD, string editsureTKOD, int editstartTKOD, int editfinishTKOD, string editidariTKOD, string editpaymentTKOD)
        {
            ContTKod kod = new ContTKod();
            byte pstatus = Convert.ToByte(editpaymentTKOD);
            var check = kod.Check(EditTKodId, editcodeTKOD, editidariTKOD, pstatus);
            if (check != null)
            {
                ViewBag.GeneralWarningMessage = "Bu kod ve idari kod daha önce kayıt yapılmıştır..!";
                ViewBag.GeneralDynamicScripts = "$('#general-warning').click();";
                var data1 = kod.GetAllCodes();
                return View(data1);
            }
            kod.EditTKOD(EditTKodId, editcodeTKOD, editsureTKOD, editstartTKOD, editfinishTKOD, editidariTKOD, pstatus);
            ViewBag.GeneralSuccessMessage = "Tahdit Kodu başarılı bir şekilde güncellenmiştir..!";
            ViewBag.GeneralDynamicScripts = "$('#general-success').click();";
            var data = kod.GetAllCodes();
            return View(data);
        }
        [Route("DeleteTKod")]
        public JsonResult Index(int Id)
        {
            ContTKod kod = new ContTKod();
            kod.DeleteTKod(Id);
            return Json(new { Message = "Başarılı bir şekilde silinmiştir.", Url = "/TKod" }, JsonRequestBehavior.AllowGet);

        }
    }
}