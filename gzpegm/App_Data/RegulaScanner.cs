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

                    // HIZLI MRZ MODU:
                    // Sadece MRZ OCR aktif, Authenticity (UV/hologram/elyaf kontrolü) KAPALI!
                    // DoReceiveAllScannedImages KAPALI! VisualOCR ve Graphics KAPALI!
                    rr.DoReceiveImages = true;
                    rr.DoReceiveAllScannedImages = false;
                    rr.DoMRZOCR = true;
                    rr.DoVisualOCR = false;
                    rr.DoGraphics = false;
                    rr.DoAuthenticity = false;
                    rr.DoLocateDocument = true;
                    rr.DoDocumentType = true;
                }
                catch { }

                if (args.Length > 0 && args[0] == "--status")
                {
                    try
                    {
                        rr.Connect();
                        bool isConn = false;
                        for (int i = 0; i < 15; i++)
                        {
                            try { isConn = (bool)rr.Connected; } catch { }
                            if (isConn) break;
                            System.Threading.Thread.Sleep(100);
                        }
                        int devCount = 0;
                        try { devCount = (int)rr.AvailableDevicesCount; } catch { }
                        try { rr.Disconnect(); } catch { }
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

                // Donanımın USB el sıkışması ve hazır hale gelmesi için maksimum 1.5 saniye bekle
                bool connected = false;
                for (int i = 0; i < 15; i++)
                {
                    try { connected = (bool)rr.Connected; } catch { }
                    if (connected) break;
                    System.Threading.Thread.Sleep(100);
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

                // Donanımın taramaya başlaması için kısa pay ver ve eşzamanlı MRZ kontrolü yap
                System.Threading.Thread.Sleep(120);

                string line1 = null;
                string line2 = null;
                string line3 = null;

                // İşlemin tamamlanmasını bekle (maksimum 4.5 saniye)
                int waited = 120;
                while (waited < 4500)
                {
                    try
                    {
                        string quickMrz = (string)rr.GetMRZLines();
                        if (!string.IsNullOrEmpty(quickMrz))
                        {
                            var lines = quickMrz.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);
                            if (lines.Length >= 2)
                            {
                                line1 = lines[0].Trim();
                                line2 = lines[1].Trim();
                                if (lines.Length >= 3) line3 = lines[2].Trim();
                                break;
                            }
                        }
                    }
                    catch { }

                    bool isBusy = false;
                    try { isBusy = (bool)rr.IsBusy; } catch { }
                    if (!isBusy)
                    {
                        System.Threading.Thread.Sleep(60);
                        try { isBusy = (bool)rr.IsBusy; } catch { }
                        if (!isBusy) break; // Tarama kesinlikle tamamlandı
                    }

                    System.Threading.Thread.Sleep(60);
                    waited += 120;
                }

                // 1. Görselleri Çek: Sadece VIS (Beyaz Işık - Önizleme)
                string visBase64 = null;
                string uvBase64 = null;
                string irBase64 = null;
                string coaxVisBase64 = null;

                try
                {
                    object raw = rr.GetReaderFileImageByLightIndex(6);
                    byte[] bArr = raw as byte[];
                    if (bArr != null && bArr.Length > 0)
                    {
                        visBase64 = Convert.ToBase64String(bArr);
                    }
                    else
                    {
                        int fileImgCount = 0;
                        try { fileImgCount = (int)rr.IsReaderResultTypeAvailable(2); } catch { }
                        for (int i = 0; i < fileImgCount; i++)
                        {
                            int light = 0;
                            try { light = (int)rr.CheckReaderImageLight(i); } catch { }
                            if (light == 6 || (light & 0x06) != 0)
                            {
                                object r2 = rr.GetReaderFileImage(i);
                                byte[] b2 = r2 as byte[];
                                if (b2 != null && b2.Length > 0)
                                {
                                    visBase64 = Convert.ToBase64String(b2);
                                    break;
                                }
                            }
                        }
                    }
                }
                catch { }

                // 2. Doğrudan Işık İndeksine göre (6=VIS, 128=UV, 24=IR)
                if (string.IsNullOrEmpty(visBase64))
                {
                    try
                    {
                        object raw = rr.GetReaderFileImageByLightIndex(6);
                        byte[] bArr = raw as byte[];
                        if (bArr != null && bArr.Length > 0) visBase64 = Convert.ToBase64String(bArr);
                    }
                    catch { }
                }
                if (string.IsNullOrEmpty(uvBase64))
                {
                    try
                    {
                        object raw = rr.GetReaderFileImageByLightIndex(128);
                        byte[] bArr = raw as byte[];
                        if (bArr != null && bArr.Length > 0) uvBase64 = Convert.ToBase64String(bArr);
                    }
                    catch { }
                }
                if (string.IsNullOrEmpty(irBase64))
                {
                    try
                    {
                        object raw = rr.GetReaderFileImageByLightIndex(24);
                        byte[] bArr = raw as byte[];
                        if (bArr != null && bArr.Length > 0) irBase64 = Convert.ToBase64String(bArr);
                    }
                    catch { }
                }

                // 3. Fallback: Bitmap / RawImage
                if (string.IsNullOrEmpty(visBase64))
                {
                    try
                    {
                        object raw = rr.GetReaderBitmapImageByLightIndex(6);
                        byte[] bArr = raw as byte[];
                        if (bArr != null && bArr.Length > 0) visBase64 = Convert.ToBase64String(bArr);
                    }
                    catch { }
                }

                // 4. Fallback: Regula Scans Klasörleri (Disk Fallback)
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

                // 5. Portre Fotoğrafını Çek (Field 201 = RGT_Portrait)
                string photoBase64 = null;
                try
                {
                    object pData = rr.GetReaderGraphicsFileImageByFieldType(201);
                    byte[] pb = pData as byte[];
                    if (pb != null && pb.Length > 0) photoBase64 = Convert.ToBase64String(pb);
                }
                catch { }

                if (string.IsNullOrEmpty(photoBase64))
                {
                    try
                    {
                        object portraitBytes = rr.GetReaderGraphicsBitmapByFieldType(201);
                        byte[] pb = portraitBytes as byte[];
                        if (pb != null && pb.Length > 0) photoBase64 = Convert.ToBase64String(pb);
                    }
                    catch { }
                }

                // 6. Metin ve MRZ Satırlarını Çek
                line1 = line1 ?? "";
                line2 = line2 ?? "";
                line3 = line3 ?? "";
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
                        else
                        {
                            var matches = System.Text.RegularExpressions.Regex.Matches(mrzText, @"[A-Z0-9<]{28,44}");
                            if (matches.Count >= 2)
                            {
                                line1 = matches[0].Value;
                                line2 = matches[1].Value;
                                if (matches.Count >= 3) line3 = matches[2].Value;
                            }
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

                // 7. Regula Dahili Adli Güvenlik Sonuçlarını Çek
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

                if (string.IsNullOrEmpty(visBase64) && string.IsNullOrEmpty(line1))
                {
                    Console.WriteLine("{\"success\":false,\"message\":\"Regula optik okuyucu camında belge algılanamadı. Lütfen pasaport veya kimlik kartını camın üzerine tam yerleştiriniz.\"}");
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
