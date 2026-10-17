/* ==========================================================================
   Mesaj Olusturma JavaScript (mesaj-compose.js)
   ========================================================================== */

$(document).ready(function () {
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
});
