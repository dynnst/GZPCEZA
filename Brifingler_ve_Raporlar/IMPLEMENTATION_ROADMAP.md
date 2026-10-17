# CEZAM Projesi - Authorization & Error Handling Implementation Roadmap

## ?? Hýzlý Özet

```
Tespit Edilen Kritik Sorun:
? HomeController'da [UserAuthorize] yorum halinde
? Birden fazla controller manuel token kontrolü kullanýyor
? Global error pages yok
? HTTP 403/404/405 custom handling yok

Tavsiye: 405/404 stratejisini uygulamak + HomeController'i sabitlemek
Tahmini Zaman: 2 hafta (4 faz)
Risk Seviyesi: ?? YÜKSEK (þu anki), ? DÜÞÜK (sonrasý)
```

---

## ?? FIX 1: HomeController Kritik Sorunu (SAATLERÝNCE)

### Problem:
```csharp
//[UserAuthorize]  ? YORUM HALINDE!
public class HomeController : Controller
{
    public ActionResult Index()
    {
        var user = getuserby();
        // Yetkisiz kullanýcý sayfayý görebiliyor
    }
}
```

### Çözüm:
```csharp
[UserAuthorize]  ? UNCOMMENT
public class HomeController : Controller
{
    public ActionResult Index()
    {
        var user = getuserby();
        // UserAuthorize zaten check etti
    }
}
```

**Dosya**: `gzpegm/Controllers/HomeController.cs` - Line 14

---

## ?? FIX 2: Enhanced UserAuthorize Attribute (1-2 Saat)

### Neden:
Þu anki UserAuthorize sadece redirect yapýyor. 403 Forbidden döndürmüyor.

### Yeni Kod:
```csharp
// gzpegm/Cont/UserAuthorize.cs

using System;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Net;

namespace gzpegm.Cont
{
    public class UserAuthorize : AuthorizeAttribute
    {
        public enum UnauthorizedBehavior
        {
            Redirect,      // Eski davranýþ: /Giris'e yönlendir
            ReturnForbidden // Yeni davranýþ: 403 Forbidden
        }

        public UnauthorizedBehavior OnUnauthorized { get; set; } = UnauthorizedBehavior.Redirect;

        protected override bool AuthorizeCore(HttpContextBase httpContext)
        {
            var controllerName = httpContext.Request.RequestContext.RouteData.Values["controller"] as string;
            var actionName = httpContext.Request.RequestContext.RouteData.Values["action"] as string;

            // Landing sayfasý için her zaman izin ver
            if (string.Equals(controllerName, "Landing", StringComparison.OrdinalIgnoreCase) &&
                string.Equals(actionName, "Index", StringComparison.OrdinalIgnoreCase))
                return true;

            var tokenCookie = httpContext.Request.Cookies["Token"];
            if (tokenCookie == null)
            {
                httpContext.Request.RequestContext.HttpContext.Items["UnauthorizedReason"] = "NoToken";
                return false;
            }

            Token token = new Token();
            var check = token.GetToken(tokenCookie.Value.ToString());
            if (check == null)
            {
                httpContext.Request.RequestContext.HttpContext.Items["UnauthorizedReason"] = "InvalidToken";
                return false;
            }

            if (!check.fldDateTime.HasValue || check.fldDateTime.Value < DateTime.Now.AddHours(-3))
            {
                token.RemoveToken(Convert.ToInt32(check.fldUserId));
                httpContext.Request.RequestContext.HttpContext.Items["UnauthorizedReason"] = "TokenExpired";
                return false;
            }

            User userCont = new User();
            var userData = userCont.GetUserById(Convert.ToInt32(check.fldUserId));
            if (userData == null ||
                (userData.IsActive.HasValue && !userData.IsActive.Value) ||
                string.Equals(userData.fldActive, "0", StringComparison.OrdinalIgnoreCase))
            {
                token.RemoveToken(Convert.ToInt32(check.fldUserId));
                httpContext.Request.RequestContext.HttpContext.Items["UnauthorizedReason"] = "UserInactive";
                return false;
            }

            // Kullanýcý rol kontrolü (Users attributelý ise)
            if (!string.IsNullOrEmpty(Users))
            {
                var userAuth = (userData?.fldAuth ?? string.Empty).Trim();
                var userRoles = userAuth.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries).Select(s => s.Trim()).ToArray();
                var allowedRoles = Users.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries).Select(s => s.Trim()).ToArray();

                bool roleOk = userRoles.Any(r => allowedRoles.Contains(r));
                if (!roleOk)
                {
                    httpContext.Request.RequestContext.HttpContext.Items["UnauthorizedReason"] = "InsufficientRole";
                    httpContext.Request.RequestContext.HttpContext.Items["RequiredRoles"] = Users;
                    httpContext.Request.RequestContext.HttpContext.Items["UserRoles"] = userAuth;
                    return false;
                }
            }

            return true;
        }

        protected override void HandleUnauthorizedRequest(AuthorizationContext filterContext)
        {
            // Eðer kullanýcý authenticate ise ama role'ü yok ? 403
            if (filterContext.HttpContext.User.Identity.IsAuthenticated)
            {
                filterContext.Result = new HttpStatusCodeResult(
                    HttpStatusCode.Forbidden,
                    "Bu iþlem için yetkiniz bulunmamaktadýr."
                );
            }
            else
            {
                // Login deðil ? Redirect to login
                if (OnUnauthorized == UnauthorizedBehavior.Redirect)
                {
                    filterContext.HttpContext.Response.Redirect("/Giris");
                }
                else
                {
                    // 401 Unauthorized döndür
                    filterContext.Result = new HttpStatusCodeResult(
                        HttpStatusCode.Unauthorized,
                        "Lütfen giriþ yapýnýz."
                    );
                }
            }
        }
    }
}
```

