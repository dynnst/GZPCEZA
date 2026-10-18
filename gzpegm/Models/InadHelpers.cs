using System;
using System.Collections.Generic;
using System.Linq;

namespace gzpegm.Models
{
    public static class InadHelpers
    {
        /// <summary>
        /// Pasaport türleri listesi
        /// </summary>
        public static List<string> PasaportTurleri
        {
            get
            {
                return new List<string>
                {
                    "Umuma Mahsus",
                    "Diplomatik Pasaport",
                    "Hizmet Pasaportu",
                    "Kimlik Kartı",
                    "Seyahat Belgesi",
                    "Travel Döküman",
                    "Servis Pasaportu",
                    "Acil Durum Pasaportu"
                };
            }
        }

        /// <summary>
        /// Dünya ülkeleri listesi (alfabetik sıralı)
        /// </summary>
        public static List<string> Ulkeler
        {
            get
            {
                return new List<string>
                {
                    "Afganistan", "Almanya", "Amerika Birleşik Devletleri", "Andorra", "Angola", "Antigua ve Barbuda",
                    "Arjantin", "Arnavutluk", "Avustralya", "Avusturya", "Azerbaycan", "Bahama", "Bahreyn",
                    "Bangladeş", "Barbados", "Belarus", "Belçika", "Belize", "Benin", "Bhutan", "Bolivya",
                    "Bosna-Hersek", "Botsvana", "Brezilya", "Brunei", "Bulgaristan", "Burkina Faso", "Burundi",
                    "Cezayir", "Cibuti", "Çad", "Çek Cumhuriyeti", "Çin", "Danimarka", "Demokratik Kongo Cumhuriyeti",
                    "Dominik", "Dominik Cumhuriyeti", "Doğu Timor", "Ekvador", "Ekvator Ginesi", "El Salvador",
                    "Endonezya", "Eritre", "Ermenistan", "Estonya", "Etiyopya", "Fas", "Fiji", "Filipinler",
                    "Finlandiya", "Fransa", "Gabon", "Gambiya", "Gana", "Gine", "Gine-Bissau", "Granada",
                    "Grönland", "Guatemala", "Guyana", "Güney Afrika", "Güney Kore", "Güney Sudan", "Gürcistan",
                    "Haiti", "Hindistan", "Hırvatistan", "Hollanda", "Honduras", "Irak", "İran", "İrlanda",
                    "İspanya", "İsrail", "İsveç", "İsviçre", "İtalya", "İzlanda", "Jamaika", "Japonya",
                    "Kamboçya", "Kamerun", "Kanada", "Karadağ", "Katar", "Kazakistan", "Kenya", "Kıbrıs",
                    "Kırgızistan", "Kiribati", "Kolombiya", "Komor", "Kongo", "Kosta Rika", "Kuveyt", "Kuzey Kore",
                    "Kuzey Makedonya", "Laos", "Lesotho", "Letonya", "Liban", "Liberya", "Libya", "Liechtenstein",
                    "Litvanya", "Lüksemburg", "Macaristan", "Madagaskar", "Malavi", "Maldivler", "Malezya",
                    "Mali", "Malta", "Marshall Adaları", "Mauritius", "Meksika", "Mısır", "Mikronezya", "Moldovya",
                    "Monako", "Moğolistan", "Mozambik", "Myanmar", "Namibya", "Nauru", "Nepal", "Nijer",
                    "Nijerya", "Nikaragua", "Norveç", "Orta Afrika Cumhuriyeti", "Özbekistan", "Pakistan",
                    "Palau", "Panama", "Papua Yeni Gine", "Paraguay", "Peru", "Polonya", "Portekiz", "Romanya",
                    "Ruanda", "Rusya", "Saint Kitts ve Nevis", "Saint Lucia", "Saint Vincent ve Grenadinler",
                    "Samoa", "San Marino", "São Tomé ve Príncipe", "Senegal", "Seyşeller", "Sierra Leone",
                    "Singapur", "Sırbistan", "Slovakya", "Slovenya", "Solomon Adaları", "Somali", "Sri Lanka",
                    "Sudan", "Surinam", "Suudi Arabistan", "Şili", "Suriye", "Svaziland", "Tacikistan",
                    "Tanzanya", "Tayland", "Togo", "Tonga", "Trinidad ve Tobago", "Tunus", "Tuvalu", "Türkiye",
                    "Türkmenistan", "Uganda", "Ukrayna", "Umman", "Uruguay", "Ürdün", "Vanuatu", "Vatikan",
                    "Venezuela", "Vietnam", "Yemen", "Yeni Zelanda", "Yeşil Burun Adaları", "Yunanistan",
                    "Zambiya", "Zimbabve"
                };
            }
        }

