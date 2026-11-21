# EGM HUDUT KAPILARI CEZA VE HARÇ HESAPLAMA SİSTEMİ (CEZAM)
## Yıllık Harç, İdari Ceza ve Özel Katsayılar Güncelleme Rehberi (Admin Brifingi)

**Doküman Kodu:** BRF-2026-ADM-01  
**Tarih:** 22 Kasım 2026  
**Hedef Kitle:** Sistem Yöneticileri (Admin), Şube Müdürleri, Büro Amirleri ve Bilgi İşlem Personeli  
**İlgili Modüller:** `/tgvh`, `/Defter`, `/CezaParametre`, `/AUH`, `/Ajax`

---

## 1. YÖNETİCİ ÖZETİ (EXECUTIVE SUMMARY)

CEZAM (Ceza ve Harç Hesaplama Otomasyonu); 492 sayılı Harçlar Kanunu, 210 sayılı Değerli Kağıtlar Kanunu, 6458 sayılı Yabancılar ve Uluslararası Koruma Kanunu (YUKK) ile Emniyet Genel Müdürlüğü (EGM) Göçmen Kaçakçılığıyla Mücadele ve Hudut Kapıları Daire Başkanlığı'nın yürürlükteki genelgeleri doğrultusunda vize/ikamet ihlali yapan yabancılara uygulanacak harç, defter bedeli ve idari para cezalarını hesaplar.

Bu doküman;
1. Sistemde hesaplanan mali kalemlerin **hukuki dayanaklarını**,
2. Yıllık artışların (YDO, Cumhurbaşkanı Kararları, Resmi Gazete tebliğleri) **matematiksel işleyişini**,
3. **F Grubu (Norveç, Sırbistan vb.) 467,60 TL basamağını** ve **G Grubu (Danimarka, Suriye, Türkmenistan vb.) Kabahatler Kanunu m.32** muafiyet mekanizmasını,
4. **Azerbaycan, Almanya vb. A Grubu ülkelerin standart harç rejimini**,
5. Yeni bir takvim yılına girerken (örn. 2027 yılı başında) sistem yöneticisinin (Admin) **adım adım neler yapması gerektiğini**
kapsamlı bir işletim rehberi olarak sunmaktadır.

---

## 2. MALİ KALEMLER VE HUKUKİ ARTIŞ MEKANİZMASI