---

## ?? FIX 3: Global Error Handler (2-3 Saat)

### 3.1 FilterConfig.cs Oluþtur/Düzenle
```csharp
// gzpegm/App_Start/FilterConfig.cs

using System.Web.Mvc;

namespace gzpegm
{
    public class FilterConfig
    {
        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
            filters.Add(new HandleErrorAttribute());
            filters.Add(new AuthorizeErrorAttribute());
        }
    }
}
```

### 3.2 AuthorizeErrorAttribute Oluþtur
```csharp
// gzpegm/Helpers/AuthorizeErrorAttribute.cs

using System.Web.Mvc;

namespace gzpegm.Helpers
{
    public class AuthorizeErrorAttribute : ActionFilterAttribute
    {
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            // 403/404 errors handled by UserAuthorize -> Error view'a yönlendir
            base.OnActionExecuting(filterContext);
        }
    }
}
```

### 3.3 Global.asax.cs Güncelle
```csharp
// Global.asax.cs'de Application_Start

protected void Application_Start(object sender, EventArgs e)
{
    // ... mevcut kod ...

    AreaRegistration.RegisterAllAreas();
    FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);  // ? EKLE
    GlobalConfiguration.Configure(WebApiConfig.Register);
    RouteConfig.RegisterRoutes(RouteTable.Routes);
}
```

---

## ?? FIX 4: Custom Error Pages (3-4 Saat)

### 4.1 ErrorController Oluþtur
```csharp
// gzpegm/Controllers/ErrorController.cs

using System.Web.Mvc;

namespace gzpegm.Controllers
{
    public class ErrorController : Controller
    {
        [HttpGet]
        public ActionResult Index()
        {
            // Generic error
            return View();
        }

        [HttpGet]
        public ActionResult NotFound()
        {
            Response.StatusCode = 404;
            Response.TrySkipIisCustomErrors = true;
            return View();
        }

        [HttpGet]
        public ActionResult Forbidden()
        {
            Response.StatusCode = 403;
            Response.TrySkipIisCustomErrors = true;
            return View();
        }

        [HttpGet]
        public ActionResult MethodNotAllowed()
        {
            Response.StatusCode = 405;
            Response.TrySkipIisCustomErrors = true;
            return View();
        }

        [HttpGet]
        public ActionResult Unauthorized()
        {
            Response.StatusCode = 401;
            Response.TrySkipIisCustomErrors = true;
            return View();
        }
    }
}
```

### 4.2 Error View'larý Oluþtur

**Views/Error/Index.cshtml**
```html
@{
    Layout = "~/Views/Shared/_Master.cshtml";
    ViewBag.Title = "Hata Oluþtu";
}

<section class="card">
    <header class="card-header">
        <h2 class="card-title"><i class="fas fa-exclamation-circle"></i> Hata Oluþtu</h2>
    </header>
    <div class="card-body">
        <p class="lead">Sistemde bir hata meydana geldi. Lütfen daha sonra tekrar deneyin.</p>
        <p>
            <a href="@Url.Action("Index", "Home")" class="btn btn-primary">
                <i class="fas fa-home"></i> Ana Sayfaya Dön
            </a>
        </p>
    </div>
</section>
```

