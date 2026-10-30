/* ==========================================================================
   E-INAD Yonetim JavaScript (einad-index.js v2.0)
   Modern EGM Hudut Polisi Komuta & Sevk Scriptleri
   ========================================================================== */

var _cfg = document.getElementById('einad-config');
function getEinadUrl(attr, fallback) {
    return (_cfg && _cfg.getAttribute(attr)) ? _cfg.getAttribute(attr) : fallback;
}

/* =========================
   TARİH YARDIMCILARI
========================= */
function getLocalDateTimeForInput() {
    var now = new Date();
    now.setMinutes(now.getMinutes() - now.getTimezoneOffset());
    return now.toISOString().slice(0, 16);
}

function parseMsDateToLocal(value, isDateOnly) {
    if (value === null || value === undefined || value === '') return "";
    if (typeof value === 'string') {
        var msMatch = /\/Date\((\-?\d+)(?:[+-]\d+)?\)\//.exec(value);
        if (msMatch) {
            value = parseInt(msMatch[1], 10);
        }
    }
    var d = new Date(value);
    if (isNaN(d)) return "";
    d.setMinutes(d.getMinutes() - d.getTimezoneOffset());
    return isDateOnly ? d.toISOString().slice(0, 10) : d.toISOString().slice(0, 16);
}

function getAntiForgeryToken() {
    return $('#inadForm input[name="__RequestVerificationToken"]').val()
        || $('input[name="__RequestVerificationToken"]').first().val();
}

function showEInadStatus(message, type) {
    var status = $('#einadStatus');
    if (!status.length) return;

    var cssType = type || 'info';
    status
        .removeClass('alert-success alert-danger alert-warning alert-info')
        .addClass('alert-' + cssType)
        .empty()
        .append($.parseHTML(message))
        .css('display', 'block');
}

function hideEInadStatus() {
    $('#einadStatus').css('display', 'none').empty();
}

/* =========================
   INTERAKTIF KPI FILTRELERI
========================= */
function filterByKpi(type) {
    var table = $('#inad-table').DataTable ? $('#inad-table').DataTable() : null;

    if (type === 'all') {
        if (table) {
            table.search('').draw();
        }
        $('#filterQ').val('');
        $('#filterFrom').val('');
        $('#filterTo').val('');
        var form = document.getElementById('inadFilterForm');
        if (form && window.location.search) {
            window.location.href = form.action;
        }
    } else if (type === 'odada') {
        if (table) {
            table.search('İnad Odasına Alındı').draw();
            $('html, body').animate({ scrollTop: $('#inad-table').offset().top - 80 }, 300);
        } else {
            $('#filterQ').val('İnad Odasına Alındı');
            $('#inadFilterForm').submit();
        }
    } else if (type === 'edildi') {
        if (table) {
            table.search('İnad Edildi').draw();
            $('html, body').animate({ scrollTop: $('#inad-table').offset().top - 80 }, 300);
        } else {
            $('#filterQ').val('İnad Edildi');
            $('#inadFilterForm').submit();
        }
    } else if (type === 'bugun') {
        var today = new Date().toISOString().slice(0, 10);
        $('#filterFrom').val(today);
        $('#filterTo').val(today);
        $('#inadFilterForm').submit();
    }
}

/* =========================
   UYRUK → DOĞUM YERİ
========================= */
function initUyrukChange() {
    $('#Uyruk').off('change').on('change', function () {
        var val = $(this).val();
        if (val && !$('#DogumY').val()) {
            $('#DogumY').val(val);
        }
    });
}

/* =========================
   HAVAYOLU LİSTESİ YÜKLE
========================= */
function loadAirlineList() {
    $.get(getEinadUrl('data-url-get-airlines', '/EInad/GetEuropeanAirlines'))
        .done(function (list) {
            var dl = $('#airlineList').empty();
            if (Array.isArray(list) && list.length > 0) {
                list.forEach(function (a) {
                    dl.append($('<option>').val(a.Name).data('iata', a.IATACode));
                });
            }
        })
        .fail(function () { });
}

/* =========================
   HAVAYOLU KONTROL VE EKLEME
========================= */
function checkAndAddAirline(airlineName, flightNo) {
    if (!airlineName || airlineName.trim().length === 0) return;
    if (!flightNo || flightNo.length < 2) return;

    airlineName = airlineName.trim();
    var iataCode = flightNo.substring(0, 2).toUpperCase();

    var options = $('#airlineList option');
    var found = false;

    options.each(function () {
        var optionName = $(this).val();
        var optionIata = $(this).data('iata');

        if (optionName && optionName.toLowerCase() === airlineName.toLowerCase()) {
            found = true;
            return false;
        }
        if (optionIata && optionIata === iataCode) {
            found = true;
            return false;
        }
    });

    if (!found) {
        $.ajax({
            url: getEinadUrl('data-url-add-airline', '/EInad/AddUserDefinedAirline'),
            type: 'POST',
            data: {
                flightNo: flightNo,
                airlineName: airlineName,
                __RequestVerificationToken: getAntiForgeryToken()
            },
            success: function (response) {
                if (response && response.success) {
                    loadAirlineList();
                }
            },
            error: function () { }
        });
    }
}

function initHavayoluManualCheck() {
    $('#GelenHavayolu').on('blur', function () {
        var airlineName = $(this).val();
        var flightNo = $('#GelenUcusNo').val();
        if (airlineName && flightNo && flightNo.length >= 2) {
            checkAndAddAirline(airlineName, flightNo);
        }
    });

    $('#GidenHavayolu').on('blur', function () {
        var airlineName = $(this).val();
        var flightNo = $('#GidisUcusNo').val();
        if (airlineName && flightNo && flightNo.length >= 2) {
            checkAndAddAirline(airlineName, flightNo);
        }
    });
}

function initUcusNoToAirline() {
    $('#GelenUcusNo, #GidisUcusNo').on('input', function () {
        $(this).val($(this).val().toUpperCase());
    });

    $('#GelenUcusNo').on('blur', function () {
        var flightNo = $(this).val();
        if (flightNo && flightNo.length >= 2) {
            var iataCode = flightNo.substring(0, 2).toUpperCase();
            findAirlineByIata(iataCode, '#GelenHavayolu', flightNo);
        }
    });

    $('#GidisUcusNo').on('blur', function () {
        var flightNo = $(this).val();
        if (flightNo && flightNo.length >= 2) {
            var iataCode = flightNo.substring(0, 2).toUpperCase();
            findAirlineByIata(iataCode, '#GidenHavayolu', flightNo);
        }
    });
}

function findAirlineByIata(iataCode, fieldSelector, flightNo) {
    if (!iataCode || iataCode.length !== 2) return;

    var options = $('#airlineList option');
    var foundOption = null;

    options.each(function () {
        var optionData = $(this).data('iata');
        if (optionData && optionData === iataCode) {
            foundOption = $(this);
            return false;
        }
    });

    if (foundOption) {
        $(fieldSelector).val(foundOption.val());
    } else {
        $.get(getEinadUrl('data-url-get-iata', '/EInad/GetByIataCode'), { iata: iataCode })
            .done(function (res) {
                if (res.success) {
                    $(fieldSelector).val(res.name);

                    $.ajax({
                        url: getEinadUrl('data-url-add-airline', '/EInad/AddUserDefinedAirline'),
                        type: 'POST',
                        data: {
                            flightNo: flightNo,
                            airlineName: res.name,
                            __RequestVerificationToken: getAntiForgeryToken()
                        },
                        success: function (response) {
                            if (response.success) {
                                loadAirlineList();
                            }
                        },
                        error: function () { }
                    });
                }
            })
            .fail(function () { });
    }
}

/* ==========================================================================
   MRZ (MACHINE READABLE ZONE) & 3M OPTİK OKUYUCU ENTEGRASYONU (PV40 / PV60)
   ========================================================================== */
