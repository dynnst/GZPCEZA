using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Xml;

namespace Sahtecilik.RegulaScanner
{
    class Program
    {
        static void KillZombieReaderDemo()
        {
            try
            {
                var procs = Process.GetProcessesByName("READERDEMO");
                foreach (var p in procs)
                {
                    try { p.Kill(); p.WaitForExit(1000); } catch { }
                }
            }
            catch { }
        }

        [STAThread]
        static void Main(string[] args)
        {
            Console.OutputEncoding = Encoding.UTF8;

            dynamic rr = null;

            try
            {
                // 1. Önceki oturumlardan arka planda takılı kalmış zombie READERDEMO süreçlerini temizle
                KillZombieReaderDemo();

                Type comType = Type.GetTypeFromProgID("READERDEMO.RegulaReader");
                if (comType == null)
                {
                    try
                    {
                        comType = Type.GetTypeFromCLSID(new Guid("F4E2014F-3E2A-4FCF-BA56-EB86B73F30FB"));
                    }
                    catch { }
                }

                if (comType == null)
                {
                    Console.WriteLine("{\"success\":false,\"message\":\"Regula Document Reader SDK COM bileşeni (READERDEMO.RegulaReader) bu bilgisayarda bulunamadı.\"}");
                    return;
                }

                // COM nesnesini başlat (hata durumunda temizleyip 1 kez daha dene)
                for (int attempt = 0; attempt < 2; attempt++)
                {
                    try
                    {
                        rr = Activator.CreateInstance(comType);
                        if (rr != null) break;
                    }
                    catch (Exception ex)
                    {
                        KillZombieReaderDemo();
                        if (attempt == 1)
                        {
                            Console.WriteLine(string.Format("{{\"success\":false,\"message\":\"Regula okuyucu nesnesi başlatılamadı: {0}\"}}", EscapeJson(ex.Message)));
                            return;
                        }
                        System.Threading.Thread.Sleep(600);
                    }
                }

                if (rr == null)
                {
                    Console.WriteLine("{\"success\":false,\"message\":\"Regula okuyucu nesnesi başlatılamadı.\"}");
                    return;
                }

                // Arka plan / sessiz çalışma ayarları (Connect çağrılmadan önce mutlaka ayarlanmalı)
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
                }
                catch { }

                if (args.Length > 0 && args[0] == "--status")
                {
                    try
                    {
                        rr.Connect();
                        bool isConn = (bool)rr.Connected;
                        int devCount = (int)rr.AvailableDevicesCount;
                        rr.Disconnect();
                        Console.WriteLine(string.Format("{{\"success\":true,\"isInitialised\":{0},\"availableDevices\":{1}}}", isConn ? "true" : "false", devCount));
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine(string.Format("{{\"success\":false,\"message\":\"Regula durum kontrol hatası: {0}\"}}", EscapeJson(ex.Message)));
                    }
                    return;
                }

                // --scan veya varsayılan tarama modu
                try
                {
                    rr.Connect();
                }
                catch { }

                // Donanımın USB el sıkışması ve hazır hale gelmesi için 8 saniyeye kadar bekle
                bool connected = false;
                for (int i = 0; i < 40; i++)
                {
                    try { connected = (bool)rr.Connected; } catch { }
                    if (connected) break;
                    System.Threading.Thread.Sleep(200);
                }

                if (!connected)
                {
                    Console.WriteLine("{\"success\":false,\"message\":\"Regula Document Reader cihazına bağlanılamadı. Lütfen cihazın USB kablosunu ve gücünü kontrol ediniz.\"}");
                    return;
                }

                // Tarama tetikle
                try
                {
                    rr.GetImages();
                }
                catch
                {
                    try { rr.Process(); } catch { }
                }

                // MRZ hazır olur olmaz devam et; gerçek süreyi ölç ve form verisini önceliklendir.
                var regulaScanClock = System.Diagnostics.Stopwatch.StartNew();
                int idlePolls = 0;
                while (regulaScanClock.ElapsedMilliseconds < 3000)
                {
                    try
                    {
                        string mrzProbe = (string)rr.GetMRZLines();
                        if (!string.IsNullOrWhiteSpace(mrzProbe))
                        {
                            var probeLines = mrzProbe.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);
                            if (probeLines.Length >= 2 || mrzProbe.Length >= 70) break;
                        }
                    }
                    catch { }

                    bool isBusy = true;
                    try { isBusy = (bool)rr.IsBusy; } catch { }
                    if (!isBusy)
                    {
                        if (++idlePolls >= 2) break;
                    }
                    else
                    {
                        idlePolls = 0;
                    }
                    System.Threading.Thread.Sleep(100);
                }