Sistem üzerinde hesaplanan temel mali kalemler ve rejimler bulunmaktadır:

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                               CEZAM MALİ PARAMETRE MİMARİSİ                             │
├──────────────────────────┬─────────────────────────────┬───────────────────────────────┤
│ Mali Kalem / Rejim       │ Hukuki Dayanak              │ Artış Belirleme Mekanizması   │
├──────────────────────────┼─────────────────────────────┼───────────────────────────────┤
│ 1. TGVH (Vize Harcı)     │ 492 s. Harçlar Kanunu (6)   │ Harçlar Genel Tebliği (RG)    │
│ 2. Defter Bedeli         │ 210 s. Değerli Kağıtlar K.  │ Değerli Kağıtlar Tebliği (RG) │
│ 3. V-137 İdari Para C.   │ YUKK m.102/1-a & VUK Tebliği│ YDO Oranında Maktu Artış      │
│ 4. F Grubu 9. Gün Kats.  │ EGM Genelgesi 2011/68506    │ POLNET Tavan Harcı İle Orantı │
│ 5. G Grubu Kabahatler C. │ Kabahatler K. m.32 & VUK    │ YDO Oranında Maktu Artış      │
│ 6. A Grubu Standart H.   │ E_AUH / Dolar Endeksli      │ İlk Ay 25$, Sonraki 5$ (USD)  │
└──────────────────────────┴─────────────────────────────┴───────────────────────────────┘
```

### 2.1. Yıllık Artış Takvimi ve Resmi Gazete Süreci
Her yılın son iki ayında devletin mali parametreleri şu kronolojiyle netleşir:

1. **Kasım Ayı Sonu (YDO İlanı):**
   * Hazine ve Maliye Bakanlığı Gelir İdaresi Başkanlığı, Resmi Gazete'de **Vergi Usul Kanunu Genel Tebliği** yayımlayarak o yılın **Yeniden Değerleme Oranını (YDO)** ilan eder (Örn: 2026 yılı için %25,49).
2. **Aralık Ayı Sonu (Cumhurbaşkanı Kararı - Varsa):**
   * Cumhurbaşkanı, Vergi Usul Kanunu ve Harçlar Kanunu uyarınca harçlarda artış oranını YDO'dan farklı belirleme yetkisini kullanabilir (Örn: 2026 yılı vize ve pasaport harçları için artış oranı %18,95 olarak kararlaştırılmıştır).
3. **31 Aralık (Mükerrer Resmi Gazete Tebliğleri):**
   * **Harçlar Kanunu Genel Tebliği (Örn: Seri No: 98):** (6) sayılı Tarifedeki Tek Giriş Vize Harcı (TGVH) ve konsolosluk harçları ilan edilir (2026 yılı TGVH: **9.376,40 TL**).
   * **Muhasebat Genel Müdürlüğü Değerli Kağıtlar Genel Tebliği (Örn: Sıra No: 97):** İkamet izni defter satış bedeli ilan edilir (2026 yılı Defter Bedeli: **964,00 TL**).
4. **EGM POLNET Harç ve Ceza Cetveli:**
   * EGM Göçmen Kaçakçılığı ve Hudut Kapıları Daire Başkanlığı, Resmi Gazete tutarlarını POLNET Hudut sistemine entegre eder ve taşra teşkilatına resmi tamim/cetvel yayımlar.

---

## 3. ÜLKE GRUPLARI VE FORMÜL ANALİZİ

### 3.1. Standart A Grubu Ülkeler (Azerbaycan, Almanya, Avusturya vb.)
* **Kapsam:** Azerbaycan, Almanya, ABD, Rusya, Kazakistan, Özbekistan, Kırgızistan ve 190+ dünya ülkesi.
* **Hukuki Dayanak:** 492 sayılı Harçlar Kanunu (6) sayılı Tarife ve `E_AUH` veri tablosu.
* **Önemli Not (Azerbaycan Rejimi):** Azerbaycan vatandaşları harçtan muaf **değildir**. Standart A Grubu kapsamında değerlendirilirler.
  * İlk 1 ay için: **25 USD** karşılığı TL.
  * Sonraki her ay için: **5 USD** karşılığı TL.
  * Günlük aşım için: **1 USD/gün** (10 güne kadar).
  * Ceza katı: Yetişkinlerde 2 kat ceza uygulanır (`Ceza = Harç * 2`).
  * İlave olarak Defter Bedeli ve Vize Harcı tahakkuk ettirilir.
  * Canlı sistemdeki `E_History` kayıtlarında da Azerbaycan vatandaşlarına 1.409 TL, 2.300 TL, 4.082 TL gibi normal harç ve ceza tahakkukları mevcuttur.

### 3.2. F Grubu Ülkeler ve 467,60 TL Basamağının Hesabı
* **Kapsam:** Norveç, Sırbistan, Fiji, Kuzey Mariana Adaları.
* **Hukuki Dayanak:** EGM'nin 25.03.2011 tarihli ve B.05.1.EGM.0.76.04.02-68506 sayılı Genelgesi.
* **İşleyiş Mantığı:** Bu ülke vatandaşları Türkiye'de vize muafiyeti süresini aştıklarında:
  * **1 - 9 gün arası ihlallerde:** Her gün için kademeli olarak belirlenen günlük basamak katsayısı uygulanır.
  * **10 gün ve üzeri ihlallerde:** Günlük artış durdurulur ve EGM POLNET sisteminde belirlenen **tavan harç tutarı** uygulanır. 2026 yılı için bu tavan tek kat **1.066,00 TL**, çift kat **2.132,00 TL**'dir.
  * **467,60 TL Değeri:** 9. güne gelindiğinde cezanın tam olarak tavan değere ulaşmasını sağlayan son geçiş basamağıdır.
* **2027 Yılı Güncelleme Formülü:**
  $$\text{FGRUBU\_DAY9\_KAT}_{2027} = \text{FGRUBU\_DAY9\_KAT}_{2026} \times (1 + \text{Harç Artış Oranı})$$
  *Veya doğrudan EGM Daire Başkanlığı POLNET Harç Cetvelindeki F Grubu 9. gün / 10. gün satırındaki maktu tutar girilir.*

### 3.3. G Grubu Ülkeler ve Kabahatler Kanunu m.32 İstisnası (Harçtan Muaf Ülkeler)
* **Kapsam:** **Danimarka, Kosova, Çek Cumhuriyeti, İrlanda, Nepal, Sri Lanka, Suriye, Türkmenistan**.
* **Hukuki Dayanak:** EGM'nin 04.06.2013 tarihli ve 41139-5 sayılı Genelgesi.
* **İşleyiş Mantığı:**
  * Bu 8 ülkenin vatandaşları ikamet izni harcından **tamamen muaftır**.
  * İhlal süresi ne kadar olursa olsun (1 gün veya 100 gün), bu şahıslara ikamet harcı veya katlamalı harç tahakkuk ettirilmez (`Harc = 0.00 TL`).
  * Yalnızca **5326 sayılı Kabahatler Kanunu'nun 32. maddesi (Emre Aykırı Davranış)** uyarınca idari para cezası kesilir (2026 yılı 1 kat tutarı: **1.854,00 TL**; yetişkinde 2 katı: **3.708,00 TL**).
  * V-137 süresini (12 ay / 365 gün) aşmışlarsa ayrıca V-137 idari para cezası eklenir.
* **2027 Yılı Güncelleme Formülü:**
  $$\text{KABAHATLER\_M32\_CEZA}_{2027} = \text{KABAHATLER\_M32\_CEZA}_{2026} \times (1 + \text{YDO})$$
  *(Tutar 5326 sayılı Kanun gereği 1 TL'nin küsuratları dikkate alınarak tam sayıya yuvarlanır).*

### 3.4. V-137 İdari Para Cezası (20.605,00 TL)
* **Kapsam:** İkamet veya vize süresini 12 aydan (365 gün) fazla ihlal eden tüm yabancılar.
* **Hukuki Dayanak:** 6458 sayılı YUKK m. 102/1-a ve VUK Genel Tebliği.
* **2027 Yılı Güncelleme Formülü:**
  $$\text{V137\_IDARI\_CEZA}_{2027} = \text{V137\_IDARI\_CEZA}_{2026} \times (1 + \text{YDO})$$
  *(2026 tutarı 20.605,00 TL'dir. 2027 YDO oranı %20 olursa: $20.605 \times 1,20 = 24.726,00 \text{ TL}$ olacaktır).*

---

## 4. ADMİN İÇİN YILBAŞI GEÇİŞ REHBERİ (ADIM ADIM CHECKLIST)

Yeni bir takvim yılına girildiğinde sistem yöneticisi (Admin) veritabanına SQL sorgusu yazmak veya kaynak kod değiştirmek **zorunda değildir**. Tüm güncellemeler web arayüzünden güvenli bir şekilde yapılır.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                         YILBAŞI GEÇİŞ CHECKLIST'İ (SIRA İLE YAPINIZ)                   │
├────┬─────────────────────────────┬─────────────────────────────┬──────────────────────┤
│ No │ İşlem Adımı                 │ Kullanılacak Ekran          │ Beklenen Girdi       │
├────┼─────────────────────────────┼─────────────────────────────┼──────────────────────┤
│ 1  │ TGVH Güncelleme             │ /tgvh                       │ Yeni Yıl ve Vize H.  │
│ 2  │ Defter Bedeli Güncelleme    │ /Defter                     │ Yeni Defter Bedeli   │
│ 3  │ V-137 Ceza Güncelleme       │ /CezaParametre              │ Yeni Maktu Ceza      │
│ 4  │ F Grubu 9. Gün Katsayısı    │ /CezaParametre              │ Yeni Günlük Basamak  │
│ 5  │ Kabahatler m.32 Cezası      │ /CezaParametre              │ Yeni Kabahatler C.   │
│ 6  │ Ülke Genelge Kontrolü       │ /CezaParametre (Sekme 2)    │ Ülke Ekleme/Çıkarma  │
│ 7  │ Doğrulama ve Test           │ /Home/Index & /Ajax         │ 4 Kritik Test        │
└────┴─────────────────────────────┴─────────────────────────────┴──────────────────────┘
```

