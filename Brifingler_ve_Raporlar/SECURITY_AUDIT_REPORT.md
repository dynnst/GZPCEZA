# CEZAM Projesine Kapsamlý Güvenlik Analizi Raporu

## ?? Özet
Bu rapor CEZAM ASP.NET MVC projesindeki **yetkisiz geçiþ alanlarýný** ve **authorization gap'lerini** detaylý olarak analiz etmektedir. Raporun amacý, güvenlik açýklarýný tespit etmek ve **405/404 stratejisinin** uygulanabilirliðini deðerlendirmektir.

---

## ?? BÖLÜM 1: Mevcut Authorization Sistemi

### 1.1 UserAuthorize Attribute (CustomAuthorizeAttribute)
**Dosya**: `gzpegm/Cont/UserAuthorize.cs`

```csharp
[UserAuthorize]           // Token doðrulamasý zorunlu
[UserAuthorize(Users="2")]    // Spesifik role (Rol 2 = Admin)
```

**Nasýl çalýþýr:**
1. Token cookie'sini kontrol eder (`Token`)
2. Token geçerliliðini doðrular (3 saatlik session)
3. Kullanýcý aktiflik durumunu kontrol eder
4. Role tabanlý eriþim kontrol eder (fldAuth)
5. Yetki yoksa ? `/Giris` sayfasýna yönlendirir

**Eksiklikler:**
- ? HTTP 405 (Method Not Allowed) döndürmüyor
- ? HTTP 403 (Forbidden) döndürmüyor
- ? Sadece redirect var
- ? Hata sayfasý yok

---

## ?? BÖLÜM 2: Tespit Edilen Yetkisiz Geçiþ Alanlarý

### **KATEGORI A: ADMIN PANEL (Rol 2 = Admin)**

#### A1. ErrorLogsController ? KORUMALI
```csharp
[UserAuthorize(Users = "2")]
public class ErrorLogsController : Controller
```
- **Status**: ? Korumalý
- **Eriþim**: Sadece Admin (Rol 2)
- **Risk**: Düþük

#### A2. AllUsersController ? KORUMALI
```csharp
[UserAuthorize(Users = "2")]
public class AllUsersController : Controller
```
- **Status**: ? Korumalý
- **Eriþim**: Sadece Admin (Rol 2)
- **Risk**: Düþük

#### A3. RolePermissionController ? KORUMALÜ
```csharp
[UserAuthorize(Users = "2")]
public class RolePermissionController : Controller
```
- **Status**: ? Korumalý
- **Eriþim**: Sadece Admin (Rol 2)
- **Risk**: Düþük
- **Ýþlemler**: Rol/Yetki yönetimi, Permission matrix

---

### **KATEGORI B: ORTA-LEVEL YÖNETIM (Rol 2, 3, 6)**

#### B1. DashboardController ?? KISMI KORUMALÜ
```csharp
[UserAuthorize(Users = "2,3,6")]
public class DashboardController : Controller
```
- **Status**: ?? Kýsmen korumalý
- **Eriþim**: Admin (2), Öðretmen (3), Baþka rol (6)
- **Risk**: Orta
- **Eksiklik**: Role göre data filtreleme kontrol edilmesi gerekiyor

---

### **KATEGORI C: YETKI KONTROLLÜ CONTROLLER'LAR (Manuel Token Kontrol)**

#### C1. ProfilController ?? MANUEL KONTROL
```csharp
public class ProfileController : Controller
{
    private int? GetCurrentUserId()
    {
        HttpCookie cookie = Request.Cookies["Token"];
        if (cookie == null) return null;
        // Token doðrulamasý
    }

    [HttpGet]
    public ActionResult Index()
    {
        var userId = GetCurrentUserId();
        if (userId == null)
            return RedirectToAction("Index", "Giris");
        // ...
    }
}
```
- **Status**: ?? Manuel kontrol
- **Risk**: Orta
- **Problem**: 
  - ? Attribute deðil, manuel kontrol
  - ? Unauthorized (401) yerine Redirect
  - ?? Her action'a manual kontrol eklemek gerekiyor

#### C2. VizeController ?? MANUEL KONTROL
```csharp
public class VizeController : Controller
{
    public E_User GetUser()
    {
        HttpCookie UserCookie = Request.Cookies["Token"];
        Token token = new Token();
        // Token doðrulamasý
    }
}
```
- **Status**: ?? Manuel kontrol
- **Risk**: Orta
- **Problem**: Tutarsýz yetki kontrol pattern'i

#### C3. EInadController ?? MANUEL KONTROL
- **Status**: ?? Manuel kontrol
- **Risk**: Orta-Yüksek

---

