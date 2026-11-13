/* ==========================================================================
   Profil Sayfasi JavaScript (profil-index.js)
   ========================================================================== */

$(function () {
    var cfg = document.getElementById('profil-config');
    var borderHistoryUrl = (cfg && cfg.getAttribute('data-border-history-url')) || '/Profile/BorderHistory';

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
                '<div class="modal-body"></div>' +
                '<div class="modal-footer"><button type="button" class="btn btn-secondary" data-dismiss="modal">Kapat</button></div>' +
                '</div></div></div>');
            $modal = $('#borderDetailModal');
        }
        return $modal;
    }

    // Helper escape
    function escapeHtml(str) {
        if(!str) return '';
        return str.replace(/[&<>"']/g, function(m) {
            if (m === '&') return '&amp;';
            if (m === '<') return '&lt;';
            if (m === '>') return '&gt;';
            if (m === '"') return '&quot;';
            if (m === "'") return '&#39;';
            return m;
        });
    }

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
            var detailUrl = borderHistoryUrl + (borderHistoryUrl.indexOf('?') === -1 ? '?' : '&') + 'border=' + encodeURIComponent(b.Border || '');
            html += '<tr>' +
                '<td><strong>' + escapeHtml(String(b.Border || '-')) + '</strong></td>' +
                '<td>' + (b.Count || 0) + '</td>' +
                '<td>â‚º ' + (b.Sum || 0) + '</td>' +
                '<td>' + escapeHtml(String(b.MostActiveDay || '-')) + '</td>' +
                '<td><a class="btn btn-sm btn-outline-primary" href="' + escapeHtml(detailUrl) + '">Detay</a></td>' +
                '</tr>';
        }
        html += '</tbody></table></div>';
        var $modal = ensureModal();
        $modal.find('.modal-title').text('Hudut KapÄ±larÄ± Listesi');
        $modal.find('.modal-body').html(html);
        $modal.modal('show');
    });
});
