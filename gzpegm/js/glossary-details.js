// Glossary Details Page JavaScript
// Kullanıcı bilgileri view sayfasından gelecek: watermarkUserName, watermarkUserSurname, watermarkUserSicil

// Watermark cache için
let watermarkCache = null;

// Watermark SVG şablonu oluştur
function createWatermarkSVG() {
    const patternId = 'pattern-' + Math.random().toString(36).substr(2, 9);

    return `
        <svg class="watermark-svg" preserveAspectRatio="none" viewBox="0 0 1000 1000">
            <defs>
                <pattern id="${patternId}" patternUnits="userSpaceOnUse" width="200" height="200" patternTransform="rotate(-45)">
                    <text x="0" y="30" font-family="'Segoe UI', Arial, sans-serif" font-size="30" font-weight="700" fill="white" opacity="0.8">
                        ${watermarkUserName} ${watermarkUserSurname} (${watermarkUserSicil})
                    </text>
                </pattern>
            </defs>
            <rect width="1000" height="1000" fill="url(#${patternId})" />
        </svg>
    `;
}

// Cache'li watermark SVG al
function getCachedWatermarkSVG() {
    if (!watermarkCache) {
        watermarkCache = createWatermarkSVG();
    }
    return watermarkCache;
}

// Modal açma fonksiyonu - Watermark ile
function openImageModal(imageSrc, imageTitle) {
    const overlay = document.getElementById('imageModalOverlay');
    const modalImg = document.getElementById('modalImage');
    const modalInfo = document.getElementById('modalImageInfo');
    const watermarkLayer = document.getElementById('modalWatermarkLayer');

    modalImg.src = imageSrc;
    modalImg.alt = imageTitle;
    modalInfo.textContent = imageTitle;

    // Watermark SVG ekle
    watermarkLayer.innerHTML = getCachedWatermarkSVG();

    overlay.classList.add('active');
    document.body.style.overflow = 'hidden';
}

// Modal kapatma fonksiyonu
function closeImageModal() {
    const overlay = document.getElementById('imageModalOverlay');
    overlay.classList.remove('active');
    document.body.style.overflow = 'auto';
}

// Tek bir resme watermark ekle
function addWatermarkToImage(img) {
    if (img.parentElement && img.parentElement.classList.contains('summernote-image-wrapper')) {
        return;
    }

    var wrapper = document.createElement('div');
    wrapper.className = 'summernote-image-wrapper';

    img.parentNode.insertBefore(wrapper, img);
    wrapper.appendChild(img);

    var watermarkDiv = document.createElement('div');
    watermarkDiv.className = 'summernote-watermark';
    watermarkDiv.innerHTML = getCachedWatermarkSVG();
    wrapper.appendChild(watermarkDiv);

    img.ondragstart = function() { return false; };
    img.oncontextmenu = function() { return false; };
    img.draggable = false;
    img.loading = "lazy";

    // Resim tıklanması için event ekle - Modal watermark ile açılacak
    wrapper.addEventListener('click', function() {
        const termTitle = img.alt || document.querySelector('.glossary-detail-header h1')?.textContent || 'Resim';
        openImageModal(img.src, termTitle);
    });
}

// Summernote ve diğer HTML resimlere watermark ekle
function addWatermarkToImages() {
    // Sayfadaki tüm img etiketlerine (modal içindeki hariç) uygula
    var images = document.querySelectorAll('img:not(#modalImage):not(.watermark-added)');
    images.forEach(function (img) {
        img.classList.add('watermark-added');
        addWatermarkToImage(img);
    });
}

// Basit Intersection Observer
function initImageObserver() {
    // Görünen tüm img etiketleri (modal hariç)
    var images = document.querySelectorAll('img:not(#modalImage):not(.watermark-added)');
    images.forEach(function(img) {
        var rect = img.getBoundingClientRect();
        var isVisible = (
            rect.top >= 0 &&
            rect.left >= 0 &&
            rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
            rect.right <= (window.innerWidth || document.documentElement.clientWidth)
        );

        if (isVisible) {
            img.classList.add('watermark-added');
            addWatermarkToImage(img);
        }
    });
}

// Scroll handler
function handleScroll() {
    initImageObserver();
}

