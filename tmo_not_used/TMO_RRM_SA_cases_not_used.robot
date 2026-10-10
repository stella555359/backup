#*** Settings ***
#Documentation    TMO Automation for SA RRM cases
#...              Author: jun.8.chen@nokia-sbell.com
#Suite Setup    TMO_Common_Suite_Setup    is_commission=${True}    prefer_5g_nr_mode=SA
#Test Teardown    TMO_Common_Case_Teardown
#Suite Teardown    TMO_Suite_Teardown
#Force Tags    5G_TOL    SG_06
#...    PY36
#
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_common_keywords.robot
#
#*** Variables ***
#${target_version}
#${package_version_1525-CA}      ${target_version}
#
#*** Test Cases ***
#5603003_TOL_21A_5GC1390_RRM04_TDD_2200_4CSIRS_outside_FDD_CDRX_ON_duration_1UE_FT_CA_SA_withDRX_sleep_status
#    [Documentation]    TL813:UE0-SDX65, 5G SA CA call, AHFIG0+AEHC0, 5gcell_21+301
#    [Tags]    TA_NOT_NEEDED
#    [Setup]    TMO_Common_Case_Setup
#    FOR    ${enb_index}    IN RANGE    ${enb_length}
#        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
#    END
#    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#    ${attach_info}    Procedures.Verify CA Basic L3 Call    whether_check_tupt=${False}
#    ...                                                     whether_start_dl_call=${False}
#    ...                                                     whether_start_ul_call=${False}
#    ...                                                     enb_index=${fdd_enb_index}
#    ${host}   Start To Capture Aasyslog    gnb_index=${0}    du_index=${0}
#    FOR    ${i}    IN RANGE    ${5}
#        Procedures.Start TMO L3 Call    cpif_log_path=${attach_info['cpif_log_path']}
#        ...                             ul_throughput=250M
#        ...                             dl_throughput=2000MKbits/sec
#        ...                             start_keep_on_duration=30
#        ...                             iperf_path=/data/local/tmp/iperf
#        ...                             whether_start_ul_call=${False}
#        Sleep    31sec
#    END
#    ${tupt_file_path}    Stop To Capture And Download Aasyslog    host=${host}
#    Procedures.Check TMO Throughput    ue_index=${0}
#    ...                                addition_scell_index_list=${SCELL_INDEX_LIST}
#    ...                                ignore_time=5sec
#    ...                                tput_collect_duration=300
#    ...                                whether_collect_tput=${False}
#    ...                                tput_file_use_collected=${tupt_file_path}
#    ...                                min_DL_percent=0
#    ...                                min_UL_percent=0
#    ...                                min_scell_percent=0
#    ...                                check_ul_pcell_tput_type=no_data
#    ...                                check_pcell_tput_type=layer4
#    ...                                target_DL_avg_percent=0.7
#
#5603002_TOL_21A_5GC1390_RRM02_TDD_2200_4CSIRS_FDD_CDRX_ON_1UE_FT_CA_SA_withVONR_ScellActivation_bufferbased
#    [Documentation]    TL813:UE0-SDX65, 5G SA CA call, ahfig0+aehc0, 5gcell_21+301, UL 2CC, sCellOperationalMode=dlAndUl
#    [Tags]    TA_NOT_NEEDED
#    [Setup]    TMO_Common_Case_Setup
#    FOR    ${enb_index}    IN RANGE    ${enb_length}
#        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
#    END
#    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#    Procedures.Verify CA Basic L3 Call    ul_throughput=250M
#    ...                                   dl_throughput=1800MKbits/sec
#    ...                                   start_keep_on_duration=2400
#    ...                                   tput_collect_duration=120
#    ...                                   whether_need_ue_log=${False}
#    ...                                   check_pcell_tput_type=layer4
#    ...                                   whether_check_scell_addition=${False}
#    ...                                   ignore_time=15sec
#    ...                                   enb_index=${fdd_enb_index}
#    ${host}   Start To Capture Aasyslog    gnb_index=${0}    du_index=${0}
#    Run Keyword And Continue On Failure    Start CP-IF Log Collection
#    ...                                    tcpdump_collector_name=vonr_call
#    ...                                    asik_connection_alias=ASIK Master
#    ...                                    gnb_index=${0}
#    ...                                    options=-i any '((sctp) and ((port 38472) or (port 38412) or (port 38422) or (port 38462)))' -s 0
#    Make Vonr Call
#    Sleep    10sec
#    Hang Up Vonr Call
#    ${vonr_wireshark}    Run Keyword And Continue On Failure    Stop tcpdump log collection    tcpdump_collector_name=vonr_call
#    ${tupt_file_path}    Stop To Capture And Download Aasyslog    host=${host}
#    Procedures.Check TMO Throughput    ue_index=${0}
#    ...                                addition_scell_index_list=${SCELL_INDEX_LIST}
#    ...                                whether_collect_tput=${False}
#    ...                                tput_file_use_collected=${tupt_file_path}
#    ...                                check_pcell_tput_type=layer4
#    Check VoNR Call Success    log_path=${vonr_wireshark}
#
#5603071_TOL_case_71_5GTddCall_CA_del_oneNRREL_on_TddNrCell_5GTddCall_CAcall_add_oneNRREL_on_TddNrCell_5GTddCall_Cacall
#    [Tags]    TA_Not_Start
#    [Setup]    TMO_Common_Case_Setup
#    # Below delete all nrrel and make L3 call, make sure it's non-ca call.
#    ${delete_nrrel_param_list}    ${add_nrrel_param_list}   Get The Parameter List Of NRREL Config
#    Set Test Variable    ${DELETE_NRREL_PARAM_LIST}    ${delete_nrrel_param_list}
#    Set Test Variable    ${ADD_NRREL_PARAM_LIST}    ${add_nrrel_param_list}
#    Add Or Delete Scell Of All NR Cells    param_list=${DELETE_NRREL_PARAM_LIST}
#    FOR    ${enb_index}    IN RANGE    ${enb_length}
#        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
#    END
#    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#    ${attach_info}    Procedures.Verify CA Basic L3 Call    ul_throughput=200M
#    ...                                                     dl_throughput=1800MKbits/sec
#    ...                                                     whether_check_scell_addition=${False}
#    ...                                                     check_scell_tput=${False}
#    ...                                                     enb_index=${fdd_enb_index}
#    # Comment: need to add check point--above call is Non-CA call via wireshark.
#    # Below add all nrrel and make L3 call, make sure it's ca call.
#    ${status}  Run Keyword And Return Status    Add Or Delete Scell Of All NR Cells    param_list=${ADD_NRREL_PARAM_LIST}
#    Procedures.Verify CA Basic L3 Call    ul_throughput=200M    dl_throughput=2500MKbits/sec
#    ...                                                     enb_index=${fdd_enb_index}
#    [Teardown]    Run Keywords    TMO_Common_Case_Teardown
#    ...    AND    Run Keyword If  ${status}==${False}    Add Or Delete Scell Of All NR Cells    param_list=${ADD_NRREL_PARAM_LIST}
#
#
#5603016_TOL_22R1_CB8015_RRM01_Pcellchange_A1based
#    [Tags]    TA_ongoing
#    [Documentation]      Pcell change based on A1, decrease scell PA to trigger (scell rsrp larger than a1ThresholdPCellSwitchSsbRsrp)
#    ...                 for SDX60, Qualcomm UE has the limitation that after pcell change ,DL tp will drop to 1 layer and can’t be reach peak
#    [Setup]  TMO_Common_Case_Setup
#    FOR    ${enb_index}    IN RANGE    ${enb_length}
#        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
#    END
#    ${a1ThresholdPCellSwitchSsbRsrp}    set variable if    '${stream_version}' == 'master'    86    80
#    Modify Pcell Change Based On A1 Related Paremeters    pcell_index=${PCELL_INDEX}    scell_index=${SCELL_INDEX_LIST}[0]
#    ...    a1ThresholdPCellSwitchSsbRsrp=${a1ThresholdPCellSwitchSsbRsrp}
#    ${scell_ru_index}    Set Variable    ${SCELL_MAPPING[${SCELL_INDEX_LIST}[0]]['all_cell_info']['ru_index_mapping']}
#    ${ru_whether_connect_mcs}    Check RU Whether Connect Mcs    ru_index=${scell_ru_index}
#    FOR    ${attenuator}    IN    @{attenuator_list}
#        Run Keyword If    '${attenuator}'=='pa'    Modify PA Value Setting For Required RU    modify_ru_id=${scell_ru_index}
#        ...                                                                                   ue_index=${0}
#        ...                                                                                   pa_off_value=35
#        ...    ELSE IF    '${attenuator}'=='mcs' and ${ru_whether_connect_mcs}
#        ...                                       Set Case Related MCS Port Value    att_value=20
#        ...                                                                          ue_index=${0}
#        ...                                                                          whether_do_Angles=${False}
#        ...                                                                          whether_do_mcs_setup=${False}
#        ...    ELSE    Log To Console     ${\n}INFO: --Use the wrong attenuator type(${attenuator}), need to check TMO_Data.py--
#    END
#    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#    ${attach_info}    Procedures.Verify CA Basic L3 Call    ul_throughput=200M
#    ...                                                     dl_throughput=2500MKbits/sec
#    ...                                                     tput_collect_duration=120
#    ...                                                     whether_need_ue_log=${False}
#    ...                                                     whether_check_scell_addition=${False}
#    ...                                                     ignore_time=15sec
#    ...                                                     check_pcell_tput_type=peak
#    ...                                                     check_scell_tput_type=not_peak
#    ...                                                     check_ul_pcell_tput_type=peak
#    ...                                                     enb_index=${fdd_enb_index}
#    Get Pcell And Scell Mapping Info For Pcell Change    ho_pcell_index=${SCELL_INDEX_LIST}[0]
#    Run Keyword And Continue On Failure    Start CP-IF Log Collection
#    ...    tcpdump_collector_name=pcell_change
#    ...    asik_connection_alias=ASIK Master
#    ...    gnb_index=${0}
#    ...    options=-i any '((sctp) and ((port 38472) or (port 38412) or (port 38462) or (port 36422) or (port 38422)))' -s 0
#    FOR    ${attenuator}    IN    @{attenuator_list}
#        Run Keyword If    '${attenuator}'=='pa'    Modify PA Value Setting For Required RU    modify_ru_id=${scell_ru_index}
#        ...                                                                                   ue_index=${0}
#        ...    ELSE IF    '${attenuator}'=='mcs' and ${ru_whether_connect_mcs}
#        ...                                        Set Case Related MCS Port Value    att_value=0
#        ...                                                                           ue_index=${0}
#        ...                                                                           whether_do_Angles=${False}
#        ...                                                                           whether_do_mcs_setup=${False}
#        ...    ELSE    Log To Console     ${\n}INFO: --Use the wrong attenuator type(${attenuator}), need to check TMO_Data.py--
#    END
#    Sleep    30sec
#    ${pcell_change_wireshark}    Run Keyword And Continue On Failure    Stop tcpdump log collection    tcpdump_collector_name=pcell_change
#    # Check TUPT after pcell change
#    Run Keyword And Continue On Failure    Procedures.Check TMO Throughput    ue_index=${0}
#    ...                                                                       addition_scell_index_list=${HO_SCELL_INDEX_LIST}
#    ...                                                                       pcell_mapping=${HO_PCELL_MAPPING}
#    ...                                                                       scell_mapping=${HO_SCELL_MAPPING}
#    ...                                                                       tput_collect_duration=120
#    ...                                                                       ignore_time=5sec
#    ...                                                                       check_pcell_tput_type=peak
#    ...                                                                       check_scell_tput_type=peak
#    ...                                                                       check_ul_pcell_tput_type=peak
#    # Check pcell change based on A1
#    Check Pcell Change Success    attach_info=${attach_info}
#    ...                           pcell_change_wireshark_log=${pcell_change_wireshark}
#    ...                           event_type=A1
#    ...                           scell_index=${SCELL_INDEX_LIST}[0]
#    ...                           after_change_scell_index=${HO_SCELL_INDEX_LIST}[0]
#    [Teardown]    Run Keywords    TMO_Common_Case_Teardown
#    ...                    AND    Modify Pcell Change Based On A1 Related Paremeters    pcell_index=${PCELL_INDEX}
#    ...                                                                                 scell_index=${SCELL_INDEX_LIST}[0]
#    ...                                                                                 a1BasedPCellSwitchEnabled=false
#    ...                                                                                 a2MeasSCellRelEnabled=none
#    ...                                                                                 a1MeasPCellSwitchEnabled=none
#    ...                                                                                 a1ThresholdPCellSwitchSsbRsrp=116
#    ...                                                                                 a1MeashoEnabledSA=rsrp
#    ...                                                                                 a2MeashoEnabledSA=rsrp
#
#5603017_TOL_22R1_CB8015_RRM02_Pcellchange_A2based_from_TFCA_to_FTCA
#    [Documentation]    Check Pcell Change,T(pcell)+F(scell) --> F(pcell)+T(scell)(scell selection based on sortlist)
#    ...                  Pcell change based on A2, increase pcell PA to trigger (make pcell rsrp lower than a2ThresholdPCellSwitchSsbRsrp)
#    [Tags]    TA_ongoing
#    [Setup]  TMO_Common_Case_Setup
#    FOR    ${enb_index}    IN RANGE    ${enb_length}
#        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
#    END
#    ${a2ThresholdPCellSwitchSsbRsrp}    set variable if    '${stream_version}' == 'master'    76    76
#    Modify Pcell Change Based On A2 Related Paremeters    pcell_index=${PCELL_INDEX}    scell_index=${SCELL_INDEX_LIST}[0]
#    ...    a2ThresholdPCellSwitchSsbRsrp=${a2ThresholdPCellSwitchSsbRsrp}
#    ${scell_ru_index}    Set Variable    ${SCELL_MAPPING[${SCELL_INDEX_LIST}[0]]['all_cell_info']['ru_index_mapping']}
#    ${ru_whether_connect_mcs}    Check RU Whether Connect Mcs    ru_index=${scell_ru_index}
#    FOR    ${attenuator}    IN    @{attenuator_list}
#        Run Keyword If    '${attenuator}'=='pa'    Modify PA Value Setting For Required RU    modify_ru_id=${scell_ru_index}
#        ...                                                                                   ue_index=${0}
#        ...                                                                                   pa_off_value=20
#        ...    ELSE IF    '${attenuator}'=='mcs' and ${ru_whether_connect_mcs}
#        ...                                       Set Case Related MCS Port Value    att_value=20
#        ...                                                                          ue_index=${0}
#        ...                                                                          whether_do_Angles=${False}
#        ...                                                                          whether_do_mcs_setup=${False}
#        ...    ELSE    Log To Console     ${\n}INFO: --Use the wrong attenuator type(${attenuator}), need to check TMO_Data.py--
#    END
#    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#    ${attach_info}    Procedures.Verify CA Basic L3 Call    ul_throughput=190M
#    ...                                                     dl_throughput=2200MKbits/sec
#    ...                                                     tput_collect_duration=120
#    ...                                                     whether_need_ue_log=${False}
#    ...                                                     ignore_time=15sec
#    ...                                                     check_pcell_tput_type=peak
#    ...                                                     check_scell_tput_type=peak
##    ...                                                     check_scell_tput=${False}
#    ...                                                     check_ul_pcell_tput_type=layer1
#    ...                                                     enb_index=${fdd_enb_index}
#    Get Pcell And Scell Mapping Info For Pcell Change    ho_pcell_index=${SCELL_INDEX_LIST}[0]
#    Change cellBarred Parameter Value On Gnb    pcell_index=${SCELL_INDEX_LIST}[0]    exp_status=notBarred
#    Run Keyword And Continue On Failure    Start CP-IF Log Collection
#    ...    tcpdump_collector_name=pcell_change
#    ...    asik_connection_alias=ASIK Master
#    ...    gnb_index=${0}
#    ...    options=-i any '((sctp) and ((port 38472) or (port 38412) or (port 38462) or (port 36422) or (port 38422)))' -s 0
#    FOR    ${attenuator}    IN    @{attenuator_list}
#        Run Keyword If    '${attenuator}'=='pa'    Modify PA Value Setting For Required RU    modify_ru_id=${scell_ru_index}
#        ...                                                                                   ue_index=${0}
#        ...    ELSE IF    '${attenuator}'=='mcs' and ${ru_whether_connect_mcs}
#        ...                                        Set Case Related MCS Port Value    att_value=0
#        ...                                                                           ue_index=${0}
#        ...                                                                           whether_do_Angles=${False}
#        ...                                                                           whether_do_mcs_setup=${False}
#        ...    ELSE    Log To Console     ${\n}INFO: --Use the wrong attenuator type(${attenuator}), need to check TMO_Data.py--
#    END
#    ${ru_whether_connect_mcs}    Check RU Whether Connect Mcs    ru_index=${PCELL_MAPPING['ru_index_mapping']}
#    FOR    ${attenuator}    IN    @{attenuator_list}
#        Run Keyword If    '${attenuator}'=='pa'    Modify PA Value Setting For Required RU
#        ...                      modify_ru_id=${PCELL_MAPPING['ru_index_mapping']}    ue_index=${0}    pa_off_value=35
#        ...    ELSE IF    '${attenuator}'=='mcs' and ${ru_whether_connect_mcs}
#        ...                      Set Case Related MCS Port Value    att_value=30    ue_index=${0}    whether_do_Angles=${False}
#        ...                                                         whether_do_mcs_setup=${False}
#    END
#    Sleep    5sec
#    ${pcell_change_wireshark}    Run Keyword And Continue On Failure    Stop tcpdump log collection    tcpdump_collector_name=pcell_change
#    # Check TUPT after pcell change
#
#    Run Keyword And Continue On Failure     Procedures.Check TMO Throughput    ue_index=${0}
#    ...                                                                        addition_scell_index_list=${HO_SCELL_INDEX_LIST}
#    ...                                                                        pcell_mapping=${HO_PCELL_MAPPING}
#    ...                                                                        scell_mapping=${HO_SCELL_MAPPING}
#    ...                                                                        tput_collect_duration=120
#    ...                                                                        ignore_time=5sec
#    ...                                                                        check_pcell_tput_type=peak
#    ...                                                                        check_scell_tput_type=not_peak
#    ...                                                                        check_ul_pcell_tput_type=peak
#    # Check pcell change based on A2
#    Check Pcell Change Success    attach_info=${attach_info}
#    ...                           pcell_change_wireshark_log=${pcell_change_wireshark}
#    ...                           event_type=A2
#    ...                           scell_index=${SCELL_INDEX_LIST}[0]
#    ...                           after_change_scell_index=${HO_SCELL_INDEX_LIST}[0]
#    [Teardown]    Run Keywords    TMO_Common_Case_Teardown
#    ...                    AND    Modify Pcell Change Based On A2 Related Paremeters    pcell_index=${PCELL_INDEX}
#    ...                                                                                 scell_index=${SCELL_INDEX_LIST}[0]
#    ...                                                                                 a2BasedPCellSwitchEnabled=false
#    ...                                                                                 a2MeasPCellSwitchEnabled=none
#    ...                                                                                 a2ThresholdPCellSwitchSsbRsrp=50
#    ...                                                                                 a2ThresholdhoSsbRsrpSA=50
#
#5603013_TOL_22R1_CB007922_CB8145_RRM03_1UE_CA_LinkAdaption_bufferBased
#    [Tags]    TA_NOT_NEEDED
#    [Setup]    TMO_Common_Case_Setup
#    Run Keyword If    '${ue_type}'!='huawei_sigspark'    Fail    msg=This case need to run on the spark enviorment.
#    TOL_case_RRM_SA_1UE_LinkAdaption_TCP    whether_start_ul_call=${False}
#    ...                                     log_name=tcp_dl_CA
#    ...                                     check_ul_pcell_tput_type=no_data
#    ...                                     min_DL_percent=0
#    ...                                     min_scell_percent=0
#    ...                                     check_ul_pcell_tput_type_after_la=no_data
#
#5603057_TOL_22R1_CB007922_CB8145_RRM03_1UE_CA_LinkAdaption_bufferBased_UL_TCP
#    [Tags]    TA_NOT_NEEDED
#    [Setup]    TMO_Common_Case_Setup
#    Run Keyword If    '${ue_type}'!='huawei_sigspark'    Fail    msg=This case need to run on the spark enviorment.
#    TOL_case_RRM_SA_1UE_LinkAdaption_TCP    whether_start_dl_call=${False}
#    ...                                     log_name=tcp_ul_CA
#    ...                                     check_ul_pcell_tput_type=peak
#    ...                                     check_pcell_tput_type=no_data
#    ...                                     check_scell_tput_type=no_data
#    ...                                     min_UL_percent=0
#    ...                                     check_pcell_tput_type_after_la=no_data
#    ...                                     check_scell_tput_type_after_la=no_data
#
#5603039_TOL_case_33_RRM_SA_LinkAdaption_TCP_UL_100MhzCell
#    [Tags]    TA_NOT_NEEDED
#    [Setup]    TMO_Common_Case_Setup
#    Run Keyword If    '${ue_type}'!='huawei_sigspark'    Fail    msg=This case need to run on the spark enviorment.
#    ${delete_nrrel_param_list}    ${add_nrrel_param_list}   Get The Parameter List Of NRREL Config
#    Set Test Variable    ${DELETE_NRREL_PARAM_LIST}    ${delete_nrrel_param_list}
#    Set Test Variable    ${ADD_NRREL_PARAM_LIST}    ${add_nrrel_param_list}
#    Add Or Delete Scell Of All NR Cells    param_list=${DELETE_NRREL_PARAM_LIST}
#    TOL_case_RRM_SA_1UE_LinkAdaption_TCP    whether_start_dl_call=${False}
#    ...                                     whether_check_scell_addition=${False}
#    ...                                     log_name=tcp_ul_LA
#    ...                                     check_ul_pcell_tput_type=peak
#    ...                                     check_pcell_tput_type=no_data
#    ...                                     check_scell_tput_type=no_data
#    ...                                     min_UL_percent=0
#    ...                                     check_pcell_tput_type_after_la=no_data
#    ...                                     check_scell_tput_type_after_la=no_data
#    [Teardown]    Run Keywords    TMO_Common_Case_Teardown
#    ...                    AND    Add Or Delete Scell Of All NR Cells    param_list=${ADD_NRREL_PARAM_LIST}
#
#5603038_TOL_case_33_RRM_SA_LinkAdaption_TCP_DL_100MhzCell
#    [Tags]    TA_NOT_NEEDED
#    [Setup]    TMO_Common_Case_Setup
#    Run Keyword If    '${ue_type}'!='huawei_sigspark'    Fail    msg=This case need to run on the spark enviorment.
#    ${delete_nrrel_param_list}    ${add_nrrel_param_list}   Get The Parameter List Of NRREL Config
#    Set Test Variable    ${DELETE_NRREL_PARAM_LIST}    ${delete_nrrel_param_list}
#    Set Test Variable    ${ADD_NRREL_PARAM_LIST}    ${add_nrrel_param_list}
#    Add Or Delete Scell Of All NR Cells    param_list=${DELETE_NRREL_PARAM_LIST}
#    TOL_case_RRM_SA_1UE_LinkAdaption_TCP    whether_start_ul_call=${False}
#    ...                                     whether_check_scell_addition=${False}
#    ...                                     log_name=tcp_dl_LA
#    ...                                     check_ul_pcell_tput_type=no_data
#    ...                                     check_pcell_tput_type=not_peak
#    ...                                     check_scell_tput_type=no_data
#    ...                                     min_DL_percent=0
#    ...                                     check_ul_pcell_tput_type_after_la=no_data
#    ...                                     check_pcell_tput_type_after_la=not_peak
#    ...                                     check_scell_tput_type_after_la=no_data
#    [Teardown]    Run Keywords    TMO_Common_Case_Teardown
#    ...                    AND    Add Or Delete Scell Of All NR Cells    param_list=${ADD_NRREL_PARAM_LIST}
#
#5603041_TOL_case_42_RRM_L3_call_SA_40Mhz_TCP
#    [Tags]    TA_NOT_NEEDED
#    [Setup]    TMO_Common_Case_Setup
#    ${delete_nrrel_param_list}    ${add_nrrel_param_list}   Get The Parameter List Of NRREL Config
#    Set Test Variable    ${DELETE_NRREL_PARAM_LIST}    ${delete_nrrel_param_list}
#    Set Test Variable    ${ADD_NRREL_PARAM_LIST}    ${add_nrrel_param_list}
#    Add Or Delete Scell Of All NR Cells    param_list=${DELETE_NRREL_PARAM_LIST}
#    Procedures.Verify CA Basic L3 Call    ul_throughput=100M
#    ...                                   dl_throughput=800MKbits/sec
#    ...                                   protocol=tcp
#    ...                                   tput_collect_duration=180
#    ...                                   whether_need_ue_log=${False}
#    ...                                   whether_check_scell_addition=${False}
#    ...                                   ignore_time=15sec
#    ...                                   check_scell_tput_type=no_data
#    ...                                   dl_process_num=${5}
#    [Teardown]    Run Keywords    TMO_Common_Case_Teardown
#    ...                    AND    Add Or Delete Scell Of All NR Cells    param_list=${ADD_NRREL_PARAM_LIST}
#
#
#5603097_TOL_case_97_OAM_Site_Reset_downtime_KPI_1a
#    [Tags]    Release_branch_out
#    [Setup]    TMO_Common_Case_Setup_OAM
#    Case Status Init
#    Create Kpi Csv File
#    ${duration_time_list}    Create List
#    ${max}    Set Variable   ${930}
#    ${reset_time}    Set Variable   ${10}
#    FOR    ${i}    IN RANGE    ${reset_time}
#        Run Keyword And Ignore Error    Run    command=rm /tmp/btslog2/* -rf
#        Run Keyword And Ignore Error    Start To Collect Btslog    btslog_collector_name=btslog_${i+1}
#        ${res}    Run Keyword And Ignore Error    Loop For Site Reset Via WEBUI
#        ${reset_status}         Set Variable If    '${res[0]}'=='FAIL'      fail    ${res[1][0]}
#        ${duration_time_tmp}    Set Variable If    '${res[0]}'=='FAIL'      1800    ${res[1][1]}
#        Case Status Caluate    duration=${duration_time_tmp}    max=${max}
#        Run Keyword If   ${duration_time_tmp}<=${max}    Append To List    ${duration_time_list}    ${duration_time_tmp}
#        Log To Console     Case loop ${i+1} END
#        Append Case Result To File    index=${i+1}    target_value=${max}    result_value=${duration_time_tmp}
#        Run Keyword And Ignore Error    Stop Btslog Collection    btslog_collector_name=btslog_${i+1}
#        ${unexpect_alarm_should_not_exist}    Check Unexpect Alarm And Trunk Roll
#        Run Keyword If   ${unexpect_alarm_should_not_exist} and ${duration_time_tmp}>${max}
#        ...    Run Keyword And Ignore Error    Common_keywords.Collect Snapshot Log    timeout=${2400}
#        ...    ELSE    Sleep    2min
#    END
#    Case Status Finnal    duration_time_list=${duration_time_list}    target_value=${max}
#    [Teardown]    Run Keywords    Copy File And Verify Whether Exist    source_file_path=${case_result_save_path}
#    ...                    AND    Run Keyword And Ignore Error    TMO_Common_Case_Teardown
#
#5603098_TOL_case_98_OAM_RU_Reset_downtime_KPI_51a
#    [Tags]    Release_branch_out
#    [Setup]    TMO_Common_Case_Setup_OAM
#    ${duration_time_list}    Create List
#    ${max}    Set Variable   ${780}
#    ${reset_time}    Set Variable   ${4}
#    Case Status Init
#    Create Kpi Csv File
#    ${rmod_distname_list}    Get RMOD List For Special RU
#    FOR    ${rmod_distname}    IN    @{rmod_distname_list}
#        ${ru_index}    Set Variable   ${rmod_distname.split('-')[-1]}
#        Make RU Reset With Retry    ru_index=${ru_index}    reset_time=${reset_time}    max=${max}
#        ...    duration_time_list=${duration_time_list}    timeout=${2400}
#    END
#    Case Status Finnal    duration_time_list=${duration_time_list}    target_value=${max}
#    [Teardown]    Run Keywords    Copy File And Verify Whether Exist    source_file_path=${case_result_save_path}
#    ...                    AND    Run Keyword And Ignore Error    TMO_Common_Case_Teardown
#
#5603028_TOL_case_13_SiSO_AEHC_RF_module_power_off_on
#    [Tags]    TA_NOT_NEEDED
#    [Setup]    TMO_Common_Case_Setup    whether_get_ca_info=${False}    whether_set_pa_value=${False}
##    Add Or Delete Scell Of All NR Cells    param_list=${DELETE_NRREL_PARAM_LIST}
#    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
#    ${aehc_nr_cell_list_1}    Get Cell List For Special RU    cell_type=nr
#    @{aehc_nr_cell_list_2}    Create List     ${302}
#    ${aehc_nr_cell_list}    Set Variable If   '${tl_prefix}'=='T080'    ${aehc_nr_cell_list_2}    ${aehc_nr_cell_list_1}
#    ${aehc_lte_cell_list1}    Get Cell List For Special RU    cell_type=lte
#    @{aehc_lte_cell_list2}    Create List     ${132}    ${142}
#    ${aehc_lte_cell_list}     Set Variable If   '${tl_prefix}'=='T080'     ${aehc_lte_cell_list2}    ${aehc_lte_cell_list1}
#    ${aehc_lte_cell_list_length}     Get Length    ${aehc_lte_cell_list}
#    FOR    ${enb_index}    IN RANGE    ${enb_length}
#        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
#    END
#    Verify Non-CA Basic L3 Call One By One    cell_list=${aehc_nr_cell_list}    ue_type=${ue_type}    ue_index=${0}
#    Run Keyword If    '${aehc_lte_cell_list_length}'!='${0}'      Verify 4G Non-CA Basic L3 Call One By One
#    ...     cell_list=${aehc_lte_cell_list}    ue_type=${ue_type}    ue_index=${0}    enb_index=${0}    whether_do_barred_action=${True}
#    FOR    ${i}    IN RANGE    ${1}
#        Perform Special RU Power Action    action=power_off
#        Verify Specific RU Should Be Power Action    action=power_off
#        Sleep    10 sec
#        Perform Special RU Power Action    action=power_on
#        Verify Specific RU Should Be Power Action    action=power_on
#        Check TMO Gnb Ready And All Cell On Air
#        Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False}    Verify All Enbs Cell On Air
#        Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=GNB_OAM
#        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=@{GNB_ALLOWED_FAULT}
#        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${0}
#        Verify Non-CA Basic L3 Call One By One    cell_list=${aehc_nr_cell_list}    ue_type=${ue_type}    ue_index=${0}
#        Run Keyword If    '${aehc_lte_cell_list_length}'!='${0}'      Verify 4G Non-CA Basic L3 Call One By One
#        ...    cell_list=${aehc_lte_cell_list}   ue_type=${ue_type}   ue_index=${0}   enb_index=${0}   whether_do_barred_action=${True}
#        Sleep    30 sec
#    END
#    [Teardown]    Run Keywords    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${0}    ue_type=${ue_type}
#    ...    AND    Run Keyword And Ignore Error    Run Keyword If Test Failed    Common_keywords.Collect Snapshot Log    timeout=${2400}
#    ...    AND    Run Keyword And Ignore Error    Run Keyword If Test Failed    Common_keywords.Collect Enb Snapshot Log    timeout=${2400}
#
#5603019_TOL_22R1_SiSo_reset_GNB_Site
#    [Tags]    TA_NOT_NEEDED
#    [Setup]    TMO_Common_Case_Setup    whether_get_ca_info=${False}    whether_set_pa_value=${False}
##    Add Or Delete Scell Of All NR Cells    param_list=${DELETE_NRREL_PARAM_LIST}
#    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
#    ${nr_cell_list1}    Get Cell Index List    cell_type=nr
#    @{nr_cell_list2}    Create List     ${302}
#    ${nr_cell_list}    Set Variable If   '${tl_prefix}'=='T080'    ${nr_cell_list2}    ${nr_cell_list1}
#    ${tdd_lte_cell_list1}    Get Cell Index List    cell_type=lte    enb_index=${0}    technology=TDD
#    @{tdd_lte_cell_list2}    Create List     ${132}      ${142}
#    ${tdd_lte_cell_list}    Set Variable If   '${tl_prefix}'=='T080'    ${tdd_lte_cell_list2}    ${tdd_lte_cell_list1}
#    ${tdd_lte_cell_list_length}     Get Length    ${tdd_lte_cell_list}
#    ${fdd_lte_cell_list1}    Get Cell Index List    cell_type=lte    enb_index=${1}    technology=FDD
#    @{fdd_lte_cell_list2}    Create List     ${32}
#    ${fdd_lte_cell_list}    Set Variable If   '${tl_prefix}'=='T080'    ${fdd_lte_cell_list2}    ${fdd_lte_cell_list1}
#    ## Below line for run only fdd cell,if want to run all, you can delete it.
#    ${fdd_lte_cell_list}    Create List    ${fdd_lte_cell_list}[0]
#    FOR    ${enb_index}    IN RANGE    ${enb_length}
#        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
#    END
#    Verify Non-CA Basic L3 Call One By One    cell_list=${nr_cell_list}    ue_type=${ue_type}    ue_index=${0}    ue_mode=SA
#    Run Keyword If    '${tdd_lte_cell_list_length}'!='${0}'      Verify 4G Non-CA Basic L3 Call One By One
#    ...     cell_list=${tdd_lte_cell_list}   ue_type=${ue_type}    ue_index=${0}    enb_index=${0}    whether_do_barred_action=${True}
#    Verify 4G Non-CA Basic L3 Call One By One    cell_list=${fdd_lte_cell_list}    ue_type=${ue_type}    ue_index=${0}    enb_index=${1}
#    ...                                          whether_do_barred_action=${True}
#    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=GNB_OAM
#    coam.reset_site    wait_for_reconnection=${True}    timeout=600    connection=GNB_OAM
#    Sleep    60s
#    Check TMO Gnb Ready And All Cell On Air
#    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False}    Verify All Enbs Cell On Air
#    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=GNB_OAM
#    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=@{GNB_ALLOWED_FAULT}
#    FOR    ${enb_index}    IN RANGE    ${enb_length}
#        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
#    END
#    Verify Non-CA Basic L3 Call One By One    cell_list=${nr_cell_list}    ue_type=${ue_type}    ue_index=${0}    ue_mode=SA
#    Run Keyword If    '${tdd_lte_cell_list_length}'!='${0}'      Verify 4G Non-CA Basic L3 Call One By One
#    ...     cell_list=${tdd_lte_cell_list}   ue_type=${ue_type}    ue_index=${0}    enb_index=${0}    whether_do_barred_action=${True}
#    Verify 4G Non-CA Basic L3 Call One By One    cell_list=${fdd_lte_cell_list}    ue_type=${ue_type}    ue_index=${0}    enb_index=${1}
#    ...                                          whether_do_barred_action=${True}
#    [Teardown]    Run Keywords    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${0}    ue_type=${ue_type}
#    ...    AND    Run Keyword And Ignore Error    Run Keyword If Test Failed    Common_keywords.Collect Snapshot Log    timeout=${2400}
#    ...    AND    Run Keyword And Ignore Error    Run Keyword If Test Failed    Common_keywords.Collect Enb Snapshot Log    timeout=${2400}
#
#5603054_TOL_case_67_RRM_22R2_CB002640_1UE_FTTCA_SA
#    [Documentation]    TL813:UE0-SDX65, AHLOA0+AEHC0, 15M+100M+40M_cellID1_301_311
#    ...                replace by 5603108/5603109/5603110
#    [Tags]    TA_Done_Case_Delete
#    [Setup]    TMO_Common_Case_Setup    3CC_support=${True}    is_pdl_checking_needed=${False}
#    ...       ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
#    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#    Procedures.Verify CA Basic L3 Call    ul_throughput=250M
#    ...                                   dl_throughput=3500MKbits/sec
#    ...                                   ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
#    ...                                   enb_index=${fdd_enb_index}
#    [Teardown]    TMO_Common_Case_Teardown    3CC_support=${True}   ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
#
#
#5603053_TOL_case_66_RRM_22R1_CB006138_1UE_TFTCA_SA
#    [Documentation]    TL813:UE0-SDX65, AEHC0+AHLOA, 100M+15M+40M_cellID301_1_311
#    ...                replace by 5603108/5603109/5603110
#    [Tags]    TA_Done_Case_Delete
#    [Setup]    TMO_Common_Case_Setup    3CC_support=${True}   is_pdl_checking_needed=${False}
#    ...        ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
#    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#    Procedures.Verify CA Basic L3 Call    ul_throughput=200M
#    ...                                   dl_throughput=2200MKbits/sec
#    ...                                   ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
#    ...                                   enb_index=${fdd_enb_index}
#    [Teardown]    TMO_Common_Case_Teardown    3CC_support=${True}   ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
#
#5603084_TOL_case_84_Intra_frequency_ANR_trigger_HO
#    [Tags]    TA_NOT_START
#    [Setup]    TMO_Common_Case_Setup
##    Update DrxLongCycle Of All 5G Cell    drxLongCycle=640ms
#    Update values of some ANR parameters    pcell_index=${PCELL_INDEX}    ho_pcell_index=${HO_PCELL_INDEX}
#    ...    drxLongCycle_value=640ms    drxOnDurationTimer_value=20ms
#    Get NRREL Config For Intra Frequency    source_cell_idx=${PCELL_INDEX}    target_cell_idx=${HO_PCELL_INDEX}
#    ${attach_info}    Procedures.Verify CA Basic L3 Call    whether_start_dl_call=${False}
#    ...                                                     whether_start_ul_call=${False}
#    ...                                                     whether_check_tupt=${False}
#    ...                                                     whether_do_barred_action=${False}
#    ...                                                     whether_check_scell_addition=${False}
#    ${handover_wireshark}    Procedures.Verify CA Basic Handover Test    source_pa_value=50    target_pa_value=10
#    ...           whether_check_scell_addition=${False}
#    Message_Flow_Check.Intra Frequency Handover Process    source_ho_cpif_log_path=${handover_wireshark}
#    ...                                                    target_ho_cpif_log_path=${handover_wireshark}
#    ...                                                    addition_cpif_log_path=${attach_info['cpif_log_path']}
#    ...                                                    mode=SA
#    ...                                                    source_pci=${PCELL_MAPPING['physicalCellId']}
#    ...                                                    target_pci=${HO_PCELL_MAPPING['physicalCellId']}
#    ...                                                    whether_check_contain=${True}
#    Check CGI For ANR From Wireshark    log_path=${handover_wireshark}     drxLongCycle_value=640ms     drxOnDurationTimer_value=20ms
#    Wait Until Keyword Succeeds    2 min    5 sec    Check The Lcrid For Special NRREL    source_cell_idx=${PCELL_INDEX}
#    ...                                                                                   target_cell_idx=${HO_PCELL_INDEX}
#    [Teardown]    Run Keywords    Common_setup_and_teardown.Common Suite Setup    scf_name=${tl_prefix}_gNB_${stream_version}.xml
#    ...                                                                           is_commission=True
#    ...                    AND    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${0}    ue_type=${ue_type}
#
#5603032_TOL_case_21_SiSo_Cell_lock_and_unlock_from_TDDLTE
#    [Tags]    TA_NOT_NEEDED
#    [Setup]    TMO_Common_Case_Setup    3CC_support=${True}    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
#    FOR    ${i}    IN RANGE    ${1}
#        # Below for SDX65/SA-3CC-TTF
#        Procedures.Verify CA Basic L3 Call    ul_throughput=200M
#        ...                                   dl_throughput=3000MKbits/sec
#        ...                                   ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
#        ...                                   start_keep_on_duration=7200
#        # Below for samsung/SA-4G-Non-CA
#        # Comment: Need to add VOLTE call
#        ${ue_type1}    translate_power_ue_type_from_testline    ue_index=${1}
#        ${aehc_lte_cell_list}    Get Cell List For Special RU    cell_type=lte    whether_get_first_ru_only=${True}
##        Run Keyword If    '${ue_type1}'=='samsung'
##        ...          Change Network Mode For Samsung    ue_type=${ue_type1}    ue_index=${1}    netword_mode=4G
#        Verify 4G Non-CA Basic L3 Call    cell_index=${aehc_lte_cell_list}[0]
#        ...                               ue_type=${ue_type1}
#        ...                               ue_index=${1}
#        ...                               enb_index=${0}
#        ...                               tput_collect_duration=90
#        Do All TDD-LTE Cells Action
#        Verify All TDD-LTE Cells Should Be Locked
#        Wait Gnb Ready And Cell On Air    timeout=20 min
#        Wait until keyword succeeds    2 min    20 sec    Verify Gnb Type Cells Should Be Onair    cell_type=lte    cell_technology=FDD
#        Wait until keyword succeeds    2 min    20 sec    Verify Gnb Type Cells Should Be Onair    cell_type=wcdma
#        Wait until keyword succeeds    2 min    20 sec    Verify Gnb Type Cells Should Be Onair    cell_type=gsm
#        Run Keyword If    '${LTE_WHETHER_IN_GNB}'=='${False}'
#        ...    Wait Until Keyword Succeeds    3 min    20 sec    Verify Enb All Cell On Air    enb_index=${1}
#        Procedures.Check TMO Throughput    ue_index=${0}
#        ...                                addition_scell_index_list=${SCELL_INDEX_LIST}
#        ...                                tput_collect_duration=120
#        ...                                ignore_time=5sec
#        Run Keyword If    ${LTE_WHETHER_IN_GNB}    Wait For Expect Fault Present   faultId=${49}   timeout=600
#        Do All TDD-LTE Cells Action    cell_action=unlocked
#        sleep   30s
#        Verify All TDD-LTE Cells Should Be Unlocked
#        Check TMO Gnb Ready And All Cell On Air
#        Verify All Enbs Cell On Air
#        Procedures.Check TMO Throughput    ue_index=${0}
#        ...                                addition_scell_index_list=${SCELL_INDEX_LIST}
#        ...                                tput_collect_duration=120
#        ...                                ignore_time=5sec
#        Verify 4G Non-CA Basic L3 Call    cell_index=${aehc_lte_cell_list}[0]
#        ...                               ue_type=${ue_type1}
#        ...                               ue_index=${1}
#        ...                               enb_index=${0}
#        ...                               tput_collect_duration=90
#        Sleep    30 sec
#    END
#    [Teardown]    Run Keywords    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    3CC_support=${True}
#    ...                                               ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}    ue_type=${ue_type}
#    ...    AND    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${1}    ue_type=${ue_type1}
#
#5603099_TOL_case_99_KPI_comparison_FDDCELL_4GCall_VoLTE_at_far_condition
#    [Tags]    TA_NOT_START
#    [Setup]    TMO_Common_Case_Setup
#    Run Keyword If    '${tl_prefix}'=='T284'    Modify PA Value Setting For Required RU    ue_index=${0}
#    ...                                                                                    pa_off_value=10
#    ${AHFIB_lte_cell_list}    Get Cell List For Special RU    cell_type=lte    ru_type=AHFIB    enb_index=${1}
#    Verify 4G Non-CA Basic L3 Call One By One    cell_list=${AHFIB_lte_cell_list}    ue_type=${ue_type}    ue_index=${0}    enb_index=${1}
#    ...                                          whether_do_ue_prepare=${True}
#    Sleep    20min
#    Run Keyword If    '${tl_prefix}'=='T284'    Modify PA Value Setting For Required RU    ue_index=${0}
#    ...                                                                                    pa_off_value=33
#    Sleep    20min
#    Run Keyword If    '${tl_prefix}'=='T284'    Modify PA Value Setting For Required RU    ue_index=${0}
#    ...                                                                                    pa_off_value=53
#    Sleep    20min
#     Run Keyword If    '${tl_prefix}'=='T284'    Modify PA Value Setting For Required RU    ue_index=${0}
#    ...                                                                                    pa_off_value=33
#    Sleep    20min
#    Run Keyword If    '${tl_prefix}'=='T284'    Modify PA Value Setting For Required RU    modify_ru_id=2
#    ...                                                                                    ue_index=${0}
#    ...                                                                                    pa_off_value=10
#    Sleep    20min
#    Run Keyword And Continue On Failure    Get KPI Report from gnb and enb    connection=ENB    folder_index=2
#    Common_keywords.Collect Snapshot Log
#    [Teardown]     TMO_Common_Case_Teardown    ue_index=${0}    ue_type=${ue_type}
#
#
#5603105_TOL_case_105_23R1_SA_UE_CHBW_modification
#    [Documentation]    siso cases
#    [Tags]    TA_NOT_NEEDED
#    [Setup]    TMO_Common_Case_Setup     is_commission=True    scf_name=${tl_prefix}_5603105.xml
#    ...                                  whether_get_ca_info=${True}    whether_set_pa_value=${True}
#    @{cell_list}    Create List     ${401}    ${402}   ${403}
#    Modify chBW And Related Parameters     cell_list=${cell_list}     configuration_type=80MHz
#    sleep     1min
#    Check GNB On Air And Unexpect Alarm Should Not Exist
#    FOR    ${enb_index}    IN RANGE    ${enb_length}
#        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
#    END
#    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#    Verify Non-CA Basic L3 Call One By One    cell_list=${cell_list}    ue_type=${ue_type}    ue_index=${0}
#    ...                                   enb_index=${fdd_enb_index}
#    Modify chBW And Related Parameters     cell_list=${cell_list}     configuration_type=40MHz
#    ...                                    bwpdn0_profile=184
#    ...                                    bwpdn1_profile=203
#    ...                                    cellchBW_value=40MHz
#    ...                                    nrarfcn_value=514056
#    ...                                    csirsPower_value=18
#    ...                                    maxCsirsNumber_value=4
#    ...                                    actMultipleDedicatedBWPs_value=false
#    ...                                    actEnhMultipleDedicatedBWPs_value=false
#    ...                                    actPowerSavingBWP_value=false
#    ...                                    actDynPdcchTd_value=true
#    ...                                    gscnOrSsPbchArfcn_value=6402
#    ...                                    msg1FrequencyStart_value=9
#    ...                                    reqMinNumPuschPrb_value=88
#    ...                                    ssPbchBlockPower_value=12
#    ...                                    pMax_value=280
#    sleep     1min
#    Check GNB On Air And Unexpect Alarm Should Not Exist
#    Verify Non-CA Basic L3 Call One By One    cell_list=${cell_list}    ue_type=${ue_type}    ue_index=${0}
#    ...                                   enb_index=${fdd_enb_index}
#    [Teardown]    Run Keywords    Common_setup_and_teardown.Common Suite Setup    scf_name=${tl_prefix}_gNB_${stream_version}.xml
#    ...                                                                           is_commission=True
#    ...                    AND    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${0}    ue_type=${ue_type}
