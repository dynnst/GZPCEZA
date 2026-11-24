using gzpegm.Models;
using System;
using System.Collections.Generic;
using System.Linq;

namespace gzpegm.Services
{
    public class TahditSozlukService
    {
        private static readonly List<TahditSozlukItem> _builtInCodes = new List<TahditSozlukItem>
        {
            // === Ç KODLARI (GİRİŞ YASAKLARI) ===
            new TahditSozlukItem {
                Kod = "Ç-101",
                Baslik = "3 Ay Süreli Giriş Yasağı (Vize / İkamet İhlali)",
                Kategori = "Ç Kodları (Giriş Yasağı)",
                Sure = "3 Ay",
                Aciklama = "Vize veya ikamet süresini ihlal edip sınır kapılarında çıkış yaparken idari para cezasını ödemeden terk edenler ile 3 aya kadar ihlali olup ceza ödemeyen yabancılara konulur.",
                GirisIslem = "Girişine izin verilmez. Dış temsilciliklerimizden özel meşruhatlı vize alması şarttır.",
                CikisIslem = "Para cezası tahsil edilir, tahsil edilemezse tahdit şerhi sisteme işlenir.",
                OnemDerecesi = "Standart"
            },
            new TahditSozlukItem {
                Kod = "Ç-102",
                Baslik = "6 Ay Süreli Giriş Yasağı (3-6 Ay Arası İhlal)",
                Kategori = "Ç Kodları (Giriş Yasağı)",
                Sure = "6 Ay",
                Aciklama = "Vize veya ikamet süresini 3 ay ile 6 ay arasında ihlal edip çıkışta para cezasını ödemeyen yabancılara uygulanır.",
                GirisIslem = "Girişine izin verilmez. Dış temsilciliklerimizden vize alması gerekir.",
                CikisIslem = "Para cezası tahsil edilir veya tahdit devam eder.",
                OnemDerecesi = "Standart"
            },
            new TahditSozlukItem {
                Kod = "Ç-103",
                Baslik = "1 Yıl Süreli Giriş Yasağı (6 Ay - 1 Yıl İhlal)",
                Kategori = "Ç Kodları (Giriş Yasağı)",
                Sure = "1 Yıl",
                Aciklama = "Yasal kalış süresini 6 ay ile 1 yıl arasında ihlal eden ve para cezasını ödemeden ülkeden ayrılan yabancılara konur.",
                GirisIslem = "Girişine izin verilmez. 1 yıl süreyle ülke sınırlarına giriş yasağı vardır.",
                CikisIslem = "Para cezası tahakkuku ve sistem bildirimi yapılır.",
                OnemDerecesi = "Standart"
            },
            new TahditSozlukItem {
                Kod = "Ç-104",
                Baslik = "2 Yıl Süreli Giriş Yasağı (1 - 2 Yıl İhlal)",
                Kategori = "Ç Kodları (Giriş Yasağı)",
                Sure = "2 Yıl",
                Aciklama = "Yasal kalış süresini 1 yıl ile 2 yıl arasında ihlal ederek ülkeden ayrılan yabancılara tesis edilir.",
                GirisIslem = "Girişine izin verilmez. 2 yıl süreyle Türkiye'ye giremez.",
                CikisIslem = "İdari yaptırım kararı uygulanır.",
                OnemDerecesi = "Yuksek"
            },
            new TahditSozlukItem {
                Kod = "Ç-105",
                Baslik = "5 Yıl Süreli Giriş Yasağı (2 Yıldan Fazla İhlal)",
                Kategori = "Ç Kodları (Giriş Yasağı)",
                Sure = "5 Yıl",
                Aciklama = "Yasal kalış süresini 2 yıldan daha uzun süre ihlal edip ayrılan yabancılara 5 yıl süreli giriş yasağı konulur.",
                GirisIslem = "Girişine izin verilmez. 5 yıl süreyle ülkeye girişi engellenir.",
                CikisIslem = "Para cezası tahakkuk ettirilir.",
                OnemDerecesi = "Yuksek"
            },
            new TahditSozlukItem {
                Kod = "Ç-113",
                Baslik = "Yasa Dışı Giriş-Çıkış Yapanlar",
                Kategori = "Ç Kodları (Giriş Yasağı)",
                Sure = "2 Yıl",
                Aciklama = "Türkiye sınırlarından yasa dışı (kaçak) yollarla giriş veya çıkış yaptığı tespit edilen yabancılara konulur.",
                GirisIslem = "Girişi kesinlikle engellenir ve adli/idari birimlere sevk edilir.",
                CikisIslem = "Adli tahkikat evrakları kontrol edilir.",
                OnemDerecesi = "Yuksek"
            },
            new TahditSozlukItem {
                Kod = "Ç-114",
                Baslik = "Haklarında Adli İşlem Yapılan Yabancılar",
                Kategori = "Ç Kodları (Giriş Yasağı)",
                Sure = "1 Yıl",
                Aciklama = "Türkiye'de bulundukları sürede herhangi bir suçtan adli soruşturma veya kovuşturmaya tabi tutulan yabancılara konulur.",
                GirisIslem = "Girişine izin verilmez.",
                CikisIslem = "Adli tahdit / yurt dışı çıkış yasağı var mı sorgulanır.",
                OnemDerecesi = "Yuksek"
            },
            new TahditSozlukItem {
                Kod = "Ç-115",
                Baslik = "Ceza İnfaz Kurumundan Tahliye Olanlar",
                Kategori = "Ç Kodları (Giriş Yasağı)",
                Sure = "1 Yıl / Değişken",
                Aciklama = "Cezaevinden tahliye edilerek sınır dışı (deport) edilen yabancılara uygulanır.",
                GirisIslem = "Girişine izin verilmez.",
                CikisIslem = "Tahliye ve deport belgeleri kontrol edilir.",
                OnemDerecesi = "Yuksek"
            },
            new TahditSozlukItem {
                Kod = "Ç-116",
                Baslik = "Genel Ahlak ve Kamu Sağlığı Sakıncası",
                Kategori = "Ç Kodları (Giriş Yasağı)",
                Sure = "Süresiz / İdarece Belirlenen",
                Aciklama = "Genel ahlaka aykırı davranışları veya kamu sağlığını tehdit eden durumları tespit edilen yabancılara konulur.",
                GirisIslem = "Girişine izin verilmez.",
                CikisIslem = "Normal çıkış işlemi uygulanır.",
                OnemDerecesi = "Yuksek"
            },
            new TahditSozlukItem {
                Kod = "Ç-117",
                Baslik = "Kaçak Çalışan Yabancılar",
                Kategori = "Ç Kodları (Giriş Yasağı)",
                Sure = "1 Yıl",
                Aciklama = "Çalışma ve Sosyal Güvenlik Bakanlığı izni olmaksızın izinsiz/kaçak çalıştığı tespit edilen yabancılara konur.",
                GirisIslem = "Girişine izin verilmez.",
                CikisIslem = "Kaçak çalışma idari para cezası sorgulanır.",
                OnemDerecesi = "Standart"
            },
            new TahditSozlukItem {
                Kod = "Ç-118",
                Baslik = "Bulaşıcı Hastalık Taşıyan Yabancılar",
                Kategori = "Ç Kodları (Giriş Yasağı)",
                Sure = "Tedavi Edilene Kadar",
                Aciklama = "Kamu sağlığını ciddi boyutta tehdit eden bulaşıcı hastalık (HIV, tüberküloz, vb.) taşıdığı belirlenen yabancılar.",
                GirisIslem = "Sağlık denetleme merkezi koordinasyonuyla giriş verilmez.",
                CikisIslem = "Tedbirli çıkış sağlanır.",
                OnemDerecesi = "Yuksek"
            },
            new TahditSozlukItem {
                Kod = "Ç-119",
                Baslik = "Kaçak Çalışma Cezasını Ödemeyenler",
                Kategori = "Ç Kodları (Giriş Yasağı)",
                Sure = "Ödenene Kadar",
                Aciklama = "Kaçak çalışma nedeniyle uygulanan idari para cezasını ödemeden çıkış yapan yabancılara tahsis edilir.",
                GirisIslem = "Cezayı ödemeden ülkeye girişine izin verilmez.",
                CikisIslem = "Ceza tahsilatı kontrol edilir.",
                OnemDerecesi = "Standart"
            },
            new TahditSozlukItem {
                Kod = "Ç-120",
                Baslik = "Vize / İkamet İhlal Cezasından Doğan Yasak",
                Kategori = "Ç Kodları (Giriş Yasağı)",
                Sure = "Ceza Ödenene Kadar",
                Aciklama = "Vize veya ikamet ihlali nedeniyle tebliğ edilen para cezasını ödemeyen yabancılar hakkında konulan koddur.",
                GirisIslem = "İhlal cezası hudut kapısında vezneye ödenmedikçe giriş yapılamaz.",
                CikisIslem = "Tebligat ve ceza tahsili.",
                OnemDerecesi = "Standart"
            },
            new TahditSozlukItem {
                Kod = "Ç-135",
                Baslik = "YUKK İdari Para Cezası Uygulananlar",
                Kategori = "Ç Kodları (Giriş Yasağı)",
                Sure = "Ceza Ödenene Kadar",
                Aciklama = "6458 sayılı Kanun kapsamında idari para cezası kesilen yabancıların kayıt kodudur.",
                GirisIslem = "Ceza makbuzu ve sistem kontrolü yapılır.",
                CikisIslem = "Tahsilat yapılır.",
                OnemDerecesi = "Standart"
            },
            new TahditSozlukItem {
                Kod = "Ç-136",
                Baslik = "Sınır Dışı Seyahat Masraflarını Ödemeyenler",
                Kategori = "Ç Kodları (Giriş Yasağı)",
                Sure = "Masraf Ödenene Kadar",
                Aciklama = "Kamu bütçesinden karşılanan sınır dışı (deport) uçak/seyahat masraflarını devlete geri ödemeyen yabancılara konulur.",
                GirisIslem = "Seyahat masrafı Maliye veznesine yatırılmadıkça giriş verilmez.",
                CikisIslem = "Normal çıkış.",
                OnemDerecesi = "Standart"
            },
            new TahditSozlukItem {
                Kod = "Ç-137",
                Baslik = "Terke Davet Edilip Süresinde Çıkmayanlar",
                Kategori = "Ç Kodları (Giriş Yasağı)",
                Sure = "İdarece Belirlenen",
                Aciklama = "Kendisine Türkiye'yi terk etmesi için tanınan yasal süre (terke davet) içerisinde çıkış yapmayan yabancılar.",
                GirisIslem = "Girişine izin verilmez.",
                CikisIslem = "İhlal cezası uygulanarak çıkışı sağlanır.",
                OnemDerecesi = "Yuksek"
            },
            new TahditSozlukItem {
                Kod = "Ç-138",
                Baslik = "INAD Yolcu (Kabul Edilmeyen Yolcu)",
                Kategori = "Ç Kodları (Giriş Yasağı)",
                Sure = "Geri Gönderilene Kadar",
                Aciklama = "Hudut kapısına gelip Türkiye'ye girişi uygun görülmeyerek reddedilen (INAD) yabancılara işlenen kod.",
                GirisIslem = "Giriş reddedilir, havayolu şirketi refakatiyle geldiği ülkeye iade edilir.",
                CikisIslem = "İnad bildirim formu tanzim edilir.",
                OnemDerecesi = "Yuksek"
            },
            new TahditSozlukItem {
                Kod = "Ç-141",
                Baslik = "Bakanlık İznine Tabi Giriş (Milli Güvenlik)",
                Kategori = "Ç Kodları (Giriş Yasağı)",
                Sure = "Bakanlık İzni",
                Aciklama = "Milli güvenlik aleyhine faaliyet veya uluslararası sakıncalı eylemler sebebiyle girişi İçişleri Bakanlığı iznine tabi tutulan şahıslar.",
                GirisIslem = "Bakanlık açık onayı yoksa kesinlikle giriş verilmez, amire bildirilir.",
                CikisIslem = "Derhal nöbetçi amire ve ilgili büroya bilgi verilir.",
                OnemDerecesi = "Kritik"
            },
            new TahditSozlukItem {
                Kod = "Ç-149",
                Baslik = "Kamu Güvenliği Açısından Sakıncalı Şahıslar",
                Kategori = "Ç Kodları (Giriş Yasağı)",
                Sure = "Süresiz / İdari Karar",
                Aciklama = "Kamu düzeni veya güvenliği yönünden Türkiye'ye girmesi sakıncalı görülen yabancılar.",
                GirisIslem = "Girişi engellenir, pasaport şube/terör birimine bilgi verilir.",
                CikisIslem = "İlgili birimle koordine kurulur.",
                OnemDerecesi = "Kritik"
            },
            new TahditSozlukItem {
                Kod = "Ç-150",
                Baslik = "Sahte Belge Kullanan Yabancılar",
                Kategori = "Ç Kodları (Giriş Yasağı)",
                Sure = "Adli ve İdari Süre",
                Aciklama = "Pasaport, vize, oturma izni veya hudut damgasında tahrifat veya sahtecilik yapan yabancılar.",
                GirisIslem = "Belgeye el konulur, adli işlem için nöbetçi savcıya bildirilir.",
                CikisIslem = "Sahte belge muhafazaya alınır, adli işlem başlatılır.",
                OnemDerecesi = "Kritik"
            },
            new TahditSozlukItem {
                Kod = "Ç-151",
                Baslik = "Göçmen Kaçakçılığı / İnsan Ticareti Şüphesi",
                Kategori = "Ç Kodları (Giriş Yasağı)",
                Sure = "Adli Tahkikat Süresi",
                Aciklama = "Göçmen kaçakçılığı veya insan ticareti suçlarıyla irtibatlı olduğu değerlendirilen yabancılar.",
                GirisIslem = "Girişine izin verilmez, KOM/Göçmen Kaçakçılığı birimine sevk edilir.",
                CikisIslem = "Kolluk birimleriyle derhal koordine kurulur.",
                OnemDerecesi = "Kritik"
            },

            // === G KODLARI (GENEL GÜVENLİK VE TERÖR) ===
            new TahditSozlukItem {
                Kod = "G-26",
                Baslik = "Yasa Dışı Örgüt Faaliyetleri Şüphesi",
                Kategori = "G Kodları (Genel Güvenlik)",
                Sure = "Süresiz / Tahkikat",
                Aciklama = "Silahlı terör örgütleri veya yasa dışı organize suç örgütleriyle bağlantılı şüpheli yabancılar.",
                GirisIslem = "Derhal nöbetçi amire haber verilir, TEM şube koordinesi sağlanır.",
                CikisIslem = "TEM ve İstihbarat birimiyle teyit alınmadan çıkış yapılmaz.",
                OnemDerecesi = "Kritik"
            },
            new TahditSozlukItem {
                Kod = "G-34",
                Baslik = "Nitelikli Dolandırıcılık ve Sahtecilik",
                Kategori = "G Kodları (Genel Güvenlik)",
                Sure = "İdari / Adli",
                Aciklama = "Uluslararası mali suçlar, sahtecilik ve nitelikli dolandırıcılık şüphelileri.",
                GirisIslem = "Girişine izin verilmez, ilgili şube bilgilendirilir.",
                CikisIslem = "Adli arama kaydı kontrol edilir.",
                OnemDerecesi = "Yuksek"
            },
            new TahditSozlukItem {
                Kod = "G-42",
                Baslik = "Uyuşturucu Madde Kaçakçılığı",
                Kategori = "G Kodları (Genel Güvenlik)",
                Sure = "Süresiz / İdare",
                Aciklama = "Uluslararası uyuşturucu ticareti, sevkiyatı veya kullanımıyla irtibatlı şahıslar.",
                GirisIslem = "Narkotik ve Gümrük Muhafaza ile ortak detaylı arama yapılır, girişi engellenir.",
                CikisIslem = "Narkotik birimine bilgi verilir.",
                OnemDerecesi = "Kritik"
            },
            new TahditSozlukItem {
                Kod = "G-48",
                Baslik = "Fuhşa Aracılık ve İnsan Ticareti",
                Kategori = "G Kodları (Genel Güvenlik)",
                Sure = "Süresiz / İdari",
                Aciklama = "Fuhşa yer temini, aracılık veya insan ticareti mağduru/faili olduğu tespit edilenler.",
                GirisIslem = "Girişine kesinlikle izin verilmez.",
                CikisIslem = "İşlem kontrol edilir.",
                OnemDerecesi = "Yuksek"
            },
            new TahditSozlukItem {
                Kod = "G-78",
                Baslik = "Bulaşıcı Hastalık Nedeniyle Giriş Yasağı",
                Kategori = "G Kodları (Genel Güvenlik)",
                Sure = "Süresiz",
                Aciklama = "Tehlikeli bulaşıcı hastalık nedeniyle süresiz giriş yasağı uygulanan yabancılar.",
                GirisIslem = "Sağlık personeli nezaretinde girişi engellenir.",
                CikisIslem = "Normal çıkış.",
                OnemDerecesi = "Yuksek"
            },
            new TahditSozlukItem {
                Kod = "G-82",
                Baslik = "Milli Güvenlik Aleyhine Faaliyet (İstihbari)",
                Kategori = "G Kodları (Genel Güvenlik)",
                Sure = "Süresiz",
                Aciklama = "Milli güvenliğe aykırı casusluk, istihbari veya terör faaliyetleri şüphesi.",
                GirisIslem = "Kırmızı alarm; derhal amir ve istihbarat birimiyle temas kurulur.",
                CikisIslem = "Kontrollü işlem yapılır, amir bilgilendirilir.",
                OnemDerecesi = "Kritik"
            },
            new TahditSozlukItem {
                Kod = "G-87",
                Baslik = "Genel Güvenlik Açısından Tehlike Arz Edenler",
                Kategori = "G Kodları (Genel Güvenlik)",
                Sure = "Süresiz / Bakanlık",
                Aciklama = "Genel güvenlik, terörizm veya kamu düzeni açısından yüksek risk oluşturan şahıslar.",
                GirisIslem = "Giriş kesinlikle verilmez, protokol uygulanır.",
                CikisIslem = "Birimlerle koordine edilir.",
                OnemDerecesi = "Kritik"
            },

            // === V KODLARI (VİZE VE İKAMET İŞLEMLERİ) ===
            new TahditSozlukItem {
                Kod = "V-68",
                Baslik = "Bakanlık İznine Tabi İkamet İzni",
                Kategori = "V Kodları (Vize / İkamet)",
                Sure = "Bakanlık İzni",
                Aciklama = "İkamet izni verilmesi Göç İdaresi Başkanlığı / Bakanlık onayına tabi olan yabancılar.",
                GirisIslem = "Vizesi kontrol edilir, il göç müracaatına yönlendirilir.",
                CikisIslem = "Normal çıkış.",
                OnemDerecesi = "Standart"
            },
            new TahditSozlukItem {
                Kod = "V-69",
                Baslik = "İkamet İzni İptal Edilenler (5 Yıl Yasak)",
                Kategori = "V Kodları (Vize / İkamet)",
                Sure = "5 Yıl",
                Aciklama = "Sahte evrak, sahte adres veya şartları kaybetme sebebiyle ikamet izni iptal edilen yabancılar.",
                GirisIslem = "Girişine izin verilmez. Dış temsilcilik vizesi gerekir.",
                CikisIslem = "İkamet kartı geri alınır ve iptal işlemi yapılır.",
                OnemDerecesi = "Yuksek"
            },
            new TahditSozlukItem {
                Kod = "V-70",
                Baslik = "Sahte / Muvazaalı Evlilik Yapanlar",
                Kategori = "V Kodları (Vize / İkamet)",
                Sure = "5 Yıl",
                Aciklama = "Türk vatandaşı ile sadece ikamet izni veya vatandaşlık almak kastıyla gerçek dışı evlilik yapan yabancılar.",
                GirisIslem = "Girişine izin verilmez. 5 yıl giriş yasağı uygulanır.",
                CikisIslem = "Normal çıkış.",
                OnemDerecesi = "Yuksek"
            },
            new TahditSozlukItem {
                Kod = "V-71",
                Baslik = "Adres Değişikliğini Bildirmeyen Yabancılar",
                Kategori = "V Kodları (Vize / İkamet)",
                Sure = "Bildirime Kadar",
                Aciklama = "İkamet izni sahibi olup adres tahkikatında adresinde bulunamayan ve adres güncellemeyenler.",
                GirisIslem = "Girişte uyarılır, İl Göç İdaresine yönlendirilir.",
                CikisIslem = "Uyarılır, çıkışı verilir.",
                OnemDerecesi = "Bilgi"
            },
            new TahditSozlukItem {
                Kod = "V-74",
                Baslik = "Çıkışı İzne Tabi Yabancılar",
                Kategori = "V Kodları (Vize / İkamet)",
                Sure = "İzin Belgesine Kadar",
                Aciklama = "Türkiye'den ayrılışı Valilik veya Göç İdaresi Başkanlığı yol izin belgesine tabi yabancılar.",
                GirisIslem = "Normal.",
                CikisIslem = "Yol izin belgesi kontrol edilir; belgesiz çıkış yaptırılmaz.",
                OnemDerecesi = "Yuksek"
            },
            new TahditSozlukItem {
                Kod = "V-84",
                Baslik = "Şartlı Vize Girişi (10 Gün Taahhüt)",
                Kategori = "V Kodları (Vize / İkamet)",
                Sure = "10 Günlük Taahhüt",
                Aciklama = "Vize muafiyet veya vize süresi bitmiş olup kapıda cezasını ödeyerek 10 gün içinde ikamet iznine başvuracağını taahhüt eden yabancıların giriş kodu.",
                GirisIslem = "V-84 şartlı vize taahhüt formu imzalatılır, sisteme işlenir ve 10 gün süre verilir.",
                CikisIslem = "Taahhüde uyulup uyulmadığı ve ihlal cezası sorgulanır.",
                OnemDerecesi = "Standart"
            },
            new TahditSozlukItem {
                Kod = "V-87",
                Baslik = "Gönüllü Geri Dönüş Yapanlar",
                Kategori = "V Kodları (Vize / İkamet)",
                Sure = "1 Yıl / Değişken",
                Aciklama = "Geçici veya uluslararası koruma statüsünden kendi iradesiyle feragat ederek menşe ülkesine dönenler.",
                GirisIslem = "Gönüllü geri dönüş belgesi sorgulanır, vizesiz giriş yapılamaz.",
                CikisIslem = "Gönüllü geri dönüş formu onaylanır.",
                OnemDerecesi = "Standart"
            },
            new TahditSozlukItem {
                Kod = "V-88",
                Baslik = "Çalışma İzni İptal Edilen Yabancılar",
                Kategori = "V Kodları (Vize / İkamet)",
                Sure = "Bakanlık Kararı",
                Aciklama = "Çalışma izni Çalışma Bakanlığınca iptal edilen ve yasal kalış hakkı sona eren yabancılar.",
                GirisIslem = "Vizesi yoksa giriş verilmez.",
                CikisIslem = "Kalış süresi kontrol edilir.",
                OnemDerecesi = "Standart"
            },
            new TahditSozlukItem {
                Kod = "V-137",
                Baslik = "Türkiye'yi Terke Davet Edilenler",
                Kategori = "V Kodları (Vize / İkamet)",
                Sure = "15-30 Gün Terk Süresi",
                Aciklama = "Hakkında sınır dışı etme kararı alınıp Türkiye'yi terk etmesi için 15 ila 30 gün süre tanınan yabancılar.",
                GirisIslem = "Girişine izin verilmez.",
                CikisIslem = "Terke davet süresinde çıkıyorsa cezasız/normal çıkış; süreyi aştıysa giriş yasağı konur.",
                OnemDerecesi = "Yuksek"
            },
            new TahditSozlukItem {
                Kod = "V-144",
                Baslik = "Sınır Dışı Edilemeyecek Yabancılar (YUKK m.55)",
                Kategori = "V Kodları (Vize / İkamet)",
                Sure = "Statü Devamınca",
                Aciklama = "Menşe ülkesinde ölüm cezası, işkence veya insanlık dışı muameleye maruz kalma riski nedeniyle sınır dışı edilemeyen yabancılar.",
                GirisIslem = "İl Göç İdaresi koordinasyonu.",
                CikisIslem = "Belge kontrolü yapılır.",
                OnemDerecesi = "Standart"
            },
            new TahditSozlukItem {
                Kod = "V-146",
                Baslik = "Pasaportunda Çalıntı / Zayi Şerhi Bulunanlar",
                Kategori = "V Kodları (Vize / İkamet)",
                Sure = "Belge Değişimine Kadar",
                Aciklama = "Pasaportu için çalıntı, kayıp veya sahtelik kaydı girilmiş yabancılar.",
                GirisIslem = "Pasaporta el konulur, konsolosluk ve adli birimle teyit yapılır.",
                CikisIslem = "Pasaport geçerliliği teyit edilir.",
                OnemDerecesi = "Yuksek"
            },
            new TahditSozlukItem {
                Kod = "V-147",
                Baslik = "Pasaportunda Tahrifat Tespit Edilenler",
                Kategori = "V Kodları (Vize / İkamet)",
                Sure = "Adli İşlem",
                Aciklama = "Pasaport sayfalarında veya kimlik bölümünde tahrifat, silinti veya değişiklik tespit edilenler.",
                GirisIslem = "Belgeye el konulur, adli tahkikat başlatılır.",
                CikisIslem = "Adli tahkikat başlatılır.",
                OnemDerecesi = "Kritik"
            },
            new TahditSozlukItem {
                Kod = "V-148",
                Baslik = "Sahte İkamet veya Vize Belgesi Kullananlar",
                Kategori = "V Kodları (Vize / İkamet)",
                Sure = "Adli ve İdari Karar",
                Aciklama = "Sahte e-vize veya sahte ikamet izin belgesi ibraz ettiği tespit edilen yabancılar.",
                GirisIslem = "Girişi reddedilir, sahte belge zabıtla muhafaza edilir.",
                CikisIslem = "Adli işlem başlatılır.",
                OnemDerecesi = "Kritik"
            },
            new TahditSozlukItem {
                Kod = "V-154",
                Baslik = "İdare Mahkemesine Dava Açan Yabancılar",
                Kategori = "V Kodları (Vize / İkamet)",
                Sure = "Dava Sonuçlanana Kadar",
                Aciklama = "Sınır dışı (deport) veya tahdit kararına karşı idari yargıda iptal davası açan ve yürütmeyi durdurma talebinde bulunanlar.",
                GirisIslem = "Mahkeme kararı ve yürütmenin durdurulması kontrol edilir.",
                CikisIslem = "Dava sürecinde kendi isteğiyle çıkış yapabilir.",
                OnemDerecesi = "Standart"
            },
            new TahditSozlukItem {
                Kod = "V-157",
                Baslik = "İkamet İzni Başvurusu Reddedilenler",
                Kategori = "V Kodları (Vize / İkamet)",
                Sure = "10 Gün Terk Süresi",
                Aciklama = "İkamet izni başvurusu İl Göç İdaresi tarafından reddedilen ve 10 gün içinde Türkiye'yi terk etmesi gereken yabancılar.",
                GirisIslem = "Vizesi yoksa giriş verilemez.",
                CikisIslem = "10 günlük terk süresini aştıysa vize ihlal cezası uygulanır.",
                OnemDerecesi = "Standart"
            },
            new TahditSozlukItem {
                Kod = "V-160",
                Baslik = "Geçici Koruma Kapsamında Adres Tahkikatı Tahditi",
                Kategori = "V Kodları (Vize / İkamet)",
                Sure = "Tahkikat / İl Göç Kararı",
                Aciklama = "Geçici koruma kapsamındaki yabancıların bildirdikleri adreste bulunamamaları üzerine gıyabında girilen tahdit kaydıdır. Yabancı daha önce ülkemizden yasal yollarla çıkış yapmış olmasına rağmen geçici koruma kaydı zamanında kapatılmadığı için konulmuş olabilir.",
                GirisIslem = "Girişte idari para cezası UYGULANMAZ. Şahsın durumu tutanağa bağlanır ve kayıtlı olduğu İl Göç İdaresi Müdürlüğüne yönlendirilir.",
                CikisIslem = "Yasal çıkış işlemlerine istinaden tahkikat kontrolü yapılır, ilgili genelge uyarınca işlem tesis edilir.",
                OnemDerecesi = "Standart"
            },

            // === N KODLARI (ÖN İZİN VE İDARİ BİLDİRİM) ===
            new TahditSozlukItem {
                Kod = "N-82",
                Baslik = "İstizanlı Vize (Ön İzne Tabi Giriş)",
                Kategori = "N Kodları (Ön İzin / İdari)",
                Sure = "Ön İzne Tabi",
                Aciklama = "Türkiye'ye gelişi Göç İdaresi Başkanlığı veya Dışişleri Bakanlığı ön iznine (istizan) bağlanan yabancılar.",
                GirisIslem = "Ön izin onayı sisteme işlenmemişse kesinlikle ülkeye alınmaz.",
                CikisIslem = "Normal çıkış işlemi uygulanır.",
                OnemDerecesi = "Yuksek"
            },
            new TahditSozlukItem {
                Kod = "N-99",
                Baslik = "Interpol Bülteni ile Aranan Şahıslar",
                Kategori = "N Kodları (Ön İzin / İdari)",
                Sure = "Bülten Kalkana Kadar",
                Aciklama = "Interpol tarafından Kırmızı (Red Notice), Mavi veya Difüzyon mesajıyla uluslararası düzeyde aranan şahıslar.",
                GirisIslem = "Derhal nöbetçi amir ve Interpol Daire Başkanlığına bildirilir, şahıs muhafazaya alınır.",
                CikisIslem = "Derhal Interpol Dairesine teyit sorulur, yakalama yapılır.",
                OnemDerecesi = "Kritik"
            },
            new TahditSozlukItem {
                Kod = "N-120",
                Baslik = "Vize İhlali İdari Para Cezası Tahakkuku",
                Kategori = "N Kodları (Ön İzin / İdari)",
                Sure = "Tahsilata Kadar",
                Aciklama = "Vize veya vize muafiyetini ihlal eden yabancıların çıkış kapısında cezasının hesaplanarak tahsil edilmesi şerhidir.",
                GirisIslem = "Eski ceza borcu ödenmiş mi kontrol edilir.",
                CikisIslem = "Sistem üzerinden ihlal süresine göre ceza tahakkuk ettirilir.",
                OnemDerecesi = "Standart"
            },

            // === DİĞER KODLAR ===
            new TahditSozlukItem {
                Kod = "K",
                Baslik = "Kaçakçılık Suçları Tahditi",
                Kategori = "Diğer Kodlar",
                Sure = "Adli Karar",
                Aciklama = "Gümrük ve kaçakçılık suçları şüphelisi şahıslar için adli ve idari mercilerce konulan tahdit.",
                GirisIslem = "Gümrük muhafaza ve polis arama birimine sevk edilir.",
                CikisIslem = "Arama ve tahkikat yapılır.",
                OnemDerecesi = "Yuksek"
            },
            new TahditSozlukItem {
                Kod = "O-100",
                Baslik = "Uluslararası Güvenlik / Girişi Sakıncalı Şahıslar",
                Kategori = "Diğer Kodlar",
                Sure = "Süresiz",
                Aciklama = "Yabancı devlet güvenlik birimlerince bildirilen veya uluslararası terör şüphelisi şahıslar.",
                GirisIslem = "Girişine izin verilmez, terör birimi bilgilendirilir.",
                CikisIslem = "Kontrollü işlem yapılır.",
                OnemDerecesi = "Kritik"
            }
        };

