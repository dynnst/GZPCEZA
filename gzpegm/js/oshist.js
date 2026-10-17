/* ==========================================================================
   OSHIST Yapılan İşlem Geçmişi JavaScript (oshist.js)
   ========================================================================== */

$(document).ready(function () {
    if ($.fn.DataTable) {
        $('#historyTable').DataTable({
            "pageLength": 10,
            "lengthMenu": [5, 10, 25, 50],
            "order": [[3, "desc"]],
            "autoWidth": false,
            "searching": false,
            "language": {
                "processing": "Yükleniyor...",
                "emptyTable": "Hiç işlem bulunamadı",
                "lengthMenu": "_MENU_ kayıt göster",
                "search": "Ara:",
                "info": "_START_ - _END_ / _TOTAL_ kayıt",
                "infoEmpty": "Kayıt yok",
                "infoFiltered": "(_MAX_ kayıt içinden filtrelendi)",
                "paginate": {
                    "first": "İlk",
                    "last": "Son",
                    "next": "Sonraki",
                    "previous": "Önceki"
                }
            }
        });
    }
});
