namespace gzpegm.Models
{
    public class TahditSozlukItem
    {
        public string Kod { get; set; }
        public string Baslik { get; set; }
        public string Kategori { get; set; }
        public string Sure { get; set; }
        public string Aciklama { get; set; }
        public string GirisIslem { get; set; }
        public string CikisIslem { get; set; }
        public string OnemDerecesi { get; set; } // 'Kritik', 'Yuksek', 'Standart', 'Bilgi'
        public string BadgeClass
        {
            get
            {
                if (string.IsNullOrWhiteSpace(Kod)) return "badge-secondary";
                var k = Kod.ToUpperInvariant();
                if (k.StartsWith("G-") || k == "K" || k.StartsWith("O-")) return "badge-danger";
                if (k.StartsWith("Ç-") || k.StartsWith("C-")) return "badge-warning";
                if (k.StartsWith("V-")) return "badge-primary";
                if (k.StartsWith("N-")) return "badge-info";
                return "badge-dark";
            }
        }
    }
}
