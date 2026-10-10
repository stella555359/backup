*** Settings ***
Documentation     Author: tingting.1.liu@nokia-sbell.com
Suite Setup     TMO_Common_Suite_Setup   is_commission=${True}   ute_space=10    whether_do_prepare_ue=${False}
Suite Teardown   Run Keyword And Ignore Error    COAM Teardown gnb connections
Force Tags   5G_SISO    SG_06

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_common_keywords.robot


*** Test Cases ***
5613001_TOL_AZHL_01_1UE-NR-SACALL
     [Documentation]    author: tingting.1.liu@nokia-sbell.com
     ...          step1:case setup contained check gnb cell on air and unexpect alarm
     ...          step2:set up parameter(cellBarred) only NR cell(301) notBarred and PA
     ...          step3:make a L3 SA call,cellid:301 and check Tput could reach to peak
     ...          ue_index:0, 2UE-MultiUE, spark license needed before TA running!
     [Setup]    TMO_AZHL_case_setup
     [Tags]    TA_Done_Case_Delete
     Trun Off All PA Ports
     gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=0   value=0
     Log To Console     ${\n}INFO: -- Start to prepare ue--
     Procedures.Start UE Prepare    ue_index=${0}
     Change Network Mode Between SA And NSA For 2UE Module    ue_mode=SA    ue_index=${0}
     #Deployment SA And NSA Mode For 2UE Module    ue_mode=SA    ue_index=${0}    apn_address=${tl.core.pdns[0].apn}
     ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
     Procedures.Verify Non-CA Basic L3 Call    ue_index=${0}
     ...                                   is_power_ue_code=${True}
     ...                                   ul_throughput=100MKbits/sec
     ...                                   dl_throughput=2000MKbits/sec
     ...                                   expect_dl_tput=1400
     ...                                   expect_ul_tput=50
     ...                                   start_keep_on_duration=600
     ...                                   tput_collect_duration=180
     ...                                   notbarred_cell_index=${301}
     ...                                   apn_address=${tl.core.pdns[0].apn}
     ...                                   whether_do_ue_prepare=${False}
     ...                                   whether_start_uelog=${False}
     ...                                   enb_index=${fdd_enb_index}
     Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
     Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
     [Teardown]   TMO_Common_Case_Teardown   ue_index=${0}    is_power_ue_code=${True}

