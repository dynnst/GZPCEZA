using System;
using System.Collections.Generic;

namespace gzpegm.Models.PCInfo
{
    public enum DeviceType
    {
        Unknown = 0,
        WindowsPC = 1,
        HikvisionCamera = 2,
        Printer = 3,
        SwitchRouter = 4
    }

    public class ComputerInfo
    {
        public string Target { get; set; } = string.Empty;
        public bool IsOnline { get; set; }
        public string ErrorMessage { get; set; }
        public DateTime QueryTime { get; set; } = DateTime.Now;

        // System
        public string ComputerName { get; set; } = string.Empty;
        public string Manufacturer { get; set; } = string.Empty;
        public string Model { get; set; } = string.Empty;
        public string SerialNumber { get; set; } = string.Empty;
        public string ProductName { get; set; } = string.Empty;
        public string SystemType { get; set; } = string.Empty;
        public string Domain { get; set; } = string.Empty;
        public string Workgroup { get; set; } = string.Empty;
        public string CurrentUser { get; set; } = string.Empty;
        public string LastUser { get; set; } = string.Empty;

        // Sub-components
        public CpuInfo Cpu { get; set; } = new CpuInfo();
        public MemoryInfo Memory { get; set; } = new MemoryInfo();
        public List<DiskInfo> Disks { get; set; } = new List<DiskInfo>();
        public List<GpuInfo> Gpus { get; set; } = new List<GpuInfo>();
        public MotherboardInfo Motherboard { get; set; } = new MotherboardInfo();
        public BiosInfo Bios { get; set; } = new BiosInfo();
        public WindowsInfo Windows { get; set; } = new WindowsInfo();
        public List<NetworkAdapterInfo> NetworkAdapters { get; set; } = new List<NetworkAdapterInfo>();
        public List<InstalledSoftware> InstalledSoftware { get; set; } = new List<InstalledSoftware>();

        // Bağlı Donanımlar / Çevre Birimleri (Peripherals)
        public List<MonitorInfo> Monitors { get; set; } = new List<MonitorInfo>();
        public List<UsbDeviceInfo> UsbDevices { get; set; } = new List<UsbDeviceInfo>();
        public List<PrinterInfo> Printers { get; set; } = new List<PrinterInfo>();
    }

    public class CpuInfo
    {
        public string Name { get; set; } = string.Empty;
        public string Manufacturer { get; set; } = string.Empty;
        public int Cores { get; set; }
        public int Threads { get; set; }
        public string MaxSpeedGhz { get; set; } = string.Empty;
        public string CurrentSpeedGhz { get; set; } = string.Empty;
        public string Architecture { get; set; } = string.Empty;
    }

    public class MemoryInfo
    {
        public double TotalGb { get; set; }
        public List<MemorySlot> Slots { get; set; } = new List<MemorySlot>();
    }

    public class MemorySlot
    {
        public string Tag { get; set; } = string.Empty;
        public string Manufacturer { get; set; } = string.Empty;
        public double CapacityGb { get; set; }
        public uint SpeedMhz { get; set; }
        public string PartNumber { get; set; } = string.Empty;
    }

    public class DiskInfo
    {
        public string Model { get; set; } = string.Empty;
        public string SerialNumber { get; set; } = string.Empty;
        public string MediaType { get; set; } = string.Empty;
        public double TotalSizeGb { get; set; }
        public string InterfaceType { get; set; } = string.Empty;
        public List<LogicalDiskInfo> LogicalDisks { get; set; } = new List<LogicalDiskInfo>();
    }

    public class LogicalDiskInfo
    {
        public string DriveLetter { get; set; } = string.Empty;
        public string Label { get; set; } = string.Empty;
        public string FileSystem { get; set; } = string.Empty;
        public double TotalSizeGb { get; set; }
        public double FreeSpaceGb { get; set; }
        public double UsedSpaceGb => TotalSizeGb - FreeSpaceGb;
        public double UsedPercent => TotalSizeGb > 0 ? Math.Round((UsedSpaceGb / TotalSizeGb) * 100.0, 1) : 0;
    }

    public class GpuInfo
    {
        public string Name { get; set; } = string.Empty;
        public string AdapterType { get; set; } = string.Empty;
        public string VramText { get; set; } = string.Empty;
        public string DriverVersion { get; set; } = string.Empty;
        public string DriverDate { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
    }

    public class MotherboardInfo
    {
        public string Manufacturer { get; set; } = string.Empty;
        public string Product { get; set; } = string.Empty;
        public string SerialNumber { get; set; } = string.Empty;
        public string Version { get; set; } = string.Empty;
    }

