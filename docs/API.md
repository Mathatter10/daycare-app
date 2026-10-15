# Referensi API Mobile

Daftar isi: autentikasi · aturan akses · anak & timeline · absensi · aktivitas · sinkronisasi.

Base URL: `https://<host>/api/v1`. Semua request dan response memakai JSON.
Error selalu berbentuk `{"error": "<pesan>"}`.

## Alur autentikasi

```text
login ──> access_token (24 jam) + refresh_token (30 hari)
   │
   ├─ setiap request: header  Authorization: Bearer <access_token>
   │
   ├─ dapat 401 / access_token kedaluwarsa ──> POST /auth/refresh
   │      └─ dapat pasangan token BARU. Refresh token lama langsung tidak berlaku.
   │
   └─ logout ──> POST /auth/logout, lalu hapus kedua token dari HP
```

Aturan untuk aplikasi Flutter:
- Simpan token di penyimpanan aman (`flutter_secure_storage`), **bukan** di Isar atau SharedPreferences.
- Setiap refresh **selalu** simpan `refresh_token` yang baru. Memakai refresh token lama dianggap pencurian: server mencabut **semua** sesi user itu dan user harus login ulang.
- Jangan refresh dua kali secara paralel (mis. dua request gagal bersamaan). Antrekan menjadi satu refresh.

---

## `POST /auth/login`

Hanya untuk role `caregiver` dan `parent`. Admin memakai web.

Request:
```json
{ "email": "ortu@contoh.id", "password": "rahasia-ortu-123" }
```

