/* ==========================================================================
   Ceza Kesilen Yolcular JavaScript (isk-index.js)
   ========================================================================== */

$(document).ready(function () {
    if ($.fn.DataTable && !$.fn.DataTable.isDataTable('#penaltyTable')) {
        $('#penaltyTable').DataTable({
            pageLength: 10,
            searching: false,          // DataTables'ın kendi arama kutusunu gizler
            deferRender: true,
            order: [[1, "desc"]],
            language: {
                decimal: ",",
                thousands: ".",
                emptyTable: "Tabloda herhangi bir veri mevcut değil",
                info: "_TOTAL_ kayıttan _START_ - _END_ arası gösteriliyor",
                infoEmpty: "Kayıt yok",
                infoFiltered: "(_MAX_ kayıt içerisinden bulunan)",
                lengthMenu: "Sayfada _MENU_ kayıt göster",
                loadingRecords: "Yükleniyor...",
                processing: "İşleniyor...",
                search: "Ara:",
                zeroRecords: "Eşleşen kayıt bulunamadı",
                paginate: {
                    first: "İlk",
                    last: "Son",
                    next: "Sonraki",
                    previous: "Önceki"
                },
                aria: {
                    sortAscending: ": artan sütun sıralamasını aktifleştir",
                    sortDescending: ": azalan sütun sıralamasını aktifleştir"
                }
            },
            columnDefs: [
                { orderable: false, targets: [0, 12] } // Resim ve işlem sütunları sıralanamaz
            ]
        });
    }
});

function deleteRecord(id) {
    if (confirm('Bu kaydı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.')) {
        var config = document.getElementById('isk-config');
        var deleteUrl = (config && config.getAttribute('data-delete-url')) ? config.getAttribute('data-delete-url') : '/DeleteIsk';
        $.ajax({
            url: deleteUrl,
            type: 'POST',
            data: { Id: id },
            success: function (response) {
                if (response.success) {
                    if (typeof toastr !== 'undefined') {
                        toastr.success('Kayıt başarıyla silindi');
                    } else {
                        alert('Kayıt başarıyla silindi');
                    }
                    setTimeout(function () {
                        location.reload();
                    }, 1000);
                } else {
                    if (typeof toastr !== 'undefined') {
                        toastr.error('Silme işlemi başarısız: ' + response.message);
                    } else {
                        alert('Silme işlemi başarısız: ' + response.message);
                    }
                }
            },
            error: function () {
                if (typeof toastr !== 'undefined') {
                    toastr.error('Bir hata oluştu');
                } else {
                    alert('Bir hata oluştu');
                }
            }
        });
    }
}