                // 1. Görselleri Çek (Önce rr.ImagesCount ve rr.Image(i) standart COM metodu)
                string visBase64 = null;
                string uvBase64 = null;
                string irBase64 = null;
                string coaxVisBase64 = null;

                try
                {
                    int imgCount = 0;
                    try { imgCount = (int)rr.ImagesCount; } catch { }
                    for (int i = 0; i < imgCount; i++)
                    {
                        try
                        {
                            int light = 0;
                            try { light = (int)rr.ImageLight(i); } catch { }
                            int page = 0;
                            try { page = (int)rr.ImagePage(i); } catch { }
                            if (page != 0) continue;

                            string b64 = null;
                            try
                            {
                                object raw = rr.Image(i);
                                if (raw is byte[] bArr && bArr.Length > 0)
                                {
                                    b64 = Convert.ToBase64String(bArr);
                                }
                            }
                            catch { }

                            if (!string.IsNullOrEmpty(b64))
                            {
                                // White / VIS: 6, 2, 4 veya bitmask 0x06
                                if ((light == 6 || (light & 0x06) != 0 || (light & 0x802000) != 0) && visBase64 == null)
                                    visBase64 = b64;
                                // UV: 128 veya bitmask 0x80
                                else if ((light == 128 || (light & 0x80) != 0) && uvBase64 == null)
                                    uvBase64 = b64;
                                // IR: 24, 8, 16 veya bitmask 0x18
                                else if ((light == 24 || (light & 0x18) != 0 || (light & 0x1001040) != 0) && irBase64 == null)
                                    irBase64 = b64;
                                // Coaxial: 8 veya bitmask 0x0C00
                                else if ((light == 8 || (light & 0x0C00) != 0) && coaxVisBase64 == null)
                                    coaxVisBase64 = b64;
                                else if (visBase64 == null)
                                    visBase64 = b64;
                            }
                        }
                        catch { }
                    }
                }
                catch { }

