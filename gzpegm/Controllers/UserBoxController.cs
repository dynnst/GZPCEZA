using gzpegm.Cont;
using System.Web;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    public class UserBoxController : Controller
    {
        [Route("Userbox")]
        public ActionResult Index()
        {
            HttpCookie UserCookie;
            UserCookie = Request.Cookies["Token"];
            Token token = new Token();
            gzpegm.Cont.User user = new User();
            int UserId = 0;
            if (UserCookie != null)
            {
                var tokendata = token.GetToken(UserCookie.Value.ToString());
                if (tokendata?.fldUserId != null)
                    int.TryParse(tokendata.fldUserId.ToString(), out UserId);
            }
            var Data = user.GetUserById(UserId);
            return PartialView(Data);
        }
    }
}