        public List<TahditSozlukItem> GetAllCodes()
        {
            var list = new List<TahditSozlukItem>();
            var processedCodes = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

            // 1. BİRİNCİL ÖNCELİK: Veritabanındaki aktif "Tahditler ve Yapılacaklar" (TahditKod) kayıtları
            try
            {
                using (var db = new GZPEGM1())
                {
                    var dbCodes = db.TahditKod.AsNoTracking().Where(x => x.Aktif).ToList();
                    foreach (var item in dbCodes)
                    {
                        if (string.IsNullOrWhiteSpace(item.Kod)) continue;
                        var trimmedCode = item.Kod.Trim();
                        if (processedCodes.Contains(trimmedCode)) continue;

                        // Yerleşik kodlarda aynı kod varsa zenginleştirme / referans için alalım
                        var builtInMatch = _builtInCodes.FirstOrDefault(x => string.Equals(x.Kod, trimmedCode, StringComparison.OrdinalIgnoreCase));

                        // Ceza Süresi Formatı
                        string sure;
                        if (item.SureAy.HasValue && item.SureAy.Value > 0)
                        {
                            if (item.SureAy.Value >= 12 && item.SureAy.Value % 12 == 0)
                                sure = $"{item.SureAy.Value / 12} Yıl ({item.SureAy.Value} Ay)";
                            else
                                sure = $"{item.SureAy.Value} Ay";
                        }
                        else if (builtInMatch != null && !string.IsNullOrWhiteSpace(builtInMatch.Sure))
                        {
                            sure = builtInMatch.Sure;
                        }
                        else
                        {
                            sure = "Süresiz / Belirtilmemiş";
                        }

                        // Açıklama: Veritabanında girilen açıklama öncelikli
                        string aciklama = !string.IsNullOrWhiteSpace(item.Aciklama) 
                            ? item.Aciklama.Trim() 
                            : (builtInMatch?.Aciklama ?? "Açıklama bulunmuyor.");

                        // Başlık: Kısa kart başlığı
                        string baslik;
                        if (builtInMatch != null && !string.IsNullOrWhiteSpace(builtInMatch.Baslik))
                        {
                            baslik = builtInMatch.Baslik;
                        }
                        else if (!string.IsNullOrWhiteSpace(item.Aciklama))
                        {
                            baslik = item.Aciklama.Length > 70 
                                ? item.Aciklama.Substring(0, 67).Trim() + "..." 
                                : item.Aciklama.Trim();
                        }
                        else
                        {
                            baslik = trimmedCode + " Tahdit Kodu";
                        }

                        // Girişte Yapılacak İşlem (1. ÖNCELİK VERİTABANI!)
                        string giris = !string.IsNullOrWhiteSpace(item.GirisGelirse)
                            ? item.GirisGelirse.Trim()
                            : (builtInMatch?.GirisIslem ?? "Sistem kontrolü gereklidir.");

                        // Çıkışta Yapılacak İşlem (1. ÖNCELİK VERİTABANI!)
                        string cikis = !string.IsNullOrWhiteSpace(item.CikisGelirse)
                            ? item.CikisGelirse.Trim()
                            : (builtInMatch?.CikisIslem ?? "Sistem kontrolü gereklidir.");

                        string kategori = DetermineCategory(trimmedCode, builtInMatch?.Kategori);
                        string onem = DetermineImportance(trimmedCode, builtInMatch?.OnemDerecesi);

                        list.Add(new TahditSozlukItem
                        {
                            Id = item.Id,
                            Kod = trimmedCode,
                            Baslik = baslik,
                            Kategori = kategori,
                            Sure = sure,
                            Aciklama = aciklama,
                            GirisIslem = giris,
                            CikisIslem = cikis,
                            OnemDerecesi = onem,
                            TahditMedia = item.TahditMedia,
                            IsFromDatabase = true
                        });

                        processedCodes.Add(trimmedCode);
                    }
                }
            }
            catch
            {
                // Veritabanı bağlantı hatası durumunda yerleşik listeye devam et
            }

            // 2. İKİNCİL / TAMAMLAYICI KAYNAK: Veritabanında henüz tanımlanmamış yerleşik mevzuat kodları
            foreach (var b in _builtInCodes)
            {
                if (!string.IsNullOrWhiteSpace(b.Kod) && !processedCodes.Contains(b.Kod.Trim()))
                {
                    list.Add(new TahditSozlukItem
                    {
                        Id = null,
                        Kod = b.Kod.Trim(),
                        Baslik = b.Baslik,
                        Kategori = b.Kategori,
                        Sure = b.Sure,
                        Aciklama = b.Aciklama,
                        GirisIslem = b.GirisIslem,
                        CikisIslem = b.CikisIslem,
                        OnemDerecesi = b.OnemDerecesi,
                        TahditMedia = null,
                        IsFromDatabase = false
                    });
                    processedCodes.Add(b.Kod.Trim());
                }
            }

            // Standart kod sıralaması
            return list.OrderBy(x => x.Kod).ToList();
        }