### Adım 1: Resmi Tebliğleri Temin Ediniz (25 - 31 Aralık)
1. Gelir İdaresi Başkanlığı / Resmi Gazete web sitesinden:
   * **Harçlar Kanunu Genel Tebliği** (TGVH tutarı için)
   * **Değerli Kağıtlar Genel Tebliği** (Defter bedeli için)
   * **Vergi Usul Kanunu Genel Tebliği** (Yeniden Değerleme Oranı için)
2. EGM Göçmen Kaçakçılığı ve Hudut Kapıları Daire Başkanlığı POLNET Harç ve Ceza Cetveli resmi yazısını temin ediniz.

### Adım 2: Tek Giriş Vize Harcını (TGVH) Ekleyiniz
* **Ekran:** Tarayıcınızda `http://[SUNUCU_IP]/tgvh` adresine gidiniz (veya sol menüden **Harçlar -> TGVH** seçiniz).
* **İşlem:** 
  1. Üst kısımdaki **"Yeni TGVH Ekle"** formuna geliniz.
  2. `Yıl`: `2027` (İlgili takvim yılı).
  3. `Tutar`: Resmi Gazete'de yayımlanan tutar (Örn: `11.250,00`).
  4. **"Kaydet"** butonuna basınız.

### Adım 3: İkamet İzni Defter Bedelini Güncelleyiniz
* **Ekran:** `http://[SUNUCU_IP]/Defter` adresine gidiniz (veya menüden **Harçlar -> Defter Bedeli** seçiniz).
* **İşlem:**
  1. `Defter Bedeli (TL)` kutucuğuna Resmi Gazete'de yayımlanan yeni bedeli giriniz (Örn: `1.150,00`).
  2. **"Güncelle"** butonuna basınız.

