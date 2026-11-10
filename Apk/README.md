# CEZAM - Vize ve İkamet İhlali Ceza Hesaplayıcı (Android Mobil APK)

Bu klasör, Pasaport Kontrol ve Sınır Kapıları için geliştirilen **CEZAM Vize ve İkamet İhlali Ceza Hesaplayıcı** mobil uygulamasının doğrudan kurulabilir güncel Android sürümünü (`cezam-calculator.apk`) içermektedir.

---

### 📦 Dosya Bilgileri
* **Dosya Adı:** `cezam-calculator.apk`
* **Sürüm:** `0.3.0 (Build 3)`
* **Boyut:** ~61.4 MB
* **Desteklenen Platform:** Android 7.0 (API 24) ve üzeri
* **Çalışma Modu:** %100 Çevrimdışı (İnternetsiz / Yerel Hesaplama Motoru)
* **Uygulama Teması:** Hudut Kapıları (✈️ Uçak • 🚢 Gemi • 🚗 Araba)
* **API / Senkronizasyon Desteği:** Vizeİhlal API ile merkezi veri güncelleme opsiyonu

---

### 🚀 Kurulum Talimatları
1. **İndirme:** `cezam-calculator.apk` dosyasını Android telefonunuza veya tabletinize indirin.
2. **Güvenlik İzni:** Android ayarlarından tarayıcınıza veya dosya yöneticinize *"Bilinmeyen kaynaklardan uygulama yükle"* izni verin.
3. **Yükleme:** İndirilen APK dosyasına dokunarak kurulumu tamamlayın.
4. **Kullanım:** Uygulamayı açtığınızda internet veya sunucu bağlantısına ihtiyaç duymaksızın doğrudan tüm vize ve ikamet ihlali hesaplamalarını yapabilirsiniz.

---

### 🌟 Temel ve Güncel Özellikler (v0.3.0)
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
* **180G Kapsamı Göstergesi:**
  - Sefer satırlarında hem seferin kendi toplam kalış günü (örn. `80 Gün`) hem de 180 günlük pencereye giren süre (örn. `180G: 19`) eşzamanlı gösterilir.
* **Kapsamlı Harç ve Ceza Matrisi:**
  - Vize harcı, ikamet harcı, defter bedeli ve idari para cezası (T-Kodları) tek ekranda.
* **Resmi PDF Tebliğ / Tutanak:**
  - İnternet gerekmeksizin Türkçe ve İngilizce dillerinde resmi ceza tebliğ formu ve yazdırma desteği.
* **Genişletilmiş Ülke Veritabanı:**
  - Tüm dünya ülkelerine ait vize muafiyetleri ve harç tarifeleri cihaz üzerinde hazır gelir.