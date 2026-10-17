using gzpegm.Helpers;
using gzpegm.Models;
using gzpegm.Models.ViewModels;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Entity;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;

namespace gzpegm.Services
{
    public class EducationPackageService
    {
        private static readonly HashSet<string> AllowedExtensions = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp",
            ".pdf", ".doc", ".docx", ".ppt", ".pptx", ".xls", ".xlsx",
            ".mp4", ".avi", ".mov", ".wmv", ".webm",
            ".html", ".htm", ".json"
        };

        private readonly GZPEGM1 db;
        private readonly HttpServerUtilityBase server;
        private readonly JsonSerializerSettings jsonSettings = new JsonSerializerSettings
        {
            ContractResolver = new CamelCasePropertyNamesContractResolver(),
            Formatting = Formatting.Indented,
            NullValueHandling = NullValueHandling.Ignore
        };

        public EducationPackageService(GZPEGM1 db, HttpServerUtilityBase server)
        {
            this.db = db ?? throw new ArgumentNullException(nameof(db));
            this.server = server ?? throw new ArgumentNullException(nameof(server));
        }

        public long MaximumPackageBytes => ReadLimit("EducationPackageMaxBytes", 100L * 1024 * 1024);
        public long MaximumExtractedBytes => ReadLimit("EducationPackageMaxExtractedBytes", 250L * 1024 * 1024);

