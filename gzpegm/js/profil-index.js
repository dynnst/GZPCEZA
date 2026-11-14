/* Profil sayfası etkileşimleri */
$(function () {
    var cfg = document.getElementById('profil-config');
    var detailsUrl = (cfg && cfg.getAttribute('data-details-url')) || '/Profile/GetBorderDetails';

    // Fotoğrafı yüklemeden önce önizle.
    $('#profileImageInput').on('change', function (event) {
        var file = event.target.files && event.target.files[0];
        if (!file) return;
        var reader = new FileReader();
        reader.onload = function (e) { $('#profilePreview').attr('src', e.target.result); };
        reader.readAsDataURL(file);
    });

    // Son 12 ayın işlem grafiği.
    try {
        var chartData = cfg && cfg.getAttribute('data-history-chart')
            ? JSON.parse(cfg.getAttribute('data-history-chart')) : [];
        if (chartData && chartData.length && $.fn.sparkline) {
            $('#profile-sparkline').sparkline(chartData, {
                type: 'bar',
                barColor: '#38ad9b',
                height: '150',
                barWidth: 28,
                barSpacing: 9,
                chartRangeMin: 0
            });
        } else {
            $('#profile-sparkline').html('<div class="profile-empty-state">Henüz grafik verisi yok.</div>');
        }
    } catch (error) {
        console.warn('Profil grafiği yüklenemedi.', error);
    }

    function escapeHtml(value) {
        return String(value == null ? '' : value).replace(/[&<>"']/g, function (character) {
            return {
                '&': '&amp;',
                '<': '&lt;',
                '>': '&gt;',
                '"': '&quot;',
                "'": '&#39;'
            }[character];
        });
    }

    function ensureModal() {
        var $modal = $('#borderDetailModal');
        if (!$modal.length) {
            $('body').append(
                '<div id="borderDetailModal" class="modal fade" tabindex="-1" role="dialog" aria-hidden="true">' +
                    '<div class="modal-dialog modal-lg modal-dialog-centered" role="document">' +
                        '<div class="modal-content">' +
                            '<div class="modal-header"><h5 class="modal-title"></h5><button type="button" class="close" data-dismiss="modal" aria-label="Kapat"><span aria-hidden="true">&times;</span></button></div>' +
                            '<div class="modal-body"></div>' +
                            '<div class="modal-footer"><button type="button" class="btn btn-secondary" data-dismiss="modal">Kapat</button></div>' +
                        '</div>' +
                    '</div>' +
                '</div>'
            );
            $modal = $('#borderDetailModal');
        }
        return $modal;
    }

    function renderPagination(page, total, pageSize) {
        var totalPages = Math.ceil(total / pageSize) || 1;
        var previous = Math.max(1, page - 1);
        var next = Math.min(totalPages, page + 1);
        var html = '<nav aria-label="Hudut detay sayfaları"><ul class="pagination justify-content-center">';
        html += '<li class="page-item ' + (page <= 1 ? 'disabled' : '') + '"><a class="page-link pg-link" href="#" data-page="' + previous + '">« Önceki</a></li>';
        for (var p = 1; p <= totalPages; p++) {
            html += '<li class="page-item ' + (p === page ? 'active' : '') + '"><a class="page-link pg-link" href="#" data-page="' + p + '">' + p + '</a></li>';
        }
        html += '<li class="page-item ' + (page >= totalPages ? 'disabled' : '') + '"><a class="page-link pg-link" href="#" data-page="' + next + '">Sonraki »</a></li>';
        return html + '</ul></nav>';
    }

    function loadBorderDetails(border, page) {
        var $modal = ensureModal();
        page = page || 1;
        $modal.find('.modal-title').text(border + ' detayları');
        $modal.find('.modal-body').html('<div class="profile-empty-state"><span class="spinner-border spinner-border-sm text-primary" role="status"></span> Detaylar yükleniyor…</div>');
        $modal.modal('show');

        $.getJSON(detailsUrl, { border: border, page: page }).done(function (result) {
            if (!result || !result.success) {
                $modal.find('.modal-body').html('<div class="alert alert-danger mb-0">' + escapeHtml(result && result.message ? result.message : 'Veriler yüklenemedi.') + '</div>');
                return;
            }

            var pdfUrl = escapeHtml(result.pdf || '#');
            var html = '<div class="d-flex align-items-center justify-content-between flex-wrap mb-3">' +
                '<h6 class="mb-2">' + escapeHtml(border) + ' · Kayıtlar</h6>' +
                '<a class="btn btn-sm btn-outline-secondary rounded-pill mb-2" href="' + pdfUrl + '" target="_blank" rel="noopener"><i class="fas fa-file-pdf mr-1"></i> PDF indir</a>' +
                '</div><div class="table-responsive"><table class="table table-hover table-sm"><thead><tr>' +
                '<th>Tarih</th><th>Ad Soyad</th><th>Uyruk</th><th>Vize / Tahdit</th><th>Ceza (TL)</th><th>Form</th></tr></thead><tbody>';

            (result.items || []).forEach(function (item) {
                var date = item.date ? new Date(item.date) : null;
                var dateText = date && !isNaN(date.getTime()) ? date.toLocaleString('tr-TR') : '—';
                var formLink = item.formUrl
                    ? '<a href="' + escapeHtml(item.formUrl) + '" target="_blank" rel="noopener">Görüntüle</a>'
                    : '—';
                html += '<tr>' +
                    '<td>' + escapeHtml(dateText) + '</td>' +
                    '<td>' + escapeHtml(item.name || '—') + '</td>' +
                    '<td>' + escapeHtml(item.nationality || '—') + '</td>' +
                    '<td>' + escapeHtml(item.visa || '—') + '</td>' +
                    '<td class="text-danger">₺ ' + escapeHtml(String(item.penalty || '0')) + '</td>' +
                    '<td>' + formLink + '</td></tr>';
            });

            if (!(result.items || []).length) {
                html += '<tr><td colspan="6" class="text-center text-muted py-4">Bu hudut kapısı için kayıt bulunamadı.</td></tr>';
            }
            html += '</tbody></table></div>' + renderPagination(result.page || page, result.total || 0, result.pageSize || 10);
            $modal.find('.modal-body').html(html);
            $modal.find('.pg-link').on('click', function (event) {
                event.preventDefault();
                if ($(this).closest('.page-item').hasClass('disabled') || $(this).closest('.page-item').hasClass('active')) return;
                loadBorderDetails(border, parseInt($(this).data('page'), 10) || 1);
            });
        }).fail(function () {
            $modal.find('.modal-body').html('<div class="alert alert-danger mb-0">Sunucu hatası. Lütfen daha sonra tekrar deneyin.</div>');
        });
    }

    $(document).on('click', '.view-border', function () {
        var border = $(this).attr('data-border');
        if (border) loadBorderDetails(border, 1);
    });

    $('#showAllBorders').on('click', function (event) {
        event.preventDefault();
        var list = [];
        try {
            list = cfg && cfg.getAttribute('data-border-history')
                ? JSON.parse(cfg.getAttribute('data-border-history')) : [];
        } catch (error) {
            console.warn('Hudut listesi okunamadı.', error);
        }
        if (!list || !list.length) {
            window.alert('Kayıtlı hudut bilgisi yok.');
            return;
        }

        var html = '<div class="table-responsive"><table class="table table-hover"><thead><tr>' +
            '<th>Hudut kapısı</th><th>İşlem sayısı</th><th>Toplam ceza</th><th>En aktif gün</th><th></th>' +
            '</tr></thead><tbody>';
        list.forEach(function (item) {
            var border = item.Border || '';
            html += '<tr><td><strong>' + escapeHtml(border || '—') + '</strong></td>' +
                '<td>' + escapeHtml(item.Count || 0) + '</td>' +
                '<td>₺ ' + escapeHtml(item.Sum || 0) + '</td>' +
                '<td>' + escapeHtml(item.MostActiveDay || '—') + '</td>' +
                '<td><button type="button" class="btn btn-sm btn-outline-primary view-border-modal" data-border="' + escapeHtml(border) + '">Detay</button></td></tr>';
        });
        html += '</tbody></table></div>';

        var $modal = ensureModal();
        $modal.find('.modal-title').text('Hudut kapıları');
        $modal.find('.modal-body').html(html);
        $modal.modal('show');
        $modal.find('.view-border-modal').on('click', function () {
            var border = $(this).attr('data-border');
            if (border) loadBorderDetails(border, 1);
        });
    });
});
