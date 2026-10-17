using System.ComponentModel.DataAnnotations.Schema;

namespace gzpegm.Models
{
    public partial class CertificateRequest
    {
        [NotMapped]
        public E_User E_User { get; set; }

        [NotMapped]
        public Courses Courses { get; set; }
    }
}