var _isoCountryMap = {
    'TUR': 'Türkiye', 'DEU': 'Almanya', 'GBR': 'İngiltere', 'RUS': 'Rusya', 'UKR': 'Ukrayna',
    'USA': 'Amerika Birleşik Devletleri', 'FRA': 'Fransa', 'NLD': 'Hollanda', 'BEL': 'Belçika',
    'AUT': 'Avusturya', 'CHE': 'İsviçre', 'SWE': 'İsveç', 'NOR': 'Norveç', 'DNK': 'Danimarka',
    'FIN': 'Finlandiya', 'POL': 'Polonya', 'CZE': 'Çek Cumhuriyeti', 'ROU': 'Romanya', 'BGR': 'Bulgaristan',
    'GRC': 'Yunanistan', 'ITA': 'İtalya', 'ESP': 'İspanya', 'PRT': 'Portekiz', 'AZE': 'Azerbaycan',
    'KAZ': 'Kazakistan', 'UZB': 'Özbekistan', 'KGZ': 'Kırgızistan', 'TKM': 'Türkmenistan', 'TJK': 'Tacikistan',
    'GEO': 'Gürcistan', 'ARM': 'Ermenistan', 'MDA': 'Moldovya', 'BLR': 'Belarus', 'IRN': 'İran',
    'IRQ': 'Irak', 'SYR': 'Suriye', 'LBN': 'Lübnan', 'JOR': 'Ürdün', 'ISR': 'İsrail',
    'SAU': 'Suudi Arabistan', 'ARE': 'Birleşik Arap Emirlikleri', 'KWT': 'Kuveyt', 'QAT': 'Katar',
    'BHR': 'Bahreyn', 'OMN': 'Umman', 'EGY': 'Mısır', 'LBY': 'Libya', 'TUN': 'Tunus',
    'DZA': 'Cezayir', 'MAR': 'Fas', 'SDN': 'Sudan', 'SOM': 'Somali', 'ETH': 'Etiyopya',
    'KEN': 'Kenya', 'NGA': 'Nijerya', 'GHA': 'Gana', 'ZAF': 'Güney Afrika', 'IND': 'Hindistan',
    'PAK': 'Pakistan', 'BGD': 'Bangladeş', 'AFG': 'Afganistan', 'CHN': 'Çin', 'JPN': 'Japonya',
    'KOR': 'Güney Kore', 'IDN': 'Endonezya', 'MYS': 'Malezya', 'PHL': 'Filipinler', 'THA': 'Tayland',
    'VNM': 'Vietnam', 'AUS': 'Avustralya', 'CAN': 'Kanada', 'BRA': 'Brezilya', 'ARG': 'Arjantin',
    'MEX': 'Meksika', 'COL': 'Kolombiya', 'SRB': 'Sırbistan', 'BIH': 'Bosna-Hersek', 'HRV': 'Hırvatistan',
    'MKD': 'Kuzey Makedonya', 'ALB': 'Arnavutluk', 'MNE': 'Karadağ', 'KOS': 'Kosova', 'HUN': 'Macaristan',
    'SVK': 'Slovakya', 'SVN': 'Slovenya', 'IRL': 'İrlanda', 'CYP': 'Kıbrıs', 'MLT': 'Malta'
};

function playScanBeep() {
    try {
        var AudioCtx = window.AudioContext || window.webkitAudioContext;
        if (!AudioCtx) return;
        var audioCtx = new AudioCtx();
        if (audioCtx.state === 'suspended') {
            audioCtx.resume();
        }
        var osc = audioCtx.createOscillator();
        var gain = audioCtx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(880, audioCtx.currentTime);
        gain.gain.setValueAtTime(0.12, audioCtx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.16);
        osc.connect(gain);
        gain.connect(audioCtx.destination);
        osc.start();
        osc.stop(audioCtx.currentTime + 0.16);
    } catch (e) { }
}

function cleanOcrMrzLine(line) {
    if (!line) return "";
    var cleaned = line.toUpperCase().replace(/\s+/g, '');
    // OCR veya bozuk karakter kodlaması (, «, », ‹, ›, parantez/köşeli parantezler)
    cleaned = cleaned.replace(/[\uFFFD«»‹›\(\)\{\}\[\]]/g, '<');
    cleaned = cleaned.replace(/^P[KC«‹]/, 'P<');
    cleaned = cleaned.replace(/^I[KC«‹]/, 'I<');
    cleaned = cleaned.replace(/K{2,}/g, function (match) { return '<'.repeat(match.length); });
    cleaned = cleaned.replace(/C{2,}/g, function (match) { return '<'.repeat(match.length); });
    return cleaned;
}

function parseDateString(str) {
    if (!str) return "";
    str = str.trim();

    // 1. Durum: Ham 6 hane (YYMMDD) - Ã–rn: 840408
    if (/^\d{6}$/.test(str)) {
        var yy = parseInt(str.substr(0, 2), 10);
        var mm = str.substr(2, 2);
        var dd = str.substr(4, 2);
        var currentYearShort = new Date().getFullYear() % 100;
        var fullYear = (yy > currentYearShort ? 1900 : 2000) + yy;
        return fullYear + '-' + mm + '-' + dd;
    }

    // 2. Durum: Ham 8 hane (YYYYMMDD) - Ã–rn: 19840408
    if (/^\d{8}$/.test(str)) {
        return str.substr(0, 4) + '-' + str.substr(4, 2) + '-' + str.substr(6, 2);
    }

    // 3. Durum: DD-MM-YYYY veya DD/MM/YYYY veya DD.MM.YYYY (4 haneli yÄ±l)
    var dmy4 = /^(\d{1,2})[\/\.\-](\d{1,2})[\/\.\-](\d{4})$/.exec(str);
    if (dmy4) {
        var d = dmy4[1].length === 1 ? '0' + dmy4[1] : dmy4[1];
        var m = dmy4[2].length === 1 ? '0' + dmy4[2] : dmy4[2];
        return dmy4[3] + '-' + m + '-' + d;
    }

    // 4. Durum: YYYY-MM-DD veya YYYY/MM/DD (4 haneli yÄ±l)
    var ymd4 = /^(\d{4})[\/\.\-](\d{1,2})[\/\.\-](\d{1,2})$/.exec(str);
    if (ymd4) {
        var m2 = ymd4[2].length === 1 ? '0' + ymd4[2] : ymd4[2];
        var d2 = ymd4[3].length === 1 ? '0' + ymd4[3] : ymd4[3];
        return ymd4[1] + '-' + m2 + '-' + d2;
    }

    // 5. Durum: DD-MM-YY veya DD/MM/YY veya DD.MM.YY (3M Wedge FormatÄ±! Ã–rn: 08-04-84)
    var dmy2 = /^(\d{1,2})[\/\.\-](\d{1,2})[\/\.\-](\d{2})$/.exec(str);
    if (dmy2) {
        var day2 = dmy2[1].length === 1 ? '0' + dmy2[1] : dmy2[1];
        var month2 = dmy2[2].length === 1 ? '0' + dmy2[2] : dmy2[2];
        var year2 = parseInt(dmy2[3], 10);
        var currentYrShort = new Date().getFullYear() % 100;
        var fullYr2 = (year2 > currentYrShort ? 1900 : 2000) + year2;
        return fullYr2 + '-' + month2 + '-' + day2;
    }

    // 6. Durum: YY-MM-DD veya YY/MM/DD (2 haneli yÄ±l Ã¶nde)
    var ymd2 = /^(\d{2})[\/\.\-](\d{1,2})[\/\.\-](\d{1,2})$/.exec(str);
    if (ymd2) {
        var year2b = parseInt(ymd2[1], 10);
        var month2b = ymd2[2].length === 1 ? '0' + ymd2[2] : ymd2[2];
        var day2b = ymd2[3].length === 1 ? '0' + ymd2[3] : ymd2[3];
        var curYrB = new Date().getFullYear() % 100;
        var fullYr2b = (year2b > curYrB ? 1900 : 2000) + year2b;
        return fullYr2b + '-' + month2b + '-' + day2b;
    }

    return "";
}

