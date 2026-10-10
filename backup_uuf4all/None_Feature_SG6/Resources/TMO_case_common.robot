*** Settings ***
Documentation    Auther:lei.jia@nokia-sbell.com

Resource    TMO_keyword_common.robot
Variables   ../TestData/5GC001304_5GC001301_variables.py

*** Variables ***
&{fault_48}           faultId=${48}
&{fault_1981}         faultId=${1981}
&{fault_49}           faultId=${49}
&{fault_10}           faultId=${10}
&{fault_4459}         faultId=${4459}
&{fault_4657}         faultId=${4657}
&{fault_1899}         faultId=${1899}
@{FAULT_4459_LIST}    &{fault_4459}    &{fault_4657}
${cellid}             301
${enb_mr_bts_id}      7373
${luashark_path}      /home/ute/luashark/luashark.lua
${MRBTS_ID}           ${tl.gnbs[0].instance_id}
${NRBTS_ID}           ${tl.gnbs[0].global_bts_id}
@{ul_direction_component}    UL_L2LO
@{dl_direction_component}    DL_L2LO
@{ul_dl_direction_component}    DL_L2LO    UL_L2LO
${enb_sw_web_path}    http://lterel.es-si-s3-z4.eecloud.nsn-net.net/build/
${anchore_enb_cellid}             73
${gnb_counter_prefix}             [D510_Sector1]





*** Keywords ***
L3_Call_UDP_80MHz_bandwidth_with_256QAM_mcs_27
    [Documentation]
    ...    This test case is used to test AEHC 40M 256QAM peak TP.
    ...    CHBW:80MHz
    [Arguments]    ${ul_data_transfer}=110M
    ...             ${expect_ul_tput}=90
    ...             ${expect_pcell_dl_tput}=195
    ...             ${expect_scell_dl_tput}=960
    ...             ${ue_index}=${0}
    ...             ${4G_check}=True
    ...             ${pcellid}=${None}
    ...             ${scellid}=${None}
    ...             ${reset_sol}=ue_reboot
    ...             ${modify_cell_ids}=${TDD_cell_list}
    ...             ${cellid}=1
    ${modify_param}    Modify All Chbw Para    bandwidth=80MHz    modify_cell_ids=${modify_cell_ids}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    timeout=900
    coam wait for gnb ready and cell setup     timeout=15 min
    Start Qualcomm L3 Call With CA    ul_data_transfer=${ul_data_transfer}
    ...                   expect_ul_tput=${expect_ul_tput}
    ...                   dl_data_transfer=1500M
    ...                   expect_pcell_dl_tput=${expect_pcell_dl_tput}
    ...                   expect_scell_dl_tput=${expect_scell_dl_tput}
    ...                   check_tput_duration=240
    ...                   pcellid=${pcellid}
    ...                   scellid=${scellid}
    ...                   4G_check=${4G_check}
    ...                   reset_sol=${reset_sol}
    ...                   ue_index=${ue_index}
    Run Keyword And Continue On Failure    Check RU Calibration Status And Power on Specifc RU    ru_type=AEHC    is_dualasik_used=True
#    [Teardown]    run keyword and ignore error    Change status for parameter cellBarred on GNB    exp_status=notBarred

L3_Call_UDP_40MHz_bandwidth_with_256QAM_mcs_27
    [Documentation]
    ...    This test case is used to test AEHC 40M 256QAM peak TP.
    ...    CHBW:40MHz
    [Arguments]    ${ul_data_transfer}=50M
    ...             ${expect_ul_tput}=22
    ...             ${expect_pcell_dl_tput}=195
    ...             ${expect_scell_dl_tput}=460
    ...             ${ue_index}=${0}
    ...             ${4G_check}=True
    ...             ${pcellid}=${None}
    ...             ${scellid}=${None}
    ...             ${reset_sol}=ue_reboot
    ...             ${modify_cell_ids}=${TDD_cell_list}
    ...             ${cellid}=1
    ${modify_param}    Modify All Chbw Para    bandwidth=40MHz    modify_cell_ids=${modify_cell_ids}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    timeout=900
    coam wait for gnb ready and cell setup     timeout=15 min
    Start Qualcomm L3 Call With CA    ul_data_transfer=${ul_data_transfer}
    ...                   expect_ul_tput=${expect_ul_tput}
    ...                   dl_data_transfer=1000M
    ...                   expect_pcell_dl_tput=${expect_pcell_dl_tput}
    ...                   expect_scell_dl_tput=${expect_scell_dl_tput}
    ...                   check_tput_duration=240
    ...                   pcellid=${pcellid}
    ...                   scellid=${scellid}
    ...                   4G_check=${4G_check}
    ...                   reset_sol=${reset_sol}
    ...                   ue_index=${ue_index}
    Run Keyword And Continue On Failure    Check RU Calibration Status And Power on Specifc RU    ru_type=AEHC    is_dualasik_used=True
#    [Teardown]    run keyword and ignore error    Change status for parameter cellBarred on GNB    exp_status=notBarred

L3_Call_UDP_100MHz_bandwidth_with_256QAM_mcs_27
    [Documentation]
    ...    This test case is used to test AEHC 100M 256QAM peak TP.
    ...    CHBW:10MHz
    [Arguments]    ${ul_data_transfer}=60M
    ...             ${expect_ul_tput}=50
    ...             ${expect_pcell_dl_tput}=195
    ...             ${expect_scell_dl_tput}=1190
    ...             ${ue_index}=${0}
    ...             ${4G_check}=True
    ...             ${pcellid}=${None}
    ...             ${scellid}=${None}
    ...             ${reset_sol}=ue_reboot
    ...             ${modify_cell_ids}=${TDD_cell_list}
    ...             ${cellid}=1
    ${modify_param}    Modify All Chbw Para    bandwidth=100MHz    modify_cell_ids=${modify_cell_ids}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    timeout=900
    coam wait for gnb ready and cell setup     timeout=15 min
    Start Qualcomm L3 Call With CA    ul_data_transfer=${ul_data_transfer}
    ...                   expect_ul_tput=${expect_ul_tput}
    ...                   dl_data_transfer=1800M
    ...                   expect_pcell_dl_tput=${expect_pcell_dl_tput}
    ...                   expect_scell_dl_tput=${expect_scell_dl_tput}
    ...                   check_tput_duration=240
    ...                   pcellid=${pcellid}
    ...                   scellid=${scellid}
    ...                   4G_check=${4G_check}
    ...                   reset_sol=${reset_sol}
    ...                   ue_index=${ue_index}
    Run Keyword And Continue On Failure    Check RU Calibration Status And Power on Specifc RU    ru_type=AEHC    is_dualasik_used=True
