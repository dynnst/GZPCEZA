import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:country_picker/country_picker.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'country_codes.dart';
import 'app_localizations.dart';

void main() {
  runApp(const CezamApp());
}

class CezamApp extends StatefulWidget {
  const CezamApp({super.key});

  @override
  State<CezamApp> createState() => _CezamAppState();
}

class _CezamAppState extends State<CezamApp> {
  Locale _locale = const Locale('tr');

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('appLanguage') ?? 'tr';
    if (!mounted) return;
    setState(() => _locale = Locale(code));
  }

  Future<void> _changeLocale(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appLanguage', code);
    if (!mounted) return;
    setState(() => _locale = Locale(code));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => context.tr('app_title'),
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        CountryLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff0a7cff)),
        useMaterial3: true,
      ),
      home: CalculatorPage(
        locale: _locale,
        onLocaleChanged: _changeLocale,
      ),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({
    this.locale = const Locale('tr'),
    this.onLocaleChanged,
    super.key,
  });

  final Locale locale;
  final ValueChanged<String>? onLocaleChanged;

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final _calculator = PenaltyCalculator();
  final List<EntryExitControllers> _entryExitRows = [EntryExitControllers()];
  final _birthController = TextEditingController();
  final _manualOneTimeController = TextEditingController(text: '90');
  final _manualLongController = TextEditingController(text: '90');
  final _consularVisaDaysController = TextEditingController();
  final _specialVisaDateController = TextEditingController();
  final _firstMonthController = TextEditingController(text: '0');
  final _monthStepController = TextEditingController(text: '0');
  final _dayStartController = TextEditingController(text: '0');
  final _dayStepController = TextEditingController(text: '0');
  final _defterController = TextEditingController(text: '0');
  final _visaFeeController = TextEditingController(text: '0');
  final _usdController = TextEditingController(text: '1');
  final _eurController = TextEditingController(text: '1');
  final _gbpController = TextEditingController(text: '1');
  final _apiUrlController = TextEditingController(text: 'http://10.0.2.2:5089');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adminUserEmailController = TextEditingController();
  final _adminSubscriptionDaysController = TextEditingController(text: '30');
  final _printNameController = TextEditingController();
  final _printPassportController = TextEditingController();
  final _printPoliceController = TextEditingController();
  final _printFatherController = TextEditingController();
  final _printMotherController = TextEditingController();

  CezamData _data = CezamData.empty();
  PenaltyResult? _result;
  List<DateRange> _lastCalculatedRanges = [];
  String? _error;
  String? _authToken;
  String? _authEmail;
  String? _authRole;
  String? _authPlanName;
  int? _authDailyLimit;
  int? _authUsedToday;
  int? _authRemainingToday;
  String _adminPlanCode = 'standard';
  List<Map<String, dynamic>> _adminUsers = [];
  String _country = '';
  int _passport = 1;
  int _visa = 2;
  int _calculateType = 1;
  int _adultType = 2;
  int _paymentType = 1;
  String _currency = 'USD';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    for (final row in _entryExitRows) {
      row.dispose();
    }
    _birthController.dispose();
    _manualOneTimeController.dispose();
    _manualLongController.dispose();
    _consularVisaDaysController.dispose();
    _specialVisaDateController.dispose();
    _firstMonthController.dispose();
    _monthStepController.dispose();
    _dayStartController.dispose();
    _dayStepController.dispose();
    _defterController.dispose();
    _visaFeeController.dispose();
    _usdController.dispose();
    _eurController.dispose();
    _gbpController.dispose();
    _apiUrlController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _adminUserEmailController.dispose();
    _adminSubscriptionDaysController.dispose();
    _printNameController.dispose();
    _printPassportController.dispose();
    _printPoliceController.dispose();
    _printFatherController.dispose();
    _printMotherController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('cezam_data');
    final raw = stored ?? await rootBundle.loadString('assets/cezam_data.json');
    final data = CezamData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    setState(() {
      _data = data;
      _applyDataDefaults(data);
      _applyStoredSettings(prefs);
      final countries = countriesForSelection(data.countries);
      _country = countries.isNotEmpty ? countries.first : '';
    });
    _syncSystemSettingsWithApi(silent: true);
  }

  void _applyDataDefaults(CezamData data) {
    _usdController.text = data.exchange['USD']?.toString() ?? '1';
    _eurController.text = data.exchange['EUR']?.toString() ?? '1';
    _gbpController.text = data.exchange['GBP']?.toString() ?? '1';
    _defterController.text = data.defterPrice.toString();
    if (data.tgvh.isNotEmpty) {
      _visaFeeController.text = data.tgvh.last.price.toString();
    }
  }

  void _applyStoredSettings(SharedPreferences prefs) {
    _manualOneTimeController.text =
        prefs.getString('manualOneTime') ?? _manualOneTimeController.text;
    _manualLongController.text =
        prefs.getString('manualLong') ?? _manualLongController.text;
    _firstMonthController.text =
        prefs.getString('firstMonth') ?? _firstMonthController.text;
    _monthStepController.text =
        prefs.getString('monthStep') ?? _monthStepController.text;
    _dayStartController.text =
        prefs.getString('dayStart') ?? _dayStartController.text;
    _dayStepController.text =
        prefs.getString('dayStep') ?? _dayStepController.text;
    _defterController.text =
        prefs.getString('defter') ?? _defterController.text;
    _visaFeeController.text =
        prefs.getString('visaFee') ?? _visaFeeController.text;
    _usdController.text = prefs.getString('usd') ?? _usdController.text;
    _eurController.text = prefs.getString('eur') ?? _eurController.text;
    _gbpController.text = prefs.getString('gbp') ?? _gbpController.text;
    _currency = prefs.getString('currency') ?? _currency;
    _apiUrlController.text =
        prefs.getString('apiUrl') ?? _apiUrlController.text;
    _authToken = prefs.getString('authToken');
    _authEmail = prefs.getString('authEmail');
    _authRole = prefs.getString('authRole');
    _authPlanName = prefs.getString('authPlanName');
    _authDailyLimit = prefs.getInt('authDailyLimit');
    _authUsedToday = prefs.getInt('authUsedToday');
    _authRemainingToday = prefs.getInt('authRemainingToday');
    _paymentType = prefs.getString('paymentType') == null
        ? _paymentType
        : asInt(prefs.getString('paymentType'));
    if (!paymentOptionsForVisa(_visa)
        .any((option) => option.value == _paymentType)) {
      _paymentType = paymentOptionsForVisa(_visa).first.value;
    }
  }

  Future<void> _saveManualSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('manualOneTime', _manualOneTimeController.text);
    await prefs.setString('manualLong', _manualLongController.text);
    await prefs.setString('firstMonth', _firstMonthController.text);
    await prefs.setString('monthStep', _monthStepController.text);
    await prefs.setString('dayStart', _dayStartController.text);
    await prefs.setString('dayStep', _dayStepController.text);
    await prefs.setString('defter', _defterController.text);
    await prefs.setString('visaFee', _visaFeeController.text);
    await prefs.setString('usd', _usdController.text);
    await prefs.setString('eur', _eurController.text);
    await prefs.setString('gbp', _gbpController.text);
    await prefs.setString('currency', _currency);
    await prefs.setString('paymentType', _paymentType.toString());
    await prefs.setString('apiUrl', _apiUrlController.text.trim());
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final isBirthDate = identical(controller, _birthController);
    final currentValue = parseDate(controller.text);
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: isBirthDate ? now : DateTime(now.year + 2),
      initialDate: currentValue ??
          (isBirthDate ? DateTime(now.year - 18, now.month, now.day) : now),
    );
    if (picked != null) {
      setState(() {
        controller.text = formatDate(picked);
        if (isBirthDate) {
          _adultType = isChildOn(picked, now) ? 1 : 2;
        }
      });
    }
  }

  Future<void> _importJsonFromClipboard() async {
    if (!_isAdmin) {
      _showMessage('Bu alan sadece admin tarafindan kullanilabilir.');
      return;
    }

    try {
      final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
      final text = clipboard?.text;
      if (text == null || text.trim().isEmpty) {
        _showMessage('Panoda JSON metni yok. Once JSON metnini kopyalayin.');
        return;
      }
      final decoded = jsonDecode(text) as Map<String, dynamic>;
      final data = CezamData.fromJson(decoded);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cezam_data', jsonEncode(decoded));
      setState(() {
        _data = data;
        _applyDataDefaults(data);
        final countries = countriesForSelection(data.countries);
        _country = countries.isNotEmpty ? countries.first : '';
        _error = null;
      });
      _showMessage('JSON verisi ice aktarildi.');
    } catch (e) {
      _showMessage('Panodaki metin gecerli CEZAM JSON formati degil.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.tr(message))));
  }

  String get _apiBaseUrl =>
      _apiUrlController.text.trim().replaceFirst(RegExp(r'/+$'), '');

  bool get _isAdmin => _authRole == 'admin';

  Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  Future<bool> _syncSystemSettingsWithApi({bool silent = false}) async {
    try {
      final response = await http
          .get(Uri.parse('$_apiBaseUrl/system-settings'), headers: _jsonHeaders)
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final usd = (json['usd'] as num?)?.toDouble();
        final eur = (json['eur'] as num?)?.toDouble();
        final gbp = (json['gbp'] as num?)?.toDouble();
        final singleEntryVisaFee =
            (json['singleEntryVisaFee'] as num?)?.toDouble();
        final defterPrice = (json['defterPrice'] as num?)?.toDouble();

        if (usd != null || singleEntryVisaFee != null || defterPrice != null) {
          final tgvh = [..._data.tgvh];
          if (singleEntryVisaFee != null) {
            final fee = TgvhRule(
                year: DateTime.now().year.toString(),
                price: singleEntryVisaFee);
            if (tgvh.isEmpty) {
              tgvh.add(fee);
            } else {
              tgvh[tgvh.length - 1] = fee;
            }
          }

          final updatedData = CezamData(
            generatedAt: _data.generatedAt,
            exchange: {
              'USD': usd ?? _data.exchange['USD'] ?? 1.0,
              'EUR': eur ?? _data.exchange['EUR'] ?? 1.0,
              'GBP': gbp ?? _data.exchange['GBP'] ?? 1.0,
              'TRY': 1.0,
            },
            defterPrice: defterPrice ?? _data.defterPrice,
            embeddedCountries: _data.embeddedCountries,
            tgvh: tgvh,
            uvr: _data.uvr,
            auh: _data.auh,
            tkod: _data.tkod,
          );

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              'cezam_data', jsonEncode(updatedData.toJson()));

          if (mounted) {
            setState(() {
              _data = updatedData;
              _applyDataDefaults(updatedData);
            });
            if (!silent) {
              _showMessage(
                  'Sistem ayarları sunucudan başarıyla güncellendi.');
            }
          }
          return true;
        }
      }
    } catch (_) {
      // Offline fallback
    }
    return false;
  }

  Future<bool> _saveSettingsToServer(CezamData data) async {
    if (!_isAdmin) return false;
    if (_authToken == 'local-admin' || _authToken == null) return false;

    try {
      final lastFee = data.tgvh.isNotEmpty ? data.tgvh.last.price : null;
      final body = jsonEncode({
        'usd': data.exchange['USD'],
        'eur': data.exchange['EUR'],
        'gbp': data.exchange['GBP'],
        'singleEntryVisaFee': lastFee,
        'defterPrice': data.defterPrice,
      });

      final response = await http
          .post(
            Uri.parse('$_apiBaseUrl/system-settings'),
            headers: _jsonHeaders,
            body: body,
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> _saveAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiUrl', _apiUrlController.text.trim());
    if (_authToken == null) {
      await prefs.remove('authToken');
      await prefs.remove('authEmail');
      await prefs.remove('authRole');
      await prefs.remove('authPlanName');
      await prefs.remove('authDailyLimit');
      await prefs.remove('authUsedToday');
      await prefs.remove('authRemainingToday');
      return;
    }

    await prefs.setString('authToken', _authToken!);
    await prefs.setString('authEmail', _authEmail ?? '');
    await prefs.setString('authRole', _authRole ?? 'user');
    await prefs.setString('authPlanName', _authPlanName ?? '');
    await prefs.setInt('authDailyLimit', _authDailyLimit ?? 0);
    await prefs.setInt('authUsedToday', _authUsedToday ?? 0);
    await prefs.setInt('authRemainingToday', _authRemainingToday ?? 0);
  }

  Future<bool> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showMessage('msg_credentials');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/auth/login'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode != 200) {
        if (await _loginLocalAdmin(email, password)) {
          return true;
        }
        _showMessage(
            'Giris basarisiz. E-posta, sifre veya API adresini kontrol edin.');
        return false;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      setState(() {
        _authToken = body['token'] as String?;
        _authEmail = body['email'] as String?;
        _authRole = body['role'] as String? ?? 'user';
        _authPlanName = body['planName'] as String?;
        _authDailyLimit = asInt(body['dailyLimit']);
        _authUsedToday = null;
        _authRemainingToday = _authDailyLimit;
      });
      await _saveAuthState();
      if (!mounted) return false;
      _showMessage(context.trValue(
          'msg_login_success', _authPlanName ?? 'subscription'));
      return true;
    } catch (_) {
      if (await _loginLocalAdmin(email, password)) {
        return true;
      }
      _showMessage('msg_api_unavailable');
      return false;
    }
  }

  Future<bool> _loginLocalAdmin(String email, String password) async {
    if (email.toLowerCase() != 'admin@test.local' || password != '123456') {
      return false;
    }

    setState(() {
      _authToken = 'local-admin';
      _authEmail = 'admin@test.local';
      _authRole = 'admin';
      _authPlanName = 'Admin';
      _authDailyLimit = 0;
      _authUsedToday = 0;
      _authRemainingToday = 0;
    });
    await _saveAuthState();
    _showMessage(
        'Yerel admin girisi yapildi. API olmadan hesaplama kullanilabilir.');
    return true;
  }

  Future<void> _logout() async {
    setState(() {
      _authToken = null;
      _authEmail = null;
      _authRole = null;
      _authPlanName = null;
      _authDailyLimit = null;
      _authUsedToday = null;
      _authRemainingToday = null;
    });
    await _saveAuthState();
    _showMessage('msg_logout');
  }

  Future<bool> _consumeUsageOrAskLogin() async {
    if (_authToken == null) {
      _showMessage('msg_login_required');
      await _showAccountDialog();
      return false;
    }

    if (_authToken == 'local-admin' && _isAdmin) {
      return true;
    }

    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/usage/consume'),
        headers: _jsonHeaders,
      );

      if (response.statusCode == 401) {
        await _logout();
        _showMessage('msg_session_expired');
        await _showAccountDialog();
        return false;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      setState(() {
        _authEmail = body['email'] as String? ?? _authEmail;
        _authRole = body['role'] as String? ?? _authRole;
        _authPlanName = body['planName'] as String? ?? _authPlanName;
        _authDailyLimit = asInt(body['dailyLimit']);
        _authUsedToday = asInt(body['usedToday']);
        _authRemainingToday = asInt(body['remainingToday']);
      });
      await _saveAuthState();

      if (response.statusCode != 200 || body['allowed'] != true) {
        _showMessage(
            body['message'] as String? ?? 'Sorgu hakki kullanilamadi.');
        await _showPlansDialog();
        return false;
      }

      return true;
    } catch (_) {
      _showMessage('msg_subscription_unavailable');
      return false;
    }
  }

  Future<void> _showPlansDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('subscription_plans')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _planCard(
                title: context.tr('standard'),
                dailyLimit: context.tr('per_day_1'),
                description: context.tr('basic_plan'),
                planCode: 'standard',
                highlighted: _authPlanName == 'Standart',
              ),
              const SizedBox(height: 10),
              _planCard(
                title: context.tr('silver'),
                dailyLimit: context.tr('per_day_3'),
                description: context.tr('regular_plan'),
                planCode: 'silver',
                highlighted:
                    _authPlanName == 'Gümüş' || _authPlanName == 'Gumus',
              ),
              const SizedBox(height: 10),
              _planCard(
                title: context.tr('gold'),
                dailyLimit: context.tr('per_day_5'),
                description: context.tr('heavy_plan'),
                planCode: 'gold',
                highlighted:
                    _authPlanName == 'Altın' || _authPlanName == 'Altin',
              ),
              const SizedBox(height: 12),
              Text(
                'Test asamasinda satin alma Google Play yerine admin onayi ile aktif edilir.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.tr('close')),
          ),
        ],
      ),
    );
  }

  Widget _planCard({
    required String title,
    required String dailyLimit,
    required String description,
    required String planCode,
    required bool highlighted,
  }) {
    return Card(
      color:
          highlighted ? Theme.of(context).colorScheme.primaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(dailyLimit, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(description),
            const SizedBox(height: 10),
            FilledButton.tonal(
              onPressed: () => _requestPlan(planCode, title),
              child: Text(
                  highlighted ? context.tr('current_plan') : context.tr('buy')),
            ),
          ],
        ),
      ),
    );
  }

  void _requestPlan(String planCode, String title) {
    if (_authToken == null) {
      Navigator.of(context).pop();
      _showMessage('msg_plan_login_required');
      _showAccountDialog();
      return;
    }

    _showMessage(
        '$title paketi test asamasinda admin tarafindan aktif edilir.');
  }

  Future<void> _showAccountDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(context.tr('account')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _apiUrlController,
                  decoration:
                      InputDecoration(labelText: context.tr('api_address')),
                ),
                const SizedBox(height: 12),
                if (_authToken != null) ...[
                  Text('${context.tr('signed_in')}: ${_authEmail ?? '-'}'),
                  Text(
                      '${context.tr('role')}: ${_isAdmin ? context.tr('admin') : context.tr('user')}'),
                  Text('${context.tr('plan')}: ${_authPlanName ?? '-'}'),
                  if (_isAdmin)
                    Text(context.tr('daily_unlimited'))
                  else ...[
                    Text(
                        context.trValue('daily_limit', _authDailyLimit ?? '-')),
                    Text(context.trValue('used_today', _authUsedToday ?? 0)),
                    Text(context.trValue('remaining',
                        _authRemainingToday ?? _authDailyLimit ?? '-')),
                  ],
                ] else ...[
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: context.tr('email')),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration:
                        InputDecoration(labelText: context.tr('password')),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Test hesaplari: admin@test.local, standard@test.local, gumus@test.local, altin@test.local. Sifre: 123456',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showPlansDialog();
              },
              child: Text(context.tr('plans')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.tr('close')),
            ),
            if (_authToken != null)
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _logout();
                },
                child: Text(context.tr('logout')),
              )
            else
              FilledButton(
                onPressed: () async {
                  final ok = await _login();
                  if (ok && context.mounted) Navigator.of(context).pop();
                },
                child: Text(context.tr('login')),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadAdminUsers() async {
    if (!_isAdmin) {
      _showMessage('Kullanici yonetimi sadece admin icindir.');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/admin/users'),
        headers: _jsonHeaders,
      );

      if (response.statusCode == 401) {
        await _logout();
        _showMessage('Admin oturumu suresi doldu.');
        return;
      }

      if (response.statusCode != 200) {
        _showMessage('Kullanici listesi alinamadi.');
        return;
      }

      final body = jsonDecode(response.body) as List<dynamic>;
      setState(() {
        _adminUsers =
            body.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      });
    } catch (_) {
      _showMessage('Admin API baglantisi kurulamadi.');
    }
  }

  Future<bool> _assignUserPlan() async {
    if (!_isAdmin) {
      _showMessage('Bu islem sadece admin icindir.');
      return false;
    }

    final email = _adminUserEmailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Kullanici e-postasi giriniz.');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/admin/assign-plan'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'email': email,
          'planCode': _adminPlanCode,
          'days': max(1, readInt(_adminSubscriptionDaysController)),
        }),
      );

      if (response.statusCode == 401) {
        await _logout();
        _showMessage('Admin oturumu suresi doldu.');
        return false;
      }

      if (response.statusCode != 200) {
        _showMessage(response.statusCode == 404
            ? 'Kullanici bulunamadi.'
            : 'Paket guncellenemedi.');
        return false;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      _showMessage(
          '${body['email']} icin paket guncellendi: ${body['planName']}');
      await _loadAdminUsers();
      return true;
    } catch (_) {
      _showMessage('Admin API baglantisi kurulamadi.');
      return false;
    }
  }

  Future<void> _showAdminUsersDialog() async {
    if (!_isAdmin) {
      _showMessage('Kullanici yonetimi sadece admin icindir.');
      return;
    }

    await _loadAdminUsers();
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Kullanici Yonetimi'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _adminUserEmailController,
                    decoration:
                        const InputDecoration(labelText: 'Kullanici e-postasi'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _adminPlanCode,
                    decoration: const InputDecoration(labelText: 'Paket'),
                    items: const [
                      DropdownMenuItem(
                          value: 'standard', child: Text('Standart - 1/gun')),
                      DropdownMenuItem(
                          value: 'silver', child: Text('Gumus - 3/gun')),
                      DropdownMenuItem(
                          value: 'gold', child: Text('Altin - 5/gun')),
                    ],
                    onChanged: (value) {
                      setState(() => _adminPlanCode = value ?? 'standard');
                      setDialogState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  _numberField(
                      'Abonelik gunu', _adminSubscriptionDaysController),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Kayitli kullanicilar',
                        style: Theme.of(context).textTheme.titleSmall),
                  ),
                  const SizedBox(height: 8),
                  ..._adminUsers.map((user) {
                    final email = user['email']?.toString() ?? '';
                    final planCode = user['planCode']?.toString() ?? 'standard';
                    final planName = user['planName']?.toString() ?? '';
                    final role = user['role']?.toString() ?? 'user';
                    final expiresAt =
                        user['subscriptionExpiresAtUtc']?.toString() ?? '';
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(email),
                      subtitle:
                          Text('$role - $planName - ${_shortDate(expiresAt)}'),
                      onTap: () {
                        _adminUserEmailController.text = email;
                        setState(() => _adminPlanCode = planCode);
                        setDialogState(() {});
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kapat'),
            ),
            TextButton.icon(
              onPressed: () async {
                await _loadAdminUsers();
                setDialogState(() {});
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Yenile'),
            ),
            FilledButton(
              onPressed: () async {
                final ok = await _assignUserPlan();
                if (ok) setDialogState(() {});
              },
              child: const Text('Paketi Guncelle'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSettingsDialog() async {
    if (!_isAdmin) {
      _showMessage('Ayarlar ve veri alani sadece admin icindir.');
      return;
    }

    final updated = await Navigator.of(context).push<SystemSettingsResult>(
      MaterialPageRoute(
        builder: (_) => SystemSettingsPage(
          initialData: _data,
          apiBaseUrl: _apiBaseUrl,
          authToken: _authToken,
          isAdmin: _isAdmin,
          initialManualSettings: ManualCalculationSettings(
            oneTime: readInt(_manualOneTimeController),
            longStay: readInt(_manualLongController),
            firstMonth: readDouble(_firstMonthController),
            monthStep: readDouble(_monthStepController),
            dayStart: readDouble(_dayStartController),
            dayStep: readDouble(_dayStepController),
            currency: _currency,
          ),
        ),
      ),
    );
    if (updated == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cezam_data', jsonEncode(updated.data.toJson()));
    if (!mounted) return;
    setState(() {
      _data = updated.data;
      _applyDataDefaults(updated.data);
      _manualOneTimeController.text = updated.manualSettings.oneTime.toString();
      _manualLongController.text = updated.manualSettings.longStay.toString();
      _firstMonthController.text = updated.manualSettings.firstMonth.toString();
      _monthStepController.text = updated.manualSettings.monthStep.toString();
      _dayStartController.text = updated.manualSettings.dayStart.toString();
      _dayStepController.text = updated.manualSettings.dayStep.toString();
      _currency = updated.manualSettings.currency;
      if (!updated.data.countries.contains(_country)) {
        final countries = countriesForSelection(updated.data.countries);
        _country = countries.isEmpty ? '' : countries.first;
      }
      _error = null;
    });
    await _saveManualSettings();
    final serverOk = await _saveSettingsToServer(updated.data);
    if (serverOk) {
      _showMessage(
          'Sistem ayarları sunucuya ve yerel önbelleğe kaydedildi.');
    } else {
      _showMessage(
          'Sistem ayarları çevrimdışı olarak kaydedildi.');
    }
  }

  Future<void> _calculate() async {
    try {
      final ranges = _readEntryExitRanges();
      final calculationRanges = _calculationRangesForVisa(ranges);
      final consularVisaDays = readInt(_consularVisaDaysController);
      if (_visa == 3 && consularVisaDays <= 0) {
        throw const FormatException('error_consular_days');
      }

      final manualRule = UvrRule(
        country: _country.isEmpty ? 'Manuel' : _country,
        calculateType: _calculateType,
        passportType: _passport,
        visaStatus: _visa,
        day: 180,
        longStay: readInt(_manualLongController),
        oneTime: readInt(_manualOneTimeController),
        visaFeeEnabled: readDouble(_visaFeeController) > 0 ? 1 : 0,
      );

      if (!_isAdmin) {
        final hasMainRule =
            _data.findUvr(_country, _passport, _visa, _calculateType) != null;
        final hasMainFeeRule = _data.findAuh(_country) != null;
        if (!hasMainRule || !hasMainFeeRule) {
          throw const FormatException('error_data_missing');
        }
      }

      final settings = PenaltySettings(
        country: _country,
        passport: _passport,
        visa: _visa,
        consularVisaDays: consularVisaDays,
        calculateType: _calculateType,
        adultType: _adultType,
        entryExitPairs: calculationRanges,
        manualRule: manualRule,
        manualAuh: AuhRule(
          country: _country,
          firstMonth: readDouble(_firstMonthController),
          monthStep: readDouble(_monthStepController),
          dayStart: readDouble(_dayStartController),
          dayStep: readDouble(_dayStepController),
          currency: _currency,
        ),
        exchange: {
          'USD': readDouble(_usdController),
          'EUR': readDouble(_eurController),
          'GBP': readDouble(_gbpController),
          'TRY': 1,
        },
        defterPrice: readDouble(_defterController),
        visaFee: readDouble(_visaFeeController),
        paymentType: _paymentType,
      );

      final result = _calculator.calculate(settings, _data);
      final canCalculate = await _consumeUsageOrAskLogin();
      if (!canCalculate) {
        return;
      }

      setState(() {
        _result = result;
        _lastCalculatedRanges = calculationRanges;
        _error = null;
      });
      if (_isAdmin) {
        _saveManualSettings();
      }
    } catch (e) {
      setState(() {
        _result = null;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<DateRange> _readEntryExitRanges() {
    final ranges = <DateRange>[];
    for (var index = 0; index < _entryExitRows.length; index += 1) {
      final row = _entryExitRows[index];
      final entry = parseDate(row.entry.text);
      final exit = parseDate(row.exit.text);
      if (entry == null || exit == null) {
        throw FormatException('error_row_date:${index + 1}');
      }

      ranges.add(DateRange(entry, exit));
    }

    ranges.sort((a, b) => a.entry.compareTo(b.entry));
    return ranges;
  }

  List<DateRange> _calculationRangesForVisa(List<DateRange> ranges) {
    if (_visa == 7 && ranges.length > 1) {
      throw const FormatException('error_v84_single');
    }

    if (!_usesSpecialVisaDate(_visa)) return ranges;

    final specialDate = parseDate(_specialVisaDateController.text);
    if (specialDate == null) {
      throw const FormatException('error_notice_date');
    }

    final lastExit = ranges
        .map((range) => range.exit)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    return [DateRange(specialDate, lastExit)];
  }

  void _addEntryExitRow() {
    if (_visa == 7) {
      _showMessage('msg_v84_single');
      return;
    }

    setState(() {
      _entryExitRows.add(EntryExitControllers());
    });
  }

  void _removeEntryExitRow(int index) {
    if (_entryExitRows.length == 1) {
      _showMessage('msg_minimum_row');
      return;
    }

    setState(() {
      final removed = _entryExitRows.removeAt(index);
      removed.dispose();
    });
  }

  Future<void> _showPrintInfoDialog() async {
    if (_result == null) {
      _showMessage('msg_calculate_first');
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Print Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: _printNameController,
                  decoration: const InputDecoration(labelText: 'Name Surname')),
              const SizedBox(height: 8),
              TextField(
                  controller: _printPassportController,
                  decoration: const InputDecoration(labelText: 'Passport No')),
              const SizedBox(height: 8),
              TextField(
                  controller: _printPoliceController,
                  decoration: const InputDecoration(
                      labelText: 'Passport Police Officer / Registry No')),
              const SizedBox(height: 8),
              TextField(
                  controller: _printFatherController,
                  decoration: const InputDecoration(labelText: 'Father Name')),
              const SizedBox(height: 8),
              TextField(
                  controller: _printMotherController,
                  decoration: const InputDecoration(labelText: 'Mother Name')),
              const SizedBox(height: 8),
              _dateField('Date of Birth', _birthController),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          FilledButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              await _printViolationForm();
            },
            icon: const Icon(Icons.print),
            label: const Text('Print'),
          ),
        ],
      ),
    );
  }

  Future<void> _printViolationForm() async {
    final result = _result;
    if (result == null) return;
    await Printing.layoutPdf(
      name: 'vize-ihlali-islem-formu.pdf',
      onLayout: (_) => _buildViolationPdf(result),
    );
  }

  Future<Uint8List> _buildViolationPdf(PenaltyResult result) async {
    final paid = isPaidPaymentType(_paymentType);
    final font = pw.Font.ttf(await rootBundle.load('assets/fonts/arial.ttf'));
    final boldFont =
        pw.Font.ttf(await rootBundle.load('assets/fonts/arialbd.ttf'));
    final italicFont =
        pw.Font.ttf(await rootBundle.load('assets/fonts/ariali.ttf'));
    final boldItalicFont =
        pw.Font.ttf(await rootBundle.load('assets/fonts/arialbi.ttf'));
    final logoBytes =
        await rootBundle.load('assets/print_templates/img/goc.jpg');
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());
    final doc = pw.Document(
      theme: pw.ThemeData.withFont(
          base: font,
          bold: boldFont,
          italic: italicFont,
          boldItalic: boldItalicFont),
    );
    final today = DateTime.now();
    final canEnterDate = result.earliestReEntryDate(today);
    final name = _printNameController.text.trim().isEmpty
        ? '................................'
        : _printNameController.text.trim();
    final firstName = name.contains(' ')
        ? name.substring(0, name.lastIndexOf(' ')).trim()
        : name;
    final lastName =
        name.contains(' ') ? name.substring(name.lastIndexOf(' ')).trim() : '';
    final passport = _printPassportController.text.trim().isEmpty
        ? '................................'
        : _printPassportController.text.trim();
    final police = _printPoliceController.text.trim().isEmpty
        ? '................................'
        : _printPoliceController.text.trim();
    final approver = _authEmail ?? '................................';
    final father = _printFatherController.text.trim().isEmpty
        ? '................................'
        : _printFatherController.text.trim();
    final mother = _printMotherController.text.trim().isEmpty
        ? '................................'
        : _printMotherController.text.trim();
    final birthDate = _birthController.text.trim().isEmpty
        ? '................................'
        : _birthController.text.trim();
    final entryDate = _lastCalculatedRanges.isEmpty
        ? '-'
        : formatDate(_lastCalculatedRanges.first.entry);
    final violationTotalDays = result.violationDays;
    final values = <String, String>{
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'country': _country,
      'passport': passport,
      'police': police,
      'approver': approver,
      'father': father,
      'mother': mother,
      'birthDate': birthDate,
      'entryDate': entryDate,
      'today': formatDate(today),
      'shouldExit': formatDate(result.shouldExitDate),
      'canEnter': formatDate(canEnterDate),
      'stayDays': result.allowedStayDays.toString(),
      'violationDays': violationTotalDays.toString(),
      'fine': _legacyFineText(result),
      'banDays': result.tahditPenaltyDays.toString(),
      'code': result.tahditCode,
      'time':
          '${today.hour.toString().padLeft(2, '0')}:${today.minute.toString().padLeft(2, '0')}',
    };

    doc.addPage(_mainViolationPage(values, paid: paid));
    if (!paid) {
      doc.addPage(_preliminaryPermissionPage(values, logo));
    }
    if (!_printPersonIsChild() && _hasEntryBanCode(result.tahditCode)) {
      doc.addPage(_entryBanPage(values, logo));
    }
    return doc.save();
  }

  pw.Page _mainViolationPage(Map<String, String> v, {required bool paid}) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(34, 34, 34, 30),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _title('VİZE İHLALİ İŞLEM FORMU /VISA VIOLATION FORM'),
          pw.SizedBox(height: paid ? 26 : 18),
          paid ? _paidIdentity(v) : _unpaidIdentity(v),
          pw.SizedBox(height: paid ? 18 : 22),
          paid ? _paidInfoTable(v) : _unpaidInfoRows(v),
          pw.SizedBox(height: paid ? 18 : 28),
          paid ? _paidNotice(v) : _unpaidNotice(v),
          pw.SizedBox(height: 18),
          _dateLine(v),
          pw.SizedBox(height: 28),
          _signatureBlock(v),
          pw.SizedBox(height: 24),
          _center(
              'Formu okudum, imzaladım ve kopyasını aldım / I have read the form, signed it,and have a copy of the form',
              size: 11,
              bold: true),
          pw.SizedBox(height: 22),
          _center('O N A Y', size: 13, bold: true),
          _center('APPROVAL', size: 12),
          pw.SizedBox(height: 12),
          _center(v['approver']!, size: 12, bold: true),
          pw.SizedBox(height: paid ? 24 : 20),
          pw.Expanded(child: _legalNotes(paid: paid)),
        ],
      ),
    );
  }

  String _legacyFineText(PenaltyResult result) {
    final payType = _paymentType.toString();
    const nonPaying = {'0', '3', '5', '7', '9', '11', '15'};
    final fineWithoutDefter =
        result.total - result.defter - result.administrativeFine;
    var text = _money(fineWithoutDefter);

    if (nonPaying.contains(payType)) {
      if (result.defter != 0) text += '+DEF';
      if (payType == '5') text += '+N-96(6458/56/1-102/1-c)';
      return text;
    }

    if (result.defter != 0) {
      text += '+ DEF${_money(result.defter)}TL';
      if (payType == '4') {
        text +=
            ' İdari para cezası: ${_money(result.administrativeFine)} TL, Toplam=${_money(result.total)}';
      } else {
        text += ' Toplam=${_money(result.total)}';
      }
    } else if (payType == '4') {
      text +=
          ' İdari para cezası: ${_money(result.administrativeFine)} TL, Toplam=${_money(result.total)}';
    } else {
      text += ' Toplam=${_money(result.total)}';
    }

    return text;
  }

  String _money(double value) {
    var text = value.toStringAsFixed(2).replaceAll('.', ',');
    if (text.endsWith('0')) text = text.substring(0, text.length - 1);
    if (text.endsWith(',0')) text = text.substring(0, text.length - 2);
    return text;
  }

  bool _printPersonIsChild() {
    return _adultType == 1;
  }

  bool _hasEntryBanCode(String code) {
    final normalized = foldTurkish(code);
    return normalized.contains('C');
  }

  pw.Widget _title(String text) => pw.Center(
        child: pw.Text(text,
            style: const pw.TextStyle(
                fontSize: 16, fontWeight: pw.FontWeight.bold)),
      );

  pw.Widget _center(String text, {double size = 10, bool bold = false}) =>
      pw.Center(
        child: pw.Text(text,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
                fontSize: size,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      );

  pw.Text _text(String text,
          {double size = 10, bool bold = false, pw.TextAlign? align}) =>
      pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
            fontSize: size,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
      );

  pw.Widget _paidIdentity(Map<String, String> v) => pw.Row(
        children: [
          pw.Expanded(child: _identityLabels()),
          pw.SizedBox(width: 18),
          pw.Expanded(child: _identityValues(v, colon: true)),
        ],
      );

  pw.Widget _unpaidIdentity(Map<String, String> v) => pw.Row(
        children: [
          pw.SizedBox(width: 150, child: _identityLabels(regular: true)),
          pw.SizedBox(width: 8),
          pw.Expanded(child: _identityValues(v, colon: false, regular: true)),
        ],
      );

  pw.Widget _identityLabels({bool regular = false}) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _text('Adı Soyadı /Name/Surname', size: 11, bold: !regular),
          _text('Uyruğu/ Nationality', size: 11, bold: !regular),
          _text('Pasaport No/Passport No', size: 11, bold: !regular),
        ],
      );

  pw.Widget _identityValues(Map<String, String> v,
          {required bool colon, bool regular = false}) =>
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _text('${colon ? ':' : ''}${v['name']}', size: 11, bold: !regular),
          _text('${colon ? ':' : ''}${v['country']}', size: 11, bold: !regular),
          _text('${colon ? ':' : ''}${v['passport']}',
              size: 11, bold: !regular),
        ],
      );

  pw.Widget _paidInfoTable(Map<String, String> v) {
    final rows = [
      [
        '*  Ülkemize Giriş Tarihiniz ve Vize süreniz\n   Date of entry into country and visa validity',
        v['entryDate']!,
        '${v['stayDays']} Gün /\nDay'
      ],
      [
        '*  Ülkemizden çıkış için müracaat tarihiniz\n   The date that you are applying to leave the country',
        v['today']!,
        ''
      ],
      [
        '* Tebliğ Edilen, Tahdit Çıkış  veya İkamet Teskere Bitiş Tarihi / End date of notified or\nlimitation date or residence permit',
        v['shouldExit']!,
        ''
      ],
      [
        '*  Ülkemizden çıkış yapmanız gereken tarih\n   The date that you were meant to leave the country',
        v['shouldExit']!,
        ''
      ],
      [
        '*  Vize ihlal süreniz\n   Visa violation period',
        v['violationDays']!,
        ''
      ],
      [
        '*  Vize ihlali için ödenecek ücret\n   Penalty for visa violation',
        v['fine']!,
        'TL'
      ],
    ];
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey700, width: .35),
      columnWidths: const {
        0: pw.FlexColumnWidth(5.9),
        1: pw.FixedColumnWidth(10),
        2: pw.FlexColumnWidth(2.7),
        3: pw.FlexColumnWidth(.9)
      },
      children: [
        for (final row in rows)
          pw.TableRow(children: [
            _cell(row[0], size: 8.2, bold: true),
            _cell(':', size: 13, bold: true),
            _cell(row[1], size: 12, bold: true),
            _cell(row[2], size: 11, bold: true),
          ]),
      ],
    );
  }

  pw.Widget _unpaidInfoRows(Map<String, String> v) {
    final rows = [
      [
        '* Ülkemize Giriş Tarihiniz ve Vize süreniz Date of entry into country / Notification Date and visa validity',
        v['entryDate']!,
        '${v['stayDays']} Day(s)'
      ],
      [
        '* Ülkemizden çıkış için müracaat tarihiniz/ The date that you are applying to leave the country',
        v['today']!,
        ''
      ],
      [
        '* Ülkemizden çıkış yapmanız gereken tarih/ The date that you were meant to leave the country',
        v['shouldExit']!,
        ''
      ],
      [
        '* Ülkemize giriş yapabileceğiniz tarih/ (Giriş yasağınızın otomatik olarak iptal edileceği tarih) / The date on which the ban on entry will be automatically canceled',
        v['canEnter']!,
        ''
      ],
      [
        '* Tebliğ Edilen, Tahdit Çıkış veya İkamet Teskere Bitiş Tarihi / End date of notified or limitation date or residence permit',
        v['shouldExit']!,
        ''
      ],
      ['* Vize ihlal süreniz / Visa violation period', v['violationDays']!, ''],
      [
        '* Vize ihlali için ödenecek ücret / Penalty for visa violation',
        '${v['fine']} TL',
        ''
      ],
    ];
    return pw.Column(
      children: [
        for (final row in rows)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(child: _text(row[0], size: 8.5)),
                  pw.SizedBox(width: 6),
                  pw.Text(': ', style: const pw.TextStyle(fontSize: 10)),
                  pw.SizedBox(
                      width: 96, child: _text(row[1], size: 11, bold: true)),
                  if (row[2].isNotEmpty)
                    pw.SizedBox(
                        width: 58,
                        child: _text(row[2], size: 10.5, bold: true)),
                ]),
          ),
      ],
    );
  }

  pw.Widget _paidNotice(Map<String, String> v) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _text(
              'Sayın ${v['name']} Ülkemizdeki yasal kalış sürenizi ihlal etmiş bulunmaktasınız. Vize ihlal ücretinizi şimdi ödediğinizden dolayı teşekkür ederiz.',
              size: 8.7,
              bold: true),
          pw.SizedBox(height: 8),
          _text(
              'Dear Madame/Sir ${v['name']}   You have exceeded the legal duration of stay in our country. Thank you in advance for paying the penalty of your visa-offence.',
              size: 7.4,
              bold: true),
        ],
      );

  pw.Widget _unpaidNotice(Map<String, String> v) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _text(
              'Sayın ${v['name']} Ülkemizdeki yasal kalış sürenizi ihlal etmiş bulunmaktasınız.Vize ihlal ücretini ödemediğiniz için hakkınızda ülkemize ${v['banDays']} Gün giriş yasağı uygulanacaktır. Hakkınızda girilecek Tahdit kodu ${v['code']}',
              size: 8.6),
          pw.Divider(height: 18, thickness: .4),
          _text(
              'Dear Madame/Sir ${v['name']} You have overstayed your visa. As you have not paid the relevant fine, a ban on your re-entering Turkey will be put into practise${v['banDays']}\nEntry Ban Code ${v['code']}',
              size: 8.4),
        ],
      );

  pw.Widget _dateLine(Map<String, String> v) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          _text('Düzenleme Tarihi / Dated On:', size: 12),
          pw.SizedBox(width: 70),
          _text(v['today']!, size: 12, bold: true),
        ],
      );

  pw.Widget _signatureBlock(Map<String, String> v) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(children: [
            _text('Yolcu İmzası', size: 12, bold: true),
            _text('Signature of passenger', size: 12, bold: true),
            _text(v['name']!, size: 12, bold: true),
          ]),
          pw.Column(children: [
            _text('Pasaport Kontrol Polisi', size: 12, bold: true),
            _text('Passport police officer', size: 11),
            _text(v['police']!, size: 12, bold: true),
          ]),
        ],
      );

  pw.Widget _legalNotes({required bool paid}) {
    final notes = [
      'İkamet Harçları 492 sayılı Harçlar kanununun 6 sayılı tarifesine göre her yıl Maliye Bakanlığınca Belirlenmektedir./Residence Fees are determined by the Ministry of Finance every year according to the tariff no. 6 of the Fees Law No. 492.',
      'Hakkınızda konulmuşsa, konulan ülkemize giriş yasağının kaldırılması için Türkiye Cumhuriyeti dış temsilciliklerine özel amaçlı vize için müracaat ediniz./If it has been placed about you, apply for a special purpose visa to the foreign representatives of the Republic of Turkey in order to lift the ban on entry to our country.',
      'Vize ihlali nedeniyle hakkınızda uygulanan "N" veya "Ç" tahdit kodlarıyla ilgili , 60(altmış) gün içerisinde İdare mahkemesine başvuru yapmanız gerekmektedir./You must apply to the Administrative Court within 60 (sixty) days regarding the "N" or "C" restriction codes applied to you due to visa violation.',
      'Tahdit iş ve işlemler ile ilgili uygulamalar Göç İdaresi Genel Müdürlüğü\'nün 22/07/2020 tarih ve 2020/17 sayılı genelgeye istinaden yapılmaktadır./Applications related to the restriction works and transactions are made in accordance with the circular numbered 2020/17 dated 22/07/2020 of the General Directorate of Migration Management.',
      'Vize ihlalinde bulunan yolcularla ilgili yurda giriş yasaklarına ilişkin uygulama 2020/17 sayılı genelgenin Madde 6\'nın "A" ve "B" bendlerine istinaden uygulanır./Implementation of bans on entry to the dormitory for passengers violating a visa is applied pursuant to subparagraphs "A" and "B" of Article 6 of the circular numbered 2020/17.',
      '6458 Sayılı Yabancılar ve Uluslararası Koruma Kanununun "9","15","102" Maddeleri./Articles "9","15","102" of the Foreigners and International Protection Law No. 6458',
      '17/03/2016 tarihli ve 29656 sayılı Yabancılar ve Uluslararası Koruma Kanununun Uygulamasına İlişkin Yönetmeliğin 8. ve 9. Maddeleri./Articles 8 and 9 of the Regulation on the Implementation of the Law on Foreigners and International Protection dated 17/03/2016 and numbered 29656',
      'Göç İdaresi Başkanlığı\'nın 06.01.2022 tarih ve V-157 İdari Takip Kodu Görüş Talebi Konulu Yazısı.Letter of the Directorate of Migration Management, dated 06.01.2022, on V-157 Administrative Tracking Code, Request for Opinion',
    ];
    return pw.Table(
      border:
          paid ? pw.TableBorder.all(color: PdfColors.grey700, width: .3) : null,
      columnWidths: const {0: pw.FixedColumnWidth(12), 1: pw.FlexColumnWidth()},
      children: [
        for (var i = 0; i < notes.length; i++)
          pw.TableRow(children: [
            pw.Padding(
                padding: const pw.EdgeInsets.all(2),
                child: _text('${i + 1}', size: 6.8, bold: true)),
            pw.Padding(
                padding: const pw.EdgeInsets.all(2),
                child: _text(notes[i], size: paid ? 6.3 : 6.0)),
          ]),
      ],
    );
  }

  pw.Widget _cell(String text,
          {double size = 9,
          bool bold = false,
          pw.Alignment align = pw.Alignment.centerLeft}) =>
      pw.Container(
        alignment: align,
        padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 3),
        child: _text(text, size: size, bold: bold),
      );

  pw.Page _preliminaryPermissionPage(
      Map<String, String> v, pw.ImageProvider logo) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(34, 42, 34, 28),
      build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Image(logo, width: 135, height: 62, fit: pw.BoxFit.contain),
            _center(
                'İdari Para Cezalarına İlişkin N Kodlu Ön İzin Kararı Tebliğ Formu',
                size: 11),
            _center(
                'Notification Form for Code N Preliminary Permission Decision Regarding Administrative Fines',
                size: 10.5),
            pw.SizedBox(height: 7),
            _center('Yabancıya İlişkin Bilgiler - Information on the Foreigner',
                size: 10, bold: true),
            pw.SizedBox(height: 4),
            _foreignerTable(v, compact: true),
            pw.SizedBox(height: 6),
            _center('Ön İzin Kararı - Preliminary Permission Decision',
                size: 8.5, bold: true),
            _paragraphBox(_preliminaryText(), size: 7.1, italic: true),
            _paragraphBox(
                'Bu belge, bir nüshası avukatına/yabancıya/yasal temsilcisine verilmek üzere iki nüsha olarak hazırlanmış olup, hakkında sınır dışı etme kararı alınan yukarıda açık kimliği yazılı yabancıya kendi dilinde/anladığı dilde, ${v['today']} tarihinde ve ${v['time']} saatinde yazılı olarak tebliğ edilmiş ve imza altına alınarak bir sureti tebellüğ edene verilmiştir. - This document has been issued in duplicate so a copy can be given to the lawyer/foreigner/legal representative and the foreigner, whose open identity is given above and upon whom the deportation decision has been imposed, has been notified in writing in his own language/language of comprehension on ${v['today']} at ${v['time']} and one copy has been given to the notified with a signature.',
                size: 7.1,
                bold: true),
            pw.SizedBox(height: 14),
            _notifySignatures(v),
          ]),
    );
  }

  pw.Page _entryBanPage(Map<String, String> v, pw.ImageProvider logo) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(34, 34, 34, 28),
      build: (_) => pw
          .Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
        pw.Image(logo, width: 135, height: 62, fit: pw.BoxFit.contain),
        _center(
            'Ç Kodlu Giriş Yasağı Kararı Tebliğ Formu / Code Ç - Entry Ban Notification Form',
            size: 11,
            bold: true),
        pw.SizedBox(height: 18),
        _center('Yabancıya İlişkin Bilgiler - Information on the Foreigner',
            size: 11, bold: true),
        pw.SizedBox(height: 5),
        _foreignerTable(v, compact: false),
        pw.SizedBox(height: 5),
        _paragraphBox(
            '* Bu alana giriş yasağı kararının başlangıç tarihi yazılacaktır. - * Enter start date of entry ban decision to this field.\n** Bu alana giriş yasağı kararının bitiş tarihi yazılacaktır. - ** Enter end date of entry ban decision to this field.',
            size: 8.4,
            bold: true),
        _sectionHeader('1.        Giriş Yasağı Kararı - Entry Ban Decision'),
        _paragraphBox(
            '6458 sayılı Yabancılar ve Uluslararası Koruma Kanunun 9 uncu maddesi uyarınca gerçekleştirilen değerlendirme neticesinde, Göç İdaresi Genel Müdürlüğü / ????. Valili?i (İl Göç İdaresi Müdürlüğü) taraf?ndan hakkınızda giriş yasağı kararı alınmıştır. - As a result of the evaluation conducted in accordance with the Article 9 of the Law on Foreigners and International Protection numbered 6458, Directorate General of Migration Management / Governorship of ????. (Provincial Directorate of Migration Management) has resolved to impose an entry ban on you.',
            size: 9.2,
            bold: true,
            italic: true),
        _paragraphBox(_entryBanBullets(), size: 5.7, bold: true, italic: true),
        _sectionHeader(
            '2.        Giriş Yasağı Kararına Karşı Yargı Yoluna Başvuru - Resort to the Jurisdiction Against the Entry Ban Decision'),
        _paragraphBox(_appealBullets(), size: 5.7, bold: true, italic: true),
        _paragraphBox(
            'Bu belge, bir nüshası avukatına/yabancıya/yasal temsilcisine verilmek üzere iki nüsha olarak hazırlanmış olup, hakkında sınır dışı etme kararı alınan yukarıda açık kimliği yazılı yabancıya kendi dilinde/anladığı dilde, ${v['today']} tarihinde ve ${v['time']} saatinde yazılı olarak tebliğ edilmiş ve imza altına alınarak bir sureti tebellüğ edene verilmiştir. - This document has been issued in duplicate so a copy can be given to the lawyer/foreigner/legal representative and the foreigner, whose open identity is given above and upon whom the deportation decision has been imposed, has been notified in writing in his own language/language of comprehension on ${v['today']} at ${v['time']} and one copy has been given to the notified with a signature.',
            size: 7.2,
            bold: true,
            italic: true),
        _notifySignatures(v),
      ]),
    );
  }

  pw.Widget _foreignerTable(Map<String, String> v, {required bool compact}) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey700, width: .35),
      columnWidths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(1.2),
        2: pw.FlexColumnWidth(1.7),
        3: pw.FlexColumnWidth(1.7)
      },
      children: [
        _tableRow(['Adı - Name', v['firstName']!, '', ''], bold: true),
        _tableRow(['Soyadı - Surname', v['lastName']!, '', ''], bold: true),
        _tableRow(['Baba Adı - Father’s Name', v['father']!, '', ''],
            bold: true),
        _tableRow(['Anne Adı - Mother’s Name', v['mother']!, '', ''],
            bold: true),
        _tableRow([
          'Doğum Tarihi - Date of Birth',
          v['birthDate']!,
          'Uyruğu - Nationality',
          v['country']!
        ], bold: true),
        _tableRow(
            ['İletişim Dili - Communication Language', v['country']!, '', ''],
            bold: true),
        _tableRow([
          'Karar ve Değerlendirmeye İlişkin Bilgiler - Information about the Decision and Evaluation',
          '',
          '',
          ''
        ], bold: true, center: true),
        if (compact)
          _tableRow([
            'Giriş Yasağı Kararı Başlangıç-Bitiş Tarihi - Start Date of Entry Ban Decision',
            '1-',
            v['today']!,
            ''
          ], bold: true, center: true),
        if (!compact)
          _tableRow([
            'Giriş Yasağı Kararı Başlangıç-Bitiş Tarihi - Start and End Date of Entry Ban Decision',
            '',
            '',
            ''
          ], bold: true, center: true),
        if (!compact)
          _tableRow([
            'Giriş Yasağı Kararı Başlangıç-Bitiş Tarihi - Start and End Date of Entry Ban Decision',
            v['today']!,
            v['canEnter']!,
            ''
          ], bold: true, center: true),
        if (!compact)
          _tableRow(['Tahdit Kodu / Restriction Code', v['code']!, '', ''],
              bold: true, center: true, tall: true),
      ],
    );
  }

  pw.TableRow _tableRow(List<String> cells,
          {bool bold = false, bool center = false, bool tall = false}) =>
      pw.TableRow(
        children: [
          for (final cell in cells)
            pw.Container(
              height: tall ? 42 : null,
              alignment: center ? pw.Alignment.center : pw.Alignment.centerLeft,
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              child: _text(cell,
                  size: 8.5,
                  bold: bold,
                  align: center ? pw.TextAlign.center : pw.TextAlign.left),
            ),
        ],
      );

  pw.Widget _paragraphBox(String text,
          {required double size, bool bold = false, bool italic = false}) =>
      pw.Container(
        width: double.infinity,
        margin: const pw.EdgeInsets.only(top: 3),
        padding: const pw.EdgeInsets.all(4),
        decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey700, width: .35)),
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.justify,
          style: pw.TextStyle(
              fontSize: size,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontStyle: italic ? pw.FontStyle.italic : pw.FontStyle.normal),
        ),
      );

  pw.Widget _sectionHeader(String text) => pw.Container(
        width: double.infinity,
        margin: const pw.EdgeInsets.only(top: 4),
        padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey700, width: .35)),
        child: _center(text, size: 10.5, bold: true),
      );

  pw.Widget _notifySignatures(Map<String, String> v) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          pw.Column(children: [
            _text('Tebliğ Eden', size: 11, bold: true),
            _text('Notifying Party', size: 11, bold: true),
            _text(v['approver']!, size: 11, bold: true)
          ]),
          pw.Column(children: [
            _text('Tebellüğ Eden', size: 11, bold: true),
            _text('Notified', size: 11, bold: true),
            _text(v['name']!, size: 11, bold: true)
          ]),
        ],
      );

  String _preliminaryText() =>
      '6458 sayılı Yabancılar ve Uluslararası Koruma Kanunun 9 uncu maddesi uyarınca gerçekleştirilen değerlendirme neticesinde, ..... Valiliği (İl Göç İdaresi Müdürlüğü) tarafından hakkınızda ön izin kararı alınmıştır. - As a result of the evaluation conducted in accordance with the Article 9 of the Law on Foreigners and International Protection numbered 6458, Governorship of ..... (Provincial Directorate of Migration Management) has resolved to adopt a preliminary permission decision against you.\n'
      'Hakkınızda ön izin kararı alınmasına dayanak teşkil eden husus/hususlar sebebiyle; - Based on the particular/particulars constituting grounds for adopting a preliminary permission decision against you;\n'
      'İkamet izninizin iptali için gerekli işlemler başlatılacaktır. - Respective procedures will be commenced for cancelling your residence permit.\n'
      'Çalışma izninizin iptali için gerekli işlemler başlatılacaktır. - Respective procedures will be commenced for cancelling your work permit.\n'
      'İdari para cezanızı ödememeniz nedeni ile hakkınızda alınan ön izin kararı, idari para cezasının ödendiğine ilişkin makbuzun idareye tebliğ edilmesi halinde kaldırılır ve girişinize engel olacak başka bir hususun bulunmaması kaydıyla Türkiye’ye girişinize izin verilir.\n'
      'The preliminary permission decision adopted against you on the grounds of non-payment of the administrative fine imposed on you will be rescinded provided that the receipt of payment of the respective administrative fine is submitted to the directorate, and the permission of entry to Turkey will be granted to you on condition that no other particulars barring you from entering Turkey are determined.\n'
      'Ön İzin Kararına Karşı Yargı Yoluna Başvuru - Resort to the Jurisdiction Against the Preliminary Permission Decision\n'
      'Şahsınız veya yasal temsilciniz ya da avukatınız tarafından, ön izin kararına karşı, kararın tebliğinden itibaren 60 (altmış) gün içinde idare mahkemesine başvurulabilir. - You or your legal representative or lawyer may appeal against the preliminary permission decision to the Administrative Court within 60 (sixty) days from the notification of the decision.\n'
      'Mahkemeye başvuran kişi, ön izin kararı veren makama da başvurusunu bildirir. - The applicant who applied to the Court also notifies the authority of the preliminary permission decision.\n'
      'Mahkemeye yapılan başvurular ön izin kararını durdurmaz. - Applications made to the Court does not suspend the preliminary permission decision.';

  String _entryBanBullets() =>
      '• Hakkınızda giriş yasağı kararı alınmasına dayanak teşkil eden husus/hususlar sebebiyle; - Based on the particular/particulars constituting grounds for imposing an entry ban on you;\n'
      '• İkamet izninizin iptali için gerekli işlemler başlatılacaktır. - Respective procedures will be commenced for cancelling your residence permit.\n'
      '• Çalışma izninizin iptali için gerekli işlemler başlatılacaktır. - Respective procedures will be commenced for cancelling your work permit.\n'
      '• Türkiye’ye girişinizin yasaklı olduğu süre içerisinde giriş yapmak istemeniz halinde, Türkiye Cumhuriyeti Dış Temsilciliklerinden amacına uygun özel meşruhatlı vize almanız gerekmektedir. - If you wish to enter Turkey during the period of your entry ban, you are required to obtain the relevant visa from Foreign Representative Offices of the Republic of Turkey.\n'
      '• Hakkınızda tahsis edilen giriş yasağı süresinin sona ermesi yüz seksen günde doksan gün kuralının uygulanmasına engel teşkil etmemektedir. Her halükarda vizenin veya vize muafiyetinin Türkiye’de sağladığı kalış süresi, her yüz seksen günde doksan günü geçemez.\n'
      '• Hakkınızda alınan giriş yasağı kararının süresi dolmuş olsa dahi idari para cezanızı ödememenizden kaynaklanan ön izin kararına ilişkin hükümler saklıdır. - All provisions with respect to the preliminary permission decision stemming from the non-payment of your administrative fine are reserved.';

  String _appealBullets() =>
      '• Şahsınız veya yasal temsilciniz ya da avukatınız tarafından, giriş yasağı kararına karşı, kararın tebliğinden itibaren 60 (altmış) gün içinde idare mahkemesine başvurulabilir. - You or your legal representative or lawyer may appeal against the entry ban decision to the Administrative Court within 60 days from the notification of the decision.\n'
      '• Mahkemeye başvuran kişi, giriş yasağı kararı veren makama da başvurusunu bildirir. - The applicant who applied to the Court also notifies the authority of the entry ban decision.\n'
      '• Mahkemeye yapılan başvurular giriş yasağı kararını durdurmaz. - Applications made to the Court does not suspend the entry ban decision.';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('app_title')),
        actions: [
          PopupMenuButton<String>(
            tooltip: context.tr('language'),
            initialValue: widget.locale.languageCode,
            icon: const Icon(Icons.language),
            onSelected: widget.onLocaleChanged,
            itemBuilder: (context) => languageNames.entries
                .map((entry) => PopupMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ))
                .toList(),
          ),
          IconButton(
            tooltip: context.tr('account'),
            onPressed: _showAccountDialog,
            icon: Icon(_authToken == null
                ? Icons.account_circle_outlined
                : Icons.verified_user),
          ),
          IconButton(
            tooltip: context.tr('plans'),
            onPressed: _showPlansDialog,
            icon: const Icon(Icons.workspace_premium),
          ),
          if (_isAdmin) ...[
            IconButton(
              tooltip: context.tr('user_management'),
              onPressed: _showAdminUsersDialog,
              icon: const Icon(Icons.manage_accounts),
            ),
            IconButton(
              tooltip: context.tr('settings'),
              onPressed: _showSettingsDialog,
              icon: const Icon(Icons.settings),
            ),
            IconButton(
              tooltip: context.tr('import_json'),
              onPressed: _importJsonFromClipboard,
              icon: const Icon(Icons.content_paste),
            ),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle(context.tr('date_and_type')),
          _entryExitRowsWidget(),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _calculateType,
            decoration:
                InputDecoration(labelText: context.tr('calculation_type')),
            items: [
              DropdownMenuItem(
                  value: 1, child: Text(context.tr('normal_calculation'))),
              DropdownMenuItem(value: 2, child: Text(context.tr('rule_180'))),
              DropdownMenuItem(value: 3, child: Text(context.tr('rule_30'))),
              DropdownMenuItem(
                  value: 4, child: Text(context.tr('daily_penalty'))),
              DropdownMenuItem(
                  value: 5, child: Text(context.tr('belarus_rule'))),
            ],
            onChanged: (value) => setState(() => _calculateType = value ?? 1),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _visa,
            decoration: InputDecoration(labelText: context.tr('visa')),
            items: [
              DropdownMenuItem(
                  value: 1, child: Text(context.tr('visa_required'))),
              DropdownMenuItem(
                  value: 2, child: Text(context.tr('visa_exempt'))),
              DropdownMenuItem(
                  value: 3, child: Text(context.tr('consular_visa'))),
              DropdownMenuItem(
                  value: 4, child: Text(context.tr('residence_permit'))),
              DropdownMenuItem(
                  value: 5, child: Text(context.tr('born_in_turkey'))),
              DropdownMenuItem(
                  value: 7, child: Text(context.tr('conditional_entry'))),
              DropdownMenuItem(
                  value: 8, child: Text(context.tr('work_permit'))),
              const DropdownMenuItem(value: 9, child: Text('V-157')),
              const DropdownMenuItem(value: 10, child: Text('V-69')),
              DropdownMenuItem(
                  value: 11, child: Text('V-137 ${context.tr('unlimited')}')),
              const DropdownMenuItem(value: 12, child: Text('V-88')),
              DropdownMenuItem(
                  value: 13, child: Text('V-137 ${context.tr('limited')}')),
              DropdownMenuItem(
                  value: 14,
                  child: Text('${context.tr('residence_permit')} V-157')),
              const DropdownMenuItem(value: 15, child: Text('V-69 Tebliğ')),
            ],
            onChanged: (value) {
              setState(() {
                _visa = value ?? 2;
                _paymentType = paymentOptionsForVisa(_visa).first.value;
                if (_visa == 7 && _entryExitRows.length > 1) {
                  final extraRows = _entryExitRows.sublist(1);
                  _entryExitRows.removeRange(1, _entryExitRows.length);
                  for (final row in extraRows) {
                    row.dispose();
                  }
                }
              });
            },
          ),
          if (_visa == 3) ...[
            const SizedBox(height: 12),
            _numberField(
                context.tr('consular_days'), _consularVisaDaysController),
          ],
          if (_usesSpecialVisaDate(_visa)) ...[
            const SizedBox(height: 12),
            _dateField(context.tr('notice_date'), _specialVisaDateController),
          ],
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _passport,
            decoration: InputDecoration(labelText: context.tr('passport')),
            items: [
              DropdownMenuItem(
                  value: 1, child: Text(context.tr('ordinary_passport'))),
              DropdownMenuItem(
                  value: 2, child: Text(context.tr('diplomatic_passport'))),
              DropdownMenuItem(
                  value: 3, child: Text(context.tr('service_passport'))),
              DropdownMenuItem(
                  value: 4, child: Text(context.tr('official_passport'))),
              DropdownMenuItem(value: 5, child: Text(context.tr('stateless'))),
              DropdownMenuItem(value: 6, child: Text(context.tr('seaman'))),
            ],
            onChanged: (value) => setState(() => _passport = value ?? 1),
          ),
          const SizedBox(height: 12),
          if (_data.countries.isNotEmpty)
            Builder(builder: (context) {
              final countries = countriesForSelection(_data.countries);
              return DropdownButtonFormField<String>(
                initialValue: _country.isEmpty ? countries.first : _country,
                isExpanded: true,
                decoration: InputDecoration(labelText: context.tr('country')),
                items: countries
                    .map((country) => DropdownMenuItem(
                          value: country,
                          child: Text(countryDisplayName(country, context)),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _country = value ?? ''),
              );
            })
          else if (_isAdmin)
            TextFormField(
              decoration:
                  InputDecoration(labelText: context.tr('manual_country')),
              onChanged: (value) => _country = value.trim(),
            )
          else
            const SizedBox.shrink(),
          const SizedBox(height: 18),
          _dateField(context.tr('birth_date'), _birthController),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            key: ValueKey('person-type-$_adultType'),
            initialValue: _adultType,
            decoration: InputDecoration(
              labelText: parseDate(_birthController.text) == null
                  ? context.tr('person_type')
                  : context.tr('person_type_auto'),
            ),
            items: [
              DropdownMenuItem(value: 1, child: Text(context.tr('child'))),
              DropdownMenuItem(value: 2, child: Text(context.tr('adult'))),
            ],
            onChanged: parseDate(_birthController.text) == null
                ? (value) => setState(() => _adultType = value ?? 2)
                : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue:
                paymentOptionsForVisa(_visa).any((x) => x.value == _paymentType)
                    ? _paymentType
                    : paymentOptionsForVisa(_visa).first.value,
            decoration:
                InputDecoration(labelText: context.tr('payment_status')),
            items: paymentOptionsForVisa(_visa)
                .map((option) => DropdownMenuItem(
                    value: option.value,
                    child: Text(_localizedPaymentLabel(context, option.label))))
                .toList(),
            onChanged: (value) => setState(() => _paymentType =
                value ?? paymentOptionsForVisa(_visa).first.value),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => _calculate(),
            icon: const Icon(Icons.calculate),
            label: Text(context.tr('calculate')),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_localizedError(context, _error!),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer)),
              ),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 16),
            ResultCard(
              result: _result!,
              onPrint: _showPrintInfoDialog,
              showPrint: _isAdmin,
            ),
          ],
          const SizedBox(height: 32),
          Text(
            _data.generatedAt == null
                ? context.tr('add_data_hint')
                : context.trValue('data_date', _data.generatedAt!),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _shortDate(String raw) {
    if (raw.length >= 10) {
      return raw.substring(0, 10);
    }
    return raw.isEmpty ? '-' : raw;
  }

  String _localizedPaymentLabel(BuildContext context, String label) {
    final unpaid = label.contains('Odemeyen');
    final prefix =
        label.replaceAll('Odemeyen', '').replaceAll('Odeyen', '').trim();
    final status = context.tr(unpaid ? 'unpaid' : 'paid');
    return prefix.isEmpty ? status : '$prefix — $status';
  }

  String _localizedError(BuildContext context, String error) {
    if (error.startsWith('error_row_date:')) {
      return context.trValue('error_row_date', error.split(':').last);
    }
    return context.tr(error);
  }

  Widget _entryExitRowsWidget() {
    return Column(
      children: [
        for (var index = 0; index < _entryExitRows.length; index += 1) ...[
          Builder(builder: (context) {
            final isLastRow = index == _entryExitRows.length - 1;
            final entryLabel =
                isLastRow ? context.tr('last_entry') : context.tr('past_entry');
            final exitLabel =
                isLastRow ? context.tr('last_exit') : context.tr('past_exit');

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 28,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('${index + 1}.'),
                  ),
                ),
                Expanded(
                    child: _dateField(entryLabel, _entryExitRows[index].entry)),
                const SizedBox(width: 8),
                Expanded(
                    child: _dateField(exitLabel, _entryExitRows[index].exit)),
                SizedBox(
                  width: 58,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _entryExitRowDayText(context, _entryExitRows[index]),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: context.tr('delete_row'),
                  onPressed: _entryExitRows.length == 1
                      ? null
                      : () => _removeEntryExitRow(index),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
              ],
            );
          }),
          const SizedBox(height: 8),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addEntryExitRow,
            icon: const Icon(Icons.add),
            label: Text(context.tr('add_entry_exit')),
          ),
        ),
      ],
    );
  }

  String _entryExitRowDayText(BuildContext context, EntryExitControllers row) {
    final entry = parseDate(row.entry.text);
    final exit = parseDate(row.exit.text);
    if (entry == null || exit == null || entry.isAfter(exit)) return '-';

    // Arayuzde mevcut tek giris/cikis gun mantigini gostermeye devam et.
    final days = max(1, exit.difference(entry).inDays);
    return context.trValue('day_short', days);
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _dateField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_month),
      ),
      onTap: () => _pickDate(controller),
    );
  }

  Widget _numberField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
    );
  }
}

