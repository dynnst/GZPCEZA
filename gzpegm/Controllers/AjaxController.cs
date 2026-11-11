using gzpegm.Cont;
using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.SessionState;

namespace gzpegm.Controllers
{
    [UserAuthorize]
    [SessionState(SessionStateBehavior.ReadOnly)]
    public class AjaxController : Controller
    {
        private static bool TryParseCalculationDate(string value, out DateTime date)
        {
            date = DateTime.MinValue;
            if (string.IsNullOrWhiteSpace(value)) return false;

            var formats = new[]
            {
                "dd.MM.yyyy",
                "dd.MM.yyyy HH:mm",
                "dd.MM.yyyy HH:mm:ss",
                "d.M.yyyy",
                "d.M.yyyy HH:mm",
                "d.M.yyyy HH:mm:ss"
            };

            DateTime parsed;
            if (DateTime.TryParseExact(value.Trim(), formats, new CultureInfo("tr-TR"), DateTimeStyles.None, out parsed) ||
                DateTime.TryParse(value.Trim(), new CultureInfo("tr-TR"), DateTimeStyles.None, out parsed))
            {
                date = parsed.Date;
                return true;
            }

            return false;
        }

        private static int CalculateStayDays(DateTime entryDate, DateTime exitDate)
        {
            if (entryDate.Date > exitDate.Date) return 0;
            var days = (exitDate.Date - entryDate.Date).Days;
            return days == 0 ? 1 : days;
        }

