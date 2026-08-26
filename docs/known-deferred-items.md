# Intentionally deferred external dependencies

These are not hidden placeholders; they require external platform/account setup outside repository code.

- Firebase Storage uploads: deferred until the Firebase plan supports Storage for this project.
- Google Play subscription activation: requires creating and activating the two products in Play Console.
- Store purchase runtime validation: requires a Play testing-track installation and tester account.
- Release APK/AAB generation on GitHub: requires repository secrets for Firebase configuration and the release/upload keystore.
- Server-side subscription receipt verification: recommended before a large-scale production rollout; current client integration activates entitlements from store-confirmed purchase events.
