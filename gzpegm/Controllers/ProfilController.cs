using CryptoHelper;
using gzpegm.Cont;
using gzpegm.Helpers;
using gzpegm.Models;
using System;
using System.IO;
using System.Linq;
using System.Data.Entity;
using System.Web;
using System.Web.Mvc;
using System.Collections.Generic;
using gzpegm.Models.ViewModels;

namespace gzpegm.Controllers
{
    [UserAuthorize]
    public class ProfileController : Controller
    {
        private readonly GZPEGM1 db = new GZPEGM1();

        private int? GetCurrentUserId()
        {
            HttpCookie cookie = Request.Cookies["Token"];
            if (cookie == null) return null;

            Token token = new Token();
            var tokenData = token.GetToken(cookie.Value);
            if (tokenData == null) return null;

            return tokenData.fldUserId;
        }

        [HttpGet]
        [Route("Profil")]
        public ActionResult Index()
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return RedirectToAction("Index", "Giris");

            var user = db.E_User.FirstOrDefault(x => x.fldId == userId);
            if (user == null)
                return RedirectToAction("Index", "Giris");

            try
            {
                // prepare statistics for profile view
                string fullname = (user.fldName ?? "").Trim() + " " + (user.fldLastName ?? "").Trim();
                string sicil = (user.fldSicil ?? "").Trim();

                // load all history rows that have a fldUser (we will match user ownership in-memory)
                var allWithUser = db.E_History
                    .Where(h => h.fldUser != null)
                    .ToList();

                // match records that belong to this user (by sicil or fullname or plain sicil)
                var matched = allWithUser.Where(h =>
                {
                    var fu = (h.fldUser ?? "").Trim();
                    if (string.IsNullOrEmpty(fu)) return false;
                    var ns = fu.ToLowerInvariant();
                    if (!string.IsNullOrEmpty(sicil))
                    {
                        var nsicil = sicil.ToLowerInvariant();
                        if (ns.StartsWith(nsicil + "|")) return true;
                        if (ns == nsicil) return true; // plain sicil stored
                        // also accept pipe-split first token equals sicil
                        var idx = ns.IndexOf('|');
                        if (idx > 0)
                        {
                            var first = ns.Substring(0, idx).Trim();
                            if (first == nsicil) return true;
                        }
                    }
                    if (!string.IsNullOrEmpty(fullname) && ns == fullname.ToLowerInvariant()) return true;
                    return false;
                }).ToList();

                // group matched histories by border so we can show per-border counts
                var groupedByBorder = matched
                    .GroupBy(h => (h.fldBorder ?? "-"))
                    .Select(g => new { Border = g.Key, Count = g.Count(), Items = g.ToList() })
                    .OrderByDescending(x => x.Count)
                    .ToList();

                // current border-specific histories (used for main stats)
                var currentHistories = groupedByBorder.Where(g => string.Equals(g.Border, user.fldBorder, StringComparison.OrdinalIgnoreCase))
                    .SelectMany(g => g.Items).ToList();

                // if user has no entries in current border, currentHistories will be empty
                ViewBag.TotalHistory = currentHistories.Count;

                // most active day (based on currentHistories)
                var mostActive = currentHistories
                    .Where(h => h.fldDatetime.HasValue)
                    .GroupBy(h => h.fldDatetime.Value.Date)
                    .Select(g => new { Date = g.Key, Count = g.Count() })
                    .OrderByDescending(x => x.Count)
                    .FirstOrDefault();
                ViewBag.MostActiveDay = mostActive != null ? mostActive.Date.ToString("dd.MM.yyyy") : null;
                ViewBag.MostActiveDayCount = mostActive != null ? mostActive.Count : 0;

                // total penalty amount (try parse fldPMoney)
                decimal totalPenalty = 0;
                foreach (var h in currentHistories)
                {
                    var s = (h.fldPMoney ?? "").Trim();
                    if (string.IsNullOrEmpty(s)) continue;
                    // try to extract numeric from string
                    var cleaned = System.Text.RegularExpressions.Regex.Replace(s, "[^0-9,.-]", "");
                    cleaned = cleaned.Replace(',', '.');
                    if (decimal.TryParse(cleaned, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out var val))
                        totalPenalty += val;
                }
                ViewBag.TotalPenalty = totalPenalty;

                // rank among personnel by total penalty within same border (use allWithUser filtered to same border)
                var perSicilSums = allWithUser
                    .Where(h => string.Equals(h.fldBorder, user.fldBorder, StringComparison.OrdinalIgnoreCase) && h.fldUser != null)
                    .ToList()
                    .Select(h => new { h.fldUser, h.fldPMoney })
                    .Select(item => new { Sicil = (item.fldUser ?? "").Split('|').FirstOrDefault()?.Trim(), Money = item.fldPMoney })
                    .Where(x => !string.IsNullOrEmpty(x.Sicil))
                    .GroupBy(x => x.Sicil)
                    .Select(g => new
                    {
                        Sicil = g.Key,
                        Sum = g.Sum(z =>
                        {
                            var cleaned = System.Text.RegularExpressions.Regex.Replace((z.Money ?? ""), "[^0-9,.-]", "").Replace(',', '.');
                            if (decimal.TryParse(cleaned, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out var v)) return v;
                            return 0;
                        })
                    })
                    .OrderByDescending(x => x.Sum)
                    .ToList();

                int rank = -1;
                for (int i = 0; i < perSicilSums.Count; i++)
                {
                    if (string.Equals(perSicilSums[i].Sicil, sicil, StringComparison.OrdinalIgnoreCase)) { rank = i + 1; break; }
                }
                ViewBag.PenaltyRank = rank > 0 ? rank : (int?)null;

                // top country where user applied penalties (based on currentHistories)
                var topCountry = currentHistories
                    .GroupBy(h => (h.fldCountry ?? "-"))
                    .Select(g => new { Country = g.Key, Count = g.Count(), Sum = g.Sum(h =>
                    {
                        var cleaned = System.Text.RegularExpressions.Regex.Replace((h.fldPMoney ?? ""), "[^0-9,.-]", "").Replace(',', '.');
                        if (decimal.TryParse(cleaned, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out var v)) return v;
                        return 0;
                    }) })
                    .OrderByDescending(x => x.Count)
                    .FirstOrDefault();
                if (topCountry != null)
                {
                    ViewBag.TopCountry = topCountry.Country;
                    ViewBag.TopCountryCount = topCountry.Count;
                }

                // E_Inad stats (use Sicil field)
                var inadQuery = db.E_Inad.AsQueryable();
                if (!string.IsNullOrEmpty(sicil)) inadQuery = inadQuery.Where(i => i.Sicil == sicil);
                var inadTop = inadQuery
                    .GroupBy(i => new { Country = i.GeldigiYer, Reason = i.InadSebep })
                    .Select(g => new { g.Key.Country, g.Key.Reason, Count = g.Count() })
                    .OrderByDescending(x => x.Count)
                    .FirstOrDefault();
                if (inadTop != null)
                {
                    ViewBag.InadTopCountry = inadTop.Country;
                    ViewBag.InadTopReason = inadTop.Reason;
                    ViewBag.InadTopCount = inadTop.Count;
                }

                // Other posts are based on the logged-in staff member's E_IsK operations.
                var staffOperations = db.E_IsK.AsNoTracking()
                    .Where(x => x.fldApproval == fullname && x.fldBorder != null)
                    .ToList();
                var borderStats = new List<ProfileBorderStat>();
                foreach (var g in staffOperations
                    .Where(x => !string.Equals(x.fldBorder, user.fldBorder, StringComparison.OrdinalIgnoreCase))
                    .GroupBy(x => x.fldBorder)
                    .OrderByDescending(x => x.Count()))
                {
                    var most = g.Where(h => h.fldDatetime.HasValue)
                        .GroupBy(h => h.fldDatetime.Value.Date)
                        .Select(x => new { Date = x.Key, Count = x.Count() })
                        .OrderByDescending(x => x.Count).FirstOrDefault();
                    string mostDay = most != null ? most.Date.ToString("dd.MM.yyyy") : null;

                    var sum = g.Sum(h => ParseProfileMoney(h.fldPMoney));
                    borderStats.Add(new ProfileBorderStat
                    {
                        Border = g.Key,
                        Count = g.Count(),
                        Sum = sum,
                        MostActiveDay = mostDay,
                        Samples = new List<ProfileSample>()
                    });
                }

                ViewBag.BorderHistory = borderStats;

                // courses/enrollments and exam results
                var enrolledCount = db.CourseEnrollments.Count(e => e.UserId == user.fldId);
                var examCount = db.ExamResult.Count(er => er.UserId == user.fldId);
                ViewBag.EnrolledCoursesCount = enrolledCount;
                ViewBag.ExamResultsCount = examCount;

                // load borders for dropdown
                ViewBag.Borders = db.E_Border.OrderBy(b => b.fldName).ToList();

                // last message
                var lastMessage = db.E_Messages.Where(m => m.fldRecipientId == user.fldId && m.fldIsDeletedByRecipient == false)
                    .OrderByDescending(m => m.fldDateTime).FirstOrDefault();
                if (lastMessage != null)
                {
                    ViewBag.LastMessageSubject = lastMessage.fldSubject;
                    ViewBag.LastMessageText = lastMessage.fldMessage;
                    ViewBag.LastMessageDate = lastMessage.fldDateTime;
                }

                // small chart: last 12 months history counts for this user
                var monthCounts = new List<int>();
                for (int m = 11; m >= 0; m--)
                {
                    var from = DateTime.Now.AddMonths(-m);
                    var start = new DateTime(from.Year, from.Month, 1);
                    var end = start.AddMonths(1);
                    var cnt = currentHistories.Count(h => h.fldDatetime.HasValue && h.fldDatetime.Value >= start && h.fldDatetime.Value < end);
                    monthCounts.Add(cnt);
                }
                ViewBag.HistoryChart = monthCounts;
                ViewBag.TahditStats = new TahditFormLogService().GetStatistics(null, null, null, user.fldId, user.fldSicil);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Profile stats error: " + ex.Message);
            }

