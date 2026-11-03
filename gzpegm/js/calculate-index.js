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

    function getWindowDaysConfig() {
        var country = ($('#CountryCalculate').val() || '').trim();
        if (country === 'Beyaz Rusya') return 365;
        var dayVal = parseInt($('#DayCalculate').val(), 10);
        return (dayVal > 0) ? dayVal : 180;
    }

    /**
     * Formdaki tüm giriş-çıkış çiftlerinin gün farkını ve kayan pencere (180/365 gün) kapsamındaki gününü hesaplar
     */
    function computeAllDiffs(serverSeferler) {
        var rows = [];
        var maxExitTime = 0;
        var msPerDay = 1000 * 60 * 60 * 24;

        $('.endt').each(function (idx) {
            var $enter = $(this);
            var $row = $enter.closest('.date-pair-row, .form-group.row');
            if (!$row.length) $row = $enter.parent().parent();
            var $exit = $row.find('.exdt').first();
            var $diff = $row.find('.pair-diff').first();
            var $badge = $row.find('.window-diff-badge');
            if (!$badge.length) {
                $badge = $('<div class="window-diff-badge mt-1" style="font-size:11.5px; font-weight:600;"></div>');
                $diff.after($badge);
            }

            var ev = ($enter.val() || '').trim();
            var xv = ($exit.val() || '').trim();
            var start = parseDate(ev);
            var end = parseDate(xv);

            var item = {
                index: idx,
                $diff: $diff,
                $badge: $badge,
                start: start,
                end: end,
                valid: (start && end && start <= end),
                rawDays: 0
            };

            if (item.valid) {
                var uStart = Date.UTC(start.getFullYear(), start.getMonth(), start.getDate());
                var uEnd = Date.UTC(end.getFullYear(), end.getMonth(), end.getDate());
                var days = Math.round((uEnd - uStart) / msPerDay);
                item.rawDays = (days === 0) ? 1 : days;
                if (end.getTime() > maxExitTime) {
                    maxExitTime = end.getTime();
                }
            } else if (ev && xv && start && end && start > end) {
                $diff.val('G > Ç');
                $badge.empty();
            } else {
                $diff.val('').attr('placeholder', 'Gün');
                $badge.empty();
            }

            rows.push(item);
        });

        var validRows = rows.filter(function (r) { return r.valid; });
        var hasMultiple = validRows.length > 1;
        var windowDaysConfig = getWindowDaysConfig();

        var maxExitDate = new Date(maxExitTime);
        var windowStartDate = new Date(maxExitDate.getTime());
        windowStartDate.setDate(windowStartDate.getDate() - windowDaysConfig);

        rows.forEach(function (r, i) {
            if (!r.valid) return;

            var rawDays = r.rawDays;

            if (!hasMultiple) {
                r.$diff.val(rawDays + ' Gün');
                r.$badge.empty();
                return;
            }

            var windowStay = 0;
            if (serverSeferler && serverSeferler.length > i && typeof serverSeferler[i] === 'number') {
                windowStay = serverSeferler[i];
            } else {
                if (r.end < windowStartDate) {
                    windowStay = 0;
                } else {
                    var cStart = r.start < windowStartDate ? windowStartDate : r.start;
                    var cExit = r.end > maxExitDate ? maxExitDate : r.end;
                    var uCS = Date.UTC(cStart.getFullYear(), cStart.getMonth(), cStart.getDate());
                    var uCE = Date.UTC(cExit.getFullYear(), cExit.getMonth(), cExit.getDate());
                    var diffW = Math.round((uCE - uCS) / msPerDay);
                    windowStay = (diffW === 0 && uCS <= uCE) ? 1 : Math.max(0, diffW);
                }
            }

            // Kullanıcı talebi: Mevcut kalış günü dursun (örn. 80 Gün), ek olarak 180G içindeki süre yansıtılsın
            if (windowStay === 0) {
                r.$diff.val(rawDays + ' Gün (' + windowDaysConfig + 'G Dışı: 0 G)');
                r.$badge.html('<span class="badge badge-secondary p-1" style="font-size:11px;"><i class="fas fa-history mr-1"></i>' + windowDaysConfig + ' Gün Dışı (0 G Dahil)</span>');
            } else if (windowStay < rawDays) {
                var excludedDays = rawDays - windowStay;
                r.$diff.val(rawDays + ' Gün (' + windowDaysConfig + 'G: ' + windowStay + ' G)');
                r.$badge.html('<span class="badge badge-warning text-dark p-1" style="font-size:11px; font-weight:700;"><i class="fas fa-filter mr-1"></i>' + windowDaysConfig + 'G Kapsamı: ' + windowStay + ' Gün</span> <span class="text-muted font-italic" style="font-size:10.5px;">(' + excludedDays + ' gün ' + windowDaysConfig + ' gün öncesi)</span>');
            } else {
                r.$diff.val(rawDays + ' Gün (' + windowDaysConfig + 'G: ' + windowStay + ' G)');
                r.$badge.html('<span class="badge badge-success p-1" style="font-size:11px; font-weight:700;"><i class="fas fa-check-circle mr-1"></i>' + windowDaysConfig + 'G Kapsamı: ' + windowStay + ' Gün</span>');
            }
        });
    }

    function computePairDiff(context) {
        computeAllDiffs();
    }

    window.computePairDiff = computePairDiff;
    window.computeAllDiffs = computeAllDiffs;

    var originalComputeDiffForRow = window.computeDiffForRow;
    window.computeDiffForRow = function ($row) {
        computeAllDiffs();
        if (typeof originalComputeDiffForRow === 'function') {
            try { originalComputeDiffForRow($row); } catch (e) { }
        }
    };
    /**
     * Sınır kapısı toplam işlem sayısını sunucudan çeker (Kullanıcı isteğiyle iptal edildi - Sıfır DB yükü)
     */
    function refreshHistoryCount() {
        // İptal edildi: Veritabanı sorgusu ve UI gecikmesi önlendi
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