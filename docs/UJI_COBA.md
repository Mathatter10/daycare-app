# Panduan Uji Coba (Sprint 1–6)

Fitur yang bisa dicoba sekarang:

| Bagian | Bisa dicoba |
|---|---|
| **Admin web** (`/admin`) | Login, dashboard, kelola kelas, pengasuh, orang tua, dan anak |
| **API mobile** (`/api/v1`) | Login, daftar anak, check-in/out, catat aktivitas, timeline orang tua, sync |
| **Aplikasi mobile** (Android) | Login pengasuh/orang tua, catat absensi & aktivitas, foto, timeline, mode offline |

Foto/video bisa dicoba setelah R2 dikonfigurasi ([DEPLOYMENT.md](DEPLOYMENT.md) bagian 7). Push notification belum bisa diterima: aplikasi belum mendaftarkan token FCM. Bagian D–F mencoba API langsung lewat PowerShell; bagian G mencoba aplikasinya.

Semua perintah dijalankan di **PowerShell** dari folder `backend-go`:

```powershell
cd D:\Project\daycare-app\backend-go
```

---

## A. Coba di komputer sendiri (disarankan)

Pakai database Neon branch **`dev`** supaya data uji tidak masuk ke produksi.

### 1. Cek file `.env`

Buka `backend-go\.env` dan pastikan:

```env
DATABASE_URL=postgresql://...neon.tech/neondb?sslmode=require   # branch dev, alamat direct (tanpa -pooler)
JWT_SECRET=<minimal 32 karakter>
```

Belum punya `JWT_SECRET` yang cukup panjang? Buat dengan:

```powershell
$b = New-Object byte[] 48; [Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($b); [Convert]::ToBase64String($b)
```

### 2. Siapkan database dan akun admin (sekali saja)

```powershell
go tool goose -dir migrations postgres "<DATABASE_URL dev>" up
go run ./cmd/createuser -email admin@daycare.id -name "Admin Uji" -role admin
```

Kata sandi admin akan ditanyakan (minimal 8 karakter, ketikan tidak terlihat).
Jika muncul `duplicate key ... users_email_lower_key`, berarti akun itu sudah ada. Lanjut saja.

### 3. Jalankan server

```powershell
npm install          # sekali saja
npm run css
go run ./cmd/server
```

Biarkan jendela ini terbuka. Server siap jika muncul log `"msg":"server listening"`.

### 4. Buka admin web

Buka **http://localhost:8080/admin** di browser, lalu login dengan akun admin dari langkah 2.

Lanjut ke bagian **C**.

---

## B. Coba di Render (online)

Kode Sprint 2 dan 3 **belum** ada di Render. Langkahnya:

1. Commit Sprint 3, push branch, lalu merge ke `main` di GitHub. Render otomatis deploy.
2. Di Render → **Environment**: pastikan `JWT_SECRET` minimal 32 karakter. `SESSION_SECRET` boleh dihapus.
3. Buat akun admin produksi dari komputer sendiri:
   ```powershell
   go run ./cmd/createuser -database-url "<DATABASE_URL produksi>" -email admin@daycare.id -name "Nama Admin" -role admin
   ```
4. Buka **https://\<nama-app\>.onrender.com/admin** dan login.

Paket gratis Render "tidur" setelah 15 menit tidak dipakai. Request pertama bisa butuh ±1 menit.

---

## C. Skenario uji coba admin web

Ikuti urutan ini karena datanya saling bergantung.

