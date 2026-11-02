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
        public ActionResult Index(string target, string mode = "inspector")
        {
            string cleanTarget = string.IsNullOrWhiteSpace(target) ? "localhost" : target.Trim();
            ViewBag.SelectedTarget = cleanTarget;
            ViewBag.ActiveMode = mode; // "inspector", "scanner", "camera"

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

        [HttpPost]
        public ActionResult ScanNetwork(string range, int timeoutMs = 1000, int concurrency = 30)
        {
            if (string.IsNullOrWhiteSpace(range))
            {
                range = "10.7.202.1 - 10.7.202.100";
            }

            var results = _pcInfoService.ScanNetworkRange(range, timeoutMs, concurrency);
            return Json(new { success = true, count = results.Count, devices = results }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult QueryCamera(string ip, string username = "admin", string password = "", int port = 80)
        {
            if (string.IsNullOrWhiteSpace(ip))
            {
                return Json(new { success = false, message = "IP adresi girilmelidir." }, JsonRequestBehavior.AllowGet);
            }

            var camera = _pcInfoService.GetCameraInfo(ip.Trim(), username, password, port);
            return Json(camera, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public ActionResult ExportExcel(string target, string username, string password)
        {
            string cleanTarget = string.IsNullOrWhiteSpace(target) ? "localhost" : target.Trim();
            var model = _pcInfoService.GetComputerInfo(cleanTarget, username, password);
            var fileBytes = _pcInfoService.ExportToExcel(model);

            string fileName = $"PCInfo_{(model.ComputerName ?? cleanTarget).Replace(" ", "_")}_{DateTime.Now:yyyyMMdd_HHmmss}.xlsx";
            return File(fileBytes, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", fileName);
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

        [HttpGet]
        public ActionResult ExportHtml(string target, string username, string password)
        {
            string cleanTarget = string.IsNullOrWhiteSpace(target) ? "localhost" : target.Trim();
            var model = _pcInfoService.GetComputerInfo(cleanTarget, username, password);
            string html = _pcInfoService.ExportToHtml(model);

            return Content(html, "text/html", Encoding.UTF8);
        }
    }
}
