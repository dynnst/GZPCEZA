using gzpegm.Helpers;
using gzpegm.Models;
using gzpegm.Models.ViewModels;
using HtmlAgilityPack;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Entity;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;

namespace gzpegm.Services
{
    public sealed class PradoCourseImportService
    {
        private static readonly HashSet<string> AllowedExtensions = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        { ".html", ".htm", ".jpg", ".jpeg", ".png", ".gif", ".webp" };

        private static readonly Dictionary<string, string> Terms = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            ["Document"]="Belge", ["Title"]="Belge adı", ["Issuing Country"]="Düzenleyen ülke",
            ["Document Category"]="Belge kategorisi", ["Document type"]="Belge türü",
            ["Document version number"]="Belge sürüm numarası", ["First issued on"]="İlk düzenlenme tarihi",
            ["Valid"]="Geçerli", ["Legal status / main purpose"]="Hukuki durum / temel amaç",
            ["Overall construction"]="Genel yapı", ["Format width (mm)"]="Genişlik (mm)",
            ["Format height (mm)"]="Yükseklik (mm)", ["Number of pages"]="Sayfa sayısı",
            ["Validity"]="Geçerlilik", ["Validity qualifier"]="Geçerlilik niteliği",
            ["Maximum validity"]="Azami geçerlilik", ["Minimum age for validity"]="Asgari yaş",
            ["Maximum age for validity"]="Azami yaş", ["Validity period"]="Geçerlilik süresi",
            ["Extension is possible"]="Uzatma mümkün mü", ["Total prolongation period"]="Toplam uzatma süresi",
            ["Extension period"]="Uzatma süresi", ["Validity-additional information"]="Geçerliliğe ilişkin ek bilgi",
            ["Cover"]="Kapak", ["Inside front cover"]="Ön kapağın iç yüzü", ["Inside back cover"]="Arka kapağın iç yüzü",
            ["Integrated biodata card - recto (identity)"]="Entegre kimlik kartı - ön yüz",
            ["Integrated card - verso"]="Entegre kart - arka yüz", ["Inner page(s)"]="İç sayfalar",
            ["Construction"]="Yapı", ["Cover embossing"]="Kapak kabartması", ["Material"]="Malzeme",
            ["Overall colour"]="Genel renk", ["Security features"]="Güvenlik özellikleri", ["Light"]="Işık",
            ["UV feature"]="UV özelliği", ["Additional safeguard"]="Ek güvenlik unsuru",
            ["Substrate"]="Alt tabaka", ["Watermark"]="Filigran", ["Watermark position"]="Filigran konumu",
            ["Colours"]="Renkler", ["Photo type"]="Fotoğraf türü", ["Facial image"]="Yüz görüntüsü",
            ["Integration of electronic data"]="Elektronik veri entegrasyonu", ["OVD (optically variable device)"]="OVD (optik değişken cihaz)"
            , ["Başlık"]="Belge adı", ["İhraç Eden Ülke"]="Düzenleyen ülke", ["Belge Kategorisi"]="Belge kategorisi",
            ["Belge türü"]="Belge türü", ["Belge sürüm numarası"]="Belge sürüm numarası",
            ["İlk yayınlanma tarihi"]="İlk düzenlenme tarihi", ["Geçerli"]="Geçerli",
            ["Yasal statü / ana amaç"]="Hukuki durum / temel amaç", ["Genel yapı"]="Genel yapı",
            ["Biçim genişliği (mm)"]="Genişlik (mm)", ["Biçim yüksekliği (mm)"]="Yükseklik (mm)",
            ["Sayfa sayısı"]="Sayfa sayısı", ["Geçerlilik"]="Geçerlilik", ["Maksimum geçerlilik"]="Azami geçerlilik",
            ["Geçerlilik için asgari yaş"]="Asgari yaş", ["Geçerlilik için azami yaş"]="Azami yaş",
            ["Geçerlilik süresi"]="Geçerlilik süresi", ["Uzatma mümkündür"]="Uzatma mümkün mü",
            ["Güvenlik özellikleri"]="Güvenlik özellikleri", ["Işık"]="Işık", ["UV özelliği"]="UV özelliği",
            ["Ek güvenlik önlemi"]="Ek güvenlik unsuru", ["Alt tabaka"]="Alt tabaka", ["Filigran"]="Filigran",
            ["Renkler"]="Renkler", ["Fotoğraf türü"]="Fotoğraf türü"
        };

        private readonly GZPEGM1 db;
        private readonly HttpServerUtilityBase server;
        public long MaximumZipBytes => ReadLimit("PradoImportMaxBytes", 100L * 1024 * 1024);
        private long MaximumExtractedBytes => ReadLimit("PradoImportMaxExtractedBytes", 250L * 1024 * 1024);

        public PradoCourseImportService(GZPEGM1 db, HttpServerUtilityBase server)
        { this.db = db ?? throw new ArgumentNullException(nameof(db)); this.server = server ?? throw new ArgumentNullException(nameof(server)); }

