using System;

namespace gzpegm.Models.ViewModels
{
    public class BorderOperationViewModel
    {
        public int Id { get; set; }
        public DateTime? Date { get; set; }
        public string PassengerName { get; set; }
        public string Nationality { get; set; }
        public string Amount { get; set; }
        public string Visa { get; set; }
        public string TahditCode { get; set; }
        public string AdministrativeTahditCode { get; set; }
        public string Officer { get; set; }
    }
}