                // 2. Fallback: GetReaderFileImage ve CheckReaderImageLight
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
                                    if (((light & 0x06) != 0 || (light & 0x802000) != 0) && visBase64 == null)
                                        visBase64 = b64;
                                    else if ((light & 0x80) != 0 && uvBase64 == null)
                                        uvBase64 = b64;
                                    else if (((light & 0x18) != 0 || (light & 0x1001040) != 0) && irBase64 == null)
                                        irBase64 = b64;
                                    else if ((light & 0x0C00) != 0 && coaxVisBase64 == null)
                                        coaxVisBase64 = b64;
                                    else if (visBase64 == null)
                                        visBase64 = b64;
                                }
                            }
                            catch { }
                        }
                    }
                    catch { }
                }

                // 3. Fallback: Regula Scans Klasörleri (Disk Fallback)
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
                                    if ((name.Contains("vis") || name.Contains("white") || name.Contains("color")) && visBase64 == null)
                                        visBase64 = Convert.ToBase64String(File.ReadAllBytes(f.FullName));
                                    else if (name.Contains("uv") && uvBase64 == null)
                                        uvBase64 = Convert.ToBase64String(File.ReadAllBytes(f.FullName));
                                    else if (name.Contains("ir") && irBase64 == null)
                                        irBase64 = Convert.ToBase64String(File.ReadAllBytes(f.FullName));
                                }
                                if (!string.IsNullOrEmpty(visBase64)) break;
                            }
                        }
                    }
                    catch { }
                }

                // 4. Portre Fotoğrafını Çek
                string photoBase64 = null;
                try
                {
                    object pData = rr.Photo;
                    if (pData is byte[] pb && pb.Length > 0) photoBase64 = Convert.ToBase64String(pb);
                }
                catch { }

                if (string.IsNullOrEmpty(photoBase64))
                {
                    try
                    {
                        byte[] portraitBytes = (byte[])rr.GetReaderGraphicsBitmapByFieldType(201);
                        if (portraitBytes != null && portraitBytes.Length > 0)
                        {
                            photoBase64 = Convert.ToBase64String(portraitBytes);
                        }
                    }
                    catch { }
                }

                // 3. Metin ve MRZ Satırlarını Çek
                string line1 = "";
                string line2 = "";
                string line3 = "";
                string docType = "Umuma Mahsus Pasaport";

                // Önce doğrudan GetMRZLines çağrısını dene
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

                // MRZ bulunamadıysa XML sonuçlarını kontrol et (OCRLexicalAnalyze = 15 veya MRZ_OCR = 3)
                if (string.IsNullOrEmpty(line1))
                {
                    try
                    {
                        int totalLex = (int)rr.IsReaderResultTypeAvailable(15);
                        if (totalLex > 0)
                        {
                            string xml = (string)rr.CheckReaderResultXML(15, 0, 0);
                            if (!string.IsNullOrEmpty(xml))
                            {
                                XmlDocument doc = new XmlDocument();
                                doc.LoadXml(xml);
                                var mrzNodes = doc.GetElementsByTagName("Field_MRZ");
                                var mrzLines = new List<string>();
                                foreach (XmlNode n in mrzNodes)
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

                        if (string.IsNullOrEmpty(line1))
                        {
                            int totalMrz = (int)rr.IsReaderResultTypeAvailable(3);
                            if (totalMrz > 0)
                            {
                                string xml3 = (string)rr.CheckReaderResultXML(3, 0, 0);
                                if (!string.IsNullOrEmpty(xml3))
                                {
                                    XmlDocument doc3 = new XmlDocument();
                                    doc3.LoadXml(xml3);
                                    var strNodes = doc3.GetElementsByTagName("String");
                                    var list3 = new List<string>();
                                    foreach (XmlNode sn in strNodes)
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
                    }
                    catch { }
                }

                                // 4. Regula Dahili Adli Güvenlik Sonuçlarını Çek
                int secStatus = -1;
                int mrzStatus = -1;
                int optStatus = -1;
                int txtStatus = -1;
                string authRaw = null;

                try { secStatus = (int)rr.CheckStatusSecurity; } catch { }
                try { mrzStatus = (int)rr.CheckStatusMRZ; } catch { }
                try { optStatus = (int)rr.CheckStatusOptical; } catch { }
                try { txtStatus = (int)rr.CheckStatusTextComparison; } catch { }

                try
                {
                    int totalAuth = (int)rr.IsReaderResultTypeAvailable(5); // RPRM_ResultType_Authenticity = 5
                    if (totalAuth > 0)
                    {
                        try { authRaw = (string)rr.CheckReaderResultJSON(5, 0, 0); } catch { }
                        if (string.IsNullOrEmpty(authRaw))
                        {
                            try { authRaw = (string)rr.CheckReaderResultXML(5, 0, 0); } catch { }
                        }
                    }
                }
                catch { }

                // Form aktarımı için MRZ gerekir; görüntü aktarımı tek başına başarı değildir.
                if (string.IsNullOrWhiteSpace(line1))
                {
                    Console.WriteLine("{\"success\":false,\"message\":\"Regula taradı ancak MRZ bilgilerini okuyamadı. Belgeyi düz yerleştirip yeniden deneyiniz.\"}");
                    return;
                }

                var sb = new StringBuilder();
                sb.Append("{");
                sb.Append("\"success\":true,");
                sb.Append("\"visBase64\":\"" + (visBase64 ?? "") + "\",");
                sb.Append("\"uvBase64\":\"" + (uvBase64 ?? "") + "\",");
                sb.Append("\"irBase64\":\"" + (irBase64 ?? "") + "\",");
                sb.Append("\"photoBase64\":\"" + (photoBase64 ?? "") + "\",");
                sb.Append("\"coaxVisBase64\":\"" + (coaxVisBase64 ?? "") + "\",");
                sb.Append("\"line1\":\"" + EscapeJson(line1) + "\",");
                sb.Append("\"line2\":\"" + EscapeJson(line2) + "\",");
                sb.Append("\"line3\":\"" + EscapeJson(line3) + "\",");
                                sb.Append("\"docType\":\"" + EscapeJson(docType) + "\",");
                sb.Append("\"regulaSecurityStatus\":" + secStatus + ",");
                sb.Append("\"regulaMrzStatus\":" + mrzStatus + ",");
                sb.Append("\"regulaOpticalStatus\":" + optStatus + ",");
                sb.Append("\"regulaTextStatus\":" + txtStatus + ",");
                sb.Append("\"regulaAuthenticityRaw\":\"" + EscapeJson(authRaw ?? "") + "\"");
                sb.Append("}");

                Console.WriteLine(sb.ToString());
            }
            catch (Exception ex)
            {
                Console.WriteLine(string.Format("{{\"success\":false,\"message\":\"Regula tarama hatası: {0}\"}}", EscapeJson(ex.Message)));
            }
            finally
            {
                try
                {
                    if (rr != null)
                    {
                        try { rr.Disconnect(); } catch { }
                        Marshal.FinalReleaseComObject(rr);
                        rr = null;
                    }
                }
                catch { }
            }
        }

        static string EscapeJson(string s)
        {
            if (string.IsNullOrEmpty(s)) return "";
            return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "").Replace("\n", "\\n");
        }
    }
}
