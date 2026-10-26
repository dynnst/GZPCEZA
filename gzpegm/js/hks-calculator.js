/* ==========================================================================
   HKS (Hudut Kapıları Sistemi) & 90/180 Gün Kuralı Hesaplayıcı (hks-calculator.js)
   EGM Pasaport Kontrol Noktaları İçin Çevrimdışı, Hızlı ve Akıllı Entegrasyon
   ========================================================================== */

(function (window, $) {
    'use strict';

    var HKS = {
        state: {
            passenger: {
                name: '',
                surname: '',
                fullName: '',
                fatherName: '',
                motherName: '',
                birthdate: '',
                gender: '',
                idNo: '',
                passportNo: '',
                country: '',
                age: null,
                isAdult: true
            },
            movements: [], // [{ type: 'G'|'C', typeName: 'Giriş'|'Çıkış', date: 'dd.mm.yyyy', dateObj: Date, raw: '' }]
            calculation: {
                totalDaysInWindow: 0,
                allowedDays: 90,
                violationDays: 0,
                remainingDays: 0,
                status: 'none', // 'valid', 'warning', 'violation'
                summaryText: ''
            },
            isOcrBusy: false
        },

        init: function () {
            this.bindEvents();
        },

        bindEvents: function () {
            var self = this;

            // Modal Açılış
            $('#btnOpenHksModal').on('click', function (e) {
                e.preventDefault();
                $('#hksModal').modal('show');
            });

            // Ekran Yakalama Butonu
            $('#btnCaptureScreen').on('click', function () {
                self.captureFromScreen();
            });

            // Panodan Yapıştır Butonu
            $('#btnPasteClipboard').on('click', function () {
                self.readFromClipboard();
            });

            // Global Ctrl+V (Modal açıkken)
            $(document).on('paste', function (e) {
                if ($('#hksModal').hasClass('show')) {
                    var items = (e.clipboardData || e.originalEvent.clipboardData).items;
                    for (var i = 0; i < items.length; i++) {
                        if (items[i].type.indexOf('image') !== -1) {
                            var blob = items[i].getAsFile();
                            self.processImageBlob(blob);
                            e.preventDefault();
                            break;
                        }
                    }
                }
            });

            // Dosya Seçme (Excel, CSV, Resim)
            $('#hksFileInput').on('change', function (e) {
                var file = e.target.files[0];
                if (file) {
                    self.handleUploadedFile(file);
                }
            });

            // Sürükle Bırak (Dropzone)
            var $dropzone = $('#hksDropzone');
            $dropzone.on('dragover dragenter', function (e) {
                e.preventDefault();
                e.stopPropagation();
                $dropzone.addClass('drag-active');
            }).on('dragleave drop', function (e) {
                e.preventDefault();
                e.stopPropagation();
                $dropzone.removeClass('drag-active');
                if (e.type === 'drop') {
                    var file = e.originalEvent.dataTransfer.files[0];
                    if (file) self.handleUploadedFile(file);
                }
            });

            // Metin Ayrıştırma Butonu
            $('#btnParseText').on('click', function () {
                var text = $('#hksTextInput').val();
                if (!text || !text.trim()) {
                    alert('Lütfen ayrıştırılacak metni kutucuğa yapıştırınız.');
                    return;
                }
                self.parseRawText(text);
            });

            // Manuel Satır Ekle
            $('#btnAddManualRow').on('click', function () {
                self.addManualRow();
            });

            // CEZAM'a Aktar Butonu
            $('#btnTransferToCezam').on('click', function () {
                self.transferToCezamForm();
            });
        },

        /**
         * 1. EKRAN YAKALAMA (Screen Capture API)
         */
        captureFromScreen: function () {
            var self = this;
            if (!navigator.mediaDevices || !navigator.mediaDevices.getDisplayMedia) {
                alert('Tarayıcınız ekran yakalama özelliğini desteklemiyor. Lütfen "Panodan Yapıştır" veya "Dosya Seç" seçeneğini kullanınız.');
                return;
            }

            self.showSpinner('HKS Penceresi seçimi bekleniyor...');

            navigator.mediaDevices.getDisplayMedia({
                video: { cursor: 'always' },
                audio: false
            }).then(function (stream) {
                var video = document.createElement('video');
                video.srcObject = stream;
                video.play();

                video.onloadedmetadata = function () {
                    setTimeout(function () {
                        var canvas = document.createElement('canvas');
                        canvas.width = video.videoWidth;
                        canvas.height = video.videoHeight;
                        var ctx = canvas.getContext('2d');
                        ctx.drawImage(video, 0, 0, canvas.width, canvas.height);

                        stream.getTracks().forEach(function (track) { track.stop(); });

                        canvas.toBlob(function (blob) {
                            self.processImageBlob(blob);
                        }, 'image/png');
                    }, 500);
                };
            }).catch(function (err) {
                self.hideSpinner();
                if (err.name !== 'NotAllowedError') {
                    alert('Ekran yakalanırken bir sorun oluştu: ' + err.message);
                }
            });
        },

        /**
         * 2. PANODAN YAPIŞTIR (Clipboard API)
         */
        readFromClipboard: function () {
            var self = this;
            if (navigator.clipboard && navigator.clipboard.read) {
                self.showSpinner('Panodaki görüntü okunuyor...');
                navigator.clipboard.read().then(function (items) {
                    var found = false;
                    for (var i = 0; i < items.length; i++) {
                        var item = items[i];
                        if (item.types.some(function (t) { return t.startsWith('image/'); })) {
                            var imgType = item.types.find(function (t) { return t.startsWith('image/'); });
                            item.getType(imgType).then(function (blob) {
                                self.processImageBlob(blob);
                            });
                            found = true;
                            break;
                        }
                    }
                    if (!found) {
                        self.hideSpinner();
                        alert('Panoda herhangi bir ekran görüntüsü bulunamadı. Lütfen önce ekran görüntüsü alınız.');
                    }
                }).catch(function (err) {
                    self.hideSpinner();
                    alert('Panoya erişim izni verilmedi. Bunun yerine doğrudan klavyeden Ctrl+V yapabilirsiniz.');
                });
            } else {
                alert('Tarayıcınız panodan otomatik okumayı desteklemiyor. Lütfen pencere açıkken klavyeden Ctrl+V tuşlarına basınız.');
            }
        },

        /**
         * 3. RESİM İŞLEME VE YEREL OFFLINE OCR (Tesseract.js)
         */
        processImageBlob: function (blob) {
            var self = this;
            self.showSpinner('Görüntü üzerindeki HKS verileri çözümleniyor...');

            var imgUrl = URL.createObjectURL(blob);
            $('#hksImagePreview').attr('src', imgUrl).removeClass('hidden');

            if (window.Tesseract) {
                window.Tesseract.recognize(blob, 'tur', {
                    workerPath: '/js/ocr/worker.min.js',
                    corePath: '/js/ocr/tesseract-core.wasm.js',
                    langPath: '/js/ocr',
                    logger: function (m) {
                        if (m.status === 'recognizing text' && m.progress) {
                            $('#hksSpinnerText').text('Metin okunuyor: %' + Math.round(m.progress * 100));
                        }
                    }
                }).then(function (result) {
                    self.hideSpinner();
                    var text = result.data.text || '';
                    self.parseOcrText(text);
                }).catch(function (err) {
                    self.hideSpinner();
                    console.error('OCR Hatası:', err);
                    alert('Görüntü okunurken bir hata oluştu. Lütfen görselin net olduğundan emin olunuz.');
                });
            } else {
                self.hideSpinner();
                alert('OCR modülü henüz hazır değil. Lütfen Excel veya Metin yapıştırma seçeneğini kullanınız.');
            }
        },

        /**
         * 4. DOSYA İŞLEME (Excel, CSV, Resim)
         */
        handleUploadedFile: function (file) {
            var self = this;
            var name = file.name.toLowerCase();

            if (name.endsWith('.xlsx') || name.endsWith('.xls')) {
                self.parseExcelFile(file);
            } else if (name.endsWith('.csv') || name.endsWith('.txt')) {
                self.parseCsvFile(file);
            } else if (name.endsWith('.png') || name.endsWith('.jpg') || name.endsWith('.jpeg')) {
                self.processImageBlob(file);
            } else {
                alert('Desteklenmeyen dosya türü. Lütfen Excel (.xlsx), CSV (.csv) veya Ekran Resmi yükleyiniz.');
            }
        },

        parseExcelFile: function (file) {
            var self = this;
            self.showSpinner('Excel dosyası çözümleniyor...');

            if (window.XLSX) {
                var reader = new FileReader();
                reader.onload = function (e) {
                    try {
                        var data = new Uint8Array(e.target.result);
                        var workbook = window.XLSX.read(data, { type: 'array' });
                        var firstSheet = workbook.SheetNames[0];
                        var csv = window.XLSX.utils.sheet_to_csv(workbook.Sheets[firstSheet]);
                        self.hideSpinner();
                        self.parseRawText(csv);
                    } catch (err) {
                        self.hideSpinner();
                        self.uploadToServer(file);
                    }
                };
                reader.readAsArrayBuffer(file);
            } else {
                self.uploadToServer(file);
            }
        },

        parseCsvFile: function (file) {
            var self = this;
            self.showSpinner('CSV dosyası okunuyor...');

            var reader = new FileReader();
            reader.onload = function (e) {
                self.hideSpinner();
                self.parseRawText(e.target.result);
            };
            reader.readAsText(file, 'windows-1254');
        },

        uploadToServer: function (file) {
            var self = this;
            self.showSpinner('Sunucu üzerinden çözümleniyor...');

            var formData = new FormData();
            formData.append('file', file);

            $.ajax({
                url: '/Calculate/ParseHksFile',
                type: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                success: function (res) {
                    self.hideSpinner();
                    if (res && res.success) {
                        self.applyParsedData(res.passenger, res.movements);
                    } else {
                        alert(res.message || 'Dosya okunamadı.');
                    }
                },
                error: function (xhr) {
                    self.hideSpinner();
                    alert('Sunucu hatası: ' + (xhr.statusText || 'Bilinmeyen hata'));
                }
            });
        },

        /**
         * METİN / CSV AYRIŞTIRMA MOTORU
         */
        parseRawText: function (content) {
            var self = this;
            if (!content) return;

            var lines = content.split(/\r?\n/).filter(function (l) { return l.trim().length > 0; });
            if (lines.length === 0) return;

            var delimiter = lines[0].indexOf(';') !== -1 ? ';' : ',';
            var headers = lines[0].split(delimiter).map(function (h) { return self.cleanHeader(h); });

            var colType = headers.findIndex(function (h) { return h.indexOf('giriscikistipi') !== -1 || h.indexOf('tip') !== -1 || h.indexOf('hareket') !== -1; });
            var colDate = headers.findIndex(function (h) { return h === 'tarih' || (h.indexOf('tarih') !== -1 && h.indexOf('dogum') === -1); });
            var colCancel = headers.findIndex(function (h) { return h.indexOf('iptal') !== -1; });
            var colName = headers.findIndex(function (h) { return h === 'ad' || h === 'adi' || h.indexOf('yolcuadi') !== -1; });
            var colSurname = headers.findIndex(function (h) { return h === 'soyad' || h === 'soyadi'; });
            var colFather = headers.findIndex(function (h) { return h.indexOf('baba') !== -1; });
            var colMother = headers.findIndex(function (h) { return h.indexOf('anne') !== -1; });
            var colBirth = headers.findIndex(function (h) { return h.indexOf('dogum') !== -1; });
            var colGender = headers.findIndex(function (h) { return h.indexOf('cinsiyet') !== -1; });
            var colId = headers.findIndex(function (h) { return h.indexOf('kimlik') !== -1 || h.indexOf('ykn') !== -1; });
            var colPass = headers.findIndex(function (h) { return h.indexOf('belgeserino') !== -1 || (h.indexOf('serino') !== -1 && h.indexOf('harf') === -1) || h.indexOf('pasaport') !== -1; });
            var colCountry = headers.findIndex(function (h) { return h.indexOf('ulke') !== -1; });

            var passenger = {
                name: '', surname: '', fullName: '', fatherName: '', motherName: '', birthdate: '', gender: '', idNo: '', passportNo: '', country: ''
            };
            var movements = [];

            for (var i = 1; i < lines.Length || i < lines.length; i++) {
                var row = lines[i].split(delimiter);
                if (!row || row.length === 0) continue;

                if (!passenger.name && colName !== -1 && row[colName]) passenger.name = row[colName].trim();
                if (!passenger.surname && colSurname !== -1 && row[colSurname]) passenger.surname = row[colSurname].trim();
                if (!passenger.fatherName && colFather !== -1 && row[colFather]) passenger.fatherName = row[colFather].trim();
                if (!passenger.motherName && colMother !== -1 && row[colMother]) passenger.motherName = row[colMother].trim();
                if (!passenger.birthdate && colBirth !== -1 && row[colBirth]) passenger.birthdate = self.cleanDateOnly(row[colBirth]);
                if (!passenger.gender && colGender !== -1 && row[colGender]) passenger.gender = row[colGender].trim();
                if (!passenger.idNo && colId !== -1 && row[colId]) passenger.idNo = row[colId].trim();
                if (!passenger.passportNo && colPass !== -1 && row[colPass]) passenger.passportNo = row[colPass].trim();
                if (!passenger.country && colCountry !== -1 && row[colCountry]) passenger.country = row[colCountry].trim();

                var isCancelled = false;
                if (colCancel !== -1 && row[colCancel]) {
                    var cVal = row[colCancel].toLowerCase();
                    if (cVal.indexOf('iptal') !== -1 || cVal.indexOf('gecersiz') !== -1) isCancelled = true;
                }
                if (isCancelled) continue;

                if (colDate !== -1 && row[colDate]) {
                    var cleanDate = self.cleanDateOnly(row[colDate]);
                    if (!cleanDate) continue;

                    var mType = 'G';
                    if (colType !== -1 && row[colType]) {
                        var tVal = row[colType].trim().toLowerCase();
                        if (tVal.startsWith('ç') || tVal.startsWith('c') || tVal.indexOf('çıkış') !== -1 || tVal.indexOf('cikis') !== -1) {
                            mType = 'C';
                        }
                    }

                    movements.push({
                        type: mType,
                        typeName: mType === 'C' ? 'Çıkış' : 'Giriş',
                        date: cleanDate,
                        rawDate: row[colDate].trim()
                    });
                }
            }

            passenger.fullName = (passenger.name + ' ' + passenger.surname).trim();
            self.applyParsedData(passenger, movements);
        },

        /**
         * OCR METNİNDEN HKS VERİLERİNİ AYIKLAMA (REGEX & PATTERN MATCHING)
         */
        parseOcrText: function (text) {
            var self = this;
            var lines = text.split(/\r?\n/);
            var movements = [];
            var passenger = $.extend({}, self.state.passenger);

            // Pasaport / Seri No: e.g. "Seri No: N11077690" veya "N11077690"
            var passMatch = text.match(/(?:seri\s*no|belge\s*seri\s*no|pasaport\s*no)[\s:]*([A-Z0-9]{6,12})/i) ||
                            text.match(/\b([A-Z]\d{8,9})\b/);
            if (passMatch) passenger.passportNo = passMatch[1].trim();

            // Kimlik No / YKN: 11 veya 12 haneli rakam (88 veya 99 ile başlayan yabancı kimlik veya TC)
            var idMatch = text.match(/(?:kimlik\s*no|ykn|tc(?:kn)?)[\s:]*(\d{11,12})/i) ||
                          text.match(/\b(88\d{10}|99\d{9}|\d{11})\b/);
            if (idMatch) passenger.idNo = idMatch[1].trim();

            // Doğum Tarihi: DD.MM.YYYY veya DD/MM/YYYY
            var birthMatch = text.match(/(?:do[gğ]um\s*tarihi?)[\s:]*(\d{1,2}[./-]\d{1,2}[./-]\d{4})/i);
            if (birthMatch) passenger.birthdate = self.cleanDateOnly(birthMatch[1]);

            // Ülke / Uyruk
            var countryMatch = text.match(/(?:uyruk|ülke)[\s:]*([A-ZÇĞİÖŞÜa-zçğıöşü]+)/i) ||
                               text.match(/\b(KAZAKISTAN|RUSYA|UKRAYNA|ALMANYA|GURCISTAN|AZERBAYCAN|IRAN|IRAK|SURIYE|OZBEKISTAN|TURKMENISTAN)\b/i);
            if (countryMatch) passenger.country = countryMatch[1].trim();

            // Satır satır C/G ve Tarih ara: e.g. "C 26/10/2026 11:28:04" veya "Çıkış 26/10/2026"
            var dateRegex = /(\b[CGÇcç]\b)?.*?(\d{1,2}[./-]\d{1,2}[./-]\d{4})/i;

            lines.forEach(function (line) {
                var match = line.match(dateRegex);
                if (match) {
                    var rawType = (match[1] || '').toUpperCase();
                    var rawDate = match[2];
                    var cleanDate = self.cleanDateOnly(rawDate);

                    var mType = 'G';
                    if (rawType.indexOf('C') !== -1 || rawType.indexOf('Ç') !== -1 || line.toLowerCase().indexOf('çıkış') !== -1) {
                        mType = 'C';
                    }

                    if (cleanDate) {
                        movements.push({
                            type: mType,
                            typeName: mType === 'C' ? 'Çıkış' : 'Giriş',
                            date: cleanDate,
                            rawDate: line.trim()
                        });
                    }
                }
            });

            self.applyParsedData(passenger, movements);
        },

        /**
         * AYRIŞTIRILMIŞ VERİYİ STATE'E UYGULA VE EKRANA BAS
         */
        applyParsedData: function (passenger, movements) {
            var self = this;

            if (passenger) {
                self.state.passenger = $.extend({}, self.state.passenger, passenger);
                if (!self.state.passenger.fullName && (self.state.passenger.name || self.state.passenger.surname)) {
                    self.state.passenger.fullName = (self.state.passenger.name + ' ' + self.state.passenger.surname).trim();
                }
            }

            self.state.movements = (movements || []).map(function (m) {
                var dObj = self.parseDateDMY(m.date);
                return {
                    type: m.type,
                    typeName: m.type === 'C' ? 'Çıkış' : 'Giriş',
                    date: m.date,
                    dateObj: dObj,
                    rawDate: m.rawDate || m.date
                };
            }).filter(function (m) { return m.dateObj !== null; });

            // Kronolojik sırala (Eskiden yeniye)
            self.state.movements.sort(function (a, b) {
                return a.dateObj - b.dateObj;
            });

            self.renderPassengerCard();
            self.renderMovementsTable();
            self.calculate90_180();
        },

        /**
         * YOLCU KARTI RENDERING (Yaş Grubu ve Kimlik Detayları)
         */
        renderPassengerCard: function () {
            var self = this;
            var p = self.state.passenger;
            if (p.fullName || p.country || p.passportNo || p.idNo || p.birthdate) {
                $('#hksPassengerCard').removeClass('hidden');
                $('#hksPassName').text(p.fullName || '—');
                $('#hksPassCountry').text(p.country || '—');
                $('#hksPassPassport').text(p.passportNo || '—');
                $('#hksPassIdNo').text(p.idNo || '—');
                $('#hksPassBirth').text(p.birthdate || '—');

                if (p.fatherName) {
                    $('#hksPassFather').text(p.fatherName);
                    $('#hksPassFatherCol').removeClass('hidden');
                } else {
                    $('#hksPassFatherCol').addClass('hidden');
                }

                // Yaş Grubu Hesabı
                if (p.birthdate) {
                    var bDate = self.parseDateDMY(p.birthdate);
                    if (bDate) {
                        var now = new Date();
                        var age = now.getFullYear() - bDate.getFullYear();
                        var m = now.getMonth() - bDate.getMonth();
                        if (m < 0 || (m === 0 && now.getDate() < bDate.getDate())) age--;

                        p.age = age;
                        p.isAdult = age >= 18;
                        $('#hksPassAgeBadge').text(age + ' Yaş (' + (p.isAdult ? 'Yetişkin' : 'Çocuk') + ')').removeClass('hidden');
                    } else {
                        $('#hksPassAgeBadge').addClass('hidden');
                    }
                } else {
                    $('#hksPassAgeBadge').addClass('hidden');
                }
            } else {
                $('#hksPassengerCard').addClass('hidden');
            }
        },

        renderMovementsTable: function () {
            var self = this;
            var $tbody = $('#hksMovementsTbody');
            $tbody.empty();

            if (self.state.movements.length === 0) {
                $tbody.append('<tr><td colspan="4" class="text-center text-muted py-3">Henüz hareket kaydı bulunamadı.</td></tr>');
                $('#hksResultCard').addClass('hidden');
                return;
            }

            self.state.movements.forEach(function (m, idx) {
                var badgeClass = m.type === 'C' ? 'badge-danger' : 'badge-success';
                var tr = '<tr>' +
                    '<td class="text-center font-weight-bold">' + (idx + 1) + '</td>' +
                    '<td><span class="badge ' + badgeClass + ' px-2 py-1">' + m.typeName + '</span></td>' +
                    '<td class="font-weight-bold">' + m.date + '</td>' +
                    '<td class="text-center">' +
                    '   <button type="button" class="btn btn-xs btn-outline-danger btn-delete-row" data-idx="' + idx + '" title="Bu satırı kaldır">' +
                    '       <i class="fas fa-trash-alt"></i>' +
                    '   </button>' +
                    '</td>' +
                    '</tr>';
                $tbody.append(tr);
            });

            $('.btn-delete-row').on('click', function () {
                var idx = parseInt($(this).data('idx'), 10);
                self.state.movements.splice(idx, 1);
                self.renderMovementsTable();
                self.calculate90_180();
            });
        },

        calculate90_180: function () {
            var self = this;
            var movs = self.state.movements;
            if (movs.length === 0) {
                $('#hksResultCard').addClass('hidden');
                return;
            }

            var trips = [];
            var currentEntry = null;

            movs.forEach(function (m) {
                if (m.type === 'G') {
                    if (currentEntry) {
                        trips.push({ enter: currentEntry.dateObj, exit: m.dateObj, enterStr: currentEntry.date, exitStr: m.date });
                    }
                    currentEntry = m;
                } else if (m.type === 'C') {
                    if (currentEntry) {
                        trips.push({ enter: currentEntry.dateObj, exit: m.dateObj, enterStr: currentEntry.date, exitStr: m.date });
                        currentEntry = null;
                    } else {
                        trips.push({ enter: m.dateObj, exit: m.dateObj, enterStr: m.date, exitStr: m.date });
                    }
                }
            });

            var today = new Date();
            today.setHours(0, 0, 0, 0);

            if (currentEntry) {
                trips.push({ enter: currentEntry.dateObj, exit: today, enterStr: currentEntry.date, exitStr: self.formatDateDMY(today), isOpen: true });
            }

            var lastTrip = trips[trips.length - 1];
            var targetDate = lastTrip ? lastTrip.exit : today;

            var windowStart = new Date(targetDate);
            windowStart.setDate(windowStart.getDate() - 180);

            var totalStayDays = 0;
            var msPerDay = 1000 * 60 * 60 * 24;

            trips.forEach(function (t) {
                var overlapStart = t.enter > windowStart ? t.enter : windowStart;
                var overlapEnd = t.exit < targetDate ? t.exit : targetDate;

                if (overlapStart <= overlapEnd) {
                    var days = Math.floor((overlapEnd - overlapStart) / msPerDay) + 1;
                    totalStayDays += days;
                }
            });

            var allowedDays = 90;
            var violation = Math.max(0, totalStayDays - allowedDays);
            var remaining = Math.max(0, allowedDays - totalStayDays);

            self.state.calculation = {
                totalDaysInWindow: totalStayDays,
                allowedDays: allowedDays,
                violationDays: violation,
                remainingDays: remaining,
                trips: trips
            };

            // Sefer Mantık Doğrulaması Kutusu Rendering
            var $valBox = $('#hksTripsValidationBox');
            $valBox.empty();

            if (trips.length > 0) {
                $valBox.removeClass('hidden');
                var valHtml = '<div class="font-weight-bold text-dark mb-1"><i class="fas fa-check-double text-info mr-1"></i> Eşleştirilen Seferler ve Mantık Doğrulaması:</div><ul class="list-unstyled mb-0">';
                var hasLogicError = false;

                trips.forEach(function (t, i) {
                    var isOrderValid = t.enter <= t.exit;
                    if (!isOrderValid) hasLogicError = true;

                    var badge = isOrderValid 
                        ? '<span class="badge badge-success ml-2"><i class="fas fa-check mr-1"></i>Mantık Doğru (Giriş &le; Çıkış)</span>'
                        : '<span class="badge badge-danger ml-2"><i class="fas fa-exclamation-triangle mr-1"></i>HATA: Giriş çıkıştan büyük!</span>';

                    var diffTxt = t.isOpen ? '<span class="text-warning font-weight-bold">(Halen Yurt İçinde)</span>' : '<span class="text-primary font-weight-bold">(' + (Math.floor((t.exit - t.enter) / msPerDay) + 1) + ' Gün Kalış)</span>';

                    valHtml += '<li class="py-1 border-bottom d-flex align-items-center justify-content-between">' +
                        '<div><strong>Sefer ' + (i + 1) + ':</strong> ' +
                        '<span class="badge badge-success px-2">Giriş</span> ' + t.enterStr + ' ➔ ' +
                        '<span class="badge badge-danger px-2">Çıkış</span> ' + t.exitStr + ' ' + diffTxt +
                        '</div>' + badge +
                        '</li>';
                });
                valHtml += '</ul>';
                $valBox.html(valHtml);

                if (hasLogicError) {
                    $('#btnTransferToCezam').prop('disabled', true).addClass('disabled').attr('title', 'Tarih sıralamasında mantık hatası var!');
                } else {
                    $('#btnTransferToCezam').prop('disabled', false).removeClass('disabled').removeAttr('title');
                }
            } else {
                $valBox.addClass('hidden');
            }

            self.renderResultCard();
        },

        renderResultCard: function () {
            var calc = this.state.calculation;
            var $card = $('#hksResultCard');
            $card.removeClass('hidden result-valid result-warning result-violation');

            $('#hksResTotalStay').text(calc.totalDaysInWindow + ' Gün');

            if (calc.violationDays > 0) {
                $card.addClass('result-violation');
                $('#hksResStatusBadge').html('<i class="fas fa-exclamation-triangle mr-1"></i> VİZE İHLALİ (90 GÜN AŞILDI)');
                $('#hksResDetailText').html('Yolcu son 180 günde yasal kalış hakkını <strong>' + calc.violationDays + ' GÜN</strong> aşmıştır.');
                $('#btnTransferToCezam').removeClass('hidden').html('<i class="fas fa-rocket mr-1"></i> Bu ' + calc.violationDays + ' Günlük İhlali ve Kimlik Bilgilerini Forma Aktar');
            } else if (calc.remainingDays <= 10) {
                $card.addClass('result-warning');
                $('#hksResStatusBadge').html('<i class="fas fa-exclamation-circle mr-1"></i> SINIRDA / DİKKAT');
                $('#hksResDetailText').html('Yolcunun son 180 günde yalnızca <strong>' + calc.remainingDays + ' gün</strong> kalış hakkı kalmıştır.');
                $('#btnTransferToCezam').removeClass('hidden').html('<i class="fas fa-check mr-1"></i> Seferleri ve Kimlik Bilgilerini Forma Aktar');
            } else {
                $card.addClass('result-valid');
                $('#hksResStatusBadge').html('<i class="fas fa-check-circle mr-1"></i> GİRİŞE UYGUN');
                $('#hksResDetailText').html('Yolcunun son 180 gün kuralına göre <strong>' + calc.remainingDays + ' gün</strong> yasal kalış hakkı bulunmaktadır.');
                $('#btnTransferToCezam').removeClass('hidden').html('<i class="fas fa-check mr-1"></i> Seferleri ve Kimlik Bilgilerini Forma Aktar');
            }
        },

        /**
         * 6. CEZAM HESAPLAMA FORMUNA AKTAR (Tüm Seferler + Kimlik Bilgileri)
         */
        transferToCezamForm: function () {
            var self = this;
            var p = self.state.passenger;
            var trips = self.state.calculation.trips || [];

            if (trips.length === 0) {
                alert('Aktarılacak sefer bulunamadı.');
                return;
            }

            // 1. Ülke Seçimi (Varsa)
            if (p.country) {
                var matchedCountry = self.matchCountrySelect(p.country);
                if (matchedCountry) {
                    if ($.fn.select2) {
                        $('#CountryCalculate').val(matchedCountry).trigger('change.select2');
                    } else {
                        $('#CountryCalculate').val(matchedCountry).change();
                    }
                }
            }

            // 2. Hesaplama Modeli -> Default olarak "Normal Hesaplama" (value="1")
            // (180 Gün Kuralı sadece Rusya Federasyonu ve çoklu sefer için syncRussiaCalculationModel ile otomatik devreye girer)
            if ($.fn.select2) {
                $('#CTypeCalculate').val('1').trigger('change.select2');
            } else {
                $('#CTypeCalculate').val('1').change();
            }

            // 3. Giriş - Çıkış Tarihlerini Aktar
            var lastTrip = trips[trips.length - 1];
            $('#EnterDateCalculate').val(lastTrip.enterStr);
            $('#ExitDateCalculate').val(lastTrip.exitStr);

            if (trips.length > 1) {
                $('.extra').remove();
                for (var i = trips.length - 2; i >= 0; i--) {
                    if (typeof window.gcadd === 'function') {
                        window.gcadd();
                        var $lastRow = $('#date-rows-container .date-pair-row').last();
                        $lastRow.find('.endt').val(trips[i].enterStr);
                        $lastRow.find('.exdt').val(trips[i].exitStr);
                    }
                }
            }

            // 4. Şahıs Tutanak ve Kimlik Bilgilerini Hazırla (#form)
            if (p.fullName) $('#NameCFORM').val(p.fullName);
            if (p.passportNo) $('#PassportCFORM').val(p.passportNo);
            if (p.idNo) $('#IDNCFORM').val(p.idNo);
            if (p.birthdate) $('#BirthdateCFORM').val(p.birthdate);
            if (p.fatherName) $('#FatherCFORM').val(p.fatherName);
            if (p.motherName) $('#MotherCFORM').val(p.motherName);

            // 5. Gün Farklarını Hesapla
            if (typeof window.computeAllDiffs === 'function') {
                window.computeAllDiffs();
            }

            // 6. Otomatik Zincirleme Hesaplama: hesapla1 -> Doğum Tarihi/Yaş -> hesapla2 -> Tutanak Formu
            var birthdateStr = p.birthdate;

            // Calculate1 tamamlandığında Doğum Tarihi alanını doldur ve hesapla2'yi tetikle
            $(document).one('ajaxSuccess', function (event, xhr, settings) {
                if (settings.url && settings.url.indexOf('/Calculate1') !== -1) {
                    if (birthdateStr) {
                        $('#BirthDateCalculate').val(birthdateStr);
                        var birthEl = document.getElementById('BirthDateCalculate');
                        if (birthEl && typeof window.adultchild === 'function') {
                            try { window.adultchild(birthEl); } catch (e) { }
                        }

                        // Calculate2'yi tetikle
                        setTimeout(function () {
                            if (typeof window.hesapla2 === 'function') {
                                window.hesapla2();
                            }

                            // Calculate2 tamamlandığında Tutanak Formunu (#form) doldur ve aç
                            $(document).one('ajaxSuccess', function (ev2, xhr2, set2) {
                                if (set2.url && set2.url.indexOf('/Calculate2') !== -1) {
                                    setTimeout(function () {
                                        if (p.fullName) $('#NameCFORM').val(p.fullName);
                                        if (p.passportNo) $('#PassportCFORM').val(p.passportNo);
                                        if (p.idNo) $('#IDNCFORM').val(p.idNo);
                                        if (p.birthdate) $('#BirthdateCFORM').val(p.birthdate);
                                        if (p.fatherName) $('#FatherCFORM').val(p.fatherName);
                                        if (p.motherName) $('#MotherCFORM').val(p.motherName);

                                        if (typeof window.hesapla3 === 'function') {
                                            window.hesapla3();
                                        }
                                        $('#form').removeClass('hidden');

                                        // Sayfayı tutanak formuna akıcı kaydır
                                        if ($('#form').length && $('#form').is(':visible')) {
                                            $('html, body').animate({
                                                scrollTop: $('#form').offset().top - 80
                                            }, 500);
                                        }
                                    }, 150);
                                }
                            });
                        }, 100);
                    } else {
                        // Doğum tarihi yoksa doğrudan tutanak formunu aç
                        $('#form').removeClass('hidden');
                    }
                }
            });

            // İlk hesaplamayı başlat
            if (typeof window.hesapla1 === 'function') {
                window.hesapla1();
            }

            // Modalı Kapat
            $('#hksModal').modal('hide');

            // Başarı Bildirimi
            if (typeof PNotify !== 'undefined') {
                new PNotify({
                    title: 'HKS Verileri ve Şahıs Bilgileri Aktarıldı',
                    text: (p.fullName ? p.fullName + ' - ' : '') + trips.length + ' sefer ve tüm kimlik verileri forma eksiksiz aktarıldı.',
                    type: 'success',
                    delay: 4000
                });
            } else {
                alert((p.fullName ? p.fullName + ' isimli yolcunun ' : '') + 'tüm seferleri, kimlik bilgileri ve 180 gün kuralı forma başarıyla aktarıldı!');
            }
        },

        matchCountrySelect: function (rawCountry) {
            if (!rawCountry) return '';
            var norm = rawCountry.trim().toLowerCase()
                .replace(/ı/g, 'i').replace(/ğ/g, 'g').replace(/ü/g, 'u')
                .replace(/ş/g, 's').replace(/ö/g, 'o').replace(/ç/g, 'c');

            var matched = '';
            $('#CountryCalculate option').each(function () {
                var optVal = $(this).val();
                if (!optVal) return;
                var optNorm = optVal.toLowerCase()
                    .replace(/ı/g, 'i').replace(/ğ/g, 'g').replace(/ü/g, 'u')
                    .replace(/ş/g, 's').replace(/ö/g, 'o').replace(/ç/g, 'c');

                if (optNorm === norm || optNorm.indexOf(norm) !== -1 || norm.indexOf(optNorm) !== -1) {
                    matched = optVal;
                    return false;
                }
            });
            return matched;
        },

        addManualRow: function () {
            var today = this.formatDateDMY(new Date());
            this.state.movements.push({
                type: 'G',
                typeName: 'Giriş',
                date: today,
                dateObj: new Date(),
                rawDate: today
            });
            this.renderMovementsTable();
            this.calculate90_180();
        },

        showSpinner: function (msg) {
            $('#hksSpinner').removeClass('hidden');
            $('#hksSpinnerText').text(msg || 'İşleniyor...');
        },

        hideSpinner: function () {
            $('#hksSpinner').addClass('hidden');
        },

        cleanHeader: function (h) {
            if (!h) return '';
            return h.trim().toLowerCase()
                .replace(/ı/g, 'i').replace(/ğ/g, 'g').replace(/ü/g, 'u')
                .replace(/ş/g, 's').replace(/ö/g, 'o').replace(/ç/g, 'c')
                .replace(/[^a-z0-9]/g, '');
        },

        cleanDateOnly: function (raw) {
            if (!raw) return '';
            var match = String(raw).match(/(\d{1,2})[./-](\d{1,2})[./-](\d{4})/);
            if (match) {
                var day = parseInt(match[1], 10);
                var month = parseInt(match[2], 10);
                var year = parseInt(match[3], 10);
                if (day >= 1 && day <= 31 && month >= 1 && month <= 12 && year >= 1900 && year <= 2100) {
                    var d = ('0' + day).slice(-2);
                    var m = ('0' + month).slice(-2);
                    return d + '.' + m + '.' + year;
                }
            }
            return '';
        },

        parseDateDMY: function (dmyStr) {
            if (!dmyStr) return null;
            var parts = String(dmyStr).split('.');
            if (parts.length !== 3) return null;
            return new Date(parseInt(parts[2], 10), parseInt(parts[1], 10) - 1, parseInt(parts[0], 10));
        },

        formatDateDMY: function (dateObj) {
            if (!dateObj) return '';
            var d = ('0' + dateObj.getDate()).slice(-2);
            var m = ('0' + (dateObj.getMonth() + 1)).slice(-2);
            var y = dateObj.getFullYear();
            return d + '.' + m + '.' + y;
        }
    };

    $(document).ready(function () {
        HKS.init();
        window.HKS = HKS;
    });

})(window, jQuery);