### **KATEGORI D: AÇIK ERIÞIM (No Authorization) ??????**

#### D1. LandingController ?????? AÇIK ERIÞIM
```csharp
public class LandingController : Controller  // ? NO [UserAuthorize]
{
    public ActionResult Index()
    {
        // Herkese açýk
    }
}
```
- **Status**: ?????? Açýk eriþim
- **Eriþim**: Tüm kullanýcýlar (login olmuþ/olmamýþ)
- **Risk**: Yüksek
- **Sayfalar**: 
  - `Index()` - Ana sayfa (intentional, OK)
  - `SubmitComment()` - Yorum gönderme (kontrol edilmeli)
  - `GetComments()` - Yorumlarý listele (kontrol edilmeli)

#### D2. KosullarController ?? AÇIK ERIÞIM
```csharp
public class KosullarController : Controller  // ? NO [UserAuthorize]
{
    [Route("Kosullar")]
    public ActionResult Index()
    {
        return View();
    }
}
```
- **Status**: ? Kasýtlý açýk eriþim (Terms of Service)
- **Risk**: Düþük (legal sayfasý)

#### D3. AjaxController ?? AÇIK ERIÞIM (Kýsmen)
```csharp
public class AjaxController : Controller  // ? NO [UserAuthorize]
{
    public JsonResult CalculateVizeDays(string entry, string exit)
    {
        // Herkese açýk hesaplama
    }
}
```
- **Status**: ?? Kýsmen açýk
- **Risk**: Orta
- **Methods**: Bazý metodlar intentional açýk, bazýlarý kontrol edilmeli