        public byte[] Export(EducationPackageExportViewModel request, int userId, out string fileName)
        {
            if (request == null) throw new ArgumentNullException(nameof(request));
            var course = db.Courses.AsNoTracking().Include(x => x.Categories).SingleOrDefault(x => x.CourseId == request.CourseId);
            if (course == null) throw new InvalidOperationException("Kurs bulunamadı.");

            var contents = db.CourseContents.AsNoTracking().Where(x => x.CourseId == course.CourseId).OrderBy(x => x.ContentId).ToList();
            var exams = db.Exam.AsNoTracking().Where(x => x.CourseId == course.CourseId).OrderBy(x => x.ExamId).ToList();
            var examIds = exams.Select(x => x.ExamId).ToList();
            var questions = db.Question.AsNoTracking().Where(x => examIds.Contains(x.ExamId)).OrderBy(x => x.ExamId).ThenBy(x => x.SortOrder).ToList();
            var questionIds = questions.Select(x => x.QuestionId).ToList();
            var options = db.QuestionOption.AsNoTracking().Where(x => questionIds.Contains(x.QuestionId)).OrderBy(x => x.SortOrder).ToList();
            var media = db.QuestionMedia.AsNoTracking().Where(x => questionIds.Contains(x.QuestionId)).OrderBy(x => x.SortOrder).ToList();

            var courseKey = "course-" + course.CourseId;
            var manifest = new EducationPackageManifest
            {
                PackageCode = Required(request.PackageCode, "Paket kodu"),
                PackageTitle = course.CourseTitle,
                PackageVersion = Required(request.PackageVersion, "Paket sürümü"),
                Language = string.IsNullOrWhiteSpace(request.Language) ? "tr-TR" : request.Language.Trim(),
                CreatedAt = DateTime.UtcNow,
                Source = request.Source,
                SourceUrl = request.SourceUrl,
                DocumentCode = request.DocumentCode,
                CountryName = request.CountryName,
                DocumentType = request.DocumentType,
                RequiresInternet = false
            };
            var courseDto = new EducationPackageCourse
            {
                SourceId = course.CourseId,
                CourseKey = courseKey,
                CourseTitle = course.CourseTitle,
                CourseDescription = course.CourseDescription,
                CategoryName = course.Categories?.CategoryName,
                IsActive = course.IsActive
            };

            var contentDtos = contents.Select((x, index) => new EducationPackageContent
            {
                SourceId = x.ContentId,
                ContentKey = "content-" + x.ContentId,
                CourseKey = courseKey,
                ContentType = x.ContentType,
                ContentTitle = x.ContentTitle,
                ContentDescription = x.ContentDescription,
                SortOrder = index + 1
            }).ToList();
            var examDtos = exams.Select(x => new EducationPackageExam
            {
                SourceId = x.ExamId,
                ExamKey = "exam-" + x.ExamId,
                CourseKey = courseKey,
                Title = x.Title,
                Description = x.Description,
                DurationMinutes = x.DurationMinutes,
                PassingScore = x.PassingScore,
                IsActive = x.IsActive
            }).ToList();
            var questionDtos = questions.Select(q => new EducationPackageQuestion
            {
                SourceId = q.QuestionId,
                QuestionKey = "question-" + q.QuestionId,
                ExamKey = "exam-" + q.ExamId,
                Text = q.Text,
                QuestionType = q.QuestionType,
                Points = q.Points,
                SortOrder = q.SortOrder,
                Options = options.Where(o => o.QuestionId == q.QuestionId).Select(o => new EducationPackageOption
                {
                    SourceId = o.OptionId,
                    OptionKey = "option-" + o.OptionId,
                    Text = o.Text,
                    IsCorrect = o.IsCorrect,
                    SortOrder = o.SortOrder
                }).ToList(),
                Media = media.Where(m => m.QuestionId == q.QuestionId).Select(m => new EducationPackageMedia
                {
                    SourceId = m.MediaId,
                    MediaKey = "media-" + m.MediaId,
                    MediaType = m.MediaType,
                    SortOrder = m.SortOrder
                }).ToList()
            }).ToList();

            using (var output = new MemoryStream())
            {
                using (var archive = new ZipArchive(output, ZipArchiveMode.Create, true, Encoding.UTF8))
                {
                    AddJson(archive, "manifest.json", manifest);
                    AddJson(archive, "exam.json", examDtos);

                    AddExportFile(archive, course.CoverImage, "course-cover", value => courseDto.CoverFileName = value);
                    AddExportFile(archive, course.ResourceFile, "course-resource", value => courseDto.ResourceFileName = value);
                    foreach (var pair in contents.Zip(contentDtos, (entity, dto) => new { entity, dto }))
                        AddExportFile(archive, pair.entity.FilePath, pair.dto.ContentKey, value => pair.dto.FileName = value);
                    foreach (var q in questionDtos)
                        foreach (var m in q.Media)
                        {
                            var entity = media.Single(x => x.MediaId == m.SourceId.Value);
                            AddExportFile(archive, entity.MediaPath, m.MediaKey, value => m.FileName = value, true);
                        }

                    AddJson(archive, "course.json", courseDto);
                    AddJson(archive, "contents.json", contentDtos);
                    AddJson(archive, "questions.json", questionDtos);
                }
                if (output.Length > MaximumPackageBytes) throw new InvalidOperationException("Oluşan paket izin verilen boyutu aşıyor.");
                fileName = SafeToken(manifest.PackageCode) + "_v" + SafeToken(manifest.PackageVersion) + ".cezapkg";
                return output.ToArray();
            }
        }

