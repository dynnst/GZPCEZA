using gzpegm.Cont;
using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize]
    public class VizeController : Controller
    {
        [NonAction]
        public E_User GetUser()
        {
            HttpCookie UserCookie;
            UserCookie = Request.Cookies["Token"];
            Token token = new Token();
            gzpegm.Cont.User user = new User();
            int UserId = 0;
            if (UserCookie != null)
            {
                var tokendata = token.GetToken(UserCookie.Value.ToString());
                int.TryParse(tokendata.fldUserId.ToString(), out UserId);
            }
            var Data = user.GetUserById(UserId);
            return Data;
        }

        private static IEnumerable<E_Sartli> ApplySvizeFilters(IEnumerable<E_Sartli> query, string q, string border, string user, DateTime? from, DateTime? to)
        {
            if (!string.IsNullOrWhiteSpace(q))
            {
                var search = q.Trim();
                query = query.Where(x =>
                    (!string.IsNullOrEmpty(x.fldBy) && x.fldBy.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0) ||
                    (!string.IsNullOrEmpty(x.fldBorder) && x.fldBorder.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0) ||
                    (!string.IsNullOrEmpty(x.fldName) && x.fldName.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0) ||
                    (!string.IsNullOrEmpty(x.fldOrgin) && x.fldOrgin.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0));
            }

            if (!string.IsNullOrWhiteSpace(border))
            {
                var selectedBorder = border.Trim();
                query = query.Where(x => string.Equals(x.fldBorder ?? string.Empty, selectedBorder, StringComparison.OrdinalIgnoreCase));
            }

            if (!string.IsNullOrWhiteSpace(user))
            {
                var selectedUser = user.Trim();
                query = query.Where(x => string.Equals(x.fldBy ?? string.Empty, selectedUser, StringComparison.OrdinalIgnoreCase));
            }

            if (from.HasValue)
            {
                var fromDate = from.Value.Date;
                query = query.Where(x => x.fldDate.HasValue && x.fldDate.Value.Date >= fromDate);
            }

            if (to.HasValue)
            {
                var toDate = to.Value.Date;
                query = query.Where(x => x.fldDate.HasValue && x.fldDate.Value.Date <= toDate);
            }

            return query;
        }

        private void SetSvizeFilterViewBag(IEnumerable<E_Sartli> allData, string q, string border, string user, DateTime? from, DateTime? to, int resultCount, bool defaultLimited)
        {
            ViewBag.BorderList = allData
                .Select(x => x.fldBorder)
                .Where(x => !string.IsNullOrWhiteSpace(x))
                .Distinct()
                .OrderBy(x => x)
                .ToList();

            ViewBag.UserList = allData
                .Select(x => x.fldBy)
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
                ? "Filtre uygulanmadÄ±ÄŸÄ± iÃ§in son 100 kayÄ±t gÃ¶steriliyor."
                : resultCount + " kayÄ±t listeleniyor.";
        }

        private static string BuildSvizeExcelHtml(List<E_Sartli> list, string filterInfo)
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
            sb.AppendLine("<div class=\"title\">ÅartlÄ± Vize Listesi</div>");
            sb.AppendLine("<div class=\"subtitle\">OluÅŸturma Tarihi: " + HttpUtility.HtmlEncode(DateTime.Now.ToString("dd.MM.yyyy HH:mm")) + "</div>");
            sb.AppendLine("<div class=\"subtitle\">" + HttpUtility.HtmlEncode(filterInfo ?? string.Empty) + "</div>");
            sb.AppendLine("<table><thead><tr>");
            sb.AppendLine("<th>Ä°ÅŸlem Tarihi</th><th>Ä°ÅŸlemi Yapan</th><th>KapÄ±</th><th>AdÄ± SoyadÄ±</th><th>UyruÄŸu</th><th>DoÄŸum Tarihi</th>");
            sb.AppendLine("</tr></thead><tbody>");

            foreach (var item in list)
            {
                sb.AppendLine("<tr>");
                sb.AppendLine("<td class=\"nowrap\">" + HttpUtility.HtmlEncode(item.fldDate?.ToString("dd.MM.yyyy HH:mm") ?? string.Empty) + "</td>");
                sb.AppendLine("<td>" + HttpUtility.HtmlEncode(item.fldBy ?? string.Empty) + "</td>");
                sb.AppendLine("<td>" + HttpUtility.HtmlEncode(item.fldBorder ?? string.Empty) + "</td>");
                sb.AppendLine("<td>" + HttpUtility.HtmlEncode(item.fldName ?? string.Empty) + "</td>");
                sb.AppendLine("<td>" + HttpUtility.HtmlEncode(item.fldOrgin ?? string.Empty) + "</td>");
                sb.AppendLine("<td class=\"nowrap\">" + HttpUtility.HtmlEncode(item.fldBdate?.ToString("dd.MM.yyyy") ?? string.Empty) + "</td>");
                sb.AppendLine("</tr>");
            }

            sb.AppendLine("</tbody></table></body></html>");
            return sb.ToString();
        }

        private static byte[] BuildSvizePdfContent(List<E_Sartli> list, string filterInfo)
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

                document.Add(new iTextSharp.text.Paragraph("ÅartlÄ± Vize Listesi", titleFont));
                document.Add(new iTextSharp.text.Paragraph("OluÅŸturma Tarihi: " + DateTime.Now.ToString("dd.MM.yyyy HH:mm"), infoFont));
                document.Add(new iTextSharp.text.Paragraph(filterInfo ?? string.Empty, infoFont));
                document.Add(new iTextSharp.text.Paragraph(" "));

                var table = new iTextSharp.text.pdf.PdfPTable(6) { WidthPercentage = 100 };
                table.SetWidths(new float[] { 13f, 18f, 14f, 20f, 15f, 12f });

                foreach (var header in new[] { "Ä°ÅŸlem Tarihi", "Ä°ÅŸlemi Yapan", "KapÄ±", "AdÄ± SoyadÄ±", "UyruÄŸu", "DoÄŸum Tarihi" })
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
                    AddPdfCell(table, item.fldDate?.ToString("dd.MM.yyyy HH:mm") ?? string.Empty, cellFont);
                    AddPdfCell(table, item.fldBy ?? string.Empty, cellFont);
                    AddPdfCell(table, item.fldBorder ?? string.Empty, cellFont);
                    AddPdfCell(table, item.fldName ?? string.Empty, cellFont);
                    AddPdfCell(table, item.fldOrgin ?? string.Empty, cellFont);
                    AddPdfCell(table, item.fldBdate?.ToString("dd.MM.yyyy") ?? string.Empty, cellFont);
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

        Svize vize = new Svize();

        [Route("VIZEV")]
        public ActionResult Index()
        {
            return View();
        }

        [Route("AddSVIZE")]
        public ActionResult AddSVIZE(FormCollection Form)
        {
            var userData = GetUser();
            var data = vize.addSVize(
                userData.fldName + " " + userData.fldLastName,
                Form["Uyruk"].ToString(),
                Convert.ToDateTime(Form["BdateSVIZE"]),
                Convert.ToDateTime(Form["IdateSVIZE"]),
                Form["NameSVIZE"].ToString(),
                userData.fldBorder
            );

            return View(data);
        }

        [Route("vizeformyazdir/{Id:int}")]
        public ActionResult AddSVIZE(int Id)
        {
            var data = vize.GetbyId(Id);
            return View(data);
        }

        [NonAction]
        private bool IsAdminUser(E_User user)
        {
            if (user == null) return false;
            if (string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase)) return true;
            var auth = (user.fldAuth ?? string.Empty).Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries).Select(x => x.Trim());
            return auth.Contains("2") || auth.Contains("4");
        }

        [Route("SVIZE")]
        [UserAuthorize(Users = "2,4")]
        public ActionResult SVIZE(string q, string border, string user, DateTime? from, DateTime? to, string export)
        {
            using (var db = new GZPEGM1())
            {
                IQueryable<E_Sartli> query = db.E_Sartli.AsNoTracking().Where(x => x.fldDate.HasValue);

                if (!string.IsNullOrWhiteSpace(border))
                {
                    var selectedBorder = border.Trim();
                    query = query.Where(x => x.fldBorder == selectedBorder);
                }

                if (!string.IsNullOrWhiteSpace(user))
                {
                    var selectedUser = user.Trim();
                    query = query.Where(x => x.fldBy == selectedUser);
                }

                if (from.HasValue)
                {
                    var fromDate = from.Value.Date;
                    query = query.Where(x => x.fldDate >= fromDate);
                }

                if (to.HasValue)
                {
                    var toDate = to.Value.Date.AddDays(1).AddTicks(-1);
                    query = query.Where(x => x.fldDate <= toDate);
                }

                if (!string.IsNullOrWhiteSpace(q))
                {
                    var search = q.Trim().ToLower();
                    query = query.Where(x =>
                        (x.fldBy != null && x.fldBy.ToLower().Contains(search)) ||
                        (x.fldBorder != null && x.fldBorder.ToLower().Contains(search)) ||
                        (x.fldName != null && x.fldName.ToLower().Contains(search)) ||
                        (x.fldOrgin != null && x.fldOrgin.ToLower().Contains(search)));
                }

                var filteredList = query.OrderByDescending(x => x.fldDate).ToList();
                var hasFilter = !string.IsNullOrWhiteSpace(q)
                    || !string.IsNullOrWhiteSpace(border)
                    || !string.IsNullOrWhiteSpace(user)
                    || from.HasValue
                    || to.HasValue;

                var list = hasFilter ? filteredList : filteredList.Take(100).ToList();

                var filterInfo = string.Format(
                    "Arama: {0} | Kapı: {1} | Kullanıcı: {2} | Başlangıç: {3} | Bitiş: {4}",
                    string.IsNullOrWhiteSpace(q) ? "Tümü" : q,
                    string.IsNullOrWhiteSpace(border) ? "Tümü" : border,
                    string.IsNullOrWhiteSpace(user) ? "Tümü" : user,
                    from.HasValue ? from.Value.ToString("dd.MM.yyyy") : "Yok",
                    to.HasValue ? to.Value.ToString("dd.MM.yyyy") : "Yok");

                if (!string.IsNullOrWhiteSpace(export))
                {
                    if (string.Equals(export, "excel", StringComparison.OrdinalIgnoreCase))
                    {
                        var html = BuildSvizeExcelHtml(list, filterInfo);
                        return File(System.Text.Encoding.UTF8.GetBytes(html), "application/vnd.ms-excel; charset=utf-8", "sartli-vize-listesi.xls");
                    }

                    if (string.Equals(export, "pdf", StringComparison.OrdinalIgnoreCase))
                    {
                        var pdfBytes = BuildSvizePdfContent(list, filterInfo);
                        return File(pdfBytes, "application/pdf", "sartli-vize-listesi.pdf");
                    }
                }

                ViewBag.BorderList = db.E_Sartli.AsNoTracking()
                    .Where(x => !string.IsNullOrWhiteSpace(x.fldBorder))
                    .Select(x => x.fldBorder)
                    .Distinct()
                    .OrderBy(x => x)
                    .ToList();

                ViewBag.UserList = db.E_Sartli.AsNoTracking()
                    .Where(x => !string.IsNullOrWhiteSpace(x.fldBy))
                    .Select(x => x.fldBy)
                    .Distinct()
                    .OrderBy(x => x)
                    .ToList();

                ViewBag.SearchText = q ?? string.Empty;
                ViewBag.SelectedBorder = border ?? string.Empty;
                ViewBag.SelectedUser = user ?? string.Empty;
                ViewBag.From = from;
                ViewBag.To = to;
                ViewBag.IsAdmin = true;
                ViewBag.ResultInfo = !hasFilter
                    ? "Filtre uygulanmadığı için son 100 kayıt gösteriliyor."
                    : list.Count + " kayıt listeleniyor.";

                return View(list);
            }
        }

        [Route("OSVIZE")]
        public ActionResult SVIZE(string deneme, string q, string border, string user, DateTime? from, DateTime? to, string export)
        {
            var userdata = GetUser();
            if (userdata == null) return RedirectToAction("Index", "Giris");

            bool isAdmin = IsAdminUser(userdata);
            string userBorder = (userdata.fldBorder ?? string.Empty).Trim();

            using (var db = new GZPEGM1())
            {
                IQueryable<E_Sartli> query = db.E_Sartli.AsNoTracking().Where(x => x.fldDate.HasValue);

                string effectiveBorder;
                if (isAdmin)
                {
                    effectiveBorder = !string.IsNullOrWhiteSpace(border) ? border.Trim() : userBorder;
                }
                else
                {
                    // Kapı personeli: SADECE kendi hudut kapısının verileri gösterilir!
                    effectiveBorder = userBorder;
                }

                if (!string.IsNullOrEmpty(effectiveBorder))
                {
                    query = query.Where(x => x.fldBorder == effectiveBorder);
                }
                else if (!isAdmin)
                {
                    query = query.Where(x => false);
                }

                if (!string.IsNullOrWhiteSpace(user))
                {
                    var selectedUser = user.Trim();
                    query = query.Where(x => x.fldBy == selectedUser);
                }

                if (from.HasValue)
                {
                    var fromDate = from.Value.Date;
                    query = query.Where(x => x.fldDate >= fromDate);
                }

                if (to.HasValue)
                {
                    var toDate = to.Value.Date.AddDays(1).AddTicks(-1);
                    query = query.Where(x => x.fldDate <= toDate);
                }

                if (!string.IsNullOrWhiteSpace(q))
                {
                    var search = q.Trim().ToLower();
                    query = query.Where(x =>
                        (x.fldBy != null && x.fldBy.ToLower().Contains(search)) ||
                        (x.fldBorder != null && x.fldBorder.ToLower().Contains(search)) ||
                        (x.fldName != null && x.fldName.ToLower().Contains(search)) ||
                        (x.fldOrgin != null && x.fldOrgin.ToLower().Contains(search)));
                }

                var filteredList = query.OrderByDescending(x => x.fldDate).ToList();
                var hasFilter = !string.IsNullOrWhiteSpace(q)
                    || !string.IsNullOrWhiteSpace(effectiveBorder)
                    || !string.IsNullOrWhiteSpace(user)
                    || from.HasValue
                    || to.HasValue;

                var list = hasFilter ? filteredList : filteredList.Take(100).ToList();

                var filterInfo = string.Format(
                    "Arama: {0} | Kapı: {1} | Kullanıcı: {2} | Başlangıç: {3} | Bitiş: {4}",
                    string.IsNullOrWhiteSpace(q) ? "Tümü" : q,
                    string.IsNullOrWhiteSpace(effectiveBorder) ? "Tümü" : effectiveBorder,
                    string.IsNullOrWhiteSpace(user) ? "Tümü" : user,
                    from.HasValue ? from.Value.ToString("dd.MM.yyyy") : "Yok",
                    to.HasValue ? to.Value.ToString("dd.MM.yyyy") : "Yok");

                if (!string.IsNullOrWhiteSpace(export))
                {
                    if (string.Equals(export, "excel", StringComparison.OrdinalIgnoreCase))
                    {
                        var html = BuildSvizeExcelHtml(list, filterInfo);
                        return File(System.Text.Encoding.UTF8.GetBytes(html), "application/vnd.ms-excel; charset=utf-8", "sartli-vize-listesi.xls");
                    }

                    if (string.Equals(export, "pdf", StringComparison.OrdinalIgnoreCase))
                    {
                        var pdfBytes = BuildSvizePdfContent(list, filterInfo);
                        return File(pdfBytes, "application/pdf", "sartli-vize-listesi.pdf");
                    }
                }

                if (isAdmin)
                {
                    ViewBag.BorderList = db.E_Sartli.AsNoTracking()
                        .Where(x => !string.IsNullOrWhiteSpace(x.fldBorder))
                        .Select(x => x.fldBorder)
                        .Distinct()
                        .OrderBy(x => x)
                        .ToList();
                }
                else
                {
                    ViewBag.BorderList = !string.IsNullOrEmpty(userBorder)
                        ? new List<string> { userBorder }
                        : new List<string>();
                }

                ViewBag.UserList = db.E_Sartli.AsNoTracking()
                    .Where(x => x.fldBorder == effectiveBorder && !string.IsNullOrWhiteSpace(x.fldBy))
                    .Select(x => x.fldBy)
                    .Distinct()
                    .OrderBy(x => x)
                    .ToList();

                ViewBag.SearchText = q ?? string.Empty;
                ViewBag.SelectedBorder = effectiveBorder;
                ViewBag.SelectedUser = user ?? string.Empty;
                ViewBag.From = from;
                ViewBag.To = to;
                ViewBag.IsAdmin = isAdmin;
                ViewBag.UserBorder = userBorder;
                ViewBag.ResultInfo = !hasFilter
                    ? "Filtre uygulanmadığı için son 100 kayıt gösteriliyor."
                    : list.Count + " kayıt listeleniyor.";

                return View(list);
            }
        }
    }
}
