using System;
using System.Data.Entity;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Routing;
using gzpegm.Helpers;

namespace gzpegm
{
    public class Global : HttpApplication
    {
        void Application_Start(object sender, EventArgs e)
        {
            // Entity Framework pre-compilation - Ilk yuklemeyi ve cold-start'i hizlandirir
            try
            {
                using (var db = new Models.GZPEGM1())
                {
                    // EF6 metadata ve mapping view derlemesini tetikle
                    var _ = db.E_User.AsNoTracking().Take(1).ToList();
                }
            }
            catch
            {
                // Baglanti hatasi olsa bile uygulama calissin
            }

            AreaRegistration.RegisterAllAreas();
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            GlobalConfiguration.Configure(WebApiConfig.Register);
            RouteConfig.RegisterRoutes(RouteTable.Routes);

            // Arka planda sık kullanılan ana tabloları ve EF sorgu planlarını ısıt (Non-blocking Warm-up)
            System.Web.Hosting.HostingEnvironment.QueueBackgroundWorkItem(ct =>
            {
                try
                {
                    using (var db = new Models.GZPEGM1())
                    {
                        var _1 = db.E_Token.AsNoTracking().Take(1).ToList();
                        var _2 = db.E_History.AsNoTracking().Take(1).ToList();
                        var _3 = db.E_Forms.AsNoTracking().Take(1).ToList();
                        var _4 = db.TahditKod.AsNoTracking().Take(1).ToList();
                        var _5 = db.E_Inad.AsNoTracking().Take(1).ToList();
                        var _6 = db.E_UVR.AsNoTracking().Take(1).ToList();
                    }
                }
                catch { }
            });
        }

        protected void Application_BeginRequest(object sender, EventArgs e)
        {
            try
            {
                if (ServerFailoverHelper.ShouldRedirect(Context, out string targetUrl))
                {
                    Response.Redirect(targetUrl, false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }
            }
            catch
            {
                // Yönlendirme kontrolünde istisna olursa normal akışa devam et
            }
        }

        protected void Application_Error(object sender, EventArgs e)
        {
            var ex = Server.GetLastError();
            if (ex is HttpException httpEx)
            {
                var code = httpEx.GetHttpCode();
                var path = Request?.Path?.ToLowerInvariant() ?? "";
                if (code == 404 && (path.EndsWith(".ico") || path.EndsWith(".css") || path.EndsWith(".js") || path.EndsWith(".png") || path.EndsWith(".jpg") || path.EndsWith(".map") || path.EndsWith(".woff") || path.EndsWith(".woff2")))
                {
                    return;
                }
            }
            ErrorLogHelper.Log(ex, Context);
        }

    }
}