        public EducationPackageImportResult Import(Stream packageStream, string originalFileName, EducationPackageImportMode mode, int userId)
        {
            if (packageStream == null) throw new ArgumentNullException(nameof(packageStream));
            var tempRoot = Path.Combine(Path.GetTempPath(), "CEZAM", "EducationPackages", Guid.NewGuid().ToString("N"));
            Directory.CreateDirectory(tempRoot);
            var createdFiles = new List<string>();
            EducationPackageManifest manifest = null;
            try
            {
                var packagePath = Path.Combine(tempRoot, "package.cezapkg");
                CopyWithLimit(packageStream, packagePath, MaximumPackageBytes);
                ExtractSecurely(packagePath, tempRoot);

                manifest = ReadJson<EducationPackageManifest>(tempRoot, "manifest.json");
                var courseDto = ReadJson<EducationPackageCourse>(tempRoot, "course.json");
                var contents = ReadJson<List<EducationPackageContent>>(tempRoot, "contents.json") ?? new List<EducationPackageContent>();
                var exams = ReadJson<List<EducationPackageExam>>(tempRoot, "exam.json") ?? new List<EducationPackageExam>();
                var questions = ReadJson<List<EducationPackageQuestion>>(tempRoot, "questions.json") ?? new List<EducationPackageQuestion>();
                ValidatePackage(manifest, courseDto, contents, exams, questions, tempRoot);

                var duplicate = HasSuccessfulImport(manifest.PackageCode, manifest.PackageVersion);
                if (duplicate && mode == EducationPackageImportMode.SkipIfExists)
                {
                    var skipped = new EducationPackageImportResult { Success = true, Skipped = true, Message = "Paket daha önce içe aktarıldığı için atlandı." };
                    WriteLog(manifest, userId, originalFileName, "Skipped", skipped.Message, null, null);
                    return skipped;
                }
                if (duplicate) throw new InvalidOperationException("Aynı paket kodu ve sürümü daha önce başarıyla içe aktarılmış.");
                if (mode == EducationPackageImportMode.UpdateExisting)
                    throw new InvalidOperationException("Mevcut kursu güncelleme modu güvenlik nedeniyle ilk sürümde kapalıdır. Yeni kurs modunu kullanın.");

                int courseId;
                int? firstExamId = null;
                using (var transaction = db.Database.BeginTransaction())
                {
                    try
                    {
                        var categoryName = string.IsNullOrWhiteSpace(courseDto.CategoryName) ? "Paket Eğitimleri" : courseDto.CategoryName.Trim();
                        var category = db.Categories.FirstOrDefault(x => x.CategoryName == categoryName);
                        if (category == null)
                        {
                            category = new Categories { CategoryName = categoryName, Description = "Eğitim paketi içe aktarımı", IsActive = true };
                            db.Categories.Add(category);
                            db.SaveChanges();
                        }

                        var course = new Courses
                        {
                            CourseTitle = courseDto.CourseTitle,
                            CourseDescription = courseDto.CourseDescription,
                            CategoryId = category.CategoryId,
                            CreatedBy = userId,
                            CreatedDate = DateTime.Now,
                            IsActive = false,
                            IsDeleted = false,
                            CoverImage = CopyImportedFile(tempRoot, courseDto.CoverFileName, "~/files/Egitim/", createdFiles, false),
                            ResourceFile = CopyImportedFile(tempRoot, courseDto.ResourceFileName, "~/files/Egitim/", createdFiles, false)
                        };
                        db.Courses.Add(course);
                        db.SaveChanges();
                        courseId = course.CourseId;

                        foreach (var contentDto in contents.OrderBy(x => x.SortOrder))
                            db.CourseContents.Add(new CourseContents
                            {
                                CourseId = courseId,
                                ContentType = contentDto.ContentType,
                                ContentTitle = contentDto.ContentTitle,
                                ContentDescription = contentDto.ContentDescription,
                                FilePath = CopyImportedFile(tempRoot, contentDto.FileName, "~/files/Egitim/", createdFiles, false),
                                CreatedDate = DateTime.Now
                            });
                        db.SaveChanges();

                        var examMap = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
                        foreach (var examDto in exams)
                        {
                            var exam = new Exam
                            {
                                CourseId = courseId, Title = examDto.Title, Description = examDto.Description,
                                DurationMinutes = examDto.DurationMinutes, PassingScore = examDto.PassingScore,
                                IsActive = false, IsArchived = false, CreatedAt = DateTime.Now
                            };
                            db.Exam.Add(exam);
                            db.SaveChanges();
                            examMap.Add(examDto.ExamKey, exam.ExamId);
                            if (!firstExamId.HasValue) firstExamId = exam.ExamId;
                        }

                        foreach (var questionDto in questions.OrderBy(x => x.SortOrder))
                        {
                            var question = new Question
                            {
                                ExamId = examMap[questionDto.ExamKey], Text = questionDto.Text,
                                QuestionType = questionDto.QuestionType, Points = questionDto.Points,
                                SortOrder = questionDto.SortOrder, IsActive = false
                            };
                            db.Question.Add(question);
                            db.SaveChanges();
                            foreach (var option in questionDto.Options.OrderBy(x => x.SortOrder))
                                db.QuestionOption.Add(new QuestionOption
                                {
                                    QuestionId = question.QuestionId, Text = option.Text,
                                    IsCorrect = option.IsCorrect, SortOrder = option.SortOrder
                                });
                            foreach (var mediaDto in questionDto.Media.OrderBy(x => x.SortOrder))
                            {
                                var stored = CopyImportedFile(tempRoot, mediaDto.FileName, "~/files/", createdFiles, true);
                                db.QuestionMedia.Add(new QuestionMedia
                                {
                                    QuestionId = question.QuestionId, MediaType = mediaDto.MediaType,
                                    MediaPath = stored, SortOrder = mediaDto.SortOrder, CreatedAt = DateTime.Now
                                });
                            }
                        }
                        db.SaveChanges();
                        transaction.Commit();
                    }
                    catch
                    {
                        transaction.Rollback();
                        DeleteFiles(createdFiles);
                        throw;
                    }
                }

                var result = new EducationPackageImportResult { Success = true, CourseId = courseId, ExamId = firstExamId, Message = "Paket taslak eğitim olarak içe aktarıldı. Yayınlamadan önce kontrol edilmelidir." };
                WriteLog(manifest, userId, originalFileName, "Success", result.Message, courseId, firstExamId);
                return result;
            }
            catch (Exception ex)
            {
                DeleteFiles(createdFiles);
                try { WriteLog(manifest, userId, originalFileName, "Failed", SafeError(ex), null, null); } catch { }
                throw new InvalidOperationException(SafeError(ex));
            }
            finally
            {
                try { if (Directory.Exists(tempRoot)) Directory.Delete(tempRoot, true); } catch { }
            }
        }

