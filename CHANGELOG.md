# Changelog

All notable changes to the Cooqee CMP GTM template.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] — 2026-10-19

### Added
- Initial release for submission to the Google Tag Manager Community
  Template Gallery.
- `Customer ID` field (required) linking the banner to a Cooqee account.
- `Google Consent Mode v2 — Defaults` group: `wait_for_update`,
  `url_passthrough`, `ads_data_redaction`.
- `Banner Options` group: default language, TCF v2.2 toggle, AC v2
  toggle, GPP toggle.
- `Advanced` group: custom script URL override, debug-mode logging.
- IAB TCF v2.2 `__tcfapi()` queueing stub installed before the banner
  script loads.
- Three built-in template tests covering the default-denied posture,
  script injection, and the failure path.

### Notes
- Requires GTM trigger type **Consent Initialization — All Pages** so
  the template fires before any Google tag with `wait_for_update`.
- Companion demo site at <https://demo.cooqee.com.tr> deployed by
  Cooqee for the Google CMP Partner Program audit.
