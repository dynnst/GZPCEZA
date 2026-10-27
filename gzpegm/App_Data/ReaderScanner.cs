using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Reflection;
using System.Text;

namespace Sahtecilik.ReaderScanner
{
    class Program
    {
        static string[] possibleBinDirs = new string[]
        {
            @"C:\Program Files (x86)\Thales\Gemalto Document Reader SDK\3.7.1.18\Bin",
            @"C:\Program Files\Thales\Gemalto Document Reader SDK\3.7.1.18\Bin",
            @"C:\Program Files (x86)\3M\3M Page Reader",
            @"C:\Program Files\3M\3M Page Reader"
        };

        static string resolvedBinDir = null;

        [STAThread]
        static void Main(string[] args)
        {
            Console.OutputEncoding = Encoding.UTF8;

            foreach (var dir in possibleBinDirs)
            {
                if (Directory.Exists(dir) && File.Exists(Path.Combine(dir, "MMMReaderDotNet40.dll")))
                {
                    resolvedBinDir = dir;
                    break;
                }
            }

            if (resolvedBinDir == null)
            {
                Console.WriteLine("{\"success\":false,\"message\":\"3M / Gemalto Reader SDK kütüphaneleri bulunamadı.\"}");
                return;
            }

            AppDomain.CurrentDomain.AssemblyResolve += (sender, eventArgs) =>
            {
                var assemblyName = new AssemblyName(eventArgs.Name).Name;
                var targetPath = Path.Combine(resolvedBinDir, assemblyName + ".dll");
                if (File.Exists(targetPath))
                {
                    return Assembly.LoadFrom(targetPath);
                }
                return null;
            };

            Execute(args);
        }