        public PradoCourseImportResult Import(Stream input, string originalName, PradoCourseImportViewModel model, int userId)
        {
            if (input == null) throw new InvalidOperationException("ZIP dosyası okunamadı.");
            if (!string.Equals(Path.GetExtension(originalName), ".zip", StringComparison.OrdinalIgnoreCase))
                throw new InvalidOperationException("Yalnızca .zip uzantılı web sayfası paketi yüklenebilir.");

            var temp = Path.Combine(Path.GetTempPath(), "cezam-prado-" + Guid.NewGuid().ToString("N"));
            var zipPath = temp + ".zip";
            var createdRoot = default(string);
            Directory.CreateDirectory(temp);
            try
            {
                CopyWithLimit(input, zipPath, MaximumZipBytes);
                ExtractSafe(zipPath, temp);
                var htmlFiles = Directory.GetFiles(temp, "*.*", SearchOption.AllDirectories)
                    .Where(x => new[] { ".html", ".htm" }.Contains(Path.GetExtension(x), StringComparer.OrdinalIgnoreCase)).ToList();
                if (!htmlFiles.Any()) throw new InvalidOperationException("ZIP içinde HTML dosyası bulunamadı.");

                var parsed = Parse(htmlFiles);
                // If parser couldn't find a title and user didn't provide one, create with a placeholder but mark TitleMissing
                var titleMissing = string.IsNullOrWhiteSpace(parsed.Title) && string.IsNullOrWhiteSpace(model.CourseTitle);
                if (parsed.Facts.Count < 3) throw new InvalidOperationException("HTML içinde kurs oluşturacak yeterli başlık, açıklama veya liste bilgisi bulunamadı. Dinamik bir siteyse sayfa tamamen yüklendikten sonra Türkçeye çevirip ‘Web sayfası, tamamı’ olarak yeniden kaydedin.");
                var code = parsed.DocumentCode ?? FindDocumentCode(originalName) ?? "WEB-" + SafeName(parsed.Title ?? Path.GetFileNameWithoutExtension(originalName)).ToUpperInvariant();
                var folder = "web-egitim/" + SafeName(code) + "-" + Guid.NewGuid().ToString("N").Substring(0, 8);
                createdRoot = FileStorageHelper.MapPath(server, "~/files/Egitim/" + folder + "/");
                Directory.CreateDirectory(createdRoot);

                var images = CopyImages(temp, createdRoot, folder);
                var generatedName = "egitim.html";
                File.WriteAllText(Path.Combine(createdRoot, generatedName), BuildTurkishHtml(parsed, code, images), new UTF8Encoding(false));
                var resolvedTitle = string.IsNullOrWhiteSpace(model.CourseTitle) ? (parsed.Title ?? code) + " - Türkçe Eğitim" : model.CourseTitle.Trim();
                var coverPath = CreateCourseCover(model, resolvedTitle, code, parsed.SourceName, images, createdRoot, folder);

                int courseId, examId, generatedQuestions;
                using (var tx = db.Database.BeginTransaction())
                {
                    try
                    {
                        var category = db.Categories.FirstOrDefault(x => x.CategoryName == "Web Kaynaklı Belge Eğitimleri");
                        if (category == null)
                        {
                            category = new Categories { CategoryName = "Web Kaynaklı Belge Eğitimleri", Description = "PRADO, Regula, EdisonTD ve benzeri web kaynaklarından oluşturulan eğitimler", IsActive = true };
                            db.Categories.Add(category); db.SaveChanges();
                        }
                        var title = resolvedTitle;
                        var course = new Courses
                        {
                            CourseTitle = title, CourseDescription = BuildDescription(parsed, code), CategoryId = category.CategoryId,
                            CreatedBy = userId, CreatedDate = DateTime.Now, IsActive = false, IsDeleted = false,
                            ResourceFile = folder + "/" + generatedName, CoverImage = coverPath
                        };
                        db.Courses.Add(course); db.SaveChanges(); courseId = course.CourseId;
                        db.CourseContents.Add(new CourseContents
                        {
                            CourseId = courseId, ContentType = "HTML", ContentTitle = (parsed.Title ?? code) + " Türkçe Eğitim İçeriği",
                            ContentDescription = "Kaydedilmiş web sayfasından güvenli biçimde oluşturulmuştur.",
                            FilePath = folder + "/" + generatedName, CreatedDate = DateTime.Now
                        });
                        var exam = new Exam
                        {
                            CourseId = courseId, Title = code + " Değerlendirme Sınavı",
                            Description = "Yüklenen eğitim içeriğine ilişkin değerlendirme sınavı", DurationMinutes = 15,
                            PassingScore = 70, IsActive = false, IsArchived = false, CreatedAt = DateTime.Now
                        };
                        db.Exam.Add(exam); db.SaveChanges(); examId = exam.ExamId;
                        generatedQuestions = parsed.PreparedQuestions.Any()
                            ? AddPreparedQuestions(examId, parsed.PreparedQuestions, model.QuestionCount)
                            : AddQuestions(examId, code, parsed.Facts, images, model.QuestionCount);
                        db.SaveChanges(); tx.Commit();
                    }
                    catch { tx.Rollback(); throw; }
                }
                return new PradoCourseImportResult
                {
                    CourseId = courseId, ExamId = examId, ContentCount = 1, QuestionCount = generatedQuestions, DocumentCode = code,
                    Message = $"{code} için Türkçe kurs ve {generatedQuestions} soruluk sınav taslak olarak oluşturuldu. Kontrol edip son onayı verin.",
                    TitleMissing = titleMissing
                };
            }
            catch { if (createdRoot != null && Directory.Exists(createdRoot)) Directory.Delete(createdRoot, true); throw; }
            finally { TryDelete(temp); TryDelete(zipPath); }
        }

        private ParsedPrado Parse(List<string> files)
        {
            var result = new ParsedPrado();
            foreach (var file in files.OrderBy(x => Path.GetFileName(x).Equals("index.html", StringComparison.OrdinalIgnoreCase) ? 0 : 1))
            {
                var doc = new HtmlDocument(); doc.OptionFixNestedTags = true; doc.Load(file, Encoding.UTF8, true);
                foreach (var n in doc.DocumentNode.SelectNodes("//script|//style|//noscript") ?? Enumerable.Empty<HtmlNode>()) n.Remove();
                var text = WebUtility.HtmlDecode(doc.DocumentNode.InnerText ?? "");
                text = Regex.Replace(text, @"[\t\r ]+", " "); text = Regex.Replace(text, @"\n\s*\n+", "\n");
                result.DocumentCode = result.DocumentCode ?? FindDocumentCode(text);
                ExtractPreparedQuestions(doc, result);
                if (string.IsNullOrWhiteSpace(result.SourceName))
                {
                    if (text.IndexOf("regulaforensics", StringComparison.OrdinalIgnoreCase) >= 0) result.SourceName = "REGULA FORENSICS";
                    else if (text.IndexOf("edisontd", StringComparison.OrdinalIgnoreCase) >= 0) result.SourceName = "EDISON TD";
                    else if (text.IndexOf("PRADO", StringComparison.OrdinalIgnoreCase) >= 0 || result.DocumentCode != null) result.SourceName = "PRADO";
                }
                if (string.IsNullOrWhiteSpace(result.Title))
                {
                    var candidateTitle = Clean((doc.DocumentNode.SelectSingleNode("//main//h1") ?? doc.DocumentNode.SelectSingleNode("//article//h1") ?? doc.DocumentNode.SelectSingleNode("//h1") ?? doc.DocumentNode.SelectSingleNode("//title"))?.InnerText);
                    if (!string.IsNullOrWhiteSpace(candidateTitle)) result.Title = candidateTitle;
                }
                var edisonFactCount = ExtractEdisonContent(doc, result) + ExtractEdisonDetailContent(doc, result);
                foreach (var grid in doc.DocumentNode.SelectNodes("//div[contains(concat(' ',normalize-space(@class),' '),' gsc-bge-grid ')]") ?? Enumerable.Empty<HtmlNode>())
                {
                    var areas = grid.SelectNodes("./div[contains(concat(' ',normalize-space(@class),' '),' gsc-bge-grid__area ')]");
                    if (areas == null || areas.Count < 2) continue;
                    var rawKey = Clean(areas[0].InnerText).TrimEnd(':').Trim();
                    var rawValue = Clean(areas[1].InnerText);
                    string translatedKey;
                    if (!Terms.TryGetValue(rawKey, out translatedKey) || string.IsNullOrWhiteSpace(rawValue) || rawValue.Length > 1000) continue;
                    AddFact(result, translatedKey, TranslateValue(rawValue), rawKey);
                }
                var lines = text.Split('\n').Select(Clean).Where(x => x.Length > 0).ToList();
                var start = lines.FindIndex(x => Regex.IsMatch(x, @"^(Document:)?\s*[A-Z]{3}-[A-Z]{2}-\d{5}"));
                if (start < 0)
                {
                    if (edisonFactCount == 0) ExtractGenericContent(doc, result);
                    continue;
                }
                for (var i = start; i < lines.Count - 1; i++)
                {
                    if (lines[i].StartsWith("This information is supplied", StringComparison.OrdinalIgnoreCase)) break;
                    var key = lines[i].TrimEnd(':').Trim();
                    if (!Terms.ContainsKey(key) || i + 1 >= lines.Count) continue;
                    var value = lines[i + 1];
                    if (Terms.ContainsKey(value.TrimEnd(':')) || value.Length > 1000) continue;
                    AddFact(result, Terms[key], TranslateValue(value), key);
                }
                ExtractGenericContent(doc, result);
            }
            return result;
        }

