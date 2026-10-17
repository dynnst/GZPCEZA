/* ==========================================================================
   HIST Admin Eski Hesaplamalar JavaScript (hist-admin.js)
   ========================================================================== */

$(document).ready(function () {
    if ($.fn.DataTable && !$.fn.DataTable.isDataTable('#datatable-hist-admin')) {
        $('#datatable-hist-admin').DataTable({
            pageLength: 25,
            order: [[2, "desc"]],
            autoWidth: false,
            searching: false,
            language: {
                emptyTable: "Tabloda herhangi bir veri mevcut değil",
                info: "_TOTAL_ kayıttan _START_ - _END_ arası gösteriliyor",
                infoEmpty: "Kayıt yok",
                lengthMenu: "Sayfada _MENU_ kayıt göster",
                search: "Ara:",
                zeroRecords: "Eşleşen kayıt bulunamadı",
                paginate: { first: "İlk", last: "Son", next: "Sonraki", previous: "Önceki" }
            }
        });
    }
});
