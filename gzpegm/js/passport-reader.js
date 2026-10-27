/**
 * CEZAM - Pasaport & Optik Okuyucu Entegrasyon Modülü
 * Desteklenen Donanımlar: 3M Cogent / Gemalto (PV40, PV60, AT9000), Regula (70X4, 7024), Desko (Penta, BRS)
 * Desteklenen Formatlar: ICAO 9303 MRZ (TD1, TD2, TD3), 3M & Regula Key-Value Wedge, Fotoğraf / Belge OCR
 */

(function ($) {
    'use strict';

    /* ==========================================================================
       1. ISO 3166-1 ÜLKE KODU EŞLEŞTİRME TABLOSU (TÜRKÇE SEÇENEK UYUMLU)
       ========================================================================== */
    var _isoCountryMap = {
        'TUR': 'Türkiye', 'DEU': 'Almanya', 'GBR': 'Birleşik Krallık', 'RUS': 'Rusya Federasyonu',
        'UKR': 'Ukrayna', 'USA': 'Amerika Birleşik Devletleri', 'FRA': 'Fransa', 'NLD': 'Hollanda',
        'BEL': 'Belçika', 'AUT': 'Avusturya', 'CHE': 'İsviçre', 'SWE': 'İsveç', 'NOR': 'Norveç',
        'DNK': 'Danimarka', 'FIN': 'Finlandiya', 'POL': 'Polonya', 'CZE': 'Çek Cumhuriyeti',
        'ROU': 'Romanya', 'BGR': 'Bulgaristan', 'GRC': 'Yunanistan', 'ITA': 'İtalya', 'ESP': 'İspanya',
        'PRT': 'Portekiz', 'AZE': 'Azerbaycan', 'KAZ': 'Kazakistan', 'UZB': 'Özbekistan',
        'KGZ': 'Kırgızistan', 'TKM': 'Türkmenistan', 'TJK': 'Tacikistan', 'GEO': 'Gürcistan',
        'ARM': 'Ermenistan', 'MDA': 'Moldovya Cumhuriyeti', 'BLR': 'Beyaz Rusya', 'IRN': 'İran',
        'IRQ': 'Irak', 'SYR': 'Suriye', 'LBN': 'Lübnan', 'JOR': 'Ürdün', 'ISR': 'İsrail',
        'SAU': 'Suudi Arabistan', 'ARE': 'Birleşik Arap Emirlikleri', 'KWT': 'Kuveyt', 'QAT': 'Katar',
        'BHR': 'Bahreyn', 'OMN': 'Umman', 'EGY': 'Mısır', 'LBY': 'Libya', 'TUN': 'Tunus',
        'DZA': 'Cezayir', 'MAR': 'Fas', 'SDN': 'Sudan', 'SOM': 'Somali', 'ETH': 'Etiyopya',
        'KEN': 'Kenya', 'NGA': 'Nijerya', 'GHA': 'Gana', 'ZAF': 'Güney Afrika', 'IND': 'Hindistan',
        'PAK': 'Pakistan', 'BGD': 'Bangladeş', 'AFG': 'Afganistan', 'CHN': 'Çin', 'JPN': 'Japonya',
        'KOR': 'Güney Kore', 'IDN': 'Endonezya', 'MYS': 'Malezya', 'PHL': 'Filipinler', 'THA': 'Tayland',
        'VNM': 'Vietnam', 'AUS': 'Avustralya', 'CAN': 'Kanada', 'BRA': 'Brezilya', 'ARG': 'Arjantin',
        'MEX': 'Meksika', 'COL': 'Kolombiya', 'SRB': 'Sırbistan', 'BIH': 'Bosna Hersek', 'HRV': 'Hırvatistan',
        'MKD': 'Makedonya', 'ALB': 'Arnavutluk', 'MNE': 'Karadağ', 'KOS': 'Kosova', 'HUN': 'Macaristan',
        'SVK': 'Slovakya', 'SVN': 'Slovenya', 'IRL': 'İrlanda', 'CYP': 'Kıbrıs', 'MLT': 'Malta',
        'LTU': 'Litvanya', 'LVA': 'Letonya', 'EST': 'Estonya', 'ISL': 'İzlanda', 'MNG': 'Moğolistan',
        'YEM': 'Yemen', 'SGP': 'Singapur', 'NZL': 'Yeni Zelanda'
    };

    /* ==========================================================================
       2. SESLİ VE GÖRSEL BİLDİRİM YARDIMCILARI
       ========================================================================== */
    function playScanBeep() {
        try {
            var AudioCtx = window.AudioContext || window.webkitAudioContext;
            if (!AudioCtx) return;
            var ctx = new AudioCtx();
            if (ctx.state === 'suspended') {
                ctx.resume();
            }
            var osc = ctx.createOscillator();
            var gain = ctx.createGain();
            osc.type = 'sine';
            osc.frequency.setValueAtTime(880, ctx.currentTime); // A5 nota
            gain.gain.setValueAtTime(0.15, ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.18);
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.start();
            osc.stop(ctx.currentTime + 0.18);
        } catch (e) { }
    }

    function showPassportToast(message, type) {
        var isSuccess = (type !== 'danger' && type !== 'error');
        var bg = isSuccess ? '#059669' : '#dc2626';
        var icon = isSuccess ? 'fa-check-circle' : 'fa-exclamation-triangle';

        var toast = $(
            '<div class="passport-toast shadow-lg text-white d-flex align-items-center" style="position:fixed; bottom:25px; right:25px; z-index:9999; background:' + bg + '; padding:14px 20px; border-radius:10px; font-size:0.95rem; font-weight:600; box-shadow:0 10px 25px rgba(0,0,0,0.25); animation:toastSlideIn 0.3s ease;">' +
            '<i class="fas ' + icon + ' mr-2" style="font-size:1.3rem;"></i>' +
            '<div>' + message + '</div>' +
            '</div>'
        );

        $('body').append(toast);
        setTimeout(function () {
            toast.fadeOut(400, function () { $(this).remove(); });
        }, 4500);
    }

    function highlightInput(selector) {
        var el = $(selector);
        if (!el.length) return;
        el.addClass('passport-field-highlight');
        setTimeout(function () {
            el.removeClass('passport-field-highlight');
        }, 2200);
    }

    /* ==========================================================================
       3. METİN FORMATLAMA VE TARİH DÖNÜŞÜMÜ
       ========================================================================== */
    function toTitleCase(str) {
        if (!str) return "";
        return str.replace(/\w\S*/g, function (txt) {
            return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
        });
    }

    function cleanMrzStr(str) {
        if (!str) return "";
        return str.replace(/</g, " ").replace(/\s+/g, " ").trim();
    }

    function parseMrzDate(dateStr) {
        if (!dateStr || dateStr.length < 6) return "";
        var yy = parseInt(dateStr.substring(0, 2), 10);
        var mm = dateStr.substring(2, 4);
        var dd = dateStr.substring(4, 6);
        if (isNaN(yy)) return "";

        var curYear2Digit = new Date().getFullYear() % 100;
        var fullYear = (yy <= curYear2Digit) ? (2000 + yy) : (1900 + yy);

        var d = parseInt(dd, 10);
        var m = parseInt(mm, 10);
        if (d < 1 || d > 31 || m < 1 || m > 12) return "";

        return (d < 10 ? '0' + d : d) + "." + (m < 10 ? '0' + m : m) + "." + fullYear;
    }

    function setPassportCountry(countryCodeOrName) {
        if (!countryCodeOrName) return "";
        var target = countryCodeOrName.trim().toUpperCase();
        var mappedName = _isoCountryMap[target] || countryCodeOrName.trim();
        if (!mappedName) return "";

        var foundVal = null;
        var targetLower = mappedName.toLowerCase();

        // 1. Birebir eşleşme
        $('#CountryCalculate option').each(function () {
            var val = $(this).val();
            if (!val) return;
            if (val.toLowerCase() === targetLower) {
                foundVal = val;
                return false;
            }
        });

        // 2. Başlangıç eşleşmesi
        if (!foundVal) {
            $('#CountryCalculate option').each(function () {
                var val = $(this).val();
                if (!val) return;
                var optLower = val.toLowerCase();
                if (optLower.indexOf(targetLower) === 0 || targetLower.indexOf(optLower) === 0) {
                    foundVal = val;
                    return false;
                }
            });
        }

        // 3. İçerme eşleşmesi (örn: "Rusya" -> "Rusya Federasyonu")
        if (!foundVal) {
            $('#CountryCalculate option').each(function () {
                var val = $(this).val();
                if (!val) return;
                var optLower = val.toLowerCase();
                if (optLower.indexOf(targetLower) >= 0 || targetLower.indexOf(optLower) >= 0) {
                    foundVal = val;
                    return false;
                }
            });
        }

        if (foundVal) {
            $('#CountryCalculate').val(foundVal).trigger('change');
            highlightInput('#CountryCalculate');
            return foundVal;
        }

        return "";
    }

    /* ==========================================================================
       4. DOĞRUDAN DONANIM TARAMASI (3M COGENT, REGULA, DESKO)
       ========================================================================== */
    var isDirectScanActive = false;

    function triggerDirectOpticalScan(deviceType) {
        if (isDirectScanActive) return;
        isDirectScanActive = true;

        var btns = $('#btnDirectOpticalScan, #btnModalDirectScan');
        var originalHtml = btns.first().html();

        btns.prop('disabled', true).html('<span class="spinner-border spinner-border-sm mr-1" role="status"></span> Okunuyor...');

        var statusEl = $('#passportReaderStatus');
        statusEl.html(
            '<div class="alert alert-info py-2 px-3 mb-0 d-flex align-items-center">' +
            '<div class="spinner-border spinner-border-sm text-primary mr-2" role="status"></div>' +
            '<div><strong>3M / Regula / Desko taranıyor:</strong> Pasaport veya kimlik verileri okunuyor, lütfen bekleyin...</div>' +
            '</div>'
        );

        $.ajax({
            url: '/Calculate/ScanOpticalReader',
            type: 'POST',
            data: { deviceType: deviceType || 'auto' },
            timeout: 20000,
            success: function (res) {
                isDirectScanActive = false;
                btns.prop('disabled', false).html(originalHtml);

                if (res && res.success) {
                    // Yolcu Adı Soyadı
                    if (res.fullName) {
                        $('#NameCFORM').val(res.fullName);
                        highlightInput('#NameCFORM');
                    }

                    // Belge / Pasaport Numarası
                    if (res.documentNumber) {
                        $('#PassportCFORM').val(res.documentNumber);
                        highlightInput('#PassportCFORM');
                    }

                    // YKN / Kimlik Numarası
                    if (res.personalNumber) {
                        $('#IDNCFORM').val(res.personalNumber);
                        highlightInput('#IDNCFORM');
                    }

                    // Pasaport Türü (1: Umuma Mahsus, 2: Diplomatik, 3: Servis, vb.)
                    var docTypeVal = "1";
                    if (res.documentType) {
                        var dtLower = res.documentType.toLowerCase();
                        if (dtLower.indexOf('diplomatik') >= 0) docTypeVal = "2";
                        else if (dtLower.indexOf('servis') >= 0) docTypeVal = "3";
                        else if (dtLower.indexOf('hizmet') >= 0) docTypeVal = "4";
                    }
                    if ($('#PassportCalculate').length) {
                        $('#PassportCalculate').val(docTypeVal).trigger('change');
                        highlightInput('#PassportCalculate');
                    }

                    // Uyruk / Ülke Seçimi (Otomatik vize ve harç hesaplatır)
                    var matchedCountry = "";
                    if (res.country) {
                        matchedCountry = setPassportCountry(res.country);
                    }

                    // Doğum Tarihi & Yaş Grubu
                    if (res.birthDate) {
                        $('#BirthDateCalculate').val(res.birthDate).trigger('change');
                        $('#BirthdateCFORM').val(res.birthDate);
                        highlightInput('#BirthDateCalculate');

                        if (typeof window.adultchild === 'function') {
                            window.adultchild($('#BirthDateCalculate')[0]);
                        }
                    }

                    // Görsel Önizleme
                    if (res.visBase64) {
                        $('#passportDocPreview').attr('src', 'data:image/jpeg;base64,' + res.visBase64).removeClass('hidden').show();
                    }

                    // Sesli ve görsel bildirim
                    playScanBeep();

                    var detailSummary = (res.fullName || 'Yolcu') +
                        (res.documentNumber ? ' (' + res.documentNumber + ')' : '') +
                        (matchedCountry ? ' - ' + matchedCountry : (res.country ? ' - ' + res.country : ''));

                    showPassportToast(
                        '<strong>✓ ' + (res.deviceName || 'Optik Okuyucu') + ' ile Okundu:</strong><br>' + detailSummary +
                        (res.birthDate ? '<div class="small mt-1 opacity-90"><i class="fas fa-birthday-cake mr-1"></i> Doğum: ' + res.birthDate + '</div>' : ''),
                        'success'
                    );

                    statusEl.html(
                        '<div class="alert alert-success py-2 px-3 mb-0">' +
                        '<i class="fas fa-check-circle mr-2"></i> <strong>Cihazdan başarıyla okundu:</strong><br>' + detailSummary +
                        '</div>'
                    );

                    setTimeout(function () {
                        $('#passportReaderModal').modal('hide');
                    }, 1400);

                } else {
                    var errMsg = (res && res.message) ? res.message : 'Optik okuyucudan belge okunamadı. Lütfen belgeyi camın üzerine yerleştiriniz.';
                    statusEl.html(
                        '<div class="alert alert-warning py-2 px-3 mb-0">' +
                        '<i class="fas fa-exclamation-triangle mr-2"></i> ' + errMsg +
                        '</div>'
                    );
                    showPassportToast(errMsg, 'danger');
                }
            },
            error: function (xhr, status, err) {
                isDirectScanActive = false;
                btns.prop('disabled', false).html(originalHtml);
                var errMsg = 'Optik okuyucu servisiyle iletişim kurulamadı. (' + (err || status) + ')';
                statusEl.html(
                    '<div class="alert alert-danger py-2 px-3 mb-0">' +
                    '<i class="fas fa-times-circle mr-2"></i> ' + errMsg +
                    '</div>'
                );
                showPassportToast(errMsg, 'danger');
            }
        });
    }

    function checkOpticalReaderStatus() {
        $.ajax({
            url: '/Calculate/GetOpticalReaderStatus',
            type: 'GET',
            cache: false,
            success: function (res) {
                if (res && res.success && res.isRunning) {
                    $('#opticalHardwareBadge')
                        .removeClass('badge-warning badge-secondary')
                        .addClass('badge-success')
                        .html('<span class="passport-pulse-dot"></span> ' + (res.deviceName || 'Optik Okuyucu') + ' Hazır');

                    $('#opticalStatusBanner')
                        .removeClass('alert-warning alert-secondary')
                        .addClass('alert-success')
                        .html(
                            '<div class="d-flex align-items-center justify-content-between">' +
                            '<div><span class="passport-pulse-dot"></span> <strong>' + (res.deviceName || '3M / Regula') + ' Bağlı ve Hazır:</strong> Pasaportu camın üzerine koyup <strong>"Cihazdan Oku"</strong> butonuna basınız.</div>' +
                            '<span class="badge badge-success px-2 py-1">Aktif</span>' +
                            '</div>'
                        );
                } else {
                    $('#opticalHardwareBadge')
                        .removeClass('badge-success')
                        .addClass('badge-warning')
                        .html('<i class="fas fa-plug mr-1"></i> Okuyucu Bağlantısı Bekleniyor');

                    $('#opticalStatusBanner')
                        .removeClass('alert-success')
                        .addClass('alert-warning')
                        .html(
                            '<div class="d-flex align-items-center justify-content-between">' +
                            '<div><i class="fas fa-info-circle mr-1"></i> Optik okuyucu hazır değilse <strong>"Cihaza Bağlan"</strong> butonuna basabilir veya pasaport fotoğrafını yükleyebilirsiniz.</div>' +
                            '<button type="button" class="btn btn-xs btn-outline-dark" onclick="window.PassportReader.connectDevice();">Bağlan</button>' +
                            '</div>'
                        );
                }
            }
        });
    }

    function connectDevice(deviceType) {
        var statusEl = $('#passportReaderStatus');
        statusEl.html(
            '<div class="text-center py-2 text-primary font-weight-bold">' +
            '<div class="spinner-border spinner-border-sm text-primary mr-2" role="status"></div>' +
            'Optik okuyucu başlatılıyor, lütfen bekleyin...' +
            '</div>'
        );

        $.ajax({
            url: '/Calculate/ConnectOpticalReader',
            type: 'POST',
            data: { deviceType: deviceType || 'auto' },
            success: function (res) {
                if (res && res.success) {
                    showPassportToast(res.message || 'Okuyucu hazır.', 'success');
                    checkOpticalReaderStatus();
                } else {
                    showPassportToast(res.message || 'Cihaza bağlanılamadı.', 'danger');
                }
            }
        });
    }

    /* ==========================================================================
       5. ICAO MRZ & WEDGE AYRIŞTIRMA VE CEZA FORMUNA AKTARMA (FALLBACK / WEDGE)
       ========================================================================== */
    function parseAndApplyPassportMrz(rawText, sourceName) {
        if (!rawText || !rawText.trim()) return false;

        var surname = "";
        var givenNames = "";
        var passportNo = "";
        var nationalityCode = "";
        var birthDateStr = "";
        var kimlikNo = "";
        var docType = "1";
        var parsedSuccessfully = false;

        // A. 3M, Regula veya Desko Key-Value Wedge Formatı
        var hasWedgeKeys = /(?:Surname|Last\s*Name|Family\s*Name|Forenames?|Given\s*Names?|First\s*Names?|Doc\.?\s*(?:Number|No)|Passport\s*(?:Number|No)?|Date\s*of\s*Birth|Birth\s*Date|DOB|Nationality|Country|Personal\s*No)/i.test(rawText);
        if (hasWedgeKeys) {
            var lines = rawText.split(/[\r\n]+/);
            for (var i = 0; i < lines.length; i++) {
                var l = lines[i].trim();
                if (!l) continue;

                var mSurname = /^(?:Surname|Last\s*Name|Family\s*Name)\s*[:=]\s*(.+)$/i.exec(l);
                if (mSurname) surname = mSurname[1].trim();

                var mGiven = /^(?:Forenames?|Given\s*Names?|First\s*Names?|Name)\s*[:=]\s*(.+)$/i.exec(l);
                if (mGiven && !mSurname) givenNames = mGiven[1].trim();

                var mDoc = /^(?:Doc\.?\s*(?:Number|No)|Document\s*(?:Number|No)?|Passport\s*(?:Number|No)?)\s*[:=]\s*(.+)$/i.exec(l);
                if (mDoc) passportNo = mDoc[1].trim().replace(/\s+/g, '');

                var mNat = /^(?:Nationality|Country|Issuing\s*State)\s*[:=]\s*(.+)$/i.exec(l);
                if (mNat) nationalityCode = mNat[1].trim();

                var mDob = /^(?:Date\s*of\s*Birth|Birth\s*Date|DOB)\s*[:=]\s*(.+)$/i.exec(l);
                if (mDob) {
                    var rawDob = mDob[1].trim();
                    if (/^\d{2}[./-]\d{2}[./-]\d{4}$/.test(rawDob)) {
                        birthDateStr = rawDob.replace(/[-/]/g, '.');
                    } else if (/^\d{4}[./-]\d{2}[./-]\d{2}$/.test(rawDob)) {
                        var dp = rawDob.split(/[-./]/);
                        birthDateStr = dp[2] + '.' + dp[1] + '.' + dp[0];
                    } else if (/^\d{6}$/.test(rawDob)) {
                        birthDateStr = parseMrzDate(rawDob);
                    }
                }

                var mPid = /^(?:Personal\s*No|National\s*ID|ID\s*No|Personal\s*Number)\s*[:=]\s*(.+)$/i.exec(l);
                if (mPid) kimlikNo = mPid[1].trim().replace(/</g, '').trim();
            }

            if (surname || givenNames || passportNo) {
                parsedSuccessfully = true;
            }
        }

        // B. Standart ICAO 9303 MRZ
        if (!parsedSuccessfully) {
            var rawLines = rawText.split(/[\r\n]+/);
            var mrzLines = [];

            for (var j = 0; j < rawLines.length; j++) {
                var lineClean = rawLines[j].toUpperCase().replace(/\s+/g, '');
                lineClean = lineClean.replace(/[«»‹›]/g, '<');
                lineClean = lineClean.replace(/[{}[\]()]/g, '<');

                if (lineClean.length >= 26 && /^[A-Z0-9<]+$/.test(lineClean)) {
                    mrzLines.push(lineClean);
                }
            }

            // B.1. TD3 Formatı: 2 Satır x 44 Karakter (Pasaportlar)
            if (mrzLines.length >= 2) {
                for (var k = 0; k < mrzLines.length - 1; k++) {
                    var l1 = mrzLines[k];
                    var l2 = mrzLines[k + 1];

                    if (l1.length >= 40 && l2.length >= 40 && (l1.charAt(0) === 'P' || l1.charAt(0) === 'V')) {
                        var subType = l1.substring(0, 2);
                        if (subType === 'PD' || subType === 'D<') docType = "2";
                        else if (subType === 'PS' || subType === 'S<') docType = "3";
                        else docType = "1";

                        nationalityCode = l1.substring(2, 5).replace(/</g, '');

                        var namePart = l1.substring(5);
                        var nameSplit = namePart.split('<<');
                        surname = cleanMrzStr(nameSplit[0] || "");
                        givenNames = cleanMrzStr(nameSplit[1] || "");

                        passportNo = l2.substring(0, 9).replace(/</g, '');
                        if (!nationalityCode || nationalityCode.length < 3) {
                            nationalityCode = l2.substring(10, 13).replace(/</g, '');
                        }

                        var dobRaw = l2.substring(13, 19);
                        birthDateStr = parseMrzDate(dobRaw);

                        var optData = l2.substring(28, 42).replace(/</g, '').trim();
                        if (optData.length >= 5 && /^\d+$/.test(optData)) {
                            kimlikNo = optData;
                        }

                        parsedSuccessfully = true;
                        break;
                    }
                }
            }

            // B.2. TD1 Formatı: 3 Satır x 30 Karakter (Kimlik Kartları)
            if (!parsedSuccessfully && mrzLines.length >= 3) {
                for (var m = 0; m < mrzLines.length - 2; m++) {
                    var t1 = mrzLines[m];
                    var t2 = mrzLines[m + 1];
                    var t3 = mrzLines[m + 2];

                    if (t1.length >= 28 && t2.length >= 28 && t3.length >= 28 && (t1.charAt(0) === 'I' || t1.charAt(0) === 'A' || t1.charAt(0) === 'C')) {
                        nationalityCode = t1.substring(2, 5).replace(/</g, '');
                        passportNo = t1.substring(5, 14).replace(/</g, '');

                        var idOpt = t1.substring(15, 30).replace(/</g, '').trim();
                        if (idOpt) kimlikNo = idOpt;

                        var dobRaw1 = t2.substring(0, 6);
                        birthDateStr = parseMrzDate(dobRaw1);

                        var nameParts = t3.split('<<');
                        surname = cleanMrzStr(nameParts[0] || "");
                        givenNames = cleanMrzStr(nameParts[1] || "");

                        parsedSuccessfully = true;
                        break;
                    }
                }
            }
        }

        if (!parsedSuccessfully) {
            return false;
        }

        var fullName = (surname + " " + givenNames).trim();

        if (fullName) {
            $('#NameCFORM').val(fullName);
            highlightInput('#NameCFORM');
        }

        if (passportNo) {
            $('#PassportCFORM').val(passportNo);
            highlightInput('#PassportCFORM');
        }

        if (kimlikNo) {
            $('#IDNCFORM').val(kimlikNo);
            highlightInput('#IDNCFORM');
        }

        if (docType && $('#PassportCalculate').length) {
            $('#PassportCalculate').val(docType).trigger('change');
            highlightInput('#PassportCalculate');
        }

        var matchedCountry = "";
        if (nationalityCode) {
            matchedCountry = setPassportCountry(nationalityCode);
        }

        if (birthDateStr) {
            $('#BirthDateCalculate').val(birthDateStr).trigger('change');
            $('#BirthdateCFORM').val(birthDateStr);
            highlightInput('#BirthDateCalculate');

            if (typeof window.adultchild === 'function') {
                window.adultchild($('#BirthDateCalculate')[0]);
            }
        }

        playScanBeep();

        var detailSummary = (fullName ? fullName : 'Yolcu') +
            (passportNo ? ' (' + passportNo + ')' : '') +
            (matchedCountry ? ' - ' + matchedCountry : (nationalityCode ? ' - ' + nationalityCode : ''));

        showPassportToast(
            '<strong>✓ Belge Okundu:</strong> ' + detailSummary +
            (birthDateStr ? '<div class="small mt-1 opacity-90"><i class="fas fa-birthday-cake mr-1"></i> Doğum: ' + birthDateStr + '</div>' : ''),
            'success'
        );

        var modalStatus = $('#passportReaderStatus');
        if (modalStatus.length) {
            modalStatus.html(
                '<div class="alert alert-success py-2 px-3 mb-0">' +
                '<i class="fas fa-check-circle mr-2"></i> <strong>' + (sourceName || 'Okuyucu') + ' ile başarıyla okundu:</strong><br>' +
                detailSummary +
                '</div>'
            );
            setTimeout(function () {
                $('#passportReaderModal').modal('hide');
            }, 1200);
        }

        return true;
    }

    /* ==========================================================================
       6. DONANIM OKUYUCU DİNLEYİCİSİ (KEYBOARD WEDGE)
       ========================================================================== */
    function initHardwareScannerListener() {
        var buffer = '';
        var lastCharTime = 0;
        var MAX_KEY_INTERVAL = 45;

        $(window).on('keydown', function (e) {
            var activeTag = document.activeElement ? document.activeElement.tagName.toLowerCase() : '';
            if (activeTag === 'textarea' && document.activeElement.id === 'manualMrzInput') {
                return;
            }

            var now = Date.now();
            var charCode = e.which || e.keyCode;
            var charStr = e.key;

            if (buffer.length > 0 && (now - lastCharTime > MAX_KEY_INTERVAL)) {
                buffer = '';
            }
            lastCharTime = now;

            if (charCode === 13) {
                if (buffer.length >= 20) {
                    var isMrzOrWedge = (
                        buffer.indexOf('P<') >= 0 ||
                        buffer.indexOf('I<') >= 0 ||
                        buffer.indexOf('A<') >= 0 ||
                        buffer.indexOf('Surname') >= 0 ||
                        buffer.indexOf('Doc') >= 0 ||
                        buffer.indexOf('<<') >= 0 ||
                        /^[A-Z0-9<]{24,}$/i.test(buffer.replace(/[\r\n\s]/g, ''))
                    );

                    if (isMrzOrWedge) {
                        e.preventDefault();
                        e.stopPropagation();

                        var scannedData = buffer;
                        buffer = '';

                        var applied = parseAndApplyPassportMrz(scannedData, '3M / Regula / Desko (Wedge)');
                        if (!applied) {
                            showPassportToast('Optik okuyucu verisi alındı fakat format çözülemedi.', 'danger');
                        }
                        return false;
                    }
                }
                buffer = '';
                return;
            }

            if (charStr && charStr.length === 1) {
                buffer += charStr;

                if (buffer.length >= 15 && (buffer.indexOf('P<') === 0 || buffer.indexOf('I<') === 0 || buffer.indexOf('Surname') === 0)) {
                    if (activeTag === 'input' && document.activeElement.id !== 'manualMrzInput') {
                        e.preventDefault();
                    }
                }
            }
        });
    }

    /* ==========================================================================
       7. PASAPORT FOTOĞRAFI YÜKLEME VE OCR
       ========================================================================== */
    function initPassportPhotoUpload() {
        $(document).on('change', '#passportFileInput', function () {
            if (this.files && this.files[0]) {
                uploadAndProcessPassportImage(this.files[0]);
                $(this).val('');
            }
        });

        var dropzone = $('#passportDropzone');
        if (dropzone.length) {
            dropzone.on('dragover dragenter', function (e) {
                e.preventDefault();
                e.stopPropagation();
                $(this).addClass('dragover');
            });

            dropzone.on('dragleave dragend drop', function (e) {
                e.preventDefault();
                e.stopPropagation();
                $(this).removeClass('dragover');
            });

            dropzone.on('drop', function (e) {
                var dt = e.originalEvent.dataTransfer;
                if (dt && dt.files && dt.files.length) {
                    uploadAndProcessPassportImage(dt.files[0]);
                }
            });
        }

        $(window).on('paste', function (e) {
            if (document.activeElement && document.activeElement.id === 'manualMrzInput') {
                return;
            }

            var clipboardData = e.originalEvent.clipboardData || window.clipboardData;
            if (!clipboardData || !clipboardData.items) return;

            var items = clipboardData.items;
            for (var i = 0; i < items.length; i++) {
                if (items[i].type.indexOf('image') !== -1) {
                    var blob = items[i].getAsFile();
                    if (blob) {
                        e.preventDefault();
                        uploadAndProcessPassportImage(blob);
                        break;
                    }
                }
            }
        });

        $(document).on('click', '#btnParseManualMrz', function () {
            var txt = $('#manualMrzInput').val();
            if (!txt || !txt.trim()) {
                showPassportToast('Lütfen çözümlenecek MRZ veya okuyucu metnini yapıştırın.', 'danger');
                return;
            }
            var ok = parseAndApplyPassportMrz(txt, 'Manuel MRZ');
            if (!ok) {
                showPassportToast('MRZ metni çözümlenemedi. Lütfen satırları kontrol edin.', 'danger');
            }
        });
    }

    function uploadAndProcessPassportImage(file) {
        if (!file) return;

        var statusEl = $('#passportReaderStatus');
        statusEl.html(
            '<div class="text-center py-2 text-primary font-weight-bold">' +
            '<div class="spinner-border spinner-border-sm text-primary mr-2" role="status"></div>' +
            'Pasaport görseli taranıyor ve MRZ çözümleniyor, lütfen bekleyin...' +
            '</div>'
        );

        var formData = new FormData();
        formData.append('file', file);

        $.ajax({
            url: '/Calculate/ScanPassportImage',
            type: 'POST',
            data: formData,
            processData: false,
            contentType: false,
            success: function (res) {
                if (res && res.success) {
                    var parsed = false;

                    if (res.mrz1 && res.mrz2) {
                        parsed = parseAndApplyPassportMrz(res.mrz1 + '\n' + res.mrz2, 'Pasaport Fotoğrafı (OCR)');
                    }

                    if (!parsed && res.rawText) {
                        parsed = parseAndApplyPassportMrz(res.rawText, 'Pasaport Fotoğrafı (OCR)');
                    }

                    if (parsed) {
                        statusEl.html('<div class="alert alert-success py-2 px-3 mb-0"><i class="fas fa-check-circle mr-1"></i> Pasaport fotoğrafından kimlik bilgileri başarıyla aktarıldı!</div>');
                    } else {
                        statusEl.html('<div class="alert alert-warning py-2 px-3 mb-0"><i class="fas fa-exclamation-triangle mr-1"></i> Görsel yüklendi ancak MRZ satırları net okunamadı. Lütfen ışık ve netliği kontrol ediniz.</div>');
                        if (res.rawText) {
                            $('#manualMrzInput').val(res.rawText);
                            $('#tab-manual-link').tab('show');
                        }
                    }
                } else {
                    statusEl.html('<div class="alert alert-danger py-2 px-3 mb-0"><i class="fas fa-times-circle mr-1"></i> ' + (res.message || 'Görsel taranamadı.') + '</div>');
                }
            },
            error: function () {
                statusEl.html('<div class="alert alert-danger py-2 px-3 mb-0"><i class="fas fa-times-circle mr-1"></i> Sunucu hatası oluştu.</div>');
            }
        });
    }

    /* ==========================================================================
       8. SAYFA BAŞLATMA
       ========================================================================== */
    $(document).ready(function () {
        initHardwareScannerListener();
        initPassportPhotoUpload();
        checkOpticalReaderStatus();

        // Buton tıklamaları
        $(document).on('click', '#btnDirectOpticalScan, #btnModalDirectScan', function (e) {
            e.preventDefault();
            triggerDirectOpticalScan('auto');
        });

        $('#passportReaderModal').on('shown.bs.modal', function () {
            checkOpticalReaderStatus();
        });

        // Global export
        window.PassportReader = {
            scanDevice: triggerDirectOpticalScan,
            connectDevice: connectDevice,
            checkStatus: checkOpticalReaderStatus,
            parseAndApply: parseAndApplyPassportMrz,
            setCountry: setPassportCountry,
            showToast: showPassportToast
        };
    });

})(jQuery);
