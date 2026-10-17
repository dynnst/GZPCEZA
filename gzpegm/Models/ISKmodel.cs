using System;

namespace gzpegm.Models
{
    public class ISKmodel
    {
        public int Id { get; set; }
        public DateTime? Tarih { get; set; }
        public string Name { get; set; }
        public string Pasaport { get; set; }
        public string Kimlik { get; set; }
        public string Uyruk { get; set; }
        public DateTime? Birth { get; set; }
        public string Kontrolm { get; set; }
        public string Onay { get; set; }
        public string Vize { get; set; }
        public string Money { get; set; }
        public string Kapi { get; set; }
        public string Resim { get; set; }

    }
}