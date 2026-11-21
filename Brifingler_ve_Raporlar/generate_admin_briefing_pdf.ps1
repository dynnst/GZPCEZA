[System.Reflection.Assembly]::LoadFrom("C:\Users\fb\source\repos\GZPCEZA\gzpegm\bin\itextsharp.dll") | Out-Null

$outputPdf = "C:\Users\fb\source\repos\GZPCEZA\Brifingler_ve_Raporlar\YILLIK_HARC_VE_CEZA_GUNCELLEME_ADMIN_REHBERI.pdf"

$fontPath = "C:\Windows\Fonts\arial.ttf"
$fontBoldPath = "C:\Windows\Fonts\arialbd.ttf"
$baseFont = [iTextSharp.text.pdf.BaseFont]::CreateFont($fontPath, [iTextSharp.text.pdf.BaseFont]::IDENTITY_H, [iTextSharp.text.pdf.BaseFont]::EMBEDDED)
$baseFontBold = [iTextSharp.text.pdf.BaseFont]::CreateFont($fontBoldPath, [iTextSharp.text.pdf.BaseFont]::IDENTITY_H, [iTextSharp.text.pdf.BaseFont]::EMBEDDED)

$cNavy   = New-Object iTextSharp.text.BaseColor(30, 58, 138)
$cBlue   = New-Object iTextSharp.text.BaseColor(2, 132, 199)
$cDark   = New-Object iTextSharp.text.BaseColor(15, 23, 42)
$cGray   = New-Object iTextSharp.text.BaseColor(100, 116, 139)
$cLight  = New-Object iTextSharp.text.BaseColor(241, 245, 249)
$cWhite  = [iTextSharp.text.BaseColor]::WHITE
$cGreen  = New-Object iTextSharp.text.BaseColor(22, 101, 52)
$cGreenBg= New-Object iTextSharp.text.BaseColor(240, 253, 244)
$cYellow = New-Object iTextSharp.text.BaseColor(254, 240, 138)
$cLightBlue = New-Object iTextSharp.text.BaseColor(224, 231, 255)

$fBanner1   = New-Object iTextSharp.text.Font($baseFontBold, 10, [iTextSharp.text.Font]::NORMAL, $cWhite)
$fBanner2   = New-Object iTextSharp.text.Font($baseFont, 8, [iTextSharp.text.Font]::NORMAL, $cLightBlue)
$fBanner3   = New-Object iTextSharp.text.Font($baseFontBold, 11, [iTextSharp.text.Font]::NORMAL, $cYellow)
$fBanner4   = New-Object iTextSharp.text.Font($baseFontBold, 8, [iTextSharp.text.Font]::NORMAL, $cWhite)

$fSecTitle  = New-Object iTextSharp.text.Font($baseFontBold, 10.5, [iTextSharp.text.Font]::NORMAL, $cNavy)
$fSubTitle  = New-Object iTextSharp.text.Font($baseFontBold, 9, [iTextSharp.text.Font]::NORMAL, $cBlue)
$fBody      = New-Object iTextSharp.text.Font($baseFont, 8, [iTextSharp.text.Font]::NORMAL, $cDark)
$fBodyBold  = New-Object iTextSharp.text.Font($baseFontBold, 8, [iTextSharp.text.Font]::NORMAL, $cDark)
$fSmall     = New-Object iTextSharp.text.Font($baseFont, 7, [iTextSharp.text.Font]::NORMAL, $cGray)
$fTableHead = New-Object iTextSharp.text.Font($baseFontBold, 7.5, [iTextSharp.text.Font]::NORMAL, $cWhite)
$fTableCell = New-Object iTextSharp.text.Font($baseFont, 7.5, [iTextSharp.text.Font]::NORMAL, $cDark)
$fTableCellB= New-Object iTextSharp.text.Font($baseFontBold, 7.5, [iTextSharp.text.Font]::NORMAL, $cDark)

$doc = New-Object iTextSharp.text.Document([iTextSharp.text.PageSize]::A4, 30, 30, 30, 30)
$fs = [System.IO.File]::Create($outputPdf)
$writer = [iTextSharp.text.pdf.PdfWriter]::GetInstance($doc, $fs)
$doc.Open()

# 1. Header Banner
$banner = New-Object iTextSharp.text.pdf.PdfPTable(1)
$banner.WidthPercentage = 100
$bCell = New-Object iTextSharp.text.pdf.PdfPCell
$bCell.BackgroundColor = $cNavy
$bCell.Padding = 8
$bCell.HorizontalAlignment = [iTextSharp.text.Element]::ALIGN_CENTER

