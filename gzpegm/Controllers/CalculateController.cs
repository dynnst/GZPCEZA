using gzpegm.Cont;
using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Mvc;
using ClosedXML.Excel;

namespace gzpegm.Controllers
{
    [UserAuthorize(Users = "2,3")] // Admin = 2, Ceza Islemleri = 3
    public class CalculateController : Controller
    {
        [Route("Hesaplama")]
        public ActionResult Index()
        {
            var currentUser = GetUser();
            if (currentUser != null)
            {
                string fullName = ((currentUser.fldName ?? "").Trim() + " " + (currentUser.fldLastName ?? "").Trim()).Trim();
                string sicil = (currentUser.fldSicil ?? "").Trim();
                ViewBag.OfficerName = !string.IsNullOrEmpty(sicil) ? fullName + " (" + sicil + ")" : fullName;
                ViewBag.OfficerBorder = currentUser.fldBorder;
            }
            return View();
        }

        [NonAction]
        public E_User GetUser()
        {
            HttpCookie userCookie = Request.Cookies["Token"];
            Token token = new Token();
            gzpegm.Cont.User user = new User();
            int userId = 0;

            if (userCookie != null)
            {
                var tokenData = token.GetToken(userCookie.Value.ToString());
                if (tokenData?.fldUserId != null)
                    int.TryParse(tokenData.fldUserId.ToString(), out userId);
            }

            return user.GetUserById(userId);
        }

