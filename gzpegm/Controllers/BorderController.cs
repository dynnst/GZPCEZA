using gzpegm.Cont;
using gzpegm.Models;
using gzpegm.Models.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize(Users = "2")]
    public class BorderController : Controller
    {
        [Route("KAPI")]
        [Route("Border")]
        [Route("Border/Index")]
        public ActionResult Index()
        {
            using (GZPEGM1 db = new GZPEGM1())
            {
                var borders = db.E_Border.AsNoTracking().ToList();

                var userBorders = db.E_User
                    .AsNoTracking()
                    .Where(u => u.fldBorder != null && u.fldBorder != "")
                    .Select(u => u.fldBorder)
                    .ToList();

                var borderCountDict = userBorders
                    .Where(b => !string.IsNullOrWhiteSpace(b))
                    .GroupBy(b => b.Trim(), StringComparer.OrdinalIgnoreCase)
                    .ToDictionary(g => g.Key, g => g.Count(), StringComparer.OrdinalIgnoreCase);

                var viewModelList = borders.Select(b =>
                {
                    int count = 0;
                    if (!string.IsNullOrWhiteSpace(b.fldName))
                    {
                        borderCountDict.TryGetValue(b.fldName.Trim(), out count);
                    }
                    return new BorderItemViewModel
                    {
                        fldId = b.fldId,
                        fldName = b.fldName,
                        PersonnelCount = count
                    };
                }).OrderBy(b => b.fldName).ToList();

                return View(viewModelList);
            }
        }

        [Route("GetBorderPersonnel")]
        [HttpGet]
        public JsonResult GetBorderPersonnel(string borderName)
        {
            if (string.IsNullOrWhiteSpace(borderName))
            {
                return Json(new { success = false, message = "Sınır kapısı adı belirtilmedi." }, JsonRequestBehavior.AllowGet);
            }

            try
            {
                using (GZPEGM1 db = new GZPEGM1())
                {
                    var trimmedBorder = borderName.Trim();
                    var allUsersWithBorder = db.E_User
                        .AsNoTracking()
                        .Where(u => u.fldBorder != null && u.fldBorder != "")
                        .ToList();

                    var matchingUsers = allUsersWithBorder
                        .Where(u => string.Equals(u.fldBorder.Trim(), trimmedBorder, StringComparison.OrdinalIgnoreCase))
                        .OrderBy(u => u.fldName)
                        .ThenBy(u => u.fldLastName)
                        .Select(u => new BorderPersonnelViewModel
                        {
                            Id = u.fldId,
                            Sicil = string.IsNullOrWhiteSpace(u.fldSicil) ? "-" : u.fldSicil.Trim(),
                            FullName = string.Format("{0} {1}", u.fldName ?? "", u.fldLastName ?? "").Trim(),
                            Title = string.IsNullOrWhiteSpace(u.fldTitle) ? "-" : u.fldTitle.Trim(),
                            Deputy = string.IsNullOrWhiteSpace(u.fldDeputy) ? "-" : u.fldDeputy.Trim(),
                            Phone = string.IsNullOrWhiteSpace(u.fldPhone) ? "-" : u.fldPhone.Trim(),
                            Email = string.IsNullOrWhiteSpace(u.fldEmail) ? "-" : u.fldEmail.Trim(),
                            Role = string.IsNullOrWhiteSpace(u.Role) ? "Kullanıcı" : u.Role.Trim(),
                            IsActive = u.IsActive == true || u.fldActive == "1",
                            Picture = u.fldPicture,
                            LastLogin = u.LastLogin.HasValue ? u.LastLogin.Value.ToString("dd.MM.yyyy HH:mm") : "Giriş Yapılmadı",
                            CreatedDate = u.fldDateTime.HasValue ? u.fldDateTime.Value.ToString("dd.MM.yyyy") : "-"
                        })
                        .ToList();

                    return Json(new
                    {
                        success = true,
                        border = trimmedBorder,
                        count = matchingUsers.Count,
                        data = matchingUsers
                    }, JsonRequestBehavior.AllowGet);
                }
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = "Personel listesi yüklenirken hata oluştu: " + ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [Route("addborder")]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult addborder(string border)
        {
            if (string.IsNullOrWhiteSpace(border))
            {
                return Json(new { command = "alert('Lütfen geçerli bir sınır kapısı ismi giriniz..!');" }, JsonRequestBehavior.AllowGet);
            }

            var cleanName = border.Trim().ToUpper();
            Border aborder = new Border();
            var check = aborder.GetbyName(cleanName);
            if (check != null) return Json(new { command = "alert('Bu sınır kapısı daha önce eklenmiştir..!');" }, JsonRequestBehavior.AllowGet);
            aborder.addBorder(cleanName);
            return Json(new { command = "alert('Başarılı bir şekilde eklendi..!'); location.href='/KAPI';" }, JsonRequestBehavior.AllowGet);
        }

        [Route("deleteborder")]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult deleteborder(int Id)
        {
            Border aborder = new Border();
            aborder.deleteBorder(Id);
            return Json(new { command = "alert('Başarılı bir şekilde silinmiştir..!'); location.href='/KAPI';" }, JsonRequestBehavior.AllowGet);
        }
    }
}
