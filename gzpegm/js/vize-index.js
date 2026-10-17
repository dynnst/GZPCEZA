/* ==========================================================================
   Sartli Vize Giris JavaScript (vize-index.js)
   ========================================================================== */

window.addEventListener("load", function () {
    var form = document.querySelector("form[action='/AddSVIZE']") || document.getElementById("vizeForm");
    if (!form) {
        return;
    }

    var submitBtn = form.querySelector("button[type='submit']");
    var elements = form.querySelectorAll("input, select, textarea, button");
    elements.forEach(function (el) {
        el.disabled = true;
    });

    if (submitBtn) {
        submitBtn.style.display = 'none';
    }

    var imagePath = "/files/Genelge/V-84.JPG";

    if (typeof Swal !== 'undefined') {
        Swal.fire({
            title: 'Dikkat!',
            html: '<div style="text-align:center;">' +
                '<img src="' + imagePath + '" alt="Bilgilendirme Resmi" style="max-width:600px; width:100%; height:auto; margin-bottom:20px;" />' +
                '<p style="font-size:16px; margin:10px 0;">Bu formu doldurmadan önce tüm bilgilerinizi kontrol ediniz.<br>Eksik veya hatalı bilgiler işlem sürecini etkileyebilir.</p>' +
                '</div>',
            width: 800,
            confirmButtonText: 'Tamam',
            allowOutsideClick: false,
            allowEscapeKey: false,
            showClass: {
                popup: 'animate__animated animate__fadeInDown'
            },
            hideClass: {
                popup: 'animate__animated animate__fadeOutUp'
            }
        }).then(function (result) {
            if (result.isConfirmed) {
                elements.forEach(function (el) { el.disabled = false; });
                if (submitBtn) {
                    submitBtn.style.display = 'inline-block';
                }
            }
        });
    } else {
        elements.forEach(function (el) { el.disabled = false; });
        if (submitBtn) {
            submitBtn.style.display = 'inline-block';
        }
    }
});
