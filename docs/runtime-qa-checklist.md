# Real-device runtime QA checklist

Before production release, validate on a real Android device installed from the intended testing channel.

## Authentication and Firebase
- Anonymous sign-in creates a Firebase Auth user.
- Home + asset creation appear under the same `users/{uid}` Firestore namespace.
- Data remains after a force-close and restart.
- Guest -> Google linking preserves the UID and existing data.
- Logging into a different account never exposes the previous user's data.
- Logout does not delete data.
- Delete account removes Home OS cloud data and the Firebase Auth user.

## Core flows
- First-home onboarding remains keyboard safe with no overflow.
- Add/edit/archive/restore asset flows work without red screens.
- Maintenance and warranty records remain linked to the intended asset.
- Documents/expenses/providers/services/family/search/settings open and behave as described.
- Arabic/English and light/dark modes remain usable across all primary screens.

## Subscription flows
- Free limits block only new additions and never delete existing records.
- Unlimited allows unrestricted practical use but still blocks a second home.
- Multi-Home allows a second and subsequent homes.
- Google Play purchase and restore activate only store-confirmed entitlements.
- Unlimited -> Multi-Home does not create an unintended second parallel Android subscription.
