// (Dosyanın tamamı, sadece PrintForm1 metodu içinde ViewBag atamaları eklendi)
using gzpegm.Cont;
using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity.Validation;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize(Users = "2,3")]
    public class EInadController : Controller
    {
        private GZPEGM1 db = new GZPEGM1();

        // Türkçe karakterlerin bozulmaması için UTF-8 Content-Encoding ile JSON döner
        protected JsonResult JsonUtf8(object data, JsonRequestBehavior behavior = JsonRequestBehavior.DenyGet)
        {
            return new JsonResult
            {
                Data = data,
                JsonRequestBehavior = behavior,
                ContentEncoding = Encoding.UTF8,
                ContentType = "application/json"
            };
        }

        private E_User GetCurrentUser()
        {
            try
            {
                HttpCookie cookie = Request.Cookies["Token"];
                if (cookie == null) return null;

                Token token = new Token();
                var data = token.GetToken(cookie.Value);
                if (data == null) return null;

                if (!int.TryParse(data.fldUserId?.ToString(), out int userId))
                    return null;

                User user = new User();
                return user.GetUserById(userId);
            }
            catch
            {
                return null;
            }
        }

        private bool HasAccessToRecord(E_Inad item, E_User user)
        {
            if (user == null) return false;
            if (string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase))
                return true;

            var userBorder = (user.fldBorder ?? "").Trim();
            var itemBorder = (item?.Kapi ?? "").Trim();

            return !string.IsNullOrEmpty(userBorder)
                && string.Equals(userBorder, itemBorder, StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>
        /// Ülkeler listesini birleştiren helper metod
        /// </summary>
        private static System.Collections.Generic.List<string> GetCountriesList()
        {
            var ulkeModel = new UlkeModel();
            return ulkeModel.AGRUBU
                .Union(ulkeModel.BGRUBU)
                .Union(ulkeModel.CGRUBU)
                .Union(ulkeModel.DGRUBU)
                .Union(ulkeModel.EGRUBU)
                .Union(ulkeModel.FGRUBU)
                .Union(ulkeModel.GGRUBU)
                .Where(s => !string.IsNullOrWhiteSpace(s))
                .Select(s => s.Trim())
                .Distinct()
                .OrderBy(s => s)
                .ToList();
        }

        private DateTime? ReadDateTimeField(string fieldName, DateTime? fallback = null)
        {
            var raw = Request.Form[fieldName];
            if (string.IsNullOrWhiteSpace(raw))
                return fallback;

            var formats = new[]
            {
                "yyyy-MM-ddTHH:mm",
                "yyyy-MM-ddTHH:mm:ss",
                "yyyy-MM-dd HH:mm",
                "dd.MM.yyyy HH:mm",
                "dd.MM.yyyy"
            };

            if (DateTime.TryParseExact(raw.Trim(), formats, CultureInfo.InvariantCulture, DateTimeStyles.None, out var exact))
                return exact;

            if (DateTime.TryParse(raw.Trim(), new CultureInfo("tr-TR"), DateTimeStyles.None, out var parsed))
                return parsed;

            return fallback;
        }

        private static IEnumerable<E_Inad> ApplyInadFilters(IEnumerable<E_Inad> query, string q, string border, string user, DateTime? from, DateTime? to)
        {
            if (!string.IsNullOrWhiteSpace(q))
            {
                var search = q.Trim();
                query = query.Where(x =>
                    (!string.IsNullOrEmpty(x.AdSoyad) && x.AdSoyad.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0) ||
                    (!string.IsNullOrEmpty(x.Uyruk) && x.Uyruk.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0) ||
                    (!string.IsNullOrEmpty(x.PasaportNo) && x.PasaportNo.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0) ||
                    (!string.IsNullOrEmpty(x.Kapi) && x.Kapi.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0) ||
                    (!string.IsNullOrEmpty(x.Sicil) && x.Sicil.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0) ||
                    (!string.IsNullOrEmpty(x.Durum) && x.Durum.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0));
            }

            if (!string.IsNullOrWhiteSpace(border))
            {
                var selectedBorder = border.Trim();
                query = query.Where(x => string.Equals(x.Kapi ?? string.Empty, selectedBorder, StringComparison.OrdinalIgnoreCase));
            }

            if (!string.IsNullOrWhiteSpace(user))
            {
                var selectedUser = user.Trim();
                query = query.Where(x => string.Equals(x.Sicil ?? string.Empty, selectedUser, StringComparison.OrdinalIgnoreCase));
            }

            if (from.HasValue)
            {
                var fromDate = from.Value.Date;
                query = query.Where(x => x.TarihSaat.HasValue && x.TarihSaat.Value.Date >= fromDate);
            }

            if (to.HasValue)
            {
                var toDate = to.Value.Date;
                query = query.Where(x => x.TarihSaat.HasValue && x.TarihSaat.Value.Date <= toDate);
            }

            return query;
        }

        private void SetIndexFilterViewBag(IEnumerable<E_Inad> allData, string q, string border, string user, DateTime? from, DateTime? to, int resultCount, bool defaultLimited)
        {
            var dataList = allData as IList<E_Inad> ?? allData.ToList();

            ViewBag.BorderList = dataList
                .Select(x => x.Kapi)
                .Where(x => !string.IsNullOrWhiteSpace(x))
                .Distinct()
                .OrderBy(x => x)
                .ToList();

            ViewBag.UserList = dataList
                .Select(x => x.Sicil)
                .Where(x => !string.IsNullOrWhiteSpace(x))
                .Distinct()
                .OrderBy(x => x)
                .ToList();

            ViewBag.SearchText = q ?? string.Empty;
            ViewBag.SelectedBorder = border ?? string.Empty;
            ViewBag.SelectedUser = user ?? string.Empty;
            ViewBag.From = from;
            ViewBag.To = to;
            ViewBag.ResultInfo = defaultLimited
                ? "Filtre uygulanmadigi icin son 100 kayit gosteriliyor."
                : resultCount + " kayit listeleniyor.";

            // KPI Metrikleri (Yönetici & Nöbetçi Amir Özeti)
            var today = DateTime.Today;
            ViewBag.TotalCount = dataList.Count;
            ViewBag.InadOdadaCount = dataList.Count(x => !string.IsNullOrEmpty(x.Durum) && x.Durum.IndexOf("İnad Odasına Alındı", StringComparison.OrdinalIgnoreCase) >= 0);
            ViewBag.InadEdildiCount = dataList.Count(x => !string.IsNullOrEmpty(x.Durum) && x.Durum.IndexOf("İnad Edildi", StringComparison.OrdinalIgnoreCase) >= 0);
            ViewBag.TodayCount = dataList.Count(x => x.TarihSaat.HasValue && x.TarihSaat.Value.Date == today);
        }

        private static string BuildInadExcelHtml(List<E_Inad> list, string filterInfo)
        {
            var sb = new System.Text.StringBuilder();
            sb.AppendLine("<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />");
            sb.AppendLine("<style>");
            sb.AppendLine("body { font-family: Calibri, Arial, sans-serif; font-size: 11pt; color: #1f2937; }");
            sb.AppendLine(".title { font-size: 18pt; font-weight: 700; color: #1f3b63; margin-bottom: 6px; }");
            sb.AppendLine(".subtitle { font-size: 10pt; color: #475569; margin-bottom: 10px; }");
            sb.AppendLine("table { border-collapse: collapse; width: 100%; }");
            sb.AppendLine("th { background: #1f4e78; color: #ffffff; font-weight: 700; font-size: 11pt; border: 1px solid #9fb3c8; padding: 8px; text-align: center; }");
            sb.AppendLine("td { border: 1px solid #cbd5e1; padding: 6px 8px; vertical-align: middle; }");
            sb.AppendLine(".nowrap { white-space: nowrap; }");
            sb.AppendLine("tr:nth-child(even) td { background: #f8fafc; }");
            sb.AppendLine("</style></head><body>");
            sb.AppendLine("<div class=\"title\">INAD Kayitlari</div>");
            sb.AppendLine("<div class=\"subtitle\">Olusturma Tarihi: " + HttpUtility.HtmlEncode(DateTime.Now.ToString("dd.MM.yyyy HH:mm")) + "</div>");
            sb.AppendLine("<div class=\"subtitle\">" + HttpUtility.HtmlEncode(filterInfo ?? string.Empty) + "</div>");
            sb.AppendLine("<table><thead><tr>");
            sb.AppendLine("<th>Tarih Saat</th><th>Ad Soyad</th><th>Uyruk</th><th>Pasaport No</th><th>Kapi</th><th>Durum</th><th>Sicil</th>");
            sb.AppendLine("</tr></thead><tbody>");

            foreach (var item in list)
            {
                sb.AppendLine("<tr>");
                sb.AppendLine("<td class=\"nowrap\">" + HttpUtility.HtmlEncode(item.TarihSaat?.ToString("dd.MM.yyyy HH:mm") ?? string.Empty) + "</td>");
                sb.AppendLine("<td>" + HttpUtility.HtmlEncode(item.AdSoyad ?? string.Empty) + "</td>");
                sb.AppendLine("<td>" + HttpUtility.HtmlEncode(item.Uyruk ?? string.Empty) + "</td>");
                sb.AppendLine("<td>" + HttpUtility.HtmlEncode(item.PasaportNo ?? string.Empty) + "</td>");
                sb.AppendLine("<td>" + HttpUtility.HtmlEncode(item.Kapi ?? string.Empty) + "</td>");
                sb.AppendLine("<td>" + HttpUtility.HtmlEncode(item.Durum ?? string.Empty) + "</td>");
                sb.AppendLine("<td>" + HttpUtility.HtmlEncode(item.Sicil ?? string.Empty) + "</td>");
                sb.AppendLine("</tr>");
            }

            sb.AppendLine("</tbody></table></body></html>");
            return sb.ToString();
        }

        private static byte[] BuildInadPdfContent(List<E_Inad> list, string filterInfo)
        {
            using (var stream = new System.IO.MemoryStream())
            {
                var document = new iTextSharp.text.Document(iTextSharp.text.PageSize.A4.Rotate(), 18, 18, 18, 18);
                iTextSharp.text.pdf.PdfWriter.GetInstance(document, stream);
                document.Open();

                var titleFont = BuildUnicodeFont(14, true);
                var infoFont = BuildUnicodeFont(9);
                var headerFont = BuildUnicodeFont(9, true, iTextSharp.text.BaseColor.WHITE);
                var cellFont = BuildUnicodeFont(8);

                document.Add(new iTextSharp.text.Paragraph("INAD Kayitlari", titleFont));
                document.Add(new iTextSharp.text.Paragraph("Olusturma Tarihi: " + DateTime.Now.ToString("dd.MM.yyyy HH:mm"), infoFont));
                document.Add(new iTextSharp.text.Paragraph(filterInfo ?? string.Empty, infoFont));
                document.Add(new iTextSharp.text.Paragraph(" "));

                var table = new iTextSharp.text.pdf.PdfPTable(7) { WidthPercentage = 100 };
                table.SetWidths(new float[] { 14f, 20f, 12f, 14f, 14f, 12f, 10f });

                foreach (var header in new[] { "Tarih Saat", "Ad Soyad", "Uyruk", "Pasaport No", "Kapi", "Durum", "Sicil" })
                {
                    var cell = new iTextSharp.text.pdf.PdfPCell(new iTextSharp.text.Phrase(header, headerFont))
                    {
                        BackgroundColor = new iTextSharp.text.BaseColor(31, 78, 120),
                        HorizontalAlignment = iTextSharp.text.Element.ALIGN_CENTER,
                        Padding = 5f
                    };
                    table.AddCell(cell);
                }

                foreach (var item in list)
                {
                    AddPdfCell(table, item.TarihSaat?.ToString("dd.MM.yyyy HH:mm") ?? string.Empty, cellFont);
                    AddPdfCell(table, item.AdSoyad ?? string.Empty, cellFont);
                    AddPdfCell(table, item.Uyruk ?? string.Empty, cellFont);
                    AddPdfCell(table, item.PasaportNo ?? string.Empty, cellFont);
                    AddPdfCell(table, item.Kapi ?? string.Empty, cellFont);
                    AddPdfCell(table, item.Durum ?? string.Empty, cellFont);
                    AddPdfCell(table, item.Sicil ?? string.Empty, cellFont);
                }

                document.Add(table);
                document.Close();
                return stream.ToArray();
            }
        }

        private static void AddPdfCell(iTextSharp.text.pdf.PdfPTable table, string value, iTextSharp.text.Font font, bool center = false)
        {
            var cell = new iTextSharp.text.pdf.PdfPCell(new iTextSharp.text.Phrase(value ?? string.Empty, font))
            {
                Padding = 4f
            };

            if (center)
            {
                cell.HorizontalAlignment = iTextSharp.text.Element.ALIGN_CENTER;
            }

            table.AddCell(cell);
        }

        private static iTextSharp.text.Font BuildUnicodeFont(float size, bool bold = false, iTextSharp.text.BaseColor color = null)
        {
            var fontPath = System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Fonts), "arial.ttf");
            var baseFont = iTextSharp.text.pdf.BaseFont.CreateFont(fontPath, iTextSharp.text.pdf.BaseFont.IDENTITY_H, iTextSharp.text.pdf.BaseFont.EMBEDDED);
            return new iTextSharp.text.Font(baseFont, size, bold ? iTextSharp.text.Font.BOLD : iTextSharp.text.Font.NORMAL, color ?? iTextSharp.text.BaseColor.BLACK);
        }

        public ActionResult Index(string q, string border, string userCode, DateTime? from, DateTime? to, string export)
        {
            var user = GetCurrentUser();
            if (user == null)
            {
                TempData["msgError"] = "Lütfen sisteme giriş yapın.";
                return RedirectToAction("Index", "Giris");
            }

            var query = db.E_Inad.AsNoTracking().AsQueryable();

            if (!string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase))
            {
                var userBorder = (user.fldBorder ?? "").Trim();
                query = query.Where(x => x.Kapi == userBorder);
            }

            var allData = query
                .OrderByDescending(x => x.TarihSaat)
                .ToList();

            var filtered = ApplyInadFilters(allData, q, border, userCode, from, to)
                .OrderByDescending(x => x.TarihSaat);

            var hasFilter = !string.IsNullOrWhiteSpace(q)
                || !string.IsNullOrWhiteSpace(border)
                || !string.IsNullOrWhiteSpace(userCode)
                || from.HasValue
                || to.HasValue;

            var list = hasFilter ? filtered.ToList() : filtered.Take(100).ToList();

            var filterInfo = string.Format(
                "Arama: {0} | Kapi: {1} | Kullanici: {2} | Baslangic: {3} | Bitis: {4}",
                string.IsNullOrWhiteSpace(q) ? "Tumu" : q,
                string.IsNullOrWhiteSpace(border) ? "Tumu" : border,
                string.IsNullOrWhiteSpace(userCode) ? "Tumu" : userCode,
                from.HasValue ? from.Value.ToString("dd.MM.yyyy") : "Yok",
                to.HasValue ? to.Value.ToString("dd.MM.yyyy") : "Yok");

            if (!string.IsNullOrWhiteSpace(export))
            {
                if (string.Equals(export, "excel", StringComparison.OrdinalIgnoreCase))
                {
                    var html = BuildInadExcelHtml(list, filterInfo);
                    return File(System.Text.Encoding.UTF8.GetBytes(html), "application/vnd.ms-excel; charset=utf-8", "inad-kayitlari.xls");
                }

                if (string.Equals(export, "pdf", StringComparison.OrdinalIgnoreCase))
                {
                    var pdfBytes = BuildInadPdfContent(list, filterInfo);
                    return File(pdfBytes, "application/pdf", "inad-kayitlari.pdf");
                }
            }

            ViewBag.Countries = InadHelpers.Ulkeler;
            ViewBag.PasaportTurleri = InadHelpers.PasaportTurleri;
            ViewBag.BeyanTurleri = InadHelpers.BeyanTurleri;
            ViewBag.YolcuDurumlari = InadHelpers.YolcuDurumlari;
            ViewBag.MyBorder = (user.fldBorder ?? "").Trim();
            ViewBag.IsAdmin = string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase);
            SetIndexFilterViewBag(allData, q, border, userCode, from, to, list.Count, !hasFilter);

            return View(list);
        }

        [HttpGet]
        public JsonResult GetCountries()
        {
            try
            {
                var countries = InadHelpers.Ulkeler;
                return JsonUtf8(new { success = true, countries = countries }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return JsonUtf8(new { success = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public ActionResult ScanPassportImage()
        {
            var user = GetCurrentUser();
            if (user == null)
                return JsonUtf8(new { success = false, message = "Lütfen sisteme giriş yapın." });

            if (Request.Files.Count == 0 || Request.Files[0] == null || Request.Files[0].ContentLength == 0)
                return JsonUtf8(new { success = false, message = "Lütfen bir pasaport görseli seçin." });

            var file = Request.Files[0];
            var ext = System.IO.Path.GetExtension(file.FileName ?? "").ToLowerInvariant();
            var allowedExts = new[] { ".jpg", ".jpeg", ".png", ".bmp", ".webp", ".jfif" };
            if (!allowedExts.Contains(ext))
                return JsonUtf8(new { success = false, message = "Desteklenmeyen dosya formatı. Lütfen JPG veya PNG yükleyin." });

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
                    return JsonUtf8(new { success = false, message = "OCR betiği bulunamadı." });
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
                        return JsonUtf8(new { success = false, message = "OCR çıktısı alınamadı." });
                    }

                    var jsonStartIndex = output.IndexOf('{');
                    var jsonEndIndex = output.LastIndexOf('}');
                    if (jsonStartIndex >= 0 && jsonEndIndex > jsonStartIndex)
                    {
                        var cleanJson = output.Substring(jsonStartIndex, jsonEndIndex - jsonStartIndex + 1);
                        return Content(cleanJson, "application/json", System.Text.Encoding.UTF8);
                    }

                    return JsonUtf8(new { success = false, message = "OCR çıktısı ayrıştırılamadı." });
                }
            }
            catch (Exception ex)
            {
                return JsonUtf8(new { success = false, message = "Hata: " + ex.Message });
            }
            finally
            {
                try { if (System.IO.File.Exists(tempFile)) System.IO.File.Delete(tempFile); } catch { }
            }
        }

        [HttpGet]
        public JsonResult GetInad(int id)
        {
            var user = GetCurrentUser();
            if (user == null)
                return JsonUtf8(new { success = false, message = "Giriş yapın." }, JsonRequestBehavior.AllowGet);

            var entity = db.E_Inad.AsNoTracking().FirstOrDefault(x => x.InadId == id);
            if (entity == null)
                return JsonUtf8(new { success = false, message = "Kayıt bulunamadı." }, JsonRequestBehavior.AllowGet);

            if (!HasAccessToRecord(entity, user))
                return JsonUtf8(new { success = false, message = "Yetkisiz." }, JsonRequestBehavior.AllowGet);

            var item = db.E_Inad
                .AsNoTracking()
                .Where(x => x.InadId == id)
                .Select(x => new
                {
                    x.InadId,
                    x.TarihSaat,
                    x.AdSoyad,
                    x.DogumT,
                    x.DogumY,
                    x.Cinsiyet,
                    x.Uyruk,
                    x.PasaportNo,
                    x.BelgeNo,
                    x.KimlikNo,
                    x.PasaportTuru,
                    x.Beyan,
                    x.InadSebep,

                    x.GelenUcusNo,
                    x.GelenHavayolu,
                    x.GeldigiYer,
                    x.GeldigiTarihSaat,
                    x.GidisUcusNo,
                    x.GidenHavayolu,
                    x.GidisYer,
                    x.GidisTarihSaat,
                    x.UstAramaEsya,
                    x.Personel,
                    x.Sicil,
                    x.Kapi,
                    x.Valilik,
                    x.Durum,
                    x.OzelGuvenlik,
                    x.YerHizmetleriPersonel,
                    x.YerHizmetleri,
                    x.Refakat,
                    x.UcagaNakil
                })
                .FirstOrDefault();

            return JsonUtf8(new { success = true, data = item }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult GetMyBorder()
        {
            var user = GetCurrentUser();
            if (user == null)
                return JsonUtf8(new { success = false }, JsonRequestBehavior.AllowGet);

            return JsonUtf8(new
            {
                success = true,
                border = (user.fldBorder ?? "").Trim(),
                sicil = (user.fldSicil ?? "").Trim()
            }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult GetByIataCode(string iata)
        {
            if (string.IsNullOrWhiteSpace(iata))
                return JsonUtf8(new { success = false }, JsonRequestBehavior.AllowGet);

            iata = iata.Trim().ToUpper();

            var airline = db.Airline
                .AsNoTracking()
                .FirstOrDefault(x =>
                    x.IATACode == iata &&
                    x.IsActive == true
                );

            if (airline == null)
                return JsonUtf8(new { success = false }, JsonRequestBehavior.AllowGet);

            return JsonUtf8(new
            {
                success = true,
                name = airline.Name,
                country = airline.Country
            }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult AddUserDefinedAirline(string flightNo, string airlineName)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null)
                    return JsonUtf8(new { success = false, message = "Giriş yapın." });

                flightNo = (flightNo ?? "").Trim().ToUpperInvariant();
                airlineName = (airlineName ?? "").Trim();

                if (string.IsNullOrWhiteSpace(flightNo) || flightNo.Length < 2)
                    return JsonUtf8(new { success = false, message = "Geçersiz uçuş numarası." });

                if (string.IsNullOrWhiteSpace(airlineName))
                    return JsonUtf8(new { success = false, message = "Havayolu adı boş olamaz." });

                var iata = flightNo.Substring(0, 2).ToUpperInvariant();

                if (db.Airline.Any(x => x.IATACode == iata && x.IsActive))
                    return JsonUtf8(new { success = true, message = "Havayolu zaten kayıtlı." });

                db.Airline.Add(new Airline
                {
                    IATACode = iata,
                    Name = airlineName,
                    Country = "UserDefined",
                    IsActive = true,
                    IsUserDefined = true,
                    CreatedDate = DateTime.Now
                });

                db.SaveChanges();

                return JsonUtf8(new { success = true, message = "Havayolu eklendi." });
            }
            catch (Exception ex)
            {
                return JsonUtf8(new { success = false, message = "Hata: " + ex.Message });
            }
        }

        private void EnsureAirlineExists(string airlineName, string flightNo)
        {
            if (string.IsNullOrWhiteSpace(airlineName)) return;
            if (string.IsNullOrWhiteSpace(flightNo) || flightNo.Length < 2) return;

            var code = flightNo.Substring(0, 2).ToUpper();

            if (db.Airline.Any(x => x.IATACode == code && x.IsActive)) return;

            try
            {
                db.Airline.Add(new Airline
                {
                    IATACode = code,
                    Name = airlineName.Trim(),
                    Country = "UserDefined",
                    IsActive = true,
                    IsUserDefined = true,
                    CreatedDate = DateTime.Now
                });

                db.SaveChanges();
            }
            catch
            {
                // Hata durumunda sessizce devam et
            }
        }

        [HttpGet]
        public JsonResult GetEuropeanAirlines()
        {
            try
            {
                var europeCountries = new[]
                {
                    "Türkiye",
                    "Germany", "France", "Netherlands", "Belgium", "Austria", "Switzerland",
                    "Luxembourg", "United Kingdom", "Ireland",
                    "Italy", "Spain", "Portugal", "Greece", "Malta", "Cyprus",
                    "Denmark", "Norway", "Sweden", "Finland", "Iceland",
                    "Poland", "Czech Republic", "Slovakia", "Hungary", "Slovenia", "Liechtenstein",
                    "Romania", "Bulgaria", "Croatia", "Serbia", "Bosnia and Herzegovina",
                    "Montenegro", "North Macedonia", "Albania", "Kosovo",
                    "Estonia", "Latvia", "Lithuania",
                    "Georgia", "Armenia", "Azerbaijan",
                    "Monaco", "San Marino", "Andorra", "Vatican City",
                    "Russia", "Russian Federation"
                };

                var list = db.Airline
                    .AsNoTracking()
                    .Where(x =>
                        x.IsActive == true &&
                        europeCountries.Contains(x.Country)
                    )
                    .OrderBy(x => x.Name)
                    .Select(x => new
                    {
                        x.IATACode,
                        x.Name,
                        x.Country
                    })
                    .ToList();

                return JsonUtf8(list, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return JsonUtf8(new { error = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult AddInad(E_Inad model)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null)
                    return RedirectToAction("Index", "Giris");

                if (string.IsNullOrWhiteSpace(model.AdSoyad) ||
                    string.IsNullOrWhiteSpace(model.Uyruk) ||
                    string.IsNullOrWhiteSpace(model.PasaportNo))
                {
                    TempData["msgError"] = "Zorunlu alanları doldurun (Ad Soyad, Uyruk, Pasaport No).";
                    return RedirectToAction("Index");
                }

                if (!string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase))
                {
                    model.Sicil = (user.fldSicil ?? "").Trim();
                    model.Kapi = (user.fldBorder ?? "").Trim();
                }

                model.Personel = (user.fldSicil ?? "").Trim();
                model.TarihSaat = ReadDateTimeField("TarihSaat", model.TarihSaat ?? DateTime.Now);
                model.GeldigiTarihSaat = ReadDateTimeField("GeldigiTarihSaat", model.GeldigiTarihSaat);
                model.GidisTarihSaat = ReadDateTimeField("GidisTarihSaat", model.GidisTarihSaat);

                var inadSecimler = Request.Form.GetValues("InadSebep");
                if (inadSecimler == null || !inadSecimler.Any(x => !string.IsNullOrWhiteSpace(x)))
                {
                    TempData["msgError"] = "En az bir INAD sebebi secin.";
                    return RedirectToAction("Index");
                }

                model.InadSebep = (inadSecimler != null && inadSecimler.Any())
                    ? string.Join(",", inadSecimler.Select(x => x.Trim()))
                    : null;

                var nakilSecimler = Request.Form.GetValues("UcagaNakil");
                model.UcagaNakil = (nakilSecimler != null && nakilSecimler.Any())
                    ? string.Join(",", nakilSecimler.Select(x => x.Trim()))
                    : null;

                if (!string.IsNullOrWhiteSpace(model.GelenHavayolu) && !string.IsNullOrWhiteSpace(model.GelenUcusNo))
                    EnsureAirlineExists(model.GelenHavayolu, model.GelenUcusNo);

                if (!string.IsNullOrWhiteSpace(model.GidenHavayolu) && !string.IsNullOrWhiteSpace(model.GidisUcusNo))
                    EnsureAirlineExists(model.GidenHavayolu, model.GidisUcusNo);

                db.E_Inad.Add(model);
                db.SaveChanges();

                TempData["msgSuccess"] = "Kayıt başarıyla eklendi.";
            }
            catch (DbEntityValidationException dbEx)
            {
                var errors = dbEx.EntityValidationErrors
                    .SelectMany(e => e.ValidationErrors)
                    .Select(v => $"{v.PropertyName}: {v.ErrorMessage}");

                TempData["msgError"] = "Veritabanı doğrulama hatası: " + string.Join(" | ", errors);
            }
            catch (Exception ex)
            {
                TempData["msgError"] = "Hata: " + ex.Message;
            }

            return RedirectToAction("Index");
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult EditInad(E_Inad model)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null)
                    return RedirectToAction("Index", "Giris");

                var existing = db.E_Inad.Find(model.InadId);
                if (existing == null || !HasAccessToRecord(existing, user))
                {
                    TempData["msgError"] = "Yetkisiz işlem veya kayıt bulunamadı.";
                    return RedirectToAction("Index");
                }

                existing.AdSoyad = model.AdSoyad;
                existing.TarihSaat = ReadDateTimeField("TarihSaat", model.TarihSaat);
                existing.DogumT = model.DogumT;
                existing.DogumY = model.DogumY;
                existing.Cinsiyet = model.Cinsiyet;
                existing.Uyruk = model.Uyruk;

                existing.PasaportNo = model.PasaportNo;
                existing.BelgeNo = model.BelgeNo;
                existing.KimlikNo = model.KimlikNo;
                existing.PasaportTuru = model.PasaportTuru;
                existing.Beyan = model.Beyan;

                existing.GelenUcusNo = model.GelenUcusNo;
                existing.GelenHavayolu = model.GelenHavayolu;
                existing.GeldigiYer = model.GeldigiYer;
                existing.GeldigiTarihSaat = ReadDateTimeField("GeldigiTarihSaat", model.GeldigiTarihSaat);

                existing.GidisUcusNo = model.GidisUcusNo;
                existing.GidenHavayolu = model.GidenHavayolu;
                existing.GidisYer = model.GidisYer;
                existing.GidisTarihSaat = ReadDateTimeField("GidisTarihSaat", model.GidisTarihSaat);

                existing.UstAramaEsya = model.UstAramaEsya;


                existing.Kapi = string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase)
                    ? model.Kapi
                    : (user.fldBorder ?? "").Trim();
                existing.Valilik = model.Valilik;
                existing.Durum = model.Durum;
                existing.OzelGuvenlik = model.OzelGuvenlik;
                existing.YerHizmetleriPersonel = model.YerHizmetleriPersonel;
                existing.YerHizmetleri = model.YerHizmetleri;
                existing.Refakat = model.Refakat;

                var inadSecimler = Request.Form.GetValues("InadSebep");
                if (inadSecimler == null || !inadSecimler.Any(x => !string.IsNullOrWhiteSpace(x)))
                {
                    TempData["msgError"] = "En az bir INAD sebebi secin.";
                    return RedirectToAction("Index");
                }

                existing.InadSebep = (inadSecimler != null && inadSecimler.Any())
                    ? string.Join(",", inadSecimler.Select(x => x.Trim()))
                    : null;

                var nakilSecimler = Request.Form.GetValues("UcagaNakil");
                existing.UcagaNakil = (nakilSecimler != null && nakilSecimler.Any())
                    ? string.Join(",", nakilSecimler.Select(x => x.Trim()))
                    : null;

                if (!string.IsNullOrWhiteSpace(model.GelenHavayolu) && !string.IsNullOrWhiteSpace(model.GelenUcusNo))
                    EnsureAirlineExists(model.GelenHavayolu, model.GelenUcusNo);

                if (!string.IsNullOrWhiteSpace(model.GidenHavayolu) && !string.IsNullOrWhiteSpace(model.GidisUcusNo))
                    EnsureAirlineExists(model.GidenHavayolu, model.GidisUcusNo);

                db.SaveChanges();
                TempData["msgSuccess"] = "Kayıt başarıyla güncellendi.";
            }
            catch (DbEntityValidationException dbEx)
            {
                var errors = dbEx.EntityValidationErrors
                    .SelectMany(e => e.ValidationErrors)
                    .Select(v => $"{v.PropertyName}: {v.ErrorMessage}");

                TempData["msgError"] = "Veritabanı doğrulama hatası: " + string.Join(" | ", errors);
            }
            catch (Exception ex)
            {
                TempData["msgError"] = "Hata: " + ex.Message;
            }

            return RedirectToAction("Index");
        }

        [HttpGet]
        public ActionResult Print(int id)
        {
            var user = GetCurrentUser();
            if (user == null)
                return RedirectToAction("Index", "Giris");

            var item = db.E_Inad.AsNoTracking().FirstOrDefault(x => x.InadId == id);
            if (item == null)
                return HttpNotFound();

            if (!HasAccessToRecord(item, user))
                return new HttpStatusCodeResult(403);

            return View(item);
        }

        [HttpGet]
        public ActionResult PrintForm1(int id, string lang = null)
        {
            var user = GetCurrentUser();
            if (user == null)
                return RedirectToAction("Index", "Giris");

            var item = db.E_Inad.Find(id);
            if (item == null)
                return HttpNotFound();

            if (!HasAccessToRecord(item, user))
                return new HttpStatusCodeResult(403);

            // Tebliğ eden (giriş yapan) kullanıcının adı soyadı ViewBag'e ekleniyor
            var notifyName = string.Join(" ", new[] { (user.fldName ?? "").Trim(), (user.fldLastName ?? "").Trim() }.Where(s => !string.IsNullOrEmpty(s))).Trim();
            ViewBag.NotifyName = string.IsNullOrEmpty(notifyName) ? (user.fldSicil ?? "").Trim() : notifyName;

            // İşlem yapılan kişinin adı soyadı
            ViewBag.NotifiedName = (item.AdSoyad ?? "").Trim();

            // Dil seçimi: Eğer parametre verildiyse onu kullan, yoksa ülkeye göre belirle
            var dil = !string.IsNullOrWhiteSpace(lang)
                ? lang.Trim()
                : InadHelpers.GetFormLanguageByCountry(item.Uyruk ?? "");

            var viewPath = InadHelpers.GetFormViewPath(dil, 1);

            // View dosyasının varlığını kontrol et, yoksa varsayılan Form1'i kullan
            try
            {
                return View(viewPath, item);
            }
            catch
            {
                // View bulunamazsa varsayılan Form1'i kullan
                return View("PrintTemplates/Form1", item);
            }
        }

        [HttpGet]
        public ActionResult PrintForm2(int id, string lang = null)
        {
            var user = GetCurrentUser();
            if (user == null)
                return RedirectToAction("Index", "Giris");

            var item = db.E_Inad.Find(id);
            if (item == null)
                return HttpNotFound();

            if (!HasAccessToRecord(item, user))
                return new HttpStatusCodeResult(403);

            // Tebliğ eden (giriş yapan) kullanıcının adı soyadı ViewBag'e ekleniyor
            var notifyName = string.Join(" ", new[] { (user.fldName ?? "").Trim(), (user.fldLastName ?? "").Trim() }
                .Where(s => !string.IsNullOrEmpty(s))).Trim();
            ViewBag.NotifyName = string.IsNullOrEmpty(notifyName) ? (user.fldSicil ?? "").Trim() : notifyName;

            // İşlem yapılan kişinin adı soyadı
            ViewBag.NotifiedName = (item.AdSoyad ?? "").Trim();

            // Dil seçimi: Eğer parametre verildiyse onu kullan, yoksa ülkeye göre belirle (varsayılan İngilizce)
            var dil = !string.IsNullOrWhiteSpace(lang)
                ? lang.Trim()
                : InadHelpers.GetFormLanguageByCountry(item.Uyruk ?? "");

            var viewPath = InadHelpers.GetFormViewPath(dil, 2);

            try
            {
                return View(viewPath, item);
            }
            catch
            {
                return View("PrintTemplates/Form2_Ingilizce", item);
            }
        }

        [HttpGet]
        public ActionResult PrintForm3(int id) => PrintFormBase(id, "PrintTemplates/Form3");

        [HttpGet]
        public ActionResult PrintForm4(int id) => PrintFormBase(id, "PrintTemplates/Form4");

        [HttpGet]
        public ActionResult PrintForm5(int id) => PrintFormBase(id, "PrintTemplates/Form5");

        [HttpGet]
        public ActionResult PrintForm6(int id, string lang = null)
        {
            var user = GetCurrentUser();
            if (user == null)
                return RedirectToAction("Index", "Giris");

            var item = db.E_Inad.Find(id);
            if (item == null)
                return HttpNotFound();

            if (!HasAccessToRecord(item, user))
                return new HttpStatusCodeResult(403);

            var dil = !string.IsNullOrWhiteSpace(lang)
                ? lang.Trim()
                : InadHelpers.GetFormLanguageByCountry(item.Uyruk ?? "");

            var viewPath = InadHelpers.GetFormViewPath(dil, 6);

            try
            {
                return View(viewPath, item);
            }
            catch
            {
                return View("PrintTemplates/Form6", item);
            }
        }

        private ActionResult PrintFormBase(int id, string viewName)
        {
            var user = GetCurrentUser();
            if (user == null)
                return RedirectToAction("Index", "Giris");

            var item = db.E_Inad.Find(id);
            if (item == null)
                return HttpNotFound();

            if (!HasAccessToRecord(item, user))
                return new HttpStatusCodeResult(403);

            return View(viewName, item);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult UpdateStatus(int id, string status)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null)
                    return JsonUtf8(new { success = false, message = "Giriş yapın." });

                var item = db.E_Inad.Find(id);
                if (item == null)
                    return JsonUtf8(new { success = false, message = "Kayıt bulunamadı." });

                if (!HasAccessToRecord(item, user))
                    return JsonUtf8(new { success = false, message = "Yetkisiz işlem." });

                // Durumu güncelle
                if (status == "İnad Edildi" || status == "İnad Odasına Alındı")
                {
                    item.Durum = status;
                    db.SaveChanges();

                    // Eğer "İnad Odasına Alındı" ise, kullanıcıyı kayıt et (takip için)
                    if (status == "İnad Odasına Alındı")
                    {
                        // Opsiyonel: TakipLog tablosu varsa buraya ekle
                        // Bu sayede kullanıcı "kimler neleri unuttuğunun" takibini yapabilir
                    }

                    return JsonUtf8(new { success = true, message = "Durum güncellendi.", data = new { status = item.Durum } });
                }
                else
                {
                    return JsonUtf8(new { success = false, message = "Geçersiz durum." });
                }
            }
            catch (Exception ex)
            {
                return JsonUtf8(new { success = false, message = "Hata: " + ex.Message });
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult DeleteInad(int id)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null)
                    return JsonUtf8(new { success = false, message = "Giriş yapın." });

                var item = db.E_Inad.Find(id);
                if (item == null)
                    return JsonUtf8(new { success = false, message = "Kayıt bulunamadı." });

                if (!HasAccessToRecord(item, user))
                    return JsonUtf8(new { success = false, message = "Yetkisiz işlem." });

                db.E_Inad.Remove(item);
                db.SaveChanges();

                return JsonUtf8(new { success = true, message = "Kayıt silindi." });
            }
            catch (Exception ex)
            {
                return JsonUtf8(new { success = false, message = "Hata: " + ex.Message });
            }
        }

        [HttpPost]
        [AllowAnonymous]
        public JsonResult Connect3MReader()
        {
            return ConnectOpticalReader();
        }

        [HttpPost]
        [AllowAnonymous]
        public JsonResult ConnectOpticalReader()
        {
            try
            {
                // 1. 3M Cogent / Gemalto SDK Yolları
                string[] mmmPaths = new string[]
                {
                    @"C:\Program Files (x86)\Thales\Gemalto Document Reader SDK\3.7.1.18\Bin\OutputWedgeSysTray.exe",
                    @"C:\Program Files\Thales\Gemalto Document Reader SDK\3.7.1.18\Bin\OutputWedgeSysTray.exe",
                    @"C:\Program Files (x86)\3M\3M Page Reader\OutputWedgeSysTray.exe"
                };

                // 2. Regula Document Reader Yolları
                string[] regulaPaths = new string[]
                {
                    @"C:\Program Files\Regula\Document Reader SDK\Bin\DocReader.exe",
                    @"C:\Program Files (x86)\Regula\Document Reader SDK\Bin\DocReader.exe",
                    @"C:\Program Files\Regula\Reader\DocReader.exe",
                    @"C:\Program Files (x86)\Regula\Reader\DocReader.exe",
                    @"C:\Program Files\Regula\Document Reader SDK\Bin\Regula Reader.exe",
                    @"C:\Program Files (x86)\Regula\Document Reader SDK\Bin\Regula Reader.exe"
                };

                bool is3MRunning = System.Diagnostics.Process.GetProcessesByName("OutputWedgeSysTray").Length > 0;
                bool isRegulaRunning = System.Diagnostics.Process.GetProcessesByName("DocReader").Length > 0
                                    || System.Diagnostics.Process.GetProcessesByName("Regula Reader").Length > 0
                                    || System.Diagnostics.Process.GetProcessesByName("RegulaReaderService").Length > 0;

                string deviceName = "";
                bool started = false;

                if (is3MRunning)
                {
                    deviceName = "3M Cogent / Gemalto (PV40/PV60)";
                }
                else if (isRegulaRunning)
                {
                    deviceName = "Regula Document Reader";
                }
                else
                {
                    // 3M Başlatmayı Dene
                    foreach (var p in mmmPaths)
                    {
                        if (System.IO.File.Exists(p))
                        {
                            var psi = new System.Diagnostics.ProcessStartInfo
                            {
                                FileName = p,
                                WorkingDirectory = System.IO.Path.GetDirectoryName(p),
                                UseShellExecute = true
                            };
                            System.Diagnostics.Process.Start(psi);
                            deviceName = "3M Cogent / Gemalto (PV40/PV60)";
                            started = true;
                            break;
                        }
                    }

                    // Regula Başlatmayı Dene
                    if (!started)
                    {
                        foreach (var rp in regulaPaths)
                        {
                            if (System.IO.File.Exists(rp))
                            {
                                var psi = new System.Diagnostics.ProcessStartInfo
                                {
                                    FileName = rp,
                                    WorkingDirectory = System.IO.Path.GetDirectoryName(rp),
                                    UseShellExecute = true
                                };
                                System.Diagnostics.Process.Start(psi);
                                deviceName = "Regula Document Reader";
                                started = true;
                                break;
                            }
                        }
                    }

                    if (started)
                    {
                        System.Threading.Thread.Sleep(900);
                    }
                }

                bool isAnyRunning = System.Diagnostics.Process.GetProcessesByName("OutputWedgeSysTray").Length > 0
                                 || System.Diagnostics.Process.GetProcessesByName("DocReader").Length > 0
                                 || System.Diagnostics.Process.GetProcessesByName("Regula Reader").Length > 0;

                string activeName = !string.IsNullOrEmpty(deviceName) ? deviceName : (isAnyRunning ? "Optik Okuyucu" : "3M / Regula");

                return JsonUtf8(new
                {
                    success = true,
                    isRunning = isAnyRunning,
                    deviceName = activeName,
                    message = isAnyRunning
                        ? activeName + " servisine başarıyla bağlanıldı ve aktif. Pasaport veya kimliği okuyucuya koyabilirsiniz."
                        : "Okuyucu servisi başlatılamadı. Cihazın USB bağlantısını ve sürücüsünü kontrol ediniz."
                });
            }
            catch (Exception ex)
            {
                return JsonUtf8(new { success = false, message = "Cihaza bağlanırken hata: " + ex.Message });
            }
        }

        [HttpGet]
        [AllowAnonymous]
        public JsonResult Get3MReaderStatus()
        {
            return GetOpticalReaderStatus();
        }

        [HttpGet]
        [AllowAnonymous]
        public JsonResult GetOpticalReaderStatus()
        {
            try
            {
                bool is3MRunning = System.Diagnostics.Process.GetProcessesByName("OutputWedgeSysTray").Length > 0;
                bool isRegulaRunning = System.Diagnostics.Process.GetProcessesByName("DocReader").Length > 0
                                    || System.Diagnostics.Process.GetProcessesByName("Regula Reader").Length > 0
                                    || System.Diagnostics.Process.GetProcessesByName("RegulaReaderService").Length > 0;

                bool isRunning = is3MRunning || isRegulaRunning;
                string deviceName = is3MRunning ? "3M PV40/PV60" : (isRegulaRunning ? "Regula" : "Optik Okuyucu");

                return JsonUtf8(new
                {
                    success = true,
                    isRunning = isRunning,
                    deviceName = deviceName,
                    statusText = isRunning ? (deviceName + " Bağlı & Aktif") : "Bağlantı Bekleniyor"
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return JsonUtf8(new { success = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
                db?.Dispose();

            base.Dispose(disposing);
        }
    }
}
