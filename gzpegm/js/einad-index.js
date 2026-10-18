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
   MRZ (MACHINE READABLE ZONE) & 3M OPTİK OKUYUCU ENTEGRASYONU
   ========================================================================== */
var _isoCountryMap = {
    'AFG': 'Afganistan', 'ALB': 'Arnavutluk', 'DZA': 'Cezayir', 'AND': 'Andorra', 'AGO': 'Angola',
    'ARG': 'Arjantin', 'ARM': 'Ermenistan', 'AUS': 'Avustralya', 'AUT': 'Avusturya', 'AZE': 'Azerbaycan',
    'BHR': 'Bahreyn', 'BGD': 'Bangladeş', 'BLR': 'Belarus', 'BEL': 'Belçika', 'BIH': 'Bosna-Hersek',
    'BRA': 'Brezilya', 'BGR': 'Bulgaristan', 'CAN': 'Kanada', 'CHN': 'Çin', 'HRV': 'Hırvatistan',
    'CZE': 'Çek Cumhuriyeti', 'DNK': 'Danimarka', 'EGY': 'Mısır', 'FIN': 'Finlandiya', 'FRA': 'Fransa',
    'GEO': 'Gürcistan', 'DEU': 'Almanya', 'GRC': 'Yunanistan', 'HUN': 'Macaristan', 'IND': 'Hindistan',
    'IDN': 'Endonezya', 'IRN': 'İran', 'IRQ': 'Irak', 'IRL': 'İrlanda', 'ISR': 'İsrail',
    'ITA': 'İtalya', 'JPN': 'Japonya', 'JOR': 'Ürdün', 'KAZ': 'Kazakistan', 'KWT': 'Kuveyt',
    'KGZ': 'Kırgızistan', 'LBN': 'Liban', 'LBY': 'Libya', 'MDA': 'Moldovya', 'MAR': 'Fas',
    'NLD': 'Hollanda', 'MKD': 'Kuzey Makedonya', 'NOR': 'Norveç', 'PAK': 'Pakistan', 'POL': 'Polonya',
    'PRT': 'Portekiz', 'QAT': 'Katar', 'ROU': 'Romanya', 'RUS': 'Rusya', 'SAU': 'Suudi Arabistan',
    'SRB': 'Sırbistan', 'SVK': 'Slovakya', 'SVN': 'Slovenya', 'ESP': 'İspanya', 'SWE': 'İsveç',
    'CHE': 'İsviçre', 'SYR': 'Suriye', 'TJK': 'Tacikistan', 'TUN': 'Tunus', 'TUR': 'Türkiye',
    'TKM': 'Türkmenistan', 'UKR': 'Ukrayna', 'ARE': 'Birleşik Arap Emirlikleri', 'GBR': 'İngiltere',
    'USA': 'Amerika Birleşik Devletleri', 'UZB': 'Özbekistan', 'SOM': 'Somali', 'SDN': 'Sudan',
    'YEM': 'Yemen', 'NGA': 'Nijerya', 'GHA': 'Gana', 'ETH': 'Etiyopya', 'KEN': 'Kenya',
    'LBN': 'Lübnan', 'DZA': 'Cezayir', 'MAR': 'Fas', 'EGY': 'Mısır', 'IRQ': 'Irak', 'IRN': 'İran'
};

