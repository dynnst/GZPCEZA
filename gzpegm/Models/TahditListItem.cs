using System;

namespace gzpegm.Models
{
    // Simple DTO to hold list view fields and avoid dynamic/anonymous typing issues in Razor
    public class TahditListItem
    {
        public int Id { get; set; }
        public string Kod { get; set; }
        public string Aciklama { get; set; }
        public int? SureAy { get; set; }
        public string GirisGelirse { get; set; }
        public string CikisGelirse { get; set; }
        public bool Aktif { get; set; }
    }
}
