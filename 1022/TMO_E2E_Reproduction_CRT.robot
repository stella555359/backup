*** Settings ***
Documentation    TMO Automation for SISO without L3 call cases
...              Author: xiangsheng.chu@nokia-sbell.com
#Suite Setup    UUF_Common_Suite_Setup    is_commission=${True}
#Suite Setup    TMO_Common_Suite_Setup    is_commission=${False}    whether_do_prepare_ue=${False}    turn_off_pa=${False}
#Test Teardown    robot_common_operations.Common Suite Teardown
#Suite Teardown    robot_common_operations.Common Suite Teardown
Force Tags    5G_SISO    SG_06     CA_VRF_HAZ4
...    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_KPI_Report_Case_Common.robot


*** Variables ***
${spark_ue_logpath}      C:/tmp/uelog/AUTO/${target_version}
${ReportName_ue_kpi}      C:/spark/UE_KPI.rpt
${ReportName_ue_DL_kpi}      C:/spark/UE_DL_KPI.rpt
${ReportName_ue_prach}      C:/spark/UE_prach.rpt
${qc_lab_path_trunk}    Root\\Test_Sets\\Trunk\\VRF_HAZ4\\VRF_HAZ4_T06
${qc_lab_path_SBTS24R3}    Root\\Test_Sets\\24R3\\Regression\\VRF_HAZ4\\VRF_HAZ4_T06
${qc_lab_path_SBTS24R2}    Root\\Test_Sets\\24R2_MP\\Regression\\VRF_HAZ4\\VRF_HAZ4_T06
${SAVE LOG DIRECTORY}      /tmp
${scell_add_fail}    adding UE failed
${Ue_group_full}    The UE group is full
${enb_target_ver}
${enb_target_sw}    ${enb_target_ver}

*** Test Cases ***
#5603153_E2E_Rep_001_all_TDD_cells_L3call_comparison_before_after_gNB_upgrade
#    [Documentation]    Author:lei.jia@nokia-sbell.com
#    ...                compare TDD L3 call tput before and after upgrade
#    ...                step1: make L3 call one by one on AEHC nr cells, and record tput result
#    ...                step2: perform sw upgrade
#    ...                step3: make L3 call one by one on AEHC nr cells, and record tput result
#    ...                step4: load new scf, make L3 call one by one on AEHC nr cells, and record tput result
#    ...                step5: compare tput
#    ...                EXECUTION TESTLINE: TL073
#    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
#    COAM Create log directory
#    # comment: aehc_pcell_scell_list}: [['301', 1, 21, 311], ['302', 2, 22, 312]]
#    @{aehc_pcell_scell_list}    create list
#    &{scell_pcell_mapping_dict}    Create Dictionary
#    ${ue_index}=    Set Variable    ${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
#    Check Rollback is needed before sw upgrade
#    ${stream_version_before_upgrade}    Common_setup_and_teardown.Get Active SW Version Based On Stream Version
#    Common_setup_and_teardown.Common Suite Setup    scf_name=${tl_prefix}_gNB_${stream_version_before_upgrade}.xml    is_commission=${True}
#    ...    timeout_for_commission=20 min
#    sleep  1min
#    Verify TMO Gnb Ready And All Cell On Air
#    ${aehc_nr_cell_list}    Get Cell List For Special RU    cell_type=nr
#    # comment: large_chbw_nrcells_list contains 100M AEHC cells id, for example 301/302/303
#    ${large_chbw_nrcells_list}    Get TDD large chbw cells    aehc_nr_cell_list=${aehc_nr_cell_list}
#    FOR    ${pcell_index}    IN    @{large_chbw_nrcells_list}
#        ${SCELL_INDEX_LIST}    Get scell and pcell mapping dict    pcell_index=${pcell_index}    scell_pcell_mapping_dict=${scell_pcell_mapping_dict}
#        ${PCELL_INDEX_LIST}    create list    ${pcell_index}
#        ${pcell_scell_list}    Combine Lists    ${PCELL_INDEX_LIST}     ${SCELL_INDEX_LIST}
#        Append To List    ${aehc_pcell_scell_list}    ${pcell_scell_list}
#    END
#    log to console    \n--- step1: start l3 call before upgrade---
#    ${btsName_before_upgrade}    ${gnb_version_before_upgrade}     Get BtsName and SwVersion
#    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False}    Verify All Enbs Cell On Air
#    Check Alarm and stop robot testing when unexpected alarm raised
#    Wait Until Keyword Succeeds    1 min    5 sec  Connect to gnb coam via ssl
#    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=@{GNB_ALLOWED_FAULT}
#    FOR    ${enb_index}    IN RANGE    ${enb_length}
#        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
#    END
#    ${timestamp_before_upgrade}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d-%H%M%S
#    Run Keyword If    'spark' in '${ue_type}'    Procedures.Start UE Prepare    ue_index=${ue_index}
#    ...                                          ue_type=${ue_type}    detach_request=${true}      power_reset=true
#    ${tput_before_upgrade}    Start L3 call and Record tput with aasyslog    cell_list=${large_chbw_nrcells_list}
#    ...    ue_index=${ue_index}    whether_do_ue_prepare=${True}
#    log to console    \n--- step2:  start to upgrade---
#    Gnb Upgrade Only
#    sleep  5min
#    Verify TMO Gnb Ready And All Cell On Air
#    ${btsName_after_upgrade}    ${gnb_version_after_upgrade}    Get BtsName and SwVersion
#    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False}    Verify All Enbs Cell On Air
#    Check Alarm and stop robot testing when unexpected alarm raised
#    Wait Until Keyword Succeeds    1 min    5 sec  Connect to gnb coam via ssl
#    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=@{GNB_ALLOWED_FAULT}
#    Run Keyword And Ignore Error    COAM Teardown gnb connections
#    Sleep    90sec
#    log to console    \n--- step3: start l3 call after upgrade---
#    ${timestamp_after_upgrade}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d-%H%M%S
#    ${tput_after_upgrade}     Start L3 call and Record tput with aasyslog    cell_list=${large_chbw_nrcells_list}
#    ...    ue_index=${ue_index}    whether_do_ue_prepare=${True}
#    log to console    \n--- step4: load scf correspoding to given version---
#    ${stream_version_after_upgrade}    Common_setup_and_teardown.Get Active SW Version Based On Stream Version
#    Common_setup_and_teardown.Common Suite Setup    scf_name=${tl_prefix}_gNB_${stream_version_after_upgrade}.xml    is_commission=${True}
#    ...    timeout_for_commission=20 min
#    Verify TMO Gnb Ready And All Cell On Air
#    Sleep    90sec
#    ${btsName_after_upgrade_load_scf}    ${gnb_version_after_upgrade_load_scf}    Get BtsName and SwVersion
#    ${stream_version_after_upgrade}    Common_setup_and_teardown.Get Active SW Version Based On Stream Version
#    Check Alarm and stop robot testing when unexpected alarm raised
#    Wait Until Keyword Succeeds    1 min    5 sec  Connect to gnb coam via ssl
#    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=@{GNB_ALLOWED_FAULT}
#    log to console    \n--- step4.2: start l3 call after load scf---
#    ${timestamp_after_upgrade_load_scf}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d-%H%M%S
#    ${tput_after_upgrade_with_new_scf}     Start L3 call and Record tput with aasyslog    cell_list=${large_chbw_nrcells_list}
#    ...    ue_index=${ue_index}    whether_do_ue_prepare=${True}
#    log to console    \n--- step5: comapre tput and generate tput report--
#    @{tput_results}=    Create List
#    @{tput_report_before_upgrade}=    Create List    ${timestamp_before_upgrade}
#    ...                                            ${gnb_version_before_upgrade}   ${btsName_before_upgrade}
#    @{tput_report_after_upgrade}=    Create List     ${timestamp_after_upgrade}
#    ...                                            ${gnb_version_after_upgrade}    ${btsName_after_upgrade}
#    @{tput_report_after_upgrade_load_scf}=    Create List    ${timestamp_after_upgrade_load_scf}
#    ...                                            ${gnb_version_after_upgrade_load_scf}    ${btsName_after_upgrade_load_scf}
#    @{tput_columns}=    Create List    StartTime    SwBuild    ScfName
#    FOR    ${cell_list}    IN    @{aehc_pcell_scell_list}
#        Get DL and UL tput for pcell and scell lists
#        ...            cell_list=${cell_list}
#        ...            tput_columns=${tput_columns}
#        ...            tput_report_before_upgrade=${tput_report_before_upgrade}
#        ...            tput_report_after_upgrade=${tput_report_after_upgrade}
#        ...            tput_report_after_upgrade_load_scf=${tput_report_after_upgrade_load_scf}
#        ...            scell_pcell_mapping_dict=${scell_pcell_mapping_dict}
#        ...            tput_before_upgrade=${tput_before_upgrade}
#        ...            tput_after_upgrade=${tput_after_upgrade}
#        ...            tput_after_upgrade_with_new_scf=${tput_after_upgrade_with_new_scf}
#    END
#    Append To List    ${tput_results}    ${tput_report_before_upgrade}
#    ...    ${tput_report_after_upgrade}    ${tput_report_after_upgrade_load_scf}
#    ${file_path}    set variable     /home/ute/KPI_report/${tl_prefix}_${stream_version_after_upgrade}_tput.xlsx
#    Log To Console    ${\n}Start to generate data report
#    KPI_report.Generate Data Report From Aasyslog    tput_data_list=${tput_results}
#    ...    header_list=${tput_columns}    file_path=${file_path}
#    [Teardown]    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${ue_index}