        public List<EducationPackageImportLog> GetLogs()
        {
            return db.Database.SqlQuery<EducationPackageImportLog>("SELECT TOP 500 * FROM dbo.EducationPackageImportLog ORDER BY ImportedDate DESC").ToList();
        }

        private void ValidatePackage(EducationPackageManifest manifest, EducationPackageCourse course, List<EducationPackageContent> contents, List<EducationPackageExam> exams, List<EducationPackageQuestion> questions, string root)
        {
            if (manifest == null || string.IsNullOrWhiteSpace(manifest.PackageCode) || string.IsNullOrWhiteSpace(manifest.PackageVersion)) throw new InvalidOperationException("manifest.json paket kodu ve sürümü içermelidir.");
            if (manifest.RequiresInternet) throw new InvalidOperationException("İnternet gerektiren paketler kabul edilmez.");
            if (course == null || string.IsNullOrWhiteSpace(course.CourseKey) || string.IsNullOrWhiteSpace(course.CourseTitle)) throw new InvalidOperationException("course.json geçersiz.");
            EnsureUnique(contents.Select(x => x.ContentKey), "contentKey");
            EnsureUnique(exams.Select(x => x.ExamKey), "examKey");
            EnsureUnique(questions.Select(x => x.QuestionKey), "questionKey");
            var examKeys = new HashSet<string>(exams.Select(x => x.ExamKey), StringComparer.OrdinalIgnoreCase);
            foreach (var q in questions)
            {
                if (!examKeys.Contains(q.ExamKey)) throw new InvalidOperationException("Bir soru bilinmeyen examKey içeriyor.");
                EnsureUnique((q.Options ?? new List<EducationPackageOption>()).Select(x => x.OptionKey), "optionKey");
                EnsureUnique((q.Media ?? new List<EducationPackageMedia>()).Select(x => x.MediaKey), "mediaKey");
                q.Options = q.Options ?? new List<EducationPackageOption>();
                q.Media = q.Media ?? new List<EducationPackageMedia>();
                foreach (var m in q.Media) RequirePackageFile(root, m.FileName);
            }
            RequireOptionalPackageFile(root, course.CoverFileName);
            RequireOptionalPackageFile(root, course.ResourceFileName);
            foreach (var c in contents) RequireOptionalPackageFile(root, c.FileName);
        }

