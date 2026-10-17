using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Linq;

namespace gzpegm.Cont
{
    public class ContTKod
    {
        public E_TKOD GetTkodBydays(int ceza, byte tip)
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                var check = _db.E_TKOD.Where(c => c.fldStart <= ceza && c.fldFinish >= ceza && c.fldPaid == tip).ToList();
                if (check.Count > 1)
                {
                    return check[0];
                }
                else
                {
                    return _db.E_TKOD.Where(c => c.fldStart <= ceza && c.fldFinish >= ceza && c.fldPaid == tip).SingleOrDefault();
                }
            }
        }
        public List<E_TKOD> GetAllCodes()
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_TKOD.ToList();
            }
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
            }
            catch (Exception exp)
            {
                throw new Exception("Hata:  Kayıt eklenemedi - " + exp.Message.ToString(), exp);
            }

        }
        public E_TKOD Check(int fldId, string Code, string idari, int fldPaid)
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_TKOD.Where(c => c.fldId != fldId && c.fldCode.Trim() == Code.Trim() && c.fldIdariCode.Trim() == idari.Trim() && c.fldPaid == fldPaid).SingleOrDefault();
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
            }


            catch (Exception exp)
            {
                throw new Exception("Hata:  Kayıt silinemedi - " + exp.Message.ToString(), exp);
            }
        }
    }
}