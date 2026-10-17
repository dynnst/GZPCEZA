using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace gzpegm.Models
{
    public partial class E_Messages
    {
        // Navigation properties with friendly names
        [NotMapped]
        public E_User Sender => E_User;

        [NotMapped]
        public E_User Recipient => E_User1;

        [NotMapped]
        public E_Messages ParentMessage => E_Messages2;

        [NotMapped]
        public ICollection<E_Messages> Replies => E_Messages1;
    }
}