5613002_TOL_AZHL_02_1UE-NR-SACALL-VONRCALL
     [Documentation]    author: tingting.1.liu@nokia-sbell.com
     ...     step1:case setup contained check gnb cell on air and unexpect alarm
     ...     step2:set up parameter(cellBarred) only NR cell(301) notBarred and PA
     ...     step3:make a L3 SA call and start Vonr call
     ...     step4:stop vonr call and check vonr call success
     ...     step5:check L3 call Tput could reach to peak
     ...     ue_index:0, 2UE-MultiUE, spark license needed before TA running!
     [Tags]    TA_Done_Case_Delete
     [Setup]    TMO_AZHL_case_setup
     Trun Off All PA Ports
     gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=0   value=0
     Procedures.Start UE Prepare    ue_index=${0}
     Change Network Mode Between SA And NSA For 2UE Module    ue_mode=SA    ue_index=${0}
     #Deployment SA And NSA Mode For 2UE Module    ue_mode=SA    ue_index=${0}    apn_address=${tl.core.pdns[0].apn}
     ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
     Procedures.Verify Non-CA Basic L3 Call    ue_index=${0}
     ...                                   is_power_ue_code=${True}
     ...                                   ul_throughput=100MKbits/sec
     ...                                   dl_throughput=2000MKbits/sec
     ...                                   expect_dl_tput=1400
     ...                                   expect_ul_tput=50
     ...                                   start_keep_on_duration=660
     ...                                   tput_collect_duration=180
     ...                                   notbarred_cell_index=${301}
     ...                                   whether_check_tupt=${False}
     ...                                   whether_stop_uelog=${False}
     ...                                   whether_start_uelog=${False}
     ...                                   whether_do_ue_prepare=${False}
     ...                                   apn_address=${tl.core.pdns[0].apn}
     ...                                   enb_index=${fdd_enb_index}
     Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
     ...                                    tcpdump_collector_name=vonr_call
     ...                                    asik_connection_alias=ASIK Master
     ...                                    gnb_index=${0}
     Sleep    10sec
     Make Vonr Call For Model    ue_index=${0}
     Sleep    10sec
     Hang Up Vonr Call For Model   ue_index=${0}
     Sleep    10sec
     ${vonr_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection    tcpdump_collector_name=vonr_call
     Check Tput With Power UE            cellid=${301}
     ...                                 direction_component_list=${direction_component_list}
     ...                                 expect_ul_tput=50
     ...                                 expect_dl_tput=1400
     ...                                 target_avg_percent=0.9
     ...                                 duration=180
     ...                                 is_ulbler_calcu=${False}
     ...                                 check_source=aasyslog
     Check VoNR Call Success       log_path=${vonr_wireshark}
     Run Keyword And Ignore Error    Spark_common_keywords.Spark Stop UE Log    ue_index=${0}
     Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
     Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
     Run Keyword And Ignore Error   Spark_common_keywords.Stop L3 Traffic   ue_index=${0}   apn_address=${tl.core.pdns[0].apn}
     Procedures.Stop TMO L3 Call And Detach    ue_index=${0}    is_power_ue_code=${True}
     [Teardown]   TMO_Common_Case_Teardown   ue_index=${0}    is_power_ue_code=${True}

5603032_TOL_case_21_SiSo_Cell_lock_and_unlock_from_TDDLTE
     [Documentation]    author: tingting.1.liu@nokia-sbell.com
     ...     UE1: 5G SA call
     ...     UE2: 4G call
     [Tags]    TA_Not_Done
     [Setup]    TMO_AZHL_case_setup
     Set Test Variable    ${test_round}    1
     Trun Off All PA Ports
     gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=0   value=0
     ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
     FOR    ${count}    IN RANGE    ${test_round}
         Procedures.Verify Non-CA Basic L3 Call    ue_index=${0}
         ...                                   dl_throughput=2000MKbits/sec
         ...                                   notbarred_cell_index=${301}
         ...                                   whether_stop_uelog=${False}
         ...                                   whether_start_uelog=${False}
         ...                                   whether_do_ue_prepare=${True}
         ...                                   whether_check_attach_cell=${False}
         ...                                   start_keep_on_duration=3600
         ...                                   tput_collect_duration=180
         ...                                   apn_address=${tl.core.pdns[0].apn}
         ...                                   expect_dl_tput=1400
         ...                                   expect_ul_tput=50
         Run Keyword And Continue On Failure    Procedures.Verify 4G L3 Call   ue_index=${1}
         ...                                   notbarred_cell_index=${131}
         ...                                   whether_check_on_air=${False}
         ...                                   whether_do_ue_prepare=${True}
         ...                                   dl_throughput=400MKbits/sec
         ...                                   start_keep_on_duration=1000
         ...                                   expect_dl_tput=2
         ...                                   expect_ul_tput=0
         ...                                   tput_collect_duration=180
         Do All Type Cells Action And Verify Status   cell_action=locked   cell_type=lte    enb_index=${fdd_enb_index}
         run keyword and ignore error    COAM Teardown gnb connections
         Wait Until Keyword Succeeds    300 sec    5 sec    Connect to gnb coam via ssl
         Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
         run keyword and ignore error    COAM Teardown gnb connections
         Check Tput With Power UE            cellid=${301}
         ...                                 direction_component_list=${direction_component_list}
         ...                                 expect_ul_tput=50
         ...                                 expect_dl_tput=1400
         ...                                 target_avg_percent=0.9
         ...                                 duration=180
         ...                                 ignore_time=35
         ...                                 is_ulbler_calcu=${False}
         ...                                 check_source=aasyslog
         Do All Type Cells Action And Verify Status   cell_action=unlocked   cell_type=lte    enb_index=${fdd_enb_index}
         run keyword and ignore error    COAM Teardown gnb connections
         Wait Until Keyword Succeeds    300 sec    5 sec    Connect to gnb coam via ssl
         Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
         run keyword and ignore error    COAM Teardown gnb connections
         Check Tput With Power UE            cellid=${301}
         ...                                 direction_component_list=${direction_component_list}
         ...                                 expect_ul_tput=50
         ...                                 expect_dl_tput=1400
         ...                                 target_avg_percent=0.9
         ...                                 duration=180
         ...                                 ignore_time=35
         ...                                 is_ulbler_calcu=${False}
         ...                                 check_source=aasyslog
         Run Keyword And Continue On Failure    Procedures.Verify 4G L3 Call   ue_index=${1}
         ...                                   notbarred_cell_index=${131}
         ...                                   whether_check_on_air=${False}
         ...                                   whether_do_ue_prepare=${True}
         ...                                   dl_throughput=400MKbits/sec
         ...                                   start_keep_on_duration=1000
         ...                                   expect_dl_tput=2
         ...                                   expect_ul_tput=0
         ...                                   tput_collect_duration=180
     END
     [Teardown]   Run Keywords    TMO_Common_Case_Teardown   ue_index=${0}   AND
     ...                          TMO_Common_Case_Teardown   ue_index=${1}

5603037_TOL_case_32_Siso_UE1_5GFDDCall_UE2_5GTDDCall_all_RF_Module_Lock_and_unlock_from_gNB_UE1_5GFDDCall_UE2_5GTDDCall
     [Documentation]    author: tingting.1.liu@nokia-sbell.com
     ...      UE1: 5G TDD SA CALL
     ...      UE2: 5G FDD SA CALL
     [Tags]    TA_Not_Done
     [Setup]    TMO_AZHL_case_setup
     Trun Off All PA Ports
     ${enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
     gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=0   value=0
     gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=5   value=0
     Procedures.Verify Non-CA Basic L3 Call    ue_index=${0}
     ...                                   dl_throughput=2000MKbits/sec
     ...                                   notbarred_cell_index=${301}
     ...                                   whether_do_ue_prepare=${True}
     ...                                   whether_stop_uelog=${False}
     ...                                   whether_start_uelog=${False}
     ...                                   whether_check_attach_cell=${False}
     ...                                   start_keep_on_duration=600
     ...                                   tput_collect_duration=180
     ...                                   apn_address=${tl.core.pdns[0].apn}
     ...                                   expect_dl_tput=1400
     ...                                   expect_ul_tput=50
     Procedures.Verify Non-CA Basic L3 Call    ue_index=${1}
     ...                                   dl_throughput=2000MKbits/sec
     ...                                   notbarred_cell_index=${21}
     ...                                   whether_do_ue_prepare=${True}
     ...                                   whether_stop_uelog=${False}
     ...                                   whether_start_uelog=${False}
     ...                                   whether_check_attach_cell=${False}
     ...                                   start_keep_on_duration=600
     ...                                   tput_collect_duration=180
     ...                                   apn_address=${tl.core.pdns[0].apn}
     ...                                   expect_dl_tput=350
     ...                                   expect_ul_tput=30
     Run Keyword And Continue On Failure    power_ue.Stop traffic    ue_type=huawei_sigspark    direction=ul    dt_name=DT_ul
     ...        apn_address=${tl.core.pdns[0].apn}    ue_mode=SA    ue_index=${0}
     Run Keyword And Continue On Failure    power_ue.Stop traffic    ue_type=huawei_sigspark    direction=ul    dt_name=DT_ul
     ...        apn_address=${tl.core.pdns[0].apn}    ue_mode=SA    ue_index=${1}
     Procedures.Stop TMO L3 Call And Detach    ue_index=${0}
     Procedures.Stop TMO L3 Call And Detach    ue_index=${1}
     Do All RU Locked Or Unlocked On Gnb   ru_status=Locked    enb_index=${enb_index}
     sleep   1min
     Do All RU Locked Or Unlocked On Gnb   ru_status=Unlocked    enb_index=${enb_index}
     Check TMO Gnb Ready And All Cell On Air
     Procedures.Verify Non-CA Basic L3 Call    ue_index=${0}
     ...                                   dl_throughput=2000MKbits/sec
     ...                                   notbarred_cell_index=${301}
     ...                                   whether_do_ue_prepare=${True}
     ...                                   whether_stop_uelog=${False}
     ...                                   whether_start_uelog=${False}
     ...                                   whether_check_attach_cell=${False}
     ...                                   start_keep_on_duration=600
     ...                                   tput_collect_duration=180
     ...                                   apn_address=${tl.core.pdns[0].apn}
     ...                                   expect_dl_tput=1400
     ...                                   expect_ul_tput=50
     Procedures.Start UE Prepare    ue_index=${1}
     Procedures.Verify Non-CA Basic L3 Call    ue_index=${1}
     ...                                   dl_throughput=2000MKbits/sec
     ...                                   notbarred_cell_index=${21}
     ...                                   whether_stop_uelog=${False}
     ...                                   whether_start_uelog=${False}
     ...                                   whether_check_attach_cell=${False}
     ...                                   whether_do_ue_prepare=${True}
     ...                                   start_keep_on_duration=600
     ...                                   tput_collect_duration=180
     ...                                   apn_address=${tl.core.pdns[0].apn}
     ...                                   expect_dl_tput=350
     ...                                   expect_ul_tput=30
     Procedures.Stop TMO L3 Call And Detach    ue_index=${0}
     Procedures.Stop TMO L3 Call And Detach    ue_index=${1}
     [Teardown]   Run Keywords    Run Keyword And Continue On Failure
     ...     Do All RU Locked Or Unlocked On Gnb   ru_status=Unlocked   enb_index=${enb_index}    AND
     ...     TMO_Common_Case_Teardown   ue_index=${0}     AND
     ...     TMO_Common_Case_Teardown   ue_index=${1}

5603036_TOL_case_31_Siso_all_RF_Module_reset_from_gNB
     [Documentation]    author: tingting.1.liu@nokia-sbell.com
     ...      UE1: 5G TDD SA CALL
     ...      UE2: 5G FDD SA CALL
     [Tags]    TA_Not_Done
     [Setup]    TMO_AZHL_case_setup
     Trun Off All PA Ports
     gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=0   value=0
     gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=5   value=0
     Procedures.Verify Non-CA Basic L3 Call    ue_index=${0}
     ...                                   dl_throughput=2000MKbits/sec
     ...                                   notbarred_cell_index=${301}
     ...                                   whether_do_ue_prepare=${True}
     ...                                   whether_stop_uelog=${False}
     ...                                   whether_start_uelog=${False}
     ...                                   whether_check_attach_cell=${False}
     ...                                   start_keep_on_duration=600
     ...                                   tput_collect_duration=180
     ...                                   apn_address=${tl.core.pdns[0].apn}
     ...                                   expect_dl_tput=1400
     ...                                   expect_ul_tput=50
     Procedures.Verify Non-CA Basic L3 Call    ue_index=${1}
     ...                                   dl_throughput=2000MKbits/sec
     ...                                   notbarred_cell_index=${21}
     ...                                   whether_do_ue_prepare=${True}
     ...                                   whether_stop_uelog=${False}
     ...                                   whether_start_uelog=${False}
     ...                                   whether_check_attach_cell=${False}
     ...                                   start_keep_on_duration=600
     ...                                   tput_collect_duration=180
     ...                                   apn_address=${tl.core.pdns[0].apn}
     ...                                   expect_dl_tput=350
     ...                                   expect_ul_tput=20
     Run Keyword And Continue On Failure    power_ue.Stop traffic    ue_type=huawei_sigspark    direction=ul    dt_name=DT_ul
     ...        apn_address=${tl.core.pdns[0].apn}    ue_mode=SA    ue_index=${0}
     Run Keyword And Continue On Failure    power_ue.Stop traffic    ue_type=huawei_sigspark    direction=ul    dt_name=DT_ul
     ...        apn_address=${tl.core.pdns[0].apn}    ue_mode=SA    ue_index=${1}
     Procedures.Stop TMO L3 Call And Detach    ue_index=${0}
     Procedures.Stop TMO L3 Call And Detach    ue_index=${1}
     Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
     ${ru_index_list}    Get All RU Index
     FOR   ${ru_index}   IN   @{ru_index_list}
             Perform RU Reset     ru_index=${ru_index}
     END
     run keyword and ignore error    COAM Teardown gnb connections
     Check TMO Gnb Ready And All Cell On Air
     Procedures.Verify Non-CA Basic L3 Call    ue_index=${0}
     ...                                   dl_throughput=2000MKbits/sec
     ...                                   notbarred_cell_index=${301}
     ...                                   whether_do_ue_prepare=${True}
     ...                                   whether_stop_uelog=${False}
     ...                                   whether_start_uelog=${False}
     ...                                   whether_check_attach_cell=${False}
     ...                                   start_keep_on_duration=600
     ...                                   tput_collect_duration=180
     ...                                   apn_address=${tl.core.pdns[0].apn}
     ...                                   expect_dl_tput=1400
     ...                                   expect_ul_tput=50
     Procedures.Verify Non-CA Basic L3 Call    ue_index=${1}
     ...                                   dl_throughput=2000MKbits/sec
     ...                                   notbarred_cell_index=${21}
     ...                                   whether_stop_uelog=${False}
     ...                                   whether_start_uelog=${False}
     ...                                   whether_check_attach_cell=${False}
     ...                                   whether_do_ue_prepare=${True}
     ...                                   start_keep_on_duration=600
     ...                                   tput_collect_duration=180
     ...                                   apn_address=${tl.core.pdns[0].apn}
     ...                                   expect_dl_tput=350
     ...                                   expect_ul_tput=20
     Procedures.Stop TMO L3 Call And Detach    ue_index=${0}
     Procedures.Stop TMO L3 Call And Detach    ue_index=${1}
     [Teardown]   Run Keywords    Run Keyword And Continue On Failure
     ...     TMO_Common_Case_Teardown   ue_index=${0}     AND
     ...     TMO_Common_Case_Teardown   ue_index=${1}

5603077_TOL_case_77_SISO_lock_unlock_NGLINK
     [Documentation]    author: tingting.1.liu@nokia-sbell.com
     ...     UE1: NSA call on nrcell:301 lncell:31
     ...     UE2: SA call on nrcell:21
     [Tags]    TA_Not_Done
     [Setup]    TMO_AZHL_case_setup
     Trun Off All PA Ports
     gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=0   value=0
     gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=5   value=0
     Change cellBarred Parameter Value Of Lte Cells        list_cell_ids=${11}     exp_status=notBarred
     Procedures.Start UE Prepare    ue_index=${0}
     Change Network Mode Between SA And NSA For 8UE Module   ue_mode=NSA   ue_index=${0}
     Procedures.Verify Non-CA Basic L3 Call    ue_index=${0}
     ...                                   ue_mode=NSA
     ...                                   notbarred_cell_index=${301}
     ...                                   whether_stop_uelog=${False}
     ...                                   whether_start_uelog=${False}
     ...                                   whether_do_ue_prepare=${True}
     ...                                   whether_check_attach_cell=${False}
     ...                                   whether_do_lte_cell_barred=${False}
     ...                                   whether_check_on_air=${False}
     ...                                   whether_do_ue_prepare=${False}
     ...                                   start_keep_on_duration=3600
     ...                                   tput_collect_duration=180
     ...                                   apn_address=${tl.core.pdns[0].apn}
     ...                                   expect_dl_tput=400
     ...                                   expect_ul_tput=30
     Procedures.Verify Non-CA Basic L3 Call    ue_index=${1}
     ...                                   notbarred_cell_index=${11}
     ...                                   whether_stop_uelog=${False}
     ...                                   whether_start_uelog=${False}
     ...                                   whether_check_attach_cell=${False}
     ...                                   whether_do_ue_prepare=${True}
     ...                                   whether_do_lte_cell_barred=${False}
     ...                                   start_keep_on_duration=600
     ...                                   tput_collect_duration=180
     ...                                   apn_address=${tl.core.pdns[0].apn}
     ...                                   dl_throughput=600MKbits/sec
     ...                                   expect_dl_tput=350
     ...                                   expect_ul_tput=30
     Lock Or Unlock NG Links In vCU  expected_value=Locked
     Check Tput With Power UE            cellid=${301}
     ...                                 direction_component_list=${direction_component_list}
     ...                                 expect_ul_tput=30
     ...                                 expect_dl_tput=800
     ...                                 target_avg_percent=0.9
     ...                                 duration=180
     ...                                 ignore_time=0
     ...                                 is_ulbler_calcu=${False}
     ...                                 check_source=aasyslog
     Lock Or Unlock NG Links In vCU  expected_value=Unlocked
     Check Tput With Power UE            cellid=${301}
     ...                                 direction_component_list=${direction_component_list}
     ...                                 expect_ul_tput=30
     ...                                 expect_dl_tput=800
     ...                                 target_avg_percent=0.9
     ...                                 duration=180
     ...                                 ignore_time=0
     ...                                 is_ulbler_calcu=${False}
     ...                                 check_source=aasyslog
     Procedures.Verify Non-CA Basic L3 Call    ue_index=${1}
     ...                                   notbarred_cell_index=${11}
     ...                                   whether_stop_uelog=${False}
     ...                                   whether_start_uelog=${False}
     ...                                   whether_do_ue_prepare=${True}
     ...                                   whether_check_attach_cell=${False}
     ...                                   whether_do_lte_cell_barred=${False}
     ...                                   whether_check_on_air=${False}
     ...                                   whether_do_ue_prepare=${False}
     ...                                   start_keep_on_duration=600
     ...                                   tput_collect_duration=180
     ...                                   apn_address=${tl.core.pdns[0].apn}
     ...                                   dl_throughput=600MKbits/sec
     ...                                   expect_dl_tput=350
     ...                                   expect_ul_tput=30
     [Teardown]   Run Keywords    TMO_Common_Case_Teardown   ue_index=${0}     AND
     ...     TMO_Common_Case_Teardown   ue_index=${1}

5603046_TOL_case_48_OAM_5G_Site_eCPRI_link_failure_Long_break_2_min_recovery
     [Tags]    TA_Not_Done
     [Setup]    TMO_AZHL_case_setup
     Trun Off All PA Ports
     gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=1   value=0
     run keyword and ignore error    COAM Teardown gnb connections
     Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
     Generate Pcell Mapping Info    pcell_index=${303}
     Run Keyword And Continue On Failure    Check RU Calibration Status And Power on Specifc RU
     Procedures.Verify Non-CA Basic L3 Call
     ...                                   ue_index=${0}
     ...                                   ul_throughput=100MKbits/sec
     ...                                   dl_throughput=2000MKbits/sec
     ...                                   expect_dl_tput=1400
     ...                                   expect_ul_tput=50
     ...                                   start_keep_on_duration=3600
     ...                                   tput_collect_duration=180
     ...                                   notbarred_cell_index=${303}
     ...                                   apn_address=${tl.core.pdns[0].apn}
     ...                                   whether_stop_uelog=${False}
     ...                                   whether_start_uelog=${False}
     ...                                   whether_do_ue_prepare=${True}
     Run Keyword And Continue On Failure    Procedures.Verify 4G L3 Call   ue_index=${1}
     ...                                   notbarred_cell_index=${133}
     ...                                   whether_check_on_air=${False}
     ...                                   whether_do_ue_prepare=${True}
     ...                                   dl_throughput=400MKbits/sec
     ...                                   start_keep_on_duration=1000
     ...                                   expect_dl_tput=2
     ...                                   expect_ul_tput=0
     ...                                   tput_collect_duration=180
     Log To Console    \n\tSet Fiber Switch Into link_failure
     Set Test Variable    ${test_case_id}    ${TEST NAME.split('_')[0]}
     Set Test Variable    ${gnb_used_channel}
     ...                  ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']['5G_fiber_switch_channel']}
     Set Fiber Switch Into Link Failure Or Link Up   channel_numbers=${gnb_used_channel}    link_status=down
     &{fault_2002}     Create Dictionary     faultId=${2002}
     ${GNB_ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_2002}
     Run Keyword And Ignore Error    Wait For Expect Fault Present   faultId=${2002}   timeout=300    connection=GNB_OAM
     Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${GNB_ALLOWED_FAULT}
     ...                                                                       connection=GNB_OAM
     Wait Until Keyword Succeeds    600 sec    3 sec    Wait Gnb Ready And Cell On Air   connection=GNB_OAM
     Check Tput With Power UE
     ...                                                 cellid=${303}
     ...                                                 direction_component_list=${direction_component_list}
     ...                                                 expect_ul_tput=50
     ...                                                 expect_dl_tput=1400
     ...                                                 target_avg_percent=0.9
     ...                                                 duration=180
     ...                                                 ignore_time=0
     ...                                                 is_ulbler_calcu=${False}
     ...                                                 check_source=aasyslog
     Log To Console    \n\tSet Fiber Switch Into link_up
     Set Fiber Switch Into Link Failure Or Link Up    channel_numbers=${gnb_used_channel}    link_status=up
     Sleep    10min
     Run Keyword And Ignore Error    Wait For Expect Fault To Disappear   faultId=${2002}  timeout=600    connection=GNB_OAM
     Wait Until Keyword Succeeds    600 sec    3 sec    COAM Check GNB RU status    connection=GNB_OAM
     Wait Until Keyword Succeeds    600 sec    3 sec    Verify Gnb Type Cells Should Be Onair  cell_type=lte    connection=GNB_OAM
     Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl
     Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${GNB_ALLOWED_FAULT}    connection=GNB_OAM
     COAM Wait for gnb ready and cell setup    timeout=15 min    connection=GNB_OAM
     ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_2002}
     Run Keyword And Continue On Failure    Unexpect History Alarm Should Not Exist
     ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=GNB_OAM
     Check Tput With Power UE
     ...                                                 cellid=${303}
     ...                                                 direction_component_list=${direction_component_list}
     ...                                                 expect_ul_tput=50
     ...                                                 expect_dl_tput=1400
     ...                                                 target_avg_percent=0.9
     ...                                                 duration=180
     ...                                                 ignore_time=0
     ...                                                 is_ulbler_calcu=${False}
     ...                                                 check_source=aasyslog
     Run Keyword And Continue On Failure    Procedures.Verify 4G L3 Call   ue_index=${1}
     ...                                   notbarred_cell_index=${133}
     ...                                   whether_check_on_air=${False}
     ...                                   whether_do_ue_prepare=${True}
     ...                                   dl_throughput=400MKbits/sec
     ...                                   start_keep_on_duration=1000
     ...                                   expect_dl_tput=2
     ...                                   expect_ul_tput=0
     ...                                   tput_collect_duration=180
     Run Keyword And Continue On Failure    Check RU Calibration Status And Power on Specifc RU
     [Teardown]   Run Keywords    TMO_Common_Case_Teardown   ue_index=${0}   AND   Run Keyword And Continue On Failure
     ...     Change cellBarred Parameter Value Of Lte Cells      list_cell_ids=all  exp_status=barred
     ...     AND        TMO_Common_Case_Teardown   ue_index=${1}
     ...             AND   Set Fiber Switch Into Link Failure Or Link Up    channel_numbers=${gnb_used_channel}    link_status=up

5603047_TOL_case_49_OAM_LTE_Site_eCPRI_link_failure_Long_break_2_min_recovery
     [Tags]    TA_Not_Done
     [Setup]    TMO_AZHL_case_setup
     Trun Off All PA Ports
     gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=1   value=0
     run keyword and ignore error    COAM Teardown gnb connections
     Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
     Generate Pcell Mapping Info    pcell_index=${303}
     Run Keyword And Continue On Failure    Check RU Calibration Status And Power on Specifc RU
     Procedures.Verify Non-CA Basic L3 Call   ue_index=${0}
     ...                                      ul_throughput=100MKbits/sec
     ...                                      dl_throughput=1000MKbits/sec
     ...                                      expect_dl_tput=1400
     ...                                      expect_ul_tput=50
     ...                                      start_keep_on_duration=1000
     ...                                      tput_collect_duration=180
     ...                                      notbarred_cell_index=${303}
     ...                                      apn_address=${tl.core.pdns[0].apn}
     ...                                      whether_stop_uelog=${False}
     ...                                      whether_start_uelog=${False}
     ...                                      whether_do_ue_prepare=${True}
     Run Keyword And Continue On Failure    Procedures.Verify 4G L3 Call   ue_index=${1}
     ...                                   notbarred_cell_index=${133}
     ...                                   whether_check_on_air=${False}
     ...                                   whether_do_ue_prepare=${True}
     ...                                   dl_throughput=400MKbits/sec
     ...                                   start_keep_on_duration=3600
     ...                                   expect_dl_tput=2
     ...                                   expect_ul_tput=0
     ...                                   tput_collect_duration=180
     Log To Console    \n\tSet Fiber Switch Into link_failure
     Set Test Variable    ${test_case_id}    ${TEST NAME.split('_')[0]}
     Set Test Variable    ${enb_used_channel}
     ...                  ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']['4G_fiber_switch_channel']}
     Set Fiber Switch Into Link Failure Or Link Up   channel_numbers=${enb_used_channel}    link_status=down
     &{fault_2002}     Create Dictionary     faultId=${2002}
     ${GNB_ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_2002}
     Run Keyword And Ignore Error    Wait For Expect Fault Present   faultId=${2002}   timeout=300    connection=GNB_OAM
     Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${GNB_ALLOWED_FAULT}
     ...                                                                       connection=GNB_OAM
     Wait Until Keyword Succeeds    600 sec    3 sec    COAM Check GNB RU status   connection=GNB_OAM
     Wait Until Keyword Succeeds    600 sec    3 sec    Verify Gnb Type Cells Should Be Onair    cell_type=lte   connection=GNB_OAM
     Run Keyword And Continue On Failure    Check 4G Tput With Power UE
     ...                                                 expect_ul_tput=0
     ...                                                 expect_dl_tput=2
     ...                                                 ignore_time=0sec
     ...                                                 tput_collect_duration=180
     Log To Console    \n\tSet Fiber Switch Into link_up
     Set Fiber Switch Into Link Failure Or Link Up    channel_numbers=${enb_used_channel}    link_status=up
     Run Keyword And Ignore Error    Wait For Expect Fault To Disappear   faultId=${2002}  timeout=600    connection=GNB_OAM
     Wait Until Keyword Succeeds    600 sec    3 sec    Wait Gnb Ready And Cell On Air  timeout=20 min   connection=GNB_OAM
     Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${GNB_ALLOWED_FAULT}    connection=GNB_OAM
     COAM Wait for gnb ready and cell setup    timeout=15 min    connection=GNB_OAM
     ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_2002}
     Run Keyword And Continue On Failure    Unexpect History Alarm Should Not Exist
     ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=GNB_OAM
     Run Keyword And Continue On Failure    Check 4G Tput With Power UE
     ...                                                 expect_ul_tput=0
     ...                                                 expect_dl_tput=2
     ...                                                 ignore_time=0sec
     ...                                                 tput_collect_duration=180
     Procedures.Start UE Prepare    ue_index=${0}
     Run Keyword And Ignore Error    spark.send_AT_command_CPE     ue_alias=UE_0   param=AT+CFUN=0
     Run Keyword And Ignore Error    spark.send_AT_command_CPE     ue_alias=UE_0   param=AT+CFUN=1
     Procedures.Verify Non-CA Basic L3 Call    ue_index=${0}
     ...                                       ul_throughput=100MKbits/sec
     ...                                       dl_throughput=2000MKbits/sec
     ...                                       expect_dl_tput=1400
     ...                                       expect_ul_tput=50
     ...                                       start_keep_on_duration=1000
     ...                                       tput_collect_duration=180
     ...                                       notbarred_cell_index=${303}
     ...                                       apn_address=${tl.core.pdns[0].apn}
     ...                                       whether_stop_uelog=${False}
     ...                                       whether_start_uelog=${False}
     ...                                       whether_do_ue_prepare=${True}
     Run Keyword And Continue On Failure    Check RU Calibration Status And Power on Specifc RU
     [Teardown]   Run Keywords    TMO_Common_Case_Teardown   ue_index=${0}   AND   Run Keyword And Ignore Error
     ...             Spark_common_keywords.Stop L3 Traffic   ue_index=${0}   apn_address=${tl.core.pdns[0].apn}  AND
     ...             TMO_Common_Case_Teardown   ue_index=${1}
     ...             AND   Set Fiber Switch Into Link Failure Or Link Up    channel_numbers=${enb_used_channel}    link_status=up

