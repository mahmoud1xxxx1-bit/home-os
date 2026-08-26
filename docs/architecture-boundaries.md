# Production architecture boundaries

- UI must depend on repositories/providers, not directly on local mock storage.
- Firebase production data is isolated by authenticated UID.
- Local repositories remain test/development substitutes and must not become a second production source of truth.
- Subscription feature gates are centralized under `core/subscriptions`.
- Store billing is responsible for purchase state; feature screens must never directly grant paid tiers.
- Release signing and Firebase configuration remain outside source control.
