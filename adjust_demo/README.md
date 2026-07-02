# Nova Store — Flutter Demo App

A modern, **fully offline** Flutter e-commerce demo application built to showcase
a wide variety of realistic user flows, screens, and state changes. It is
intended as a **testing / automation / SDK-integration playground** — not a
production app.

> There is **no backend, no REST API, no Firebase, and no analytics/tracking
> SDKs**. All data is fake and stored locally.

---

## Project Overview

Nova Store looks and feels like a real shopping app: users sign in, browse
products by category, search and filter, manage a cart and wishlist, check out,
and review their orders and profile — all backed by locally-generated fake data
and `SharedPreferences` persistence.

It is a **complete, clickable prototype** built to be a realistic sandbox for
feature testing, UI automation, and (later) attribution/analytics **SDK
integration** — every meaningful user action (login, logout, add-to-cart,
remove, checkout, place-order, wishlist, theme change, …) updates real state
and is an obvious hook point for firing SDK events.

## Features

**Auth & session**
- Animated splash with auto-navigation based on session state.
- Login / Register with full form validation and loading/error states.
- Fake authentication — any valid-looking credentials sign you in; session
  persists across restarts. Logout with confirmation.

**Browsing**
- Home: greeting, search bar, category rail, Featured & Latest rails.
- Product list with live **search**, **category filter** chips, and **sort**
  (price / rating / name).
- Product details: image, rating, stock state, description, related products,
  add-to-cart, buy-now, and wishlist toggle.
- 21 fake products across 6 categories; procedurally-drawn placeholder images
  (no binary assets).

**Cart, wishlist & checkout**
- Cart with quantity steppers, remove, and a live subtotal / tax / shipping /
  total breakdown (free shipping over a threshold). Live count badge on the
  Cart tab.
- Wishlist with move-to-cart and remove.
- Checkout: shipping address, payment-method selector, promo codes
  (`NOVA10` / `WELCOME` / `DEMO20`), order summary, and Place Order.
- Order Success confirmation with a generated order number.

**Orders, profile & settings**
- Order history with statuses (Processing / Delivered / Cancelled) and
  per-order line items; tap a status to cycle it.
- Profile with avatar, stats (orders / wishlist / cart), edit profile, and
  quick links.
- Settings: light/dark theme toggle, clear cart, reset demo data, and about.

All cart, wishlist, orders, session and theme state is **persisted locally** and
restored on relaunch.

## Analytics / event tracking (swappable)

The app fires analytics events from a single, swappable layer so it can be
tested now and moved to the **Adjust SDK** later without touching feature code.

- `AnalyticsService` (interface) — the whole app depends only on this.
- `HttpAnalyticsService` (**active now**) — POSTs each event as JSON to a
  configurable endpoint and prints it to the console. Test/inspect in Postman.
- `AdjustAnalyticsService` (**stub**) — drop-in Adjust implementation; fill in
  your app token + event tokens and flip **one line** in `main.dart`.

**Events fired:** `app_opened`, `login`, `register`, `logout`, `search`,
`view_product`, `add_to_cart`, `remove_from_cart`, `add_to_wishlist`,
`remove_from_wishlist`, `begin_checkout`, `purchase` (with revenue/currency).
They originate from the provider mutation methods and a few screen actions —
the same call sites Adjust will use.

### Configure the test endpoint

