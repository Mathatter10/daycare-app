# AI Agent & Developer Guidelines (AGENTS.md)

## System Context
You are acting as a Senior Full-Stack Engineer developing a Daycare Management System. The project uses a unified Go backend that serves both a JSON API for mobile apps and an HTMX-powered web interface for admins.

## Tech Stack Rules
These choices are fixed. Do not substitute alternatives.
1.  **Backend:** Go with `gofiber/fiber` **v3** for routing (handlers take `fiber.Ctx`). No Gin, Echo, Chi or `net/http` routers.
2.  **Database access:** `sqlc` (pgx/v5 driver). Write SQL in `backend-go/db/queries/`, run `sqlc generate`, use the generated code in `internal/repository/`. No GORM or other ORMs.
3.  **Admin PWA:** HTML rendered with `a-h/templ` components (`internal/views/*.templ`, run `go tool templ generate`), enhanced with HTMX and Tailwind CSS. No `html/template`, React or Vue.
4.  **Mobile App:** Flutter, in `mobile/`. **One app for both roles**: the UI switches on the logged-in user's role (caregiver: fast logging; parent: timeline). Use `camerawesome` for photo/video capture and **`isar_community`** (the maintained Isar fork, same API) as the local database for offline-first capabilities. Writes go to Isar plus an outbox first, then sync to the API (`docs/API.md`, "Sinkronisasi offline-first").
5.  **Database:** PostgreSQL (Supabase/Neon). Schema changes go in goose migrations in `backend-go/migrations/`.

## Coding Guidelines
*   **Single Source of Truth:** Use UUIDs for all primary keys in PostgreSQL.
*   **HTMX Patterns:** When writing Go handlers for the admin web, return HTML partials (snippets), NOT full HTML pages, unless handling a direct page load. Use `hx-swap` and `hx-target` efficiently.
*   **API Design:** API endpoints for mobile (`/api/v1/...`) must return strict JSON and use JWT authentication. 
*   **Mobile Mobile-First:** Caregiver UI must follow the "Thumb-Zone" rule. Minimize keyboard usage; favor large tap targets, chips, and bottom sheets.
*   **Concurrency:** Use Go routines (`goroutines`) for background tasks like image compression or triggering Push Notifications to avoid blocking the HTTP response.