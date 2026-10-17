# CEZAM PROJESİ - GELİŞTİRME HAFIZASI VE DEVİR TESLİM DOSYASI
**Son Güncelleme:** 16 Ekim 2026  
**Proje Sahibi:** T.C. İçişleri Bakanlığı Emniyet Genel Müdürlüğü (EGM) / Naşit  
**Uygulama:** CEZAM - Havalimanı Şube Müdürlüğü Ceza Portalı & Personel Yönetim Sistemi

---

> [!IMPORTANT]
> **EVDEKİ BİLGİSAYARDA ANTIGRAVITY'YE VERİLECEK BAŞLANGIÇ TALİMATI:**  
> Evdeki bilgisayarda bu projeyi açtığınızda Antigravity sohbetine şu cümleyi yazmanız yeterlidir:  
> *"Proje kök dizinindeki `PROJE_HAFIZASI_VE_DURUM.md` dosyasını oku. İki sunuculu mimariyi, yaptığımız en son geliştirmeleri hatırla ve kaldığımız yerden devam edelim."*

---

## 1. PROJE MİMARİSİ VE TEKNİK ÖZET

- **Çerçeve:** ASP.NET MVC 5 (.NET Framework 4.7.2 / 4.8)
- **Veritabanı:** MSSQL Server (Entity Framework 6 - `GZPEGM1` DbContext)
- **Güvenlik & Kriptografi:** `CryptoHelper` (PBKDF2 Hash doğrulaması), Token tabanlı oturum yönetimi (`E_Token` tablosu ve HttpOnly Cookie).
- **Proje Konumu:** `c:\Users\Naşit\source\repos\CEZAM\CEZAM\CEZAM\gzpegm`
- **Çözüm / Derleme:** `C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe`
- **Geliştirme Sunucusu:** IIS Express (Varsayılan Port: `52500` - `http://localhost:52500`)

---

## 2. SUNUCU TOPOLOJİSİ VE AKILLI FAILOVER (YÜK DEVRETME) SİSTEMİ

Kullanıcımızın iki adet fiziksel sunucusu bulunmaktadır:
1. **Ana Sunucu (Primary):** `10.7.202.75`
2. **Yedek Sunucu (Backup):** `10.7.202.76`

### Karşılaşılan Sorun ve Çözülen İhtiyaç:
Kullanıcılar doğrudan yedek sunucuya (76) girdiklerinde yapılan işlemler ana sunucudan kopuyor ve istatistikler bölünüyordu. Ayrıca ana sunucu arızalandığında kullanıcıların kesintisiz yedek sunucuya aktarılması ve **IIS ARR / Donanımsal NLB kullanılmadan tamamen uygulama kodlarıyla** çözülmesi istendi.

### Uygulanan Mimari Çözümler:

#### A) Kod Seviyesinde Akıllı Yönlendirme & Failover (`ServerFailoverHelper.cs` & `Global.asax.cs`)
- **Otomatik Rol Algılama:** Sistem sunucu ağ kartındaki IP'leri okuyarak `10.7.202.75` ise `Primary`, `10.7.202.76` ise `Backup` rolünü otomatik üstlenir (`Web.config` ayarı: `ServerRole = Auto`).
- **Canlı Sağlık Denetimi:** Yedek sunucu, ana sunucunun `/Health/Check` adresini 5 saniyelik önbellek ve 1.5 saniye zaman aşımı ile aralıksız yoklar.
- **Şeffaf Yönlendirme:** Ana sunucu ayaktayken 76'ya gelen tüm kullanıcı istekleri HTTP 302 ile queryString ve parametreler korunarak `10.7.202.75` sunucusuna şeffaf yönlendirilir.
- **Acil Durum (Disaster Recovery):** 75 çökerse 76 yönlendirmeyi anında keser, sistemi lokal olarak sunar ve ekranın üstünde turuncu renkli *"Yedek Sunucu Acil Durum Modu Aktif"* bannerı gösterir (`_Master.cshtml`).
- **Bypass Koruması:** Sistem logları (`/hataloglari`), sağlık durumu (`/sistemsaglik`), statik CSS/JS dosyaları ve admin test parametresi (`?forceLocal=1`) yönlendirme dışı tutulmuştur.