#### D4. GirisController ? KASITLI AÇIK
```csharp
public class GirisController : Controller  // ? NO [UserAuthorize]
{
    public ActionResult LoginPage() { }
    public ActionResult Login(string username, string pwd) { }
    public ActionResult ResetPassword() { }
}
```
- **Status**: ? Kasýtlý açýk (Login sayfasý)
- **Risk**: Düþük (authentication action'larý)

#### D5. HomeController ?? AÇIK ERIÞIM
```csharp
//[UserAuthorize]  ? YORUM HALINDE!
public class HomeController : Controller
{
    public ActionResult Index()
    {
        var user = getuserby();  // ? Manual check
        // ...
    }
}
```
- **Status**: ???? AÇIK ERIÞIM (Attribute yorum halinde)
- **Risk**: Yüksek
- **Problem**: 
  - ? `[UserAuthorize]` yorum halinde
  - ? Manual token kontrolü var, ama redirects yok
  - ? Yetkisiz kullanýcýlar sayfayý görebiliyor

#### D6. CourseController ?? KONTROL EDILMESI GEREKLI
- **Status**: ? (Kontrol gerekli)
- **Risk**: Bilinmiyor

#### D7. ExamController ?? KONTROL EDILMESI GEREKLI
- **Status**: ? (Kontrol gerekli)
- **Risk**: Bilinmiyor

---

### **KATEGORI E: AJAX/JSON ENDPOINT'LER (Spesial Risk)**

#### E1. AjaxController.CalculateVizeDays
- **Status**: ?? Açýk eriþim
- **Risk**: Düþük-Orta (Hesaplama fonksiyonu)

#### E2. AllUsersController.GetOrphanCandidates
```csharp
[UserAuthorize(Users = "2")]
[HttpGet]
[Route("AllUsers/GetOrphanCandidates")]
public JsonResult GetOrphanCandidates(int months = 3) { }
```
- **Status**: ? Korumalý
- **Risk**: Düþük

---

## ?? BÖLÜM 3: Yetkisiz Geçiþ Senaryolarý

### Senaryo 1: Logout Olan Kullanýcý Admin Sayfasýna Girebilir Mi?
```
1. Kullanýcý login olur ? Token cookie'sine yazýlýr
2. Logout yapýlýr ? Token cookie silinir
3. Ýstisnai durum: Browser cache'de "/AllUsers" URL kalmasý
4. Reload edilirse...

SONUÇ: 
? Redirect to /Giris (UserAuthorize attr sayesinde)
```

### Senaryo 2: Bir Student Rolu (0) AdminPanel'e Eriþebilir Mi?
```
1. Student (Rol 0) login olur
2. /AllUsers URL'sine gidilir
3. UserAuthorize(Users="2") kontrolü çalýþýr
4. Rol 0 ? 2 olduðu için...

SONUÇ:
?? Redirect to /Giris (Error handling yok, sadece redirect)
```

### Senaryo 3: HomeController.Index'e Yetkisiz Eriþim
```
1. [UserAuthorize] yorum halinde
2. Token olmadan /Home/Index'e gidilir
3. getuserby() null döner
4. Sayfanýn ne yapacaðý?

SONUÇ:
???? RÝSKLÝ - Yorum halinde attribute nedeniyle AÇIK ERIÞIM
```

### Senaryo 4: AJAX Endpoint Brute Force
```
1. POST /Ajax/CalculateVizeDays
2. Yetki kontrolü YOK
3. Milyonlarca request gönderilebilir

SONUÇ:
?? DoS (Denial of Service) riski
```

---

## ??? BÖLÜM 4: Mevcut Error Handling

### Þu Anda:
```
? HTTP 404 Custom Page: Yok (standart IIS 404)
? HTTP 405 Custom Page: Yok
? HTTP 403 Forbidden Sayfasý: Yok
? Login Redirect: Var (/Giris)
```

### Global.asax.cs
```csharp
protected void Application_Error(object sender, EventArgs e)
{
    ErrorLogHelper.Log(Server.GetLastError(), Context);
    // ? Custom error page yok, sadece log var
}
```

---

## ?? BÖLÜM 5: 405/404 Stratejisi Deðerlendirmesi

### ? AVANTAJLARI:

1. **Açýk Güvenlik**
   - Kullanýcý neye yetkisiz olduðunu bilir
   - Ek gizleme stratejisine ihtiyaç yok

2. **SEO Faydasý**
   - 403/405 ? Search engine bunu index'lemez
   - Gizli admin alanlarý search'te çýkmaz

3. **API/Automation Clarity**
   - JavaScript fetch'leri proper HTTP status elde eder
   - CORS + proper status codes

4. **Profesyonel Görünüþ**
   - Kurumsal uygulamalar 403/405 kullanýr

### ? DÝSAVANTAJLARI:

1. **Security Through Obscurity Farký**
   - 404 (Not Found): "Bu sayfa hiç yok"
   - 403 (Forbidden): "Sayfa var, sen giriþ yapamýyorsun"
   - Attacker'a sayfa varlýðýný bildirir

2. **Brute Force Riski**
   - Admin sayfalarý 403 dönünce
   - Attacker admin sayfalarýnýn kodu bilir
   - Ek güvenlik tedbirleri gerekir

3. **Ek Kod Karmaþýklýðý**
   - Error handling view'larý eklenecek
   - Error controller action'larý yazýlacak

### ?? REKOMENDASYONUMUZ:

**KARMA YAKLAÞIM** kullanýlmalý:
```
1. Admin Panel sayfalarý ? 403 Forbidden
   (Kullanýcýya "yetkisiz" mesajýný ver)

2. Tamamen gizli sistem sayfalarý ? 404 Not Found
   (Ex: /Internal/SecretAPI)

3. Public API endpoints ? 401 Unauthorized (for API)
   (JSON: {"error": "Unauthorized"})
```

---

## ?? BÖLÜM 6: Önerilen Çözümler

### Çözüm 1: HomeController.Index'i Koruma (ACIL)
**Durum**: [UserAuthorize] yorum halinde - RÝSKLÝ!

```csharp
// ÖNCE:
//[UserAuthorize]
public class HomeController : Controller

// SONRA:
[UserAuthorize]
public class HomeController : Controller
```

### Çözüm 2: Global Error Handler ve Custom Error Pages
```csharp
// 1. Global.asax.cs -> HandleErrorAttribute
public class FilterConfig
{
    public static void RegisterGlobalFilters(GlobalFilterCollection filters)
    {
        filters.Add(new HandleErrorAttribute());
    }
}

// 2. Custom error pages
/Views/Error/Index.cshtml (403)
/Views/Error/NotFound.cshtml (404)
/Views/Error/MethodNotAllowed.cshtml (405)
```

### Çözüm 3: Enhanced UserAuthorize Attribute
```csharp
public class UserAuthorize : AuthorizeAttribute
{
    protected override void HandleUnauthorizedRequest(AuthorizationContext filterContext)
    {
        // REDIRECT YERINE 403 DÖNDÜR
        if (filterContext.HttpContext.User.Identity.IsAuthenticated)
        {
            // Rol yetkisi yok
            filterContext.Result = new HttpStatusCodeResult(
                System.Net.HttpStatusCode.Forbidden, 
                "Yetkiniz yetersiz"
            );
        }
        else
        {
            // Login deðil, authentication eksik
            base.HandleUnauthorizedRequest(filterContext);
        }
    }
}
```

### Çözüm 4: AjaxController ve API Endpoints Koruma
```csharp
// AÇIK ERIÞIM OLAN AJAX ENDPOINTS'I KORUyA

[UserAuthorize]  // ? EKLE
public class AjaxController : Controller
{
    // ÝSTÝSNA: Public metodlar için [AllowAnonymous]
    [AllowAnonymous]
    public JsonResult CalculateVizeDays(string entry, string exit)
    {
        // Herkese açýk hesaplama (intentional)
    }
}
```

### Çözüm 5: Tutarlý Authorization Pattern
```csharp
// ESKI (Manuel):
private int? GetCurrentUserId() { }

// YENÝ (Standardized):
[UserAuthorize]  // ? Attribute kullan
public ActionResult MyAction()
{
    // UserAuthorize zaten check etti
    // Kodda user var olduðunu garantile
}
```

### Çözüm 6: Web.config Hatasý Handling
```xml
<configuration>
  <system.web>
    <customErrors mode="On" defaultRedirect="~/Error">
      <error statusCode="404" redirect="~/Error/NotFound" />
      <error statusCode="403" redirect="~/Error/Forbidden" />
      <error statusCode="405" redirect="~/Error/MethodNotAllowed" />
    </customErrors>
  </system.web>
</configuration>
```

---

## ?? BÖLÜM 7: Yetki Kontrol Matrisi

| Controller | Class-Level | Method-Level | Token Check | Role Check | Risk | Status |
|-----------|------------|-------------|-------------|-----------|------|--------|
| **AllUsersController** | ? UserAuthorize(2) | ? | ? | ? Rol 2 | Düþük | ? Güvenli |
| **ErrorLogsController** | ? UserAuthorize(2) | ? | ? | ? Rol 2 | Düþük | ? Güvenli |
| **RolePermissionController** | ? UserAuthorize(2) | ? | ? | ? Rol 2 | Düþük | ? Güvenli |
| **DashboardController** | ? UserAuthorize(2,3,6) | ? | ? | ? Rol 2,3,6 | Orta | ?? Kontrol Gerekli |
| **ProfilController** | ? | ?? Manuel | ? | ? | Orta | ?? Düzeltme Gerekli |
| **VizeController** | ? | ?? Manuel | ? | ? | Orta | ?? Düzeltme Gerekli |
| **EInadController** | ? | ?? Manuel | ? | ? | Orta | ?? Düzeltme Gerekli |
| **HomeController** | ? (Yorum) | ?? Manuel | ? | ? | ?? Yüksek | ?? ACIL FIX |
| **LandingController** | ? | ? | ? | ? | Orta | ? Kasýtlý (Açýk) |
| **AjaxController** | ? | ? | ? | ? | Orta | ?? Seçici Kontrol |
| **GirisController** | ? | ? | ? | ? | Düþük | ? Kasýtlý (Auth) |
| **KosullarController** | ? | ? | ? | ? | Düþük | ? Kasýtlý (Legal) |

---

## ?? BÖLÜM 8: Uygulama Sýrasý (Phased Approach)

### Faz 1 (ACIL - 1-2 gün)
1. ? HomeController'daki `[UserAuthorize]` commentini kaldýr
2. ? ManuelTokenChecker methodlarýný audit et

### Faz 2 (KRÝTÝK - 3-5 gün)
1. ? Global error handler ekle
2. ? Custom error pages oluþtur (403, 404, 405)
3. ? UserAuthorize attribute'ý enhance et

### Faz 3 (STANDARTLAÞMA - 1 hafta)
1. ? Tüm ProfilController, VizeController, EInadController'a `[UserAuthorize]` ekle
2. ? Manuel token kontroller'larýný kaldýr
3. ? AjaxController'a selective [UserAuthorize] ekle

### Faz 4 (TESTING - 1 hafta)
1. ? Penetration testing yap
2. ? Role-based access testing
3. ? HTTP status code testing

---

## ? SONUÇ

### Tespit Edilen Sorunlar:
1. ?? **HomeController açýk eriþim** (Attribute yorum halinde)
2. ?? **Bazý controllers manuel token kontrolü** (ProfilController, VizeController, EInadController)
3. ?? **Global error handling yok**
4. ?? **HTTP 403/404/405 custom pages yok**

### 405/404 Stratejisi:
? **UYGULANMALI** ama seçici olarak:
- Admin sayfalarý ? 403 Forbidden
- Gizli sistem sayfalarý ? 404 Not Found
- Public API ? Proper status codes

### Güvenlik Skoru:
```
Þu Anki: 6/10  ??
Faz 1 Sonrasý: 7.5/10
Faz 2 Sonrasý: 8.5/10
Faz 3 Sonrasý: 9/10
Faz 4 Sonrasý: 9.5/10
```

---

## ?? Ýletiþim / Sorular

Raporun herhangi bir bölümü hakkýnda soru veya açýklama gerekiyorsa, detaylý inceleme yapabilirim.
