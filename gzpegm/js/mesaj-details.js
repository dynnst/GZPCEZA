/* ==========================================================================
   Mesaj Detay JavaScript (mesaj-details.js)
   ========================================================================== */

function deleteMessage(messageId) {
    if (!confirm('Bu mesajı silmek istediğinizden emin misiniz?')) {
        return;
    }

    var cfg = document.getElementById('mesaj-details-config');
    var deleteBaseUrl = (cfg && cfg.getAttribute('data-url-delete')) || '/Mesaj/Delete';
    var inboxUrl = (cfg && cfg.getAttribute('data-url-inbox')) || '/Mesaj/Inbox';

    $.ajax({
        url: deleteBaseUrl + '/' + messageId,
        type: 'POST',
        data: {
            __RequestVerificationToken: $('input[name="__RequestVerificationToken"]').val()
        },
        success: function (result) {
            if (result.success) {
                window.location = inboxUrl;
            } else {
                alert(result.message || 'Mesaj silinemedi.');
            }
        },
        error: function () {
            alert('Bir hata oluştu.');
        }
    });
}
