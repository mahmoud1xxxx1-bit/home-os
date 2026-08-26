# Home OS Product Polish Contract

This document is a permanent quality contract for future Home OS development.

- No raw Flutter, Firebase, billing, or platform exceptions are shown to users.
- Destructive actions use clear confirmation; reversible archive actions prefer Undo.
- Every primary page explains its purpose when needed and has meaningful empty/loading/error states.
- Navigation keeps Settings, Help, Profile, Search, and subscription management discoverable.
- Buttons must perform real actions; deferred capabilities are clearly labeled rather than simulated.
- Light and Dark themes use a calm premium visual hierarchy, not flat black/white surfaces.
- Icons, spacing, radii, cards, buttons, dialogs, sheets, status colors, and typography remain consistent app-wide.
- Arabic and English receive equal treatment, including RTL/LTR, date/number layout, long text, and keyboard-safe forms.
- Status colors are consistent: success/healthy, attention/soon, destructive/expired, informational.
- Forms show essentials first and optional details progressively; user input is validated and protected from duplicate submissions.
- Account, privacy, subscription, logout, and deletion consequences are explained in human language.
- Accessibility includes adequate touch targets, contrast, scalable layouts, and no meaning conveyed by color alone.
- Mobile is the primary experience; tablet/desktop adapt rather than merely stretch.
- Production releases require CI, real-device runtime QA, Firebase isolation QA, and store purchase QA.
