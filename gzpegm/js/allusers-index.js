/* ==========================================================================
   Kullanici Yonetimi JavaScript (allusers-index.js)
   ========================================================================== */

// Global tablo değişkenleri
var usersTable = null;
var pendingTable = null;
var allUsersTable = null;

// DataTable başlatma
function initializeDataTables() {
    if ($('#usersTable').length && !$.fn.DataTable.isDataTable('#usersTable')) {
        usersTable = $('#usersTable').DataTable({
            pageLength: 10,
            lengthMenu: [5, 10, 25, 50],
            order: [[12, "desc"]],
            autoWidth: false,
            language: {
                emptyTable: "Kayıt bulunamadı",
                info: "_TOTAL_ kayıttan _START_ - _END_ arası gösteriliyor",
                infoEmpty: "Kayıt yok",
                infoFiltered: "(_MAX_ kayıt içerisinden filtrelendi)",
                lengthMenu: "Sayfada _MENU_ kayıt göster",
                loadingRecords: "Yükleniyor...",
                processing: "İşleniyor...",
                search: "Kullanıcı Ara:",
                zeroRecords: "Eşleşen kullanıcı bulunamadı",
                paginate: {
                    first: "İlk",
                    last: "Son",
                    next: "Sonraki",
                    previous: "Önceki"
                }
            },
            columnDefs: [
                { orderable: false, targets: [0, 9, 10, 13] },
                { searchable: false, targets: [0, 9, 10, 13] }
            ]
        });
    }

    if ($('#datatable-default2').length && !$.fn.DataTable.isDataTable('#datatable-default2')) {
        pendingTable = $('#datatable-default2').DataTable({
            pageLength: 10,
            lengthMenu: [5, 10, 25, 50],
            autoWidth: false,
            language: {
                emptyTable: "Onay bekleyen kullanıcı bulunamadı",
                info: "_TOTAL_ kayıttan _START_ - _END_ arası gösteriliyor",
                infoEmpty: "Kayıt yok",
                infoFiltered: "(_MAX_ kayıt içerisinden filtrelendi)",
                lengthMenu: "Sayfada _MENU_ kayıt göster",
                search: "Ara:",
                zeroRecords: "Eşleşen kayıt bulunamadı",
                paginate: {
                    first: "İlk",
                    last: "Son",
                    next: "Sonraki",
                    previous: "Önceki"
                }
            },
            columnDefs: [
                { orderable: false, targets: [7] }
            ]
        });
    }

    if ($('#datatable-default').length && !$.fn.DataTable.isDataTable('#datatable-default')) {
        allUsersTable = $('#datatable-default').DataTable({
            pageLength: 10,
            lengthMenu: [5, 10, 25, 50],
            order: [[8, "desc"]],
            autoWidth: false,
            language: {
                emptyTable: "Kullanıcı bulunamadı",
                info: "_TOTAL_ kullanıcıdan _START_ - _END_ arası gösteriliyor",
                infoEmpty: "Kayıt yok",
                infoFiltered: "(_MAX_ kullanıcı içerisinden filtrelendi)",
                lengthMenu: "Sayfada _MENU_ kullanıcı göster",
                search: "Kullanıcı Ara:",
                zeroRecords: "Eşleşen kullanıcı bulunamadı",
                paginate: {
                    first: "İlk",
                    last: "Son",
                    next: "Sonraki",
                    previous: "Önceki"
                }
            },
            columnDefs: [
                { orderable: false, targets: [9] }
            ]
        });
    }
}

