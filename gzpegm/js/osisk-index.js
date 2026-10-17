/* ==========================================================================
   OSISK Hudut Kapısı İstatistikleri JavaScript (osisk-index.js)
   ========================================================================== */

$(document).ready(function () {
    if ($.fn.DataTable) {
        $('#processTable').DataTable({
            "processing": true,
            "serverSide": true,
            "ajax": {
                "url": "/osIskData",
                "type": "GET"
            },
            "columns": [
                { "data": "tarih" },
                { "data": "adi" },
                { "data": "onay" },
                { "data": "kapi" },
                {
                    "data": "id",
                    "orderable": false,
                    "searchable": false,
                    "render": function (data) {
                        return '<a href="/formyazdir/' + data + '" target="_blank" class="btn btn-sm btn-outline-info" title="Formu Yazdır">' +
                            '<i class="fas fa-print"></i> Yazdır</a>';
                    }
                }
            ],
            "pageLength": 10,
            "lengthMenu": [5, 10, 25, 50],
            "order": [[0, "desc"]],
            "autoWidth": false,
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
