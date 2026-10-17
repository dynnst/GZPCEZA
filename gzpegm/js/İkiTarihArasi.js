// İki Gün Hesapla butonu
function showIkiGunHesap() {
    let today = new Date();
    let yyyy = today.getFullYear();
    let mm = String(today.getMonth() + 1).padStart(2, '0');
    let dd = String(today.getDate()).padStart(2, '0');
    let formatted = yyyy + '-' + mm + '-' + dd;

    $('#t2').val(formatted);
    $("#gunFarkiModal").modal("show");
}

function hesaplaGunFarki() {
    const t1Val = $('#t1').val();
    const t2Val = $('#t2').val();

    if (!t1Val || !t2Val) {
        alert("Lütfen iki tarih seçin.");
        return;
    }

    const t1 = new Date(t1Val);
    const t2 = new Date(t2Val);

    const farkMs = t2 - t1;
    const farkGun = Math.abs(Math.floor(farkMs / (1000 * 60 * 60 * 24)));

    $('#modalIcerik').text("İki tarih arasındaki gün farkı: " + farkGun + " gün");
}