function playScanBeep() {
    try {
        var AudioContext = window.AudioContext || window.webkitAudioContext;
        if (!AudioContext) return;
        var audioCtx = new AudioContext();
        var osc = audioCtx.createOscillator();
        var gain = audioCtx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(880, audioCtx.currentTime);
        gain.gain.setValueAtTime(0.12, audioCtx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.15);
        osc.connect(gain);
        gain.connect(audioCtx.destination);
        osc.start();
        osc.stop(audioCtx.currentTime + 0.15);
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

function parseAndApplyMrz(rawText, sourceName) {
    if (!rawText || !rawText.trim()) return false;

    var cleanText = rawText.replace(/\r/g, '\n').replace(/\t/g, '\n');
    var rawLines = cleanText.split('\n')
        .map(function (s) { return cleanOcrMrzLine(s.trim()); })
        .filter(function (s) { return s.length >= 10; });

    var line1 = "";
    var line2 = "";

    // 1. Durum: Satırlar arasında P< veya I< ile başlayan satırı ve ardından gelen satırı bul
    for (var idx = 0; idx < rawLines.length; idx++) {
        var cur = rawLines[idx];
        if (cur.indexOf('P<') === 0 || cur.indexOf('I<') === 0 || cur.indexOf('P') === 0 || cur.indexOf('I') === 0) {
            line1 = cur;
            if (idx + 1 < rawLines.length) {
                line2 = rawLines[idx + 1];
            }
            break;
        }
    }

    // 2. Durum: Eğer tek satırda peş peşe 88 karakter geldiyse (Donanımsal Okuyucu Tek Parça Gönderimi)
    if (!line1 && cleanText.length >= 80) {
        var compact = cleanOcrMrzLine(cleanText);
        var pIdx = compact.indexOf('P<');
        if (pIdx < 0) pIdx = compact.indexOf('I<');
        if (pIdx >= 0 && compact.length >= pIdx + 80) {
            line1 = compact.substr(pIdx, 44);
            line2 = compact.substr(pIdx + 44, 44);
        }
    }

    // 3. Durum: Ham satırlardan son iki satırı dene
    if (!line1 && rawLines.length >= 2) {
        line1 = rawLines[rawLines.length - 2];
        line2 = rawLines[rawLines.length - 1];
    } else if (!line1 && rawLines.length === 1) {
        line1 = rawLines[0];
    }

    if (!line1 && !line2) return false;

    var surname = "";
    var givenNames = "";
    var passportNo = "";
    var nationalityCode = "";
    var birthDateStr = "";
    var sex = "";

    // TD3 / TD2 / TD1 Line 1 İsim Ayrıştırma
    if (line1) {
        var namePart = "";
        var issuingState = "";

        if (line1.indexOf('P<') === 0 || line1.indexOf('I<') === 0) {
            issuingState = line1.substr(2, 3).replace(/[<]/g, '').trim();
            namePart = line1.substr(5);
        } else if (line1.indexOf('P') === 0 || line1.indexOf('I') === 0) {
            issuingState = line1.substr(1, 3).replace(/[<]/g, '').trim();
            namePart = line1.substr(4);
        } else {
            namePart = line1;
        }

        var normalizedNamePart = namePart.replace(/[\uFFFD«»‹›\(\)\{\}\[\]]/g, '<');

        // Soyad ve Adları çift veya daha fazla chevron (<<) ile ayır
        var primaryParts = normalizedNamePart.split(/<{2,}/).filter(function (p) {
            return p.replace(/</g, '').trim().length > 0;
        });

        if (primaryParts.length >= 1) {
            surname = primaryParts[0].replace(/<+/g, ' ').replace(/[^A-ZÇĞİÖŞÜ\s]/g, ' ').replace(/\s+/g, ' ').trim();
        }
        if (primaryParts.length >= 2) {
            givenNames = primaryParts[1].replace(/<+/g, ' ').replace(/[^A-ZÇĞİÖŞÜ\s]/g, ' ').replace(/\s+/g, ' ').trim();
        }

        // Çift chevron okunamadıysa tek chevron (<) ile bölmeyi dene
        if (!givenNames && normalizedNamePart.indexOf('<') >= 0) {
            var singleParts = normalizedNamePart.split(/<+/).map(function (s) {
                return s.replace(/[^A-ZÇĞİÖŞÜ\s]/g, ' ').replace(/\s+/g, ' ').trim();
            }).filter(function (s) { return s.length > 0; });

            if (singleParts.length >= 1) surname = singleParts[0];
            if (singleParts.length >= 2) givenNames = singleParts.slice(1).join(' ');
        }
    }

    // TD3 Line 2 Ayrıştırma (Belge No, Uyruk, Doğum Tarihi, Cinsiyet)
    if (line2 && line2.length >= 20) {
        passportNo = line2.substr(0, 9).replace(/[<«»‹›\uFFFD]/g, '').trim();
        nationalityCode = line2.substr(10, 3).replace(/[<«»‹›\uFFFD]/g, '').trim();
        var dobRaw = line2.substr(13, 6); // YYMMDD
        var sexRaw = line2.substr(20, 1).toUpperCase();

        if (sexRaw === 'M') sex = 'Erkek';
        else if (sexRaw === 'F') sex = 'Bayan';

        // OCR kaynaklı rakam-harf karışıklıklarını düzelt (O->0, I->1, S->5, B->8, Z->2)
        dobRaw = dobRaw.replace(/O/g, '0').replace(/I/g, '1').replace(/S/g, '5').replace(/B/g, '8').replace(/Z/g, '2');

        if (/^\d{6}$/.test(dobRaw)) {
            var yy = parseInt(dobRaw.substr(0, 2), 10);
            var mm = dobRaw.substr(2, 2);
            var dd = dobRaw.substr(4, 2);
            var currentYearShort = new Date().getFullYear() % 100;
            var fullYear = (yy > currentYearShort ? 1900 : 2000) + yy;
            birthDateStr = fullYear + '-' + mm + '-' + dd;
        }
    }

    var fullName = (surname + ' ' + givenNames).trim();
    if (!fullName && !passportNo) return false;

    if (fullName) $('#AdSoyad').val(fullName);
    if (passportNo) $('#PasaportNo').val(passportNo);
    if (sex) $('#Cinsiyet').val(sex);
    if (birthDateStr) $('#DogumT').val(birthDateStr);

    var matchedCountry = _isoCountryMap[nationalityCode] || 
                         (line1 && line1.length >= 5 ? _isoCountryMap[line1.substr(2, 3)] : null) ||
                         (line1 && line1.length >= 3 ? _isoCountryMap[line1.substr(0, 3)] : null);

    if (matchedCountry) {
        var foundOpt = false;
        $('#Uyruk').find('option').each(function () {
            var optVal = $(this).val();
            if (optVal && (optVal.toLowerCase() === matchedCountry.toLowerCase() ||
                optVal.toLowerCase().indexOf(matchedCountry.toLowerCase()) >= 0 ||
                matchedCountry.toLowerCase().indexOf(optVal.toLowerCase()) >= 0)) {
                $('#Uyruk').val(optVal).trigger('change');
                foundOpt = true;
                return false;
            }
        });
        if (!foundOpt) {
            $('#Uyruk').append($('<option selected></option>').val(matchedCountry).text(matchedCountry)).trigger('change');
        }
    }

    // Başarı Sesi ve Bildirimi
    playScanBeep();

    var sourceLabel = sourceName ? ' (' + sourceName + ')' : '';
    var feedback = '✅ Pasaport Başarıyla Okundu' + sourceLabel + ': ' + fullName + ' | Pasaport: ' + (passportNo || '-') + ' | Uyruk: ' + (matchedCountry || nationalityCode || '-');
    $('#mrzFeedback').text(feedback).show();

    // Alanları yeşil parıltıyla vurgula
    $('#AdSoyad, #PasaportNo, #Uyruk, #Cinsiyet, #DogumT').css('transition', 'background-color 0.4s').css('background-color', '#dcfce7');
    setTimeout(function () {
        $('#AdSoyad, #PasaportNo, #Uyruk, #Cinsiyet, #DogumT').css('background-color', '');
    }, 1500);

    $('#accKimlik').collapse('show');
    $('#mrzInputText').val(cleanOcrMrzLine(line1) + (line2 ? '\n' + cleanOcrMrzLine(line2) : ''));

    return true;
}

function initMrzParser() {
    $('#btnParseMrz').off('click').on('click', function () {
        var raw = ($('#mrzInputText').val() || '').trim();
        if (!raw) {
            alert('Lütfen pasaport MRZ kodunu yapıştırın.');
            return;
        }
        var success = parseAndApplyMrz(raw, "Manuel MRZ Kodu");
        if (!success) {
            alert('MRZ formatı doğrulanamadı. Lütfen en az 2 satırlı standart ICAO MRZ kodunu kontrol edin.');
        }
    });
}

/* ==========================================================================
   3M PV40 / PV60 DONANIMSAL OPTİK OKUYUCU DİNLEYİCİSİ (KEYBOARD WEDGE)
   ========================================================================== */
function initHardwareScannerListener() {
    var scannerBuffer = "";
    var lastKeystrokeTime = 0;
    var scannerTimer = null;

    $(document).on('keypress', function (e) {
        var now = Date.now();
        var delta = now - lastKeystrokeTime;
        lastKeystrokeTime = now;

        var char = String.fromCharCode(e.which);

        if (delta > 150 && scannerBuffer.indexOf('P<') === -1 && scannerBuffer.indexOf('I<') === -1) {
            scannerBuffer = "";
        }

        if (e.which === 13) {
            if (scannerBuffer.length >= 44 && (scannerBuffer.indexOf('P<') >= 0 || scannerBuffer.indexOf('I<') >= 0)) {
                e.preventDefault();
                processHardwareScan(scannerBuffer);
                scannerBuffer = "";
                return false;
            }
        } else {
            scannerBuffer += char;

            clearTimeout(scannerTimer);
            scannerTimer = setTimeout(function () {
                if (scannerBuffer.length >= 88 && (scannerBuffer.indexOf('P<') >= 0 || scannerBuffer.indexOf('I<') >= 0)) {
                    processHardwareScan(scannerBuffer);
                    scannerBuffer = "";
                }
            }, 120);
        }
    });

    function processHardwareScan(capturedText) {
        if (!$('#inadModal').hasClass('show')) {
            openAdd();
            setTimeout(function () {
                parseAndApplyMrz(capturedText, "3M PV40 / PV60 Donanım");
            }, 300);
        } else {
            parseAndApplyMrz(capturedText, "3M PV40 / PV60 Donanım");
        }
    }
}

/* ==========================================================================
   PASAPORT FOTOĞRAFI YÜKLEME & MRZ AYRIŞTIRMA (DROPZONE & AJAX OCR)
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

    $('#inadForm').off('submit').on('submit', validateInadForm);
});