        private static int ExtractEdisonContent(HtmlDocument doc, ParsedPrado result)
        {
            var documentCards = doc.DocumentNode.SelectNodes("//div[contains(concat(' ',normalize-space(@class),' '),' document-wrapper ')][@title]");
            if (documentCards == null || documentCards.Count == 0) return 0;

            result.SourceName = "EDISON TD";
            var country = Clean(doc.DocumentNode.SelectSingleNode("//*[@data-testid='sidebar-country']")?.InnerText);
            if (!string.IsNullOrWhiteSpace(country))
            {
                result.Title = country + " Seyahat Belgeleri";
                AddFact(result, "Ülke", country, "edison-country");
            }
            else if (string.Equals(result.Title, "EDISON BROWSER", StringComparison.OrdinalIgnoreCase))
                result.Title = "EdisonTD Belge Eğitimi";

            var before = result.Facts.Count;
            foreach (var card in documentCards)
            {
                var description = Clean(card.GetAttributeValue("title", ""));
                if (string.IsNullOrWhiteSpace(description)) continue;
                var group = card.Ancestors("div").FirstOrDefault(x => (x.GetAttributeValue("class", "") ?? "").Split(' ').Contains("mb-4"));
                var category = Clean(group?.SelectSingleNode(".//h5")?.InnerText).TrimEnd(':');
                if (string.IsNullOrWhiteSpace(category)) category = "Belge modeli";
                AddFact(result, category, description, "edison-document");
            }
            return result.Facts.Count - before;
        }

        private static int ExtractEdisonDetailContent(HtmlDocument doc, ParsedPrado result)
        {
            var details = doc.DocumentNode.SelectSingleNode("//*[@id='part-details-content']");
            var sectionNodes = doc.DocumentNode.SelectNodes("//*[starts-with(@data-testid,'section-name-')]");
            if (details == null && (sectionNodes == null || sectionNodes.Count == 0)) return 0;

            result.SourceName = "EDISON TD";
            var breadcrumbs = (doc.DocumentNode.SelectNodes("//div[contains(concat(' ',normalize-space(@class),' '),' breadcrumb-item ') and contains(concat(' ',normalize-space(@class),' '),' active ')]")
                ?? new HtmlNodeCollection(null)).Select(x => Clean(x.InnerText)).Where(x => !string.IsNullOrWhiteSpace(x)).ToList();
            var country = Clean(doc.DocumentNode.SelectSingleNode("//*[@data-testid='sidebar-country']")?.InnerText);
            var documentType = breadcrumbs.FirstOrDefault(x => !x.Equals(country, StringComparison.OrdinalIgnoreCase) && !x.Equals("Seçme", StringComparison.OrdinalIgnoreCase));
            var modelName = breadcrumbs.LastOrDefault(x => !x.Equals(country, StringComparison.OrdinalIgnoreCase) && !x.Equals(documentType, StringComparison.OrdinalIgnoreCase));

            var titleParts = new[] { country, documentType, modelName }.Where(x => !string.IsNullOrWhiteSpace(x)).Distinct(StringComparer.OrdinalIgnoreCase).ToList();
            result.Title = titleParts.Any() ? string.Join(" - ", titleParts) : "EdisonTD Belge Detay Eğitimi";

            var before = result.Facts.Count;
            AddFact(result, "Ülke", country, "edison-detail");
            AddFact(result, "Belge türü", documentType, "edison-detail");
            AddFact(result, "Model", modelName, "edison-detail");

            foreach (var section in sectionNodes ?? Enumerable.Empty<HtmlNode>())
            {
                var sectionName = Clean(section.InnerText);
                var table = section.SelectSingleNode("following-sibling::table[1]");
                foreach (var row in table?.SelectNodes(".//tr") ?? Enumerable.Empty<HtmlNode>())
                {
                    var key = Clean(row.SelectSingleNode("./th")?.InnerText).TrimEnd(':');
                    var value = Clean(row.SelectSingleNode("./td")?.InnerText);
                    if (string.IsNullOrWhiteSpace(key) || string.IsNullOrWhiteSpace(value)) continue;
                    AddFact(result, string.IsNullOrWhiteSpace(sectionName) ? key : sectionName + " - " + key, value, "edison-detail");
                }
            }
            return result.Facts.Count - before;
        }

        private static void ExtractGenericContent(HtmlDocument doc, ParsedPrado result)
        {
            var root = doc.DocumentNode.SelectSingleNode("//main") ?? doc.DocumentNode.SelectSingleNode("//article")
                ?? doc.DocumentNode.SelectSingleNode("//*[@role='main']") ?? doc.DocumentNode.SelectSingleNode("//body");
            if (root == null) return;
            var heading = string.IsNullOrWhiteSpace(result.Title) ? "Eğitim içeriği" : result.Title;
            var sequence = 0;
            foreach (var node in root.Descendants().Where(x => new[] { "h1", "h2", "h3", "h4", "h5", "h6", "p", "li", "figcaption" }.Contains(x.Name, StringComparer.OrdinalIgnoreCase)))
            {
                var value = Clean(node.InnerText);
                if (value.Length < 3 || IsBoilerplate(value)) continue;
                if (Regex.IsMatch(node.Name, @"^h[1-6]$", RegexOptions.IgnoreCase)) { heading = value; continue; }
                if (value.Length < 20 && node.Name != "li" && node.Name != "figcaption") continue;
                if (value.Length > 1200) value = value.Substring(0, 1200).Trim() + "…";
                var label = heading;
                if (result.Facts.Count(x => x.Label.Equals(label, StringComparison.OrdinalIgnoreCase)) >= 4)
                    label = heading + " - " + (++sequence);
                AddFact(result, label, TranslateValue(value), node.Name);
                if (result.Facts.Count >= 100) break;
            }
        }

