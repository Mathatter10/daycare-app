# Panduan Uji Coba (Sprint 1–4)

Fitur yang bisa dicoba sekarang:

| Bagian | Bisa dicoba |
|---|---|
| **Admin web** (`/admin`) | Login, dashboard, kelola kelas, pengasuh, orang tua, dan anak |
| **API mobile** (`/api/v1`) | Login, daftar anak, check-in/out, catat aktivitas, timeline orang tua, sync |

Belum ada: aplikasi mobile Flutter, foto/video, dan push notification. API mobile untuk sementara dicoba lewat PowerShell.

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

## Jika ada masalah

| Gejala | Solusi |
|---|---|
| Halaman admin tampil polos tanpa warna | Jalankan `npm run css`, lalu refresh browser. |
| `JWT_SECRET must be at least 32 characters` | Isi `JWT_SECRET` yang lebih panjang di `.env` (langkah A.1). |
| `relation "users" does not exist` | Migration belum dijalankan (langkah A.2). |
| Login admin selalu gagal | Pastikan akun dibuat dengan `-role admin`. Setelah 10× gagal, tunggu 15 menit. |
| Tombol tidak bereaksi / muncul alert "Terjadi kesalahan" | Sesi mungkin habis (12 jam). Muat ulang halaman lalu login lagi. |
| `go: command not found` | Tutup lalu buka lagi PowerShell/VS Code. |
