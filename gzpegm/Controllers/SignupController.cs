using gzpegm.Cont;
using System;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    public class SignupController : Controller
    {
        [Route("kayit")]
        public ActionResult Index()
        {
            Border border = new Border();
            var data = border.GetAll();
            return View(data);
        }

        [Route("signup")]
        public ActionResult Index(string sicil, string name, string lastname, string phone, string email, string title, string deputy)
        {
            Border border = new Border();
            var data = border.GetAll();
            gzpegm.Cont.User user = new User();

            if (string.IsNullOrWhiteSpace(email) ||
                !email.Trim().EndsWith("@egm.gov.tr", StringComparison.OrdinalIgnoreCase))
            {
                ViewBag.Error = "Kayıt için yalnızca @egm.gov.tr uzantılı e-posta adresi kullanılabilir.";
                return View(data);
            }

            var check = user.Check(0, sicil);
            if (check != null)
            {
                ViewBag.Error = "Bu sicil numarası daha önce kaydedilmiş..!";
                return View(data);
            }

            var check1 = user.Checktemp(0, sicil);
            if (check1 != null)
            {
                ViewBag.Error = "Bu sicil numarası ile daha önce talepte bulunulmuştur..!";
                return View(data);
            }

            user.AddTempUser(sicil, name, lastname, phone, email.Trim(), title, deputy);
            ViewBag.Success = "Kayıt talebiniz alınmıştır. En kısa sürede hesabınız aktif edilip telefon veya e-posta ile bilgi verilecektir.";
            return View(data);
        }
    }
}