5603153_E2E_Rep_001_all_TDD_cells_L3call_comparison_before_after_gNB_upgrade
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                modify:stella.lin@nokia-sbell.com
    ...                compare TDD L3 call tput before and after upgrade
    ...                step1: make L3 call one by one on AEHC nr cells, and record tput result
    ...                step2: perform sw upgrade
    ...                step3: make L3 call one by one on AEHC nr cells, and record tput result
    ...                step4: load new scf, make L3 call one by one on AEHC nr cells, and record tput result
    ...                step5: compare tput
    ...                EXECUTION TESTLINE: TL073
    [Tags]     T073    T080
    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    # comment: aehc_pcell_scell_list}: [['301', 1, 21, 311], ['302', 2, 22, 312]]
    @{aehc_pcell_scell_list}    create list
    &{scell_pcell_mapping_dict}    Create Dictionary
    ${ue_index}=    Set Variable    ${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    ${aehc_nr_cell_list}    Get Cell List For Special RU    cell_type=nr
    # comment: large_chbw_nrcells_list contains 100M AEHC cells id, for example 301/302/303
    ${large_chbw_nrcells_list}    Get TDD large chbw cells    aehc_nr_cell_list=${aehc_nr_cell_list}
    FOR    ${pcell_index}    IN    @{large_chbw_nrcells_list}
        ${SCELL_INDEX_LIST}    Get scell and pcell mapping dict    pcell_index=${pcell_index}
        ...    scell_pcell_mapping_dict=${scell_pcell_mapping_dict}
        ${PCELL_INDEX_LIST}    create list    ${pcell_index}
        ${pcell_scell_list}    Combine Lists    ${PCELL_INDEX_LIST}     ${SCELL_INDEX_LIST}
        Append To List    ${aehc_pcell_scell_list}    ${pcell_scell_list}
    END
    Set Test Variable    ${ue_index}
    Set Test Variable    ${scell_pcell_mapping_dict}
    Set Test Variable    ${aehc_pcell_scell_list}
    Set Test Variable    ${large_chbw_nrcells_list}
    Procedures.Start UE Prepare    ue_index=${ue_index}    ue_type=${ue_type}
    #---- start test ----
    ${tput_active_build}    ${timestamp_active_build}    ${btsName_active_build}    ${gnb_version_active_build}
    ...    TestCase.Reproduce_5603153
    SetUp.Precondition For First gNB    is_commission=${True}    check_rollback_is_needed=${False}
    ${tput_with_scf}    ${timestamp_with_scf}    ${btsName_with_scf}    ${gnb_version_with_scf}    TestCase.Reproduce_5603153
    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB    is_commission=${True}    check_rollback_is_needed=${False}
    Check Rollback is needed before sw upgrade    active_sw_flag=Low
    ...                                           gnb_index=${0}
    ${tput_passive_build}    ${timestamp_passive_build}    ${btsName_passive_build}    ${gnb_version_passive_build}
    ...    TestCase.Reproduce_5603153
    log to console    \n--- step5: comapre tput and generate tput report--
    @{tput_results}=    Create List
    @{tput_report_before_upgrade}=    Create List    ${timestamp_passive_build}
    ...                                              ${gnb_version_passive_build}    ${btsName_passive_build}
    @{tput_report_after_upgrade}=    Create List     ${timestamp_active_build}
    ...                                              ${gnb_version_active_build}     ${btsName_active_build}
    @{tput_report_after_upgrade_load_scf}=    Create List    ${timestamp_with_scf}
    ...                                                      ${gnb_version_with_scf}     ${btsName_with_scf}
    @{tput_columns}=    Create List    StartTime    SwBuild    ScfName
    FOR    ${cell_list}    IN    @{aehc_pcell_scell_list}
        Get DL and UL tput for pcell and scell lists
        ...            cell_list=${cell_list}
        ...            tput_columns=${tput_columns}
        ...            tput_report_before_upgrade=${tput_report_before_upgrade}
        ...            tput_report_after_upgrade=${tput_report_after_upgrade}
        ...            tput_report_after_upgrade_load_scf=${tput_report_after_upgrade_load_scf}
        ...            scell_pcell_mapping_dict=${scell_pcell_mapping_dict}
        ...            tput_before_upgrade=${tput_passive_build}
        ...            tput_after_upgrade=${tput_active_build}
        ...            tput_after_upgrade_with_new_scf=${tput_with_scf}
    END
    Append To List    ${tput_results}    ${tput_report_before_upgrade}
    ...    ${tput_report_after_upgrade}    ${tput_report_after_upgrade_load_scf}
    ${file_path}    set variable     /home/ute/KPI_Report/Excel_KPI/${tl_prefix}_${gnb_version_active_build}_tput.xlsx
    Log To Console    ${\n}Start to generate data report
    KPI_report.Generate Data Report From Aasyslog    tput_data_list=${tput_results}
    ...    header_list=${tput_columns}    file_path=${file_path}
    Run Keyword And Ignore Error    combine_two_excel_result    first_excel=/home/ute/KPI_Report/KPI_5605001.xlsx    second_excel=${file_path}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${ue_index}    AND
    ...    SetUp.Precondition For First gNB    is_commission=${True}    check_rollback_is_needed=${False}    AND    csn.reset_cache


5605003_E2E_Rep_003_Inactive Scell Swap for 4CCs
    [Documentation]    Author:stella.lin@nokia-sbell.com
    ...                EXECUTION TESTLINE: TL073,TL080
    [Tags]     T080_QC    T073_QC
    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    Log to console    INFO:--start to config relation cells--
    Configure Relation Cells
    Backup and Modify swconfig file    swconfig_modify=@{wireshark_flag}
    Perform gNB Reset site and Wait Onair
    ${SCELL_INDEX_LIST}    Set Variable    ${case_params.get('scell_idx_list')}
    Set Test Variable    ${SCELL_INDEX_LIST}
    Set Case PA Or MCS Port Value    attenuator_list=${attenuator_list}    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    Log to console    INFO:--modify additional parameters based on TL
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[0].global_bts_id}
    ${drbInactivityTimerSA}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'drbInactivityTimerSA','value':'120'}
    ${sCellAdditionMethod}    catenate
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${PCELL_INDEX}/NRREL-${SCELL_MAPPING[${311}]['nrrel_id']}',
    ...    'parameter':'sCellAdditionMethod','value':'covBasedA1'},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${PCELL_INDEX}/NRREL-${SCELL_MAPPING[${311}]['nrrel_id']}',
    ...    'parameter':'actA4ToA1BasedSCellFallbackNsa','value':'false'}
    ${update_param}     Run Keyword If    '${stream_version}'=='master' and '${tl_prefix}'=='T073'
    ...     evaluate    [${drbInactivityTimerSA},${sCellAdditionMethod}]
    ...    ELSE    evaluate    [${drbInactivityTimerSA}]
    Update Params Through RestApi    params_need_to_modify=${update_param}    gnb_index=0
    # Step0_4:set LTE cell to barred status in order to make SA call
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${PCELL_INDEX}
    ...    connection=GNB_OAM    timeout=300
    # Step1: L3 call Process
    Run keyword if    '${ue_type}' == 'mtk'    MTK_common_keywords.Get UE Airmode status and Turnoff Airplane Mode
    ...               ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    Run Keyword And Continue On Failure    Run Keyword If    '${ue_type}'=='qct_dx50'
    ...    Procedures.Check network mode    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    Get Syslog Start Time
