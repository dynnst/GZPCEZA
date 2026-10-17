using gzpegm.Cont;
using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Reflection;
using System.Web.Mvc;

namespace gzpegm.Controllers
{
    [UserAuthorize(Users = "2")]
    public class RolePermissionController : Controller
    {
        private readonly GZPEGM1 db = new GZPEGM1();

        [HttpGet]
        [Route("RolYetki")]
        public ActionResult Index()
        {
            var model = BuildModel();
            return View(model);
        }

        [HttpGet]
        [Route("YetkiMatrisi")]
        public ActionResult Matrix()
        {
            var model = BuildMatrixModel();
            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [Route("RolYetki/Uygula")]
        public ActionResult Apply(string roleName, string[] permissionCodes)
        {
            roleName = (roleName ?? "").Trim();
            if (!AllowedRoles.Any(x => string.Equals(x, roleName, StringComparison.OrdinalIgnoreCase)))
            {
                TempData["msgError"] = "Geçerli bir rol seçilmedi.";
                return RedirectToAction("Index");
            }

            var selectedCodes = NormalizeCodes(permissionCodes);
            if (!selectedCodes.Any())
            {
                TempData["msgError"] = "En az bir yetki seçmelisiniz.";
                return RedirectToAction("Index");
            }

            var users = db.E_User
                .Where(u => u.Role != null)
                .ToList()
                .Where(u => string.Equals(u.Role, roleName, StringComparison.OrdinalIgnoreCase))
                .ToList();

            if (!users.Any())
            {
                TempData["msgError"] = roleName + " rolünde kullanıcı bulunamadı. Rol yetkisi uygulanmadı.";
                return RedirectToAction("Index");
            }

            foreach (var user in users)
            {
                user.fldAuth = string.Join(",", selectedCodes);
            }

            db.SaveChanges();

            TempData["msgSuccess"] = $"{roleName} rolündeki {users.Count} kullanıcının yetkileri güncellendi.";
            return RedirectToAction("Index");
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [Route("RolYetki/KullaniciYetki")]
        public ActionResult UpdateUserPermissions(int userId, string[] permissionCodes)
        {
            var user = db.E_User.FirstOrDefault(u => u.fldId == userId);
            if (user == null)
            {
                TempData["msgError"] = "Kullanıcı bulunamadı.";
                return RedirectToAction("Index");
            }

            var selectedCodes = NormalizeCodes(permissionCodes);
            user.fldAuth = string.Join(",", selectedCodes);
            db.SaveChanges();

            TempData["msgSuccess"] = $"{DisplayName(user)} kullanıcısının yetkileri güncellendi.";
            return RedirectToAction("Index");
        }

        private RolePermissionPageViewModel BuildModel()
        {
            var permissions = GetPermissionCatalog();
            var users = db.E_User
                .AsNoTracking()
                .OrderBy(u => u.Role)
                .ThenBy(u => u.fldName)
                .ThenBy(u => u.fldLastName)
                .Select(u => new RolePermissionUserViewModel
                {
                    UserId = u.fldId,
                    Sicil = u.fldSicil,
                    FullName = ((u.fldName ?? "") + " " + (u.fldLastName ?? "")).Trim(),
                    Role = u.Role,
                    AuthCodes = u.fldAuth
                })
                .ToList();

            var roleSummaries = AllowedRoles.Select(role =>
            {
                var roleUsers = users
                    .Where(u => string.Equals(u.Role, role, StringComparison.OrdinalIgnoreCase))
                    .ToList();

                return new RolePermissionRoleViewModel
                {
                    RoleName = role,
                    UserCount = roleUsers.Count,
                    SuggestedCodes = GetDefaultCodesForRole(role),
                    CurrentCodes = GetRoleCurrentCodes(roleUsers, role)
                };
            }).ToList();

            return new RolePermissionPageViewModel
            {
                Permissions = permissions,
                Roles = roleSummaries,
                Users = users
            };
        }

        private static List<string> NormalizeCodes(string[] permissionCodes)
        {
            return (permissionCodes ?? new string[0])
                .Select(x => (x ?? "").Trim())
                .Where(x => !string.IsNullOrWhiteSpace(x))
                .Distinct()
                .OrderBy(x => x)
                .ToList();
        }

        private static readonly string[] AllowedRoles = { "Admin", "Teacher", "Student" };

        private static string[] GetDefaultCodesForRole(string role)
        {
            if (string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase)) return new[] { "1", "2", "3", "4", "5", "6" };
            if (string.Equals(role, "Teacher", StringComparison.OrdinalIgnoreCase)) return new[] { "6" };
            return new[] { "3" };
        }

        private static string[] GetRoleCurrentCodes(List<RolePermissionUserViewModel> roleUsers, string role)
        {
            if (roleUsers == null || !roleUsers.Any()) return GetDefaultCodesForRole(role);

            return roleUsers
                .SelectMany(u => SplitCodes(u.AuthCodes))
                .Distinct()
                .OrderBy(x => x)
                .ToArray();
        }

        private static IEnumerable<string> SplitCodes(string authCodes)
        {
            return (authCodes ?? "")
                .Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                .Select(x => (x ?? "").Trim())
                .Where(x => !string.IsNullOrWhiteSpace(x));
        }

        private static List<PermissionItemViewModel> GetPermissionCatalog()
        {
            return new List<PermissionItemViewModel>
            {
                new PermissionItemViewModel { Code = "1", Name = "Kullanıcı İşlemleri", Group = "Yönetim", Description = "Kullanıcı listesi, kullanıcı ekleme/düzenleme gibi yönetim alanları." },
                new PermissionItemViewModel { Code = "2", Name = "Admin / Sistem Tanımları", Group = "Yönetim", Description = "Harç, ülke, sınır kapısı, rol-yetki, eğitim paketi ve kritik sistem tanımları." },
                new PermissionItemViewModel { Code = "3", Name = "Ceza, Tahdit ve Şartlı Vize İşlemleri", Group = "Hudut", Description = "Ceza hesaplama, tahdit sayfası, şartlı vize giriş işlemleri ve ana işlem ekranları." },
                new PermissionItemViewModel { Code = "4", Name = "Eski İşlemler / Raporlar", Group = "Hudut", Description = "Genel eski işlemler, admin eski işlemler, raporlar ve V-84 şartlı vize kayıt listesi." },
                new PermissionItemViewModel { Code = "5", Name = "Duyuru / Mesaj İşlemleri", Group = "İletişim", Description = "Duyuru, bildirim, mesaj ve toplu bilgilendirme yönetimi." },
                new PermissionItemViewModel { Code = "6", Name = "Eğitim Düzenleme", Group = "Eğitim", Description = "Kurs, kategori, sınav, soru, şık, medya, eğitim paketi ve kurs içeriklerini düzenleme yetkisi." }
            };
        }

        private static RolePermissionMatrixViewModel BuildMatrixModel()
        {
            var permissions = GetPermissionCatalog();
            var controllers = Assembly.GetExecutingAssembly()
                .GetTypes()
                .Where(t => typeof(Controller).IsAssignableFrom(t) && !t.IsAbstract && t.Name.EndsWith("Controller", StringComparison.Ordinal))
                .OrderBy(t => t.Name)
                .ToList();

            var rows = new List<RolePermissionMatrixRowViewModel>();

            foreach (var controller in controllers)
            {
                var controllerName = controller.Name.Substring(0, controller.Name.Length - "Controller".Length);
                var controllerAuth = controller.GetCustomAttributes(typeof(UserAuthorize), true).Cast<UserAuthorize>().FirstOrDefault();
                var controllerAllowAnonymous = controller.GetCustomAttributes(typeof(AllowAnonymousAttribute), true).Any();

                var actions = controller.GetMethods(BindingFlags.Instance | BindingFlags.Public | BindingFlags.DeclaredOnly)
                    .Where(IsMvcAction)
                    .OrderBy(m => m.Name)
                    .ToList();

                foreach (var action in actions)
                {
                    var actionAuth = action.GetCustomAttributes(typeof(UserAuthorize), true).Cast<UserAuthorize>().FirstOrDefault();
                    var actionAllowAnonymous = action.GetCustomAttributes(typeof(AllowAnonymousAttribute), true).Any();
                    var effectiveAuth = actionAuth ?? controllerAuth;
                    var allowAnonymous = actionAllowAnonymous || controllerAllowAnonymous;
                    var codes = allowAnonymous ? new string[0] : SplitCodes(effectiveAuth?.Users).ToArray();

                    rows.Add(new RolePermissionMatrixRowViewModel
                    {
                        Controller = controllerName,
                        Action = action.Name,
                        HttpMethods = GetHttpMethods(action),
                        Routes = GetRoutes(action, controllerName, action.Name),
                        RequiredCodes = codes,
                        Protection = allowAnonymous
                            ? "Anonim"
                            : effectiveAuth == null
                                ? "Korumalı Değil"
                                : string.IsNullOrWhiteSpace(effectiveAuth.Users)
                                    ? "Giriş Yeterli"
                                    : "Yetki Kodlu",
                        Source = actionAuth != null ? "Action" : controllerAuth != null ? "Controller" : allowAnonymous ? "AllowAnonymous" : "Yok",
                        AdminAccess = HasRoleAccess("Admin", codes, allowAnonymous, effectiveAuth),
                        TeacherAccess = HasRoleAccess("Teacher", codes, allowAnonymous, effectiveAuth),
                        StudentAccess = HasRoleAccess("Student", codes, allowAnonymous, effectiveAuth)
                    });
                }
            }

            return new RolePermissionMatrixViewModel
            {
                Permissions = permissions,
                Rows = rows,
                GeneratedAt = DateTime.Now,
                ProtectedCount = rows.Count(x => x.Protection != "Anonim" && x.Protection != "Korumalı Değil"),
                OpenCount = rows.Count(x => x.Protection == "Anonim" || x.Protection == "Korumalı Değil")
            };
        }

        private static bool IsMvcAction(MethodInfo method)
        {
            if (method == null) return false;
            if (method.IsSpecialName) return false;
            if (method.GetCustomAttributes(typeof(NonActionAttribute), true).Any()) return false;
            if (method.IsDefined(typeof(ChildActionOnlyAttribute), true)) return false;
            if (!typeof(ActionResult).IsAssignableFrom(method.ReturnType) && !typeof(JsonResult).IsAssignableFrom(method.ReturnType) && !typeof(FileResult).IsAssignableFrom(method.ReturnType))
                return false;
            return true;
        }

        private static string GetHttpMethods(MethodInfo action)
        {
            var methods = new List<string>();
            if (action.GetCustomAttributes(typeof(HttpGetAttribute), true).Any()) methods.Add("GET");
            if (action.GetCustomAttributes(typeof(HttpPostAttribute), true).Any()) methods.Add("POST");
            if (action.GetCustomAttributes(typeof(HttpPutAttribute), true).Any()) methods.Add("PUT");
            if (action.GetCustomAttributes(typeof(HttpDeleteAttribute), true).Any()) methods.Add("DELETE");
            return methods.Any() ? string.Join(", ", methods) : "ANY";
        }

        private static string GetRoutes(MethodInfo action, string controllerName, string actionName)
        {
            var routes = action.GetCustomAttributes(typeof(RouteAttribute), true)
                .Cast<RouteAttribute>()
                .Select(x => x.Template)
                .Where(x => !string.IsNullOrWhiteSpace(x))
                .ToList();

            if (!routes.Any()) routes.Add(controllerName + "/" + actionName);
            return string.Join(", ", routes);
        }

        private static bool HasRoleAccess(string role, string[] requiredCodes, bool allowAnonymous, UserAuthorize auth)
        {
            if (allowAnonymous) return true;
            if (auth == null) return false;
            if (requiredCodes == null || requiredCodes.Length == 0) return true;
            var defaults = GetDefaultCodesForRole(role);
            return defaults.Any(x => requiredCodes.Contains(x));
        }

        private static string DisplayName(E_User user)
        {
            if (user == null) return "Kullanıcı";
            var name = ((user.fldName ?? "") + " " + (user.fldLastName ?? "")).Trim();
            return string.IsNullOrWhiteSpace(name) ? (user.fldSicil ?? ("#" + user.fldId)) : name;
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing) db.Dispose();
            base.Dispose(disposing);
        }
    }

