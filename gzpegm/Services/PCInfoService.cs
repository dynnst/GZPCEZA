using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Management;
using System.Net;
using System.Net.NetworkInformation;
using System.Net.Sockets;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;
using ClosedXML.Excel;
using gzpegm.Models.PCInfo;
using Microsoft.Win32;

namespace gzpegm.Services
{
    public class PCInfoService
    {
        public bool IsLocalhost(string target)
        {
            if (string.IsNullOrWhiteSpace(target)) return true;
            target = target.Trim();
            return string.Equals(target, "localhost", StringComparison.OrdinalIgnoreCase)
                || string.Equals(target, "127.0.0.1", StringComparison.OrdinalIgnoreCase)
                || string.Equals(target, ".", StringComparison.OrdinalIgnoreCase)
                || string.Equals(target, "Yerel Sunucu", StringComparison.OrdinalIgnoreCase)
                || string.Equals(target, Environment.MachineName, StringComparison.OrdinalIgnoreCase);
        }

        #region 1. DONANIM DENETİMİ (INSPECTOR)

        public ComputerInfo GetComputerInfo(string target, string username = null, string password = null)
        {
            var cleanTarget = string.IsNullOrWhiteSpace(target) ? "localhost" : target.Trim();
            bool isLocal = IsLocalhost(cleanTarget);

            var info = new ComputerInfo
            {
                Target = isLocal ? "Yerel Sunucu (" + Environment.MachineName + ")" : cleanTarget,
                QueryTime = DateTime.Now
            };

            // 1. Ağ Erişilebilirlik Kontrolü (Ping)
            if (!isLocal)
            {
                try
                {
                    using (var ping = new Ping())
                    {
                        var reply = ping.Send(cleanTarget, 2500);
                        if (reply == null || reply.Status != IPStatus.Success)
                        {
                            info.IsOnline = false;
                            info.ErrorMessage = $"Hedef bilgisayara ({cleanTarget}) ağ üzerinden ulaşılamıyor (Ping yanıt vermedi). Cihaz kapalı veya ağ erişimi kısıtlı olabilir.";
                            return info;
                        }
                    }
                }
                catch (Exception pex)
                {
                    info.IsOnline = false;
                    info.ErrorMessage = $"Ağ bağlantı hatası: {pex.Message}";
                    return info;
                }
            }

            // 2. WMI Kapsamı (root\cimv2)
            ManagementScope scope;
            ConnectionOptions options = null;
            try
            {
                if (isLocal)
                {
                    scope = new ManagementScope(@"\\.\root\cimv2");
                    scope.Connect();
                }
                else
                {
                    options = new ConnectionOptions
                    {
                        Impersonation = ImpersonationLevel.Impersonate,
                        Authentication = AuthenticationLevel.PacketPrivacy,
                        Timeout = TimeSpan.FromSeconds(8)
                    };

                    if (!string.IsNullOrWhiteSpace(username))
                    {
                        options.Username = username.Trim();
                        options.Password = password ?? string.Empty;
                    }

                    scope = new ManagementScope($@"\\{cleanTarget}\root\cimv2", options);
                    scope.Connect();
                }
            }
            catch (UnauthorizedAccessException uex)
            {
                info.IsOnline = false;
                info.ErrorMessage = $"WMI Erişim Reddedildi (Yetkilendirme Hatası): {uex.Message}. Uzak bilgisayarda Yönetici (Administrator) yetkisine sahip bir kullanıcı adı ve şifre girmeniz gerekebilir.";
                return info;
            }
            catch (Exception ex)
            {
                info.IsOnline = false;
                info.ErrorMessage = $"WMI Bağlantı Kurulamadı: {ex.Message}. Hedef makinede 'Windows Management Instrumentation' ve RPC servislerinin çalıştığından ve güvenlik duvarının WMI'a izin verdiğinden emin olun.";
                return info;
            }

            info.IsOnline = true;

            // 3. Sistem & Bilgisayar Bilgileri (Win32_ComputerSystem)
            try
            {
                using (var searcher = new ManagementObjectSearcher(scope, new ObjectQuery("SELECT * FROM Win32_ComputerSystem")))
                using (var collection = searcher.Get())
                {
                    foreach (ManagementObject mo in collection)
                    {
                        info.ComputerName = mo["Name"]?.ToString() ?? string.Empty;
                        info.Manufacturer = mo["Manufacturer"]?.ToString()?.Trim() ?? string.Empty;
                        info.Model = mo["Model"]?.ToString()?.Trim() ?? string.Empty;
                        info.SystemType = mo["SystemType"]?.ToString() ?? string.Empty;
                        info.Domain = mo["Domain"]?.ToString() ?? string.Empty;
                        info.Workgroup = mo["Workgroup"]?.ToString() ?? string.Empty;
                        info.CurrentUser = mo["UserName"]?.ToString() ?? string.Empty;

                        if (mo["TotalPhysicalMemory"] != null && ulong.TryParse(mo["TotalPhysicalMemory"].ToString(), out ulong totalBytes))
                        {
                            info.Memory.TotalGb = Math.Round(totalBytes / (1024.0 * 1024 * 1024), 2);
                        }
                        break;
                    }
                }
            }
            catch { }

            // 4. Seri Numarası & Ürün Adı (Win32_ComputerSystemProduct)
            try
            {
                using (var searcher = new ManagementObjectSearcher(scope, new ObjectQuery("SELECT * FROM Win32_ComputerSystemProduct")))
                using (var collection = searcher.Get())
                {
                    foreach (ManagementObject mo in collection)
                    {
                        info.SerialNumber = mo["IdentifyingNumber"]?.ToString()?.Trim() ?? string.Empty;
                        info.ProductName = mo["Name"]?.ToString()?.Trim() ?? string.Empty;
                        break;
                    }
                }
            }
            catch { }

            // 5. İşletim Sistemi (Win32_OperatingSystem)
            try
            {
                using (var searcher = new ManagementObjectSearcher(scope, new ObjectQuery("SELECT * FROM Win32_OperatingSystem")))
                using (var collection = searcher.Get())
                {
                    foreach (ManagementObject mo in collection)
                    {
                        info.Windows.Caption = mo["Caption"]?.ToString()?.Trim() ?? string.Empty;
                        info.Windows.Version = mo["Version"]?.ToString() ?? string.Empty;
                        info.Windows.BuildNumber = mo["BuildNumber"]?.ToString() ?? string.Empty;
                        info.Windows.Architecture = mo["OSArchitecture"]?.ToString() ?? string.Empty;

                        if (mo["InstallDate"] != null)
                        {
                            try { info.Windows.InstallDate = ManagementDateTimeConverter.ToDateTime(mo["InstallDate"].ToString()).ToString("dd.MM.yyyy HH:mm"); }
                            catch { info.Windows.InstallDate = mo["InstallDate"].ToString(); }
                        }

                        if (mo["LastBootUpTime"] != null)
                        {
                            try { info.Windows.LastBootTime = ManagementDateTimeConverter.ToDateTime(mo["LastBootUpTime"].ToString()).ToString("dd.MM.yyyy HH:mm"); }
                            catch { info.Windows.LastBootTime = mo["LastBootUpTime"].ToString(); }
                        }
                        break;
                    }
                }
            }
            catch { }

            // 6. İşlemci (Win32_Processor)
            try
            {
                using (var searcher = new ManagementObjectSearcher(scope, new ObjectQuery("SELECT * FROM Win32_Processor")))
                using (var collection = searcher.Get())
                {
                    foreach (ManagementObject mo in collection)
                    {
                        info.Cpu.Name = mo["Name"]?.ToString()?.Trim() ?? string.Empty;
                        info.Cpu.Manufacturer = mo["Manufacturer"]?.ToString()?.Trim() ?? string.Empty;

                        if (mo["NumberOfCores"] != null && int.TryParse(mo["NumberOfCores"].ToString(), out int cores))
                            info.Cpu.Cores = cores;
                        if (mo["NumberOfLogicalProcessors"] != null && int.TryParse(mo["NumberOfLogicalProcessors"].ToString(), out int threads))
                            info.Cpu.Threads = threads;

                        if (mo["MaxClockSpeed"] != null && double.TryParse(mo["MaxClockSpeed"].ToString(), out double maxSpeed))
                            info.Cpu.MaxSpeedGhz = $"{maxSpeed / 1000.0:F2} GHz";
                        if (mo["CurrentClockSpeed"] != null && double.TryParse(mo["CurrentClockSpeed"].ToString(), out double curSpeed))
                            info.Cpu.CurrentSpeedGhz = $"{curSpeed / 1000.0:F2} GHz";

                        var arch = mo["Architecture"]?.ToString();
                        info.Cpu.Architecture = arch == "9" ? "x64" : arch == "5" ? "ARM" : arch == "0" ? "x86" : arch ?? string.Empty;
                        break;
                    }
                }
            }
            catch { }

            // 7. Bellek Yuvaları (Win32_PhysicalMemory)
            try
            {
                using (var searcher = new ManagementObjectSearcher(scope, new ObjectQuery("SELECT * FROM Win32_PhysicalMemory")))
                using (var collection = searcher.Get())
                {
                    foreach (ManagementObject mo in collection)
                    {
                        ulong cap = 0;
                        uint spd = 0;
                        if (mo["Capacity"] != null) ulong.TryParse(mo["Capacity"].ToString(), out cap);
                        if (mo["Speed"] != null) uint.TryParse(mo["Speed"].ToString(), out spd);

                        info.Memory.Slots.Add(new MemorySlot
                        {
                            Tag = mo["DeviceLocator"]?.ToString() ?? mo["Tag"]?.ToString() ?? "Slot",
                            Manufacturer = mo["Manufacturer"]?.ToString()?.Trim() ?? "Bilinmiyor",
                            CapacityGb = Math.Round(cap / (1024.0 * 1024 * 1024), 1),
                            SpeedMhz = spd,
                            PartNumber = mo["PartNumber"]?.ToString()?.Trim() ?? string.Empty
                        });
                    }
                }
            }
            catch { }

            // 8. Mantıksal Diskler (Win32_LogicalDisk)
            var logicalDisks = new List<LogicalDiskInfo>();
            try
            {
                using (var searcher = new ManagementObjectSearcher(scope, new ObjectQuery("SELECT * FROM Win32_LogicalDisk WHERE DriveType = 3")))
                using (var collection = searcher.Get())
                {
                    foreach (ManagementObject mo in collection)
                    {
                        ulong size = 0;
                        ulong free = 0;
                        if (mo["Size"] != null) ulong.TryParse(mo["Size"].ToString(), out size);
                        if (mo["FreeSpace"] != null) ulong.TryParse(mo["FreeSpace"].ToString(), out free);

                        logicalDisks.Add(new LogicalDiskInfo
                        {
                            DriveLetter = mo["DeviceID"]?.ToString() ?? string.Empty,
                            Label = mo["VolumeName"]?.ToString() ?? string.Empty,
                            FileSystem = mo["FileSystem"]?.ToString() ?? string.Empty,
                            TotalSizeGb = Math.Round(size / (1024.0 * 1024 * 1024), 1),
                            FreeSpaceGb = Math.Round(free / (1024.0 * 1024 * 1024), 1)
                        });
                    }
                }
            }
            catch { }

            // 9. Fiziksel Diskler (Win32_DiskDrive)
            try
            {
                using (var searcher = new ManagementObjectSearcher(scope, new ObjectQuery("SELECT * FROM Win32_DiskDrive")))
                using (var collection = searcher.Get())
                {
                    foreach (ManagementObject mo in collection)
                    {
                        ulong size = 0;
                        if (mo["Size"] != null) ulong.TryParse(mo["Size"].ToString(), out size);

                        string model = mo["Model"]?.ToString()?.Trim() ?? "Bilinmiyor";
                        string mediaType = mo["MediaType"]?.ToString() ?? string.Empty;
                        if (model.IndexOf("SSD", StringComparison.OrdinalIgnoreCase) >= 0 ||
                            model.IndexOf("NVMe", StringComparison.OrdinalIgnoreCase) >= 0)
                        {
                            mediaType = model.IndexOf("NVMe", StringComparison.OrdinalIgnoreCase) >= 0 ? "NVMe SSD" : "SSD";
                        }
                        else if (string.IsNullOrWhiteSpace(mediaType))
                        {
                            mediaType = "Sabit Disk";
                        }

                        var disk = new DiskInfo
                        {
                            Model = model,
                            SerialNumber = mo["SerialNumber"]?.ToString()?.Trim() ?? string.Empty,
                            MediaType = mediaType,
                            TotalSizeGb = Math.Round(size / (1024.0 * 1024 * 1024), 1),
                            InterfaceType = mo["InterfaceType"]?.ToString() ?? string.Empty
                        };

                        info.Disks.Add(disk);
                    }
                }
            }
            catch { }

            if (info.Disks.Count > 0)
            {
                info.Disks[0].LogicalDisks.AddRange(logicalDisks);
            }
            else if (logicalDisks.Count > 0)
            {
                info.Disks.Add(new DiskInfo
                {
                    Model = "Sistem Mantıksal Sürücüleri",
                    MediaType = "Depolama",
                    TotalSizeGb = logicalDisks.Sum(x => x.TotalSizeGb),
                    LogicalDisks = logicalDisks
                });
            }

            // 10. Ekran Kartı (Win32_VideoController)
            try
            {
                using (var searcher = new ManagementObjectSearcher(scope, new ObjectQuery("SELECT * FROM Win32_VideoController")))
                using (var collection = searcher.Get())
                {
                    foreach (ManagementObject mo in collection)
                    {
                        string name = mo["Name"]?.ToString()?.Trim() ?? string.Empty;
                        if (string.IsNullOrWhiteSpace(name)) continue;

                        string vramStr = "Bilinmiyor";
                        if (mo["AdapterRAM"] != null && ulong.TryParse(mo["AdapterRAM"].ToString(), out ulong ram))
                        {
                            vramStr = $"{Math.Round(ram / (1024.0 * 1024 * 1024), 1)} GB";
                        }

                        string driverDate = string.Empty;
                        if (mo["DriverDate"] != null)
                        {
                            try { driverDate = ManagementDateTimeConverter.ToDateTime(mo["DriverDate"].ToString()).ToString("dd.MM.yyyy"); }
                            catch { driverDate = mo["DriverDate"].ToString(); }
                        }

                        info.Gpus.Add(new GpuInfo
                        {
                            Name = name,
                            AdapterType = mo["AdapterCompatibility"]?.ToString() ?? string.Empty,
                            VramText = vramStr,
                            DriverVersion = mo["DriverVersion"]?.ToString() ?? string.Empty,
                            DriverDate = driverDate,
                            Status = mo["Status"]?.ToString() ?? "OK"
                        });
                    }
                }
            }
            catch { }

            // 11. Anakart & BIOS
            try
            {
                using (var searcher = new ManagementObjectSearcher(scope, new ObjectQuery("SELECT * FROM Win32_BaseBoard")))
                using (var collection = searcher.Get())
                {
                    foreach (ManagementObject mo in collection)
                    {
                        info.Motherboard.Manufacturer = mo["Manufacturer"]?.ToString()?.Trim() ?? string.Empty;
                        info.Motherboard.Product = mo["Product"]?.ToString()?.Trim() ?? string.Empty;
                        info.Motherboard.SerialNumber = mo["SerialNumber"]?.ToString()?.Trim() ?? string.Empty;
                        info.Motherboard.Version = mo["Version"]?.ToString()?.Trim() ?? string.Empty;
                        break;
                    }
                }
            }
            catch { }

            try
            {
                using (var searcher = new ManagementObjectSearcher(scope, new ObjectQuery("SELECT * FROM Win32_BIOS")))
                using (var collection = searcher.Get())
                {
                    foreach (ManagementObject mo in collection)
                    {
                        info.Bios.Manufacturer = mo["Manufacturer"]?.ToString()?.Trim() ?? string.Empty;
                        info.Bios.Version = mo["Version"]?.ToString()?.Trim() ?? string.Empty;
                        info.Bios.SMBIOSVersion = mo["SMBIOSBIOSVersion"]?.ToString()?.Trim() ?? string.Empty;

                        if (mo["ReleaseDate"] != null)
                        {
                            try { info.Bios.ReleaseDate = ManagementDateTimeConverter.ToDateTime(mo["ReleaseDate"].ToString()).ToString("dd.MM.yyyy"); }
                            catch { info.Bios.ReleaseDate = mo["ReleaseDate"].ToString(); }
                        }
                        break;
                    }
                }
            }
            catch { }

            // 12. Ağ Bağdaştırıcıları (Win32_NetworkAdapterConfiguration)
            try
            {
                using (var searcher = new ManagementObjectSearcher(scope, new ObjectQuery("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")))
                using (var collection = searcher.Get())
                {
                    foreach (ManagementObject mo in collection)
                    {
                        var adapter = new NetworkAdapterInfo
                        {
                            Name = mo["Description"]?.ToString() ?? "Ağ Kartı",
                            MacAddress = mo["MACAddress"]?.ToString() ?? string.Empty,
                            DefaultGateway = mo["DefaultIPGateway"] is string[] gw && gw.Length > 0 ? gw[0] : string.Empty,
                            DhcpServer = mo["DHCPServer"]?.ToString() ?? string.Empty,
                            DhcpEnabled = mo["DHCPEnabled"] != null && Convert.ToBoolean(mo["DHCPEnabled"])
                        };

                        if (mo["IPAddress"] is string[] ips)
                        {
                            foreach (var ip in ips)
                            {
                                if (ip.Contains(":")) adapter.IPv6Addresses.Add(ip);
                                else adapter.IpAddresses.Add(ip);
                            }
                        }

                        if (mo["DNSServerSearchOrder"] is string[] dns)
                        {
                            adapter.DnsServers.AddRange(dns);
                        }

                        info.NetworkAdapters.Add(adapter);
                    }
                }
            }
            catch { }

            // 13. BAĞLI MONİTÖRLER (WmiMonitorID / Win32_DesktopMonitor)
            GetMonitors(info, cleanTarget, isLocal, options);

            // 14. BAĞLI USB AYGITLARI (Pasaport/Kimlik okuyucu, Optik Okuyucu, Klavye, Fare)
            GetUsbDevices(info, scope);

            // 15. YAZICILAR (Win32_Printer)
            GetPrinters(info, scope);

            // 16. YÜKLÜ YAZILIMLAR
            if (isLocal)
            {
                GetInstalledSoftwareFromRegistry(info.InstalledSoftware);
            }

            return info;
        }