        private static void ExtractPreparedQuestions(HtmlDocument doc, ParsedPrado result)
        {
            var examNodes = doc.DocumentNode.SelectNodes("//*[@data-exam='true' or @data-exam='1' or contains(concat(' ',normalize-space(@class),' '),' ai-exam ')]");
            if (examNodes == null) return;

            foreach (var examNode in examNodes.ToList())
            {
                var questionNodes = examNode.SelectNodes(".//*[@data-question='true' or @data-question='1' or contains(concat(' ',normalize-space(@class),' '),' question ')]");
                foreach (var questionNode in questionNodes ?? Enumerable.Empty<HtmlNode>())
                {
                    var prepared = ParsePreparedQuestion(questionNode);
                    if (prepared != null && !result.PreparedQuestions.Any(x => x.Text.Equals(prepared.Text, StringComparison.OrdinalIgnoreCase)))
                        result.PreparedQuestions.Add(prepared);
                }

                examNode.Remove();
            }
        }

        private static PreparedQuestion ParsePreparedQuestion(HtmlNode questionNode)
        {
            var correctKey = Clean(questionNode.GetAttributeValue("data-correct", ""));
            var questionText = Clean(questionNode.GetAttributeValue("data-text", ""));
            if (string.IsNullOrWhiteSpace(questionText))
            {
                var textNode = questionNode.SelectSingleNode("./*[self::h2 or self::h3 or self::h4 or self::p][not(ancestor::ol) and not(ancestor::ul)]")
                    ?? questionNode.SelectSingleNode(".//*[@data-question-text='true' or contains(concat(' ',normalize-space(@class),' '),' question-text ')]");
                questionText = Clean(textNode?.InnerText);
            }

            var optionNodes = questionNode.SelectNodes(".//ol/li|.//ul/li|.//*[@data-option]");
            var options = new List<PreparedOption>();
            var index = 0;
            foreach (var optionNode in optionNodes ?? Enumerable.Empty<HtmlNode>())
            {
                var text = Clean(optionNode.InnerText);
                if (string.IsNullOrWhiteSpace(text)) continue;

                var key = Clean(optionNode.GetAttributeValue("data-key", ""));
                if (string.IsNullOrWhiteSpace(key)) key = Clean(optionNode.GetAttributeValue("value", ""));
                if (string.IsNullOrWhiteSpace(key)) key = ((char)('A' + index)).ToString();

                var isCorrect = string.Equals(Clean(optionNode.GetAttributeValue("data-correct", "")), "true", StringComparison.OrdinalIgnoreCase)
                    || string.Equals(Clean(optionNode.GetAttributeValue("data-correct", "")), "1", StringComparison.OrdinalIgnoreCase)
                    || optionNode.GetClasses().Any(x => x.Equals("correct", StringComparison.OrdinalIgnoreCase));

                options.Add(new PreparedOption { Key = key, Text = StripOptionPrefix(text), IsCorrect = isCorrect });
                index++;
            }

            if (!string.IsNullOrWhiteSpace(correctKey))
            {
                var numericIndex = 0;
                var hasNumeric = int.TryParse(correctKey, out numericIndex);
                for (var i = 0; i < options.Count; i++)
                {
                    if (string.Equals(options[i].Key, correctKey, StringComparison.OrdinalIgnoreCase)
                        || string.Equals(((char)('A' + i)).ToString(), correctKey, StringComparison.OrdinalIgnoreCase)
                        || (hasNumeric && numericIndex == i + 1))
                        options[i].IsCorrect = true;
                }
            }

            options = options
                .Where(x => !string.IsNullOrWhiteSpace(x.Text))
                .GroupBy(x => x.Text, StringComparer.OrdinalIgnoreCase)
                .Select(x => x.First())
                .Take(6)
                .ToList();

            if (questionText.Length < 8 || questionText.Length > 500) return null;
            if (options.Count < 4 || options.Count(x => x.IsCorrect) != 1) return null;

            return new PreparedQuestion { Text = questionText, Options = options };
        }

        private static string StripOptionPrefix(string value)
        {
            return Regex.Replace(Clean(value), @"^\s*([A-Ha-h]|\d{1,2})[\)\.\-:]\s*", "").Trim();
        }

        private static bool IsBoilerplate(string value)
        {
            return Regex.IsMatch(value, @"^(menu|search|cookie|accept|privacy|contact|subscribe|back to|skip to|home|login|sign in|tüm çerez|arama|menü|iletişim|gizlilik)\b", RegexOptions.IgnoreCase)
                || value.IndexOf("javascript", StringComparison.OrdinalIgnoreCase) >= 0;
        }
        private static bool IsGoodVisualCaption(string value)
        {
            value = Clean(value);
            if (value.Length < 5 || value.Length > 160) return false;
            if (IsBoilerplate(value)) return false;
            if (Regex.IsMatch(value, @"\.(jpg|jpeg|png|gif|webp)$", RegexOptions.IgnoreCase)) return false;
            if (Regex.IsMatch(value, @"^(image|resim|photo|foto|picture|görsel|model|preview|önizleme|section preview|bölüm önizlemesi)\s*\d*$", RegexOptions.IgnoreCase)) return false;
            if (Regex.IsMatch(value, @"^\d+$")) return false;
            return true;
        }

        private static bool IsGoodQuestionFact(PradoFact fact)
        {
            if (fact == null) return false;
            var label = Clean(fact.Label);
            var value = Clean(fact.Value);
            if (label.Length < 3 || label.Length > 120) return false;
            if (value.Length < 6 || value.Length > 180) return false;
            if (IsBoilerplate(label) || IsBoilerplate(value)) return false;
            if (Regex.IsMatch(value, @"^(yes|no|evet|hayır|true|false|var|yok|n/?a|-)$", RegexOptions.IgnoreCase)) return false;
            if (Regex.IsMatch(value, @"^(click|tap|read more|more|next|previous|download|view|select|seç|indir|görüntüle)\b", RegexOptions.IgnoreCase)) return false;
            if (Regex.IsMatch(value, @"^https?://", RegexOptions.IgnoreCase)) return false;
            if (string.Equals(label, value, StringComparison.OrdinalIgnoreCase)) return false;
            if (value.IndexOf(label, StringComparison.OrdinalIgnoreCase) >= 0 && value.Length <= label.Length + 10) return false;
            return true;
        }