    public class BiosInfo
    {
        public string Manufacturer { get; set; } = string.Empty;
        public string Version { get; set; } = string.Empty;
        public string ReleaseDate { get; set; } = string.Empty;
        public string SMBIOSVersion { get; set; } = string.Empty;
    }

    public class WindowsInfo
    {
        public string Caption { get; set; } = string.Empty;
        public string Version { get; set; } = string.Empty;
        public string BuildNumber { get; set; } = string.Empty;
        public string Architecture { get; set; } = string.Empty;
        public string InstallDate { get; set; } = string.Empty;
        public string LastBootTime { get; set; } = string.Empty;
        public string Edition { get; set; } = string.Empty;
        public string DisplayVersion { get; set; } = string.Empty;
    }

    public class NetworkAdapterInfo
    {
        public string Name { get; set; } = string.Empty;
        public string MacAddress { get; set; } = string.Empty;
        public List<string> IpAddresses { get; set; } = new List<string>();
        public List<string> IPv6Addresses { get; set; } = new List<string>();
        public string DefaultGateway { get; set; } = string.Empty;
        public string DhcpServer { get; set; } = string.Empty;
        public List<string> DnsServers { get; set; } = new List<string>();
        public bool DhcpEnabled { get; set; }
        public string AdapterType { get; set; } = string.Empty;
        public string Speed { get; set; } = string.Empty;
    }

    public class InstalledSoftware
    {
        public string Name { get; set; } = string.Empty;
        public string Version { get; set; } = string.Empty;
        public string Publisher { get; set; } = string.Empty;
        public string InstallDate { get; set; } = string.Empty;
        public string Architecture { get; set; } = string.Empty;
    }

    // Çevre Birimleri (Peripherals)
    public class MonitorInfo
    {
        public string Manufacturer { get; set; } = string.Empty;
        public string Model { get; set; } = string.Empty;
        public string SerialNumber { get; set; } = string.Empty;
        public int YearOfManufacture { get; set; }
        public int WeekOfManufacture { get; set; }
        public bool IsActive { get; set; } = true;
    }

    public class UsbDeviceInfo
    {
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string DeviceId { get; set; } = string.Empty;
        public string Manufacturer { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
    }

    public class PrinterInfo
    {
        public string Name { get; set; } = string.Empty;
        public string DriverName { get; set; } = string.Empty;
        public string PortName { get; set; } = string.Empty;
        public bool IsDefault { get; set; }
        public bool IsNetwork { get; set; }
        public string Status { get; set; } = string.Empty;
    }

    // Akıllı Ağ Tarayıcısı (Smart Scanner)
    public class ScanItemResult
    {
        public string IpAddress { get; set; } = string.Empty;
        public string HostName { get; set; } = string.Empty;
        public DeviceType DeviceType { get; set; } = DeviceType.Unknown;
        public string DeviceTypeDisplay
        {
            get
            {
                switch (DeviceType)
                {
                    case DeviceType.WindowsPC: return "Windows PC";
                    case DeviceType.HikvisionCamera: return "Hikvision Kamera";
                    case DeviceType.Printer: return "Ağ Yazıcısı";
                    case DeviceType.SwitchRouter: return "Switch / Ağ Cihazı";
                    default: return "Bilinmeyen Cihaz";
                }
            }
        }
        public string DeviceIcon
        {
            get
            {
                switch (DeviceType)
                {
                    case DeviceType.WindowsPC: return "fas fa-desktop text-primary";
                    case DeviceType.HikvisionCamera: return "fas fa-video text-danger";
                    case DeviceType.Printer: return "fas fa-print text-warning";
                    case DeviceType.SwitchRouter: return "fas fa-network-wired text-info";
                    default: return "fas fa-question-circle text-secondary";
                }
            }
        }
        public bool IsOnline { get; set; }
        public List<int> OpenPorts { get; set; } = new List<int>();
        public string Details { get; set; } = string.Empty;
        public long ResponseTimeMs { get; set; }
    }

    // Hikvision IP Kamera
    public class CameraDeviceInfo
    {
        public string IpAddress { get; set; } = string.Empty;
        public string DeviceName { get; set; } = string.Empty;
        public string Model { get; set; } = string.Empty;
        public string SerialNumber { get; set; } = string.Empty;
        public string MacAddress { get; set; } = string.Empty;
        public string FirmwareVersion { get; set; } = string.Empty;
        public int HttpPort { get; set; } = 80;
        public int RtspPort { get; set; } = 554;
        public string SnapshotUrl { get; set; } = string.Empty;
        public string RtspUrl { get; set; } = string.Empty;
        public bool IsOnline { get; set; }
        public string ErrorMessage { get; set; }
        public DateTime QueryTime { get; set; } = DateTime.Now;
    }

    public class ConnectionCredentials
    {
        public string Username { get; set; }
        public string Password { get; set; }
    }
}
