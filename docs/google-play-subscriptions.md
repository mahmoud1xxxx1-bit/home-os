# Google Play subscription setup

Create two monthly subscription products in Google Play Console using these exact product IDs:

- `home_os_unlimited_monthly` — target price USD 20/month (Google Play localizes supported market prices).
- `home_os_multi_home_monthly` — target price USD 35/month.

Recommended behavior:
- Free and Unlimited support one home.
- Multi-Home supports multiple homes.
- Unlimited -> Multi-Home is treated as an upgrade/replacement on Android rather than a second parallel subscription.
- Test purchases only from a Google Play internal/closed testing installation signed with the correct Play/Firebase configuration.
- Verify purchase, cancellation, restore, renewal, and plan upgrade behavior before production.

The app does not fake a paid entitlement when products are missing or the store is unavailable.
