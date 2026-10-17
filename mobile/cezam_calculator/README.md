# CEZAM Offline Calculator

Flutter tabanli, internet ve kurum agi olmadan calisacak ceza hesaplama uygulamasi taslagi.

Bu klasor Flutter SDK kurulu olmayan ortamda elle olusturuldu. SDK kurulduktan sonra:

```powershell
cd mobile\cezam_calculator
flutter create --platforms=android .
flutter pub get
flutter run
```

Gercek CEZAM verilerini aktarmak icin:

```powershell
powershell -ExecutionPolicy Bypass -File tools\export_cezam_data.ps1
```

Export basarili olursa `assets/cezam_data.json` guncellenir. Uygulama ayrica manuel ayarlarla da hesaplama yapabilir.
