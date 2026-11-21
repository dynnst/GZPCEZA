-- =========================================================================================
-- Script: 14_CREATE_CEZA_PARAMETRE_VE_GENELGE_SINIFLANDIRMA.sql
-- Veritabanı: CEZA (veya canlı ortam hedef veritabanı)
-- Modül: Ceza, Basamak ve Ülke Sınıflandırmaları Parametre Yönetimi
-- Tarih: 22 Kasım 2026
-- Yasal Dayanak:
--   1. 6458 Sayılı YUKK Md. 53/54 (V-137 Terke Davet Rejimi ve İdari Para Cezası)
--   2. EGM Genelgesi: 04.06.2013 tarih ve 41139-5 sayılı yazı (Harçtan Muaf Ülkelere İdari Yaptırım)
--   3. EGM Genelgesi: 25.03.2011 tarih ve 68506 sayılı yazı (Ülkeler Harç ve Ceza Sınıflandırması)
--   4. 492 Sayılı Harçlar Kanunu (6 Sayılı Tarife) ve POLNET Vize İhlal Cetveli
-- Açıklama:
--   Bu betik, hesaplama motorundaki sabit kalmış (hardcoded) ceza tutarlarını, özel gün
--   basamaklarını ve genelgelerdeki ülke gruplarını dinamik ve yönetilebilir kılmak üzere
--   'CezaParametre' tablosunu oluşturur ve varsayılan resmi değerleri yükler.
--   Mevcut tablolara (E_History, E_AUH, E_TGVH vb.) ASLA dokunmaz. Güvenli ve idempotenttir.
-- =========================================================================================

IF DB_ID('CEZA') IS NOT NULL
BEGIN
    USE [CEZA];
END
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Tablo Kontrolü ve Oluşturulması
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CezaParametre' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[CezaParametre] (
        [ParamKey]         NVARCHAR(50)   NOT NULL PRIMARY KEY,
        [ParamValue]       NVARCHAR(MAX)  NOT NULL,
        [ParamTitle]       NVARCHAR(150)  NOT NULL,
        [ParamDescription] NVARCHAR(500)  NULL,
        [ParamGroup]       NVARCHAR(50)   NOT NULL,
        [UpdatedAt]        DATETIME       NOT NULL DEFAULT GETDATE(),
        [UpdatedBy]        NVARCHAR(100)  NULL
    );
    PRINT '>> [BASARILI] CezaParametre tablosu olusturuldu.';
END
ELSE
BEGIN
    PRINT '>> [BILGI] CezaParametre tablosu zaten mevcut.';
END
GO

-- 2. Varsayılan Parametrelerin Güvenli Olarak Eklenmesi (MERGE)
MERGE INTO [dbo].[CezaParametre] AS target
USING (VALUES
    ('V137_IDARI_CEZA', '20605', N'V-137 Terke Davet Süresi Aşımı İdari Para Cezası (TL)', N'6458 sayılı YUKK m. 53/54 gereğince terke davet süresini aşan yabancılara uygulanan idari para cezası tutarı.', 'Ceza'),
    ('FGRUBU_DAY9_KAT', '467.6', N'F Grubu (Norveç vb.) 9. Gün Özel Basamak Sıçraması (TL)', N'POLNET Vize İhlal Cetveli uyarınca F Grubu (Norveç, Sırbistan vb.) için 9. günde uygulanan ara basamak tamamlama tutarı.', 'Basamak'),
    ('KABAHATLER_M32_CEZA', '1854', N'Harçtan Muaf Ülkeler (G Grubu) İdari Yaptırım Tabanı (TL)', N'04.06.2013 tarihli ve 41139-5 sayılı EGM Genelgesi uyarınca ikamet harcından muaf tutulan G Grubu ülkeler için uygulanan 1 kat idari yaptırım tabanı (Yetişkinde 2 katı uygulanır).', 'Ceza'),
    ('ULKE_FGRUBU', N'Norveç, Sırbistan, Fiji, Kuzey Mariana Adaları', N'F Grubu Ülkeleri (Özel Basamak Rejimi)', N'Özel kademeli günlük/aylık Türk Lirası artış cetveline tabi ülkeler.', 'Ulke'),
    ('ULKE_GGRUBU', N'Danimarka, Kosova, Çek Cumhuriyeti, İrlanda, Nepal, Sri Lanka, Suriye, Türkmenistan', N'G Grubu Ülkeleri (Harçtan Muaf / İdari Yaptırım)', N'04.06.2013 tarih ve 41139-5 sayılı genelge ile ikamet harcından muaf olup Kabahatler Kanununa göre idari yaptırım uygulanan ülkeler.', 'Ulke'),
    ('ULKE_BGRUBU', N'Filipinler, İsrail, Japonya, Kamboçya, Makedonya, Mali, Umman, Arnavutluk, Tacikistan', N'B Grubu Ülkeleri (Genelge 2011/68506)', N'1 aya kadar 0.5 USD/gün (5-14 USD), 1 aydan sonra 3.5 USD/ay uygulanan ülkeler.', 'Ulke'),
    ('ULKE_CGRUBU', N'İspanya, Malta, Beyaz Rusya, Kuveyt, Belçika, Singapur, Tayvan, Cezayir, Lüksemburg, Ürdün', N'C Grubu Ülkeleri (Genelge 2011/68506)', N'1 aya kadar 0.4 USD/gün (4-9 USD), 1 aydan sonra 2.5 USD/ay uygulanan ülkeler.', 'Ulke'),
    ('ULKE_DGRUBU', N'Hong Kong SAR - Çin, Mikronezya Federal Eyaletleri, Rusya Federasyonu, Etiyopya, Güney Kore', N'D Grubu Ülkeleri (Genelge 2011/68506)', N'1 aya kadar 0.3 USD/gün (3-7 USD), 1 aydan sonra 1.5 USD/ay uygulanan ülkeler.', 'Ulke'),
    ('ULKE_EGRUBU', N'Fas, Fildişi Sahilleri, Irak, Sırbistan-Karadağ, Karadağ, Mısır, Tunus', N'E Grubu Ülkeleri (Genelge 2011/68506)', N'1 aya kadar 0.2 USD/gün (2-5 USD), 1 aydan sonra 0.5 USD/ay uygulanan ülkeler.', 'Ulke')
) AS source (ParamKey, ParamValue, ParamTitle, ParamDescription, ParamGroup)
ON target.ParamKey = source.ParamKey
WHEN NOT MATCHED THEN
    INSERT (ParamKey, ParamValue, ParamTitle, ParamDescription, ParamGroup, UpdatedAt, UpdatedBy)
    VALUES (source.ParamKey, source.ParamValue, source.ParamTitle, source.ParamDescription, source.ParamGroup, GETDATE(), 'SystemInit');
GO

PRINT '>> [BASARILI] CezaParametre kayitlari kontrol edildi ve guncellendi.';
PRINT '>> Canli kurulum tamamlandi.';
GO
