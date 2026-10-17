/* ==========================================================================
   Yurtdisi Teskilati Ulkeler JavaScript (ulke-index.js)
   ========================================================================== */

function gosterModal(ulkeAdi, temsilcilik, telefon, adres) {
    var modalIcerik = document.getElementById("modalIcerik");
    if (modalIcerik) {
        modalIcerik.textContent = 
"Ülke: " + (ulkeAdi || '') + "\n" +
"Temsilcilik: " + (temsilcilik || '') + "\n" +
"Telefon: " + (telefon || '') + "\n" +
"Adres: " + (adres || '');
    }

    var el = document.getElementById('ulkeModal');
    if (el) {
        if (typeof bootstrap !== 'undefined' && bootstrap.Modal) {
            new bootstrap.Modal(el).show();
        } else if (window.jQuery) {
            $(el).modal('show');
        }
    }
}

document.addEventListener('DOMContentLoaded', function () {
    var searchBox = document.getElementById("aramaKutusu");
    if (searchBox) {
        searchBox.addEventListener('input', function () {
            var filtre = (this.value || '').toLowerCase();
            var kartlar = document.querySelectorAll(".ulkeKart");
            kartlar.forEach(function (k) {
                var text = (k.innerText || '').toLowerCase();
                if (k.parentElement) {
                    k.parentElement.style.display = text.indexOf(filtre) !== -1 ? 'block' : 'none';
                }
            });
        });
    }
});
