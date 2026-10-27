using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Text.RegularExpressions;

namespace gzpegm.Services
{
    /// <summary>
    /// CEZAM - Donanımsal Optik Okuyucu Yöneticisi (3M Cogent / Gemalto, Regula Document Reader, Desko PENTA)
    /// Sahtecilik projesindeki kanıtlanmış mimariyle doğrudan SDK yürütücüsü (ReaderScanner.exe) ve Web API üzerinden çalışır.
    /// </summary>
    public static class OpticalReaderService
    {
        private static readonly object _scanLock = new object();

        private static readonly string[] MmmPaths = new string[]
        {
            @"C:\Program Files (x86)\Thales\Gemalto Document Reader SDK\3.7.1.18\Bin\OutputWedgeSysTray.exe",
            @"C:\Program Files\Thales\Gemalto Document Reader SDK\3.7.1.18\Bin\OutputWedgeSysTray.exe",
            @"C:\Program Files (x86)\3M\3M Page Reader\OutputWedgeSysTray.exe",
            @"C:\Program Files\3M\3M Page Reader\OutputWedgeSysTray.exe"
        };

        private static readonly string[] RegulaPaths = new string[]
        {
            @"C:\Program Files\Regula\Document Reader SDK\Bin\DocReader.exe",
            @"C:\Program Files (x86)\Regula\Document Reader SDK\Bin\DocReader.exe",
            @"C:\Program Files\Regula\Reader\DocReader.exe",
            @"C:\Program Files (x86)\Regula\Reader\DocReader.exe",
            @"C:\Program Files\Regula\Document Reader SDK\Bin\Regula Reader.exe",
            @"C:\Program Files (x86)\Regula\Document Reader SDK\Bin\Regula Reader.exe",
            @"C:\Program Files\Regula\Document Reader SDK\RegulaReaderService.exe"
        };

        private static readonly string[] DeskoPaths = new string[]
        {
            @"C:\Program Files\DESKO\PENTA Scanner\PentaScanner.exe",
            @"C:\Program Files (x86)\DESKO\PENTA Scanner\PentaScanner.exe",
            @"C:\Program Files\DESKO\DeskoService.exe",
            @"C:\Program Files (x86)\DESKO\DeskoService.exe",
            @"C:\Program Files\DESKO\PENTA Scanner SDK\Bin\PentaScanner.exe"
        };

