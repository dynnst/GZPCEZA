-- ==========================================================================
-- CEZAM EÄÄ°TÄ°M VE SINAV SÄ°STEMÄ° - DERS, Ä°Ã‡ERÄ°K VE SORU BANKASI
-- Dosya: 04_SEED_COURSES_AND_EXAMS.sql
-- Tarih: 17.10.2026 23:21:40
-- AÃ§Ä±klama: Kurslar, iÃ§erikler, sÄ±navlar, soru bankasÄ± ve seÃ§enekler.
-- ==========================================================================
USE [CEZA];
GO

-- --------------------------------------------------------------------------
-- Veri: [dbo].[Courses]
-- --------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[Courses]', N'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Courses])
    BEGIN
        SET IDENTITY_INSERT [dbo].[Courses] ON;
        INSERT INTO [dbo].[Courses] ([CourseId], [CourseTitle], [CourseDescription], [CoverImage], [CreatedBy], [CreatedDate], [CategoryId], [ResourceFile], [IsActive], [IsDeleted]) VALUES
            (7, N'Danimarka Umuma Mahsus Pasaporta Ait Özellikler ve Kursa Bağlı Sınavlar', N'<div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); color: rgba(62, 73, 81, 1); font-family: &quot;Source Sans&quot;, Verdana, sans-serif; font-size: 14.4px; padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Başlık:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">PAS</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); color: rgba(62, 73, 81, 1); font-family: &quot;Source Sans&quot;, Verdana, sans-serif; font-size: 14.4px; padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">İhraç Eden Ülke:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">DNK - Danimarka • DANMARK •</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); color: rgba(62, 73, 81, 1); font-family: &quot;Source Sans&quot;, Verdana, sans-serif; font-size: 14.4px; padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Belge Kategorisi:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">A - Pasaport</font><a title="PRADO çevrimiçi yardım: A" style="font-size: 1.1em; margin: 0 0 0 0.4em; position: relative">&nbsp;</a></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); color: rgba(62, 73, 81, 1); font-family: &quot;Source Sans&quot;, Verdana, sans-serif; font-size: 14.4px; padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Belge türü:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">O - sıradan belge</font><a title="PRADO çevrimiçi yardım: O" style="font-size: 1.1em; margin: 0 0 0 0.4em; position: relative">&nbsp;</a></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); color: rgba(62, 73, 81, 1); font-family: &quot;Source Sans&quot;, Verdana, sans-serif; font-size: 14.4px; padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Belge sürüm numarası:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">06001</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); color: rgba(62, 73, 81, 1); font-family: &quot;Source Sans&quot;, Verdana, sans-serif; font-size: 14.4px; padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">İlk yayınlanma tarihi:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">01/10/2021</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); color: rgba(62, 73, 81, 1); font-family: &quot;Source Sans&quot;, Verdana, sans-serif; font-size: 14.4px; padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Geçerli:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">Evet</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); color: rgba(62, 73, 81, 1); font-family: &quot;Source Sans&quot;, Verdana, sans-serif; font-size: 14.4px; padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Hukuki durum / temel amaç:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">Danimarka vatandaşlarına verilen seyahat belgesi: DNK - Danimarka • DANMARK •</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); color: rgba(62, 73, 81, 1); font-family: &quot;Source Sans&quot;, Verdana, sans-serif; font-size: 14.4px; padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Genel yapı:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">diğer</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); color: rgba(62, 73, 81, 1); font-family: &quot;Source Sans&quot;, Verdana, sans-serif; font-size: 14.4px; padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Format genişliği (mm):</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">88</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); color: rgba(62, 73, 81, 1); font-family: &quot;Source Sans&quot;, Verdana, sans-serif; font-size: 14.4px; padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Format yüksekliği (mm):</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">125</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); color: rgba(62, 73, 81, 1); font-family: &quot;Source Sans&quot;, Verdana, sans-serif; font-size: 14.4px; padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Sayfa sayısı:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">32</font></p></div></div><h3 style="overflow-wrap: break-word; hyphens: manual; font-size: 32px; font-family: &quot;Source Serif&quot;, &quot;Times New Roman&quot;, serif; margin-right: 0; margin-left: 0; line-height: 1.1; position: relative; grid-column: 1 / -1; color: rgba(62, 73, 81, 1); padding-left: 20px !important; padding-right: 20px !important; margin-top: 20px !important"><font dir="auto" style="margin: 0; vertical-align: inherit">Geçerlilik</font></h3><div style="margin: 0; color: rgba(62, 73, 81, 1); font-family: &quot;Source Sans&quot;, Verdana, sans-serif; font-size: 14.4px; padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Geçerlilik koşulu:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">Belirsiz</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Maksimum geçerlilik süresi:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">10 yıl</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Geçerlilik için minimum yaş:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">18 yaş</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Geçerlilik süresi:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">10 yıl</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Uzatma mümkündür:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">Evet</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Toplam uzatma süresi:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">12</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Uzatma süresi:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">12 ay</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Geçerlilik ek bilgileri:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">Belge, en fazla 12 ay süreyle bir kez uzatılabilir. Onay niteliğindeki uzatma, yalnızca seyahatin uzunluğuna bağlı olarak gerekli süre için verilir.</font></p></div></div></div><h3 style="overflow-wrap: break-word; hyphens: manual; font-size: 32px; font-family: &quot;Source Serif&quot;, &quot;Times New Roman&quot;, serif; margin-right: 0; margin-left: 0; line-height: 1.1; position: relative; grid-column: 1 / -1; color: rgba(62, 73, 81, 1); padding-left: 20px !important; padding-right: 20px !important; margin-top: 20px !important"><font dir="auto" style="margin: 0; vertical-align: inherit">Geçerlilik</font></h3><div style="margin: 0; color: rgba(62, 73, 81, 1); font-family: &quot;Source Sans&quot;, Verdana, sans-serif; font-size: 14.4px; padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Geçerlilik koşulu:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">Belirsiz</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Maksimum geçerlilik süresi:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">2 yıl</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Geçerlilik için minimum yaş:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">0 yıl</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Geçerlilik için azami yaş sınırı:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">1 yıl</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Geçerlilik süresi:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">12 ay</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Uzatma mümkündür:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">Evet</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Toplam uzatma süresi:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">12</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Uzatma süresi:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">12 ay</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Geçerlilik ek bilgileri:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">Belge, en fazla 12 ay süreyle bir kez uzatılabilir. Onay niteliğindeki uzatma, yalnızca seyahatin uzunluğuna bağlı olarak gerekli süre için verilir.</font></p></div></div></div><h3 style="overflow-wrap: break-word; hyphens: manual; font-size: 32px; font-family: &quot;Source Serif&quot;, &quot;Times New Roman&quot;, serif; margin-right: 0; margin-left: 0; line-height: 1.1; position: relative; grid-column: 1 / -1; color: rgba(62, 73, 81, 1); padding-left: 20px !important; padding-right: 20px !important; margin-top: 20px !important"><font dir="auto" style="margin: 0; vertical-align: inherit">Geçerlilik</font></h3><div style="margin: 0; color: rgba(62, 73, 81, 1); font-family: &quot;Source Sans&quot;, Verdana, sans-serif; font-size: 14.4px; padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Geçerlilik koşulu:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">Belirsiz</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Maksimum geçerlilik süresi:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">5 yıl</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Geçerlilik için minimum yaş:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">2 yıl</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Geçerlilik için azami yaş sınırı:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">17 yıl</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Geçerlilik süresi:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">5 yıl</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Uzatma mümkündür:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">Evet</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Toplam uzatma süresi:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">12</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Uzatma süresi:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">12 ay</font></p></div></div><div style="margin: 0; display: grid; flex-direction: column; gap: 30px; grid-template-columns: repeat(12, minmax(0, 1fr)); padding-left: 20px !important; padding-right: 20px !important"><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 4"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><strong style="margin: 0"><font dir="auto" style="margin: 0; vertical-align: inherit">Geçerlilik ek bilgileri:</font></strong></p></div><div style="margin: 0; display: grid; grid-auto-rows: max-content; gap: 30px 0; grid-column-end: span 8"><p style="overflow-wrap: break-word; hyphens: manual; font-size: 20px; margin: 0 !important"><font dir="auto" style="margin: 0; vertical-align: inherit">Belge, en fazla 12 ay süreyle bir kez uzatılabilir. Onay niteliğindeki uzatma, yalnızca seyahatin uzunluğuna bağlı olarak gerekli süre için verilir.</font></p></div></div></div>', N'be6238d2ca3248bc9201d079170be601.png', 2, '2026-09-26 15:18:41.527', 16, N'00588ff5684e432b984e145f35aaff84.html', 1, 0),
            (8, N'Sınır Kapılarında 18 Yaş Altı Yabancıların Tahdit ve Ceza İşlemleri', N'<li><p><b>Aşama 1 (Belge Kontrolü):</b> Pasaport veya ikame belgeler üzerinden resmi olarak anne/baba tespiti yapılır. Tespit edilirse ceza bunlardan birine yazılır.</p></li><li><p><b>Aşama 2 (Beyan Yöntemi):</b> Belgeyle ispatlanamıyorsa, anne veya babanın sözlü beyanı esas alınır.</p></li><li><p><b>Aşama 3 (Resmi Vasilik/Velayet):</b> Anne-baba dışında velayeti elinde bulunduran 3. bir kişi varsa (ve bunu resmi mahkeme kararı/belge ile kanıtlayabiliyorsa) ceza bu kişiye yazılır.</p></li><li><p><b>Aşama 4 (İstisnai Durum - Akrabalar):</b> Birlikte seyahat etme izin belgesi (muvafakatname) olsa dahi; büyükanne, büyükbaba, amca, teyze, hala gibi diğer akrabaların üzerine <b>ceza kaydı girilemez</b>. Bu durumda veri girişi doğrudan <b>çocuğun kendi adına</b> yapılır.</p></li>', N'f5608cd1370f4e29a9dee17bf877d238.png', 2, '2026-09-26 15:19:04.377', 2, NULL, 1, 0),
            (9, N'Göç İdaresi Başkanlığı 2024/5 Genelgesi ve Tahdit Kodları Uzmanlık Sınavı (Üst Seviye)', N'<h3>Öğrenme Kazanımları</h3><ul style="line-height: 1.15 !important"><li><p style="line-height: 1.15 !important"><span style="line-height: 1.15 !important; margin-top: 0 !important">Vize/İkamet/Çalışma izni ihlallerinde süreye ve başvuru şekline (kendiliğinden/terke davet/sınır dışı) göre uygulanan <b style="line-height: 1.15 !important; margin-top: 0 !important">"Ç" kodlarının farklarını ve giriş yasağı sürelerini</b> tam olarak analiz edebilme</span><span style="line-height: 1.15 !important; margin-top: 0 !important"></span><span style="line-height: 1.15 !important; margin-top: 0 !important">.</span></p></li><li><p style="line-height: 1.15 !important"><span style="line-height: 1.15 !important; margin-top: 0 !important"><b style="line-height: 1.15 !important; margin-top: 0 !important">"G" ve "N" kodlarının</b> hukuki niteliklerini (Kamu Güvenliği, Ön İzin, İdari Para Cezaları) ayırt edebilme</span><span style="line-height: 1.15 !important; margin-top: 0 !important"></span><span style="line-height: 1.15 !important; margin-top: 0 !important">.</span></p></li><li><p style="line-height: 1.15 !important"><span style="line-height: 1.15 !important; margin-top: 0 !important"><b style="line-height: 1.15 !important; margin-top: 0 !important">Mavi Kart hamilleri, 18 yaşından küçükler ve istisnai kişilerin</b> tahdit kodları karşısındaki hukuki statülerini değerlendirebilme</span><span style="line-height: 1.15 !important; margin-top: 0 !important"></span><span style="line-height: 1.15 !important; margin-top: 0 !important">.</span></p></li><li style="line-height: 1.15 !important; margin-top: 0 !important"><p><span style="line-height: 1.15 !important; margin-top: 0 !important">Özel meşruhatlı vize, mücbir sebepler ve tahdit kodlarının resen veya talimatla kaldırılması süreçlerini yönetebilme</span><span style="line-height: 1.15 !important; margin-top: 0 !important"></span><span style="line-height: 1.15 !important; margin-top: 0 !important">.<br></span><img src="/files/Egitim/cd59b81f-2501-4b65-8b69-acbb6fc62e95_Gemini_Generated_Image_log06tlog06tlog0 (1).png" style="width: 50%"><br></p><p><br></p><h1><span style="line-height: 1.15 !important; margin-top: 0 !important">"Ç" Tahdit Kodları Hiyerarşisi<br></span></h1><blockquote style=""><font>[ Ç-113 ] ──&gt; Yasa Dışı Giriş-Çıkış / Teşebbüs ──────────────&gt; 5 Yıl Yasal Yasağı<br></font><font>&nbsp; [ Ç-114 ] ──&gt; Adli İşlem Yapılan Yabancılar ─────────────────&gt; 3 Yıl Yasal Yasağı<br></font><font>&nbsp; [ Ç-115 ] ──&gt; Cezaevinden Tahliye Olan Yabancılar ───────────&gt; 5 Yıl Yasal Yasağı<br></font><font>&nbsp; [ Ç-116 ] ──&gt; Geçimini Meşru Olmayan Yoldan Sağlayan ────────&gt; 5 Yıl Yasal Yasağı<br></font><font>&nbsp; [ Ç-117 ] ──&gt; Çalışma İzni Olmadan Çalışan Yabancı ──────────&gt; 1 Yıl Yasal Yasağı<br></font><font>&nbsp; [ Ç-118 ] ──&gt; Bulaşıcı Hastalık (Kamu Sağlığı Threat) ───────&gt; 5 Yıl Yasal Yasağı<br></font><font>&nbsp; [ Ç-141 ] ──&gt; Uluslararası Terörizm Faaliyetleri ────────────&gt; 5 Yıl Yasal Yasağı<br></font><font>&nbsp; [ Ç-150 ] ──&gt; Sahte Belge ile Giriş/Çıkış Teşebbüsü ─────────&gt; 5 Yıl Yasal Yasağı<br></font><font>&nbsp; [ Ç-184 ] ──&gt; Çatışma Bölgesi Bağlantılı / INAD Yolcu ──────&gt; 5 Yıl Yasal Yasağı<br><br></font></blockquote><img src="/files/Egitim/5d4a18ba-c8d8-4f03-a94c-089a84249eca_Gemini_Generated_Image_log06tlog06tlog0 (3).png" style="width: 50%"><img src="/files/Egitim/bdb3d7e3-cf56-480d-9949-713614dae3a0_Gemini_Generated_Image_log06tlog06tlog0 (2).png" style="width: 50%"><blockquote style=""><font><br></font></blockquote><h1 style=""><font><span style="line-height: 1.15 !important; margin-top: 0 !important"></span></font></h1><p></p></li></ul>', N'cc150809ea2c4b669b9a55871a9e0117.png', 2, '2026-09-26 15:19:33.173', 2, NULL, 1, 0),
            (10, N'6458 sayılı Yabancılar ve Uluslararası Koruma Kanunu', N'<p><img src="/files/Egitim/4ae899c0-3963-4e87-99ce-defdea59924a_Gemini_Generated_Image_sqcbcesqcbcesqcb (1).png" style="width: 741px"><br></p>', N'8818d66a55894e5b83bf011392549063.png', 2, '2026-09-26 15:19:58.280', 1, NULL, 1, 0),
            (11, N'Düzensiz Göçmen İşlemleri ve 2019/5 Sayılı Genelge Uygulama Eğitimi', N'<h3>A. Yasal Dayanak ve Temel İlkeler</h3><ul><li><p><strong>Mevzuat:</strong> 6458 sayılı Yabancılar ve Uluslararası Koruma Kanunu (YUKK) ve YUKK Uygulama Yönetmeliği.</p></li><li><p><strong>Amaç:</strong> Göç İdaresi Başkanlığı, Emniyet Genel Müdürlüğü, Jandarma Genel Komutanlığı, Sahil Güvenlik Komutanlığı, Kara Kuvvetleri Komutanlığı ve Gümrük Muhafaza arasında uygulama birliğini sağlamak.</p></li></ul><h3>B. Yakalama ve Evrak Tanzim Süreçleri</h3><ol><li><p><strong>Zorunlu Belgeler:</strong> Resmi yazı, isim listesi, yakalama/üst arama/idari yaptırım tutanakları, durum bildirir sağlık raporu, parmak izi kayıtları ve UYAP sorguları. Fuhuş/konsomasyon durumlarında ek olarak bulaşıcı hastalık/kan testi raporu eklenir.</p></li><li><p><strong>Karar Süreleri (48 Saat Kuralı):</strong> Geri gönderme merkezi (GGM) bulunmayan illerde, evrakların kolluk tarafından İl Göç İdaresi Müdürlüğüne eksiksiz ve fiziki olarak teslim edilmesinden itibaren <strong>en geç 48 saat içinde</strong> idari kararlar (sınır dışı, idari gözetim, terke davet vb.) alınır. Yabancılar bu süre zarfında kolluk birimlerince muhafaza edilir.</p></li><li><p><strong>GGM Bulunan İller:</strong> GGM kapasitesi müsaitse mülakat ve kararlar sonrası teslim yapılır. Kapasite yetersizse GGM olmayan illerdeki 48 saatlik prosedür uygulanır.</p></li></ol><h3>C. Kolluk Kuvvetlerinin Özel Görev Dağılımı</h3><ul><li><p><strong>Kara Kuvvetleri Komutanlığı (KKK):</strong> Sınırda yakalanan yabancılar yetkili genel kolluğa teslim edilir. Yakalama tutanağı, üst arama tutanağı ve sağlık raporu KKK tarafından; diğer belgeler teslim alan kollukça düzenlenir.</p></li><li><p><strong>Sahil Güvenlik Komutanlığı (SGK):</strong> SGK Karakol/Destek Timi yoksa yakalama tutanağı, isim listesi ve el konulan eşya tutanağı ile karaya çıkılan ilk yerdeki genel kolluğa teslim edilir.</p></li><li><p><strong>Sevk Güvenliği ve Yol Güzergahı:</strong> Sevklerde güvenlik ve güzergah belirleme sorumluluğu genel kolluk kuvvetlerindedir. Risk değerlendirmesi İl Göç İdaresi görüşü alınarak kollukça yapılır; anlaşmazlıklarda kararı <strong>Valilik / Mülki İdare Amiri</strong> verir.</p></li></ul><h3>D. İdari Gözetim ve Sınır Dışı İstisnaları (Madde 55)</h3><ol><li><p><strong>Sınır Dışı Edilemeyecekler (YUKK Madde 55):</strong> Sınır dışı edileceği ülkede işkenceye, ölüm cezasına veya insanlık dışı muameleye maruz kalacağı konusunda ciddi emare bulunanlar, ciddi sağlık sorunu/gebelik/yaşlılığı olanlar, tedavisi devam edenler vb.</p></li><li><p><strong>İstisna Uygulaması:</strong> Madde 55 kapsamındaki yabancılar ve <strong>18 yaşından küçük çocuklar</strong> hakkında sınır dışı etme ve idari gözetim kararı <strong>alınamaz</strong>. Hakkında sınır dışı kararı alındıktan sonra Madde 55 kapsamında olduğu anlaşılanların kararları derhal geri alınır.</p></li><li><p><strong>İdari Gözetim Süreleri:</strong> Kararlar ilk etapta <strong>6 ay</strong> süreli alınır. Her ay düzenli olarak (veya gerekirse derhal) devamı/sonlandırılması yönünde değerlendirme yapılır.</p></li></ol><h3>E. Tebligat ve Tercümanlık Esasları</h3><ul><li><p><strong>7201 Sayılı Tebligat Kanunu:</strong> Tebligatlarda esas kural 7201 sayılı Kanundur. Kararlar yabancıya anladığı dilde tebliğ edilir.</p></li><li><p><strong>El Yazısı İbaresi:</strong> Tercüman olmaksızın yapılan tebliğlerde yabancı, form üzerine kendi dilinde el yazısı ile <strong>"Okudum, anladım"</strong> yazar.</p></li><li><p><strong>İmtina (İmzalamama) Halinde:</strong> Yabancı imzadan imtina ederse nedeni yazdırılır; yazmak istemezse kolluk/göç personeli el yazısıyla "Tebligat Kanunu hükümleri anlatılarak tebligat yapılmıştır ancak yabancı imzadan imtina etmiştir" şerhi düşerek tercüman/hazirun ile birlikte imzalar.</p></li><li><p><strong>Okuma Yazması Olmayanlar:</strong> Tercüman metni okur ve "aslına sadık kalarak anlattım" ibaresiyle imzalar; yabancı "Bana anlatılanı anladım" ibaresiyle parmak basar.</p></li><li><p><strong>Tercüman Nitelikleri:</strong> 18 yaşından büyük, yabancı ile akrabalığı veya çıkar çatışması/menfaat ilişkisi bulunmayan kişiler görevlendirilebilir.</p></li></ul><h3>F. Harcama ve Mali Mükellefiyetler</h3><ul><li><p><strong>Seyahat Masrafları:</strong> Masrafların yabancı tarafından karşılanması esastır. Biletini kendisi alan yabancıya tahdit konulmaz.</p></li><li><p><strong>Tahdit Veri Girişi:</strong> Devlet (İl Göç İdaresi) tarafından karşılanan her türlü seyahat ve belge masrafı tutarında yabancıya <strong>tahdit (giriş yasağı) veri girişi</strong> yapılır. Sınır dışı gerçekleştirilemezse konulan tahdit kaldırılır.</p></li><li><p><strong>Refakatçi Kolluk Harcırahları:</strong> Göç İdaresi Genel Müdürlüğü onayı ile yurt dışına mevcutlu refakat eden kolluk personelinin bilet ve harcırahları İl Göç İdaresi bütçesinden ödenir. Mücbir sebep olmaksızın fazladan yurt dışında geçirilen süreler için harcırah ödenmez.</p></li><li><p><strong>İaşe ve Acil İhtiyaçlar:</strong> GGM dışındaki kolluk muhafaza alanlarında geçen sürelerdeki iaşe, tercüman ve acil ihtiyaç giderleri İl Göç İdaresi bütçesinden karşılanır.</p></li></ul>', N'a05e515815414463a38c7808df232bfa.png', 2, '2026-09-26 15:20:20.963', 2, NULL, 1, 0),
            (13, N'PASAPORT KANUNU KRİTİK NOKTALAR', N'<h3>1. Pasaport Türleri ve Verilme Şartları</h3><ul><li><p><b>Hususi Damgalı Pasaport (Yeşil):</b> TBMM eski üyeleri, eski bakanlar, 1., 2. ve 3. derece kadrolarda bulunan veya bu kadrolar karşılık gösterilmek suretiyle sözleşmeli olarak çalışan devlet memurları ile birinci sınıf olup sınıfı ayrılmayan hakim ve savcılara verilir. Büyükşehir, il ve ilçe belediye başkanlarına <b>görevleri süresince</b> hususi damgalı pasaport verilir.</p></li><li><p><b>Hizmet Damgalı Pasaport (Gri):</b> Hükümetçe, özel idarelerce veya belediyelerce resmi vazifeyle dış memleketlere gönderilen veya dış memleketlerde vazifeye alınanlara, Türkiye Cumhuriyeti''nin üyesi bulunduğu uluslararası kuruluşlarda memur statüsünde çalışanlara verilir. Hususi veya diplomatik pasaport hakkı olmayan kişilere tahsis edilir.</p></li><li><p><b>Diplomatik Pasaport (Siyah):</b> Cumhurbaşkanı, TBMM üyeleri, Cumhurbaşkanı yardımcıları, bakanlar, Anayasa Mahkemesi başkanı ve üyeleri, Yargıtay, Danıştay, Uyuşmazlık Mahkemesi başkan ve üyeleri, Genelkurmay Başkanı, Diyanet İşleri Başkanı, büyükelçiler gibi devletin en üst düzey makam sahiplerine ve emekliliklerinde belirli üst düzey görevlilere verilir.</p></li></ul><h3>2. Hak Sahiplerinin Eş ve Çocuklarının Durumu</h3><ul><li><p><b>Eşler:</b> Hususi, Hizmet ve Diplomatik pasaport hakkı olanların eşlerine de durumlarına uygun pasaport düzenlenir.</p></li><li><p><b>Çocuklar:</b> Hususi ve Hizmet damgalı pasaport hak sahiplerinin çocuklarına pasaport verilebilmesi için:</p><ul><li><p>Ergin olmamaları (18 yaşını doldurmamış olmaları), OR</p></li><li><p>Ergin olsalar bile <b>25 yaşını doldurmamış olmaları</b>, evli bulunmamaları, iş sahibi olmamaları ve öğrenime devam etmeleri gerekir.</p></li><li><p>Bedensel, zihinsel veya ruhsal engellerinden en az biri nedeniyle sürekli bakıma muhtaç durumda olduğu resmi sağlık kurumlarının sağlık kurulu raporu ile belgelenen çocuklara <b>yaş sınırı uygulanmaksızın</b> pasaport verilir.</p></li></ul></li></ul><h3>3. Pasaport Vermeye Yetkili Makamlar</h3><ul><li><p><b>Yurt içinde:</b> İçişleri Bakanlığı (Nüfus ve Vatandaşlık İşleri Genel Müdürlüğü ve valilikler).</p></li><li><p><b>Yurt dışında:</b> Dışişleri Bakanlığı yetkisi altında Türkiye Cumhuriyeti Başkonsoloslukları ve Büyükelçilik Konsolosluk Şubeleri.</p></li><li><p><b>Diplomatik Pasaport:</b> Yalnızca Dışişleri Bakanlığı tarafından verilir.</p></li></ul><h3>4. Giriş-Çıkış Yasağı ve Sınırdışı Etme</h3><ul><li><p>Türkiye Cumhuriyeti sınırlarına giriş ve çıkışlar ancak yetkili makamlarca belirlenen <b>sınır kapılarından</b> ve geçerli pasaport veya pasaport yerine geçen belgelerle yapılır.</p></li><li><p>Haklarında adli kontrol kararı veya yurt dışına çıkış yasağı bulunan kişilerin pasaportları iptal edilebilir ya da yenisi verilmeyebilir.</p></li></ul>', N'9a587077a84640b28e7292e270b6b7a8.png', 2, '2026-09-26 15:20:54.403', 5, NULL, 1, 0),
            (14, N'Bulgaristan Umuma Mahsus Pasaport', N'Bulgaria - National Passport - 011 - Second portrait on page 3 kaynağından oluşturulan Türkçe eğitim içeriği.', N'5023350c5b2641dfb9c6ba3820f50088.jpg', 2, '2026-09-26 15:23:42.167', 16, N'4effb47d180545cbbcb9738d8a74de89.html', 1, 0);
        SET IDENTITY_INSERT [dbo].[Courses] OFF;
        PRINT 'Tablo [dbo].[Courses] icin 7 kayit eklendi.';
    END
