using System;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Net;
using System.Reflection;
using System.ServiceProcess;
using System.Text;
using System.Threading;

namespace Sahtecilik.ReaderBridge
{
    class Program
    {
        private const int Port = 41102;
        private static HttpListener _listener;
        private static bool _isRunning = true;
        private static string _resolved3mBinDir = null;

        static void Main(string[] args)
        {
            EnsureAutoStartInstalled();
            RegisterProtocolInHkcu();
            KillConflictingWedges();

            if (!Environment.UserInteractive)
            {
                ServiceBase.Run(new EgmBridgeService());
                return;
            }

            bool createdNew;
            using (var mutex = new Mutex(true, "EgmReaderBridgeSingleInstanceMutex", out createdNew))
            {
                if (!createdNew)
                {
                    // Başka bir EgmReaderBridge örneği zaten arka planda çalışıyor!
                    return;
                }
            Console.OutputEncoding = Encoding.UTF8;
            Console.Title = "EGM Optik Okuyucu Köprüsü (3M / Regula) - Port " + Port;

            Console.WriteLine("====================================================================");
            Console.WriteLine("  EGM ADLİ BELGE VE PASAPORT İNCELEME SİSTEMİ");
            Console.WriteLine("  Masaüstü Optik Okuyucu Donanım Köprüsü (3M & Regula)");
            Console.WriteLine("====================================================================");

            _resolved3mBinDir = Find3mSdkBinDir();
            if (_resolved3mBinDir != null)
            {
                Console.WriteLine("  [✓] 3M / Gemalto / Thales SDK Dizini: " + _resolved3mBinDir);
                AppDomain.CurrentDomain.AssemblyResolve += (s, e) =>
                {
                    try
                    {
                        var name = new AssemblyName(e.Name).Name;
                        var p = Path.Combine(_resolved3mBinDir, name + ".dll");
                        if (File.Exists(p)) return Assembly.LoadFrom(p);
                    }
                    catch { }
                    return null;
                };
            }
            else
            {
                Console.WriteLine("  [!] 3M SDK bu bilgisayarda bulunamadı.");
            }

            // Regula kontrolü
            bool hasRegula = false;
            try
            {
                Type t = Type.GetTypeFromProgID("READERDEMO.RegulaReader");
                if (t == null) t = Type.GetTypeFromCLSID(new Guid("F4E2014F-3E2A-4FCF-BA56-EB86B73F30FB"));
                hasRegula = (t != null);
            }
            catch { }
            Console.WriteLine(hasRegula ? "  [✓] Regula SDK (COM): Kurulu ve Hazır" : "  [!] Regula SDK bulunamadı.");

            Console.WriteLine("--------------------------------------------------------------------");

            StartHttpServer();

            Console.WriteLine("  [🟢 AKTİF] Köprü http://127.0.0.1:" + Port + "/ adresinde dinleniyor.");
            Console.WriteLine("  Merkezi sunucudaki web sayfası (76 vb.) masanızdaki okuyucuya doğrudan erişebilir.");
            Console.WriteLine("  (Bu pencereyi simge durumuna küçültebilirsiniz. Çıkmak için 'Q' veya Ctrl+C basınız.)");
            Console.WriteLine("====================================================================");

            while (_isRunning)
            {
                try
                {
                    if (Console.IsInputRedirected)
                    {
                        Thread.Sleep(2000);
                        continue;
                    }
                    var key = Console.ReadKey(true);
                    if (key.Key == ConsoleKey.Q)
                    {
                        _isRunning = false;
                        break;
                    }
                }
                catch
                {
                    // Arka planda konsolsuz (silent background daemon) çalışırken
                    Thread.Sleep(2000);
                }
            }

            StopHttpServer();
            }
        }

        private static void StartHttpServer()
        {
            try
            {
                _listener = new HttpListener();
                _listener.Prefixes.Add("http://127.0.0.1:" + Port + "/");
                _listener.Prefixes.Add("http://localhost:" + Port + "/");
                _listener.Start();

                var thread = new Thread(ListenLoop) { IsBackground = true };
                thread.Start();
            }
            catch (Exception ex)
            {
                Console.WriteLine("  [X] HTTP Dinleyici başlatılamadı: " + ex.Message);
            }
        }

        internal static void StartServiceMode()
        {
            try
            {
                _resolved3mBinDir = Find3mSdkBinDir();
                if (_resolved3mBinDir != null)
                {
                    AppDomain.CurrentDomain.AssemblyResolve += (s, e) =>
                    {
                        try
                        {
                            var name = new AssemblyName(e.Name).Name;
                            var p = Path.Combine(_resolved3mBinDir, name + ".dll");
                            if (File.Exists(p)) return Assembly.LoadFrom(p);
                        }
                        catch { }
                        return null;
                    };
                }
                StartHttpServer();
            }
            catch { }
        }

        internal static void StopServiceMode()
        {
            _isRunning = false;
            StopHttpServer();
        }

        private static void StopHttpServer()
        {
            try
            {
                _listener?.Stop();
                _listener?.Close();
            }
            catch { }
        }

        private static void ListenLoop()
        {
            while (_isRunning && _listener != null && _listener.IsListening)
            {
                try
                {
                    var ctx = _listener.GetContext();
                    ThreadPool.QueueUserWorkItem((state) => HandleRequest((HttpListenerContext)state), ctx);
                }
                catch
                {
                    if (!_isRunning) break;
                }
            }
        }

        private static void HandleRequest(HttpListenerContext ctx)
        {
            var req = ctx.Request;
            var resp = ctx.Response;

            // CORS Başlıkları (Merkezi sunucu 10.7.202.76 vb. tarayıcıdan yerel köprüye erişebilsin)
            resp.AddHeader("Access-Control-Allow-Origin", "*");
            resp.AddHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
            resp.AddHeader("Access-Control-Allow-Headers", "Content-Type, Accept, Authorization");
            resp.AddHeader("Access-Control-Allow-Private-Network", "true");
            resp.AddHeader("Cache-Control", "no-cache, no-store, must-revalidate");

            if (req.HttpMethod.Equals("OPTIONS", StringComparison.OrdinalIgnoreCase))
            {
                resp.StatusCode = 200;
                resp.Close();
                return;
            }

            string rawPath = (req.Url.AbsolutePath ?? "/").ToLowerInvariant();
            string responseJson = "";

            try
            {
                if (rawPath.Contains("status"))
                {
                    responseJson = "{\"success\":true,\"isRunning\":true,\"message\":\"EGM Optik Okuyucu Köprüsü Aktif\",\"port\":" + Port + "}";
                }
                else
                {
                    // Scan isteği
                    string requestedDevice = req.QueryString["device"] ?? "auto";
                    responseJson = PerformScan(requestedDevice);
                }
            }
            catch (Exception ex)
            {
                responseJson = "{\"success\":false,\"message\":\"Köprü tarama hatası: " + EscapeJsonString(ex.Message) + "\"}";
            }

            try
            {
                byte[] buffer = Encoding.UTF8.GetBytes(responseJson);
                resp.ContentType = "application/json; charset=utf-8";
                resp.ContentLength64 = buffer.Length;
                resp.StatusCode = 200;
                resp.OutputStream.Write(buffer, 0, buffer.Length);
                resp.OutputStream.Flush();
            }
            catch { }
            finally
            {
                try { resp.Close(); } catch { }
            }
        }

        private static readonly object _scanLock = new object();

        private static bool CheckIfRegulaUsbPlugged()
        {
            try
            {
                using (var key = Microsoft.Win32.Registry.LocalMachine.OpenSubKey(@"SYSTEM\CurrentControlSet\Enum\USB"))
                {
                    if (key != null)
                    {
                        foreach (var subName in key.GetSubKeyNames())
                        {
                            if (subName.IndexOf("VID_1C6A", StringComparison.OrdinalIgnoreCase) >= 0)
                            {
                                return true;
                            }
                        }
                    }
                }
            }
            catch { }
            return false;
        }

