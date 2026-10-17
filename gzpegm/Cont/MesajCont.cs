using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Linq;

namespace gzpegm.Cont
{
    public class MesajCont
    {
        public E_Messages GetMesajById(int fldId)
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_Messages.Where(c => c.fldId == fldId).SingleOrDefault();


            }
        }
        public List<E_Messages> GetAll()
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_Messages.OrderByDescending(z => z.fldDateTime).ToList();
            }
        }
        public void SendMessage(string NameUser, string sicilUser, string PhoneUser, string EmailUser, string MessageUser)
        {
            try
            {
                E_Messages yeni = new E_Messages();
                yeni.fldSendByName = NameUser;
                yeni.fldSendBySicil = sicilUser;
                yeni.fldSendByPhone = PhoneUser;
                yeni.fldSendByMail = EmailUser;
                yeni.fldMessage = MessageUser;
                yeni.fldDateTime = DateTime.Now;
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    _db.E_Messages.Add(yeni);
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