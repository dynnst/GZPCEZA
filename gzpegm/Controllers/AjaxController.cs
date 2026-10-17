using gzpegm.Cont;
using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize]
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
            int[] seferler = new int[form["EnterDateCalculate"].Split(',').Length];
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

            // Visa tipi kontrolü
            if (Visa == 3)
                Visaday = Convert.ToInt32(form["Visaday"]);
            // ✅ V-137 Vize Süreli (13) eklendi
            else if (Visa == 4 || Visa == 8 || Visa == 10 || Visa == 11 || Visa == 12 || Visa == 13 || Visa == 14 || Visa == 15)
            {
                enterdates = form["testarihi"];
                exitdates = exitdates.Split(',')[exitdates.Split(',').Length - 1];
            }

            DateTime enterdt = DateTime.Now, exitdt = DateTime.Now;
            Contuvr contuvr = new Contuvr();

            string[] entryDateValues = enterdates.Split(',');
            string[] exitDateValues = exitdates.Split(',');
            if (entryDateValues.Length != exitDateValues.Length)
                return Json(new { Type = "0", Message = "Giriş ve çıkış tarihleri eşleşmiyor..!" }, JsonRequestBehavior.AllowGet);

            var trips = new List<Tuple<DateTime, DateTime>>();
            for (int i = 0; i < entryDateValues.Length; i++)
            {
                if (entryDateValues[i] == "" || exitDateValues[i] == "")
                    return Json(new { Type = "0", Message = "Tarihlerde boş bırakmayınız..!" }, JsonRequestBehavior.AllowGet);

                if (!TryParseCalculationDate(entryDateValues[i], out enterdt) ||
                    !TryParseCalculationDate(exitDateValues[i], out exitdt))
                    return Json(new { Type = "0", Message = "Tarih biçimi geçersiz..!" }, JsonRequestBehavior.AllowGet);

                if (enterdt > exitdt)
                    return Json(new { Type = "0", Message = "Tarihlerde yanlışlık var lütfen kontrol ediniz.!" }, JsonRequestBehavior.AllowGet);

                trips.Add(Tuple.Create(enterdt.Date, exitdt.Date));
            }

            bool isMultipleEntryExit = trips.Count > 1;
            DateTime referenceExit = trips.Max(x => x.Item2);
            DateTime windowStart = referenceExit.AddDays(-179);

            foreach (var trip in trips)
            {
                DateTime countedEntry = trip.Item1;
                DateTime countedExit = trip.Item2;

                if (isMultipleEntryExit)
                {
                    // Schengen penceresi, en son çıkış günü dahil 180 takvim günüdür.
                    if (countedEntry < windowStart) countedEntry = windowStart;
                    if (countedExit > referenceExit) countedExit = referenceExit;
                }

                int farkGun;
                if (countedEntry > countedExit)
                {
                    // 180 günlük pencerenin tamamen dışında kalan kayıt yok sayılır.
                    farkGun = 0;
                }
                else
                {
                    // Saat bilgileri yok sayılır. Giriş günü sayılır, çıkış günü sayılmaz.
                    // İş kuralı gereği aynı gün giriş-çıkış 1 gün kabul edilir.
                    // Çoklu kayıtta her döneme ayrıca +1 eklenmez.
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

            // Sonraki tarih hesaplamalarında her zaman en son çıkış referans alınır.
            exitdt = referenceExit;

            var UVRdata = contuvr.check(0, Country, Passport, Visa, Ctype);

            if (Ctype == 4) Visaday = 0;
            else if (Visaday == 0 && UVRdata != null)
                Visaday = Convert.ToInt32(UVRdata.fldOneTime);

            if (UVRdata == null)
                return Json(new { Type = "0", Message = "Belirtilen bilgilere ait hesaplama bilgisi mevcut değildir..!" }, JsonRequestBehavior.AllowGet);

            // Beyaz Rusya özel kuralları
            if (Country == "Beyaz Rusya")
            {
                int maxOneTime = 30;
                int maxYearTotal = 90;
                int penalty = 0;

                for (int i = 0; i < seferler.Length; i++)
                {
                    if (seferler[i] > maxOneTime)
                        penalty += seferler[i] - maxOneTime;
                }

                if (kalmagun > maxYearTotal)
                    penalty = Math.Max(penalty, kalmagun - maxYearTotal);

                cezagun = penalty;
            }
            else
            {
                int check = 0;
                foreach (int d in seferler)
                {
                    if (d > Visaday)
                    {
                        cezagun = kalmagun - Visaday;
                        check = 1;
                        break;
                    }
                }

                if (check == 0 && kalmagun > Convert.ToInt32(UVRdata.fldLong))
                    cezagun = kalmagun - Convert.ToInt32(UVRdata.fldLong);
            }

            int hgun = cezagun;
            if (cezagun > 30)
            {
                cezaay = cezagun / 30;
                cezagun = cezagun % 30;
            }
            else if (Visa == 4 && cezagun < 0)
                return Json(new { Type = "0", Message = "İkamet teskeresi bitiş tarihinden veya tebliğ tarihinden itibaren 10 günden fazla süre geçmemiştir. Bu yüzden Cezalı Süresi Yoktur..!" }, JsonRequestBehavior.AllowGet);
            else if (Visa == 4 && cezagun > 0)
                cezagun -= 0;
            else if (cezagun > 0)
                cezaay = 0;
            else
                return Json(new { Type = "0", Message = "Cezalı Süresi Yoktur..!" }, JsonRequestBehavior.AllowGet);

            return Json(new
            {
                Type = "1",
                Day = UVRdata.fldDay,
                Daylong = UVRdata.fldLong,
                OneTime = Visaday,
                ShoulExtiTime = exitdt.AddDays(-hgun).ToString("dd.MM.yyyy"),
                FarkAy = cezaay,
                FarkGun = cezagun
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
                else return Json(new { Type = "1", Code = result.fldCode, Rslt = "Tahdit kodu = <strong>---.</strong> İdari tahdit kodu = <strong> " + result.fldIdariCode + ".</strong> Cezalı süre = <strong>0 gün.</strong>", CZ = result.fldPTime }, JsonRequestBehavior.AllowGet);
            }
        }
        [Route("addhistory")]
        public JsonResult addhistory(string bas, string sexit, string bdate, string csure, string ttutar, string country)
        {
            var userdata = GetUser();
            Isk isk = new Isk();
            DateTime dtbas = Convert.ToDateTime(bas),
                dtsexit = Convert.ToDateTime(sexit),
                dtbdate = Convert.ToDateTime(bdate);
            // Store stable identifier (fldSicil) together with display name so name changes won't break stats
            var fullname = (userdata.fldName + " " + userdata.fldLastName).Trim();
            var userKey = (userdata.fldSicil ?? "") + "|" + fullname;
            isk.Addhistory(dtbas, dtsexit, dtbdate, csure, ttutar, userKey, userdata.fldBorder, country);
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }
        [Route("Calculate2")]
        public JsonResult Calculate2(string Country, string Ticket, int Type, int Passport, int Visa, int CTtype, string Enter, bool V137Expired = false)
        {
            UlkeModel ulke = new UlkeModel();
            contauh contauh = new contauh();
            ContExchange exchange = new ContExchange();
            var AUHdata = contauh.Check(0, Country);
            double Ceza = 0;
            int Gun = 0, Ay = 0;
            if (Ticket.Contains("Ay"))
            {
                Ticket = Ticket.Remove(Ticket.Length - 3);
                int.TryParse(Ticket, out Ay);
                if (Array.IndexOf(ulke.GGRUBU, Country) > -1)
                {
                    Ceza = Convert.ToDouble(AUHdata.fldFirstMounth);
                    Ceza = Ceza * 2;
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
                Ticket = Ticket.Remove(Ticket.Length - 4);
                int.TryParse(Ticket, out Gun);
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
                if (Array.IndexOf(ulke.GGRUBU, Country) > -1) Ceza = Ceza * 2;
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
            if (contuvr.check(0, Country, Passport, Visa, CTtype).fldHB == 1)
            {
                var harcdata = tgvh.checkTGVH(Convert.ToDateTime(Enter).ToString("yyyy"));
                if (harcdata == null) harcdata = tgvh.GetTGVH().OrderByDescending(c => c.fldYear).Take(1).SingleOrDefault();
                VizeHarc = harcdata.fldPrice.ToString();
            }
            if (Visa != 4 && Visa != 10 && Visa != 12 && Visa != 14 && Visa != 15) Defter = tgvh.GetDefter().fldPrice.ToString();
            double Toplam = Convert.ToDouble(cezatl) + Convert.ToDouble(Defter) + Convert.ToDouble(VizeHarc);
            if ((Visa == 11 || Visa == 13) && V137Expired) Idari = "20605";
            Toplam += Convert.ToDouble(Idari);
            return Json(new { toplam = Toplam.ToString(), ID = Idari, VH = VizeHarc, DFTR = Defter, CTL = cezatl, Fine = Ceza, ToM = AUHdata.fldToM, KurPrice = KurP, Kur = Kurr }, JsonRequestBehavior.AllowGet);

        }
    }
}