        private void GetMonitors(ComputerInfo info, string target, bool isLocal, ConnectionOptions options)
        {
            // Metot 1: root\wmi -> WmiMonitorID (Gerçek Üretici, Model ve Seri Numarası barındırır)
            try
            {
                ManagementScope wmiScope = isLocal ? new ManagementScope(@"\\.\root\wmi") : new ManagementScope($@"\\{target}\root\wmi", options);
                wmiScope.Connect();

                using (var searcher = new ManagementObjectSearcher(wmiScope, new ObjectQuery("SELECT * FROM WmiMonitorID")))
                using (var collection = searcher.Get())
                {
                    foreach (ManagementObject mo in collection)
                    {
                        string mfg = DecodeUshortArray(mo["ManufacturerName"] as ushort[]);
                        string model = DecodeUshortArray(mo["UserFriendlyName"] as ushort[]);
                        string serial = DecodeUshortArray(mo["SerialNumberID"] as ushort[]);

                        int year = 0;
                        if (mo["YearOfManufacture"] != null) int.TryParse(mo["YearOfManufacture"].ToString(), out year);

                        int week = 0;
                        if (mo["WeekOfManufacture"] != null) int.TryParse(mo["WeekOfManufacture"].ToString(), out week);

                        if (!string.IsNullOrWhiteSpace(model) || !string.IsNullOrWhiteSpace(mfg) || !string.IsNullOrWhiteSpace(serial))
                        {
                            info.Monitors.Add(new MonitorInfo
                            {
                                Manufacturer = string.IsNullOrWhiteSpace(mfg) ? "Bilinmiyor" : mfg,
                                Model = string.IsNullOrWhiteSpace(model) ? (string.IsNullOrWhiteSpace(mfg) ? "Monitör" : $"{mfg} Monitör") : model,
                                SerialNumber = string.IsNullOrWhiteSpace(serial) ? "Mevcut Değil" : serial,
                                YearOfManufacture = year,
                                WeekOfManufacture = week,
                                IsActive = true
                            });
                        }
                    }
                }
            }
            catch { }

            // Fallback: root\cimv2 -> Win32_DesktopMonitor
            if (info.Monitors.Count == 0)
            {
                try
                {
                    ManagementScope cimScope = isLocal ? new ManagementScope(@"\\.\root\cimv2") : new ManagementScope($@"\\{target}\root\cimv2", options);
                    if (!cimScope.IsConnected) cimScope.Connect();

                    using (var searcher = new ManagementObjectSearcher(cimScope, new ObjectQuery("SELECT * FROM Win32_DesktopMonitor")))
                    using (var collection = searcher.Get())
                    {
                        foreach (ManagementObject mo in collection)
                        {
                            string name = mo["Name"]?.ToString() ?? string.Empty;
                            string mfg = mo["MonitorManufacturer"]?.ToString() ?? string.Empty;
                            string type = mo["MonitorType"]?.ToString() ?? string.Empty;

                            if (!string.IsNullOrWhiteSpace(name) || !string.IsNullOrWhiteSpace(type))
                            {
                                info.Monitors.Add(new MonitorInfo
                                {
                                    Manufacturer = string.IsNullOrWhiteSpace(mfg) ? "Standart" : mfg,
                                    Model = string.IsNullOrWhiteSpace(type) ? name : type,
                                    SerialNumber = "—",
                                    IsActive = true
                                });
                            }
                        }
                    }
                }
                catch { }
            }
        }

