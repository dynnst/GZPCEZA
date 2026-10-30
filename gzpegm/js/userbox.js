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

    function initSubmenus() {
        if (!window.jQuery) return;

        // Hover handling for submenus with 400ms grace period.
        // NOTE: .faydali-linkler is excluded from hover-open so passing over it while moving down never triggers it!
        $(document).off('mouseenter.userboxSubmenu', '.userbox-header .dropdown-submenu:not(.faydali-linkler)')
                   .on('mouseenter.userboxSubmenu', '.userbox-header .dropdown-submenu:not(.faydali-linkler)', function () {
            var $this = $(this);
            var timer = $this.data('submenuTimer');
            if (timer) {
                clearTimeout(timer);
                $this.removeData('submenuTimer');
            }
            $this.siblings('.dropdown-submenu').each(function () {
                var st = $(this).data('submenuTimer');
                if (st) clearTimeout(st);
                $(this).removeData('submenuTimer');
                $(this).removeClass('show open is-active');
            });
            $this.addClass('show open is-active');
        });

        $(document).off('mouseleave.userboxSubmenu', '.userbox-header .dropdown-submenu:not(.faydali-linkler)')
                   .on('mouseleave.userboxSubmenu', '.userbox-header .dropdown-submenu:not(.faydali-linkler)', function () {
            var $this = $(this);
            var timer = setTimeout(function () {
                $this.removeClass('show open is-active');
                $this.removeData('submenuTimer');
            }, 400);
            $this.data('submenuTimer', timer);
        });

        // Submenu click / tap handler (for pinning open or mobile toggle)
        $(document).off('click.userboxSubmenu', '.userbox-header .dropdown-submenu > a')
                   .on('click.userboxSubmenu', '.userbox-header .dropdown-submenu > a', function (e) {
            e.preventDefault();
            e.stopPropagation();
            var $parent = $(this).parent('.dropdown-submenu');
            var wasOpen = $parent.hasClass('show') || $parent.hasClass('open') || $parent.hasClass('is-active');
            $parent.siblings('.dropdown-submenu').each(function () {
                var st = $(this).data('submenuTimer');
                if (st) clearTimeout(st);
                $(this).removeData('submenuTimer');
                $(this).removeClass('show open is-active');
            });
            if (wasOpen) {
                $parent.removeClass('show open is-active');
            } else {
                $parent.addClass('show open is-active');
            }
        });

        // Ensure clicking links inside submenu proceeds with navigation
        $(document).off('click.userboxSubmenuLink', '.userbox-header .dropdown-submenu > .dropdown-menu a')
                   .on('click.userboxSubmenuLink', '.userbox-header .dropdown-submenu > .dropdown-menu a', function (e) {
            var href = $(this).attr('href');
            if (href && href !== '#' && href.indexOf('javascript:') !== 0) {
                return true;
            }
        });

        // Prevent accidental closing when clicking whitespace inside submenu
        $(document).off('click.userboxSubmenuMenu', '.userbox-header .dropdown-submenu > .dropdown-menu')
                   .on('click.userboxSubmenuMenu', '.userbox-header .dropdown-submenu > .dropdown-menu', function (e) {
            e.stopPropagation();
        });

        // Reset submenus when main navbar dropdown closes
        $(document).off('hidden.bs.dropdown.userbox', '.userbox-header #mainNav > li.dropdown')
                   .on('hidden.bs.dropdown.userbox', '.userbox-header #mainNav > li.dropdown', function () {
            $(this).find('.dropdown-submenu').each(function () {
                var t = $(this).data('submenuTimer');
                if (t) clearTimeout(t);
                $(this).removeData('submenuTimer');
                $(this).removeClass('show open is-active');
            });
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function () {
            updateUnreadCount();
            initSubmenus();
            window.setInterval(updateUnreadCount, 30000);
        });
    } else {
        updateUnreadCount();
        initSubmenus();
        window.setInterval(updateUnreadCount, 30000);
    }
})();