**Views/Error/NotFound.cshtml**
```html
@{
    Layout = "~/Views/Shared/_Master.cshtml";
    ViewBag.Title = "Sayfa Bulunamadý";
}

<section class="card">
    <header class="card-header">
        <h2 class="card-title"><i class="fas fa-search"></i> 404 - Sayfa Bulunamadý</h2>
    </header>
    <div class="card-body">
        <p class="lead">Aradýðýnýz sayfa bulunamadý.</p>
        <p>
            <strong>Aranýlan URL:</strong> @Request.Url?.PathAndQuery
        </p>
        <p>
            <a href="@Url.Action("Index", "Home")" class="btn btn-primary">
                <i class="fas fa-home"></i> Ana Sayfaya Dön
            </a>
        </p>
    </div>
</section>
```

**Views/Error/Forbidden.cshtml**
```html
@{
    Layout = "~/Views/Shared/_Master.cshtml";
    ViewBag.Title = "Yetkisiz Eriþim";
}

<section class="card">
    <header class="card-header">
        <h2 class="card-title"><i class="fas fa-lock"></i> 403 - Yetkisiz Eriþim</h2>
    </header>
    <div class="card-body">
        <div class="alert alert-warning">
            <strong>Uyarý:</strong> Bu sayfaya eriþim yetkiniz bulunmamaktadýr.
        </div>
        <p class="lead">Aradýðýnýz iþlem için gerekli yetki seviyesine sahip deðilsiniz.</p>
        <p>
            Eðer bu bir hata ise, lütfen sistem yöneticisine baþvurunuz.
        </p>
        <p>
            <a href="@Url.Action("Index", "Home")" class="btn btn-primary">
                <i class="fas fa-home"></i> Ana Sayfaya Dön
            </a>
        </p>
    </div>
</section>
```

**Views/Error/MethodNotAllowed.cshtml**
```html
@{
    Layout = "~/Views/Shared/_Master.cshtml";
    ViewBag.Title = "Metod Desteklenmiyor";
}

<section class="card">
    <header class="card-header">
        <h2 class="card-title"><i class="fas fa-ban"></i> 405 - Metod Desteklenmiyor</h2>
    </header>
    <div class="card-body">
        <p class="lead">Ýstek attýðýnýz HTTP metodu bu endpoint tarafýndan desteklenmemektedir.</p>
        <p>
            <strong>Yöntem:</strong> @Request.HttpMethod<br>
            <strong>URL:</strong> @Request.Url?.PathAndQuery
        </p>
        <p>
            <a href="@Url.Action("Index", "Home")" class="btn btn-primary">
                <i class="fas fa-home"></i> Ana Sayfaya Dön
            </a>
        </p>
    </div>
</section>
```

### 4.3 Web.config Düzenle
```xml
<configuration>
  <system.web>
    <customErrors mode="On" defaultRedirect="~/Error">
      <error statusCode="404" redirect="~/Error/NotFound" />
      <error statusCode="403" redirect="~/Error/Forbidden" />
      <error statusCode="405" redirect="~/Error/MethodNotAllowed" />
      <error statusCode="401" redirect="~/Error/Unauthorized" />
    </customErrors>
  </system.web>

  <system.webServer>
    <httpErrors errorMode="Custom">
      <remove statusCode="404" />
      <error statusCode="404" path="/Error/NotFound" responseMode="ExecuteURL" />
      <remove statusCode="403" />
      <error statusCode="403" path="/Error/Forbidden" responseMode="ExecuteURL" />
      <remove statusCode="405" />
      <error statusCode="405" path="/Error/MethodNotAllowed" responseMode="ExecuteURL" />
      <remove statusCode="401" />
      <error statusCode="401" path="/Error/Unauthorized" responseMode="ExecuteURL" />
    </httpErrors>
  </system.webServer>
</configuration>
```

---

## ?? FIX 5: Controller'larý Standardize Et (3-4 Saat)

### 5.1 ProfilController Güncelle
```csharp
// Deðiþtir:
public class ProfileController : Controller

// Buna:
[UserAuthorize]
public class ProfileController : Controller
{
    // GetCurrentUserId() methodunu kaldýr
    // UserAuthorize zaten check etti
}
```

### 5.2 VizeController Güncelle
```csharp
// Deðiþtir:
public class VizeController : Controller

// Buna:
[UserAuthorize]
public class VizeController : Controller
{
    // GetUser() methodunu simplify et (UserAuthorize handles auth)
}
```

### 5.3 EInadController Güncelle
```csharp
// Deðiþtir:
public class EInadController : Controller

// Buna:
[UserAuthorize]
public class EInadController : Controller
{
    // Manual token kontrollerini kaldýr
}
```

