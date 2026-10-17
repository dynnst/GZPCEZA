/* ==========================================================================
   Profil Sayfasi JavaScript (profil-index.js)
   ========================================================================== */

$(function () {
    var cfg = document.getElementById('profil-config');
    var detailsUrl = (cfg && cfg.getAttribute('data-details-url')) || '/Profile/GetBorderDetails';

    // Image preview without upload
    $("#profileImageInput").on("change", function(e) {
        var reader = new FileReader();
        reader.onload = function(event) {
            $("#profilePreview").attr("src", event.target.result);
        };
        if (e.target.files[0]) {
            reader.readAsDataURL(e.target.files[0]);
        }
    });

    // Sparkline chart
    try {
        var data = [];
        if (cfg && cfg.getAttribute('data-history-chart')) {
            data = JSON.parse(cfg.getAttribute('data-history-chart'));
        }
        if (data && data.length) {
            $('#profile-sparkline').sparkline(data, { type: 'bar', barColor: '#1ab394', height: '220', barWidth: 30, barSpacing: 8 });
        } else {
            $('#profile-sparkline').html('<div class="alert alert-info text-center">Grafik verisi bulunamadÄ±</div>');
        }
    } catch(e) { console.warn(e); }

    function ensureModal() {
        var $modal = $('#borderDetailModal');
        if ($modal.length === 0) {
            $('body').append('<div id="borderDetailModal" class="modal fade" tabindex="-1" role="dialog">' +
                '<div class="modal-dialog modal-lg modal-dialog-centered" role="document">' +
                '<div class="modal-content">' +
                '<div class="modal-header"><h5 class="modal-title"></h5><button type="button" class="close" data-dismiss="modal">&times;</button></div>' +
                '<div class="modal-body text-center"><div class="spinner-border text-primary" role="status"><span class="sr-only">Loading...</span></div> YÃ¼kleniyor...</div>' +
                '<div class="modal-footer"><button type="button" class="btn btn-secondary" data-dismiss="modal">Kapat</button></div>' +
                '</div></div></div>');
            $modal = $('#borderDetailModal');
        }
        return $modal;
    }

    function renderPageControls(border, page, total, pageSize) {
        var totalPages = Math.ceil(total / pageSize) || 1;
        var html = '<nav aria-label="border-pagination"><ul class="pagination justify-content-center">';
        var prev = page > 1 ? page - 1 : 1;
        var next = page < totalPages ? page + 1 : totalPages;
        html += '<li class="page-item ' + (page <= 1 ? 'disabled' : '') + '"><a class="page-link pg-link" href="#" data-page="' + prev + '">Â« Ã–nceki</a></li>';
        for (var p = 1; p <= totalPages; p++) {
            html += '<li class="page-item ' + (p === page ? 'active' : '') + '"><a class="page-link pg-link" href="#" data-page="' + p + '">' + p + '</a></li>';
        }
        html += '<li class="page-item ' + (page >= totalPages ? 'disabled' : '') + '"><a class="page-link pg-link" href="#" data-page="' + next + '">Sonraki Â»</a></li>';
        html += '</ul></nav>';
        return html;
    }

    function loadBorderDetails(border, page) {
        page = page || 1;
        var $modal = ensureModal();
        $modal.modal('show');
        $modal.find('.modal-body').html('<div class="text-center p-4"><div class="spinner-border text-primary"></div><br/> Detaylar getiriliyor...</div>');
        $.getJSON(detailsUrl, { border: border, page: page }).done(function (res) {
            if (!res || !res.success) {
                $modal.find('.modal-body').html('<div class="alert alert-danger">' + (res && res.message ? res.message : 'Veri yÃ¼klenemedi') + '</div>');
                return;
            }
            var html = '<div class="d-flex justify-content-between align-items-center mb-3 flex-wrap"><h5 class="mb-2">' + escapeHtml(border) + ' - KayÄ±tlar</h5>';
            html += '<a class="btn btn-sm btn-outline-secondary rounded-pill" href="' + res.csv + '">ğŸ“¥ CSV Ä°ndir</a></div>';
            html += '<div class="table-responsive"><table class="table table-hover table-sm"><thead class="bg-light"><tr><th>Tarih</th><th>Ãœlke</th><th>Ceza (TL)</th><th>KullanÄ±cÄ±</th></tr></thead><tbody>';
            for (var i = 0; i < res.items.length; i++) {
                var s = res.items[i];
                var dt = s.date ? new Date(s.date) : null;
                html += '<tr>' +
                    '<td>' + (dt ? dt.toLocaleString('tr-TR') : '-') + '</td>' +
                    '<td>' + (s.country || '-') + '</td>' +
                    '<td class="text-danger">â‚º ' + (s.penalty || 0) + '</td>' +
                    '<td>' + (s.user || '-') + '</td>' +
                    '</tr>';
            }
            html += '</tbody></table></div>';
            html += renderPageControls(border, res.page, res.total, res.pageSize);
            $modal.find('.modal-title').text(border + ' DetaylarÄ±');
            $modal.find('.modal-body').html(html);
            // bind pagination events
            $modal.find('.pg-link').off('click').on('click', function (e) {
                e.preventDefault();
                var p = parseInt($(this).data('page')) || 1;
                loadBorderDetails(border, p);
            });
        }).fail(function () {
            $modal.find('.modal-body').html('<div class="alert alert-danger">Sunucu hatasÄ±, lÃ¼tfen daha sonra tekrar deneyin.</div>');
        });
    }

    // Helper escape
    function escapeHtml(str) {
        if(!str) return '';
        return str.replace(/[&<>]/g, function(m) {
            if (m === '&') return '&amp;';
            if (m === '<') return '&lt;';
            if (m === '>') return '&gt;';
            return m;
        });
    }

    $('.view-border').off('click').on('click', function () {
        var border = $(this).data('border');
        if (border) loadBorderDetails(border, 1);
    });

    // Show all borders modal
    $('#showAllBorders').off('click').on('click', function (e) {
        e.preventDefault();
        var list = [];
        try {
            if (cfg && cfg.getAttribute('data-border-history')) {
                list = JSON.parse(cfg.getAttribute('data-border-history'));
            }
        } catch (err) { console.warn(err); }

        if (!list || !list.length) {
            alert("KayÄ±tlÄ± hudut bilgisi yok.");
            return;
        }
        var html = '<h5 class="mb-3">TÃ¼m Hudut KapÄ±larÄ± Ä°statistikleri</h5><div class="table-responsive"><table class="table table-striped"><thead><tr><th>Hudut</th><th>Ä°ÅŸlem SayÄ±sÄ±</th><th>Toplam Ceza</th><th>En Aktif GÃ¼n</th><th></th></tr></thead><tbody>';
        for (var i = 0; i < list.length; i++) {
            var b = list[i];
            html += '<tr>' +
                '<td><strong>' + (b.Border || '-') + '</strong></td>' +
                '<td>' + (b.Count || 0) + '</td>' +
                '<td>â‚º ' + (b.Sum || 0) + '</td>' +
                '<td>' + (b.MostActiveDay || '-') + '</td>' +
                '<td><button class="btn btn-sm btn-outline-primary view-border-modal" data-border="' + escapeHtml(b.Border) + '">Detay</button></td>' +
                '</tr>';
        }
        html += '</tbody></table></div>';
        var $modal = ensureModal();
        $modal.find('.modal-title').text('Hudut KapÄ±larÄ± Listesi');
        $modal.find('.modal-body').html(html);
        $modal.modal('show');

        $modal.find('.view-border-modal').off('click').on('click', function () {
            var border = $(this).data('border');
            if(border) loadBorderDetails(border, 1);
            $modal.modal('hide');
        });
    });
});
