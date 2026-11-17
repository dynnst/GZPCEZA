using gzpegm.Models;
using System;
using System.Linq;

namespace gzpegm.Cont
{
    public class ContFormT
    {
        public void UpdateForm(string GB, string GBC, string DE, string DEC, string RU, string RUC, string IR, string IRC, string IRK, string IRKC, string FRC, string FR, string Cin = null, string CinC = null, string Yunan = null, string YunanC = null)
        {
            try
            {
                using (GZPEGM1 _db = new GZPEGM1())
                {
                    E_Forms edit = _db.E_Forms.Where(c => c.fldId == 1).SingleOrDefault();
                    edit.fldGB = GB;
                    edit.fldGBC = GBC;
                    edit.fldDE = DE;
                    edit.fldDEC = DEC;
                    edit.fldRU = RU;
                    edit.fldRUC = RUC;
                    edit.fldIR = IR;
                    edit.fldIRC = IRC;
                    edit.fldIRK = IRK;
                    edit.fldIRKC = IRKC;
                    edit.fldFransizcaC = FRC;
                    edit.fldFransizca = FR;
                    if (Cin != null) edit.fldCin = Cin;
                    if (CinC != null) edit.fldCinC = CinC;
                    if (Yunan != null) edit.fldYunan = Yunan;
                    if (YunanC != null) edit.fldYunanC = YunanC;
                    _db.SaveChanges();
                }
            }
            catch (Exception exp)
            {
                throw new Exception("Hata:  Kayıt güncellenemedi - " + exp.Message.ToString(), exp);
            }
        }
        public E_Forms GetAllForms()
        {
            using (GZPEGM1 _db = new GZPEGM1())
            {
                return _db.E_Forms.Where(c => c.fldId == 1).SingleOrDefault();
            }
        }
    }
}