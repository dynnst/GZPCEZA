/* ============================================================
   İstatistik sayfası - Chart.js grafikleri

   URL adresleri Razor View tarafından data-* attribute olarak
   verilir. Böylece attribute route ve klasik route yapılarında
   çalışmaya devam eder.
   ============================================================ */

(function ($) {
    'use strict';

    var urls = {};

    var chartColors = {
        navy: 'rgba(26, 179, 148, 1)',
        navyLight: 'rgba(26, 179, 148, 0.20)',

        blue: 'rgba(35, 198, 200, 1)',
        blueLight: 'rgba(35, 198, 200, 0.20)',

        yellow: 'rgba(248, 172, 89, 1)',
        yellowLight: 'rgba(248, 172, 89, 0.20)',

        red: 'rgba(237, 85, 101, 1)',
        redLight: 'rgba(237, 85, 101, 0.20)',

        dark: 'rgba(47, 64, 80, 1)',
        darkLight: 'rgba(47, 64, 80, 0.20)',

        gray: 'rgba(179, 179, 179, 1)',
        grayLight: 'rgba(179, 179, 179, 0.20)'
    };

    var pieColors = [
        '#1ab394',
        '#23c6c8',
        '#f8ac59',
        '#ed5565',
        '#1c84c6',
        '#676a6c',
        '#a3e1d4',
        '#b5b8cf'
    ];

    function showChartError(canvasId, message) {
        var $canvas = $('#' + canvasId);

        if (!$canvas.length) {
            return;
        }

        var $parent = $canvas.parent();

        $canvas.remove();

        $parent.html(
            '<div class="text-center text-muted p-lg">' +
            '<i class="fa fa-exclamation-circle fa-2x"></i>' +
            '<p class="m-t-sm">' + message + '</p>' +
            '</div>'
        );
    }

    function hasData(data) {
        return data &&
            data.sayilar &&
            data.sayilar.length > 0;
    }

    function renderChartSummary(canvasId, labels, values) {
        var $canvas = $('#' + canvasId);

        if (!$canvas.length || !labels || !values) {
            return;
        }

        var $parent = $canvas.parent();
        var $oldSummary = $parent.find('.chart-data-summary');
        var html = '';
        var limit = Math.min(labels.length, values.length, 8);

        $oldSummary.remove();

        if (limit === 0) {
            return;
        }

        for (var i = 0; i < limit; i++) {
            html += '<span>' +
                shortenLabel(labels[i], 20) +
                ': <strong>' + values[i] + '</strong>' +
                '</span>';
        }

        $parent.append(
            '<div class="chart-data-summary">' + html + '</div>'
        );
    }

    function totalValues(values) {
        if (!values || !values.length) {
            return 0;
        }

        return values.reduce(function (total, value) {
            return total + (Number(value) || 0);
        }, 0);
    }

    function trendTicks(valuesA, valuesB) {
        var maxValue = Math.max(
            totalValues(valuesA),
            totalValues(valuesB)
        );

        if (maxValue === 0) {
            return {
                beginAtZero: true,
                max: 1,
                precision: 0
            };
        }

        return {
            beginAtZero: true,
            precision: 0
        };
    }

    function shortenLabel(value, maximumLength) {
        if (!value) {
            return '';
        }

        value = value.toString();

        if (value.length <= maximumLength) {
            return value;
        }

        return value.substring(0, maximumLength) + '...';
    }

    // ============================================================
    // Yüksek Çözünürlüklü Grafik & Tablo Dışa Aktarma Motoru (Canvas 2D)
    // 100% Çevrimdışı (Offline), Polnet uyumlu
    // ============================================================
    var chartExportStore = {};

    function formatNumber(num) {
        if (num === null || num === undefined || isNaN(num)) {
            return '0';
        }
        return Number(num).toLocaleString('tr-TR');
    }

    function formatReportDate() {
        var d = new Date();
        var pad = function (n) { return (n < 10 ? '0' : '') + n; };
        return pad(d.getDate()) + '.' + pad(d.getMonth() + 1) + '.' + d.getFullYear() + ' ' +
               pad(d.getHours()) + ':' + pad(d.getMinutes());
    }

    function drawRoundedRect(ctx, x, y, width, height, radius, fill, stroke) {
        var r = { tl: 0, tr: 0, br: 0, bl: 0 };
        if (typeof radius === 'number') {
            r = { tl: radius, tr: radius, br: radius, bl: radius };
        } else if (radius && typeof radius === 'object') {
            r = {
                tl: radius.tl || 0,
                tr: radius.tr || 0,
                br: radius.br || 0,
                bl: radius.bl || 0
            };
        }
        ctx.beginPath();
        ctx.moveTo(x + r.tl, y);
        ctx.lineTo(x + width - r.tr, y);
        ctx.quadraticCurveTo(x + width, y, x + width, y + r.tr);
        ctx.lineTo(x + width, y + height - r.br);
        ctx.quadraticCurveTo(x + width, y + height, x + width - r.br, y + height);
        ctx.lineTo(x + r.bl, y + height);
        ctx.quadraticCurveTo(x, y + height, x, y + height - r.bl);
        ctx.lineTo(x, y + r.tl);
        ctx.quadraticCurveTo(x, y, x + r.tl, y);
        ctx.closePath();
        if (fill) {
            ctx.fill();
        }
        if (stroke) {
            ctx.stroke();
        }
    }

    function downloadCanvasAsPng(canvas, fileName) {
        if (canvas.toBlob) {
            canvas.toBlob(function (blob) {
                if (!blob) {
                    fallbackDownload(canvas.toDataURL('image/png'), fileName);
                    return;
                }
                var url = URL.createObjectURL(blob);
                var a = document.createElement('a');
                a.style.display = 'none';
                a.href = url;
                a.download = fileName;
                document.body.appendChild(a);
                a.click();
                setTimeout(function () {
                    document.body.removeChild(a);
                    URL.revokeObjectURL(url);
                }, 300);
            }, 'image/png');
        } else {
            fallbackDownload(canvas.toDataURL('image/png'), fileName);
        }
    }

    function fallbackDownload(dataUrl, fileName) {
        var a = document.createElement('a');
        a.style.display = 'none';
        a.href = dataUrl;
        a.download = fileName;
        document.body.appendChild(a);
        a.click();
        setTimeout(function () {
            document.body.removeChild(a);
        }, 300);
    }

    function registerChartForExport(canvasId, meta) {
        chartExportStore[canvasId] = meta;
    }

    function getColAlign(headers, colIdx) {
        if (headers[0] === 'Sıra') {
            if (colIdx === 0) return 'center';
            if (colIdx === 1) return 'left';
            return 'right';
        }
        if (colIdx === 0) return 'left';
        return 'right';
    }

    function exportChartAsHighResImage(canvasId) {
        var sourceCanvas = document.getElementById(canvasId);
        if (!sourceCanvas) {
            alert('Grafik henüz yüklenmedi veya bulunamadı.');
            return;
        }

        var meta = chartExportStore[canvasId] || {
            title: 'İstatistik Grafiği',
            subTitle: 'CEZAM İstatistik Verileri',
            tableHeaders: ['Kategori', 'Değer'],
            rows: []
        };

        var targetW = 1600;
        var paddingX = 60;
        var contentW = targetW - (paddingX * 2);

        var headerH = 175;
        var chartContainerH = 540;
        var sectionGap = 35;
        var tableHeaderH = 46;
        var rowH = 38;
        var totalRows = (meta.rows ? meta.rows.length : 0);
        var dataRowsH = totalRows * rowH;
        var summaryRowH = meta.summaryRow ? 46 : 0;
        var tableTotalH = 35 + tableHeaderH + dataRowsH + summaryRowH;
        var footerH = 80;

        var totalH = headerH + chartContainerH + sectionGap + tableTotalH + footerH + 40;

        var exportCanvas = document.createElement('canvas');
        exportCanvas.width = targetW;
        exportCanvas.height = Math.round(totalH);
        var ctx = exportCanvas.getContext('2d');

        // 1. Arka Plan
        ctx.fillStyle = '#ffffff';
        ctx.fillRect(0, 0, targetW, exportCanvas.height);

        // Dış Çerçeve
        ctx.strokeStyle = '#e2e8f0';
        ctx.lineWidth = 2;
        ctx.strokeRect(10, 10, targetW - 20, exportCanvas.height - 20);

        // 2. Üst Dekoratif Şerit (Lacivert & Altın)
        ctx.fillStyle = '#1a365d';
        ctx.fillRect(10, 10, targetW - 20, 10);
        ctx.fillStyle = '#d4af37';
        ctx.fillRect(10, 20, targetW - 20, 3);

        // 3. Kurum Başlığı
        ctx.fillStyle = '#1a365d';
        ctx.font = 'bold 20px "Segoe UI", Arial, sans-serif';
        ctx.textAlign = 'left';
        ctx.textBaseline = 'alphabetic';
        ctx.fillText('T.C. İÇİŞLERİ BAKANLIĞI — EMNİYET GENEL MÜDÜRLÜĞÜ', paddingX, 60);

        ctx.fillStyle = '#4a5568';
        ctx.font = '600 15px "Segoe UI", Arial, sans-serif';
        ctx.fillText('Göçmen Kaçakçılığıyla Mücadele ve Hudut Kapıları Daire Başkanlığı (CEZAM)', paddingX, 86);

        // Sağ Bilgi Rozeti: Rapor Tarihi ve Sistem
        var badgeW = 340;
        var badgeH = 56;
        var badgeX = targetW - paddingX - badgeW;
        var badgeY = 40;
        ctx.fillStyle = '#f8fafc';
        ctx.strokeStyle = '#cbd5e0';
        ctx.lineWidth = 1;
        drawRoundedRect(ctx, badgeX, badgeY, badgeW, badgeH, 6, true, true);

        var dateStr = formatReportDate();
        ctx.fillStyle = '#718096';
        ctx.font = 'bold 11px "Segoe UI", Arial, sans-serif';
        ctx.fillText('RAPOR TARİHİ & SAATİ', badgeX + 16, badgeY + 22);

        ctx.fillStyle = '#1a202c';
        ctx.font = 'bold 16px "Segoe UI", Arial, sans-serif';
        ctx.fillText(dateStr, badgeX + 16, badgeY + 44);

        ctx.fillStyle = '#1a365d';
        ctx.font = 'bold 12px "Segoe UI", Arial, sans-serif';
        ctx.textAlign = 'right';
        ctx.fillText('CEZAM v2.8', badgeX + badgeW - 16, badgeY + 44);
        ctx.textAlign = 'left';

        // Başlık altı ayraç çizgisi
        ctx.strokeStyle = '#e2e8f0';
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.moveTo(paddingX, 115);
        ctx.lineTo(targetW - paddingX, 115);
        ctx.stroke();

        // 4. Rapor / Grafik Başlığı & Açıklaması
        ctx.fillStyle = '#1a202c';
        ctx.font = 'bold 24px "Segoe UI", Arial, sans-serif';
        ctx.fillText(meta.title, paddingX, 150);

        if (meta.subTitle) {
            ctx.fillStyle = '#718096';
            ctx.font = '14px "Segoe UI", Arial, sans-serif';
            ctx.fillText(meta.subTitle, paddingX + ctx.measureText(meta.title).width + 16, 150);
        }

        // 5. Grafik Görsel Kutusu
        var chartContainerY = 175;
        ctx.fillStyle = '#ffffff';
        ctx.strokeStyle = '#e2e8f0';
        ctx.lineWidth = 1;
        drawRoundedRect(ctx, paddingX, chartContainerY, contentW, chartContainerH, 8, true, true);

        // Orijinal grafiği en-boy oranını koruyarak ortalı çiz
        var srcW = sourceCanvas.width;
        var srcH = sourceCanvas.height;
        if (srcW > 0 && srcH > 0) {
            var maxDrawW = contentW - 40;
            var maxDrawH = chartContainerH - 30;
            var scale = Math.min(maxDrawW / srcW, maxDrawH / srcH);
            var drawW = srcW * scale;
            var drawH = srcH * scale;
            var drawX = paddingX + (contentW - drawW) / 2;
            var drawY = chartContainerY + (chartContainerH - drawH) / 2;

            ctx.imageSmoothingEnabled = true;
            ctx.imageSmoothingQuality = 'high';
            ctx.drawImage(sourceCanvas, drawX, drawY, drawW, drawH);
        }

        // 6. Veri Detayları Tablosu
        var tableStartY = chartContainerY + chartContainerH + sectionGap;

        // Bölüm Başlığı
        ctx.fillStyle = '#1a365d';
        ctx.font = 'bold 18px "Segoe UI", Arial, sans-serif';
        ctx.fillText('VERİ DETAYLARI VE DAĞILIM TABLOSU', paddingX, tableStartY);

        ctx.fillStyle = '#a0aec0';
        ctx.font = 'italic 13px "Segoe UI", Arial, sans-serif';
        ctx.textAlign = 'right';
        ctx.fillText('CEZAM Hudut Güvenlik Veritabanı', targetW - paddingX, tableStartY);
        ctx.textAlign = 'left';

        var tableY = tableStartY + 15;
        var headers = meta.tableHeaders || ['Kategori', 'Değer'];
        var numCols = headers.length;

        // Sütun genişlikleri dağılımı
        var colWidths = [];
        if (meta.colWidths && meta.colWidths.length === numCols) {
            var specSum = meta.colWidths.reduce(function (a, b) { return a + b; }, 0);
            colWidths = meta.colWidths.map(function (w) { return Math.round((w / specSum) * contentW); });
        } else {
            if (numCols === 2) {
                colWidths = [900, 580];
            } else if (numCols === 3) {
                colWidths = [680, 400, 400];
            } else if (numCols === 4) {
                if (headers[0] === 'Sıra') {
                    colWidths = [120, 660, 350, 350];
                } else {
                    colWidths = [430, 350, 350, 350];
                }
            } else {
                var colW = Math.floor(contentW / numCols);
                for (var cWIdx = 0; cWIdx < numCols; cWIdx++) {
                    colWidths.push(colW);
                }
            }
        }

        // Tablo Başlık Satırı
        ctx.fillStyle = '#1a365d';
        drawRoundedRect(ctx, paddingX, tableY, contentW, tableHeaderH, { tl: 6, tr: 6, br: 0, bl: 0 }, true, false);

        ctx.fillStyle = '#ffffff';
        ctx.font = 'bold 14px "Segoe UI", Arial, sans-serif';
        var curColX = paddingX;
        for (var h = 0; h < numCols; h++) {
            var align = getColAlign(headers, h);
            ctx.textAlign = align;
            if (align === 'center') {
                ctx.fillText(headers[h], curColX + (colWidths[h] / 2), tableY + 28);
            } else if (align === 'left') {
                ctx.fillText(headers[h], curColX + 20, tableY + 28);
            } else {
                ctx.fillText(headers[h], curColX + colWidths[h] - 20, tableY + 28);
            }
            curColX += colWidths[h];
        }
        ctx.textAlign = 'left';
        tableY += tableHeaderH;

        // Veri Satırları
        var rows = meta.rows || [];
        for (var r = 0; r < rows.length; r++) {
            var rowData = rows[r];
            var isEven = (r % 2 === 0);

            // Satır Arka Planı
            ctx.fillStyle = isEven ? '#ffffff' : '#f8fafc';
            ctx.fillRect(paddingX, tableY, contentW, rowH);

            // Alt Çizgi
            ctx.strokeStyle = '#edf2f7';
            ctx.lineWidth = 1;
            ctx.beginPath();
            ctx.moveTo(paddingX, tableY + rowH);
            ctx.lineTo(paddingX + contentW, tableY + rowH);
            ctx.stroke();

            // Satır Değerleri
            ctx.font = '14px "Segoe UI", Arial, sans-serif';
            curColX = paddingX;
            for (var c = 0; c < numCols; c++) {
                var val = (rowData[c] !== undefined && rowData[c] !== null) ? rowData[c].toString() : '-';
                var rAlign = getColAlign(headers, c);
                ctx.textAlign = rAlign;

                if (rAlign === 'center') {
                    ctx.fillStyle = '#718096';
                    ctx.fillText(val, curColX + (colWidths[c] / 2), tableY + 24);
                } else if (rAlign === 'left') {
                    ctx.fillStyle = '#2d3748';
                    ctx.fillText(val, curColX + 20, tableY + 24);
                } else {
                    ctx.fillStyle = '#1a202c';
                    ctx.fillText(val, curColX + colWidths[c] - 20, tableY + 24);
                }
                curColX += colWidths[c];
            }
            ctx.textAlign = 'left';
            tableY += rowH;
        }

        // Toplam / Özet Satırı
        if (meta.summaryRow) {
            ctx.fillStyle = '#ebf4ff';
            ctx.fillRect(paddingX, tableY, contentW, summaryRowH);

            ctx.strokeStyle = '#cbd5e0';
            ctx.lineWidth = 1.5;
            ctx.beginPath();
            ctx.moveTo(paddingX, tableY);
            ctx.lineTo(paddingX + contentW, tableY);
            ctx.moveTo(paddingX, tableY + summaryRowH);
            ctx.lineTo(paddingX + contentW, tableY + summaryRowH);
            ctx.stroke();

            ctx.font = 'bold 15px "Segoe UI", Arial, sans-serif';
            curColX = paddingX;
            for (var s = 0; s < numCols; s++) {
                var sVal = (meta.summaryRow[s] !== undefined && meta.summaryRow[s] !== null) ? meta.summaryRow[s].toString() : '';
                var sAlign = getColAlign(headers, s);
                ctx.textAlign = sAlign;
                ctx.fillStyle = '#1a365d';

                if (sAlign === 'center') {
                    ctx.fillText(sVal, curColX + (colWidths[s] / 2), tableY + 28);
                } else if (sAlign === 'left') {
                    ctx.fillText(sVal, curColX + 20, tableY + 28);
                } else {
                    ctx.fillText(sVal, curColX + colWidths[s] - 20, tableY + 28);
                }
                curColX += colWidths[s];
            }
            ctx.textAlign = 'left';
            tableY += summaryRowH;
        }

        // Tablo Dış Çerçevesi
        ctx.strokeStyle = '#cbd5e0';
        ctx.lineWidth = 1;
        ctx.strokeRect(paddingX, tableStartY + 15, contentW, (tableY - (tableStartY + 15)));

        // 7. Alt Bilgi (Footer)
        var footerY = tableY + 35;
        ctx.strokeStyle = '#e2e8f0';
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.moveTo(paddingX, footerY);
        ctx.lineTo(targetW - paddingX, footerY);
        ctx.stroke();

        ctx.fillStyle = '#718096';
        ctx.font = '13px "Segoe UI", Arial, sans-serif';
        ctx.fillText('T.C. Emniyet Genel Müdürlüğü - CEZAM Hudut Kapıları Bilgi ve İstatistik Sistemi', paddingX, footerY + 24);

        ctx.fillStyle = '#a0aec0';
        ctx.textAlign = 'right';
        ctx.fillText('Resmi ve Kuruma Özeldir • İntranet / Polnet Güvenli Ağ', targetW - paddingX, footerY + 24);
        ctx.textAlign = 'left';

        // En Alt Lacivert Şerit
        ctx.fillStyle = '#1a365d';
        ctx.fillRect(10, exportCanvas.height - 18, targetW - 20, 8);

        // 8. PNG İndirmeyi Başlat
        var safeTitle = (meta.title || 'Istatistik').replace(/[^a-zA-Z0-9çğıöşüÇĞİÖŞÜ_-]/g, '_');
        var nowD = new Date();
        var pad = function (n) { return (n < 10 ? '0' : '') + n; };
        var fileDate = nowD.getFullYear() + pad(nowD.getMonth() + 1) + pad(nowD.getDate());
        var fileName = 'CEZAM_' + safeTitle + '_' + fileDate + '.png';

        downloadCanvasAsPng(exportCanvas, fileName);
    }

    function loadGunlukTrend() {
        $.getJSON(urls.gunluk)
            .done(function (data) {
                var canvas = document.getElementById(
                    'gunlukTrendChart'
                );

                if (!canvas) {
                    return;
                }

                new Chart(canvas.getContext('2d'), {
                    type: 'line',

                    data: {
                        labels: data.labels,

                        datasets: [
                            {
                                label: 'Kesilen Ceza',

                                data: data.cezaSayilari,

                                borderColor: chartColors.navy,

                                backgroundColor:
                                    chartColors.navyLight,

                                pointBackgroundColor:
                                    chartColors.navy,

                                pointBorderColor: '#ffffff',

                                borderWidth: 2,

                                pointRadius: 4,

                                pointHoverRadius: 6,

                                fill: true,

                                lineTension: 0.25
                            },
                            {
                                label: 'Hesaplama',

                                data: data.hesaplamaSayilari,

                                borderColor: chartColors.blue,

                                backgroundColor:
                                    chartColors.blueLight,

                                pointBackgroundColor:
                                    chartColors.blue,

                                pointBorderColor: '#ffffff',

                                borderWidth: 2,

                                pointRadius: 4,

                                pointHoverRadius: 6,

                                fill: true,

                                lineTension: 0.25
                            }
                        ]
                    },

                    options: {
                        responsive: true,

                        maintainAspectRatio: true,

                        legend: {
                            display: true,
                            position: 'bottom'
                        },

                        tooltips: {
                            mode: 'index',
                            intersect: false
                        },

                        scales: {
                            yAxes: [
                                {
                                    ticks: trendTicks(
                                        data.cezaSayilari,
                                        data.hesaplamaSayilari
                                    ),

                                    gridLines: {
                                        color:
                                            'rgba(0, 0, 0, 0.05)'
                                    }
                                }
                            ],

                            xAxes: [
                                {
                                    gridLines: {
                                        display: false
                                    }
                                }
                            ]
                        }
                    }
                });

                renderChartSummary(
                    'gunlukTrendChart',
                    data.labels,
                    data.cezaSayilari
                );

                var totGunlukCeza = totalValues(data.cezaSayilari);
                var totGunlukHesap = totalValues(data.hesaplamaSayilari);
                registerChartForExport('gunlukTrendChart', {
                    title: 'Son 7 Günlük İşlem Trendi',
                    subTitle: 'Ceza ve hesaplama sayıları',
                    tableHeaders: ['Tarih', 'Ceza Sayısı', 'Hesaplama Sayısı', 'Toplam İşlem'],
                    rows: (data.labels || []).map(function (label, idx) {
                        var ceza = (data.cezaSayilari && data.cezaSayilari[idx]) || 0;
                        var hesap = (data.hesaplamaSayilari && data.hesaplamaSayilari[idx]) || 0;
                        return [
                            label,
                            formatNumber(ceza) + ' adet',
                            formatNumber(hesap) + ' adet',
                            formatNumber(ceza + hesap) + ' adet'
                        ];
                    }),
                    summaryRow: [
                        'TOPLAM (7 GÜN)',
                        formatNumber(totGunlukCeza) + ' adet',
                        formatNumber(totGunlukHesap) + ' adet',
                        formatNumber(totGunlukCeza + totGunlukHesap) + ' adet'
                    ]
                });
            })
            .fail(function () {
                showChartError(
                    'gunlukTrendChart',
                    'Günlük trend verileri alınamadı.'
                );
            });
    }

    function loadAylikTrend() {
        $.getJSON(urls.aylik)
            .done(function (data) {
                var canvas = document.getElementById(
                    'aylikTrendChart'
                );

                if (!canvas) {
                    return;
                }

                new Chart(canvas.getContext('2d'), {
                    type: 'line',

                    data: {
                        labels: data.labels,

                        datasets: [
                            {
                                label: 'Kesilen Ceza',

                                data: data.cezaSayilari,

                                borderColor: chartColors.red,

                                backgroundColor:
                                    chartColors.redLight,

                                pointBackgroundColor:
                                    chartColors.red,

                                pointBorderColor: '#ffffff',

                                borderWidth: 2,

                                pointRadius: 4,

                                fill: true,

                                lineTension: 0.25
                            },
                            {
                                label: 'V-84',

                                data: data.v84Sayilari,

                                borderColor: chartColors.yellow,

                                backgroundColor:
                                    chartColors.yellowLight,

                                pointBackgroundColor:
                                    chartColors.yellow,

                                pointBorderColor: '#ffffff',

                                borderWidth: 2,

                                pointRadius: 4,

                                fill: true,

                                lineTension: 0.25
                            }
                        ]
                    },

                    options: {
                        responsive: true,

                        legend: {
                            display: true,
                            position: 'bottom'
                        },

                        tooltips: {
                            mode: 'index',
                            intersect: false
                        },

                        scales: {
                            yAxes: [
                                {
                                    ticks: {
                                        beginAtZero: true,
                                        precision: 0
                                    }
                                }
                            ]
                        }
                    }
                });

                renderChartSummary(
                    'aylikTrendChart',
                    data.labels,
                    data.cezaSayilari
                );

                var totAylikCeza = totalValues(data.cezaSayilari);
                var totAylikV84 = totalValues(data.v84Sayilari);
                registerChartForExport('aylikTrendChart', {
                    title: 'Son 6 Aylık İşlem Trendi',
                    subTitle: 'Ceza ve V-84 sayıları',
                    tableHeaders: ['Dönem / Ay', 'Ceza Sayısı', 'V-84 Belge Sayısı', 'Toplam İşlem'],
                    rows: (data.labels || []).map(function (label, idx) {
                        var ceza = (data.cezaSayilari && data.cezaSayilari[idx]) || 0;
                        var v84 = (data.v84Sayilari && data.v84Sayilari[idx]) || 0;
                        return [
                            label,
                            formatNumber(ceza) + ' adet',
                            formatNumber(v84) + ' adet',
                            formatNumber(ceza + v84) + ' adet'
                        ];
                    }),
                    summaryRow: [
                        'TOPLAM (6 AY)',
                        formatNumber(totAylikCeza) + ' adet',
                        formatNumber(totAylikV84) + ' adet',
                        formatNumber(totAylikCeza + totAylikV84) + ' adet'
                    ]
                });
            })
            .fail(function () {
                showChartError(
                    'aylikTrendChart',
                    'Aylık trend verileri alınamadı.'
                );
            });
    }

    function loadUlkeCokChart() {
        $.getJSON(urls.ulke)
            .done(function (data) {
                if (!hasData(data)) {
                    showChartError(
                        'ulkeCokChart',
                        'Ülke kaydı bulunamadı.'
                    );

                    return;
                }

                var canvas = document.getElementById(
                    'ulkeCokChart'
                );

                if (!canvas) {
                    return;
                }

                new Chart(canvas.getContext('2d'), {
                    type: 'bar',

                    data: {
                        labels: data.labels.map(function (label) {
                            return shortenLabel(label, 14);
                        }),

                        datasets: [
                            {
                                label: 'Ceza Sayısı',

                                data: data.sayilar,

                                backgroundColor:
                                    chartColors.navyLight,

                                borderColor:
                                    chartColors.navy,

                                borderWidth: 1
                            }
                        ]
                    },

                    options: {
                        responsive: true,

                        legend: {
                            display: false
                        },

                        scales: {
                            yAxes: [
                                {
                                    ticks: {
                                        beginAtZero: true,
                                        precision: 0
                                    }
                                }
                            ],

                            xAxes: [
                                {
                                    ticks: {
                                        autoSkip: false,
                                        maxRotation: 45,
                                        minRotation: 0
                                    },

                                     gridLines: {
                                        display: false
                                    }
                                }
                            ]
                        }
                    }
                });

                var totUlkeCok = totalValues(data.sayilar);
                registerChartForExport('ulkeCokChart', {
                    title: 'En Çok Ceza Kesilen Ülkeler',
                    subTitle: 'İlk 8 ülke ceza sayısı dağılımı',
                    tableHeaders: ['Sıra', 'Ülke Adı', 'Ceza Sayısı', 'Dağılım Oranı (%)'],
                    rows: (data.labels || []).map(function (label, idx) {
                        var sayi = (data.sayilar && data.sayilar[idx]) || 0;
                        var oran = totUlkeCok > 0 ? ((sayi / totUlkeCok) * 100).toFixed(1) + '%' : '0%';
                        return [
                            (idx + 1) + '.',
                            label,
                            formatNumber(sayi) + ' adet',
                            oran
                        ];
                    }),
                    summaryRow: [
                        '-',
                        'İLK 8 ÜLKE TOPLAMI',
                        formatNumber(totUlkeCok) + ' adet',
                        '100.0%'
                    ]
                });
            })
            .fail(function () {
                showChartError(
                    'ulkeCokChart',
                    'Ülke dağılımı alınamadı.'
                );
            });
    }

    function loadUlkeAzChart() {
        $.getJSON(urls.ulkeAz)
            .done(function (data) {
                if (!hasData(data)) {
                    showChartError(
                        'ulkeAzChart',
                        'Ülke kaydı bulunamadı.'
                    );

                    return;
                }

                var canvas = document.getElementById(
                    'ulkeAzChart'
                );

                if (!canvas) {
                    return;
                }

                new Chart(canvas.getContext('2d'), {
                    type: 'bar',

                    data: {
                        labels: data.labels.map(function (label) {
                            return shortenLabel(label, 14);
                        }),

                        datasets: [
                            {
                                label: 'Ceza Sayısı',

                                data: data.sayilar,

                                backgroundColor:
                                    chartColors.yellowLight,

                                borderColor:
                                    chartColors.yellow,

                                borderWidth: 1
                            }
                        ]
                    },

                    options: {
                        responsive: true,

                        legend: {
                            display: false
                        },

                        scales: {
                            yAxes: [
                                {
                                    ticks: {
                                        beginAtZero: true,
                                        precision: 0
                                    }
                                }
                            ],

                            xAxes: [
                                {
                                    ticks: {
                                        autoSkip: false,
                                        maxRotation: 45,
                                        minRotation: 0
                                    },

                                    gridLines: {
                                        display: false
                                    }
                                }
                            ]
                        }
                    }
                });

                var totUlkeAz = totalValues(data.sayilar);
                registerChartForExport('ulkeAzChart', {
                    title: 'En Az Ceza Kesilen Ülkeler',
                    subTitle: 'En az ceza kesilen ilk 5 ülke',
                    tableHeaders: ['Sıra', 'Ülke Adı', 'Ceza Sayısı', 'Dağılım Oranı (%)'],
                    rows: (data.labels || []).map(function (label, idx) {
                        var sayi = (data.sayilar && data.sayilar[idx]) || 0;
                        var oran = totUlkeAz > 0 ? ((sayi / totUlkeAz) * 100).toFixed(1) + '%' : '0%';
                        return [
                            (idx + 1) + '.',
                            label,
                            formatNumber(sayi) + ' adet',
                            oran
                        ];
                    }),
                    summaryRow: [
                        '-',
                        'EN AZ 5 ÜLKE TOPLAMI',
                        formatNumber(totUlkeAz) + ' adet',
                        '100.0%'
                    ]
                });
            })
            .fail(function () {
                showChartError(
                    'ulkeAzChart',
                    'En az ülke verileri alınamadı.'
                );
            });
    }

    function loadPersonelChart() {
        $.getJSON(urls.personel)
            .done(function (data) {
                if (!hasData(data)) {
                    showChartError(
                        'personelChart',
                        'Personel kaydı bulunamadı.'
                    );

                    return;
                }

                var canvas = document.getElementById(
                    'personelChart'
                );

                if (!canvas) {
                    return;
                }

                new Chart(canvas.getContext('2d'), {
                    type: 'horizontalBar',

                    data: {
                        labels: data.labels.map(function (label) {
                            return shortenLabel(label, 22);
                        }),

                        datasets: [
                            {
                                label: 'Ceza Sayısı',

                                data: data.sayilar,

                                backgroundColor:
                                    chartColors.blueLight,

                                borderColor:
                                    chartColors.blue,

                                borderWidth: 1
                            }
                        ]
                    },

                    options: {
                        responsive: true,

                        legend: {
                            display: false
                        },

                        scales: {
                            xAxes: [
                                {
                                    ticks: {
                                        beginAtZero: true,
                                        precision: 0
                                    }
                                }
                            ],

                            yAxes: [
                                {
                                    gridLines: {
                                        display: false
                                    }
                                }
                            ]
                        }
                    }
                });

                var totPersonel = totalValues(data.sayilar);
                registerChartForExport('personelChart', {
                    title: 'Personel Ceza Sıralaması',
                    subTitle: 'En çok ceza kesen ilk 10 personel',
                    tableHeaders: ['Sıra', 'Personel Adı Soyadı', 'Ceza Sayısı', 'İşlem Payı (%)'],
                    rows: (data.labels || []).map(function (label, idx) {
                        var sayi = (data.sayilar && data.sayilar[idx]) || 0;
                        var oran = totPersonel > 0 ? ((sayi / totPersonel) * 100).toFixed(1) + '%' : '0%';
                        return [
                            (idx + 1) + '.',
                            label,
                            formatNumber(sayi) + ' adet',
                            oran
                        ];
                    }),
                    summaryRow: [
                        '-',
                        'İLK 10 PERSONEL TOPLAMI',
                        formatNumber(totPersonel) + ' adet',
                        '100.0%'
                    ]
                });
            })
            .fail(function () {
                showChartError(
                    'personelChart',
                    'Personel sıralaması alınamadı.'
                );
            });
    }

    function loadHaftalikChart() {
        $.getJSON(urls.haftalik)
            .done(function (data) {
                if (!hasData(data)) {
                    showChartError(
                        'haftalikChart',
                        'Haftalık işlem kaydı bulunamadı.'
                    );

                    return;
                }

                var canvas = document.getElementById(
                    'haftalikChart'
                );

                if (!canvas) {
                    return;
                }

                new Chart(canvas.getContext('2d'), {
                    type: 'bar',

                    data: {
                        labels: data.labels,

                        datasets: [
                            {
                                label: 'Ceza Sayısı',

                                data: data.sayilar,

                                backgroundColor: [
                                    chartColors.navyLight,
                                    chartColors.blueLight,
                                    chartColors.yellowLight,
                                    chartColors.redLight,
                                    chartColors.darkLight,
                                    chartColors.grayLight,
                                    'rgba(28, 132, 198, 0.20)'
                                ],

                                borderColor: [
                                    chartColors.navy,
                                    chartColors.blue,
                                    chartColors.yellow,
                                    chartColors.red,
                                    chartColors.dark,
                                    chartColors.gray,
                                    'rgba(28, 132, 198, 1)'
                                ],

                                borderWidth: 1
                            }
                        ]
                    },

                    options: {
                        responsive: true,

                        legend: {
                            display: false
                        },

                        scales: {
                            yAxes: [
                                {
                                    ticks: {
                                        beginAtZero: true,
                                        precision: 0
                                    }
                                }
                            ],

                            xAxes: [
                                {
                                    gridLines: {
                                        display: false
                                    }
                                }
                            ]
                        }
                    }
                });

                var totHaftalik = totalValues(data.sayilar);
                registerChartForExport('haftalikChart', {
                    title: 'Haftanın Günlerine Göre Ceza Yoğunluğu',
                    subTitle: 'Gün bazında tüm zamanların ceza dağılımı',
                    tableHeaders: ['Gün', 'Ceza Sayısı', 'Haftalık Pay (%)'],
                    rows: (data.labels || []).map(function (label, idx) {
                        var sayi = (data.sayilar && data.sayilar[idx]) || 0;
                        var oran = totHaftalik > 0 ? ((sayi / totHaftalik) * 100).toFixed(1) + '%' : '0%';
                        return [
                            label,
                            formatNumber(sayi) + ' adet',
                            oran
                        ];
                    }),
                    summaryRow: [
                        'TOPLAM',
                        formatNumber(totHaftalik) + ' adet',
                        '100.0%'
                    ]
                });
            })
            .fail(function () {
                showChartError(
                    'haftalikChart',
                    'Haftalık yoğunluk verileri alınamadı.'
                );
            });
    }

    function loadInadUyrukChart() {
        $.getJSON(urls.inadPie)
            .done(function (data) {
                if (!hasData(data)) {
                    showChartError(
                        'inadUyrukChart',
                        'İNAD uyruk kaydı bulunamadı.'
                    );

                    return;
                }

                var canvas = document.getElementById(
                    'inadUyrukChart'
                );

                if (!canvas) {
                    return;
                }

                new Chart(canvas.getContext('2d'), {
                    type: 'pie',

                    data: {
                        labels: data.labels,

                        datasets: [
                            {
                                data: data.sayilar,

                                backgroundColor:
                                    pieColors.slice(
                                        0,
                                        data.sayilar.length
                                    ),

                                borderColor: '#ffffff',

                                borderWidth: 2
                            }
                        ]
                    },

                    options: {
                        responsive: true,

                        legend: {
                            display: true,
                            position: 'bottom'
                        },

                        tooltips: {
                            callbacks: {
                                label: function (
                                    tooltipItem,
                                    chartData
                                ) {
                                    var dataset =
                                        chartData.datasets[
                                        tooltipItem.datasetIndex
                                        ];

                                    var currentValue =
                                        dataset.data[
                                        tooltipItem.index
                                        ];

                                    var total = dataset.data.reduce(
                                        function (sum, value) {
                                            return sum +
                                                Number(value);
                                        },
                                        0
                                    );

                                    var percentage = total > 0
                                        ? Math.round(
                                            currentValue /
                                            total *
                                            100
                                        )
                                        : 0;

                                    return chartData.labels[
                                        tooltipItem.index
                                    ] +
                                        ': ' +
                                        currentValue +
                                        ' (%' +
                                        percentage +
                                        ')';
                                }
                            }
                        }
                    }
                });

                var totInadUyruk = totalValues(data.sayilar);
                registerChartForExport('inadUyrukChart', {
                    title: 'İNAD Uyruk Dağılımı',
                    subTitle: 'Ülke/uyruk bazında İNAD kayıt dağılımı',
                    tableHeaders: ['Sıra', 'Uyruk / Ülke', 'İNAD Sayısı', 'Dağılım Oranı (%)'],
                    rows: (data.labels || []).map(function (label, idx) {
                        var sayi = (data.sayilar && data.sayilar[idx]) || 0;
                        var oran = totInadUyruk > 0 ? ((sayi / totInadUyruk) * 100).toFixed(1) + '%' : '0%';
                        return [
                            (idx + 1) + '.',
                            label,
                            formatNumber(sayi) + ' adet',
                            oran
                        ];
                    }),
                    summaryRow: [
                        '-',
                        'TOPLAM İNAD KAYDI',
                        formatNumber(totInadUyruk) + ' adet',
                        '100.0%'
                    ]
                });
            })
            .fail(function () {
                showChartError(
                    'inadUyrukChart',
                    'İNAD uyruk dağılımı alınamadı.'
                );
            });
    }

    function loadInadKapiChart() {
        $.getJSON(urls.inadDonut)
            .done(function (data) {
                if (!hasData(data)) {
                    showChartError(
                        'inadKapiChart',
                        'İNAD kapı kaydı bulunamadı.'
                    );

                    return;
                }

                var canvas = document.getElementById(
                    'inadKapiChart'
                );

                if (!canvas) {
                    return;
                }

                new Chart(canvas.getContext('2d'), {
                    type: 'doughnut',

                    data: {
                        labels: data.labels,

                        datasets: [
                            {
                                data: data.sayilar,

                                backgroundColor:
                                    pieColors.slice(
                                        0,
                                        data.sayilar.length
                                    ),

                                borderColor: '#ffffff',

                                borderWidth: 2
                            }
                        ]
                    },

                    options: {
                        responsive: true,

                        cutoutPercentage: 60,

                        legend: {
                            display: true,
                            position: 'bottom'
                        },

                        animation: {
                            animateScale: true,
                            animateRotate: true
                        }
                    }
                });

                var totInadKapi = totalValues(data.sayilar);
                registerChartForExport('inadKapiChart', {
                    title: 'İNAD Kapı Dağılımı',
                    subTitle: 'Hudut kapısı bazında İNAD kayıt dağılımı',
                    tableHeaders: ['Sıra', 'Hudut Kapısı', 'İNAD Sayısı', 'Dağılım Oranı (%)'],
                    rows: (data.labels || []).map(function (label, idx) {
                        var sayi = (data.sayilar && data.sayilar[idx]) || 0;
                        var oran = totInadKapi > 0 ? ((sayi / totInadKapi) * 100).toFixed(1) + '%' : '0%';
                        return [
                            (idx + 1) + '.',
                            label,
                            formatNumber(sayi) + ' adet',
                            oran
                        ];
                    }),
                    summaryRow: [
                        '-',
                        'TOPLAM İNAD KAYDI',
                        formatNumber(totInadKapi) + ' adet',
                        '100.0%'
                    ]
                });
            })
            .fail(function () {
                showChartError(
                    'inadKapiChart',
                    'İNAD kapı dağılımı alınamadı.'
                );
            });
    }

    function loadIslemTipiChart() {
        $.getJSON(urls.islemTipi)
            .done(function (data) {
                if (!hasData(data)) {
                    showChartError(
                        'islemTipiChart',
                        'Islem tipi verisi bulunamadi.'
                    );

                    return;
                }

                var canvas = document.getElementById('islemTipiChart');

                if (!canvas) {
                    return;
                }

                new Chart(canvas.getContext('2d'), {
                    type: 'doughnut',

                    data: {
                        labels: data.labels,
                        datasets: [
                            {
                                data: data.sayilar,
                                backgroundColor: pieColors.slice(0, data.sayilar.length),
                                borderColor: '#ffffff',
                                borderWidth: 2
                            }
                        ]
                    },

                    options: {
                        responsive: true,
                        cutoutPercentage: 58,
                        legend: {
                            display: true,
                            position: 'bottom'
                        }
                    }
                });

                renderChartSummary(
                    'islemTipiChart',
                    data.labels,
                    data.sayilar
                );

                var totIslem = totalValues(data.sayilar);
                registerChartForExport('islemTipiChart', {
                    title: 'Genel İşlem Dağılımı',
                    subTitle: 'Ceza, hesaplama, İNAD ve V-84 genel toplam dağılımı',
                    tableHeaders: ['İşlem Türü', 'Toplam İşlem Sayısı', 'Genel Pay (%)'],
                    rows: (data.labels || []).map(function (label, idx) {
                        var sayi = (data.sayilar && data.sayilar[idx]) || 0;
                        var oran = totIslem > 0 ? ((sayi / totIslem) * 100).toFixed(1) + '%' : '0%';
                        return [
                            label,
                            formatNumber(sayi) + ' adet',
                            oran
                        ];
                    }),
                    summaryRow: [
                        'GENEL TOPLAM',
                        formatNumber(totIslem) + ' adet',
                        '100.0%'
                    ]
                });
            })
            .fail(function () {
                showChartError(
                    'islemTipiChart',
                    'Islem tipi dagilimi alinamadi.'
                );
            });
    }

    function loadBugunIslemChart() {
        $.getJSON(urls.bugunIslem)
            .done(function (data) {
                if (!hasData(data)) {
                    showChartError(
                        'bugunIslemChart',
                        'Bugun icin islem kaydi bulunamadi.'
                    );

                    return;
                }

                var canvas = document.getElementById('bugunIslemChart');

                if (!canvas) {
                    return;
                }

                new Chart(canvas.getContext('2d'), {
                    type: 'pie',

                    data: {
                        labels: data.labels,
                        datasets: [
                            {
                                data: data.sayilar,
                                backgroundColor: pieColors.slice(0, data.sayilar.length),
                                borderColor: '#ffffff',
                                borderWidth: 2
                            }
                        ]
                    },

                    options: {
                        responsive: true,
                        legend: {
                            display: true,
                            position: 'bottom'
                        }
                    }
                });

                renderChartSummary(
                    'bugunIslemChart',
                    data.labels,
                    data.sayilar
                );

                var totBugunIslem = totalValues(data.sayilar);
                registerChartForExport('bugunIslemChart', {
                    title: 'Bugünkü İşlem Dağılımı',
                    subTitle: 'Bugün gerçekleştirilen işlemler',
                    tableHeaders: ['İşlem Türü', 'Bugünkü İşlem Sayısı', 'Günlük Pay (%)'],
                    rows: (data.labels || []).map(function (label, idx) {
                        var sayi = (data.sayilar && data.sayilar[idx]) || 0;
                        var oran = totBugunIslem > 0 ? ((sayi / totBugunIslem) * 100).toFixed(1) + '%' : '0%';
                        return [
                            label,
                            formatNumber(sayi) + ' adet',
                            oran
                        ];
                    }),
                    summaryRow: [
                        'BUGÜNKÜ TOPLAM',
                        formatNumber(totBugunIslem) + ' adet',
                        '100.0%'
                    ]
                });
            })
            .fail(function () {
                showChartError(
                    'bugunIslemChart',
                    'Bugunku islem dagilimi alinamadi.'
                );
            });
    }

    function loadKapiGenelChart() {
        $.getJSON(urls.kapiGenel)
            .done(function (data) {
                if (!hasData(data)) {
                    showChartError(
                        'kapiGenelChart',
                        'Kapi bazli islem verisi bulunamadi.'
                    );

                    return;
                }

                var canvas = document.getElementById('kapiGenelChart');

                if (!canvas) {
                    return;
                }

                new Chart(canvas.getContext('2d'), {
                    type: 'horizontalBar',

                    data: {
                        labels: data.labels.map(function (label) {
                            return shortenLabel(label, 22);
                        }),
                        datasets: [
                            {
                                label: 'Toplam Islem',
                                data: data.sayilar,
                                backgroundColor: chartColors.darkLight,
                                borderColor: chartColors.dark,
                                borderWidth: 1
                            }
                        ]
                    },

                    options: {
                        responsive: true,
                        legend: {
                            display: false
                        },
                        scales: {
                            xAxes: [
                                {
                                    ticks: trendTicks(
                                        data.cezaSayilari,
                                        data.v84Sayilari
                                    )
                                }
                            ],
                            yAxes: [
                                {
                                    gridLines: {
                                        display: false
                                    }
                                }
                            ]
                        }
                    }
                });

                renderChartSummary(
                    'kapiGenelChart',
                    data.labels,
                    data.sayilar
                );

                var totKapiGenel = totalValues(data.sayilar);
                registerChartForExport('kapiGenelChart', {
                    title: 'Kapı Bazlı Toplam Yoğunluk',
                    subTitle: 'Tüm işlem tablolarında en aktif ilk 10 hudut kapısı',
                    tableHeaders: ['Sıra', 'Hudut Kapısı', 'Toplam İşlem Sayısı', 'Yoğunluk Payı (%)'],
                    rows: (data.labels || []).map(function (label, idx) {
                        var sayi = (data.sayilar && data.sayilar[idx]) || 0;
                        var oran = totKapiGenel > 0 ? ((sayi / totKapiGenel) * 100).toFixed(1) + '%' : '0%';
                        return [
                            (idx + 1) + '.',
                            label,
                            formatNumber(sayi) + ' adet',
                            oran
                        ];
                    }),
                    summaryRow: [
                        '-',
                        'İLK 10 KAPI TOPLAMI',
                        formatNumber(totKapiGenel) + ' adet',
                        '100.0%'
                    ]
                });
            })
            .fail(function () {
                showChartError(
                    'kapiGenelChart',
                    'Kapi bazli toplam yogunluk alinamadi.'
                );
            });
    }

    function loadRadarChart() {
        $.getJSON(urls.radar)
            .done(function (data) {
                if (!data ||
                    !data.labels ||
                    data.labels.length === 0) {

                    showChartError(
                        'radarChart',
                        'Hudut kapısı verisi bulunamadı.'
                    );

                    return;
                }

                var canvas = document.getElementById(
                    'radarChart'
                );

                if (!canvas) {
                    return;
                }

                new Chart(canvas.getContext('2d'), {
                    type: 'radar',

                    data: {
                        labels: data.labels.map(function (label) {
                            return shortenLabel(label, 18);
                        }),

                        datasets: [
                            {
                                label: 'Ceza',

                                data: data.cezaSayilari,

                                borderColor:
                                    chartColors.red,

                                backgroundColor:
                                    chartColors.redLight,

                                pointBackgroundColor:
                                    chartColors.red,

                                pointBorderColor: '#ffffff',

                                borderWidth: 2
                            },
                            {
                                label: 'V-84',

                                data: data.v84Sayilari,

                                borderColor:
                                    chartColors.navy,

                                backgroundColor:
                                    chartColors.navyLight,

                                pointBackgroundColor:
                                    chartColors.navy,

                                pointBorderColor: '#ffffff',

                                borderWidth: 2
                            }
                        ]
                    },

                    options: {
                        responsive: true,

                        legend: {
                            display: true,
                            position: 'bottom'
                        },

                        scale: {
                            ticks: {
                                beginAtZero: true,
                                precision: 0
                            }
                        }
                    }
                });

                var totRadarCeza = totalValues(data.cezaSayilari);
                var totRadarV84 = totalValues(data.v84Sayilari);
                registerChartForExport('radarChart', {
                    title: 'Hudut Kapısı Karşılaştırması',
                    subTitle: 'Ceza ve V-84 işlem sayıları',
                    tableHeaders: ['Hudut Kapısı', 'Ceza Sayısı', 'V-84 Sayısı', 'Toplam İşlem'],
                    rows: (data.labels || []).map(function (label, idx) {
                        var ceza = (data.cezaSayilari && data.cezaSayilari[idx]) || 0;
                        var v84 = (data.v84Sayilari && data.v84Sayilari[idx]) || 0;
                        return [
                            label,
                            formatNumber(ceza) + ' adet',
                            formatNumber(v84) + ' adet',
                            formatNumber(ceza + v84) + ' adet'
                        ];
                    }),
                    summaryRow: [
                        'TOPLAM',
                        formatNumber(totRadarCeza) + ' adet',
                        formatNumber(totRadarV84) + ' adet',
                        formatNumber(totRadarCeza + totRadarV84) + ' adet'
                    ]
                });
            })
            .fail(function () {
                showChartError(
                    'radarChart',
                    'Hudut kapısı karşılaştırması alınamadı.'
                );
            });
    }

    function validateUrls() {
        var missingUrls = [];

        Object.keys(urls).forEach(function (key) {
            if (!urls[key]) {
                missingUrls.push(key);
            }
        });

        if (missingUrls.length > 0 &&
            window.console &&
            console.warn) {

            console.warn(
                'Eksik istatistik URL adresleri: ' +
                missingUrls.join(', ')
            );
        }
    }

    function configureChartDefaults() {
        if (!window.Chart) {
            return;
        }

        if (Chart.defaults &&
            Chart.defaults.global) {

            Chart.defaults.global.defaultFontFamily =
                '"open sans", "Helvetica Neue", Helvetica, Arial, sans-serif';

            Chart.defaults.global.defaultFontColor =
                '#676a6c';

            Chart.defaults.global.animation.duration =
                700;
        }
    }

    $(document).ready(function () {
        var $dataElement = $('#istatistik-data');

        if (!$dataElement.length) {
            return;
        }

        if (typeof Chart === 'undefined') {
            if (window.console && console.error) {
                console.error(
                    'Chart.js yüklenemedi. ' +
                    'Chart.min.js dosyasının yolunu kontrol edin.'
                );
            }

            return;
        }

        urls = {
            gunluk:
                $dataElement.data('url-gunluk'),

            aylik:
                $dataElement.data('url-aylik'),

            ulke:
                $dataElement.data('url-ulke'),

            ulkeAz:
                $dataElement.data('url-ulke-az'),

            personel:
                $dataElement.data('url-personel'),

            inadPie:
                $dataElement.data('url-inad-pie'),

            inadDonut:
                $dataElement.data('url-inad-donut'),

            islemTipi:
                $dataElement.data('url-islem-tipi'),

            bugunIslem:
                $dataElement.data('url-bugun-islem'),

            kapiGenel:
                $dataElement.data('url-kapi-genel'),

            radar:
                $dataElement.data('url-radar'),

            haftalik:
                $dataElement.data('url-haftalik')
        };

        validateUrls();
        configureChartDefaults();

        loadGunlukTrend();
        loadAylikTrend();
        loadUlkeCokChart();
        loadUlkeAzChart();
        loadPersonelChart();
        loadHaftalikChart();
        loadInadUyrukChart();
        loadInadKapiChart();
        loadIslemTipiChart();
        loadBugunIslemChart();
        loadKapiGenelChart();
        loadRadarChart();

        // Görsel İndir Buton Olayı
        $(document).on('click', '.btn-chart-export', function (e) {
            e.preventDefault();
            var $btn = $(this);
            var canvasId = $btn.data('chart');

            if ($btn.hasClass('exporting')) {
                return;
            }

            $btn.addClass('exporting').html('<i class="fa fa-spinner fa-spin"></i> Hazırlanıyor...');

            setTimeout(function () {
                try {
                    exportChartAsHighResImage(canvasId);
                    $btn.html('<i class="fa fa-check"></i> İndirildi!');
                } catch (err) {
                    if (window.console && console.error) {
                        console.error('Grafik dışa aktarma hatası:', err);
                    }
                    alert('Görsel oluşturulurken bir hata oluştu: ' + (err.message || err));
                    $btn.removeClass('exporting').html('<i class="fa fa-download"></i> Detaylı Görsel İndir');
                }

                setTimeout(function () {
                    $btn.removeClass('exporting').html('<i class="fa fa-download"></i> Detaylı Görsel İndir');
                }, 2200);
            }, 60);
        });
    });

})(jQuery);