var isRunningOrphanCheck = false;
function startOrphanCheckDetailed(monthsParam) {
    if (isRunningOrphanCheck) return;
    isRunningOrphanCheck = true;
    var months = monthsParam || parseInt($("#inactivityMonths").val(), 10) || 3;
    $("#btnCheckOrphans").prop("disabled", true).html('<i class="fas fa-spinner fa-spin me-1"></i> Denetleniyor...');
    $("#orphanCheckModal").modal("show");
    $("#orphanCheckLoadingArea").show();
    $("#orphanCheckResultArea").hide();
    $("#orphanCandidateTableWrapper").hide();
    $("#btnProceedDelete").hide();
    $("#orphanCheckProgressBar").css("width", "0%").text("%0");
    $("#orphanCheckLog").empty();

    $.get('/AllUsers/CheckOrphanCandidatesDetailed', { months: months })
        .done(function (res) {
            if (!res || !res.checks) {
                $("#orphanCheckLog").append('<li class="list-group-item text-danger">❌ Hata: Geçersiz sunucu yanıtı.</li>');
                return;
            }
            var totalSteps = res.checks.length;
            var currentStep = 0;
            var delayBetweenSteps = 150;

            function displayNextCheck() {
                if (currentStep >= totalSteps) {
                    setTimeout(function () {
                        $("#orphanCheckLoadingArea").fadeOut(250, function () {
                            $("#orphanCheckResultArea").fadeIn(250);
                            if (res.total === 0) {
                                $("#orphanCheckSummaryIcon").html('<i class="fas fa-check-circle text-success fa-3x"></i>');
                                $("#orphanCheckResultText").html(
                                    '<div class="alert alert-success text-center mb-0">' +
                                    '<h5 class="alert-heading font-weight-bold mb-1"><i class="fas fa-shield-alt me-1"></i> Veritabanınız Temiz!</h5>' +
                                    '<p class="mb-0 small">' + months + ' aydır sisteme girmemiş ve ilişkili eğitim/işlem kaydı bulunmayan hiçbir yetim kullanıcı tespit edilmedi.</p>' +
                                    '</div>'
                                );
                                $("#orphanCandidateTableWrapper").hide();
                                $("#btnProceedDelete").hide();
                            } else {
                                $("#orphanCheckSummaryIcon").html('<i class="fas fa-exclamation-triangle text-warning fa-3x"></i>');
                                $("#orphanCheckResultText").html(
                                    '<div class="alert alert-warning text-left mb-0">' +
                                    '<h6 class="font-weight-bold mb-1"><i class="fas fa-user-slash me-1"></i> ' + res.total + ' Silinebilir Yetim Kullanıcı Tespit Edildi</h6>' +
                                    '<p class="mb-0 small text-muted">Bu kullanıcıların ' + months + ' aydır sisteme giriş yapmadığı ve kurs, sınav, sertifika, dilekçe veya işlem kütüğünde hiçbir kaydının olmadığı doğrulanmıştır. Aşağıdaki listeden inceleyebilirsiniz.</p>' +
                                    '</div>'
                                );

                                var users = res.users || [];
                                var rowsHtml = '';
                                for (var i = 0; i < users.length; i++) {
                                    var u = users[i];
                                    rowsHtml += '<tr>' +
                                        '<td class="text-center font-weight-bold">' + (i + 1) + '</td>' +
                                        '<td><span class="badge badge-light border text-dark font-weight-bold">' + (u.fldSicil || '-') + '</span></td>' +
                                        '<td class="font-weight-semibold">' + (u.FullName || ((u.fldName || '') + ' ' + (u.fldLastName || ''))) + '</td>' +
                                        '<td><small class="text-muted">' + (u.RegisterDate || '-') + '</small></td>' +
                                        '<td><small class="text-muted">' + (u.LastLogin || '-') + '</small></td>' +
                                        '</tr>';
                                }
                                $("#orphanCandidateTableBody").html(rowsHtml);
                                $("#orphanCandidateTableWrapper").show();
                                $("#btnProceedDelete").show().html('<i class="fas fa-trash-alt me-1"></i> Listelenen ' + res.total + ' Yetim Kullanıcıyı Güvenle Sil');
                                $("#btnProceedDelete").off("click").on("click", function () {
                                    $("#orphanCheckModal").modal("hide");
                                    startOrphanDeletion(months);
                                });
                            }
                        });
                    }, 400);
                    return;
                }

                var check = res.checks[currentStep];
                var checkText = typeof check === 'string' ? check : (check.message || check.step || JSON.stringify(check));
                var isSuccess = checkText.indexOf('✅') !== -1 || checkText.indexOf('✓') !== -1;
                var isError = checkText.indexOf('❌') !== -1;
                var borderCol = isError ? '#dc3545' : (isSuccess ? '#198754' : '#0dcaf0');
                var icon = isError ? '❌' : (isSuccess ? '✅' : 'ℹ️');
                var progress = Math.round(((currentStep + 1) / totalSteps) * 100);

                $("#orphanCheckProgressBar").css("width", progress + "%").text("%" + progress);
                $("#orphanCheckLog").append(
                    '<li class="list-group-item d-flex align-items-center py-2 px-3 mb-1" style="border-left: 4px solid ' + borderCol + '; background-color: #f8fafc; border-radius: 4px;">' +
                    '<span class="me-2">' + icon + '</span>' +
                    '<span class="font-weight-medium text-dark">' + checkText.replace(/^[✓✅❌ℹ️]\s*/, '') + '</span>' +
                    '</li>'
                );
                $("#orphanCheckLog").scrollTop($("#orphanCheckLog")[0].scrollHeight);
                currentStep++;
                setTimeout(displayNextCheck, delayBetweenSteps);
            }
            displayNextCheck();
        })
        .fail(function (xhr, status, error) {
            console.error('Error:', error);
            $("#orphanCheckLoadingArea").fadeOut(250, function () {
                $("#orphanCheckResultArea").fadeIn(250);
                $("#orphanCheckSummaryIcon").html('<i class="fas fa-times-circle text-danger fa-3x"></i>');
                $("#orphanCheckResultText").html('<div class="alert alert-danger"><strong>Sunucu hatası oluştu:</strong> ' + error + '</div>');
                $("#orphanCandidateTableWrapper").hide();
                $("#btnProceedDelete").hide();
            });
        })
        .always(function () {
            isRunningOrphanCheck = false;
            $("#btnCheckOrphans").prop("disabled", false).html('<i class="fas fa-search-plus me-1"></i> Silinecek Kullanıcıları Kontrol Et & Önizle');
        });
}

