/* ==========================================================================
   Ceza Hesaplama JavaScript (calculate-index.js) - Profesyonel Kabin Sürümü
   Sade, Hızlı ve Akıcı Tek Ekran Deneyimi (v3.0)
   ========================================================================== */

(function ($) {
    'use strict';

    /**
     * "dd.mm.yyyy" stringini Date objesine çevirir
     */
    function parseDate(dateStr) {
        if (!dateStr) return null;
        if (typeof window.parseDMY === 'function') {
            return window.parseDMY(dateStr);
        }
        var parts = String(dateStr).trim().split(/\s+/)[0].split('.');
        if (parts.length !== 3) return null;
        var d = parseInt(parts[0], 10), m = parseInt(parts[1], 10) - 1, y = parseInt(parts[2], 10);
        var dt = new Date(y, m, d);
        if (dt && dt.getFullYear() === y && dt.getMonth() === m && dt.getDate() === d) return dt;
        return null;
    }

    /**
     * Tek bir satır için gün farkını hesaplayıp .pair-diff alanına yazar
     */
    function computePairDiff(context) {
        var $ctx = $(context || '#EnterDateCalculate');
        var $row;

        if ($ctx.is('.date-pair-row')) {
            $row = $ctx;
        } else {
            $row = $ctx.closest('.date-pair-row');
            if (!$row.length) {
                $row = $ctx.closest('.form-group.row');
            }
        }

        var $enter = ($row.length) ? $row.find('.endt').first() : $();
        var $exit  = ($row.length) ? $row.find('.exdt').first() : $();
        var $diff  = ($row.length) ? $row.find('.pair-diff').first() : $();

        // İlk (statik) satır için mutlak fallback
        if (!$enter.length || $enter.attr('id') === 'EnterDateCalculate' || $ctx.attr('id') === 'EnterDateCalculate' || $ctx.attr('id') === 'ExitDateCalculate' || $ctx.attr('id') === 'PairDiff_0') {
            if (!$enter.length) $enter = $('#EnterDateCalculate');
            if (!$exit.length)  $exit  = $('#ExitDateCalculate');
            if (!$diff.length)  $diff  = $('#PairDiff_0');
        }

        if (!$enter.length || !$exit.length || !$diff.length) return;

        var ev = ($enter.val() || '').trim();
        var xv = ($exit.val() || '').trim();

        if (!ev || !xv) {
            $diff.val('').attr('placeholder', 'Gün');
            return;
        }

        var start = parseDate(ev);
        var end = parseDate(xv);

        if (!start || !end) {
            $diff.val('Hatalı');
            return;
        }

        if (start > end) {
            $diff.val('G > Ç');
            return;
        }

        var msPerDay = 1000 * 60 * 60 * 24;
        var uStart = Date.UTC(start.getFullYear(), start.getMonth(), start.getDate());
        var uEnd = Date.UTC(end.getFullYear(), end.getMonth(), end.getDate());
        var days = Math.round((uEnd - uStart) / msPerDay);
        if (days === 0) days = 1;

        $diff.val(days + ' Gün');
    }

    window.computePairDiff = computePairDiff;

    /**
     * Formdaki tüm giriş-çıkış çiftlerinin gün farkını hesaplar
     */
    function computeAllDiffs() {
        computePairDiff($('#EnterDateCalculate'));
        $('.date-pair-row.extra, .extra').each(function () {
            computePairDiff(this);
        });
    }

    window.computeAllDiffs = computeAllDiffs;

    var originalComputeDiffForRow = window.computeDiffForRow;
    window.computeDiffForRow = function ($row) {
        if ($row && $row.length) {
            computePairDiff($row);
        } else {
            computeAllDiffs();
        }
        if (typeof originalComputeDiffForRow === 'function') {
            try { originalComputeDiffForRow($row); } catch (e) { }
        }
    };

    /**
     * Sınır kapısı toplam işlem sayısını sunucudan çeker
     */
    function refreshHistoryCount() {
        if (!$) return;
        $.ajax({
            url: '/Calculate/GetHistoryCount',
            type: 'GET',
            dataType: 'json',
            cache: false,
            success: function (res) {
                if (res && typeof res.count !== 'undefined') {
                    var $el = $('#userHistoryCount');
                    if ($el.length) {
                        $el.text(res.count);
                    }
                }
            },
            error: function () { }
        });
    }

    window.refreshHistoryCount = refreshHistoryCount;

    /**
     * 180/90 Tekrar Giriş Hesabını Yeniler
     */
    function refreshReEntry() {
        if (typeof window.computeReEntryFromForm === 'function') {
            window.computeReEntryFromForm();
        }
    }

    /**
     * Sağ paneldeki boş yer tutucu (placeholder) ile sonuç bölümlerini senkronize eder
     */
    function syncSummaryPlaceholder() {
        var isVeriVisible = !$('#veri').hasClass('hidden');
        var isHes3Visible = !$('#hes3').hasClass('hidden');
        var $placeholder = $('#calc-empty-placeholder');

        if (isVeriVisible || isHes3Visible) {
            $placeholder.hide();
        } else {
            $placeholder.show();
        }

        // İhlal süresine göre banner rengini ayarla (İhlal var: kırmızı, İhlal yok: yeşil)
        var sonuc = ($('#SonucCalculate').val() || '').trim();
        var $banner = $('.violation-banner');
        if (sonuc && (sonuc === '0 Gün' || sonuc.indexOf('0 ') === 0)) {
            $banner.removeClass('has-fine').addClass('no-fine');
        } else if (sonuc) {
            $banner.removeClass('no-fine').addClass('has-fine');
        }
    }

    /**
     * Tüm hesaplama formunu temizler ve yeni yolcu için hazırlar
     */
    function resetCalculateForm() {
        var $form = $('#calculate-form');
        if (!$form.length) return;

        // Ekstra giriş-çıkış satırlarını temizle
        $('#date-rows-container, #calculate-form').find('.extra').remove();
        $form.data('gc-index', 0);
        if (typeof window.reindexDateRows === 'function') {
            try { window.reindexDateRows(); } catch (e) { }
        }

        // Giriş alanlarını sıfırla
        $('#EnterDateCalculate').val('');
        var today = new Date();
        var dd = ('0' + today.getDate()).slice(-2);
        var mm = ('0' + (today.getMonth() + 1)).slice(-2);
        var yyyy = today.getFullYear();
        $('#ExitDateCalculate').val(dd + '.' + mm + '.' + yyyy);
        $('#PairDiff_0').val('').attr('placeholder', 'Gün');

        // Select2 alanlarını sıfırla
        if ($.fn.select2) {
            $('#CTypeCalculate').val('1').trigger('change.select2');
            $('#PassportCalculate').val('1').trigger('change.select2');
            $('#CountryCalculate').val('').trigger('change.select2');
            $('#VisaCalculate').val('2').trigger('change.select2');
            $('#PayCalculate').val('').trigger('change.select2');
        } else {
            $('#CTypeCalculate').val('1');
            $('#PassportCalculate').val('1');
            $('#CountryCalculate').val('');
            $('#VisaCalculate').val('2');
            $('#PayCalculate').val('');
        }

        $('#AdultCalculate').val('2'); // Varsayılan Yetişkin
        $('#Visaday, #testarihi, #BirthDateCalculate').val('');
        $('#V137ExpiredCalculate').val('0');

        // Sonuç bölümlerini gizle ve temizle
        $('#veri, #hes2, #hes3, #hes4, #hes5, #form, #ikametli, #v137SureDurumu').addClass('hidden');
        $('#DayCalculate, #LongCalculate, #OneTimeCalculate, #BasCalculate, #BitCalculate').val('');
        $('#CezaAyCalculate, #CezaGunCalculate, #SonucCalculate, #ReEntryCalculate').val('');
        $('#CezaCalculate, #KurCalculate, #CezaTLCalculate, #VisaHarcCalculate, #DefterCalculate, #IdariCalculate, #ToplamCalculate').val('');
        $('#KurCalculate').text('');
        $('#lastalert').html('');

        // PDF form alanlarını temizle (Memur sicili hariç)
        $('#form').find('input:not(#PoliceCFORM)').val('');

        syncSummaryPlaceholder();

        // İlk girişe odaklan
        $('#EnterDateCalculate').focus();

        computeAllDiffs();
    }

    window.resetCalculateForm = resetCalculateForm;

    $(document).ready(function () {
        // İlk yüklemede toplam işlem sayısını al
        refreshHistoryCount();

        // Tarih değişikliklerinde gün farkını hesapla
        $(document).on('change changeDate input keyup blur', '.endt, .exdt', function () {
            computePairDiff(this);
            refreshReEntry();
        });

        // Datepicker ile tarih tıklandığında anında diff ve hesapla1 tetikle
        $(document).on('changeDate', '.endt, .exdt', function () {
            computePairDiff(this);
            if (typeof window.hesapla1 === 'function') {
                try { window.hesapla1(); } catch (e) { }
            }
        });

        // Ödeme tercihi seçildiğinde tahdit kodunu getir ve tutanak formunu otomatik doldur
        $(document).on('change', '#PayCalculate', function () {
            var val = $(this).val();
            if (val !== '' && typeof window.hesapla3 === 'function') {
                setTimeout(function () {
                    window.hesapla3();
                }, 400);
            }
        });

        // Doğum tarihi veya yaş grubu girildiğinde ihlal varsa otomatik hesapla2 tetikle
        $(document).on('change changeDate', '#BirthDateCalculate', function () {
            var sonuc = ($('#SonucCalculate').val() || '').trim();
            if (sonuc && typeof window.hesapla2 === 'function') {
                setTimeout(function () {
                    window.hesapla2();
                }, 200);
            }
        });

        // Sağ panel yer tutucusunu izle ve güncelle
        var observer = new MutationObserver(syncSummaryPlaceholder);
        ['veri', 'hes2', 'hes3', 'hes4', 'hes5'].forEach(function (id) {
            var el = document.getElementById(id);
            if (el) observer.observe(el, { attributes: true, attributeFilter: ['class'] });
        });
        syncSummaryPlaceholder();

        computeAllDiffs();
        refreshReEntry();
    });

})(window.jQuery);