5603076_TOL_case_76_SISO_lock_unlock_BBMOD
     [Documentation]    author: tingting.1.liu@nokia-sbell.com
     ...     UE1: 5G SA call and VONR on nrcell:302
     ...     UE2: 4G call on ltecell:133、143
     [Tags]    TA_Not_Done
     [Setup]    TMO_AZHL_case_setup
     gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=0   value=0
     Procedures.Verify Non-CA Basic L3 Call    ue_index=${0}
     ...                                   ul_throughput=100MKbits/sec
     ...                                   dl_throughput=2000MKbits/sec
     ...                                   expect_dl_tput=1400
     ...                                   expect_ul_tput=50
     ...                                   start_keep_on_duration=600
     ...                                   tput_collect_duration=180
     ...                                   notbarred_cell_index=${301}
     ...                                   apn_address=${tl.core.pdns[0].apn}
     ...                                   whether_do_ue_prepare=${True}
     ...                                   whether_start_uelog=${False}
     Run Keyword And Continue On Failure    Procedures.Verify 4G L3 Call   ue_index=${1}
     ...                                   notbarred_cell_index=${131}
     ...                                   whether_check_on_air=${False}
     ...                                   whether_do_ue_prepare=${True}
     ...                                   dl_throughput=400MKbits/sec
     ...                                   start_keep_on_duration=1000
     ...                                   expect_dl_tput=2
     ...                                   expect_ul_tput=0
     ...                                   tput_collect_duration=180
     Lock Or Unlock Or Reset BBMOD  cell_index=${301}   expect_bbmod_status=Locked   cell_type=nr
     Lock Or Unlock Or Reset BBMOD   cell_index=${301}   expect_bbmod_status=Unlocked   cell_type=nr
     Procedures.Verify Non-CA Basic L3 Call    ue_index=${0}
     ...                                   ul_throughput=100MKbits/sec
     ...                                   dl_throughput=2000MKbits/sec
     ...                                   expect_dl_tput=1400
     ...                                   expect_ul_tput=50
     ...                                   start_keep_on_duration=600
     ...                                   tput_collect_duration=180
     ...                                   notbarred_cell_index=${301}
     ...                                   apn_address=${tl.core.pdns[0].apn}
     ...                                   whether_do_ue_prepare=${True}
     ...                                   whether_start_uelog=${False}
     Run Keyword And Continue On Failure    Procedures.Verify 4G L3 Call   ue_index=${1}
     ...                                   notbarred_cell_index=${131}
     ...                                   whether_check_on_air=${False}
     ...                                   whether_do_ue_prepare=${True}
     ...                                   dl_throughput=400MKbits/sec
     ...                                   start_keep_on_duration=1000
     ...                                   expect_dl_tput=2
     ...                                   expect_ul_tput=0
     ...                                   tput_collect_duration=180
     Lock Or Unlock Or Reset BBMOD  cell_index=${131}   expect_bbmod_status=Locked   cell_type=lte
     Lock Or Unlock Or Reset BBMOD  cell_index=${131}   expect_bbmod_status=Unlocked   cell_type=lte
     Procedures.Verify Non-CA Basic L3 Call    ue_index=${0}
     ...                                   ul_throughput=100MKbits/sec
     ...                                   dl_throughput=2000MKbits/sec
     ...                                   expect_dl_tput=1400
     ...                                   expect_ul_tput=50
     ...                                   start_keep_on_duration=600
     ...                                   tput_collect_duration=180
     ...                                   notbarred_cell_index=${301}
     ...                                   apn_address=${tl.core.pdns[0].apn}
     ...                                   whether_do_ue_prepare=${True}
     ...                                   whether_start_uelog=${False}
     Run Keyword And Continue On Failure    Procedures.Verify 4G L3 Call   ue_index=${1}
     ...                                   notbarred_cell_index=${133}
     ...                                   whether_check_on_air=${False}
     ...                                   whether_do_ue_prepare=${True}
     ...                                   dl_throughput=400MKbits/sec
     ...                                   start_keep_on_duration=1000
     ...                                   expect_dl_tput=2
     ...                                   expect_ul_tput=0
     ...                                   tput_collect_duration=180
     [Teardown]   Run Keywords
     ...     Run Keyword And Ignore Error   Lock Or Unlock Or Reset BBMOD  cell_index=${303}   expect_bbmod_status=Unlocked   AND
     ...     Run Keyword And Ignore Error   Lock Or Unlock Or Reset BBMOD  cell_index=${131}   expect_bbmod_status=Unlocked   cell_type=lte
     ...     AND     TMO_Common_Case_Teardown   ue_index=${0}    AND
     ...     TMO_Common_Case_Teardown   ue_index=${1}

