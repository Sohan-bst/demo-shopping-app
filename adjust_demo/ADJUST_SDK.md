# Adjust SDK Integration — Nova Store Demo App

This document explains how the [Adjust](https://www.adjust.com/) mobile attribution & analytics SDK is integrated into this app, what it currently tracks, how to verify it's working, and what else you'd typically add for a real production app.

- **App:** Nova Store (Flutter e-commerce demo), package `com.example.adjustdemo`
- **Adjust dashboard:** https://suite.adjust.com/datascape/custom-dashboard?custom_dashboard_id=affd779e-9ea4-482a-86d9-6a4b1e9e517c
- **Demo APK:** https://drive.google.com/drive/folders/1_dEetdohn3j_5Hzht1ka7_XRd8X0D0wG?usp=sharing

---

## 1. What Adjust is / how it works (quick primer)

Adjust is a mobile measurement partner (MMP). It sits between your app and your marketing/ad networks and answers two questions:

1. **Attribution** — "Which campaign/ad/network caused this install (or re-engagement)?" The SDK reads the device's advertising ID (Google Advertising ID on Android / IDFA on iOS) and click/impression data from ad networks, then matches a fresh install to the ad that drove it.
2. **Event & revenue tracking** — After install, the app calls the SDK to report things users do (`add_to_cart`, `purchase`, watching a rewarded ad, etc.). Adjust attributes those events back to the original install/campaign so you can measure ROAS, funnel drop-off, LTV, etc. per campaign/network/creative.

At a high level, the flow is:

```
App start
  → Adjust.initSdk(config)          // SDK opens a "session"
  → SDK sends install/session info to Adjust's servers
  → Adjust checks it against click/impression data from ad networks
  → Install gets attributed (Organic, or a specific network/campaign)

User action (add to cart, purchase, etc.)
  → App calls Adjust.trackEvent(AdjustEvent(token))
  → SDK batches/sends the event to Adjust's servers
  → Event appears in Datascape / Testing Console, attributed to the same install
```

Key building blocks used by this SDK:

| Concept | What it is |
|---|---|
| **App token** | Identifies *this app* to Adjust (one per app, per platform). Public — safe to ship in source. |
| **Event token** | A short code (e.g. `dvpgwr`) identifying *one event type* (e.g. "add to cart"). Created per-event in the dashboard, mapped in app code. |
| **Environment** | `sandbox` (test data, shows immediately in the Testing Console) vs `production` (real data, goes to Datascape/Insights with aggregation delay). |
| **Callback parameters** | Free-form key/value strings attached to an event (e.g. `product_id`, `price`) for extra context/debugging. |
| **Revenue tracking** | `purchase`/ad-revenue events can carry a monetary value + ISO currency so Adjust can compute revenue and ROAS. |
| **GPS Advertising ID / IDFA** | The device-level advertising identifier used to match installs to ad clicks. Needed when looking up a specific device in the Testing Console. |

---

## 2. What's added in this app

### 2.1 Dependency

`pubspec.yaml`:
```yaml
adjust_sdk: ^5.6.2
```

This is the official Flutter plugin wrapping Adjust's native Android/iOS SDKs (v5).

### 2.2 Configuration — `lib/constants/adjust_config.dart`

All Adjust settings live in one file, `AdjustSettings`:

```dart
static const String appToken = 'bwvz3zev5o1s';
static const AdjustEnvironment environment = AdjustEnvironment.production;
static const AdjustLogLevel logLevel = AdjustLogLevel.verbose;

static const Map<String, String> eventTokens = {
  AnalyticsEvents.appOpened:         'y1m3k4',
  AnalyticsEvents.login:             'w1uvub',
  AnalyticsEvents.register:          'rz61gw',
  AnalyticsEvents.logout:            'wxo1us',
  AnalyticsEvents.search:            'si7mhj',
  AnalyticsEvents.viewProduct:       '2kscdv',
  AnalyticsEvents.addToCart:         'dvpgwr',
  AnalyticsEvents.removeFromCart:    '4er2sc',
  AnalyticsEvents.addToWishlist:     'kjd3r2',
  AnalyticsEvents.removeFromWishlist:'gtlxkx',
  AnalyticsEvents.beginCheckout:     'xe60dk',
  AnalyticsEvents.purchase:          '88ahe2',
};
```

Notes:
- The app token and every event token are **real, already-created tokens** from the Adjust dashboard for this demo app — not placeholders.
- `AdjustSettings.tokenFor(name)` returns `null` for any event whose token is missing or still a `CHANGE_ME_*` placeholder, so `AdjustAnalyticsService` silently skips sending it. This means the integration degrades gracefully if you ever remove/rename an event.
- **Environment is currently set to `AdjustEnvironment.production`.** This means the app is sending live data to the real Datascape dashboards, not the Testing Console. See §4 for how to flip this to `sandbox` for testing.
- `logLevel = AdjustLogLevel.verbose` prints detailed request/response logs from the native SDK — good for development, should be turned down (`AdjustLogLevel.suppress` or `.error`) for an actual release build.

### 2.3 Swappable analytics layer

The app never calls the Adjust SDK directly from UI/business logic. There's an interface, `AnalyticsService` (`lib/services/analytics/analytics_service.dart`), with one concrete implementation, `AdjustAnalyticsService` (`lib/services/analytics/adjust_analytics_service.dart`), wired up in `main.dart`:

```dart
final AnalyticsService analytics = AdjustAnalyticsService();
```

`AdjustAnalyticsService` implements four methods:

| Method | Adjust call | Used for |
|---|---|---|
| `init()` | `AdjustConfig(...)` → `Adjust.initSdk(config)` | Boots the SDK once at app start; also fires `app_opened` |
| `logEvent(name, params)` | `AdjustEvent(token)` + `addCallbackParameter` → `Adjust.trackEvent(event)` | Generic named events |
| `logPurchase(revenue, currency, orderId, params)` | `AdjustEvent(token)..setRevenue(...)` → `Adjust.trackEvent(event)` | Revenue-carrying purchase event |
| `logAdRevenue(source, revenue, currency, network, unit, placement)` | `AdjustAdRevenue(source)..setRevenue(...)` → `Adjust.trackAdRevenue(event)` | In-app ad monetization (rewarded video, etc.) |

Every call is:
- **Non-throwing** — wrapped in try/catch so a failed/misconfigured analytics call never breaks the user's action.
- **Mirrored to the debug console** as `📊 analytics » <event> {params}` for local visibility regardless of whether Adjust actually sent anything.

### 2.4 Events currently tracked, and what triggers them

| Event name | Token | Trigger | Source |
|---|---|---|---|
| `app_opened` | `y1m3k4` | App startup | `AdjustAnalyticsService.init()` |
| `login` | `w1uvub` | Successful login | `lib/providers/auth_provider.dart:105` |
| `register` | `rz61gw` | Successful registration | `lib/providers/auth_provider.dart:105` (shared `_run` helper, event name passed in) |
| `logout` | `wxo1us` | User logs out | `lib/providers/auth_provider.dart:86` |
| `search` | `si7mhj` | Search submitted (on submit, not per keystroke) | `lib/services/analytics/analytics_context.dart` → `product_list_screen.dart:80` |
| `view_product` | `2kscdv` | Product details screen opened | `lib/screens/products/product_details_screen.dart:42` |
| `add_to_cart` | `dvpgwr` | Item added/incremented in cart (with `product_id`, `name`, `price`, `quantity`) | `lib/providers/cart_provider.dart:64` |
| `remove_from_cart` | `4er2sc` | Item removed from cart | `lib/providers/cart_provider.dart:103` |
| `add_to_wishlist` / `remove_from_wishlist` | `kjd3r2` / `gtlxkx` | Wishlist toggled | `lib/providers/wishlist_provider.dart:68` |
| `begin_checkout` | `xe60dk` | Checkout screen opened (with `item_count`, `total`) | `lib/screens/checkout/checkout_screen.dart:54` |
| `purchase` | `88ahe2` | Order placed — **revenue event**, carries `revenue`/`currency`/`order_id`, plus `item_count`, `payment_method` | `lib/providers/orders_provider.dart:56` |
| `ad_revenue` | *(no event token — sent via `trackAdRevenue`, not `trackEvent`)* | User watches the "Watch a short video" rewarded-ad card on Home ($0.02, source `admob_sdk`) | `lib/widgets/watch_ad_card.dart:134` |

All event *names* are centralized as constants in `AnalyticsEvents` (`lib/services/analytics/analytics_service.dart`) so the dashboard config and the code can't drift apart.

### 2.5 Native Android setup

- **`android/app/src/main/AndroidManifest.xml`** — added permissions Adjust needs:
  - `android.permission.INTERNET` — send data to Adjust's servers
  - `com.google.android.gms.permission.AD_ID` — required on Android 13+ to read the Google Advertising ID
  - `android.permission.ACCESS_NETWORK_STATE` — connectivity checks
- **`android/app/build.gradle.kts`** — added native dependencies the SDK uses for attribution:
  - `com.google.android.gms:play-services-ads-identifier:18.1.0` (Google Advertising ID)
  - `com.android.installreferrer:installreferrer:2.2` (Play Store install referrer — tells Adjust which Play Store click led to the install)
- **`android/app/proguard-rules.pro`** — keep-rules so release/R8 builds don't strip Adjust SDK classes.

There is **no `ios/` project** in this repo (Android-only demo). For iOS you would additionally need: `AppTrackingTransparency` prompt + `NSUserTrackingUsageDescription` in `Info.plist`, and `Adjust.initSdk` called from the app delegate/Flutter side the same way.

---

## 3. What you'd add for a real production app

This demo covers the core "fire events, see them in the dashboard" loop. A production integration typically adds:

1. **Attribution callbacks** — `AdjustConfig.attributionCallback` to receive network/campaign/adgroup/creative info in-app (e.g. to personalize onboarding or pass to your own backend/CRM).
2. **Deferred deep linking** — so a user who clicks an ad before installing lands on the right in-app screen after install (`AdjustConfig` deep link resolvers + your router).
3. **App Tracking Transparency (iOS)** — request the ATT prompt and only initialize/track after consent, per Apple's requirements. On Android 13+, similarly respect user ad-ID settings.
4. **Consent/Privacy (GDPR/CCPA)** — Adjust's SDK supports `Adjust.gdprForgetMe()`, `AdjustThirdPartySharing`, and disabling tracking per region/consent state.
5. **Google Play Install Referrer verification** and **SKAdNetwork (iOS)** setup for privacy-safe attribution on newer OS versions.
6. **Server-to-server (S2S) events** for critical revenue events (e.g. subscription renewals from your backend) instead of only client-side tracking, so events aren't lost if the app is killed.
7. **Cost/ad-spend integration** — connect real ad network accounts in Adjust so ROAS/CPI reporting is populated (a demo app has no real campaigns, so installs always show as "Organic").
8. **Fraud prevention** — enable Adjust's fraud prevention suite for click spam/install fraud filtering.
9. **Environment safety** — ensure builds are hard-wired to `AdjustEnvironment.production` for release and `sandbox` for debug/QA (e.g. driven by build flavor, not a manually-edited constant), and set `logLevel` to `suppress`/`error` in release.
10. **COPPA / age-gating flags** if the app targets children.
11. **Event de-duplication safeguards** — e.g. guard `purchase` against being fired twice for the same order (retry, back-navigation) using `order_id`-based dedup, which Adjust supports natively for purchase events.
12. **QA per release** — a checklist step to verify new/changed events in the Testing Console before shipping (see §5).

---

## 4. Sandbox vs Production — switching environments

`lib/constants/adjust_config.dart`:

```dart
static const AdjustEnvironment environment = AdjustEnvironment.production;
```

- **`AdjustEnvironment.sandbox`** — use during development/QA. Events show up almost immediately in the Adjust **Testing Console** (see §5). Use this whenever you want to *verify* something is wired correctly.
- **`AdjustEnvironment.production`** — use for real users / release builds. Data goes to **Datascape** dashboards and Insights reports, aggregated over time (see §6 for lag).

To test: change this line to `AdjustEnvironment.sandbox`, rebuild, and use the Testing Console. Change it back to `production` before shipping/demoing real dashboard numbers.

---

## 5. How to verify events are reaching Adjust (Testing Console)

The **Testing Console** (in the Adjust dashboard) shows events in near real-time for **sandbox** builds — this is the fastest way to confirm the plumbing works end-to-end.

Steps:

1. Set `AdjustSettings.environment = AdjustEnvironment.sandbox` and rebuild/reinstall the app on your device/emulator.
2. In the Adjust dashboard, open **Testing Console** for this app.
3. Find your device. The Testing Console looks up devices by the **GPS Advertising ID (GAID)** (Android) — **not** the Adjust device ID (ADID). Get it directly from the device:

   **On the phone/tablet:**
   1. Open **Settings**.
   2. Scroll down and tap **Google**.
   3. Tap **Ads** (on some Android versions this is under **All services → Ads**).
   4. Your **Advertising ID** is shown on that screen — copy it and paste it into the Testing Console's device search.

   Use this same ID any time you want to check whether *your own* device's events are reaching Adjust — search for it in the Testing Console and confirm your events show up.

   **On an emulator** (the Settings → Google → Ads screen often shows a blank/null ID on emulators), pull it via adb instead:
   ```
   adb logcat -s Adjust | grep gps_adid
   ```
4. Trigger actions in the app (open app, add to cart, checkout, purchase, watch the rewarded-ad card, etc.).
5. Watch the Testing Console — each should appear as a row with a server response of **"Event tracked"** (or "Session tracked" / "Install tracked" for the session-level ones). A failed/misconfigured token typically shows up as a rejected/errored row instead.
6. You can also confirm client-side that the SDK is actually sending requests by tailing logcat with verbose logging on:
   ```
   adb logcat -s Adjust
   ```
   Sandbox logs show detailed per-request lines ("Making request…", "tracked"); this is much chattier than production logging.

Once you've confirmed events in the Testing Console, switch back to `AdjustEnvironment.production` for real dashboard reporting.

---

## 6. Dashboard delay — production data is NOT real-time

This is a common point of confusion: **there is a delay between an event happening in the app and it showing up in the production Datascape/Insights dashboards.** The exact delay isn't documented/fixed by Adjust and can vary — from around an hour up to appearing more fully the next day, depending on the metric and how Adjust batches/aggregates it. Don't assume "I tapped purchase and don't see it in the dashboard 5 minutes later" means something is broken.

Practical implications:
- If you need to verify an event **immediately**, use **sandbox + Testing Console** (§5), not the production dashboard.
- If you're checking the **production** dashboard, expect numbers to lag — check back later rather than treating an empty/low count as a bug.
- Pick the right report/dashboard template: a **Network/Campaign/ROAS**-oriented report will look empty for this demo because there's no real ad spend/campaigns behind it (a demo install is always attributed "Organic"). For a demo app, use an **event / session / install / revenue** report grouped by Day instead — that's where `app_opened`, `begin_checkout`, `purchase`, etc. actually show up.

---

## 7. File reference

| File | Purpose |
|---|---|
| `lib/constants/adjust_config.dart` | App token, environment, log level, event-token map |
| `lib/services/analytics/analytics_service.dart` | `AnalyticsService` interface + `AnalyticsEvents` name constants |
| `lib/services/analytics/adjust_analytics_service.dart` | Adjust SDK implementation (init/logEvent/logPurchase/logAdRevenue) |
| `lib/services/analytics/analytics_context.dart` | `BuildContext` convenience extensions (`context.logViewProduct`, `context.logSearch`) |
| `lib/main.dart` | Wires `AdjustAnalyticsService` as the active backend, provides it via `Provider<AnalyticsService>` |
| `lib/providers/{auth,cart,wishlist,orders}_provider.dart` | Fire login/logout/register, cart add/remove, wishlist toggle, purchase events |
| `lib/screens/checkout/checkout_screen.dart` | Fires `begin_checkout` |
| `lib/screens/products/product_details_screen.dart` | Fires `view_product` |
| `lib/widgets/watch_ad_card.dart` | Fires `ad_revenue` (simulated rewarded video) |
| `android/app/src/main/AndroidManifest.xml` | Adjust-required permissions |
| `android/app/build.gradle.kts` | Native attribution dependencies (advertising ID, install referrer) |
| `android/app/proguard-rules.pro` | Keep-rules for release builds |

---

## 8. Links

- Adjust dashboard (this app's custom dashboard): https://suite.adjust.com/datascape/custom-dashboard?custom_dashboard_id=affd779e-9ea4-482a-86d9-6a4b1e9e517c
- Demo APK: https://drive.google.com/drive/folders/1_dEetdohn3j_5Hzht1ka7_XRd8X0D0wG?usp=sharing
