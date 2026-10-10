*** Settings ***
Library    taf.playwright.sbts    WITH NAME    sbts
Suite Teardown    sbts.close_all

*** Variables ***
${SBTS_URL}          %{SBTS_URL}
${SBTS_USERNAME}     %{SBTS_USERNAME}
${SBTS_PASSWORD}     %{SBTS_PASSWORD}
${SBTS_VERSION}      SBTS26R3
${BROWSER}           chromium
${HEADLESS}          True
${SCREENSHOT_DIR}    C:\\TA\\taf_doc\\playwright_smoke_screenshots
${TRACE_DIR}         C:\\TA\\taf_doc\\playwright_smoke_trace

*** Test Cases ***
Playwright SBTS Login Status Screenshot Logout Smoke
    ${login_msg}=    sbts.login
    ...    ${SBTS_URL}
    ...    ${SBTS_USERNAME}
    ...    ${SBTS_PASSWORD}
    ...    version=${SBTS_VERSION}
    ...    browser=${BROWSER}
    ...    headless=${HEADLESS}
    ...    screenshot_dir=${SCREENSHOT_DIR}
    ...    trace_dir=${TRACE_DIR}
    Log    ${login_msg}
    ${status}=    sbts.get_bts_status
    Log    ${status}
    ${screenshot}=    sbts.save_screenshot    sbts_smoke
    Log    ${screenshot}
    sbts.logout

Playwright SBTS Domain Navigation Smoke
    sbts.login
    ...    ${SBTS_URL}
    ...    ${SBTS_USERNAME}
    ...    ${SBTS_PASSWORD}
    ...    version=${SBTS_VERSION}
    ...    browser=${BROWSER}
    ...    headless=${HEADLESS}
    ...    screenshot_dir=${SCREENSHOT_DIR}
    sbts.go_to_configuration
    sbts.go_to_diagnostic
    sbts.go_to_software
    sbts.go_to_alarms
    sbts.go_to_performance
    sbts.logout