5603019_TOL_case_12_SiSo_reset_GNB_site
     [Tags]    TA_Not_Done
     [Setup]    TMO_AZHL_case_setup
     Set Test Variable    ${test_round}    1
     FOR    ${count}    IN RANGE    ${test_round}
         Run Keyword And Ignore Error    Trun Off All PA Ports
         gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=0   value=0
         Change Network Mode Between SA And NSA For 8UE Module   ue_mode=SA   ue_index=${0}
         Procedures.Verify Non-CA Basic L3 Call    ue_index=${0}
         ...                                   ul_throughput=100MKbits/sec
         ...                                   dl_throughput=2000MKbits/sec
         ...                                   expect_dl_tput=1400
         ...                                   expect_ul_tput=50
         ...                                   start_keep_on_duration=600
         ...                                   tput_collect_duration=180
         ...                                   notbarred_cell_index=${301}
         ...                                   apn_address=${tl.core.pdns[0].apn}
         ...                                   whether_do_ue_prepare=${True}
         ...                                   whether_start_uelog=${False}
         Change Network Mode Between SA And NSA For 8UE Module   ue_mode=NSA   ue_index=${1}
         Run Keyword And Continue On Failure    Procedures.Verify 4G L3 Call   ue_index=${1}
         ...                                   notbarred_cell_index=${131}
         ...                                   whether_check_on_air=${False}
         ...                                   whether_do_ue_prepare=${True}
         ...                                   dl_throughput=400MKbits/sec
         ...                                   start_keep_on_duration=1000
         ...                                   expect_dl_tput=2
         ...                                   expect_ul_tput=0
         ...                                   tput_collect_duration=180
         Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=GNB_OAM
         coam.reset_site    wait_for_reconnection=${True}    timeout=600    connection=GNB_OAM
         Sleep    60s
         Check TMO Gnb Ready And All Cell On Air
         Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=GNB_OAM
         Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
         Procedures.Verify Non-CA Basic L3 Call    ue_index=${0}
         ...                                   ul_throughput=100MKbits/sec
         ...                                   dl_throughput=2000MKbits/sec
         ...                                   expect_dl_tput=1400
         ...                                   expect_ul_tput=50
         ...                                   start_keep_on_duration=600
         ...                                   tput_collect_duration=180
         ...                                   notbarred_cell_index=${301}
         ...                                   apn_address=${tl.core.pdns[0].apn}
         ...                                   whether_do_ue_prepare=${True}
         ...                                   whether_start_uelog=${False}
         Run Keyword And Continue On Failure    Procedures.Verify 4G L3 Call   ue_index=${1}
         ...                                   notbarred_cell_index=${131}
         ...                                   whether_check_on_air=${False}
         ...                                   whether_do_ue_prepare=${True}
         ...                                   dl_throughput=400MKbits/sec
         ...                                   start_keep_on_duration=1000
         ...                                   expect_dl_tput=2
         ...                                   expect_ul_tput=0
         ...                                   tput_collect_duration=180
     END
     [Teardown]   Run Keywords    TMO_Common_Case_Teardown   ue_index=${0}   AND
     ...     TMO_Common_Case_Teardown   ue_index=${1}   AND
     ...     Run Keyword And Continue On Failure
     ...                      Change Network Mode Between SA And NSA For 8UE Module   ue_mode=SA   ue_index=${1}

