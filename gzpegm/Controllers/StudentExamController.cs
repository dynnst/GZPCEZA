using gzpegm.Cont;
using gzpegm.Models;
using gzpegm.Models.ViewModels;
using gzpegm.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    public class StudentExamController : Controller
    {
        private GZPEGM1 db = new GZPEGM1();
        private EmailService emailService = new EmailService();

        private E_User GetCurrentUser()
        {
            try
            {
                HttpCookie UserCookie = Request.Cookies["Token"];
                if (UserCookie == null) return null;

                Token token = new Token();
                var tokendata = token.GetToken(UserCookie.Value);
                if (tokendata == null) return null;

                int UserId = 0;
                int.TryParse(tokendata.fldUserId?.ToString(), out UserId);
                if (UserId == 0) return null;

                User user = new User();
                return user.GetUserById(UserId);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"GetCurrentUser Error: {ex.Message}");
                return null;
            }
        }

        private void LogExamResultIdSources(string actionName, int id)
        {
            try
            {
                var routeId = RouteData?.Values["id"]?.ToString();
                var queryId = Request?.QueryString["id"];
                var formId = Request?.Form["id"];
                var rawId = Request?.Params["id"];

                System.Diagnostics.Trace.TraceInformation(
                    $"[{actionName}] ExamResultId kaynaklari -> BoundId: {id}, RouteId: {routeId ?? "null"}, QueryId: {queryId ?? "null"}, FormId: {formId ?? "null"}, RawId: {rawId ?? "null"}");

                if (string.IsNullOrWhiteSpace(routeId) && string.IsNullOrWhiteSpace(queryId) && string.IsNullOrWhiteSpace(formId))
                {
                    System.Diagnostics.Trace.TraceWarning(
                        $"[{actionName}] ExamResultId hicbir kaynaktan gelmedi. BoundId: {id}");
                }

                if (id <= 0)
                {
                    System.Diagnostics.Trace.TraceWarning(
                        $"[{actionName}] Gecersiz BoundId tespit edildi. BoundId: {id}, RouteId: {routeId ?? "null"}, QueryId: {queryId ?? "null"}, FormId: {formId ?? "null"}");
                }

                if (string.IsNullOrWhiteSpace(rawId))
                {
                    System.Diagnostics.Trace.TraceWarning($"[{actionName}] id parametresi null/bos geldi.");
                }
                else if (!int.TryParse(rawId, out var parsedId))
                {
                    System.Diagnostics.Trace.TraceWarning($"[{actionName}] id parametresi int'e parse edilemedi. RawId: {rawId}");
                }
                else if (parsedId <= 0)
                {
                    System.Diagnostics.Trace.TraceWarning($"[{actionName}] id parametresi 0 veya negatif. ParsedId: {parsedId}");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"LogExamResultIdSources Error: {ex.Message}");
            }
        }

        public ActionResult AvailableExams()
        {
            var user = GetCurrentUser();
            if (user == null)
            {
                TempData["msgError"] = "Sınavlara erişmek için giriş yapmalısınız.";
                return RedirectToAction("LoginPage", "Giris");
            }

            var examsList = db.Exam
                .Where(e => e.IsActive == true
                    && (e.IsArchived == null || e.IsArchived == false)
                    && db.Courses.Any(c => c.CourseId == e.CourseId && c.IsActive && c.IsDeleted != true))
                .OrderBy(e => e.CreatedAt)
                .ToList();

            var availableExams = new List<ExamViewModel>();
            if (examsList.Count == 0)
            {
                ViewBag.CurrentUser = user;
                return View(availableExams);
            }

            var examIds = examsList.Select(x => x.ExamId).ToList();
            var courseIds = examsList.Select(x => x.CourseId).Distinct().ToList();

            var courses = db.Courses
                .Where(c => courseIds.Contains(c.CourseId))
                .ToDictionary(c => c.CourseId, c => c);

            var enrolledCourseIds = new HashSet<int>(
                db.CourseEnrollments
                    .Where(ce => ce.UserId == user.fldId && courseIds.Contains(ce.CourseId))
                    .Select(ce => ce.CourseId));

            var completedByExam = db.ExamResult
                .Where(er => examIds.Contains(er.ExamId) && er.UserId == user.fldId && er.Status == 1)
                .GroupBy(er => er.ExamId)
                .ToDictionary(g => g.Key, g => g.Select(er => er.ExamResultId).FirstOrDefault());

            var questionCounts = db.Question
                .Where(q => examIds.Contains(q.ExamId))
                .GroupBy(q => q.ExamId)
                .Select(g => new { g.Key, Cnt = g.Count() })
                .ToDictionary(x => x.Key, x => x.Cnt);

            foreach (var e in examsList)
            {
                courses.TryGetValue(e.CourseId, out var course);
                bool isEnrolled = enrolledCourseIds.Contains(e.CourseId) || user.Role == "Admin" || (course != null && course.CreatedBy == user.fldId);
                completedByExam.TryGetValue(e.ExamId, out var completedRid);
                int? completedResultId = completedRid > 0 ? completedRid : (int?)null;
                int questionCount = questionCounts.TryGetValue(e.ExamId, out var qc) ? qc : 0;
                bool canTakeExam = isEnrolled && e.IsActive == true && completedResultId == null;

                availableExams.Add(new ExamViewModel
                {
                    ExamId = e.ExamId,
                    ExamTitle = e.Title,
                    ExamDescription = e.Description,
                    CourseId = e.CourseId,
                    CourseTitle = course?.CourseTitle ?? "Bilinmeyen Kurs",
                    CourseCoverImage = course?.CoverImage,
                    Duration = e.DurationMinutes ?? 60,
                    PassingScore = e.PassingScore ?? 60,
                    QuestionCount = questionCount,
                    IsActive = e.IsActive,
                    CreatedDate = e.CreatedAt,
                    IsStudentEnrolled = isEnrolled,
                    CanTakeExam = canTakeExam,
                    ExamResultId = completedResultId
                });
            }

            ViewBag.CurrentUser = user;
            return View(availableExams);
        }

        public ActionResult StartExam(int? id = null)
        {
            var user = GetCurrentUser();
            if (user == null)
            {
                TempData["msgError"] = "Sınava girmek için giriş yapmalısınız.";
                return RedirectToAction("LoginPage", "Giris");
            }

            if (!id.HasValue || id.Value <= 0)
            {
                TempData["msgInfo"] = "Lütfen girmek istediğiniz sınavı seçin.";
                return RedirectToAction("AvailableExams");
            }

            int examId = id.Value;

            var exam = db.Exam.Find(examId);
            if (exam == null || exam.IsActive == false)
            {
                TempData["msgError"] = "Sınav bulunamadı veya aktif değil.";
                return RedirectToAction("AvailableExams");
            }

            var course = db.Courses.FirstOrDefault(c => c.CourseId == exam.CourseId && c.IsActive && c.IsDeleted != true);
            if (course == null)
            {
                TempData["msgError"] = "Bu sınavın bağlı olduğu kurs aktif değil veya kaldırılmış.";
                return RedirectToAction("AvailableExams");
            }

            bool isEnrolled = user.Role == "Admin" || (course.CreatedBy == user.fldId) ||
                db.CourseEnrollments.Any(e => e.CourseId == exam.CourseId && e.UserId == user.fldId);

            if (!isEnrolled)
            {
                TempData["msgError"] = "Bu sınava girmek için kursa kayıtlı olmalısınız.";
                return RedirectToAction("AvailableExams");
            }

            // Daha önce tamamlanmış sınav var mı?
            var completedAttempt = db.ExamResult
                .FirstOrDefault(er => er.ExamId == examId && er.UserId == user.fldId && er.Status == 1);
            if (completedAttempt != null)
            {
                TempData["msgInfo"] = "Bu sınavı daha önce tamamladınız. Sonuçlarınızı görüntüleyebilirsiniz.";
                return RedirectToAction("ExamResult", new { id = completedAttempt.ExamResultId });
            }

            // Devam eden sınav varsa aynı oturumdan devam et.
            var inProgressAttempt = db.ExamResult
                .FirstOrDefault(er => er.ExamId == examId && er.UserId == user.fldId && er.Status == 0);
            // Soruları hazırla
            var questions = db.Question
                .Where(q => q.ExamId == examId && q.IsActive == true)
                .OrderBy(q => q.SortOrder)
                .ToList()
                .Select(q => new ExamQuestionViewModel
                {
                    QuestionId = q.QuestionId,
                    QuestionText = q.Text,
                    QuestionType = GetQuestionTypeString(q.QuestionType),
                    Points = q.Points,
                    SortOrder = q.SortOrder,
                    Options = (q.QuestionType == 1 || q.QuestionType == 2) ? db.QuestionOption
                        .Where(o => o.QuestionId == q.QuestionId)
                        .OrderBy(o => o.SortOrder)
                        .Select(o => new QuestionOptionViewModel
                        {
                            OptionId = o.OptionId,
                            OptionText = o.Text
                        }).ToList() : new List<QuestionOptionViewModel>(),
                    MediaFiles = db.QuestionMedia
                        .Where(m => m.QuestionId == q.QuestionId)
                        .OrderBy(m => m.SortOrder)
                        .Select(m => new QuestionMediaViewModel
                        {
                            MediaId = m.MediaId,
                            MediaType = m.MediaType,
                            MediaPath = m.MediaPath,
                            SortOrder = m.SortOrder
                        }).ToList()
                }).ToList();

            if (!questions.Any())
            {
                TempData["msgError"] = "Bu sınavda henüz soru bulunmuyor.";
                return RedirectToAction("AvailableExams");
            }

            // Yeni sınav oturumu oluştur (sorular kontrol edildikten sonra)
            var examResult = inProgressAttempt ?? new ExamResult
            {
                ExamId = examId,
                UserId = user.fldId,
                StartedAt = DateTime.Now,
                Status = 0
            };
            if (inProgressAttempt == null)
            {
                db.ExamResult.Add(examResult);
                db.SaveChanges();
            }

            int examResultId = examResult.ExamResultId;
            DateTime startTime = examResult.StartedAt ?? DateTime.Now;

            var duration = exam.DurationMinutes ?? 60;
            var viewModel = new StudentExamViewModel
            {
                ExamId = exam.ExamId,
                ExamTitle = exam.Title,
                ExamDescription = exam.Description,
                CourseId = exam.CourseId,
                CourseTitle = course?.CourseTitle ?? "Bilinmeyen Kurs",
                Duration = duration,
                PassingScore = exam.PassingScore ?? 60,
                TotalQuestions = questions.Count,
                StartTime = startTime,
                EndTime = startTime.AddMinutes(duration),
                Questions = questions
            };
            ViewBag.ExamResultId = examResultId;
            return View(viewModel);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult SubmitExam(StudentExamViewModel model, int examResultId)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null)
                    return Json(new { success = false, message = "Oturum sona erdi." });

                var examResult = db.ExamResult
                    .FirstOrDefault(er => er.ExamResultId == examResultId && er.UserId == user.fldId);
                if (examResult == null)
                    return Json(new { success = false, message = "Geçersiz sınav sonucu." });

                if (examResult.Status != 0)
                    return Json(new { success = false, message = "Bu sınav daha önce tamamlanmış." });

                var exam = db.Exam.Find(examResult.ExamId);
                if (exam == null || exam.IsActive == false)
                    return Json(new { success = false, message = "Sınav bulunamadı veya aktif değil." });

                if (examResult.StartedAt.HasValue)
                {
                    var duration = exam.DurationMinutes ?? 60;
                    var deadline = examResult.StartedAt.Value.AddMinutes(duration).AddMinutes(1);
                    if (DateTime.Now > deadline)
                    {
                        examResult.FinishedAt = DateTime.Now;
                        examResult.Status = 1;
                        examResult.Score = 0;
                        db.SaveChanges();
                        return Json(new
                        {
                            success = true,
                            examResultId = examResultId,
                            score = 0,
                            maxScore = 0,
                            percentage = 0,
                            isPassed = false,
                            timeExpired = true,
                            message = "Sınav süresi dolduğu için sonuç sayfasına yönlendiriliyorsunuz."
                        });
                    }
                }

                if (model?.Questions == null)
                    return Json(new { success = false, message = "Gönderilen veriler eksik." });

                var examQuestions = db.Question
                    .Where(q => q.ExamId == examResult.ExamId && q.IsActive == true)
                    .OrderBy(q => q.SortOrder)
                    .ToList();

                if (!examQuestions.Any())
                    return Json(new { success = false, message = "Sınavda aktif soru bulunamadı." });

                var questionIds = examQuestions.Select(q => q.QuestionId).ToList();
                var postedAnswers = model.Questions
                    .Where(q => questionIds.Contains(q.QuestionId))
                    .GroupBy(q => q.QuestionId)
                    .ToDictionary(g => g.Key, g => g.First());

                var correctOptions = db.QuestionOption
                    .Where(o => questionIds.Contains(o.QuestionId) && o.IsCorrect == true)
                    .GroupBy(o => o.QuestionId)
                    .ToDictionary(g => g.Key, g => g.Select(o => o.OptionId).ToList());

                var optionQuestionMap = db.QuestionOption
                    .Where(o => questionIds.Contains(o.QuestionId))
                    .Select(o => new { o.OptionId, o.QuestionId })
                    .ToDictionary(o => o.OptionId, o => o.QuestionId);

                var existingAnswers = db.Answer.Where(a => a.ExamResultId == examResultId).ToList();
                if (existingAnswers.Any())
                    db.Answer.RemoveRange(existingAnswers);

                int totalScore = 0;
                int maxScore = 0;

                // Her aktif sınav sorusu için tek Answer kaydı oluştur.
                foreach (var dbQ in examQuestions)
                {
                    maxScore += dbQ.Points;
                    postedAnswers.TryGetValue(dbQ.QuestionId, out var submittedQuestion);

                    var answer = new Answer
                    {
                        ExamResultId = examResultId,
                        QuestionId = dbQ.QuestionId
                    };

                    bool isCorrect = false;
                    if (submittedQuestion != null && submittedQuestion.SelectedOptionId.HasValue)
                    {
                        var selectedOptionId = submittedQuestion.SelectedOptionId.Value;
                        if (optionQuestionMap.TryGetValue(selectedOptionId, out var optionQuestionId)
                            && optionQuestionId == dbQ.QuestionId)
                        {
                            answer.OptionId = selectedOptionId;
                            if (correctOptions.TryGetValue(dbQ.QuestionId, out var correctOptionIds))
                                isCorrect = correctOptionIds.Contains(selectedOptionId);
                        }
                    }
                    else if (submittedQuestion != null && !string.IsNullOrWhiteSpace(submittedQuestion.TextAnswer))
                    {
                        answer.TextAnswer = submittedQuestion.TextAnswer;
                        // Metin cevaplar için doğruluk kontrolü yapılmıyor (öğretmen değerlendirmeli)
                        isCorrect = false;
                    }

                    if (isCorrect)
                        totalScore += dbQ.Points;

                    db.Answer.Add(answer);
                }

                examResult.Score = totalScore;
                examResult.FinishedAt = DateTime.Now;
                examResult.Status = 1;
                db.SaveChanges();

                double percentage = maxScore > 0 ? ((double)totalScore / maxScore) * 100 : 0;
                bool isPassed = percentage >= (exam?.PassingScore ?? 60);

                if (!string.IsNullOrEmpty(user.fldEmail))
                {
                    try
                    {
                        emailService.SendExamResultEmailAsync(
                            user.fldEmail,
                            user.fldName + " " + user.fldLastName,
                            exam.Title,
                            totalScore,
                            maxScore,
                            isPassed
                        ).Wait();
                    }
                    catch { }
                }

                return Json(new
                {
                    success = true,
                    examResultId = examResultId,
                    score = totalScore,
                    maxScore = maxScore,
                    percentage = (int)percentage,
                    isPassed = isPassed
                });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"SubmitExam Error: {ex.Message}");
                return Json(new { success = false, message = "Sınav gönderilirken hata oluştu: " + ex.Message });
            }
        }

        public ActionResult ExamResult(int? id = null)
        {
            try
            {
                var user = GetCurrentUser();
                if (user == null)
                {
                    TempData["msgError"] = "Sonuçları görüntülemek için giriş yapmalısınız.";
                    return RedirectToAction("LoginPage", "Giris");
                }

                if (!id.HasValue || id.Value <= 0)
                {
                    var latestResult = db.ExamResult
                        .Where(er => er.Status == 1 && (user.Role == "Admin" || er.UserId == user.fldId))
                        .OrderByDescending(er => er.ExamResultId)
                        .FirstOrDefault();

                    if (latestResult != null)
                    {
                        return RedirectToAction("ExamResult", new { id = latestResult.ExamResultId });
                    }

                    TempData["msgInfo"] = "Görüntülenecek sınav sonucu bulunamadı.";
                    return RedirectToAction("MyExamResults");
                }

                int examResultId = id.Value;
                System.Diagnostics.Debug.WriteLine("ExamResultId: " + examResultId);
                LogExamResultIdSources(nameof(ExamResult), examResultId);

                var examResult = db.ExamResult.FirstOrDefault(er => er.ExamResultId == examResultId);
                System.Diagnostics.Debug.WriteLine("FoundExamResult: " + (examResult != null ? "true" : "false"));
                if (examResult == null)
                {
                    TempData["msgError"] = "Sınav sonucu bulunamadı.";
                    return RedirectToAction("AvailableExams");
                }
                if (examResult.Status != 1)
                {
                    TempData["msgError"] = "Sınav sonucu henüz tamamlanmamış.";
                    return RedirectToAction("MyExamResults");
                }

                var answersForExamResult = db.Answer
                    .Where(x => x.ExamResultId == examResultId)
                    .ToList();
                var exam = db.Exam.Find(examResult.ExamId);
                if (exam == null)
                {
                    TempData["msgError"] = "İlgili sınav bulunamadı.";
                    return RedirectToAction("AvailableExams");
                }

                var course = db.Courses.Find(exam.CourseId);

                // Yetki kontrolü
                bool hasAccess = false;
                if (!string.IsNullOrWhiteSpace(user.Role))
                {
                    if (user.Role.Equals("Admin", StringComparison.OrdinalIgnoreCase))
                        hasAccess = true;
                    else if (user.Role.Equals("Teacher", StringComparison.OrdinalIgnoreCase))
                        hasAccess = (course != null && course.CreatedBy == user.fldId);
                    else
                        hasAccess = (examResult.UserId == user.fldId);
                }
                else
                {
                    hasAccess = (examResult.UserId == user.fldId);
                }

                if (!hasAccess)
                {
                    TempData["msgError"] = "Bu sınav sonucunu görüntüleme yetkiniz yok.";
                    return RedirectToAction("AvailableExams");
                }

                // Sorular (pasif olanlar da dahil, çünkü sonuç geçmişe ait)
                var answeredQuestionIds = answersForExamResult
                    .Select(a => a.QuestionId)
                    .Distinct()
                    .ToList();
                var hasAnswerDetails = answeredQuestionIds.Any();

                var questions = db.Question
                    .Where(q => hasAnswerDetails
                        ? answeredQuestionIds.Contains(q.QuestionId)
                        : q.ExamId == examResult.ExamId)
                    .ToList()
                    .OrderBy(q => q.SortOrder)
                    .ThenBy(q => q.QuestionId)
                    .ToList();
                var answers = questions.Select(q =>
                {
                    var userAnswer = answersForExamResult.FirstOrDefault(a => a.QuestionId == q.QuestionId);
                    var correctOption = db.QuestionOption.FirstOrDefault(o => o.QuestionId == q.QuestionId && o.IsCorrect);

                    string userAnswerText = null;
                    if (userAnswer != null)
                    {
                        if (!string.IsNullOrWhiteSpace(userAnswer.TextAnswer))
                            userAnswerText = userAnswer.TextAnswer;
                        else if (userAnswer.OptionId.HasValue)
                        {
                            var selectedOption = db.QuestionOption.FirstOrDefault(o => o.OptionId == userAnswer.OptionId);
                            userAnswerText = selectedOption?.Text ?? "";
                        }
                    }

                    string correctAnswerText = correctOption?.Text ?? "";
                    bool isCorrect = false;
                    if (correctOption != null && userAnswer != null)
                        isCorrect = (userAnswer.OptionId == correctOption.OptionId);

                    var mediaFiles = db.QuestionMedia
                        .Where(m => m.QuestionId == q.QuestionId)
                        .OrderBy(m => m.SortOrder)
                        .Select(m => new QuestionMediaViewModel
                        {
                            MediaId = m.MediaId,
                            MediaType = m.MediaType,
                            MediaPath = m.MediaPath,
                            SortOrder = m.SortOrder
                        }).ToList();

                    var options = db.QuestionOption
                        .Where(o => o.QuestionId == q.QuestionId)
                        .OrderBy(o => o.SortOrder)
                        .Select(o => new QuestionOptionResultViewModel
                        {
                            OptionId = o.OptionId,
                            OptionText = o.Text,
                            IsCorrect = o.IsCorrect,
                            SortOrder = o.SortOrder
                        }).ToList();

                    return new AnswerResultViewModel
                    {
                        QuestionId = q.QuestionId,
                        QuestionText = q.Text ?? "",
                        UserAnswer = userAnswerText ?? "",
                        CorrectAnswer = correctAnswerText,
                        IsCorrect = isCorrect,
                        PointsEarned = isCorrect ? q.Points : 0,
                        MaxPoints = q.Points,
                        MediaFiles = mediaFiles ?? new List<QuestionMediaViewModel>(),
                        Options = options ?? new List<QuestionOptionResultViewModel>(),
                        SelectedOptionId = userAnswer?.OptionId
                    };
                }).ToList();

                int maxTotalScore = questions.Sum(q => q.Points);
                int studentScore = examResult.Score.HasValue ? (int)examResult.Score.Value : 0;
                double percentage = maxTotalScore > 0 ? ((double)studentScore / maxTotalScore) * 100 : 0;
                TimeSpan duration = TimeSpan.Zero;
                if (examResult.StartedAt.HasValue && examResult.FinishedAt.HasValue)
                    duration = examResult.FinishedAt.Value - examResult.StartedAt.Value;

                var viewModel = new ExamResultViewModel
                {
                    ExamResultId = examResult.ExamResultId,
                    ExamTitle = exam.Title ?? "",
                    CourseTitle = course?.CourseTitle ?? "",
                    TotalScore = (int)studentScore,
                    MaxScore = maxTotalScore,
                    Percentage = percentage,
                    IsPassed = percentage >= (exam.PassingScore ?? 60),
                    StartTime = examResult.StartedAt ?? DateTime.Now,
                    EndTime = examResult.FinishedAt,
                    Duration = duration,
                    Answers = answers
                };

                return View(viewModel);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"ExamResult Critical Error: {ex}");
                TempData["msgError"] = "Sonuçlar yüklenirken teknik bir hata oluştu.";
                return RedirectToAction("AvailableExams");
            }
        }

        public ActionResult MyExamResults()
        {
            var user = GetCurrentUser();
            if (user == null)
            {
                TempData["msgError"] = "Sonuçları görüntülemek için giriş yapmalısınız.";
                return RedirectToAction("LoginPage", "Giris");
            }

            // Performanslı sorgu: önce filtrele, sonra verileri tek seferde çek
            var examResultsQuery = from er in db.ExamResult
                                   join e in db.Exam on er.ExamId equals e.ExamId
                                   join c in db.Courses on e.CourseId equals c.CourseId
                                   where er.Status == 1 &&
                                         ((user.Role != null && user.Role.Equals("Admin", StringComparison.OrdinalIgnoreCase))
                                         || (user.Role != null && user.Role.Equals("Teacher", StringComparison.OrdinalIgnoreCase) && c.CreatedBy == user.fldId)
                                         || er.UserId == user.fldId)
                                   orderby er.FinishedAt descending
                                   select new
                                   {
                                       er.ExamResultId,
                                       e.ExamId,
                                       e.Title,
                                       e.Description,
                                       c.CourseTitle,
                                       er.Score,
                                       er.StartedAt,
                                       er.FinishedAt,
                                       e.PassingScore
                                   };

            var resultsList = examResultsQuery.ToList();
            var draftResultsList = (from er in db.ExamResult
                                    join e in db.Exam on er.ExamId equals e.ExamId
                                    join c in db.Courses on e.CourseId equals c.CourseId
                                    where er.Status != 1 &&
                                          ((user.Role != null && user.Role.Equals("Admin", StringComparison.OrdinalIgnoreCase))
                                          || (user.Role != null && user.Role.Equals("Teacher", StringComparison.OrdinalIgnoreCase) && c.CreatedBy == user.fldId)
                                          || er.UserId == user.fldId)
                                    orderby er.StartedAt descending
                                    select new
                                    {
                                        er.ExamResultId,
                                        e.ExamId,
                                        e.Title,
                                        c.CourseTitle,
                                        er.StartedAt,
                                        er.FinishedAt,
                                        er.Status
                                    }).ToList();
            var examIds = resultsList.Select(r => r.ExamId).Distinct().ToList();
            var questionCounts = db.Question
                .Where(q => examIds.Contains(q.ExamId))
                .GroupBy(q => q.ExamId)
                .Select(g => new { g.Key, MaxScore = g.Sum(q => (int?)q.Points) ?? 0 })
                .ToDictionary(g => g.Key, g => g.MaxScore);

            var resultIds = resultsList.Select(r => r.ExamResultId).ToList();
            var allAnswers = db.Answer
                .Where(a => resultIds.Contains(a.ExamResultId))
                .ToList();
            var allQuestions = db.Question.Where(q => examIds.Contains(q.ExamId)).ToList();
            var allCorrectOptions = db.QuestionOption
                .Where(o => examIds.Contains(o.Question.ExamId) && o.IsCorrect)
                .ToDictionary(o => o.QuestionId, o => o.OptionId);

            var results = new List<ExamResultViewModel>();
            foreach (var r in resultsList)
            {
                int maxScore = questionCounts.ContainsKey(r.ExamId) ? questionCounts[r.ExamId] : 0;
                decimal studentScore = r.Score ?? 0m;
                double percentage = maxScore > 0 ? (double)studentScore / maxScore * 100 : 0;
                bool isPassed = percentage >= (r.PassingScore ?? 60);
                TimeSpan duration = (r.FinishedAt.HasValue && r.StartedAt.HasValue) ? r.FinishedAt.Value - r.StartedAt.Value : TimeSpan.Zero;

                var examQuestions = allQuestions.Where(q => q.ExamId == r.ExamId).ToList();
                var examAnswers = allAnswers.Where(a => a.ExamResultId == r.ExamResultId).ToList();

                var answerViewModels = examQuestions.Select(q =>
                {
                    var userAnswer = examAnswers.FirstOrDefault(a => a.QuestionId == q.QuestionId);
                    var correctOptId = allCorrectOptions.ContainsKey(q.QuestionId) ? allCorrectOptions[q.QuestionId] : (int?)null;
                    string userAnswerText = "";
                    bool isCorrect = false;
                    if (userAnswer != null)
                    {
                        if (userAnswer.OptionId.HasValue)
                        {
                            var opt = db.QuestionOption.FirstOrDefault(o => o.OptionId == userAnswer.OptionId);
                            userAnswerText = opt?.Text ?? "";
                            if (correctOptId.HasValue && userAnswer.OptionId == correctOptId.Value)
                                isCorrect = true;
                        }
                        else if (!string.IsNullOrWhiteSpace(userAnswer.TextAnswer))
                        {
                            userAnswerText = userAnswer.TextAnswer;
                        }
                    }
                    string correctAnswerText = "";
                    if (correctOptId.HasValue)
                    {
                        var correctOpt = db.QuestionOption.FirstOrDefault(o => o.OptionId == correctOptId.Value);
                        correctAnswerText = correctOpt?.Text ?? "";
                    }
                    return new AnswerResultViewModel
                    {
                        QuestionText = q.Text,
                        UserAnswer = userAnswerText,
                        CorrectAnswer = correctAnswerText,
                        IsCorrect = isCorrect,
                        PointsEarned = isCorrect ? q.Points : 0,
                        MaxPoints = q.Points
                    };
                }).ToList();

                results.Add(new ExamResultViewModel
                {
                    ExamResultId = r.ExamResultId,
                    ExamId = r.ExamId,
                    ExamTitle = r.Title,
                    ExamDescription = r.Description,
                    CourseTitle = r.CourseTitle,
                    TotalScore = (int)studentScore,
                    MaxScore = maxScore,
                    Percentage = percentage,
                    IsPassed = isPassed,
                    StartTime = r.StartedAt ?? DateTime.Now,
                    EndTime = r.FinishedAt,
                    Duration = duration,
                    Answers = answerViewModels
                });
            }

            ViewBag.DraftResults = draftResultsList.Select(d => new ExamResultViewModel
            {
                ExamResultId = d.ExamResultId,
                ExamId = d.ExamId,
                ExamTitle = d.Title,
                CourseTitle = d.CourseTitle,
                StartTime = d.StartedAt ?? DateTime.Now,
                EndTime = d.FinishedAt,
                ExamDescription = d.Status == 0 ? "Devam ediyor" : "Tamamlanmamış"
            }).ToList();

            return View(results);
        }

        private string GetQuestionTypeString(byte? questionType)
        {
            if (questionType == null) return "MultipleChoice";
            return questionType.Value switch
            {
                1 => "MultipleChoice",
                2 => "TrueFalse",
                3 => "Text",
                _ => "MultipleChoice"
            };
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing) db?.Dispose();
            base.Dispose(disposing);
        }
    }
}