function parseSexString(str) {
    if (!str) return "";
    var s = str.trim().toUpperCase();
    if (s === 'M' || s.indexOf('MALE') === 0 || s.indexOf('ERKEK') === 0) return 'Erkek';
    if (s === 'F' || s.indexOf('FEMALE') === 0 || s.indexOf('BAYAN') === 0 || s.indexOf('KADIN') === 0) return 'Bayan';
    return "";
}

function applyCountryToSelect(countryCodeOrName) {
    if (!countryCodeOrName) return "";
    var target = countryCodeOrName.trim().toUpperCase();
    var mappedName = _isoCountryMap[target] || countryCodeOrName.trim();
    if (!mappedName) return "";

    var foundVal = null;
    var targetLower = mappedName.toLowerCase();

    $('#Uyruk option').each(function () {
        var optVal = $(this).val();
        if (!optVal) return;
        var optLower = optVal.toLowerCase();
        if (optLower === targetLower || optLower.indexOf(targetLower) >= 0 || targetLower.indexOf(optLower) >= 0) {
            foundVal = optVal;
            return false;
        }
    });

    if (foundVal) {
        $('#Uyruk').val(foundVal).trigger('change');
        return foundVal;
    } else {
        $('#Uyruk').append($('<option selected></option>').val(mappedName).text(mappedName)).trigger('change');
        return mappedName;
    }
}

function parseAndApplyMrz(rawText, sourceName) {
    if (!rawText || !rawText.trim()) return false;

    var surname = "";
    var givenNames = "";
    var passportNo = "";
    var nationalityCode = "";
    var birthDateStr = "";
    var sex = "";
    var kimlikNo = "";
    var parsedSuccessfully = false;

        // =========================================================================
    // 1. FORMAT: 3M & REGULA KEY-VALUE WEDGE FORMATI
    // =========================================================================
    var hasWedgeKeys = /(?:Surname|Last\s*Name|Family\s*Name|Forenames?|Given\s*Names?|First\s*Names?|Name|Doc\.?\s*(?:Number|No)|Document\s*(?:Number|No)?|Passport\s*(?:Number|No)?|Date\s*of\s*Birth|Birth\s*Date|DOB|Nationality|Country|Personal\s*No|START|REGULA)/i.test(rawText);
    if (hasWedgeKeys) {
        var lines = rawText.split(/[\r\n]+/);
        for (var i = 0; i < lines.length; i++) {
            var l = lines[i].trim();
            if (!l) continue;

            // Soyad (Surname, Last Name, Family Name)
            var mSurname = /^(?:Surname|Last\s*Name|Family\s*Name)\s*:\s*(.+)$/i.exec(l);
            if (mSurname) surname = mSurname[1].trim();

            // Ad (Forenames, Given Name, First Name, Given Names, Name)
            var mForenames = /^(?:Forenames?|Given\s*Names?|First\s*Names?|Name)\s*:\s*(.+)$/i.exec(l);
            if (mForenames) givenNames = mForenames[1].trim();

            // Belge TÃ¼rÃ¼
            var mDocType = /^(?:Document|Doc\.?\s*Type|Document\s*Type)\s*:\s*(.+)$/i.exec(l);
            if (mDocType && !nationalityCode) {
                var dt = mDocType[1].trim();
                if (/IDENTITY\s*CARD/i.test(dt)) {
                    nationalityCode = 'TUR';
                }
            }

            // Pasaport / Belge No (Doc Number, Document Number, Passport Number, DocNo)
            var mDocNo = /^(?:Doc\.?\s*(?:Number|No)?|Document\s*(?:Number|No)?|Passport\s*(?:Number|No)?|DocNo)\s*:\s*(.+)$/i.exec(l);
            if (mDocNo) passportNo = mDocNo[1].trim();

            // T.C. Kimlik No / KiÅŸisel No (Regula Personal Number, National ID, Personal No, Identity No)
            var mPersonal = /^(?:Personal\s*(?:Number|No)|National\s*ID|Identity\s*(?:Number|No)|TC\s*(?:Kimlik\s*No)?)\s*:\s*(.+)$/i.exec(l);
            if (mPersonal) kimlikNo = mPersonal[1].trim();

            // DoÄŸum Tarihi (Date of Birth, Birth Date, DOB)
            var mDob = /^(?:Date\s*of\s*Birth|Birth\s*Date|DOB)\s*:\s*(.+)$/i.exec(l);
            if (mDob) birthDateStr = parseDateString(mDob[1]);

            // Cinsiyet (Sex, Gender)
            var mSex = /^(?:Sex|Gender)\s*:\s*(.+)$/i.exec(l);
            if (mSex) sex = parseSexString(mSex[1]);

            // Uyruk (Nationality, Issuing State, Country, Citizenship)
            var mNat = /^(?:Nationality|Issuing\s*State|Country|Citizenship)\s*:\s*(.+)$/i.exec(l);
            if (mNat && !nationalityCode) nationalityCode = mNat[1].trim();
        }

        if (surname || givenNames || passportNo) {
            parsedSuccessfully = true;
        }
    }

    // =========================================================================
    // 2. FORMAT: STANDART ICAO MRZ (TD3 Pasaport 2x44, TD1 Kimlik 3x30, TD2 2x36)
    // =========================================================================
    if (!parsedSuccessfully) {
        var cleanText = rawText.replace(/\r/g, '\n').replace(/\t/g, '\n');
        var rawLines = cleanText.split('\n')
            .map(function (s) { return cleanOcrMrzLine(s.trim()); })
            .filter(function (s) { return s.length >= 10; });

        var line1 = "", line2 = "", line3 = "";

        // Sürekli tek parça metin geldiyse (satır başı olmadan 88 veya 90 karakter)
        if (rawLines.length === 1 && rawLines[0].length >= 80) {
            var single = rawLines[0];
            if (single.indexOf('P<') >= 0 || single.indexOf('P') === 0) {
                var pIdx = Math.max(0, single.indexOf('P<'));
                line1 = single.substr(pIdx, 44);
                line2 = single.substr(pIdx + 44, 44);
            } else if (single.indexOf('I<') >= 0 || single.indexOf('I') === 0) {
                var iIdx = Math.max(0, single.indexOf('I<'));
                line1 = single.substr(iIdx, 30);
                line2 = single.substr(iIdx + 30, 30);
                line3 = single.substr(iIdx + 60, 30);
            }
        }

        // Satırlar arasında TD3 (2x44) Pasaport Bulma
        if (!line1) {
            for (var idx = 0; idx < rawLines.length; idx++) {
                var cur = rawLines[idx];
                if ((cur.indexOf('P<') === 0 || cur.indexOf('P') === 0) && cur.length >= 35) {
                    line1 = cur;
                    if (idx + 1 < rawLines.length) {
                        line2 = rawLines[idx + 1];
                    }
                    break;
                }
            }
        }

        // Satırlar arasında TD1 (3x30) Kimlik Kartı Bulma
        if (!line1) {
            for (var idx2 = 0; idx2 < rawLines.length; idx2++) {
                var cur2 = rawLines[idx2];
                if ((cur2.indexOf('I<') === 0 || cur2.indexOf('I') === 0 || cur2.indexOf('A<') === 0) && cur2.length >= 28) {
                    line1 = cur2;
                    if (idx2 + 1 < rawLines.length) line2 = rawLines[idx2 + 1];
                    if (idx2 + 2 < rawLines.length) line3 = rawLines[idx2 + 2];
                    break;
                }
            }
        }

        // Son çare: Satır sayısına göre eşleştir
        if (!line1 && rawLines.length >= 2) {
            line1 = rawLines[rawLines.length - 2];
            line2 = rawLines[rawLines.length - 1];
        }

        // --- TD1 KİMLİK KARTI AYRIŞTIRMA (3 Satır x 30 Karakter) ---
        if (line3 && line1.length >= 28 && line2.length >= 28) {
            // Line 1: I<TUR + Belge No (5-13) + TC Kimlik / Opsiyonel (15-29)
            if (line1.length >= 5) nationalityCode = line1.substr(2, 3).replace(/</g, '').trim();
            if (line1.length >= 14) passportNo = line1.substr(5, 9).replace(/</g, '').trim();
            if (line1.length >= 26) {
                var optRaw = line1.substr(15, 11).replace(/</g, '').trim();
                if (/^\d{11}$/.test(optRaw)) kimlikNo = optRaw;
            }

            // Line 2: Doğum Tarihi (0-5) + Cinsiyet (7)
            if (line2.length >= 8) {
                birthDateStr = parseDateString(line2.substr(0, 6));
                sex = parseSexString(line2.substr(7, 1));
            }

            // Line 3: Soyad << Adlar
            var nameLine = line3.replace(/[\uFFFD«»‹›\(\)\{\}\[\]]/g, '<');
            var parts = nameLine.split(/<{2,}/).filter(function (p) { return p.replace(/</g, '').trim().length > 0; });
            if (parts.length >= 1) surname = parts[0].replace(/<+/g, ' ').replace(/[^A-ZÇĞİÖŞÜ\s]/g, ' ').trim();
            if (parts.length >= 2) givenNames = parts[1].replace(/<+/g, ' ').replace(/[^A-ZÇĞİÖŞÜ\s]/g, ' ').trim();
            parsedSuccessfully = true;
        }
        // --- TD3 PASAPORT AYRIŞTIRMA (2 Satır x 44 Karakter) ---
        else if (line1) {
            // Line 1 İsim Ayrıştırma
            var namePart = "";
            if (line1.indexOf('P<') === 0 || line1.indexOf('I<') === 0) {
                if (!nationalityCode) nationalityCode = line1.substr(2, 3).replace(/[<]/g, '').trim();
                namePart = line1.substr(5);
            } else if (line1.indexOf('P') === 0 || line1.indexOf('I') === 0) {
                if (!nationalityCode) nationalityCode = line1.substr(1, 3).replace(/[<]/g, '').trim();
                namePart = line1.substr(4);
            } else {
                namePart = line1;
            }

            var normalizedNamePart = namePart.replace(/[\uFFFD«»‹›\(\)\{\}\[\]]/g, '<');
            var primaryParts = normalizedNamePart.split(/<{2,}/).filter(function (p) {
                return p.replace(/</g, '').trim().length > 0;
            });

            if (primaryParts.length >= 1) {
                surname = primaryParts[0].replace(/<+/g, ' ').replace(/[^A-ZÇĞİÖŞÜ\s]/g, ' ').replace(/\s+/g, ' ').trim();
            }
            if (primaryParts.length >= 2) {
                givenNames = primaryParts[1].replace(/<+/g, ' ').replace(/[^A-ZÇĞİÖŞÜ\s]/g, ' ').replace(/\s+/g, ' ').trim();
            }
            if (!givenNames && normalizedNamePart.indexOf('<') >= 0) {
                var singleParts = normalizedNamePart.split(/<+/).map(function (s) {
                    return s.replace(/[^A-ZÇĞİÖŞÜ\s]/g, ' ').replace(/\s+/g, ' ').trim();
                }).filter(function (s) { return s.length > 0; });
                if (singleParts.length >= 1) surname = singleParts[0];
                if (singleParts.length >= 2) givenNames = singleParts.slice(1).join(' ');
            }

            // Line 2 Ayrıştırma (Belge No, Uyruk, Doğum Tarihi, Cinsiyet)
            if (line2 && line2.length >= 20) {
                passportNo = line2.substr(0, 9).replace(/[<«»‹›\uFFFD]/g, '').trim();
                if (!nationalityCode || nationalityCode.length < 3) {
                    nationalityCode = line2.substr(10, 3).replace(/[<«»‹›\uFFFD]/g, '').trim();
                }
                var dobRaw = line2.substr(13, 6);
                birthDateStr = parseDateString(dobRaw);
                sex = parseSexString(line2.substr(20, 1));
            }

            if (surname || givenNames || passportNo) {
                parsedSuccessfully = true;
            }
        }
    }

    if (!parsedSuccessfully) return false;

    // =========================================================================
    // 3. FORM ALANLARINA OTOMATİK AKTARIM & UI PARILTI VURGULARI
    // =========================================================================
    var fullName = (surname + ' ' + givenNames).trim();
    if (fullName) $('#AdSoyad').val(fullName);
    if (passportNo) { $('#PasaportNo').val(passportNo); if (!$('#BelgeNo').val()) $('#BelgeNo').val(passportNo); }
    if (sex) $('#Cinsiyet').val(sex);
    if (birthDateStr) $('#DogumT').val(birthDateStr);
    if (kimlikNo) $('#KimlikNo').val(kimlikNo);

    var matchedCountry = applyCountryToSelect(nationalityCode);

    // Sesli onay
    playScanBeep();

    // Bilgi etiketi & Geri bildirim
    var sourceLabel = sourceName ? ' (' + sourceName + ')' : '';
    var feedback = '✅ Okuyucudan Aktarıldı' + sourceLabel + ': ' + (fullName || 'Yolcu') + ' | Belge No: ' + (passportNo || '-') + ' | Uyruk: ' + (matchedCountry || nationalityCode || '-');
    $('#mrzFeedback').text(feedback).show();

    // Alanları yeşil parıltıyla vurgula
    var targetFields = $('#AdSoyad, #PasaportNo, #Uyruk, #Cinsiyet, #DogumT, #KimlikNo');
    targetFields.css('transition', 'background-color 0.4s').css('background-color', '#dcfce7');
    setTimeout(function () {
        targetFields.css('background-color', '');
    }, 1800);

    // İlgili akordeonları otomatik aç
    $('#accKimlik').collapse('show');
    $('#accBelge').collapse('show');

    // MRZ metin kutusuna da ham veriyi yaz
    $('#mrzInputText').val(rawText.trim());

    if (typeof showEInadStatus === 'function') {
        showEInadStatus('<i class="fas fa-check-circle mr-1"></i> ' + feedback, 'success');
    }

    return true;
}