class ResultCard extends StatelessWidget {
  const ResultCard({
    required this.result,
    required this.onPrint,
    required this.showPrint,
    super.key,
  });

  final PenaltyResult result;
  final VoidCallback onPrint;
  final bool showPrint;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final penaltyText = result.penaltyMonths == 0
        ? context.trValue('day_short', result.penaltyDays)
        : context.trValue(
            'month_short',
            result.penaltyMonths + (result.penaltyDays > 0 ? 1 : 0),
          );
    final entryBanText = result.hasEntryBan
        ? '${result.tahditCode} / ${context.trValue('day_short', result.tahditPenaltyDays)}'
        : context.tr('not_applied');
    final rows = <(String, String)>[
      (context.tr('stay_days'), '${result.stayDays}'),
      (context.tr('penalty'), penaltyText),
      (
        context.tr('total_violation'),
        context.trValue('day_short', result.violationDays)
      ),
      (context.tr('should_exit'), formatDate(result.shouldExitDate)),
      (context.tr('entry_ban'), entryBanText),
      (
        context.tr('earliest_reentry'),
        formatDate(result.earliestReEntryDate(today))
      ),
      (
        context.tr('penalty_fee'),
        '${result.penaltyAmount.toStringAsFixed(2)} ${result.currency}'
      ),
      (
        context.tr('exchange_rate'),
        '${result.currency} = ${result.exchangeRate.toStringAsFixed(4)} TRY'
      ),
      (context.tr('penalty_fee_try'), result.penaltyTry.toStringAsFixed(2)),
      (context.tr('visa_fee_try'), result.visaFee.toStringAsFixed(2)),
      (context.tr('document_fee_try'), result.defter.toStringAsFixed(2)),
      (
        context.tr('administrative_try'),
        result.administrativeFine.toStringAsFixed(2)
      ),
      (context.tr('total_try'), result.total.toStringAsFixed(2)),
      (context.tr('restriction_code'), result.tahditCode),
      (context.tr('administrative_code'), result.idariTahditCode),
      (
        context.tr('restriction_duration'),
        context.trValue('day_short', result.tahditPenaltyDays)
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr('result'),
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Expanded(child: Text(row.$1)),
                    Text(row.$2,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            if (showPrint) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: onPrint,
                  icon: const Icon(Icons.print),
                  label: Text(context.tr('print_pdf')),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ManualCalculationSettings {
  const ManualCalculationSettings({
    required this.oneTime,
    required this.longStay,
    required this.firstMonth,
    required this.monthStep,
    required this.dayStart,
    required this.dayStep,
    required this.currency,
  });

  final int oneTime;
  final int longStay;
  final double firstMonth;
  final double monthStep;
  final double dayStart;
  final double dayStep;
  final String currency;
}

class SystemSettingsResult {
  const SystemSettingsResult({
    required this.data,
    required this.manualSettings,
  });

  final CezamData data;
  final ManualCalculationSettings manualSettings;
}

class SystemSettingsPage extends StatefulWidget {
  const SystemSettingsPage({
    required this.initialData,
    this.initialManualSettings = const ManualCalculationSettings(
      oneTime: 90,
      longStay: 90,
      firstMonth: 0,
      monthStep: 0,
      dayStart: 0,
      dayStep: 0,
      currency: 'USD',
    ),
    this.apiBaseUrl,
    this.authToken,
    this.isAdmin = false,
    super.key,
  });

  final CezamData initialData;
  final ManualCalculationSettings initialManualSettings;
  final String? apiBaseUrl;
  final String? authToken;
  final bool isAdmin;

  @override
  State<SystemSettingsPage> createState() => _SystemSettingsPageState();
}

class _SystemSettingsPageState extends State<SystemSettingsPage> {
  late CezamData _draft;
  late String _country;
  int _passport = 1;
  int _visa = 2;
  int _calculateType = 1;
  int _visaFeeEnabled = 1;
  String _auhCurrency = 'USD';
  int _tkodIndex = 0;

  final _ruleDay = TextEditingController();
  final _oneTime = TextEditingController();
  final _longStay = TextEditingController();
  final _firstMonth = TextEditingController();
  final _monthStep = TextEditingController();
  final _dayStart = TextEditingController();
  final _dayStep = TextEditingController();
  final _usd = TextEditingController();
  final _eur = TextEditingController();
  final _gbp = TextEditingController();
  final _defter = TextEditingController();
  final _visaFee = TextEditingController();
  final _tkodCode = TextEditingController();
  final _tkodPenaltyTime = TextEditingController();
  final _tkodStart = TextEditingController();
  final _tkodFinish = TextEditingController();
  final _tkodIdariCode = TextEditingController();
  final _manualOneTime = TextEditingController();
  final _manualLongStay = TextEditingController();
  final _manualFirstMonth = TextEditingController();
  final _manualMonthStep = TextEditingController();
  final _manualDayStart = TextEditingController();
  final _manualDayStep = TextEditingController();
  late String _manualCurrency;

  @override
  void initState() {
    super.initState();
    _draft = CezamData.fromJson(widget.initialData.toJson());
    _country = _draft.countries.isEmpty ? '' : _draft.countries.first;
    _manualOneTime.text = widget.initialManualSettings.oneTime.toString();
    _manualLongStay.text = widget.initialManualSettings.longStay.toString();
    _manualFirstMonth.text = widget.initialManualSettings.firstMonth.toString();
    _manualMonthStep.text = widget.initialManualSettings.monthStep.toString();
    _manualDayStart.text = widget.initialManualSettings.dayStart.toString();
    _manualDayStep.text = widget.initialManualSettings.dayStep.toString();
    _manualCurrency = widget.initialManualSettings.currency;
    _loadAllFields();
  }

  @override
  void dispose() {
    for (final controller in [
      _ruleDay,
      _oneTime,
      _longStay,
      _firstMonth,
      _monthStep,
      _dayStart,
      _dayStep,
      _usd,
      _eur,
      _gbp,
      _defter,
      _visaFee,
      _tkodCode,
      _tkodPenaltyTime,
      _tkodStart,
      _tkodFinish,
      _tkodIdariCode,
      _manualOneTime,
      _manualLongStay,
      _manualFirstMonth,
      _manualMonthStep,
      _manualDayStart,
      _manualDayStep,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _loadAllFields() {
    _loadUvrFields();
    _loadAuhFields();
    _usd.text = _draft.exchange['USD']?.toString() ?? '1';
    _eur.text = _draft.exchange['EUR']?.toString() ?? '1';
    _gbp.text = _draft.exchange['GBP']?.toString() ?? '1';
    _defter.text = _draft.defterPrice.toString();
    _visaFee.text =
        _draft.tgvh.isEmpty ? '0' : _draft.tgvh.last.price.toString();
    _loadTkodFields();
  }

  void _loadUvrFields() {
    final rule = _draft.findUvr(_country, _passport, _visa, _calculateType);
    _ruleDay.text = (rule?.day ?? 180).toString();
    _oneTime.text = (rule?.oneTime ?? 0).toString();
    _longStay.text = (rule?.longStay ?? 0).toString();
    _visaFeeEnabled = rule?.visaFeeEnabled ?? 0;
  }

  void _loadAuhFields() {
    final rule = _draft.findAuh(_country);
    _firstMonth.text = (rule?.firstMonth ?? 0).toString();
    _monthStep.text = (rule?.monthStep ?? 0).toString();
    _dayStart.text = (rule?.dayStart ?? 0).toString();
    _dayStep.text = (rule?.dayStep ?? 0).toString();
    _auhCurrency = rule?.currency ?? 'USD';
  }

  void _loadTkodFields() {
    if (_draft.tkod.isEmpty) return;
    _tkodIndex = _tkodIndex.clamp(0, _draft.tkod.length - 1);
    final rule = _draft.tkod[_tkodIndex];
    _tkodCode.text = rule.code;
    _tkodPenaltyTime.text = rule.penaltyTime.toString();
    _tkodStart.text = rule.start.toString();
    _tkodFinish.text = rule.finish.toString();
    _tkodIdariCode.text = rule.idariCode;
  }

  void _saveCountryRule({bool notify = true}) {
    final rule = UvrRule(
      country: _country,
      calculateType: _calculateType,
      passportType: _passport,
      visaStatus: _visa,
      day: readInt(_ruleDay),
      longStay: readInt(_longStay),
      oneTime: readInt(_oneTime),
      visaFeeEnabled: _visaFeeEnabled,
    );
    final index = _draft.uvr.indexWhere((row) =>
        row.country == _country &&
        row.calculateType == _calculateType &&
        row.passportType == _passport &&
        row.visaStatus == _visa);
    index < 0 ? _draft.uvr.add(rule) : _draft.uvr[index] = rule;
    if (notify) _message('\u00dclke kural\u0131 tasla\u011fa uyguland\u0131.');
  }

  void _saveAuhRule({bool notify = true}) {
    final rule = AuhRule(
      country: _country,
      firstMonth: readDouble(_firstMonth),
      monthStep: readDouble(_monthStep),
      dayStart: readDouble(_dayStart),
      dayStep: readDouble(_dayStep),
      currency: _auhCurrency,
    );
    final index = _draft.auh.indexWhere((row) => row.country == _country);
    index < 0 ? _draft.auh.add(rule) : _draft.auh[index] = rule;
    if (notify) _message('Ceza tutarlar\u0131 tasla\u011fa uyguland\u0131.');
  }

  void _saveTkodRule({bool notify = true}) {
    if (_draft.tkod.isEmpty) return;
    final old = _draft.tkod[_tkodIndex];
    _draft.tkod[_tkodIndex] = TkodRule(
      code: _tkodCode.text.trim(),
      penaltyTime: readInt(_tkodPenaltyTime),
      start: readInt(_tkodStart),
      finish: readInt(_tkodFinish),
      idariCode: _tkodIdariCode.text.trim(),
      paidType: old.paidType,
    );
    if (notify) _message('Tahdit kural\u0131 tasla\u011fa uyguland\u0131.');
  }

  bool _isSyncing = false;

  Future<void> _fetchServerSettings() async {
    final url = widget.apiBaseUrl;
    if (url == null || url.isEmpty) {
      _message('Sunucu API adresi tanımsız.');
      return;
    }

    setState(() => _isSyncing = true);
    try {
      final response = await http
          .get(Uri.parse('$url/system-settings'), headers: {
            'Content-Type': 'application/json',
            if (widget.authToken != null)
              'Authorization': 'Bearer ${widget.authToken}',
          })
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final usd = (json['usd'] as num?)?.toDouble();
        final eur = (json['eur'] as num?)?.toDouble();
        final gbp = (json['gbp'] as num?)?.toDouble();
        final singleEntryVisaFee =
            (json['singleEntryVisaFee'] as num?)?.toDouble();
        final defterPrice = (json['defterPrice'] as num?)?.toDouble();

        setState(() {
          if (usd != null) _usd.text = usd.toString();
          if (eur != null) _eur.text = eur.toString();
          if (gbp != null) _gbp.text = gbp.toString();
          if (singleEntryVisaFee != null) {
            _visaFee.text = singleEntryVisaFee.toString();
          }
          if (defterPrice != null) _defter.text = defterPrice.toString();
        });
        _message('Sunucudan güncel kurlar ve harçlar başarıyla çekildi.');
      } else {
        _message('Sunucudan ayarlar alınamadı (HTTP ${response.statusCode}).');
      }
    } catch (e) {
      _message('Sunucuya bağlanılamadı: $e');
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _saveGeneralSettingsToServer() async {
    final url = widget.apiBaseUrl;
    final token = widget.authToken;

    if (!widget.isAdmin ||
        token == null ||
        token == 'local-admin' ||
        url == null) {
      _message('Ayarlar yerel taslağa uygulandı (Çevrimdışı mod).');
      return;
    }

    setState(() => _isSyncing = true);
    try {
      final body = jsonEncode({
        'usd': readDouble(_usd),
        'eur': readDouble(_eur),
        'gbp': readDouble(_gbp),
        'singleEntryVisaFee': readDouble(_visaFee),
        'defterPrice': readDouble(_defter),
      });

      final response = await http
          .post(
            Uri.parse('$url/system-settings'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        _message('Kurlar ve harç bedelleri sunucuya başarıyla kaydedildi!');
      } else if (response.statusCode == 403) {
        _message(
            'Yetkisiz işlem: Sadece admin sistem ayarlarını güncelleyebilir.');
      } else {
        _message('Sunucu hatası: HTTP ${response.statusCode}');
      }
    } catch (e) {
      _message('Sunucuya kaydedilemedi, yerel taslak güncellendi.');
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  void _saveAndClose() {
    _saveCountryRule(notify: false);
    _saveAuhRule(notify: false);
    _saveTkodRule(notify: false);
    Navigator.pop(
      context,
      SystemSettingsResult(
        data: _buildData(),
        manualSettings: ManualCalculationSettings(
          oneTime: readInt(_manualOneTime),
          longStay: readInt(_manualLongStay),
          firstMonth: readDouble(_manualFirstMonth),
          monthStep: readDouble(_manualMonthStep),
          dayStart: readDouble(_manualDayStart),
          dayStep: readDouble(_manualDayStep),
          currency: _manualCurrency,
        ),
      ),
    );
  }

  CezamData _buildData() {
    final tgvh = [..._draft.tgvh];
    final fee = TgvhRule(
        year: DateTime.now().year.toString(), price: readDouble(_visaFee));
    if (tgvh.isEmpty) {
      tgvh.add(fee);
    } else {
      tgvh[tgvh.length - 1] = fee;
    }
    return CezamData(
      generatedAt: DateTime.now().toIso8601String(),
      exchange: {
        'USD': readDouble(_usd),
        'EUR': readDouble(_eur),
        'GBP': readDouble(_gbp),
        'TRY': 1,
      },
      defterPrice: readDouble(_defter),
      embeddedCountries: [..._draft.embeddedCountries],
      tgvh: tgvh,
      uvr: [..._draft.uvr],
      auh: [..._draft.auh],
      tkod: [..._draft.tkod],
    );
  }

  Future<void> _resetDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Varsay\u0131lan Veriler'),
        content: const Text(
            'Yapt\u0131\u011f\u0131n\u0131z yerel veri de\u011fi\u015fiklikleri s\u0131f\u0131rlanacak.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Vazge\u00e7')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('S\u0131f\u0131rla')),
        ],
      ),
    );
    if (confirmed != true) return;
    final raw = await rootBundle.loadString('assets/cezam_data.json');
    setState(() {
      _draft = CezamData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      _country = _draft.countries.isEmpty ? '' : _draft.countries.first;
      _tkodIndex = 0;
      _loadAllFields();
    });
    _message('APK i\u00e7indeki varsay\u0131lan veriler y\u00fcklendi.');
  }

  Future<void> _exportData() async {
    _saveCountryRule(notify: false);
    _saveAuhRule(notify: false);
    _saveTkodRule(notify: false);
    await Clipboard.setData(
        ClipboardData(text: jsonEncode(_buildData().toJson())));
    _message('Anonim sistem verileri panoya kopyaland\u0131.');
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Widget _number(String label, TextEditingController controller) => TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label),
      );

  Widget _two(Widget left, Widget right) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          const SizedBox(width: 12),
          Expanded(child: right)
        ],
      );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sistem Ayarlar\u0131'),
          actions: [
            IconButton(
                tooltip: 'D\u0131\u015fa aktar',
                onPressed: _exportData,
                icon: const Icon(Icons.copy_all_outlined)),
            IconButton(
                tooltip: 'Varsay\u0131lana d\u00f6n',
                onPressed: _resetDefaults,
                icon: const Icon(Icons.restore)),
            IconButton(
              tooltip: 'Kaydet',
              onPressed: _saveAndClose,
              icon: const Icon(Icons.save),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: '\u00dclke Kural\u0131'),
              Tab(text: 'Ceza Tutar\u0131'),
              Tab(text: 'Genel'),
              Tab(text: 'Tahdit'),
              Tab(text: 'Manuel'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _countryRuleTab(),
            _auhTab(),
            _generalTab(),
            _tkodTab(),
            _manualTab(),
          ],
        ),
      ),
    );
  }

