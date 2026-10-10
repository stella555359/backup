*** Settings ***
Documentation    TMO Automation for SISO without L3 call cases
...              Author: tingting.1.liu@nokia-sbell.com
Suite Setup    UUF_Common_Suite_Setup    is_commission=${True}
Test Teardown    robot_common_operations.Common Suite Teardown
Suite Teardown    robot_common_operations.Common Suite Teardown
Force Tags    5G_SISO    SG_06
...    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_common_keywords.robot

*** Test Cases ***
#5603028_TOL_case_13_SiSO_AEHC_RF_module_power_off_on
#     [Tags]    T813_OAM    T080_OAM    T073_OAM
#     [Setup]    TMO_Common_Case_Setup_SISO
#     FOR    ${i}    IN RANGE    ${3}
#         Perform Special RU Power Action    action=power_off
#         Verify Specific RU Should Be Power Action    action=power_off
#         Sleep    10 sec
#         Perform Special RU Power Action    action=power_on
#         Verify Specific RU Should Be Power Action    action=power_on
#         Check TMO Gnb Ready And All Cell On Air
#         Check ENB On Air And Unexpect Alarm Should Not Exist
#         Check GNB On Air And Unexpect Alarm Should Not Exist
#         Sleep    30 sec
#     END
#     [Teardown]    Run Keywords
#     ...    Run Keyword And Ignore Error    Run Keyword If Test Failed    Common_keywords.Collect Snapshot Log    timeout=${2400}
#     ...    AND    Run Keyword And Ignore Error    Run Keyword If Test Failed    Common_keywords.Collect Enb Snapshot Log    timeout=${2400}

5603019_TOL_22R1_SiSo_reset_GNB_Site
     [Tags]    T813_OAM     T283_OAM     T816_OAM   T080_OAM    T073_OAM
     [Setup]    TMO_Common_Case_Setup_SISO
     FOR    ${i}    IN RANGE    ${3}
         Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=GNB_OAM
         coam.reset_site    wait_for_reconnection=${True}    timeout=600    connection=GNB_OAM
         Sleep    60s
         Check TMO Gnb Ready And All Cell On Air
         Check ENB On Air And Unexpect Alarm Should Not Exist
         Check GNB On Air And Unexpect Alarm Should Not Exist
         sleep  10s
     END
     [Teardown]    Run Keywords
     ...    Run Keyword And Ignore Error    Run Keyword If Test Failed    Common_keywords.Collect Snapshot Log    timeout=${2400}
     ...    AND    Run Keyword And Ignore Error    Run Keyword If Test Failed    Common_keywords.Collect Enb Snapshot Log    timeout=${2400}

5603032_TOL_case_21_SiSo_Cell_lock_and_unlock_from_TDDLTE
     [Documentation]    author:lei.jia@nokia-sbell.com
     ...                2024.03.15: concurrent enb(TDDLTE) removed in configuration
     [Tags]    TA_Done_Case_Delete
     [Setup]    TMO_Common_Case_Setup_SISO
     FOR    ${i}    IN RANGE    ${3}
         Do All TDD-LTE Cells Action
         Verify All TDD-LTE Cells Should Be Locked
         Wait Gnb Ready And Cell On Air    timeout=20 min
         Wait until keyword succeeds    2 min    20 sec    Verify Gnb Type Cells Should Be Onair    cell_type=lte    cell_technology=FDD
         Wait until keyword succeeds    2 min    20 sec    Verify Gnb Type Cells Should Be Onair    cell_type=wcdma
         Wait until keyword succeeds    2 min    20 sec    Verify Gnb Type Cells Should Be Onair    cell_type=gsm
#        Run Keyword If    ${LTE_WHETHER_IN_GNB}    Wait For Expect Fault Present   faultId=${49}   timeout=600
         Do All TDD-LTE Cells Action    cell_action=unlocked
         sleep   30s
         Verify All TDD-LTE Cells Should Be Unlocked
         Check GNB On Air And Unexpect Alarm Should Not Exist
         Check ENB On Air And Unexpect Alarm Should Not Exist
         Sleep    30 sec
     END
     [Teardown]    Run Keywords      Run Keyword And Ignore Error     Do All TDD-LTE Cells Action    cell_action=unlocked
     ...    AND    Run Keyword And Ignore Error    Run Keyword If Test Failed    Common_keywords.Collect Snapshot Log    timeout=${2400}
     ...    AND    Run Keyword And Ignore Error    Run Keyword If Test Failed    Common_keywords.Collect Enb Snapshot Log    timeout=${2400}


