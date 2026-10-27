using gzpegm.Cont;
using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize]
    public class OSISKController : Controller
    {
        [NonAction]
        public E_User GetUser()
        {
            HttpCookie userCookie = Request.Cookies["Token"];
            Token token = new Token();
            gzpegm.Cont.User user = new User();
            int userId = 0;
            if (userCookie != null)
            {
                var tokendata = token.GetToken(userCookie.Value.ToString());
                if (tokendata != null)
                {
                    int.TryParse(tokendata.fldUserId.ToString(), out userId);
                }
            }
            var data = user.GetUserById(userId);
            return data;
        }

        private bool IsAdminUser(E_User user)
        {
            if (user == null)
                return false;

            if (string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase))
                return true;

            var auth = user.fldAuth ?? string.Empty;
            return auth.Contains("2") || auth.Contains("4");
        }

        private static bool TryParseMoney(string value, out double result)
        {
            if (double.TryParse(value, NumberStyles.Any, new CultureInfo("tr-TR"), out result))
            {
                result = Math.Truncate(result);
                return true;
            }

            if (double.TryParse(value, NumberStyles.Any, CultureInfo.InvariantCulture, out result))
            {
                result = Math.Truncate(result);
                return true;
            }

            var normalized = NormalizeMoneyString(value);
            if (double.TryParse(normalized, NumberStyles.Any, CultureInfo.InvariantCulture, out result))
            {
                result = Math.Truncate(result);
                return true;
            }

            result = 0;
            return false;
        }

        private static List<E_History> DeduplicateHistoryList(List<E_History> list)
        {
            if (list == null || list.Count <= 1) return list;

            var result = new List<E_History>(list.Count);
            foreach (var item in list)
            {
                var itemTime = item.fldDatetime ?? DateTime.MinValue;
                var itemUserKey = gzpegm.Helpers.HistoryUserHelper.GetGroupingKey(item.fldUser);
                bool isDup = false;

                for (int i = result.Count - 1; i >= 0; i--)
                {
                    var prev = result[i];
                    var prevTime = prev.fldDatetime ?? DateTime.MinValue;
                    var diffSeconds = Math.Abs((itemTime - prevTime).TotalSeconds);

                    if (diffSeconds > 120) break;

                    if (diffSeconds <= 90 &&
                        prev.fldCountry == item.fldCountry &&
                        prev.fldPenalty == item.fldPenalty &&
                        prev.fldPMoney == item.fldPMoney &&
                        prev.fldStart == item.fldStart &&
                        prev.fldShouldExit == item.fldShouldExit &&
                        prev.fldBirthDate == item.fldBirthDate &&
                        prev.fldBorder == item.fldBorder &&
                        gzpegm.Helpers.HistoryUserHelper.GetGroupingKey(prev.fldUser) == itemUserKey)
                    {
                        isDup = true;
                        break;
                    }
                }

                if (!isDup)
                {
                    result.Add(item);
                }
            }

            return result;
        }

        private static void SetHistoryStats(dynamic viewBag, List<E_History> data)
        {
            viewBag.ToplamHesaplama = data.Count.ToString();

            double toplamMiktar = 0;
            double enYuksekMiktar = 0;
            int tutarliKayit = 0;
            foreach (var item in data)
            {
                double val;
                if (!string.IsNullOrEmpty(item.fldPMoney) && TryParseMoney(item.fldPMoney, out val))
                {
                    toplamMiktar += val;
                    tutarliKayit++;
                    if (val > enYuksekMiktar)
                        enYuksekMiktar = val;
                }
            }

            viewBag.ToplamMiktar = toplamMiktar.ToString("#,0", new CultureInfo("tr-TR"));
            viewBag.OrtalamaMiktar = tutarliKayit > 0 ? (toplamMiktar / tutarliKayit).ToString("#,0", new CultureInfo("tr-TR")) : "0";
            viewBag.EnYuksekMiktar = enYuksekMiktar.ToString("#,0", new CultureInfo("tr-TR"));
            viewBag.BugunHesaplama = data.Count(x => x.fldDatetime.HasValue && x.fldDatetime.Value.Date == DateTime.Today).ToString();

            var grouped = data
                .Where(x => !string.IsNullOrEmpty(x.fldUser))
                .GroupBy(x => gzpegm.Helpers.HistoryUserHelper.GetGroupingKey(x.fldUser));

            var enCok = grouped
                .OrderByDescending(g => g.Count())
                .Select(g => new { Key = g.Key, Count = g.Count(), Display = gzpegm.Helpers.HistoryUserHelper.GetDisplayName(g.First().fldUser) })
                .FirstOrDefault();

            viewBag.EnCokHesaplayanPersonel = enCok != null ? enCok.Count.ToString() : "0";
            viewBag.EnCokHesaplayanAdi = enCok != null ? enCok.Display : "-";

            var enCokUlke = data
                .Where(x => !string.IsNullOrEmpty(x.fldCountry))
                .GroupBy(x => x.fldCountry)
                .OrderByDescending(g => g.Count())
                .Select(g => new { Ulke = g.Key, Sayi = g.Count() })
                .FirstOrDefault();
            viewBag.EnCokUlke = enCokUlke != null ? enCokUlke.Ulke : "-";
            viewBag.EnCokUlkeSayi = enCokUlke != null ? enCokUlke.Sayi.ToString() : "0";

            var enCokCeza = data
                .Where(x => !string.IsNullOrEmpty(x.fldPenalty))
                .GroupBy(x => x.fldPenalty)
                .OrderByDescending(g => g.Count())
                .Select(g => new { Ceza = g.Key, Sayi = g.Count() })
                .FirstOrDefault();
            viewBag.EnCokCezaTuru = enCokCeza != null ? enCokCeza.Ceza : "-";
            viewBag.EnCokCezaTuruSayi = enCokCeza != null ? enCokCeza.Sayi.ToString() : "0";
        }

        private static void SetTahditStats(dynamic viewBag, DateTime? startTime, DateTime? endTime, string border)
        {
            try
            {
                viewBag.TahditStats = new TahditFormLogService().GetStatistics(startTime, endTime, border, null, null);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Tahdit old history stats error: " + ex.Message);
                viewBag.TahditStats = new gzpegm.Models.ViewModels.TahditStatisticsViewModel();
            }
        }

        private static IQueryable<E_History> ApplyHistorySearch(IQueryable<E_History> query, string q)
        {
            if (string.IsNullOrWhiteSpace(q))
                return query;

            string search = q.Trim().ToLower();
            return query.Where(x =>
                (x.fldCountry != null && x.fldCountry.ToLower().Contains(search)) ||
                (x.fldUser != null && x.fldUser.ToLower().Contains(search)) ||
                (x.fldBorder != null && x.fldBorder.ToLower().Contains(search)) ||
                (x.fldPenalty != null && x.fldPenalty.ToLower().Contains(search)) ||
                (x.fldPMoney != null && x.fldPMoney.ToLower().Contains(search)));
        }

        private static IQueryable<E_History> ApplyHistoryFilters(IQueryable<E_History> query, string q, string border, string user)
        {
            query = ApplyHistorySearch(query, q);

            if (!string.IsNullOrWhiteSpace(border))
            {
                var selectedBorder = border.Trim();
                query = query.Where(x => x.fldBorder == selectedBorder);
            }

            if (!string.IsNullOrWhiteSpace(user))
            {
                var selectedUser = user.Trim();
                query = query.Where(x => x.fldUser == selectedUser);
            }

            return query;
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

        private static string FormatMoney(string value)
        {
            double parsed;
            return TryParseMoney(value, out parsed)
                ? parsed.ToString("#,0", new CultureInfo("tr-TR"))
                : (value ?? string.Empty);
        }

        private static string BuildHistoryExcelHtml(List<E_History> list, string filterInfo)
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
            sb.AppendLine(".text-right { text-align: right; }");
            sb.AppendLine("tr:nth-child(even) td { background: #f8fafc; }");
            sb.AppendLine("</style></head><body>");
            sb.AppendLine("<div class=\"title\">Eski Hesaplamalar</div>");
            sb.AppendLine("<div class=\"subtitle\">Oluşturma Tarihi: " + HttpUtility.HtmlEncode(DateTime.Now.ToString("dd.MM.yyyy HH:mm")) + "</div>");
            sb.AppendLine("<div class=\"subtitle\">" + HttpUtility.HtmlEncode(filterInfo ?? string.Empty) + "</div>");
            sb.AppendLine("<table><thead><tr>");
            sb.AppendLine("<th>Id</th><th>İşlem Tarihi</th><th>Kullanıcı</th><th>Kapı</th><th>Ülke</th><th>Doğum Tarihi</th><th>Başlangıç</th><th>Çıkış</th><th>Ceza</th><th>Miktar</th>");
            sb.AppendLine("</tr></thead><tbody>");

            foreach (var item in list)
            {
                sb.AppendLine("<tr>");
                sb.AppendLine("<td>" + item.fldId + "</td>");
                sb.AppendLine("<td class=\"nowrap\">" + HttpUtility.HtmlEncode(item.fldDatetime?.ToString("dd.MM.yyyy HH:mm") ?? string.Empty) + "</td>");
                sb.AppendLine("<td>" + HttpUtility.HtmlEncode(item.fldUser ?? string.Empty) + "</td>");
                sb.AppendLine("<td>" + HttpUtility.HtmlEncode(item.fldBorder ?? string.Empty) + "</td>");
                sb.AppendLine("<td>" + HttpUtility.HtmlEncode(item.fldCountry ?? string.Empty) + "</td>");
                sb.AppendLine("<td class=\"nowrap\">" + HttpUtility.HtmlEncode(item.fldBirthDate?.ToString("dd.MM.yyyy") ?? string.Empty) + "</td>");
                sb.AppendLine("<td class=\"nowrap\">" + HttpUtility.HtmlEncode(item.fldStart?.ToString("dd.MM.yyyy") ?? string.Empty) + "</td>");
                sb.AppendLine("<td class=\"nowrap\">" + HttpUtility.HtmlEncode(item.fldShouldExit?.ToString("dd.MM.yyyy") ?? string.Empty) + "</td>");
                sb.AppendLine("<td>" + HttpUtility.HtmlEncode(item.fldPenalty ?? string.Empty) + "</td>");
                sb.AppendLine("<td class=\"text-right\">" + HttpUtility.HtmlEncode(FormatMoney(item.fldPMoney)) + "</td>");
                sb.AppendLine("</tr>");
            }

            sb.AppendLine("</tbody></table></body></html>");
            return sb.ToString();
        }

        private static byte[] BuildHistoryPdfContent(List<E_History> list, string filterInfo)
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

                document.Add(new iTextSharp.text.Paragraph("Eski Hesaplamalar", titleFont));
                document.Add(new iTextSharp.text.Paragraph("Oluşturma Tarihi: " + DateTime.Now.ToString("dd.MM.yyyy HH:mm"), infoFont));
                document.Add(new iTextSharp.text.Paragraph(filterInfo ?? string.Empty, infoFont));
                document.Add(new iTextSharp.text.Paragraph(" "));

                var table = new iTextSharp.text.pdf.PdfPTable(10) { WidthPercentage = 100 };
                table.SetWidths(new float[] { 5f, 11f, 14f, 10f, 10f, 10f, 10f, 10f, 10f, 10f });

                foreach (var header in new[] { "Id", "İşlem Tarihi", "Kullanıcı", "Kapı", "Ülke", "Doğum Tarihi", "Başlangıç", "Çıkış", "Ceza", "Miktar" })
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
                    AddPdfCell(table, item.fldUser ?? string.Empty, cellFont);
                    AddPdfCell(table, item.fldBorder ?? string.Empty, cellFont);
                    AddPdfCell(table, item.fldCountry ?? string.Empty, cellFont);
                    AddPdfCell(table, item.fldBirthDate?.ToString("dd.MM.yyyy") ?? string.Empty, cellFont);
                    AddPdfCell(table, item.fldStart?.ToString("dd.MM.yyyy") ?? string.Empty, cellFont);
                    AddPdfCell(table, item.fldShouldExit?.ToString("dd.MM.yyyy") ?? string.Empty, cellFont);
                    AddPdfCell(table, item.fldPenalty ?? string.Empty, cellFont);
                    AddPdfCell(table, FormatMoney(item.fldPMoney), cellFont, false, true);
                }

                document.Add(table);
                document.Close();
                return stream.ToArray();
            }
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

        private static iTextSharp.text.Font BuildUnicodeFont(float size, bool bold = false, iTextSharp.text.BaseColor color = null)
        {
            var fontPath = System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Fonts), "arial.ttf");
            var baseFont = iTextSharp.text.pdf.BaseFont.CreateFont(fontPath, iTextSharp.text.pdf.BaseFont.IDENTITY_H, iTextSharp.text.pdf.BaseFont.EMBEDDED);
            return new iTextSharp.text.Font(baseFont, size, bold ? iTextSharp.text.Font.BOLD : iTextSharp.text.Font.NORMAL, color ?? iTextSharp.text.BaseColor.BLACK);
        }

        private static string BuildIskExcelHtml(List<E_IsK> list, string filterInfo)
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
            sb.AppendLine(".text-right { text-align: right; }");
            sb.AppendLine("tr:nth-child(even) td { background: #f8fafc; }");
            sb.AppendLine("</style></head><body>");
            sb.AppendLine("<div class=\"title\">Hudut Kapısı İşlem Listesi</div>");
            sb.AppendLine("<div class=\"subtitle\">Oluşturma Tarihi: " + HttpUtility.HtmlEncode(DateTime.Now.ToString("dd.MM.yyyy HH:mm")) + "</div>");
            sb.AppendLine("<div class=\"subtitle\">" + HttpUtility.HtmlEncode(filterInfo ?? string.Empty) + "</div>");
            sb.AppendLine("<table><thead><tr>");
            sb.AppendLine("<th>Id</th><th>İşlem Tarihi</th><th>Ad Soyad</th><th>Onaylayan</th><th>Kapı</th><th>Pasaport</th><th>Kimlik</th><th>Uyruk</th><th>Vize</th><th>Doğum Tarihi</th><th>Para (TL)</th><th>Resim</th>");
            sb.AppendLine("</tr></thead><tbody>");

            foreach (var item in list)
            {
                sb.AppendLine("<tr>");
                sb.AppendLine("<td>" + item.fldId + "</td>");
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

            sb.AppendLine("</tbody></table></body></html>");
            return sb.ToString();
        }

        private static byte[] BuildIskPdfContent(List<E_IsK> list, string filterInfo)
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

                document.Add(new iTextSharp.text.Paragraph("Hudut Kapısı İşlem Listesi", titleFont));
                document.Add(new iTextSharp.text.Paragraph("Oluşturma Tarihi: " + DateTime.Now.ToString("dd.MM.yyyy HH:mm"), infoFont));
                document.Add(new iTextSharp.text.Paragraph(filterInfo ?? string.Empty, infoFont));
                document.Add(new iTextSharp.text.Paragraph(" "));

                var table = new iTextSharp.text.pdf.PdfPTable(12) { WidthPercentage = 100 };
                table.SetWidths(new float[] { 5f, 11f, 14f, 12f, 14f, 10f, 9f, 10f, 12f, 10f, 9f, 10f });

                foreach (var header in new[] { "Id", "İşlem Tarihi", "Ad Soyad", "Onaylayan", "Kapı", "Pasaport", "Kimlik", "Uyruk", "Vize", "Doğum Tarihi", "Para (TL)", "Resim" })
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
                    AddPdfCell(table, item.fldPicture ?? string.Empty, cellFont);
                }

                document.Add(table);
                document.Close();
                return stream.ToArray();
            }
        }

        private static IQueryable<E_History> ApplyHistoryDateRange(IQueryable<E_History> query, DateTime? from, DateTime? to, out DateTime? startTime, out DateTime? endTime)
        {
            startTime = null;
            endTime = null;

            if (!from.HasValue && !to.HasValue)
                return query;

            if (from.HasValue)
                startTime = from.Value.Date;

            if (to.HasValue)
                endTime = to.Value.Date.AddDays(1).AddTicks(-1);

            if (startTime.HasValue)
            {
                DateTime start = startTime.Value;
                query = query.Where(x => x.fldDatetime.HasValue && x.fldDatetime.Value >= start);
            }

            if (endTime.HasValue)
            {
                DateTime end = endTime.Value;
                query = query.Where(x => x.fldDatetime.HasValue && x.fldDatetime.Value <= end);
            }

            return query;
        }

        [Route("osIsk")]
        public ActionResult Index(int? hours, DateTime? from, DateTime? to)
        {
            var userdata = GetUser();
            if (userdata == null)
            {
                return RedirectToAction("Index", "Giris");
            }

            var isAdmin = IsAdminUser(userdata);
            int h = hours ?? 24;
            DateTime startTime;
            DateTime endTime = DateTime.Now;
            if (from.HasValue && to.HasValue)
            {
                startTime = from.Value.Date;
                endTime = to.Value.Date.AddDays(1).AddTicks(-1);
            }
            else
            {
                startTime = DateTime.Now.AddHours(-h);
            }

            using (GZPEGM1 c = new GZPEGM1())
            {
                if (isAdmin)
                {
                    var borderQuery = c.E_IsK.AsNoTracking().Where(x => x.fldDatetime.HasValue && x.fldDatetime >= startTime && x.fldDatetime <= endTime);
                    if (!string.IsNullOrEmpty(userdata.fldBorder))
                    {
                        borderQuery = borderQuery.Where(x => x.fldBorder == userdata.fldBorder);
                    }

                    ViewBag.KesilenToplamCeza = borderQuery.Count().ToString();

                    // Toplam Ceza Miktarı (fldPMoney in E_IsK)
                    var toplamList = borderQuery
                        .Where(x => x.fldPMoney != null && x.fldPMoney != "")
                        .Select(x => x.fldPMoney)
                        .ToList();
                    double toplam = 0;
                    foreach (var item in toplamList)
                    {
                        double val;
                        if (TryParseMoney(item, out val)) toplam += val;
                    }
                    ViewBag.toplam = toplam.ToString("#,0", new CultureInfo("tr-TR"));

                    // En Çok İşlem Yapan Personel
                    var enCokPersonel = borderQuery
                        .Where(x => x.fldApproval != null && x.fldApproval != "")
                        .GroupBy(x => x.fldApproval)
                        .OrderByDescending(g => g.Count())
                        .Select(g => new { Adi = g.Key, Sayi = g.Count() })
                        .FirstOrDefault();
                    ViewBag.EnCokIslemYapanPersonel = enCokPersonel != null ? enCokPersonel.Sayi.ToString() : "0";
                    ViewBag.EnCokIslemYapanAdi = enCokPersonel != null ? enCokPersonel.Adi : "-";

                    // En Fazla Ceza Kesilen Miktar
                    var moneyList = borderQuery
                        .Where(x => x.fldPMoney != null && x.fldPMoney != "")
                        .Select(x => x.fldPMoney)
                        .ToList();
                    double enFazlaMiktar = 0;
                    foreach (var item in moneyList)
                    {
                        double val;
                        if (TryParseMoney(item, out val) && val > enFazlaMiktar)
                            enFazlaMiktar = val;
                    }
                    ViewBag.EnFazlaCezaMiktari = enFazlaMiktar.ToString("#,0", new CultureInfo("tr-TR"));
                }
                else
                {
                    DateTime dt = DateTime.Now.AddDays(-1);
                    string approval = (userdata.fldName + " " + userdata.fldLastName).Trim();
                    var userQuery = c.E_IsK.AsNoTracking().Where(x => x.fldApproval == approval && x.fldBorder == userdata.fldBorder && x.fldDatetime.HasValue && x.fldDatetime > dt);

                    var count = userQuery.Count();
                    ViewBag.KesilenToplamCeza = count.ToString();

                    var userMoneyList = userQuery
                        .Where(x => x.fldPMoney != null && x.fldPMoney != "")
                        .Select(x => x.fldPMoney)
                        .ToList();
                    double toplam = 0;
                    double enFazlaMiktar = 0;
                    foreach (var item in userMoneyList)
                    {
                        double val;
                        if (TryParseMoney(item, out val))
                        {
                            toplam += val;
                            if (val > enFazlaMiktar) enFazlaMiktar = val;
                        }
                    }
                    ViewBag.toplam = toplam.ToString("#,0", new CultureInfo("tr-TR"));
                    ViewBag.EnCokIslemYapanPersonel = count.ToString();
                    ViewBag.EnCokIslemYapanAdi = approval;
                    ViewBag.EnFazlaCezaMiktari = enFazlaMiktar.ToString("#,0", new CultureInfo("tr-TR"));
                }
            }

            SetTahditStats(ViewBag, startTime, endTime, userdata.fldBorder);
            ViewBag.SelectedHours = h;
            ViewBag.From = from.HasValue ? (DateTime?)from.Value.Date : null;
            ViewBag.To = to.HasValue ? (DateTime?)to.Value.Date : null;
            // View'a boş model gönder, tablo verileri AJAX ile gelecek
            return View(new List<E_IsK>());
        }

        [Route("osIskData")]
        public JsonResult GetData(int draw, int start, int length, string searchValue)
        {
            var userdata = GetUser();
            if (userdata == null)
            {
                return Json(new
                {
                    draw = draw,
                    recordsTotal = 0,
                    recordsFiltered = 0,
                    data = new object[0]
                }, JsonRequestBehavior.AllowGet);
            }

            var isAdmin = IsAdminUser(userdata);

            using (GZPEGM1 c = new GZPEGM1())
            {
                IQueryable<E_IsK> query;
                if (isAdmin)
                {
                    query = c.E_IsK.AsNoTracking();
                    if (!string.IsNullOrEmpty(userdata.fldBorder))
                    {
                        query = query.Where(x => x.fldBorder == userdata.fldBorder);
                    }
                }
                else
                {
                    DateTime dt = DateTime.Now.AddDays(-1);
                    string approval = (userdata.fldName + " " + userdata.fldLastName).Trim();
                    query = c.E_IsK.AsNoTracking().Where(x => x.fldApproval == approval && x.fldBorder == userdata.fldBorder && x.fldDatetime > dt);
                }

                int totalRecords = query.Count();

                // Arama filtresi - tüm veritabanında arama yapar (sayfalamadan önce)
                if (!string.IsNullOrWhiteSpace(searchValue))
                {
                    searchValue = searchValue.Trim().ToLower();
                    query = query.Where(x =>
                        (x.fldName != null && x.fldName.ToLower().Contains(searchValue)) ||
                        (x.fldApproval != null && x.fldApproval.ToLower().Contains(searchValue)) ||
                        (x.fldBorder != null && x.fldBorder.ToLower().Contains(searchValue)) ||
                        (x.fldPassport != null && x.fldPassport.ToLower().Contains(searchValue)) ||
                        (x.fldIdn != null && x.fldIdn.ToLower().Contains(searchValue)) ||
                        (x.fldOrgin != null && x.fldOrgin.ToLower().Contains(searchValue)) ||
                        (x.fldVisa != null && x.fldVisa.ToLower().Contains(searchValue))
                    );
                }

                int filteredRecords = query.Count();

                // Verileri sayfalayarak ve sıralayarak al
                var data = query
                    .OrderByDescending(x => x.fldDatetime)
                    .Skip(start)
                    .Take(length)
                    .Select(x => new
                    {
                        x.fldId,
                        x.fldPicture,
                        x.fldDatetime,
                        x.fldName,
                        x.fldPassport,
                        x.fldIdn,
                        x.fldOrgin,
                        x.fldBirthdate,
                        x.fldPassControl,
                        x.fldApproval,
                        x.fldPMoney,
                        x.fldBorder,
                        x.fldVisa
                    })
                    .ToList();

                var result = data.Select(x => new
                {
                    resim = x.fldPicture ?? "no-image.png",
                    tarih = x.fldDatetime.HasValue ? x.fldDatetime.Value.ToString("dd.MM.yyyy HH:mm") : "",
                    adi = x.fldName ?? "",
                    pasaport = x.fldPassport ?? "",
                    kimlik = x.fldIdn ?? "",
                    uyruk = x.fldOrgin ?? "",
                    vize = x.fldVisa ?? "",
                    dogumTarihi = x.fldBirthdate.HasValue ? x.fldBirthdate.Value.ToString("dd.MM.yyyy") : "",
                    kontrolm = x.fldPassControl ?? "",
                    onay = x.fldApproval ?? "",
                    para = x.fldPMoney ?? "",
                    kapi = x.fldBorder ?? "",
                    id = x.fldId
                });

                return Json(new
                {
                    draw = draw,
                    recordsTotal = totalRecords,
                    recordsFiltered = filteredRecords,
                    data = result
                }, JsonRequestBehavior.AllowGet);
            }
        }

        [Route("osIskExport")]
        public ActionResult OsIskExport(int? hours, DateTime? from, DateTime? to, string export)
        {
            var userdata = GetUser();
            if (userdata == null)
            {
                return RedirectToAction("Index", "Giris");
            }

            var isAdmin = IsAdminUser(userdata);

            using (GZPEGM1 c = new GZPEGM1())
            {
                IQueryable<E_IsK> query;
                if (isAdmin)
                {
                    query = c.E_IsK.AsNoTracking();
                    if (!string.IsNullOrEmpty(userdata.fldBorder))
                    {
                        query = query.Where(x => x.fldBorder == userdata.fldBorder);
                    }
                }
                else
                {
                    DateTime dt = DateTime.Now.AddDays(-1);
                    string approval = (userdata.fldName + " " + userdata.fldLastName).Trim();
                    query = c.E_IsK.AsNoTracking().Where(x => x.fldApproval == approval && x.fldBorder == userdata.fldBorder && x.fldDatetime > dt);
                }

                // apply time filters
                DateTime startTime;
                DateTime endTime = DateTime.Now;
                if (from.HasValue && to.HasValue)
                {
                    startTime = from.Value.Date;
                    endTime = to.Value.Date.AddDays(1).AddTicks(-1);
                    query = query.Where(x => x.fldDatetime >= startTime && x.fldDatetime <= endTime);
                }
                else
                {
                    int h = hours ?? 24;
                    startTime = DateTime.Now.AddHours(-h);
                    query = query.Where(x => x.fldDatetime >= startTime && x.fldDatetime <= endTime);
                }

                var list = query.OrderByDescending(x => x.fldDatetime).ToList();

                if (!string.IsNullOrEmpty(export) && (export.ToLower() == "pdf" || export.ToLower() == "excel"))
                {
                    var filterInfo = from.HasValue && to.HasValue
                        ? string.Format("{0:dd.MM.yyyy} - {1:dd.MM.yyyy} tarih aralığı", from.Value, to.Value)
                        : string.Format("Son {0} saat", hours ?? 24);
                    var fileNameBase = string.Format("OsIsk_{0:yyyyMMddHHmm}", DateTime.Now);

                    if (export.ToLower() == "excel")
                    {
                        var html = BuildIskExcelHtml(list, filterInfo);
                        var htmlBytes = new System.Text.UTF8Encoding(true).GetBytes(html);
                        return File(htmlBytes, "application/vnd.ms-excel; charset=utf-8", fileNameBase + ".xls");
                    }

                    var pdfBytes = BuildIskPdfContent(list, filterInfo);
                    return File(pdfBytes, "application/pdf", fileNameBase + ".pdf");
                }

                // otherwise redirect back to Index
                return RedirectToAction("Index");
            }
        }

        [Route("osIsk/iskData")]
        public JsonResult GetIskData(int draw, int start, int length, string searchValue)
        {
            var userdata = GetUser();
            if (userdata == null)
            {
                return Json(new { draw = draw, recordsTotal = 0, recordsFiltered = 0, data = new object[0] }, JsonRequestBehavior.AllowGet);
            }

            var isAdmin = IsAdminUser(userdata);

            using (GZPEGM1 c = new GZPEGM1())
            {
                IQueryable<E_IsK> query;
                
                if (isAdmin)
                {
                    query = c.E_IsK.AsNoTracking();
                    if (!string.IsNullOrEmpty(userdata.fldBorder))
                    {
                        query = query.Where(x => x.fldBorder == userdata.fldBorder);
                    }
                }
                else
                {
                    DateTime dt = DateTime.Now.AddDays(-1);
                    query = c.E_IsK.AsNoTracking().Where(x => x.fldBorder == userdata.fldBorder && x.fldDatetime > dt);
                }

                int totalRecords = query.Count();

                // Arama filtresi
                if (!string.IsNullOrWhiteSpace(searchValue))
                {
                    searchValue = searchValue.Trim().ToLower();
                    query = query.Where(x =>
                        (x.fldName != null && x.fldName.ToLower().Contains(searchValue)) ||
                        (x.fldApproval != null && x.fldApproval.ToLower().Contains(searchValue)) ||
                        (x.fldBorder != null && x.fldBorder.ToLower().Contains(searchValue)) ||
                        (x.fldPassport != null && x.fldPassport.ToLower().Contains(searchValue)) ||
                        (x.fldIdn != null && x.fldIdn.ToLower().Contains(searchValue)) ||
                        (x.fldOrgin != null && x.fldOrgin.ToLower().Contains(searchValue)) ||
                        (x.fldVisa != null && x.fldVisa.ToLower().Contains(searchValue))
                    );
                }

                int filteredRecords = query.Count();

                // Verileri sayfalayarak ve sıralayarak al
                var data = query
                    .OrderByDescending(x => x.fldDatetime)
                    .Skip(start)
                    .Take(length)
                    .Select(x => new
                    {
                        x.fldId,
                        x.fldPicture,
                        x.fldDatetime,
                        x.fldName,
                        x.fldPassport,
                        x.fldIdn,
                        x.fldOrgin,
                        x.fldBirthdate,
                        x.fldPassControl,
                        x.fldApproval,
                        x.fldPMoney,
                        x.fldBorder,
                        x.fldVisa
                    })
                    .ToList();

                var result = data.Select(x => new
                {
                    resim = x.fldPicture ?? "no-image.png",
                    tarih = x.fldDatetime.HasValue ? x.fldDatetime.Value.ToString("dd.MM.yyyy HH:mm") : "",
                    adi = x.fldName ?? "",
                    pasaport = x.fldPassport ?? "",
                    kimlik = x.fldIdn ?? "",
                    uyruk = x.fldOrgin ?? "",
                    vize = x.fldVisa ?? "",
                    dogumTarihi = x.fldBirthdate.HasValue ? x.fldBirthdate.Value.ToString("dd.MM.yyyy") : "",
                    kontrolm = x.fldPassControl ?? "",
                    onay = x.fldApproval ?? "",
                    para = x.fldPMoney ?? "",
                    kapi = x.fldBorder ?? "",
                    id = x.fldId
                });

                return Json(new
                {
                    draw = draw,
                    recordsTotal = totalRecords,
                    recordsFiltered = filteredRecords,
                    data = result
                }, JsonRequestBehavior.AllowGet);
            }
        }

        [Route("OSHIST")]
        public ActionResult OSHIST(int? hours, DateTime? from, DateTime? to, string q, string export)
        {
            var userdata = GetUser();
            if (userdata == null)
            {
                return RedirectToAction("Index", "Giris");
            }

            var isAdmin = IsAdminUser(userdata);

            using (GZPEGM1 db = new GZPEGM1())
            {
                IQueryable<E_History> query = db.E_History.AsNoTracking().Where(hh => hh.fldDatetime.HasValue);

                // Normal kullanıcılar sadece kendi kapısını görebilir
                if (!isAdmin)
                {
                    var userBorder = userdata.fldBorder ?? string.Empty;
                    if (string.IsNullOrWhiteSpace(userBorder))
                    {
                        query = query.Where(x => false);
                    }
                    else
                    {
                        query = query.Where(x => x.fldBorder == userBorder);
                    }
                }
                else if (!string.IsNullOrWhiteSpace(userdata.fldBorder))
                {
                    query = query.Where(x => x.fldBorder == userdata.fldBorder);
                }

                DateTime? startTime, endTime;
                var filtered = ApplyHistoryDateRange(query, from, to, out startTime, out endTime);
                if (!from.HasValue && !to.HasValue && hours.HasValue && hours.Value > 0)
                {
                    endTime = DateTime.Now;
                    startTime = endTime.Value.AddHours(-hours.Value);
                    filtered = filtered.Where(x => x.fldDatetime.HasValue && x.fldDatetime.Value >= startTime.Value && x.fldDatetime.Value <= endTime.Value);
                }
                filtered = ApplyHistorySearch(filtered, q);
                var filteredList = filtered.OrderByDescending(x => x.fldDatetime).ToList();
                filteredList = DeduplicateHistoryList(filteredList);
                bool hasFilter = from.HasValue || to.HasValue || hours.HasValue || !string.IsNullOrWhiteSpace(q);
                var data = hasFilter ? filteredList : filteredList.Take(100).ToList();

                // Export
                if (!string.IsNullOrEmpty(export) && (export.ToLower() == "pdf" || export.ToLower() == "excel"))
                {
                    var filterInfo = hasFilter
                        ? string.Format("{0} kayıt bulundu.", filteredList.Count)
                        : "Son 100 kayıt gösteriliyor. Arama ve filtreler tüm veritabanında çalışır.";
                    var fileNameBase = string.Format("OSHIST_{0:yyyyMMddHHmm}", DateTime.Now);

                    if (export.ToLower() == "excel")
                    {
                        var html = BuildHistoryExcelHtml(filteredList, filterInfo);
                        var htmlBytes = new System.Text.UTF8Encoding(true).GetBytes(html);
                        return File(htmlBytes, "application/vnd.ms-excel; charset=utf-8", fileNameBase + ".xls");
                    }

                    var pdfBytes = BuildHistoryPdfContent(filteredList, filterInfo);
                    return File(pdfBytes, "application/pdf", fileNameBase + ".pdf");
                }

                SetHistoryStats(ViewBag, filteredList);
                SetTahditStats(ViewBag, startTime, endTime, userdata.fldBorder);

                ViewBag.From = from.HasValue ? (DateTime?)from.Value.Date : null;
                ViewBag.To = to.HasValue ? (DateTime?)to.Value.Date : null;
                ViewBag.SelectedHours = hours;
                ViewBag.SearchText = q ?? "";
                ViewBag.ResultInfo = hasFilter
                    ? string.Format("{0} kayıt bulundu.", filteredList.Count)
                    : "Son 100 kayıt gösteriliyor. Arama ve filtreler tüm veritabanında çalışır.";

                return View(data);
            }
        }

        [Route("HIST")]
        [UserAuthorize(Users = "2,4")] // Admin = 2,4
        public ActionResult HIST(int? hours, DateTime? from, DateTime? to, string q, string border, string user, string export)
        {
            var userdata = GetUser();
            if (userdata == null)
            {
                return RedirectToAction("Index", "Giris");
            }

            using (GZPEGM1 db = new GZPEGM1())
            {
                IQueryable<E_History> query = db.E_History.AsNoTracking().Where(hh => hh.fldDatetime.HasValue);

                DateTime? startTime, endTime;
                var filtered = ApplyHistoryDateRange(query, from, to, out startTime, out endTime);
                if (!from.HasValue && !to.HasValue && hours.HasValue && hours.Value > 0)
                {
                    endTime = DateTime.Now;
                    startTime = endTime.Value.AddHours(-hours.Value);
                    filtered = filtered.Where(x => x.fldDatetime.HasValue && x.fldDatetime.Value >= startTime.Value && x.fldDatetime.Value <= endTime.Value);
                }
                filtered = ApplyHistoryFilters(filtered, q, border, user);
                var filteredList = filtered.OrderByDescending(x => x.fldDatetime).ToList();
                filteredList = DeduplicateHistoryList(filteredList);
                bool hasFilter = from.HasValue || to.HasValue || hours.HasValue || !string.IsNullOrWhiteSpace(q) || !string.IsNullOrWhiteSpace(border) || !string.IsNullOrWhiteSpace(user);
                var data = hasFilter ? filteredList : filteredList.Take(100).ToList();

                if (!string.IsNullOrEmpty(export) && (export.ToLower() == "pdf" || export.ToLower() == "excel"))
                {
                    var fileNameBase = string.Format("HIST_{0:yyyyMMddHHmm}", DateTime.Now);
                    var filterInfo = hasFilter ? string.Format("{0} kayıt bulundu.", filteredList.Count) : "Son 100 kayıt gösteriliyor. Arama ve filtreler tüm veritabanında çalışır.";
                    if (export.ToLower() == "excel")
                    {
                        var html = BuildHistoryExcelHtml(filteredList, filterInfo);
                        var htmlBytes = new System.Text.UTF8Encoding(true).GetBytes(html);
                        return File(htmlBytes, "application/vnd.ms-excel; charset=utf-8", fileNameBase + ".xls");
                    }

                    var pdfBytes = BuildHistoryPdfContent(filteredList, filterInfo);
                    return File(pdfBytes, "application/pdf", fileNameBase + ".pdf");
                }

                SetHistoryStats(ViewBag, filteredList);
                SetTahditStats(ViewBag, startTime, endTime, border);

                ViewBag.From = from.HasValue ? (DateTime?)from.Value.Date : null;
                ViewBag.To = to.HasValue ? (DateTime?)to.Value.Date : null;
                ViewBag.SelectedHours = hours;
                ViewBag.SearchText = q ?? "";
                ViewBag.SelectedBorder = border ?? "";
                ViewBag.SelectedUser = user ?? "";
                ViewBag.BorderList = db.E_History.AsNoTracking()
                    .Where(x => x.fldBorder != null && x.fldBorder != "")
                    .Select(x => x.fldBorder)
                    .Distinct()
                    .OrderBy(x => x)
                    .ToList();
                ViewBag.UserList = db.E_History.AsNoTracking()
                    .Where(x => x.fldUser != null && x.fldUser != "")
                    .Select(x => x.fldUser)
                    .Distinct()
                    .OrderBy(x => x)
                    .ToList();
                ViewBag.ResultInfo = hasFilter
                    ? string.Format("{0} kayıt bulundu.", filteredList.Count)
                    : "Son 100 kayıt gösteriliyor. Arama ve filtreler tüm veritabanında çalışır.";

                return View(data);
            }
        }

        [Route("HIST24")]
        [UserAuthorize(Users = "2,4")] // Admin = 2,4
        public ActionResult HIST24(int? hours, DateTime? from, DateTime? to, string export)
        {
            return RedirectToAction("HIST", new { from, to, export });
        }

        [HttpPost]
        [Route("DeleteHist")]
        [UserAuthorize(Users = "2,4")]
        public JsonResult DeleteHist(int Id)
        {
            Isk hist = new Isk();
            hist.DeleteHist(Id);
            return Json(new { Message = "Başarılı bir şekilde silinmiştir.", Url = "/HIST" });
        }
    
        [HttpPost]
        [Route("CleanDuplicateHist")]
        [UserAuthorize(Users = "2,4")]
        public JsonResult CleanDuplicateHist()
        {
            try
            {
                int deletedHistory = 0;
                using (GZPEGM1 db = new GZPEGM1())
                {
                    db.Database.CommandTimeout = 300;
                    deletedHistory = db.Database.ExecuteSqlCommand(@"
                        ;WITH CTE_History AS
                        (
                            SELECT 
                                fldId,
                                ROW_NUMBER() OVER 
                                (
                                    PARTITION BY 
                                        CAST(fldDatetime AS DATE),
                                        DATEPART(hour, fldDatetime),
                                        DATEPART(minute, fldDatetime),
                                        ISNULL(CAST(fldUser AS NVARCHAR(250)), N''),
                                        ISNULL(fldStart, '1900-01-01'),
                                        ISNULL(fldShouldExit, '1900-01-01'),
                                        ISNULL(fldBirthDate, '1900-01-01'),
                                        ISNULL(CAST(fldCountry AS NVARCHAR(250)), N''),
                                        ISNULL(CAST(fldPenalty AS NVARCHAR(500)), N''),
                                        ISNULL(CAST(fldPMoney AS NVARCHAR(100)), N''),
                                        ISNULL(CAST(fldBorder AS NVARCHAR(250)), N'')
                                    ORDER BY fldId ASC
                                ) AS RowNum
                            FROM dbo.E_History
                        )
                        DELETE FROM CTE_History
                        WHERE RowNum > 1;");
                }
                return Json(new { Success = true, Message = string.Format("{0} adet mÃ¼kerrer kayÄ±t baÅŸarÄ±yla temizlendi.", deletedHistory) });
            }
            catch (Exception ex)
            {
                return Json(new { Success = false, Message = "Temizleme hatasÄ±: " + ex.Message });
            }
        }
    }
}