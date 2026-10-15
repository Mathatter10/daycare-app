# Panduan Menjalankan & Deploy Backend

Panduan ini untuk backend Go di folder `backend-go/`.

> **Status saat ini (Sprint 4):** admin web di `/admin` (kelas, anak, pengasuh, orang tua) dan API mobile lengkap untuk login, absensi, aktivitas harian, timeline orang tua, dan sinkronisasi offline (lihat [API.md](API.md)). Foto/video dan push notification **belum ada**.

## Alur awal memakai admin web

Setelah deploy dan login sebagai admin (langkah 6), isi data dengan urutan ini:

1. **Pengasuh** → *Tambah pengasuh*. Kata sandi sementara muncul **sekali**; catat dan berikan ke pengasuh untuk login di aplikasi mobile.
2. **Kelas** → *Tambah kelas*, centang pengasuh yang bertanggung jawab.
3. **Orang Tua** → *Tambah orang tua* (kata sandi sementara juga muncul sekali).
4. **Anak** → *Tambah anak*, pilih kelas, isi **email orang tua** dari langkah 3.

Lupa kata sandi? Klik **Reset sandi** di baris akun itu. **Nonaktifkan** akun membuat user langsung keluar dari aplikasi. Data anak tidak bisa dihapus, hanya dinonaktifkan, supaya riwayatnya tetap tersimpan.

Arsitektur deploy yang disarankan untuk MVP:

```text
[ HP / Browser ] --HTTPS--> [ Render (container Docker backend-go) ] ---> [ Neon (PostgreSQL) ]
```

---

## 1. Persiapan (sekali saja)

