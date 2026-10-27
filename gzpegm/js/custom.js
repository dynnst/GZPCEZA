var z = 0;
// 180/90 hesaplama: formdaki tüm giriş/çıkış kayıtlarına göre en son çıkış tarihini referans alır.
// Hesaplama motorundaki kuralla uyumlu olması için referans tarih her zaman en son çıkış tarihidir.
function computeReEntryFromForm() {
    var ends = [];
    $('.endt').each(function (i) {
        var s = parseDMY($(this).val());
        var e = parseDMY($('.exdt').eq(i).val());
        if (s && e && s <= e) {
            e = new Date(e.getFullYear(), e.getMonth(), e.getDate());
            ends.push(e);
        }
    });

    if (ends.length === 0) {
        $('#ReEntryCalculate').val('');
        return;
    }

    var lastExit = ends.reduce(function (a, b) { return a > b ? a : b; });
    var visa = $('#VisaCalculate').val();
    var penaltyMonth = parseInt($('#CezaAyCalculate').val(), 10) || 0;
    var penaltyDay = parseInt($('#CezaGunCalculate').val(), 10) || 0;
    var penaltyTotal = (penaltyMonth * 30) + penaltyDay;

    if ((visa === '4' || visa === '8') && penaltyTotal > 0) {
        var remaining = Math.max(0, 90 - penaltyTotal);
        if (remaining > 0) {
            var allowedUntil = new Date(lastExit.getTime());
            allowedUntil.setDate(allowedUntil.getDate() + remaining);
            var allowedUntilText = ('0' + allowedUntil.getDate()).slice(-2) + '.'
                + ('0' + (allowedUntil.getMonth() + 1)).slice(-2) + '.'
                + allowedUntil.getFullYear();
            $('#ReEntryCalculate').val('Çıkış sonrası girebilir - hemen giriş yaparsa en geç çıkış tarihi: ' + allowedUntilText + ' / kalan hak: ' + remaining + ' gün (' + penaltyTotal + ' gün düşüldü)');
            return;
        }
    }

    var date91 = new Date(lastExit.getTime());
    date91.setDate(date91.getDate() + 91);

    var dd91 = ('0' + date91.getDate()).slice(-2);
    var mm91 = ('0' + (date91.getMonth() + 1)).slice(-2);
    var yy91 = date91.getFullYear();
    $('#ReEntryCalculate').val(dd91 + '.' + mm91 + '.' + yy91);
}

function uploadSummernoteImage(file, editorSelector) {
    var formData = new FormData();
    formData.append('file', file);

    // antiforgery token varsa hem formData'ya hem header'a ekle
    var token = $('input[name="__RequestVerificationToken"]').val();
    if (token) {
        formData.append('__RequestVerificationToken', token);
    }

    // normalize editor selector
    var $editor = null;
    try {
        if (editorSelector) {
            $editor = $(editorSelector);
            if ($editor.length === 0) $editor = null;
        }
    } catch (ex) {
        $editor = null;
    }
    if (!$editor) $editor = $('#addAnonsExplain');

    // AJAX çağrısı ve dönen JSON'u logla / işle
    var jq = $.ajax({
        url: '/UploadSummernoteImage',
        type: 'POST',
        data: formData,
        cache: false,
        contentType: false,
        processData: false,
        dataType: 'json',
        beforeSend: function (xhr) {
            if (token) {
                // bazı sunucu yapılandırmaları header ile bekleyebilir
                xhr.setRequestHeader('RequestVerificationToken', token);
            }
        },
        success: function (res) {
            console.log('UploadSummernoteImage response:', res);
            if (!res) {
                alert('Sunucudan beklenmeyen cevap alındı.');
                return;
            }

            if (res.success && res.url) {
                try {
                    // Eğer sunucu debug bilgisi döndüyse dosyanın gerçekten var olup olmadığına bak
                    if (typeof res.exists !== 'undefined' && res.exists === false) {
                        console.warn('Sunucu dosyayı bildirdi fakat fiziksel dosya bulunamadı:', res.physicalPath);
                        alert('Resim yüklendi ancak sunucuda dosya bulunamadı. Yönetici ile iletişime geçin.');
                        return;
                    }

                    // Summernote insertImage kullanımı (callback ile stil ayarı)
                    $editor.summernote('insertImage', res.url, function ($img) {
                        // Opsiyonel: image stilini sınırlandır
                        try { $($img).css('max-width', '100%'); } catch (e) { /* ignore */ }
                    });
                } catch (e) {
                    console.warn('insertImage hata, fallback kullanılıyor:', e);
                    var img = document.createElement('img');
                    img.src = res.url;
                    img.alt = '';
                    $('#addAnonsExplain').summernote('insertNode', img);
                }
            } else {
                var msg = res.message || 'Bilinmeyen hata';
                console.warn('Upload başarısız:', res);
                alert('Resim yüklenemedi: ' + msg);
            }
        },
        error: function (xhr) {
            var errMsg = 'Sunucu hatası: Resim yüklenemedi.';
            try {
                if (xhr && xhr.responseJSON && xhr.responseJSON.message) errMsg = xhr.responseJSON.message;
                else if (xhr && xhr.responseText) {
                    // json değilse düz metin olabilir
                    var txt = xhr.responseText;
                    try {
                        var j = JSON.parse(txt);
                        if (j && j.message) errMsg = j.message;
                    } catch (e) {
                        errMsg = txt;
                    }
                }
            } catch (ex) { /* ignore */ }

            console.error('Upload error:', xhr, errMsg);
            alert(errMsg);
        }
    });

    return jq;
}

