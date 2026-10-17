(function ($, window, document) {
    'use strict';

    function cfg() {
        return window.landingConfig || {};
    }

    function htmlEncode(value) {
        return $('<div/>').text(value || '').html();
    }

    function showNewCoursesToast() {
        var $toast = $('#newCoursesToast');
        if (!$toast.length) {
            return;
        }

        try {
            $toast.toast('show');
            $toast.find('.close').off('click.enhanced').on('click.enhanced', function (e) {
                e.preventDefault();
                try {
                    $toast.toast('hide');
                } catch (err) {
                    $toast.hide();
                }
            });
        } catch (e) {
            $toast.show();
            setTimeout(function () {
                $toast.hide();
            }, 8000);
        }
    }

    function setupLandingSearch() {
        var settings = cfg();
        var $input = $('#searchInput');
        var $form = $('#searchForm');
        var $results = $('#searchResults');
        var typingTimer;
        var typingDelay = 350;

        if (!$input.length || !$form.length || !$results.length) {
            return;
        }

        function renderResults(items) {
            if (!items || items.length === 0) {
                $results.html('<div class="p-3 text-muted">Sonuç bulunamadı.</div>').show();
                return;
            }

            var html = [];
            $.each(items, function (i, item) {
                var excerpt = item.excerpt ? item.excerpt.replace(/[\r\n]+/g, ' ').replace(/<\/?[^>]+(>|$)/g, '') : '';
                if (excerpt.length > 120) {
                    excerpt = excerpt.substring(0, 120) + '...';
                }

                html.push(
                    '<a class="search-result-item" href="' + settings.courseDetailsUrl + '?id=' + encodeURIComponent(item.id) + '">' +
                    '<img class="search-result-thumb" src="' + htmlEncode(item.cover) + '" loading="lazy" onerror="this.src=\'' + settings.defaultCourseImage + '\'" />' +
                    '<div class="search-result-meta">' +
                    '<div class="search-result-title">' + htmlEncode(item.title) + '</div>' +
                    '<div class="search-result-desc">' + htmlEncode(excerpt) + '</div>' +
                    (item.category ? '<div class="search-result-cat">' + htmlEncode(item.category) + '</div>' : '') +
                    '</div>' +
                    '</a>'
                );
            });

            $results.html(html.join('')).show();
        }

        function doSearch(query) {
            if (!query || query.trim().length < 2) {
                $results.hide();
                return;
            }

            $.ajax({
                url: settings.searchUrl,
                type: 'GET',
                data: { q: query },
                dataType: 'json',
                success: function (response) {
                    renderResults((response && response.items) ? response.items : []);
                },
                error: function () {
                    $results.html('<div class="p-3 text-danger">Arama yapılırken hata oluştu.</div>').show();
                }
            });
        }

        $input.on('input', function () {
            clearTimeout(typingTimer);
            var query = $(this).val();
            typingTimer = setTimeout(function () {
                doSearch(query);
            }, typingDelay);
        });

        $form.on('submit', function (e) {
            e.preventDefault();
            var query = $input.val();
            if (!query || query.trim().length === 0) {
                return;
            }

            var first = $results.find('.search-result-item').first();
            if (first.length) {
                window.location.href = first.attr('href');
            } else {
                window.location.href = settings.courseListUrl + '?q=' + encodeURIComponent(query);
            }
        });

        $(document).on('click', function (e) {
            if (!$(e.target).closest('#searchResults, #searchInput').length) {
                $results.hide();
            }
        });

        $input.on('keydown', function (e) {
            if (e.key === 'Escape') {
                $results.hide();
            }
        });
    }

    function sendTeacherRequest() {
        var settings = cfg();
        var token = $('#teacherRequestFormGlobal').find('input[name="__RequestVerificationToken"]').val();

        if (!token) {
            alert('Güvenlik tokeni bulunamadı. Lütfen sayfayı yenileyin.');
            return;
        }

        $.ajax({
            url: settings.teacherRequestUrl,
            type: 'POST',
            data: { __RequestVerificationToken: token },
            success: function (response) {
                if (!response) {
                    alert('Beklenmeyen cevap.');
                    return;
                }

                if (response.status === 'notLogin') {
                    window.location.href = settings.loginUrl;
                } else if (response.status === 'ok') {
                    alert('Başvurunuz alındı. Yönetici onayına gönderildi.');
                } else if (response.status === 'alreadyRequested') {
                    alert('Zaten bir başvurunuz beklemede.');
                } else if (response.status === 'alreadyTeacher') {
                    alert('Zaten eğitmensiniz.');
                } else {
                    alert('Hata: ' + (response.message || response.status));
                }
            },
            error: function () {
                alert('İstek gönderilirken hata oluştu.');
            }
        });
    }

    function setupTeacherRequest() {
        $(document)
            .off('click.landingTeacherRequest', '#teacherRequestBtnNav, #teacherRequestAnchorNav')
            .on('click.landingTeacherRequest', '#teacherRequestBtnNav, #teacherRequestAnchorNav', function (e) {
                e.preventDefault();
                sendTeacherRequest();
            });
    }

    function setupLoginAlert() {
        var settings = cfg();
        var $modal = $('#loginAlertModal');
        if (!$modal.length || !settings.hasLoginError) {
            return;
        }

        $modal.modal('show');

        $('#loginRedirectBtn').on('click', function () {
            window.location.href = settings.loginUrl;
        });

        $('#homeRedirectBtn').on('click', function () {
            window.location.href = settings.landingUrl;
        });

        $modal.on('hidden.bs.modal', function () {
            window.location.href = settings.landingUrl;
        });
    }

    function loadCategories() {
        var settings = cfg();
        var $grid = $('#categoriesGrid');
        if (!$grid.length) {
            return;
        }

        $.ajax({
            url: settings.categoriesUrl,
            type: 'GET',
            dataType: 'json',
            success: function (categories) {
                displayCategories(categories);
            },
            error: function (xhr, status, error) {
                if (window.console) {
                    console.error('Kategoriler yüklenirken hata:', error);
                }

                $grid.html(
                    '<div class="col-12 text-center">' +
                    '<div class="alert alert-warning">' +
                    '<i class="fa fa-exclamation-triangle"></i> Kategoriler yüklenirken bir hata oluştu.' +
                    '</div>' +
                    '</div>'
                );
            }
        });
    }

    function displayCategories(categories) {
        var settings = cfg();
        var $grid = $('#categoriesGrid');
        var html = '';

        if (categories && categories.length > 0) {
            // Aktif kursu olan kategorileri öne al
            categories.sort(function (a, b) {
                var countA = a.CourseCount || 0;
                var countB = b.CourseCount || 0;
                if (countB !== countA) return countB - countA;
                return (a.CategoryName || '').localeCompare(b.CategoryName || '', 'tr');
            });

            $.each(categories, function (index, category) {
                var hasCourses = (category.CourseCount || 0) > 0;
                var badgeHtml = hasCourses
                    ? '<span class="badge badge-primary px-3 py-1 font-weight-bold" style="font-size:12px; border-radius:12px;">' + category.CourseCount + ' Kurs</span>'
                    : '<span class="badge badge-light text-muted px-2 py-1" style="font-size:11px;">0 Kurs</span>';

                html += '<div class="col-lg-3 col-md-4 col-sm-6 mb-4">' +
                    '<div class="category-card text-center ' + (hasCourses ? 'has-courses-card' : '') + '" data-category-id="' + category.CategoryId + '">' +
                    '<div class="category-icon">' +
                    '<i class="fa fa-folder-open"></i>' +
                    '</div>' +
                    '<h4>' + htmlEncode(category.CategoryName) + '</h4>' +
                    '<div class="mb-2">' + badgeHtml + '</div>' +
                    '<div class="category-overlay">' +
                    '<span class="btn btn-primary btn-sm font-weight-bold"><i class="fa fa-arrow-right mr-1"></i> Kursları Gör</span>' +
                    '</div>' +
                    '</div>' +
                    '</div>';
            });
        } else {
            html = '<div class="col-12 text-center">' +
                '<div class="alert alert-info">' +
                '<i class="fa fa-info-circle"></i> Henüz aktif kategori bulunmuyor.' +
                '</div>' +
                '</div>';
        }

        $grid.html(html);
        $grid.find('.category-card').on('click', function () {
            var categoryId = $(this).data('category-id');
            window.location.href = settings.coursesByCategoryUrl + '?categoryId=' + encodeURIComponent(categoryId);
        });
    }

    function setupPageScroll() {
        $('a.page-scroll').on('click', function (event) {
            var $anchor = $(this);
            var target = $($anchor.attr('href'));
            if (!target.length) {
                return;
            }

            event.preventDefault();
            $('html, body').stop().animate({
                scrollTop: target.offset().top - 50
            }, 500);
        });
    }

    $(function () {
        showNewCoursesToast();
        setupLandingSearch();
        setupTeacherRequest();
        setupLoginAlert();
        loadCategories();
        setupPageScroll();

        if (window.WOW) {
            new window.WOW().init();
        }
    });
})(jQuery, window, document);
