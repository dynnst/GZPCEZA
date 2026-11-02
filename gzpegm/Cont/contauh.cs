using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace gzpegm.Cont
{
    public class contauh
    {
        private static readonly object _auhLock = new object();
        private const string AUH_CACHE_KEY = "CACHE_ALL_E_AUH";

        public static void ClearCache()
        {
            try { HttpRuntime.Cache.Remove(AUH_CACHE_KEY); } catch { }
        }

        public List<E_AUH> GetAllAUH()
        {
            var cached = HttpRuntime.Cache[AUH_CACHE_KEY] as List<E_AUH>;
            if (cached != null) return cached;

            lock (_auhLock)
            {
                cached = HttpRuntime.Cache[AUH_CACHE_KEY] as List<E_AUH>;
                if (cached != null) return cached;

                using (GZPEGM1 _db = new GZPEGM1())
                {
                    cached = _db.E_AUH.AsNoTracking().ToList();
                    HttpRuntime.Cache.Insert(AUH_CACHE_KEY, cached, null, System.Web.Caching.Cache.NoAbsoluteExpiration, TimeSpan.FromHours(12));
                    return cached;
                }
            }
        }

        public E_AUH Check(int fldId, string Country)
        {
            if (string.IsNullOrWhiteSpace(Country)) return null;
            string cClean = Country.Trim();

            var all = GetAllAUH();
            return all.FirstOrDefault(c => c.fldId != fldId && string.Equals(c.fldCountry?.Trim(), cClean, StringComparison.OrdinalIgnoreCase));
        }

        public void AddAUH(string Country, string FirstMounth, string Kat, string Sday, string Kday, string Tom)
        {
            var AUH = new E_AUH();
            AUH.fldCountry = Country.Trim();
            AUH.fldFirstMounth = FirstMounth.Trim();
            AUH.fldKat = Kat.Trim();
            AUH.fldDayStart = Sday.Trim();
            AUH.fldDayKat = Kday.Trim();
            AUH.fldToM = Tom;
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    _db.E_AUH.Add(AUH);
                    _db.SaveChanges();
                }
                ClearCache();
            }
            catch (Exception exp)
            {
                throw new Exception("Hata:  Kayıt eklenemedi - " + exp.Message.ToString(), exp);
            }
        }

        public void EditAUH(int fldId, string Country, string FirstMounth, string Kat, string Sday, string Kday, string Tom)
        {
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    E_AUH edit = _db.E_AUH.Where(c => c.fldId == fldId).SingleOrDefault();
                    edit.fldCountry = Country.Trim();
                    edit.fldFirstMounth = FirstMounth.Trim();
                    edit.fldKat = Kat.Trim();
                    edit.fldDayStart = Sday.Trim();
                    edit.fldDayKat = Kday.Trim();
                    edit.fldToM = Tom;
                    _db.SaveChanges();
                }
                ClearCache();
            }
            catch (Exception exp)
            {
                throw new Exception("Hata:  Kayıt güncellenemedi - " + exp.Message.ToString(), exp);
            }
        }

        public void DeleteAUH(int fldId)
        {
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    E_AUH edit = _db.E_AUH.Where(c => c.fldId == fldId).SingleOrDefault();
                    _db.E_AUH.Remove(edit);
                    _db.SaveChanges();
                }
                ClearCache();
            }
            catch (Exception exp)
            {
                throw new Exception("Hata:  Kayıt silinemedi - " + exp.Message.ToString(), exp);
            }
        }
    }
}