function deleteImagePage(file) {
    if (!file) return;
    if (!confirm('Bu resmi sunucudan kalıcı olarak silmek istediğinize emin misiniz?')) return;

    var token = $('input[name="__RequestVerificationToken"]').val();
    var data = { name: file };
    if (token) data.__RequestVerificationToken = token;

    $.ajax({
        url: "/ResimSil",
        type: "POST",
        data: data,
        dataType: 'json'
    }).done(function (res) {
        console.log('ResimSil response:', res);
        if (res && res.success) {
            alert('Resim sunucudan silindi.');
        } else {
            alert('Resim silinemedi: ' + (res && res.message ? res.message : 'Bilinmeyen hata'));
        }
    }).fail(function (xhr) {
        var txt = xhr && xhr.responseText ? xhr.responseText : 'Sunucu hatası';
        console.error('ResimSil error:', xhr);
        alert('Resim silme hatası: ' + txt);
    });
}
function resetpass(id) {
    $(document.body).addClass('loading-overlay-showing');
    $(document.body).attr('data-loading-overlay');
    $.ajax({
        url: "/resetpass",
        type: "POST",
        data: { 'fldId': id },
        success: function (result) {
            alert(result.M);
            $(document.body).removeClass('loading-overlay-showing');
            $(document.body).removeAttr('data-loading-overlay');
        },
        error: function (result) {
            $(document.body).removeClass('loading-overlay-showing');
            $(document.body).removeAttr('data-loading-overlay');
        }
    });
}
function checkPass(theForm) {
    if (theForm.newpass.value != theForm.confirmpass.value) {
        alert('Yeni sifreler eslesmiyor. Lutfen kontrol ediniz..!');
        return false;
    }
    else {
        if (z === 1) return true;
        else {
            var $id = theForm.id.value,
                $pass = theForm.currentpass.value;
            $.ajax({
                url: "/CheckPass",
                type: "POST",
                data: { 'userid': $id, 'pass': $pass },
                dataType: "json",
                success: function (result) {
                    if (result.Type === "0") {
                        alert('Sifre yanlis. Lutfen kontrol ediniz..!');
                        return false;
                    }
                    else {
                        z = 1;
                        $('#submit').click();
                    }
                },
                error: function (result) {
                    //return false;
                }
            });
            return false;
        }
        return true
    }

}
function previewPass(input) {
    setTimeout(function () {
        var x = input; //document.getElementById('currentpass');
        if (x.type === "text") {
            x.type = "password";
        }
    }, 1000);
}
function previewPass2(input) {
    var x = input;
    if (x.type === "password") {
        x.type = "text";
    }
}
function getuserdata(fldId) {
    $(document.body).addClass('loading-overlay-showing');
    $(document.body).attr('data-loading-overlay');
    $.ajax({
        url: "/getuser",
        type: "POST",
        data: { 'fldId': fldId },
        success: function (result) {
            $('#EditUserId').val(result.ID);
            $('#editNameUser').val(result.Name);
            $('#editLastNameUser').val(result.LastName);
            $('#editTitleUser').val(result.Title);
            $('#editDeputyUser').val(result.Deputy);
            $('#editPhoneUser').val(result.Phone);
            $('#editEmailUser').val(result.Email);
            $('#editSicilUser').val(result.Sicil);
            $('#editSubAuthUser').val(result.Subauth).change();
            $('#editBorderUser').val(result.Border).change();
            $('option', $('#editPermiUser')).each(function (element) {
                $('#editPermiUser').multiselect('deselect', $(this).val());
            });
            $('option', $('#editPermiUser')).each(function (element) {
                var optionvalue = $(this).val();
                if (result.Permi.toString().includes(optionvalue.toString())) { $('#editPermiUser').multiselect('select', $(this).val()); }
            });
            $(document.body).removeClass('loading-overlay-showing');
            $(document.body).removeAttr('data-loading-overlay');
        },
        error: function (result) {
        }
    });
}
function Decimal(elem, event) {
    var n = event.keyCode;
    if (!((n == 8)              // backspace
        || (n == 46)                // delete
        || (n >= 35 && n <= 40)     // arrow keys/home/end
        || (n >= 48 && n <= 57)     // numbers on keyboard
        || (n >= 96 && n <= 105)
        || (n == 188)
        || (n == 110)// number on keypad
        && (elem.value.includes(',') == false))
    ) {
        event.preventDefault();
    }
}
// ... (diğer fonksiyonlar değişmedi, proje dosyanızdaki tam içeriği koruyun)
function Decimal(elem, event) {
    var n = event.keyCode;
    if (!((n == 8)              // backspace
        || (n == 46)                // delete
        || (n >= 35 && n <= 40)     // arrow keys/home/end
        || (n >= 48 && n <= 57)     // numbers on keyboard
        || (n >= 96 && n <= 105)
        || (n == 188)
        || (n == 110)// number on keypad
        && (elem.value.includes(',') == false))
    ) {
        event.preventDefault();
    }
}
function editauh(Id, Country, FirstMounth, Kat, Tom, Sday, Kday) {
    $('#EditAUHId').val(Id);
    $('#editCountryAUH').val(Country).change();
    $('#editFirstMounthAUH').val(FirstMounth);
    $('#editKatSAUH').val(Kat);
    $('#editTOMAUH').val(Tom).change();
    $('#editDaySAUH').val(Sday);
    $('#editDayKAUH').val(Kday);
}
function deleteauh(Id) {
    var r = confirm("Aylık Ülke Harcını silmek istediğinizde emin misiniz ?");
    if (r == false) {
        return false;
    }
    $.ajax({
        url: "/DeleteAuh",
        type: "POST",
        data: {
            'Id': Id
        },
        success: function (result) {
            alert(result.Message);
            location.href = result.Url;
        }
    });
}
function edittkod(Id, Code, Sure, Start, Finish, Idari, Payment) {
    $('#EditTKodId').val(Id);
    $('#editcodeTKOD').val(Code);
    $('#editsureTKOD').val(Sure);
    $('#editstartTKOD').val(Start);
    $('#editfinishTKOD').val(Finish);
    $('#editidariTKOD').val(Idari);
    $('#editpaymentTKOD').val(Payment).change();
    $('#editadultTKOD').val(ToP).change();
}
function deletetkod(Id) {
    var r = confirm("Tahdit Kodunu silmek istediğinizde emin misiniz ?");
    if (r == false) {
        return false;
    }
    $.ajax({
        url: "/DeleteTKod",
        type: "POST",
        data: {
            'Id': Id
        },
        success: function (result) {
            alert(result.Message);
            location.href = result.Url;
        }
    });
}
function edituvr(Id, Country, Calculate, Passport, Visa, Day, Long, Time, Hb) {
    $('#EditUVR').val(Id);
    $('#editCountryUVR').val(Country).change();
    $('#editCalculateUVR').val(Calculate).change();
    $('#editPassportUVR').val(Passport).change();
    $('#editvisaUVR').val(Visa).change();
    $('#editdayUVR').val(Day);
    $('#editlongUVR').val(Long);
    $('#editonetimeUVR').val(Time);
    $('#editharcUVR').val(Hb).change();
}
function deleteuvr(Id) {
    var r = confirm("Ülke Vize Rejmini silmek istediğinizde emin misiniz ?");
    if (r == false) {
        return false;
    }
    $.ajax({
        url: "/DeleteUVR",
        type: "POST",
        data: {
            'Id': Id
        },
        success: function (result) {
            alert(result.Message);
            location.href = result.Url;
        }
    });
}
function deletetgvh(Id) {
    var r = confirm("Tek giriş vize harcını silmek istediğinizde emin misiniz ?");
    if (r == false) {
        return false;
    }
    $.ajax({
        url: "/deletetgvh",
        type: "POST",
        data: {
            'Id': Id
        },
        success: function (result) {
            alert(result.Message);
            location.href = result.Url;
        }
    });
}
function visachange(elem) {
    $('#ikametli').addClass('hidden');
    $('#v137SureDurumu').addClass('hidden');
    $('#V137ExpiredCalculate').val('0');
    $('#Visaday').val('');
    $('#ikametli').val('');
    $('#testarihiLabel').text('İkamet Tezkeresi Bitiş Tarihi');
    if (elem.value == '') {
        updateConditionalEntryDateRows();
        return false;
    }
    if (elem.value == 3) {
        var visaday = prompt('Vize süresini giriniz');
        if (isNaN(visaday) == false && visaday.includes('.') == false) {
            $('#Visaday').val(visaday);
        }
        else {
            alert('Hatalı giriş. Lütfen sadece rakam giriniz');
            visachange($('#VisaCalculate'));
        }
    }
    else if (elem.value == 4 || elem.value == 8 || elem.value == 10 || elem.value == 11 || elem.value == 12 || elem.value == 13 || elem.value == 14 || elem.value == 15) {
        $('#Visaday').val('');
        if (elem.value == 4 || elem.value == 14) {
            $('#testarihiLabel').text('İkamet Tezkeresi Bitiş Tarihi');
        } else if (elem.value == 8) {
            $('#testarihiLabel').text('Çalışma İzni Bitiş Tarihi');
        } else if (elem.value == 11) {
            $('#testarihiLabel').text('Terke Davet Tebliğ Tarihi');
        } else if (elem.value == 13) {
            $('#testarihiLabel').text('Vize Başlangıç / Terke Davet Tebliğ Tarihi');
        } else {
            $('#testarihiLabel').text('Tebliğ Tarihi');
        }
        $('#ikametli').removeClass('hidden');
        if (elem.value == 11 || elem.value == 13) {
            $('#v137SureDurumu').removeClass('hidden');
        }
    }
    else {
        $('#Visaday').val('');
        $('#ikametli').addClass('hidden');
        $('#ikametli').val('');
    }
    $('#PayCalculate')
        .find('option')
        .remove();

    //*27.12.2021 (3 Ay İhlal) Eklemesi yapıldı*//
    if (elem.value == 14) {
        $('#PayCalculate')
            .append('<option value="">Lütfen Seçiniz</option>')
            .append('<option value="14">İkamet Teskereli V-157 Tahditli Ödeyen,Tebliğ Tarihi Dışında Gelen</option>')
            .append('<option value="15">İkamet Teskereli V-157 Tahditli Ödemeyen,Tebliğ Tarihi Dışında Gelen</option>');
    }
    else if (elem.value == 13) {
        // ✅ V-137 Vize Süreli için
        $('#PayCalculate')
            .append('<option value="">Lütfen Seçiniz</option>')
            .append('<option value="16">V-137 Vize Süreli Ödeyen</option>')
            .append('<option value="17">V-137 Vize Süreli Ödemeyen</option>');
    }
    else if (elem.value == 11) {
        $('#PayCalculate')
            .append('<option value="">Lütfen Seçiniz</option>')
            .append('<option value="4">V-137 Ödeyen</option>')
            .append('<option value="5">V-137 Ödemeyen</option>');
    }
    else if (elem.value == 9) {
        $('#PayCalculate')
            .append('<option value="">Lütfen Seçiniz</option>')
            .append('<option value="6">V-157 Ödeyen,Tebliğ Tarihi Dışında Gelen</option>')
            .append('<option value="7">V-157 Ödemeyen,Tebliğ Tarihi Dışında Gelen</option>');
    }
    else if (elem.value == 10) {
        $('#PayCalculate')
            .append('<option value="">Lütfen Seçiniz</option>')
            .append('<option value="8">V-69 Ödeyen</option>')
            .append('<option value="9">V-69 Ödemeyen</option>');
    }
    else if (elem.value == 12) {
        $('#PayCalculate')
            .append('<option value="">Lütfen Seçiniz</option>')
            .append('<option value="10">V-88 Ödeyen</option>')
            .append('<option value="11">V-88 Ödemeyen</option>');
    }
    else if (elem.value == 7) {
        $('#PayCalculate')
            .append('<option value="">Lütfen Seçiniz</option>')
            .append('<option value="2">V-84 Ödeyen</option>')
            .append('<option value="3">V-84 Ödemeyen</option>');
    }
    else {
        $('#PayCalculate')
            .append('<option value="">Lütfen Seçiniz</option>')
            .append('<option value="1">Ödeyen</option>')
            .append('<option value="0">Ödemeyen</option>');
    }

    updateConditionalEntryDateRows();
}