  Widget _countryPicker({required VoidCallback afterChange}) =>
      DropdownButtonFormField<String>(
        key: ValueKey('country-$_country'),
        initialValue: _country,
        isExpanded: true,
        decoration: const InputDecoration(labelText: '\u00dclke'),
        items: countriesForSelection(_draft.countries)
            .map((name) => DropdownMenuItem(
                value: name, child: Text(countryDisplayName(name, context))))
            .toList(),
        onChanged: (value) => setState(() {
          _country = value ?? _country;
          afterChange();
        }),
      );

  Widget _countryRuleTab() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _countryPicker(afterChange: () {
            _loadUvrFields();
            _loadAuhFields();
          }),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            key: ValueKey('passport-$_passport'),
            initialValue: _passport,
            decoration: const InputDecoration(labelText: 'Pasaport'),
            items: const [
              DropdownMenuItem(value: 1, child: Text('Umuma Mahsus')),
              DropdownMenuItem(value: 2, child: Text('Diplomatik')),
              DropdownMenuItem(value: 3, child: Text('Servis')),
              DropdownMenuItem(value: 4, child: Text('Hizmet')),
              DropdownMenuItem(value: 5, child: Text('Haymatlos')),
              DropdownMenuItem(value: 6, child: Text('Gemi Adam\u0131')),
            ],
            onChanged: (value) => setState(() {
              _passport = value ?? 1;
              _loadUvrFields();
            }),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            key: ValueKey('calculate-$_calculateType'),
            initialValue: _calculateType,
            decoration: const InputDecoration(labelText: 'Hesaplama Tipi'),
            items: const [
              DropdownMenuItem(value: 1, child: Text('Normal Hesaplama')),
              DropdownMenuItem(
                  value: 2, child: Text('180 G\u00fcn Uygulamas\u0131')),
              DropdownMenuItem(
                  value: 3, child: Text('30 G\u00fcnl\u00fck Uygulama')),
              DropdownMenuItem(
                  value: 4, child: Text('G\u00fcn\u00fcbirlik Ceza')),
              DropdownMenuItem(value: 5, child: Text('Beyaz Rusya 30/90')),
            ],
            onChanged: (value) => setState(() {
              _calculateType = value ?? 1;
              _loadUvrFields();
            }),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            key: ValueKey('visa-$_visa'),
            initialValue: _visa,
            decoration: const InputDecoration(labelText: 'Vize Durumu'),
            items: const [
              DropdownMenuItem(value: 1, child: Text('Vizeli')),
              DropdownMenuItem(value: 2, child: Text('Vizesiz')),
              DropdownMenuItem(
                  value: 3, child: Text('Konsolosluk / Ka\u015fe Vize')),
              DropdownMenuItem(value: 4, child: Text('\u0130kamet Teskereli')),
              DropdownMenuItem(
                  value: 5, child: Text("T\u00fcrkiye'de Do\u011fan")),
              DropdownMenuItem(
                  value: 7, child: Text('V-84 \u015eartl\u0131 Giri\u015f')),
              DropdownMenuItem(
                  value: 8, child: Text('\u00c7al\u0131\u015fma \u0130zni')),
              DropdownMenuItem(value: 9, child: Text('V-157')),
              DropdownMenuItem(value: 10, child: Text('V-69')),
              DropdownMenuItem(value: 11, child: Text('V-137 S\u00fcresiz')),
              DropdownMenuItem(value: 12, child: Text('V-88')),
              DropdownMenuItem(value: 13, child: Text('V-137 S\u00fcreli')),
              DropdownMenuItem(
                  value: 14, child: Text('\u0130kamet Teskereli V-157')),
              DropdownMenuItem(
                  value: 15,
                  child: Text('V-69 Tebli\u011f \u0130\u00e7indeki')),
            ],
            onChanged: (value) => setState(() {
              _visa = value ?? 2;
              _loadUvrFields();
            }),
          ),
          const SizedBox(height: 16),
          _two(_number('Kural periyodu (g\u00fcn)', _ruleDay),
              _number('Bir seferde kal\u0131\u015f (g\u00fcn)', _oneTime)),
          const SizedBox(height: 12),
          _number('Toplam kal\u0131\u015f (g\u00fcn)', _longStay),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Vize harc\u0131 uygulans\u0131n'),
            value: _visaFeeEnabled == 1,
            onChanged: (value) =>
                setState(() => _visaFeeEnabled = value ? 1 : 0),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
              onPressed: _saveCountryRule,
              icon: const Icon(Icons.check),
              label: const Text('Bu Kural\u0131 Uygula')),
        ],
      );

  Widget _auhTab() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _countryPicker(afterChange: _loadAuhFields),
          const SizedBox(height: 16),
          _two(_number('\u0130lk ay', _firstMonth),
              _number('Sonraki ay', _monthStep)),
          const SizedBox(height: 12),
          _two(_number('G\u00fcn ba\u015flang\u0131\u00e7', _dayStart),
              _number('G\u00fcn art\u0131\u015f', _dayStep)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: ValueKey('currency-$_auhCurrency'),
            initialValue: _auhCurrency,
            decoration: const InputDecoration(labelText: 'Para Birimi'),
            items: const ['TRY', 'USD', 'EUR', 'GBP']
                .map((value) =>
                    DropdownMenuItem(value: value, child: Text(value)))
                .toList(),
            onChanged: (value) => setState(() => _auhCurrency = value ?? 'USD'),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
              onPressed: _saveAuhRule,
              icon: const Icon(Icons.check),
              label: const Text('Tutarlar\u0131 Uygula')),
        ],
      );

  Widget _generalTab() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.currency_exchange,
                          color: Color(0xff0a7cff)),
                      const SizedBox(width: 8),
                      Text(
                        'Döviz Kurları (Günlük Kur / Exchange)',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _two(_number('USD / TRY (Dolar)', _usd),
                      _number('EUR / TRY (Euro)', _eur)),
                  const SizedBox(height: 12),
                  _number('GBP / TRY (İngiliz Sterlini)', _gbp),
                ],
              ),
            ),
          ),
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Harç ve Defter Bedelleri (TGVH & Defter)',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _two(
                    _number('Tek Girişlik Vize Harcı (TGVH - TL)', _visaFee),
                    _number('Defter Bedeli (TL)', _defter),
                  ),
                ],
              ),
            ),
          ),
          if (widget.isAdmin) ...[
            FilledButton.icon(
              onPressed: _isSyncing ? null : _saveGeneralSettingsToServer,
              icon: _isSyncing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.cloud_upload),
              label: const Text('Kurları ve Harçları Sunucuya Kaydet'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _isSyncing ? null : _fetchServerSettings,
              icon: const Icon(Icons.cloud_download),
              label: const Text('Sunucudaki Güncel Değerleri Çek'),
            ),
            const SizedBox(height: 16),
          ],
          Text('Veri oluşturulma tarihi: ${_draft.generatedAt ?? '-'}'),
          Text(
              'UVR: ${_draft.uvr.length}  AUH: ${_draft.auh.length}  Tahdit: ${_draft.tkod.length}'),
        ],
      );

  Widget _manualTab() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Bu de\u011ferler yaln\u0131zca ana veride uygun kural veya ceza tutar\u0131 bulunamad\u0131\u011f\u0131nda admin hesab\u0131yla yap\u0131lan hesaplamalarda kullan\u0131l\u0131r.',
          ),
          const SizedBox(height: 16),
          _two(
            _number('Bir seferde kal\u0131\u015f (g\u00fcn)', _manualOneTime),
            _number('Toplam kal\u0131\u015f (g\u00fcn)', _manualLongStay),
          ),
          const SizedBox(height: 20),
          const Text('Manuel Ceza Tutar\u0131'),
          const SizedBox(height: 12),
          _two(
            _number('\u0130lk ay', _manualFirstMonth),
            _number('Sonraki ay', _manualMonthStep),
          ),
          const SizedBox(height: 12),
          _two(
            _number('G\u00fcn ba\u015flang\u0131\u00e7', _manualDayStart),
            _number('G\u00fcn art\u0131\u015f', _manualDayStep),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: ValueKey('manual-currency-$_manualCurrency'),
            initialValue: _manualCurrency,
            decoration: const InputDecoration(labelText: 'Para Birimi'),
            items: const ['TRY', 'USD', 'EUR', 'GBP']
                .map((value) =>
                    DropdownMenuItem(value: value, child: Text(value)))
                .toList(),
            onChanged: (value) =>
                setState(() => _manualCurrency = value ?? 'USD'),
          ),
        ],
      );

  Widget _tkodTab() {
    if (_draft.tkod.isEmpty) {
      return const Center(child: Text('Tahdit verisi yok.'));
    }
    final paidType = _draft.tkod[_tkodIndex].paidType;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<int>(
          key: ValueKey('tkod-$_tkodIndex'),
          initialValue: _tkodIndex,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Tahdit Kayd\u0131'),
          items: List.generate(_draft.tkod.length, (index) {
            final row = _draft.tkod[index];
            return DropdownMenuItem(
                value: index,
                child: Text(
                    '${row.code} | ${row.start}-${row.finish} | \u00d6deme ${row.paidType}'));
          }),
          onChanged: (value) => setState(() {
            _tkodIndex = value ?? 0;
            _loadTkodFields();
          }),
        ),
        const SizedBox(height: 16),
        TextField(
            controller: _tkodCode,
            decoration: const InputDecoration(labelText: 'Tahdit Kodu')),
        const SizedBox(height: 12),
        _two(_number('Ba\u015flang\u0131\u00e7 g\u00fcn\u00fc', _tkodStart),
            _number('Biti\u015f g\u00fcn\u00fc', _tkodFinish)),
        const SizedBox(height: 12),
        _number('Tahdit s\u00fcresi (g\u00fcn)', _tkodPenaltyTime),
        const SizedBox(height: 12),
        TextField(
            controller: _tkodIdariCode,
            decoration: const InputDecoration(labelText: '\u0130dari Kod')),
        const SizedBox(height: 8),
        Text('\u00d6deme tipi: $paidType',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 20),
        FilledButton.icon(
            onPressed: _saveTkodRule,
            icon: const Icon(Icons.check),
            label: const Text('Tahdit Kural\u0131n\u0131 Uygula')),
      ],
    );
  }
}

