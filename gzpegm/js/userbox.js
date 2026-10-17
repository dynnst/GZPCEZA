/* ==========================================================================
   UserBox Header Widget JavaScript (userbox.js)
   ========================================================================== */

(function () {
    function updateUnreadCount() {
        if (!window.jQuery || !document.getElementById('unreadBadge')) {
            return;
        }

        var cfg = document.getElementById('userbox-config');
        var unreadUrl = (cfg && cfg.getAttribute('data-unread-url')) ? cfg.getAttribute('data-unread-url') : '/Mesaj/GetUnreadCount';

        $.ajax({
            url: unreadUrl,
            type: 'GET',
            dataType: 'json',
            success: function (data) {
                var count = data && data.count !== undefined ? parseInt(data.count, 10) : 0;
                if (count > 0) {
                    $('#unreadBadge').text(count).show();
                    $('#unreadBadgeInbox').text(count).show();
                } else {
                    $('#unreadBadge').hide();
                    $('#unreadBadgeInbox').hide();
                }
            },
            error: function () {
                $('#unreadBadge').hide();
                $('#unreadBadgeInbox').hide();
            }
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function () {
            updateUnreadCount();
            window.setInterval(updateUnreadCount, 30000);
        });
    } else {
        updateUnreadCount();
        window.setInterval(updateUnreadCount, 30000);
    }
})();
