/* ==========================================================================
   Ana Sayfa Dashboard JavaScript (home-index.js)
   ========================================================================== */

var _homeCfg = document.getElementById('home-config');

// --- Modal Kontrolleri ---
(function () {
    try {
        if (!_homeCfg) return;

        var forceUnread = _homeCfg.getAttribute('data-force-unread-modal') === 'true';
        var hasNewCourses = _homeCfg.getAttribute('data-has-new-courses') === 'true';
        var courseModalKey = _homeCfg.getAttribute('data-new-course-key') || '';

        if (forceUnread) {
            try { sessionStorage.removeItem('unreadModalClosed'); } catch (e) { }
            setTimeout(function () {
                var modal = document.getElementById('unreadMessageModal');
                if (!modal) return;
                try {
                    if (typeof $ !== 'undefined' && $.fn && $.fn.modal) { $(modal).modal('show'); return; }
                } catch (e) { console.error(e); }
                try { if (typeof bootstrap !== 'undefined' && bootstrap.Modal) { new bootstrap.Modal(modal).show(); return; } } catch (e) { console.error(e); }
                modal.style.display = 'block';
            }, 200);
        }

        if (hasNewCourses && courseModalKey) {
            var modalKey = 'newCourseModalClosed:' + courseModalKey;

            function markClosed() {
                try { sessionStorage.setItem(modalKey, '1'); } catch (e) { }
            }

            function alreadyClosed() {
                try { return sessionStorage.getItem(modalKey) === '1'; } catch (e) { return false; }
            }

            function showNewCourseModal() {
                if (alreadyClosed()) return;
                var modal = document.getElementById('newCourseModal');
                if (!modal) return;
                try {
                    if (typeof $ !== 'undefined' && $.fn && $.fn.modal) {
                        $(modal).modal('show');
                        return;
                    }
                } catch (e) { console.error(e); }
                try {
                    if (typeof bootstrap !== 'undefined' && bootstrap.Modal) {
                        new bootstrap.Modal(modal).show();
                        return;
                    }
                } catch (e) { console.error(e); }
                modal.style.display = 'block';
            }

            setTimeout(function () {
                var unreadModal = document.getElementById('unreadMessageModal');
                var shouldWaitUnread = unreadModal && forceUnread;

                if (shouldWaitUnread && typeof $ !== 'undefined' && $.fn && $.fn.modal) {
                    $(unreadModal).one('hidden.bs.modal', function () {
                        setTimeout(showNewCourseModal, 250);
                    });
                    setTimeout(function () {
                        if (!$(unreadModal).hasClass('show')) showNewCourseModal();
                    }, 1600);
                } else {
                    showNewCourseModal();
                }
            }, 450);

            if (typeof $ !== 'undefined') {
                $('#newCourseModal').on('hidden.bs.modal', markClosed);
            }
        }
    } catch (err) {
        console.warn('Modal init warning:', err);
    }
})();

