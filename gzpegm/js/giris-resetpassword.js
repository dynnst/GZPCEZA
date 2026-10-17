/* ==========================================================================
   Sifre Sifirlama JavaScript (giris-resetpassword.js)
   ========================================================================== */

/* =========================
           YARDIMCI FONKSİYONLAR
        ========================= */
        function esc(t) {
            if (t === null || t === undefined) return '';
            return String(t).replace(/[&<>"']/g, function(c) {
                return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' }[c];
            });
        }

        function getAntiForgeryToken() {
            return $('input[name="__RequestVerificationToken"]').first().val();
        }

        /* Toast mesaj */
        function showToast(message, type) {
            var icon = (type === 'error') ? 'fa-times-circle' : 'fa-check-circle';
            var cssErr = (type === 'error') ? ' error' : '';
            var $toast = $('<div class="toast-msg' + cssErr + '"></div>')
                .html('<i class="fas ' + icon + '"></i> ' + esc(message));
            $('#toastContainer').append($toast);
            setTimeout(function () {
                $toast.fadeOut(300, function () { $(this).remove(); });
            }, 2500);
        }

        /* =========================
           ŞİFRE KOPYALA
        ========================= */
        function copyPassword() {
            var el = document.getElementById('passwordDisplay');
            if (!el) { showToast('Şifre bulunamadı!', 'error'); return; }
            var text = el.textContent.trim();
            if (!text) { showToast('Şifre boş!', 'error'); return; }

            if (navigator.clipboard && window.isSecureContext) {
                navigator.clipboard.writeText(text)
                    .then(function () { showToast('Şifre kopyalandı'); })
                    .catch(function () { fallbackCopy(text); });
            } else {
                fallbackCopy(text);
            }
        }

        function fallbackCopy(text) {
            var ta = document.createElement('textarea');
            ta.value = text;
            ta.style.position = 'fixed';
            ta.style.opacity = '0';
            document.body.appendChild(ta);
            ta.select();
            try {
                document.execCommand('copy');
                showToast('Şifre kopyalandı');
            } catch (e) {
                showToast('Kopyalanamadı, elle seçiniz.', 'error');
            }
            document.body.removeChild(ta);
        }

        /* =========================
           SONUÇ KUTUSU
        ========================= */
        function showResult(type, title, content) {
            $('#resultBox')
                .removeClass('success error')
                .addClass(type)
                .show();
            $('#resultTitle').text(title);
            $('#resultContent').html(content);
        }

        function hideResult() {
            $('#resultBox').hide().removeClass('success error');
            $('#resultTitle').text('');
            $('#resultContent').empty();
        }

        /* =========================
           FORM SUBMIT
        ========================= */
        $(function () {
            $('#resetForm').on('submit', function (e) {
                e.preventDefault();

                var sicil = $.trim($('#sicil').val());
                var email = $.trim($('#email').val());

                // Basit doğrulama
                if (!sicil || !email) {
                    showResult('error', '❌ Hata', 'Lütfen tüm alanları doldurunuz!');
                    return;
                }

                // Sicil sadece rakam olmalı
                if (!/^[0-9]+$/.test(sicil)) {
                    showResult('error', '❌ Hata', 'Sicil numarası sadece rakamlardan oluşmalıdır.');
                    return;
                }

                if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
                    showResult('error', '❌ Hata', 'Geçerli bir e-posta adresi giriniz.');
                    return;
                }

                // Eski sonucu temizle
                hideResult();

                // Yükleniyor göster
                $('#loadingSpinner').show();
                $('#submitBtn').prop('disabled', true)
                    .html('<i class="fas fa-spinner fa-spin"></i> İşleniyor...');

                $.ajax({
                    url: (document.getElementById('reset-config') ? document.getElementById('reset-config').getAttribute('data-reset-url') : '/Giris/ResetPassword'),
                    type: 'POST',
                    data: {
                        sicil: sicil,
                        email: email,
                        __RequestVerificationToken: getAntiForgeryToken()
                    },
                    dataType: 'json',
                    success: function (r) {
                        if (r && r.success) {
                            var userInfo = r.userInfo || {};
                            var content = '';

                            // Kullanıcı bilgileri
                            content += '<div style="margin-bottom:14px;">';
                            if (userInfo.sicil) {
                                content += '<p style="margin:4px 0;"><strong>🎫 Sicil:</strong> ' + esc(userInfo.sicil) + '</p>';
                            }
                            if (userInfo.adSoyad) {
                                content += '<p style="margin:4px 0;"><strong>👤 Ad Soyad:</strong> ' + esc(userInfo.adSoyad) + '</p>';
                            }
                            content += '</div>';

                            // Yeni şifre kutusu
                            if (userInfo.yeniSifre) {
                                content += '<div class="warning-note">';
                                content += '<p><i class="fas fa-key"></i> Yeni Şifreniz:</p>';
                                content += '<div class="password-display" id="passwordDisplay">' + esc(userInfo.yeniSifre) + '</div>';
                                content += '<div class="btn-action-group">';
                                content += '<button type="button" class="btn-copy" onclick="copyPassword()">';
                                content += '<i class="fas fa-copy"></i> Kopyala</button>';
                                content += '<a href="@Url.Action("Index", "Giris")" class="btn-login">';
                                content += '<i class="fas fa-sign-in-alt"></i> Giriş Yap</a>';
                                content += '</div>';
                                content += '</div>';
                            }

                            // Talimatlar
                            content += '<div class="info-note">';
                            content += '<strong><i class="fas fa-info-circle"></i> Talimatlar:</strong>';
                            content += '<ul>';
                            content += '<li><strong style="color:#ffc107;">Yönetici onayını bekleyiniz.</strong></li>';
                            content += '<li>Onaydan sonra bu şifreyle sisteme giriş yapınız</li>';
                            content += '<li>Bu şifreyi güvenli bir yerde saklayınız</li>';
                            content += '<li>Bu pencereyi kapattıktan sonra şifre tekrar gösterilmez</li>';
                            content += '</ul>';
                            content += '</div>';

                            // Kapat butonu
                            content += '<button type="button" class="btn-close-result" onclick="hideResult()">';
                            content += '<i class="fas fa-times"></i> Anladım, Kapat</button>';

                            showResult('success', '✅ Şifre Sıfırlama Talebi Alındı', content);
                            showToast('Yönetici onayı bekleniyor');
                        } else {
                            showResult('error', '❌ Hata', esc((r && r.message) || 'Şifre sıfırlanamadı.'));
                        }
                    },
                    error: function (xhr) {
                        var msg = 'Sunucuya ulaşılamadı.';
                        if (xhr && xhr.status === 400) {
                            msg = 'Güvenlik doğrulaması başarısız. Sayfayı yenileyip tekrar deneyin.';
                        } else if (xhr && xhr.status === 404) {
                            msg = 'Servis bulunamadı.';
                        } else if (xhr && xhr.status === 500) {
                            msg = 'Sunucu hatası oluştu.';
                        }
                        showResult('error', '❌ Hata', msg);
                    },
                    complete: function () {
                        $('#loadingSpinner').hide();
                        $('#submitBtn').prop('disabled', false)
                            .html('<i class="fas fa-sync-alt"></i> Şifreyi Sıfırla');
                    }
                });
            });

            // ESC ile sonuç kutusunu kapat
            $(document).on('keydown', function (e) {
                if (e.key === 'Escape') hideResult();
            });
        });
