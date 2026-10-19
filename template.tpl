___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Cooqee CMP",
  "categories": ["CONSENT_MANAGEMENT"],
  "description": "Cooqee CMP - KVKK/GDPR consent manager. Sets Google Consent Mode v2 defaults to denied, loads the banner, and publishes consent via Consent Mode v2, IAB TCF v2.2, Google AC v2 and IAB GPP.",
  "containerContexts": ["WEB"]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "customerId",
    "displayName": "Customer ID",
    "simpleValueType": true,
    "valueValidators": [
      { "type": "NON_EMPTY" }
    ],
    "help": "Your Cooqee Customer ID. Find it in your Cooqee panel under Settings - API Keys."
  },
  {
    "type": "GROUP",
    "name": "consentDefaultsGroup",
    "displayName": "Google Consent Mode v2 - Defaults",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "SELECT",
        "name": "waitForUpdate",
        "displayName": "Wait for update (ms)",
        "macrosInSelect": false,
        "selectItems": [
          { "value": "0",    "displayValue": "0 - fire immediately" },
          { "value": "250",  "displayValue": "250 ms" },
          { "value": "500",  "displayValue": "500 ms (recommended)" },
          { "value": "1000", "displayValue": "1000 ms" },
          { "value": "2000", "displayValue": "2000 ms" }
        ],
        "simpleValueType": true,
        "defaultValue": "500",
        "help": "How long Google tags should wait for a consent update before firing. 500 ms is the Google-recommended default."
      },
      {
        "type": "CHECKBOX",
        "name": "urlPassthrough",
        "checkboxText": "Enable URL passthrough (recommended)",
        "simpleValueType": true,
        "defaultValue": true,
        "help": "When storage is denied, Google tags pass click identifiers via URL so attribution is not lost."
      },
      {
        "type": "CHECKBOX",
        "name": "adsDataRedaction",
        "checkboxText": "Enable ads data redaction (recommended)",
        "simpleValueType": true,
        "defaultValue": true,
        "help": "When ad_storage is denied, Google fully anonymises ad traffic. Required for GDPR."
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "bannerOptionsGroup",
    "displayName": "Banner Options",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "SELECT",
        "name": "language",
        "displayName": "Default language",
        "macrosInSelect": false,
        "selectItems": [
          { "value": "auto", "displayValue": "Auto-detect (browser language)" },
          { "value": "tr",   "displayValue": "Turkce" },
          { "value": "en",   "displayValue": "English" },
          { "value": "de",   "displayValue": "Deutsch" },
          { "value": "fr",   "displayValue": "Francais" },
          { "value": "ar",   "displayValue": "Arabic" }
        ],
        "simpleValueType": true,
        "defaultValue": "auto",
        "help": "Language the banner opens in on first visit."
      },
      {
        "type": "CHECKBOX",
        "name": "enableTcf",
        "checkboxText": "Enable IAB TCF v2.2 (for EEA/UK visitors)",
        "simpleValueType": true,
        "defaultValue": true,
        "help": "Publishes a full IAB TCF v2.2 TC String for EEA/UK visitors."
      },
      {
        "type": "CHECKBOX",
        "name": "enableAcV2",
        "checkboxText": "Enable Google Additional Consent (AC) v2",
        "simpleValueType": true,
        "defaultValue": true,
        "help": "Publishes AC v2 for Google Ad-Technology Providers not on the IAB list."
      },
      {
        "type": "CHECKBOX",
        "name": "enableGpp",
        "checkboxText": "Enable IAB GPP (for US visitors)",
        "simpleValueType": true,
        "defaultValue": true,
        "help": "Publishes an IAB Global Privacy Platform string for US visitors."
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "advancedGroup",
    "displayName": "Advanced",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "TEXT",
        "name": "scriptUrl",
        "displayName": "Banner script URL (override)",
        "simpleValueType": true,
        "defaultValue": "https://cooqee.com.tr/scripts/cooqee-banner.js",
        "help": "Only change this if you host the Cooqee banner from a custom CDN. Must be HTTPS and added to the inject_script permission below."
      },
      {
        "type": "CHECKBOX",
        "name": "debug",
        "checkboxText": "Debug mode (logs to console)",
        "simpleValueType": true,
        "defaultValue": false,
        "help": "Emits diagnostic logs to the browser console. Disable in production."
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const injectScript = require('injectScript');
const setDefaultConsentState = require('setDefaultConsentState');
const encodeUriComponent = require('encodeUriComponent');
const makeInteger = require('makeInteger');

const waitMs = data.waitForUpdate ? makeInteger(data.waitForUpdate) : 500;

setDefaultConsentState({
  ad_storage: 'denied',
  analytics_storage: 'denied',
  ad_user_data: 'denied',
  ad_personalization: 'denied',
  functionality_storage: 'denied',
  personalization_storage: 'denied',
  security_storage: 'granted',
  wait_for_update: waitMs
});

const scriptBase = data.scriptUrl || 'https://cooqee.com.tr/scripts/cooqee-banner.js';
let scriptSrc = scriptBase;
scriptSrc += (scriptBase.indexOf('?') === -1 ? '?' : '&') + 'cid=' + encodeUriComponent(data.customerId);
if (data.language && data.language !== 'auto') {
  scriptSrc += '&lang=' + encodeUriComponent(data.language);
}
if (data.enableTcf === false)  scriptSrc += '&tcf=0';
if (data.enableAcV2 === false) scriptSrc += '&ac=0';
if (data.enableGpp === false)  scriptSrc += '&gpp=0';
scriptSrc += '&src=gtm';

injectScript(scriptSrc, data.gtmOnSuccess, data.gtmOnFailure, 'cooqee-cmp');


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "inject_script",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              { "type": 1, "string": "https://cooqee.com.tr/*" },
              { "type": 1, "string": "https://cdn.cooqee.com.tr/*" }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_consent",
        "versionId": "1"
      },
      "param": [
        {
          "key": "consentTypes",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {"type": 1, "string": "consentType"},
                  {"type": 1, "string": "read"},
                  {"type": 1, "string": "write"}
                ],
                "mapValue": [
                  {"type": 1, "string": "ad_storage"},
                  {"type": 8, "boolean": false},
                  {"type": 8, "boolean": true}
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {"type": 1, "string": "consentType"},
                  {"type": 1, "string": "read"},
                  {"type": 1, "string": "write"}
                ],
                "mapValue": [
                  {"type": 1, "string": "analytics_storage"},
                  {"type": 8, "boolean": false},
                  {"type": 8, "boolean": true}
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {"type": 1, "string": "consentType"},
                  {"type": 1, "string": "read"},
                  {"type": 1, "string": "write"}
                ],
                "mapValue": [
                  {"type": 1, "string": "ad_user_data"},
                  {"type": 8, "boolean": false},
                  {"type": 8, "boolean": true}
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {"type": 1, "string": "consentType"},
                  {"type": 1, "string": "read"},
                  {"type": 1, "string": "write"}
                ],
                "mapValue": [
                  {"type": 1, "string": "ad_personalization"},
                  {"type": 8, "boolean": false},
                  {"type": 8, "boolean": true}
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {"type": 1, "string": "consentType"},
                  {"type": 1, "string": "read"},
                  {"type": 1, "string": "write"}
                ],
                "mapValue": [
                  {"type": 1, "string": "functionality_storage"},
                  {"type": 8, "boolean": false},
                  {"type": 8, "boolean": true}
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {"type": 1, "string": "consentType"},
                  {"type": 1, "string": "read"},
                  {"type": 1, "string": "write"}
                ],
                "mapValue": [
                  {"type": 1, "string": "personalization_storage"},
                  {"type": 8, "boolean": false},
                  {"type": 8, "boolean": true}
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {"type": 1, "string": "consentType"},
                  {"type": 1, "string": "read"},
                  {"type": 1, "string": "write"}
                ],
                "mapValue": [
                  {"type": 1, "string": "security_storage"},
                  {"type": 8, "boolean": false},
                  {"type": 8, "boolean": true}
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Cooqee CMP - Google Tag Manager Community Template
Created: 2026-10-19
Author: Cooqee Bilisim Teknolojileri
Website: https://cooqee.com.tr
Support: engineering@cooqee.com.tr