### 5.4 AjaxController (Seçici Koruma)
```csharp
// Kýsmi koruma yapacaðýz:

[UserAuthorize]  // ? Class-level koruma
public class AjaxController : Controller
{
    [AllowAnonymous]  // ? Exception: Public hesaplama
    public JsonResult CalculateVizeDays(string entry, string exit)
    {
        // Herkese açýk
    }

    // Diðer metodlar UserAuthorize tarafýndan korunacak
}
```

---

## ?? FIX 6: Testing Planý (3-4 Saat)

### Test Case 1: Unauthorized User
```
Adým:
1. Browser'ý aç, çýkýþ yap
2. /AllUsers URL'sine git
3. Beklenen: 403 Forbidden + Error/Forbidden view

Kontrol: ? Ýþte mi?
```

### Test Case 2: Wrong Role
```
Adým:
1. Student (Rol 0) ile giriþ yap
2. /RolYetki URL'sine git
3. Beklenen: 403 Forbidden + Error/Forbidden view

Kontrol: ? Ýþte mi?
```

### Test Case 3: No Token
```
Adým:
1. Tüm cookies sil
2. /Home/Index'e git
3. Beklenen: Login sayfasýna yönlendir veya 401

Kontrol: ? Ýþte mi?
```

### Test Case 4: Expired Token
```
Adým:
1. Login ol
2. Token cookie'sini manual olarak sil/expire yap
3. Herhangi bir action'a git
4. Beklenen: /Giris'e yönlendir

Kontrol: ? Ýþte mi?
```

### Test Case 5: Invalid Role Format
```
Adým:
1. Database'de user rol'ünü koru(pt et
2. /AllUsers'a git
3. Beklenen: 403 Forbidden

Kontrol: ? Ýþte mi?
```

### Test Case 6: AJAX Error Responses
```
Adým:
1. Login olmadan POST /Ajax/SendMessage yap
2. Beklenen: 401/403 + JSON error

Kontrol: ? Ýþte mi?
```

---

## ?? Uygulama Sýra-Listesi (Checklist)

### Faz 1 (SAATLERÝNCE - CRITICAL)
- [ ] HomeController'da `[UserAuthorize]` uncomment et
- [ ] Tüm system administrator(s) bunu kontrol etsin

### Faz 2 (1-2 GÜN)
- [ ] UserAuthorize.cs enhance et (403 Forbidden döndürmek için)
- [ ] FilterConfig.cs oluþtur
- [ ] Global.asax.cs güncelle
- [ ] ErrorController.cs oluþtur
- [ ] Error views oluþtur (404, 403, 405, 401)
- [ ] Web.config güncelle

### Faz 3 (2-3 GÜN)
- [ ] ProfilController [UserAuthorize] ekle
- [ ] VizeController [UserAuthorize] ekle
- [ ] EInadController [UserAuthorize] ekle
- [ ] AjaxController seçici [UserAuthorize] ekle

### Faz 4 (1-2 GÜN)
- [ ] Tüm test case'leri çalýþtýr
- [ ] Penetration testing
- [ ] Browser testing (Chrome, Firefox, IE)
- [ ] Mobile testing

### Faz 5 (SONRASI)
- [ ] Production deployment
- [ ] Monitoring & logging
- [ ] User feedback collection

---

## ?? Güvenlik Kontrol Listesi (Post-Implementation)

- [ ] 404/403/405 sayfalarý custom HTML'de admin bilgisi yok mu?
- [ ] Error logging active mi?
- [ ] Rate limiting var mý?
- [ ] SQL injection risk kontrol edildi mi?
- [ ] XSS risk kontrol edildi mi?
- [ ] CSRF protection aktif mi?
- [ ] HTTPS enforced mi?
- [ ] Secure cookies (HttpOnly, Secure) aktif mi?

---

## ?? Kaynaklar & Referanslar

1. **Microsoft Docs - Authorization in ASP.NET MVC**
   - https://docs.microsoft.com/en-us/aspnet/mvc/overview/security/

2. **OWASP - Authentication Cheat Sheet**
   - https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html

3. **HTTP Status Codes**
   - 401 Unauthorized - Authentication gerekli
   - 403 Forbidden - Authentication var ama yetkisiz
   - 404 Not Found - Resource bulunamadý
   - 405 Method Not Allowed - HTTP metodu desteklenmiyor

---

## ?? Notlar

1. **Backward Compatibility**: Mevcut redirect davranýþý `OnUnauthorized` property'si ile kontrol edilebilir
2. **Staging Test**: Production'a gitmeden staging ortamýnda test et
3. **Monitoring**: Error logs'u düzenli kontrol et
4. **Documentation**: Yeni error handling'i developer team'e document et
