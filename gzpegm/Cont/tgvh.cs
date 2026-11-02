using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Globalization;
using System.Web;

namespace gzpegm.Cont
{
    public class tgvh
    {
        private static readonly object _tgvhLock = new object();
        private const string TGVH_CACHE_KEY = "CACHE_ALL_E_TGVH";
        private const string DEFTER_CACHE_KEY = "CACHE_E_DEFTER";

        public static void ClearCache()
        {
            try
            {
                HttpRuntime.Cache.Remove(TGVH_CACHE_KEY);
                HttpRuntime.Cache.Remove(DEFTER_CACHE_KEY);
            }
            catch { }
        }

        public void EditDefter(string Price, string TOM)
        {
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    E_Defter edit = _db.E_Defter.Where(msc => msc.fldId == 1).SingleOrDefault();
                    edit.fldPrice = Price;
                    edit.fldTypeofMoney = TOM;
                    _db.SaveChanges();
                }
                ClearCache();
            }
            catch (Exception exp)
            {
                throw new Exception("Hata:  Güncellenemedi - " + exp.Message.ToString(), exp);
            }
        }

        public E_Defter GetDefter()
        {
            var cached = HttpRuntime.Cache[DEFTER_CACHE_KEY] as E_Defter;
            if (cached != null) return cached;

            lock (_tgvhLock)
            {
                cached = HttpRuntime.Cache[DEFTER_CACHE_KEY] as E_Defter;
                if (cached != null) return cached;

                using (GZPEGM1 _db = new GZPEGM1())
                {
                    cached = _db.E_Defter.AsNoTracking().FirstOrDefault(c => c.fldId == 1);
                    if (cached != null)
                    {
                        HttpRuntime.Cache.Insert(DEFTER_CACHE_KEY, cached, null, System.Web.Caching.Cache.NoAbsoluteExpiration, TimeSpan.FromHours(12));
                    }
                    return cached;
                }
            }
        }

        public List<E_TGVH> GetTGVH()
        {
            var cached = HttpRuntime.Cache[TGVH_CACHE_KEY] as List<E_TGVH>;
            if (cached != null) return cached;

            lock (_tgvhLock)
            {
                cached = HttpRuntime.Cache[TGVH_CACHE_KEY] as List<E_TGVH>;
                if (cached != null) return cached;

                using (GZPEGM1 _db = new GZPEGM1())
                {
                    cached = _db.E_TGVH.AsNoTracking().ToList();
                    HttpRuntime.Cache.Insert(TGVH_CACHE_KEY, cached, null, System.Web.Caching.Cache.NoAbsoluteExpiration, TimeSpan.FromHours(12));
                    return cached;
                }
            }
        }

        public E_TGVH checkTGVH(string Year)
        {
            if (string.IsNullOrWhiteSpace(Year)) return null;
            string yClean = Year.Trim();

            var all = GetTGVH();
            return all.FirstOrDefault(c => string.Equals(c.fldYear?.Trim(), yClean, StringComparison.OrdinalIgnoreCase));
        }

        public decimal GetCurrentPrice(decimal defaultValue = 10m)
        {
            try
            {
                var all = GetTGVH();
                string curYear = DateTime.Now.Year.ToString();
                var yearRec = all.FirstOrDefault(c => c.fldYear != null && string.Equals(c.fldYear.Trim(), curYear, StringComparison.OrdinalIgnoreCase));
                var rec = yearRec ?? all.OrderByDescending(c => c.fldId).FirstOrDefault();
                if (rec != null && !string.IsNullOrWhiteSpace(rec.fldPrice))
                {
                    decimal d;
                    if (decimal.TryParse(rec.fldPrice.Trim(), NumberStyles.Any, CultureInfo.InvariantCulture, out d))
                        return d;
                    if (decimal.TryParse(rec.fldPrice.Trim(), NumberStyles.Any, CultureInfo.CurrentCulture, out d))
                        return d;
                }
            }
            catch
            {
                // ignore and use default
            }
            return defaultValue;
        }

        public void addTGVH(string Price, string Tarih)
        {
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    E_TGVH edit = new E_TGVH();
                    edit.fldPrice = Price;
                    edit.fldTypeofMoney = "TRY";
                    edit.fldYear = Tarih;
                    _db.E_TGVH.Add(edit);
                    _db.SaveChanges();
                }
                ClearCache();
            }
            catch (Exception exp)
            {
                throw new Exception("Hata:  Güncellenemedi - " + exp.Message.ToString(), exp);
            }
        }

        public void DeleteTGVH(int fldId)
        {
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    E_TGVH edit = _db.E_TGVH.Where(msc => msc.fldId == fldId).SingleOrDefault();
                    _db.E_TGVH.Remove(edit);
                    _db.SaveChanges();
                }
                ClearCache();
            }
            catch (Exception exp)
            {
                throw new Exception("Hata:  Güncellenemedi - " + exp.Message.ToString(), exp);
            }
        }
    }
}
