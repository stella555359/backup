*** Settings ***
Documentation     Practice testcase generated with UTE TAF MCP guidance.
...               MCP evidence:
...               - Library: taf.sbts.oam.coam.admin
...               - Preferred keywords: lock / unlock
...               - Deprecated cell-specific keywords: lock_cell / unlock_cell
...               - Target object type: NRCELL / NRCELLGRP distName
Library           taf.sbts.oam.coam.admin    WITH NAME    coam


*** Variables ***
${GNB_ID}                  0
${COAM_PORT}               3600
${COAM_ALIAS}              cOAM
${OPERATION_TIMEOUT}       300
${LOCK_UNLOCK_CYCLES}      30
@{CELL_DIST_NAMES}         /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1


*** Test Cases ***
SBTS Cells Lock Unlock Loop Stability
    [Documentation]    Repeatedly lock and unlock SBTS cells.
    ...                On each failed lock/unlock attempt, collect failure evidence before failing the testcase.
    [Tags]    sbts    coam    cell-admin    stability    mcp-practice
    Connect To SBTS COAM
    TRY
        FOR    ${cycle_index}    IN RANGE    ${LOCK_UNLOCK_CYCLES}
            ${cycle_number}=    Evaluate    ${cycle_index} + 1
            Log    Starting lock/unlock cycle ${cycle_number}/${LOCK_UNLOCK_CYCLES}
            FOR    ${cell_dist_name}    IN    @{CELL_DIST_NAMES}
                Lock Cell And Collect Evidence On Failure    ${cell_dist_name}    ${cycle_number}
                Unlock Cell And Collect Evidence On Failure    ${cell_dist_name}    ${cycle_number}
            END
        END
    FINALLY
        Disconnect From SBTS COAM
    END


*** Keywords ***
Connect To SBTS COAM
    [Documentation]    Connect to SBTS cOAM using testline gNB OAM HTTP connection details.
    coam.connect_to
    ...    bts_host=${tl.gnbs[${GNB_ID}].cu.oam_http_connection_details.addr}
    ...    bts_port=${COAM_PORT}
    ...    name=${COAM_ALIAS}

Disconnect From SBTS COAM
    [Documentation]    Always close cOAM connection at the end of the testcase.
    coam.teardown    connection=${COAM_ALIAS}

Lock Cell And Collect Evidence On Failure
    [Arguments]    ${cell_dist_name}    ${cycle_number}
    [Documentation]    Lock one NRCELL object. Collect failure evidence if the operation fails.
    ${status}    ${result}=    Run Keyword And Ignore Error
    ...    coam.lock
    ...    dist_name=${cell_dist_name}
    ...    timeout=${OPERATION_TIMEOUT}
    ...    connection=${COAM_ALIAS}
    IF    '${status}' == 'FAIL'
        Collect Failure Snapshot    lock    ${cell_dist_name}    ${cycle_number}    ${result}
        Fail    Failed to lock cell ${cell_dist_name} during cycle ${cycle_number}: ${result}
    END
    Log    Cell locked successfully: ${cell_dist_name}; response: ${result}
    Should Not Be Empty    ${result}

Unlock Cell And Collect Evidence On Failure
    [Arguments]    ${cell_dist_name}    ${cycle_number}
    [Documentation]    Unlock one NRCELL object. Collect failure evidence if the operation fails.
    ${status}    ${result}=    Run Keyword And Ignore Error
    ...    coam.unlock
    ...    dist_name=${cell_dist_name}
    ...    timeout=${OPERATION_TIMEOUT}
    ...    connection=${COAM_ALIAS}
    IF    '${status}' == 'FAIL'
        Collect Failure Snapshot    unlock    ${cell_dist_name}    ${cycle_number}    ${result}
        Fail    Failed to unlock cell ${cell_dist_name} during cycle ${cycle_number}: ${result}
    END
    Log    Cell unlocked successfully: ${cell_dist_name}; response: ${result}
    Should Not Be Empty    ${result}

Collect Failure Snapshot
    [Arguments]    ${operation}    ${cell_dist_name}    ${cycle_number}    ${error}
    [Documentation]    Project-specific evidence hook.
    ...                MCP found snapshot-related candidates such as taf.collectors.snapshot
    ...                and taf.selenium.sbts collect_snapshot, but the exact collector depends on
    ...                the lab setup and SBTS access method. Replace this placeholder with the
    ...                collector used by your target testline.
    Log    Snapshot hook triggered after ${operation} failure on ${cell_dist_name} during cycle ${cycle_number}.    level=WARN
    Log    Failure detail: ${error}    level=WARN