Response `200`:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "Bearer",
  "expires_at": "2026-10-16T05:14:21Z",
  "refresh_token": "q2V0...",
  "refresh_expires_at": "2026-11-14T05:14:21Z",
  "user": {
    "id": "fccf8a3d-5183-4649-82d0-f444b5890012",
    "email": "ortu@contoh.id",
    "full_name": "Pak Ortu",
    "phone": null,
    "role": "parent"
  }
}
```

| Status | Arti |
|---|---|
| `400` | Body bukan JSON / email atau password kosong |
| `401` | Email atau password salah, atau akun nonaktif |
| `403` | Akun admin (tidak boleh login di mobile) |
| `429` | 10× gagal untuk email ini dalam 15 menit |

## `POST /auth/refresh`

Request: `{ "refresh_token": "q2V0..." }`
Response `200`: sama persis dengan login (pasangan token baru + `user`).
`401` = token tidak valid, kedaluwarsa, sudah dipakai, atau akun nonaktif → arahkan ke layar login.

## `POST /auth/logout`

Request: `{ "refresh_token": "q2V0..." }`
Response `204` (tanpa body), walaupun token tidak dikenal.

## `GET /me`

Header: `Authorization: Bearer <access_token>`
Response `200`: objek `user` seperti di atas.
`401` = token tidak ada, tidak valid, kedaluwarsa, atau akun sudah dinonaktifkan admin.

---

## Aturan akses

| Role | Boleh |
|---|---|
| `caregiver` | Melihat dan mencatat untuk anak **aktif** di kelas yang ditugaskan kepadanya |
| `parent` | Hanya **membaca** data anak yang terhubung ke akunnya |

Anak di luar akses user selalu dijawab `404 child not found` (bukan 403), supaya ID anak tidak bisa ditebak. Endpoint tulis (absensi, aktivitas) memberi `403` untuk orang tua.

Semua waktu memakai format RFC 3339 (mis. `2026-10-15T08:30:00+07:00`). "Hari" dihitung dalam zona waktu daycare (`Asia/Jakarta`).

## `GET /children`

Daftar anak yang boleh dilihat user, beserta status absensi hari ini.

```json
{
  "children": [{
    "id": "…", "full_name": "Citra", "nickname": null,
    "date_of_birth": "2024-01-01", "gender": "female",
    "class_id": "…", "class_name": "Kelas X",
    "allergies": "Kacang", "medical_notes": null,
    "updated_at": "…",
    "today": { "check_in_at": "2026-10-15T07:45:00+07:00", "check_out_at": null }
  }]
}
```

## `GET /children/{id}/timeline?date=YYYY-MM-DD`

Absensi dan aktivitas satu hari (default: hari ini). Aktivitas terbaru di atas; yang sudah dihapus tidak ikut.

```json
{
  "date": "2026-10-15",
  "attendance": { "id": "…", "child_id": "…", "date": "2026-10-15",
                  "check_in_at": "…", "check_in_by": "…",
                  "check_out_at": null, "check_out_by": null, "picked_up_by": null, "updated_at": "…" },
  "activities": [ /* objek aktivitas, lihat di bawah */ ]
}
```
`attendance` bernilai `null` jika anak belum check-in hari itu.

## Absensi (khusus `caregiver`)

### `POST /attendance/check-in`
```json
{ "child_id": "…", "at": "2026-10-15T07:45:00+07:00" }
```
`at` opsional (default: waktu server). **Kirim `at` dari HP** untuk data yang diantrekan saat offline. Mengirim ulang aman: yang disimpan adalah waktu check-in **paling awal**. Response: objek `attendance`.

### `POST /attendance/check-out`
```json
{ "child_id": "…", "at": "…", "picked_up_by": "Nenek" }
```
`409` jika anak belum check-in pada hari `at`; `422` jika `at` lebih awal dari check-in.

## Aktivitas (khusus `caregiver`)

### `PUT /activities/{id}`

**`id` dibuat di HP (UUID v4)** saat aktivitas dicatat, lalu dipakai untuk simpan pertama maupun perubahan. Mengirim ulang request yang sama aman (idempotent).

```json
{
  "child_id": "…",
  "type": "eat",
  "started_at": "2026-10-15T09:00:00+07:00",
  "ended_at": null,
  "details": { "portion": "half", "menu": "Bubur ayam" },
  "notes": "Lahap"
}
```

| `type` | `details` | `ended_at` |
|---|---|---|
| `eat` | `portion` (wajib): `all` `most` `half` `little` `none`; `menu` (opsional) | tidak boleh |
| `sleep` | `{}` | opsional; kosong = masih tidur, isi saat bangun |
| `toilet` | `kind` (wajib): `wet` `dirty` `both` `dry` | tidak boleh |
| `play` | `activity` (opsional) | opsional |
| `medical` | `kind` (wajib): `temperature` `medicine` `injury` `other`; `temperature_c` (34–43, wajib untuk `temperature`); `medicine` (wajib untuk `medicine`) | tidak boleh |

Field `details` yang tidak dikenal ditolak. Waktu tidak boleh lebih dari 5 menit di masa depan atau lebih tua dari 7 hari.

Response `200`: objek aktivitas:
```json
{
  "id": "…", "child_id": "…", "caregiver_id": "…", "caregiver_name": "Ani Pengasuh",
  "type": "eat", "started_at": "…", "ended_at": null,
  "details": { "menu": "Bubur ayam", "portion": "half" }, "notes": "Lahap",
  "created_at": "…", "updated_at": "…", "deleted_at": null
}
```

| Status | Arti |
|---|---|
| `409 activity was deleted` | Aktivitas sudah dihapus; jangan kirim ulang, hapus dari antrean |
| `409 activity id is already used for another child` | Bug di aplikasi (UUID dipakai ulang) |
| `422` | Validasi gagal; pesan menjelaskan field yang salah |

### `DELETE /activities/{id}`
`204`. Aman diulang, termasuk untuk ID yang belum pernah tersimpan di server.

## Sinkronisasi offline-first: `GET /sync`

```
GET /sync?activities_cursor=<cursor>&attendance_cursor=<cursor>
```
Kosongkan cursor untuk sinkron pertama (mengambil data 14 hari terakhir).

```json
{
  "server_time": "…",
  "children":   [ /* daftar LENGKAP anak yang boleh diakses saat ini */ ],
  "activities": { "items": [ … ], "next_cursor": "…", "has_more": false },
  "attendance": { "items": [ … ], "next_cursor": "…", "has_more": false }
}
```

Algoritma di aplikasi (Isar):
1. Kirim dulu semua antrean lokal (`PUT`/`DELETE`/check-in/check-out) yang belum terkirim.
2. Panggil `/sync` dengan cursor tersimpan.
3. **Upsert** setiap item berdasarkan `id`. Item dengan `deleted_at` ≠ null → hapus dari Isar.
4. Hapus dari Isar anak yang **tidak ada** di `children` (beserta datanya). Ini terjadi jika anak dipindah kelas atau dinonaktifkan.
5. Simpan `next_cursor` masing-masing. Ulangi langkah 2 selama `has_more` bernilai `true`.

Server sengaja mengirim ulang perubahan ±30 detik terakhir di setiap sync agar tidak ada data yang terlewat. Karena itu langkah 3 harus upsert, bukan insert.

---

## Health check

`GET /api/health` (tanpa `/v1`, tanpa auth) → `200 {"status":"OK","database":"up",...}` atau `503` jika database tidak terjangkau.