function isConditionalEntryVisa() {
    return $('#VisaCalculate').val() === '7';
}

function updateConditionalEntryDateRows() {
    var isConditional = isConditionalEntryVisa();
    var $addButton = $('#GcAddButton');

    if (isConditional) {
        var $container = $('#date-rows-container');
        if ($container.length) {
            $container.find('.extra').remove();
        } else {
            $('#calculate-form').find('.extra').remove();
        }
        if (typeof reindexDateRows === 'function') reindexDateRows();
        $('.form-group.row, .date-pair-row').each(function () {
            computeDiffForRow($(this));
        });
    }

    if ($addButton.length) {
        $addButton
            .prop('disabled', isConditional)
            .toggleClass('disabled', isConditional)
            .attr('title', isConditional ? 'İkamet Şartlı Giriş (V-84) için sadece tek giriş-çıkış tarihi hesaplanır.' : '');
    }
}
// Rusya Federasyonu için Hesaplama Modeli senkronizasyonu
// Çoklu giriş-çıkışta otomatik '180 Gün Kuralı' (2), tek giriş-çıkışta 'Normal Hesaplama' (1)
function syncRussiaCalculationModel() {
    var country = ($('#CountryCalculate').val() || '').trim();
    if (country === 'Rusya Federasyonu') {
        var rowCount = $('.endt').length;
        var targetType = (rowCount > 1) ? '2' : '1';
        var $ctype = $('#CTypeCalculate');
        if ($ctype.length && $ctype.val() !== targetType) {
            $ctype.val(targetType);
            if ($.fn.select2) {
                try { $ctype.trigger('change.select2'); } catch (e) { }
            }
            $ctype.trigger('change');
        }
    }
}
window.syncRussiaCalculationModel = syncRussiaCalculationModel;

