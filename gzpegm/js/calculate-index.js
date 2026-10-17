/* ==========================================================================
   Ceza Hesaplama JavaScript (calculate-index.js)
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
     * Tek bir satır veya eleman için gün farkını hesaplayıp .pair-diff alanına yazar
     */
    function computePairDiff(context) {
        var $ctx = $(context);
        var $row = $ctx.is('.form-group, .form-row, .extra, .date-pair-row') ? $ctx : $ctx.closest('.form-group.row, .form-row, .extra, .date-pair-row, .mb-3');
        if (!$row.length) $row = $ctx.closest('#step1-card');

        var $enter = $row.find('.endt').first();
        var $exit = $row.find('.exdt').first();
        var $diff = $row.find('.pair-diff').first();

        // Eğer row içinde bulunamadıysa statik ilk satır kontrolü
        if (!$diff.length && $enter.attr('id') === 'EnterDateCalculate') {
            $diff = $('#PairDiff_0');
        }

        if (!$enter.length || !$exit.length || !$diff.length) return;

        var ev = ($enter.val() || '').trim();
        var xv = ($exit.val() || '').trim();

        if (!ev || !xv) {
            $diff.val('').attr('placeholder', 'Gün Farkı');
            return;
        }

        var start = parseDate(ev);
        var end = parseDate(xv);

        if (!start || !end) {
            $diff.val('Geçersiz Tarih');
            return;
        }

        if (start > end) {
            $diff.val('Giriş > Çıkış');
            return;
        }

        var msPerDay = 1000 * 60 * 60 * 24;
        var days = Math.floor((end - start) / msPerDay);
        if (days === 0) days = 1;

        $diff.val(days + ' Gün');
    }

    window.computePairDiff = computePairDiff;

    /**
     * Formdaki tüm giriş-çıkış çiftlerinin gün farkını hesaplar
     */
    function computeAllDiffs() {
        $('.endt').each(function () {
            computePairDiff(this);
        });
    }

    window.computeAllDiffs = computeAllDiffs;

    // custom.js içindeki computeDiffForRow'u genişletip güçlü hale getir
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
     * Sınır kapısı ve kullanıcı bazlı toplam işlem sayısını sunucudan çeker
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
        $('#PairDiff_0').val('').attr('placeholder', 'Gün Farkı');

        // Select2 alanlarını sıfırla
        if ($.fn.select2) {
            $('#CTypeCalculate').val('1').trigger('change.select2');
            $('#PassportCalculate').val('1').trigger('change.select2');
            $('#CountryCalculate').val('').trigger('change.select2');
            $('#VisaCalculate').val('2').trigger('change.select2');
            $('#AdultCalculate').val('').trigger('change.select2');
            $('#PayCalculate').val('').trigger('change.select2');
        } else {
            $('#CTypeCalculate').val('1');
            $('#PassportCalculate').val('1');
            $('#CountryCalculate').val('');
            $('#VisaCalculate').val('2');
            $('#AdultCalculate').val('');
            $('#PayCalculate').val('');
        }

        $('#Visaday, #testarihi, #BirthDateCalculate').val('');
        $('#V137ExpiredCalculate').val('0');

        // Sonuç bölümlerini gizle ve temizle
        $('#veri, #hes2, #hes3, #hes4, #hes5, #form, #ikametli, #v137SureDurumu').addClass('hidden');
        $('#DayCalculate, #LongCalculate, #OneTimeCalculate, #BasCalculate, #BitCalculate').val('');
        $('#CezaAyCalculate, #CezaGunCalculate, #SonucCalculate, #ReEntryCalculate').val('');
        $('#CezaCalculate, #KurCalculate, #CezaTLCalculate, #VisaHarcCalculate, #DefterCalculate, #IdariCalculate, #ToplamCalculate').val('');
        $('#KurCalculate').text('');
        $('#lastalert').html('');

        // PDF form alanlarını temizle (Memur adı hariç)
        $('#form').find('input:not(#PoliceCFORM)').val('');

        // İlk girişe odaklan
        $('#EnterDateCalculate').focus();

        computeAllDiffs();
    }

    window.resetCalculateForm = resetCalculateForm;

    /**
     * Yeni bir bölüm görünür olduğunda yumuşak kaydırma
     */
    function observeVisibilityAndScroll() {
        var targets = ['#veri', '#hes2', '#hes5', '#form'];
        targets.forEach(function (sel) {
            var el = document.querySelector(sel);
            if (!el) return;

            var prevHidden = el.classList.contains('hidden');
            var observer = new MutationObserver(function () {
                var isHidden = el.classList.contains('hidden');
                if (prevHidden && !isHidden) {
                    try {
                        el.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
                    } catch (e) { }
                }
                prevHidden = isHidden;
            });
            observer.observe(el, { attributes: true, attributeFilter: ['class'] });
        });
    }

    $(document).ready(function () {
        // İlk yüklemede toplam işlem sayısını al
        refreshHistoryCount();

        // Tarih değişikliklerinde hem gün farkını hem re-entry'yi anında hesapla
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

        // Tarih ekleme/silme veya işlem kaydında sayacı ve gün farklarını yenile
        $(document).on('historyCountChanged', function () {
            refreshHistoryCount();
            computeAllDiffs();
        });

        // Adım geçişlerinde yumuşak kaydırma
        observeVisibilityAndScroll();

        // Adım 3 kartının görünürlüğünü senkronize et
        function syncStep3Card() {
            var $step3 = $('#step3-card');
            if (!$step3.length) return;
            var isAnyVisible = !$('#hes2').hasClass('hidden') || !$('#hes3').hasClass('hidden') || !$('#hes4').hasClass('hidden');
            $step3.toggleClass('is-visible', isAnyVisible);
        }

        var observerStep3 = new MutationObserver(syncStep3Card);
        ['#hes2', '#hes3', '#hes4'].forEach(function (id) {
            var el = document.querySelector(id);
            if (el) observerStep3.observe(el, { attributes: true, attributeFilter: ['class'] });
        });
        syncStep3Card();

        // Sayfa açıldığında tüm diff'leri ve re-entry'yi hesapla
        computeAllDiffs();
        refreshReEntry();
    });

})(window.jQuery);