END
GO

-- --------------------------------------------------------------------------
-- Veri: [dbo].[CourseContents]
-- --------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[CourseContents]', N'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dbo].[CourseContents])
    BEGIN
        SET IDENTITY_INSERT [dbo].[CourseContents] ON;
        INSERT INTO [dbo].[CourseContents] ([ContentId], [CourseId], [ContentType], [ContentTitle], [FilePath], [CreatedDate], [ContentDescription]) VALUES
            (5, 7, N'HTML', N'Belge: DNK-AO-06001 Türkçe Eğitim İçeriği', N'f79577ec939f49c9ab3230bcfa0a8e07.html', '2026-09-26 15:18:41.633', N'Kaydedilmiş web sayfasından güvenli biçimde oluşturulmuştur.'),
            (6, 8, N'HTML', N'İçerikler', N'993b0826e65741e5ae158dfe34a9c00b.png', '2026-09-26 15:19:04.420', N'<p>Göç İdaresi Genel Müdürlüğü''nün bu resmi yazısını temel alarak, sınır kapılarında çalışan pasaport kontrol memurları, vize memurları veya göç uzmanları için hazırlayabileceğiniz bir <b data-path-to-node="0" data-index-in-node="182">eğitim/kurs içeriği</b> taslağı ve bu içeriği pekiştirecek <b data-path-to-node="0" data-index-in-node="237">4 şıklı 3 adet soru</b> hazırladım.<br><br></p><h2 data-path-to-node="2">Kurs İçeriği: Sınır Kapılarında 18 Yaş Altı Yabancıların Tahdit ve Ceza İşlemleri</h2><h3 data-path-to-node="3">1. Eğitimin Amacı</h3><p data-path-to-node="4">Sınır kapılarından çıkış veya giriş ihlali yapan 18 yaşından küçük yabancı uyruklu çocuklara uygulanacak idari para cezası veri girişlerinin (tahdit işlemlerinin) yasal mevzuata uygun, doğru kişiler adına tesis edilmesini sağlamak.</p><h3 data-path-to-node="5">2. Temel Dayanak</h3><ul data-path-to-node="6"><li><p data-path-to-node="6,0,0"><b data-path-to-node="6,0,0" data-index-in-node="0">2020/17 Sayılı Tahdit Genelgesi (Madde 18/2-a):</b> 18 yaşından küçük yabancıların idari para cezaları refakatindeki kişinin cezasına eklenir. Yanlarında refakatçi yoksa ceza kaydı doğrudan çocuğun kendi adına açılır.</p></li></ul>'),
            (7, 9, N'Resim', N'İlgili Genelge İçeriği', N'3a957dd7b4ec4d75954f9fc959f00b5b.png', '2026-09-26 15:19:33.223', N'<p><img src="/files/Egitim/6e3ca50d-8055-4e3f-b947-af3364841a8a_Gemini_Generated_Image_log06tlog06tlog0 (3).png" data-filename="Gemini_Generated_Image_log06tlog06tlog0 (3).png" style="width: 744.8px;"><br><img src="/files/Egitim/3435f441-edf4-482f-a7ac-6767189bf21c_Gemini_Generated_Image_log06tlog06tlog0 (2).png" data-filename="Gemini_Generated_Image_log06tlog06tlog0 (2).png" style="width: 744.8px;"><img src="/files/Egitim/c9f05817-8a34-4c3e-8925-2084d4f5bd36_Gemini_Generated_Image_log06tlog06tlog0 (1).png" data-filename="Gemini_Generated_Image_log06tlog06tlog0 (1).png" style="width: 744.8px;"><br></p>'),
            (8, 10, N'Resim', N'Yabancılar ve Uluslararası Koruma Kanunu (6458 S.K.)', N'134ceb6a0ebc4360ba923a410962de65.png', '2026-09-26 15:19:58.310', N'<p><img src="/files/Egitim/d9d5cda3-386d-464e-8d06-6b206d53a203_Gemini_Generated_Image_sqcbcesqcbcesqcb (1).png" data-filename="Gemini_Generated_Image_sqcbcesqcbcesqcb (1).png" style="width: 744px;"><br></p>'),
            (9, 11, N'HTML', N'İçeriğe bak', N'63056029419b48259d9b0585113b08d7.png', '2026-09-26 15:20:20.993', N'


    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Düzensiz Göç Mevzuatı Görsel Eğitim Kartları</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&amp;display=swap" rel="stylesheet">
    <script>
        tailwind.config = {
            darkMode: ''class'',
            theme: {
                extend: {
                    fontFamily: {
                        sans: [''Inter'', ''sans-serif''],
                    },
                    colors: {
                        darkbg: ''#0B0F17'',
                        cardbg: ''#151C28'',
                        bordercolor: ''#2A3548'',
                        accentblue: ''#3B82F6'',
                        accentamber: ''#F59E0B'',
                        accentred: ''#EF4444'',
                        accentemerald: ''#10B981'',
                        accentpurple: ''#8B5CF6''
                    }
                }
            }
        }
    </script>
    <style>
        body { font-family: ''Inter'', sans-serif; background-color: #0B0F17; color: #F1F5F9; }
        .glass-card {
            background: rgba(21, 28, 40, 0.85);
            backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.08);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);
        }
        .glow-blue { box-shadow: 0 0 25px rgba(59, 130, 246, 0.25); }
        .glow-red { box-shadow: 0 0 25px rgba(239, 68, 68, 0.25); }
        .glow-amber { box-shadow: 0 0 25px rgba(245, 158, 11, 0.25); }
    </style>



    <!-- Header Section -->
    <header class="w-full max-w-6xl mb-8 text-center sm:text-left flex flex-col sm:flex-row justify-between items-center border-b border-slate-800 pb-6 gap-4">
        <div>
            <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-blue-950/60 border border-blue-500/30 text-blue-400 text-xs font-semibold uppercase tracking-wider mb-2">
                <i class="fa-solid fa-shield-halved"></i> 2019/5 Genelge Eğitimi
            </div>
            <h1 class="text-2xl sm:text-3xl font-extrabold text-white tracking-tight">
                Düzensiz Göç Mevzuatı <span class="text-transparent bg-clip-text bg-gradient-to-r from-blue-400 to-purple-500">Görsel Eğitim Kartları</span>
            </h1>
            <p class="text-slate-400 text-sm mt-1">Uygulama Talimatı Konu Anlatımı ve Akış Şemaları</p>
        </div>

        <!-- Navigation Tabs -->
        <div class="flex items-center bg-slate-900/90 p-1.5 rounded-xl border border-slate-800 gap-1">
            <button onclick="switchTab(1)" id="tab-btn-1" class="tab-btn px-4 py-2 rounded-lg text-xs font-semibold transition-all duration-200 bg-blue-600 text-white shadow-lg shadow-blue-600/30">
                <i class="fa-solid fa-clock-rotate-left mr-1.5"></i> Görsel 1: 48 Saat Kuralı
            </button>
            <button onclick="switchTab(2)" id="tab-btn-2" class="tab-btn px-4 py-2 rounded-lg text-xs font-semibold transition-all duration-200 text-slate-400 hover:text-white hover:bg-slate-800">
                <i class="fa-solid fa-ban mr-1.5"></i> Görsel 2: İstisnalar (M.55)
            </button>
            <button onclick="switchTab(3)" id="tab-btn-3" class="tab-btn px-4 py-2 rounded-lg text-xs font-semibold transition-all duration-200 text-slate-400 hover:text-white hover:bg-slate-800">
                <i class="fa-solid fa-sitemap mr-1.5"></i> Görsel 3: Görev &amp; Maliye
            </button>
        </div>
    </header>

    <!-- SLIDE / CARD 1: 48 Saat Kuralı ve Evrak Akışı -->
    <main id="card-1" class="slide-card w-full max-w-6xl">
        <div class="glass-card rounded-2xl p-6 sm:p-8 glow-blue relative overflow-hidden">
            <!-- Background Watermark/Accent -->
            <div class="absolute -right-16 -top-16 w-64 h-64 bg-blue-600/10 rounded-full blur-3xl pointer-events-none"></div>

            <!-- Card Header -->
            <div class="flex items-center justify-between border-b border-slate-800 pb-4 mb-6">
                <div class="flex items-center gap-3">
                    <div class="w-12 h-12 rounded-xl bg-blue-500/10 border border-blue-500/30 flex items-center justify-center text-blue-400 text-xl font-bold">
                        01
                    </div>
                    <div>
                        <h2 class="text-xl font-bold text-white">GÖRSEL 1: Yakalama, Evrak Düzeni ve 48 Saat Kuralı</h2>
                        <p class="text-xs text-slate-400">GGM Bulunmayan İllerde Yürütülecek Zaman Kritik Süreçler</p>
                    </div>
                </div>
                <span class="hidden sm:inline-block px-3 py-1 rounded-md bg-slate-800 text-slate-300 text-xs border border-slate-700">
                    <i class="fa-solid fa-file-signature text-blue-400 mr-1"></i> Madde 4 Uygulaması
                </span>
            </div>

            <!-- Grid Content -->
            <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">

                <!-- Required Documents Checklist -->
                <div class="lg:col-span-5 bg-slate-900/80 rounded-xl p-5 border border-slate-800 flex flex-col justify-between">
                    <div>
                        <h3 class="text-sm font-bold text-blue-400 uppercase tracking-wider mb-3 flex items-center gap-2">
                            <i class="fa-solid fa-folder-closed"></i> Zorunlu Evrak Listesi
                        </h3>
                        <ul class="space-y-2.5 text-xs text-slate-300">
                            <li class="flex items-start gap-2.5 bg-slate-800/40 p-2 rounded-lg border border-slate-800">
                                <i class="fa-solid fa-check text-emerald-400 mt-0.5"></i>
                                <span><strong>İl Göç İdaresine Hitaben Yazı:</strong> Resmi üst yazı ve olay özeti.</span>
                            </li>
                            <li class="flex items-start gap-2.5 bg-slate-800/40 p-2 rounded-lg border border-slate-800">
                                <i class="fa-solid fa-check text-emerald-400 mt-0.5"></i>
                                <span><strong>İsim Listesi:</strong> Belgeler yoksa beyana dayalı kimlik bilgileri.</span>
                            </li>
                            <li class="flex items-start gap-2.5 bg-slate-800/40 p-2 rounded-lg border border-slate-800">
                                <i class="fa-solid fa-check text-emerald-400 mt-0.5"></i>
                                <span><strong>Tutanaklar:</strong> Yakalama, üst arama ve idari yaptırım tutanağı.</span>
                            </li>
                            <li class="flex items-start gap-2.5 bg-slate-800/40 p-2 rounded-lg border border-slate-800">
                                <i class="fa-solid fa-check text-emerald-400 mt-0.5"></i>
                                <span><strong>Sağlık &amp; Bulaşıcı Raporu:</strong> Durum bildirir rapor (Fuhuş/konsomasyonda kan testi eklenir).</span>
                            </li>
                            <li class="flex items-start gap-2.5 bg-slate-800/40 p-2 rounded-lg border border-slate-800">
                                <i class="fa-solid fa-check text-emerald-400 mt-0.5"></i>
                                <span><strong>Sistem Kayıtları:</strong> Parmak izi, UYAP sorguları ve adli belgeler.</span>
                            </li>
                        </ul>
                    </div>
                    <div class="mt-4 p-3 bg-amber-500/10 border border-amber-500/20 rounded-lg text-amber-300 text-xs flex items-center gap-2">
                        <i class="fa-solid fa-triangle-exclamation text-amber-400 text-base"></i>
                        <span>Parmak izi/kan testi gecikirse yabancı <strong>kolluk alanında</strong> barındırılır.</span>
                    </div>
                </div>

                <!-- 48-Hour Workflow Diagram -->
                <div class="lg:col-span-7 bg-slate-900/80 rounded-xl p-5 border border-slate-800 flex flex-col justify-between">
                    <h3 class="text-sm font-bold text-blue-400 uppercase tracking-wider mb-4 flex items-center gap-2">
                        <i class="fa-solid fa-timeline"></i> GGM Olmayan İllerde 48 Saat Zaman Çizelgesi
                    </h3>

                    <!-- Visual Flow Steps -->
                    <div class="space-y-4 relative before:absolute before:inset-0 before:left-5 before:w-0.5 before:bg-slate-700">

                        <!-- Step 1 -->
                        <div class="relative pl-10">
                            <div class="absolute left-2 top-0 w-6 h-6 rounded-full bg-blue-600 border-2 border-slate-900 flex items-center justify-center text-xs font-bold text-white">1</div>
                            <div class="bg-slate-800/80 p-3 rounded-lg border border-slate-700">
                                <div class="flex justify-between items-center mb-1">
                                    <span class="text-xs font-bold text-white">Yakalama ve Evrak Teslimi</span>
                                    <span class="text-[10px] px-2 py-0.5 rounded bg-blue-900/80 text-blue-300 border border-blue-700/50">Başlangıç Noktası</span>
                                </div>
                                <p class="text-xs text-slate-300">Kolluk birimi evrakları hazırlar ve <strong>fiziki olarak</strong> İl Göç İdaresi''ne teslim eder.</p>
                            </div>
                        </div>

                        <!-- Step 2 -->
                        <div class="relative pl-10">
                            <div class="absolute left-2 top-0 w-6 h-6 rounded-full bg-amber-500 border-2 border-slate-900 flex items-center justify-center text-xs font-bold text-slate-950">2</div>
                            <div class="bg-slate-800/80 p-3 rounded-lg border border-amber-500/30">
                                <div class="flex justify-between items-center mb-1">
                                    <span class="text-xs font-bold text-amber-300">EN GEÇ 48 SAAT (İdari Karar)</span>
                                    <span class="text-[10px] px-2 py-0.5 rounded bg-amber-950 text-amber-400 border border-amber-800">Kollukta Muhafaza</span>
                                </div>
                                <p class="text-xs text-slate-300">Evrakların fiziki tesliminden itibaren <strong>en geç 48 saat içinde</strong> İl Göç İdaresi kararı (sınır dışı, idari gözetim vb.) alır. Bu sürede yabancı kollukça muhafaza edilir.</p>
                            </div>
                        </div>

                        <!-- Step 3 -->
                        <div class="relative pl-10">
                            <div class="absolute left-2 top-0 w-6 h-6 rounded-full bg-emerald-500 border-2 border-slate-900 flex items-center justify-center text-xs font-bold text-slate-950">3</div>
                            <div class="bg-slate-800/80 p-3 rounded-lg border border-slate-700">
                                <div class="flex justify-between items-center mb-1">
                                    <span class="text-xs font-bold text-emerald-400">EN GEÇ 48 SAAT (İcra ve Sevk)</span>
                                    <span class="text-[10px] px-2 py-0.5 rounded bg-emerald-950 text-emerald-300 border border-emerald-800">Kolluk İcrası</span>
                                </div>
                                <p class="text-xs text-slate-300">Kararın kolluğa bildirilmesinden itibaren <strong>en geç 48 saat içinde</strong> kolluk birimi sevk veya işlem gereğini yerine getirir.</p>
                            </div>
                        </div>

                    </div>

                    <div class="mt-4 p-2.5 bg-blue-950/40 rounded-lg border border-blue-800/40 text-[11px] text-slate-300 text-center">
                        <i class="fa-solid fa-circle-info text-blue-400 mr-1"></i> GGM bulunan illerde kapasite müsaitse mülakat ve kararlar sonrası teslim kabul edilir.
                    </div>
                </div>

            </div>
        </div>
    </main>

    <!-- SLIDE / CARD 2: İstisnalar (Madde 55) ve İdari Gözetim -->
    <main id="card-2" class="slide-card w-full max-w-6xl hidden">
        <div class="glass-card rounded-2xl p-6 sm:p-8 glow-red relative overflow-hidden">
            <!-- Background Watermark/Accent -->
            <div class="absolute -right-16 -top-16 w-64 h-64 bg-red-600/10 rounded-full blur-3xl pointer-events-none"></div>

            <!-- Card Header -->
            <div class="flex items-center justify-between border-b border-slate-800 pb-4 mb-6">
                <div class="flex items-center gap-3">
                    <div class="w-12 h-12 rounded-xl bg-red-500/10 border border-red-500/30 flex items-center justify-center text-red-400 text-xl font-bold">
                        02
                    </div>
                    <div>
                        <h2 class="text-xl font-bold text-white">GÖRSEL 2: Sınır Dışı ve İdari Gözetim İstisnaları</h2>
                        <p class="text-xs text-slate-400">YUKK Madde 55 Kapsamındaki Yabancılar ve Çocukların Durumu</p>
                    </div>
                </div>
                <span class="hidden sm:inline-block px-3 py-1 rounded-md bg-slate-800 text-slate-300 text-xs border border-slate-700">
                    <i class="fa-solid fa-shield-cat text-red-400 mr-1"></i> Hassas Gruplar
                </span>
            </div>

            <!-- Main Notice Banner -->
            <div class="mb-6 p-4 rounded-xl bg-red-950/60 border border-red-500/40 flex items-center gap-4">
                <div class="w-12 h-12 rounded-lg bg-red-500/20 text-red-400 flex items-center justify-center text-2xl shrink-0">
                    <i class="fa-solid fa-ban"></i>
                </div>
                <div>
                    <h3 class="text-sm font-bold text-red-200 uppercase tracking-wide">Kayıtsız Şartsız Yasak Kuralı</h3>
                    <p class="text-xs text-slate-300 mt-0.5">
                        6458 sayılı Kanun''un 55''inci maddesi kapsamındaki yabancılar ve <strong>18 yaşından küçük çocuklar</strong> hakkında <span class="text-red-400 font-bold underline">SINIR DIŞI ETME</span> ve <span class="text-red-400 font-bold underline">İDARİ GÖZETİM</span> kararı ALINAMAZ!
                    </p>
                </div>
            </div>

            <!-- Grid Content -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">

                <!-- Exemption 1 -->
                <div class="bg-slate-900/80 p-4 rounded-xl border border-slate-800 flex flex-col justify-between">
                    <div>
                        <div class="w-8 h-8 rounded-lg bg-purple-500/20 text-purple-400 flex items-center justify-center mb-3">
                            <i class="fa-solid fa-person-falling-burst"></i>
                        </div>
                        <h4 class="text-xs font-bold text-white mb-1">İşkence &amp; Ölüm Cezası Riski</h4>
                        <p class="text-[11px] text-slate-400">Sınır dışı edileceği ülkede işkenceye, insanlık dışı muameleye maruz kalacağı konusunda ciddi emare olanlar.</p>
                    </div>
                    <div class="mt-3 text-[10px] text-purple-400 font-semibold uppercase">Madde 55/1-a</div>
                </div>

                <!-- Exemption 2 -->
                <div class="bg-slate-900/80 p-4 rounded-xl border border-slate-800 flex flex-col justify-between">
                    <div>
                        <div class="w-8 h-8 rounded-lg bg-amber-500/20 text-amber-400 flex items-center justify-center mb-3">
                            <i class="fa-solid fa-notes-medical"></i>
                        </div>
                        <h4 class="text-xs font-bold text-white mb-1">Ciddi Sağlık / Yaşlılık / Gebelik</h4>
                        <p class="text-[11px] text-slate-400">Ciddi sağlık sorunu, yaşlılığı veya gebelik durumu nedeniyle seyahat etmesi hayati risk taşıyanlar.</p>
                    </div>
                    <div class="mt-3 text-[10px] text-amber-400 font-semibold uppercase">Madde 55/1-b</div>
                </div>

                <!-- Exemption 3 -->
                <div class="bg-slate-900/80 p-4 rounded-xl border border-slate-800 flex flex-col justify-between">
                    <div>
                        <div class="w-8 h-8 rounded-lg bg-emerald-500/20 text-emerald-400 flex items-center justify-center mb-3">
                            <i class="fa-solid fa-bed-pulse"></i>
                        </div>
                        <h4 class="text-xs font-bold text-white mb-1">Hayati Tedavisi Devam Edenler</h4>
                        <p class="text-[11px] text-slate-400">Hayati tehlike arz eden hastalığı için tedavisi devam etmekte olup gideceği ülkede tedavi imkanı olmayanlar.</p>
                    </div>
                    <div class="mt-3 text-[10px] text-emerald-400 font-semibold uppercase">Madde 55/1-c</div>
                </div>

                <!-- Exemption 4 -->
                <div class="bg-slate-900/80 p-4 rounded-xl border border-slate-800 flex flex-col justify-between">
                    <div>
                        <div class="w-8 h-8 rounded-lg bg-blue-500/20 text-blue-400 flex items-center justify-center mb-3">
                            <i class="fa-solid fa-child font-bold"></i>
                        </div>
                        <h4 class="text-xs font-bold text-white mb-1">18 Yaşından Küçük Çocuklar</h4>
                        <p class="text-[11px] text-slate-400">Çocuklar hakkında idari gözetim uygulanamaz. GGM''de barınması gerekirse ebeveyninin hanesine kaydedilir.</p>
                    </div>
                    <div class="mt-3 text-[10px] text-blue-400 font-semibold uppercase">Özel Koruma Esası</div>
                </div>

            </div>

            <!-- Bottom Detail Boxes -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="bg-slate-900/90 p-4 rounded-xl border border-slate-800 flex items-start gap-3">
                    <i class="fa-solid fa-rotate-left text-amber-400 text-lg mt-0.5"></i>
                    <div>
                        <h4 class="text-xs font-bold text-white">Kararın Kendiliğinden Geri Alınması Prosedürü</h4>
                        <p class="text-[11px] text-slate-300 mt-1">
                            Sınır dışı kararı alındıktan sonra kişinin Madde 55 kapsamında olduğu anlaşılırsa kararı <strong class="text-amber-400">DERHAL GERİ ALINIR</strong>. İstisna sebebi ortadan kalktığında durum yeniden değerlendirilerek sınır dışı kararı tanzim edilir.
                        </p>
                    </div>
                </div>

                <div class="bg-slate-900/90 p-4 rounded-xl border border-slate-800 flex items-start gap-3">
                    <i class="fa-solid fa-calendar-check text-blue-400 text-lg mt-0.5"></i>
                    <div>
                        <h4 class="text-xs font-bold text-white">İdari Gözetim Süresi ve Periyodik Değerlendirme</h4>
                        <p class="text-[11px] text-slate-300 mt-1">
                            İdari gözetim kararı ilk aşamada kural olarak <strong class="text-blue-400">6 AY</strong> süreli alınır. Alınan kararlar her halükarda <strong class="text-blue-400">AYLIK OLARAK (EN GEÇ 30 GÜNDE BİR)</strong> İl Göç İdaresi tarafından yeniden değerlendirilir.
                        </p>
                    </div>
                </div>
            </div>

        </div>
    </main>

    <!-- SLIDE / CARD 3: Kurumlar Arası İş Bölümü ve Harcamalar -->
    <main id="card-3" class="slide-card w-full max-w-6xl hidden">
        <div class="glass-card rounded-2xl p-6 sm:p-8 glow-amber relative overflow-hidden">
            <!-- Background Watermark/Accent -->
            <div class="absolute -right-16 -top-16 w-64 h-64 bg-amber-600/10 rounded-full blur-3xl pointer-events-none"></div>

            <!-- Card Header -->
            <div class="flex items-center justify-between border-b border-slate-800 pb-4 mb-6">
                <div class="flex items-center gap-3">
                    <div class="w-12 h-12 rounded-xl bg-amber-500/10 border border-amber-500/30 flex items-center justify-center text-amber-400 text-xl font-bold">
                        03
                    </div>
                    <div>
                        <h2 class="text-xl font-bold text-white">GÖRSEL 3: Kurumlar Arası Görev Dağılımı ve Mali Esaslar</h2>
                        <p class="text-xs text-slate-400">Askeri/Kolluk Sorumlulukları ve Seyahat/Tahdit Harcamaları</p>
                    </div>
                </div>
                <span class="hidden sm:inline-block px-3 py-1 rounded-md bg-slate-800 text-slate-300 text-xs border border-slate-700">
                    <i class="fa-solid fa-handshake-angle text-amber-400 mr-1"></i> Kurumsal İşbirliği
                </span>
            </div>

            <!-- Institutional Roles Grid -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-5 mb-6">

                <!-- Kara Kuvvetleri -->
                <div class="bg-slate-900/90 p-4 rounded-xl border border-slate-800 relative">
                    <div class="flex items-center gap-2 mb-3 border-b border-slate-800 pb-2">
                        <i class="fa-solid fa-person-military-rifle text-emerald-400 text-lg"></i>
                        <h3 class="text-xs font-bold text-white">Kara Kuvvetleri Komutanlığı</h3>
                    </div>
                    <ul class="space-y-2 text-[11px] text-slate-300">
                        <li class="flex items-start gap-1.5">
                            <i class="fa-solid fa-angle-right text-emerald-400 mt-0.5"></i>
                            <span>Sınır hattında yakalamayı gerçekleştirir.</span>
                        </li>
                        <li class="flex items-start gap-1.5">
                            <i class="fa-solid fa-angle-right text-emerald-400 mt-0.5"></i>
                            <span><strong>Kendi Hazırladığı Belgeler:</strong> Yakalama tutanağı, Üst arama tutanağı, Sağlık raporu.</span>
                        </li>
                        <li class="flex items-start gap-1.5">
                            <i class="fa-solid fa-angle-right text-emerald-400 mt-0.5"></i>
                            <span>Genel kolluğa teslim eder; diğer belgeleri teslim alan kolluk hazırlar.</span>
                        </li>
                    </ul>
                </div>

                <!-- Sahil Güvenlik -->
                <div class="bg-slate-900/90 p-4 rounded-xl border border-slate-800 relative">
                    <div class="flex items-center gap-2 mb-3 border-b border-slate-800 pb-2">
                        <i class="fa-solid fa-ship text-blue-400 text-lg"></i>
                        <h3 class="text-xs font-bold text-white">Sahil Güvenlik Komutanlığı</h3>
                    </div>
                    <ul class="space-y-2 text-[11px] text-slate-300">
                        <li class="flex items-start gap-1.5">
                            <i class="fa-solid fa-angle-right text-blue-400 mt-0.5"></i>
                            <span>Deniz alanlarında yakalama yapar.</span>
                        </li>
                        <li class="flex items-start gap-1.5">
                            <i class="fa-solid fa-angle-right text-blue-400 mt-0.5"></i>
                            <span>Karakol/Destek Timi yoksa <strong>karaya çıkılan ilk yerdeki</strong> genel kolluğa teslim eder.</span>
                        </li>
                        <li class="flex items-start gap-1.5">
                            <i class="fa-solid fa-angle-right text-blue-400 mt-0.5"></i>
                            <span>Yakalama tutanağı, isim listesi ve el konulan eşya tutanağı ile devreder.</span>
                        </li>
                    </ul>
                </div>

                <!-- Genel Kolluk & İl Göç -->
                <div class="bg-slate-900/90 p-4 rounded-xl border border-slate-800 relative">
                    <div class="flex items-center gap-2 mb-3 border-b border-slate-800 pb-2">
                        <i class="fa-solid fa-building-flag text-purple-400 text-lg"></i>
                        <h3 class="text-xs font-bold text-white">Genel Kolluk &amp; İl Göç İdaresi</h3>
                    </div>
                    <ul class="space-y-2 text-[11px] text-slate-300">
                        <li class="flex items-start gap-1.5">
                            <i class="fa-solid fa-angle-right text-purple-400 mt-0.5"></i>
                            <span><strong>Sevk Güvenliği ve Güzergah:</strong> Sorumluluk tamamen genel kolluk kuvvetindedir.</span>
                        </li>
                        <li class="flex items-start gap-1.5">
                            <i class="fa-solid fa-angle-right text-purple-400 mt-0.5"></i>
                            <span><strong>Yetki/Görev Anlaşmazlıkları:</strong> Kurumlar arası çıkan uyuşmazlıklarda kararı <strong class="text-amber-400">VALİLİK / MÜLKİ İDARE AMİRİ</strong> verir.</span>
                        </li>
                    </ul>
                </div>

            </div>

            <!-- Financial Provisions Box -->
            <div class="bg-slate-900/90 rounded-xl p-5 border border-slate-800">
                <h3 class="text-xs font-bold text-amber-400 uppercase tracking-wider mb-3 flex items-center gap-2">
                    <i class="fa-solid fa-coins"></i> Harcama, Seyahat Masrafları ve Tahdit (Giriş Yasağı) Esasları
                </h3>

                <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 text-xs">

                    <div class="bg-slate-800/50 p-3 rounded-lg border border-slate-800">
                        <div class="font-bold text-white mb-1 flex items-center gap-1.5">
                            <i class="fa-solid fa-ticket text-emerald-400"></i> Biletini Kendi Alanlar
                        </div>
                        <p class="text-[11px] text-slate-300">
                            Seyahat masraflarını kendi karşılayan yabancıya, bilet bedeline bağlı olarak <strong>TAHDİT (GİRİŞ YASAĞI) VERİ GİRİŞİ YAPILMAZ</strong>.
                        </p>
                    </div>

                    <div class="bg-slate-800/50 p-3 rounded-lg border border-slate-800">
                        <div class="font-bold text-white mb-1 flex items-center gap-1.5">
                            <i class="fa-solid fa-hand-holding-dollar text-red-400"></i> Devletçe Karşılanan Masraf
                        </div>
                        <p class="text-[11px] text-slate-300">
                            Bilet veya pasaport/seyahat belgesi İl Göç İdaresince ödenirse, <strong>ödenen miktar kadar mali tahdit</strong> kaydı işlenir. Sınır dışı gerçekleşmezse tahdit kaldırılır.
                        </p>
                    </div>

                    <div class="bg-slate-800/50 p-3 rounded-lg border border-slate-800">
                        <div class="font-bold text-white mb-1 flex items-center gap-1.5">
                            <i class="fa-solid fa-plane-departure text-blue-400"></i> Refakatçi Kolluk Harcırahı
                        </div>
                        <p class="text-[11px] text-slate-300">
                            Yurt dışı mevcutlu sevklerde <strong>GİGM yazılı onayı</strong> şarttır. Personelin bilet ve harcırahı İl Göç bütçesinden ödenir. Fazladan kalınan süreye harcırah ödenmez.
                        </p>
                    </div>

                </div>
            </div>

        </div>
    </main>

    <!-- Footer / Slide Switcher JS -->
    <footer class="mt-8 text-center text-slate-500 text-xs">
        2019/5 Sayılı İçişleri Bakanlığı Genelgesi Eğitim Materyali • Görsel Slayt Kartları
    </footer>

    <script>
        function switchTab(slideNum) {
            // Hide all slides
            document.querySelectorAll(''.slide-card'').forEach(el => {
                el.classList.add(''hidden'');
            });

            // Show target slide
            const targetSlide = document.getElementById(''card-'' + slideNum);
            if (targetSlide) {
                targetSlide.classList.remove(''hidden'');
            }

            // Reset tab button styles
            document.querySelectorAll(''.tab-btn'').forEach(btn => {
                btn.className = "tab-btn px-4 py-2 rounded-lg text-xs font-semibold transition-all duration-200 text-slate-400 hover:text-white hover:bg-slate-800";
            });

            // Set active tab style
            const activeBtn = document.getElementById(''tab-btn-'' + slideNum);
            if (activeBtn) {
                activeBtn.className = "tab-btn px-4 py-2 rounded-lg text-xs font-semibold transition-all duration-200 bg-blue-600 text-white shadow-lg shadow-blue-600/30";
            }
        }
    </script>