function initMrzParser() {
    $('#btnParseMrz').off('click').on('click', function () {
        var raw = ($('#mrzInputText').val() || '').trim();
        if (!raw) {
            alert('Lütfen pasaport MRZ kodunu veya 3M çıktı metnini yapıştırın.');
            return;
        }
        var success = parseAndApplyMrz(raw, "Manuel MRZ / Wedge Kodu");
        if (!success) {
            alert('Belge formatı doğrulanamadı. Lütfen standart ICAO MRZ veya 3M çıktı verisini kontrol edin.');
        }
    });
}

/* ==========================================================================
   3M PV40 / PV60 & REGULA DONANIMSAL OPTIK OKUYUCU DINLEYICISI (KEYBOARD WEDGE)
   ========================================================================== */
function tryLocalClientRegulaForEinad(callback) {
    var endpoints = [
        'http://127.0.0.1:41101/api/process',
        'http://127.0.0.1:8080/api/process',
        'http://127.0.0.1:41102/api/process'
    ];

    function tryNext(index) {
        if (index >= endpoints.length) {
            callback(null);
            return;
        }
        var url = endpoints[index];
        $.ajax({
            url: url,
            type: 'POST',
            data: JSON.stringify({ processParam: { scenario: "Mrz" } }),
            contentType: 'application/json',
            timeout: 1200
        }).done(function (data) {
            if (data) callback(data);
            else tryNext(index + 1);
        }).fail(function () {
            $.ajax({
                url: url,
                type: 'GET',
                timeout: 800
            }).done(function (data2) {
                if (data2) callback(data2);
                else tryNext(index + 1);
            }).fail(function () {
                tryNext(index + 1);
            });
        });
    }

    tryNext(0);
}

function extractMrzFromRegulaResponse(data) {
    if (!data) return "";
    if (typeof data === 'string') {
        try { data = JSON.parse(data); } catch (e) { return data; }
    }
    if (data.rawMrz) return data.rawMrz;
    if (data.mrz) return data.mrz;
    if (data.RawMrz) return data.RawMrz;
    if (data.ContainerList && data.ContainerList.List && Array.isArray(data.ContainerList.List)) {
        for (var i = 0; i < data.ContainerList.List.length; i++) {
            var item = data.ContainerList.List[i];
            var t = item.raw_data || item.mrz || item.RawData || item.Text;
            if (t && typeof t === 'string' && t.trim().length >= 25) {
                return t;
            }
        }
    }
    return "";
}

