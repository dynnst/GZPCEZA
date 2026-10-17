# Gereksinim Belgesi

## Giriş

Bu belge, GZPEGM ASP.NET MVC 5 uygulamasındaki şifre sıfırlama akışının yeniden tasarlanmasına ilişkin gereksinimleri tanımlar. Mevcut akışta personel, sicil numarası ve e-posta adresiyle şifresini anında değiştirebilmekte; bu durum sicil ve e-posta bilgisini bilen üçüncü kişilerin hesaba erişim riskini doğurmaktadır. Yeni akışta personel yalnızca sicil numarasıyla talep oluşturur, şifre değişikliği admin onayına bırakılır ve yeni şifre admin tarafından üretilerek personele iletilir.

Sistem kapalı ağ ortamında çalıştığından e-posta gönderimi bulunmamaktadır.

## Sözlük

- **Sistem**: GZPEGM ASP.NET MVC 5 web uygulaması
- **Personel**: Sisteme giriş yetkisi olan, `E_User` tablosunda kaydı bulunan kullanıcı
- **Admin**: `[UserAuthorize(Users = "2")]` filtresiyle korunan, `Role = "Admin"` yetkisine sahip kullanıcı
- **SifreSifirlamaTalebi** (`PasswordResetRequest`): Personelin oluşturduğu ve admin onayını bekleyen şifre sıfırlama kaydı
- **Talep Durumu**: `Beklemede (0)`, `Onaylandı (1)`, `Reddedildi (2)` değerlerinden birini alabilen durum alanı
- **GirisController**: `/SifreSifirla` rotasını yöneten ASP.NET MVC denetleyicisi
- **AllUsersController**: `/Kullanıcılar` rotasını yöneten, admin işlemlerini barındıran ASP.NET MVC denetleyicisi
- **GZPEGM1**: Entity Framework veritabanı bağlamı
- **CryptoHelper**: BCrypt tabanlı şifre hashleme kütüphanesi (`CryptoHelper.Crypto.HashPassword`)

---

## Gereksinimler

### Gereksinim 1: Şifre Sıfırlama Talebi Oluşturma

**Kullanıcı Hikayesi:** Personel olarak, şifremi unuttuğumda sicil numaramı girerek admin onayına bir talep oluşturmak istiyorum; böylece yetkisiz kişilerin hesabıma erişme riski olmaksızın şifremi sıfırlayabileyim.

#### Kabul Kriterleri

1. WHEN personel `/SifreSifirla` sayfasına erişir, THE Sistem SHALL sicil numarası alanından oluşan bir form gösterir.
2. WHEN personel geçerli bir sicil numarası gönderir, THE GirisController SHALL sicil numarasını `E_User` tablosunda arar.
3. IF sicil numarası `E_User` tablosunda bulunamazsa, THEN THE GirisController SHALL `{ success: false, message: "Sicil numarası sistemde bulunamadı!" }` yanıtı döner.
4. IF personel hesabı pasif durumda (`IsActive = false` veya `fldActive = "0"`) ise, THEN THE GirisController SHALL `{ success: false, message: "Bu kullanıcı hesabı pasif durumdadır!" }` yanıtı döner.
5. WHEN sicil numarası aktif bir `E_User` kaydıyla eşleşir, THE GirisController SHALL `PasswordResetRequest` tablosunda `Status = 0 (Beklemede)`, `RequestDate = DateTime.Now`, `UserId` ve `SicilNo` alanlarını içeren yeni bir kayıt oluşturur.
6. WHEN `PasswordResetRequest` kaydı başarıyla oluşturulur, THE GirisController SHALL `{ success: true }` yanıtı döner ve arayüzde "Talebiniz alındı, admin onayından sonra yeni şifrenizi kullanabilirsiniz." mesajı gösterilir.
7. WHEN personelin `Beklemede (Status = 0)` durumunda zaten bir talebi varsa, THE GirisController SHALL yeni kayıt oluşturmaz ve `{ success: false, message: "Zaten beklemede bir şifre sıfırlama talebiniz bulunmaktadır." }` yanıtı döner.
8. THE GirisController SHALL şifre sıfırlama talebini işlerken `E_User` tablosundaki `fldPassword` alanını değiştirmez.

