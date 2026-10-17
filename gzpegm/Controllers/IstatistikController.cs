using gzpegm.Helpers;
using gzpegm.Models;
using gzpegm.Services;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Globalization;
using System.Linq;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    public class IstatistikController : Controller
    {
        private class RecentActivity
        {
            public string User { get; set; }
            public string Border { get; set; }
            public string Type { get; set; }
            public DateTime? Date { get; set; }
        }

        private class BorderChartItem
        {
            public string Border { get; set; }
            public int Count { get; set; }
        }

        [Serializable]
        public class MacroStatsDto
        {
            public int PersonelSayisi { get; set; }
            public int V84Sayisi { get; set; }
            public int HesaplamaSayisi { get; set; }
            public int KesilenToplamCeza { get; set; }
            public int InadSayisi { get; set; }
            public int AktifPersonelSayisi { get; set; }
            public string EnCokCezaKesenPersonel { get; set; }
            public string EnCokV84DuzenleyenPersonel { get; set; }
            public string EnCokCezaKesilenUlke { get; set; }
            public int EnCokCezaKesilenUlkeSayi { get; set; }
            public string EnAzCezaKesilenUlke { get; set; }
            public int EnAzCezaKesilenUlkeSayi { get; set; }
            public string GenelToplamPara { get; set; }
        }

        [Serializable]
        public class ChartResultDto
        {
            public List<string> labels { get; set; } = new List<string>();
            public List<int> sayilar { get; set; } = new List<int>();
        }

        [Serializable]
        public class GunlukTrendDto
        {
            public List<string> labels { get; set; } = new List<string>();
            public List<int> cezaSayilari { get; set; } = new List<int>();
            public List<int> hesaplamaSayilari { get; set; } = new List<int>();
            public List<decimal> cezaTutarlari { get; set; } = new List<decimal>();
        }

        [Serializable]
        public class AylikTrendDto
        {
            public List<string> labels { get; set; } = new List<string>();
            public List<int> cezaSayilari { get; set; } = new List<int>();
            public List<int> v84Sayilari { get; set; } = new List<int>();
        }

        [Serializable]
        public class RadarDto
        {
            public List<string> labels { get; set; } = new List<string>();
            public List<int> cezaSayilari { get; set; } = new List<int>();
            public List<int> v84Sayilari { get; set; } = new List<int>();
        }

        // GET: Istatistik
        [HttpGet]
        [Route("ISTATIK")]
        public ActionResult Index()
        {
            var bugunBaslangic = DateTime.Today;
            var yarinBaslangic = bugunBaslangic.AddDays(1);

            // 1. Makro toplamlar - 15 dakika boyunca RAM'den hızlı servis edilir
            var macro = CacheService.GetOrCreate("Istatistik_MacroStats_v2", () =>
            {
                using (var c = new GZPEGM1())
                {
                    var dto = new MacroStatsDto();
                    dto.PersonelSayisi = c.E_User.Count();
                    dto.V84Sayisi = c.E_Sartli.Count();
                    dto.HesaplamaSayisi = c.E_History.Count();
                    dto.KesilenToplamCeza = c.E_IsK.Count();
                    dto.InadSayisi = c.E_Inad.Count();
                    dto.AktifPersonelSayisi = c.E_User.Count(x => x.IsActive == true || x.fldActive == "1");

                    dto.EnCokCezaKesenPersonel = c.E_IsK.AsNoTracking()
                        .Where(x => x.fldApproval != null && x.fldApproval.Trim() != "")
                        .GroupBy(x => x.fldApproval)
                        .OrderByDescending(g => g.Count())
                        .Select(g => g.Key)
                        .FirstOrDefault() ?? "-";

                    dto.EnCokV84DuzenleyenPersonel = c.E_Sartli.AsNoTracking()
                        .Where(x => x.fldBy != null && x.fldBy.Trim() != "")
                        .GroupBy(x => x.fldBy)
                        .OrderByDescending(g => g.Count())
                        .Select(g => g.Key)
                        .FirstOrDefault() ?? "-";

                    var enCokUlke = c.E_IsK.AsNoTracking()
                        .Where(x => x.fldOrgin != null && x.fldOrgin.Trim() != "")
                        .GroupBy(x => x.fldOrgin)
                        .Select(g => new { Ulke = g.Key, Sayi = g.Count() })
                        .OrderByDescending(x => x.Sayi)
                        .FirstOrDefault();

                    dto.EnCokCezaKesilenUlke = enCokUlke != null ? enCokUlke.Ulke : "-";
                    dto.EnCokCezaKesilenUlkeSayi = enCokUlke != null ? enCokUlke.Sayi : 0;

                    var enAzUlke = c.E_IsK.AsNoTracking()
                        .Where(x => x.fldOrgin != null && x.fldOrgin.Trim() != "")
                        .GroupBy(x => x.fldOrgin)
                        .Select(g => new { Ulke = g.Key, Sayi = g.Count() })
                        .OrderBy(x => x.Sayi)
                        .FirstOrDefault();

                    dto.EnAzCezaKesilenUlke = enAzUlke != null ? enAzUlke.Ulke : "-";
                    dto.EnAzCezaKesilenUlkeSayi = enAzUlke != null ? enAzUlke.Sayi : 0;

                    var tumTutarlar = c.E_History.AsNoTracking().Select(x => x.fldPMoney).ToList();
                    dto.GenelToplamPara = ParaTopla(tumTutarlar).ToString("N2", CultureInfo.GetCultureInfo("tr-TR"));

                    return dto;
                }
            }, 15);

            ViewBag.personelsayisi = macro.PersonelSayisi;
            ViewBag.v84sayisi = macro.V84Sayisi;
            ViewBag.hesaplamasayisi = macro.HesaplamaSayisi;
            ViewBag.KesilenToplamCeza = macro.KesilenToplamCeza;
            ViewBag.inadsayisi = macro.InadSayisi;
            ViewBag.aktifpersonelsayisi = macro.AktifPersonelSayisi;
            ViewBag.d13 = macro.EnCokCezaKesenPersonel;
            ViewBag.v84encokpersonel = macro.EnCokV84DuzenleyenPersonel;
            ViewBag.encokulkehangi = macro.EnCokCezaKesilenUlke;
            ViewBag.encokulkesayi = macro.EnCokCezaKesilenUlkeSayi;
            ViewBag.enazulkehangi = macro.EnAzCezaKesilenUlke;
            ViewBag.enazkulkesayi = macro.EnAzCezaKesilenUlkeSayi;
            ViewBag.toplam = macro.GenelToplamPara;

            // 2. Canlı veriler - sadece bugünün küçük dilimi çekilir (çok hızlı)
            using (var c = new GZPEGM1())
            {
                var recentActivities = new List<RecentActivity>();
                recentActivities.AddRange(c.E_History.AsNoTracking()
                    .Where(x => x.fldDatetime != null)
                    .OrderByDescending(x => x.fldDatetime)
                    .Take(1)
                    .Select(x => new RecentActivity { User = x.fldUser, Border = x.fldBorder, Type = "Hesaplama", Date = x.fldDatetime })
                    .ToList());

                recentActivities.AddRange(c.E_IsK.AsNoTracking()
                    .Where(x => x.fldDatetime != null)
                    .OrderByDescending(x => x.fldDatetime)
                    .Take(1)
                    .Select(x => new RecentActivity { User = x.fldApproval, Border = x.fldBorder, Type = "Ceza", Date = x.fldDatetime })
                    .ToList());

                recentActivities.AddRange(c.E_Inad.AsNoTracking()
                    .Where(x => x.TarihSaat != null)
                    .OrderByDescending(x => x.TarihSaat)
                    .Take(1)
                    .Select(x => new RecentActivity { User = x.Sicil, Border = x.Kapi, Type = "INAD", Date = x.TarihSaat })
                    .ToList());

                recentActivities.AddRange(c.E_Sartli.AsNoTracking()
                    .Where(x => x.fldDate != null)
                    .OrderByDescending(x => x.fldDate)
                    .Take(1)
                    .Select(x => new RecentActivity { User = x.fldBy, Border = x.fldBorder, Type = "V-84", Date = x.fldDate })
                    .ToList());

                var sonIslem = recentActivities.OrderByDescending(x => x.Date).FirstOrDefault();
                if (sonIslem != null)
                {
                    ViewBag.islemyapansonper = HistoryUserHelper.GetDisplayName(sonIslem.User);
                    ViewBag.d11 = sonIslem.Date;
                    ViewBag.d12 = sonIslem.Type + " / " + (sonIslem.Border ?? "-");
                }
                else
                {
                    ViewBag.islemyapansonper = "-";
                    ViewBag.d11 = null;
                    ViewBag.d12 = "-";
                }

                // Bugünün sayıları
                ViewBag.bugunsartli = c.E_Sartli.Count(x => x.fldDate >= bugunBaslangic && x.fldDate < yarinBaslangic);
                ViewBag.buguninad = c.E_Inad.Count(x => x.TarihSaat >= bugunBaslangic && x.TarihSaat < yarinBaslangic);
                ViewBag.d14 = c.E_IsK.Count(x => x.fldDatetime >= bugunBaslangic && x.fldDatetime < yarinBaslangic);
                ViewBag.d15 = c.E_History.Count(x => x.fldDatetime >= bugunBaslangic && x.fldDatetime < yarinBaslangic);

                // Bugün hesaplanan ceza tutarı
                var bugunTutarlar = c.E_History.AsNoTracking()
                    .Where(x => x.fldDatetime >= bugunBaslangic && x.fldDatetime < yarinBaslangic)
                    .Select(x => x.fldPMoney)
                    .ToList();

                var bugunToplam = ParaTopla(bugunTutarlar);
                ViewBag.d1 = bugunToplam.ToString("N2", CultureInfo.GetCultureInfo("tr-TR"));
            }

            return View();
        }

        // ============================================================
        // Grafik JSON metotları (Önbellekli ve Optimize Edilmiş)
        // ============================================================

        /// <summary>
        /// Son 7 günlük ceza ve hesaplama sayıları.
        /// </summary>
        [HttpGet]
        public JsonResult GunlukTrend()
        {
            var result = CacheService.GetOrCreate("Istatistik_GunlukTrend_v2", () =>
            {
                using (var c = new GZPEGM1())
                {
                    var bugun = DateTime.Today;
                    var startDate = bugun.AddDays(-6);
                    var endDate = bugun.AddDays(1);

                    // 21 SQL sorgusu yerine tek seferde 7 günlük veriyi çekiyoruz
                    var iskDates = c.E_IsK.AsNoTracking()
                        .Where(x => x.fldDatetime >= startDate && x.fldDatetime < endDate)
                        .Select(x => x.fldDatetime)
                        .ToList();

                    var historyItems = c.E_History.AsNoTracking()
                        .Where(x => x.fldDatetime >= startDate && x.fldDatetime < endDate)
                        .Select(x => new { x.fldDatetime, x.fldPMoney })
                        .ToList();

                    var dto = new GunlukTrendDto();

                    for (var i = 6; i >= 0; i--)
                    {
                        var gunBaslangic = bugun.AddDays(-i);
                        var sonrakiGun = gunBaslangic.AddDays(1);

                        dto.labels.Add(gunBaslangic.ToString("dd.MM"));

                        var cezaSayisi = iskDates.Count(d => d >= gunBaslangic && d < sonrakiGun);
                        dto.cezaSayilari.Add(cezaSayisi);

                        var gunlukHistory = historyItems.Where(h => h.fldDatetime >= gunBaslangic && h.fldDatetime < sonrakiGun).ToList();
                        dto.hesaplamaSayilari.Add(gunlukHistory.Count);

                        var gunlukTutarlar = gunlukHistory.Select(h => h.fldPMoney);
                        dto.cezaTutarlari.Add(Math.Round(ParaTopla(gunlukTutarlar), 2));
                    }

                    return dto;
                }
            }, 10);

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        /// <summary>
        /// Son 6 aylık ceza ve V-84 sayıları.
        /// </summary>
        [HttpGet]
        public JsonResult AylikTrend()
        {
            var result = CacheService.GetOrCreate("Istatistik_AylikTrend_v2", () =>
            {
                using (var c = new GZPEGM1())
                {
                    var simdi = DateTime.Now;
                    var startMonth = new DateTime(simdi.Year, simdi.Month, 1).AddMonths(-5);

                    // 12 SQL sorgusu yerine tek seferde 6 aylık veriyi çekiyoruz
                    var iskDates = c.E_IsK.AsNoTracking()
                        .Where(x => x.fldDatetime >= startMonth)
                        .Select(x => x.fldDatetime)
                        .ToList();

                    var sartliDates = c.E_Sartli.AsNoTracking()
                        .Where(x => x.fldDate >= startMonth)
                        .Select(x => x.fldDate)
                        .ToList();

                    var dto = new AylikTrendDto();

                    for (var i = 5; i >= 0; i--)
                    {
                        var ay = simdi.AddMonths(-i);
                        var ayBaslangic = new DateTime(ay.Year, ay.Month, 1);
                        var sonrakiAy = ayBaslangic.AddMonths(1);

                        dto.labels.Add(ayBaslangic.ToString("MM/yyyy"));
                        dto.cezaSayilari.Add(iskDates.Count(d => d >= ayBaslangic && d < sonrakiAy));
                        dto.v84Sayilari.Add(sartliDates.Count(d => d >= ayBaslangic && d < sonrakiAy));
                    }

                    return dto;
                }
            }, 30);

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        /// <summary>
        /// En çok ceza kesilen ilk 8 ülke.
        /// </summary>
        [HttpGet]
        public JsonResult UlkeDagilimi()
        {
            var result = CacheService.GetOrCreate("Istatistik_UlkeDagilimi_v2", () =>
            {
                using (var c = new GZPEGM1())
                {
                    var veriler = c.E_IsK.AsNoTracking()
                        .Where(x => x.fldOrgin != null && x.fldOrgin.Trim() != "")
                        .GroupBy(x => x.fldOrgin)
                        .Select(g => new { Ulke = g.Key, Sayi = g.Count() })
                        .OrderByDescending(x => x.Sayi)
                        .Take(8)
                        .ToList();

                    return new ChartResultDto
                    {
                        labels = veriler.Select(x => x.Ulke).ToList(),
                        sayilar = veriler.Select(x => x.Sayi).ToList()
                    };
                }
            }, 15);

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        /// <summary>
        /// En az ceza kesilen ilk 5 ülke.
        /// </summary>
        [HttpGet]
        public JsonResult UlkeDagilimiAz()
        {
            var result = CacheService.GetOrCreate("Istatistik_UlkeDagilimiAz_v2", () =>
            {
                using (var c = new GZPEGM1())
                {
                    var veriler = c.E_IsK.AsNoTracking()
                        .Where(x => x.fldOrgin != null && x.fldOrgin.Trim() != "")
                        .GroupBy(x => x.fldOrgin)
                        .Select(g => new { Ulke = g.Key, Sayi = g.Count() })
                        .OrderBy(x => x.Sayi)
                        .Take(5)
                        .ToList();

                    return new ChartResultDto
                    {
                        labels = veriler.Select(x => x.Ulke).ToList(),
                        sayilar = veriler.Select(x => x.Sayi).ToList()
                    };
                }
            }, 15);

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        /// <summary>
        /// Personel bazında ilk 10 ceza sıralaması.
        /// </summary>
        [HttpGet]
        public JsonResult PersonelSiralamasi()
        {
            var result = CacheService.GetOrCreate("Istatistik_PersonelSiralamasi_v2", () =>
            {
                using (var c = new GZPEGM1())
                {
                    var veriler = c.E_IsK.AsNoTracking()
                        .Where(x => x.fldApproval != null && x.fldApproval.Trim() != "")
                        .GroupBy(x => x.fldApproval)
                        .Select(g => new { Personel = g.Key, Sayi = g.Count() })
                        .OrderByDescending(x => x.Sayi)
                        .Take(10)
                        .ToList();

                    return new ChartResultDto
                    {
                        labels = veriler.Select(x => x.Personel).ToList(),
                        sayilar = veriler.Select(x => x.Sayi).ToList()
                    };
                }
            }, 10);

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        /// <summary>
        /// İNAD uyruk dağılımı.
        /// </summary>
        [HttpGet]
        public JsonResult InadUyrukDagilimi()
        {
            var result = CacheService.GetOrCreate("Istatistik_InadUyrukDagilimi_v2", () =>
            {
                using (var c = new GZPEGM1())
                {
                    var veriler = c.E_Inad.AsNoTracking()
                        .Where(x => x.Uyruk != null && x.Uyruk.Trim() != "")
                        .GroupBy(x => x.Uyruk.Trim())
                        .Select(g => new { Uyruk = g.Key, Sayi = g.Count() })
                        .OrderByDescending(x => x.Sayi)
                        .Take(6)
                        .ToList();

                    return new ChartResultDto
                    {
                        labels = veriler.Select(x => x.Uyruk).ToList(),
                        sayilar = veriler.Select(x => x.Sayi).ToList()
                    };
                }
            }, 15);

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        /// <summary>
        /// İNAD kapı dağılımı.
        /// </summary>
        [HttpGet]
        public JsonResult InadKapiDagilimi()
        {
            var result = CacheService.GetOrCreate("Istatistik_InadKapiDagilimi_v2", () =>
            {
                using (var c = new GZPEGM1())
                {
                    var veriler = c.E_Inad.AsNoTracking()
                        .Where(x => x.Kapi != null && x.Kapi.Trim() != "")
                        .GroupBy(x => x.Kapi.Trim())
                        .Select(g => new { Kapi = g.Key, Sayi = g.Count() })
                        .OrderByDescending(x => x.Sayi)
                        .Take(8)
                        .ToList();

                    return new ChartResultDto
                    {
                        labels = veriler.Select(x => x.Kapi).ToList(),
                        sayilar = veriler.Select(x => x.Sayi).ToList()
                    };
                }
            }, 15);

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult IslemTipiDagilimi()
        {
            var result = CacheService.GetOrCreate("Istatistik_IslemTipiDagilimi_v2", () =>
            {
                using (var c = new GZPEGM1())
                {
                    return new ChartResultDto
                    {
                        labels = new List<string> { "Ceza", "Hesaplama", "INAD", "V-84" },
                        sayilar = new List<int>
                        {
                            c.E_IsK.Count(),
                            c.E_History.Count(),
                            c.E_Inad.Count(),
                            c.E_Sartli.Count()
                        }
                    };
                }
            }, 10);

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult BugunIslemDagilimi()
        {
            var result = CacheService.GetOrCreate("Istatistik_BugunIslemDagilimi_v2", () =>
            {
                using (var c = new GZPEGM1())
                {
                    var bugun = DateTime.Today;
                    var yarin = bugun.AddDays(1);

                    return new ChartResultDto
                    {
                        labels = new List<string> { "Ceza", "Hesaplama", "INAD", "V-84" },
                        sayilar = new List<int>
                        {
                            c.E_IsK.Count(x => x.fldDatetime >= bugun && x.fldDatetime < yarin),
                            c.E_History.Count(x => x.fldDatetime >= bugun && x.fldDatetime < yarin),
                            c.E_Inad.Count(x => x.TarihSaat >= bugun && x.TarihSaat < yarin),
                            c.E_Sartli.Count(x => x.fldDate >= bugun && x.fldDate < yarin)
                        }
                    };
                }
            }, 2); // 2 dakika önbellek

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult KapiGenelDagilimi()
        {
            var result = CacheService.GetOrCreate("Istatistik_KapiGenelDagilimi_v2", () =>
            {
                using (var c = new GZPEGM1())
                {
                    var sql = @"
SELECT TOP 10
    Border,
    SUM([Count]) AS [Count]
FROM
(
    SELECT LTRIM(RTRIM(fldBorder)) AS Border, COUNT(1) AS [Count]
    FROM dbo.E_IsK
    WHERE NULLIF(LTRIM(RTRIM(fldBorder)), '') IS NOT NULL
    GROUP BY LTRIM(RTRIM(fldBorder))

    UNION ALL

    SELECT LTRIM(RTRIM(fldBorder)) AS Border, COUNT(1) AS [Count]
    FROM dbo.E_History
    WHERE NULLIF(LTRIM(RTRIM(fldBorder)), '') IS NOT NULL
    GROUP BY LTRIM(RTRIM(fldBorder))

    UNION ALL

    SELECT LTRIM(RTRIM(Kapi)) AS Border, COUNT(1) AS [Count]
    FROM dbo.E_Inad
    WHERE NULLIF(LTRIM(RTRIM(Kapi)), '') IS NOT NULL
    GROUP BY LTRIM(RTRIM(Kapi))

    UNION ALL

    SELECT LTRIM(RTRIM(fldBorder)) AS Border, COUNT(1) AS [Count]
    FROM dbo.E_Sartli
    WHERE NULLIF(LTRIM(RTRIM(fldBorder)), '') IS NOT NULL
    GROUP BY LTRIM(RTRIM(fldBorder))
) AS AllBorders
GROUP BY Border
ORDER BY SUM([Count]) DESC";

                    var data = c.Database
                        .SqlQuery<BorderChartItem>(sql)
                        .ToList();

                    return new ChartResultDto
                    {
                        labels = data.Select(x => x.Border).ToList(),
                        sayilar = data.Select(x => x.Count).ToList()
                    };
                }
            }, 15);

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        /// <summary>
        /// Kapı bazında ceza ve V-84 karşılaştırması.
        /// </summary>
        [HttpGet]
        public JsonResult RadarVerileri()
        {
            var result = CacheService.GetOrCreate("Istatistik_RadarVerileri_v2", () =>
            {
                using (var c = new GZPEGM1())
                {
                    var cezaKapilari = c.E_IsK.AsNoTracking()
                        .Where(x => x.fldBorder != null && x.fldBorder.Trim() != "")
                        .GroupBy(x => x.fldBorder.Trim())
                        .Select(g => new { Border = g.Key, Count = g.Count() })
                        .ToDictionary(g => g.Border, g => g.Count);

                    var v84Kapilari = c.E_Sartli.AsNoTracking()
                        .Where(x => x.fldBorder != null && x.fldBorder.Trim() != "")
                        .GroupBy(x => x.fldBorder.Trim())
                        .Select(g => new { Border = g.Key, Count = g.Count() })
                        .ToDictionary(g => g.Border, g => g.Count);

                    var allBorders = cezaKapilari.Keys
                        .Union(v84Kapilari.Keys)
                        .OrderByDescending(b => (cezaKapilari.ContainsKey(b) ? cezaKapilari[b] : 0) + (v84Kapilari.ContainsKey(b) ? v84Kapilari[b] : 0))
                        .Take(8)
                        .ToList();

                    var dto = new RadarDto();
                    foreach (var kapi in allBorders)
                    {
                        dto.labels.Add(kapi);
                        dto.cezaSayilari.Add(cezaKapilari.ContainsKey(kapi) ? cezaKapilari[kapi] : 0);
                        dto.v84Sayilari.Add(v84Kapilari.ContainsKey(kapi) ? v84Kapilari[kapi] : 0);
                    }

                    return dto;
                }
            }, 15);

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        /// <summary>
        /// Haftanın günlerine göre ceza yoğunluğu.
        /// </summary>
        [HttpGet]
        public JsonResult HaftalikYogunluk()
        {
            var result = CacheService.GetOrCreate("Istatistik_HaftalikYogunluk_v2", () =>
            {
                using (var c = new GZPEGM1())
                {
                    var gunler = new[]
                    {
                        "Pazartesi",
                        "Salı",
                        "Çarşamba",
                        "Perşembe",
                        "Cuma",
                        "Cumartesi",
                        "Pazar"
                    };

                    var sayilar = new int[7];

                    var tarihler = c.E_IsK.AsNoTracking()
                        .Where(x => x.fldDatetime != null)
                        .Select(x => x.fldDatetime)
                        .ToList();

                    foreach (var tarih in tarihler)
                    {
                        if (!tarih.HasValue) continue;

                        var gun = (int)tarih.Value.DayOfWeek;
                        var index = gun == 0 ? 6 : gun - 1;
                        sayilar[index]++;
                    }

                    return new ChartResultDto
                    {
                        labels = gunler.ToList(),
                        sayilar = sayilar.ToList()
                    };
                }
            }, 15);

            return Json(result, JsonRequestBehavior.AllowGet);
        }

        private static decimal ParaTopla(IEnumerable<string> tutarlar)
        {
            decimal toplam = 0;

            if (tutarlar == null)
            {
                return toplam;
            }

            var trCulture = CultureInfo.GetCultureInfo("tr-TR");
            var invariantCulture = CultureInfo.InvariantCulture;

            foreach (var tutar in tutarlar)
            {
                if (string.IsNullOrWhiteSpace(tutar))
                {
                    continue;
                }

                decimal deger;

                if (decimal.TryParse(
                    tutar,
                    NumberStyles.Any,
                    trCulture,
                    out deger))
                {
                    toplam += deger;
                    continue;
                }

                if (decimal.TryParse(
                    tutar,
                    NumberStyles.Any,
                    invariantCulture,
                    out deger))
                {
                    toplam += deger;
                }
            }

            return toplam;
        }
    }
}