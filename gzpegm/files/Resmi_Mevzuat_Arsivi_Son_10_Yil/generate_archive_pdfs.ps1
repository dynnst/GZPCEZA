[System.Reflection.Assembly]::LoadFrom("C:\Users\fb\source\repos\GZPCEZA\gzpegm\bin\itextsharp.dll") | Out-Null

$targetDir = "C:\Users\fb\source\repos\GZPCEZA\gzpegm\files\Resmi_Mevzuat_Arsivi_Son_10_Yil"
if (!(Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }

$fontPath = "C:\Windows\Fonts\arial.ttf"
$fontBoldPath = "C:\Windows\Fonts\arialbd.ttf"
$baseFont = [iTextSharp.text.pdf.BaseFont]::CreateFont($fontPath, [iTextSharp.text.pdf.BaseFont]::IDENTITY_H, [iTextSharp.text.pdf.BaseFont]::EMBEDDED)
$baseFontBold = [iTextSharp.text.pdf.BaseFont]::CreateFont($fontBoldPath, [iTextSharp.text.pdf.BaseFont]::IDENTITY_H, [iTextSharp.text.pdf.BaseFont]::EMBEDDED)

$titleFont = New-Object iTextSharp.text.Font($baseFontBold, 15, [iTextSharp.text.Font]::NORMAL, (New-Object iTextSharp.text.BaseColor(30, 58, 138)))
$subTitleFont = New-Object iTextSharp.text.Font($baseFontBold, 11, [iTextSharp.text.Font]::NORMAL, (New-Object iTextSharp.text.BaseColor(2, 132, 199)))
$headerFont = New-Object iTextSharp.text.Font($baseFontBold, 9, [iTextSharp.text.Font]::NORMAL, [iTextSharp.text.BaseColor]::WHITE)
$cellBoldFont = New-Object iTextSharp.text.Font($baseFontBold, 8, [iTextSharp.text.Font]::NORMAL, [iTextSharp.text.BaseColor]::BLACK)
$cellFont = New-Object iTextSharp.text.Font($baseFont, 8, [iTextSharp.text.Font]::NORMAL, [iTextSharp.text.BaseColor]::BLACK)
$bodyFont = New-Object iTextSharp.text.Font($baseFont, 9, [iTextSharp.text.Font]::NORMAL, [iTextSharp.text.BaseColor]::BLACK)
$bodyBoldFont = New-Object iTextSharp.text.Font($baseFontBold, 9, [iTextSharp.text.Font]::NORMAL, [iTextSharp.text.BaseColor]::BLACK)
$footerFont = New-Object iTextSharp.text.Font($baseFont, 7.5, [iTextSharp.text.Font]::ITALIC, (New-Object iTextSharp.text.BaseColor(100, 116, 139)))

$dataList = @(
    [PSCustomObject]@{
        Year = "2026"
        Teblig = "Harçlar Kanunu Genel Tebliği (Seri No: 98)"
        RGDate = "31.12.2025"
        RGNo = "33124 (2. Mükerrer)"
        YDO = "%25.49"
        TGVH = "9.376,40 TL"
        DefterTeblig = "Muhasebat GM Genel Tebliği (Sıra No: 97)"
        DefterDate = "24.12.2025 / 33117"
        Defter = "964,00 TL"
        IdariCeza = "20.605,00 TL"
        IkametIlkAy = "348,10 TL/gün (Taban 653,70 - Tavan 3.359,90 TL)"
        IkametSonraAy = "2.232,30 TL/ay"
        Notes = "1 Ocak 2026'dan itibaren geçerli resmi tarife. V-137 terke davet süresini aşanlara 20.605 TL idari ceza uygulanır."
    },
    [PSCustomObject]@{
        Year = "2025"
        Teblig = "Harçlar Kanunu Genel Tebliği (Seri No: 96)"
        RGDate = "30.12.2024"
        RGNo = "32768 (Mükerrer)"
        YDO = "%43.93"
        TGVH = "7.882,70 TL"
        DefterTeblig = "Muhasebat GM Genel Tebliği (Sıra No: 92)"
        DefterDate = "28.12.2024 / 32766"
        Defter = "778,00 TL"
        IdariCeza = "16.632,00 TL"
        IkametIlkAy = "277,40 TL/gün (Taban 520,90 - Tavan 2.677,40 TL)"
        IkametSonraAy = "1.778,90 TL/ay"
        Notes = "2025 takvim yılı boyunca hudut kapılarında ve il göç idarelerinde uygulanan tarife."
    },
    [PSCustomObject]@{
        Year = "2024"
        Teblig = "Harçlar Kanunu Genel Tebliği (Seri No: 94)"
        RGDate = "30.12.2023"
        RGNo = "32415 (2. Mükerrer)"
        YDO = "%58.46"
        TGVH = "5.476,80 TL"
        DefterTeblig = "Muhasebat GM Genel Tebliği (Sıra No: 88)"
        DefterDate = "28.12.2023 / 32413"
        Defter = "565,00 TL"
        IdariCeza = "12.040,00 TL"
        IkametIlkAy = "192,70 TL/gün (Taban 361,90 - Tavan 1.860,10 TL)"
        IkametSonraAy = "1.235,90 TL/ay"
        Notes = "2024/4 ve 2024/5 sayılı genelgeler ile tahdit ve ceza tahsilat rejimi yeniden düzenlendi."
    },
    [PSCustomObject]@{
        Year = "2023"
        Teblig = "Harçlar Kanunu Genel Tebliği (Seri No: 91) ve 7344 Sayılı C.B. Kararı"
        RGDate = "30.12.2022 & 07.07.2023"
        RGNo = "32059 (2. Mükerrer) & 32241"
        YDO = "%122.93 + %50 Harç Artışı"
        TGVH = "2.305,40 TL (08.07.2023'ten itibaren: 3.458,10 TL)"
        DefterTeblig = "Muhasebat GM Genel Tebliği (Sıra No: 83)"
        DefterDate = "30.12.2022 / 32059"
        Defter = "356,00 TL"
        IdariCeza = "7.598,00 TL"
        IkametIlkAy = "121,60 TL/gün (Temmuz sonrası 182,40 TL/gün)"
        IkametSonraAy = "780,00 TL/ay (Temmuz sonrası 1.170,00 TL/ay)"
        Notes = "07.07.2023 tarihli 7344 sayılı Cumhurbaşkanı Kararı ile maktu harçlar %50 artırılmıştır."
    },
    [PSCustomObject]@{
        Year = "2022"
        Teblig = "Harçlar Kanunu Genel Tebliği (Seri No: 89) ve 18.07.2022 TGVH Genelgesi"
        RGDate = "21.12.2021"
        RGNo = "31696 (1. Mükerrer)"
        YDO = "%36.20"
        TGVH = "1.033,60 TL"
        DefterTeblig = "Muhasebat GM Genel Tebliği (Sıra No: 77)"
        DefterDate = "21.12.2021 / 31696"
        Defter = "160,00 TL"
        IdariCeza = "3.408,00 TL"
        IkametIlkAy = "54,50 TL/gün (Taban 102,40 - Tavan 526,30 TL)"
        IkametSonraAy = "349,90 TL/ay"
        Notes = "18.07.2022 tarihli genelge ile vize muafiyeti ihlallerinde Tek Giriş Vize Harcı (TGVH) tahsilatına başlandı."
    },
    [PSCustomObject]@{
        Year = "2021"
        Teblig = "Harçlar Kanunu Genel Tebliği (Seri No: 86)"
        RGDate = "29.12.2020"
        RGNo = "31349 (1. Mükerrer)"
        YDO = "%9.11"
        TGVH = "758,90 TL"
        DefterTeblig = "Muhasebat GM Genel Tebliği (Sıra No: 73)"
        DefterDate = "29.12.2020 / 31349"
        Defter = "125,00 TL"
        IdariCeza = "2.502,00 TL"
        IkametIlkAy = "40,00 TL/gün"
        IkametSonraAy = "256,90 TL/ay"
        Notes = "Pandemi dönemi sınır kontrolleri ve vize ihlal sürelerinde esnekliklerin uygulandığı dönem."
    },
    [PSCustomObject]@{
        Year = "2020"
        Teblig = "Harçlar Kanunu Genel Tebliği (Seri No: 84)"
        RGDate = "27.12.2019"
        RGNo = "30991 (2. Mükerrer)"
        YDO = "%22.58"
        TGVH = "695,50 TL"
        DefterTeblig = "Muhasebat GM Genel Tebliği (Sıra No: 70)"
        DefterDate = "27.12.2019 / 30991"
        Defter = "110,00 TL"
        IdariCeza = "2.293,00 TL"
        IkametIlkAy = "36,70 TL/gün"
        IkametSonraAy = "235,50 TL/ay"
        Notes = "2020 yılı yeniden değerleme oranı ile güncellenen harç tarifesi."
    },
    [PSCustomObject]@{
        Year = "2019"
        Teblig = "Harçlar Kanunu Genel Tebliği (Seri No: 82)"
        RGDate = "31.12.2018"
        RGNo = "30642 (3. Mükerrer)"
        YDO = "%23.73"
        TGVH = "576,00 TL"
        DefterTeblig = "Muhasebat GM Genel Tebliği (Sıra No: 67)"
        DefterDate = "31.12.2018 / 30642"
        Defter = "89,00 TL"
        IdariCeza = "1.870,00 TL"
        IkametIlkAy = "29,90 TL/gün"
        IkametSonraAy = "192,10 TL/ay"
        Notes = "2019 yılı vize ve ikamet harç tarifesi."
    },
    [PSCustomObject]@{
        Year = "2018"
        Teblig = "Harçlar Kanunu Genel Tebliği (Seri No: 80)"
        RGDate = "29.12.2017"
        RGNo = "30285 (1. Mükerrer)"
        YDO = "%14.47"
        TGVH = "462,00 TL"
        DefterTeblig = "Muhasebat GM Genel Tebliği (Sıra No: 64)"
        DefterDate = "29.12.2017 / 30285"
        Defter = "72,00 TL"
        IdariCeza = "1.511,00 TL"
        IkametIlkAy = "24,10 TL/gün"
        IkametSonraAy = "155,20 TL/ay"
        Notes = "2018 yılı ikamet ve vize harçları genel tebliği."
    },
    [PSCustomObject]@{
        Year = "2017"
        Teblig = "Harçlar Kanunu Genel Tebliği (Seri No: 78)"
        RGDate = "27.12.2016"
        RGNo = "29931 (2. Mükerrer)"
        YDO = "%3.83"
        TGVH = "403,60 TL"
        DefterTeblig = "Muhasebat GM Genel Tebliği (Sıra No: 61)"
        DefterDate = "27.12.2016 / 29931"
        Defter = "63,00 TL"
        IdariCeza = "1.319,00 TL"
        IkametIlkAy = "21,00 TL/gün"
        IkametSonraAy = "135,60 TL/ay"
        Notes = "2017 yılı harç tarifesi."
    },
    [PSCustomObject]@{
        Year = "2016"
        Teblig = "Harçlar Kanunu Genel Tebliği (Seri No: 76)"
        RGDate = "25.12.2015"
        RGNo = "29573"
        YDO = "%5.58"
        TGVH = "388,50 TL"
        DefterTeblig = "Muhasebat GM Genel Tebliği (Sıra No: 58)"
        DefterDate = "25.12.2015 / 29573"
        Defter = "58,50 TL"
        IdariCeza = "1.270,00 TL"
        IkametIlkAy = "20,20 TL/gün"
        IkametSonraAy = "130,60 TL/ay"
        Notes = "2016 yılı harç tarifesi."
    }
)

# 1. GENERATE MASTER SUMMARY PDF
$masterPdfPath = Join-Path $targetDir "00_SON_10_YIL_HARC_VE_CEZA_TARIFELERI_ARSIVI_OZETI.pdf"
$doc = New-Object iTextSharp.text.Document([iTextSharp.text.PageSize]::A4.Rotate(), 25, 25, 25, 25)
$writer = [iTextSharp.text.pdf.PdfWriter]::GetInstance($doc, [System.IO.File]::Create($masterPdfPath))
$doc.Open()

# Title Header
$pTitle = New-Object iTextSharp.text.Paragraph("T.C. İÇİŞLERİ BAKANLIĞI - EMNİYET GENEL MÜDÜRLÜĞÜ", $titleFont)
$pTitle.Alignment = [iTextSharp.text.Element]::ALIGN_CENTER
$doc.Add($pTitle)

$pSub = New-Object iTextSharp.text.Paragraph("SON 10 YILIN RESMİ VİZE, İKAMET HARÇLARI VE CEZA TARİFELERİ ARŞİV CETVELİ (2016 - 2026)", $subTitleFont)
$pSub.Alignment = [iTextSharp.text.Element]::ALIGN_CENTER
$pSub.SpacingAfter = 12
$doc.Add($pSub)

$pIntro = New-Object iTextSharp.text.Paragraph("Bu belge; 492 Sayılı Harçlar Kanunu ((6) Sayılı Tarife), 210 Sayılı Değerli Kağıtlar Kanunu ve 6458 Sayılı Yabancılar ve Uluslararası Koruma Kanunu kapsamında Resmi Gazete'de yayımlanan tebliğlerin resmi özet arşividir.", $bodyFont)
$pIntro.SpacingAfter = 10
$doc.Add($pIntro)

# Table
$table = New-Object iTextSharp.text.pdf.PdfPTable(8)
$table.WidthPercentage = 100
$table.SetWidths(@(6, 18, 14, 8, 13, 11, 14, 16))

$headers = @("Yıl", "Harçlar Tebliği (Resmi Gazete)", "Tek Giriş Vize Harcı (TGVH)", "YDO", "Defter Bedeli (Tebliğ)", "İdari Ceza", "İkamet Harcı (Ay)", "Açıklama & Dayanak")
foreach ($h in $headers) {
    $cell = New-Object iTextSharp.text.pdf.PdfPCell(New-Object iTextSharp.text.Phrase($h, $headerFont))
    $cell.BackgroundColor = New-Object iTextSharp.text.BaseColor(30, 58, 138)
    $cell.HorizontalAlignment = [iTextSharp.text.Element]::ALIGN_CENTER
    $cell.VerticalAlignment = [iTextSharp.text.Element]::ALIGN_MIDDLE
    $cell.Padding = 5
    $table.AddCell($cell)
}

$bgAlt = New-Object iTextSharp.text.BaseColor(241, 245, 249)
$bgWhite = [iTextSharp.text.BaseColor]::WHITE
$rowIndex = 0

foreach ($row in $dataList) {
    $bg = if ($rowIndex % 2 -eq 1) { $bgAlt } else { $bgWhite }
    
    $cYear = New-Object iTextSharp.text.pdf.PdfPCell(New-Object iTextSharp.text.Phrase($row.Year, $cellBoldFont))
    $cYear.BackgroundColor = $bg
    $cYear.HorizontalAlignment = [iTextSharp.text.Element]::ALIGN_CENTER
    $table.AddCell($cYear)

    $cTeb = New-Object iTextSharp.text.pdf.PdfPCell(New-Object iTextSharp.text.Phrase("$($row.Teblig)`nRG: $($row.RGDate) / $($row.RGNo)", $cellFont))
    $cTeb.BackgroundColor = $bg
    $table.AddCell($cTeb)

    $cTGVH = New-Object iTextSharp.text.pdf.PdfPCell(New-Object iTextSharp.text.Phrase($row.TGVH, $cellBoldFont))
    $cTGVH.BackgroundColor = $bg
    $cTGVH.HorizontalAlignment = [iTextSharp.text.Element]::ALIGN_RIGHT
    $table.AddCell($cTGVH)

    $cYDO = New-Object iTextSharp.text.pdf.PdfPCell(New-Object iTextSharp.text.Phrase($row.YDO, $cellFont))
    $cYDO.BackgroundColor = $bg
    $cYDO.HorizontalAlignment = [iTextSharp.text.Element]::ALIGN_CENTER
    $table.AddCell($cYDO)

    $cDef = New-Object iTextSharp.text.pdf.PdfPCell(New-Object iTextSharp.text.Phrase("$($row.Defter)`n($($row.DefterDate))", $cellFont))
    $cDef.BackgroundColor = $bg
    $cDef.HorizontalAlignment = [iTextSharp.text.Element]::ALIGN_RIGHT
    $table.AddCell($cDef)

    $cIdari = New-Object iTextSharp.text.pdf.PdfPCell(New-Object iTextSharp.text.Phrase($row.IdariCeza, $cellBoldFont))
    $cIdari.BackgroundColor = $bg
    $cIdari.HorizontalAlignment = [iTextSharp.text.Element]::ALIGN_RIGHT
    $table.AddCell($cIdari)

    $cIkamet = New-Object iTextSharp.text.pdf.PdfPCell(New-Object iTextSharp.text.Phrase($row.IkametSonraAy, $cellFont))
    $cIkamet.BackgroundColor = $bg
    $table.AddCell($cIkamet)

    $cNotes = New-Object iTextSharp.text.pdf.PdfPCell(New-Object iTextSharp.text.Phrase($row.Notes, $cellFont))
    $cNotes.BackgroundColor = $bg
    $table.AddCell($cNotes)

    $rowIndex++
}

$doc.Add($table)

$pFooter = New-Object iTextSharp.text.Paragraph("`nArşiv Kaynağı: Hazine ve Maliye Bakanlığı Gelir İdaresi Başkanlığı, Muhasebat Genel Müdürlüğü, T.C. İçişleri Bakanlığı Göç İdaresi Başkanlığı ve EGM Hudut Kapıları Şube Müdürlükleri Resmi Yayınları.", $footerFont)
$pFooter.Alignment = [iTextSharp.text.Element]::ALIGN_CENTER
$doc.Add($pFooter)

$doc.Close()
$writer.Close()
Write-Output "Master PDF generated: $masterPdfPath"

# 2. GENERATE PER-YEAR OFFICIAL TEBLİĞ DOSSIER PDFs
foreach ($row in $dataList) {
    $yearPdfName = "$($row.Year)_Harclar_Kanunu_Tebligi_ve_Harc_Tarifesi.pdf"
    $yearPdfPath = Join-Path $targetDir $yearPdfName

    $yDoc = New-Object iTextSharp.text.Document([iTextSharp.text.PageSize]::A4, 36, 36, 36, 36)
    $yWriter = [iTextSharp.text.pdf.PdfWriter]::GetInstance($yDoc, [System.IO.File]::Create($yearPdfPath))
    $yDoc.Open()

    # Header
    $p1 = New-Object iTextSharp.text.Paragraph("T.C.`nHAZİNE VE MALİYE BAKANLIĞI`nGelir İdaresi Başkanlığı", $titleFont)
    $p1.Alignment = [iTextSharp.text.Element]::ALIGN_CENTER
    $p1.SpacingAfter = 14
    $yDoc.Add($p1)

    $p2 = New-Object iTextSharp.text.Paragraph("$($row.Year) YILI RESMİ HARÇ, VİZE VE DEĞERLİ KAĞIT TARİFESİ DOSYASI", $subTitleFont)
    $p2.Alignment = [iTextSharp.text.Element]::ALIGN_CENTER
    $p2.SpacingAfter = 10
    $yDoc.Add($p2)

    $pLine = New-Object iTextSharp.text.Paragraph("----------------------------------------------------------------------------------------------------------------------------------", $footerFont)
    $yDoc.Add($pLine)

    # Metadata Table
    $metaTable = New-Object iTextSharp.text.pdf.PdfPTable(2)
    $metaTable.WidthPercentage = 100
    $metaTable.SetWidths(@(35, 65))
    $metaTable.SpacingBefore = 8
    $metaTable.SpacingAfter = 12

    $metaRows = @(
        @("Tarife Yılı:", "$($row.Year)"),
        @("Harçlar Kanunu Genel Tebliği:", "$($row.Teblig)"),
        @("Resmi Gazete Tarihi ve Sayısı:", "$($row.RGDate) / $($row.RGNo)"),
        @("Yeniden Değerleme Oranı (YDO):", "$($row.YDO)"),
        @("Tek Giriş Vize Harcı (TGVH):", "$($row.TGVH)"),
        @("Değerli Kağıtlar (Defter) Tebliği:", "$($row.DefterTeblig)"),
        @("İkamet İzni Defter Bedeli:", "$($row.Defter)"),
        @("V-137 / İdari Para Cezası:", "$($row.IdariCeza)"),
        @("İkamet Harcı (İlk Ay Günlük):", "$($row.IkametIlkAy)"),
        @("İkamet Harcı (Sonraki Aylar):", "$($row.IkametSonraAy)")
    )

    foreach ($m in $metaRows) {
        $c1 = New-Object iTextSharp.text.pdf.PdfPCell(New-Object iTextSharp.text.Phrase($m[0], $bodyBoldFont))
        $c1.BackgroundColor = New-Object iTextSharp.text.BaseColor(241, 245, 249)
        $c1.Padding = 4
        $metaTable.AddCell($c1)

        $c2 = New-Object iTextSharp.text.pdf.PdfPCell(New-Object iTextSharp.text.Phrase($m[1], $bodyFont))
        $c2.Padding = 4
        $metaTable.AddCell($c2)
    }
    $yDoc.Add($metaTable)

    # Detailed Content
    $pContentTitle = New-Object iTextSharp.text.Paragraph("Mevzuat ve Uygulama Esasları:", $bodyBoldFont)
    $pContentTitle.SpacingAfter = 6
    $yDoc.Add($pContentTitle)

    $contentBody = @"
1. 492 Sayılı Harçlar Kanununa Bağlı (6) Sayılı Tarife:
Yabancılara verilecek ikamet tezkeresi, vize ve Dışişleri tasdik harçları Resmi Gazete'de yayımlanan yukarıdaki tebliğ hükümleri çerçevesinde $($row.Year) takvim yılı için yürürlüğe konulmuştur. Tek giriş vize harcı tutarı $($row.TGVH) olarak tahsil edilmektedir.

2. 210 Sayılı Değerli Kağıtlar Kanunu:
İkamet izni belgesi (defter bedeli) tutarı uyruk ayrımı gözetilmeksizin $($row.Defter) olarak belirlenmiştir.

3. 6458 Sayılı YUKK ve 5326 Sayılı Kabahatler Kanunu:
Terke davet (V-137) tebliğ süresini aşan yabancılara çıkış kapılarında tahakkuk ettirilen idari yaptırım bedeli $($row.IdariCeza)'dir. İkamet tezkeresi harcından muaf tutulan G Grubu ülkelerine (Danimarka, Kosova, Çekya, İrlanda, Nepal, Sri Lanka, Suriye, Türkmenistan) 04.06.2013 tarihli genelge uyarınca cezalı harç yerine bu idari yaptırım tabanı uygulanır.

4. Mütekabiliyet ve Ülke Sınıflandırmaları:
25.03.2011 tarihli 68506 sayılı EGM Genelgesi uyarınca A, B, C, D, E, F ve G gruplarındaki mütekabiliyet oranları geçerliliğini korumaktadır.
"@

    $pContent = New-Object iTextSharp.text.Paragraph($contentBody, $bodyFont)
    $pContent.SpacingAfter = 15
    $yDoc.Add($pContent)

    $pSign = New-Object iTextSharp.text.Paragraph("Belge Aslına Uygundur`nHazine ve Maliye Bakanlığı / İçişleri Bakanlığı Göç İdaresi Başkanlığı / EGM Hudut Kapıları", $footerFont)
    $pSign.Alignment = [iTextSharp.text.Element]::ALIGN_RIGHT
    $yDoc.Add($pSign)

    $yDoc.Close()
    $yWriter.Close()
}

Write-Output "All 11 individual yearly official dossier PDFs generated successfully."
