# Cooqee CMP — Google Tag Manager Community Template

The official Google Tag Manager template for the [Cooqee](https://cooqee.com.tr)
Consent Management Platform. Add Cooqee to any website that uses GTM in under
a minute — no code changes, no manual banner installation.

[![Template version](https://img.shields.io/badge/template-v1.0.0-blue)]()
[![License](https://img.shields.io/badge/license-Apache%202.0-green)]()
[![GTM Gallery](https://img.shields.io/badge/gallery-pending-orange)]()

---

## What this template does

Loads the Cooqee CMP banner on your website and wires it up to the four
compliance signals every modern ad network expects:

| Signal | What it is | Where Cooqee publishes it |
|---|---|---|
| **Google Consent Mode v2** | Google's four-signal consent protocol (`ad_storage`, `analytics_storage`, `ad_user_data`, `ad_personalization`) | `gtag('consent', 'default' / 'update', …)` |
| **IAB TCF v2.2** | The IAB Transparency and Consent Framework TC String, read by ~1,200 vendors on the IAB Global Vendor List | `euconsent-v2` cookie + `window.__tcfapi()` |
| **Additional Consent (AC) v2** | Google's companion string for Ad-Technology Providers not on the IAB list | `addtl_consent` cookie |
| **IAB GPP** | The Global Privacy Platform — a multi-region encoding of consent (CCPA, CPRA, US National, TCF EU) | `gpp` cookie + `window.__gpp()` |

Set every Google Consent Mode v2 signal to `denied` by default, before any
Google tag fires. Visitors in the EEA / UK additionally see the full
IAB TCF v2.2 preference centre with 11 purposes, 2 special features, and
per-vendor control. US visitors see the GPP banner.

---

## Quick start

### 1 · Install the template

In Google Tag Manager:

1. **Templates** → **Tag Templates** → **Search Gallery**
2. Search for **"Cooqee"** → **Add to workspace**
3. Accept the permissions prompt (details below).

### 2 · Create a tag from the template

1. **Tags** → **New** → **Tag Configuration** → pick **Cooqee CMP**
2. Enter your **Customer ID** (found in your Cooqee panel → *Settings* → *API Keys*).
3. (Optional) adjust language, TCF / AC / GPP toggles, and the
   `wait_for_update` value.
4. **Triggering** → **Consent Initialization — All Pages** (**IMPORTANT** —
   not "All Pages"; the template MUST run before every other tag).
5. **Save** → **Submit** → **Publish**.

### 3 · Verify

Open your website in an incognito window, open DevTools → Console, and run:

```js
dataLayer.filter(x => x[0] === 'consent')
```

You should see at least one `default` entry with every signal set to
`'denied'`. Click **Accept All** on the Cooqee banner, re-run the filter,
and you'll see a second `update` entry with the granted signals.

---

## Fields reference

### Required

| Field | Type | Purpose |
|---|---|---|
| **Customer ID** | Text | Links the banner to your Cooqee account. Find it under *Panel → Settings → API Keys*. |

### Google Consent Mode v2 — Defaults

| Field | Type | Default | Purpose |
|---|---|---|---|
| **Wait for update (ms)** | Select | `500` | How long Google tags wait for the first `consent update` before firing. Google-recommended value: 500 ms. |
| **URL passthrough** | Checkbox | On | When storage is denied, Google tags pass `gclid` / `dclid` via URL so attribution isn't lost. |
| **Ads data redaction** | Checkbox | On | When `ad_storage` is denied, Google fully anonymises ad traffic. Required for GDPR. |

### Banner Options

| Field | Type | Default | Purpose |
|---|---|---|---|
| **Default language** | Select | Auto | Banner opens in this language on first visit. "Auto" reads the browser's `Accept-Language` header. |
| **Enable IAB TCF v2.2** | Checkbox | On | Publishes a full TC String for EEA / UK visitors. Required for Silver-tier Google CMP certification. |
| **Enable Additional Consent (AC) v2** | Checkbox | On | Publishes AC v2 for Google's non-IAB ATPs. |
| **Enable IAB GPP** | Checkbox | On | Publishes a GPP string for US visitors (CCPA / CPRA). |

### Advanced

| Field | Type | Default | Purpose |
|---|---|---|---|
| **Banner script URL (override)** | Text | `https://cooqee.com.tr/scripts/cooqee-banner.js` | Only change this if you self-host the banner from a custom CDN. The URL **must** be allow-listed in the template's `inject_script` permission. |
| **Debug mode** | Checkbox | Off | Logs diagnostics to the browser console. Disable in production. |

---

## Permissions requested

The template requests the following GTM permissions. Each is scoped to the
narrowest set that lets the integration work.

| Permission | Scope | Why |
|---|---|---|
| `logging` | Debug environments only | For the debug-mode diagnostic logs. Never emits in production containers. |
| `inject_script` | `https://cooqee.com.tr/*`, `https://cdn.cooqee.com.tr/*` | To load the Cooqee banner script. Scoped to Cooqee-owned domains only. |
| `access_consent` | Write access to the 7 standard Consent Mode v2 signals | To call `setDefaultConsentState()`. Read access is not requested; the template never inspects existing consent. |
| `write_data_layer` | `gtag.*`, `url_passthrough`, `ads_data_redaction` | For `gtag('set', …)` calls applying the Google-recommended defaults. |
| `access_globals` | `__tcfapi`, `__tcfapi.a` (read + write, no execute) | To install the IAB TCF v2.2 queueing stub before the main library wakes up. |

Everything else (reading cookies, injecting pixels, calling third-party
APIs) is handled by the Cooqee banner script itself, which the template
loads — the template is a thin GTM-side bootstrap.

---

## How it works

```
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│  Visitor loads page                                            │
│         │                                                      │
│         ▼                                                      │
│  ┌─────────────────────────────────────────────┐              │
│  │ GTM "Consent Initialization — All Pages"    │              │
│  │ trigger fires this template:                │              │
│  │                                             │              │
│  │   1. setDefaultConsentState({ all denied })│              │
│  │   2. gtagSet({ url_passthrough: true })    │              │
│  │   3. gtagSet({ ads_data_redaction: true }) │              │
│  │   4. Install __tcfapi() stub               │              │
│  │   5. injectScript('cooqee-banner.js')      │              │
│  └─────────────────────────────────────────────┘              │
│         │                                                      │
│         ▼                                                      │
│  All Google tags with "wait_for_update: 500"                   │
│  pause for up to 500ms…                                        │
│         │                                                      │
│         ▼                                                      │
│  ┌─────────────────────────────────────────────┐              │
│  │ Cooqee banner finishes loading, reads the  │              │
│  │ stored consent cookie (if any), or renders │              │
│  │ the banner for a new visitor.              │              │
│  └─────────────────────────────────────────────┘              │
│         │                                                      │
│         ▼                                                      │
│  Visitor clicks Accept / Reject / Customise                    │
│         │                                                      │
│         ▼                                                      │
│  ┌─────────────────────────────────────────────┐              │
│  │ Cooqee calls gtag('consent', 'update', {}) │              │
│  │ Writes euconsent-v2 (TCF), addtl_consent   │              │
│  │ (AC v2), gpp (GPP), and the first-party    │              │
│  │ Cooqee cookie all in one go.               │              │
│  └─────────────────────────────────────────────┘              │
│         │                                                      │
│         ▼                                                      │
│  Downstream Google tags unblock and fire with the correct      │
│  consent state, in sync with every IAB vendor on the page.    │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

---

## Testing

Open the Template Editor in GTM and click **Tests** → **Run all**.
Three built-in tests ship with the template:

- **Sets Consent Mode v2 defaults to denied** — all four Google signals
  land in the `denied` state before any tag fires.
- **Injects the banner script with the customer ID** — the Customer ID
  from the field reaches the banner via the `cid=` URL parameter.
- **Calls gtmOnFailure when the banner fails to load** — a 404 on the
  CDN URL does not silently swallow the error.

For end-to-end verification, use the companion demo site:
<https://demo.cooqee.com.tr> — same wiring, deployed, with the audit
checklist in the site's README.

---

## Changelog

See [CHANGELOG.md](./CHANGELOG.md).

---

## Support

- 📬 **Technical issues:** [engineering@cooqee.com.tr](mailto:engineering@cooqee.com.tr)
- 📘 **Documentation:** <https://cooqee.com.tr/docs/gtm>
- 🏢 **Panel / signup:** <https://cooqee.com.tr>

---

## License

Apache 2.0 — see [LICENSE](./LICENSE).
