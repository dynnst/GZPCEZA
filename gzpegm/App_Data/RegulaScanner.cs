using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
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

                bool connected = false;
                try { connected = (bool)rr.Connected; } catch { }

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
                catch (Exception ex)
                {
                    try { rr.Disconnect(); } catch { }
                    Console.WriteLine(string.Format("{{\"success\":false,\"message\":\"Regula tarama komutu verilemedi: {0}\"}}", EscapeJson(ex.Message)));
                    return;
                }

                // İşlemin tamamlanmasını bekle (maksimum 12 saniye)
                int waited = 0;
                while (waited < 12000)
                {
                    bool isBusy = false;
                    try { isBusy = (bool)rr.IsBusy; } catch { }
                    if (!isBusy) break;

                    System.Threading.Thread.Sleep(100);
                    waited += 100;
                }

                // 1. Görselleri Çek (Raw Image)
                string visBase64 = null;
                string uvBase64 = null;
                string irBase64 = null;
                string coaxVisBase64 = null;

                try
                {
                    int totalImages = (int)rr.IsReaderResultTypeAvailable(1); // RPRM_ResultType_RawImage = 1
                    for (int i = 0; i < totalImages; i++)
                    {
                        byte[] imgBytes = (byte[])rr.GetReaderFileImage(i);
                        int light = (int)rr.CheckReaderImageLight(i);

                        if (imgBytes != null && imgBytes.Length > 0)
                        {
                            string b64 = Convert.ToBase64String(imgBytes);

                            // White / VIS: Top=2, Side=4, Full=6, Front=0x800000, Bottom=0x2000
                            if ((light & 0x06) != 0 || (light & 0x802000) != 0)
                            {
                                if (visBase64 == null) visBase64 = b64;
                            }
                            // UV: 0x80 (128)
                            else if ((light & 0x80) != 0)
                            {
                                if (uvBase64 == null) uvBase64 = b64;
                            }
                            // IR: Top=8, Side=16, Full=24, Front=0x1000000, Bottom=0x1000, Transmitted_IR=0x40
                            else if ((light & 0x18) != 0 || (light & 0x1001040) != 0)
                            {
                                if (irBase64 == null) irBase64 = b64;
                            }
                            // Axial / Coaxial White: 0x400, 0x800, 0xC00
                            else if ((light & 0x0C00) != 0)
                            {
                                if (coaxVisBase64 == null) coaxVisBase64 = b64;
                            }
                            else if (visBase64 == null)
                            {
                                visBase64 = b64;
                            }
                        }
                    }
                }
                catch { }

                // 2. Portre Fotoğrafını Çek (Graphics Result Type = 6, gf_Portrait = 201)
                string photoBase64 = null;
                try
                {
                    int totalGraphics = (int)rr.IsReaderResultTypeAvailable(6);
                    if (totalGraphics > 0)
                    {
                        byte[] portraitBytes = (byte[])rr.GetReaderGraphicsBitmapByFieldType(201);
                        if (portraitBytes != null && portraitBytes.Length > 0)
                        {
                            photoBase64 = Convert.ToBase64String(portraitBytes);
                        }
                    }
                }
                catch { }

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

                if (string.IsNullOrEmpty(visBase64) && string.IsNullOrEmpty(line1))
                {
                    Console.WriteLine("{\"success\":false,\"message\":\"Regula optik okuyucu camında belge algılanamadı. Lütfen pasaportu camın üzerine tam yerleştiriniz.\"}");
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

                // Arka planda kilitli kalmaması için READERDEMO sürecini temizle
                KillZombieReaderDemo();
            }
        }

        static string EscapeJson(string s)
        {
            if (string.IsNullOrEmpty(s)) return "";
            return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "").Replace("\n", "\\n");
        }
    }
}
