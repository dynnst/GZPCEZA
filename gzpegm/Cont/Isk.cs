using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Linq;

namespace gzpegm.Cont
{
    public class Isk
    {
        public List<E_History> GetallHistory()
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_History.OrderByDescending(z => z.fldDatetime).ToList();
            }
        }
        public void DeleteHist(int fldId)
        {
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    E_History histsil = _db.E_History.Where(c => c.fldId == fldId).SingleOrDefault();
                    _db.E_History.Remove(histsil);
                    _db.SaveChanges();
                }
            }
            catch (Exception exp)
            {
                throw new Exception("Hata:  Kayıt silinemedi - " + exp.Message.ToString(), exp);
            }
        }
        public void Addhistory(DateTime bas, DateTime sexit, DateTime bdate, string csure, string ttutar, string User, string Border, string Country)
        {
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    E_History data = new E_History();
                    data.fldStart = bas;
                    data.fldShouldExit = sexit;
                    data.fldBirthDate = bdate;
                    data.fldCountry = Country;
                    data.fldPenalty = csure;
                    data.fldPMoney = ttutar;
                    // store stable identifier with display name to avoid name-change issues
                    // prefer format: "{fldSicil}|{DisplayName}". If caller passed only display name,
                    // try to resolve sicil from E_User table (by name + border) and store combined key.
                    var userValue = (User ?? string.Empty).Trim();
                    if (!userValue.Contains("|"))
                    {
                        // try to find matching user by name and border
                        var found = _db.E_User
                            .Where(u => (u.fldName + " " + u.fldLastName).Trim() == userValue && u.fldBorder == Border)
                            .Select(u => new { u.fldSicil })
                            .FirstOrDefault();
                        if (found != null && !string.IsNullOrEmpty(found.fldSicil))
                        {
                            data.fldUser = found.fldSicil.Trim() + "|" + userValue;
                        }
                        else
                        {
                            data.fldUser = userValue; // fallback: keep as-is
                        }
                    }
                    else
                    {
                        data.fldUser = userValue;
                    }
                    data.fldBorder = Border;
                    data.fldDatetime = DateTime.Now;
                    _db.E_History.Add(data);
                    _db.SaveChanges();
                }
            }
            catch (Exception)
            {

                throw;
            }
        }
        public E_IsK GetdatabyId(int fldId)
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_IsK.Where(c => c.fldId == fldId).SingleOrDefault();
            }
        }
        public void DeleteIsk(int fldId)
        {
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    E_IsK del = _db.E_IsK.Where(c => c.fldId == fldId).SingleOrDefault();
                    _db.E_IsK.Remove(del);
                    _db.SaveChanges();
                }
            }
            catch (Exception exp)
            {
                throw new Exception("Hata:  Kayıt silinemedi - " + exp.Message.ToString(), exp);
            }
        }
        public List<E_IsK> Getalldata()
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_IsK.OrderByDescending(c => c.fldDatetime).ToList();
            }
        }
        public List<E_IsK> GetdataByBorder(string border)
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_IsK
                    .AsNoTracking()
                    .Where(c => c.fldBorder == border)
                    .OrderByDescending(c => c.fldDatetime)
                    .ToList();
            }
        }
        public int GetCountByBorder(string border)
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_IsK.Count(c => c.fldBorder == border);
            }
        }
        public List<E_IsK> GetdataByApprovalAndBorder(string approval, string border, DateTime afterDate)
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_IsK
                    .AsNoTracking()
                    .Where(c => c.fldApproval == approval && c.fldBorder == border && c.fldDatetime > afterDate)
                    .OrderByDescending(c => c.fldDatetime)
                    .ToList();
            }
        }
        public List<ISKmodel> Getalldata2()
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_IsK
                    .AsNoTracking() // Performans için tracking kapatıldı
                    .OrderByDescending(c => c.fldDatetime)
                    .Take(1000) // Son 1000 kayıt - tüm veritabanını yüklemez
                    .Select(c => new ISKmodel
                    {
                        Id = c.fldId,
                        Tarih = c.fldDatetime,
                        Name = c.fldName,
                        Pasaport = c.fldPassport,
                        Kimlik = c.fldIdn,
                        Uyruk = c.fldOrgin,
                        Birth = c.fldBirthdate,
                        Kontrolm = c.fldPassControl,
                        Onay = c.fldApproval,
                        Money = c.fldPMoney,
                        Vize = c.fldVisa,
                        Kapi = c.fldBorder,
                        Resim = c.fldPicture
                    }).ToList();
            }
        }



        public void AddIsk(DateTime dt, string Name, string Pasaport, string Idn, string Uyruğu, DateTime Birthdate, string Form, string PKPolis, string Onypolis, string Border, string Visa, string Money, string Resim)
        {
            try
            {
                var son = new E_IsK();
                son.fldDatetime = dt;
                son.fldName = Name;
                son.fldPassport = Pasaport;
                son.fldIdn = Idn;
                son.fldOrgin = Uyruğu;
                son.fldBirthdate = Birthdate;
                son.fldForm = Form;
                son.fldPassControl = PKPolis;
                son.fldApproval = Onypolis;
                son.fldBorder = Border;
                son.fldVisa = Visa;
                son.fldPMoney = Money;
                son.fldPicture = Resim;
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    _db.E_IsK.Add(son);
                    _db.SaveChanges();
                }
            }
            catch (Exception exp)
            {
                throw new Exception("Hata:  Kayıt eklenemedi - " + exp.Message.ToString(), exp);
            }
        }

    }
}