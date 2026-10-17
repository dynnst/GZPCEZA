namespace gzpegm.Migrations
{
    using gzpegm.Models;
    using System.Data.Entity.Migrations;
    using System.Linq;

    internal sealed class Configuration : DbMigrationsConfiguration<gzpegm.Models.GZPEGM1>
    {
        public Configuration()
        {
            AutomaticMigrationsEnabled = false;
            MigrationsNamespace = "gzpegm.Migrations";
            ContextKey = "gzpegm.Models.GZPEGM1";
        }

        protected override void Seed(gzpegm.Models.GZPEGM1 context)
        {
            // Varsayýlan kategoriler
            if (!context.Categories.Any())
            {
                context.Categories.AddOrUpdate(
                    c => c.CategoryName,
                    new Categories { CategoryName = "Genel Eðitim", Description = "Genel eðitim kurslarý", IsActive = true },
                    new Categories { CategoryName = "Teknik Eðitim", Description = "Teknik bilgi ve beceri eðitimi", IsActive = true },
                    new Categories { CategoryName = "Dil Eðitimi", Description = "Yabancý dil kurslarý", IsActive = true }
                );
            }

            // Varsayýlan sýnýr kapýlarý
            if (!context.E_Border.Any())
            {
                context.E_Border.AddOrUpdate(
                    b => b.fldName,
                    new E_Border { fldName = "Ýstanbul Atatürk Havalimaný" },
                    new E_Border { fldName = "Ankara Esenboða Havalimaný" },
                    new E_Border { fldName = "Ýzmir Adnan Menderes Havalimaný" }
                );
            }

            context.SaveChanges();
        }
    }
}