        [NonAction]
        public E_User getuserby()
        {
            HttpCookie UserCookie;
            UserCookie = Request.Cookies["Token"];
            Token token = new Token();
            gzpegm.Cont.User user = new User();
            int UserId = 0;
            if (UserCookie != null)
            {
                var tokendata = token.GetToken(UserCookie.Value.ToString());
                if (tokendata?.fldUserId != null)
                    int.TryParse(tokendata.fldUserId.ToString(), out UserId);
            }
            var uData = user.GetUserById(UserId);
            return uData;
        }

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
                if (tokendata?.fldUserId != null)
                    int.TryParse(tokendata.fldUserId.ToString(), out UserId);
            }
            var Data = user.GetUserById(UserId);
            return Data;
        }

        [AllowAnonymous]
        [Route("Calculate1")]
        public JsonResult Calculate1(FormCollection form, string deneme)
        {
            string Country = form["CountryCalculate"],
                enterdates = form["EnterDateCalculate"],
                exitdates = form["ExitDateCalculate"];
            int Passport = Convert.ToInt32(form["PassportCalculate"]),
                Visa = Convert.ToInt32(form["VisaCalculate"]),
                Ctype = Convert.ToInt32(form["CTypeCalculate"]),
                Visaday = 0,
                sayac = 0,
                cezagun = 0,
                cezaay = 0,
                kalmagun = 0;

            bool isPermitOrRestriction = (Visa == 4 || Visa == 8 || Visa == 10 || Visa == 11 || Visa == 12 || Visa == 13 || Visa == 14 || Visa == 15);

            // Visa tipi kontrolü
            if (Visa == 3)
                Visaday = Convert.ToInt32(form["Visaday"]);
            else if (isPermitOrRestriction)
            {
                enterdates = form["testarihi"];
                if (string.IsNullOrWhiteSpace(enterdates))
                    return Json(new { Type = "0", Message = "Lütfen geçerli bitiş / tebliğ tarihini giriniz..!" }, JsonRequestBehavior.AllowGet);

                var exitArr = (exitdates ?? "").Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                exitdates = exitArr.Length > 0 ? exitArr[exitArr.Length - 1] : "";
            }

            DateTime enterdt = DateTime.Now, exitdt = DateTime.Now;
            Contuvr contuvr = new Contuvr();

            string[] entryDateValues = (enterdates ?? "").Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            string[] exitDateValues = (exitdates ?? "").Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            if (entryDateValues.Length == 0 || exitDateValues.Length == 0 || entryDateValues.Length != exitDateValues.Length)
                return Json(new { Type = "0", Message = "Giriş ve çıkış tarihleri eşleşmiyor veya boş..!" }, JsonRequestBehavior.AllowGet);

            var trips = new List<Tuple<DateTime, DateTime>>();
            for (int i = 0; i < entryDateValues.Length; i++)
            {
                if (string.IsNullOrWhiteSpace(entryDateValues[i]) || string.IsNullOrWhiteSpace(exitDateValues[i]))
                    return Json(new { Type = "0", Message = "Tarihlerde boş bırakmayınız..!" }, JsonRequestBehavior.AllowGet);

                if (!TryParseCalculationDate(entryDateValues[i], out enterdt) ||
                    !TryParseCalculationDate(exitDateValues[i], out exitdt))
                    return Json(new { Type = "0", Message = "Tarih biçimi geçersiz..!" }, JsonRequestBehavior.AllowGet);

                if (!isPermitOrRestriction && enterdt > exitdt)
                    return Json(new { Type = "0", Message = "Tarihlerde yanlışlık var lütfen kontrol ediniz.!" }, JsonRequestBehavior.AllowGet);

                trips.Add(Tuple.Create(enterdt.Date, exitdt.Date));
            }

            // =========================================================================
            // TÜRKİYE'DE DOĞAN ÇOCUKLAR HESABI (Visa == 5)
            // Türkiye'de doğan çocukların doğum tarihi giriş tarihi olarak yazılır.
            // Vize / muafiyet hakkı 0 gündür.
            // Doğduğu günden çıktığı güne kadar olan tüm süre cezalıdır (cezagun = kalmagun).
            // =========================================================================
            if (Visa == 5)
            {
                DateTime birthDt = trips[0].Item1;
                DateTime borderExitDt = trips[trips.Count - 1].Item2;

                if (borderExitDt < birthDt)
                {
                    return Json(new { Type = "0", Message = "Çıkış tarihi doğum tarihinden önce olamaz..!" }, JsonRequestBehavior.AllowGet);
                }

                int totalViolationDays = 0;
                int[] childSeferler = new int[trips.Count];
                for (int i = 0; i < trips.Count; i++)
                {
                    int stayDays = CalculateStayDays(trips[i].Item1, trips[i].Item2);
                    childSeferler[i] = stayDays;
                    totalViolationDays += stayDays;
                }

                if (totalViolationDays <= 0)
                {
                    return Json(new { Type = "0", Message = "Cezalı Süresi Yoktur..!" }, JsonRequestBehavior.AllowGet);
                }

                cezagun = totalViolationDays;
                if (cezagun > 30)
                {
                    cezaay = cezagun / 30;
                    cezagun = cezagun % 30;
                }
                else
                {
                    cezaay = 0;
                }

                return Json(new
                {
                    Type = "1",
                    Day = 0,
                    Daylong = 0,
                    OneTime = 0,
                    BasDate = birthDt.ToString("dd.MM.yyyy"),
                    ShoulExtiTime = birthDt.ToString("dd.MM.yyyy"),
                    FarkAy = cezaay,
                    FarkGun = cezagun,
                    Seferler = childSeferler
                }, JsonRequestBehavior.AllowGet);
            }

            var UVRdata = contuvr.check(0, Country, Passport, Visa, Ctype);
            if (UVRdata == null && Ctype == 2)
            {
                // 180 Gün Kuralı için spesifik kayıt yoksa Normal Hesaplama kuralını al
                UVRdata = contuvr.check(0, Country, Passport, Visa, 1);
            }
            if (UVRdata == null && isPermitOrRestriction)
            {
                // İkamet/çalışma/tahdit için genel ülke kaydı varsa al
                UVRdata = contuvr.check(0, Country, Passport, 2, 1) ?? contuvr.check(0, Country, Passport, 1, 1);
            }

            if (UVRdata == null && !isPermitOrRestriction)
                return Json(new { Type = "0", Message = "Belirtilen bilgilere ait hesaplama bilgisi mevcut değildir..!" }, JsonRequestBehavior.AllowGet);

            int dayVal = UVRdata?.fldDay != null ? Convert.ToInt32(UVRdata.fldDay) : 0;
            int longVal = UVRdata?.fldLong != null ? Convert.ToInt32(UVRdata.fldLong) : 0;

            if (Ctype == 4) Visaday = 0;
            else if (Visaday == 0 && UVRdata?.fldOneTime != null)
                Visaday = Convert.ToInt32(UVRdata.fldOneTime);

            int[] seferler = new int[entryDateValues.Length];

            // =========================================================================
            // 1. İKAMET TEZKERESİ, ÇALIŞMA İZNİ VE TAHDİTLİ / TEBLİĞLİ İŞLEMLER HESABI
            // (Visa == 4, 8, 10, 11, 12, 13, 14, 15)
            // İkamet tezkeresi ve çalışma izinlerinde 10 günlük muafiyet kaldırılmıştır.
            // Ceza, izin bitiş tarihinden sonraki günden itibaren başlar.
            // =========================================================================
            if (isPermitOrRestriction)
            {
                DateTime permitEndDt = trips[0].Item1; // İkamet / İzin bitiş veya tebliğ tarihi
                DateTime borderExitDt = trips[trips.Count - 1].Item2; // Hudut kapısı çıkış tarihi

                // Kişi izin bitiş tarihinde veya bitiş tarihinden önce çıkıyorsa cezası yoktur.
                if (borderExitDt <= permitEndDt)
                {
                    return Json(new { Type = "0", Message = "İkamet tezkeresi veya izin geçerlilik süresi dolmamıştır. Cezalı Süresi Yoktur..!" }, JsonRequestBehavior.AllowGet);
                }

                // İzin bitiş tarihinden sonraki günden başlayarak çıkış tarihine kadar olan tüm günler cezalıdır.
                int violationDays = (borderExitDt.Date - permitEndDt.Date).Days;
                if (violationDays <= 0)
                {
                    return Json(new { Type = "0", Message = "Cezalı Süresi Yoktur..!" }, JsonRequestBehavior.AllowGet);
                }

                cezagun = violationDays;
                if (cezagun > 30)
                {
                    cezaay = cezagun / 30;
                    cezagun = cezagun % 30;
                }
                else
                {
                    cezaay = 0;
                }

                seferler[0] = violationDays;

                return Json(new
                {
                    Type = "1",
                    Day = dayVal,
                    Daylong = longVal,
                    OneTime = Visaday,
                    BasDate = permitEndDt.ToString("dd.MM.yyyy"),
                    ShoulExtiTime = permitEndDt.ToString("dd.MM.yyyy"),
                    FarkAy = cezaay,
                    FarkGun = cezagun,
                    Seferler = seferler
                }, JsonRequestBehavior.AllowGet);
            }

            // =========================================================================
            // 2. NORMAL VİZELİ / VİZESİZ / TURİSTİK KALIŞ HESABI (90/180 vb.)
            // =========================================================================
            bool isMultipleEntryExit = trips.Count > 1;
            DateTime referenceExit = trips.Max(x => x.Item2);
            int ruleWindowDays = (dayVal > 0) ? dayVal : 180;
            DateTime windowStart = referenceExit.AddDays(-ruleWindowDays);

            // Son çıkışa karşılık gelen güncel seferin giriş tarihi (Yasal Tarih Aralığı için)
            var latestTrip = trips.OrderByDescending(x => x.Item2).ThenByDescending(x => x.Item1).FirstOrDefault();
            DateTime currentTripEntry = latestTrip != null ? latestTrip.Item1 : trips[0].Item1;

            foreach (var trip in trips)
            {
                DateTime countedEntry = trip.Item1;
                DateTime countedExit = trip.Item2;

                // Çoklu giriş-çıkışlarda veya 180 Gün Kuralında geriye dönük takvim penceresi (örn. 180 gün) uygulanır.
                // Pencere öncesindeki (180 gün dışındaki) kalışlar kanunen hesaba dahil edilmez.
                if (isMultipleEntryExit || Ctype == 2)
                {
                    if (countedExit < windowStart)
                    {
                        countedEntry = windowStart;
                        countedExit = windowStart.AddDays(-1);
                    }
                    else
                    {
                        if (countedEntry < windowStart) countedEntry = windowStart;
                        if (countedExit > referenceExit) countedExit = referenceExit;
                    }
                }

                int farkGun;
                if (countedEntry > countedExit)
                {
                    farkGun = 0;
                }
                else
                {
                    // Saat bilgileri yok sayılır. Giriş günü sayılır, çıkış günü sayılmaz.
                    // İş kuralı gereği aynı gün giriş-çıkış 1 gün kabul edilir.
                    farkGun = CalculateStayDays(countedEntry, countedExit);
                }

                if (Ctype == 4) // Günübirlik cezalar
                {
                    farkGun = countedEntry > countedExit ? 0 : 1;
                    seferler[sayac] = farkGun == 0 ? 0 : -1;
                }
                else
                {
                    seferler[sayac] = farkGun;
                }

                kalmagun += farkGun;
                sayac++;
            }

            exitdt = referenceExit;
            int maxOneTime = (Visaday > 0) ? Visaday : (UVRdata?.fldOneTime != null ? Convert.ToInt32(UVRdata.fldOneTime) : 0);
            if (Country == "Rusya Federasyonu" && maxOneTime == 0) maxOneTime = 60;
            if (Country == "Beyaz Rusya" && maxOneTime == 0) maxOneTime = 30;

            int maxPeriodTotal = (longVal > 0) ? longVal : 90;
            int penalty = 0;

            if (maxOneTime > 0)
            {
                for (int i = 0; i < seferler.Length; i++)
                {
                    if (seferler[i] > maxOneTime)
                        penalty += seferler[i] - maxOneTime;
                }
            }

            if (maxPeriodTotal > 0 && kalmagun > maxPeriodTotal)
            {
                penalty = Math.Max(penalty, kalmagun - maxPeriodTotal);
            }

            cezagun = penalty;
            if (maxOneTime > 0) Visaday = maxOneTime;

            int hgun = cezagun;
            if (cezagun > 30)
            {
                cezaay = cezagun / 30;
                cezagun = cezagun % 30;
            }
            else if (cezagun > 0)
                cezaay = 0;
            else
                return Json(new { Type = "0", Message = "Cezalı Süresi Yoktur..!" }, JsonRequestBehavior.AllowGet);

            return Json(new
            {
                Type = "1",
                Day = dayVal,
                Daylong = longVal,
                OneTime = Visaday,
                BasDate = currentTripEntry.ToString("dd.MM.yyyy"),
                ShoulExtiTime = exitdt.AddDays(-hgun).ToString("dd.MM.yyyy"),
                FarkAy = cezaay,
                FarkGun = cezagun,
                Seferler = seferler
            }, JsonRequestBehavior.AllowGet);
        }

        [Route("Kodgetir")]
        public JsonResult Kodgetir(string Cezagun, string Cezaay, int Tip, int Adult)
        {
            ContTKod kod = new ContTKod();
            int Gun = 0;
            bool Adultmu;
            if (Adult == 1) Adultmu = false;
            else Adultmu = true;
            Gun = Convert.ToInt32(Cezagun) + (Convert.ToInt32(Cezaay) * 30);
            byte tipitip = Convert.ToByte(Tip);
            var result = kod.GetTkodBydays(Gun, tipitip);
            if (result == null) return Json(new { Type = "0", Rslt = "Hesaplama bilgilerine göre kod datası bulunamadı..." }, JsonRequestBehavior.AllowGet);
            else
            {
                if (Adultmu) return Json(new { Type = "1", Code = result.fldCode, Rslt = "Tahdit kodu = <strong>" + result.fldCode + ".</strong> İdari tahdit kodu = <strong> " + result.fldIdariCode + ".</strong> Cezalı süre = <strong>" + result.fldPTime + " gün.</strong>", CZ = result.fldPTime }, JsonRequestBehavior.AllowGet);
                else return Json(new { Type = "1", Code = "---", Rslt = "Tahdit kodu = <strong>---.</strong> İdari tahdit kodu = <strong> " + result.fldIdariCode + ".</strong> Cezalı süre = <strong>0 gün.</strong>", CZ = 0 }, JsonRequestBehavior.AllowGet);
            }
        }

        [Route("addhistory")]
        public JsonResult addhistory(string bas, string sexit, string bdate, string csure, string ttutar, string country)
        {
            try
            {
                var userdata = GetUser();
                Isk isk = new Isk();
                DateTime dtbas, dtsexit, dtbdate;
                if (!TryParseCalculationDate(bas, out dtbas)) dtbas = DateTime.Now;
                if (!TryParseCalculationDate(sexit, out dtsexit)) dtsexit = DateTime.Now;
                if (!TryParseCalculationDate(bdate, out dtbdate)) dtbdate = new DateTime(1900, 1, 1);

                var fullname = userdata != null ? (userdata.fldName + " " + userdata.fldLastName).Trim() : "";
                var border = userdata != null ? userdata.fldBorder : "";
                var sicil = userdata != null ? (userdata.fldSicil ?? "") : "";
                var userKey = sicil + "|" + fullname;
                isk.Addhistory(dtbas, dtsexit, dtbdate, csure, ttutar, userKey, border, country);
                return Json(new { success = true }, JsonRequestBehavior.AllowGet);
            }
            catch
            {
                return Json(new { success = false }, JsonRequestBehavior.AllowGet);
            }
        }

        [Route("Calculate2")]
        public JsonResult Calculate2(string Country, string Ticket, int Type, int Passport, int Visa, int CTtype, string Enter, bool V137Expired = false)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(Country) || string.IsNullOrWhiteSpace(Ticket))
                {
                    return Json(new { toplam = "0", ID = "0", VH = "0", DFTR = "0", CTL = 0, Fine = 0, ToM = "", KurPrice = "1", Kur = "" }, JsonRequestBehavior.AllowGet);
                }

                UlkeModel ulke = new UlkeModel();
                contauh contauh = new contauh();
                ContExchange exchange = new ContExchange();
                var AUHdata = contauh.Check(0, Country);
                if (AUHdata == null)
                {
                    return Json(new { toplam = "0", ID = "0", VH = "0", DFTR = "0", CTL = 0, Fine = 0, ToM = "", KurPrice = "1", Kur = "" }, JsonRequestBehavior.AllowGet);
                }

                double Ceza = 0;
                int Gun = 0, Ay = 0;
                string t = Ticket.Trim();

                if (t.IndexOf("Ay", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    var match = System.Text.RegularExpressions.Regex.Match(t, @"\d+");
                    if (match.Success) int.TryParse(match.Value, out Ay);
                    if (Array.IndexOf(ulke.GGRUBU, Country) > -1)
                    {
                        Ceza = Convert.ToDouble(AUHdata.fldFirstMounth);
                        if (Type != 1) Ceza = Ceza * 2;
                    }
                    else
                    {
                        for (int i = 0; i < Ay; i++)
                        {
                            if (i == 0) Ceza = Convert.ToDouble(AUHdata.fldFirstMounth);
                            else Ceza += Convert.ToDouble(AUHdata.fldKat);
                        }
                        Ceza = Ceza * Convert.ToDouble(Type);
                    }
                }
                else
                {
                    var match = System.Text.RegularExpressions.Regex.Match(t, @"\d+");
                    if (match.Success) int.TryParse(match.Value, out Gun);
                    Ceza = Convert.ToDouble(AUHdata.fldDayStart);
                    if (Array.IndexOf(ulke.AGRUBU, Country) > -1 || Array.IndexOf(ulke.EGRUBU, Country) > -1)
                    {
                        for (int i = 1; i < Gun + 1; i++)
                        {
                            if (i > 10 && i < 26) Ceza += Convert.ToDouble(AUHdata.fldDayKat);
                            if (i == 26) Ceza = Math.Ceiling(Ceza);
                        }
                    }
                    else if (Array.IndexOf(ulke.BGRUBU, Country) > -1)
                    {
                        for (int i = 1; i < Gun + 1; i++)
                        {
                            if (i > 10 && i < 29) Ceza += Convert.ToDouble(AUHdata.fldDayKat);
                            if (i == 29) Ceza = Math.Ceiling(Ceza);
                        }
                    }
                    else if (Array.IndexOf(ulke.CGRUBU, Country) > -1)
                    {
                        for (int i = 1; i < Gun + 1; i++)
                        {
                            if (i > 10 && i < 24) Ceza += Convert.ToDouble(AUHdata.fldDayKat);
                            if (i == 24) Ceza = Math.Ceiling(Ceza);
                        }
                    }
                    else if (Array.IndexOf(ulke.DGRUBU, Country) > -1)
                    {
                        for (int i = 1; i < Gun + 1; i++)
                        {
                            if (i > 10 && i < 25) Ceza += Convert.ToDouble(AUHdata.fldDayKat);
                            if (i == 25) Ceza = Math.Ceiling(Ceza);
                        }
                    }
                    else if (Array.IndexOf(ulke.FGRUBU, Country) > -1)
                    {
                        for (int i = 1; i < Gun + 1; i++)
                        {
                            if (i > 1 && i < 9) Ceza += Convert.ToDouble(AUHdata.fldDayKat);
                            else if (i == 9) Ceza += Convert.ToDouble(467.6);
                            if (i == 10) Ceza = Math.Ceiling(Ceza);
                        }
                    }
                    else if (Array.IndexOf(ulke.GGRUBU, Country) > -1)
                    {
                        Ceza = Convert.ToDouble(AUHdata.fldFirstMounth);
                    }
                    if (Array.IndexOf(ulke.GGRUBU, Country) > -1)
                    {
                        if (Type != 1) Ceza = Ceza * 2;
                    }
                    else Ceza = Ceza * Convert.ToDouble(Type);
                    Ceza = Math.Round(Ceza, 2);
                }

                var ExchangeData = exchange.GetAllExchange();

                double cezatl = 0;
                string Kurr = "",
                     KurP = "",
                     VizeHarc = "0",
                     Idari = "0",
                     Defter = "0";
                Kurr = AUHdata.fldToM;
                if (AUHdata.fldToM == "EUR") { KurP = ExchangeData.fldEuro; }
                else if (AUHdata.fldToM == "USD") { KurP = ExchangeData.fldDollar; }
                else if (AUHdata.fldToM == "GBP") { KurP = ExchangeData.fldPaund; }
                else if (AUHdata.fldToM == "TRY") { KurP = "1"; }

                cezatl = Math.Round(Convert.ToDouble(Ceza) * Convert.ToDouble(KurP), 2);
                Contuvr contuvr = new Contuvr();
                tgvh tgvh = new tgvh();
                var uvrRecord = contuvr.check(0, Country, Passport, Visa, CTtype);
                if (uvrRecord != null && uvrRecord.fldHB == 1)
                {
                    DateTime parsedEnter;
                    string enterYear = TryParseCalculationDate(Enter, out parsedEnter)
                        ? parsedEnter.ToString("yyyy")
                        : DateTime.Now.ToString("yyyy");
                    var harcdata = tgvh.checkTGVH(enterYear);
                    if (harcdata == null) harcdata = tgvh.GetTGVH().OrderByDescending(c => c.fldYear).Take(1).SingleOrDefault();
                    VizeHarc = (harcdata != null) ? harcdata.fldPrice.ToString() : "0";
                }
                if (Visa != 4 && Visa != 8 && Visa != 10 && Visa != 12 && Visa != 14 && Visa != 15) Defter = tgvh.GetDefter().fldPrice.ToString();
                double Toplam = Convert.ToDouble(cezatl) + Convert.ToDouble(Defter) + Convert.ToDouble(VizeHarc);
                if ((Visa == 11 || Visa == 13) && V137Expired) Idari = "20605";
                Toplam += Convert.ToDouble(Idari);
                return Json(new { toplam = Toplam.ToString(), ID = Idari, VH = VizeHarc, DFTR = Defter, CTL = cezatl, Fine = Ceza, ToM = AUHdata.fldToM, KurPrice = KurP, Kur = Kurr }, JsonRequestBehavior.AllowGet);
            }
            catch
            {
                return Json(new { toplam = "0", ID = "0", VH = "0", DFTR = "0", CTL = 0, Fine = 0, ToM = "", KurPrice = "1", Kur = "" }, JsonRequestBehavior.AllowGet);
            }
        }
    }
}