5603080_TOL_22R1_15_SiSO_Block_unBlock_from_gNB
     [Documentation]    TL073: due to PR728031, hw issue for fault 1802
     [Tags]    T813_OAM    T283_OAM    T816_OAM    T080_OAM
     [Setup]    TMO_Common_Case_Setup_SISO
     FOR    ${i}    IN RANGE    ${3}
         ${enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
         Block RAT    enb_index=${enb_index}
         Wait Until Keyword Succeeds    2 min    5 sec    Verify RAT Should Be Blocked   enb_index=${enb_index}
         Sleep    30 sec
         Unblock RAT    enb_index=${enb_index}
         Check GNB On Air And Unexpect Alarm Should Not Exist
         Check ENB On Air And Unexpect Alarm Should Not Exist
         Sleep    30 sec
     END
     [Teardown]    Run Keywords      Run Keyword And Ignore Error     Unblock RAT    enb_index=${enb_index}
     ...    AND    Run Keyword And Ignore Error    Run Keyword If Test Failed    Common_keywords.Collect Snapshot Log    timeout=${2400}
     ...    AND    Run Keyword And Ignore Error    Run Keyword If Test Failed    Common_keywords.Collect Enb Snapshot Log    timeout=${2400}

5603027_TOL_case_12_SiSo_reset_GNBRAT
     [Tags]    T813_OAM     T283_OAM    T816_OAM    T080_OAM    T073_OAM
     [Setup]    TMO_Common_Case_Setup_SISO
     FOR    ${i}    IN RANGE    ${3}
         Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl
         coam.reset_rat     rat_type=NR    timeout=600    connection=GNB_OAM
         Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False}    Verify All Enbs Cell On Air
         Sleep    60s
         Check GNB On Air And Unexpect Alarm Should Not Exist
         Check ENB On Air And Unexpect Alarm Should Not Exist
         Sleep    30 sec
     END
     [Teardown]    Run Keywords
     ...    Run Keyword And Ignore Error    Run Keyword If Test Failed    Common_keywords.Collect Snapshot Log    timeout=${2400}
     ...    AND    Run Keyword And Ignore Error    Run Keyword If Test Failed    Common_keywords.Collect Enb Snapshot Log    timeout=${2400}

5603076_TOL_case_76_SISO_lock_unlock_BBMOD_wo_call
     [Tags]    T813_OAM    T283_OAM     T816_OAM    T080_OAM     T073_OAM
     [Setup]    TMO_Common_Case_Setup_SISO
     ${bbmod_distname_list}    Get BBMOD List For RU AEHC Or AZHL
     FOR    ${bbmod_distname}    IN    @{bbmod_distname_list}
         Wait Until Keyword Succeeds    2 min    20 sec    Connect to gnb coam via ssl    connection=GNB_OAM0
         ...                                                                              gnb_index=${0}
         Run Keyword And Ignore Error    coam.lock     dist_name=${bbmod_distname}     connection=GNB_OAM0    timeout=300s
         Run Keyword And Ignore Error    COAM Teardown gnb connections
     END
     sleep   30s
     FOR    ${bbmod_distname}    IN    @{bbmod_distname_list}
         Wait Until Keyword Succeeds    2 min    20 sec    Connect to gnb coam via ssl    connection=GNB_OAM0
         ...                                                                              gnb_index=${0}
         Run Keyword And Ignore Error    coam.unlock     dist_name=${bbmod_distname}     connection=GNB_OAM0    timeout=300s
         Run Keyword And Ignore Error    COAM Teardown gnb connections
     END
     Check GNB On Air And Unexpect Alarm Should Not Exist
     Check ENB On Air And Unexpect Alarm Should Not Exist
     [Teardown]    Run Keywords
     ...    Run Keyword And Ignore Error    Run Keyword If Test Failed    Common_keywords.Collect Snapshot Log    timeout=${2400}
     ...    AND    Run Keyword And Ignore Error    Run Keyword If Test Failed    Common_keywords.Collect Enb Snapshot Log    timeout=${2400}