#    [Teardown]    run keyword and ignore error    Change status for parameter cellBarred on GNB    exp_status=notBarred

L3_Call_UDP_60MHz_bandwidth_with_256QAM_mcs_27
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...    This test case is used to test AEHC 50M 256QAM peak TP.
    ...    This test case is coverd 5G20B feature 5GC001076
    ...    CHBW:60MHz
    [Arguments]    ${ul_data_transfer}=70M
    ...             ${expect_ul_tput}=27
    ...             ${expect_pcell_dl_tput}=195
    ...             ${expect_scell_dl_tput}=720
    ...             ${ue_index}=${0}
    ...             ${4G_check}=True
    ...             ${pcellid}=${None}
    ...             ${scellid}=${None}
    ...             ${reset_sol}=ue_reboot
    ...             ${modify_cell_ids}=${TDD_cell_list}
    ...             ${cellid}=1
    ${modify_param}    Modify All Chbw Para    bandwidth=60MHz    modify_cell_ids=${modify_cell_ids}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    timeout=900
    coam wait for gnb ready and cell setup     timeout=15 min
    Start Qualcomm L3 Call With CA    ul_data_transfer=${ul_data_transfer}
    ...                   expect_ul_tput=${expect_ul_tput}
    ...                   dl_data_transfer=1200M
    ...                   expect_pcell_dl_tput=${expect_pcell_dl_tput}
    ...                   expect_scell_dl_tput=${expect_scell_dl_tput}
    ...                   check_tput_duration=240
    ...                   pcellid=${pcellid}
    ...                   scellid=${scellid}
    ...                   4G_check=${4G_check}
    ...                   reset_sol=${reset_sol}
    ...                   ue_index=${ue_index}
    Run Keyword And Continue On Failure    Check RU Calibration Status And Power on Specifc RU    ru_type=AEHC    is_dualasik_used=True
#    [Teardown]    run keyword and ignore error    Change status for parameter cellBarred on GNB    exp_status=notBarred


TOL_ForamtCell setup with PRACH format switchover bewteen B4 and C2
    [Documentation]
    ...    This test case is used to test tol case. Prach index changes from 206 to 158.
    ...    CHBW:60MHz
    ...    author: lei.jia@nokia-sbell.com
    [Arguments]    ${ul_data_transfer}=70M
    ...             ${expect_ul_tput}=27
    ...             ${expect_pcell_dl_tput}=195
    ...             ${expect_scell_dl_tput}=720
    ...             ${ue_index}=${0}
    ...             ${4G_check}=True
    ...             ${pcellid}=${None}
    ...             ${scellid}=${None}
    ...             ${reset_sol}=ue_reboot
    ...             ${modify_cell_ids}=${TDD_cell_list}
    ...             ${cellid}=1
    ${modify_param}    Modify All Chbw Para    bandwidth=60MHz    modify_cell_ids=${modify_cell_ids}    prachRootSequenceIndex=206
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    timeout=900
    coam wait for gnb ready and cell setup     timeout=15 min
    Start Qualcomm L3 Call With CA    ul_data_transfer=${ul_data_transfer}
    ...                   expect_ul_tput=${expect_ul_tput}
    ...                   dl_data_transfer=1200M
    ...                   expect_pcell_dl_tput=${expect_pcell_dl_tput}
    ...                   expect_scell_dl_tput=${expect_scell_dl_tput}
    ...                   check_tput_duration=240
    ...                   pcellid=${pcellid}
    ...                   scellid=${scellid}
    ...                   4G_check=${4G_check}
    ...                   reset_sol=${reset_sol}
    ...                   ue_index=${ue_index}
    ...                   stop_traffic=${False}
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    iperf_port=default
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=default
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    ${modify_param}    Modify All Chbw Para    bandwidth=60MHz    modify_cell_ids=${modify_cell_ids}    prachRootSequenceIndex=158
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    timeout=900
    coam wait for gnb ready and cell setup     timeout=15 min
    Start Qualcomm L3 Call With CA    ul_data_transfer=${ul_data_transfer}
    ...                   expect_ul_tput=${expect_ul_tput}
    ...                   dl_data_transfer=1200M
    ...                   expect_pcell_dl_tput=${expect_pcell_dl_tput}
    ...                   expect_scell_dl_tput=${expect_scell_dl_tput}
    ...                   check_tput_duration=240
    ...                   pcellid=${pcellid}
    ...                   scellid=${scellid}
    ...                   4G_check=${4G_check}
    ...                   reset_sol=${reset_sol}
    ...                   ue_index=${ue_index}
    ...                   is_do_require_ue=${False}
    Run Keyword And Continue On Failure    Check RU Calibration Status And Power on Specifc RU    ru_type=AEHC    is_dualasik_used=True
    [Teardown]    run keywords    CI_commssion.common commissioning     AND
    ...    run keyword and ignore error    Change status for parameter cellBarred on GNB    exp_status=notBarred


