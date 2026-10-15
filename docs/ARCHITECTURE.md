# System Architecture

## 1. High-Level Architecture
The system follows a monolith backend approach serving two distinct client types:

```text
[ Mobile App (Flutter/RN) ] ---> JSON API (JWT) -------\
                                                        +--> [ Go Backend ] ---> [ PostgreSQL ]
[ Web Admin (Browser/PWA) ] ---> HTTP/HTML (Cookies) ---/       |
                                                                +--> [ Cloud Storage / S3 ]