### Adım 4: İdari Para Cezalarını ve Katsayıları Güncelleyiniz
* **Ekran:** `http://[SUNUCU_IP]/CezaParametre` adresine gidiniz (veya sol menüden **Sistem -> Ceza Parametreleri** seçiniz).
* **1. Sekme ("İdari Para Cezaları & Özel Basamaklar"):**
  1. **V-137 İdari Para Cezası (`V137_IDARI_CEZA`):**
     * Yeni YDO oranına göre hesaplanan tutarı giriniz (Örn: `24726.00`).
     * Sağındaki yeşil **"Kaydet"** butonuna basınız.
  2. **F Grubu 9. Gün Katsayısı (`FGRUBU_DAY9_KAT`):**
     * Yeni harç oranına göre hesaplanan tutarı giriniz (Örn: `561.12`).
     * Sağındaki yeşil **"Kaydet"** butonuna basınız.
  3. **Kabahatler Kanunu m.32 Cezası (`KABAHATLER_M32_CEZA`):**
     * Yeni YDO oranına göre hesaplanan tutarı giriniz (Örn: `2224.00`).
     * Sağındaki yeşil **"Kaydet"** butonuna basınız.

### Adım 5: Genelge Ülke Sınıflandırmalarını Kontrol Ediniz
* **Ekran:** Yine `/CezaParametre` sayfasında **"2. Genelge Ülke Sınıflandırmaları"** sekmesine tıklayınız.
* **Kontrol:**
  * EGM yeni bir genelge yayımlayarak F Grubuna yeni bir ülke eklediyse veya G Grubuna (muafiyet grubuna) yeni bir ülke dahil edildiyse ilgili kutucuğa ülke adını aralarına virgül koyarak ekleyiniz.
  * **"Ülke Listesini Güncelle"** butonuna basınız.

---

## 5. DOĞRULAMA VE TEST ADIMLARI (PİLOT DOĞRULAMA)

Güncellemeleri yaptıktan sonra sistemin canlıda doğru hesaplama yaptığını teyit etmek için ana sayfadan (`/Home/Index`) 4 adet test senaryosu çalıştırınız:

### Test Senaryosu 1: Standart A Grubu Ülke (Örn: Azerbaycan veya Almanya - 15 Gün)
* **Veriler:** Uyruk: Azerbaycan, İhlal Süresi: 15 Gün.
* **Beklenen Sonuç:**
  * İkamet Harcı: Standart 25 USD tabanına göre TL karşılığı + katlamalı ceza.
  * Defter Bedeli: Yeni tanımlanan defter bedeli.
  * Vize Harcı: Tek Giriş Vize Harcı (TGVH).
  * Sonuç: Harçtan muaf tutulmamalı, tam yasal tarife uygulanmalıdır.

