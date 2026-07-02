# Adjust SDK Integration Guide

This guide takes Nova Store from its current **swappable HTTP analytics layer** to a
full **Adjust SDK** integration — covering both halves of Adjust:

1. **Event tracking** — already fully wired in the app; you only fill in tokens.
2. **Attribution** — tracking which ad/campaign an install came from. This needs an
   Adjust account, tracker links, and testing through Adjust's dashboard (it cannot
   be tested with Postman or plain HTTP).

> **Current state:** the app fires all events through an `AnalyticsService`
> interface. Today it uses `HttpAnalyticsService` (Postman-testable). Switching to
> Adjust is a one-line change plus filling tokens — **no provider or screen code
> changes.**

---

## 0. Mental model — the two halves

| | Event tracking | Attribution |
|---|---|---|
| Answers | "What did the user do?" | "Where did this install come from?" |
| Status in this app | ✅ Done (code) | ⛔ Blocked on Adjust account |
| Test tool | Postman / webhook.site / Adjust console | **Adjust Testing Console only** |
| Effort split | ~all code (done) | ~90% dashboard/process, ~10% code |

The events we fire (`login`, `add_to_cart`, `purchase`, …) are enough for the
event half. Attribution is a **separate mechanism** the SDK performs on install.

---

## 1. Prerequisites (Adjust dashboard — no coding)

- [ ] **Approved Adjust account** with this app created → note the **App Token**
      (looks like `abc1de2fghij`).
- [ ] Create an **Event Token** for each event you want to forward. Map them to the
      app's canonical event names (see the table in §4). Purchase should be set up
      as a **revenue event**.
- [ ] Create **Tracker / Campaign links** — one per source you want to test
      (e.g. a generic "Test" tracker, plus Google Ads / Meta later). Each yields a
      URL like `https://app.adjust.com/abc123`.
- [ ] (iOS, later) App available via **TestFlight / App Store**; configure
      **SKAdNetwork** and an **ATT** prompt.
- [ ] (Android) A device/emulator with **Google Play services** for Install
      Referrer attribution.

---

## 2. Add the SDK

In `pubspec.yaml` (under `dependencies:`), add:

```yaml
  adjust_sdk: ^5.4.0   # check pub.dev for the latest 5.x
```

Then:

```bash
flutter pub get
```

### Android platform setup
- Add the **Install Referrer** library so Adjust can read Play Store referrer data.
  In `android/app/build.gradle` (`dependencies { }`):
  ```gradle
  implementation 'com.android.installreferrer:installreferrer:2.2'
  ```
- Ensure **INTERNET** permission is in the **release** manifest too
  (`android/app/src/main/AndroidManifest.xml`), not just debug:
  ```xml
  <uses-permission android:name="android.permission.INTERNET"/>
  ```
- (Optional, recommended) add Google Play Services ad-id gathering per Adjust docs.

### iOS platform setup (when you target iOS)
- In `ios/Runner/Info.plist` add the **ATT** usage string:
  ```xml
  <key>NSUserTrackingUsageDescription</key>
  <string>We use this to measure the effectiveness of our ads.</string>
  ```
- Configure **SKAdNetwork** IDs per Adjust's iOS guide.
- Prompt for ATT (via `Adjust.requestTrackingAuthorizationWithCompletionHandler`
  or the `app_tracking_transparency` package) before/at first launch.

---

## 3. Fill in the Adjust implementation

The file **`lib/services/analytics/adjust_analytics_service.dart`** already exists as a
stub with everything marked. Steps:

1. Uncomment `import 'package:adjust_sdk/...';` lines.
2. Set `_appToken` to your App Token.
3. Fill the `_eventTokens` map (canonical name → Adjust event token).
4. Uncomment the `// ADJUST:` SDK calls in `init`, `logEvent`, `logPurchase`.
5. Set the environment: `AdjustEnvironment.sandbox` for testing,
   `AdjustEnvironment.production` for release.

### Attribution-specific code (the only *new* code beyond events)

Attribution needs a couple of things events don't. Add these to `init()`:

```dart
// inside AdjustAnalyticsService.init()
final config = AdjustConfig(_appToken, AdjustEnvironment.sandbox);

// (a) receive the attribution result — THIS is how you verify attribution works.
config.attributionCallback = (attribution) {
  debugPrint('🎯 Adjust attribution: '
      'network=${attribution.network} campaign=${attribution.campaign} '
      'tracker=${attribution.trackerName}');
  // Optionally surface this in the UI / send to your own backend.
};

// (b) deferred deep link (optional — if ads should route to a specific screen).
config.deferredDeeplinkCallback = (uri) {
  debugPrint('🔗 deferred deep link: $uri');
  // Route with GoRouter here, e.g. context.go(...) via a navigator key.
  return true; // let Adjust also open it
};

Adjust.initSdk(config);
```