'),
            (11, 13, N'HTML', N'Pasaport Kanunu', N'f69a7fa60cd24f8a836ca565a91c0f70.html', '2026-09-26 15:20:54.440', N'


    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>5682 Sayılı Pasaport Kanunu (Çevrimdışı Sürüm)</title>
    <style>
        :root {
            --primary-color: #8b0000;
            --secondary-color: #2c3e50;
            --bg-color: #f8f9fa;
            --card-bg: #ffffff;
            --text-color: #2b2b2b;
            --border-color: #e0e0e0;
        }

        body {
            font-family: ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: var(--text-color);
            background-color: var(--bg-color);
            margin: 0;
            padding: 20px;
        }

        .container {
            max-width: 1000px;
            margin: 0 auto;
            background: var(--card-bg);
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
        }

        .header {
            text-align: center;
            border-bottom: 3px solid var(--primary-color);
            padding-bottom: 20px;
            margin-bottom: 30px;
        }

        .header h1 {
            color: var(--primary-color);
            margin: 0 0 10px 0;
            font-size: 26px;
            letter-spacing: 0.5px;
        }

        .header .meta-info {
            font-size: 14px;
            color: #666;
            display: flex;
            justify-content: center;
            gap: 20px;
            flex-wrap: wrap;
        }

        .section-title {
            background-color: var(--secondary-color);
            color: white;
            padding: 8px 15px;
            font-size: 16px;
            font-weight: bold;
            border-radius: 4px;
            margin-top: 30px;
            margin-bottom: 15px;
        }

        .article {
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px dotted var(--border-color);
        }

        .article-title {
            font-weight: bold;
            color: var(--primary-color);
            margin-bottom: 5px;
        }

        ul, ol {
            padding-left: 25px;
        }

        li {
            margin-bottom: 8px;
        }

        .highlight-box {
            background-color: #fff8e1;
            border-left: 4px solid #ffc107;
            padding: 15px;
            margin: 20px 0;
            border-radius: 0 4px 4px 0;
        }

        @media print {
            body { background: white; padding: 0; }
            .container { box-shadow: none; width: 100%; max-width: none; padding: 0; }
        }
    </style>



<div class="container">
    <div class="header">
        <h1>PASAPORT KANUNU</h1>
        <div class="meta-info">
            <span><strong>Kanun No:</strong> 5682</span>
            <span><strong>Kabul Tarihi:</strong> 15/7/1950</span>
            <span><strong>R.G. Tarihi:</strong> 24/7/1950</span>
            <span><strong>R.G. Sayısı:</strong> 7564</span>
        </div>
    </div>

    <div class="highlight-box">
        <strong>İnternetsiz Çevrimdışı Sürüm:</strong> Bu sayfa internet bağlantısı gerektirmeyen bağımsız CSS stilleri içerir.
    </div>

    <div class="section-title">BİRİNCİ BÖLÜM: GENEL HÜKÜMLER</div>

    <div class="article">
        <div class="article-title">Madde 1 – Türkiye Sınırlarından Giriş ve Çıkış</div>
        <p>Türk vatandaşları ile yabancılar, Türkiye sınırlarından ancak yetkili makamların tayin ettiği sınır kapılarından geçerli pasaport veya pasaport yerine geçen belgelerle girip çıkabilirler.</p>
    </div>

    <div class="article">
        <div class="article-title">Madde 2 – Pasaport Zorunluluğu</div>
        <p>Türkiye''ye giren veya Türkiye''den çıkan Türk vatandaşları ile yabancılar pasaport veya pasaport yerine geçen belgelerini sınır kapısındaki görevli memurlara göstermeye mecburdurlar.</p>
    </div>

    <div class="section-title">İKİNCİ BÖLÜM: PASAPORT TÜRLERİ VE HAK SAHİPLİĞİ</div>

    <div class="article">
        <div class="article-title">Madde 12 – Pasaport Türleri</div>
        <p>Türkiye Cumhuriyeti tarafından verilen pasaportlar şunlardır:</p>
        <ul>
            <li><strong>A) Diplomatik Pasaport (Siyah)</strong></li>
            <li><strong>B) Hususi Damgalı Pasaport (Yeşil)</strong></li>
            <li><strong>C) Hizmet Damgalı Pasaport (Gri)</strong></li>
            <li><strong>D) Umuma Mahsus Pasaport (Bordo)</strong></li>
        </ul>
    </div>

    <div class="article">
        <div class="article-title">Madde 13 – Diplomatik Pasaportlar</div>
        <p>Diplomatik pasaportlar, Dışişleri Bakanlığı ile Türkiye Cumhuriyeti Dış Temsilcilikleri tarafından Cumhurbaşkanı, TBMM Üyeleri, Cumhurbaşkanı Yardımcıları, Bakanlar, Anayasa Mahkemesi, Yargıtay ve Danıştay Başkanları ile Kanunda belirtilen üst düzey devlet görevlilerine verilir.</p>
    </div>

    <div class="article">
        <div class="article-title">Madde 14 – Hususi Damgalı Pasaportlar</div>
        <p>Hususi damgalı pasaportlar;</p>
        <ul>
            <li>TBMM eski üyeleri ve eski bakanlara,</li>
            <li>Birinci, ikinci ve üçüncü derece kadrolarda bulunan veya bu kadrolar karşılık gösterilmek suretiyle sözleşmeli olarak çalışan devlet memurlarına,</li>
            <li>Büyükşehir, il ve ilçe belediye başkanlarına (görevleri süresince),</li>
            <li>Hak sahiplerinin eşlerine ve 25 yaşını doldurmamış, evli olmayan, iş sahibi olmayan ve öğrenime devam eden çocuklarına verilir.</li>
        </ul>
    </div>

    <div class="article">
        <div class="article-title">Madde 14/B – Hizmet Damgalı Pasaportlar</div>
        <p>Hükümetçe, özel idarelerce veya belediyelerce resmi vazifeyle dış memleketlere gönderilenlere veya Türkiye Cumhuriyeti''nin üyesi bulunduğu uluslararası kuruluşlarda memur statüsünde çalışanlara görevleri süresince verilir.</p>
    </div>

    <div class="section-title">ÜÇÜNCÜ BÖLÜM: CEZAİ HÜKÜMLER</div>

    <div class="article">
        <div class="article-title">Madde 33 – Pasaportsuz Sınır İhlali</div>
        <p>Pasaportsuz veya pasaport yerine geçen bir belgeden mahrum olarak sınır kapıları dışından Türkiye''ye giren veya Türkiye''den çıkan kimseler hakkında adli para veya hapis cezası uygulanır.</p>
    </div>