---

### Gereksinim 2: Şifre Sıfırlama Formu Güncelleme

**Kullanıcı Hikayesi:** Personel olarak, şifre sıfırlama formunda yalnızca sicil numaramı girmek istiyorum; e-posta adresimi girmek zorunda kalmak istemiyorum.

#### Kabul Kriterleri

1. THE Sistem SHALL `/SifreSifirla` sayfasında yalnızca sicil numarası giriş alanını gösterir; e-posta alanı kaldırılır.
2. THE Sistem SHALL formda CSRF koruması için `AntiForgeryToken` içerir.
3. WHEN talep başarıyla oluşturulur, THE Sistem SHALL personele ekranda "Talebiniz alındı, admin onayından sonra yeni şifrenizi kullanabilirsiniz." bilgi mesajını gösterir ve şifreyi ekranda göstermez.
4. WHEN talep başarısız olur, THE Sistem SHALL personele hata nedenini açıklayan bir mesaj gösterir.
5. WHEN personel formu gönderir, THE Sistem SHALL sicil numarasının yalnızca rakam içerdiğini doğrular; aksi hâlde `{ success: false, message: "Sicil numarası sadece rakamlardan oluşmalıdır." }` yanıtı döner.

---

### Gereksinim 3: Admin Panelinde Bekleyen Taleplerin Listelenmesi

**Kullanıcı Hikayesi:** Admin olarak, bekleyen şifre sıfırlama taleplerini `/Kullanıcılar` sayfasında görmek istiyorum; böylece talepleri hızlıca onaylayabileyim veya reddedebilleyim.

#### Kabul Kriterleri

1. WHEN Admin `/Kullanıcılar` sayfasına erişir, THE AllUsersController SHALL `PasswordResetRequest` tablosundan `Status = 0 (Beklemede)` olan tüm kayıtları `Usermodel.passwordResetRequests` alanına yükler.
2. THE Sistem SHALL bekleyen her talep için personelin adını, soyadını, sicil numarasını ve talep tarihini listeler.
3. WHILE `passwordResetRequests` listesi boşsa, THE Sistem SHALL "Bekleyen şifre sıfırlama talebi bulunmamaktadır." mesajını gösterir.
4. THE Sistem SHALL bekleyen taleplerin listelendiği bölümü yalnızca `[UserAuthorize(Users = "2")]` yetkisine sahip kullanıcılara gösterir.

---

### Gereksinim 4: Admin Tarafından Talebin Onaylanması

**Kullanıcı Hikayesi:** Admin olarak, bir şifre sıfırlama talebini onayladığımda rastgele güvenli bir şifre üretilmesini, hash'lenerek veritabanına kaydedilmesini ve yeni şifrenin ekranda gösterilmesini istiyorum; böylece şifreyi personele iletebiliyeyim.

#### Kabul Kriterleri

1. WHEN Admin bir talebi onaylar, THE AllUsersController SHALL büyük harf, küçük harf, rakam ve özel karakter içeren en az 8 karakterlik rastgele bir şifre üretir.
2. WHEN rastgele şifre üretilir, THE AllUsersController SHALL `CryptoHelper.Crypto.HashPassword()` ile şifreyi hashler ve ilgili `E_User` kaydının `fldPassword` alanını günceller.
3. WHEN `fldPassword` güncellenir, THE AllUsersController SHALL `PasswordResetRequest` kaydının `Status` alanını `1 (Onaylandı)` olarak günceller ve `ProcessedDate = DateTime.Now` değerini kaydeder.
4. WHEN talep onaylanır, THE AllUsersController SHALL `{ ok: true, newPassword: "<üretilen_şifre>", message: "Şifre başarıyla sıfırlandı." }` JSON yanıtı döner.
5. THE Sistem SHALL onay işlemini yalnızca `[UserAuthorize(Users = "2")]` yetkisine sahip kullanıcılara sunar.
6. IF belirtilen `requestId`'ye sahip `PasswordResetRequest` kaydı bulunamazsa, THEN THE AllUsersController SHALL `{ ok: false, message: "Talep bulunamadı." }` yanıtı döner.