        private void GetUsbDevices(ComputerInfo info, ManagementScope scope)
        {
            try
            {
                using (var searcher = new ManagementObjectSearcher(scope, new ObjectQuery("SELECT * FROM Win32_PnPEntity WHERE PNPClass = 'USB' OR Service = 'USBSTOR'")))
                using (var collection = searcher.Get())
                {
                    foreach (ManagementObject mo in collection)
                    {
                        string name = mo["Name"]?.ToString()?.Trim() ?? string.Empty;
                        string desc = mo["Description"]?.ToString()?.Trim() ?? string.Empty;
                        string devId = mo["DeviceID"]?.ToString()?.Trim() ?? string.Empty;
                        string mfg = mo["Manufacturer"]?.ToString()?.Trim() ?? string.Empty;
                        string status = mo["Status"]?.ToString()?.Trim() ?? "OK";

                        if (!string.IsNullOrWhiteSpace(name))
                        {
                            info.UsbDevices.Add(new UsbDeviceInfo
                            {
                                Name = name,
                                Description = desc,
                                DeviceId = devId,
                                Manufacturer = mfg,
                                Status = status
                            });
                        }
                    }
                }
            }
            catch { }
        }

        private void GetPrinters(ComputerInfo info, ManagementScope scope)
        {
            try
            {
                using (var searcher = new ManagementObjectSearcher(scope, new ObjectQuery("SELECT * FROM Win32_Printer")))
                using (var collection = searcher.Get())
                {
                    foreach (ManagementObject mo in collection)
                    {
                        string name = mo["Name"]?.ToString()?.Trim() ?? string.Empty;
                        string driver = mo["DriverName"]?.ToString()?.Trim() ?? string.Empty;
                        string port = mo["PortName"]?.ToString()?.Trim() ?? string.Empty;
                        bool isDef = mo["Default"] != null && Convert.ToBoolean(mo["Default"]);
                        bool isNet = mo["Network"] != null && Convert.ToBoolean(mo["Network"]);
                        string status = mo["Status"]?.ToString()?.Trim() ?? "OK";

                        if (!string.IsNullOrWhiteSpace(name))
                        {
                            info.Printers.Add(new PrinterInfo
                            {
                                Name = name,
                                DriverName = driver,
                                PortName = port,
                                IsDefault = isDef,
                                IsNetwork = isNet,
                                Status = status
                            });
                        }
                    }
                }
            }
            catch { }
        }

