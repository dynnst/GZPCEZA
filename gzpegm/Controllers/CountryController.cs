using gzpegm.Models;
using HtmlAgilityPack;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    public class CountryController : Controller
    {
        [Route("Country")]
        public async Task<ActionResult> Index()
        {
            var url = "https://tr.wikipedia.org/wiki/%C3%9Clkeler_listesi";
            var countries = new List<Country>();

            try
            {
                using (var httpClient = new HttpClient { Timeout = TimeSpan.FromSeconds(2) })
                {
                    httpClient.DefaultRequestHeaders.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)");
                    var response = await httpClient.GetAsync(url);
                    if (!response.IsSuccessStatusCode)
                    {
                        ViewBag.Error = $"Sayfa alınamadı. HTTP Status: {response.StatusCode}";
                        return View(countries);
                    }

                    var html = await response.Content.ReadAsStringAsync();
                    var doc = new HtmlDocument();
                    doc.LoadHtml(html);

                    var tables = doc.DocumentNode.SelectNodes("//table[contains(@class,'wikitable')]");

                    if (tables != null)
                    {
                        foreach (var table in tables)
                        {
                            var headers = table.SelectNodes(".//tr/th")
                                               ?.Select(h => h.InnerText.Trim().ToLower())
                                               .ToList();

                            int nameIndex = headers?.FindIndex(h => h.Contains("ülke")) ?? -1;
                            int capitalIndex = headers?.FindIndex(h => h.Contains("başkent")) ?? -1;
                            int populationIndex = headers?.FindIndex(h => h.Contains("nüfus")) ?? -1;

                            foreach (var row in table.SelectNodes(".//tr").Skip(1))
                            {
                                var cols = row.SelectNodes(".//td");
                                if (cols != null)
                                {
                                    // Bayrak URL'si: ilk sütundaki <img> src
                                    var imgNode = cols[0].SelectSingleNode(".//img");
                                    string flagUrl = "";
                                    if (imgNode != null && imgNode.Attributes["src"] != null)
                                    {
                                        flagUrl = "https:" + imgNode.Attributes["src"].Value;
                                    }

                                    countries.Add(new Country
                                    {
                                        Name = nameIndex >= 0 && nameIndex < cols.Count ? cols[nameIndex].InnerText.Trim() : "",
                                        Capital = capitalIndex >= 0 && capitalIndex < cols.Count ? cols[capitalIndex].InnerText.Trim() : "",
                                        Population = populationIndex >= 0 && populationIndex < cols.Count ? cols[populationIndex].InnerText.Trim() : "",
                                        FlagUrl = flagUrl
                                    });
                                }
                            }
                        }
                    }
                    else
                    {
                        ViewBag.Error = "Sayfada herhangi bir tablo bulunamadı.";
                    }
                }
            }
            catch (Exception ex)
            {
                ViewBag.Error = "Hata oluştu: " + ex.Message;
            }

            return View(countries);
        }
    }
}
