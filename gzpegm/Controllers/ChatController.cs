using System;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    /// <summary>
    /// Sohbet Sistemi Ýptal Edilmiþtir (2024)
    /// MesajController kullanýlmaktadýr.
    /// </summary>
    [Obsolete("Chat system disabled. Use MesajController instead.")]
    public class ChatController : Controller
    {
        public ActionResult Index()
        {
            return HttpNotFound();
        }
    }
}
