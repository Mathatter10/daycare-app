# 🍼 Daycare Management Platform (MVP)

A unified system to manage daycare operations and provide real-time activity tracking for parents, built with Go (Fiber, sqlc, templ), HTMX, PostgreSQL, and Flutter.

## Features
*   **Caregiver Mobile App:** Lightning-fast logging of meals, naps, and toilet breaks with native camera integration.
*   **Parent Mobile App:** Real-time push notifications and activity timeline.
*   **Admin PWA:** HTMX-powered web dashboard for managing classes, children, and staff without writing heavy JS frameworks.

## Prerequisites
*   [Go 1.26+](https://go.dev/)
*   [PostgreSQL](https://www.postgresql.org/) (Local or Supabase)
*   [Flutter](https://flutter.dev/)
*   [sqlc](https://sqlc.dev/) and [goose](https://github.com/pressly/goose)
*   Tailwind CSS CLI (for Admin UI styling)

## Quick Start (Backend)

1. **Clone the repo:**
   ```bash
   git clone [https://github.com/Mathatter10/daycare-app.git](https://github.com/Mathatter10/daycare-app.git)
   cd daycare-app