function initHardwareScannerListener() {
    var scannerBuffer = "";
    var lastKeystrokeTime = 0;
    var scannerTimer = null;
    var burstCount = 0;

    $(document).on('keydown', function (e) {
        // Kontrol tuslarini yoksay
        if (e.key === 'Shift' || e.key === 'Control' || e.key === 'Alt' || e.key === 'Meta' || e.key === 'CapsLock') {
            return;
        }

        var now = Date.now();
        var delta = now - lastKeystrokeTime;
        lastKeystrokeTime = now;

        // Donanimsal okuyucular harfleri 5ms - 50ms araliginda yuksek hizda gonderir
        var isFastBurst = (delta <= 50);

        if (isFastBurst) {
            burstCount++;
        } else {
            // Normal insan yazimi araya girdiyse (800ms'den uzun sessizlik) buffer'i temizle
            if (delta > 800) {
                scannerBuffer = "";
                burstCount = 0;
            }
        }

        var key = e.key;
        if (key === 'Enter') {
            scannerBuffer += '\n';
        } else if (key && key.length === 1) {
            scannerBuffer += key;
        }

        // Donanim tarama imzasi veya burst akisi algilandiginda:
        // Odaktaki input alanini scanner verisiyle kirletmemek icin varsayilan yazmayi engelle
        var hasScannerSignature = (
            scannerBuffer.indexOf('START') >= 0 ||
            scannerBuffer.indexOf('Surname:') >= 0 ||
            scannerBuffer.indexOf('Last Name:') >= 0 ||
            scannerBuffer.indexOf('Given Name:') >= 0 ||
            scannerBuffer.indexOf('First Name:') >= 0 ||
            scannerBuffer.indexOf('Doc. Number:') >= 0 ||
            scannerBuffer.indexOf('Soyadı:') >= 0 ||
            scannerBuffer.indexOf('Adı:') >= 0 ||
            scannerBuffer.indexOf('Belge No:') >= 0 ||
            scannerBuffer.indexOf('REGULA') >= 0 ||
            scannerBuffer.indexOf('P<') >= 0 ||
            scannerBuffer.indexOf('I<') >= 0 ||
            scannerBuffer.indexOf('A<') >= 0 ||
            scannerBuffer.indexOf('V<') >= 0
        );

        if ((burstCount >= 2 || hasScannerSignature) && e.target) {
            var tag = (e.target.tagName || '').toUpperCase();
            if ((tag === 'INPUT' || tag === 'TEXTAREA') && e.target.id !== 'mrzInputText') {
                e.preventDefault();
            }
        }

        // 1) OutputWedge END etiketini gonderdiginde aninda islet
        if (/END[\r\n]*$/i.test(scannerBuffer) && scannerBuffer.length >= 25) {
            e.preventDefault();
            clearTimeout(scannerTimer);
            var scanOutput = scannerBuffer;
            scannerBuffer = "";
            burstCount = 0;
            processHardwareScan(scanOutput);
            return false;
        }

        // 2) TD3 2 Satirli Pasaport tamamlandiginda (88+ karakter ve 2 satir)
        var td3Lines = scannerBuffer.split(/[\r\n]+/).filter(function (l) { return l.trim().length >= 40; });
        if (td3Lines.length >= 2 && (td3Lines[0].indexOf('P<') >= 0 || td3Lines[0].indexOf('P') === 0 || td3Lines[0].indexOf('V<') >= 0)) {
            if (td3Lines[1].length >= 44) {
                clearTimeout(scannerTimer);
                var td3Data = scannerBuffer;
                scannerBuffer = "";
                burstCount = 0;
                processHardwareScan(td3Data);
                return;
            }
        }

        // 3) TD1 3 Satirli Kimlik tamamlandiginda (3 satir x 30 karakter)
        var td1Lines = scannerBuffer.split(/[\r\n]+/).filter(function (l) { return l.trim().length >= 28; });
        if (td1Lines.length >= 3 && (td1Lines[0].indexOf('I<') >= 0 || td1Lines[0].indexOf('I') === 0 || td1Lines[0].indexOf('A<') >= 0)) {
            clearTimeout(scannerTimer);
            var td1Data = scannerBuffer;
            scannerBuffer = "";
            burstCount = 0;
            processHardwareScan(td1Data);
            return;
        }

        // Sondaki dinamik debounce zamanlayicisi (donanim akisi durduktan 500ms sonra tetiklenir)
        clearTimeout(scannerTimer);
        scannerTimer = setTimeout(function () {
            if (scannerBuffer.trim().length >= 20) {
                var captured = scannerBuffer;
                scannerBuffer = "";
                burstCount = 0;
                processHardwareScan(captured);
            } else {
                scannerBuffer = "";
                burstCount = 0;
            }
        }, 500);
    });

    function processHardwareScan(capturedText) {
        if (!capturedText || !capturedText.trim()) return;

        var isRecognizable = (
            capturedText.indexOf('START') >= 0 ||
            capturedText.indexOf('Surname:') >= 0 ||
            capturedText.indexOf('Last Name:') >= 0 ||
            capturedText.indexOf('Given Name:') >= 0 ||
            capturedText.indexOf('First Name:') >= 0 ||
            capturedText.indexOf('Doc. Number:') >= 0 ||
            capturedText.indexOf('Document Number:') >= 0 ||
            capturedText.indexOf('Passport Number:') >= 0 ||
            capturedText.indexOf('Personal Number:') >= 0 ||
            capturedText.indexOf('Soyadı:') >= 0 ||
            capturedText.indexOf('Adı:') >= 0 ||
            capturedText.indexOf('P<') >= 0 ||
            capturedText.indexOf('I<') >= 0 ||
            capturedText.length >= 44
        );

        if (!isRecognizable) return;

        // Modal kapaliysa yeni kayit penceresini ac ve modal hazir olunca veriyi doldur
        if (!$('#inadModal').hasClass('show')) {
            window._pendingHardwareScan = capturedText;
            openAdd();
            setTimeout(function () {
                if (window._pendingHardwareScan) {
                    var pending = window._pendingHardwareScan;
                    window._pendingHardwareScan = null;
                    parseAndApplyMrz(pending, "3M / Regula Donanim");
                }
            }, 600);
        } else {
            parseAndApplyMrz(capturedText, "3M / Regula Donanim");
        }
    }
}

/* ==========================================================================
   OPTİK OKUYUCUDAN DOĞRUDAN BELGE TARAMA (3M / REGULA / DESKO)
   ========================================================================== */
function applyScanResultForEinad(res) {
    if (!res) return;

    var docNo = res.documentNumber || res.passportNo || '';
    if (docNo) {
        $('#PasaportNo').val(docNo);
        if (!$('#BelgeNo').val()) $('#BelgeNo').val(docNo);
    }

    var fullName = res.fullName || ((res.surname || '') + ' ' + (res.givenNames || '')).trim();
    if (fullName) $('#AdSoyad').val(fullName);

    var sex = parseSexString(res.sex || res.gender);
    if (sex) $('#Cinsiyet').val(sex);

    var bDate = parseDateString(res.birthDate);
    if (bDate) $('#DogumT').val(bDate);

    if (res.personalNumber) $('#KimlikNo').val(res.personalNumber);

    var country = res.country || res.nationality;
    var matchedCountry = applyCountryToSelect(country);

    var photoB64 = res.visBase64 || res.photoBase64;
    if (photoB64) {
        var imgSrc = photoB64.indexOf('data:image') === 0 ? photoB64 : ('data:image/jpeg;base64,' + photoB64);
        $('#passportPreviewImg').attr('src', imgSrc);
        $('#photoStatusText').text('Görsel optik okuyucudan çekildi.');
        $('#photoFileName').text(res.deviceName || 'Optik Okuyucu');
        $('#passportPreviewContainer').show();
        $('#passportDropzone').hide();
    }

    playScanBeep();

    var devName = res.deviceName || 'Optik Okuyucu';
    var feedback = '✅ ' + devName + ' ile Okundu: ' + (fullName || 'Yolcu') + ' | Belge No: ' + (docNo || '-') + ' | Uyruk: ' + (matchedCountry || country || '-');
    $('#mrzFeedback').text(feedback).show();

    var targetFields = $('#AdSoyad, #PasaportNo, #BelgeNo, #Uyruk, #Cinsiyet, #DogumT, #KimlikNo');
    targetFields.css('transition', 'background-color 0.4s').css('background-color', '#dcfce7');
    setTimeout(function () {
        targetFields.css('background-color', '');
    }, 1800);

    $('#accKimlik').collapse('show');
    $('#accBelge').collapse('show');

    if (typeof showEInadStatus === 'function') {
        showEInadStatus('<i class="fas fa-check-circle mr-1"></i> ' + feedback, 'success');
    }
}

