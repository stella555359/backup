*** Settings ***
Documentation    TMO Automation for SISO without L3 call cases
...              Author: xiangsheng.chu@nokia-sbell.com
Suite Setup    UUF_Common_Suite_Setup
Test Teardown    robot_common_operations.Common Case Teardown
Suite Teardown    robot_common_operations.Common Suite Teardown
Force Tags    5G_SISO    SG_06     CA_VRF_HAZ4
...    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_common_keywords.robot

*** Variables ***
${Perform Special RU Reset with OAM KPI}         Perform Special RU Reset with OAM KPI
${Perform BBMOD From All RU Reset with OAM KPI}       Perform BBMOD From All RU Reset with OAM KPI
${Perform Lock Or Unlock Single Cell On Special RU with OAM KPI}       Perform Lock Or Unlock Single Cell On Special RU with OAM KPI
${Perform Block Or Unblock Single Cell On Special RU with OAM KPI}     Perform Block Or Unblock Single Cell On Special RU with OAM KPI
${Perform Reset with HWF deletion}         Perform Reset with HWF deletion
${Perform Block Or Unblock LTE Single Cell On Special RU with OAM KPI}   Perform Block Or Unblock LTE Single Cell On Special RU with OAM KPI
${Perform Lock Or Unlock LTE Single Cell On Special RU with OAM KPI}    Perform Lock Or Unlock LTE Single Cell On Special RU with OAM KPI
${Delta Commissioning With Site Reset Required with OAM KPI}     Delta Commissioning With Site Reset Required with OAM KPI
${Delta Commissioning With Online Parameter Modification with OAM KPI}   Delta Commissioning With Online Parameter Modification with OAM KPI
${SW_Upgrade_Rollback_with_OAM_KPI}      SW_Upgrade_Rollback_with_OAM_KPI
${Delta Commissioning With NR Rat Reset Required with OAM KPI}    Delta Commissioning With NR Rat Reset Required with OAM KPI
${Delta Commissioning With GSM Rat Reset Required with OAM KPI}    Delta Commissioning With GSM Rat Reset Required with OAM KPI
${local_node_attach_test_keyword}       local_node_attach_test_keyword
${Delta Commissioning With LTE Rat Reset Required with OAM KPI}       Delta Commissioning With LTE Rat Reset Required with OAM KPI
${Perform Block Or Unblock GSM Single Cell On Special RU with OAM KPI}   Perform Block Or Unblock GSM Single Cell On Special RU with OAM KPI
${enb_target_ver}
${enb_target_sw}       ${enb_target_ver}

