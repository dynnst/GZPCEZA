using gzpegm.Cont;
using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Data.Entity.SqlServer;

namespace gzpegm.Controllers
{
    [UserAuthorize(Users = "2,4")]
    public class IskController : Controller
    {
        // Yardımcı sınıf: istatistik verilerini tutar
        private class IskStats
        {
            public string KesilenToplamCeza { get; set; }
            public string Toplam { get; set; }
            public string EnCokIslemYapanPersonel { get; set; }
            public string EnCokIslemYapanAdi { get; set; }
            public string EnFazlaCezaMiktari { get; set; }
            public string BugunIslem { get; set; }
            public string OrtalamaCeza { get; set; }
            public string EnCokUyruk { get; set; }
            public string EnCokUyrukSayi { get; set; }
            public string EnCokVize { get; set; }
            public string EnCokVizeSayi { get; set; }
        }

        // Tahdit istatistiklerini ViewBag'e ekler
        private static void SetTahditStats(dynamic viewBag, DateTime? startTime, DateTime? endTime)
        {
            try
            {
                viewBag.TahditStats = new TahditFormLogService().GetStatistics(startTime, endTime, null, null, null);
            }
            catch
            {
                viewBag.TahditStats = new gzpegm.Models.ViewModels.TahditStatisticsViewModel();
            }
        }

        // Tarih aralığını ve filtre metnini çözer
        private static void ResolveDateRange(int? hours, DateTime? from, DateTime? to, int? year,
            out DateTime? startTime, out DateTime? endTime, out int selectedYear, out string filterText)
        {
            startTime = null;
            endTime = null;
            selectedYear = year.HasValue ? year.Value : 0;

            if (from.HasValue && to.HasValue)
            {
                startTime = from.Value.Date;
                endTime = to.Value.Date.AddDays(1).AddTicks(-1);
                filterText = $"{startTime:dd.MM.yyyy} - {to.Value:dd.MM.yyyy} tarih aralığı";
                return;
            }

            if (hours.HasValue && hours.Value > 0)
            {
                endTime = DateTime.Now;
                startTime = DateTime.Now.AddHours(-hours.Value);
                filterText = $"Son {hours.Value} saat";
                return;
            }

            if (selectedYear > 0)
            {
                startTime = new DateTime(selectedYear, 1, 1);
                endTime = new DateTime(selectedYear, 12, 31, 23, 59, 59, 997);
                filterText = $"{selectedYear} yılı";
                return;
            }

            filterText = "Tüm kayıtlar";
        }

        // Sorguya filtreleri uygular
        private static IQueryable<E_IsK> ApplyFilters(IQueryable<E_IsK> query, DateTime? startTime, DateTime? endTime,
            string q, string border = null, string user = null)
        {
            if (startTime.HasValue && endTime.HasValue)
            {
                DateTime s = startTime.Value;
                DateTime e = endTime.Value;
                query = query.Where(x => x.fldDatetime.HasValue && x.fldDatetime >= s && x.fldDatetime <= e);
            }
            if (!string.IsNullOrWhiteSpace(q))
            {
                string search = "%" + q.Trim() + "%";
                query = query.Where(x => x.fldName != null && SqlFunctions.PatIndex(search, x.fldName) > 0);
            }
            if (!string.IsNullOrWhiteSpace(border))
            {
                string borderValue = "%" + border.Trim() + "%";
                query = query.Where(x => x.fldBorder != null && SqlFunctions.PatIndex(borderValue, x.fldBorder) > 0);
            }
            if (!string.IsNullOrWhiteSpace(user))
            {
                string userValue = "%" + user.Trim() + "%";
                query = query.Where(x => x.fldApproval != null && SqlFunctions.PatIndex(userValue, x.fldApproval) > 0);
            }
            return query;
        }