        private static readonly string[] RegulaScanFolders = new string[]
        {
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), @"Regula\Document Reader SDK\Scans"),
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData), @"Regula\Document Reader SDK\Scans"),
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), @"Regula\Scans"),
            @"C:\Regula\Scans",
            @"C:\RegulaScans"
        };

        public static object ConnectDevice(string deviceType = "auto")
        {
            try
            {
                bool is3MRunning = Process.GetProcessesByName("OutputWedgeSysTray").Length > 0;
                bool isRegulaRunning = Process.GetProcessesByName("DocReader").Length > 0
                                    || Process.GetProcessesByName("Regula Reader").Length > 0
                                    || Process.GetProcessesByName("RegulaReaderService").Length > 0;
                bool isDeskoRunning = Process.GetProcessesByName("PentaScanner").Length > 0
                                   || Process.GetProcessesByName("DeskoService").Length > 0;

                string requested = (deviceType ?? "auto").ToLowerInvariant();
                bool started = false;
                string deviceName = "";

                // 1. 3M / Gemalto Kontrolü
                if (requested == "3m" || requested == "auto")
                {
                    if (is3MRunning)
                    {
                        deviceName = "3M Cogent / Gemalto (PV40/PV60/AT9000)";
                    }
                    else
                    {
                        foreach (var p in MmmPaths)
                        {
                            if (File.Exists(p))
                            {
                                Process.Start(new ProcessStartInfo
                                {
                                    FileName = p,
                                    WorkingDirectory = Path.GetDirectoryName(p),
                                    UseShellExecute = true
                                });
                                deviceName = "3M Cogent / Gemalto (PV40/PV60/AT9000)";
                                started = true;
                                break;
                            }
                        }
                    }
                }

                // 2. Regula Kontrolü
                if ((requested == "regula" || (requested == "auto" && !started && !is3MRunning)) && !isRegulaRunning)
                {
                    foreach (var rp in RegulaPaths)
                    {
                        if (File.Exists(rp))
                        {
                            Process.Start(new ProcessStartInfo
                            {
                                FileName = rp,
                                WorkingDirectory = Path.GetDirectoryName(rp),
                                UseShellExecute = true
                            });
                            deviceName = "Regula Document Reader (70X4/70X7)";
                            started = true;
                            break;
                        }
                    }
                }
                else if (isRegulaRunning && string.IsNullOrEmpty(deviceName))
                {
                    deviceName = "Regula Document Reader (70X4/70X7)";
                }

                // 3. Desko PENTA Kontrolü
                if ((requested == "desko" || (requested == "auto" && !started && !is3MRunning && !isRegulaRunning)) && !isDeskoRunning)
                {
                    foreach (var dp in DeskoPaths)
                    {
                        if (File.Exists(dp))
                        {
                            Process.Start(new ProcessStartInfo
                            {
                                FileName = dp,
                                WorkingDirectory = Path.GetDirectoryName(dp),
                                UseShellExecute = true
                            });
                            deviceName = "Desko PENTA Scanner";
                            started = true;
                            break;
                        }
                    }
                }
                else if (isDeskoRunning && string.IsNullOrEmpty(deviceName))
                {
                    deviceName = "Desko PENTA Scanner";
                }

                if (started)
                {
                    System.Threading.Thread.Sleep(800);
                }

                bool is3M = Process.GetProcessesByName("OutputWedgeSysTray").Length > 0;
                bool isRegula = Process.GetProcessesByName("DocReader").Length > 0
                             || Process.GetProcessesByName("Regula Reader").Length > 0
                             || Process.GetProcessesByName("RegulaReaderService").Length > 0;
                bool isDesko = Process.GetProcessesByName("PentaScanner").Length > 0
                            || Process.GetProcessesByName("DeskoService").Length > 0;
                bool isAnyRunning = is3M || isRegula || isDesko;

                string activeDevice = is3M && isRegula ? "3M & Regula" : (is3M ? "3M PV40/PV60/AT9000" : (isRegula ? "Regula 70X4/70X7" : (isDesko ? "Desko PENTA" : (deviceName != "" ? deviceName : "Optik Okuyucu"))));

                return new
                {
                    success = true,
                    isRunning = isAnyRunning,
                    is3MRunning = is3M,
                    isRegulaRunning = isRegula,
                    isDeskoRunning = isDesko,
                    deviceName = activeDevice,
                    message = isAnyRunning
                        ? activeDevice + " servisine başarıyla bağlanıldı ve dinleniyor. Pasaport veya kimliği okuyucuya koyabilirsiniz."
                        : "Okuyucu servisi başlatılamadı. Lütfen cihazın USB bağlantısını ve sürücüsünü kontrol ediniz."
                };
            }
            catch (Exception ex)
            {
                return new { success = false, message = "Cihaza bağlanırken hata: " + ex.Message };
            }
        }

        private static string ResolveAppDataPath(string fileName)
        {
            try
            {
                if (System.Web.Hosting.HostingEnvironment.IsHosted)
                {
                    string p = System.Web.Hosting.HostingEnvironment.MapPath("~/App_Data/" + fileName);
                    if (!string.IsNullOrEmpty(p) && File.Exists(p)) return p;
                }
            }
            catch { }

            string baseDir = AppDomain.CurrentDomain.BaseDirectory;
            string p1 = Path.Combine(baseDir, "App_Data", fileName);
            if (File.Exists(p1)) return p1;

            string p2 = Path.GetFullPath(Path.Combine(baseDir, "..", "App_Data", fileName));
            if (File.Exists(p2)) return p2;

            return p1;
        }

        public static object GetStatus()
        {
            try
            {
                string scannerExe = ResolveAppDataPath("ReaderScanner.exe");

                bool is3MHardwareReady = false;
                bool isDocOnWindow = false;

                if (File.Exists(scannerExe))
                {
                    try
                    {
                        var psi = new ProcessStartInfo
                        {
                            FileName = scannerExe,
                            Arguments = "--status",
                            UseShellExecute = false,
                            RedirectStandardOutput = true,
                            RedirectStandardError = true,
                            CreateNoWindow = true,
                            StandardOutputEncoding = System.Text.Encoding.UTF8
                        };

                        using (var proc = Process.Start(psi))
                        {
                            string output = proc.StandardOutput.ReadToEnd();
                            proc.WaitForExit(3000);

                            if (!string.IsNullOrWhiteSpace(output))
                            {
                                int jsonStart = output.IndexOf('{');
                                int jsonEnd = output.LastIndexOf('}');
                                if (jsonStart >= 0 && jsonEnd > jsonStart)
                                {
                                    var jsonObj = JObject.Parse(output.Substring(jsonStart, jsonEnd - jsonStart + 1));
                                    is3MHardwareReady = (bool?)jsonObj["isInitialised"] ?? false;
                                    isDocOnWindow = (bool?)jsonObj["isDocumentOnWindow"] ?? false;
                                }
                            }
                        }
                    }
                    catch { }
                }

                bool is3MProcess = Process.GetProcessesByName("OutputWedgeSysTray").Length > 0;
                bool isRegula = Process.GetProcessesByName("DocReader").Length > 0
                             || Process.GetProcessesByName("Regula Reader").Length > 0
                             || Process.GetProcessesByName("RegulaReaderService").Length > 0;
                bool isDesko = Process.GetProcessesByName("PentaScanner").Length > 0
                            || Process.GetProcessesByName("DeskoService").Length > 0;

                bool isRunning = is3MHardwareReady || is3MProcess || isRegula || isDesko;
                string deviceName = (is3MHardwareReady || is3MProcess) ? "3M Cogent / Gemalto (PV40/PV60/AT9000)" : (isRegula ? "Regula 70X4/70X7" : (isDesko ? "Desko PENTA" : "Optik Okuyucu"));

                return new
                {
                    success = true,
                    isRunning = isRunning,
                    is3MReady = is3MHardwareReady,
                    isDocumentOnWindow = isDocOnWindow,
                    is3MRunning = is3MProcess,
                    isRegulaRunning = isRegula,
                    isDeskoRunning = isDesko,
                    deviceName = deviceName,
                    statusText = isRunning ? (deviceName + " Bağlı & Hazır") : "Bağlantı Bekleniyor"
                };
            }
            catch (Exception ex)
            {
                return new { success = false, message = ex.Message };
            }
        }

        /// <summary>
        /// Doğrudan optik okuyucudan (3M AT9000/PV40/PV60, Regula 70X4/70X7 veya Desko PENTA)
        /// donanım SDK'sı üzerinden pasaport/kimlik verilerini ve görselini çeker.
        /// </summary>
        public static object ScanDevice(string deviceType = "auto")
        {
            lock (_scanLock)
            {
                try
                {
                    bool isRegulaRunning = Process.GetProcessesByName("DocReader").Length > 0
                                        || Process.GetProcessesByName("Regula Reader").Length > 0
                                        || Process.GetProcessesByName("RegulaReaderService").Length > 0;

                    string requested = (deviceType ?? "auto").ToLowerInvariant();

                    // 1. Regula okuyucu seçildiyse veya Auto modunda Regula aktifse
                    if (requested == "regula" || (requested == "auto" && isRegulaRunning))
                    {
                        var regulaResult = TryScanRegula();
                        if (regulaResult != null)
                        {
                            return regulaResult;
                        }
                    }

                    // 2. 3M / Gemalto donanım tarayıcısını doğrudan çalıştır (ReaderScanner.exe)
                    string scannerExe = ResolveAppDataPath("ReaderScanner.exe");
                    if (!File.Exists(scannerExe))
                    {
                        return new { success = false, message = "Optik tarayıcı yürütücüsü (ReaderScanner.exe) bulunamadı. Lütfen App_Data klasörünü kontrol ediniz." };
                    }

                    // 3M OutputWedge donanım portunu meşgul ediyorsa geçici olarak durdur
                    bool was3MRunning = false;
                    var runningWedges = Process.GetProcessesByName("OutputWedgeSysTray");
                    if (runningWedges.Length > 0)
                    {
                        was3MRunning = true;
                        foreach (var p in runningWedges)
                        {
                            try { p.Kill(); } catch { }
                        }
                        System.Threading.Thread.Sleep(350);
                    }

                    try
                    {
                        var psi = new ProcessStartInfo
                        {
                            FileName = scannerExe,
                            Arguments = "--scan",
                            UseShellExecute = false,
                            RedirectStandardOutput = true,
                            RedirectStandardError = true,
                            CreateNoWindow = true,
                            StandardOutputEncoding = System.Text.Encoding.UTF8
                        };

                        using (var proc = Process.Start(psi))
                        {
                            string output = proc.StandardOutput.ReadToEnd();
                            string errOutput = proc.StandardError.ReadToEnd();
                            proc.WaitForExit(14000);

                            if (string.IsNullOrWhiteSpace(output))
                            {
                                string detail = !string.IsNullOrWhiteSpace(errOutput) ? " (" + errOutput.Trim() + ")" : "";
                                return new { success = false, message = "Optik okuyucudan veri yanıtı alınamadı." + detail };
                            }

                            int jsonStart = output.IndexOf('{');
                            int jsonEnd = output.LastIndexOf('}');
                            if (jsonStart < 0 || jsonEnd <= jsonStart)
                            {
                                string detail = !string.IsNullOrWhiteSpace(errOutput) ? " [Hata: " + errOutput.Trim() + "]" : "";
                                return new { success = false, message = "Okuyucu çıktısı ayrıştırılamadı: " + output + detail };
                            }

                            string jsonStr = output.Substring(jsonStart, jsonEnd - jsonStart + 1);
                            var jsonObj = JObject.Parse(jsonStr);

                            bool success = (bool?)jsonObj["success"] ?? false;
                            if (!success)
                            {
                                string msg = (string)jsonObj["message"] ?? "Optik okuyucudan belge okunamadı. Lütfen belgeyi camın üzerine yerleştiriniz.";
                                return new { success = false, message = msg };
                            }

                            string visBase64 = (string)jsonObj["visBase64"] ?? "";
                            string line1 = (string)jsonObj["line1"] ?? "";
                            string line2 = (string)jsonObj["line2"] ?? "";
                            string line3 = (string)jsonObj["line3"] ?? "";
                            string docTypeStr = (string)jsonObj["docType"] ?? "PASSPORT";

                            // Satırları ICAO formatına göre ayrıştır
                            var parsed = ParseMrzCodelines(line1, line2, line3, docTypeStr);

                            return new
                            {
                                success = true,
                                deviceName = "3M Cogent / Gemalto (PV40/PV60/AT9000)",
                                visBase64 = visBase64,
                                isTurkishCitizen = parsed.IsTurkishCitizen,
                                message = parsed.Message,
                                documentType = parsed.DocumentType,
                                docTypeCode = parsed.DocTypeCode,
                                country = parsed.Country,
                                countryCode = parsed.CountryCode,
                                documentNumber = parsed.DocumentNumber,
                                fullName = parsed.FullName,
                                surname = parsed.Surname,
                                givenNames = parsed.GivenNames,
                                birthDate = parsed.BirthDate,
                                age = parsed.Age,
                                isAdult = parsed.IsAdult,
                                adultCode = parsed.AdultCode,
                                personalNumber = parsed.PersonalNumber,
                                sex = parsed.Sex,
                                rawText = parsed.RawText,
                                line1 = line1,
                                line2 = line2,
                                line3 = line3,
                                summary = parsed.IsTurkishCitizen
                                    ? "TÜRK VATANDAŞI (Ceza Uygulanmaz)"
                                    : (parsed.FullName + " (" + parsed.DocumentNumber + ") - " + parsed.Country)
                            };
                        }
                    }
                    finally
                    {
                        // Daha önce OutputWedge çalışıyorduysa tekrar arka planda başlat
                        if (was3MRunning)
                        {
                            try
                            {
                                foreach (var p in MmmPaths)
                                {
                                    if (File.Exists(p))
                                    {
                                        Process.Start(new ProcessStartInfo
                                        {
                                            FileName = p,
                                            WorkingDirectory = Path.GetDirectoryName(p),
                                            UseShellExecute = true
                                        });
                                        break;
                                    }
                                }
                            }
                            catch { }
                        }
                    }
                }
                catch (Exception ex)
                {
                    return new { success = false, message = "Cihazdan tarama hatası: " + ex.Message };
                }
            }
        }

        private static object TryScanRegula()
        {
            try
            {
                // Regula Web API kontrolü (localhost:41101)
                using (var client = new HttpClient())
                {
                    client.Timeout = TimeSpan.FromMilliseconds(2000);
                    var response = client.GetAsync("http://127.0.0.1:41101/api/process").Result;
                    if (response.IsSuccessStatusCode)
                    {
                        string jsonContent = response.Content.ReadAsStringAsync().Result;
                        var json = JObject.Parse(jsonContent);

                        string visBase64 = "";
                        string rawMrz = "";

                        var containerList = json["ContainerList"]?["List"] as JArray;
                        if (containerList != null)
                        {
                            foreach (var item in containerList)
                            {
                                int resultType = (int?)item["result_type"] ?? 0;
                                if (resultType == 1 || resultType == 201)
                                    visBase64 = (string)item["image"] ?? visBase64;
                                else if (resultType == 36 || resultType == 3)
                                {
                                    string text = (string)item["raw_data"] ?? (string)item["mrz"] ?? "";
                                    if (!string.IsNullOrEmpty(text)) rawMrz = text;
                                }
                            }
                        }

                        if (!string.IsNullOrEmpty(rawMrz) || !string.IsNullOrEmpty(visBase64))
                        {
                            var lines = (rawMrz ?? "").Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.RemoveEmptyEntries);
                            string l1 = lines.Length > 0 ? lines[0] : "";
                            string l2 = lines.Length > 1 ? lines[1] : "";
                            string l3 = lines.Length > 2 ? lines[2] : "";

                            var parsed = ParseMrzCodelines(l1, l2, l3, "REGULA DOCUMENT");

                            return new
                            {
                                success = true,
                                deviceName = "Regula Document Reader (Web API)",
                                visBase64 = visBase64,
                                isTurkishCitizen = parsed.IsTurkishCitizen,
                                message = parsed.Message,
                                documentType = parsed.DocumentType,
                                docTypeCode = parsed.DocTypeCode,
                                country = parsed.Country,
                                countryCode = parsed.CountryCode,
                                documentNumber = parsed.DocumentNumber,
                                fullName = parsed.FullName,
                                surname = parsed.Surname,
                                givenNames = parsed.GivenNames,
                                birthDate = parsed.BirthDate,
                                age = parsed.Age,
                                isAdult = parsed.IsAdult,
                                adultCode = parsed.AdultCode,
                                personalNumber = parsed.PersonalNumber,
                                sex = parsed.Sex,
                                rawText = parsed.RawText,
                                line1 = l1,
                                line2 = l2,
                                line3 = l3,
                                summary = parsed.IsTurkishCitizen
                                    ? "TÜRK VATANDAŞI (Ceza Uygulanmaz)"
                                    : (parsed.FullName + " (" + parsed.DocumentNumber + ") - " + parsed.Country)
                            };
                        }
                    }
                }
            }
            catch { }

            // Regula dosya klasöründen aktarımı dene
            try
            {
                foreach (var folder in RegulaScanFolders)
                {
                    if (Directory.Exists(folder))
                    {
                        var dir = new DirectoryInfo(folder);
                        var recentFiles = dir.GetFiles("*.*", SearchOption.TopDirectoryOnly)
                                             .Where(f => (DateTime.UtcNow - f.LastWriteTimeUtc).TotalMinutes < 3)
                                             .OrderByDescending(f => f.LastWriteTimeUtc)
                                             .ToList();

                        if (recentFiles.Any())
                        {
                            var f = recentFiles.FirstOrDefault(x => x.Name.ToLowerInvariant().Contains("vis") || x.Name.ToLowerInvariant().Contains("white"));
                            if (f != null)
                            {
                                string visBase64 = Convert.ToBase64String(File.ReadAllBytes(f.FullName));
                                return new
                                {
                                    success = true,
                                    deviceName = "Regula Document Reader (Folder)",
                                    visBase64 = visBase64,
                                    isTurkishCitizen = false,
                                    documentType = "Umuma Mahsus Pasaport",
                                    docTypeCode = "1",
                                    country = "",
                                    countryCode = "",
                                    documentNumber = "",
                                    fullName = "",
                                    birthDate = "",
                                    summary = "Regula klasöründen görsel başarıyla alındı"
                                };
                            }
                        }
                    }
                }
            }
            catch { }

            return null;
        }

        private static readonly int[] MrzWeights = { 7, 3, 1 };

        public static readonly Dictionary<string, string> CountryMap = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            { "TUR", "Türkiye" }, { "TR", "Türkiye" },
            { "RUS", "Rusya Federasyonu" }, { "RU", "Rusya Federasyonu" },
            { "DEU", "Almanya" }, { "D", "Almanya" },
            { "GBR", "Birleşik Krallık" }, { "UK", "Birleşik Krallık" },
            { "UKR", "Ukrayna" }, { "UA", "Ukrayna" },
            { "AZE", "Azerbaycan" }, { "AZ", "Azerbaycan" },
            { "GEO", "Gürcistan" }, { "GE", "Gürcistan" },
            { "IRN", "İran" }, { "IRQ", "Irak" },
            { "USA", "Amerika Birleşik Devletleri" }, { "US", "Amerika Birleşik Devletleri" },
            { "KAZ", "Kazakistan" }, { "UZB", "Özbekistan" }, { "TKM", "Türkmenistan" },
            { "TJK", "Tacikistan" }, { "KGZ", "Kırgızistan" },
            { "MDA", "Moldovya Cumhuriyeti" }, { "BLR", "Beyaz Rusya" },
            { "FRA", "Fransa" }, { "NLD", "Hollanda" }, { "BEL", "Belçika" },
            { "AUT", "Avusturya" }, { "CHE", "İsviçre" }, { "SWE", "İsveç" },
            { "NOR", "Norveç" }, { "DNK", "Danimarka" }, { "FIN", "Finlandiya" },
            { "POL", "Polonya" }, { "BGR", "Bulgaristan" }, { "GRC", "Yunanistan" },
            { "ITA", "İtalya" }, { "ESP", "İspanya" }, { "PRT", "Portekiz" },
            { "ROU", "Romanya" }, { "CZE", "Çek Cumhuriyeti" }, { "HUN", "Macaristan" },
            { "SVK", "Slovakya" }, { "SVN", "Slovenya" }, { "HRV", "Hırvatistan" },
            { "SRB", "Sırbistan" }, { "BIH", "Bosna Hersek" }, { "MKD", "Makedonya" },
            { "ALB", "Arnavutluk" }, { "MNE", "Karadağ" }, { "KOS", "Kosova" },
            { "SYR", "Suriye" }, { "LBN", "Lübnan" }, { "JOR", "Ürdün" },
            { "ISR", "İsrail" }, { "SAU", "Suudi Arabistan" }, { "ARE", "Birleşik Arap Emirlikleri" },
            { "EGY", "Mısır" }, { "LBY", "Libya" }, { "TUN", "Tunus" },
            { "DZA", "Cezayir" }, { "MAR", "Fas" }, { "CHN", "Çin" },
            { "JPN", "Japonya" }, { "KOR", "Güney Kore" }, { "IND", "Hindistan" },
            { "PAK", "Pakistan" }, { "AFG", "Afganistan" }, { "CAN", "Kanada" },
            { "AUS", "Avustralya" }, { "BRA", "Brezilya" }, { "ARG", "Arjantin" }
        };

        public static bool ValidateCheckDigit(string value, char expectedCheckDigit)
        {
            if (string.IsNullOrEmpty(value)) return false;
            int sum = 0;
            for (int i = 0; i < value.Length; i++)
            {
                char c = char.ToUpperInvariant(value[i]);
                int val = 0;
                if (c >= '0' && c <= '9') val = c - '0';
                else if (c >= 'A' && c <= 'Z') val = c - 'A' + 10;
                else if (c == '<') val = 0;
                else return false;

                sum += val * MrzWeights[i % 3];
            }
            int calc = sum % 10;
            int exp = expectedCheckDigit >= '0' && expectedCheckDigit <= '9' ? expectedCheckDigit - '0' : -1;
            return calc == exp;
        }

        public static bool ValidateTckn(string tckn)
        {
            if (string.IsNullOrEmpty(tckn) || tckn.Length != 11 || !Regex.IsMatch(tckn, @"^[1-9]\d{10}$"))
                return false;

            int[] d = tckn.Select(c => c - '0').ToArray();
            int oddSum = d[0] + d[2] + d[4] + d[6] + d[8];
            int evenSum = d[1] + d[3] + d[5] + d[7];

            int d10 = ((oddSum * 7) - evenSum) % 10;
            if (d10 < 0) d10 += 10;
            if (d[9] != d10) return false;

            int sum10 = 0;
            for (int i = 0; i < 10; i++) sum10 += d[i];
            if (sum10 % 10 != d[10]) return false;

            return true;
        }

        public static string RecoverTckn(string partial10)
        {
            if (string.IsNullOrEmpty(partial10) || partial10.Length != 10) return "";
            for (int firstDigit = 1; firstDigit <= 9; firstDigit++)
            {
                string candidate = firstDigit + partial10;
                if (ValidateTckn(candidate)) return candidate;
            }
            return "";
        }

        public static string CleanMrzLine(string raw)
        {
            if (string.IsNullOrWhiteSpace(raw)) return "";
            string s = raw.Trim().ToUpperInvariant().Replace(" ", "");
            s = Regex.Replace(s, @"[«»‹›\(\)\{\}\[\]\|\\\/]", "<");
            s = Regex.Replace(s, @"K{2,}", "<<");
            s = Regex.Replace(s, @"C{2,}", "<<");
            s = Regex.Replace(s, @"^[I1ı|!][<«‹\s]*", "I<");
            s = Regex.Replace(s, @"^P[KC«‹]", "P<");
            return s;
        }

        public static int? CalculateAge(string birthDateDmy)
        {
            if (string.IsNullOrWhiteSpace(birthDateDmy)) return null;
            var parts = birthDateDmy.Split('.');
            if (parts.Length != 3) return null;

            if (int.TryParse(parts[0], out int d) && int.TryParse(parts[1], out int m) && int.TryParse(parts[2], out int y))
            {
                try
                {
                    var birth = new DateTime(y, m, d);
                    var today = DateTime.Today;
                    int age = today.Year - birth.Year;
                    if (birth.Date > today.AddYears(-age)) age--;
                    return age;
                }
                catch { }
            }
            return null;
        }

        /// <summary>
        /// Yüklenen veya kamera ile çekilen pasaport/kimlik görselini gelişmiş OCR ve ICAO 9303 matematiksel hata onarım motoruyla çözümler.
        /// </summary>
        public static object ProcessPassportImage(string imagePath)
        {
            if (string.IsNullOrWhiteSpace(imagePath) || !File.Exists(imagePath))
            {
                return new { success = false, message = "Görsel dosyası bulunamadı." };
            }

            try
            {
                string scriptPath = ResolveAppDataPath("PassportOcr.ps1");
                if (string.IsNullOrEmpty(scriptPath) || !File.Exists(scriptPath))
                {
                    return new { success = false, message = "OCR betiği (PassportOcr.ps1) bulunamadı." };
                }

                var psi = new ProcessStartInfo
                {
                    FileName = "powershell.exe",
                    Arguments = string.Format("-NoProfile -ExecutionPolicy Bypass -File \"{0}\" -imagePath \"{1}\"", scriptPath, imagePath),
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    UseShellExecute = false,
                    CreateNoWindow = true,
                    StandardOutputEncoding = System.Text.Encoding.UTF8
                };

                string output = "";
                using (var proc = Process.Start(psi))
                {
                    output = proc.StandardOutput.ReadToEnd();
                    proc.WaitForExit(18000);
                }

                if (string.IsNullOrWhiteSpace(output))
                {
                    return new { success = false, message = "OCR çıktısı alınamadı." };
                }

                int jsonStart = output.IndexOf('{');
                int jsonEnd = output.LastIndexOf('}');
                if (jsonStart < 0 || jsonEnd <= jsonStart)
                {
                    return new { success = false, message = "OCR çıktısı JSON formatında ayrıştırılamadı." };
                }

                var jsonObj = JObject.Parse(output.Substring(jsonStart, jsonEnd - jsonStart + 1));
                bool ocrSuccess = (bool?)jsonObj["success"] ?? false;
                if (!ocrSuccess)
                {
                    return new { success = false, message = (string)jsonObj["message"] ?? "Görsel taranamadı." };
                }

                string rawText = (string)jsonObj["rawText"] ?? "";
                var lines = jsonObj["lines"]?.Select(t => t.ToString()).ToList() ?? new List<string>();
                var cropLines = jsonObj["cropLines"]?.Select(t => t.ToString()).ToList() ?? new List<string>();

                // MRZ filtreleme: ASCII karakterler ve uzunluk >= 20
                var mrzCandidates = new List<string>();
                foreach (var l in cropLines.Concat(lines))
                {
                    var cl = CleanMrzLine(l);
                    if (cl.Length >= 20 && Regex.IsMatch(cl, @"^[A-Z0-9<]{20,}$"))
                    {
                        if (cl.Contains("REPUBLIC") || cl.Contains("TURKEY") || cl.Contains("KART") || cl.Contains("MINISTRY") || cl.Contains("PASSPORT"))
                            continue;

                        if (!mrzCandidates.Contains(cl))
                        {
                            mrzCandidates.Add(cl);
                        }
                    }
                }

                string fullName = "";
                string surname = "";
                string givenNames = "";
                string docNo = "";
                string tckn = "";
                string birthDate = "";
                string country = "";
                string docType = "Umuma Mahsus Pasaport";
                string docTypeCode = "1";
                string sex = "";
                bool isAdult = true;

                // =========================================================================
                // 1. TD1 FORMATI (Kimlik Kartları - 3 Satır x 30 Karakter)
                // =========================================================================
                var td1L1 = mrzCandidates.FirstOrDefault(x => x.StartsWith("I<") || x.StartsWith("A<") || x.StartsWith("C<"));
                var td1L2 = mrzCandidates.FirstOrDefault(x => x != td1L1 && Regex.IsMatch(x, @"^\d{6}\d"));
                var td1L3 = mrzCandidates.FirstOrDefault(x => x != td1L1 && x != td1L2 && x.Contains("<<"));

                if (td1L1 != null && td1L2 != null)
                {
                    docType = "Kimlik Kartı";
                    docTypeCode = "1";

                    // Ülke Kodu & Belge No Eşleme
                    string cCode = "";
                    int docStart = -1;

                    foreach (var kvp in CountryMap)
                    {
                        if (kvp.Key.Length == 3)
                        {
                            int idx = td1L1.IndexOf(kvp.Key);
                            if (idx >= 1 && idx <= 6)
                            {
                                cCode = kvp.Key;
                                docStart = idx + 3;
                                break;
                            }
                        }
                    }

                    if (string.IsNullOrEmpty(cCode))
                    {
                        var mCountry = Regex.Match(td1L1, @"^[IAC][<]*([A-Z]{3})");
                        cCode = mCountry.Success ? mCountry.Groups[1].Value : (td1L1.Length >= 5 ? td1L1.Substring(2, 3) : "TUR");
                        docStart = td1L1.IndexOf(cCode);
                        if (docStart >= 0) docStart += cCode.Length; else docStart = 5;
                    }

                    if (CountryMap.TryGetValue(cCode, out var cName)) country = cName;
                    else country = cCode;

                    // Belge Numarası & Kontrol Hanesi
                    if (docStart >= 0 && td1L1.Length >= docStart + 10)
                    {
                        string candDoc = td1L1.Substring(docStart, 9).Replace("<", "");
                        char check = td1L1[docStart + 9];
                        docNo = candDoc;
                        ValidateCheckDigit(td1L1.Substring(docStart, 9), check);
                    }

                    // TCKN / YKN Tespiti ve Otomatik Kurtarma
                    var mTckn11 = Regex.Match(td1L1, @"\b([1-9]\d{10})\b");
                    if (mTckn11.Success && ValidateTckn(mTckn11.Groups[1].Value))
                    {
                        tckn = mTckn11.Groups[1].Value;
                    }
                    else
                    {
                        var m10 = Regex.Match(td1L1, @"[A-Z<]([0-9]{10})[<]*$");
                        if (m10.Success)
                        {
                            string rec = RecoverTckn(m10.Groups[1].Value);
                            if (!string.IsNullOrEmpty(rec)) tckn = rec;
                        }
                    }

                    // Doğum Tarihi & Cinsiyet
                    if (td1L2.Length >= 6)
                    {
                        birthDate = FormatMrzDate(td1L2.Substring(0, 6));
                    }
                    if (td1L2.Length >= 8)
                    {
                        string subSex = td1L2.Substring(7);
                        if (subSex.StartsWith("M") || subSex.StartsWith("19") || subSex.StartsWith("IV")) sex = "Erkek";
                        else if (subSex.StartsWith("F")) sex = "Kadın";
                    }

                    // İsim
                    if (td1L3 != null)
                    {
                        var nameParts = td1L3.Split(new[] { "<<" }, StringSplitOptions.RemoveEmptyEntries);
                        surname = nameParts.Length > 0 ? nameParts[0].Replace("<", " ").Trim() : "";
                        givenNames = nameParts.Length > 1 ? nameParts[1].Replace("<", " ").Trim() : "";
                        fullName = (surname + " " + givenNames).Trim();
                    }
                }

                // =========================================================================
                // 2. TD3 FORMATI (Standart Pasaportlar - 2 Satır x 44 Karakter)
                // =========================================================================
                if (string.IsNullOrEmpty(docNo) || string.IsNullOrEmpty(fullName))
                {
                    var td3L1 = mrzCandidates.FirstOrDefault(x => x.StartsWith("P<") || (x.StartsWith("P") && x.Length >= 38));
                    var td3L2 = mrzCandidates.FirstOrDefault(x => x != td3L1 && x.Length >= 36 && Regex.IsMatch(x, @"^[A-Z0-9<]{9}\d"));

                    if (td3L1 != null && td3L2 != null)
                    {
                        docType = td3L1.StartsWith("PD") || td3L1.StartsWith("D<") ? "Diplomatik Pasaport" : (td3L1.StartsWith("PS") || td3L1.StartsWith("S<") ? "Servis Pasaportu" : "Umuma Mahsus Pasaport");
                        docTypeCode = docType.Contains("Diplomatik") ? "2" : (docType.Contains("Servis") ? "3" : "1");

                        // Line 1: Ülke & İsim
                        if (td3L1.Length >= 5)
                        {
                            string cCode = td3L1.Substring(2, 3).Replace("<", "");
                            if (CountryMap.TryGetValue(cCode, out var cName)) country = cName;
                            else country = cCode;
                        }

                        string namePart = td3L1.Length > 5 ? td3L1.Substring(5) : "";
                        var parts = namePart.Split(new[] { "<<" }, StringSplitOptions.RemoveEmptyEntries);
                        surname = parts.Length > 0 ? parts[0].Replace("<", " ").Trim() : "";
                        givenNames = parts.Length > 1 ? parts[1].Replace("<", " ").Trim() : "";
                        fullName = (surname + " " + givenNames).Trim();

                        // Line 2: Belge No (0..9) + Check (9)
                        if (td3L2.Length >= 10)
                        {
                            string rawDoc = td3L2.Substring(0, 9).Replace("<", "");
                            char docCheck = td3L2[9];
                            docNo = rawDoc;
                            ValidateCheckDigit(td3L2.Substring(0, 9), docCheck);
                        }

                        // Uyruk (10..12)
                        if (string.IsNullOrEmpty(country) && td3L2.Length >= 13)
                        {
                            string natCode = td3L2.Substring(10, 3).Replace("<", "");
                            if (CountryMap.TryGetValue(natCode, out var mappedNat)) country = mappedNat;
                            else country = natCode;
                        }

                        // Doğum Tarihi (13..18) + Check (19)
                        if (td3L2.Length >= 19)
                        {
                            string rawBirth = td3L2.Substring(13, 6);
                            char bCheck = td3L2.Length > 19 ? td3L2[19] : '0';
                            birthDate = FormatMrzDate(rawBirth);
                        }

                        // Cinsiyet (20)
                        if (td3L2.Length >= 21)
                        {
                            char rawSex = td3L2[20];
                            if (rawSex == 'M') sex = "Erkek";
                            else if (rawSex == 'F') sex = "Kadın";
                        }

                        // Opsiyonel / TCKN (28..42)
                        if (td3L2.Length >= 42)
                        {
                            string opt = td3L2.Substring(28, 14).Replace("<", "").Trim();
                            if (Regex.IsMatch(opt, @"^\d{11}$") && ValidateTckn(opt)) tckn = opt;
                        }
                    }
                }

                // =========================================================================
                // 3. VIZ (Visual Inspection Zone - Görsel Metin Alanı) YEDEK TARAMA
                // =========================================================================
                if (string.IsNullOrEmpty(tckn))
                {
                    var mAllTckn = Regex.Matches(rawText, @"\b([1-9]\d{10})\b");
                    foreach (Match m in mAllTckn)
                    {
                        if (ValidateTckn(m.Groups[1].Value))
                        {
                            tckn = m.Groups[1].Value;
                            break;
                        }
                    }
                }

                if (string.IsNullOrEmpty(birthDate))
                {
                    var mBirth = Regex.Match(rawText, @"(?:Doğum\s*Tarihi|Date\s*of\s*Birth|DOB|Birth\s*Date)[\s\:\.\/]*(\d{2})[\.\/-](\d{2})[\.\/-](\d{4})", RegexOptions.IgnoreCase);
                    if (mBirth.Success)
                    {
                        birthDate = string.Format("{0}.{1}.{2}", mBirth.Groups[1].Value, mBirth.Groups[2].Value, mBirth.Groups[3].Value);
                    }
                    else
                    {
                        var mAnyDate = Regex.Match(rawText, @"\b(\d{2})[\.](\d{2})[\.](\d{4})\b");
                        if (mAnyDate.Success)
                        {
                            birthDate = mAnyDate.Value;
                        }
                    }
                }

                if (string.IsNullOrEmpty(docNo))
                {
                    var mDoc = Regex.Match(rawText, @"(?:Pasaport\s*No|Passport\s*No|Seri\s*No|Belge\s*No)[\s\:\.\/]*([A-Z0-9]{8,10})", RegexOptions.IgnoreCase);
                    if (mDoc.Success)
                    {
                        docNo = mDoc.Groups[1].Value;
                    }
                }

                if (string.IsNullOrEmpty(fullName))
                {
                    var mSur = Regex.Match(rawText, @"(?:Soyadı|Surname|Last\s*Name)[\s\:\.\/]*([A-ZÇĞİÖŞÜa-zçğıöşü]+)", RegexOptions.IgnoreCase);
                    var mGiv = Regex.Match(rawText, @"(?:Adı|Given\s*Names?|First\s*Name)[\s\:\.\/]*([A-ZÇĞİÖŞÜa-zçğıöşü]+(?:\s+[A-ZÇĞİÖŞÜa-zçğıöşü]+)?)", RegexOptions.IgnoreCase);
                    if (mSur.Success || mGiv.Success)
                    {
                        surname = mSur.Success ? mSur.Groups[1].Value.Trim().ToUpperInvariant() : "";
                        givenNames = mGiv.Success ? mGiv.Groups[1].Value.Trim().ToUpperInvariant() : "";
                        fullName = (surname + " " + givenNames).Trim();
                    }
                }

                // Yaş & Yetişkin / Çocuk Durumu
                int? age = CalculateAge(birthDate);
                if (age.HasValue)
                {
                    isAdult = age.Value >= 18;
                }

                bool hasAnyData = !string.IsNullOrEmpty(docNo) || !string.IsNullOrEmpty(fullName) || !string.IsNullOrEmpty(tckn);

                if (!hasAnyData)
                {
                    return new
                    {
                        success = false,
                        message = "Görselden kimlik veya pasaport verisi okunamadı. Lütfen ışık yansıması olmayan net bir görsel yükleyiniz.",
                        rawText = rawText
                    };
                }

                return new
                {
                    success = true,
                    documentType = docType,
                    docTypeCode = docTypeCode,
                    country = country,
                    documentNumber = docNo,
                    personalNumber = tckn,
                    fullName = fullName,
                    surname = surname,
                    givenNames = givenNames,
                    birthDate = birthDate,
                    sex = sex,
                    age = age,
                    isAdult = isAdult,
                    adultCode = isAdult ? "1" : "2",
                    summary = (!string.IsNullOrEmpty(fullName) ? fullName : "Yolcu") +
                              (!string.IsNullOrEmpty(docNo) ? " (" + docNo + ")" : "") +
                              (!string.IsNullOrEmpty(country) ? " - " + country : ""),
                    rawText = rawText
                };
            }
            catch (Exception ex)
            {
                return new { success = false, message = "Görsel işleme hatası: " + ex.Message };
            }
        }

        private class ParsedMrz
        {
            public string DocumentType { get; set; } = "Umuma Mahsus Pasaport";
            public string DocTypeCode { get; set; } = "1";
            public string Country { get; set; } = "";
            public string CountryCode { get; set; } = "";
            public bool IsTurkishCitizen { get; set; } = false;
            public string DocumentNumber { get; set; } = "";
            public string FullName { get; set; } = "";
            public string Surname { get; set; } = "";
            public string GivenNames { get; set; } = "";
            public string BirthDate { get; set; } = "";
            public int? Age { get; set; }
            public bool IsAdult { get; set; } = true;
            public string AdultCode { get; set; } = "1";
            public string PersonalNumber { get; set; } = "";
            public string Sex { get; set; } = "";
            public string RawText { get; set; } = "";
            public string Message { get; set; } = "";
        }

        private static ParsedMrz ParseMrzCodelines(string l1, string l2, string l3, string docTypeHint)
        {
            var p = new ParsedMrz();
            l1 = CleanMrzLine(l1);
            l2 = CleanMrzLine(l2);
            l3 = CleanMrzLine(l3);

            p.RawText = (l1 + "\n" + l2 + "\n" + l3).Trim();

            // 1. TD3 FORMATI (Standart Pasaportlar - 2 Satır x 44 Karakter - Yabancı Yolcuların Temel Belgesi)
            if (l1.Length >= 36 && (l1.StartsWith("P<") || l1.StartsWith("P") || l1.StartsWith("V<")))
            {
                p.DocumentType = l1.StartsWith("PD") || l1.StartsWith("D<") ? "Diplomatik Pasaport" : (l1.StartsWith("PS") || l1.StartsWith("S<") ? "Servis Pasaportu" : "Umuma Mahsus Pasaport");
                p.DocTypeCode = p.DocumentType.Contains("Diplomatik") ? "2" : (p.DocumentType.Contains("Servis") ? "3" : "1");

                // Line 1: Ülke Kodu & İsimler
                string cCode = "";
                if (l1.Length >= 5)
                {
                    cCode = l1.Substring(2, 3).Replace("<", "").Trim().ToUpperInvariant();
                    p.CountryCode = cCode;
                }

                // Türk Vatandaşı Kontrolü: Bu projede Türklere ceza işlemi uygulanmaz
                if (cCode == "TUR" || cCode == "TR")
                {
                    p.IsTurkishCitizen = true;
                    p.Country = "Türkiye";
                    p.Message = "Okunan belge Türk vatandaşına aittir (TUR). Türk vatandaşlarına vize/ceza işlemi uygulanamaz.";
                }
                else if (!string.IsNullOrEmpty(cCode))
                {
                    if (CountryMap.TryGetValue(cCode, out var mName)) p.Country = mName;
                    else p.Country = cCode;
                }

                string namePart = l1.Length > 5 ? l1.Substring(5) : "";
                var parts = namePart.Split(new[] { "<<" }, StringSplitOptions.RemoveEmptyEntries);
                p.Surname = CleanMrzWord(parts.Length > 0 ? parts[0] : "");
                p.GivenNames = CleanMrzWord(parts.Length > 1 ? parts[1] : "");
                p.FullName = (p.Surname + " " + p.GivenNames).Trim();

                // Line 2: Belge No (0-9), Uyruk (10-12), Doğum Tarihi (13-18), Cinsiyet (20)
                if (l2.Length >= 9) p.DocumentNumber = l2.Substring(0, 9).Replace("<", "").Trim();
                if (l2.Length >= 13)
                {
                    string natCode = l2.Substring(10, 3).Replace("<", "").Trim().ToUpperInvariant();
                    if (natCode == "TUR" || natCode == "TR")
                    {
                        p.IsTurkishCitizen = true;
                        p.Country = "Türkiye";
                        p.CountryCode = natCode;
                        p.Message = "Okunan belge Türk vatandaşına aittir (TUR). Türk vatandaşlarına vize/ceza işlemi uygulanamaz.";
                    }
                    else if (string.IsNullOrEmpty(p.Country))
                    {
                        p.CountryCode = natCode;
                        if (CountryMap.TryGetValue(natCode, out var mNat)) p.Country = mNat;
                        else p.Country = natCode;
                    }
                }

                if (l2.Length >= 19) p.BirthDate = FormatMrzDate(l2.Substring(13, 6));
                if (l2.Length >= 21) p.Sex = l2.Substring(20, 1) == "M" ? "Erkek" : (l2.Substring(20, 1) == "F" ? "Kadın" : "");

                if (l2.Length >= 42)
                {
                    string opt = l2.Substring(28, 14).Replace("<", "").Trim();
                    if (!string.IsNullOrEmpty(opt)) p.PersonalNumber = opt;
                }

                p.Age = CalculateAge(p.BirthDate);
                if (p.Age.HasValue)
                {
                    p.IsAdult = p.Age.Value >= 18;
                    p.AdultCode = p.IsAdult ? "1" : "2";
                }

                return p;
            }

            // 2. TD1 / TD2 FORMATI (3 satır x 30 karakter veya 2 satır x 36 karakter - Yabancı Kimlik & İkamet Kartları)
            if (l1.Length >= 26 && (l1.StartsWith("I<") || l1.StartsWith("I") || l1.StartsWith("A<") || l1.StartsWith("C<")))
            {
                p.DocumentType = "Kimlik Kartı";
                p.DocTypeCode = "1";

                var mC = Regex.Match(l1, @"^[IAC][<]*([A-Z]{3})");
                string cCode = mC.Success ? mC.Groups[1].Value : (l1.Length >= 5 ? l1.Substring(2, 3) : "");
                p.CountryCode = cCode;

                if (cCode == "TUR" || cCode == "TR")
                {
                    p.IsTurkishCitizen = true;
                    p.Country = "Türkiye";
                    p.Message = "Okunan belge Türk vatandaşına aittir (TUR). Türk vatandaşlarına vize/ceza işlemi uygulanamaz.";
                }
                else if (!string.IsNullOrEmpty(cCode))
                {
                    if (CountryMap.TryGetValue(cCode, out var mName)) p.Country = mName;
                    else p.Country = cCode;
                }

                int sStart = l1.IndexOf(cCode);
                if (sStart >= 0) sStart += cCode.Length; else sStart = 5;
                string rem = l1.Substring(Math.Min(sStart, l1.Length));
                if (rem.Length >= 9) p.DocumentNumber = rem.Substring(0, 9).Replace("<", "").Trim();

                // Line 2: Doğum Tarihi (0-5), Cinsiyet (7)
                if (l2.Length >= 6) p.BirthDate = FormatMrzDate(l2.Substring(0, 6));
                if (l2.Length >= 8)
                {
                    string sx = l2.Substring(7);
                    if (sx.StartsWith("M") || sx.StartsWith("19") || sx.StartsWith("IV")) p.Sex = "Erkek";
                    else if (sx.StartsWith("F")) p.Sex = "Kadın";
                }

                // Yabancı Kimlik / Kişisel No
                var tcknMatch = Regex.Match((l1 + " " + l2).Replace("<", " "), @"\b([1-9]\d{10})\b");
                if (tcknMatch.Success)
                {
                    p.PersonalNumber = tcknMatch.Groups[1].Value;
                }

                // Line 3: Soyad<<Ad
                string nameLine = !string.IsNullOrEmpty(l3) ? l3 : "";
                if (!string.IsNullOrEmpty(nameLine))
                {
                    var parts = nameLine.Split(new[] { "<<" }, StringSplitOptions.RemoveEmptyEntries);
                    p.Surname = CleanMrzWord(parts.Length > 0 ? parts[0] : "");
                    p.GivenNames = CleanMrzWord(parts.Length > 1 ? parts[1] : "");
                    p.FullName = (p.Surname + " " + p.GivenNames).Trim();
                }

                p.Age = CalculateAge(p.BirthDate);
                if (p.Age.HasValue)
                {
                    p.IsAdult = p.Age.Value >= 18;
                    p.AdultCode = p.IsAdult ? "1" : "2";
                }

                return p;
            }

            // 3. Fallback: Genel Regex Arama
            var all = (l1 + " " + l2 + " " + l3);
            var mPass = Regex.Match(all, @"\b([A-Z0-9]{8,9})\b");
            if (mPass.Success) p.DocumentNumber = mPass.Groups[1].Value;

            return p;
        }

        private static string CleanMrzWord(string raw)
        {
            if (string.IsNullOrWhiteSpace(raw)) return "";
            return raw.Replace("<", " ").Trim();
        }

        private static string FormatMrzDate(string yymmdd)
        {
            if (string.IsNullOrWhiteSpace(yymmdd) || yymmdd.Length < 6) return "";
            if (!int.TryParse(yymmdd.Substring(0, 2), out int yy)) return "";
            string mm = yymmdd.Substring(2, 2);
            string dd = yymmdd.Substring(4, 2);

            int curYear = DateTime.Now.Year % 100;
            int fullYear = yy <= curYear ? (2000 + yy) : (1900 + yy);

            if (int.TryParse(dd, out int d) && int.TryParse(mm, out int m))
            {
                if (d >= 1 && d <= 31 && m >= 1 && m <= 12)
                {
                    return string.Format("{0:D2}.{1:D2}.{2:D4}", d, m, fullYear);
                }
            }
            return "";
        }
    }
}