// Öğretmen onay/red
function approveTeacher(id) {
    if (!confirm("Öğretmen olarak onaylansın mı?")) return;
    $.post("/AllUsers/ApproveTeacher", {
        id: id,
        __RequestVerificationToken: $('input[name="__RequestVerificationToken"]').first().val()
    }, function (res) {
        if (res.status === "ok") location.reload(); else alert(res.message || "İşlem başarısız.");
    }).fail(function () { alert("Sunucu hatası oluştu."); });
}

function rejectTeacher(id) {
    if (!confirm("Başvuru reddedilsin mi?")) return;
    $.post("/AllUsers/RejectTeacher", {
        id: id,
        __RequestVerificationToken: $('input[name="__RequestVerificationToken"]').first().val()
    }, function (res) {
        if (res.status === "ok") location.reload(); else alert(res.message || "İşlem başarısız.");
    }).fail(function () { alert("Sunucu hatası oluştu."); });
}

function ensurePermissionMultiselect(selector) {
    var $select = $(selector);
    if (!$select.length || !$.fn.multiselect) return;

    if (!$select.data('multiselect')) {
        var opts = $select.data('plugin-options') || {};
        $select.multiselect(opts);
    } else {
        $select.multiselect('refresh');
    }
}

// Rol <-> Yetki multiselect otomatik senkronizasyonu
function syncRoleToPermissions(selectSelector, role) {
    var $select = $(selectSelector);
    if (!$select.length) return;

    var defaults = [];
    if (role === 'Admin') {
        defaults = ['1', '2', '3', '4', '5', '6'];
    } else if (role === 'Teacher') {
        defaults = ['3', '6'];
    } else {
        defaults = ['3'];
    }

    $select.find('option').each(function () {
        var val = $(this).val();
        $(this).prop('selected', defaults.indexOf(val) !== -1);
    });

    ensurePermissionMultiselect(selectSelector);
    $select.trigger('change');
}

function getuserdata(id) {
    $.get("/Getuser", { fldId: id }, function (data) {
        if (!data || data.success === false) {
            alert((data && data.message) || "Kullanıcı bulunamadı.");
            return;
        }
        $("#EditUserId").val(data.ID);
        $("#editNameUser").val(data.Name);
        $("#editLastNameUser").val(data.LastName);
        $("#editTitleUser").val(data.Title);
        $("#editDeputyUser").val(data.Deputy);
        $("#editPhoneUser").val(data.Phone);
        $("#editEmailUser").val(data.Email);
        $("#editSicilUser").val(data.Sicil);
        $("#editBorderUser").val(data.Border).trigger('change');
        $("#editUserRole").val(data.Role || "Student");
        if (data.Permi) {
            var permiArray = data.Permi.split(',').map(function (v) { return v.trim(); });
            $("#editPermiUser option").each(function () {
                $(this).prop('selected', permiArray.indexOf($(this).val()) !== -1);
            });
        } else {
            $("#editPermiUser option").prop('selected', false);
        }
        ensurePermissionMultiselect('#editPermiUser');
        $("#editPermiUser").trigger('change');
    }).fail(function () { alert("Kullanıcı verisi alınamadı."); });
}

