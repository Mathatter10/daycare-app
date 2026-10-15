# Referensi API Mobile

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

## Health check

`GET /api/health` (tanpa `/v1`, tanpa auth) → `200 {"status":"OK","database":"up",...}` atau `503` jika database tidak terjangkau.
