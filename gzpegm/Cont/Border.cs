using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Linq;

namespace gzpegm.Cont
{
    public class Border
    {
        public E_Border GetbyName(string Name)
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_Border.Where(c => c.fldName == Name).SingleOrDefault();
            }
        }
        public List<E_Border> GetAll()
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_Border.ToList();
            }
        }
        public void addBorder(string Name)
        {
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    E_Border data = new E_Border();
                    data.fldName = Name.ToUpper();
                    _db.E_Border.Add(data);
                    _db.SaveChanges();
                }
            }
            catch (Exception)
            {

                throw;
            }
        }
        public void deleteBorder(int Id)
        {
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    var delete = _db.E_Border.Where(c => c.fldId == Id).SingleOrDefault();
                    _db.E_Border.Remove(delete);
                    _db.SaveChanges();
                }
            }
            catch (Exception)
            {

                throw;
            }
        }
    }
}