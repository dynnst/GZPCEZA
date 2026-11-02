using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace gzpegm.Cont
{
    public class ContTKod
    {
        private static readonly object _tkodLock = new object();
        private const string TKOD_CACHE_KEY = "CACHE_ALL_E_TKOD";

        public static void ClearCache()
        {
            try { HttpRuntime.Cache.Remove(TKOD_CACHE_KEY); } catch { }
        }

        public List<E_TKOD> GetAllCodes()
        {
            var cached = HttpRuntime.Cache[TKOD_CACHE_KEY] as List<E_TKOD>;
            if (cached != null) return cached;

            lock (_tkodLock)
            {
                cached = HttpRuntime.Cache[TKOD_CACHE_KEY] as List<E_TKOD>;
                if (cached != null) return cached;

                using (GZPEGM1 _db = new GZPEGM1())
                {
                    cached = _db.E_TKOD.AsNoTracking().ToList();
                    HttpRuntime.Cache.Insert(TKOD_CACHE_KEY, cached, null, System.Web.Caching.Cache.NoAbsoluteExpiration, TimeSpan.FromHours(12));
                    return cached;
                }
            }
        }

        public E_TKOD GetTkodBydays(int ceza, byte tip)
        {
            var all = GetAllCodes();
            var check = all.Where(c => c.fldStart <= ceza && c.fldFinish >= ceza && c.fldPaid == tip).ToList();
            if (check.Count > 1)
            {
                return check[0];
            }
            else
            {
                return check.SingleOrDefault();
            }
        }

        public E_TKOD Check(int fldId, string Code, string idari, int fldPaid)
        {
            if (string.IsNullOrWhiteSpace(Code)) return null;
            string cCode = Code.Trim();
            string cIdari = (idari ?? "").Trim();

            var all = GetAllCodes();
            return all.FirstOrDefault(c => c.fldId != fldId 
                && string.Equals(c.fldCode?.Trim(), cCode, StringComparison.OrdinalIgnoreCase) 
                && string.Equals(c.fldIdariCode?.Trim(), cIdari, StringComparison.OrdinalIgnoreCase) 
                && c.fldPaid == fldPaid);
        }

        public void AddTKOD(string Code, string Sure, int Start, int Finish, string Idari, byte Payment)
        {
            var TKOd = new E_TKOD();
            TKOd.fldCode = Code.Trim();
            TKOd.fldPTime = Sure;
            TKOd.fldStart = Start;
            TKOd.fldFinish = Finish;
            TKOd.fldIdariCode = Idari;
            TKOd.fldPaid = Payment;
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    _db.E_TKOD.Add(TKOd);
                    _db.SaveChanges();
                }
                ClearCache();
            }
            catch (Exception exp)
            {
                throw new Exception("Hata:  Kayıt eklenemedi - " + exp.Message.ToString(), exp);
            }
        }

        public void EditTKOD(int fldId, string Code, string Sure, int Start, int Finish, string Idari, byte Payment)
        {
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    E_TKOD edit = _db.E_TKOD.Where(c => c.fldId == fldId).SingleOrDefault();
                    edit.fldCode = Code.Trim();
                    edit.fldPTime = Sure;
                    edit.fldStart = Start;
                    edit.fldFinish = Finish;
                    edit.fldIdariCode = Idari;
                    edit.fldPaid = Payment;
                    _db.SaveChanges();
                }
                ClearCache();
            }
            catch (Exception exp)
            {
                throw new Exception("Hata:  Kayıt güncellenemedi - " + exp.Message.ToString(), exp);
            }
        }

        public void DeleteTKod(int fldId)
        {
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    E_TKOD delete = _db.E_TKOD.Where(c => c.fldId == fldId).SingleOrDefault();
                    _db.E_TKOD.Remove(delete);
                    _db.SaveChanges();
                }
                ClearCache();
            }
            catch (Exception exp)
            {
                throw new Exception("Hata:  Kayıt silinemedi - " + exp.Message.ToString(), exp);
            }
        }

        public void DeleteTKOD(int fldId)
        {
            DeleteTKod(fldId);
        }
    }
}