        private static List<string> BuildWrongOptions(string correct, IEnumerable<string> candidates, string seed)
        {
            correct = Clean(correct);
            if (string.IsNullOrWhiteSpace(correct)) return new List<string>();

            var minLength = Math.Max(4, correct.Length / 3);
            var maxLength = Math.Max(20, correct.Length * 3);

            return candidates
                .Select(Clean)
                .Where(x => !string.IsNullOrWhiteSpace(x))
                .Where(x => !x.Equals(correct, StringComparison.OrdinalIgnoreCase))
                .Where(x => x.Length >= minLength && x.Length <= maxLength)
                .Where(x => !IsBoilerplate(x))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .OrderBy(x => StableHash(seed + "|" + x))
                .Take(3)
                .ToList();
        }

        private int AddQuestions(int examId, string documentCode, List<PradoFact> facts, List<CopiedImage> images, int requested)
        {
            requested = Math.Max(5, Math.Min(requested, 20));
            var order = 0;
            facts = (facts ?? new List<PradoFact>()).Where(IsGoodQuestionFact).ToList();
            images = images ?? new List<CopiedImage>();

            var visualCandidates = images.Where(x => IsGoodVisualCaption(x.Caption))
                .GroupBy(x => x.Caption, StringComparer.OrdinalIgnoreCase).Select(x => x.First())
                .Take(Math.Max(1, requested / 2)).ToList();
            var visualAnswers = images.Select(x => x.Caption).Where(IsGoodVisualCaption).Distinct(StringComparer.OrdinalIgnoreCase).ToList();
            foreach (var image in visualCandidates)
            {
                var wrong = BuildWrongOptions(image.Caption, visualAnswers, image.FileName);
                if (wrong.Count < 3) continue;

                var q = new Question { ExamId = examId, Text = $"Görsel, {documentCode} eğitimindeki hangi örneği veya bölümü göstermektedir?", QuestionType = 1, Points = 10, SortOrder = ++order, IsActive = false };
                db.Question.Add(q); db.SaveChanges();
                db.QuestionMedia.Add(new QuestionMedia { QuestionId = q.QuestionId, MediaType = 1, MediaPath = "/files/Egitim/" + image.RelativePath, SortOrder = 1, CreatedAt = DateTime.Now });
                AddOptions(q.QuestionId, image.Caption, wrong, image.FileName);
            }

            var remaining = requested - order;
            var usable = facts
                .GroupBy(x => x.Label, StringComparer.OrdinalIgnoreCase).Select(x => x.First())
                .Take(remaining).ToList();
            var allValues = facts.Select(x => x.Value).Distinct(StringComparer.OrdinalIgnoreCase).ToList();
            foreach (var fact in usable)
            {
                var wrong = BuildWrongOptions(fact.Value, allValues, fact.Label);
                if (wrong.Count < 3) continue;

                var q = new Question { ExamId = examId, Text = $"{documentCode} eğitim içeriğinde “{fact.Label}” başlığıyla verilen bilgi hangisidir?", QuestionType = 1, Points = 10, SortOrder = ++order, IsActive = false };
                db.Question.Add(q); db.SaveChanges();
                AddOptions(q.QuestionId, fact.Value, wrong, fact.Label);
            }
            return order;
        }

        private int AddPreparedQuestions(int examId, List<PreparedQuestion> questions, int requested)
        {
            requested = Math.Max(1, Math.Min(requested, 30));
            var order = 0;
            foreach (var prepared in (questions ?? new List<PreparedQuestion>()).Take(requested))
            {
                var options = (prepared.Options ?? new List<PreparedOption>())
                    .Where(x => !string.IsNullOrWhiteSpace(x.Text))
                    .GroupBy(x => x.Text, StringComparer.OrdinalIgnoreCase)
                    .Select(x => x.First())
                    .Take(6)
                    .ToList();

                if (string.IsNullOrWhiteSpace(prepared.Text) || options.Count < 4 || options.Count(x => x.IsCorrect) != 1)
                    continue;

                var q = new Question
                {
                    ExamId = examId,
                    Text = Clean(prepared.Text),
                    QuestionType = 1,
                    Points = 10,
                    SortOrder = ++order,
                    IsActive = false
                };
                db.Question.Add(q);
                db.SaveChanges();

                for (var i = 0; i < options.Count; i++)
                {
                    db.QuestionOption.Add(new QuestionOption
                    {
                        QuestionId = q.QuestionId,
                        Text = Clean(options[i].Text),
                        IsCorrect = options[i].IsCorrect,
                        SortOrder = i + 1
                    });
                }
            }
            return order;
        }