#### B) "76'da Olan Kullanıcı 75'te Yok İse" Problemi ve Çözümü:
İki kademeli senkronizasyon motoru kuruldu:
1. **JIT (Just-In-Time) Canlı Giriş Senkronizasyonu (`GirisController.cs`):**
   - Kullanıcı 75'te giriş yaparken veritabanında yoksa, sistem hemen hata vermez.
   - Arka planda güvenli token (`X-Internal-Sync-Token`) ile 76'daki `/internal-sync/verify-and-get-user` servisine bağlanır.
   - 76 personelin şifresini doğrularsa, kullanıcının tüm bilgilerini (sicil, isim, şifre hash'i, rol, telefon, e-posta vb.) anında 75'in `E_User` tablosuna kopyalar.
   - Kullanıcı beklemeden oturum açar. (Aynı mekanizma 75 çöktüğünde 76 için de çift yönlü çalışır).
2. **Yönetici Tek Tıkla Eşitleme Paneli (`AllUsersController.cs` & `Views/AllUsers/Index.cshtml`):**
   - Kullanıcı Yönetimi sayfasına *"Sunucu Eşitleme (10.7.202.75 / 76)"* butonu ve modern bir modal eklendi.
   - İki sunucunun kullanıcı veritabanını canlı karşılaştırır (örn: Yerel 1.027, Karşı 1.035, Eksik 8).
   - Eksik personelleri tablo halinde döker ve *"Seçilen Personelleri Bu Sunucuya Aktar"* butonuyla şifre hash'leri bozulmadan tek tıkla kopyalar.

#### C) Güvenli İç Senkronizasyon Servisi (`InternalSyncController.cs`):
- `/internal-sync/verify-and-get-user` (POST): Şifre doğrulama ve kullanıcı profil aktarımı.
- `/internal-sync/users-summary` (GET): Karşılaştırma için sicil ve yetki özeti.
- `/internal-sync/get-users-detail` (POST): Toplu transfer için sicillerin detaylı dökümü.
- *Güvenlik Anahtarı:* `Web.config` -> `InternalSyncSecret` (`GZPEGM-CEZAM-SYNC-KEY-2026`).

---

## 3. DİĞER MODÜLLER VE YAPILAN GELİŞTİRMELER

1. **Ceza Hesaplama ve Canlıya Geçiş Brifingi:**
   - Ceza hesaplama ekranları modern animasyonlar ve detaylı hesaplama parametreleriyle zenginleştirildi.
   - Üst makamlara sunulmak üzere detaylı canlıya geçiş brifing raporu hazırlandı (`CEZAM_Canliya_Gecis_Brifing_Raporu.md`).
2. **Karanlık Siber Polis Giriş Ekranı:**
   - Havalimanı kontrol kulesi, pist ışıkları ve derin siber mavi parçacık efektlerine sahip özel arka plan tasarlandı.
   - Giriş kartı glassmorphism estetiğine kavuşturuldu.
3. **Sistem Sağlık Paneli (`/SistemSaglik` - `HealthController.cs`):**
   - Veritabanı gecikmesi, bellek tüketimi, disk alanı, servis yanıt süresi ve Failover eş sunucu durumu canlı kartlar olarak sunuldu.
4. **Hata Logları Takip Paneli (`/HataLoglari` - `ErrorLogsController.cs`):**
   - Uygulama içi hataların gerçek zamanlı filtrelenebildiği ve detaylarının incelenebildiği panel.
5. **Mesajlaşma Modülü (`/Mesaj/Inbox`, `/Mesaj/Compose`):**
   - Görüntülenen `GÃ¶nderen` gibi UTF-8 karakter bozulmaları (mojibake) giderildi.
   - CSS ve mobil uyumluluk sorunları düzeltildi.

---

## 4. KRİTİK DOSYALAR LİSTESİ

| Dosya Yolu | Açıklama |
| :--- | :--- |
| `gzpegm/Helpers/ServerFailoverHelper.cs` | Sunucu failover kontrolü, sağlık kontrolü, JIT ve toplu kullanıcı senkronizasyon motoru |
| `gzpegm/Controllers/InternalSyncController.cs` | Sunucular arası güvenli iç API uç noktaları |
| `gzpegm/Global.asax.cs` | `Application_BeginRequest` yönlendirme mantığı |
| `gzpegm/Controllers/GirisController.cs` | JIT uzaktan oturum açma ve kullanıcı aktarma kancası |
| `gzpegm/Controllers/AllUsersController.cs` | Çift sunucu kullanıcı karşılaştırma ve toplu aktarım metodları |
| `gzpegm/Views/AllUsers/Index.cshtml` | Kullanıcı eşitleme modalı ve yönetici paneli |
| `gzpegm/Views/Shared/_Master.cshtml` | Yedek sunucu aktifken gösterilen acil durum bannerı |
| `gzpegm/Web.config` | Failover ayarları (`ServerRole`, `PrimaryServerUrl`, `BackupServerUrl`, `InternalSyncSecret`) |
| `gzpegm/Controllers/HealthController.cs` | Sağlık kontrolü ve failover durum bilgisi |

---

## 5. EVDEKİ BİLGİSAYARDA KURULUM VE BAŞLATMA ADIMLARI

1. **Flash Bellekten Kopyalama:** Flash bellekteki `CEZAM` klasörünü evdeki bilgisayarınızın istediğiniz bir dizinine yapıştırın (örneğin `C:\source\repos\CEZAM`).
2. **Veritabanı (SQL Server):**
   - İş yerindeki MSSQL veritabanınızın `.bak` yedeğini evdeki MSSQL Server'a restore edin.
   - `Web.config` dosyasındaki `connectionStrings` bölümünde yer alan `Data Source=...` bilgisini evdeki SQL Server adınıza (örneğin `localhost` veya `.\SQLEXPRESS`) göre güncelleyin.
3. **Derleme ve Çalıştırma:**
   - Visual Studio 2022 ile `CEZAM\CEZAM\gzpegm.sln` veya `gzpegm\gzpegm.csproj` projesini açın.
   - Projeyi derleyin (`Build Solution` - 0 Hata ile derlenecektir).
   - `F5` veya `Ctrl+F5` ile projeyi çalıştırın.
4. **Antigravity ile Sohbeti Başlatma:**
   - Projeyi Antigravity'de açın ve yukarıdaki başlangıç talimatını girin.
   - Antigravity bu dosyayı okuyarak projeyi 100% doğrulukla devralacaktır.