        /// <summary>
        /// İNAD sebepleri listesi
        /// </summary>
        public static List<string> InadSebepleri
        {
            get
            {
                return new List<string>
                {
                    "Geçerli bir seyahat belgesine sahip olmaması",
                    "Türkiye'ye girişi sakıncalı görülmesi",
                    "Yeterli maddi imkâna sahip olmaması",
                    "Hakkında Türkiye'ye giriş yasağı bulunması",
                    "Giriş vizesinin olmaması",
                    "Pasaport süresinin yetersiz olması",
                    "Sahte pasaport",
                    "Pasaportta tahrifat yapılmış olması",
                    "Sahte vize / ikamet",
                    "Çalıntı belge",
                    "180 günde 90 gün uygulamasının ihlali",
                    "Türkiye'ye girmek istememesi",
                    "Diğer Sebepler / Other Reasons"
                };
            }
        }

        /// <summary>
        /// Beyan türleri listesi
        /// </summary>
        public static List<string> BeyanTurleri
        {
            get
            {
                return new List<string>
                {
                    "Yolcu kimlik bilgileri hamili olduğu belgeye göredir.",
                    "Yolcu kimlik bilgileri yolcunun beyanına göredir."
                };
            }
        }

        /// <summary>
        /// Yolcu durumları listesi
        /// </summary>
        public static List<string> YolcuDurumlari
        {
            get
            {
                return new List<string>
                {
                    "İnad Edilmek Üzere İnad Odasına Alındı.",
                    "İnad Edildi"
                };
            }
        }

        /// <summary>
        /// Uçağa nakil seçenekleri
        /// </summary>
        public static List<string> UcagaNakilSecenekleri
        {
            get
            {
                return new List<string>
                {
                    "Esyalari ve evraklari teslim edildi",
                    "Refakat edilmesi gerekmektedir"
                };
            }
        }

