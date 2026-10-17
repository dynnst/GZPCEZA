using gzpegm.Cont;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize(Users = "2")] // Admin = 2, Sistem Tanımlama = 2
    public class ExchangeController : Controller
    {
        [Route("Doviz")]
        public ActionResult Index()
        {
            ContExchange exchange = new ContExchange();
            var data = exchange.GetAllExchange();
            return View(data);
        }
        [Route("UpdateExchange")]
        public ActionResult Index(string AvroExchange, string DollarExchange, string SterlinExchange)
        {
            ContExchange exchange = new ContExchange();
            exchange.EditExchange(AvroExchange, DollarExchange, SterlinExchange);
            var data = exchange.GetAllExchange();
            ViewBag.GeneralSuccessMessage = "Döviz Kur Verisi başarılı bir şekilde güncellenmiştir..!";
            ViewBag.GeneralDynamicScripts = "$('#general-success').click();";
            return View(data);
        }
    }
}