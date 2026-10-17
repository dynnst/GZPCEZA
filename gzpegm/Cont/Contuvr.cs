using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Linq;

namespace gzpegm.Cont
{
    public class Contuvr
    {
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
            }
            catch (Exception exp)
            {
                throw new Exception("Hata:  Kayıt eklenemedi - " + exp.Message.ToString(), exp);
            }
        }
        public E_UVR check(int fldId, string Country, int Passport, int Visa, int Ctype)
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_UVR.Where(c => c.fldId != fldId && c.fldCountry.Trim() == Country.Trim() && c.fldPassportType == Passport && c.fldVisaStatus == Visa && c.fldCalculateType == Ctype).SingleOrDefault();
            }
        }
        public List<E_UVR> GetAllUVR()
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_UVR.ToList();
            }
        }

        public E_UVR GetByCountry(string country)
        {
            if (string.IsNullOrWhiteSpace(country)) return null;
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_UVR.Where(c => c.fldCountry != null && c.fldCountry.Trim() == country.Trim()).FirstOrDefault();
            }
        }

        public E_UVR GetKaseVizeByCountry(string country)
        {
            if (string.IsNullOrWhiteSpace(country)) return null;
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_UVR
                    .Where(c => c.fldCountry != null
                        && c.fldCountry.Trim() == country.Trim()
                        && (c.fldVisaStatus == 2 || c.fldVisaStatus == 1 || c.fldVisaStatus == 3))
                    .OrderBy(c => c.fldVisaStatus == 2 ? 0 : (c.fldVisaStatus == 1 ? 1 : 2))
                    .ThenBy(c => c.fldPassportType)
                    .ThenBy(c => c.fldCalculateType)
                    .FirstOrDefault();
            }
        }

        public List<string> GetAllCountryNames()
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_UVR
                    .Where(x => x.fldCountry != null && x.fldCountry != "")
                    .Select(x => x.fldCountry.Trim())
                    .Distinct()
                    .OrderBy(x => x)
                    .ToList();
            }
        }

    }
}