#    Run Keyword If    '${tl_prefix}'=='T073'    Procedures.Start UE Prepare    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
#    ...               ue_type=${ue_type}
#    ...    ELSE IF     '${tl_prefix}'=='T080'    Procedures.Start UE Prepare MTK80
#    ...    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}    ue_type=${ue_type}
    Procedures.Start UE Prepare    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}   ue_type=${ue_type}
    ...    get_spark_license=${False}
    log to console  INFO:--start T(301)+T(311)+F(1)+F(21) CA scell addition and activation success--
    ${attach_info}     Run Keyword And Continue On Failure    Procedures.Verify CA Basic L3 Call    dl_throughput=2800MKbits/sec
    ...                                                      ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    ...                                                      whether_check_on_air=${False}
    ...                                                      enb_index=${fdd_enb_index}
    ...                                                      whether_start_ul_call=${False}
    ...                                                      check_scell_tput_type=not_peak
    ...                                                      check_ul_pcell_tput_type=no_data
    ...                                                      check_pcell_tput_type=not_peak
    ...                                                      tput_collect_duration=60
    ...                                                      min_scell_percent=0
    ...                                                      min_DL_percent=0
    log to console  INFO:--start T(301)+T(311)+F(1)+F(21) CA scell deactivation (by reduce the data transfer amountt)--
    Run Keyword And Continue On Failure    Close the iperf process on APPserver
    ...    port=${tl.ues[${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}
    Sleep   5sec
    Run Keyword And Continue On Failure    Procedures.Start TMO L3 Call    cpif_log_path=${attach_info['cpif_log_path']}
    ...                                    dl_throughput=1MKbits/sec
    ...                                    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    ...                                    whether_start_ul_call=${False}
    Log to console    INFO:--start to check scell is deactivated--
    Run Keyword And Continue On Failure    Procedures.Check TMO Throughput
    ...    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    ...    addition_scell_index_list=${SCELL_INDEX_LIST}
    ...    check_scell_tput_type=no_data
    ...    check_ul_pcell_tput_type=no_data
    ...    check_pcell_tput_type=low_traffic
    ...    tput_collect_duration=90
    ...    min_scell_percent=0
    ...    min_DL_percent=0
    Run Keyword And Ignore Error     Recover Collect Syslog On Control PC
    log to console  INFO:--start T(301)+T(311)+F(1)+F(21) CA scell swap to T(301)+T(311)+F(1)+F(22)--
    ${source_swap_pa_value}    Set Variable If    '${tl_prefix}'=='T073'    25
    ...                                           '${tl_prefix}'=='T080'    40
    ${target_swap_pa_value}    Set Variable If    '${tl_prefix}'=='T073'    25
    ...                                           '${tl_prefix}'=='T080'    10
    Run Keyword And Continue On Failure    CA.Trigger A6 Scell Swap     ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    ...    rounds=10    source_swap_pa_value=${source_swap_pa_value}    target_swap_pa_value=${target_swap_pa_value}
    log to console  INFO:--check syslog: ERR/ctrlNrUlPucch::logIdPucchReq/0x62000200, Invalid number of PRBs: 0--
    ${error_file}    Run Keyword And Continue On Failure    Find Syslog Errors During A Specific Period of Time
    ...    syslog_start_time=${SYSLOG_START_TIME}
    ${status}    Run Keyword And Return Status   Find Syslog Errors During A Specific Period of Time
    ...    syslog_start_time=${SYSLOG_START_TIME}
    ${error_context}    Run Keyword If    '${status}'=='${False}'    OperatingSystem.Get File
    ...    path=${error_file}
    ${error_context}    Run Keyword If    '${status}'=='${False}'    String.Get Lines Containing String
    ...    string=${error_context}    pattern=ERR/ctrlNrUlPucch
    Run Keyword If    '${status}'=='${False}'    Should Be Empty        ${error_context}
    ...    msg=ERR/ctrlNrUlPucch exist.
    [Teardown]   Run Keywords     Run Keyword And Ignore Error     Save Current SCF And Save Snapshot    AND
    ...    Run Keyword And Continue On Failure    TMO_Common_Case_Teardown
    ...    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}    is_save_snapshot=${False}    AND
    ...    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB
    ...    is_commission=${True}    check_rollback_is_needed=${False}  AND
    ...    csn.reset_cache

5605004_E2E_Rep_004_ping service during Xn-HO intra-frequency mobility
    [Documentation]    Author:stella.lin@nokia-sbell.com
    ...       EXECUTION TESTLINE: TL080/TL282
    [Tags]     T080_QC
    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    is_second_gnb_used=${True}    ue_index=${4}
    ${used_ue_index}    Set Variable If    '${tl_prefix}'=='T073'    ${1}
    ...                                    '${tl_prefix}'=='T080'    ${4}
    set test variable    ${used_ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${used_ue_index}
    Set Test Variable    ${ue_type}
    ${report_timestamps_target_build}    KPI_Report_Case.Test Procedures
    ...                                  case_test_procedure_kw=TestCase.Reproduce_5605004
    ...                                  gnb_index=${0}
    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB   is_commission=${True}
    ...    check_rollback_is_needed=${False}
    Run Keyword And Continue On Failure    SetUp.Precondition For Second gNB   is_commission=${True}
    ...    check_rollback_is_needed=${False}
    ${reproduce_kpi_info_target_build}    Run Keyword And Continue On Failure
    ...    Generate And Record Reproduce KPI Report To Compass And UTE
    ...    report_timestamps=${report_timestamps_target_build}
    ...    comments=5605004
    ...    filter_distnames=bts,NRCELL-301
    ...    gnb_index=${0}
    ...    group_name=PR03773570
    ${total_kpi_info_target_build}    Run Keyword And Continue On Failure
    ...    Generate And Record Total KPI Report To Compass And UTE
    ...    report_timestamps=${report_timestamps_target_build}
    ...    comments=5605004
    ...    filter_distnames=bts,NRCELL-301
    ...    gnb_index=${0}
    ${NR_5057e_target}    Set Variable    ${reproduce_kpi_info_target_build['reproduce_kpi_values'][0]['NR_5057e']}
    ${NR_5057e_target}    Convert To Number    ${NR_5057e_target}
    Run Keyword And Continue On Failure    Should Be True    ${NR_5057e_target}>=${1.5}
    ...    msg=NR_5057e is more than 1.5 in avtive build.value is ${NR_5057e_target}
    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${used_ue_index}
    Check Rollback is needed before sw upgrade    active_sw_flag=Low
    ...                                           gnb_index=${0}
    Check Rollback is needed before sw upgrade    active_sw_flag=Low
    ...                                           gnb_index=${1}
    ${report_timestamps_source_build}    KPI_Report_Case.Test Procedures
    ...                                  case_test_procedure_kw=TestCase.Reproduce_5605004
    ...                                  gnb_index=${0}
    ${reproduce_kpi_info_source_build}    Run Keyword And Continue On Failure
    ...    Generate And Record Reproduce KPI Report To Compass And UTE
    ...    report_timestamps=${report_timestamps_source_build}
    ...    comments=5605004
    ...    filter_distnames=bts,NRCELL-301
    ...    gnb_index=${0}
    ...    group_name=PR03773570
    ${total_kpi_info_source_build}    Run Keyword And Continue On Failure
    ...    Generate And Record Total KPI Report To Compass And UTE
    ...    report_timestamps=${report_timestamps_source_build}
    ...    comments=5605004
    ...    filter_distnames=bts,NRCELL-301
    ...    gnb_index=${0}
    #------record active and passive swbuild test kpi data together to automation testcase log path---------------#
    ${total_test_kpi_result}    Create List    ${total_kpi_info_target_build}    ${total_kpi_info_source_build}
    ${reproduce_test_kpi_result}    Create List    ${reproduce_kpi_info_target_build}    ${reproduce_kpi_info_source_build}
    ${total_test_kpi_result}    Evaluate    [x for x in ${total_test_kpi_result} if x is not ${None}]
    ${reproduce_test_kpi_result}    Evaluate    [x for x in ${reproduce_test_kpi_result} if x is not ${None}]
    Run Keyword And Continue On Failure    Record KPI Data To TestCase Path
    ...                                    kpi_info_list=${total_test_kpi_result}
    ...                                    output_report_name=total_kpi_result.xlsx
    ...                                    filter_distnames=NRCELL-301,bts
    Record KPI Data To TestCase Path    kpi_info_list=${reproduce_test_kpi_result}
    ...                                 output_report_name=reproduce_kpi_result.xlsx
    ...                                 filter_distnames=NRCELL-301,bts
    ...                                 group_name=PR03773570
    ${NR_5057e_source}    Set Variable    ${reproduce_kpi_info_source_build['reproduce_kpi_values'][0]['NR_5057e']}
    ${NR_5057e_source}    Convert To Number    ${NR_5057e_source}
    Run Keyword And Continue On Failure    Should Be True    ${NR_5057e_source}>=${1.5}
    ...    msg=NR_5057e is more than 1.5 in passive build.value is ${NR_5057e_source}
    [Teardown]    Run Keywords  TMO_Common_Case_Teardown    ue_index=${used_ue_index}    is_save_snapshot=${False}    AND
    ...    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB   is_commission=${True}
    ...    check_rollback_is_needed=${False}    AND
    ...    Run Keyword And Continue On Failure    SetUp.Precondition For Second gNB   is_commission=${True}
    ...    check_rollback_is_needed=${False}    AND   csn.reset_cache

5605002_E2E_Rep_002_Multi-Ues for long time buffer based Scell addtion
    [Documentation]    Author:stella.lin@nokia-sbell.com
    [Tags]     T080    T073   T284
    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
    ${report_timestamps_target_build}    KPI_Report_Case.Test Procedures
    ...                                  case_test_procedure_kw=TestCase.Reproduce_5605002
    #----Check Error Log in syslog
    ${error_file}    Run Keyword And Continue On Failure    Find Syslog Errors During A Specific Period of Time
    ...    syslog_start_time=${SYSLOG_START_TIME}
    ${error_context}    Run Keyword And Continue On Failure    OperatingSystem.Get File    path=${error_file}
    ${error_ue_context}    Run Keyword And Continue On Failure    String.Get Lines Containing String
    ...    string=${error_context}    pattern=adding UE failed
    ${error_uegroup_context}    Run Keyword And Continue On Failure    String.Get Lines Containing String
    ...    string=${error_context}    pattern=UE group is full
    Run Keyword And Continue On Failure    Should Be Empty    ${error_ue_context}    msg=ERR/adding UE failed exist.
    Run Keyword And Continue On Failure    Should Be Empty    ${error_uegroup_context}    msg=ERR/UE group is full exist.
    Run Keyword And Continue On Failure    Run Keyword If     '${FAIL_TIME}'>='${15}'    fail
    ...    msg=FAIL TIMES FOR 1600 TEST IS: ${FAIL_TIME}
    #---record kpi result----
    ${filter_distnames}    Set Variable If    '${tl_prefix}'=='T073'    NRCELL-301,bts
    ...                                       '${tl_prefix}'=='T080'    NRCELL-303,bts
    ...                                       '${tl_prefix}'=='T284'    NRCELL-301,bts
    ${total_kpi_info_target_build}    Run Keyword And Continue On Failure
    ...    Generate And Record Total KPI Report To Compass And UTE
    ...    report_timestamps=${report_timestamps_target_build}
    ...    comments=5605002
    ...    filter_distnames=${filter_distnames}
    ...    gnb_index=${0}
    ${total_test_kpi_result}    Create List    ${total_kpi_info_target_build}
    ${total_test_kpi_result}    Evaluate    [x for x in ${total_test_kpi_result} if x is not ${None}]
    Record KPI Data To TestCase Path    kpi_info_list=${total_test_kpi_result}
    ...                                 output_report_name=total_kpi_result.xlsx
    ...                                 filter_distnames=${filter_distnames}
    [Teardown]   Run Keywords    TMO_Common_Case_Teardown    ue_index=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}    AND
    ...    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB   is_commission=${True}
    ...    check_rollback_is_needed=${False}    AND    csn.reset_cache

#5605005_E2E_Rep_005_Concurrent PS-BWP swtich and scell addtion
#    [Documentation]    Author:stella.lin@nokia-sbell.com
#    ...       EXECUTION TESTLINE: TL073,TL284,TL282
#    [Tags]     T080    T073   T284
#    [Setup]    RepCase_5605005_CaseSetUp
#    #---------------Precondition---------------------------------------#
#    ${used_gnb_index}   Set Variable If    '${tl_prefix}'=='T073'    ${0}
#    ...                                    '${tl_prefix}'=='T080'    ${1}
#    ...                                    '${tl_prefix}'=='T284'    ${0}
#    Set Test Variable    ${used_gnb_index}
#    Reproduce_5605005.PA Value Setting
#    #------test in active build: generate and record kpi data to compass and UTE PC---------------#
#    ${report_timestamps_target_build}    KPI_Report_Case.Test Procedures
#    ...                                  case_test_procedure_kw=TestCase.Reproduce_5605005
#    ...                                  rounds=1
#    ...                                  gnb_index=${used_gnb_index}
#    ${reproduce_kpi_info_target_build}    Run Keyword And Continue On Failure
#    ...    Generate And Record Reproduce KPI Report To Compass And UTE
#    ...    report_timestamps=${report_timestamps_target_build}
#    ...    comments=5605005
#    ...    filter_distnames=bts,NRCELL-301
#    ...    gnb_index=${used_gnb_index}
#    ...    group_name=PR03841043
#    ${total_kpi_info_target_build}    Run Keyword And Continue On Failure
#    ...    Generate And Record Total KPI Report To Compass And UTE
#    ...    report_timestamps=${report_timestamps_target_build}
#    ...    comments=5605005
#    ...    filter_distnames=bts,NRCELL-301
#    #------record active and passive swbuild test kpi data together to automation testcase log path---------------#
#    ${total_test_kpi_result}    Create List    ${total_kpi_info_target_build}
#    ${reproduce_test_kpi_result}    Create List    ${reproduce_kpi_info_target_build}
#    ${total_test_kpi_result}    Evaluate    [x for x in ${total_test_kpi_result} if x is not ${None}]
#    ${reproduce_test_kpi_result}    Evaluate    [x for x in ${reproduce_test_kpi_result} if x is not ${None}]
#    Run Keyword And Continue On Failure    Record KPI Data To TestCase Path
#    ...                                    kpi_info_list=${total_test_kpi_result}
#    ...                                    output_report_name=total_kpi_result.xlsx
#    ...                                    filter_distnames=NRCELL-301,bts
#    Record KPI Data To TestCase Path    kpi_info_list=${reproduce_test_kpi_result}
#    ...                                 output_report_name=reproduce_kpi_result.xlsx
#    ...                                 filter_distnames=NRCELL-301,bts
#    ...                                 group_name=PR03841043
#    [Teardown]    Run Keywords    Run Keyword And Continue On Failure    RepCase_5605005_CaseTeardown    AND
#    ...    TMO_Common_Case_Teardown    ue_index=${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}
#    ...    is_save_snapshot=${False}   AND    csn.reset_cache

5605005_E2E_Rep_005_Concurrent PS-BWP swtich and scell addtion
    [Documentation]    Author:stella.lin@nokia-sbell.com
    ...       EXECUTION TESTLINE: TL073,TL284,TL282
    [Tags]     T080    T073   T284
    [Setup]    RepCase_5605005_CaseSetUp
    #---------------Precondition---------------------------------------#
    ${used_gnb_index}   Set Variable If    '${tl_prefix}'=='T073'    ${0}
    ...                                    '${tl_prefix}'=='T080'    ${1}
    ...                                    '${tl_prefix}'=='T284'    ${0}
    Set Test Variable    ${used_gnb_index}
    Reproduce_5605005.PA Value Setting
    #------test in active build: generate and record kpi data to compass and UTE PC---------------#
    ${report_timestamps_target_build}    KPI_Report_Case.Test Procedures
    ...                                  case_test_procedure_kw=TestCase.Reproduce_5605005
    ...                                  gnb_index=${used_gnb_index}
    ${reproduce_kpi_info_target_build}    Run Keyword And Continue On Failure
    ...    Generate And Record Reproduce KPI Report To Compass And UTE
    ...    report_timestamps=${report_timestamps_target_build}
    ...    comments=5605005
    ...    filter_distnames=bts,NRCELL-301
    ...    gnb_index=${used_gnb_index}
    ...    group_name=PR03841043
    ${total_kpi_info_target_build}    Run Keyword And Continue On Failure
    ...    Generate And Record Total KPI Report To Compass And UTE
    ...    report_timestamps=${report_timestamps_target_build}
    ...    comments=5605005
    ...    filter_distnames=bts,NRCELL-301
    ...    gnb_index=${used_gnb_index}
    Run Keyword And Continue On Failure    RepCase_5605005_CaseTeardown
    #------test in passive sw build: rollback sw build, generate and record kpi data to compass and UTE PC------------#
    Check Rollback is needed before sw upgrade    active_sw_flag=Low
    ...                                           gnb_index=${used_gnb_index}
    RepCase_5605005_rollback_commission
    ${report_timestamps_source_build}    KPI_Report_Case.Test Procedures
    ...                                  case_test_procedure_kw=TestCase.Reproduce_5605005
    ...                                  gnb_index=${used_gnb_index}
    ${reproduce_kpi_info_source_build}    Run Keyword And Continue On Failure
    ...    Generate And Record Reproduce KPI Report To Compass And UTE
    ...    report_timestamps=${report_timestamps_source_build}
    ...    comments=5605005
    ...    filter_distnames=bts,NRCELL-301
    ...    gnb_index=${used_gnb_index}
    ...    group_name=PR03841043
    ${total_kpi_info_source_build}    Run Keyword And Continue On Failure
    ...    Generate And Record Total KPI Report To Compass And UTE
    ...    report_timestamps=${report_timestamps_source_build}
    ...    comments=5605005
    ...    filter_distnames=bts,NRCELL-301
    ...    gnb_index=${used_gnb_index}
    #------record active and passive swbuild test kpi data together to automation testcase log path---------------#
    ${total_test_kpi_result}    Create List    ${total_kpi_info_target_build}    ${total_kpi_info_source_build}
    ${reproduce_test_kpi_result}    Create List    ${reproduce_kpi_info_target_build}    ${reproduce_kpi_info_source_build}
    ${total_test_kpi_result}    Evaluate    [x for x in ${total_test_kpi_result} if x is not ${None}]
    ${reproduce_test_kpi_result}    Evaluate    [x for x in ${reproduce_test_kpi_result} if x is not ${None}]
    Run Keyword And Continue On Failure    Record KPI Data To TestCase Path
    ...                                    kpi_info_list=${total_test_kpi_result}
    ...                                    output_report_name=total_kpi_result.xlsx
    ...                                    filter_distnames=NRCELL-301,bts
    Record KPI Data To TestCase Path    kpi_info_list=${reproduce_test_kpi_result}
    ...                                 output_report_name=reproduce_kpi_result.xlsx
    ...                                 filter_distnames=NRCELL-301,bts
    ...                                 group_name=PR03841043
    [Teardown]    Run Keywords    Run Keyword And Continue On Failure    RepCase_5605005_CaseTeardown    AND
    ...    TMO_Common_Case_Teardown    ue_index=${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}
    ...    is_save_snapshot=${False}   AND    csn.reset_cache

#5605006_E2E_Rep_006_DL_Spectral_efficiency_comparison_between_before_AEHC_NRCELL_energy_saving_and_exit_MixedSwitchoff_energy_saving
#    [Documentation]    Author:stella.lin@nokia-sbell.com
#    ...       EXECUTION TESTLINE: TL080
#    [Tags]     T813
#    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${REPCASE_5605006_CHOOSED_UE['${tl_prefix}']}
#    ${report_timestamps_target_build_step2}    ${report_timestamps_target_build_step4}    TestCase.Reproduce_5605006
#    Run Keyword And Continue On Failure    TMO_Common_Case_Teardown    ue_index=${REPCASE_5605006_CHOOSED_UE['${tl_prefix}']}
#    ...    is_save_snapshot=${False}
#    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB    is_commission=${True}    check_rollback_is_needed=${False}
#    ${reproduce_kpi_info_target_build_step2}    Run Keyword And Continue On Failure
#    ...    Generate And Record Reproduce KPI Report To Compass And UTE
#    ...    report_timestamps=${report_timestamps_target_build_step2}
#    ...    comments=5605006
#    ...    filter_distnames=bts,NRCELL-301
#    ...    gnb_index=${0}
#    ...    group_name=03892004
#    ${total_kpi_info_target_build_step2}    Run Keyword And Continue On Failure
#    ...    Generate And Record Total KPI Report To Compass And UTE
#    ...    report_timestamps=${report_timestamps_target_build_step2}
#    ...    comments=5605006
#    ...    filter_distnames=bts,NRCELL-301
#    ...    gnb_index=${0}
#    ${energy_saving_kpi_info_target_build_step2}    Run Keyword And Continue On Failure
#    ...    Generate And Record Energy Saving KPI Report To Compass And UTE
#    ...    report_timestamps=${report_timestamps_target_build_step2}
#    ...    comments=5605006
#    ...    filter_distnames=bts,NRCELL-301
#    ...    gnb_index=${0}
#    ${reproduce_kpi_info_target_build_step4}    Run Keyword And Continue On Failure
#    ...    Generate And Record Reproduce KPI Report To Compass And UTE
#    ...    report_timestamps=${report_timestamps_target_build_step4}
#    ...    comments=5605006
#    ...    filter_distnames=bts,NRCELL-301
#    ...    gnb_index=${0}
#    ...    group_name=03892004
#    ${total_kpi_info_target_build_step4}    Run Keyword And Continue On Failure
#    ...    Generate And Record Total KPI Report To Compass And UTE
#    ...    report_timestamps=${report_timestamps_target_build_step4}
#    ...    comments=5605006
#    ...    filter_distnames=bts,NRCELL-301
#    ...    gnb_index=${0}
#    ${energy_saving_kpi_info_target_build_step4}    Run Keyword And Continue On Failure
#    ...    Generate And Record Energy Saving KPI Report To Compass And UTE
#    ...    report_timestamps=${report_timestamps_target_build_step4}
#    ...    comments=5605006
#    ...    filter_distnames=bts,NRCELL-301
#    ...    gnb_index=${0}
#    Check Rollback is needed before sw upgrade    active_sw_flag=Low
#    ...                                           gnb_index=${0}
#    ${report_timestamps_source_build_step2}    ${report_timestamps_source_build_step4}    TestCase.Reproduce_5605006
#    ${reproduce_kpi_info_source_build_step2}    Run Keyword And Continue On Failure
#    ...    Generate And Record Reproduce KPI Report To Compass And UTE
#    ...    report_timestamps=${report_timestamps_source_build_step2}
#    ...    comments=5605006
#    ...    filter_distnames=bts,NRCELL-301
#    ...    gnb_index=${0}
#    ...    group_name=03892004
#    ${total_kpi_info_source_build_step2}    Run Keyword And Continue On Failure
#    ...    Generate And Record Total KPI Report To Compass And UTE
#    ...    report_timestamps=${report_timestamps_source_build_step2}
#    ...    comments=5605006
#    ...    filter_distnames=bts,NRCELL-301
#    ...    gnb_index=${0}
#    ${energy_saving_kpi_info_source_build_step2}    Run Keyword And Continue On Failure
#    ...    Generate And Record Energy Saving KPI Report To Compass And UTE
#    ...    report_timestamps=${report_timestamps_source_build_step2}
#    ...    comments=5605006
#    ...    filter_distnames=bts,NRCELL-301
#    ...    gnb_index=${0}
#    ${reproduce_kpi_info_source_build_step4}    Run Keyword And Continue On Failure
#    ...    Generate And Record Reproduce KPI Report To Compass And UTE
#    ...    report_timestamps=${report_timestamps_source_build_step4}
#    ...    comments=5605006
#    ...    filter_distnames=bts,NRCELL-301
#    ...    gnb_index=${0}
#    ...    group_name=03892004
#    ${total_kpi_info_source_build_step4}    Run Keyword And Continue On Failure
#    ...    Generate And Record Total KPI Report To Compass And UTE
#    ...    report_timestamps=${report_timestamps_source_build_step4}
#    ...    comments=5605006
#    ...    filter_distnames=bts,NRCELL-301
#    ...    gnb_index=${0}
#    ${energy_saving_kpi_info_source_build_step4}    Run Keyword And Continue On Failure
#    ...    Generate And Record Energy Saving KPI Report To Compass And UTE
#    ...    report_timestamps=${report_timestamps_source_build_step4}
#    ...    comments=5605006
#    ...    filter_distnames=bts,NRCELL-301
#    ...    gnb_index=${0}
#    #------record active and passive swbuild test kpi data together to automation testcase log path---------------#
#    ${total_test_kpi_result}    Create List    ${total_kpi_info_target_build_step2}    ${total_kpi_info_target_build_step4}
#    ...    ${total_kpi_info_source_build_step2}    ${total_kpi_info_source_build_step4}
#    ${reproduce_test_kpi_result}    Create List    ${reproduce_kpi_info_target_build_step2}    ${reproduce_kpi_info_target_build_step4}
#    ...    ${reproduce_kpi_info_source_build_step2}    ${reproduce_kpi_info_source_build_step4}
#    ${energy_saving_test_kpi_result}    Create List    ${energy_saving_kpi_info_target_build_step2}
#    ...    ${energy_saving_kpi_info_target_build_step4}
#    ...    ${energy_saving_kpi_info_source_build_step2}    ${energy_saving_kpi_info_source_build_step4}
#    ${total_test_kpi_result}    Evaluate    [x for x in ${total_test_kpi_result} if x is not ${None}]
#    ${reproduce_test_kpi_result}    Evaluate    [x for x in ${reproduce_test_kpi_result} if x is not ${None}]
#    ${energy_saving_test_kpi_result}    Evaluate    [x for x in ${energy_saving_test_kpi_result} if x is not ${None}]
#    Run Keyword And Continue On Failure    Record KPI Data To TestCase Path
#    ...                                    kpi_info_list=${total_test_kpi_result}
#    ...                                    output_report_name=total_kpi_result.xlsx
#    ...                                    filter_distnames=NRCELL-301,bts
#    Run Keyword And Continue On Failure    Record KPI Data To TestCase Path    kpi_info_list=${reproduce_test_kpi_result}
#    ...                                 output_report_name=reproduce_kpi_result.xlsx
#    ...                                 filter_distnames=NRCELL-301,bts
#    ...                                 group_name=03892004
#    Run Keyword And Continue On Failure    Record KPI Data To TestCase Path    kpi_info_list=${energy_saving_test_kpi_result}
#    ...                                 output_report_name=energy_saving_kpi_result.xlsx
#    ...                                 filter_distnames=NRCELL-301,bts
#    [Teardown]    Run Keywords
#    ...    Run Keyword And Continue On Failure    TMO_Common_Case_Teardown    ue_index=${REPCASE_5605006_CHOOSED_UE['${tl_prefix}']}
#    ...    is_save_snapshot=${False}    AND
#    ...    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB    is_commission=${True}
#    ...    check_rollback_is_needed=${False}   AND    csn.reset_cache

5605006_E2E_Rep_006_DL_Spectral_efficiency_comparison_between_before_AEHC_NRCELL_energy_saving_and_exit_MixedSwitchoff_energy_saving
    [Documentation]    Author:stella.lin@nokia-sbell.com
    ...       EXECUTION TESTLINE: TL080
    [Tags]     T813
    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${REPCASE_5605006_CHOOSED_UE['${tl_prefix}']}
    ${report_timestamps_target_build_step2}    ${report_timestamps_target_build_step4}    TestCase.Reproduce_5605006
    ${reproduce_kpi_info_target_build_step2}    Run Keyword And Continue On Failure
    ...    Generate And Record Reproduce KPI Report To Compass And UTE
    ...    report_timestamps=${report_timestamps_target_build_step2}
    ...    comments=5605006
    ...    filter_distnames=bts,NRCELL-301
    ...    gnb_index=${0}
    ...    group_name=03892004
    ${total_kpi_info_target_build_step2}    Run Keyword And Continue On Failure
    ...    Generate And Record Total KPI Report To Compass And UTE
    ...    report_timestamps=${report_timestamps_target_build_step2}
    ...    comments=5605006
    ...    filter_distnames=bts,NRCELL-301
    ...    gnb_index=${0}
    ${energy_saving_kpi_info_target_build_step2}    Run Keyword And Continue On Failure
    ...    Generate And Record Energy Saving KPI Report To Compass And UTE
    ...    report_timestamps=${report_timestamps_target_build_step2}
    ...    comments=5605006
    ...    filter_distnames=bts,NRCELL-301
    ...    gnb_index=${0}
    ${reproduce_kpi_info_target_build_step4}    Run Keyword And Continue On Failure
    ...    Generate And Record Reproduce KPI Report To Compass And UTE
    ...    report_timestamps=${report_timestamps_target_build_step4}
    ...    comments=5605006
    ...    filter_distnames=bts,NRCELL-301
    ...    gnb_index=${0}
    ...    group_name=03892004
    ${total_kpi_info_target_build_step4}    Run Keyword And Continue On Failure
    ...    Generate And Record Total KPI Report To Compass And UTE
    ...    report_timestamps=${report_timestamps_target_build_step4}
    ...    comments=5605006
    ...    filter_distnames=bts,NRCELL-301
    ...    gnb_index=${0}
    ${energy_saving_kpi_info_target_build_step4}    Run Keyword And Continue On Failure
    ...    Generate And Record Energy Saving KPI Report To Compass And UTE
    ...    report_timestamps=${report_timestamps_target_build_step4}
    ...    comments=5605006
    ...    filter_distnames=bts,NRCELL-301
    ...    gnb_index=${0}
    #------record active and passive swbuild test kpi data together to automation testcase log path---------------#
    ${total_test_kpi_result}    Create List    ${total_kpi_info_target_build_step2}    ${total_kpi_info_target_build_step4}
    ${reproduce_test_kpi_result}    Create List    ${reproduce_kpi_info_target_build_step2}    ${reproduce_kpi_info_target_build_step4}
    ${energy_saving_test_kpi_result}    Create List    ${energy_saving_kpi_info_target_build_step2}
    ...    ${energy_saving_kpi_info_target_build_step4}
    ${total_test_kpi_result}    Evaluate    [x for x in ${total_test_kpi_result} if x is not ${None}]
    ${reproduce_test_kpi_result}    Evaluate    [x for x in ${reproduce_test_kpi_result} if x is not ${None}]
    ${energy_saving_test_kpi_result}    Evaluate    [x for x in ${energy_saving_test_kpi_result} if x is not ${None}]
    Run Keyword And Continue On Failure    Record KPI Data To TestCase Path
    ...                                    kpi_info_list=${total_test_kpi_result}
    ...                                    output_report_name=total_kpi_result.xlsx
    ...                                    filter_distnames=NRCELL-301,bts
    Run Keyword And Continue On Failure    Record KPI Data To TestCase Path    kpi_info_list=${reproduce_test_kpi_result}
    ...                                 output_report_name=reproduce_kpi_result.xlsx
    ...                                 filter_distnames=NRCELL-301,bts
    ...                                 group_name=03892004
    Run Keyword And Continue On Failure    Record KPI Data To TestCase Path    kpi_info_list=${energy_saving_test_kpi_result}
    ...                                 output_report_name=energy_saving_kpi_result.xlsx
    ...                                 filter_distnames=NRCELL-301,bts
    #checkpoint
    ${NR_5108e_step2}    Set Variable    ${reproduce_kpi_info_target_build_step2['reproduce_kpi_values'][0]['NR_5108e']}
    ${NR_5108e_step4}    Set Variable    ${reproduce_kpi_info_target_build_step4['reproduce_kpi_values'][0]['NR_5108e']}
    ${NR_5108e_step2}    Convert To Number    ${NR_5108e_step2}
    ${NR_5108e_step4}    Convert To Number    ${NR_5108e_step4}
    ${compare_value}    Evaluate    ${NR_5108e_step2}*${0.97}
    Run Keyword And Continue On Failure    Should Be True    ${NR_5108e_step4}>=${compare_value}
    ...    msg=NR_5108e is degrade more than 3% fot step2 and step4.
    [Teardown]    Run Keywords
    ...    Run Keyword And Continue On Failure    TMO_Common_Case_Teardown    ue_index=${REPCASE_5605006_CHOOSED_UE['${tl_prefix}']}
    ...    is_save_snapshot=${False}    AND
    ...    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB    is_commission=${True}
    ...    check_rollback_is_needed=${False}   AND    csn.reset_cache

5605501_E2E_Rep_501_change_paramter_ulTransPrecodeCtl_enforcePrimaryPathOverLte_after_AMF_lock
    [Documentation]    Author:stella.lin@nokia-sbell.com
    ...       EXECUTION TESTLINE: TL080
    [Tags]     T080
    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    ${report_timestamps_target_build_first}    ${report_timestamps_target_build_second}    TestCase.Reproduce_5605501
    ${reproduce_kpi_info_target_build_first}    Run Keyword And Continue On Failure
    ...    Generate And Record Reproduce KPI Report To Compass And UTE
    ...    report_timestamps=${report_timestamps_target_build_first}
    ...    comments=5605501
    ...    filter_distnames=NRDU
    ...    gnb_index=${0}
    ...    group_name=5605501
    ${total_kpi_info_target_build_first}    Run Keyword And Continue On Failure
    ...    Generate And Record Total KPI Report To Compass And UTE
    ...    report_timestamps=${report_timestamps_target_build_first}
    ...    comments=5605501
    ...    filter_distnames=NRDU
    ...    gnb_index=${0}
    ${reproduce_kpi_info_target_build_second}    Run Keyword And Continue On Failure
    ...    Generate And Record Reproduce KPI Report To Compass And UTE
    ...    report_timestamps=${report_timestamps_target_build_second}
    ...    comments=5605501
    ...    filter_distnames=NRDU
    ...    gnb_index=${0}
    ...    group_name=5605501
    ${total_kpi_info_target_build_second}    Run Keyword And Continue On Failure
    ...    Generate And Record Total KPI Report To Compass And UTE
    ...    report_timestamps=${report_timestamps_target_build_second}
    ...    comments=5605501
    ...    filter_distnames=NRDU
    ...    gnb_index=${0}
    #checkpoint
    ${M55150C00035_first}    Set Variable    ${reproduce_kpi_info_target_build_first['reproduce_kpi_values'][0]['M55150C00035']}
    ${M55150C00035_second}    Set Variable    ${reproduce_kpi_info_target_build_second['reproduce_kpi_values'][0]['M55150C00035']}
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${M55150C00035_first}    ${0}
    ...    msg=M55150C00035 is not zero in first step
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${M55150C00035_second}     ${0}
    ...    msg=M55150C00035 is not zero in second step
#    #------record active and passive swbuild test kpi data together to automation testcase log path---------------#
#    ${total_test_kpi_result}    Create List    ${total_kpi_info_target_build_first}    ${total_kpi_info_target_build_second}
#    ${reproduce_test_kpi_result}    Create List    ${reproduce_kpi_info_target_build_first}    ${reproduce_kpi_info_target_build_second}
#    ${total_test_kpi_result}    Evaluate    [x for x in ${total_test_kpi_result} if x is not ${None}]
#    ${reproduce_test_kpi_result}    Evaluate    [x for x in ${reproduce_test_kpi_result} if x is not ${None}]
#    Run Keyword And Continue On Failure    Record KPI Data To TestCase Path
#    ...                                    kpi_info_list=${total_test_kpi_result}
#    ...                                    output_report_name=total_kpi_result.xlsx
#    ...                                    filter_distnames=NRDU
#    Record KPI Data To TestCase Path    kpi_info_list=${reproduce_test_kpi_result}
#    ...                                 output_report_name=reproduce_kpi_result.xlsx
#    ...                                 filter_distnames=NRDU
#    ...                                 group_name=5605501
    [Teardown]    Run Keywords
    ...    Run Keyword And Continue On Failure    TMO_Common_Case_Teardown    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    ...    is_save_snapshot=${False}    is_history_alarm_check=${False}    AND
    ...    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB    is_commission=${True}
    ...    check_rollback_is_needed=${False}   AND    csn.reset_cache

#5605501_E2E_Rep_501_change_paramter_ulTransPrecodeCtl_enforcePrimaryPathOverLte_after_AMF_lock
#    [Documentation]    Author:stella.lin@nokia-sbell.com
#    ...       EXECUTION TESTLINE: TL080
#    [Tags]     T080
#    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
#    ${report_timestamps_target_build_first}    ${report_timestamps_target_build_second}    TestCase.Reproduce_5605501
#    Run Keyword And Continue On Failure    TMO_Common_Case_Teardown    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
#    ...    is_save_snapshot=${False}
#    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB    is_commission=${True}    check_rollback_is_needed=${False}
#    ${reproduce_kpi_info_target_build_first}    Run Keyword And Continue On Failure
#    ...    Generate And Record Reproduce KPI Report To Compass And UTE
#    ...    report_timestamps=${report_timestamps_target_build_first}
#    ...    comments=5605501
#    ...    filter_distnames=bts,NRCELL-301
#    ...    gnb_index=${0}
#    ...    group_name=5605501
#    ${total_kpi_info_target_build_first}    Run Keyword And Continue On Failure
#    ...    Generate And Record Total KPI Report To Compass And UTE
#    ...    report_timestamps=${report_timestamps_target_build_first}
#    ...    comments=5605501
#    ...    filter_distnames=bts,NRCELL-301
#    ...    gnb_index=${0}
#    ${reproduce_kpi_info_target_build_second}    Run Keyword And Continue On Failure
#    ...    Generate And Record Reproduce KPI Report To Compass And UTE
#    ...    report_timestamps=${report_timestamps_target_build_second}
#    ...    comments=5605501
#    ...    filter_distnames=bts,NRCELL-301
#    ...    gnb_index=${0}
#    ...    group_name=5605501
#    ${total_kpi_info_target_build_second}    Run Keyword And Continue On Failure
#    ...    Generate And Record Total KPI Report To Compass And UTE
#    ...    report_timestamps=${report_timestamps_target_build_second}
#    ...    comments=5605501
#    ...    filter_distnames=bts,NRCELL-301
#    ...    gnb_index=${0}
#    Check Rollback is needed before sw upgrade    active_sw_flag=Low
#    ...                                           gnb_index=${0}
#    ${report_timestamps_source_build_first}    ${report_timestamps_source_build_second}    TestCase.Reproduce_5605501
#    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB    is_commission=${True}    check_rollback_is_needed=${False}
#    ${reproduce_kpi_info_source_build_first}    Run Keyword And Continue On Failure
#    ...    Generate And Record Reproduce KPI Report To Compass And UTE
#    ...    report_timestamps=${report_timestamps_source_build_first}
#    ...    comments=5605501
#    ...    filter_distnames=NRDU
#    ...    gnb_index=${0}
#    ...    group_name=03892004
#    ${total_kpi_info_source_build_first}    Run Keyword And Continue On Failure
#    ...    Generate And Record Total KPI Report To Compass And UTE
#    ...    report_timestamps=${report_timestamps_source_build_first}
#    ...    comments=5605501
#    ...    filter_distnames=NRDU
#    ...    gnb_index=${0}
#    ${reproduce_kpi_info_source_build_second}    Run Keyword And Continue On Failure
#    ...    Generate And Record Reproduce KPI Report To Compass And UTE
#    ...    report_timestamps=${report_timestamps_source_build_second}
#    ...    comments=5605501
#    ...    filter_distnames=NRDU
#    ...    gnb_index=${0}
#    ...    group_name=5605501
#    ${total_kpi_info_source_build_second}    Run Keyword And Continue On Failure
#    ...    Generate And Record Total KPI Report To Compass And UTE
#    ...    report_timestamps=${report_timestamps_source_build_second}
#    ...    comments=5605501
#    ...    filter_distnames=NRDU
#    ...    gnb_index=${0}
#    #------record active and passive swbuild test kpi data together to automation testcase log path---------------#
#    ${total_test_kpi_result}    Create List    ${total_kpi_info_target_build_first}    ${total_kpi_info_target_build_second}
#    ...    ${total_kpi_info_source_build_first}    ${total_kpi_info_source_build_second}
#    ${reproduce_test_kpi_result}    Create List    ${reproduce_kpi_info_target_build_first}    ${reproduce_kpi_info_target_build_second}
#    ...    ${reproduce_kpi_info_source_build_first}    ${reproduce_kpi_info_source_build_second}
#    ${total_test_kpi_result}    Evaluate    [x for x in ${total_test_kpi_result} if x is not ${None}]
#    ${reproduce_test_kpi_result}    Evaluate    [x for x in ${reproduce_test_kpi_result} if x is not ${None}]
#    Run Keyword And Continue On Failure    Record KPI Data To TestCase Path
#    ...                                    kpi_info_list=${total_test_kpi_result}
#    ...                                    output_report_name=total_kpi_result.xlsx
#    ...                                    filter_distnames=NRDU
#    Record KPI Data To TestCase Path    kpi_info_list=${reproduce_test_kpi_result}
#    ...                                 output_report_name=reproduce_kpi_result.xlsx
#    ...                                 filter_distnames=NRDU
#    ...                                 group_name=5605501
#    [Teardown]    Run Keywords
#    ...    Run Keyword And Continue On Failure    TMO_Common_Case_Teardown    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
#    ...    is_save_snapshot=${False}    AND
#    ...    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB    is_commission=${True}
#    ...    check_rollback_is_needed=${False}   AND    csn.reset_cache

5605011_E2E_Rep_011_RedCap_RRCEstablishment_setup
    [Documentation]    Author:stella.lin@nokia-sbell.com
    ...       EXECUTION TESTLINE: TL080
    [Tags]     T080
    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${14}
    Backup and Modify swconfig file    swconfig_modify=@{wireshark_flag}
    Perform gNB Reset site and Wait Onair
    Modify PA Value Setting For Required RU    modify_ru_id=0
    ...    ue_index=${4}
    Enable RedCap Function
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${PCELL_INDEX}
    ...    connection=GNB_OAM    timeout=300
#    UE With ADB Reboot    ue_index=${14}
    M60_RedCap.Prepare UE    ue_index=${14}
    ${attach_info}    M60_RedCap.UE Attach    ue_index=${14}    expect_attach_cell_index=301
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Connect to Common Unit Master     alias=ASIK Master0   gnb_index=${0}
    ${filter_ports}    Set Variable    ((port 38472) or (port 38412)or (port 38462) or (port 36422) or (port 38422))
    ${wireshark_capture_interface}    Set Variable    -p -i any '((sctp) and ${filter_ports})' -s 0
    Run Keyword And Continue On Failure    Start CP-IF Log Collection
    ...    tcpdump_collector_name=wireshark_${timestamp}
    ...    asik_connection_alias=ASIK Master0
    ...    gnb_index=${0}
    ...    du_index=0
    ...    options=${wireshark_capture_interface}
    Sleep  20sec
    Run Keyword And Continue On Failure    Procedures.Start TMO L3 Call    cpif_log_path=${attach_info['cpif_log_path']}
    ...                                    dl_throughput=600MKbits/sec
    ...                                    ue_index=${14}
    ...                                    whether_start_ul_call=${False}
    Sleep   15sec
    ${ngap_wireshark}    Run Keyword And Continue On Failure    Stop tcpdump log collection
    ...    tcpdump_collector_name=wireshark_${timestamp}
    ...    target_dir=${TS_CASE_LOG_PATH}
    Run Keyword And Continue On Failure    M60_RedCap.Check Tput    direction=DL    expect_dl_tput=400    cellid=301    duration=60
    #checkpoint
    ${filter_expression}    Catenate    ngap.procedureCode == 15
    pcap.setup    infile=${ngap_wireshark}    display_filter=${filter_expression}    alias=test0
    pcap.get_packets    filter=${filter_expression}   pcap_parser=test0
    ${message_items}    pcap.get_field_value    field_name=ngap.id
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
#    ${compare_message_list}    Create List    id-RAN-UE-NGAP-ID
#    ...                                       id-NAS-PDU
#    ...                                       id-UserLocationInformation
#    ...                                       id-RRCEstablishmentCause
#    ...                                       id-FiveG-S-TMSI
#    ...                                       id-RedCapIndication
    ${compare_message_list}    Create List    85    38    121   90  26   333
    Lists Should Be Equal    ${message_items[0]}    ${compare_message_list}
    ...    msg=message order for initialuemessage are not correct.expect is ${compare_message_list},actual is ${message_items[0]}.
    [Teardown]   Run Keywords    TMO_Common_Case_Teardown    ue_index=${14}   AND
    ...    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB
    ...    is_commission=${True}    check_rollback_is_needed=${False}  AND
    ...    csn.reset_cache

5605500_E2E_Rep_500_lssIPaddress_change_on_eNB
    [Documentation]    Author:stella.lin@nokia-sbell.com
    ...       EXECUTION TESTLINE: TL080
    [Tags]     T080
    [Setup]    SetUp.TMO Case Common SetUp    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    Update lssIPaddress Via RestAPI    value=10.68.88.189
    Sleep    5min
    ${ssh_status}     Run Keyword And Return Status     Connect to eNB
    ${https_status}    Run Keyword And Return Status     COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    Run Keyword And Continue On Failure    Run Keyword If    '${ssh_status}'=='${False}'     Fail
    ...    msg=ssh connection failed after lssIPaddress change to 10.68.88.189
    Run Keyword And Continue On Failure    Run Keyword If    '${https_status}'=='${False}'     Fail
    ...    msg=https connection failed after lssIPaddress change to 10.68.88.189
    Check the enb cell onAir
    coam.get_software_info    timeout=300    connection=enblte
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Update lssIPaddress Via RestAPI   AND
    ...    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}

