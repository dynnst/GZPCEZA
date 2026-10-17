using gzpegm.Cont;
using gzpegm.Helpers;
using gzpegm.Models;
using gzpegm.Models.ViewModels;
using System;
using System.Data.Entity;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize(Users = "2,6")]
    public class QuestionController : Controller
    {
        private GZPEGM1 db = new GZPEGM1();

        #region AUTH

        private E_User GetCurrentUser()
        {
            try
            {
                HttpCookie cookie = Request.Cookies["Token"];
                if (cookie == null) return null;

                Token token = new Token();
                var data = token.GetToken(cookie.Value);
                if (data == null) return null;

                int userId;
                if (!int.TryParse(data.fldUserId?.ToString(), out userId)) return null;

                User user = new User();
                return user.GetUserById(userId);
            }
            catch
            {
                return null;
            }
        }

        private bool HasAccess(E_User user)
        {
            return user != null && (user.Role == "Admin" || user.Role == "Teacher");
        }

        private bool CanModifyExam(E_User user, int examId)
        {
            if (!HasAccess(user)) return false;
            if (user.Role == "Admin") return db.Exam.Any(e => e.ExamId == examId);

            return db.Exam
                .Join(db.Courses, e => e.CourseId, c => c.CourseId, (e, c) => new { e.ExamId, c.CreatedBy })
                .Any(x => x.ExamId == examId && x.CreatedBy == user.fldId);
        }

        private bool CanModifyQuestion(E_User user, int questionId)
        {
            var examId = db.Question
                .Where(q => q.QuestionId == questionId)
                .Select(q => (int?)q.ExamId)
                .FirstOrDefault();

            return examId.HasValue && CanModifyExam(user, examId.Value);
        }

        #endregion

        // ===================== INDEX =====================
        public ActionResult Index(int? examId = null)
        {
            var user = GetCurrentUser();
            if (user == null)
            {
                return RedirectToAction("Login", "Account");
            }

            if (!HasAccess(user))
            {
                return RedirectToAction("Index", "Home");
            }

            if (!examId.HasValue || examId.Value <= 0)
            {
                var defaultExam = (from e in db.Exam
                                   where e.IsArchived != true
                                   orderby e.ExamId descending
                                   select (int?)e.ExamId).FirstOrDefault();

                if (defaultExam.HasValue && CanModifyExam(user, defaultExam.Value))
                {
                    return RedirectToAction("Index", new { examId = defaultExam.Value });
                }

                TempData["msgInfo"] = "Lütfen sorularını yönetmek istediğiniz sınavı seçin.";
                return RedirectToAction("Index", "Exam");
            }

            int currentExamId = examId.Value;
            ViewBag.ExamId = currentExamId;

            var examContext = (from exam in db.Exam
                               join course in db.Courses on exam.CourseId equals course.CourseId
                               where exam.ExamId == currentExamId
                               select new
                               {
                                   exam.ExamId,
                                   ExamTitle = exam.Title,
                                   course.CourseId,
                                   CourseTitle = course.CourseTitle,
                                   CourseIsActive = course.IsActive
                               }).FirstOrDefault();

            if (examContext == null)
            {
                TempData["msgError"] = "Sınav veya sınavın bağlı olduğu kurs bulunamadı.";
                return RedirectToAction("Index", "Exam");
            }

            if (!CanModifyExam(user, currentExamId))
            {
                TempData["msgError"] = "Bu sınavın sorularını görüntüleme yetkiniz yok.";
                return RedirectToAction("Index", "Exam");
            }

            ViewBag.ExamTitle = examContext.ExamTitle;
            ViewBag.CourseId = examContext.CourseId;
            ViewBag.CourseTitle = examContext.CourseTitle;
            ViewBag.CourseIsActive = examContext.CourseIsActive;

            System.Collections.Generic.List<QuestionViewModel> list = null;

            try
            {
                list = db.Question
                    .Where(x => x.ExamId == currentExamId)
                    .OrderBy(x => x.SortOrder)
                    .Select(q => new QuestionViewModel
                    {
                        QuestionId = q.QuestionId,
                        QuestionText = q.Text,
                        QuestionType = q.QuestionType == 1 ? "MultipleChoice"
                                       : q.QuestionType == 2 ? "TrueFalse"
                                       : q.QuestionType == 3 ? "Text"
                                       : "MultipleChoice",
                        Points = q.Points,
                        SortOrder = q.SortOrder,
                        IsActive = q.IsActive ?? true,

                        Options = db.QuestionOption
                            .Where(o => o.QuestionId == q.QuestionId)
                            .OrderBy(o => o.SortOrder)
                            .Select(o => new QuestionOptionViewModel
                            {
                                OptionId = o.OptionId,
                                QuestionId = o.QuestionId,
                                OptionText = o.Text,
                                IsCorrect = o.IsCorrect,
                                SortOrder = o.SortOrder
                            }).ToList(),

                        MediaFiles = db.QuestionMedia
                            .Where(m => m.QuestionId == q.QuestionId)
                            .OrderBy(m => m.SortOrder)
                            .Select(m => new QuestionMediaViewModel
                            {
                                MediaId = m.MediaId,
                                MediaType = m.MediaType,
                                MediaPath = m.MediaPath
                            }).ToList()
                    }).ToList();
            }
            catch (Exception ex)
            {
                if (ex.InnerException != null && ex.InnerException.Message != null &&
                    ex.InnerException.Message.IndexOf("Invalid column name 'IsActive'", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    list = db.Question
                        .Where(x => x.ExamId == currentExamId)
                        .OrderBy(x => x.SortOrder)
                        .Select(q => new QuestionViewModel
                        {
                            QuestionId = q.QuestionId,
                            QuestionText = q.Text,
                            QuestionType = q.QuestionType == 1 ? "MultipleChoice"
                                           : q.QuestionType == 2 ? "TrueFalse"
                                           : q.QuestionType == 3 ? "Text"
                                           : "MultipleChoice",
                            Points = q.Points,
                            SortOrder = q.SortOrder,
                            IsActive = true,

                            Options = db.QuestionOption
                                .Where(o => o.QuestionId == q.QuestionId)
                                .OrderBy(o => o.SortOrder)
                                .Select(o => new QuestionOptionViewModel
                                {
                                    OptionId = o.OptionId,
                                    QuestionId = o.QuestionId,
                                    OptionText = o.Text,
                                    IsCorrect = o.IsCorrect,
                                    SortOrder = o.SortOrder
                                }).ToList(),

                            MediaFiles = db.QuestionMedia
                                .Where(m => m.QuestionId == q.QuestionId)
                                .OrderBy(m => m.SortOrder)
                                .Select(m => new QuestionMediaViewModel
                                {
                                    MediaId = m.MediaId,
                                    MediaType = m.MediaType,
                                    MediaPath = m.MediaPath
                                }).ToList()
                        }).ToList();
                }
                else
                {
                    throw;
                }
            }

            return View(list ?? new System.Collections.Generic.List<QuestionViewModel>());
        }

        // ===================== CREATE (POST) =====================
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult CreateQuestion(QuestionViewModel model)
        {
            var user = GetCurrentUser();
            if (!CanModifyExam(user, model.ExamId))
            {
                TempData["msgError"] = "Bu sınava soru ekleme yetkiniz yok.";
                return RedirectToAction("Index", new { examId = model.ExamId });
            }

            if (!ModelState.IsValid)
            {
                var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToArray();
                TempData["CreateErrors"] = errors;
                TempData["ShowCreateModal"] = true;
                TempData["CreateModel"] = model;
                return RedirectToAction("Index", new { examId = model.ExamId });
            }

            var question = new Question
            {
                ExamId = model.ExamId,
                Text = model.QuestionText,
                QuestionType = GetQuestionTypeByte(model.QuestionType),
                Points = model.Points,
                SortOrder = model.SortOrder,
                IsActive = true
            };

            db.Question.Add(question);
            db.SaveChanges();

            // Şıkları kaydet
            if (model.Options != null && model.Options.Any())
            {
                int optSort = 1;
                foreach (var opt in model.Options)
                {
                    if (string.IsNullOrWhiteSpace(opt.OptionText)) { optSort++; continue; }

                    db.QuestionOption.Add(new QuestionOption
                    {
                        QuestionId = question.QuestionId,
                        Text = opt.OptionText,
                        IsCorrect = opt.IsCorrect,
                        SortOrder = opt.SortOrder != 0 ? opt.SortOrder : optSort
                    });
                    optSort++;
                }
                db.SaveChanges();
            }

            SaveMediaFiles(question.QuestionId, model);

            TempData["msgSuccess"] = "Soru başarıyla eklendi.";
            return RedirectToAction("Index", new { examId = model.ExamId });
        }

        // ===================== GET DETAILS (EDIT) =====================
        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult GetQuestionDetails(int questionId)
        {
            var user = GetCurrentUser();
            if (!CanModifyQuestion(user, questionId))
                return Json(new { success = false, message = "Bu soruyu görüntüleme yetkiniz yok." });

            var q = db.Question
                .Include(x => x.QuestionOption)
                .FirstOrDefault(x => x.QuestionId == questionId);

            if (q == null)
                return Json(new { success = false });

            var data = new
            {
                QuestionId = q.QuestionId,
                QuestionText = q.Text,
                QuestionType = GetQuestionTypeString(q.QuestionType),
                Points = q.Points,
                SortOrder = q.SortOrder,
                Options = q.QuestionOption
                    .OrderBy(o => o.SortOrder)
                    .Select(o => new
                    {
                        o.OptionId,
                        OptionText = o.Text,
                        o.IsCorrect
                    }).ToList(),
                MediaFiles = db.QuestionMedia
                    .Where(m => m.QuestionId == q.QuestionId)
                    .Select(m => new
                    {
                        m.MediaId,
                        m.MediaType,
                        m.MediaPath
                    }).ToList()
            };

            return Json(new { success = true, question = data });
        }

        // ===================== EDIT - KONTROLLÜ DÜZENLEME =====================
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult EditQuestion(QuestionViewModel model)
        {
            var user = GetCurrentUser();
            if (!CanModifyQuestion(user, model.QuestionId))
            {
                TempData["msgError"] = "Bu soruyu düzenleme yetkiniz yok.";
                return RedirectToAction("Index", new { examId = model.ExamId });
            }

            if (!ModelState.IsValid)
            {
                var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToArray();
                TempData["EditErrors"] = errors;
                TempData["ShowEditModal"] = model.QuestionId;
                TempData["EditModel"] = model;
                return RedirectToAction("Index", new { examId = model.ExamId });
            }

            var q = db.Question.FirstOrDefault(x => x.QuestionId == model.QuestionId);

            if (q == null)
            {
                TempData["msgError"] = "Soru bulunamadı.";
                return RedirectToAction("Index", new { examId = model.ExamId });
            }

            // ✅ Soruya cevap varsa, metin ve seçenekler DEĞİŞTİRİLEMEZ
            bool hasAnswers = db.Answer.Any(a => a.QuestionId == q.QuestionId);

            if (hasAnswers)
            {
                // Sadece puan ve sıra değiştirilir
                q.Points = model.Points;
                q.SortOrder = model.SortOrder;
                db.SaveChanges();

                TempData["msgWarning"] = "⚠️ Bu soruya cevaplar verilmiş. Sadece puan ve sıra değiştirildi. Soru metni ve seçenekler değiştirilemez.";
            }
            else
            {
                // Tamamen düzenleyebiliriz (cevap yoksa)
                q.Text = model.QuestionText;
                q.QuestionType = GetQuestionTypeByte(model.QuestionType);
                q.Points = model.Points;
                q.SortOrder = model.SortOrder;

                // Şıkları güncelle: önce mevcutları kaldır sonra yeni ekle
                var existing = db.QuestionOption.Where(o => o.QuestionId == q.QuestionId).ToList();
                if (existing.Any())
                {
                    db.QuestionOption.RemoveRange(existing);
                    db.SaveChanges();
                }

                if (model.Options != null && model.Options.Any())
                {
                    int optSort = 1;
                    foreach (var opt in model.Options)
                    {
                        if (string.IsNullOrWhiteSpace(opt.OptionText)) { optSort++; continue; }

                        db.QuestionOption.Add(new QuestionOption
                        {
                            QuestionId = q.QuestionId,
                            Text = opt.OptionText,
                            IsCorrect = opt.IsCorrect,
                            SortOrder = opt.SortOrder != 0 ? opt.SortOrder : optSort
                        });
                        optSort++;
                    }
                    db.SaveChanges();
                }

                // Yeni medya ekle
                SaveMediaFiles(q.QuestionId, model);

                TempData["msgSuccess"] = "✅ Soru başarıyla güncellendi.";
            }

            return RedirectToAction("Index", new { examId = q.ExamId });
        }

        // ===================== DELETE - PASIF YAPMA / AKTİF YAPMA =====================
        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult DeleteQuestion(int questionId)
        {
            try
            {
                var question = db.Question.FirstOrDefault(x => x.QuestionId == questionId);

                if (question == null)
                    return Json(new { success = false, message = "Soru bulunamadı" });

                var user = GetCurrentUser();
                if (!CanModifyExam(user, question.ExamId))
                    return Json(new { success = false, message = "Bu soruyu silme yetkiniz yok." });

                // ✅ Pasif soruya tıklanırsa: AKTİF YAP
                if (question.IsActive != true)
                {
                    question.IsActive = true;
                    db.SaveChanges();
                    return Json(new { success = true, message = "✅ Soru aktif duruma alındı" });
                }

                // ✅ Aktif soruya tıklanırsa: PASIF YAP VEYA SİL
                bool hasAnswers = db.Answer.Any(a => a.QuestionId == question.QuestionId);

                if (hasAnswers)
                {
                    // Pasif yap (cevaplar korunur, soru gizlenir)
                    question.IsActive = false;
                    db.SaveChanges();
                    return Json(new { success = true, message = "✅ Soru pasif duruma alındı (cevapları korunuyor)" });
                }
                else
                {
                    // Hiç cevap yoksa: TAMAMEN SİL
                    // 1. Medyaları sil
                    var mediaFiles = db.QuestionMedia.Where(m => m.QuestionId == questionId).ToList();
                    foreach (var media in mediaFiles)
                    {
                        string path = media.MediaPath != null && media.MediaPath.StartsWith("~/", StringComparison.Ordinal)
                            ? FileStorageHelper.MapPath(Server, media.MediaPath)
                            : FileStorageHelper.MapUrlToPhysicalPath(Server, media.MediaPath);

                        if (path != null && System.IO.File.Exists(path))
                            System.IO.File.Delete(path);
                    }
                    db.QuestionMedia.RemoveRange(mediaFiles);

                    // 2. Şıkları sil
                    var options = db.QuestionOption.Where(o => o.QuestionId == questionId).ToList();
                    db.QuestionOption.RemoveRange(options);

                    // 3. Soruyu sil
                    db.Question.Remove(question);
                    db.SaveChanges();

                    return Json(new { success = true, message = "✅ Soru tamamen silindi" });
                }
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = "❌ Hata: " + ex.Message });
            }
        }

        // ===================== DELETE MEDIA =====================
        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult DeleteQuestionMedia(int mediaId)
        {
            var media = db.QuestionMedia.Find(mediaId);
            if (media == null)
                return Json(new { success = false, message = "Medya bulunamadı" });

            var user = GetCurrentUser();
            if (!CanModifyQuestion(user, media.QuestionId))
                return Json(new { success = false, message = "Bu medyayı silme yetkiniz yok." });

            string path = media.MediaPath != null && media.MediaPath.StartsWith("~/", StringComparison.Ordinal)
                ? FileStorageHelper.MapPath(Server, media.MediaPath)
                : FileStorageHelper.MapUrlToPhysicalPath(Server, media.MediaPath);

            if (path != null && System.IO.File.Exists(path))
                System.IO.File.Delete(path);

            db.QuestionMedia.Remove(media);
            db.SaveChanges();

            return Json(new { success = true });
        }

        // ===================== MEDIA SAVE =====================
        private void SaveMediaFiles(int questionId, QuestionViewModel model)
        {
            string basePath = FileStorageHelper.MapPath(Server, "~/files/");
            if (!Directory.Exists(basePath))
                Directory.CreateDirectory(basePath);

            // Resimler
            if (model.ImageFiles != null)
            {
                foreach (var file in model.ImageFiles)
                {
                    if (file == null || file.ContentLength == 0) continue;

                    string ext = Path.GetExtension(file.FileName).ToLower();
                    if (!new[] { ".jpg", ".jpeg", ".png" }.Contains(ext)) continue;

                    string name = Guid.NewGuid() + ext;
                    file.SaveAs(Path.Combine(basePath, name));

                    db.QuestionMedia.Add(new QuestionMedia
                    {
                        QuestionId = questionId,
                        MediaType = 1,
                        MediaPath = "/files/" + name,
                        CreatedAt = DateTime.Now
                    });
                }
            }

            // Videolar
            if (model.VideoFiles != null)
            {
                foreach (var file in model.VideoFiles)
                {
                    if (file == null || file.ContentLength == 0) continue;

                    string ext = Path.GetExtension(file.FileName).ToLower();
                    if (ext != ".mp4") continue;

                    string name = Guid.NewGuid() + ext;
                    file.SaveAs(Path.Combine(basePath, name));

                    db.QuestionMedia.Add(new QuestionMedia
                    {
                        QuestionId = questionId,
                        MediaType = 2,
                        MediaPath = "/files/" + name,
                        CreatedAt = DateTime.Now
                    });
                }
            }

            db.SaveChanges();
        }

        #region HELPERS

        private string GetQuestionTypeString(byte? type)
        {
            return type == 1 ? "MultipleChoice" :
                   type == 2 ? "TrueFalse" :
                   type == 3 ? "Text" : "MultipleChoice";
        }

        private byte GetQuestionTypeByte(string type)
        {
            return type == "MultipleChoice" ? (byte)1 :
                   type == "TrueFalse" ? (byte)2 :
                   type == "Text" ? (byte)3 : (byte)1;
        }

        #endregion

        // ===================== GET CREATE =====================
        [HttpGet]
        public ActionResult Create(int examId = 0)
        {
            var user = GetCurrentUser();
            if (!HasAccess(user))
                return RedirectToAction("Index", new { examId = examId });

            if (examId == 0)
            {
                var firstExam = user.Role == "Admin"
                    ? db.Exam.OrderBy(e => e.ExamId).FirstOrDefault()
                    : (from e in db.Exam
                       join c in db.Courses on e.CourseId equals c.CourseId
                       where c.CreatedBy == user.fldId
                       orderby e.ExamId
                       select e).FirstOrDefault();
                if (firstExam == null)
                    return RedirectToAction("Index", new { examId = 0 });
                examId = firstExam.ExamId;
            }

            if (!CanModifyExam(user, examId))
            {
                TempData["msgError"] = "Bu sınava soru ekleme yetkiniz yok.";
                return RedirectToAction("Index", "Exam");
            }

            int nextSort = 1;
            var lastQuestion = db.Question
                .Where(q => q.ExamId == examId)
                .OrderByDescending(q => q.SortOrder)
                .FirstOrDefault();

            if (lastQuestion != null)
                nextSort = lastQuestion.SortOrder + 1;

            var model = new QuestionViewModel
            {
                ExamId = examId,
                SortOrder = nextSort,
                Points = 1,
                QuestionType = "MultipleChoice"
            };

            return View(model);
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing) db?.Dispose();
            base.Dispose(disposing);
        }
    }
}
