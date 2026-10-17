/* ==========================================================================
   CEZAM - Tahdit / Index Sayfası JavaScript
   Bağımlılıklar: jQuery, DataTables, Summernote, Bootstrap
   ========================================================================== */

$(document).ready(function () {

    /* ----------------------------------------------------------------------
       1. Sayfa Değişkenleri
       ---------------------------------------------------------------------- */
    var $page       = $('#tahdit-page-data');
    var canManage   = $page.data('can-manage') === true;
    var listUrl     = $page.data('list-url');
    var detailUrl   = $page.data('detail-url');
    var deleteUrl   = $page.data('delete-url');
    var uploadUrl   = '/Tahdit/SummernoteUpload';
    var antiForgery = $('#deleteTokenHolder input[name="__RequestVerificationToken"]').val() || '';

    /* ----------------------------------------------------------------------
       2. Güvenli Kaçış Fonksiyonları (XSS Koruması)
       ---------------------------------------------------------------------- */
    function escapeHtml(str) {
        if (!str) return '';
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;')
            .replace(/\n/g, '<br>');
    }

    function escapeAttribute(str) {
        if (!str) return '';
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    /* ----------------------------------------------------------------------
       3. Aksiyon Butonları Render
       ---------------------------------------------------------------------- */
    function renderActions(id) {
        var detailBtn = '<button type="button" class="btn btn-sm btn-action-detail btn-detail" data-id="' + id + '" title="Detayları İncele">'
                      + '<i class="fas fa-eye"></i> Detay</button>';

        if (!canManage) {
            return '<div class="tahdit-actions">' + detailBtn + '</div>';
        }

        var editBtn = '<button type="button" class="btn btn-sm btn-action-icon btn-action-edit btn-edit" data-id="' + id + '" title="Kaydı Düzenle">'
                    + '<i class="fas fa-pen"></i></button>';

        var deleteBtn = '<form action="' + deleteUrl + '" method="post" class="d-inline" onsubmit="return confirm(\'Bu tahdit kaydını pasife almak istediğinize emin misiniz?\');">'
                      + '<input name="__RequestVerificationToken" type="hidden" value="' + escapeAttribute(antiForgery) + '">'
                      + '<input type="hidden" name="id" value="' + id + '">'
                      + '<button type="submit" class="btn btn-sm btn-action-icon btn-action-delete" title="Pasife Al / Sil">'
                      + '<i class="fas fa-trash-alt"></i></button></form>';

        return '<div class="tahdit-actions">' + detailBtn + editBtn + deleteBtn + '</div>';
    }

    /* ----------------------------------------------------------------------
       4. DataTable Başlatma
       ---------------------------------------------------------------------- */
    var table = $('#tahditTable').DataTable({
        processing  : true,
        serverSide  : true,
        ajax        : {
            url : listUrl,
            type: 'GET'
        },
        pageLength  : 25,
        responsive  : true,
        order       : [[0, 'asc']],
        deferRender : true,
        language    : {
            processing   : '<div class="p-3 text-center"><i class="fas fa-spinner fa-spin fa-2x text-primary mr-2"></i> Veriler getiriliyor...</div>',
            search       : 'Filtrele:',
            searchPlaceholder: 'Kod, açıklama veya talimat ara...',
            lengthMenu   : 'Sayfada _MENU_ kayıt göster',
            info         : 'Toplam _TOTAL_ kayıttan _START_ - _END_ arası listeleniyor',
            infoEmpty    : 'Kayıt bulunamadı',
            infoFiltered : '(_MAX_ kayıt arasından filtrelendi)',
            zeroRecords  : '<div class="p-4 text-center text-muted"><i class="fas fa-search fa-2x mb-2 d-block"></i>Aradığınız kriterlere uygun tahdit kodu bulunamadı.</div>',
            paginate     : { first: 'İlk', last: 'Son', next: 'Sonraki &raquo;', previous: '&laquo; Önceki' }
        },
        columns: [
            // 0: Kod
            {
                data: 'kod',
                render: function (data, type, row) {
                    if (type !== 'display') return data || '';
                    return '<a href="javascript:void(0)" class="kod-pill btn-detail" data-id="' + row.id + '" title="Detay için tıklayın">'
                         + '<i class="fas fa-shield-alt"></i> ' + escapeHtml(data || '—') + '</a>';
                }
            },
            // 1: Açıklama
            {
                data: 'aciklama',
                render: function (data, type) {
                    if (type !== 'display') return data || '';
                    if (!data) return '<span class="text-muted">—</span>';
                    var shortText = data.length > 85 ? data.substring(0, 85) + '…' : data;
                    return '<div class="desc-text" title="' + escapeAttribute(data) + '">' + escapeHtml(shortText) + '</div>';
                }
            },
            // 2: Ceza Süre (Ay)
            {
                data: 'sureAy',
                render: function (data, type) {
                    if (type !== 'display') return data || '';
                    if (!data) return '<span class="text-muted">—</span>';
                    var isLong = parseInt(data, 10) >= 12;
                    var cls = isLong ? 'sure-badge sure-badge-highlight' : 'sure-badge';
                    return '<span class="' + cls + '"><i class="far fa-clock"></i> ' + data + ' Ay</span>';
                }
            },
            // 3: Girişe Gelirse
            {
                data: 'girisGelirse',
                render: function (data, type) {
                    if (type !== 'display') return data || '';
                    if (!data) return '<span class="text-muted">—</span>';
                    var shortText = data.length > 70 ? data.substring(0, 70) + '…' : data;
                    return '<div class="instruction-preview instruction-giris" title="' + escapeAttribute(data) + '">'
                         + '<i class="fas fa-sign-in-alt mr-1"></i>' + escapeHtml(shortText) + '</div>';
                }
            },
            // 4: Çıkışa Gelirse
            {
                data: 'cikisGelirse',
                render: function (data, type) {
                    if (type !== 'display') return data || '';
                    if (!data) return '<span class="text-muted">—</span>';
                    var shortText = data.length > 70 ? data.substring(0, 70) + '…' : data;
                    return '<div class="instruction-preview instruction-cikis" title="' + escapeAttribute(data) + '">'
                         + '<i class="fas fa-sign-out-alt mr-1"></i>' + escapeHtml(shortText) + '</div>';
                }
            },
            // 5: Durum
            {
                data: 'aktif',
                render: function (data, type) {
                    if (type !== 'display') return data ? 'Aktif' : 'Pasif';
                    return data ? '<span class="status-dot-badge status-active">Aktif</span>'
                                : '<span class="status-dot-badge status-passive">Pasif</span>';
                }
            },
            // 6: İşlemler
            {
                data: null,
                render: function (data, type, row) {
                    return type !== 'display' ? '' : renderActions(row.id);
                }
            }
        ],
        columnDefs: [
            { orderable: true,  targets: [0, 1, 2, 5] },
            { orderable: false, targets: [3, 4, 6] }
        ]
    });

    /* ----------------------------------------------------------------------
       5. Hızlı Kategori Filtre Butonları (Pill Filter Chips)
       ---------------------------------------------------------------------- */
    $('.filter-chip-btn').on('click', function () {
        $('.filter-chip-btn').removeClass('active');
        $(this).addClass('active');

        var filterVal = $(this).data('filter') || '';
        table.search(filterVal).draw();
    });

    /* ----------------------------------------------------------------------
       6. Detay Modal
       ---------------------------------------------------------------------- */
    $(document).on('click', '.btn-detail', function (e) {
        e.preventDefault();
        var id = $(this).data('id');
        if (!id) return;

        $('#detailModal').modal('show');
        $('#detailLoadingState').show();
        $('#detailLoadedContent').hide();

        $.get(detailUrl + '/' + id)
            .done(function (res) {
                $('#detailLoadingState').hide();
                if (res && res.success) {
                    $('#detailLoadedContent').show();

                    $('#detailKodTitle').text(res.kod || '—');
                    $('#detailAciklama').text(res.aciklama || 'Açıklama belirtilmemiş.');

                    if (res.sureAy) {
                        $('#detailSureBadge').html('<i class="far fa-clock mr-1"></i>' + res.sureAy + ' Ay Giriş Yasağı').show();
                    } else {
                        $('#detailSureBadge').hide();
                    }

                    if (res.aktif) {
                        $('#detailAktifBadge').html('<span class="status-dot-badge status-active">Aktif Tedbir</span>');
                    } else {
                        $('#detailAktifBadge').html('<span class="status-dot-badge status-passive">Pasif / Kaldırılmış</span>');
                    }

                    // Girişe Gelirse
                    if (res.girisGelirse) {
                        $('#detailGirisText').text(res.girisGelirse);
                        $('#detailGirisBox').show();
                    } else {
                        $('#detailGirisText').text('Özel bir giriş talimatı bulunmamaktadır.');
                        $('#detailGirisBox').show();
                    }

                    // Çıkışa Gelirse
                    if (res.cikisGelirse) {
                        $('#detailCikisText').text(res.cikisGelirse);
                        $('#detailCikisBox').show();
                    } else {
                        $('#detailCikisText').text('Özel bir çıkış talimatı bulunmamaktadır.');
                        $('#detailCikisBox').show();
                    }

                    // Medya / Summernote İçeriği
                    if (res.tahditMedia && res.tahditMedia.trim().length > 0) {
                        $('#detailMediaContainer').html(res.tahditMedia).show();
                        $('#detailMediaEmpty').hide();
                    } else {
                        $('#detailMediaContainer').html('').hide();
                        $('#detailMediaEmpty').show();
                    }

                    // Eğer yönetici ise düzenle butonu ID'sini ata
                    if (canManage) {
                        $('#btnDetailEditShortcut').data('id', res.id).show();
                    }
                } else {
                    $('#detailLoadedContent').html('<div class="alert alert-danger mb-0"><i class="fas fa-exclamation-triangle mr-2"></i>Kayıt bulunamadı.</div>').show();
                }
            })
            .fail(function () {
                $('#detailLoadingState').hide();
                $('#detailLoadedContent').html('<div class="alert alert-danger mb-0"><i class="fas fa-exclamation-triangle mr-2"></i>Detay verisi yüklenirken sunucu hatası oluştu.</div>').show();
            });
    });

    // Detay modaldan Düzenle modala geçiş
    $('#btnDetailEditShortcut').on('click', function () {
        var id = $(this).data('id');
        $('#detailModal').modal('hide');
        setTimeout(function () {
            openEditModal(id);
        }, 350);
    });

    /* ----------------------------------------------------------------------
       7. Düzenle Modal (Yönetici Yetkisi Varsa)
       ---------------------------------------------------------------------- */
    function openEditModal(id) {
        if (!id) return;

        $.get(detailUrl + '/' + id)
            .done(function (res) {
                if (!res || !res.success) {
                    alert('Tahdit bilgileri alınamadı.');
                    return;
                }

                $('#Edit_Id').val(res.id);
                $('#Edit_Kod').val(res.kod);
                $('#Edit_Aciklama').val(res.aciklama);
                $('#Edit_SureAy').val(res.sureAy);
                $('#Edit_GirisGelirse').val(res.girisGelirse);
                $('#Edit_CikisGelirse').val(res.cikisGelirse);

                var isAktif = res.aktif === true;
                $('#Edit_Aktif').prop('checked', isAktif);
                $('#Edit_Aktif_Hidden').val(isAktif ? 'true' : 'false');
                $('#Edit_AktifText').text(isAktif ? 'Aktif' : 'Pasif');

                var $sn = $('#Edit_TahditMedia');
                if ($sn.next('.note-editor').length) {
                    $sn.summernote('code', res.tahditMedia || '');
                } else {
                    $sn.val(res.tahditMedia || '');
                }

                $('#editModal').modal('show');
            })
            .fail(function () {
                alert('Sunucu ile bağlantı hatası oluştu.');
            });
    }

    if (canManage) {
        $(document).on('click', '.btn-edit', function () {
            var id = $(this).data('id');
            openEditModal(id);
        });

        // Switch senkronizasyonu
        $('#Edit_Aktif').on('change', function () {
            var checked = $(this).is(':checked');
            $('#Edit_Aktif_Hidden').val(checked ? 'true' : 'false');
            $('#Edit_AktifText').text(checked ? 'Aktif' : 'Pasif');
        });

        /* ------------------------------------------------------------------
           8. Summernote Editörü Yapılandırması
           ------------------------------------------------------------------ */
        var summernoteOpts = {
            height       : 220,
            lang         : 'tr-TR',
            dialogsInBody: true,
            callbacks    : {
                onImageUpload: function (files) {
                    var $editor = $(this);
                    if (!files || files.length === 0) return;

                    var formData = new FormData();
                    formData.append('file', files[0]);
                    formData.append('__RequestVerificationToken', antiForgery);

                    $.ajax({
                        url         : uploadUrl,
                        type        : 'POST',
                        data        : formData,
                        processData : false,
                        contentType : false,
                        success     : function (data) {
                            if (data && data.url) {
                                $editor.summernote('insertImage', data.url);
                            } else if (data && data.error) {
                                alert('Resim yükleme hatası: ' + data.error);
                            }
                        },
                        error       : function () {
                            alert('Resim sunucuya yüklenirken bir ağ veya yetki hatası oluştu.');
                        }
                    });
                }
            },
            toolbar : [
                ['style',  ['bold', 'italic', 'underline', 'clear']],
                ['font',   ['strikethrough']],
                ['para',   ['ul', 'ol', 'paragraph']],
                ['insert', ['link', 'picture', 'table']],
                ['view',   ['fullscreen', 'codeview']]
            ]
        };

        if ($.fn.summernote) {
            $('#Yeni_TahditMedia').summernote(summernoteOpts);
            $('#Edit_TahditMedia').summernote(summernoteOpts);
        }

        // Form submit öncesi Summernote içeriğini senkronize et
        $('#createForm, #editForm').on('submit', function () {
            var $sn = $(this).find('textarea[name="TahditMedia"]');
            if ($sn.length && $.fn.summernote && $sn.next('.note-editor').length) {
                $sn.val($sn.summernote('code'));
            }
        });
    }
});
