*** Settings ***
Documentation     Practice testcase generated with UTE TAF MCP guidance.
...               Goal: attach and detach UE against a specific SBTS cell while keeping one flow
...               reusable for different UE access types.
...               MCP evidence:
...               - Library facade: taf.ue
...               - Keywords: Require Ue, Attach Ue, Detach Ue, Log Ue Info
...               - Android supports starting_cell in Require Ue.
...               - iPhone / AT docs mark starting_cell as NOT SUPPORTED.
...               - taf.ue.proxy can support multiple access layers such as android, at,
...                 iphone, fastmile, mtk when the proxy is started with suitable config.
Library           taf.ue
Library           Collections


*** Variables ***
${TARGET_SBTS_CELL}       CELL_ALIAS_OR_EUTRAN_CELL_ID
${ATTACH_TIMEOUT}         60
${VALIDATION}             ${True}
${TOP_CMD_ONLY}           ${False}
@{UE_TYPES_TO_TEST}       android    iphone    at    fastmile
&{UE_ALIAS_BY_TYPE}       android=ANDROID_UE    iphone=IPHONE_UE    at=AT_UE    fastmile=FASTMILE_UE
&{UE_CAPABILITY_BY_TYPE}  android=ANDROID_UE_1    iphone=IPHONE_UE_1    at=AT_UE_1    fastmile=FASTMILE_UE_1


*** Test Cases ***
UE Attach Detach For Specific SBTS Cell With Multiple UE Types
    [Documentation]    Reserve a UE by type, attach it, log UE info, detach it, and collect evidence on failure.
    ...                Android is reserved with starting_cell. Other UE types are reserved by capability only
    ...                because MCP documentation marks starting_cell as unsupported for iPhone / AT.
    [Tags]    ue    attach    detach    sbts-cell    multi-ue-type    mcp-practice
    FOR    ${ue_type}    IN    @{UE_TYPES_TO_TEST}
        ${ue_alias}=    Get From Dictionary    ${UE_ALIAS_BY_TYPE}    ${ue_type}
        ${capabilities}=    Get From Dictionary    ${UE_CAPABILITY_BY_TYPE}    ${ue_type}
        Run UE Attach Detach Scenario    ${ue_type}    ${ue_alias}    ${capabilities}    ${TARGET_SBTS_CELL}
    END


*** Keywords ***
Run UE Attach Detach Scenario
    [Arguments]    ${ue_type}    ${ue_alias}    ${capabilities}    ${target_cell}
    [Documentation]    Full attach/detach lifecycle for one UE type.
    Log    Starting UE attach/detach scenario. type=${ue_type}, alias=${ue_alias}, capabilities=${capabilities}, target_cell=${target_cell}
    Reserve UE For Target Cell    ${ue_type}    ${ue_alias}    ${capabilities}    ${target_cell}
    TRY
        Attach UE And Collect Evidence On Failure    ${ue_type}    ${ue_alias}
        Log Ue Info    ${ue_alias}    ALL
        Detach UE And Collect Evidence On Failure    ${ue_type}    ${ue_alias}
    EXCEPT    AS    ${error}
        Collect UE Failure Evidence    ${ue_type}    ${ue_alias}    lifecycle    ${error}
        Fail    UE attach/detach scenario failed for ${ue_type}/${ue_alias}: ${error}
    END

Reserve UE For Target Cell
    [Arguments]    ${ue_type}    ${ue_alias}    ${capabilities}    ${target_cell}
    [Documentation]    Reserve a UE alias. Android supports starting_cell; other types may not.
    IF    '${ue_type}' == 'android'
        Require Ue    ue_alias=${ue_alias}    capabilities=${capabilities}    starting_cell=${target_cell}
    ELSE
        Log    starting_cell is not used for ${ue_type}; MCP docs mark it unsupported for some UE types.    level=WARN
        Require Ue    ue_alias=${ue_alias}    capabilities=${capabilities}
    END

Attach UE And Collect Evidence On Failure
    [Arguments]    ${ue_type}    ${ue_alias}
    [Documentation]    Attach UE. Android supports timeout/top_cmd_only; other types use common arguments.
    IF    '${ue_type}' == 'android'
        ${status}    ${result}=    Run Keyword And Ignore Error
        ...    Attach Ue
        ...    ue_alias=${ue_alias}
        ...    timeout=${ATTACH_TIMEOUT}
        ...    validation=${VALIDATION}
        ...    top_cmd_only=${TOP_CMD_ONLY}
    ELSE
        ${status}    ${result}=    Run Keyword And Ignore Error
        ...    Attach Ue
        ...    ue_alias=${ue_alias}
        ...    validation=${VALIDATION}
    END
    IF    '${status}' == 'FAIL'
        Collect UE Failure Evidence    ${ue_type}    ${ue_alias}    attach    ${result}
        Fail    Attach failed for ${ue_type}/${ue_alias}: ${result}
    END
    Log    Attach succeeded for ${ue_type}/${ue_alias}

Detach UE And Collect Evidence On Failure
    [Arguments]    ${ue_type}    ${ue_alias}
    [Documentation]    Detach UE. Android supports timeout/top_cmd_only; other types use common arguments.
    IF    '${ue_type}' == 'android'
        ${status}    ${result}=    Run Keyword And Ignore Error
        ...    Detach Ue
        ...    ue_alias=${ue_alias}
        ...    timeout=${ATTACH_TIMEOUT}
        ...    validation=${VALIDATION}
        ...    top_cmd_only=${TOP_CMD_ONLY}
    ELSE
        ${status}    ${result}=    Run Keyword And Ignore Error
        ...    Detach Ue
        ...    ue_alias=${ue_alias}
        ...    validation=${VALIDATION}
    END
    IF    '${status}' == 'FAIL'
        Collect UE Failure Evidence    ${ue_type}    ${ue_alias}    detach    ${result}
        Fail    Detach failed for ${ue_type}/${ue_alias}: ${result}
    END
    Log    Detach succeeded for ${ue_type}/${ue_alias}

Collect UE Failure Evidence
    [Arguments]    ${ue_type}    ${ue_alias}    ${phase}    ${error}
    [Documentation]    Project-specific UE evidence hook.
    ...                MCP docs recommend collecting robot.html, config file, ute_ue logs,
    ...                taf.ue.proxy logs, moler logs for taf.ue.at, proxy_mngr.log for
    ...                taf.ue.proxy.mngr, and logcat for Nokia Android Application issues.
    Log    UE evidence hook triggered. type=${ue_type}, alias=${ue_alias}, phase=${phase}    level=WARN
    Log    Failure detail: ${error}    level=WARN
    Run Keyword And Ignore Error    Log Ue Info    ${ue_alias}    ALL