            return View("~/Views/Profil/Index.cshtml", user);
        }

        [HttpGet]
        [Route("Profil/HudutGecmisi")]
        public ActionResult BorderHistory(string border, int page = 1)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return RedirectToAction("Index", "Giris");

            var user = db.E_User.FirstOrDefault(x => x.fldId == userId);
            if (user == null)
                return RedirectToAction("Index", "Giris");
            if (string.IsNullOrWhiteSpace(border))
                return HttpNotFound();

            border = border.Trim();
            const int pageSize = 25;
            var operations = GetBorderOperations(border);
            var total = operations.Count;
            var totalPages = Math.Max(1, (int)Math.Ceiling(total / (double)pageSize));
            page = Math.Max(1, Math.Min(page, totalPages));

            ViewBag.Border = border;
            ViewBag.Page = page;
            ViewBag.PageSize = pageSize;
            ViewBag.TotalPages = totalPages;
            ViewBag.Total = total;

            var pageItems = operations.Skip((page - 1) * pageSize).Take(pageSize).ToList();
            return View("~/Views/Profil/BorderHistory.cshtml", pageItems);
        }

        private List<BorderOperationViewModel> GetBorderOperations(string border)
        {
            var records = db.E_IsK.AsNoTracking()
                .Where(x => x.fldBorder == border)
                .OrderByDescending(x => x.fldDatetime)
                .ThenByDescending(x => x.fldId)
                .ToList()
                .Where(x => string.Equals(x.fldBorder ?? "", border, StringComparison.OrdinalIgnoreCase))
                .ToList();

            var tahditLogs = new List<TahditFormLog>();
            var datedRecords = records.Where(x => x.fldDatetime.HasValue).ToList();
            if (datedRecords.Count > 0)
            {
                var start = datedRecords.Min(x => x.fldDatetime.Value).AddMinutes(-2);
                var end = datedRecords.Max(x => x.fldDatetime.Value).AddMinutes(2);
                tahditLogs = new TahditFormLogService().GetEntries(border, start, end);
            }

            return records.Select(record =>
            {
                var matchingLog = record.fldDatetime.HasValue
                    ? tahditLogs
                        .Where(log => IsMatchingTahditLog(record, log))
                        .OrderBy(log => Math.Abs((log.CreatedAt - record.fldDatetime.Value).Ticks))
                        .FirstOrDefault()
                    : null;

                return new BorderOperationViewModel
                {
                    Id = record.fldId,
                    Date = record.fldDatetime,
                    PassengerName = record.fldName,
                    Nationality = record.fldOrgin,
                    Amount = record.fldPMoney,
                    Visa = record.fldVisa,
                    TahditCode = matchingLog != null ? matchingLog.TahditCode : null,
                    AdministrativeTahditCode = matchingLog != null ? matchingLog.IdariTahditCode : null,
                    Officer = record.fldApproval
                };
            }).ToList();
        }

        private static bool IsMatchingTahditLog(E_IsK record, TahditFormLog log)
        {
            if (!string.Equals(record.fldBorder ?? "", log.Border ?? "", StringComparison.OrdinalIgnoreCase))
                return false;
            if (!string.Equals(NormalizeOperationMatchValue(record.fldName), NormalizeOperationMatchValue(log.PassengerName), StringComparison.Ordinal))
                return false;
            if (!string.IsNullOrWhiteSpace(record.fldPassport) &&
                !string.Equals(NormalizeOperationMatchValue(record.fldPassport), NormalizeOperationMatchValue(log.PassportNo), StringComparison.Ordinal))
                return false;
            if (!string.IsNullOrWhiteSpace(record.fldApproval) &&
                !string.IsNullOrWhiteSpace(log.UserDisplayName) &&
                !string.Equals(NormalizeOperationMatchValue(record.fldApproval), NormalizeOperationMatchValue(log.UserDisplayName), StringComparison.Ordinal))
                return false;

            return record.fldDatetime.HasValue
                && Math.Abs((log.CreatedAt - record.fldDatetime.Value).TotalMinutes) <= 2;
        }

        private static string NormalizeOperationMatchValue(string value)
        {
            return string.Concat((value ?? "").Where(c => !char.IsWhiteSpace(c))).ToUpperInvariant();
        }

        private static decimal ParseProfileMoney(string value)
        {
            decimal amount;
            if (decimal.TryParse(value, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.GetCultureInfo("tr-TR"), out amount))
                return amount;
            if (decimal.TryParse(value, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out amount))
                return amount;

            var cleaned = System.Text.RegularExpressions.Regex.Replace(value ?? "", "[^0-9,.-]", "");
            cleaned = cleaned.Replace(".", "").Replace(',', '.');
            return decimal.TryParse(cleaned, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out amount)
                ? amount
                : 0m;
        }

        private static void AddProfilePdfHeader(iTextSharp.text.pdf.PdfPTable table, string text, iTextSharp.text.pdf.BaseFont baseFont)
        {
            var headerFont = new iTextSharp.text.Font(baseFont, 9, iTextSharp.text.Font.BOLD, iTextSharp.text.BaseColor.WHITE);
            var cell = new iTextSharp.text.pdf.PdfPCell(new iTextSharp.text.Phrase(text, headerFont))
            {
                BackgroundColor = new iTextSharp.text.BaseColor(31, 78, 121),
                Padding = 5f
            };
            table.AddCell(cell);
        }

        private static void AddProfilePdfCell(
            iTextSharp.text.pdf.PdfPTable table,
            string text,
            iTextSharp.text.Font font,
            int horizontalAlignment = iTextSharp.text.Element.ALIGN_LEFT)
        {
            var cell = new iTextSharp.text.pdf.PdfPCell(new iTextSharp.text.Phrase(text ?? "-", font))
            {
                HorizontalAlignment = horizontalAlignment,
                Padding = 5f
            };
            table.AddCell(cell);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult SaveProfile(
            HttpPostedFileBase PictureFile,
            string currentpass,
            string newpass,
            string confirmpass,
            string fldName,
            string fldLastName,
            string fldPhone,
            string fldEmail,
            string fldTitle,
            string fldDeputy)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return RedirectToAction("Index", "Giris");

            var user = db.E_User.FirstOrDefault(x => x.fldId == userId);
            if (user == null)
                return RedirectToAction("Index", "Giris");

            // ================= KİMLİK BİLGİLERİ =================
            if (!string.IsNullOrWhiteSpace(fldName))
                user.fldName = fldName.Trim();

            if (!string.IsNullOrWhiteSpace(fldLastName))
                user.fldLastName = fldLastName.Trim();

            if (!string.IsNullOrWhiteSpace(fldPhone))
                user.fldPhone = fldPhone.Trim();

            if (!string.IsNullOrWhiteSpace(fldEmail))
                user.fldEmail = fldEmail.Trim();

            if (!string.IsNullOrWhiteSpace(fldTitle))
                user.fldTitle = fldTitle.Trim();

            if (!string.IsNullOrWhiteSpace(fldDeputy))
                user.fldDeputy = fldDeputy.Trim();

            // fldBorder may come from dropdown - allow empty/null
            var fldBorder = Request.Form["fldBorder"];
            if (!string.IsNullOrWhiteSpace(fldBorder)) user.fldBorder = fldBorder.Trim();

            // ================= FOTO =================
            if (PictureFile != null && PictureFile.ContentLength > 0)
            {
                string[] allowedExt = { ".jpg", ".jpeg", ".png", ".gif" };
                string ext = Path.GetExtension(PictureFile.FileName)?.ToLower();

                if (!allowedExt.Contains(ext))
                {
                    TempData["msgError"] = "Geçersiz resim formatı.";
                    return RedirectToAction("Index");
                }

                if (PictureFile.ContentLength > 2 * 1024 * 1024)
                {
                    TempData["msgError"] = "Resim 2MB'den büyük olamaz.";
                    return RedirectToAction("Index");
                }

                string folder = FileStorageHelper.MapPath(Server, "~/files/User/");
                if (!folder.EndsWith(Path.DirectorySeparatorChar.ToString()))
                    folder += Path.DirectorySeparatorChar;
                Directory.CreateDirectory(folder);

                if (!string.IsNullOrEmpty(user.fldPicture))
                {
                    string old = Path.Combine(folder, user.fldPicture);
                    if (System.IO.File.Exists(old))
                        System.IO.File.Delete(old);
                }

                string fileName = Guid.NewGuid().ToString("N") + ext;
                PictureFile.SaveAs(Path.Combine(folder, fileName));
                user.fldPicture = fileName;
            }

            // ================= ŞİFRE =================
            bool wantsPasswordChange =
                !string.IsNullOrWhiteSpace(currentpass) ||
                !string.IsNullOrWhiteSpace(newpass) ||
                !string.IsNullOrWhiteSpace(confirmpass);

            if (wantsPasswordChange)
            {
                if (string.IsNullOrWhiteSpace(currentpass) ||
                    string.IsNullOrWhiteSpace(newpass) ||
                    string.IsNullOrWhiteSpace(confirmpass))
                {
                    TempData["msgError"] = "Tüm şifre alanları doldurulmalıdır.";
                    return RedirectToAction("Index");
                }

                if (!Crypto.VerifyHashedPassword(user.fldPassword, currentpass))
                {
                    TempData["msgError"] = "Mevcut şifre yanlış.";
                    return RedirectToAction("Index");
                }

                if (newpass != confirmpass)
                {
                    TempData["msgError"] = "Yeni şifreler uyuşmuyor.";
                    return RedirectToAction("Index");
                }

                user.fldPassword = Crypto.HashPassword(newpass);
            }

            db.SaveChanges();
            TempData["msgSuccess"] = "Profil başarıyla güncellendi.";
            return RedirectToAction("Index");
        }

        [HttpGet]
        public ActionResult ExportBorderPdf(string border)
        {
            var userId = GetCurrentUserId();
            if (userId == null) return new HttpStatusCodeResult(401);

            var user = db.E_User.FirstOrDefault(x => x.fldId == userId);
            if (user == null) return new HttpStatusCodeResult(401);
            if (string.IsNullOrWhiteSpace(border)) return new HttpStatusCodeResult(400);

            var operations = GetBorderOperations(border.Trim());

            using (var stream = new MemoryStream())
            {
                var document = new iTextSharp.text.Document(iTextSharp.text.PageSize.A4.Rotate(), 24, 24, 24, 24);
                iTextSharp.text.pdf.PdfWriter.GetInstance(document, stream);
                document.Open();

                var fontPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Fonts), "arial.ttf");
                var baseFont = iTextSharp.text.pdf.BaseFont.CreateFont(
                    fontPath,
                    iTextSharp.text.pdf.BaseFont.IDENTITY_H,
                    iTextSharp.text.pdf.BaseFont.EMBEDDED);
                var titleFont = new iTextSharp.text.Font(baseFont, 15, iTextSharp.text.Font.BOLD, new iTextSharp.text.BaseColor(31, 78, 121));
                var infoFont = new iTextSharp.text.Font(baseFont, 9);
                var cellFont = new iTextSharp.text.Font(baseFont, 8);

                document.Add(new iTextSharp.text.Paragraph("Hudut Kapısı İşlem Dökümü", titleFont));
                document.Add(new iTextSharp.text.Paragraph("Hudut Kapısı: " + border.Trim(), infoFont));
                document.Add(new iTextSharp.text.Paragraph("Oluşturulma tarihi: " + DateTime.Now.ToString("dd.MM.yyyy HH:mm"), infoFont));
                document.Add(new iTextSharp.text.Paragraph(" "));

                var table = new iTextSharp.text.pdf.PdfPTable(9) { WidthPercentage = 100, HeaderRows = 1 };
                table.SetWidths(new float[] { 6f, 13f, 17f, 10f, 9f, 11f, 10f, 10f, 14f });
                AddProfilePdfHeader(table, "Kayıt No", baseFont);
                AddProfilePdfHeader(table, "Tarih", baseFont);
                AddProfilePdfHeader(table, "Ad Soyad", baseFont);
                AddProfilePdfHeader(table, "Uyruk", baseFont);
                AddProfilePdfHeader(table, "Tutar", baseFont);
                AddProfilePdfHeader(table, "Vize", baseFont);
                AddProfilePdfHeader(table, "Tahdit", baseFont);
                AddProfilePdfHeader(table, "İdari Tahdit", baseFont);
                AddProfilePdfHeader(table, "Görevli", baseFont);

                foreach (var item in operations)
                {
                    AddProfilePdfCell(table, item.Id.ToString(), cellFont);
                    AddProfilePdfCell(table, item.Date.HasValue ? item.Date.Value.ToString("dd.MM.yyyy HH:mm") : "-", cellFont);
                    AddProfilePdfCell(table, item.PassengerName, cellFont);
                    AddProfilePdfCell(table, item.Nationality, cellFont);
                    AddProfilePdfCell(table, item.Amount, cellFont);
                    AddProfilePdfCell(table, item.Visa, cellFont);
                    AddProfilePdfCell(table, item.TahditCode, cellFont);
                    AddProfilePdfCell(table, item.AdministrativeTahditCode, cellFont);
                    AddProfilePdfCell(table, item.Officer, cellFont);
                }

                if (!operations.Any())
                {
                    var emptyCell = new iTextSharp.text.pdf.PdfPCell(new iTextSharp.text.Phrase("Bu hudut kapısı için işlem kaydı bulunamadı.", cellFont))
                    {
                        Colspan = 9,
                        Padding = 5f
                    };
                    table.AddCell(emptyCell);
                }

                document.Add(table);
                document.Close();
                return File(stream.ToArray(), "application/pdf", "hudut-kapisi-islemleri-" + DateTime.Now.ToString("yyyyMMdd") + ".pdf");
            }
        }

        [HttpGet]
        public ActionResult ExportBorderCsv(string border)
        {
            var userId = GetCurrentUserId();
            if (userId == null) return new HttpStatusCodeResult(401);
            var user = db.E_User.FirstOrDefault(x => x.fldId == userId);
            if (user == null) return new HttpStatusCodeResult(401);
            if (string.IsNullOrWhiteSpace(border)) return new HttpStatusCodeResult(400);

            var operations = GetBorderOperations(border.Trim());

            var sb = new System.Text.StringBuilder();
            sb.AppendLine("Kayıt No;Tarih;Ad Soyad;Uyruk;Tutar;Vize;Tahdit;İdari Tahdit;Görevli");
            foreach (var item in operations)
            {
                var fields = new[]
                {
                    item.Id.ToString(),
                    item.Date.HasValue ? item.Date.Value.ToString("dd.MM.yyyy HH:mm") : "",
                    item.PassengerName,
                    item.Nationality,
                    item.Amount,
                    item.Visa,
                    item.TahditCode,
                    item.AdministrativeTahditCode,
                    item.Officer
                };
                sb.AppendLine(string.Join(";", fields.Select(EscapeCsvField)));
            }

            var bytes = new System.Text.UTF8Encoding(true).GetBytes(sb.ToString());
            var fileName = string.Format("border_operations_{0}.csv", DateTime.Now.ToString("yyyyMMddHHmm"));
            return File(bytes, "text/csv; charset=utf-8", fileName);
        }

        private static string EscapeCsvField(string value)
        {
            return "\"" + (value ?? "").Replace("\"", "\"\"") + "\"";
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing) db?.Dispose();
            base.Dispose(disposing);
        }
    }
}