5605502_E2E_Rep_502_maxNumX2Links_test
    [Documentation]    Author:stella.lin@nokia-sbell.com
    ...       EXECUTION TESTLINE: TL080
    [Tags]     T080
    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    #congiure enb1 x2 to tl080 gnb and tl282 gnb (on enb1)
    Create LNADJGNB On ENB Side    dist_name=MRBTS-11213/LNBTS-11213/LNADJGNB-80    enb_index=${0}
    Run Keyword And Continue On Failure    Check x2link Status On Gnb Side    eNodeBId=11213
    Run Keyword And Continue On Failure    Check x2link Status On Enb Side    enb_index=${0}
#    #change maxNumX2Links on tl080 gnb : 256-->2
    Modify Parameter maxNumX2Links    value=2
##    #reset tl080 gnb
    Perform gNB Reset site and Wait Onair
#    #lock LNADJGNB-80 x2 on enb1
    Lock And Unlock LNADJGNB ON ENB    status=locked
#    #configure enb2 x2 to tl080 gnb (on enb2)
    Sleep   10s
    Create LNADJGNB On ENB Side    enb_index=${1}
    Run Keyword And Continue On Failure    Check x2link Status On Gnb Side    eNodeBId=284284
    Run Keyword And Continue On Failure    Check x2link Status On Enb Side    enb_index=${1}
