### 5. SECURITY.md (Security Protocols)
Sangat penting untuk memastikan AI tidak menulis kode yang rentan, terutama menyangkut data privasi anak-anak.

```markdown
# Security & Privacy Guidelines

## 1. Authentication
*   **Mobile API:** Use JWT (JSON Web Tokens). Tokens must have a short expiration (e.g., 24 hours) with a secure refresh token mechanism.
*   **Admin Web (HTMX):** Use HttpOnly, Secure Cookies for session management. Do not store JWTs in LocalStorage for the web admin.

## 2. Authorization (RBAC - Role-Based Access Control)
Middleware must strictly enforce roles:
*   `Role = Admin`: Can access HTMX endpoints, modify master data.
*   `Role = Caregiver`: Can only POST activities and attendance for children in their assigned `class_id`.
*   `Role = Parent`: Can only GET activities and profiles where `children.parent_id == user.id`. Strict isolation is required to prevent parents from seeing other children's timelines.

## 3. Data Privacy (PII)
*   **Media URLs:** Uploaded photos should ideally use Signed URLs that expire, rather than fully public URLs, to protect children's photos from unauthorized scraping.
*   **Passwords:** Must be hashed using `bcrypt` (cost >= 10). Never log passwords or sensitive PII in application logs.