L3_Call_UDP_50MHz_bandwidth_with_256QAM_mcs_27
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...    This test case is used to test AEHC 50M 256QAM peak TP.
    ...    This test case is coverd 5G20B feature 5GC001076
    ...    CHBW:50MHz
    [Arguments]    ${ul_data_transfer}=70M
    ...             ${expect_ul_tput}=25
    ...             ${expect_pcell_dl_tput}=195
    ...             ${expect_scell_dl_tput}=610
    ...             ${ue_index}=${0}
    ...             ${4G_check}=True
    ...             ${pcellid}=${None}
    ...             ${scellid}=${None}
    ...             ${reset_sol}=ue_reboot
    ...             ${modify_cell_ids}=${TDD_cell_list}
    ...             ${cellid}=1
    ${modify_param}    Modify All Chbw Para    bandwidth=50MHz    modify_cell_ids=${modify_cell_ids}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    timeout=900
    coam wait for gnb ready and cell setup     timeout=15 min
    Start Qualcomm L3 Call With CA    ul_data_transfer=${ul_data_transfer}
    ...                   expect_ul_tput=${expect_ul_tput}
    ...                   dl_data_transfer=1000M
    ...                   expect_pcell_dl_tput=${expect_pcell_dl_tput}
    ...                   expect_scell_dl_tput=${expect_scell_dl_tput}
    ...                   check_tput_duration=240
    ...                   pcellid=${pcellid}
    ...                   scellid=${scellid}
    ...                   4G_check=${4G_check}
    ...                   reset_sol=${reset_sol}
    ...                   ue_index=${ue_index}
    Run Keyword And Continue On Failure    Check RU Calibration Status And Power on Specifc RU    ru_type=AEHC    is_dualasik_used=True
#    [Teardown]    run keyword and ignore error    Change status for parameter cellBarred on GNB    exp_status=notBarred

L3_Call_UDP_90MHz_bandwidth_with_256QAM_mcs_27
    [Documentation]    author: lei.jia@nokia-sbell.com
    ...    CHBW:90MHz
    [Arguments]    ${ul_data_transfer}=60M
    ...             ${expect_ul_tput}=50
    ...             ${expect_pcell_dl_tput}=195
    ...             ${expect_scell_dl_tput}=1100
    ...             ${ue_index}=${0}
    ...             ${4G_check}=True
    ...             ${pcellid}=${None}
    ...             ${scellid}=${None}
    ...             ${reset_sol}=ue_reboot
    ...             ${modify_cell_ids}=${TDD_cell_list}
    ...             ${cellid}=1
    ${modify_param}    Modify All Chbw Para    bandwidth=90MHz    modify_cell_ids=${modify_cell_ids}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    timeout=900
    coam wait for gnb ready and cell setup     timeout=15 min
    Start Qualcomm L3 Call With CA    ul_data_transfer=${ul_data_transfer}
    ...                   expect_ul_tput=${expect_ul_tput}
    ...                   dl_data_transfer=1700M
    ...                   expect_pcell_dl_tput=${expect_pcell_dl_tput}
    ...                   expect_scell_dl_tput=${expect_scell_dl_tput}
    ...                   check_tput_duration=240
    ...                   pcellid=${pcellid}
    ...                   scellid=${scellid}
    ...                   4G_check=${4G_check}
    ...                   reset_sol=${reset_sol}
    ...                   ue_index=${ue_index}
    Run Keyword And Continue On Failure    Check RU Calibration Status And Power on Specifc RU    ru_type=AEHC    is_dualasik_used=True
#    [Teardown]    run keyword and ignore error    Change status for parameter cellBarred on GNB    exp_status=notBarred

L3_Call_UDP_20MHz_bandwidth_with_256QAM_mcs_27
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...    This test case is used to test AEHC 20M 256QAM peak TP.
    ...    This test case is coverd 5G20B feature 5GC001076
    ...    CHBW:20MHz
    [Arguments]    ${ul_data_transfer}=30M
    ...             ${expect_ul_tput}=17
    ...             ${expect_pcell_dl_tput}=195
    ...             ${expect_scell_dl_tput}=190
    ...             ${ue_index}=${0}
    ...             ${4G_check}=True
    ...             ${pcellid}=${None}
    ...             ${scellid}=${None}
    ...             ${reset_sol}=ue_reboot
    ...             ${modify_cell_ids}=${TDD_cell_list}
    ...             ${cellid}=1
    ${modify_param}    Modify All Chbw Para    bandwidth=20MHz    modify_cell_ids=${modify_cell_ids}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    timeout=900
    coam wait for gnb ready and cell setup     timeout=15 min
    Start Qualcomm L3 Call With CA    ul_data_transfer=${ul_data_transfer}
    ...                   expect_ul_tput=${expect_ul_tput}
    ...                   dl_data_transfer=500M
    ...                   expect_pcell_dl_tput=${expect_pcell_dl_tput}
    ...                   expect_scell_dl_tput=${expect_scell_dl_tput}
    ...                   check_tput_duration=240
    ...                   pcellid=${pcellid}
    ...                   scellid=${scellid}
    ...                   4G_check=${4G_check}
    ...                   reset_sol=${reset_sol}
    ...                   ue_index=${ue_index}
    Run Keyword And Continue On Failure    Check RU Calibration Status And Power on Specifc RU    ru_type=AEHC    is_dualasik_used=True
#    [Teardown]    run keyword and ignore error    Change status for parameter cellBarred on GNB    exp_status=notBarred

#TOL_ForamtCell setup with PRACH format switchover bewteen B4 and C2
#    [Documentation]
#    ...    This test case is used to test tol case. Prach index changes from 206 to 158.
#    ...    CHBW:60MHz
#    ...    author: lei.jia@nokia-sbell.com
#    [Arguments]    ${ul_data_transfer}=30M
#    ...             ${expect_ul_tput}=27
#    ...             ${ue_index}=${0}
#    ...             ${4G_check}=True
#    ...             ${cellid}=${cellid}
#    ...             ${reset_sol}=ue_reboot
#    ...             ${actCarrierAggregation}=${False}
#    ...             ${list_all_cell_ids}=${False}
#    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
#    COAM Update Several Parameters Via Rest Api    parameters_to_update_via_api=${MODIFY_PARA_1301_05}    timeout=900
#    Coam Wait For Gnb Ready And Cell Setup    timeout=15 min
#    Verify RRH L3 Call With Qualcomm    ul_data_transfer=${ul_data_transfer}
#    ...                                 expect_ul_tput=${expect_ul_tput}
#    ...                                 dl_data_transfer=800M
#    ...                                 expect_dl_tput=720
#    ...                                 duration=300
#    ...                                 is_ulbler_calcu=${False}
#    ...                                 cellid=${cellid}
#    ...                                 hw_slot=${hw_slot}
#    ...                                 4G_check=${4G_check}
#    ...                                 reset_sol=${reset_sol}
#    ...                                 ue_index=${ue_index}
#    ...                                 actCarrierAggregation=${actCarrierAggregation}
#    ...                                 list_all_cell_ids=${list_all_cell_ids}
#    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    iperf_port=${UL_PORT}
#    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${DL_PORT}
#    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
#    COAM Update Several Parameters Via Rest Api    parameters_to_update_via_api=${MODIFY_PARA_1304_02}    timeout=900
#    Coam Wait For Gnb Ready And Cell Setup    timeout=15 min
#    sleep    3min
#    UE soft reboot
#    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
#    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}
#    Verify RRH L3 Call With Qualcomm    ul_data_transfer=${ul_data_transfer}
#    ...                                 expect_ul_tput=${expect_ul_tput}
#    ...                                 dl_data_transfer=800M
#    ...                                 expect_dl_tput=720
#    ...                                 duration=300
#    ...                                 is_ulbler_calcu=${False}
#    ...                                 cellid=${cellid}
#    ...                                 hw_slot=${hw_slot}
#    ...                                 4G_check=${4G_check}
#    ...                                 reset_sol=${reset_sol}
#    ...                                 ue_index=${ue_index}
#    ...                                 actCarrierAggregation=${actCarrierAggregation}
#    ...                                 list_all_cell_ids=${list_all_cell_ids}
#    Run Keyword And Continue On Failure    Wait until keyword succeeds    3X    60 s    Check RU Calibration Status And Power

