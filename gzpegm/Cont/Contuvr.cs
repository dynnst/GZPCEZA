using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace gzpegm.Cont
{
    public class Contuvr
    {
        private static readonly object _uvrLock = new object();
        private const string UVR_CACHE_KEY = "CACHE_ALL_E_UVR";

        public static void ClearCache()
        {
            try { HttpRuntime.Cache.Remove(UVR_CACHE_KEY); } catch { }
        }

        public void DeleteUVR(int fldId)
        {
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    E_UVR delete = _db.E_UVR.Where(c => c.fldId == fldId).SingleOrDefault();
                    _db.E_UVR.Remove(delete);
                    _db.SaveChanges();
                }
                ClearCache();
            }
            catch (Exception exp)
            {
                throw new Exception("Hata:  Kayıt silinemedi - " + exp.Message.ToString(), exp);
            }
        }

        public void EditUVR(int fldId, string country, int Calculate, int Passport, int Visa, int Day, int Long, int Onetime, byte HB)
        {
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    E_UVR edit = _db.E_UVR.Where(c => c.fldId == fldId).SingleOrDefault();
                    edit.fldCountry = country.Trim();
                    edit.fldCalculateType = Calculate;
                    edit.fldPassportType = Passport;
                    edit.fldVisaStatus = Visa;
                    edit.fldDay = Day;
                    edit.fldLong = Long;
                    edit.fldOneTime = Onetime;
                    edit.fldHB = HB;
                    _db.SaveChanges();
                }
                ClearCache();
            }
            catch (Exception exp)
            {
                throw new Exception("Hata:  Kayıt güncellenemedi - " + exp.Message.ToString(), exp);
            }
        }

        public void AddUVR(string country, int Calculate, int Passport, int Visa, int Day, int Long, int Onetime, byte HB)
        {
            var UVR = new E_UVR();
            UVR.fldCountry = country.Trim();
            UVR.fldCalculateType = Calculate;
            UVR.fldPassportType = Passport;
            UVR.fldVisaStatus = Visa;
            UVR.fldDay = Day;
            UVR.fldLong = Long;
            UVR.fldOneTime = Onetime;
            UVR.fldHB = HB;
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    _db.E_UVR.Add(UVR);
                    _db.SaveChanges();
                }
                ClearCache();
            }
            catch (Exception exp)
            {
                throw new Exception("Hata:  Kayıt eklenemedi - " + exp.Message.ToString(), exp);
            }
        }

        public List<E_UVR> GetAllUVR()
        {
            var cached = HttpRuntime.Cache[UVR_CACHE_KEY] as List<E_UVR>;
            if (cached != null) return cached;

            lock (_uvrLock)
            {
                cached = HttpRuntime.Cache[UVR_CACHE_KEY] as List<E_UVR>;
                if (cached != null) return cached;

                using (GZPEGM1 _db = new GZPEGM1())
                {
                    cached = _db.E_UVR.AsNoTracking().ToList();
                    HttpRuntime.Cache.Insert(UVR_CACHE_KEY, cached, null, System.Web.Caching.Cache.NoAbsoluteExpiration, TimeSpan.FromHours(12));
                    return cached;
                }
            }
        }

        public E_UVR check(int fldId, string Country, int Passport, int Visa, int Ctype)
        {
            if (string.IsNullOrWhiteSpace(Country)) return null;
            string cClean = Country.Trim();

            var all = GetAllUVR();
            return all.FirstOrDefault(c => c.fldId != fldId
                && string.Equals(c.fldCountry?.Trim(), cClean, StringComparison.OrdinalIgnoreCase)
                && c.fldPassportType == Passport
                && c.fldVisaStatus == Visa
                && c.fldCalculateType == Ctype);
        }

        public E_UVR GetByCountry(string country)
        {
            if (string.IsNullOrWhiteSpace(country)) return null;
            string cClean = country.Trim();

            var all = GetAllUVR();
            return all.FirstOrDefault(c => c.fldCountry != null && string.Equals(c.fldCountry.Trim(), cClean, StringComparison.OrdinalIgnoreCase));
        }

        public E_UVR GetKaseVizeByCountry(string country)
        {
            if (string.IsNullOrWhiteSpace(country)) return null;
            string cClean = country.Trim();

            var all = GetAllUVR();
            return all
                .Where(c => c.fldCountry != null
                    && string.Equals(c.fldCountry.Trim(), cClean, StringComparison.OrdinalIgnoreCase)
                    && (c.fldVisaStatus == 2 || c.fldVisaStatus == 1 || c.fldVisaStatus == 3))
                .OrderBy(c => c.fldVisaStatus == 2 ? 0 : (c.fldVisaStatus == 1 ? 1 : 2))
                .ThenBy(c => c.fldPassportType)
                .ThenBy(c => c.fldCalculateType)
                .FirstOrDefault();
        }

        public List<string> GetAllCountryNames()
        {
            var all = GetAllUVR();
            return all
                .Where(x => !string.IsNullOrWhiteSpace(x.fldCountry))
                .Select(x => x.fldCountry.Trim())
                .Distinct()
                .OrderBy(x => x)
                .ToList();
        }
    }
}
