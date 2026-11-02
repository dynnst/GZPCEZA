using gzpegm.Models;
using System;
using System.Linq;
using System.Web;

namespace gzpegm.Cont
{
    public class ContExchange
    {
        private static readonly object _exLock = new object();
        private const string EX_CACHE_KEY = "CACHE_E_EXCHANGE";

        public static void ClearCache()
        {
            try { HttpRuntime.Cache.Remove(EX_CACHE_KEY); } catch { }
        }

        public E_Exchange GetAllExchange()
        {
            var cached = HttpRuntime.Cache[EX_CACHE_KEY] as E_Exchange;
            if (cached != null) return cached;

            lock (_exLock)
            {
                cached = HttpRuntime.Cache[EX_CACHE_KEY] as E_Exchange;
                if (cached != null) return cached;

                using (GZPEGM1 _db = new GZPEGM1())
                {
                    cached = _db.E_Exchange.AsNoTracking().FirstOrDefault(c => c.fldId == 1);
                    if (cached != null)
                    {
                        HttpRuntime.Cache.Insert(EX_CACHE_KEY, cached, null, System.Web.Caching.Cache.NoAbsoluteExpiration, TimeSpan.FromMinutes(30));
                    }
                    return cached;
                }
            }
        }

        public void EditExchange(string Euro, string Dollar, string Paund)
        {
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    E_Exchange edit = _db.E_Exchange.Where(c => c.fldId == 1).SingleOrDefault();
                    edit.fldEuro = Euro.Trim();
                    edit.fldDollar = Dollar.Trim();
                    edit.fldPaund = Paund.Trim();
                    _db.SaveChanges();
                }
                ClearCache();
            }
            catch (Exception exp)
            {
                throw new Exception("Hata:  Kayıt güncellenemedi - " + exp.Message.ToString(), exp);
            }
        }
    }
}