TOL_Verify_SIB_Message
    [Documentation]    Auther: stella.lin@nokia-sbell.com
    ...    Verify SIB message is sent to UE
    ...    NR5G RRC OTA Packet  --  BCCH_BCH / Mib after RRC_Reconfig_Complete
    Start UE Attach With Power UE    hwcheck_index=${hw_slot}
    Start L3 Call With Power UE    ul_data_transfer=20M    dl_data_transfer=100M
    Bip Capture with gnbMirroring scripts with retry
    sleep  5sec
    ${bip_log}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC
    ...    log_prefix=sib_verification
    Verify SIB In MIB Message On gNB Side    bip_log=${bip_log[0]}

TOL_Harq_Verification
    [Documentation]     Auther: stella.lin@nokia-sbell.com
    ...    Steps: 1.Attenuate/De-attenuate NR signal.
    ...           2.Using DL TPUT, verify ack/nack is working properly
    Start UE Attach With Power UE    hwcheck_index=${hw_slot}
    Start L3 Call With Power UE    ul_data_transfer=20M    dl_data_transfer=100M
    Sleep    15sec
    Run Keyword And Ignore Error    Verify Throughput And UL Bler
    ...    direction_component_list=${dl_direction_component}    expect_dl_tput=${90}    duration=60
    ...    hw_slot=${hw_slot}    is_ulbler_calcu=${False}    cellid=${cellid}
    Connect to Common Unit Master
    Bip Capture with gnbMirroring scripts with retry
    Sleep    5 sec
    ${bip_with_ack}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC    log_prefix=ack
    Modify NR Signal    value=63
    Sleep    15sec
    Run Keyword And Ignore Error    Verify Throughput And UL Bler
    ...    direction_component_list=${dl_direction_component}    expect_dl_tput=${90}    duration=60
    ...    hw_slot=${hw_slot}    is_ulbler_calcu=${False}    cellid=${cellid}
    Bip Capture with gnbMirroring scripts with retry
    Sleep    5 sec
    ${bip_with_nack}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC    log_prefix=nack
    Modify NR Signal    value=0
    Run Keyword And Ignore Error    Verify Throughput And UL Bler
    ...    direction_component_list=${dl_direction_component}    expect_dl_tput=${90}    duration=60
    ...    hw_slot=${hw_slot}    is_ulbler_calcu=${False}    cellid=${cellid}
    Run Keyword And Continue On Failure    Verify ACK NACK With BIP    bip_log=${bip_with_ack[0]}
    Verify ACK NACK With BIP    bip_log=${bip_with_nack[0]}    ack_nack_type=NACK

TOL_Verify_Counter_For_DL_PDCP_Agg_And_ENDC
    [Documentation]    Auther:stella.lin@nokia-sbell.com
    ...                DL PDCP Agg & ENDC counter : M55315C00007, qos group is configured to 7 on mme side.
    ${counter_duration_scf}   Catenate    {'dist_name': 'NRBTS-${NRBTS_ID}/NRPMRNL-1', 'parameter': 'miNrS1UInterface','value': '5min'}
    ${parameter_to_modify}    Evaluate    [${counter_duration_scf}]
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameter_to_modify}
    ...                                            timeout=${180}
    ${counter_string}  Catenate  [{'M55315C00007': '[TL073_gNB_SA_NSA_AEHC_Concurrent] BTS/NRBTS-${NRBTS_ID}/NS1UB/DL_PDCP_SDU_RCV_S1U_QOS_GRP_07'}]
    ${dl_sdu_counter}    Evaluate    ${counter_string}
    Start UE Attach With Power UE    hwcheck_index=${hw_slot}
    Start L3 Call With Power UE    ul_data_transfer=20M    dl_data_transfer=100M
    ${time_to_start_traffic}    robot.libraries.DateTime.Get current date   result_format=%Y-%m-%d %H:%M:%S
    Run Keyword And Ignore Error    Verify Throughput And UL Bler
    ...    direction_component_list=${dl_direction_component}    expect_dl_tput=${90}    duration=60
    ...    hw_slot=${hw_slot}    is_ulbler_calcu=${False}    cellid=${cellid}
    sleep    360 sec
#    Verify Counter Added As Expected    counter_info_dict_list=${dl_sdu_counter}
#    ...                                 counter_generatd_time=${time_to_start_traffic}
#    ...                                 expect_added_value=10
    ${required_counter_values}    Get Required Counter Values    counter_info_dict_list=${dl_sdu_counter}
    ...                                                          counter_generatd_time=${time_to_start_traffic}
    Log    Result: ${required_counter_values}, duration is ${available_duration}.

