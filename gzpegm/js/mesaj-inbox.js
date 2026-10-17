/* ==========================================================================
   Mesaj Gelen Kutusu JavaScript (mesaj-inbox.js)
   ========================================================================== */

$(document).ready(function () {
    var cfg = document.getElementById('mesaj-inbox-config');
    var detailsBaseUrl = (cfg && cfg.getAttribute('data-url-details')) || '/Mesaj/Details';
    var markReadBaseUrl = (cfg && cfg.getAttribute('data-url-mark-read')) || '/Mesaj/MarkAsRead';

    $('.message-row').on('click', function () {
        var id = $(this).data('message-id') || $(this).data('id');
        var token = $('input[name="__RequestVerificationToken"]').val();
        if (!id) return;

        if ($(this).hasClass('message-read')) {
            window.location = detailsBaseUrl + '/' + id;
            return;
        }

        $.ajax({
            url: markReadBaseUrl + '/' + id,
            type: 'POST',
            data: { __RequestVerificationToken: token },
            success: function () {
                window.location = detailsBaseUrl + '/' + id;
            },
            error: function () {
                window.location = detailsBaseUrl + '/' + id;
            }
        });
    });
});

function deleteMessage(messageId) {
    if (!confirm('Bu mesajı silmek istediğinizden emin misiniz?')) {
        return;
    }

    var cfg = document.getElementById('mesaj-inbox-config');
    var deleteBaseUrl = (cfg && cfg.getAttribute('data-url-delete')) || '/Mesaj/Delete';

    $.ajax({
        url: deleteBaseUrl + '/' + messageId,
        type: 'POST',
        data: {
            __RequestVerificationToken: $('input[name="__RequestVerificationToken"]').val()
        },
        success: function (result) {
            if (result.success) {
                location.reload();
            } else {
                alert(result.message || 'Mesaj silinemedi.');
            }
        },
        error: function () {
            alert('Bir hata oluştu.');
        }
    });
}
