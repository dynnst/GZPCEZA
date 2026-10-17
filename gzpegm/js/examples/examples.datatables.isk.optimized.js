/*
Name: ISK DataTable - Optimized Version
Description: Performans için optimize edilmiş DataTable konfigürasyonu
*/

(function($) {
    'use strict';

    var datatableInit = function() {
        var $table = $('#datatable-tabletools');

        // Optimize edilmiş DataTable ayarları
        var table = $table.DataTable({
            // Sayfalama
            "pageLength": 50, // Sayfa başına 50 kayıt
            "lengthMenu": [[25, 50, 100, 200], [25, 50, 100, 200]],
            
            // Performans optimizasyonları
            "deferRender": true, // Sadece görünen satırları render et
            "processing": true, // İşlem göstergesi
            "stateSave": true, // Kullanıcı tercihlerini kaydet
            "stateDuration": 60 * 60, // 1 saat
            
            // Sıralama
            "order": [[1, "desc"]], // Tarih sütununa göre azalan
            
            // Dil ayarları
            "language": {
                "processing": "İşleniyor...",
                "lengthMenu": "Sayfada _MENU_ kayıt göster",
                "info": "_TOTAL_ kayıttan _START_ - _END_ arası gösteriliyor",
                "infoEmpty": "Kayıt yok",
                "infoFiltered": "(_MAX_ kayıt içerisinden bulunan)",
                "search": "Ara:",
                "paginate": {
                    "first": "İlk",
                    "last": "Son",
                    "next": "Sonraki",
                    "previous": "Önceki"
                }
            },
            
            // Export butonları (sadece gerekli olanlar)
            dom: 'Blfrtip',
            buttons: [
                {
                    extend: 'excel',
                    text: '<i class="fas fa-file-excel"></i> Excel',
                    className: 'btn btn-success btn-sm',
                    exportOptions: {
                        columns: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11] // Resim ve Eylemler hariç
                    }
                },
                {
                    extend: 'print',
                    text: '<i class="fas fa-print"></i> Yazdır',
                    className: 'btn btn-primary btn-sm',
                    exportOptions: {
                        columns: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
                    }
                }
            ],
            
            // Sütun ayarları
            "columnDefs": [
                {
                    "targets": 0, // Resim sütunu
                    "orderable": false,
                    "searchable": false
                },
                {
                    "targets": 12, // Eylemler sütunu
                    "orderable": false,
                    "searchable": false
                }
            ]
        });

        // Buton stillerini düzenle
        $('.dt-buttons').addClass('mb-3');
    };

    $(function() {
        datatableInit();
    });

}).apply(this, [jQuery]);