        private void GetInstalledSoftwareFromRegistry(List<InstalledSoftware> softwareList)
        {
            var registryPaths = new[]
            {
                @"SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
                @"SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
            };

            var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

            foreach (var path in registryPaths)
            {
                try
                {
                    using (var key = Registry.LocalMachine.OpenSubKey(path))
                    {
                        if (key == null) continue;

                        foreach (var subKeyName in key.GetSubKeyNames())
                        {
                            try
                            {
                                using (var subKey = key.OpenSubKey(subKeyName))
                                {
                                    if (subKey == null) continue;

                                    var name = subKey.GetValue("DisplayName")?.ToString()?.Trim();
                                    if (string.IsNullOrWhiteSpace(name)) continue;

                                    var isSys = subKey.GetValue("SystemComponent");
                                    if (isSys != null && (isSys.ToString() == "1" || isSys.ToString() == "True")) continue;

                                    var parentKey = subKey.GetValue("ParentKeyName")?.ToString();
                                    if (!string.IsNullOrWhiteSpace(parentKey)) continue;

                                    if (seen.Contains(name)) continue;
                                    seen.Add(name);

                                    var version = subKey.GetValue("DisplayVersion")?.ToString()?.Trim() ?? string.Empty;
                                    var publisher = subKey.GetValue("Publisher")?.ToString()?.Trim() ?? string.Empty;
                                    var installDate = subKey.GetValue("InstallDate")?.ToString()?.Trim() ?? string.Empty;

                                    if (installDate.Length == 8 && int.TryParse(installDate, out _))
                                    {
                                        installDate = $"{installDate.Substring(6, 2)}.{installDate.Substring(4, 2)}.{installDate.Substring(0, 4)}";
                                    }

                                    softwareList.Add(new InstalledSoftware
                                    {
                                        Name = name,
                                        Version = version,
                                        Publisher = publisher,
                                        InstallDate = installDate,
                                        Architecture = path.Contains("WOW6432Node") ? "32-bit" : "64-bit"
                                    });
                                }
                            }
                            catch { }
                        }
                    }
                }
                catch { }
            }

            softwareList.Sort((a, b) => string.Compare(a.Name, b.Name, StringComparison.OrdinalIgnoreCase));
        }

        private static string DecodeUshortArray(ushort[] array)
        {
            if (array == null || array.Length == 0) return string.Empty;
            return new string(array.Select(c => (char)c).Where(c => c != 0 && c != '\r' && c != '\n').ToArray()).Trim();
        }

        #endregion

        #region 2. AKILLI AĞ TARAYICISI (SMART NETWORK SCANNER)

        private static readonly int[] ProbePorts = { 135, 445, 80, 554, 8000, 9100, 3389, 22 };

        public List<ScanItemResult> ScanNetworkRange(string rangeInput, int timeoutMs = 1200, int maxConcurrency = 30)
        {
            var ipList = GenerateIpRange(rangeInput);
            var results = new ConcurrentBag<ScanItemResult>();

            var parallelOptions = new ParallelOptions
            {
                MaxDegreeOfParallelism = Math.Max(5, Math.Min(50, maxConcurrency))
            };

            Parallel.ForEach(ipList, parallelOptions, ip =>
            {
                var item = ScanSingleIp(ip, timeoutMs);
                if (item.IsOnline)
                {
                    results.Add(item);
                }
            });

            return results.OrderBy(x => IpToUint(x.IpAddress)).ToList();
        }

        private ScanItemResult ScanSingleIp(string ip, int timeoutMs)
        {
            var item = new ScanItemResult
            {
                IpAddress = ip,
                IsOnline = false
            };

            var sw = System.Diagnostics.Stopwatch.StartNew();

            // 1. Hızlı Ping Testi
            bool pingOk = false;
            try
            {
                using (var ping = new Ping())
                {
                    var reply = ping.Send(ip, timeoutMs);
                    if (reply != null && reply.Status == IPStatus.Success)
                    {
                        pingOk = true;
                        item.ResponseTimeMs = reply.RoundtripTime;
                    }
                }
            }
            catch { }

            // 2. Port Taraması (Ping kapalı olan ama açık portu bulunan cihazları da yakalamak için)
            var openPorts = new List<int>();
            foreach (var port in ProbePorts)
            {
                if (IsPortOpen(ip, port, Math.Min(timeoutMs, 400)))
                {
                    openPorts.Add(port);
                }
            }

            sw.Stop();
            if (item.ResponseTimeMs == 0) item.ResponseTimeMs = sw.ElapsedMilliseconds;

            item.IsOnline = pingOk || openPorts.Count > 0;
            item.OpenPorts = openPorts;

            if (item.IsOnline)
            {
                // DNS Hostname Çözümleme
                try
                {
                    var hostEntry = Dns.GetHostEntry(ip);
                    item.HostName = hostEntry.HostName ?? string.Empty;
                }
                catch
                {
                    item.HostName = string.Empty;
                }

                // Cihaz Türü Tespiti
                item.DeviceType = ClassifyDevice(openPorts, item.HostName);

                var sbDetails = new StringBuilder();
                if (openPorts.Count > 0)
                {
                    sbDetails.Append("Açık Portlar: ").Append(string.Join(", ", openPorts));
                }
                item.Details = sbDetails.ToString();
            }

            return item;
        }

        private static bool IsPortOpen(string host, int port, int timeoutMs)
        {
            try
            {
                using (var client = new TcpClient())
                {
                    var result = client.BeginConnect(host, port, null, null);
                    var success = result.AsyncWaitHandle.WaitOne(timeoutMs);
                    if (!success) return false;
                    client.EndConnect(result);
                    return true;
                }
            }
            catch
            {
                return false;
            }
        }

        private static DeviceType ClassifyDevice(List<int> openPorts, string hostName)
        {
            var hn = (hostName ?? "").ToLowerInvariant();

            // Hikvision Kamera Belirteçleri
            if (openPorts.Contains(554) || openPorts.Contains(8000) || hn.Contains("hik") || hn.Contains("cam") || hn.Contains("kamera"))
                return DeviceType.HikvisionCamera;

            // Windows PC Belirteçleri (WMI 135, SMB 445, RDP 3389)
            if (openPorts.Contains(135) || openPorts.Contains(445) || openPorts.Contains(3389) || hn.Contains("pc") || hn.Contains("gise") || hn.Contains("des"))
                return DeviceType.WindowsPC;

            // Ağ Yazıcısı (Port 9100 veya 515 LPD veya 631 IPP)
            if (openPorts.Contains(9100) || hn.Contains("print") || hn.Contains("hp") || hn.Contains("canon"))
                return DeviceType.Printer;

            // Switch / Router / Ağ Cihazı
            if (openPorts.Contains(22) || openPorts.Contains(80) || openPorts.Contains(443))
                return DeviceType.SwitchRouter;

            return DeviceType.Unknown;
        }

