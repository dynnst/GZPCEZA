using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;

namespace gzpegm.Helpers
{
    public static class ErrorLogHelper
    {
        private static readonly object SyncRoot = new object();

        public static void Log(Exception exception, HttpContext context = null)
        {
            if (exception == null) return;

            try
            {
                context = context ?? HttpContext.Current;
                var entry = BuildEntry(exception, context);
                var dir = GetLogDirectory(context);
                Directory.CreateDirectory(dir);

                var filePath = Path.Combine(dir, DateTime.Now.ToString("yyyy-MM-dd") + ".log");
                var serializer = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };
                var line = serializer.Serialize(entry);

                lock (SyncRoot)
                {
                    File.AppendAllText(filePath, line + Environment.NewLine, Encoding.UTF8);
                }
            }
            catch
            {
                // Hata loglama uygulamayı ikinci kez düşürmemeli.
            }
        }

        public static List<ErrorLogEntry> ReadEntries(HttpContextBase context, int take = 200, string fileName = null)
        {
            var result = new List<ErrorLogEntry>();
            var dir = GetLogDirectory(context);
            if (!Directory.Exists(dir)) return result;

            var files = Directory.GetFiles(dir, "*.log")
                .OrderByDescending(File.GetLastWriteTime)
                .ToList();

            if (!string.IsNullOrWhiteSpace(fileName))
            {
                var safeFile = Path.GetFileName(fileName);
                files = files.Where(x => string.Equals(Path.GetFileName(x), safeFile, StringComparison.OrdinalIgnoreCase)).ToList();
            }

            var serializer = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };

            foreach (var file in files)
            {
                var lines = File.ReadAllLines(file, Encoding.UTF8);
                for (var i = lines.Length - 1; i >= 0; i--)
                {
                    var line = lines[i];
                    if (string.IsNullOrWhiteSpace(line)) continue;

                    try
                    {
                        var entry = serializer.Deserialize<ErrorLogEntry>(line);
                        if (entry == null) continue;

                        entry.FileName = Path.GetFileName(file);
                        entry.LineNumber = i + 1;
                        entry.Id = ToId(entry.FileName, entry.LineNumber);
                        result.Add(entry);

                        if (result.Count >= take) return result;
                    }
                    catch
                    {
                        result.Add(new ErrorLogEntry
                        {
                            Id = ToId(Path.GetFileName(file), i + 1),
                            FileName = Path.GetFileName(file),
                            LineNumber = i + 1,
                            LoggedAt = File.GetLastWriteTime(file),
                            ExceptionType = "LogParseException",
                            Message = "Log satırı okunamadı.",
                            Detail = line
                        });
                    }
                }
            }

            return result;
        }

        public static ErrorLogEntry FindEntry(HttpContextBase context, string id)
        {
            var decoded = FromId(id);
            if (decoded == null) return null;

            var fileName = decoded.Item1;
            var lineNumber = decoded.Item2;
            var dir = GetLogDirectory(context);
            var path = Path.Combine(dir, Path.GetFileName(fileName));
            if (!File.Exists(path)) return null;

            var lines = File.ReadAllLines(path, Encoding.UTF8);
            if (lineNumber < 1 || lineNumber > lines.Length) return null;

            var serializer = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };
            var entry = serializer.Deserialize<ErrorLogEntry>(lines[lineNumber - 1]);
            entry.FileName = Path.GetFileName(path);
            entry.LineNumber = lineNumber;
            entry.Id = id;
            return entry;
        }

        public static string GetLogDirectory(HttpContextBase context)
        {
            return Path.GetFullPath(context.Server.MapPath("~/Logs/Errors/"));
        }

        private static string GetLogDirectory(HttpContext context)
        {
            return context != null
                ? Path.GetFullPath(context.Server.MapPath("~/Logs/Errors/"))
                : Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Logs", "Errors");
        }

        private static ErrorLogEntry BuildEntry(Exception exception, HttpContext context)
        {
            var baseException = exception.GetBaseException();
            var request = context?.Request;
            var user = context?.User;

            return new ErrorLogEntry
            {
                LoggedAt = DateTime.Now,
                ExceptionType = baseException.GetType().FullName,
                Message = baseException.Message,
                Detail = exception.ToString(),
                Url = Safe(() => request?.Url?.ToString()),
                Path = Safe(() => request?.Path),
                HttpMethod = Safe(() => request?.HttpMethod),
                UserName = Safe(() => user?.Identity?.IsAuthenticated == true ? user.Identity.Name : null),
                IpAddress = Safe(() => request?.UserHostAddress),
                UserAgent = Safe(() => request?.UserAgent),
                Referrer = Safe(() => request?.UrlReferrer?.ToString()),
                MachineName = Environment.MachineName
            };
        }

        private static string Safe(Func<string> getter)
        {
            try { return getter(); }
            catch { return null; }
        }

        private static string ToId(string fileName, int lineNumber)
        {
            var raw = fileName + "|" + lineNumber;
            return Convert.ToBase64String(Encoding.UTF8.GetBytes(raw)).TrimEnd('=').Replace('+', '-').Replace('/', '_');
        }

        private static Tuple<string, int> FromId(string id)
        {
            try
            {
                var padded = id.Replace('-', '+').Replace('_', '/');
                switch (padded.Length % 4)
                {
                    case 2: padded += "=="; break;
                    case 3: padded += "="; break;
                }

                var raw = Encoding.UTF8.GetString(Convert.FromBase64String(padded));
                var parts = raw.Split('|');
                if (parts.Length != 2) return null;
                int lineNumber;
                if (!int.TryParse(parts[1], out lineNumber)) return null;
                return Tuple.Create(Path.GetFileName(parts[0]), lineNumber);
            }
            catch
            {
                return null;
            }
        }
    }

    public class ErrorLogEntry
    {
        public string Id { get; set; }
        public string FileName { get; set; }
        public int LineNumber { get; set; }
        public DateTime LoggedAt { get; set; }
        public string ExceptionType { get; set; }
        public string Message { get; set; }
        public string Detail { get; set; }
        public string Url { get; set; }
        public string Path { get; set; }
        public string HttpMethod { get; set; }
        public string UserName { get; set; }
        public string IpAddress { get; set; }
        public string UserAgent { get; set; }
        public string Referrer { get; set; }
        public string MachineName { get; set; }
    }
}
