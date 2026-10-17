using gzpegm.Models;
using System;
using System.Linq;

namespace gzpegm.Cont
{
    public class ContExchange
    {
        public E_Exchange GetAllExchange()
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_Exchange.Where(c => c.fldId == 1).SingleOrDefault();
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
            }
            catch (Exception exp)
            {
                throw new Exception("Hata:  Kayıt güncellenemedi - " + exp.Message.ToString(), exp);
            }
        }
    }
}