        [HttpGet]
        public JsonResult GetHistoryCount()
        {
            try
            {
                var currentUser = GetUser();
                if (currentUser == null)
                    return Json(new { count = 0 }, JsonRequestBehavior.AllowGet);

                using (var db = new GZPEGM1())
                {
                    string fullName = ((currentUser.fldName ?? "").Trim() + " " + (currentUser.fldLastName ?? "").Trim()).Trim();
                    string sicil = (currentUser.fldSicil ?? "").Trim();

                    var query = db.E_History
                        .AsNoTracking()
                        .Where(h => h.fldUser != null);

                    if (!string.IsNullOrEmpty(currentUser.fldBorder))
                        query = query.Where(h => h.fldBorder == currentUser.fldBorder);

                    if (!string.IsNullOrEmpty(sicil))
                    {
                        string sicilPrefix = sicil + "|";
                        string userKey = !string.IsNullOrEmpty(fullName) ? sicil + "|" + fullName : null;

                        query = query.Where(h =>
                            h.fldUser == sicil ||
                            h.fldUser == fullName ||
                            h.fldUser == userKey ||
                            h.fldUser.StartsWith(sicilPrefix));
                    }
                    else
                    {
                        query = query.Where(h => h.fldUser == fullName);
                    }

                    var count = query.Count();

                    return Json(new { count }, JsonRequestBehavior.AllowGet);
                }
            }
            catch (Exception)
            {
                return Json(new { count = 0 }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public JsonResult ParseHksFile()
        {
            try
            {
                if (Request.Files.Count == 0 || Request.Files[0] == null || Request.Files[0].ContentLength == 0)
                {
                    return Json(new { success = false, message = "Lütfen bir dosya seçiniz." });
                }

                var file = Request.Files[0];
                string fileName = file.FileName ?? "";
                string ext = Path.GetExtension(fileName).ToLowerInvariant();

                var passenger = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
                {
                    { "name", "" },
                    { "surname", "" },
                    { "fatherName", "" },
                    { "motherName", "" },
                    { "birthdate", "" },
                    { "gender", "" },
                    { "idNo", "" },
                    { "passportNo", "" },
                    { "country", "" }
                };

                var movements = new List<object>();

                if (ext == ".csv" || ext == ".txt")
                {
                    using (var reader = new StreamReader(file.InputStream, Encoding.GetEncoding("windows-1254"), true))
                    {
                        string content = reader.ReadToEnd();
                        ParseCsvContent(content, passenger, movements);
                    }
                }
                else if (ext == ".xlsx" || ext == ".xls")
                {
                    using (var workbook = new XLWorkbook(file.InputStream))
                    {
                        var worksheet = workbook.Worksheets.FirstOrDefault();
                        if (worksheet != null)
                        {
                            ParseExcelWorksheet(worksheet, passenger, movements);
                        }
                    }
                }
                else
                {
                    return Json(new { success = false, message = "Desteklenmeyen dosya türü. Lütfen Excel (.xlsx) veya CSV dosyası yükleyiniz." });
                }

                return Json(new
                {
                    success = true,
                    passenger = new
                    {
                        name = passenger["name"],
                        surname = passenger["surname"],
                        fullName = (passenger["name"] + " " + passenger["surname"]).Trim(),
                        fatherName = passenger["fatherName"],
                        motherName = passenger["motherName"],
                        birthdate = passenger["birthdate"],
                        gender = passenger["gender"],
                        idNo = passenger["idNo"],
                        passportNo = passenger["passportNo"],
                        country = passenger["country"]
                    },
                    movements
                });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = "Dosya ayrıştırılırken hata oluştu: " + ex.Message });
            }
        }

        [NonAction]
        private void ParseCsvContent(string content, Dictionary<string, string> passenger, List<object> movements)
        {
            var lines = content.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.RemoveEmptyEntries);
            if (lines.Length == 0) return;

            char delimiter = lines[0].Contains(';') ? ';' : ',';
            var headers = lines[0].Split(delimiter).Select(h => CleanHeader(h)).ToList();

            int colType = headers.FindIndex(h => h.Contains("giriscikistipi") || h.Contains("tip") || h.Contains("hareket"));
            int colDate = headers.FindIndex(h => h == "tarih" || (h.Contains("tarih") && !h.Contains("dogum")));
            int colCancel = headers.FindIndex(h => h.Contains("iptal"));
            int colName = headers.FindIndex(h => h == "ad" || h == "adi" || h.Contains("yolcuadi"));
            int colSurname = headers.FindIndex(h => h == "soyad" || h == "soyadi");
            int colFather = headers.FindIndex(h => h.Contains("baba"));
            int colMother = headers.FindIndex(h => h.Contains("anne"));
            int colBirth = headers.FindIndex(h => h.Contains("dogum"));
            int colGender = headers.FindIndex(h => h.Contains("cinsiyet"));
            int colId = headers.FindIndex(h => h.Contains("kimlik") || h.Contains("ykn") || h.Contains("tckn"));
            int colPass = headers.FindIndex(h => h.Contains("belgeserino") || (h.Contains("serino") && !h.Contains("harf")) || h.Contains("pasaport"));
            int colCountry = headers.FindIndex(h => h.Contains("ulke"));

            for (int i = 1; i < lines.Length; i++)
            {
                var row = lines[i].Split(delimiter);
                if (row.Length == 0) continue;

                if (string.IsNullOrEmpty(passenger["name"]) && colName >= 0 && colName < row.Length)
                    passenger["name"] = row[colName].Trim();
                if (string.IsNullOrEmpty(passenger["surname"]) && colSurname >= 0 && colSurname < row.Length)
                    passenger["surname"] = row[colSurname].Trim();
                if (string.IsNullOrEmpty(passenger["fatherName"]) && colFather >= 0 && colFather < row.Length)
                    passenger["fatherName"] = row[colFather].Trim();
                if (string.IsNullOrEmpty(passenger["motherName"]) && colMother >= 0 && colMother < row.Length)
                    passenger["motherName"] = row[colMother].Trim();
                if (string.IsNullOrEmpty(passenger["birthdate"]) && colBirth >= 0 && colBirth < row.Length)
                    passenger["birthdate"] = CleanDateOnly(row[colBirth]);
                if (string.IsNullOrEmpty(passenger["gender"]) && colGender >= 0 && colGender < row.Length)
                    passenger["gender"] = row[colGender].Trim();
                if (string.IsNullOrEmpty(passenger["idNo"]) && colId >= 0 && colId < row.Length)
                    passenger["idNo"] = row[colId].Trim();
                if (string.IsNullOrEmpty(passenger["passportNo"]) && colPass >= 0 && colPass < row.Length)
                    passenger["passportNo"] = row[colPass].Trim();
                if (string.IsNullOrEmpty(passenger["country"]) && colCountry >= 0 && colCountry < row.Length)
                    passenger["country"] = row[colCountry].Trim();

                bool isCancelled = false;
                if (colCancel >= 0 && colCancel < row.Length)
                {
                    string status = row[colCancel].ToLowerInvariant();
                    if (status.Contains("iptal") || status.Contains("gecersiz")) isCancelled = true;
                }

                if (isCancelled) continue;

                if (colDate >= 0 && colDate < row.Length)
                {
                    string rawDate = row[colDate].Trim();
                    string cleanDate = CleanDateOnly(rawDate);
                    if (string.IsNullOrEmpty(cleanDate)) continue;

                    string movementType = "G";
                    if (colType >= 0 && colType < row.Length)
                    {
                        string t = row[colType].Trim().ToLowerInvariant();
                        if (t.StartsWith("ç") || t.StartsWith("c") || t.Contains("çıkış") || t.Contains("cikis"))
                            movementType = "C";
                        else
                            movementType = "G";
                    }

                    movements.Add(new
                    {
                        type = movementType,
                        typeName = movementType == "C" ? "Çıkış" : "Giriş",
                        date = cleanDate,
                        rawDate = rawDate
                    });
                }
            }
        }

