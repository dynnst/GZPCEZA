/* ==========================================================================
   Tahdit Summernote Editor (tahdit-editor.js)
   ========================================================================== */

$(function () {
    var uploadUrl = $('#tahdit-editor-config').data('upload-url') || '/Tahdit/SummernoteUpload';

    $('.summernote').each(function () {
        var $this = $(this);
        if (!$this.data('summernote')) {
            $this.summernote({
                lang: 'tr-TR',
                height: 300,
                dialogsInBody: true,
                callbacks: {
                    onImageUpload: function (files) {
                        var $sn = $(this);
                        var formData = new FormData();
                        formData.append('file', files[0]);
                        formData.append('__RequestVerificationToken', $('input[name="__RequestVerificationToken"]').val());
                        $.ajax({
                            url: uploadUrl,
                            type: 'POST',
                            data: formData,
                            processData: false,
                            contentType: false,
                            success: function (data) {
                                if (data.url) $sn.summernote('insertImage', data.url);
                                else if (data.error) alert('Hata: ' + data.error);
                            },
                            error: function () { alert('Resim yüklenirken hata oluştu'); }
                        });
                    }
                }
            });
        }
    });

    $('#Edit_Aktif').on('change', function () {
        var isChecked = $(this).prop('checked');
        $('#Edit_Aktif_Hidden').val(isChecked ? 'true' : 'false');
        $('#Edit_AktifText').text(isChecked ? 'Aktif' : 'Pasif');
    });

    $('form').on('submit', function () {
        $(this).find('.summernote').each(function () {
            if ($(this).summernote) $(this).val($(this).summernote('code'));
        });
    });
});