        private void ExtractSecurely(string packagePath, string destination)
        {
            long total = 0;
            using (var archive = ZipFile.OpenRead(packagePath))
                foreach (var entry in archive.Entries)
                {
                    var name = (entry.FullName ?? "").Replace('\\', '/');
                    if (string.IsNullOrWhiteSpace(name)) continue;
                    if (name.StartsWith("/", StringComparison.Ordinal) || name.Contains(":") || name.Split('/').Any(x => x == "..")) throw new InvalidOperationException("Paket güvenli olmayan dosya yolu içeriyor.");
                    if (name.EndsWith("/", StringComparison.Ordinal)) continue;
                    var extension = Path.GetExtension(name);
                    if (!AllowedExtensions.Contains(extension)) throw new InvalidOperationException("Pakette izin verilmeyen dosya türü var: " + extension);
                    total += entry.Length;
                    if (total > MaximumExtractedBytes) throw new InvalidOperationException("Paket açılmış boyut sınırını aşıyor.");
                    var fullPath = Path.GetFullPath(Path.Combine(destination, name.Replace('/', Path.DirectorySeparatorChar)));
                    var root = Path.GetFullPath(destination).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
                    if (!fullPath.StartsWith(root, StringComparison.OrdinalIgnoreCase)) throw new InvalidOperationException("Paket dosya yolu geçersiz.");
                    Directory.CreateDirectory(Path.GetDirectoryName(fullPath));
                    using (var input = entry.Open()) using (var output = File.Create(fullPath)) input.CopyTo(output);
                }
        }

        private void AddExportFile(ZipArchive archive, string sourceValue, string stableName, Action<string> setPackageName, bool questionMedia = false)
        {
            if (string.IsNullOrWhiteSpace(sourceValue)) return;
            var physical = ResolvePhysicalFile(sourceValue, questionMedia);
            if (physical == null || !File.Exists(physical)) throw new FileNotFoundException("Paketlenecek dosya bulunamadı: " + Path.GetFileName(sourceValue));
            var extension = Path.GetExtension(physical).ToLowerInvariant();
            if (!AllowedExtensions.Contains(extension)) throw new InvalidOperationException("Dosya türü pakete eklenemez: " + extension);
            var packageName = "images/" + SafeToken(stableName) + extension;
            var entry = archive.CreateEntry(packageName, CompressionLevel.Optimal);
            if (string.Equals(extension, ".html", StringComparison.OrdinalIgnoreCase) || string.Equals(extension, ".htm", StringComparison.OrdinalIgnoreCase))
            {
                var html = EmbedLocalImages(File.ReadAllText(physical, Encoding.UTF8), physical);
                using (var writer = new StreamWriter(entry.Open(), new UTF8Encoding(false))) writer.Write(html);
            }
            else
            {
                using (var input = File.OpenRead(physical)) using (var output = entry.Open()) input.CopyTo(output);
            }
            setPackageName(packageName);
        }

