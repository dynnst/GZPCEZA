using System;
using System.Collections.Generic;
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
            ViewBag.ActiveMode = mode; // "inspector", "scanner", "camera", "inventory"

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
        public ActionResult ConnectRdp(string ip)
        {
            if (string.IsNullOrWhiteSpace(ip))
            {
                return HttpNotFound();
            }

            string cleanIp = ip.Trim();
            // Tek tıkla Windows mstsc.exe'yi hedef IP ile açacak .rdp yapılandırma dosyası
            string rdpContent = "full address:s:" + cleanIp + "\r\n" +
                                "prompt for credentials:i:1\r\n" +
                                "administrative session:i:1\r\n" +
                                "screen mode id:i:2\r\n" +
                                "use multimon:i:0\r\n" +
                                "compression:i:1\r\n" +
                                "keyboardhook:i:2\r\n" +
                                "audiomode:i:0\r\n";

            byte[] fileBytes = Encoding.ASCII.GetBytes(rdpContent);
            return File(fileBytes, "application/x-rdp", $"{cleanIp}.rdp");
        }

        [HttpGet]
        public ActionResult ConnectAssist(string ip, string mode = "msra")
        {
            if (string.IsNullOrWhiteSpace(ip))
            {
                return HttpNotFound();
            }

            string cleanIp = ip.Trim();
            mode = (mode ?? "msra").ToLowerInvariant();

            string scriptContent;
            string fileName;

            if (mode == "shadow")
            {
                // RDP Shadowing (Gölgeleme Modu - Oturumu kapatmadan bağlanma)
                fileName = $"Golge_Baglanti_{cleanIp}.cmd";
                scriptContent =
"@echo off\r\n" +
"chcp 65001 >nul\r\n" +
"title RDP Golgeleme - " + cleanIp + "\r\n" +
"echo =======================================================================\r\n" +
"echo   EGM CEZAM - RDP GOLGELEME BAGLANTISI (OTURUM KAPANMAZ)\r\n" +
"echo   Hedef IP: " + cleanIp + "\r\n" +
"echo   Aciklama: Gisedeki memurun oturumu kilitlenmez, ekrana ortak olunur.\r\n" +
"echo =======================================================================\r\n" +
"echo.\r\n" +
"echo Golgeleme oturumu baslatiliyor (Konsol Oturumu 1)...\r\n" +
"start mstsc.exe /v:" + cleanIp + " /shadow:1 /control\r\n" +
"timeout /t 2 >nul\r\n" +
"exit\r\n";
            }
            else
            {
                // Windows Uzaktan Yardım (MSRA - Microsoft Remote Assistance Offer)
                fileName = $"Uzaktan_Yardim_{cleanIp}.cmd";
                scriptContent =
"@echo off\r\n" +
"chcp 65001 >nul\r\n" +
"title Windows Uzaktan Yardim - " + cleanIp + "\r\n" +
"echo =======================================================================\r\n" +
"echo   EGM CEZAM - WINDOWS UZAKTAN YARDIM (OTURUM KAPANMAZ)\r\n" +
"echo   Hedef IP: " + cleanIp + "\r\n" +
"echo   Aciklama: Gisedeki polisin ekrani kapanmaz, onay alinarak canli yardim baslatilir.\r\n" +
"echo =======================================================================\r\n" +
"echo.\r\n" +
"echo Hedef bilgisayara uzaktan yardim teklifi gonderiliyor...\r\n" +
"start msra.exe /offerRA " + cleanIp + "\r\n" +
"timeout /t 2 >nul\r\n" +
"exit\r\n";
            }

            byte[] fileBytes = Encoding.UTF8.GetBytes(scriptContent);
            return File(fileBytes, "application/octet-stream", fileName);
        }

        #region CEZA VERİTABANI ENVANTER İŞLEMLERİ

        [HttpGet]
        public ActionResult GetInventory(string search, int? category, int? status, string location)
        {
            var devices = _pcInfoService.GetAllDevices(search, category, status, location);
            return Json(new { success = true, count = devices.Count, data = devices }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult SaveDevice(DeviceEntity device)
        {
            try
            {
                int id = _pcInfoService.SaveDevice(device);
                return Json(new { success = true, id = id, message = "Cihaz envantere başarıyla kaydedildi." });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message });
            }
        }

        [HttpPost]
        public ActionResult SaveCurrentToInventory(string target, string location, string assignedPerson, string notes, string assetTag, int category = 1)
        {
            try
            {
                string cleanTarget = string.IsNullOrWhiteSpace(target) ? "localhost" : target.Trim();
                var model = _pcInfoService.GetComputerInfo(cleanTarget);
                if (!model.IsOnline)
                {
                    return Json(new { success = false, message = "Cihaza ulaşılamadığı için envantere kaydedilemedi." });
                }

                int id = _pcInfoService.SaveFromComputerInfo(model, location, assignedPerson, notes, assetTag, category);
                return Json(new { success = true, id = id, message = $"'{model.ComputerName}' CEZA veritabanı envanterine kaydedildi." });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message });
            }
        }

        [HttpPost]
        public ActionResult SaveScanDeviceToInventory(string ip, string hostname, int deviceType, string location, string details)
        {
            try
            {
                var scanItem = new ScanItemResult
                {
                    IpAddress = ip,
                    HostName = hostname,
                    DeviceType = (DeviceType)deviceType,
                    Details = details
                };

                int id = _pcInfoService.SaveFromScanItem(scanItem, location);
                return Json(new { success = true, id = id, message = $"{ip} envantere kaydedildi." });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message });
            }
        }

        [HttpPost]
        public ActionResult DeleteInventoryDevice(int id)
        {
            bool result = _pcInfoService.DeleteDevice(id);
            return Json(new { success = result });
        }

        [HttpGet]
        public ActionResult ExportInventoryExcel(string search, int? category, int? status, string location)
        {
            var devices = _pcInfoService.GetAllDevices(search, category, status, location);
            var fileBytes = _pcInfoService.ExportInventoryToExcel(devices);
            string fileName = $"CEZA_Donanim_Envanteri_{DateTime.Now:yyyyMMdd_HHmmss}.xlsx";
            return File(fileBytes, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", fileName);
        }

        #endregion

        #region DIŞA AKTARMA (EXCEL / JSON / HTML)

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

        #endregion
    }
}