TOL_Verify_Counter_For_UL_PDCP_Agg_And_ENDC
    [Documentation]    Auther:stella.lin@nokia-sbell.com
    ...                DL PDCP Agg & ENDC counter : M55315C02007, qos group is configured to 7 on mme side.
    ...                ulDataPath=ulOverLteNr_PrimaryPathOverNr
    ...                ulDataPathForUlSplitNotCapableUeulPrimaryPathOverNr
    ...                ulDataSplitThreshold=b12800
    ${counter_duration_scf}   Catenate    {'dist_name': 'NRBTS-${NRBTS_ID}/NRPMRNL-1', 'parameter': 'miNrS1UInterface','value': '5min'}
    ${parameter_to_modify}    Evaluate    [${counter_duration_scf}]
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameter_to_modify}
    ...                                            timeout=${180}
    ${counter_string}  Catenate  [{'M55315C02007': '[TL073_gNB_SA_NSA_AEHC_Concurrent] BTS/NRBTS-${NRBTS_ID}/NS1UB/UL_PDCP_SDU_SNT_S1U_QOS_GRP_07'}]
    ${ul_sdu_counter}    Evaluate    ${counter_string}
    Start UE Attach With Power UE    hwcheck_index=${hw_slot}
    Start L3 Call With Power UE    ul_data_transfer=20M    dl_data_transfer=100M
    ${time_to_start_traffic}    robot.libraries.DateTime.Get current date    result_format=%Y-%m-%d %H:%M:%S
    sleep    15 sec
    Run Keyword And Ignore Error    Verify Throughput And UL Bler
    ...    direction_component_list=${ul_direction_component}    expect_ul_tput=${15}    duration=60
    ...    hw_slot=${hw_slot}    is_ulbler_calcu=${False}    cellid=${cellid}
    sleep    360 sec
#    Verify Counter Added As Expected    counter_info_dict_list=${ul_sdu_counter}
#    ...                                 counter_generatd_time=${time_to_start_traffic}
#    ...                                 expect_added_value=10
    ${required_counter_values}    Get Required Counter Values    counter_info_dict_list=${ul_sdu_counter}
    ...                                                          counter_generatd_time=${time_to_start_traffic}
    Log    Result: ${required_counter_values}, duration is ${available_duration}.

TOL_SiSo_Auto_BTS_site_reset
    Set Test Variable    ${reset_times}    5
    Set Test Variable    ${fail_count}    0
    @{GNB_ALLOWED_FAULT}    Combine Lists    ${ALLOWED_FAULT}    ${FAULT_4459_LIST}
    run keyword and continue on failure    Unexpect Alarm Should Not Exist  allowed_faults=${GNB_ALLOWED_FAULT}
#    : FOR    ${count}    IN RANGE    ${reset_times}
#    \    ${reset_count}    evaluate    ${count} + 1
#    \    log to console    Try ${reset_count} times BTS site restart!
#    \    ${date_before_reset}    DateTime.Get Current Date
#    \    Perfrom gNB site reset with COAM
#    \    sleep     60s
#    \    run keyword and ignore error    COAM Teardown gnb connections
#    \    Wait Until Keyword Succeeds    300 sec    5 sec    Connect to gnb coam via ssl
#    \    ${status}=    Run Keyword And Return Status    COAM Wait for gnb ready and cell setup    timeout=20 min
#    \    Run Keyword If    '${status}'=='True'    Run Keywords
#        ...    Get Cluster Start Up time    ${date_before_reset}    AND
#        ...    Run Keyword And Continue On Failure    Wait until keyword succeeds    3X    60 s    Check RU Calibration Status And Power    AND
#        ...    Wait Until Keyword Succeeds    300 sec    5 sec    Connect to gnb coam via ssl    AND
#        ...    run keyword and continue on failure    Unexpect Alarm Should Not Exist   allowed_faults=@{GNB_ALLOWED_FAULT}
#        ...    ELSE       Interger Calculate    input_number=${fail_count}
    FOR    ${count}    IN RANGE    ${reset_times}
        ${reset_count}    evaluate    ${count} + 1
        log to console    Try ${reset_count} times BTS site restart!
        ${date_before_reset}    robot.libraries.DateTime.Get current date
        Perfrom gNB site reset with COAM
        sleep     60s
        run keyword and ignore error    COAM Teardown gnb connections
        Wait Until Keyword Succeeds    300 sec    5 sec    Connect to gnb coam via ssl
        ${status}=    Run Keyword And Return Status    COAM Wait for gnb ready and cell setup    timeout=20 min
        Run Keyword If    '${status}'=='True'    Run Keywords
        ...    Get Cluster Start Up time    ${date_before_reset}    AND
        ...    Run Keyword And Continue On Failure    Wait until keyword succeeds    3X    60 s    Check RU Calibration Status And Power    AND
        ...    Wait Until Keyword Succeeds    300 sec    5 sec    Connect to gnb coam via ssl    AND
        ...    run keyword and continue on failure    Unexpect Alarm Should Not Exist  allowed_faults=${GNB_ALLOWED_FAULT}
        ...    ELSE       Interger Calculate    input_number=${fail_count}
    END
    ${fail_rate}    Evaluate    float(${fail_count})/float(${reset_times})
    Log    Total reset ${reset_times} times, Fail ${fail_count} times, FAIL rate is ${fail_rate}

TOL_General_SiSo_RF_module_power_reset
    [Documentation]  Author: Jia Lei
    ...               This case is used to test AEHC concurrent mode.
    ...               Two enbs connected to one gnb. Anchor_eNB(enb0) is used to connect to MME.
    ...               Concurrent_enb(enb1) is used to perform RU sw upgrade.
    ...               Perform RF module power reset on concurrent enb(enb1) side.
    @{ALLOWED_FAULT_ID}    Combine Lists    ${ALLOWED_FAULT_ID}    ${FAULT_4459_LIST}
    set test variable    ${ALLOWED_FAULT_ID}
    run keyword and ignore error    COAM Teardown gnb connections
    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    General SiSo BTS Reset With RF Power Reset
    Run Keyword And Continue On Failure    Wait until keyword succeeds    3X    60 s    Check RU Calibration Status And Power

TOL_eCPRI_RU_logs_collection
    [Documentation]    author: lei.jia@nokia-sbell.com
    Connect to RU With Allocated IP
    Verify RFSW Log Include In Snapshot