        // Para değerini çözümler
        private static decimal ParseMoney(string money)
        {
            if (string.IsNullOrEmpty(money)) return 0;
            if (decimal.TryParse(money, NumberStyles.Any, new CultureInfo("tr-TR"), out decimal val))
                return decimal.Truncate(val);
            if (decimal.TryParse(money, NumberStyles.Any, CultureInfo.InvariantCulture, out val))
                return decimal.Truncate(val);

            var normalized = NormalizeMoneyString(money);
            if (decimal.TryParse(normalized, NumberStyles.Any, CultureInfo.InvariantCulture, out val))
                return decimal.Truncate(val);

            return 0;
        }

        private static IQueryable<ISKmodel> ProjectToIskModel(IQueryable<E_IsK> query)
        {
            return query.Select(c => new ISKmodel
            {
                Id = c.fldId,
                Tarih = c.fldDatetime,
                Name = c.fldName,
                Pasaport = c.fldPassport,
                Kimlik = c.fldIdn,
                Uyruk = c.fldOrgin,
                Birth = c.fldBirthdate,
                Kontrolm = c.fldPassControl,
                Onay = c.fldApproval,
                Money = c.fldPMoney,
                Vize = c.fldVisa,
                Kapi = c.fldBorder,
                Resim = c.fldPicture
            });
        }

        // Model listesinden istatistikleri hesaplar
        private static IskStats BuildStats(List<ISKmodel> modelData)
        {
            decimal toplam = 0;
            decimal enFazlaMiktar = 0;
            int tutarliKayit = 0;

            foreach (var item in modelData)
            {
                decimal val = ParseMoney(item.Money);
                if (val > 0)
                {
                    toplam += val;
                    tutarliKayit++;
                    if (val > enFazlaMiktar)
                        enFazlaMiktar = val;
                }
            }

            var enCokPersonel = modelData
                .Where(x => !string.IsNullOrEmpty(x.Onay))
                .GroupBy(x => x.Onay)
                .OrderByDescending(g => g.Count())
                .Select(g => new { Adi = g.Key, Sayi = g.Count() })
                .FirstOrDefault();

            var enCokUyruk = modelData
                .Where(x => !string.IsNullOrEmpty(x.Uyruk))
                .GroupBy(x => x.Uyruk)
                .OrderByDescending(g => g.Count())
                .Select(g => new { Deger = g.Key, Sayi = g.Count() })
                .FirstOrDefault();

            var enCokVize = modelData
                .Where(x => !string.IsNullOrEmpty(x.Vize))
                .GroupBy(x => x.Vize)
                .OrderByDescending(g => g.Count())
                .Select(g => new { Deger = g.Key, Sayi = g.Count() })
                .FirstOrDefault();

            return new IskStats
            {
                KesilenToplamCeza = modelData.Count.ToString(),
                Toplam = toplam.ToString("#,0", new CultureInfo("tr-TR")),
                EnCokIslemYapanPersonel = enCokPersonel?.Sayi.ToString() ?? "0",
                EnCokIslemYapanAdi = enCokPersonel?.Adi ?? "-",
                EnFazlaCezaMiktari = enFazlaMiktar.ToString("#,0", new CultureInfo("tr-TR")),
                BugunIslem = modelData.Count(x => x.Tarih.HasValue && x.Tarih.Value.Date == DateTime.Today).ToString(),
                OrtalamaCeza = tutarliKayit > 0 ? decimal.Truncate(toplam / tutarliKayit).ToString("#,0", new CultureInfo("tr-TR")) : "0",
                EnCokUyruk = enCokUyruk?.Deger ?? "-",
                EnCokUyrukSayi = enCokUyruk?.Sayi.ToString() ?? "0",
                EnCokVize = enCokVize?.Deger ?? "-",
                EnCokVizeSayi = enCokVize?.Sayi.ToString() ?? "0"
            };
        }

        private static byte[] BuildPdfContent(List<E_IsK> list, string filterText)
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

