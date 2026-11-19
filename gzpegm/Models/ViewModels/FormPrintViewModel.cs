using System;
using System.Text.RegularExpressions;

namespace gzpegm.Models.ViewModels
{
    public class FormPrintViewModel
    {
        public string PassengerName { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string FatherName { get; set; }
        public string MotherName { get; set; }
        public string Nationality { get; set; }
        public string PassportNo { get; set; }
        public string Birthdate { get; set; }
        public string CommunicationLanguage { get; set; }

        public string EntryDate { get; set; }
        public string ApplicationDate { get; set; }
        public string ShouldExitDate { get; set; }
        public string CanEnterDate { get; set; }
        public string VisaDistanceDays { get; set; }
        public string ViolationPeriod { get; set; }
        public string FineAmount { get; set; }
        public string FinePriceTotal { get; set; }
        public string DefterPrice { get; set; }
        public string TahditCode { get; set; }
        public string EntryBanDays { get; set; }

        public string PoliceOfficer { get; set; }
        public string ApprovalUser { get; set; }
        public string BorderGate { get; set; }
        public string Province { get; set; }
        public string Today { get; set; }
        public string CurrentTime { get; set; }

        public bool IsPaid { get; set; }
        public bool IsAdult { get; set; }
        public bool IsOver90 { get; set; }
        public bool HasCKodlu { get; set; }
        public bool HasNKodlu { get; set; }

        public string LanguageCode { get; set; } // "GB", "RU", "DE", "FR", "IR", "IRK", "Cin", "Yunan"
        public string QrText { get; set; }

        public string FineBreakdown { get; set; }
        public string FineTotalAmount { get; set; }

        public string RenderFineAmountHtml()
        {
            if (!string.IsNullOrWhiteSpace(FineTotalAmount))
            {
                var sb = new System.Text.StringBuilder();
                sb.Append("<div class=\"fine-amount-wrap\">");
                if (!string.IsNullOrWhiteSpace(FineBreakdown))
                {
                    sb.Append($"<span class=\"fine-breakdown\">{FineBreakdown}</span>");
                }
                sb.Append($"<strong class=\"fine-total-badge\">{FineTotalAmount}</strong>");
                sb.Append("</div>");
                return sb.ToString();
            }

            return ParseLegacyFineAmount(FineAmount, FinePriceTotal);
        }

        public static string ParseLegacyFineAmount(string fineAmount, string finePriceTotal)
        {
            if (string.IsNullOrWhiteSpace(fineAmount))
            {
                if (!string.IsNullOrWhiteSpace(finePriceTotal))
                {
                    return $"<div class=\"fine-amount-wrap\"><strong class=\"fine-total-badge\">Toplam = {finePriceTotal.Trim()} TL</strong></div>";
                }
                return "-";
            }

            if (fineAmount.Contains("fine-total-badge"))
            {
                return fineAmount;
            }

            string raw = fineAmount.Trim();
            if (raw.EndsWith("TL", StringComparison.OrdinalIgnoreCase))
            {
                raw = raw.Substring(0, raw.Length - 2).Trim();
            }

            int topIdx = raw.IndexOf("Toplam=", StringComparison.OrdinalIgnoreCase);
            if (topIdx < 0) topIdx = raw.IndexOf("Toplam:", StringComparison.OrdinalIgnoreCase);
            if (topIdx < 0) topIdx = raw.IndexOf("Toplam", StringComparison.OrdinalIgnoreCase);

            if (topIdx >= 0)
            {
                string detailPart = raw.Substring(0, topIdx).Trim().TrimEnd(',', ';');
                string totalPart = raw.Substring(topIdx).Trim();

                string totalVal = "";
                int eqIdx = totalPart.IndexOfAny(new char[] { '=', ':' });
                if (eqIdx >= 0)
                {
                    totalVal = totalPart.Substring(eqIdx + 1).Trim();
                }
                else
                {
                    totalVal = totalPart.Replace("Toplam", "").Trim();
                }
                if (totalVal.EndsWith("TL", StringComparison.OrdinalIgnoreCase))
                {
                    totalVal = totalVal.Substring(0, totalVal.Length - 2).Trim();
                }

                string formattedDetail = CleanLegacyDetail(detailPart, totalVal);

                var sb = new System.Text.StringBuilder();
                sb.Append("<div class=\"fine-amount-wrap\">");
                if (!string.IsNullOrWhiteSpace(formattedDetail))
                {
                    sb.Append($"<span class=\"fine-breakdown\">{formattedDetail}</span>");
                }
                sb.Append($"<strong class=\"fine-total-badge\">Toplam = {totalVal} TL</strong>");
                sb.Append("</div>");
                return sb.ToString();
            }
            else
            {
                string cleanVal = raw;
                cleanVal = Regex.Replace(cleanVal, @"\+\s*DEF", " + DEF", RegexOptions.IgnoreCase);
                cleanVal = Regex.Replace(cleanVal, @"\+\s*N-96", " + N-96", RegexOptions.IgnoreCase);
                return $"<div class=\"fine-amount-wrap\"><strong class=\"fine-total-badge\">{cleanVal.Trim()} TL</strong></div>";
            }
        }

        private static string CleanLegacyDetail(string detail, string total)
        {
            if (string.IsNullOrWhiteSpace(detail)) return "";

            string numOnly = Regex.Replace(detail, @"[^\d,.]", "").Trim();
            string totalNumOnly = Regex.Replace(total, @"[^\d,.]", "").Trim();
            if (numOnly == totalNumOnly && !detail.Contains("+") && !detail.Contains("DEF") && !detail.Contains("İdari") && !detail.Contains("idari"))
            {
                return "";
            }

            string s = detail;
            s = Regex.Replace(s, @"\+\s*DEF\s*(\d+)\s*(?:TL)?", " + DEF $1 TL", RegexOptions.IgnoreCase);
            s = Regex.Replace(s, @"(?:,\s*)?İdari\s*para\s*cezası:\s*(\d+)\s*(?:TL)?", " + İdari Para Cezası: $1 TL", RegexOptions.IgnoreCase);

            s = s.Trim().TrimEnd(',', ';');
            if (s.StartsWith("+")) s = s.Substring(1).Trim();
            s = Regex.Replace(s, @"\s+", " ");
            return s;
        }
    }
}