        private static string PerformScan(string requestedDevice)
        {
            lock (_scanLock)
            {
                Console.WriteLine("\n[" + DateTime.Now.ToString("HH:mm:ss") + "] Tarama isteği alındı (Talep: " + requestedDevice + ")...");

                bool regulaPlugged = CheckIfRegulaUsbPlugged();

                // 1. Eğer Regula takılıysa veya talep regula ise önce Regula'yı dene
                if (requestedDevice == "regula" || (requestedDevice == "auto" && regulaPlugged))
                {
                    string resRegula = TryScanRegula();
                    if (!string.IsNullOrEmpty(resRegula) && resRegula.Contains("\"success\":true"))
                    {
                        Console.WriteLine("  -> Regula Cihazından başarıyla okundu!");
                        return resRegula;
                    }

                    if (requestedDevice == "auto" && _resolved3mBinDir != null)
                    {
                        string res3m = TryScan3M();
                        if (!string.IsNullOrEmpty(res3m) && res3m.Contains("\"success\":true"))
                        {
                            Console.WriteLine("  -> 3M / Thales Cihazından başarıyla okundu!");
                            return res3m;
                        }
                    }
                }
                else
                {
                    // 3M / Thales takılı veya talep edilmişse önce 3M'i dene
                    if (requestedDevice == "3m" || requestedDevice == "thales" || requestedDevice == "auto")
                    {
                        if (_resolved3mBinDir != null)
                        {
                            string res3m = TryScan3M();
                            if (!string.IsNullOrEmpty(res3m) && res3m.Contains("\"success\":true"))
                            {
                                Console.WriteLine("  -> 3M / Thales Cihazından başarıyla okundu!");
                                return res3m;
                            }
                        }
                    }

                    string resRegula = TryScanRegula();
                    if (!string.IsNullOrEmpty(resRegula) && resRegula.Contains("\"success\":true"))
                    {
                        Console.WriteLine("  -> Regula Cihazından başarıyla okundu!");
                        return resRegula;
                    }
                }

                Console.WriteLine("  -> Cihazdan görüntü/veri alınamadı.");
                return "{\"success\":false,\"message\":\"Masanızdaki 3M veya Regula optik okuyucudan pasaport veya kimlik okunamadı. Lütfen belgenin okuyucu camına tam yerleştirildiğinden ve cihazın açık olduğundan emin olunuz.\"}";
            }
        }

        private static void KillConflictingWedges()
        {
            try
            {
                foreach (var p in Process.GetProcesses())
                {
                    try
                    {
                        string name = p.ProcessName.ToLowerInvariant();
                        if (name.Contains("outputwedge") || (name.Contains("wedge") && !name.Contains("bridge")))
                        {
                            p.Kill();
                        }
                    }
                    catch { }
                }
            }
            catch { }
        }

        private static string TryScan3M()
        {
            try
            {
                // 3M OutputWedge donanım portunu meşgul ediyorsa veya hata popup'ı verdiyse kapat
                KillConflictingWedges();
                Thread.Sleep(350);

                try
                {
                    MMM.Readers.FullPage.Reader.EnableLogging(false, 0, 0, "ReaderBridge.log");
                    var initRes = MMM.Readers.FullPage.Reader.Initialise(null, null, null, null, false, false);
                    if (initRes != MMM.Readers.ErrorCode.NO_ERROR_OCCURRED)
                    {
                        return null;
                    }

                    // USB donanım el sıkışması ve hazır olma kontrolü (maks 3 saniye)
                    bool isInit = false;
                    for (int i = 0; i < 15; i++)
                    {
                        if (MMM.Readers.FullPage.Reader.IsInitialised())
                        {
                            isInit = true;
                            break;
                        }
                        Thread.Sleep(200);
                    }

                    if (!isInit) return null;

                    // Cihaz veri gönderme ve görsel yakalama ayarlarını kesinleştir (VIS, UV, IR, Fotoğraf)
                    try
                    {
                        MMM.Readers.FullPage.ReaderSettings settings;
                        if (MMM.Readers.FullPage.Reader.GetSettings(out settings) == MMM.Readers.ErrorCode.NO_ERROR_OCCURRED)
                        {
                            var dataSend = settings.puDataToSend;
                            dataSend.send |= (0x000001 | 0x000002 | 0x000004 | 0x000008 | 0x000010 | 0x000020 | 0x002000);
                            dataSend.enabled = 1;
                            settings.puDataToSend = dataSend;

                            var imgSet = settings.puImageSettings;
                            imgSet.faceFind = true;
                            imgSet.faceFindPassport = true;
                            settings.puImageSettings = imgSet;

                            MMM.Readers.FullPage.Reader.UpdateSettings(settings);
                        }
                    }
                    catch { }

                    // Belgenin okuyucu camına yerleştirilmesini bekle (maksimum 4 saniye payı)
                    for (int waitDoc = 0; waitDoc < 16; waitDoc++)
                    {
                        if (MMM.Readers.FullPage.Reader.IsDocumentOnWindow()) break;
                        Thread.Sleep(250);
                    }

                    var readRes = MMM.Readers.FullPage.Reader.ReadDocument();
                    if (readRes != MMM.Readers.ErrorCode.NO_ERROR_OCCURRED)
                    {
                        Thread.Sleep(300);
                        readRes = MMM.Readers.FullPage.Reader.ReadDocument();
                    }

                    string visBase64 = Get3mImageBase64(MMM.Readers.FullPage.DataType.CD_IMAGEVIS);
                    string uvBase64 = Get3mImageBase64(MMM.Readers.FullPage.DataType.CD_IMAGEUV);
                    string irBase64 = Get3mImageBase64(MMM.Readers.FullPage.DataType.CD_IMAGEIR);
                    string photoBase64 = Get3mImageBase64(MMM.Readers.FullPage.DataType.CD_IMAGEPHOTO);
                    string coaxVisBase64 = Get3mImageBase64(MMM.Readers.FullPage.DataType.CD_IMAGECOAXVIS);

                    string docType = "", line1 = "", line2 = "", line3 = "";
                    string rawMrz = "";
                    MMM.Readers.CodelineData? clData = null;
                    object codelineObj = null;

                    // Codeline / MRZ datasının işlenmesi için kısa pay ve döngü
                    for (int retry = 0; retry < 5; retry++)
                    {
                        if (MMM.Readers.FullPage.Reader.GetData(MMM.Readers.FullPage.DataType.CD_CODELINE_DATA, ref codelineObj) == MMM.Readers.ErrorCode.NO_ERROR_OCCURRED && codelineObj != null)
                        {
                            try
                            {
                                var parsedCl = (MMM.Readers.CodelineData)codelineObj;
                                clData = parsedCl;
                                docType = parsedCl.DocType ?? "";
                                line1 = parsedCl.Line1 ?? "";
                                line2 = parsedCl.Line2 ?? "";
                                line3 = parsedCl.Line3 ?? "";
                                rawMrz = parsedCl.Data ?? "";
                                if (!string.IsNullOrEmpty(line1) || !string.IsNullOrEmpty(rawMrz)) break;
                            }
                            catch { }
                        }
                        Thread.Sleep(150);
                    }

                    // Fallback to CD_CODELINE if line1 is empty
                    if (string.IsNullOrEmpty(line1) && string.IsNullOrEmpty(rawMrz))
                    {
                        try
                        {
                            object rawCl = null;
                            if (MMM.Readers.FullPage.Reader.GetData(MMM.Readers.FullPage.DataType.CD_CODELINE, ref rawCl) == MMM.Readers.ErrorCode.NO_ERROR_OCCURRED && rawCl != null)
                            {
                                string str = rawCl.ToString() ?? "";
                                rawMrz = str;
                                var spl = str.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);
                                if (spl.Length > 0) line1 = spl[0].Trim();
                                if (spl.Length > 1) line2 = spl[1].Trim();
                                if (spl.Length > 2) line3 = spl[2].Trim();
                            }
                        }
                        catch { }
                    }

                    MMM.Readers.FullPage.Reader.Shutdown();

                    if (string.IsNullOrEmpty(line1) && string.IsNullOrEmpty(rawMrz) && string.IsNullOrEmpty(visBase64))
                    {
                        return "{\"success\":false,\"message\":\"3M cihazı belgeyi algılayamadı. Lütfen pasaportu veya kimliği okuyucu camına tam yerleştiriniz.\"}";
                    }

                    // ICAO 9303 / MRZ alanlarını ayrıştır
                    var mrzInfo = ParseMrzData(line1, line2, line3, rawMrz, clData);

                    // Filigran ve Mikrobaskı katmanlarını türet
                    string watermarkBase64 = ExtractWatermark(visBase64, irBase64, coaxVisBase64);
                    string microBase64 = ExtractMicroprint(visBase64);

                    var sb = new StringBuilder();
                    sb.Append("{");
                    sb.Append("\"success\":true,");
                    sb.Append("\"deviceName\":\"3M Cogent / Gemalto (Masaüstü)\",");
                    sb.AppendFormat("\"docType\":{0},", EscapeJson(mrzInfo.DocType));
                    sb.AppendFormat("\"line1\":{0},", EscapeJson(line1));
                    sb.AppendFormat("\"line2\":{0},", EscapeJson(line2));
                    sb.AppendFormat("\"line3\":{0},", EscapeJson(line3));
                    sb.AppendFormat("\"rawMrz\":{0},", EscapeJson(mrzInfo.RawMrz));
                    sb.AppendFormat("\"documentNumber\":{0},", EscapeJson(mrzInfo.DocNumber));
                    sb.AppendFormat("\"country\":{0},", EscapeJson(mrzInfo.Country));
                    sb.AppendFormat("\"documentType\":{0},", EscapeJson(mrzInfo.DocType));
                    sb.AppendFormat("\"fullName\":{0},", EscapeJson(mrzInfo.FullName));
                    sb.AppendFormat("\"surname\":{0},", EscapeJson(mrzInfo.Surname));
                    sb.AppendFormat("\"givenNames\":{0},", EscapeJson(mrzInfo.GivenNames));
                    sb.AppendFormat("\"birthDate\":{0},", EscapeJson(mrzInfo.BirthDate));
                    sb.AppendFormat("\"expiryDate\":{0},", EscapeJson(mrzInfo.ExpiryDate));
                    sb.AppendFormat("\"personalNumber\":{0},", EscapeJson(mrzInfo.PersonalNumber));
                    sb.AppendFormat("\"sex\":{0},", EscapeJson(mrzInfo.Sex));
                    sb.AppendFormat("\"allChecksPassed\":{0},", mrzInfo.AllChecksPassed ? "true" : "false");
                    sb.AppendFormat("\"visBase64\":{0},", EscapeJson(visBase64));
                    sb.AppendFormat("\"uvBase64\":{0},", EscapeJson(uvBase64));
                    sb.AppendFormat("\"irBase64\":{0},", EscapeJson(irBase64));
                    sb.AppendFormat("\"watermarkBase64\":{0},", EscapeJson(watermarkBase64));
                    sb.AppendFormat("\"microBase64\":{0},", EscapeJson(microBase64));
                    sb.AppendFormat("\"photoBase64\":{0},", EscapeJson(photoBase64));
                    sb.AppendFormat("\"coaxVisBase64\":{0}", EscapeJson(coaxVisBase64));
                    sb.Append("}");

                    return sb.ToString();
                }
                finally
                {
                    // OutputWedge'i ASLA yeniden başlatmıyoruz.
                    // OutputWedgeSysTray kamerayı ele geçirmeye çalıştığında 536870916 ("Camera driver returned an error code")
                    // hatasını verip ekrana popup açar ve sonraki taramaları kilitler.
                }
            }
            catch
            {
                try { MMM.Readers.FullPage.Reader.Shutdown(); } catch { }
                return null;
            }
        }