window.scanPassportDirectForEinad = function (deviceType) {
    if (!$('#inadModal').hasClass('show')) {
        if (typeof openAdd === 'function') {
            openAdd();
        } else {
            $('#inadModal').modal('show');
        }
    }

    var btns = $('#btnTopScanPassport, #btnModalScanPassport, #btnTabScanPassport');
    var originalHtmls = [];
    btns.each(function () {
        originalHtmls.push($(this).html());
    });
    btns.prop('disabled', true).html('<i class="fas fa-spinner fa-spin mr-1"></i> Okunuyor...');

    var scanUrl = getEinadUrl('data-url-scan-passport', '/EInad/ScanPassport');

    $.ajax({
        url: scanUrl,
        type: 'POST',
        data: { deviceType: deviceType || 'auto' },
        timeout: 25000,
        success: function (res) {
            btns.each(function (idx) {
                $(this).prop('disabled', false).html(originalHtmls[idx] || '<i class="fas fa-camera mr-1"></i> Cihazdan Pasaport Oku');
            });

            if (res && res.success) {
                applyScanResultForEinad(res);
            } else {
                var msg = (res && res.message) ? res.message : 'Optik okuyucudan belge okunamadı. Lütfen pasaport veya kimliği cihaz camına koyunuz.';
                if (typeof showEInadStatus === 'function') {
                    showEInadStatus('<i class="fas fa-exclamation-triangle mr-1"></i> ' + msg, 'warning');
                } else {
                    alert(msg);
                }
            }
        },
        error: function (xhr, status, err) {
            btns.each(function (idx) {
                $(this).prop('disabled', false).html(originalHtmls[idx] || '<i class="fas fa-camera mr-1"></i> Cihazdan Pasaport Oku');
            });
            var errMsg = 'Optik okuyucu servisiyle iletişim kurulamadı. (' + (err || status) + ')';
            if (typeof showEInadStatus === 'function') {
                showEInadStatus('<i class="fas fa-times-circle mr-1"></i> ' + errMsg, 'danger');
            } else {
                alert(errMsg);
            }
        }
    });
};
/* ==========================================================================
   3M & REGULA OPTIK OKUYUCU BAGLAN & CANLI DURUM YONETIMI
   ========================================================================== */
function update3MStatusUI(isActive, message) {
    var btnModal = $('#btnModalConnect3M');
    var btnTab = $('#btnTabConnect3M');
    var btnTop = $('#btnTopConnect3M');
    var badge = $('.scanner-live-badge');
    var statusMsg = $('#connect3MStatusMessage');
    

    $.ajax({
        url: getEinadUrl('data-url-status-3m', '/EInad/GetOpticalReaderStatus'),
        type: 'GET',
        timeout: 4000
    }).done(function (res) {
        if (res && res.success && res.isRunning) {
            update3MStatusUI(true, (res.deviceName || "Optik Okuyucu") + " aktif ve dinleniyor.");
        } else {
            update3MStatusUI(false);
            if (notifyIfFailed) {
                var msg = "Okuyucu servisi henüz yanıt vermedi. Lütfen 3M veya Regula cihazının USB kablosunun takılı olduğundan emin olun.";
                $('#connect3MStatusMessage').html('<span class="text-danger"><i class="fas fa-exclamation-triangle mr-1"></i> ' + msg + '</span>');
            }
        }
    }).fail(function () {
        update3MStatusUI(false);
    });
};
/* ==========================================================================
   PASAPORT FOTOÄRAFI YÃœKLEME & MRZ AYRIÅTIRMA (DROPZONE & AJAX OCR)
   ========================================================================== */
function initPassportPhotoUpload() {
    var dropzone = $('#passportDropzone');
    var fileInput = $('#passportPhotoInput');

    // Tarayıcının görsel dosyasını yeni sekmede veya doğrudan sayfada açmasını KESİN OLARAK engelle
    window.addEventListener("dragover", function (e) { e.preventDefault(); }, false);
    window.addEventListener("drop", function (e) { e.preventDefault(); }, false);
    $(document).off('dragenter dragover dragleave drop').on('dragenter dragover dragleave drop', function (e) {
        e.preventDefault();
    });

    // Tıklayarak dosya seçme
    dropzone.off('click').on('click', function (e) {
        e.preventDefault();
        e.stopPropagation();
        fileInput.trigger('click');
    });

    $('#btnBrowsePassport').off('click').on('click', function (e) {
        e.preventDefault();
        e.stopPropagation();
        fileInput.trigger('click');
    });

    fileInput.off('click').on('click', function (e) {
        e.stopPropagation();
    });

    // Sürükle-Bırak Olayları
    dropzone.off('dragenter dragover').on('dragenter dragover', function (e) {
        e.preventDefault();
        e.stopPropagation();
        dropzone.addClass('dragover');
    });

    dropzone.off('dragleave dragend').on('dragleave dragend', function (e) {
        e.preventDefault();
        e.stopPropagation();
        dropzone.removeClass('dragover');
    });

    dropzone.off('drop').on('drop', function (e) {
        e.preventDefault();
        e.stopPropagation();
        dropzone.removeClass('dragover');

        var dt = e.originalEvent.dataTransfer;
        if (dt && dt.files && dt.files.length > 0) {
            handlePassportFile(dt.files[0]);
        }
    });

    fileInput.off('change').on('change', function () {
        if (this.files && this.files.length > 0) {
            handlePassportFile(this.files[0]);
        }
    });

    $('#btnRemovePhoto').off('click').on('click', function (e) {
        e.preventDefault();
        e.stopPropagation();
        fileInput.val('');
        $('#passportPreviewContainer').hide();
        $('#passportPreviewImg').attr('src', '');
        $('#photoStatusText').text('');
        $('#photoFileName').text('');
    });

    function handlePassportFile(file) {
        if (!file.type.match('image.*')) {
            alert('Lütfen geçerli bir görsel dosyası (JPG, PNG, WEBP) seçin.');
            return;
        }

        // 1. Görsel önizlemesini hemen göster
        var reader = new FileReader();
        reader.onload = function (e) {
            var dataUrl = e.target.result;
            $('#passportPreviewImg').attr('src', dataUrl);
            $('#photoFileName').text(file.name + ' (' + Math.round(file.size / 1024) + ' KB)');
            $('#photoStatusText').html('<i class="fas fa-spinner fa-spin text-info mr-1"></i> Pasaport fotoğrafı taranıyor, optik karakterler (OCR) okunuyor...');
            $('#passportPreviewContainer').show();
        };
        reader.readAsDataURL(file);

        // 2. Sunucu tarafı Windows OCR servisine gönder
        var formData = new FormData();
        formData.append('file', file);
        formData.append('__RequestVerificationToken', getAntiForgeryToken());

        $.ajax({
            url: getEinadUrl('data-url-scan-image', '/EInad/ScanPassportImage'),
            type: 'POST',
            data: formData,
            contentType: false,
            processData: false,
            success: function (res) {
                if (res && res.success) {
                    var parsed = false;

                    // A) mrz1 ve mrz2 adaylarından ayrıştırmayı dene
                    if (res.mrz1 && res.mrz2) {
                        parsed = parseAndApplyMrz(res.mrz1 + '\n' + res.mrz2, 'Pasaport Fotoğrafı (OCR)');
                    }

                    // B) Olmazsa ham OCR metninin tamamından ayrıştır
                    if (!parsed && res.rawText) {
                        parsed = parseAndApplyMrz(res.rawText, 'Pasaport Fotoğrafı (OCR)');
                    }

                    if (parsed) {
                        $('#photoStatusText').html('<i class="fas fa-check-circle text-success mr-1"></i> MRZ başarıyla okundu ve form alanları dolduruldu!');
                        showEInadStatus('<i class="fas fa-check-circle mr-1"></i> Pasaport fotoğrafından kimlik bilgileri başarıyla aktarıldı.', 'success');
                    } else {
                        $('#photoStatusText').html('<i class="fas fa-exclamation-triangle text-warning mr-1"></i> Görsel yüklendi ancak MRZ satırları net okunamadı. Lütfen ışık ve netliği kontrol edin.');
                        if (res.rawText) {
                            $('#mrzInputText').val(res.rawText);
                            $('#tab-mrz-link').tab('show');
                        }
                    }
                } else {
                    $('#photoStatusText').html('<i class="fas fa-times-circle text-danger mr-1"></i> ' + (res.message || 'Görsel taranamadı.'));
                }
            },
            error: function () {
                $('#photoStatusText').html('<i class="fas fa-times-circle text-danger mr-1"></i> Sunucu hatası oluştu.');
            }
        });
    }
}

