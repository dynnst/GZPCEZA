using Newtonsoft.Json.Linq;
using System;
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

        public static object GetStatus()
        {
            try
            {
                string baseDir = AppDomain.CurrentDomain.BaseDirectory;
                string scannerExe = Path.Combine(baseDir, "App_Data", "ReaderScanner.exe");

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
                    string baseDir = AppDomain.CurrentDomain.BaseDirectory;
                    string scannerExe = Path.Combine(baseDir, "App_Data", "ReaderScanner.exe");
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
                                documentType = parsed.DocumentType,
                                country = parsed.Country,
                                documentNumber = parsed.DocumentNumber,
                                fullName = parsed.FullName,
                                surname = parsed.Surname,
                                givenNames = parsed.GivenNames,
                                birthDate = parsed.BirthDate,
                                personalNumber = parsed.PersonalNumber,
                                sex = parsed.Sex,
                                rawText = parsed.RawText,
                                line1 = line1,
                                line2 = line2,
                                line3 = line3,
                                summary = parsed.FullName + " (" + parsed.DocumentNumber + ") - " + parsed.Country
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
                                documentType = parsed.DocumentType,
                                country = parsed.Country,
                                documentNumber = parsed.DocumentNumber,
                                fullName = parsed.FullName,
                                surname = parsed.Surname,
                                givenNames = parsed.GivenNames,
                                birthDate = parsed.BirthDate,
                                personalNumber = parsed.PersonalNumber,
                                sex = parsed.Sex,
                                rawText = parsed.RawText,
                                summary = parsed.FullName + " (" + parsed.DocumentNumber + ") - " + parsed.Country
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
                                    documentType = "Pasaport / Kimlik",
                                    country = "Türkiye",
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

        private class ParsedMrz
        {
            public string DocumentType { get; set; } = "Umuma Mahsus Pasaport";
            public string Country { get; set; } = "";
            public string DocumentNumber { get; set; } = "";
            public string FullName { get; set; } = "";
            public string Surname { get; set; } = "";
            public string GivenNames { get; set; } = "";
            public string BirthDate { get; set; } = "";
            public string PersonalNumber { get; set; } = "";
            public string Sex { get; set; } = "";
            public string RawText { get; set; } = "";
        }

        private static ParsedMrz ParseMrzCodelines(string l1, string l2, string l3, string docTypeHint)
        {
            var p = new ParsedMrz();
            l1 = (l1 ?? "").Trim().ToUpperInvariant().Replace(" ", "");
            l2 = (l2 ?? "").Trim().ToUpperInvariant().Replace(" ", "");
            l3 = (l3 ?? "").Trim().ToUpperInvariant().Replace(" ", "");

            p.RawText = (l1 + "\n" + l2 + "\n" + l3).Trim();

            // 1. TD1 FORMATI (3 satır x 30 karakter - Yeni Kimlik Kartları & İkamet İzinleri)
            // Örnek:
            // Line 1: I<TURA17V792816<28123829162<<<
            // Line 2: 8404084M2902234TUR<<<<<<<<<<<6
            // Line 3: DAYAN<<NASIT<<<<<<<<<<<<<<<<<<
            if (l1.Length >= 28 && l2.Length >= 28 && (l1.StartsWith("I<") || l1.StartsWith("I") || l1.StartsWith("A<") || l1.StartsWith("C<")))
            {
                p.DocumentType = "Kimlik Kartı";
                if (l1.Length >= 5) p.Country = l1.Substring(2, 3).Replace("<", "");
                if (l1.Length >= 14) p.DocumentNumber = l1.Substring(5, 9).Replace("<", "");

                // Line 2: Doğum Tarihi (0-5), Cinsiyet (7), Son Geçerlilik (8-13)
                if (l2.Length >= 6) p.BirthDate = FormatMrzDate(l2.Substring(0, 6));
                if (l2.Length >= 8) p.Sex = l2.Substring(7, 1);

                // 11 haneli TCKN / YKN / Kişisel No tespiti
                var tcknMatch = Regex.Match((l1 + " " + l2).Replace("<", " "), @"\b(\d{11})\b");
                if (tcknMatch.Success)
                {
                    p.PersonalNumber = tcknMatch.Groups[1].Value;
                }

                // Line 3: Soyad<<Ad
                string nameLine = !string.IsNullOrEmpty(l3) ? l3 : "";
                if (!string.IsNullOrEmpty(nameLine))
                {
                    var parts = nameLine.Split(new[] { "<<" }, StringSplitOptions.None);
                    p.Surname = CleanMrzWord(parts.Length > 0 ? parts[0] : "");
                    p.GivenNames = CleanMrzWord(parts.Length > 1 ? parts[1] : "");
                    p.FullName = !string.IsNullOrEmpty(p.GivenNames)
                        ? (p.GivenNames + " " + p.Surname).Trim()
                        : p.Surname;
                }

                return p;
            }

            // 2. TD3 FORMATI (2 satır x 44 karakter - Standart Pasaportlar)
            // Örnek:
            // Line 1: P<TURDAYAN<<NASIT<<<<<<<<<<<<<<<<<<<<<<<<<<<
            // Line 2: U123456784TUR8404084M2902234<<<<<<<<<<<<<<02
            if (l1.Length >= 38 && l2.Length >= 38 && (l1.StartsWith("P<") || l1.StartsWith("P") || l1.StartsWith("V<")))
            {
                p.DocumentType = l1.StartsWith("PD") || l1.StartsWith("D<") ? "Diplomatik Pasaport" : (l1.StartsWith("PS") || l1.StartsWith("S<") ? "Servis Pasaportu" : "Umuma Mahsus Pasaport");
                if (l1.Length >= 5) p.Country = l1.Substring(2, 3).Replace("<", "");

                // Line 1: İsimler (5. karakterden itibaren)
                string namePart = l1.Substring(5);
                var parts = namePart.Split(new[] { "<<" }, StringSplitOptions.None);
                p.Surname = CleanMrzWord(parts.Length > 0 ? parts[0] : "");
                p.GivenNames = CleanMrzWord(parts.Length > 1 ? parts[1] : "");
                p.FullName = (p.Surname + " " + p.GivenNames).Trim();

                // Line 2: Belge No (0-9), Uyruk (10-12), Doğum Tarihi (13-18), Cinsiyet (20)
                if (l2.Length >= 9) p.DocumentNumber = l2.Substring(0, 9).Replace("<", "");
                if (string.IsNullOrEmpty(p.Country) && l2.Length >= 13) p.Country = l2.Substring(10, 3).Replace("<", "");
                if (l2.Length >= 19) p.BirthDate = FormatMrzDate(l2.Substring(13, 6));
                if (l2.Length >= 21) p.Sex = l2.Substring(20, 1);

                if (l2.Length >= 42)
                {
                    string opt = l2.Substring(28, 14).Replace("<", "").Trim();
                    if (Regex.IsMatch(opt, @"^\d{11}$")) p.PersonalNumber = opt;
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
