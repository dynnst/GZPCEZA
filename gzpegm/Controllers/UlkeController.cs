using gzpegm.Models;
using HtmlAgilityPack;
using System.Collections.Generic;
using System.Net.Http;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    public class UlkeController : Controller
    {
        [Route("ULKEAPI")]
        public ActionResult Index()
        {
            var ulkeler = new List<Ulke>();
            var url = "https://ticaret.gov.tr/yurtdisi-teskilati";

            try
            {
                using (var httpClient = new HttpClient { Timeout = System.TimeSpan.FromSeconds(2) })
                {
                    var html = httpClient.GetStringAsync(url).Result;

                    var doc = new HtmlDocument();
                    doc.LoadHtml(html);

                    var kartlar = doc.DocumentNode.SelectNodes("//div[contains(@class,'views-row')]");
                    if (kartlar != null)
                    {
                        foreach (var node in kartlar)
                        {
                            var ulkeAdi = node.SelectSingleNode(".//div[contains(@class,'ulke-adi')]")?.InnerText.Trim() ?? "";
                            var temsilcilik = node.SelectSingleNode(".//div[contains(@class,'temsilcilik-adi')]")?.InnerText.Trim() ?? "";
                            var telefon = node.SelectSingleNode(".//div[contains(@class,'telefon')]")?.InnerText.Trim() ?? "";
                            var adres = node.SelectSingleNode(".//div[contains(@class,'adres')]")?.InnerText.Trim() ?? "";

                            ulkeler.Add(new Ulke
                            {
                                UlkeAdi = ulkeAdi,
                                Temsilcilik = temsilcilik,
                                Telefon = telefon,
                                Adres = adres
                            });
                        }
                    }
                }
            }
            catch (System.Exception ex)
            {
                System.Diagnostics.Trace.TraceWarning("Ulke API offline error: " + ex.Message);
            }

            return View(ulkeler);  // System.Web.Mvc.ActionResult tipine uygun
        }
    }
}