        public static List<string> GenerateIpRange(string rangeInput)
        {
            var ipList = new List<string>();
            if (string.IsNullOrWhiteSpace(rangeInput)) return ipList;

            rangeInput = rangeInput.Trim();

            // "10.7.202.1 - 10.7.202.50" formatı
            if (rangeInput.Contains("-"))
            {
                var parts = rangeInput.Split('-');
                if (parts.Length == 2 &&
                    IPAddress.TryParse(parts[0].Trim(), out var startIp) &&
                    IPAddress.TryParse(parts[1].Trim(), out var endIp))
                {
                    uint start = IpToUint(startIp.ToString());
                    uint end = IpToUint(endIp.ToString());

                    if (start > end) { var temp = start; start = end; end = temp; }
                    // Maksimum 512 IP ile sınırla (performans güvenliği)
                    if (end - start > 512) end = start + 512;

                    for (uint i = start; i <= end; i++)
                    {
                        ipList.Add(UintToIp(i));
                    }
                    return ipList;
                }
            }

            // CIDR formatı: "10.7.202.0/24"
            if (rangeInput.Contains("/"))
            {
                var parts = rangeInput.Split('/');
                if (parts.Length == 2 && IPAddress.TryParse(parts[0].Trim(), out var baseIp) && int.TryParse(parts[1].Trim(), out int cidr))
                {
                    cidr = Math.Max(24, Math.Min(30, cidr)); // En az /24 en fazla /30
                    uint ipUint = IpToUint(baseIp.ToString());
                    uint mask = uint.MaxValue << (32 - cidr);
                    uint network = ipUint & mask;
                    uint broadcast = network | ~mask;

                    for (uint i = network + 1; i < broadcast; i++)
                    {
                        ipList.Add(UintToIp(i));
                    }
                    return ipList;
                }
            }

            // Virgülle ayrılmış tekil IP'ler
            var ips = rangeInput.Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries);
            foreach (var ip in ips)
            {
                var tr = ip.Trim();
                if (IPAddress.TryParse(tr, out _))
                {
                    ipList.Add(tr);
                }
            }

            return ipList;
        }

        private static uint IpToUint(string ipAddress)
        {
            var bytes = IPAddress.Parse(ipAddress).GetAddressBytes();
            if (BitConverter.IsLittleEndian) Array.Reverse(bytes);
            return BitConverter.ToUInt32(bytes, 0);
        }

        private static string UintToIp(uint ipUint)
        {
            var bytes = BitConverter.GetBytes(ipUint);
            if (BitConverter.IsLittleEndian) Array.Reverse(bytes);
            return new IPAddress(bytes).ToString();
        }

        #endregion

        #region 3. HIKVISION IP KAMERA YÖNETİMİ

        public CameraDeviceInfo GetCameraInfo(string ip, string username = "admin", string password = "", int port = 80)
        {
            var result = new CameraDeviceInfo
            {
                IpAddress = ip,
                HttpPort = port,
                RtspPort = 554,
                QueryTime = DateTime.Now
            };

            if (!IsPortOpen(ip, port, 1500) && !IsPortOpen(ip, 8000, 1500) && !IsPortOpen(ip, 554, 1500))
            {
                result.IsOnline = false;
                result.ErrorMessage = $"Kamera IP adresine ({ip}:{port}) ulaşılamıyor. Kamera kapalı veya port kapalı.";
                return result;
            }

            result.IsOnline = true;
            result.RtspUrl = $"rtsp://{(string.IsNullOrWhiteSpace(username) ? "" : username + ":" + password + "@")}{ip}:554/Streaming/Channels/101";
            result.SnapshotUrl = $"http://{ip}:{port}/ISAPI/Streaming/channels/101/picture";

            // ISAPI /ISAPI/System/deviceInfo endpoint sorgusu
            try
            {
                string url = $"http://{ip}:{port}/ISAPI/System/deviceInfo";
                var request = (HttpWebRequest)WebRequest.Create(url);
                request.Method = "GET";
                request.Timeout = 4000;

                var credentialCache = new CredentialCache();
                credentialCache.Add(new Uri(url), "Digest", new NetworkCredential(username, password));
                credentialCache.Add(new Uri(url), "Basic", new NetworkCredential(username, password));
                request.Credentials = credentialCache;

                using (var response = (HttpWebResponse)request.GetResponse())
                using (var stream = response.GetResponseStream())
                using (var reader = new StreamReader(stream, Encoding.UTF8))
                {
                    string xml = reader.ReadToEnd();
                    var doc = XDocument.Parse(xml);
                    XNamespace ns = doc.Root?.Name.Namespace ?? XNamespace.None;

                    result.DeviceName = doc.Descendants(ns + "deviceName").FirstOrDefault()?.Value ?? "Hikvision Kamera";
                    result.Model = doc.Descendants(ns + "model").FirstOrDefault()?.Value ?? string.Empty;
                    result.SerialNumber = doc.Descendants(ns + "serialNumber").FirstOrDefault()?.Value ?? string.Empty;
                    result.MacAddress = doc.Descendants(ns + "macAddress").FirstOrDefault()?.Value ?? string.Empty;
                    result.FirmwareVersion = doc.Descendants(ns + "firmwareVersion").FirstOrDefault()?.Value ?? string.Empty;
                }
            }
            catch (Exception ex)
            {
                result.ErrorMessage = $"ISAPI Cihaz Bilgisi Alınamadı: {ex.Message}";
                if (string.IsNullOrWhiteSpace(result.Model)) result.Model = "Hikvision IP Kamera (Genel)";
            }

            return result;
        }

        #endregion

        #region 4. RAPORLAMA & DIŞA AKTARMA (EXCEL / HTML)

        public byte[] ExportToExcel(ComputerInfo pc)
        {
            using (var wb = new XLWorkbook())
            {
                // Sayfa 1: Donanım & Sistem Detayı
                var ws = wb.Worksheets.Add("Donanım Detayı");

                int r = 1;
                AddExcelSection(ws, "GENEL SİSTEM BİLGİLERİ", ref r);
                AddExcelRow(ws, "Bilgisayar Adı", pc.ComputerName, ref r);
                AddExcelRow(ws, "Üretici", pc.Manufacturer, ref r);
                AddExcelRow(ws, "Model", pc.Model, ref r);
                AddExcelRow(ws, "Seri Numarası", pc.SerialNumber, ref r);
                AddExcelRow(ws, "Sistem Türü", pc.SystemType, ref r);
                AddExcelRow(ws, "Domain / Çalışma Grubu", string.IsNullOrWhiteSpace(pc.Domain) ? pc.Workgroup : pc.Domain, ref r);
                AddExcelRow(ws, "Aktif Kullanıcı", pc.CurrentUser, ref r);
                AddExcelRow(ws, "Anakart Modeli", $"{pc.Motherboard?.Manufacturer} {pc.Motherboard?.Product}", ref r);
                AddExcelRow(ws, "BIOS Sürümü", $"{pc.Bios?.Manufacturer} {pc.Bios?.Version} ({pc.Bios?.ReleaseDate})", ref r);
                r++;

                if (pc.Cpu != null)
                {
                    AddExcelSection(ws, "İŞLEMCİ (CPU)", ref r);
                    AddExcelRow(ws, "İşlemci Modeli", pc.Cpu.Name, ref r);
                    AddExcelRow(ws, "Çekirdek / İzlek", $"{pc.Cpu.Cores} Çekirdek / {pc.Cpu.Threads} İzlek", ref r);
                    AddExcelRow(ws, "Maksimum Frekans", pc.Cpu.MaxSpeedGhz, ref r);
                    AddExcelRow(ws, "Mevcut Frekans", pc.Cpu.CurrentSpeedGhz, ref r);
                    AddExcelRow(ws, "Mimari", pc.Cpu.Architecture, ref r);
                    r++;
                }

                if (pc.Memory != null)
                {
                    AddExcelSection(ws, "BELLEK (RAM)", ref r);
                    AddExcelRow(ws, "Toplam RAM", $"{pc.Memory.TotalGb:F1} GB", ref r);
                    foreach (var slot in pc.Memory.Slots)
                    {
                        AddExcelRow(ws, slot.Tag, $"{slot.Manufacturer} {slot.CapacityGb:F1} GB {slot.SpeedMhz} MHz ({slot.PartNumber})", ref r);
                    }
                    r++;
                }

                if (pc.Disks != null && pc.Disks.Count > 0)
                {
                    AddExcelSection(ws, "DİSKLER VE DEPOLAMA", ref r);
                    foreach (var d in pc.Disks)
                    {
                        AddExcelRow(ws, d.Model, $"{d.MediaType} | {d.TotalSizeGb:F1} GB | S/N: {d.SerialNumber}", ref r);
                        foreach (var ld in d.LogicalDisks)
                        {
                            AddExcelRow(ws, $"  Sürücü {ld.DriveLetter}", $"{ld.Label} ({ld.FileSystem}) - Kullanılan: {ld.UsedSpaceGb:F1} GB / Boş: {ld.FreeSpaceGb:F1} GB ({ld.UsedPercent:F1}%)", ref r);
                        }
                    }
                    r++;
                }

                if (pc.Monitors != null && pc.Monitors.Count > 0)
                {
                    AddExcelSection(ws, "BAĞLI MONİTÖRLER (SERİ NO İLE)", ref r);
                    foreach (var m in pc.Monitors)
                    {
                        AddExcelRow(ws, m.Model, $"Marka: {m.Manufacturer} | Seri No: {m.SerialNumber} | Üretim Yılı: {m.YearOfManufacture}", ref r);
                    }
                    r++;
                }

                if (pc.UsbDevices != null && pc.UsbDevices.Count > 0)
                {
                    AddExcelSection(ws, "BAĞLI USB VE OPTİK AYGITLAR", ref r);
                    foreach (var u in pc.UsbDevices.Take(25))
                    {
                        AddExcelRow(ws, u.Name, $"{u.Manufacturer} - Durum: {u.Status}", ref r);
                    }
                    r++;
                }

                if (pc.Printers != null && pc.Printers.Count > 0)
                {
                    AddExcelSection(ws, "YAZICILAR", ref r);
                    foreach (var p in pc.Printers)
                    {
                        AddExcelRow(ws, p.Name, $"Sürücü: {p.DriverName} | Port: {p.PortName} | {(p.IsDefault ? "[Varsayılan]" : "")}", ref r);
                    }
                    r++;
                }

                ws.Columns().AdjustToContents();

                // Sayfa 2: Kurulu Yazılımlar
                if (pc.InstalledSoftware != null && pc.InstalledSoftware.Count > 0)
                {
                    var wsSoft = wb.Worksheets.Add("Kurulu Yazılımlar");
                    string[] headers = { "Yazılım Adı", "Sürüm", "Yayıncı", "Yükleme Tarihi", "Mimari" };
                    for (int i = 0; i < headers.Length; i++)
                    {
                        var cell = wsSoft.Cell(1, i + 1);
                        cell.Value = headers[i];
                        cell.Style.Font.Bold = true;
                        cell.Style.Fill.BackgroundColor = XLColor.FromHtml("#1E293B");
                        cell.Style.Font.FontColor = XLColor.White;
                    }

                    int sRow = 2;
                    foreach (var soft in pc.InstalledSoftware)
                    {
                        wsSoft.Cell(sRow, 1).Value = soft.Name;
                        wsSoft.Cell(sRow, 2).Value = soft.Version;
                        wsSoft.Cell(sRow, 3).Value = soft.Publisher;
                        wsSoft.Cell(sRow, 4).Value = soft.InstallDate;
                        wsSoft.Cell(sRow, 5).Value = soft.Architecture;
                        sRow++;
                    }
                    wsSoft.Columns().AdjustToContents();
                }

                using (var ms = new MemoryStream())
                {
                    wb.SaveAs(ms);
                    return ms.ToArray();
                }
            }
        }