### Test Senaryosu 2: F Grubu Ülke Kademeli Artış (Örn: Norveç - 3 Gün ve 12 Gün)
* **Veriler:** Uyruk: Norveç, İhlal Süresi: 3 Gün.
* **Beklenen Sonuç:**
  * Harç: 1-9 gün arasında `3 * FGRUBU_DAY9_KAT` formülü ile orantılı artış göstermelidir.
  * 10 gün seçildiğinde POLNET tavanına kilitlenmelidir (2026 için Tek Kat 1.066 TL, Çift Kat 2.132 TL).

### Test Senaryosu 3: G Grubu Muafiyet (Örn: Suriye veya Türkmenistan - 20 Gün)
* **Veriler:** Uyruk: Türkmenistan (veya Suriye, Danimarka), İhlal Süresi: 20 Gün.
* **Beklenen Sonuç:**
  * İkamet Harcı: **0,00 TL** (Harçtan muafiyet uyarısı görünmelidir).
  * Ceza: Yalnızca **Kabahatler Kanunu m.32 İdari Para Cezası** (1 kat / 2 kat).

### Test Senaryosu 4: V-137 Kritik İhlal (400 Gün İhlal)
* **Veriler:** Herhangi bir ülke, İhlal Süresi: 400 Gün (> 365 gün).
* **Beklenen Sonuç:**
  * Ekranda kırmızı renkli **V-137 İdari Para Cezası** ve **Çıkış Tahdit Uyarısı** belirmelidir.
  * Ceza tutarına yeni `V137_IDARI_CEZA` bedeli eklenmelidir.

---

## 6. TEKNİK MİMARİ VE ACİL DURUM PROSEDÜRLERİ

### 6.1. Veritabanı Mimarisi (`dbo.CezaParametre`)
Sistem parametreleri `dbo.CezaParametre` tablosunda anahtar-değer (Key-Value) yapısında tutulur:
* `ParamKey (NVARCHAR(50))`: Parametre sistem kodu (Örn: `V137_IDARI_CEZA`, `FGRUBU_DAY9_KAT`, `KABAHATLER_M32_CEZA`, `ULKE_GGRUBU`).
* `ParamValue (NVARCHAR(500))`: Parametre değeri.
* `Aciklama (NVARCHAR(500))`: Parametrenin Türkçe açıklaması ve genelge maddesi.
* `GuncellemeTarihi (DATETIME)`: Son değişiklik zaman damgası.

### 6.2. Çift Katmanlı Güvenlik (Fallback Koruması)
Herhangi bir nedenle veritabanı bağlantısı kesilirse veya parametre tablosu hasar görürse, `CezaParametreService.cs` servisindeki statik varsayılanlar (Default Fallbacks) devreye girer. Sistem asla hata verip kapanmaz (Zero Downtime); en kötü durumda yasal varsayılan değerlerle hesaplamayı sürdürür.

### 6.3. Veritabanı Yedeği ve Canlıya Taşıma
Canlı sunucuya (Production) geçişte veya veritabanı sıfırlanmasında proje kökündeki SQL betiği çalıştırılabilir:
* **Dosya Yolu:** `sql/14_CREATE_CEZA_PARAMETRE_VE_GENELGE_SINIFLANDIRMA.sql`
* Bu betik tabloyu otomatik oluşturur, indeksleri tanımlar ve resmi mevzuat verilerini tohumlar (seed eder).

---

## 7. YÖNETİCİ İLETİŞİM VE MEVZUAT DESTEK KANALLARI

Sistem güncellemelerinde veya genelge yorumlarında tereddüde düşüldüğünde irtibat kurulacak birimler:
1. **Mevzuat ve Yorum:** EGM Göçmen Kaçakçılığıyla Mücadele ve Hudut Kapıları Daire Başkanlığı - Hudut Kapıları Şube Müdürlüğü.
2. **Yazılım ve Altyapı:** Bilgi Teknolojileri ve Haberleşme Şube Müdürlüğü / CEZAM Sistem Yöneticisi.
3. **Resmi Belgeler Arşivi:** Proje içerisindeki `gzpegm/files/Resmi_Mevzuat_Arsivi_Son_10_Yil/` dizininde 2016-2026 yılları arasındaki tüm resmi tebliğler ve genelgeler kayıtlıdır.

---
*Bu brifing dokümanı EGM Hudut Kapıları personeli ve sistem yöneticileri için resmi standart işletim prosedürü (SOP) olarak hazırlanmıştır.*
