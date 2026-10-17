using Owin;

[assembly: Microsoft.Owin.OwinStartup(typeof(gzpegm.Startup))]
namespace gzpegm
{
    public class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            // SignalR configuration removed (no hubs)
        }
    }
}