        private static void AddExcelSection(IXLWorksheet ws, string title, ref int row)
        {
            var cell = ws.Cell(row, 1);
            cell.Value = title;
            cell.Style.Font.Bold = true;
            cell.Style.Fill.BackgroundColor = XLColor.FromHtml("#1E293B");
            cell.Style.Font.FontColor = XLColor.White;
            ws.Range(row, 1, row, 3).Merge();
            row++;
        }

        private static void AddExcelRow(IXLWorksheet ws, string label, string value, ref int row)
        {
            ws.Cell(row, 1).Value = label;
            ws.Cell(row, 1).Style.Font.Bold = true;
            ws.Cell(row, 2).Value = value ?? "";
            row++;
        }

        public string ExportToHtml(ComputerInfo pc)
        {
            var sb = new StringBuilder();
            sb.Append("<!DOCTYPE html><html lang='tr'><head><meta charset='utf-8'><title>PCInfo Raporu - ").Append(pc.ComputerName).Append("</title>");
            sb.Append("<style>body{font-family:-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,sans-serif;padding:30px;color:#1e293b;line-height:1.5;}");
            sb.Append("h2,h3{color:#0f172a;border-bottom:2px solid #0284c7;padding-bottom:6px;}");
            sb.Append("table{width:100%;border-collapse:collapse;margin-bottom:25px;}th,td{border:1px solid #cbd5e1;padding:8px 12px;text-align:left;}th{background:#f1f5f9;font-weight:600;width:30%;}");
            sb.Append(".badge{display:inline-block;padding:3px 8px;border-radius:12px;font-size:12px;font-weight:600;background:#e0f2fe;color:#0369a1;}");
            sb.Append("@media print{button{display:none;}body{padding:0;}}</style></head><body>");

            sb.Append("<div style='display:flex;justify-content:space-between;align-items:center;'>");
            sb.Append("<h2><span style='color:#0284c7;'>PCInfo</span> Donanım & Donanım Teşhis Raporu</h2>");
            sb.Append("<button onclick='window.print()' style='padding:8px 16px;background:#0284c7;color:#fff;border:none;border-radius:6px;cursor:pointer;'>Yazdır / PDF Kaydet</button>");
            sb.Append("</div>");

            sb.Append("<p><strong>Hedef:</strong> ").Append(pc.Target).Append(" | <strong>Rapor Tarihi:</strong> ").Append(pc.QueryTime.ToString("dd.MM.yyyy HH:mm:ss")).Append("</p>");

            // Sistem
            sb.Append("<h3>Sistem ve Anakart</h3><table>");
            sb.Append("<tr><th>Bilgisayar Adı</th><td>").Append(pc.ComputerName).Append("</td></tr>");
            sb.Append("<tr><th>Üretici ve Model</th><td>").Append(pc.Manufacturer).Append(" ").Append(pc.Model).Append("</td></tr>");
            sb.Append("<tr><th>Seri Numarası</th><td><strong>").Append(pc.SerialNumber).Append("</strong></td></tr>");
            sb.Append("<tr><th>İşletim Sistemi</th><td>").Append(pc.Windows?.Caption).Append(" (").Append(pc.Windows?.Architecture).Append(")</td></tr>");
            sb.Append("<tr><th>Anakart & BIOS</th><td>").Append(pc.Motherboard?.Product).Append(" | BIOS: ").Append(pc.Bios?.Version).Append("</td></tr>");
            sb.Append("</table>");

            // CPU & RAM
            sb.Append("<h3>İşlemci ve Bellek</h3><table>");
            sb.Append("<tr><th>İşlemci (CPU)</th><td>").Append(pc.Cpu?.Name).Append(" (").Append(pc.Cpu?.Cores).Append(" Çekirdek / ").Append(pc.Cpu?.Threads).Append(" Thread)</td></tr>");
            sb.Append("<tr><th>Toplam Bellek</th><td>").Append(pc.Memory?.TotalGb).Append(" GB RAM</td></tr>");
            sb.Append("</table>");

            // Monitörler
            if (pc.Monitors != null && pc.Monitors.Count > 0)
            {
                sb.Append("<h3>Bağlı Monitörler (Seri No ile)</h3><table><thead><tr><th style='width:auto;'>Model</th><th>Üretici</th><th>Seri Numarası</th><th>Üretim Yılı</th></tr></thead><tbody>");
                foreach (var m in pc.Monitors)
                {
                    sb.Append("<tr><td>").Append(m.Model).Append("</td><td>").Append(m.Manufacturer).Append("</td><td><strong>").Append(m.SerialNumber).Append("</strong></td><td>").Append(m.YearOfManufacture).Append("</td></tr>");
                }
                sb.Append("</tbody></table>");
            }

            // USB & Optik Okuyucular
            if (pc.UsbDevices != null && pc.UsbDevices.Count > 0)
            {
                sb.Append("<h3>Bağlı USB / Pasaport / Kimlik Okuyucu Aygıtları</h3><table><thead><tr><th style='width:auto;'>Aygıt Adı</th><th>Üretici</th><th>Durum</th></tr></thead><tbody>");
                foreach (var u in pc.UsbDevices.Take(30))
                {
                    sb.Append("<tr><td>").Append(u.Name).Append("</td><td>").Append(u.Manufacturer).Append("</td><td>").Append(u.Status).Append("</td></tr>");
                }
                sb.Append("</tbody></table>");
            }

            // Diskler
            if (pc.Disks != null && pc.Disks.Count > 0)
            {
                sb.Append("<h3>Depolama & Sürücüler</h3><table><thead><tr><th style='width:auto;'>Sürücü / Disk</th><th>Medya Türü</th><th>Toplam Boyut</th><th>Kullanılan / Boş</th></tr></thead><tbody>");
                foreach (var d in pc.Disks)
                {
                    sb.Append("<tr style='background:#f8fafc;'><td colspan='4'><strong>").Append(d.Model).Append(" (").Append(d.TotalSizeGb).Append(" GB)</strong></td></tr>");
                    foreach (var ld in d.LogicalDisks)
                    {
                        sb.Append("<tr><td>Sürücü ").Append(ld.DriveLetter).Append(" (").Append(ld.Label).Append(")</td><td>").Append(ld.FileSystem).Append("</td><td>").Append(ld.TotalSizeGb).Append(" GB</td><td>Kullanılan: ").Append(ld.UsedSpaceGb).Append(" GB / Boş: ").Append(ld.FreeSpaceGb).Append(" GB</td></tr>");
                    }
                }
                sb.Append("</tbody></table>");
            }

            sb.Append("</body></html>");
            return sb.ToString();
        }

