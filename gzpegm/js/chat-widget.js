// Sohbet Sistemi İptal Edilmiştir (2024)
// Chat widget disabled - use MesajController instead
console.log('Chat widget disabled');

        var value = 0;
        try {
            value = Number(window.sessionStorage.getItem(storageKey) || 0);
        } catch (e) {
            value = 0;
        }
        return isNaN(value) || value < 0 ? 0 : value;
    }

    function setClearedAfterId(value) {
        try {
            window.sessionStorage.setItem(storageKey, String(value || 0));
        } catch (e) { }
    }

    function clearChatWindow(message) {
        $('#cezamChatMessages').html('<div class="cezam-chat-empty">' + esc(message || 'Sohbet penceresi temizlendi. Yeni mesajlar burada görünecek.') + '</div>');
        $('#cezamChatText').val('');
        $('#cezamChatImage').val('');
        $('#cezamChatSelectedFile').text('');
        state.firstLoadDone = false;
    }

    function closeAndClearChat() {
        var clearPoint = Math.max(state.lastMessageId || 0, getClearedAfterId());
        setClearedAfterId(clearPoint);
        state.lastMessageId = clearPoint;
        state.open = false;
        $('#cezamChatPanel').removeClass('is-open');
        clearChatWindow('Sohbet kapatıldı ve pencere içeriği temizlendi. Veritabanındaki geçmiş silinmedi.');
    }

    function post(url, data, done) {
        data = data || {};
        data.__RequestVerificationToken = token();
        $.post(url, data).done(done).fail(function () { });
    }

    function heartbeat() {
        post(cfg.heartbeatUrl, { page: window.location.pathname + window.location.search }, function () { });
    }

    function loadMe() {
        $.getJSON(cfg.meUrl).done(function (res) {
            if (!res || !res.success) {
                $('#cezamChatLauncher,#cezamChatPanel').remove();
                return;
            }

            state.me = res.user;
            state.lastMessageId = Math.max(state.lastMessageId, getClearedAfterId());

            if (state.me && state.me.isAdmin) {
                $('#cezamChatAdminLink').show();
            }

            heartbeat();
            loadUsers();
            loadMessages(false);

            setInterval(heartbeat, 30000);
            setInterval(loadUsers, 10000);
            setInterval(function () {
                loadMessages(true);
            }, 5000);
        });
    }

    function loadUsers() {
        $.getJSON(cfg.onlineUsersUrl).done(function (res) {
            if (!res || !res.success) return;

            var users = res.users || [];
            var html = [];

            html.push('<div class="cezam-chat-room-card active">' +
                '<span class="cezam-chat-room-title">Ortak Sohbet</span>' +
                '<span class="cezam-chat-room-meta">Herkese açık mesaj havuzu</span>' +
                '</div>');

            html.push('<div class="cezam-chat-online-title">Çevrimiçi (' + users.length + ')</div>');

            if (!users.length) {
                html.push('<div class="cezam-chat-empty compact">Şu an çevrimiçi kullanıcı görünmüyor.</div>');
            } else {
                $.each(users, function (_, u) {
                    html.push(
                        '<div class="cezam-chat-online-user">' +
                        '<span class="dot"></span>' +
                        '<span>' + esc(u.name) + '</span>' +
                        '</div>'
                    );
                });
            }

            $('#cezamChatUsers').html(html.join(''));
        });
    }

    function loadMessages(appendOnly) {
        var clearedAfterId = getClearedAfterId();
        var requestAfterId = appendOnly ? Math.max(state.lastMessageId, clearedAfterId) : clearedAfterId;

        $.getJSON(cfg.messagesUrl, { afterId: requestAfterId }).done(function (res) {
            if (!res || !res.success) return;

            var messages = res.messages || [];
            if (!appendOnly) {
                $('#cezamChatMessages').empty();
                state.lastMessageId = requestAfterId;
            }

            if (!messages.length && !appendOnly) {
                var emptyMessage = clearedAfterId > 0
                    ? 'Sohbet penceresi temizlendi. Yeni mesajlar burada görünecek.'
                    : 'Henüz ortak sohbet mesajı yok. İlk mesajı siz yazın.';
                $('#cezamChatMessages').html('<div class="cezam-chat-empty">' + esc(emptyMessage) + '</div>');
                state.firstLoadDone = true;
                return;
            }

            var html = [];
            $.each(messages, function (_, m) {
                state.lastMessageId = Math.max(state.lastMessageId, m.id);
                html.push(
                    '<div class="cezam-chat-msg ' + (m.mine ? 'mine' : '') + '">' +
                    '<div class="cezam-chat-msg-sender">' + esc(m.sender || '') + '</div>' +
                    (m.text ? '<div>' + formatMessageText(m.text) + '</div>' : '') +
                    (m.image ? '<a href="' + esc(m.image) + '" target="_blank"><img src="' + esc(m.image) + '" alt="chat resmi" /></a>' : '') +
                    '<div class="cezam-chat-msg-time">' + esc(m.time) + '</div>' +
                    '</div>'
                );
            });

            if (html.length) {
                if (!appendOnly) $('#cezamChatMessages').empty();
                $('#cezamChatMessages').append(html.join(''));
                var box = document.getElementById('cezamChatMessages');
                if (box && (state.open || !state.firstLoadDone)) box.scrollTop = box.scrollHeight;
            }

            state.firstLoadDone = true;
        });
    }

    function sendMessage() {
        var text = $('#cezamChatText').val();
        var fileInput = document.getElementById('cezamChatImage');
        var file = fileInput && fileInput.files && fileInput.files.length ? fileInput.files[0] : null;
        if ((!text || !text.trim()) && !file) return;

        var form = new FormData();
        form.append('__RequestVerificationToken', token());
        form.append('text', text || '');
        if (file) form.append('image', file);

        $.ajax({
            url: cfg.sendUrl,
            type: 'POST',
            data: form,
            processData: false,
            contentType: false
        }).done(function (res) {
            if (!res || !res.success) {
                alert((res && res.message) || 'Mesaj gönderilemedi.');
                return;
            }
            $('#cezamChatText').val('');
            $('#cezamChatImage').val('');
            $('#cezamChatSelectedFile').text('');
            loadMessages(true);
        }).fail(function () {
            alert('Mesaj gönderilemedi.');
        });
    }

    function bind() {
        $('#cezamChatLauncher').on('click', function () {
            if (state.open) {
                closeAndClearChat();
                return;
            }

            state.open = true;
            $('#cezamChatPanel').addClass('is-open');
            heartbeat();
            loadUsers();
            loadMessages(false);
        });

        $('#cezamChatClose,#cezamChatClearClose').on('click', closeAndClearChat);

        $(document).on('click', 'a[href*="/Cikis"],a[href*="/Giris/Logout"],a[href*="/Logout"]', function () {
            setClearedAfterId(Math.max(state.lastMessageId || 0, getClearedAfterId()));
        });

        $('#cezamChatSend').on('click', sendMessage);
        $('#cezamChatText').on('keydown', function (e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendMessage();
            }
        });

        $('#cezamChatImage').on('change', function () {
            var file = this.files && this.files.length ? this.files[0] : null;
            $('#cezamChatSelectedFile').text(file ? file.name : '');
        });
    }

    $(function () {
        if (!$('#cezamChatLauncher').length) return;
        bind();
        loadMe();
    });
})(jQuery, window, document);
