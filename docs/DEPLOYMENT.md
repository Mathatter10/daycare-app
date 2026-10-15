# Panduan Menjalankan & Deploy Backend

Panduan ini untuk backend Go di folder `backend-go/`.

> **Status saat ini (Sprint 1):** backend baru berisi fondasi: koneksi database, skema tabel, dan endpoint `GET /api/health`. Login, API untuk aplikasi mobile, dan dashboard admin **belum ada**. Setelah deploy, yang bisa dicek baru server hidup dan tersambung ke database.

Arsitektur deploy yang disarankan untuk MVP:

```text
[ HP / Browser ] --HTTPS--> [ Render (container Docker backend-go) ] ---> [ Neon (PostgreSQL) ]
```

---

## 1. Persiapan (sekali saja)

| Kebutuhan | Keterangan |
|---|---|
| Go 1.26+ | Sudah terpasang di `C:\Program Files\Go`. Cek: `go version` |
| Git + akun GitHub | Render mengambil kode dari GitHub |
| Akun [Neon](https://neon.tech) | Database PostgreSQL gratis |
| Akun [Render](https://render.com) | Hosting backend gratis |

`templ` dan `goose` sudah dipasang sebagai *tool* di `go.mod`, jadi tidak perlu diinstal terpisah. Jalankan dengan `go tool templ ...` dan `go tool goose ...`.

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
   - `JWT_SECRET` dan `SESSION_SECRET` = string acak panjang. Buat dengan (di Git Bash):
     ```bash
     openssl rand -base64 48
     ```
   File `.env` sudah masuk `.gitignore`, **jangan pernah di-commit**.

2. **Buat tabel di database (migration):**
   ```bash
   go tool goose -dir migrations postgres "<DATABASE_URL>" up
   go tool goose -dir migrations postgres "<DATABASE_URL>" status   # cek: 001 = Applied
   ```

3. **Jalankan server:**
   ```bash
   go tool templ generate   # hanya perlu jika ada file .templ yang diubah
   go run ./cmd/server
   ```

4. **Cek di terminal lain:**
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

Lakukan ini **setiap kali** ada file migration baru, **sebelum** deploy kode yang membutuhkannya.

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
   | `SESSION_SECRET` | string acak baru (min. 32 karakter) |

   `PORT` tidak perlu diisi, Render mengaturnya otomatis.

4. Klik **Create Web Service**. Tunggu build selesai (beberapa menit pertama kali).
5. Cek di browser atau terminal:
   ```bash
   curl https://daycare-api.onrender.com/api/health
   ```

Setiap `git push` ke branch `main` akan otomatis memicu deploy ulang.

> **Catatan paket gratis Render:** server "tidur" setelah 15 menit tanpa request, sehingga request pertama bisa lambat ±1 menit. Untuk dipakai daycare sungguhan, gunakan paket berbayar (Starter).

---

## 7. Alternatif: VPS sendiri (Docker)

Jika memakai VPS (mis. DigitalOcean, IDCloudHost, Biznet Gio) yang sudah terpasang Docker:

```bash
git clone https://github.com/Mathatter10/daycare-app.git
cd daycare-app/backend-go
docker build -t daycare-api .

# file .env.production berisi APP_ENV, DATABASE_URL, JWT_SECRET, SESSION_SECRET
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
| `JWT_SECRET must be at least 32 characters in production` | Secret terlalu pendek saat `APP_ENV=production`. Buat ulang dengan `openssl rand -base64 48`. |
| `ping database: ... connection refused` | Alamat database salah, atau Postgres lokal tidak berjalan. |
| Error `prepared statement ... already exists` | Memakai alamat *pooler*. Gunakan alamat direct (tanpa `-pooler`). |
| Health check `"database":"down"` | Database Neon sedang *suspend* atau kredensial berubah. Coba lagi setelah beberapa detik. |
| Server lambat di request pertama | Render free tier sedang bangun dari tidur (lihat langkah 6). |