                document.Add(new iTextSharp.text.Paragraph("Ceza Kesilen Yolcu Listesi", titleFont));
                document.Add(new iTextSharp.text.Paragraph("Oluşturma Tarihi: " + DateTime.Now.ToString("dd.MM.yyyy HH:mm"), infoFont));
                if (!string.IsNullOrWhiteSpace(filterText))
                {
                    document.Add(new iTextSharp.text.Paragraph("Filtre: " + filterText, infoFont));
                }
                document.Add(new iTextSharp.text.Paragraph(" "));

                var table = new iTextSharp.text.pdf.PdfPTable(11)
                {
                    WidthPercentage = 100
                };
                table.SetWidths(new float[] { 6f, 12f, 14f, 12f, 14f, 10f, 9f, 10f, 12f, 10f, 9f });

                foreach (var header in new[]
                {
                    "Id", "İşlem Tarihi", "Ad Soyad", "Onaylayan", "Kapı", "Pasaport", "Kimlik", "Uyruk", "Vize", "Doğum Tarihi", "Para (TL)"
                })
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
                    AddPdfCell(table, item.fldId.ToString(), cellFont, true);
                    AddPdfCell(table, item.fldDatetime?.ToString("dd.MM.yyyy HH:mm") ?? string.Empty, cellFont);
                    AddPdfCell(table, item.fldName ?? string.Empty, cellFont);
                    AddPdfCell(table, item.fldApproval ?? string.Empty, cellFont);
                    AddPdfCell(table, item.fldBorder ?? string.Empty, cellFont);
                    AddPdfCell(table, item.fldPassport ?? string.Empty, cellFont);
                    AddPdfCell(table, item.fldIdn ?? string.Empty, cellFont);
                    AddPdfCell(table, item.fldOrgin ?? string.Empty, cellFont);
                    AddPdfCell(table, item.fldVisa ?? string.Empty, cellFont);
                    AddPdfCell(table, item.fldBirthdate?.ToString("dd.MM.yyyy") ?? string.Empty, cellFont);
                    AddPdfCell(table, FormatMoney(item.fldPMoney), cellFont, false, true);
                }

