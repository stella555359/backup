#*** Settings ***
#Documentation    Author: tingting.1.liu@nokia-sbell.com
#Suite Setup      UUF_Common_Suite_Setup   is_commission=${False}
#Suite Teardown    robot_common_operations.Common Suite Teardown
#Force Tags    5G_SISO    SG_06
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_common_keywords.robot
#
#*** Variables ***
#${bts_filter1}   CELL NOTIFICATION 4329 Radio memory consumption exceeds abnormal threshold
#${bts_filter2}   FaultId: 4329
#${bts_filter3}   FaultId: 4330
#${bts_filter4}   Detector 4329
#${bts_filter5}   Detector 4330
#${bts_filter6}   active 4329
#${bts_filter7}   active 4330
#${bts_filter8}   4230 Radio memory consumption exceeds critical threshold
#*** Test Cases ***
#[1]E2E_Reset_with_HWF_deletion
#    [Documentation]    author: tingting.1.liu@nokia-sbell.com
#    [Tags]    T073_QC    T816_QC    T813_QC    T080_QC
#    [Setup]    robot_common_operations.Common Case Setup
#    COAM Create log directory
#    ${swconfig_list}=   Create List   0x190030=0    0x4F0214=0
#    Modify Swconfig File   para_update=${swconfig_list}
#    run keyword and ignore error    COAM Teardown gnb connections
#    Wait Until Keyword Succeeds    1 min    5 sec   Connect to gnb coam via ssl
##        start btslog capture  name=btslog
#    coam.reset_site    wait_for_reconnection=${True}    connection=GNB_OAM
#    sleep   8min
#    ${gnb_status_status}   Run Keyword And Return Status   Check TMO Gnb Ready And All Cell On Air
#    Set Test Variable   ${gnb_status_status}
##        stop btslog and collect logs   status=FAIL
##        ${bts_log_path}=   set variable   ${TS_CASE_LOG_PATH}/btslog/syslog_files.tgz
##        Check Btslog After Reset   log_path=${bts_log_path}
#    Check Gnb Startup Log
#    Wait Until Keyword Succeeds    1 min    5 sec  Connect to gnb coam via ssl
#    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=@{GNB_ALLOWED_FAULT}
#    Run Keyword And Continue On Failure    Unexpect History Alarm Should Not Exist   allowed_faults=@{ALLOWED_HISTORY_FAULT}
#    FOR    ${enb_id}    IN RANGE    ${enb_length}
#        Connect to eNB via ssl   enb_index=${enb_id}    connection=enblte_${enb_id}
#        coam.reset_site    connection=enblte_0
#        sleep   5min
#        Wait until keyword succeeds    2 min    20 sec   Verify Enb All Cell On Air    enb_index=${enb_id}
#        Connect to eNB via ssl   enb_index=${enb_id}    connection=enblte_${enb_id}
#        Run Keyword And Continue On Failure
#        ...   Unexpect Alarm Should Not Exist   allowed_faults=@{GNB_ALLOWED_FAULT}  connection=enblte_${enb_id}
#        Run Keyword And Continue On Failure
#        ...  Unexpect History Alarm Should Not Exist  allowed_faults=@{ALLOWED_HISTORY_FAULT}   connection=enblte_${enb_id}
#    END
#    [Teardown]   Teardown GNB and ENB Connections