TOL_SiSo_Antenna_carrier_configuration_conducted
    [Documentation]   author: lei.jia@nokia-sbell.com
    COAM Check GNB cell on air
    Run Keyword And Continue On Failure    Wait until keyword succeeds    3X    60 s    Check RU Calibration Status And Power

TOL_General_Reset_RF_Module_from_LTE
    [Documentation]  Author: Jia Lei
    ...               This case is used to test AEHC concurrent mode.
    ...               Two enbs connected to one gnb. Anchor_eNB(enb0) is used to connect to MME.
    ...               Concurrent_enb is used to perform RU sw upgrade.
    ...               Perform RF reset on concurrent enb(enb1) side.
    General RF Module Reset From LTE    enb_index=1
    Run Keyword And Continue On Failure    Wait until keyword succeeds    3X    60 s    Check RU Calibration Status And Power

TOL_General_Perform LTE-eNB_AirScale_reset
    [Documentation]  Author: Jia Lei
    ...               This case is used to test AEHC concurrent mode.
    ...               Two enbs connected to one gnb. Anchor_eNB(enb0) is used to connect to MME.
    ...               Concurrent_enb(enb1) is used to perform RU sw upgrade.
    ...               Perform concurrent enb(enb1) site reset.
    ...               2020-12-17:  PTP sync imporvement added at 5G20A CHILE 34P,
    ...               if PTP re-synch in radio is needed, radio will send "reset request" to system module
    ...               there will be 1981 alarm visible and radio gets reset.
    General_Perform eNB_site_reset    enb_index=1
    Run Keyword And Continue On Failure    Wait until keyword succeeds    3X    60 s    Check RU Calibration Status And Power

TOL_General_Lock_Unblock_RF_Module_from_LTE
    [Documentation]    xiangyue.zhou@nokia-sbell.com
    ...               2020/11/9 Jia Lei: two enbs connected to one gnb, add enb index
    ...               Note: Not supported until 20B
    ...               This case is used to test AEHC concurrent mode.
    ...               Two enbs connected to one gnb. Anchor_eNB(enb0) is used to connect to MME.
    ...               Concurrent_enb(enb1) is used to perform RU sw upgrade.
    ...               Perform RF lock unlock on concurrent enb(enb1) side.
    General SiSo RU Lock Unlock on eNB    enb_index=1    enb_mr_bts_id=${enb_mr_bts_id}
    Run Keyword And Continue On Failure    Wait until keyword succeeds    3X    60 s    Check RU Calibration Status And Power

TOL_General_Perform LTE-eNB_sw_upgrade
    [Documentation]    Auther: xiaoxia.hao@nokia-sbell.com, lei.jia@nokia-sbell.com
    ...                 This keyword is used to upgrade enb sw build for AEHC concurrent mode.
    ...                 Two enbs connected to one gnb. Anchor_eNB(enb0) is used to connect to MME.
    ...                 Concurrent_enb(enb1) is used to perform RU sw upgrade.
    ...                 Target enb sw build is stored under UTE file under folder /home/ute/SCF/AEHC_ENB_SW_Version.txt
    ...                 enb_0 is Anchor_eNB, used to connect to MME, enb_1 is used to upgrade AEHC SW.
    ...                 Perform Concurrent_enb(enb1) sw upgrade first, then upgrade gnb sw.
    ${enb_tartget_sw_version}    Get eNB Target Build From UTE
    Update eNB SW    SW=${enb_tartget_sw_version}    enb_index=1

TOL_Synchronization_Holdover_Support
    [Documentation]   author: lei.jia@nokia-sbell.com
    ...    Sub-feature:TOL concurrent mode
    ...               This case is used to test sync holdover. steps are as below
    ...               step1: Confirm gNB is up with no alarms.
    ...               step2: Modify sync input type to trigger holdover, Confirm GPS alarm is triggered
    ...               step3: Wait 5 minutes without GPS
	...               step4: recover sync to normal state, and Confirm GPS is detected and alarms cleared
    Synchronization Holdover Support

TOL_General_Cell_lock_and_unlock_from_LTE
    [Documentation]    author: lei.jia@nokia-sbell.com
    ...               This case is used to test AEHC concurrent mode.
    ...               Two enbs connected to one gnb. Anchor_eNB(enb0) is used to connect to MME.
    ...               Concurrent_enb(enb1) is used to perform RU sw upgrade.
    ...               Block/Unblock cell from Concurrent_enb(enb1)  while NR call is ongoing, verify NR call is continue.
    Start UE Attach With Power UE    hwcheck_index=${hw_slot}
    Start L3 Call With Power UE    ul_data_transfer=60M    dl_data_transfer=1000M    duration=4500
    ${time_to_start_traffic}    robot.libraries.DateTime.Get current date   result_format=%Y-%m-%d %H:%M:%S
    Run Keyword And Ignore Error    Verify Throughput And UL Bler
    ...    direction_component_list=${ul_dl_direction_component}
    ...    expect_ul_tput=40    expect_dl_tput=960    duration=300
    ...    hw_slot=${hw_slot}    is_ulbler_calcu=${False}    cellid=${cellid}
    Set Test Variable    ${reset_times}    2
#    : FOR    ${count}    IN RANGE    ${reset_times}
#    \    ${date_before_reset}    DateTime.Get Current Date
#    \    Run Keyword And Continue On Failure    General SiSo Cell Lock Unlock on eNB    enb_index=1    enb_mr_bts_id=${enb_mr_bts_id}
    FOR    ${count}    IN RANGE    ${reset_times}
        ${date_before_reset}    robot.libraries.DateTime.Get current date
        Run Keyword And Continue On Failure    General SiSo Cell Lock Unlock on eNB    enb_index=1    enb_mr_bts_id=${enb_mr_bts_id}
    END
    sleep    5min
    Run Keyword And Continue On Failure    Verify Throughput And UL Bler
    ...    direction_component_list=${ul_dl_direction_component}
    ...    expect_ul_tput=40    expect_dl_tput=900    duration=300
    ...    hw_slot=${hw_slot}    is_ulbler_calcu=${False}    cellid=${cellid}
    Run Keyword And Continue On Failure    Wait until keyword succeeds    3X    60 s    Check RU Calibration Status And Power

