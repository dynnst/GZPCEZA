using System;
using System.Text;
using System.Web.Mvc;
using gzpegm.Cont;
using gzpegm.Models.PCInfo;
using gzpegm.Services;
using Newtonsoft.Json;

namespace gzpegm.Controllers
{
    [UserAuthorize(Users = "2")] // Sadece Sistem Yöneticisi (Admin) erişebilir
    public class PCInfoController : Controller
    {
        private readonly PCInfoService _pcInfoService;

        public PCInfoController()
        {
            _pcInfoService = new PCInfoService();
        }

        [HttpGet]
        public ActionResult Index(string target)
        {
            string cleanTarget = string.IsNullOrWhiteSpace(target) ? "localhost" : target.Trim();
            ViewBag.SelectedTarget = cleanTarget;

            var model = _pcInfoService.GetComputerInfo(cleanTarget);
            return View(model);
        }

        [HttpPost]
        public ActionResult Query(string target, string username, string password)
        {
            string cleanTarget = string.IsNullOrWhiteSpace(target) ? "localhost" : target.Trim();
            var model = _pcInfoService.GetComputerInfo(cleanTarget, username, password);
            return Json(model, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public ActionResult ExportJson(string target, string username, string password)
        {
            string cleanTarget = string.IsNullOrWhiteSpace(target) ? "localhost" : target.Trim();
            var model = _pcInfoService.GetComputerInfo(cleanTarget, username, password);
            string json = JsonConvert.SerializeObject(model, Formatting.Indented);

            string safeFileName = $"PCInfo_{(model.ComputerName ?? cleanTarget).Replace(" ", "_")}_{DateTime.Now:yyyyMMdd_HHmmss}.json";
            byte[] fileBytes = Encoding.UTF8.GetBytes(json);
            return File(fileBytes, "application/json", safeFileName);
        }
    }
}
