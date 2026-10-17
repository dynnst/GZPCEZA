/* ==========================================================================
   POLIS HAVALIMANI GIRIS SISTEMI (AIRPORT SECURITY LOGIN)
   JAVASCRIPT (giris-index.js)
   ========================================================================== */

// Input Kutusuna Tıklandığında Focus Verme
document.querySelectorAll('.cyber-input-wrapper').forEach(function (box) {
    box.addEventListener('click', function (e) {
        var input = box.querySelector('input');
        if (input && e.target !== input && !e.target.closest('.cyber-eye-toggle')) {
            input.focus();
        }
    });
});

// Şifre Göster / Gizle
function togglePassword() {
    var pwd = document.getElementById('pwd');
    var eye = document.getElementById('pwdEye');
    if (!pwd || !eye) return;

    if (pwd.type === 'password') {
        pwd.type = 'text';
        eye.classList.remove('fa-eye');
        eye.classList.add('fa-eye-slash');
    } else {
        pwd.type = 'password';
        eye.classList.remove('fa-eye-slash');
        eye.classList.add('fa-eye');
    }
}

// Caps Lock Uyarısı
(function () {
    var pwdInput = document.getElementById('pwd');
    var warning = document.getElementById('capsWarning');
    if (!pwdInput || !warning) return;

    function checkCaps(e) {
        if (e.getModifierState && e.getModifierState('CapsLock')) {
            warning.style.display = 'flex';
        } else {
            warning.style.display = 'none';
        }
    }

    pwdInput.addEventListener('keyup', checkCaps);
    pwdInput.addEventListener('keydown', checkCaps);
    pwdInput.addEventListener('blur', function () {
        warning.style.display = 'none';
    });
})();

// Beni Hatırla (LocalStorage Desteği)
(function () {
    var usernameInput = document.getElementById('username');
    var rememberMe = document.getElementById('rememberMe');
    if (!usernameInput || !rememberMe) return;

    // Sayfa açıldığında kayıtlı sicil varsa doldur
    var savedUsername = localStorage.getItem('cezam_saved_sicil');
    if (savedUsername) {
        usernameInput.value = savedUsername;
        rememberMe.checked = true;
    }

    // Form gönderilirken beni hatırla durumunu kaydet
    var form = document.getElementById('login');
    if (form) {
        form.addEventListener('submit', function () {
            if (rememberMe.checked) {
                localStorage.setItem('cezam_saved_sicil', usernameInput.value.trim());
            } else {
                localStorage.removeItem('cezam_saved_sicil');
            }
        });
    }
})();

// Çift Tıklama Koruması ve Yükleniyor Göstergesi
(function () {
    var form = document.getElementById('login');
    var btn = document.getElementById('btnLogin');
    if (!form || !btn) return;

    form.addEventListener('submit', function () {
        if (form.checkValidity()) {
            btn.disabled = true;
            btn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i> GİRİŞ YAPILIYOR...';
        }
    });
})();

// Autofill Dinamik Algılayıcı ve Neon Işıma Entegrasyonu
(function () {
    function markAutofill(input) {
        if (!input) return;
        var wrapper = input.closest('.cyber-input-wrapper');
        if (!wrapper) return;

        try {
            if (input.matches(':-webkit-autofill') || input.matches(':autofill')) {
                wrapper.classList.add('has-autofill');
                return;
            }
        } catch (e) {}

        if (input.value && input.value.trim().length > 0) {
            wrapper.classList.add('has-autofill');
        } else {
            wrapper.classList.remove('has-autofill');
        }
    }

    document.addEventListener('animationstart', function (e) {
        if (e.animationName === 'onAutoFillStart') {
            markAutofill(e.target);
        }
    }, true);

    document.querySelectorAll('.cyber-input').forEach(function (input) {
        ['input', 'change', 'blur', 'focus'].forEach(function (evt) {
            input.addEventListener(evt, function () {
                markAutofill(input);
            });
        });
    });

    // Sayfa açılışında tarayıcının otomatik doldurmasını yakala
    setTimeout(function () {
        document.querySelectorAll('.cyber-input').forEach(markAutofill);
    }, 100);
    setTimeout(function () {
        document.querySelectorAll('.cyber-input').forEach(markAutofill);
    }, 500);
    setTimeout(function () {
        document.querySelectorAll('.cyber-input').forEach(markAutofill);
    }, 1200);
})();
