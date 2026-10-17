using System.Web.Mvc;

namespace gzpegm
{
    /// <summary>
    /// Global filter configuration for ASP.NET MVC
    /// Registers error handling and authorization filters
    /// </summary>
    public class FilterConfig
    {
        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
            // Handle errors globally and display error page instead of exception details
            filters.Add(new HandleErrorAttribute());
        }
    }
}
