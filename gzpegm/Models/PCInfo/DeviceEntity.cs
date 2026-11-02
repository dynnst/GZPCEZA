using System;

namespace gzpegm.Models.PCInfo
{
    public class DeviceEntity
    {
        public int Id { get; set; }
        public string AssetTag { get; set; }
        public int Category { get; set; } = 1; // 1: Desktop, 2: Laptop, 3: Monitor, 4: Camera, 5: OpticalReader, 6: Fingerprint, 7: Printer, 8: UPS, 9: Network, 10: Server, 99: Other
        public string Brand { get; set; } = string.Empty;
        public string Model { get; set; } = string.Empty;
        public string SerialNumber { get; set; } = string.Empty;
        public string Location { get; set; } = string.Empty;
        public string RoomNumber { get; set; }
        public string AssignedPerson { get; set; }
        public DateTime? ProcurementDate { get; set; }
        public DateTime? DeliveryDate { get; set; }
        public DateTime? WarrantyExpiryDate { get; set; }
        public int Status { get; set; } = 1; // 1: Active, 2: InStorage, 3: InRepair, 4: Scrapped
        public string IpAddress { get; set; }
        public string MacAddress { get; set; }
        public string ImagePath { get; set; }
        public string Notes { get; set; }
        public string TechnicalDetailsJson { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime UpdatedAt { get; set; } = DateTime.Now;

        public string GetCategoryName()
        {
            switch (Category)
            {
                case 1: return "Masaüstü Bilgisayar";
                case 2: return "Dizüstü Bilgisayar (Laptop)";
                case 3: return "Monitör";
                case 4: return "IP Kamera (Hikvision vb.)";
                case 5: return "Pasaport / Optik Okuyucu";
                case 6: return "Parmak İzi / Biyometrik";
                case 7: return "Yazıcı / Tarayıcı";
                case 8: return "Kesintisiz Güç Kaynağı (UPS)";
                case 9: return "Switch / Ağ Cihazı";
                case 10: return "Sunucu";
                default: return "Diğer Donanım";
            }
        }

        public string GetCategoryIcon()
        {
            switch (Category)
            {
                case 1: return "fas fa-desktop text-primary";
                case 2: return "fas fa-laptop text-info";
                case 3: return "fas fa-tv text-secondary";
                case 4: return "fas fa-video text-danger";
                case 5: return "fas fa-id-card text-success";
                case 6: return "fas fa-fingerprint text-warning";
                case 7: return "fas fa-print text-dark";
                case 8: return "fas fa-car-battery text-danger";
                case 9: return "fas fa-network-wired text-info";
                case 10: return "fas fa-server text-primary";
                default: return "fas fa-cube text-secondary";
            }
        }

        public string GetStatusName()
        {
            switch (Status)
            {
                case 1: return "Kullanımda / Faal";
                case 2: return "Depoda / Yedek";
                case 3: return "Arızalı / Tamirde";
                case 4: return "Hurda / HEK";
                default: return "Bilinmiyor";
            }
        }

        public string GetStatusBadgeClass()
        {
            switch (Status)
            {
                case 1: return "badge badge-success";
                case 2: return "badge badge-primary";
                case 3: return "badge badge-warning text-dark";
                case 4: return "badge badge-danger";
                default: return "badge badge-secondary";
            }
        }
    }
}
