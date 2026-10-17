/* ==========================================================================
   Sinir Kapilari Yonetimi JavaScript (border-index.js)
   ========================================================================== */

$(document).ready(function () {
    var cfg = document.getElementById('border-config');
    var addUrl = (cfg && cfg.getAttribute('data-add-url')) || '/addborder';
    var deleteUrl = (cfg && cfg.getAttribute('data-delete-url')) || '/deleteborder';
    var personnelUrl = (cfg && cfg.getAttribute('data-personnel-url')) || '/GetBorderPersonnel';

    var modalPersonnelDt = null;

    // 1. Ana Tablo DataTables Başlatma
    if ($.fn.DataTable && !$.fn.DataTable.isDataTable('#borderDataTable')) {
        $('#borderDataTable').DataTable({
            pageLength: 25,
            lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "Tümü"]],
            order: [[1, "asc"]],
            autoWidth: false,
            language: {
                emptyTable: "Tabloda herhangi bir sınır kapısı bulunamadı",
                info: "_TOTAL_ kayıttan _START_ - _END_ arası gösteriliyor",
                infoEmpty: "Kayıt yok",
                infoFiltered: "(_MAX_ kayıt içerisinden filtrelendi)",
                lengthMenu: "Sayfada _MENU_ kayıt göster",
                loadingRecords: "Yükleniyor...",
                processing: "İşleniyor...",
                search: "Kapı Ara:",
                zeroRecords: "Eşleşen sınır kapısı bulunamadı",
                paginate: {
                    first: "İlk",
                    last: "Son",
                    next: "Sonraki",
                    previous: "Önceki"
                }
            },
            columnDefs: [
                { orderable: false, targets: [0, 4] }, // # ve İşlemler sıralanmaz
                { searchable: false, targets: [0, 4] }
            ]
        });
    }

    // 2. Personel Görüntüleme Modal Tıklaması
    $(document).on('click', '.btn-view-personnel', function (e) {
        e.preventDefault();
        var borderName = $(this).attr('data-border');
        if (!borderName) return;

        openPersonnelModal(borderName);
    });

    function openPersonnelModal(borderName) {
        $('#modalBorderName').text(borderName);
        $('#modalPersonnelCountBadge').text('Yükleniyor...');
        $('#personnelLoading').show();
        $('#personnelEmpty').hide();
        $('#personnelTableWrapper').hide();

        // Eğer önceki bir DataTable varsa temizle
        if (modalPersonnelDt) {
            modalPersonnelDt.destroy();
            modalPersonnelDt = null;
        }
        $('#modalPersonnelTableBody').empty();

        $('#borderPersonnelModal').modal('show');

        $.ajax({
            url: personnelUrl,
            type: 'GET',
            data: { borderName: borderName },
            dataType: 'json',
            success: function (res) {
                $('#personnelLoading').hide();

                if (!res || !res.success) {
                    var errorMsg = (res && res.message) ? res.message : 'Personel verileri alınırken bir sorun oluştu.';
                    $('#personnelEmpty').find('p').text(errorMsg);
                    $('#personnelEmpty').show();
                    $('#modalPersonnelCountBadge').text('0 Personel');
                    return;
                }

                var list = res.data || [];
                $('#modalPersonnelCountBadge').text(list.length + ' Personel');

                if (list.length === 0) {
                    $('#personnelEmpty').find('p').text('Bu sınır kapısına kayıtlı herhangi bir personel bulunmamaktadır.');
                    $('#personnelEmpty').show();
                    return;
                }

                var rowsHtml = '';
                for (var i = 0; i < list.length; i++) {
                    var user = list[i];
                    var initials = getInitials(user.FullName);

                    // Rol rozeti
                    var roleBadgeClass = 'badge-role-student';
                    var roleText = user.Role || 'Kullanıcı';
                    if (roleText.toLowerCase() === 'admin') {
                        roleBadgeClass = 'badge-role-admin';
                    } else if (roleText.toLowerCase() === 'teacher' || roleText.toLowerCase() === 'öğretmen') {
                        roleBadgeClass = 'badge-role-teacher';
                    }

                    // Durum rozeti
                    var statusHtml = user.IsActive
                        ? '<span class="badge-status-active"><span class="status-dot status-dot-active"></span>Aktif</span>'
                        : '<span class="badge-status-inactive"><span class="status-dot status-dot-inactive"></span>Pasif</span>';

                    // İletişim bilgisi
                    var phoneHtml = (user.Phone && user.Phone !== '-')
                        ? '<div class="contact-item"><i class="fas fa-phone-alt"></i><span>' + escapeHtml(user.Phone) + '</span></div>'
                        : '';
                    var emailHtml = (user.Email && user.Email !== '-')
                        ? '<div class="contact-item"><i class="fas fa-envelope"></i><span>' + escapeHtml(user.Email) + '</span></div>'
                        : '';
                    var contactHtml = (phoneHtml || emailHtml) ? (phoneHtml + emailHtml) : '<span class="text-muted">-</span>';

                    rowsHtml += '<tr>' +
                        '<td class="text-center font-weight-bold text-muted">' + (i + 1) + '</td>' +
                        '<td class="text-center text-nowrap"><span class="badge badge-light border text-dark font-monospace px-2 py-1">' + escapeHtml(user.Sicil) + '</span></td>' +
                        '<td>' +
                            '<div class="d-flex align-items-center">' +
                                '<span class="user-avatar-circle mr-2">' + initials + '</span>' +
                                '<div>' +
                                    '<span class="font-weight-semibold text-dark d-block">' + escapeHtml(user.FullName) + '</span>' +
                                    (user.CreatedDate && user.CreatedDate !== '-' ? '<small class="text-muted"><i class="far fa-calendar-alt mr-1"></i>Kayıt: ' + escapeHtml(user.CreatedDate) + '</small>' : '') +
                                '</div>' +
                            '</div>' +
                        '</td>' +
                        '<td>' +
                            '<span class="font-weight-semibold text-dark d-block">' + escapeHtml(user.Title) + '</span>' +
                            (user.Deputy && user.Deputy !== '-' ? '<small class="text-muted">' + escapeHtml(user.Deputy) + '</small>' : '') +
                        '</td>' +
                        '<td>' + contactHtml + '</td>' +
                        '<td class="text-center text-nowrap"><span class="' + roleBadgeClass + '">' + escapeHtml(roleText) + '</span></td>' +
                        '<td class="text-center text-nowrap">' + statusHtml + '</td>' +
                        '<td class="text-center text-nowrap"><small class="font-weight-semibold text-secondary">' + escapeHtml(user.LastLogin) + '</small></td>' +
                    '</tr>';
                }

                $('#modalPersonnelTableBody').html(rowsHtml);
                $('#personnelTableWrapper').show();

                // Modal içi DataTable başlatma
                if ($.fn.DataTable) {
                    modalPersonnelDt = $('#modalPersonnelTable').DataTable({
                        pageLength: 10,
                        lengthMenu: [[10, 25, 50, -1], [10, 25, 50, "Tümü"]],
                        order: [[2, "asc"]],
                        autoWidth: false,
                        language: {
                            emptyTable: "Kayıt bulunamadı",
                            info: "_TOTAL_ personelden _START_ - _END_ arası",
                            infoEmpty: "Kayıt yok",
                            infoFiltered: "(_MAX_ personel içerisinden filtrelendi)",
                            lengthMenu: "_MENU_ personel",
                            search: "Personel Ara:",
                            zeroRecords: "Aramaya uygun personel bulunamadı",
                            paginate: {
                                first: "İlk",
                                last: "Son",
                                next: "Sonraki",
                                previous: "Önceki"
                            }
                        },
                        columnDefs: [
                            { orderable: false, targets: [0, 4] }
                        ]
                    });

                    setTimeout(function () {
                        if (modalPersonnelDt) {
                            modalPersonnelDt.columns.adjust().draw();
                        }
                    }, 200);
                }
            },
            error: function () {
                $('#personnelLoading').hide();
                $('#personnelEmpty').find('p').text('Sunucu ile iletişim kurulurken bir hata oluştu.');
                $('#personnelEmpty').show();
                $('#modalPersonnelCountBadge').text('Hata');
            }
        });
    }

    // Modal açılışında DataTables sütun genişliklerini düzelt
    $('#borderPersonnelModal').on('shown.bs.modal', function () {
        if (modalPersonnelDt) {
            modalPersonnelDt.columns.adjust().draw();
        }
    });

    // 3. Yeni Kapı Ekleme Form Submit
    $('#addBorderForm').on('submit', function (e) {
        e.preventDefault();

        var borderInput = $('#borderNameInput');
        var borderVal = $.trim(borderInput.val());
        var alertBox = $('#addBorderAlert');
        var submitBtn = $('#btnAddBorderSubmit');

        alertBox.hide().empty();

        if (!borderVal) {
            alertBox.text('Lütfen sınır kapısı ismini giriniz.').show();
            borderInput.focus();
            return;
        }

        var token = $('input[name="__RequestVerificationToken"]').first().val();
        submitBtn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin mr-1"></i> Kaydediliyor...');

        $.ajax({
            url: addUrl,
            type: 'POST',
            data: {
                border: borderVal,
                __RequestVerificationToken: token
            },
            success: function (result) {
                if (result && result.command) {
                    eval(result.command);
                } else {
                    location.reload();
                }
            },
            error: function () {
                alertBox.text('Sunucu hatası oluştu, lütfen tekrar deneyiniz.').show();
                submitBtn.prop('disabled', false).html('<i class="fas fa-save mr-1"></i> Kaydet');
            }
        });
    });

    // 4. Silme Butonu Tıklaması
    $(document).on('click', '.btn-delete-border', function () {
        var id = $(this).data('id');
        var name = $(this).data('name') || 'Bu sınır kapısını';

        if (!confirm(name + ' sınır kapısını silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.')) {
            return;
        }

        var token = $('input[name="__RequestVerificationToken"]').first().val();

        $.ajax({
            url: deleteUrl,
            type: 'POST',
            data: {
                Id: id,
                __RequestVerificationToken: token
            },
            success: function (result) {
                if (result && result.command) {
                    eval(result.command);
                } else {
                    location.reload();
                }
            },
            error: function () {
                alert('Silme işlemi sırasında hata oluştu.');
            }
        });
    });

    // Modal açıldığında inputa otomatik odaklan
    $('#addBorderModal').on('shown.bs.modal', function () {
        $('#borderNameInput').focus();
    });

    // Yardımcı Fonksiyonlar
    function getInitials(name) {
        if (!name) return '?';
        var parts = $.trim(name).split(/\s+/);
        if (parts.length === 1) {
            return parts[0].substring(0, Math.min(2, parts[0].length)).toUpperCase();
        }
        return (parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase();
    }

    function escapeHtml(text) {
        if (!text) return '';
        return String(text)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#039;');
    }
});

// Geriye dönük uyumluluk inline çağrıları
function addborder() {
    $('#addBorderModal').modal('show');
}

function deleteborder(Id) {
    if (!confirm('Kapıyı silmek istediğinizden emin misiniz?')) {
        return false;
    }
    var token = $('input[name="__RequestVerificationToken"]').first().val();
    $.ajax({
        url: '/deleteborder',
        type: 'POST',
        data: {
            Id: Id,
            __RequestVerificationToken: token
        },
        success: function (result) {
            eval(result.command);
        }
    });
}