        private string EmbedLocalImages(string html, string htmlPhysicalPath)
        {
            if (string.IsNullOrWhiteSpace(html)) return html;
            return Regex.Replace(html, "(?<attr>\\bsrc\\s*=\\s*)(?<quote>[\"'])(?<url>.*?)(\\k<quote>)", match =>
            {
                var url = HttpUtility.HtmlDecode(match.Groups["url"].Value ?? "");
                if (string.IsNullOrWhiteSpace(url)
                    || url.StartsWith("data:", StringComparison.OrdinalIgnoreCase)
                    || url.StartsWith("http://", StringComparison.OrdinalIgnoreCase)
                    || url.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
                    return match.Value;

                var cleanUrl = url.Split('#')[0].Split('?')[0];
                var physical = ResolveEmbeddedImagePath(cleanUrl, htmlPhysicalPath);
                if (physical == null || !File.Exists(physical)) return match.Value;
                var imageExtension = Path.GetExtension(physical).ToLowerInvariant();
                if (!IsEmbeddableImage(imageExtension)) return match.Value;

                var data = Convert.ToBase64String(File.ReadAllBytes(physical));
                return match.Groups["attr"].Value + match.Groups["quote"].Value + "data:" + ImageMime(imageExtension) + ";base64," + data + match.Groups["quote"].Value;
            }, RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);
        }

        private string ResolveEmbeddedImagePath(string url, string htmlPhysicalPath)
        {
            var normalized = (url ?? "").Replace('\\', '/').Trim();
            if (string.IsNullOrWhiteSpace(normalized)) return null;

            if (normalized.StartsWith("~/") || normalized.StartsWith("/"))
                return FileStorageHelper.MapPath(server, normalized.StartsWith("~") ? normalized : "~" + normalized);

            var htmlDir = Path.GetDirectoryName(htmlPhysicalPath);
            var local = Path.GetFullPath(Path.Combine(htmlDir ?? "", normalized.Replace('/', Path.DirectorySeparatorChar)));
            if (File.Exists(local)) return local;

            return FileStorageHelper.MapPath(server, "~/files/Egitim/" + normalized);
        }

        private static bool IsEmbeddableImage(string extension)
        {
            return new[] { ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp" }.Contains(extension, StringComparer.OrdinalIgnoreCase);
        }

        private static string ImageMime(string extension)
        {
            switch ((extension ?? "").ToLowerInvariant())
            {
                case ".jpg":
                case ".jpeg": return "image/jpeg";
                case ".png": return "image/png";
                case ".gif": return "image/gif";
                case ".bmp": return "image/bmp";
                case ".webp": return "image/webp";
                default: return "application/octet-stream";
            }
        }

        private string ResolvePhysicalFile(string value, bool questionMedia)
        {
            if (string.IsNullOrWhiteSpace(value) || value.StartsWith("http://", StringComparison.OrdinalIgnoreCase) || value.StartsWith("https://", StringComparison.OrdinalIgnoreCase)) return null;
            var clean = value.Trim();
            if (clean.StartsWith("~/") || clean.StartsWith("/")) return FileStorageHelper.MapPath(server, clean.StartsWith("~") ? clean : "~" + clean);
            var first = FileStorageHelper.MapPath(server, questionMedia ? "~/files/" + clean : "~/files/Egitim/" + clean);
            if (File.Exists(first)) return first;
            return FileStorageHelper.MapPath(server, "~/files/" + clean);
        }

        private string CopyImportedFile(string tempRoot, string packageName, string targetRoot, List<string> created, bool returnUrl)
        {
            if (string.IsNullOrWhiteSpace(packageName)) return null;
            var source = SafePackageFile(tempRoot, packageName);
            var extension = Path.GetExtension(source).ToLowerInvariant();
            var targetDir = FileStorageHelper.MapPath(server, targetRoot);
            Directory.CreateDirectory(targetDir);
            var storedName = Guid.NewGuid().ToString("N") + extension;
            var target = Path.Combine(targetDir, storedName);
            File.Copy(source, target, false);
            created.Add(target);
            return returnUrl ? "/files/" + storedName : storedName;
        }

        private string SafePackageFile(string root, string packageName)
        {
            var relative = packageName.Replace('\\', '/');
            if (!relative.StartsWith("images/", StringComparison.OrdinalIgnoreCase) || relative.Split('/').Any(x => x == "..")) throw new InvalidOperationException("Paket dosya yolu geçersiz.");
            var full = Path.GetFullPath(Path.Combine(root, relative.Replace('/', Path.DirectorySeparatorChar)));
            var expectedRoot = Path.GetFullPath(root).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            if (!full.StartsWith(expectedRoot, StringComparison.OrdinalIgnoreCase) || !File.Exists(full)) throw new FileNotFoundException("Paket dosyası eksik: " + Path.GetFileName(packageName));
            return full;
        }

        private T ReadJson<T>(string root, string name)
        {
            var path = Path.Combine(root, name);
            if (!File.Exists(path)) throw new InvalidOperationException(name + " pakette bulunamadı.");
            try { return JsonConvert.DeserializeObject<T>(File.ReadAllText(path, Encoding.UTF8)); }
            catch (JsonException) { throw new InvalidOperationException(name + " geçerli JSON içermiyor."); }
        }

        private void AddJson(ZipArchive archive, string name, object value)
        {
            var entry = archive.CreateEntry(name, CompressionLevel.Optimal);
            using (var writer = new StreamWriter(entry.Open(), new UTF8Encoding(false))) writer.Write(JsonConvert.SerializeObject(value, jsonSettings));
        }

        private bool HasSuccessfulImport(string code, string version)
        {
            return db.Database.SqlQuery<int>(@"
SELECT COUNT(1)
FROM dbo.EducationPackageImportLog l
INNER JOIN dbo.Courses c ON c.CourseId = l.ImportedCourseId
WHERE l.PackageCode = @p0
  AND l.PackageVersion = @p1
  AND l.Status = 'Success'
  AND (c.IsDeleted IS NULL OR c.IsDeleted = 0)", code, version).Single() > 0;
        }

        private void WriteLog(EducationPackageManifest manifest, int userId, string fileName, string status, string message, int? courseId, int? examId)
        {
            db.Database.ExecuteSqlCommand(@"INSERT INTO dbo.EducationPackageImportLog
(PackageCode,PackageTitle,PackageVersion,SourceDocumentCode,ImportedCourseId,ImportedExamId,ImportedByUserId,ImportedDate,FileName,Status,Message)
VALUES(@p0,@p1,@p2,@p3,@p4,@p5,@p6,GETDATE(),@p7,@p8,@p9)",
                (object)manifest?.PackageCode ?? DBNull.Value,
                (object)manifest?.PackageTitle ?? DBNull.Value,
                (object)manifest?.PackageVersion ?? DBNull.Value,
                (object)manifest?.DocumentCode ?? DBNull.Value,
                (object)courseId ?? DBNull.Value, (object)examId ?? DBNull.Value, userId,
                Path.GetFileName(fileName ?? ""), status, message);
        }

        private static void CopyWithLimit(Stream input, string outputPath, long limit)
        {
            long total = 0; var buffer = new byte[81920];
            using (var output = File.Create(outputPath))
            {
                int read;
                while ((read = input.Read(buffer, 0, buffer.Length)) > 0)
                {
                    total += read; if (total > limit) throw new InvalidOperationException("Paket boyut sınırını aşıyor.");
                    output.Write(buffer, 0, read);
                }
            }
        }

        private static void EnsureUnique(IEnumerable<string> keys, string field)
        {
            var list = keys.ToList();
            var nonEmpty = list.Where(x => !string.IsNullOrWhiteSpace(x)).ToList();
            if (nonEmpty.Count != list.Count || nonEmpty.Count != nonEmpty.Distinct(StringComparer.OrdinalIgnoreCase).Count()) throw new InvalidOperationException(field + " değerleri boş veya tekrarlı olamaz.");
        }

        private void RequirePackageFile(string root, string name) { if (string.IsNullOrWhiteSpace(name)) throw new InvalidOperationException("Soru medyası dosya adı eksik."); SafePackageFile(root, name); }
        private void RequireOptionalPackageFile(string root, string name) { if (!string.IsNullOrWhiteSpace(name)) SafePackageFile(root, name); }
        private static string Required(string value, string label) { if (string.IsNullOrWhiteSpace(value)) throw new InvalidOperationException(label + " zorunludur."); return value.Trim(); }
        private static string SafeToken(string value) { return new string((value ?? "package").Where(c => char.IsLetterOrDigit(c) || c == '-' || c == '_').ToArray()); }
        private static string SafeError(Exception ex) { return ex is InvalidOperationException || ex is FileNotFoundException ? ex.Message : "Paket işlenirken beklenmeyen bir hata oluştu."; }
        private static void DeleteFiles(IEnumerable<string> files) { foreach (var file in files) try { if (File.Exists(file)) File.Delete(file); } catch { } }
        private static long ReadLimit(string key, long defaultValue) { long value; return long.TryParse(ConfigurationManager.AppSettings[key], out value) && value > 0 ? value : defaultValue; }
    }
}
