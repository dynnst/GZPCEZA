using gzpegm.Services;
using System.Linq;

namespace gzpegm.Models
{
    public class UlkeModel
    {
        private string[] _agrubu = new string[]
        {
            "ABD Virgin Adaları","Afganistan","Aland Adaları","Almanya","Amerika Birleşik Devletleri","Amerika Birleşik Devletleri Küçük Dış Adaları","Amerikan Samoası","Andora","Angola","Anguilla","Antarktika","Antigua ve Barbuda","Arjantin","Aruba","Avrupa Birliği","Avustralya","Avusturya","Azerbaycan","Bahamalar","Bahreyn","Bangladeş","Barbados","Batı Sahara","Belize","Benin","Bermuda","Bhutan","Bilinmeyen veya Geçersiz Bölge","Birleşik Arap Emirlikleri","Birleşik Krallık","Bolivya","Bosna Hersek","Botsvana","Bouvet Adası","Brezilya","Brunei","Bulgaristan","Burkina Faso","Burundi","Cape Verde","Cebelitarık","Christmas Adası","Cibuti","Cocos Adaları","Cook Adaları","Çad","Çin","Dominik","Dominik Cumhuriyeti","Doğu Timor","Ekvator","Ekvator Ginesi","El Salvador","Endonezya","Eritre","Ermenistan","Estonya","Falkland Adaları (Malvinalar)","Faroe Adaları","Filistin Bölgesi","Finlandiya","Fransa","Fransız Guyanası","Fransız Güney Bölgeleri","Fransız Polinezyası","Gabon","Gambia","Gana","Gine","Gine-Bissau","Granada","Grönland","Guadeloupe","Guam","Guatemala","Guernsey","Guyana","Güney Afrika","Güney Georgia ve Güney Sandwich Adaları","Güney Kıbrıs Rum Kesimi","Gürcistan","Haiti","Heard Adası ve McDonald Adaları","Hindistan","Hint Okyanusu İngiliz Bölgesi","Hollanda","Hollanda Antilleri","Honduras","Hırvatistan","İngiliz Virgin Adaları","İran","İsveç","İsviçre","İtalya","İzlanda","Jamaika","Jersey","Kamerun","Kanada","Katar","Kayman Adaları","Kazakistan","Kenya","Kiribati","Kolombiya","Komorlar","Kongo","Kongo Demokratik Cumhuriyeti","Kosta Rika","Kuzey Kore","Küba","Kırgızistan","Laos","Lesotho","Letonya","Liberya","Libya","Liechtenstein","Litvanya","Lübnan","Macaristan","Madagaskar","Makao S.A.R. Çin","Malavi","Maldivler","Malezya","Man Adası","Marshall Adaları","Martinik","Mauritius","Mayotte","Meksika","Moldovya Cumhuriyeti","Monako","Montserrat","Moritanya","Mozambik","Moğolistan","Myanmar","Namibya","Nauru","Nijer","Nijerya","Nikaragua","Niue","Norfolk Adası","Orta Afrika Cumhuriyeti","Özbekistan","Pakistan","Palau","Panama","Papua Yeni Gine","Paraguay","Peru","Pitcairn","Polonya","Portekiz","Porto Riko","Reunion","Romanya","Ruanda","Saint Helena","Saint Kitts ve Nevis","Saint Lucia","Saint Pierre ve Miquelon","Saint Vincent ve Grenadinler","Samoa","San Marino","Sao Tome ve Principe","Senegal","Seyşeller","Sierra Leone","Slovakya","Slovenya","Solomon Adaları","Somali","Sudan","Surinam","Suudi Arabistan","Svalbard ve Jan Mayen","Svaziland","Şili","Tanzanya","Tayland","Togo","Tokelau","Tonga","Trinidad ve Tobago","Turks ve Caicos Adaları","Tuvalu","Uganda","Ukrayna","Uruguay","Uzak Okyanusya","Vanuatu","Vatikan","Venezuela","Vietnam","Wallis ve Futuna","Yemen","Yeni Kaledonya","Yeni Zelanda","Yunanistan","Zambiya","Zimbabve"
        };
        private string[] _bgrubu = new string[] { "Filipinler","İsrail","Japonya","Kamboçya","Makedonya","Mali","Umman","Arnavutluk","Tacikistan" };
        private string[] _cgrubu = new string[] { "İspanya","Malta","Beyaz Rusya","Kuveyt","Belçika","Singapur","Tayvan","Cezayir","Lüksemburg","Ürdün" };
        private string[] _dgrubu = new string[] { "Hong Kong SAR - Çin","Mikronezya Federal Eyaletleri","Rusya Federasyonu","Etiyopya","Güney Kore" };
        private string[] _egrubu = new string[] { "Fas","Fildişi Sahilleri","Irak","Sırbistan-Karadağ","Karadağ","Mısır","Tunus" };
        private string[] _fgrubu = new string[] { "Norveç","Sırbistan","Fiji","Kuzey Mariana Adaları" };
        private string[] _ggrubu = new string[] { "Danimarka","Kosova","Çek Cumhuriyeti","İrlanda","Nepal","Sri Lanka","Suriye","Türkmenistan" };

        public string[] AGRUBU
        {
            get { return _agrubu; }
            set { _agrubu = value; }
        }

        public string[] BGRUBU
        {
            get { return CezaParametreService.GetCountryList("ULKE_BGRUBU", _bgrubu); }
            set { _bgrubu = value; }
        }

        public string[] CGRUBU
        {
            get { return CezaParametreService.GetCountryList("ULKE_CGRUBU", _cgrubu); }
            set { _cgrubu = value; }
        }

        public string[] DGRUBU
        {
            get { return CezaParametreService.GetCountryList("ULKE_DGRUBU", _dgrubu); }
            set { _dgrubu = value; }
        }

        public string[] EGRUBU
        {
            get { return CezaParametreService.GetCountryList("ULKE_EGRUBU", _egrubu); }
            set { _egrubu = value; }
        }

        public string[] FGRUBU
        {
            get { return CezaParametreService.GetCountryList("ULKE_FGRUBU", _fgrubu); }
            set { _fgrubu = value; }
        }

        public string[] GGRUBU
        {
            get { return CezaParametreService.GetCountryList("ULKE_GGRUBU", _ggrubu); }
            set { _ggrubu = value; }
        }
    }
}