| # | Langkah | Yang seharusnya terjadi |
|---|---|---|
| 1 | Menu **Pengasuh** → *Tambah pengasuh*. Isi nama dan email, lalu Simpan. | Muncul kotak **kata sandi sementara**. **Catat**, karena hanya tampil sekali. Baris baru muncul di tabel. |
| 2 | Menu **Kelas** → *Tambah kelas*. Isi nama (mis. "Bayi"), centang pengasuh dari langkah 1. | Kelas muncul dengan nama pengasuhnya. |
| 3 | Menu **Orang Tua** → *Tambah orang tua*. | Kata sandi sementara orang tua muncul. Catat juga. |
| 4 | Menu **Anak** → *Tambah anak*. Isi nama, tanggal lahir, pilih kelas, isi **email orang tua** dari langkah 3, dan isi alergi (mis. "Kacang"). | Anak muncul dengan tanda merah **⚠ Alergi**. |
| 5 | Di menu **Anak**, coba ketik di kolom cari dan ganti filter kelas. | Tabel tersaring tanpa reload halaman. |
| 6 | Klik **Ubah** pada salah satu baris, ubah data, lalu Simpan. | Baris berubah di tempat. |
| 7 | Menu **Orang Tua**. | Kolom *Anak* menampilkan nama anak dari langkah 4. |
| 8 | Klik **Dashboard**. | Angka anak, kelas, pengasuh, dan orang tua bertambah. |

Uji juga validasinya:
- Tambah anak dengan email orang tua yang belum terdaftar → muncul pesan *"Akun orang tua dengan email ini tidak ditemukan"*.
- Tambah pengasuh dengan email yang sama → muncul pesan *"Email ini sudah terdaftar"*.
- Isi tanggal lahir di masa depan → ditolak.

---

## D. Coba API mobile (login pengasuh / orang tua)

Ganti `$B` dengan `https://<nama-app>.onrender.com` jika mencoba di Render.

```powershell
$B = "http://localhost:8080"

# 1. Login dengan email + kata sandi sementara dari bagian C
$login = Invoke-RestMethod -Method Post "$B/api/v1/auth/login" -ContentType "application/json" `
  -Body (@{ email = "email-pengasuh@contoh.id"; password = "KATA-SANDI-SEMENTARA" } | ConvertTo-Json)
$login.user

# 2. Ambil profil dengan access token
Invoke-RestMethod "$B/api/v1/me" -Headers @{ Authorization = "Bearer $($login.access_token)" }

# 3. Refresh token (dapat pasangan token baru)
$baru = Invoke-RestMethod -Method Post "$B/api/v1/auth/refresh" -ContentType "application/json" `
  -Body (@{ refresh_token = $login.refresh_token } | ConvertTo-Json)
$baru.expires_at
```

Uji keamanannya:
- **Akun admin** login di API → ditolak (`403`), karena admin hanya untuk web.
- Di admin web, klik **Nonaktifkan** pada pengasuh itu, lalu ulangi langkah 2 → ditolak (`401`). Akun langsung keluar.
- Klik **Reset sandi** → kata sandi lama tidak bisa dipakai login lagi.

Detail semua endpoint ada di [API.md](API.md).

---

## E. Coba absensi dan aktivitas (Sprint 4)

Lanjutan dari bagian D. Login sebagai **pengasuh** yang sudah ditugaskan ke kelas, dan pastikan ada anak di kelas itu (bagian C).

```powershell
$H = @{ Authorization = "Bearer $($login.access_token)" }   # token pengasuh dari bagian D

# 1. Daftar anak di kelas pengasuh
$anak = (Invoke-RestMethod "$B/api/v1/children" -Headers $H).children
$anak | Format-Table full_name, class_name
$childId = $anak[0].id

# 2. Check-in
Invoke-RestMethod -Method Post "$B/api/v1/attendance/check-in" -Headers $H -ContentType "application/json" `
  -Body (@{ child_id = $childId } | ConvertTo-Json)

# 3. Catat makan (id aktivitas dibuat di sisi aplikasi)
$actId = [guid]::NewGuid().ToString()
$makan = @{
  child_id   = $childId
  type       = "eat"
  started_at = (Get-Date).ToString("o")
  details    = @{ portion = "half"; menu = "Bubur ayam" }
  notes      = "Lahap"
} | ConvertTo-Json
Invoke-RestMethod -Method Put "$B/api/v1/activities/$actId" -Headers $H -ContentType "application/json" -Body $makan

