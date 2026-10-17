using System;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    /// <summary>
    /// ChatRobot Sistemi Ýptal Edilmiþtir (2024)
    /// </summary>
    [Obsolete("ChatRobot system disabled.")]
    public class ChatRobotController : Controller
    {
        public ActionResult Index()
        {
            return HttpNotFound();
        }
    }
}