class PenaltyCalculator {
  PenaltyResult calculate(PenaltySettings settings, CezamData data) {
    final rule = data.findUvr(
          settings.country,
          settings.passport,
          settings.visa,
          settings.calculateType,
        ) ??
        settings.manualRule;

    final auh = data.findAuh(settings.country) ?? settings.manualAuh;
    final ranges = settings.entryExitPairs;
    final countedTripDays = _countedTripDays(ranges, settings.calculateType);
    final stayDays =
        countedTripDays.fold<int>(0, (total, days) => total + days);
    final tripDays = settings.calculateType == 4
        ? countedTripDays.map((_) => -1).toList()
        : countedTripDays;

    final oneTime = settings.calculateType == 4
        ? 0
        : settings.visa == 3 && settings.consularVisaDays > 0
            ? settings.consularVisaDays
            : rule.oneTime;
    var penaltyDays = 0;

    var allowedStayDays = settings.calculateType == 4 ? 1 : oneTime;

    if (settings.country == 'Beyaz Rusya' || settings.calculateType == 5) {
      allowedStayDays = 30;
      for (final days in tripDays) {
        if (days > 30) penaltyDays += days - 30;
      }
      if (stayDays > 90) {
        penaltyDays = max(penaltyDays, stayDays - 90);
        if (!tripDays.any((days) => days > 30)) {
          allowedStayDays = 90;
        }
      }
    } else {
      var exceedsOneTime = false;
      for (final days in tripDays) {
        if (days > oneTime) {
          exceedsOneTime = true;
          break;
        }
      }
      if (exceedsOneTime) {
        penaltyDays = stayDays - oneTime;
        allowedStayDays = oneTime;
      } else if (stayDays > rule.longStay) {
        penaltyDays = stayDays - rule.longStay;
        allowedStayDays = rule.longStay;
      }
    }

    if (penaltyDays <= 0) {
      throw Exception('error_no_penalty');
    }

    final penaltyMonths = penaltyDays > 30 ? penaltyDays ~/ 30 : 0;
    final remainingDays = penaltyDays > 30 ? penaltyDays % 30 : penaltyDays;
    final ticketText = penaltyMonths == 0
        ? '$remainingDays Gun'
        : remainingDays > 0
            ? '${penaltyMonths + 1} Ay'
            : '$penaltyMonths Ay';

    final penaltyAmount = _calculatePenaltyAmount(
      country: settings.country,
      ticketText: ticketText,
      adultType: settings.adultType,
      auh: auh,
    );
    final exchangeRate = settings.exchange[auh.currency] ?? 1;
    final penaltyTry = round2(penaltyAmount * exchangeRate);
    final visaFee = rule.visaFeeEnabled == 1 ? settings.visaFee : 0.0;
    final defter = {4, 10, 12, 14, 15}.contains(settings.visa)
        ? 0.0
        : settings.defterPrice;
    final administrative = settings.visa == 11 ? 20605.0 : 0.0;
    final total = penaltyTry + visaFee + defter + administrative;
    final tahditRule = data.findTkod(penaltyDays, settings.paymentType);
    if (tahditRule == null) {
      throw Exception('error_restriction_missing');
    }

    return PenaltyResult(
      stayDays: stayDays,
      allowedStayDays: allowedStayDays,
      penaltyMonths: penaltyMonths,
      penaltyDays: remainingDays,
      ticketText: ticketText,
      referenceExitDate: _referenceExit(ranges),
      shouldExitDate:
          _referenceExit(ranges).subtract(Duration(days: penaltyDays)),
      penaltyAmount: penaltyAmount,
      currency: auh.currency,
      exchangeRate: exchangeRate,
      penaltyTry: penaltyTry,
      visaFee: visaFee,
      defter: defter,
      administrativeFine: administrative,
      total: total,
      tahditCode: settings.adultType == 1 ? '---' : tahditRule.code,
      idariTahditCode: tahditRule.idariCode,
      tahditPenaltyDays: tahditRule.penaltyTime,
    );
  }

