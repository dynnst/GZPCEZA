using gzpegm.Cont;
using gzpegm.Helpers;
using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Web;
using System.Web.Mvc;
using System.Linq;

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
            return View((gzpegm.Models.ViewModels.FormPrintViewModel)null);
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
            int cGun = 0, cAy = 0;
            int.TryParse(CGunCFORM, out cGun);
            int.TryParse(CAyCFORM, out cAy);
            int totalDays = (cAy * 30) + cGun;

            bool isPaid = (payType == "1" || payType == "2" || payType == "10" || payType == "8" || payType == "6" || payType == "14" || payType == "4");

            bool isUnder90 = (totalDays < 90 && payType != "2" && payType != "3" && payType != "6")
                          || (payType == "6" && totalDays < 11)
                          || (payType == "8" && totalDays < 11)
                          || (payType == "14" && totalDays < 11)
                          || !adult;

            if (!adult && !isPaid)
            {
                Adı = FatherCFORM + ", " + MotherCFORM + " çocuğu " + Adı;
            }

            string lang = "GB";
            string origin = (OrginCFORM ?? "").Trim();
            if (origin == "Rusya Federasyonu" || origin == "Ukrayna" || origin == "Rusya" || origin == "Russia" || origin == "Ukraine")
            {
                lang = "RU";
            }
            else if (origin == "Almanya" || origin == "Germany")
            {
                lang = "DE";
            }
            else if (origin == "Fransa" || origin == "France")
            {
                lang = "FR";
            }
            else if (origin == "İran" || origin == "Iran")
            {
                lang = "IR";
            }
            else if (origin == "Irak" || origin == "Iraq")
            {
                lang = "IRK";
            }
            else if (origin == "Çin" || origin == "China" || origin == "Çin Halk Cumhuriyeti")
            {
                lang = "Cin";
            }
            else if (origin == "Yunanistan" || origin == "Greece")
            {
                lang = "Yunan";
            }
            else if (origin == "Bulgaristan" || origin == "Bulgaria")
            {
                lang = "BG";
            }
            else if (origin == "Romanya" || origin == "Romania" || origin == "Moldova" || origin == "Moldavya")
            {
                lang = "RO";
            }
            else if (origin == "Azerbaycan" || origin == "Azerbaijan")
            {
                lang = "AZ";
            }
            else if (origin == "Gürcistan" || origin == "Georgia")
            {
                lang = "GE";
            }

            bool hasCKodlu = (codeFORM ?? "").Contains("Ç");
            bool hasNKodlu = !isPaid;

            int dDay = 0;
            int.TryParse(DDayCFORM, out dDay);

            string qrText = "T.C. ICISLERI BAKANLIGI EGM\n" +
                            "Yolcu: " + (NameCFORM ?? "-") + "\n" +
                            "Pasaport: " + (PassportCFORM ?? "-") + "\n" +
                            "Uyruk: " + (OrginCFORM ?? "-") + "\n" +
                            "Ceza Tutari: " + (FinePriceCFORM ?? "-") + " TL\n" +
                            "Tahdit Kodu: " + (codeFORM ?? "-") + "\n" +
                            "Hudut Kapisi: " + (Data != null ? (Data.fldBorder ?? "-") : "-") + "\n" +
                            "Gorevli Memur: " + (PoliceCFORM ?? "-") + " (Sicil: " + (Data != null ? (Data.fldSicil ?? "-") : "-") + ")\n" +
                            "Tarih: " + DateTime.Now.ToString("dd.MM.yyyy HH:mm");

            var model = new gzpegm.Models.ViewModels.FormPrintViewModel
            {
                PassengerName = NameCFORM,
                FirstName = Adı,
                LastName = Soyadı,
                FatherName = FatherCFORM,
                MotherName = MotherCFORM,
                Nationality = OrginCFORM,
                PassportNo = PassportCFORM,
                Birthdate = BirthdateCFORM.ToString("dd.MM.yyyy"),
                CommunicationLanguage = OrginCFORM,
                EntryDate = EntryDateCFORM,
                ApplicationDate = DateTime.Now.ToString("dd.MM.yyyy"),
                ShouldExitDate = ShouldExitCFORM,
                CanEnterDate = DateTime.Now.AddDays(dDay).ToString("dd.MM.yyyy"),
                VisaDistanceDays = VisaDistanceCFORM,
                ViolationPeriod = totalDays.ToString(),
                FineAmount = FINET,
                FinePriceTotal = FinePriceCFORM,
                DefterPrice = DefterCFORM,
                TahditCode = codeFORM,
                EntryBanDays = DDayCFORM,
                PoliceOfficer = PoliceCFORM,
                ApprovalUser = Data?.fldSicil ?? "",
                BorderGate = Data?.fldBorder ?? "",
                Province = ResolveProvince(Data?.fldBorder ?? ""),
                Today = DateTime.Now.ToString("dd.MM.yyyy"),
                CurrentTime = DateTime.Now.ToShortTimeString(),
                IsPaid = isPaid,
                IsAdult = adult,
                IsOver90 = !isUnder90,
                HasCKodlu = hasCKodlu,
                HasNKodlu = hasNKodlu,
                LanguageCode = lang,
                QrText = qrText
            };

            result = RenderRazorViewToString(this.ControllerContext, "Index", model);
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
            // Mükerrer Kayıt Önleme: Aynı pasaport numarası, aynı hudut kapısı ve aynı ceza tutarı ile
            // son 3 dakika içerisinde zaten bir kayıt yapılmışsa E_IsK tablosuna mükerrer kayıt ekleme.
            // Form çıktısı memura kesintisiz üretilmeye devam eder ve mevcut kayıt en güncel form içeriğiyle yenilenir.
            var cleanPassport = (PassportCFORM ?? "").Trim();
            var cleanName = (NameCFORM ?? "").Trim();
            var borderName = Data != null ? (Data.fldBorder ?? "") : "";
            var cutoffTime = DateTime.Now.AddMinutes(-3);

            E_IsK existingRecord = null;
            using (GZPEGM1 _db = new GZPEGM1())
            {
                if (!string.IsNullOrEmpty(cleanPassport))
                {
                    existingRecord = _db.E_IsK
                        .Where(x => x.fldPassport == cleanPassport
                                 && x.fldBorder == borderName
                                 && x.fldPMoney == FinePriceCFORM
                                 && x.fldDatetime.HasValue
                                 && x.fldDatetime.Value >= cutoffTime)
                        .OrderByDescending(x => x.fldId)
                        .FirstOrDefault();
                }
                else if (!string.IsNullOrEmpty(cleanName))
                {
                    existingRecord = _db.E_IsK
                        .Where(x => x.fldName == cleanName
                                 && x.fldBorder == borderName
                                 && x.fldPMoney == FinePriceCFORM
                                 && x.fldDatetime.HasValue
                                 && x.fldDatetime.Value >= cutoffTime)
                        .OrderByDescending(x => x.fldId)
                        .FirstOrDefault();
                }

                if (existingRecord != null)
                {
                    // Mevcut kaydı güncelle (yeni mükerrer satır açma)
                    existingRecord.fldForm = result;
                    existingRecord.fldName = NameCFORM;
                    existingRecord.fldIdn = IDNCFORM;
                    _db.SaveChanges();
                }
            }

            if (existingRecord == null)
            {
                Isk.AddIsk(DateTime.Now, NameCFORM, PassportCFORM, IDNCFORM, OrginCFORM, BirthdateCFORM, result, PoliceCFORM, Data.fldName + " " + Data.fldLastName, Data.fldBorder, Vizeler[visatype], FinePriceCFORM, fileName, Request.ServerVariables["HTTP_X_FORWARDED_FOR"] ?? Request.ServerVariables["REMOTE_ADDR"]);
                TryLogTahditForm(Data, OrginCFORM, FinePriceCFORM, PaymentTypeCFORM, NameCFORM, PassportCFORM, codeFORM, visatype, DDayCFORM, CGunCFORM, CAyCFORM);
            }
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
            return View(model);
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

        private string RenderRazorViewToString(ControllerContext context, string viewName, object model)
        {
            try
            {
                ViewData.Model = model;
                using (var sw = new System.IO.StringWriter())
                {
                    var viewResult = ViewEngines.Engines.FindView(context, viewName, null);
                    if (viewResult.View == null)
                    {
                        viewResult = ViewEngines.Engines.FindPartialView(context, viewName);
                    }
                    if (viewResult != null && viewResult.View != null)
                    {
                        var viewContext = new ViewContext(context, viewResult.View, ViewData, TempData, sw);
                        viewResult.View.Render(viewContext, sw);
                        viewResult.ViewEngine.ReleaseView(context, viewResult.View);
                        return sw.GetStringBuilder().ToString();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("RenderRazorViewToString error: " + ex.Message);
            }
            return "";
        }

        private static readonly string[] TurkishProvinces = new string[]
        {
            "Adana", "Adıyaman", "Afyonkarahisar", "Ağrı", "Aksaray", "Amasya", "Ankara", "Antalya", "Ardahan", "Artvin",
            "Aydın", "Balıkesir", "Bartın", "Batman", "Bayburt", "Bilecik", "Bingöl", "Bitlis", "Bolu", "Burdur",
            "Bursa", "Çanakkale", "Çankırı", "Çorum", "Denizli", "Diyarbakır", "Düzce", "Edirne", "Elazığ", "Erzincan",
            "Erzurum", "Eskişehir", "Gaziantep", "Giresun", "Gümüşhane", "Hakkari", "Hatay", "Iğdır", "Isparta", "İstanbul",
            "İzmir", "Kahramanmaraş", "Karabük", "Karaman", "Kars", "Kastamonu", "Kayseri", "Kırıkkale", "Kırklareli", "Kırşehir",
            "Kilis", "Kocaeli", "Konya", "Kütahya", "Malatya", "Manisa", "Mardin", "Mersin", "Muğla", "Muş",
            "Nevşehir", "Niğde", "Ordu", "Osmaniye", "Rize", "Sakarya", "Samsun", "Siirt", "Sinop", "Sivas",
            "Şanlıurfa", "Şırnak", "Tekirdağ", "Tokat", "Trabzon", "Tunceli", "Uşak", "Van", "Yalova", "Yozgat", "Zonguldak"
        };

        private static readonly Dictionary<string, string> SpecialBorderGateProvinces = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            { "ÇUKUROVA", "Mersin" },
            { "KAPADOKYA", "Nevşehir" },
            { "MARMARİS", "Muğla" },
            { "ÇEŞME", "İzmir" },
            { "İSKENDERUN", "Hatay" },
            { "BODRUM", "Muğla" },
            { "FETHİYE", "Muğla" },
            { "DATÇA", "Muğla" },
            { "DALAMAN", "Muğla" },
            { "KUŞADASI", "Aydın" },
            { "DİDİM", "Aydın" },
            { "AYVALIK", "Balıkesir" },
            { "BANDIRMA", "Balıkesir" },
            { "MARMARA DENİZ", "Balıkesir" },
            { "SARP", "Artvin" },
            { "HOPA", "Artvin" },
            { "KAPIKULE", "Edirne" },
            { "HAMZABEYLİ", "Edirne" },
            { "İPSALA", "Edirne" },
            { "PAZARKULE", "Edirne" },
            { "DEREKÖY", "Kırklareli" },
            { "GÜRBULAK", "Ağrı" },
            { "HABUR", "Şırnak" },
            { "ESENDERE", "Hakkari" },
            { "ÜZÜMLÜ", "Hakkari" },
            { "DERECİK", "Hakkari" },
            { "TÜRKGÖZÜ", "Ardahan" },
            { "AKTAŞ", "Ardahan" },
            { "DİLUCU", "Iğdır" },
            { "ALİCAN", "Iğdır" },
            { "KAPIKÖY", "Van" },
            { "CİLVEGÖZÜ", "Hatay" },
            { "ÖNCÜPINAR", "Kilis" },
            { "ÇOBANBEY", "Kilis" },
            { "KARKAMIŞ", "Gaziantep" },
            { "GAZİPAŞA", "Antalya" },
            { "SABİHA GÖKÇEN", "İstanbul" },
            { "ESENBOĞA", "Ankara" },
            { "ADNAN MENDERES", "İzmir" },
            { "DAİRE BAŞKANLIĞI", "Ankara" }
        };

        public static string ResolveProvince(string borderGate)
        {
            if (string.IsNullOrWhiteSpace(borderGate)) return "Antalya";

            string bg = borderGate.Trim();
            var trCulture = System.Globalization.CultureInfo.GetCultureInfo("tr-TR");
            string bgUpper = bg.ToUpper(trCulture);

            // 1. Check if border gate name starts with or equals any of the 81 Turkish provinces
            foreach (var prov in TurkishProvinces)
            {
                string provUpper = prov.ToUpper(trCulture);
                if (bgUpper == provUpper || bgUpper.StartsWith(provUpper + " ") || bgUpper.StartsWith(provUpper + "-"))
                {
                    return prov;
                }
            }

            // 2. Check special mappings (Çukurova, Kapadokya, Marmaris, Çeşme, etc.)
            foreach (var kvp in SpecialBorderGateProvinces)
            {
                string keyUpper = kvp.Key.ToUpper(trCulture);
                if (bgUpper.IndexOf(keyUpper, StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    return kvp.Value;
                }
            }

            // 3. Substring search for province inside border gate name
            foreach (var prov in TurkishProvinces)
            {
                string provUpper = prov.ToUpper(trCulture);
                if (bgUpper.IndexOf(provUpper, StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    return prov;
                }
            }

            return "Antalya";
        }
    }
}