5603027_TOL_case_12_SiSo_reset_GNBRAT
     [Tags]    TA_Not_Done
     [Setup]    TMO_AZHL_case_setup
     Set Test Variable    ${test_round}    1
     FOR    ${count}    IN RANGE    ${test_round}
         gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=0   value=0
         Procedures.Verify Non-CA Basic L3 Call    ue_index=${0}
         ...                                   ul_throughput=100MKbits/sec
         ...                                   dl_throughput=2000MKbits/sec
         ...                                   expect_dl_tput=1400
         ...                                   expect_ul_tput=50
         ...                                   start_keep_on_duration=600
         ...                                   tput_collect_duration=180
         ...                                   notbarred_cell_index=${301}
         ...                                   apn_address=${tl.core.pdns[0].apn}
         ...                                   whether_do_ue_prepare=${True}
         ...                                   whether_start_uelog=${False}
         Run Keyword And Continue On Failure    Procedures.Verify 4G L3 Call   ue_index=${1}
         ...                                   notbarred_cell_index=${131}
         ...                                   whether_check_on_air=${False}
         ...                                   whether_do_ue_prepare=${True}
         ...                                   dl_throughput=400MKbits/sec
         ...                                   start_keep_on_duration=1000
         ...                                   expect_dl_tput=2
         ...                                   expect_ul_tput=0
         ...                                   tput_collect_duration=180
         Log To Console    ${\n}INFO:-- ${count} time to reset NR RAT --
         Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=GNB_OAM
         coam.reset_rat     rat_type=NR    timeout=600    connection=GNB_OAM
         Sleep    60s
         Check TMO Gnb Ready And All Cell On Air
         Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
         Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
         run keyword and ignore error    COAM Teardown gnb connections
         Procedures.Verify Non-CA Basic L3 Call    ue_index=${0}
         ...                                   ul_throughput=100MKbits/sec
         ...                                   dl_throughput=2000MKbits/sec
         ...                                   expect_dl_tput=1400
         ...                                   expect_ul_tput=50
         ...                                   start_keep_on_duration=600
         ...                                   tput_collect_duration=180
         ...                                   notbarred_cell_index=${301}
         ...                                   apn_address=${tl.core.pdns[0].apn}
         ...                                   whether_do_ue_prepare=${True}
         ...                                   whether_start_uelog=${False}
         Run Keyword And Continue On Failure    Procedures.Verify 4G L3 Call   ue_index=${1}
         ...                                   notbarred_cell_index=${131}
         ...                                   whether_check_on_air=${False}
         ...                                   whether_do_ue_prepare=${True}
         ...                                   dl_throughput=400MKbits/sec
         ...                                   start_keep_on_duration=1000
         ...                                   expect_dl_tput=2
         ...                                   expect_ul_tput=0
         ...                                   tput_collect_duration=180
     END
     [Teardown]    Run Keywords      Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${0}
     ...    AND    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${1}

