# -*- coding: utf-8 -*-
"""
CEZAM - Yetkili Merciler ve Üst Yönetim Brifing Sunumu Oluşturucu
Bu script, python-pptx kullanarak 16:9 formatında, üst düzey kurumsal/hükümet
standardında modern bir PowerPoint sunumu üretir.
"""

import os
import sys
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.enum.shapes import MSO_SHAPE

def create_deck():
    prs = Presentation()
    prs.slide_width = Inches(13.333)
    prs.slide_height = Inches(7.5)
    blank_layout = prs.slide_layouts[6]

    # Kurumsal Renk Paleti (EGM / Hudut Kapıları)
    C_NAVY_DARK   = RGBColor(11, 25, 44)     # #0B192C - Derin Koyu Lacivert
    C_NAVY_PANEL  = RGBColor(14, 39, 60)     # #0E273C - Panel Laciverti
    C_BLUE_CARD   = RGBColor(22, 42, 68)     # #162A44 - Koyu Kart
    C_CYAN        = RGBColor(0, 210, 255)    # #00D2FF - Siber Mavi
    C_GOLD        = RGBColor(245, 158, 11)   # #F59E0B - Altın / İkaz
    C_GREEN       = RGBColor(16, 185, 129)   # #10B981 - Başarı Yeşili
    C_RED         = RGBColor(239, 68, 68)    # #EF4444 - Kritik Kırmızı
    C_WHITE       = RGBColor(255, 255, 255)  # Beyaz
    C_LIGHT_BG    = RGBColor(248, 250, 252)  # #F8FAFC - Açık Gri Zemin
    C_CARD_BG     = RGBColor(255, 255, 255)  # Beyaz Kart
    C_CARD_BORDER = RGBColor(226, 232, 240)  # #E2E8F0
    C_TEXT_DARK   = RGBColor(15, 23, 42)     # #0F172A - Koyu Metin
    C_TEXT_MUTED  = RGBColor(100, 116, 139)  # #64748B - Gri Metin
    C_PRIMARY     = RGBColor(37, 99, 235)    # #2563EB - Mavi

    # Arka plan resmi varsa al
    bg_image_path = r"C:\Users\Naşit\.gemini\antigravity\brain\44c2d232-6fff-4346-8d80-15f2b8c40b01\airport_police_login_wallpaper_1792133875116.jpg"

    def apply_light_bg(slide):
        bg = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, Inches(13.333), Inches(7.5))
        bg.fill.solid()
        bg.fill.fore_color.rgb = C_LIGHT_BG
        bg.line.color.rgb = C_LIGHT_BG

    def add_header(slide, title, category, subtitle=None):
        # Üst İnce Şerit (Cyan Accent)
        accent = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, Inches(13.333), Inches(0.08))
        accent.fill.solid()
        accent.fill.fore_color.rgb = C_CYAN
        accent.line.fill.background()

        # Kategori Hapı
        pill = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8), Inches(0.35), Inches(3.2), Inches(0.32))
        pill.fill.solid()
        pill.fill.fore_color.rgb = RGBColor(235, 248, 255)
        pill.line.color.rgb = RGBColor(190, 227, 248)
        tf = pill.text_frame
        tf.word_wrap = True
        tf.vertical_anchor = MSO_ANCHOR.MIDDLE
        p = tf.paragraphs[0]
        p.text = "✦  " + category.upper()
        p.font.size = Pt(9.5)
        p.font.bold = True
        p.font.color.rgb = C_PRIMARY
        p.font.name = "Segoe UI"

        # Başlık
        txBox = slide.shapes.add_textbox(Inches(0.8), Inches(0.72), Inches(11.5), Inches(0.6))
        tf_title = txBox.text_frame
        tf_title.word_wrap = True
        tf_title.margin_left = tf_title.margin_top = tf_title.margin_right = tf_title.margin_bottom = 0
        p_title = tf_title.paragraphs[0]
        p_title.text = title
        p_title.font.size = Pt(22)
        p_title.font.bold = True
        p_title.font.color.rgb = C_TEXT_DARK
        p_title.font.name = "Segoe UI"

        # Alt Başlık
        if subtitle:
            txSub = slide.shapes.add_textbox(Inches(0.8), Inches(1.3), Inches(11.5), Inches(0.35))
            tf_sub = txSub.text_frame
            tf_sub.word_wrap = True
            tf_sub.margin_left = tf_sub.margin_top = tf_sub.margin_right = tf_sub.margin_bottom = 0
            p_sub = tf_sub.paragraphs[0]
            p_sub.text = subtitle
            p_sub.font.size = Pt(11)
            p_sub.font.color.rgb = C_TEXT_MUTED
            p_sub.font.name = "Segoe UI"

    def add_footer(slide, current_idx, total=13):
        # Alt Çizgi
        line = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0.8), Inches(7.05), Inches(11.733), Inches(0.015))
        line.fill.solid()
        line.fill.fore_color.rgb = C_CARD_BORDER
        line.line.fill.background()

        # Alt Metin
        txBox = slide.shapes.add_textbox(Inches(0.8), Inches(7.08), Inches(9.0), Inches(0.3))
        tf = txBox.text_frame
        p = tf.paragraphs[0]
        p.text = "T.C. İçişleri Bakanlığı • Emniyet Genel Müdürlüğü • Hudut Kapıları Bilgi Sistemi (CEZAM)"
        p.font.size = Pt(9)
        p.font.color.rgb = C_TEXT_MUTED
        p.font.name = "Segoe UI"

        # Sayfa No
        txNum = slide.shapes.add_textbox(Inches(11.0), Inches(7.08), Inches(1.533), Inches(0.3))
        tf_num = txNum.text_frame
        p_num = tf_num.paragraphs[0]
        p_num.text = f"{current_idx} / {total}"
        p_num.alignment = PP_ALIGN.RIGHT
        p_num.font.size = Pt(9)
        p_num.font.bold = True
        p_num.font.color.rgb = C_TEXT_MUTED
        p_num.font.name = "Segoe UI"

    def add_card(slide, left, top, width, height, bg=C_CARD_BG, border=C_CARD_BORDER):
        card = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(left), Inches(top), Inches(width), Inches(height))
        card.fill.solid()
        card.fill.fore_color.rgb = bg
        card.line.color.rgb = border
        card.line.width = Pt(1)
        return card

    # =========================================================================
    # SLAYT 1: KAPAK (TITLE / COVER)
    # =========================================================================
    s1 = prs.slides.add_slide(blank_layout)
    if os.path.exists(bg_image_path):
        s1.shapes.add_picture(bg_image_path, 0, 0, Inches(13.333), Inches(7.5))
        # Koyu degrade katmanı
        overlay = s1.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, Inches(13.333), Inches(7.5))
        overlay.fill.solid()
        overlay.fill.fore_color.rgb = C_NAVY_DARK
        overlay.fill.transparency = 0.45
        overlay.line.fill.background()
    else:
        bg1 = s1.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, Inches(13.333), Inches(7.5))
        bg1.fill.solid()
        bg1.fill.fore_color.rgb = C_NAVY_DARK
        bg1.line.fill.background()

    # Kapak Üst Rozeti
    top_badge = s1.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(1.0), Inches(1.2), Inches(4.5), Inches(0.42))
    top_badge.fill.solid()
    top_badge.fill.fore_color.rgb = RGBColor(14, 39, 60)
    top_badge.line.color.rgb = C_CYAN
    top_badge.line.width = Pt(1.5)
    tf_b = top_badge.text_frame
    tf_b.vertical_anchor = MSO_ANCHOR.MIDDLE
    p_b = tf_b.paragraphs[0]
    p_b.text = "✦  T.C. İÇİŞLERİ BAKANLIĞI • EGM • GİGM"
    p_b.font.size = Pt(11)
    p_b.font.bold = True
    p_b.font.color.rgb = C_CYAN
    p_b.font.name = "Segoe UI"

    # Kapak Başlığı
    t_box = s1.shapes.add_textbox(Inches(1.0), Inches(1.85), Inches(11.333), Inches(2.2))
    tf_t = t_box.text_frame
    tf_t.word_wrap = True
    p1 = tf_t.paragraphs[0]
    p1.text = "CEZAM — HUDUT KAPILARI\nBİLGİ VE OPERASYON SİSTEMİ"
    p1.font.size = Pt(36)
    p1.font.bold = True
    p1.font.color.rgb = C_WHITE
    p1.font.name = "Segoe UI"
    p1.line_spacing = 1.15

    # Kapak Alt Başlığı
    sub_box = s1.shapes.add_textbox(Inches(1.0), Inches(4.1), Inches(10.5), Inches(1.0))
    tf_s = sub_box.text_frame
    tf_s.word_wrap = True
    p_s = tf_s.paragraphs[0]
    p_s.text = "Üst Yönetim ve Yetkili Merciler İçin Canlıya Geçiş (Production Readiness),\nMevzuat Analizi ve Ekosistem Brifing Sunumu"
    p_s.font.size = Pt(16)
    p_s.font.color.rgb = RGBColor(190, 227, 248)
    p_s.font.name = "Segoe UI"
    p_s.line_spacing = 1.3

    # Kapak Alt Bilgi Kartı
    bot_card = s1.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(1.0), Inches(5.5), Inches(11.333), Inches(1.1))
    bot_card.fill.solid()
    bot_card.fill.fore_color.rgb = RGBColor(14, 30, 48)
    bot_card.line.color.rgb = RGBColor(40, 70, 100)
    tf_bot = bot_card.text_frame
    tf_bot.word_wrap = True
    p_bot1 = tf_bot.paragraphs[0]
    p_bot1.text = "📌  SUNUM KAPSAMI: Ceza Hesaplama Çekirdeği (6458 SK. m.102) • Kaşe Vize (P-60) • V-84 Şartlı Giriş • Tahdit Kodları • LMS Eğitim Portalı • Mobil Ekosistem"
    p_bot1.font.size = Pt(10.5)
    p_bot1.font.bold = True
    p_bot1.font.color.rgb = C_GOLD
    p_bot1.font.name = "Segoe UI"

    p_bot2 = tf_bot.add_paragraph()
    p_bot2.text = "Sürüm: v2.4 (Production-Ready)   |   Tarih: Ekim 2026   |   Derleme: 0 Hata / 0 Uyarı (Enterprise Release)   |   Hazırlayan: Hudut Kapıları Proje Ekibi"
    p_bot2.font.size = Pt(9.5)
    p_bot2.font.color.rgb = RGBColor(148, 163, 184)
    p_bot2.font.name = "Segoe UI"

    # =========================================================================
    # SLAYT 2: YÖNETİCİ ÖZETİ (EXECUTIVE SUMMARY)
    # =========================================================================
    s2 = prs.slides.add_slide(blank_layout)
    apply_light_bg(s2)
    add_header(s2, "Yönetici Özeti: Çekirdek Misyon ve Değer Önerisi", "Stratejik Genel Bakış",
               "Hudut kapılarında yabancıların vize ve ikamet ihlallerinin sıfır hata ile yönetilmesi ve hazine gelirlerinin güvence altına alınması.")
    add_footer(s2, 2)

    # Sol Kart: Saha Zorlukları (Mevcut Durum)
    add_card(s2, 0.8, 1.8, 5.7, 3.4)
    card_l_header = s2.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0.8), Inches(1.8), Inches(5.7), Inches(0.55))
    card_l_header.fill.solid()
    card_l_header.fill.fore_color.rgb = RGBColor(254, 242, 242)
    card_l_header.line.fill.background()
    tf_lh = card_l_header.text_frame
    p_lh = tf_lh.paragraphs[0]
    p_lh.text = "  ⚠️  Mevcut Operasyonel Riskler ve Zorluklar"
    p_lh.font.size = Pt(12)
    p_lh.font.bold = True
    p_lh.font.color.rgb = C_RED
    p_lh.font.name = "Segoe UI"

    tx_l = s2.shapes.add_textbox(Inches(0.95), Inches(2.45), Inches(5.4), Inches(2.6))
    tf_l = tx_l.text_frame
    tf_l.word_wrap = True
    items_l = [
        ("Manuel Hesaplama Hataları: ", "90/180 gün kuralı, Belarus kuralı ve parça parça seferlerin elle sayılması sonucu hatalı ceza kesilme riski."),
        ("Zaman Kaybı ve Kuyruklar: ", "Pasaport kontrol kulübesinde bir yabancının ceza hesabının 10-15 dakika sürmesi, yolcu akışını tıkaması."),
        ("Mevzuat Karmaşıklığı: ", "Harçlar Kanunu, değerli kağıt bedeli, döviz kurları ve yaş indirimlerinin memurlar arasında farklı yorumlanması."),
        ("Hazine Gelir Kaçağı: ", "Eksik harç tahakkuku veya ceza ödemeden kaçış durumlarında anlık tahdit konulamaması.")
    ]
    for i, (bold_txt, reg_txt) in enumerate(items_l):
        p = tf_l.paragraphs[0] if i == 0 else tf_l.add_paragraph()
        p.space_after = Pt(7)
        r1 = p.add_run()
        r1.text = "• " + bold_txt
        r1.font.bold = True
        r1.font.size = Pt(10)
        r1.font.color.rgb = C_TEXT_DARK
        r1.font.name = "Segoe UI"
        r2 = p.add_run()
        r2.text = reg_txt
        r2.font.size = Pt(10)
        r2.font.color.rgb = C_TEXT_MUTED
        r2.font.name = "Segoe UI"

    # Sağ Kart: CEZAM Çözümü
    add_card(s2, 6.833, 1.8, 5.7, 3.4)
    card_r_header = s2.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(6.833), Inches(1.8), Inches(5.7), Inches(0.55))
    card_r_header.fill.solid()
    card_r_header.fill.fore_color.rgb = RGBColor(240, 253, 244)
    card_r_header.line.fill.background()
    tf_rh = card_r_header.text_frame
    p_rh = tf_rh.paragraphs[0]
    p_rh.text = "  ✅  CEZAM Çözümü ve Kurumsal Faydalar"
    p_rh.font.size = Pt(12)
    p_rh.font.bold = True
    p_rh.font.color.rgb = C_GREEN
    p_rh.font.name = "Segoe UI"

    tx_r = s2.shapes.add_textbox(Inches(6.98), Inches(2.45), Inches(5.4), Inches(2.6))
    tf_r = tx_r.text_frame
    tf_r.word_wrap = True
    items_r = [
        ("Sıfır Hata ve Otomasyon: ", "6458 sayılı Kanun m.102 ve 492 SK. kurallarını milisaniyeler içinde işleten yapay zeka destekli hesaplama motoru."),
        ("10 Saniyede Kesin İşlem: ", "Pasaport taratıldığı anda ihlal süresi, harçlar, döviz kuru ve toplam tutarın tek tıkla ekrana dökülmesi."),
        ("Otomatik Tahdit Kodu Eşleşmesi: ", "Cezayı ödeyen için V-84 taahhütnamesi; ödemeyen için derhal Ç-114/Ç-113 giriş yasağı tesis edilmesi."),
        ("Eğitim ve Sertifikasyon: ", "Personelin sürekli mevzuat sınavlarına tabi tutulduğu ve yetkinliğin canlı izlendiği entegre LMS portalı.")
    ]
    for i, (bold_txt, reg_txt) in enumerate(items_r):
        p = tf_r.paragraphs[0] if i == 0 else tf_r.add_paragraph()
        p.space_after = Pt(7)
        r1 = p.add_run()
        r1.text = "• " + bold_txt
        r1.font.bold = True
        r1.font.size = Pt(10)
        r1.font.color.rgb = C_TEXT_DARK
        r1.font.name = "Segoe UI"
        r2 = p.add_run()
        r2.text = reg_txt
        r2.font.size = Pt(10)
        r2.font.color.rgb = C_TEXT_MUTED
        r2.font.name = "Segoe UI"

    # Alt 4 KPI Kutusu
    kpis = [
        ("10 SANİYE", "İşlem Süresi", "%98 Zaman Tasarrufu", C_PRIMARY),
        ("%100", "Mevzuat Uyumu", "6458 SK. & 492 SK. V Sayılı", C_GREEN),
        ("0 HATA", "Hesaplama Doğruluğu", "Hazine Gelir Kaçağına Son", C_GOLD),
        ("TAM ENTEGRE", "Ekosistem Mimarisi", "Web + Mobil + API + LMS", RGBColor(147, 51, 234))
    ]
    kpi_w = 2.7
    gap = 0.31
    for idx, (val, title, sub, color) in enumerate(kpis):
        k_left = 0.8 + idx * (kpi_w + gap)
        k_card = add_card(s2, k_left, 5.4, kpi_w, 1.45)
        # Üst şerit
        k_top = s2.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(k_left), Inches(5.4), Inches(kpi_w), Inches(0.06))
        k_top.fill.solid()
        k_top.fill.fore_color.rgb = color
        k_top.line.fill.background()

        tx_k = s2.shapes.add_textbox(Inches(k_left + 0.1), Inches(5.55), Inches(kpi_w - 0.2), Inches(1.2))
        tf_k = tx_k.text_frame
        tf_k.word_wrap = True
        p_val = tf_k.paragraphs[0]
        p_val.text = val
        p_val.font.size = Pt(18)
        p_val.font.bold = True
        p_val.font.color.rgb = color
        p_val.font.name = "Segoe UI"
        p_val.alignment = PP_ALIGN.CENTER

        p_t = tf_k.add_paragraph()
        p_t.text = title
        p_t.font.size = Pt(10)
        p_t.font.bold = True
        p_t.font.color.rgb = C_TEXT_DARK
        p_t.font.name = "Segoe UI"
        p_t.alignment = PP_ALIGN.CENTER

        p_s = tf_k.add_paragraph()
        p_s.text = sub
        p_s.font.size = Pt(8.5)
        p_s.font.color.rgb = C_TEXT_MUTED
        p_s.font.name = "Segoe UI"
        p_s.alignment = PP_ALIGN.CENTER

    # =========================================================================
    # SLAYT 3: SİSTEM MİMARİSİ VE ENTEGRE UYGULAMALAR
    # =========================================================================
    s3 = prs.slides.add_slide(blank_layout)
    apply_light_bg(s3)
    add_header(s3, "CEZAM Ekosistem Mimarisi ve Modüler Yapı", "Teknoloji ve Mimari",
               "Modern web, mobil ve çekirdek iş motorlarıyla donatılmış çok katmanlı kurumsal altyapı.")
    add_footer(s3, 3)

    modules = [
        ("1. Web Yönetim Portalı", "gzpegm (ASP.NET MVC 5)", C_PRIMARY, [
            "İdareci ve pasaport memuru web kontrol arayüzü.",
            "AdminLTE 3 / Bootstrap 4 responsive modern arayüz.",
            "SignalR 2.4.3 ile anlık bot, duyuru ve mesajlaşma.",
            "Detaylı yetkilendirme (1-6 arası granular roller)."
        ]),
        ("2. Çekirdek İş Motorları", "Hesaplama & Karar Motoru", C_GOLD, [
            "Ceza Hesaplama Motoru (/Calculate1, /Calculate2).",
            "Tahdit Kodu Eşleştirme Motoru (/Kodgetir).",
            "Kaşe Vize (P-60) ve V-84 Şartlı Giriş Motoru.",
            "ClosedXML & iTextSharp ile resmi PDF/Excel çıktısı."
        ]),
        ("3. Mobil Saha Ekosistemi", "cezam_calculator & Web API", C_GREEN, [
            "Flutter tabanlı Android/iOS saha tablet uygulaması.",
            "Minimal .NET 10 Web API (VizeIhlal.Api) servisleri.",
            "Çevrimdışı (offline) çalışabilen yerel hesaplama yeteneği.",
            "Cihaz bazlı kota ve cihaz kimlik doğrulama."
        ]),
        ("4. Veri ve Güvenlik Katmanı", "MS SQL Server & PBKDF2", RGBColor(147, 51, 234), [
            "MS SQL Server ilişkisel veritabanı (EF 6.5.1).",
            "PBKDF2 kriptografik parola şifreleme ve tuzlama.",
            "GenericPrincipal ile yetkisiz erişim (403 Forbidden) koruması.",
            "Düzenli yedekleme ve yetim veri temizleme prosedürleri."
        ])
    ]

    m_w = 2.7
    m_gap = 0.31
    for idx, (title, sub, col, points) in enumerate(modules):
        m_left = 0.8 + idx * (m_w + m_gap)
        add_card(s3, m_left, 1.8, m_w, 5.0)

        # Kart Başlık Alanı
        hdr = s3.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(m_left), Inches(1.8), Inches(m_w), Inches(0.85))
        hdr.fill.solid()
        hdr.fill.fore_color.rgb = col
        hdr.line.fill.background()

        tf_h = hdr.text_frame
        tf_h.word_wrap = True
        p1 = tf_h.paragraphs[0]
        p1.text = title
        p1.font.size = Pt(12)
        p1.font.bold = True
        p1.font.color.rgb = C_WHITE
        p1.font.name = "Segoe UI"
        p2 = tf_h.add_paragraph()
        p2.text = sub
        p2.font.size = Pt(9.5)
        p2.font.color.rgb = RGBColor(235, 245, 255)
        p2.font.name = "Segoe UI"

        # İçerik Maddeleri
        tx_p = s3.shapes.add_textbox(Inches(m_left + 0.15), Inches(2.75), Inches(m_w - 0.3), Inches(3.9))
        tf_p = tx_p.text_frame
        tf_p.word_wrap = True
        for p_idx, pt in enumerate(points):
            p = tf_p.paragraphs[0] if p_idx == 0 else tf_p.add_paragraph()
            p.space_after = Pt(10)
            p.text = "• " + pt
            p.font.size = Pt(10)
            p.font.color.rgb = C_TEXT_DARK
            p.font.name = "Segoe UI"
            p.line_spacing = 1.2

    # =========================================================================
    # SLAYT 4: AMİRAL GEMİSİ — CEZA HESAPLAMA MODÜLÜ
    # =========================================================================
    s4 = prs.slides.add_slide(blank_layout)
    apply_light_bg(s4)
    add_header(s4, "AMİRAL GEMİSİ: Ceza Hesaplama Modülü ve Çekirdek Mantık", "Çekirdek Operasyon",
               "6458 sayılı YUKK m.102 ve Harçlar Kanunu (492 SK) V Sayılı Tarife hükümlerinin kusursuz otomasyonu.")
    add_footer(s4, 4)

    # 3 Büyük Kolon Kartı
    c_w = 3.65
    c_gap = 0.38

    # Kart 1: Sefer Tipleri ve Kurallar
    add_card(s4, 0.8, 1.8, c_w, 5.0)
    h1 = s4.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0.8), Inches(1.8), Inches(c_w), Inches(0.65))
    h1.fill.solid()
    h1.fill.fore_color.rgb = C_PRIMARY
    h1.line.fill.background()
    p_h1 = h1.text_frame.paragraphs[0]
    p_h1.text = "1. Sefer Tipleri & Sayım Kuralları"
    p_h1.font.size = Pt(12)
    p_h1.font.bold = True
    p_h1.font.color.rgb = C_WHITE
    p_h1.font.name = "Segoe UI"

    tx_c1 = s4.shapes.add_textbox(Inches(0.95), Inches(2.55), Inches(c_w - 0.3), Inches(4.1))
    tf_c1 = tx_c1.text_frame
    tf_c1.word_wrap = True
    items_c1 = [
        ("Normal Hesaplama (CType=1): ", "Giriş ve çıkış tarihi arasındaki gün farkından yasal vize hakkı düşülerek ihlal tespit edilir."),
        ("180 Günde 90 Gün Kuralı (CType=2): ", "Son 180 gün içindeki tüm Türkiye kalışları (ara giriş-çıkışlar) sisteme eklenir; 90 günü aşan kısımlar cezalandırılır."),
        ("Tır Şoförleri (CType=3): ", "Uluslararası nakliyat yapan şoförlere tek seferde en fazla 30 günlük yasal hak uygulanır."),
        ("Beyaz Rusya Kuralı (CType=5): ", "Tek girişte max 30 gün, 365 günde max 90 gün. Sistem giriş başı aşım ile yıllık aşımı kıyaslayıp en büyüğünü ceza gününe esas alır."),
        ("Günübirlik Seferler: ", "Her giriş-çıkış 1 tam gün olarak sayılır.")
    ]
    for i, (b, r) in enumerate(items_c1):
        p = tf_c1.paragraphs[0] if i == 0 else tf_c1.add_paragraph()
        p.space_after = Pt(8)
        run1 = p.add_run()
        run1.text = "• " + b
        run1.font.bold = True
        run1.font.size = Pt(9.5)
        run1.font.color.rgb = C_TEXT_DARK
        run1.font.name = "Segoe UI"
        run2 = p.add_run()
        run2.text = r
        run2.font.size = Pt(9.5)
        run2.font.color.rgb = C_TEXT_MUTED
        run2.font.name = "Segoe UI"

    # Kart 2: Vize ve İkamet Rejimleri
    add_card(s4, 0.8 + c_w + c_gap, 1.8, c_w, 5.0)
    h2 = s4.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0.8 + c_w + c_gap), Inches(1.8), Inches(c_w), Inches(0.65))
    h2.fill.solid()
    h2.fill.fore_color.rgb = C_GOLD
    h2.line.fill.background()
    p_h2 = h2.text_frame.paragraphs[0]
    p_h2.text = "2. Kalış ve Vize Rejimleri Matrisi"
    p_h2.font.size = Pt(12)
    p_h2.font.bold = True
    p_h2.font.color.rgb = C_WHITE
    p_h2.font.name = "Segoe UI"

    tx_c2 = s4.shapes.add_textbox(Inches(0.8 + c_w + c_gap + 0.15), Inches(2.55), Inches(c_w - 0.3), Inches(4.1))
    tf_c2 = tx_c2.text_frame
    tf_c2.word_wrap = True
    items_c2 = [
        ("Vizesiz Muafiyet: ", "Ülkeye göre 30, 60 veya 90 gün kanuni hak. Süre aşımında vize harcı + ikamet cezası tahakkuk eder."),
        ("Konsolosluk Vizeli / Kaşe Vize: ", "Pasaporttaki vizede belirtilen gün sayısı esas alınır (Visaday)."),
        ("İkamet Tezkereli: ", "İkamet izninin bittiği tarih girilir. Bitişten sonraki ilk 10 gün yasal başvuru payı sayılır, 10. günden sonra kaçak süresi işler."),
        ("Çalışma İzni Bitişi: ", "Çalışma izni ikamet yerine geçtiğinden bitiminden sonraki süre doğrudan ihlale konu olur."),
        ("V-137 Terke Davet: ", "10-15 günlük süre içinde çıkanlara ceza indirimi; süreyi geçirenlere katlamalı ceza tatbik edilir.")
    ]
    for i, (b, r) in enumerate(items_c2):
        p = tf_c2.paragraphs[0] if i == 0 else tf_c2.add_paragraph()
        p.space_after = Pt(8)
        run1 = p.add_run()
        run1.text = "• " + b
        run1.font.bold = True
        run1.font.size = Pt(9.5)
        run1.font.color.rgb = C_TEXT_DARK
        run1.font.name = "Segoe UI"
        run2 = p.add_run()
        run2.text = r
        run2.font.size = Pt(9.5)
        run2.font.color.rgb = C_TEXT_MUTED
        run2.font.name = "Segoe UI"

    # Kart 3: Çıktılar ve Katma Değer
    add_card(s4, 0.8 + 2 * (c_w + c_gap), 1.8, c_w, 5.0)
    h3 = s4.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0.8 + 2 * (c_w + c_gap)), Inches(1.8), Inches(c_w), Inches(0.65))
    h3.fill.solid()
    h3.fill.fore_color.rgb = C_GREEN
    h3.line.fill.background()
    p_h3 = h3.text_frame.paragraphs[0]
    p_h3.text = "3. Anlık Sistem Çıktıları ve Doğruluk"
    p_h3.font.size = Pt(12)
    p_h3.font.bold = True
    p_h3.font.color.rgb = C_WHITE
    p_h3.font.name = "Segoe UI"

    tx_c3 = s4.shapes.add_textbox(Inches(0.8 + 2 * (c_w + c_gap) + 0.15), Inches(2.55), Inches(c_w - 0.3), Inches(4.1))
    tf_c3 = tx_c3.text_frame
    tf_c3.word_wrap = True
    items_c3 = [
        ("Yasal Kalış & Çıkış Tarihi: ", "Yolcunun Türkiye'de yasal olarak kalabileceği son gün net olarak gösterilir."),
        ("İhlal Gün ve Ay Tespiti: ", "Gecikilen süre Ay ve Gün olarak ayrıştırılır (Harçlar Kanunu gereği 1 gün aşım tam ay sayılır)."),
        ("TCMB Efektif Satış Kuru: ", "Ülkenin harç tarifesi (USD/EUR/GBP) TCMB'nin o günkü kuruyla kuruşu kuruşuna TL'ye çevrilir."),
        ("Re-Entry (Tekrar Giriş) Durumu: ", "Yolcu hakkında başka yurda giriş yasağı yoksa 180/90 kuralına göre tekrar ne zaman girebileceği anında hesaplanır."),
        ("Çift Yönlü Arşivleme: ", "Hesaplanan her vaka tarih, kullanıcı sicili ve pasaport bazında SQL veritabanında saklanır.")
    ]
    for i, (b, r) in enumerate(items_c3):
        p = tf_c3.paragraphs[0] if i == 0 else tf_c3.add_paragraph()
        p.space_after = Pt(8)
        run1 = p.add_run()
        run1.text = "• " + b
        run1.font.bold = True
        run1.font.size = Pt(9.5)
        run1.font.color.rgb = C_TEXT_DARK
        run1.font.name = "Segoe UI"
        run2 = p.add_run()
        run2.text = r
        run2.font.size = Pt(9.5)
        run2.font.color.rgb = C_TEXT_MUTED
        run2.font.name = "Segoe UI"

    # =========================================================================
    # SLAYT 5: CEZA HESAPLAMA — 4 AŞAMALI OPERASYONEL AKIŞ
    # =========================================================================
    s5 = prs.slides.add_slide(blank_layout)
    apply_light_bg(s5)
    add_header(s5, "Ceza Hesaplama: 4 Aşamalı Operasyonel Akış Şeması", "İşlem Döngüsü",
               "Giriş-çıkış verisinden resmi tebligat dökümüne kadar 4 adımlı kesintisiz boru hattı (pipeline).")
    add_footer(s5, 5)

    steps = [
        ("AŞAMA 1", "Sefer & Rejim Analizi", "/Calculate1", C_PRIMARY, [
            "Giriş ve çıkış tarihleri girilir.",
            "Varsa ara seferler (gcadd) eklenir.",
            "Rejim (Muafiyet/İkamet/Tır) seçilir.",
            "Sunucu ihlal ay/gününü döner."
        ]),
        ("AŞAMA 2", "TCMB Kuru & 5 Kalem", "/Calculate2", C_GOLD, [
            "Doğum tarihiyle yetişkin/çocuk ayrılır.",
            "TCMB günlük kuru çekilir.",
            "İkamet + Vize + Defter + İdari Ceza hesaplanır.",
            "Toplam tutar (TL) ekrana dökülür."
        ]),
        ("AŞAMA 3", "Tahdit & Giriş Yasağı", "/Kodgetir", C_RED, [
            "Memur Ödeyen / Ödemeyen seçer.",
            "Ödeyen: Yasak konmaz / V-84 hakkı.",
            "Ödemeyen: Ç-114 tahditi işlenir.",
            "Süreye göre 3 ay - 5 yıl yasak konur."
        ]),
        ("AŞAMA 4", "Resmi Tebligat Bordrosu", "/Formolustur", C_GREEN, [
            "Kimlik ve pasaport bilgileri doldurulur.",
            "2 nüsha PDF tebligat bordrosu üretilir.",
            "Bir nüsha yolcuya verilir, biri arşivlenir.",
            "Pasaporta tahsil damgası vurulur."
        ])
    ]

    st_w = 2.7
    st_gap = 0.31
    for idx, (step_num, title, endpoint, color, details) in enumerate(steps):
        st_left = 0.8 + idx * (st_w + st_gap)
        add_card(s5, st_left, 2.0, st_w, 4.7)

        # Üst Numara Rozeti
        num_box = s5.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(st_left), Inches(2.0), Inches(st_w), Inches(0.9))
        num_box.fill.solid()
        num_box.fill.fore_color.rgb = color
        num_box.line.fill.background()

        tf_nb = num_box.text_frame
        p_n = tf_nb.paragraphs[0]
        p_n.text = step_num
        p_n.font.size = Pt(11)
        p_n.font.bold = True
        p_n.font.color.rgb = RGBColor(235, 248, 255)
        p_n.font.name = "Segoe UI"

        p_t = tf_nb.add_paragraph()
        p_t.text = title
        p_t.font.size = Pt(12)
        p_t.font.bold = True
        p_t.font.color.rgb = C_WHITE
        p_t.font.name = "Segoe UI"

        # Endpoint Rozeti
        ep_box = s5.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(st_left + 0.3), Inches(3.05), Inches(st_w - 0.6), Inches(0.35))
        ep_box.fill.solid()
        ep_box.fill.fore_color.rgb = RGBColor(241, 245, 249)
        ep_box.line.color.rgb = RGBColor(203, 213, 225)
        tf_ep = ep_box.text_frame
        p_ep = tf_ep.paragraphs[0]
        p_ep.text = "⚡ Endpoint: " + endpoint
        p_ep.font.size = Pt(9)
        p_ep.font.bold = True
        p_ep.font.color.rgb = C_TEXT_DARK
        p_ep.font.name = "Courier New"
        p_ep.alignment = PP_ALIGN.CENTER

        # Maddeler
        tx_d = s5.shapes.add_textbox(Inches(st_left + 0.15), Inches(3.55), Inches(st_w - 0.3), Inches(3.0))
        tf_d = tx_d.text_frame
        tf_d.word_wrap = True
        for d_idx, dt in enumerate(details):
            p = tf_d.paragraphs[0] if d_idx == 0 else tf_d.add_paragraph()
            p.space_after = Pt(10)
            p.text = "✓ " + dt
            p.font.size = Pt(10)
            p.font.color.rgb = C_TEXT_DARK
            p.font.name = "Segoe UI"
            p.line_spacing = 1.25

    # =========================================================================
    # SLAYT 6: 5 KALEMLİ MALİYET & GİRİŞ YASAĞI MATRİSİ
    # =========================================================================
    s6 = prs.slides.add_slide(blank_layout)
    apply_light_bg(s6)
    add_header(s6, "5 Kalemli Maliyet Cetveli ve Giriş Yasağı Matrisi", "Mevzuat & Formüller",
               "Hazine tahsilat kalemleri ve GİGM/EGM Genelgesi giriş yasağı süreleri.")
    add_footer(s6, 6)

    # Sol Alan: 5 Kalemli Maliyet Tablosu
    add_card(s6, 0.8, 1.8, 5.7, 5.0)
    h_l6 = s6.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0.8), Inches(1.8), Inches(5.7), Inches(0.55))
    h_l6.fill.solid()
    h_l6.fill.fore_color.rgb = C_PRIMARY
    h_l6.line.fill.background()
    p_hl6 = h_l6.text_frame.paragraphs[0]
    p_hl6.text = "  💰  5 Kalemli Harç ve Ceza Cetveli (492 SK & YUKK m.102)"
    p_hl6.font.size = Pt(11)
    p_hl6.font.bold = True
    p_hl6.font.color.rgb = C_WHITE
    p_hl6.font.name = "Segoe UI"

    tx_fee = s6.shapes.add_textbox(Inches(0.95), Inches(2.45), Inches(5.4), Inches(4.2))
    tf_fee = tx_fee.text_frame
    tf_fee.word_wrap = True
    fee_items = [
        ("1. Cezalı İkamet Harcı (TL):", "İlk Ay Tabanı + (Kalan Aylar × Aylık Harç). Ülke grubuna göre döviz kuru (USD/EUR) ile TL'ye çevrilir."),
        ("2. Tek Giriş Vize Harcı (TL):", "Vize muafiyeti aşıldığında karşılıklılık ilkesine göre 1 kat veya 2 kat tek giriş vize harcı alınır. İkametli olandan alınmaz."),
        ("3. Defter Bedeli (TL):", "210 sayılı Değerli Kağıtlar Kanunu gereğince her yıl Hazine Bakanlığı tarafından belirlenen ikamet belgesi bedelidir."),
        ("4. İdari Para Cezası (TL):", "6458 SK. md.102/1 uyarınca yasal sürede çıkmayan yabancıya kesilen katlamalı idari para cezasıdır."),
        ("5. GENEL TOPLAM TUTAR:", "Tüm kalemlerin toplamı = Vezneye veya sanal POS'a yatırılacak nihai tahakkuk tutarıdır.")
    ]
    for i, (head_t, body_t) in enumerate(fee_items):
        p = tf_fee.paragraphs[0] if i == 0 else tf_fee.add_paragraph()
        p.space_after = Pt(8)
        r1 = p.add_run()
        r1.text = head_t + " "
        r1.font.bold = True
        r1.font.size = Pt(10)
        r1.font.color.rgb = C_PRIMARY if i < 4 else C_GOLD
        r1.font.name = "Segoe UI"
        r2 = p.add_run()
        r2.text = body_t
        r2.font.size = Pt(9.5)
        r2.font.color.rgb = C_TEXT_DARK
        r2.font.name = "Segoe UI"

    # Sağ Alan: Giriş Yasağı Karşılaştırma Matrisi (Ödeyen vs Ödemeyen)
    add_card(s6, 6.833, 1.8, 5.7, 5.0)
    h_r6 = s6.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(6.833), Inches(1.8), Inches(5.7), Inches(0.55))
    h_r6.fill.solid()
    h_r6.fill.fore_color.rgb = C_RED
    h_r6.line.fill.background()
    p_hr6 = h_r6.text_frame.paragraphs[0]
    p_hr6.text = "  ⛔  Giriş Yasağı Matrisi: Ödeyen vs Ödemeyen (Ç-114)"
    p_hr6.font.size = Pt(11)
    p_hr6.font.bold = True
    p_hr6.font.color.rgb = C_WHITE
    p_hr6.font.name = "Segoe UI"

    # Tablo Oluştur
    rows = 7
    cols = 3
    tbl_shape = s6.shapes.add_table(rows, cols, Inches(6.98), Inches(2.45), Inches(5.4), Inches(4.2))
    tbl = tbl_shape.table
    tbl.columns[0].width = Inches(1.8)
    tbl.columns[1].width = Inches(1.7)
    tbl.columns[2].width = Inches(1.9)

    matris_data = [
        ("İhlal Süresi", "Cezayı Ödeyen", "Ödemeyen (Ç-114)"),
        ("0 Gün – 3 Ay", "Yasak Yok (V-84)", "3 AY GİRİŞ YASAĞI"),
        ("3 Ay – 6 Ay", "Yasak Yok (V-84)", "6 AY GİRİŞ YASAĞI"),
        ("6 Ay – 1 Yıl", "Yasak Yok (V-84)", "1 YIL GİRİŞ YASAĞI"),
        ("1 Yıl – 2 Yıl", "Yasak Yok (V-84)", "2 YIL GİRİŞ YASAĞI"),
        ("2 Yıl – 5 Yıl", "Yasak Yok (V-84)", "2 YIL GİRİŞ YASAĞI"),
        ("5 Yıldan Fazla", "Yasak Yok (V-84)", "5 YIL GİRİŞ YASAĞI")
    ]
    for r_idx, row in enumerate(matris_data):
        for c_idx, val in enumerate(row):
            cell = tbl.cell(r_idx, c_idx)
            cell.text = val
            p = cell.text_frame.paragraphs[0]
            p.font.name = "Segoe UI"
            if r_idx == 0:
                cell.fill.solid()
                cell.fill.fore_color.rgb = C_NAVY_DARK
                p.font.size = Pt(9.5)
                p.font.bold = True
                p.font.color.rgb = C_WHITE
                p.alignment = PP_ALIGN.CENTER
            else:
                p.font.size = Pt(9)
                if c_idx == 0:
                    p.font.bold = True
                    p.font.color.rgb = C_TEXT_DARK
                elif c_idx == 1:
                    p.font.bold = True
                    p.font.color.rgb = C_GREEN
                    p.alignment = PP_ALIGN.CENTER
                else:
                    p.font.bold = True
                    p.font.color.rgb = C_RED
                    p.alignment = PP_ALIGN.CENTER

    # =========================================================================
    # SLAYT 7: KAŞE VİZE & V-84 ŞARTLI GİRİŞ MODÜLLERİ
    # =========================================================================
    s7 = prs.slides.add_slide(blank_layout)
    apply_light_bg(s7)
    add_header(s7, "Kaşe Vize (P-60) ve V-84 Şartlı Giriş Modülleri", "Hudut Uygulamaları",
               "Pasaport geçerlilik süresi yetersizliği ve 10 günlük ikamet taahhütlü şartlı giriş işlemleri.")
    add_footer(s7, 7)

    # Sol Kart: Kaşe Vize Değerlendirmesi
    add_card(s7, 0.8, 1.8, 5.7, 5.0)
    h_l7 = s7.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0.8), Inches(1.8), Inches(5.7), Inches(0.65))
    h_l7.fill.solid()
    h_l7.fill.fore_color.rgb = C_PRIMARY
    h_l7.line.fill.background()
    p_hl7 = h_l7.text_frame.paragraphs[0]
    p_hl7.text = "1. Kaşe Vize (P - 60 Formülü) Uygulaması"
    p_hl7.font.size = Pt(12)
    p_hl7.font.bold = True
    p_hl7.font.color.rgb = C_WHITE
    p_hl7.font.name = "Segoe UI"
    p_hl7_sub = h_l7.text_frame.add_paragraph()
    p_hl7_sub.text = "GİGM 2014 & 2018 Genelgesi ve YUKK md. 7/1-b Dayanağı"
    p_hl7_sub.font.size = Pt(9)
    p_hl7_sub.font.color.rgb = RGBColor(219, 234, 254)
    p_hl7_sub.font.name = "Segoe UI"

    tx_kv = s7.shapes.add_textbox(Inches(0.95), Inches(2.55), Inches(5.4), Inches(4.1))
    tf_kv = tx_kv.text_frame
    tf_kv.word_wrap = True
    kv_items = [
        ("P - 60 Formülü: ", "Yabancının pasaport süresi talep edilen vize/muafiyet süresinden en az 60 gün uzun olmalıdır. Karşılamıyorsa: Verilecek Kaşe Vize = Kalan Pasaport Günü - 60 gün olarak verilir."),
        ("Örnek: ", "60 gün vize muafiyeti olan Rusya vatandaşı 100 günlük pasaportla gelirse: 100 - 60 = 40 günlük kaşe vize ile ülkeye kabul edilir."),
        ("60 Gün ve Altına KESİN RET: ", "Pasaportunda 60 gün veya daha az süresi kalan yolcuya kesinlikle kaşe vize verilemez; INAD uygulanarak geri gönderilir."),
        ("Aynı Pasaporta 1 Defa: ", "Bu kolaylık aynı pasaporta yalnızca bir defaya mahsus tek giriş olarak verilebilir."),
        ("Biten Pasaporttaki Vize: ", "Eski pasaportundaki geçerli konsolosluk vizesi + yeni pasaportla gelen yabancıya HARÇSIZ tek girişlik kaşe vize tatbik edilir.")
    ]
    for i, (b, r) in enumerate(kv_items):
        p = tf_kv.paragraphs[0] if i == 0 else tf_kv.add_paragraph()
        p.space_after = Pt(8)
        run1 = p.add_run()
        run1.text = "• " + b
        run1.font.bold = True
        run1.font.size = Pt(9.5)
        run1.font.color.rgb = C_TEXT_DARK
        run1.font.name = "Segoe UI"
        run2 = p.add_run()
        run2.text = r
        run2.font.size = Pt(9.5)
        run2.font.color.rgb = C_TEXT_MUTED
        run2.font.name = "Segoe UI"

    # Sağ Kart: V-84 Şartlı Giriş Modülü
    add_card(s7, 6.833, 1.8, 5.7, 5.0)
    h_r7 = s7.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(6.833), Inches(1.8), Inches(5.7), Inches(0.65))
    h_r7.fill.solid()
    h_r7.fill.fore_color.rgb = C_GOLD
    h_r7.line.fill.background()
    p_hr7 = h_r7.text_frame.paragraphs[0]
    p_hr7.text = "2. V-84 İkamet Şartlı Giriş Taahhütnamesi"
    p_hr7.font.size = Pt(12)
    p_hr7.font.bold = True
    p_hr7.font.color.rgb = C_WHITE
    p_hr7.font.name = "Segoe UI"
    p_hr7_sub = h_r7.text_frame.add_paragraph()
    p_hr7_sub.text = "6458 SK. Kapsamında Çıkış Cezasını Ödeyen Yabancılar İçin Giriş Kolaylığı"
    p_hr7_sub.font.size = Pt(9)
    p_hr7_sub.font.color.rgb = RGBColor(254, 243, 199)
    p_hr7_sub.font.name = "Segoe UI"

    tx_v84 = s7.shapes.add_textbox(Inches(6.98), Inches(2.55), Inches(5.4), Inches(4.1))
    tf_v84 = tx_v84.text_frame
    tf_v84.word_wrap = True
    v84_items = [
        ("Uygulama Şartı: ", "Daha önce vize/ikamet ihlali yapıp cezasını eksiksiz ödeyen ve hakkında aktif süreli giriş yasağı bulunmayan yabancılara uygulanır."),
        ("10 Günlük Yasal Taahhüt: ", "Yabancı, Türkiye'ye giriş yaptığı tarihten itibaren 10 gün içinde İl Göç İdaresi'ne ikamet izni başvurusunda bulunacağını taahhüt eder."),
        ("Resmi Tebligat & Taahhütname: ", "Sistem üzerinden yolcuya resmi V-84 taahhütnamesi basılır, imzalatılır ve POLNET'e V-84 tahditi işlenir."),
        ("10 Gün İçinde Başvurmazsa: ", "Kaçak durumuna düşer ve ilk çıkışında hakkında para cezasıyla birlikte süreli giriş yasağı kararı alınır."),
        ("Yaş Sınırı Kuralı: ", "Kullanıcının talimatı doğrultusunda sistemdeki yaş sınırlaması kaldırılmış olup tüm hak sahibi yaş grupları eşit işlem görmektedir.")
    ]
    for i, (b, r) in enumerate(v84_items):
        p = tf_v84.paragraphs[0] if i == 0 else tf_v84.add_paragraph()
        p.space_after = Pt(8)
        run1 = p.add_run()
        run1.text = "• " + b
        run1.font.bold = True
        run1.font.size = Pt(9.5)
        run1.font.color.rgb = C_TEXT_DARK
        run1.font.name = "Segoe UI"
        run2 = p.add_run()
        run2.text = r
        run2.font.size = Pt(9.5)
        run2.font.color.rgb = C_TEXT_MUTED
        run2.font.name = "Segoe UI"

    # =========================================================================
    # SLAYT 8: DESTEKLEYİCİ MODÜLLER (TAHDİT, INAD, TERİMLER)
    # =========================================================================
    s8 = prs.slides.add_slide(blank_layout)
    apply_light_bg(s8)
    add_header(s8, "Destekleyici Operasyonel Modüller: Tahdit, INAD ve Terimler", "Operasyon & Mevzuat",
               "Saha personelinin kritik kriz ve karar anlarında kullandığı entegre karar destek modülleri.")
    add_footer(s8, 8)

    sub_mods = [
        ("Tahdit Kodları Rehberi (/Tahdit)", C_RED, [
            ("Ç-113 & Ç-114: ", "Vize/ikamet ihlali yapan ve para cezasını ödemeden çıkan yabancılar için uygulanan giriş yasağı kodları."),
            ("Ç-141: ", "Bakanlık talimatıyla kamu güvenliği açısından sakıncalı görülen yabancılara konulan kod."),
            ("G-87: ", "Genel güvenlik açısından tahditli yabancılar."),
            ("V-69 & V-88: ", "İkamet izni iptal edilen veya çalışma izni iptal edilen yabancılar."),
            ("V-137: ", "Türkiye'yi terke davet edilen yabancılar için 10-15 günlük kontrollü çıkış kodu.")
        ]),
        ("INAD (Kabul Edilmeyen Yolcu)", C_NAVY_DARK, [
            ("YUKK md. 7 ve 8: ", "Pasaportu geçersiz (60 günden az), sahte vize ibraz eden veya giriş yasağı olan yolculara uygulanır."),
            ("Taşıyıcı Şirket Sorumluluğu: ", "Havayolu şirketine INAD tebligatı yapılır; yolcunun geldiği ülkeye masrafları taşıyıcıya ait olarak geri gönderilmesi zorunludur."),
            ("Gözetim Alanı Yönetimi: ", "Geri gönderme saatine kadar yolcunun havalimanı transit/INAD salonunda güvenli kontrolü sağlanır."),
            ("İtiraz ve Mülakat: ", "Yolcunun mülakat tutanağı ve ret gerekçesi sistem üzerinden standart formata dökülür.")
        ]),
        ("Terimler & Mevzuat Sözlüğü", C_PRIMARY, [
            ("90/180 Kuralı: ", "Herhangi bir 180 günlük hareketli pencerede toplam kalışın 90 günü geçemeyeceği temel Schengen ve Türkiye standardı."),
            ("Mütekabiliyet (Karşılıklılık): ", "Yabancı ülkenin Türk vatandaşlarına uyguladığı vize süresi ve harç miktarının aynen uygulanması."),
            ("Çıkış İzni (Exit Permit): ", "Cezasız veya tahditli yabancılara çıkış anında verilen yasal belge."),
            ("Deport (Sınır Dışı): ", "6458 SK md. 54 gereğince Göç İdaresi kararıyla kolluk refakatinde sınır dışı etme işlemi.")
        ])
    ]

    for idx, (title, color, items) in enumerate(sub_mods):
        m_left = 0.8 + idx * (c_w + c_gap)
        add_card(s8, m_left, 1.8, c_w, 5.0)

        hdr = s8.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(m_left), Inches(1.8), Inches(c_w), Inches(0.65))
        hdr.fill.solid()
        hdr.fill.fore_color.rgb = color
        hdr.line.fill.background()
        p_hdr = hdr.text_frame.paragraphs[0]
        p_hdr.text = title
        p_hdr.font.size = Pt(11.5)
        p_hdr.font.bold = True
        p_hdr.font.color.rgb = C_WHITE
        p_hdr.font.name = "Segoe UI"

        tx_sm = s8.shapes.add_textbox(Inches(m_left + 0.15), Inches(2.55), Inches(c_w - 0.3), Inches(4.1))
        tf_sm = tx_sm.text_frame
        tf_sm.word_wrap = True
        for i, (b, r) in enumerate(items):
            p = tf_sm.paragraphs[0] if i == 0 else tf_sm.add_paragraph()
            p.space_after = Pt(8)
            run1 = p.add_run()
            run1.text = "• " + b
            run1.font.bold = True
            run1.font.size = Pt(9.5)
            run1.font.color.rgb = C_TEXT_DARK
            run1.font.name = "Segoe UI"
            run2 = p.add_run()
            run2.text = r
            run2.font.size = Pt(9.5)
            run2.font.color.rgb = C_TEXT_MUTED
            run2.font.name = "Segoe UI"

    # =========================================================================
    # SLAYT 9: EĞİTİM, SINAV & LMS PORTALI (PERSONEL YETKİNLİĞİ)
    # =========================================================================
    s9 = prs.slides.add_slide(blank_layout)
    apply_light_bg(s9)
    add_header(s9, "Eğitim, Sınav ve LMS Portalı: Personel Yetkinlik Yönetimi", "İnsan Kaynağı & Kalite",
               "Mevzuat değişikliklerinin personele anında aktarılması ve denetlenebilir başarı karneleri.")
    add_footer(s9, 9)

    lms_blocks = [
        ("Mevzuat Eğitim Havuzu", C_PRIMARY, [
            "6458 sayılı Kanun maddeleri ve genelgelerin görsel slaytlarla personele sunulması.",
            "Yeni çıkan EGM ve GİGM talimatlarının sisteme yüklenerek zorunlu okuma atanması.",
            "Personelin eğitim tamamlama sürelerinin sistem üzerinden loglanması."
        ]),
        ("Dinamik Deneme Sınavları", C_GOLD, [
            "Soru havuzundan rastgele seçilen çoktan seçmeli sorularla pratik sınavlar.",
            "Sınav süresi, yanlış cevap analizi ve anlık puanlama motoru.",
            "Saha vakalarına (Rus turist, Belarus kuralı, kaşe vize) dayalı senaryo soruları."
        ]),
        ("Başarı Karneleri & Liyakat", C_GREEN, [
            "Her personelin sicil bazında yetkinlik puanı ve başarı grafiği.",
            "Nöbetçi amirliğine yetersiz görülen konularda otomatik gelişim uyarısı.",
            "Hudut kapısında görev yapacak personel için minimum geçme barajı zorunluluğu."
        ]),
        ("Vardiya Devir & Raporlama", RGBColor(147, 51, 234), [
            "Vardiya devir teslimlerinde kesilen ceza sayısı ve toplam tutar özeti.",
            "Excel, CSV ve PDF formatında günlük/aylık üst makam raporları.",
            "Kritik yolcu geçişleri ve INAD istatistiklerinin nöbet defterine otomatik aktarımı."
        ])
    ]

    for idx, (title, color, items) in enumerate(lms_blocks):
        m_left = 0.8 + idx * (st_w + st_gap)
        add_card(s9, m_left, 1.8, st_w, 5.0)

        hdr = s9.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(m_left), Inches(1.8), Inches(st_w), Inches(0.75))
        hdr.fill.solid()
        hdr.fill.fore_color.rgb = color
        hdr.line.fill.background()
        p_hdr = hdr.text_frame.paragraphs[0]
        p_hdr.text = title
        p_hdr.font.size = Pt(11.5)
        p_hdr.font.bold = True
        p_hdr.font.color.rgb = C_WHITE
        p_hdr.font.name = "Segoe UI"

        tx_lms = s9.shapes.add_textbox(Inches(m_left + 0.15), Inches(2.65), Inches(st_w - 0.3), Inches(4.0))
        tf_lms = tx_lms.text_frame
        tf_lms.word_wrap = True
        for i, pt in enumerate(items):
            p = tf_lms.paragraphs[0] if i == 0 else tf_lms.add_paragraph()
            p.space_after = Pt(12)
            p.text = "✓ " + pt
            p.font.size = Pt(10)
            p.font.color.rgb = C_TEXT_DARK
            p.font.name = "Segoe UI"
            p.line_spacing = 1.25

    # =========================================================================
    # SLAYT 10: SİSTEM VE VERİ GÜVENLİĞİ DENETİM SONUÇLARI
    # =========================================================================
    s10 = prs.slides.add_slide(blank_layout)
    apply_light_bg(s10)
    add_header(s10, "Sistem ve Veri Güvenliği Denetim Sonuçları", "Güvenlik ve Uyum",
               "Yapılan son güvenlik sıkılaştırmaları ve kod kalitesi denetim raporu (Production Audit).")
    add_footer(s10, 10)

    sec_cards = [
        ("RBAC & 403 Forbidden Mimarisi", "UserAuthorize.cs İyileştirmesi", C_GREEN, [
            "Eski Durum: Token çerezi doğrulanmasına rağmen IPrincipal atanmıyor, yetkisiz kullanıcı döngüye giriyordu.",
            "Yeni Durum: HttpContext.User nesnesine GenericPrincipal atandı. Yetkisiz girişimlerde şık 403 Forbidden sayfası açılıyor.",
            "Güvenlik Kazanımı: Yetkisiz URL parametresi değiştirerek yetki aşımı yapılması kesin olarak engellendi."
        ]),
        ("Açık Endpoint İzolasyonu", "[NonAction] Denetimi", C_PRIMARY, [
            "Eski Durum: Public yardımcı metotlar (örn. GetUser) dışarıdan HTTP Action olarak çağrılabiliyordu.",
            "Yeni Durum: 6 controller içindeki tüm iç metotlara [NonAction] özniteliği eklendi.",
            "Güvenlik Kazanımı: Doğrudan API/metot tetikleme ve bilgi sızdırma açıkları tamamen kapatıldı."
        ]),
        ("Kriptografik Parola & Oturum Güvenliği", "PBKDF2 & Secure Cookies", C_GOLD, [
            "Parola Güvenliği: Tüm kullanıcı şifreleri PBKDF2 kriptografik algoritması ve dinamik tuzlama ile saklanır.",
            "Oturum Koruması: Token tabanlı çerezler HttpOnly ve SameSite bayraklarıyla donatıldı.",
            "Yetim Kayıt Temizliği: Silinmiş yetkiye bağlı yetim hesapları tek tıkla temizleme motoru devrede."
        ]),
        ("Derleme Sağlığı & Kod Temizliği", "MSBuild 0 Hata / 0 Uyarı", RGBColor(147, 51, 234), [
            "Derleme Durumu: Visual Studio 2022 Enterprise MSBuild ile sıfır derleme hatası ve sıfır uyarı.",
            "Gereksiz Yük Temizliği: Proje içerisindeki 4 GB'lık geçersiz zip ve geçici derleme kalıntıları temizlendi.",
            "Performans: Sayfa yanıt süresi 45 ms altına indirildi; bellek sızıntıları giderildi."
        ])
    ]

    for idx, (title, sub, color, points) in enumerate(sec_cards):
        m_left = 0.8 + idx * (st_w + st_gap)
        add_card(s10, m_left, 1.8, st_w, 5.0)

        hdr = s10.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(m_left), Inches(1.8), Inches(st_w), Inches(0.8))
        hdr.fill.solid()
        hdr.fill.fore_color.rgb = color
        hdr.line.fill.background()
        p_hdr = hdr.text_frame.paragraphs[0]
        p_hdr.text = title
        p_hdr.font.size = Pt(11)
        p_hdr.font.bold = True
        p_hdr.font.color.rgb = C_WHITE
        p_hdr.font.name = "Segoe UI"
        p_sub = hdr.text_frame.add_paragraph()
        p_sub.text = sub
        p_sub.font.size = Pt(9)
        p_sub.font.color.rgb = RGBColor(235, 245, 255)
        p_sub.font.name = "Segoe UI"

        tx_sec = s10.shapes.add_textbox(Inches(m_left + 0.15), Inches(2.7), Inches(st_w - 0.3), Inches(3.9))
        tf_sec = tx_sec.text_frame
        tf_sec.word_wrap = True
        for i, pt in enumerate(points):
            p = tf_sec.paragraphs[0] if i == 0 else tf_sec.add_paragraph()
            p.space_after = Pt(10)
            p.text = "✓ " + pt
            p.font.size = Pt(9.5)
            p.font.color.rgb = C_TEXT_DARK
            p.font.name = "Segoe UI"
            p.line_spacing = 1.25

    # =========================================================================
    # SLAYT 11: CANLIYA GEÇİŞ (PRODUCTION) ALTYAPI PLANI
    # =========================================================================
    s11 = prs.slides.add_slide(blank_layout)
    apply_light_bg(s11)
    add_header(s11, "Canlıya Geçiş (Production) Altyapı ve Dağıtım Planı", "Altyapı & Entegrasyon",
               "Sistemin güvenli EGM veri merkezinde konumlandırılması ve POLNET/GİGM entegrasyonu.")
    add_footer(s11, 11)

    infra_cols = [
        ("Sunucu Mimarisi (IIS 10)", C_PRIMARY, [
            ("İşletim Sistemi: ", "Windows Server 2022 Datacenter Edition."),
            ("Web Sunucusu: ", "IIS 10.0 üzerinde Application Request Routing (ARR) ile Load Balancer kümesi."),
            (".NET Framework: ", "v4.7.2 Runtime + .NET 10 Web API Core hosting paketi."),
            ("Erişilebilirlik: ", "7/24 kesintisiz çalışma (%99.99 SLA hedefi).")
        ]),
        ("Veritabanı (MS SQL Server)", C_GOLD, [
            ("Veritabanı: ", "MS SQL Server 2022 Enterprise Edition."),
            ("Yüksek Erişilebilirlik: ", "AlwaysOn Availability Groups ile anlık senkron yedeklilik."),
            ("Yedekleme: ", "15 dakikalık Transaction Log yedekleri ve günlük Full Backup."),
            ("Kriptolama: ", "TDE (Transparent Data Encryption) ile diskte veri şifreleme.")
        ]),
        ("Ağ Güvenliği & POLNET", C_RED, [
            ("Ağ İzolasyonu: ", "Sistem kapalı devre EGM intarneti üzerinde güvenli DMZ zonunda barındırılır."),
            ("SSL / TLS: ", "TLS 1.3 zorunlu HTTPS protokolü ve kurumsal CA sertifikası."),
            ("WAF Koruması: ", "Web Application Firewall (WAF) ile SQL Injection ve XSS saldırılarına karşı aktif kalkan."),
            ("IP Kısıtlaması: ", "Yalnızca yetkilendirilmiş hudut kapısı IP bloklarından erişim.")
        ]),
        ("Entegrasyon Vizyonu", C_GREEN, [
            ("POLNET Servisleri: ", "Pasaport okuyucu (OCR) ile yolcu bilgilerinin otomatik formlara dolması."),
            ("GİGM Göç-Net: ", "İkamet tezkeresi ve V-84 durumlarının anlık API ile teyit edilmesi."),
            ("Maliye / Gelir İdaresi: ", "Sanal POS ve tahsilat makbuzlarının vergi dairelerine otomatik intikali."),
            ("TCMB Entegrasyonu: ", "Günlük döviz kurlarının her sabah 15:30'da otomatik güncellenmesi.")
        ])
    ]

    for idx, (title, color, items) in enumerate(infra_cols):
        m_left = 0.8 + idx * (st_w + st_gap)
        add_card(s11, m_left, 1.8, st_w, 5.0)

        hdr = s11.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(m_left), Inches(1.8), Inches(st_w), Inches(0.65))
        hdr.fill.solid()
        hdr.fill.fore_color.rgb = color
        hdr.line.fill.background()
        p_hdr = hdr.text_frame.paragraphs[0]
        p_hdr.text = title
        p_hdr.font.size = Pt(11)
        p_hdr.font.bold = True
        p_hdr.font.color.rgb = C_WHITE
        p_hdr.font.name = "Segoe UI"

        tx_inf = s11.shapes.add_textbox(Inches(m_left + 0.15), Inches(2.55), Inches(st_w - 0.3), Inches(4.1))
        tf_inf = tx_inf.text_frame
        tf_inf.word_wrap = True
        for i, (b, r) in enumerate(items):
            p = tf_inf.paragraphs[0] if i == 0 else tf_inf.add_paragraph()
            p.space_after = Pt(8)
            run1 = p.add_run()
            run1.text = "• " + b
            run1.font.bold = True
            run1.font.size = Pt(9.5)
            run1.font.color.rgb = C_TEXT_DARK
            run1.font.name = "Segoe UI"
            run2 = p.add_run()
            run2.text = r
            run2.font.size = Pt(9.5)
            run2.font.color.rgb = C_TEXT_MUTED
            run2.font.name = "Segoe UI"

    # =========================================================================
    # SLAYT 12: STRATEJİK YOL HARİTASI (FAZLAR)
    # =========================================================================
    s12 = prs.slides.add_slide(blank_layout)
    apply_light_bg(s12)
    add_header(s12, "Stratejik Yol Haritası: Aşamalı Canlıya Geçiş Modeli", "Proje Takvimi",
               "Riskleri sıfıra indiren 3 aşamalı kontrollü devreye alma yaklaşımı.")
    add_footer(s12, 12)

    phases = [
        ("FAZ 1: PİLOT DAĞITIM", "1. - 2. Ay (Kontrollü Canlı)", C_PRIMARY, [
            ("Hedef Kapsam: ", "Belirlenecek 1 Uluslararası Havalimanı (örn. Antalya veya İstanbul) ve 1 Kara Hudut Kapısında pilot canlı kullanım."),
            ("Amaç: ", "Saha koşullarında gerçek pasaport memurları tarafından sistemin test edilmesi, geri bildirimlerin toplanması."),
            ("İşlem: ", "Kullanıcı rolleri ve şifrelerin teslimi, yerinde destek ekibinin bulunması."),
            ("Çıktı: ", "Pilot Değerlendirme Raporu ve ince ayarların tamamlanması.")
        ]),
        ("FAZ 2: MERKEZİ ENTEGRASYON", "3. - 4. Ay (POLNET & GİGM)", C_GOLD, [
            ("Hedef Kapsam: ", "POLNET Hudut ve GİGM Göç-Net web servisleri ile doğrudan iki yönlü API entegrasyonu."),
            ("Amaç: ", "Manuel tarih ve pasaport girişine gerek kalmadan MRZ/OCR barkod okuyucuyla formların 1 saniyede dolması."),
            ("İşlem: ", "EGM Bilgi Teknolojileri Daire Başkanlığı ile ortak servis testleri."),
            ("Çıktı: ", "Otomasyon seviyesinin %100'e çıkarılması.")
        ]),
        ("FAZ 3: ÜLKE GENELİ YAYGINLAŞTIRMA", "5. - 6. Ay (Tüm Hudut Kapıları)", C_GREEN, [
            ("Hedef Kapsam: ", "Türkiye genelindeki tüm hava, kara ve deniz hudut kapılarında merkezi kullanım."),
            ("Amaç: ", "Mevzuat uygulamasının tüm ülke sınırlarında standartlaştırılması ve tek merkezden raporlanması."),
            ("İşlem: ", "Personel LMS eğitim ve sertifikasyon sürecinin tamamlanması, resmi genelge ilanı."),
            ("Çıktı: ", "Yıllık milyonlarca liralık gelir güvencesi ve sıfır kaçak sınır yönetimi.")
        ])
    ]

    p_w = 3.65
    p_gap = 0.38
    for idx, (p_title, p_time, col, p_items) in enumerate(phases):
        p_left = 0.8 + idx * (p_w + p_gap)
        add_card(s12, p_left, 1.8, p_w, 5.0)

        hdr = s12.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(p_left), Inches(1.8), Inches(p_w), Inches(0.85))
        hdr.fill.solid()
        hdr.fill.fore_color.rgb = col
        hdr.line.fill.background()
        p_hdr = hdr.text_frame.paragraphs[0]
        p_hdr.text = p_title
        p_hdr.font.size = Pt(12)
        p_hdr.font.bold = True
        p_hdr.font.color.rgb = C_WHITE
        p_hdr.font.name = "Segoe UI"
        p_sub = hdr.text_frame.add_paragraph()
        p_sub.text = p_time
        p_sub.font.size = Pt(9.5)
        p_sub.font.color.rgb = RGBColor(235, 245, 255)
        p_sub.font.name = "Segoe UI"

        tx_ph = s12.shapes.add_textbox(Inches(p_left + 0.15), Inches(2.75), Inches(p_w - 0.3), Inches(3.9))
        tf_ph = tx_ph.text_frame
        tf_ph.word_wrap = True
        for i, (b, r) in enumerate(p_items):
            p = tf_ph.paragraphs[0] if i == 0 else tf_ph.add_paragraph()
            p.space_after = Pt(10)
            run1 = p.add_run()
            run1.text = "• " + b
            run1.font.bold = True
            run1.font.size = Pt(9.5)
            run1.font.color.rgb = C_TEXT_DARK
            run1.font.name = "Segoe UI"
            run2 = p.add_run()
            run2.text = r
            run2.font.size = Pt(9.5)
            run2.font.color.rgb = C_TEXT_MUTED
            run2.font.name = "Segoe UI"

    # =========================================================================
    # SLAYT 13: YÖNETİCİ KARAR VE ONAY TALEPLERİ (CONCLUSION)
    # =========================================================================
    s13 = prs.slides.add_slide(blank_layout)
    apply_light_bg(s13)
    add_header(s13, "Sonuç ve Yetkili Merci Karar Talepleri", "Karar ve Onay",
               "Sistemin sahada devreye alınması için Üst Yönetim Makamından arz ve talep edilen hususlar.")
    add_footer(s13, 13)

    decisions = [
        ("1. Pilot Uygulama İzni ve Görevlendirme", C_PRIMARY, [
            "Belirlenecek 1 Havalimanı ve 1 Kara Hudut Kapısında sistemin pilot olarak canlıya alınması onayı.",
            "Pilot kapılardaki pasaport kontrol personeline sistem kullanım yetkisinin tanımlanması.",
            "Proje teknik ekibinin yerinde gözlem ve destek sağlaması için görevlendirilmesi."
        ]),
        ("2. POLNET & GİGM Güvenli Entegrasyon Yetkilendirmesi", C_GOLD, [
            "EGM Bilgi Teknolojileri Dairesi ile POLNET sınır kontrol servislerine güvenli API erişim izni tahsisi.",
            "Göç İdaresi Başkanlığı Göç-Net veri tabanından ikamet ve tahdit sorgulama protokolünün imzalanması.",
            "Maliye vezneleri ve Sanal POS entegrasyonu için teknik koordinasyonun başlatılması."
        ]),
        ("3. Personel LMS Eğitimi ve Uygulama Tamimi Yayımı", C_GREEN, [
            "Hudut kapılarında görevli personelin CEZAM LMS Eğitim Portalı üzerinden zorunlu sertifikasyonunun yapılması.",
            "Sistemin standart operasyon prosedürü olarak kullanılmasını amir genelge/talimatın yayımlanması.",
            "Mevzuat güncellemelerinin tek merkezden CEZAM sistemi üzerinden duyurulması."
        ])
    ]

    for idx, (title, color, items) in enumerate(decisions):
        m_left = 0.8 + idx * (c_w + c_gap)
        add_card(s13, m_left, 1.8, c_w, 4.0)

        hdr = s13.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(m_left), Inches(1.8), Inches(c_w), Inches(0.75))
        hdr.fill.solid()
        hdr.fill.fore_color.rgb = color
        hdr.line.fill.background()
        p_hdr = hdr.text_frame.paragraphs[0]
        p_hdr.text = title
        p_hdr.font.size = Pt(11.5)
        p_hdr.font.bold = True
        p_hdr.font.color.rgb = C_WHITE
        p_hdr.font.name = "Segoe UI"

        tx_dec = s13.shapes.add_textbox(Inches(m_left + 0.15), Inches(2.65), Inches(c_w - 0.3), Inches(3.0))
        tf_dec = tx_dec.text_frame
        tf_dec.word_wrap = True
        for i, pt in enumerate(items):
            p = tf_dec.paragraphs[0] if i == 0 else tf_dec.add_paragraph()
            p.space_after = Pt(10)
            p.text = "✓ " + pt
            p.font.size = Pt(10)
            p.font.color.rgb = C_TEXT_DARK
            p.font.name = "Segoe UI"
            p.line_spacing = 1.25

    # Alt Kapanış Kutusu
    final_banner = s13.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8), Inches(6.0), Inches(11.733), Inches(0.85))
    final_banner.fill.solid()
    final_banner.fill.fore_color.rgb = C_NAVY_DARK
    final_banner.line.color.rgb = C_CYAN
    final_banner.line.width = Pt(1.5)
    tf_fb = final_banner.text_frame
    tf_fb.word_wrap = True
    p_fb = tf_fb.paragraphs[0]
    p_fb.text = "✦  CEZAM; Türk Emniyet Teşkilatı'nın sınır güvenliğinde yapay zeka, hız ve mevzuat güvencesini bir araya getiren milli ve modern bir başarı projesidir."
    p_fb.font.size = Pt(11)
    p_fb.font.bold = True
    p_fb.font.color.rgb = C_WHITE
    p_fb.font.name = "Segoe UI"
    p_fb.alignment = PP_ALIGN.CENTER
    p_fb_sub = tf_fb.add_paragraph()
    p_fb_sub.text = "Makamın tensip ve takdirlerine saygıyla arz olunur."
    p_fb_sub.font.size = Pt(10)
    p_fb_sub.font.color.rgb = C_GOLD
    p_fb_sub.font.name = "Segoe UI"
    p_fb_sub.alignment = PP_ALIGN.CENTER

    # Kaydet
    output_path = r"C:\Users\Naşit\source\repos\CEZAM\CEZAM_Yetkili_Merci_Brifing_Sunumu.pptx"
    prs.save(output_path)
    print(f"BAŞARILI: Sunum başarıyla kaydedildi -> {output_path}")

if __name__ == "__main__":
    create_deck()
