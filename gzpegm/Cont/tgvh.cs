using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Globalization;

namespace gzpegm.Cont
{
    public class tgvh
    {
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
            }
            catch (Exception exp)
            {
                throw new Exception("Hata:  Güncellenemedi - " + exp.Message.ToString(), exp);
            }
        }
        public E_Defter GetDefter()
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_Defter.Where(c => c.fldId == 1).SingleOrDefault();
            }
        }
        public List<E_TGVH> GetTGVH()
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_TGVH.ToList();
            }
        }
        public E_TGVH checkTGVH(string Year)
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_TGVH.Where(c => c.fldYear.Trim() == Year.Trim()).SingleOrDefault();
            }
        }
        /// <summary>
        /// Returns the current kaşe vize (per-day) price from E_TGVH table.
        /// Falls back to first available record or default 10 if parsing fails.
        /// </summary>
        public decimal GetCurrentPrice(decimal defaultValue = 10m)
        {
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    // Try to get by current year first
                    var yearRec = _db.E_TGVH.Where(c => c.fldYear != null && c.fldYear.Trim() == DateTime.Now.Year.ToString()).SingleOrDefault();
                    var rec = yearRec ?? _db.E_TGVH.OrderByDescending(c => c.fldId).FirstOrDefault();
                    if (rec != null && !string.IsNullOrWhiteSpace(rec.fldPrice))
                    {
                        // Try parse with invariant culture
                        decimal d;
                        if (decimal.TryParse(rec.fldPrice.Trim(), NumberStyles.Any, CultureInfo.InvariantCulture, out d))
                            return d;
                        // Try parse with current culture as fallback
                        if (decimal.TryParse(rec.fldPrice.Trim(), NumberStyles.Any, CultureInfo.CurrentCulture, out d))
                            return d;
                    }
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
            }
            catch (Exception exp)
            {
                throw new Exception("Hata:  Güncellenemedi - " + exp.Message.ToString(), exp);
            }
        }
    }
}