#    #unlock enb1 x2 on tl080 gnb
    Lock And Unlock LNADJGNB ON ENB    status=unlocked
    #check x2 status on enb2 on both enb and gnb side.
    Sleep   30s
    #check x2 links available on gnb
    ${available_enbs}    Check all x2link Status On Gnb Side
    ${available_enbs_length}     Get Length    ${available_enbs}
    Should Be True     '${available_enbs_length}'=='${2}'    msg=more than 2 x2 links are available on gnb.
    #check x2 links available on enb
    FOR    ${enb_id}    IN    @{available_enbs}
        ${is_enb}    Set Variable If    '${enb_id}'=='284284'    ${True}
        ...                             '${enb_id}'=='11213'     ${True}
        ...                             '${enb_id}'=='8080'    ${False}
        ${connection_index}    Set Variable If    '${enb_id}'=='284284'    ${1}
        ...                                       '${enb_id}'=='11213'     ${0}
        ...                                       '${enb_id}'=='8080'    ${0}
        Run Keyword If  ${is_enb}    Check x2link Status On Enb Side    enb_index=${connection_index}    status=available
        ...    ELSE    Check LNADJGNB Status On Gnb Side    status=available    gnb_index=${connection_index}
    END
    ${all_enb_ids}    Create List    ${284284}    ${11213}    ${8080}
    ${unavailable_enb}    Evaluate    list(set(${all_enb_ids})-set(${available_enbs}))
    ${enb_id}    Set Variable    ${unavailable_enb[0]}
    ${is_enb}    Set Variable If    '${enb_id}'=='284284'    ${True}
    ...                             '${enb_id}'=='11213'     ${True}
    ...                             '${enb_id}'=='8080'    ${False}
    ${connection_index}    Set Variable If    '${enb_id}'=='284284'    ${1}
    ...                                       '${enb_id}'=='11213'     ${0}
    ...                                       '${enb_id}'=='8080'    ${0}
    Run Keyword If  ${is_enb}    Check x2link Status On Enb Side    enb_index=${connection_index}    status=unavailable
    ...    ELSE    Check LNADJGNB Status On Gnb Side    status=unavailable    gnb_index=${connection_index}
    [Teardown]    Run Keywords
    ...    Run Keyword And Continue On Failure    Modify Parameter maxNumX2Links    AND
    ...    Run Keyword And Continue On Failure    Delete LNADJGNB On ENB Side
    ...    dist_name=MRBTS-11213/LNBTS-11213/LNADJGNB-80    enb_index=${0}    AND
    ...    Run Keyword And Continue On Failure    Delete LNADJGNB On ENB Side    enb_index=${1}    AND
    ...    Run Keyword And Continue On Failure    Perform gNB Reset site and Wait Onair    AND
    ...    TMO_Common_Case_Teardown    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}



Record KPI Compare Report
    Create Case Log Path
    ${id}        compator report generate


*** Keywords ***
compator report generate
#    ${template_names_list}     Create List   SG6_KPI_TMO_Reproduction_CRT
#    ${template_id_list}    Create List    1036
#    ${id}    generate_new_comparator_report_on_compass
#    ...    test_line_id=TL_1745
#    ...    test_line_name=7_5_UTE5G402T080
#    ...    report_name=test_1021
#    ...    template_names_list=${template_names_list}
#    ...    template_id_list=${template_id_list}
#    ...    first_description=first_test
#    ...    first_start_time=2024-10-19 12:33:58
#    ...    first_end_time=2024-10-19 13:00:58
#    ...    second_description=second_test
#    ...    second_start_time=2024-10-20 14:33:58
#    ...    second_end_time=2024-10-20 15:00:58
#    ...    alpha_factor=0.005
#    download_kpi_file    report_id=79644    path=/home/ute/KPI_Report/Excel_KPI/
#    download_kpi_file    report_id=${id}    path=/home/ute/KPI_Report/Compare_Report/    is_compare_kpi=True
    extract_compare_data_from_scout    compare_report_id=813267
#    [Return]    ${id}