        private static string DetermineCategory(string kod, string defaultCategory = null)
        {
            if (!string.IsNullOrWhiteSpace(defaultCategory) && defaultCategory != "Kullanıcı / Sistem Tanımlı Kodlar")
            {
                return defaultCategory;
            }

            if (string.IsNullOrWhiteSpace(kod)) return "Diğer Kodlar";
            var k = kod.Trim().ToUpperInvariant();
            if (k.StartsWith("Ç-") || k.StartsWith("C-")) return "Ç Kodları (Giriş Yasağı)";
            if (k.StartsWith("G-")) return "G Kodları (Güvenlik / Kamu Düzeni)";
            if (k.StartsWith("V-")) return "V Kodları (İkamet & Vize Kısıtlamaları)";
            if (k.StartsWith("N-")) return "N Kodları (Ön İzin / Özel Denetim)";
            if (k.StartsWith("K")) return "K Kodları (Kaçakçılık)";
            if (k.StartsWith("O-")) return "O Kodları (Uluslararası Güvenlik)";
            return "Diğer Kodlar";
        }

        private static string DetermineImportance(string kod, string defaultImportance = null)
        {
            if (!string.IsNullOrWhiteSpace(defaultImportance)) return defaultImportance;
            if (string.IsNullOrWhiteSpace(kod)) return "Standart";
            var k = kod.Trim().ToUpperInvariant();
            if (k.StartsWith("G-") || k.StartsWith("O-")) return "Kritik";
            if (k.StartsWith("Ç-") || k.StartsWith("C-") || k.StartsWith("K")) return "Yuksek";
            return "Standart";
        }

        public List<TahditSozlukItem> Search(string query, string category = null)
        {
            var all = GetAllCodes();
            IEnumerable<TahditSozlukItem> filtered = all;

            if (!string.IsNullOrWhiteSpace(category) && category != "Tumu")
            {
                filtered = filtered.Where(x => (x.Kategori != null && x.Kategori.IndexOf(category, StringComparison.OrdinalIgnoreCase) >= 0) ||
                                               (x.Kod != null && x.Kod.StartsWith(category, StringComparison.OrdinalIgnoreCase)));
            }

            if (!string.IsNullOrWhiteSpace(query))
            {
                var q = query.Trim().ToLowerInvariant();
                filtered = filtered.Where(x =>
                    (x.Kod ?? "").ToLowerInvariant().Contains(q) ||
                    (x.Baslik ?? "").ToLowerInvariant().Contains(q) ||
                    (x.Aciklama ?? "").ToLowerInvariant().Contains(q) ||
                    (x.GirisIslem ?? "").ToLowerInvariant().Contains(q) ||
                    (x.CikisIslem ?? "").ToLowerInvariant().Contains(q)
                );
            }

            return filtered.ToList();
        }
    }
}