        private void AddOptions(int questionId, string correct, List<string> wrong, string seed)
        {
            correct = Clean(correct);
            wrong = (wrong ?? new List<string>()).Select(Clean)
                .Where(x => !string.IsNullOrWhiteSpace(x) && !x.Equals(correct, StringComparison.OrdinalIgnoreCase))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .Take(3)
                .ToList();

            if (string.IsNullOrWhiteSpace(correct) || wrong.Count < 3) return;

            var options = wrong.Select(x => new { Text = x, Correct = false }).Concat(new[] { new { Text = correct, Correct = true } })
                .OrderBy(x => StableHash(seed + "|" + x.Text)).ToList();
            for (var i = 0; i < options.Count; i++) db.QuestionOption.Add(new QuestionOption { QuestionId = questionId, Text = options[i].Text, IsCorrect = options[i].Correct, SortOrder = i + 1 });
        }
        private List<CopiedImage> CopyImages(string temp, string target, string folder)
        {
            var captions = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            foreach (var html in Directory.GetFiles(temp, "*.*", SearchOption.AllDirectories).Where(x => new[] { ".html", ".htm" }.Contains(Path.GetExtension(x), StringComparer.OrdinalIgnoreCase)))
            {
                var doc = new HtmlDocument(); doc.Load(html, Encoding.UTF8, true);
                foreach (var img in doc.DocumentNode.SelectNodes("//img[@src]") ?? Enumerable.Empty<HtmlNode>())
                {
                    var file = Path.GetFileName((img.GetAttributeValue("src", "") ?? "").Replace('/', Path.DirectorySeparatorChar));
                    var caption = Clean(img.GetAttributeValue("alt", img.GetAttributeValue("title", "")));
                    if (string.Equals(caption, "bölüm önizlemesi", StringComparison.OrdinalIgnoreCase) || string.Equals(caption, "section preview", StringComparison.OrdinalIgnoreCase))
                    {
                        var part = img.Ancestors("div").FirstOrDefault(x => (x.GetAttributeValue("class", "") ?? "").IndexOf("document-part-wrapper", StringComparison.OrdinalIgnoreCase) >= 0);
                        var partName = Clean(part?.SelectSingleNode(".//span")?.InnerText);
                        if (!string.IsNullOrWhiteSpace(partName)) caption = partName;
                    }
                    if (string.Equals(caption, "model kapağı", StringComparison.OrdinalIgnoreCase) || string.Equals(caption, "model cover", StringComparison.OrdinalIgnoreCase))
                    {
                        var documentCard = img.Ancestors("div").FirstOrDefault(x => !string.IsNullOrWhiteSpace(x.GetAttributeValue("title", "")));
                        caption = Clean(documentCard?.GetAttributeValue("title", ""));
                    }
                    if (string.IsNullOrWhiteSpace(caption))
                    {
                        var block = img.Ancestors("div").FirstOrDefault(x => (x.GetAttributeValue("class", "") ?? "").IndexOf("img-block", StringComparison.OrdinalIgnoreCase) >= 0);
                        var blockCaption = block?.SelectSingleNode(".//*[contains(concat(' ',normalize-space(@class),' '),' glossary-content__block-caption ')]");
                        caption = Clean(blockCaption?.InnerText);
                    }
                    caption = Regex.Replace(caption, @"\s+(Resmi|Image)\s*\d*\s*$", "", RegexOptions.IgnoreCase).Trim();
                    if (caption.Length > 300) caption = caption.Substring(0, 300).Trim() + "…";
                    if (!string.IsNullOrWhiteSpace(file) && !string.IsNullOrWhiteSpace(caption)) captions[file] = caption;
                }
            }
            var result = new List<CopiedImage>(); var index = 0;
            foreach (var source in Directory.GetFiles(temp, "*.*", SearchOption.AllDirectories)
                .Where(x => IsImage(Path.GetExtension(x)))
                .Where(x => !Regex.IsMatch(Path.GetFileName(x), @"(logo|icon|favicon|sprite|pixel)", RegexOptions.IgnoreCase)).Take(100))
            {
                var name = (++index).ToString("000") + "-" + SafeName(Path.GetFileNameWithoutExtension(source)) + Path.GetExtension(source).ToLowerInvariant();
                File.Copy(source, Path.Combine(target, name), false);
                string caption; captions.TryGetValue(Path.GetFileName(source), out caption);
                result.Add(new CopiedImage { FileName = name, RelativePath = folder + "/" + name, Caption = caption });
            }
            return result;
        }

        private string CreateCourseCover(PradoCourseImportViewModel model, string title, string code, string sourceName, List<CopiedImage> images, string target, string folder)
        {
            if (model.CoverMode == CourseCoverMode.CustomUpload)
                return SaveCustomCover(model.CustomCoverFile, target, folder);

            if (model.CoverMode == CourseCoverMode.SourceImage && images.Any())
                return images[0].RelativePath;

            const string fileName = "kapak-otomatik.jpg";
            var output = Path.Combine(target, fileName);
            using (var bitmap = new Bitmap(1200, 675, PixelFormat.Format24bppRgb))
            using (var graphics = Graphics.FromImage(bitmap))
            {
                graphics.SmoothingMode = SmoothingMode.AntiAlias;
                graphics.TextRenderingHint = System.Drawing.Text.TextRenderingHint.AntiAliasGridFit;
                using (var background = new LinearGradientBrush(new Rectangle(0, 0, 1200, 675), Color.FromArgb(12, 31, 50), Color.FromArgb(26, 103, 145), 20f))
                    graphics.FillRectangle(background, 0, 0, 1200, 675);

                using (var glow = new SolidBrush(Color.FromArgb(35, 255, 255, 255)))
                {
                    graphics.FillEllipse(glow, 760, -210, 620, 620);
                    graphics.FillEllipse(glow, 900, 410, 350, 350);
                }
                using (var pen = new Pen(Color.FromArgb(52, 255, 255, 255), 2f))
                    for (var i = 0; i < 7; i++) graphics.DrawArc(pen, 785 + i * 18, 85 + i * 18, 310 - i * 24, 310 - i * 24, 195, 245);

                DrawCoverSourceImage(graphics, images, target);

                using (var accent = new SolidBrush(Color.FromArgb(242, 178, 51))) graphics.FillRectangle(accent, 70, 78, 92, 7);
                using (var badgeBrush = new SolidBrush(Color.FromArgb(42, 255, 255, 255))) graphics.FillRectangle(badgeBrush, 70, 106, 260, 42);
                using (var badgeFont = new Font("Segoe UI", 15, FontStyle.Bold, GraphicsUnit.Pixel))
                using (var white = new SolidBrush(Color.White))
                    graphics.DrawString(string.IsNullOrWhiteSpace(sourceName) ? "CEZAM EĞİTİM" : sourceName, badgeFont, white, new RectangleF(88, 116, 225, 25));

                using (var titleFont = new Font("Segoe UI", 46, FontStyle.Bold, GraphicsUnit.Pixel))
                using (var white = new SolidBrush(Color.White))
                    DrawWrappedText(graphics, title, titleFont, white, new RectangleF(70, 188, 680, 270), 4);

                using (var codeFont = new Font("Segoe UI", 20, FontStyle.Regular, GraphicsUnit.Pixel))
                using (var muted = new SolidBrush(Color.FromArgb(215, 232, 242)))
                    graphics.DrawString(code + "  •  Belge inceleme ve güvenlik eğitimi", codeFont, muted, new RectangleF(72, 520, 690, 40));

                using (var footerFont = new Font("Segoe UI", 16, FontStyle.Bold, GraphicsUnit.Pixel))
                using (var footer = new SolidBrush(Color.FromArgb(230, 255, 255, 255)))
                    graphics.DrawString("CEZAM", footerFont, footer, new PointF(70, 612));

                var encoder = ImageCodecInfo.GetImageEncoders().First(x => x.FormatID == ImageFormat.Jpeg.Guid);
                using (var parameters = new EncoderParameters(1))
                {
                    parameters.Param[0] = new EncoderParameter(System.Drawing.Imaging.Encoder.Quality, 92L);
                    bitmap.Save(output, encoder, parameters);
                }
            }
            return folder + "/" + fileName;
        }