function onayver(id) {
    if (!confirm("Bu kullanıcıya onay vermek istediğinize emin misiniz?")) return;
    $.post("/submituser", { Id: id, __RequestVerificationToken: $('input[name="__RequestVerificationToken"]').first().val() }, function (res) {
        if (res.Message) alert(res.Message);
        if (res.ok !== false && res.Url) window.location.href = res.Url;
    }).fail(function () { alert("Sunucu hatası oluştu."); });
}

function deletetemp(id) {
    if (!confirm("Bu geçici kullanıcıyı silmek istediğinize emin misiniz?")) return;
    $.post("/deletetempuser", { Id: id, __RequestVerificationToken: $('input[name="__RequestVerificationToken"]').first().val() }, function (res) {
        if (res.Message) alert(res.Message);
        if (res.ok !== false && res.Url) window.location.href = res.Url;
    }).fail(function () { alert("Sunucu hatası oluştu."); });
}

function resetpass(id) {
    if (!confirm("Bu kullanıcının şifresini sıfırlamak istediğinize emin misiniz?")) return;
    $.post("/resetpass", { fldId: id, __RequestVerificationToken: $('input[name="__RequestVerificationToken"]').first().val() }, function (res) {
        if (res.M) alert(res.M);
        if (!res || res.ok !== false) location.reload();
    }).fail(function () { alert("Sunucu hatası oluştu."); });
}

function deleteuser(id) {
    if (!confirm("Bu kullanıcıyı silmek istediğinize emin misiniz?")) return;
    $.post("/deleteuser", { Id: id, __RequestVerificationToken: $('input[name="__RequestVerificationToken"]').first().val() }, function (res) {
        if (res.Message) alert(res.Message);
        if (res.ok !== false && res.Url) window.location.href = res.Url;
    }).fail(function () { alert("Sunucu hatası oluştu."); });
}

// ==========================================================================
// BAKIM İŞLEMLERİ (ENTERPRISE MAINTENANCE OPERATIONS)
// ==========================================================================

// 1. Dinamik İnaktif Kullanıcı Sayısını Yükle
function loadInactivityCandidateCount() {
    var months = parseInt($("#inactivityMonths").val(), 10) || 3;
    var $badge = $("#inactivityCandidateBadge");
    if (!$badge.length) return;

    $badge.html('<i class="fas fa-spinner fa-spin me-1"></i> Hesaplanıyor...');

    function tryFetch(url, fallbackUrl) {
        $.get(url, { months: months })
            .done(function (res) {
                if (res && res.success) {
                    var c = res.count || 0;
                    $badge
                        .data("count", c)
                        .removeClass("badge-warning badge-secondary badge-success badge-danger")
                        .addClass(c > 0 ? "badge-warning" : "badge-secondary")
                        .text(c + " aday bulundu");

                    $("#inactivityBtnText").text(months + " Ay ve Üzeri İnaktifleri Pasife Al (" + c + ")");
                    if (typeof res.totalPassive !== 'undefined') {
                        $("#passiveCountText").text(res.totalPassive);
                    }
                } else if (fallbackUrl) {
                    tryFetch(fallbackUrl, null);
                } else {
                    $badge.removeClass("badge-warning").addClass("badge-danger").text("Hata: " + (res && res.message ? res.message : "Hesaplanamadı"));
                }
            })
            .fail(function () {
                if (fallbackUrl) {
                    tryFetch(fallbackUrl, null);
                } else {
                    $badge.removeClass("badge-warning").addClass("badge-danger").text("Bağlantı hatası");
                }
            });
    }

    tryFetch("/AllUsers/GetInactivityCandidateCount", "/GetInactivityCandidateCount");
}