$p1 = New-Object iTextSharp.text.Paragraph("T.C. İÇİŞLERİ BAKANLIĞI - EMNİYET GENEL MÜDÜRLÜĞÜ", $fBanner1)
$p1.Alignment = [iTextSharp.text.Element]::ALIGN_CENTER
$p2 = New-Object iTextSharp.text.Paragraph("GÖÇMEN KAÇAKÇILIĞIYLA MÜCADELE VE HUDUT KAPILARI DAİRE BAŞKANLIĞI", $fBanner2)
$p2.Alignment = [iTextSharp.text.Element]::ALIGN_CENTER
$p3 = New-Object iTextSharp.text.Paragraph("CEZAM: YILLIK HARÇ, İDARİ CEZA VE ÖZEL KATSAYILAR GÜNCELLEME REHBERİ", $fBanner3)
$p3.Alignment = [iTextSharp.text.Element]::ALIGN_CENTER
$p3.SpacingBefore = 3
$p4 = New-Object iTextSharp.text.Paragraph("SİSTEM YÖNETİCİSİ (ADMIN) STANDART İŞLETİM BRİFİNGİ (SOP-2026-ADM-01)", $fBanner4)
$p4.Alignment = [iTextSharp.text.Element]::ALIGN_CENTER

$bCell.AddElement($p1)
$bCell.AddElement($p2)
$bCell.AddElement($p3)
$bCell.AddElement($p4)
$banner.AddCell($bCell)
$doc.Add($banner)

# Spacer
$sp = New-Object iTextSharp.text.Paragraph(" ", $fSmall)
$doc.Add($sp)

# 2. Metadata Table
$mTable = New-Object iTextSharp.text.pdf.PdfPTable(4)
$mTable.WidthPercentage = 100
$mTable.SetWidths(@(18, 32, 18, 32))

function Add-Meta($lbl, $val) {
    $c1 = New-Object iTextSharp.text.pdf.PdfPCell(New-Object iTextSharp.text.Phrase($lbl, $fBodyBold))
    $c1.BackgroundColor = $cLight
    $c1.Padding = 4
    $c2 = New-Object iTextSharp.text.pdf.PdfPCell(New-Object iTextSharp.text.Phrase($val, $fBody))
    $c2.Padding = 4
    $script:mTable.AddCell($c1)
    $script:mTable.AddCell($c2)
}

Add-Meta "Doküman No:" "BRF-2026-ADM-01"
Add-Meta "Yürürlük Dönemi:" "2026 - 2027 İtibarıyla"
Add-Meta "Hazırlayan Birim:" "CEZAM Proje & Sistem Yöneticisi"
Add-Meta "Hedef Kitle:" "Hudut Kapıları Şube Md. / Admin"
$doc.Add($mTable)

$doc.Add($sp)

# 3. YÖNETİCİ ÖZETİ
$sec1 = New-Object iTextSharp.text.Paragraph("1. YÖNETİCİ ÖZETİ VE MEVZUAT TEMELİ", $fSecTitle)
$sec1.SpacingAfter = 3
$doc.Add($sec1)

$pSumText = "Bu brifing; CEZAM sisteminde vize ve ikamet ihlali yapan yabancılara uygulanan harç, defter bedeli ve idari para cezalarının yasal dayanaklarını, yıllık artış mekanizmalarını ve her takvim yılı başında (örn. 2027) Sistem Yöneticisi (Admin) tarafından yapılması gereken operasyonel adımları açıklamaktadır. Sistem; 492 sayılı Harçlar Kanunu, 210 sayılı Değerli Kağıtlar Kanunu, 6458 sayılı YUKK ve EGM Daire Başkanlığı Genelgelerine tam uyumlu olarak çalışmaktadır."
$pSum = New-Object iTextSharp.text.Paragraph($pSumText, $fBody)
$pSum.SpacingAfter = 5
$doc.Add($pSum)

# 4. MALİ KALEMLER TABLOSU
$sec2 = New-Object iTextSharp.text.Paragraph("2. MALİ KALEMLERİN HUKUKİ VE MATEMATİKSEL ARTIŞ MEKANİZMASI", $fSecTitle)
$sec2.SpacingAfter = 3
$doc.Add($sec2)

