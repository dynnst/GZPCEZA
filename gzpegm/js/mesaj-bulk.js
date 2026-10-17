/* ==========================================================================
   Toplu Mesaj JavaScript (mesaj-bulk.js)
   ========================================================================== */

$(document).ready(function () {
    var cfg = document.getElementById('mesaj-bulk-config');
    var getRecipientsUrl = (cfg && cfg.getAttribute('data-url-recipients')) || '/Mesaj/GetRecipients';
    var sendToRecipientUrl = (cfg && cfg.getAttribute('data-url-send')) || '/Mesaj/SendToRecipient';

    // Character counter for subject
    $('#subjectInput').on('input', function () {
        var length = $(this).val().length;
        var counter = $('#subjectCounter');
        counter.text(length + ' / 200');

        if (length > 180) {
            counter.addClass('danger').removeClass('warning');
        } else if (length > 150) {
            counter.addClass('warning').removeClass('danger');
        } else {
            counter.removeClass('warning danger');
        }
    });

    // Character counter for message
    $('#messageInput').on('input', function () {
        var length = $(this).val().length;
        var counter = $('#messageCounter');
        counter.text(length + ' / 4000');

        if (length > 3800) {
            counter.addClass('danger').removeClass('warning');
        } else if (length > 3500) {
            counter.addClass('warning').removeClass('danger');
        } else {
            counter.removeClass('warning danger');
        }
    });

    // Initialize counters
    $('#subjectInput').trigger('input');
    $('#messageInput').trigger('input');

    // Prevent normal submit; use AJAX bulk flow
    $('#bulkForm').on('submit', function (e) {
        e.preventDefault();

        if (!confirm('Tüm kullanıcılara mesaj göndermek istediğinizden emin misiniz?')) {
            return;
        }

        var subject = $('#subjectInput').val().trim();
        var content = $('#messageInput').val().trim();

        if (!subject || subject.length > 200) {
            alert('Geçersiz konu.');
            return;
        }
        if (!content || content.length > 4000) {
            alert('Geçersiz mesaj içeriği.');
            return;
        }

        startBulkSend(subject, content);
    });

    function startBulkSend(subject, content) {
        // Show modal and reset counters
        $('#bulkProgressModal').modal({ backdrop: 'static', keyboard: false });
        $('#totalCount').text('0');
        $('#successCount').text('0');
        $('#failCount').text('0');
        $('#bulkProgressBar').css('width', '0%').attr('aria-valuenow', 0);
        $('#progressStatus').text('Alıcılar alınıyor...');
        $('#currentRecipient').text('');
        $('#closeBulkBtn').hide();

        // Fetch recipients
        $.get(getRecipientsUrl, function (data) {
            if (!data || !data.success || !data.recipients) {
                $('#progressStatus').text('Alıcılar alınamadı.');
                $('#closeBulkBtn').show();
                return;
            }

            var recipients = data.recipients;
            var total = recipients.length;
            $('#totalCount').text(total);

            if (total === 0) {
                $('#progressStatus').text('Gönderilecek alıcı bulunamadı.');
                $('#closeBulkBtn').show();
                return;
            }

            var token = $('input[name="__RequestVerificationToken"]').val();
            var successCount = 0;
            var failCount = 0;
            var index = 0;

            $('#progressStatus').text('Gönderim başlatılıyor...');

            function sendNext() {
                if (index >= total) {
                    $('#progressStatus').text('Gönderim tamamlandı.');
                    $('#closeBulkBtn').show();
                    $('#cancelBulkBtn').hide();
                    return;
                }

                var recipient = recipients[index];
                $('#currentRecipient').text(recipient.Name + ' (' + recipient.Role + ')');

                $.ajax({
                    url: sendToRecipientUrl,
                    type: 'POST',
                    data: {
                        __RequestVerificationToken: token,
                        recipientId: recipient.UserId,
                        subject: subject,
                        content: content
                    },
                    success: function (resp) {
                        if (resp && resp.success) {
                            successCount++;
                            $('#successCount').text(successCount);
                        } else {
                            failCount++;
                            $('#failCount').text(failCount);
                        }
                    },
                    error: function () {
                        failCount++;
                        $('#failCount').text(failCount);
                    },
                    complete: function () {
                        index++;
                        var percent = Math.round((index / total) * 100);
                        $('#bulkProgressBar').css('width', percent + '%').attr('aria-valuenow', percent);
                        $('#progressStatus').text('Gönderiliyor... ' + percent + '%');
                        setTimeout(sendNext, 50);
                    }
                });
            }

            sendNext();
        }).fail(function () {
            $('#progressStatus').text('Alıcılar alınamadı (istek hatası).');
            $('#closeBulkBtn').show();
        });
    }
});
