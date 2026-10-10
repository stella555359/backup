# TAF Playwright SBTS Domain Coverage

## Purpose

This document records which `taf.selenium.sbts` domains have an initial Playwright implementation in `taf.playwright.sbts`.

The Playwright package intentionally raises `SbtsFeatureNotMigrated` for Selenium keywords that are not implemented yet. This keeps failures explicit during Robot migration.

## Implemented Smoke Keywords

| Robot keyword | Playwright implementation | Notes |
| --- | --- | --- |
| `login` | `taf.playwright.sbts.interface.sbts.login` | Creates Playwright browser/context/page and stores alias. |
| `logout` | `taf.playwright.sbts.interface.sbts.logout` | Best-effort UI logout, optional browser close. |
| `get_bts_status` | `taf.playwright.sbts.pages.bts_status.BtsStatusPage` | Supports generic status selectors and optional `technology` named argument. |
| `save_screenshot` | `taf.playwright.sbts.facade.Sbts.save_screenshot` | Full-page screenshot to configured screenshot directory. |
| `close_all` | `taf.playwright.core.session.SessionStore.close_all` | Closes all stored Playwright sessions. |
| `list_aliases` | `taf.playwright.core.session.SessionStore.aliases` | Lists active aliases. |
| `login_with_offline_mode` | `taf.playwright.sbts.interface.sbts.login_with_offline_mode` | Opens local HTML through `file:///`. |

## Implemented Domain Navigation Templates

| Robot keyword | Domain | Current behavior |
| --- | --- | --- |
| `go_to_configuration` | `configuration` | Clicks `Configuration`. |
| `go_to_commissioning_tab` | `commissioning` | Clicks `Configuration > Configuration Management > Commissioning Wizard`, then target path items. |
| `go_to_diagnostic` | `diagnostic` | Clicks `Diagnostics`. |
| `go_to_software` | `software` | Clicks `Software`. |
| `go_to_alarms` | `alarms` | Clicks `Fault Management > Alarms`. |
| `go_to_performance` | `performance` | Clicks `Performance`. |

## Pending Domains

| Domain | Status | Migration note |
| --- | --- | --- |
| `configuration` | Navigation only | Port high-value parameter editor and commissioning wizard flows first. |
| `commissioning` | Navigation only | Port `set_bts_name`, `configure_system_module_configuration`, and submit/validate flows after real UI validation. |
| `diagnostic` | Navigation only | Port command execution and result collection once selectors are confirmed. |
| `software` | Navigation only | Port upload/download flows after download watcher is verified. |
| `alarms` | Navigation only | Port table reading with shared table helper. |
| `performance` | Navigation only | Port report generation/download flows after download watcher is verified. |
| `security`, `options`, `browser`, `procedures`, `rnd_mode` | Placeholder | Facade properties exist and raise `SbtsFeatureNotMigrated` for unmigrated keywords. |

## Validation Handoff

Run after setting SBTS target variables on the server:

```powershell
robot C:\TA\taf_doc\playwright_sbts_smoke.robot
```

Expected result:
- browser starts
- SBTS login succeeds
- status text or page title is returned
- screenshots are saved
- navigation keywords either reach the page or fail with a clear selector timeout and screenshot

Common failure modes:
- menu text differs from the current selector labels
- login modal text differs across SBTS release
- certificate or browser installation issues block Playwright startup