// 2. Belirtilen Süredeki İnaktifleri Pasife Al
var isRunningInactivityDeactivation = false;
function runInactivityDeactivation() {
    if (isRunningInactivityDeactivation) return;

    var months = parseInt($("#inactivityMonths").val(), 10) || 3;
    var count = $("#inactivityCandidateBadge").data("count");
    var confirmMsg = months + " aydan uzun süredir sisteme giriş yapmamış aktif kullanıcılar pasife alınacaktır.";
    if (typeof count === 'number' && count >= 0) {
        confirmMsg = "Kriterlere uyan " + count + " adet aktif personel hesabı pasife alınacaktır. Devam edilsin mi?";
    } else {
        confirmMsg += " Devam edilsin mi?";
    }

    if (!confirm(confirmMsg)) return;

    isRunningInactivityDeactivation = true;
    var token = $('input[name="__RequestVerificationToken"]').first().val();
    var $btn = $("#btnRunInactivityDeactivate");
    $btn.prop("disabled", true).html('<i class="fas fa-spinner fa-spin me-1"></i> İşleniyor...');

    function postDeactivate(url, fallbackUrl) {
        $.post(url, { months: months, __RequestVerificationToken: token })
            .done(function (res) {
                if (res && res.success) {
                    alert(res.message);
                    location.reload();
                } else if (res && res.message) {
                    alert("Hata: " + res.message);
                    isRunningInactivityDeactivation = false;
                    $btn.prop("disabled", false).html('<i class="fas fa-user-lock me-1"></i> <span id="inactivityBtnText">' + months + ' Ay ve Üzeri İnaktifleri Pasife Al</span>');
                } else {
                    location.reload();
                }
            })
            .fail(function () {
                if (fallbackUrl) {
                    postDeactivate(fallbackUrl, null);
                } else {
                    alert("Sunucu ile bağlantı kurulamadı.");
                    isRunningInactivityDeactivation = false;
                    $btn.prop("disabled", false).html('<i class="fas fa-user-lock me-1"></i> <span id="inactivityBtnText">' + months + ' Ay ve Üzeri İnaktifleri Pasife Al</span>');
                }
            });
    }

    postDeactivate("/AllUsers/SetInactiveByInactivity", "/SetInactiveByInactivity");
}

// 3. Hızlı Toplu Aktifleştirme (Optimize Tek SQL İşlemi)
var isRunningBulkActivation = false;
function startBulkActivation() {
    if (isRunningBulkActivation) return;
    if (!confirm("Sistemde pasif durumda olan tüm personelin hesapları aktifleştirilecektir. Devam etmek istiyor musunuz?")) return;

    isRunningBulkActivation = true;
    var token = $('input[name="__RequestVerificationToken"]').first().val();
    var $btn = $("#btnActivateAll");
    $btn.prop("disabled", true).html('<i class="fas fa-spinner fa-spin me-1"></i> Aktifleştiriliyor...');

    function postActivate(url, fallbackUrl) {
        $.post(url, { __RequestVerificationToken: token })
            .done(function (res) {
                if (res && res.success) {
                    alert(res.message || "Tüm pasif kullanıcılar başarıyla aktifleştirildi.");
                    location.reload();
                } else if (fallbackUrl) {
                    postActivate(fallbackUrl, null);
                } else {
                    alert("Hata: " + (res && res.message ? res.message : "İşlem gerçekleştirilemedi."));
                    isRunningBulkActivation = false;
                    $btn.prop("disabled", false).html('<i class="fas fa-unlock-alt me-1"></i> Tüm Pasif Kullanıcıları Aktifleştir');
                }
            })
            .fail(function () {
                if (fallbackUrl) {
                    postActivate(fallbackUrl, null);
                } else {
                    alert("Sunucu hatası oluştu.");
                    isRunningBulkActivation = false;
                    $btn.prop("disabled", false).html('<i class="fas fa-unlock-alt me-1"></i> Tüm Pasif Kullanıcıları Aktifleştir');
                }
            });
    }

    postActivate("/AllUsers/BulkActivateAll", "/BulkActivateAll");
}

window.loadInactivityCandidateCount = loadInactivityCandidateCount;
window.runInactivityDeactivation = runInactivityDeactivation;
window.startBulkActivation = startBulkActivation;
window.startOrphanCheckDetailed = startOrphanCheckDetailed;
window.startOrphanDeletion = startOrphanDeletion;