#5603075_TOL_case_75_SISO_reset_BBMOD
#     [Documentation]    author:lei.jia@nokia-sbell.com
#     ...                2024.03.15: case replaced by "[1]E2E_TL_Capacity_Module_Reset_with_OAM_KPI"
#     [Tags]    TA_Done_Case_Delete
#     [Setup]    TMO_Common_Case_Setup_SISO
#     ${bbmod_distname_list}    Get BBMOD List For RU AEHC Or AZHL
#     FOR    ${bbmod_distname}    IN    @{bbmod_distname_list}
#         Wait Until Keyword Succeeds    2 min    20 sec    Connect to gnb coam via ssl    connection=GNB_OAM0
#         ...                                                                              gnb_index=${0}
#         coam.reset_unit    dist_name=${bbmod_distname}    reset_type=Warm    force_radio_reset=${True}
#         ...                timeout=${720}    connection=GNB_OAM0
#         Check GNB On Air And Unexpect Alarm Should Not Exist
#         Check ENB On Air And Unexpect Alarm Should Not Exist
#     END
#     [Teardown]    Run Keywords
#     ...    Run Keyword And Ignore Error    Run Keyword If Test Failed    Common_keywords.Collect Snapshot Log    timeout=${2400}
#     ...    AND    Run Keyword And Ignore Error    Run Keyword If Test Failed    Common_keywords.Collect Enb Snapshot Log    timeout=${2400}

