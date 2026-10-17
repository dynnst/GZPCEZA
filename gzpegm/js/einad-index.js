/* ==========================================================================
   E-INAD Yonetim JavaScript (einad-index.js)
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
   UYRUK → DOĞUM YERİ
========================= */
function initUyrukChange() {
    $('#Uyruk').off('change').on('change', function () {
        var val = $(this).val();
        if (val) {
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
    if (!airlineName || airlineName.trim().length === 0) {
        return;
    }

    if (!flightNo || flightNo.length < 2) {
        return;
    }

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

/* =========================
   HAVAYOLU MANUEL GİRİŞ KONTROLÜ
========================= */
function initHavayoluManualCheck() {
    $('#GelenHavayolu').on('blur', function () {
        var airlineName = $(this).val();
        var flightNo = $('#GelenUcusNo').val();

        if (airlineName && airlineName.trim().length > 0 && flightNo && flightNo.length >= 2) {
            checkAndAddAirline(airlineName, flightNo);
        }
    });

    $('#GidenHavayolu').on('blur', function () {
        var airlineName = $(this).val();
        var flightNo = $('#GidisUcusNo').val();

        if (airlineName && airlineName.trim().length > 0 && flightNo && flightNo.length >= 2) {
            checkAndAddAirline(airlineName, flightNo);
        }
    });
}

/* =========================
   UÇUŞ NO DEĞİŞİNCE HAVAYOLU BUL
========================= */
function initUcusNoToAirline() {
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
    if (!iataCode || iataCode.length !== 2) {
        return;
    }

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

/* =========================
   YENİ KAYIT
========================= */
function openAdd() {
    $('#inadForm').attr('action', getEinadUrl('data-url-add-inad', '/EInad/AddInad'));
    $('#inadModalTitle').text('Yeni Kayıt Ekle');
    $('#inadForm')[0].reset();
    $('#InadId').val(0);

    $('input[name="UcagaNakil"]').prop('checked', false);
    $('input[name="InadSebep"]').prop('checked', false);

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
                $('#inadModal').modal('show');
            });
    });
}

/* =========================
   DÜZENLE
========================= */
function openEdit(id) {
    refreshAllDropdowns().done(function () {
        $.get(getEinadUrl('data-url-get-inad', '/EInad/GetInad'), { id: id }, function (res) {

            if (!res || !res.success) {
                alert("Veri alınamadı");
                return;
            }

            var d = res.data || {};

            $('#inadForm').attr('action', getEinadUrl('data-url-edit-inad', '/EInad/EditInad'));
            $('#inadModalTitle').text('Kayıt Düzenle');

            $('#InadId').val(d.InadId || 0);
            $('#TarihSaat').val(parseMsDateToLocal(d.TarihSaat));
            $('#AdSoyad').val(d.AdSoyad || '');
            $('#DogumT').val(parseMsDateToLocal(d.DogumT, true));
            $('#DogumY').val(d.DogumY || '');
            $('#Cinsiyet').val(d.Cinsiyet || '');

            $('#PasaportNo').val(d.PasaportNo || '');
            $('#BelgeNo').val(d.BelgeNo || '');
            $('#KimlikNo').val(d.KimlikNo || '');

            setTimeout(function() {
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

            $('input[name="UcagaNakil"]').prop('checked', false);
            if (d.UcagaNakil && typeof d.UcagaNakil === 'string') {
                d.UcagaNakil.split(',').forEach(function (v) {
                    var val = v.trim();
                    if (val.length) $('input[name="UcagaNakil"][value="' + val + '"]').prop('checked', true);
                });
            }

            loadAirlineList();
            $('#inadModal').modal('show');
        });
    });
}

/* =========================
   TÜM DROPDOWN'LARI YENİLE - PROMISE DÖNÜYOR
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
    if (!confirm("Bu kayıt silinecek. Emin misiniz?"))
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
   ✅ DURUM DEĞİŞTİRME - RELOAD OLMADAN, TEK TIKLAMA
========================= */
function toggleStatus(btn) {
    var $btn = $(btn);
    var id = $btn.data('inad-id');
    var newStatus = $btn.data('next-status');

    if (!id || !newStatus) return;

    // Yanıp sönen uyarıda ekstra onay
    var confirmMsg = newStatus === 'İnad Odasına Alındı'
        ? "⚠️ Yolcu 'İnad Odasına Alındı' olarak işaretlenecek.\n\nLütfen yolcunun takibini yapınız!\n\nOnaylıyor musunuz?"
        : "Yolcu 'İnad Edildi' olarak işaretlenecek.\n\nOnaylıyor musunuz?";

    if (!confirm(confirmMsg)) return;

    // Çift tıklama koruması
    var originalHtml = $btn.html();
    $btn.prop('disabled', true)
        .html('<i class="fas fa-spinner fa-spin"></i> İşleniyor...');

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
                // Satırdaki badge'i yerinde güncelle
                updateRowStatusBadge($btn, newStatus);

                var message = newStatus === 'İnad Edildi'
                    ? '<i class="fas fa-check-circle"></i> <strong>Yolcu başarıyla "İnad Edildi" olarak işaretlendi.</strong>'
                    : '<i class="fas fa-exclamation-circle"></i> <strong>Yolcu "İnad Odasına Alındı" olarak işaretlendi.</strong> Lütfen takip yapınız!';

                showEInadStatus(message, newStatus === 'İnad Edildi' ? 'success' : 'warning');

                // 5 saniye sonra mesajı otomatik kapat (reload yok!)
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

/* =========================
   SATIRDAKİ BADGE'İ YERİNDE GÜNCELLE
========================= */
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
        missing.push('İNAD sebebi');
        $('#accInad').collapse('show');
    }

    if (missing.length > 0) {
        var warningMsg = '<i class="fas fa-exclamation-triangle"></i> <strong>Lütfen zorunlu alanları tamamlayın:</strong> ' + missing.join(', ') + '.';
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
        var alertMsg = '<i class="fas fa-exclamation-circle"></i> <strong>⚠️ ÖNEMLİ UYARI:</strong> Yolcu "İnad Odasına Alındı" durumundadır. Lütfen yolcunun takibini yapınız! Listedeki sarı butona basarak durumu güncelleyebilirsiniz.';
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
        search: 'Ara:',
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
   INIT
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

    // Durum badge'lerine event delegation (DataTable sayfa değişimlerinde de çalışır)
    $(document).off('click', '.inad-status-btn:not(.status-diger)')
               .on('click', '.inad-status-btn:not(.status-diger)', function (e) {
        e.preventDefault();
        toggleStatus(this);
    });

    $('#inadModal').on('show.bs.modal', function () {
        hideEInadStatus();
        $('#saveButton').prop('disabled', false).html('Kaydet');
        loadAirlineList();
    });

    $('#inadForm').off('submit').on('submit', validateInadForm);
});