// 4. Yetim Kullanıcı Silme (Canlı İlerleme ve Log Takibi)
var isRunningOrphanDeletion = false;
function startOrphanDeletion(monthsParam) {
    if (isRunningOrphanDeletion) {
        console.warn("Yetim kullanıcı silme işlemi zaten devam ediyor.");
        return;
    }
    isRunningOrphanDeletion = true;

    var months = monthsParam || parseInt($("#inactivityMonths").val(), 10) || 3;
    $("#btnDeleteOrphans, #btnProceedDelete").prop("disabled", true).html('<i class="fas fa-spinner fa-spin me-1"></i> Siliniyor...');
    $("#orphanDeleteModal").modal("show");
    $("#orphanLoadingArea").show();
    $("#orphanResultArea").hide();
    $("#orphanProgressBar").css("width", "0%").text("%0");
    $("#orphanProgressText").text("0 / 0");
    $("#orphanLiveLog").empty();

    var token = $('input[name="__RequestVerificationToken"]').first().val();
    if (!token) {
        isRunningOrphanDeletion = false;
        $("#orphanLoadingArea").hide();
        $("#orphanResultArea").show();
        $("#orphanResultText").text("Güvenlik tokeni bulunamadı. İşlem iptal edildi.");
        $("#btnDeleteOrphans").prop("disabled", false).html('<i class="fas fa-user-times me-1"></i> Yetim Kullanıcıları Sil (Doğrudan Başlat)');
        $("#btnProceedDelete").prop("disabled", false).html('<i class="fas fa-trash-alt me-1"></i> Bu Kullanıcıları Güvenle Sil');
        return;
    }

    $.get("/AllUsers/GetOrphanCandidates", { months: months })
        .done(function (res) {
            var rawUsers = (res && res.users) ? res.users : [];
            // ID bazında tekrarları önle (Deduplicate)
            var seenIds = {};
            var users = [];
            for (var i = 0; i < rawUsers.length; i++) {
                var u = rawUsers[i];
                if (u && u.fldId && !seenIds[u.fldId]) {
                    seenIds[u.fldId] = true;
                    users.push(u);
                }
            }

            var total = users.length;
            if (total === 0) {
                isRunningOrphanDeletion = false;
                $("#orphanLoadingArea").hide();
                $("#orphanResultArea").show();
                $("#orphanResultText").text("Silinecek yetim kullanıcı bulunamadı.");
                $("#btnDeleteOrphans").prop("disabled", false).html('<i class="fas fa-user-times me-1"></i> Yetim Kullanıcıları Sil (Doğrudan Başlat)');
                $("#btnProceedDelete").prop("disabled", false).html('<i class="fas fa-trash-alt me-1"></i> Bu Kullanıcıları Güvenle Sil');
                return;
            }
            var current = 0;
            var deletedCount = 0;
            var failedCount = 0;

            function finishDeletion() {
                isRunningOrphanDeletion = false;
                $("#orphanLoadingArea").hide();
                $("#orphanResultArea").show();
                var summary = deletedCount + " yetim kullanıcı başarıyla temizlendi.";
                if (failedCount > 0) {
                    summary += " " + failedCount + " kullanıcı silinemedi.";
                }
                summary += " Sayfa yenileniyor...";
                $("#orphanResultText").html(summary);
                $("#btnDeleteOrphans").prop("disabled", false).html('<i class="fas fa-user-times me-1"></i> Yetim Kullanıcıları Sil (Doğrudan Başlat)');
                $("#btnProceedDelete").prop("disabled", false).html('<i class="fas fa-trash-alt me-1"></i> Bu Kullanıcıları Güvenle Sil');
                setTimeout(function () { location.reload(); }, 1500);
            }

            function deleteNext() {
                if (current >= total) {
                    finishDeletion();
                    return;
                }
                var user = users[current];
                $.post("/AllUsers/DeleteOrphanUser",
                    { id: user.fldId, months: months, __RequestVerificationToken: token },
                    function (r) {
                        current++;
                        var percent = Math.round((current / total) * 100);
                        $("#orphanProgressBar").css("width", percent + "%").text("%" + percent);
                        $("#orphanProgressText").text(current + " / " + total);
                        var name = (r && r.name) ? r.name : ((user.fldName || '') + ' ' + (user.fldLastName || '')) || "Kullanıcı";
                        var sicilStr = user.fldSicil ? " (Sicil: " + user.fldSicil + ")" : "";
                        if (r && r.ok) {
                            deletedCount++;
                            var note = (r.message && r.message.indexOf("zaten") !== -1) ? " (Önceden silinmişti)" : "";
                            var msg = "<span class='text-success'>✅ " + name + sicilStr + " silindi" + note + "</span>";
                            $("#orphanLiveLog").append("<li class='py-1 border-bottom'>" + msg + "</li>");
                        } else {
                            failedCount++;
                            var errMsg = (r && r.message) ? r.message : "Hata";
                            var msg = "<span class='text-danger'>❌ " + name + sicilStr + " silinemedi: " + errMsg + "</span>";
                            $("#orphanLiveLog").append("<li class='py-1 border-bottom'>" + msg + "</li>");
                        }
                        $("#orphanLiveLog").scrollTop($("#orphanLiveLog")[0].scrollHeight);
                        setTimeout(deleteNext, 60);
                    }
                ).fail(function () {
                    current++;
                    failedCount++;
                    var percent = Math.round((current / total) * 100);
                    $("#orphanProgressBar").css("width", percent + "%").text("%" + percent);
                    $("#orphanProgressText").text(current + " / " + total);
                    var name = ((user.fldName || '') + ' ' + (user.fldLastName || '')) || "Kullanıcı";
                    var sicilStr = user.fldSicil ? " (Sicil: " + user.fldSicil + ")" : "";
                    $("#orphanLiveLog").append("<li class='py-1 border-bottom text-danger'>❌ Sunucu hatası: " + name + sicilStr + " silinemedi</li>");
                    $("#orphanLiveLog").scrollTop($("#orphanLiveLog")[0].scrollHeight);
                    setTimeout(deleteNext, 150);
                });
            }
            $("#orphanProgressText").text("0 / " + total);
            deleteNext();
        })
        .fail(function () {
            isRunningOrphanDeletion = false;
            $("#orphanLoadingArea").hide();
            $("#orphanResultArea").show();
            $("#orphanResultText").text("Silinecek kullanıcı listesi alınamadı.");
            $("#btnDeleteOrphans").prop("disabled", false).html('<i class="fas fa-user-times me-1"></i> Yetim Kullanıcıları Sil (Doğrudan Başlat)');
            $("#btnProceedDelete").prop("disabled", false).html('<i class="fas fa-trash-alt me-1"></i> Bu Kullanıcıları Güvenle Sil');
        });
}