</div>


'),
            (12, 14, N'HTML', N'Bulgaria - National Passport - 011 - Second portrait on page 3 Türkçe Eğitim İçeriği', N'e18a6494cf394a888f2d60b83c98e5ae.html', '2026-09-26 15:23:42.203', N'Kaydedilmiş web sayfasından güvenli biçimde oluşturulmuştur.');
        SET IDENTITY_INSERT [dbo].[CourseContents] OFF;
        PRINT 'Tablo [dbo].[CourseContents] icin 7 kayit eklendi.';
    END
END
GO

-- --------------------------------------------------------------------------
-- Veri: [dbo].[Exam]
-- --------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[Exam]', N'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Exam])
    BEGIN
        SET IDENTITY_INSERT [dbo].[Exam] ON;
        INSERT INTO [dbo].[Exam] ([ExamId], [CourseId], [Title], [Description], [DurationMinutes], [PassingScore], [IsActive], [CreatedAt], [IsArchived]) VALUES
            (5, 7, N'Danimarka Umuma Mahsusu Pasaporta Ait Sınav Soruları', N'Yüklenen eğitim içeriğine ilişkin değerlendirme sınavı', 15, 70, 1, '2026-09-26 15:18:41.670', 0),
            (6, 8, N'Konu Pekiştirme Soruları', NULL, 3, 30, 1, '2026-09-26 15:19:04.447', 0),
            (7, 9, N'2024/5 Genelgesi Sınavı', N'20 Adet Sınav Sorusu', 20, 80, 1, '2026-09-26 15:19:33.263', 0),
            (8, 10, N'Yabancılar ve Uluslararası Koruma Kanunu (6458 S.K.) Sınavı', NULL, 10, 80, 1, '2026-09-26 15:19:58.340', 0),
            (9, 11, N'KURS TESTİ ', N'KURS TESTİ (10 Soruluk Zor Seviye)', 10, 70, 1, '2026-09-26 15:20:21.027', 0),
            (11, 13, N'PASAPORT KANUNU SINAVI', NULL, 20, 60, 1, '2026-09-26 15:20:54.463', 0),
            (12, 14, N'WEB-BULGARIA---NATIONAL-PASSPORT---011---SECOND-PORTRAIT-ON-PAGE-3 Değerlendirme Sınavı', N'Yüklenen eğitim içeriğine ilişkin değerlendirme sınavı', 15, 70, 1, '2026-09-26 15:23:42.233', 0);
        SET IDENTITY_INSERT [dbo].[Exam] OFF;
        PRINT 'Tablo [dbo].[Exam] icin 7 kayit eklendi.';
    END
END
GO