  List<int> _countedTripDays(List<DateRange> ranges, int calculateType) {
    for (final range in ranges) {
      if (range.entry.isAfter(range.exit)) {
        throw Exception('error_date_order');
      }
    }

    // Tek kayitta eski hesaplama davranisi kesinlikle korunur.
    if (ranges.length == 1) {
      final range = ranges.single;
      if (calculateType == 4) return const [1];
      return [max(1, range.exit.difference(range.entry).inDays)];
    }

    // Schengen penceresi referans gun dahil 180 takvim gunudur.
    final referenceExit = _referenceExit(ranges);
    final windowStart = referenceExit.subtract(const Duration(days: 179));

    return ranges.map((range) {
      final clippedEntry =
          range.entry.isBefore(windowStart) ? windowStart : range.entry;
      final clippedExit =
          range.exit.isAfter(referenceExit) ? referenceExit : range.exit;
      if (clippedEntry.isAfter(clippedExit)) return 0;
      if (calculateType == 4) return 1;

      // Schengen hesabinda hem giris hem cikis gunu kalis gunudur.
      return clippedExit.difference(clippedEntry).inDays + 1;
    }).toList();
  }

  DateTime _referenceExit(List<DateRange> ranges) =>
      ranges.map((range) => range.exit).reduce((a, b) => a.isAfter(b) ? a : b);

