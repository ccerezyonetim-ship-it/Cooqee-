# Installing Cooqee CMP via Google Tag Manager

This guide walks you through installing Cooqee on your website using the
official Google Tag Manager (GTM) Community Template. Total time: **under
five minutes**.

---

## Before you begin

You need:

- An active [Cooqee](https://cooqee.com.tr) account with your **Customer ID**
  (visible in your Cooqee panel under *Settings → API Keys*).
- A GTM container already deployed on your website.
- Publish permission on that GTM container.

---

## Step 1 — Add the template to your workspace

1. In GTM, open your container.
2. Left menu → **Templates**.
3. Under **Tag Templates**, click **Search Gallery**.
4. Type **"Cooqee"** into the search box.
5. Click the Cooqee CMP card → **Add to workspace**.

GTM will show you a permissions prompt describing exactly what the template
needs — see [the README](../README.md#permissions-requested) for the full
breakdown. Click **Add** to accept.

---

## Step 2 — Create a tag

1. Left menu → **Tags** → **New**.
2. Give it a descriptive name, e.g. *"Cooqee CMP — Consent Init"*.
3. **Tag Configuration** → **Discover more tag types** → **Cooqee CMP**.
4. Fill in the fields:

   | Field | Value |
   |---|---|
   | **Customer ID** | *Your Cooqee Customer ID — required* |
   | **Wait for update** | `500 ms` *(default — recommended)* |
   | **URL passthrough** | ✅ on *(default)* |
   | **Ads data redaction** | ✅ on *(default)* |
   | **Default language** | `Auto` *(default)* |
   | **Enable IAB TCF v2.2** | ✅ on *(if you serve EEA/UK traffic)* |
   | **Enable Additional Consent v2** | ✅ on *(if you use Google Ads)* |
   | **Enable IAB GPP** | ✅ on *(if you serve US traffic)* |

5. Leave the Advanced section untouched unless you self-host the banner.

---

## Step 3 — Set the trigger

**This is the most important step.** The template MUST fire before every
other Google tag.

1. Scroll to **Triggering** → click the pencil.
2. Click the ⊕ in the top-right → **New Trigger**.
3. Trigger name: *"Consent Initialization — All Pages"*.
4. **Trigger Configuration** → choose **Consent Initialization**.
5. Fire on: **All Pages**.
6. Save the trigger.

> **Why "Consent Initialization" and not "All Pages"?** The former fires
> *earlier* than any other trigger in the GTM lifecycle — before any
> Google tag with `wait_for_update` even checks its consent state. If you
> use plain "All Pages" instead, your Google tags may fire before the
> Cooqee default-denied signals are set, which breaks consent mode.

---

## Step 4 — Publish

1. **Save** the tag.
2. Top-right → **Submit**.
3. Name the version, e.g. *"Add Cooqee CMP"*.
4. **Publish**.

The banner will now appear on every page of your site within seconds.

---

## Step 5 — Verify

1. Open your website in an **incognito** window (so stored consent doesn't
   skip the banner).
2. Do NOT click the banner.
3. Open DevTools → **Console**, and run:

   ```js
   dataLayer.filter(x => x[0] === 'consent')
   ```

4. You should see at least one entry:

   ```
   ['consent', 'default', {
     ad_storage: 'denied',
     analytics_storage: 'denied',
     ad_user_data: 'denied',
     ad_personalization: 'denied',
     wait_for_update: 500,
     ...
   }]
   ```

5. Click **Accept All** on the Cooqee banner. Re-run the filter. A second
   entry appears with every signal flipped to `granted`.

6. (Optional) In the **Network** tab, filter by `google-analytics.com`.
   Requests before Accept carry `gcs=G100` (denied). Requests after
   Accept carry `gcs=G111` (granted).

---

## Troubleshooting

### The banner doesn't appear

- Did you set the trigger to **Consent Initialization — All Pages**?
- Is your **Customer ID** correct? Copy it fresh from the Cooqee panel.
- Did you publish the GTM version (not just save)?

### Google tags fire before consent is updated

- Make sure every Google tag has **Advanced Settings → Consent Settings
  → Require additional consent for tag to fire** checked, with the right
  signals selected.
- Check that **Wait for update** on the Cooqee template is at least 500 ms.

### I use a custom CDN for Cooqee

- Expand the **Advanced** section and set **Banner script URL** to your
  self-hosted URL.
- You MUST also edit the template's `inject_script` permission to allow
  your origin — see the README for how to do this.

### The console shows `[cooqee] customer not found`

- The Customer ID you entered doesn't match any Cooqee account. Verify
  it in the Cooqee panel.

---

## Removing Cooqee from your container

1. **Tags** → find your Cooqee tag → open it → **Pause** (keeps the tag
   but doesn't fire it), or trash-can icon to delete.
2. If you're removing permanently, also delete the **Consent Initialization**
   trigger if nothing else uses it.
3. Submit + publish a new container version.
4. On your website, clear the `cooqee_*`, `euconsent-v2`, `addtl_consent`,
   and `gpp` cookies to remove any stored decisions.

---

## Need help?

- 📘 Full documentation: <https://cooqee.com.tr/docs/gtm>
- 📬 Email: [engineering@cooqee.com.tr](mailto:engineering@cooqee.com.tr)
