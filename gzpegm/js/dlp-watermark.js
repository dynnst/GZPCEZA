/**
 * CEZAM Data Loss Prevention (DLP) & Watermark Security Engine
 * EGM Havalimanı Şube Müdürlüğü - Mevzuat & Eğitim Koruma Sistemi
 */
(function () {
    'use strict';

    function initDLP() {
        var scriptTag = document.getElementById('cezamDlpScript');
        var sicil = (scriptTag && scriptTag.getAttribute('data-sicil')) || '313258';
        var ip = (scriptTag && scriptTag.getAttribute('data-ip')) || '10.7.202.75';
        var name = (scriptTag && scriptTag.getAttribute('data-name')) || 'Personel';

        var now = new Date();
        var dateStr = now.toLocaleDateString('tr-TR') + ' ' + now.toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' });
        var watermarkText = 'T.C. EGM • SİCİL: ' + sicil + ' • IP: ' + ip + ' • ' + dateStr;

        // 1. Dinamik Filigran Katmanını Oluştur
        createWatermarkOverlay(watermarkText);

        // 2. Kopyalama, Sağ Tık ve İndirme Kısıtlamalarını Etkinleştir
        document.body.classList.add('dlp-active');
        document.body.classList.add('dlp-protected');

        // Sağ Tıklamayı Engelle
        document.addEventListener('contextmenu', function (e) {
            e.preventDefault();
            return false;
        }, true);

        // Metin Seçimini Engelle
        document.addEventListener('selectstart', function (e) {
            if (e.target.tagName !== 'INPUT' && e.target.tagName !== 'TEXTAREA') {
                e.preventDefault();
                return false;
            }
        }, true);

        // Görsel ve Dosya Sürüklemeyi Engelle
        document.addEventListener('dragstart', function (e) {
            e.preventDefault();
            return false;
        }, true);

        // Kısayol Tuşlarını Engelle (Ctrl+P, Ctrl+S, Ctrl+C, Ctrl+U, F12, PrintScreen)
        document.addEventListener('keydown', function (e) {
            var ctrlOrCmd = e.ctrlKey || e.metaKey;
            var key = e.key ? e.key.toLowerCase() : '';

            // F12 veya Ctrl+Shift+I / J
            if (e.keyCode === 123 || (ctrlOrCmd && e.shiftKey && (key === 'i' || key === 'j' || key === 'c'))) {
                e.preventDefault();
                return false;
            }

            // Ctrl+P (Yazdır), Ctrl+S (Kaydet), Ctrl+C (Kopyala), Ctrl+U (Kaynak Görüntüle)
            if (ctrlOrCmd && (key === 'p' || key === 's' || key === 'c' || key === 'u')) {
                e.preventDefault();
                return false;
            }

            // PrintScreen Tuşu
            if (e.keyCode === 44 || key === 'printscreen') {
                triggerScreenBlur();
            }
        }, true);

        // Pencere Odağı Kaybedildiğinde (Ekran Alıntısı / Win+Shift+S) Bulanıklaştır
        window.addEventListener('blur', function () {
            document.body.classList.add('dlp-screen-blur');
        });

        window.addEventListener('focus', function () {
            document.body.classList.remove('dlp-screen-blur');
        });
    }

    function createWatermarkOverlay(text) {
        if (document.getElementById('cezamGlobalWatermarkLayer')) return;

        // Yüksek çözünürlüklü SVG filigran motifi
        var svgWidth = 460;
        var svgHeight = 240;
        var svg = '<svg xmlns="http://www.w3.org/2000/svg" width="' + svgWidth + '" height="' + svgHeight + '">' +
            '<text x="50%" y="50%" fill="#dc2626" font-family="-apple-system, BlinkMacSystemFont, Segoe UI, Roboto, sans-serif" ' +
            'font-weight="bold" font-size="14" text-anchor="middle" ' +
            'transform="rotate(-28 ' + (svgWidth / 2) + ' ' + (svgHeight / 2) + ')">' +
            escapeXml(text) +
            '</text>' +
            '</svg>';

        var encodedSvg = 'data:image/svg+xml;utf8,' + encodeURIComponent(svg);

        var layer = document.createElement('div');
        layer.id = 'cezamGlobalWatermarkLayer';
        layer.style.backgroundImage = 'url("' + encodedSvg + '")';
        document.body.appendChild(layer);
    }

    function triggerScreenBlur() {
        document.body.classList.add('dlp-screen-blur');
        setTimeout(function () {
            document.body.classList.remove('dlp-screen-blur');
        }, 1500);
    }

    function escapeXml(unsafe) {
        return unsafe.replace(/[<>&'"]/g, function (c) {
            switch (c) {
                case '<': return '&lt;';
                case '>': return '&gt;';
                case '&': return '&amp;';
                case '\'': return '&apos;';
                case '"': return '&quot;';
            }
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initDLP);
    } else {
        initDLP();
    }
})();