        private static string SaveCustomCover(HttpPostedFileBase file, string target, string folder)
        {
            if (file == null || file.ContentLength <= 0) throw new InvalidOperationException("Özel kapak görseli bulunamadı.");
            if (file.ContentLength > 10 * 1024 * 1024) throw new InvalidOperationException("Kapak görseli 10 MB'tan büyük olamaz.");
            var ext = Path.GetExtension(file.FileName)?.ToLowerInvariant();
            if (!new[] { ".jpg", ".jpeg", ".png", ".webp" }.Contains(ext)) throw new InvalidOperationException("Kapak için JPG, PNG veya WEBP görseli yükleyin.");
            var name = "kapak-ozel" + ext;
            using (var output = File.Create(Path.Combine(target, name))) file.InputStream.CopyTo(output);
            return folder + "/" + name;
        }

        private static void DrawCoverSourceImage(Graphics graphics, List<CopiedImage> images, string target)
        {
            var candidate = images.FirstOrDefault(x => new[] { ".jpg", ".jpeg", ".png", ".gif" }.Contains(Path.GetExtension(x.FileName), StringComparer.OrdinalIgnoreCase));
            if (candidate == null) return;
            try
            {
                using (var image = Image.FromFile(Path.Combine(target, candidate.FileName)))
                {
                    var box = new Rectangle(820, 155, 300, 385);
                    using (var shadow = new SolidBrush(Color.FromArgb(50, 0, 0, 0))) graphics.FillRectangle(shadow, box.X + 12, box.Y + 14, box.Width, box.Height);
                    using (var frame = new SolidBrush(Color.White)) graphics.FillRectangle(frame, box.X - 8, box.Y - 8, box.Width + 16, box.Height + 16);
                    var ratio = Math.Min((float)box.Width / image.Width, (float)box.Height / image.Height);
                    var width = (int)(image.Width * ratio); var height = (int)(image.Height * ratio);
                    graphics.DrawImage(image, box.X + (box.Width - width) / 2, box.Y + (box.Height - height) / 2, width, height);
                }
            }
            catch { }
        }

        private static void DrawWrappedText(Graphics graphics, string text, Font font, Brush brush, RectangleF area, int maxLines)
        {
            var words = (text ?? "Eğitim").Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            var lines = new List<string>(); var current = "";
            foreach (var word in words)
            {
                var test = string.IsNullOrEmpty(current) ? word : current + " " + word;
                if (graphics.MeasureString(test, font).Width <= area.Width) current = test;
                else { if (!string.IsNullOrEmpty(current)) lines.Add(current); current = word; if (lines.Count == maxLines - 1) break; }
            }
            if (!string.IsNullOrEmpty(current) && lines.Count < maxLines) lines.Add(current);
            for (var i = 0; i < lines.Count; i++) graphics.DrawString(lines[i], font, brush, new PointF(area.X, area.Y + i * (font.GetHeight(graphics) + 5)));
        }

        private string BuildTurkishHtml(ParsedPrado data, string code, List<CopiedImage> images)
        {
            var title = data.Title ?? code + " Eğitimi";
            var generic = data.Facts.Any(x => x.OriginalLabel == "p" || x.OriginalLabel == "li" || x.OriginalLabel == "figcaption");
            var sb = new StringBuilder();
            sb.Append("<!doctype html><html lang=\"tr\"><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width,initial-scale=1\"><title>")
                .Append(H(title)).Append("</title><style>")
                .Append(":root{--navy:#14283d;--blue:#1769aa;--ink:#17212b;--muted:#647383;--line:#dfe5ea;--soft:#f5f7f9}*{box-sizing:border-box}body{margin:0;background:#fff;color:var(--ink);font:17px/1.68 Arial,Helvetica,sans-serif}.top{height:8px;background:linear-gradient(90deg,#13283c,#277cae)}.hero{background:#f3f6f8;border-bottom:1px solid var(--line);padding:56px 24px}.hero-inner,.page{max-width:1180px;margin:auto}.eyebrow{color:var(--blue);font-size:13px;font-weight:700;letter-spacing:.12em;text-transform:uppercase}.hero h1{font-size:46px;line-height:1.12;margin:10px 0 0;color:var(--navy)}.page{padding:48px 24px 70px}.intro{font-size:19px;color:#40505e;max-width:880px}.article{max-width:900px}.article p{margin:0 0 24px}.article ul{margin:0 0 28px;padding-left:25px}.article li{margin:8px 0}.section-title{font-size:27px;line-height:1.25;color:var(--navy);margin:44px 0 18px}.facts{border:1px solid var(--line);border-radius:8px;overflow:hidden}.fact{display:grid;grid-template-columns:minmax(210px,32%) 1fr;border-bottom:1px solid var(--line)}.fact:last-child{border-bottom:0}.fact b,.fact span{padding:14px 16px}.fact b{background:var(--soft);color:var(--navy)}.gallery{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:28px;margin-top:22px}.figure{margin:0;border:1px solid var(--line);border-radius:8px;overflow:hidden;background:#fff;box-shadow:0 5px 18px rgba(24,45,65,.08)}.figure-img{background:#f1f3f5;display:flex;align-items:center;justify-content:center;min-height:280px;padding:12px}.figure img{display:block;max-width:100%;width:auto;height:auto;max-height:580px;object-fit:contain}.figure figcaption{padding:14px 16px;color:#536270;font-size:14px;border-top:1px solid var(--line)}.source{margin-top:55px;padding-top:20px;border-top:1px solid var(--line);color:var(--muted);font-size:13px}@media(max-width:720px){.hero h1{font-size:34px}.gallery{grid-template-columns:1fr}.fact{grid-template-columns:1fr}.fact b{padding-bottom:4px}.fact span{padding-top:4px}.page{padding:30px 18px}}")
                .Append("</style></head><body><div class=\"top\"></div><header class=\"hero\"><div class=\"hero-inner\"><div class=\"eyebrow\">Belge İnceleme Eğitimi</div><h1>")
                .Append(H(title)).Append("</h1></div></header><main class=\"page\"><p class=\"intro\">Bu eğitim, yüklenen kaynak sayfanın metinleri ve görselleri kullanılarak çevrimdışı çalışacak biçimde hazırlanmıştır.</p>");

            if (generic)
            {
                sb.Append("<article class=\"article\"><h2 class=\"section-title\">Eğitim İçeriği</h2>");
                var listOpen = false;
                foreach (var fact in data.Facts.Where(x => x.OriginalLabel != "figcaption"))
                {
                    if (fact.OriginalLabel == "li")
                    {
                        if (!listOpen) { sb.Append("<ul>"); listOpen = true; }
                        sb.Append("<li>").Append(H(fact.Value)).Append("</li>");
                    }
                    else
                    {
                        if (listOpen) { sb.Append("</ul>"); listOpen = false; }
                        sb.Append("<p>").Append(H(fact.Value)).Append("</p>");
                    }
                }
                if (listOpen) sb.Append("</ul>");
                sb.Append("</article>");
            }
            else
            {
                sb.Append("<h2 class=\"section-title\">Belge Bilgileri</h2><div class=\"facts\">");
                foreach (var f in data.Facts) sb.Append("<div class=\"fact\"><b>").Append(H(f.Label)).Append("</b><span>").Append(H(f.Value)).Append("</span></div>");
                sb.Append("</div>");
            }

            if (images.Any())
            {
                sb.Append("<h2 class=\"section-title\">Görsel Örnekler</h2><div class=\"gallery\">");
                foreach (var image in images)
                {
                    var imageUrl = "/files/Egitim/" + image.RelativePath.Replace("\\", "/");
                    sb.Append("<figure class=\"figure\"><div class=\"figure-img\"><img loading=\"lazy\" src=\"")
                        .Append(HttpUtility.HtmlAttributeEncode(imageUrl)).Append("\" alt=\"").Append(HttpUtility.HtmlAttributeEncode(image.Caption ?? "Eğitim görseli"))
                        .Append("\"></div><figcaption>").Append(H(image.Caption ?? "Kaynak sayfadan alınan görsel örnek")).Append("</figcaption></figure>");
                }
                sb.Append("</div>");
            }
            return sb.Append("<div class=\"source\">Kaynak: Yüklenen web sayfası. Eğitim yayınlanmadan önce yetkili kişi tarafından doğrulanmalıdır.</div></main></body></html>").ToString();
        }