        /// <summary>
        /// Ülkeye göre form dili belirleme
        /// </summary>
        /// <param name="ulke">Ülke adı</param>
        /// <returns>Dil kodu (Almanca, Arapça, Bulgarca, Farsça, Fransızca, Gürcüce, İngilizce, Peştuca, Romence, Rusça)</returns>
        public static string GetFormLanguageByCountry(string ulke)
        {
            if (string.IsNullOrWhiteSpace(ulke))
                return "İngilizce"; // Varsayılan dil

            var ulkeNormalized = ulke.Trim();

            // Almanca ülkeler
            var almancaUlkeler = new[] { "Almanya", "Avusturya", "İsviçre", "Liechtenstein" };
            if (almancaUlkeler.Any(u => ulkeNormalized.Contains(u, StringComparison.OrdinalIgnoreCase)))
                return "Almanca";

            // Bulgarca ülkeler
            if (ulkeNormalized.Contains("Bulgaristan", StringComparison.OrdinalIgnoreCase))
                return "Bulgarca";

            // Farsça ülkeler
            if (ulkeNormalized.Contains("İran", StringComparison.OrdinalIgnoreCase))
                return "Farsça";

            // Fransızca ülkeler
            var fransizcaUlkeler = new[] { "Fransa", "Belçika", "Lüksemburg", "Monako", "Cezayir", "Fas", "Tunus", "Senegal", "Mali", "Nijer", "Çad", "Kamerun", "Gabon", "Kongo", "Madagaskar", "Mauritius", "Ruanda", "Burundi", "Cibuti", "Komor", "Vanuatu", "Haiti", "Kanada" };
            if (fransizcaUlkeler.Any(u => ulkeNormalized.Contains(u, StringComparison.OrdinalIgnoreCase)))
                return "Fransızca";

            // Gürcüce ülkeler
            if (ulkeNormalized.Contains("Gürcistan", StringComparison.OrdinalIgnoreCase))
                return "Gürcüce";

            // Peştuca ülkeler
            if (ulkeNormalized.Contains("Afganistan", StringComparison.OrdinalIgnoreCase))
                return "Peştuca";

            // Romence ülkeler
            var romenceUlkeler = new[] { "Romanya", "Moldovya", "Moldova" };
            if (romenceUlkeler.Any(u => ulkeNormalized.Contains(u, StringComparison.OrdinalIgnoreCase)))
                return "Romence";

            // Rusça ülkeler
            var ruscaUlkeler = new[] { "Rusya", "Belarus", "Ukrayna", "Kazakistan", "Kırgızistan", "Özbekistan", "Tacikistan", "Türkmenistan" };
            if (ruscaUlkeler.Any(u => ulkeNormalized.Contains(u, StringComparison.OrdinalIgnoreCase)))
                return "Rusça";

            // Arapça ülkeler
            var arapcaUlkeler = new[] { "Suudi Arabistan", "Irak", "Suriye", "Ürdün", "Liban", "Yemen", "Umman", "Birleşik Arap Emirlikleri", "Bahreyn", "Katar", "Kuveyt", "Mısır", "Libya", "Sudan", "Somali", "Cibuti", "Mauritanya", "Tunus", "Cezayir", "Fas", "Filistin" };
            if (arapcaUlkeler.Any(u => ulkeNormalized.Contains(u, StringComparison.OrdinalIgnoreCase)))
                return "Arapça";

            // Varsayılan: İngilizce
            return "İngilizce";
        }

        /// <summary>
        /// Yazdırma için desteklenen resmi diller sözlüğü
        /// </summary>
        public static readonly Dictionary<string, string> DesteklenenDiller = new Dictionary<string, string>
        {
            { "Turkce", "Türkçe (TR)" },
            { "Ingilizce", "English (EN)" },
            { "Arapca", "العربية (Arapça)" },
            { "Farsa", "فارسی (Farsça)" },
            { "Rusca", "Русский (Rusça)" },
            { "Fransizca", "Français (Fransızca)" },
            { "Almanca", "Deutsch (Almanca)" },
            { "Pestuca", "پښتو (Peştuca)" },
            { "Gurcuce", "ქართული (Gürcüce)" },
            { "Bulgarca", "Български (Bulgarca)" },
            { "Romence", "Română (Romence)" }
        };

        /// <summary>
        /// Dil koduna göre view dosya adı döndürür
        /// </summary>
        /// <param name="dil">Dil adı</param>
        /// <param name="formNo">Form numarası (1, 2, 3, 4, 5, 6)</param>
        /// <returns>View dosya yolu</returns>
        public static string GetFormViewPath(string dil, int formNo = 1)
        {
            var cleanDil = (dil ?? "").Trim();
            if (string.Equals(cleanDil, "Türkçe", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(cleanDil, "Turkce", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(cleanDil, "TR", StringComparison.OrdinalIgnoreCase))
            {
                return $"PrintTemplates/Form{formNo}";
            }

            var dilKodu = cleanDil switch
            {
                "Almanca" => "Almanca",
                "Arapça" or "Arapca" => "Arapca",
                "Bulgarca" => "Bulgarca",
                "Farsça" or "Farsa" or "Farsca" => "Farsa",
                "Fransızca" or "Fransizca" => "Fransizca",
                "Gürcüce" or "Gurcuce" => "Gurcuce",
                "İngilizce" or "Ingilizce" => "Ingilizce",
                "Peştuca" or "Pestuca" => "Pestuca",
                "Romence" => "Romence",
                "Rusça" or "Rusca" => "Rusca",
                _ => "Ingilizce" // Varsayılan
            };

            return $"PrintTemplates/Form{formNo}_{dilKodu}";
        }
    }
}