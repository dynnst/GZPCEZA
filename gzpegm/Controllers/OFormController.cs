using gzpegm.Cont;
using gzpegm.Helpers;
using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Web;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    public class OFormController : Controller
    {
        [Route("Formyazdir/{Id:int}")]
        public ActionResult Index(int Id)
        {
            string Result = "";
            Isk Isk = new Isk();
            var data = Isk.GetdatabyId(Id);
            if (data != null)
            {
                Result = data.fldForm;
                ViewBag.QrText = "T.C. ICISLERI BAKANLIGI EGM\n" +
                                 "Yolcu: " + (data.fldName ?? "-") + "\n" +
                                 "Pasaport: " + (data.fldPassport ?? "-") + "\n" +
                                 "Uyruk: " + (data.fldOrgin ?? "-") + "\n" +
                                 "Ceza Tutari: " + (data.fldPMoney ?? "-") + " TL\n" +
                                 "Hudut Kapisi: " + (data.fldBorder ?? "-") + "\n" +
                                 "Gorevli Memur: " + (data.fldPassControl ?? "-") + "\n" +
                                 "Tarih: " + (data.fldDatetime.HasValue ? data.fldDatetime.Value.ToString("dd.MM.yyyy HH:mm") : "-");
            }
            ViewBag.Form = Result;
            return View();
        }
        [Route("Formolustur")]
        public ActionResult Index(string OrginCFORM, string IDNCFORM, string EntryDateCFORM, string VisaDistanceCFORM, string ShouldExitCFORM, string FineDayCFORM, string FinePriceCFORM, string PaymentTypeCFORM, string NameCFORM, string PassportCFORM, string PoliceCFORM, string DDayCFORM, string DefterCFORM, string CGunCFORM, string CAyCFORM, string FatherCFORM, string MotherCFORM, DateTime BirthdateCFORM, string codeFORM, int visatype, HttpPostedFileBase coverinputpd)
        {
            string[] Vizeler = new string[16] { "", "Vizeli", "Vizesiz", "Konsolosluk Vizeli-Transit Yolcu", "İkamet Teskereli", "Türkiye'de Doğan", "Resmi Görevli", "İkamet Şartlı Giriş (V-84)", "Çalışma İzni", "V-157 Tahditli Şahıslar", "V-69 Tahditli Şahıslar", "V-137 Vize Süresiz Tahditli Şahıslar", "V-88 Tahditli Şahıslar", "V-137 Vize Süreli", "İkamet Teskereli V-157 Tahditli", "V-69 Tebliğ Tarihi İçinde Gelen Tahditli Şahıslar" };
            double Idari = 11409;
            bool adult;
            int age = DateTime.Now.Year - BirthdateCFORM.Year;
            if (DateTime.Now.Month < BirthdateCFORM.Month || (DateTime.Now.Month == BirthdateCFORM.Month && DateTime.Now.Day < BirthdateCFORM.Day)) age--;
            if (age > 17) adult = true;
            else adult = false;
            HttpCookie UserCookie;
            UserCookie = Request.Cookies["Token"];
            Token token = new Token();
            gzpegm.Cont.User user = new User();
            int UserId = 0;
            if (UserCookie != null)
            {
                var tokendata = token.GetToken(UserCookie.Value.ToString());
                if (tokendata != null)
                {
                    int.TryParse(tokendata.fldUserId.ToString(), out UserId);
                }
            }
            var Data = user.GetUserById(UserId);
            ContFormT formT = new ContFormT();
            string result = "",
            Adı = "",
                      Soyadı = "";
            if (NameCFORM.LastIndexOf(" ") > 0) { Adı = NameCFORM.Substring(0, NameCFORM.LastIndexOf(" ")); Soyadı = NameCFORM.Substring(NameCFORM.LastIndexOf(" ")); }
            else { Adı = NameCFORM; Soyadı = NameCFORM; }
            string FINET = "";
            FINET = (Convert.ToDouble(FinePriceCFORM) - Convert.ToDouble(DefterCFORM)).ToString();
            if (PaymentTypeCFORM == "5" || PaymentTypeCFORM == "4") FINET = (Convert.ToDouble(FINET) - Idari).ToString();

            // DÜZELTME: PaymentTypeCFORM değerindeki boşluk hatası ve "Ödemeyen" (0) için istenen format
            var payType = (PaymentTypeCFORM ?? "").Trim();
            var nonPaying = new HashSet<string> { "0", "3", "5", "7", "9", "11", "15" };

            if (nonPaying.Contains(payType))
            {
                // Ödemeyen grubu: sadece temel ceza + DEF gösterilsin. Örneğin: "1324,8+DEF"
                if (Convert.ToDouble(DefterCFORM) != 0)
                {
                    FINET += "+DEF";
                }

                // Özel not gerekiyorsa (ör. PaymentType 5 için) ek bilgi ekle (istenirse araya boşluk koyabilirsiniz)
                if (payType == "5")
                {
                    FINET += "+N-96(6458/56/1-102/1-c)";
                }
            }
            else
            {
                // Diğer ödeme türleri mevcut davranışı korur (Toplam=... eklenir)
                if (Convert.ToDouble(DefterCFORM) != 0)
                {
                    if (payType == "4") FINET += "+ DEF" + DefterCFORM + "TL İdari para cezası: " + Idari.ToString() + " TL, Toplam=" + FinePriceCFORM;
                    else FINET += "+ DEF" + DefterCFORM + "TL Toplam=" + FinePriceCFORM;
                }
                else
                {
                    if (payType == "4") FINET += " İdari para cezası: " + Idari.ToString() + " TL, Toplam=" + FinePriceCFORM;
                    else FINET += " Toplam=" + FinePriceCFORM;
                }
            }
            bool isPaid = (PaymentTypeCFORM == "1" || PaymentTypeCFORM == "2" || PaymentTypeCFORM == "10" || PaymentTypeCFORM == "8" || PaymentTypeCFORM == "6" || PaymentTypeCFORM == "14" || PaymentTypeCFORM == "4");
            var allForms = formT.GetAllForms();
            string template = "";

            if (OrginCFORM == "Rusya Federasyonu" || OrginCFORM == "Ukrayna" || OrginCFORM == "Rusya" || OrginCFORM == "Russia" || OrginCFORM == "Ukraine")
            {
                template = isPaid ? allForms.fldRUC : allForms.fldRU;
            }
            else if (OrginCFORM == "Fransa" || OrginCFORM == "France")
            {
                template = isPaid ? allForms.fldFransizca : allForms.fldFransizcaC;
            }
            else if (OrginCFORM == "Almanya" || OrginCFORM == "Germany")
            {
                template = isPaid ? allForms.fldDEC : allForms.fldDE;
            }
            else if (OrginCFORM == "İran" || OrginCFORM == "Iran")
            {
                template = isPaid ? allForms.fldIRC : allForms.fldIR;
            }
            else if (OrginCFORM == "Irak" || OrginCFORM == "Iraq")
            {
                template = isPaid ? allForms.fldIRKC : allForms.fldIRK;
            }
            else if (OrginCFORM == "Çin" || OrginCFORM == "China" || OrginCFORM == "Çin Halk Cumhuriyeti")
            {
                template = isPaid ? allForms.fldCinC : allForms.fldCin;
            }
            else if (OrginCFORM == "Yunanistan" || OrginCFORM == "Greece")
            {
                template = isPaid ? allForms.fldYunanC : allForms.fldYunan;
            }
            else
            {
                template = isPaid ? allForms.fldGBC : allForms.fldGB;
            }

            result = template ?? "";
            result = result.Replace("{{GATE}}", Data?.fldBorder?.Split(' ')[0] ?? "");

            if (isPaid)
            {
                result = result.Replace("{{TCODE}}", codeFORM)
                               .Replace("{{NAME}}", NameCFORM)
                               .Replace("{{ORGIN}}", OrginCFORM)
                               .Replace("{{PASSPORT}}", PassportCFORM)
                               .Replace("{{EDATE}}", EntryDateCFORM)
                               .Replace("{{TODAY}}", DateTime.Now.ToString("dd.MM.yyyy"))
                               .Replace("{{SEDATE}}", ShouldExitCFORM)
                               .Replace("{{VDAY}}", VisaDistanceCFORM)
                               .Replace("{{FINETIME}}", ((Convert.ToInt32(CAyCFORM) * 30) + Convert.ToInt32(CGunCFORM)).ToString())
                               .Replace("{{FINET}}", FINET)
                               .Replace("{{POLICE}}", PoliceCFORM)
                               .Replace("{{USER}}", Data?.fldSicil ?? "")
                               .Replace("{{CANENT}}", DateTime.Now.AddDays(Convert.ToInt32(DDayCFORM)).ToString("dd.MM.yyyy"))
                               .Replace("{{FINEDAY}}", DDayCFORM)
                               .Replace("{{FIRSTNAME}}", Adı)
                               .Replace("{{LASTNAME}}", Soyadı)
                               .Replace("{{FATHERNAME}}", FatherCFORM)
                               .Replace("{{MOTHERNAME}}", MotherCFORM)
                               .Replace("{{BIRTHDATE}}", BirthdateCFORM.ToString("dd.MM.yyyy"))
                               .Replace("{{TOTIME}}", DateTime.Now.ToShortTimeString());

                bool isUnder90 = (((Convert.ToInt32(CAyCFORM) * 30) + Convert.ToInt32(CGunCFORM)) < 90 && PaymentTypeCFORM != "2" && PaymentTypeCFORM != "3" && PaymentTypeCFORM != "6")
                              || (PaymentTypeCFORM == "6" && ((Convert.ToInt32(CAyCFORM) * 30) + Convert.ToInt32(CGunCFORM)) < 11)
                              || (PaymentTypeCFORM == "8" && ((Convert.ToInt32(CAyCFORM) * 30) + Convert.ToInt32(CGunCFORM)) < 11)
                              || (PaymentTypeCFORM == "14" && ((Convert.ToInt32(CAyCFORM) * 30) + Convert.ToInt32(CGunCFORM)) < 11)
                              || adult == false;

                if (isUnder90 || !codeFORM.Contains("Ç"))
                {
                    int start = result.IndexOf("{{S}}"),
                        finish = result.IndexOf("{{F}}");
                    if (start >= 0 && finish > start)
                        result = result.Remove(start, (finish - start) + 5);
                    int start1 = result.IndexOf("{{S1}}"),
                        finish1 = result.IndexOf("{{F1}}");
                    if (start1 >= 0 && finish1 > start1)
                        result = result.Remove(start1, (finish1 - start1) + 6);
                    result = result.Replace("{{S}}", "").Replace("{{F}}", "").Replace("{{S1}}", "").Replace("{{F1}}", "");
                }
                else
                {
                    result = result.Replace("{{S}}", "").Replace("{{F}}", "");
                    result = result.Replace("{{S1}}", "<div class=\"page-break\" style=\"display:block; page-break-before:always !important; break-before:page !important; clear:both;\"></div>");
                    result = result.Replace("{{F1}}", "");
                }
                result = result.Trim();
            }
            else
            {
                if (!adult)
                {
                    Adı = FatherCFORM + ", " + MotherCFORM + " çocuğu " + Adı;
                }

                result = result.Replace("{{TCODE}}", codeFORM)
                               .Replace("{{NAME}}", NameCFORM)
                               .Replace("{{ORGIN}}", OrginCFORM)
                               .Replace("{{PASSPORT}}", PassportCFORM)
                               .Replace("{{EDATE}}", EntryDateCFORM)
                               .Replace("{{TODAY}}", DateTime.Now.ToString("dd.MM.yyyy"))
                               .Replace("{{SEDATE}}", ShouldExitCFORM)
                               .Replace("{{VDAY}}", VisaDistanceCFORM)
                               .Replace("{{FINETIME}}", ((Convert.ToInt32(CAyCFORM) * 30) + Convert.ToInt32(CGunCFORM)).ToString())
                               .Replace("{{FINET}}", FINET)
                               .Replace("{{POLICE}}", PoliceCFORM)
                               .Replace("{{USER}}", Data?.fldSicil ?? "")
                               .Replace("{{CANENT}}", DateTime.Now.AddDays(Convert.ToInt32(DDayCFORM)).ToString("dd.MM.yyyy"))
                               .Replace("{{FINEDAY}}", DDayCFORM)
                               .Replace("{{FIRSTNAME}}", Adı)
                               .Replace("{{LASTNAME}}", Soyadı)
                               .Replace("{{FATHERNAME}}", FatherCFORM)
                               .Replace("{{MOTHERNAME}}", MotherCFORM)
                               .Replace("{{BIRTHDATE}}", BirthdateCFORM.ToString("dd.MM.yyyy"))
                               .Replace("{{TOTIME}}", DateTime.Now.ToShortTimeString());

                result = result.Replace("{{S}}", "").Replace("{{F}}", "").Replace("{{S1}}", "").Replace("{{F1}}", "");

                int nKodluPos = result.IndexOf("N Kodlu");
                if (nKodluPos > 0)
                {
                    int imgBeforeN = result.LastIndexOf("<img", nKodluPos);
                    int targetPos = -1;
                    if (imgBeforeN > 0)
                    {
                        int pBefore = result.LastIndexOf("<p", imgBeforeN);
                        targetPos = (pBefore > 0 && (imgBeforeN - pBefore) < 100) ? pBefore : imgBeforeN;
                    }
                    else
                    {
                        targetPos = result.LastIndexOf("<table", nKodluPos);
                    }
                    if (targetPos > 0)
                    {
                        result = result.Insert(targetPos, "<div class=\"page-break\" style=\"display:block; page-break-before:always !important; break-before:page !important; clear:both;\"></div>");
                    }
                }

                if (!codeFORM.Contains("Ç") || !adult)
                {
                    int start3 = result.IndexOf("{{ÇS}}");
                    if (start3 >= 0)
                    {
                        int pBefore = result.LastIndexOf("<p", start3);
                        if (pBefore > 0 && (start3 - pBefore) < 150)
                            result = result.Substring(0, pBefore).Trim();
                        else
                            result = result.Substring(0, start3).Trim();
                    }
                }
                else
                {
                    int start3 = result.IndexOf("{{ÇS}}");
                    if (start3 >= 0)
                    {
                        int pBefore = result.LastIndexOf("<p", start3);
                        int cKodluPos = result.IndexOf("Ç Kodlu", start3);
                        int imgBeforeC = cKodluPos > 0 ? result.LastIndexOf("<img", cKodluPos) : -1;
                        int targetEnd = imgBeforeC > 0 ? result.LastIndexOf("<p", imgBeforeC) : -1;
                        if (targetEnd < 0) targetEnd = imgBeforeC > 0 ? imgBeforeC : (start3 + 6);

                        int cutStart = (pBefore >= 0 && (start3 - pBefore) < 150) ? pBefore : start3;
                        if (targetEnd > cutStart)
                        {
                            result = result.Remove(cutStart, targetEnd - cutStart).Insert(cutStart, "<div class=\"page-break\" style=\"display:block; page-break-before:always !important; break-before:page !important; clear:both;\"></div>");
                        }
                        else
                        {
                            result = result.Replace("{{ÇS}}", "<div class=\"page-break\" style=\"display:block; page-break-before:always !important; break-before:page !important; clear:both;\"></div>");
                        }
                    }
                }
                result = result.Trim();
            }
            //if (DefterCFORM == "0") result = result.Replace("+Def", "");
            Isk Isk = new Isk();
            string ext = coverinputpd != null ? coverinputpd.FileName.Substring(coverinputpd.FileName.LastIndexOf('.')).ToLower() : "NO IMAGE";
            IList<string> AllowedExt = new List<string> { ".jpeg", ".jpg", ".gif", ".png" };
            string fileName = "";
            if (AllowedExt.Contains(ext))
            {
                fileName = $@"{DateTime.Now.Ticks}" + coverinputpd.FileName.Substring(coverinputpd.FileName.LastIndexOf('.')).ToLower();
                string filepath = Path.Combine(FileStorageHelper.MapPath(Server, "~/ccc"), fileName);
                coverinputpd.SaveAs(filepath);
            }
            //if (coverinputpd != "") coverinputpd = $@"{DateTime.Now.Ticks}."+coverinputpd.Split('.')[coverinputpd.Split('.').Length-1];
            Isk.AddIsk(DateTime.Now, NameCFORM, PassportCFORM, IDNCFORM, OrginCFORM, BirthdateCFORM, result, PoliceCFORM, Data.fldName + " " + Data.fldLastName, Data.fldBorder, Vizeler[visatype], FinePriceCFORM, fileName, Request.ServerVariables["HTTP_X_FORWARDED_FOR"] ?? Request.ServerVariables["REMOTE_ADDR"]);
            TryLogTahditForm(Data, OrginCFORM, FinePriceCFORM, PaymentTypeCFORM, NameCFORM, PassportCFORM, codeFORM, visatype, DDayCFORM, CGunCFORM, CAyCFORM);
            ViewBag.QrText = "T.C. ICISLERI BAKANLIGI EGM\n" +
                             "Yolcu: " + (NameCFORM ?? "-") + "\n" +
                             "Pasaport: " + (PassportCFORM ?? "-") + "\n" +
                             "Uyruk: " + (OrginCFORM ?? "-") + "\n" +
                             "Ceza Tutari: " + (FinePriceCFORM ?? "-") + " TL\n" +
                             "Tahdit Kodu: " + (codeFORM ?? "-") + "\n" +
                             "Hudut Kapisi: " + (Data != null ? (Data.fldBorder ?? "-") : "-") + "\n" +
                             "Gorevli Memur: " + (PoliceCFORM ?? "-") + " (Sicil: " + (Data != null ? (Data.fldSicil ?? "-") : "-") + ")\n" +
                             "Tarih: " + DateTime.Now.ToString("dd.MM.yyyy HH:mm");
            ViewBag.Form = result;
            return View();
        }

        private void TryLogTahditForm(E_User user, string country, string finePrice, string paymentType, string passengerName, string passportNo, string tahditCode, int visaType, string dday, string penaltyDay, string penaltyMonth)
        {
            try
            {
                if (user == null || string.IsNullOrWhiteSpace(tahditCode))
                    return;

                int day;
                int month;
                int forbiddenDay;
                int.TryParse((penaltyDay ?? "").Trim(), out day);
                int.TryParse((penaltyMonth ?? "").Trim(), out month);
                int.TryParse((dday ?? "").Trim(), out forbiddenDay);

                var service = new TahditFormLogService();
                string idariCode;
                using (var db = new GZPEGM1())
                {
                    idariCode = service.FindIdariTahditCode(db, tahditCode, paymentType);
                }

                service.Log(new TahditFormLogEntry
                {
                    TahditCode = tahditCode,
                    IdariTahditCode = idariCode,
                    PenaltyDay = day,
                    PenaltyMonth = month,
                    PenaltyTotalDay = (month * 30) + day,
                    PaymentType = paymentType,
                    VisaType = visaType,
                    Country = country,
                    Border = user.fldBorder,
                    UserId = user.fldId,
                    UserSicil = user.fldSicil,
                    UserDisplayName = ((user.fldName ?? "").Trim() + " " + (user.fldLastName ?? "").Trim()).Trim(),
                    PassengerName = passengerName,
                    PassportNo = passportNo,
                    FormMoney = finePrice
                });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Tahdit form log error: " + ex.Message);
            }
        }
    }
}