        #endregion

        #region 5. CEZA VERİTABANI ENVANTER YÖNETİMİ (INVENTORY)

        private static bool _tableChecked = false;
        private static readonly object _tableLock = new object();

        public void EnsureInventoryTableExists()
        {
            if (_tableChecked) return;
            lock (_tableLock)
            {
                if (_tableChecked) return;
                try
                {
                    using (var db = new gzpegm.Models.GZPEGM1())
                    {
                        const string createTableSql = @"
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_PCInfoDevices' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[tbl_PCInfoDevices]
    (
        [Id]                   INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
        [AssetTag]             NVARCHAR(64) NULL,
        [Category]             INT NOT NULL DEFAULT 1,
        [Brand]                NVARCHAR(128) NOT NULL DEFAULT '',
        [Model]                NVARCHAR(128) NOT NULL DEFAULT '',
        [SerialNumber]         NVARCHAR(128) NOT NULL DEFAULT '',
        [Location]             NVARCHAR(256) NOT NULL DEFAULT '',
        [RoomNumber]           NVARCHAR(64) NULL,
        [AssignedPerson]       NVARCHAR(128) NULL,
        [ProcurementDate]      DATETIME NULL,
        [DeliveryDate]         DATETIME NULL,
        [WarrantyExpiryDate]   DATETIME NULL,
        [Status]               INT NOT NULL DEFAULT 1,
        [IpAddress]            NVARCHAR(64) NULL,
        [MacAddress]           NVARCHAR(64) NULL,
        [ImagePath]            NVARCHAR(500) NULL,
        [Notes]                NVARCHAR(2000) NULL,
        [TechnicalDetailsJson] NVARCHAR(MAX) NULL,
        [CreatedAt]            DATETIME NOT NULL DEFAULT GETDATE(),
        [UpdatedAt]            DATETIME NOT NULL DEFAULT GETDATE()
    );

    CREATE NONCLUSTERED INDEX [IX_tbl_PCInfoDevices_SerialNumber] ON [dbo].[tbl_PCInfoDevices] ([SerialNumber] ASC);
    CREATE NONCLUSTERED INDEX [IX_tbl_PCInfoDevices_IpAddress] ON [dbo].[tbl_PCInfoDevices] ([IpAddress] ASC);
    CREATE NONCLUSTERED INDEX [IX_tbl_PCInfoDevices_Location] ON [dbo].[tbl_PCInfoDevices] ([Location] ASC);
END";
                        db.Database.ExecuteSqlCommand(createTableSql);
                    }
                    _tableChecked = true;
                }
                catch { }
            }
        }

        public List<DeviceEntity> GetAllDevices(string search = null, int? category = null, int? status = null, string location = null)
        {
            EnsureInventoryTableExists();
            try
            {
                using (var db = new gzpegm.Models.GZPEGM1())
                {
                    var sql = new StringBuilder("SELECT * FROM dbo.tbl_PCInfoDevices WHERE 1=1 ");
                    var pars = new List<object>();

                    if (!string.IsNullOrWhiteSpace(search))
                    {
                        var pName = "@p" + pars.Count;
                        sql.Append($"AND (Brand LIKE {pName} OR Model LIKE {pName} OR SerialNumber LIKE {pName} OR Location LIKE {pName} OR AssignedPerson LIKE {pName} OR IpAddress LIKE {pName} OR AssetTag LIKE {pName}) ");
                        pars.Add("%" + search.Trim() + "%");
                    }

                    if (category.HasValue && category.Value > 0)
                    {
                        var pName = "@p" + pars.Count;
                        sql.Append($"AND Category = {pName} ");
                        pars.Add(category.Value);
                    }

                    if (status.HasValue && status.Value > 0)
                    {
                        var pName = "@p" + pars.Count;
                        sql.Append($"AND Status = {pName} ");
                        pars.Add(status.Value);
                    }

                    if (!string.IsNullOrWhiteSpace(location))
                    {
                        var pName = "@p" + pars.Count;
                        sql.Append($"AND Location = {pName} ");
                        pars.Add(location.Trim());
                    }

                    sql.Append("ORDER BY UpdatedAt DESC");

                    return db.Database.SqlQuery<DeviceEntity>(sql.ToString(), pars.ToArray()).ToList();
                }
            }
            catch
            {
                return new List<DeviceEntity>();
            }
        }

        public DeviceEntity GetDeviceById(int id)
        {
            EnsureInventoryTableExists();
            try
            {
                using (var db = new gzpegm.Models.GZPEGM1())
                {
                    return db.Database.SqlQuery<DeviceEntity>("SELECT * FROM dbo.tbl_PCInfoDevices WHERE Id=@p0", id).FirstOrDefault();
                }
            }
            catch
            {
                return null;
            }
        }