$pTable = New-Object iTextSharp.text.pdf.PdfPTable(5)
$pTable.WidthPercentage = 100
$pTable.SetWidths(@(22, 22, 18, 16, 22))

$headers = @("Mali Kalem", "Hukuki Dayanak", "Resmi Belge / Kaynak", "2026 Tutarı", "Artış Mekanizması")
foreach ($h in $headers) {
    $c = New-Object iTextSharp.text.pdf.PdfPCell(New-Object iTextSharp.text.Phrase($h, $fTableHead))
    $c.BackgroundColor = $cNavy
    $c.Padding = 4
    $c.HorizontalAlignment = [iTextSharp.text.Element]::ALIGN_CENTER
    $pTable.AddCell($c)
}

$rows = @(
    @("Tek Giriş Vize Harcı (TGVH)", "492 s. Harçlar K. (6) Tarife", "Harçlar Tebliği (Seri: 98)", "9.376,40 TL", "Cumhurbaşkanı K. veya YDO"),
    @("İkamet İzni Defter Bedeli", "210 s. Değerli Kağıtlar K.", "Muhasebat Tebliği (Sıra: 97)", "964,00 TL", "Yeniden Değerleme Oranı"),
    @("V-137 İdari Para Cezası", "6458 s. YUKK m.102/1-a", "VUK Tebliği & YUKK", "20.605,00 TL", "YDO Oranında Maktu Artış"),
    @("F Grubu 9. Gün Katsayısı", "EGM Genelgesi 2011/68506", "EGM Hudut Cetveli", "467,60 TL", "Harç Artış Oranıyla Ölçeklenir"),
    @("G Grubu Kabahatler Cezası", "5326 s. Kabahatler K. m.32", "Kabahatler Tebliği & YDO", "1.854,00 TL", "YDO Oranında Maktu Artış")
)

foreach ($r in $rows) {
    for ($i = 0; $i -lt 5; $i++) {
        $c = New-Object iTextSharp.text.pdf.PdfPCell(New-Object iTextSharp.text.Phrase($r[$i], $fTableCell))
        $c.Padding = 3.5
        if ($i -eq 3) { 
            $c.HorizontalAlignment = [iTextSharp.text.Element]::ALIGN_RIGHT
            $c.Phrase = New-Object iTextSharp.text.Phrase($r[$i], $fTableCellB)
        }
        $pTable.AddCell($c)
    }
}
$doc.Add($pTable)

$doc.Add($sp)

# 5. ÖZEL GRUPLAR ANALİZİ
$sec3 = New-Object iTextSharp.text.Paragraph("3. ÖZEL ÜLKE GRUPLARI VE FORMÜL ANALİZİ", $fSecTitle)
$sec3.SpacingAfter = 3
$doc.Add($sec3)

$boxTable = New-Object iTextSharp.text.pdf.PdfPTable(2)
$boxTable.WidthPercentage = 100
$boxTable.SetWidths(@(50, 50))

$box1 = New-Object iTextSharp.text.pdf.PdfPCell
$box1.BackgroundColor = $cLight
$box1.Padding = 5
$box1.AddElement((New-Object iTextSharp.text.Paragraph("F GRUBU (Norveç, Sırbistan, Fiji vb.):", $fSubTitle)))
$box1Text = "• 1-9 gün ihlalde: Gün başına kademeli basamak katsayısı uygulanır.`n• 10 gün ve üzeri ihlalde: Günlük artış durur, POLNET tavan harcına (Tek Kat 1.066 TL, Çift Kat 2.132 TL) kilitlenir.`n• 467,60 TL Değeri: 9. günde tavan harca ulaşmayı sağlayan yasal basamak katsayısıdır.`n• 2027 Güncelleme: 467.60 * (1 + Harç Artış Oranı)"
$box1.AddElement((New-Object iTextSharp.text.Paragraph($box1Text, $fTableCell)))
$boxTable.AddCell($box1)

$box2 = New-Object iTextSharp.text.pdf.PdfPCell
$box2.BackgroundColor = $cGreenBg
$box2.Padding = 5
$fGreenTitle = New-Object iTextSharp.text.Font($baseFontBold, 9, [iTextSharp.text.Font]::NORMAL, $cGreen)
$box2.AddElement((New-Object iTextSharp.text.Paragraph("G GRUBU (Azerbaycan, Kazakistan, Özbekistan vb.):", $fGreenTitle)))
$box2Text = "• EGM 04.06.2013 / 41139-5 Genelgesi uyarınca ikamet harcından TAMAMEN MUAFTIRLAR.`n• İhlal süresine bakılmaksızın ikamet harcı 0,00 TL'dir.`n• Yalnızca 5326 s. Kabahatler Kanunu m.32 idari para cezası kesilir (2026 yılı: 1.854,00 TL).`n• 2027 Güncelleme: 1.854 * (1 + YDO)"
$box2.AddElement((New-Object iTextSharp.text.Paragraph($box2Text, $fTableCell)))
$boxTable.AddCell($box2)