    public class RolePermissionPageViewModel
    {
        public List<PermissionItemViewModel> Permissions { get; set; } = new List<PermissionItemViewModel>();
        public List<RolePermissionRoleViewModel> Roles { get; set; } = new List<RolePermissionRoleViewModel>();
        public List<RolePermissionUserViewModel> Users { get; set; } = new List<RolePermissionUserViewModel>();
    }

    public class RolePermissionMatrixViewModel
    {
        public DateTime GeneratedAt { get; set; }
        public int ProtectedCount { get; set; }
        public int OpenCount { get; set; }
        public List<PermissionItemViewModel> Permissions { get; set; } = new List<PermissionItemViewModel>();
        public List<RolePermissionMatrixRowViewModel> Rows { get; set; } = new List<RolePermissionMatrixRowViewModel>();
    }

    public class RolePermissionMatrixRowViewModel
    {
        public string Controller { get; set; }
        public string Action { get; set; }
        public string HttpMethods { get; set; }
        public string Routes { get; set; }
        public string[] RequiredCodes { get; set; } = new string[0];
        public string Protection { get; set; }
        public string Source { get; set; }
        public bool AdminAccess { get; set; }
        public bool TeacherAccess { get; set; }
        public bool StudentAccess { get; set; }
    }

    public class PermissionItemViewModel
    {
        public string Code { get; set; }
        public string Name { get; set; }
        public string Group { get; set; }
        public string Description { get; set; }
    }

    public class RolePermissionRoleViewModel
    {
        public string RoleName { get; set; }
        public int UserCount { get; set; }
        public string[] SuggestedCodes { get; set; } = new string[0];
        public string[] CurrentCodes { get; set; } = new string[0];
    }

    public class RolePermissionUserViewModel
    {
        public int UserId { get; set; }
        public string Sicil { get; set; }
        public string FullName { get; set; }
        public string Role { get; set; }
        public string AuthCodes { get; set; }
    }
}
