/**
 * CEZAM - Pasaport & Optik Okuyucu Entegrasyon Modülü
 * Desteklenen Donanımlar: 3M Cogent / Gemalto (PV40, PV60, AT9000), Regula (70X4, 7024), Desko (Penta, BRS)
 * Not: Bu sistemde yalnızca yabancı yolculara ihlal cezası uygulanır. Türk vatandaşlarına ceza işlemi uygulanmaz.
 */

(function ($) {
    'use strict';

    /* ==========================================================================
       1. ISO 3166-1 ÜLKE KODU EŞLEŞTİRME TABLOSU (TÜRKÇE SEÇENEK UYUMLU)
       ========================================================================== */
    var _isoCountryMap = {
        'DEU': 'Almanya', 'D': 'Almanya',
        'GBR': 'Birleşik Krallık', 'UK': 'Birleşik Krallık',
        'RUS': 'Rusya Federasyonu', 'RU': 'Rusya Federasyonu',
        'UKR': 'Ukrayna', 'UA': 'Ukrayna',
        'USA': 'Amerika Birleşik Devletleri', 'US': 'Amerika Birleşik Devletleri',
        'FRA': 'Fransa', 'NLD': 'Hollanda', 'BEL': 'Belçika',
        'AUT': 'Avusturya', 'CHE': 'İsviçre', 'SWE': 'İsveç',
        'NOR': 'Norveç', 'DNK': 'Danimarka', 'FIN': 'Finlandiya',
        'POL': 'Polonya', 'CZE': 'Çek Cumhuriyeti', 'ROU': 'Romanya',
        'BGR': 'Bulgaristan', 'GRC': 'Yunanistan', 'ITA': 'İtalya',
        'ESP': 'İspanya', 'PRT': 'Portekiz', 'AZE': 'Azerbaycan',
        'KAZ': 'Kazakistan', 'UZB': 'Özbekistan', 'KGZ': 'Kırgızistan',
        'TKM': 'Türkmenistan', 'TJK': 'Tacikistan', 'GEO': 'Gürcistan',
        'ARM': 'Ermenistan', 'MDA': 'Moldovya Cumhuriyeti', 'BLR': 'Beyaz Rusya',
        'IRN': 'İran', 'IRQ': 'Irak', 'SYR': 'Suriye', 'LBN': 'Lübnan',
        'JOR': 'Ürdün', 'ISR': 'İsrail', 'SAU': 'Suudi Arabistan',
        'ARE': 'Birleşik Arap Emirlikleri', 'KWT': 'Kuveyt', 'QAT': 'Katar',
        'BHR': 'Bahreyn', 'OMN': 'Umman', 'EGY': 'Mısır', 'LBY': 'Libya',
        'TUN': 'Tunus', 'DZA': 'Cezayir', 'MAR': 'Fas', 'SDN': 'Sudan',
        'SOM': 'Somali', 'ETH': 'Etiyopya', 'KEN': 'Kenya', 'NGA': 'Nijerya',
        'GHA': 'Gana', 'ZAF': 'Güney Afrika', 'IND': 'Hindistan', 'PAK': 'Pakistan',
        'BGD': 'Bangladeş', 'AFG': 'Afganistan', 'CHN': 'Çin', 'JPN': 'Japonya',
        'KOR': 'Güney Kore', 'IDN': 'Endonezya', 'MYS': 'Malezya', 'PHL': 'Filipinler',
        'THA': 'Tayland', 'VNM': 'Vietnam', 'AUS': 'Avustralya', 'CAN': 'Kanada',
        'BRA': 'Brezilya', 'ARG': 'Arjantin', 'MEX': 'Meksika', 'COL': 'Kolombiya',
        'SRB': 'Sırbistan', 'BIH': 'Bosna Hersek', 'HRV': 'Hırvatistan',
        'MKD': 'Makedonya', 'ALB': 'Arnavutluk', 'MNE': 'Karadağ', 'KOS': 'Kosova',
        'HUN': 'Macaristan', 'SVK': 'Slovakya', 'SVN': 'Slovenya', 'IRL': 'İrlanda',
        'CYP': 'Kıbrıs', 'MLT': 'Malta', 'LTU': 'Litvanya', 'LVA': 'Letonya',
        'EST': 'Estonya', 'ISL': 'İzlanda', 'MNG': 'Moğolistan', 'YEM': 'Yemen',
        'SGP': 'Singapur', 'NZL': 'Yeni Zelanda'
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
            osc.frequency.setValueAtTime(880, ctx.currentTime);
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
            '<div class="passport-toast shadow-lg text-white d-flex align-items-center" style="position:fixed; bottom:25px; right:25px; z-index:99999; background:' + bg + '; padding:14px 20px; border-radius:10px; font-size:0.95rem; font-weight:600; box-shadow:0 10px 25px rgba(0,0,0,0.25); animation:toastSlideIn 0.3s ease; max-width:480px;">' +
            '<i class="fas ' + icon + ' mr-2" style="font-size:1.3rem;"></i>' +
            '<div>' + message + '</div>' +
            '</div>'
        );

        $('body').append(toast);
        setTimeout(function () {
            toast.fadeOut(400, function () { $(this).remove(); });
        }, 5500);
    }

    function showPassportAlert(message, type) {
        showPassportToast(message, type);

        var alertEl = $('#opticalScanAlert');
        if (alertEl.length) {
            var alertClass = (type === 'danger' || type === 'error') ? 'alert-danger' : ((type === 'warning') ? 'alert-warning' : 'alert-success');
            var icon = (type === 'danger' || type === 'error') ? 'fa-exclamation-triangle' : ((type === 'warning') ? 'fa-info-circle' : 'fa-check-circle');
            alertEl.html(
                '<div class="alert ' + alertClass + ' py-2 px-3 mb-2 font-weight-bold d-flex align-items-center justify-content-between shadow-sm" style="border-radius:8px; font-size:0.92rem;">' +
                '<div><i class="fas ' + icon + ' mr-2"></i>' + message + '</div>' +
                '<button type="button" class="close text-dark ml-2" onclick="$(\'#opticalScanAlert\').slideUp();" style="font-size:1.2rem; line-height:1;">&times;</button>' +
                '</div>'
            ).slideDown(200);

            setTimeout(function () {
                alertEl.slideUp(400);
            }, 8000);
        }
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

        // Türk vatandaşı kontrolü
        if (target === 'TUR' || target === 'TR' || target === 'TÜRKİYE' || target === 'TURKEY') {
            if ($('#CountryCalculate').length && $('#CountryCalculate option[value="Türkiye"]').length === 0) {
                $('#CountryCalculate').append(new Option('Türkiye (Test Modu)', 'Türkiye', true, true));
            }
            if ($('#CountryCalculate').length) {
                $('#CountryCalculate').val('Türkiye').trigger('change');
            }
            return "Türkiye";
        }

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

    function applyScanResult(res) {
        if (!res) {
            showPassportAlert('Optik okuyucudan yanıt alınamadı.', 'danger');
            return;
        }

        if (res.success) {
            // 1. Türk Vatandaşı Bilgilendirmesi (Test amacıyla form doldurulur)
            if (res.isTurkishCitizen || (res.countryCode && (res.countryCode === 'TUR' || res.countryCode === 'TR'))) {
                showPassportAlert(
                    '<strong>BİLGİ / TEST MODU (TUR):</strong> Türk vatandaşı belgesi okundu. Test amacıyla tüm alanlar başarıyla dolduruldu.',
                    'info'
                );
            }

            // 2. Yabancı Yolcu Adı Soyadı
            if (res.fullName) {
                $('#NameCFORM').val(res.fullName);
                highlightInput('#NameCFORM');
            }

            // 3. Belge / Pasaport Numarası
            if (res.documentNumber) {
                $('#PassportCFORM').val(res.documentNumber);
                highlightInput('#PassportCFORM');
            }

            // 4. Kimlik / Kişisel No
            if (res.personalNumber) {
                $('#IDNCFORM').val(res.personalNumber);
                highlightInput('#IDNCFORM');
            }

            // 5. Pasaport Türü (1: Umuma Mahsus, 2: Diplomatik, 3: Servis, vb.)
            var docTypeCode = res.docTypeCode || "1";
            if ($('#PassportCalculate').length) {
                $('#PassportCalculate').val(docTypeCode).trigger('change');
                highlightInput('#PassportCalculate');
            }

            // 6. Uyruk / Ülke Seçimi (Otomatik vize ve harç hesaplatır)
            var matchedCountry = "";
            if (res.country || res.countryCode) {
                matchedCountry = setPassportCountry(res.country || res.countryCode);
            }

            // 7. Doğum Tarihi & Yaş Grubu
            if (res.birthDate) {
                $('#BirthDateCalculate').val(res.birthDate).trigger('change');
                $('#BirthdateCFORM').val(res.birthDate);
                highlightInput('#BirthDateCalculate');

                if (typeof window.adultchild === 'function') {
                    window.adultchild($('#BirthDateCalculate')[0]);
                }
            }

            // 8. Yetişkin / Çocuk Durumu
            if (res.adultCode && $('#AdultCalculate').length) {
                $('#AdultCalculate').val(res.adultCode).trigger('change');
                highlightInput('#AdultCalculate');
            }

            // Sesli ve görsel bildirim
            playScanBeep();

            var detailSummary = (res.fullName || 'Yabancı Yolcu') +
                (res.documentNumber ? ' (' + res.documentNumber + ')' : '') +
                (matchedCountry && matchedCountry !== 'TUR' ? ' - ' + matchedCountry : (res.country ? ' - ' + res.country : ''));

            showPassportAlert(
                '<strong>Pasaport Okundu (' + (res.deviceName || 'Optik Okuyucu') + '):</strong> ' + detailSummary +
                (res.birthDate ? ' | Doğum: ' + res.birthDate : ''),
                'success'
            );

        } else {
            var errMsg = res.message ? res.message : 'Optik okuyucudan pasaport okunamadı. Lütfen pasaportu cihaz camına yerleştiriniz.';
            showPassportAlert(errMsg, 'warning');
        }
    }

    var isRemoteClient = (window.location.hostname !== 'localhost' && window.location.hostname !== '127.0.0.1');

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

    function tryLocalClientRegula(callback) {
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

    function triggerDirectOpticalScan(deviceType) {
        if (isDirectScanActive) return;
        isDirectScanActive = true;

        var btns = $('#btnDirectOpticalScan, #btnPanelDirectScan');
        var originalHtmls = [];
        btns.each(function () {
            originalHtmls.push($(this).html());
        });

        btns.prop('disabled', true).html('<span class="spinner-border spinner-border-sm mr-1" role="status"></span> Okunuyor...');

        // Doğrudan C# backend servisine bağlan (Regula, 3M veya Desko otomatik taranır)
        $.ajax({
            url: '/Calculate/ScanOpticalReader',
            type: 'POST',
            data: { deviceType: deviceType || 'auto' },
            timeout: 25000,
            success: function (res) {
                applyScanResult(res);
            },
            error: function (xhr, status, err) {
                var errMsg = 'Optik okuyucu servisiyle iletişim kurulamadı. (' + (err || status) + ')';
                showPassportAlert(errMsg, 'danger');
            },
            complete: function () {
                isDirectScanActive = false;
                btns.each(function (idx) {
                    $(this).prop('disabled', false).html(originalHtmls[idx] || '<span class="passport-pulse-dot mr-1"></span> <i class="fas fa-camera mr-1"></i> Cihazdan Pasaport Oku');
                });
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
                    $('#btnDirectOpticalScan, #btnPanelDirectScan').attr('title', (res.deviceName || 'Optik Okuyucu') + ' Bağlı ve Hazır');
                }
            }
        });
    }

    function connectDevice(deviceType) {
        

        $.ajax({
            url: '/Calculate/ConnectOpticalReader',
            type: 'POST',
            data: { deviceType: deviceType || 'auto' },
            success: function (res) {
                if (res && res.success) {
                    showPassportAlert(res.message || 'Optik okuyucu hazır.', 'success');
                    checkOpticalReaderStatus();
                } else {
                    showPassportAlert(res.message || 'Cihaza bağlanılamadı.', 'danger');
                }
            }
        });
    }

    /* ==========================================================================
       5. ICAO MRZ & WEDGE AYRIŞTIRMA VE CEZA FORMUNA AKTARMA (KEYBOARD WEDGE FALLBACK)
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
                lineClean = lineClean.replace(/[^A-Z0-9<]/g, '<');

                if (lineClean.length >= 26 && /^[A-Z0-9<]+$/.test(lineClean)) {
                    mrzLines.push(lineClean);
                }
            }

            // Tek parca 80+ karakter geldiyse (satir basi olmadan 88 karakterlik TD3 veya 90 karakterlik TD1)
            if (mrzLines.length === 1 && mrzLines[0].length >= 80) {
                var single = mrzLines[0];
                if (single.indexOf('P<') >= 0 || single.indexOf('P') === 0 || single.indexOf('V<') >= 0) {
                    var pIdx = Math.max(0, single.indexOf('P<'));
                    mrzLines = [single.substr(pIdx, 44), single.substr(pIdx + 44, 44)];
                } else if (single.indexOf('I<') >= 0 || single.indexOf('I') === 0 || single.indexOf('A<') >= 0) {
                    var iIdx = Math.max(0, single.indexOf('I<'));
                    mrzLines = [single.substr(iIdx, 30), single.substr(iIdx + 30, 30), single.substr(iIdx + 60, 30)];
                }
            }

            // B.1. TD3 Formatı: 2 Satır x 44 Karakter (Yabancı Pasaportlar)
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
                        if (optData.length >= 5) {
                            kimlikNo = optData;
                        }

                        parsedSuccessfully = true;
                        break;
                    }
                }
            }

            // B.2. TD1 Formatı: 3 Satır x 30 Karakter (Yabancı Kimlik & İkamet Kartları)
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
                        surname = cleanMrzWord(nameParts[0] || "");
                        givenNames = cleanMrzWord(nameParts[1] || "");

                        parsedSuccessfully = true;
                        break;
                    }
                }
            }
        }

        if (!parsedSuccessfully) {
            return false;
        }

        // TÜRK VATANDAŞI KONTROLÜ (Bu sistemde Türklere ceza işlemi uygulanmaz!)
        var natUpper = (nationalityCode || '').trim().toUpperCase();
        if (natUpper === 'TUR' || natUpper === 'TR') {
            showPassportAlert(
                '<strong>TÜRK VATANDAŞI (TUR):</strong> Bu sistemde yalnızca yabancı yolculara vize/ihlal cezası uygulanmaktadır. Türk vatandaşlarına ceza işlemi uygulanamaz.',
                'danger'
            );
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

        var detailSummary = (fullName ? fullName : 'Yabancı Yolcu') +
            (passportNo ? ' (' + passportNo + ')' : '') +
            (matchedCountry ? ' - ' + matchedCountry : (nationalityCode ? ' - ' + nationalityCode : ''));

        showPassportAlert(
            '<strong>Pasaport Okundu (' + (sourceName || 'Okuyucu') + '):</strong> ' + detailSummary +
            (birthDateStr ? ' | Doğum: ' + birthDateStr : ''),
            'success'
        );

        return true;
    }

    function cleanMrzWord(raw) {
        if (!raw) return "";
        return raw.replace(/</g, " ").replace(/\s+/g, " ").trim();
    }

    /* ==========================================================================
       6. DONANIM OKUYUCU DİNLEYİCİSİ (KEYBOARD WEDGE LISTENER)
       ========================================================================== */
    function initHardwareScannerListener() {
        var scannerBuffer = "";
        var lastKeystrokeTime = 0;
        var scannerTimer = null;
        var burstCount = 0;

        $(document).on('keydown', function (e) {
            // Kontrol tuşlarını atla
            if (e.key === 'Shift' || e.key === 'Control' || e.key === 'Alt' || e.key === 'Meta' || e.key === 'CapsLock') {
                return;
            }

            var now = Date.now();
            var delta = now - lastKeystrokeTime;
            lastKeystrokeTime = now;

            // Donanımsal okuyucular harfleri 5ms - 50ms aralığında yüksek hızda gönderir
            var isFastBurst = (delta <= 50);
            if (isFastBurst) {
                burstCount++;
            } else {
                // Normal manuel klavye yazımı araya girdiyse (800ms'den uzun boşluk) buffer'ı sıfırla
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

            // Donanım tarama imzası algılama
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

            // Odaktaki input alanını donanım verisiyle kirletmemek için varsayılan yazmayı engelle
            if ((burstCount >= 2 || hasScannerSignature) && e.target) {
                var tag = (e.target.tagName || '').toUpperCase();
                if (tag === 'INPUT' || tag === 'TEXTAREA') {
                    e.preventDefault();
                }
            }

            // 1) 3M Wedge END etiketi tespiti
            if (/END[\r\n]*$/i.test(scannerBuffer) && scannerBuffer.length >= 25) {
                e.preventDefault();
                clearTimeout(scannerTimer);
                var outputWedge = scannerBuffer;
                scannerBuffer = "";
                burstCount = 0;
                parseAndApplyPassportMrz(outputWedge, "3M PV40/PV60 Donanım");
                return false;
            }

            // 2) TD3 Pasaport tamamlandığında (2 satır x 44 karakter)
            var td3Lines = scannerBuffer.split(/[\r\n]+/).filter(function (l) { return l.trim().length >= 40; });
            if (td3Lines.length >= 2 && (td3Lines[0].indexOf('P<') >= 0 || td3Lines[0].indexOf('P') === 0 || td3Lines[0].indexOf('V<') >= 0)) {
                if (td3Lines[1].length >= 44) {
                    clearTimeout(scannerTimer);
                    var td3Data = scannerBuffer;
                    scannerBuffer = "";
                    burstCount = 0;
                    parseAndApplyPassportMrz(td3Data, "3M / Regula Pasaport Okuyucu");
                    return;
                }
            }

            // 3) TD1 Kimlik tamamlandığında (3 satır x 30 karakter)
            var td1Lines = scannerBuffer.split(/[\r\n]+/).filter(function (l) { return l.trim().length >= 28; });
            if (td1Lines.length >= 3 && (td1Lines[0].indexOf('I<') >= 0 || td1Lines[0].indexOf('I') === 0 || td1Lines[0].indexOf('A<') >= 0)) {
                clearTimeout(scannerTimer);
                var td1Data = scannerBuffer;
                scannerBuffer = "";
                burstCount = 0;
                parseAndApplyPassportMrz(td1Data, "3M / Regula Kimlik Okuyucu");
                return;
            }

            // Debounce zamanlayıcısı (500ms): tüm satırların ve tuş serilerinin tamamlanmasını bekler
            clearTimeout(scannerTimer);
            scannerTimer = setTimeout(function () {
                if (scannerBuffer.trim().length >= 22) {
                    var captured = scannerBuffer;
                    scannerBuffer = "";
                    burstCount = 0;
                    parseAndApplyPassportMrz(captured, "Donanımsal Okuyucu (Wedge)");
                } else {
                    scannerBuffer = "";
                    burstCount = 0;
                }
            }, 500);
        });
    }

    /* ==========================================================================
       7. GLOBAL EXPORT (ANINDA KULLANIMA HAZIR)
       ========================================================================== */
    window.scanPassportDirect = triggerDirectOpticalScan;

    window.simulatePassportScan = function (type) {
        if (type === '3m_wedge') {
            var s3m = "START\r\nSurname: SMITH\r\nForenames: JOHN\r\nDate of Birth: 15-05-88\r\nExpiry Date: 20-05-28\r\nDocument: PASSPORT\r\nDoc. Number: GBR123456\r\nNationality: GBR\r\nEND\r\n";
            return parseAndApplyPassportMrz(s3m, "3M Wedge Test Simülasyonu");
        } else if (type === 'regula_wedge') {
            var sReg = "Surname: MULLER\r\nGiven Name: HANS\r\nDocument Number: C3X000123\r\nDate of Birth: 22.08.1985\r\nExpiry Date: 15.08.2032\r\nNationality: DEU\r\nSex: M\r\n";
            return parseAndApplyPassportMrz(sReg, "Regula Wedge Test Simülasyonu");
        } else if (type === 'td1') {
            var sId = "I<DEU123456789712345678901234<\r\n8505205M3005204DEU<<<<<<<<<<<4\r\nSCHMIDT<<ANNA<<<<<<<<<<<<<<<<<";
            return parseAndApplyPassportMrz(sId, "Kimlik Kartı (TD1) Test Simülasyonu");
        } else {
            var sPass = "P<GBRO'CONNOR<<JOHN<<<<<<<<<<<<<<<<<<<<<<<<<<\r\n1234567897GBR9001011M2501012<<<<<<<<<<<<<<02";
            return parseAndApplyPassportMrz(sPass, "Pasaport (TD3) Test Simülasyonu");
        }
    };

    window.PassportReader = {
        scanDevice: triggerDirectOpticalScan,
        applyResult: applyScanResult,
        connectDevice: connectDevice,
        checkStatus: checkOpticalReaderStatus,
        parseAndApply: parseAndApplyPassportMrz,
        simulateScan: window.simulatePassportScan,
        setCountry: setPassportCountry,
        showToast: showPassportToast,
        showAlert: showPassportAlert
    };

    /* ==========================================================================
       8. SAYFA BAŞLATMA
       ========================================================================== */
    $(document).ready(function () {
        initHardwareScannerListener();
        checkOpticalReaderStatus();

        // Buton tıklamaları delegasyonu
        $(document).on('click', '#btnDirectOpticalScan, #btnPanelDirectScan', function (e) {
            e.preventDefault();
            triggerDirectOpticalScan('auto');
        });
    });

})(jQuery);
