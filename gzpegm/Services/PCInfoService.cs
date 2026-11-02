using System;
using System.Collections.Generic;
using System.Linq;
using System.Management;
using System.Net.NetworkInformation;
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

            // 2. WMI Bağlantı Kapsamını Hazırla
            ManagementScope scope;
            try
            {
                if (isLocal)
                {
                    scope = new ManagementScope(@"\\.\root\cimv2");
                    scope.Connect();
                }
                else
                {
                    var options = new ConnectionOptions
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

            // 3. Sistem & Bilgisayar Bilgileri
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

            // 4. Seri Numarası & Ürün Adı
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

            // 5. İşletim Sistemi (Windows)
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

            // 6. İşlemci (CPU)
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

            // 7. Bellek Yuvaları (RAM Slots)
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

            // 8. Mantıksal Diskler (C:, D:)
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

            // 9. Fiziksel Diskler
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

            // Eğer fiziksel disk varsa mantıksal sürücüleri ilk diske veya sırasıyla ekle, yoksa sanal disk oluştur
            if (info.Disks.Count > 0)
            {
                info.Disks[0].LogicalDisks.AddRange(logicalDisks);
            }
            else if (logicalDisks.Count > 0)
            {
                var virtualDisk = new DiskInfo
                {
                    Model = "Sistem Mantıksal Sürücüleri",
                    MediaType = "Depolama",
                    TotalSizeGb = logicalDisks.Sum(x => x.TotalSizeGb),
                    LogicalDisks = logicalDisks
                };
                info.Disks.Add(virtualDisk);
            }

            // 10. Ekran Kartı (GPU)
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

            // 12. Ağ Bağdaştırıcıları (Network Adapters)
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

            // 13. Yüklü Yazılımlar
            if (isLocal)
            {
                GetInstalledSoftwareFromRegistry(info.InstalledSoftware);
            }

            return info;
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

                                    // Sistem bileşeni veya güncelleme olanları atla
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
    }
}
