using gzpegm.Cont;
using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    public class PublicGlossaryController : Controller
    {
        private GZPEGM1 db = new GZPEGM1();

        // Kullanıcı bilgisi alma
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

        // GET: PublicGlossary - Terimler Listesi
        public ActionResult Index(string q = null, string category = null, string letter = null, int page = 1)
        {
            int pageSize = 20;
            var terms = db.Set<DocumentTerms>().Where(x => x.IsActive).AsQueryable();

            // Arama filtresi
            if (!string.IsNullOrWhiteSpace(q))
            {
                string search = q.Trim().ToLower();
                terms = terms.Where(x =>
                    (x.Term != null && x.Term.ToLower().Contains(search)) ||
                    (x.Definition != null && x.Definition.ToLower().Contains(search)) ||
                    (x.Category != null && x.Category.ToLower().Contains(search))
                );
            }

            // Kategori filtresi
            if (!string.IsNullOrWhiteSpace(category))
            {
                terms = terms.Where(x => x.Category == category);
            }

            // Alfabetik filtre
            if (!string.IsNullOrWhiteSpace(letter))
            {
                if (letter == "0-9")
                {
                    terms = terms.Where(x => x.Term != null && x.Term != "" &&
                        (x.Term.StartsWith("0") || x.Term.StartsWith("1") || x.Term.StartsWith("2") ||
                         x.Term.StartsWith("3") || x.Term.StartsWith("4") || x.Term.StartsWith("5") ||
                         x.Term.StartsWith("6") || x.Term.StartsWith("7") || x.Term.StartsWith("8") ||
                         x.Term.StartsWith("9")));
                }
                else if (letter.Length == 1)
                {
                    string lowerLetter = letter.ToLower();
                    string upperLetter = letter.ToUpper();
                    terms = terms.Where(x => x.Term != null && x.Term != "" &&
                        (x.Term.StartsWith(lowerLetter) || x.Term.StartsWith(upperLetter)));
                }
            }

            int totalCount = terms.Count();
            int totalPages = (int)Math.Ceiling((double)totalCount / pageSize);
            page = Math.Max(1, Math.Min(page, Math.Max(1, totalPages)));

            var list = terms.OrderBy(x => x.Term)
                            .Skip((page - 1) * pageSize)
                            .Take(pageSize)
                            .ToList();

            var categories = db.Categories
                .Where(x => x.IsActive)
                .OrderBy(x => x.CategoryName)
                .Select(x => x.CategoryName)
                .ToList();

            var allTerms = db.Set<DocumentTerms>().Where(x => x.IsActive && x.Term != null && x.Term != "")
                             .Select(x => x.Term).ToList();
            var availableLetters = new System.Collections.Generic.HashSet<string>();
            foreach (var term in allTerms)
            {
                char firstChar = term[0];
                if (char.IsDigit(firstChar)) availableLetters.Add("0-9");
                else if (char.IsLetter(firstChar)) availableLetters.Add(char.ToUpper(firstChar).ToString());
            }

            ViewBag.Categories = categories;
            ViewBag.CurrentCategory = category;
            ViewBag.SearchQuery = q;
            ViewBag.SelectedLetter = letter;
            ViewBag.LettersAvailable = availableLetters;
            ViewBag.TotalCount = totalCount;
            ViewBag.CurrentPage = page;
            ViewBag.TotalPages = totalPages;
            ViewBag.PageSize = pageSize;

            return View(list);
        }

        // GET: PublicGlossary/Details/5 - Terim Detayı
        public ActionResult Details(int? id, string slug = null)
        {
            DocumentTerms term = null;

            if (id.HasValue)
            {
                term = db.Set<DocumentTerms>().Find(id);
            }
            else if (!string.IsNullOrWhiteSpace(slug))
            {
                term = db.Set<DocumentTerms>()
                    .FirstOrDefault(x => x.Slug == slug && x.IsActive);
            }

            if (term == null || !term.IsActive)
                return HttpNotFound();

            // ✅ Token tabanlı kullanıcı kontrolü
            var currentUser = GetCurrentUser();
            if (currentUser == null)
                return RedirectToAction("Login", "Account");

            // ✅ Session'a kullanıcı bilgilerini yaz
            Session["fldName"] = currentUser.fldName ?? "Kullanıcı";
            Session["fldLastName"] = currentUser.fldLastName ?? "";
            Session["fldSicil"] = string.IsNullOrWhiteSpace(currentUser.fldSicil)
                ? "00000"
                : currentUser.fldSicil.Trim();

            // İlişkili terimler (aynı kategorideki)
            var relatedTerms = db.Set<DocumentTerms>()
                .Where(x => x.Category == term.Category && x.Id != term.Id && x.IsActive)
                .OrderBy(x => x.Term)
                .Take(8)
                .ToList();

            ViewBag.RelatedTerms = relatedTerms;
            ViewBag.CategoryName = term.Category;

            return View(term);
        }

        // GET: PublicGlossary/Search - AJAX İçin Arama Önerisi
        [HttpGet]
        public JsonResult Search(string q)
        {
            if (string.IsNullOrWhiteSpace(q) || q.Length < 2)
                return Json(new { data = new object[] { } }, JsonRequestBehavior.AllowGet);

            string search = q.Trim().ToLower();
            var results = db.Set<DocumentTerms>()
                .Where(x => x.IsActive && (x.Term ?? "").ToLower().Contains(search))
                .Select(x => new { x.Id, x.Term, x.Category })
                .Take(10)
                .ToList();

            return Json(new { data = results }, JsonRequestBehavior.AllowGet);
        }

        // GET: PublicGlossary/GetRecentTerms
        [HttpGet]
        public JsonResult GetRecentTerms(int count = 5)
        {
            try
            {
                var terms = db.Set<DocumentTerms>()
                    .Where(x => x.IsActive)
                    .OrderByDescending(x => x.CreatedAt)
                    .Take(count)
                    .Select(x => new
                    {
                        id = x.Id,
                        term = x.Term
                    })
                    .ToList();

                return Json(terms, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"GetRecentTerms Error: {ex.Message}");
                return Json(new List<object>(), JsonRequestBehavior.AllowGet);
            }
        }

        // GET: PublicGlossary/GetTermDetail
        [HttpGet]
        public JsonResult GetTermDetail(int id)
        {
            try
            {
                var term = db.Set<DocumentTerms>().Find(id);

                if (term == null || !term.IsActive)
                    return Json(null, JsonRequestBehavior.AllowGet);

                return Json(new
                {
                    id = term.Id,
                    term = term.Term,
                    definition = term.Definition,
                    detailedDescription = term.DetailedDescription,
                    category = term.Category,
                    imageUrl = term.ImageUrl,
                    adSoyad = term.AdSoyad,
                    sicil = term.Sicil,
                    createdAt = term.CreatedAt?.ToString("dd.MM.yyyy")
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"GetTermDetail Error: {ex.Message}");
                return Json(null, JsonRequestBehavior.AllowGet);
            }
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing) db.Dispose();
            base.Dispose(disposing);
        }
    }
}