  double _calculatePenaltyAmount({
    required String country,
    required String ticketText,
    required int adultType,
    required AuhRule auh,
  }) {
    final group = countryGroup(country);
    var amount = 0.0;

    if (ticketText.contains('Ay')) {
      final months = int.tryParse(ticketText.replaceAll(' Ay', '').trim()) ?? 0;
      if (group == CountryGroup.g) {
        amount = auh.firstMonth * 2;
      } else {
        for (var i = 0; i < months; i++) {
          amount += i == 0 ? auh.firstMonth : auh.monthStep;
        }
        amount *= adultType;
      }
    } else {
      final days = int.tryParse(ticketText.replaceAll(' Gun', '').trim()) ?? 0;
      amount = auh.dayStart;
      for (var i = 1; i < days + 1; i++) {
        switch (group) {
          case CountryGroup.a:
          case CountryGroup.e:
            if (i > 10 && i < 26) amount += auh.dayStep;
            if (i == 26) amount = amount.ceilToDouble();
            break;
          case CountryGroup.b:
            if (i > 10 && i < 29) amount += auh.dayStep;
            if (i == 29) amount = amount.ceilToDouble();
            break;
          case CountryGroup.c:
            if (i > 10 && i < 24) amount += auh.dayStep;
            if (i == 24) amount = amount.ceilToDouble();
            break;
          case CountryGroup.d:
            if (i > 10 && i < 25) amount += auh.dayStep;
            if (i == 25) amount = amount.ceilToDouble();
            break;
          case CountryGroup.f:
            if (i > 1 && i < 9) {
              amount += auh.dayStep;
            } else if (i == 9) {
              amount += 467.6;
            }
            if (i == 10) amount = amount.ceilToDouble();
            break;
          case CountryGroup.g:
            amount = auh.firstMonth;
            break;
          case CountryGroup.none:
            break;
        }
      }
      amount = group == CountryGroup.g ? amount * 2 : amount * adultType;
      amount = round2(amount);
    }

    return amount;
  }
}