5603078_TOL_case_78_SISO_lock_unlock_cell_from_TDD_RF_reset_from_gNB
     [Documentation]    author: tingting.1.liu@nokia-sbell.com
     ...     UE1: Vonr and L3 SA call on nrcell301
     ...     UE2: 4G call on lncell131
     [Tags]    TA_Not_Done
     [Setup]    TMO_AZHL_case_setup
     gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    RU_id=0   value=0
     Procedures.Start UE Prepare    ue_index=${0}
     Run Keyword And Ignore Error    spark.send_AT_command_CPE     ue_alias=UE_0   param=AT+CFUN=0
     Run Keyword And Ignore Error    spark.send_AT_command_CPE     ue_alias=UE_0   param=AT+CFUN=1
     Procedures.Verify Non-CA Basic L3 Call    ue_index=${0}
     ...                                   dl_throughput=1600MKbits/sec
     ...                                   notbarred_cell_index=${301}
     ...                                   whether_stop_uelog=${False}
     ...                                   whether_start_uelog=${False}
     ...                                   whether_do_ue_prepare=${True}
     ...                                   start_keep_on_duration=1000
     ...                                   tput_collect_duration=180
     ...                                   apn_address=${tl.core.pdns[0].apn}
     Run Keyword And Continue On Failure    Procedures.Verify 4G L3 Call   ue_index=${1}
     ...                                   notbarred_cell_index=${131}
     ...                                   whether_check_on_air=${False}
     ...                                   whether_do_ue_prepare=${True}
     ...                                   dl_throughput=400MKbits/sec
     ...                                   start_keep_on_duration=1000
     ...                                   expect_dl_tput=2
     ...                                   expect_ul_tput=0
     ...                                   tput_collect_duration=180
     Log to console    perform nrcell locked
     Lock Or Unlock Single Cell    cell_index=${301}    cell_type=nr    action=lock
     Verify The Status Of Single Cell    cell_index=${301}    cell_type=nr    action=lock
     Connect to gnb coam via ssl    connection=GNB_OAM
     coam.reset_site    wait_for_reconnection=${True}    timeout=600    connection=GNB_OAM
     sleep     60s
     Wait Until Keyword Succeeds    10 min    20 sec    Verify Gnb Type Cells Should Be Onair    cell_type=lte    connection=GNB_OAM
     Run Keyword And Continue On Failure    Procedures.Verify 4G L3 Call   ue_index=${1}
     ...                                   notbarred_cell_index=${131}
     ...                                   whether_check_on_air=${False}
     ...                                   whether_do_ue_prepare=${True}
     ...                                   dl_throughput=400MKbits/sec
     ...                                   start_keep_on_duration=1000
     ...                                   expect_dl_tput=2
     ...                                   expect_ul_tput=0
     ...                                   tput_collect_duration=180
     Log to console    perform nrcell unlocked
     Lock Or Unlock Single Cell    cell_index=${301}    cell_type=nr    action=unlock
     Verify The Status Of Single Cell    cell_index=${301}    cell_type=nr    action=unlock
     Procedures.Verify Non-CA Basic L3 Call    ue_index=${0}
     ...                                   dl_throughput=1600MKbits/sec
     ...                                   notbarred_cell_index=${301}
     ...                                   whether_stop_uelog=${False}
     ...                                   whether_start_uelog=${False}
     ...                                   whether_do_ue_prepare=${True}
     ...                                   start_keep_on_duration=3000
     ...                                   tput_collect_duration=180
     ...                                   apn_address=${tl.core.pdns[0].apn}
     Log to console    perform lte cell locked
     Lock Or Unlock Single Cell    cell_index=${131}    cell_type=lte    action=lock
     Verify The Status Of Single Cell    cell_index=${131}    cell_type=lte    action=lock
     Log to console    perform lte cell unlocked
     Lock Or Unlock Single Cell    cell_index=${131}    cell_type=lte    action=unlock
     Verify The Status Of Single Cell    cell_index=${131}    cell_type=lte    action=unlock
     Procedures.Verify Non-CA Basic L3 Call    ue_index=${0}
     ...                                   dl_throughput=1600MKbits/sec
     ...                                   notbarred_cell_index=${301}
     ...                                   whether_stop_uelog=${False}
     ...                                   whether_start_uelog=${False}
     ...                                   whether_do_ue_prepare=${True}
     ...                                   start_keep_on_duration=3000
     ...                                   tput_collect_duration=180
     ...                                   apn_address=${tl.core.pdns[0].apn}
     Run Keyword And Continue On Failure    Procedures.Verify 4G L3 Call   ue_index=${1}
     ...                                   notbarred_cell_index=${131}
     ...                                   whether_check_on_air=${False}
     ...                                   whether_do_ue_prepare=${True}
     ...                                   dl_throughput=400MKbits/sec
     ...                                   start_keep_on_duration=1000
     ...                                   expect_dl_tput=2
     ...                                   expect_ul_tput=0
     ...                                   tput_collect_duration=180
     [Teardown]    Run Keywords     TMO_Common_Case_Teardown   ue_index=${0}    AND
     ...    TMO_Common_Case_Teardown   ue_index=${1}    AND
     ...    Run Keyword And Ignore Error    Lock Or Unlock Single Cell    cell_index=${301}    cell_type=nr    action=unlock    AND
     ...    Run Keyword And Ignore Error    Lock Or Unlock Single Cell    cell_index=${131}    cell_type=lte    action=unlock
