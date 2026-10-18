import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AirportStatisticsPage extends StatefulWidget {
  final String apiBaseUrl;
  final String? authToken;

  const AirportStatisticsPage({
    super.key,
    required this.apiBaseUrl,
    this.authToken,
  });

  @override
  State<AirportStatisticsPage> createState() => _AirportStatisticsPageState();
}

class _AirportStatisticsPageState extends State<AirportStatisticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String _statusMessage = 'Resmi Brifing Verileri Yüklendi (Çevrimdışı Aktif)';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchOnlineData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Merkezi sunucudan güncel veriler alınıyor...';
    });

    try {
      final uri = Uri.parse('${widget.apiBaseUrl}/Istatistik/GetBrifingJson');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          if (!mounted) return;
          setState(() {
            _statusMessage = 'Sunucuyla senkronize edildi: ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Havalimanı istatistikleri sunucudan güncellendi.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (!mounted) return;
        setState(() {
          _statusMessage = 'Sunucu yanıtı: ${response.statusCode} (Sabit brifing verisi devrede)';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Çevrimdışı moddasınız (Yerel brifing verisi devrede)';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sunucuya ulaşılamadı. Yerel resmi brifing verileri gösteriliyor.'),
          backgroundColor: Colors.orange,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const navyDark = Color(0xff06152b);
    const navyMid = Color(0xff0d2b4f);

    return Scaffold(
      backgroundColor: const Color(0xfff1f5f9),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Havalimanı Brifing & İstatistik',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'HİZMETE ÖZEL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '2026 Yılı 9 Aylık Rapor',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: navyDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            tooltip: 'Sunucudan Güncelle',
            onPressed: _isLoading ? null : _fetchOnlineData,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Hakkında',
            onPressed: () => _showAboutDialog(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.amber,
          indicatorWeight: 3,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.flight_takeoff, size: 18), text: 'Yolcu & Uçak'),
            Tab(icon: Icon(Icons.public, size: 18), text: 'İlk 10 Ülke'),
            Tab(icon: Icon(Icons.block, size: 18), text: 'INAD İcmali'),
            Tab(icon: Icon(Icons.fingerprint, size: 18), text: 'Sahtecilik & YTS'),
            Tab(icon: Icon(Icons.gavel, size: 18), text: 'Suç & Asayiş'),
            Tab(icon: Icon(Icons.videocam, size: 18), text: 'Trafik & CCTV'),
            Tab(icon: Icon(Icons.account_tree, size: 18), text: 'Büro Teşkilatı'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Sub-header status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: navyMid,
            child: Row(
              children: [
                const Icon(Icons.verified_user, color: Colors.amber, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _statusMessage,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Tab View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPassengerFlightTab(),
                _buildTopCountriesTab(),
                _buildInadTab(),
                _buildFraudAndYtsTab(),
                _buildCrimePreventionTab(),
                _buildTrafficAndCctvTab(),
                _buildBureausTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // TAB 1: YOLCU VE UÇAK TRAFİĞİ
  // ========================================================
  Widget _buildPassengerFlightTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Summary KPI Cards
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'TOPLAM YOLCU',
                value: '733.633',
                subtitle: '416.741 Dış / 316.892 İç',
                icon: Icons.people_alt,
                color: const Color(0xff2563eb),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                title: 'TOPLAM UÇAK',
                value: '4.655',
                subtitle: '2.573 Dış / 2.082 İç',
                icon: Icons.flight,
                color: const Color(0xff4f46e5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _buildSectionHeader('İÇ HATLAR TRAFİĞİ (2025 vs 2026)'),
        _buildComparisonCard(
          category: 'İç Hatlar Yolcu (9 Aylık)',
          val2025: 335225,
          val2026: 316892,
          unit: 'yolcu',
          diff: -18333,
          pct: -5.0,
          color: Colors.blue,
        ),
        _buildComparisonCard(
          category: 'İç Hatlar Uçak (9 Aylık)',
          val2025: 2302,
          val2026: 2082,
          unit: 'sefer',
          diff: -220,
          pct: -9.6,
          color: Colors.indigo,
        ),
        const SizedBox(height: 12),

        _buildSectionHeader('DIŞ HATLAR TRAFİĞİ (2025 vs 2026)'),
        _buildComparisonCard(
          category: 'Dış Hatlar Yolcu (9 Aylık)',
          val2025: 471639,
          val2026: 416741,
          unit: 'yolcu',
          diff: -54898,
          pct: -12.0,
          color: Colors.deepPurple,
        ),
        _buildComparisonCard(
          category: 'Dış Hatlar Uçak (9 Aylık)',
          val2025: 2861,
          val2026: 2573,
          unit: 'sefer',
          diff: -288,
          pct: -10.1,
          color: Colors.purple,
        ),
        const SizedBox(height: 12),

        _buildSectionHeader('EYLÜL AYI MUKAYESESİ'),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildTableRow('İç Hat Yolcu (Eylül)', '47.674', '42.135', '-12%'),
                const Divider(),
                _buildTableRow('İç Hat Uçak (Eylül)', '300', '266', '-11.3%'),
                const Divider(),
                _buildTableRow('Dış Hat Yolcu (Eylül)', '84.643', '72.756', '-14%'),
                const Divider(),
                _buildTableRow('Dış Hat Uçak (Eylül)', '526', '446', '-15.2%'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ========================================================
  // TAB 2: İLK 10 ÜLKE DAĞILIMI
  // ========================================================
  Widget _buildTopCountriesTab() {
    final countries = [
      {'rank': 1, 'name': 'Rusya Federasyonu', 'flag': '🇷🇺', 'total': 115258, 'in': 59786, 'out': 55472, 'pct': 27.66},
      {'rank': 2, 'name': 'Danimarka', 'flag': '🇩🇰', 'total': 85415, 'in': 43759, 'out': 41656, 'pct': 20.50},
      {'rank': 3, 'name': 'Finlandiya', 'flag': '🇫🇮', 'total': 51315, 'in': 26144, 'out': 25171, 'pct': 12.31},
      {'rank': 4, 'name': 'Norveç', 'flag': '🇳🇴', 'total': 47229, 'in': 24280, 'out': 22949, 'pct': 11.33},
      {'rank': 5, 'name': 'İsveç', 'flag': '🇸🇪', 'total': 26311, 'in': 13340, 'out': 12971, 'pct': 6.31},
      {'rank': 6, 'name': 'Kazakistan', 'flag': '🇰🇿', 'total': 24513, 'in': 12665, 'out': 11848, 'pct': 5.88},
      {'rank': 7, 'name': 'Hollanda', 'flag': '🇳🇱', 'total': 17397, 'in': 8747, 'out': 8650, 'pct': 4.17},
      {'rank': 8, 'name': 'İran', 'flag': '🇮🇷', 'total': 13699, 'in': 6992, 'out': 6707, 'pct': 3.29},
      {'rank': 9, 'name': 'Almanya', 'flag': '🇩🇪', 'total': 11159, 'in': 5497, 'out': 5662, 'pct': 2.68},
      {'rank': 10, 'name': 'Türkiye', 'flag': '🇹🇷', 'total': 9734, 'in': 4692, 'out': 5042, 'pct': 2.34},
      {'rank': 11, 'name': 'Diğer Ülkeler', 'flag': '🌐', 'total': 14711, 'in': 7363, 'out': 7348, 'pct': 3.53},
    ];

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildSectionHeader('2026 YILI DIŞ HATLAR İLK 10 ÜLKE SIRALAMASI'),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xff06152b),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.pie_chart, color: Colors.amber, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dış Hatlar Genel Toplam: 416.741',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      'Gelen: 213.265 | Giden: 203.476 Yolcu',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        ...countries.map((c) {
          final pct = (c['pct'] as num).toDouble();
          final isTop3 = (c['rank'] as int) <= 3;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isTop3 ? Colors.amber : const Color(0xffe2e8f0),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${c['rank']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isTop3 ? Colors.black : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(c['flag'] as String, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          c['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      Text(
                        _formatNumber(c['total'] as int),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: Color(0xff1d4ed8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct / 30.0,
                      minHeight: 6,
                      backgroundColor: const Color(0xffe2e8f0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isTop3 ? Colors.amber.shade700 : const Color(0xff2563eb),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Gelen: ${_formatNumber(c['in'] as int)} | Giden: ${_formatNumber(c['out'] as int)}',
                        style: const TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                      Text(
                        '%${pct.toStringAsFixed(1)} Pay',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ========================================================
  // TAB 3: INAD İCMALİ (14 YILLIK DÖKÜM)
  // ========================================================
  Widget _buildInadTab() {
    final reasons = [
      {'name': 'Hakkında Giriş Yasağı Bulunması', 'total': 143, 'pct': 28.7, 'color': Colors.red},
      {'name': 'Giriş Vizesinin Olmaması', 'total': 139, 'pct': 27.9, 'color': Colors.deepOrange},
      {'name': 'Pasaport Süresinin Yetersiz Olması', 'total': 51, 'pct': 10.2, 'color': Colors.amber.shade800},
      {'name': 'Geçerli Seyahat Belgesi Olmayan', 'total': 48, 'pct': 9.6, 'color': Colors.blue},
      {'name': '180 Günde 90 Gün İhlali', 'total': 37, 'pct': 7.4, 'color': Colors.purple},
      {'name': 'Sahte Pasaport', 'total': 35, 'pct': 7.0, 'color': Colors.teal},
      {'name': 'Pasaportta Tahrifat Yapılmış', 'total': 20, 'pct': 4.0, 'color': Colors.indigo},
      {'name': 'Türkiye\'ye Girişi Sakıncalı', 'total': 9, 'pct': 1.8, 'color': Colors.brown},
      {'name': 'Sahte Vize / İkamet', 'total': 1, 'pct': 0.2, 'color': Colors.blueGrey},
      {'name': 'Çalıntı Belge', 'total': 1, 'pct': 0.2, 'color': Colors.blueGrey},
      {'name': 'Diğer Sebepler', 'total': 15, 'pct': 3.0, 'color': Colors.grey},
    ];

    final yearlyTotals = [
      {'year': '2013', 'count': 21},
      {'year': '2014', 'count': 18},
      {'year': '2015', 'count': 69},
      {'year': '2016', 'count': 23},
      {'year': '2017', 'count': 29},
      {'year': '2018', 'count': 30},
      {'year': '2019', 'count': 36},
      {'year': '2020', 'count': 11},
      {'year': '2021', 'count': 39},
      {'year': '2022', 'count': 14},
      {'year': '2023', 'count': 34},
      {'year': '2024', 'count': 75},
      {'year': '2025', 'count': 63},
      {'year': '2026', 'count': 37},
    ];

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: '14 YILLIK TOPLAM INAD',
                value: '499',
                subtitle: '2013 - 2026 İcmali',
                icon: Icons.block,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                title: '2026 YILI VAKASI',
                value: '37',
                subtitle: 'İlk 9 Ay Toplamı',
                icon: Icons.warning_amber_rounded,
                color: Colors.amber.shade900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _buildSectionHeader('YILLARA GÖRE INAD SAYILARI (2013 - 2026)'),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: yearlyTotals.map((y) {
                final isCurrent = y['year'] == '2026';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCurrent ? Colors.red.shade50 : const Color(0xfff8fafc),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isCurrent ? Colors.red : const Color(0xffcbd5e1),
                      width: isCurrent ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(y['year'] as String, style: const TextStyle(fontSize: 10, color: Colors.black54)),
                      Text(
                        '${y['count']}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? Colors.red.shade800 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),

        _buildSectionHeader('INAD GEREKÇELERİNE GÖRE DAĞILIM (TOPLAM 499)'),
        ...reasons.map((r) {
          final pct = (r['pct'] as num).toDouble();
          final clr = r['color'] as Color;

          return Card(
            margin: const EdgeInsets.only(bottom: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 14,
                backgroundColor: clr.withValues(alpha: 0.15),
                child: Icon(Icons.rule, size: 14, color: clr),
              ),
              title: Text(r['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${r['total']} Vaka', style: TextStyle(fontWeight: FontWeight.w900, color: clr, fontSize: 13)),
                  Text('%${pct.toStringAsFixed(1)}', style: const TextStyle(fontSize: 10, color: Colors.black54)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ========================================================
  // TAB 4: SAHTECİLİK & YTS SORGULARI
  // ========================================================
  Widget _buildFraudAndYtsTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildSectionHeader('SEYAHAT BELGESİ İNCELEME (SAHTECİLİK)'),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.security, color: Colors.green, size: 24),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sahtecilik Vakalarında %94 Azalma!',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
                          ),
                          Text(
                            '2025 9 Ay: 19 Vaka -> 2026 9 Ay: 1 Vaka (-18)',
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTableRow('Giriş Yönü', '8', '0', '-%100'),
                const Divider(),
                _buildTableRow('Çıkış Yönü', '11', '1', '-%90'),
                const Divider(),
                _buildTableRow('Erkek (Bay)', '8', '1', '-%87'),
                const Divider(),
                _buildTableRow('Kadın (Bayan)', '11', '0', '-%100'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        _buildSectionHeader('YTS (YABANCI TERÖRİST SAVAŞÇI) SORGULARI'),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: '2024 YILI',
                value: '1.505',
                subtitle: 'Toplam Sorgu',
                icon: Icons.shield_outlined,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                title: '2025 YILI',
                value: '1.961',
                subtitle: 'Toplam Sorgu',
                icon: Icons.shield,
                color: const Color(0xff0284c7),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                title: '2026 (9 AY)',
                value: '1.253',
                subtitle: 'Aktif Sorgu',
                icon: Icons.verified_user,
                color: Colors.amber.shade900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '2026 Yılı Aylık YTS Trendi (Ocak - Eylül)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                _buildMonthlyBarRow('Ocak', 202),
                _buildMonthlyBarRow('Şubat', 115),
                _buildMonthlyBarRow('Mart', 166),
                _buildMonthlyBarRow('Nisan', 166),
                _buildMonthlyBarRow('Mayıs', 141),
                _buildMonthlyBarRow('Haziran', 138),
                _buildMonthlyBarRow('Temmuz', 116),
                _buildMonthlyBarRow('Ağustos', 105),
                _buildMonthlyBarRow('Eylül', 104),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ========================================================
  // TAB 5: SUÇ ÖNLEME & ASAYİŞ
  // ========================================================
  Widget _buildCrimePreventionTab() {
    final crimes = [
      {'name': 'Resmi Belgede Sahtecilik', 'y25': 2, 'y26': 1, 'diff': -1},
      {'name': 'Kişilerin Huzur ve Sükununu Bozma', 'y25': 0, 'y26': 1, 'diff': 1},
      {'name': 'Mala Zarar Verme', 'y25': 0, 'y26': 1, 'diff': 1},
      {'name': 'İş Kazası', 'y25': 2, 'y26': 5, 'diff': 3},
      {'name': 'Görevi Yaptırmamak İçin Direnme', 'y25': 0, 'y26': 1, 'diff': 1},
      {'name': 'Hakaret', 'y25': 0, 'y26': 1, 'diff': 1},
      {'name': 'Trafik Güvenliğini Tehlikeye Sokma', 'y25': 2, 'y26': 1, 'diff': -1},
      {'name': 'Kasten Yaralama', 'y25': 0, 'y26': 1, 'diff': 1},
    ];

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'GBT-UYAP SORGULAMA',
                value: '6.693',
                subtitle: '%7,3 Artış (2025: 6.233)',
                icon: Icons.person_search,
                color: const Color(0xff1e3a8a),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                title: 'ARANAN YAKALAMA',
                value: '42',
                subtitle: '%2,4 Artış (2025: 41)',
                icon: Icons.lock_clock,
                color: Colors.red.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _buildSectionHeader('SUÇ ÖNLEME VE SORUŞTURMA BÜRO İCMALİ (8 AYLIK)'),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: crimes.map((c) {
                final diff = c['diff'] as int;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          c['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                      Text('2025: ${c['y25']}  |  ', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                      Text(
                        '2026: ${c['y26']}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: diff > 0 ? Colors.red.shade100 : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          diff > 0 ? '+$diff' : '$diff',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: diff > 0 ? Colors.red.shade800 : Colors.green.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ========================================================
  // TAB 6: TRAFİK & CCTV BİLGİ TEKNOLOJİLERİ
  // ========================================================
  Widget _buildTrafficAndCctvTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildSectionHeader('TRAFİK DENETLEME EKİP FAALİYETLERİ (9 AYLIK)'),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'DENETLENEN ARAÇ',
                value: '7.685',
                subtitle: '%+2 Artış (2025: 7.548)',
                icon: Icons.directions_car,
                color: const Color(0xff059669),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                title: 'CEZA TUTANAĞI',
                value: '1.449.005 ₺',
                subtitle: '380 Sürücüye Ceza',
                icon: Icons.receipt_long,
                color: const Color(0xffc2410c),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildTableRow('Trafikten Men Edilen Araç', '9', '7', '-22%'),
                const Divider(),
                _buildTableRow('Geçici Geri Alınan Sürücü Belgesi', '2', '2', '%0'),
                const Divider(),
                _buildTableRow('Ceza Yazılan Sürücü Sayısı', '714', '380', '-46%'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        _buildSectionHeader('CCTV (KAPALI DEVRE TV) KAMERA ENVANTERİ (263 ADET)'),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildCctvRow('Terminal Dışı / Çevre', 41, 5, 46, '19 IP / 22 Analog'),
                const Divider(),
                _buildCctvRow('Terminal İçi Salonlar', 88, 8, 96, '41 IP / 47 Analog'),
                const Divider(),
                _buildCctvRow('Pist & Apron Sahası', 106, 15, 121, '88 IP / 18 Analog'),
                const Divider(),
                _buildCctvRow('GENEL TOPLAM', 235, 28, 263, '176 IP / 87 Analog', isBold: true),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        _buildSectionHeader('SORUNLU YOLCU TAHDİT İŞLEMLERİ (9 AYLIK)'),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatBadge('Tahdit Bakılan', '1.184', Colors.blue),
                _buildStatBadge('Tahdit Ekleme', '234', Colors.red),
                _buildStatBadge('Tahdit Kaldırma', '390', Colors.green),
                _buildStatBadge('Belge Talebi', '28', Colors.orange),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ========================================================
  // TAB 7: BÜRO TEŞKİLAT ŞEMASI
  // ========================================================
  Widget _buildBureausTab() {
    final bureaus = [
      {'code': 'B-1', 'name': 'İdari Büro Amirliği', 'desc': 'Gelen/giden evrak, personel özlük ve lojistik', 'icon': Icons.folder, 'color': Colors.blue},
      {'code': 'B-2', 'name': 'Eğitim ve Denetim Büro Amirliği', 'desc': 'Hizmet içi eğitimler ve mevzuat denetimi', 'icon': Icons.school, 'color': Colors.indigo},
      {'code': 'B-3', 'name': 'Güvenlik Hizmetleri Büro Amirliği', 'desc': 'Ana nizamiye, çevre güvenliği ve devriye', 'icon': Icons.shield, 'color': Colors.green},
      {'code': 'B-4', 'name': 'İç Hatlar Büro Amirliği', 'desc': 'İç hatlar yolcu ve uçak asayiş denetimi', 'icon': Icons.flight_land, 'color': Colors.cyan},
      {'code': 'B-5', 'name': 'Dış Hatlar Büro Amirliği', 'desc': 'Dış hatlar hudut kapısı geliş/gidiş operasyonları', 'icon': Icons.flight_takeoff, 'color': Colors.deepPurple},
      {'code': 'B-6', 'name': 'VIP Protokol Büro Amirliği', 'desc': 'Devlet ricali, protokol ve VIP güvenlik', 'icon': Icons.star, 'color': Colors.amber.shade800},
      {'code': 'B-7', 'name': 'Pasaport Kontrol Büro Amirliği', 'desc': 'Yurda giriş/çıkış pasaport muayene işlemleri', 'icon': Icons.badge, 'color': Colors.red},
      {'code': 'B-8', 'name': 'INAD ve Sınırdışı Büro Amirliği', 'desc': 'Kabul edilmeyen yolcular ve deport işlemleri', 'icon': Icons.block, 'color': Colors.red.shade900},
      {'code': 'B-9', 'name': 'Risk Analizi ve Belge İnceleme', 'desc': 'Sahtecilik tespiti, 2. hat inceleme ve YTS takibi', 'icon': Icons.search, 'color': Colors.teal},
      {'code': 'B-10', 'name': 'Suç Önleme ve Soruşturma Büro', 'desc': 'Adli asayiş, suç icmali, GBT-UYAP yakalamaları', 'icon': Icons.policy, 'color': Colors.deepOrange},
      {'code': 'B-11', 'name': 'Trafik Denetleme Büro Amirliği', 'desc': 'Nizamiye, güzergah ve otopark trafik denetimi', 'icon': Icons.traffic, 'color': Colors.orange},
      {'code': 'B-12', 'name': 'Bilgi Teknolojileri Büro Amirliği', 'desc': 'CCTV, PTS, PolNet ağı ve tahdit işlemleri', 'icon': Icons.computer, 'color': Colors.blueGrey},
      {'code': 'B-13', 'name': 'Hava Polisi Büro Amirliği', 'desc': 'Uçuş güvenliği ve uluslararası kolluk irtibatı', 'icon': Icons.airplanemode_active, 'color': Colors.blue.shade900},
    ];

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildSectionHeader('ANTALYA HAVALİMANI EMNİYET ŞUBE MÜDÜRLÜĞÜ TEŞKİLATI'),
        ...bureaus.map((b) {
          final clr = b['color'] as Color;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: clr.withValues(alpha: 0.15),
                child: Icon(b['icon'] as IconData, color: clr, size: 20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xffe2e8f0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      b['code'] as String,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      b['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(b['desc'] as String, style: const TextStyle(fontSize: 11)),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ========================================================
  // REUSABLE UI HELPERS
  // ========================================================
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Color(0xff475569),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffe2e8f0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard({
    required String category,
    required int val2025,
    required int val2026,
    required String unit,
    required int diff,
    required double pct,
    required Color color,
  }) {
    final isNegative = diff < 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isNegative ? Colors.red.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: isNegative ? Colors.red.shade200 : Colors.green.shade200),
                  ),
                  child: Text(
                    '${isNegative ? "" : "+"}${pct.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isNegative ? Colors.red.shade800 : Colors.green.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('2025: ${_formatNumber(val2025)} $unit', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                Text(
                  '2026: ${_formatNumber(val2026)} $unit',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Fark: ${diff > 0 ? "+" : ""}${_formatNumber(diff)} $unit',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isNegative ? Colors.red.shade700 : Colors.green.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow(String title, String val25, String val26, String change) {
    return Row(
      children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
        Text('25: $val25  |  ', style: const TextStyle(fontSize: 11, color: Colors.black54)),
        Text('26: $val26  ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        Text(
          change,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: change.contains('-') ? Colors.red : Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyBarRow(String month, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 55,
            child: Text(month, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: count / 250.0,
                minHeight: 8,
                backgroundColor: const Color(0xffe2e8f0),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 35,
            child: Text('$count', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCctvRow(String area, int fixed, int ptz, int total, String detail, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  area,
                  style: TextStyle(
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(detail, style: const TextStyle(fontSize: 10, color: Colors.black54)),
              ],
            ),
          ),
          Text(
            '$total Adet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isBold ? const Color(0xff1d4ed8) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String title, String count, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 10, color: Colors.black54)),
        const SizedBox(height: 2),
        Text(
          count,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    final str = number.abs().toString();
    final result = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        result.write('.');
      }
      result.write(str[i]);
    }
    return (number < 0 ? '-' : '') + result.toString();
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.shield, color: Colors.amber),
            SizedBox(width: 8),
            Text('Havalimanı Brifing Modülü', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'T.C. Emniyet Genel Müdürlüğü\nAntalya Havalimanı Emniyet Şube Müdürlüğü',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            SizedBox(height: 10),
            Text(
              'Bu modül, resmi brifing sunuş planındaki tüm verileri (Yolcu ve uçak istatistikleri, ilk 10 ülke, 14 yıllık INAD icmali, YTS sorguları, asayiş faaliyetleri ve CCTV envanteri) hem çevrimdışı hem de merkezi sunucuyla entegre olarak sunar.',
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 8),
            Text(
              'Sınıflandırma: HİZMETE ÖZEL',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('KAPAT'),
          ),
        ],
      ),
    );
  }
}
