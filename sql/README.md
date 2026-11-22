# CEZAM Veritabanı Kurulum ve Senkronizasyon Kılavuzu

Bu dizin, **CEZAM Vize İhlal ve Ceza Hesaplama Sistemi** veritabanının sıfırdan kurulması, başka bir bilgisayara/sunucuya aktarılması ve **76 (Yedek) ile 75 (Ana) sunucuları arasında veri senkronizasyonu** için en güncel SQL betiklerini içerir.

---

## 🚀 Hızlı Kurulum (Tek Adımda)
Tüm veritabanı şemasını, tabloları, ilişkileri ve başlangıç verilerini tek seferde yüklemek için:
- **`CEZA_FULL_DATABASE_SETUP.sql`** dosyasını SQL Server Management Studio (SSMS) veya `sqlcmd` ile çalıştırmanız yeterlidir:
  ```bash
  sqlcmd -S (localdb)\MSSQLLocalDB -i CEZA_FULL_DATABASE_SETUP.sql
  ```

---

## 📁 Modüler Kurulum Dosyaları (Sırasıyla Çalıştırınız)

Eğer şemayı ve verileri adım adım yüklemek isterseniz aşağıdaki sıralamayı takip ediniz:

| Sıra | Dosya Adı | Açıklama |
| :---: | :--- | :--- |
| **1** | `01_CREATE_ALL_TABLES_AND_CONSTRAINTS.sql` | `CEZA` veritabanını, 41 tablonun tamamını, birincil anahtarları (PK), indeksleri ve yabancı anahtarları (FK) oluşturur. |
| **2** | `02_SEED_CORE_LOOKUP_DATA.sql` | Sınır kapıları (`E_Border`), harç/ceza tarifeleri (`E_AUH`), tahdit kodları (`E_TKOD`), defter/kur/form parametreleri ve yetkili kullanıcıları (`E_User`) yükler. |
| **3** | `03_SEED_COUNTRY_VISA_REGIME.sql` | Tüm ülkelerin pasaport ve vize muafiyet/süre tanımlarını (`E_UVR`, 2.674 kayıt) yükler. |
| **4** | `04_SEED_COURSES_AND_EXAMS.sql` | Eğitim ve sınav modülüne ait kursları, içerikleri, sınavları ve soru bankasını (`Courses`, `Exam`, `Question`, `QuestionOption`) yükler. |
| **13** | `13_CREATE_GENELGE_GIZLI_VE_TALEP_TABLES.sql` | Gizli genelgeler (`E_GenelgeGizli`) ve personel erişim izin talep tablosunu (`E_GenelgeTalep`) oluşturur. |
| **14** | `14_CREATE_CEZA_PARAMETRE_VE_GENELGE_SINIFLANDIRMA.sql` | Dinamik ceza, basamak ve ülke sınıflandırması tablosunu (`CezaParametre`) oluşturur. |
| **15** | `15_CREATE_E_DUYURU_TABLE.sql` | Operasyonel duyuru paneli tablosunu (`E_Duyuru`) oluşturur ve indeksler. |
| **TOPLU** | `CANLI_ORTAM_TOPLU_GUNCELLEME_2026.sql` | Canlı ortama son eklenen tüm modülleri (`E_Duyuru`, `E_GenelgeGizli`, `E_GenelgeTalep`, `CezaParametre`) tek tıkla ve güvenle yükler. |

---

## 🔄 76 (Yedek) -> 75 (Ana) Sunucu Senkronizasyon Betikleri

75 sunucusu çevrimdışıyken personelin 76 (Yedek) sunucu üzerinde oluşturduğu tüm kayıtları 75'e aktarmak için:

| Dosya Adı | Açıklama | Kullanım Yeri |
| :--- | :--- | :--- |
| **`SYNC_76_TO_75_BACKUP_TO_PRIMARY.sql`** | 76'daki `E_User`, `E_IsK`, `E_History`, `TahditFormLog`, `E_Sartli`, `E_Inad`, `E_Dilekce` kayıtlarını mükerrerlik olmadan 75'e aktarır. | 75 Sunucusunda SSMS üzerinden tek tıkla çalıştırılır. |
| **`SETUP_AUTOMATIC_SYNC_AGENT_JOB.sql`** | SQL Server Agent servisi üzerinde otomatik zamanlanmış görev (`Job`) oluşturur. Her gece 03:00'te verileri otomatik eşitler. | 75 Sunucusunda SQL Server Agent üzerinde 1 kez çalıştırılır. |

---

## ⚙️ Gereksinimler & Güvenlik
- **Veritabanı Motoru:** Microsoft SQL Server 2016+ veya SQL Server Express / LocalDB
- **Yetki:** `sysadmin` veya `dbcreator` yetkisi.
- **İdempotentlik:** Tüm tablolar ve senkronizasyon betikleri `NOT EXISTS` kontrollerine sahip olup, tekrar çalıştırıldığında asla veri çoklamaz (mükerrer kayıt yapmaz).
