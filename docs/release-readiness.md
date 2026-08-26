# Home OS Release Readiness

## Current product contract

### Authentication
- Google sign-in and Anonymous guest access.
- Guest accounts can be linked to Google while preserving the Firebase UID and Home OS data.
- Logout and destructive account deletion require explicit confirmation.
- Account deletion removes the user's Home OS Firestore data before deleting Firebase Auth.

### Data
- Production screens use repository-backed Firebase data paths under `users/{uid}`.
- Firestore rules isolate user data by authenticated UID.
- Firebase Storage remains intentionally deferred; document metadata is supported without pretending file upload is active.

### Subscription tiers
- Free: 1 home, 10 assets, 10 active reminders, 10 maintenance records, 5 warranties, 10 documents, 3 providers.
- Home OS Unlimited: USD 20/month, unlimited practical use for one home.
- Home OS Multi-Home: USD 35/month, Unlimited features plus multiple homes.
- Existing data is never deleted when a free limit is reached; only new additions are gated.
- Google Play / App Store purchase state is the client-side entitlement source.
- Android Unlimited -> Multi-Home uses the official subscription replacement flow to avoid double billing.

### Store product IDs
- `home_os_unlimited_monthly`
- `home_os_multi_home_monthly`

The products must be created and activated in Google Play Console / App Store Connect before purchases can succeed. Store-localized prices are shown when product metadata is available.

### UX quality
- Calm Premium light/dark design system.
- Arabic/English, RTL/LTR.
- Empty/loading/error states.
- Destructive confirmations and Undo where appropriate.
- Raw Flutter/Firebase errors are not intentionally exposed to end users.

### CI
GitHub Actions validates `flutter analyze` and `flutter test` on changes. Separate workflows are prepared for debug APK and signed release APK/AAB artifacts. Release signing secrets and Firebase configuration must never be committed to the public repository.

## Manual runtime checks still required before production publication
1. Install a fresh APK/AAB build and verify Anonymous + Google Firebase runtime flows on a real Android device.
2. Verify Firestore persistence and account data isolation with two distinct users.
3. Create the two subscription products in Google Play Console and test purchase, restore, and Unlimited -> Multi-Home upgrade from a Play testing track.
4. Verify release SHA fingerprints in Firebase for Google Sign-In.
5. Complete Google Play privacy/data-safety and subscription disclosures before production rollout.
