# Design System & UI/UX Guidelines

## 1. Color Palette
*   **Primary Brand:** `#4F46E5` (Indigo) - Used for primary actions and parent app header.
*   **Secondary/Accent:** `#10B981` (Emerald) - Used for Check-In, Submit buttons, and success states.
*   **Background:** `#F9FAFB` (Gray 50) - App background to keep it clean and spacious.
*   **Activity Colors (Tags/Icons):**
    *   🍼 Eat: `#F59E0B` (Amber)
    *   😴 Sleep: `#3B82F6` (Blue)
    *   🧻 Toilet: `#8B5CF6` (Purple)
    *   🎨 Play: `#EC4899` (Pink)
    *   💊 Medical/Alert: `#EF4444` (Red)

## 2. Typography
*   **Font Family:** Inter or Poppins (Clean, readable sans-serif).
*   **Hierarchy:**
    *   H1: 24px Bold (Screen Titles)
    *   H2: 18px SemiBold (Card Titles, Names)
    *   Body: 14px Regular (Descriptions, Timestamps)

## 3. UI Components (Mobile)
*   **Thumb-Zone Actions:** All primary CTA buttons (e.g., "SIMPAN & KIRIM") must be full-width, at least 56px height, and docked to the bottom of the screen.
*   **Activity Bottom Sheet:** Used for inputting daily logs. Must slide up over the current screen, dimming the background (opacity 50%).
*   **Cards:** Children profiles use a 2-column grid. White background, 8px border-radius, soft shadow (`box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1)`).

## 4. UI Components (Web Admin)
*   **Data Tables:** Clean tables with sticky headers. Actions (Edit/Delete) should trigger HTMX requests to swap rows dynamically without reloading the page.