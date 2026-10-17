using System;
using System.Collections.Generic;

namespace gzpegm.Models.ViewModels
{
    public class BorderItemViewModel
    {
        public int fldId { get; set; }
        public string fldName { get; set; }
        public int PersonnelCount { get; set; }
    }

    public class BorderPersonnelViewModel
    {
        public int Id { get; set; }
        public string Sicil { get; set; }
        public string FullName { get; set; }
        public string Title { get; set; }
        public string Deputy { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public string Role { get; set; }
        public bool IsActive { get; set; }
        public string Picture { get; set; }
        public string LastLogin { get; set; }
        public string CreatedDate { get; set; }
    }
}
