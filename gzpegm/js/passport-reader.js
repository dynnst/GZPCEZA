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
        'TUR': 'Türkiye', 'TR': 'Türkiye', 'TLR': 'Türkiye',
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
    function fixOcrMisreads(str) {
        if (!str) return "";
        // OCR-B / MRZ okuma hatalarını düzelt: YFKTAS -> YEKTAS
        return str.replace(/\bYFKTAS\b/gi, 'YEKTAS').replace(/YFKTAS/g, 'YEKTAS').replace(/\bOAYAN\b/gi, 'DAYAN').replace(/OAYAN/g, 'DAYAN');
    }

    function updateTopAgeBadge(birthDateStr) {
        var badge = $('#topAgeBadge');
        if (!badge.length) return;
        if (!birthDateStr || birthDateStr.length < 8) {
            badge.text('Yaş: -').removeClass('badge-warning badge-success').addClass('top-age-badge');
            return;
        }
        var parts = birthDateStr.split('.');
        if (parts.length === 3) {
            var d = parseInt(parts[0], 10);
            var m = parseInt(parts[1], 10) - 1;
            var y = parseInt(parts[2], 10);
            var bDate = new Date(y, m, d);
            if (!isNaN(bDate.getTime())) {
                var today = new Date();
                var age = today.getFullYear() - bDate.getFullYear();
                var mDiff = today.getMonth() - bDate.getMonth();
                if (mDiff < 0 || (mDiff === 0 && today.getDate() < bDate.getDate())) {
                    age--;
                }
                if (age >= 0 && age < 130) {
                    var isChild = (age < 18);
                    badge.text('Yaş: ' + age + (isChild ? ' (Çocuk)' : ' (Yetişkin)'))
                         .toggleClass('badge-warning', isChild)
                         .toggleClass('badge-success', !isChild);
                    return;
                }
            }
        }
        badge.text('Yaş: -');
    }

    function cleanMrzStr(str) {
        if (!str) return "";
        var c = str.replace(/</g, " ").replace(/\s+/g, " ").trim();
        return fixOcrMisreads(c);
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

    function normalizeDateForInput(raw) {
        if (!raw) return '';
        var parts = raw.split('.');
        if (parts.length === 3) {
            var dd = parts[0].length === 1 ? '0' + parts[0] : parts[0];
            var mm = parts[1].length === 1 ? '0' + parts[1] : parts[1];
            var yyyy = parts[2];
            return yyyy + '-' + mm + '-' + dd;
        }
        if (raw.indexOf('-') >= 0 && raw.length >= 10) {
            return raw.substring(0, 10);
        }
        return raw;
    }

    function setPassportCountry(countryCodeOrName) {
        if (!countryCodeOrName) return "";
        var target = countryCodeOrName.trim().toUpperCase();

        // Türk vatandaşı kontrolü
        if (target === 'TUR' || target === 'TR' || target === 'TLR' || target === 'TÜRKİYE' || target === 'TURKEY') {
            if ($('#CountryCalculate').length && $('#CountryCalculate option[value="Türkiye"]').length === 0) {
                $('#CountryCalculate').append(new Option('Türkiye (Test Modu)', 'Türkiye', true, true));
            }
            if ($('#CountryCalculate').length) {
                $('#CountryCalculate').val('Türkiye').trigger('change');
            }
            if ($('#Uyruk').length) {
                $('#Uyruk option').each(function () {
                    if ($(this).val().toLowerCase().indexOf('türk') >= 0) {
                        $('#Uyruk').val($(this).val()).addClass('highlight-flash').trigger('change');
                        return false;
                    }
                });
                if (!$('#DogumY').val() || $('#DogumY').val().trim() === '') {
                    $('#DogumY').val($('#Uyruk').val() || 'Türkiye').addClass('highlight-flash');
                }
            }
            return "Türkiye";
        }

        var mappedName = _isoCountryMap[target] || countryCodeOrName.trim();
        if (!mappedName) return "";

        var foundVal = null;
        var targetLower = mappedName.toLowerCase();

        // 1. Calculate formu için eşleşme
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
        }

        // 2. E-Inad formu için eşleşme (#Uyruk ve #DogumY)
        if ($('#Uyruk').length) {
            var uyrukFound = null;
            var cleanTarget = countryCodeOrName.trim().toLowerCase();
            $('#Uyruk option').each(function () {
                var val = $(this).val();
                if (!val) return;
                var vl = val.toLowerCase();
                if (vl === targetLower || vl === cleanTarget) {
                    uyrukFound = val;
                    return false;
                }
            });
            if (!uyrukFound) {
                $('#Uyruk option').each(function () {
                    var val = $(this).val();
                    if (!val) return;
                    var vl = val.toLowerCase();
                    if (vl.indexOf(targetLower) >= 0 || targetLower.indexOf(vl) >= 0) {
                        uyrukFound = val;
                        return false;
                    }
                });
            }
            if (uyrukFound) {
                $('#Uyruk').val(uyrukFound).addClass('highlight-flash').trigger('change');
                if (!$('#DogumY').val() || $('#DogumY').val().trim() === '') {
                    $('#DogumY').val(uyrukFound).addClass('highlight-flash');
                }
            } else {
                $('#Uyruk').val(mappedName || countryCodeOrName.trim()).addClass('highlight-flash');
                if (!$('#DogumY').val() || $('#DogumY').val().trim() === '') {
                    $('#DogumY').val(mappedName || countryCodeOrName.trim()).addClass('highlight-flash');
                }
            }
        }

        return foundVal || mappedName;
    }

    /* ==========================================================================
       4. DOĞRUDAN DONANIM TARAMASI (3M COGENT, THALES, REGULA, DESKO)
       (Sahtecilik Projesi Referans Alınarak Yapılandırılmıştır - Butona Basıldığında Okur)
       ========================================================================== */
    var isDirectScanActive = false;
    var _isBridgeOnline = false;

    function openBridgeSetupModal() {
        launchBridgeViaProtocol();
        if (!$('#modalBridgeSetup').length) {
            var modalHtml = 
                '<div class="modal fade" id="modalBridgeSetup" tabindex="-1" role="dialog" style="z-index:99999;">' +
                '  <div class="modal-dialog modal-dialog-centered" role="document">' +
                '    <div class="modal-content border-0 shadow-lg" style="border-radius:14px; overflow:hidden;">' +
                '      <div class="modal-header bg-primary text-white py-3">' +
                '        <h5 class="modal-title font-weight-bold"><i class="fas fa-id-card mr-2"></i>Optik Okuyucuyu Masanızda Başlatın</h5>' +
                '        <button type="button" class="close text-white" data-dismiss="modal">&times;</button>' +
                '      </div>' +
                '      <div class="modal-body p-4 text-center">' +
                '        <div class="mb-3"><i class="fas fa-shield-alt text-success" style="font-size:3.5rem;"></i></div>' +
                '        <h5 class="font-weight-bold text-dark mb-2">Yönetici Şifresi / Admin İzni GEREKTİRMEZ</h5>' +
                '        <p class="text-muted" style="font-size:0.92rem;">' +
                '          3M Cogent, Thales, Desko ve Regula okuyucularınızın canlı sunucuyla (10.7.202.75) kesintisiz çalışabilmesi için masanızdaki hafif köprü programını <strong>1 tıkla</strong> başlatın.' +
                '        </p>' +
                '        <div class="alert alert-info py-2 px-3 text-left font-weight-bold mb-3" style="font-size:0.86rem; border-radius:8px;">' +
                '          <i class="fas fa-check-circle mr-1 text-success"></i> Bilgisayarınıza kurulum yapmaz, direkt çalışır.<br/>' +
                '          <i class="fas fa-check-circle mr-1 text-success"></i> Bir defa çalıştırıldığında Windows başlangıcına eklenir.<br/>' +
                '          <i class="fas fa-check-circle mr-1 text-success"></i> Pasaport veya kimliği okuyucuya koyup butona bastığınızda bilgiler anında forma aktarılır.' +
                '        </div>' +
                '        <a href="/Calculate/DownloadBridgeExe" id="btnDownloadBridgeNow" class="btn btn-success btn-lg btn-block shadow font-weight-bold py-2 mb-2" style="font-size:1.05rem; border-radius:8px;">' +
                '          <i class="fas fa-download mr-2"></i> Okuyucu Köprüsünü Başlat (1 Tıkla)' +
                '        </a>' +
                '        <small class="text-muted">İndirilen dosyayı bir defa tıklatmanız yeterlidir. Açıldıktan sonra bu pencere kendiliğinden kapanır ve sistem hazır hale gelir.</small>' +
                '      </div>' +
                '    </div>' +
                '  </div>' +
                '</div>';
            $('body').append(modalHtml);
        }
        $('#modalBridgeSetup').modal('show');
    }
    window.openBridgeSetupModal = openBridgeSetupModal;

    function updateBridgeStatusUI(isOnline, res) {
        _isBridgeOnline = isOnline;
        var badgeContainer = $('#bridgeStatusContainer');
        var launchBtns = $('#btnLaunchBridgeDirect, #btnLaunchBridgeBottom, .btn-launch-bridge');

        if (isOnline) {
            launchBtns
                .removeClass('btn-warning text-dark')
                .addClass('btn-success text-white')
                .attr('title', 'Optik Okuyucu Köprüsü Aktif ve Dinleniyor (3M / Thales / Regula)')
                .attr('data-online', 'true')
                .html('<i class="fas fa-check-circle mr-1 text-white"></i> <span class="lblBridgeStatusText">Okuyucu Hazır</span>');

            if (badgeContainer.length) {
                badgeContainer.html(
                    '<span class="badge badge-success px-3 py-2 shadow-sm font-weight-bold" style="font-size:0.86rem; border-radius:20px; animation:fadeIn 0.3s ease;">' +
                    '<i class="fas fa-check-circle mr-1"></i> Okuyucu Hazır (3M / Thales / Regula)' +
                    '</span>'
                );
            }

            if ($('#modalBridgeSetup').hasClass('show')) {
                $('#modalBridgeSetup').modal('hide');
                showPassportToast('🟢 Optik Okuyucu Köprüsü Aktif! Pasaportu okuyucu camına koyup "Cihazdan Pasaport Oku" butonuna basabilirsiniz.', 'success');
            }
        } else {
            launchBtns
                .removeClass('btn-success text-white')
                .addClass('btn-warning text-dark')
                .attr('title', 'Masanızdaki optik okuyucu donanım köprüsünü başlatın (Yönetici yetkisi gerekmez)')
                .attr('data-online', 'false')
                .html('<i class="fas fa-bolt text-danger mr-1"></i> <span class="lblBridgeStatusText">Okuyucuyu Başlat</span>');

            if (badgeContainer.length) {
                badgeContainer.html(
                    '<a href="javascript:void(0)" onclick="handleStartBridgeClick(event)" class="badge badge-warning px-3 py-2 shadow-sm text-dark font-weight-bold" style="font-size:0.86rem; border-radius:20px; text-decoration:none; border:1px solid #d97706;">' +
                    '<i class="fas fa-bolt text-danger mr-1"></i> Okuyucuyu Başlat (Yönetici İzni Gerekmez)' +
                    '</a>'
                );
            }
        }
    }

    function applyScanResult(res) {
        if (!res) {
            showPassportAlert('Optik okuyucudan yanıt alınamadı.', 'danger');
            return;
        }

        if (res.success) {
            // OCR okuma hatalarını düzelt (YFKTAS -> YEKTAS)
            if (res.fullName) {
                res.fullName = fixOcrMisreads(res.fullName);
            }

            // 1. Türk Vatandaşı Bilgilendirmesi (Test amacıyla form doldurulur)
            var cCode = res.countryCode || res.country || '';
            if (res.isTurkishCitizen || cCode === 'TUR' || cCode === 'TR' || cCode.toLowerCase() === 'türkiye') {
                showPassportAlert(
                    '<strong>BİLGİ / TEST MODU (TUR):</strong> Türk vatandaşı belgesi okundu. Test amacıyla tüm alanlar başarıyla dolduruldu.',
                    'info'
                );
            }

            // 2. Yabancı Yolcu Adı Soyadı (res.fullName veya line1/rawMrz)
            var fullName = res.fullName || res.FullName || res.name || (res.surname && res.givenNames ? res.surname + ' ' + res.givenNames : '');
            if (fullName) {
                fullName = fixOcrMisreads(fullName);
                $('#NameCFORM').val(fullName);
                $('#topPassengerName').val(fullName);
                highlightInput('#NameCFORM, #topPassengerName');
            }

            // 3. Belge / Pasaport Numarası
            var docNum = res.documentNumber || res.DocNumber || res.passportNo || res.docNumber || res.PassportNo;
            if (docNum) {
                $('#PassportCFORM').val(docNum);
                $('#topPassportNumber').val(docNum);
                highlightInput('#PassportCFORM, #topPassportNumber');
            }

            // 4. Kimlik / Kişisel No
            var persNum = res.personalNumber || res.PersonalNumber || res.idNo || res.kimlikNo || res.IdNo;
            if (persNum) {
                $('#IDNCFORM').val(persNum);
                $('#topPersonalNumber').val(persNum);
                highlightInput('#IDNCFORM, #topPersonalNumber');
            }

            // 5. Pasaport Türü (1: Umuma Mahsus, 2: Diplomatik, 3: Servis, vb.)
            var docTypeCode = res.docTypeCode || "1";
            if ($('#PassportCalculate').length) {
                $('#PassportCalculate').val(docTypeCode).trigger('change');
                highlightInput('#PassportCalculate');
            }

            // 6. Uyruk / Ülke Seçimi (Otomatik vize ve harç hesaplatır) + Üst bar yansıtma
            var countryVal = res.country || res.Country || res.nationality || res.countryCode;
            var matchedCountry = "";
            if (countryVal) {
                matchedCountry = setPassportCountry(countryVal);
                $('#OrginCFORM').val(matchedCountry || countryVal);
            }
            $('#topCountryDisplay').val(matchedCountry || countryVal || '');
            highlightInput('#topCountryDisplay');

            // 7. Doğum Tarihi & Yaş Grubu (Üst bar rozet ve alt form - Calculate sayfası)
            var bDate = res.birthDate || res.BirthDate || res.dateOfBirth || res.dob;
            if (bDate && $('#BirthDateCalculate').length) {
                $('#BirthDateCalculate').val(bDate).trigger('change');
                $('#BirthdateCFORM').val(bDate);
                $('#topBirthDate').val(bDate);
                updateTopAgeBadge(bDate);
                highlightInput('#BirthDateCalculate, #topBirthDate');

                if (typeof window.adultchild === 'function') {
                    try {
                        window.adultchild($('#BirthDateCalculate')[0]);
                    } catch (eAdult) {
                        console.error('adultchild error:', eAdult);
                    }
                }
            }

            // Eğer ana alanlardan biri boş kaldıysa ama raw MRZ satırları varsa, JS MRZ ayrıştırıcısını devreye sok
            if ((!fullName || !docNum) && (res.rawMrz || res.line1)) {
                var mrzCombo = res.rawMrz || (res.line1 + '\n' + (res.line2 || '') + '\n' + (res.line3 || ''));
                parseAndApplyPassportMrz(mrzCombo, res.deviceName || "Optik Okuyucu");
            }

            // 8. Yetişkin / Çocuk Durumu
            if (res.adultCode && $('#AdultCalculate').length) {
                $('#AdultCalculate').val(res.adultCode).trigger('change');
                highlightInput('#AdultCalculate');
            }

            // 9. E-Inad Form Alanları Entegrasyonu (EInad Create & Edit Sayfaları)
            if ($('#AdSoyad').length) {
                var fName = res.fullName || ((res.surname || '') + ' ' + (res.givenNames || '')).trim();
                if (fName) $('#AdSoyad').val(fixOcrMisreads(fName)).addClass('highlight-flash');

                var dNumber = res.documentNumber || res.passportNo || res.DocNumber || res.PassportNo;
                if (dNumber) {
                    $('#PasaportNo').val(dNumber).addClass('highlight-flash');
                    if (!$('#BelgeNo').val()) $('#BelgeNo').val(dNumber).addClass('highlight-flash');
                }
                var pNumber = res.personalNumber || res.PersonalNumber || res.idNo || res.kimlikNo || res.IdNo;
                if (pNumber) $('#KimlikNo').val(pNumber).addClass('highlight-flash');
                var bDateVal = res.birthDate || res.BirthDate || res.dateOfBirth || res.dob;
                if (bDateVal) {
                    var bDateNormalized = normalizeDateForInput(bDateVal);
                    if (bDateNormalized) $('#DogumT').val(bDateNormalized).addClass('highlight-flash');
                }
                if (res.sex || res.gender) {
                    var s = (res.sex || res.gender || '').toLowerCase();
                    if (s.indexOf('e') === 0 || s === 'm' || s.indexOf('erkek') >= 0 || s.indexOf('male') >= 0) {
                        $('#Cinsiyet').val('Erkek').addClass('highlight-flash');
                    } else if (s.indexOf('k') === 0 || s.indexOf('b') === 0 || s === 'f' || s.indexOf('bayan') >= 0 || s.indexOf('kadın') >= 0 || s.indexOf('female') >= 0) {
                        $('#Cinsiyet').val('Bayan').addClass('highlight-flash');
                    }
                }
                var cInad = res.country || res.countryCode || res.nationality;
                if (cInad) {
                    setPassportCountry(cInad);
                }
                if (res.documentType || res.docTypeCode || res.docType) {
                    var dtStr = (res.documentType || res.docType || '').toUpperCase();
                    if (dtStr.indexOf('I') >= 0 || dtStr.indexOf('C') >= 0 || dtStr.indexOf('A') >= 0 || dtStr.indexOf('KİMLİK') >= 0 || dtStr.indexOf('KIMLIK') >= 0 || res.docTypeCode === "1") {
                        $('#PasaportTuru').val('Kimlik Kartı');
                    } else {
                        $('#PasaportTuru').val('Umuma Mahsus');
                    }
                }
                if (res.rawText || res.mrz || res.rawMrz) {
                    $('#mrzInputText').val(res.rawText || res.mrz || res.rawMrz);
                }
                $('#accKimlik, #accBelge').show();

                if (typeof window.applyPassportDataToForm === 'function') {
                    try { window.applyPassportDataToForm(res); } catch (eForm) { console.error('window.applyPassportDataToForm error:', eForm); }
                }
            }

            // Kimlik ve Ceza Alanları ASLA Gizlenmez - Kalıcı Açık Tutulur
            $('#form').show().attr('style', 'display: block !important;');
            $('#accKimlik, #accBelge').show().attr('style', 'display: block !important;');

            if (typeof window._onWedgeScanSuccess === 'function') {
                try { window._onWedgeScanSuccess(); } catch (e) { }
            }

            // Görsel Önizleme (VIS veya Portre)
            var imgData = res.visBase64 || res.photoBase64 || res.photo;
            if (imgData) {
                var imgSrc = (imgData.indexOf('data:image') === 0) ? imgData : ('data:image/jpeg;base64,' + imgData);
                if ($('#passportPreviewImg').length) {
                    $('#passportPreviewImg').attr('src', imgSrc);
                }
                if ($('#photoStatusText').length) {
                    $('#photoStatusText').html('<i class="fas fa-check-circle mr-1"></i> Belge Görüntüsü Aktarıldı');
                }
                if ($('#photoFileName').length) {
                    $('#photoFileName').text('Belge No: ' + (res.documentNumber || '-'));
                }
                if ($('#passportPreviewContainer').length) {
                    $('#passportPreviewContainer').slideDown(200);
                }
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

    function launchBridgeViaProtocol() {
        try {
            var iframe = document.getElementById('egm-bridge-launcher-frame');
            if (!iframe) {
                iframe = document.createElement('iframe');
                iframe.id = 'egm-bridge-launcher-frame';
                iframe.style.display = 'none';
                document.body.appendChild(iframe);
            }
            iframe.src = 'egm-reader://start';
        } catch (e) { }
    }

    function tryLocalHardwareBridge(callback, selectedDev) {
        var dev = selectedDev || 'auto';
        $.ajax({
            url: 'http://127.0.0.1:41102/status',
            type: 'GET',
            dataType: 'json',
            timeout: 1000
        }).done(function (sRes) {
            if (sRes && (sRes.isRunning || sRes.success)) {
                doBridgeScan();
            } else {
                attemptProtocolAndScan();
            }
        }).fail(function () {
            attemptProtocolAndScan();
        });

        function attemptProtocolAndScan() {
            launchBridgeViaProtocol();
            setTimeout(function () {
                $.ajax({
                    url: 'http://127.0.0.1:41102/status',
                    type: 'GET',
                    dataType: 'json',
                    timeout: 1500
                }).done(function (sRes2) {
                    if (sRes2 && (sRes2.isRunning || sRes2.success)) {
                        doBridgeScan();
                    } else {
                        if (callback) callback(null);
                    }
                }).fail(function () {
                    if (callback) callback(null);
                });
            }, 1200);
        }

        function doBridgeScan() {
            $.ajax({
                url: 'http://127.0.0.1:41102/scan?device=' + encodeURIComponent(dev),
                type: 'GET',
                dataType: 'json',
                timeout: 30000
            }).done(function (res) {
                if (callback) callback(res);
            }).fail(function () {
                if (callback) callback(null);
            });
        }
    }

    var _bridgePollInterval = null;
    function handleStartBridgeClick(e) {
        if (_isBridgeOnline) {
            if (e && e.preventDefault) e.preventDefault();
            showPassportToast('🟢 Optik Okuyucu Köprüsü Zaten Aktif ve Hazır! Pasaportu veya kimliği okuyucu camına koyup "Cihazdan Pasaport Oku" butonuna basabilirsiniz.', 'success');
            playScanBeep();
            $('#btnDirectOpticalScan, #btnTopScan, #btnTutanakOpticalScan').addClass('pulse-attention');
            setTimeout(function () {
                $('#btnDirectOpticalScan, #btnTopScan, #btnTutanakOpticalScan').removeClass('pulse-attention');
            }, 2500);
            return false;
        }

        // Protokol ile açmayı dene (kurulu ise arka planda anında başlar)
        launchBridgeViaProtocol();

        var launchBtns = $('#btnLaunchBridgeDirect, #btnLaunchBridgeBottom, .btn-launch-bridge');
        launchBtns.html('<span class="spinner-border spinner-border-sm mr-1"></span> Başlatılıyor...');

        showPassportAlert(
            '<strong>⚡ Optik Okuyucu Köprüsü Başlatılıyor...</strong><br/>' +
            '• Köprü daha önce bilgisayarınızda açıldıysa 1-2 saniye içinde otomatik hazır olacaktır.<br/>' +
            '• İlk kullanım ise indirilen <strong>EgmReaderBridge.exe</strong> dosyasına 1 kez tıklayınız (Yönetici yetkisi gerekmez).<br/>' +
            '• Açıldığında bu buton otomatik olarak yeşil <strong>"🟢 Okuyucu Hazır"</strong> rozetine dönecektir.',
            'info'
        );

        var attempts = 0;
        if (_bridgePollInterval) clearInterval(_bridgePollInterval);
        _bridgePollInterval = setInterval(function () {
            attempts++;
            $.ajax({
                url: 'http://127.0.0.1:41102/status',
                type: 'GET',
                dataType: 'json',
                timeout: 800
            }).done(function (res) {
                if (res && (res.isRunning || res.success)) {
                    clearInterval(_bridgePollInterval);
                    _bridgePollInterval = null;
                    updateBridgeStatusUI(true, res);
                    playScanBeep();
                    showPassportAlert(
                        '<strong>🟢 Optik Okuyucu Köprüsü Başarıyla Bağlandı!</strong><br/>' +
                        'Artık masanızdaki pasaport veya kimliği okuyucu camına koyup <strong>[Cihazdan Pasaport Oku]</strong> butonuna basabilirsiniz.',
                        'success'
                    );
                }
            }).fail(function () {
                if (attempts >= 20) {
                    clearInterval(_bridgePollInterval);
                    _bridgePollInterval = null;
                    updateBridgeStatusUI(false);
                }
            });
        }, 1000);

        return true;
    }
    window.handleStartBridgeClick = handleStartBridgeClick;

    function triggerDirectOpticalScan(deviceType) {
        if (isDirectScanActive) return;
        isDirectScanActive = true;

        var btns = $('#btnDirectOpticalScan, #btnPanelDirectScan, #btnTopOpticalScan, #btnTutanakOpticalScan, #btnTopScan, #btnBottomScan, #btnPageScanPassport, #btnBigDirectScan, #btnTopScanPassport, #btnModalScanPassport');
        var originalHtmls = [];
        btns.each(function () {
            originalHtmls.push($(this).html());
        });

        // 0 milisaniye anında görsel geri bildirim
        btns.prop('disabled', true).html('<span class="spinner-border spinner-border-sm mr-1" role="status"></span> Okunuyor...');
        showPassportAlert('<i class="fas fa-satellite-dish fa-spin mr-1"></i> <strong>Optik Okuyucu Taranıyor:</strong> Masanızdaki okuyucuya bağlanılıyor, lütfen pasaportu camda tutunuz...', 'info');

        var safetyTimer = setTimeout(function () {
            if (isDirectScanActive) {
                console.warn('triggerDirectOpticalScan safety timeout triggered.');
                showPassportAlert('Optik okuyucu işlem süresi doldu.', 'warning');
                finishScan();
            }
        }, 10000);

        function finishScan() {
            if (safetyTimer) {
                clearTimeout(safetyTimer);
                safetyTimer = null;
            }
            isDirectScanActive = false;
            btns.each(function (idx) {
                var orig = originalHtmls[idx];
                if (!orig || orig.indexOf('spinner-border') >= 0 || orig.indexOf('Okunuyor') >= 0) {
                    orig = '<span class="passport-pulse-dot mr-1"></span> <i class="fas fa-camera mr-1"></i> Cihazdan Pasaport / Kimlik Oku';
                }
                $(this).prop('disabled', false).html(orig);
            });
        }

        var dev = deviceType || 'auto';

        // 1. Masadaki yerel köprüyü (127.0.0.1:41102) sorgula (1000ms hızlı timeout)
        $.ajax({
            url: 'http://127.0.0.1:41102/status',
            type: 'GET',
            dataType: 'json',
            timeout: 1000
        }).done(function (sRes) {
            if (sRes && (sRes.isRunning || sRes.success)) {
                updateBridgeStatusUI(true, sRes);
                // Köprü hazır! Donanım tarama isteğini gönder (maksimum 8 saniye)
                $.ajax({
                    url: 'http://127.0.0.1:41102/scan?device=' + encodeURIComponent(dev),
                    type: 'GET',
                    dataType: 'json',
                    timeout: 8000
                }).done(function (scanRes) {
                    try {
                        if (scanRes && scanRes.success) {
                            applyScanResult(scanRes);
                        } else {
                            var msg = (scanRes && scanRes.message) ? scanRes.message : 'Masanızdaki optik okuyucudan veri alınamadı. Pasaportun okuyucu camına tam yerleştirildiğinden emin olunuz.';
                            showPassportAlert(msg, 'warning');
                        }
                    } catch (scanErr) {
                        console.error('applyScanResult error:', scanErr);
                        showPassportAlert('Pasaport verisi forma aktarılırken bir hata oluştu: ' + (scanErr.message || scanErr), 'warning');
                    } finally {
                        finishScan();
                    }
                }).fail(function (xhr, status, error) {
                    showPassportAlert('Optik okuyucu tarama işlemi zaman aşımına veya hataya uğradı: ' + error, 'warning');
                    finishScan();
                });
            } else {
                handleBridgeNotRunning();
            }
        }).fail(function () {
            handleBridgeNotRunning();
        });

        function handleBridgeNotRunning() {
            updateBridgeStatusUI(false);
            finishScan();
            showPassportAlert(
                '<strong>Optik Okuyucu Köprüsü Kapalı!</strong><br/>' +
                'Masanızdaki okuyucuya erişebilmek için lütfen yukarıdaki ' +
                '<a href="javascript:void(0)" onclick="handleStartBridgeClick(event)" class="text-white font-weight-bold" style="text-decoration:underline;">[⚡ Okuyucuyu Başlat]</a> ' +
                'butonuna tıklayınız. (Yönetici yetkisi gerekmez)',
                'warning'
            );
            $('#btnLaunchBridgeDirect, #btnLaunchBridgeBottom, .btn-launch-bridge').addClass('pulse-attention');
            setTimeout(function () {
                $('#btnLaunchBridgeDirect, #btnLaunchBridgeBottom, .btn-launch-bridge').removeClass('pulse-attention');
            }, 3000);
        }
    }

    function checkOpticalReaderStatus() {
        $.ajax({
            url: 'http://127.0.0.1:41102/status',
            type: 'GET',
            dataType: 'json',
            timeout: 1000
        }).done(function (sRes) {
            if (sRes && (sRes.isRunning || sRes.success)) {
                updateBridgeStatusUI(true, sRes);
                $('#btnDirectOpticalScan, #btnPanelDirectScan, #btnTopOpticalScan, #btnTopScanPassport').attr('title', 'Optik Okuyucu Köprüsü Aktif (3M / Thales / Regula)');
            } else {
                updateBridgeStatusUI(false);
            }
        }).fail(function () {
            updateBridgeStatusUI(false);
        });
    }

    function connectDevice(deviceType) {
        triggerDirectOpticalScan(deviceType || 'auto');
    }

    window.scanPassportDirect = triggerDirectOpticalScan;
    window.triggerDirectOpticalScan = triggerDirectOpticalScan;

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

        // A. 3M, Regula veya Desko Key-Value Wedge Formatı (Türkçe ve İngilizce Etiketler)
        var hasWedgeKeys = /(?:Surname|Last\s*Name|Family\s*Name|Forenames?|Given\s*Names?|First\s*Names?|Doc\.?\s*(?:Number|No)|Passport\s*(?:Number|No)?|Date\s*of\s*Birth|Birth\s*Date|DOB|Nationality|Country|Personal\s*No|Soyad[ıi]?|Ad[ıi]?|İsim|Belge\s*No|Pasaport\s*No|Kimlik\s*No|TC\s*No|YKN|Do[gğ]um\s*Tarihi|D\.?\s*Tarihi|Uyruk|Vatanda[sş]l[ıi]k)/i.test(rawText);
        if (hasWedgeKeys) {
            var lines = rawText.split(/[\r\n]+/);
            for (var i = 0; i < lines.length; i++) {
                var l = lines[i].trim();
                if (!l) continue;

                var mSurname = /^(?:Surname|Last\s*Name|Family\s*Name|Soyad[ıi]?)\s*[:=]\s*(.+)$/i.exec(l);
                if (mSurname) surname = mSurname[1].trim();

                var mGiven = /^(?:Forenames?|Given\s*Names?|First\s*Names?|Name|Ad[ıi]?|İsim)\s*[:=]\s*(.+)$/i.exec(l);
                if (mGiven && !mSurname) givenNames = mGiven[1].trim();

                var mFullName = /^(?:Ad[ıi]?\s*Soyad[ıi]?|Full\s*Name)\s*[:=]\s*(.+)$/i.exec(l);
                if (mFullName) {
                    var fn = mFullName[1].trim();
                    var fnParts = fn.split(/\s+/);
                    if (fnParts.length >= 2) {
                        surname = fnParts[fnParts.length - 1];
                        givenNames = fnParts.slice(0, fnParts.length - 1).join(' ');
                    } else {
                        surname = fn;
                    }
                }

                var mDoc = /^(?:Doc\.?\s*(?:Number|No)|Document\s*(?:Number|No)?|Passport\s*(?:Number|No)?|Pasaport\s*No|Belge\s*No)\s*[:=]\s*(.+)$/i.exec(l);
                if (mDoc) passportNo = mDoc[1].trim().replace(/\s+/g, '');

                var mNat = /^(?:Nationality|Country|Issuing\s*State|Uyruk|Vatanda[sş]l[ıi]k|[UÜ]lke)\s*[:=]\s*(.+)$/i.exec(l);
                if (mNat) nationalityCode = mNat[1].trim();

                var mDob = /^(?:Date\s*of\s*Birth|Birth\s*Date|DOB|Do[gğ]um\s*Tarihi|D\.?\s*Tarihi)\s*[:=]\s*(.+)$/i.exec(l);
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

                var mPid = /^(?:Personal\s*No|National\s*ID|ID\s*No|Personal\s*Number|Kimlik\s*No|TC\s*No|YKN)\s*[:=]\s*(.+)$/i.exec(l);
                if (mPid) kimlikNo = mPid[1].trim().replace(/</g, '').trim();
            }

            if (surname || givenNames || passportNo) {
                parsedSuccessfully = true;
            }
        }

        // B. Standart ICAO 9303 MRZ (Türkçe Klavye normalizasyonlu)
        if (!parsedSuccessfully) {
            var rawLines = rawText.split(/[\r\n]+/);
            var mrzLines = [];

            for (var j = 0; j < rawLines.length; j++) {
                var lineClean = rawLines[j].toUpperCase().replace(/\s+/g, '');
                // Türkçe Q klavye harita dönüştürmesi:
                // USB wedge donanımının ABD klavye kodlamasında '<' göndermesi Türkçe klavyede ';', ':', ',', 'ç', 'ö', '|' olarak düşer
                lineClean = lineClean.replace(/[;:,çöşığü|«»‹›]/g, '<');
                lineClean = lineClean.replace(/[{}[\]()]/g, '<');
                lineClean = lineClean.replace(/[^A-Z0-9<]/g, '<');

                if (lineClean.length >= 26 && /^[A-Z0-9<]+$/.test(lineClean)) {
                    mrzLines.push(lineClean);
                }
            }

            // Tek parça 80+ karakter geldiyse (satır başı olmadan 88 karakterlik TD3 veya 90 karakterlik TD1)
            if (mrzLines.length === 1 && mrzLines[0].length >= 80) {
                var single = mrzLines[0];
                var pIdxSingle = single.indexOf('P<');
                if (pIdxSingle < 0 && single.indexOf('P') === 0) pIdxSingle = 0;
                if (pIdxSingle < 0 && single.indexOf('V<') >= 0) pIdxSingle = single.indexOf('V<');

                if (pIdxSingle >= 0 && single.length >= pIdxSingle + 88) {
                    mrzLines = [single.substr(pIdxSingle, 44), single.substr(pIdxSingle + 44, 44)];
                } else {
                    var iIdxSingle = single.indexOf('I<');
                    if (iIdxSingle < 0 && single.indexOf('I') === 0) iIdxSingle = 0;
                    if (iIdxSingle < 0 && single.indexOf('A<') >= 0) iIdxSingle = single.indexOf('A<');
                    if (iIdxSingle >= 0 && single.length >= iIdxSingle + 90) {
                        mrzLines = [single.substr(iIdxSingle, 30), single.substr(iIdxSingle + 30, 30), single.substr(iIdxSingle + 60, 30)];
                    }
                }
            }

            // B.1. TD3 Formatı: 2 Satır x 44 Karakter (Yabancı Pasaportlar)
            if (mrzLines.length >= 2) {
                for (var k = 0; k < mrzLines.length - 1; k++) {
                    var l1 = mrzLines[k];
                    var l2 = mrzLines[k + 1];

                    var pIdx = l1.indexOf('P<');
                    if (pIdx < 0 && l1.charAt(0) === 'P') pIdx = 0;
                    if (pIdx < 0) {
                        pIdx = l1.indexOf('V<');
                        if (pIdx < 0 && l1.charAt(0) === 'V') pIdx = 0;
                    }

                    if (pIdx >= 0 && l1.length >= 40 && l2.length >= 40) {
                        if (pIdx > 0) l1 = l1.substring(pIdx);

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

                    var iIdx = t1.indexOf('I<');
                    if (iIdx < 0 && (t1.charAt(0) === 'I' || t1.charAt(0) === 'A' || t1.charAt(0) === 'C')) iIdx = 0;

                    if (iIdx >= 0 && t1.length >= 28 && t2.length >= 28 && t3.length >= 28) {
                        if (iIdx > 0) t1 = t1.substring(iIdx);

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

            // B.3. TD2 Formatı: 2 Satır x 36 Karakter (Yabancı Kimlik & Seyahat Belgeleri)
            if (!parsedSuccessfully && mrzLines.length >= 2) {
                for (var n = 0; n < mrzLines.length - 1; n++) {
                    var u1 = mrzLines[n];
                    var u2 = mrzLines[n + 1];

                    var uIdx = u1.indexOf('I<');
                    if (uIdx < 0 && (u1.charAt(0) === 'I' || u1.charAt(0) === 'A' || u1.charAt(0) === 'C' || u1.charAt(0) === 'V')) uIdx = 0;

                    if (uIdx >= 0 && u1.length >= 34 && u2.length >= 34) {
                        if (uIdx > 0) u1 = u1.substring(uIdx);

                        nationalityCode = u1.substring(2, 5).replace(/</g, '');
                        var namePart2 = u1.substring(5);
                        var nameSplit2 = namePart2.split('<<');
                        surname = cleanMrzStr(nameSplit2[0] || "");
                        givenNames = cleanMrzStr(nameSplit2[1] || "");

                        passportNo = u2.substring(0, 9).replace(/</g, '');
                        if (!nationalityCode || nationalityCode.length < 3) {
                            nationalityCode = u2.substring(10, 13).replace(/</g, '');
                        }

                        var dobRaw2 = u2.substring(13, 19);
                        birthDateStr = parseMrzDate(dobRaw2);

                        var optData2 = u2.substring(28, 35).replace(/</g, '').trim();
                        if (optData2.length >= 5) {
                            kimlikNo = optData2;
                        }

                        docType = "1";
                        parsedSuccessfully = true;
                        break;
                    }
                }
            }
        }

        if (!parsedSuccessfully) {
            return false;
        }

        if (typeof window._onWedgeScanSuccess === 'function') {
            try { window._onWedgeScanSuccess(); } catch (e) { }
        }

        var fullName = fixOcrMisreads((surname + " " + givenNames).trim());

        // 1. Calculate Form Alanları (Ceza Hesaplama)
        if ($('#NameCFORM').length) {
            if (fullName) {
                $('#NameCFORM').val(fullName);
                $('#topPassengerName').val(fullName);
                highlightInput('#NameCFORM, #topPassengerName');
            }

            if (passportNo) {
                $('#PassportCFORM').val(passportNo);
                $('#topPassportNumber').val(passportNo);
                highlightInput('#PassportCFORM, #topPassportNumber');
            }

            if (kimlikNo) {
                $('#IDNCFORM').val(kimlikNo);
                $('#topPersonalNumber').val(kimlikNo);
                highlightInput('#IDNCFORM, #topPersonalNumber');
            }

            if (docType && $('#PassportCalculate').length) {
                $('#PassportCalculate').val(docType).trigger('change');
                highlightInput('#PassportCalculate');
            }

            var matchedCountry = "";
            if (nationalityCode) {
                matchedCountry = setPassportCountry(nationalityCode);
            }
            if ($('#topCountryDisplay').length) {
                $('#topCountryDisplay').val(matchedCountry || nationalityCode || '');
            }

            if (birthDateStr) {
                $('#BirthDateCalculate').val(birthDateStr).trigger('change');
                $('#BirthdateCFORM').val(birthDateStr);
                $('#topBirthDate').val(birthDateStr);
                updateTopAgeBadge(birthDateStr);
                highlightInput('#BirthDateCalculate, #topBirthDate');

                if (typeof window.adultchild === 'function' && $('#BirthDateCalculate').length) {
                    try {
                        window.adultchild($('#BirthDateCalculate')[0]);
                    } catch (eAdult2) {
                        console.error('adultchild error:', eAdult2);
                    }
                }
            }

            // KİMLİK BİLGİLERİ FORMUNU AÇIK TUT VE KESİNLİKLE GİZLEME!
            $('#form').show().removeClass('hidden').css('display', 'block');

            // Kullanıcının gözü önüne getir (akıcı yumuşak kaydırma)
            if ($('#form').length && $('#form').offset()) {
                $('html, body').animate({
                    scrollTop: $('#form').offset().top - 80
                }, 350);
            }
        }

        // 2. E-Inad Form Alanları (EInad Create & Edit)
        if ($('#AdSoyad').length) {
            if (fullName) $('#AdSoyad').val(fullName).addClass('highlight-flash');
            if (passportNo) {
                $('#PasaportNo').val(passportNo).addClass('highlight-flash');
                if (!$('#BelgeNo').val()) $('#BelgeNo').val(passportNo).addClass('highlight-flash');
            }
            if (kimlikNo) $('#KimlikNo').val(kimlikNo).addClass('highlight-flash');
            if (birthDateStr) {
                var bDateNorm = normalizeDateForInput(birthDateStr);
                if (bDateNorm) $('#DogumT').val(bDateNorm).addClass('highlight-flash');
            }
            if (nationalityCode) {
                setPassportCountry(nationalityCode);
            }
            if (docType) {
                if (docType === "1") $('#PasaportTuru').val('Kimlik Kartı');
                else $('#PasaportTuru').val('Umuma Mahsus');
            }
            if (rawText) {
                $('#mrzInputText').val(rawText);
            }
            // E-Inad 1. ve 2. Bölümlerini her zaman açık tut
            $('#accKimlik, #accBelge').show();
            if ($('#accKimlik').length && $('#accKimlik').offset()) {
                $('html, body').animate({
                    scrollTop: $('#accKimlik').offset().top - 100
                }, 300);
            }
        }

        playScanBeep();

        var detailSummary = (fullName ? fullName : 'Yabancı Yolcu') +
            (passportNo ? ' (' + passportNo + ')' : '') +
            (matchedCountry ? ' - ' + matchedCountry : (nationalityCode ? ' - ' + nationalityCode : ''));

        showPassportAlert(
            '<strong>✓ Belge Başarıyla Okundu (' + (sourceName || 'Optik Okuyucu') + '):</strong> ' + detailSummary +
            (birthDateStr ? ' | Doğum: ' + birthDateStr : ''),
            'success'
        );

        return true;
    }

    function cleanMrzWord(raw) {
        if (!raw) return "";
        var c = raw.replace(/</g, " ").replace(/\s+/g, " ").trim();
        return fixOcrMisreads(c);
    }

    /* ==========================================================================
       6. DONANIM OKUYUCU DİNLEYİCİSİ (KEYBOARD WEDGE & PANO LISTENER)
       ========================================================================== */
    function initHardwareScannerListener() {
        var scannerBuffer = "";
        var lastKeystrokeTime = 0;
        var scannerTimer = null;
        var burstCount = 0;

        // 1) PANO / CTRL+V DİNLEYİCİSİ (3M, Thales, Desko Pano Modu)
        $(window).on('paste', function (e) {
            var clip = (e.originalEvent || e).clipboardData;
            if (!clip) return;
            var text = clip.getData('text');
            if (text && text.trim().length >= 20) {
                var isMrzOrWedge = (
                    text.indexOf('P<') >= 0 || text.indexOf('I<') >= 0 || text.indexOf('P;') >= 0 || text.indexOf('I;') >= 0 ||
                    text.indexOf('START') >= 0 ||
                    /(?:Surname|Soyad|Doc\.?\s*Number|Pasaport\s*No)/i.test(text) ||
                    text.split(/[\r\n]+/).filter(function (l) { return l.trim().length >= 28; }).length >= 2
                );
                if (isMrzOrWedge) {
                    e.preventDefault();
                    parseAndApplyPassportMrz(text, "Masaüstü Okuyucu (Pano Modu)");
                }
            }
        });

        // 2) INPUT ALANI ENGELLEYİCİSİ: Eğer kullanıcı bir alandayken okuyucu basarsa
        $(document).on('input', 'input[type="text"]', function () {
            var val = $(this).val();
            if (val && val.length >= 28) {
                if (val.indexOf('P<') >= 0 || val.indexOf('I<') >= 0 || val.indexOf('P;') >= 0 || val.indexOf('I;') >= 0 || val.indexOf('START') >= 0) {
                    var capturedVal = val;
                    $(this).val('');
                    parseAndApplyPassportMrz(capturedVal, "Donanımsal Okuyucu (Wedge Alanı)");
                }
            }
        });

        // 3) KEYBOARD WEDGE DİNLEYİCİSİ
        $(document).on('keydown', function (e) {
            if (e.key === 'Shift' || e.key === 'Control' || e.key === 'Alt' || e.key === 'Meta' || e.key === 'CapsLock') {
                return;
            }

            var now = Date.now();
            var delta = now - lastKeystrokeTime;
            lastKeystrokeTime = now;

            // Donanımsal okuyucularda harf basma süresi 5ms-60ms, satır geçişi 160ms'ye kadar sürebilir
            var isFastBurst = (delta <= 160);
            if (isFastBurst) {
                burstCount++;
            } else {
                if (delta > 1200) {
                    scannerBuffer = "";
                    burstCount = 0;
                }
            }

            var key = e.key;
            if (key === 'Enter') {
                scannerBuffer += '\n';
            } else if (key === 'Tab') {
                scannerBuffer += ' ';
            } else if (key && key.length === 1) {
                scannerBuffer += key;
            }

            // Donanım tarama imzası algılama
            var hasScannerSignature = (
                scannerBuffer.indexOf('START') >= 0 ||
                scannerBuffer.indexOf('Surname:') >= 0 ||
                scannerBuffer.indexOf('Last Name:') >= 0 ||
                scannerBuffer.indexOf('Family Name:') >= 0 ||
                scannerBuffer.indexOf('Given Name:') >= 0 ||
                scannerBuffer.indexOf('Forenames:') >= 0 ||
                scannerBuffer.indexOf('First Name:') >= 0 ||
                scannerBuffer.indexOf('Doc. Number:') >= 0 ||
                scannerBuffer.indexOf('Document Number:') >= 0 ||
                scannerBuffer.indexOf('Passport Number:') >= 0 ||
                scannerBuffer.indexOf('Soyad') >= 0 ||
                scannerBuffer.indexOf('Adı:') >= 0 ||
                scannerBuffer.indexOf('Belge No') >= 0 ||
                scannerBuffer.indexOf('Pasaport No') >= 0 ||
                scannerBuffer.indexOf('REGULA') >= 0 ||
                scannerBuffer.indexOf('DESKO') >= 0 ||
                scannerBuffer.indexOf('THALES') >= 0 ||
                scannerBuffer.indexOf('3M') >= 0 ||
                scannerBuffer.indexOf('P<') >= 0 ||
                scannerBuffer.indexOf('I<') >= 0 ||
                scannerBuffer.indexOf('A<') >= 0 ||
                scannerBuffer.indexOf('C<') >= 0 ||
                scannerBuffer.indexOf('V<') >= 0 ||
                scannerBuffer.indexOf('P;') >= 0 ||
                scannerBuffer.indexOf('I;') >= 0
            );

            // Odaktaki input alanını donanım verisiyle kirletmemek için varsayılan yazmayı engelle
            if ((burstCount >= 2 || hasScannerSignature) && e.target) {
                var tag = (e.target.tagName || '').toUpperCase();
                if (tag === 'INPUT' || tag === 'TEXTAREA') {
                    e.preventDefault();
                }
            }

            // 1) 3M / Thales Wedge END etiketi tespiti
            if (/END[\r\n]*$/i.test(scannerBuffer) && scannerBuffer.length >= 25) {
                e.preventDefault();
                clearTimeout(scannerTimer);
                var outputWedge = scannerBuffer;
                scannerBuffer = "";
                burstCount = 0;
                parseAndApplyPassportMrz(outputWedge, "3M / Thales Donanım");
                return false;
            }

            // 2) TD3 Pasaport tamamlandığında (2 satır x 44 karakter)
            var td3Lines = scannerBuffer.split(/[\r\n]+/).filter(function (l) { return l.trim().length >= 38; });
            if (td3Lines.length >= 2) {
                var firstL = td3Lines[0].replace(/[;:,çöşığü|]/g, '<');
                if (firstL.indexOf('P<') >= 0 || firstL.indexOf('P') === 0 || firstL.indexOf('V<') >= 0) {
                    if (td3Lines[1].trim().length >= 38) {
                        clearTimeout(scannerTimer);
                        var td3Data = scannerBuffer;
                        scannerBuffer = "";
                        burstCount = 0;
                        parseAndApplyPassportMrz(td3Data, "3M / Thales / Desko / Regula Pasaport Okuyucu");
                        return;
                    }
                }
            }

            // 3) TD1 Kimlik tamamlandığında (3 satır x 30 karakter)
            var td1Lines = scannerBuffer.split(/[\r\n]+/).filter(function (l) { return l.trim().length >= 26; });
            if (td1Lines.length >= 3) {
                var firstT = td1Lines[0].replace(/[;:,çöşığü|]/g, '<');
                if (firstT.indexOf('I<') >= 0 || firstT.indexOf('I') === 0 || firstT.indexOf('A<') >= 0 || firstT.indexOf('C<') >= 0) {
                    clearTimeout(scannerTimer);
                    var td1Data = scannerBuffer;
                    scannerBuffer = "";
                    burstCount = 0;
                    parseAndApplyPassportMrz(td1Data, "3M / Thales / Desko / Regula Kimlik Okuyucu");
                    return;
                }
            }

            // 4) TD2 Kimlik / Seyahat Belgesi tamamlandığında (2 satır x 36 karakter)
            var td2Lines = scannerBuffer.split(/[\r\n]+/).filter(function (l) { return l.trim().length >= 34; });
            if (td2Lines.length >= 2) {
                var firstU = td2Lines[0].replace(/[;:,çöşığü|]/g, '<');
                if (firstU.indexOf('I<') >= 0 || firstU.indexOf('A<') >= 0 || firstU.indexOf('C<') >= 0 || firstU.indexOf('V<') >= 0) {
                    clearTimeout(scannerTimer);
                    var td2Data = scannerBuffer;
                    scannerBuffer = "";
                    burstCount = 0;
                    parseAndApplyPassportMrz(td2Data, "Desko / 3M / Regula Seyahat Belgesi Okuyucu");
                    return;
                }
            }

            // Debounce zamanlayıcısı (400ms): tüm satırların ve tuş serilerinin tamamlanmasını bekler
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
            }, 400);
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
    /* ==========================================================================
       ÜST KABİN PANELİ İKİ YÖNLÜ SENKRONİZASYON VE KISAYOLLAR
       ========================================================================== */
    function initTopPassportBarSync() {
        // 1. Üst panel -> Alt form senkronizasyonu
        $('#topPassengerName').on('input change', function () {
            $('#NameCFORM').val($(this).val());
        });

        $('#topPassportNumber').on('input change', function () {
            var v = $(this).val().toUpperCase();
            $(this).val(v);
            $('#PassportCFORM').val(v);
        });

        $('#topBirthDate').on('input change', function () {
            var v = $(this).val();
            $('#BirthDateCalculate').val(v);
            $('#BirthdateCFORM').val(v);
            updateTopAgeBadge(v);
            if (typeof window.adultchild === 'function' && v.length === 10) {
                window.adultchild($('#BirthDateCalculate')[0]);
            }
        });

        $('#topPersonalNumber').on('input change', function () {
            $('#IDNCFORM').val($(this).val());
        });

        // 2. Alt form -> Üst panel senkronizasyonu
        $('#NameCFORM').on('input change', function () {
            $('#topPassengerName').val($(this).val());
        });

        $('#PassportCFORM').on('input change', function () {
            $('#topPassportNumber').val($(this).val());
        });

        $('#CountryCalculate').on('change', function () {
            var opt = $(this).find('option:selected');
            var txt = opt.text();
            var val = $(this).val();
            if (val && txt && txt !== 'Seçiniz...') {
                $('#topCountryDisplay').val(txt);
            } else {
                $('#topCountryDisplay').val(val || '');
            }
        });

        $('#BirthDateCalculate, #BirthdateCFORM').on('input change', function () {
            var v = $(this).val();
            $('#topBirthDate').val(v);
            updateTopAgeBadge(v);
        });

        $('#IDNCFORM').on('input change', function () {
            $('#topPersonalNumber').val($(this).val());
        });

        // Üst bar doğum tarihi datepicker desteği
        if ($.fn.datepicker) {
            $('#topBirthDate').datepicker({
                format: 'dd.mm.yyyy',
                autoclose: true,
                weekStart: 1,
                language: 'tr',
                startView: 'years',
                endDate: '+0d'
            }).on('changeDate', function () {
                var v = $(this).val();
                $('#BirthDateCalculate').val(v).trigger('change');
                $('#BirthdateCFORM').val(v);
                updateTopAgeBadge(v);
                if (typeof window.adultchild === 'function' && $('#BirthDateCalculate').length) {
                    try {
                        window.adultchild($('#BirthDateCalculate')[0]);
                    } catch (eAdult2) {
                        console.error('adultchild error:', eAdult2);
                    }
                }
            });
        }

        // F2 Kısayol Tuşu: Hızlı optik okuyucu tarama
        $(document).on('keydown', function (e) {
            if (e.key === 'F2') {
                e.preventDefault();
                triggerDirectOpticalScan('auto');
            }
        });
    }

    $(document).ready(function () {
        initHardwareScannerListener();
        initTopPassportBarSync();
        checkOpticalReaderStatus();

        // Kimlik Alanını Her Zaman Görünür Tut (Kullanıcı Talebi)
        $('#form').show().attr('style', 'display: block !important;');
        $('#accKimlik, #accBelge').show().attr('style', 'display: block !important;');

        // Buton tıklamaları delegasyonu (Üst ve alt butonlar - Butona tıklandığında okur)
        $(document).on('click', '#btnDirectOpticalScan, #btnPanelDirectScan, #btnTopOpticalScan, #btnTutanakOpticalScan, #btnTopScan, #btnPageScanPassport, #btnBigDirectScan', function (e) {
            e.preventDefault();
            triggerDirectOpticalScan('auto');
        });

        $(document).on('click', '#btnLaunchBridgeDirect, #btnLaunchBridgeBottom, .btn-launch-bridge', function (e) {
            handleStartBridgeClick(e);
        });
    });

})(jQuery);
