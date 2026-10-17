-- ==========================================================================
-- CEZAM VÄ°ZE VE CEZA HESAPLAMA SÄ°STEMÄ° - TEMEL REFERANS VE SÄ°STEM VERÄ°LERÄ°
-- Dosya: 02_SEED_CORE_LOOKUP_DATA.sql
-- Tarih: 17.10.2026 23:21:39
-- AÃ§Ä±klama: SÄ±nÄ±r kapÄ±larÄ±, harÃ§/ceza tarifeleri, tahdit kodlarÄ±, form ve kullanÄ±cÄ±lar.
-- ==========================================================================
USE [CEZA];
GO

-- --------------------------------------------------------------------------
-- Veri: [dbo].[E_Border]
-- --------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[E_Border]', N'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dbo].[E_Border])
    BEGIN
        SET IDENTITY_INSERT [dbo].[E_Border] ON;
        INSERT INTO [dbo].[E_Border] ([fldId], [fldName]) VALUES
            (5, N'ANTALYA HAVA LİMANI'),
            (6, N'İSTANBUL HAVALİMANI'),
            (7, N'İSTANBUL SABİHA GÖKÇEN HAVA LİMANI'),
            (8, N'İSTANBUL ATATÜRK HAVA LİMANI'),
            (9, N'İZMİR ADNAN MENDERES HAVA LİMANI'),
            (10, N'MUĞLA DALAMAN HAVA LİMANI'),
            (11, N'ANKARA ESENBOĞA HAVA LİMANI'),
            (12, N'MUĞLA MİLAS-BODRUM HAVA LİMANI'),
            (13, N'ADANA ŞAKİRPAŞA HAVA LİMANI'),
            (14, N'ANTALYA GAZİPAŞA HAVA LİMANI'),
            (15, N'TRABZON HAVA LİMANI'),
            (16, N'GAZİANTEP HAVA LİMANI'),
            (17, N'KAYSERİ HAVA LİMANI'),
            (18, N'HATAY HAVA LİMANI'),
            (19, N'SAMSUN ÇARŞAMBA HAVA LİMANI'),
            (20, N'KONYA HAVA LİMANI'),
            (21, N'DENİZLİ ÇARDAK HAVA LİMANI'),
            (22, N'ESKİŞEHİR HASAN POLATKAN HAVA LİMANI'),
            (23, N'DİYARBAKIR HAVA LİMANI'),
            (24, N'ISPARTA SÜLEYMAN DEMİREL HAVA LİMANI'),
            (25, N'ELAZIĞ HAVA LİMANI'),
            (26, N'ORDU GİRESUN HAVA LİMANI'),
            (27, N'KÜTAHYA ZAFER HAVA LİMANI'),
            (28, N'ADANA İNCİRLİK HAVALİMANI'),
            (29, N'BURSA YENİŞEHİR HAVA LİMANI'),
            (30, N'ARTVİN HOPA HAVA LİMANI'),
            (31, N'ŞANLIURFA GAP HAVA LİMANI'),
            (32, N'MALATYA HAVA LİMANI'),
            (33, N'ZONGULDAK ÇAYCUMA HAVA LİMANI'),
            (34, N'AMASYA MERZİFON HAVA LİMANI'),
            (35, N'ERZURUM HAVA LİMANI'),
            (36, N'ANKARA ETİMESGUT ASKERİ HAVALİMANI'),
            (37, N'KOCAELİ CENGİZ TOPEL HAVA LİMANI'),
            (38, N'BALIKESİR KOCA SEYİT HAVA LİMANI'),
            (40, N'KAPADOKYA HAVA LİMANI'),
            (41, N'ÇANAKKALE HAVA LİMANI'),
            (42, N'VAN FERİT MELEN HAVA LİMANI'),
            (43, N'TEKİRDAĞ ÇORLU HAVA LİMANI'),
            (44, N'KASTAMONU HAVA LİMANI'),
            (45, N'MARDİN HAVA LİMANI'),
            (46, N'MUŞ HAVA LİMANI'),
            (47, N'IĞDIR HAVALİMANI HUDUT KAPISI'),
            (48, N'İZMİR ÇİĞLİ ASKERİ HAVALİMANI'),
            (49, N'BATMAN HAVA LİMANI'),
            (50, N'ADIYAMAN HAVA LİMANI'),
            (51, N'ERZİNCAN HAVA LİMANI'),
            (52, N'ANKARA MÜRTED GEÇİCİ HAVA HUDUT KAPISI'),
            (53, N'UŞAK HAVA LİMANI'),
            (54, N'KARS HARAKANİ HAVA LİMANI'),
            (55, N'BİNGÖL HAVA LİMANI'),
            (56, N'SİNOP HAVA LİMANI'),
            (57, N'KAHRAMANMARAŞ HAVA LİMANI'),
            (58, N'AĞRI AHMED-İ HANİ HAVA LİMANI'),
            (59, N'BALIKESİR BANDIRMA ASKERİ HAVA LİMANI'),
            (60, N'BALIKESİR ASKERİ-MERKEZ HAVA LİMANI'),
            (61, N'EDİRNE KAPIKULE KARA HUDUT KAPISI'),
            (62, N'ARTVİN SARP KARA HUDUT KAPISI'),
            (63, N'ŞIRNAK HABUR KARA HUDUT KAPISI'),
            (64, N'EDİRNE İPSALA KARA HUDUT KAPISI'),
            (65, N'AĞRI GÜRBULAK KARA HUDUT KAPISI'),
            (66, N'EDİRNE HAMZABEYLİ KARA HUDUT KAPISI'),
            (67, N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI'),
            (68, N'VAN KAPIKÖY KARA HUDUT KAPISI'),
            (69, N'EDİRNE PAZARKULE KARA HUDUT KAPISI'),
            (71, N'HAKKARİ ESENDERE KARA HUDUT KAPISI'),
            (72, N'IĞDIR DİLUCU KARA HUDUT KAPISI'),
            (73, N'KİLİS ÖNCÜPINAR KARA HUDUT KAPISI'),
            (74, N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI'),
            (75, N'ARDAHAN AKTAŞ KARA HUDUT KAPISI'),
            (76, N'GAZİANTEP KARKAMIŞ KARA HUDUT KAPISI'),
            (77, N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI'),
            (78, N'HAKKARİ ÜZÜMLÜ KARA HUDUT KAPISI'),
            (79, N'KİLİS ÇOBANBEY KARA HUDUT KAPIS'),
            (80, N'HATAY YAYLADAĞI HUDUT KAPISI'),
            (81, N'HATAY KUMLU GEÇİCİ KARA HUDUT KAPISI'),
            (82, N'ŞANLIURFA AKÇAKALE KARA HUDUT KAPISI'),
            (83, N'EDİRNE KAPIKULE DEMİRYOLU HUDUT KAPISI'),
            (84, N'VAN KAPIKÖY DEMİRYOLU HUDUT KAPISI'),
            (85, N'KARS TREN GARI GEÇİCİ DEMİRYOLU HUDUT KAPISI'),
            (86, N'EDİRNE UZUNKÖPRÜ DEMİRYOLU HUDUT KAPISI'),
            (87, N'MUĞLA BODRUM DENİZ HUDUT KAPISI'),
            (88, N'ÇEŞME DENİZ HUDUT KAPISI'),
            (89, N'MARMARİS DENİZ HUDUT KAPISI'),
            (90, N'MUĞLA BODRUM YOLCU İSKELESİ DENİZ HUDUT KAPISI'),
            (91, N'MERSİN DENİZ HUDUT KAPISI'),
            (92, N'BALIKESİR AYVALIK DENİZ HUDUT KAPISI'),
            (93, N'KOCAELİ DERİNCE DENİZ HUDUT KAPISI'),
            (94, N'AYDIN KUŞADASI DENİZ HUDUT KAPISI'),
            (95, N'MUĞLA TURGUT REİS DENİZ HUDUT KAPISI'),
            (96, N'MERSİN TAŞUCU-SEKA DENİZ HUDUT KAPISI'),
            (97, N'MERSİN TAŞUCU DENİZ HUDUT KAPISI'),
            (98, N'MUĞLA FETHİYE DENİZ HUDUT KAPISI'),
            (99, N'İZMİR ALİAĞA DENİZ HUDUT KAPISI'),
            (100, N'ANTALYA KAŞ DENİZ HUDUT KAPISI'),
            (101, N'İSTANBUL TUZLA DENİZ HUDUT KAPISI'),
            (102, N'SAMSUN DENİZ HUDUT KAPISI'),
            (103, N'İSTANBUL AMBARLI DENİZ HUDUT KAPISI'),
            (104, N'İSTANBUL ZEYTİNBURNU DENİZ HUDUT KAPISI'),
            (105, N'İZMİR (EM -5)  DENİZ HUDUT KAPISI'),
            (106, N'ZONGULDAK DENİZ HUDUT KAPISI'),
            (107, N'İZMİR SEFERİHİSAR DENİZ HUDUT KAPISI'),
            (108, N'TEKİRDAĞ MARMARA EREĞLİSİ DENİZ HUDUT KAPISI'),
            (109, N'YALOVA RO-RO DENİZ HUDUT KAPISI'),
            (110, N'MUĞLA BOZBURUN DENİZ HUDUT KAPISI'),
            (111, N'İSTANBUL PENDİK DENİZ HUDUT KAPISI'),
            (112, N'İSTANBUL HAYDARPAŞA DENİZ HUDUT KAPISI'),
            (113, N'İSKENDERUN DENİZ HUDUT KAPISI'),
            (114, N'MUĞLA YALIKAVAK DENİZ HUDUT KAPISI'),
            (115, N'SAKARYA KARASU DENİZ HUDUT KAPISI'),
            (116, N'ÇANAKKALE KÜÇÜKKUYU DENİZ HUDUT KAPISI'),
            (117, N'MUĞLA DATÇA DENİZ HUDUT KAPISI'),
            (118, N'BURSA GEMLİK DENİZ HUDUT KAPISI'),
            (119, N'BALIKESİR BANDIRMA DENİZ HUDUT KAPISI'),
            (120, N'HATAY İSKENDERUN ATAKAŞ LİMANI DENİZ HUDUT KAPISI'),
            (121, N'TRABZON DENİZ HUDUT KAPISI'),
            (122, N'TEKİRDAĞ ASYAPORT LİMAN TESİSİ DENİZ HUDUT KAPISI'),
            (123, N'HATAY İSKENDERUN YAZICI DENİZ HUDUT KAPISI'),
            (124, N'ANTALYA DENİZ HUDUT KAPISI'),
            (125, N'SAMSUN YEŞİLYURT KIYI TESİSİ DENİZ HUDUT KAPISI'),
            (126, N'ZONGULDAK EREN DENİZ LİMANI'),
            (127, N'HATAY İSDEMİR DENİZ HUDUT KAPISI'),
            (128, N'MUĞLA GÖCEK DENİZ HUDUT KAPISI'),
            (129, N'MERSİN YEŞİLOVACIK DENİZ HUDUT KAPISI'),
            (130, N'MUĞLA GÜLLÜK MANDALYA DENİZ HUDUT KAPISI'),
            (131, N'ZONGULDAK- EREĞLİ DENİZ BÜRO AMİRLİĞİ'),
            (132, N'ANTALYA ALANYA DENİZ HUDUT KAPISI'),
            (133, N'AYDIN DİDİM DENİZ HUDUT KAPISI'),
            (134, N'GİRESUN DENİZ HUDUT KAPISI'),
            (135, N'ARTVİN HOPA DENİZ HUDUT KAPISI'),
            (136, N'İZMİR DİKİLİ DENİZ HUDUT KAPISI'),
            (137, N'ADANA BOTAŞ DENİZ HUDUT KAPISI'),
            (138, N'ADANA TOROS TARIM DENİZ HUDUT KAPISI'),
            (139, N'HATAY İSKENDERUN EKİNCI DENİZ HUDUT KAPISI'),
            (140, N'BARTIN DENİZ HUDUT KAPISI'),
            (141, N'HATAY MMK METALURJİ DENİZ HUDUT KAPISI'),
            (142, N'İSTANBUL SARAYBURNU DENİZ HUDUT KAPISI'),
            (143, N'ÇANAKKALE KEPEZ DENİZ HUDUT KAPISI'),
            (144, N'ÇANAKKALE İÇDAŞ DENİZ HUDUT KAPISI'),
            (145, N'ORDU ÜNYE DENİZ HUDUT KAPISI'),
            (146, N'İZMİR FOÇA DENİZ HUDUT KAPISI'),
            (147, N'BALIKESİR BANDIRMA BAĞFAŞ DENİZ HUDUT KAPISI'),
            (148, N'ANTALYA KAŞ-SETUR MARİNA DENİZ HUDUT KAPISI'),
            (149, N'HATAY İSKENDERUN ASSAN DENİZ HUDUT KAPISI'),
            (150, N'KASTAMONU İNEBOLU DENİZ HUDUT KAPISI'),
            (151, N'SAMSUN TOROS TARIM DENİZ HUDUT KAPISI'),
            (152, N'ÇANAKKALE YAT LİMANI DENİZ HUDUT KAPI'),
            (153, N'ANTALYA FİNİKE DENİZ HUDUT KAPISI'),
            (154, N'MARMARA DENİZ HUDUT KAPISI'),
            (155, N'HATAY DÖRTYOL BOTAŞ DENİZ HUDUT KAPISI'),
            (156, N'ADANA SANKO LİMANI DENİZ HUDUT KAPISI'),
            (157, N'HATAY DÖRTYOL RUBİS DENİZ HUDUT KAPISI'),
            (158, N'ORDU FATSA DENİZ HUDUT KAPISI'),
            (159, N'SİNOP DENİZ HUDUT KAPISI'),
            (160, N'ÇANAKKALE BOZCAADA DENİZ HUDUT KAPISI'),
            (161, N'MUĞLA GÜLLÜK DENİZ HUDUT KAPISI'),
            (162, N'AYDIN DİDİM YAT LİMANI DENİZ HUDUT KAPISI BÜRO AMİRLİĞİ'),
            (163, N'HATAY İSKENDERUN GÜBRETAŞ DENİZ HUDUT KAPISI'),
            (164, N'RİZE DENİZ HUDUT KAPISI'),
            (165, N'ÇANAKKALE KARABİGA DENİZ HUDUT KAPISI'),
            (166, N'ANTALYA KEMER DENİZ HUDUT KAPISI'),
            (167, N'MERSİN ERDEMLİ KUMKUYU YAT LİMANI'),
            (168, N'İSTANBUL KARAKÖY DENİZ BÜRO AMİRLİĞİ'),
            (169, N'MERSİN AYDINCIK DENİZ HUDUT KAPISI'),
            (170, N'KIRKLARELİ İĞNEADA LİMANI GEÇİCİ DENİZ HUDUT KAPISI'),
            (172, N'RİZE ARTVİN HAVA HUDUT KAPISI'),
            (173, N'HATAY MADENLİ YAT LİMANI DENİZ HUDUT KAPISI'),
            (175, N'SİVAS NURİ DEMİRAĞ HAVALİMANI'),
            (176, N''),
            (177, N'HAKKARİ DERECİK SINIR KAPISI'),
            (178, N'HATAY ARSUZ DENİZ LİMANI'),
            (179, N'ÇUKUROVA HAVALİMANI'),
            (180, N'MERSİN ÇUKUROVA HAVALİMANI'),
            (181, N'GÖÇMEN KAÇAKÇILIĞIYLA MÜCADELE VE HUDUT KAPILARI DAİRE BAŞKANLIĞI'),
            (182, N'IĞDIR ALİCAN KARA HUDUT KAPISI');
        SET IDENTITY_INSERT [dbo].[E_Border] OFF;
        PRINT 'Tablo [dbo].[E_Border] icin 174 kayit eklendi.';
    END
END
GO

-- --------------------------------------------------------------------------
-- Veri: [dbo].[E_AUH]
-- --------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[E_AUH]', N'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dbo].[E_AUH])
    BEGIN
        SET IDENTITY_INSERT [dbo].[E_AUH] ON;
        INSERT INTO [dbo].[E_AUH] ([fldId], [fldCountry], [fldFirstMounth], [fldKat], [fldDayStart], [fldDayKat], [fldToM]) VALUES
            (1002, N'Rusya Federasyonu', N'7', N'1,5', N'3', N'0,3', N'USD'),
            (1005, N'Ukrayna', N'25', N'5', N'10', N'1', N'USD'),
            (1006, N'İsrail', N'14', N'3,5', N'5', N'0,5', N'USD'),
            (1007, N'İran', N'25', N'5', N'10', N'1', N'USD'),
            (2003, N'Finlandiya', N'25', N'5', N'10', N'1', N'USD'),
            (2004, N'Amerika Birleşik Devletleri', N'25', N'5', N'10', N'1', N'USD'),
            (2005, N'Afganistan', N'25', N'5', N'10', N'1', N'USD'),
            (2006, N'Almanya', N'25', N'5', N'10', N'1', N'USD'),
            (2007, N'Andora', N'25', N'5', N'10', N'1', N'USD'),
            (2008, N'Angola', N'25', N'5', N'10', N'1', N'USD'),
            (2009, N'Antigua ve Barbuda', N'25', N'5', N'10', N'1', N'USD'),
            (2010, N'Arjantin', N'25', N'5', N'10', N'1', N'USD'),
            (2011, N'Avustralya', N'25', N'5', N'10', N'1', N'USD'),
            (2012, N'Avusturya', N'25', N'5', N'10', N'1', N'USD'),
            (2013, N'Azerbaycan', N'25', N'5', N'10', N'1', N'USD'),
            (2014, N'Bahamalar', N'25', N'5', N'10', N'1', N'USD'),
            (2015, N'Bahreyn', N'25', N'5', N'10', N'1', N'USD'),
            (2016, N'Bangladeş', N'25', N'5', N'10', N'1', N'USD'),
            (2017, N'Barbados', N'25', N'5', N'10', N'1', N'USD'),
            (2018, N'Belize', N'25', N'5', N'10', N'1', N'USD'),
            (2019, N'Benin', N'25', N'5', N'10', N'1', N'USD'),
            (2020, N'Bhutan', N'25', N'5', N'10', N'1', N'USD'),
            (2021, N'Birleşik Arap Emirlikleri', N'25', N'5', N'10', N'1', N'USD'),
            (2022, N'Bolivya', N'25', N'5', N'10', N'1', N'USD'),
            (2023, N'Bosna Hersek', N'25', N'5', N'10', N'1', N'USD'),
            (2024, N'Botsvana', N'25', N'5', N'10', N'1', N'USD'),
            (2025, N'Brezilya', N'25', N'5', N'10', N'1', N'USD'),
            (2026, N'Brunei', N'25', N'5', N'10', N'1', N'USD'),
            (2027, N'Bulgaristan', N'25', N'5', N'10', N'1', N'USD'),
            (2028, N'Burkina Faso', N'25', N'5', N'10', N'1', N'USD'),
            (2029, N'Burundi', N'25', N'5', N'10', N'1', N'USD'),
            (2030, N'Cape Verde', N'25', N'5', N'10', N'1', N'USD'),
            (2031, N'Cibuti', N'25', N'5', N'10', N'1', N'USD'),
            (2032, N'Çad', N'25', N'5', N'10', N'1', N'USD'),
            (2033, N'Çin', N'25', N'5', N'10', N'1', N'USD'),
            (2034, N'Doğu Timor', N'25', N'5', N'10', N'1', N'USD'),
            (2035, N'Dominik Cumhuriyeti', N'25', N'5', N'10', N'1', N'USD'),
            (2036, N'Dominik', N'25', N'5', N'10', N'1', N'USD'),
            (2037, N'Kırgızistan', N'25', N'5', N'10', N'1', N'USD'),
            (2038, N'Kazakistan', N'25', N'5', N'10', N'1', N'USD'),
            (2039, N'Filipinler', N'14', N'3,5', N'5', N'0,5', N'USD'),
            (2040, N'Japonya', N'14', N'3,5', N'5', N'0,5', N'USD'),
            (2041, N'Kamboçya', N'14', N'3,5', N'5', N'0,5', N'USD'),
            (2042, N'Makedonya', N'14', N'3,5', N'5', N'0,5', N'USD'),
            (2043, N'Mali', N'14', N'3,5', N'5', N'0,5', N'USD'),
            (2044, N'Arnavutluk', N'14', N'3,5', N'5', N'0,5', N'USD'),
            (2045, N'Tacikistan', N'14', N'3,5', N'5', N'0,5', N'USD'),
            (2046, N'Ekvator', N'25', N'5', N'10', N'1', N'USD'),
            (2047, N'Ekvator Ginesi', N'25', N'5', N'10', N'1', N'USD'),
            (2048, N'El Salvador', N'25', N'5', N'10', N'1', N'USD'),
            (2049, N'Endonezya', N'25', N'5', N'10', N'1', N'USD'),
            (2050, N'Eritre', N'25', N'5', N'10', N'1', N'USD'),
            (2051, N'Ermenistan', N'25', N'5', N'10', N'1', N'USD'),
            (2052, N'Estonya', N'25', N'5', N'10', N'1', N'USD'),
            (2053, N'Filistin Bölgesi', N'25', N'5', N'10', N'1', N'USD'),
            (2054, N'Fransa', N'25', N'5', N'10', N'1', N'USD'),
            (2055, N'Gabon', N'25', N'5', N'10', N'1', N'USD'),
            (2057, N'Norveç', N'1680', N'939', N'275', N'46,10', N'TRY'),
            (2059, N'Danimarka', N'1854', N'0', N'1854', N'0', N'TRY'),
            (2060, N'Samoa', N'25', N'5', N'10', N'1', N'USD'),
            (2061, N'Gambia', N'25', N'5', N'10', N'1', N'USD'),
            (2062, N'Gine-Bissau', N'25', N'5', N'10', N'1', N'USD'),
            (2063, N'Granada', N'25', N'5', N'10', N'1', N'USD'),
            (2064, N'Guatemala', N'25', N'5', N'10', N'1', N'USD'),
            (2065, N'Guyana', N'25', N'5', N'10', N'1', N'USD'),
            (2066, N'Sudan', N'25', N'5', N'10', N'1', N'USD'),
            (2067, N'Haiti', N'25', N'5', N'10', N'1', N'USD'),
            (2068, N'Hindistan', N'25', N'5', N'10', N'1', N'USD'),
            (2069, N'Hollanda', N'25', N'5', N'10', N'1', N'USD'),
            (2070, N'Jamaika', N'25', N'5', N'10', N'1', N'USD'),
            (2071, N'Kamerun', N'25', N'5', N'10', N'1', N'USD'),
            (2072, N'Kanada', N'25', N'5', N'10', N'1', N'USD'),
            (2073, N'Kenya', N'25', N'5', N'10', N'1', N'USD'),
            (3060, N'Güney Afrika', N'25', N'5', N'10', N'1', N'USD'),
            (3061, N'Güney Kıbrıs Rum Kesimi', N'25', N'5', N'10', N'1', N'USD'),
            (3062, N'Gürcistan', N'25', N'5', N'10', N'1', N'USD'),
            (3063, N'Hırvatistan', N'25', N'5', N'10', N'1', N'USD'),
            (3064, N'Honduras', N'25', N'5', N'10', N'1', N'USD'),
            (3065, N'Birleşik Krallık', N'25', N'5', N'10', N'1', N'USD'),
            (3066, N'İsveç', N'25', N'5', N'10', N'1', N'USD'),
            (3067, N'İsviçre', N'25', N'5', N'10', N'1', N'USD'),
            (3068, N'İtalya', N'25', N'5', N'10', N'1', N'USD'),
            (3069, N'İzlanda', N'25', N'5', N'10', N'1', N'USD'),
            (3070, N'Katar', N'25', N'5', N'10', N'1', N'USD'),
            (3071, N'Kiribati', N'25', N'5', N'10', N'1', N'USD'),
            (3072, N'Kolombiya', N'25', N'5', N'10', N'1', N'USD'),
            (3073, N'Komorlar', N'25', N'5', N'10', N'1', N'USD'),
            (3074, N'Kongo', N'25', N'5', N'10', N'1', N'USD'),
            (3075, N'Kongo Demokratik Cumhuriyeti', N'25', N'5', N'10', N'1', N'USD'),
            (3076, N'Kosta Rika', N'25', N'5', N'10', N'1', N'USD'),
            (3077, N'Kuzey Kore', N'25', N'5', N'10', N'1', N'USD'),
            (3078, N'Küba', N'25', N'5', N'10', N'1', N'USD'),
            (3079, N'Laos', N'25', N'5', N'10', N'1', N'USD'),
            (3080, N'Lesotho', N'25', N'5', N'10', N'1', N'USD'),
            (3081, N'Letonya', N'25', N'5', N'10', N'1', N'USD'),
            (3082, N'Liberya', N'25', N'5', N'10', N'1', N'USD'),
            (3083, N'Liechtenstein', N'25', N'5', N'10', N'1', N'USD'),
            (3084, N'Litvanya', N'25', N'5', N'10', N'1', N'USD'),
            (3085, N'Lübnan', N'25', N'5', N'10', N'1', N'USD'),
            (3086, N'Macaristan', N'25', N'5', N'10', N'1', N'USD'),
            (3087, N'Madagaskar', N'25', N'5', N'10', N'1', N'USD'),
            (3088, N'Malavi', N'25', N'5', N'10', N'1', N'USD'),
            (3089, N'Maldivler', N'25', N'5', N'10', N'1', N'USD'),
            (3090, N'Malezya', N'25', N'5', N'10', N'1', N'USD'),
            (3091, N'Marshall Adaları', N'25', N'5', N'10', N'1', N'USD'),
            (3092, N'Meksika', N'25', N'5', N'10', N'1', N'USD'),
            (3093, N'Moğolistan', N'25', N'5', N'10', N'1', N'USD'),
            (3094, N'Moldovya Cumhuriyeti', N'25', N'5', N'10', N'1', N'USD'),
            (3095, N'Monako', N'25', N'5', N'10', N'1', N'USD'),
            (3096, N'Moritanya', N'25', N'5', N'10', N'1', N'USD'),
            (3097, N'Belçika', N'9', N'2,5', N'4', N'0,4', N'USD'),
            (3098, N'Suriye', N'1854', N'0', N'1854', N'0', N'TRY'),
            (3099, N'Irak', N'5', N'0,5', N'2', N'0,2', N'USD'),
            (3100, N'Mauritius', N'25', N'5', N'10', N'1', N'USD'),
            (3101, N'Mozambik', N'25', N'5', N'10', N'1', N'USD'),
            (3102, N'Myanmar', N'25', N'5', N'10', N'1', N'USD'),
            (3103, N'Nijer', N'25', N'5', N'10', N'1', N'USD'),
            (3104, N'Nijerya', N'25', N'5', N'10', N'1', N'USD'),
            (3105, N'Özbekistan', N'25', N'5', N'10', N'1', N'USD'),
            (3106, N'Pakistan', N'25', N'5', N'10', N'1', N'USD'),
            (3107, N'Paraguay', N'25', N'5', N'10', N'1', N'USD'),
            (3108, N'Peru', N'25', N'5', N'10', N'1', N'USD'),
            (3109, N'Polonya', N'25', N'5', N'10', N'1', N'USD'),
            (3110, N'Portekiz', N'25', N'5', N'10', N'1', N'USD'),
            (3111, N'Romanya', N'25', N'5', N'10', N'1', N'USD'),
            (3112, N'Senegal', N'25', N'5', N'10', N'1', N'USD'),
            (3113, N'Slovakya', N'25', N'5', N'10', N'1', N'USD'),
            (3114, N'Slovenya', N'25', N'5', N'10', N'1', N'USD'),
            (3115, N'Solomon Adaları', N'25', N'5', N'10', N'1', N'USD'),
            (3116, N'Somali', N'25', N'5', N'10', N'1', N'USD'),
            (3117, N'Suudi Arabistan', N'25', N'5', N'10', N'1', N'USD'),
            (3118, N'Şili', N'25', N'5', N'10', N'1', N'USD'),
            (3119, N'Tanzanya', N'25', N'5', N'10', N'1', N'USD'),
            (3120, N'Tayland', N'25', N'5', N'10', N'1', N'USD'),
            (3121, N'Uganda', N'25', N'5', N'10', N'1', N'USD'),
            (3122, N'Uruguay', N'25', N'5', N'10', N'1', N'USD'),
            (3123, N'Venezuela', N'25', N'5', N'10', N'1', N'USD'),
            (3124, N'Vietnam', N'25', N'5', N'10', N'1', N'USD'),
            (3125, N'Yemen', N'25', N'5', N'10', N'1', N'USD'),
            (3126, N'Yeni Zelanda', N'25', N'5', N'10', N'1', N'USD'),
            (3127, N'Yunanistan', N'25', N'5', N'10', N'1', N'USD'),
            (3128, N'İspanya', N'9', N'2,5', N'4', N'0,4', N'USD'),
            (3129, N'Malta', N'9', N'2,5', N'4', N'0,4', N'USD'),
            (3130, N'Beyaz Rusya', N'9', N'2,5', N'4', N'0,4', N'USD'),
            (3131, N'Kuveyt', N'9', N'2,5', N'4', N'0,4', N'USD'),
            (3132, N'Singapur', N'9', N'2,5', N'4', N'0,4', N'USD'),
            (3133, N'Tayvan', N'9', N'2,5', N'4', N'0,4', N'USD'),
            (3134, N'Cezayir', N'9', N'2,5', N'4', N'0,4', N'USD'),
            (3135, N'Lüksemburg', N'9', N'2,5', N'4', N'0,4', N'USD'),
            (3136, N'Ürdün', N'9', N'2,5', N'4', N'0,4', N'USD'),
            (3137, N'Hong Kong SAR - Çin', N'7', N'1,5', N'3', N'0,3', N'USD'),
            (3138, N'Etiyopya', N'7', N'1,5', N'3', N'0,3', N'USD'),
            (3139, N'Güney Kore', N'7', N'1,5', N'3', N'0,3', N'USD'),
            (3140, N'Fas', N'5', N'0,5', N'2', N'0,2', N'USD'),
            (3141, N'Karadağ', N'5', N'0,5', N'2', N'0,2', N'USD'),
            (3142, N'Mısır', N'5', N'0,5', N'2', N'0,2', N'USD'),
            (3143, N'Tunus', N'5', N'0,5', N'2', N'0,2', N'USD'),
            (3144, N'Nepal', N'1854', N'0', N'1854', N'0', N'TRY'),
            (3145, N'Sri Lanka', N'1854', N'0', N'1854', N'0', N'TRY'),
            (3146, N'İrlanda', N'1854', N'0', N'1854', N'0', N'TRY'),
            (3147, N'Türkmenistan', N'1854', N'0', N'1854', N'0', N'TRY'),
            (3148, N'Zambiya', N'25', N'5', N'10', N'1', N'USD'),
            (3149, N'Vatikan', N'25', N'5', N'10', N'1', N'USD'),
            (3150, N'Vanuatu', N'25', N'5', N'10', N'1', N'USD'),
            (3151, N'Libya', N'25', N'5', N'10', N'1', N'USD'),
            (3152, N'Umman', N'25', N'5', N'10', N'1', N'USD'),
            (3153, N'Gana', N'25', N'5', N'10', N'1', N'USD'),
            (3154, N'Gine', N'25', N'5', N'10', N'1', N'USD'),
            (3155, N'Nikaragua', N'25', N'5', N'10', N'1', N'USD'),
            (3156, N'Çek Cumhuriyeti', N'1854', N'0', N'1854', N'0', N'TRY'),
            (3157, N'Namibya', N'25', N'5', N'10', N'1', N'USD'),
            (3158, N'Nauru', N'25', N'5', N'10', N'1', N'USD'),
            (3159, N'Orta Afrika Cumhuriyeti', N'25', N'5', N'10', N'1', N'USD'),
            (3160, N'Panama', N'25', N'5', N'10', N'1', N'USD'),
            (3161, N'Saint Kitts ve Nevis', N'25', N'5', N'10', N'1', N'USD'),
            (3162, N'San Marino', N'25', N'5', N'10', N'1', N'USD'),
            (3163, N'Seyşeller', N'25', N'5', N'10', N'1', N'USD'),
            (3164, N'Trinidad ve Tobago', N'25', N'5', N'10', N'1', N'USD'),
            (3165, N'Palau', N'25', N'5', N'10', N'1', N'USD'),
            (3166, N'Papua Yeni Gine', N'25', N'5', N'10', N'1', N'USD'),
            (3167, N'Ruanda', N'25', N'5', N'10', N'1', N'USD'),
            (3168, N'Saint Lucia', N'25', N'5', N'10', N'1', N'USD'),
            (3169, N'Saint Vincent ve Grenadinler', N'25', N'5', N'10', N'1', N'USD'),
            (3170, N'Sao Tome ve Principe', N'25', N'5', N'10', N'1', N'USD'),
            (3171, N'Sierra Leone', N'25', N'5', N'10', N'1', N'USD'),
            (3172, N'Sırbistan', N'1413', N'939', N'275', N'46,10', N'TRY'),
            (3173, N'Fiji', N'1413', N'939', N'275', N'46,10', N'TRY'),
            (3174, N'Kuzey Mariana Adaları', N'1413', N'939', N'275', N'46,10', N'TRY'),
            (3175, N'Fildişi Sahilleri', N'5', N'0,5', N'2', N'0,2', N'USD'),
            (3176, N'Togo', N'25', N'5', N'10', N'1', N'USD'),
            (3177, N'Tonga', N'25', N'5', N'10', N'1', N'USD'),
            (3178, N'Tuvalu', N'25', N'5', N'10', N'1', N'USD'),
            (3180, N'Kosova', N'1854', N'0', N'1854', N'0', N'TRY');
        SET IDENTITY_INSERT [dbo].[E_AUH] OFF;
        PRINT 'Tablo [dbo].[E_AUH] icin 193 kayit eklendi.';
    END
END
GO

-- --------------------------------------------------------------------------
-- Veri: [dbo].[E_TKOD]
-- --------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[E_TKOD]', N'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dbo].[E_TKOD])
    BEGIN
        SET IDENTITY_INSERT [dbo].[E_TKOD] ON;
        INSERT INTO [dbo].[E_TKOD] ([fldId], [fldCode], [fldPTime], [fldStart], [fldFinish], [fldIdariCode], [fldPaid]) VALUES
            (1, N'-', N'0', 1, 10, N'N-120', N'0'),
            (86, N'--', N'YOK', 1, 10, N'N-120 + N-96', N'0'),
            (3, N'Ç-101', N'90', 11, 89, N'N-120', N'0'),
            (5, N'Ç-102', N'180', 90, 179, N'N-120', N'0'),
            (6, N'Ç-103', N'365', 180, 364, N'N-120', N'0'),
            (8, N'Ç-104', N'730', 365, 729, N'N-120', N'0'),
            (10, N'Ç-105', N'1825', 730, 999999, N'N-120', N'0'),
            (2, N'-', N'0', 1, 89, N'YOK', N'1'),
            (4, N'Ç-101', N'90', 90, 179, N'YOK', N'1'),
            (134, N'Ç-102', N'180', 180, 364, N'YOK', N'1'),
            (7, N'Ç-103', N'365', 365, 729, N'YOK', N'1'),
            (9, N'Ç-104', N'730', 730, 1094, N'YOK', N'1'),
            (11, N'Ç-105', N'1825', 1095, 999999, N'YOK', N'1'),
            (17, N'Ç -101 (V-84 e BAĞLI)', N'90', 1, 89, N'YOK', N'2'),
            (19, N'Ç-102 ( V-84  e BAĞLI)', N'180', 90, 179, N'YOK', N'2'),
            (21, N'Ç-103 ( V-84  e BAĞLI)', N'365', 180, 364, N'YOK', N'2'),
            (23, N'Ç-104  (V-84  e BAĞLI)', N'730', 365, 729, N'YOK', N'2'),
            (25, N'Ç-105  (V-84  e BAĞLI)', N'1825', 730, 999999, N'YOK', N'2'),
            (18, N'Ç-101 (V-84 e BAĞLI)', N'90', 1, 89, N'N-120', N'3'),
            (20, N'Ç-102 ( V-84  e BAĞLI)', N'180', 90, 179, N'N-120', N'3'),
            (22, N'Ç-103 ( V-84  e BAĞLI)', N'365', 180, 364, N'N-120', N'3'),
            (24, N'Ç-104  (V-84  e BAĞLI)', N'730', 365, 729, N'N-120', N'3'),
            (26, N'Ç-105  (V-84 e BAĞLI)', N'1825', 730, 9999999, N'N-120', N'3'),
            (85, N'--', N'0', 1, 10, N'YOK', N'4'),
            (110, N'Ç-101 (V-137 Bağlı)', N'90', 11, 89, N'YOK', N'4'),
            (90, N'Ç-102 (V-137''ye bağlı)', N'180', 90, 179, N'YOK', N'4'),
            (92, N'Ç-103 (V-137''ye bağlı)', N'365', 180, 364, N'YOK', N'4'),
            (96, N'Ç-104 (V-137 BAĞLI)', N'730', 365, 729, N'YOK', N'4'),
            (97, N'Ç-105 (V-137 BAĞLI)', N'1825', 730, 999999, N'YOK', N'4'),
            (93, N'---', N'0', 1, 10, N'N-120', N'5'),
            (87, N'Ç-101 (V-137 BAĞLI)', N'90', 11, 89, N'N-120 ', N'5'),
            (88, N'Ç-102 (V-137''ye bağlı)', N'180', 90, 179, N'N-120 + N-96', N'5'),
            (91, N'Ç-103 (V-137''ye bağlı)', N'365', 180, 364, N'N-120 + N-96', N'5'),
            (95, N'Ç-104 (V-137 BAĞLI)', N'730', 365, 729, N'N-120 + N-96', N'5'),
            (98, N'Ç-105 (V-137 BAĞLI)', N'1825', 730, 999999, N'N-120 + N-96', N'5'),
            (101, N'-', N'0', 1, 10, N'YOK', N'6'),
            (99, N'Ç -101 (V-157 BAGLI)', N'90', 11, 89, N'YOK', N'6'),
            (32, N'Ç-102 (V-157 ye Bağlı)', N'180', 90, 179, N'YOK', N'6'),
            (34, N'Ç-103 (V-157 ye Bağlı)', N'365', 180, 364, N'YOK', N'6'),
            (36, N'Ç-104 (V-157 ye Bağlı)', N'730', 365, 729, N'YOKTUR', N'6'),
            (38, N'Ç-105 (V-157 ye Bağlı)', N'1825', 730, 999999, N'YOK', N'6'),
            (102, N'-', N'0', 1, 10, N'N-120', N'7'),
            (100, N'Ç -101 (V-157 BAĞLI)', N'90', 11, 89, N'N-120', N'7'),
            (33, N'Ç-102(V-157 ye Bağlı)', N'180', 90, 179, N'N-120', N'7'),
            (35, N'Ç-103 (V-157 ye Bağlı)', N'365', 180, 364, N'N-120', N'7'),
            (37, N'Ç-104 (V-157 ye Bağlı)', N'730', 365, 729, N'N-120', N'7'),
            (39, N'Ç-105 (V-157 ye Bağlı)', N'1825', 730, 999999, N'N-120', N'7'),
            (105, N'-', N'0', 1, 10, N'YOK', N'8'),
            (106, N'Ç-101 (V-69 BAGLI)', N'90', 11, 89, N'YOK', N'8'),
            (120, N'Ç-101 (V-69''a Bağlı)', N'90', 11, 89, N'YOK', N'8'),
            (109, N'Ç-102 (V-69 a Bağlı)', N'180', 90, 179, N'YOK', N'8'),
            (44, N'Ç-103 (V-69 a Bağlı)', N'365', 180, 364, N'YOK', N'8'),
            (46, N'Ç-104 (V-69 a Bağlı)', N'730', 365, 729, N'YOK', N'8'),
            (48, N'Ç-105 (V-69 a Bağlı)', N'1825', 730, 999999, N'YOK', N'8'),
            (104, N'-', N'0', 1, 10, N'N-120', N'9'),
            (41, N'Ç-101 (V-69 a Bağlı)', N'90', 11, 89, N'N-120', N'9'),
            (43, N'Ç-102 (V-69 a Bağlı)', N'180', 90, 179, N'N-120', N'9'),
            (45, N'Ç-103 (V-69 a Bağlı)', N'365', 180, 364, N'N-120', N'9'),
            (47, N'Ç-104 (V-69 a Bağlı)', N'730', 365, 729, N'N-120', N'9'),
            (49, N'Ç-105 (V-69 a Bağlı)', N'1825', 730, 999999, N'N-120', N'9'),
            (135, N'-', N'0', 1, 10, N'YOK', N'10'),
            (50, N'Ç-101 (V-88 e Bağlı)', N'90', 11, 89, N'YOK', N'10'),
            (52, N'Ç-102 (V-88 e Bağlı)', N'180', 90, 179, N'YOK', N'10'),
            (54, N'Ç-103 (V-88 e Bağlı)', N'365', 180, 364, N'YOK', N'10'),
            (56, N'Ç-104 (V-88 e Bağlı)', N'730', 365, 729, N'YOK', N'10'),
            (58, N'Ç-105 (V-88 e Bağlı)', N'1825', 730, 999999, N'YOK', N'10'),
            (136, N'-', N'0', 1, 10, N'N-120', N'11'),
            (51, N'Ç-101(V-88 e Bağlı)', N'90', 11, 89, N'N-120', N'11'),
            (53, N'Ç-102 (V-88 e Bağlı)', N'180', 90, 179, N'N-120', N'11'),
            (55, N'Ç-103 (V-88 e Bağlı)', N'365', 180, 364, N'N-120', N'11'),
            (57, N'Ç-104 (V-88 e Bağlı)', N'730', 365, 729, N'N-120', N'11'),
            (59, N'Ç-105 (V-88 e Bağlı)', N'1825', 730, 999999, N'N-120', N'11'),
            (117, N'-', N'YOK', 1, 10, N'YOK', N'12'),
            (118, N'-', N'0', 1, 10, N'YOK', N'14'),
            (133, N'Ç-101 (İkamet Teskereli V-157''ye Bağlı)', N'90', 11, 89, N'YOK', N'14'),
            (123, N'Ç-102 (İkamet Teskereli  V-157''ye Bağlı)', N'180', 90, 179, N'YOK', N'14'),
            (125, N'Ç-103 (İkamet Teskereli  V-157''ye Bağlı)', N'365', 180, 364, N'YOK', N'14'),
            (127, N'Ç-104 (İkamet Teskereli V-157''ye Bağlı)', N'730', 365, 729, N'YOK', N'14'),
            (129, N'Ç-105 (İkamet Teskereli V-157''ye Bağlı)', N'1825', 730, 999999, N'YOK', N'14'),
            (119, N'-', N'0', 1, 10, N'N-120', N'15'),
            (122, N'Ç-101 (İkamet Teskereli V-157''ye Bağlı)', N'90', 11, 89, N'N-120', N'15'),
            (132, N'Ç-102 (İkamet Teskereli V-157''ye Bağlı)', N'180', 90, 179, N'N-120', N'15'),
            (126, N'Ç-103 (İkamet Teskereli  V-157''ye Bağlı)', N'365', 180, 364, N'N-120', N'15'),
            (128, N'Ç-104 ( İkamet Teskereli V-157''ye Bağlı)', N'730', 365, 729, N'N-120', N'15'),
            (130, N'Ç-105 (İkamet Teskereli V-157''ye Bağlı)', N'1825', 730, 99999, N'N-120', N'15');
        SET IDENTITY_INSERT [dbo].[E_TKOD] OFF;
        PRINT 'Tablo [dbo].[E_TKOD] icin 85 kayit eklendi.';
    END
END
GO

-- --------------------------------------------------------------------------
-- Veri: [dbo].[TahditKod]
-- --------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[TahditKod]', N'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dbo].[TahditKod])
    BEGIN
        SET IDENTITY_INSERT [dbo].[TahditKod] ON;
        INSERT INTO [dbo].[TahditKod] ([Id], [Kod], [Aciklama], [SureAy], [Aktif], [GirisGelirse], [CikisGelirse], [TahditMedia], [CreatedAt], [CreatedByUserId], [CreatedBySicil], [CreatedByName]) VALUES
            (115, N'ççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççç', N'çççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççç', 0, 0, N'çççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççç', N'çççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççç', N'<p>çççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççççç<img src="/Uploads/Tahdit/Summernote/20260423204813_Ekran görüntüsü 2026-04-22 194156.png" style="width: 669px;"></p>', NULL, NULL, NULL, NULL),
            (116, N'Ç-101', N'3 AY GİRİŞ YASAĞI', 3, 1, N'GİREMEZ KONSOLUSLUK VİZESİ GEREKİR.', N'GİRİŞİNİN LEGAL OLUP OLMADIĞI KONTROL EDİLİR', N'', NULL, NULL, NULL, NULL);
        SET IDENTITY_INSERT [dbo].[TahditKod] OFF;
        PRINT 'Tablo [dbo].[TahditKod] icin 2 kayit eklendi.';
    END
END
GO

-- --------------------------------------------------------------------------
-- Veri: [dbo].[E_Defter]
-- --------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[E_Defter]', N'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dbo].[E_Defter])
    BEGIN
        SET IDENTITY_INSERT [dbo].[E_Defter] ON;
        INSERT INTO [dbo].[E_Defter] ([fldId], [fldPrice], [fldTypeofMoney]) VALUES
            (1, N'964', N'TRY');
        SET IDENTITY_INSERT [dbo].[E_Defter] OFF;
        PRINT 'Tablo [dbo].[E_Defter] icin 1 kayit eklendi.';
    END
END
GO

-- --------------------------------------------------------------------------
-- Veri: [dbo].[E_Exchange]
-- --------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[E_Exchange]', N'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dbo].[E_Exchange])
    BEGIN
        SET IDENTITY_INSERT [dbo].[E_Exchange] ON;
        INSERT INTO [dbo].[E_Exchange] ([fldId], [fldEuro], [fldDollar], [fldPaund]) VALUES
            (1, N'51,90', N'44,55', N'58,95');
        SET IDENTITY_INSERT [dbo].[E_Exchange] OFF;
        PRINT 'Tablo [dbo].[E_Exchange] icin 1 kayit eklendi.';
    END
END
GO

-- --------------------------------------------------------------------------
-- Veri: [dbo].[E_Forms]
-- --------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[E_Forms]', N'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dbo].[E_Forms])
    BEGIN
        SET IDENTITY_INSERT [dbo].[E_Forms] ON;
        INSERT INTO [dbo].[E_Forms] ([fldId], [fldGB], [fldDE], [fldRU], [fldIR], [fldGBC], [fldDEC], [fldRUC], [fldIRC], [fldIRKC], [fldIRK], [fldFransizca], [fldFransizcaC]) VALUES
            (1, N'<h3 align="center">VİZE İHLALİ İŞLEM FORMU /VISA VIOLATION FORM</h3>
<table width="400" border="0">
  <tbody>
    <tr>
      <td>Adı Soyadı /Name/Surname</td>
      <td>{{NAME}}<br></td>
    </tr>
    <tr>
      <td>Uyruğu / Nationality</td>
      <td>{{ORGIN}}</td>
    </tr>
    <tr>
      <td>Pasaport No / Passport No</td>
      <td>{{PASSPORT}}</td>
    </tr>
  </tbody>
</table>
<span style="font-size: 14px"><br>
</span>
<table width="800" border="0">
  <tbody>
    <tr>
      <td colspan="2" style="font-size: 12px">
*  Ülkemize Giriş Tarihiniz ve Vize süreniz  Date of entry into country / Notification Date and visa validity</td>
      <td style="font-size: 16px"><strong>{{EDATE}}</strong></td>
      <td><table width="100%" border="0">
        <tbody>
          <tr>
            <td width="8%"><strong>{{VDAY}}</strong></td>
            <td width="9%"><strong>&nbsp;Day(s)</strong></td>
          </tr>
        </tbody>
      </table></td>
    </tr>
    <tr>
      <td colspan="2" style="font-size: 12px"><table width="100%" border="0">
        <tbody>
          <tr>
            <td>*&nbsp;&nbsp;Ülkemizden çıkış için müracaat tarihiniz/ The date that you are applying to leave the country</td>
            <td>:</td>

          </tr>
        </tbody>
      </table></td>
      <td style="font-size: 16px"><strong>{{TODAY}}</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size: 12px">*&nbsp;&nbsp;Ülkemizden çıkış yapmanız gereken tarih/ The date that you were meant to leave the country</td>
      <td style="font-size: 12px">:</td>
      <td style="font-size: 16px"><strong>{{SEDATE}}</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size: 12px">*&nbsp;&nbsp;Ülkemize giriş yapabileceğiniz tarih/&nbsp;(Giriş yasağınızın otomatik olarak iptal edileceği tarih) / &nbsp;&nbsp;&nbsp; The date on which the ban on entry will be automatically canceled&nbsp;</td>
      <td style="font-size: 12px">:</td>
      <td style="font-size: 16px"><strong>{{CANENT}}</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size: 12px">*&nbsp;Tebliğ Edilen, Tahdit Çıkış&nbsp; veya İkamet Teskere Bitiş Tarihi / End date of notified or limitation date or residence permit</td>
      <td style="font-size: 12px">:</td>
      <td style="font-size: 16px"><strong>{{SEDATE}}</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size: 12px">*&nbsp;&nbsp;Vize ihlal süreniz / Visa violation period</td>
      <td style="font-size: 12px">:</td>
      <td style="font-size: 16px"><strong>{{FINETIME}}</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size: 12px">*&nbsp;&nbsp;Vize ihlali için ödenecek ücret / Penalty for visa violation</td>
      <td style="font-size: 12px">:</td>
      <td style="font-size: 16px"><strong>{{FINET}}</strong></td><td style="font-size: 16px"><span style="font-size: 13px; font-weight: 700 !important;"><font size="2">TL</font></span><br></td></tr></tbody></table>
<span style="font-size: 14px"><br>
</span>
<table width="800" border="0">
  <tbody>
    <tr>
      <td style="font-size: 12px"><p>Sayın&nbsp;<span style="color: rgb(0, 0, 0); font-size: 13px;">{{NAME}}</span>&nbsp;Ülkemizdeki yasal kalış sürenizi ihlal etmiş bulunmaktasınız.{{S}}Vize ihlal ücretini ödemediğiniz için hakkınızda ülkemize&nbsp;<strong>{{FINEDAY}}&nbsp;</strong>Gün giriş yasağı uygulanacaktır.&nbsp; Hakkınızda girilecek&nbsp;Tahdit kodu {{TCODE}}{{F}}</p>
       
      <hr>
      <table width="800" border="0">
  <tbody>
    <tr>
      <td> Dear Madame/Sir&nbsp;<span style="font-size: 13px;">{{NAME}}</span>&nbsp;You have overstayed your visa.{{S1}} As you have not paid the relevant fine, a  ban on your re-entering Turkey will be put into practise{{FINEDAY}}  Entry Ban Code {{TCODE}}{{F1}}</td>
    </tr>
  </tbody>
</table>

      </td>
    </tr>
  </tbody>
</table>
<span style="font-size: 14px"><br>
</span>
<table align="center" width="400" border="0">
  <tbody>
    <tr>
      <td>Düzenleme Tarihi / Dated On:</td>
      <td><strong>{{TODAY}}</strong></td>
    </tr>
  </tbody>
</table>
<span style="font-size: 14px"><br>
</span>
<table width="800" border="0">
  <tbody>
    <tr align="center">
      <td>Yolcu İmzası</td>
      <td>Pasaport Kontrol Polisi</td>
    </tr>
    <tr align="center">
      <td>Signature of passenger</td>
      <td>Passport police officer</td>
    </tr>
    <tr align="center">
      <td><strong>&nbsp;{{NAME}}</strong></td>
      <td><strong>{{POLICE}}</strong></td>
    </tr>
  </tbody>
</table>
<span style="font-size: 14px"><br>
</span>
<table width="800" border="0">
  <tbody>
    <tr>
      <td>Formu okudum, imzaladım ve kopyasını aldım / I have read the form, signed it,and have a copy of the form</td>
    </tr>
  </tbody>
</table>
<span style="font-size: 14px"><br>
</span>
<table width="800" border="0">
  <tbody>
    <tr align="center">
      <td><strong>O N A Y</strong></td>
    </tr>
    <tr align="center">
      <td>APPROVAL</td>
    </tr>
    <tr align="center">
      <td>{{USER}}</td>
    </tr>
  </tbody>
</table>
<span style="font-size: 14px"><br>
</span>
<table width="800" border="0">
  <tbody>
  <tr>
						<th scope="col" style="width:10"><span style="font-size:10px">1</span></th>
						<td style="text-align:left"><span style="font-size:10px">İkamet Harçları 492 sayılı Harçlar kanununun 6 sayılı tarifesine göre her yıl Maliye Bakanlığınca Belirlenmektedir./</span><span style="font-size: 10px;">Residence Fees are determined by the Ministry of Finance every year according to the tariff no. 6 of the Fees Law No. 492.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:10"><span style="font-size:10px">2</span></th>
						<td style="text-align:left"><span style="font-size:10px">Hakkınızda konulmuşsa, konulan ülkemize giriş yasağının kaldırılması için Türkiye Cumhuriyeti dış temsilciliklerine özel amaçlı vize için müracaat ediniz./</span><span style="font-size: 10px;">If it has been placed about you, apply for a special purpose visa to the foreign representatives of the Republic of Turkey in order to lift the ban on entry to our country.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">3</span></th>
						<td style="text-align:left"><span style="font-size:10px">Vize ihlali nedeniyle hakkınızda uygulanan "N" veya "Ç" tahdit kodlarıyla ilgili , 60(altmış) gün içerisinde İdare mahkemesine başvuru yapmanız gerekmektedir./</span><span style="font-size: 10px;">You must apply to the Administrative Court within 60 (sixty) days regarding the "N" or "C" restriction codes applied to you due to visa violation.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">4</span></th>
						<td style="text-align:left"><span style="font-size:10px">Tahdit iş ve işlemler ile ilgili uygulamalar Göç İdaresi Genel Müdürlüğü''nün 22/07/2020 tarih ve 2020/17 sayılı genelgeye istinaden yapılmaktadır./</span><span style="font-size: 10px;">Applications related to the restriction works and transactions are made in accordance with the circular numbered 2020/17 dated 22/07/2020 of the General Directorate of Migration Management.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">5</span></th>
						<td style="text-align:left"><span style="font-size:10px">Vize ihlalinde bulunan yolcularla ilgili yurda giriş yasaklarına ilişkin uygulama 2020/17 sayılı genelgenin Madde 6''nın "A" ve "B" bendlerine istinaden uygulanır./</span><span style="font-size: 10px;">Implementation of bans on entry to the dormitory for passengers violating a visa is applied pursuant to subparagraphs "A" and "B" of Article 6 of the circular numbered 2020/17.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">6</span></th>
						<td style="text-align:left"><span style="font-size:10px">6458 Sayılı Yabancılar ve Uluslararası Koruma Kanununun "9","15","102" Maddeleri./</span><span style="font-size: 10px;">Articles "9","15","102" of the Foreigners and International Protection Law No. 6458</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">7</span></th>
						<td style="text-align:left"><span style="font-size:10px">17/03/2016 tarihli ve 29656 sayılı Yabancılar ve Uluslararası Koruma Kanununun Uygulamasına İlişkin Yönetmeliğin 8. ve 9. Maddeleri./</span><span style="font-size: 10px;">Articles 8 and 9 of the Regulation on the Implementation of the Law on Foreigners and International Protection dated 17/03/2016 and numbered 29656</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">8</span></th>
						<td style="text-align:left"><span style="font-size:10px">Göç İdaresi Başkanlığı''nın 06.01.2022 tarih ve V-157 İdari Takip Kodu Görüş Talebi Konulu Yazısı.</span><span style="font-size: 10px;">Letter of the Directorate of Migration Management, dated 06.01.2022, on V-157 Administrative Tracking Code, Request for Opinion</span></td>
					</tr>
  </tbody>
</table>

<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>


<p align="center"><img src="../img/goc.jpg" width="200" height="95" class="note-float-left" style="float: left;"></p>

<table width="800" border="0" align="center">
  <tbody>
    <tr align="center">
      <td>İdari Para Cezalarına İlişkin N Kodlu Ön İzin Kararı Tebliğ Formu<br>
      Notification Form for Code N Preliminary Permission Decision Regarding Administrative Fines</td>
    </tr>
  </tbody>
  
</table>

<table width="800" border="0">
  <tbody>
    <tr>
      <td align="center"><strong style="font-size: 14px">Yabancıya İlişkin Bilgiler&nbsp;–&nbsp;Information on the Foreigner</strong></td>
    </tr>
  </tbody>
</table>

<table width="800" border="1">
  <tbody>
    <tr>
      <td style="font-size: 12px">Adı –&nbsp;Name</td>
      <td style="font-size: 12px"><strong>{{FIRSTNAME}}</strong></td>
    </tr>
    <tr>
      <td style="font-size: 12px">Soyadı –&nbsp;Surname</td>
      <td style="font-size: 12px"><strong>{{LASTNAME}}</strong></td>
    </tr>
    <tr>
      <td style="font-size: 12px">Baba Adı –&nbsp;Father’s Name</td>
      <td style="font-size: 12px"><strong>{{FATHERNAME}}</strong></td>
    </tr>
    <tr>
      <td style="font-size: 12px">Anne Adı –&nbsp;Mother’s Name</td>
      <td style="font-size: 12px"><strong>{{MOTHERNAME}}</strong></td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <td>Doğum Tarihi –&nbsp;Date of Birth</td>
      <td><strong>{{BIRTHDATE}}</strong></td>
      <td>Uyruğu –&nbsp;Nationality</td>
      <td><strong>{{ORGIN}}</strong></td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <td>İletişim Dili –&nbsp;Communication Language</td>
      <td><strong>{{ORGIN}}</strong></td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <td>Karar ve Değerlendirmeye İlişkin Bilgiler –&nbsp;Information about the Decision and Evaluation</td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th width="518" rowspan="2" scope="col">Giriş Yasağı Kararı Başlangıç-Bitiş Tarihi –&nbsp;Start Date of Entry Ban Decision</th>
      <th width="53" scope="col">1-</th>
      <th width="207" scope="col">{{TODAY}}</th>
    </tr>
    <tr>
      <th scope="col">2-</th>
      <th scope="col">&nbsp;</th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="font-size: 12px" scope="col">* Bu alana giriş yasağı kararının başlangıç tarihi yazılacaktır.</th>
      <th style="font-size: 12px" scope="col">Enter start date of entry ban decision to this field</th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="font-size: 12px" scope="col">** Bu alana giriş yasağı kararının bitiş tarihi yazılacaktır.</th>
      <th style="font-size: 12px" scope="col">Enter end date of entry ban decision to this field.</th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 12px;"><li style="text-align:center"><strong>Ön İzin Kararı –&nbsp;Preliminary Permission Decision</strong></li>
        <li><strong>6458 sayılı Yabancılar ve Uluslararası Koruma Kanunun 9 uncu maddesi uyarınca gerçekleştirilen değerlendirme neticesinde,&nbsp;<a name="_Hlk43629860">………….</a>&nbsp;Valiliği (İl Göç İdaresi Müdürlüğü) tarafından hakkınızda ön izin kararı alınmıştır. –&nbsp;<em>As a result of the evaluation conducted in accordance with the Article 9 of the Law on Foreigners and International Protection numbered 6458, Governorship of&nbsp;</em>………….<em>&nbsp;(Provincial Directorate of Migration Management) has resolved to adopt a preliminary permission decision against you.</em></strong></li><em>
        <li><strong>
        Hakkınızda ön izin kararı alınmasına dayanak teşkil eden husus/hususlar sebebiyle; -&nbsp;<a name="_Hlk43632705"><em>Based on the particular/particulars constituting grounds for adopting a preliminary permission decision against you;</em></a>&nbsp;</strong></li>
        <li><strong>&nbsp;İkamet izninizin iptali için gerekli işlemler başlatılacaktır. -&nbsp;<a name="_Hlk43632761"><em>Respective procedures will be commenced for cancelling your residence permit.</em></a>&nbsp;</strong></li>
        <li><strong>Çalışma izninizin iptali için gerekli işlemler başlatılacaktır. -&nbsp;<em>Respective procedures will be commenced for cancelling your work permit.</em></strong></li>
        <li><strong><u>İdari para cezanızı ödememeniz nedeni ile hakkınızda alınan ön izin kararı, idari para cezasının ödendiğine ilişkin makbuzun idareye tebliğ edilmesi halinde kaldırılır ve&nbsp;</u>girişinize engel olacak başka bir hususun bulunmaması kaydıyla<u>&nbsp;Türkiye’ye girişinize izin verilir.</u>&nbsp;</strong></li>
        <li><strong><em>&nbsp;<u>The preliminary permission decision adopted against you on the grounds of non-payment of the administrative fine imposed on you will be rescinded provided that the receipt of payment of the respective administrative fine is submitted to the directorate</u>, and&nbsp;<u>the permission of entry to Turkey</u>&nbsp;will be granted to you on condition that no other particulars barring you from entering Turkey are determined.</em></strong></li>
        <li style="text-align:center"><strong>Ön İzin Kararına Karşı Yargı Yoluna Başvuru –&nbsp;<a name="_Hlk43633474">Resort to the Jurisdiction Against the Preliminary Permission Decision</a>&nbsp;</strong></li>
        <li><strong>Şahsınız veya yasal temsilciniz ya da avukatınız tarafından, ön izin kararına karşı, kararın tebliğinden itibaren 60 (altmış) gün içinde idare mahkemesine başvurulabilir. –&nbsp;<a name="_Hlk43633494"><em>You or your legal representative or lawyer may appeal against the preliminary permission decision to the Administrative Court within 60 (sixty) days from the notification of the decision.</em></a></strong></li>
        <li><strong>Mahkemeye başvuran kişi, ön izin kararı veren makama da başvurusunu bildirir. –&nbsp;<a name="_Hlk43633548"><em>The applicant who applied to the Court also notifies the authority of the preliminary permission decision.</em></a></strong></li>
        <li><strong>Mahkemeye yapılan başvurular ön izin kararını durdurmaz. –&nbsp;<a name="_Hlk43633568"><em>Applications made to the Court does not suspend the preliminary permission decision.</em></a></strong></li>
        <strong>
        
      </strong></em></th>
    </tr>
  </tbody>
</table>




<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align:justify; font-size:12px">Bu belge, bir nüshası avukatına/yabancıya/yasal temsilcisine verilmek üzere iki nüsha olarak hazırlanmış olup, hakkında sınır dışı etme kararı alınan yukarıda açık kimliği yazılı yabancıya kendi dilinde/anladığı dilde,&nbsp;<a name="_Hlk43631423"><em>{{TODAY}}&nbsp;&nbsp;</em></a>tarihinde ve&nbsp;&nbsp;<a name="_Hlk43631423"><em>{{TOTIME}}&nbsp;</em></a>saatinde yazılı olarak tebliğ edilmiş ve imza altına alınarak bir sureti tebellüğ edene verilmiştir. –&nbsp;<a name="_Hlk43633584"><em>This document has been issued in duplicate so a copy can be given to the lawyer/foreigner/legal representative and the foreigner, whose open identity is given above and upon whom the deportation decision has been imposed, has been notified in writing in his own language/language of comprehension on&nbsp;&nbsp;</em></a><a name="_Hlk43631423"><em>{{TODAY}}&nbsp;</em></a><a name="_Hlk43633584"><em>at&nbsp;</em></a><a name="_Hlk43631423"><em>{{TOTIME}}</em></a><em>&nbsp;and one copy has been given to the notified with a signature.</em></th>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="0" align="center">
  <tbody>
    <tr align="center">
      <th scope="col"><strong>Tebliğ Eden</strong></th>
      <th scope="col"><strong>Tebellüğ Eden</strong></th>
    </tr>
    <tr align="center">
      <th scope="row"><strong>Notifying Party</strong></th>
      <td scope="col"><strong>Notified</strong></td>
    </tr>
    <tr align="center">
      <th scope="row"><strong>{{USER}}</strong></th>
      <td><strong>{{NAME}}</strong></td>
    </tr>
  </tbody>
</table>
<p>&nbsp;</p>

<p align="center"><span style="text-align: left;"><br>{{ÇS}}</span><br></p>


<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>

<p align="center"><img src="../img/goc.jpg" width="200" height="95" class="note-float-left" style="float: left;"></p>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th> Ç Kodlu Giriş Yasağı Kararı Tebliğ Formu / Code Ç – Entry Ban Notification Form</th>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th scope="col">Yabancıya İlişkin Bilgiler – Information on the Foreigner</th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><strong>Adı –&nbsp;</strong>Name</th>
      <th scope="col">{{FIRSTNAME}}</th>
    </tr>
    <tr>
      <th scope="row"><strong>Soyadı –&nbsp;</strong>Surname</th>
      <td>{{LASTNAME}}</td>
    </tr>
    <tr>
      <th scope="row"><strong>Baba Adı –&nbsp;</strong>Father’s Name</th>
      <td>{{FATHERNAME}}</td>
    </tr>
    <tr>
      <th scope="row"><strong>Anne Adı –&nbsp;</strong>Mother’s Name</th>
      <td>{{MOTHERNAME}}</td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><strong>Doğum Tarihi –&nbsp;</strong>Date of Birth</th>
      <th scope="col">{{BIRTHDATE}}</th>
      <th scope="col"><strong>Uyruğu –&nbsp;</strong>Nationality</th>
      <th scope="col">{{ORGIN}}</th>
    </tr>
    <tr>
      <th scope="row"><strong>İletişim Dili –&nbsp;</strong>Communication Language</th>
      <th colspan="3" scope="row">{{ORGIN}}</th>
    </tr>
    <tr>
      <th colspan="4" scope="row"><strong>Karar ve Değerlendirmeye İlişkin Bilgiler –&nbsp;</strong>Information about the Decision and Evaluation</th>
    </tr>
    <tr>
      <th colspan="4" scope="row"><strong>Giriş Yasağı Kararı Başlangıç-Bitiş Tarihi –&nbsp;</strong>Start and End Date of Entry Ban Decision</th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><strong>Giriş Yasağı Kararı Başlangıç-Bitiş Tarihi –&nbsp;</strong>Start and End Date of Entry Ban Decision</th>
      <th scope="col">{{TODAY}}</th>
      <th scope="col">{{CANENT}}</th>
    </tr>
    <tr>
      <th scope="col"><strong>Tahdit Kodu / Restriction Code</strong></th>
      <th colspan="2" scope="col"><h5>{{TCODE}}</h5></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col">* Bu alana giriş yasağı kararının başlangıç tarihi yazılacaktır. –&nbsp;<em>*&nbsp;</em><em>Enter start date of entry ban decision to this field.</em> <br>
      ** Bu alana giriş yasağı kararının bitiş tarihi yazılacaktır. –&nbsp;<em>**&nbsp;</em><em>Enter end date of entry ban decision to this field.</em></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><ol start="1" type="1">
        <li><strong>Giriş Yasağı Kararı –&nbsp;</strong><strong>Entry Ban Decision</strong></li>
      </ol></th>
    </tr>
  </tbody>
</table>

<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col">6458 sayılı Yabancılar ve Uluslararası Koruma Kanunun 9 uncu maddesi uyarınca gerçekleştirilen değerlendirme neticesinde, Göç İdaresi Genel Müdürlüğü / …………. Valiliği (İl Göç İdaresi Müdürlüğü) tarafından hakkınızda giriş yasağı kararı alınmıştır. –&nbsp;<em>As a result of the evaluation conducted in accordance with the Article 9 of the Law on Foreigners and International Protection numbered 6458, Directorate General of Migration Management / Governorship of …………. (Provincial Directorate of Migration Management) has resolved to impose an entry ban on you.</em></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 9px;" scope="col"><ul>
        <li>Hakkınızda giriş yasağı kararı alınmasına dayanak teşkil eden husus/hususlar sebebiyle; -&nbsp;<em>Based on the particular/particulars constituting grounds for imposing an entry ban on you;</em></li>
        <li><em>İkamet izninizin iptali için gerekli işlemler başlatılacaktır. –&nbsp;<a name="_Hlk43630024"><em>Respective procedures will be commenced for cancelling your residence permit.</em></a>&nbsp;</em></li>
        <li><em>Çalışma izninizin iptali için gerekli işlemler başlatılacaktır. –&nbsp;<em>Respective procedures will be commenced for cancelling your work permit.</em></em></li>
        <li><u>Türkiye’ye girişinizin yasaklı olduğu süre içerisinde giriş yapmak istemeniz halinde, Türkiye Cumhuriyeti Dış Temsilciliklerinden amacına uygun (özel meşruhatlı) vize almanız gerekmektedir. –&nbsp;</u><em><u>If you wish to enter Turkey during the period of your entry ban, you are required to obtain the relevant visa (annotated visa) from Foreign Representative Offices of the Republic of Turkey.&nbsp;</u></em></li>
        <li><em><u>Hakkınızda tahsis edilen giriş yasağı süresinin sona ermesi yüz seksen günde doksan gün kuralının uygulanmasına engel teşkil etmemektedir. Her halükârda vizenin veya vize muafiyetinin Türkiye’de sağladığı kalış süresi, her yüz seksen günde doksan günü geçemez. –&nbsp;<em>Note that the expiration of the entry ban period imposed on you does not constitute any impediment for implementing the rule of ninety days in one hundred and eighty days. In any case, the duration of stay in Turkey granted by the visa or the visa exemption cannot exceed ninety days in every one hundred and eighty days.</em></u></em></li>
        <li><em><u><em><u>Hakkınızda alınan giriş yasağı kararının süresi dolmuş olsa dahi idari para cezanızı ödememenizden kaynaklanan ön izin kararına ilişkin hükümler saklıdır. -&nbsp;</u><em><u>All provisions with respect to the preliminary permission decision stemming from the non-payment of your administrative fine are reserved regardless of the expiration of the entry ban decision imposed on you.</u></em></em></u></em></li>
      </ul></th>
    </tr>
  </tbody>
</table>

<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><ol start="2" type="1">
        <li><strong>Giriş Yasağı Kararına Karşı Yargı Yoluna Başvuru –&nbsp;</strong><strong>Resort to the Jurisdiction Against the Entry Ban Decision</strong></li>
      </ol></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 9px;" scope="col"><ul>
        <li>Şahsınız veya yasal temsilciniz ya da avukatınız tarafından, giriş yasağı kararına karşı, kararın tebliğinden itibaren 60 (altmış) gün içinde idare mahkemesine başvurulabilir. –&nbsp;<a name="_Hlk43631319"><em>You or your legal representative or lawyer may appeal against the entry ban decision to the Administrative Court within 60 (sixty) days from the notification of the decision.</em></a></li>
        <li>Mahkemeye başvuran kişi, giriş yasağı kararı veren makama da başvurusunu bildirir. –&nbsp;<a name="_Hlk43631350"><em>The applicant who applied to the Court also notifies the authority of the entry ban decision.</em></a></li>
        <li>Mahkemeye yapılan başvurular giriş yasağı kararını durdurmaz. –&nbsp;<a name="_Hlk43631381"><em>Applications made to the Court does not suspend the entry ban decision.</em></a></li>
      </ul></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 12px;" scope="col">Bu belge, bir nüshası avukatına/yabancıya/yasal temsilcisine verilmek üzere iki nüsha olarak hazırlanmış olup, hakkında sınır dışı etme kararı alınan yukarıda açık kimliği yazılı yabancıya kendi dilinde/anladığı dilde,&nbsp;<strong>{{TODAY}}</strong>&nbsp;tarihinde ve&nbsp;<strong>{{TOTIME}}</strong>&nbsp;saatinde yazılı olarak tebliğ edilmiş ve imza altına alınarak bir sureti tebellüğ edene verilmiştir. –&nbsp;<a name="_Hlk43631423"><em>This document has been issued in duplicate so a copy can be given to the lawyer/foreigner/legal representative and the foreigner, whose open identity is given above and upon whom the deportation decision has been imposed, has been notified in writing in his own language/language of comprehension on {{TODAY}} at {{TOTIME}} and one copy has been given to the notified with a signature.</em></a></th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: center" scope="col"><strong>Tebliğ Eden</strong></th>
      <th style="text-align: center" scope="col"><strong>Tebellüğ Eden</strong></th>
    </tr>
    <tr>
      <th style="text-align: center" scope="row"><strong>Notifying Party</strong></th>
      <td style="text-align: center"><strong>Notified</strong></td>
    </tr>
    <tr>
      <th style="text-align: center" scope="row"><strong>{{USER}}</strong></th>
      <td style="text-align: center"><strong>{{NAME}}</strong></td>
    </tr>
  </tbody>
</table>', N'<p></p><h3 align="center">VİZE İHLALİ İŞLEM FORMU /<strong>FORMALİTÄT FÜR DİE BEEİNTRÄCHTİGUNG DES AUFENTHALTSFRİSTS</strong></h3>
<table width="400" border="0">
  <tbody>
    <tr>
      <td>Adı Soyadı /Name und Vorname</td>
      <td> {{NAME}}</td>
    </tr>
    <tr>
      <td>Uyruğu / Nationalität</td>
      <td>{{ORGIN}}</td>
    </tr>
    <tr>
      <td>Pasaport No / Pass. Nummer</td>
      <td>{{PASSPORT}}</td>
    </tr>
  </tbody>
</table>
<span style="font-size: 14px"><br>
</span>
<table width="800" border="0">
  <tbody>
    <tr>
      <td colspan="2" style="font-size: 12px">
*  Ülkemize Giriş Tarihiniz ve Vize süreniz  İhre Einreisedatum und Aufenthaltsfrist in der Türkei.</td>
      <td style="font-size: 16px"><strong>{{EDATE}}</strong></td>
      <td><table width="100%" border="0">
        <tbody>
          <tr>
            <td width="8%"><strong>{{VDAY}}</strong></td>
            <td width="9%"><strong>&nbsp;Tag(e)</strong></td>
          </tr>
        </tbody>
      </table></td>
    </tr>
    <tr>
      <td colspan="2" style="font-size: 12px"><table width="100%" border="0">
        <tbody>
          <tr>
            <td>*&nbsp;&nbsp;Ülkemizden çıkış için müracaat tarihiniz/ İhr(e) Ausreisedatum aus der Türkei</td>
            <td>:</td>

          </tr>
        </tbody>
      </table></td>
      <td style="font-size: 16px"><strong>{{TODAY}}</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size: 12px">*&nbsp;&nbsp;Ülkemizden çıkış yapmanız gereken tarih/ Die erforderliche Ausreisedatum aus der Türkei</td>
      <td style="font-size: 12px">:</td>
      <td style="font-size: 16px"><strong>{{SEDATE}}</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size: 12px">*&nbsp;&nbsp;Ülkemize giriş yapabileceğiniz tarih/&nbsp;(Giriş yasağınızın otomatik olarak iptal edileceği tarih) / &nbsp;&nbsp;&nbsp; The date on which the ban on entry will be automatically canceled&nbsp;</td>
      <td style="font-size: 12px">:</td>
      <td style="font-size: 16px"><strong>{{CANENT}}</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size: 12px">*&nbsp;Tebliğ Edilen, Tahdit Çıkış&nbsp; veya İkamet Teskere Bitiş Tarihi / End date of notified or limitation date or residence permit</td>
      <td style="font-size: 12px">:</td>
      <td style="font-size: 16px"><strong>{{SEDATE}}</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size: 12px">*&nbsp;&nbsp;Vize ihlal süreniz / &nbsp;İhr(e) Beeinträchtigte Aufenthaltsfrist.</td>
      <td style="font-size: 12px">:</td>
      <td style="font-size: 16px"><strong>{{FINETIME}}</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size: 12px">*&nbsp;&nbsp;Vize ihlali için ödenecek ücret / Die zahlbare Gebühr für die Beeinträchtigung des Aufenthaltsfrists.</td>
      <td style="font-size: 12px">:</td>
      <td style="font-size: 16px"><strong>{{FINET}}</strong></td><td style="font-size: 16px"><span style="font-size: 13px; font-weight: 700 !important;"><font size="2">TL</font></span><br></td></tr></tbody></table>
<span style="font-size: 14px"><br>
</span>
<table width="800" border="0">
  <tbody>
    <tr>
      <td style="font-size: 12px"><p>Sayın&nbsp;{{NAME}}&nbsp;Ülkemizdeki yasal kalış sürenizi ihlal etmiş bulunmaktasınız.{{S}}Vize ihlal ücretini ödemediğiniz için hakkınızda ülkemize&nbsp;<strong>{{FINEDAY}}&nbsp;</strong>Gün giriş yasağı uygulanacaktır.&nbsp; Hakkınızda girilecek&nbsp;Tahdit kodu {{TCODE}}{{F}}</p>
       
      <hr>
      <table width="800" border="0">
  <tbody>
    <tr>
      <td>Sehr Geehrte Herr/Frau&nbsp;<strong>{{NAME}}</strong>&nbsp;&nbsp;sie haben Ihre legale Aufenthaltsdauer (Visum) in unserem Land überschritten. Wir bedanken uns im Voraus für die Bezahlung Ihrer Starfe bezüglich des Visa- Vergehens.&nbsp;<strong>{{S1}}</strong>&nbsp;Ihnen wird hiermit für<strong>{{FINEDAY}}</strong>&nbsp; &nbsp;,Entry Ban Code :&nbsp;{{TCODE}}<strong>{{F1}}</strong></td>
    </tr>
  </tbody>
</table>

      </td>
    </tr>
  </tbody>
</table>
<span style="font-size: 14px"><br>
</span>
<table align="center" width="400" border="0">
  <tbody>
    <tr>
      <td>Düzenleme Tarihi / Ausstellungsdatum:</td>
      <td><strong>{{TODAY}}</strong></td>
    </tr>
  </tbody>
</table>
<span style="font-size: 14px"><br>
</span>
<table width="800" border="0">
  <tbody>
    <tr align="center">
      <td>Yolcu İmzası</td>
      <td>Pasaport Kontrol Polisi</td>
    </tr>
    <tr align="center">
      <td>Unterschrift der Passagiers</td>
      <td>Beauftragte der Passkontrolbehörde</td>
    </tr>
    <tr align="center">
      <td><strong>&nbsp;{{NAME}}</strong></td>
      <td><strong>{{POLICE}}</strong></td>
    </tr>
  </tbody>
</table>
<span style="font-size: 14px"><br>
</span>
<table width="800" border="0">
  <tbody>
    <tr>
      <td>Formu okudum, imzaladım ve kopyasını aldım /İch habe diesen Formblatt gelesen und einen Absatz davon erhalten.</td>
    </tr>
  </tbody>
</table>
<span style="font-size: 14px"><br>
</span>
<table width="800" border="0">
  <tbody>
    <tr align="center">
      <td><strong>O N A Y</strong></td>
    </tr>
    <tr align="center">
      <td>APPROVAL</td>
    </tr>
    <tr align="center">
      <td>{{USER}}</td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
  <tr>
						<th scope="col" style="width:10"><span style="font-size:10px">1</span></th>
						<td style="text-align:left"><span style="font-size:10px">İkamet Harçları 492 sayılı Harçlar kanununun 6 sayılı tarifesine göre her yıl Maliye Bakanlığınca Belirlenmektedir./</span><span style="font-size: 10px;"> Die Aufenthaltsgebühren werden jedes Jahr vom Finanzministerium gemäß Tarif Nr. 6 des Gebührengesetzes Nr. 492 festgelegt. </span></td>
					</tr>
					<tr>
						<th scope="row" style="width:10"><span style="font-size:10px">2</span></th>
						<td style="text-align:left"><span style="font-size:10px">Hakkınızda konulmuşsa, konulan ülkemize giriş yasağının kaldırılması için Türkiye Cumhuriyeti dış temsilciliklerine özel amaçlı vize için müracaat ediniz./</span><span style="font-size: 10px;"> Wenn es sich um Sie handelt, beantragen Sie bei den ausländischen Vertretern der Republik Türkei ein Sondervisum, um das Einreiseverbot für unser Land aufzuheben.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">3</span></th>
						<td style="text-align:left"><span style="font-size:10px">Vize ihlali nedeniyle hakkınızda uygulanan "N" veya "Ç" tahdit kodlarıyla ilgili , 60(altmış) gün içerisinde İdare mahkemesine başvuru yapmanız gerekmektedir./</span><span style="font-size: 10px;"> Sie müssen innerhalb von 60 (sechzig) Tagen beim Verwaltungsgericht einen Antrag bezüglich der Beschränkungscodes „N“ oder „C“ stellen, die Ihnen aufgrund eines Visumverstoßes auferlegt wurden.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">4</span></th>
						<td style="text-align:left"><span style="font-size:10px">Tahdit iş ve işlemler ile ilgili uygulamalar Göç İdaresi Genel Müdürlüğü''nün 22/07/2020 tarih ve 2020/17 sayılı genelgeye istinaden yapılmaktadır./</span><span style="font-size: 10px;"> Anträge im Zusammenhang mit den Beschränkungsarbeiten und Transaktionen werden gemäß dem Rundschreiben Nr. 2020/17 vom 22.07.2020 der Generaldirektion Migrationsmanagement gestellt.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">5</span></th>
						<td style="text-align:left"><span style="font-size:10px">Vize ihlalinde bulunan yolcularla ilgili yurda giriş yasaklarına ilişkin uygulama 2020/17 sayılı genelgenin Madde 6''nın "A" ve "B" bendlerine istinaden uygulanır./</span><span style="font-size: 10px;"> Der Antrag bezüglich des Verbots des Zutritts zum Wohnheim für Passagiere, die gegen ein Visum verstoßen, wird gemäß den Klauseln „A“ und „B“ des Artikels 6 des Rundschreibens Nr. 2020/17 beantragt.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">6</span></th>
						<td style="text-align:left"><span style="font-size:10px">6458 Sayılı Yabancılar ve Uluslararası Koruma Kanununun "9","15","102" Maddeleri./</span><span style="font-size: 10px;"> Artikel „9“, „15“, „102“ des Gesetzes über Ausländer und internationalen Schutz Nr. 6458.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">7</span></th>
						<td style="text-align:left"><span style="font-size:10px">17/03/2016 tarihli ve 29656 sayılı Yabancılar ve Uluslararası Koruma Kanununun Uygulamasına İlişkin Yönetmeliğin 8. ve 9. Maddeleri./</span><span style="font-size: 10px;"> Artikel 8 und 9 der Verordnung zur Umsetzung des Gesetzes über Ausländer und internationalen Schutz vom 17.03.2016 mit der Nummer 29656.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">8</span></th>
						<td style="text-align:left"><span style="font-size:10px">Göç İdaresi Başkanlığı''nın 06.01.2022 tarih ve V-157 İdari Takip Kodu Görüş Talebi Konulu Yazısı.</span><span style="font-size: 10px;"> Schreiben der Direktion für Migrationsmanagement vom 06.01.2022 zum Verwaltungsverfolgungscode V-157, Bitte um Stellungnahme. </span></td>
					</tr>
  </tbody>
</table>
<br>
<br>
<br>
<br>
<br>
<br>
<p align="center"><img src="../img/goc.png" width="200" height="95" class="note-float-left" style="float: left;"></p>

<table width="800" border="0" align="center">
  <tbody>
    <tr align="center">
      <td>İdari Para Cezalarına İlişkin N Kodlu Ön İzin Kararı Tebliğ Formu<br>
      <strong><span lang="de">Kode N in Bezug auf die Ordnungsgelder –</span></strong><strong><span lang="de">Notifizierungsformular für die Entscheidung über die vorläufige Erlaubnis</span></strong></td>
    </tr>
  </tbody>
  
</table>

<table width="800" border="0">
  <tbody>
    <tr>
      <td align="center"><strong style="font-size: 14px">Yabancıya İlişkin Bilgiler&nbsp;–&nbsp;Informationen über den Ausländer</strong></td>
    </tr>
  </tbody>
</table>

<table width="800" border="1">
  <tbody>
    <tr>
      <td style="font-size: 12px">Adı –&nbsp;Name</td>
      <td style="font-size: 12px"><strong>{{FIRSTNAME}}</strong></td>
    </tr>
    <tr>
      <td style="font-size: 12px">Soyadı –&nbsp;Nachname</td>
      <td style="font-size: 12px"><strong>{{LASTNAME}}</strong></td>
    </tr>
    <tr>
      <td style="font-size: 12px">Baba Adı –&nbsp;&nbsp;Name des Vaters</td>
      <td style="font-size: 12px"><strong>{{FATHERNAME}}</strong></td>
    </tr>
    <tr>
      <td style="font-size: 12px">Anne Adı –&nbsp;Name der Mutter</td>
      <td style="font-size: 12px"><strong>{{MOTHERNAME}}</strong></td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <td>Doğum Tarihi –&nbsp;Geburtsdatum</td>
      <td><strong>{{BIRTHDATE}}</strong></td>
      <td>Uyruğu –&nbsp;Nationalität</td>
      <td><strong>{{ORGIN}}</strong></td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <td>İletişim Dili –&nbsp;Kommunikationssprache</td>
      <td><strong>{{ORGIN}}</strong></td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <td style="text-align: center">Karar ve Değerlendirmeye İlişkin Bilgiler –&nbsp;Informationen über<span style="text-align: center"></span> die Entscheidung und Beurteilung</td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th width="518" rowspan="2" scope="col">Giriş Yasağı Kararı Başlangıç-Bitiş Tarihi –&nbsp;Anfangs- und Enddatum des Ausschlussbeschluss</th>
      <th width="53" scope="col">1-</th>
      <th width="207" scope="col">{{TODAY}}</th>
    </tr>
    <tr>
      <th scope="col">2-</th>
      <th scope="col">&nbsp;</th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="font-size: 12px" scope="col">* Bu alana giriş yasağı kararının başlangıç tarihi yazılacaktır.</th>
      <th style="font-size: 12px" scope="col"><em><span lang="DE">Das Anfangs- und Enddatum des Ausschlussbeschluss sollen auf diesen Platz geschrieben werden</span></em></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="font-size: 12px" scope="col">** Bu alana giriş yasağı kararının bitiş tarihi yazılacaktır.</th>
      <th style="font-size: 12px" scope="col"><em><span lang="DE">&nbsp;Der Enddatum des Ausschlussbeschluss sollen auf diesen Platz geschrieben werden.</span></em></th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 12px;"><li style="text-align:center"><strong>Ön İzin Kararı –<span lang="DE">Die Entscheidung über die vorläufige Erlaubnis</span></strong></li>
        <li><strong>6458 sayılı Yabancılar ve Uluslararası Koruma Kanunun 9 uncu maddesi uyarınca gerçekleştirilen değerlendirme neticesinde,&nbsp;<a name="_Hlk43629860">………….</a>&nbsp;Valiliği (İl Göç İdaresi Müdürlüğü) tarafından hakkınızda ön izin kararı alınmıştır. –&nbsp;<em>Infolge der Beurteilung, die gemäß Artikel 9 des Ausländer- und internationalen Schutzgesetz durchgeführt ist, .................... ist die Entscheidung über die vorläufige Erlaubnis für Sie durch das Gouvernerursamt (Provinzeinwanderungsbehörde) getroffen.</em></strong></li><em>
        <li><strong>
        Hakkınızda ön izin kararı alınmasına dayanak teşkil eden husus/hususlar sebebiyle; -&nbsp;</strong></li>
        <span lang="DE">Aufgrund des/der Grunds/Gründen, der/die zu Grunde liegt/liegen, dass die Entscheidung über die vorläufige Erlaubnis für Sie betroffen ist;</span>
        <li><strong>&nbsp;İkamet izninizin iptali için gerekli işlemler başlatılacaktır. -&nbsp;</strong></li>
        <span lang="DE">Notwendige Vorgänge sollen zur Aufhebung ihrer Aufenthaltsbefugnis eingeführt werden</span>
        <li><strong>Çalışma izninizin iptali için gerekli işlemler başlatılacaktır. -&nbsp;</strong></li>
        <span lang="de">Notwendige Vorgänge sollen zur Aufhebung ihrer Arbeitserlaubnis eingeführt werden.</span>
        <li><strong><u>İdari para cezanızı ödememeniz nedeni ile hakkınızda alınan ön izin kararı, idari para cezasının ödendiğine ilişkin makbuzun idareye tebliğ edilmesi halinde kaldırılır ve&nbsp;</u>girişinize engel olacak başka bir hususun bulunmaması kaydıyla<u>&nbsp;Türkiye’ye girişinize izin verilir.</u>&nbsp;</strong></li>
        <li><strong><em>&nbsp;<u><span lang="DE">Die Entscheidung über die vorläufige Erlaubnis, die für Sie dadurch getroffen, dass Sie das Ordnungsgeld nicht bezahlen wird aufgehoben, falls der Beleg in Bezug auf die Bezahlung des Ordnungsgeld der Behörde gegeben wird und dann könne Sie in Türkei einreisen</span></u></em><em><span lang="DE">, falls es keine weitere Sache gibt, die sie daran hindert, in die Türkei einzureisen.</span></em></strong></li>
        <li style="text-align:center"><strong>Ön İzin Kararına Karşı Yargı Yoluna Başvuru –&nbsp;<span lang="DE">Rechtmittelsantrag gegen die Entscheidung über die vorläufige Erlaubnis</span></strong></li>
        <li><strong>Şahsınız veya yasal temsilciniz ya da avukatınız tarafından, ön izin kararına karşı, kararın tebliğinden itibaren 60 (altmış) gün içinde idare mahkemesine başvurulabilir. –&nbsp;</strong></li>
        <span lang="DE">Sie oder ihr/e Rechtsvertreter/in oder Rechtsanwalt/in können einen Antrag gegen die Entscheidung über die vorläufige Erlaubnis vor Verwaltungsgericht in der 60 (sechzig) Tagen ab der Ankündigung des Beschlusses stellen.</span>
        <li><strong><a name="_Hlk43633494"></a></strong></li>
        <li><strong>Mahkemeye başvuran kişi, ön izin kararı veren makama da başvurusunu bildirir. –&nbsp;</strong></li>
        <span lang="DE">Derjenige/Diejenige, der/die den Antrag vor dem Gericht stellt, stellt auch den Antrag vor dem Gericht, das die Entscheidung über die vorläufige Erlaubnis trifft.</span>
        <li><strong><a name="_Hlk43633548"></a></strong></li>
        <li><strong>Mahkemeye yapılan başvurular ön izin kararını durdurmaz. –&nbsp;</strong></li>
        <span lang="DE">Die vor dem Gericht gestellte Anträge heben die Entscheidung für die vorläufige Erlaubnis nicht auf.</span>        <strong>
        
      </strong></em></th>
    </tr>
  </tbody>
</table>




<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align:justify; font-size:12px">Bu belge, bir nüshası avukatına/yabancıya/yasal temsilcisine verilmek üzere iki nüsha olarak hazırlanmış olup, hakkında sınır dışı etme kararı alınan yukarıda açık kimliği yazılı yabancıya kendi dilinde/anladığı dilde,&nbsp;<a name="_Hlk43631423"><em>{{TODAY}}&nbsp;&nbsp;</em></a>tarihinde ve&nbsp;&nbsp;<a name="_Hlk43631423"><em>{{TOTIME}}&nbsp;</em></a>saatinde yazılı olarak tebliğ edilmiş ve imza altına alınarak bir sureti tebellüğ edene verilmiştir. –&nbsp;<em><span lang="DE">Dieses Dokument wurde in zweifacher Ausfertigung erstellt, so dass eine Kopie an den Anwalt/Ausländer/gesetzlichen Vertreter übergeben werden kann und der Ausländer, dessen offene Identität oben gegeben ist und über den die Ausweisungsentscheidung ergangen ist wurde schriftlich in seiner eigenen Sprache/Sprache seines Verständnisses am&nbsp;</span></em><strong>{{TODAY}}</strong><em><span lang="DE">um&nbsp;</span></em><strong>{{TOTIME}}</strong>&nbsp;<em><span lang="DE">benachrichtigt und eine Kopie wurde ihm gegen eine Unterschrift übergeben.</span></em></th>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="0" align="center">
  <tbody>
    <tr align="center">
      <th scope="col"><strong>Tebliğ Eden</strong></th>
      <th scope="col"><strong>Tebellüğ Eden</strong></th>
    </tr>
    <tr align="center">
      <th scope="row"><strong><span lang="DE">Benachrichtigende Partei</span></strong></th>
      <td scope="col"><strong><span lang="DE">Benachrichtigter</span></strong></td>
    </tr>
    <tr align="center">
      <th scope="row"><strong>{{USER}}</strong></th>
      <td><strong>{{NAME}}</strong></td>
    </tr>
  </tbody>
</table>
<p>&nbsp;</p>

<p align="center"><span style="text-align: left;"><br>{{ÇS}}</span><br></p>


<p>&nbsp;</p>

<p align="center"><img src="../img/goc.png" width="200" height="95" class="note-float-left" style="float: left;"></p>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th> Ç Kodlu Giriş Yasağı Kararı Tebliğ Formu / <strong><span lang="de">Kode Ç -&nbsp;</span><span lang="DE">Notifizierungsformular für den Ausschlussbeschluss</span></strong></th>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th scope="col">Yabancıya İlişkin Bilgiler – Informationen über den Ausländer</th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: left" scope="col"><strong>Adı –&nbsp;</strong>Name</th>
      <th scope="col">{{FIRSTNAME}}</th>
    </tr>
    <tr>
      <th style="text-align: left" scope="row"><strong>Soyadı –&nbsp;</strong>Nachname</th>
      <td>{{LASTNAME}}</td>
    </tr>
    <tr>
      <th style="text-align: left" scope="row"><strong>Baba Adı –&nbsp;</strong>Name des Vaters</th>
      <td>{{FATHERNAME}}</td>
    </tr>
    <tr>
      <th style="text-align: left" scope="row"><strong>Anne Adı –&nbsp;</strong>Name der Mutter</th>
      <td>{{MOTHERNAME}}</td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: left" scope="col"><strong>Doğum Tarihi –&nbsp;</strong>Geburtsdatum</th>
      <th scope="col">{{BIRTHDATE}}</th>
      <th scope="col"><strong>Uyruğu –&nbsp;</strong>Nationalität</th>
      <th scope="col">{{ORGIN}}</th>
    </tr>
    <tr>
      <th style="text-align: left" scope="row"><strong>İletişim Dili –&nbsp;</strong>Kommunikationssprache</th>
      <th colspan="3" scope="row">{{ORGIN}}</th>
    </tr>
    <tr>
      <th colspan="4" scope="row"><strong>Karar ve Değerlendirmeye İlişkin Bilgiler –&nbsp;</strong>Informationen über die Entscheidung und Beurteilung</th>
    </tr>
   
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><strong>Giriş Yasağı Kararı Başlangıç-Bitiş Tarihi –&nbsp;</strong>Anfangs- und Enddatum des Ausschlussbeschluss</th>
      <th scope="col">{{TODAY}}</th>
      <th scope="col">{{CANENT}}</th>
    </tr>
    <tr>
      <th scope="col"><strong>Tahdit Kodu / Einreisesperrcode</strong></th>
      <th colspan="2" scope="col"><h5>{{TCODE}}</h5></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 10px;" scope="col">* Bu alana giriş yasağı kararının başlangıç tarihi yazılacaktır. –&nbsp;<em>*&nbsp;</em><em><span lang="de">Das Anfangs- und Enddatum des Ausschlussbeschluss sollen auf diesen Platz geschrieben werden.</span></em><br>
      ** Bu alana giriş yasağı kararının bitiş tarihi yazılacaktır. –&nbsp;<em>**&nbsp;</em><em><span lang="de">Der Enddatum des Ausschlussbeschluss sollen auf diesen Platz geschrieben werden.</span></em></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><ol start="1" type="1">
        <li><strong>Giriş Yasağı Kararı –&nbsp;</strong><strong><span lang="de">Ausschlussbeschluss</span></strong></li>
      </ol></th>
    </tr>
  </tbody>
</table>

<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 12px;" scope="col">6458 sayılı Yabancılar ve Uluslararası Koruma Kanunun 9 uncu maddesi uyarınca gerçekleştirilen değerlendirme neticesinde, Göç İdaresi Genel Müdürlüğü / …………. Valiliği (İl Göç İdaresi Müdürlüğü) tarafından hakkınızda giriş yasağı kararı alınmıştır. –&nbsp;<em><span lang="de">Infolge der Beurteilung, die gemäß Artikel 9 des Ausländer- und internationalen Schutzgesetz durchgeführt ist, ist der Ausschlussbeschluss für Sie Durch die Einwanderungsbehörde / das Gouverneursamt................ (Provinzeinwanderungsbehörde) getroffen.</span></em></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 9px;" scope="col"><ul>
        <li>Hakkınızda giriş yasağı kararı alınmasına dayanak teşkil eden husus/hususlar sebebiyle; -<em><span lang="de">Aufgrund des/der Grunds/Gründen, der/die zu Grunde liegt/liegen, dass der Ausschlussbeschluss für Sie betroffen ist;</span></em></li>
        <li><em>İkamet izninizin iptali için gerekli işlemler başlatılacaktır. –&nbsp;<span lang="de">Notwendige Vorgänge sollen zur Aufhebung ihrer Aufenthaltsbefugnis eingeführt werden.</span></em></li>
        <li><em>Çalışma izninizin iptali için gerekli işlemler başlatılacaktır. –&nbsp;<span lang="de">Notwendige Vorgänge sollen zur Aufhebung ihrer Arbeitserlaubnis eingeführt werden.</span></em></li>
        <li><u>Türkiye’ye girişinizin yasaklı olduğu süre içerisinde giriş yapmak istemeniz halinde, Türkiye Cumhuriyeti Dış Temsilciliklerinden amacına uygun (özel meşruhatlı) vize almanız gerekmektedir. –</u><em><u>&nbsp;<em><u><span lang="DE">Falls Sie während ihres Ausschlussbeschluss in die Türkei einreisen wollen, sollen Sie durch die türkischen Auslandvertretungen ein relevantes (annotiertes) Visum erhalten.</span></u></em>&nbsp;</u></em></li>
        <li><em><u>Hakkınızda tahsis edilen giriş yasağı süresinin sona ermesi yüz seksen günde doksan gün kuralının uygulanmasına engel teşkil etmemektedir. Her halükârda vizenin veya vize muafiyetinin Türkiye’de sağladığı kalış süresi, her yüz seksen günde doksan günü geçemez. </u><span lang="de">Der Ablauf des für Sie betroffenen Ausschlussbeschlusszeit hindern es nicht, die Regel der neunzig Tagen in der einhundertachtzig Tagen durchzuführen. Jedenfalls überschreitet der von dem Visum oder der Visumfreiheit angebotene Aufenthalt in der Türkei nicht die neunzig Tage pro der einhundertachtzig Tagen.</span></em></li>
        <li><em><u><em><u>Hakkınızda alınan giriş yasağı kararının süresi dolmuş olsa dahi idari para cezanızı ödememenizden kaynaklanan ön izin kararına ilişkin hükümler saklıdır. -</u></em></u></em><em><u><span lang="de">Auch wenn die für Sie betroffene Ausschlussbeschlusszeit abgelaufen ist, sind Alle Bestimmungen in Bezug auf die Entscheidung über die vorläufige Erlaubnis vorbehalten, die dadurch auftreten, dass Sie das Ordnungsgeld nicht bezahlen.</span></u></em></li>
      </ul></th>
    </tr>
  </tbody>
</table>

<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><ol start="2" type="1">
        <li><strong>Giriş Yasağı Kararına Karşı Yargı Yoluna Başvuru –&nbsp;</strong><strong><span lang="DE">Rechtmittels – Antrag gegen den Ausschlussbeschluss</span></strong></li>
      </ol></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 9px;" scope="col"><ul>
        <li>Şahsınız veya yasal temsilciniz ya da avukatınız tarafından, giriş yasağı kararına karşı, kararın tebliğinden itibaren 60 (altmış) gün içinde idare mahkemesine başvurulabilir. –&nbsp;<em><span lang="de">Sie oder ihr/e Rechtsvertreter/in oder Rechtsanwalt/in können einen Antrag gegen den Ausschlussbeschluss vor Verwaltungsgericht in der 60 (sechzig) Tagen ab der Ankündigung des Beschluss stellen.</span></em></li>
        <li>Mahkemeye başvuran kişi, giriş yasağı kararı veren makama da başvurusunu bildirir. –&nbsp;<a name="_Hlk43631350"><em><span lang="de">Derjenige/Diejenige, der/die den Antrag vor dem Gericht stellt, stellt auch den Antrag vor dem Gericht, das den Ausschlussbeschluss trifft.</span></em></a></li>
        <li>Mahkemeye yapılan başvurular giriş yasağı kararını durdurmaz. –&nbsp;<a name="_Hlk43631381"><em><span lang="de">Die vor dem Gericht gestellte Anträge heben den Ausschlussbeschluss nicht auf.</span></em></a></li>
      </ul></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 12px;" scope="col">Bu belge, bir nüshası avukatına/yabancıya/yasal temsilcisine verilmek üzere iki nüsha olarak hazırlanmış olup, hakkında sınır dışı etme kararı alınan yukarıda açık kimliği yazılı yabancıya kendi dilinde/anladığı dilde,&nbsp;<strong>{{TODAY}}</strong>&nbsp;tarihinde ve&nbsp;<strong>{{TOTIME}}</strong>&nbsp;saatinde yazılı olarak tebliğ edilmiş ve imza altına alınarak bir sureti tebellüğ edene verilmiştir. –&nbsp;<a name="_Hlk43631423"><em><span lang="de">Dieses Dokument wurde in zweifacher Ausfertigung erstellt, so dass eine Kopie an den Anwalt/Ausländer/gesetzlichen Vertreter übergeben werden kann und der Ausländer, dessen offene Identität oben gegeben ist und über den die Ausweisungsentscheidung ergangen ist wurde schriftlich in seiner eigenen Sprache/Sprache seines Verständnisses am</span></em><strong>{{TODAY}}</strong><em><span lang="DE">um&nbsp;</span></em><strong>{{TOTIME}}</strong>&nbsp;<em><span lang="de">benachrichtigt und eine Kopie wurde ihm gegen eine Unterschrift übergeben.</span></em></a></th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: center" scope="col"><strong>Tebliğ Eden</strong></th>
      <th style="text-align: center" scope="col"><strong>Tebellüğ Eden</strong></th>
    </tr>
    <tr>
      <th style="text-align: center" scope="row"><strong><span lang="DE">Benachrichtigende Partei</span></strong></th>
      <td style="text-align: center"><strong><span lang="DE">Benachrichtigter</span></strong></td>
    </tr>
    <tr>
      <th style="text-align: center" scope="row"><strong>{{USER}}</strong></th>
      <td style="text-align: center"><strong>{{NAME}}</strong></td>
    </tr>
  </tbody>
</table>
', N'<h3 align="center"><strong>VİZE İHLALİ İŞLEM FORMU /АКТ О НАРУШЕНИИ ВИЗОВОГО РЕЖИМА</strong></h3>
<table width="400" border="0">
  <tbody>
    <tr>
      <td>Adı Soyadı /Имя; Фамилия</td>
      <td><strong> {{NAME}}</strong></td>
    </tr>
    <tr>
      <td>Uyruğu / Гражданство</td>
      <td><strong>{{ORGIN}}</strong></td>
    </tr>
    <tr>
      <td>Pasaport No / Номер паспорта</td>
      <td><strong>{{PASSPORT}}</strong></td>
    </tr>
  </tbody>
</table>
<strong><span style="font-size: 14px"><br>
</span>
</strong>
<table width="800" border="0">
  <tbody>
    <tr>
      <td colspan="2" style="font-size: 12px; text-align: left;">*  Ülkemize Giriş Tarihiniz ve Vize süreniz  Дата прибытия и срок действия визы..</td>
      <td style="font-size: 16px"><strong>{{EDATE}}</strong></td>
      <td><table width="100%" border="0">
        <tbody>
          <tr>
            <td width="8%"><strong>{{VDAY}}</strong></td>
            <td width="9%"><strong>&nbsp;Day</strong></td>
          </tr>
        </tbody>
      </table></td>
    </tr>
    <tr>
      <td colspan="2" style="font-size: 12px; text-align: justify;"><table width="100%" border="0">
        <tbody>
          <tr>
            <td>*&nbsp;&nbsp;Ülkemizden çıkış için müracaat tarihiniz/ &nbsp;Дата выезда</td>
            <td><strong>:</strong></td>

          </tr>
        </tbody>
      </table></td>
      <td style="font-size: 16px"><strong>{{TODAY}}</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size: 12px">*&nbsp;&nbsp;Ülkemizden çıkış yapmanız gereken tarih/Окончание срока пребывания.</td>
      <td style="font-size: 12px"><strong>:</strong></td>
      <td style="font-size: 16px"><strong>{{SEDATE}}</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size: 12px">*&nbsp;&nbsp;Ülkemize giriş yapabileceğiniz tarih/&nbsp;(Giriş yasağınızın otomatik olarak iptal edileceği tarih) / &nbsp;&nbsp;&nbsp;Вы можете подключиться к нашей стране (Автоматически отменить дату вашего запрет)</td>
      <td style="font-size: 12px"><strong>:</strong></td>
      <td style="font-size: 16px"><strong>{{CANENT}}</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size: 12px">*&nbsp;Tebliğ Edilen, Tahdit Çıkış&nbsp; veya İkamet Teskere Bitiş Tarihi / End date of notified or limitation date or residence permit</td>
      <td style="font-size: 12px"><strong>:</strong></td>
      <td style="font-size: 16px"><strong>{{SEDATE}}</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size: 12px">*&nbsp;&nbsp;Vize ihlal süreniz / &nbsp;Срок нарушения визы</td>
      <td style="font-size: 12px"><strong>:</strong></td>
      <td style="font-size: 16px"><strong>{{FINETIME}}</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size: 12px">*&nbsp;&nbsp;Vize ihlali için ödenecek ücret / &nbsp; Сумма штрафа</td>
      <td style="font-size: 12px"><strong>:</strong></td>
      <td style="font-size: 16px"><strong>{{FINET}}</strong></td>
      <td style="font-size: 16px"><strong><span style="font-size: 13px; font-weight: 700 !important;"><font size="2">TL</font></span><br>
      </strong></td>
    </tr></tbody></table>
<strong><span style="font-size: 14px"><br>
</span>
</strong>
<table width="800" border="0">
  <tbody>
    <tr>
      <td style="font-size: 12px"><p>Sayın&nbsp;<strong>{{NAME}}</strong>&nbsp;Ülkemizdeki yasal kalış sürenizi ihlal etmiş bulunmaktasınız.{{S}}Vize ihlal ücretini ödemediğiniz için hakkınızda ülkemize<strong>&nbsp;{{FINEDAY}}</strong>&nbsp;Gün giriş yasağı uygulanacaktır.&nbsp; Hakkınızda girilecek&nbsp;Tahdit kodu <strong>{{TCODE}}</strong>{{F}}</p>
       
      <hr>
      <table width="800" border="0">
  <tbody>
    <tr>
      <td>уважаемый господин / госпожа&nbsp;<strong>{{NAME}}</strong>&nbsp; В случае He оплаты штрафа за нарушение визового режима&nbsp;{{S1}}&nbsp;Турецкой Республики отказ на въезд в течение&nbsp;<strong>{{FINEDAY}}</strong>&nbsp;месяцев {{F1}}</td>
    </tr>
  </tbody>
</table>

      </td>
    </tr>
  </tbody>
</table>
<strong><span style="font-size: 14px"><br>
</span>
</strong>
<table align="center" width="400" border="0">
  <tbody>
    <tr>
      <td>Düzenleme Tarihi / Дата :</td>
      <td><strong>{{TODAY}}</strong></td>
    </tr>
  </tbody>
</table>
<strong><span style="font-size: 14px"><br>
</span>
</strong>
<table width="800" border="0">
  <tbody>
    <tr align="center">
      <td>Yolcu İmzası</td>
      <td>Pasaport Kontrol Polisi</td>
    </tr>
    <tr align="center">
      <td>Подпись пассажира</td>
      <td>Орган пограничного контроля</td>
    </tr>
    <tr align="center">
      <td><strong>&nbsp;{{NAME}}</strong></td>
      <td><strong>{{POLICE}}</strong></td>
    </tr>
  </tbody>
</table>
<strong><span style="font-size: 14px"><br>
</span>
</strong>
<table width="800" border="0">
  <tbody>
    <tr>
      <td>Formu okudum, imzaladım ve kopyasını aldım /С текстом акта ознакомлен, подписался, получил копию.</td>
    </tr>
  </tbody>
</table>
<strong><span style="font-size: 14px"><br>
</span>
</strong>
<table width="800" border="0">
  <tbody>
    <tr align="center">
      <td>O N A Y</td>
    </tr>
    <tr align="center">
      <td>ПОТВЕРЖДЕНИЕ</td>
    </tr>
    <tr align="center">
      <td><strong>{{USER}}</strong></td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
  <tr>
      <th style="width:10" scope="col">1</th>
      <td style="font-size:9px; text-align:left ">İkamet Harçları 492 sayılı Harçlar kanununun 6 sayılı tarifesine göre her yıl Maliye Bakanlığınca Belirlenmektedir./Суммы подлежащие оплате за пребывание в стране определяются ежегодно Министерством Финансов на основании закона № 492 о взносах и пошлинах, тариф № 6.</td>
    </tr>
					 <tr>
      <th style="width:10" scope="row">2</th>
      <td style="font-size:9px; text-align:left ">Hakkınızda konulmuşsa, konulan ülkemize giriş yasağının kaldırılması için Türkiye Cumhuriyeti dış temsilciliklerine özel amaçlı vize için müracaat ediniz./Для того, чтобы снять запрет на въезд в страну, обращайтесь для получения особой визы в иностранные представительства Турецкой Республики.</td>
    </tr>
					<tr>
      <th style="width:20" scope="row">3</th>
      <td style="font-size:9px; text-align:left ">Vize ihlali nedeniyle hakkınızda uygulanan "N" veya "Ç" tahdit kodlarıyla ilgili , 60(altmış) gün içerisinde İdare mahkemesine başvuru yapmanız gerekmektedir./Вы должны обратиться в административный суд в течение 60 (шестидесяти) дней в отношении кодов ограничений «N» или «C», примененных к вам в связи с нарушением визы.</td>
    </tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">4</span></th>
						<td style="text-align:left"><span style="font-size:10px">Tahdit iş ve işlemler ile ilgili uygulamalar Göç İdaresi Genel Müdürlüğü''nün 22/07/2020 tarih ve 2020/17 sayılı genelgeye istinaden yapılmaktadır./</span><span style="font-size: 10px;"> Ограничения, связанные с работой и действиями, относятся к приложениям, согласно общим распоряжением Генерального управления по миграции от 22.07.2020 г. № 2020/17.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">5</span></th>
						<td style="text-align:left"><span style="font-size:10px">Vize ihlalinde bulunan yolcularla ilgili yurda giriş yasaklarına ilişkin uygulama 2020/17 sayılı genelgenin Madde 6''nın "A" ve "B" bendlerine istinaden uygulanır./</span><span style="font-size: 10px;"> Применение запретов на въезд в страну для пассажиров, нарушивших визовые правила, осуществляется в соответствии с пунктами "А" и "Б" статьи 6 общего распоряжения под номером 2020/17 согласно правовым нормам.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">6</span></th>
						<td style="text-align:left"><span style="font-size:10px">6458 Sayılı Yabancılar ve Uluslararası Koruma Kanununun "9","15","102" Maddeleri./</span><span style="font-size: 10px;">Закон № 6458 "О иностранцах и международной защите", Статьи "9", "15" и "102" в соответствии с законом.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">7</span></th>
						<td style="text-align:left"><span style="font-size:10px">17/03/2016 tarihli ve 29656 sayılı Yabancılar ve Uluslararası Koruma Kanununun Uygulamasına İlişkin Yönetmeliğin 8. ve 9. Maddeleri./</span><span style="font-size: 10px;"> Пункты 8 и 9 Положения о применении Закона о иностранцах и международной защите № 29656 от 17.03.2016 года.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">8</span></th>
						<td style="text-align:left"><span style="font-size:10px">Göç İdaresi Başkanlığı''nın 06.01.2022 tarih ve V-157 İdari Takip Kodu Görüş Talebi Konulu Yazısı.</span><span style="font-size: 10px;"> Письмо Миграционной службы от 06.01.2022 года с номером V-157 по Запросу о Мнении о Правоприменении Административного Кодекса.

 </span></td>
					</tr>
  </tbody>
</table>

 
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<p align="center"><strong><img src="../img/goc.jpg" width="200" height="95" class="note-float-left" style="float: left;"></strong></p>

<table width="800" border="0" align="center">
  <tbody>
    <tr align="center">
      <td><p><span style="text-align: left;">İdari Para Cezalarına İlişkin N Kodlu Ön İzin Kararı Tebliğ Formu</span><br></p><p>
      Форма-уведомление решения о предварительном разрешении с кодом N касательно административного штрафа</p></td>
    </tr>
  </tbody>
  
</table>

<table width="800" border="0">
  <tbody>
    <tr>
      <td align="center">Yabancıya İlişkin Bilgiler&nbsp;–&nbsp;Информация об иностранном гражданине</td>
    </tr>
  </tbody>
</table>

<table width="800" border="1">
  <tbody>
    <tr>
      <td style="font-size: 12px">Adı –&nbsp;Имя</td>
      <td style="font-size: 12px"><strong>{{FIRSTNAME}}</strong></td>
    </tr>
    <tr>
      <td style="font-size: 12px">Soyadı –&nbsp;Фамилия</td>
      <td style="font-size: 12px"><strong>{{LASTNAME}}</strong></td>
    </tr>
    <tr>
      <td style="font-size: 12px">Baba Adı –&nbsp;&nbsp;Имя отца</td>
      <td style="font-size: 12px"><strong>{{FATHERNAME}}</strong></td>
    </tr>
    <tr>
      <td style="font-size: 12px">Anne Adı –&nbsp;Имя матери</td>
      <td style="font-size: 12px"><strong>{{MOTHERNAME}}</strong></td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <td>Doğum Tarihi –&nbsp;Дата рождения</td>
      <td><strong>{{BIRTHDATE}}</strong></td>
      <td>Uyruğu –&nbsp;Гражданство</td>
      <td><strong>{{ORGIN}}</strong></td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <td>İletişim Dili –&nbsp;Язык для коммуникации</td>
      <td><strong>{{ORGIN}}</strong></td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <td style="text-align: center">Karar ve Değerlendirmeye İlişkin Bilgiler –&nbsp;Информация о решении и рассмотрении вопроса</td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th width="518" rowspan="2" scope="col">Giriş Yasağı Kararı Başlangıç-Bitiş Tarihi –&nbsp;Дата начала-окончания запрета на въезд</th>
      <th width="53" scope="col"><strong>1-</strong></th>
      <th width="207" scope="col"><strong>{{TODAY}}</strong></th>
    </tr>
    <tr>
      <th scope="col"><strong>2-</strong></th>
      <th scope="col">&nbsp;</th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="font-size: 12px" scope="col">* Bu alana giriş yasağı kararının başlangıç tarihi yazılacaktır.</th>
      <th style="font-size: 12px" scope="col"><em>В этом поле будет указана дата начала запрета на въезд</em>&nbsp;<em>.</em></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="font-size: 12px" scope="col">** Bu alana giriş yasağı kararının bitiş tarihi yazılacaktır.</th>
      <th style="font-size: 12px" scope="col"><em>В этом поле будет указана дата окончания запрета на въезд</em>&nbsp;<em><span lang="DE">.</span></em></th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 12px;"><li style="text-align:center"><strong>Ön İzin Kararı –Решение о предварительном разрешении</strong></li>
        <li>6458 sayılı Yabancılar ve Uluslararası Koruma Kanunun 9 uncu maddesi uyarınca gerçekleştirilen değerlendirme neticesinde,&nbsp;<a name="_Hlk43629860">………….</a>&nbsp;Valiliği (İl Göç İdaresi Müdürlüğü) tarafından hakkınızda ön izin kararı alınmıştır. –&nbsp;<em>По результатам рассмотрения вопроса в соответствии со статьей 9 Закона №6458 Об иностранцах и международной защите, Губернаторством (Управлением по вопросам миграции провинции)................................в отношении Вас было принято решение о предварительном разрешении&nbsp;</em>.</li>        <em>
        <li><strong>
        Hakkınızda ön izin kararı alınmasına dayanak teşkil eden husus/hususlar sebebiyle; -&nbsp;</strong><em style="font-weight: 400;"><strong>На основании обстоятельства/обстоятельств, которые являются основой для принятия в отношении Вас решения о предварительном разрешении&nbsp;</strong></em><strong>;</strong></li></em><em><li><strong>&nbsp;İkamet izninizin iptali için gerekli işlemler başlatılacaktır. -</strong><em style="font-weight: 400;"><strong>Будут начаты необходимые процедуры по аннулированию Вашего разрешения на проживание&nbsp;</strong></em><strong>.</strong></li></em><em><li><strong>Çalışma izninizin iptali için gerekli işlemler başlatılacaktır. -&nbsp;</strong><em style="font-weight: 400;"><strong>Будут начаты необходимые процедуры по аннулированию Вашего разрешения на работу&nbsp;</strong></em><strong>.</strong></li></em><em><li><strong><u>İdari para cezanızı ödememeniz nedeni ile hakkınızda alınan ön izin kararı, idari para cezasının ödendiğine ilişkin makbuzun idareye tebliğ edilmesi halinde kaldırılır ve&nbsp;</u>girişinize engel olacak başka bir hususun bulunmaması kaydıyla<u>&nbsp;Türkiye’ye girişinize izin verilir.</u>&nbsp;</strong></li>
        <li><strong><em>&nbsp;</em><u><em>Принятое из-за неуплаты административного штрафа в отношении Вас решение о предварительном разрешении, отменяется в случае предоставления в управление квитанции об уплате административного штрафа и Вам будет разрешен въезд,&nbsp;</em></u> <em>при условии отсутствия других преград для Вашего въезда&nbsp;<u>в Турцию.</u></em></strong></li>
        <li style="text-align:center"><strong>Ön İzin Kararına Karşı Yargı Yoluna Başvuru –Ходатайство об отмене в судебном порядке решения о предварительном разрешении</strong></li>
        <li><strong>Şahsınız veya yasal temsilciniz ya da avukatınız tarafından, ön izin kararına karşı, kararın tebliğinden itibaren 60 (altmış) gün içinde idare mahkemesine başvurulabilir. –&nbsp;</strong><em style="font-weight: 400;"><strong>Вы лично, либо через вашего законного представителя, либо вашего адвоката, можете обратиться в административный суд с обжалованием вынесенного в отношении Вас решения о предварительном разрешении в течение 60 (шестидесяти) дней после получения уведомления о принятом решении.</strong></em></li><li><strong>Mahkemeye başvuran kişi, ön izin kararı veren makama da başvurusunu bildirir. –&nbsp;</strong><br></li>
        <strong>Лицо, обратившееся в суд, также уведомляет о своем ходатайстве орган, принявший решение о предварительном разрешении.
        
        
        
        </strong>
        <li><strong>Mahkemeye yapılan başvurular ön izin kararını durdurmaz. –&nbsp;</strong><em style="font-weight: 400;"><strong>Обращение в суд не останавливает действие решения о предварительном разрешении.</strong></em></li></em></th>
    </tr>
  </tbody>
</table>




<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align:justify; font-size:12px"><strong>Bu belge, bir nüshası avukatına/yabancıya/yasal temsilcisine verilmek üzere iki nüsha olarak hazırlanmış olup, hakkında sınır dışı etme kararı alınan yukarıda açık kimliği yazılı yabancıya kendi dilinde/anladığı dilde,&nbsp;<a name="_Hlk43631423"><em>{{TODAY}}&nbsp;&nbsp;</em></a>tarihinde ve&nbsp;&nbsp;<a name="_Hlk43631423"><em>{{TOTIME}}&nbsp;</em></a>saatinde yazılı olarak tebliğ edilmiş ve imza altına alınarak bir sureti tebellüğ edene verilmiştir. –&nbsp;<em>Данный документ,</em>&nbsp;<em>с целью вручения одного экземпляра иностранному гражданину/ его адвокату/ его законному представителю, составлен в двух экземплярах, и&nbsp;</em>{{TODAY}}<em>&nbsp;числа в&nbsp;</em>{{TOTIME}}&nbsp;<em>&nbsp;был передан иностранному гражданину, в отношении которого принято решение о депортации и идентификационные данные которого указаны выше, в письменном виде на родном/понятном ему языке; один экземпляр данного документа был вручен уведомляемому под подпись.</em></strong></th>
    </tr>
  </tbody>
</table>
<strong><br>
</strong>
<table width="800" border="0" align="center">
  <tbody>
    <tr align="center">
      <th scope="col"><strong>Tebliğ Eden</strong></th>
      <th scope="col"><strong>Tebellüğ Eden</strong></th>
    </tr>
    <tr align="center">
      <th scope="row"><strong>Уведомляющий</strong></th>
      <td scope="col"><strong>Уведомляемый</strong></td>
    </tr>
    <tr align="center">
      <th scope="row"><strong>{{USER}}</strong></th>
      <td><strong>{{NAME}}</strong></td>
    </tr>
  </tbody>
</table>
<p>&nbsp;</p>
<p align="center"><span style="text-align: left;"><br>{{ÇS}}</span><span style="text-align: left;">&nbsp; &nbsp;</span></p>

<p align="center"><img src="../img/goc.jpg" width="200" height="95" class="note-float-left" style="float: left;"></p>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th> Ç Kodlu Giriş Yasağı Kararı Tebliğ Formu /Форма-уведомление решения о запрете на въезд с кодом Ç</th>
    </tr>
  </tbody>
</table>
<strong><br>
</strong>
<table width="800" border="0">
  <tbody>
    <tr>
      <th scope="col">Yabancıya İlişkin Bilgiler – Информация об иностранном гражданине</th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: left" scope="col"><strong>Adı –&nbsp;Имя</strong></th>
      <th scope="col"><strong>{{FIRSTNAME}}</strong></th>
    </tr>
    <tr>
      <th style="text-align: left" scope="row"><strong>Soyadı –&nbsp;Фамилия</strong></th>
      <td><strong>{{LASTNAME}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left" scope="row"><strong>Baba Adı –Имя отца (отчество)</strong></th>
      <td><strong>{{FATHERNAME}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left" scope="row"><strong>Anne Adı –&nbsp;Имя матери</strong></th>
      <td><strong>{{MOTHERNAME}}</strong></td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: left" scope="col"><strong>Doğum Tarihi –&nbsp;Дата рождения</strong></th>
      <th scope="col"><strong>{{BIRTHDATE}}</strong></th>
      <th scope="col"><strong>Uyruğu –&nbsp;Гражданство</strong></th>
      <th scope="col"><strong>{{ORGIN}}</strong></th>
    </tr>
    <tr>
      <th style="text-align: left" scope="row"><strong>İletişim Dili –&nbsp;Язык для коммуникации</strong></th>
      <th colspan="3" scope="row"><strong>{{ORGIN}}</strong></th>
    </tr>
    <tr>
      <th colspan="4" scope="row"><strong>Karar ve Değerlendirmeye İlişkin Bilgiler –&nbsp;Информация о решении и рассмотрении вопроса</strong></th>
    </tr>
   
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><strong>Giriş Yasağı Kararı Başlangıç-Bitiş Tarihi –&nbsp;Дата начала-окончания запрета на въезд</strong></th>
      <th scope="col"><strong>{{TODAY}}</strong></th>
      <th scope="col"><strong>{{CANENT}}</strong></th>
    </tr>
    <tr>
      <th scope="col"><strong>Tahdit Kodu / Ban Code</strong></th>
      <th colspan="2" scope="col"><h5><strong>{{TCODE}}</strong></h5></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 10px;" scope="col"><strong>* Bu alana giriş yasağı kararının başlangıç tarihi yazılacaktır. –&nbsp;<em>*</em>*В этом поле будет указана дата начала запрета на въезд<br>
      ** Bu alana giriş yasağı kararının bitiş tarihi yazılacaktır. –&nbsp;<em>**</em>В этом поле будет указана дата окончания запрета на въезд</strong></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><ol start="1" type="1">
        <li><strong>Giriş Yasağı Kararı –&nbsp;<em>Решение о запрете на въезд</em></strong></li>
      </ol></th>
    </tr>
  </tbody>
</table>

<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 12px;" scope="col"><strong>6458 sayılı Yabancılar ve Uluslararası Koruma Kanunun 9 uncu maddesi uyarınca gerçekleştirilen değerlendirme neticesinde, Göç İdaresi Genel Müdürlüğü / …………. Valiliği (İl Göç İdaresi Müdürlüğü) tarafından hakkınızda giriş yasağı kararı alınmıştır. –<em>По результатам рассмотрения вопроса в соответствии со статьей 9 Закона №6458 Об иностранцах и международной защите, Губернаторством (Управлением по вопросам миграции провинции)........................... в отношении Вас было принято решение о запрете на въезд.</em></strong></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 9px;" scope="col"><ul>
        <li><strong>Hakkınızda giriş yasağı kararı alınmasına dayanak teşkil eden husus/hususlar sebebiyle; -&nbsp;<em>На основании обстоятельства/обстоятельств, которые являются основой для принятия в отношении Вас решения о запрете на въезд&nbsp;</em>;</strong></li>
        <li><strong><em>İkamet izninizin iptali için gerekli işlemler başlatılacaktır. –&nbsp;Будут начаты необходимые процедуры по аннулированию Вашего разрешения на проживание.</em></strong></li>
        <li><strong><em>Çalışma izninizin iptali için gerekli işlemler başlatılacaktır. –&nbsp;Будут начаты необходимые процедуры по аннулированию Вашего разрешения на работу&nbsp;</em></strong></li>
        <li><strong><u>Türkiye’ye girişinizin yasaklı olduğu süre içerisinde giriş yapmak istemeniz halinde, Türkiye Cumhuriyeti Dış Temsilciliklerinden amacına uygun (özel meşruhatlı) vize almanız gerekmektedir. –</u><em><u>&nbsp;<em>Если вы хотите совершить въезд в Турцию в период действия Вашего запрета на въезд, предварительно Вы обязаны получить визу, соответствующую цели приезда (с особыми примечаниями) в иностранном представительстве Турецкой Республики.</em>&nbsp;</u></em></strong></li>
        <li><strong><em><u>Hakkınızda tahsis edilen giriş yasağı süresinin sona ermesi yüz seksen günde doksan gün kuralının uygulanmasına engel teşkil etmemektedir. Her halükârda vizenin veya vize muafiyetinin Türkiye’de sağladığı kalış süresi, her yüz seksen günde doksan günü geçemez. </u>Прекращение назначенного вам запрета на въезд не препятствует применению правила пребывания девяноста из ста восьмидесяти дней. В любом случае срок пребывания в Турции, предусмотренный действием визы или визового освобождения, не должен превышать девяноста из ста восьмидесяти дней».</em></strong></li>
        <li><strong><em><u><em><u>Hakkınızda alınan giriş yasağı kararının süresi dolmuş olsa dahi idari para cezanızı ödememenizden kaynaklanan ön izin kararına ilişkin hükümler saklıdır. </u></em></u></em><u><em>Даже если срок действия решения о запрете на въезд в отношении вас истек, положения, касающиеся решения о предварительном разрешении, связанного с неуплатой Вами административного штрафа, сохраняются.</em></u></strong></li>
      </ul></th>
    </tr>
  </tbody>
</table>

<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><ol start="2" type="1">
        <li><strong>Giriş Yasağı Kararına Karşı Yargı Yoluna Başvuru –&nbsp;<em>Ходатайство об отмене в судебном порядке решения о запрете на въезд</em></strong></li>
      </ol></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 9px;" scope="col"><ul>
        <li><strong>Şahsınız veya yasal temsilciniz ya da avukatınız tarafından, giriş yasağı kararına karşı, kararın tebliğinden itibaren 60 (altmış) gün içinde idare mahkemesine başvurulabilir. –&nbsp;<em>Вы лично, либо через вашего законного представителя, либо вашего адвоката, можете обратиться в административный суд с обжалованием вынесенного в отношении Вас решения о запрете на въезд в течение 60 (шестидесяти) дней после получения уведомления о принятом решении.</em></strong></li>
        <li><strong>Mahkemeye başvuran kişi, giriş yasağı kararı veren makama da başvurusunu bildirir. –&nbsp;<a name="_Hlk43631350"><em>Лицо, обратившееся в суд, также уведомляет о своем ходатайстве орган, принявший решение о запрете на въезд.</em></a></strong></li>
        <li><strong>Mahkemeye yapılan başvurular giriş yasağı kararını durdurmaz. –&nbsp;<a name="_Hlk43631381"><em>Обращение в суд не останавливает действие решения о запрете на въезд.</em></a></strong></li>
      </ul></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 12px;" scope="col"><strong>Bu belge, bir nüshası avukatına/yabancıya/yasal temsilcisine verilmek üzere iki nüsha olarak hazırlanmış olup, hakkında sınır dışı etme kararı alınan yukarıda açık kimliği yazılı yabancıya kendi dilinde/anladığı dilde,&nbsp;{{TODAY}}&nbsp;tarihinde ve&nbsp;{{TOTIME}}&nbsp;saatinde yazılı olarak tebliğ edilmiş ve imza altına alınarak bir sureti tebellüğ edene verilmiştir. –&nbsp;<a name="_Hlk43631423">&nbsp;<em>Данный документ, с целью вручения одного экземпляра иностранному гражданину/ его адвокату/ его законному представителю, составлен в двух экземплярах, и&nbsp;</em>{{TODAY}}<em>&nbsp;числа в</em>{{TOTIME}}<em>&nbsp;был передан иностранному гражданину, в отношении которого принято решение о депортации и идентификационные данные которого указаны выше, в письменном виде на родном/понятном ему языке; один экземпляр данного документа был вручен уведомляемому под подпись.</em></a></strong></th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: center" scope="col"><strong>Tebliğ Eden</strong></th>
      <th style="text-align: center" scope="col"><strong>Tebellüğ Eden</strong></th>
    </tr>
    <tr>
      <th style="text-align: center" scope="row"><strong><em>Уведомляющий</em></strong></th>
      <td style="text-align: center"><strong><em>Уведомляемый</em></strong></td>
    </tr>
    <tr>
      <th style="text-align: center" scope="row"><strong>{{USER}}</strong></th>
      <td style="text-align: center"><strong>{{NAME}}</strong></td>
    </tr>
  </tbody>
</table>


', N'<h3 align="center">VİZE İHLALİ İŞLEM FORMU /VISA VIOLATION FORM</h3>
<table width="400" border="0">
  <tbody>
    <tr>
      <td>Adı Soyadı /Name/Surname</td>
      <td> {{NAME}}</td>
    </tr>
    <tr>
      <td>Uyruğu / Nationality</td>
      <td>{{ORGIN}}</td>
    </tr>
    <tr>
      <td>Pasaport No / Passport No</td>
      <td>{{PASSPORT}}</td>
    </tr>
  </tbody>
</table>
<span style="font-size: 14px"><br>
</span>
<table width="800" border="0">
  <tbody>
    <tr>
      <td colspan="2" style="font-size: 12px">
*  Ülkemize Giriş Tarihiniz ve Vize süreniz  Date of entry into country / Notification Date and visa validity</td>
      <td style="font-size: 16px"><strong>{{EDATE}}</strong></td>
      <td><table width="100%" border="0">
        <tbody>
          <tr>
            <td width="8%"><strong>{{VDAY}}</strong></td>
            <td width="9%"><strong>&nbsp;Day(s)</strong></td>
          </tr>
        </tbody>
      </table></td>
    </tr>
    <tr>
      <td colspan="2" style="font-size: 12px"><table width="100%" border="0">
        <tbody>
          <tr>
            <td>*&nbsp;&nbsp;Ülkemizden çıkış için müracaat tarihiniz/ The date that you are applying to leave the country</td>
            <td>:</td>

          </tr>
        </tbody>
      </table></td>
      <td style="font-size: 16px"><strong>{{TODAY}}</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size: 12px">*&nbsp;&nbsp;Ülkemizden çıkış yapmanız gereken tarih/ The date that you were meant to leave the country</td>
      <td style="font-size: 12px">:</td>
      <td style="font-size: 16px"><strong>{{SEDATE}}</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size: 12px">*&nbsp;&nbsp;Ülkemize giriş yapabileceğiniz tarih/&nbsp;(Giriş yasağınızın otomatik olarak iptal edileceği tarih) / &nbsp;&nbsp;&nbsp; The date on which the ban on entry will be automatically canceled&nbsp;</td>
      <td style="font-size: 12px">:</td>
      <td style="font-size: 16px"><strong>{{CANENT}}</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size: 12px">*&nbsp;Tebliğ Edilen, Tahdit Çıkış&nbsp; veya İkamet Teskere Bitiş Tarihi / End date of notified or limitation date or residence permit</td>
      <td style="font-size: 12px">:</td>
      <td style="font-size: 16px"><strong>{{SEDATE}}</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size: 12px">*&nbsp;&nbsp;Vize ihlal süreniz / Visa violation period</td>
      <td style="font-size: 12px">:</td>
      <td style="font-size: 16px"><strong>{{FINETIME}}</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size: 12px">*&nbsp;&nbsp;Vize ihlali için ödenecek ücret / Penalty for visa violation</td>
      <td style="font-size: 12px">:</td>
      <td style="font-size: 16px"><strong>{{FINET}}</strong></td><td style="font-size: 16px"><span style="font-size: 13px; font-weight: 700 !important;"><font size="2">TL</font></span><br></td></tr></tbody></table>
<span style="font-size: 14px"><br>
</span>
<table width="800" border="0">
  <tbody>
    <tr>
      <td style="font-size: 12px"><p>Sayın&nbsp;{{NAME}}&nbsp;Ülkemizdeki yasal kalış sürenizi ihlal etmiş bulunmaktasınız.{{S}}Vize ihlal ücretini ödemediğiniz için hakkınızda ülkemize&nbsp;<strong>{{FINEDAY}}&nbsp;</strong>Gün giriş yasağı uygulanacaktır.&nbsp; Hakkınızda girilecek&nbsp;Tahdit kodu {{TCODE}}{{F}}</p>
       
      <hr>
      <table width="800" border="0">
  <tbody>
    <tr>
      <td> Dear Madame/Sir  {{NAME}}   You have overstayed your visa.{{S1}} As you have not paid the relevant fine, a  ban on your re-entering Turkey will be put into practise{{FINEDAY}}  Entry Ban Code {{TCODE}}{{F1}}</td>
    </tr>
  </tbody>
</table>

      </td>
    </tr>
  </tbody>
</table>
<span style="font-size: 14px"><br>
</span>
<table align="center" width="400" border="0">
  <tbody>
    <tr>
      <td>Düzenleme Tarihi / Dated On:</td>
      <td><strong>{{TODAY}}</strong></td>
    </tr>
  </tbody>
</table>
<span style="font-size: 14px"><br>
</span>
<table width="800" border="0">
  <tbody>
    <tr align="center">
      <td>Yolcu İmzası</td>
      <td>Pasaport Kontrol Polisi</td>
    </tr>
    <tr align="center">
      <td>Signature of passenger</td>
      <td>Passport police officer</td>
    </tr>
    <tr align="center">
      <td><strong>&nbsp;{{NAME}}</strong></td>
      <td><strong>{{POLICE}}</strong></td>
    </tr>
  </tbody>
</table>
<span style="font-size: 14px"><br>
</span>
<table width="800" border="0">
  <tbody>
    <tr>
      <td>Formu okudum, imzaladım ve kopyasını aldım / I have read the form, signed it,and have a copy of the form</td>
    </tr>
  </tbody>
</table>
<span style="font-size: 14px"><br>
</span>
<table width="800" border="0">
  <tbody>
    <tr align="center">
      <td><strong>O N A Y</strong></td>
    </tr>
    <tr align="center">
      <td>APPROVAL</td>
    </tr>
    <tr align="center">
      <td>{{USER}}</td>
    </tr>
  </tbody>
</table>
<span style="font-size: 14px"><br>
</span>
<table width="800" border="1">
  <tbody>
  <tr>
						<th scope="col" style="width:10"><span style="font-size:10px">1</span></th>
						<td style="text-align:left"><span style="font-size:10px">İkamet Harçları 492 sayılı Harçlar kanununun 6 sayılı tarifesine göre her yıl Maliye Bakanlığınca Belirlenmektedir./</span><span style="font-size: 10px;">Residence Fees are determined by the Ministry of Finance every year according to the tariff no. 6 of the Fees Law No. 492.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:10"><span style="font-size:10px">2</span></th>
						<td style="text-align:left"><span style="font-size:10px">Hakkınızda konulmuşsa, konulan ülkemize giriş yasağının kaldırılması için Türkiye Cumhuriyeti dış temsilciliklerine özel amaçlı vize için müracaat ediniz./</span><span style="font-size: 10px;">If it has been placed about you, apply for a special purpose visa to the foreign representatives of the Republic of Turkey in order to lift the ban on entry to our country.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">3</span></th>
						<td style="text-align:left"><span style="font-size:10px">Vize ihlali nedeniyle hakkınızda uygulanan "N" veya "Ç" tahdit kodlarıyla ilgili , 60(altmış) gün içerisinde İdare mahkemesine başvuru yapmanız gerekmektedir./</span><span style="font-size: 10px;">You must apply to the Administrative Court within 60 (sixty) days regarding the "N" or "C" restriction codes applied to you due to visa violation.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">4</span></th>
						<td style="text-align:left"><span style="font-size:10px">Tahdit iş ve işlemler ile ilgili uygulamalar Göç İdaresi Genel Müdürlüğü''nün 22/07/2020 tarih ve 2020/17 sayılı genelgeye istinaden yapılmaktadır./</span><span style="font-size: 10px;">Applications related to the restriction works and transactions are made in accordance with the circular numbered 2020/17 dated 22/07/2020 of the General Directorate of Migration Management.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">5</span></th>
						<td style="text-align:left"><span style="font-size:10px">Vize ihlalinde bulunan yolcularla ilgili yurda giriş yasaklarına ilişkin uygulama 2020/17 sayılı genelgenin Madde 6''nın "A" ve "B" bendlerine istinaden uygulanır./</span><span style="font-size: 10px;">Implementation of bans on entry to the dormitory for passengers violating a visa is applied pursuant to subparagraphs "A" and "B" of Article 6 of the circular numbered 2020/17.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">6</span></th>
						<td style="text-align:left"><span style="font-size:10px">6458 Sayılı Yabancılar ve Uluslararası Koruma Kanununun "9","15","102" Maddeleri./</span><span style="font-size: 10px;">Articles "9","15","102" of the Foreigners and International Protection Law No. 6458</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">7</span></th>
						<td style="text-align:left"><span style="font-size:10px">17/03/2016 tarihli ve 29656 sayılı Yabancılar ve Uluslararası Koruma Kanununun Uygulamasına İlişkin Yönetmeliğin 8. ve 9. Maddeleri./</span><span style="font-size: 10px;">Articles 8 and 9 of the Regulation on the Implementation of the Law on Foreigners and International Protection dated 17/03/2016 and numbered 29656</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">8</span></th>
						<td style="text-align:left"><span style="font-size:10px">Göç İdaresi Başkanlığı''nın 06.01.2022 tarih ve V-157 İdari Takip Kodu Görüş Talebi Konulu Yazısı.</span><span style="font-size: 10px;">Letter of the Directorate of Migration Management, dated 06.01.2022, on V-157 Administrative Tracking Code, Request for Opinion</span></td>
					</tr>
  </tbody>
</table>

<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p><p><br></p>
<p>&nbsp;</p>
<p align="center"><img src="../img/goc.png" width="200" height="95" class="note-float-left" style="float: left;"></p>

<table width="800" border="0" align="center">
  <tbody>
    <tr align="center">
      <td>İdari Para Cezalarına İlişkin N Kodlu Ön İzin Kararı Tebliğ Formu<br>
      Notification Form for Code N Preliminary Permission Decision Regarding Administrative Fines</td>
    </tr>
  </tbody>
  
</table>

<table width="800" border="0">
  <tbody>
    <tr>
      <td align="center"><strong style="font-size: 14px">Yabancıya İlişkin Bilgiler&nbsp;–&nbsp;Information on the Foreigner</strong></td>
    </tr>
  </tbody>
</table>

<table width="800" border="1">
  <tbody>
    <tr>
      <td style="font-size: 12px">Adı –&nbsp;Name</td>
      <td style="font-size: 12px"><strong>{{FIRSTNAME}}</strong></td>
    </tr>
    <tr>
      <td style="font-size: 12px">Soyadı –&nbsp;Surname</td>
      <td style="font-size: 12px"><strong>{{LASTNAME}}</strong></td>
    </tr>
    <tr>
      <td style="font-size: 12px">Baba Adı –&nbsp;Father’s Name</td>
      <td style="font-size: 12px"><strong>{{FATHERNAME}}</strong></td>
    </tr>
    <tr>
      <td style="font-size: 12px">Anne Adı –&nbsp;Mother’s Name</td>
      <td style="font-size: 12px"><strong>{{MOTHERNAME}}</strong></td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <td>Doğum Tarihi –&nbsp;Date of Birth</td>
      <td><strong>{{BIRTHDATE}}</strong></td>
      <td>Uyruğu –&nbsp;Nationality</td>
      <td><strong>{{ORGIN}}</strong></td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <td>İletişim Dili –&nbsp;Communication Language</td>
      <td><strong>{{ORGIN}}</strong></td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <td>Karar ve Değerlendirmeye İlişkin Bilgiler –&nbsp;Information about the Decision and Evaluation</td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th width="518" rowspan="2" scope="col">Giriş Yasağı Kararı Başlangıç-Bitiş Tarihi –&nbsp;Start Date of Entry Ban Decision</th>
      <th width="53" scope="col">1-</th>
      <th width="207" scope="col">{{TODAY}}</th>
    </tr>
    <tr>
      <th scope="col">2-</th>
      <th scope="col">&nbsp;</th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="font-size: 12px" scope="col">* Bu alana giriş yasağı kararının başlangıç tarihi yazılacaktır.</th>
      <th style="font-size: 12px" scope="col">Enter start date of entry ban decision to this field</th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="font-size: 12px" scope="col">** Bu alana giriş yasağı kararının bitiş tarihi yazılacaktır.</th>
      <th style="font-size: 12px" scope="col">Enter end date of entry ban decision to this field.</th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 12px;"><li style="text-align:center"><strong>Ön İzin Kararı –&nbsp;Preliminary Permission Decision</strong></li>
        <li><strong>6458 sayılı Yabancılar ve Uluslararası Koruma Kanunun 9 uncu maddesi uyarınca gerçekleştirilen değerlendirme neticesinde,&nbsp;<a name="_Hlk43629860">………….</a>&nbsp;Valiliği (İl Göç İdaresi Müdürlüğü) tarafından hakkınızda ön izin kararı alınmıştır. –&nbsp;<em>As a result of the evaluation conducted in accordance with the Article 9 of the Law on Foreigners and International Protection numbered 6458, Governorship of&nbsp;</em>………….<em>&nbsp;(Provincial Directorate of Migration Management) has resolved to adopt a preliminary permission decision against you.</em></strong></li><em>
        <li><strong>
        Hakkınızda ön izin kararı alınmasına dayanak teşkil eden husus/hususlar sebebiyle; -&nbsp;<a name="_Hlk43632705"><em>Based on the particular/particulars constituting grounds for adopting a preliminary permission decision against you;</em></a>&nbsp;</strong></li>
        <li><strong>&nbsp;İkamet izninizin iptali için gerekli işlemler başlatılacaktır. -&nbsp;<a name="_Hlk43632761"><em>Respective procedures will be commenced for cancelling your residence permit.</em></a>&nbsp;</strong></li>
        <li><strong>Çalışma izninizin iptali için gerekli işlemler başlatılacaktır. -&nbsp;<em>Respective procedures will be commenced for cancelling your work permit.</em></strong></li>
        <li><strong><u>İdari para cezanızı ödememeniz nedeni ile hakkınızda alınan ön izin kararı, idari para cezasının ödendiğine ilişkin makbuzun idareye tebliğ edilmesi halinde kaldırılır ve&nbsp;</u>girişinize engel olacak başka bir hususun bulunmaması kaydıyla<u>&nbsp;Türkiye’ye girişinize izin verilir.</u>&nbsp;</strong></li>
        <li><strong><em>&nbsp;<u>The preliminary permission decision adopted against you on the grounds of non-payment of the administrative fine imposed on you will be rescinded provided that the receipt of payment of the respective administrative fine is submitted to the directorate</u>, and&nbsp;<u>the permission of entry to Turkey</u>&nbsp;will be granted to you on condition that no other particulars barring you from entering Turkey are determined.</em></strong></li>
        <li style="text-align:center"><strong>Ön İzin Kararına Karşı Yargı Yoluna Başvuru –&nbsp;<a name="_Hlk43633474">Resort to the Jurisdiction Against the Preliminary Permission Decision</a>&nbsp;</strong></li>
        <li><strong>Şahsınız veya yasal temsilciniz ya da avukatınız tarafından, ön izin kararına karşı, kararın tebliğinden itibaren 60 (altmış) gün içinde idare mahkemesine başvurulabilir. –&nbsp;<a name="_Hlk43633494"><em>You or your legal representative or lawyer may appeal against the preliminary permission decision to the Administrative Court within 60 (sixty) days from the notification of the decision.</em></a></strong></li>
        <li><strong>Mahkemeye başvuran kişi, ön izin kararı veren makama da başvurusunu bildirir. –&nbsp;<a name="_Hlk43633548"><em>The applicant who applied to the Court also notifies the authority of the preliminary permission decision.</em></a></strong></li>
        <li><strong>Mahkemeye yapılan başvurular ön izin kararını durdurmaz. –&nbsp;<a name="_Hlk43633568"><em>Applications made to the Court does not suspend the preliminary permission decision.</em></a></strong></li>
        <strong>
        
      </strong></em></th>
    </tr>
  </tbody>
</table>




<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align:justify; font-size:12px">Bu belge, bir nüshası avukatına/yabancıya/yasal temsilcisine verilmek üzere iki nüsha olarak hazırlanmış olup, hakkında sınır dışı etme kararı alınan yukarıda açık kimliği yazılı yabancıya kendi dilinde/anladığı dilde,&nbsp;<a name="_Hlk43631423"><em>{{TODAY}}&nbsp;&nbsp;</em></a>tarihinde ve&nbsp;&nbsp;<a name="_Hlk43631423"><em>{{TOTIME}}&nbsp;</em></a>saatinde yazılı olarak tebliğ edilmiş ve imza altına alınarak bir sureti tebellüğ edene verilmiştir. –&nbsp;<a name="_Hlk43633584"><em>This document has been issued in duplicate so a copy can be given to the lawyer/foreigner/legal representative and the foreigner, whose open identity is given above and upon whom the deportation decision has been imposed, has been notified in writing in his own language/language of comprehension on&nbsp;&nbsp;</em></a><a name="_Hlk43631423"><em>{{TODAY}}&nbsp;</em></a><a name="_Hlk43633584"><em>at&nbsp;</em></a><a name="_Hlk43631423"><em>{{TOTIME}}</em></a><em>&nbsp;and one copy has been given to the notified with a signature.</em></th>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="0" align="center">
  <tbody>
    <tr align="center">
      <th scope="col"><strong>Tebliğ Eden</strong></th>
      <th scope="col"><strong>Tebellüğ Eden</strong></th>
    </tr>
    <tr align="center">
      <th scope="row"><strong>Notifying Party</strong></th>
      <td scope="col"><strong>Notified</strong></td>
    </tr>
    <tr align="center">
      <th scope="row"><strong>{{USER}}</strong></th>
      <td><strong>{{NAME}}</strong></td>
    </tr>
  </tbody>
</table>
<p>&nbsp;</p>

<p align="center"><span style="text-align: left;"><br>{{ÇS}}</span><br></p>


<p>&nbsp;</p>

<p align="center"><img src="../img/goc.png" width="200" height="95" class="note-float-left" style="float: left;"></p>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th> Ç Kodlu Giriş Yasağı Kararı Tebliğ Formu / Code Ç – Entry Ban Notification Form</th>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th scope="col">Yabancıya İlişkin Bilgiler – Information on the Foreigner</th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><strong>Adı –&nbsp;</strong>Name</th>
      <th scope="col">{{FIRSTNAME}}</th>
    </tr>
    <tr>
      <th scope="row"><strong>Soyadı –&nbsp;</strong>Surname</th>
      <td>{{LASTNAME}}</td>
    </tr>
    <tr>
      <th scope="row"><strong>Baba Adı –&nbsp;</strong>Father’s Name</th>
      <td>{{FATHERNAME}}</td>
    </tr>
    <tr>
      <th scope="row"><strong>Anne Adı –&nbsp;</strong>Mother’s Name</th>
      <td>{{MOTHERNAME}}</td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><strong>Doğum Tarihi –&nbsp;</strong>Date of Birth</th>
      <th scope="col">{{BIRTHDATE}}</th>
      <th scope="col"><strong>Uyruğu –&nbsp;</strong>Nationality</th>
      <th scope="col">{{ORGIN}}</th>
    </tr>
    <tr>
      <th scope="row"><strong>İletişim Dili –&nbsp;</strong>Communication Language</th>
      <th colspan="3" scope="row">{{ORGIN}}</th>
    </tr>
    <tr>
      <th colspan="4" scope="row"><strong>Karar ve Değerlendirmeye İlişkin Bilgiler –&nbsp;</strong>Information about the Decision and Evaluation</th>
    </tr>
    <tr>
      <th colspan="4" scope="row"><strong>Giriş Yasağı Kararı Başlangıç-Bitiş Tarihi –&nbsp;</strong>Start and End Date of Entry Ban Decision</th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><strong>Giriş Yasağı Kararı Başlangıç-Bitiş Tarihi –&nbsp;</strong>Start and End Date of Entry Ban Decision</th>
      <th scope="col">{{TODAY}}</th>
      <th scope="col">{{CANENT}}</th>
    </tr>
    <tr>
      <th scope="col"><strong>Tahdit Kodu / Restriction Code</strong></th>
      <th colspan="2" scope="col"><h5>{{TCODE}}</h5></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col">* Bu alana giriş yasağı kararının başlangıç tarihi yazılacaktır. –&nbsp;<em>*&nbsp;</em><em>Enter start date of entry ban decision to this field.</em> <br>
      ** Bu alana giriş yasağı kararının bitiş tarihi yazılacaktır. –&nbsp;<em>**&nbsp;</em><em>Enter end date of entry ban decision to this field.</em></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><ol start="1" type="1">
        <li><strong>Giriş Yasağı Kararı –&nbsp;</strong><strong>Entry Ban Decision</strong></li>
      </ol></th>
    </tr>
  </tbody>
</table>

<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col">6458 sayılı Yabancılar ve Uluslararası Koruma Kanunun 9 uncu maddesi uyarınca gerçekleştirilen değerlendirme neticesinde, Göç İdaresi Genel Müdürlüğü / …………. Valiliği (İl Göç İdaresi Müdürlüğü) tarafından hakkınızda giriş yasağı kararı alınmıştır. –&nbsp;<em>As a result of the evaluation conducted in accordance with the Article 9 of the Law on Foreigners and International Protection numbered 6458, Directorate General of Migration Management / Governorship of …………. (Provincial Directorate of Migration Management) has resolved to impose an entry ban on you.</em></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 9px;" scope="col"><ul>
        <li>Hakkınızda giriş yasağı kararı alınmasına dayanak teşkil eden husus/hususlar sebebiyle; -&nbsp;<em>Based on the particular/particulars constituting grounds for imposing an entry ban on you;</em></li>
        <li><em>İkamet izninizin iptali için gerekli işlemler başlatılacaktır. –&nbsp;<a name="_Hlk43630024"><em>Respective procedures will be commenced for cancelling your residence permit.</em></a>&nbsp;</em></li>
        <li><em>Çalışma izninizin iptali için gerekli işlemler başlatılacaktır. –&nbsp;<em>Respective procedures will be commenced for cancelling your work permit.</em></em></li>
        <li><u>Türkiye’ye girişinizin yasaklı olduğu süre içerisinde giriş yapmak istemeniz halinde, Türkiye Cumhuriyeti Dış Temsilciliklerinden amacına uygun (özel meşruhatlı) vize almanız gerekmektedir. –&nbsp;</u><em><u>If you wish to enter Turkey during the period of your entry ban, you are required to obtain the relevant visa (annotated visa) from Foreign Representative Offices of the Republic of Turkey.&nbsp;</u></em></li>
        <li><em><u>Hakkınızda tahsis edilen giriş yasağı süresinin sona ermesi yüz seksen günde doksan gün kuralının uygulanmasına engel teşkil etmemektedir. Her halükârda vizenin veya vize muafiyetinin Türkiye’de sağladığı kalış süresi, her yüz seksen günde doksan günü geçemez. –&nbsp;<em>Note that the expiration of the entry ban period imposed on you does not constitute any impediment for implementing the rule of ninety days in one hundred and eighty days. In any case, the duration of stay in Turkey granted by the visa or the visa exemption cannot exceed ninety days in every one hundred and eighty days.</em></u></em></li>
        <li><em><u><em><u>Hakkınızda alınan giriş yasağı kararının süresi dolmuş olsa dahi idari para cezanızı ödememenizden kaynaklanan ön izin kararına ilişkin hükümler saklıdır. -&nbsp;</u><em><u>All provisions with respect to the preliminary permission decision stemming from the non-payment of your administrative fine are reserved regardless of the expiration of the entry ban decision imposed on you.</u></em></em></u></em></li>
      </ul></th>
    </tr>
  </tbody>
</table>

<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><ol start="2" type="1">
        <li><strong>Giriş Yasağı Kararına Karşı Yargı Yoluna Başvuru –&nbsp;</strong><strong>Resort to the Jurisdiction Against the Entry Ban Decision</strong></li>
      </ol></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 9px;" scope="col"><ul>
        <li>Şahsınız veya yasal temsilciniz ya da avukatınız tarafından, giriş yasağı kararına karşı, kararın tebliğinden itibaren 60 (altmış) gün içinde idare mahkemesine başvurulabilir. –&nbsp;<a name="_Hlk43631319"><em>You or your legal representative or lawyer may appeal against the entry ban decision to the Administrative Court within 60 (sixty) days from the notification of the decision.</em></a></li>
        <li>Mahkemeye başvuran kişi, giriş yasağı kararı veren makama da başvurusunu bildirir. –&nbsp;<a name="_Hlk43631350"><em>The applicant who applied to the Court also notifies the authority of the entry ban decision.</em></a></li>
        <li>Mahkemeye yapılan başvurular giriş yasağı kararını durdurmaz. –&nbsp;<a name="_Hlk43631381"><em>Applications made to the Court does not suspend the entry ban decision.</em></a></li>
      </ul></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 12px;" scope="col">Bu belge, bir nüshası avukatına/yabancıya/yasal temsilcisine verilmek üzere iki nüsha olarak hazırlanmış olup, hakkında sınır dışı etme kararı alınan yukarıda açık kimliği yazılı yabancıya kendi dilinde/anladığı dilde,&nbsp;<strong>{{TODAY}}</strong>&nbsp;tarihinde ve&nbsp;<strong>{{TOTIME}}</strong>&nbsp;saatinde yazılı olarak tebliğ edilmiş ve imza altına alınarak bir sureti tebellüğ edene verilmiştir. –&nbsp;<a name="_Hlk43631423"><em>This document has been issued in duplicate so a copy can be given to the lawyer/foreigner/legal representative and the foreigner, whose open identity is given above and upon whom the deportation decision has been imposed, has been notified in writing in his own language/language of comprehension on {{TODAY}} at {{TOTIME}} and one copy has been given to the notified with a signature.</em></a></th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: center" scope="col"><strong>Tebliğ Eden</strong></th>
      <th style="text-align: center" scope="col"><strong>Tebellüğ Eden</strong></th>
    </tr>
    <tr>
      <th style="text-align: center" scope="row"><strong>Notifying Party</strong></th>
      <td style="text-align: center"><strong>Notified</strong></td>
    </tr>
    <tr>
      <th style="text-align: center" scope="row"><strong>{{USER}}</strong></th>
      <td style="text-align: center"><strong>{{NAME}}</strong></td>
    </tr>
  </tbody>
</table>

	


', N'<h3 align="center">VİZE İHLALİ İŞLEM FORMU /VISA VIOLATION FORM</h3>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: left" scope="col">Adı Soyadı /Name/Surname</th>
      <th style="text-align: left" scope="col">:<strong>{{NAME}}</strong></th>
    </tr>
    <tr>
      <th style="text-align: left" scope="row">Uyruğu/ Nationality</th>
      <td style="text-align: left">:<strong>{{ORGIN}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left" scope="row">Pasaport No/Passport No</th>
      <td style="text-align: left">:<strong>{{PASSPORT}}</strong></td>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: left; font-size: 10px;" scope="col">*&nbsp;&nbsp;Ülkemize Giriş Tarihiniz ve Vize süreniz<br>
      &nbsp;&nbsp;&nbsp;&nbsp; Date of entry into country and visa validity</th>
      <th scope="col"><strong>:</strong></th>
      <th style="text-align: left" scope="col"><strong>{{EDATE}}</strong></th>
      <th style="text-align: left" scope="col"><strong>{{VDAY}}</strong> Gün / Day</th>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;&nbsp;Ülkemizden çıkış için müracaat tarihiniz<br>
      &nbsp;&nbsp;&nbsp;The date that you are applying to leave the country</th>
      <th scope="row"><strong>:</strong></th>
      <td colspan="2" style="text-align: left"><strong>{{TODAY}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;Tebliğ Edilen, Tahdit Çıkış&nbsp; veya İkamet Teskere Bitiş Tarihi / End date of notified or limitation date or residence permit</th>
      <th scope="row">:</th>
      <td colspan="2" style="text-align: left"><strong>{{SEDATE}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;&nbsp;Ülkemizden çıkış yapmanız gereken tarih<br>
      &nbsp;&nbsp;&nbsp;The date that you were meant to leave the country</th>
      <th scope="row"><strong>:</strong></th>
      <td colspan="2" style="text-align: left"><strong>{{SEDATE}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;&nbsp;Vize ihlal süreniz<br>
      &nbsp;&nbsp;&nbsp;Visa violation period</th>
      <th scope="row"><strong>:</strong></th>
      <td colspan="2" style="text-align: left"><strong>{{FINETIME}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;&nbsp;Vize ihlali için ödenecek ücret<br>
      &nbsp;&nbsp;&nbsp;Penalty for visa violation</th>
      <th scope="row"><strong>:</strong></th>
      <td style="text-align: left"><strong>{{FINET}}</strong></td>
      <td style="text-align: left"><span style="font-weight: 700 !important;"><font size="2">TL</font></span><br></td>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 12px;" scope="col">Sayın<strong>&nbsp;{{NAME}}</strong>&nbsp;Ülkemizdeki yasal kalış sürenizi ihlal etmiş bulunmaktasınız. Vize ihlal ücretinizi şimdi ödediğinizden dolayı teşekkür ederiz.</th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: left; font-size: x-small;" scope="col">Dear Madame/Sir&nbsp;<strong>{{NAME}}&nbsp;</strong>&nbsp; You have exceeded the legal duration of stay in our country. Thank you in advance for paying the penalty of your visa-offence.&nbsp;<strong>{{S}}&nbsp;</strong>You will be banned from entering our country for&nbsp;<strong>{{FINEDAY}}</strong>days Entry Ban Code:{{TCODE}}{{F}}</th>
    </tr>
  </tbody>
</table>

<br>
<table align="center" width="400" border="0">
  <tbody>
    <tr>
      <td>Düzenleme Tarihi / Dated On:</td>
      <td><strong>{{TODAY}}</strong></td>
    </tr>
  </tbody>
</table>
<br>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: center" scope="col">Yolcu İmzası</th>
      <th style="text-align: center" scope="col">Pasaport Kontrol Polisi</th>
    </tr>
    <tr>
      <th style="text-align: center" scope="row">Signature of passenger</th>
      <td style="text-align: center">Passport police officer</td>
    </tr>
    <tr>
      <th style="text-align: center" scope="row"><strong>{{NAME}}</strong></th>
      <td style="text-align: center"><strong>{{POLICE}}</strong></td>
    </tr>
    <tr style="text-align: center">
      <th colspan="2" scope="row">&nbsp;</th>
    </tr>
    <tr style="text-align: center">
      <th colspan="2" scope="row">Formu okudum, imzaladım ve&nbsp;kopyasını aldım / I have read the form, signed it,and have a copy of the form</th>
    </tr>
 
    <tr style="text-align: center">
      <th colspan="2" scope="row">&nbsp;</th>
    </tr>
    <tr style="text-align: center">
      <th colspan="2" scope="row">O N A Y</th>
  </tr>
    <tr style="text-align: center">
      <th colspan="2" scope="row">APPROVAL</th>
  </tr>
    <tr><td colspan="2" scope="row"></td></tr><tr style="text-align: center">
      <th colspan="2" scope="row"><p><strong>{{USER}}</strong></p></th></tr></tbody></table>
<table width="800" border="1">
  <tbody>
  <tr>
						<th scope="col" style="width:10"><span style="font-size:10px">1</span></th>
						<td style="text-align:left"><span style="font-size:10px">İkamet Harçları 492 sayılı Harçlar kanununun 6 sayılı tarifesine göre her yıl Maliye Bakanlığınca Belirlenmektedir./</span><span style="font-size: 10px;">Residence Fees are determined by the Ministry of Finance every year according to the tariff no. 6 of the Fees Law No. 492.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:10"><span style="font-size:10px">2</span></th>
						<td style="text-align:left"><span style="font-size:10px">Hakkınızda konulmuşsa, konulan ülkemize giriş yasağının kaldırılması için Türkiye Cumhuriyeti dış temsilciliklerine özel amaçlı vize için müracaat ediniz./</span><span style="font-size: 10px;">If it has been placed about you, apply for a special purpose visa to the foreign representatives of the Republic of Turkey in order to lift the ban on entry to our country.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">3</span></th>
						<td style="text-align:left"><span style="font-size:10px">Vize ihlali nedeniyle hakkınızda uygulanan "N" veya "Ç" tahdit kodlarıyla ilgili , 60(altmış) gün içerisinde İdare mahkemesine başvuru yapmanız gerekmektedir./</span><span style="font-size: 10px;">You must apply to the Administrative Court within 60 (sixty) days regarding the "N" or "C" restriction codes applied to you due to visa violation.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">4</span></th>
						<td style="text-align:left"><span style="font-size:10px">Tahdit iş ve işlemler ile ilgili uygulamalar Göç İdaresi Genel Müdürlüğü''nün 22/07/2020 tarih ve 2020/17 sayılı genelgeye istinaden yapılmaktadır./</span><span style="font-size: 10px;">Applications related to the restriction works and transactions are made in accordance with the circular numbered 2020/17 dated 22/07/2020 of the General Directorate of Migration Management.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">5</span></th>
						<td style="text-align:left"><span style="font-size:10px">Vize ihlalinde bulunan yolcularla ilgili yurda giriş yasaklarına ilişkin uygulama 2020/17 sayılı genelgenin Madde 6''nın "A" ve "B" bendlerine istinaden uygulanır./</span><span style="font-size: 10px;">Implementation of bans on entry to the dormitory for passengers violating a visa is applied pursuant to subparagraphs "A" and "B" of Article 6 of the circular numbered 2020/17.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">6</span></th>
						<td style="text-align:left"><span style="font-size:10px">6458 Sayılı Yabancılar ve Uluslararası Koruma Kanununun "9","15","102" Maddeleri./</span><span style="font-size: 10px;">Articles "9","15","102" of the Foreigners and International Protection Law No. 6458</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">7</span></th>
						<td style="text-align:left"><span style="font-size:10px">17/03/2016 tarihli ve 29656 sayılı Yabancılar ve Uluslararası Koruma Kanununun Uygulamasına İlişkin Yönetmeliğin 8. ve 9. Maddeleri./</span><span style="font-size: 10px;">Articles 8 and 9 of the Regulation on the Implementation of the Law on Foreigners and International Protection dated 17/03/2016 and numbered 29656</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">8</span></th>
						<td style="text-align:left"><span style="font-size:10px">Göç İdaresi Başkanlığı''nın 06.01.2022 tarih ve V-157 İdari Takip Kodu Görüş Talebi Konulu Yazısı.</span><span style="font-size: 10px;">Letter of the Directorate of Migration Management, dated 06.01.2022, on V-157 Administrative Tracking Code, Request for Opinion</span></td>
					</tr>
  </tbody>
</table>

<br>{{S1}}<center><br>
<div align="center">
<p align="center"><img src="../img/goc.png" width="200" height="95" class="note-float-left" style="float: left;"></p>
</div>
<table width="800" border="0">
  <tbody>
    <tr>
      <th scope="col"><strong style="font-size: 14px; text-align: center;">Ç Kodlu Giriş Yasağı Kararı Tebliğ Formu<br>
      Code Ç – Entry Ban Notification Form</strong></th>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><strong style="font-size: 14px">Yabancıya İlişkin Bilgiler -&nbsp;</strong>Information on the Foreigner</th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="col">Adı<strong>&nbsp;-&nbsp;</strong>Name</th>
      <th colspan="2" style="font-size: 12px; text-align: left;" scope="col"><strong>{{FIRSTNAME}}</strong></th>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Soyadı&nbsp;<strong>-&nbsp;</strong>Surname</th>
      <td colspan="2" style="font-size: 12px"><strong>{{LASTNAME}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Baba Adı&nbsp;<strong>-&nbsp;</strong>Father’s Name</th>
      <td colspan="2" style="font-size: 12px"><strong>{{FATHERNAME}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Anne Adı&nbsp;<strong>-&nbsp;</strong>Mother’s Name</th>
      <td colspan="2" style="font-size: 12px"><strong>{{MOTHERNAME}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Doğum Tarihi<strong>–&nbsp;</strong>Date of Birth</th>
      <td style="font-size: 12px"><strong>{{BIRTHDATE}}</strong></td>
      <td style="font-size: 12px">Uyruğu&nbsp;<strong>-&nbsp;</strong>Nationality</td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">İletişim Dili&nbsp;<strong>-&nbsp;</strong>Communication Language</th>
      <td colspan="2" style="font-size: 12px"><strong>{{ORGIN}}</strong></td>
    </tr>
    <tr style="text-align: center; font-size: 12px;">
      <th colspan="3" scope="row"><strong>Karar ve Değerlendirmeye İlişkin Bilgiler -&nbsp;</strong>Information about the Decision and Evaluation</th>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Giriş Yasağı Kararı Başlangıç-Bitiş Tarihi<strong>&nbsp;-&nbsp;</strong>Start and End Date of Entry Ban Decision</th>
      <td style="font-size: 12px"><strong>{{TODAY}}</strong></td>
      <td style="font-size: 12px"><strong>{{CANENT}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Tahdit Kodu (Ban Code) :</th>
      <td colspan="2" style="font-size: 12px"><strong>{{TCODE}}</strong></td>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="font-size: 12px" scope="col">* Bu alana giriş yasağı kararının başlangıç tarihi yazılacaktır. –&nbsp;<em>*&nbsp;Enter start date of entry ban decision to this field.</em> <br>
      ** Bu alana giriş yasağı kararının bitiş tarihi yazılacaktır. –&nbsp;<em>**&nbsp;Enter end date of entry ban decision to this field.</em></th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align:justify; font-size: 12px;" scope="col">
      <p style="text-align:center;font-size:16px">1-Giriş Yasağı Kararı – Entry Ban Decision</p>
      <p> 6458 sayılı Yabancılar ve Uluslararası Koruma Kanunun 9 uncu maddesi uyarınca gerçekleştirilen değerlendirme neticesinde, Göç İdaresi Genel Müdürlüğü / …………. Valiliği (İl Göç İdaresi Müdürlüğü) tarafından hakkınızda giriş yasağı kararı alınmıştır.
        As a result of the evaluation conducted in accordance with the Article 9 of the Law on Foreigners and International Protection numbered 6458, Directorate General of Migration Management / Governorship of …………. (Provincial Directorate of Migration Management) has resolved to impose an entry ban on you. 
        	Hakkınızda giriş yasağı kararı alınmasına dayanak teşkil eden husus/hususlar sebebiyle; 
        	Based on the particular/particulars constituting grounds for imposing an entry ban on you;
        	İkamet izninizin iptali için gerekli işlemler başlatılacaktır. – Respective procedures will be commenced for cancelling your residence permit.
        	 Çalışma izninizin iptali için gerekli işlemler başlatılacaktır. – Respective procedures will be commenced for cancelling your work permit. 
        
        	Türkiye’ye girişinizin yasaklı olduğu süre içerisinde giriş yapmak istemeniz halinde, Türkiye Cumhuriyeti Dış Temsilciliklerinden amacına uygun (özel meşruhatlı) vize almanız gerekmektedir.
        	If you wish to enter Turkey during the period of your entry ban, you are required to obtain the relevant visa (annotated visa) from Foreign Representative Offices of the Republic of Turkey.  
        	Hakkınızda tahsis edilen giriş yasağı süresinin sona ermesi yüz seksen günde doksan gün kuralının uygulanmasına engel teşkil etmemektedir. Her halükârda vizenin veya vize muafiyetinin Türkiye’de sağladığı kalış süresi, her yüz seksen günde doksan günü geçemez.
        	 Note that the expiration of the entry ban period imposed on you does not constitute any impediment for implementing the rule of ninety days in one hundred and eighty days. In any case, the duration of stay in Turkey granted by the visa or the visa exemption cannot exceed ninety days in every one hundred and eighty days.
        
        	Hakkınızda alınan giriş yasağı kararının süresi dolmuş olsa dahi idari para cezanızı ödememenizden kaynaklanan ön izin kararına ilişkin hükümler saklıdır. 
        
        	All provisions with respect to the preliminary permission decision stemming from the non-payment of your administrative fine are reserved regardless of the expiration of the entry ban decision imposed on you.
        </p>
      <p style="text-align:center;font-size:16px">2-Giriş Yasağı Kararına Karşı Yargı Yoluna Başvuru – Resort to the Jurisdiction Against the Entry Ban Decision</p>
      <p> Şahsınız veya yasal temsilciniz ya da avukatınız tarafından, giriş yasağı kararına karşı, kararın tebliğinden itibaren 60 (altmış) gün içinde idare mahkemesine başvurulabilir. – You or your legal representative or lawyer may appeal against the entry ban decision to the Administrative Court within 60 (sixty) days from the notification of the decision.
        Mahkemeye başvuran kişi, giriş yasağı kararı veren makama da başvurusunu bildirir. – The applicant who applied to the Court also notifies the authority of the entry ban decision.
        Mahkemeye yapılan başvurular giriş yasağı kararını durdurmaz. – Applications made to the Court does not suspend the entry ban decision. 
        Bu belge, bir nüshası avukatına/yabancıya/yasal temsilcisine verilmek üzere iki nüsha olarak hazırlanmış olup, hakkında sınır dışı etme kararı alınan yukarıda açık kimliği yazılı yabancıya kendi dilinde/anladığı dilde, {{TODAY}} _ tarihinde ve {{TOTIME}} saatinde yazılı olarak tebliğ edilmiş ve imza altına alınarak bir sureti tebellüğ edene verilmiştir. </p>
      </th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 12px;" scope="col"><a name="_Hlk43631423"><em>This document has been issued in duplicate so a copy can be given to the lawyer/foreigner/legal representative and the foreigner, whose open identity is given above and upon whom the deportation decision has been imposed, has been notified in writing in his own language/language of comprehension on&nbsp;<strong>{{TODAY}}</strong>&nbsp;&nbsp;at&nbsp;<strong>{{TOTIME}}</strong>&nbsp;and one copy has been given to the notified with a signature.</em></a></th>
    </tr>
  </tbody>
</table>
<p>&nbsp;</p>


<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: center" scope="col"><strong>Tebliğ Eden -</strong><strong>Notifying Party</strong></th>
      <th style="text-align: center" scope="col"><strong>Tebellüğ Eden -</strong><strong>Notified</strong></th>
    </tr>
    <tr>
      <th style="text-align: center" scope="row"><strong>{{USER}}</strong></th>
      <td style="text-align: center"><strong>{{NAME}}</strong></td>
    </tr>
  </tbody>
</table>


{{F1}}</center>
', N'<p></p><h3 align="center">VİZE İHLALİ İŞLEM FORMU /<strong>FORMALİTÄT FÜR DİE BEEİNTRÄCHTİGUNG DES AUFENTHALTSFRİSTS</strong></h3>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: left" scope="col">Adı Soyadı /Name und Vorname</th>
      <th style="text-align: left" scope="col">:<strong>{{NAME}}</strong></th>
    </tr>
    <tr>
      <th style="text-align: left" scope="row">Uyruğu/ Nationalität</th>
      <td style="text-align: left">:<strong>{{ORGIN}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left" scope="row">Pasaport No/Pass. Nummer</th>
      <td style="text-align: left">:<strong>{{PASSPORT}}</strong></td>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: left; font-size: 10px;" scope="col">*&nbsp;&nbsp;Ülkemize Giriş Tarihiniz ve Vize süreniz<br>
      &nbsp;&nbsp;&nbsp;&nbsp;İhre Einreisedatum und Aufenthaltsfrist in der Türkei.</th>
      <th scope="col"><strong>:</strong></th>
      <th style="text-align: left" scope="col"><strong>{{EDATE}}</strong></th>
      <th style="text-align: left" scope="col"><strong>{{VDAY}}</strong> Gün / Tag(e)</th>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;&nbsp;Ülkemizden çıkış için müracaat tarihiniz<br>
      &nbsp;&nbsp;&nbsp;İhr(e) Ausreisedatum aus der Türkei</th>
      <th scope="row"><strong>:</strong></th>
      <td colspan="2" style="text-align: left"><strong>{{TODAY}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;Tebliğ Edilen, Tahdit Çıkış&nbsp; veya İkamet Teskere Bitiş Tarihi / End date of notified or limitation date or residence permit</th>
      <th scope="row">:</th>
      <td colspan="2" style="text-align: left"><strong>{{SEDATE}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;&nbsp;Ülkemizden çıkış yapmanız gereken tarih<br>
      &nbsp;&nbsp;&nbsp;Die erforderliche Ausreisedatum aus der Türkei.</th>
      <th scope="row"><strong>:</strong></th>
      <td colspan="2" style="text-align: left"><strong>{{SEDATE}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;&nbsp;Vize ihlal süreniz<br>
      &nbsp;&nbsp;&nbsp;İhr(e) Beeinträchtigte Aufenthaltsfrist.</th>
      <th scope="row"><strong>:</strong></th>
      <td colspan="2" style="text-align: left"><strong>{{FINETIME}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;&nbsp;Vize ihlali için ödenecek ücret<br>
      &nbsp;&nbsp;&nbsp;Die zahlbare Gebühr für die Beeinträchtigung des Aufenthaltsfrists.</th>
      <th scope="row"><strong>:</strong></th>
      <td style="text-align: left"><strong>{{FINET}}</strong></td>
      <td style="text-align: left"><br></td>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 12px;" scope="col">Sayın<strong>&nbsp;{{NAME}}</strong>&nbsp;Ülkemizdeki yasal kalış sürenizi ihlal etmiş bulunmaktasınız. Vize ihlal ücretinizi şimdi ödediğinizden dolayı teşekkür ederiz.</th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: left; font-size: x-small;" scope="col">&nbsp;Sehr Geehrte Herr/Frau&nbsp;<strong>{{NAME}}&nbsp;</strong>&nbsp;sie haben Ihre legale Aufenthaltsdauer (Visum) in unserem Land überschritten. Wir bedanken uns im Voraus für die Bezahlung Ihrer Starfe bezüglich des Visa- Vergehens.&nbsp;<strong>{{S}}&nbsp;</strong>Für Ihr Land gilt ein&nbsp;<strong>{{FINEDAY}}</strong>Einreisesperrcode:{{TCODE}}{{F}}</th>
    </tr>
  </tbody>
</table>

<br>
<table align="center" width="400" border="0">
  <tbody>
    <tr>
      <td>Düzenleme Tarihi / Ausstellungsdatum:</td>
      <td><strong>{{TODAY}}</strong></td>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: center" scope="col">Yolcu İmzası</th>
      <th style="text-align: center" scope="col">Pasaport Kontrol Polisi</th>
    </tr>
    <tr>
      <th style="text-align: center" scope="row">Unterschrift der Passagiers</th>
      <td style="text-align: center">Beauftragte der Passkontrolbehörde</td>
    </tr>
    <tr>
      <th style="text-align: center" scope="row"><strong>{{NAME}}</strong></th>
      <td style="text-align: center"><strong>{{POLICE}}</strong></td>
    </tr>
    <tr style="text-align: center">
      <th colspan="2" scope="row">&nbsp;</th>
    </tr>
    <tr style="text-align: center">
      <th colspan="2" scope="row">Formu okudum, imzaladım ve&nbsp;kopyasını aldım / İch habe diesen Formblatt gelesen und einen Absatz davon erhalten.</th>
    </tr>
 
    <tr style="text-align: center">
      <th colspan="2" scope="row"></th></tr><tr style="text-align: center"><th colspan="2" scope="row">O N A Y</th>
  </tr>
    <tr style="text-align: center">
      <th colspan="2" scope="row">BESTÄTİGUNG</th>
  </tr>
    <tr style="text-align: center">
      <th colspan="2" scope="row"><strong>{{USER}}</strong></th>
  </tr>
  <tr style="text-align: center"></tr></tbody>
</table>
<table width="800" border="1">
  <tbody>
  <tr>
						<th scope="col" style="width:10"><span style="font-size:10px">1</span></th>
						<td style="text-align:left"><span style="font-size:10px">İkamet Harçları 492 sayılı Harçlar kanununun 6 sayılı tarifesine göre her yıl Maliye Bakanlığınca Belirlenmektedir./</span><span style="font-size: 10px;"> Die Aufenthaltsgebühren werden jedes Jahr vom Finanzministerium gemäß Tarif Nr. 6 des Gebührengesetzes Nr. 492 festgelegt. </span></td>
					</tr>
					<tr>
						<th scope="row" style="width:10"><span style="font-size:10px">2</span></th>
						<td style="text-align:left"><span style="font-size:10px">Hakkınızda konulmuşsa, konulan ülkemize giriş yasağının kaldırılması için Türkiye Cumhuriyeti dış temsilciliklerine özel amaçlı vize için müracaat ediniz./</span><span style="font-size: 10px;"> Wenn es sich um Sie handelt, beantragen Sie bei den ausländischen Vertretern der Republik Türkei ein Sondervisum, um das Einreiseverbot für unser Land aufzuheben.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">3</span></th>
						<td style="text-align:left"><span style="font-size:10px">Vize ihlali nedeniyle hakkınızda uygulanan "N" veya "Ç" tahdit kodlarıyla ilgili , 60(altmış) gün içerisinde İdare mahkemesine başvuru yapmanız gerekmektedir./</span><span style="font-size: 10px;"> Sie müssen innerhalb von 60 (sechzig) Tagen beim Verwaltungsgericht einen Antrag bezüglich der Beschränkungscodes „N“ oder „C“ stellen, die Ihnen aufgrund eines Visumverstoßes auferlegt wurden.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">4</span></th>
						<td style="text-align:left"><span style="font-size:10px">Tahdit iş ve işlemler ile ilgili uygulamalar Göç İdaresi Genel Müdürlüğü''nün 22/07/2020 tarih ve 2020/17 sayılı genelgeye istinaden yapılmaktadır./</span><span style="font-size: 10px;"> Anträge im Zusammenhang mit den Beschränkungsarbeiten und Transaktionen werden gemäß dem Rundschreiben Nr. 2020/17 vom 22.07.2020 der Generaldirektion Migrationsmanagement gestellt.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">5</span></th>
						<td style="text-align:left"><span style="font-size:10px">Vize ihlalinde bulunan yolcularla ilgili yurda giriş yasaklarına ilişkin uygulama 2020/17 sayılı genelgenin Madde 6''nın "A" ve "B" bendlerine istinaden uygulanır./</span><span style="font-size: 10px;"> Der Antrag bezüglich des Verbots des Zutritts zum Wohnheim für Passagiere, die gegen ein Visum verstoßen, wird gemäß den Klauseln „A“ und „B“ des Artikels 6 des Rundschreibens Nr. 2020/17 beantragt.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">6</span></th>
						<td style="text-align:left"><span style="font-size:10px">6458 Sayılı Yabancılar ve Uluslararası Koruma Kanununun "9","15","102" Maddeleri./</span><span style="font-size: 10px;"> Artikel „9“, „15“, „102“ des Gesetzes über Ausländer und internationalen Schutz Nr. 6458.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">7</span></th>
						<td style="text-align:left"><span style="font-size:10px">17/03/2016 tarihli ve 29656 sayılı Yabancılar ve Uluslararası Koruma Kanununun Uygulamasına İlişkin Yönetmeliğin 8. ve 9. Maddeleri./</span><span style="font-size: 10px;"> Artikel 8 und 9 der Verordnung zur Umsetzung des Gesetzes über Ausländer und internationalen Schutz vom 17.03.2016 mit der Nummer 29656.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">8</span></th>
						<td style="text-align:left"><span style="font-size:10px">Göç İdaresi Başkanlığı''nın 06.01.2022 tarih ve V-157 İdari Takip Kodu Görüş Talebi Konulu Yazısı.</span><span style="font-size: 10px;"> Schreiben der Direktion für Migrationsmanagement vom 06.01.2022 zum Verwaltungsverfolgungscode V-157, Bitte um Stellungnahme. </span></td>
					</tr>
  </tbody>
</table>





<p></p><p><br></p><p>{{S1}}

</p><div align="center">
<p align="center"><img src="../img/goc.png" width="200" height="95" class="note-float-left" style="float: left;"></p>
</div>
<table width="800" border="0">
  <tbody>
    <tr>
      <th scope="col"><strong style="font-size: 14px; text-align: center;">Ç Kodlu Giriş Yasağı Kararı Tebliğ Formu<br></strong><strong><span lang="de">Kode Ç -&nbsp;</span><span lang="DE">Notifizierungsformular für den Ausschlussbeschluss</span></strong></th>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><strong style="font-size: 14px">Yabancıya İlişkin Bilgiler -&nbsp;</strong>Informationen über den Ausländer</th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="col">Adı<strong>&nbsp;-&nbsp;</strong>Name</th>
      <th colspan="2" style="font-size: 12px; text-align: left;" scope="col"><strong>{{FIRSTNAME}}</strong></th>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Soyadı&nbsp;<strong>-&nbsp;</strong>Nachname</th>
      <td colspan="2" style="font-size: 12px"><strong>{{LASTNAME}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Baba Adı&nbsp;<strong>-&nbsp;</strong><strong>&nbsp;</strong><span lang="DE">Name des Vaters</span></th>
      <td colspan="2" style="font-size: 12px"><strong>{{FATHERNAME}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Anne Adı&nbsp;<strong>-&nbsp;</strong>Name der Mutter</th>
      <td colspan="2" style="font-size: 12px"><strong>{{MOTHERNAME}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Doğum Tarihi<strong>–&nbsp;</strong>Geburtsdatum</th>
      <td style="font-size: 12px"><strong>{{BIRTHDATE}}</strong></td>
      
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">İletişim Dili&nbsp;<strong>-&nbsp;</strong>Kommunikationssprache/ <span style="font-size: 12px">Uyruğu&nbsp;<strong>-&nbsp;</strong>Nationalität:<strong>{{ORGIN}}</strong></span></th>
      <td colspan="2" style="font-size: 12px"><strong>{{ORGIN}}</strong></td>
    </tr>
    <tr style="text-align: center; font-size: 12px;">
      <th colspan="3" scope="row"><strong>Karar ve Değerlendirmeye İlişkin Bilgiler -</strong>Informationen über die Entscheidung und Beurteilung</th>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Giriş Yasağı Kararı Başlangıç-Bitiş Tarihi<strong>&nbsp;-&nbsp;</strong>Anfangs- und Enddatum des Ausschlussbeschluss</th>
      <td style="font-size: 12px"><strong>{{TODAY}}</strong></td>
      <td style="font-size: 12px"><strong>{{CANENT}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Tahdit Kodu (Einreisesperrcode) :</th>
      <td colspan="2" style="font-size: 12px"><strong>{{TCODE}}</strong></td>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="font-size: 12px" scope="col">* Bu alana giriş yasağı kararının başlangıç tarihi yazılacaktır. –&nbsp;<em>*&nbsp;<span lang="de">Das Anfangs- und Enddatum des Ausschlussbeschluss sollen auf diesen Platz geschrieben werden</span></em> <br>
      ** Bu alana giriş yasağı kararının bitiş tarihi yazılacaktır. –&nbsp;<em>**<span lang="de">&nbsp;Der Enddatum des Ausschlussbeschluss sollen auf diesen Platz geschrieben werden.</span></em></th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align:justify; font-size: 12px;" scope="col">
      <p style="text-align:center;font-size:16px">1-Giriş Yasağı Kararı – <strong><span lang="de">Ausschlussbeschluss</span></strong></p>
      <p> 6458 sayılı Yabancılar ve Uluslararası Koruma Kanunun 9 uncu maddesi uyarınca gerçekleştirilen değerlendirme neticesinde, Göç İdaresi Genel Müdürlüğü / …………. Valiliği (İl Göç İdaresi Müdürlüğü) tarafından hakkınızda giriş yasağı kararı alınmıştır.
        <em><span lang="de">Infolge der Beurteilung, die gemäß Artikel 9 des Ausländer- und internationalen Schutzgesetz durchgeführt ist, ist der Ausschlussbeschluss für Sie Durch die Einwanderungsbehörde / das Gouverneursamt................ (Provinzeinwanderungsbehörde) getroffen.</span></em> Hakkınızda giriş yasağı kararı alınmasına dayanak teşkil eden husus/hususlar sebebiyle;<em><span lang="de">Aufgrund des/der Grunds/Gründen, der/die zu Grunde liegt/liegen, dass der Ausschlussbeschluss für Sie betroffen ist;</span></em>;
        	İkamet izninizin iptali için gerekli işlemler başlatılacaktır. –<em><span lang="de">Notwendige Vorgänge sollen zur Aufhebung ihrer Aufenthaltsbefugnis eingeführt werden.</span></em> Çalışma izninizin iptali için gerekli işlemler başlatılacaktır. –&nbsp;<em><span lang="de">Notwendige Vorgänge sollen zur Aufhebung ihrer Arbeitserlaubnis eingeführt werden.</span></em> Türkiye’ye girişinizin yasaklı olduğu süre içerisinde giriş yapmak istemeniz halinde, Türkiye Cumhuriyeti Dış Temsilciliklerinden amacına uygun (özel meşruhatlı) vize almanız gerekmektedir.
        	<em><u><span lang="DE">Falls Sie während ihres Ausschlussbeschluss in die Türkei einreisen wollen, sollen Sie durch die türkischen Auslandvertretungen ein relevantes (annotiertes) Visum erhalten.</span></u></em> Hakkınızda tahsis edilen giriş yasağı süresinin sona ermesi yüz seksen günde doksan gün kuralının uygulanmasına engel teşkil etmemektedir. Her halükârda vizenin veya vize muafiyetinin Türkiye’de sağladığı kalış süresi, her yüz seksen günde doksan günü geçemez.
        	 <em><span lang="de">Der Ablauf des für Sie betroffenen Ausschlussbeschlusszeit hindern es nicht, die Regel der neunzig Tagen in der einhundertachtzig Tagen durchzuführen. Jedenfalls überschreitet der von dem Visum oder der Visumfreiheit angebotene Aufenthalt in der Türkei nicht die neunzig Tage pro der einhundertachtzig Tagen.</span></em> Hakkınızda alınan giriş yasağı kararının süresi dolmuş olsa dahi idari para cezanızı ödememenizden kaynaklanan ön izin kararına ilişkin hükümler saklıdır. 
        
   	      <em><u><span lang="de">Auch wenn die für Sie betroffene Ausschlussbeschlusszeit abgelaufen ist, sind Alle Bestimmungen in Bezug auf die Entscheidung über die vorläufige Erlaubnis vorbehalten, die dadurch auftreten, dass Sie das Ordnungsgeld nicht bezahlen</span></u></em>. </p>
      <p style="text-align:center;font-size:16px">2-Giriş Yasağı Kararına Karşı Yargı Yoluna Başvuru – <strong><span lang="DE">Rechtmittels – Antrag gegen den Ausschlussbeschluss</span></strong></p>
      <p> Şahsınız veya yasal temsilciniz ya da avukatınız tarafından, giriş yasağı kararına karşı, kararın tebliğinden itibaren 60 (altmış) gün içinde idare mahkemesine başvurulabilir. – <em><span lang="de">Sie oder ihr/e Rechtsvertreter/in oder Rechtsanwalt/in können einen Antrag gegen den Ausschlussbeschluss vor Verwaltungsgericht in der 60 (sechzig) Tagen ab der Ankündigung des Beschluss stellen.</span></em> Mahkemeye başvuran kişi, giriş yasağı kararı veren makama da başvurusunu bildirir. –&nbsp;<em><span lang="de">Derjenige/Diejenige, der/die den Antrag vor dem Gericht stellt, stellt auch den Antrag vor dem Gericht, das den Ausschlussbeschluss trifft.</span></em>.
        Mahkemeye yapılan başvurular giriş yasağı kararını durdurmaz. – <em><span lang="de">Die vor dem Gericht gestellte Anträge heben den Ausschlussbeschluss nicht auf.</span></em>. 
        Bu belge, bir nüshası avukatına/yabancıya/yasal temsilcisine verilmek üzere iki nüsha olarak hazırlanmış olup, hakkında sınır dışı etme kararı alınan yukarıda açık kimliği yazılı yabancıya kendi dilinde/anladığı dilde, {{TODAY}} _ tarihinde ve {{TOTIME}} saatinde yazılı olarak tebliğ edilmiş ve imza altına alınarak bir sureti tebellüğ edene verilmiştir. </p>
      </th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 12px;" scope="col"><a name="_Hlk43631423"><em><span lang="de">Dokument wurde in zweifacher Ausfertigung erstellt, so dass eine Kopie an den Anwalt/Ausländer/gesetzlichen Vertreter übergeben werden kann und der Ausländer, dessen offene Identität oben gegeben ist und über den die Ausweisungsentscheidung ergangen ist wurde schriftlich in seiner eigenen Sprache/Sprache seines Verständnisses am&nbsp;</span></em>{{TODAY}}<em><span lang="de">um&nbsp;</span></em>{{TOTIME}}<em><span lang="de">benachrichtigt und eine Kopie wurde ihm gegen eine Unterschrift übergeben.</span></em></a></th>
    </tr>
  </tbody>
</table>
<p>&nbsp;</p>


<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: center" scope="col"><strong>Tebliğ Eden -</strong><strong><span lang="de">Benachrichtigende Partei</span></strong></th>
      <th style="text-align: center" scope="col"><strong>Tebellüğ Eden -</strong><strong><span lang="de">Benachrichtigter</span></strong></th>
    </tr>
    <tr>
      <th style="text-align: center" scope="row"><strong>{{USER}}</strong></th>
      <td style="text-align: center"><strong>{{NAME}}</strong></td>
    </tr>
  </tbody>
</table>

{{F1}}
<p></p><p><br></p><p></p>
', N'<h3 align="center">VİZE İHLALİ İŞLEM FORMU /<strong>АКТ О НАРУШЕНИИ ВИЗОВОГО РЕЖИМА</strong></h3>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: left" scope="col">Adı Soyadı /Имя; Фамилия</th>
      <th style="text-align: left" scope="col">:<strong>{{NAME}}</strong></th>
    </tr>
    <tr>
      <th style="text-align: left" scope="row"><strong>Uyruğu/ Гражданство</strong></th>
      <td style="text-align: left">:<strong>{{ORGIN}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left" scope="row"><strong>Pasaport No/Номер паспорта</strong></th>
      <td style="text-align: left">:<strong>{{PASSPORT}}</strong></td>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: left; font-size: 10px;" scope="col">*&nbsp;&nbsp;Ülkemize Giriş Tarihiniz ve Vize süreniz /
      &nbsp;&nbsp;&nbsp;&nbsp;Дата прибытия и срок действия визы</th>
      <th scope="col"><strong>:</strong></th>
      <th style="text-align: left" scope="col"><strong>{{EDATE}}</strong></th>
      <th style="text-align: left" scope="col"><strong>{{VDAY}}</strong> Gün / Day</th>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;&nbsp;Ülkemizden çıkış için müracaat tarihiniz
      &nbsp;&nbsp;&nbsp;Дата выезда</th>
      <th scope="row"><strong>:</strong></th>
      <td colspan="2" style="text-align: left"><strong>{{TODAY}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;Tebliğ Edilen, Tahdit Çıkış&nbsp; veya İkamet Teskere Bitiş Tarihi / End date of notified or limitation date or residence permit</th>
      <th scope="row">:</th>
      <td colspan="2" style="text-align: left"><strong>{{SEDATE}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;&nbsp;Ülkemizden çıkış yapmanız gereken tarih<br>
      &nbsp;&nbsp;&nbsp;Окончание срока пребывания.</th>
      <th scope="row"><strong>:</strong></th>
      <td colspan="2" style="text-align: left"><strong>{{SEDATE}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;&nbsp;Vize ihlal süreniz<br>
      &nbsp;&nbsp;&nbsp;&nbsp;Срок нарушения визы</th>
      <th scope="row"><strong>:</strong></th>
      <td colspan="2" style="text-align: left"><strong>{{FINETIME}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;&nbsp;Vize ihlali için ödenecek ücret<br>
      &nbsp;&nbsp;&nbsp;Сумма штрафа</th>
      <th scope="row"><strong>:</strong></th>
      <td style="text-align: left"><strong>{{FINET}}</strong></td>
      <td style="text-align: left"><br></td>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 12px;" scope="col">Sayın<strong>&nbsp;{{NAME}}</strong>&nbsp;Ülkemizdeki yasal kalış sürenizi ihlal etmiş bulunmaktasınız. Vize ihlal ücretinizi şimdi ödediğinizden dolayı teşekkür ederiz.</th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: left; font-size: x-small;" scope="col">&nbsp;уважаемый господин / госпожа&nbsp;<strong>{{NAME}}&nbsp;</strong>&nbsp; YВы нарушили визовой режим страны. Благодарим Вас за то что, Вы оплатили щтраф за нарушение визового режима сейчас<strong>{{S}}&nbsp;</strong>Вам будет запрещен въезд в нашу страну за<strong>{{FINEDAY}}</strong>days&nbsp; &nbsp;Код запрета на въезд:{{TCODE}}{{F}}</th>
    </tr>
  </tbody>
</table>

<br>
<table align="center" width="400" border="0">
  <tbody>
    <tr>
      <td>Düzenleme Tarihi / Дата :</td>
      <td><strong>{{TODAY}}</strong></td>
    </tr>
  </tbody>
</table>
<br>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: center" scope="col">Yolcu İmzası</th>
      <th style="text-align: center" scope="col">Pasaport Kontrol Polisi</th>
    </tr>
    <tr>
      <th style="text-align: center" scope="row">Подпись пассажира</th>
      <td style="text-align: center">Орган пограничного контроля</td>
    </tr>
    <tr>
      <th style="text-align: center" scope="row"><strong>{{NAME}}</strong></th>
      <td style="text-align: center"><strong>{{POLICE}}</strong></td>
    </tr>
    <tr style="text-align: center">
      <th colspan="2" scope="row">&nbsp;</th>
    </tr>
    <tr style="text-align: center">
      <th colspan="2" scope="row">Formu okudum, imzaladım ve&nbsp;kopyasını aldım /С текстом акта ознакомлен, подписался, получил копию.</th>
    </tr>
 
    <tr style="text-align: center">
      <th colspan="2" scope="row">&nbsp;</th>
    </tr>
    <tr style="text-align: center">
      <th colspan="2" scope="row">O N A Y</th>
  </tr>
    <tr style="text-align: center">
      <th colspan="2" scope="row">ПОТВЕРЖДЕНИЕ</th>
  </tr>
    <tr style="text-align: center">
      <th colspan="2" scope="row"><strong>{{USER}}</strong></th>
  </tr>
  
</tbody></table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col">YASAL DAYANAKLAR</th>
    </tr>
  </tbody>
</table><table width="800" border="1">
  <tbody>
  <tr>
      <th style="width:10" scope="col">1</th>
      <td style="font-size:9px; text-align:left ">İkamet Harçları 492 sayılı Harçlar kanununun 6 sayılı tarifesine göre her yıl Maliye Bakanlığınca Belirlenmektedir./Суммы подлежащие оплате за пребывание в стране определяются ежегодно Министерством Финансов на основании закона № 492 о взносах и пошлинах, тариф № 6.</td>
    </tr>
					 <tr>
      <th style="width:10" scope="row">2</th>
      <td style="font-size:9px; text-align:left ">Hakkınızda konulmuşsa, konulan ülkemize giriş yasağının kaldırılması için Türkiye Cumhuriyeti dış temsilciliklerine özel amaçlı vize için müracaat ediniz./Для того, чтобы снять запрет на въезд в страну, обращайтесь для получения особой визы в иностранные представительства Турецкой Республики.</td>
    </tr>
					<tr>
      <th style="width:20" scope="row">3</th>
      <td style="font-size:9px; text-align:left ">Vize ihlali nedeniyle hakkınızda uygulanan "N" veya "Ç" tahdit kodlarıyla ilgili , 60(altmış) gün içerisinde İdare mahkemesine başvuru yapmanız gerekmektedir./Вы должны обратиться в административный суд в течение 60 (шестидесяти) дней в отношении кодов ограничений «N» или «C», примененных к вам в связи с нарушением визы.</td>
    </tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">4</span></th>
						<td style="text-align:left"><span style="font-size:10px">Tahdit iş ve işlemler ile ilgili uygulamalar Göç İdaresi Genel Müdürlüğü''nün 22/07/2020 tarih ve 2020/17 sayılı genelgeye istinaden yapılmaktadır./</span><span style="font-size: 10px;"> Ограничения, связанные с работой и действиями, относятся к приложениям, согласно общим распоряжением Генерального управления по миграции от 22.07.2020 г. № 2020/17.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">5</span></th>
						<td style="text-align:left"><span style="font-size:10px">Vize ihlalinde bulunan yolcularla ilgili yurda giriş yasaklarına ilişkin uygulama 2020/17 sayılı genelgenin Madde 6''nın "A" ve "B" bendlerine istinaden uygulanır./</span><span style="font-size: 10px;"> Применение запретов на въезд в страну для пассажиров, нарушивших визовые правила, осуществляется в соответствии с пунктами "А" и "Б" статьи 6 общего распоряжения под номером 2020/17 согласно правовым нормам.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">6</span></th>
						<td style="text-align:left"><span style="font-size:10px">6458 Sayılı Yabancılar ve Uluslararası Koruma Kanununun "9","15","102" Maddeleri./</span><span style="font-size: 10px;">Закон № 6458 "О иностранцах и международной защите", Статьи "9", "15" и "102" в соответствии с законом.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">7</span></th>
						<td style="text-align:left"><span style="font-size:10px">17/03/2016 tarihli ve 29656 sayılı Yabancılar ve Uluslararası Koruma Kanununun Uygulamasına İlişkin Yönetmeliğin 8. ve 9. Maddeleri./</span><span style="font-size: 10px;"> Пункты 8 и 9 Положения о применении Закона о иностранцах и международной защите № 29656 от 17.03.2016 года.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">8</span></th>
						<td style="text-align:left"><span style="font-size:10px">Göç İdaresi Başkanlığı''nın 06.01.2022 tarih ve V-157 İdari Takip Kodu Görüş Talebi Konulu Yazısı.</span><span style="font-size: 10px;"> Письмо Миграционной службы от 06.01.2022 года с номером V-157 по Запросу о Мнении о Правоприменении Административного Кодекса.

 </span></td>
					</tr>
  </tbody>
</table>



<p></p><p><br></p><p>{{S1}}<br></p><center><br>
<div align="center">
<p align="center"><img src="../img/goc.png" width="200" height="95" class="note-float-left" style="float: left;"></p>
</div>
<table width="800" border="0">
  <tbody>
    <tr>
      <th scope="col"><strong style="font-size: 14px; text-align: center;">Ç Kodlu Giriş Yasağı Kararı Tebliğ Formu<br></strong><strong>Форма-уведомление решения о запрете на въезд с кодом Ç</strong></th>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><strong style="font-size: 14px">Yabancıya İlişkin Bilgiler -&nbsp;</strong>Information on the Foreigner</th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="col">Adı<strong>&nbsp;-&nbsp;</strong>Имя</th>
      <th colspan="2" style="font-size: 12px; text-align: left;" scope="col"><strong>{{FIRSTNAME}}</strong></th>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Soyadı&nbsp;<strong>-&nbsp;</strong>Фамилия</th>
      <td colspan="2" style="font-size: 12px"><strong>{{LASTNAME}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Baba Adı&nbsp;<strong>-&nbsp;</strong><strong>&nbsp;</strong>Имя отца (отчество)</th>
      <td colspan="2" style="font-size: 12px"><strong>{{FATHERNAME}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Anne Adı&nbsp;<strong>-&nbsp;</strong>Имя матери</th>
      <td colspan="2" style="font-size: 12px"><strong>{{MOTHERNAME}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Doğum Tarihi<strong>–&nbsp;</strong><strong>Дата рождения</strong></th>
      <td style="font-size: 12px"><strong>{{BIRTHDATE}}</strong></td>
      
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">İletişim Dili&nbsp;<strong>-&nbsp;</strong>Язык для коммуникации/ <span style="font-size: 12px">Uyruğu&nbsp;<strong>-&nbsp;</strong>Гражданство:<strong>{{ORGIN}}</strong></span></th>
      <td colspan="2" style="font-size: 12px"><strong>{{ORGIN}}</strong></td>
    </tr>
    <tr style="text-align: center; font-size: 12px;">
      <th colspan="3" scope="row"><strong>Karar ve Değerlendirmeye İlişkin Bilgiler -</strong>Информация о решении и рассмотрении вопроса</th>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Giriş Yasağı Kararı Başlangıç-Bitiş Tarihi<strong>&nbsp;-&nbsp;</strong>Дата начала-окончания запрета на въезд</th>
      <td style="font-size: 12px"><strong>{{TODAY}}</strong></td>
      <td style="font-size: 12px"><strong>{{CANENT}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Tahdit Kodu (Ban Code) :</th>
      <td colspan="2" style="font-size: 12px"><strong>{{TCODE}}</strong></td>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="font-size: 12px" scope="col">* Bu alana giriş yasağı kararının başlangıç tarihi yazılacaktır. –&nbsp;<em>*В этом поле будет указана дата начала запрета на въезд</em> <br>
      ** Bu alana giriş yasağı kararının bitiş tarihi yazılacaktır. –&nbsp;<em>**<span lang="de">&nbsp;В этом поле будет указана дата окончания запрета на въезд</span></em></th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align:justify; font-size: 12px;" scope="col">
      <p style="text-align:center;font-size:16px">1-Giriş Yasağı Kararı –<strong>Решение о запрете на въезд</strong></p>
      <p> 6458 sayılı Yabancılar ve Uluslararası Koruma Kanunun 9 uncu maddesi uyarınca gerçekleştirilen değerlendirme neticesinde, Göç İdaresi Genel Müdürlüğü / …………. Valiliği (İl Göç İdaresi Müdürlüğü) tarafından hakkınızda giriş yasağı kararı alınmıştır.По результатам рассмотрения вопроса в соответствии со статьей 9 Закона&nbsp; &nbsp;№6458 Об иностранцах и международной защите, Губернаторством&nbsp; (Управлением по вопросам миграции провинции) ANTALYA в отношении Вас&nbsp; было принято решение о запрете на въезд.<em> </em>Hakkınızda giriş yasağı kararı alınmasına dayanak teşkil eden husus/hususlar sebebiyle;&nbsp;На основании обстоятельства/обстоятельств, которые являются основой для&nbsp; &nbsp; &nbsp; &nbsp; принятия в отношении Вас решения о запрете на въезд
       	  İkamet izninizin iptali için gerekli işlemler başlatılacaktır. –<em>Будут начаты необходимые процедуры по аннулированию Вашего разрешения&nbsp; &nbsp;на проживание.</em>Çalışma izninizin iptali için gerekli işlemler başlatılacaktır. –<em>Будут начаты необходимые процедуры по аннулированию&nbsp; Вашего разрешения на работу</em>. Türkiye’ye girişinizin yasaklı olduğu süre içerisinde giriş yapmak istemeniz halinde, Türkiye Cumhuriyeti Dış Temsilciliklerinden amacına uygun (özel meşruhatlı) vize almanız gerekmektedir.Если вы хотите совершить въезд в Турцию в период действия Вашего&nbsp; &nbsp; запрета на въезд, предварительно Вы обязаны получить визу,&nbsp; соответствующую цели приезда (с особыми примечаниями) в иностранном&nbsp; &nbsp; представительстве Турецкой Республики<u><em> . </em></u>Hakkınızda tahsis edilen giriş yasağı süresinin sona ermesi yüz seksen günde doksan gün kuralının uygulanmasına engel teşkil etmemektedir. Her halükârda vizenin veya vize muafiyetinin Türkiye’de sağladığı kalış süresi, her yüz seksen günde doksan günü geçemez.Прекращение назначенного вам запрета на въезд не препятствует&nbsp; &nbsp; &nbsp; &nbsp; применению правила пребывания девяноста из ста восьмидесяти дней. В&nbsp; &nbsp; любом случае срок пребывания в Турции, предусмотренный действием визы&nbsp; &nbsp; &nbsp; &nbsp; или визового освобождения, не должен превышать девяноста из ста&nbsp; восьмидесяти дней».</p>
      <p>Hakkınızda alınan giriş yasağı kararının süresi dolmuş olsa dahi idari para cezanızı ödememenizden kaynaklanan ön izin kararına ilişkin hükümler saklıdır.<em><u>Даже если срок действия решения о запрете на въезд в отношении вас&nbsp;&nbsp; истек, положения, касающиеся решения о предварительном разрешении,&nbsp; &nbsp;связанного с неуплатой Вами административного штрафа, сохраняются.</u></em></p>
      <p style="text-align:center;font-size:16px">2-Giriş Yasağı Kararına Karşı Yargı Yoluna Başvuru –<span style="font-size: 12px">Ходатайство об отмене в судебном порядке решения о запрете на&nbsp; &nbsp; &nbsp; &nbsp; въезд</span></p>
      <p> Şahsınız veya yasal temsilciniz ya da avukatınız tarafından, giriş yasağı kararına karşı, kararın tebliğinden itibaren 60 (altmış) gün içinde idare mahkemesine başvurulabilir. –<em>Вы лично, либо через вашего законного представителя, либо вашего&nbsp; &nbsp; &nbsp; &nbsp; адвоката, можете обратиться в административный суд с обжалованием&nbsp;&nbsp; &nbsp; &nbsp; &nbsp; вынесенного в отношении Вас решения о запрете на въезд в течение 60&nbsp; &nbsp; &nbsp; &nbsp; (шестидесяти) дней после получения уведомления о принятом решении. </em>Mahkemeye yapılan başvurular giriş yasağı kararını durdurmaz. –Обращение в суд не останавливает действие решения о запрете на въезд.. 
        Bu belge, bir nüshası avukatına/yabancıya/yasal temsilcisine verilmek üzere iki nüsha olarak hazırlanmış olup, hakkında sınır dışı etme kararı alınan yukarıda açık kimliği yazılı yabancıya kendi dilinde/anladığı dilde, {{TODAY}} _ tarihinde ve {{TOTIME}} saatinde yazılı olarak tebliğ edilmiş ve imza altına alınarak bir sureti tebellüğ edene verilmiştir. </p>
      </th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 12px;" scope="col"><a name="_Hlk43631423">Данный документ, с целью вручения одного экземпляра иностранному&nbsp; гражданину/ его адвокату/ его законному представителю, составлен в двух&nbsp; &nbsp;экземплярах, и{{TODAY}}&nbsp;_&nbsp;&nbsp;числа в{{TOTIME}}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;был передан&nbsp; &nbsp;иностранному гражданину, в отношении которого принято решение о&nbsp;депортации и идентификационные данные которого указаны выше, в&nbsp;&nbsp;письменном виде на родном/понятном ему языке; один экземпляр данного&nbsp;&nbsp; документа был вручен уведомляемому под подпись.</a></th>
    </tr>
  </tbody>
</table>
<p>&nbsp;</p>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: center" scope="col"><strong>Tebliğ Eden- </strong><strong>Уведомляющий</strong></th>
      <th style="text-align: center" scope="col"><strong>Tebellüğ Eden -</strong><strong>Уведомляемый</strong></th>
    </tr>
    <tr>
      <th style="text-align: center" scope="row"><strong>{{USER}}</strong></th>
      <td style="text-align: center"><strong>{{NAME}}</strong></td>
    </tr>
  </tbody>
</table>

{{F1}}</center>

', N'<h3 align="center">VİZE İHLALİ İŞLEM FORMU /VISA VIOLATION FORM</h3>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: left" scope="col">Adı Soyadı /Name/Surname</th>
      <th style="text-align: left" scope="col">:<strong>{{NAME}}</strong></th>
    </tr>
    <tr>
      <th style="text-align: left" scope="row">Uyruğu/ Nationality</th>
      <td style="text-align: left">:<strong>{{ORGIN}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left" scope="row">Pasaport No/Passport No</th>
      <td style="text-align: left">:<strong>{{PASSPORT}}</strong></td>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: left; font-size: 10px;" scope="col">*&nbsp;&nbsp;Ülkemize Giriş Tarihiniz ve Vize süreniz<br>
      &nbsp;&nbsp;&nbsp;&nbsp; Date of entry into country and visa validity</th>
      <th scope="col"><strong>:</strong></th>
      <th style="text-align: left" scope="col"><strong>{{EDATE}}</strong></th>
      <th style="text-align: left" scope="col"><strong>{{VDAY}}</strong> Gün / Day</th>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;&nbsp;Ülkemizden çıkış için müracaat tarihiniz<br>
      &nbsp;&nbsp;&nbsp;The date that you are applying to leave the country</th>
      <th scope="row"><strong>:</strong></th>
      <td colspan="2" style="text-align: left"><strong>{{TODAY}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;Tebliğ Edilen, Tahdit Çıkış&nbsp; veya İkamet Teskere Bitiş Tarihi / End date of notified or limitation date or residence permit</th>
      <th scope="row">:</th>
      <td colspan="2" style="text-align: left"><strong>{{SEDATE}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;&nbsp;Ülkemizden çıkış yapmanız gereken tarih<br>
      &nbsp;&nbsp;&nbsp;The date that you were meant to leave the country</th>
      <th scope="row"><strong>:</strong></th>
      <td colspan="2" style="text-align: left"><strong>{{SEDATE}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;&nbsp;Vize ihlal süreniz<br>
      &nbsp;&nbsp;&nbsp;Visa violation period</th>
      <th scope="row"><strong>:</strong></th>
      <td colspan="2" style="text-align: left"><strong>{{FINETIME}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;&nbsp;Vize ihlali için ödenecek ücret<br>
      &nbsp;&nbsp;&nbsp;Penalty for visa violation</th>
      <th scope="row"><strong>:</strong></th>
      <td style="text-align: left"><strong>{{FINET}}</strong></td>
      <td style="text-align: left"><span style="font-weight: 700 !important;"><font size="2">TL</font></span><br></td>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 12px;" scope="col">Sayın<strong>&nbsp;{{NAME}}</strong>&nbsp;Ülkemizdeki yasal kalış sürenizi ihlal etmiş bulunmaktasınız. Vize ihlal ücretinizi şimdi ödediğinizden dolayı teşekkür ederiz.</th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: left; font-size: x-small;" scope="col">Dear Madame/Sir&nbsp;<strong>{{NAME}}&nbsp;</strong>&nbsp; You have exceeded the legal duration of stay in our country. Thank you in advance for paying the penalty of your visa-offence.&nbsp;<strong>{{S}}&nbsp;</strong>You will be banned from entering our country for&nbsp;<strong>{{FINEDAY}}</strong>days Entry Ban Code:{{TCODE}}{{F}}</th>
    </tr>
  </tbody>
</table>

<br>
<table align="center" width="400" border="0">
  <tbody>
    <tr>
      <td>Düzenleme Tarihi / Dated On:</td>
      <td><strong>{{TODAY}}</strong></td>
    </tr>
  </tbody>
</table>
<br>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: center" scope="col">Yolcu İmzası</th>
      <th style="text-align: center" scope="col">Pasaport Kontrol Polisi</th>
    </tr>
    <tr>
      <th style="text-align: center" scope="row">Signature of passenger</th>
      <td style="text-align: center">Passport police officer</td>
    </tr>
    <tr>
      <th style="text-align: center" scope="row"><strong>{{NAME}}</strong></th>
      <td style="text-align: center"><strong>{{POLICE}}</strong></td>
    </tr>
    <tr style="text-align: center">
      <th colspan="2" scope="row">&nbsp;</th>
    </tr>
    <tr style="text-align: center">
      <th colspan="2" scope="row">Formu okudum, imzaladım ve&nbsp;kopyasını aldım / I have read the form, signed it,and have a copy of the form</th>
    </tr>
 
    <tr style="text-align: center">
      <th colspan="2" scope="row">&nbsp;</th>
    </tr>
    <tr style="text-align: center">
      <th colspan="2" scope="row">O N A Y</th>
  </tr>
    <tr style="text-align: center">
      <th colspan="2" scope="row">APPROVAL</th>
  </tr>
    <tr style="text-align: center">
      <th colspan="2" scope="row"><strong>{{USER}}</strong></th>
  </tr>
  <tr style="text-align: center"></tr></tbody>
</table>

<table width="800" border="1">
  <tbody>
  <tr>
						<th scope="col" style="width:10"><span style="font-size:10px">1</span></th>
						<td style="text-align:left"><span style="font-size:10px">İkamet Harçları 492 sayılı Harçlar kanununun 6 sayılı tarifesine göre her yıl Maliye Bakanlığınca Belirlenmektedir./</span><span style="font-size: 10px;">Residence Fees are determined by the Ministry of Finance every year according to the tariff no. 6 of the Fees Law No. 492.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:10"><span style="font-size:10px">2</span></th>
						<td style="text-align:left"><span style="font-size:10px">Hakkınızda konulmuşsa, konulan ülkemize giriş yasağının kaldırılması için Türkiye Cumhuriyeti dış temsilciliklerine özel amaçlı vize için müracaat ediniz./</span><span style="font-size: 10px;">If it has been placed about you, apply for a special purpose visa to the foreign representatives of the Republic of Turkey in order to lift the ban on entry to our country.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">3</span></th>
						<td style="text-align:left"><span style="font-size:10px">Vize ihlali nedeniyle hakkınızda uygulanan "N" veya "Ç" tahdit kodlarıyla ilgili , 60(altmış) gün içerisinde İdare mahkemesine başvuru yapmanız gerekmektedir./</span><span style="font-size: 10px;">You must apply to the Administrative Court within 60 (sixty) days regarding the "N" or "C" restriction codes applied to you due to visa violation.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">4</span></th>
						<td style="text-align:left"><span style="font-size:10px">Tahdit iş ve işlemler ile ilgili uygulamalar Göç İdaresi Genel Müdürlüğü''nün 22/07/2020 tarih ve 2020/17 sayılı genelgeye istinaden yapılmaktadır./</span><span style="font-size: 10px;">Applications related to the restriction works and transactions are made in accordance with the circular numbered 2020/17 dated 22/07/2020 of the General Directorate of Migration Management.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">5</span></th>
						<td style="text-align:left"><span style="font-size:10px">Vize ihlalinde bulunan yolcularla ilgili yurda giriş yasaklarına ilişkin uygulama 2020/17 sayılı genelgenin Madde 6''nın "A" ve "B" bendlerine istinaden uygulanır./</span><span style="font-size: 10px;">Implementation of bans on entry to the dormitory for passengers violating a visa is applied pursuant to subparagraphs "A" and "B" of Article 6 of the circular numbered 2020/17.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">6</span></th>
						<td style="text-align:left"><span style="font-size:10px">6458 Sayılı Yabancılar ve Uluslararası Koruma Kanununun "9","15","102" Maddeleri./</span><span style="font-size: 10px;">Articles "9","15","102" of the Foreigners and International Protection Law No. 6458</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">7</span></th>
						<td style="text-align:left"><span style="font-size:10px">17/03/2016 tarihli ve 29656 sayılı Yabancılar ve Uluslararası Koruma Kanununun Uygulamasına İlişkin Yönetmeliğin 8. ve 9. Maddeleri./</span><span style="font-size: 10px;">Articles 8 and 9 of the Regulation on the Implementation of the Law on Foreigners and International Protection dated 17/03/2016 and numbered 29656</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">8</span></th>
						<td style="text-align:left"><span style="font-size:10px">Göç İdaresi Başkanlığı''nın 06.01.2022 tarih ve V-157 İdari Takip Kodu Görüş Talebi Konulu Yazısı.</span><span style="font-size: 10px;">Letter of the Directorate of Migration Management, dated 06.01.2022, on V-157 Administrative Tracking Code, Request for Opinion</span></td>
					</tr>
  </tbody>
</table>

<br>{{S1}}<center><br>
<div align="center">
<p align="center"><img src="../img/goc.png" width="200" height="95" class="note-float-left" style="float: left;"></p>
</div>
<table width="800" border="0">
  <tbody>
    <tr>
      <th scope="col"><strong style="font-size: 14px; text-align: center;">Ç Kodlu Giriş Yasağı Kararı Tebliğ Formu<br>
      Code Ç – Entry Ban Notification Form</strong></th>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><strong style="font-size: 14px">Yabancıya İlişkin Bilgiler -&nbsp;</strong>Information on the Foreigner</th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="col">Adı<strong>&nbsp;-&nbsp;</strong>Name</th>
      <th colspan="2" style="font-size: 12px; text-align: left;" scope="col"><strong>{{FIRSTNAME}}</strong></th>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Soyadı&nbsp;<strong>-&nbsp;</strong>Surname</th>
      <td colspan="2" style="font-size: 12px"><strong>{{LASTNAME}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Baba Adı&nbsp;<strong>-&nbsp;</strong>Father’s Name</th>
      <td colspan="2" style="font-size: 12px"><strong>{{FATHERNAME}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Anne Adı&nbsp;<strong>-&nbsp;</strong>Mother’s Name</th>
      <td colspan="2" style="font-size: 12px"><strong>{{MOTHERNAME}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Doğum Tarihi<strong>–&nbsp;</strong>Date of Birth</th>
      <td style="font-size: 12px"><strong>{{BIRTHDATE}}</strong></td>
      <td style="font-size: 12px">Uyruğu&nbsp;<strong>-&nbsp;</strong>Nationality</td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">İletişim Dili&nbsp;<strong>-&nbsp;</strong>Communication Language</th>
      <td colspan="2" style="font-size: 12px"><strong>{{ORGIN}}</strong></td>
    </tr>
    <tr style="text-align: center; font-size: 12px;">
      <th colspan="3" scope="row"><strong>Karar ve Değerlendirmeye İlişkin Bilgiler -&nbsp;</strong>Information about the Decision and Evaluation</th>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Giriş Yasağı Kararı Başlangıç-Bitiş Tarihi<strong>&nbsp;-&nbsp;</strong>Start and End Date of Entry Ban Decision</th>
      <td style="font-size: 12px"><strong>{{TODAY}}</strong></td>
      <td style="font-size: 12px"><strong>{{CANENT}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Tahdit Kodu (Ban Code) :</th>
      <td colspan="2" style="font-size: 12px"><strong>{{TCODE}}</strong></td>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="font-size: 12px" scope="col">* Bu alana giriş yasağı kararının başlangıç tarihi yazılacaktır. –&nbsp;<em>*&nbsp;Enter start date of entry ban decision to this field.</em> <br>
      ** Bu alana giriş yasağı kararının bitiş tarihi yazılacaktır. –&nbsp;<em>**&nbsp;Enter end date of entry ban decision to this field.</em></th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align:justify; font-size: 12px;" scope="col">
      <p style="text-align:center;font-size:16px">1-Giriş Yasağı Kararı – Entry Ban Decision</p>
      <p> 6458 sayılı Yabancılar ve Uluslararası Koruma Kanunun 9 uncu maddesi uyarınca gerçekleştirilen değerlendirme neticesinde, Göç İdaresi Genel Müdürlüğü / …………. Valiliği (İl Göç İdaresi Müdürlüğü) tarafından hakkınızda giriş yasağı kararı alınmıştır.
        As a result of the evaluation conducted in accordance with the Article 9 of the Law on Foreigners and International Protection numbered 6458, Directorate General of Migration Management / Governorship of …………. (Provincial Directorate of Migration Management) has resolved to impose an entry ban on you. 
        	Hakkınızda giriş yasağı kararı alınmasına dayanak teşkil eden husus/hususlar sebebiyle; 
        	Based on the particular/particulars constituting grounds for imposing an entry ban on you;
        	İkamet izninizin iptali için gerekli işlemler başlatılacaktır. – Respective procedures will be commenced for cancelling your residence permit.
        	 Çalışma izninizin iptali için gerekli işlemler başlatılacaktır. – Respective procedures will be commenced for cancelling your work permit. 
        
        	Türkiye’ye girişinizin yasaklı olduğu süre içerisinde giriş yapmak istemeniz halinde, Türkiye Cumhuriyeti Dış Temsilciliklerinden amacına uygun (özel meşruhatlı) vize almanız gerekmektedir.
        	If you wish to enter Turkey during the period of your entry ban, you are required to obtain the relevant visa (annotated visa) from Foreign Representative Offices of the Republic of Turkey.  
        	Hakkınızda tahsis edilen giriş yasağı süresinin sona ermesi yüz seksen günde doksan gün kuralının uygulanmasına engel teşkil etmemektedir. Her halükârda vizenin veya vize muafiyetinin Türkiye’de sağladığı kalış süresi, her yüz seksen günde doksan günü geçemez.
        	 Note that the expiration of the entry ban period imposed on you does not constitute any impediment for implementing the rule of ninety days in one hundred and eighty days. In any case, the duration of stay in Turkey granted by the visa or the visa exemption cannot exceed ninety days in every one hundred and eighty days.
        
        	Hakkınızda alınan giriş yasağı kararının süresi dolmuş olsa dahi idari para cezanızı ödememenizden kaynaklanan ön izin kararına ilişkin hükümler saklıdır. 
        
        	All provisions with respect to the preliminary permission decision stemming from the non-payment of your administrative fine are reserved regardless of the expiration of the entry ban decision imposed on you.
        </p>
      <p style="text-align:center;font-size:16px">2-Giriş Yasağı Kararına Karşı Yargı Yoluna Başvuru – Resort to the Jurisdiction Against the Entry Ban Decision</p>
      <p> Şahsınız veya yasal temsilciniz ya da avukatınız tarafından, giriş yasağı kararına karşı, kararın tebliğinden itibaren 60 (altmış) gün içinde idare mahkemesine başvurulabilir. – You or your legal representative or lawyer may appeal against the entry ban decision to the Administrative Court within 60 (sixty) days from the notification of the decision.
        Mahkemeye başvuran kişi, giriş yasağı kararı veren makama da başvurusunu bildirir. – The applicant who applied to the Court also notifies the authority of the entry ban decision.
        Mahkemeye yapılan başvurular giriş yasağı kararını durdurmaz. – Applications made to the Court does not suspend the entry ban decision. 
        Bu belge, bir nüshası avukatına/yabancıya/yasal temsilcisine verilmek üzere iki nüsha olarak hazırlanmış olup, hakkında sınır dışı etme kararı alınan yukarıda açık kimliği yazılı yabancıya kendi dilinde/anladığı dilde, {{TODAY}} _ tarihinde ve {{TOTIME}} saatinde yazılı olarak tebliğ edilmiş ve imza altına alınarak bir sureti tebellüğ edene verilmiştir. </p>
      </th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 12px;" scope="col"><a name="_Hlk43631423"><em>This document has been issued in duplicate so a copy can be given to the lawyer/foreigner/legal representative and the foreigner, whose open identity is given above and upon whom the deportation decision has been imposed, has been notified in writing in his own language/language of comprehension on&nbsp;<strong>{{TODAY}}</strong>&nbsp;&nbsp;at&nbsp;<strong>{{TOTIME}}</strong>&nbsp;and one copy has been given to the notified with a signature.</em></a></th>
    </tr>
  </tbody>
</table>
<p>&nbsp;</p>


<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: center" scope="col"><strong>Tebliğ Eden -</strong><strong>Notifying Party</strong></th>
      <th style="text-align: center" scope="col"><strong>Tebellüğ Eden -</strong><strong>Notified</strong></th>
    </tr>
    <tr>
      <th style="text-align: center" scope="row"><strong>{{USER}}</strong></th>
      <td style="text-align: center"><strong>{{NAME}}</strong></td>
    </tr>
  </tbody>
</table>

{{F1}}</center>
', N'<h3 align="center">VİZE İHLALİ İŞLEM FORMU /VISA VIOLATION FORM</h3>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: left" scope="col">Adı Soyadı /Name/Surname</th>
      <th style="text-align: left" scope="col">:<strong>{{NAME}}</strong></th>
    </tr>
    <tr>
      <th style="text-align: left" scope="row">Uyruğu/ Nationality</th>
      <td style="text-align: left">:<strong>{{ORGIN}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left" scope="row">Pasaport No/Passport No</th>
      <td style="text-align: left">:<strong>{{PASSPORT}}</strong></td>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: left; font-size: 10px;" scope="col">*&nbsp;&nbsp;Ülkemize Giriş Tarihiniz ve Vize süreniz<br>
      &nbsp;&nbsp;&nbsp;&nbsp; Date of entry into country and visa validity</th>
      <th scope="col"><strong>:</strong></th>
      <th style="text-align: left" scope="col"><strong>{{EDATE}}</strong></th>
      <th style="text-align: left" scope="col"><strong>{{VDAY}}</strong> Gün / Day</th>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;&nbsp;Ülkemizden çıkış için müracaat tarihiniz<br>
      &nbsp;&nbsp;&nbsp;The date that you are applying to leave the country</th>
      <th scope="row"><strong>:</strong></th>
      <td colspan="2" style="text-align: left"><strong>{{TODAY}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;Tebliğ Edilen, Tahdit Çıkış&nbsp; veya İkamet Teskere Bitiş Tarihi / End date of notified or limitation date or residence permit</th>
      <th scope="row">:</th>
      <td colspan="2" style="text-align: left"><strong>{{SEDATE}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;&nbsp;Ülkemizden çıkış yapmanız gereken tarih<br>
      &nbsp;&nbsp;&nbsp;The date that you were meant to leave the country</th>
      <th scope="row"><strong>:</strong></th>
      <td colspan="2" style="text-align: left"><strong>{{SEDATE}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;&nbsp;Vize ihlal süreniz<br>
      &nbsp;&nbsp;&nbsp;Visa violation period</th>
      <th scope="row"><strong>:</strong></th>
      <td colspan="2" style="text-align: left"><strong>{{FINETIME}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;&nbsp;Vize ihlali için ödenecek ücret<br>
      &nbsp;&nbsp;&nbsp;Penalty for visa violation</th>
      <th scope="row"><strong>:</strong></th>
      <td style="text-align: left"><strong>{{FINET}}</strong></td>
      <td style="text-align: left"><span style="font-weight: 700 !important;"><font size="2">TL</font></span><br></td>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 12px;" scope="col">Sayın<strong>&nbsp;{{NAME}}</strong>&nbsp;Ülkemizdeki yasal kalış sürenizi ihlal etmiş bulunmaktasınız. Vize ihlal ücretinizi şimdi ödediğinizden dolayı teşekkür ederiz.</th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: left; font-size: x-small;" scope="col">Dear Madame/Sir&nbsp;<strong>{{NAME}}&nbsp;</strong>&nbsp; You have exceeded the legal duration of stay in our country. Thank you in advance for paying the penalty of your visa-offence.&nbsp;<strong>{{S}}&nbsp;</strong>You will be banned from entering our country for&nbsp;<strong>{{FINEDAY}}</strong>days Entry Ban Code:{{TCODE}}{{F}}</th>
    </tr>
  </tbody>
</table>

<br>
<table align="center" width="400" border="0">
  <tbody>
    <tr>
      <td>Düzenleme Tarihi / Dated On:</td>
      <td><strong>{{TODAY}}</strong></td>
    </tr>
  </tbody>
</table>
<br>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: center" scope="col">Yolcu İmzası</th>
      <th style="text-align: center" scope="col">Pasaport Kontrol Polisi</th>
    </tr>
    <tr>
      <th style="text-align: center" scope="row">Signature of passenger</th>
      <td style="text-align: center">Passport police officer</td>
    </tr>
    <tr>
      <th style="text-align: center" scope="row"><strong>{{NAME}}</strong></th>
      <td style="text-align: center"><strong>{{POLICE}}</strong></td>
    </tr>
    <tr style="text-align: center">
      <th colspan="2" scope="row">&nbsp;</th>
    </tr>
    <tr style="text-align: center">
      <th colspan="2" scope="row">Formu okudum, imzaladım ve&nbsp;kopyasını aldım / I have read the form, signed it,and have a copy of the form</th>
    </tr>
 
    <tr style="text-align: center">
      <th colspan="2" scope="row">&nbsp;</th>
    </tr>
    <tr style="text-align: center">
      <th colspan="2" scope="row">O N A Y</th>
  </tr>
    <tr style="text-align: center">
      <th colspan="2" scope="row">APPROVAL</th>
  </tr>
    <tr><td colspan="2" scope="row"></td></tr><tr style="text-align: center">
      <th colspan="2" scope="row"><p><strong>{{USER}}</strong></p></th></tr></tbody></table>
<table width="800" border="1">
  <tbody>
  <tr>
						<th scope="col" style="width:10"><span style="font-size:10px">1</span></th>
						<td style="text-align:left"><span style="font-size:10px">İkamet Harçları 492 sayılı Harçlar kanununun 6 sayılı tarifesine göre her yıl Maliye Bakanlığınca Belirlenmektedir./</span><span style="font-size: 10px;">Residence Fees are determined by the Ministry of Finance every year according to the tariff no. 6 of the Fees Law No. 492.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:10"><span style="font-size:10px">2</span></th>
						<td style="text-align:left"><span style="font-size:10px">Hakkınızda konulmuşsa, konulan ülkemize giriş yasağının kaldırılması için Türkiye Cumhuriyeti dış temsilciliklerine özel amaçlı vize için müracaat ediniz./</span><span style="font-size: 10px;">If it has been placed about you, apply for a special purpose visa to the foreign representatives of the Republic of Turkey in order to lift the ban on entry to our country.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">3</span></th>
						<td style="text-align:left"><span style="font-size:10px">Vize ihlali nedeniyle hakkınızda uygulanan "N" veya "Ç" tahdit kodlarıyla ilgili , 60(altmış) gün içerisinde İdare mahkemesine başvuru yapmanız gerekmektedir./</span><span style="font-size: 10px;">You must apply to the Administrative Court within 60 (sixty) days regarding the "N" or "C" restriction codes applied to you due to visa violation.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">4</span></th>
						<td style="text-align:left"><span style="font-size:10px">Tahdit iş ve işlemler ile ilgili uygulamalar Göç İdaresi Genel Müdürlüğü''nün 22/07/2020 tarih ve 2020/17 sayılı genelgeye istinaden yapılmaktadır./</span><span style="font-size: 10px;">Applications related to the restriction works and transactions are made in accordance with the circular numbered 2020/17 dated 22/07/2020 of the General Directorate of Migration Management.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">5</span></th>
						<td style="text-align:left"><span style="font-size:10px">Vize ihlalinde bulunan yolcularla ilgili yurda giriş yasaklarına ilişkin uygulama 2020/17 sayılı genelgenin Madde 6''nın "A" ve "B" bendlerine istinaden uygulanır./</span><span style="font-size: 10px;">Implementation of bans on entry to the dormitory for passengers violating a visa is applied pursuant to subparagraphs "A" and "B" of Article 6 of the circular numbered 2020/17.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">6</span></th>
						<td style="text-align:left"><span style="font-size:10px">6458 Sayılı Yabancılar ve Uluslararası Koruma Kanununun "9","15","102" Maddeleri./</span><span style="font-size: 10px;">Articles "9","15","102" of the Foreigners and International Protection Law No. 6458</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">7</span></th>
						<td style="text-align:left"><span style="font-size:10px">17/03/2016 tarihli ve 29656 sayılı Yabancılar ve Uluslararası Koruma Kanununun Uygulamasına İlişkin Yönetmeliğin 8. ve 9. Maddeleri./</span><span style="font-size: 10px;">Articles 8 and 9 of the Regulation on the Implementation of the Law on Foreigners and International Protection dated 17/03/2016 and numbered 29656</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">8</span></th>
						<td style="text-align:left"><span style="font-size:10px">Göç İdaresi Başkanlığı''nın 06.01.2022 tarih ve V-157 İdari Takip Kodu Görüş Talebi Konulu Yazısı.</span><span style="font-size: 10px;">Letter of the Directorate of Migration Management, dated 06.01.2022, on V-157 Administrative Tracking Code, Request for Opinion</span></td>
					</tr>
  </tbody>
</table>

<br>{{S1}}<center><br>
<div align="center">

<p align="center"><img src="../img/goc.png" width="200" height="95" class="note-float-left" style="float: left;"></p>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th> Ç Kodlu Giriş Yasağı Kararı Tebliğ Formu / Code Ç – Entry Ban Notification Form</th>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th scope="col">Yabancıya İlişkin Bilgiler –<span dir="RTL"><span dir="RTL">بالأجنبي </span> الخاصة </span> <span dir="RTL">المعلومات </span></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><strong>Adı –&nbsp;</strong><span dir="RTL">الاسم</span></th>
      <th scope="col">{{FIRSTNAME}}</th>
    </tr>
    <tr>
      <th scope="row"><strong>Soyadı –&nbsp;</strong><span dir="RTL">اللقب </span></th>
      <td>{{LASTNAME}}</td>
    </tr>
    <tr>
      <th scope="row"><strong>Baba Adı – <span dir="RTL">اسم </span>&nbsp;</strong><span dir="RTL">الاب </span></th>
      <td>{{FATHERNAME}}</td>
    </tr>
    <tr>
      <th scope="row"><strong>Anne Adı – <span dir="RTL">اسم </span>&nbsp;</strong><span dir="RTL">الأم</span></th>
      <td>{{MOTHERNAME}}</td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><strong>Doğum Tarihi – <span dir="RTL">الميلاد</span>&nbsp;</strong><span dir="RTL">تاريخ </span></th>
      <th scope="col">{{BIRTHDATE}}</th>
      <th scope="col"><strong>Uyruğu –&nbsp;</strong><span dir="RTL">الجنسية</span></th>
      <th scope="col">{{ORGIN}}</th>
    </tr>
    <tr>
      <th scope="row"><strong>İletişim Dili –<span dir="RTL">الاتصال</span> &nbsp;</strong><span dir="RTL">لغة </span></th>
      <th colspan="3" scope="row">{{ORGIN}}</th>
    </tr>
    <tr>
      <th colspan="4" scope="row"><strong>Karar ve Değerlendirmeye İlişkin Bilgiler –<span dir="RTL">التقييم</span> <span dir="RTL">و </span> <span dir="RTL">بالقرار </span> <span dir="RTL">المتعلقة </span>&nbsp;</strong><span dir="RTL">المعلومات </span></th>
    </tr>
   
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><strong>Giriş Yasağı Kararı Başlangıç-Bitiş Tarihi –&nbsp;</strong><strong><span dir="RTL">حظر </span> <span dir="RTL">قرار </span><span dir="RTL"> بدء </span> <span dir="RTL">تاريخ </span><span dir="RTL"> الدخول</span></strong></th>
      <th scope="col">{{TODAY}}</th>
      <th scope="col">{{CANENT}}</th>
    </tr>
    <tr>
      <th scope="col"><strong>Tahdit Kodu / Restriction Code</strong></th>
      <th colspan="2" scope="col"><h5>{{TCODE}}</h5></th>
    </tr>
  </tbody>
</table>

<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><ol start="1" type="1">
        <li><strong>Giriş Yasağı Kararı – <span dir="RTL">الدخول&nbsp; </span><span dir="RTL">حظر </span>&nbsp;</strong><span dir="RTL">قرار </span></li>
      </ol></th>
    </tr>
  </tbody>
</table>

<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><p>6458 sayılı Yabancılar ve Uluslararası Koruma Kanunun 9 uncu maddesi uyarınca gerçekleştirilen değerlendirme neticesinde, Göç İdaresi Genel Müdürlüğü / …………. Valiliği (İl Göç İdaresi Müdürlüğü) tarafından hakkınızda giriş yasağı kararı alınmıştır. –<em><span dir="RTL"><span dir="RTL"> (</span> اتُخِذ <span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> ، </span></em> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>6458 </span></em> رقم  الدولية  الحماية  و  الأجانب  قانون  من <span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>9 </span></em> للمادة  وفقا  أجري  الذي  للتقييم  نتيجة  للمحافظة الهجرة  إدارة  مديرية <span dir="RTL">) </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>........... </span></em> محافظة </span></em><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> / </span></em> الهجرة  لإدارة  العامة  المديرية  قبل </span></em><em><span dir="RTL"> من  بحقك  الدخول </span></em><em><span dir="RTL"> منع </span></em> &nbsp;<em><span dir="RTL">قرار </span></em></p>
      <p>&nbsp;</p></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 9px;" scope="col"><ul>
        <li>Hakkınızda giriş yasağı kararı alınmasına dayanak teşkil eden husus/hususlar sebebiyle; -<em><span dir="RTL">الأساس </span></em> <em><span dir="RTL">تشكل </span></em><em><span dir="RTL"> التي </span></em><em><span dir="RTL"> المسائل  <span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>/ </span></em>-للمسئلة  نظرا <span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> ؛</span></em> بحقك</span></em><em><span dir="RTL"> الدخول </span></em><em><span dir="RTL"> حظر </span></em> <em><span dir="RTL"> قرار </span></em>&nbsp;<em><span dir="RTL">لاتخاذ </span></em></li>
        <li><em>İkamet izninizin iptali için gerekli işlemler başlatılacaktır. –<span dir="RTL">إقامتك</span> <span dir="RTL">تصريح </span> <span dir="RTL">لإلغاء </span> <span dir="RTL">اللازمة </span> <span dir="RTL">الإجراءات </span>&nbsp;<span dir="RTL">ستبدأ </span></em></li>
        <li><em>Çalışma izninizin iptali için gerekli işlemler başlatılacaktır. –<span dir="RTL">لإلغاء </span> <span dir="RTL">الضرورية </span> <span dir="RTL">الإجراءات </span> <span dir="RTL">ستبدأ </span> <span dir="RTL">بك الخاص </span> <span dir="RTL">العمل </span>&nbsp;<span dir="RTL">تصريح </span></em></li>
        <li><u>Türkiye’ye girişinizin yasaklı olduğu süre içerisinde giriş yapmak istemeniz halinde, Türkiye Cumhuriyeti Dış Temsilciliklerinden amacına uygun (özel meşruhatlı) vize almanız gerekmektedir. –<em><u><span dir="RTL"> البعثات </span></u></em> <em><u><span dir="RTL">من </span></u></em> <em><u><span dir="RTL">خاصة مشروحة </span></u></em> <em><u><span dir="RTL">الغرض  تلبي </span></u></em> <em><u><span dir="RTL">دخول </span></u></em> <em><u><span dir="RTL">تأشيرة </span></u></em> <em><u><span dir="RTL">على </span></u></em><em><u><span dir="RTL"> الحصول </span></u></em> <em><u><span dir="RTL">ينبغي </span></u></em> <span dir="RTL"> </span><span dir="RTL"> </span><em><u><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>، </span></u></em> <em><u><span dir="RTL">عليك</span></u></em> <em><u><span dir="RTL">المفروضة </span></u></em><em><u><span dir="RTL"> الدخول </span></u></em> <em><u><span dir="RTL">الدخول </span></u></em><em><u><span dir="RTL">حظر </span></u></em> <em><u><span dir="RTL">فترة </span></u></em> <em><u><span dir="RTL">خلال </span></u></em> <em><u><span dir="RTL">تركيا </span></u></em> <em><u><span dir="RTL">دخول </span></u></em><em><u><span dir="RTL"> في </span></u></em> <em><u><span dir="RTL">ترغب </span></u></em> <em><u><span dir="RTL">كنت </span></u></em><em><u><span dir="RTL"> إذا </span></u></em> <em><u><span dir="RTL">التركية</span></u></em> <em><u><span dir="RTL">للجمهورية </span></u></em></u><em><u><span dir="RTL">الخارجية </span></u></em></li>
        <li>
          <p>Hakkınızda tahsis edilen giriş yasağı süresinin sona ermesi yüz seksen günde doksan gün kuralının uygulanmasına engel teşkil etmemektedir. Her halükârda vizenin veya vize muafiyetinin Türkiye’de sağladığı kalış süresi, her yüz seksen günde doksan günü geçemez.”--<span dir="RTL"><em><span dir="RTL"> ألا  يجب </span></em> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>، </span></em> <em><span dir="RTL">حال  أي </span></em> <em><span dir="RTL">على </span></em> <span dir="RTL"><em><span dir="RTL">و </span></em> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> . </span></em> <em><span dir="RTL">يومًا وثمانين  مائة </span></em> <em><span dir="RTL"> خلال </span></em><em><span dir="RTL"> يومًا  التسعين </span></em> <em><span dir="RTL">قاعدة  تطبيق  من </span></em> <em><span dir="RTL">يمنع  لا </span></em> <em><span dir="RTL">بك  المخصص  الدخول </span></em> <em><span dir="RTL">حظر  انتهاء  إن  يومًا وثمانين  مائة  خلال </span></em> <em><span dir="RTL">يومًا  التسعين  تركيا </span></em> <em><span dir="RTL">في  المقدمة  التأشيرة </span> <span dir="RTL">من  الإعفاء  أو  التأشيرة </span></em><em><span dir="RTL"> مدة </span></em> <em><span dir="RTL">تتجاوز </span></em></p>
        </li>
        <li><em><u><em><u>Hakkınızda alınan giriş yasağı kararının süresi dolmuş olsa dahi idari para cezanızı ödememenizden kaynaklanan ön izin kararına ilişkin hükümler saklıdır. -<span dir="RTL">الناتج  المسبق  الاذن  &nbsp; بقرار  المتعلقة  بالأحكام  الاحتفاظ </span> <span dir="RTL">يتم </span> <span dir="RTL">انه  إلا <span dir="RTL"> </span><span dir="RTL"> </span><em><u><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> ، </span></u></em> بحقك</span><span dir="RTL"> المتخذ  الدخول </span> <span dir="RTL">حظر </span><span dir="RTL"> قرار  انتهاء  حالة </span> <span dir="RTL">في </span> <span dir="RTL">حتى  الإدارية  الغرامة </span> <span dir="RTL">دفع </span> <span dir="RTL">عدم </span> &nbsp;</u><u><span dir="RTL">عن </span></u></em></u></em></li>
      </ul></th>
    </tr>
  </tbody>
</table>

<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><ol start="2" type="1">
        <li><strong>Giriş Yasağı Kararına Karşı Yargı Yoluna Başvuru –<span dir="RTL"><span dir="RTL"> <span dir="RTL">الدخول </span>حظر </span> قرار </span> <span dir="RTL"><span dir="RTL"><span dir="RTL">ضد </span> للقضاء </span> طلب </span> &nbsp;</strong><span dir="RTL">تقديم </span></li>
      </ol></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 9px;" scope="col"><ul>
        <li>Şahsınız veya yasal temsilciniz ya da avukatınız tarafından, giriş yasağı kararına karşı, kararın tebliğinden itibaren 60 (altmış) gün içinde idare mahkemesine başvurulabilir. – <em><span dir="RTL">ضد </span></em><em><span dir="RTL"> الإدارية </span></em><em><span dir="RTL"> المحكمة  إلى  بطلب  التقدم </span></em><em><span dir="RTL"> محاميك  أو </span></em><em><span dir="RTL"> القانوني  ممثلك  أو  أنت </span></em> <em><span dir="RTL">يمكنك </span></em> <em><span dir="RTL">بالقرار</span></em> <em><span dir="RTL">تبليغكم </span></em> <em><span dir="RTL">تاريخ  من </span></em> <em><span dir="RTL">يومًا </span></em> <span dir="RTL">(<em><span dir="RTL">ستين</span></em>) </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>60 </span></em> <em><span dir="RTL">غضون </span></em> <em><span dir="RTL">في </span></em><em><span dir="RTL"> الدخول </span></em> <em><span dir="RTL">حظر </span></em> &nbsp;<em><span dir="RTL">قرار </span></em></li>
        <li>Mahkemeye başvuran kişi, giriş yasağı kararı veren makama da başvurusunu bildirir. –<em><span dir="RTL">الجهة </span></em> <em><span dir="RTL">بإبلاغ </span></em><em><span dir="RTL"> للمحكمة </span></em><em><span dir="RTL"> المتقدم </span></em><em><span dir="RTL"> الشخص </span></em> <em><span dir="RTL">يقوم </span></em><em><span dir="RTL"> ايضا</span></em><em><span dir="RTL"> الدخول </span></em> <em><span dir="RTL">منع </span></em> <em><span dir="RTL">قرار </span></em> <em><span dir="RTL"> اتخذت </span></em>&nbsp;<em><span dir="RTL">التي </span></em></li>
        <li>Mahkemeye yapılan başvurular giriş yasağı kararını durdurmaz. –<em><span dir="RTL">الدخول</span></em> <em><span dir="RTL">حظر </span></em><em><span dir="RTL">قرار  توقف  لا </span></em> <em><span dir="RTL">للمحكمة </span></em><em><span dir="RTL">المقدمة </span></em>&nbsp;<em><span dir="RTL">الطلبات </span></em></li>
      </ul></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 12px;" scope="col"><span style="text-align:justify; font-size:12px">Bu belge, bir nüshası avukatına/yabancıya/yasal temsilcisine verilmek üzere iki nüsha olarak hazırlanmış olup, hakkında sınır dışı etme kararı alınan yukarıda açık kimliği yazılı yabancıya kendi dilinde/anladığı dilde,&nbsp;<a name="_Hlk43631423"><em>{{TODAY}}&nbsp;&nbsp;</em></a>tarihinde ve&nbsp;&nbsp;<a name="_Hlk43631423"><em>{{TOTIME}}&nbsp;</em></a>saatinde yazılı olarak tebliğ edilmiş ve imza altına alınarak bir sureti tebellüğ edene verilmiştir. –<em><span dir="RTL">إعلام</span><span dir="RTL"> </span></em> <em><span dir="RTL">تم </span></em> <em><span dir="RTL">وقد <span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>، </span></em> القانوني</span></em> <em><span dir="RTL">ممثله <span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> / </span></em> الأجنبي<span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> / </span></em> المحامي وكيله  إلى&nbsp; </span></em><em><span dir="RTL"> واحدة  نسخة </span></em> <em><span dir="RTL">تسليم  يتم </span></em><em><span dir="RTL"> أن  على <span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> ، </span></em> نسختين</span></em><em><span dir="RTL"> شكل  على </span></em><em><span dir="RTL"> الوثيقة </span></em><em><span dir="RTL"> هذه  تنظيم </span></em> <em><span dir="RTL">تم <a name="_Hlk43631423"><em>{{TODAY}}&nbsp;</em></a><span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span></span></em>التاريخ  في  وذلك </span></em> <em><span dir="RTL">يفهمها  التي  أواللغة <span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>/ </span></em> وبلغته كتابي </span></em><span dir="RTL"><em><span dir="RTL"> بشكل  التبليغ  وتم </span></em></span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> . </span></em> <em><span dir="RTL">حقه</span></em> <em><span dir="RTL">في  الصادر  الترحيل  بقرار  أعلاه  الواضحة  هويته  المذكورة  الأجنبي </span></em> <em><span dir="RTL">بالتبليغ المخاطب  الشخص </span></em><em><span dir="RTL"> إلى  منها  نسخة </span></em> <em><span dir="RTL">وتسليم  الوثيقة  هذه  على  التوقيع </span></em> <span dir="RTL"><em><span dir="RTL">تم  وعليه </span></em></span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>{{TOTIME}}</span></em> <em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> : </span></em> الساعة</span></em> <em><span dir="RTL"> في </span></em>&nbsp;<span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>20 </span></em></span></th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: center" scope="col"><strong>Tebliğ Eden</strong></th>
      <th style="text-align: center" scope="col"><strong>Tebellüğ Eden</strong></th>
    </tr>
    <tr>
      <th style="text-align: center" scope="row"><strong><span dir="RTL">المُبَلّْغ</span></strong></th>
      <td style="text-align: center"><strong><span dir="RTL"> إليه المًبَلَّغ </span></strong></td>
    </tr>
    <tr>
      <th style="text-align: center" scope="row"><strong>{{USER}}</strong></th>
      <td style="text-align: center"><strong>{{NAME}}</strong></td>
    </tr>
  </tbody>
</table>


{{F1}}
</div></center>
', N'<h3 align="center" style="font-family: Arial, Helvetica, sans-serif; color: rgb(0, 0, 0);">VİZE İHLALİ İŞLEM FORMU /VISA VIOLATION FORM</h3><h3 align="center"><table width="400" border="0" style="font-size: 13px; text-align: left;"><tbody><tr><td>Adı Soyadı /Name/Surname</td><td>{{NAME}}<br></td></tr><tr><td>Uyruğu / Nationality</td><td>{{ORGIN}}</td></tr><tr><td>Pasaport No / Passport No</td><td>{{PASSPORT}}</td></tr></tbody></table><span style="text-align: left; font-size: 14px;"><br></span><span style="font-size: 13px; text-align: left;"></span><table width="800" border="0" style="font-size: 13px; text-align: left;"><tbody><tr><td colspan="2" style="font-size: 12px;">* Ülkemize Giriş Tarihiniz ve Vize süreniz Date of entry into country / Notification Date and visa validity</td><td style="font-size: 16px;"><span style="font-weight: 700 !important;">{{EDATE}}</span></td><td><table width="100%" border="0"><tbody><tr><td width="8%"><span style="font-weight: 700 !important;">{{VDAY}}</span></td><td width="9%"><span style="font-weight: 700 !important;">&nbsp;Day(s)</span></td></tr></tbody></table></td></tr><tr><td colspan="2" style="font-size: 12px;"><table width="100%" border="0"><tbody><tr><td>*&nbsp;&nbsp;Ülkemizden çıkış için müracaat tarihiniz/ The date that you are applying to leave the country</td><td>:</td></tr></tbody></table></td><td style="font-size: 16px;"><span style="font-weight: 700 !important;">{{TODAY}}</span></td><td>&nbsp;</td></tr><tr><td style="font-size: 12px;">*&nbsp;&nbsp;Ülkemizden çıkış yapmanız gereken tarih/ The date that you were meant to leave the country</td><td style="font-size: 12px;">:</td><td style="font-size: 16px;"><span style="font-weight: 700 !important;">{{SEDATE}}</span></td><td>&nbsp;</td></tr><tr><td style="font-size: 12px;">*&nbsp;&nbsp;Ülkemize giriş yapabileceğiniz tarih/&nbsp;(Giriş yasağınızın otomatik olarak iptal edileceği tarih) / &nbsp;&nbsp;&nbsp; The date on which the ban on entry will be automatically canceled&nbsp;</td><td style="font-size: 12px;">:</td><td style="font-size: 16px;"><span style="font-weight: 700 !important;">{{CANENT}}</span></td><td>&nbsp;</td></tr><tr><td style="font-size: 12px;">*&nbsp;Tebliğ Edilen, Tahdit Çıkış&nbsp; veya İkamet Teskere Bitiş Tarihi / End date of notified or limitation date or residence permit</td><td style="font-size: 12px;">:</td><td style="font-size: 16px;"><span style="font-weight: 700 !important;">{{SEDATE}}</span></td><td>&nbsp;</td></tr><tr><td style="font-size: 12px;">*&nbsp;&nbsp;Vize ihlal süreniz / Visa violation period</td><td style="font-size: 12px;">:</td><td style="font-size: 16px;"><span style="font-weight: 700 !important;">{{FINETIME}}</span></td><td>&nbsp;</td></tr><tr><td style="font-size: 12px;">*&nbsp;&nbsp;Vize ihlali için ödenecek ücret / Penalty for visa violation</td><td style="font-size: 12px;">:</td><td style="font-size: 16px;"><span style="font-weight: 700 !important;">{{FINET}}</span></td><td style="font-size: 16px;"><span style="font-size: 13px; font-weight: 700 !important;"><font size="2">TL</font></span><br></td></tr></tbody></table><span style="text-align: left; font-size: 14px;"><br></span><span style="font-size: 13px; text-align: left;"></span><table width="800" border="0" style="font-size: 13px; text-align: left;"><tbody><tr><td style="font-size: 12px;"><p>Sayın&nbsp;<span style="color: rgb(0, 0, 0); font-size: 13px;">{{NAME}}</span>&nbsp;Ülkemizdeki yasal kalış sürenizi ihlal etmiş bulunmaktasınız.{{S}}Vize ihlal ücretini ödemediğiniz için hakkınızda ülkemize&nbsp;<span style="font-weight: 700 !important;">{{FINEDAY}}&nbsp;</span>Gün giriş yasağı uygulanacaktır.&nbsp; Hakkınızda girilecek&nbsp;Tahdit kodu {{TCODE}}{{F}}</p><hr><table width="800" border="0"><tbody><tr><td>Dear Madame/Sir&nbsp;<span style="font-size: 13px;">{{NAME}}</span>&nbsp;You have overstayed your visa.{{S1}} As you have not paid the relevant fine, a ban on your re-entering Turkey will be put into practise{{FINEDAY}} Entry Ban Code {{TCODE}}{{F1}}</td></tr></tbody></table></td></tr></tbody></table><span style="text-align: left; font-size: 14px;"><br></span><span style="font-size: 13px; text-align: left;"></span><table align="center" width="400" border="0" style="font-size: 13px; text-align: left;"><tbody><tr><td>Düzenleme Tarihi / Dated On:</td><td><span style="font-weight: 700 !important;">{{TODAY}}</span></td></tr></tbody></table><span style="text-align: left; font-size: 14px;"><br></span><span style="font-size: 13px; text-align: left;"></span><table width="800" border="0" style="font-size: 13px; text-align: left;"><tbody><tr align="center"><td>Yolcu İmzası</td><td>Pasaport Kontrol Polisi</td></tr><tr align="center"><td>Signature of passenger</td><td>Passport police officer</td></tr><tr align="center"><td><span style="font-weight: 700 !important;">&nbsp;{{NAME}}</span></td><td><span style="font-weight: 700 !important;">{{POLICE}}</span></td></tr></tbody></table><span style="text-align: left; font-size: 14px;"><br></span><span style="font-size: 13px; text-align: left;"></span><table width="800" border="0" style="font-size: 13px; text-align: left;"><tbody><tr><td>Formu okudum, imzaladım ve kopyasını aldım / I have read the form, signed it,and have a copy of the form</td></tr></tbody></table><span style="text-align: left; font-size: 14px;"><br></span><span style="font-size: 13px; text-align: left;"></span><table width="800" border="0" style="font-size: 13px; text-align: left;"><tbody><tr align="center"><td><span style="font-weight: 700 !important;">O N A Y</span></td></tr><tr align="center"><td>APPROVAL</td></tr><tr align="center"><td>{{USER}}</td></tr></tbody></table><span style="text-align: left; font-size: 14px;"><br></span><span style="font-size: 13px; text-align: left;"></span><table width="800" border="0" style="font-size: 13px; text-align: left;"><tbody><tr><th scope="col"><span style="font-size: 10px;">1</span></th><td><span style="font-size: 10px;">İkamet Harçları 492 sayılı Harçlar kanununun 6 sayılı tarifesine göre her yıl Maliye Bakanlığınca Belirlenmektedir./</span><span style="font-size: 10px;">Residence Fees are determined by the Ministry of Finance every year according to the tariff no. 6 of the Fees Law No. 492.</span></td></tr><tr><th scope="row"><span style="font-size: 10px;">2</span></th><td><span style="font-size: 10px;">Hakkınızda konulmuşsa, konulan ülkemize giriş yasağının kaldırılması için Türkiye Cumhuriyeti dış temsilciliklerine özel amaçlı vize için müracaat ediniz./</span><span style="font-size: 10px;">If it has been placed about you, apply for a special purpose visa to the foreign representatives of the Republic of Turkey in order to lift the ban on entry to our country.</span></td></tr><tr><th scope="row"><span style="font-size: 10px;">3</span></th><td><span style="font-size: 10px;">Vize ihlali nedeniyle hakkınızda uygulanan "N" veya "Ç" tahdit kodlarıyla ilgili , 60(altmış) gün içerisinde İdare mahkemesine başvuru yapmanız gerekmektedir./</span><span style="font-size: 10px;">You must apply to the Administrative Court within 60 (sixty) days regarding the "N" or "C" restriction codes applied to you due to visa violation.</span></td></tr><tr><th scope="row"><span style="font-size: 10px;">4</span></th><td><span style="font-size: 10px;">Tahdit iş ve işlemler ile ilgili uygulamalar Göç İdaresi Genel Müdürlüğü''nün 22/07/2020 tarih ve 2020/17 sayılı genelgeye istinaden yapılmaktadır./</span><span style="font-size: 10px;">Applications related to the restriction works and transactions are made in accordance with the circular numbered 2020/17 dated 22/07/2020 of the General Directorate of Migration Management.</span></td></tr><tr><th scope="row"><span style="font-size: 10px;">5</span></th><td><span style="font-size: 10px;">Vize ihlalinde bulunan yolcularla ilgili yurda giriş yasaklarına ilişkin uygulama 2020/17 sayılı genelgenin Madde 6''nın "A" ve "B" bendlerine istinaden uygulanır./</span><span style="font-size: 10px;">Implementation of bans on entry to the dormitory for passengers violating a visa is applied pursuant to subparagraphs "A" and "B" of Article 6 of the circular numbered 2020/17.</span></td></tr><tr><th scope="row"><span style="font-size: 10px;">6</span></th><td><span style="font-size: 10px;">6458 Sayılı Yabancılar ve Uluslararası Koruma Kanununun "9","15","102" Maddeleri./</span><span style="font-size: 10px;">Articles "9","15","102" of the Foreigners and International Protection Law No. 6458</span></td></tr><tr><th scope="row"><span style="font-size: 10px;">7</span></th><td><span style="font-size: 10px;">17/03/2016 tarihli ve 29656 sayılı Yabancılar ve Uluslararası Koruma Kanununun Uygulamasına İlişkin Yönetmeliğin 8. ve 9. Maddeleri./</span><span style="font-size: 10px;">Articles 8 and 9 of the Regulation on the Implementation of the Law on Foreigners and International Protection dated 17/03/2016 and numbered 29656</span></td></tr><tr><th scope="row"><span style="font-size: 10px;">8</span></th><td><span style="font-size: 10px;">Göç İdaresi Başkanlığı''nın 06.01.2022 tarih ve V-157 İdari Takip Kodu Görüş Talebi Konulu Yazısı.</span><span style="font-size: 10px;">Letter of the Directorate of Migration Management, dated 06.01.2022, on V-157 Administrative Tracking Code, Request for Opinion</span></td></tr></tbody></table></h3>
<p>&nbsp;&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>


<p align="center"><img src="../img/goc.png" width="200" height="95" class="note-float-left" style="float: left;"></p>

<table width="800" border="0" align="center">
  <tbody>
    <tr align="center">
      <td>İdari Para Cezalarına İlişkin N Kodlu Ön İzin Kararı Tebliğ Formu<br>
      Notification Form for Code N Preliminary Permission Decision Regarding Administrative Fines</td>
    </tr>
  </tbody>
  
</table>

<table width="800" border="0">
  <tbody>
    <tr>
      <td align="center"><strong style="font-size: 14px">Yabancıya İlişkin Bilgiler&nbsp;–<span dir="RTL"><span dir="RTL">بالأجنبي </span> الخاصة </span> &nbsp;<span dir="RTL">المعلومات </span></strong></td>
    </tr>
  </tbody>
</table>

<table width="800" border="1">
  <tbody>
    <tr>
      <td style="font-size: 12px">Adı –&nbsp;<span dir="RTL">الاسم</span></td>
      <td style="font-size: 12px"><strong>{{FIRSTNAME}}</strong></td>
    </tr>
    <tr>
      <td style="font-size: 12px">Soyadı –&nbsp;<span dir="RTL">اللقب </span></td>
      <td style="font-size: 12px"><strong>{{LASTNAME}}</strong></td>
    </tr>
    <tr>
      <td style="font-size: 12px">Baba Adı –&nbsp;<span dir="RTL">اسم </span> <span dir="RTL">الاب </span></td>
      <td style="font-size: 12px"><strong>{{FATHERNAME}}</strong></td>
    </tr>
    <tr>
      <td style="font-size: 12px">Anne Adı –<span dir="RTL">اسم </span> &nbsp;<span dir="RTL">الأم</span></td>
      <td style="font-size: 12px"><strong>{{MOTHERNAME}}</strong></td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <td>Doğum Tarihi –<span dir="RTL">الميلاد</span> &nbsp;<span dir="RTL">تاريخ </span></td>
      <td><strong>{{BIRTHDATE}}</strong></td>
      <td>Uyruğu –&nbsp;<span dir="RTL">الجنسية</span></td>
      <td><strong>{{ORGIN}}</strong></td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <td>İletişim Dili – <span dir="RTL">لغة </span>&nbsp;<span dir="RTL">الاتصال</span></td>
      <td><strong>{{ORGIN}}</strong></td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <td>Karar ve Değerlendirmeye İlişkin Bilgiler –<span dir="RTL"><span dir="RTL"><span dir="RTL"><span dir="RTL">التقييم</span> و </span> بالقرار </span> المتعلقة </span> &nbsp;<span dir="RTL">المعلومات </span></td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th width="518" rowspan="2" scope="col">Giriş Yasağı Kararı Başlangıç-Bitiş Tarihi –<span dir="RTL">حظر </span><span dir="RTL"> قرار </span> <span dir="RTL"><span dir="RTL">بدء </span> تاريخ </span> &nbsp;<span dir="RTL">الدخول</span></th>
      <th width="53" scope="col">1-</th>
      <th width="207" scope="col">{{TODAY}}</th>
    </tr>
    <tr>
      <th scope="col">2-</th>
      <th scope="col">&nbsp;</th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="font-size: 12px" scope="col">* Bu alana giriş yasağı kararının başlangıç tarihi yazılacaktır.</th>
      <th style="font-size: 12px" scope="col"><em><span dir="RTL">الحقلهذا في الدخول حظر قرار بدء  تاريخ كتابة  سيتم </span></em></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="font-size: 12px" scope="col">** Bu alana giriş yasağı kararının bitiş tarihi yazılacaktır.</th>
      <th style="font-size: 12px" scope="col"><em><span dir="RTL"> الحقل  هذا  في  الدخول  حظر  انتهاء  تاريخ  كتابة  سيتم </span></em></th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 12px;"><li style="text-align:center"><strong>Ön İzin Kararı –<span dir="RTL"><span dir="RTL">المسبق </span> الإذن </span> &nbsp;<span dir="RTL">قرار </span></strong></li>
        <li><strong>6458 sayılı Yabancılar ve Uluslararası Koruma Kanunun 9 uncu maddesi uyarınca gerçekleştirilen değerlendirme neticesinde,&nbsp;<a name="_Hlk43629860">………….</a>&nbsp;Valiliği (İl Göç İdaresi Müdürlüğü) tarafından hakkınızda ön izin kararı alınmıştır. –<em><span dir="RTL">نتيجة </span></em> <em><span dir="RTL">الهجرة  إدارة </span></em> <span dir="RTL"><em><span dir="RTL"> مديرية </span></em> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>........... </span></em> <em><span dir="RTL">محافظة  قبل  من </span></em><em><span dir="RTL"> بحقك  المسبق  الاذن </span></em><span dir="RTL"><span dir="RTL"><em><span dir="RTL"> قرار  اتُخِذ </span></em> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>، </span></em> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>، </span></em> <em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> 6458</span></em> رقم  الدولية </span></em> <em><span dir="RTL">الحماية </span></em> <span dir="RTL"><em><span dir="RTL"> و  الأجانب  قانون  من </span></em> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> 9 </span></em> <em><span dir="RTL">للمادة </span></em>&nbsp;<em><span dir="RTL">وفقا  أجري  الذي </span></em> <em><span dir="RTL">للتقييم </span></em> <em><span dir="RTL">للمحافظة</span></em></strong></li>
        <em>
        <li><strong>
        Hakkınızda ön izin kararı alınmasına dayanak teşkil eden husus/hususlar sebebiyle; -</strong></li>
        <span dir="RTL">الأساس </span>         <span dir="RTL">تشكل </span>        <span dir="RTL">التي </span>        <span dir="RTL">المسائل </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> / </span></em> <span dir="RTL">للمسئلة </span>        <span dir="RTL">نظرا </span><strong><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> ؛</span></em></strong>        <span dir="RTL">بحقك</span>        <span dir="RTL">المسبق </span>        <span dir="RTL">الاذن </span>        <span dir="RTL">قرار </span><strong>&nbsp;</strong>        <span dir="RTL">لاتخاذ </span>
        <li><strong>&nbsp;İkamet izninizin iptali için gerekli işlemler başlatılacaktır. -</strong> </li>
        <span dir="RTL">إقامتك</span>         <span dir="RTL">تصريح </span>        <span dir="RTL">لإلغاء </span>        <span dir="RTL">اللازمة </span>        <span dir="RTL">الإجراءات</span><strong>&nbsp; </strong>        <span dir="RTL">ستبدأ </span>
        <li><strong>Çalışma izninizin iptali için gerekli işlemler başlatılacaktır. -        <span dir="RTL"><em>لإلغاء </em></span> <span dir="RTL"><em>الضرورية </em></span> <span dir="RTL"><em>الإجراءات </em></span><strong><em>&nbsp;</em></strong> <span dir="RTL"><em>ستبدأ<span dir="RTL"> بكاالخاص  لعمل </span><u> </u></em></span></strong>         </li>
        <span dir="RTL">تصريح </span><strong><u>dari para cezanızı ödememeniz nedeni ile hakkınızda alınan ön izin kararı, idari para cezasının ödendiğine ilişkin makbuzun idareye tebliğ edilmesi halinde kaldırılır ve&nbsp;</u>girişinize engel olacak başka bir hususun bulunmaması kaydıyla<u>&nbsp;Türkiye’ye girişinize izin verilir </u></strong><u><span dir="RTL">دفع </span></u><u><span dir="RTL">وصل </span></u><strong><u> </u></strong><u><span dir="RTL">تقديم </span></u><u><span dir="RTL"> حال </span></u><strong><u> </u></strong><u><span dir="RTL">في  الادارية  المالية  للغرامة  دفعك  لعدم  بحقك  المتخذ  المسبق  الإذن </span></u><strong><u> </u></strong><u><span dir="RTL">قرار  رفع  يتم </span></u><span dir="RTL"> للدخول اخرى  عوائق  وجود </span><strong><u> </u></strong><span dir="RTL">عدم </span><span dir="RTL"> حال  في </span><strong><u> </u></strong><u><span dir="RTL">تركيا </span></u><strong><u> </u></strong><u><span dir="RTL">بدخول  لك  السماح  ويتم <span dir="RTL">  </span><span dir="RTL"> </span><em><u><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>، </span></u></em> للإدارة</span></u><strong><u> .</u></strong><u><span dir="RTL">المالية </span></u><strong> &nbsp;</strong><u><span dir="RTL">االغرامة  </span></u>
        <li></li>
        <li style="text-align:center"><strong>Ön İzin Kararına Karşı Yargı Yoluna Başvuru –<span dir="RTL">المسبق  الاذن  قرار  ضد  للقضاء </span> <span dir="RTL">طلب </span> &nbsp;<span dir="RTL">تقديم </span></strong></li>
        <li><strong>Şahsınız veya yasal temsilciniz ya da avukatınız tarafından, ön izin kararına karşı, kararın tebliğinden itibaren 60 (altmış) gün içinde idare mahkemesine başvurulabilir. –</strong></li>
        <span dir="RTL">المحكمة </span>        <span dir="RTL">إلى </span>        <span dir="RTL">بطلب </span>        <span dir="RTL">التقدم </span>        <span dir="RTL">محاميك </span>         <span dir="RTL">أو </span>         <span dir="RTL">القانوني </span>        <span dir="RTL">ممثلك </span>        <span dir="RTL">أو </span>        <span dir="RTL">أنت </span>         <span dir="RTL">يمكنك </span>        <span dir="RTL">بالقرار</span>         <span dir="RTL">تبليغكم </span>         <span dir="RTL">تاريخ </span>         <span dir="RTL">من </span>        <span dir="RTL">يومًا </span><strong><span dir="RTL">(</span></strong>        <span dir="RTL">ستين</span><strong><span dir="RTL">) </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>60 </span></em></strong>        <span dir="RTL">غضون </span>         <span dir="RTL">في </span>        <span dir="RTL">المسبق </span>        <span dir="RTL">الاذن </span>        <span dir="RTL">قرار </span>        <span dir="RTL">ضد </span>        <span dir="RTL">الإدارية </span>
        <li><strong>Mahkemeye başvuran kişi, ön izin kararı veren makama da başvurusunu bildirir. –</strong></li>
        <span dir="RTL">للمحكمة </span>        <span dir="RTL">المتقدم </span>        <span dir="RTL">الشخص </span>        <span dir="RTL">يقوم </span>        <span dir="RTL">ايضا</span>        <span dir="RTL">المسبق </span>        <span dir="RTL">الاذن </span>        <span dir="RTL">قرار </span>        <span dir="RTL">اتخذت </span>        <span dir="RTL">التي </span>        <span dir="RTL">الجهة </span><strong>&nbsp;</strong>        <span dir="RTL">بإبلاغ </span>
        <li><em><strong>Mahkemeye yapılan başvurular ön izin kararını durdurmaz. –</strong><span dir="RTL">المسبق  الاذن  قرار </span> <strong> </strong><span dir="RTL">توقف  لا  للمحكمة  االمقدمة   الطلبات  </span></em></li>
        </em></th>
    </tr>
  </tbody>
</table>




<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align:justify; font-size:12px">Bu belge, bir nüshası avukatına/yabancıya/yasal temsilcisine verilmek üzere iki nüsha olarak hazırlanmış olup, hakkında sınır dışı etme kararı alınan yukarıda açık kimliği yazılı yabancıya kendi dilinde/anladığı dilde,&nbsp;<a name="_Hlk43631423"><em>{{TODAY}}&nbsp;&nbsp;</em></a>tarihinde ve&nbsp;&nbsp;<a name="_Hlk43631423"><em>{{TOTIME}}&nbsp;</em></a>saatinde yazılı olarak tebliğ edilmiş ve imza altına alınarak bir sureti tebellüğ edene verilmiştir. –<em><span dir="RTL">إعلام</span><span dir="RTL"> </span></em> <em><span dir="RTL">تم </span></em> <em><span dir="RTL">وقد <span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>، </span></em> القانوني</span></em> <em><span dir="RTL">ممثله <span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> / </span></em> الأجنبي<span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> / </span></em> المحامي وكيله  إلى&nbsp; </span></em><em><span dir="RTL"> واحدة  نسخة </span></em> <em><span dir="RTL">تسليم  يتم </span></em><em><span dir="RTL"> أن  على <span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> ، </span></em> نسختين</span></em><em><span dir="RTL"> شكل  على </span></em><em><span dir="RTL"> الوثيقة </span></em><em><span dir="RTL"> هذه  تنظيم </span></em> <em><span dir="RTL">تم <a name="_Hlk43631423"><em>{{TODAY}}&nbsp;</em></a><span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> </span></em>التاريخ  في  وذلك </span></em> <em><span dir="RTL">يفهمها  التي  أواللغة <span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>/ </span></em> وبلغته كتابي </span></em><span dir="RTL"><em><span dir="RTL"> بشكل  التبليغ  وتم </span></em> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> . </span></em> <em><span dir="RTL">حقه</span></em> <em><span dir="RTL">في  الصادر  الترحيل  بقرار  أعلاه  الواضحة  هويته  المذكورة  الأجنبي </span></em> <em><span dir="RTL">بالتبليغ المخاطب  الشخص </span></em><em><span dir="RTL"> إلى  منها  نسخة </span></em> <em><span dir="RTL">وتسليم  الوثيقة  هذه  على  التوقيع </span></em> <span dir="RTL"><em><span dir="RTL">تم  وعليه  </span></em> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>{{TOTIME}}</span></em> <em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> : </span></em> الساعة</span></em> <em><span dir="RTL"> في </span></em>&nbsp;<span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>20 </span></em></th>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="0" align="center">
  <tbody>
    <tr align="center">
      <th scope="col"><strong>Tebliğ Eden</strong></th>
      <th scope="col"><strong>Tebellüğ Eden</strong></th>
    </tr>
    <tr align="center">
      <th scope="row"><strong><span dir="RTL">المُبَلّْغ</span></strong></th>
      <td scope="col"><strong><span dir="RTL">إليه المًبَلَّغ </span></strong></td>
    </tr>
    <tr align="center">
      <th scope="row"><strong>{{USER}}</strong></th>
      <td><strong>{{NAME}}</strong></td>
    </tr>
  </tbody>
</table>
<p>&nbsp;</p>

<p align="center"><span style="text-align: left;"><br>{{ÇS}}</span><br></p>


<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>

<p align="center"><img src="../img/goc.png" width="200" height="95" class="note-float-left" style="float: left;"></p>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th> Ç Kodlu Giriş Yasağı Kararı Tebliğ Formu / Code Ç – Entry Ban Notification Form</th>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th scope="col">Yabancıya İlişkin Bilgiler –<span dir="RTL"><span dir="RTL">بالأجنبي </span> الخاصة </span> <span dir="RTL">المعلومات </span></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><strong>Adı –&nbsp;</strong><span dir="RTL">الاسم</span></th>
      <th scope="col">{{FIRSTNAME}}</th>
    </tr>
    <tr>
      <th scope="row"><strong>Soyadı –&nbsp;</strong><span dir="RTL">اللقب </span></th>
      <td>{{LASTNAME}}</td>
    </tr>
    <tr>
      <th scope="row"><strong>Baba Adı – <span dir="RTL">اسم </span>&nbsp;</strong><span dir="RTL">الاب </span></th>
      <td>{{FATHERNAME}}</td>
    </tr>
    <tr>
      <th scope="row"><strong>Anne Adı – <span dir="RTL">اسم </span>&nbsp;</strong><span dir="RTL">الأم</span></th>
      <td>{{MOTHERNAME}}</td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><strong>Doğum Tarihi – <span dir="RTL">الميلاد</span>&nbsp;</strong><span dir="RTL">تاريخ </span></th>
      <th scope="col">{{BIRTHDATE}}</th>
      <th scope="col"><strong>Uyruğu –&nbsp;</strong><span dir="RTL">الجنسية</span></th>
      <th scope="col">{{ORGIN}}</th>
    </tr>
    <tr>
      <th scope="row"><strong>İletişim Dili –<span dir="RTL">الاتصال</span> &nbsp;</strong><span dir="RTL">لغة </span></th>
      <th colspan="3" scope="row">{{ORGIN}}</th>
    </tr>
    <tr>
      <th colspan="4" scope="row"><strong>Karar ve Değerlendirmeye İlişkin Bilgiler –<span dir="RTL">التقييم</span> <span dir="RTL">و </span> <span dir="RTL">بالقرار </span> <span dir="RTL">المتعلقة </span>&nbsp;</strong><span dir="RTL">المعلومات </span></th>
    </tr>
   
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><strong>Giriş Yasağı Kararı Başlangıç-Bitiş Tarihi –&nbsp;</strong><strong><span dir="RTL">حظر </span> <span dir="RTL">قرار </span><span dir="RTL"> بدء </span> <span dir="RTL">تاريخ </span><span dir="RTL"> الدخول</span></strong></th>
      <th scope="col">{{TODAY}}</th>
      <th scope="col">{{CANENT}}</th>
    </tr>
    <tr>
      <th scope="col"><strong>Tahdit Kodu / Restriction Code</strong></th>
      <th colspan="2" scope="col"><h5>{{TCODE}}</h5></th>
    </tr>
  </tbody>
</table>

<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><ol start="1" type="1">
        <li><strong>Giriş Yasağı Kararı – <span dir="RTL">الدخول&nbsp; </span><span dir="RTL">حظر </span>&nbsp;</strong><span dir="RTL">قرار </span></li>
      </ol></th>
    </tr>
  </tbody>
</table>

<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><p>6458 sayılı Yabancılar ve Uluslararası Koruma Kanunun 9 uncu maddesi uyarınca gerçekleştirilen değerlendirme neticesinde, Göç İdaresi Genel Müdürlüğü / …………. Valiliği (İl Göç İdaresi Müdürlüğü) tarafından hakkınızda giriş yasağı kararı alınmıştır. –<em><span dir="RTL"><span dir="RTL"> (</span> اتُخِذ <span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> ، </span></em> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>6458 </span></em> رقم  الدولية  الحماية  و  الأجانب  قانون  من <span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>9 </span></em> للمادة  وفقا  أجري  الذي  للتقييم  نتيجة  للمحافظة الهجرة  إدارة  مديرية <span dir="RTL">) </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>........... </span></em> محافظة </span></em><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> / </span></em> الهجرة  لإدارة  العامة  المديرية  قبل </span></em><em><span dir="RTL"> من  بحقك  الدخول </span></em><em><span dir="RTL"> منع </span></em> &nbsp;<em><span dir="RTL">قرار </span></em></p>
      <p>&nbsp;</p></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 9px;" scope="col"><ul>
        <li>Hakkınızda giriş yasağı kararı alınmasına dayanak teşkil eden husus/hususlar sebebiyle; -<em><span dir="RTL">الأساس </span></em> <em><span dir="RTL">تشكل </span></em><em><span dir="RTL"> التي </span></em><em><span dir="RTL"> المسائل  <span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>/ </span></em>-للمسئلة  نظرا <span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> ؛</span></em> بحقك</span></em><em><span dir="RTL"> الدخول </span></em><em><span dir="RTL"> حظر </span></em> <em><span dir="RTL"> قرار </span></em>&nbsp;<em><span dir="RTL">لاتخاذ </span></em></li>
        <li><em>İkamet izninizin iptali için gerekli işlemler başlatılacaktır. –<span dir="RTL">إقامتك</span> <span dir="RTL">تصريح </span> <span dir="RTL">لإلغاء </span> <span dir="RTL">اللازمة </span> <span dir="RTL">الإجراءات </span>&nbsp;<span dir="RTL">ستبدأ </span></em></li>
        <li><em>Çalışma izninizin iptali için gerekli işlemler başlatılacaktır. –<span dir="RTL">لإلغاء </span> <span dir="RTL">الضرورية </span> <span dir="RTL">الإجراءات </span> <span dir="RTL">ستبدأ </span> <span dir="RTL">بك الخاص </span> <span dir="RTL">العمل </span>&nbsp;<span dir="RTL">تصريح </span></em></li>
        <li><u>Türkiye’ye girişinizin yasaklı olduğu süre içerisinde giriş yapmak istemeniz halinde, Türkiye Cumhuriyeti Dış Temsilciliklerinden amacına uygun (özel meşruhatlı) vize almanız gerekmektedir. –<em><u><span dir="RTL"> البعثات </span></u></em> <em><u><span dir="RTL">من </span></u></em> <em><u><span dir="RTL">خاصة مشروحة </span></u></em> <em><u><span dir="RTL">الغرض  تلبي </span></u></em> <em><u><span dir="RTL">دخول </span></u></em> <em><u><span dir="RTL">تأشيرة </span></u></em> <em><u><span dir="RTL">على </span></u></em><em><u><span dir="RTL"> الحصول </span></u></em> <em><u><span dir="RTL">ينبغي </span></u></em> <span dir="RTL"> </span><span dir="RTL"> </span><em><u><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>، </span></u></em> <em><u><span dir="RTL">عليك</span></u></em> <em><u><span dir="RTL">المفروضة </span></u></em><em><u><span dir="RTL"> الدخول </span></u></em> <em><u><span dir="RTL">الدخول </span></u></em><em><u><span dir="RTL">حظر </span></u></em> <em><u><span dir="RTL">فترة </span></u></em> <em><u><span dir="RTL">خلال </span></u></em> <em><u><span dir="RTL">تركيا </span></u></em> <em><u><span dir="RTL">دخول </span></u></em><em><u><span dir="RTL"> في </span></u></em> <em><u><span dir="RTL">ترغب </span></u></em> <em><u><span dir="RTL">كنت </span></u></em><em><u><span dir="RTL"> إذا </span></u></em> <em><u><span dir="RTL">التركية</span></u></em> <em><u><span dir="RTL">للجمهورية </span></u></em></u><em><u><span dir="RTL">الخارجية </span></u></em></li>
        <li>
          <p>Hakkınızda tahsis edilen giriş yasağı süresinin sona ermesi yüz seksen günde doksan gün kuralının uygulanmasına engel teşkil etmemektedir. Her halükârda vizenin veya vize muafiyetinin Türkiye’de sağladığı kalış süresi, her yüz seksen günde doksan günü geçemez.”--<span dir="RTL"><em><span dir="RTL"> ألا  يجب </span></em> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>، </span></em> <em><span dir="RTL">حال  أي </span></em> <em><span dir="RTL">على </span></em> <span dir="RTL"><em><span dir="RTL">و </span></em> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> . </span></em> <em><span dir="RTL">يومًا وثمانين  مائة </span></em> <em><span dir="RTL"> خلال </span></em><em><span dir="RTL"> يومًا  التسعين </span></em> <em><span dir="RTL">قاعدة  تطبيق  من </span></em> <em><span dir="RTL">يمنع  لا </span></em> <em><span dir="RTL">بك  المخصص  الدخول </span></em> <em><span dir="RTL">حظر  انتهاء  إن  يومًا وثمانين  مائة  خلال </span></em> <em><span dir="RTL">يومًا  التسعين  تركيا </span></em> <em><span dir="RTL">في  المقدمة  التأشيرة </span> <span dir="RTL">من  الإعفاء  أو  التأشيرة </span></em><em><span dir="RTL"> مدة </span></em> <em><span dir="RTL">تتجاوز </span></em></p>
        </li>
        <li><em><u><em><u>Hakkınızda alınan giriş yasağı kararının süresi dolmuş olsa dahi idari para cezanızı ödememenizden kaynaklanan ön izin kararına ilişkin hükümler saklıdır. -<span dir="RTL">الناتج  المسبق  الاذن  &nbsp; بقرار  المتعلقة  بالأحكام  الاحتفاظ </span> <span dir="RTL">يتم </span> <span dir="RTL">انه  إلا <span dir="RTL"> </span><span dir="RTL"> </span><em><u><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> ، </span></u></em> بحقك</span><span dir="RTL"> المتخذ  الدخول </span> <span dir="RTL">حظر </span><span dir="RTL"> قرار  انتهاء  حالة </span> <span dir="RTL">في </span> <span dir="RTL">حتى  الإدارية  الغرامة </span> <span dir="RTL">دفع </span> <span dir="RTL">عدم </span> &nbsp;</u><u><span dir="RTL">عن </span></u></em></u></em></li>
      </ul></th>
    </tr>
  </tbody>
</table>

<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><ol start="2" type="1">
        <li><strong>Giriş Yasağı Kararına Karşı Yargı Yoluna Başvuru –<span dir="RTL"><span dir="RTL"> <span dir="RTL">الدخول </span>حظر </span> قرار </span> <span dir="RTL"><span dir="RTL"><span dir="RTL">ضد </span> للقضاء </span> طلب </span> &nbsp;</strong><span dir="RTL">تقديم </span></li>
      </ol></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 9px;" scope="col"><ul>
        <li>Şahsınız veya yasal temsilciniz ya da avukatınız tarafından, giriş yasağı kararına karşı, kararın tebliğinden itibaren 60 (altmış) gün içinde idare mahkemesine başvurulabilir. – <em><span dir="RTL">ضد </span></em><em><span dir="RTL"> الإدارية </span></em><em><span dir="RTL"> المحكمة  إلى  بطلب  التقدم </span></em><em><span dir="RTL"> محاميك  أو </span></em><em><span dir="RTL"> القانوني  ممثلك  أو  أنت </span></em> <em><span dir="RTL">يمكنك </span></em> <em><span dir="RTL">بالقرار</span></em> <em><span dir="RTL">تبليغكم </span></em> <em><span dir="RTL">تاريخ  من </span></em> <em><span dir="RTL">يومًا </span></em> <span dir="RTL">(<em><span dir="RTL">ستين</span></em>) </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>60 </span></em> <em><span dir="RTL">غضون </span></em> <em><span dir="RTL">في </span></em><em><span dir="RTL"> الدخول </span></em> <em><span dir="RTL">حظر </span></em> &nbsp;<em><span dir="RTL">قرار </span></em></li>
        <li>Mahkemeye başvuran kişi, giriş yasağı kararı veren makama da başvurusunu bildirir. –<em><span dir="RTL">الجهة </span></em> <em><span dir="RTL">بإبلاغ </span></em><em><span dir="RTL"> للمحكمة </span></em><em><span dir="RTL"> المتقدم </span></em><em><span dir="RTL"> الشخص </span></em> <em><span dir="RTL">يقوم </span></em><em><span dir="RTL"> ايضا</span></em><em><span dir="RTL"> الدخول </span></em> <em><span dir="RTL">منع </span></em> <em><span dir="RTL">قرار </span></em> <em><span dir="RTL"> اتخذت </span></em>&nbsp;<em><span dir="RTL">التي </span></em></li>
        <li>Mahkemeye yapılan başvurular giriş yasağı kararını durdurmaz. –<em><span dir="RTL">الدخول</span></em> <em><span dir="RTL">حظر </span></em><em><span dir="RTL">قرار  توقف  لا </span></em> <em><span dir="RTL">للمحكمة </span></em><em><span dir="RTL">المقدمة </span></em>&nbsp;<em><span dir="RTL">الطلبات </span></em></li>
      </ul></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 12px;" scope="col"><span style="text-align:justify; font-size:12px">Bu belge, bir nüshası avukatına/yabancıya/yasal temsilcisine verilmek üzere iki nüsha olarak hazırlanmış olup, hakkında sınır dışı etme kararı alınan yukarıda açık kimliği yazılı yabancıya kendi dilinde/anladığı dilde,&nbsp;<a name="_Hlk43631423"><em>{{TODAY}}&nbsp;&nbsp;</em></a>tarihinde ve&nbsp;&nbsp;<a name="_Hlk43631423"><em>{{TOTIME}}&nbsp;</em></a>saatinde yazılı olarak tebliğ edilmiş ve imza altına alınarak bir sureti tebellüğ edene verilmiştir. –<em><span dir="RTL">إعلام</span><span dir="RTL"> </span></em> <em><span dir="RTL">تم </span></em> <em><span dir="RTL">وقد <span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>، </span></em> القانوني</span></em> <em><span dir="RTL">ممثله <span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> / </span></em> الأجنبي<span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> / </span></em> المحامي وكيله  إلى&nbsp; </span></em><em><span dir="RTL"> واحدة  نسخة </span></em> <em><span dir="RTL">تسليم  يتم </span></em><em><span dir="RTL"> أن  على <span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> ، </span></em> نسختين</span></em><em><span dir="RTL"> شكل  على </span></em><em><span dir="RTL"> الوثيقة </span></em><em><span dir="RTL"> هذه  تنظيم </span></em> <em><span dir="RTL">تم <a name="_Hlk43631423"><em>{{TODAY}}&nbsp;</em></a><span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span></span></em>التاريخ  في  وذلك </span></em> <em><span dir="RTL">يفهمها  التي  أواللغة <span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>/ </span></em> وبلغته كتابي </span></em><span dir="RTL"><em><span dir="RTL"> بشكل  التبليغ  وتم </span></em></span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> . </span></em> <em><span dir="RTL">حقه</span></em> <em><span dir="RTL">في  الصادر  الترحيل  بقرار  أعلاه  الواضحة  هويته  المذكورة  الأجنبي </span></em> <em><span dir="RTL">بالتبليغ المخاطب  الشخص </span></em><em><span dir="RTL"> إلى  منها  نسخة </span></em> <em><span dir="RTL">وتسليم  الوثيقة  هذه  على  التوقيع </span></em> <span dir="RTL"><em><span dir="RTL">تم  وعليه </span></em></span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>{{TOTIME}}</span></em> <em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span> : </span></em> الساعة</span></em> <em><span dir="RTL"> في </span></em>&nbsp;<span dir="RTL"> </span><span dir="RTL"> </span><em><span dir="RTL"><span dir="RTL"> </span><span dir="RTL"> </span>20 </span></em></span></th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: center" scope="col"><strong>Tebliğ Eden</strong></th>
      <th style="text-align: center" scope="col"><strong>Tebellüğ Eden</strong></th>
    </tr>
    <tr>
      <th style="text-align: center" scope="row"><strong><span dir="RTL">المُبَلّْغ</span></strong></th>
      <td style="text-align: center"><strong><span dir="RTL"> إليه المًبَلَّغ </span></strong></td>
    </tr>
    <tr>
      <th style="text-align: center" scope="row"><strong>{{USER}}</strong></th>
      <td style="text-align: center"><strong>{{NAME}}</strong></td>
    </tr>
  </tbody>
</table>

	


', N'<h3 align="center">VİZE İHLALİ İŞLEM FORMU /VISA VIOLATION FORM</h3>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: left" scope="col">Adı Soyadı /Name/Surname</th>
      <th style="text-align: left" scope="col">:<strong>{{NAME}}</strong></th>
    </tr>
    <tr>
      <th style="text-align: left" scope="row">Uyruğu/ Nationality</th>
      <td style="text-align: left">:<strong>{{ORGIN}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left" scope="row">Pasaport No/Passport No</th>
      <td style="text-align: left">:<strong>{{PASSPORT}}</strong></td>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: left; font-size: 10px;" scope="col">*&nbsp;&nbsp;Ülkemize Giriş Tarihiniz ve Vize süreniz<br>
      &nbsp;&nbsp;&nbsp;&nbsp; Date of entry into country and visa validity</th>
      <th scope="col"><strong>:</strong></th>
      <th style="text-align: left" scope="col"><strong>{{EDATE}}</strong></th>
      <th style="text-align: left" scope="col"><strong>{{VDAY}}</strong> Gün / Day</th>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;&nbsp;Ülkemizden çıkış için müracaat tarihiniz<br>
      &nbsp;&nbsp;&nbsp;The date that you are applying to leave the country</th>
      <th scope="row"><strong>:</strong></th>
      <td colspan="2" style="text-align: left"><strong>{{TODAY}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;Tebliğ Edilen, Tahdit Çıkış&nbsp; veya İkamet Teskere Bitiş Tarihi / End date of notified or limitation date or residence permit</th>
      <th scope="row">:</th>
      <td colspan="2" style="text-align: left"><strong>{{SEDATE}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;&nbsp;Ülkemizden çıkış yapmanız gereken tarih<br>
      &nbsp;&nbsp;&nbsp;The date that you were meant to leave the country</th>
      <th scope="row"><strong>:</strong></th>
      <td colspan="2" style="text-align: left"><strong>{{SEDATE}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;&nbsp;Vize ihlal süreniz<br>
      &nbsp;&nbsp;&nbsp;Visa violation period</th>
      <th scope="row"><strong>:</strong></th>
      <td colspan="2" style="text-align: left"><strong>{{FINETIME}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">*&nbsp;&nbsp;Vize ihlali için ödenecek ücret<br>
      &nbsp;&nbsp;&nbsp;Penalty for visa violation</th>
      <th scope="row"><strong>:</strong></th>
      <td style="text-align: left"><strong>{{FINET}}</strong></td>
      <td style="text-align: left"><span style="font-weight: 700 !important;"><font size="2">TL</font></span><br></td>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 12px;" scope="col">Sayın<strong>&nbsp;{{NAME}}</strong>&nbsp;Ülkemizdeki yasal kalış sürenizi ihlal etmiş bulunmaktasınız. Vize ihlal ücretinizi şimdi ödediğinizden dolayı teşekkür ederiz.</th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: left; font-size: x-small;" scope="col">Dear Madame/Sir&nbsp;<strong>{{NAME}}&nbsp;</strong>&nbsp; You have exceeded the legal duration of stay in our country. Thank you in advance for paying the penalty of your visa-offence.&nbsp;<strong>{{S}}&nbsp;</strong>You will be banned from entering our country for&nbsp;<strong>{{FINEDAY}}</strong>days Entry Ban Code:{{TCODE}}{{F}}</th>
    </tr>
  </tbody>
</table>

<br>
<table align="center" width="400" border="0">
  <tbody>
    <tr>
      <td>Düzenleme Tarihi / Dated On:</td>
      <td><strong>{{TODAY}}</strong></td>
    </tr>
  </tbody>
</table>
<br>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: center" scope="col">Yolcu İmzası</th>
      <th style="text-align: center" scope="col">Pasaport Kontrol Polisi</th>
    </tr>
    <tr>
      <th style="text-align: center" scope="row">Signature of passenger</th>
      <td style="text-align: center">Passport police officer</td>
    </tr>
    <tr>
      <th style="text-align: center" scope="row"><strong>{{NAME}}</strong></th>
      <td style="text-align: center"><strong>{{POLICE}}</strong></td>
    </tr>
    <tr style="text-align: center">
      <th colspan="2" scope="row">&nbsp;</th>
    </tr>
    <tr style="text-align: center">
      <th colspan="2" scope="row">Formu okudum, imzaladım ve&nbsp;kopyasını aldım / I have read the form, signed it,and have a copy of the form</th>
    </tr>
 
    <tr style="text-align: center">
      <th colspan="2" scope="row">&nbsp;</th>
    </tr>
    <tr style="text-align: center">
      <th colspan="2" scope="row">O N A Y</th>
  </tr>
    <tr style="text-align: center">
      <th colspan="2" scope="row">APPROVAL</th>
  </tr>
    <tr><td colspan="2" scope="row"></td></tr><tr style="text-align: center">
      <th colspan="2" scope="row"><p><strong>{{USER}}</strong></p></th></tr></tbody></table>
<table width="800" border="1">
  <tbody>
  <tr>
						<th scope="col" style="width:10"><span style="font-size:10px">1</span></th>
						<td style="text-align:left"><span style="font-size:10px">İkamet Harçları 492 sayılı Harçlar kanununun 6 sayılı tarifesine göre her yıl Maliye Bakanlığınca Belirlenmektedir./</span><span style="font-size: 10px;">Residence Fees are determined by the Ministry of Finance every year according to the tariff no. 6 of the Fees Law No. 492.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:10"><span style="font-size:10px">2</span></th>
						<td style="text-align:left"><span style="font-size:10px">Hakkınızda konulmuşsa, konulan ülkemize giriş yasağının kaldırılması için Türkiye Cumhuriyeti dış temsilciliklerine özel amaçlı vize için müracaat ediniz./</span><span style="font-size: 10px;">If it has been placed about you, apply for a special purpose visa to the foreign representatives of the Republic of Turkey in order to lift the ban on entry to our country.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">3</span></th>
						<td style="text-align:left"><span style="font-size:10px">Vize ihlali nedeniyle hakkınızda uygulanan "N" veya "Ç" tahdit kodlarıyla ilgili , 60(altmış) gün içerisinde İdare mahkemesine başvuru yapmanız gerekmektedir./</span><span style="font-size: 10px;">You must apply to the Administrative Court within 60 (sixty) days regarding the "N" or "C" restriction codes applied to you due to visa violation.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">4</span></th>
						<td style="text-align:left"><span style="font-size:10px">Tahdit iş ve işlemler ile ilgili uygulamalar Göç İdaresi Genel Müdürlüğü''nün 22/07/2020 tarih ve 2020/17 sayılı genelgeye istinaden yapılmaktadır./</span><span style="font-size: 10px;">Applications related to the restriction works and transactions are made in accordance with the circular numbered 2020/17 dated 22/07/2020 of the General Directorate of Migration Management.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">5</span></th>
						<td style="text-align:left"><span style="font-size:10px">Vize ihlalinde bulunan yolcularla ilgili yurda giriş yasaklarına ilişkin uygulama 2020/17 sayılı genelgenin Madde 6''nın "A" ve "B" bendlerine istinaden uygulanır./</span><span style="font-size: 10px;">Implementation of bans on entry to the dormitory for passengers violating a visa is applied pursuant to subparagraphs "A" and "B" of Article 6 of the circular numbered 2020/17.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">6</span></th>
						<td style="text-align:left"><span style="font-size:10px">6458 Sayılı Yabancılar ve Uluslararası Koruma Kanununun "9","15","102" Maddeleri./</span><span style="font-size: 10px;">Articles "9","15","102" of the Foreigners and International Protection Law No. 6458</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">7</span></th>
						<td style="text-align:left"><span style="font-size:10px">17/03/2016 tarihli ve 29656 sayılı Yabancılar ve Uluslararası Koruma Kanununun Uygulamasına İlişkin Yönetmeliğin 8. ve 9. Maddeleri./</span><span style="font-size: 10px;">Articles 8 and 9 of the Regulation on the Implementation of the Law on Foreigners and International Protection dated 17/03/2016 and numbered 29656</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">8</span></th>
						<td style="text-align:left"><span style="font-size:10px">Göç İdaresi Başkanlığı''nın 06.01.2022 tarih ve V-157 İdari Takip Kodu Görüş Talebi Konulu Yazısı.</span><span style="font-size: 10px;">Letter of the Directorate of Migration Management, dated 06.01.2022, on V-157 Administrative Tracking Code, Request for Opinion</span></td>
					</tr>
  </tbody>
</table>

<br>{{S1}}<center><br>
<div align="center">
<p align="center"><img src="../img/goc.png" width="200" height="95" class="note-float-left" style="float: left;"></p>
</div>
<table width="800" border="0">
  <tbody>
    <tr>
      <th scope="col"><strong style="font-size: 14px; text-align: center;">Ç Kodlu Giriş Yasağı Kararı Tebliğ Formu<br>
      Code Ç – Entry Ban Notification Form</strong></th>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><strong style="font-size: 14px">Yabancıya İlişkin Bilgiler -&nbsp;</strong>Information on the Foreigner</th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="col">Adı<strong>&nbsp;-&nbsp;</strong>Name</th>
      <th colspan="2" style="font-size: 12px; text-align: left;" scope="col"><strong>{{FIRSTNAME}}</strong></th>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Soyadı&nbsp;<strong>-&nbsp;</strong>Surname</th>
      <td colspan="2" style="font-size: 12px"><strong>{{LASTNAME}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Baba Adı&nbsp;<strong>-&nbsp;</strong>Father’s Name</th>
      <td colspan="2" style="font-size: 12px"><strong>{{FATHERNAME}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Anne Adı&nbsp;<strong>-&nbsp;</strong>Mother’s Name</th>
      <td colspan="2" style="font-size: 12px"><strong>{{MOTHERNAME}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Doğum Tarihi<strong>–&nbsp;</strong>Date of Birth</th>
      <td style="font-size: 12px"><strong>{{BIRTHDATE}}</strong></td>
      <td style="font-size: 12px">Uyruğu&nbsp;<strong>-&nbsp;</strong>Nationality</td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">İletişim Dili&nbsp;<strong>-&nbsp;</strong>Communication Language</th>
      <td colspan="2" style="font-size: 12px"><strong>{{ORGIN}}</strong></td>
    </tr>
    <tr style="text-align: center; font-size: 12px;">
      <th colspan="3" scope="row"><strong>Karar ve Değerlendirmeye İlişkin Bilgiler -&nbsp;</strong>Information about the Decision and Evaluation</th>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Giriş Yasağı Kararı Başlangıç-Bitiş Tarihi<strong>&nbsp;-&nbsp;</strong>Start and End Date of Entry Ban Decision</th>
      <td style="font-size: 12px"><strong>{{TODAY}}</strong></td>
      <td style="font-size: 12px"><strong>{{CANENT}}</strong></td>
    </tr>
    <tr>
      <th style="text-align: left; font-size: 12px;" scope="row">Tahdit Kodu (Ban Code) :</th>
      <td colspan="2" style="font-size: 12px"><strong>{{TCODE}}</strong></td>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="font-size: 12px" scope="col">* Bu alana giriş yasağı kararının başlangıç tarihi yazılacaktır. –&nbsp;<em>*&nbsp;Enter start date of entry ban decision to this field.</em> <br>
      ** Bu alana giriş yasağı kararının bitiş tarihi yazılacaktır. –&nbsp;<em>**&nbsp;Enter end date of entry ban decision to this field.</em></th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align:justify; font-size: 12px;" scope="col">
      <p style="text-align:center;font-size:16px">1-Giriş Yasağı Kararı – Entry Ban Decision</p>
      <p> 6458 sayılı Yabancılar ve Uluslararası Koruma Kanunun 9 uncu maddesi uyarınca gerçekleştirilen değerlendirme neticesinde, Göç İdaresi Genel Müdürlüğü / …………. Valiliği (İl Göç İdaresi Müdürlüğü) tarafından hakkınızda giriş yasağı kararı alınmıştır.
        As a result of the evaluation conducted in accordance with the Article 9 of the Law on Foreigners and International Protection numbered 6458, Directorate General of Migration Management / Governorship of …………. (Provincial Directorate of Migration Management) has resolved to impose an entry ban on you. 
        	Hakkınızda giriş yasağı kararı alınmasına dayanak teşkil eden husus/hususlar sebebiyle; 
        	Based on the particular/particulars constituting grounds for imposing an entry ban on you;
        	İkamet izninizin iptali için gerekli işlemler başlatılacaktır. – Respective procedures will be commenced for cancelling your residence permit.
        	 Çalışma izninizin iptali için gerekli işlemler başlatılacaktır. – Respective procedures will be commenced for cancelling your work permit. 
        
        	Türkiye’ye girişinizin yasaklı olduğu süre içerisinde giriş yapmak istemeniz halinde, Türkiye Cumhuriyeti Dış Temsilciliklerinden amacına uygun (özel meşruhatlı) vize almanız gerekmektedir.
        	If you wish to enter Turkey during the period of your entry ban, you are required to obtain the relevant visa (annotated visa) from Foreign Representative Offices of the Republic of Turkey.  
        	Hakkınızda tahsis edilen giriş yasağı süresinin sona ermesi yüz seksen günde doksan gün kuralının uygulanmasına engel teşkil etmemektedir. Her halükârda vizenin veya vize muafiyetinin Türkiye’de sağladığı kalış süresi, her yüz seksen günde doksan günü geçemez.
        	 Note that the expiration of the entry ban period imposed on you does not constitute any impediment for implementing the rule of ninety days in one hundred and eighty days. In any case, the duration of stay in Turkey granted by the visa or the visa exemption cannot exceed ninety days in every one hundred and eighty days.
        
        	Hakkınızda alınan giriş yasağı kararının süresi dolmuş olsa dahi idari para cezanızı ödememenizden kaynaklanan ön izin kararına ilişkin hükümler saklıdır. 
        
        	All provisions with respect to the preliminary permission decision stemming from the non-payment of your administrative fine are reserved regardless of the expiration of the entry ban decision imposed on you.
        </p>
      <p style="text-align:center;font-size:16px">2-Giriş Yasağı Kararına Karşı Yargı Yoluna Başvuru – Resort to the Jurisdiction Against the Entry Ban Decision</p>
      <p> Şahsınız veya yasal temsilciniz ya da avukatınız tarafından, giriş yasağı kararına karşı, kararın tebliğinden itibaren 60 (altmış) gün içinde idare mahkemesine başvurulabilir. – You or your legal representative or lawyer may appeal against the entry ban decision to the Administrative Court within 60 (sixty) days from the notification of the decision.
        Mahkemeye başvuran kişi, giriş yasağı kararı veren makama da başvurusunu bildirir. – The applicant who applied to the Court also notifies the authority of the entry ban decision.
        Mahkemeye yapılan başvurular giriş yasağı kararını durdurmaz. – Applications made to the Court does not suspend the entry ban decision. 
        Bu belge, bir nüshası avukatına/yabancıya/yasal temsilcisine verilmek üzere iki nüsha olarak hazırlanmış olup, hakkında sınır dışı etme kararı alınan yukarıda açık kimliği yazılı yabancıya kendi dilinde/anladığı dilde, {{TODAY}} _ tarihinde ve {{TOTIME}} saatinde yazılı olarak tebliğ edilmiş ve imza altına alınarak bir sureti tebellüğ edene verilmiştir. </p>
      </th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 12px;" scope="col"><a name="_Hlk43631423"><em>This document has been issued in duplicate so a copy can be given to the lawyer/foreigner/legal representative and the foreigner, whose open identity is given above and upon whom the deportation decision has been imposed, has been notified in writing in his own language/language of comprehension on&nbsp;<strong>{{TODAY}}</strong>&nbsp;&nbsp;at&nbsp;<strong>{{TOTIME}}</strong>&nbsp;and one copy has been given to the notified with a signature.</em></a></th>
    </tr>
  </tbody>
</table>
<p>&nbsp;</p>


<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: center" scope="col"><strong>Tebliğ Eden -</strong><strong>Notifying Party</strong></th>
      <th style="text-align: center" scope="col"><strong>Tebellüğ Eden -</strong><strong>Notified</strong></th>
    </tr>
    <tr>
      <th style="text-align: center" scope="row"><strong>{{USER}}</strong></th>
      <td style="text-align: center"><strong>{{NAME}}</strong></td>
    </tr>
  </tbody>
</table>


{{F1}}</center>
', N'<h3 align="center">VİZE İHLALİ İŞLEM FORMU /VISA VIOLATION FORM</h3>
<table width="400" border="0">
  <tbody>
    <tr>
      <td>Adı Soyadı /Name/Surname</td>
      <td>{{NAME}}<br></td>
    </tr>
    <tr>
      <td>Uyruğu / Nationality</td>
      <td>{{ORGIN}}</td>
    </tr>
    <tr>
      <td>Pasaport No / Passport No</td>
      <td>{{PASSPORT}}</td>
    </tr>
  </tbody>
</table>
<span style="font-size: 14px"><br>
</span>
<table width="800" border="0">
  <tbody>
    <tr>
      <td colspan="2" style="font-size: 12px">
*  Ülkemize Giriş Tarihiniz ve Vize süreniz  Date of entry into country / Notification Date and visa validity</td>
      <td style="font-size: 16px"><strong>{{EDATE}}</strong></td>
      <td><table width="100%" border="0">
        <tbody>
          <tr>
            <td width="8%"><strong>{{VDAY}}</strong></td>
            <td width="9%"><strong>&nbsp;Day(s)</strong></td>
          </tr>
        </tbody>
      </table></td>
    </tr>
    <tr>
      <td colspan="2" style="font-size: 12px"><table width="100%" border="0">
        <tbody>
          <tr>
            <td>*&nbsp;&nbsp;Ülkemizden çıkış için müracaat tarihiniz/ The date that you are applying to leave the country</td>
            <td>:</td>

          </tr>
        </tbody>
      </table></td>
      <td style="font-size: 16px"><strong>{{TODAY}}</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size: 12px">*&nbsp;&nbsp;Ülkemizden çıkış yapmanız gereken tarih/ The date that you were meant to leave the country</td>
      <td style="font-size: 12px">:</td>
      <td style="font-size: 16px"><strong>{{SEDATE}}</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size: 12px">*&nbsp;&nbsp;Ülkemize giriş yapabileceğiniz tarih/&nbsp;(Giriş yasağınızın otomatik olarak iptal edileceği tarih) / &nbsp;&nbsp;&nbsp; The date on which the ban on entry will be automatically canceled&nbsp;</td>
      <td style="font-size: 12px">:</td>
      <td style="font-size: 16px"><strong>{{CANENT}}</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size: 12px">*&nbsp;Tebliğ Edilen, Tahdit Çıkış&nbsp; veya İkamet Teskere Bitiş Tarihi / End date of notified or limitation date or residence permit</td>
      <td style="font-size: 12px">:</td>
      <td style="font-size: 16px"><strong>{{SEDATE}}</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size: 12px">*&nbsp;&nbsp;Vize ihlal süreniz / Visa violation period</td>
      <td style="font-size: 12px">:</td>
      <td style="font-size: 16px"><strong>{{FINETIME}}</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td style="font-size: 12px">*&nbsp;&nbsp;Vize ihlali için ödenecek ücret / Penalty for visa violation</td>
      <td style="font-size: 12px">:</td>
      <td style="font-size: 16px"><strong>{{FINET}}</strong></td><td style="font-size: 16px"><span style="font-size: 13px; font-weight: 700 !important;"><font size="2">TL</font></span><br></td></tr></tbody></table>
<span style="font-size: 14px"><br>
</span>
<table width="800" border="0">
  <tbody>
    <tr>
      <td style="font-size: 12px"><p>Sayın&nbsp;<span style="color: rgb(0, 0, 0); font-size: 13px;">{{NAME}}</span>&nbsp;Ülkemizdeki yasal kalış sürenizi ihlal etmiş bulunmaktasınız.{{S}}Vize ihlal ücretini ödemediğiniz için hakkınızda ülkemize&nbsp;<strong>{{FINEDAY}}&nbsp;</strong>Gün giriş yasağı uygulanacaktır.&nbsp; Hakkınızda girilecek&nbsp;Tahdit kodu {{TCODE}}{{F}}</p>
       
      <hr>
      <table width="800" border="0">
  <tbody>
    <tr>
      <td> Dear Madame/Sir&nbsp;<span style="font-size: 13px;">{{NAME}}</span>&nbsp;You have overstayed your visa.{{S1}} As you have not paid the relevant fine, a  ban on your re-entering Turkey will be put into practise{{FINEDAY}}  Entry Ban Code {{TCODE}}{{F1}}</td>
    </tr>
  </tbody>
</table>

      </td>
    </tr>
  </tbody>
</table>
<span style="font-size: 14px"><br>
</span>
<table align="center" width="400" border="0">
  <tbody>
    <tr>
      <td>Düzenleme Tarihi / Dated On:</td>
      <td><strong>{{TODAY}}</strong></td>
    </tr>
  </tbody>
</table>
<span style="font-size: 14px"><br>
</span>
<table width="800" border="0">
  <tbody>
    <tr align="center">
      <td>Yolcu İmzası</td>
      <td>Pasaport Kontrol Polisi</td>
    </tr>
    <tr align="center">
      <td>Signature of passenger</td>
      <td>Passport police officer</td>
    </tr>
    <tr align="center">
      <td><strong>&nbsp;{{NAME}}</strong></td>
      <td><strong>{{POLICE}}</strong></td>
    </tr>
  </tbody>
</table>
<span style="font-size: 14px"><br>
</span>
<table width="800" border="0">
  <tbody>
    <tr>
      <td>Formu okudum, imzaladım ve kopyasını aldım / I have read the form, signed it,and have a copy of the form</td>
    </tr>
  </tbody>
</table>
<span style="font-size: 14px"><br>
</span>
<table width="800" border="0">
  <tbody>
    <tr align="center">
      <td><strong>O N A Y</strong></td>
    </tr>
    <tr align="center">
      <td>APPROVAL</td>
    </tr>
    <tr align="center">
      <td>{{USER}}</td>
    </tr>
  </tbody>
</table>
<span style="font-size: 14px"><br>
</span>
<table width="800" border="0">
  <tbody>
  <tr>
						<th scope="col" style="width:10"><span style="font-size:10px">1</span></th>
						<td style="text-align:left"><span style="font-size:10px">İkamet Harçları 492 sayılı Harçlar kanununun 6 sayılı tarifesine göre her yıl Maliye Bakanlığınca Belirlenmektedir./</span><span style="font-size: 10px;">Residence Fees are determined by the Ministry of Finance every year according to the tariff no. 6 of the Fees Law No. 492.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:10"><span style="font-size:10px">2</span></th>
						<td style="text-align:left"><span style="font-size:10px">Hakkınızda konulmuşsa, konulan ülkemize giriş yasağının kaldırılması için Türkiye Cumhuriyeti dış temsilciliklerine özel amaçlı vize için müracaat ediniz./</span><span style="font-size: 10px;">If it has been placed about you, apply for a special purpose visa to the foreign representatives of the Republic of Turkey in order to lift the ban on entry to our country.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">3</span></th>
						<td style="text-align:left"><span style="font-size:10px">Vize ihlali nedeniyle hakkınızda uygulanan "N" veya "Ç" tahdit kodlarıyla ilgili , 60(altmış) gün içerisinde İdare mahkemesine başvuru yapmanız gerekmektedir./</span><span style="font-size: 10px;">You must apply to the Administrative Court within 60 (sixty) days regarding the "N" or "C" restriction codes applied to you due to visa violation.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">4</span></th>
						<td style="text-align:left"><span style="font-size:10px">Tahdit iş ve işlemler ile ilgili uygulamalar Göç İdaresi Genel Müdürlüğü''nün 22/07/2020 tarih ve 2020/17 sayılı genelgeye istinaden yapılmaktadır./</span><span style="font-size: 10px;">Applications related to the restriction works and transactions are made in accordance with the circular numbered 2020/17 dated 22/07/2020 of the General Directorate of Migration Management.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">5</span></th>
						<td style="text-align:left"><span style="font-size:10px">Vize ihlalinde bulunan yolcularla ilgili yurda giriş yasaklarına ilişkin uygulama 2020/17 sayılı genelgenin Madde 6''nın "A" ve "B" bendlerine istinaden uygulanır./</span><span style="font-size: 10px;">Implementation of bans on entry to the dormitory for passengers violating a visa is applied pursuant to subparagraphs "A" and "B" of Article 6 of the circular numbered 2020/17.</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">6</span></th>
						<td style="text-align:left"><span style="font-size:10px">6458 Sayılı Yabancılar ve Uluslararası Koruma Kanununun "9","15","102" Maddeleri./</span><span style="font-size: 10px;">Articles "9","15","102" of the Foreigners and International Protection Law No. 6458</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">7</span></th>
						<td style="text-align:left"><span style="font-size:10px">17/03/2016 tarihli ve 29656 sayılı Yabancılar ve Uluslararası Koruma Kanununun Uygulamasına İlişkin Yönetmeliğin 8. ve 9. Maddeleri./</span><span style="font-size: 10px;">Articles 8 and 9 of the Regulation on the Implementation of the Law on Foreigners and International Protection dated 17/03/2016 and numbered 29656</span></td>
					</tr>
					<tr>
						<th scope="row" style="width:20"><span style="font-size:10px">8</span></th>
						<td style="text-align:left"><span style="font-size:10px">Göç İdaresi Başkanlığı''nın 06.01.2022 tarih ve V-157 İdari Takip Kodu Görüş Talebi Konulu Yazısı.</span><span style="font-size: 10px;">Letter of the Directorate of Migration Management, dated 06.01.2022, on V-157 Administrative Tracking Code, Request for Opinion</span></td>
					</tr>
  </tbody>
</table>

<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>


<p align="center"><img src="../img/goc.png" width="200" height="95" class="note-float-left" style="float: left;"></p>

<table width="800" border="0" align="center">
  <tbody>
    <tr align="center">
      <td>İdari Para Cezalarına İlişkin N Kodlu Ön İzin Kararı Tebliğ Formu<br>
      Notification Form for Code N Preliminary Permission Decision Regarding Administrative Fines</td>
    </tr>
  </tbody>
  
</table>

<table width="800" border="0">
  <tbody>
    <tr>
      <td align="center"><strong style="font-size: 14px">Yabancıya İlişkin Bilgiler&nbsp;–&nbsp;Information on the Foreigner</strong></td>
    </tr>
  </tbody>
</table>

<table width="800" border="1">
  <tbody>
    <tr>
      <td style="font-size: 12px">Adı –&nbsp;Name</td>
      <td style="font-size: 12px"><strong>{{FIRSTNAME}}</strong></td>
    </tr>
    <tr>
      <td style="font-size: 12px">Soyadı –&nbsp;Surname</td>
      <td style="font-size: 12px"><strong>{{LASTNAME}}</strong></td>
    </tr>
    <tr>
      <td style="font-size: 12px">Baba Adı –&nbsp;Father’s Name</td>
      <td style="font-size: 12px"><strong>{{FATHERNAME}}</strong></td>
    </tr>
    <tr>
      <td style="font-size: 12px">Anne Adı –&nbsp;Mother’s Name</td>
      <td style="font-size: 12px"><strong>{{MOTHERNAME}}</strong></td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <td>Doğum Tarihi –&nbsp;Date of Birth</td>
      <td><strong>{{BIRTHDATE}}</strong></td>
      <td>Uyruğu –&nbsp;Nationality</td>
      <td><strong>{{ORGIN}}</strong></td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <td>İletişim Dili –&nbsp;Communication Language</td>
      <td><strong>{{ORGIN}}</strong></td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <td>Karar ve Değerlendirmeye İlişkin Bilgiler –&nbsp;Information about the Decision and Evaluation</td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th width="518" rowspan="2" scope="col">Giriş Yasağı Kararı Başlangıç-Bitiş Tarihi –&nbsp;Start Date of Entry Ban Decision</th>
      <th width="53" scope="col">1-</th>
      <th width="207" scope="col">{{TODAY}}</th>
    </tr>
    <tr>
      <th scope="col">2-</th>
      <th scope="col">&nbsp;</th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="font-size: 12px" scope="col">* Bu alana giriş yasağı kararının başlangıç tarihi yazılacaktır.</th>
      <th style="font-size: 12px" scope="col">Enter start date of entry ban decision to this field</th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="font-size: 12px" scope="col">** Bu alana giriş yasağı kararının bitiş tarihi yazılacaktır.</th>
      <th style="font-size: 12px" scope="col">Enter end date of entry ban decision to this field.</th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 12px;"><li style="text-align:center"><strong>Ön İzin Kararı –&nbsp;Preliminary Permission Decision</strong></li>
        <li><strong>6458 sayılı Yabancılar ve Uluslararası Koruma Kanunun 9 uncu maddesi uyarınca gerçekleştirilen değerlendirme neticesinde,&nbsp;<a name="_Hlk43629860">………….</a>&nbsp;Valiliği (İl Göç İdaresi Müdürlüğü) tarafından hakkınızda ön izin kararı alınmıştır. –&nbsp;<em>As a result of the evaluation conducted in accordance with the Article 9 of the Law on Foreigners and International Protection numbered 6458, Governorship of&nbsp;</em>………….<em>&nbsp;(Provincial Directorate of Migration Management) has resolved to adopt a preliminary permission decision against you.</em></strong></li><em>
        <li><strong>
        Hakkınızda ön izin kararı alınmasına dayanak teşkil eden husus/hususlar sebebiyle; -&nbsp;<a name="_Hlk43632705"><em>Based on the particular/particulars constituting grounds for adopting a preliminary permission decision against you;</em></a>&nbsp;</strong></li>
        <li><strong>&nbsp;İkamet izninizin iptali için gerekli işlemler başlatılacaktır. -&nbsp;<a name="_Hlk43632761"><em>Respective procedures will be commenced for cancelling your residence permit.</em></a>&nbsp;</strong></li>
        <li><strong>Çalışma izninizin iptali için gerekli işlemler başlatılacaktır. -&nbsp;<em>Respective procedures will be commenced for cancelling your work permit.</em></strong></li>
        <li><strong><u>İdari para cezanızı ödememeniz nedeni ile hakkınızda alınan ön izin kararı, idari para cezasının ödendiğine ilişkin makbuzun idareye tebliğ edilmesi halinde kaldırılır ve&nbsp;</u>girişinize engel olacak başka bir hususun bulunmaması kaydıyla<u>&nbsp;Türkiye’ye girişinize izin verilir.</u>&nbsp;</strong></li>
        <li><strong><em>&nbsp;<u>The preliminary permission decision adopted against you on the grounds of non-payment of the administrative fine imposed on you will be rescinded provided that the receipt of payment of the respective administrative fine is submitted to the directorate</u>, and&nbsp;<u>the permission of entry to Turkey</u>&nbsp;will be granted to you on condition that no other particulars barring you from entering Turkey are determined.</em></strong></li>
        <li style="text-align:center"><strong>Ön İzin Kararına Karşı Yargı Yoluna Başvuru –&nbsp;<a name="_Hlk43633474">Resort to the Jurisdiction Against the Preliminary Permission Decision</a>&nbsp;</strong></li>
        <li><strong>Şahsınız veya yasal temsilciniz ya da avukatınız tarafından, ön izin kararına karşı, kararın tebliğinden itibaren 60 (altmış) gün içinde idare mahkemesine başvurulabilir. –&nbsp;<a name="_Hlk43633494"><em>You or your legal representative or lawyer may appeal against the preliminary permission decision to the Administrative Court within 60 (sixty) days from the notification of the decision.</em></a></strong></li>
        <li><strong>Mahkemeye başvuran kişi, ön izin kararı veren makama da başvurusunu bildirir. –&nbsp;<a name="_Hlk43633548"><em>The applicant who applied to the Court also notifies the authority of the preliminary permission decision.</em></a></strong></li>
        <li><strong>Mahkemeye yapılan başvurular ön izin kararını durdurmaz. –&nbsp;<a name="_Hlk43633568"><em>Applications made to the Court does not suspend the preliminary permission decision.</em></a></strong></li>
        <strong>
        
      </strong></em></th>
    </tr>
  </tbody>
</table>




<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align:justify; font-size:12px">Bu belge, bir nüshası avukatına/yabancıya/yasal temsilcisine verilmek üzere iki nüsha olarak hazırlanmış olup, hakkında sınır dışı etme kararı alınan yukarıda açık kimliği yazılı yabancıya kendi dilinde/anladığı dilde,&nbsp;<a name="_Hlk43631423"><em>{{TODAY}}&nbsp;&nbsp;</em></a>tarihinde ve&nbsp;&nbsp;<a name="_Hlk43631423"><em>{{TOTIME}}&nbsp;</em></a>saatinde yazılı olarak tebliğ edilmiş ve imza altına alınarak bir sureti tebellüğ edene verilmiştir. –&nbsp;<a name="_Hlk43633584"><em>This document has been issued in duplicate so a copy can be given to the lawyer/foreigner/legal representative and the foreigner, whose open identity is given above and upon whom the deportation decision has been imposed, has been notified in writing in his own language/language of comprehension on&nbsp;&nbsp;</em></a><a name="_Hlk43631423"><em>{{TODAY}}&nbsp;</em></a><a name="_Hlk43633584"><em>at&nbsp;</em></a><a name="_Hlk43631423"><em>{{TOTIME}}</em></a><em>&nbsp;and one copy has been given to the notified with a signature.</em></th>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="0" align="center">
  <tbody>
    <tr align="center">
      <th scope="col"><strong>Tebliğ Eden</strong></th>
      <th scope="col"><strong>Tebellüğ Eden</strong></th>
    </tr>
    <tr align="center">
      <th scope="row"><strong>Notifying Party</strong></th>
      <td scope="col"><strong>Notified</strong></td>
    </tr>
    <tr align="center">
      <th scope="row"><strong>{{USER}}</strong></th>
      <td><strong>{{NAME}}</strong></td>
    </tr>
  </tbody>
</table>
<p>&nbsp;</p>

<p align="center"><span style="text-align: left;"><br>{{ÇS}}</span><br></p>


<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>

<p align="center"><img src="../img/goc.png" width="200" height="95" class="note-float-left" style="float: left;"></p>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th> Ç Kodlu Giriş Yasağı Kararı Tebliğ Formu / Code Ç – Entry Ban Notification Form</th>
    </tr>
  </tbody>
</table>
<br>
<table width="800" border="0">
  <tbody>
    <tr>
      <th scope="col">Yabancıya İlişkin Bilgiler – Information on the Foreigner</th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><strong>Adı –&nbsp;</strong>Name</th>
      <th scope="col">{{FIRSTNAME}}</th>
    </tr>
    <tr>
      <th scope="row"><strong>Soyadı –&nbsp;</strong>Surname</th>
      <td>{{LASTNAME}}</td>
    </tr>
    <tr>
      <th scope="row"><strong>Baba Adı –&nbsp;</strong>Father’s Name</th>
      <td>{{FATHERNAME}}</td>
    </tr>
    <tr>
      <th scope="row"><strong>Anne Adı –&nbsp;</strong>Mother’s Name</th>
      <td>{{MOTHERNAME}}</td>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><strong>Doğum Tarihi –&nbsp;</strong>Date of Birth</th>
      <th scope="col">{{BIRTHDATE}}</th>
      <th scope="col"><strong>Uyruğu –&nbsp;</strong>Nationality</th>
      <th scope="col">{{ORGIN}}</th>
    </tr>
    <tr>
      <th scope="row"><strong>İletişim Dili –&nbsp;</strong>Communication Language</th>
      <th colspan="3" scope="row">{{ORGIN}}</th>
    </tr>
    <tr>
      <th colspan="4" scope="row"><strong>Karar ve Değerlendirmeye İlişkin Bilgiler –&nbsp;</strong>Information about the Decision and Evaluation</th>
    </tr>
    <tr>
      <th colspan="4" scope="row"><strong>Giriş Yasağı Kararı Başlangıç-Bitiş Tarihi –&nbsp;</strong>Start and End Date of Entry Ban Decision</th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><strong>Giriş Yasağı Kararı Başlangıç-Bitiş Tarihi –&nbsp;</strong>Start and End Date of Entry Ban Decision</th>
      <th scope="col">{{TODAY}}</th>
      <th scope="col">{{CANENT}}</th>
    </tr>
    <tr>
      <th scope="col"><strong>Tahdit Kodu / Restriction Code</strong></th>
      <th colspan="2" scope="col"><h5>{{TCODE}}</h5></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col">* Bu alana giriş yasağı kararının başlangıç tarihi yazılacaktır. –&nbsp;<em>*&nbsp;</em><em>Enter start date of entry ban decision to this field.</em> <br>
      ** Bu alana giriş yasağı kararının bitiş tarihi yazılacaktır. –&nbsp;<em>**&nbsp;</em><em>Enter end date of entry ban decision to this field.</em></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><ol start="1" type="1">
        <li><strong>Giriş Yasağı Kararı –&nbsp;</strong><strong>Entry Ban Decision</strong></li>
      </ol></th>
    </tr>
  </tbody>
</table>

<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col">6458 sayılı Yabancılar ve Uluslararası Koruma Kanunun 9 uncu maddesi uyarınca gerçekleştirilen değerlendirme neticesinde, Göç İdaresi Genel Müdürlüğü / …………. Valiliği (İl Göç İdaresi Müdürlüğü) tarafından hakkınızda giriş yasağı kararı alınmıştır. –&nbsp;<em>As a result of the evaluation conducted in accordance with the Article 9 of the Law on Foreigners and International Protection numbered 6458, Directorate General of Migration Management / Governorship of …………. (Provincial Directorate of Migration Management) has resolved to impose an entry ban on you.</em></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 9px;" scope="col"><ul>
        <li>Hakkınızda giriş yasağı kararı alınmasına dayanak teşkil eden husus/hususlar sebebiyle; -&nbsp;<em>Based on the particular/particulars constituting grounds for imposing an entry ban on you;</em></li>
        <li><em>İkamet izninizin iptali için gerekli işlemler başlatılacaktır. –&nbsp;<a name="_Hlk43630024"><em>Respective procedures will be commenced for cancelling your residence permit.</em></a>&nbsp;</em></li>
        <li><em>Çalışma izninizin iptali için gerekli işlemler başlatılacaktır. –&nbsp;<em>Respective procedures will be commenced for cancelling your work permit.</em></em></li>
        <li><u>Türkiye’ye girişinizin yasaklı olduğu süre içerisinde giriş yapmak istemeniz halinde, Türkiye Cumhuriyeti Dış Temsilciliklerinden amacına uygun (özel meşruhatlı) vize almanız gerekmektedir. –&nbsp;</u><em><u>If you wish to enter Turkey during the period of your entry ban, you are required to obtain the relevant visa (annotated visa) from Foreign Representative Offices of the Republic of Turkey.&nbsp;</u></em></li>
        <li><em><u>Hakkınızda tahsis edilen giriş yasağı süresinin sona ermesi yüz seksen günde doksan gün kuralının uygulanmasına engel teşkil etmemektedir. Her halükârda vizenin veya vize muafiyetinin Türkiye’de sağladığı kalış süresi, her yüz seksen günde doksan günü geçemez. –&nbsp;<em>Note that the expiration of the entry ban period imposed on you does not constitute any impediment for implementing the rule of ninety days in one hundred and eighty days. In any case, the duration of stay in Turkey granted by the visa or the visa exemption cannot exceed ninety days in every one hundred and eighty days.</em></u></em></li>
        <li><em><u><em><u>Hakkınızda alınan giriş yasağı kararının süresi dolmuş olsa dahi idari para cezanızı ödememenizden kaynaklanan ön izin kararına ilişkin hükümler saklıdır. -&nbsp;</u><em><u>All provisions with respect to the preliminary permission decision stemming from the non-payment of your administrative fine are reserved regardless of the expiration of the entry ban decision imposed on you.</u></em></em></u></em></li>
      </ul></th>
    </tr>
  </tbody>
</table>

<table width="800" border="1">
  <tbody>
    <tr>
      <th scope="col"><ol start="2" type="1">
        <li><strong>Giriş Yasağı Kararına Karşı Yargı Yoluna Başvuru –&nbsp;</strong><strong>Resort to the Jurisdiction Against the Entry Ban Decision</strong></li>
      </ol></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 9px;" scope="col"><ul>
        <li>Şahsınız veya yasal temsilciniz ya da avukatınız tarafından, giriş yasağı kararına karşı, kararın tebliğinden itibaren 60 (altmış) gün içinde idare mahkemesine başvurulabilir. –&nbsp;<a name="_Hlk43631319"><em>You or your legal representative or lawyer may appeal against the entry ban decision to the Administrative Court within 60 (sixty) days from the notification of the decision.</em></a></li>
        <li>Mahkemeye başvuran kişi, giriş yasağı kararı veren makama da başvurusunu bildirir. –&nbsp;<a name="_Hlk43631350"><em>The applicant who applied to the Court also notifies the authority of the entry ban decision.</em></a></li>
        <li>Mahkemeye yapılan başvurular giriş yasağı kararını durdurmaz. –&nbsp;<a name="_Hlk43631381"><em>Applications made to the Court does not suspend the entry ban decision.</em></a></li>
      </ul></th>
    </tr>
  </tbody>
</table>
<table width="800" border="1">
  <tbody>
    <tr>
      <th style="text-align: justify; font-size: 12px;" scope="col">Bu belge, bir nüshası avukatına/yabancıya/yasal temsilcisine verilmek üzere iki nüsha olarak hazırlanmış olup, hakkında sınır dışı etme kararı alınan yukarıda açık kimliği yazılı yabancıya kendi dilinde/anladığı dilde,&nbsp;<strong>{{TODAY}}</strong>&nbsp;tarihinde ve&nbsp;<strong>{{TOTIME}}</strong>&nbsp;saatinde yazılı olarak tebliğ edilmiş ve imza altına alınarak bir sureti tebellüğ edene verilmiştir. –&nbsp;<a name="_Hlk43631423"><em>This document has been issued in duplicate so a copy can be given to the lawyer/foreigner/legal representative and the foreigner, whose open identity is given above and upon whom the deportation decision has been imposed, has been notified in writing in his own language/language of comprehension on {{TODAY}} at {{TOTIME}} and one copy has been given to the notified with a signature.</em></a></th>
    </tr>
  </tbody>
</table>
<table width="800" border="0">
  <tbody>
    <tr>
      <th style="text-align: center" scope="col"><strong>Tebliğ Eden</strong></th>
      <th style="text-align: center" scope="col"><strong>Tebellüğ Eden</strong></th>
    </tr>
    <tr>
      <th style="text-align: center" scope="row"><strong>Notifying Party</strong></th>
      <td style="text-align: center"><strong>Notified</strong></td>
    </tr>
    <tr>
      <th style="text-align: center" scope="row"><strong>{{USER}}</strong></th>
      <td style="text-align: center"><strong>{{NAME}}</strong></td>
    </tr>
  </tbody>
</table>');
        SET IDENTITY_INSERT [dbo].[E_Forms] OFF;
        PRINT 'Tablo [dbo].[E_Forms] icin 1 kayit eklendi.';
    END
END
GO

-- --------------------------------------------------------------------------
-- Veri: [dbo].[E_TGVH]
-- --------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[E_TGVH]', N'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dbo].[E_TGVH])
    BEGIN
        SET IDENTITY_INSERT [dbo].[E_TGVH] ON;
        INSERT INTO [dbo].[E_TGVH] ([fldId], [fldPrice], [fldTypeofMoney], [fldYear]) VALUES
            (17, N'9376,40', N'TRY', N'2026');
        SET IDENTITY_INSERT [dbo].[E_TGVH] OFF;
        PRINT 'Tablo [dbo].[E_TGVH] icin 1 kayit eklendi.';
    END
END
GO

-- --------------------------------------------------------------------------
-- Veri: [dbo].[Categories]
-- --------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[Categories]', N'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Categories])
    BEGIN
        SET IDENTITY_INSERT [dbo].[Categories] ON;
        INSERT INTO [dbo].[Categories] ([CategoryId], [CategoryName], [Description], [IsActive]) VALUES
            (1, N'PASAPORT', N'', 1),
            (2, N'GENELGE', N'', 1),
            (3, N'SAHTE BELGELER', N'', 1),
            (4, N'HABERLER', N'', 1),
            (5, N'KANUN', N'', 1),
            (6, N'ORJİNAL BELGELER', N'', 1),
            (7, N'Ön İzin Kodları (N)', NULL, 1),
            (8, N'İdari Durum Kodları', NULL, 1),
            (9, N'Bilgi Kodları (V)', NULL, 1),
            (12, N'Güvenlik Kodları (G)', NULL, 1),
            (13, N'Giriş Yasakları (Ç)', NULL, 1),
            (14, N'Uluslararası Koruma (O)', NULL, 1),
            (15, N'PRADO Belge Eğitimleri', N'PRADO belgelerinden oluşturulan eğitimler', 1),
            (16, N'Web Kaynaklı Belge Eğitimleri', N'PRADO, Regula, EdisonTD ve benzeri web kaynaklarından oluşturulan eğitimler', 1);
        SET IDENTITY_INSERT [dbo].[Categories] OFF;
        PRINT 'Tablo [dbo].[Categories] icin 14 kayit eklendi.';
    END
END
GO

-- --------------------------------------------------------------------------
-- Veri: [dbo].[DocumentTerms]
-- --------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[DocumentTerms]', N'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dbo].[DocumentTerms])
    BEGIN
        SET IDENTITY_INSERT [dbo].[DocumentTerms] ON;
        INSERT INTO [dbo].[DocumentTerms] ([Id], [Term], [Slug], [Category], [Definition], [DetailedDescription], [ImageUrl], [RelatedTerms], [IsActive], [CreatedAt], [UpdatedAt], [Sicil], [AdSoyad]) VALUES
            (242, N'INK-JET (MÜREKKEP PÜSKÜRTME) BASKI', N'ink-jet-murekkep-puskurtme-baski', N'PASAPORT', N'Kartuş içerisinde bulunan mürekkebin sıkıştırılması sonucu püskürtülerek kağıt üzerine yapıştırılması mantığı ile çalışır. Basımı yapılan karakterler (resim veya yazılar) mercek altında incelendiğinde mürekkep tanelerinin düzensiz ve kenar hatlarının dağınık olduğu gözlemlenmektedir.  Piyasada çeşitli çalışma sistemlerine sahip ve çeşitli mürekkep kullanımı yapan İnk-jet baskı makineleri mevcuttur. Bu nedenle görünüş çeşitliliği çok fazladır. Ancak hepsinin ortak noktası mürekkep tanelerinin düzensizliği ve keskin olmayan kenar hatlarıdır. Bu özellik sayesinde ink-jet baskı diğer baskı çeşitlerinden ayırt edilebilmektedir.', N'<p><img src="/Uploads/DocumentTerms/6548d246-990d-4c2a-8f7d-96803f8b9451.png" style="width: 626px;"></p><p><img src="/Uploads/DocumentTerms/8229e619-b65e-433e-9784-15ed9dad8201.png" style="width: 352px;"><img src="/Uploads/DocumentTerms/4c2f36ef-7a86-44ac-8396-22c912dc8562.png" style="width: 777px;"><br></p><p><br></p>', NULL, N'ınk-jet,kişiselleştirme,fotoğraf,dijitalbaskı', 1, '2026-04-09 14:11:06.847', NULL, N'247833', N'SERVİN KÖSE'),
            (243, N'RENKLİ LAZER BASKI', N'renkli-lazer-baski', N'PASAPORT', N'Dijital baskı sistemlerinden bir tanesi de tonerli yazıcılardır. Her tür baskı da olduğu gibi CMYK renkleri dediğimiz (Cyan (Cam göbeği-mavi). Magenta (Fuşya-Kırmızı), Yellow (Sarı), Key (Siyah)) renkler ile baskı yapmaktadır. Her renk toner belge üzerine sırayla ve sabit açılar ile basılmaktadır. Bu baskıda baskın renk kırmızı olduğundan basımı yapılan alanlar büyütülerek incelendiğinde düzenli kırmızı noktalar  net bir şekilde görülmektedir. İnk-jet baskıdan farklı olarak bu baskı da mürekkep taneleri düzenlidir ve diğer baskılardan ayırımı bu şekilde yapılmaktadır.  ', N'<p><img src="/Uploads/DocumentTerms/a4994dd3-5ced-4eda-ae66-f353b9dadee0.png" style="width: 416px;"><img src="/Uploads/DocumentTerms/8bd4552f-c159-44a4-bb81-3b5dc88e0c56.png" style="width: 529px;"></p><p><img src="/Uploads/DocumentTerms/08f1a315-e437-406b-9288-bc4e2b14fb94.png" style="width: 453px;"><br></p><p><br></p>', NULL, N'lazer,renklilazer,baskı,kişiselleştirme,dijital', 1, '2026-04-09 14:41:28.980', NULL, N'247833', N'SERVİN KÖSE'),
            (244, N'CLIP-ID', N'clip-id', N'PASAPORT', N'FOLYO BASKI İLE LAZER GRAVÜR BASKININ KOMBİNASYONUDUR. RESİM AÇIK VE KOYU RENKLER OLMAK ÜZERE İKİ AYRI GÖRÜNTÜYE AYIRILARAK BELGEYE İŞLENİR ', N'<p><img src="/Uploads/DocumentTerms/dbde51d0-8889-4c6c-ab35-6d136e150362.png" style="width: 1206px;"><br></p>', NULL, N'CLIP-ID, resim,fotoğraf,kişiselleştirme', 1, '2026-04-09 14:56:22.660', NULL, N'247833', N'SERVİN KÖSE'),
            (245, N'RENKLİ LAZER KALKANI (COLOR LASER SHIELD)', N'renkli-lazer-kalkani-color-laser-shield', N'PASAPORT', N'POLİKARBON BELGE ÜRETİM AŞAMASINDA ALT KATMANA ENTEGRE EDİLEN MÜREKKEP PİGMENTLERİNİN FARKLI LAZER IŞIKLARI İLE SOLDURULMASI PRENSİBİNE GÖRE ÇALIŞIR. HER ANA RENK İÇİN 256 TON OLUŞTURULABİLİR. 800 DPİ DEN 1200 DPİ ÇÖZÜNÜRLÜĞE KADAR GÖRÜNTÜ KALİTESİ ALINABİLİR. 0,25 MM BOTUNDA MİKRO METİNLER EKLENEBİLİR.   
', N'<p><img src="/Uploads/DocumentTerms/bc1dab9d-7c71-4b05-b0e0-ca708bbb2f0b.png" style="width: 548px;"><img src="/Uploads/DocumentTerms/56d3a990-54cf-4fea-93d8-7c5b5f890e8e.png" style="width: 549px;"><br></p>', NULL, N'colorlasershield,renklilazerkalkanı,fotoğraf,resim,kişiselleştirme', 1, '2026-04-09 14:58:14.200', NULL, N'247833', N'SERVİN KÖSE'),
            (246, N'FOTOĞRAFİK BASKI', N'fotografik-baski', N'PASAPORT', N'Optik bir cihazla ışığa duyarlı bir film üzerine görüntü elde etmeyi ve bu görüntüleri kimyasal yöntemlerle fotoğraf kağıdına aktarmayı sağlayan bir işlemdir. Kısaca vesikalık fotoğraflar örnek olarak gösterilebilir. ', N'<p><img src="/Uploads/DocumentTerms/b9d89f7d-ef21-4148-9c3b-bd8dfd75c7d4.png" style="width: 1101px;"><br></p>', NULL, N'fotoğrafikbaskı,resim,fotoğraf,kişiselleştirme', 1, '2026-04-09 14:59:34.420', NULL, N'247833', N'SERVİN KÖSE'),
            (247, N'EMNİYET TELİ', N'emniyet-teli', N'PASAPORT', N'Kağıt yapım aşamasında belgeye entegre edilen güvenlik unsularından biridir. Üzerine çeşitli teknolojiler ile mikro yazılar yazılar dahil edilebilmektedir .Işığın geliş açısına bağlı olarak renk değiştiren, hareketli, holografik, ısı ile renk değişimi yapabilen, mikro yansıtmalı gibi pek çok türü bulunmaktadır. Üzerinde bulunan mikro yazılar büyüteç ve alttan vuran ışık yardımı ile incelenebilir. Uv ışık altında incelendiğinde renkli parlama yapabilmektedir.  
', N'<p><img src="/Uploads/DocumentTerms/2913315f-6b30-4561-bf41-52c545c3f0e3.png" style="width: 281px;"></p><p><img src="/Uploads/DocumentTerms/8230a996-7b76-4a80-a9f9-bce6c6725cb4.png" style="width: 1147px;"></p><p><img src="/Uploads/DocumentTerms/5accf0ec-eff9-4f8c-9e06-9dc5585f67ed.png" style="width: 1141px;"><br></p>', NULL, N'emniyetteli', 1, '2026-04-09 15:05:03.090', NULL, N'247833', N'SERVİN KÖSE'),
            (248, N'FİLİGRAN', N'filigran', N'PASAPORT', N'Kağıt yapım aşamasında belgeye entegre edilen güvenlik unsularından biridir. Filigran yapımında farklı kağıt makineleri kullanılabilmektedir. Ancak kalıp yapımı ve farklı filigran çeşitlerinin aynı anda kağıt üzerinde oluşturulması açısından en kullanışlısı silindir kalıp makineleridir. Kalıp üzerinde bulunan desenler henüz kurumamış olan kağıt hamuru üzerine baskı yapılması sureti ile aktarılır. Yapım aşamalarına göre tek tonlu, çift tonlu ve çok tonlu (portre filigran) olmak üzere 3 gruba ayrılır. Alttan vuran ışık kaynağında kontrol edilir. Filigranlar UV ışık altında görünmez.  
', N'<p><img src="/Uploads/DocumentTerms/4514f98b-4c03-4cfd-a0e4-f0a287856ca6.png" style="width: 889px;"><img src="/Uploads/DocumentTerms/94850772-e593-48fa-916e-7560b6e179b8.png" style="width: 1157px;"><img src="/Uploads/DocumentTerms/d4c976e9-8bf5-4e85-a2a4-805fdf15fbcc.png" style="width: 917px;"><br></p>', NULL, N'filigran,securocoreprint,güvenliçekirdekbaskı', 1, '2026-04-09 15:09:26.070', NULL, N'247833', N'SERVİN KÖSE'),
            (249, N'FLUOFORMS', N'fluoforms', N'PASAPORT', N'Kağıt yapım aşamasında belgeye entegre edilen güvenlik unsularından biridir. Bir çeşit planşet türüdür. Üzerine ülkelerin talepleri doğrultusunda amblemler yada yazılar basılabilir. Uv ışık kaynağı altında incelenirler. Kazakistan pasaportlarında kullanılan fluoformlar üzerinde Kazakistan bayrağı mevcuttur. 
', N'<p><img src="/Uploads/DocumentTerms/7424edf1-f69a-4eee-83c4-6c2986341925.png" style="width: 952px;"></p><p><img src="/Uploads/DocumentTerms/00261ec5-c0ef-486d-8be1-6b73256ec382.png" style="width: 791px;"><img src="/Uploads/DocumentTerms/38a44223-100c-4fbe-8c8d-574c326dc580.png" style="width: 592px;"><br></p>', NULL, N'fluoforms,planşet', 1, '2026-04-09 15:11:24.143', NULL, N'247833', N'SERVİN KÖSE'),
            (250, N'HI-LITES', N'hi-lites', N'PASAPORT', N'Kağıt yapım aşamasında belgeye entegre edilen güvenlik unsularından biridir. Kağıt süspansiyonu içerisine gelişi güzel altılarak karıştırıldığı için kağıt üzerinde herhangi bir standart dizilimi yoktur. Bu nedenle her sayfada farklı yerlerde konumlanırlar. Uv ışık altında kontrol edilebilmektedir. ', N'<p><img src="/Uploads/DocumentTerms/3027c451-4390-4f29-9463-f5b527071ad0.png" style="width: 893px;"><img src="/Uploads/DocumentTerms/816604dd-ea75-41ed-acca-beee0a461d40.png" style="width: 1043px;"><br></p>', NULL, N'hi-lites', 1, '2026-04-09 15:12:51.470', NULL, N'247833', N'SERVİN KÖSE'),
            (251, N'ISI SÜBLİMASYON BASKI (THERMOSUBLIMATİON)', N'isi-sublimasyon-baski-thermosublimation', N'PASAPORT', N'Isıtma yöntemi ile folyo üzerinde bulunan mürekkebin gaz haline geçerek taşıyıcı materyale aktarılması yöntemidir. Resim yakından incelendiğinde mürekkep taneleri bulunmadığı ve flu olduğu gözlemlenmektedir. ', N'<p><img src="/Uploads/DocumentTerms/b85c38d2-a802-4db7-a58a-9e2061ab081b.png" style="width: 1000px;"><br></p>', NULL, N'thermosublimation,ısıtransfer,kişiselleştirme,fotoğraf,resim', 1, '2026-04-09 15:14:25.843', NULL, N'247833', N'SERVİN KÖSE'),
            (252, N'ISI TRANSFER BASKI(THERMO TRANSFER)', N'isi-transfer-baskithermo-transfer', N'PASAPORT', N'Isıtma ve basınç yöntemi ile folyo üzerinde bulunan mürekkebin taşıyıcı materyale aktarılması yöntemidir. Baskı neticesinde özellikle eğimli olan harflerin kenar kısımlarında merdiven basamağı şeklinde bir görüntü oluşur. Resim yakından incelendiğinde ise kırmızı ve siyah mürekkep taneleri baskın olarak gözlemlenmektedir.', N'<p><img src="/Uploads/DocumentTerms/caa44da6-5795-44e9-8cd6-5914fe6f3cbb.png" style="width: 604px;"><img src="/Uploads/DocumentTerms/41897ef0-874f-4b23-8767-3987728f79d6.png" style="width: 595px;"><img src="/Uploads/DocumentTerms/548c233c-ebdb-467e-a496-ef2bdbf52331.png" style="width: 980px;"><br></p>', NULL, N'ısıtransfer,thermotransfer,fotoğraf,resim,kişiselleştirme', 1, '2026-04-09 15:16:00.313', NULL, N'247833', N'SERVİN KÖSE'),
            (253, N'KILCAL LİF', N'kilcal-lif', N'PASAPORT', N'Kağıt yapım aşamasında belgeye entegre edilen güvenlik unsularından biridir. Kağıt süspansiyonu içerisine gelişi güzel atılarak karıştırıldığı için kağıt üzerinde herhangi bir standart dizilimi yoktur. Bu nedenle her sayfada farklı yerlerde konumlanırlar. Uv ışık altında kontrol edilebilmektedir. ', N'<p><img src="/Uploads/DocumentTerms/e1b00ce8-410c-49fd-9cf7-33c01eadc6e5.png" style="width: 1282px;"><img src="/Uploads/DocumentTerms/90865152-bd2d-4570-b16a-5c5d8e371f05.png" style="width: 1282px;"><img src="/Uploads/DocumentTerms/dd244295-3a7b-4c43-8f8b-4d2781e007d7.png" style="width: 549px;"><img src="/Uploads/DocumentTerms/2fdb0675-26f9-4c49-8a21-49e7bf88e093.png" style="width: 399px;"><br></p>', NULL, N'kılcallif', 1, '2026-04-09 15:21:05.540', NULL, N'247833', N'SERVİN KÖSE'),
            (254, N'LASINK', N'lasink', N'PASAPORT', N'Lazer Gravür ve Ofset baskının kombin versiyonudur. Polikarbon belge birleştirilmeden önce fotoğrafın geleceği alana ofset baskı ile sıralı olarak çizgiler halinde CMYK renkleri basılmaktadır. Belge bir araya getirildikten sonra ise lazer gravür baskı ile bu bölüme özel bir hesaplama ile şahısın görüntüsü yakılır. Böylelikle belge sahibine ait fotoğraf renkli olarak basılmış olur.', N'<p><img src="/Uploads/DocumentTerms/81c48613-5208-4d98-8cf8-a0041100911a.png" style="width: 656px;"><br><img src="/Uploads/DocumentTerms/bb6f12ac-a8a7-4bb5-86ef-ab9bca2210ba.png" style="width: 566px;"></p>', NULL, N'lasink,fotoğraf,kişiselleştirme,resim', 1, '2026-04-09 15:36:37.743', NULL, N'247833', N'SERVİN KÖSE'),
            (255, N'LAZER GRAVÜR', N'lazer-gravur', N'PASAPORT', N'Lazer gravür, odaklanmış lazer ışınını kullanılarak polikarbon belgenin lamine alt katmanlarında yakma işlemi ile kalıcı şekil oluşturan hassas bir işaretleme tekniğidir.
 ', N'<p><img src="/Uploads/DocumentTerms/f06336c1-fe38-433c-8813-5a638f4afcf7.png" style="width: 395px;"><img src="/Uploads/DocumentTerms/1b8af2c3-2bce-4ff5-bdd9-90176f57d941.png" style="width: 647px;"></p><p><img src="/Uploads/DocumentTerms/9e7ab1b9-1cdb-4c90-98a6-bf63c4686454.png" style="width: 1191px;"><br></p>', NULL, N'lazergravür,laserengraved,resim,fotoğraf,kişiselleştirme', 1, '2026-04-09 15:38:57.240', NULL, N'247833', N'SERVİN KÖSE'),
            (256, N'POLİKARBON RENK SÜRECİ', N'polikarbon-renk-sureci', N'PASAPORT', N'Almanya’ya ait belgelerde karşımıza çıkan bir baskı teknolojisidir. İnk-jet baskı ile renkli resim polikarbon belge katmanları arasına entegre edilmektedir.', N'<p><img src="/Uploads/DocumentTerms/9bfca5eb-1afd-4097-a598-71a1c67abe49.png" style="width: 1109px;"><br></p>', NULL, N'polikarbonrenksüreci,kişiselleştirme,resim,fotoğraf', 1, '2026-04-09 15:39:55.897', NULL, N'247833', N'SERVİN KÖSE'),
            (257, N'SECURE CORE PRINT (GÜVENLİ ÇEKİRDEK BASKI)', N'secure-core-print-guvenli-cekirdek-baski', N'PASAPORT', N'Güvenli çekirdek baskı polikarbon belgeler için filigran açığını kapatmak amacı ile üretilmiştir. Baskı yolu ile yapılan bir desen polikarbon katmanları arasında yerleştirilmektedir. Alttan vuran ışıkda filigranlar gibi kontrolü yapılmaktadır. ', N'<p><img src="/Uploads/DocumentTerms/28d2f19d-6f79-4a46-90ec-26ef4b1469cc.png" style="width: 1113px;"><img src="/Uploads/DocumentTerms/efa27d81-3ae0-43a9-9a7b-a8fed8a75876.png" style="width: 709px;"><img src="/Uploads/DocumentTerms/3f3ccfcb-465c-4c26-b101-34f3f5db67df.png" style="width: 403px;"><br></p>', NULL, N'securecoreprint,güvenliçekirdekbaskı,filigran,polikarbon', 1, '2026-04-09 15:44:04.030', NULL, N'247833', N'SERVİN KÖSE'),
            (258, N'PLANŞET', N'planset', N'PASAPORT', N'Kağıt yapım aşamasında belgeye entegre edilen güvenlik unsularından biridir. Kağıt süspansiyonu içerisine gelişi güzel atılarak karıştırıldığı için kağıt üzerinde herhangi bir standart dizilimi yoktur. Bu nedenle her sayfada farklı yerlerde konumlanırlar. Uv ışık altında kontrol edilebilmektedir. Yuvarlak yada çokgen parçacıklar şeklinde üretilmektedir. ', N'<p><img src="/Uploads/DocumentTerms/80696711-52f2-4bd9-a9a3-23b156cf002f.png" style="width: 1282px;"><img src="/Uploads/DocumentTerms/722204ac-a106-4cd4-b039-df490bb0baca.png" style="width: 1014px;"></p><p><img src="/Uploads/DocumentTerms/1a5e98f3-f917-4892-ab0c-7ba300c8f1a4.png" style="width: 461px;"><img src="/Uploads/DocumentTerms/37803df6-bf1b-4090-a0a3-c772b9177301.png" style="width: 812px;"><br></p>', NULL, N'planşet,uvışık', 1, '2026-04-09 15:46:51.577', NULL, N'247833', N'SERVİN KÖSE');
        SET IDENTITY_INSERT [dbo].[DocumentTerms] OFF;
        PRINT 'Tablo [dbo].[DocumentTerms] icin 17 kayit eklendi.';
    END
END
GO

-- --------------------------------------------------------------------------
-- Veri: [dbo].[E_Dilekce]
-- --------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[E_Dilekce]', N'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dbo].[E_Dilekce])
    BEGIN
        SET IDENTITY_INSERT [dbo].[E_Dilekce] ON;
        INSERT INTO [dbo].[E_Dilekce] ([DilekceId], [AdSoyad], [DogumTarih], [DogumYeri], [PasaportNo], [KimlikNo], [Adres], [Telefon], [Uyruk], [DilekceTarih], [Tarih1], [Tarih2], [DilekceSebep], [Valilik], [DosyaNo], [Unvan], [Aciklama], [Sicil]) VALUES
            (1, N'JANA SOHL', '1965-05-10 00:00:00.000', N'ALMANYA', N'C8YMLK2YY', NULL, NULL, NULL, N'Almanya', '2025-09-16 00:00:00.000', '2024-09-16 00:00:00.000', '2025-09-16 00:00:00.000', N'Evlilik İşlemleri İçin', N'ANTALYA', N'2025/355                                          ', N'Polis Memuru', N'<table border="0" cellpadding="0" cellspacing="0" style="width:1025px;" width="1024">
	<colgroup>
		<col />
		<col />
		<col span="2" />
		<col />
		<col />
		<col />
		<col />
		<col />
		<col />
	</colgroup>
	<tbody>
		<tr height="20">
			<td height="20" style="height:20px;width:64px;">
				BelgeTuru</td>
			<td style="width:100px;">
				BelgeSeriNo</td>
			<td style="width:64px;">
				Ad</td>
			<td style="width:64px;">
				Soyad</td>
			<td style="width:103px;">
				DogumTarihi</td>
			<td style="width:64px;">
				Cinsiyet</td>
			<td style="width:127px;">
				Tarih</td>
			<td style="width:252px;">
				KapiKodu</td>
			<td style="width:104px;">
				GirisCikisTipi</td>
			<td style="width:84px;">
				UlkeKodu</td>
		</tr>
		<tr height="20">
			<td height="20" style="height:20px;">
				Y</td>
			<td>
				C8YMLK2YY</td>
			<td>
				JANA</td>
			<td>
				SOHL</td>
			<td>
				10.05.1965</td>
			<td>
				Kadın</td>
			<td>
				15.09.2025 00:27:58</td>
			<td>
				Antalya Hava Limanı</td>
			<td>
				Giriş</td>
			<td>
				ALMANYA</td>
		</tr>
		<tr height="20">
			<td height="20" style="height:20px;">
				Y</td>
			<td>
				C8YMLK2YY</td>
			<td>
				JANA</td>
			<td>
				SOHL</td>
			<td>
				10.05.1965</td>
			<td>
				Kadın</td>
			<td>
				28.08.2025 14:08:19</td>
			<td>
				Antalya Hava Limanı</td>
			<td>
				&Ccedil;ıkış</td>
			<td>
				ALMANYA</td>
		</tr>
		<tr height="20">
			<td height="20" style="height:20px;">
				Y</td>
			<td>
				C8YMLK2YY</td>
			<td>
				JANA</td>
			<td>
				SOHL</td>
			<td>
				10.05.1965</td>
			<td>
				Kadın</td>
			<td>
				9.07.2025 23:03:52</td>
			<td>
				Mersin Taşucu-Seka Deniz Hudut Kapısı</td>
			<td>
				Giriş</td>
			<td>
				ALMANYA</td>
		</tr>
		<tr height="20">
			<td height="20" style="height:20px;">
				Y</td>
			<td>
				C8YMLK2YY</td>
			<td>
				JANA</td>
			<td>
				SOHL</td>
			<td>
				10.05.1965</td>
			<td>
				Kadın</td>
			<td>
				8.04.2025 21:50:33</td>
			<td>
				Mersin Taşucu-Seka Deniz Hudut Kapısı</td>
			<td>
				&Ccedil;ıkış</td>
			<td>
				ALMANYA</td>
		</tr>
		<tr height="20">
			<td height="20" style="height:20px;">
				Y</td>
			<td>
				C8YMLK2YY</td>
			<td>
				JANA</td>
			<td>
				SOHL</td>
			<td>
				10.05.1965</td>
			<td>
				Kadın</td>
			<td>
				13.01.2025 16:03:39</td>
			<td>
				Edirne Kapıkule Kara Hudut Kapısı&nbsp;</td>
			<td>
				Giriş</td>
			<td>
				ALMANYA</td>
		</tr>
	</tbody>
</table>
<p>
	&nbsp;</p>
', N'313258'),
            (2, N'JANA SOHL', NULL, N'ALMANYA', N'e', N'e', N'MAHMUTLAR MAH. 131.SOK BİNA NO 18 SİTE MAHMUTKLAR HİLSS A /2', N'05342673834         ', N'Afganistan', '2025-09-17 00:00:00.000', NULL, NULL, N'Vatandaşlık İşlemleri İçin', N'ANTALYA', N'2025/355                                          ', N'Polis Memuru', N'<p>
	e</p>
', N'313258'),
            (3, N'ERGÜN BULUT', '1967-08-21 00:00:00.000', NULL, N'ITCCBF288', NULL, N'EUİA UEİA EİUA EUİAEUİA', NULL, N'Hollanda', '2025-09-17 00:00:00.000', '2025-03-17 00:00:00.000', '2025-09-17 00:00:00.000', N'Genel Başvuru', N'ANTALYA', N'İUEA U                                            ', N'Polis Memuru', NULL, N'445469'),
            (4, N'ERGÜN BULUT', '5555-05-15 00:00:00.000', N'alanya', N'6854564ü 4', N'1665698755', N'uğia mahallesi', N'05935785            ', N'Türkiye', '2025-09-17 00:00:00.000', '2025-01-01 00:00:00.000', '2025-09-18 00:00:00.000', N'Genel Başvuru', N'ANTALYA', N'2025/356                                          ', N'Polis Memuru', N'<table align="left" border="1" cellpadding="0" cellspacing="0" style="width:962px;" width="0">
	<tbody>
		<tr>
			<td nowrap="nowrap" style="width:70px;height:36px;">
				<p>
					<strong>B.Turu</strong></p>
			</td>
			<td nowrap="nowrap" style="width:86px;height:36px;">
				<p>
					<strong>BelgeSeriNo</strong></p>
			</td>
			<td style="width:89px;height:36px;">
				<p>
					<strong>Kimlik No</strong></p>
			</td>
			<td nowrap="nowrap" style="width:66px;height:36px;">
				<p>
					<strong>Ad</strong></p>
			</td>
			<td nowrap="nowrap" style="width:81px;height:36px;">
				<p>
					<strong>Soyad</strong></p>
			</td>
			<td nowrap="nowrap" style="width:85px;height:36px;">
				<p>
					<strong>D.Tarihi</strong></p>
			</td>
			<td nowrap="nowrap" style="width:62px;height:36px;">
				<p>
					<strong>Cinsiyet</strong></p>
			</td>
			<td nowrap="nowrap" style="width:120px;height:36px;">
				<p>
					<strong>Tarih</strong></p>
			</td>
			<td nowrap="nowrap" style="width:140px;height:36px;">
				<p>
					<strong>KapiKodu</strong></p>
			</td>
			<td nowrap="nowrap" style="width:66px;height:36px;">
				<p>
					<strong>G-C-Tipi</strong></p>
			</td>
			<td nowrap="nowrap" style="width:94px;height:36px;">
				<p>
					<strong>UlkeKodu</strong></p>
			</td>
		</tr>
		<tr>
			<td nowrap="nowrap" style="width:70px;height:36px;">
				<p>
					Y</p>
			</td>
			<td nowrap="nowrap" style="width:86px;height:36px;">
				<p>
					BJ0248435</p>
				<p>
					&nbsp;</p>
			</td>
			<td style="width:89px;height:36px;">
				<p>
					9262168707</p>
			</td>
			<td nowrap="nowrap" style="width:66px;height:36px;">
				<p>
					NATALIA</p>
			</td>
			<td nowrap="nowrap" style="width:81px;height:36px;">
				<p>
					BOSAKOVA</p>
			</td>
			<td nowrap="nowrap" style="width:85px;height:36px;">
				<p>
					16/12/1992</p>
			</td>
			<td nowrap="nowrap" style="width:62px;height:36px;">
				<p>
					Kadın</p>
			</td>
			<td nowrap="nowrap" style="width:120px;height:36px;">
				<p>
					12/03/2025 18:40:34</p>
			</td>
			<td nowrap="nowrap" style="width:140px;height:36px;">
				<p>
					İstanbul Sabiha G&ouml;k&ccedil;en Hava Limanı</p>
			</td>
			<td nowrap="nowrap" style="width:66px;height:36px;">
				<p>
					GİRİŞ</p>
			</td>
			<td nowrap="nowrap" style="width:94px;height:36px;">
				<p>
					SLOVAKYA</p>
			</td>
		</tr>
		<tr>
			<td nowrap="nowrap" style="width:70px;height:48px;">
				<p>
					Y</p>
			</td>
			<td nowrap="nowrap" style="width:86px;height:48px;">
				<p>
					BJ0248435</p>
				<p>
					&nbsp;</p>
			</td>
			<td style="width:89px;height:48px;">
				<p>
					9262168707</p>
			</td>
			<td nowrap="nowrap" style="width:66px;height:48px;">
				<p>
					NATALIA</p>
			</td>
			<td nowrap="nowrap" style="width:81px;height:48px;">
				<p>
					BOSAKOVA</p>
			</td>
			<td nowrap="nowrap" style="width:85px;height:48px;">
				<p>
					16/12/1992</p>
			</td>
			<td nowrap="nowrap" style="width:62px;height:48px;">
				<p>
					Kadın</p>
			</td>
			<td nowrap="nowrap" style="width:120px;height:48px;">
				<p>
					07/12/2024 14:56:05</p>
			</td>
			<td nowrap="nowrap" style="width:140px;height:48px;">
				<p>
					Antalya Hava Limanı</p>
			</td>
			<td nowrap="nowrap" style="width:66px;height:48px;">
				<p>
					&Ccedil;IKIŞ</p>
			</td>
			<td nowrap="nowrap" style="width:94px;height:48px;">
				<p>
					SLOVAKYA</p>
			</td>
		</tr>
	</tbody>
</table>
<p>
	&nbsp;</p>
', N'445469'),
            (5, N'ISLAM BETCHAEV', '2014-02-05 00:00:00.000', N'RUSYA', N'761074043', NULL, N'PAZARCI MAH. MUSTAFA YÜCESON CAD. NO 7 KAT 1 GAZİPAŞA-ANTALYA', N'5441158124          ', N'Rusya Federasyonu', '2025-09-19 00:00:00.000', '2025-03-19 00:00:00.000', '2025-09-19 00:00:00.000', N'Genel Başvuru', N'ANTALYA', N'2025/360                                          ', N'Polis Memuru', N'<table border="0" cellpadding="0" cellspacing="0" style="width:1059px;" width="1057">
	<colgroup>
		<col />
		<col />
		<col />
		<col />
		<col />
		<col />
		<col />
		<col />
		<col />
		<col />
	</colgroup>
	<tbody>
		<tr height="20">
			<td height="20" style="height:20px;width:88px;">
				BelgeSeriNo</td>
			<td style="width:73px;">
				Ad</td>
			<td style="width:89px;">
				Soyad</td>
			<td style="width:112px;">
				DogumTarihi</td>
			<td style="width:101px;">
				Cinsiyet</td>
			<td style="width:121px;">
				Tarih</td>
			<td style="width:128px;">
				KapiKodu</td>
			<td style="width:83px;">
				GirisCikisTipi</td>
			<td style="width:83px;">
				IptalDurumu</td>
			<td style="width:180px;">
				UlkeKodu</td>
		</tr>
		<tr height="20">
			<td height="20" style="height:20px;">
				761074043</td>
			<td>
				ISLAM</td>
			<td>
				BATCHAEV</td>
			<td>
				5.02.2014</td>
			<td>
				Erkek</td>
			<td>
				5.09.2025 15:17:14</td>
			<td>
				Antalya Hava Limanı</td>
			<td>
				Giriş</td>
			<td>
				Ge&ccedil;erli</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
	</tbody>
</table>
<p>
	&nbsp;</p>
', N'445469'),
            (6, N'ILINA BATCHAEVA', '2011-11-08 00:00:00.000', N'RUSYA', N'761074010', NULL, N'PAZARCI MAH. MUSTAFA YÜCESON CAD. NO 7 KAT 1 GAZİPAŞA-ANTALYA', N'5441158124          ', N'Rusya Federasyonu', '2025-09-19 00:00:00.000', '2025-03-19 00:00:00.000', '2025-09-19 00:00:00.000', N'Genel Başvuru', N'ANTALYA', N'2025/360                                          ', N'Polis Memuru', N'<table border="0" cellpadding="0" cellspacing="0" style="width:1015px;" width="1012">
	<colgroup>
		<col />
		<col />
		<col />
		<col />
		<col />
		<col />
		<col />
		<col />
		<col />
		<col />
		<col />
	</colgroup>
	<tbody>
		<tr height="20">
			<td height="20" style="height:20px;width:59px;">
				BelgeTuru</td>
			<td style="width:97px;">
				BelgeSeriNo</td>
			<td style="width:76px;">
				Ad</td>
			<td style="width:95px;">
				Soyad</td>
			<td style="width:91px;">
				DogumTarihi</td>
			<td style="width:64px;">
				Cinsiyet</td>
			<td style="width:129px;">
				Tarih</td>
			<td style="width:119px;">
				KapiKodu</td>
			<td style="width:68px;">
				GirisCikisTipi</td>
			<td style="width:80px;">
				IptalDurumu</td>
			<td style="width:137px;">
				UlkeKodu</td>
		</tr>
		<tr height="20">
			<td height="20" style="height:20px;">
				Y</td>
			<td>
				761074010</td>
			<td>
				ILINA</td>
			<td>
				BATCHAEVA</td>
			<td>
				8.11.2011</td>
			<td>
				Kadın</td>
			<td>
				5.09.2025 15:17:43</td>
			<td>
				Antalya Hava Limanı</td>
			<td>
				Giriş</td>
			<td>
				Ge&ccedil;erli</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
	</tbody>
</table>
<p>
	&nbsp;</p>
', N'445469'),
            (7, N'DAMIR BATCHAEV', '2015-08-15 00:00:00.000', N'RUSYA', N'761073882', NULL, N'PAZARCI MAH. MUSTAFA YÜCESON CAD. NO 7 KAT 1 GAZİPAŞA-ANTALYA', N'5441158124          ', N'Rusya Federasyonu', '2025-09-19 00:00:00.000', '2025-03-19 00:00:00.000', '2025-09-19 00:00:00.000', N'Genel Başvuru', N'ANTALYA', N'2025/360                                          ', N'Polis Memuru', N'<table border="0" cellpadding="0" cellspacing="0" style="width:897px;" width="897">
	<colgroup>
		<col />
		<col />
		<col />
		<col span="2" />
		<col span="2" />
		<col />
		<col />
		<col />
	</colgroup>
	<tbody>
		<tr height="20">
			<td height="20" style="height:20px;width:64px;">
				BelgeTuru</td>
			<td style="width:91px;">
				BelgeSeriNo</td>
			<td style="width:64px;">
				Ad</td>
			<td style="width:95px;">
				Soyad</td>
			<td style="width:95px;">
				DogumTarihi</td>
			<td style="width:64px;">
				Cinsiyet</td>
			<td style="width:64px;">
				Tarih</td>
			<td style="width:131px;">
				KapiKodu</td>
			<td style="width:84px;">
				GirisCikisTipi</td>
			<td style="width:147px;">
				UlkeKodu</td>
		</tr>
		<tr height="20">
			<td height="20" style="height:20px;">
				Y</td>
			<td>
				761073882</td>
			<td>
				DAMIR</td>
			<td>
				BATCHAEV</td>
			<td>
				15.08.2015</td>
			<td>
				Erkek</td>
			<td>
				5.09.2025 15:17:06</td>
			<td>
				Antalya Hava Limanı</td>
			<td>
				Giriş</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
	</tbody>
</table>
<p>
	&nbsp;</p>
', N'445469'),
            (8, N'ILINA  BATCHAEVA', '2011-11-08 00:00:00.000', N'Rusya', N'761074010', NULL, N'GAZİPAŞA /ANTALYA', N'05441158124         ', N'Rusya Federasyonu', '2025-09-19 00:00:00.000', '2020-01-01 00:00:00.000', '2025-09-19 00:00:00.000', N'Eğitim İşlemleri İçin', N'ANTALYA', N'2025/360                                          ', N'Polis Memuru', N'<table border="0" cellpadding="0" cellspacing="0" style="width:1000px;" width="998">
	<colgroup>
		<col />
		<col />
		<col />
		<col />
		<col />
		<col />
		<col />
		<col />
		<col />
		<col />
	</colgroup>
	<tbody>
		<tr height="32">
			<td height="32" style="height:32px;width:61px;">
				B.Turu</td>
			<td style="width:72px;">
				B.SeriNo</td>
			<td style="width:64px;">
				Ad</td>
			<td style="width:83px;">
				Soyad</td>
			<td style="width:95px;">
				D.Tarihi</td>
			<td style="width:64px;">
				Cinsiyet</td>
			<td style="width:127px;">
				Tarih</td>
			<td style="width:191px;">
				KapiKodu</td>
			<td style="width:101px;">
				Giris<br />
				CikisTipi</td>
			<td style="width:143px;">
				UlkeKodu</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td align="right">
				761074010</td>
			<td>
				ILINA</td>
			<td>
				BATCHAEVA</td>
			<td align="right">
				08.11.2011</td>
			<td>
				Kadın</td>
			<td>
				5.09.2025 15:17:43</td>
			<td>
				Antalya Hava Limanı</td>
			<td>
				Giriş</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761074010</td>
			<td>
				ILINA</td>
			<td>
				BATCHAEVA</td>
			<td>
				8.11.2011</td>
			<td>
				Kadın</td>
			<td>
				13.09.2024 05:05:06</td>
			<td>
				Antalya Hava Limanı</td>
			<td>
				&Ccedil;ıkış</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761074010</td>
			<td>
				ILINA</td>
			<td>
				BATCHAEVA</td>
			<td>
				8.11.2011</td>
			<td>
				Kadın</td>
			<td>
				30.08.2024 14:51:18</td>
			<td>
				Antalya Hava Limanı</td>
			<td>
				Giriş</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761074010</td>
			<td>
				ILINA</td>
			<td>
				BATCHAEVA</td>
			<td>
				8.11.2011</td>
			<td>
				Kadın</td>
			<td>
				25.06.2024 00:16:09</td>
			<td>
				Antalya Hava Limanı</td>
			<td>
				&Ccedil;ıkış</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761074010</td>
			<td>
				ILINA</td>
			<td>
				BATCHAEVA</td>
			<td>
				8.11.2011</td>
			<td>
				Kadın</td>
			<td>
				19.08.2023 02:50:07</td>
			<td>
				Antalya Hava Limanı</td>
			<td>
				Giriş</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761074010</td>
			<td>
				ILINA</td>
			<td>
				BATCHAEVA</td>
			<td>
				8.11.2011</td>
			<td>
				Kadın</td>
			<td>
				24.07.2023 21:32:51</td>
			<td>
				Antalya Hava Limanı</td>
			<td>
				&Ccedil;ıkış</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761074010</td>
			<td>
				ILINA</td>
			<td>
				BATCHAEVA</td>
			<td>
				8.11.2011</td>
			<td>
				Kadın</td>
			<td>
				30.11.2022 14:53:00</td>
			<td>
				İstanbul Havalimanı</td>
			<td>
				Giriş</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761074010</td>
			<td>
				ILINA</td>
			<td>
				BATCHAEVA</td>
			<td>
				8.11.2011</td>
			<td>
				Kadın</td>
			<td>
				12.11.2021 15:09:50</td>
			<td>
				İstanbul Havalimanı</td>
			<td>
				&Ccedil;ıkış</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761074010</td>
			<td>
				ILINA</td>
			<td>
				BATCHAEVA</td>
			<td>
				8.11.2011</td>
			<td>
				Kadın</td>
			<td>
				29.10.2021 21:53:13</td>
			<td>
				İstanbul Havalimanı</td>
			<td>
				Giriş</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761074010</td>
			<td>
				ILINA</td>
			<td>
				BATCHAEVA</td>
			<td>
				8.11.2011</td>
			<td>
				Kadın</td>
			<td>
				3.04.2021 11:21:07</td>
			<td>
				Antalya Gazipaşa Hava Limanı</td>
			<td>
				&Ccedil;ıkış</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761074010</td>
			<td>
				ILINA</td>
			<td>
				BATCHAEVA</td>
			<td>
				8.11.2011</td>
			<td>
				Kadın</td>
			<td>
				30.03.2021 12:05:24</td>
			<td>
				Antalya Gazipaşa Hava Limanı</td>
			<td>
				Giriş</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761074010</td>
			<td>
				ILINA</td>
			<td>
				BATCHAEVA</td>
			<td>
				8.11.2011</td>
			<td>
				Kadın</td>
			<td>
				14.09.2020 11:36:42</td>
			<td>
				Antalya Gazipaşa Hava Limanı</td>
			<td>
				&Ccedil;ıkış</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761074010</td>
			<td>
				ILINA</td>
			<td>
				BATCHAEVA</td>
			<td>
				8.11.2011</td>
			<td>
				Kadın</td>
			<td>
				27.08.2020 06:44:29</td>
			<td>
				Antalya Gazipaşa Hava Limanı</td>
			<td>
				Giriş</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761074010</td>
			<td>
				ILINA</td>
			<td>
				BATCHAEVA</td>
			<td>
				8.11.2011</td>
			<td>
				Kadın</td>
			<td>
				2.02.2020 08:07:29</td>
			<td>
				Antalya Hava Limanı</td>
			<td>
				&Ccedil;ıkış</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761074010</td>
			<td>
				ILINA</td>
			<td>
				BATCHAEVA</td>
			<td>
				8.11.2011</td>
			<td>
				Kadın</td>
			<td>
				26.01.2020 14:43:37</td>
			<td>
				Antalya Hava Limanı</td>
			<td>
				Giriş</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
	</tbody>
</table>
<p>
	&nbsp;</p>
', N'313258'),
            (9, N'ISLAM	BATCHAEV', NULL, N'RUSYA FEDERASYONU', N'761074043', NULL, N'GAZİPAŞA /ANTALYA', N'05441158124         ', N'Rusya Federasyonu', '2025-09-19 00:00:00.000', '2020-01-01 00:00:00.000', '2025-09-19 00:00:00.000', N'Eğitim İşlemleri İçin', N'ANTALYA', N'2025/360                                          ', N'Polis Memuru', N'<table border="0" cellpadding="0" cellspacing="0" style="width:967px;" width="963">
	<colgroup>
		<col />
		<col />
		<col />
		<col />
		<col />
		<col />
		<col />
		<col />
		<col />
		<col />
	</colgroup>
	<tbody>
		<tr height="32">
			<td height="32" style="height:32px;width:87px;">
				B.Turu</td>
			<td style="width:100px;">
				B.No</td>
			<td style="width:64px;">
				Ad</td>
			<td style="width:73px;">
				Soyad</td>
			<td style="width:69px;">
				D.Tarihi</td>
			<td style="width:68px;">
				Cinsiyet</td>
			<td style="width:127px;">
				Tarih</td>
			<td style="width:161px;">
				KapiKodu</td>
			<td style="width:75px;">
				Giris<br />
				CikisTipi</td>
			<td style="width:143px;">
				UlkeKodu</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td align="right">
				761074043</td>
			<td>
				ISLAM</td>
			<td>
				BATCHAEV</td>
			<td>
				5.02.2014</td>
			<td>
				Erkek</td>
			<td>
				5.09.2025 15:17:14</td>
			<td>
				Antalya Hava Limanı</td>
			<td>
				Giriş</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761074043</td>
			<td>
				ISLAM</td>
			<td>
				BATCHAEV</td>
			<td>
				5.02.2014</td>
			<td>
				Erkek</td>
			<td>
				13.09.2024 05:05:29</td>
			<td>
				Antalya Hava Limanı</td>
			<td>
				&Ccedil;ıkış</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761074043</td>
			<td>
				ISLAM</td>
			<td>
				BATCHAEV</td>
			<td>
				5.02.2014</td>
			<td>
				Erkek</td>
			<td>
				30.08.2024 14:50:37</td>
			<td>
				Antalya Hava Limanı</td>
			<td>
				Giriş</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761074043</td>
			<td>
				ISLAM</td>
			<td>
				BATCHAEV</td>
			<td>
				5.02.2014</td>
			<td>
				Erkek</td>
			<td>
				25.06.2024 00:16:47</td>
			<td>
				Antalya Hava Limanı</td>
			<td>
				&Ccedil;ıkış</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761074043</td>
			<td>
				ISLAM</td>
			<td>
				BATCHAEV</td>
			<td>
				5.02.2014</td>
			<td>
				Erkek</td>
			<td>
				19.08.2023 02:50:44</td>
			<td>
				Antalya Hava Limanı</td>
			<td>
				Giriş</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761074043</td>
			<td>
				ISLAM</td>
			<td>
				BATCHAEV</td>
			<td>
				5.02.2014</td>
			<td>
				Erkek</td>
			<td>
				24.07.2023 21:32:02</td>
			<td>
				Antalya Hava Limanı</td>
			<td>
				&Ccedil;ıkış</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761074043</td>
			<td>
				ISLAM</td>
			<td>
				BATCHAEV</td>
			<td>
				5.02.2014</td>
			<td>
				Erkek</td>
			<td>
				18.03.2023 22:07:58</td>
			<td>
				İstanbul Havalimanı</td>
			<td>
				Giriş</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761074043</td>
			<td>
				ISLAM</td>
			<td>
				BATCHAEV</td>
			<td>
				5.02.2014</td>
			<td>
				Erkek</td>
			<td>
				14.03.2023 17:15:00</td>
			<td>
				İstanbul Havalimanı</td>
			<td>
				&Ccedil;ıkış</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761074043</td>
			<td>
				ISLAM</td>
			<td>
				BATCHAEV</td>
			<td>
				5.02.2014</td>
			<td>
				Erkek</td>
			<td>
				30.11.2022 14:52:14</td>
			<td>
				İstanbul Havalimanı</td>
			<td>
				Giriş</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761074043</td>
			<td>
				ISLAM</td>
			<td>
				BATCHAEV</td>
			<td>
				5.02.2014</td>
			<td>
				Erkek</td>
			<td>
				12.11.2021 15:10:05</td>
			<td>
				İstanbul Havalimanı</td>
			<td>
				&Ccedil;ıkış</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761074043</td>
			<td>
				ISLAM</td>
			<td>
				BATCHAEV</td>
			<td>
				5.02.2014</td>
			<td>
				Erkek</td>
			<td>
				29.10.2021 21:52:09</td>
			<td>
				İstanbul Havalimanı</td>
			<td>
				Giriş</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761074043</td>
			<td>
				ISLAM</td>
			<td>
				BATCHAEV</td>
			<td>
				5.02.2014</td>
			<td>
				Erkek</td>
			<td>
				14.09.2020 11:37:59</td>
			<td>
				Antalya Gazipaşa Hava Limanı</td>
			<td>
				&Ccedil;ıkış</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761074043</td>
			<td>
				ISLAM</td>
			<td>
				BATCHAEV</td>
			<td>
				5.02.2014</td>
			<td>
				Erkek</td>
			<td>
				27.08.2020 06:44:08</td>
			<td>
				Antalya Gazipaşa Hava Limanı</td>
			<td>
				Giriş</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
	</tbody>
</table>
<p>
	&nbsp;</p>
', N'313258'),
            (10, N'DAMIR	BATCHAEV', '2015-08-15 00:00:00.000', N'RUSYA FEDERASYONU', N'761073882', NULL, N'GAZİPAŞA /ANTALYA', N'05441158124         ', N'Rusya Federasyonu', '2025-09-19 00:00:00.000', '2020-01-01 00:00:00.000', '2025-09-19 00:00:00.000', N'Eğitim İşlemleri İçin', N'ANTALYA', N'2025/360                                          ', N'Polis Memuru', N'<table border="0" cellpadding="0" cellspacing="0" style="width:865px;" width="865">
	<colgroup>
		<col span="3" />
		<col />
		<col span="2" />
		<col />
		<col />
		<col />
		<col />
	</colgroup>
	<tbody>
		<tr height="16">
			<td height="16" style="height:16px;width:64px;">
				BelgeTuru</td>
			<td style="width:64px;">
				BelgeSeriNo</td>
			<td style="width:64px;">
				Ad</td>
			<td style="width:73px;">
				Soyad</td>
			<td style="width:64px;">
				DogumTarihi</td>
			<td style="width:64px;">
				Cinsiyet</td>
			<td style="width:107px;">
				Tarih</td>
			<td style="width:161px;">
				KapiKodu</td>
			<td style="width:64px;">
				GirisCikisTipi</td>
			<td style="width:140px;">
				UlkeKodu</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761073882</td>
			<td>
				DAMIR</td>
			<td>
				BATCHAEV</td>
			<td>
				15.08.2015</td>
			<td>
				Erkek</td>
			<td>
				5.09.2025 15:17:06</td>
			<td>
				Antalya Hava Limanı</td>
			<td>
				Giriş</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761073882</td>
			<td>
				DAMIR</td>
			<td>
				BATCHAEV</td>
			<td>
				15.08.2015</td>
			<td>
				Erkek</td>
			<td>
				13.09.2024 05:05:18</td>
			<td>
				Antalya Hava Limanı</td>
			<td>
				&Ccedil;ıkış</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761073882</td>
			<td>
				DAMIR</td>
			<td>
				BATCHAEV</td>
			<td>
				15.08.2015</td>
			<td>
				Erkek</td>
			<td>
				30.08.2024 14:50:26</td>
			<td>
				Antalya Hava Limanı</td>
			<td>
				Giriş</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761073882</td>
			<td>
				DAMIR</td>
			<td>
				BATCHAEV</td>
			<td>
				15.08.2015</td>
			<td>
				Erkek</td>
			<td>
				25.06.2024 00:16:21</td>
			<td>
				Antalya Hava Limanı</td>
			<td>
				&Ccedil;ıkış</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761073882</td>
			<td>
				DAMIR</td>
			<td>
				BATCHAEV</td>
			<td>
				15.08.2015</td>
			<td>
				Erkek</td>
			<td>
				19.08.2023 02:50:11</td>
			<td>
				Antalya Hava Limanı</td>
			<td>
				Giriş</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761073882</td>
			<td>
				DAMIR</td>
			<td>
				BATCHAEV</td>
			<td>
				15.08.2015</td>
			<td>
				Erkek</td>
			<td>
				24.07.2023 21:32:41</td>
			<td>
				Antalya Hava Limanı</td>
			<td>
				&Ccedil;ıkış</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761073882</td>
			<td>
				DAMIR</td>
			<td>
				BATCHAEV</td>
			<td>
				15.08.2015</td>
			<td>
				Erkek</td>
			<td>
				30.11.2022 14:52:32</td>
			<td>
				İstanbul Havalimanı</td>
			<td>
				Giriş</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761073882</td>
			<td>
				DAMIR</td>
			<td>
				BATCHAEV</td>
			<td>
				15.08.2015</td>
			<td>
				Erkek</td>
			<td>
				12.11.2021 15:10:23</td>
			<td>
				İstanbul Havalimanı</td>
			<td>
				&Ccedil;ıkış</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761073882</td>
			<td>
				DAMIR</td>
			<td>
				BATCHAEV</td>
			<td>
				15.08.2015</td>
			<td>
				Erkek</td>
			<td>
				29.10.2021 21:52:24</td>
			<td>
				İstanbul Havalimanı</td>
			<td>
				Giriş</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761073882</td>
			<td>
				DAMIR</td>
			<td>
				BATCHAEV</td>
			<td>
				15.08.2015</td>
			<td>
				Erkek</td>
			<td>
				14.09.2020 11:38:26</td>
			<td>
				Antalya Gazipaşa Hava Limanı</td>
			<td>
				&Ccedil;ıkış</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
		<tr height="16">
			<td height="16" style="height:16px;">
				Y</td>
			<td>
				761073882</td>
			<td>
				DAMIR</td>
			<td>
				BATCHAEV</td>
			<td>
				15.08.2015</td>
			<td>
				Erkek</td>
			<td>
				27.08.2020 06:43:47</td>
			<td>
				Antalya Gazipaşa Hava Limanı</td>
			<td>
				Giriş</td>
			<td>
				RUSYA FEDERASYONU</td>
		</tr>
	</tbody>
</table>
<p>
	&nbsp;</p>
', N'313258'),
            (11, N'volkan güler', '1988-06-03 00:00:00.000', N'tokat', N'u123456', N'37987547808', N'tokat merkez', N'05412959265         ', N'Türkiye', '2025-09-19 00:00:00.000', '2025-01-01 00:00:00.000', '2025-09-19 00:00:00.000', N'Genel Başvuru', N'SAMSUN', N'123                                               ', N'Polis Memuru', N'<p>
	deneme</p>
', N'412971'),
            (12, N'aaaaa', '2000-11-11 00:00:00.000', N'dsadsd', N'574684654', N'asdasda', N'gjyhyjyjdyj', N'658416889196        ', N'Türkiye', '2026-01-13 00:00:00.000', '2000-11-11 00:00:00.000', '2000-11-11 00:00:00.000', N'Vatandaşlık İşlemleri İçin', N'EDİRNE', N'dfsdf                                             ', N'Polis Memuru', NULL, N'479077');
        SET IDENTITY_INSERT [dbo].[E_Dilekce] OFF;
        PRINT 'Tablo [dbo].[E_Dilekce] icin 12 kayit eklendi.';
    END
END
GO

-- --------------------------------------------------------------------------
-- Veri: [dbo].[E_User]
-- --------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[E_User]', N'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dbo].[E_User])
    BEGIN
        SET IDENTITY_INSERT [dbo].[E_User] ON;
        INSERT INTO [dbo].[E_User] ([fldId], [fldSicil], [fldName], [fldLastName], [fldPhone], [fldEmail], [fldTitle], [fldDeputy], [fldPicture], [fldAuth], [fldSubAuth], [fldPassword], [fldDateTime], [fldBorder], [fldActive], [Role], [LastLogin], [XP], [Level], [IsActive], [TeacherRequestStatus], [TeacherRequestDate]) VALUES
            (2, N'313258', N'Naşit', N'DAYAN', N'05535351560', N'nasit.dayan@egm.gov.tr', N'Polis Memuru', N'Büro Memuru', N'14802f72fbaa4c718ddf0e92f6368e5b.jpg', N'1,2,3,4,5', N'0', N'AQAAAAEAACcQAAAAELaICBESNYwt1kkjs/UxLBVDGGSTf+OtgnjysrWPmRTl3jdWEOaUxaNzCuJuKvme7w==', '2021-09-12 16:34:23.070', N'ANTALYA GAZİPAŞA HAVA LİMANI', N'1', N'Admin', '2026-10-17 21:44:15.587', 0, 1, 1, NULL, NULL),
            (3, N'217054', N'Mehmet Emin', N'DEMİRHAN', N'5054857402', N'mehmetemin.demirhan@egm.gov.tr', N'Polis Memuru', N'Grup Amir V.', N'', N'3,4,6', N'0', N'AQAAAAEAACcQAAAAEJJIZd8mxFhNj+OLyB3Jh8Uu/hbvSsnBBLtTloJNTtvjqGv0Kqo1v9kejGWOCA0omQ==', '2021-09-12 16:34:23.070', N'ANTALYA GAZİPAŞA HAVA LİMANI', N'1', N'Teacher', '2026-04-22 22:11:39.587', 0, 1, 1, NULL, NULL),
            (4, N'243533', N'İbrahim', N'ÇAKIR', N'5053730032', N'ibrahim.cakir5@egm.gov.tr', N'Polis Memuru', N'Grup Amir Vekili', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEEXuExOQQwrfr4dxhKSgeWOcHewlOAfzQ0ePuWsoI/oYrcVEXDR8mMh7gF14Kt41Sg==', '2021-09-12 16:34:23.070', N'ANTALYA GAZİPAŞA HAVA LİMANI', N'0', N'Student', '2026-04-09 15:22:14.047', 0, 1, 0, NULL, NULL),
            (5, N'257776', N'Mustafa ', N'BAL', N'5053465910', N'mustafa.bal9@egm.gov.tr', N'Polis Memuru', N'Grup Amir Vekili', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEOG3mB/SQNUymg+Nk4ahSqG7Za+6bvVMOetKFvmpH3GD8VrQDkk6IDNyiXjQmJtsHg==', '2021-09-12 16:34:23.070', N'ANTALYA GAZİPAŞA HAVA LİMANI', N'0', N'Student', '2026-03-30 17:22:29.780', 0, 1, 0, NULL, NULL),
            (1007, N'221425', N'Adem', N'ŞAHİN', N'05053386860', N'adem.sahin4@egm.gov.tr', N'Polis Memuru', N'Kayseri Havalimanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPO36jVz29RWcmgRLtbpOF23rkYbm44zXY8OARVOIYcTdMu9oGp9GzPuNdZ3YQXqWw==', '2021-09-12 16:34:23.070', N'KAYSERİ HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1009, N'167361', N'Necdet', N'GÜMÜŞ', N'05052299743', N'necdet.gumus@egm.gov.tr', N'Polis Memuru', N'Hamzabeyli Sınır Kapısı', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEIo8yKTqCiA67vqAuCr29QM92IFYIpsyDdIbQOSTQRnUo1xwu74xUOEUuz1lkf61pA==', '2021-09-12 16:34:23.070', N'EDİRNE HAMZABEYLİ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1011, N'371028', N'Görkem ', N'ŞAHİN', N'05070270691', N'gorkem.sahin@egm.gov.tr', N'Polis Memuru', N'Habur Sınır Kapısı', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEAcdI6u0YHbr5TXeRWdpaDW7ufkQXZq9e0zEDhIXI/PTfCsZuFMNEIhTATHMX4KitA==', '2021-09-12 16:34:23.070', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1012, N'243547', N'Mehmet', N'BALLI', N'05057726439', N'mehmet.balli2@egm.gov.tr', N'Polis Memuru', N'Taşucu Deniz Limanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEEa1Hzo3+/mBbxE9sl8iwyxYciCfPPeqDgE/nkyRMzASYpOtQXeMx2odVfwFn0MunQ==', '2021-09-12 16:34:23.070', N'MERSİN TAŞUCU-SEKA DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1014, N'205968', N'Halil', N'DURUKAN', N'05052115755', N'halil.durukan@egm.gov.tr', N'Polis Memuru', N'Milas-Bodrum Havalimanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEKrXRTyWGRJPYnaRON+teSLDVM/e1e+OMEBNz/CV6baY8CM1ZuDUb9NZUiP4pT5X6g==', '2021-09-12 16:34:23.070', N'MUĞLA MİLAS-BODRUM HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1015, N'163221', N'Gökmen', N'KASAR', N'05055662631', N'gokmen.kasar@egm.gov.tr', N'Polis Memuru', N'İncirlik ', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEGx8P2u1dy7priZMxj2Aj1igoMMCGkREe0FC+A3vZqYmvkXEVn7EaBgVFEkZd/z7yw==', '2021-09-12 16:34:23.070', N'ADANA İNCİRLİK HAVALİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1018, N'225846', N'Yalçın', N'ARIKBUĞA', N'05052700008', N'yalcin.arikbuga@egm.gov.tr', N'Polis Memuru', N'Isparta Havalimanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEIukrPEQm0pD0e7JMxTjyFlcuiqsh2zCZrWgF4fUIFkgzdNXbT20A67jho7uJzVBtQ==', '2021-09-12 16:34:23.070', N'ISPARTA SÜLEYMAN DEMİREL HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1020, N'213581', N'Beytullah', N'UZUN', N'05052930620', N'beytullah.uzun@egm.gov.tr', N'Polis Memuru', N'Çarşamba Havalimanı', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEIHrRkhBm79+sxddDvAa9E3qrZSkRaGUn5N8GQSnMGO48NfFXf+15P68o3uwkGMPOQ==', '2021-09-12 16:34:23.070', N'SAMSUN ÇARŞAMBA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1022, N'160189', N'İsmail', N'DEĞİRMENCİ', N'05052313031', N'ismail.degirmenci@egm.gov.tr', N'Polis Memuru', N'Çukurova Havalimanı', N'', N'3', N'1', N'AQAAAAEAACcQAAAAECRC1HDTn7PHC94qqpSQiY7QdAn2pkFIG6kOIdOsQFs8Mg1IBsEqhGQPRxvb9SEBdw==', '2021-09-12 16:34:23.070', N'ÇUKUROVA HAVALİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1025, N'201027', N'Şenol', N'ADAK', N'0505', N'senol.adak@egm.gov.tr', N'Polis Memuru', N'Aliağa Deniz Limanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJTCtz4/Fvtf9PU1d55wIVe3vWYCZ3SVTfLVIxifFswOjMfhjFTNwXNH2S1/iWebxQ==', '2021-09-12 16:34:23.070', N'İZMİR ALİAĞA DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1026, N'240532', N'Yakup', N'BALKAYA', N'05052342991', N'yakup.balkaya@egm.gov.tr', N'Polis Memuru', N'Gemlik Deniz Limanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEAf3vqzdl7Fs+A3JeJ9uvWtj4sTf1rn27h+RYxZo6/ZbeREgdYJic5M20ZtYIFff6g==', '2021-09-12 16:34:23.070', N'BURSA GEMLİK DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1027, N'236030', N'Erdal', N'ÇİÇEK', N'05053556472', N'v55-smsn@hotmail.com', N'Polis Memuru', N'Eskişehir Hasan Polatkan Havalimanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEClzGB5qjV4RNdajSFudjscNgo6fbstFYTf1WzDY+iGa96hFkHa5bvjpCwdlYK5GSQ==', '2021-09-12 16:34:23.070', N'ESKİŞEHİR HASAN POLATKAN HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1030, N'197240', N'AYDIN', N'DENK', N'05058236097', N'nj@egm.gov.tr', N'Polis Memuru', N'Kayseri Havalimanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEHuDZ2hcfPJr4QZKJXqHnNyUncEhWktjo2jwDUglJl0Ee8jDeq3SJAqQGNStMSJT/Q==', '2021-09-12 16:34:23.070', N'KAYSERİ HAVA LİMANI', N'0', N'Student', '2026-04-02 02:32:46.330', 0, 1, 0, NULL, NULL),
            (1034, N'447477', N'Burak', N'ERDOĞAN', N'0505', N'burak.erdogan4@egm.gov.tr', N'Polis Memuru', N'Sabiha Gökçen Havalimanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAELs+nEv3+2BU08JCiZscT/Vnl7oDbkevsMYqDM68adqVXN4AFC+c0yxgWIei4rdEyw==', '2021-09-12 16:34:23.070', N'İSTANBUL SABİHA GÖKÇEN HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1035, N'267353', N'İbrahim', N'ZORLU', N'05050276601', N'ibrahim.zorlu@egm.gov.tr', N'Polis Memuru', N'Adana Havalimanı', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEP/F/PjazRjIyZbieK0AhG0KkDb+7jgAW267LDjyzR1FiJP6WqxD6/YgVdn/uACfgQ==', '2021-09-12 16:34:23.070', N'ADANA ŞAKİRPAŞA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1037, N'303146', N'Ramazan', N'COŞKUN', N'155', N'ramazan.coskun2@egm.gov.tr', N'Polis Memuru', N'Çeçme Deniz Hava Hudut Kapısı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEN4EClAykMoyjvOWx/B/ftIrgRH6Hll2inz1LYo+zCBozOigOW5LKaye3KYhc9T8Nw==', '2021-09-12 16:34:23.070', N'ÇEŞME DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1042, N'239219', N'Murat', N'İNCEKARA', N'05052326776', N'murat.incekara2@egm.gov.tr', N'Polis Memuru', N'İstanbul Deniz Limanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEDnwhio/SutFrNkrHmmRb/l+EXCdJrlFHx9V5JyTsxn51vp8Uy1xu9KidsBFlia7wA==', '2021-09-12 16:34:23.070', N'İSTANBUL ZEYTİNBURNU DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-05 13:26:06.277', 0, 1, 0, NULL, NULL),
            (1047, N'324179', N'Hakan', N'ÇUHA', N'05068018147', N'hakan.cuha@egm.gov.tr', N'Polis Memuru', N'Sabiha Gökçen Havalimanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEBm9iZpCzYWX3Fj4HfKzE0F/AEkB7ilplsqq0HhMSccsy6dXqVTep7n7pvxAcHT4RQ==', '2021-09-12 16:34:23.070', N'İSTANBUL SABİHA GÖKÇEN HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1051, N'277332', N'Ersin', N'YILDIRIM', N'05541192300', N'ersin.yildirim4@egm.gov.tr', N'Polis Memuru', N'Sabiha Gökçen Havalimanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEI+nfEZ91k3rBRpNrTi6sBKVTDzZyBxiiyE9ho3MF4TqrEYmrM6Cg/qu5Wi5CSlLvA==', '2021-09-12 16:34:23.070', N'İSTANBUL SABİHA GÖKÇEN HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1063, N'211675', N'Sami', N'BIYIKOĞLU', N'0505', N'sami.biyikoglu@egm.gov.tr', N'Polis Memuru', N'Kayseri Havalimanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPeGjIbNZwWzbCH6gOOYLwPgCwGGHwP3CCdfmw9fDKHLNdRnxKRM9nP/EjnMLLyIqw==', '2021-09-12 16:34:23.070', N'KAYSERİ HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1065, N'243407', N'İsmail', N'HASTÜRK', N'05063800254', N'ismail.hasturk3@egm.gov.tr', N'Polis Memuru', N'Kocaeli Deniz Limanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEE52K5/8pIiUaWYuT48JyVsKpIJAUUbQmuAhG3J9ZYh4zWOA0l9OAQNZ1+Bg9r4alg==', '2021-09-12 16:34:23.070', N'KOCAELİ DERİNCE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1066, N'305749', N'Kemal', N'İNCİ', N'05063800254', N'kemal.inci@egm.gov.tr', N'Polis Memuru', N'Kocaeli Deniz Limanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEKRyC9iLVVPMkXbRgJ96X5gDMzpNezio7SOcuTfwWAfnNCVZN20rA8fs6ikt1O5iYg==', '2021-09-12 16:34:23.070', N'KOCAELİ DERİNCE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1068, N'205466', N'İdris', N'ÇEBİŞLİ', N'05052207705', N'idris.cebisli@egm.gov.tr', N'Polis Memuru', N'İSKENDERUN DENİZ LİMAN ŞUBE MÜDÜRLÜĞÜ', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEGJ8AUxYxtOZqpy6H4BNZt+Hzh+JakPh1/aK0mTgV9STQi/a144R8nLckS7Z3eNQeg==', '2021-09-12 16:34:23.070', N'ADANA ŞAKİRPAŞA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1069, N'295313', N'Hakan', N'PERK', N'05064015161', N'hakan.perk2@egm.gov.tr', N'Polis Memuru', N'Adana Havalimanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEBkwLWeVvyky096x8y4sJppMaqhYEo0HXBX5gFgW0lJMI4UPY0obifWBrojuFADovQ==', '2021-09-12 16:34:23.070', N'ÇUKUROVA HAVALİMANI', N'0', N'Student', '2026-04-02 23:09:38.337', 0, 1, 0, NULL, NULL),
            (1070, N'233480', N'Osman', N'AZMAN', N'05415734253', N'osman.azman@egm.gov.tr', N'Polis Memuru', N'Adana Havalimanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEI06FsDJCpovts7mLLzxWxPkLOOMYOL/InYV85aguDz4wVhQ7C1G+8DyGVIy7zlkRQ==', '2021-09-12 16:34:23.070', N'ADANA ŞAKİRPAŞA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1071, N'243514', N'Murat', N'YEL', N'05068104031', N'murat.yel@egm.gov.tr', N'Polis Memuru', N'Gazipaşa Havalimanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEOZ9VibMMeYvThZJk8vS27Kq9iv6c1EHqcq/dOBXOGOoaKVBZd9TYxtcv5cQNLnmRw==', '2021-09-12 16:34:23.070', N'ANTALYA GAZİPAŞA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1072, N'266535', N'Hüseyin ', N'TEMEL', N'5053870150', N'huseyin.temel@egm.gov.tr', N'Polis Memuru', N'Gazipaşa Havalimanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEI+93N2Id721lGa0YH4/q6yFWix7QDbZVs20pof7vrQ2u5jzR3N/VW0Ec5PBLooVYg==', '2021-09-12 16:34:23.070', N'ANTALYA GAZİPAŞA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1073, N'278931', N'Hüseyin ', N'Hüseyin ERTAN', N'5077616486', N'huseyin.ertan2@egm.gov.tr', N'Polis Memuru', N'Gazipaşa Havalimanı', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEOoRWcte9mXa3nKn9CUpfZoKJSiW1NoITjL/wBvL+4z+s/mHYTzJV2OIc3ulyH3P0g==', '2021-09-12 16:34:23.070', N'ANTALYA GAZİPAŞA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1074, N'280399', N'Murat', N' KANAL', N'5054935003', N'murat.kanal@egm.gov.tr', N'Polis Memuru', N'Gazipaşa Havalimanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEGfohm2MPmXIBvnftbFbivQNTU+jk6HXsJlRokLbpj9K1YLR9kg38JxrNWaET7Z4yg==', '2021-09-12 16:34:23.070', N'ANTALYA GAZİPAŞA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1075, N'285244', N'Murat ', N'KIZILKALE ', N'5058941783', N'murat.kizilkale@egm.gov.tr', N'Polis Memuru', N'Gazipaşa Havalimanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJsRLQ9YLawfcyRilVkl9q6JzI9InosPHdUq1jwze5WBOrPd9nuHqqrVkHdssPzTJg==', '2021-09-12 16:34:23.070', N'ANTALYA GAZİPAŞA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1077, N'352164', N'Mesut', N'AKYOL', N'05533064278', N'mesutakyol2@egm.gov.tr', N'Polis Memuru', N'Tekirdağ Deniz Hudut Kapısı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEAnZHNKkKkmBPtZtilgGhIepM0yLodrZucdVW3CTlPfWAcLpSRAATIs11Uln2n3tAA==', '2021-09-12 16:34:23.070', N'TEKİRDAĞ MARMARA EREĞLİSİ DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1078, N'240996', N'Sinan', N'BULAN', N'05052138402', N'sinan.bulan@egm.gov.tr', N'Polis Memuru', N'Samsun Deniz Limanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEL27oaLvgY+hmtZCfRLKIcmxu80Up29vSczoFGnM+Ty5q/s/BvEe84l+hxXWlY8DAw==', '2021-09-12 16:34:23.070', N'SAMSUN DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1082, N'250013', N'Mustafa', N'ARDA', N'05052290302', N'mustafa.arda@egm.gov.tr', N'Polis Memuru', N'Eskişehir Hasan Polatkan Havalimanı', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEBzuG3WIJNHomlEfIl5hDPytlza4ftW6gtcaAPwQ0AaVZW55FlyQgjGLQds+cn+xLA==', '2021-09-12 16:34:23.070', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1083, N'259128', N'Fatih', N'BELEN', N'05054840868', N'fatih.belen@egm.gov.tr', N'Polis Memuru', N'Eskişehir Hasan Polatkan Havalimanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEGfvmvJBa3PSk6iS3jafYMo6MTCbTtfk7dKzrqMlMFOzXsgW4rAd2VihmTm1ovBQ8w==', '2021-09-12 16:34:23.070', N'ESKİŞEHİR HASAN POLATKAN HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1086, N'309367', N'Yücel', N'DOĞAN', N'05069140579', N'yucel.dogan@egm.gov.tr', N'Polis Memuru', N'Eskişehir Hasan Polatkan Havalimanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJLX/uAZGnAPR4i5IAEK9U/C+qd/sLCyfNP2UZpZVuDAxNwqH4VzPxD2MX8xxKL+qQ==', '2021-09-12 16:34:23.070', N'ESKİŞEHİR HASAN POLATKAN HAVA LİMANI', N'0', N'Student', '2026-04-07 15:04:46.473', 0, 1, 0, NULL, NULL),
            (1089, N'255857', N'Şener', N'UZUN', N'05384769589', N'sener.uzun@egm.gov.tr', N'Polis Memuru', N'İpsala', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEDaZrKTbkFPxUmviq03+iLNXGDVBnJYBx4/QmGtGSVWUY3Re3dCHDQWh+aJDgq1XYA==', '2021-09-12 16:34:23.070', N'EDİRNE İPSALA KARA HUDUT KAPISI', N'0', N'Student', '2026-04-08 02:48:34.123', 0, 1, 0, NULL, NULL),
            (1096, N'187413', N'Rüstem', N'İNAN', N'05053566622', N'rustem.inan@egm.gov.tr', N'Polis Memuru', N'Milas-Bodrum Havalimanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEKwgYTHxvRVJW2YYA6fqIBOhKnt08IIbxxl0MKje/WByCJG662vv3UbCC5jBDjQi7w==', '2021-09-12 16:34:23.070', N'MUĞLA MİLAS-BODRUM HAVA LİMANI', N'0', N'Student', '2026-04-05 12:56:22.520', 0, 1, 0, NULL, NULL),
            (1097, N'195675', N'Akın', N'KARAK', N'05052922673', N'akin.karak@egm.gov.tr', N'Polis Memuru', N'Milas-Bodrum Havalimanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJKkDFITP1F6XzsBOmbbBd3G7nuzGv6VQ3gTJ3Av5IK6Ze+2swCHIu/3qKCma+QZoQ==', '2021-09-12 16:34:23.070', N'MUĞLA MİLAS-BODRUM HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1099, N'246219', N'Garip', N'YEŞİLYAPRAK', N'05052150181', N'garip.yesilyaprak@egm.gov.tr', N'Polis Memuru', N'Milas-Bodrum Havalimanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEP9AkZUrjZFMZ3Nhh6alV6LDv/nGRHMSgEzBW5AdAE4hGPYUNqWCilXtRQloMuMQKg==', '2021-09-12 16:34:23.070', N'MUĞLA MİLAS-BODRUM HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1101, N'300974', N'ALİ', N'TOPAL', N'0505', N'egm@egm.com.tr', N'Polis Memuru', N'Pasaport Büro', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEMJbf1Qc03ZN2xTdyMhpA2PDzAwERZskL6RvvcbwbNE9YtnChlBOdK1ruvsKebb9Ug==', '2021-09-12 16:34:23.070', N'SAMSUN ÇARŞAMBA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1102, N'288172', N'İBRAHİM ', N'AKKUŞ', N'0505', N'egm@egm.com.tr', N'Polis Memuru', N'Pasaport Büro', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEOryHZcE0y0WWExEP0P056JFtXqeAGo3woBNEmJfgbSe03UvllOdXw1rdE3DbM4MCg==', '2021-09-12 16:34:23.070', N'SAMSUN ÇARŞAMBA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1103, N'297292', N'AHMET ', N'YAHŞİ', N'05063583315', N'egm@egm.com.tr', N'POLİS MEMURU', N'Pasaport Büro', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJevIPKO2trcy/5GJoB2EKAvAsEmX+FEn4tdDWMBkt3NQIX2FPLp6rthtLOY5Wm9xQ==', '2021-09-12 16:34:23.070', N'ANTALYA GAZİPAŞA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1106, N'287820 ', N'Yasin', N'YILDIZ', N'05301704214', N'yasin.yildiz9@egm.gov.tr', N'Polis Memuru', N'Muğla Bodrum  Deniz Limanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEDpv6oZ9C6MeMGvecsHAmesiViitEdbW4ToXl30THvOjiAU50gpr7sYhWiFlN/6lPA==', '2021-09-12 16:34:23.070', N'MUĞLA MİLAS-BODRUM HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (1109, N'228538', N'Şahmettin', N'SOYAR', N'05536339521', N'egm@egm.gov.tr', N'Polis Memuru', N'Bodrum Deniz Limanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEBR+3/kHuNDqjNYLyF1yBOrcFi2F984gvUo+7B0ASaEZX9HLVTzQ+dDPrlHvh9mqFQ==', '2021-09-12 16:34:23.070', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-09 15:12:48.883', 0, 1, 0, NULL, NULL),
            (1110, N'170749', N'CEVAT', N'BAŞ', N'05052712752', N'cevat.bas@egm.gov.tr', N'Polis Memuru', N'ORDU-GİRESUN HAVALİMANI', N'', N'3', N'1', N'AQAAAAEAACcQAAAAECekJs/Yi0Wa0Xsup2awYr0dTlgn0Gs1nUc+GWdmtKFcbUBChG2oxMiEPwS0nWfcLQ==', '2021-09-12 16:34:23.070', N'ORDU GİRESUN HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2116, N'300552', N'YAVUZ', N'YILMAZ', N'5063026712', N'yavuz.yilmaz8@egm.gov.tr', N'Polis Memuru', N'Trabzon', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEK2HS6rYDIvLQzEHHEhlkqgVx7A7DFFRk3C9oqbnUNKWkWNl3xzCkS7hVL/89uRAvg==', '2021-09-13 15:50:24.280', N'TRABZON DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-03 09:27:01.243', 0, 1, 0, NULL, NULL),
            (2118, N'296507', N'SELİM', N'TAŞ', N'05534856894', N'selimcan59@hotmail.com', N'polis memuru', N'edirne hamzabeyli hudut', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEB6JGkLwViSQETcbmOCM8m5HAu0duA8ei/uZmd1U8BDj4en7EOhwGMxq4cOhJH9mYA==', '2021-09-14 10:17:02.403', N'EDİRNE HAMZABEYLİ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2120, N'220063', N'AHMET', N'BOSTANCI', N'05064251020', N'abostanci@egm.gov.tr', N'PolisMemuru', N'Çanakkale Deniz Liman', N'', N'3', N'0', N'AQAAAAEAACcQAAAAECkVXEG8YBFn1BWQMznPC93s6kmntLYm0kcWCI4LtGbIlcVMKYKQWydCzrB/ghSwYg==', '2021-09-16 09:43:41.747', N'ÇANAKKALE KÜÇÜKKUYU DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2123, N'235318', N'Hatice ', N'ARSLAN', N'05054885544', N'hatice.arslan@egm.gov.tr', N'Polis Memuru', N'Pasaport Kontrol Büro Amirliği', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEDite+IKz6AejGY8fRpFbnE9GoIspHWEY6Wg31x1Khmc45sBxvLPETCJCcGrOvsNlg==', '2021-09-17 09:44:13.300', N'TRABZON HAVA LİMANI', N'0', N'Student', '2026-04-09 09:17:05.403', 0, 1, 0, NULL, NULL),
            (2126, N'282394', N'emrah', N'öztürk', N'5055956583', N'emrah.ozturk5@egm.gov.tr', N'polis emuru', N'pasaport', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEC6TkL+wofCLoHJ6C2aKVlIPsUR5Y5eMKqup8bMvSNTidZICga26Kgsz3MUoWIIFAw==', '2021-09-20 09:28:11.673', N'TRABZON HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2127, N'356353', N'SALİH', N'AKYOL', N'553 576 2561', N'salih.akyol2@egm.gov.tr', N'polis memuru', N'Trabzon Havalimanı ', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJJdooaSKbbfqufd6EsJruqt6HWgEZwEYK59RqBi60412PO/Lu6zqqPqOGHy8skqoQ==', '2021-09-20 09:28:15.347', N'TRABZON HAVA LİMANI', N'0', N'Student', '2026-04-03 10:25:19.823', 0, 1, 0, NULL, NULL),
            (2130, N'444161', N'muhammet', N'karaosman', N'05496701461', N'muhammet.karaosman@egm.gov.tr', N'polis memuru', N'havalimanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEEVQt8Y4K7G8PEQrVqhw1mWvcaKGC5q9CBJC3u4aqd7KqN5DrQQUzFAdy0eauqsCBg==', '2021-09-22 16:30:20.580', N'TRABZON HAVA LİMANI', N'0', N'Student', '2026-04-09 09:55:27.727', 0, 1, 0, NULL, NULL),
            (2132, N'256124', N'İBRAHİM', N'YİĞİT', N'0 505 483 40 80', N'ibrahim_5061@hotmail.com', N'Polis Memuru', N'Trabzon Havalimanı Şube Müdürlüğü', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEI7qEZQQWqMdlj7HlsoVIG2l8tv2YLW3OI7sUWjvsDzuG4ZKj0YC2s/JUvs5TFJAcA==', '2021-09-27 15:34:52.763', N'TRABZON HAVA LİMANI', N'0', N'Student', '2026-04-02 09:20:05.377', 0, 1, 0, NULL, NULL),
            (2143, N'167614', N'MEHMET HAKAN', N'ÇOLAK', N'05053527627', N'mehmethakan.colak@egm.gov.tr', N'POLİS MEMURU', N'BODRUM/MUĞLA', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEN8HoAvABiC+aJLx31tzbKUyKXJ/l/X+jbhXo0I63wm+SybrOSV+1W5kxZet4QauRA==', '2021-10-18 12:11:36.740', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2145, N'173827', N'YUSUF', N'DAĞ', N'05055075138', N'yusuf.dag@egm.gov.tr', N'polis memuru ', N'kapıkule kara hudut kapısı şube müdürlüğü', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEChqRZnRVLYlDsFo6OX5PPQ/dx+RvQmrj8bWh7WI1wX+4LFWLilwUSOVeniGyRt8bA==', '2021-10-25 16:14:58.507', N'EDİRNE KAPIKULE KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2146, N'295904', N'SAMET', N'KOÇOĞLU', N'05064183125', N'samet.kocoglu@egm.gov.tr', N'Polis memuru', N'Kapıkule Kara Hudut Kapısı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEFAM8vPhQtUQjtn89meYQmCyc6XhPUlFy6bqSs/nG8gnt0UsYzamxLfQqYWOBxN/lg==', '2021-10-25 16:15:31.257', N'EDİRNE KAPIKULE KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2148, N'160583', N'METE', N'TARHAN', N'5053056806', N'metetarhan06@gmail.com', N'polis memuru', N'konya havalimanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEEOjzYpBCHyYNSf8YYJRvKMTctFsvdO2w16CHqQS3k9z7S3IzxUSbWCzswwDZLCQLQ==', '2021-10-26 09:52:13.197', N'KONYA HAVA LİMANI', N'0', N'Student', '2026-04-05 04:25:08.103', 0, 1, 0, NULL, NULL),
            (2150, N'225116', N'zeki', N'kadam', N'05053580559', N'zeki.kadam@egm.gov.tr', N'polis memuru', N'muğladalaman havalimanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEI4MdO57/4eVo/GzHsOcSaSlElerk3vVe+JagS6j66jB7/YO/2bQLYQn+ruGmBUcbg==', '2021-10-26 09:54:18.470', N'MUĞLA DALAMAN HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2151, N'245125', N'Özgür', N'ÖZCAN', N'5055011609', N'ozgur.ozcan@egm.gov.tr', N'polis memuru', N'Kapıkule KHK Şube Müdürlüğü', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEC2Vh03EYVtiak3fQYmlWJ5mR+BxTdoBvy7MS7IwFiMVHLg4mSvbXjX7V1myefWDnQ==', '2021-10-26 09:55:14.410', N'EDİRNE KAPIKULE KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2161, N'219721', N'YAKUP ', N'ZENGİN ', N'05306563396', N'yakup.zengin@egm.gov.tr', N'Polis Memuru ', N'Taşucu Seka Deniz Hudut Kapısı ', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEE6po/NPe2F7xQB/BIlVRmGxSBZdtFb+eCYKdh5NS19rfevLgmM00YMSsp+UZpegVQ==', '2021-10-28 23:10:25.270', N'MERSİN TAŞUCU-SEKA DENİZ HUDUT KAPISI', N'0', N'Student', '2026-03-30 21:01:57.043', 0, 1, 0, NULL, NULL),
            (2162, N'236075', N'Öztürk', N'DEMİRCİ', N'05052304780', N'ozturk.demirci@egm.gov.tr', N'Polis Memuru', N'Edirne Kapıkule Kara Hudut Kapısı Emniyet Şube Müdürlüğü', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEADIiEU1GqhYypezzmbJIk9qCpg1eF1aU9cqdfvhRy22IshMOW32g/OY0dLQkNpkiA==', '2021-10-28 23:10:30.380', N'EDİRNE KAPIKULE KARA HUDUT KAPISI', N'0', N'Student', '2026-03-30 21:36:09.080', 0, 1, 0, NULL, NULL),
            (2164, N'477787', N'EREN', N'BAKAR', N'05524124900', N'eren.bakar@egm.gov.tr', N'polis memuru', N'Kapıkule Kara Hudut Kapısı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAELavsFoaJkGsjUd4lO9U43Dfp2SFA2o/Ux4CwAJ+ZhxU9sGPMlLwH0Iza19Hf8r5cQ==', '2021-10-28 23:10:38.583', N'EDİRNE KAPIKULE KARA HUDUT KAPISI', N'0', N'Student', '2026-04-08 14:40:09.303', 0, 1, 0, NULL, NULL),
            (2166, N'250703', N'selim', N'YILDIZ', N'05052138915', N'selimyildiz15@hotmail.com', N'polis memuru', N'ısparta', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPZyySLaKgcuS8WF8BkEIFk6vDES/jh1gVm1zVTennyfsA7yuUJBLL5lFikCergkIA==', '2021-11-01 08:54:41.363', N'ISPARTA SÜLEYMAN DEMİREL HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2169, N'178294', N'SAVAŞ', N'DENİZ', N'05052782375', N'savas.deniz@egm.gov.tr', N'Polis Memuru', N'Pasaport', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEFpLtVjBcMnaHdZJ/nJtLBRD4JqETpDYrMdPLb9+abABK3kR7aUjMSrZRnrWVi/B9A==', '2021-11-08 09:10:15.767', N'KONYA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2170, N'297465', N'KEMAL', N'BAYRAM', N'05065148140', N'kemal.bayram@egm.gov.tr', N'POLİS MEMURU', N'ZEYTİNBURNU DENİZ LİMANI BÜRO AMİRLİĞİ-İSTANBUL DENİZ ŞUBE MÜDÜRLÜĞÜ', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEEIfWEuxSbkBPFwlEQjW3ZT+Izb84ba48InmvTJCB/9SqSm6ZNwNPzqf6mPE6ojAiA==', '2021-11-08 09:10:19.530', N'İSTANBUL ZEYTİNBURNU DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2172, N'257628', N'CENK', N'DURMUŞ', N'5055124234', N'cenk.durmus@egm.gov.tr', N'polis memuru', N'konya havalimanı', N'', N'3,4', N'1', N'AQAAAAEAACcQAAAAENoFuLwJ1RY9CvqlafjgLRZ98iCujeJpPmCDYL6vYsEbZJHxjBMQHKhtZ1/LFrDZrQ==', '2021-11-09 09:34:40.727', N'KONYA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2175, N'177237', N'TANER', N'GÖKMEN', N'05053579832', N'taner.gokmen@egm.gov.tr', N'polis memuru', N'ZEYTİNBURNU DENİZ LİMANI BÜRO AMİRLİĞİ-İSTANBUL DENİZ LİMANI ŞUBE MÜDÜRLÜĞÜ', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEI+L8KeJFk3waswLeneIXt/8iyxslbQP76ToCAzs0joyoYPtlklctG6u6gwlm7g2Gw==', '2021-11-09 16:58:30.373', N'İSTANBUL ZEYTİNBURNU DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2177, N'278952', N'MEHMET AKİF', N'UCA', N'05057798369', N'mehmetakif.uca@egm.gov.tr', N'polis memuru', N'ZEYTİNBURNU DENİZ LİMANI BÜRO AMİRLİĞİ-İSTANBUL DENİZ LİMANI ŞUBE MÜDÜRLÜĞÜ', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEB0YeBtbRi+ZJ3V0sS+z/giCWtOz91McqcRwSaP89oq708J4Zyb5Zc1Kk6BhQ5taHw==', '2021-11-11 08:42:25.000', N'İSTANBUL ZEYTİNBURNU DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-08 21:46:43.127', 0, 1, 0, NULL, NULL),
            (2179, N'315184', N'MEHMET', N'TURĞUT', N'5079849628', N'mehmet.turgut3@egm.gov.tr', N'Pdlis Memuru', N'Hatay Havalimanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEN+N/DTVBR0srFyjk97AKKYnIB1cHEOv6FSkqY2P6OjBsZY6rwuQ3NP1ja4hw+2C5Q==', '2021-11-11 08:42:33.517', N'HATAY HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2183, N'220753', N'AHMET', N'YILDIRIM', N'05534553811', N'ahmet.yildirim2581ef@egm.gov.tr', N'polis memuru', N'taşucu seka limanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEEmkE1vLV7NRW8ixu5m1LJzpbV5dBdC4zwJOG24W0yxxlbRCnF9Meyj9n2LoHb3TNQ==', '2021-11-12 15:57:26.737', N'MERSİN TAŞUCU-SEKA DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2185, N'159631', N'MEHMET ', N'VURKAÇ', N'05052138128', N'mehmet.vurkac@egm.gov.tr', N'Polis Memuru', N'Hatay', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPrwc0ZzMv1JkvcoKiTIjeG45qcvRY1x+5L35YLBCbKWm3Rpj4kNEwm/CKTo/ETHgg==', '2021-11-15 10:14:54.313', N'HATAY HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2192, N'254156', N'FATİH', N'KARASU', N'05053041950', N'fatih.karasu@egm.gov.tr', N'kıd.başpol.me.', N'Fethiye Deniz Limanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAECsGPBWiNZ0E9qr5VC8mVFvu+Q6ZZQCC0bASSoD0hfm5eiWAZD0vMKPv4BClTFnF/w==', '2021-12-06 15:34:08.383', N'MUĞLA FETHİYE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2193, N'223935', N'Esra ', N'Şenbaş', N'05055429895', N'esra.arsoy@egm.gov.tr', N'pol.me.', N'Fethiye Deniz Limanı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJs8Sd7RKM8ODpcxu6HWLkpQv4cT0aCg94/MIIC8EB5dkgrQ38sej6zJt2NB9/bwhw==', '2021-12-06 15:34:38.260', N'MUĞLA FETHİYE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2194, N'228912', N'ORKAN', N'YILMAZ', N'05055441244', N'orkan.yilmaz@egm.gov.tr', N'Polis Memuru', N'Tekirdağ Deniz Hudut Kapısı', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPDL3MeYVuNzHktF3DM06nvGqhQ8TPbAftl42pmo14dd1iclOC4qSW6gK9ZPIoDScg==', '2021-12-07 10:37:47.173', N'TEKİRDAĞ MARMARA EREĞLİSİ DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2195, N'213618', N'İLKER', N'ÜLGEN', N'0 505 327 94 19', N'ilker.ulgen@egm.gov.tr', N'Polis Memuru', N'Bandırma Deniz Limanı Şube Müdürlüğü', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEP3tK2NdaKLvsKa0PHWFjf6w46Bc5G4kymgCzBzi2vS03SWrUCNtcTgBZ0w6uDzunA==', '2021-12-10 14:06:35.853', N'BALIKESİR BANDIRMA DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2199, N'248739', N'KENAN', N'BULUK', N'05053660263', N'kenan.buluk@egm.gov.tr', N'POLİS MEMURU', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'a36355996f814745aa02199eebf17a92.jpg', N'3', N'0', N'AQAAAAEAACcQAAAAEEGSSXdvlNMg/bX3bzX2Od2aVr65ky5MsZH6R6GZJ4MooxkVruWGbc3aUpoSP3GZzg==', '2021-12-13 11:16:03.890', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'0', N'Student', '2026-04-09 10:23:43.803', 0, 1, 0, NULL, NULL),
            (2200, N'304321', N'Erkin', N'Kocaman', N'05059292060', N'erkin.kocaman@egm.gov.tr', N'Polis Memuru', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEHwDtIogJUzRvL27Ce7FFKEf2cAI/2COWe55C+y25EoUiTPGwxj/g6vk1oQ1Irc8uw==', '2021-12-13 11:16:50.593', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'0', N'Student', '2026-04-07 11:14:10.457', 0, 1, 0, NULL, NULL),
            (2207, N'267416', N'ERSAN', N'ŞENOL', N'05052767893', N'ersan.senol@egm.gov.tr', N'POLİS MEMURU', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEE7Sw6So1G16wNBJs7vXIU40C+N+T0hNgj2Ws3qPaWA8qgeIXlT4Fh4W7trGM2AknA==', '2021-12-13 14:14:36.093', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'0', N'Student', '2026-04-08 14:27:05.350', 0, 1, 0, NULL, NULL),
            (2209, N'382630', N'BURAK', N'KILIÇ', N'05070387287', N'burak.kilic6@egm.gov.tr', N'Polis Memuru', N'EDİRNE HAMZABEYLİ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAELAkuoz6sAqh8j1/NXFWQDP1O4bx1TotIjYrjPSy6NnsoDB8Omnub5KUMTqO/LAn1A==', '2021-12-13 14:15:47.317', N'EDİRNE HAMZABEYLİ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2211, N'448622', N'EVREN', N'AYDINER', N'05070631585', N'evren.aydiner@egm.gov.re', N'Polis Memuru', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEDtva2YP/2i+pl+mwRgxXOBtt5bGqO4juVDocDDd/uJtd9bpnXPqMrQbp3WmhCEWuw==', '2021-12-13 14:16:32.587', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'0', N'Student', '2026-04-09 09:44:42.980', 0, 1, 0, NULL, NULL),
            (2213, N'208229', N'İSMET', N'KILIÇLI', N'5053566393', N'ismet.kilicli@egm.gov.tr', N'Polis Memuru', N'ANTALYA FİNİKE DENİZ HUDUT KAPISI', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEOCPAbGfixoZT6Ua+ly+yzKKHO8t7GR+g0JPGDM+YytC2PVZ5GeX5V6NFSnPvp0vpw==', '2021-12-13 16:00:07.117', N'ANTALYA FİNİKE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2216, N'204933', N'DOĞAN', N'KUTSAL', N'0506 532 68 65', N'dogan.kutsal@egm.gov.tr', N'Polis memuru', N'MERSİN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEBygwDnIbrMQOvdrvsos1+CgLb3EwQd1DDtNThnI5Hy8ev56Oze3PE1miSdA4kI7TQ==', '2021-12-14 11:32:11.297', N'MERSİN DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2217, N'418993', N'TARKAN', N'AKIN', N'05530792167', N'tarkan.akin@egm.gov.tr', N'POLİS MEMURU', N'YALOVA RO-RO DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEAOQOKe0Zsv+H0LzbMWuHUULT/kDG7i0jmw4HOBMsxu1rwrhNqvsh+s8SttydTsPvA==', '2021-12-14 11:32:15.000', N'YALOVA RO-RO DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2220, N'230095', N'Çoşkun', N'ÇAĞLAR', N'05052170489', N'coskun.caglar@egm.gov.tr', N'Polis Memuru', N'KONYA', N'', N'3', N'0', N'AQAAAAEAACcQAAAAECwqI6KMkzIyTFB5vix/NbVPV0JtVTIRh3f4rwOFOxgNbvE7+Tcdk5rzV9x3DmHVqw==', '2021-12-14 12:12:04.003', N'KONYA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2223, N'246496', N'Semih', N'ARSLAN', N'05059234154', N'semih.arslan@egm.gov.tr', N'polis memuru', N'KOCAELİ DERİNCE DENİZ HUDUT KAPISI', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEJM38eSo3ExCYU/CYWXwearjODGe+sE6r65+JDrjXQ4BWuJiuyRFcLYuCM6tDmPL5g==', '2021-12-16 08:57:40.957', N'KOCAELİ DERİNCE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2224, N'341750', N'MESUT', N'ÇOBAN', N'5305550387', N'mesocoban@gmail.com', N'pol. mem.', N'EDİRNE HAMZABEYLİ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEIHIa1CanfGbJGRGmyae2cuT9RtJFM0HMlK+XH2hzoJKUCSzh6K/fI8yTRWcztzjkw==', '2021-12-17 09:10:30.647', N'EDİRNE PAZARKULE KARA HUDUT KAPISI', N'0', N'Student', '2026-04-08 18:35:38.723', 0, 1, 0, NULL, NULL),
            (2225, N'374447', N'ÖMER FARUK', N'KAHYA', N'05465914927', N'OMERFARUK.KAHYA@EGM.GOV.TR', N'POLİS MEMURU', N'ÇARŞAMBA HAVALİMANI', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEJI3GX0KZjs6+a2lqQrK1zSLICO7fcvix5iuHrha7DQDFQvUAASB23CsQTPJqrY5kA==', '2021-12-20 12:51:35.257', N'SAMSUN ÇARŞAMBA HAVA LİMANI', N'0', N'Student', '2026-04-06 08:47:57.470', 0, 1, 0, NULL, NULL),
            (2226, N'412429', N'KADİR', N'YÜCEL', N'05412105336', N'kadir.yucel4@egm.gov.tr', N'Polis Memuru', N'IĞDIR DİLUCU KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAENgOgPqhy+vmRN+oNPuaWJZnFIe8sOMPBEGu4JJW1xS4icViCvrU8jH8QAbGHAcVQQ==', '2021-12-20 12:51:39.507', N'IĞDIR DİLUCU KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2228, N'302514', N'ŞEFİK', N'ODUNCU', N'5392062145', N'sefik.oduncu@egm.gov.tr', N'Polis Memuru', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'1f349e86c30849d7a53b24a0e2ce4276.jpeg', N'3', N'0', N'AQAAAAEAACcQAAAAEB6yon0QZIrS6J/PQFE4EcnDaiHfUm0XGL4d7HUm1VwbEwvRnpALHRJXwAOO1144bg==', '2021-12-21 09:59:10.703', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'0', N'Student', '2026-04-02 07:51:56.237', 0, 1, 0, NULL, NULL),
            (2234, N'303405', N'AHMET', N'YILMAZ', N'5067422252', N'ahmet.yilmaz13b55b@egm.gov.tr', N'Polis Memuru', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEFuu7H/mOiqnjhh9gJnuCGHDfj1IjfBnfSFvZlfFSoMxnSb8RNIgzoBMsjQ0Ah7MGw==', '2021-12-21 14:40:54.813', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2240, N'210226', N'ALİ', N'KIZILDAĞ', N'5535370595', N'ali.kizildag2@egm.gov.tr', N'POLİS MEMURU', N'ANTALYA GAZİPAŞA HAVA LİMANI', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEPFvuANaaZlOPPPvXjfWPOry2g/BaMJ/3cmSqWX4cNlscY7J2L185adZBVjdgkXJZw==', '2021-12-23 10:12:24.247', N'ANTALYA GAZİPAŞA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2244, N'166545', N'AHMET', N'GERDAN', N'0505 369 73 19', N'ahmet.gerdan@egm.gov.tr', N'Polis Memuru', N'AYDIN KUŞADASI DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEGsBE2lkhV1N/W7RtskUZmZv4PzwET/dOYmPasbw7S6AGFv/1rn0FfG0rPtl/8mHdA==', '2021-12-27 10:53:05.613', N'AYDIN KUŞADASI DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2251, N'433464', N'Murat ', N'YAKUT', N'0505', N'egm@egm.gov.tr', N'Polis Memuru', N'VAN-KAPIKÖY', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEISCtkebkBU08ZGMYqjjrnhoGd2icdJ3Te4QHFTziSm9rRRBKoo1itVxuVbAJVEG6Q==', '2021-12-28 14:46:20.287', N'ISPARTA SÜLEYMAN DEMİREL HAVA LİMANI', N'0', N'Student', '2026-04-01 03:17:22.863', 0, 1, 0, NULL, NULL),
            (2252, N'211010', N'MUSTAFA', N'KILIÇ', N'05055151596', N'mustafa.kilic22e455@gmail.com', N'Polis memuru', N'İSTANBUL TUZLA DENİZ HUDUT KAPISI', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEEmd6AmReBJzg2N0VB2geabfgPWVHAgiwSOuiL/n9feYwl9KuhVHsDUJuTtzrgnTgQ==', '2021-12-28 14:48:05.073', N'İSTANBUL TUZLA DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2253, N'320918', N'ERCAN', N'TEMİZ', N'05067735261', N'ercan.temiz@egm.gov.tr', N'Polis Memuru', N'SAMSUN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAECHAlTEKVq1+LVKIi8z6uYKZrUpqOSLSLfCyGBYgCmc9b+1KCeQ5Vuo5IZbiCQdoMA==', '2021-12-28 14:48:09.807', N'SAMSUN DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2256, N'351941', N'MÜRSEL', N'BAYRAM', N'0507 972 24 83', N'mursel.bayram@egm.gov.tr', N'Polis Memuru', N'İSTANBUL TUZLA DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEBZL7M5nUuWC5HYvulu0iZJbhMkY8inwB5FyWTv7YdpMsiaLe6TUj+LLosc3ToAQtg==', '2021-12-28 18:53:02.760', N'İSTANBUL TUZLA DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2259, N'302356', N'ÖZGÜR', N'KIR', N'05058735990', N'ozgurkir@egm.gov.tr', N'Polis Memuru', N'MARMARİS', N'', N'3', N'0', N'AQAAAAEAACcQAAAAELP64ICQYaFxt6aRoSamiC2LPjDxXBXjN9zwOQo48ztaPzyuQJn68KdCmVZozwf2YQ==', '2021-12-31 09:36:43.670', N'MARMARİS DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2263, N'258444', N'ÖMER', N'NURDOĞAN', N'5055420946', N'omer.nurdogan@egm.gov.tr', N'Polis Memuru', N'HATAY İSKENDERUN YAZICI DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEAwjMTE7YCGpbcrTcCuuBU+DvSubA2A9rmq1O/RIjbRzE35Xy5Geyd6bM4FvVSO76A==', '2022-01-03 10:29:13.510', N'HATAY İSKENDERUN YAZICI DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2264, N'281666', N'CENGİZ', N'KILIÇOĞLU', N'05058835591', N'cengiz.kilicoglu@egm.gov.tr', N'polis memuru', N'KAYSERİ HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAENGEh25EcAaPEJ0cUynRPu8dmeATs7Gx7P76AD+eSw3k4VG1LB8YUwqgVO+60FWOpg==', '2022-01-03 10:29:15.917', N'KAYSERİ HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2265, N'298356', N'İSMAİL', N'GÜRBÜZ', N'5057868900', N'ismail.gurbuz@egm.gov.tr', N'POLİS MEMURU', N'GAZİANTEP HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAENvGAThCwzEX59rVtyzhYhFiIBT5/uPHFk+XsMjLFO5ShoP7scPGfIeAG7b3QFMO4w==', '2022-01-03 10:29:18.323', N'GAZİANTEP HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2266, N'309280', N'İHSAN', N'KARA', N'5067874184', N'ihsan.kara@egm.gov.tr', N'POLİS MEMURU', N'GAZİANTEP HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEHwqPX1aIVJjqcF6+5E/Qy/JZOZz6K0xW3C2CW4HtA5r3FkoXlPcZaklRFJb5pXelA==', '2022-01-03 12:19:00.650', N'GAZİANTEP HAVA LİMANI', N'0', N'Student', '2026-03-31 06:34:30.533', 0, 1, 0, NULL, NULL),
            (2267, N'280771', N'DURAN', N'SAÇMACI', N'05059201359', N'duran.sacmaci@egm.gov.tr', N'POLİS MEMURU', N'ANKARA ESENBOĞA HAVA LİMANI', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEIRm8bzytSgaR5jub1zcpRkW9NQD6QSydUkZs5efbh+NQi1CCfeAYg7IiEuoJ6pFNw==', '2022-01-03 15:46:29.440', N'ANKARA ESENBOĞA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2269, N'203307', N'NECMETTİN', N'DEMİR', N'05055673477', N'necmettin.demir@egm.gov.tr', N'POLİS MEMURU', N'GAZİANTEP HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEMyRHgJ127aM9CGK9TTBj7ZxiMRw04UUsAMVArWHPuB10ZUHbtlwCQNMHxB3feArcQ==', '2022-01-04 09:23:30.657', N'GAZİANTEP HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2270, N'237291', N'FATİH İMAM', N'BAYAR', N'5057558181', N'fatihimam.bayar@egm.gov.tr', N'polis memuru', N'GAZİANTEP HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEIMhhPCxYMte4LVX9kUu9cdvTCq6S/5OAAlfuJnhqY8zpJY3d9szJ19+xl0CmRgf7Q==', '2022-01-04 09:23:35.000', N'GAZİANTEP HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2271, N'264013', N'MEHMET', N'YILMAZ', N'5054688420', N'mehmet.yilmaz1e2d05@egm.gov.tr', N'Polıs', N'GAZİANTEP HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAED3qj2s/DXX22y/xqc7xulBDGv44nsDUV0JIFeOCDG6RyOOFDOKd96toTVzbwsE+gQ==', '2022-01-04 14:16:07.907', N'GAZİANTEP HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2272, N'205279', N'AHMET', N'AKSOY', N'05052115733', N'ahmet.aksoy@egm.gov.tr', N'Polis Memuru', N'MERSİN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEN7BXe0Yb3LiAnETc+gDr8Rzfo9bEbscOX4B4Q0Jtmo5SliNeHE0n590ywDGa+CUAw==', '2022-01-05 09:07:05.997', N'MERSİN DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2277, N'316550', N'KADİR', N'GÜÇÜKLÜOĞLU', N'05073424492', N'kadir5288@hotmail.com', N'Polis Memuru', N'SAMSUN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEOoYNeD2QwA76u3XIVa6HSg+X9jSrVglCGnC4F8OJC9h5sDkr8faHA3wkow4gniGGA==', '2022-01-10 13:35:07.843', N'SAMSUN DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2280, N'333081', N'anıl', N'aydın', N'05536034624', N'anil.aydin@egm.gov.tr', N'polis memuru', N'İZMİR ADNAN MENDERES HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPnOPEXIZwKe5CoHgmacP3nu7yRX1AvlaGTG4xcwkBg+gG6D8QVJCkQlT1qW1dP0yQ==', '2022-01-10 15:02:53.830', N'İZMİR ADNAN MENDERES HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2281, N'169516', N'MUSTAFA', N'SOYCAN', N' 0 505 275 21 80', N'mustafa.soycan@egm.gov.tr', N'Polis Memuru', N'VAN FERİT MELEN HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEDqdhNdEEQ9iqQWKp44eZ2BnlbqzePSRYxRaIvAt+6EOJLhXvxdtaYW1YWl2DzVYCQ==', '2022-01-10 15:02:58.910', N'VAN FERİT MELEN HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2282, N'284522', N'FATİH ', N'KARAISLI', N'05059177039', N'fatih.karaisli@egm.gov.tr', N'polis memuru', N'İZMİR ALİAĞA DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAENxGiVky6tMrJaOrhGyzDwjdVQmUqBXNZH/nq5bC9SfoXw49OSZ6UhR9orT5fdNLMw==', '2022-01-10 16:29:09.257', N'İZMİR ALİAĞA DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2284, N'266334', N'SERCAN', N'BOZLU', N'5057731520', N'sercan.bozlu@egm.gov.tr', N'polis memuru', N'MERSİN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAED+msrj15pT43OvKt43pf9r/qPBRZb61WQ47nJERwAvset3OWQNhtrz6lNh/OGjdRQ==', '2022-01-11 15:45:35.300', N'MERSİN DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2286, N'278756', N'ÖMER', N'GAMSIZ', N'5066825800', N'omer.gamsiz@egm.gov.tr', N'polis memuru', N'MERSİN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEHJjeNC8VfJD2bPB2PRgbi+ihsBnCZ3OPkf9CIfDLoFVeO0iHgOTm78qXGUAm00Nbg==', '2022-01-11 15:45:41.783', N'MERSİN DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2288, N'208024', N'SALİM', N'DÜLGER', N'0532 568 10 28', N'salim.dulger@egm.gov.tr', N'polis memuru', N'TRABZON DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAED1kVS60wfGD6WDTBu2sGB+Qbf/6/i2nUKFMG+BufN8KuP+ovzEd0wbdygDfNTTybw==', '2022-01-12 09:23:10.647', N'TRABZON DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-05 10:22:26.533', 0, 1, 0, NULL, NULL),
            (2290, N'243953', N'AYDIN', N'KIZGIN', N'05052965275', N'aydin.kizgin@egm.gov.tr', N'Polis Memuru', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEMGXrTTsEAIuvvmlag2j6Q9+es+KjIAH+0vQTnb3NLqEWxWeeZhWENgieaBgM1QDOQ==', '2022-01-17 09:31:24.033', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2293, N'371984', N'İSMAİL', N'CANDAN', N'5076439380', N'ismail.candan2@egm.gov.tr', N'polis memuru', N'KOCAELİ DERİNCE DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAECqTxskBqMY9vBww8ArUjp0o+DqqlM5kL0As8MBC5HHfIP53eQzXdbxsgJSwOKTYrA==', '2022-01-17 09:31:31.817', N'KOCAELİ DERİNCE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2295, N'467107', N'ADEM', N'BAYRAM', N'5318955969', N'adem.bayram3@egm.gov.tr', N'polis memuru', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEOzdmhHVD+g8czor51Or4WPjo54HwnMK85ft7xAQdUGVrQoUaXurLuEB7+rmBxXL/w==', '2022-01-17 09:31:36.097', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'0', N'Student', '2026-04-08 04:59:37.253', 0, 1, 0, NULL, NULL),
            (2298, N'261010', N'AHMET', N'KARASİS', N'507 234 68 80', N'ahmet.karasis@egm.gov.tr', N'POLİS MEMURU', N'HATAY MMK METALURJİ DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEGrDKbQFS9zTKWK8qfmV5kEt9Ku/+IemRWZltAsC+wlvJs7AO0RmV4R0Z5JQE9E2Ag==', '2022-01-17 10:28:47.213', N'HATAY MMK METALURJİ DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-08 08:33:53.543', 0, 1, 0, NULL, NULL),
            (2299, N'329156', N'MEHMET EMİN', N'ŞİMŞEK', N'5442067710', N'mehmeteminsimsek86@gmail.com', N'polis memuru', N'HATAY MMK METALURJİ DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJ+elpWXeRuDC8PtU6XvpSLe8HUYKvdAFxo3h8HvbbtiB7msul1Nu+gTtEm7fjWj6Q==', '2022-01-18 12:05:39.343', N'HATAY MMK METALURJİ DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-09 11:56:03.990', 0, 1, 0, NULL, NULL),
            (2303, N'366549', N'MUSTAFA', N'ACAR', N'0506 582 94 73', N'mustafa.acar12b33c@egm.gov.tr', N'Polis Memuru', N'HAKKARİ ESENDERE KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPliaZBYXg9KX0Geo5aHA9TnMAJLP6OU3HYpiObUs229pE2Acd6ueVx334bEAF2Naw==', '2022-01-21 16:26:47.397', N'HAKKARİ ESENDERE KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2305, N'388668', N'KERİM', N'SÖKMEN', N'5071803767', N'kerim.sokmen@egm.gov.tr', N'P.M.', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPSMXx1RihWYp9EvkKwW2TIY9ME1Q6fXHIyADi2TP53/RKOvf0BIvRr2C9NuzZb4GA==', '2022-01-25 12:28:32.783', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2312, N'279382', N'soner', N'uğur', N'05077962584', N'soner.ugur@egm.gov.tr', N'polis memuru', N'MERSİN TAŞUCU-SEKA DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEC7nxFknUaApPH3IMOMTHFmiH3Yp/i2jpuDO0CFANVAR5SMJd+weHjKCWOAVzDNWRw==', '2022-01-29 14:08:20.400', N'MERSİN TAŞUCU-SEKA DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2313, N'195539', N'Güntay', N'ATALAY', N'05053467191', N'guntay.atalay@egm.gov.tr', N'Polis Memuru', N'İSKENDERUN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEFqb3eaQ0TsTOK0egCMbW1MemHOyivNtJPH7OxC/AnsLu0grK1Ebq20u1cs5IG9icw==', '2022-01-31 09:52:55.537', N'İSKENDERUN DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-05 23:19:01.627', 0, 1, 0, NULL, NULL),
            (2314, N'445149', N'MUSTAFA', N'ŞEKER', N'05369810034', N'sekermustafa27@gmail.com', N'polis memuru', N'SAMSUN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEG20d2f6JBliVTmt4wVudDqMEKLDlwqWwbltxanPbShV7BS5g5fTlpSZVT/o4O/MMQ==', '2022-01-31 09:52:57.973', N'SAMSUN DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2315, N'264022', N'SEMİH', N'BAHAR', N'5055212416', N'semih.bahar@egm.gov.tr', N'Polis Memuru', N'MUĞLA TURGUT REİS DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJubPDYGaHGz39iILXnAP4MPc+902sot7y75Vs7WEKdAFcJEsru9Ag99MTntRU1isA==', '2022-01-31 11:34:04.133', N'MUĞLA TURGUT REİS DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2323, N'320621', N'BURHAN', N'HATİBOĞLU', N'5073123681', N'burhanhatipoglu@egm.gov.tr', N'Polis Memuru', N'TEKİRDAĞ ÇORLU HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPC0/uUY/TDaHZyBMptZCn0dp4ASsAmVyO6uQx+EApzcH7yul+tlDz46KMCWAWQPkg==', '2022-02-07 10:18:07.990', N'TEKİRDAĞ ÇORLU HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2324, N'401073', N'Ömer Faruk ', N'SIR', N'05550403569', N'omersirr@hotmail.com', N'Polis Memuru', N'YALOVA RO-RO DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEAH8zjKtZkSgu9Q1sSHcrGu5usuoXa5+2mQDYuYjoS+bExGtJEi+PjOAe6WBJVXuNg==', '2022-02-07 10:18:10.287', N'YALOVA RO-RO DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2326, N'209301', N'HASAN ', N'YAĞCI', N'5054535211', N'hasan.yagci@egm.gov.tr', N'Polis Memuru', N'AYDIN DİDİM YAT LİMANI DENİZ HUDUT KAPISI BÜRO AMİRLİĞİ', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEHfE62aW7qWb4spS62JqYKIpJzLEkgSYkie5Ogb3kZYZI9C3bN4E5F5bLocPGR35wg==', '2022-02-07 14:58:37.170', N'AYDIN DİDİM YAT LİMANI DENİZ HUDUT KAPISI BÜRO AMİRLİĞİ', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2327, N'312990', N'SEVGÜL', N'ÖZDEMİR', N'5554048167', N'sevgul.ozdemir@gov.tr', N'polis memuru', N'AYDIN DİDİM YAT LİMANI DENİZ HUDUT KAPISI BÜRO AMİRLİĞİ', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEFa8Mbt080DgDOO0lW917GxqX3qw0Ywc9q2pAtb1ojHO3dFsluUY6/V/NXqMhWWQKw==', '2022-02-07 14:58:48.360', N'AYDIN DİDİM YAT LİMANI DENİZ HUDUT KAPISI BÜRO AMİRLİĞİ', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2330, N'295057', N'YASİN', N'ŞİŞGİNOĞLU', N'05063810028', N'netosariyin@hotmail.com', N'polis memuru', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEB1Q+QJm4H/oYWDxGEJBGMM0+34vKJ2Q/MZslq6gx4mIzDmuyOSHZ8lzJ+sm0TOCUw==', '2022-02-10 13:37:04.260', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2340, N'202899', N'EYYÜP', N'IŞIK', N'5054842700', N'eyyup_33@hotmail.com', N'Polis Memuru', N'MERSİN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAECyCXO1A+JvbqVsuo4YyW7o4yHqwM8O/SlXMhEoZ4dF4PNPZjyTaWpJRXBozEneplw==', '2022-03-03 10:14:34.797', N'MERSİN DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2341, N'226394', N'Ramazan', N'TEKİN', N'05053862979', N'ramazan.tekin4@egm.gov.tr', N'Polis Memuru', N'MERSİN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPE6ZxIrqiQVGIVLIoFbd7PJ8Vobs873u0HKqsFQ4ejkymgzrfoCfIY5/qrJygF/ow==', '2022-03-03 10:14:37.093', N'MERSİN DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2344, N'327832', N'ALİ', N'TAMBOLAT', N'05069221200', N'ali.tambolat@egm.gov.tr', N'Polis Memuru', N'İSTANBUL HAYDARPAŞA DENİZ HUDUT KAPISI', N'b1c925acb0cf452c942c16833aa847a7.png', N'3', N'0', N'AQAAAAEAACcQAAAAELLWpTdtzvrtVCRNONJn9vzyq6vXumnDHiWyiuv7Ixipmsfl0W8qFMV+EpBz0tB2hw==', '2022-03-03 13:01:52.443', N'İSTANBUL HAYDARPAŞA DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-01 14:02:54.960', 0, 1, 0, NULL, NULL),
            (2348, N'288132', N'SALİH ', N'DOĞAN', N'05058297506', N'salih.dogan4@egm.govtr', N'Polis Memuru', N'DENİZLİ ÇARDAK HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAECRxk4mwfWZnCRbXQmc0+4mLP0FVqpS29jIeFieusRaCjjchjr1z0fk7BbItnLxh+w==', '2022-03-07 16:11:30.597', N'DENİZLİ ÇARDAK HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2349, N'207522', N'ORHAN', N'ABALI', N'05053495557', N'orhan.abali@egm.gov.tr', N'Polis Memuru', N'DENİZLİ ÇARDAK HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEAWxQ/Ep3SKKfR4mHenRmmzlZe9ttoWLULPgBLBfVDcilOwqRzhEbocqNtljuYPqaA==', '2022-03-07 16:11:35.770', N'DENİZLİ ÇARDAK HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2351, N'376433', N'MEHMET', N'YILMAZ', N'05070442595', N'mehmet.yilmaz21d73@egm.gov.tr', N'POLİS MEMURU', N'İSTANBUL TUZLA DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEM4bYvOu9MzRKz/bZOrxpN+t3mzsfI1u9UAYcyODp5LJmbzaFsVa/mU05EnxYcAe7Q==', '2022-03-08 12:08:38.597', N'İSTANBUL TUZLA DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2354, N'237827', N'Erol ', N'Geldi', N'05055414092', N'erol.geldi@eg.gov.tr', N'Polis Memuru', N'RİZE DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEGQET6S8LEDgD70Uwor8xES4f6svkxm3a3ZnQe9DyfA2iC+4BY6hGdhrwROldtuTwg==', '2022-03-09 11:55:10.497', N'RİZE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2357, N'479450', N'BARIŞ', N'BAŞTUĞ', N'05413409135', N'baris.bastug@egm.gov.tr', N'Polis Memuru', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEFPsft5ilh7WyDq69xHHuGpQ3CqAcCVBbOqhDQMv42stPFayXNvoVnyvdhU5/PU/rA==', '2022-03-10 14:01:51.453', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2364, N'436325', N'SELÇUK', N'DENİZ', N'5353842744', N'selcuk.deniz@egm.gov.tr', N'polis memuru', N'İSTANBUL HAYDARPAŞA DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJYu2abVZAkX2YkqePGCp3wY1g3cLGJIORmjzTo/JyhPMw9l2Ttsw4ztsMTgXRx1MA==', '2022-03-15 09:13:39.647', N'İSTANBUL HAYDARPAŞA DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-07 22:43:41.087', 0, 1, 0, NULL, NULL),
            (2365, N'278512', N'MURAT', N'ÖZTÜRK', N'05055956961', N'murat.ozturk869f4@egm.gov.tr', N'Polis memuru', N'DENİZLİ ÇARDAK HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAELjh/H/nLoAUrqnLuZryfq3XxarQcJEfaKFnS3nyEk8asYidMq//CLBEBagOS1reYg==', '2022-03-15 16:24:19.090', N'DENİZLİ ÇARDAK HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2366, N'371321', N'uğur', N'korkut', N'05347770677', N'ugur.korkut@egm.gov.tr', N'Polis Memuru', N'DENİZLİ ÇARDAK HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEIHsB0dTo9PQDjPDEy+ZXarlRmTTjuMXgKqCqibB2BqltD4IoctfhfO27bBMNPCqIA==', '2022-03-16 09:02:36.283', N'DENİZLİ ÇARDAK HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2368, N'268926', N'ERCAN', N'TORLAK', N'5052535485', N'ercan.torlak@egm.gov.tr', N'polis memuru', N'İSTANBUL AMBARLI DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEAQbUxGL3/4sv63x7TqUh9y+GH/mvSzSejM6I5gn9DeAXtSJrW+umc6cGu/CQkTNbw==', '2022-03-16 10:49:44.080', N'İSTANBUL AMBARLI DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2388, N'465886', N'SELAHATTİN', N'CENGİZ', N'0551 656 36 70', N'selahattin.cengiz@egm.gov.tr', N'Pasaport Kontrol', N'ZONGULDAK EREN DENİZ LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAENSqLrvGT9fCc2eSc5Tg/xXwyJd4/e7uv0+1oFZomkb2E/1dK3tW0Bq+scdlM7kiaw==', '2022-03-31 13:51:45.217', N'ZONGULDAK EREN DENİZ LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2390, N'226153', N'GÖKHAN', N'ŞAHİN', N'05052130423', N'gokhan.sahin3@egm.gov.tr', N'polis memuru', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEAQM3xT+k2Y0GRq/rqZ8UFLlET9pocvlvJb9vDKkgU7CJi/zF3gOF8tL1ErKjiPQOg==', '2022-04-11 09:29:02.957', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2391, N'241096', N'Cuma', N'GÖGEBAKAN', N'5055427527', N'cuma.gogebakan2@egm.gov.tr', N'Polis Memuru', N'GAZİANTEP HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEMHifaUSKJs0xCxdpJyvEZ4vclAy6p2NVagaFJbdgMJzMlDdkn91DE0yloqQa7uRsw==', '2022-04-11 09:29:06.567', N'GAZİANTEP HAVA LİMANI', N'0', N'Student', '2026-04-05 03:03:34.420', 0, 1, 0, NULL, NULL),
            (2392, N'257942', N'MEHMET ', N'YAŞAR', N'0505 3465834', N'mehmet.yasar9@egm.gov.tr', N'POLİS MEMURU', N'İZMİR ALİAĞA DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEHp4+wz9QbgGY28MNNl0F+p+0JEZWp+8HsfLRMAnNW3ou8PChBUnLqHYVlAsm9qygg==', '2022-04-11 09:29:10.067', N'İZMİR ALİAĞA DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2394, N'282253', N'muhammet', N'arıcan', N'5053973556', N'muhammet.arican@egm.gov.tr', N'Pdlis Memuru', N'HATAY HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEOugc+72HsHUiuDkQfY02JhH9JOWqtsoVgSHRNgcckHIpnrXxgNCbk2oCYksMNOzTw==', '2022-04-11 09:29:17.693', N'HATAY HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2395, N'291007', N'MUSTAFA', N'KILBOZ', N'05055930395', N'mustafa.kilboz@egm.gov.tr', N'Polis Memuru', N'HATAY HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAELJ1Wt9H0GPXd9bEMTkA6eH8XV7gpcXXYVDx3mrvKk38xJFBfkQ2GZ9BRbznR+EHpQ==', '2022-04-11 09:29:20.380', N'HATAY HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2396, N'311885', N'CAN', N'YILDIZ', N'5072988900', N'can.yildiz2@egm.gov.tr', N'Polis Memuru', N'MUĞLA DALAMAN HAVA LİMANI', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEGU/WSZ3Rw0WMZ6MGVAF70Ty639P0RSF/zrBZ4got7kL5WXXEP1n2dRYw7WTA3GmkA==', '2022-04-11 09:29:23.943', N'MUĞLA DALAMAN HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2397, N'375723', N'MEHMET', N'KARAHANLI', N'5436894928', N'mehmet.karahanli@egm.gov.tr', N'Pasaport Memuru', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEBUaoxkuKiiGQPBEvaJJRtOGpDf90zlHtl8P1x67aDVSgfTXeRqP1vxBoWc+saYqDw==', '2022-04-11 09:29:28.257', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2399, N'180032', N'Tuncay ', N'KARASAKALLI', N'05336136167', N'tuncay.karasakalli@egm.gov.tr', N'Polis Memuru', N'İSKENDERUN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEIBaA9kCUVU3B6S1i3w+jyIiEk8QbWhcA9Rt5h3sf6PLvWFy5E2AUrSTs7CKOqjgUw==', '2022-04-12 12:38:45.283', N'İSKENDERUN DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2401, N'275056', N'Mehmet', N'YEMŞEN', N'05057904235', N'mehmet.yemsen@egm.gov.tr', N'Polis Memuru', N'BALIKESİR AYVALIK DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEDW+AXD4NO1ro9INdoDKABxFNajGVTFrloFxzrbttKb/21v3iUV7dV4InRpZf6jORg==', '2022-04-13 14:03:35.980', N'BALIKESİR AYVALIK DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2410, N'315595', N'emre', N'kuru', N'5063703647', N'emre.kuru4@egm.gov.tr', N'polis memuru', N'MERSİN TAŞUCU-SEKA DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJewpb6QikyjXBI6FbDJST4ccwnaB8mMHSY3XsOU2GoSQnMgNfmQkJmQQmZD9ry6lg==', '2022-04-20 13:35:29.857', N'MERSİN TAŞUCU-SEKA DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2411, N'199672', N'SEDAT', N'DOĞRAMACİ', N'05449631298', N'sedat.dogramaci@egm.gov.tr', N'polis memuru', N'TEKİRDAĞ ÇORLU HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJ9Lw3FRtin2Jv+ZawMEsJTzE8RdElWi8pwgk6QxuiN1ZLjEXxBbMJ97AG4OyBLu9A==', '2022-04-20 16:48:14.770', N'TEKİRDAĞ ÇORLU HAVA LİMANI', N'0', N'Student', '2026-04-05 23:35:41.750', 0, 1, 0, NULL, NULL),
            (2418, N'349442', N'EMİN', N'ZORBA', N'05074862878', N'emin.zorba@egm.gov.tr', N'polis memuru', N'İSTANBUL HAYDARPAŞA DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEBC6tVHFY4U+8rDCZUpwRTtDXih+gKxJR0ShN5uLdI2zmKL+vA/940bvL+0VhKVefg==', '2022-05-05 12:35:24.103', N'İSTANBUL HAYDARPAŞA DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2420, N'413234', N'DUYGU', N'DUMAN', N'0538 424 06 08', N'duygu.duman@egm.gov.tr', N'polis memuru', N'İSTANBUL KARAKÖY DENİZ BÜRO AMİRLİĞİ', N'', N'3', N'0', N'AQAAAAEAACcQAAAAENhvstl7DBD7JJVL7xaiDWDg/+WV21YZMArEiSuCoBgBwRVR2XaZe7zJiLm1b0Z6jw==', '2022-05-09 09:52:30.303', N'İSTANBUL KARAKÖY DENİZ BÜRO AMİRLİĞİ', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2423, N'303611', N'GÖKHAN', N'GÜNAYDIN', N'05543511111', N'gokhan.gunaydin@egm.gov.tr', N'Polis Memuru', N'DİYARBAKIR HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPpr4Z7ZUjtAWgSKr7V1x4UVwwmIaDsKSVDTmGOWZ3eoKhn3GmQg8usPJiKlg5l4qg==', '2022-05-11 13:29:54.323', N'DİYARBAKIR HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2424, N'208253', N'RECEP', N'KOYUN', N'505 351 58 67', N'recep.koyun@egm.gov.tr', N'POLİS MEMURU', N'GİRESUN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPMLjEBnXAre7gpzARKl8tXMCf3d/oyWFjgpcnmTmpUIpRkodGSiiToErEaz5tF5fQ==', '2022-05-11 16:44:17.910', N'GİRESUN DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2425, N'200015', N'MEHMET', N'OCAKOĞLU', N'05055407220', N'mehmet.ocakoglu2@egm.gov.tr', N'POLİS MEMURU', N'MUĞLA FETHİYE DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEBBzHb9YtVKOsSxIL+Z5Q+5q8Fxt2wnd7msd+Eh+igAk453RgU3y186StX8egDZcJw==', '2022-05-16 09:04:05.133', N'MUĞLA FETHİYE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2426, N'301272', N'Aydın', N'ŞENDİL', N'05063512640', N'aydin.sendil@egm.gov.tr', N'Polis Memuru', N'EDİRNE KAPIKULE KARA HUDUT KAPISI', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEH4tqbzg6P1biPfbQTQUgp55NVOpLDv/I+ORLcgXHshAlJvkiD3fZ3RlKHwHe8UxXA==', '2022-05-16 09:04:07.960', N'EDİRNE KAPIKULE KARA HUDUT KAPISI', N'0', N'Student', '2026-04-09 02:18:37.117', 0, 1, 0, NULL, NULL),
            (2427, N'320547', N'AHMET', N'GÜNER', N'0 555 991 45 41', N'uaguner1@gmail.com', N'polis memuru', N'TRABZON HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEBtdIIoXdsO54Z+5+et8JYwZ/y3SJXHBbpBXo9AGrB/AGHnAnZX3X6uqvG0lQG6CrA==', '2022-05-16 09:04:10.650', N'TRABZON HAVA LİMANI', N'0', N'Student', '2026-04-02 09:21:10.830', 0, 1, 0, NULL, NULL),
            (2430, N'297235', N'İNAYET', N'ÖZTÜRK', N'05065817445', N'inayet.ozturk@egm.gov.tr', N'P.M.', N'DİYARBAKIR HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEF82AbSEoxMotQgVAakBjLu8xHQP45QH9SixM8WvhzAbc4F9G099rIMCa9x2ypt9pw==', '2022-05-18 16:26:17.633', N'DİYARBAKIR HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2431, N'270298', N'hamide', N'özer', N'05055060353', N'hamide.ozer@egm.gov.tr', N'polis memuru', N'AYDIN KUŞADASI DENİZ HUDUT KAPISI', N'6c6409e6d6044c17a6505f4cf6a6189a.png', N'3', N'0', N'AQAAAAEAACcQAAAAEEYM/74aZzFbijc42tzvBmEuvXHea1unYWr/40sfwqo7xe+aczmTWHA1G6fPGqHMOA==', '2022-05-20 08:42:41.187', N'AYDIN KUŞADASI DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-08 14:03:00.900', 0, 1, 0, NULL, NULL),
            (2432, N'311611', N'İlker', N'Kalaycı', N'5072618674', N'ilker.kalayci@egm.gov.tr', N'Polis Memuru', N'TRABZON HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEK8+L2WjlocS1CpxjnkWC4mXtthltY/JvNllp2et3Fww/5fZ1bmzZx5/OHjS92lkfw==', '2022-05-20 08:42:47.173', N'TRABZON HAVA LİMANI', N'0', N'Student', '2026-04-06 08:55:03.927', 0, 1, 0, NULL, NULL),
            (2433, N'338654', N'NEBİ', N'ÇAKIR', N'05545665998', N'nebi.cakir@egm.gov.tr', N'P.M.', N'DİYARBAKIR HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEIf9X4CLt28tcexBOyTI6FMc2gbGZZsSDwl6i4oD+yPuVZHu9/IMdg9GUxUH2RVl4A==', '2022-05-20 08:42:49.547', N'DİYARBAKIR HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2435, N'152037', N'ADEM', N'EREN', N'5053879233', N'adem.eren@egm.gov.tr', N'polis memuru', N'HATAY İSKENDERUN ATAKAŞ LİMANI DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEABJyIlzj0Ew8Hfdm8avmrlOii6gGb0SGdlRrXZeZw6E3xmsr7FY54cr5fR5YW9rYg==', '2022-05-27 10:24:25.037', N'HATAY İSKENDERUN ATAKAŞ LİMANI DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2436, N'196780', N'MEHMET', N'YILMAZ', N'0532 423 15 06', N'mehmet.yilmaz82df4@egm.gov.tr', N'pol.me.', N'MUĞLA FETHİYE DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEEyAYUqCGW6EI0MVTwQOdPHOymUlT1PUCLxRL0C8L98S3sVz2dDY9nLloTa5K+zE9w==', '2022-05-27 10:24:28.553', N'MUĞLA FETHİYE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2442, N'344175', N'MEHMET TALHA', N'GÜLTEKİN', N'05300213008', N'mehmettalha.gultekin@egm.gov.tr', N'polis memuru', N'ELAZIĞ HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEHygAu3AYJin5cbaj/ZvLfDCoK9KVzLzypwHYy6XObIkK66BOy1yhrjj/DGVAswWsw==', '2022-05-27 10:24:48.257', N'ELAZIĞ HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2443, N'331535', N'ALİ', N'YAĞAN', N'05077449603', N'ali.yagan.2@egm.gov.tr', N'polis memuru', N'HATAY İSKENDERUN ATAKAŞ LİMANI DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEKV7e/Y1A840HMu0UyKY3yEvbH5J0hF/illFSZ7GvKfxsoXtNUsilLHz1IHSuIEACA==', '2022-05-27 14:59:50.577', N'HATAY İSKENDERUN ATAKAŞ LİMANI DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2445, N'357241', N'uğur', N'sarı', N'5069055078', N'ugur.sari2@egm.gov.tr', N'polis memuru', N'İSTANBUL TUZLA DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEG4WMqKYNFB5Lk9eqjAk0iGymoKVjhogea82SFCKqHUW+dKCh1oL/XXqixUiXD2T4w==', '2022-05-30 11:08:52.707', N'İSTANBUL TUZLA DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2448, N'467163', N'EMRE', N'POLAT', N'05444952164', N'emre.polat13@egm.gov.tr', N'Pasaport Kontrol', N'ZONGULDAK EREN DENİZ LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEIr+ujCo183RsC+K86ceBUt3d/I7w0kwTT0Ucw4sGG593OuZ2/oaNbRJ0LRGkqm3jw==', '2022-06-06 13:44:49.353', N'ZONGULDAK EREN DENİZ LİMANI', N'0', N'Student', '2026-04-03 19:33:46.330', 0, 1, 0, NULL, NULL),
            (2455, N'300287', N'MURAT', N'GARİP', N'05551771024', N'murat.garip@egm.gov.tr', N'pols memuru', N'BALIKESİR KOCA SEYİT HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEDWiART3ta/ceLdXb1wDq2CLxPGnSJuwBtjqJBb8VQwFE4CcUum5HIXVQ+DoxQMcSQ==', '2022-06-22 13:51:12.067', N'BALIKESİR KOCA SEYİT HAVA LİMANI', N'0', N'Student', '2026-04-06 08:33:01.453', 0, 1, 0, NULL, NULL),
            (2457, N'196764', N'MUSTAFA', N'EKBİÇ', N'5052166931', N'mustafa.ekbic@egm.gov.tr', N'POLİS MEMURU', N'MUĞLA DALAMAN HAVA LİMANI', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEOGzgsQbzrKujA5iMnEpnUr4XsjkmgjPJ7Nr5ENTLRxNZtAogvNdzMG6z26CDLPQfQ==', '2022-06-24 11:47:51.010', N'MUĞLA DALAMAN HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2459, N'167549', N'ÖMER GÖKHAN', N'KOZZAK', N'5055464911', N'omergokhan.kozzak@egm.gov.tr', N'POLİS MEMURU', N'HATAY İSDEMİR DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEKiMXfQo7MwVRSDl77udc5dUDis+Wf4SBzocxxnmrL9Niv0wqrSVQXAFJGhe5W3/gQ==', '2022-06-29 09:45:23.647', N'HATAY İSDEMİR DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2463, N'205446', N'ERCAN', N'KARAKIRIK', N'5057799005', N'ercan.karakirik@egem.gov.tr', N'Polis Memuru', N'BARTIN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAENKc9Z2kw4bMH7iVRH4YHe4HSNf+MljfFXogmuCcwUvm6AA4KKcA69ZpS4P4Vo/ayA==', '2022-07-07 15:20:24.270', N'BARTIN DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-02 11:25:00.587', 0, 1, 0, NULL, NULL),
            (2465, N'420647', N'ersin', N'tanrıver', N'05528237125', N'ersin.tanriver@egm.gov.tr', N'polis memuru', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEOGqm2gWbaK5vCVlb7C23Sw6/4I2r5R/3FdZ4t1i9I9VA6t4yyBx8CHqU8I3a6Q6eQ==', '2022-07-21 11:18:01.137', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2471, N'311529', N'Mesut', N'Kutlu', N'05067721735', N'mesut.kutlu@egm.gov.tr', N'Polis Memuru', N'KÜTAHYA ZAFER HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEIQoJCCLuzY1B/ein1lSK/pa8oZ35ANOhsUCa2o1C/VAwWUVvPGp3Yl9eTmPLpt55A==', '2022-07-25 16:31:10.227', N'KÜTAHYA ZAFER HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2477, N'422205', N'EMRAH', N'TOPRAK', N'05448240245', N'emrah.toprak3@egm.gov.tr', N'polis memuru', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'', N'3,4', N'1', N'AQAAAAEAACcQAAAAEEY03zu+2C1N4Ss0drP/Y04rwWh6gRbfpXYGJixBqGFSdj1Ye9GZuV6+gdalLvsOFw==', '2022-07-25 16:37:24.010', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2479, N'443990', N'CİHAN', N'ATEŞ', N'5522819052', N'cihan.ates4@egm.gov.tr', N'polis memuru', N'EDİRNE İPSALA KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEGlKl0ykyk+QRBdnSrjdrvD8CCDNCSNE5UcxvrQAqolBf8tMMjkZQpYAiv/0DWmXsQ==', '2022-07-25 16:38:52.093', N'EDİRNE İPSALA KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2482, N'271535', N'HALİL İBRAHİM', N'SARI', N'5075809577', N'hisari@egm.gov.tr', N'Polis Memuru', N'ADANA BOTAŞ DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEMCpNwR0ZsDdOW/WO9Vj+TdOzjTmjkyat1nFTWU5wyoZm8AFrij6lhdUKvx4GOYDLA==', '2022-07-27 09:47:14.213', N'ADANA BOTAŞ DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2493, N'388798', N'Serkan', N'PALTACI', N'5332946349', N'serkan.paltaci@egm.gov.tr', N'Polis memuru', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEAVdcIPwHuoMNQSk6jz+0/l7PjuI7s/2h6Fs4+i9YQw/9b1R/1iZjOF56AwGtyvn2w==', '2022-08-04 15:11:45.313', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2494, N'274747', N'ERDİ', N'ONAY', N'05058188846', N'erdi.onay@egm.gov.tr', N'Polis Memuru', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEL9ABQeA8PPKICu5aiQfNiXAWx1m3XVOIZqxTE5Uk7zQ3Um4wEPhy1brHpZqQJMN3A==', '2022-08-05 13:42:05.380', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2502, N'473007', N'EMRAH', N'YALÇIN', N'536 723 59 59', N'emrah.yalcin5@egm.gov.tr', N'Polis Memuru', N'ANTALYA FİNİKE DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJ6Mg1tMjcWJ2f8xf5gwtdaf1M2G9OGVAPGaKEGqoBD5rL/ow/gQPEvGIKjc8hlTwQ==', '2022-08-15 10:23:41.250', N'ANTALYA FİNİKE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2503, N'476413', N'davut', N'uygur', N'05530073837', N'davut.uygur@egm.gov.tr', N'polis memuru', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAED1DAfp7tTNh2oUimqgGorg3XAAOrQ+lMcL0RqzHvQw5t3RE2woAWap181NH6/cy5A==', '2022-08-18 09:37:30.250', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2504, N'385360', N'FATİH', N'ZENGİN', N'05334512155', N'fatih.zengin3@egm.gov.tr', N'Polis Memuru', N'AĞRI GÜRBULAK KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJVV6TP9kEGKoZAh6iXl94NwNXyBwNbg95zCLJVv+cSfXW3dhxDBc7JmIkFuu127WA==', '2022-08-19 11:44:27.747', N'AĞRI GÜRBULAK KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2506, N'248641', N'emrah', N'yaba', N'505 546 93 39', N'emrah.yaba@egm.gov.tr', N'polis memuru', N'MUĞLA FETHİYE DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEKDO3Gmt+96UhQRL01oagZj9h5Q3Z6MvBukON1A/IMyhwsy7QYh158PoEChl+pARuw==', '2022-08-21 12:40:35.057', N'MUĞLA FETHİYE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2508, N'306734', N'Burak', N'GÜNECE', N'05059106117', N'burak.gunece@egm.gov.tr', N'polis memuru', N'MERSİN TAŞUCU-SEKA DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPoazh1Gw5Ap/KLrbsjnx1BBE9AywiiiTEFebDuV1hBvei6uqfFM+ZUAIipZ6cn6Xw==', '2022-08-23 11:40:16.527', N'MERSİN TAŞUCU-SEKA DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2511, N'427418', N'süleyman', N'hayta', N'05432957745', N'suleyman.hayta@egm.gov.tr', N'Polis Memuru', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEH5WCx6wFgv3+RDdwVPQcMjAQxqhBr97X7geFOrnVSQjPpII+IH1/ySJSy2POs/PbA==', '2022-08-24 11:07:16.383', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2513, N'477637', N'SELİN', N'ZORBAZ', N'5539395650', N'selin.zorbaz@egm.gov.tr', N'Polis Memuru', N'BÜRO MEMURU', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEPfxsfSIqtWcq9TYHXSWJEx4IWAuLgoWAK3ixZMwlciL9QWi3g/GY7X0dpgahScD+A==', '2022-08-24 15:37:29.783', N'MUĞLA FETHİYE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2514, N'364317', N'Tuğba', N'ÖKSÜZ', N'05545893837', N'tugba.oksuz@egm.gov.tr', N'Polis Memuru', N'Pasaport Büro', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEO+h03LpnNBjOVeq/nrLbplvPUCc8yE2yRZ2jO7cst1A3Y1O0FR8XoeLi4IXBxqbnw==', '2022-08-25 09:54:55.390', N'MUĞLA FETHİYE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2517, N'428252', N'FATİH', N'KARASU', N'05531677474', N'fatih.karasu3@egm.gov.tr', N'POLİS MEMURU', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEC0r+dSRg9mgTaejdvhdkC6QEtKxjRNZ5irMEuwgozRkidOcghR3a6Qo2qQfBBKhSg==', '2022-08-26 12:43:23.853', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2520, N'289024', N'COŞKUN', N'ÇAKIR', N'05058406878', N'COSKUN.CAKIR@egm.gov.tr', N'Polis Memuru', N'MUĞLA FETHİYE DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEIM7xo5MR+mxNzXSaNErtbsGqSkC4tsdmlJK/apavPr2nADi5I8JjYiVgUlaAZX3yg==', '2022-08-31 09:12:38.547', N'MUĞLA FETHİYE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2537, N'358352', N'AHMET', N'YILMAZ', N'5079261615', N'ahmet.yilmaz2ce7c@egm.gov.tr', N'polis memuru', N'ERZURUM HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJhtbCHvydywe9gnvog+SuR+unPq63clYdpjIT5MatrCqYSVxJnv+Ty0SjijamAAbQ==', '2022-09-20 17:03:14.057', N'ERZURUM HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2539, N'310002', N'ÖMER ', N'SARI', N'05055372926', N'omer.sari4@egm.gov.tr', N'polis memuru', N'SAMSUN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEIrMql6E3blbrc5PgBfDmdlgyDK+ljCSvPiaV0Dz4AN0gB/s+K9nlRy0m9gv8pyD9Q==', '2022-09-21 14:59:09.943', N'SAMSUN DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2541, N'387654', N'HARUN', N'KAZAN', N'05363921389', N'harun.kazan@egm.gov.tr', N'Polis Memuru', N'EDİRNE HAMZABEYLİ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEGvICwCYygSXLxgoZT8BuHP6jKGoo9feRFbt5gvF/rSVhtzRHlOIrlaIxNCbJUsx1Q==', '2022-09-22 14:36:02.627', N'EDİRNE HAMZABEYLİ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2545, N'303736', N'ALİ KEMAL', N'BOZOĞLU', N'5059254968', N'alikemal.bozoglu@egm.gov.tr', N'polis memuru', N'GAZİANTEP HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEH9URH1ELl87uybY47XvtromBzDlP2zJIQ6J0jzOTEibyvwLTw81XQd+20+84cEBGw==', '2022-09-27 16:16:00.867', N'GAZİANTEP HAVA LİMANI', N'0', N'Student', '2026-04-02 15:18:17.387', 0, 1, 0, NULL, NULL),
            (2547, N'409405', N'OKAN', N'OĞUZHAN', N'05522012103', N'okan.oguzhan@egm.gov.tr', N'POLİS MEMURU', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEITdcuC/lWD2pkFx59njzPSUc9jPQ7N3+2pgqZvTYC2vQ1IL8BUf1Ra0ai06Zy+2zA==', '2022-10-03 10:01:56.020', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2555, N'280413', N'Fatih', N'Sarıtaş', N'5054934670', N'fatih.saritas@egm.gov.tr', N'Polis Memuru', N'MUĞLA DALAMAN HAVA LİMANI', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEDYK3n30vjE7ytCoYViLgw59zGGbaT4pVcPZnkYrb1WrdRiX81pN0Y2CcdZtczO7jA==', '2022-10-18 15:25:51.977', N'MUĞLA DALAMAN HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2556, N'428428', N'SALİH OZAN', N'KUTLU', N'05436527452', N'salihozan.kutlu@egm.gov.tr', N'Polis Memuru', N'İSTANBUL KARAKÖY DENİZ BÜRO AMİRLİĞİ', N'', N'3', N'0', N'AQAAAAEAACcQAAAAELMj8IBqrLHSTqh9BYhnJxSU/2/iK6k1oMNOuMwcGrObIekXskp+s4SDvM1LMe0/zA==', '2022-10-18 16:05:36.960', N'İSTANBUL KARAKÖY DENİZ BÜRO AMİRLİĞİ', N'0', N'Student', '2026-03-31 11:39:25.800', 0, 1, 0, NULL, NULL),
            (2558, N'376778', N'YAVUZ', N'ELEVLİ', N'5070930961', N'yavuz.elevli@egm.gov.tr', N'polis memuru', N'SAMSUN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEGzWdObo97QNkcleEDWfc6GuFp6aYCZ1tDoqhvo7vOOeDgj1Y3wCN3y0QyFcewFxvg==', '2022-10-21 10:01:05.660', N'SAMSUN DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2560, N'418879', N'AYBERK', N'SONGÜR', N'05069202464', N'ayberk.songur@egm.gov.tr', N'Polis Memuru', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEDpCWdWtF1WyJKV+McZJISgnSSrWs/rHfQ2qMHyYmy35fIB9x0ThcI0/l9aTeftRBg==', '2022-10-24 09:15:27.073', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2561, N'238905', N'Ümit', N'Özdoğan', N'05055495623', N'talha_2534@hotmail.com', N'polis memuru', N'SAKARYA KARASU DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPYqjtdR8+mDp+/tti+9s602J13B2u0xANDZHLGU3BJKVhidKMv+lMoPdRtexeGY6A==', '2022-11-02 13:42:00.917', N'SAKARYA KARASU DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2564, N'427793', N'Yunus', N'BULUT', N'5421335813', N'yunusbulut.5@egm.gov.tr', N'polis memuru', N'AĞRI GÜRBULAK KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEMDwZVNVtZecRz44Gi+gA2e7hrSyYW9lnF1e5/f9NdUjdP+SyVAQ3S88Zy1nOfwg5g==', '2022-11-03 09:10:06.163', N'AĞRI GÜRBULAK KARA HUDUT KAPISI', N'0', N'Student', '2026-04-04 19:06:29.357', 0, 1, 0, NULL, NULL),
            (2567, N'232427', N'NECATİ', N'YILDIZ', N'05052710888', N'necati.yildiz2@egm.gov.tr', N'polis memuru', N'İSKENDERUN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJgeSR92NE4AejL1rpm10q1FfDJUaNQkPzVihZCsW5BsHs6jWFcSel2llZpCQ+vjJQ==', '2022-11-09 09:25:39.983', N'HATAY İSKENDERUN ASSAN DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-01 16:26:50.917', 0, 1, 0, NULL, NULL),
            (2568, N'340970', N'MUSTAFA', N'KALYON', N'05076632781', N'mustafa.kalyon@egm.gov.tr', N'Polis Memuru', N'SAKARYA KARASU DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEBppgf7xgZ3pBsylvbIwAHctmlLokWHadtrw8JRGvExpC6c/SRp/AB7Nwld44z/Bew==', '2022-11-09 09:25:43.813', N'SAKARYA KARASU DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2569, N'380731', N'MEHMET SERTAN', N'CAN', N'05078644981', N'mehmetsertan.can@egm.gov.tr', N'Polis Memeru', N'SAKARYA KARASU DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEI4zrMRQ6Ok4O4D3MlrvkPFflIPUmnMuImz+tMCGvpxMvREzhB+34Z4ADsoAwjbvUg==', '2022-11-09 09:25:47.110', N'SAKARYA KARASU DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2570, N'142278', N'MURAT', N'TURCAN', N'05055272215', N'murat.turcan@egm.gov.tr', N'polis memuru', N'BURSA GEMLİK DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEFtOIBwj5/Ju+kTppPjSpfrMHF7uf6MIzW9CqKoQTZJ57yNCO760RNXvJJ+GwfS3yA==', '2022-11-16 14:12:19.317', N'BURSA GEMLİK DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2571, N'501135', N'mert batuhan ', N'çalışkan ', N'05523323155', N'mertbatuhan.caliskan@egm.gov.tr', N'polis memuru', N'SAKARYA KARASU DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEKhYWfE5iBD22v9oRcECYUfMfF8gSPBwNJnnS2GEecxprMrcfvki47mXDzmqwOgkMQ==', '2022-11-16 14:12:22.753', N'SAKARYA KARASU DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-09 07:38:49.377', 0, 1, 0, NULL, NULL),
            (2573, N'369797', N'HATEM', N'TOPCU', N'05355746920', N'hatem.topcu@egm.gov.tr', N'Polis Memuru', N'HAKKARİ ÜZÜMLÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEBcfYO+OMp3OGGAKDYJ14SgX+BmYfXAOsgxgpaU+MscJXv99/hlYvOHEZ6q0CUG/ng==', '2022-11-29 10:43:06.407', N'HAKKARİ ÜZÜMLÜ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2574, N'253405', N'HASAN', N'AYYILDIZ', N'5306602675', N'hasan.ayyildiz2@egm.gov.tr', N'polis memuru', N'KONYA HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEDnfe6Wx3PBkSJ6TeVGgXbNUtZVKTvW25LPu+7Cw4i7k3PTOxvaV9UBgQTHWnzbQvg==', '2022-11-30 15:25:24.927', N'KONYA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2576, N'429572', N'Ahmet', N'KARAKAŞ', N'5365560094', N'Ahmet.karakas7@egm.gov.tr', N'polis memuru', N'BALIKESİR AYVALIK DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPIG1hEFjua8Dgr90+3m5/vPtgdMU/In/G16EqwkoSw52URAbnSrJPB2yLkhaVam3g==', '2022-12-06 10:48:34.977', N'BALIKESİR AYVALIK DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2578, N'389325', N'OĞUZHAN', N'GEÇGEL', N'5458196515', N'oguzhan.gecgel@egm.gov.tr', N'POLİS MEMURU', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJh6d2d1UjBaCteNY8I5iZahiIVfofUHQJfzsbtkL/UMEBNwEayTdqiJwFsx1ciDTQ==', '2022-12-06 13:49:35.770', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2579, N'215749', N'CENGİZ ', N'UNUK', N'05054777335', N'cengiz.unuk@egm.gov.tr', N'Polis Memuru', N'İZMİR (EM -5)  DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEKd0J0Hm5CmiOw/zWoq0BNo1ocJU4KQvlKGPz3RjAbpSJSQ8/0P9ZM6L5bo1enJsyA==', '2022-12-09 10:06:17.790', N'İZMİR (EM -5)  DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2581, N'396655', N'halil', N'demirkol', N'05549087970', N'demirkol193@gmail.com', N'polis memuru', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEBTWQwKlnmUK33CIZgqPqoi42RMt8krzd+iH7xLl6OFtvhgC6F/pLKzi/s+ZOwzzdA==', '2022-12-09 10:06:59.463', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2584, N'273842', N'BAHA', N'BİRSEN', N'505780005', N'baha.birsen@egm.gov.tr', N'POLİS MEMURU', N'GAZİANTEP KARKAMIŞ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEA4OPmXSz41j4SQEon5upzHpbevIuiPCMUeSkX0qHvN+D+yPqRZL7jUuYZcyUyOmHA==', '2022-12-13 09:43:09.850', N'GAZİANTEP KARKAMIŞ KARA HUDUT KAPISI', N'0', N'Student', '2026-04-04 18:44:21.933', 0, 1, 0, NULL, NULL),
            (2585, N'188423', N'Muhsin ', N'HOTANOĞLU', N'0505 485 38 14', N'muhsin.hotanoglu@egm.gov.tr', N'Polis Memuru', N'BALIKESİR AYVALIK DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEE79BWEm3EQxRJPt7Hh0G/D7tKX0HJeXIZkrG0flf5zZ2CkPfMv9QjT1mB4E4Bq9xg==', '2022-12-14 09:25:35.657', N'BALIKESİR AYVALIK DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2587, N'308361', N'AKİF', N'ÇOLAK', N'05063968712', N'akif.colak@egm.gov.tr', N'POLİS MEMURU', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEHu2uzjqFPl8ezS+btIpTcH2dcp/rHcOEZfN+0S272toQOVKi1QRoU0KT503n8ag4w==', '2022-12-21 12:09:14.680', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2588, N'345764', N'rıdvan', N'koçu', N'5079227862', N'ridvan.kocu@egm.gov.tr', N'polis memuru', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEH3iUEwLcJ/9uqv97cYAWefS99WCrvc9u49O0EmTZpwZW2GlrZ4mvN6W2wL3fx1GJw==', '2022-12-26 10:49:54.337', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2592, N'495773', N'Muharrem', N'ERSÜREN', N'546 200 5779', N'muharremersuren22@gmail.com', N'Polis Memuru', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEHszXvj6qjEqllhXoKHewMNk5JG2Y8Vjz1xDdRqM0itdiaIsM3Md4g0zB4KgRrtAsQ==', '2023-01-05 12:03:49.013', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2593, N'381108', N'Ahmet Turan', N'AKKOÇ', N'05521653418', N'ahmetturan.akkoc@egm.gov.tr', N'Polis Memuru', N'İSTANBUL ZEYTİNBURNU DENİZ HUDUT KAPISI', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEJc6hclwQARkMix5RqU2pM9N+VcBMz1EACiFxbIxtJcqyNZPc5+LCpw1lT/TXgyEOg==', '2023-01-06 11:09:29.947', N'İSTANBUL ZEYTİNBURNU DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2595, N'158801', N'MEHMET', N'AKDAĞ', N'05052271345', N'mehmet.akdag@egm.gov.tr', N'Polis Memuru', N'HATAY İSKENDERUN YAZICI DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAECw9C0T/kHStjowtart5DaFaATzw0T76btJMPB1EYkjyg8nd1g8Msi9rtbe4dZ6QUw==', '2023-01-10 16:53:00.567', N'HATAY İSKENDERUN YAZICI DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-01 13:54:51.040', 0, 1, 0, NULL, NULL),
            (2598, N'248640', N'EMRAH', N'YABA', N'0 505 546 9339', N'emrahyaba@hotmail.com', N'polis memuru', N'MUĞLA FETHİYE DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEE1nL3T6u2vOYNU5YqRIHfzAUnj/LGc8I3SThlr1/4fE2JTGqvtvJOE1v1vqNKjA0g==', '2023-01-16 09:48:24.163', N'MUĞLA FETHİYE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2611, N'353626', N'SEMİH', N'TANRIKULU', N'5074918339', N'semih.tanrikulu@egm.gov.tr', N'Polis Memuru', N'İSTANBUL ZEYTİNBURNU DENİZ HUDUT KAPISI', N'8179b80b12ae40bfbc4427951cd21346.png', N'3', N'0', N'AQAAAAEAACcQAAAAEJVXkTo6sSPNk0Truti/N5aoF4MGzeA4rnab4ojgEYFK9ok81safemOKw7MJpZ4spQ==', '2023-02-09 09:13:09.063', N'İSTANBUL ZEYTİNBURNU DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-02 00:56:05.847', 0, 1, 0, NULL, NULL),
            (2614, N'296657', N'mehmet', N'demircioğlu', N'5065812820', N'mehmet.demircioglu2@egm.gov.tr', N'polis memuru', N'MUĞLA FETHİYE DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAELO5EFc9gsP6vgjo8XCIpAmnc2kjIlvSUuz1tAbCDo46SBAsoqCfAmPTHyhZCbET8Q==', '2023-02-16 14:26:42.023', N'MUĞLA FETHİYE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2615, N'173133', N'ÖZKAN', N'KOÇAK', N'05326521338', N'ozkan.kocak@egm.gov.tr', N'Polis Memuru', N'BARTIN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEItUfuB+ic2Ki0404UMqGCMULZe+aDZfpvhULqGdouE4/r+dgbGxZKMQpehgsFWimg==', '2023-02-23 09:26:25.170', N'BARTIN DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2618, N'428435', N'TURGUT', N'AÇIKGÖZ', N'05545530110', N'turgut_261@outlook.com', N'Polis Memuru', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEHWmMGhoyt6x9GQQgQ/+Ge/dsW5/xsFOz5j/kPZhiA4bDf3LjYnYvtFzmMDFyD/sbg==', '2023-02-27 09:57:24.227', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'0', N'Student', '2026-04-08 19:43:26.363', 0, 1, 0, NULL, NULL),
            (2619, N'469827', N'SÜMEYYE', N'YILDIZ', N'5061552095', N'sumeyye.yildiz@egm.gov.tr', N'Polis Memuru', N'İSTANBUL ZEYTİNBURNU DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEOgRYpYh2z6ZmDQrp2KZItsYFaqF7fvWkJs8Zj94SngwnTJX3ncK4VhwDl4q8hNONw==', '2023-03-07 09:16:51.200', N'İSTANBUL ZEYTİNBURNU DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-09 11:15:31.367', 0, 1, 0, NULL, NULL),
            (2621, N'304709', N'EMRAH', N'YENİAY', N'05072396160', N'emrah.yeniay@egm.gov.tr', N'polis memuru', N'BALIKESİR BANDIRMA ASKERİ HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEBHQSTsVbC8g0pohwPUEGbvPciN74k7CSHk3WWb0IxMCLXsGC3eKpbBGMeQUJZjZsg==', '2023-03-13 09:19:32.387', N'BALIKESİR BANDIRMA ASKERİ HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2622, N'311929', N'süleyman', N'şahan', N'05066619498', N'suleyman.sahan3@egm.gov.tr', N'polis memuru', N'ELAZIĞ HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAENPaYOFnLdIhZEuqtqm+1pHRH/Ugq40mg/OYbhM3ffhXze+uIVhPIu6gXb7mraIJRA==', '2023-03-13 09:19:35.293', N'ELAZIĞ HAVA LİMANI', N'0', N'Student', '2026-04-05 03:24:37.960', 0, 1, 0, NULL, NULL),
            (2625, N'304605', N'Sinan', N'TOZKOPARAN', N'5068486968', N'sinan_5207@hotmail.com', N'polis memuru', N'ADANA ŞAKİRPAŞA HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAENkqHndElqfhLbCBAIgpD70rloH96CrdsexLQES1i2V98B+i9UN+93eU0hzUSKmVWg==', '2023-06-20 16:42:07.453', N'ADANA ŞAKİRPAŞA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2626, N'496448', N'Yasin', N'ODABAŞI', N'555', N'wasd@gmail.com', N'Polis Memuru', N'EDİRNE KAPIKULE KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAENLZXRhkgkNZ4yircGf5hZUr5wGDRGXDZoXBa2TSwY1sN5hrK23cGu/2agANfZX0Sg==', '2023-06-22 19:31:10.233', N'EDİRNE KAPIKULE KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2627, N'448052', N'EMRE', N'KIZAY', N'05522971993', N'emre.kizay@egm.gov.tr', N'Polis Memuru', N'HATAY İSKENDERUN DENİZ LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAELx+w3/UtI6gYdSR9HTpjFRuQfFdB/MaMqBUN3AGR7hLzkFponswvhMvdg4ujU6Uvg==', '2023-06-22 19:31:49.827', N'İSKENDERUN DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-01 13:56:34.583', 0, 1, 0, NULL, NULL),
            (2632, N'315747', N'ahmet', N'soytaş', N'5062822758', N'ahmet.soytas@egm.gov.tr', N'polis memuru', N'KAYSERİ HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEDs/7XvCj3h0whQNFA0ZOi7jLGpXkb4gDudUtTAZrploa+gGcL8r3xvRG/ncgOA+wQ==', '2023-06-30 20:06:47.967', N'KAYSERİ HAVA LİMANI', N'0', N'Student', '2026-04-08 01:43:27.393', 0, 1, 0, NULL, NULL),
            (2633, N'329115', N'ömer', N'göçer', N'05534502903', N'my_lovee_33@hotmail.com', N'Polis Memuru', N'ANTALYA GAZİPAŞA HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEP8UHacVOpgdHfMlBIeY8GkW6CMe9E5LiOGg7DOeCvJo95izbHpbrFXTOeAFzO9RFA==', '2023-06-30 20:09:33.773', N'ANTALYA GAZİPAŞA HAVA LİMANI', N'0', N'Student', '2026-04-01 01:59:35.387', 0, 1, 0, NULL, NULL),
            (2634, N'234564', N'NEZİR', N'KAN', N'05535989893', N'nezir.kan@egm.gov.tr', N'Polis Memuru', N'KAYSERİ HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEN8lWMnOF3gbTQ2tHuRDrbX/PlXoj5G1L6zB7jy5n6x83C6doFR3ZEwn11ZeSOtf+g==', '2023-07-03 15:34:22.367', N'KAYSERİ HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2635, N'212223', N'ÇETİN ', N'ŞENOL', N'05053497481', N'cetin.senol@egm.gov.tr', N'polis memuru', N'KOCAELİ DERİNCE DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAED+pV/rv3krqvXqfS866qivy6m8bwizPv6Tl/Y9iU9MyKm+s95b3WLfBh/UOs8onqw==', '2023-07-05 15:52:10.117', N'KOCAELİ DERİNCE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2642, N'451934', N'sinan', N'devecioğlu', N'05376034527', N'sinan.devecioglu06@egm.gov.tr', N'polis memuru', N'HAKKARİ DERECİK SINIR KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEEnvQmYrI+RxLJIefv6ruxHq5nedABNZzcnHDLD0NBJeoZ7EeQDCPoHQ5XiyIM6YBg==', '2023-07-18 16:03:00.020', N'HAKKARİ DERECİK SINIR KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2643, N'437072', N'ERAY', N'KOMLICA', N'5073104900', N'eray.komlica@egm.gov.tr', N'polis memuru', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEA5Aie0kKpT7OBZza0vtoU4/yngX4XoyEcFj/PMMl81V0GOjiQu3vPaVPqwg9EawFg==', '2023-07-19 15:08:11.190', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2645, N'422202', N'Hakan ', N'AYAZ', N'05416268631', N'hakan.ayaz4@egm.gov.tr', N'Polis Memuru', N'EDİRNE KAPIKULE KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEI7hkeDk2KGKtWU0Kf0IPoTTazxyTllexVAwvm3sJPf0SNGIxnRd4w/BzFtp2FDicQ==', '2023-07-24 10:32:50.910', N'EDİRNE KAPIKULE KARA HUDUT KAPISI', N'0', N'Student', '2026-04-08 06:33:19.950', 0, 1, 0, NULL, NULL),
            (2646, N'230009', N'mavlüt', N'limon', N'05052109811', N'mevlut.limon@egm.gov.tr', N'polis memuru', N'ISPARTA SÜLEYMAN DEMİREL HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEF5013Bu1o191QMOr92pfSyvPQIdj698O6hKiuQabl0kBNXQKbSgwEzJdlJKATiZMQ==', '2023-07-28 10:40:16.357', N'ISPARTA SÜLEYMAN DEMİREL HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2649, N'445667', N'SELÇUK', N'DİNKE', N'05345511242', N'selcuk.dinke@egm.gov.tr', N'POLİS MEMURU', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEAnqhRH95yGR8Y1JBco3uCS5gTpqUo18OQ3u3r17PrnvtTEnuU5sk32YV5LiBwQC+Q==', '2023-08-04 18:11:00.133', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2650, N'285898', N'BARIŞ', N'KOYLU', N'05058660919', N'baris.koylu@egm.gov.tr', N'Polis Memuru', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEMjckiNqkNJt2I89H8C7oGLGV0tUg6S/zERnElGbfuRzod7jUiEV7rzii4xGcLKXWg==', '2023-08-06 19:13:44.657', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2652, N'327943', N'mehmet said', N'kara', N'05541142110', N'ksaid2882@gmail.com', N'polis memuru', N'ADANA ŞAKİRPAŞA HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEMW7zj5KJGMS9Xwod1M1nIJUpy++heAk6vIvCdRQ+GmDmmOGLb6uBM1Ux+BPu8wasQ==', '2023-08-08 09:17:29.003', N'ADANA ŞAKİRPAŞA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2654, N'424141', N'İSKENDER', N'RECEP', N'5310829079', N'iskender.recep@egm.gov.tr', N'Polis Memuru', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEP5+USXk16avbEymVal15v2OvbNx1R3MyaUB1VL/AcigJt1CscQmjpkERmOdjM3YNg==', '2023-08-10 11:09:47.783', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'0', N'Student', '2026-04-02 15:40:29.897', 0, 1, 0, NULL, NULL),
            (2659, N'397097', N'ALİ ', N'OLGUN', N'05531370022', N'ali.olgun3@egm.gov.tr', N'POLİS MEMURU', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEI+583LqUkfSyXWtFs9Z6PSLk+nNE6bskwl1F11ymN4svbPy2l9Ip79J647ZTxGK+A==', '2023-08-21 10:28:25.390', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', '2026-04-08 16:38:29.337', 0, 1, 0, NULL, NULL),
            (2662, N'490036', N'ŞÜKRÜ OĞULCAN', N'AVARA', N'0 552 365 69 89', N'sukruogulcan.avara@egm.gov.tr', N'Polis Memuru', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEDTVSMtO42CDY1DTav76DxKkwOcCpBwLakU41gOAVleZBsuhvoEdoyX8MwUb5q1n5g==', '2023-08-31 10:33:45.963', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2663, N'197624', N'MEHMET', N'KALKAN', N'0 505 808 43 95', N'mehmet.kalkan4@egm.gov.tr', N'Polis Memuru', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEFkvUhbIMOol5t+Qdq/fSbR90rxYa3Umy9RDeJzTGS3cJVJJvFSTRIvqZ1ZqK3OkfQ==', '2023-08-31 15:35:45.070', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2667, N'322636', N'OSMAN HİLMİ', N'BUDAK', N'05079918444', N'osmanhilmi.budak@egm.gov.tr', N'Polis Memuru', N'DENİZLİ ÇARDAK HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEG9w6IK+9H7bqb0D6lRzWVlZnX/aeX+lmUiPjCI8U0RoZApk5Zsar5ZlNH0h/y/Klw==', '2023-09-07 19:11:42.187', N'DENİZLİ ÇARDAK HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2668, N'419412', N'HÜSEYİN', N'UĞURLU', N'05418655535', N'huseyin.ugurlu4@egm.gov.tr', N'POLİS MEMURU', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAED2KkBY3H2BbZvhMKCXcvdkTwT46ZlqysJ9bv3XVCvmsbzz7PE+IWr3sJZm5e0y0Hg==', '2023-09-07 19:11:47.780', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'0', N'Student', '2026-04-09 08:40:15.360', 0, 1, 0, NULL, NULL),
            (2670, N'443798', N'resul', N'kılıç', N'5078119733', N'resul.kilic7@egm.gov.tr', N'POLİS MEMURU', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEHnOLk0buB6Y0dMQ01xlxDZwxBo1/DaHQtKZfrdjIEhhgAXrzrq4gyu5ZwTxO3BoaA==', '2023-09-07 19:12:15.157', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2671, N'469678', N'ARİF', N'TEKİN', N'05541691757', N'arif.tekin6@egm.gov.tr', N'Polis Memuru', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEIrgd3WvVCwSv6R12+D/5Y7HWcn2F9mNnJIUQIP0O8kMPjQNFdVE9hjBeEV4wmf/XA==', '2023-09-09 19:07:35.713', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'0', N'Student', '2026-04-08 22:59:43.000', 0, 1, 0, NULL, NULL),
            (2673, N'437792', N'GÖKHAN', N'ŞAHİN', N'05412025613', N'gokhan.sahin18@egm.gov.tr', N'polis memuru', N'HAKKARİ DERECİK SINIR KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPVxQXNhNGfFvN/9rxdWjfTw841QFIN3nowqwpZDFD8mO5uOZfddi8klGpryKTyyDw==', '2023-09-11 19:09:29.457', N'HAKKARİ DERECİK SINIR KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2676, N'360130', N'KÜRŞAD', N'YÜCETÜRK', N'05534714346', N'kursad.yuceturk@egm.gov.tr', N'polis memuru', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEKu4GCB4GfelROAy/YnfxDfRD7qZad4lpnxmBBIUdcWHzS8ufqqkW1VkwZs/KmmITA==', '2023-09-13 10:48:00.880', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2677, N'852313', N'Neşet', N'Deneme', N'05535351560', N'nasit.dayan@egm.gov.tr', N'Polis Memuru', N'Pasaport', N'', N'3', N'0', N'AQAAAAEAACcQAAAAECTTIydZd/WQsg3k/A38jqvFAap/OvEGW8wrVrBcIWp4FTI2cZYyoH+RrO3ydrCIqg==', '2023-09-15 09:49:33.757', N'ANTALYA HAVA LİMANI', N'1', N'Student', '2026-07-12 17:49:52.653', 0, 1, 1, N'0', '2026-07-12 13:16:48.887'),
            (2678, N'443006', N'FATİH DOGUKAN', N'KIR', N'05349155669', N'fatihdogukan.kir@egm.com.tr', N'polis memuru', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEHO/YTQlaCzJhKRzjDwfpT5WooiPv+M5asx0rvpTTbUbMLylEs56+JMYKAxK0r0ZWw==', '2023-09-18 16:03:37.457', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', '2026-03-30 18:59:47.413', 0, 1, 0, NULL, NULL),
            (2680, N'319142', N'FATİH', N'UZUN', N'05444491742', N'fatih.uzun5@egm.gov.tr', N'Grup Amir V.', N'SAMSUN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEIev96jBqVuEZCrlpvCnNI96+V2PO7FLhjQ66uHZxZ04TClVXO3GuqT2ZnxVDlDi4w==', '2023-09-19 14:42:50.537', N'SAMSUN DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2681, N'312154', N'MUSTAFA', N'TATLILIOĞLU', N'05067525519', N'mustafatatlilioglu@egm.gov.tr', N'polis memuru', N'SAMSUN ÇARŞAMBA HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPc+r8wId9tvZUDR3sSlR41Ay/fR3umlaHaj86G/dej5seYBRsTAlnkNdqnGYlpSpg==', '2023-09-24 20:42:39.187', N'SAMSUN ÇARŞAMBA HAVA LİMANI', N'0', N'Student', '2026-04-09 01:26:20.717', 0, 1, 0, NULL, NULL),
            (2682, N'466037', N'OKAN', N'TANDOĞAN', N'05367480144', N'okan.tandogan@egm.gov.tr', N'polis memuru', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAELt1F8pkeB6aCXVdum0XoLZ+2RMX77Yn4C3WY3inEMenF8eZ7xDhSzrT5ek1DqlXiQ==', '2023-09-26 09:59:25.843', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2685, N'169861', N'KEMALETTİN', N'KORKMAZ', N'05055414650', N'kemalettin.korkmaz@egm.gov.tr', N'POLİS MEMURU', N'KAYSERİ HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPNMqprZCo/Uwb1eVvQjtgGlUsu75aFxsXJtDi0HydrRfLejAmPkmMg7Xe2/5EL7ow==', '2023-10-07 19:16:26.127', N'KAYSERİ HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2688, N'520105', N'ÖNDER', N'TÜRKEŞER', N'05380128369', N'onder.turkeser@egm.gov.tr', N'Polis Memuru', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEA/ygtyphlxwUB77x6n0dzflRSYr1ciPzVnMAF/N7lnGV4RO4Y44iz7YQmwitvIdog==', '2023-10-09 19:17:53.503', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'0', N'Student', '2026-03-31 10:31:39.850', 0, 1, 0, NULL, NULL),
            (2689, N'437963', N'fatih', N'üçkan', N'05423566746', N'fatih.uckan@egm.gov.tr', N'polis memuru', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAECyHbp5jgPfc/EABg80zlTiwQnxdeG8+NKMahq1f+5NNOIuN6D1h+ynTqanFDpfq5w==', '2023-10-10 15:53:43.860', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2690, N'187868', N'AHMET', N'ERGÜN', N'5054505356', N'ahmet.ergun@egm.gov.tr', N'Başpolis Memuru', N'EDİRNE İPSALA KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEITlrcluCtbSXIJRPepC6ZVuRgIXc3Gz1ipTU+3v+wZl93tDjhvk67VqF6B55iG4Ag==', '2023-10-13 16:22:14.623', N'EDİRNE İPSALA KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2691, N'426961', N'MEHMET EMİN', N'KAHRAMAN', N'05050379378', N'mehmetemin.kahraman3@egm.gov.tr', N'POLİS MEMURU', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEHb/PcQYZJhSvnJjENERBmIPQ7rsexF46sQwgdQMsEGCuGOEQUGjbZc/lt0y8BhC5w==', '2023-10-13 16:23:43.497', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', '2026-04-01 13:16:51.200', 0, 1, 0, NULL, NULL),
            (2694, N'235770', N'NİHAT', N'AKARDENİZ', N'05063819824', N'nihatakardeniz@egm.gov.tr', N'Polis memuru', N'MERSİN TAŞUCU-SEKA DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJPb1daKUHZpxd/MgAAGKjeKVsk7jwAEBuH46AyCllfsxTpcoeNfQZLcZUPRLLDqAQ==', '2023-10-17 09:14:21.590', N'MERSİN TAŞUCU-SEKA DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2695, N'447064', N'SERGEN', N'ARPAĞ', N'05418414177', N'sergen.arpag2@egm.gov.tr', N'POLİS MEMURU', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEDKpVnWoE6ZysO4NtNT7HEdgA5M7wPXe0Fibcw6Q4sAL5IPR2Zp4714UCfSDAtTxcA==', '2023-10-17 09:14:27.403', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2699, N'343074', N'HARUN', N'AKARSU', N'05535923596', N'harun.akarsu@egm.gov.tr', N'polis memuru', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEBkkEc7sHF5uVrxQVb/CdANfHZAwEL6R5FW3CtkNbspq3zuPX/ExU8OOIWxHSVPb1w==', '2023-10-20 11:49:05.870', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2705, N'489386', N'ESRA', N'DEMİRKOPARAN', N'05539455081', N'esra.demirkoparan@egm.gov.tr', N'polis memuru', N'MUĞLA DATÇA DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPvyul1mPaxMJMI2uwTIgUqMVuxewmGSJGW/LtBCyoohp/9B3a74WiTYI5coDzgZYA==', '2023-10-25 14:00:29.097', N'MUĞLA DATÇA DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2708, N'494041', N'NURULLAH', N'GÜLAL', N'5526190838', N'nurullah.gulal@egm.gov.tr', N'Polis Memuru', N'İSTANBUL AMBARLI DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPzHwMScXdvQXveKlmY8t+SEWmLfapljQ8cj0YJo4nIEAsnvDig1FEbCpncUk7elDg==', '2023-10-30 10:28:55.697', N'İSTANBUL AMBARLI DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2709, N'311185', N'emre', N'kestek', N'5057944312', N'emre.kestek@egm.gov.tr', N'polis memuru', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPeeJuRn8zexT0RoLXS/ubFlFtbMTs1cLsxg5qefhgrEYTwluKvrhHQ1zZi4ST22Zg==', '2023-11-01 15:33:15.823', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2710, N'495778', N'oğuzhan', N'bilgin', N'5318389229', N'oguzhan.bilgin2@egm.gov.tr', N'polis memuru', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEDkcGIasafNVrqW/Gx/5GwxacowRNod76rR/InMZSc77MRcfWmReqCXqVUBvS/eVyA==', '2023-11-01 15:34:16.183', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2712, N'363909', N'KENAN', N'KAHRAMAN', N'5078384831', N'kenan.kahraman3@egm.gov.tr', N'polis memuru', N'KONYA HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEN1EIKqDKM+TV2+IR+QELNF87QM0np3/4FQm6GbhPfaevwAhhWv9qlBqt6q2K+USyw==', '2023-11-19 19:14:49.343', N'KONYA HAVA LİMANI', N'0', N'Student', '2026-04-04 08:28:22.177', 0, 1, 0, NULL, NULL),
            (2716, N'358447', N'mehmet', N'uluçay', N'5075334026', N'mehmet.ulucay2@egm.gov.tr', N'p.m.', N'GAZİANTEP HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEK1ZWSb8F+WzrMF7oyYI7leX7kjvehUKg1akVU0jE10BYwh1FCkJxFSBGXZxi1CmJA==', '2023-12-04 19:25:20.623', N'GAZİANTEP HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2717, N'481647', N'ENSAR', N'YENİKURTULUŞ', N'05469580856', N'ensaryk_72@hotmail.com', N'Polis Memuru', N'ARTVİN SARP KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEKzwaai16YPZsuSsKWuVIZcnBbqAJ8zFvHKHsFcP20ZjW3wIUd041Tdh8bZw17TGOw==', '2023-12-05 13:46:55.003', N'ARTVİN SARP KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2719, N'278356', N'ismail', N'aydın', N'5063590867', N'ismail.aydin4@egm.gov.tr', N'POLİS MEMURU', N'KOCAELİ DERİNCE DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJoTTUJS+AcTU3udNul44p8M5cL0VI5lViR+TBImT4Y84TK8mhqqXRsdBkdBbAQjVA==', '2023-12-15 16:32:51.580', N'KOCAELİ DERİNCE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2722, N'198021', N'uğur', N'ünver', N'5053542277', N'ugur.unver@egm.gov.tr', N'polis memuru', N'KAYSERİ HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEIVMq2EFMgesZru6Ij6W3EDSsJKlXohWBhPnX6imqxbRdl8I4jL+aQjZsmew6QUaJA==', '2023-12-21 10:11:09.960', N'KAYSERİ HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2724, N'276887', N'hüseyin', N'durucu', N'05064565388', N'huseyin.durucu@egm.gov.tr', N'polis memuru', N'KONYA HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEAv94as3hi40/V++tVIDWww6yoK+d5UGpjft3iXcEBMX3v6Y9BHCI/Q5pdasowfyIA==', '2023-12-21 14:30:39.623', N'KONYA HAVA LİMANI', N'0', N'Student', '2026-04-02 03:03:57.093', 0, 1, 0, NULL, NULL),
            (2727, N'383550', N'Gökhan', N'arslan', N'5076064031', N'gokhanser37@hotmail.com', N'polis memuru', N'KASTAMONU İNEBOLU DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPf0XrTgq/yptiUgFx+Bwvhy3eTfio1aGKp37iI2J4lOJi0ds8U+zBcaEr83OJ2lHg==', '2023-12-25 15:53:43.110', N'KASTAMONU İNEBOLU DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2728, N'393745', N'veli', N'emir', N'05425324217', N'veli.emir@egm.gov.tr', N'polis memuru', N'ARTVİN SARP KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEMI6n3BXhRdP4PBdUDujQAKg8PL+T9K0qCgSt+t6BLShlgLjxEFk7513/C2FmmuB3A==', '2023-12-29 10:32:31.450', N'ARTVİN SARP KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2729, N'474317', N'MÜCAHİT', N'AVCU', N'5077270420', N'mucahit.avcu3@egm.gov.tr', N'polis memuru', N'ELAZIĞ HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEBkH9gIC5HWdsL6xpFBoPewBERgij2d8kM13Wv0h482hYH4ekk0vZe5dKJK5koCrGw==', '2023-12-29 10:32:36.510', N'ELAZIĞ HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2731, N'525753', N'OZAN', N'ÖZER', N'05528521243', N'ozan.ozer2@egm.gov.tr', N'Polis Memuru', N'İSTANBUL ZEYTİNBURNU DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEIY+fPQnuvfF/D02ETEixNF58ylpmS4tBciP+YD9Yrh4OdZIGxhNnJ/KkRrhmBVrkA==', '2024-01-02 15:42:00.097', N'İSTANBUL ZEYTİNBURNU DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2734, N'220246', N'İMİRZA', N'YENER', N'5056283307', N'imirza.yener@egm.gov.tr', N'polis memuru', N'MERSİN TAŞUCU DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEO03/32urvq1zaJrWhQ+ZxLZDBSuG6eYL2N4jaN6P0xAHPxzarkIxuGjhi+7kIRqnA==', '2024-01-07 19:23:00.333', N'MERSİN TAŞUCU DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2735, N'446504', N'FURKAN', N'YİTE', N'05424422071', N'furkan.yite@egm.gov.tr', N'POLİS MEMURU', N'ARTVİN SARP KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEH6LcLUQtTXwaKnkC1RGgmqj/x6BZnZ+P/VUtBiFwzSOsaxqDx6g5VWiSJV1kqGITA==', '2024-01-09 14:06:24.033', N'ARTVİN SARP KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2736, N'384327', N'Mehmet', N'HEKİMOĞLU', N'5061006065', N'mehmet.hekimoglu@egm.gov.tr', N'Polis Memuru', N'ARTVİN SARP KARA HUDUT KAPISI', N'', N'3,4', N'1', N'AQAAAAEAACcQAAAAEEvm27bMwczdbJh+EUaVJ7QkWo7sbGYhfxsMtW1K0wAbwBNe4++oXtjT4q0NtNYP7Q==', '2024-01-11 08:56:39.363', N'ARTVİN SARP KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2737, N'481402', N'Hamdi', N'KAYA', N'05541300670', N'hamdi.kaya5@egm.gov.tr', N'Polis Memuru', N'Pasaport Kontrol Memuru', N'', N'3,4', N'1', N'AQAAAAEAACcQAAAAEPykC5OvpUcS2UlxTA3jlIA6Qq8zR4PtWEjC7R3+71URxm+pHJ2qm62C7jD1gF28Hw==', '2024-01-11 13:47:29.353', N'ZONGULDAK DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2738, N'249518', N'ÖZKAN', N'YILMAZ', N'5052349735', N'ozkan.yilmaz4@egm.gov.tr', N'polis memuru', N'EDİRNE PAZARKULE KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAENcjqGtU3WWOglgddJhV+nJyc0aIKsBBsphT1xoElcYkE7XpR+6zcEpf/Wuq4qhv+Q==', '2024-01-12 16:45:22.083', N'EDİRNE PAZARKULE KARA HUDUT KAPISI', N'0', N'Student', '2026-04-02 13:19:36.937', 0, 1, 0, NULL, NULL),
            (2743, N'389988', N'Fuat', N'GÜN', N'05382080565', N'fuat.gun@egm.gov.tr', N'Polis Memuru', N'IĞDIR DİLUCU KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEAkl5kU3Y3rgM//B7SGdFE5/zyw/BkRj6+gP5++GeSan+nJp0Ic0lKKuJ7oWFa2WHw==', '2024-01-22 17:10:18.223', N'IĞDIR DİLUCU KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2744, N'328903', N'koray', N'aydın', N'5077457878', N'koray.aydin3@polnet', N'p.m', N'SAMSUN ÇARŞAMBA HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEGAxeEhRAqnrX+af3xGqkGPeXqX+c4rJdOptFFNSCxR5F3MmK0jOtUmBE8KSZNvzuA==', '2024-01-22 17:11:42.330', N'SAMSUN ÇARŞAMBA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2751, N'521035', N'İsa', N'YILMAZ', N'05319376286', N'isa.yilmazc9c51@egm.gov.tr', N'Polis Memuru', N'EDİRNE PAZARKULE KARA HUDUT KAPISI', N'06ef5ff70af34f14b1c41e3e61be36ea.jpg', N'3', N'0', N'AQAAAAEAACcQAAAAEC8NthjsBetMX499ApVQ8r6pz7J6wvp+dKpxNzDFFfjxnokNnKy8zYyGSeMnLcaDsw==', '2024-02-08 19:23:46.847', N'EDİRNE PAZARKULE KARA HUDUT KAPISI', N'0', N'Student', '2026-04-06 19:55:33.190', 0, 1, 0, NULL, NULL),
            (2756, N'442169', N'FURKAN', N'ERÇİN', N'05050254719', N'furkan.ercin@egm.gov.tr', N'polis memuru', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPydve0gHxRa5TEnwYKC2GbvtJwyqA2feuMpLeSt6U7FBHP9Aunc2xYkZzc3PdSCYw==', '2024-02-12 15:53:14.323', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', '2026-04-04 14:53:29.697', 0, 1, 0, NULL, NULL),
            (2758, N'273017', N'UĞUR', N'SÖZÜPEK', N'5079876857', N'ugur.sozupek@egm.gov.tr', N'polis memuru', N'BURSA YENİŞEHİR HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEGUNI++piuWN4+VBMxIxwOSKXVnXv2ELmBFwjYrnsGE6+HesgWlRo5AlODWsGfvKOA==', '2024-02-21 19:24:10.353', N'BURSA YENİŞEHİR HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2759, N'342477', N'Tolga', N'SATILMIŞ', N'05072630937', N'tolga.satilmis@egm.gov.tr', N'Polis Memuru', N'KÜTAHYA ZAFER HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEC7sAsZIbATDRiXLEyWVOV1mk1cVNFFju/qD+eGbnY5dsZRpOag57++zbx1Z2vYqhw==', '2024-02-23 12:13:18.803', N'KÜTAHYA ZAFER HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2763, N'386823', N'Semi', N'ÇAKIR', N'05521861126', N'Semicakir@egm.gov.tr', N'Polis Memuru', N'ESKİŞEHİR HASAN POLATKAN HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEMMgJ/NmvpRT64hqBPuxGYBGR3iUoXEspoxFpgmriks7e0gWDOfeun4xgjVLJhIhLA==', '2024-03-01 16:14:34.757', N'ESKİŞEHİR HASAN POLATKAN HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2764, N'516510', N'ELİF', N'GÜNGÖR', N'05393911886', N'Elif.gungor2@egm.gov.tr', N'POLİS MEMURU', N'TRABZON HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAENjFwtyXnjCWP9eC0v9DShrImCXHpO7ndDWEKvmKUMO8FVytTVgHHkjYBhPFjjGk7g==', '2024-03-09 19:31:34.403', N'TRABZON HAVA LİMANI', N'0', N'Student', '2026-04-05 09:48:16.483', 0, 1, 0, NULL, NULL),
            (2765, N'331253', N'MUHİTTİN', N'DEMİREL', N'05548295787', N'muhittin.demirel@egm.gov.tr', N'POLİS MEMURU', N'TRABZON HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEFgFUnbJhmInFPbzG7m2sFWKHs7ZWNq5VteP1Nu959jZdweliRb+h/QgDeRJDCfeNw==', '2024-03-11 19:49:50.233', N'TRABZON HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2768, N'484276', N'ERHAN', N'TAŞTAN', N'05442743820', N'erhan.tastan3@egm.gov.tr', N'POLİS MEMURU', N'IĞDIR DİLUCU KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAED8HPdQnYK5aHbgs2nTaGl1j8Q3q0+nbmh46vY1E7r8tT3KrliQzjxOkKm037DlKjA==', '2024-03-22 19:40:44.750', N'IĞDIR DİLUCU KARA HUDUT KAPISI', N'0', N'Student', '2026-04-09 13:39:09.310', 0, 1, 0, NULL, NULL),
            (2769, N'463803', N'incilay ', N'mayuk', N'05425580720', N'cobanincilay@gmail.com', N'polis memuru', N'MUĞLA FETHİYE DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEFTr55/sLh5A8m4MoyOOVm7mS26UNt+C4nl/cRY7TCNbcDXBHfObIdjluELf2naldg==', '2024-03-26 18:55:52.143', N'MUĞLA FETHİYE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2770, N'224729', N'Rabia', N'ÇETİN', N'505 889 25 08', N'rabia.cetin@egm.gov.tr', N'Polis Memuru', N'ANTALYA DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPLR5n9M47XKL6WnxqAuyCE5Ff1aNX2Qv7BOe0a3XhaxFmWquWJlDfzr+EtWIdPgXw==', '2024-03-28 08:28:58.357', N'ANTALYA DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2772, N'321061', N'Ahmet Yavuz', N'Belikara', N'05534786084', N'ahmetyavuz.belikara@egm.gov.tr', N'Polis Memuru', N'ANTALYA KAŞ DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAECLsQPR93d/behnR4uaWOIY08Gjgqndecu1ixqq0wh8iQgJ63xp6RVzjTG/U3uJodA==', '2024-03-29 11:09:55.257', N'ANTALYA KAŞ DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2774, N'444721', N'Muhammet ', N'SÖZCÜ', N'5453431684', N'muhammet.sozcu@egm.gov.tr', N'Polis Memuru', N'ANTALYA KAŞ DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEAmO/Cbbk2xUW3ZUToAPXzLvQA9rkStu30c94Eb6rZyxPpCbeNCgTKLVD0EJgih6EQ==', '2024-03-29 11:10:02.333', N'ANTALYA KAŞ DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2775, N'393379', N'EMRE', N'KANLI', N'05453746090', N'emre.kanli@egm.gov.tr', N'Polis Memuru', N'ANTALYA HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAENOtNmlqFmNTxCy0zE2AVIkINuBdYhlrIxqJ1AhJ/Y/KtpWlpVdIWqjCyDTtqClWXw==', '2024-03-29 11:32:16.370', N'ANTALYA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2776, N'380014', N'Mehmet ', N'YILMAZ', N'05071805535', N'mehmet.memis5@egm.gov.tr', N'Polis Memuru', N'ANTALYA HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEDQ+pqYHl47So838BIVTWYOgf0LR3eQDp8i21gOavDtvQO6+KAZ3mFqcKTz8Zdv0Xw==', '2024-03-29 11:37:06.110', N'ANTALYA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2778, N'311793', N'Gökmen ', N'SEVİM', N'05068520051', N'gokmen.sevim@egm.gov.tr', N'Polis Memuru', N'ANTALYA KAŞ DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEBV28/bARnCeqdmR1dasLAvGahgBNvU+t4MfpZ9IaY4Hhn459knkVcDOze1YIbq5tg==', '2024-03-30 08:40:57.467', N'ANTALYA KAŞ DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2781, N'344184', N'Yavuz', N'BERTAN', N'0507 840 15 76', N'yavuz.bertan@egm.gov.tr', N'Polis memuru', N'DİYARBAKIR HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEA/gUxf1g6VEWy+h+KBB73u6DPXzXTz77HYBEvc4HEFLm5epwEA/LRVsLLF1ex8j7A==', '2024-03-31 09:12:06.013', N'DİYARBAKIR HAVA LİMANI', N'0', N'Student', '2026-04-03 11:02:39.003', 0, 1, 0, NULL, NULL),
            (2782, N'395123', N'osman', N'gülbay', N'05542856025', N'osmannurulbay@gmail.com', N'POLIS MEMURU', N'TRABZON HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEN3wUtELNkzrG7SS8pYRqixmRnwXBqijaAKHQAH58tiCnF0vHiffLR0PSeeO5pNyUA==', '2024-03-31 09:12:10.903', N'TRABZON HAVA LİMANI', N'0', N'Student', '2026-04-05 09:50:33.340', 0, 1, 0, NULL, NULL),
            (2783, N'249956', N'ABİDİN', N'YALÇIN', N'5056774732', N'abidin.yalcin@egm.gov.tr', N'Polis Memuru', N'ŞANLIURFA GAP HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEIgHlOYI+BM7yQVmWCw1/FBoDKxGhKZvh7bXGVHqEuzyMc+9CWWjXhoc3uMt2ecOtg==', '2024-04-03 10:57:50.527', N'ŞANLIURFA GAP HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2784, N'515337', N'jale', N'şamdanlı', N'05070512100', N'jale.samdanli@egm.gov.tr', N'polis memuru', N'EDİRNE KAPIKULE KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEAJhojq53K9pkSCmi4DKQhY5Ue/QKmIHC5HW+onH34COsHxq4Xnhvs1x/ROO2IR4SA==', '2024-04-06 19:05:30.080', N'EDİRNE KAPIKULE KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2785, N'434326', N'MEHMET', N'SANCAK', N'0539 300 25 07', N'mehmet.suncak@egm.gov.tr', N'Polis Memuru', N'HAKKARİ ÜZÜMLÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEHomoH/3ftR2kRNakos0Ic9ThD+MYlcz3MPC8W0kaLiKn0pnJrGEXyNr+B1PigvNUA==', '2024-04-10 19:39:30.727', N'HAKKARİ ÜZÜMLÜ KARA HUDUT KAPISI', N'0', N'Student', '2026-03-31 15:49:14.300', 0, 1, 0, NULL, NULL),
            (2788, N'268580', N'FERHAT', N'ÖZÇELİK', N'5056260280', N'ferhat.ozcelik.2@egm.gov.tr', N'polis memuru', N'TRABZON HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEDRawA2J2K+1Ihan7L0+LfpORAFxWWsRNczO5/hAO1rCP9lzrg3s0781o9lXx/cewQ==', '2024-04-16 08:57:59.967', N'TRABZON HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2789, N'350271', N'ONUR', N'PİŞKİN', N'5432666636', N'onur.piskin2@egm.gov.tr', N'polis memuru', N'ANTALYA HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAENer4+b1aIVEbdaX4oeccGElY8Iy1cCjplUhzLcVIGuaxswAh0vrQoA5PEBUQI6txg==', '2024-04-16 13:13:25.423', N'ANTALYA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2798, N'476440', N'CENKER', N'BİLEYCİ', N'5422503231', N'cenker.bileyci@egm.gov.tr', N'polis memuru', N'ÇANAKKALE İÇDAŞ DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEIaRRhCYURsVyzmwvT1LwQnkxLiuk0o1vJiJb+P1JkvqZR6qnXCmYfwkMXRE4rfaFA==', '2024-04-26 11:51:02.933', N'ÇANAKKALE İÇDAŞ DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2799, N'280422', N'İlteriş', N'Kaynar', N'05058880612', N'ilteriskaynar@gmail.com', N'Polis Memuru', N'Fethiye Deniz Limanı Şube Müdürlüğü', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEHCVk/LX8hcn3L7lptO8rIZnU7nN+HYhWYF/UqSITLfcgzc++7U+B3W5kDxrAkxOIQ==', '2024-04-27 08:33:06.493', N'HAKKARİ ÜZÜMLÜ KARA HUDUT KAPISI', N'0', N'Student', '2026-04-01 12:00:45.783', 0, 1, 0, NULL, NULL),
            (2800, N'329058', N'Şahin', N'Alan', N'05536363477', N'sahin.alan@egm.gov.tr', N'Polis Memuru', N'MUĞLA FETHİYE DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEFsLgrHUihYHQ04oS2mYsu19xQImZOwqvhXOB98mi1IGgK3bLU3VkRF2eXsm5/OgfA==', '2024-05-01 08:32:03.923', N'MUĞLA FETHİYE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2807, N'519601', N'Ünal', N'MACİT', N'05456012145', N'unal.macit@egm.gov.tr', N'Polis Memuru', N'MUĞLA BODRUM YOLCU İSKELESİ DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPcqmKIN+3ZPEYKXj8cKbvLYH+F9obiU6jsXKCr5dLvrrXj7J1RjXfsKwQ9cS4NElA==', '2024-05-14 16:03:03.717', N'MUĞLA BODRUM YOLCU İSKELESİ DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2812, N'317619', N'MÜCAHİT', N'AK', N'05313175445', N'mucahit.ak@egm.gov.tr', N'POLİS MEMURU', N'SİNOP DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEIudg1m5crqbSMiNOjxXLcp7qXxApgoSnTvrdX+z3XqEXudrRO/fbLfQArapOSDB5A==', '2024-05-15 16:21:18.310', N'SİNOP DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-07 17:47:22.627', 0, 1, 0, NULL, NULL),
            (2814, N'275898', N'Kemal', N'BİRİNCİ', N'05054519061', N'kemal.birinci@egm.gov.tr', N'Polis Memuru', N'SAMSUN ÇARŞAMBA HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEMd15obNy5O31kOSeC79WjWhP/8QAXrfkQ5B8cH8/FPcb9mRZgCqNO5mxNe/rfru4g==', '2024-05-21 19:21:13.157', N'SAMSUN ÇARŞAMBA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2817, N'381741', N'mücahit', N'dursun', N'05538435943', N'mucahit.dursun@egm.gov.tr', N'Polis Memuru', N'EDİRNE KAPIKULE KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEFoQOPrQ4tgFoRTnNg/wWO6JIhIs4WaoXUfgBtseprfakF+DpTUtjlLkEdNkCBx1GA==', '2024-05-27 08:29:28.357', N'EDİRNE KAPIKULE KARA HUDUT KAPISI', N'0', N'Student', '2026-04-07 02:40:29.360', 0, 1, 0, NULL, NULL),
            (2818, N'359897', N'Ali', N'Küçükaltun', N'05075212228', N'ali.kucukaltun@egm.gov.tr', N'Polis Memuru', N'ISPARTA SÜLEYMAN DEMİREL HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAELxmQ1Mj/M6d9vpLgHoMvNoH/g5p66R00BykAsW58o2zL2CACXVZvNIAAjfJ8xIBfw==', '2024-05-28 08:30:56.790', N'ISPARTA SÜLEYMAN DEMİREL HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2820, N'410599', N'MUSTAFA', N'KUTLU', N'05414983433', N'mustafa.kutlu5@egm.gov.tr', N'Polis Memuru', N'AYDIN KUŞADASI DENİZ HUDUT KAPISI', N'714a1b41145f42a182989f59117b2cfc.jpg', N'3', N'0', N'AQAAAAEAACcQAAAAEKDPXQKFr+N+LZigLTJRU0JdqBVa/LrbvAB4jFc6YxV/NlH22kj1LGrWJHDHOqXVbw==', '2024-05-29 08:30:35.577', N'AYDIN KUŞADASI DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-08 08:00:16.320', 0, 1, 0, NULL, NULL),
            (2822, N'296008', N'sedat', N'albayrak', N'5066027958', N'sedat.albayrak@egm.gov.tr', N'polis memuru', N'BALIKESİR KOCA SEYİT HAVA LİMANI', N'4078e215037f4cc49bc152878a9b6ed8.jpg', N'3', N'0', N'AQAAAAEAACcQAAAAEPDgIuMRnKoifiLOGk0HEgQLKbwxLVfdNn83NGpwCk8lD3CsyE+96pnCe0iPTXj66A==', '2024-06-10 10:35:55.403', N'BALIKESİR KOCA SEYİT HAVA LİMANI', N'0', N'Student', '2026-04-01 16:52:31.910', 0, 1, 0, NULL, NULL),
            (2823, N'474658', N'Mustafa', N'Karakoç', N'5349628813', N'mustafa.karakoc11@egm.gov.tr', N'polis memuru', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEKB/3MZ6iyLvlH3q7Z4Cz0pEdzUFhDH5JfiNTl7PBKBgjD+jI27yVesgQ/VVSjuMug==', '2024-06-10 10:36:42.620', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2824, N'207403', N'İBRAHİM', N'KIRAÇ', N'05053522810', N'ibrahim.kirac2@egm.gov.tr', N'Polis Memuru', N'HATAY HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEDFhlsGmamGlIFcFXkAdgTpkm2KTHGdy6yMFd/Or0MiZQAHkJNNlgNT9OIv/TayFaA==', '2024-06-10 16:34:29.743', N'HATAY HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2826, N'240041', N'Nehar', N'YENİ', N'5052406107', N'nyeni@egm.gov.tr', N'polis memuru', N'BALIKESİR KOCA SEYİT HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEBNyvxXfHR6ke59BazOjBc693fanMpUP43zpn5/9q6zDhs/IUQYXFVOLRbiQpUD/pg==', '2024-06-11 15:35:29.787', N'BALIKESİR KOCA SEYİT HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2829, N'361242', N'ORÇUN', N'DÜZEL', N'05414683401', N'duzelorcun@hotmail.com', N'polis memuru', N'MERSİN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEEuW7jAsfuzkd12lDHTuXvmL6ygpXGVieuEhLxGaqgWa11dfVcbFt6OG3r6lF3mgCg==', '2024-06-13 16:55:04.707', N'MERSİN DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2835, N'394235', N'Mevlüt ', N'ULUSAL', N'05547568118', N'lazkooxx@icloud.com', N'polis memuru', N'AĞRI GÜRBULAK KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEEaCh2YCvhOFXTRtU9Z8fnkrjI1YX2l3ms9qPvlCiorUl9IJHSSipgDMa+UxRew3FA==', '2024-06-24 19:21:58.453', N'AĞRI GÜRBULAK KARA HUDUT KAPISI', N'0', N'Student', '2026-04-04 09:31:53.783', 0, 1, 0, NULL, NULL),
            (2839, N'434075', N'faruk', N'ataş', N'05455462571', N'faruk.atas3@egm.gov.tr', N'polis memuru', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJm+NVfzZr2g5KQPC0uvsONIWFluUL44Q6c8rvRWB3NywxZBJ6dKkMNuTwA5Uq6A+g==', '2024-07-12 12:53:45.453', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2841, N'228051', N'HAKAN', N'ÇETİNKAYA', N'05053483875', N'hakan.cetinkaya@egm.gov.tr', N'Polis Memuru', N'İSKENDERUN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEK5kgUorNAPYX2krtkpiCKVsRTQtbaRQbMkze3Fzv3XHtVWur/KLZThhiR+4G14QlQ==', '2024-07-12 13:22:06.603', N'İSKENDERUN DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2842, N'264205', N'HARUN ', N'KARTAL', N'05055430825', N'harun.kartal@egm.gov.tr', N'polis memuru', N'MERSİN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEOK/MUjpNit1dHi1dtI+74HeCBAmItO09ZVA+TWwD+xZpRXn+uo4utfFQfzdmvuUvw==', '2024-07-16 09:10:22.853', N'MERSİN DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-02 14:11:56.987', 0, 1, 0, NULL, NULL),
            (2844, N'236935', N'HABİP', N'SOYSAL', N'05054015240', N'habip.soysal@egm.gov.tr', N'polis memuru', N'İSKENDERUN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEEtulmeH8HdynMRQzR5fAKX9AhWZkAX/95L/TrX7Cqca+M6fHNoiBTqJiVEXo3K+dQ==', '2024-07-19 10:12:55.333', N'İSKENDERUN DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2846, N'421582', N'MUSTAFA ', N'ALDANMAZ', N'0 544 100 59 09', N'mustafa.aldanmaz@egm.gov.tr', N'Polis Memuru', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEH1muy3/tFlNPrWR/owhqtf7nMCHE54V3kRNqJoG3TDcWMG0V5rM+MQZ6eX8ou6ZRA==', '2024-07-19 14:56:23.840', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-06 08:46:14.287', 0, 1, 0, NULL, NULL),
            (2848, N'341072', N'İsmail', N'ESMER', N'05074674803', N'ismail.esmer@egm.gov.tr', N'Polis Memuru', N'DENİZLİ ÇARDAK HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEMH4Wn6dZQV4Rcz3Zcj0i8LRvEc15Dxg/Kb+wPNiqu1s1qjyiwXoszlSVQuUjY1KOw==', '2024-07-22 10:12:55.393', N'DENİZLİ ÇARDAK HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2854, N'280257', N'Habeş', N'İDE', N'05535545654', N'habeside@egm.gov.tr', N'Polis Memuru', N'BALIKESİR KOCA SEYİT HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEKifcIDSY75JToZuSPAauCIlVuGmoLRLSaBwtlYq14pzKT51Pumg7WVldVPdzoYJaw==', '2024-07-23 09:50:21.263', N'BALIKESİR KOCA SEYİT HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2860, N'433591', N'Murat', N'Aydemir', N'5536728425', N'murat.aydemir10@egm.gov.tr', N'polis memuru', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEEHm1uDRzMkwh4pUhsozhqo1Cq9fGk6/AzmeeZ2Coe+s/mPu4zEHAckgysfswB8OvQ==', '2024-07-26 08:39:49.960', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'0', N'Student', '2026-04-08 05:57:16.300', 0, 1, 0, NULL, NULL),
            (2861, N'464244', N'ABDULKADİR', N'YILDIRIM', N'05349161982', N'abdulkadir.yildirim6@egm.gov.tr', N'polis memuru', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEKrb568kugfvCkNCyW+XB7FzxC8/qgS6EqUJEZ0t4wpCrFrMdKm/SW9nYiNl17CbfA==', '2024-07-26 08:39:55.697', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2863, N'450711', N'MEHMET', N'MUĞAL', N'05461909335', N'mehmet.mugal@egm.gov.tr', N'polis memuru', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEGAUhIaw1ZXG6f+dKXVjcuYaDakR3+LnGRM2mXt2r1+rtRC7ksCD5ijFakYzOdG7vA==', '2024-08-02 19:57:02.020', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'0', N'Student', '2026-04-08 16:15:35.923', 0, 1, 0, NULL, NULL),
            (2865, N'394341', N'süleyman', N'çakır', N'05059710635', N'csulo394@gmail.com', N'P.m', N'AĞRI GÜRBULAK KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEHxr9ib3EmMCjL30kiIA6BOZaKvi1qm5hnP5FLTEpLILuKl7RC/it9CL8NZ/XpzAXg==', '2024-08-04 19:36:09.910', N'AĞRI GÜRBULAK KARA HUDUT KAPISI', N'0', N'Student', '2026-04-03 03:59:17.747', 0, 1, 0, NULL, NULL),
            (2866, N'395337', N'özer', N'canbey', N'5464680214', N'ozer.canbey@egm.gov.tr', N'polis memuru', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEB9NTQMKPf5rRl7R7gVY+HY3fZf9lw770LLGDUH4mycfNTE9Gcb3PJ54mtxzWw3sWQ==', '2024-08-04 19:36:14.597', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', '2026-04-03 14:07:58.310', 0, 1, 0, NULL, NULL),
            (2867, N'445930', N'AHMET', N'GÜNGÖR', N'538 524 43 15', N'ahmet.gungor8@egm.gov.tr', N'Polis Memuru', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEIAUxlJ/x+WqWcHUqPwY423VHaKpe86KpAm0+tJ7wVCZmM68M5D/92AhXD9Bp8Ilcg==', '2024-08-05 15:54:06.823', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2869, N'445469', N'Ömer Faruk', N'GÜNDOĞAN', N'05387922227', N'omerfaruk.gundogan@egm.gov.tr', N'Polis Memuru', N'GAZİPAŞA HAVALİMANI ŞUBE MÜDÜRLÜĞÜ', N'33ab865ca8474633b3f27624e5e3d4ad.jpeg', N'1,2,3,4,5', N'0', N'AQAAAAEAACcQAAAAEL62j1YRxfTjcODb+Z82GBHxvc9V8W7YxmpX8n42dnvI+3ed7YBvSJzTKYjQ0ukSBw==', '2024-08-07 14:44:08.047', N'ANTALYA GAZİPAŞA HAVA LİMANI', N'1', N'Admin', '2026-04-06 01:11:50.487', 0, 1, 1, NULL, NULL),
            (2870, N'265558', N'Olcay', N'TOSUN', N'5055401962', N'olcay.tosun2@egm.gov.tr', N'Polis Memuru', N'MUĞLA FETHİYE DENİZ HUDUT KAPISI', N'65c5cb3984744c85bab25a8816971f1d.jpeg', N'3', N'0', N'AQAAAAEAACcQAAAAEKYyfeFe5S3+D7V9v9HJqhsGIWayWBFR7L2zaFsR2vw6VfUPBLGFxzWSeW4/WSh4qw==', '2024-08-09 17:22:10.387', N'MUĞLA FETHİYE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2871, N'402606', N'AHMET', N'BAĞCI', N'05418762611', N'ahmet.bagci6@egm.gov.tr', N'POLİS MEMURU', N'EDİRNE HAMZABEYLİ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEGOpatzY+oDFamYaiD4CrHpajrgWp1sP1HM1drO8rqYgKHFk+cialH0EDYkC/PjR3Q==', '2024-08-09 17:22:16.810', N'EDİRNE PAZARKULE KARA HUDUT KAPISI', N'0', N'Student', '2026-04-05 06:21:59.057', 0, 1, 0, NULL, NULL),
            (2873, N'399336', N'yunusemre', N'altun', N'05425711868', N'yunusemre.altun3@egm.gov.tr', N'polis memuru', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEKBq67wePego1NuF9GTydacVBCaMxf2bRfUl1shFta3rC6snKXJWgsNfHoWjL3fyWg==', '2024-08-11 10:52:25.157', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2875, N'437467', N'TARIK ZİYAD', N'DOĞAN', N'0 538 031 86 01', N'tarikziyad.dogan@egm.gov.tr', N'Polis Memuru', N'ELAZIĞ HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEK00LR21yM73VnKkwJqKHmZja8isFbZoNGGDMsqzGdzNDw7D5JkYbbEe0jkjtTJIrA==', '2024-08-13 08:30:35.427', N'ELAZIĞ HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2877, N'458694', N'Hüseyin', N'Çatal', N'0555 032 90 42', N'huseyin.catal@egm.gov.tr', N'Polis Memuru', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEOE508x07UXnR1xqUVsbCa7u+02u3OjhdTekqhxFvUGLWLEeNLndDskZV21oQO/wpg==', '2024-08-19 19:15:29.247', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'0', N'Student', '2026-04-03 14:30:14.863', 0, 1, 0, NULL, NULL),
            (2878, N'387416', N'süleyman', N'ala', N'5453888558', N'suleyman.ala@egm.gov.tr', N'Kom.Yrd', N'ANTALYA GAZİPAŞA HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEOBaIY0G/Q1bygZVLymExm+CyOC3p4P0prZpNWoKKmivXF6nAz315OycjisF1YaH1g==', '2024-08-22 16:19:05.767', N'ANTALYA GAZİPAŞA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2881, N'434286', N'ALİ SERDAR', N'PİŞKİNEL', N'05413140129', N'aliserdar.piskinel@egm.gov.tr', N'POLİS MEMURU', N'HAKKARİ ESENDERE KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEF/RoJO5/t1R9eslmwIQRnfFRiRLiKe+pfSvCHRglEIZTsRJX71iKXy3leGs1qpkMg==', '2024-08-23 14:22:02.763', N'HAKKARİ ESENDERE KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2883, N'501460', N'HAYRETTİN', N'GÜNAYDIN', N'5392142372', N'hayrettin.gunaydin@egm.gov.tr', N'POLİS MEMURU', N'ÇEŞME DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEGMfugU1V/WNa+cGxwSnv1x6pbsPgPgFzfpPjW9SsH2Q/pv5VlxXCk+soaZkYLGN+A==', '2024-08-23 19:53:35.250', N'ÇEŞME DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-01 08:53:56.207', 0, 1, 0, NULL, NULL),
            (2885, N'452885', N'FATİH MEHMET', N'AYDEMİR', N'5453094646', N'fatihmehmet.aydemir@egm.gov.tr', N'POLİS MEMURU', N'HAKKARİ DERECİK SINIR KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEOBPan7LZS36D9Hh8HRBVYfScwqeMGQHpw6NRNqAn4MPdjb77BooNU2/Sf5+r09Ngg==', '2024-08-27 16:27:51.753', N'HAKKARİ DERECİK SINIR KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2887, N'433091', N'ADEM', N'ŞAHİN ', N'05414353466', N'adem.sahin22@egm.gov.tr', N'polis memuru', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEI5h+a9IPokgqw5nl0Kets4lBA+Vqpe0gbjuaI9qEOLiHmugFo4mnG1LSyMnOcfiwg==', '2024-09-05 10:05:02.290', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2889, N'463343', N'OKAN', N'BOSTAN', N'5468163846', N'okan.bostan@egm.gov.tr', N'POLİS MEMURU', N'HAKKARİ ESENDERE KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEAPpfTaP3nGGBITbkHptOihDV69t+BdKfj+I6or3wyOUViT/NShvRxA1LQ6HsCkG5g==', '2024-09-07 19:22:18.860', N'HAKKARİ ESENDERE KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2891, N'316757', N'MESUT', N'SİLİGÜNLÜ', N'05063510405', N'mesut.siligunlu@egm.gov.tr', N'POLİS MEMURU', N'İSKENDERUN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEOPEk5MefNwqtsNJTugMaF3borx0eDy97VpvXYvRmcZ3Spl8Cd6365h/3j8EOG7T9g==', '2024-09-10 08:23:24.183', N'İSKENDERUN DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2892, N'482772', N'ESRA', N'AKGÖZ', N'05344578442', N'esra.akgoz@egm.gov.tr', N'Polis Memuru', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEOMQso237yABj0DIToPeFsRestWRYbajEVgH9drkM8KWSEgXyczLl0rllvjhYAsH6A==', '2024-09-10 08:23:29.277', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2893, N'303390', N'ÖMER', N'ERAVCI', N'0552 442 15 18', N'omer.eravci@egm.gov.tr', N'POLİS MEMURU', N'KONYA HAVA LİMANI', N'25d760b60efd43688bb60261ed4f98d2.png', N'3', N'0', N'AQAAAAEAACcQAAAAEOJ+bmkGDu5HjAWEcD/boSY01guKpOMp2icLcpCgeSrBYyX/5tqaVVXCMWlPtCFNsg==', '2024-09-10 16:49:33.663', N'KONYA HAVA LİMANI', N'0', N'Student', '2026-04-09 00:55:35.387', 0, 1, 0, NULL, NULL),
            (2894, N'470061', N'ADEM', N'DOĞAR', N'05524373617', N'adem.dogar@egm.gov.tr', N'Polis Memuru', N'AĞRI GÜRBULAK KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEH7GYD63K/4geUMjjw/7YzOnp91Bc1rF02/ohEoOrVUFBDqHhVhL1pm6+0tNGnvzLQ==', '2024-09-10 16:49:38.413', N'AĞRI GÜRBULAK KARA HUDUT KAPISI', N'0', N'Student', '2026-04-08 18:55:43.187', 0, 1, 0, NULL, NULL),
            (2897, N'435965', N'MEHMET ALİ', N'GÜZEL', N'05366409780', N'mehmetali.guzel3@egm.gov.tr', N'Polis Memuru', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEBIqKEMFds/ThI5X8vIf/J5b5E5XbcW6QbdhFRa0Pyl6Kj/9Tej1rz/2pvtc0MX66A==', '2024-09-13 15:46:01.087', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'0', N'Student', '2026-04-08 06:49:55.563', 0, 1, 0, NULL, NULL),
            (2898, N'350090', N'KEMAL', N'ÖZER', N'05435874163', N'kemal.ozer2@egm.gov.tr', N'POLİS MEMURU', N'DİYARBAKIR HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEHqcIr2s66htGgFJs8PAqkNLYLnyfMPIPrriCK04eSzxg6sL2J73qhL4pmTzCPxINg==', '2024-09-14 19:21:36.410', N'DİYARBAKIR HAVA LİMANI', N'0', N'Student', '2026-03-31 00:48:18.523', 0, 1, 0, NULL, NULL),
            (2899, N'479314', N'HALİL', N'ZENGİN', N'5414901209', N'halil.zengin@egm.gov.tr', N'Polis Memuru', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPvoH1RoWglE48Fls9D7KX1bIt0kLTLo3iMZ+AzqLqwQ8WjUi9h2CPgVHt8z2i6iAg==', '2024-09-19 13:31:46.323', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'0', N'Student', '2026-04-09 15:43:44.657', 0, 1, 0, NULL, NULL),
            (2901, N'304041', N'HALİL', N'DURSUN', N'05068625986', N'halil.dursun3@egm.gov.tr', N'polis memuru', N'ISPARTA SÜLEYMAN DEMİREL HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEG5MWKQ8qizXyQQggWKh3YRDSpd2AzqBMBC/5t7SH+7kcYK2swKTrcQFFIjCXamENQ==', '2024-09-20 19:16:16.650', N'ISPARTA SÜLEYMAN DEMİREL HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2902, N'354317', N'emre', N'öztürk', N'05077509868', N'emre.ozturk7@egm.gov.tr', N'Polis Memuru', N'MUĞLA DALAMAN HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEEhWZKgeimgtswzKgokTHZN8H16sBniUt+cN3c0cBKvw8ahteUreMFLKna2NXA6OXA==', '2024-09-20 19:16:20.337', N'MUĞLA DALAMAN HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2904, N'399978', N'Halit', N'DELAK', N'05437617363', N'halit.delak@egm.gov.tr', N'POLİS MEMURU', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJa3ptwMdBEH2VqDRnmzGAMJSS1UGwhB/JqTvRcnarZpTTQ232MUEqW/4Rp3cwsHLw==', '2024-09-22 19:24:24.163', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'0', N'Student', '2026-04-07 18:56:48.120', 0, 1, 0, NULL, NULL),
            (2905, N'515079', N'FATMA NUR', N'KAYALI', N'5077173212', N'fatmanurinan1922@icloud.com', N'polis memuru', N'EDİRNE PAZARKULE KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPNN5GXWacd4bOyFhOTe3HQMeCaqt2HjYAN1wMjDfLCxfIOMyE5kihHYA0mKuI9tPg==', '2024-09-22 19:24:28.350', N'EDİRNE PAZARKULE KARA HUDUT KAPISI', N'0', N'Student', '2026-04-07 09:21:03.447', 0, 1, 0, NULL, NULL),
            (2906, N'409171', N'HÜSEYİN', N'ÜNLÜ', N'05542383551', N'huseyn_unlu@windowslive.com', N'POLİS MEMURU', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEEfINwJRqmPBwLPhwvNHAh5rmcOJPOR3kWdrihNtTwwmXY65p+UEUc7iaNTcXU5vEQ==', '2024-09-24 08:40:28.160', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2907, N'311556', N'SERHAT', N'AYDIN', N'05066133154', N'serhat.aydin3@egm.gov.tr', N'Polis Memuru', N'MUĞLA FETHİYE DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEF2CGbfeso2l/kNgR3wDhYFgc8D3T74z2oL3VOLrS6absQfhn4iii0xI5xhw8gO1PA==', '2024-09-24 12:12:56.923', N'MUĞLA FETHİYE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2909, N'527781', N'Enes', N'ÖZBEK', N'0 542 530 64 13', N'enes.ozbek2@egm.gov.tr', N'Polis Memuru', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEMdbQeVA7FyDGgjatJqE1ta9vMTO7n3El8HkEWV2GY5ZOzWtOb4ugGj/WAojYLBWgA==', '2024-09-25 08:30:37.647', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2920, N'489619', N'Fatma', N'KARAKUZU CENGİZ', N'0546 594 06 84', N'fatma.karakuzucengiz@egm.gov.tr', N'Polis Memuru', N'ZONGULDAK EREN DENİZ LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEOoA8fw5/2JqZWuZw2Pt7/27uj+4f9ZEEBmIqyJfjSeaOJ7e95yTCih/HHHq8m4aQA==', '2024-10-07 14:07:25.340', N'ZONGULDAK EREN DENİZ LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2921, N'371100', N'hüsamettin', N'küt', N'05535975972', N'husamettinkut@icloud.com', N'P.M', N'HAKKARİ ESENDERE KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEA8uBzIC8ItS/Fz5F4iJTznBdwSW9xVatv/kbtSmokf5SVGbSTZ+XKZZeETxbcZapA==', '2024-10-08 12:16:10.740', N'HAKKARİ ESENDERE KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2922, N'375474', N'özkan', N'özcan', N'5435627352', N'ozkan.ozcan2@egm.gov.tr', N'polis memuru', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAENLHHvALqcdJ0CYkxKs1a2C6i4Y7VwidghV/4FKPw9jzLdqTxmsueMdzQyJAsLvE5Q==', '2024-10-09 08:37:38.177', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2927, N'337138', N'MÜCAHİT', N'KÜÇÜKER', N'5428272639', N'mucahit.kucuker@egm.gov.tr', N'polis memuru', N'İZMİR ALİAĞA DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEEg8+ZXOCvReBY4iOH/l0eaTi7JmnP9v2UIc/YjCDz05YkIWXA72eLdx++LgRtFVvQ==', '2024-10-14 19:30:13.877', N'İZMİR ALİAĞA DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2928, N'345577', N'RAMAZAN ', N'ÖĞÜT', N'05352233543', N'ramazan.ogut2@egm.gov.tr', N'polis memuru', N'İZMİR ALİAĞA DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAENBLRjvrewR8dzpkE6ZSY4j54k8F9BCf6oQuECl8Mc0+/wsLMTVHCLCZQTCLfym+hA==', '2024-10-14 19:30:18.313', N'İZMİR ALİAĞA DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2929, N'348724', N'SELMAN', N'DUMAN', N'05075355005', N'selman.duman@egm.gov.tr', N'POLİS MEMURU', N'İZMİR ALİAĞA DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEAEBLuYGdX9MU7FXnDHHwCNnKTQAkm4X8x7yg3t1JjYnkfLhR8OKVJp2h3jZ7gcFOg==', '2024-10-14 19:30:23.440', N'İZMİR ALİAĞA DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2931, N'446103', N'Bahri', N'BOZKURT', N'05074415307', N'bahri.bozkurt@egm.gov.tr', N'Polis Memuru', N'Pasaport Kontrol Büro Memuru', N'', N'3,4', N'0', N'AQAAAAEAACcQAAAAEITlPUBseACaSCcejEDIVOSd0ekVSyGxnABSMwIj2QWVqEVxb6ShwoYgJSQ6hp4mNQ==', '2024-10-15 14:23:58.333', N'AĞRI GÜRBULAK KARA HUDUT KAPISI', N'0', N'Student', '2026-04-08 11:51:03.493', 0, 1, 0, NULL, NULL),
            (2932, N'447132', N'ÇAĞAN ', N'SEZGİN', N'05369907160', N'cagan.sezgin@egm.gov.tr', N'Polis Memuru', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEN6061SlHk5PK+8UzX0qYYQckJrW0P0KEDkuoj4ecllgIzzDDJ2KVXYZSKSQ0cruwA==', '2024-10-22 19:16:38.320', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2935, N'448154', N'UFUK TAŞKIN PİR', N'ÖZTÜRK', N'05392440896', N'ufuktaskinpir.ozturk@egm.gov.tr', N'POLİS MEMURU', N'HAKKARİ ESENDERE KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEDCKeQMsoPxZFWnAEwKdOm6gc15vSfgBGlWoU9rRJ4BR/XVFJqgV3LKneeVVnbTwmg==', '2024-11-02 19:30:33.563', N'HAKKARİ ESENDERE KARA HUDUT KAPISI', N'0', N'Student', '2026-04-07 11:00:21.833', 0, 1, 0, NULL, NULL),
            (2936, N'545881', N'HAMZA SEMİH', N'ALEMDAROĞLU', N'05069093797', N'hamzasemih.alemdaroglu@egm.gov.tr', N'polis memuru', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEIco42ebESF6QuaHfktwPe2X3zUGqlakSE+nVz45IJOWVqzHF+0/nV/Sn5Ua4OXd/w==', '2024-11-02 19:30:37.643', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2937, N'520021', N'SEMİH', N'BEKİL', N'5061547010', N'semih.bekil@egm.gov.tr', N'POLİS MEMURU', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEC5Cgb+jUUajuZO115k4JUJSFfIHiwe+jGbG2I2qLlAJtUcFYXBOA0d0DEE6PvvWww==', '2024-11-06 09:37:39.210', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-02 10:43:53.267', 0, 1, 0, NULL, NULL),
            (2939, N'543685', N'Hatice', N'GÜVEN', N'05412022807', N'haticegvn03@gmail.com', N'Polis Memuru', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEKHBAnVjU9cYbAAxSfrfzfSq8Oq2bTHdGCMDdDTZigM7lbfRlfBaaS3phcoXLLKSVg==', '2024-11-07 11:40:56.957', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'0', N'Student', '2026-03-31 10:34:37.360', 0, 1, 0, NULL, NULL),
            (2942, N'547164', N'İSA', N'SARIKAYA', N'5457843224', N'isa.sarikaya2@egm.gov.tr', N'POLİS MEMURU', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEMdjWidPKV7z/m3/mY6gkzlUTFK/uiLuDntyfuVAjDzlZh4x40bvDeW/d2/ChrD+AQ==', '2024-11-08 15:37:29.943', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2944, N'475010', N'oğuzhan', N'köğçe', N'5063573058', N'oguzhan.kogce@egm.gov.tr', N'Polis Memuru', N'HATAY İSKENDERUN EKİNCI DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEFvSL533Q862rED5yfXip/1slU0E147htcBAt0XINQr8rQGXGZNbK8542aE7p+56Ww==', '2024-11-17 19:17:35.123', N'HATAY İSKENDERUN EKİNCI DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-05 23:57:59.450', 0, 1, 0, NULL, NULL),
            (2946, N'442269', N'Bedirhan', N'AKDOĞAN', N'05301290074', N'bedirhan.akdogan@egm.gov.tr', N'Polis Memuru', N'IĞDIR DİLUCU KARA HUDUT KAPISI', N'5237c53a112646edafda2375898d88dd.jpg', N'3', N'0', N'AQAAAAEAACcQAAAAEMLWdVm6Phez0+CzgSdktXy+I1u7deXlrPgQiP3RSmjssTMY4qmS6ODGlG8GgdbgMw==', '2024-11-19 19:22:15.047', N'IĞDIR DİLUCU KARA HUDUT KAPISI', N'0', N'Student', '2026-04-07 20:15:13.833', 0, 1, 0, NULL, NULL),
            (2947, N'498061', N'ALİ', N'AKYAPI', N'05330771001', N'ali.akyapi@egm.gov.tr', N'POLİS MEMURU', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEIzh+UKy6M9CjGfHYHuXpOG21VIzduwT+mLrb5gRdXqkzXA+L34ttM27NCc0jZzuCQ==', '2024-11-20 10:17:11.683', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2948, N'412971', N'VOLKAN', N'GÜLER', N'05412959265', N'volkan.guler3@egm.gov.tr', N'polis memuru', N'SAMSUN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAELwMxs4N01bjugfmR43s5em/EzJvKTnQMHYbv6b3QlJiphSc4eEXle6DFIsRbR1kew==', '2024-11-22 10:20:15.520', N'SAMSUN DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-08 08:34:23.897', 0, 1, 0, NULL, NULL),
            (2949, N'441282', N'ERSİN', N'ATASOY', N'05419350934', N'atasoy.ersin@egm.gov.tr', N'Polis Memuru', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEOznAqaL//22dRYcak6j94sD0Y40gzZsFRCjnf/p+p2cBWeuCVvuj4TE6hdUoNQxDw==', '2024-11-22 10:20:19.643', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'0', N'Student', '2026-04-06 08:35:33.260', 0, 1, 0, NULL, NULL),
            (2950, N'439343', N'TOLGA', N'KURAN', N'05313741370', N'tolga.kuran@egm.gov.tr', N'polis memuru', N'EDİRNE HAMZABEYLİ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJK42u0jVEak4FD7YUE1yH5atkI76B7Y8fbnPb1PgVL11cH3y+cOuGietvT3TkwaEg==', '2024-11-23 08:38:42.600', N'EDİRNE HAMZABEYLİ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2951, N'442674', N'serkan', N'karabulut', N'5532122730', N'serkan.karabulut4@egm.gov.tr', N'polis memuru', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEOSgc35opyAVC655Okn0pxxBLVAeNsJDe9g/8xXsyHVnrcnbg+xbzpTkRJiUVko6Og==', '2024-11-23 08:38:46.537', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', '2026-04-04 13:55:03.880', 0, 1, 0, NULL, NULL),
            (2952, N'464124', N'YUSUF', N'GEVŞEK', N'05309218294', N'ysfgvsk@gmail.com', N'Polis Memuru', N'ARTVİN SARP KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAECiEhxa+qYsJ/Ev3hwNsKq3jZKRdZYmnyVat92ZbzYzqn8mWJXaqD8x7IULzY/WxbA==', '2024-11-23 08:38:50.443', N'ARTVİN SARP KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2953, N'504159', N'HAKAN', N'KOÇ', N'5076641021', N'hakanmoctff.28@gmail.com', N'Polis Memuru', N'SAMSUN ÇARŞAMBA HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEFM4XTHzqy1m8VV801M4iJ3zz5JZ1wWL4vfr2YIanjjhpeLyXePcDT5/KdzwSpv95g==', '2024-11-23 18:24:07.553', N'SAMSUN ÇARŞAMBA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2956, N'450780', N'HÜSEYİN', N'YETİMOĞULLARI', N'5434941989', N'huseyin.yetimogullari@egm.gov.tr', N'POLİS MEMURU', N'EDİRNE HAMZABEYLİ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEL3Su/iUgoQGZOsZYhh22qp3t+hE64HQJU68tHwquNQ1YqxZCzsTa9PNq1ZWe++pxw==', '2024-11-28 15:40:45.213', N'EDİRNE HAMZABEYLİ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2957, N'479077', N'MEHMET', N'ÇAKIRGÖZ', N'5388978887', N'mehmet.cakirgoz3@egm.gov.tr', N'POLİS MEMURU', N'EDİRNE HAMZABEYLİ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEBVdHyTw+fA4PlpypZTxp4fHQL8y3v8E5Hke4KypVGKaXW9jgJCZResGmXmZBIjcGw==', '2024-11-28 15:40:48.213', N'EDİRNE HAMZABEYLİ KARA HUDUT KAPISI', N'0', N'Student', '2026-04-08 04:16:07.450', 0, 1, 0, NULL, NULL),
            (2959, N'298676', N'ÖZAY ', N'AYDIN', N'5067637200', N'ozay.aydin@egm.gov.tr', N'Polis Memuru', N'TRABZON HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEAf1auvqHTekhB+CFZ1IAP1/zF6x9Y4CQV0H46jiOx6UwBELfEOd1FyBy/HSVg++mQ==', '2024-12-02 19:13:51.570', N'TRABZON HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2960, N'547496', N'ABDULLAH', N'SİMİR', N'05455724236', N'simir39@icloud.com', N'polis memuru', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEAMdV63VhKLXEnQY7eMlc5UAiDTZaUg5LilTSJQudYZSLJ2+pWn/nh84vZDt7I7qfA==', '2024-12-03 11:56:16.063', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'0', N'Student', '2026-04-04 13:22:59.080', 0, 1, 0, NULL, NULL),
            (2961, N'435970', N'İBRAHİM', N'KOŞAN', N'5550015818', N'ibrahim.kosan@egm.gov.tr', N'polis memuru', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEMqZ9GUqcOtxKNjlFfHnU49lN728lEidooyAm1N1cUBa8N1YCNDm5Zb75YomueC4Gw==', '2024-12-04 09:40:10.757', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'0', N'Student', '2026-04-07 19:41:17.000', 0, 1, 0, NULL, NULL),
            (2962, N'498539', N'orhan', N'kar', N'5492751453', N'orhan.kar2@egm.gov.tr', N'polis memuru', N'İSTANBUL HAYDARPAŞA DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJgk2rpplq28N+rvkN8RkvukQLZefv5zHdUalxStF1EAuh0KOBbwr9ek3i64ZGjP7w==', '2024-12-04 09:41:31.473', N'İSTANBUL HAYDARPAŞA DENİZ HUDUT KAPISI', N'0', N'Student', '2026-03-31 20:49:05.957', 0, 1, 0, NULL, NULL),
            (2963, N'545908', N'Tolga', N'SELVİLİOĞLU', N'5456353170', N'selvitolga@icloud.com', N'Polis Memuru', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEKSKPheXrGScKo9YEF3gz/A9Zpk2y9oyunGO5MoIMAjOV3CgSivoL31fbirL45/+Pg==', '2024-12-04 09:42:21.830', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'0', N'Student', '2026-03-31 12:52:59.517', 0, 1, 0, NULL, NULL),
            (2964, N'458796', N'Emre', N'Görentaş', N'05446048677', N'emre.gorentas@egm.gov.tr', N'polis memuru', N'HAKKARİ ESENDERE KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAELyMPAqZZ87niWebC3CRKbeTRILCy0AEk8R2aDokO0CPRkiV/3SV6FZ1/QjGHj6cCg==', '2024-12-05 09:46:00.170', N'HAKKARİ ESENDERE KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2968, N'333125', N'YUSUF', N'TEPE', N'05077612623', N'YUSUF.TEPE@EGM.GOV.TR', N'POLİS MEMURU', N'SAMSUN ÇARŞAMBA HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAENLbrj/t414IY7GsQ+b/xT9lLehrDgBmgepfDakOSC4abrOl73ZXCrsexlaJC1esoA==', '2024-12-15 19:17:47.347', N'SAMSUN ÇARŞAMBA HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2969, N'396499', N'UĞUR', N'BİRER', N'05530862246', N'ugur.birer@egm.gov.tr', N'POLİS MEMURU', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEO1bzPj9Nu4n7GMflO+ilpN+ow/5hddL0P8UH+TZ6BzsWv/AW7R7yzmTL7kdZLP2Tw==', '2024-12-15 19:17:51.473', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2970, N'427878', N'MEHMET CAN', N'ÇOLAK', N'5059727668', N'mehmetcan.colak@egm.gov.tr', N'Polis Memuru', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'9e20f05ebeed4d22804766977399da6d.png', N'3', N'0', N'AQAAAAEAACcQAAAAEAeFkdVH2smOvsDmfHQkW+Ijw0MeyLdX3IxLHqvg1KmIa/sLhZelfT8B/XgHln3CzA==', '2024-12-17 10:11:56.620', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'0', N'Student', '2026-04-08 16:26:58.647', 0, 1, 0, NULL, NULL),
            (2971, N'520205', N'ÖMER', N'ÖNCÜ', N'5530219155', N'omer.oncu@egm.gov.tr', N'Polis Memuru', N'EDİRNE HAMZABEYLİ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEHxcKP16ZW8+tNPeKavwJukBcHZcbr5uJZofl0huNiupUNQzD7UpQTR11VMwDI1s4Q==', '2024-12-17 12:23:47.507', N'EDİRNE HAMZABEYLİ KARA HUDUT KAPISI', N'0', N'Student', '2026-04-07 13:01:05.800', 0, 1, 0, NULL, NULL),
            (2972, N'284562', N'ALİ', N'YURDAGÜL', N'05058942294', N'ali.yurdagul@egm.gov.tr', N'POLİS MEMURU', N'TRABZON HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPZAMLaEK4klkz6oad+dwCseTDdDriwB8m5KppFdhnkerheSmU0JhfXfobf6TGZcKg==', '2024-12-19 09:18:15.393', N'TRABZON HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2973, N'376963', N'FATİH', N'ŞEKER', N'5377201830', N'fatihseker0404@gmail.com', N'Polis Memuru', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEHBFR9/OAj6i46aD02681hUn8S/RjPHdvmsZzKPr/KuQP6BD0jyihxLONhtXzLR5zQ==', '2024-12-19 09:19:36.857', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2974, N'543785', N'Reyhan', N'GÖKTEKİN', N'05384666791', N'reyhan.goktekin@egm.gov.tr', N'POLİS MEMURU', N'MERSİN TAŞUCU-SEKA DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEKklfnyJWgK88hoPytBjDo2bbzvGA9UxcWqYSgxOMyqDaZzXBWRcF4IrfMp3FCm38w==', '2024-12-20 11:49:07.903', N'MERSİN TAŞUCU-SEKA DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2975, N'441329', N'Mehmet', N'oruç', N'05453800738', N'mehmet.oruc12@egm.gov.tr', N'POLİS MEMURU', N'HAKKARİ ESENDERE KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEI5mQ6Jm9ffvfqxHsvs47DvXJyhcxuUsk4+nEWO+9gWvZ9GqAq8AKHXjj16wcolNzg==', '2024-12-26 14:51:43.887', N'HAKKARİ ESENDERE KARA HUDUT KAPISI', N'0', N'Student', '2026-04-07 19:15:30.297', 0, 1, 0, NULL, NULL),
            (2976, N'501177', N'SALİH', N'ÖZKAN', N'5522322975', N'salih.ozkan2@egm.gov.tr', N'POLİS MEMURU', N'ÇEŞME DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEANRlO0AGDVaTfXTc5vIbtgd+qefKXAn3Xdv6/rl5PMwXh07dZ+V72GTkaqdLMOV0Q==', '2024-12-26 14:51:49.247', N'ÇEŞME DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2977, N'314732', N'yunis ', N'demir', N'05558041882', N'pesimistpolis@hotmail.com', N'polis memuru', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEBQUrLk7spD7Fuq6fVHQhk6mQEtfMbN9mgkfCDgiDmqezOBhyKvwqctttQP+gKG7Ww==', '2024-12-31 09:11:59.903', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', '2026-04-09 12:48:04.857', 0, 1, 0, NULL, NULL),
            (2979, N'401484', N'KUBİLAY HAKKI', N'MARANGOZ', N'5530249559', N'401484@egm.gov.tr', N'Polis Memuru', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'0159b40f41974dbe831b6773bfc5b0e3.jpg', N'3', N'0', N'AQAAAAEAACcQAAAAEBOxAHSRkOaRG3CNnGX8/hMmGwOVNx2KljBIs+u/rLzE+Vdp6oZ366xwzRE5MgHsnQ==', '2024-12-31 09:12:05.543', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'0', N'Student', '2026-04-06 19:27:19.247', 0, 1, 0, NULL, NULL),
            (2981, N'372006', N'hamza', N'yılmaz', N'5534634592', N'hamza.yilmaz@egm.gov.tr', N'polis memuru', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEMitz8X6HIH2wnDNUCklcRNc6YYJMaFpIltGIBysOH3YWqcKd2r4ATm3m0pFMI3qEQ==', '2025-01-02 10:23:44.297', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', '2026-03-31 10:58:35.487', 0, 1, 0, NULL, NULL),
            (2982, N'442521', N'Furkan', N'CİHAN', N'05385085011', N'furkancihan4@gmail.com', N'polis memuru', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEBNAsCjpy0rrv76PbZUa1IGRvR3FEPyJvWvcsQdqqJxv/zevkmyiDNajz/nWUgpMmw==', '2025-01-02 10:23:48.703', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2983, N'304466', N'ilyas', N'ERSOY', N'05064509424', N'ilyas.ersoy@egm.gov.tr', N'Polis memuru', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAELym2QGbVs2gEscKNK9MYls+Nq3MqIRrlRIRW4p8nsMmXlCGbDNGMdAFhLKZlPxoTg==', '2025-01-02 16:30:28.957', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2985, N'339347', N'ERKUT', N'YAMAÇ', N'5438705435', N'erkut.yamac@egm.gov.tr', N'POLİS MEMURU', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEGng5mBMjaOuz3NKJP8hfxDUvNUpUxRtxYYkbSi/xVonbx+dKlvLkgPYTBwNshHl1g==', '2025-01-02 16:30:34.253', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2986, N'450423', N'tuğba ', N'koç', N'05538666389', N'tugba.koc@egm.gov.tr', N'polis memuru', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEA5fNJOF7XlTEtYg/HWrCRMseon6kUkO+xzLHqDMH2xnAFgI+OahFcafwHihYbZrZQ==', '2025-01-02 16:30:36.847', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2987, N'495461', N'ŞİNASİ', N'BOLAT', N'5369962192', N'sinasi.bolat@egm.gov.tr', N'POLİS MEMURU', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAELSH7yitvM5dP139zQ5BKdjFVsieZs/SGRdkEVDV6GX3BmKUcvI9kUJUhIoIadPYTQ==', '2025-01-02 16:30:38.860', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2989, N'396372', N'Mustafa', N'KARAARSLAN', N'05425883367', N'mustafa.karaarslan5@egm.gov.tr', N'Polis Memuru', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEC2MvBXOuEPRx6hD58zSerZ4NA2ktwxyEXStfFjoquLMYLPOao8QSPItO7uwdakY5A==', '2025-01-08 09:01:55.407', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'0', N'Student', '2026-04-01 01:24:09.287', 0, 1, 0, NULL, NULL),
            (2990, N'344334', N'Osman', N'Sönmez', N'5532422018', N'osman.sonmez2@egm.gov.tr', N'polis memuru', N'HATAY İSDEMİR DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAECYymmkC0frVX75WHSMo4Lzk2mFb/ip6HOGH1xepgkoHO3otGwhRI/1tfkqYn68qqg==', '2025-01-10 13:23:43.653', N'HATAY İSDEMİR DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2992, N'545448', N'Enes ', N'TAŞBAYIR', N'05385482043', N'enes.tasbayir@egm.gov.tr', N'Polis Memuru', N'MERSİN TAŞUCU-SEKA DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEFtctWqCd3eouF4l06rJrVvXOjloCAsm2e+1WfsGEP/iEDaGf8jlMluj34I56jRGlQ==', '2025-01-13 12:42:41.487', N'MERSİN TAŞUCU-SEKA DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-09 11:26:33.467', 0, 1, 0, N'2', '2026-04-01 10:44:37.070'),
            (2996, N'424840', N'ÖMER', N'KARABUDAK', N'5544513150', N'omer.karabudak@gov.tr', N'polis memuru', N'ÇEŞME DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEE2D+wOhw6+7/pitXuSCweXy6dXhiu8gwsCMHGeH4Tp08MAkSpqKFahvdrlMaReDOQ==', '2025-01-16 12:37:25.497', N'ÇEŞME DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2998, N'476066', N'şaban', N'köksal', N'5309245228', N'saban.koksal@egm.gov.tr', N'polis memuru', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAECmmpNzuRujrpT9+pgd9LIgsj9E6VSJr5DkebdY8nNJvkRkGs+cEZHocZVbEs0jemQ==', '2025-01-17 09:31:12.017', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (2999, N'545051', N'VEYSEL', N'KARAARSLAN', N'5376878821', N'Veysel.karaarslan@egm.gov.tr', N'polis', N'İSTANBUL ZEYTİNBURNU DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAENrem7EIt0W4PoJxv/B8ErzHLDGn/gBoQznW7CHyHRQOwRE6i2QuwPrJZ8+cImszWA==', '2025-01-17 09:31:54.547', N'İSTANBUL ZEYTİNBURNU DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-08 00:40:07.927', 0, 1, 0, NULL, NULL),
            (3000, N'245263', N'ibrahim', N'yıldırım', N'5055420620', N'ibrahim.yildirim156283@egm.gov.tr', N'polis memuru', N'TEKİRDAĞ ASYAPORT LİMAN TESİSİ DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEKgZ1d64ncTgTScaesPHMjsxtWzpabCFZD8PIcyH5llTCl2e0Q6MLj1AmJCTOnXLGQ==', '2025-01-20 10:56:58.013', N'TEKİRDAĞ ASYAPORT LİMAN TESİSİ DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3001, N'475055', N'BÜLENT', N'HAZIRLAR', N'05345980488', N'bulent.hazirlar@egm.gov.tr', N'polis memuru', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPmGJTat6pQ6cbbjh8NixqFzvzGf1bJJIdcios5jHK8Zg7umUt8vH3+KYBNYec1bSw==', '2025-01-20 10:57:02.857', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3002, N'543560', N'HATİCE', N'KOCA', N'05360635259', N'hatice.koca2@egm.gov.tr', N'Polis Memuru', N'EDİRNE KAPIKULE KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEMxhzk+u/jBot12vO4p7gkkyhpQFh31mKdKe/yU5VEniVbD8U9cPxNJouzrXhNUXug==', '2025-01-20 10:57:07.747', N'EDİRNE KAPIKULE KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3005, N'360920', N'Levent', N'Çıvgın', N'05365968679', N'levent.civgin@egm.gov.tr', N'PM', N'HAKKARİ ÜZÜMLÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEGnFH8wx1bX5i1RKLxJmXbDo02OyLJTjjyv4EAfmEZlECGz01eLy49TzjnDZ+RdpUQ==', '2025-01-23 16:20:55.937', N'HAKKARİ ÜZÜMLÜ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3006, N'546449', N'MELİKE', N'AÇIKGÖZ', N'5398972029', N'melike.acikgoz@egm.com.tr', N'polis memuru', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEBunnalhf2xXCNhhvc8FpvdzR9JwAtRd9kYQx5ALolpiBfyq01DzHRklTIDYonU6sA==', '2025-01-27 09:26:00.897', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3008, N'543781', N'KADER', N'ZEYTUN', N'05540243617', N'kader.zeytun@egm.gov.tr', N'polis memuru', N'EDİRNE KAPIKULE KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAECYaVmtjoy05TYaCzpYCmr2l1QBpCeBOx8NB14CJCPg+g1jvEFHSPB2Ho+V73A1ArQ==', '2025-02-04 09:54:31.897', N'EDİRNE KAPIKULE KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3009, N'527460', N'aslıhan', N'ovuz', N'5537455318', N'aslihan.ovuz@egm.gov.tr', N'polis memuru', N'TRABZON HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEF2PylOOF0Jifp6dH2Tc+4K47KMLvvPqxdAFmQQ9c3/ytyp0T+yxuvB2rkXiybVeFQ==', '2025-02-04 09:55:31.690', N'TRABZON HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3010, N'316525', N'mehmet', N'kılınç', N'5317925027', N'mehmet.kilinc3616e6@egm.gov.tr', N'polis memuru', N'HATAY İSKENDERUN ATAKAŞ LİMANI DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEAXFXIWiLNkGlFMwMsJ5nujYtyqF+KdoduPXfYiEdYm9tkPxUkXw7PioP+KUuQ29kw==', '2025-02-06 10:22:11.283', N'HATAY İSKENDERUN ATAKAŞ LİMANI DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3012, N'511299', N'ÖMER FARUK', N'AKDEPE', N'05360326863', N'omerfaruk.akdepe@egm.gov.tr', N'polis mem', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEDpcaphPKRyEHxUsUh8hHXS9FQBv2X20HJGFdwvUnqUp45OGRO30H4ViC4EQz4Xomg==', '2025-02-07 14:07:36.793', N'HATAY CİLVEGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3014, N'385139', N'ŞİRİN DURMUŞ ALİ ', N'TAŞKIR', N'5078669294', N'sirindurmusali.taskir@egm.gov.tr', N'Polis Memuru', N'ANTALYA FİNİKE DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEHGw3IHV3/NBnJGoy+5dvQK6h+Qhyb84EtAL3ByoIA3s0hBwQazL9qyMN+E845QMvw==', '2025-02-11 10:45:21.983', N'ANTALYA FİNİKE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3016, N'267872', N'AHMET', N'ÖZER', N'5074434306', N'ahmet.ozer10@egm.gov.tr', N'POLİSMEMURU', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEB9BFhGVWJRU28eM40ZcNfhbFr6Ry+ls59MPtlkrqSGIe6OddJRh8hXEwqFeQ8vI8w==', '2025-02-12 09:39:28.183', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', '2026-04-03 14:24:49.420', 0, 1, 0, NULL, NULL),
            (3017, N'354106', N'TOLGA', N'HACIOĞLU', N'0507 410 00 38', N'tolga.hacioglu@egm.gov.tr', N'POLİS MEMURU', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJVrIwgMUzE5PmbN8mo7MUjOeo4cCjqSWtwcnoFbkdrYzH7zIA5AeRS/hzsaNTnZ/g==', '2025-02-14 15:26:28.453', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'0', N'Student', '2026-04-09 13:25:08.827', 0, 1, 0, NULL, NULL),
            (3021, N'545801', N'Asena', N'YILMAZ', N'5010800780', N'asene.yilmaz@egm.gov.tr', N'polis memuru', N'ÇEŞME DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEK+DKzgROMXNUiZt/+/w73glPOsyrm/aipLL1cNpH8bHzwFdXonRtOKKPLpAvIu4AQ==', '2025-02-17 10:52:01.697', N'ÇEŞME DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3023, N'417935', N'abdullah', N'demir', N'5445437927', N'abdullah.demir10@gov.tr', N'polis Memuru', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAENnBfqPSVpKIR0NRrLyGjHKrfLj9oIy+QrggJCxLOLAZokYYOBfu2Eb2rcT733Hsqg==', '2025-02-18 11:43:52.687', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3024, N'443448', N'SAMET', N'KURT', N'5428101809', N'samet.kurt3@egm.gov.tr', N'Polis Memuru', N'ANTALYA KAŞ DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEL1ywzczTlAMUz00fJ0tfmFsBuEGEcowxx9ebMfLnMb/E0aCrSDCeumPJFspA4RA1A==', '2025-02-20 10:21:24.493', N'ANTALYA KAŞ DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3025, N'443826', N'EMRE', N'AYDIN', N'5050707373', N'emre.aydin19@egm.gov.tr', N'Polis Memuru', N'AĞRI GÜRBULAK KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEESDa+SEpN1Bm6VHc2dneHWpO3K77pwyutFlRwv0vIzNDXgq8j0l3blX55sTqLHtaA==', '2025-02-20 10:21:46.820', N'AĞRI GÜRBULAK KARA HUDUT KAPISI', N'0', N'Student', '2026-04-04 14:19:47.353', 0, 1, 0, NULL, NULL),
            (3028, N'476088', N'AYTUNÇ ', N'BAKIRCIK', N'0544 259 9654', N'aytunc.bakircik@egm.gov.tr', N'POLİS MEMURU', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEMYQDR2xk6VRS51qrbfr+ZSH2rCNQes3yve5cndOZnkFPYpVqUDR7flhEluKPLXqmg==', '2025-02-21 09:24:14.957', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'0', N'Student', '2026-04-03 15:31:35.557', 0, 1, 0, NULL, NULL),
            (3029, N'535589', N'Akın', N'GÖKBAYRAK', N'05342310002', N'akin.gokbayrak@egm.gov.tr', N'PM', N'İSTANBUL KARAKÖY DENİZ BÜRO AMİRLİĞİ', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEDLKhlz8JAL66icBfsxQ72wGJrPqJr6s7CkHC9yxMW9f4Dhm5ZYJK4WrfaodwaR+Ww==', '2025-02-21 09:24:26.253', N'İSTANBUL KARAKÖY DENİZ BÜRO AMİRLİĞİ', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3032, N'475581', N'murat', N'kavak', N'05524284156', N'murat.kavak4@egm.gov.tr', N'polis memuru', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEDYtgwX+WnKscvIwol4hvfSKtjkVRMUcxmZ7eLAqiKrRxVleJV0fCCjdqD9V+GYVXA==', '2025-02-28 10:59:20.087', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3034, N'332101', N'ORHAN', N'SONEL', N'05077611836', N'orhan.sonel@egm.gov.tr', N'Polis Memuru', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAENT8K4RJu+SBFNKShcjK9Uyoo3cSQBSO8Z2+XGpK382J6+99GtN7Z6fo/I5LdgWXCg==', '2025-03-05 11:28:32.213', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3035, N'353256', N'Sercan', N'Korkmaz', N'05456675261', N'sercan.korkmaz@egm.gov.tr', N'Gemi Adamı', N'ZONGULDAK- EREĞLİ DENİZ BÜRO AMİRLİĞİ', N'', N'3', N'0', N'AQAAAAEAACcQAAAAECa1jMY8C+VSu2e4K1hiBd+h6bzhnreNh6GevTV1TkINtfSdgi+48LsV5SZBquhl6Q==', '2025-03-06 13:04:42.407', N'ZONGULDAK- EREĞLİ DENİZ BÜRO AMİRLİĞİ', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3039, N'376904', N'ismail', N'Güvendiren', N'5061006005', N'ismail.guvendiren@egm.gov.tr', N'Polis memuru', N'ARTVİN SARP KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEL1cxG1ETL1Q4Z6a6t9iTQj2IHc42wr9tE61vi6ynFI7aT8F4mJfUWyzXVnxSu3k2A==', '2025-03-19 11:29:14.843', N'ARTVİN SARP KARA HUDUT KAPISI', N'0', N'Student', '2026-04-03 08:28:06.557', 0, 1, 0, NULL, NULL),
            (3040, N'464874', N'Fikret', N'Yıldız', N'5529322506', N'fikret.yildiz6@egm.gov.tr', N'polis memuru', N'HAKKARİ DERECİK SINIR KAPISI', N'3b134ba917584c3cae203a6ef8bca049.jpg', N'3', N'0', N'AQAAAAEAACcQAAAAEABg9um5KbWyejztT0yVK4S/8GJK8ceFFDqlDZvsy4DpQ/icH5jGT30hdspXXpiRmQ==', '2025-03-19 11:30:17.297', N'HAKKARİ DERECİK SINIR KAPISI', N'0', N'Student', '2026-04-07 08:54:52.533', 0, 1, 0, NULL, NULL),
            (3044, N'537889', N'Mehmet Tunahan', N'Gelen', N'05378821288', N'mehmettunahangelen@egm.gov.tr', N'Polis Memuru', N'İSTANBUL KARAKÖY DENİZ BÜRO AMİRLİĞİ', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEEnSUkb4DBxhVHBoE44vcm+hZ9AQ/5XXocKPZWFp+1WqZXnAZUuxj/LMu8CBsnhylA==', '2025-04-05 11:53:05.227', N'İSTANBUL KARAKÖY DENİZ BÜRO AMİRLİĞİ', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3045, N'424130', N'HACI', N'KILIÇ', N'0555', N'haci.kilic5@egm.gov.tr', N'Polis Memuru', N'ANTALYA HAVA LİMANI', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEBPGiRyU3Uf0vadt8a0Cx8tbDMhz8JgbdiiC3+zRy1CHAs7gv93eQeAegCWPPYUEFw==', '2025-04-07 15:07:29.607', N'GÖÇMEN KAÇAKÇILIĞIYLA MÜCADELE VE HUDUT KAPILARI DAİRE BAŞKANLIĞI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3051, N'547044', N'Cansu', N'YILMAZ', N'05419649082', N'cansu.yilmaz7@egm.gov.tr', N'polis memuru', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEAuF1Suv78wlBE2tUVJD3j1ghsBNUXNbz4qfMR3VxiygRgxP1bdHWNwZ4fSRRbIbVg==', '2025-04-21 10:08:15.643', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3053, N'478341', N'oğuzhan', N'SEYHAN', N'05010016716', N'oguzhan.seyhan3@egm.gov.tr', N'polis memuru', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAELJkjI/PD1WmnZJ9Hk1yljEjNXNk390bIjVmx38iinWLZ+a+oz9pXU4wovoEMhrnIg==', '2025-04-22 09:30:49.397', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3054, N'475244', N'ZEKİ', N'ATEŞ', N'05464250473', N'zeki.ates4@egm.gov.tr', N'polis memuru', N'EDİRNE HAMZABEYLİ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEOvXqfMvWw5cdTX10YddGdfOdvIxA+Mmwd8cAHY1+i0C0bcb+13XqlwpUaHpxMipRg==', '2025-05-02 11:02:43.183', N'EDİRNE HAMZABEYLİ KARA HUDUT KAPISI', N'0', N'Student', '2026-04-09 02:48:44.463', 0, 1, 0, NULL, NULL),
            (3056, N'308388', N'ALİ', N'DURSUN', N'05066572722', N'ali.dursun3@egm.gov.tr', N'POLİS MEMURU', N'ELAZIĞ HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEMLV/d1HK0Wkm0XLHwTI9tsfrKU5LUnZuCL7l7xCa6GmkR1W3BZi0mxBDMK+ZgijKw==', '2025-05-12 09:58:26.133', N'ELAZIĞ HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3057, N'381303', N'Mustafa', N'EKER', N'05556135490', N'mustafaeker2034@gmail.com', N'Polis Memuru', N'DENİZLİ ÇARDAK HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEOT2r7Hoj2IiTlw60Ld0Km09qpPGCQIBBBAoA1LE8965RxaGzkyCkytTuix2cPRGDA==', '2025-05-12 09:59:25.210', N'DENİZLİ ÇARDAK HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3061, N'547476', N'METİN', N'DİNLER', N'05078201696', N'metin.dinler@egm.gov.tr', N'POLİS MEMURU', N'İZMİR ALİAĞA DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJ4rmN5q/2Nn7W5C5uGKEPwH7Ygau4ijmxgNwVC24wyGRQyr1he17zrB84USPT6AaQ==', '2025-05-13 13:22:37.143', N'İZMİR ALİAĞA DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3062, N'263013', N'Mehmet ', N'ÇELİKER', N'05052553462', N'mehmet.celiker@egm.gov.tr', N'Polis Memuru', N'İZMİR DİKİLİ DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAELjOjRnMZxGXyPpT6Nw29mIh5SKvLOQ9i5mQ8MI/4vpsit1IhPVr8ApfJTcJxIMGeQ==', '2025-05-15 14:20:22.510', N'İZMİR DİKİLİ DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3063, N'545951', N'Mehmet', N'YILMAZ', N'05467902933', N'mehmet.yilmaz95f95@egm.gov.tr', N'Polis Memuru', N'İZMİR DİKİLİ DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEI0xlanu17e1q43fcAb3LnAdmu5QCw1ui2lvU5kF4BAF71ZGdsamuYzx+LQeS/zMUg==', '2025-05-15 14:20:25.073', N'İZMİR DİKİLİ DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3068, N'545455', N'AHMET', N'KAYA', N'5520995121', N'ahmet.kaya71162@egm.gov.tr', N'polis', N'İSTANBUL ZEYTİNBURNU DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEB665Vb6yN5VOTOYOZbKM6w8oHJ8enwpF/MdtI7G+z/v/J8RSV+d8UY93NhKHI40Pg==', '2025-05-20 09:23:48.060', N'İSTANBUL ZEYTİNBURNU DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3070, N'323129', N'ilkay', N'küçükkale', N'5535929148', N'ilkay.kucukkale@egm.gov.tr', N'Polis memuru', N'ORDU ÜNYE DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAECovCUDlyYUIK7AbzNU3mucQ6dorM8QRtgQ4Cw7U5pGyVvnyXyf0QUWKlqkQcGBisg==', '2025-05-22 16:19:51.240', N'ORDU ÜNYE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3071, N'396315', N'YAVUZ', N'KURTGÖZ', N'5433262208', N'yavuz.kurtgoz@egm.gov.tr', N'polis memuru', N'İSTANBUL TUZLA DENİZ HUDUT KAPISI', N'4b9ca6f6ef304ddda71321a0b97adf18.png', N'3', N'0', N'AQAAAAEAACcQAAAAEEzAumasPzUVoHhjGQjIGVwOvBtYSVxZUde190S1RMBcnxWpHdqPcMcV5K++a2zhmw==', '2025-05-22 16:20:27.940', N'İSTANBUL TUZLA DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3072, N'506693', N'enes', N'çılgın', N'5350725318', N'enes.cilgin@egm.gov.tr', N'polis memuru', N'EDİRNE PAZARKULE KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAECOMjZXBqYIv399kdmq61BqB/aOPddj5uOBgKcDdQcERwk87vwAlvczXjH4XwDA9xg==', '2025-05-22 16:21:18.643', N'EDİRNE PAZARKULE KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3073, N'540038', N'Şenol', N'BAKİ', N'5616179911', N'senol.baki@egm.gov.tr', N'Polis Memuru', N'İSTANBUL TUZLA DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEAA4kSPY7kWqPClA4P9Fxf8RqQo+4kuntHFOtvpvJsslOZQN6jP6BiRA8PIp1xxvBw==', '2025-05-27 12:51:14.537', N'İSTANBUL TUZLA DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-01 09:52:54.763', 0, 1, 0, NULL, NULL),
            (3074, N'209136', N'DURSUN', N'YILDIRIM', N'5052167193', N'dursun.bildirim2@egm.gov.tr', N'POLİ MEMURU', N'ZONGULDAK DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAENv9WT7BGD05pO/ZuYVj3xJpyF/TBX7L1Sfl5QE39kb37obVfLkbpVWtkUVFOv+NEw==', '2025-06-20 11:22:24.970', N'ZONGULDAK DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3076, N'342184', N'NURULLAH', N'KARAKÖSE', N'05536025034', N'nurullah.karakose@egm.gov.tr', N'P.M', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'a68b25138bbe425986e13829089e54ca.png', N'3', N'0', N'AQAAAAEAACcQAAAAEEzO76wpt1o57tYJULk0Ii4hbM6fCqzgNuzFl9WISJznGHVsh42SgEVPIVX1BSLi+A==', '2025-06-20 11:24:01.293', N'KIRKLARELİ DEREKÖY KARA HUDUT KAPISI', N'0', N'Student', '2026-04-07 01:01:00.733', 0, 1, 0, NULL, NULL),
            (3077, N'384269', N'TALİP', N'CEBECİ', N'05076080620', N'Talipcebeci.1234@gmail.com', N'polis memuru', N'ELAZIĞ HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEKSoPHofRFmq1xA9R9YcU9m4GcRxYRjnvGwh7vaDnEZObm+re90skcWsUkLE7MTJTw==', '2025-06-20 11:24:44.557', N'ELAZIĞ HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3078, N'386523', N'alper ebrar', N'tekin', N'5525360052', N'alperebrar.tekin@egm.gov.tr', N'polis memuru', N'İSTANBUL HAYDARPAŞA DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAELIlr22ctLA3vQIIEIUYq4N0BVEyXsR8bG1Yz+fvgIlWyFpdGMavRIs/NrPABzyalg==', '2025-06-20 11:25:14.370', N'İSTANBUL HAYDARPAŞA DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-01 17:53:18.247', 0, 1, 0, NULL, NULL),
            (3081, N'428563', N'Muhammet Mücahit Emin', N'KÜÇÜK', N'0506 091 00 25', N'muhammetmucahitemin.kucuk@egm.gov.tr', N'Polis Memuru', N'İSTANBUL KARAKÖY DENİZ BÜRO AMİRLİĞİ', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEFzjMxDkvZ59VmhU05dqEzDp9FOJ9sRWuOpQzWiUARSD/xua4o2EiaZBNw+cfMwbIQ==', '2025-07-04 13:50:36.627', N'İSTANBUL KARAKÖY DENİZ BÜRO AMİRLİĞİ', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3083, N'544213', N'Ahmet', N'TANRIVERDİ', N'05348624261', N'ahmet.tanriverdi5@egm.gov.tr', N'Polis Memuru', N'EDİRNE HAMZABEYLİ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEAu4MPgrN5KnYNC8yTJx2A16LQJNPsAZ5Wr0f2cQRdZG1R32c5mrp3MKIXOU5qWUzA==', '2025-07-04 13:52:36.357', N'EDİRNE HAMZABEYLİ KARA HUDUT KAPISI', N'0', N'Student', '2026-04-09 11:55:20.187', 0, 1, 0, NULL, NULL),
            (3084, N'443979', N'Metin', N'Aydoğdu', N'05343440711', N'metin.aydogdu5@egm.gov.tr', N'polis memuru', N'TEKİRDAĞ ASYAPORT LİMAN TESİSİ DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEEywiz18rnWWEA7vWzsI9HgJOonc+zJeY+1Coar3iAClNlkFOJQsmMaTkSf+UFxpkw==', '2025-07-07 09:10:33.757', N'TEKİRDAĞ ASYAPORT LİMAN TESİSİ DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3089, N'538698', N'MEHMET', N'YAZIBOĞA', N'05072074314', N'mehmet.yaziboga@egm.gov.tr', N'POLİS MEMURU', N'EDİRNE HAMZABEYLİ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJazU/32uBI6ha5dTnQZXcSlRjhzHfNyACyoFzqfyg/sw74t4fOrTmRvQzmMEN0hIA==', '2025-07-08 09:28:09.203', N'EDİRNE HAMZABEYLİ KARA HUDUT KAPISI', N'0', N'Student', '2026-04-08 18:50:56.827', 0, 1, 0, NULL, NULL),
            (3090, N'504815', N'Yağız beytullah', N'arslan', N'5412110429', N'beytullah.arslan.2@egm.gov.tr', N'polis memuru', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEGJPug3qY550unTHkcbNxOU6ROeng68qoRKTN4NIlcI14tEWGraZKXO8HH6/o9/LRg==', '2025-07-09 11:21:21.180', N'MUĞLA BODRUM DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3092, N'331838', N'mehmet ', N'demirci', N'5079439350', N'mehmet.demirci9@egm.gov.tr', N'polis memuru', N'SAKARYA KARASU DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEA5bBzz1WjNZC9PeYrjM75QOKXXvyq9Je5COkqG8xIqoVZEBA1bo8KWW0kU7/pxFqg==', '2025-07-16 10:03:30.170', N'SAKARYA KARASU DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3093, N'474396', N'AHMET', N'ÇOBAN', N'05346000270', N'ahmet.coban14@egm.gov.tr', N'Polis Memuru', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEBupoyUNjYqd2I5jo6JtA/P8Phrz0pijotrss7Ub1qtCW7kfGtEtvILEVIQWn9oSkA==', '2025-07-16 10:09:16.470', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3095, N'546291', N'Seyit Burak', N'Kaşkaya', N'05423959852', N'seyitburak.kaskaya@egm.gov.tr', N'Polis Memuru', N'EDİRNE İPSALA KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEFQizlsy/4nyPgHO6lvwgVZ/inD7UCixOS1SD5KUI7sZ4+DutML1BgvthsX6qxRWyw==', '2025-07-25 11:46:33.043', N'EDİRNE İPSALA KARA HUDUT KAPISI', N'0', N'Student', '2026-04-02 04:35:19.137', 0, 1, 0, NULL, NULL),
            (3096, N'360311', N'nuri', N'yıldız', N'5078722062', N'nuri.yildiz3@egm.gov.tr', N'polis memuru', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAENwf9zrh5xpetezCu22RXlp0zqZhNrZrfYy8ThSuxeQVOdpX5o1NvIe8Rj6N1kWiHg==', '2025-07-31 09:48:34.017', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'0', N'Student', '2026-04-03 14:30:56.487', 0, 1, 0, NULL, NULL),
            (3097, N'511672', N'taner', N'artmış', N'05436376280', N'taner.artmis@egm.gov.tr', N'polis memuru', N'MUĞLA MİLAS-BODRUM HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEHOiZFgMlQ6+6dBGZIdZDwvOt0OG/DZ+lqBw2MDj9I/J4KJ9vb5k6l7P7C6aiXiobQ==', '2025-07-31 09:48:37.813', N'MUĞLA MİLAS-BODRUM HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3099, N'284470', N'BURHAN', N'ELAGÖZ', N'5058941985', N'burhan.elagoz@egm.gov.tr', N'POLİS MEMURU', N'BALIKESİR KOCA SEYİT HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEAiHM172mCjCk014d6FmBQJe/VyPl6PZjpRetzy7kNRUN29MeKMiOXkDlZBTZOJyog==', '2025-08-04 10:13:47.047', N'BALIKESİR KOCA SEYİT HAVA LİMANI', N'0', N'Student', '2026-04-01 13:50:43.217', 0, 1, 0, NULL, NULL),
            (3101, N'354617', N'BAHADIR', N'ERCAN', N'05317910152', N'bahadirercan58@hotmail.com', N'Polis Memuru', N'MERSİN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEAT2ZsZqt5O6ScIUhvcr/qxVG1YqM2TME3Opn0Xdxrgf922fnUY3vIQpslCygNuLUg==', '2025-08-04 10:15:11.183', N'MERSİN DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-08 15:08:30.923', 0, 1, 0, NULL, NULL),
            (3102, N'358489', N'GÖRKEM', N'KALLEM', N'5074823676', N'gorkem.kallem@egm.gov.tr', N'POLİS MEMURU', N'BALIKESİR KOCA SEYİT HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEH2+UXUFnMhLnRj1ahpN2r7IuGKhd6uxs1+qFhrMmG1ioBNwvHC6L4ZHbyRvCyCnLA==', '2025-08-04 10:15:40.387', N'BALIKESİR KOCA SEYİT HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3103, N'330185', N'Hasan', N'ÖZASLAN', N'05068635467', N'hasan.ozaslan2@egm.gov.tr', N'polis memuru', N'GAZİANTEP HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEFwDsgxzlE0PRRQt6XNud5M1Sl0geseNCKwO2uHWKRR42N7nnUzZU60miwqSqR/SCQ==', '2025-08-05 10:12:29.287', N'GAZİANTEP HAVA LİMANI', N'0', N'Student', '2026-04-08 01:39:53.287', 0, 1, 0, NULL, NULL),
            (3105, N'441328', N'Ramazan ', N'TEMİZYÜREK', N'0530 381 73 11', N'ramazan.temizyurek@egm.gov.tr', N'Polis Memuru', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAECKLWsx0fZbghA4n1nCTnRqFJXA129wgn3CJ+vmykwMuj7fpqr976Sv15QnLX+NKrg==', '2025-08-06 16:42:12.597', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', '2026-04-08 19:52:43.803', 0, 1, 0, NULL, NULL),
            (3106, N'344938', N'YAŞAR', N'KARABULUT', N'05077796151', N'yasar.karabulut@egm.gov.tr', N'Polis Memuru', N'BURSA YENİŞEHİR HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAENwA+W2Z3+fSNJdUujOULVDL1BOYm2YbdtU6AVkqe1PmBZY9qRVul4bWeYl2JBT4Ug==', '2025-08-08 14:00:58.293', N'BURSA YENİŞEHİR HAVA LİMANI', N'0', N'Student', '2026-04-09 12:24:43.003', 0, 1, 0, NULL, NULL),
            (3107, N'531844', N'FATİH', N'KORKMAZ', N'05434459278', N'korkmazfatih5203@gmail.com', N'polis memuru', N'TRABZON HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEO6pOPUlcGzgwQo7cTI5GtMJLiQkpc2b3Vk+S4gSRxNjmd+lEmPSq7+G7Sst3WXHMQ==', '2025-08-08 14:01:52.213', N'TRABZON HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3109, N'303684', N'Fatih', N'TÜMER', N'05059110479', N'fatih.tumer@egm.gov.tr', N'Polis Memuru', N'HATAY HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAENMF72tT8kLgqus3xqjYcpbL0qUSXaNSuQ96eLUhuITn2cZTkycFkhp7VNmgSdc7dw==', '2025-08-11 15:39:16.867', N'HATAY HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3111, N'545695', N'Mehmet Numan', N'KALYAN', N'5314908384', N'mehmetnuman.kalyan@egm.com.tr', N'polis memuru', N'İZMİR SEFERİHİSAR DENİZ HUDUT KAPISI', N'', N'3', N'1', N'AQAAAAEAACcQAAAAEM2ni74rFxUyz19mfnwj7+fytDohIy1EkpRG4nlMBTkhoNZB/i1idtkhAT1wXpO5kg==', '2025-08-11 15:40:58.677', N'İZMİR SEFERİHİSAR DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3112, N'463227', N'SERCAN', N'SAVAŞ', N'05433817403', N'sercan.savas@egm.gov.tr', N'Polis Memuru', N'EDİRNE PAZARKULE KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJ4UpEVWaxHUCqv6rLwjT6j25l0cMBYc8IOfWrqwDbuiQ0GKsHuWY0u0qQkDSMeUHg==', '2025-08-12 10:55:22.227', N'EDİRNE PAZARKULE KARA HUDUT KAPISI', N'0', N'Student', '2026-04-07 13:15:08.037', 0, 1, 0, NULL, NULL),
            (3114, N'443977', N'CANER', N'KARA', N'05315977409', N'caner.kara5@egm.gov.tr', N'POLİS MEMURU', N'HAKKARİ ESENDERE KARA HUDUT KAPISI', N'a3e7b53be6d340d79aeeae1f4dde843e.jpg', N'3', N'0', N'AQAAAAEAACcQAAAAEJ8EG3JRwP1bJNlQTJCxWvNKs7FQ9fp3GvlywjVIiA7aQQ+1okhwifl6LDbWdxXpxQ==', '2025-08-13 13:51:00.137', N'HAKKARİ ESENDERE KARA HUDUT KAPISI', N'0', N'Student', '2026-04-09 04:56:20.603', 0, 1, 0, NULL, NULL),
            (3116, N'546598', N'Bahtiyar', N'ÇELİK', N'5432727604', N'bahtiyar.celik2@egm.gov.tr', N'Polis Memuru', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAED9Z8DLzam/YVjw2dynq5vE6+CaLCb4741odfTxsZLxEqm15ev8hV7zr6x5++MNRIw==', '2025-08-13 13:54:21.163', N'ARDAHAN TÜRKGÖZÜ KARA HUDUT KAPISI', N'0', N'Student', '2026-04-01 21:13:52.767', 0, 1, 0, NULL, NULL),
            (3117, N'388223', N'ENES', N'KURTOĞLU', N'0507 082 92 01', N'enes.kurtoglu@egm.gov.tr', N'Polis Memuru', N'HAKKARİ ESENDERE KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEGuSLViy4ZOpIFceunA5cw0WHBDmfBrQtqFYfJuBPZC1EetQQr4nyrdrHWhSeY1lxA==', '2025-08-15 15:40:15.810', N'HAKKARİ ESENDERE KARA HUDUT KAPISI', N'0', N'Student', '2026-04-09 15:17:26.983', 0, 1, 0, NULL, NULL),
            (3118, N'425653', N'HASAN', N'ERİŞ', N'5375119222', N'hasan.eris@egm.gov.tr', N'Polis Memuru', N'İSTANBUL TUZLA DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEDfdIwEdrRfrZ79hpsE2/hInrfkJIX3Y9RMFWk9iqMalMirG27FwtP/h2C8yA/IBkw==', '2025-08-15 15:40:49.967', N'İSTANBUL TUZLA DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3119, N'451448', N'KIYAS KEREM', N'GÜNDÜZ', N'0506 039 39 60', N'kiyas.gunduz@egm.gov.tr', N'Polis Memuru', N'HAKKARİ ESENDERE KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAENJbhflptwBM4lUOSCxouaMY2fwiz964Z7ScV8ur4alcDEDtyvXULwjqLGB4X81NsQ==', '2025-08-15 15:41:18.543', N'HAKKARİ ESENDERE KARA HUDUT KAPISI', N'0', N'Student', '2026-04-05 18:48:38.150', 0, 1, 0, NULL, NULL),
            (3120, N'370250', N'Musa', N'Çakmak', N'05076439342', N'musa.cakmak2@egm.gov.tr', N'Polis Memuru', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEGqDZGRv9vp0LZLvgZi9z4EZtO0MaqaBDhRKxlJiAW2bD71038qHj+9OPw2NtbNNsA==', '2025-08-18 14:48:19.653', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3123, N'312419', N'ADEM', N'ÖZBUĞANLİ', N'05053915650', N'adem.ozbuganli@egm.gov.tr', N'polis memuru', N'BURSA YENİŞEHİR HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEKxN5vByjy4u3rboUKEsHERFTDOymNaMv7OB/SGUOn9aDXB0KDeHIK+It16ta4zU2g==', '2025-08-22 15:40:26.693', N'BURSA YENİŞEHİR HAVA LİMANI', N'0', N'Student', '2026-04-08 15:03:26.000', 0, 1, 0, NULL, NULL),
            (3124, N'465808', N'Abdurrahman', N'KALKAN', N'05342361038', N'abdurrahman.kalkan3@egm.gov.tr', N'polis memuru', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAECFF07hmG47YI3vZmSu1/WnzQIE2U1cxjQYCdcmh0lECX2NSkAIT5wNR9PFOYT++ZQ==', '2025-08-22 15:42:05.017', N'ARDAHAN AKTAŞ KARA HUDUT KAPISI', N'0', N'Student', '2026-04-02 18:45:29.150', 0, 1, 0, NULL, NULL),
            (3125, N'480009', N'MUHAMMET', N'SEZER', N'05425284781', N'muhammet.sezer5@egm.gov.tr', N'POLİS MEMURU', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAENEhJGDjZVR8MfO1GgxJisr60r6Qha/vn1yC0oFQonlqIK3Uit79psWNRbxAhL6CmA==', '2025-08-22 15:43:01.610', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'0', N'Student', '2026-04-07 16:33:50.897', 0, 1, 0, NULL, NULL),
            (3126, N'397293', N'FATİH', N'ÖZEN', N'05417477707', N'fatih.ozen3@egm.gov.tr', N'polis memuru', N'İSKENDERUN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEO7yHImpOZY296eFk5v3jmBpyBuYCO6cu0g+82eCb2S2ugcssmyZmh15koK2/02Dbw==', '2025-08-26 16:46:00.583', N'İSKENDERUN DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-04 08:26:33.540', 0, 1, 0, NULL, NULL),
            (3127, N'474409', N'BİLAL', N'CESUR', N'05550680240', N'bilal.cesur@egm.gov.tr', N'polis memuru', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJHAHwJJwg/sCgWCAxvdRZV9ZbDb1iwsdvDIbrzzLuSgzJ/I4K2MjQNDiPoO5L5WDw==', '2025-08-26 16:46:29.363', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3129, N'275660', N'MUSTAFA', N'ÜNALAN', N'055', N'mustafa.unalan@egm.gov.tr', N'POLİS MEMURU', N'BALIKESİR KOCA SEYİT HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAECGxU2lMY/nark4IULSBvLqtfuxM+ggICIiAiyJaoraIU4x3bsiYU7z3TAv4kcMTPw==', '2025-09-01 16:24:03.583', N'BALIKESİR KOCA SEYİT HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3131, N'470529', N'ÇAĞDAŞ', N'KARGILI', N'05539822720', N'cagdas.kargili@egm.gov.tr', N'polis memuru', N'HAKKARİ ÜZÜMLÜ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEAJ4LZ/5hZWQAF9SYUTsEw+NZzdCMSSRGSoE/cTsBv7V/yidAuEsdZrJoL13Ftpbxg==', '2025-09-01 16:25:10.050', N'HAKKARİ ÜZÜMLÜ KARA HUDUT KAPISI', N'0', N'Student', '2026-04-09 11:06:31.903', 0, 1, 0, NULL, NULL),
            (3133, N'217145', N'ŞIH MEHMET', N'GÜNEŞ', N'5053460300', N'sihmehmet.gunes@egm.gov.tr', N'Polis Memuru', N'HATAY HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEOmNDK3TevYEe1o1F/KcFdCBpySFzZKTCVsX29ZvnV1TqiKyExkUh+6H7BAX3fV1LQ==', '2025-09-03 09:58:51.693', N'HATAY HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3134, N'367585', N'KEREM', N'ÖZKAN', N'5426398637', N'kerem.ozkan2@egm.gov.tr', N'Polis Memuru', N'AĞRI GÜRBULAK KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEG1xnloq7a8Mc+cQmLx9fnojZ/zSenlBVp1In36MThfvc4e76LeJbKkAUqEhxsdhaQ==', '2025-09-03 09:59:24.537', N'AĞRI GÜRBULAK KARA HUDUT KAPISI', N'0', N'Student', '2026-04-08 16:26:52.477', 0, 1, 0, NULL, NULL),
            (3137, N'542923', N'OKAN', N'AKGÜL', N'05356253191', N'OKAN.AKGUL@EGM.GOV.TR', N'POLİS MEMURU', N'EDİRNE HAMZABEYLİ KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEIT72iSvvn/us1InHkuFODFD7s8b+RltDYB2IcG5awUrr8ojcMXAcqtKwWyfrqJwgg==', '2025-09-08 09:51:08.937', N'EDİRNE HAMZABEYLİ KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3138, N'544491', N'AHMET', N'ARI', N'05063799914', N'ahmet.ari12@egm.gov.tr', N'polis memuru', N'EDİRNE KAPIKULE KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEIMykYO0x4H1sqwoVg4RTN66K5rU1URopvgIsBckACavR+3XWAbU21auXHtnZo+K5g==', '2025-09-08 09:51:42.670', N'EDİRNE KAPIKULE KARA HUDUT KAPISI', N'0', N'Student', '2026-04-07 00:25:08.843', 0, 1, 0, NULL, NULL),
            (3139, N'343830', N'ZAİDDİN', N'FIRTANA', N'05354637353', N'zaiddin.firtana@egm.gov.tr', N'POLİS MEMURU', N'HAKKARİ ESENDERE KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEG41mVM9csOPKQBxWX7EZYLURm5xj7pfEO77OnY8cmXSYmG9ZekQUgaqwnBSWnYyWw==', '2025-09-12 15:25:55.330', N'HAKKARİ ESENDERE KARA HUDUT KAPISI', N'0', N'Student', '2026-03-31 20:08:07.737', 0, 1, 0, NULL, NULL),
            (3140, N'378752', N'UĞUR', N'ÖNAL', N'5070066159', N'ugur.onal2@egm.gov.tr', N'Polis Memuru', N'ANTALYA FİNİKE DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEGtvgcUg8hmR4paG4noskMtnyHXXV6tC63CfGIvxAvRzSD2QpXLRxdG/JD/raUSahA==', '2025-09-15 16:48:41.040', N'ANTALYA FİNİKE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL);
        INSERT INTO [dbo].[E_User] ([fldId], [fldSicil], [fldName], [fldLastName], [fldPhone], [fldEmail], [fldTitle], [fldDeputy], [fldPicture], [fldAuth], [fldSubAuth], [fldPassword], [fldDateTime], [fldBorder], [fldActive], [Role], [LastLogin], [XP], [Level], [IsActive], [TeacherRequestStatus], [TeacherRequestDate]) VALUES
            (3141, N'464116', N'EMİN', N'ERKAN', N'5342636257', N'emin.erkan@egm.gov.tr', N'polis memuru', N'ARTVİN SARP KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEBmYkXxOouSrZ5BAW/+AMP2rj6K59CeBAJpckZEijD12hsJmNSwyL3Xbdv5LvjwLAQ==', '2025-09-15 16:50:32.143', N'ARTVİN SARP KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3144, N'547218', N'Mehmet', N'TURAN', N'5455578188', N'mehmet.turan13812e@egm.gov.tr', N'Polis Memuru', N'MUĞLA TURGUT REİS DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEKQG95n6ML0f9WHb/diUomt2qc63Uy7mQSC16lKkf3s8VEvUm4+TgtEw9YS1P4rlbw==', '2025-09-29 11:26:17.940', N'MUĞLA TURGUT REİS DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3152, N'315510', N'ALİ', N'KAÇAN', N'05057651959', N'ali.kacan@egm.gov.tr', N'Polis Memuru', N'İSTANBUL KARAKÖY DENİZ BÜRO AMİRLİĞİ', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEIt0wzrF3AfHIXuqyWvL/f85ck6zlK9BaM3v7saJwCc2WTiThc7E4J+uukJBmqGGAQ==', '2025-10-07 10:16:24.837', N'İSTANBUL KARAKÖY DENİZ BÜRO AMİRLİĞİ', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3153, N'462306', N'ORHAN', N'TEMİZ', N'0 543 665 41 86 ', N'Orhan.temiz@egm.gov.tr', N'Polis Memuru', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEHDNBlvO5N8h3buGs583+NhC1fYePToZwyMBR37KAiczMAQho9NSfluEHrFAOS7FCw==', '2025-10-07 10:17:06.850', N'VAN KAPIKÖY KARA HUDUT KAPISI', N'0', N'Student', '2026-04-09 05:05:52.317', 0, 1, 0, NULL, NULL),
            (3158, N'443992', N'mesut', N'cuci', N'05075677814', N'mesutcucii@gmail.com', N'polis memudu', N'ARTVİN SARP KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEOh2HZ1eYoW4WbxTJIrQwWm1uvSepzSqDDtjZC4tE5cClAH4w+CUePqsNfzHxn8klQ==', '2025-10-15 12:31:46.627', N'ARTVİN SARP KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3160, N'441293', N'Hasan', N'KILINÇ', N'05076466736', N'hasan.kilinc10@egm.gov.tr', N'Polis Memuru', N'DİYARBAKIR HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEMhPjr3esWt/ZFquqxh/q6Jmsyn1SXbVL57vc3ejDB1bRiMQthanv3xUxiltQDM64Q==', '2025-10-23 14:27:12.267', N'DİYARBAKIR HAVA LİMANI', N'0', N'Student', '2026-04-07 10:48:44.657', 0, 1, 0, NULL, NULL),
            (3165, N'524674', N'Şeyma', N'DEMİRCİOĞLU', N'05012621014', N'seyma.bostanci@egm.gov.tr', N'POLİS MEMURU', N'KONYA HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEFHr4bIOqQFHqK4WnUe7/zJh0uM2NPtT8ehYxEUojla/vkFQc1JLrTmAPNztONMcsA==', '2025-11-03 11:30:33.750', N'KONYA HAVA LİMANI', N'0', N'Student', '2026-04-07 09:44:15.200', 0, 1, 0, NULL, NULL),
            (3168, N'349729', N'FATİH', N'YILMAZ', N'05536594460', N'fatih.yilmaz10@egm.gov.tr', N'polis memuru', N'TRABZON DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAELGi/R6rJtOeiiRuiv0Sw4U/GSNaOqEhsOgCpk4byt0o+Z5MZmnEHr/1r2ppMfgI/A==', '2025-11-14 09:56:29.053', N'TRABZON DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3177, N'462579', N'Gökhan', N'KAYA', N'0553 575 3860', N'gokhan.kaya21@egm.gov.tr', N'Polis Memuru', N'ARTVİN SARP KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEE47VeZqhon9JN+41CS/AnxharFqmbaN3UwOSmdreypRJCWFQZjwt98HkwoSfa3bDw==', '2025-12-03 15:17:48.013', N'ARTVİN SARP KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3179, N'506719', N'Serhat', N'KAYAR', N'05350237020', N'serhat.kayar2@egm.gov.tr', N'Polis Memuru', N'MERSİN DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEA7lPpiMJtO93m3/Yc8F017Z+CT2IGrb28PjRzdy9RHE6dqgQjdT1hPn7Y/ROco8wQ==', '2025-12-08 10:59:44.797', N'MERSİN DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-07 18:54:22.157', 0, 1, 0, NULL, NULL),
            (3181, N'551126', N'kamile', N'görgel', N'5074923458', N'kamile.gorgel@egm.gov.tr', N'polis memuru', N'KOCAELİ DERİNCE DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEPDvG3zoineYp5qLZ6/L1mfa8+9n6+72OQnqUKJT1QCXjCGAGb8Lq8IWHLAdLnUJkw==', '2025-12-08 11:02:25.273', N'KOCAELİ DERİNCE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3184, N'531587', N'UMAY', N'TURGUD', N'05457879827', N'umayturgud@egm.gov.tr', N'polis memuru', N'KOCAELİ DERİNCE DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEKWi9lt4wvNqLt0RRfH8D9V7xGqzP+f66mdg3vyI9XcmcPExFtk2FGW9jpmgnUxCew==', '2025-12-17 08:28:45.033', N'KOCAELİ DERİNCE DENİZ HUDUT KAPISI', N'0', N'Student', '2026-03-31 21:37:15.743', 0, 1, 0, NULL, NULL),
            (3185, N'348496', N'BİRKAN', N'SARI', N'05074455656', N'birkan_sari@hotmail.com', N'polis memuru', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEBRWRbflYbHJ0abVeIU2m0+XfahGtaE2B7imGndEm0XWgzjSikD+8Zeqp1ScrM1XFQ==', '2025-12-29 09:36:44.557', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'0', N'Student', '2026-04-08 14:45:02.667', 0, 1, 0, NULL, NULL),
            (3186, N'498293', N'ALPER', N'SÜNGÜ', N'05392169951', N'alper.sungu@egm.gov.tr', N'Polis Memuru', N'İSTANBUL SABİHA GÖKÇEN HAVA LİMANI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEMKd5/Okmi6dllMp72pvWgYW1fD2744sAES53CENLWlZuE9cHaWQfCSQSI7M59M1Ng==', '2025-12-29 09:36:48.527', N'İSTANBUL SABİHA GÖKÇEN HAVA LİMANI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3189, N'547856', N'FATMA ', N'EKMEN', N'5522402998', N'fatma.ekmen@egm.gov.tr', N'polis memuru', N'KOCAELİ DERİNCE DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEGnFzb4kLnryQneLpgN1DjPpryMNiMO8yQOjAx4LC9ir5wqUGyz/D91qtWdHtx4qUg==', '2025-12-29 09:36:57.260', N'KOCAELİ DERİNCE DENİZ HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3192, N'315868', N'ali ihsan ', N'duman', N'5305411164', N'aliihsan.duman@egm.gov.tr', N'polis memuru', N'HATAY MMK METALURJİ DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEGVo1e+ooPkxIOGkZinbZhd/Xsq4eL+PtYr0NB3aMricUzOUkpvcC6fYTphhrFQ9Og==', '2026-01-05 11:34:49.910', N'HATAY MMK METALURJİ DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-06 07:44:26.597', 0, 1, 0, NULL, NULL),
            (3196, N'467574', N'YÜCEL', N'BULUT', N'05333017274', N'yucel.bulut@egm.gov.tr', N'polis memuru', N'EDİRNE PAZARKULE KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJfHSUfTHCQv1VveMATz3sh74iEMllMjBlUosudbVk65EmBwfZz4OUAVOXGjw8xKwQ==', '2026-01-06 09:48:54.077', N'EDİRNE PAZARKULE KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3198, N'476976', N'SERCAN', N'AYGÜN', N'5456279641', N'sercan.aygun3@egm.gov.tr', N'polis memuru', N'IĞDIR DİLUCU KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAED+7qHUqcsuCUCVylOLGlyM7PHHXyRfwM7K3Cqp7QZTC4jPCw8MmGmtbf/L3liB1aQ==', '2026-01-18 10:37:09.170', N'IĞDIR DİLUCU KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3210, N'442315', N'RIZA EMRE', N'ERDOĞAN', N'05364723748', N'rizaemre.erdogan@egm.gov.tr', N'Polis Memuru', N'IĞDIR DİLUCU KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJueiRJxIAgR4An+wdUHdwkAKUTxx0px0pNg9zOREG9eG+xbbVKSY/8Wacr51AWU8Q==', '2026-02-10 15:45:01.760', N'IĞDIR DİLUCU KARA HUDUT KAPISI', N'0', N'Student', '2026-04-08 19:06:43.873', 0, 1, 0, NULL, NULL),
            (3211, N'428730', N'İbrahim', N'ASLAN', N'05936568701', N'ibrahim.ozen5@egm.gov.tr', N'polis memuru', N'AĞRI GÜRBULAK KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEDaVLpxidcYAy6VbzI+WRwa1CbEBHQUnAsUSuc4k+r50uF5NPe9g+5pibzSfCdV9ag==', '2026-02-17 12:41:28.737', N'AĞRI GÜRBULAK KARA HUDUT KAPISI', N'0', N'Student', '2026-04-09 08:20:42.237', 0, 1, 0, NULL, NULL),
            (3212, N'463042', N'Metin', N'AKYÜZ', N'05064074091', N'metinakyuz.3@egm.gov.tr', N'Polis Memuru', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEKIdRdx83SvCqtBdqoSKZcLp8xwDHw3gpMdriuLFa7egTTfh/dXaGV7JVUNh0O7N6g==', '2026-02-20 11:46:43.177', N'ŞIRNAK HABUR KARA HUDUT KAPISI', N'0', N'Student', '2026-04-04 04:35:56.900', 0, 1, 0, NULL, NULL),
            (3215, N'376740', N'AYKUT', N'YILDIRIM', N'5454608115', N'aykut.yildirim3@egm.gov.tr', N'P.M.', N'IĞDIR ALİCAN KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJzk8cVi+x2vLpA6we3vyDu465x3GM6P8yFIride7p+qFxE02Rx8JN493q4f991BUw==', '2026-02-25 13:25:19.080', N'IĞDIR ALİCAN KARA HUDUT KAPISI', N'0', N'Student', NULL, 0, 1, 0, NULL, NULL),
            (3219, N'247833', N'SERVİN', N'KÖSE', N'0505', N'servin.kose@egm.gov.tr', N'POLİS MEMURU', N'EĞİTMEN', N'2321fda20d7149338d76a73697ca28e2.png', N'3,4,6', N'0', N'AQAAAAEAACcQAAAAEFLGo5JLR9VI8y2q+Wk4M735Sak1En+hiEpRUgvKHbvOIXgI5sSGtwzNPotliFsP5w==', '2026-03-05 14:13:19.420', N'ANTALYA GAZİPAŞA HAVA LİMANI', N'0', N'Teacher', '2026-04-09 13:50:17.760', 0, 0, 0, NULL, NULL),
            (3227, N'552622', N'ESRA', N'AKCA', N'0552 553 2111', N'esra.akca@egm.gov.tr', N'Polis Memuru', N'EDİRNE KAPIKULE KARA HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEA6u1lFLS8yexU4KG8PzGHU/doPaHQ/EkNfjceifeIftvj/GF97VTx/X7lIXV88AOA==', '2026-03-27 16:25:18.200', N'EDİRNE KAPIKULE KARA HUDUT KAPISI', N'0', N'Student', '2026-04-09 11:34:01.350', 0, 0, 0, NULL, NULL),
            (3229, N'000000', N'Deneme ', N'Kullanıcı', N'0505', N'deneme@egm.gov.tr', N'Polis', N'Deneme Görevi', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEJ7mLNnYZtx6nOU95T4O63kbHajN9SgktVMXzCp8XJPxCHH7DexMupa9U6GI+o8I+w==', '2026-03-30 13:59:06.237', N'ANTALYA GAZİPAŞA HAVA LİMANI', N'1', N'Student', '2026-04-23 15:17:08.907', 0, 0, 1, N'2', '2026-04-23 15:20:09.770'),
            (3251, N'282261', N'İBRAHİM', N'BURTAŞKIRAY', N'05075213278', N'ibrahim.burtaskiray@egm.gov.tr', N'Polis Memuru', N'HATAY MMK METALURJİ DENİZ HUDUT KAPISI', N'', N'3', N'0', N'AQAAAAEAACcQAAAAEG1WK4FBP4TCnJKTtT2T8CbcQaHZ35zsqG02NiXnuIw3V0YP7HvLcjMLoO/EvTSpGg==', '2026-04-07 14:57:52.277', N'HATAY MMK METALURJİ DENİZ HUDUT KAPISI', N'0', N'Student', '2026-04-08 11:31:59.760', 0, 0, 0, NULL, NULL),
            (3253, N'100001', N'Ali', N'YILMAZ', N'05000000001', N'ali.yilmaz@egm.gov.tr', N'Komiser Yardimcisi', N'Buro Amiri', NULL, N'1,2', N'0', N'AQAAAAEAACcQAAAAELaICBESNYwt1kkjs/UxLBVDGGSTf+OtgnjysrWPmRTl3jdWEOaUxaNzCuJuKvme7w==', '2026-06-14 22:12:12.390', N'ANTALYA GAZIPASA HAVA LIMANI', N'1', N'BuroAmiri', NULL, 0, 1, 1, NULL, NULL),
            (3254, N'100002', N'Ayse', N'DEMIR', N'05000000002', N'ayse.demir@egm.gov.tr', N'Polis Memuru', N'Veri Giris Personeli', NULL, N'1', N'0', N'AQAAAAEAACcQAAAAELaICBESNYwt1kkjs/UxLBVDGGSTf+OtgnjysrWPmRTl3jdWEOaUxaNzCuJuKvme7w==', '2026-06-14 22:12:12.410', N'ANTALYA GAZIPASA HAVA LIMANI', N'1', N'VeriGirisPersoneli', NULL, 0, 1, 1, NULL, NULL);
        SET IDENTITY_INSERT [dbo].[E_User] OFF;
        PRINT 'Tablo [dbo].[E_User] icin 528 kayit eklendi.';
    END
END
GO

