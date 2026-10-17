html2canvas(tempDiv, {
    backgroundColor: '#ffffff',
    scale: 2,
    logging: false,
    useCORS: true,
    allowTaint: true
}).then(function (canvas) {
    var image = canvas.toDataURL('image/jpeg', 0.95);

    var link = document.createElement('a');
    link.href = image;
    link.download = tableName + '_' + new Date().getTime() + '.jpeg';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    document.body.removeChild(tempDiv);

    $('#downloadImageBtn').prop('disabled', false).text(originalText);
}).catch(function (error) {
    console.error('İndirme hatası:', error);
    alert('✗ İndirme sırasında hata oluştu: ' + error.message);
    $('#downloadImageBtn').prop('disabled', false).text(originalText);
    if (document.body.contains(tempDiv)) {
        document.body.removeChild(tempDiv);
    }
});
    }

$('#downloadImageBtn').click(function () {
    downloadTableAsJpeg();
});