| Kebutuhan | Keterangan |
|---|---|
| Go 1.26+ | Sudah terpasang di `C:\Program Files\Go`. Cek: `go version` |
| Node.js | Hanya untuk build CSS Tailwind. Cek: `node --version` |
| Git + akun GitHub | Render mengambil kode dari GitHub |
| Akun [Neon](https://neon.tech) | Database PostgreSQL gratis |
| Akun [Render](https://render.com) | Hosting backend gratis |

`templ`, `goose`, dan `sqlc` sudah dipasang sebagai *tool* di `go.mod`, jadi tidak perlu diinstal terpisah. Jalankan dengan `go tool templ ...`, `go tool goose ...`, dan `go tool sqlc ...`.

> Jika terminal bilang `go: command not found`, tutup lalu buka lagi terminal/VS Code supaya PATH ter-update.

---

## 2. Buat database di Neon

1. Login ke Neon, klik **New Project**. Pilih region terdekat (mis. **AWS Asia Pacific (Singapore)**).
2. Buka **Connection Details**. Matikan opsi **Connection pooling** supaya dapat alamat *direct* (host **tanpa** `-pooler`).
3. Salin connection string-nya, bentuknya seperti:
   ```
   postgresql://neondb_owner:PASSWORD@ep-xxxx.ap-southeast-1.aws.neon.tech/neondb?sslmode=require
   ```
   Pastikan ada `?sslmode=require` di akhir.

> Tips: buat dua *branch* di Neon, `main` untuk produksi dan `dev` untuk development, supaya data uji tidak tercampur.

---

## 3. Jalankan di komputer sendiri (lokal)

Dari folder `backend-go/`:

1. **Siapkan file `.env`.** Salin dari contoh lalu isi:
   ```bash
   cp .env.example .env
   ```
   - `DATABASE_URL` = connection string Neon (branch `dev`) dari langkah 2.
   - `JWT_SECRET` = string acak minimal 32 karakter (**wajib**, server tidak mau jalan tanpanya). Buat dengan (di Git Bash):
     ```bash
     openssl rand -base64 48
     ```
   File `.env` sudah masuk `.gitignore`, **jangan pernah di-commit**.

2. **Buat tabel di database (migration):**
   ```bash
   go tool goose -dir migrations postgres "<DATABASE_URL>" up
   go tool goose -dir migrations postgres "<DATABASE_URL>" status   # cek: 001 = Applied
   ```

3. **Buat akun admin pertama:**
   ```bash
   go run ./cmd/createuser -email admin@daycare.id -name "Nama Admin" -role admin
   ```
   Kata sandi akan ditanyakan (min. 8 karakter). Jalankan di **PowerShell** agar ketikan kata sandi tersembunyi; di Git Bash ketikan akan terlihat.
   Untuk akun uji pengasuh/orang tua, ganti `-role caregiver` atau `-role parent`.

4. **Build CSS dan jalankan server:**
   ```bash
   npm install              # sekali saja
   npm run css              # ulangi setiap ada perubahan class Tailwind di file .templ
   go tool templ generate   # ulangi setiap ada perubahan file .templ
   go run ./cmd/server
   ```
   Buka http://localhost:8080/admin lalu login dengan akun admin dari langkah 3.

5. **Cek health di terminal lain:**
   ```bash
   curl http://localhost:8080/api/health
   ```
   Hasil yang benar:
   ```json
   {"database":"up","status":"OK","time":"2026-10-15T02:00:00Z"}
   ```
   Jika `"database":"down"` (HTTP 503), periksa `DATABASE_URL`.

---

## 4. Upload kode ke GitHub

Render butuh kode ada di GitHub. Dari root repo `daycare-app/`:

```bash
git add .
git commit -m "Sprint 1: backend foundation"
git branch -M main
git remote add origin https://github.com/Mathatter10/daycare-app.git
git push -u origin main
```

Sebelum push, pastikan `git status` **tidak** menampilkan file `.env`.

---

## 5. Migration ke database produksi

Jalankan dari komputer sendiri ke branch `main` Neon:

```bash
cd backend-go
go tool goose -dir migrations postgres "<DATABASE_URL_PRODUKSI>" up
```

Sejak Sprint 4, server **menjalankan migration baru secara otomatis** setiap kali start (`AUTO_MIGRATE=true`, default). Perintah `goose` di atas tetap berguna untuk mengecek status (`... status`) atau jika `AUTO_MIGRATE=false`.

Buat akun admin produksi (sekali saja), juga dari komputer sendiri:

```bash
go run ./cmd/createuser -database-url "<DATABASE_URL_PRODUKSI>" -email admin@daycare.id -name "Nama Admin" -role admin
```

---

## 6. Deploy ke Render

1. Di dashboard Render: **New → Web Service** → hubungkan akun GitHub → pilih repo `daycare-app`.
2. Isi pengaturan:

   | Field | Nilai |
   |---|---|
   | Name | `daycare-api` |
   | Region | Singapore |
   | Language / Runtime | **Docker** |
   | Root Directory | `backend-go` |
   | Dockerfile Path | `./Dockerfile` |
   | Instance Type | Free (untuk uji coba) |
   | Health Check Path | `/api/health` |

3. Di bagian **Environment Variables**, tambahkan:

   | Key | Value |
   |---|---|
   | `APP_ENV` | `production` |
   | `DATABASE_URL` | connection string Neon branch `main` |
   | `JWT_SECRET` | string acak baru (min. 32 karakter, **beda** dari lokal) |

   `SESSION_SECRET` dari Sprint 1 **tidak dipakai lagi** dan boleh dihapus. Opsional: `SESSION_TTL` (default `12h`, lama login admin web).

   `PORT` tidak perlu diisi, Render mengaturnya otomatis.

4. Klik **Create Web Service**. Tunggu build selesai (beberapa menit pertama kali).
5. Cek di browser atau terminal:
   ```bash
   curl https://daycare-api.onrender.com/api/health
   ```
   Lalu buka `https://daycare-api.onrender.com/admin` dan login dengan akun admin produksi.

Setiap `git push` ke branch `main` akan otomatis memicu deploy ulang.

> **Catatan paket gratis Render:** server "tidur" setelah 15 menit tanpa request, sehingga request pertama bisa lambat ±1 menit. Untuk dipakai daycare sungguhan, gunakan paket berbayar (Starter).

---

## 7. Alternatif: VPS sendiri (Docker)

Jika memakai VPS (mis. DigitalOcean, IDCloudHost, Biznet Gio) yang sudah terpasang Docker:

```bash
git clone https://github.com/Mathatter10/daycare-app.git
cd daycare-app/backend-go
docker build -t daycare-api .

# file .env.production berisi APP_ENV, DATABASE_URL, JWT_SECRET
docker run --rm --env-file .env.production --entrypoint /app/goose daycare-api \
  -dir /app/migrations postgres "<DATABASE_URL_PRODUKSI>" up

docker run -d --name daycare-api --restart unless-stopped \
  --env-file .env.production -p 127.0.0.1:8080:8080 daycare-api
```

Lalu pasang reverse proxy dengan HTTPS (mis. **Caddy**: `reverse_proxy 127.0.0.1:8080`) di depan port 8080. **Wajib HTTPS**, karena cookie sesi admin memakai flag `Secure`.

---

## 8. Masalah yang sering terjadi

| Gejala | Penyebab & solusi |
|---|---|
| `DATABASE_URL is required` | `.env` tidak ada / env var belum diisi di Render. |
| `JWT_SECRET must be at least 32 characters` | Secret kosong/terlalu pendek. Buat dengan `openssl rand -base64 48`. |
| Halaman admin tampil tanpa gaya (polos) | `static/css/output.css` belum dibuat. Jalankan `npm run css`. |
| Login admin gagal terus padahal benar | Akun bukan role `admin`, atau sudah 10× salah dalam 15 menit (tunggu). |
| `429 too many login attempts` | 10 kali gagal login untuk email itu dalam 15 menit. Tunggu 15 menit. |
| `ping database: ... connection refused` | Alamat database salah, atau Postgres lokal tidak berjalan. |
| Error `prepared statement ... already exists` | Memakai alamat *pooler*. Gunakan alamat direct (tanpa `-pooler`). |
| Health check `"database":"down"` | Database Neon sedang *suspend* atau kredensial berubah. Coba lagi setelah beberapa detik. |
| Server lambat di request pertama | Render free tier sedang bangun dari tidur (lihat langkah 6). |