function hesapla1() {
    syncRussiaCalculationModel();
    try {
        if (typeof window.computeAllDiffs === 'function') {
            window.computeAllDiffs();
        } else if (typeof computeDiffForRow === 'function') {
            computeDiffForRow($('#EnterDateCalculate').closest('.date-pair-row, .form-group.row'));
        }
    } catch (e) { }
    var form = $('#calculate-form');
    $('#veri, #hes2, #hes3, #hes4, #form, #hes5').addClass('hidden');
    $('#PayCalculate').val('').change();

    var $Exit = $('#ExitDateCalculate').val(),
        $Enter = $('#EnterDateCalculate').val(),
        $Passport = $('#PassportCalculate').val(),
        $Country = $('#CountryCalculate').val(),
        $Visa = $('#VisaCalculate').val();

    if ($Visa === '7') {
        updateConditionalEntryDateRows();
    }

    if ($Visa == 4 || $Visa == 8 || $Visa == 10 || $Visa == 11 || $Visa == 12 || $Visa == 13 || $Visa == 15) {
        if ($('#testarihi').val() == '' || $('#testarihi').val() == null) {
            alert('Lütfen tarih giriniz..!');
            return false;
        }
    }

    $('#AdultCalculate').val('').change();

    var enter = document.getElementsByClassName("endt"),
        exit = document.getElementsByClassName("exdt"),
        i, totalDays = 0;

    for (i = 0; i < enter.length; i++) {
        var enterv = enter[i].value,
            exitv = exit[i].value;

        if (enterv === '' || exitv === '') return false;

        // Tarihleri Date objesine çevir; saat bilgileri gün hesabını etkilemez.
        var start = parseDMY(enterv),
            end = parseDMY(exitv);

        if (!start || !end) {
            alert('Tarih biçimi geçersiz!');
            return false;
        }

        if (start > end) {
            alert('Giriş tarihi çıkış tarihinden büyük olamaz!');
            return false;
        }

        // Günübirlik veya aynı gün giriş-çıkış kontrolü
        var diffDays = Math.floor((end - start) / (1000 * 60 * 60 * 24));
        if (diffDays === 0) diffDays = 1;

        totalDays += diffDays;
    }

    if ($Exit == "" || $Enter == "" || $Passport == "" || $Country == "" || $Visa == "") return false;

    $('#DayCalculate, #LongCalculate, #OneTimeCalculate, #BasCalculate, #BitCalculate, #CezaAyCalculate, #CezaGunCalculate, #SonucCalculate, #BirthDateCalculate').val('');
    $('#AdultCalculate').val('0');

    $.ajax({
        url: "/Calculate1",
        type: "POST",
        data: form.serialize(),
        dataType: "json",
        success: function (result) {
            if (result.Type == '0') {
                alert(result.Message);
                return false;
            }

            $('#veri').removeClass('hidden');
            $('#DayCalculate').val(result.Day);
            $('#LongCalculate').val(result.Daylong);
            $('#OneTimeCalculate').val(result.OneTime);

            // İkamet tezkeresi / tahdit hesaplarında başlangıç tarihi özel tarih alanıdır.
            if ($Visa == 4 || $Visa == 8 || $Visa == 10 || $Visa == 11 || $Visa == 12 || $Visa == 13 || $Visa == 14 || $Visa == 15) {
                $('#BasCalculate').val($('#testarihi').val());
            } else {
                $('#BasCalculate').val($Enter);
            }

            $('#BitCalculate').val(result.ShoulExtiTime);
            $('#CezaAyCalculate').val(result.FarkAy);
            $('#CezaGunCalculate').val(result.FarkGun);

            if (result.FarkAy == '0') {
                $('#SonucCalculate').val(result.FarkGun + ' Gün');
            } else {
                $('#SonucCalculate').val(parseInt(result.FarkGun) > 0 ? (parseInt(result.FarkAy) + 1) + ' Ay' : result.FarkAy + ' Ay');
            }

            // 180/90 kuralına göre tekrar giriş tarihini formdaki geçmiş giriş-çıkışlara göre hesapla ve göster
            try {
                computeReEntryFromForm();
            } catch (e) {
                console.warn('Re-entry hesaplama hatası', e);
            }
        }
    });
}

