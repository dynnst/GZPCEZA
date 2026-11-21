using gzpegm.Cont;
using gzpegm.Services;
using System;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize(Users = "2")] // Sadece Sistem Yöneticileri (2) erişebilir
    public class CezaParametreController : Controller
    {
        [Route("CezaParametre")]
        public ActionResult Index()
        {
            var data = CezaParametreService.GetAllParams();
            return View(data);
        }

        [HttpPost]
        [Route("UpdateCezaParametre")]
        [ValidateAntiForgeryToken]
        public ActionResult Update(FormCollection form)
        {
            try
            {
                var currentUser = Session["User"] as gzpegm.Models.E_User;
                string userName = currentUser != null 
                    ? ((currentUser.fldName ?? "") + " " + (currentUser.fldLastName ?? "")).Trim() 
                    : "Sistem";

                int updatedCount = 0;
                foreach (string key in form.AllKeys)
                {
                    if (key.StartsWith("param_", StringComparison.OrdinalIgnoreCase))
                    {
                        string paramKey = key.Substring("param_".Length);
                        string paramVal = form[key];
                        if (CezaParametreService.UpdateParam(paramKey, paramVal, userName))
                        {
                            updatedCount++;
                        }
                    }
                }

                ViewBag.GeneralSuccessMessage = $"'{updatedCount}' adet ceza ve mevzuat parametresi başarıyla güncellendi.";
                ViewBag.GeneralDynamicScripts = "$('#general-success').click();";
            }
            catch (Exception ex)
            {
                ViewBag.GeneralWarningMessage = "Hata oluştu: " + ex.Message;
                ViewBag.GeneralDynamicScripts = "$('#general-warning').click();";
            }

            var data = CezaParametreService.GetAllParams();
            return View("Index", data);
        }

        [HttpPost]
        [Route("UpdateSingleParam")]
        public JsonResult UpdateSingle(string key, string value)
        {
            try
            {
                var currentUser = Session["User"] as gzpegm.Models.E_User;
                string userName = currentUser != null 
                    ? ((currentUser.fldName ?? "") + " " + (currentUser.fldLastName ?? "")).Trim() 
                    : "Sistem";

                bool ok = CezaParametreService.UpdateParam(key, value, userName);
                return Json(new { success = ok, message = ok ? "Parametre güncellendi." : "Güncelleme başarısız." });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message });
            }
        }
    }
}