                document.Add(table);
                document.Close();
                return stream.ToArray();
            }
        }

        private static string BuildExcelHtml(List<E_IsK> list, string filterText)
        {
            var sb = new System.Text.StringBuilder();
            sb.AppendLine("<html>");
            sb.AppendLine("<head>");
            sb.AppendLine("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />");
            sb.AppendLine("<style>");
            sb.AppendLine("body { font-family: Calibri, Arial, sans-serif; font-size: 11pt; color: #1f2937; }");
            sb.AppendLine(".title { font-size: 18pt; font-weight: 700; color: #1f3b63; margin-bottom: 6px; }");
            sb.AppendLine(".subtitle { font-size: 10pt; color: #475569; margin-bottom: 10px; }");
            sb.AppendLine("table { border-collapse: collapse; width: 100%; }");
            sb.AppendLine("th { background: #1f4e78; color: #ffffff; font-weight: 700; font-size: 11pt; border: 1px solid #9fb3c8; padding: 8px; text-align: center; }");
            sb.AppendLine("td { border: 1px solid #cbd5e1; padding: 6px 8px; vertical-align: middle; }");
            sb.AppendLine(".text-center { text-align: center; }");
            sb.AppendLine(".text-right { text-align: right; }");
            sb.AppendLine(".nowrap { white-space: nowrap; }");
            sb.AppendLine("tr:nth-child(even) td { background: #f8fafc; }");
            sb.AppendLine("</style>");
            sb.AppendLine("</head>");
            sb.AppendLine("<body>");
            sb.AppendLine("<div class=\"title\">Ceza Kesilen Yolcu Listesi</div>");
            sb.AppendLine("<div class=\"subtitle\">Oluşturma Tarihi: " + HttpUtility.HtmlEncode(DateTime.Now.ToString("dd.MM.yyyy HH:mm")) + "</div>");

            if (!string.IsNullOrWhiteSpace(filterText))
            {
                sb.AppendLine("<div class=\"subtitle\">Filtre: " + HttpUtility.HtmlEncode(filterText) + "</div>");
            }

            sb.AppendLine("<table>");
            sb.AppendLine("<thead><tr>");
            sb.AppendLine("<th>Id</th>");
            sb.AppendLine("<th>İşlem Tarihi</th>");
            sb.AppendLine("<th>Ad Soyad</th>");
            sb.AppendLine("<th>Onaylayan</th>");
            sb.AppendLine("<th>Kapı</th>");
            sb.AppendLine("<th>Pasaport</th>");
            sb.AppendLine("<th>Kimlik</th>");
            sb.AppendLine("<th>Uyruk</th>");
            sb.AppendLine("<th>Vize</th>");
            sb.AppendLine("<th>Doğum Tarihi</th>");
            sb.AppendLine("<th>Para (TL)</th>");
            sb.AppendLine("<th>Resim</th>");
            sb.AppendLine("</tr></thead>");
            sb.AppendLine("<tbody>");

            foreach (var item in list)
            {
                sb.AppendLine("<tr>");
                sb.AppendLine("<td class=\"text-center\">" + HttpUtility.HtmlEncode(item.fldId.ToString()) + "</td>");
                sb.AppendLine("<td class=\"nowrap\">" + HttpUtility.HtmlEncode(item.fldDatetime?.ToString("dd.MM.yyyy HH:mm") ?? string.Empty) + "</td>");
                sb.AppendLine("<td>" + HttpUtility.HtmlEncode(item.fldName ?? string.Empty) + "</td>");
                sb.AppendLine("<td>" + HttpUtility.HtmlEncode(item.fldApproval ?? string.Empty) + "</td>");
                sb.AppendLine("<td>" + HttpUtility.HtmlEncode(item.fldBorder ?? string.Empty) + "</td>");
                sb.AppendLine("<td>" + HttpUtility.HtmlEncode(item.fldPassport ?? string.Empty) + "</td>");
                sb.AppendLine("<td>" + HttpUtility.HtmlEncode(item.fldIdn ?? string.Empty) + "</td>");
                sb.AppendLine("<td>" + HttpUtility.HtmlEncode(item.fldOrgin ?? string.Empty) + "</td>");
                sb.AppendLine("<td>" + HttpUtility.HtmlEncode(item.fldVisa ?? string.Empty) + "</td>");
                sb.AppendLine("<td class=\"nowrap\">" + HttpUtility.HtmlEncode(item.fldBirthdate?.ToString("dd.MM.yyyy") ?? string.Empty) + "</td>");
                sb.AppendLine("<td class=\"text-right\">" + HttpUtility.HtmlEncode(FormatMoney(item.fldPMoney)) + "</td>");
                sb.AppendLine("<td>" + HttpUtility.HtmlEncode(item.fldPicture ?? string.Empty) + "</td>");
                sb.AppendLine("</tr>");
            }

            sb.AppendLine("</tbody>");
            sb.AppendLine("</table>");
            sb.AppendLine("</body>");
            sb.AppendLine("</html>");

            return sb.ToString();
        }

        private static void AddPdfCell(iTextSharp.text.pdf.PdfPTable table, string value, iTextSharp.text.Font font, bool center = false, bool right = false)
        {
            var cell = new iTextSharp.text.pdf.PdfPCell(new iTextSharp.text.Phrase(value ?? string.Empty, font))
            {
                Padding = 4f
            };
            if (right)
            {
                cell.HorizontalAlignment = iTextSharp.text.Element.ALIGN_RIGHT;
            }
            else if (center)
            {
                cell.HorizontalAlignment = iTextSharp.text.Element.ALIGN_CENTER;
            }
            table.AddCell(cell);
        }

        private static string FormatMoney(string value)
        {
            var money = ParseMoney(value);
            if (money != 0 || !string.IsNullOrWhiteSpace(value))
            {
                return money.ToString("N0", new CultureInfo("tr-TR"));
            }

            return value ?? string.Empty;
        }

        private static string NormalizeMoneyString(string value)
        {
            var cleaned = System.Text.RegularExpressions.Regex.Replace(value ?? string.Empty, "[^0-9,.-]", "");
            if (string.IsNullOrWhiteSpace(cleaned))
            {
                return "0";
            }

            var lastComma = cleaned.LastIndexOf(',');
            var lastDot = cleaned.LastIndexOf('.');
            var decimalSeparatorIndex = Math.Max(lastComma, lastDot);

            if (decimalSeparatorIndex >= 0)
            {
                var integerPart = cleaned.Substring(0, decimalSeparatorIndex).Replace(",", "").Replace(".", "");
                var fractionalPart = cleaned.Substring(decimalSeparatorIndex + 1).Replace(",", "").Replace(".", "");
                return integerPart + "." + fractionalPart;
            }

            return cleaned.Replace(",", "").Replace(".", "");
        }

        private static iTextSharp.text.Font BuildUnicodeFont(float size, bool bold = false, iTextSharp.text.BaseColor color = null)
        {
            var fontPath = System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Fonts), "arial.ttf");
            var baseFont = iTextSharp.text.pdf.BaseFont.CreateFont(fontPath, iTextSharp.text.pdf.BaseFont.IDENTITY_H, iTextSharp.text.pdf.BaseFont.EMBEDDED);
            return new iTextSharp.text.Font(baseFont, size, bold ? iTextSharp.text.Font.BOLD : iTextSharp.text.Font.NORMAL, color ?? iTextSharp.text.BaseColor.BLACK);
        }

        // İstatistikleri ViewBag'e aktarır
        private void ApplyStatsToViewBag(IskStats stats)
        {
            ViewBag.KesilenToplamCeza = stats.KesilenToplamCeza;
            ViewBag.toplam = stats.Toplam;
            ViewBag.EnCokIslemYapanPersonel = stats.EnCokIslemYapanPersonel;
            ViewBag.EnCokIslemYapanAdi = stats.EnCokIslemYapanAdi;
            ViewBag.EnFazlaCezaMiktari = stats.EnFazlaCezaMiktari;
            ViewBag.BugunIslem = stats.BugunIslem;
            ViewBag.OrtalamaCeza = stats.OrtalamaCeza;
            ViewBag.EnCokUyruk = stats.EnCokUyruk;
            ViewBag.EnCokUyrukSayi = stats.EnCokUyrukSayi;
            ViewBag.EnCokVize = stats.EnCokVize;
            ViewBag.EnCokVizeSayi = stats.EnCokVizeSayi;
        }

        // ANA SAYFA (INDEX)
        [Route("Isk")]
        public ActionResult Index(int? hours, DateTime? from, DateTime? to, int? year, string q, string border, string user)
        {
            List<ISKmodel> modelData = new List<ISKmodel>();
            DateTime? startTime, endTime;
            int selectedYear;
            string filterText;

            ResolveDateRange(hours, from, to, year, out startTime, out endTime, out selectedYear, out filterText);

            try
            {
                using (var db = new GZPEGM1())
                {
                    IQueryable<E_IsK> query = db.E_IsK.AsNoTracking();
                    query = ApplyFilters(query, startTime, endTime, q, border, user);

                    var statsData = ProjectToIskModel(query).ToList();

                    // Ekranda sadece son 100 kayıt gösterilir; istatistikler tüm filtreli veri üzerinden hesaplanır.
                    modelData = ProjectToIskModel(query.OrderByDescending(x => x.fldId).Take(100)).ToList();

                    var stats = BuildStats(statsData);
                    ApplyStatsToViewBag(stats);

                    // Kapı ve kullanıcı listeleri
                    ViewBag.BorderList = db.E_IsK.AsNoTracking()
                        .Where(x => x.fldBorder != null && x.fldBorder != "")
                        .Select(x => x.fldBorder)
                        .Distinct()
                        .OrderBy(x => x)
                        .ToList();

                    ViewBag.UserList = db.E_IsK.AsNoTracking()
                        .Where(x => x.fldApproval != null && x.fldApproval != "")
                        .Select(x => x.fldApproval)
                        .Distinct()
                        .OrderBy(x => x)
                        .ToList();

                    // Tahdit istatistikleri
                    SetTahditStats(ViewBag, startTime, endTime);
                }
            }
            catch (Exception ex)
            {
                // Hata durumunda mevcut model üzerinden istatistik üretmeye çalış
                var stats = BuildStats(modelData);
                ApplyStatsToViewBag(stats);
                ViewBag.TahditStats = new gzpegm.Models.ViewModels.TahditStatisticsViewModel();
                ViewBag.LoadError = "Veriler yüklenirken hata oluştu: " + ex.Message;
            }

            // Filtre bilgilerini ViewBag'e ata
            ViewBag.SelectedHours = hours;
            ViewBag.SelectedYear = selectedYear;
            ViewBag.From = from?.Date;
            ViewBag.To = to?.Date;
            ViewBag.SearchText = q ?? "";
            ViewBag.SelectedBorder = border ?? "";
            ViewBag.SelectedUser = user ?? "";
            ViewBag.ResultInfo = $"{filterText} filtresine göre son 100 kayıt gösteriliyor. Arama tüm veritabanında yapılır.";

            return View(modelData);
        }

        // KAYIT SİLME (AJAX)
        [HttpPost]
        [Route("DeleteIsk")]
        public JsonResult DeleteRecord(int Id)
        {
            Isk Isk = new Isk();
            Isk.DeleteIsk(Id);
            return Json(new { success = true, message = "Başarılı bir şekilde silinmiştir.", url = "/Isk" }, JsonRequestBehavior.AllowGet);
        }

        // DIŞA AKTAR (PDF / EXCEL)
        [Route("IskExport")]
        public ActionResult Export(int? hours, DateTime? from, DateTime? to, int? year, string q, string border, string user, string export)
        {
            DateTime? startTime, endTime;
            int selectedYear;
            string filterText;
            ResolveDateRange(hours, from, to, year, out startTime, out endTime, out selectedYear, out filterText);

            using (var db = new GZPEGM1())
            {
                IQueryable<E_IsK> query = db.E_IsK.AsNoTracking();
                query = ApplyFilters(query, startTime, endTime, q, border, user);

                var list = query.OrderByDescending(x => x.fldDatetime).ToList();

                if (!string.IsNullOrEmpty(export) && (export.ToLower() == "pdf" || export.ToLower() == "excel"))
                {
                    var fileNameBase = $"Isk_{DateTime.Now:yyyyMMddHHmm}";
                    var isExcel = export.ToLower() == "excel";

                    if (isExcel)
                    {
                        var html = BuildExcelHtml(list, filterText);
                        var htmlBytes = new System.Text.UTF8Encoding(true).GetBytes(html);
                        return File(htmlBytes, "application/vnd.ms-excel; charset=utf-8", fileNameBase + ".xls");
                    }

                    var pdfBytes = BuildPdfContent(list, filterText);
                    return File(pdfBytes, "application/pdf", fileNameBase + ".pdf");
                }

                return RedirectToAction("Index", new { hours, from, to, year, q, border, user });
            }
        }

        // DATATABLES VERİ BESLEME (AJAX)
        [HttpGet]
        [Route("IskData")]
        [Route("Isk/Data")]
        public JsonResult Data(int? hours, DateTime? from, DateTime? to, int? year, string q, string border, string user)
        {
            int draw = 0, start = 0, length = 10;
            try
            {
                int.TryParse(Request["draw"], out draw);
                int.TryParse(Request["start"], out start);
                int.TryParse(Request["length"], out length);

                if (start < 0) start = 0;
                if (length <= 0 || length > 100) length = 10;

                var searchValue = (Request["search[value]"] ?? string.Empty).Trim();
                if (string.IsNullOrWhiteSpace(q))
                    q = searchValue;

                DateTime? startTime, endTime;
                int selectedYear;
                string filterText;
                ResolveDateRange(hours, from, to, year, out startTime, out endTime, out selectedYear, out filterText);

                using (var db = new GZPEGM1())
                {
                    IQueryable<E_IsK> baseQuery = db.E_IsK.AsNoTracking();

                    // Filtresiz toplam (tüm veritabanı) – performans için hızlı bir yaklaşım
                    var totalQuery = ApplyFilters(baseQuery, startTime, endTime, null, border, user);
                    int recordsTotal = totalQuery.Count();   // gerçek sayı

                    // Aramalı filtreli toplam
                    var filteredQuery = ApplyFilters(baseQuery, startTime, endTime, q, border, user);
                    int recordsFiltered = filteredQuery.Count();  // gerçek sayı

                    // Sayfalama yap
                    var rows = filteredQuery
                        .OrderByDescending(x => x.fldId)
                        .Skip(start)
                        .Take(length)
                        .Select(x => new
                        {
                            x.fldId,
                            x.fldDatetime,
                            x.fldName,
                            x.fldPassport,
                            x.fldIdn,
                            x.fldOrgin,
                            x.fldVisa,
                            x.fldBirthdate,
                            x.fldPassControl,
                            x.fldApproval,
                            x.fldPMoney,
                            x.fldBorder,
                            x.fldPicture
                        })
                        .ToList()
                        .Select(x =>
                        {
                            decimal ceza = ParseMoney(x.fldPMoney);
                            string para = ceza.ToString("N0", new CultureInfo("tr-TR"));

                            string resim = !string.IsNullOrEmpty(x.fldPicture) ? x.fldPicture : "no-image.png";

                            return new[]
                            {
                                $"<img src=\"/ccc/{HttpUtility.HtmlAttributeEncode(resim)}\" class=\"table-img\" loading=\"lazy\" decoding=\"async\" onerror=\"this.src='/AdminTemplate/img/no-image.png'\" />",
                                x.fldDatetime?.ToString("dd.MM.yyyy HH:mm") ?? "",
                                $"<strong>{HttpUtility.HtmlEncode(x.fldName ?? "")}</strong>",
                                $"<span class=\"badge-custom\">{HttpUtility.HtmlEncode(x.fldPassport ?? "")}</span>",
                                HttpUtility.HtmlEncode(x.fldIdn ?? ""),
                                HttpUtility.HtmlEncode(x.fldOrgin ?? ""),
                                HttpUtility.HtmlEncode(x.fldVisa ?? ""),
                                x.fldBirthdate?.ToString("dd.MM.yyyy") ?? "",
                                HttpUtility.HtmlEncode(x.fldPassControl ?? ""),
                                HttpUtility.HtmlEncode(x.fldApproval ?? ""),
                                $"<span class=\"text-danger fw-bold\">₺ {para}</span>",
                                $"<span class=\"badge-custom\">{HttpUtility.HtmlEncode(x.fldBorder ?? "")}</span>",
                                $"<a href=\"/formyazdir/{x.fldId}\" target=\"_blank\" class=\"btn btn-sm btn-outline-secondary\" title=\"Yazdır\">🖨️</a> " +
                                $"<a onclick=\"deleteRecord('{x.fldId}')\" class=\"btn btn-sm btn-danger\" title=\"Sil\">🗑️</a>"
                            };
                        })
                        .ToList();

                    return Json(new
                    {
                        draw = draw,
                        recordsTotal = recordsTotal,
                        recordsFiltered = recordsFiltered,
                        data = rows
                    }, JsonRequestBehavior.AllowGet);
                }
            }
            catch (Exception ex)
            {
                return Json(new
                {
                    draw = draw,
                    recordsTotal = 0,
                    recordsFiltered = 0,
                    data = new string[0][],
                    error = ex.Message
                }, JsonRequestBehavior.AllowGet);
            }
        }
    }
}