// --- Grafik ve Etkileşim Scriptleri ---
(function () {
    'use strict';
    try {
        var homeCharts = {};
        var profileHistoryLabels = [];
        var profileHistoryData = [];

        try {
            var rawLabels = _homeCfg ? _homeCfg.getAttribute('data-history-labels') : null;
            if (rawLabels) profileHistoryLabels = JSON.parse(rawLabels);
        } catch (e) { profileHistoryLabels = []; }

        try {
            var rawData = _homeCfg ? _homeCfg.getAttribute('data-history-data') : null;
            if (rawData) profileHistoryData = JSON.parse(rawData);
        } catch (e) { profileHistoryData = []; }

        var palette = ['#2f6f9f', '#3f7f68', '#8a6d3b', '#9b4d4d', '#476f95', '#5e6c84'];

        function formatNumber(value) {
            return new Intl.NumberFormat('tr-TR').format(Number(value) || 0);
        }

        function formatMoney(value) {
            return new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY', maximumFractionDigits: 0 }).format(Number(value) || 0);
        }

        function setText(id, value) {
            var el = document.getElementById(id);
            if (el) el.textContent = value;
        }

        function getDatasetValue(context, data) {
            var datasetIndex = context.datasetIndex !== undefined ? context.datasetIndex : 0;
            var valueIndex = context.index !== undefined ? context.index : context.dataIndex;
            var ds = data && data.datasets ? data.datasets[datasetIndex] || {} : {};
            if (ds.data && valueIndex !== undefined && ds.data[valueIndex] !== undefined) {
                return ds.data[valueIndex];
            }
            if (context.xLabel !== undefined) return context.xLabel;
            if (context.yLabel !== undefined) return context.yLabel;
            if (context.value !== undefined) return context.value;
            return 0;
        }

        function showGraphEmpty(show) {
            var empty = document.getElementById('homeGraphEmpty');
            var grid = document.getElementById('homeGraphGrid');
            if (empty) empty.style.display = show ? 'block' : 'none';
            if (grid) grid.style.display = show ? 'none' : 'grid';
        }

        function destroyChart(id) {
            if (homeCharts[id]) {
                homeCharts[id].destroy();
                delete homeCharts[id];
            }
        }

        function renderChart(canvasId, type, labels, datasets, options) {
            destroyChart(canvasId);
            var canvas = document.getElementById(canvasId);
            if (!canvas || !labels || labels.length === 0 || typeof Chart === 'undefined') return;

            homeCharts[canvasId] = new Chart(canvas, {
                type: type,
                data: { labels: labels, datasets: datasets },
                options: $.extend(true, {
                    responsive: true,
                    maintainAspectRatio: false,
                    legend: { position: 'bottom', labels: { boxWidth: 12, fontSize: 11 } },
                    tooltips: {
                        callbacks: {
                            label: function (tooltipItem, data) {
                                var ds = data.datasets[tooltipItem.datasetIndex] || {};
                                var val = getDatasetValue(tooltipItem, data);
                                return ds.label + ': ' + (ds.money ? formatMoney(val) : formatNumber(val));
                            }
                        }
                    }
                }, options || {})
            });
        }

        function renderHomeGraph(res) {
            var summary = res && res.summary ? res.summary : {};
            setText('homeGraphCalculations', formatNumber(summary.totalCalculations));
            setText('homeGraphMoney', formatMoney(summary.totalMoney));
            setText('homeGraphScope', formatNumber(summary.countryCount) + ' / ' + formatNumber(summary.borderCount));
            setText('homeGraphInadSartli', formatNumber(summary.inadCount) + ' / ' + formatNumber(summary.sartliCount));

            var borderStats = res.kapiParaTop || [];
            var countries = res.ulkeTop || [];
            showGraphEmpty(borderStats.length === 0 && countries.length === 0);

            if (borderStats.length) {
                renderChart('homeMonthlyChart', 'bar', borderStats.map(function (x) { return x.Border || 'Belirtilmemiş'; }), [
                    { label: 'İşlem Sayısı', data: borderStats.map(function (x) { return x.Count; }), backgroundColor: 'rgba(47, 111, 159, .72)', borderColor: '#2f6f9f', borderWidth: 1 },
                    { label: 'Ceza Tutarı', data: borderStats.map(function (x) { return x.ToplamPara; }), type: 'line', fill: false, borderColor: '#3f7f68', backgroundColor: '#3f7f68', yAxisID: 'money-axis', money: true }
                ], {
                    scales: {
                        xAxes: [{ ticks: { autoSkip: false, maxRotation: 35, minRotation: 0 } }],
                        yAxes: [
                            { id: 'count-axis', position: 'left', ticks: { beginAtZero: true, callback: formatNumber } },
                            { id: 'money-axis', position: 'right', gridLines: { drawOnChartArea: false }, ticks: { beginAtZero: true, callback: formatMoney } }
                        ]
                    }
                });
            }

            if (countries.length) {
                renderChart('homeCountryChart', 'horizontalBar', countries.map(function (x) { return x.Country; }), [{
                    label: 'Ceza Sayısı',
                    data: countries.map(function (x) { return x.Count; }),
                    backgroundColor: palette,
                    borderWidth: 0
                }], {
                    layout: { padding: { right: 28 } },
                    scales: { xAxes: [{ ticks: { beginAtZero: true, callback: formatNumber } }] },
                    plugins: {
                        datalabels: {
                            anchor: 'end',
                            align: 'right',
                            clamp: true,
                            formatter: function (value) { return formatNumber(value); }
                        }
                    }
                });
            }
        }

        function renderProfileHistoryChart() {
            if (!profileHistoryData || !profileHistoryData.length) return;
            renderChart('homeProfileHistoryChart', 'bar', profileHistoryLabels, [{
                label: 'İşlem Sayısı',
                data: profileHistoryData,
                backgroundColor: 'rgba(63, 127, 104, .72)',
                borderColor: '#3f7f68',
                borderWidth: 1
            }], {
                legend: { display: false },
                scales: {
                    yAxes: [{ ticks: { beginAtZero: true, precision: 0, callback: formatNumber } }],
                    xAxes: [{ ticks: { autoSkip: false, maxRotation: 35, minRotation: 0 } }]
                }
            });
        }

        function loadHomeGraph() {
            if (typeof Chart === 'undefined' || typeof $ === 'undefined') {
                showGraphEmpty(true);
                return;
            }

            $.getJSON(((_homeCfg && _homeCfg.getAttribute('data-chart-url')) || '/Grafik/ChartData'))
                .done(function (res) {
                    if (!res || !res.success) {
                        showGraphEmpty(true);
                        return;
                    }
                    renderHomeGraph(res);
                })
                .always(function () {
                    renderProfileHistoryChart();
                })
                .fail(function () {
                    showGraphEmpty(true);
                });
        }

        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', loadHomeGraph);
        } else {
            loadHomeGraph();
            renderProfileHistoryChart();
        }
    } catch (err) {
        console.warn('Graph init warning:', err);
    }
})();

