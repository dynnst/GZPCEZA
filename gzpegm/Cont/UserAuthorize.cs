using System;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Net;

namespace gzpegm.Cont
{
    public class UserAuthorize : AuthorizeAttribute
    {
        protected override bool AuthorizeCore(HttpContextBase httpContext)
        {
            var controllerName = httpContext.Request.RequestContext.RouteData.Values["controller"] as string;
            var actionName = httpContext.Request.RequestContext.RouteData.Values["action"] as string;

            // Landing sayfası için her zaman izin ver
            if (string.Equals(controllerName, "Landing", StringComparison.OrdinalIgnoreCase) &&
                string.Equals(actionName, "Index", StringComparison.OrdinalIgnoreCase))
                return true;

            var tokenCookie = httpContext.Request.Cookies["Token"];
            if (tokenCookie == null || string.IsNullOrWhiteSpace(tokenCookie.Value))
            {
                return false;
            }

            Token token = new Token();
            var check = token.GetToken(tokenCookie.Value.ToString());
            if (check == null)
            {
                return false;
            }

            if (!check.fldDateTime.HasValue || check.fldDateTime.Value < DateTime.Now.AddHours(-3))
            {
                token.RemoveToken(Convert.ToInt32(check.fldUserId));
                return false;
            }

            User userCont = new User();
            var userData = userCont.GetUserById(Convert.ToInt32(check.fldUserId));
            if (userData == null ||
                (userData.IsActive.HasValue && !userData.IsActive.Value) ||
                string.Equals(userData.fldActive, "0", StringComparison.OrdinalIgnoreCase))
            {
                token.RemoveToken(Convert.ToInt32(check.fldUserId));
                return false;
            }

            // Kullanıcı geçerli ve aktif - Oturum doğrulaması başarılı (Authenticated)
            httpContext.Items["UserIsAuthenticated"] = true;
            httpContext.Items["CurrentUser"] = userData;

            try
            {
                var identity = new System.Security.Principal.GenericIdentity(userData.fldSicil ?? userData.fldId.ToString(), "TokenAuth");
                var userAuth = (userData?.fldAuth ?? string.Empty).Trim();
                var userRoles = userAuth.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries).Select(s => s.Trim()).ToArray();
                var principal = new System.Security.Principal.GenericPrincipal(identity, userRoles);
                httpContext.User = principal;
                System.Threading.Thread.CurrentPrincipal = principal;
            }
            catch
            {
                // Principal atamasında hata olsa bile akışı bozma
            }

            // Kullanıcı rol kontrolü (Users attributelı ise)
            if (!string.IsNullOrEmpty(Users))
            {
                var userAuth = (userData?.fldAuth ?? string.Empty).Trim();
                var userRoles = userAuth.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries).Select(s => s.Trim()).ToArray();
                var allowedRoles = Users.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries).Select(s => s.Trim()).ToArray();

                bool roleOk = userRoles.Any(r => allowedRoles.Contains(r));
                if (!roleOk)
                {
                    return false;
                }
            }

            return true;
        }

        protected override void HandleUnauthorizedRequest(AuthorizationContext filterContext)
        {
            bool isAuthenticated = (filterContext.HttpContext.Items["UserIsAuthenticated"] as bool?) == true
                || (filterContext.HttpContext.User != null && filterContext.HttpContext.User.Identity != null && filterContext.HttpContext.User.Identity.IsAuthenticated);

            if (isAuthenticated)
            {
                // Kullanıcı oturum açmış ama bu sayfa/işlem için yetkisi yetersiz → 403 Forbidden
                if (filterContext.HttpContext.Request.IsAjaxRequest())
                {
                    filterContext.Result = new HttpStatusCodeResult(
                        HttpStatusCode.Forbidden,
                        "Bu işlem için yetkiniz bulunmamaktadır."
                    );
                }
                else
                {
                    filterContext.Result = new RedirectResult("/Error/Forbidden");
                }
            }
            else
            {
                // Kullanıcı oturum açmamış veya token süresi dolmuş → Login sayfasına yönlendir
                if (filterContext.HttpContext.Request.IsAjaxRequest())
                {
                    filterContext.Result = new HttpStatusCodeResult(
                        HttpStatusCode.Unauthorized,
                        "Oturum açmanız gerekmektedir."
                    );
                }
                else
                {
                    filterContext.Result = new RedirectResult("/Giris");
                }
            }
        }
    }
}
