/**
 * country-documents.js - EGM Hudut Kapıları Ülke Yazıları & Mevzuat Bilgi Bankası
 * Hem Home/Index hem de Genelge/Index sayfalarında ortak çalışan interaktif ülke masası.
 */
(function () {
    'use strict';

    var currentCountry = '';

    function getEl(id) {
        return document.getElementById(id);
    }

    function escapeHtml(text) {
        if (!text) return '';
        var map = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' };
        return String(text).replace(/[&<>"']/g, function (m) { return map[m]; });
    }

    function initCountryDocuments() {
        var modalEl = getEl('countryDocumentsModal');
        if (!modalEl) return;

        // Modal'ları body altına taşı (backdrop ve z-index stacking sorunlarını önlemek için)
        try {
            if (modalEl.parentNode && modalEl.parentNode.tagName !== 'BODY') {
                document.body.appendChild(modalEl);
            }
            var vEl = getEl('modalCountryDocViewer');
            if (vEl && vEl.parentNode && vEl.parentNode.tagName !== 'BODY') {
                document.body.appendChild(vEl);
            }
            var reqEl = getEl('modalCountryDocAccessRequest');
            if (reqEl && reqEl.parentNode && reqEl.parentNode.tagName !== 'BODY') {
                document.body.appendChild(reqEl);
            }
        } catch (e) { }

        // Event Dinleyicileri (jQuery ile)
        if (typeof $ !== 'undefined') {
            // Açma butonları (Hem ana sayfadaki hem de genelgelerdeki butonlar)
            $(document).off('click.cdOpen').on('click.cdOpen', '#btnOpenCountryDocsModal, [data-target="#countryDocumentsModal"], .btn-open-country-docs-desk', function (e) {
                if (e && e.preventDefault) e.preventDefault();
                showCountryModal();
            });

            // Ülke Arama ve Seçim
            $(document).off('click.cdFetch').on('click.cdFetch', '#btnCdFetchCountry', function () {
                var c = $('#cdCountrySelect').val();
                if (c) loadCountryData(c);
            });

            $(document).off('change.cdSelect').on('change.cdSelect', '#cdCountrySelect', function () {
                var c = $(this).val();
                if (c) loadCountryData(c);
            });

            // Hızlı Ülke Kısayol Rozetleri
            $(document).off('click.cdQuick').on('click.cdQuick', '.btn-quick-country', function () {
                var c = $(this).data('country');
                if (c) {
                    $('#cdCountrySelect').val(c);
                    loadCountryData(c);
                }
            });

            // Önizleyiciyi Kapat / Geri Dön
            $(document).off('click.cdCloseViewer').on('click.cdCloseViewer', '#btnBackToCountryDocs, #btnCloseCountryDocViewer', function () {
                closeCountryDocViewer();
            });

            // Belge Kartı veya "Belgeyi Aç" Tıklaması
            $(document).off('click.cdOpenDoc').on('click.cdOpenDoc', '.cd-doc-card, .btn-open-country-doc', function (e) {
                // Eğer doğrudan link (Yeni Sekme), izin talep veya iletişim butonuna tıklandıysa kart tıklamasını atla
                if ($(e.target).closest('a').length > 0) return;
                if ($(e.target).closest('.btn-request-country-access').length > 0) return;
                if ($(e.target).closest('.btn-show-admin-contact').length > 0) return;

                e.preventDefault();
                var card = $(this).closest('.cd-doc-card');
                var id = card.data('id');
                var title = card.data('title');
                var isConf = card.data('conf') === true || card.data('conf') === 'true';
                var hasAccess = card.data('hasaccess') === true || card.data('hasaccess') === 'true';

                // Eğer belge gizli ve kullanıcının erişim izni yoksa doğrudan talep modalını aç
                if (isConf && !hasAccess) {
                    openCountryDocAccessRequestModal(id, title);
                    return;
                }

                if (id) {
                    openCountryDocViewer(id, title, isConf);
                }
            });

            // "İzin Talep Et" Butonu Tıklaması
            $(document).off('click.cdReqAccess').on('click.cdReqAccess', '.btn-request-country-access', function (e) {
                e.stopPropagation();
                e.preventDefault();
                var id = $(this).data('id');
                var title = $(this).data('title');
                openCountryDocAccessRequestModal(id, title);
            });

            // "Yönetici İletişim Bilgisi" Butonu Tıklaması
            $(document).off('click.cdContactAdmin').on('click.cdContactAdmin', '.btn-show-admin-contact', function (e) {
                e.stopPropagation();
                e.preventDefault();
                showAdminContactAlert();
            });

            // Gizli Belge Erişim İzni Form Gönderimi (AJAX)
            $(document).off('submit.cdReqForm').on('submit.cdReqForm', '#formCountryDocRequestAccess', function (e) {
                e.preventDefault();
                var form = $(this);
                var btn = $('#btnSubmitCdRequest');
                btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin mr-1"></i> İletiliyor...');

                $.ajax({
                    url: '/Genelge/RequestAccess',
                    type: 'POST',
                    data: form.serialize(),
                    success: function (res) {
                        btn.prop('disabled', false).html('<i class="fas fa-paper-plane mr-1"></i> Onay Talebini Gönder');
                        if (res && res.success) {
                            alert(res.message || 'Erişim talebiniz yöneticilere iletildi. Onaylandığında belgeyi inceleyebilirsiniz.');
                            $('#modalCountryDocAccessRequest').modal('hide');
                            if (currentCountry) {
                                loadCountryData(currentCountry);
                            }
                        } else {
                            alert('Hata: ' + ((res && res.message) || 'Talep iletilemedi.'));
                        }
                    },
                    error: function () {
                        btn.prop('disabled', false).html('<i class="fas fa-paper-plane mr-1"></i> Onay Talebini Gönder');
                        alert('Sunucu hatası: Talep iletilirken bir bağlantı sorunu oluştu.');
                    }
                });
            });
        }
    }

    function showCountryModal() {
        var modalEl = getEl('countryDocumentsModal');
        if (!modalEl) return;
        if (typeof $ !== 'undefined' && $.fn && $.fn.modal) {
            $(modalEl).modal('show');
        } else {
            modalEl.classList.add('show');
            modalEl.style.display = 'block';
        }
    }

    window.openCountryDocsModalFromKase = function (country) {
        try {
            if (typeof $ !== 'undefined' && $.fn && $.fn.modal) {
                $('#kaseVizeModal').modal('hide');
            }
        } catch (e) { }

        setTimeout(function () {
            showCountryModal();
            if (country) {
                var sel = getEl('cdCountrySelect');
                if (sel) sel.value = country;
                loadCountryData(country);
            }
        }, 350);
    };

    function loadCountryData(country) {
        if (!country || !country.trim()) return;
        currentCountry = country.trim();

        var spinner = getEl('cdLoadingSpinner');
        var resArea = getEl('cdResultArea');
        if (spinner) spinner.style.display = 'block';
        if (resArea) resArea.style.display = 'none';

        var url = '/Genelge/GetCountryDocuments?country=' + encodeURIComponent(currentCountry) + '&t=' + new Date().getTime();
        fetch(url, { credentials: 'same-origin' })
            .then(function (res) { return res.json(); })
            .then(function (data) {
                if (spinner) spinner.style.display = 'none';
                if (resArea) resArea.style.display = 'block';

                if (!data || !data.success) {
                    alert(data && data.message ? data.message : 'Ülke verileri alınamadı.');
                    return;
                }

                renderCountryDetails(data);
            })
            .catch(function (err) {
                if (spinner) spinner.style.display = 'none';
                console.error(err);
                alert('Bağlantı hatası: Ülke verileri alınamadı.');
            });
    }

    function renderCountryDetails(data) {
        // Başlık ve Rozet
        var badgeEl = getEl('cdSelectedCountryBadge');
        var titleEl = getEl('cdCountryTitleText');
        if (badgeEl) badgeEl.innerText = data.country || 'ÜLKE';
        if (titleEl) titleEl.innerText = (data.country || '') + ' - Vize Rejimi ve Resmi Yazıları';

        // Rejim Özeti
        var regime = data.regime || {};
        var dayEl = getEl('cdRegimeDay');
        var statusEl = getEl('cdRegimeStatus');
        var harcEl = getEl('cdRegimeHarc');
        var specialEl = getEl('cdRegimeSpecial');
        var noticeCont = getEl('cdSpecialNoticeContainer');

        if (dayEl) dayEl.innerText = regime.day ? (regime.day + ' Gün') : 'Standart (90 Gün)';
        if (statusEl) {
            var st = 'Vize Muafiyeti';
            if (regime.visaStatus === 1) st = 'Vizeye Tabi';
            else if (regime.visaStatus === 3) st = 'Şartlı Vize / E-Vize';
            statusEl.innerText = st;
        }
        if (harcEl) {
            var isMuaf = (regime.harcByte === 0 || regime.harcText === 'Harçtan Muaf');
            harcEl.innerHTML = isMuaf
                ? '<span class="text-success"><i class="fas fa-check-circle mr-1"></i>Harçtan Muaf</span>'
                : '<span class="text-warning"><i class="fas fa-coins mr-1"></i>Harca Tabi (' + (data.dailyPrice || 10) + ' TL/gün)</span>';
        }

        // Özel Kolaylık / Kural
        var norm = (data.country || '').trim().toLowerCase();
        var specialText = 'Standart YUKK 7/1-b (P-60)';
        var noticeBadge = '';

        if (norm === 'almanya') {
            specialText = 'Süresi 1 Yıl Biten Pasaport/Kimlik Geçerli';
            noticeBadge = '<span class="badge badge-info px-2 py-1"><i class="fas fa-certificate mr-1"></i> 1 Yıl Süre Kolaylığı</span>';
        } else if (['belçika', 'belcika', 'fransa', 'ispanya', 'isviçre', 'isvicre', 'lüksemburg', 'luksemburg', 'portekiz'].indexOf(norm) !== -1) {
            specialText = 'Süresi 5 Yıl Biten Pasaport/Kimlik Geçerli';
            noticeBadge = '<span class="badge badge-info px-2 py-1"><i class="fas fa-certificate mr-1"></i> 5 Yıl Süre Kolaylığı</span>';
        } else if (norm === 'ukrayna') {
            specialText = 'Yeni Tip Çipli Kimlik Kartı ile Giriş';
            noticeBadge = '<span class="badge badge-success px-2 py-1"><i class="fas fa-id-card mr-1"></i> Kimlikle Seyahat</span>';
        } else if (norm === 'bulgaristan') {
            specialText = 'Kimlik Kartı ile Vizesiz Giriş (90 Gün)';
            noticeBadge = '<span class="badge badge-success px-2 py-1"><i class="fas fa-id-card mr-1"></i> Kimlikle Seyahat</span>';
        }

        if (specialEl) specialEl.innerText = specialText;
        if (noticeCont) noticeCont.innerHTML = noticeBadge;

        // Belgeler Listesi
        var docs = data.documents || [];
        var countBadge = getEl('cdDocCountBadge');
        if (countBadge) countBadge.innerText = docs.length;

        var emptyMsg = getEl('cdEmptyDocsMessage');
        var listWrapper = getEl('cdDocsListWrapper');
        var container = getEl('cdDocsListContainer');

        if (!docs || docs.length === 0) {
            if (emptyMsg) emptyMsg.style.display = 'block';
            if (listWrapper) listWrapper.style.display = 'none';
            if (container) container.innerHTML = '';
            return;
        }

        if (emptyMsg) emptyMsg.style.display = 'none';
        if (listWrapper) listWrapper.style.display = 'block';

        var cardsHtml = '';
        for (var i = 0; i < docs.length; i++) {
            var doc = docs[i];
            var iconClass = 'fa-file-pdf text-danger';
            if (doc.isOffice) iconClass = 'fa-file-word text-primary';
            else if (doc.isImage || doc.isTiff) iconClass = 'fa-file-image text-success';

            var isConf = doc.isConfidential === true;
            var hasAccess = doc.userHasAccess === true;
            var hasPending = doc.hasPendingRequest === true;

            var confBadge = '';
            var cardExtraClass = '';
            var actionButtons = '';

            if (isConf) {
                if (hasAccess) {
                    confBadge = '<span class="badge badge-warning text-dark font-weight-bold mr-1" style="font-size:0.75rem;"><i class="fas fa-unlock mr-1"></i>GİZLİ (İZİNLİ)</span>';
                } else {
                    confBadge = '<span class="badge badge-danger text-white font-weight-bold mr-1" style="font-size:0.75rem;"><i class="fas fa-lock mr-1"></i>GİZLİ</span>' +
                                '<span class="badge badge-secondary mr-1" style="font-size:0.72rem;"><i class="fas fa-user-lock mr-1"></i>Erişim Kısıtlı</span>';
                    cardExtraClass = ' is-confidential is-restricted';
                }
            } else {
                confBadge = '<span class="badge badge-light border text-muted mr-1" style="font-size:0.75rem;">AÇIK</span>';
            }

            // Aksiyon Butonları
            if (isConf && !hasAccess) {
                if (hasPending) {
                    actionButtons = '<button type="button" class="btn btn-warning btn-sm font-weight-bold" disabled title="Erişim izni talebiniz yönetici onayında beklemektedir">' +
                        '<i class="fas fa-hourglass-half mr-1"></i> Talep İnceleniyor' +
                        '</button>' +
                        '<button type="button" class="btn btn-outline-info btn-sm font-weight-bold btn-show-admin-contact ml-1" title="Yönetici İletişim Bilgileri">' +
                        '<i class="fas fa-phone-alt mr-1"></i> İletişim' +
                        '</button>';
                } else {
                    actionButtons = '<button type="button" class="btn btn-danger btn-sm font-weight-bold btn-request-country-access shadow-sm mr-1" data-id="' + escapeHtml(doc.id) + '" data-title="' + escapeHtml(doc.title) + '" title="Bu gizli belgeyi inceleyebilmek için yöneticiden izin talep edin">' +
                        '<i class="fas fa-key mr-1"></i> İzin Talep Et' +
                        '</button>' +
                        '<button type="button" class="btn btn-outline-info btn-sm font-weight-bold btn-show-admin-contact" title="Yönetici İletişim Bilgileri">' +
                        '<i class="fas fa-phone-alt mr-1"></i> İletişim' +
                        '</button>';
                }
            } else {
                var viewerUrl = '/Genelge/Viewer?path=' + encodeURIComponent(doc.id);
                actionButtons = '<button type="button" class="btn btn-primary btn-sm font-weight-bold btn-open-country-doc shadow-sm mr-2" data-id="' + escapeHtml(doc.id) + '" data-title="' + escapeHtml(doc.title) + '">' +
                    '<i class="fas fa-book-open mr-1"></i> Belgeyi Aç' +
                    '</button>' +
                    '<a href="' + viewerUrl + '" target="_blank" class="btn btn-outline-info btn-sm font-weight-bold" title="Belgeyi tam ekran ayrı sekmede aç">' +
                    '<i class="fas fa-external-link-alt mr-1"></i> Yeni Sekme' +
                    '</a>';
            }

            cardsHtml += '<div class="cd-doc-card' + cardExtraClass + '" data-id="' + escapeHtml(doc.id) + '" data-title="' + escapeHtml(doc.title) + '" data-conf="' + (isConf ? 'true' : 'false') + '" data-hasaccess="' + (hasAccess ? 'true' : 'false') + '" title="' + (isConf && !hasAccess ? 'Bu belge gizlidir; izin talep etmek için tıklayınız' : 'Belgeyi açmak için tıklayınız') + '">' +
                '<div class="d-flex align-items-center" style="min-width:0; flex:1;">' +
                    '<div class="cd-doc-icon mr-3"><i class="fas ' + iconClass + '"></i></div>' +
                    '<div class="text-truncate mr-2" style="flex:1;">' +
                        '<div class="cd-doc-title text-truncate">' + confBadge + escapeHtml(doc.title) + '</div>' +
                        '<div class="cd-doc-meta">' +
                            '<span class="badge badge-light border mr-2"><i class="fas fa-folder mr-1 text-primary"></i>' + escapeHtml(doc.folderTitle || 'Genelge') + '</span>' +
                            '<span class="mr-2 font-weight-semibold text-secondary"><i class="far fa-calendar-alt mr-1 text-info"></i>' + escapeHtml(doc.formattedDate) + '</span>' +
                            '<span><i class="fas fa-file mr-1"></i>' + escapeHtml(doc.formattedSize) + '</span>' +
                        '</div>' +
                    '</div>' +
                '</div>' +
                '<div class="cd-doc-actions">' + actionButtons + '</div>' +
            '</div>';
        }
        if (container) container.innerHTML = cardsHtml;
    }

    function openCountryDocAccessRequestModal(docId, docTitle) {
        var reqModal = getEl('modalCountryDocAccessRequest');
        if (!reqModal) return;

        $('#cdReqDocPath').val(docId || '');
        $('#cdReqDocTitle').val(docTitle || '');
        $('#cdDisplayReqDocTitle').val(docTitle || 'Resmi Belge');
        $('#cdReqReason').val('');

        if (typeof $ !== 'undefined' && $.fn && $.fn.modal) {
            $(reqModal).modal({ backdrop: 'static', keyboard: true }).modal('show');
        } else {
            reqModal.classList.add('show');
            reqModal.style.display = 'block';
        }
    }

    function showAdminContactAlert() {
        var msg = "🛡️ EGM MEVZUAT GİZLİ BELGE YÖNETİMİ & İLETİŞİM REHBERİ\n\n" +
            "1. İzin Talebi Süreci:\n" +
            "   'İzin Talep Et' butonuna tıklayarak görev gerekçenizi (nöbet, yolcu vize incelemesi vb.) ilettiğinizde, talebiniz sistem üzerinden Grup Amiri ve Şube Yönetimi ekranına anlık bildirim olarak düşer.\n\n" +
            "2. Onaylandığında:\n" +
            "   Yönetici onayladığı anda belge hesabınıza açılır ve hem portal üzerinden hem de ayrı pencerede tam sayfa inceleyebilirsiniz.\n\n" +
            "3. İvedi Hudut Kapısı Operasyonları:\n" +
            "   Yolcu başında acil teyit ve karar gerektiren durumlarda lütfen Nöbetçi Amir / Büro Yönetimi ile doğrudan dahili hat veya telsiz üzerinden irtibata geçiniz.";
        alert(msg);
    }

    window.openCountryDocViewer = function (docId, title, isConfidential) {
        var modalV = getEl('modalCountryDocViewer');
        var iframe = getEl('countryDocViewerIframe');
        var titleEl = getEl('modalCountryDocViewerLabel');
        var badgeEl = getEl('countryDocViewerBadge');
        var popoutBtn = getEl('btnPopoutCountryDoc');

        if (titleEl) titleEl.innerText = title || 'Resmi Belge';
        if (badgeEl) {
            badgeEl.style.display = isConfidential ? 'inline-block' : 'none';
        }

        var vUrl = '/Genelge/Viewer?path=' + encodeURIComponent(docId);
        if (popoutBtn) popoutBtn.href = vUrl;

        if (iframe) {
            iframe.src = vUrl;
        }

        if (typeof $ !== 'undefined' && $.fn && $.fn.modal) {
            $(modalV).modal({ backdrop: 'static', keyboard: true }).modal('show');
        } else if (modalV) {
            modalV.classList.add('show');
            modalV.style.display = 'block';
        }
    };

    window.closeCountryDocViewer = function () {
        var modalV = getEl('modalCountryDocViewer');
        var iframe = getEl('countryDocViewerIframe');
        if (typeof $ !== 'undefined' && $.fn && $.fn.modal) {
            $(modalV).modal('hide');
        } else if (modalV) {
            modalV.classList.remove('show');
            modalV.style.display = 'none';
        }
        if (iframe) {
            iframe.src = 'about:blank';
        }
    };

    // Global Dışa Aktarımlar
    window.showCountryModal = showCountryModal;
    window.loadCountryData = loadCountryData;
    window.openCountryDocAccessRequestModal = openCountryDocAccessRequestModal;
    window.showAdminContactAlert = showAdminContactAlert;

    // Sayfa Yüklendiğinde Otomatik Başlatma
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initCountryDocuments);
    } else {
        initCountryDocuments();
    }
    if (typeof $ !== 'undefined') {
        $(document).ready(initCountryDocuments);
    }
})();