// --- Kaşe Vize Kontrolü (GİGM 2014/2018 Talimatı & 6458 Sayılı Kanun m.7/1-b) ---
(function () {
    'use strict';

    function showModal(modalEl) {
        if (!modalEl) modalEl = document.getElementById('kaseVizeModal');
        if (!modalEl) return;

        // Bootstrap modal backdrop sorunlarını önlemek için modalı body altına taşı
        try {
            if (modalEl.parentNode && modalEl.parentNode.tagName !== 'BODY') {
                document.body.appendChild(modalEl);
            }
        } catch (e) { }

        // 1. Öncelik: jQuery Bootstrap modal
        if (typeof $ !== 'undefined' && $.fn && $.fn.modal) {
            try {
                $(modalEl).modal('show');
                return;
            } catch (e) {
                console.warn('jQuery modal.show error:', e);
            }
        }

        // 2. Öncelik: Bootstrap native Modal
        if (typeof bootstrap !== 'undefined' && typeof bootstrap.Modal === 'function') {
            try {
                var m = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
                m.show();
                return;
            } catch (e) {
                console.warn('bootstrap.Modal error:', e);
            }
        }

        // 3. Fallback: CSS ile görünür kıl
        modalEl.classList.add('show');
        modalEl.style.display = 'block';
    }

    function initKaseVize() {
        // Özel pasaport / kimlik anlaşmaları bulunan ülkeler (Genelge Ekleri)
        var specialExpire1 = ['almanya'];
        var specialExpire5 = ['belçika', 'belcika', 'fransa', 'ispanya', 'isviçre', 'isvicre', 'lüksemburg', 'luksemburg', 'portekiz'];
        var specialBulgaria = ['bulgaristan'];

        function normalizeCountry(c) {
            return (c || '').trim().toLowerCase();
        }

        function formatTL(val) {
            var num = parseFloat(val);
            if (isNaN(num)) return '0,00';
            return (num / 100).toLocaleString('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        }

        // Giriş tarihlerini varsayılan olarak bugün yap
        function resetGirisTarihleri() {
            var today = new Date().toISOString().split('T')[0];
            var g1 = document.getElementById('girisTarihi');
            if (g1) g1.value = today;
            var g2 = document.getElementById('eskiVizeGirisTarihi');
            if (g2) g2.value = today;
        }

        resetGirisTarihleri();

        function handleModalOpen(e) {
            if (e && e.preventDefault) e.preventDefault();
            var pInput = document.getElementById('pasaportBitis');
            if (pInput) pInput.value = '';
            var ypInput = document.getElementById('yeniPasaportBitis');
            if (ypInput) ypInput.value = '';
            var evbInput = document.getElementById('eskiVizeBitis');
            if (evbInput) evbInput.value = '';

            resetGirisTarihleri();
            var fb = document.getElementById('kaseVizeFeedback');
            if (fb) fb.innerHTML = '';
            showModal(document.getElementById('kaseVizeModal'));
        }

        // Buton tıklama dinleyicilerini hem delegated hem doğrudan bağla
        if (typeof $ !== 'undefined') {
            $(document).on('click', '#openKaseVizeModal, [data-target="#kaseVizeModal"]', handleModalOpen);
        }

        var openBtn = document.getElementById('openKaseVizeModal');
        if (openBtn) {
            openBtn.addEventListener('click', handleModalOpen);
        }

        // İşlem türü değişimi (Radio butonları)
        function handleIslemTipiChange() {
            var secim = 'sureYetersiz';
            var checkedRadio = document.querySelector('input[name="kaseIslemTipi"]:checked');
            if (checkedRadio) secim = checkedRadio.value;

            var secSureYetersiz = document.getElementById('sectionSureYetersiz');
            var secEskiPasaport = document.getElementById('sectionEskiPasaport');
            var fb = document.getElementById('kaseVizeFeedback');
            if (fb) fb.innerHTML = '';

            if (secim === 'sureYetersiz') {
                if (secSureYetersiz) secSureYetersiz.style.display = 'block';
                if (secEskiPasaport) secEskiPasaport.style.display = 'none';
            } else {
                if (secSureYetersiz) secSureYetersiz.style.display = 'none';
                if (secEskiPasaport) secEskiPasaport.style.display = 'block';
            }
        }

        if (typeof $ !== 'undefined') {
            $(document).on('change', 'input[name="kaseIslemTipi"]', handleIslemTipiChange);
        } else {
            var radios = document.querySelectorAll('input[name="kaseIslemTipi"]');
            radios.forEach(function (r) { r.addEventListener('change', handleIslemTipiChange); });
        }

        // Ülkeye göre UVR ve harç verilerini getir
        function fetchUVRForCountry(country) {
            if (!country || country.trim().length === 0) return;

            var url = '/GetUVRByCountry?country=' + encodeURIComponent(country.trim());
            fetch(url, { credentials: 'same-origin' })
                .then(function (res) { return res.json(); })
                .then(function (json) {
                    var fb = document.getElementById('kaseVizeFeedback');
                    var vizeHakkiEl = document.getElementById('kaseVizeHakki');
                    var harcEl = document.getElementById('harcDurum');
                    var harcPerGunEl = document.getElementById('harcPerGun');

                    if (!json || !json.success) {
                        if (fb) {
                            fb.innerHTML = '<div class="alert alert-info py-2"><i class="fas fa-info-circle me-1"></i> Ülke verisi: ' + (json && json.message ? json.message : 'Kayıt bulunamadı. Vize hakkını manuel belirtebilirsiniz.') + '</div>';
                        }
                        return;
                    }

                    // Vize / Muafiyet süresini güncelle (örneğin 30, 60, 90 gün)
                    if (json.day !== undefined && json.day !== null) {
                        var dayNum = parseInt(json.day, 10);
                        if (!isNaN(dayNum) && dayNum > 0 && vizeHakkiEl) {
                            vizeHakkiEl.value = dayNum;
                        }
                    }

                    // Harç durumu ve günlük harç bedeli
                    var price = (json.dailyPrice !== undefined && json.dailyPrice !== null) ? json.dailyPrice : 10;
                    try {
                        var hb = parseInt(json.harcByte || 0, 10);
                        // 1 = Alınacak, 0 = Muaf
                        if (!isNaN(hb) && hb === 1) {
                            if (harcEl) harcEl.value = 'var';
                            if (harcPerGunEl) harcPerGunEl.value = price;
                        } else {
                            if (harcEl) harcEl.value = 'muaf';
                            if (harcPerGunEl) harcPerGunEl.value = 0;
                        }
                    } catch (e) {
                        console.error(e);
                    }

                    // Bilgilendirme mesajı ve özel ülke notları
                    var alertsHtml = '';
                    var norm = normalizeCountry(country);

                    if (harcEl && harcEl.value === 'muaf') {
                        alertsHtml += '<div class="alert alert-success py-2 mb-2"><i class="fas fa-check-circle me-1"></i> <strong>' + country + '</strong> vatandaşları vize harcından MUAFTIR.</div>';
                    } else {
                        alertsHtml += '<div class="alert alert-warning py-2 mb-2"><i class="fas fa-coins me-1"></i> <strong>' + country + '</strong> harca tabidir. Tahmini tarife: <strong>' + formatTL(price) + ' TL</strong>.</div>';
                    }

                    if (specialExpire1.indexOf(norm) !== -1) {
                        alertsHtml += '<div class="alert alert-info py-2 mb-0"><i class="fas fa-passport me-1"></i> <strong>Almanya Özel Kuralı:</strong> Pasaport veya kimlik kartının son geçerlilik tarihinin üzerinden en fazla 1 yıl geçmiş olsa dahi geçerli kabul edilir.</div>';
                    } else if (specialExpire5.indexOf(norm) !== -1) {
                        alertsHtml += '<div class="alert alert-info py-2 mb-0"><i class="fas fa-passport me-1"></i> <strong>Özel Anlaşma Kapsamı:</strong> Belçika, Fransa, İspanya, İsviçre, Lüksemburg ve Portekiz vatandaşlarının pasaport veya kimlik kartları geçerlilik süresinin bitiminden itibaren 5 yıl süreyle geçerli kabul edilmektedir.</div>';
                    } else if (specialBulgaria.indexOf(norm) !== -1) {
                        alertsHtml += '<div class="alert alert-info py-2 mb-0"><i class="fas fa-id-card me-1"></i> <strong>Bulgaristan Özel Kuralı:</strong> Kimlik kartı ile seyahat ve sınır geçiş anlaşması hükümlerini kontrol ediniz.</div>';
                    }

                    if (fb) fb.innerHTML = alertsHtml;
                })
                .catch(function (err) {
                    console.error('GetUVRByCountry error:', err);
                });
        }

        // Ülke değişim ve buton olayları (delegated ve direct)
        if (typeof $ !== 'undefined') {
            $(document).on('click', '#kaseFetchCountry', function () {
                var c = $('#kaseCountry').val();
                fetchUVRForCountry(c);
            });
            $(document).on('change', '#kaseCountry', function () {
                var c = $(this).val();
                fetchUVRForCountry(c);
            });
        }

        // =========================================================================
        // DEĞERLENDİRME MOTORU
        // =========================================================================
        function evaluateKaseVize() {
            var fb = document.getElementById('kaseVizeFeedback');
            var secim = 'sureYetersiz';
            var checkedRadio = document.querySelector('input[name="kaseIslemTipi"]:checked');
            if (checkedRadio) secim = checkedRadio.value;

            // ---------------------------------------------------------------------
            // SENARYO 1: PASAPORT SÜRESİ YETERSİZLİĞİ (P - 60 Formülü)
            // ---------------------------------------------------------------------
            if (secim === 'sureYetersiz') {
                var pasaportInputEl = document.getElementById('pasaportBitis');
                var girisInputEl = document.getElementById('girisTarihi');
                var vizeHakkiInputEl = document.getElementById('kaseVizeHakki');
                var harcSelectEl = document.getElementById('harcDurum');
                var harcBedelInputEl = document.getElementById('harcPerGun');

                var pasaportBitis = pasaportInputEl ? pasaportInputEl.value : null;
                var girisTarihi = (girisInputEl && girisInputEl.value) ? girisInputEl.value : new Date().toISOString().split('T')[0];

                if (!pasaportBitis) {
                    if (fb) fb.innerHTML = '<div class="alert alert-warning"><i class="fas fa-exclamation-triangle me-1"></i> Lütfen pasaport geçerlilik bitiş tarihini giriniz.</div>';
                    return;
                }

                var girisDate = new Date(girisTarihi);
                var bitisDate = new Date(pasaportBitis);

                if (isNaN(girisDate.getTime()) || isNaN(bitisDate.getTime())) {
                    if (fb) fb.innerHTML = '<div class="alert alert-danger"><i class="fas fa-times-circle me-1"></i> Geçersiz tarih formatı girildi.</div>';
                    return;
                }

                var diffTime = bitisDate.getTime() - girisDate.getTime();
                var kalanGun = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

                if (kalanGun <= 0) {
                    if (fb) fb.innerHTML = '<div class="alert alert-danger"><strong><i class="fas fa-ban me-1"></i> Pasaportun Süresi Dolmuş!</strong><br>Giriş tarihi itibarıyla pasaport süresi sona ermiştir. Türkiye\'ye giriş izni VERİLEMEZ.</div>';
                    return;
                }

                var vizeHakki = 90;
                if (vizeHakkiInputEl && vizeHakkiInputEl.value) {
                    var parsed = parseInt(vizeHakkiInputEl.value, 10);
                    if (!isNaN(parsed) && parsed > 0) vizeHakki = parsed;
                }

                var yasalGerekenSure = vizeHakki + 60;

                var harcDurumVal = harcSelectEl ? harcSelectEl.value : 'var';
                var harcBedeli = 0;
                if (harcBedelInputEl) {
                    try { harcBedeli = parseFloat(harcBedelInputEl.value); } catch (e) { harcBedeli = 0; }
                }
                var harcBilgiHtml = '';
                if (harcDurumVal === 'muaf') {
                    harcBilgiHtml = '<div class="mt-2 text-success small"><i class="fas fa-check-circle me-1"></i> <strong>Harç Durumu:</strong> Ülke anlaşması/kararı gereği vize harcından MUAFTIR.</div>';
                } else {
                    harcBilgiHtml = '<div class="mt-2 text-warning small"><i class="fas fa-coins me-1"></i> <strong>Harç Durumu:</strong> Harca tabidir. Tahmini bedel: <strong>' + formatTL(harcBedeli) + ' TL</strong>.</div>';
                }

                // DURUM 1.1: P <= 60 gün
                if (kalanGun <= 60) {
                    if (fb) {
                        fb.innerHTML = '<div class="alert alert-danger border-left border-danger" style="border-left-width: 5px;">' +
                            '<h5 class="alert-heading font-weight-bold mb-2"><i class="fas fa-times-circle me-1"></i> ❌ GİRİŞ İZNİ VERİLEMEZ (INAD / Kabul Edilemez Yolcu)</h5>' +
                            '<p class="mb-1">Yabancının pasaportunda giriş tarihi itibarıyla kalan süre <strong>' + kalanGun + ' gün</strong>dür.</p>' +
                            '<p class="mb-1"><strong>Hukuki Gerekçe:</strong> 6458 sayılı YUKK md. 7/1-b uyarınca talep edilen vize süresinden sonra en az 60 gün daha geçerli pasaporta sahip olunması kanuni zorunluluktur. Kalan süre 60 gün ve altında olduğu için kaşe vize verilmesi <u>hukuken mümkün değildir</u>.</p>' +
                            '<hr class="my-2">' +
                            '<div class="small"><strong>Yapılacak İşlem:</strong> İlgili hakkında INAD (Kabul Edilemez Yolcu) işlemi tesis edilerek geldiği ülkeye geri gönderilmesi gerekmektedir.</div>' +
                            '</div>';
                    }
                    return;
                }

                // DURUM 1.2: P >= V + 60 gün
                if (kalanGun >= yasalGerekenSure) {
                    if (fb) {
                        fb.innerHTML = '<div class="alert alert-info border-left border-info" style="border-left-width: 5px;">' +
                            '<h5 class="alert-heading font-weight-bold mb-2"><i class="fas fa-info-circle me-1"></i> ℹ️ Pasaport Geçerlilik Süresi YETERLİ - Kaşe Vizeye Gerek Yoktur</h5>' +
                            '<p class="mb-1">Yabancının pasaport kalan süresi: <strong>' + kalanGun + ' gün</strong>dür.</p>' +
                            '<p class="mb-1">Yabancının tabi olduğu standart vize/muafiyet süresi: <strong>' + vizeHakki + ' gün</strong> (YUKK md. 7/1-b gereği aranan asgari pasaport süresi: ' + yasalGerekenSure + ' gün).</p>' +
                            '<hr class="my-2">' +
                            '<div class="mb-1"><strong>Sonuç:</strong> Pasaport süresi aranan şartı sağladığından yabancı, normal vizesi veya vize muafiyeti kapsamında <strong>' + vizeHakki + ' gün</strong> süreyle doğrudan giriş yapabilir. Kaşe vize kısıtlamasına gerek yoktur.</div>' +
                            harcBilgiHtml +
                            '</div>';
                    }
                    return;
                }

                // DURUM 1.3: 60 < P < V + 60 gün -> Kaşe Vize (P - 60 gün)
                var kaseVizeSuresi = kalanGun - 60;
                if (kaseVizeSuresi > vizeHakki) kaseVizeSuresi = vizeHakki;

                if (fb) {
                    fb.innerHTML = '<div class="alert alert-success border-left border-success" style="border-left-width: 5px;">' +
                        '<h5 class="alert-heading font-weight-bold mb-2"><i class="fas fa-check-circle me-1"></i> ✅ KAŞE VİZE VERİLEBİLİR (Pasaport Süresi Kısaltması)</h5>' +
                        '<div class="p-2 mb-2 bg-white rounded border text-dark font-weight-bold" style="font-size: 1.15rem;">' +
                        'Tatbik Edilecek Kaşe Vize Süresi: <span class="badge badge-success px-3 py-2" style="font-size:1.15rem;">' + kaseVizeSuresi + ' GÜN</span>' +
                        '</div>' +
                        '<div class="mb-2"><strong>Mevzuat ve GİGM Talimatı Dayanağı:</strong><br>' +
                        'YUKK md. 7/1-b gereği pasaportun kalış süresinden 60 gün daha uzun olması gerekir. Pasaportun bitmesine ' + kalanGun + ' gün kaldığından, yolcunun kalış süresi pasaportun bitimine 60 gün kalacak şekilde <strong>' + kaseVizeSuresi + ' güne (' + kalanGun + ' - 60)</strong> kısaltılmıştır.</div>' +
                        '<div class="alert alert-warning py-2 px-3 my-2 small font-weight-bold">' +
                        '<i class="fas fa-exclamation-triangle me-1 text-danger"></i> ÖNEMLİ OPERASYONEL KURALLAR:<br>' +
                        '1. Bu işlem kanunu bilmeden gelen yabancıya kolaylık amacıyla <u>AYNI PASAPORTA SADECE 1 DEFAYA MAHSUS</u> verilebilir.<br>' +
                        '2. Kaşe vize <u>TEK GİRİŞ</u> olarak tatbik edilmelidir.<br>' +
                        '3. Yolcuya bir sonraki seyahatinde mutlaka geçerli süreli pasaportla gelmesi gerektiği tebliğ edilmelidir.' +
                        '</div>' +
                        '<hr class="my-2">' +
                        '<div class="small">' +
                        '• <strong>Pasaport Kalan Süresi:</strong> ' + kalanGun + ' gün<br>' +
                        '• <strong>Standart Vize / Muafiyet Hakkı:</strong> ' + vizeHakki + ' gün (Normalde gereken pasaport süresi: ' + yasalGerekenSure + ' gün)<br>' +
                        '• <strong>Hesaplanan Kaşe Vize:</strong> ' + kalanGun + ' - 60 = <strong>' + kaseVizeSuresi + ' gün (Tek Giriş)</strong><br>' +
                        '</div>' +
                        harcBilgiHtml +
                        '</div>';
                }
                return;
            }

            // ---------------------------------------------------------------------
            // SENARYO 2: BİTEN PASAPORTTAKİ VİZE + YENİ PASAPORT (Vize Aktarım Kolaylığı)
            // ---------------------------------------------------------------------
            if (secim === 'eskiPasaport') {
                var gTarihEl = document.getElementById('eskiVizeGirisTarihi');
                var ypBitisEl = document.getElementById('yeniPasaportBitis');
                var evBitisEl = document.getElementById('eskiVizeBitis');
                var evHakEl = document.getElementById('eskiVizeTekGirisHakki');

                var gVal = (gTarihEl && gTarihEl.value) ? gTarihEl.value : new Date().toISOString().split('T')[0];
                var ypVal = ypBitisEl ? ypBitisEl.value : null;
                var evVal = evBitisEl ? evBitisEl.value : null;

                if (!ypVal) {
                    if (fb) fb.innerHTML = '<div class="alert alert-warning"><i class="fas fa-exclamation-triangle me-1"></i> Lütfen YENİ pasaportun bitiş tarihini giriniz.</div>';
                    return;
                }
                if (!evVal) {
                    if (fb) fb.innerHTML = '<div class="alert alert-warning"><i class="fas fa-exclamation-triangle me-1"></i> Lütfen eski pasaporttaki konsolosluk vizesinin bitiş tarihini giriniz.</div>';
                    return;
                }

                var gDate = new Date(gVal);
                var ypDate = new Date(ypVal);
                var evDate = new Date(evVal);

                if (isNaN(gDate.getTime()) || isNaN(ypDate.getTime()) || isNaN(evDate.getTime())) {
                    if (fb) fb.innerHTML = '<div class="alert alert-danger"><i class="fas fa-times-circle me-1"></i> Geçersiz tarih formatı girildi.</div>';
                    return;
                }

                // Vize bitmiş mi?
                var vizeKalanGun = Math.ceil((evDate.getTime() - gDate.getTime()) / (1000 * 60 * 60 * 24));
                if (vizeKalanGun <= 0) {
                    if (fb) fb.innerHTML = '<div class="alert alert-danger"><strong><i class="fas fa-ban me-1"></i> Eski Pasaporttaki Vizenin Süresi Dolmuş!</strong><br>Konsolosluk vizesinin geçerlilik süresi giriş tarihi itibarıyla sona ermiştir. Bu vize ile giriş verilemez.</div>';
                    return;
                }

                // Yeni pasaport bitmiş mi?
                var yeniPaspKalanGun = Math.ceil((ypDate.getTime() - gDate.getTime()) / (1000 * 60 * 60 * 24));
                if (yeniPaspKalanGun <= 0) {
                    if (fb) fb.innerHTML = '<div class="alert alert-danger"><strong><i class="fas fa-ban me-1"></i> Yeni Pasaportun Süresi Dolmuş!</strong><br>Yeni pasaportun geçerlilik süresi sona ermiştir. Giriş verilemez.</div>';
                    return;
                }

                // Yeni pasaport 60 gün kuralını karşılıyor mu?
                if (yeniPaspKalanGun <= 60) {
                    if (fb) fb.innerHTML = '<div class="alert alert-danger"><strong><i class="fas fa-times-circle me-1"></i> Yeni Pasaportun Kalan Süresi Yetersiz (≤ 60 Gün)!</strong><br>Yeni pasaportta kalan süre ' + yeniPaspKalanGun + ' gündür. 6458 sayılı Kanun gereği pasaportun en az 60 gün geçerliliği olmalıdır. Giriş izni VERİLEMEZ.</div>';
                    return;
                }

                var tekGirisHak = 90;
                if (evHakEl && evHakEl.value) {
                    var parsedHak = parseInt(evHakEl.value, 10);
                    if (!isNaN(parsedHak) && parsedHak > 0) tekGirisHak = parsedHak;
                }

                // Yeni pasaporta göre verilebilecek max süre (P_yeni - 60)
                var paspMaxHak = yeniPaspKalanGun - 60;

                // Verilecek süre = min(Tek giriş kalış hakkı, vizenin kalan süresi, yeni pasaport max hakkı)
                var verilecekSure = Math.min(tekGirisHak, vizeKalanGun, paspMaxHak);

                if (verilecekSure <= 0) {
                    if (fb) fb.innerHTML = '<div class="alert alert-danger"><strong><i class="fas fa-ban me-1"></i> Vize Verilemez</strong><br>Hesaplanan geçerlilik süresi 0 gündür.</div>';
                    return;
                }

                if (fb) {
                    fb.innerHTML = '<div class="alert alert-success border-left border-success" style="border-left-width: 5px;">' +
                        '<h5 class="alert-heading font-weight-bold mb-2"><i class="fas fa-check-circle me-1"></i> ✅ KAŞE VİZE VERİLEBİLİR (Vize Aktarım Kolaylığı)</h5>' +
                        '<div class="p-2 mb-2 bg-white rounded border text-dark font-weight-bold" style="font-size: 1.15rem;">' +
                        'Tatbik Edilecek Kaşe Vize Süresi: <span class="badge badge-success px-3 py-2" style="font-size:1.15rem;">' + verilecekSure + ' GÜN</span>' +
                        '</div>' +
                        '<div class="p-2 mb-2 bg-light rounded text-success font-weight-bold">' +
                        '<i class="fas fa-coins me-1"></i> HARÇ DURUMU: HARÇ ALINMAZ (MUAFTIR - 0,00 TL)<br>' +
                        '<small class="text-muted font-weight-normal">Konsolosluk vizesi harcı yetkili makamca tahsil edilmiş olduğundan hudut kapısında mükerrer harç alınmaz.</small>' +
                        '</div>' +
                        '<div class="alert alert-warning py-2 px-3 my-2 small font-weight-bold">' +
                        '<i class="fas fa-exclamation-triangle me-1 text-danger"></i> OPERASYONEL UYGULAMA VE TEBLİGAT ESASLARI:<br>' +
                        '1. <strong>1 DEFAYA MAHSUS TEK GİRİŞ:</strong> Eski pasaporttaki konsolosluk vizesi müteaddit (çok girişli) olsa dahi, bu işlem yolcuya sadece <u>1 DEFALIK TEK GİRİŞ</u> hakkı sağlar.<br>' +
                        '2. <strong>YENİ VİZE ALMA ZORUNLULUĞU:</strong> Yolcunun bir sonraki Türkiye seyahatinden önce yeni pasaportuna yeni vize alması zorunludur. Bilmeden geldiği için bu defaya mahsus kolaylık sağlanmıştır.<br>' +
                        '3. <strong>SİSTEM KAYDI:</strong> Kaşe vize tatbik edilerek sisteme tek giriş olarak işlenmeli ve yolcu bilgilendirilmelidir.' +
                        '</div>' +
                        '<hr class="my-2">' +
                        '<div class="small">' +
                        '• <strong>Yeni Pasaport Kalan Süresi:</strong> ' + yeniPaspKalanGun + ' gün<br>' +
                        '• <strong>Konsolosluk Vizesi Kalan Süresi:</strong> ' + vizeKalanGun + ' gün<br>' +
                        '• <strong>Tek Giriş Kalış İzni:</strong> ' + tekGirisHak + ' gün<br>' +
                        '• <strong>Verilecek Kaşe Vize:</strong> <strong>' + verilecekSure + ' gün (Tek Giriş - Harçsız)</strong>' +
                        '</div>' +
                        '</div>';
                }
                return;
            }
        }

        if (typeof $ !== 'undefined') {
            $(document).on('click', '#kaseVizeKontrolBtn', function (e) {
                if (e && e.preventDefault) e.preventDefault();
                evaluateKaseVize();
            });
        }
        var kontrolBtnEl = document.getElementById('kaseVizeKontrolBtn');
        if (kontrolBtnEl) {
            kontrolBtnEl.addEventListener('click', function (e) {
                if (e && e.preventDefault) e.preventDefault();
                evaluateKaseVize();
            });
        }
    }

    // Sayfa yüklendiğinde Kaşe Vize dinleyicilerini başlat
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initKaseVize);
    } else {
        initKaseVize();
    }

    if (typeof $ !== 'undefined') {
        $(document).ready(initKaseVize);
    }

})();
// --- Inad Odasi Hatirlatma Kontrolleri (Kapi Bazli) ---
(function () {
    function initInadReminder() {
        var modalEl = document.getElementById('inadReminderModal');
        if (!modalEl) return;

        // Oturum suresince kapatilmis mi kontrol et
        var isDismissed = false;
        try {
            isDismissed = sessionStorage.getItem('inadReminderDismissed') === '1';
        } catch (e) { }

        // Kapatilmamissa sayfaya girildikten kisa sure sonra otomatik ac
        if (!isDismissed) {
            setTimeout(function () {
                if (typeof $ !== 'undefined' && $.fn && $.fn.modal) {
                    $('#inadReminderModal').modal('show');
                } else if (typeof bootstrap !== 'undefined' && bootstrap.Modal) {
                    new bootstrap.Modal(modalEl).show();
                } else {
                    modalEl.style.display = 'block';
                }
            }, 600);
        }
    }

    // Tek tikla Inad Edildi yapma
    window.quickMarkInadDone = function (inadId, btnElement) {
        if (!confirm('Bu yolcunun durumunu "İnad Edildi" olarak güncellemek ve odadan düşürmek istediğinize emin misiniz?')) {
            return;
        }

        var $btn = $(btnElement);
        var originalHtml = $btn.html();
        var $row = $('#inadRow-' + inadId);

        $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin mr-1"></i> Güncelleniyor...');

        $.ajax({
            url: '/Home/QuickUpdateInadStatus',
            type: 'POST',
            data: { id: inadId, status: 'İnad Edildi' },
            success: function (res) {
                if (res && res.success) {
                    $row.css({
                        'background-color': '#d4edda',
                        'transition': 'all 0.4s ease'
                    });
                    $row.find('td:last').html('<span class="badge badge-success font-weight-bold p-2"><i class="fas fa-check-circle mr-1"></i> İnad Edildi</span>');

                    setTimeout(function () {
                        $row.fadeOut(500, function () {
                            $(this).remove();
                            window.updateInadCounters();
                        });
                    }, 500);
                } else {
                    alert(res.message || 'Güncelleme yapılamadı.');
                    $btn.prop('disabled', false).html(originalHtml);
                }
            },
            error: function (xhr) {
                alert('Sunucu ile bağlantı hatası oluştu (' + xhr.status + '). Lütfen tekrar deneyin.');
                $btn.prop('disabled', false).html(originalHtml);
            }
        });
    };

    // Bu seferlik atla / odada beklemeye devam ediyor
    window.skipInadReminderRow = function (inadId, btnElement) {
        var $row = $('#inadRow-' + inadId);
        $row.css({
            'opacity': '0.4',
            'transition': 'all 0.3s ease'
        });
        $row.find('td:last').html('<span class="badge badge-secondary p-2"><i class="fas fa-clock mr-1"></i> Takip Devam Ediyor</span>');
    };

    // Sayaclari guncelleme ve bosalma kontrolu
    window.updateInadCounters = function () {
        var remaining = $('#inadReminderTable tbody tr:visible').length;
        $('#modalInadRemainingCount').text(remaining);
        $('.inad-count-badge').text(remaining);

        if (remaining <= 0) {
            $('#inadTableContainer').slideUp(300);
            $('#inadEmptyState').slideDown(300);
            setTimeout(function () {
                if (typeof $ !== 'undefined' && $.fn && $.fn.modal) {
                    $('#inadReminderModal').modal('hide');
                }
                $('#inadAlertBanner').slideUp(400);
            }, 1800);
        }
    };

    // Modali kapatip oturum boyunca bir daha otomatik acmama
    window.dismissInadReminderModal = function () {
        try {
            sessionStorage.setItem('inadReminderDismissed', '1');
        } catch (e) { }
    };

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initInadReminder);
    } else {
        initInadReminder();
    }
    if (typeof $ !== 'undefined') {
        $(document).ready(initInadReminder);
    }
})();