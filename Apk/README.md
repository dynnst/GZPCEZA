# Pasaport Kontrol ve Hudut Kapıları Mobil APK Paketleri

Bu klasör, Pasaport Kontrol ve Sınır Kapıları için geliştirilen her iki kurumsal mobil uygulamanın (`cezam-calculator.apk` ve `sahtecilik_mobile.apk`) doğrudan kurulabilir güncel Android sürümlerini içermektedir.

---

### 📥 Doğrudan İndirme Bağlantıları (GitHub)
* 📱 **CEZAM (Vize & İkamet İhlali Hesaplayıcı v0.3.3):** 
  - [cezam-calculator.apk (Depo)](https://github.com/dynnst/GZPCEZA/raw/main/Apk/cezam-calculator.apk)
  - [cezam-calculator.apk (GitHub Release)](https://github.com/dynnst/GZPCEZA/releases/download/mobile-latest/cezam-calculator.apk)
* 🔍 **Pasaport ve Adli Belge İnceleme (v1.1.0):** 
  - [sahtecilik_mobile.apk (Depo)](https://github.com/dynnst/GZPCEZA/raw/main/Apk/sahtecilik_mobile.apk)
  - [sahtecilik_mobile.apk (GitHub Release)](https://github.com/dynnst/Sahtecilik/releases/download/latest/sahtecilik_mobile.apk)

---

### 📦 1. CEZAM - Vize ve İkamet İhlali Ceza Hesaplayıcı
* **Dosya Adı:** `cezam-calculator.apk`
* **Sürüm:** `0.3.3 (Build 6)`
* **Boyut:** ~64.5 MB (Son Güncel Derleme: 20.11.2026)
* **Desteklenen Platform:** Android 7.0 (API 24) ve üzeri / BlueStacks
* **Çalışma Modu:** %100 Çevrimdışı (İnternetsiz / Yerel Hesaplama Motoru)
* **Uygulama Teması:** Hudut Kapıları (✈️ Uçak • 🚢 Gemi • 🚗 Araba)

---

### 📦 2. Pasaport ve Adli Belge İnceleme Otomasyonu
* **Dosya Adı:** `sahtecilik_mobile.apk`
* **Sürüm:** `1.1.0 (Build 11)`
* **Boyut:** ~66.3 MB (Son Güncel Derleme: 20.11.2026)
* **Desteklenen Platform:** Android 7.0 (API 24) ve üzeri / BlueStacks
* **Çalışma Modu:** %100 Çevrimdışı (Cihaz Hafızasına Kayıt) / Opsiyonel Sunucu API

---

### 🚀 Kurulum Talimatları
1. **İndirme:** Yukarıdaki doğrudan indirme bağlantılarına dokunarak APK dosyasını telefonunuza veya tabletinize indirin.
2. **Güvenlik İzni:** Android ayarlarından tarayıcınıza veya dosya yöneticinize *"Bilinmeyen kaynaklardan uygulama yükle"* izni verin.
3. **Yükleme:** İndirilen APK dosyasına dokunarak kurulumu tamamlayın.
4. **Kullanım:** Uygulamayı açtığınızda internet veya sunucu bağlantısına ihtiyaç duymaksızın doğrudan tüm işlemleri yapabilirsiniz.

---

### 🌟 Temel ve Güncel Özellikler (v0.3.3)
* **Genelgeler & Mevzuat Rehberi (Güvenli Çevrim İçi Okuma Modu):**
  - Göç İdaresi Başkanlığı'nın 2020/17 sayılı Genelgesi (Madde 6 Vize İhlali Kısıtlama Esasları) ve 6458 sayılı YUKK rehberi mobil arayüze entegre edildi.
  - Sınır kapısı personeli için tüm tebliğ, kısıtlama süreleri ve Ç/N tahdit kodları nezaketli ve kurumsal terimlerle sunulur.
* **Sahtecilik & Belge İnceleme Masası Entegrasyonu:**
  - Sol çekmece menüsünden (Drawer) kardeş "Pasaport ve Adli Belge İnceleme" modülüne ve web portalına doğrudan geçiş köprüsü eklendi.
* **Resmi Tutanak & Tebliğ Metinlerinde Kurumsal İyileştirme:**
  - Tebliğ formlarında yer alan "giriş yasağı" ibareleri mevzuat gereği kurumsal ve nezaketli "giriş kısıtlama kararı" diliyle güncellendi.
  - PDF yazdırma dökümünde ceza ve defter bedeli alanları yüksek kontrastlı okunabilir biçime getirildi.
* **Çoklu Girişte Otomatik 180 Gün Kuralı Seçimi:**
  - Kullanıcı yeni bir giriş-çıkış seferi eklediğinde (`_addEntryExitRow`), hesaplama türü arayüzde ve motorda otomatik olarak **"180 Gün Kuralı (180/90)"** moduna geçer.
* **180/90 Kuralı Veri Eksikliği ve Normal Hesaplama Fallback Koruması:**
  - Bir ülke/vize kombinasyonunda 180/90 kuralı verisi bulunamazsa, sistem web motoru (`AjaxController.cs:195-199`) standardında otomatik olarak ilgili ülkenin **Normal Hesaplama verilerini** devreye sokar ve hiçbir zaman veri hatası vermez.
  - Ayrıca `cezam_data.json` veritabanındaki 1.991 eksik 180/90 kuralı, normal hesaplama verilerinden üretilerek veritabanı 4.233 kural ile %100 kapsama ulaştırılmıştır.
* **Web Portalı (AjaxController.cs) ile 1:1 Tam Uyumlu 180/90 Kayan Pencere Motoru:**
  - **Çoklu Giriş-Çıkış Otomatik 180G Kuralı:** Kullanıcı "Normal Hesaplama" (`calculateType: 1`) modunda olsa dahi birden fazla sefer girildiğinde (`trips > 1`), web sürümündeki gibi en son çıkıştan geriye doğru 180 günlük (Beyaz Rusya için 365 günlük) takvim penceresi otomatik uygulanır.
  - **Pencere Dışı Seferlerin Sıfırlanması:** 180 gün öncesinde kalmış olan eski çıkışlar web motorunda olduğu gibi `0 gün` olarak hesaba dahil edilmez.
  - **Sefer Başına vs. Dönem İhlali Ayrımı (`Math.Max(singleTripPenalty, totalPeriodPenalty)`):** Tek seferlik kalış aşımı (örn. Rusya 60 gün, Beyaz Rusya 30 gün, standart 90 gün) ve toplam dönem aşımı (90 gün) ayrı ayrı hesaplanarak en yüksek yasal ihlal cezası uygulanır.
  - **Arayüzde 180G Kapsamı ve Pencere Dışı Göstergesi:** Çoklu giriş yapıldığında her satırda toplam gün ve pencereye giren gün `${days} Gün (180G: ${windowStay} G)` veya `${days} Gün (180G Dışı: 0 G)` şeklinde anlık gösterilir.
  - **İkamet Tezkereli ve Türkiye'de Doğan Çocuklar Hesabı:** Web'deki tebliğ/bitiş tarihi ile çıkış tarihi farkı ve doğumdan itibaren kesintisiz ceza standartları mobile 1:1 uyarlandı.
* **Yeni Hudut Kapıları İkonu ve Görsel Kimliği:**
  - Uygulama simgesi ve ana görseli **Uçak (Hava), Gemi (Deniz) ve Araba (Kara)** hudut kapılarını simgeleyen kurumsal polis kalkanı/brövesi ile yenilendi.
  - HD launcher, adaptive ve round ikon setleri tüm ekran yoğunlukları (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi) için güncellendi.
* **Hızlı Kapı Seçimi (Uçak • Gemi • Araba):**
  - **✈️ Hava Hudut Kapıları:** Sabiha Gökçen, İstanbul, Gazipaşa-Alanya, Antalya, Esenboğa, İzmir Adnan Menderes.
  - **🚢 Deniz Hudut Kapıları:** Karaköy / Galataport, Pendik, İzmir, Mersin, Bodrum, Kuşadası Deniz Limanları.
  - **🚗 Kara Hudut Kapıları:** Kapıkule, İpsala, Hamzabeyli, Sarp, Habur, Dilucu, Cilvegözü Kara Hudut Kapıları.
* **Dinamik Kapı Türü Göstergesi:**
  - Üst çubukta (AppBar) ve sol çekmece menüsünde (Drawer) seçili hudut kapısının türüne göre otomatik uçak, gemi veya araba rozeti görüntülenir.
* **EGM Polnet 1:1 Kalibrasyonu:**
  - 180 günlük geriye dönük takvim penceresi kuralı EGM Polnet standardıyla tam uyumlu hale getirildi.
  - "Giriş günü sayılır, çıkış günü sayılmaz" iş kuralı ve münferit sefer kalış süreleri eksiksiz entegre edildi.
* **Kapsamlı Harç ve Ceza Matrisi:**
  - Vize harcı, ikamet harcı, defter bedeli ve idari para cezası (T-Kodları) tek ekranda.
* **Resmi PDF Tebliğ / Tutanak:**
  - İnternet gerekmeksizin Türkçe ve İngilizce dillerinde resmi ceza tebliğ formu ve yazdırma desteği.
* **Genişletilmiş Ülke Veritabanı:**
  - Tüm dünya ülkelerine ait vize muafiyetleri ve harç tarifeleri cihaz üzerinde hazır gelir.