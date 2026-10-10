*** Settings ***
Library    taf.playwright.gnb.oam.coam.classical    WITH NAME    coam
Suite Teardown    coam.close_all

*** Variables ***
${COAM_URL}          %{COAM_URL}
${COAM_USERNAME}     %{COAM_USERNAME}
${COAM_PASSWORD}     %{COAM_PASSWORD}
${BROWSER}           chromium
${HEADLESS}          True
${SCREENSHOT_DIR}    C:\\TA\\taf_doc\\playwright_coam_smoke_screenshots
${TRACE_DIR}         C:\\TA\\taf_doc\\playwright_coam_smoke_trace

*** Test Cases ***
Playwright COAM Classical Smoke
    coam.login
    ...    ${COAM_URL}
    ...    ${COAM_USERNAME}
    ...    ${COAM_PASSWORD}
    ...    browser=${BROWSER}
    ...    headless=${HEADLESS}
    ...    screenshot_dir=${SCREENSHOT_DIR}
    ...    trace_dir=${TRACE_DIR}
    coam.go_to_configuration
    coam.go_to_diagnostic
    ${screenshot}=    coam.save_screenshot    coam_classical_smoke
    Log    ${screenshot}
    coam.logout