// Toast bildirimi
function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'warning' ? '#fef3c7' : '#dbeafe'};
        color: ${type === 'warning' ? '#92400e' : '#1e40af'};
        padding: 12px 20px;
        border-radius: 6px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        z-index: 9999;
        font-weight: 500;
        border-left: 4px solid ${type === 'warning' ? '#f59e0b' : '#3b82f6'};
        animation: slideIn 0.3s ease;
    `;

    toast.textContent = message;
    document.body.appendChild(toast);

    setTimeout(function() {
        toast.style.animation = 'slideOut 0.3s ease';
        setTimeout(function() {
            if (toast.parentNode) {
                document.body.removeChild(toast);
            }
        }, 300);
    }, 3000);
}

// Kopyalama işlevi
function copyToClipboard(text) {
    if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(text).then(function () {
            showToast('Terim kopyalandı: ' + text, 'info');
        }, function (err) {
            fallbackCopyTextToClipboard(text);
        });
    } else {
        fallbackCopyTextToClipboard(text);
    }
}

// Fallback kopyalama
function fallbackCopyTextToClipboard(text) {
    var textArea = document.createElement("textarea");
    textArea.value = text;

    textArea.style.position = "fixed";
    textArea.style.left = "-999999px";
    textArea.style.top = "-999999px";
    document.body.appendChild(textArea);

    textArea.focus();
    textArea.select();

    try {
        var successful = document.execCommand('copy');
        if (successful) {
            showToast('Terim kopyalandı: ' + text, 'info');
        } else {
            showToast('Kopyalama başarısız. Lütfen terimi seçip Ctrl+C ile kopyalayın.', 'warning');
        }
    } catch (err) {
        showToast('Tarayıcı kopyalamayı desteklemiyor', 'warning');
    }

    document.body.removeChild(textArea);
}

// Sayfa yüklendiğinde başlat
document.addEventListener('DOMContentLoaded', function() {
    // Overlay'e tıklayınca kapat
    const overlay = document.getElementById('imageModalOverlay');
    if (overlay) {
        overlay.addEventListener('click', function(e) {
            if (e.target === overlay) {
                closeImageModal();
            }
        });
    }

    // ESC tuşu ile kapat
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeImageModal();
        }
    });

    // Ana resmi işaretle
    const mainImage = document.querySelector('.definition-image img');
    if (mainImage) {
        mainImage.classList.add('watermark-added');
    }

    // Resimlere watermark ekle
    addWatermarkToImages();
    window.addEventListener('scroll', handleScroll);

    setTimeout(initImageObserver, 500);

    // Dinamik içerik yüklenirse
    var observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
            if (mutation.addedNodes.length) {
                setTimeout(function() {
                    addWatermarkToImages();
                    initImageObserver();
                }, 100);
            }
        });
    });

    const mainContent = document.querySelector('.glossary-detail-main');
    if (mainContent) {
        observer.observe(mainContent, {
            childList: true,
            subtree: true
        });
    }

    // Resim koruma
    document.addEventListener('contextmenu', function (e) {
        if (e.target.tagName === 'IMG') {
            e.preventDefault();
            e.stopPropagation();
            showToast('Resimler korunmaktadır ve indirilemez.', 'warning');
            return false;
        }
    }, true);

    document.addEventListener('dragstart', function (e) {
        if (e.target.tagName === 'IMG') {
            e.preventDefault();
            e.stopPropagation();
            return false;
        }
    }, true);

    document.addEventListener('keydown', function (e) {
        if ((e.ctrlKey || e.metaKey) && e.key === 's') {
            var activeElement = document.activeElement;
            if (activeElement && activeElement.tagName === 'IMG') {
                e.preventDefault();
                showToast('Resimler indirilemez.', 'warning');
                return false;
            }
        }

        if (e.key === 'PrintScreen') {
            e.preventDefault();
            showToast('Ekran görüntüsü alınamaz.', 'warning');
            return false;
        }
    });

    document.addEventListener('mousedown', function (e) {
        if (e.button === 2 && e.target.tagName === 'IMG') {
            e.preventDefault();
            e.stopPropagation();
            return false;
        }
    }, true);
});