# 4. Lihat timeline hari ini
Invoke-RestMethod "$B/api/v1/children/$childId/timeline" -Headers $H | ConvertTo-Json -Depth 5

# 5. Check-out
Invoke-RestMethod -Method Post "$B/api/v1/attendance/check-out" -Headers $H -ContentType "application/json" `
  -Body (@{ child_id = $childId; picked_up_by = "Ibu" } | ConvertTo-Json)
```

Lalu login sebagai **orang tua** anak itu (ulangi bagian D dengan email orang tua) dan panggil timeline yang sama (langkah 4). Hasil yang seharusnya:
- Orang tua melihat check-in, aktivitas makan beserta nama pengasuh, dan check-out.
- Orang tua lain atau pengasuh kelas lain mendapat `404 child not found`.
- Orang tua yang mencoba check-in mendapat `403`.

Jenis aktivitas lain dan isi `details`-nya ada di [API.md](API.md#aktivitas-khusus-caregiver).

---

## F. Coba upload foto (Sprint 5)

Butuh R2 sudah dikonfigurasi ([DEPLOYMENT.md](DEPLOYMENT.md) bagian 7a). Karena PowerShell 5.1 tidak mendukung upload file dengan mudah, gunakan **`curl.exe`** (sudah ada di Windows 10/11). Lanjutan dari bagian E, masih dengan token pengasuh:

```powershell
$fotoId = [guid]::NewGuid().ToString()
curl.exe -X PUT "$B/api/v1/media/$fotoId/photo" `
  -H "Authorization: Bearer $($login.access_token)" `
  -F "file=@C:\Users\NAMA\Pictures\contoh.jpg" `
  -F "child_id=$childId"

# Tunggu 1-2 detik, lalu ambil hasilnya (status "ready" + url)
$foto = Invoke-RestMethod "$B/api/v1/media/$fotoId" -Headers $H
$foto.status
Start-Process $foto.url     # membuka foto di browser
```

Yang seharusnya terjadi:
- Foto tampil tegak (tidak miring) dan lebih kecil dari aslinya (maks. 1600 px).
- Link foto **berhenti bekerja setelah 1 jam**. Coba buka lagi nanti: muncul error dari R2.
- Foto juga muncul di timeline anak (`media` di langkah 4 bagian E).
- Di dashboard Cloudflare R2, bucket `daycare-media` berisi folder `children/<id anak>/`.

Push notification belum bisa diterima karena aplikasi mobile belum mendaftarkan token FCM.

---

## G. Coba aplikasi mobile (Sprint 6)

Butuh data dari bagian C: satu akun **pengasuh** yang punya kelas berisi anak, dan akun **orang tua** anak tersebut.

### 1. Pasang aplikasi di HP Android

Cara termudah: pakai APK yang sudah jadi.

1. Build APK (sekali, dari folder `mobile`):
   ```powershell
   cd D:\Project\daycare-app\mobile
   flutter build apk --debug
   ```
   Hasilnya `mobile\build\app\outputs\flutter-apk\app-debug.apk`.
2. Kirim file itu ke HP (kabel USB, Google Drive, atau WhatsApp ke diri sendiri), buka, lalu izinkan **"Instal aplikasi tidak dikenal"** bila diminta.

Secara bawaan aplikasi memakai backend **Render**. Mau memakai server di komputer sendiri (bagian A)? HP dan komputer harus di Wi-Fi yang sama:

```powershell
ipconfig                      # catat "IPv4 Address", mis. 192.168.1.10
flutter build apk --debug --dart-define=API_BASE_URL=http://192.168.1.10:8080
```

Di emulator Android, alamat komputer adalah `http://10.0.2.2:8080`. Kalau HP tersambung kabel dengan USB debugging aktif, `flutter run --dart-define=...` langsung memasang dan menjalankan aplikasi.

### 2. Skenario pengasuh

Login dengan email dan kata sandi pengasuh. Request pertama ke Render bisa butuh ±1 menit (server bangun dari tidur).

| # | Langkah | Yang seharusnya terjadi |
|---|---|---|
| 1 | Login. | Muncul **Anak Hari Ini**: kartu tiap anak di kelas pengasuh, status *Belum datang*. Anak beralergi bertanda ⚠. |
| 2 | Ketuk kartu anak → **CHECK-IN SEKARANG**. | Muncul pesan *"✅ … check-in 08.15"*; status kartu jadi *Hadir sejak …*. |
| 3 | Ketuk kartu lagi → **Makan** → pilih porsi. | Tersimpan langsung, tanpa mengetik. Pesan memiliki tombol **BATALKAN** dan **hilang sendiri setelah ±4 detik**. |
| 4 | Coba **BATALKAN** pada pesan berikutnya (sebelum pesannya hilang). | Aktivitas itu terhapus. |
| 5 | **Tidur**, tunggu sebentar, lalu ketuk kartu → **Bangun**. | Kartu menampilkan *Tidur sejak …*; setelah bangun muncul lama tidurnya. |
| 6 | **Toilet** dan **Main** → pilih salah satu chip. | Tercatat dengan pesan konfirmasi. |
| 7 | **Kesehatan** → *Suhu*, atur angka, **SIMPAN & KIRIM**. Coba juga *Cedera* tanpa keterangan. | Suhu tersimpan. *Cedera* tidak bisa disimpan sebelum keterangan diisi. |
| 8 | **Foto** → izinkan kamera → ambil foto. | Muncul *"📷 Foto … akan dikirim"*. Butuh R2 aktif di server (bagian F). |
| 9 | **Timeline**. | Semua catatan hari itu urut waktu, foto tampil di atas. Geser satu aktivitas ke kiri → konfirmasi → terhapus. Panah ‹ › berpindah hari. |
| 10 | **Check-out** → pilih penjemput (mis. *Ibu*) atau tulis nama lain. | Status kartu jadi *Pulang …*. |

Ikon di kanan atas menunjukkan status sinkron: angka merah = jumlah data yang belum terkirim. Tarik layar ke bawah untuk sinkron manual.

### 3. Skenario mode offline (paling penting)

| # | Langkah | Yang seharusnya terjadi |
|---|---|---|
| 1 | Nyalakan **mode pesawat**. | Muncul pita *"Offline · data terakhir ditampilkan"*. Daftar anak tetap tampil. |
| 2 | Catat beberapa aktivitas (makan, toilet) dan check-in anak lain. | Semua langsung tampil di aplikasi. Pita berubah jadi *"Offline · N data tersimpan di HP, dikirim saat online"*; ikon sinkron berangka. |
| 3 | Tutup aplikasi sepenuhnya, lalu buka lagi (masih offline). | Data tadi masih ada, tidak hilang. |
| 4 | Matikan mode pesawat. | Dalam beberapa detik angka hilang dan pita lenyap. |
| 5 | Cek di HP orang tua atau lewat timeline API (bagian E langkah 4). | Semua aktivitas tadi ada, dengan jam saat dicatat (bukan jam saat terkirim). |
| 6 | Coba **Keluar** saat masih ada data belum terkirim. | Muncul peringatan merah bahwa data akan **HILANG**. Pilih *Batal*. |
| 7 | Masih offline: buka **Timeline**, geser satu aktivitas → **Hapus**. Ketuk **LIHAT** di pita. | Layar *Data belum terkirim* menampilkan *"Hapus … · nama anak"*. |
| 8 | Ketuk **BATALKAN HAPUS**, kembali, lalu matikan mode pesawat. | Aktivitas tampil lagi dan **tidak** terhapus di server (cek timeline orang tua). |

### 3b. Memulihkan aktivitas yang terhapus (admin web)

| # | Langkah | Yang seharusnya terjadi |
|---|---|---|
| 1 | Hapus satu aktivitas di aplikasi pengasuh (online). | Hilang dari HP pengasuh dan orang tua. |
| 2 | Admin web → menu **Aktivitas terhapus**. | Aktivitas itu ada, dengan jam dicatat, jam dihapus, dan **nama yang menghapus**. Hapusan sebelum fitur ini tercatat *"oleh (tidak tercatat)"*. |
| 3 | Klik **Pulihkan** → OK. | Baris berubah jadi *"✓ Dipulihkan"*. Setelah sinkron (tarik layar ke bawah), aktivitas tampil lagi di HP pengasuh dan orang tua. |

### 4. Skenario orang tua

Keluar, lalu login dengan akun orang tua (boleh di HP lain agar bisa melihat bersamaan).

| # | Langkah | Yang seharusnya terjadi |
|---|---|---|
| 1 | Login. | Muncul **Anak Saya** dengan status hari ini (*Di daycare sejak …* / *Sudah dijemput …*). Tidak ada tombol pencatatan. |
| 2 | Ketuk nama anak. | Timeline sama dengan yang dicatat pengasuh, termasuk nama pengasuh. Tidak bisa geser untuk menghapus. |
| 3 | Pengasuh mencatat aktivitas baru di HP-nya, lalu orang tua tarik layar ke bawah. | Aktivitas baru muncul (otomatis juga dalam ±1 menit). |

Uji keamanannya:
- Login dengan **akun admin** → ditolak.
- Admin **menonaktifkan** pengasuh di admin web → dalam ±1 menit aplikasi pengasuh kembali ke layar login.
- Orang tua hanya melihat anaknya sendiri, bukan anak lain di kelas yang sama.

---

## Jika ada masalah

| Gejala | Solusi |
|---|---|
| Halaman admin tampil polos tanpa warna | Jalankan `npm run css`, lalu refresh browser. |
| `JWT_SECRET must be at least 32 characters` | Isi `JWT_SECRET` yang lebih panjang di `.env` (langkah A.1). |
| `relation "users" does not exist` | Migration belum dijalankan (langkah A.2). |
| Login admin selalu gagal | Pastikan akun dibuat dengan `-role admin`. Setelah 10× gagal, tunggu 15 menit. |
| Tombol tidak bereaksi / muncul alert "Terjadi kesalahan" | Sesi mungkin habis (12 jam). Muat ulang halaman lalu login lagi. |
| `go: command not found` | Tutup lalu buka lagi PowerShell/VS Code. |
| Aplikasi: *"Tidak ada koneksi ke server"* padahal internet aktif | Server lokal: pastikan HP satu Wi-Fi dengan komputer, alamat IP benar, dan Windows Firewall mengizinkan port 8080. Render: tunggu ±1 menit lalu tarik layar ke bawah. |
| Aplikasi: daftar anak kosong | Pengasuh belum ditugaskan ke kelas, atau kelas belum berisi anak (bagian C). Tarik ke bawah setelah memperbaiki. |
| Aplikasi: pita merah *"N data ditolak server"* | Data tidak lolos validasi server (mis. anak sudah dipindah kelas). Data lain tetap terkirim. Ketuk **LIHAT** untuk melihat datanya; hapusan yang tidak diinginkan bisa dibatalkan, sisanya dikirim ulang dengan **Kirim ulang yang ditolak**. Laporkan ke pengembang bila berulang. |
| Aktivitas hilang padahal tidak dihapus | Admin web → **Aktivitas terhapus**: lihat siapa yang menghapus dan kapan, lalu **Pulihkan**. |
| Aplikasi: *"Sesi berakhir. N data belum terkirim masih tersimpan di HP ini"* | Akun dinonaktifkan atau sesinya dicabut. Data tidak hilang: aktifkan lagi akunnya, lalu masuk dengan akun **yang sama** agar data terkirim. Masuk dengan akun lain akan menghapusnya. |
| Aplikasi: foto tidak pernah muncul | R2 belum dikonfigurasi di server (bagian F). Foto tetap antre di HP. |