$doc.Add($boxTable)

$doc.Add($sp)

# 6. ADIM ADIM YILBAŞI GEÇİŞ REHBERİ (CHECKLIST)
$sec4 = New-Object iTextSharp.text.Paragraph("4. SİSTEM YÖNETİCİSİ (ADMIN) YILBAŞI GEÇİŞ REHBERİ", $fSecTitle)
$sec4.SpacingAfter = 3
$doc.Add($sec4)

$cTable = New-Object iTextSharp.text.pdf.PdfPTable(4)
$cTable.WidthPercentage = 100
$cTable.SetWidths(@(8, 22, 28, 42))

$hCheck = @("Sıra", "İşlem Adımı", "Erişim Ekranı (URL)", "Yapılacak İşlem ve Girdi")
foreach ($h in $hCheck) {
    $c = New-Object iTextSharp.text.pdf.PdfPCell(New-Object iTextSharp.text.Phrase($h, $fTableHead))
    $c.BackgroundColor = $cNavy
    $c.Padding = 4
    $c.HorizontalAlignment = [iTextSharp.text.Element]::ALIGN_CENTER
    $cTable.AddCell($c)
}

$steps = @(
    @("1", "Resmi Tebliğ Temini", "Resmi Gazete / EGM", "25-31 Aralık'ta yayımlanan Harçlar, Değerli Kağıtlar ve VUK tebliğlerini temin ediniz."),
    @("2", "TGVH Eklenmesi", "/tgvh", "Harçlar -> TGVH menüsünden 'Yeni TGVH Ekle' formuna Yıl (örn: 2027) ve yeni tutarı girip kaydediniz."),
    @("3", "Defter Bedeli", "/Defter", "Harçlar -> Defter menüsünden yeni yılın değerli kağıt defter bedelini yazıp 'Güncelle' butonuna basınız."),
    @("4", "V-137 Ceza Tutarı", "/CezaParametre (Sekme 1)", "Sistem -> Ceza Parametreleri ekranında V137_IDARI_CEZA değerini yeni YDO tutarıyla güncelleyiniz."),
    @("5", "F Grubu Katsayısı", "/CezaParametre (Sekme 1)", "FGRUBU_DAY9_KAT değerini yeni harç oranına göre hesaplayıp (veya cetvelden alıp) kaydediniz."),
    @("6", "Kabahatler m.32", "/CezaParametre (Sekme 1)", "KABAHATLER_M32_CEZA değerini yeni YDO'ya göre güncelleyip kaydediniz."),
    @("7", "Genelge Ülkeleri", "/CezaParametre (Sekme 2)", "Daire Başkanlığınca F veya G grubuna yeni eklenen/çıkarılan ülke varsa listeyi güncelleyiniz."),
    @("8", "Sistem Testi", "/Home/Index", "Standart, F Grubu, G Grubu ve V-137 senaryolarını test ederek doğru tutarları teyit ediniz.")
)

foreach ($s in $steps) {
    for ($i = 0; $i -lt 4; $i++) {
        $c = New-Object iTextSharp.text.pdf.PdfPCell(New-Object iTextSharp.text.Phrase($s[$i], $fTableCell))
        $c.Padding = 3.5
        if ($i -eq 0) { 
            $c.HorizontalAlignment = [iTextSharp.text.Element]::ALIGN_CENTER
            $c.Phrase = New-Object iTextSharp.text.Phrase($s[$i], $fTableCellB)
        }
        if ($i -eq 2) { $c.Phrase = New-Object iTextSharp.text.Phrase($s[$i], $fTableCellB) }
        $cTable.AddCell($c)
    }
}
$doc.Add($cTable)

$doc.Add($sp)

# 7. DÖRT PİLOT TEST SENARYOSU
$sec5 = New-Object iTextSharp.text.Paragraph("5. PİLOT DOĞRULAMA TESTLERİ (CANLIYA ALMADAN ÖNCE YAPILACAK)", $fSecTitle)
$sec5.SpacingAfter = 3
$doc.Add($sec5)

