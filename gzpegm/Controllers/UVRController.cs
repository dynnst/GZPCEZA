using gzpegm.Cont;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize(Users = "2")] // Admin = 2, Sistem Tanımlama = 2
    public class UVRController : Controller
    {

        [Route("UVR")]
        public ActionResult Index()
        {
            Contuvr contuvr = new Contuvr();
            var data = contuvr.GetAllUVR();
            return View(data);
        }
        [Route("AddUVR")]
        public ActionResult Index(string CountryUVR, int CalculateUVR, int PassportUVR, int visaUVR, int dayUVR, int longUVR, int onetimeUVR, byte harcUVR)
        {
            Contuvr contuvr = new Contuvr();
            var check = contuvr.check(0, CountryUVR, PassportUVR, visaUVR, CalculateUVR);
            if (check != null)
            {
                ViewBag.GeneralWarningMessage = "Bu ülke için daha önce kayıt yapılmıştır..!";
                ViewBag.GeneralDynamicScripts = "$('#general-warning').click();";
                var data = contuvr.GetAllUVR();
                return View(data);
            }
            else
            {
                contuvr.AddUVR(CountryUVR, CalculateUVR, PassportUVR, visaUVR, dayUVR, longUVR, onetimeUVR, harcUVR);
                ViewBag.GeneralSuccessMessage = "Ülke Vize Rejmi başarılı bir şekilde kaydedilmiştir..!";
                ViewBag.GeneralDynamicScripts = "$('#general-success').click();";
                var data = contuvr.GetAllUVR();
                return View(data);
            }

        }
        [Route("EditUVR")]
        public ActionResult Index(int EditUVR, string editCountryUVR, int editCalculateUVR, int editPassportUVR, int editvisaUVR, int editdayUVR, int editlongUVR, int editonetimeUVR, byte editharcUVR)
        {
            Contuvr contuvr = new Contuvr();
            var check = contuvr.check(EditUVR, editCountryUVR, editPassportUVR, editvisaUVR, editCalculateUVR);
            if (check != null)
            {
                ViewBag.GeneralWarningMessage = "Bu ülke için daha önce kayıt yapılmıştır..!";
                ViewBag.GeneralDynamicScripts = "$('#general-warning').click();";
                var data = contuvr.GetAllUVR();
                return View(data);
            }
            else
            {
                contuvr.EditUVR(EditUVR, editCountryUVR, editCalculateUVR, editPassportUVR, editvisaUVR, editdayUVR, editlongUVR, editonetimeUVR, editharcUVR);
                ViewBag.GeneralSuccessMessage = "Ülke Vize Rejmi başarılı bir şekilde kaydedilmiştir..!";
                ViewBag.GeneralDynamicScripts = "$('#general-success').click();";
                var data = contuvr.GetAllUVR();
                return View(data);
            }

        }
        [Route("DeleteUVR")]
        public JsonResult Index(int Id)
        {
            Contuvr contuvr = new Contuvr();
            contuvr.DeleteUVR(Id);
            return Json(new { Message = "Başarılı bir şekilde silinmiştir.", Url = "/UVR" }, JsonRequestBehavior.AllowGet);

        }

        [HttpGet]
        [Route("GetUVRByCountry")]
        public JsonResult GetUVRByCountry(string country)
        {
            try
            {
                var cont = new Contuvr();
                var rec = cont.GetKaseVizeByCountry(country);
                if (rec == null) return Json(new { success = false, message = "Kayıt bulunamadı" }, JsonRequestBehavior.AllowGet);

                // include current per-day price (fallback handled in tgvh)
                var t = new gzpegm.Cont.tgvh();
                var perDay = t.GetCurrentPrice(10m);

                return Json(new
                {
                    success = true,
                    country = rec.fldCountry,
                    calculateType = rec.fldCalculateType,
                    passportType = rec.fldPassportType,
                    visaStatus = rec.fldVisaStatus,
                    day = rec.fldDay,
                    lon = rec.fldLong,
                    oneTime = rec.fldOneTime,
                    harcByte = rec.fldHB,
                    dailyPrice = perDay
                }, JsonRequestBehavior.AllowGet);
            }
            catch (System.Exception ex)
            {
                return Json(new { success = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }
    }
}