/* ==========================================================================
   HIZLI İNAD SEBEP ÇİPLERİ
   ========================================================================== */
function initReasonChips() {
    $('.btn-chip').off('click').on('click', function (e) {
        e.preventDefault();
        var val = $(this).data('val');
        var checkbox = $('input[name="InadSebep"][value="' + val + '"]');

        if (checkbox.length) {
            var isChecked = checkbox.prop('checked');
            checkbox.prop('checked', !isChecked);
            $(this).toggleClass('active', !isChecked);
        }
    });

    $('input[name="InadSebep"]').on('change', function () {
        syncChipsWithCheckboxes();
    });
}

function syncChipsWithCheckboxes() {
    $('.btn-chip').each(function () {
        var val = $(this).data('val');
        var checkbox = $('input[name="InadSebep"][value="' + val + '"]');
        $(this).toggleClass('active', checkbox.is(':checked'));
    });
}

/* =========================
   YENİ KAYIT
========================= */
function openAdd() {
    $('#inadForm').attr('action', getEinadUrl('data-url-add-inad', '/EInad/AddInad'));
    $('#inadModalTitle').text('Yeni İNAD Kaydı Ekle');
    $('#inadForm')[0].reset();
    $('#InadId').val(0);
    $('#mrzInputText').val('');
    $('#mrzFeedback').hide();

    $('input[name="UcagaNakil"]').prop('checked', false);
    $('input[name="InadSebep"]').prop('checked', false);
    $('.btn-chip').removeClass('active');

    $('#TarihSaat').val(getLocalDateTimeForInput());

    refreshAllDropdowns().done(function () {
        $.get(getEinadUrl('data-url-get-border', '/EInad/GetMyBorder'))
            .done(function (res) {
                if (res && res.success) {
                    if (res.border) {
                        $('#Kapi').val(res.border);
                        $('#Valilik').val(res.border.split(' ')[0]);
                    }
                    if (res.sicil) {
                        $('#Personel').val(res.sicil);
                        $('#Sicil').val(res.sicil);
                    }
                }
            })
            .always(function () {
                loadAirlineList();
                $('#accKimlik').collapse('show');
                $('#inadModal').modal('show');
            });
    });
}

/* =========================
   DÜZENLE
========================= */
function openEdit(id) {
    $('#mrzInputText').val('');
    $('#mrzFeedback').hide();

    refreshAllDropdowns().done(function () {
        $.get(getEinadUrl('data-url-get-inad', '/EInad/GetInad'), { id: id }, function (res) {
            if (!res || !res.success) {
                alert("Kayıt bilgileri alınamadı.");
                return;
            }

            var d = res.data || {};

            $('#inadForm').attr('action', getEinadUrl('data-url-edit-inad', '/EInad/EditInad'));
            $('#inadModalTitle').text('İNAD Kaydını Düzenle (ID: #' + d.InadId + ')');

            $('#InadId').val(d.InadId || 0);
            $('#TarihSaat').val(parseMsDateToLocal(d.TarihSaat));
            $('#AdSoyad').val(d.AdSoyad || '');
            $('#DogumT').val(parseMsDateToLocal(d.DogumT, true));
            $('#DogumY').val(d.DogumY || '');
            $('#Cinsiyet').val(d.Cinsiyet || '');

            $('#PasaportNo').val(d.PasaportNo || '');
            $('#BelgeNo').val(d.BelgeNo || '');
            $('#KimlikNo').val(d.KimlikNo || '');

            setTimeout(function () {
                $('#Uyruk').val(d.Uyruk || '').trigger('change');
                $('#PasaportTuru').val(d.PasaportTuru || '').trigger('change');
                $('#Beyan').val(d.Beyan || '').trigger('change');
                $('#Durum').val(d.Durum || '').trigger('change');
            }, 100);

            $('#Kapi').val(d.Kapi || '');
            $('#Valilik').val(d.Valilik || '');

            $('#Personel').val(d.Personel || '');
            $('#Sicil').val(d.Sicil || '');
            $('#OzelGuvenlik').val(d.OzelGuvenlik || '');
            $('#YerHizmetleriPersonel').val(d.YerHizmetleriPersonel || '');
            $('#YerHizmetleri').val(d.YerHizmetleri || '');
            $('#Refakat').val(d.Refakat || '');

            $('#GelenUcusNo').val(d.GelenUcusNo || '');
            $('#GelenHavayolu').val(d.GelenHavayolu || '');
            $('#GeldigiYer').val(d.GeldigiYer || '');
            $('#GeldigiTarihSaat').val(parseMsDateToLocal(d.GeldigiTarihSaat));

            $('#GidisUcusNo').val(d.GidisUcusNo || '');
            $('#GidenHavayolu').val(d.GidenHavayolu || '');
            $('#GidisYer').val(d.GidisYer || '');
            $('#GidisTarihSaat').val(parseMsDateToLocal(d.GidisTarihSaat));

            $('#UstAramaEsya').val(d.UstAramaEsya || '');

            $('input[name="InadSebep"]').prop('checked', false);
            if (d.InadSebep && typeof d.InadSebep === 'string') {
                d.InadSebep.split(',').forEach(function (v) {
                    var val = v.trim();
                    if (val.length) $('input[name="InadSebep"][value="' + val + '"]').prop('checked', true);
                });
            }
            syncChipsWithCheckboxes();

            $('input[name="UcagaNakil"]').prop('checked', false);
            if (d.UcagaNakil && typeof d.UcagaNakil === 'string') {
                d.UcagaNakil.split(',').forEach(function (v) {
                    var val = v.trim();
                    if (val.length) $('input[name="UcagaNakil"][value="' + val + '"]').prop('checked', true);
                });
            }

            loadAirlineList();
            $('#accKimlik').collapse('show');
            $('#inadModal').modal('show');
        });
    });
}

/* =========================
   DROPDOWN YENİLEME
========================= */
function refreshAllDropdowns() {
    var deferred = $.Deferred();

    $.get(getEinadUrl('data-url-get-countries', '/EInad/GetCountries'))
        .done(function (data) {
            if (data && data.success && Array.isArray(data.countries)) {
                var select = $('#Uyruk');
                select.find('option:not(:first)').remove();

                data.countries.forEach(function (country) {
                    select.append($('<option>').val(country).text(country));
                });
            }
            deferred.resolve();
        })
        .fail(function () {
            deferred.resolve();
        });

    return deferred.promise();
}