        private static string Get3mImageBase64(MMM.Readers.FullPage.DataType dt)
        {
            try
            {
                object data = null;
                var res = MMM.Readers.FullPage.Reader.GetData(dt, ref data);
                if (res != MMM.Readers.ErrorCode.NO_ERROR_OCCURRED || data == null)
                {
                    return "";
                }

                if (data is Bitmap bmp)
                {
                    using (var ms = new MemoryStream())
                    {
                        var encoder = GetEncoder(ImageFormat.Jpeg);
                        if (encoder != null)
                        {
                            var encParams = new EncoderParameters(1);
                            encParams.Param[0] = new EncoderParameter(System.Drawing.Imaging.Encoder.Quality, 88L);
                            bmp.Save(ms, encoder, encParams);
                        }
                        else
                        {
                            bmp.Save(ms, ImageFormat.Jpeg);
                        }
                        return Convert.ToBase64String(ms.ToArray());
                    }
                }
                else if (data is byte[] bArr && bArr.Length > 0)
                {
                    try
                    {
                        using (var inMs = new MemoryStream(bArr))
                        using (var b = new Bitmap(inMs))
                        using (var outMs = new MemoryStream())
                        {
                            b.Save(outMs, ImageFormat.Jpeg);
                            return Convert.ToBase64String(outMs.ToArray());
                        }
                    }
                    catch
                    {
                        return Convert.ToBase64String(bArr);
                    }
                }
            }
            catch { }
            return "";
        }