$tTable = New-Object iTextSharp.text.pdf.PdfPTable(3)
$tTable.WidthPercentage = 100
$tTable.SetWidths(@(25, 33, 42))

$hTest = @("Test Senaryosu", "Test Verileri", "Beklenen Doğrulama Sonucu")
foreach ($h in $hTest) {
    $c = New-Object iTextSharp.text.pdf.PdfPCell(New-Object iTextSharp.text.Phrase($h, $fTableHead))
    $c.BackgroundColor = $cBlue
    $c.Padding = 4
    $c.HorizontalAlignment = [iTextSharp.text.Element]::ALIGN_CENTER
    $tTable.AddCell($c)
}

$tests = @(
    @("1. Standart Ülke Kontrolü", "Uyruk: Almanya | İhlal: 15 Gün", "Yeni TGVH tabanına göre 1 aylık ikamet harcı + yeni Defter bedeli eksiksiz hesaplanmalıdır."),
    @("2. F Grubu Kademeli Artış", "Uyruk: Norveç | İhlal: 3 Gün & 12 Gün", "3 gün için günlük katsayı çarpımı; 12 gün için POLNET tavan harcına kilitlenmelidir."),
    @("3. G Grubu Muafiyet", "Uyruk: Azerbaycan | İhlal: 25 Gün", "İkamet harcı 0,00 TL çıkmalı; yalnızca Kabahatler Kanunu m.32 idari para cezası kesilmelidir."),
    @("4. V-137 Tahditli İhlal", "Herhangi Uyruk | İhlal: 400 Gün", "Kırmızı renkli V-137 tahdit uyarısı çıkmalı ve yeni maktu ceza tutarı toplam cezaya eklenmelidir.")
)

foreach ($t in $tests) {
    for ($i = 0; $i -lt 3; $i++) {
        $c = New-Object iTextSharp.text.pdf.PdfPCell(New-Object iTextSharp.text.Phrase($t[$i], $fTableCell))
        $c.Padding = 3.5
        if ($i -eq 0) { $c.Phrase = New-Object iTextSharp.text.Phrase($t[$i], $fTableCellB) }
        $tTable.AddCell($c)
    }
}
$doc.Add($tTable)

$doc.Add($sp)

# 8. TEKNİK SİGORTA VE FOOTER
$sec6 = New-Object iTextSharp.text.Paragraph("6. TEKNİK MİMARİ, ÖNBELLEK VE SİGORTA KORUMASI", $fSecTitle)
$sec6.SpacingAfter = 3
$doc.Add($sec6)

$pTechText = "• Otomatik Önbellek Temizleme: Ceza parametreleri güncellendiğinde sistem belleği otomatik sıfırlanır; IIS uygulama havuzunu yeniden başlatmaya gerek kalmaz.`n• Sert Kodlu Güvenlik Fallback: Veritabanı bağlantısı kopsa veya parametre tablosu hasar görse dahi CezaParametreService içerisindeki statik yedek değerler devreye girer; hudut kapısında hesaplama ASLA durmaz.`n• SQL Kurulum / Taşıma Betiği: Canlı sunucuya geçişte sql/14_CREATE_CEZA_PARAMETRE_VE_GENELGE_SINIFLANDIRMA.sql betiği ile tüm yapı ve ilk veriler 5 saniyede oluşturulabilir."
$pTech = New-Object iTextSharp.text.Paragraph($pTechText, $fBody)
$pTech.SpacingAfter = 6
$doc.Add($pTech)

$footerTable = New-Object iTextSharp.text.pdf.PdfPTable(1)
$footerTable.WidthPercentage = 100
$fCell = New-Object iTextSharp.text.pdf.PdfPCell
$fCell.BackgroundColor = $cLight
$fCell.Padding = 5
$fCell.HorizontalAlignment = [iTextSharp.text.Element]::ALIGN_CENTER
$pFoot = New-Object iTextSharp.text.Paragraph("CEZAM Sistemi Mevzuat ve Yönetici Brifingi - EGM Hudut Kapıları Bilgi İşlem ve Operasyon Standardı - 2026", $fSmall)
$pFoot.Alignment = [iTextSharp.text.Element]::ALIGN_CENTER
$fCell.AddElement($pFoot)
$footerTable.AddCell($fCell)
$doc.Add($footerTable)

$doc.Close()
$fs.Close()
Write-Host "PDF Başarıyla Üretildi: $outputPdf"
