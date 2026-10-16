# Aplikasi Mobile Daycare

Aplikasi Flutter untuk **pengasuh** dan **orang tua** dalam satu app; tampilan berganti sesuai peran pengguna yang login.

- **Pengasuh**: daftar anak hari ini, check-in/check-out, catat aktivitas (makan, tidur, toilet, main, medis) lewat chip dan bottom sheet, ambil foto/video dengan `camerawesome`.
- **Orang tua**: timeline harian anak (aktivitas, absensi, foto/video).

## Offline-first

Semua penulisan disimpan dulu ke database lokal Isar (`isar_community`) beserta antrean *outbox*, lalu dikirim ke API oleh `lib/data/sync_service.dart`: outbox dikirim berurutan, kemudian perubahan ditarik lewat `GET /api/v1/sync`. Protokolnya ada di `../docs/API.md` bagian "Sinkronisasi offline-first".

## Struktur

| Lokasi | Isi |
|---|---|
| `lib/core/` | API client (Dio + JWT), sesi, format tanggal, label |
| `lib/data/` | Model Isar, aksi pengasuh, layanan sinkronisasi |
| `lib/features/` | Layar: `login`, `caregiver`, `parent`, `timeline`, `common` |
| `lib/providers.dart` | Provider Riverpod |
| `lib/config.dart` | URL backend |

## Menjalankan

Lokasi toolchain dan variabel lingkungan (Flutter, JDK 21, Android SDK) mengikuti pengaturan mesin pengembang.

```sh
flutter pub get
flutter run                                   # pakai backend default (Render)
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080   # backend lokal
flutter build apk --debug                     # hasil: build/app/outputs/flutter-apk/
```

Setelah mengubah model di `lib/data/models.dart`, buat ulang kode Isar:

```sh
dart run build_runner build --delete-conflicting-outputs
```

## Tes

```sh
flutter analyze
flutter test
```

Tes sinkronisasi memakai Isar sungguhan; `flutter test` mengunduh library native Isar (`libisar.*`) saat pertama kali dijalankan. File itu diabaikan oleh git.