class CezamData {
  CezamData({
    required this.generatedAt,
    required this.exchange,
    required this.defterPrice,
    required this.embeddedCountries,
    required this.tgvh,
    required this.uvr,
    required this.auh,
    required this.tkod,
  });

  factory CezamData.empty() => CezamData(
        generatedAt: null,
        exchange: const {'EUR': 1, 'USD': 1, 'GBP': 1, 'TRY': 1},
        defterPrice: 0,
        embeddedCountries: const [],
        tgvh: const [],
        uvr: const [],
        auh: const [],
        tkod: const [],
      );

  factory CezamData.fromJson(Map<String, dynamic> json) {
    final exchangeJson = (json['exchange'] as Map<String, dynamic>? ?? {});
    final defterJson = (json['defter'] as Map<String, dynamic>? ?? {});
    return CezamData(
      generatedAt: json['generatedAt']?.toString(),
      exchange: {
        'EUR': asDouble(exchangeJson['EUR']),
        'USD': asDouble(exchangeJson['USD']),
        'GBP': asDouble(exchangeJson['GBP']),
        'TRY': 1,
      },
      defterPrice: asDouble(defterJson['price']),
      embeddedCountries: (json['countries'] as List<dynamic>? ?? [])
          .map((country) => country.toString().trim())
          .where((country) => country.isNotEmpty)
          .toList(),
      tgvh: (json['tgvh'] as List<dynamic>? ?? [])
          .map((row) => TgvhRule.fromJson(row as Map<String, dynamic>))
          .toList(),
      uvr: (json['uvr'] as List<dynamic>? ?? [])
          .map((row) => UvrRule.fromJson(row as Map<String, dynamic>))
          .toList(),
      auh: (json['auh'] as List<dynamic>? ?? [])
          .map((row) => AuhRule.fromJson(row as Map<String, dynamic>))
          .toList(),
      tkod: (json['tkod'] as List<dynamic>? ?? [])
          .map((row) => TkodRule.fromJson(row as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'version': 1,
        'generatedAt': generatedAt,
        'countries': embeddedCountries,
        'exchange': exchange,
        'defter': {'price': defterPrice},
        'tgvh': tgvh.map((row) => row.toJson()).toList(),
        'uvr': uvr.map((row) => row.toJson()).toList(),
        'auh': auh.map((row) => row.toJson()).toList(),
        'tkod': tkod.map((row) => row.toJson()).toList(),
      };

  final String? generatedAt;
  final Map<String, double> exchange;
  final double defterPrice;
  final List<String> embeddedCountries;
  final List<TgvhRule> tgvh;
  final List<UvrRule> uvr;
  final List<AuhRule> auh;
  final List<TkodRule> tkod;

  List<String> get countries {
    final names = <String>{};
    names.addAll(embeddedCountries);
    names.addAll(uvr.map((x) => x.country));
    names.addAll(auh.map((x) => x.country));
    final list = names.where((x) => x.isNotEmpty).toList()..sort();
    return list;
  }

  UvrRule? findUvr(String country, int passport, int visa, int calculateType) {
    for (final row in uvr) {
      if (row.country == country &&
          row.passportType == passport &&
          row.visaStatus == visa &&
          row.calculateType == calculateType) {
        return row;
      }
    }
    return null;
  }

  AuhRule? findAuh(String country) {
    for (final row in auh) {
      if (row.country == country) return row;
    }
    return null;
  }

  TkodRule? findTkod(int penaltyDays, int paymentType) {
    for (final row in tkod) {
      if (row.start <= penaltyDays &&
          row.finish >= penaltyDays &&
          row.paidType == paymentType) {
        return row;
      }
    }
    return null;
  }
}

class UvrRule {
  const UvrRule({
    required this.country,
    required this.calculateType,
    required this.passportType,
    required this.visaStatus,
    required this.day,
    required this.longStay,
    required this.oneTime,
    required this.visaFeeEnabled,
  });

  factory UvrRule.fromJson(Map<String, dynamic> json) => UvrRule(
        country: json['country']?.toString().trim() ?? '',
        calculateType: asInt(json['calculateType']),
        passportType: asInt(json['passportType']),
        visaStatus: asInt(json['visaStatus']),
        day: asInt(json['day']),
        longStay: asInt(json['longStay']),
        oneTime: asInt(json['oneTime']),
        visaFeeEnabled: asInt(json['visaFeeEnabled']),
      );

  Map<String, dynamic> toJson() => {
        'country': country,
        'calculateType': calculateType,
        'passportType': passportType,
        'visaStatus': visaStatus,
        'day': day,
        'longStay': longStay,
        'oneTime': oneTime,
        'visaFeeEnabled': visaFeeEnabled,
      };

  final String country;
  final int calculateType;
  final int passportType;
  final int visaStatus;
  final int day;
  final int longStay;
  final int oneTime;
  final int visaFeeEnabled;
}

class AuhRule {
  const AuhRule({
    required this.country,
    required this.firstMonth,
    required this.monthStep,
    required this.dayStart,
    required this.dayStep,
    required this.currency,
  });

  factory AuhRule.fromJson(Map<String, dynamic> json) => AuhRule(
        country: json['country']?.toString().trim() ?? '',
        firstMonth: asDouble(json['firstMonth']),
        monthStep: asDouble(json['monthStep']),
        dayStart: asDouble(json['dayStart']),
        dayStep: asDouble(json['dayStep']),
        currency: json['currency']?.toString().trim() ?? 'TRY',
      );

  Map<String, dynamic> toJson() => {
        'country': country,
        'firstMonth': firstMonth,
        'monthStep': monthStep,
        'dayStart': dayStart,
        'dayStep': dayStep,
        'currency': currency,
      };

  final String country;
  final double firstMonth;
  final double monthStep;
  final double dayStart;
  final double dayStep;
  final String currency;
}

class TgvhRule {
  const TgvhRule({required this.year, required this.price});

  factory TgvhRule.fromJson(Map<String, dynamic> json) => TgvhRule(
        year: json['year']?.toString() ?? '',
        price: asDouble(json['price']),
      );

  Map<String, dynamic> toJson() =>
      {'year': year, 'price': price, 'currency': 'TRY'};

  final String year;
  final double price;
}

class TkodRule {
  const TkodRule({
    required this.code,
    required this.penaltyTime,
    required this.start,
    required this.finish,
    required this.idariCode,
    required this.paidType,
  });

  factory TkodRule.fromJson(Map<String, dynamic> json) => TkodRule(
        code: json['code']?.toString().trim() ?? '',
        penaltyTime: asInt(json['penaltyTime']),
        start: asInt(json['start']),
        finish: asInt(json['finish']),
        idariCode: json['idariCode']?.toString().trim() ?? '',
        paidType: asInt(json['paidType']),
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'penaltyTime': penaltyTime,
        'start': start,
        'finish': finish,
        'idariCode': idariCode,
        'paidType': paidType,
      };

  final String code;
  final int penaltyTime;
  final int start;
  final int finish;
  final String idariCode;
  final int paidType;
}

class PenaltySettings {
  const PenaltySettings({
    required this.country,
    required this.passport,
    required this.visa,
    required this.consularVisaDays,
    required this.calculateType,
    required this.adultType,
    required this.entryExitPairs,
    required this.manualRule,
    required this.manualAuh,
    required this.exchange,
    required this.defterPrice,
    required this.visaFee,
    required this.paymentType,
  });

  final String country;
  final int passport;
  final int visa;
  final int consularVisaDays;
  final int calculateType;
  final int adultType;
  final List<DateRange> entryExitPairs;
  final UvrRule manualRule;
  final AuhRule manualAuh;
  final Map<String, double> exchange;
  final double defterPrice;
  final double visaFee;
  final int paymentType;
}

class DateRange {
  const DateRange(this.entry, this.exit);

  final DateTime entry;
  final DateTime exit;
}

class EntryExitControllers {
  EntryExitControllers();

  final TextEditingController entry = TextEditingController();
  final TextEditingController exit = TextEditingController();

  void dispose() {
    entry.dispose();
    exit.dispose();
  }
}

class PenaltyResult {
  const PenaltyResult({
    required this.stayDays,
    required this.allowedStayDays,
    required this.penaltyMonths,
    required this.penaltyDays,
    required this.ticketText,
    required this.referenceExitDate,
    required this.shouldExitDate,
    required this.penaltyAmount,
    required this.currency,
    required this.exchangeRate,
    required this.penaltyTry,
    required this.visaFee,
    required this.defter,
    required this.administrativeFine,
    required this.total,
    required this.tahditCode,
    required this.idariTahditCode,
    required this.tahditPenaltyDays,
  });

  final int stayDays;
  final int allowedStayDays;
  final int penaltyMonths;
  final int penaltyDays;
  final String ticketText;
  final DateTime referenceExitDate;
  final DateTime shouldExitDate;
  final double penaltyAmount;
  final String currency;
  final double exchangeRate;
  final double penaltyTry;
  final double visaFee;
  final double defter;
  final double administrativeFine;
  final double total;
  final String tahditCode;
  final String idariTahditCode;
  final int tahditPenaltyDays;

  int get violationDays => (penaltyMonths * 30) + penaltyDays;

  bool get hasEntryBan =>
      tahditPenaltyDays > 0 && foldTurkish(tahditCode).contains('C');

  DateTime get schengenReEntryDate =>
      referenceExitDate.add(const Duration(days: 90));

  DateTime earliestReEntryDate(DateTime today) {
    if (!hasEntryBan) return schengenReEntryDate;

    final normalizedToday = DateTime(today.year, today.month, today.day);
    final entryBanEndDate =
        normalizedToday.add(Duration(days: tahditPenaltyDays));
    return entryBanEndDate.isAfter(schengenReEntryDate)
        ? entryBanEndDate
        : schengenReEntryDate;
  }
}

double asDouble(Object? value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().replaceAll(',', '.')) ?? 0;
}

int asInt(Object? value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

double readDouble(TextEditingController controller) =>
    asDouble(controller.text);

int readInt(TextEditingController controller) => asInt(controller.text);

double round2(double value) => (value * 100).roundToDouble() / 100;

class PaymentOption {
  const PaymentOption(this.value, this.label);

  final int value;
  final String label;
}

List<PaymentOption> paymentOptionsForVisa(int visa) {
  switch (visa) {
    case 14:
      return const [
        PaymentOption(14, 'Ikamet Teskereli V-157 Odeyen'),
        PaymentOption(15, 'Ikamet Teskereli V-157 Odemeyen'),
      ];
    case 13:
      return const [
        PaymentOption(16, 'V-137 Vize Sureli Odeyen'),
        PaymentOption(17, 'V-137 Vize Sureli Odemeyen'),
      ];
    case 11:
      return const [
        PaymentOption(4, 'V-137 Odeyen'),
        PaymentOption(5, 'V-137 Odemeyen'),
      ];
    case 9:
      return const [
        PaymentOption(6, 'V-157 Odeyen'),
        PaymentOption(7, 'V-157 Odemeyen'),
      ];
    case 10:
      return const [
        PaymentOption(8, 'V-69 Odeyen'),
        PaymentOption(9, 'V-69 Odemeyen'),
      ];
    case 12:
      return const [
        PaymentOption(10, 'V-88 Odeyen'),
        PaymentOption(11, 'V-88 Odemeyen'),
      ];
    case 7:
      return const [
        PaymentOption(2, 'V-84 Odeyen'),
        PaymentOption(3, 'V-84 Odemeyen'),
      ];
    default:
      return const [
        PaymentOption(1, 'Odeyen'),
        PaymentOption(0, 'Odemeyen'),
      ];
  }
}

bool _usesSpecialVisaDate(int visa) {
  return const {4, 10, 12, 13, 14, 15}.contains(visa);
}

bool isPaidPaymentType(int paymentType) {
  return const {1, 2, 4, 6, 8, 10, 14, 16}.contains(paymentType);
}

DateTime? parseDate(String value) {
  final parts = value.split('.');
  if (parts.length != 3) return null;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;
  return DateTime(year, month, day);
}

bool isChildOn(DateTime birthDate, DateTime referenceDate) {
  var age = referenceDate.year - birthDate.year;
  if (referenceDate.month < birthDate.month ||
      (referenceDate.month == birthDate.month &&
          referenceDate.day < birthDate.day)) {
    age--;
  }
  return age < 18;
}

String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}

const _priorityCountryCodes = <String, String>{
  'Rusya Federasyonu': 'RU',
  '\u0130ran': 'IR',
  'Bulgaristan': 'BG',
  'Yunanistan': 'GR',
  'Almanya': 'DE',
  'G\u00fcrcistan': 'GE',
  'Azerbaycan': 'AZ',
  'Ermenistan': 'AM',
  'Irak': 'IQ',
  'Suriye': 'SY',
  'Ukrayna': 'UA',
  'Romanya': 'RO',
  'Moldovya Cumhuriyeti': 'MD',
  'Beyaz Rusya': 'BY',
  'S\u0131rbistan': 'RS',
  'S\u0131rbistan-Karada\u011f': 'RS',
  'Makedonya': 'MK',
  'Arnavutluk': 'AL',
  'Kosova': 'XK',
  'Bosna Hersek': 'BA',
  'Karada\u011f': 'ME',
  'H\u0131rvatistan': 'HR',
  'Slovenya': 'SI',
  'Macaristan': 'HU',
  'G\u00fcney K\u0131br\u0131s Rum Kesimi': 'CY',
  'L\u00fcbnan': 'LB',
  '\u0130srail': 'IL',
  'Filistin B\u00f6lgesi': 'PS',
  '\u00dcrd\u00fcn': 'JO',
  'M\u0131s\u0131r': 'EG',
};

List<String> countriesForSelection(Iterable<String> countryNames) {
  final available = countryNames.toSet();
  final priority = _priorityCountryCodes.keys
      .where(available.contains)
      .toList(growable: false);
  final remaining = available
      .where((name) => !_priorityCountryCodes.containsKey(name))
      .toList()
    ..sort((a, b) => foldTurkish(a).compareTo(foldTurkish(b)));
  return [...priority, ...remaining];
}

String countryDisplayName(String country, [BuildContext? context]) {
  final code = countryCodes[country];
  if (code == null) return country;
  final localizedName = context == null
      ? country
      : CountryLocalizations.of(context)?.countryName(countryCode: code) ??
          country;
  return '${_flagEmoji(code)}  $code — $localizedName';
}

String _flagEmoji(String countryCode) => countryCode
    .toUpperCase()
    .codeUnits
    .map((letter) => String.fromCharCode(0x1F1E6 + letter - 65))
    .join();

enum CountryGroup { a, b, c, d, e, f, g, none }

CountryGroup countryGroup(String country) {
  final folded = foldTurkish(country);
  if (_aGroup.contains(folded)) return CountryGroup.a;
  if (_bGroup.contains(folded)) return CountryGroup.b;
  if (_cGroup.contains(folded)) return CountryGroup.c;
  if (_dGroup.contains(folded)) return CountryGroup.d;
  if (_eGroup.contains(folded)) return CountryGroup.e;
  if (_fGroup.contains(folded)) return CountryGroup.f;
  if (_gGroup.contains(folded)) return CountryGroup.g;
  return CountryGroup.none;
}

String foldTurkish(String value) {
  return value
      .trim()
      .replaceAll('Ç', 'C')
      .replaceAll('ç', 'c')
      .replaceAll('Ğ', 'G')
      .replaceAll('ğ', 'g')
      .replaceAll('İ', 'I')
      .replaceAll('I', 'I')
      .replaceAll('ı', 'i')
      .replaceAll('Ö', 'O')
      .replaceAll('ö', 'o')
      .replaceAll('Ş', 'S')
      .replaceAll('ş', 's')
      .replaceAll('Ü', 'U')
      .replaceAll('ü', 'u');
}

const _aGroup = {
  'ABD Virgin Adalari',
  'Afganistan',
  'Aland Adalari',
  'Almanya',
  'Amerika Birlesik Devletleri',
  'Amerika Birlesik Devletleri Kucuk Dis Adalari',
  'Amerikan Samoasi',
  'Andora',
  'Angola',
  'Anguilla',
  'Antarktika',
  'Antigua ve Barbuda',
  'Arjantin',
  'Aruba',
  'Avrupa Birligi',
  'Avustralya',
  'Avusturya',
  'Azerbaycan',
  'Bahamalar',
  'Bahreyn',
  'Banglades',
  'Barbados',
  'Bati Sahara',
  'Belize',
  'Benin',
  'Bermuda',
  'Bhutan',
  'Bilinmeyen veya Gecersiz Bolge',
  'Birlesik Arap Emirlikleri',
  'Birlesik Krallik',
  'Bolivya',
  'Bosna Hersek',
  'Botsvana',
  'Bouvet Adasi',
  'Brezilya',
  'Brunei',
  'Bulgaristan',
  'Burkina Faso',
  'Burundi',
  'Cape Verde',
  'Cebelitarik',
  'Christmas Adasi',
  'Cibuti',
  'Cocos Adalari',
  'Cook Adalari',
  'Cad',
  'Cin',
  'Dominik',
  'Dominik Cumhuriyeti',
  'Dogu Timor',
  'Ekvator',
  'Ekvator Ginesi',
  'El Salvador',
  'Endonezya',
  'Eritre',
  'Ermenistan',
  'Estonya',
  'Falkland Adalari (Malvinalar)',
  'Faroe Adalari',
  'Filistin Bolgesi',
  'Finlandiya',
  'Fransa',
  'Fransiz Guyanasi',
  'Fransiz Guney Bolgeleri',
  'Fransiz Polinezyasi',
  'Gabon',
  'Gambia',
  'Gana',
  'Gine',
  'Gine-Bissau',
  'Granada',
  'Gronland',
  'Guadeloupe',
  'Guam',
  'Guatemala',
  'Guernsey',
  'Guyana',
  'Guney Afrika',
  'Guney Georgia ve Guney Sandwich Adalari',
  'Guney Kibris Rum Kesimi',
  'Gurcistan',
  'Haiti',
  'Heard Adasi ve McDonald Adalari',
  'Hindistan',
  'Hint Okyanusu Ingiliz Bolgesi',
  'Hollanda',
  'Hollanda Antilleri',
  'Honduras',
  'Hirvatistan',
  'Ingiliz Virgin Adalari',
  'Iran',
  'Isvec',
  'Isvicre',
  'Italya',
  'Izlanda',
  'Jamaika',
  'Jersey',
  'Kamerun',
  'Kanada',
  'Katar',
  'Kayman Adalari',
  'Kazakistan',
  'Kenya',
  'Kiribati',
  'Kolombiya',
  'Komorlar',
  'Kongo',
  'Kongo Demokratik Cumhuriyeti',
  'Kosta Rika',
  'Kuzey Kore',
  'Kuba',
  'Kirgizistan',
  'Laos',
  'Lesotho',
  'Letonya',
  'Liberya',
  'Libya',
  'Liechtenstein',
  'Litvanya',
  'Lubnan',
  'Macaristan',
  'Madagaskar',
  'Makao S.A.R. Cin',
  'Malavi',
  'Maldivler',
  'Malezya',
  'Man Adasi',
  'Marshall Adalari',
  'Martinik',
  'Mauritius',
  'Mayotte',
  'Meksika',
  'Moldovya Cumhuriyeti',
  'Monako',
  'Montserrat',
  'Moritanya',
  'Mozambik',
  'Mogolistan',
  'Myanmar',
  'Namibya',
  'Nauru',
  'Nijer',
  'Nijerya',
  'Nikaragua',
  'Niue',
  'Norfolk Adasi',
  'Orta Afrika Cumhuriyeti',
  'Ozbekistan',
  'Pakistan',
  'Palau',
  'Panama',
  'Papua Yeni Gine',
  'Paraguay',
  'Peru',
  'Pitcairn',
  'Polonya',
  'Portekiz',
  'Porto Riko',
  'Reunion',
  'Romanya',
  'Ruanda',
  'Saint Helena',
  'Saint Kitts ve Nevis',
  'Saint Lucia',
  'Saint Pierre ve Miquelon',
  'Saint Vincent ve Grenadinler',
  'Samoa',
  'San Marino',
  'Sao Tome ve Principe',
  'Senegal',
  'Seyseller',
  'Sierra Leone',
  'Slovakya',
  'Slovenya',
  'Solomon Adalari',
  'Somali',
  'Sudan',
  'Surinam',
  'Suudi Arabistan',
  'Svalbard ve Jan Mayen',
  'Svaziland',
  'Sili',
  'Tanzanya',
  'Tayland',
  'Togo',
  'Tokelau',
  'Tonga',
  'Trinidad ve Tobago',
  'Turks ve Caicos Adalari',
  'Tuvalu',
  'Uganda',
  'Ukrayna',
  'Uruguay',
  'Uzak Okyanusya',
  'Vanuatu',
  'Vatikan',
  'Venezuela',
  'Vietnam',
  'Wallis ve Futuna',
  'Yemen',
  'Yeni Kaledonya',
  'Yeni Zelanda',
  'Yunanistan',
  'Zambiya',
  'Zimbabve',
};

const _bGroup = {
  'Filipinler',
  'Israil',
  'Japonya',
  'Kambocya',
  'Makedonya',
  'Mali',
  'Umman',
  'Arnavutluk',
  'Tacikistan',
};

const _cGroup = {
  'Ispanya',
  'Malta',
  'Beyaz Rusya',
  'Kuveyt',
  'Belcika',
  'Singapur',
  'Tayvan',
  'Cezayir',
  'Luksemburg',
  'Urdun',
};

const _dGroup = {
  'Hong Kong SAR - Cin',
  'Mikronezya Federal Eyaletleri',
  'Rusya Federasyonu',
  'Etiyopya',
  'Guney Kore',
};

const _eGroup = {
  'Fas',
  'Fildisi Sahilleri',
  'Irak',
  'Sirbistan-Karadag',
  'Karadag',
  'Misir',
  'Tunus',
};

const _fGroup = {
  'Norvec',
  'Sirbistan',
  'Fiji',
  'Kuzey Mariana Adalari',
};

const _gGroup = {
  'Danimarka',
  'Kosova',
  'Cek Cumhuriyeti',
  'Irlanda',
  'Nepal',
  'Sri Lanka',
  'Suriye',
  'Turkmenistan',
};