$(document).ready(function () {
    initializeDataTables();

    // DataTables sayfalandığında veya arama yapıldığında modal form bağlamalarını tazele
    $(document).on('draw.dt', function () {
        if ($.fn.magnificPopup) {
            $('.modal-with-form').magnificPopup({
                type: 'inline',
                preloader: false,
                modal: true
            });
        }
    });

    // Rol değiştiğinde multiselect yetkilerini senkronize et
    $(document).on('change', '#addUserRole, select[name="UserRole"]', function () {
        syncRoleToPermissions('#PermiUser', $(this).val());
    });

    $(document).on('change', '#editUserRole', function () {
        syncRoleToPermissions('#editPermiUser', $(this).val());
    });

    // Bakım İşlemleri: İnaktiflik süresi değiştiğinde dinamik sayıyı tazele
    $(document).on('change', '#inactivityMonths', function () {
        loadInactivityCandidateCount();
    });

    // Bakım İşlemleri: Buton bağlamaları
    $('#btnRunInactivityDeactivate').off('click').on('click', function () {
        runInactivityDeactivation();
    });

    $('#btnActivateAll').off('click').on('click', function () {
        startBulkActivation();
    });

    $('#btnCheckOrphans').off('click').on('click', function () {
        startOrphanCheckDetailed();
    });

    $("#btnDeleteOrphans").off("click").on("click", function () {
        var months = parseInt($("#inactivityMonths").val(), 10) || 3;
        if (!confirm(months + " aydır sisteme giriş yapmamış ve hiçbir işlem/eğitim kaydı bulunmayan yetim kullanıcılar kalıcı olarak silinecektir. Devam edilsin mi?")) return;
        startOrphanDeletion(months);
    });

    $('#filterStatus').on('change', function () {
        var val = $(this).val();
        if (usersTable) {
            if (val === "") usersTable.column(1).search('').draw();
            else usersTable.column(1).search('^' + val + '$', true, false).draw();
        }
    });

    $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
        var targetTab = $(e.target).attr("href");
        if (targetTab === "#maintenance-content") {
            loadInactivityCandidateCount();
        }

        setTimeout(function () {
            if (usersTable) usersTable.columns.adjust().draw(false);
            if (pendingTable) pendingTable.columns.adjust().draw(false);
            if (allUsersTable) allUsersTable.columns.adjust().draw(false);
        }, 100);
    });

    // Sayfa ilk yüklendiğinde bakım sekmesi önizlemesini hazırla
    loadInactivityCandidateCount();
});
