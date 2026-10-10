# TAF Playwright Migration Validation Handoff

## Step 1: Static Unit Smoke

Command:

```powershell
python -m pytest C:\TA\site-packages\taf\playwright\tests -q
```

Expected result:
- `test_core_smoke.py` passes.
- `ArtifactManager`, `SessionStore`, and SBTS provider legacy version mappings work.

Common failure modes:
- `ModuleNotFoundError: taf`: run with `C:\TA\site-packages` on `PYTHONPATH`.
- `pytest` missing: install pytest in the target Python environment.

## Step 2: Playwright Runtime Preparation

Command:

```powershell
python -m pip install playwright
python -m playwright install chromium
```

Expected result:
- Playwright Python package is available.
- Chromium browser is installed or already available.

Common failure modes:
- Corporate network blocks browser download. Use an internal mirror, proxy, or an installed Chrome/Edge channel and pass `channel=chrome` or `channel=msedge` where supported.
- Server has no UI. Use `headless=True`.

## Step 3: SBTS Robot Smoke

Command:

```powershell
$env:SBTS_URL="https://<target-sbts-host>"
$env:SBTS_USERNAME="<username>"
$env:SBTS_PASSWORD="<password>"
robot C:\TA\taf_doc\playwright_sbts_smoke.robot
```

Expected result:
- SBTS login succeeds.
- `get_bts_status` returns a status text or the page title fallback.
- Screenshot and trace artifacts are created.
- Logout closes the browser session.

Common failure modes:
- Login selectors changed. Check screenshot in `C:\TA\taf_doc\playwright_smoke_screenshots`.
- Certificate issue. Keep `ignore_https_errors=True` on login.
- Menu labels differ by SBTS release. Update domain route labels in `taf.playwright.sbts.domains`.

## Step 4: COAM Classical Robot Smoke

Command:

```powershell
$env:COAM_URL="https://<target-coam-host>"
$env:COAM_USERNAME="<username>"
$env:COAM_PASSWORD="<password>"
robot C:\TA\taf_doc\playwright_coam_classical_smoke.robot
```

Expected result:
- COAM classical library imports as `taf.playwright.gnb.oam.coam.classical`.
- Login, configuration navigation, diagnostic navigation, screenshot, and logout execute.

Common failure modes:
- COAM login form has product-specific field names. Update `CoamFacade.login` selectors in `taf.playwright.gnb.oam.coam.common`.
- Navigation labels differ between classical/CU/VDU. Override `DEFAULT_CONFIGURATION_ROUTE` or `DEFAULT_DIAGNOSTIC_ROUTE` in the product `interface.py`.

## Step 5: Review Questions

- Which SBTS business domain should be migrated next: configuration, commissioning, diagnostic, software, alarms, or performance?
- Which real Robot suites should be used as the Selenium-vs-Playwright comparison baseline?
- Should COAM CU and VDU use the same login selectors as classical in the target environment?