---

### Gereksinim 5: Admin Tarafından Talebin Reddedilmesi

**Kullanıcı Hikayesi:** Admin olarak, uygunsuz gördüğüm bir şifre sıfırlama talebini reddedebilmek istiyorum; böylece ilgili personelin şifresi değiştirilmemiş olsun.

#### Kabul Kriterleri

1. WHEN Admin bir talebi reddeder, THE AllUsersController SHALL ilgili `PasswordResetRequest` kaydının `Status` alanını `2 (Reddedildi)` olarak günceller ve `ProcessedDate = DateTime.Now` değerini kaydeder.
2. WHEN `PasswordResetRequest` kaydı reddedilir, THE AllUsersController SHALL ilgili `E_User` kaydındaki `fldPassword` alanını değiştirmez.
3. WHEN talep reddedilir, THE AllUsersController SHALL `{ ok: true, message: "Talep reddedildi." }` JSON yanıtı döner.
4. IF belirtilen `requestId`'ye sahip `PasswordResetRequest` kaydı bulunamazsa, THEN THE AllUsersController SHALL `{ ok: false, message: "Talep bulunamadı." }` yanıtı döner.
5. THE Sistem SHALL red işlemini yalnızca `[UserAuthorize(Users = "2")]` yetkisine sahip kullanıcılara sunar.

---

### Gereksinim 6: PasswordResetRequest Veri Modeli

**Kullanıcı Hikayesi:** Geliştirici olarak, şifre sıfırlama taleplerini depolamak ve sorgulamak için veritabanında uygun bir tablo ve Entity Framework modeli olmasını istiyorum.

#### Kabul Kriterleri

1. THE Sistem SHALL aşağıdaki sütunlara sahip `PasswordResetRequest` tablosunu barındırır:
   - `Id` (int, PK, otomatik artan)
   - `UserId` (int, FK → `E_User.fldId`)
   - `SicilNo` (nvarchar(50))
   - `Status` (int): `0 = Beklemede`, `1 = Onaylandı`, `2 = Reddedildi`
   - `RequestDate` (datetime)
   - `ProcessedDate` (datetime, nullable)
2. THE Sistem SHALL `GZPEGM1` DbContext'e `DbSet<PasswordResetRequest> PasswordResetRequest` özelliğini ekler.
3. THE Sistem SHALL `PasswordResetRequest` sınıfını `gzpegm.Models` namespace'inde tanımlar.
4. THE Sistem SHALL `Usermodel` sınıfına `List<PasswordResetRequest> passwordResetRequests` özelliğini ekler.

---

### Gereksinim 7: Güvenli Şifre Üretimi

**Kullanıcı Hikayesi:** Admin olarak, üretilen yeni şifrenin yeterince güçlü olmasını istiyorum; böylece tahmin edilmesi zor olsun.

#### Kabul Kriterleri

1. THE AllUsersController SHALL şifre üretirken en az 1 büyük harf (`A-Z`), en az 1 küçük harf (`a-z`), en az 1 rakam (`0-9`) ve en az 1 özel karakter (`!@#$%^&*`) içeren 8 karakterlik şifreler üretir.
2. THE AllUsersController SHALL şifre karakterlerini tahmin edilemez sırada dizmek için `System.Security.Cryptography.RNGCryptoServiceProvider` kullanır; `System.Random` kullanmaz.
3. THE Sistem SHALL üretilen şifreyi yalnızca admin onay yanıtında (`JSON`) döner; `E_User` tablosunda düz metin olarak saklamaz.
