using gzpegm.Cont;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize(Users = "2")] // Admin = 2, Sistem Tanımlama = 2 (artık Admin ile aynı)
    public class FormTController : Controller
    {
        [Route("FormT")]
        public ActionResult Index()
        {
            ContFormT formT = new ContFormT();
            var data = formT.GetAllForms();
            return View(data);
        }
        [HttpPost, ValidateInput(false)]
        [Route("UpdateForm")]
        public ActionResult Index(string GBNotPaid, string GBPaid, string DENotPaid, string DEPaid, string RUNotPaid, string RUPaid, string IRNotPaid, string IRKPaid, string IRKNotPaid, string IRPaid, string FRNotPaid, string FRPaid)
        {
            ContFormT formT = new ContFormT();
            formT.UpdateForm(GBNotPaid, GBPaid, DENotPaid, DEPaid, RUNotPaid, RUPaid, IRNotPaid, IRPaid, IRKNotPaid, IRKPaid, FRNotPaid, FRPaid);
            ViewBag.GeneralSuccessMessage = "Form Verileri başarılı bir şekilde güncellenmiştir..!";
            ViewBag.GeneralDynamicScripts = "$('#general-success').click();";
            var data = formT.GetAllForms();
            return View(data);
        }
    }
}