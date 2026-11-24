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
            if (model != null)
            {
                Session["PCInfo_" + cleanTarget] = model;
            }
            return View(model);
        }

        [HttpPost]
        public ActionResult IndexPost(string target, string username, string password, string mode = "inspector")
        {
            string cleanTarget = string.IsNullOrWhiteSpace(target) ? "localhost" : target.Trim();
            ViewBag.SelectedTarget = cleanTarget;
            ViewBag.ActiveMode = mode;
            ViewBag.AdminUsername = username;
            ViewBag.AdminPassword = password;

            var model = _pcInfoService.GetComputerInfo(cleanTarget, username, password);
            if (model != null)
            {
                Session["PCInfo_" + cleanTarget] = model;
            }
            return View("Index", model);
        }

        [HttpPost]
        public ActionResult Query(string target, string username, string password)
        {
            string cleanTarget = string.IsNullOrWhiteSpace(target) ? "localhost" : target.Trim();
            var model = _pcInfoService.GetComputerInfo(cleanTarget, username, password);
            if (model != null)
            {
                Session["PCInfo_" + cleanTarget] = model;
            }
            return Json(model, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult ScanNetwork(string range, int timeoutMs = 1000, int concurrency = 30)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(range))
                {
                    range = "10.7.202.1 - 10.7.202.100";
                }

                var results = _pcInfoService.ScanNetworkRange(range, timeoutMs, concurrency);
                return Json(new { success = true, count = results.Count, devices = results }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = "Ağ tarama hatası: " + ex.Message, count = 0, devices = new List<ScanItemResult>() }, JsonRequestBehavior.AllowGet);
            }
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
        public ActionResult GetSnapshot(string ip, int port = 80, string user = "admin", string pass = "", int channel = 101)
        {
            if (string.IsNullOrWhiteSpace(ip))
            {
                return new HttpStatusCodeResult(400, "IP adresi gerekli.");
            }

            string errorLog;
            byte[] imageBytes = _pcInfoService.GetCameraSnapshot(ip.Trim(), user, pass, port, channel, out errorLog);
            if (imageBytes != null && imageBytes.Length > 200)
            {
                return File(imageBytes, "image/jpeg");
            }

            // Resim alınamazsa tarayıcıda kırık ikon çıkmaması için hata SVG'si üretip dön
            string safeMsg = string.IsNullOrWhiteSpace(errorLog) ? "Kamera veya NVR'dan görüntü alınamadı." : errorLog.Replace("<", "&lt;").Replace(">", "&gt;").Replace("\"", "'");
            if (safeMsg.Length > 200) safeMsg = safeMsg.Substring(0, 200) + "...";

            string svg = @"<svg xmlns='http://www.w3.org/2000/svg' width='640' height='360' viewBox='0 0 640 360'>
  <rect width='100%' height='100%' fill='#18181b'/>
  <circle cx='320' cy='140' r='36' fill='#ef4444' opacity='0.2'/>
  <path d='M320 120 v25 M320 155 v5' stroke='#ef4444' stroke-width='4' stroke-linecap='round'/>
  <text x='320' y='210' fill='#f87171' font-size='16' font-family='Segoe UI, Arial, sans-serif' font-weight='bold' text-anchor='middle'>Kamera Görüntüsü Alınamadı</text>
  <text x='320' y='235' fill='#94a3b8' font-size='12' font-family='Segoe UI, Arial, sans-serif' text-anchor='middle'>" + ip + @":" + port + @" (Kanal: " + channel + @")</text>
  <text x='320' y='265' fill='#cbd5e1' font-size='11' font-family='Consolas, monospace' text-anchor='middle'>" + safeMsg + @"</text>
</svg>";

            return Content(svg, "image/svg+xml", Encoding.UTF8);
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

        [HttpGet]
        public ActionResult GetDeviceById(int id)
        {
            var device = _pcInfoService.GetDeviceById(id);
            if (device == null)
            {
                return Json(new { success = false, message = "Cihaz bulunamadi." }, JsonRequestBehavior.AllowGet);
            }
            return Json(device, JsonRequestBehavior.AllowGet);
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
        public ActionResult SaveCurrentToInventory(string target, string location, string assignedPerson, string notes, string assetTag, int category = 1, string username = null, string password = null)
        {
            try
            {
                string cleanTarget = string.IsNullOrWhiteSpace(target) ? "localhost" : target.Trim();

                // 1. Önce Session'daki mevcut teftiş edilmiş modeli kontrol et (böylece 2. kez WMI/şifre sorgulamasına gerek kalmaz)
                var model = Session["PCInfo_" + cleanTarget] as ComputerInfo;
                if (model == null || !model.IsOnline)
                {
                    model = _pcInfoService.GetComputerInfo(cleanTarget, username, password);
                }

                int id;
                if (model != null && model.IsOnline)
                {
                    id = _pcInfoService.SaveFromComputerInfo(model, location, assignedPerson, notes, assetTag, category);
                }
                else
                {
                    // WMI veya ağ kısıtlı olsa dahi cihazı girilen bilgilerle başarıyla envantere ekle
                    var fallbackDev = new DeviceEntity
                    {
                        Brand = "Windows İstemci PC",
                        Model = "Ağ Terminali",
                        SerialNumber = "IP:" + cleanTarget,
                        IpAddress = cleanTarget,
                        Location = location ?? "Hudut Kapısı / Gişe",
                        AssignedPerson = assignedPerson,
                        Category = category,
                        Notes = notes,
                        AssetTag = assetTag,
                        Status = 1
                    };
                    id = _pcInfoService.SaveDevice(fallbackDev);
                }

                string compName = (model != null && !string.IsNullOrWhiteSpace(model.ComputerName)) ? model.ComputerName : cleanTarget;
                return Json(new { success = true, id = id, message = $"'{compName}' CEZA veritabanı envanterine başarıyla kaydedildi." });
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
            try
            {
                var devices = _pcInfoService.GetAllDevices(search, category, status, location);
                var fileBytes = _pcInfoService.ExportInventoryToExcel(devices);
                string fileName = $"CEZA_Donanim_Envanteri_{DateTime.Now:yyyyMMdd_HHmmss}.xlsx";
                return File(fileBytes, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", fileName);
            }
            catch (Exception ex)
            {
                return Content("Excel oluşturma hatası: " + ex.Message);
            }
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