        static void Execute(string[] args)
        {
            try
            {
                MMM.Readers.FullPage.Reader.EnableLogging(false, 0, 0, "ReaderScanner.log");

                var initRes = MMM.Readers.FullPage.Reader.Initialise(null, null, null, null, false, false);
                if (initRes != MMM.Readers.ErrorCode.NO_ERROR_OCCURRED)
                {
                    Console.WriteLine("{{\"success\":false,\"message\":\"Okuyucu başlatılamadı. Hata: {0}\"}}", initRes);
                    return;
                }

                if (!MMM.Readers.FullPage.Reader.IsInitialised())
                {
                    Console.WriteLine("{\"success\":false,\"message\":\"Okuyucu donanımı bağlı değil veya başka bir uygulama tarafından meşgul.\"}");
                    return;
                }

                if (args.Length > 0 && args[0] == "--status")
                {
                    bool isDoc = MMM.Readers.FullPage.Reader.IsDocumentOnWindow();
                    MMM.Readers.FullPage.Reader.Shutdown();
                    Console.WriteLine("{{\"success\":true,\"isInitialised\":true,\"isDocumentOnWindow\":{0}}}", isDoc ? "true" : "false");
                    return;
                }

                var readRes = MMM.Readers.FullPage.Reader.ReadDocument();
                if (readRes != MMM.Readers.ErrorCode.NO_ERROR_OCCURRED)
                {
                    MMM.Readers.FullPage.Reader.Shutdown();
                    Console.WriteLine("{{\"success\":false,\"message\":\"Belge okunamadı. Lütfen pasaportu veya kimliği okuyucu camına tam yerleştiriniz. ({0})\"}}", readRes);
                    return;
                }

                string visBase64 = GetImageBase64(MMM.Readers.FullPage.DataType.CD_IMAGEVIS);
                string uvBase64 = GetImageBase64(MMM.Readers.FullPage.DataType.CD_IMAGEUV);
                string irBase64 = GetImageBase64(MMM.Readers.FullPage.DataType.CD_IMAGEIR);
                string photoBase64 = GetImageBase64(MMM.Readers.FullPage.DataType.CD_IMAGEPHOTO);
                string coaxVisBase64 = GetImageBase64(MMM.Readers.FullPage.DataType.CD_IMAGECOAXVIS);

                string docType = "";
                string line1 = "";
                string line2 = "";
                string line3 = "";

                object codelineObj = null;
                if (MMM.Readers.FullPage.Reader.GetData(MMM.Readers.FullPage.DataType.CD_CODELINE_DATA, ref codelineObj) == MMM.Readers.ErrorCode.NO_ERROR_OCCURRED && codelineObj != null)
                {
                    try
                    {
                        var cl = (MMM.Readers.CodelineData)codelineObj;
                        docType = cl.DocType ?? "";
                        line1 = cl.Line1 ?? "";
                        line2 = cl.Line2 ?? "";
                        line3 = cl.Line3 ?? "";
                    }
                    catch { }
                }

                MMM.Readers.FullPage.Reader.Shutdown();

                var sb = new StringBuilder();
                sb.Append("{");
                sb.Append("\"success\":true,");
                sb.AppendFormat("\"docType\":{0},", EscapeJson(docType));
                sb.AppendFormat("\"line1\":{0},", EscapeJson(line1));
                sb.AppendFormat("\"line2\":{0},", EscapeJson(line2));
                sb.AppendFormat("\"line3\":{0},", EscapeJson(line3));
                sb.AppendFormat("\"visBase64\":{0},", EscapeJson(visBase64));
                sb.AppendFormat("\"uvBase64\":{0},", EscapeJson(uvBase64));
                sb.AppendFormat("\"irBase64\":{0},", EscapeJson(irBase64));
                sb.AppendFormat("\"photoBase64\":{0},", EscapeJson(photoBase64));
                sb.AppendFormat("\"coaxVisBase64\":{0}", EscapeJson(coaxVisBase64));
                sb.Append("}");

                Console.WriteLine(sb.ToString());
            }
            catch (Exception ex)
            {
                try { MMM.Readers.FullPage.Reader.Shutdown(); } catch { }
                Console.WriteLine("{{\"success\":false,\"message\":\"Hata: {0}\",\"stack\":\"{1}\"}}", EscapeJsonString(ex.Message), EscapeJsonString(ex.ToString()));
            }
        }

        static string GetImageBase64(MMM.Readers.FullPage.DataType dt)
        {
            try
            {
                object data = null;
                var res = MMM.Readers.FullPage.Reader.GetData(dt, ref data);
                Bitmap bmp = data as Bitmap;
                if (res == MMM.Readers.ErrorCode.NO_ERROR_OCCURRED && bmp != null)
                {
                    using (var ms = new MemoryStream())
                    {
                        // Save as JPEG with 88 quality
                        var encoder = GetEncoder(ImageFormat.Jpeg);
                        var encParams = new EncoderParameters(1);
                        encParams.Param[0] = new EncoderParameter(System.Drawing.Imaging.Encoder.Quality, 88L);
                        bmp.Save(ms, encoder, encParams);
                        return Convert.ToBase64String(ms.ToArray());
                    }
                }
            }
            catch { }
            return "";
        }

        static ImageCodecInfo GetEncoder(ImageFormat format)
        {
            ImageCodecInfo[] codecs = ImageCodecInfo.GetImageDecoders();
            foreach (ImageCodecInfo codec in codecs)
            {
                if (codec.FormatID == format.Guid)
                {
                    return codec;
                }
            }
            return null;
        }

        static string EscapeJson(string s)
        {
            if (s == null) return "null";
            return "\"" + EscapeJsonString(s) + "\"";
        }

        static string EscapeJsonString(string s)
        {
            if (string.IsNullOrEmpty(s)) return "";
            return s.Replace("\\", "\\\\")
                    .Replace("\"", "\\\"")
                    .Replace("\r", "\\r")
                    .Replace("\n", "\\n")
                    .Replace("\t", "\\t");
        }
    }
}