TOL_Phase1_Detection_and_Cancel
    [Documentation]
    ...    This test case is used to test sleeping cell phase1 alarm detection and cancel.
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    COAM Update Several Parameters Via Rest Api    parameters_to_update_via_api=${MODIFY_PARA_To_trigger_sleeping_cell}    timeout=900
    Coam Wait For Gnb Ready And Cell Setup    timeout=15 min
    log to console    INFO: check counter increment
    Check counter increment    M55601C00006
    Run Keyword And Continue On Failure    Wait For Expect Fault Present   faultId=${4547}   timeout=180
    log to console    INFO: Cancel Sleeping Cell alarm
    COAM Update Several Parameters Via Rest Api    parameters_to_update_via_api=${MODIFY_PARA_To_cancel_sleeping_cell}    timeout=900
    Run Keyword And Continue On Failure    Wait For Expect Fault To Disappear   faultId=${4547}  timeout=600
    Coam Wait For Gnb Ready And Cell Setup    timeout=15 min

TOL_Attach_Successfully_With_Default_PDCCH_Configuration
    [Documentation]    author: lei.jia@nokia-sbell.com
    ...    this test case is used to test L3 call when 2197 feature is deactivated.
    log to console    INFO: Deactivate 2197
    run keyword and ignore error    COAM Teardown gnb connections
	Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    COAM Update Several Parameters Via Rest Api    parameters_to_update_via_api=${MODIFY_PARA_Deactivate_2197}    timeout=900
    Coam Wait For Gnb Ready And Cell Setup    timeout=15 min
    Verify RRH L3 Call With Qualcomm    ul_data_transfer=60M
    ...                                 dl_data_transfer=1000M
    ...                                 expect_ul_tput=40
    ...                                 expect_dl_tput=960
    ...                                 duration=300
    ...                                 is_ulbler_calcu=${False}
    ...                                 cellid=${cellid}
    ...                                 hw_slot=${hw_slot}
    ...                                 4G_check=${False}

TOL_NR_RLF_Data_Recovery
    [Documentation]    Author: stella.lin@nokia-sbell.com
    ...                 for b1 based ENDC, please set actDynTrigLteNrDualConnectivity: 'true'
    Start UE Attach With Power UE    hwcheck_index=${hw_slot}
    Start L3 Call With Power UE    ul_data_transfer=20M    dl_data_transfer=100M    duration=1800
    sleep    15 sec
    Run Keyword And Ignore Error    Verify Throughput And UL Bler
    ...    direction_component_list=${ul_dl_direction_component}    expect_dl_tput=${90}    expect_ul_tput=${15}    duration=60
    ...    hw_slot=${hw_slot}    is_ulbler_calcu=${False}    cellid=${cellid}
    ${x2_NR_to_LTE}    Start CP-IF trace capturing    CPIF_log_prefix=x2_switch_data_NR_to_LTE    local_node_id=0x2011    hw_slot=${hw_slot}
    Modify NR Signal     value=63
    ${time_to_switch_traffic}    robot.libraries.DateTime.Get current date   result_format=%Y-%m-%d %H:%M:%S
    Run Keyword And Ignore Error    Verify Throughput And UL Bler
    ...    direction_component_list=${dl_direction_component}    expect_dl_tput=${90}    duration=60
    ...    hw_slot=${hw_slot}    is_ulbler_calcu=${False}    cellid=${cellid}
    Stop trace capturing    log_prefix=x2_switch_data_NR_to_LTE
    Sleep    15min
    Run Keyword And Continue On Failure    Verify Data Continues On LTE
    ...                                    data_switch_time=${time_to_switch_traffic}
    ...                                    expect_data_amount=10
    ${x2_LTE_to_NR}    Start CP-IF trace capturing    CPIF_log_prefix=x2_switch_data_LTE_to_NR    local_node_id=0x2011    hw_slot=${hw_slot}
    Modify NR Signal     value=0
    Run Keyword And Continue On Failure    Verify Throughput And UL Bler
    ...    direction_component_list=${ul_dl_direction_component}    expect_dl_tput=${90}    expect_ul_tput=${15}    duration=60
    ...    hw_slot=${hw_slot}    is_ulbler_calcu=${False}    cellid=${cellid}
    Stop trace capturing    log_prefix=x2_switch_data_LTE_to_NR
    Run Keyword And Continue On Failure    Download trace log    log_full_path=${x2_NR_to_LTE}
    Download trace log    log_full_path=${x2_LTE_to_NR}

TOL_Verify_Counter_For_UL_Leg_Switch
    [Documentation]     Author: stella.lin@nokia-sbell.com
    ...                 verify counter M55146C01004 & M55146C01003
    ...                 for b1 based ENDC, please set actDynTrigLteNrDualConnectivity: 'true'
    Modify UL Leg Switch Case Related Parameters
    Start UE Attach With Power UE    hwcheck_index=${hw_slot}
    Start L3 Call With Power UE    ul_data_transfer=20M    dl_data_transfer=100M    duration=1800
    Run Keyword And Ignore Error    Verify Throughput And UL Bler
    ...    direction_component_list=${ul_direction_component}    expect_ul_tput=${15}    duration=60
    ...    hw_slot=${hw_slot}    is_ulbler_calcu=${False}    cellid=${cellid}
    ${x2_NR_to_LTE}    Start CP-IF trace capturing    CPIF_log_prefix=x2_switch_data_NR_to_LTE    local_node_id=0x2011    hw_slot=${hw_slot}
    Modify NR Signal     value=63
    ${time_to_switch_traffic}    robot.libraries.DateTime.Get current date    result_format=%Y-%m-%d %H:%M:%S
    Run Keyword And Ignore Error    Verify Throughput And UL Bler
    ...    direction_component_list=${ul_direction_component}    expect_ul_tput=${15}    duration=60
    ...    hw_slot=${hw_slot}    is_ulbler_calcu=${False}    cellid=${cellid}
    Stop trace capturing    log_prefix=x2_switch_data_NR_to_LTE
    sleep    15min
    Run Keyword And Continue On Failure    Verify Data Continues On LTE
    ...                                    data_switch_time=${time_to_switch_traffic}
    ...                                    expect_data_amount=10
    ...                                    dl_ul_type=UL
    ${counter_string}    Catenate    [{'M55146C01003': '${gnb_counter_prefix} CELLS/NRCELL-${cellid}/NRBC/UL_DATA_SPLIT_RECONF_NR_ATT'},
    ...                       {'M55146C01004': '${gnb_counter_prefix} CELLS/NRCELL-${cellid}/NRBC/UL_DATA_SPLIT_RECONF_NR_SUCC'}]
    ${ul_leg_switch_counter}    Evaluate    ${counter_string}
