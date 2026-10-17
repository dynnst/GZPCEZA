/* ==========================================================================
   Kullanici Islem Gecmisi JavaScript (userhistory.js)
   ========================================================================== */

$(document).ready(function () {
            if ($.fn.DataTable) {
                $('#historyTable').DataTable({
                    "pageLength": 10,
                    "lengthMenu": [5, 10, 25, 50],
                    "order": [[1, "desc"]],
                    "autoWidth": false,
                    "language": {
                        "emptyTable": "Hiç işlem bulunamadı",
                        "lengthMenu": "_MENU_ kayıt göster",
                        "info": "_START_ - _END_ / _TOTAL_ kayıt",
                        "infoEmpty": "Kayıt yok",
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