        [NonAction]
        private void ParseExcelWorksheet(IXLWorksheet worksheet, Dictionary<string, string> passenger, List<object> movements)
        {
            var rows = worksheet.RangeUsed()?.RowsUsed()?.ToList();
            if (rows == null || rows.Count < 2) return;

            var headerRow = rows[0];
            var headers = new List<string>();
            foreach (var cell in headerRow.Cells())
            {
                headers.Add(CleanHeader(cell.GetString()));
            }

            int colType = headers.FindIndex(h => h.Contains("giriscikistipi") || h.Contains("tip") || h.Contains("hareket"));
            int colDate = headers.FindIndex(h => h == "tarih" || (h.Contains("tarih") && !h.Contains("dogum")));
            int colCancel = headers.FindIndex(h => h.Contains("iptal"));
            int colName = headers.FindIndex(h => h == "ad" || h == "adi" || h.Contains("yolcuadi"));
            int colSurname = headers.FindIndex(h => h == "soyad" || h == "soyadi");
            int colFather = headers.FindIndex(h => h.Contains("baba"));
            int colMother = headers.FindIndex(h => h.Contains("anne"));
            int colBirth = headers.FindIndex(h => h.Contains("dogum"));
            int colGender = headers.FindIndex(h => h.Contains("cinsiyet"));
            int colId = headers.FindIndex(h => h.Contains("kimlik") || h.Contains("ykn") || h.Contains("tckn"));
            int colPass = headers.FindIndex(h => h.Contains("belgeserino") || (h.Contains("serino") && !h.Contains("harf")) || h.Contains("pasaport"));
            int colCountry = headers.FindIndex(h => h.Contains("ulke"));

            for (int r = 1; r < rows.Count; r++)
            {
                var row = rows[r];
                var cells = row.Cells().ToList();
                if (cells.Count == 0) continue;

                string GetCellValue(int colIdx)
                {
                    if (colIdx < 0 || colIdx >= cells.Count) return "";
                    return cells[colIdx].GetString().Trim();
                }

                if (string.IsNullOrEmpty(passenger["name"])) passenger["name"] = GetCellValue(colName);
                if (string.IsNullOrEmpty(passenger["surname"])) passenger["surname"] = GetCellValue(colSurname);
                if (string.IsNullOrEmpty(passenger["fatherName"])) passenger["fatherName"] = GetCellValue(colFather);
                if (string.IsNullOrEmpty(passenger["motherName"])) passenger["motherName"] = GetCellValue(colMother);
                if (string.IsNullOrEmpty(passenger["birthdate"])) passenger["birthdate"] = CleanDateOnly(GetCellValue(colBirth));
                if (string.IsNullOrEmpty(passenger["gender"])) passenger["gender"] = GetCellValue(colGender);
                if (string.IsNullOrEmpty(passenger["idNo"])) passenger["idNo"] = GetCellValue(colId);
                if (string.IsNullOrEmpty(passenger["passportNo"])) passenger["passportNo"] = GetCellValue(colPass);
                if (string.IsNullOrEmpty(passenger["country"])) passenger["country"] = GetCellValue(colCountry);

                bool isCancelled = false;
                string cancelVal = GetCellValue(colCancel).ToLowerInvariant();
                if (cancelVal.Contains("iptal") || cancelVal.Contains("gecersiz")) isCancelled = true;
                if (isCancelled) continue;

                string rawDate = GetCellValue(colDate);
                string cleanDate = CleanDateOnly(rawDate);
                if (string.IsNullOrEmpty(cleanDate)) continue;

                string movementType = "G";
                string typeVal = GetCellValue(colType).ToLowerInvariant();
                if (typeVal.StartsWith("ç") || typeVal.StartsWith("c") || typeVal.Contains("çıkış") || typeVal.Contains("cikis"))
                    movementType = "C";
                else
                    movementType = "G";

                movements.Add(new
                {
                    type = movementType,
                    typeName = movementType == "C" ? "Çıkış" : "Giriş",
                    date = cleanDate,
                    rawDate = rawDate
                });
            }
        }

