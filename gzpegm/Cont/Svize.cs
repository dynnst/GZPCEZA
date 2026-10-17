using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Linq;

namespace gzpegm.Cont
{
    public class Svize
    {
        public E_Sartli GetbyId(int Id)
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_Sartli.Where(c => c.fldId == Id).SingleOrDefault();
            }
        }
        public List<E_Sartli> Getallsvize()
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_Sartli.OrderByDescending(c => c.fldDate).ToList();
            }
        }
        public E_Sartli addSVize(string By, string Orgin, DateTime Bdate, DateTime Date, string Name, string Border)
        {
            E_Sartli data = new E_Sartli();
            data.fldBy = By;
            data.fldOrgin = Orgin;
            data.fldBdate = Bdate;
            data.fldDate = Date;
            data.fldName = Name;
            data.fldBorder = Border;
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    _db.E_Sartli.Add(data);
                    _db.SaveChanges();
                }
            }
            catch (Exception)
            {

                throw;
            }
            return data;
        }
    }
}