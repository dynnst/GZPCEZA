/* ==========================================================================
   Ceza Brifing Grafikleri JavaScript (ceza-grafik.js)
   ========================================================================== */

(function () {
    var charts = {};
    var palette = ['#2563eb', '#16896f', '#c2413a', '#b7791f', '#4f46e5', '#0f766e', '#7c3aed', '#dc2626', '#64748b', '#0891b2'];
    
    var cfg = document.getElementById('cezagrafik-config');
    var IS_ADMIN = cfg ? cfg.getAttribute('data-is-admin') === 'true' : false;
    var USER_BORDER = cfg ? (cfg.getAttribute('data-user-border') || '') : '';
    var URL_BORDERS = cfg ? (cfg.getAttribute('data-url-borders') || '/Grafik/GetBorders') : '/Grafik/GetBorders';
    var URL_CHART_DATA = cfg ? (cfg.getAttribute('data-url-chart-data') || '/Grafik/ChartData') : '/Grafik/ChartData';

    function showLoading(show) {
        $('.loading-overlay').css('display', show ? 'flex' : 'none');
    }

    function escapeHtml(value) {
        if (value === null || value === undefined || value === '') return '—';
        return String(value).replace(/[&<>"']/g, function (m) {
            return ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[m];
        });
    }

    function number(value) {
        return new Intl.NumberFormat('tr-TR').format(Number(value) || 0);
    }

    function money(value) {
        return new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY', maximumFractionDigits: 0 }).format(Number(value) || 0);
    }

    function dateOnly(value) {
        if (!value) return '—';
        var d = new Date(value);
        return isNaN(d.getTime()) ? '—' : d.toLocaleDateString('tr-TR');
    }

    function buildQuery() {
        var qs = new URLSearchParams();
        var start = $('#startDateFilter').val();
        var end = $('#endDateFilter').val();
        var border = IS_ADMIN ? $('#borderFilter').val() : USER_BORDER;
        if (start) qs.append('startDate', start);
        if (end) qs.append('endDate', end);
        if (border) qs.append('border', border);
        return qs.toString();
    }

    function selectedMeta() {
        var border = IS_ADMIN ? ($('#borderFilter').val() || 'Tüm hudut kapıları') : (USER_BORDER ? USER_BORDER + ' (Yetkili Kapınız)' : 'Yetki Tanımsız');
        var start = $('#startDateFilter').val() || 'başlangıç yok';
        var end = $('#endDateFilter').val() || 'bitiş yok';
        return border + ' | ' + start + ' - ' + end + ' | Oluşturma: ' + new Date().toLocaleString('tr-TR');
    }

    function setReportMeta() {
        $('#reportMeta').text(selectedMeta());
    }

    function destroyChart(id) {
        if (charts[id]) {
            charts[id].destroy();
            delete charts[id];
        }
    }

    function noData(containerId, tableId) {
        destroyChart(containerId);
        $('#' + tableId).html('<div class="empty-state">Bu filtre için veri bulunamadı.</div>');
    }

    function renderChart(canvasId, type, labels, datasets, options) {
        destroyChart(canvasId);
        var ctx = document.getElementById(canvasId);
        if (!ctx || !labels || labels.length === 0) return;
        charts[canvasId] = new Chart(ctx, {
            type: type,
            data: { labels: labels, datasets: datasets },
            options: $.extend(true, {
                responsive: true,
                maintainAspectRatio: false,
                legend: { position: 'bottom', labels: { boxWidth: 12, fontSize: 11 } },
                tooltips: {
                    mode: 'index',
                    intersect: false,
                    callbacks: {
                        label: function (tooltipItem, data) {
                            var ds = data.datasets[tooltipItem.datasetIndex];
                            var val = tooltipItem.yLabel !== undefined ? tooltipItem.yLabel : tooltipItem.value;
                            return ds.label + ': ' + (ds.money ? money(val) : number(val));
                        }
                    }
                }
            }, options || {})
        });
    }

    function renderTable(tableId, columns, data) {
        if (!data || data.length === 0) {
            $('#' + tableId).html('<div class="empty-state">Bu filtre için veri bulunamadı.</div>');
            return;
        }

        var html = '<table class="table table-sm table-bordered table-striped"><thead><tr>';
        columns.forEach(function (col) { html += '<th>' + escapeHtml(col.title) + '</th>'; });
        html += '</tr></thead><tbody>';
        data.forEach(function (row) {
            html += '<tr>';
            columns.forEach(function (col) {
                var value = row[col.field];
                if (col.type === 'money') value = money(value);
                else if (col.type === 'number') value = number(value);
                else if (col.type === 'date') value = dateOnly(value);
                html += '<td>' + escapeHtml(value) + '</td>';
            });
            html += '</tr>';
        });
        html += '</tbody></table>';
        $('#' + tableId).html(html);
    }

    function renderSummary(summary) {
        summary = summary || {};
        $('#sumCalculations').text(number(summary.totalCalculations));
        $('#sumMoney').text(money(summary.totalMoney));
        $('#sumAverage').text('Ortalama: ' + money(summary.averageMoney));
        if (IS_ADMIN) {
            $('#sumScope').text(number(summary.countryCount) + ' / ' + number(summary.borderCount));
        } else {
            $('#sumScope').text(number(summary.countryCount) + ' Ülke');
        }
        $('#sumInadSartli').text(number(summary.inadCount) + ' / ' + number(summary.sartliCount) + ' / ' + number(summary.tahditFormCount));
    }

    function renderBar(canvasId, tableId, data, labelField, valueField, datasetLabel, valueType, horizontal) {
        if (!data || data.length === 0) {
            noData(canvasId, tableId);
            return;
        }
        var labels = data.map(function (x) { return x[labelField]; });
        var values = data.map(function (x) { return Number(x[valueField]) || 0; });
        renderChart(canvasId, horizontal ? 'horizontalBar' : 'bar', labels, [{
            label: datasetLabel,
            data: values,
            backgroundColor: palette,
            borderWidth: 0,
            money: valueType === 'money'
        }], {
            scales: horizontal
                ? { xAxes: [{ ticks: { beginAtZero: true, callback: valueType === 'money' ? money : number } }] }
                : { yAxes: [{ ticks: { beginAtZero: true, callback: valueType === 'money' ? money : number } }] }
        });
    }

    function renderDashboard(res) {
        renderSummary(res.summary);
        setReportMeta();

        var monthly = res.monthlyTrend || [];
        if (monthly.length) {
            renderChart('monthlyChart', 'bar', monthly.map(function (x) { return x.YearMonth; }), [
                { label: 'Hesaplama Sayısı', data: monthly.map(function (x) { return x.Count; }), backgroundColor: 'rgba(37, 99, 235, .72)', borderColor: '#2563eb', borderWidth: 1 },
                { label: 'Ceza Tutarı', data: monthly.map(function (x) { return x.TotalMoney; }), type: 'line', fill: false, borderColor: '#16896f', backgroundColor: '#16896f', yAxisID: 'money-axis', money: true }
            ], {
                scales: {
                    yAxes: [
                        { id: 'count-axis', position: 'left', ticks: { beginAtZero: true, callback: number } },
                        { id: 'money-axis', position: 'right', gridLines: { drawOnChartArea: false }, ticks: { beginAtZero: true, callback: money } }
                    ]
                }
            });
        } else {
            noData('monthlyChart', 'monthlyTable');
        }
        renderTable('monthlyTable', [
            { title: 'Ay', field: 'YearMonth' },
            { title: 'Hesaplama', field: 'Count', type: 'number' },
            { title: 'Tutar', field: 'TotalMoney', type: 'money' }
        ], monthly);

        renderBar('countryChart', 'countryTable', res.ulkeTop, 'Country', 'Count', 'Ceza Sayısı', 'number', true);
        renderTable('countryTable', [
            { title: 'Ülke', field: 'Country' },
            { title: 'Ceza Sayısı', field: 'Count', type: 'number' },
            { title: 'Tutar', field: 'TotalMoney', type: 'money' }
        ], res.ulkeTop);

        renderBar('borderMoneyChart', 'borderMoneyTable', res.kapiParaTop, 'Border', 'ToplamPara', 'Ceza Tutarı', 'money', true);
        renderTable('borderMoneyTable', [
            { title: 'Kapı', field: 'Border' },
            { title: 'İşlem', field: 'Count', type: 'number' },
            { title: 'Tutar', field: 'ToplamPara', type: 'money' }
        ], res.kapiParaTop);

        renderBar('personnelChart', 'personnelTable', res.personnelTop, 'PersonnelName', 'TransactionCount', 'İşlem Sayısı', 'number', true);
        renderTable('personnelTable', [
            { title: 'Personel', field: 'PersonnelName' },
            { title: 'İşlem', field: 'TransactionCount', type: 'number' },
            { title: 'Tutar', field: 'TotalMoney', type: 'money' },
            { title: 'İlk İşlem', field: 'FirstTransaction', type: 'date' },
            { title: 'Son İşlem', field: 'LastTransaction', type: 'date' }
        ], res.personnelTop);

        var daily = res.dailyTrend || [];
        if (daily.length) {
            renderChart('dailyChart', 'line', daily.map(function (x) { return x.DateStr; }), [{
                label: 'Günlük Hesaplama',
                data: daily.map(function (x) { return x.Count; }),
                borderColor: '#4f46e5',
                backgroundColor: 'rgba(79, 70, 229, .12)',
                pointRadius: 3,
                fill: true
            }], { scales: { yAxes: [{ ticks: { beginAtZero: true, callback: number } }] } });
        } else {
            noData('dailyChart', 'dailyTable');
        }
        renderTable('dailyTable', [
            { title: 'Tarih', field: 'DateStr' },
            { title: 'İşlem', field: 'Count', type: 'number' },
            { title: 'Tutar', field: 'TotalMoney', type: 'money' }
        ], daily);

        renderBar('hourlyChart', 'hourlyTable', res.hourlyData, 'TimeRange', 'Count', 'Ceza Sayısı', 'number', false);
        renderTable('hourlyTable', [
            { title: 'Saat', field: 'TimeRange' },
            { title: 'Ceza Sayısı', field: 'Count', type: 'number' }
        ], res.hourlyData);

        if (res.penaltyTop && res.penaltyTop.length) {
            renderChart('penaltyChart', 'doughnut', res.penaltyTop.map(function (x) { return x.Penalty; }), [{
                label: 'Ceza Türü',
                data: res.penaltyTop.map(function (x) { return x.Count; }),
                backgroundColor: palette
            }]);
        } else {
            noData('penaltyChart', 'penaltyTable');
        }
        renderTable('penaltyTable', [
            { title: 'Ceza Türü', field: 'Penalty' },
            { title: 'Sayı', field: 'Count', type: 'number' },
            { title: 'Tutar', field: 'TotalMoney', type: 'money' }
        ], res.penaltyTop);

        if (res.inadByReason && res.inadByReason.length) {
            renderChart('inadChart', 'pie', res.inadByReason.map(function (x) { return x.Reason; }), [{
                label: 'İnad Sebep',
                data: res.inadByReason.map(function (x) { return x.Count; }),
                backgroundColor: palette
            }]);
        } else {
            noData('inadChart', 'inadTable');
        }
        renderTable('inadTable', [
            { title: 'Sebep', field: 'Reason' },
            { title: 'Sayı', field: 'Count', type: 'number' }
        ], res.inadByReason);

        renderBar('sartliChart', 'sartliTable', res.sartliByBorder, 'Border', 'Count', 'Kişi Sayısı', 'number', true);
        renderTable('sartliTable', [
            { title: 'Kapı', field: 'Border' },
            { title: 'Kişi Sayısı', field: 'Count', type: 'number' }
        ], res.sartliByBorder);

        if (res.userByRole && res.userByRole.length) {
            renderChart('userRoleChart', 'doughnut', res.userByRole.map(function (x) { return x.Role; }), [{
                label: 'Kullanıcı',
                data: res.userByRole.map(function (x) { return x.Count; }),
                backgroundColor: palette
            }]);
        } else {
            noData('userRoleChart', 'userRoleTable');
        }
        renderTable('userRoleTable', [
            { title: 'Rol', field: 'Role' },
            { title: 'Kullanıcı Sayısı', field: 'Count', type: 'number' }
        ], res.userByRole);

        var education = [];
        (res.examByCourse || []).forEach(function (x) { education.push({ Name: x.Course, Type: 'Kurs/Sınav', Count: x.Count }); });
        (res.questionByExam || []).forEach(function (x) { education.push({ Name: x.ExamTitle, Type: 'Sınav/Soru', Count: x.Count }); });
        education = education.slice(0, 12);
        renderBar('educationChart', 'educationTable', education, 'Name', 'Count', 'Adet', 'number', true);
        renderTable('educationTable', [
            { title: 'Başlık', field: 'Name' },
            { title: 'Tür', field: 'Type' },
            { title: 'Adet', field: 'Count', type: 'number' }
        ], education);

        renderBar('tahditCodeChart', 'tahditCodeTable', res.tahditByCode, 'TahditCode', 'Count', 'Form Sayısı', 'number', false);
        renderTable('tahditCodeTable', [
            { title: 'Tahdit', field: 'TahditCode' },
            { title: 'İdari', field: 'IdariTahditCode' },
            { title: 'Adet', field: 'Count', type: 'number' }
        ], res.tahditByCode);

        var tahditUsers = (res.tahditByUser || []).slice(0, 10).map(function (x) {
            x.UserLabel = (x.UserSicil && x.UserSicil !== '-' ? x.UserSicil + ' - ' : '') + (x.UserDisplayName || '-');
            return x;
        });
        renderBar('tahditUserChart', 'tahditUserTable', tahditUsers, 'UserLabel', 'Count', 'Form Sayısı', 'number', true);
        renderTable('tahditUserTable', [
            { title: 'Kullanıcı', field: 'UserLabel' },
            { title: 'Kapı', field: 'Border' },
            { title: 'Tahdit', field: 'TahditCode' },
            { title: 'Adet', field: 'Count', type: 'number' }
        ], tahditUsers);
    }

    function loadBorders() {
        if (!IS_ADMIN) {
            return;
        }
        $.getJSON(URL_BORDERS)
            .done(function (res) {
                if (!res || !res.success) return;
                var selected = $('#borderFilter').val();
                var select = $('#borderFilter').empty().append('<option value="">Tümü (Tüm Hudut Kapıları)</option>');
                (res.borders || []).forEach(function (border) {
                    select.append('<option value="' + escapeHtml(border) + '">' + escapeHtml(border) + '</option>');
                });
                if (selected) select.val(selected);
            });
    }

    function loadData() {
        setReportMeta();
        showLoading(true);
        $.getJSON(URL_CHART_DATA + '?' + buildQuery())
            .done(function (res) {
                if (!res || !res.success) {
                    alert('Grafik verisi alınamadı: ' + (res && res.error ? res.error : 'Bilinmeyen hata'));
                    return;
                }
                renderDashboard(res);
            })
            .fail(function (xhr) {
                alert('Grafik verisi alınamadı. Sunucu yanıtı: ' + xhr.status);
            })
            .always(function () {
                showLoading(false);
            });
    }

    function resetFilters() {
        if (IS_ADMIN) {
            $('#borderFilter').val('');
        } else {
            $('#borderFilter').val(USER_BORDER);
        }
        $('#startDateFilter').val('');
        $('#endDateFilter').val('');
        $('#quickRange').val('');
        loadData();
    }

    function applyQuickRange(days) {
        if (!days) return;

        var end = new Date();
        var start = new Date();

        start.setDate(end.getDate() - (parseInt(days, 10) - 1));

        $('#startDateFilter').val(start.toISOString().slice(0, 10));
        $('#endDateFilter').val(end.toISOString().slice(0, 10));

        loadData();
    }

    function safeFileName(text) {
        return String(text || 'rapor')
            .replace(/[^a-zA-Z0-9ğüşıöçĞÜŞİÖÇ_-]+/g, '_')
            .replace(/_+/g, '_')
            .substring(0, 70);
    }

    function captureElement(element, fileName) {
        return html2canvas(element, {
            scale: 2,
            backgroundColor: '#ffffff',
            logging: false,
            useCORS: false,
            allowTaint: true,
            scrollY: -window.scrollY
        }).then(function (canvas) {
            var link = document.createElement('a');
            link.download = fileName + '_' + new Date().toISOString().slice(0, 10) + '.jpeg';
            link.href = canvas.toDataURL('image/jpeg', 0.95);
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        });
    }

    function downloadSection(sectionId) {
        var element = document.getElementById(sectionId);
        if (!element) return;
        var title = $(element).find('.chart-header h5').first().text() || sectionId;
        showLoading(true);
        captureElement(element, safeFileName(title))
            .catch(function (err) {
                alert('Görsel oluşturulamadı: ' + err);
            })
            .then(function () {
                showLoading(false);
            });
    }

    function downloadReport() {
        var element = document.getElementById('reportArea');
        if (!element) return;
        showLoading(true);
        captureElement(element, 'Ceza_Brifing_Raporu')
            .catch(function (err) { alert('Rapor görseli oluşturulamadı: ' + err); })
            .then(function () { showLoading(false); });
    }

    async function downloadAllSections() {
        var ids = $('.chart-panel').map(function () { return this.id; }).get();
        showLoading(true);
        for (var i = 0; i < ids.length; i++) {
            var element = document.getElementById(ids[i]);
            if (!element) continue;
            var title = $(element).find('.chart-header h5').first().text() || ids[i];
            await captureElement(element, safeFileName(title));
        }
        showLoading(false);
    }

    $(document).ready(function () {
        if (typeof Chart === 'undefined') {
            alert('Yerel Chart.js dosyası yüklenemedi. Lütfen AdminTemplate/js/plugins/chartJs/Chart.min.js dosyasını kontrol edin.');
            return;
        }

        loadBorders();
        loadData();

        $('#applyFilterBtn').on('click', loadData);
        $('#resetFilterBtn').on('click', resetFilters);
        $('#downloadReportBtn').on('click', downloadReport);
        $('#downloadAllBtn').on('click', function () {
            downloadAllSections().catch(function (err) {
                showLoading(false);
                alert('Tüm bölümler indirilemedi: ' + err);
            });
        });
        $('#printBtn').on('click', function () { window.print(); });
        $('#quickRange').on('change', function () {
            applyQuickRange(this.value);
        });
        $(document).on('click', '.download-section-btn', function () {
            downloadSection($(this).data('section'));
        });
    });
})();