Edit `lib/constants/analytics_config.dart` and set `eventEndpoint` to your own
URL (e.g. a [webhook.site](https://webhook.site) URL or a Postman Mock Server).
Until then, events are still printed to the console/logcat — grep for
`📊 analytics »`. Each payload looks like:

```json
{ "app_token": "DEMO-APP-TOKEN", "event": "add_to_cart",
  "params": { "product_id": "p07", "name": "…", "price": 89.99, "quantity": 1 } }
```

### Switching to Adjust later

1. Add `adjust_sdk` to `pubspec.yaml`.
2. In `adjust_analytics_service.dart`, set the app token, map event names →
   Adjust event tokens, and uncomment the `// ADJUST:` SDK calls.
3. In `main.dart`, change one line:
   `final AnalyticsService analytics = AdjustAnalyticsService();`

No provider or screen code changes.

---

## Architecture

The project follows a clean, layered architecture that keeps UI separate from
business logic and data access:

- **models** — immutable data classes (`User`, `Product`, `Category`,
  `CartItem`, `Order`) with JSON (de)serialization.
- **data** — the fixed fake catalog (`product_data`, `category_data`).
- **services** — infrastructure wrappers (`StorageService` over
  `SharedPreferences`); the only layer that touches persistence directly.
- **repository** — data-access logic (`AuthRepository`, `ProductRepository`)
  built on services/data.
- **providers** — `ChangeNotifier`s exposing state to the UI (auth, theme,
  products, cart, wishlist, orders); cart/wishlist/orders persist on every
  mutation.
- **screens** — feature screens, grouped by area (`auth`, `home`, `products`,
  `cart`, `wishlist`, `checkout`, `orders`, `profile`, `settings`, …).
- **widgets** — reusable UI components (product card/image, rating stars,
  price summary, quantity stepper, settings tile, empty state, …).
- **navigation** — route definitions and the GoRouter configuration (a
  `StatefulShellRoute` powers the Home/Cart/Profile/Settings bottom nav).
- **theme / constants / utils** — cross-cutting styling, tokens, and helpers.

State flows one way: **repository → provider → UI**, with the UI dispatching
intents back into providers.

## Folder Structure

```
lib/
├── main.dart                 # Entry point: init storage, wire providers, run app
├── app/app.dart              # Root MaterialApp.router (theme + router)
├── constants/                # app_strings, app_sizes, app_durations, app_config
├── theme/                    # app_colors, app_theme (Material 3 light/dark)
├── models/                   # user, product, category, cart_item, order
├── data/                     # product_data (21 products), category_data
├── services/
│   └── storage_service.dart  # Typed SharedPreferences wrapper (all keys)
├── repository/               # auth_repository, product_repository
├── providers/                # auth, theme, product, cart, wishlist, orders
├── navigation/
│   ├── app_routes.dart       # Route paths & names
│   └── app_router.dart       # GoRouter + auth redirects + bottom-nav shell
├── screens/
│   ├── splash/               # splash_screen
│   ├── auth/                 # login_screen, register_screen
│   ├── home/                 # home_shell (bottom nav), home_screen
│   ├── products/             # product_list_screen, product_details_screen
│   ├── cart/                 # cart_screen
│   ├── wishlist/             # wishlist_screen
│   ├── checkout/             # checkout_screen, order_success_screen
│   ├── orders/               # orders_screen
│   ├── profile/              # profile_screen, edit_profile_screen
│   └── settings/             # settings_screen
├── widgets/                  # product_card/image, rating_stars, price_summary,
│                             # quantity_stepper, settings_tile, user_avatar,
│                             # category_tile, search_field, empty_state, …
└── utils/                    # validators, snackbar, formatters, product_visuals
```

---

## Packages Used

| Package | Purpose |
|--------|---------|
| `provider` | State management (`ChangeNotifier`) |
| `go_router` | Declarative routing with auth guards/redirects |
| `shared_preferences` | Local key/value persistence |
| `uuid` | Unique id generation (users, orders, cart lines) |
| `http` | HTTP client for the swappable analytics layer (demo events) |
| `cupertino_icons` | iOS-style icons |
| `flutter_lints` | Recommended lint rules (dev) |

No networking, backend, or analytics packages are included by design.

---

## How to Run

**Prerequisites:** Flutter (stable, 3.44+) and a connected device or emulator.

```bash
# From the project root
cd adjust_demo

# Fetch dependencies
flutter pub get

# Run on a connected device/emulator
flutter run

# Static analysis
flutter analyze

# Tests
flutter test
```

> **Windows note:** if an Android build ever fails with
> `Could not close incremental caches`, stop stale daemons
> (`cd android && ./gradlew --stop`) and rebuild. Kotlin incremental
> compilation is disabled in `android/gradle.properties`
> (`kotlin.incremental=false`) to prevent this.

---

## Future Improvements

- Integrate an attribution/analytics SDK (e.g. Adjust) and fire events from the
  existing provider mutations (login, add-to-cart, checkout, purchase, …).
- Add integration/golden tests for key flows.
- Optional localization (strings are already centralized in `app_strings`).
- Richer product media and real product imagery.

---

*Built as a reusable demo foundation that can be extended with additional
features or integrated with external SDKs in the future.*