function adultchild(elem) {
    var strbirthDate = elem.value,
        formatted = '';
    var dizi = strbirthDate.split('.');
    for (var i = 0; i < dizi.length; i++) {
        formatted += dizi[2 - i] + '/'
    }
    formatted = formatted.substring(0, formatted.length - 1);
    var today = new Date();
    var birthDate = new Date(formatted);
    var age = today.getFullYear() - birthDate.getFullYear();
    var m = today.getMonth() - birthDate.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
        age--;
    }
    if (parseInt(age) < 18) {
        $('#AdultCalculate').val('1').change();
    }
    else {
        $('#AdultCalculate').val('2').change();
    }
    $('#BirthdateCFORM').val(strbirthDate);
}
function hesapla2() {
    var $Tckt = $('#SonucCalculate').val(),
        $Type = $('#AdultCalculate').val(),
        $Passport = $('#PassportCalculate').val(),
        $Visa = $('#VisaCalculate').val(),
        $Ctype = $('#CTypeCalculate').val(),
        $Country = $('#CountryCalculate').val();
    $('#hes2').addClass('hidden');
    $('#hes3').removeClass('hidden');
    $('#form').addClass('hidden');

    $('#PayCalculate').val('').change();
    $.ajax({
        url: "/Calculate2",
        type: "POST",
        data: {
            'Country': $Country,
            'Ticket': $Tckt,
            'Type': $Type,
            'Passport': $Passport,
            'Visa': $Visa,
            'CTtype': $Ctype,
            'Enter': $('#EnterDateCalculate').val(),
            'V137Expired': $('#V137ExpiredCalculate').val() === '1'
        },
        success: function (result) {
            $('#hes2').removeClass('hidden');
            $('#hes3').removeClass('hidden');
            $('#hes4').removeClass('hidden');
            $('#CezaCalculate').val(result.Fine);
            $('#ToMCalculate').val(result.ToM).change();
            $('#KurCalculate').html(result.Kur + ' == ' + result.KurPrice + '  TRY');
            $('#CezaTLCalculate').val(result.CTL);
            $('#VisaHarcCalculate').val(result.VH);
            $('#DefterCalculate').val(result.DFTR);
            $('#IdariCalculate').val(result.ID);
            $('#ToplamCalculate').val(result.toplam);
            $.ajax({
                url: "/addhistory",
                type: "POST",
                data: {
                    'bas': $('#BasCalculate').val(),
                    'sexit': $('#BitCalculate').val(),
                    'bdate': $('#BirthDateCalculate').val(),
                    'csure': $('#SonucCalculate').val(),
                    'ttutar': $('#ToplamCalculate').val(),
                    'country': $('#CountryCalculate').val()
                },
                success: function (result) {
                    if (typeof window.refreshHistoryCount === 'function') {
                        window.refreshHistoryCount();
                    }
                    $(document).trigger('historyCountChanged');
                }
            });
        }
    });

}
function fiyat(elem) {
    var currentInput = $(elem).val();
    var fixedInput = currentInput.replace(/[A-Za-z!@#$%^&*(). ]/g, '');
    $(elem).val(fixedInput);
}
// Yardımcı: "dd.mm.yyyy" -> Date veya null
function parseDMY(dateStr) {
    if (!dateStr) return null;
    var datePart = String(dateStr).trim().split(/\s+/)[0];
    var parts = datePart.split('.');
    if (parts.length !== 3) return null;
    var d = parseInt(parts[0], 10), m = parseInt(parts[1], 10) - 1, y = parseInt(parts[2], 10);
    var dt = new Date(y, m, d);
    if (dt && dt.getFullYear() === y && dt.getMonth() === m && dt.getDate() === d) return dt;
    return null;
}

// Bir satır için gün farkını hesaplayıp .pair-diff alanına yaz
function computeDiffForRow($row) {
    if (!$row || !$row.length) $row = $('#EnterDateCalculate').closest('.date-pair-row, .form-group.row');
    var $enter = $row.find('.endt').first();
    var $exit = $row.find('.exdt').first();
    var $diff = $row.find('.pair-diff').first();
    if (!$enter.length && $('#EnterDateCalculate').length) $enter = $('#EnterDateCalculate');
    if (!$exit.length && $('#ExitDateCalculate').length) $exit = $('#ExitDateCalculate');
    if (!$diff.length && $('#PairDiff_0').length) $diff = $('#PairDiff_0');
    if ($enter.length === 0 || $exit.length === 0 || $diff.length === 0) return;
    var ev = ($enter.val() || '').trim(), xv = ($exit.val() || '').trim();
    if (!ev || !xv) { $diff.val('').attr('placeholder', 'Gün'); return; }
    var start = (typeof parseDMY === 'function') ? parseDMY(ev) : null;
    var end = (typeof parseDMY === 'function') ? parseDMY(xv) : null;
    if (!start || !end || start > end) { $diff.val(start > end ? 'G > Ç' : 'Hatalı Tarih'); return; }
    var msPerDay = 1000 * 60 * 60 * 24;
    var uStart = Date.UTC(start.getFullYear(), start.getMonth(), start.getDate());
    var uEnd = Date.UTC(end.getFullYear(), end.getMonth(), end.getDate());
    var days = Math.round((uEnd - uStart) / msPerDay);
    if (days === 0) days = 1;
    $diff.val(days + ' Gün');
}

// Numaralandırma ve etiket senkronizasyonu
function reindexDateRows() {
    var $container = $('#date-rows-container');
    var $rows = $container.length ? $container.find('.date-pair-row') : $('.date-pair-row');
    $rows.each(function (i) {
        var idx = i + 1;
        $(this).find('.row-badge').text(idx);
    });
}

// Satır bazında tekil silme fonksiyonu
function gcremoveSpecificRow(btn) {
    var $row = $(btn).closest('.date-pair-row, .extra');
    if ($row.length) {
        $row.remove();
        reindexDateRows();
        $('.form-group.row, .date-pair-row').each(function () {
            computeDiffForRow($(this));
        });
        try { computeReEntryFromForm(); } catch (e) { }
        syncRussiaCalculationModel();
        if (typeof window.hesapla1 === 'function') {
            try { window.hesapla1(); } catch (e) { }
        }
    }
}

// Dinamik satır ekleme (TARİHLER ALT ALTA GELECEK ŞEKİLDE #date-rows-container İÇİNE EKLENİR)
function gcadd() {
    if (isConditionalEntryVisa()) {
        alert('İkamet Şartlı Giriş (V-84) için sadece 1 giriş ve 1 çıkış tarihi hesaplanır.');
        updateConditionalEntryDateRows();
        return false;
    }

    // Birden fazla giriş-çıkış ekleniyorsa hesaplama tipini kontrol et
    var $ctype = $('#CTypeCalculate');
    var $country = $('#CountryCalculate');
    var countryVal = ($country.val() || '').trim();
    if (countryVal === 'Rusya Federasyonu') {
        // Rusya Federasyonu için çoklu giriş-çıkışta otomatik 180 Gün Kuralı (2) seçilir
        if ($ctype.val() !== '2') {
            $ctype.val('2');
            if ($.fn.select2) {
                try { $ctype.trigger('change.select2'); } catch (e) { }
            }
            $ctype.trigger('change');
        }
    } else if ($ctype.val() === '1' && countryVal !== '') {
        alert('Birden fazla giriş-çıkış girişi yapıyorsunuz. Lütfen hesaplama tipinin doğru seçili olduğunu kontrol ediniz.');
    }

    var $form = $('#calculate-form');
    var nextIndex = ($form.data('gc-index') || 0) + 1;
    $form.data('gc-index', nextIndex);

    var labelNum = $('.endt').length + 1;
    var enterId = 'EnterDateCalculate_' + nextIndex;
    var exitId = 'ExitDateCalculate_' + nextIndex;
    var diffId = 'PairDiff_' + nextIndex;

    var html = ''
        + '<div class="form-group row form-row date-pair-row extra align-items-end mb-2" id="date-row-' + nextIndex + '">'
        + '<div class="col-xl-4 col-lg-4 col-md-4 col-sm-12 mb-2">'
        + '<label for="' + enterId + '" class="control-label font-weight-bold" style="font-size:12.5px;">'
        + '<i class="fas fa-sign-in-alt text-primary mr-1"></i> <span class="badge badge-primary mr-1 row-badge">' + labelNum + '</span> Giriş Tarihi'
        + '</label>'
        + '<div class="input-group">'
        + '<span class="input-group-prepend"><span class="input-group-text"><i class="fas fa-calendar-alt"></i></span></span>'
        + '<input autocomplete="off" onchange="hesapla1()" id="' + enterId + '" name="EnterDateCalculate" type="text" data-plugin-datepicker data-plugin-options=\'{"format":"dd.mm.yyyy","autoclose":"true","weekStart":"1","language":"tr","endDate":"+0d","orientation":"bottom"}\' class="form-control endt" placeholder="GG.AA.YYYY" />'
        + '</div></div>'
        + '<div class="col-xl-4 col-lg-4 col-md-4 col-sm-12 mb-2">'
        + '<label for="' + exitId + '" class="control-label font-weight-bold" style="font-size:12.5px;">'
        + '<i class="fas fa-sign-out-alt text-danger mr-1"></i> <span class="badge badge-danger mr-1 row-badge">' + labelNum + '</span> Çıkış Tarihi'
        + '</label>'
        + '<div class="input-group">'
        + '<span class="input-group-prepend"><span class="input-group-text"><i class="fas fa-calendar-alt"></i></span></span>'
        + '<input autocomplete="off" onchange="hesapla1()" id="' + exitId + '" name="ExitDateCalculate" type="text" data-plugin-datepicker data-plugin-options=\'{"format":"dd.mm.yyyy","autoclose":"true","weekStart":"1","language":"tr","orientation":"bottom"}\' class="form-control exdt" placeholder="GG.AA.YYYY" />'
        + '</div></div>'
        + '<div class="col-xl-3 col-lg-3 col-md-3 col-sm-10 mb-2">'
        + '<label for="' + diffId + '" class="control-label font-weight-bold" style="font-size:12.5px;">'
        + '<i class="fas fa-clock text-info mr-1"></i> Kalış Süresi'
        + '</label>'
        + '<input readonly id="' + diffId + '" class="form-control pair-diff" placeholder="Gün Farkı" />'
        + '</div>'
        + '<div class="col-xl-1 col-lg-1 col-md-1 col-sm-2 mb-2 text-center">'
        + '<button type="button" class="btn btn-sm btn-outline-danger btn-remove-row" onclick="gcremoveSpecificRow(this)" title="Bu satırı sil" style="border-radius:6px; padding:6px 10px;">'
        + '<i class="fas fa-trash-alt"></i>'
        + '</button>'
        + '</div>'
        + '</div>';

    var $row = $(html);
    var $container = $('#date-rows-container');
    if ($container.length) {
        $container.append($row);
    } else {
        var $firstRow = $('#EnterDateCalculate').closest('.date-pair-row, .form-group.row');
        if ($firstRow.length) {
            $firstRow.after($row);
        } else {
            $form.append($row);
        }
    }

    // datepicker başlatma: varsa bootstrapDP, yoksa standart datepicker
    var $newEndt = $row.find('.endt'), $newExdt = $row.find('.exdt');
    if (typeof $newEndt.bootstrapDP === 'function') {
        $newEndt.bootstrapDP({ dateFormat: 'dd.mm.yy', firstDay: 1, endDate: '+0d', language: 'tr', autoclose: true, orientation: 'bottom' });
        $newExdt.bootstrapDP({ dateFormat: 'dd.mm.yy', firstDay: 1, language: 'tr', autoclose: true, orientation: 'bottom' });
    } else if ($.fn.datepicker) {
        $newEndt.datepicker({ format: 'dd.mm.yyyy', autoclose: true, weekStart: 1, language: 'tr', endDate: '+0d', orientation: 'bottom' });
        $newExdt.datepicker({ format: 'dd.mm.yyyy', autoclose: true, weekStart: 1, language: 'tr', orientation: 'bottom' });
    }

    // değişiklik handler'ı
    $row.on('change changeDate input keyup blur', '.endt, .exdt', function () {
        computeDiffForRow($row);
    });

    // hemen hesapla/ göster
    syncRussiaCalculationModel();
    computeDiffForRow($row);
}

// Güvenli kaldırma ve etiket yeniden numaralandırma + diff tekrar hesapla
function gcremove(elem) {
    var $container = $('#date-rows-container');
    var $extra = $container.length ? $container.find('.extra').last() : $('#calculate-form').find('.extra').last();
    if ($extra.length === 0) return;
    $extra.remove();

    reindexDateRows();

    // tüm satırlar için diff'leri yeniden hesapla (statik ilk satır dahil)
    $('.form-group.row, .date-pair-row').each(function () {
        computeDiffForRow($(this));
    });
    try { computeReEntryFromForm(); } catch (e) { }
    syncRussiaCalculationModel();
    if (typeof window.hesapla1 === 'function') {
        try { window.hesapla1(); } catch (e) { }
    }
}
function tahdit1(elem) {
    $('#hes5').addClass('hidden');
    if (elem.value == '') { return false; }
    //if (elem.value == '2' || elem.value == '3') {
    //    if ($('#VisaCalculate').val() !== '7') {
    //        alert('Bu seçenek sadece ikamet şartlı giriş için seçilebilir..!');
    //        $(elem).val('').change();
    //        return false;
    //    }
    //}
    var Cezagun = $('#CezaGunCalculate').val(),
        Cezaay = $('#CezaAyCalculate').val(),
        Tip = elem.value,
        Adult = $('#AdultCalculate').val();
    $.ajax({
        url: "/Kodgetir",
        type: "POST",
        data: {
            'Cezagun': Cezagun,
            'Cezaay': Cezaay,
            'Tip': Tip,
            'Adult': Adult
        },
        success: function (result) {
            if (result.Type == "0") {
                alert(result.Rslt);
            }
            else {
                $('#form').addClass('hidden');
                $('#hes5').removeClass('hidden');
                $('#lastalert').html(result.Rslt);
                $('#DDayCFORM').val(result.CZ);
                $('#codeFORM').val(result.Code);

            }
        }
    });
}
function hesapla3() {
    $('#OrginCFORM').val($('#CountryCalculate').val());
    $('#EntryDateCFORM').val($('#EnterDateCalculate').val());
    $('#VisaDistanceCFORM').val($('#OneTimeCalculate').val());
    $('#ShouldExitCFORM').val($('#BitCalculate').val());
    $('#FineDayCFORM').val($('#SonucCalculate').val());
    $('#FinePriceCFORM').val($('#ToplamCalculate').val());
    $('#PaymentTypeCFORM').val($('#PayCalculate').val());
    $('#DefterCFORM').val($('#DefterCalculate').val());
    $('#CGunCFORM').val($('#CezaGunCalculate').val());
    $('#CAyCFORM').val($('#CezaAyCalculate').val());
    $('#visatype').val($('#VisaCalculate').val());
    $('#form').removeClass('hidden');
}
function deleterecord(Id) {
    var r = confirm("Kaydı silmek istediğinizde emin misiniz ?");
    if (r == false) {
        return false;
    }
    $.ajax({
        url: "/DeleteIsk",
        type: "POST",
        data: {
            'Id': Id
        },
        success: function (result) {
            alert(result.Message);
            location.href = result.Url;
        }
    });
}
function deleterecordhist(Id) {
    var r = confirm("Kaydı silmek istediğinizde emin misiniz ?");
    if (r == false) {
        return false;
    }
    $.ajax({
        url: "/DeleteHist",
        type: "POST",
        data: {
            'Id': Id
        },
        success: function (result) {
            alert(result.Message);
            location.href = result.Url;
        }
    });
}
function onayver(Id) {
    var r = confirm("Geçici kullanıcıya onay vereceksiniz ?");
    if (r == false) {
        return false;
    }
    $.ajax({
        url: "/submituser",
        type: "POST",
        data: {
            'Id': Id
        },
        success: function (result) {
            alert(result.Message);
            location.href = result.Url;
        }
    });
}
function deletetemp(Id) {
    var r = confirm("Geçici kullanıcıyı silmek istediğinizden emin misiniz?");
    if (r == false) {
        return false;
    }
    $.ajax({
        url: "/deletetempuser",
        type: "POST",
        data: {
            'Id': Id
        },
        success: function (result) {
            alert(result.Message);
            location.href = result.Url;
        }
    });
}
function deleteuser(Id) {
    var r = confirm("Kullanıcıyı silmek istediğinizden emin misiniz?");
    if (r == false) {
        return false;
    }
    $.ajax({
        url: "/deleteuser",
        type: "POST",
        data: {
            'Id': Id
        },
        success: function (result) {
            alert(result.Message);
            location.href = result.Url;
        }
    });
}
function getAnons(Id) {
    $.get("/getanons", { "Id": Id }, function (data) {
        $('#getAnonsTopic').val(data.Subject);
        $('#getAnonsExplain').html(data.Explain);
    });
}
function deleteAnons(Id) {
    var r = confirm("Anonsu silmek istediğinizden emin misiniz?");
    if (r == false) {
        return false;
    }
    $.get("/deleteanons", { "Id": Id }, function (data) {
        alert(data.Message);
        location.href = data.Href;
    });
}
function getMessages(Id) {
    $.get("/getMessages", { "Id": Id }, function (data) {
        $('#NameUser').val(data.Model.fldSendByName);
        $('#sicilUser').val(data.Model.fldSendBySicil);
        $('#PhoneUser').val(data.Model.fldSendByPhone);
        $('#EmailUser').val(data.Model.fldSendByMail);
        $('#MessageUser').val(data.Model.fldMessage);
    });
}
function addborder() {
    var border = prompt('Lütfen Sınır Kapısı İsmi Giriniz... Örn (Gazipaşa-hava) ');
    $.ajax({
        url: "/addborder",
        type: "POST",
        data: {
            'border': border,
            '__RequestVerificationToken': $('input[name="__RequestVerificationToken"]').first().val()
        },
        success: function (result) {
            eval(result.command);
        }
    });
}
function deleteborder(Id) {
    var r = confirm("Kapıyı silmek istediğinizden emin misiniz?");
    if (r == false) {
        return false;
    }
    $.ajax({
        url: "/deleteborder",
        type: "POST",
        data: {
            'Id': Id,
            '__RequestVerificationToken': $('input[name="__RequestVerificationToken"]').first().val()
        },
        success: function (result) {
            eval(result.command);
        }
    });
}
$(function () {
    // Rusya Federasyonu için ülke değiştiğinde hesaplama modelini senkronize et
    $(document).on('change', '#CountryCalculate', function () {
        syncRussiaCalculationModel();
    });
    // Delegated handler: form içindeki tüm .endt / .exdt değişikliklerinde diff hesapla
    $(document).on('change changeDate input keyup blur', '.endt, .exdt', function () {
        var $row = $(this).closest('.date-pair-row, .form-group.row');
        computeDiffForRow($row);
        try { computeReEntryFromForm(); } catch (e) { }
    });

    // Sayfa yüklenince ilk (statik) satırı hesapla (varsa)
    var $firstRow = $('#EnterDateCalculate').closest('.form-group.row');
    if ($firstRow.length) computeDiffForRow($firstRow);
    try { computeReEntryFromForm(); } catch (e) { }
    syncRussiaCalculationModel();
});