        [NonAction]
        private string CleanHeader(string h)
        {
            if (string.IsNullOrEmpty(h)) return "";
            return h.Trim().ToLowerInvariant()
                .Replace("ı", "i")
                .Replace("ğ", "g")
                .Replace("ü", "u")
                .Replace("ş", "s")
                .Replace("ö", "o")
                .Replace("ç", "c")
                .Replace(" ", "")
                .Replace("_", "")
                .Replace("-", "");
        }

        [NonAction]
        private string CleanDateOnly(string raw)
        {
            if (string.IsNullOrEmpty(raw)) return "";
            var match = Regex.Match(raw.Trim(), @"(\d{1,2})[./-](\d{1,2})[./-](\d{4})");
            if (match.Success)
            {
                int day = int.Parse(match.Groups[1].Value);
                int month = int.Parse(match.Groups[2].Value);
                int year = int.Parse(match.Groups[3].Value);
                if (day >= 1 && day <= 31 && month >= 1 && month <= 12 && year >= 1900 && year <= 2100)
                {
                    return string.Format("{0:D2}.{1:D2}.{2:D4}", day, month, year);
                }
            }
            return "";
        }

        [HttpPost]
        public ActionResult ScanPassportImage()
        {
            var user = GetUser();
            if (user == null)
                return Json(new { success = false, message = "Lütfen sisteme giriş yapın." });

            if (Request.Files.Count == 0 || Request.Files[0] == null || Request.Files[0].ContentLength == 0)
                return Json(new { success = false, message = "Lütfen bir pasaport görseli seçin." });

            var file = Request.Files[0];
            var ext = System.IO.Path.GetExtension(file.FileName ?? "").ToLowerInvariant();
            var allowedExts = new[] { ".jpg", ".jpeg", ".png", ".bmp", ".webp", ".jfif" };
            if (!allowedExts.Contains(ext))
                return Json(new { success = false, message = "Desteklenmeyen dosya formatı. Lütfen JPG veya PNG yükleyin." });

            var tempDir = System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "App_Data", "TempUploads");
            if (!System.IO.Directory.Exists(tempDir))
                System.IO.Directory.CreateDirectory(tempDir);

            var tempFile = System.IO.Path.Combine(tempDir, Guid.NewGuid().ToString("N") + ext);
            file.SaveAs(tempFile);

            try
            {
                var scriptPath = System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "App_Data", "PassportOcr.ps1");
                if (!System.IO.File.Exists(scriptPath))
                {
                    return Json(new { success = false, message = "OCR betiği bulunamadı." });
                }

                var psi = new System.Diagnostics.ProcessStartInfo
                {
                    FileName = "powershell.exe",
                    Arguments = string.Format("-NoProfile -ExecutionPolicy Bypass -File \"{0}\" -imagePath \"{1}\"", scriptPath, tempFile),
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    UseShellExecute = false,
                    CreateNoWindow = true,
                    StandardOutputEncoding = System.Text.Encoding.UTF8
                };

                using (var proc = System.Diagnostics.Process.Start(psi))
                {
                    var output = proc.StandardOutput.ReadToEnd();
                    proc.WaitForExit(15000);

                    if (string.IsNullOrWhiteSpace(output))
                    {
                        return Json(new { success = false, message = "OCR çıktısı alınamadı." });
                    }

                    var jsonStartIndex = output.IndexOf('{');
                    var jsonEndIndex = output.LastIndexOf('}');
                    if (jsonStartIndex >= 0 && jsonEndIndex > jsonStartIndex)
                    {
                        var cleanJson = output.Substring(jsonStartIndex, jsonEndIndex - jsonStartIndex + 1);
                        return Content(cleanJson, "application/json", System.Text.Encoding.UTF8);
                    }

                    return Json(new { success = false, message = "OCR çıktısı ayrıştırılamadı." });
                }
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = "Hata: " + ex.Message });
            }
            finally
            {
                try { if (System.IO.File.Exists(tempFile)) System.IO.File.Delete(tempFile); } catch { }
            }
        }
    }
}
