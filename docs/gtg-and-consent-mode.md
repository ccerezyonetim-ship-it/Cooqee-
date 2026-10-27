# Google Tag Gateway (GTG) & Cooqee Consent Mode

This document explains how Google Tag Gateway (GTG) interacts with Cooqee's
Consent Mode v2 implementation, how to verify whether a Google tag on your
site is enrolled in GTG, and what Cooqee recommends when a "late consent"
signal is detected.

## Reference

- Google's official GTG documentation:
  <https://support.google.com/tagmanager/answer/15161513>
- Google Consent Mode v2 reference:
  <https://developers.google.com/tag-platform/security/guides/consent>
- Google's Universal + Consent (U+C) specification:
  <https://developers.google.com/tag-platform/security/guides/consent-advanced>

## What GTG is and why it matters for consent

Google Tag Gateway is Google's new mechanism for delivering tags through a
first-party CDN rather than directly from a Google-owned domain. When a
customer enables GTG with a one-click CDN injection, Google's tags are
served from the customer's own hostname. The customer no longer controls
the exact order in which these tags load relative to the Cooqee banner,
because the CDN injection runs ahead of ordinary page scripts.

The practical consequence: a Google tag can fire **before** the Cooqee
Consent Mode default command has executed. This is called a **late consent
signal**, and in classical Consent Mode terms it means the tag "ran without
a known consent state." The tag will still function (Google falls back to
denied-equivalent behavior), but attribution and measurement precision are
reduced.

## How to verify whether a tag is enrolled in GTG

1. Open your website in Chrome with DevTools attached (`F12` → Network tab).
2. Filter requests for `googletagmanager.com`, `google-analytics.com`,
   or `googleadservices.com`.
3. If every such request is served from your own hostname (e.g.
   `cdn.yoursite.com/tag/js?id=...`) rather than Google's domain, the tag
   is enrolled in GTG.
4. Alternatively, inspect the `<script>` tag inserted into the DOM — a
   GTG-enrolled tag's `src` attribute points at your first-party CDN.

## Cooqee's behavior when a late signal is detected

Cooqee's debug mode (`debug: true` in the GTM template or
`?cooqeeDebug=1` on the URL) scans the page for Google tags that fired
before the default consent command. When it detects such a tag it writes
one of the following messages to the browser console:

```
[Cooqee] Late tag detected: GA4 (G-XXXXXXXXXX)
         fired before consent default. If this tag is enrolled in
         Google Tag Gateway, see docs/gtg-and-consent-mode.md
         for the recommended fix.
```

Follow the steps below in order:

### Step 1 — Confirm GTG enrollment

Use the DevTools check above. If the tag is **not** enrolled in GTG, the
late signal is caused by ordinary load order and you should fix it the
usual way (move the Cooqee script to the top of `<head>`, remove any
`async` on the Cooqee loader, verify no other CMP has been left on the
page).

### Step 2 — Switch to Universal + Consent (U+C), a.k.a. advanced Consent Mode

When the late tag **is** enrolled in GTG you cannot repair the load order
from inside the page, because GTG controls injection. Google's documented
remediation is to adopt **U+C (advanced Consent Mode)**:

- Turn OFF the "Basic" blocking mode in your Cooqee panel (Settings →
  Consent Mode → **Advanced**).
- Enable **Data Transmission Controls** and **Global Consent Defaults** in
  your Google Ads / GA4 property so measurement is maintained before the
  user interacts with the banner.
- U+C is **the recommended mechanism for GTG-enabled tags**, because it is
  compatible with manual GTG — Google's own tags continue to receive the
  consent signal even if the Cooqee loader has not run yet when they fire.

### Step 3 — Alternative: migrate everything into one GTM container

If you prefer to keep basic blocking mode, migrate every Google tag on the
page into a single GTM container, then deploy GTM via GTG so Google
controls the whole load sequence, or set up GTG manually with import order
you control. See Google's GTM-via-GTG documentation above.

## Why Cooqee recommends U+C for GTG-enrolled sites

- U+C is purposely designed to work when the exact script load order
  cannot be guaranteed. GTG is one of several contexts (CDN rewrites,
  edge workers, server-side tagging) that can reorder script execution
  outside the page author's control.
- Basic Consent Mode blocks Google tags until consent is set. On a
  GTG-enrolled site, the "block" never actually applies to the tag,
  because the tag loads before Cooqee can intercept it.
- U+C lets the tag load, read Data Transmission Controls / Global Consent
  Defaults, and operate under those defaults until the user interacts
  with the banner. When they do interact, the Cooqee update command fires
  normally and the tag transitions to the chosen state.

## In short

| Situation                                     | Recommended fix          |
|-----------------------------------------------|--------------------------|
| Late signal, tag is **not** GTG-enrolled      | Fix script load order    |
| Late signal, tag **is** GTG-enrolled          | Switch to U+C (advanced) |
| Prefer to keep basic blocking on a GTG site   | Move all tags into GTM + GTG |

If you have followed the steps above and still see a late signal in
Cooqee's debug mode, contact Cooqee support at `contact@cooqee.com.tr`
with a page URL and your container ID — we will reproduce it on our side
and reply with a specific remediation.