/* =========================
   SİLME İŞLEMİ
========================= */
function deleteRecord(id) {
    if (!confirm("⚠️ Bu İNAD kaydı kalıcı olarak silinecek.\n\nOnaylıyor musunuz?"))
        return;

    $.ajax({
        url: getEinadUrl('data-url-delete-inad', '/EInad/DeleteInad'),
        type: 'POST',
        data: {
            id: id,
            __RequestVerificationToken: $('input[name="__RequestVerificationToken"]').val()
        },
        success: function (res) {
            if (res.success) {
                location.reload();
            } else {
                alert(res.message || "Silme işlemi başarısız.");
            }
        },
        error: function () {
            alert("Sunucu hatası oluştu.");
        }
    });
}

/* =========================
   DURUM DEĞİŞTİRME - TEK TIKLAMA & ANINDA GÜNCELLEME
========================= */
function toggleStatus(btn) {
    var $btn = $(btn);
    var id = $btn.data('inad-id');
    var newStatus = $btn.data('next-status');

    if (!id || !newStatus) return;

    var confirmMsg = newStatus === 'İnad Odasına Alındı'
        ? "⚠️ Yolcu 'İnad Odasına Alındı' olarak işaretlenecek.\n\nLütfen yolcunun takibini yapınız!\n\nOnaylıyor musunuz?"
        : "Yolcu 'İnad Edildi' olarak işaretlenecek.\n\nOnaylıyor musunuz?";

    if (!confirm(confirmMsg)) return;

    var originalHtml = $btn.html();
    $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> İşleniyor...');

    $.ajax({
        url: getEinadUrl('data-url-update-status', '/EInad/UpdateStatus'),
        type: 'POST',
        data: {
            id: id,
            status: newStatus,
            __RequestVerificationToken: getAntiForgeryToken()
        },
        success: function (res) {
            if (res.success) {
                updateRowStatusBadge($btn, newStatus);

                var message = newStatus === 'İnad Edildi'
                    ? '<i class="fas fa-check-circle"></i> <strong>Yolcu başarıyla "İnad Edildi" olarak işaretlendi.</strong>'
                    : '<i class="fas fa-exclamation-circle"></i> <strong>Yolcu "İnad Odasına Alındı" olarak işaretlendi.</strong> Lütfen sevk takibini yapınız!';

                showEInadStatus(message, newStatus === 'İnad Edildi' ? 'success' : 'warning');

                setTimeout(function () {
                    hideEInadStatus();
                }, 5000);
            } else {
                $btn.prop('disabled', false).html(originalHtml);
                showEInadStatus(
                    '<i class="fas fa-times-circle"></i> ' + (res.message || 'Durum güncelleme başarısız.'),
                    'danger'
                );
            }
        },
        error: function () {
            $btn.prop('disabled', false).html(originalHtml);
            showEInadStatus('<i class="fas fa-times-circle"></i> Sunucu hatası oluştu.', 'danger');
        }
    });
}

function updateRowStatusBadge($btn, newStatus) {
    if (newStatus === 'İnad Edildi') {
        $btn
            .removeClass('status-odada status-diger blink')
            .addClass('status-edildi')
            .data('next-status', 'İnad Odasına Alındı')
            .attr('aria-label', "Durumu 'İnad Odasına Alındı' yapmak için tıklayın")
            .attr('title', "Durumu 'İnad Odasına Alındı' yapmak için tıklayın")
            .prop('disabled', false)
            .html('<i class="fas fa-check-circle"></i> İnad Edildi');
    } else {
        $btn
            .removeClass('status-edildi status-diger')
            .addClass('status-odada blink')
            .data('next-status', 'İnad Edildi')
            .attr('aria-label', "Durumu 'İnad Edildi' yapmak için tıklayın")
            .attr('title', "Durumu 'İnad Edildi' yapmak için tıklayın")
            .prop('disabled', false)
            .html('<i class="fas fa-exclamation-circle"></i> İnad Odasına Alındı');
    }
}

/* =========================
   FORM VALİDASYON
========================= */
function validateInadForm() {
    hideEInadStatus();

    var missing = [];
    var requiredFields = [
        { selector: '#TarihSaat', label: 'Tarih Saat' },
        { selector: '#AdSoyad', label: 'Ad Soyad' },
        { selector: '#Uyruk', label: 'Uyruk' },
        { selector: '#PasaportNo', label: 'Pasaport No' }
    ];

    $('.is-invalid').removeClass('is-invalid');

    requiredFields.forEach(function (field) {
        var input = $(field.selector);
        if (!input.val()) {
            input.addClass('is-invalid');
            missing.push(field.label);
        }
    });

    if ($('input[name="InadSebep"]:checked').length === 0) {
        missing.push('En az bir İNAD sebebi');
        $('#accInad').collapse('show');
    }

    if (missing.length > 0) {
        var warningMsg = '<i class="fas fa-exclamation-triangle"></i> <strong>Lütfen zorunlu alanları doldurun:</strong> ' + missing.join(', ') + '.';
        showEInadStatus(warningMsg, 'warning');
        var firstInvalid = $('.is-invalid').first();
        if (firstInvalid.length) {
            firstInvalid.closest('.collapse').collapse('show');
            firstInvalid.focus();
        }
        return false;
    }

    var durum = $('#Durum').val();
    if (durum === 'İnad Odasına Alındı') {
        var alertMsg = '<i class="fas fa-exclamation-circle"></i> <strong>⚠️ ÖNEMLİ UYARI:</strong> Yolcu "İnad Odasına Alındı" durumundadır. Lütfen sevk takibini yapınız!';
        showEInadStatus(alertMsg, 'warning');
    }

    $('#saveButton').prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Kaydediliyor...');
    return true;
}

function getDataTableTurkishLanguage() {
    return {
        emptyTable: 'Tabloda kayıt bulunmuyor',
        info: '_TOTAL_ kayıttan _START_ - _END_ arası gösteriliyor',
        infoEmpty: 'Kayıt yok',
        infoFiltered: '(_MAX_ kayıt içinden filtrelendi)',
        lengthMenu: 'Sayfada _MENU_ kayıt göster',
        loadingRecords: 'Yükleniyor...',
        processing: 'İşleniyor...',
        search: 'Tabloda Filtrele:',
        zeroRecords: 'Eşleşen kayıt bulunamadı',
        paginate: {
            first: 'İlk',
            last: 'Son',
            next: 'Sonraki',
            previous: 'Önceki'
        },
        aria: {
            sortAscending: ': artan sıralama',
            sortDescending: ': azalan sıralama'
        }
    };
}

/* =========================
   SAYFA YÜKLENDİĞİNDE
========================= */
$(function () {
    if ($.fn.DataTable) {
        $('#inad-table').DataTable({
            "pageLength": 25,
            "order": [],
            "language": getDataTableTurkishLanguage()
        });
    }

    initUyrukChange();
    loadAirlineList();
    initUcusNoToAirline();
    initHavayoluManualCheck();
    initMrzParser();
    initReasonChips();
    initHardwareScannerListener();
    window.check3MStatus();
    initPassportPhotoUpload();

    // Durum badge'lerine event delegation
    $(document).off('click', '.inad-status-btn:not(.status-diger)')
               .on('click', '.inad-status-btn:not(.status-diger)', function (e) {
        e.preventDefault();
        toggleStatus(this);
    });

    $('#inadModal').on('show.bs.modal', function () {
        hideEInadStatus();
        $('#saveButton').prop('disabled', false).html('<i class="fas fa-save mr-1"></i> Kaydet');
        loadAirlineList();
    });

    $('#inadModal').on('shown.bs.modal', function () {
        if (window._pendingHardwareScan) {
            var pending = window._pendingHardwareScan;
            window._pendingHardwareScan = null;
            parseAndApplyMrz(pending, "3M PV40 / PV60 Donanım");
        }
    });

    $('#inadForm').off('submit').on('submit', validateInadForm);
});