        private static string TryScanRegula()
        {
            dynamic rr = null;
            try
            {
                // Zombileri temizle
                try
                {
                    foreach (var z in Process.GetProcessesByName("READERDEMO")) { try { z.Kill(); z.WaitForExit(600); } catch { } }
                }
                catch { }

                Type comType = Type.GetTypeFromProgID("READERDEMO.RegulaReader");
                if (comType == null) comType = Type.GetTypeFromCLSID(new Guid("F4E2014F-3E2A-4FCF-BA56-EB86B73F30FB"));
                if (comType == null) return null;

                rr = Activator.CreateInstance(comType);
                if (rr == null) return null;

                try
                {
                    rr.InBackground = true;
                    rr.DoHideMinimized = true;
                    rr.DoShowStatusBar = false;
                    rr.DoShowMenuToolbars = false;
                    rr.DoShowShortResults = false;
                    rr.MinimizeOnRun = true;
                    rr.ShowTrayIcon = false;
                    rr.DoSound = false;
                    rr.DoReceiveImages = true;
                    rr.DoReceiveAllScannedImages = true;
                    rr.DoMRZOCR = true;
                    rr.DoVisualOCR = true;
                    rr.DoGraphics = true;
                    rr.DoAuthenticity = true;
                    rr.Connect();
                }
                catch { }

                bool connected = false;
                try { connected = (bool)rr.Connected; } catch { }
                if (!connected) return null;

                try
                {
                    rr.GetImages();
                }
                catch
                {
                    try { rr.Process(); } catch { }
                }

                // Donanımın ışıkları yakıp taramaya başlaması için pay ver
                Thread.Sleep(800);

                int waited = 800;
                while (waited < 18000)
                {
                    bool isBusy = false;
                    try { isBusy = (bool)rr.IsBusy; } catch { }
                    if (!isBusy)
                    {
                        // Işık geçişleri (VIS -> UV -> IR) arasında anlık false olmasını filtrele
                        Thread.Sleep(400);
                        try { isBusy = (bool)rr.IsBusy; } catch { }
                        if (!isBusy) break; // Tarama kesinlikle tamamlandı
                    }
                    Thread.Sleep(200);
                    waited += 600;
                }

                // Bellek havuzunun hazırlanması için kısa bekleme
                Thread.Sleep(300);

                string visBase64 = "", uvBase64 = "", irBase64 = "", photoBase64 = "", coaxVisBase64 = "";
                string line1 = "", line2 = "", line3 = "";

                try
                {
                    int imgCount = 0;
                    try { imgCount = (int)rr.ImagesCount; } catch { }
                    for (int i = 0; i < imgCount; i++)
                    {
                        try
                        {
                            int light = (int)rr.ImageLight(i);
                            int page = 0;
                            try { page = (int)rr.ImagePage(i); } catch { }
                            if (page != 0) continue;

                            string b64 = "";
                            try
                            {
                                object rawData = rr.Image(i);
                                if (rawData is byte[] bArr) b64 = Convert.ToBase64String(bArr);
                            }
                            catch { }

                            if (!string.IsNullOrEmpty(b64))
                            {
                                if ((light == 6 || (light & 0x06) != 0 || (light & 0x802000) != 0) && string.IsNullOrEmpty(visBase64)) visBase64 = b64;
                                else if ((light == 128 || (light & 0x80) != 0) && string.IsNullOrEmpty(uvBase64)) uvBase64 = b64;
                                else if ((light == 24 || (light & 0x18) != 0 || (light & 0x1001040) != 0) && string.IsNullOrEmpty(irBase64)) irBase64 = b64;
                                else if ((light == 8 || (light & 0x0C00) != 0) && string.IsNullOrEmpty(coaxVisBase64)) coaxVisBase64 = b64;
                                else if (string.IsNullOrEmpty(visBase64)) visBase64 = b64;
                            }
                        }
                        catch { }
                    }
                }
                catch { }

                // Fallback 1: GetReaderFileImage
                if (string.IsNullOrEmpty(visBase64))
                {
                    try
                    {
                        for (int i = 0; i < 20; i++)
                        {
                            try
                            {
                                byte[] imgBytes = (byte[])rr.GetReaderFileImage(i);
                                int light = (int)rr.CheckReaderImageLight(i);
                                if (imgBytes != null && imgBytes.Length > 0)
                                {
                                    string b64 = Convert.ToBase64String(imgBytes);
                                    if (((light & 0x06) != 0 || (light & 0x802000) != 0) && string.IsNullOrEmpty(visBase64)) visBase64 = b64;
                                    else if ((light & 0x80) != 0 && string.IsNullOrEmpty(uvBase64)) uvBase64 = b64;
                                    else if (((light & 0x18) != 0 || (light & 0x1001040) != 0) && string.IsNullOrEmpty(irBase64)) irBase64 = b64;
                                    else if ((light & 0x0C00) != 0 && string.IsNullOrEmpty(coaxVisBase64)) coaxVisBase64 = b64;
                                    else if (string.IsNullOrEmpty(visBase64)) visBase64 = b64;
                                }
                            }
                            catch { }
                        }
                    }
                    catch { }
                }

                // Fallback 2: Regula Scans Disk Klasörleri
                if (string.IsNullOrEmpty(visBase64))
                {
                    try
                    {
                        string[] scanDirs = new string[]
                        {
                            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), @"Regula\Document Reader SDK\Scans"),
                            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData), @"Regula\Document Reader SDK\Scans"),
                            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), @"Regula\Scans"),
                            @"C:\Regula\Scans",
                            @"C:\RegulaScans"
                        };
                        foreach (var sDir in scanDirs)
                        {
                            if (Directory.Exists(sDir))
                            {
                                var files = new DirectoryInfo(sDir).GetFiles("*.*", SearchOption.AllDirectories)
                                    .Where(f => (DateTime.UtcNow - f.LastWriteTimeUtc).TotalMinutes < 3)
                                    .OrderByDescending(f => f.LastWriteTimeUtc)
                                    .ToList();
                                foreach (var f in files)
                                {
                                    string name = f.Name.ToLowerInvariant();
                                    if ((name.Contains("vis") || name.Contains("white") || name.Contains("color")) && string.IsNullOrEmpty(visBase64))
                                        visBase64 = Convert.ToBase64String(File.ReadAllBytes(f.FullName));
                                    else if (name.Contains("uv") && string.IsNullOrEmpty(uvBase64))
                                        uvBase64 = Convert.ToBase64String(File.ReadAllBytes(f.FullName));
                                    else if (name.Contains("ir") && string.IsNullOrEmpty(irBase64))
                                        irBase64 = Convert.ToBase64String(File.ReadAllBytes(f.FullName));
                                }
                                if (!string.IsNullOrEmpty(visBase64)) break;
                            }
                        }
                    }
                    catch { }
                }

                // Fotoğraf
                try
                {
                    object pData = rr.Photo;
                    if (pData is byte[] pb && pb.Length > 0) photoBase64 = Convert.ToBase64String(pb);
                }
                catch { }

                // MRZ Çek
                // 1. Önce doğrudan GetMRZLines çağrısını dene
                try
                {
                    string mrzText = (string)rr.GetMRZLines();
                    if (!string.IsNullOrEmpty(mrzText))
                    {
                        var lines = mrzText.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);
                        if (lines.Length >= 2)
                        {
                            line1 = lines[0].Trim();
                            line2 = lines[1].Trim();
                            if (lines.Length >= 3) line3 = lines[2].Trim();
                        }
                    }
                }
                catch { }

                // 2. MRZ bulunamadıysa XML sonuçlarını kontrol et (OCRLexicalAnalyze = 15)
                if (string.IsNullOrEmpty(line1))
                {
                    try
                    {
                        int totalLex = 0;
                        try { totalLex = (int)rr.IsReaderResultTypeAvailable(15); } catch { }
                        if (totalLex > 0)
                        {
                            string xml = (string)rr.CheckReaderResultXML(15, 0, 0);
                            if (!string.IsNullOrEmpty(xml))
                            {
                                var doc = new System.Xml.XmlDocument();
                                doc.LoadXml(xml);
                                var mrzNodes = doc.GetElementsByTagName("Field_MRZ");
                                var mrzLines = new System.Collections.Generic.List<string>();
                                foreach (System.Xml.XmlNode n in mrzNodes)
                                {
                                    string t = (n.InnerText ?? "").Trim();
                                    if (t.Length >= 28) mrzLines.Add(t);
                                }
                                if (mrzLines.Count >= 2)
                                {
                                    line1 = mrzLines[0];
                                    line2 = mrzLines[1];
                                    if (mrzLines.Count >= 3) line3 = mrzLines[2];
                                }
                            }
                        }
                    }
                    catch { }
                }

                // 3. XML sonuçlarını kontrol et (MRZ_OCR = 3)
                if (string.IsNullOrEmpty(line1))
                {
                    try
                    {
                        int totalMrz = 0;
                        try { totalMrz = (int)rr.IsReaderResultTypeAvailable(3); } catch { }
                        if (totalMrz > 0)
                        {
                            string xml3 = (string)rr.CheckReaderResultXML(3, 0, 0);
                            if (!string.IsNullOrEmpty(xml3))
                            {
                                var doc3 = new System.Xml.XmlDocument();
                                doc3.LoadXml(xml3);
                                var strNodes = doc3.GetElementsByTagName("String");
                                var list3 = new System.Collections.Generic.List<string>();
                                foreach (System.Xml.XmlNode sn in strNodes)
                                {
                                    string t = (sn.InnerText ?? "").Trim();
                                    if (t.Length >= 28) list3.Add(t);
                                }
                                if (list3.Count >= 2)
                                {
                                    line1 = list3[0];
                                    line2 = list3[1];
                                    if (list3.Count >= 3) line3 = list3[2];
                                }
                            }
                        }
                    }
                    catch { }
                }

                // 4. Regula Scans klasöründen en son taranan dosyaları oku (MRZ fallback)
                if (string.IsNullOrEmpty(line1))
                {
                    try
                    {
                        string[] scanDirs = new string[]
                        {
                            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), @"Regula\Document Reader SDK\Scans"),
                            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData), @"Regula\Document Reader SDK\Scans"),
                            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), @"Regula\Scans"),
                            @"C:\Regula\Scans",
                            @"C:\RegulaScans"
                        };
                        foreach (var sDir in scanDirs)
                        {
                            if (Directory.Exists(sDir))
                            {
                                var txtFiles = new DirectoryInfo(sDir).GetFiles("*.txt", SearchOption.AllDirectories)
                                    .Concat(new DirectoryInfo(sDir).GetFiles("*.xml", SearchOption.AllDirectories))
                                    .Where(f => (DateTime.UtcNow - f.LastWriteTimeUtc).TotalMinutes < 3)
                                    .OrderByDescending(f => f.LastWriteTimeUtc)
                                    .ToList();

                                foreach (var tf in txtFiles)
                                {
                                    try
                                    {
                                        string content = File.ReadAllText(tf.FullName, Encoding.UTF8);
                                        var mrzMatch = System.Text.RegularExpressions.Regex.Matches(content, @"[A-Z0-9<]{30,44}");
                                        if (mrzMatch.Count >= 2)
                                        {
                                            line1 = mrzMatch[0].Value;
                                            line2 = mrzMatch[1].Value;
                                            if (mrzMatch.Count >= 3) line3 = mrzMatch[2].Value;
                                            break;
                                        }
                                    }
                                    catch { }
                                }
                                if (!string.IsNullOrEmpty(line1)) break;
                            }
                        }
                    }
                    catch { }
                }

                try { rr.Disconnect(); } catch { }

                if (string.IsNullOrEmpty(visBase64) && string.IsNullOrEmpty(line1)) return null;

                // ICAO 9303 / MRZ alanlarını ayrıştır
                var mrzInfo = ParseMrzData(line1, line2, line3, null, null);

                string watermarkBase64 = ExtractWatermark(visBase64, irBase64, coaxVisBase64);
                string microBase64 = ExtractMicroprint(visBase64);

                var sb = new StringBuilder();
                sb.Append("{");
                sb.Append("\"success\":true,");
                sb.Append("\"deviceName\":\"Regula Document Reader (Masaüstü)\",");
                sb.AppendFormat("\"docType\":{0},", EscapeJson(mrzInfo.DocType));
                sb.AppendFormat("\"line1\":{0},", EscapeJson(line1));
                sb.AppendFormat("\"line2\":{0},", EscapeJson(line2));
                sb.AppendFormat("\"line3\":{0},", EscapeJson(line3));
                sb.AppendFormat("\"rawMrz\":{0},", EscapeJson(mrzInfo.RawMrz));
                sb.AppendFormat("\"documentNumber\":{0},", EscapeJson(mrzInfo.DocNumber));
                sb.AppendFormat("\"country\":{0},", EscapeJson(mrzInfo.Country));
                sb.AppendFormat("\"documentType\":{0},", EscapeJson(mrzInfo.DocType));
                sb.AppendFormat("\"fullName\":{0},", EscapeJson(mrzInfo.FullName));
                sb.AppendFormat("\"surname\":{0},", EscapeJson(mrzInfo.Surname));
                sb.AppendFormat("\"givenNames\":{0},", EscapeJson(mrzInfo.GivenNames));
                sb.AppendFormat("\"birthDate\":{0},", EscapeJson(mrzInfo.BirthDate));
                sb.AppendFormat("\"expiryDate\":{0},", EscapeJson(mrzInfo.ExpiryDate));
                sb.AppendFormat("\"personalNumber\":{0},", EscapeJson(mrzInfo.PersonalNumber));
                sb.AppendFormat("\"sex\":{0},", EscapeJson(mrzInfo.Sex));
                sb.AppendFormat("\"allChecksPassed\":{0},", mrzInfo.AllChecksPassed ? "true" : "false");
                sb.AppendFormat("\"visBase64\":{0},", EscapeJson(visBase64));
                sb.AppendFormat("\"uvBase64\":{0},", EscapeJson(uvBase64));
                sb.AppendFormat("\"irBase64\":{0},", EscapeJson(irBase64));
                sb.AppendFormat("\"watermarkBase64\":{0},", EscapeJson(watermarkBase64));
                sb.AppendFormat("\"microBase64\":{0},", EscapeJson(microBase64));
                sb.AppendFormat("\"photoBase64\":{0},", EscapeJson(photoBase64));
                sb.AppendFormat("\"coaxVisBase64\":{0}", EscapeJson(coaxVisBase64));
                sb.Append("}");

                return sb.ToString();
            }
            catch
            {
                try { if (rr != null) rr.Disconnect(); } catch { }
                return null;
            }
        }

        private static string ExtractWatermark(string visBase64, string irBase64, string coaxBase64)
        {
            try
            {
                string src = !string.IsNullOrEmpty(coaxBase64) ? coaxBase64 : (!string.IsNullOrEmpty(irBase64) ? irBase64 : visBase64);
                if (string.IsNullOrEmpty(src)) return null;

                using (var ms = new MemoryStream(Convert.FromBase64String(src)))
                using (var bmp = new Bitmap(ms))
                {
                    using (var result = new Bitmap(bmp.Width, bmp.Height, PixelFormat.Format24bppRgb))
                    using (var g = Graphics.FromImage(result))
                    {
                        var cm = new ColorMatrix(new float[][]
                        {
                            new float[] { 1.6f, 0, 0, 0, 0 },
                            new float[] { 0, 1.6f, 0, 0, 0 },
                            new float[] { 0, 0, 1.6f, 0, 0 },
                            new float[] { 0, 0, 0, 1, 0 },
                            new float[] { -0.3f, -0.3f, -0.3f, 0, 1 }
                        });
                        var ia = new ImageAttributes();
                        ia.SetColorMatrix(cm);
                        g.DrawImage(bmp, new Rectangle(0, 0, bmp.Width, bmp.Height), 0, 0, bmp.Width, bmp.Height, GraphicsUnit.Pixel, ia);

                        using (var outMs = new MemoryStream())
                        {
                            result.Save(outMs, ImageFormat.Jpeg);
                            return Convert.ToBase64String(outMs.ToArray());
                        }
                    }
                }
            }
            catch { }
            return null;
        }

        private static string ExtractMicroprint(string visBase64)
        {
            try
            {
                if (string.IsNullOrEmpty(visBase64)) return null;
                using (var ms = new MemoryStream(Convert.FromBase64String(visBase64)))
                using (var bmp = new Bitmap(ms))
                {
                    // Orta alt kısımdaki mikrobaskı bandını 4x büyüt
                    int cw = Math.Max(50, (int)(bmp.Width * 0.35));
                    int ch = Math.Max(30, (int)(bmp.Height * 0.12));
                    int cx = (int)(bmp.Width * 0.45);
                    int cy = (int)(bmp.Height * 0.60);

                    using (var cropped = new Bitmap(cw, ch, PixelFormat.Format24bppRgb))
                    {
                        using (var g = Graphics.FromImage(cropped))
                        {
                            g.DrawImage(bmp, new Rectangle(0, 0, cw, ch), cx, cy, cw, ch, GraphicsUnit.Pixel);
                        }

                        // 4x Büyüt
                        using (var scaled = new Bitmap(cw * 4, ch * 4, PixelFormat.Format24bppRgb))
                        using (var g2 = Graphics.FromImage(scaled))
                        {
                            g2.InterpolationMode = InterpolationMode.HighQualityBicubic;
                            g2.DrawImage(cropped, 0, 0, scaled.Width, scaled.Height);

                            using (var outMs = new MemoryStream())
                            {
                                scaled.Save(outMs, ImageFormat.Jpeg);
                                return Convert.ToBase64String(outMs.ToArray());
                            }
                        }
                    }
                }
            }
            catch { }
            return null;
        }

        private static void EnsureAutoStartInstalled()
        {
            try
            {
                string currentExe = Assembly.GetExecutingAssembly().Location;
                string targetDir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "EgmReaderBridge");
                string targetExe = Path.Combine(targetDir, "EgmReaderBridge.exe");
                string startupDir = Environment.GetFolderPath(Environment.SpecialFolder.Startup);
                string vbsPath = Path.Combine(targetDir, "Kopru_Arka_Planda_Baslat.vbs");
                string startupVbs = Path.Combine(startupDir, "EgmReaderBridge.vbs");

                if (!Directory.Exists(targetDir)) Directory.CreateDirectory(targetDir);

                if (!string.Equals(currentExe, targetExe, StringComparison.OrdinalIgnoreCase))
                {
                    try { File.Copy(currentExe, targetExe, true); } catch { }
                }

                string vbsContent = "Set WshShell = CreateObject(\"WScript.Shell\")\r\nWshShell.Run \"\"\"" + targetExe + "\"\"\", 0, False\r\n";
                File.WriteAllText(vbsPath, vbsContent, Encoding.Default);
                File.WriteAllText(startupVbs, vbsContent, Encoding.Default);
            }
            catch { }
        }

        private static void RegisterProtocolInHkcu()
        {
            try
            {
                string targetDir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "EgmReaderBridge");
                string targetExe = Path.Combine(targetDir, "EgmReaderBridge.exe");
                string exePath = File.Exists(targetExe) ? targetExe : Assembly.GetExecutingAssembly().Location;

                using (var key = Microsoft.Win32.Registry.CurrentUser.CreateSubKey(@"Software\Classes\egm-reader"))
                {
                    if (key != null)
                    {
                        key.SetValue("", "URL:EgmReaderBridge Protocol");
                        key.SetValue("URL Protocol", "");
                        using (var cmdKey = key.CreateSubKey(@"shell\open\command"))
                        {
                            cmdKey?.SetValue("", "\"" + exePath + "\"");
                        }
                    }
                }
            }
            catch { }
        }

        private static string Find3mSdkBinDir()
        {
            string[] possibleBinDirs = new string[]
            {
                @"C:\Program Files (x86)\Thales\Gemalto Document Reader SDK\3.7.1.18\Bin",
                @"C:\Program Files\Thales\Gemalto Document Reader SDK\3.7.1.18\Bin",
                @"C:\Program Files (x86)\3M\3M Page Reader",
                @"C:\Program Files\3M\3M Page Reader"
            };

            foreach (var dir in possibleBinDirs)
            {
                if (Directory.Exists(dir) && File.Exists(Path.Combine(dir, "MMMReaderDotNet40.dll")))
                {
                    return dir;
                }
            }

            string[] baseRoots = new string[]
            {
                @"C:\Program Files (x86)\Thales",
                @"C:\Program Files\Thales",
                @"C:\Program Files (x86)\Gemalto",
                @"C:\Program Files\Gemalto",
                @"C:\Program Files (x86)\3M",
                @"C:\Program Files\3M",
                @"C:\Program Files (x86)\3M Cogent",
                @"C:\Program Files\3M Cogent"
            };

            foreach (var root in baseRoots)
            {
                if (Directory.Exists(root))
                {
                    try
                    {
                        var files = Directory.GetFiles(root, "MMMReaderDotNet40.dll", SearchOption.AllDirectories);
                        if (files.Length > 0)
                        {
                            foreach (var f in files)
                            {
                                var d = Path.GetDirectoryName(f);
                                if (d.IndexOf("Bin", StringComparison.OrdinalIgnoreCase) >= 0) return d;
                            }
                            return Path.GetDirectoryName(files[0]);
                        }
                    }
                    catch { }
                }
            }
            return null;
        }

        private static ImageCodecInfo GetEncoder(ImageFormat format)
        {
            try
            {
                foreach (var codec in ImageCodecInfo.GetImageEncoders())
                {
                    if (codec.FormatID == format.Guid) return codec;
                }
            }
            catch { }
            return null;
        }

        private static string EscapeJson(string s)
        {
            if (s == null) return "null";
            return "\"" + EscapeJsonString(s) + "\"";
        }

        private static string EscapeJsonString(string s)
        {
            if (string.IsNullOrEmpty(s)) return "";
            return s.Replace("\\", "\\\\")
                    .Replace("\"", "\\\"")
                    .Replace("\r", "\\r")
                    .Replace("\n", "\\n")
                    .Replace("\t", "\\t");
        }

        #region MRZ ve ICAO 9303 Ayrıştırma Yardımcıları
        private class BridgeMrzInfo
        {
            public string DocType = "";
            public string DocNumber = "";
            public string Country = "";
            public string FullName = "";
            public string Surname = "";
            public string GivenNames = "";
            public string BirthDate = "";
            public string ExpiryDate = "";
            public string PersonalNumber = "";
            public string Sex = "";
            public bool AllChecksPassed = false;
            public string RawMrz = "";
        }

        private static readonly System.Collections.Generic.Dictionary<string, string> IsoCountryMap = new System.Collections.Generic.Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            { "TUR", "Türkiye" }, { "D", "Almanya" }, { "DEU", "Almanya" }, { "GBR", "İngiltere" }, { "RUS", "Rusya" },
            { "UKR", "Ukrayna" }, { "USA", "Amerika Birleşik Devletleri" }, { "FRA", "Fransa" }, { "NLD", "Hollanda" },
            { "BEL", "Belçika" }, { "AUT", "Avusturya" }, { "CHE", "İsviçre" }, { "SWE", "İsveç" }, { "NOR", "Norveç" },
            { "DNK", "Danimarka" }, { "FIN", "Finlandiya" }, { "POL", "Polonya" }, { "CZE", "Çek Cumhuriyeti" },
            { "ROU", "Romanya" }, { "BGR", "Bulgaristan" }, { "GRC", "Yunanistan" }, { "ITA", "İtalya" }, { "ESP", "İspanya" },
            { "PRT", "Portekiz" }, { "AZE", "Azerbaycan" }, { "KAZ", "Kazakistan" }, { "UZB", "Özbekistan" },
            { "KGZ", "Kırgızistan" }, { "TKM", "Türkmenistan" }, { "TJK", "Tacikistan" }, { "GEO", "Gürcistan" },
            { "ARM", "Ermenistan" }, { "MDA", "Moldovya" }, { "BLR", "Belarus" }, { "IRN", "İran" }, { "IRQ", "Irak" },
            { "SYR", "Suriye" }, { "LBN", "Lübnan" }, { "JOR", "Ürdün" }, { "ISR", "İsrail" }, { "SAU", "Suudi Arabistan" },
            { "ARE", "Birleşik Arap Emirlikleri" }, { "KWT", "Kuveyt" }, { "QAT", "Katar" }, { "BHR", "Bahreyn" },
            { "OMN", "Umman" }, { "EGY", "Mısır" }, { "LBY", "Libya" }, { "TUN", "Tunus" }, { "DZA", "Cezayir" },
            { "MAR", "Fas" }, { "SDN", "Sudan" }, { "SOM", "Somali" }, { "ETH", "Etiyopya" }, { "KEN", "Kenya" },
            { "NGA", "Nijerya" }, { "GHA", "Gana" }, { "ZAF", "Güney Afrika" }, { "IND", "Hindistan" }, { "PAK", "Pakistan" },
            { "BGD", "Bangladeş" }, { "AFG", "Afganistan" }, { "CHN", "Çin" }, { "JPN", "Japonya" }, { "KOR", "Güney Kore" },
            { "IDN", "Endonezya" }, { "MYS", "Malezya" }, { "PHL", "Filipinler" }, { "THA", "Tayland" }, { "VNM", "Vietnam" },
            { "AUS", "Avustralya" }, { "CAN", "Kanada" }, { "BRA", "Brezilya" }, { "ARG", "Arjantin" }, { "MEX", "Meksika" },
            { "COL", "Kolombiya" }, { "SRB", "Sırbistan" }, { "BIH", "Bosna-Hersek" }, { "HRV", "Hırvatistan" },
            { "MKD", "Kuzey Makedonya" }, { "ALB", "Arnavutluk" }, { "MNE", "Karadağ" }, { "KOS", "Kosova" },
            { "HUN", "Macaristan" }, { "SVK", "Slovakya" }, { "SVN", "Slovenya" }, { "IRL", "İrlanda" }, { "CYP", "Kıbrıs" },
            { "MLT", "Malta" }
        };

        private static string MapCountry(string code)
        {
            if (string.IsNullOrEmpty(code)) return "";
            code = code.Replace("<", "").Trim().ToUpperInvariant();
            if (IsoCountryMap.TryGetValue(code, out string name)) return name;
            return code;
        }

        private static readonly int[] MrzWeights = { 7, 3, 1 };

        private static bool ValidateCheckDigit(string value, char expectedCheckDigit)
        {
            if (string.IsNullOrEmpty(value)) return false;
            int sum = 0;
            for (int i = 0; i < value.Length; i++)
            {
                char c = char.ToUpperInvariant(value[i]);
                int val;
                if (c >= '0' && c <= '9') val = c - '0';
                else if (c >= 'A' && c <= 'Z') val = c - 'A' + 10;
                else val = 0;

                sum += val * MrzWeights[i % 3];
            }
            int calc = sum % 10;
            int exp = expectedCheckDigit >= '0' && expectedCheckDigit <= '9' ? expectedCheckDigit - '0' : -1;
            return calc == exp;
        }

        private static string FormatMrzBirthDate(string yymmdd)
        {
            if (string.IsNullOrEmpty(yymmdd) || yymmdd.Length < 6) return yymmdd ?? "";
            if (int.TryParse(yymmdd.Substring(0, 2), out int yy))
            {
                int curYear = DateTime.Now.Year % 100;
                int fullYear = (yy > curYear ? 1900 : 2000) + yy;
                return $"{yymmdd.Substring(4, 2)}.{yymmdd.Substring(2, 2)}.{fullYear}";
            }
            return $"{yymmdd.Substring(4, 2)}.{yymmdd.Substring(2, 2)}.{yymmdd.Substring(0, 2)}";
        }

        private static string FormatMrzExpiryDate(string yymmdd)
        {
            if (string.IsNullOrEmpty(yymmdd) || yymmdd.Length < 6) return yymmdd ?? "";
            if (int.TryParse(yymmdd.Substring(0, 2), out int yy))
            {
                int fullYear = 2000 + yy;
                return $"{yymmdd.Substring(4, 2)}.{yymmdd.Substring(2, 2)}.{fullYear}";
            }
            return $"{yymmdd.Substring(4, 2)}.{yymmdd.Substring(2, 2)}.{yymmdd.Substring(0, 2)}";
        }

        private static BridgeMrzInfo ParseMrzData(string line1, string line2, string line3, string rawMrzText = null, MMM.Readers.CodelineData? cl = null)
        {
            var info = new BridgeMrzInfo();
            try
            {
                // 1. Önce 3M CodelineData objesinden gelen hazır alanlar varsa al
                if (cl.HasValue)
                {
                    var clVal = cl.Value;
                    if (!string.IsNullOrEmpty(clVal.DocNumber)) info.DocNumber = clVal.DocNumber.Replace("<", "").Trim();
                    if (!string.IsNullOrEmpty(clVal.Surname)) info.Surname = clVal.Surname.Replace("<", " ").Trim();
                    if (!string.IsNullOrEmpty(clVal.Forenames)) info.GivenNames = clVal.Forenames.Replace("<", " ").Trim();
                    else if (!string.IsNullOrEmpty(clVal.Forename)) info.GivenNames = clVal.Forename.Replace("<", " ").Trim();
                    if (!string.IsNullOrEmpty(clVal.DocType)) info.DocType = clVal.DocType;
                    if (!string.IsNullOrEmpty(clVal.IssuingState)) info.Country = MapCountry(clVal.IssuingState);
                    else if (!string.IsNullOrEmpty(clVal.Nationality)) info.Country = MapCountry(clVal.Nationality);
                    if (!string.IsNullOrEmpty(clVal.DateOfBirthMRZ)) info.BirthDate = FormatMrzBirthDate(clVal.DateOfBirthMRZ);
                    if (!string.IsNullOrEmpty(clVal.ExpiryDateMRZ)) info.ExpiryDate = FormatMrzExpiryDate(clVal.ExpiryDateMRZ);
                    if (!string.IsNullOrEmpty(clVal.Sex)) info.Sex = (clVal.Sex == "M" ? "Erkek" : (clVal.Sex == "F" ? "Kadın" : clVal.Sex));
                    if (!string.IsNullOrEmpty(clVal.Data)) info.RawMrz = clVal.Data;
                    if (clVal.CodelineValidationResult == MMM.Readers.CheckDigitResult.CDR_Valid)
                    {
                        info.AllChecksPassed = true;
                    }
                }

                // Satırları temizle
                line1 = (line1 ?? "").Trim().Replace("«", "<").Replace("»", "<");
                line2 = (line2 ?? "").Trim().Replace("«", "<").Replace("»", "<");
                line3 = (line3 ?? "").Trim().Replace("«", "<").Replace("»", "<");

                if (string.IsNullOrEmpty(info.RawMrz))
                {
                    if (!string.IsNullOrEmpty(line1))
                    {
                        info.RawMrz = line1 + "\r\n" + line2 + (string.IsNullOrEmpty(line3) ? "" : "\r\n" + line3);
                    }
                    else if (!string.IsNullOrEmpty(rawMrzText))
                    {
                        info.RawMrz = rawMrzText;
                    }
                }

                // Satırları ham metinden çıkar (gerekirse)
                if (string.IsNullOrEmpty(line1) && !string.IsNullOrEmpty(info.RawMrz))
                {
                    var spl = info.RawMrz.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);
                    if (spl.Length > 0) line1 = spl[0].Trim();
                    if (spl.Length > 1) line2 = spl[1].Trim();
                    if (spl.Length > 2) line3 = spl[2].Trim();
                }

                // FORMAT 1: TD1 (3 satır, her biri ~30 karakter - Bulgaristan Kimliği, AB Kimlikleri, TC Kimlik)
                if (!string.IsNullOrEmpty(line3) || (line1.Length >= 28 && line1.Length <= 32 && line2.Length >= 28 && line2.Length <= 32))
                {
                    info.DocType = "Kimlik Kartı";

                    // Satır 1: [0..1] Belge Türü, [2..4] Ülke, [5..13] Belge No, [14] Kontrol Hanesi
                    if (line1.Length >= 15)
                    {
                        if (string.IsNullOrEmpty(info.Country))
                            info.Country = MapCountry(line1.Substring(2, 3));

                        if (string.IsNullOrEmpty(info.DocNumber))
                            info.DocNumber = line1.Substring(5, 9).Replace("<", "").Trim();

                        char docCd = line1[14];
                        bool docValid = ValidateCheckDigit(line1.Substring(5, 9), docCd);

                        // Satır 2: [0..5] Doğum Tarihi, [6] Kontrol, [7] Cinsiyet, [8..13] Son Geçerlilik, [14] Kontrol, [15..17] Uyruk, [18..] Kişisel No
                        bool dobValid = false, expValid = false;
                        if (line2.Length >= 15)
                        {
                            string dobStr = line2.Substring(0, 6);
                            dobValid = ValidateCheckDigit(dobStr, line2[6]);
                            if (string.IsNullOrEmpty(info.BirthDate))
                                info.BirthDate = FormatMrzBirthDate(dobStr);

                            if (string.IsNullOrEmpty(info.Sex) && line2.Length > 7)
                            {
                                char sChar = line2[7];
                                info.Sex = (sChar == 'M' ? "Erkek" : (sChar == 'F' ? "Kadın" : ""));
                            }

                            string expStr = line2.Substring(8, 6);
                            expValid = ValidateCheckDigit(expStr, line2[14]);
                            if (string.IsNullOrEmpty(info.ExpiryDate))
                                info.ExpiryDate = FormatMrzExpiryDate(expStr);

                            if (string.IsNullOrEmpty(info.Country) && line2.Length >= 18)
                                info.Country = MapCountry(line2.Substring(15, 3));

                            if (string.IsNullOrEmpty(info.PersonalNumber) && line2.Length >= 28)
                                info.PersonalNumber = line2.Substring(18, Math.Min(11, line2.Length - 18)).Replace("<", "").Trim();
                        }

                        // Satır 3: Soyad<<Ad
                        if (!string.IsNullOrEmpty(line3))
                        {
                            var parts = line3.Split(new[] { "<<" }, StringSplitOptions.None);
                            if (string.IsNullOrEmpty(info.Surname) && parts.Length > 0)
                                info.Surname = parts[0].Replace("<", " ").Trim();
                            if (string.IsNullOrEmpty(info.GivenNames) && parts.Length > 1)
                                info.GivenNames = parts[1].Replace("<", " ").Trim();
                        }

                        if (!info.AllChecksPassed)
                            info.AllChecksPassed = (docValid && dobValid && expValid);
                    }
                }
                // FORMAT 2: TD3 (2 satır, her biri 44 karakter - Pasaportlar)
                else if (line1.Length >= 40 && line2.Length >= 40)
                {
                    if (line1.StartsWith("PD")) info.DocType = "Diplomatik Pasaport";
                    else if (line1.StartsWith("PS")) info.DocType = "Hizmet Pasaportu";
                    else info.DocType = "Umuma Mahsus Pasaport";

                    if (string.IsNullOrEmpty(info.Country))
                        info.Country = MapCountry(line1.Substring(2, 3));

                    if (line1.Length >= 6)
                    {
                        var namePart = line1.Substring(5);
                        var parts = namePart.Split(new[] { "<<" }, StringSplitOptions.None);
                        if (string.IsNullOrEmpty(info.Surname) && parts.Length > 0)
                            info.Surname = parts[0].Replace("<", " ").Trim();
                        if (string.IsNullOrEmpty(info.GivenNames) && parts.Length > 1)
                            info.GivenNames = parts[1].Replace("<", " ").Trim();
                    }

                    // Satır 2: [0..8] Belge No, [9] Kontrol, [10..12] Uyruk, [13..18] Doğum Tarihi, [19] Kontrol, [20] Cinsiyet, [21..26] Son Geçerlilik, [27] Kontrol
                    if (line2.Length >= 28)
                    {
                        if (string.IsNullOrEmpty(info.DocNumber))
                            info.DocNumber = line2.Substring(0, 9).Replace("<", "").Trim();

                        bool docValid = ValidateCheckDigit(line2.Substring(0, 9), line2[9]);

                        if (string.IsNullOrEmpty(info.Country))
                            info.Country = MapCountry(line2.Substring(10, 3));

                        string dobStr = line2.Substring(13, 6);
                        bool dobValid = ValidateCheckDigit(dobStr, line2[19]);
                        if (string.IsNullOrEmpty(info.BirthDate))
                            info.BirthDate = FormatMrzBirthDate(dobStr);

                        if (string.IsNullOrEmpty(info.Sex) && line2.Length > 20)
                        {
                            char sChar = line2[20];
                            info.Sex = (sChar == 'M' ? "Erkek" : (sChar == 'F' ? "Kadın" : ""));
                        }

                        string expStr = line2.Substring(21, 6);
                        bool expValid = ValidateCheckDigit(expStr, line2[27]);
                        if (string.IsNullOrEmpty(info.ExpiryDate))
                            info.ExpiryDate = FormatMrzExpiryDate(expStr);

                        if (string.IsNullOrEmpty(info.PersonalNumber) && line2.Length >= 42)
                            info.PersonalNumber = line2.Substring(28, 14).Replace("<", "").Trim();

                        if (!info.AllChecksPassed)
                            info.AllChecksPassed = (docValid && dobValid && expValid);
                    }
                }
                // FORMAT 3: TD2 (2 satır, her biri 36 karakter - Vize veya Kimlik)
                else if (line1.Length >= 34 && line2.Length >= 34)
                {
                    info.DocType = line1.StartsWith("V") ? "Vize" : "Kimlik Kartı";
                    if (string.IsNullOrEmpty(info.Country))
                        info.Country = MapCountry(line1.Substring(2, 3));

                    if (line1.Length >= 6)
                    {
                        var namePart = line1.Substring(5);
                        var parts = namePart.Split(new[] { "<<" }, StringSplitOptions.None);
                        if (string.IsNullOrEmpty(info.Surname) && parts.Length > 0)
                            info.Surname = parts[0].Replace("<", " ").Trim();
                        if (string.IsNullOrEmpty(info.GivenNames) && parts.Length > 1)
                            info.GivenNames = parts[1].Replace("<", " ").Trim();
                    }

                    if (line2.Length >= 28)
                    {
                        if (string.IsNullOrEmpty(info.DocNumber))
                            info.DocNumber = line2.Substring(0, 9).Replace("<", "").Trim();

                        bool docValid = ValidateCheckDigit(line2.Substring(0, 9), line2[9]);
                        string dobStr = line2.Substring(13, 6);
                        bool dobValid = ValidateCheckDigit(dobStr, line2[19]);
                        if (string.IsNullOrEmpty(info.BirthDate))
                            info.BirthDate = FormatMrzBirthDate(dobStr);

                        if (string.IsNullOrEmpty(info.Sex) && line2.Length > 20)
                        {
                            char sChar = line2[20];
                            info.Sex = (sChar == 'M' ? "Erkek" : (sChar == 'F' ? "Kadın" : ""));
                        }

                        string expStr = line2.Substring(21, 6);
                        bool expValid = ValidateCheckDigit(expStr, line2[27]);
                        if (string.IsNullOrEmpty(info.ExpiryDate))
                            info.ExpiryDate = FormatMrzExpiryDate(expStr);

                        if (!info.AllChecksPassed)
                            info.AllChecksPassed = (docValid && dobValid && expValid);
                    }
                }

                if (string.IsNullOrEmpty(info.FullName))
                {
                    info.FullName = (info.Surname + " " + info.GivenNames).Trim();
                }
            }
            catch { }

            return info;
        }
        #endregion
    }

    /// <summary>
    /// Active Directory GPO veya SCCM ile kurumsal Windows Hizmeti (Service) olarak çalışabilirlik desteği.
    /// sc.exe create EgmReaderBridge binPath= "..." start= auto
    /// </summary>
    public class EgmBridgeService : ServiceBase
    {
        public EgmBridgeService()
        {
            ServiceName = "EgmReaderBridge";
        }

        protected override void OnStart(string[] args)
        {
            try
            {
                // Background thread üzerinden HTTP Listener ve SDK başlat
                var t = new Thread(() =>
                {
                    Program.StartServiceMode();
                })
                {
                    IsBackground = true
                };
                t.Start();
            }
            catch { }
        }

        protected override void OnStop()
        {
            try
            {
                Program.StopServiceMode();
            }
            catch { }
        }
    }
}
