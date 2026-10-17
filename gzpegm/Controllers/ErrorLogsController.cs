using gzpegm.Cont;
using gzpegm.Helpers;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize(Users = "2")]
    public class ErrorLogsController : Controller
    {
        [HttpGet]
        [Route("HataLoglari")]
        public ActionResult Index(int take = 200, string file = null)
        {
            if (take < 20) take = 20;
            if (take > 1000) take = 1000;

            var model = new ErrorLogsPageViewModel
            {
                Take = take,
                SelectedFile = file,
                LogDirectory = ErrorLogHelper.GetLogDirectory(HttpContext),
                Entries = ErrorLogHelper.ReadEntries(HttpContext, take, file)
            };

            model.Files = GetLogFiles(model.LogDirectory);
            return View(model);
        }

        [HttpGet]
        public ActionResult Detail(string id)
        {
            var entry = ErrorLogHelper.FindEntry(HttpContext, id);
            if (entry == null) return HttpNotFound("Hata log kaydı bulunamadı.");
            return View(entry);
        }

        [HttpGet]
        public ActionResult Download(string file)
        {
            var safeFile = Path.GetFileName(file ?? "");
            if (string.IsNullOrWhiteSpace(safeFile) || !safeFile.EndsWith(".log", StringComparison.OrdinalIgnoreCase))
            {
                return HttpNotFound("Log dosyası bulunamadı.");
            }

            var path = Path.Combine(ErrorLogHelper.GetLogDirectory(HttpContext), safeFile);
            if (!System.IO.File.Exists(path)) return HttpNotFound("Log dosyası bulunamadı.");

            return File(path, "text/plain", safeFile);
        }

        private static List<ErrorLogFileViewModel> GetLogFiles(string logDirectory)
        {
            if (string.IsNullOrWhiteSpace(logDirectory) || !Directory.Exists(logDirectory))
            {
                return new List<ErrorLogFileViewModel>();
            }

            return Directory.GetFiles(logDirectory, "*.log")
                .Select(path => new FileInfo(path))
                .OrderByDescending(file => file.LastWriteTime)
                .Select(file => new ErrorLogFileViewModel
                {
                    FileName = file.Name,
                    Length = file.Length,
                    LastWriteTime = file.LastWriteTime
                })
                .ToList();
        }
    }

    public class ErrorLogsPageViewModel
    {
        public int Take { get; set; }
        public string SelectedFile { get; set; }
        public string LogDirectory { get; set; }
        public List<ErrorLogEntry> Entries { get; set; } = new List<ErrorLogEntry>();
        public List<ErrorLogFileViewModel> Files { get; set; } = new List<ErrorLogFileViewModel>();
    }

    public class ErrorLogFileViewModel
    {
        public string FileName { get; set; }
        public long Length { get; set; }
        public DateTime LastWriteTime { get; set; }
    }
}