#    Run Keyword And Continue On Failure    Verify Counter Added As Expected    counter_info_dict_list=${ul_leg_switch_counter}
#    ...                                    counter_generatd_time=${time_to_switch_traffic}
#    ...                                    expect_added_value=10
    ${required_counter_values}    Run Keyword And Continue On Failure    Get Required Counter Values
    ...                                                                  counter_info_dict_list=${ul_leg_switch_counter}
    ...                                                                  counter_generatd_time=${time_to_switch_traffic}
    Log    Result: ${required_counter_values}, duration is ${available_duration}.
    ${x2_LTE_to_NR}    Start CP-IF trace capturing    CPIF_log_prefix=x2_switch_data_LTE_to_NR    local_node_id=0x2011    hw_slot=${hw_slot}
    Modify NR Signal     value=0
    ${time_to_switch_back}    robot.libraries.DateTime.Get current date    result_format=%Y-%m-%d %H:%M:%S
    Run Keyword And Continue On Failure    Verify Throughput And UL Bler
    ...    direction_component_list=${ul_direction_component}    expect_ul_tput=${15}    duration=60
    ...    hw_slot=${hw_slot}    is_ulbler_calcu=${False}    cellid=${cellid}
    Stop trace capturing    log_prefix=x2_switch_data_LTE_to_NR
    ${required_counter_values}    Run Keyword And Continue On Failure    Get Required Counter Values
    ...                                                                  counter_info_dict_list=${ul_leg_switch_counter}
    ...                                                                  counter_generatd_time=${time_to_switch_back}
    Log    Result: ${required_counter_values}, duration is ${available_duration}.
    Run Keyword And Continue On Failure    Download trace log    log_full_path=${x2_NR_to_LTE}
    Download trace log    log_full_path=${x2_LTE_to_NR}

TOL_UL_Leg_Switch
    [Documentation]     Auther: stella.lin@nokia-sbell.com
    Run Keyword If    '${PREV_TEST_STATUS}'=='PASS'    pass execution   UL leg switch passed.
    Modify UL Leg Switch Case Related Parameters
    Start UE Attach With Power UE    hwcheck_index=${hw_slot}
    Start L3 Call With Power UE    ul_data_transfer=20M    dl_data_transfer=100M    duration=1800
    Run Keyword And Ignore Error    Verify Throughput And UL Bler
    ...    direction_component_list=${ul_direction_component}    expect_ul_tput=${15}    duration=60
    ...    hw_slot=${hw_slot}    is_ulbler_calcu=${False}    cellid=${cellid}
    Modify NR Signal     value=63
    ${time_to_switch_traffic}    robot.libraries.DateTime.Get current date    result_format=%Y-%m-%d %H:%M:%S
    Run Keyword And Ignore Error    power_ue.Check throughput
    ...                             ue_type=${ue_type}    direction=ul    throughput=${15}    hw_slot=${hw_slot}    cellid=${cellid}
    sleep    15min
    Run Keyword And Continue On Failure    Verify Data Continues On LTE
    ...                                    data_switch_time=${time_to_switch_traffic}
    ...                                    expect_data_amount=10
    ...                                    dl_ul_type=UL
    Modify NR Signal     value=0
    Verify Throughput And UL Bler
    ...    direction_component_list=${ul_direction_component}    expect_ul_tput=${15}    duration=60
    ...    hw_slot=${hw_slot}    is_ulbler_calcu=${False}    cellid=${cellid}

TOL_Dynamic_Power_Sharing
    [Documentation]    Auther:stella.lin@nokia-sbell.com
    ...      Qualcomm UE SDX50 is not supported dynamic power sharing, as ue capability does not contain "dynamicPowerSharingENDC: supported"
    Start UE Attach With Power UE    hwcheck_index=${hw_slot}
#    ${x2_log_path}    Start UE Attach With Power UE    is_wireshark_log_capture=${True}    hwcheck_index=${hw_slot}
    Start L3 Call With Power UE    ul_data_transfer=20M    dl_data_transfer=100M
    Bip Capture with gnbMirroring scripts with retry
    sleep    5sec
    ${bip_log_0}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC
    ...    log_prefix=dynamic_power_sharing_00
    Modify LTE Signal    value=35
    Bip Capture with gnbMirroring scripts with retry
    sleep    5sec
    ${bip_log_1}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC
    ...    log_prefix=dynamic_power_sharing_01
    Modify LTE Signal    value=50
    Bip Capture with gnbMirroring scripts with retry
    sleep    5sec
    ${bip_log_2}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC
    ...    log_prefix=dynamic_power_sharing_02
    ${rx_power_0}    Get RxPower From BIP    bip_log=${bip_log_0[0]}
    ${rx_power_1}    Get RxPower From BIP    bip_log=${bip_log_1[0]}
    ${rx_power_2}    Get RxPower From BIP    bip_log=${bip_log_2[0]}
    Run Keyword And Continue On Failure
    ...     Should Be True    ${rx_power_0['pusch_rxpower']}>${rx_power_1['pusch_rxpower']}>${rx_power_2['pusch_rxpower']}
    ...                       msg=pusch rxpower is not dynamic sharing.
    Should Be True    ${rx_power_0['pucch_rxpower']}>${rx_power_1['pucch_rxpower']}>${rx_power_2['pucch_rxpower']}
    ...               msg=pucch rxpower is not dynamic sharing.

TOL_General_GNSS reset_via_WebUI
    [Documentation]   author: lei.jia@nokia-sbell.com
    ...    Sub-feature:TOL concurrent mode
    General_GNSS reset on ENB via Admin CLI    enb_index=1
