/* =========================
   TARİH YARDIMCILARI
========================= */
function getLocalDateTimeForInput() {
    var now = new Date();
    now.setMinutes(now.getMinutes() - now.getTimezoneOffset());
    return now.toISOString().slice(0, 16);
}

function parseMsDateToLocal(value, isDateOnly) {
    if (!value) return "";
    var d = new Date(value);
    if (isNaN(d)) return "";
    return isDateOnly
        ? d.toISOString().slice(0, 10)
        : d.toISOString().slice(0, 16);
}

/* =========================
   YENİ KAYIT
========================= */
function openAdd() {

    $('#inadForm').attr('action', window.einadUrls.addInad);
    $('#inadModalTitle').text('Yeni Kayıt Ekle');
    $('#inadForm')[0].reset();
    $('#InadId').val(0);

    $('input[name="UcagaNakil"]').prop('checked', false);
    $('input[name="InadSebep"]').prop('checked', false);

    $('#TarihSaat').val(getLocalDateTimeForInput());

    $.get(window.einadUrls.getMyBorder)
        .done(function (res) {
            if (res && res.success) {
                if (res.border) {
                    $('#Kapi').val(res.border);
                    $('#Valilik').val(res.border.split(' ')[0]);
                }
                if (res.sicil) {
                    $('#Personel').val(res.sicil);
                    $('#Sicil').val(res.sicil);
                }
            }
        })
        .always(function () {
            $('#inadModal').modal('show');
        });
}

/* =========================
   DÜZENLE
========================= */
function openEdit(id) {

    $.get(window.einadUrls.getInad, { id: id }, function (res) {

        if (!res || !res.success) {
            alert("Veri alınamadı");
            return;
        }

        var d = res.data;

        $('#inadForm').attr('action', window.einadUrls.editInad);
        $('#inadModalTitle').text('Kayıt Düzenle');

        $('#InadId').val(d.InadId);
        $('#TarihSaat').val(parseMsDateToLocal(d.TarihSaat));
        $('#AdSoyad').val(d.AdSoyad);
        $('#DogumT').val(parseMsDateToLocal(d.DogumT, true));
        $('#DogumY').val(d.DogumY);
        $('#Cinsiyet').val(d.Cinsiyet);
        $('#Uyruk').val(d.Uyruk);

        $('#PasaportNo').val(d.PasaportNo);
        $('#BelgeNo').val(d.BelgeNo);
        $('#PasaportTuru').val(d.PasaportTuru);
        $('#Beyan').val(d.Beyan);
        $('#InadSebepAciklama').val(d.InadSebepAciklama);

        $('input[name="InadSebep"]').prop('checked', false);
        if (d.InadSebep) {
            d.InadSebep.split(',').forEach(function (v) {
                $('input[name="InadSebep"][value="' + v.trim() + '"]').prop('checked', true);
            });
        }

        $('input[name="UcagaNakil"]').prop('checked', false);
        if (d.UcagaNakil) {
            d.UcagaNakil.split(',').forEach(function (v) {
                $('input[name="UcagaNakil"][value="' + v.trim() + '"]').prop('checked', true);
            });
        }

        $('#inadModal').modal('show');
    });
}

/* =========================
   SİL
========================= */
function deleteRecord(id) {

    if (!confirm("Bu kayıt silinecek. Emin misiniz?"))
        return;

    $.post(window.einadUrls.deleteInad, {
        id: id,
        __RequestVerificationToken: $('input[name="__RequestVerificationToken"]').val()
    }).done(function (res) {
        if (res.success) location.reload();
        else alert(res.message || "Silme başarısız");
    });
}

/* =========================
   INIT
========================= */
$(function () {
    if ($.fn.DataTable) {
        $('#inad-table').DataTable();
    }
});