-- --------------------------------------------------------------------------
-- Veri: [dbo].[Question]
-- --------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[Question]', N'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Question])
    BEGIN
        SET IDENTITY_INSERT [dbo].[Question] ON;
        INSERT INTO [dbo].[Question] ([QuestionId], [ExamId], [Text], [QuestionType], [Points], [SortOrder], [IsActive]) VALUES
            (81, 5, N'PRADO sayfasındaki ilk görsel olan pasaportun dış kapağı ("Cover") incelendiğinde, Danimarka pasaportunun kapak rengi ve üzerinde yer alan ana sembol hangisidir?', N'1', 10, 1, 1),
            (82, 5, N'Ön kapak içinin morötesi ışık altındaki halini gösteren görselde ("Inside front cover: UV feature"), normalde görünmeyen hangi parlayan özellik göze çarpar?', N'1', 10, 2, 1),
            (83, 5, N'Arka kapak içinin UV ışıklı görselinde ("Inside back cover: UV feature") yer alan ve belgenin sahtelenmesini zorlaştıran temel güvenlik tasarımı nedir?', N'1', 10, 3, 1),
            (84, 5, N'Pasaport sahibinin fotoğrafının ve kişisel bilgilerinin bulunduğu polikarbonat kimlik kartının ön yüz görselinde ("Integrated biodata card - recto") kimlik bilgilerinin hemen yanında yer alan ana güvenlik görseli nedir?', N'1', 10, 4, 1),
            (85, 5, N'Kimlik kartının ön yüzündeki OVD detay görselinde ("OVD - optically variable device") kullanılan ve ışık açısına göre renk/şekil değiştiren tescilli holografik teknoloji aşağıdakilerden hangisidir?', N'1', 10, 5, 1),
            (86, 5, N'Polikarbonat kimlik kartının arka yüzünü gösteren görselde ("Integrated card - verso") hangi teknik bilgi ve alanlar yer almaktadır?', N'1', 10, 6, 1),
            (87, 5, N'Pasaportun vize basılan iç sayfalarını gösteren görsellerde ("Inner page(s)"), sayfaların zemininde kullanılan ve Danimarka tarihini/kültürünü yansıtan ana tema görseli nedir?', N'1', 10, 7, 1),
            (88, 5, N'Pasaportun iç sayfalarının ışığa tutulduğunda görünen filigran görselinde ("Substrate: Watermark") kağıdın içine işlenmiş olan motif hangisidir?', N'1', 10, 8, 1),
            (89, 5, N'PRADO sayfasındaki teknik verilere göre, 18 yaş ve üzerindeki Danimarka vatandaşlarına verilen bu pasaportun (DNK-AO-06001) maksimum geçerlilik süresi ne kadardır?', N'1', 10, 9, 1),
            (90, 5, N'Veri sayfasındaki bilgilere göre, bu seyahat belgesinin süresi bittiğinde istisnai olarak ne kadar süreyle ve nasıl uzatılması mümkündür?', N'1', 10, 10, 1),
            (91, 5, N'Pasaport sayfalarını bir arada tutan ve PRADO''da "Stitching thread" başlığı altında gösterilen dikiş ipliği ile ilgili hangi güvenlik önlemi alınmıştır?', N'1', 10, 11, 1),
            (92, 5, N'Pasaportun iç sayfalarında yer alan belge numarası, sayfaların alt veya yan kısımlarına hangi ileri teknoloji yöntemle delinerek (perfore edilerek) işlenmiştir?', N'1', 10, 12, 1),
            (93, 5, N'Pasaportun vize sayfalarında kullanılan orijinal güvenlik kağıdının sahtelerinden ayırt edilmesini sağlayan en temel optik özelliği nedir?', N'1', 10, 13, 1),
            (94, 5, N'Pasaport sayfalarında ışığa tutulduğunda ön ve arka yüzdeki parçaların birbirini kusursuz şekilde tamamlayarak tek bir bütün oluşturduğu "See-through Register" (Çakışan Resim) ögesinde genellikle hangi motif kullanılır?', N'1', 10, 14, 1),
            (95, 5, N'Teknik Detay: Sedefli Mürekkep (Iridescent Ink)
Pasaportun iç sayfalarında veya kapak içlerinde, bakış açısına göre hafif altın sarısından şeffaf parıltılara dönüşen ve fotokopiyle çoğaltılamayan mürekkep türü aşağıdakilerden hangisidir?', N'1', 10, 15, 1),
            (96, 5, N'Teknik Detay: MRZ Standartları
Polikarbonat biodata sayfasının alt kısmında yer alan iki satırlık Makinede Okunabilir Alan (MRZ) şeridinde, ICAO standartlarına göre her bir satırda kaç karakter bulunmalıdır?', N'1', 10, 16, 1),
            (97, 5, N'Görsel Detay: "Integrated biodata card - Tactile Elements"
Kimlik sayfasının (biodata card) yüzeyindeki dokunsal (hissedilebilir) güvenlik ögeleri el ile kontrol edildiğinde ne hissettirir?', N'1', 10, 17, 1),
            (98, 5, N'Teknik Detay: Sayfa Sayısı (Number of Pages)
Danimarka standart pasaport modelinde (DNK-AO-06001), kapaklar hariç toplam kaç adet vize ve bilgi sayfası yer almaktadır?', N'1', 10, 18, 1),
            (99, 5, N'Teknik Detay: Giyoj Desen Kalitesi (Guilloche Quality)
Sahte belgelerde genellikle çizgisel kesintiler veya mürekkep dağılması şeklinde görülen, ancak orijinal Danimarka pasaportunda son derece keskin ve kesintisiz olan çok renkli ince çizgi desenleri hangi baskı teknolojisiyle basılır?', N'1', 10, 19, 1),
            (100, 5, N'Teknik Detay: Fotoğraf Güvenliği (Photo Protection)
Polikarbonat kimlik kartında pasaport sahibinin fotoğrafı üzerinde yer alan ve fotoğrafın kesilerek değiştirilmesini engelleyen üst üste binmiş (overlapping) güvenlik yapısı hangisidir?', N'1', 10, 20, 1),
            (101, 6, N'Soru 1: Resmi belgelere göre anne veya babası tespit edilemeyen 18 yaşından küçük bir yabancının refakatçisine ceza kaydı girilirken hangi yöntem izlenmelidir?', N'1', 10, 1, 1),
            (102, 6, N'Soru 2: 18 yaşından küçük bir yabancı; yanında noter onaylı "birlikte seyahat edebilir" muvafakatnamesi bulunan öz teyzesi ile sınır kapısından çıkış yapmaktadır. Ceza ihlali durumunda veri girişi kimin adına yapılmalıdır?', N'1', 10, 2, 1),
            (103, 6, N'Soru 3: Anne ve babası haricinde, velayeti elinde bulunduran üçüncü bir kişi hakkında çocuk adına ceza veri girişi yapılabilmesinin temel şartı nedir?', N'1', 10, 3, 1),
            (104, 7, N'Vize ihlalinde bulunup idari gözetim veya sınır dışı etme kararı alınmadan, kendiliğinden sınır kapısına gelerek ihlalden kaynaklı para cezasını ödeyen bir yabancı 10 ay boyunca vize muafiyetini ihlal etmiştir. 2024/5 sayılı Genelge uyarınca bu yabancı hakkında hangi tahdit kodu ve kaç yıl süreyle giriş yasağı uygulanır?', N'1', 5, 1, 1),
            (105, 7, N'İkamet izni ihlal süresi 2 ay olan ve hakkında henüz sınır dışı etme kararı alınmamış bir yabancı, ülkeden çıkış yapmak üzere kendiliğinden sınır kapısına gelmiş ve ihlalden kaynaklanan para cezasını ödemiştir. Bu yabancı hakkında yapılacak işlem aşağıdakilerden hangisidir?', N'1', 5, 2, 1),
            (106, 7, N'Ülkeye ikamet izni şartlı giriş yaparak giren ancak 10 gün içinde ikamet iznine müracaat etmeyen ve şartlı giriş yükümlülüğünü ihlal ederek çıkış yapmak üzere kendiliğinden sınır kapısına gelen, ihlal süresi 8 gün olan ve idari para cezasını ödeyen yabancıya hangi kısıtlama uygulanır?  ', N'1', 5, 3, 1),
            (107, 7, N'Hakkında Ç-114 (Hakkında Adli İşlem Yapılan Yabancılar) tahdit kodu bulunan bir yabancının yasal giriş yasağı süresi kaç yıldır ve kod hangi makam tarafından girilir?  ', N'1', 5, 4, 1),
            (108, 7, N'Cezaevinden tahliye edilen bir yabancı hakkında Ç-115 kodu ile 5 yıl giriş yasağı konulmuştur. Yabancının devam eden yargılamasında beraat etmesi halinde tahdit kaydı ile ilgili nasıl bir işlem tesis edilir?  ', N'1', 5, 5, 1),
            (109, 7, N'Sahte belge ile Türkiye''ye giriş yapmaya çalışan veya transit geçiş yapmak isterken sınır kapısı personeli tarafından tespit edilen bir yabancı hakkında hangi kod girilir ve kaç yıl süreyle giriş yasağı uygulanır?  ', N'1', 5, 6, 1),
            (110, 7, N'Aşağıdaki "Ç" kodlarından hangisine sahip olan bir yabancı, dış temsilciliklerden "özel meşruhatlı vize" alarak sınır kapısına geldiğinde, idari para cezasını ödemiş olsa dahi tahdit kodu sınır kapısı personeli tarafından RESEN KALDIRILAMAZ?  ', N'1', 5, 7, 1),
            (111, 7, N'Mavi Kart sahibi olan (doğumla Türk vatandaşı olup çıkma izniyle ayrılan) bir yabancı hakkında Genelge gereğince kural olarak "Ç" kodlu veri girişi yapılmaz. Ancak milli güvenlik ve kamu düzeni aleyhine faaliyetleri nedeniyle Mavi Kartlılara da girilebilen istisnai kod grubu hangisidir?  ', N'1', 5, 8, 1),
            (112, 7, N'Sağlık Bakanlığı tarafından belirlenen bulaşıcı hastalık taşıdığı doktor raporuyla sabit olan yabancılar için Ç-118 kodu girilir. Bu tahdit kaydı hangi durumda kaldırılabilir?  ', N'1', 5, 9, 1),
            (113, 7, N'Mücbir sebep (örn. ağır sağlık sorunu) nedeniyle ikamet veya vize ihlalinde bulunan yabancılardan bu durumunu kamu hastanelerinden alınan uzman hekim ve başhekim onaylı raporla belgeleyenler için Genelgeye göre nasıl bir işlem yapılır?  ', N'1', 5, 10, 1),
            (114, 7, N'"G" kodlu giriş yasakları ile ilgili veri girişi ve kaldırma işlemleri mevzuata göre yalnızca hangi makam tarafından yapılır?  ', N'1', 5, 11, 1),
            (115, 7, N'Hakkında "G" kodu bulunan bir yabancının sınır kapısına gelmesi halinde uygulanacak idari usul nedir?  ', N'1', 5, 12, 1),
            (116, 7, N'Türkiye’de adres kayıt sistemine kayıtlı olmayan veya kalacağını beyan ettiği adreste ikamet etmediği tespit edilen yabancılara uygulanan idari para cezası ve ön izin kodu aşağıdakilerden hangisidir?  ', N'1', 5, 13, 1),
            (117, 7, N'6735 sayılı Uluslararası İşgücü Kanunu''na göre izinsiz çalıştığı tespit edilen yabancılara idari para cezasını ödemediği gerekçesiyle uygulanan kod aşağıdakilerden hangisidir?  ', N'1', 5, 14, 1),
            (118, 7, N'Geri Gönderme Merkezlerinde (GGM) barındırılan yabancılardan Başkanlığın belirlediği idari para cezasını içeren disiplin kurallarına uymayanlara hangi kod tanımlanır?  ', N'1', 5, 15, 1),
            (119, 7, N'Uluslararası koruma başvurusunu geri çeken veya geri çekilmiş sayılan yabancılar hakkında uygulanan "O-176" tahdit kodunun yasal kısıtlama süresi kaç yıldır?  ', N'1', 5, 16, 1),
            (120, 7, N'Uluslararası koruma başvurusu hakkında kabul edilemez başvuru, reddedilme veya statüsü iptal edilme kararı verilen yabancılara hangi kod girilir ve süresi ne kadardır?  ', N'1', 5, 17, 1),
            (121, 7, N'5395 sayılı Çocuk Koruma Kanunu uyarınca 18 yaşını doldurmamış yabancılarla ilgili idari para cezası ve tahdit kodu uygulamasında fiil işlendiği sırada kaç yaşını doldurmamış olanlara idari para cezası UYGULANMAZ?  ', N'1', 5, 18, 1),
            (122, 7, N'Sınır dışı etme kararı yargı merciince (mahkeme kararıyla) iptal edilen bir yabancı hakkında tesis edilmiş olan idari işlemler ve tahdit kodları ile ilgili nasıl bir hukuki süreç işletilir?  ', N'1', 5, 19, 1),
            (123, 7, N'Hakkında "N" (Ön İzin) kodlu idari para cezası kaydı bulunan bir yabancı sınır kapısına geldiğinde, ceza miktarını ödemek istemez veya ödemekten imtina ederse sınır kapısı personeli nasıl bir işlem tesis eder?  ', N'1', 5, 20, 1),
            (124, 8, N'1. 6458 sayılı Kanun’a göre, bir yabancının havalimanı veya deniz limanı sınır kapısındaki "kapsamlı kontrol" işlemleri sırasında bekletilme süresi en fazla kaç saattir?', N'1', 5, 1, 1),
            (125, 8, N'2. Aşağıdakilerden hangisi 6458 sayılı Kanun’un 12. maddesi kapsamında Türkiye’ye girişte vize şartından muaf tutulan kişilerden biri değildir?', N'1', 5, 2, 1),
            (126, 8, N'3. Aşağıdaki durumların hangisinde verilmiş olan vize, iptal kararına konu olmaz?', N'1', 5, 3, 1),
            (127, 8, N'4. 6458 sayılı Kanun’a göre, konsolosluklara yapılan ikamet izni başvuruları kural olarak en geç kaç gün içinde sonuçlandırılır?', N'1', 5, 4, 1),
            (128, 8, N'5. Türkiye’de kesintisiz ikamet süresi hesaplanırken öğrenci ikamet izinlerinin ne kadarlık kısmı dikkate alınır?', N'1', 5, 5, 1),
            (129, 8, N'6. Aşağıdakilerden hangisi "Kısa Dönem İkamet İzni" verilebilecek yabancılar arasında sayılmamıştır?', N'1', 5, 6, 1),
            (130, 8, N'7. Kısa dönem ikamet iznine sahip bir yabancının ikamet izni, son bir yıl içinde toplamda kaç günden fazla yurt dışında kalması hâlinde iptal edilir veya uzatılmaz?', N'1', 5, 7, 1),
            (131, 8, N'8. Ön lisans ve lisans düzeyinde öğrenim gören yabancı öğrencilerin çalışma hakkı ile ilgili kanuni düzenleme aşağıdakilerden hangisidir?', N'1', 5, 8, 1),
            (132, 8, N'9. Uzun dönem ikamet iznine sahip yabancılar, Türk vatandaşlarına tanınan haklardan yararlanırlar. Ancak bazı haklar kısıtlanmıştır. Aşağıdakilerden hangisi uzun dönem ikamet izni sahiplerinin yararlanabileceği haklardandır?', N'1', 5, 9, 1),
            (133, 8, N'10. İnsan ticareti mağduru olduğu veya olabileceği yönünde kuvvetli şüphe duyulan yabancılara verilen ikamet izni ilk aşamada kaç gün sürelidir ve en fazla toplam kaç yıla kadar uzatılabilir?', N'1', 5, 10, 1),
            (134, 8, N'11. Sınır dışı etme kararına karşı idare mahkemesine başvuru süresi kaç gündür ve açılan dava kaç gün içinde sonuçlandırılır?', N'1', 5, 11, 1),
            (135, 8, N'12. Aşağıdaki yabancılardan hangisi hakkında 54. madde kapsamında kural olarak sınır dışı etme şartları oluşsa dahi sınır dışı etme kararı alınmaz?', N'1', 5, 12, 1),
            (136, 8, N'13. Geri gönderme merkezlerinde uygulanan idari gözetim süresi kural olarak en fazla ne kadardır ve en fazla ne kadar uzatılabilir?', N'1', 5, 13, 1),
            (137, 8, N'14. Avrupa ülkeleri dışında meydana gelen olaylar sebebiyle ırkı, dini, tabiiyeti, belli bir toplumsal gruba mensubiyeti veya siyasi düşüncelerinden dolayı zulme uğrayacağından haklı sebeplerle korktuğu için Türkiye''den koruma talep eden kişiye hangi statü verilir?', N'1', 5, 14, 1),
            (138, 8, N'15. Uluslararası koruma başvuru sahibinin idari gözetim süresi en fazla kaç günü geçemez?', N'1', 5, 15, 1),
            (139, 8, N'16. Uluslararası koruma başvurusuyla ilgili "Hızlandırılmış Değerlendirme" kapsamına alınan bir başvuru sahibiyle kaç gün içinde mülakat yapılır ve başvuru mülakattan sonra kaç gün içinde sonuçlandırılır?', N'1', 5, 16, 1),
            (140, 8, N'17. Aşağıdakilerden hangisinin uluslararası koruma başvurusu "Hızlandırılmış Değerlendirme"ye tabi tutulamaz?', N'1', 5, 17, 1),
            (141, 8, N'18. Uluslararası Koruma Değerlendirme Komisyonuna idari itiraz süresi kararın tebliğinden itibaren kaç gündür?', N'1', 5, 18, 1),
            (142, 8, N'19. Göç Politikaları Kurulu’nun başkanı aşağıdakilerden hangisidir?', N'1', 5, 19, 1),
            (143, 8, N'20. Aşağıdakilerden hangisi Göç İdaresi Genel Müdürlüğü bünyesinde yer alan "Sürekli Kurul ve Komisyonlar"dan biri değildir?', N'1', 5, 20, 1),
            (144, 9, N'Geri gönderme merkezi (GGM) bulunmayan bir ilde kolluk birimlerince yakalanan bir düzensiz göçmen hakkında yürütülecek idari karar süreci ile ilgili aşağıdakilerden hangisi doğrudur?', N'1', 10, 1, 1),
            (145, 9, N'6458 sayılı Kanun''un 55''inci maddesi (sınır dışı etme kararı alınmayacak yabancılar) ve idari gözetim uygulamaları ile ilgili aşağıdakilerden hangisi mevzuata kesinlikle aykırıdır?', N'1', 10, 2, 1),
            (146, 9, N'Yabancıya kendi anladığı dilde tebligat yapılması sürecinde, ortamda tercüman bulunmaması veya yabancının imzadan imtina etmesi halleriyle ilgili aşağıdakilerden hangisi yanlıştır?', N'1', 10, 3, 1),
            (147, 9, N'Sınır hattında veya denizde gerçekleştirilen yakalamalarda askeri ve kolluk birimlerinin evrak tanzim ve teslim sorumluluklarına ilişkin aşağıdakilerden hangisi doğrudur?', N'1', 10, 4, 1),
            (148, 9, N'İdari gözetim kararlarının hukuki niteliği, süresi ve kararların onay/tebliğ süreçleri ile ilgili aşağıdakilerden hangisi yanlıştır?', N'1', 10, 5, 1),
            (149, 9, N'Yurt dışına mevcutlu (kolluk refakatinde) sınır dışı etme işlemleri ve görevli personelin özlük/harcırah hakları ile ilgili aşağıdaki ifadelerden hangisi doğrudur?', N'1', 10, 6, 1),
            (150, 9, N'Sınır dışı edilecek yabancıların seyahat masrafları, seyahat belgeleri ve tahdit (giriş yasağı) veri girişleri ile ilgili ilişki bakımından hangisi doğrudur?', N'1', 10, 7, 1),
            (151, 9, N'Herhangi bir suça karışması nedeniyle adli mercilere sevk edilen ve ardından serbest bırakılan yabancılar hakkında izlenecek usul bakımından aşağıdakilerden hangisi yanlıştır?', N'1', 10, 8, 1),
            (152, 9, N'27.02.2019 tarihli ve E.12231 sayılı Bakanlık Makamı Oluru uyarınca kolluk birimlerinin kullanımına tahsis edilen geçici tutma/barındırma alanları (konteyner vb.) ile ilgili giderlerin paylaşımı hakkında hangisi yanlıştır?', N'1', 10, 9, 1),
            (153, 9, N'Geri gönderme merkezleri dışındaki sevk, nakil, güvenlik ve yetki uyuşmazlıklarında karar alma mercileri ile ilgili aşağıdakilerden hangisi doğrudur?', N'1', 10, 10, 1),
            (164, 11, N'5682 Sayılı Pasaport Kanunu’na göre, Belediye Başkanlarının Hususi Damgalı (Yeşil) Pasaport hakkı ile ilgili aşağıdakilerden hangisi doğrudur?', N'1', 5, 1, 1),
            (165, 11, N'Hususi Damgalı Pasaport hak sahibinin ergin (18 yaşını doldurmuş) çocuklarının bu pasaporttan yararlanabilmesi için mevzuatta aranan şartlarla ilgili aşağıdakilerden hangisi yanlıştır?', N'1', 5, 2, 1),
            (166, 11, N'Pasaport Kanunu''na göre, Diplomatik Pasaport (Siyah) verme ve tanzim etme yetkisi münhasıran hangi makama aittir?', N'1', 5, 3, 1),
            (167, 11, N'Hususi veya Hizmet Damgalı pasaport alma hakkı bulunan kişilerin sürekli bakıma muhtaç derecede engelli çocukları için yaş sınırı kuralı nasıl uygulanır?', N'1', 5, 4, 1),
            (168, 11, N'Devlet memurlarının Hususi Damgalı (Yeşil) Pasaport alabilmeleri için 1., 2. veya 3. derece kadrolarda bulunmaları şarttır. Kadro derecesi yetmeyen ancak bu derecelere karşılık gösterilmek suretiyle sözleşmeli olarak çalışan personelin durumu hakkında hangisi doğrudur?', N'1', 5, 5, 1),
            (169, 11, N'Türkiye Cumhuriyeti''nin üyesi bulunduğu uluslararası kuruluşlarda memur statüsünde çalışan ve diplomatik pasaport hakkı bulunmayan T.C. vatandaşlarına hangi tür pasaport verilir?', N'1', 5, 6, 1),
            (170, 11, N'Pasaport Kanunu uyarınca, "Sınır kapıları dışından Türkiye''ye giren veya Türkiye''den çıkan kişilere" uygulanacak hukuki yaptırım aşağıdakilerden hangisidir?', N'1', 5, 7, 1),
            (171, 11, N'Aşağıdaki makam sahiplerinden hangisi Diplomatik Pasaport (Siyah) alma hakkına sahip değildir?', N'1', 5, 8, 1),
            (172, 11, N'Hizmet Damgalı (Gri) Pasaport kullanım esasları ile ilgili aşağıda verilen bilgilerden hangisi doğrudur?', N'1', 5, 9, 1),
            (173, 11, N'Pasaport Kanunu''na göre, Türkiye''den kaçmış olan veya yurt dışında bulunup da adli makamlarca iadesi istenen kişilerin pasaportları hakkında yapılan işlem nedir?', N'1', 5, 10, 1),
            (174, 12, N'Soru: Aşağıdaki görselde görülen Bulgar pasaportunun kapağının rengi ve malzemesi nedir?', N'1', 10, 1, 1),
            (175, 12, N'Soru: Aşağıdaki görselde görülen filigran (Watermark) özelliği pasaportun hangi kısmında bulunuyor ve ne tür bir güvenlik sağlar?', N'1', 10, 2, 1),
            (176, 12, N'Soru: Pasaportun kişisel bilgilerin bulunduğu sayfada (Personalisation) ikinci portrenin yer aldığı modelde hangi güvenlik unsuru ön planda?', N'1', 10, 3, 1),
            (177, 12, N'Soru: Pasaportun kimlik sayfasındaki laminate tabakada hangi gelişmiş güvenlik özelliği yer alır?', N'1', 10, 4, 1),
            (178, 12, N'Soru: Pasaporttaki taşıyıcı fotoğrafı (Image of Bearer) alanında kullanılan güvenlik teknolojisi nedir?', N'1', 10, 5, 1),
            (179, 12, N'UV ışık altında kimlik sayfasının (front) gösterdiği floresan desen hangisidir?', N'1', 10, 6, 1),
            (180, 12, N'Pasaportun ciltleme (Binding) kısmında kullanılan güvenlik unsuru nedir?', N'1', 10, 7, 1),
            (181, 12, N'Ön ve arka endpaper sayfalarında ortak olarak bulunan güvenlik özelliği aşağıdakilerden hangisidir?', N'1', 10, 8, 1),
            (182, 12, N'Pasaportta “Security feature (1)” olarak belirtilen özel unsur genellikle nedir?', N'1', 10, 9, 1),
            (183, 12, N'Bulgar Umuma Mahsus Pasaport’un (Model 011) en önemli çok katmanlı güvenlik yaklaşımı nedir?', N'1', 10, 10, 1);
        SET IDENTITY_INSERT [dbo].[Question] OFF;
        PRINT 'Tablo [dbo].[Question] icin 93 kayit eklendi.';
    END
END
GO

-- --------------------------------------------------------------------------
-- Veri: [dbo].[QuestionOption]
-- --------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[QuestionOption]', N'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dbo].[QuestionOption])
    BEGIN
        SET IDENTITY_INSERT [dbo].[QuestionOption] ON;
        INSERT INTO [dbo].[QuestionOption] ([OptionId], [QuestionId], [Text], [IsCorrect], [SortOrder]) VALUES
            (325, 81, N'A) Mavi renk üzerine Danimarka haritası', 0, 1),
            (326, 81, N'B) Kırmızı/Bordo renk üzerine Danimarka Kraliyet Arması (üç aslan ve kalpler)', 1, 2),
            (327, 81, N'C) Yeşil renk üzerine Viking miğferi görseli', 0, 3),
            (328, 81, N'D) Siyah renk üzerine altın sarısı taç sembolü', 0, 4),
            (329, 82, N'A) Sadece büyük bir Danimarka bayrağı', 0, 1),
            (330, 82, N'B) Renkli floresan lifler ve UV ışığı altında parlayan özel güvenlik desenleri', 1, 2),
            (331, 82, N'C) Sadece pasaport sahibinin kimlik numarası', 0, 3),
            (332, 82, N'D) Yeşil renkte parlayan bir dünya haritası', 0, 4),
            (333, 83, N'A) Sayfa numarasını gösteren büyük bir filigran', 0, 1),
            (334, 83, N'B) Manyetik şerit ve barkod sistemi', 0, 2),
            (335, 83, N'C) Arka kapak yapısına entegre edilmiş, UV ışığında reaksiyon veren özel güvenlik desenleri', 1, 3),
            (336, 83, N'D) Sadece pasaportu üreten firmanın logosu', 0, 4),
            (337, 84, N'A) Lazerle işlenmiş siyah-beyaz fotoğraf (Facial image) ve arka plan güvenlik çizgileri', 1, 1),
            (338, 84, N'B) Doğrudan plastik yüzeye yapıştırılmış renkli bir kağıt fotoğrafı', 0, 2),
            (339, 84, N'C) Danimarka haritası ve Kopenhag Nyhavn evleri çizimi', 0, 3),
            (340, 84, N'D) Büyük bir holografik Viking gemisi motifi', 0, 4),
            (341, 85, N'A) Kinegram®', 1, 1),
            (342, 85, N'B) Alphagram®', 0, 2),
            (343, 85, N'C) Identigram®', 0, 3),
            (344, 85, N'D) Hologram-Plus', 0, 4),
            (345, 86, N'A) Sadece vizelerin basılacağı boş bir alan', 0, 1),
            (346, 86, N'B) Danimarka''nın tarihi simgeleri ve UV ışık altında parlayan güvenlik desenleri', 0, 2),
            (347, 86, N'C) Acil durumda aranacak kişiler listesi', 0, 3),
            (348, 86, N'D) Belgenin seri numarası, MRZ (makinede okunabilir alan) uzantısı ve güvenlik desenleri', 1, 4),
            (349, 87, N'A) Danimarka''nın ünlü Jelling Rün Taşları (Jelling Stones) çizimleri', 1, 1),
            (350, 87, N'B) Sadece modern Danimarka mimarisi çizimleri', 0, 2),
            (351, 87, N'C) Hans Christian Andersen masal karakterleri', 0, 3),
            (352, 87, N'D) Danimarka süper lig stadyumlarının krokileri', 0, 4),
            (353, 88, N'A) Sadece "DANMARK" yazılı düz bir filigran çizgisi', 0, 1),
            (354, 88, N'B) Danimarka devlet amblemi veya rünik motifler içeren özel bir filigran deseni', 1, 2),
            (355, 88, N'C) Kraliyet tacı ve pasaport sahibinin gölge resmi', 0, 3),
            (356, 88, N'D) Deniz kızı heykeli görseli', 0, 4),
            (357, 89, N'A) 5 Yıl', 0, 1),
            (358, 89, N'B) 10 Yıl', 1, 2),
            (359, 89, N'C) 3 Yıl', 0, 3),
            (360, 89, N'D) Ömür boyu (Süresiz)', 0, 4),
            (361, 90, N'A) Bir kez, en fazla 12 aya kadar (Endorsement/Onay damgası ile)', 1, 1),
            (362, 90, N'B) Sınırsız sayıda, her seferinde 5 yıl boyunca', 0, 2),
            (363, 90, N'C) Bu belgede hiçbir şekilde süre uzatımı yapılamaz, doğrudan yeni pasaport alınmalıdır', 0, 3),
            (364, 90, N'D) Sadece online başvuru ile 2 yıl daha uzatılabilir', 0, 4),
            (365, 91, N'A) Sadece sıradan beyaz pamuk iplik kullanılmıştır.', 0, 1),
            (366, 91, N'B) İplikler metal tellerle güçlendirilmiştir.', 0, 2),
            (367, 91, N'C) UV ışığı altında farklı renklerde (örneğin floresan sarı/yeşil/kırmızı) parlayan özel güvenlik iplikleri kullanılmıştır.', 1, 3),
            (368, 91, N'D) İplik yerine tamamen ısısal yapıştırma (termal kaynak) yöntemi tercih edilmiştir.', 0, 4),
            (369, 92, N'A) Mekanik iğneleme yöntemiyle', 0, 1),
            (370, 92, N'B) Lazer perforasyon (lazer ışınları ile yakılarak konik delikler açılması) yöntemiyle', 1, 2),
            (371, 92, N'C) Sıcak baskı (hot stamping) yöntemiyle', 0, 3),
            (372, 92, N'D) Kimyasal aşındırma yöntemiyle', 0, 4),
            (373, 93, N'A) UV ışığı altında tamamen parlaması (yüksek optik beyazlatıcı içermesi)', 0, 1),
            (374, 93, N'B) UV ışığı altında mat kalması (UV-dead / floresan içermeyen kağıt) ve üzerindeki güvenlik liflerinin parlaması', 1, 2),
            (375, 93, N'C) Kağıdın tamamen şeffaf plastik benzeri bir yapıda olması', 0, 3),
            (376, 93, N'D) Üzerine dökülen her türlü sıvıyı doğrudan emip rengini değiştirmesi', 0, 4),
            (377, 94, N'A) Danimarka Kraliyet Tacı veya devlet armasına ait bir sembol', 1, 1),
            (378, 94, N'B) Pasaport sahibinin profil fotoğrafı', 0, 2),
            (379, 94, N'C) Basit bir geometrik kare desen', 0, 3),
            (380, 94, N'D) Viking gemisi dümeni', 0, 4),
            (381, 95, N'A) Manyetik mürekkep', 0, 1),
            (382, 95, N'B) Sedefli / Yanardöner mürekkep (Iridescent ink)', 1, 2),
            (383, 95, N'C) Silinebilir mürekkep', 0, 3),
            (384, 95, N'D) Termokromik (ısıya duyarlı) mürekkep', 0, 4),
            (385, 96, N'A) 30 karakter', 0, 1),
            (386, 96, N'B) 36 karakter', 0, 2),
            (387, 96, N'C) 44 karakter', 1, 3),
            (388, 96, N'D) 50 karakter', 0, 4),
            (389, 97, N'A) Tamamen pürüzsüz ve kaygan bir cam yüzey', 0, 1),
            (390, 97, N'B) Lazer gravür nedeniyle yüzeyde hafif kabartılı ve pürüzlü teknik yazılar/şekiller', 1, 2),
            (391, 97, N'C) Yumuşak ve süngerimsi bir doku', 0, 3),
            (392, 97, N'D) Pütürlü zımpara kağıdı hissi', 0, 4),
            (393, 98, N'A) 24 sayfa', 0, 1),
            (394, 98, N'B) 32 sayfa', 1, 2),
            (395, 98, N'C) 48 sayfa', 0, 3),
            (396, 98, N'D) 64 sayfa', 0, 4),
            (397, 99, N'A) Ev tipi mürekkep püskürtmeli (Inkjet) baskı', 0, 1),
            (398, 99, N'B) Yüksek hassasiyetli Ofset Baskı (Offset Printing)', 1, 2),
            (399, 99, N'C) Basit lazer yazıcı baskısı', 0, 3),
            (400, 99, N'D) Şablon (Serigrafi) baskı', 0, 4),
            (401, 100, N'A) Fotoğrafın üzerine yapıştırılmış kalın bir plastik etiket', 0, 1),
            (402, 100, N'B) Fotoğraf alanının üzerinden geçen dalgalı kinegram desenleri ve mikroyazılar', 1, 2),
            (403, 100, N'C) Sadece fotoğrafın köşelerine basılan ıslak imzalı damgalar', 0, 3),
            (404, 100, N'D) Fotoğrafın etrafını saran metalik koruma çerçevesi', 0, 4),
            (405, 101, N'A) İşlem iptal edilir ve çocuk cezasız gönderilir.', 0, 1),
            (406, 101, N'B) Anne veya babanın beyanı esas alınarak bunlardan biri hakkında işlem tesis edilir.', 1, 2),
            (407, 101, N'C) En yakın akrabasının beyanı olmadan işlem doğrudan çocuğun adına yapılır.', 0, 3),
            (408, 101, N'D) Konsolosluktan resmi onay gelene kadar çocuk sınırda bekletilir.', 0, 4),
            (409, 102, N'A) Muvafakatnamesi olduğu için teyzesi adına', 0, 1),
            (410, 102, N'B) Türkiye''deki davet eden sponsor adına', 0, 2),
            (411, 102, N'C) Doğrudan 18 yaşından küçük yabancının kendisi adına', 1, 3),
            (412, 102, N'D) Teyzesi ve çocuğun adına yarı yarıya bölünerek', 0, 4),
            (413, 103, N'A) Çocuğun bu kişiyi sevdiğini beyan etmesi', 0, 1),
            (414, 103, N'B) Velayet durumunun resmi olarak belgelenmesi', 1, 2),
            (415, 103, N'C) Kişinin çocukla aynı soyadını taşıyor olması', 0, 3),
            (416, 103, N'D) Kişinin Türkiye''de ikamet izni sahibi olması', 0, 4),
            (417, 104, N'A) Ç-101 / 3 Ay  ', 0, 1),
            (418, 104, N'B) Ç-102 / 6 Ay  ', 1, 2),
            (419, 104, N'C) Ç-103 / 1 Yıl  ', 0, 3),
            (420, 104, N'D) Ç-102 / 3 Ay  ', 0, 4),
            (421, 105, N'A) Ç-101 kodu girilerek 3 ay giriş yasağı koyulur.  ', 0, 1),
            (422, 105, N'B) Ç-102 kodu girilerek 6 ay giriş yasağı koyulur.  ', 0, 2),
            (423, 105, N'C) Hakkında "Ç" kodlu giriş yasağı uygulanmaz.  ', 1, 3),
            (424, 105, N'D) N-96 idari para cezası kodu girilerek 1 yıl giriş yasağı uygulanır.  ', 0, 4),
            (425, 106, N'A) Ç-101 kodlu 3 ay süreyle giriş yasağı', 0, 1),
            (426, 106, N'B) Ç-102 kodlu 6 ay süreyle giriş yasağı', 0, 2),
            (427, 106, N'C) Ç-113 kodlu 5 yıl süreyle giriş yasağı', 0, 3),
            (428, 106, N'D) Hakkında "Ç" kodlu giriş yasağı uygulanmaz.  ', 1, 4),
            (429, 107, N'A) 5 Yıl / Başkanlık  ', 0, 1),
            (430, 107, N'B) 3 Yıl / İl Müdürlükleri  ', 1, 2),
            (431, 107, N'C) 2 Yıl / Sınır Kapısı Personeli  ', 0, 3),
            (432, 107, N'D) 1 Yıl / Hukuk Müşavirliği  ', 0, 4),
            (433, 108, N'A) Giriş yasağı süresi olan 5 yılın dolması beklenir.  ', 0, 1),
            (434, 108, N'B) Bu suça istinaden girilen tahdit kaydı kaldırılır.  ', 1, 2),
            (435, 108, N'C) Ç-115 kodu Ç-114 koduna dönüştürülerek 3 yıla indirilir.  ', 0, 3),
            (436, 108, N'D) Yabancıya Ç-152 kodu tanımlanır.  ', 0, 4),
            (437, 109, N'A) Ç-150 / 5 Yıl  ', 1, 1),
            (438, 109, N'B) Ç-113 / 5 Yıl  ', 0, 2),
            (439, 109, N'C) G-87 / Süresiz  ', 0, 3),
            (440, 109, N'D) N-95 / 2 Yıl  ', 0, 4),
            (441, 110, N'A) Ç-101  ', 0, 1),
            (442, 110, N'B) Ç-104  ', 0, 2),
            (443, 110, N'C) Ç-113  ', 0, 3),
            (444, 110, N'D) Ç-141  ', 1, 4),
            (445, 111, N'A) Ç-101, Ç-102, Ç-103  ', 0, 1),
            (446, 111, N'B) Ç-114, Ç-115, Ç-141, Ç-149, Ç-151, Ç-152, Ç-179, Ç-184, Ç-185  ', 1, 2),
            (447, 111, N'C) N-95, N-96, N-97  ', 0, 3),
            (448, 111, N'D) O-100, O-176, O-177  ', 0, 4),
            (449, 112, N'A) Yabancı 5 yıllık süreyi yurt dışında tamamladığında.  ', 0, 1),
            (450, 112, N'B) Tam teşekküllü devlet hastanesinden bulaşıcı hastalık taşımadığına dair rapor getirilmesi veya yurt dışındaki raporda apostil şerhi bulunması halinde.  ', 1, 2),
            (451, 112, N'C) Yabancının özel hastaneden alacağı tek hekim raporu ile.  ', 0, 3),
            (452, 112, N'D) Ç-118 kodu hiçbir şekilde kaldırılamaz.  ', 0, 4),
            (453, 113, N'A) Ç-101 kodu girilir ancak para cezası alınmaz.  ', 0, 1),
            (454, 113, N'B) "Ç" kodlu veri girişi yapılmaz.  ', 1, 2),
            (455, 113, N'C) Doğrudan Ç-114 kodu girilir.  ', 0, 3),
            (456, 113, N'D) Yabancıya 1 ay süreli N-96 ön izin kodu verilir.  ', 0, 4),
            (457, 114, N'A) Sınır Kapısı Mülki İdare Amirliği  ', 0, 1),
            (458, 114, N'B) İl Göç İdaresi Müdürlükleri  ', 0, 2),
            (459, 114, N'C) Yalnızca Göç İdaresi Başkanlığı  ', 1, 3),
            (460, 114, N'D) Emniyet Genel Müdürlüğü  ', 0, 4),
            (461, 115, N'A) Yabancı derhal gözaltına alınır.  ', 0, 1),
            (462, 115, N'B) Yabancının ülkeye girişine izin verilmeyerek kabul edilemeyen yolcu kapsamına alınır ve tebligat yapılır.  ', 1, 2),
            (463, 115, N'C) Sınır kapısı personeli kodu resen silerek içeri alır.  ', 0, 3),
            (464, 115, N'D) Yabancıya N-95 kodu tanımlanarak transit geçiş verilir.  ', 0, 4),
            (465, 116, N'A) N-95  ', 0, 1),
            (466, 116, N'B) N-96  ', 0, 2),
            (467, 116, N'C) N-97  ', 1, 3),
            (468, 116, N'D) N-119  ', 0, 4),
            (469, 117, N'A) Ç-117  ', 0, 1),
            (470, 117, N'B) N-119  ', 1, 2),
            (471, 117, N'C) N-120  ', 0, 3),
            (472, 117, N'D) N-135  ', 0, 4),
            (473, 118, N'A) N-136  ', 0, 1),
            (474, 118, N'B) N-170  ', 0, 2),
            (475, 118, N'C) N-186  ', 1, 3),
            (476, 118, N'D) N-187  ', 0, 4),
            (477, 119, N'A) 1 Yıl  ', 0, 1),
            (478, 119, N'B) 2 Yıl  ', 0, 2),
            (479, 119, N'C) 3 Yıl  ', 1, 3),
            (480, 119, N'D) 5 Yıl  ', 0, 4),
            (481, 120, N'A) O-100 / 1 Yıl  ', 0, 1),
            (482, 120, N'B) O-176 / 3 Yıl  ', 0, 2),
            (483, 120, N'C) O-177 / 5 Yıl  ', 1, 3),
            (484, 120, N'D) Ç-152 / 1 Yıl  ', 0, 4),
            (485, 121, N'A) 12  ', 0, 1),
            (486, 121, N'B) 14  ', 0, 2),
            (487, 121, N'C) 15  ', 1, 3),
            (488, 121, N'D) 18  ', 0, 4),
            (489, 122, N'A) Sınır dışı etme kararına istinaden girilen tahdit kodları kaldırılır.  ', 1, 1),
            (490, 122, N'B) Mahkeme kararına rağmen tahdit kodları 5 yıl boyunca silinmez.  ', 0, 2),
            (491, 122, N'C) Kod "N" serisine dönüştürülür.  ', 0, 3),
            (492, 122, N'D) Yabancı yeniden uluslararası koruma başvurusu yapmak zorundadır.  ', 0, 4),
            (493, 123, N'A) Yabancıya Ç-101 kodu koyarak 3 ay süreyle ülkeye sokar.  ', 0, 1),
            (494, 123, N'B) Ülkeye girişine izin verilmeyerek kabul edilemeyen yolcu (INAD) kapsamında değerlendirilir.  ', 1, 2),
            (495, 123, N'C) Ceza silinir ve vize şartı aranmaksızın içeri alınır.  ', 0, 3),
            (496, 123, N'D) Dosyası İl Hukuk Müşavirliğine sevk edilir.  ', 0, 4),
            (497, 124, N'A) 2 saat  ', 0, 1),
            (498, 124, N'B) 4 saat', 1, 2),
            (499, 124, N'C) 12 saat', 0, 3),
            (500, 124, N'D) 24 saat', 0, 4),
            (501, 124, N'E) 48 saat', 0, 5),
            (502, 125, N'A) Türkiye Cumhuriyeti’nin taraf olduğu anlaşmalarla vizeden muaf tutulan ülke vatandaşları  ', 0, 1),
            (503, 125, N'B) Geçerli ikamet veya çalışma izni bulunan yabancılar  ', 0, 2),
            (504, 125, N'C) Türk Vatandaşlığı Kanununun 28. maddesi (Mavi Kart) kapsamında olanlar  ', 0, 3),
            (505, 125, N'D) Yabancılara mahsus damgalı pasaport sahipleri  ', 0, 4),
            (506, 125, N'E) Turizm amaçlı gezecek ve deniz limanına gelen yabancılar (yetmiş iki saati geçmemek kaydıyla)  ', 1, 5),
            (507, 126, N'A) Vizenin sahteciliğe konu olduğunun tespiti  ', 0, 1),
            (508, 126, N'B) Vize sahibinin Türkiye’ye girişinin yasaklanması  ', 0, 2),
            (509, 126, N'C) Yabancı hakkında sınır dışı etme kararı alınması  ', 0, 3),
            (510, 126, N'D) Yabancının ikamet izni başvurusunda bulunması  ', 1, 4),
            (511, 126, N'E) Vize veya vize muafiyetinin amacı dışında kullanılması  ', 0, 5),
            (512, 127, N'A) 15 gün  ', 0, 1),
            (513, 127, N'B) 30 gün', 0, 2),
            (514, 127, N'C) 60 gün', 0, 3),
            (515, 127, N'D) 90 gün', 1, 4),
            (516, 127, N'E) 120 gün', 0, 5),
            (517, 128, N'A) Tamamı  ', 0, 1),
            (518, 128, N'B) Üçte ikisi', 0, 2),
            (519, 128, N'C) Yarısı  ', 1, 3),
            (520, 128, N'D) Üçte biri', 0, 4),
            (521, 128, N'E) Hiçbiri', 0, 5),
            (522, 129, N'A) Türkiye’de taşınmaz malı bulunanlar  ', 0, 1),
            (523, 129, N'B) Ticari bağlantı veya iş kuracaklar  ', 0, 2),
            (524, 129, N'C) Türkçe öğrenme kurslarına katılacaklar  ', 0, 3),
            (525, 129, N'D) Türkiye''de kesintisiz 5 yıl ikamet etmiş olanlar  ', 1, 4),
            (526, 129, N'E) Türkiye’de yükseköğrenimini tamamlayıp mezuniyetten itibaren 6 ay içinde başvuranlar  ', 0, 5),
            (527, 130, N'A) 60 gün  ', 0, 1),
            (528, 130, N'B) 90 gün', 0, 2),
            (529, 130, N'C) 120 gün', 1, 3),
            (530, 130, N'D) 180 gün', 0, 4),
            (531, 130, N'E) 365 gün', 0, 5),
            (532, 131, N'A) İlk yıldan itibaren başlayabilir ve haftada en fazla 20 saattir.  ', 0, 1),
            (533, 131, N'B) İlk yıldan sonra başlar ve haftada 24 saatten fazla olamaz.  ', 1, 2),
            (534, 131, N'C) Öğrenim süresince hiçbir şekilde çalışamazlar.', 0, 3),
            (535, 131, N'D) Kayıt yaptırdığı andan itibaren tam zamanlı çalışabilirler.', 0, 4),
            (536, 131, N'E) Sadece yaz tatillerinde sınırsız çalışma hakları vardır.', 0, 5),
            (537, 132, N'A) Askerlik yapma yükümlülüğünden muaf olmak  ', 0, 1),
            (538, 132, N'B) Seçme ve seçilme hakkı  ', 0, 2),
            (539, 132, N'C) Kamu görevlerine girme hakkı  ', 0, 3),
            (540, 132, N'D) Muaf olarak araç ithal etme hakkı  ', 0, 4),
            (541, 132, N'E) Sosyal güvenliğe ilişkin kazanılmış haklar saklı kalmak kaydıyla ilgili mevzuata tabi olmak  ', 1, 5),
            (542, 133, N'A) İlk aşama 15 gün / En fazla 1 yıl  ', 0, 1),
            (543, 133, N'B) İlk aşama 30 gün / En fazla 3 yıl  ', 1, 2),
            (544, 133, N'C) İlk aşama 60 gün / En fazla 2 yıl', 0, 3),
            (545, 133, N'D) İlk aşama 90 gün / En fazla 5 yıl', 0, 4),
            (546, 133, N'E) İlk aşama 6 ay / En fazla 3 yıl', 0, 5),
            (547, 134, N'A) Başvuru süresi 7 gün / Sonuçlandırma 7 gün  ', 0, 1),
            (548, 134, N'B) Başvuru süresi 10 gün / Sonuçlandırma 30 gün', 0, 2),
            (549, 134, N'C) Başvuru süresi 15 gün / Sonuçlandırma 15 gün  ', 1, 3),
            (550, 134, N'D) Başvuru süresi 30 gün / Sonuçlandırma 60 gün', 0, 4),
            (551, 134, N'E) Başvuru süresi 60 gün / Sonuçlandırma 30 gün', 0, 5),
            (552, 135, N'A) Vize süresini 10 günden fazla ihlal edenler  ', 0, 1),
            (553, 135, N'B) Çalışma izni olmadan çalıştığı tespit edilenler  ', 0, 2),
            (554, 135, N'C) Ciddi sağlık sorunları, yaş ve hamilelik durumu nedeniyle seyahat etmesi riskli görülenler  ', 1, 3),
            (555, 135, N'D) İkamet izni uzatma başvurusu reddedilip 10 gün içinde çıkmayanlar  ', 0, 4),
            (556, 135, N'E) Türkiye’ye yasa dışı giriş yaptığı tespit edilenler  ', 0, 5),
            (557, 136, N'A) Kural olarak 3 ay / En fazla 3 ay uzatılabilir  ', 0, 1),
            (558, 136, N'B) Kural olarak 6 ay / En fazla 6 ay uzatılabilir  ', 1, 2),
            (559, 136, N'C) Kural olarak 6 ay / En fazla 1 yıl uzatılabilir', 0, 3),
            (560, 136, N'D) Kural olarak 1 yıl / Uzatılamaz', 0, 4),
            (561, 136, N'E) Kural olarak 30 gün / En fazla 60 gün uzatılabilir', 0, 5),
            (562, 137, N'A) Mülteci  ', 0, 1),
            (563, 137, N'B) Şartlı Mülteci  ', 1, 2),
            (564, 137, N'C) İkincil Koruma  ', 0, 3),
            (565, 137, N'D) Geçici Koruma  ', 0, 4),
            (566, 137, N'E) Vatansız Kişi  ', 0, 5),
            (567, 138, N'A) 15 gün  ', 0, 1),
            (568, 138, N'B) 30 gün  ', 1, 2),
            (569, 138, N'C) 60 gün', 0, 3),
            (570, 138, N'D) 90 gün', 0, 4),
            (571, 138, N'E) 180 gün', 0, 5),
            (572, 139, N'A) Mülakat 3 gün içinde / Sonuçlandırma 5 gün içinde  ', 1, 1),
            (573, 139, N'B) Mülakat 5 gün içinde / Sonuçlandırma 10 gün içinde', 0, 2),
            (574, 139, N'C) Mülakat 7 gün içinde / Sonuçlandırma 15 gün içinde', 0, 3),
            (575, 139, N'D) Mülakat 10 gün içinde / Sonuçlandırma 30 gün içinde', 0, 4),
            (576, 139, N'E) Mülakat 1 gün içinde / Sonuçlandırma 3 gün içinde', 0, 5),
            (577, 140, N'A) Kamu düzeni açısından tehlike oluşturanlar  ', 0, 1),
            (578, 140, N'B) Sahte belge kullananlar  ', 0, 2),
            (579, 140, N'C) Refakatsiz çocuklar  ', 1, 3),
            (580, 140, N'D) Sınır dışı edilmek üzere idari gözetim altında olanlar  ', 0, 4),
            (581, 140, N'E) Başvurusu geri çekilmiş sayıldıktan sonra yeniden başvuranlar  ', 0, 5),
            (582, 141, N'A) 5 gün  ', 0, 1),
            (583, 141, N'B) 7 gün', 0, 2),
            (584, 141, N'C) 10 gün  ', 1, 3),
            (585, 141, N'D) 15 gün', 0, 4),
            (586, 141, N'E) 30 gün', 0, 5),
            (587, 142, N'A) Cumhurbaşkanı  ', 0, 1),
            (588, 142, N'B) Göç İdaresi Genel Müdürü  ', 0, 2),
            (589, 142, N'C) İçişleri Bakanı  ', 1, 3),
            (590, 142, N'D) Dışişleri Bakanı  ', 0, 4),
            (591, 142, N'E) Başbakan Yardımcısı', 0, 5),
            (592, 143, N'A) Göç Danışma Kurulu  ', 0, 1),
            (593, 143, N'B) Uluslararası Koruma Değerlendirme Komisyonu  ', 0, 2),
            (594, 143, N'C) Düzensiz Göçle Mücadele Koordinasyon Kurulu  ', 0, 3),
            (595, 143, N'D) İnsan Hakları İnceleme Kurulu', 1, 4),
            (596, 144, N'A) İdari karar alma süresi yakalama anından itibaren 24 saattir ve muhafaza İl Göç İdaresince sağlanır.', 0, 1),
            (597, 144, N'B) Evrakların fiziki ve eksiksiz tesliminden itibaren en geç 48 saat içinde idari karar alınır; bu sürede muhafaza kolluktadır.', 1, 2),
            (598, 144, N'C) İşlemler GöçNet üzerinden başlatıldığı andan itibaren 72 saat içinde valilik kararı alınır.', 0, 3),
            (599, 144, N'D) GGM olmayan illerde idari gözetim kararı alınamaz, yabancı derhal en yakın GGM bulunan ile sevk edilir.', 0, 4),
            (600, 145, N'A) Madde 55 kapsamında olduğu tespit edilen yabancılar hakkında sınır dışı etme kararı alınmaz.', 0, 1),
            (601, 145, N'B) 18 yaşından küçük çocuklar hakkında idari gözetim kararı uygulanmaz.', 0, 2),
            (602, 145, N'C) Hakkında sınır dışı kararı alındıktan sonra Madde 55 kapsamında olduğu anlaşılanların kararları derhal geri alınır.', 0, 3),
            (603, 145, N'D) Madde 55 kapsamındaki yabancılar 6 ayı geçmemek üzere geçici olarak geri gönderme merkezinde tutulabilir.', 1, 4),
            (604, 146, N'A) Tercüman olmaksızın yapılan tebliğlerde yabancının form üzerine kendi dilinde el yazısı ile "Okudum, anladım" yazması zorunludur.', 0, 1),
            (605, 146, N'B) Tebligatı imzalamak istemeyen yabancıya Tebligat Kanunu anlatılır; reddederse nedeni kendi dilinde el yazısıyla yazdırılır.', 0, 2),
            (606, 146, N'C) Yabancı reddetme nedenini de yazmak istemezse, görevli personel el yazısıyla durum şerhini düşer ve işlem tek başına personelce imzalanarak tamamlanır.', 1, 3),
            (607, 146, N'D) Okuma yazması olmayan yabancılarda tercüman "aslına sadık kalarak anlattım" şerhiyle imzalar, yabancı ise "Bana anlatılanı anladım" yazarak parmak basar.', 0, 4),
            (608, 147, N'A) Kara Kuvvetleri Komutanlığı yakaladığı yabancıların tüm adli ve idari evraklarını eksiksiz kendisi tanzim ederek İl Göç İdaresine teslim eder.', 0, 1),
            (609, 147, N'B) Sahil Güvenlik Komutanlığı yakaladığı yabancıları her durumda doğrudan en yakın Geri Gönderme Merkezine teslim etmekle yükümlüdür.', 0, 2),
            (610, 147, N'C) Kara Kuvvetlerince yakalananlarda yakalama, üst arama tutanağı ve sağlık raporunu Kara Kuvvetleri; diğer evrakları teslim alan genel kolluk hazırlar.', 1, 3),
            (611, 147, N'D) Gümrük Muhafaza birimleri yakaladıkları yabancıları evrak tanzim etmeksizin derhal Emniyet birimlerine sevk eder.', 0, 4),
            (612, 148, N'A) İdari gözetim kararı her yabancı için ilk aşamada kural olarak 6 ay süreli alınır.', 0, 1),
            (613, 148, N'B) Alınan idari gözetim kararları en geç 3 aylık periyotlarla İl Göç İdaresi tarafından yeniden değerlendirilir.', 1, 2),
            (614, 148, N'C) Kararlar GöçNet sistemi üzerinden 5070 sayılı Elektronik İmza Kanununa uygun olarak e-imza ile alınır.', 0, 3),
            (615, 148, N'D) E-imzanın bulunmadığı veya teknik aksaklık yaşandığı durumlarda GöçNet kararları mutlaka ıslak imzalı olarak tanzim edilir.', 0, 4),
            (616, 149, N'A) İl Göç İdaresi Müdürlüğü gerekli gördüğü takdirde herhangi bir makam onayı olmaksızın kolluk personelini yurt dışına refakatçi gönderebilir.', 0, 1),
            (617, 149, N'B) Yurt dışı refakat görevinde personelin uçak bilet bedelleri, kendisine ödenecek yevmiye/harcırah hesabına dahil edilerek personele nakden ödenir.', 0, 2),
            (618, 149, N'C) Yurt dışı mevcutlu sınır dışı işlemlerinde Göç İdaresi Genel Müdürlüğünün yazılı onayı şarttır ve mücbir sebep olmaksızın fazladan kalınan süreye harcırah ödenmez.', 1, 3),
            (619, 149, N'D) Sınır dışı edilen ülkede geçirilen tüm sürenin harcırahı, dönüş süresine bakılmaksızın ilgili kolluk biriminin kendi bütçesinden karşılanır.', 0, 4),
            (620, 150, N'A) Seyahat masrafını kendisi karşılayan yabancılara da standart olarak 5 yıl süreli mali tahdit veri girişi yapılır.', 0, 1),
            (621, 150, N'B) Bilet ve seyahat belgesi masrafları İl Göç İdaresince karşılanan yabancıya, karşılanan miktar kadar seyahat masrafı tahdit veri girişi yapılır.', 1, 2),
            (622, 150, N'C) Yabancı sınır dışı edilemeyip ülkede kaldığı sürece, devletçe yapılan masrafların tahdit kaydı silinmez.', 0, 3),
            (623, 150, N'D) Ülke temsilciliğinden alınan seyahat belgesi ücretleri her durumda genel kolluk bütçesinden ödenir ve tahdit konusu yapılmaz.', 0, 4),
            (624, 151, N'A) Mahkemece hakkında "yurt dışına çıkış yasağı" adli kontrol kararı verilen yabancıların takibi sorumluluk sahasına göre kollukça yapılır.', 0, 1),
            (625, 151, N'B) Yasal kalış süresi bulunan ve hakkında istihbarat/güvenlik olumsuz görüşü olmayan serbest kalmış yabancılar İl Göç İdaresine teslim edilmez, kollukça serbest bırakılır.', 0, 2),
            (626, 151, N'C) Yasal kalış hakkı bulunmayan yabancılar adli makamlarca serbest bırakılsa dahi hakkında sınır dışı hükümleri uygulanmak üzere İl Göç İdaresine teslim edilir.', 0, 3),
            (627, 151, N'D) Yurt dışına çıkış yasağı kararı bulunan yabancıların bu yasağının kaldırılması için adli makamlarla yazışmaları doğrudan Emniyet Asayiş Şube yürütür.', 1, 4),
            (628, 152, N'A) Bu alanlarda barındırılan yabancıların iaşe giderleri Göç İdaresi Genel Müdürlüğü bütçesinden karşılanır.', 0, 1),
            (629, 152, N'B) Geri Gönderme Merkezi bahçesinde yer alan alanların elektrik, su ve doğalgaz abonelik giderleri İl Göç İdaresi Müdürlüğünce ödenir.', 0, 2),
            (630, 152, N'C) Kolluk kullanımına verilen alanların iç ve dış güvenliği, temizliği, tamiratı ve kırtasiye/yazıcı giderleri ilgili kolluk birimlerince karşılanır.', 0, 3),
            (631, 152, N'D) Geçici barındırma alanlarının kullanım aşamasındaki tüm tefrişat ve bakım masrafları sürekli olarak Göç İdaresi Genel Müdürlüğü bütçesinden ödenir.', 1, 4),
            (632, 153, N'A) Sevk sırasındaki yol güzergahını belirleme yetkisi İl Göç İdaresi Müdürlüğü personeline aittir.', 0, 1),
            (633, 153, N'B) Sorumlu kolluk biriminin tespitinde veya risk değerlendirmesinde çıkacak uyuşmazlıklar Mülki İdare Amiri (Vali/Kaymakam) tarafından karara bağlanır.', 1, 2),
            (634, 153, N'C) Havalimanlarında sınır dışı işlemlerinde çıkan idari sorunları çözmek üzere Emniyet Genel Müdürlüğü merkez teşkilatı doğrudan müdahale eder.', 0, 3),
            (635, 153, N'D) GGM''den hastane veya mahkemeye sevklerde güvenlik tedbiri alma görevi Sahil Güvenlik Komutanlığına verilir.', 0, 4),
            (676, 164, N'A) Sadece büyükşehir belediye başkanları emekliliklerinde de hususi pasaport kullanabilir.', 0, 1),
            (677, 164, N'B) Büyükşehir, il ve ilçe belediye başkanlarına yalnızca görevleri süresince hususi damgalı pasaport verilir.', 1, 2),
            (678, 164, N'C) Belde belediye başkanları en az iki dönem görev yaptıktan sonra hususi pasaport alma hakkı kazanır.', 0, 3),
            (679, 164, N'D) Belediye başkanları görev süreleri bitse dahi kadro derecelerine bakılmaksızın hususi pasaportlarını muhafaza ederler.', 0, 4),
            (680, 164, N'E) Belediye başkanlarına hususi pasaport değil, görevleri nedeniyle hizmet damgalı (gri) pasaport verilir.', 0, 5),
            (681, 165, N'A) Evli bulunmamaları gerekir.', 0, 1),
            (682, 165, N'B) Öğrenime devam ediyor olmaları şarttır.', 0, 2),
            (683, 165, N'C) İş sahibi olmamaları (çalışmamaları) gerekir.', 0, 3),
            (684, 165, N'D) Yaşlarının 28''i doldurmamış olması gerekir.', 1, 4),
            (685, 165, N'E) Hak sahibi ebeveyn ile birlikte yaşamaları şartı aranmaz.', 0, 5),
            (686, 166, N'A) İçişleri Bakanlığı', 0, 1),
            (687, 166, N'B) Cumhurbaşkanlığı İdari İşler Başkanlığı', 0, 2),
            (688, 166, N'C) Dışişleri Bakanlığı', 1, 3),
            (689, 166, N'D) Nüfus ve Vatandaşlık İşleri Genel Müdürlüğü', 0, 4),
            (690, 166, N'E) Adalet Bakanlığı', 0, 5),
            (691, 167, N'A) En fazla 30 yaşına kadar uzatılır.', 0, 1),
            (692, 167, N'B) Yaş sınırı aranmaksızın pasaport verilebilir.', 1, 2),
            (693, 167, N'C) Sadece hak sahibi ebeveyn hayatta olduğu sürece 25 yaş sınırı uygulanır.', 0, 3),
            (694, 167, N'D) Sağlık kurulu raporu olsa dahi 25 yaşını geçen çocuklara verilemez.', 0, 4),
            (695, 167, N'E) Bu durumdaki çocuklara yalnızca Umuma Mahsus (Bordo) Pasaport harçsız verilir.', 0, 5),
            (696, 168, N'A) Sözleşmeli personel hiçbir şekilde hususi pasaport alamaz.', 0, 1),
            (697, 168, N'B) Yalnızca yurt dışı teşkilatında görev yapması şartıyla alabilir.', 0, 2),
            (698, 168, N'C) Kadro karşılığı sözleşmeli çalışıp 1, 2 veya 3. derece kadro karşılığı olanlar da hususi pasaport alabilir.', 1, 3),
            (699, 168, N'D) En az 15 yıl hizmet süresini doldurmuş olmaları kaydıyla alabilirler.', 0, 4),
            (700, 168, N'E) Sadece Dışişleri Bakanlığı bünyesindeki sözleşmeli personel bu haktan yararlanır.', 0, 5),
            (701, 169, N'A) Umuma Mahsus Pasaport (Harçtan muaf)', 0, 1),
            (702, 169, N'B) Hizmet Damgalı Pasaport', 1, 2),
            (703, 169, N'C) Hususi Damgalı Pasaport', 0, 3),
            (704, 169, N'D) Yabancılara Mahsus Pasaport', 0, 4),
            (705, 169, N'E) Geçici Pasaport', 0, 5),
            (706, 170, N'A) Sadece idari para cezası uygulanır ve kişi serbest bırakılır.', 0, 1),
            (707, 170, N'B) Pasaport Kanunu''na muhalefetten adli ceza (hapis veya adli para cezası) uygulanır.', 1, 2),
            (708, 170, N'C) Pasaportuna 5 yıl süreyle el konulur.', 0, 3),
            (709, 170, N'D) Herhangi bir ceza uygulanmaz, kişi ilk sınır kapısına yönlendirilir.', 0, 4),
            (710, 170, N'E) Yalnızca yabancı uyruklulara ceza verilir, T.C. vatandaşları muaf tutulur.', 0, 5),
            (711, 171, N'A) Anayasa Mahkemesi Başkanı ve Üyeleri', 0, 1),
            (712, 171, N'D) İl Belediye Başkanları', 1, 2),
            (713, 172, N'A) Hak sahibine yaşamı boyunca geçerli olmak üzere verilir.', 0, 1),
            (714, 172, N'B) Sadece görev süresi ve amaca uygun olarak verilir, görev bitiminde yetkili kuruma iade edilir.', 1, 2),
            (715, 172, N'C) Hak sahibinin tüm akrabaları bu pasaporttan yararlanabilir.', 0, 3),
            (716, 172, N'D) İçişleri Bakanlığı izni olmadan yurt içinde ticari faaliyetlerde kullanılabilir.', 0, 4),
            (717, 172, N'E) Memuriyetten istifa edenler bu pasaportu kullanmaya devam edebilirler.', 0, 5),
            (718, 173, N'A) Dışişleri Bakanlığı kararıyla 10 yıl süreyle dondurulur.', 0, 1),
            (719, 173, N'B) Pasaportları hükümsüz kılınır (iptal edilir) ve kendilerine sadece Türkiye''ye dönmelerini sağlayacak pasaport/seyahat belgesi verilir.', 1, 2),
            (720, 173, N'C) Pasaport hakkı tamamen elinden alınır ve vatansız (haymatlos) statüsüne geçirilir.', 0, 3),
            (721, 173, N'D) Pasaportları Konsolosluk tarafından uzatılır ancak vize verilmez.', 0, 4),
            (722, 173, N'E) Yalnızca mahkeme kararı kesinleştikten sonra iptal edilebilir.', 0, 5),
            (723, 174, N'A) Koyu mavi - Kağıt', 0, 1),
            (724, 174, N'B) Koyu kırmızı (Dark red) - Sentetik/Polymer', 1, 2),
            (725, 174, N'C) Yeşil - Deri', 0, 3),
            (726, 174, N'D) Siyah - Karton', 0, 4),
            (727, 175, N'A) Sadece ön kapakta, renk değiştirir', 0, 1),
            (728, 175, N'B) Kağıt içinde, ışığa tutulduğunda görünür', 1, 2),
            (729, 175, N'C) Yalnızca UV ışıkta', 0, 3),
            (730, 175, N'D) Dokunmatik kabartma', 0, 4),
            (731, 176, N'A) Basit hologram', 0, 1),
            (732, 176, N'B) İkinci portre (Second portrait on page 3)', 1, 2),
            (733, 176, N'C) Sadece UV mürekkep', 0, 3),
            (734, 176, N'D) Manyetik şerit', 0, 4),
            (735, 177, N'A) Basit yapıştırma', 0, 1),
            (736, 177, N'B) Güvenlik laminatı (özel desenler, UV reaksiyonu)', 1, 2),
            (737, 177, N'C) Normal plastik kaplama', 0, 3),
            (738, 177, N'D) Sadece renkli baskı', 0, 4),
            (739, 178, N'A) Normal fotoğraf', 0, 1),
            (740, 178, N'B) Laser gravür + optik değişken mürekkep', 1, 2),
            (741, 178, N'C) Yapıştırma fotoğraf', 0, 3),
            (742, 178, N'D) Sadece siyah-beyaz', 0, 4),
            (743, 179, N'A) Hiçbir şey görünmez', 0, 1),
            (744, 179, N'B) Sadece metin', 0, 2),
            (745, 179, N'C) Bulgar bayrağı ve özel semboller', 1, 3),
            (746, 179, N'D) Rastgele noktalar', 0, 4),
            (747, 180, N'A) Normal dikiş', 0, 1),
            (748, 180, N'B) Yapıştırıcı', 0, 2),
            (749, 180, N'C) Güvenlik ipliği + özel dikiş deseni', 1, 3),
            (750, 180, N'D) Metal klips', 0, 4),
            (751, 181, N'A) Boş sayfa', 0, 1),
            (752, 181, N'B) Sadece yazı', 0, 2),
            (753, 181, N'C) Özel desenli filigran ve UV mürekkep', 1, 3),
            (754, 181, N'D) Hologram yok', 0, 4),
            (755, 182, N'A) Barkod', 0, 1),
            (756, 182, N'B) Mikro yazı', 0, 2),
            (757, 182, N'C) Kinegram / Değişken hologram veya guilloche desen', 1, 3),
            (758, 182, N'D) RFID çip (sadece e-pasaport)', 0, 4),
            (759, 183, N'A) Sadece renkli baskı', 0, 1),
            (760, 183, N'B) Sadece manyetik şerit', 0, 2),
            (761, 183, N'C) Filigran + Laminate + UV + Laser gravür + Özel iplik kombinasyonu', 1, 3),
            (762, 183, N'D) Basit kağıt doküman', 0, 4);
        SET IDENTITY_INSERT [dbo].[QuestionOption] OFF;
        PRINT 'Tablo [dbo].[QuestionOption] icin 398 kayit eklendi.';
    END
END
GO

-- --------------------------------------------------------------------------
-- Veri: [dbo].[Answer]
-- --------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[Answer]', N'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Answer])
    BEGIN
        SET IDENTITY_INSERT [dbo].[Answer] ON;
        INSERT INTO [dbo].[Answer] ([AnswerId], [ExamResultId], [QuestionId], [OptionId], [TextAnswer]) VALUES
            (71, 2, 174, NULL, NULL),
            (72, 2, 175, NULL, NULL),
            (73, 2, 176, NULL, NULL),
            (74, 2, 177, NULL, NULL),
            (75, 2, 178, NULL, NULL),
            (76, 2, 179, NULL, NULL),
            (77, 2, 180, NULL, NULL),
            (78, 2, 181, NULL, NULL),
            (79, 2, 182, NULL, NULL),
            (80, 2, 183, NULL, NULL);
        SET IDENTITY_INSERT [dbo].[Answer] OFF;
        PRINT 'Tablo [dbo].[Answer] icin 10 kayit eklendi.';
    END
END
GO