> These callbacks are the attribution equivalent of "verifying an event fired" —
> when a tracker link brings in an install, the attribution callback is where you
> observe it.

---

## 4. Event → token mapping

Fill the `_eventTokens` map in `AdjustAnalyticsService`. Canonical names come from
`lib/services/analytics/analytics_service.dart` (`AnalyticsEvents`). Where each one
fires in the app:

| Canonical event | Adjust token | Fires from |
|---|---|---|
| `app_opened` | (session — usually automatic) | `main.dart` → `analytics.init()` |
| `login` | `TODO` | `providers/auth_provider.dart` |
| `register` | `TODO` | `providers/auth_provider.dart` |
| `logout` | `TODO` | `providers/auth_provider.dart` |
| `search` | `TODO` | search field `onSubmitted` |
| `view_product` | `TODO` | `screens/products/product_details_screen.dart` (`initState`) |
| `add_to_cart` | `TODO` | `providers/cart_provider.dart` (`add`) |
| `remove_from_cart` | `TODO` | `providers/cart_provider.dart` (`remove`) |
| `add_to_wishlist` | `TODO` | `providers/wishlist_provider.dart` |
| `remove_from_wishlist` | `TODO` | `providers/wishlist_provider.dart` |
| `begin_checkout` | `TODO` | `screens/checkout/checkout_screen.dart` (`initState`) |
| `purchase` (revenue) | `TODO` | `providers/orders_provider.dart` (`placeOrder`) |

`purchase` already passes `revenue` + `currency` + `orderId` via `logPurchase`, which
maps cleanly onto `AdjustEvent.setRevenue(revenue, currency)`.

---

## 5. Flip the switch

In `lib/main.dart`, change the single backend line:

```dart
// Before (HTTP / Postman-testable):
final AnalyticsService analytics = HttpAnalyticsService();

// After (Adjust):
final AnalyticsService analytics = AdjustAnalyticsService();
```

Nothing else changes. Every event call site stays identical.

> Tip: you can keep both — e.g. a small `CompositeAnalyticsService` that forwards to
> both HTTP (for your own inspection) and Adjust — if you want side-by-side.

---

## 6. Testing

### 6a. Events (fast loop)
- **Sandbox + verbose logs:** run the app, watch logcat:
  ```bash
  flutter logs        # or: adb logcat -s flutter
  ```
  Adjust prints each tracked event in sandbox mode.
- **Adjust Testing Console** (dashboard): shows events arriving from your device in
  real time.

### 6b. Attribution (the part Postman can't do)
1. Build in **sandbox** mode and install on a real device/emulator.
2. In the Adjust dashboard, open the **Testing Console** and add/inspect your device
   (by advertising id / `adid`).
3. **Click a tracker link** you created (§1) on that device.
4. Install/open the app **through that click**.
5. Confirm the dashboard attributes the install to that tracker, and that your
   **`attributionCallback`** (§3) logged the network/campaign.
6. If you set up deferred deep links, confirm the app routed to the right screen.

> There is no Postman shortcut for 6b — attribution matching happens inside Adjust's
> backend against the real SDK's install signals.

---

## 7. What "done" looks like

- [ ] SDK added, platform setup complete (Android referrer / iOS ATT+SKAN).
- [ ] `AdjustAnalyticsService` filled with app token + event tokens, SDK calls
      uncommented.
- [ ] `main.dart` switched to `AdjustAnalyticsService()`.
- [ ] Events visible in the Adjust Testing Console.
- [ ] A test tracker-link install attributed correctly, attribution callback firing.
- [ ] Switch environment to `production` and remove verbose logging for release.

---

## Appendix — why the architecture makes this cheap

The app depends only on the `AnalyticsService` interface. Providers fire semantic
events (`add_to_cart`, `purchase`, …) at single choke points; screens fire
navigation events via the `AnalyticsContext` extension. Swapping the HTTP backend for
Adjust touches **one file** (`AdjustAnalyticsService`) plus **one line**
(`main.dart`). See `docs`/memory `analytics-swappable-layer` for the full map.
