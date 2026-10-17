using gzpegm.Cont;
using gzpegm.Helpers;
using gzpegm.Models;
using System;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize(Users = "2,3")]
    [RoutePrefix("Tahdit")]
    public class TahditController : Controller
    {
        private GZPEGM1 db = new GZPEGM1();

        // Yardımcılar
        private string GetCurrentUserAuth()
        {
            try
            {
                if (Session["UserId"] != null && int.TryParse(Session["UserId"].ToString(), out int userId))
                {
                    var u = db.E_User.FirstOrDefault(x => x.fldId == userId);
                    if (u != null) return u.fldAuth;
                }

                if (Session["User"] != null)
                {
                    var t = Session["User"].GetType();
                    var prop = t.GetProperty("fldSicil");
                    if (prop != null)
                    {
                        var sicil = prop.GetValue(Session["User"])?.ToString();
                        if (!string.IsNullOrEmpty(sicil))
                        {
                            var u = db.E_User.FirstOrDefault(x => x.fldSicil == sicil);
                            if (u != null) return u.fldAuth;
                        }
                    }
                }

                var tokenCookie = Request.Cookies["Token"];
                if (tokenCookie != null)
                {
                    var tokenValue = tokenCookie.Value;
                    if (!string.IsNullOrEmpty(tokenValue))
                    {
                        var tokenRecord = db.Set<gzpegm.Models.E_Token>().FirstOrDefault(t => t.fldToken == tokenValue);
                        if (tokenRecord != null)
                        {
                            var u = db.E_User.FirstOrDefault(x => x.fldId == tokenRecord.fldUserId);
                            if (u != null) return u.fldAuth;
                        }
                        else
                        {
                            var tokenRecord2 = db.E_Token.FirstOrDefault(t => t.fldToken == tokenValue);
                            if (tokenRecord2 != null)
                            {
                                var u2 = db.E_User.FirstOrDefault(x => x.fldId == tokenRecord2.fldUserId);
                                if (u2 != null) return u2.fldAuth;
                            }
                        }
                    }
                }

                if (User != null && User.Identity != null && User.Identity.IsAuthenticated)
                {
                    var name = User.Identity.Name;
                    if (!string.IsNullOrEmpty(name))
                    {
                        var u = db.E_User.FirstOrDefault(x => x.fldSicil == name || x.fldEmail == name);
                        if (u != null) return u.fldAuth;
                    }
                }
            }
            catch
            {
            }

            return null;
        }

        private bool HasAuth(params string[] required)
        {
            var auth = GetCurrentUserAuth();
            if (string.IsNullOrEmpty(auth)) return false;
            var parts = auth.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries).Select(x => x.Trim());
            foreach (var r in required) if (parts.Contains(r)) return true;
            return false;
        }
        [HttpGet]
        [Route("GetMediaContent/{id}")]
        public ActionResult GetMediaContent(int id)
        {
            var kayit = db.TahditKod.Find(id);
            if (kayit == null) return Json(new { success = false, content = "" }, JsonRequestBehavior.AllowGet);
            return Json(new { success = true, content = kayit.TahditMedia ?? "" }, JsonRequestBehavior.AllowGet);
        }
        // Summernote için resim yükleme
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Route("SummernoteUpload")]
        public ActionResult SummernoteUpload(HttpPostedFileBase file)
        {
            if (!HasAuth("2", "6")) return new HttpStatusCodeResult(403);

            try
            {
                if (file == null || file.ContentLength == 0)
                    return Json(new { error = "Dosya seçilmedi" });

                string fileName = DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + Path.GetFileName(file.FileName);
                string uploadPath = FileStorageHelper.MapPath(Server, "~/Uploads/Tahdit/Summernote/");
                Directory.CreateDirectory(uploadPath);

                string savePath = Path.Combine(uploadPath, fileName);
                file.SaveAs(savePath);

                string url = Url.Content($"~/Uploads/Tahdit/Summernote/{fileName}");

                return Json(new { url = url });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("SummernoteUpload hata: " + ex);
                return Json(new { error = "Yükleme başarısız: " + ex.Message });
            }
        }

        // Index
        [HttpGet]
        [Route("")]
        public ActionResult Index(string all)
        {
            ViewBag.CanManage = HasAuth("2", "6");
            ViewBag.TotalCount = db.TahditKod.Count();
            ViewBag.AktifCount = db.TahditKod.Count(x => x.Aktif);
            ViewBag.FilteredCount = string.IsNullOrEmpty(all) || !all.Equals("true", StringComparison.OrdinalIgnoreCase)
                ? ViewBag.AktifCount
                : ViewBag.TotalCount;

            return View(Enumerable.Empty<TahditListItem>());
        }

        [HttpGet]
        [Route("List")]
        public ActionResult List(string all)
        {
            int draw = ToInt(Request.QueryString["draw"], 0);
            int start = Math.Max(ToInt(Request.QueryString["start"], 0), 0);
            int length = ToInt(Request.QueryString["length"], 25);
            if (length <= 0 || length > 100) length = 25;

            string search = (Request.QueryString["search[value]"] ?? string.Empty).Trim();
            int orderColumn = ToInt(Request.QueryString["order[0][column]"], 0);
            string orderDir = (Request.QueryString["order[0][dir]"] ?? "asc").Equals("desc", StringComparison.OrdinalIgnoreCase)
                ? "desc"
                : "asc";

            var query = db.TahditKod.AsNoTracking().AsQueryable();
            if (string.IsNullOrEmpty(all) || !all.Equals("true", StringComparison.OrdinalIgnoreCase))
            {
                query = query.Where(x => x.Aktif);
            }

            int recordsTotal = query.Count();

            if (!string.IsNullOrWhiteSpace(search))
            {
                query = query.Where(x =>
                    (x.Kod ?? "").Contains(search) ||
                    (x.Aciklama ?? "").Contains(search) ||
                    (x.GirisGelirse ?? "").Contains(search) ||
                    (x.CikisGelirse ?? "").Contains(search));
            }

            int recordsFiltered = query.Count();

            query = ApplyTahditOrdering(query, orderColumn, orderDir);

            var data = query
                .Skip(start)
                .Take(length)
                .Select(x => new
                {
                    id = x.Id,
                    kod = x.Kod,
                    aciklama = x.Aciklama,
                    sureAy = x.SureAy,
                    girisGelirse = x.GirisGelirse,
                    cikisGelirse = x.CikisGelirse,
                    aktif = x.Aktif
                })
                .ToList();

            return Json(new
            {
                draw,
                recordsTotal,
                recordsFiltered,
                data
            }, JsonRequestBehavior.AllowGet);
        }

        private static int ToInt(string value, int fallback)
        {
            return int.TryParse(value, out int result) ? result : fallback;
        }

        private static IQueryable<TahditKod> ApplyTahditOrdering(IQueryable<TahditKod> query, int column, string direction)
        {
            bool desc = direction.Equals("desc", StringComparison.OrdinalIgnoreCase);

            switch (column)
            {
                case 1:
                    return desc ? query.OrderByDescending(x => x.Aciklama) : query.OrderBy(x => x.Aciklama);
                case 2:
                    return desc ? query.OrderByDescending(x => x.SureAy) : query.OrderBy(x => x.SureAy);
                case 5:
                    return desc ? query.OrderByDescending(x => x.Aktif) : query.OrderBy(x => x.Aktif);
                case 0:
                default:
                    return desc ? query.OrderByDescending(x => x.Kod) : query.OrderBy(x => x.Kod);
            }
        }

        // CREATE (POST)
        [HttpPost]
        [ValidateAntiForgeryToken]
        [ValidateInput(false)]
        [Route("Ekle")]
        public ActionResult Ekle(TahditKod model, string TahditMedia)
        {
            if (!HasAuth("2", "6")) return new HttpStatusCodeResult(403);

            // Verileri doğrudan kaydet - HtmlEncode yapma
            model.Aciklama = string.IsNullOrWhiteSpace(model.Aciklama) ? null : model.Aciklama.Trim();
            model.GirisGelirse = string.IsNullOrWhiteSpace(model.GirisGelirse) ? null : model.GirisGelirse.Trim();
            model.CikisGelirse = string.IsNullOrWhiteSpace(model.CikisGelirse) ? null : model.CikisGelirse.Trim();

            // Summernote HTML içeriği
            model.TahditMedia = TahditMedia;

            if (!ModelState.IsValid) return RedirectToAction("Index");

            model.Aktif = true;

            db.TahditKod.Add(model);
            db.SaveChanges();

            if (Request.IsAjaxRequest())
            {
                return Json(new { success = true, message = "Kayıt eklendi." });
            }

            return RedirectToAction("Index");
        }

        // CREATE (GET) - new separate page for creating records
        [HttpGet]
        [Route("Ekle")]
        public ActionResult Ekle()
        {
            if (!HasAuth("2", "6")) return new HttpStatusCodeResult(403);

            var kayit = new TahditKod
            {
                Id = 0,
                Kod = string.Empty,
                Aciklama = null,
                SureAy = null,
                Aktif = true,
                GirisGelirse = null,
                CikisGelirse = null,
                TahditMedia = null
            };

            return View(kayit);
        }

        // GET Düzenle
        [HttpGet]
        [Route("Duzenle/{id?}")]
        public ActionResult Duzenle(int? id)
        {
            if (!HasAuth("2", "6")) return new HttpStatusCodeResult(403);
            TahditKod kayit;
            if (!id.HasValue || id.Value == 0)
            {
                kayit = new TahditKod
                {
                    Id = 0,
                    Kod = string.Empty,
                    Aciklama = null,
                    SureAy = null,
                    Aktif = true,
                    GirisGelirse = null,
                    CikisGelirse = null,
                    TahditMedia = null
                };
                return View(kayit);
            }

            kayit = db.TahditKod.Find(id.Value);
            if (kayit == null) return HttpNotFound();

            return View(kayit);
        }

        // POST Düzenle
        [HttpPost]
        [ValidateAntiForgeryToken]
        [ValidateInput(false)]
        [Route("Duzenle")]
        public ActionResult Duzenle(TahditKod model, string TahditMedia)
        {
            if (!HasAuth("2", "6")) return new HttpStatusCodeResult(403);

            // Verileri doğrudan kaydet - HtmlEncode yapma
            model.Aciklama = string.IsNullOrWhiteSpace(model.Aciklama) ? null : model.Aciklama.Trim();
            model.GirisGelirse = string.IsNullOrWhiteSpace(model.GirisGelirse) ? null : model.GirisGelirse.Trim();
            model.CikisGelirse = string.IsNullOrWhiteSpace(model.CikisGelirse) ? null : model.CikisGelirse.Trim();

            if (!ModelState.IsValid)
            {
                if (Request.IsAjaxRequest()) return PartialView("_Form", model);
                if (model == null || model.Id == 0) return RedirectToAction("Index");
                return RedirectToAction("Duzenle", new { id = model.Id });
            }

            TahditKod kayit;
            var isNew = model.Id == 0;

            if (isNew)
            {
                kayit = new TahditKod
                {
                    Kod = model.Kod,
                    Aciklama = model.Aciklama,
                    SureAy = model.SureAy,
                    GirisGelirse = model.GirisGelirse,
                    CikisGelirse = model.CikisGelirse,
                    Aktif = model.Aktif,
                    TahditMedia = TahditMedia
                };
                db.TahditKod.Add(kayit);
                db.SaveChanges();
            }
            else
            {
                kayit = db.TahditKod.Find(model.Id);
                if (kayit == null) return HttpNotFound();

                kayit.Kod = model.Kod;
                kayit.Aciklama = model.Aciklama;
                kayit.SureAy = model.SureAy;
                kayit.GirisGelirse = model.GirisGelirse;
                kayit.CikisGelirse = model.CikisGelirse;
                kayit.Aktif = model.Aktif;
                kayit.TahditMedia = TahditMedia;
                db.SaveChanges();
            }

            if (Request.IsAjaxRequest())
            {
                return Json(new { success = true, message = "Kayıt başarıyla kaydedildi." });
            }

            return RedirectToAction("Index");
        }

        // Sil (soft delete)
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Route("Sil")]
        public ActionResult Sil(int id)
        {
            if (!HasAuth("2", "6")) return new HttpStatusCodeResult(403);
            var kayit = db.TahditKod.Find(id);
            if (kayit == null) return HttpNotFound();
            kayit.Aktif = false;
            db.SaveChanges();
            if (Request.IsAjaxRequest())
            {
                return Json(new { success = true, message = "Kayıt silindi." });
            }

            return RedirectToAction("Index");
        }

        [HttpGet]
        [Route("Sil/{id}")]
        public ActionResult SilOnay(int id)
        {
            if (!HasAuth("2", "6")) return new HttpStatusCodeResult(403);
            var kayit = db.TahditKod.Find(id);
            if (kayit == null) return HttpNotFound();
            return View("Sil", kayit);
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing) db.Dispose();
            base.Dispose(disposing);
        }

        [HttpGet]
        [Route("GetTahditKodById/{id}")]
        public ActionResult GetTahditKodById(int id)
        {
            var kayit = db.TahditKod.Find(id);
            if (kayit == null)
                return Json(new { success = false, message = "Kayıt bulunamadı" }, JsonRequestBehavior.AllowGet);

            return Json(new
            {
                success = true,
                id = kayit.Id,
                kod = kayit.Kod,
                aciklama = kayit.Aciklama ?? "",
                sureAy = kayit.SureAy,
                girisGelirse = kayit.GirisGelirse ?? "",
                cikisGelirse = kayit.CikisGelirse ?? "",
                aktif = kayit.Aktif,
                tahditMedia = kayit.TahditMedia ?? ""
            }, JsonRequestBehavior.AllowGet);
        }
    }
}
