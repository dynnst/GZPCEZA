using System.ComponentModel.DataAnnotations.Schema;

namespace gzpegm.Models
{
    // E_Inad kýsmý partial, buraya view için ek alan ekliyoruz.
    public partial class E_Inad
    {
        [NotMapped]
        public string DigerSebepAciklama { get; set; }
    }
}