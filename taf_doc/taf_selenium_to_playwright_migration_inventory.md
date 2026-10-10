# TAF Selenium To Playwright Migration Inventory

## Scope

This document tracks the migration from `C:\TA\site-packages\taf\selenium` to the new explicit Robot import namespace under `C:\TA\site-packages\taf\playwright`.

The migration keeps `taf.selenium` unchanged as the rollback baseline. New or migrated Robot suites should import Playwright libraries explicitly, for example:

```robotframework
*** Settings ***
Library    taf.playwright.sbts    WITH NAME    sbts
```

## Current Selenium Product Areas

| Selenium package | Migration target | Current status | Notes |
| --- | --- | --- | --- |
| `taf.selenium.core` | `taf.playwright.core` | In progress | Shared browser, page, wait, download, debug, session primitives. |
| `taf.selenium.sbts` | `taf.playwright.sbts` | Pilot | Existing Playwright skeleton covers login, logout, screenshot, alias list, BTS status. |
| `taf.selenium.sbts_fsm3` | `taf.playwright.sbts_fsm3` | Planned | Should reuse the SBTS migration template where possible. |
| `taf.selenium.sc` | `taf.playwright.sc` | Planned | Smaller vertical slice; good candidate after SBTS core stabilizes. |
| `taf.selenium.nms.nom` | `taf.playwright.nms.nom` | Planned | Small flat interface, useful for validating non-SBTS product shape. |
| `taf.selenium.mobile` | `taf.playwright.mobile` | Planned | Requires browser device profile support in `taf.playwright.core`. |
| `taf.selenium.gnb.oam.coam.classical` | `taf.playwright.gnb.oam.coam.classical` | Planned | Large facade/page-object stack similar to SBTS. |
| `taf.selenium.gnb.oam.coam.cu` | `taf.playwright.gnb.oam.coam.cu` | Planned | Should follow the classical COAM pattern after shared panel/navigation helpers exist. |
| `taf.selenium.gnb.oam.coam.vdu` | `taf.playwright.gnb.oam.coam.vdu` | Planned | Should follow the CU/classical migration template. |

## Shared Selenium Patterns To Rebuild

| Selenium concept | Playwright replacement |
| --- | --- |
| `CustomWebDriverChrome` / `CustomWebDriverFirefox` | `taf.playwright.core.browser.BrowserManager` with browser/context/page lifecycle. |
| `PagePart` / product `LocalBasicPage` | `taf.playwright.core.common.PlaywrightPagePart` plus thin product-specific page bases. |
| `DownloadChecker` / polling downloader | `taf.playwright.core.download.DownloadWatcher` using `expect_download` plus optional filesystem polling. |
| `catch_interface_exception` | `taf.playwright.core.debug.catch_interface_exception` with screenshot-on-failure. |
| `LookupHandler` implicit lookup | New `SessionStore` keeps explicit alias behavior; optional adapter can be added later if exact TAF alias integration is needed. |
| Version provider maps | Per-product `provider.py`, using the same release string parsing contract. |
| Facade domain composition | Per-product `facade.py`, preserving Robot keyword contract while replacing page internals. |

## First Migration Batch

The first batch is intentionally focused on stable smoke and reusable infrastructure:

1. `taf.playwright.core`
   - browser/session/page lifecycle
   - artifact directories
   - timeout and boolean conversion helpers
   - base page interactions
   - screenshot-on-error decorator
   - download watcher

2. `taf.playwright.sbts`
   - use `taf.playwright.core` instead of SBTS-private browser/session/base-page helpers
   - keep existing Robot keywords working
   - expand provider classes for Selenium SBTS release names
   - add placeholder domain facades for configuration, diagnostic, software, alarms, commissioning, performance, security, browser, procedures, rnd mode

3. Validation assets
   - pytest target list for core and SBTS smoke
   - Robot smoke example
   - real SBTS server handoff commands and expected results

## Coverage Table

| Area | Selenium baseline | Playwright implementation status |
| --- | --- | --- |
| Login/logout | Implemented in `taf.selenium.sbts` | Implemented in `taf.playwright.sbts`, with core extraction planned. |
| Screenshot/debug | Selenium debug page and decorators | Core screenshot/decorator to be added; SBTS `save_screenshot` already exists. |
| Alias sessions | `LookupHandler` store | `SessionStore`, explicit alias by name. |
| BTS status | Selenium page object supports product UI selectors | Minimal Playwright selector fallback exists; needs live UI validation. |
| Configuration | Full Selenium domain | Placeholder facade first, real keywords migrated by priority. |
| Diagnostic | Full Selenium domain | Placeholder facade first, real keywords migrated by priority. |
| Software | Full Selenium domain | Placeholder facade first, real keywords migrated by priority. |
| Alarms/performance/security/options | Full Selenium domains | Placeholder facade first, real keywords migrated by priority. |
| Commissioning | Selenium mix-in interface | Placeholder interface first, selected wizard keywords migrated later. |
| gNB/COAM | Full Selenium stacks | Namespace skeleton after SBTS core stabilizes. |

## Handoff Validation

Run these only on the target server after dependencies are prepared.

```powershell
python -m pytest C:\TA\site-packages\taf\playwright -q
```

Expected result: unit tests for core helpers and SBTS smoke pass.

Common failure modes:
- `ModuleNotFoundError: playwright`: install the Python Playwright package.
- Browser download failure: use an already installed browser channel or configure internal proxy before running `playwright install`.
- Selector timeout on real SBTS: capture screenshot and trace, then update page object selectors.

```powershell
robot C:\TA\taf_doc\playwright_sbts_smoke.robot
```

Expected result: login, BTS status read, screenshot, logout, and close all complete against a configured SBTS target.

Common failure modes:
- Missing Robot variables for SBTS URL or credentials.
- Login modal selector changed in the target SBTS version.
- Headless browser blocked by certificate or environment policy.
