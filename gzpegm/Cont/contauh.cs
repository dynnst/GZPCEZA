using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Linq;

namespace gzpegm.Cont
{
    public class contauh
    {
        public List<E_AUH> GetAllAUH()
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_AUH.ToList();
            }
        }
        public E_AUH Check(int fldId, string Country)
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_AUH.Where(c => c.fldId != fldId && c.fldCountry.Trim() == Country.Trim()).SingleOrDefault();
            }
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
                    edit.fldCountry = Country;
                    edit.fldFirstMounth = FirstMounth.Trim();
                    edit.fldKat = Kat.Trim();
                    edit.fldDayStart = Sday.Trim();
                    edit.fldDayKat = Kday.Trim();
                    edit.fldToM = Tom;
                    _db.SaveChanges();
                }
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
            }
            catch (Exception exp)
            {
                throw new Exception("Hata:  Kayıt silinemedi - " + exp.Message.ToString(), exp);
            }
        }
    }
}