        private static string BuildDescription(ParsedPrado p, string code) => $"{(p.Title ?? code)} kaynağından oluşturulan Türkçe eğitim içeriği.";
        private static string TranslateValue(string value)
        {
            var v = Clean(value);
            var replacements = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase) { ["yes"]="evet", ["no"]="hayır", ["Indefinite"]="süresiz", ["year(s)"]="yıl", ["month(s)"]="ay", ["flexible"]="esnek", ["plastic"]="plastik", ["paper"]="kâğıt", ["burgundy"]="bordo", ["gold"]="altın", ["black & white"]="siyah-beyaz", ["blue"]="mavi", ["yellow"]="sarı", ["other"]="diğer", ["positioned - centred"]="konumlandırılmış - ortalanmış", ["substrate without optical brighteners"]="optik parlatıcı içermeyen alt tabaka", ["fluorescent ink"]="floresan mürekkep" };
            foreach (var item in replacements.OrderByDescending(x => x.Key.Length)) v = Regex.Replace(v, @"\b" + Regex.Escape(item.Key) + @"\b", item.Value, RegexOptions.IgnoreCase);
            return v;
        }

        private void ExtractSafe(string zipPath, string destination)
        {
            long total = 0; var root = Path.GetFullPath(destination + Path.DirectorySeparatorChar);
            using (var zip = ZipFile.OpenRead(zipPath)) foreach (var entry in zip.Entries)
            {
                if (string.IsNullOrEmpty(entry.Name)) continue;
                var ext = Path.GetExtension(entry.Name); if (!AllowedExtensions.Contains(ext)) continue;
                total += entry.Length; if (total > MaximumExtractedBytes) throw new InvalidOperationException("ZIP açılmış boyut sınırını aşıyor.");
                var target = Path.GetFullPath(Path.Combine(root, entry.FullName.Replace('/', Path.DirectorySeparatorChar)));
                if (!target.StartsWith(root, StringComparison.OrdinalIgnoreCase)) throw new InvalidOperationException("ZIP içinde güvensiz dosya yolu bulundu.");
                Directory.CreateDirectory(Path.GetDirectoryName(target)); entry.ExtractToFile(target, false);
            }
        }

        private static void CopyWithLimit(Stream input, string path, long limit) { long total=0; var b=new byte[81920]; using(var o=File.Create(path)){ int n; while((n=input.Read(b,0,b.Length))>0){ total+=n; if(total>limit) throw new InvalidOperationException("ZIP dosyası boyut sınırını aşıyor."); o.Write(b,0,n); } } }
        private static long ReadLimit(string key, long fallback) { long value; return long.TryParse(ConfigurationManager.AppSettings[key], out value) && value > 0 ? value : fallback; }
        private static string FindDocumentCode(string text) { var m=Regex.Match(text ?? "", @"\b[A-Z]{3}-[A-Z]{2}-\d{5}\b", RegexOptions.IgnoreCase); return m.Success ? m.Value.ToUpperInvariant() : null; }
        private static string Clean(string value) => Regex.Replace(WebUtility.HtmlDecode(value ?? ""), @"\s+", " ").Trim(' ', ':');
        private static string SafeName(string value) { var v=Regex.Replace(value ?? "file", @"[^A-Za-z0-9_-]+", "-").Trim('-'); return string.IsNullOrEmpty(v) ? "file" : v.Substring(0, Math.Min(v.Length, 80)); }
        private static void AddFact(ParsedPrado result, string label, string value, string original)
        {
            if (string.IsNullOrWhiteSpace(label) || string.IsNullOrWhiteSpace(value)) return;
            if (!result.Facts.Any(x => x.Label == label && x.Value == value)) result.Facts.Add(new PradoFact { Label = label, Value = value, OriginalLabel = original });
        }
        private static bool IsImage(string ext) => new[] { ".jpg", ".jpeg", ".png", ".gif", ".webp" }.Contains(ext, StringComparer.OrdinalIgnoreCase);
        private static string H(string value) => HttpUtility.HtmlEncode(value ?? "");
        private static int StableHash(string value) { unchecked { var h=23; foreach(var c in value ?? "") h=h*31+c; return h; } }
        private static void TryDelete(string path) { try { if (Directory.Exists(path)) Directory.Delete(path, true); else if (File.Exists(path)) File.Delete(path); } catch { } }
        private sealed class ParsedPrado { public string DocumentCode; public string Title; public string SourceName; public List<PradoFact> Facts = new List<PradoFact>(); public List<PreparedQuestion> PreparedQuestions = new List<PreparedQuestion>(); }
        private sealed class PradoFact { public string Label; public string Value; public string OriginalLabel; }
        private sealed class PreparedQuestion { public string Text; public List<PreparedOption> Options = new List<PreparedOption>(); }
        private sealed class PreparedOption { public string Key; public string Text; public bool IsCorrect; }
        private sealed class CopiedImage { public string FileName; public string RelativePath; public string Caption; }
    }
}