5603037_TOL_case_32_Siso_all_RF_Module_Lock_and_unlock_from_gNB_wo_call
     [Documentation]    for cell lock unlock, will ignore faultId 7313 NgGnbInitPartialReset
     [Tags]    T813_OAM    T283_OAM    T816_OAM    T080_OAM    T073_OAM
     [Setup]    TMO_Common_Case_Setup_SISO
     &{fault_7313}     Create Dictionary     faultId=${7313}
     ${GNB_ALLOWED_FAULT}   Create List   @{GNB_ALLOWED_FAULT}   ${fault_7313}
     Set Test Variable    ${GNB_ALLOWED_FAULT}
     ${enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
     FOR    ${i}    IN RANGE    ${3}
         Do All RU Locked Or Unlocked On Gnb   ru_status=Locked    enb_index=${enb_index}
         sleep   1min
         Do All RU Locked Or Unlocked On Gnb   ru_status=Unlocked    enb_index=${enb_index}
         Check GNB On Air And Unexpect Alarm Should Not Exist
         Check ENB On Air And Unexpect Alarm Should Not Exist
     END
     [Teardown]    Run Keywords      Run Keyword And Ignore Error     Do All RU Locked Or Unlocked On Gnb   ru_status=Unlocked
     ...                                                              enb_index=${enb_index}
     ...    AND    Run Keyword And Ignore Error    Run Keyword If Test Failed    Common_keywords.Collect Snapshot Log    timeout=${2400}
     ...    AND    Run Keyword And Ignore Error    Run Keyword If Test Failed    Common_keywords.Collect Enb Snapshot Log    timeout=${2400}

5603036_TOL_case_31_Siso_all_RF_Module_reset_from_gNB_wo_call
     [Tags]    T813_OAM      T816_OAM     T283_OAM    T080_OAM    T073_OAM
     [Setup]    TMO_Common_Case_Setup_SISO
     ${enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
     FOR    ${i}    IN RANGE    ${3}
         Perform Special RU Reset   ru_type=all
         Check TMO Gnb Ready And All Cell On Air
         Check ENB On Air And Unexpect Alarm Should Not Exist
         Check GNB On Air And Unexpect Alarm Should Not Exist
     END
     [Teardown]    Run Keywords      Run Keyword And Ignore Error     Do All RU Locked Or Unlocked On Gnb   ru_status=Unlocked
     ...                                                              enb_index=${enb_index}
     ...    AND    Run Keyword And Ignore Error    Run Keyword If Test Failed    Common_keywords.Collect Snapshot Log    timeout=${2400}
     ...    AND    Run Keyword And Ignore Error    Run Keyword If Test Failed    Common_keywords.Collect Enb Snapshot Log    timeout=${2400}

5603078_TOL_case_78_SISO_Block_unBlock_cell_from_TDD_RF_reset_from_gNB_wo_call
     [Tags]    T283_OAM
     [Setup]    TMO_Common_Case_Setup_SISO
     ${enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=TDD
     Log To Console     ${\n}INFO: ---Step1: Get all nr and lte cells of one AEHC---
     ${aehc_nr_cell_list}    ${aehc_lte_cell_list}    Get All NR And LTE CellID List Of One Special RU    ru_index=0
     ...          ru_type=${tl.gnbs[${0}].dus[${0}].rus[0].radio_type}
     ${origin_aehc_nr_cell_list}    Copy List    ${aehc_nr_cell_list}
     ${origin_aehc_lte_cell_list}    Copy List    ${aehc_lte_cell_list}
     Log To Console     ${\n}INFO: ---Step2: Lock nrcell with Max id of one AEHC---
     ${nr_max_cell_id}    Remove From List    ${aehc_nr_cell_list}    -1
     Do Type Cell Action Then Verify Status And Alarm    cell_index=${nr_max_cell_id}    cell_action=locked    cell_type=nr
     Log To Console     ${\n}INFO: ---Step3: Reset GNB wait until gnb is up---gnb & ENB:no abnormal alarm---
     Perform BTS Site Reset
     Check All Cells Should Be On Air Except One Locked Cell    cell_id=${nr_max_cell_id}
     Check GNB On Air And Unexpect Alarm Should Not Exist    is_check_cell_onAir=${False}
     Check ENB On Air And Unexpect Alarm Should Not Exist
     Log To Console     ${\n}INFO: ---Step4: Lock nr-cell from high cellid to low cellid---
     Loop For Do Type Cell Action Then Verify Status And Alarm    cell_list=${aehc_nr_cell_list}    list_index=-1
     ...                                                          cell_action=locked    cell_type=nr
     Log To Console     ${\n}INFO: ---Step5: Unlock nr-cell from high cellid to low cellid---
     Loop For Do Type Cell Action Then Verify Status And Alarm    cell_list=${origin_aehc_nr_cell_list}    list_index=-1
     ...                                                          cell_action=unlocked    cell_type=nr
     Log To Console     ${\n}INFO: ---Step6: Lock lte-cell from low cellid to high cellid---
     Loop For Do Type Cell Action Then Verify Status And Alarm    cell_list=${aehc_lte_cell_list}    list_index=0
     ...                                                          cell_action=locked    cell_type=lte
     Log To Console     ${\n}INFO: ---Step7: Unlock lte-cell from low cellid to high cellid---
     Loop For Do Type Cell Action Then Verify Status And Alarm    cell_list=${origin_aehc_lte_cell_list}    list_index=0
     ...                                                          cell_action=unlocked    cell_type=lte
     [Teardown]    Run Keywords    Run Keyword If Test Failed    Do All Type Cells Lock Or Unlock    cell_action=unlocked    cell_type=nr
     ...    AND    Run Keyword If Test Failed    Do All Type Cells Lock Or Unlock    cell_action=unlocked    cell_type=lte    enb_index=${enb_index}

5603049_TOL_case_62_SISO_1UE_NSA_1UE_SA_Lock_AMF_reset_NR_waitX2up_unlock_AMF_1UE_NSA_1UE_SA_wo_call
     [Documentation]    author: tingting.1.liu@nokia-sbell.com
     [Tags]    T813_OAM     T080_OAM
     [Setup]    TMO_Common_Case_Setup_SISO
     ${ru_type}    Set Variable If
     ... 	      '${tl_prefix}'=='T813'    AHFIG
     ... 	      '${tl_prefix}'=='T080' 	AHFII
     ... 	      '${tl_prefix}'=='T073' 	AHFIB
     &{fault_7107}     Create Dictionary     faultId=${7107}
     ${GNB_ALLOWED_FAULT_AMF_LOCK}    Create List    @{GNB_ALLOWED_FAULT}    ${fault_7107}
     FOR    ${i}    IN RANGE    ${3}
         Log To Console    ${\n}INFO:-- ${i} time to lock unlock AMF --
         Update AMF Status   administrativeState=Locked
         ${enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
         Verify SERVEDAMF Status On GNB    administrativeState=Locked   ngLinkStatus=Inactive    expected_value=Locked    enb_index=${enb_index}
         ...    ru_type=${ru_type}    allowed_faults=${GNB_ALLOWED_FAULT_AMF_LOCK}
         Connect to gnb coam via ssl    connection=GNB_OAM
         coam.reset_site    wait_for_reconnection=${True}    timeout=600    connection=GNB_OAM
         sleep     60s
         Check All Cells Should Be On Air Except Special RU Related Cells     ru_type=${ru_type}
         Update AMF Status   administrativeState=Unlocked
         Verify SERVEDAMF Status On GNB    administrativeState=Unlocked   ngLinkStatus=Active    expected_value=Unlocked    enb_index=${enb_index}
         Check GNB On Air And Unexpect Alarm Should Not Exist
         Check ENB On Air And Unexpect Alarm Should Not Exist
     END
     [Teardown]  Run Keyword And Ignore Error    Update AMF Status    administrativeState=Unlocked

5603077_TOL_case_77_SISO_lock_unlock_NGLINK_wo_call
     [Documentation]    author: tingting.1.liu@nokia-sbell.com
     [Tags]    T816_OAM     T813_OAM     T283_OAM    T080_OAM     T073_OAM
     [Setup]    TMO_Common_Case_Setup_SISO
     ${ru_type}    Set Variable If
     ... 	      '${tl_prefix}'=='T813'    AHFIG
     ... 	      '${tl_prefix}'=='T080' 	AHFII
     ... 	      '${tl_prefix}'=='T073' 	AHFII
     ... 	      '${tl_prefix}'=='T816'    AHFII
     &{fault_7107}     Create Dictionary     faultId=${7107}
     ${GNB_ALLOWED_FAULT_AMF_LOCK}    Create List    @{GNB_ALLOWED_FAULT}    ${fault_7107}
     FOR    ${i}    IN RANGE    ${3}
         Log To Console    ${\n}INFO:-- ${i} time to lock unlock NGLINK --
         Lock Or Unlock NG Links In vCU  expected_value=Locked    ru_type=${ru_type}    allowed_faults=${GNB_ALLOWED_FAULT_AMF_LOCK}
         sleep   1min
         Lock Or Unlock NG Links In vCU  expected_value=Unlocked
         Check GNB On Air And Unexpect Alarm Should Not Exist
     END
     [Teardown]   Run Keyword And Ignore Error     Lock Or Unlock NG Links In vCU    expected_value=Unlocked

5603101_TOL_case_101_SISO_reset_FDD_related_BBMOD
     [Tags]    T816_OAM    T813_OAM    T283_OAM    T073_OAM
     [Setup]    TMO_Common_Case_Setup_SISO
     ${bbmod_distname_list}    Get BBMOD List For All FDD RU
     FOR    ${bbmod_distname}    IN    @{bbmod_distname_list}
         Wait Until Keyword Succeeds    2 min    20 sec    Connect to gnb coam via ssl    connection=GNB_OAM0
         ...                                                                              gnb_index=${0}
         Run Keyword And Ignore Error    coam.reset_unit    dist_name=${bbmod_distname}    reset_type=Warm    force_radio_reset=${True}
         ...                timeout=${720}    connection=GNB_OAM0
         Check GNB On Air And Unexpect Alarm Should Not Exist
         Check ENB On Air And Unexpect Alarm Should Not Exist
     END
     [Teardown]    Run Keywords
     ...    Run Keyword And Ignore Error    Run Keyword If Test Failed    Common_keywords.Collect Snapshot Log    timeout=${2400}
     ...    AND    Run Keyword And Ignore Error    Run Keyword If Test Failed    Common_keywords.Collect Enb Snapshot Log    timeout=${2400}

#5603103_TOL_case_103_SiSO_ecpri_RF_module_power_off_on_wo_call
#     [Documentation]    author: tingting.1.liu@nokia-sbell.com
#     [Tags]    T816_OAM
#     [Setup]    TMO_Common_Case_Setup_SISO
#     FOR    ${i}    IN RANGE    ${5}
#         Log To Console    ${\n}INFO:-- ${i} time to \test --
#         Perform Special RU Power Action    action=power_off     special_ru=AZHL
#         Verify Specific RU Should Be Power Action    action=power_off     ru_type=AZHL
#         Sleep    10 sec
#         Perform Special RU Power Action    action=power_on     special_ru=AZHL
#         Verify Specific RU Should Be Power Action    action=power_on      ru_type=AZHL
#         Check GNB On Air And Unexpect Alarm Should Not Exist
#     END
#     [Teardown]    Run Keyword And Ignore Error     Perform Special RU Power Action    action=power_on    special_ru=AZHL

#5603097_TOL_case_97_OAM_Site_Reset_downtime_KPI_1a
#     [Tags]    Release_branch_out
#     [Setup]    TMO_Common_Case_Setup_SISO
#     Case Status Init
#     Create Kpi Csv File
#     ${duration_time_list}    Create List
#     ${max}    Set Variable   ${930}
#     ${reset_time}    Set Variable   ${10}
#     FOR    ${i}    IN RANGE    ${reset_time}
#         Run Keyword And Ignore Error    Run    command=rm /tmp/btslog2/* -rf
#         Run Keyword And Ignore Error    Start To Collect Btslog    btslog_collector_name=btslog_${i+1}
#         ${res}    Run Keyword And Ignore Error    Loop For Site Reset Via WEBUI
#         ${reset_status}         Set Variable If    '${res[0]}'=='FAIL'      fail    ${res[1][0]}
#         ${duration_time_tmp}    Set Variable If    '${res[0]}'=='FAIL'      1800    ${res[1][1]}
#         Case Status Caluate    duration=${duration_time_tmp}    max=${max}
#         Run Keyword If   ${duration_time_tmp}<=${max}    Append To List    ${duration_time_list}    ${duration_time_tmp}
#         Log To Console     Case loop ${i+1} END
#         Append Case Result To File    index=${i+1}    target_value=${max}    result_value=${duration_time_tmp}
#         Run Keyword And Ignore Error    Stop Btslog Collection    btslog_collector_name=btslog_${i+1}
#         ${unexpect_alarm_should_not_exist}    Check Unexpect Alarm And Trunk Roll
#         Run Keyword If   ${unexpect_alarm_should_not_exist} and ${duration_time_tmp}>${max}
#         ...    Run Keyword And Ignore Error    Common_keywords.Collect Snapshot Log    timeout=${2400}
#         ...    ELSE    Sleep    2min
#     END
#     Case Status Finnal    duration_time_list=${duration_time_list}    target_value=${max}
#     [Teardown]    Run Keyword And Ignore Error    Copy File And Verify Whether Exist    source_file_path=${case_result_save_path}

#5603098_TOL_case_98_OAM_RU_Reset_downtime_KPI_51a
#     [Tags]    Release_branch_out
#     [Setup]    TMO_Common_Case_Setup_SISO
#     ${duration_time_list}    Create List
#     ${max}    Set Variable   ${780}
#     ${reset_time}    Set Variable   ${4}
#     Case Status Init
#     Create Kpi Csv File
#     ${rmod_distname_list}    Get RMOD List For Special RU
#     FOR    ${rmod_distname}    IN    @{rmod_distname_list}
#         ${ru_index}    Set Variable   ${rmod_distname.split('-')[-1]}
#         Make RU Reset With Retry    ru_index=${ru_index}    reset_time=${reset_time}    max=${max}
#         ...    duration_time_list=${duration_time_list}    timeout=${2400}
#     END
#     Case Status Finnal    duration_time_list=${duration_time_list}    target_value=${max}
#     [Teardown]    Run Keyword And Ignore Error    Copy File And Verify Whether Exist    source_file_path=${case_result_save_path}

5603139_TOL_case_139_SiSO_TDD_RF_module_power_off_on_wo_call
    [Documentation]    author: xiangsheng.chu@nokia-sbell.com
    [Tags]    T816_OAM    T080_OAM   T284_OAM   T813_OAM    T073_OAM
    [Setup]    TMO_Common_Case_Setup_SISO
    FOR    ${i}    IN RANGE    ${20}
         Log To Console    ${\n}INFO:-- ${i} time to test --
         Perform Special RU Power Action    action=power_off
         Verify Specific RU Should Be Power Action    action=power_off
         Sleep    10 sec
         Perform Special RU Power Action    action=power_on
         Verify Specific RU Should Be Power Action   action=power_on
         Check ENB On Air And Unexpect Alarm Should Not Exist
         Check GNB On Air And Unexpect Alarm Should Not Exist
         Sleep    30 sec
    END
    [Teardown]    Run Keywords    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
     ...    Run Keyword And Ignore Error    Run Keyword If Test Failed    Common_keywords.Collect Snapshot Log    timeout=${2400}    AND
     ...    Run Keyword And Ignore Error    Run Keyword If Test Failed    Common_keywords.Collect Enb Snapshot Log    timeout=${2400}    AND
     ...    Run Keyword And Ignore Error    Perform Special RU Power Action    action=power_on

5603086_TOL_case_86_CB006483_Trigger_Snapshot_on_eNB_when_LSS_unreachable
    [Documentation]    without call
    ...    In config.ini: need to  activate 'Monitoring_stop_with_file = stop_mon.log'
    [Tags]    T813_OAM
    [Setup]    TMO_Common_Case_Setup_SISO
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    Modify Lss IP Adsress Paremeters   enb_index=${fdd_enb_index}
    Check TMO Gnb Ready And All Cell On Air
    Set Test Variable    ${test_case_id}    ${TEST NAME.split('_')[0]}
    ${case_params}    Set Variable    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']}
    Set Test Variable    ${PCELL_INDEX}    ${case_params.get('pcell_idx')}
    Verify Whether FID10 Triggered On Enb   cell_index=${PCELL_INDEX}    enb_index=${fdd_enb_index}
    ${first_time_VmallocUsed_vlaue}   Execute Memory On ENB     enb_index=${fdd_enb_index}
    sleep   10min
    ${second_time_VmallocUsed_vlaue}   Execute Memory On ENB    enb_index=${fdd_enb_index}
    ${deviation_status}   Evaluate   int(${second_time_VmallocUsed_vlaue})-int(${first_time_VmallocUsed_vlaue}) <= ${1000}
    Should Be True    ${deviation_status}    msg=VmallocUsed deviation is more than 1000,memory maybe leak!
    [Teardown]   Run Keyword And Ignore Error      Modify Lss IP Adsress Paremeters   lssIPaddress=10.57.177.22
    ...                                   enb_index=${fdd_enb_index}

5603046_TOL_case_48_OAM_5G_Site_eCPRI_link_failure_Long_break_2_min_recovery
     [Documentation]    author: lei.jia@nokia-sbell.com
     ...     for T073, AEHC3 OPT1 use fiber switch port25&26, opt2: port27&28, opt3: port29&30, opt4: port31&32
     ...     step1: set all data cables link down, keep configuration cable on, check gnb is stll onair while some cells nok with alarms
     ...     step2: set all data cable link on, check all cells onair without alarms and faults
    [Tags]    T073_OAM    T816_OAM
    [Setup]    TMO_Common_Case_Setup_SISO
     Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
     Log To Console    \n\tSet Fiber Switch Into link_failure
     Set Test Variable    ${test_case_id}    ${TEST NAME.split('_')[0]}
     Set Test Variable    ${gnb_used_channel}
     ...                  ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']['5G_fiber_switch_channel']}
     ${ru_index}    Set Variable If
     ... 	      '${tl_prefix}'=='T073'    3
     ... 	      '${tl_prefix}'=='T816' 	1
     ${rmod_linkmode_list_info}    COAM get ru cable port number and linkmode type    ru_index=${ru_index}
     ${rmod_data_cables_used_channel}    Get fiber switch port for linkmode type data    ${rmod_linkmode_list_info}
     ${ru_index_in_init_file}    Set Variable If
     ... 	      '${tl_prefix}'=='T073'    2
     ... 	      '${tl_prefix}'=='T816' 	0
     Set Fiber Switch Into Link Failure Or Link Up   channel_numbers=${rmod_data_cables_used_channel}    link_status=down
     ...                                             ru_id=${ru_index_in_init_file}
     Log To Console    \n\tSet Fiber Switch link_failure_Long_break_2_min
     Sleep    3min
     COAM Check GNB cell on air
     Log To Console    \n\tSet Fiber Switch Into link_up
     Set Fiber Switch Into Link Failure Or Link Up    channel_numbers=${rmod_data_cables_used_channel}    link_status=up
     ...                                             ru_id=${ru_index_in_init_file}
     Sleep    1min
     Check TMO Gnb Ready And All Cell On Air
     [Teardown]         Set Fiber Switch Into Link Failure Or Link Up    channel_numbers=${rmod_data_cables_used_channel}    link_status=up
     ...                                             ru_id=${ru_index_in_init_file}