*** Test Cases ***
[1]E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_WebUI
     [Tags]    T080_QC_upgrade    T073_QC_upgrade     T816_QC_upgrade
     [Setup]    TMO_Common_Case_Setup_OAM
     ${version_splitted}    Split String    ${package_version_1525-CA}    _
     ${tmp_gnb_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
     ${qc_id}     Set Variable If    '${tmp_gnb_version}'=='24R3'     850005
     ...                             '${tmp_gnb_version}'=='00'    35487
     ...                             '${tmp_gnb_version}'=='24R2'    834521
     Check Rollback is needed before sw upgrade
     Check TMO Gnb Ready And All Cell On Air
     Run    '/opt/btslog/btslog_launcher' stop_udplog
     Run Keyword And Continue On Failure    SW_Upgrade_Rollback_with_OAM_KPI      qc_id=${qc_id}    test_iteration=1
     Run    '/opt/btslog/btslog_launcher' start_udplog

[1]gNB_enb_SW_Upgrade_loops_with_WebUI_RFS_gNB_1st
    [Documentation]    Author:xiangsheng.chu@nokia-sbell.com
    ...                update with gnb/enb sw upgrade
    ...                enb only upgrade to SBTS24R1_ENB_0000_000452_000004
    [Tags]     not_needed
    [Setup]    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    gNB_enb_SW_Upgrade_loops_with_WebUI_RFS_Precondition
    Run    '/opt/btslog/btslog_launcher' stop_udplog
    FOR    ${i}    IN RANGE    ${1}
         Log To Console    ${\n}INFO:-- start to upgrade gnb/enb time_${i}--
         gNB_enb_SW_Upgrade_loops_with_WebUI_RFS
    END
    [Teardown]   Run Keywords    Run    '/opt/btslog/btslog_launcher' start_udplog    AND
    ...    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
    ...                          run keyword and ignore error    COAM Teardown gnb connections    AND
    ...                          run keyword and ignore error    Run Keyword If Test Failed    Collect Snapshot Log in gnb and enb
    ...                                                                                            timeout=${2400}

[1]gNB_enb_SW_Upgrade_loops_with_WebUI_RFS_LTE_1st
    [Tags]     not_needed
    [Setup]    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    ${whether_do_lte_first}    Set Variable    ${True}
    gNB_enb_SW_Upgrade_loops_with_WebUI_RFS_Precondition    whether_do_lte_first=${whether_do_lte_first}
    Run    '/opt/btslog/btslog_launcher' stop_udplog
    FOR    ${i}    IN RANGE    ${1}
         Log To Console    ${\n}INFO:-- start to upgrade gnb/enb time_${i}--
         gNB_enb_SW_Upgrade_loops_with_WebUI_RFS    whether_do_lte_first=${whether_do_lte_first}
    END
    [Teardown]   Run Keywords    Run    '/opt/btslog/btslog_launcher' start_udplog    AND
    ...    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
    ...                          run keyword and ignore error    COAM Teardown gnb connections    AND
    ...                          run keyword and ignore error    Run Keyword If Test Failed    Collect Snapshot Log in gnb and enb
    ...                                                                                            timeout=${2400}

[1]E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
     [Tags]    T080_QC    T073_QC    T816_QC    T283_QC
     [Setup]    TMO_Common_Case_Setup_OAM    swconfig_flag=special_flag
     TMO_common_keywords_part_two.Verify Test In Loop     should_be_reported=False
     ...                test_keyword=${Perform Reset with HWF deletion}
     ...                iteration_number=1
     [Teardown]     Run Keywords    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
     ...                            Run Keyword If Test Failed    Collect Snapshot Log in gnb and enb    timeout=${2400}    AND
     ...                            Backup And Delete Parameter Of Swconfig File    swconfig_modify=@{delete_flag}

[1]E2E_TL_Capacity_Module_Reset_with_OAM_KPI
     [Tags]    T080_QC    T813_QC     T073_QC   T816_QC
     [Setup]    TMO_Common_Case_Setup_OAM
     TMO_common_keywords_part_two.Verify Test In Loop     should_be_reported=False   test_keyword=${Perform BBMOD From All RU Reset with OAM KPI}
     ...                iteration_number=3
     [Teardown]     Run Keywords    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
     ...                            Run Keyword If Test Failed    Collect Snapshot Log in gnb and enb    timeout=${2400}

5603029_TOL_case_14_OAM_snapshot_collection
     [Tags]    T080_QC
     [Setup]    TMO_Common_Case_Setup_SISO
     Sleep    300s    Wait for error log disappear after cell onair!
     Get Syslog Start Time
     Check TMO Gnb Ready And All Cell On Air
     Sleep    180s
     Run Keyword And Continue On Failure    Find Syslog Errors During A Specific Period of Time
     ...    syslog_start_time=${SYSLOG_START_TIME}
     FOR    ${i}    IN RANGE    ${2}
         Log To Console    ${\n}INFO:-- start to do time_${i}--
         General_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot
     END

[2][1.0] 5603029_TOL_case_14_OAM_snapshot_collection
     [Tags]    T813_QC
     [Setup]    TMO_Common_Case_Setup_SISO
     Sleep    300s    Wait for error log disappear after cell onair!
     Get Syslog Start Time
     Check TMO Gnb Ready And All Cell On Air
     Sleep    180s
     Run Keyword And Continue On Failure    Find Syslog Errors During A Specific Period of Time
     ...    syslog_start_time=${SYSLOG_START_TIME}
     FOR    ${i}    IN RANGE    ${2}
         Log To Console    ${\n}INFO:-- start to do time_${i}--
         General_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot
     END

[3][1.0] 5603029_TOL_case_14_OAM_snapshot_collection
     [Tags]    T283_QC
     [Setup]    TMO_Common_Case_Setup_SISO
     Sleep    300s    Wait for error log disappear after cell onair!
     Get Syslog Start Time
     Check TMO Gnb Ready And All Cell On Air
     Sleep    180s
     Run Keyword And Continue On Failure    Find Syslog Errors During A Specific Period of Time
     ...    syslog_start_time=${SYSLOG_START_TIME}
     FOR    ${i}    IN RANGE    ${2}
         Log To Console    ${\n}INFO:-- start to do time_${i}--
         General_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot
     END

[4][1.0] 5603029_TOL_case_14_OAM_snapshot_collection
     [Tags]    T816_QC
     [Setup]    TMO_Common_Case_Setup_SISO
     Sleep    300s    Wait for error log disappear after cell onair!
     Get Syslog Start Time
     Check TMO Gnb Ready And All Cell On Air
     Sleep    180s
     Run Keyword And Continue On Failure    Find Syslog Errors During A Specific Period of Time
     ...    syslog_start_time=${SYSLOG_START_TIME}
     FOR    ${i}    IN RANGE    ${2}
         Log To Console    ${\n}INFO:-- start to do time_${i}--
         General_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot
     END


[5][1.0] 5603029_TOL_case_14_OAM_snapshot_collection
     [Tags]    T073_QC
     [Setup]    TMO_Common_Case_Setup_SISO
     Sleep    300s    Wait for error log disappear after cell onair!
     Get Syslog Start Time
     Check TMO Gnb Ready And All Cell On Air
     Sleep    180s
     Run Keyword And Continue On Failure    Find Syslog Errors During A Specific Period of Time
     ...    syslog_start_time=${SYSLOG_START_TIME}
     FOR    ${i}    IN RANGE    ${2}
         Log To Console    ${\n}INFO:-- start to do time_${i}--
         General_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot
     END

[6][1.0] 5603029_TOL_case_14_OAM_snapshot_collection
     [Tags]    T284_QC
     [Setup]    TMO_Common_Case_Setup_SISO
     Sleep    300s    Wait for error log disappear after cell onair!
     Get Syslog Start Time
     Check TMO Gnb Ready And All Cell On Air
     Sleep    180s
     Run Keyword And Continue On Failure    Find Syslog Errors During A Specific Period of Time
     ...    syslog_start_time=${SYSLOG_START_TIME}
     FOR    ${i}    IN RANGE    ${2}
         Log To Console    ${\n}INFO:-- start to do time_${i}--
         General_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot
     END

[1]5603146_E2E_TOL_all_cells_lock_unlock_modify_param
     [Documentation]    TL073: due to customer PR 03577610
     ...                step1: lock all nr cells in gnb
     ...                step2: unlock all nr cells in gnb
     ...                step3: modify parameters
     [Tags]    T813_SISO    T283_SISO    T816_SISO
     [Setup]    TMO_Common_Case_Setup_SISO
     Get Syslog Start Time
     run keyword and ignore error    COAM Teardown gnb connections
     Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl
     ${cell_list}    Get All Cell Id    cell_type=nr
     ${para_file_scellweight}    ${para_file_cell_locked}    ${para_file_cell_unlocked}    ${para_file_scellweight100}
     ...                         COAM Create Updated parameters Delta File    cell_list=${cell_list}
     FOR    ${i}    IN RANGE    ${3}
         Log to console    \nstep0: modify WeightForSCellSelection Parameters to 1!
         COAM perform scf delta commission     para_file=${para_file_scellweight}
         Log to console    \nstep1: lock all nr cells!
         COAM perform scf delta commission     para_file=${para_file_cell_locked}
         Log to console    step2: unlock all nr cells in gnb
         COAM perform scf delta commission     para_file=${para_file_cell_unlocked}
         Log to console    step3: modify WeightForSCellSelection parameters to 100
         COAM perform scf delta commission     para_file=${para_file_scellweight100}
     END
     ${syslog_inputfile}    Get latest modified syslog file and Compress File    syslog_start_time=${SYSLOG_START_TIME}
     ${output} = 	Run 	zgrep -a "type:RuntimeConfiguration]: procedure is being queued" ${syslog_inputfile}
     ${queue_length}    Get Length    ${output}
     Should Be Equal 	${queue_length}    ${0}    msg="procedure is being queued"

5603105_TOL_case_105_23R1_SA_UE_CHBW_modification
    [Tags]    T080_QC    T073_QC   T813_QC
    [Setup]    TMO_Common_Case_Setup_SISO    scf_name=${tl_prefix}_5603105.xml
    @{cell_list}    Create List     ${311}    ${312}   ${313}
    @{813_cell_list}    Create List     ${311}    ${312}
    ${cell_list_new}     Set Variable If   '${tl_prefix}'=='T813'    ${813_cell_list}    ${cell_list}
    Modify chBW And Related Parameters via WebUI     cell_list=${cell_list_new}     configuration_type=80MHz
    sleep     1min
    Check GNB On Air And Unexpect Alarm Should Not Exist
    Modify chBW And Related Parameters via WebUI     cell_list=${cell_list_new}     configuration_type=40MHz
    ...                                    bwpdn0_profile=184
    ...                                    bwpdn1_profile=203
    ...                                    cellchBW_value=40MHz
    ...                                    nrarfcn_value=514056
    ...                                    csirsPower_value=18
    ...                                    maxCsirsNumber_value=4
    ...                                    actMultipleDedicatedBWPs_value=true
    ...                                    actEnhMultipleDedicatedBWPs_value=false
    ...                                    actPowerSavingBWP_value=false
    ...                                    actDynPdcchTd_value=largestBWP
    ...                                    gscnOrSsPbchArfcn_value=6402
    ...                                    msg1FrequencyStart_value=9
    ...                                    reqMinNumPuschPrb_value=88
    ...                                    ssPbchBlockPower_value=12
    ...                                    pMax_value=28
    ...                                    cSRS_value=23
    ...                                    globalF0ForRs_value=514056
    sleep     1min
    Check GNB On Air And Unexpect Alarm Should Not Exist