        public int SaveDevice(DeviceEntity d)
        {
            EnsureInventoryTableExists();
            try
            {
                using (var db = new gzpegm.Models.GZPEGM1())
                {
                    if (d.Id > 0)
                    {
                        const string updateSql = @"
UPDATE dbo.tbl_PCInfoDevices SET
    AssetTag = @p0, Category = @p1, Brand = @p2, Model = @p3, SerialNumber = @p4,
    Location = @p5, RoomNumber = @p6, AssignedPerson = @p7, ProcurementDate = @p8,
    DeliveryDate = @p9, WarrantyExpiryDate = @p10, Status = @p11, IpAddress = @p12,
    MacAddress = @p13, ImagePath = @p14, Notes = @p15, TechnicalDetailsJson = @p16,
    UpdatedAt = GETDATE()
WHERE Id = @p17";
                        db.Database.ExecuteSqlCommand(updateSql,
                            d.AssetTag ?? (object)DBNull.Value,
                            d.Category,
                            d.Brand ?? "",
                            d.Model ?? "",
                            d.SerialNumber ?? "",
                            d.Location ?? "",
                            d.RoomNumber ?? (object)DBNull.Value,
                            d.AssignedPerson ?? (object)DBNull.Value,
                            d.ProcurementDate ?? (object)DBNull.Value,
                            d.DeliveryDate ?? (object)DBNull.Value,
                            d.WarrantyExpiryDate ?? (object)DBNull.Value,
                            d.Status,
                            d.IpAddress ?? (object)DBNull.Value,
                            d.MacAddress ?? (object)DBNull.Value,
                            d.ImagePath ?? (object)DBNull.Value,
                            d.Notes ?? (object)DBNull.Value,
                            d.TechnicalDetailsJson ?? (object)DBNull.Value,
                            d.Id);

                        return d.Id;
                    }
                    else
                    {
                        const string insertSql = @"
INSERT INTO dbo.tbl_PCInfoDevices
    (AssetTag, Category, Brand, Model, SerialNumber, Location, RoomNumber, AssignedPerson, ProcurementDate, DeliveryDate, WarrantyExpiryDate, Status, IpAddress, MacAddress, ImagePath, Notes, TechnicalDetailsJson, CreatedAt, UpdatedAt)
VALUES
    (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11, @p12, @p13, @p14, @p15, @p16, GETDATE(), GETDATE());
SELECT SCOPE_IDENTITY();";
                        var newId = db.Database.SqlQuery<decimal>(insertSql,
                            d.AssetTag ?? (object)DBNull.Value,
                            d.Category,
                            d.Brand ?? "",
                            d.Model ?? "",
                            d.SerialNumber ?? "",
                            d.Location ?? "",
                            d.RoomNumber ?? (object)DBNull.Value,
                            d.AssignedPerson ?? (object)DBNull.Value,
                            d.ProcurementDate ?? (object)DBNull.Value,
                            d.DeliveryDate ?? (object)DBNull.Value,
                            d.WarrantyExpiryDate ?? (object)DBNull.Value,
                            d.Status,
                            d.IpAddress ?? (object)DBNull.Value,
                            d.MacAddress ?? (object)DBNull.Value,
                            d.ImagePath ?? (object)DBNull.Value,
                            d.Notes ?? (object)DBNull.Value,
                            d.TechnicalDetailsJson ?? (object)DBNull.Value).FirstOrDefault();

                        return Convert.ToInt32(newId);
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Envanter kaydı kaydedilemedi: " + ex.Message, ex);
            }
        }

        public bool DeleteDevice(int id)
        {
            EnsureInventoryTableExists();
            try
            {
                using (var db = new gzpegm.Models.GZPEGM1())
                {
                    db.Database.ExecuteSqlCommand("DELETE FROM dbo.tbl_PCInfoDevices WHERE Id=@p0", id);
                    return true;
                }
            }
            catch
            {
                return false;
            }
        }

        public int SaveFromComputerInfo(ComputerInfo pc, string location, string assignedPerson, string notes, string assetTag = null, int category = 1)
        {
            EnsureInventoryTableExists();

            string json = Newtonsoft.Json.JsonConvert.SerializeObject(pc, Newtonsoft.Json.Formatting.None);
            string ip = pc.NetworkAdapters?.SelectMany(n => n.IpAddresses).FirstOrDefault() ?? pc.Target;
            string mac = pc.NetworkAdapters?.Select(n => n.MacAddress).FirstOrDefault(m => !string.IsNullOrWhiteSpace(m)) ?? "";

            // Mevcut kayıt var mı kontrol et (Seri numarası veya IP eşleşmesi)
            DeviceEntity existing = null;
            if (!string.IsNullOrWhiteSpace(pc.SerialNumber) && pc.SerialNumber != "—" && pc.SerialNumber != "To be filled by O.E.M.")
            {
                using (var db = new gzpegm.Models.GZPEGM1())
                {
                    existing = db.Database.SqlQuery<DeviceEntity>("SELECT TOP 1 * FROM dbo.tbl_PCInfoDevices WHERE SerialNumber=@p0", pc.SerialNumber).FirstOrDefault();
                }
            }

            if (existing == null && !string.IsNullOrWhiteSpace(ip) && ip != "localhost" && ip != "127.0.0.1")
            {
                using (var db = new gzpegm.Models.GZPEGM1())
                {
                    existing = db.Database.SqlQuery<DeviceEntity>("SELECT TOP 1 * FROM dbo.tbl_PCInfoDevices WHERE IpAddress=@p0", ip).FirstOrDefault();
                }
            }

            var device = existing ?? new DeviceEntity();
            if (!string.IsNullOrWhiteSpace(assetTag)) device.AssetTag = assetTag;
            device.Category = category;
            device.Brand = string.IsNullOrWhiteSpace(pc.Manufacturer) ? "Bilinmiyor" : pc.Manufacturer;
            device.Model = string.IsNullOrWhiteSpace(pc.Model) ? pc.ComputerName : pc.Model;
            device.SerialNumber = pc.SerialNumber ?? "";
            device.Location = string.IsNullOrWhiteSpace(location) ? (device.Location ?? "Hudut Kapısı") : location;
            device.AssignedPerson = string.IsNullOrWhiteSpace(assignedPerson) ? (device.AssignedPerson ?? pc.CurrentUser) : assignedPerson;
            device.Notes = string.IsNullOrWhiteSpace(notes) ? device.Notes : notes;
            device.IpAddress = ip;
            device.MacAddress = mac;
            device.TechnicalDetailsJson = json;
            device.Status = 1; // Aktif / Faal

            return SaveDevice(device);
        }

        public int SaveFromScanItem(ScanItemResult scan, string location = null)
        {
            EnsureInventoryTableExists();

            DeviceEntity existing = null;
            using (var db = new gzpegm.Models.GZPEGM1())
            {
                existing = db.Database.SqlQuery<DeviceEntity>("SELECT TOP 1 * FROM dbo.tbl_PCInfoDevices WHERE IpAddress=@p0", scan.IpAddress).FirstOrDefault();
            }

            int category = 1;
            if (scan.DeviceType == DeviceType.HikvisionCamera) category = 4;
            else if (scan.DeviceType == DeviceType.Printer) category = 7;
            else if (scan.DeviceType == DeviceType.SwitchRouter) category = 9;

            var device = existing ?? new DeviceEntity();
            device.Category = category;
            device.Brand = scan.DeviceType == DeviceType.HikvisionCamera ? "Hikvision" : "Ağ Cihazı";
            device.Model = string.IsNullOrWhiteSpace(scan.HostName) ? scan.DeviceTypeDisplay : scan.HostName;
            device.IpAddress = scan.IpAddress;
            device.Location = string.IsNullOrWhiteSpace(location) ? (device.Location ?? "Hudut Kapısı Ağı") : location;
            device.Notes = scan.Details;
            device.Status = 1;

            return SaveDevice(device);
        }

        public byte[] ExportInventoryToExcel(List<DeviceEntity> devices)
        {
            using (var wb = new XLWorkbook())
            {
                var ws = wb.Worksheets.Add("Donanım Envanteri");

                string[] headers = {
                    "ID", "Demirbaş No", "Kategori", "Marka", "Model",
                    "Seri Numarası", "Mevki / Gişe", "Oda No", "Zimmetli Personel",
                    "Durum", "IP Adresi", "MAC Adresi", "Açıklama / Notlar", "Kayıt Tarihi"
                };

                for (int i = 0; i < headers.Length; i++)
                {
                    var cell = ws.Cell(1, i + 1);
                    cell.Value = headers[i];
                    cell.Style.Font.Bold = true;
                    cell.Style.Fill.BackgroundColor = XLColor.FromHtml("#1E293B");
                    cell.Style.Font.FontColor = XLColor.White;
                }

                int row = 2;
                foreach (var d in devices)
                {
                    ws.Cell(row, 1).Value = d.Id;
                    ws.Cell(row, 2).Value = d.AssetTag ?? "";
                    ws.Cell(row, 3).Value = d.GetCategoryName();
                    ws.Cell(row, 4).Value = d.Brand;
                    ws.Cell(row, 5).Value = d.Model;
                    ws.Cell(row, 6).Value = d.SerialNumber;
                    ws.Cell(row, 7).Value = d.Location;
                    ws.Cell(row, 8).Value = d.RoomNumber ?? "";
                    ws.Cell(row, 9).Value = d.AssignedPerson ?? "";
                    ws.Cell(row, 10).Value = d.GetStatusName();
                    ws.Cell(row, 11).Value = d.IpAddress ?? "";
                    ws.Cell(row, 12).Value = d.MacAddress ?? "";
                    ws.Cell(row, 13).Value = d.Notes ?? "";
                    ws.Cell(row, 14).Value = d.CreatedAt.ToString("dd.MM.yyyy HH:mm");

                    row++;
                }

                ws.Columns().AdjustToContents();

                using (var ms = new MemoryStream())
                {
                    wb.SaveAs(ms);
                    return ms.ToArray();
                }
            }
        }

        #endregion
    }
}
