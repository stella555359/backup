#*** Settings ***
#Documentation    TMO Automation for NSA RRM cases
#...              Author: jun.8.chen@nokia-sbell.com
#Suite Setup    TMO_Common_Suite_Setup    is_commission=${False}    prefer_5g_nr_mode=NSA
#Test Teardown    TMO_Common_Case_Teardown
#Suite Teardown    TMO_Suite_Teardown
#Force Tags    5G_TOL    SG_06
#...    PY36
#
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_common_keywords.robot
#
#
#*** Test Cases ***
#5603033_TOL_case_28_RRM_L3Call_1UE_TT_CA_PRACH_format_switchover_bewteen_B4_C2_PreambleFormat0_1UE_TT_CA
#    [Tags]    TA_NOT_NEEDED
#    [Setup]    TMO_Common_Case_Setup
#    Update The Prach Index    cell_index=${PCELL_INDEX}    prach_index=206
#    FOR    ${enb_index}    IN RANGE    ${enb_length}
#        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
#    END
#    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#    Procedures.Verify CA Basic L3 Call    ue_mode=NSA
#    ...                                   ul_throughput=150M
#    ...                                   dl_throughput=2500MKbits/sec
#    ...                                   notbarred_cell_index=all
#    ...                                   b1_select_cell_index=${PCELL_INDEX}
#    ...                                   exp_status=barred
#    ...                                   whether_do_lte_barred_action=${True}
#    ...                                   whether_check_scell_addition=${False}
#    ...                                   tput_collect_duration=120
#    ...                                   ignore_time=15sec
#    ...                                   enb_index=${fdd_enb_index}
#    Procedures.Stop TMO L3 Call And Detach
#    ${prach_index_list}    Create List    9    198    14    158
#    FOR    ${prach_index}    IN    @{prach_index_list}
#        Update The Prach Index    cell_index=${PCELL_INDEX}    prach_index=${prach_index}
#        Procedures.Verify CA Basic L3 Call    whether_check_scell_addition=${False}
#        ...                                   whether_do_barred_action=${False}
#        ...                                   whether_check_on_air=${False}
#        ...                                   whether_do_ue_prepare=${False}
#        ...                                   whether_need_ue_log=${False}
#        ...                                   b1_select_cell_index=${PCELL_INDEX}
#        ...                                   ue_mode=NSA
#        ...                                   ul_throughput=150M
#        ...                                   dl_throughput=2200MKbits/sec
#        ...                                   start_keep_on_duration=600
#        ...                                   tput_collect_duration=120
#        ...                                   ignore_time=15sec
#        ...                                   enb_index=${fdd_enb_index}
#        Procedures.Stop TMO L3 Call And Detach
#    END
#
#5603010_TOL_21B_CB7873_RRM01_1UE_CA_FT_call_NSA_VoLTE_call_AdditionA1Based_N41_N71
#    [Tags]    TL80_RRM
#    [Setup]    TMO_Common_Case_Setup     ue_index=${CASE_FOR_VoLTE_CHOOSED_UE['${tl_prefix}']}
#    FOR    ${enb_index}    IN RANGE    ${enb_length}
#        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
#    END
#    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#    Run Keyword And Continue On Failure    Procedures.Verify CA Basic L3 Call    ue_index=${CASE_FOR_VoLTE_CHOOSED_UE['${tl_prefix}']}
#    ...                                                                          ue_mode=NSA
#    ...                                                                          ul_throughput=100M
#    ...                                                                          dl_throughput=2000MKbits/sec
#    ...                                                                          notbarred_cell_index=all
#    ...                                                                          b1_select_cell_index=${PCELL_INDEX}
#    ...                                                                          exp_status=barred
#    ...                                                                          whether_do_lte_barred_action=${True}
#    ...                                                                          whether_check_scell_addition=${False}
#    ...                                                                          start_keep_on_duration=4200
#    ...                                                                          tput_collect_duration=120
#    ...                                                                          ignore_time=15sec
#    ...                                                                          whether_do_lte_cell_locked=${True}
#    ...                                                                          target_DL_avg_percent=0.2
#    ...                                                                          target_UL_avg_percent=0.2
#    ...                                                                          min_DL_percent=0.2
#    ...                                                                          min_UL_percent=0.2
#    ...                                                                          whether_do_ue_prepare=${True}
#    ...                                                                          enb_index=${fdd_enb_index}
#    Run Keyword And Continue On Failure    Start CP-IF Log Collection
#    ...    tcpdump_collector_name=volte_call
#    ...    asik_connection_alias=ASIK Master
#    ...    gnb_index=${0}
#    ...    options=-i any '((sctp) and ((port 38472) or (port 38412) or (port 38462) or (port 36422) or (port 38422)))' -s 0
#    Make Vonr Call    ue_index=${CASE_FOR_VoLTE_CHOOSED_UE['${tl_prefix}']}
#    Sleep    30 sec
#    ${host}   Start To Capture Aasyslog    gnb_index=${0}    du_index=${0}    timeout=30s
#    Sleep    15 sec
#    ${tupt_file_path}    Stop To Capture And Download Aasyslog    host=${host}
#    Hang Up Vonr Call    ue_index=${CASE_FOR_VoLTE_CHOOSED_UE['${tl_prefix}']}
#    Sleep    20 sec
#    ${volte_wireshark}    Run Keyword And Continue On Failure    Stop tcpdump log collection    tcpdump_collector_name=volte_call
#    Procedures.Check TMO Throughput    ue_index=${CASE_FOR_VoLTE_CHOOSED_UE['${tl_prefix}']}
#    ...                                addition_scell_index_list=${SCELL_INDEX_LIST}
#    ...                                ignore_time=15sec
#    ...                                tput_collect_duration=120
#    ...                                check_ul_pcell_tput_type=layer1
#    ...                                target_DL_avg_percent=0.2
#    ...                                target_UL_avg_percent=0.2
#    ...                                min_DL_percent=0.2
#    ...                                min_UL_percent=0.2
#    Procedures.Check TMO Throughput    ue_index=${CASE_FOR_VoLTE_CHOOSED_UE['${tl_prefix}']}
#    ...                                addition_scell_index_list=${SCELL_INDEX_LIST}
#    ...                                whether_collect_tput=${False}
#    ...                                tput_file_use_collected=${tupt_file_path}
#    ...                                check_pcell_tput_type=no_data
#    ...                                check_scell_tput_type=no_data
#    ...                                check_ul_pcell_tput_type=no_data
#    Check VoLTE Call Success    log_path=${volte_wireshark}
#    [Teardown]    TMO_Common_Case_Teardown       ue_index=${CASE_FOR_VoLTE_CHOOSED_UE['${tl_prefix}']}
#
#5603022_TOL_case_03_RRM_L3_call_NSA_40Mhz_UDP
#    [Tags]    TA_NOT_NEEDED
#    [Setup]    TMO_Common_Case_Setup
##    Add Or Delete Scell Of All NR Cells    param_list=${DELETE_NRREL_PARAM_LIST}
#    FOR    ${enb_index}    IN RANGE    ${enb_length}
#        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
#    END
#    ${enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#    Procedures.Verify CA Basic L3 Call    ue_mode=NSA
#    ...                                   ul_throughput=100M
#    ...                                   dl_throughput=800MKbits/sec
#    ...                                   notbarred_cell_index=all
#    ...                                   b1_select_cell_index=${PCELL_INDEX}
#    ...                                   exp_status=barred
#    ...                                   whether_do_lte_barred_action=${True}
#    ...                                   whether_check_scell_addition=${False}
#    ...                                   check_scell_tput_type=no_data
#    ...                                   tput_collect_duration=180
#    ...                                   ignore_time=15sec
#    ...                                   enb_index=${fdd_enb_index}
#    [Teardown]    Run Keyword And Ignore Error    TMO_Common_Case_Teardown
#
#5603080_TOL_22R1_15_SiSO_Block_unBlock_from_gNB
#    [Tags]    TA_NOT_NEEDED
#    [Setup]    TMO_Common_Case_Setup    whether_get_ca_info=${False}    whether_set_pa_value=${False}
#    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
#    ${ue_type1}    translate_power_ue_type_from_testline    ue_index=${1}
#    ${nr_cell_list}    Get Cell Index List    cell_type=nr
#    ${tdd_lte_cell_list}    Get Cell Index List    cell_type=lte    enb_index=${0}    technology=TDD
#    ${fdd_lte_cell_list}    Get Cell Index List    cell_type=lte    enb_index=${1}    technology=FDD
#    ${tdd_lte_cell_list_length}     Get Length    ${tdd_lte_cell_list}
#    ${fdd_lte_cell_list_length}     Get Length    ${fdd_lte_cell_list}
#    FOR    ${enb_index}    IN RANGE    ${enb_length}
#        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
#    END
#    Verify Non-CA Basic L3 Call One By One    cell_list=${nr_cell_list}
#    ...                                       ue_type=${ue_type}
#    ...                                       ue_index=${0}
#    ...                                       ue_mode=NSA
#    ...                                       whether_do_lte_barred_action=${True}
#    Run Keyword If    '${tdd_lte_cell_list_length}'!='${0}'      Verify 4G Non-CA Basic L3 Call One By One
#    ...     cell_list=${tdd_lte_cell_list}    ue_type=${ue_type}    ue_index=${0}    whether_do_barred_action=${True}
#    Run Keyword If    '${fdd_lte_cell_list_length}'!='${0}'      Verify 4G Non-CA Basic L3 Call One By One
#    ...     cell_list=${fdd_lte_cell_list}    ue_type=${ue_type}    ue_index=${0}    whether_do_barred_action=${True}
#    ...     enb_index=${1}
#    Block RAT
#    Wait Until Keyword Succeeds    2 min    5 sec    Verify RAT Should Be Blocked
#    Sleep    30 sec
#    Unblock RAT
#    Check GNB On Air And Unexpect Alarm Should Not Exist
#    Check ENB On Air And Unexpect Alarm Should Not Exist
#    Verify Non-CA Basic L3 Call One By One    cell_list=${nr_cell_list}
#    ...                                       ue_type=${ue_type}
#    ...                                       ue_index=${0}
#    ...                                       ue_mode=NSA
#    ...                                       whether_do_lte_barred_action=${True}
#    Run Keyword If    '${tdd_lte_cell_list_length}'!='${0}'      Verify 4G Non-CA Basic L3 Call One By One
#    ...     cell_list=${tdd_lte_cell_list}    ue_type=${ue_type}    ue_index=${0}    whether_do_barred_action=${True}
#    Run Keyword If    '${fdd_lte_cell_list_length}'!='${0}'      Verify 4G Non-CA Basic L3 Call One By One
#    ...     cell_list=${fdd_lte_cell_list}    ue_type=${ue_type}    ue_index=${0}    whether_do_barred_action=${True}
#    ...     enb_index=${1}
#    [Teardown]    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${0}    ue_type=${ue_type}
#
#5603083_TOL_case_83_3UEsCall_on_oneCELL
#    [Tags]    TA_NOT_NEEDED
#    [Setup]    TMO_Common_Case_Setup
#    # Below for SDX65/NSA-CA
#    Procedures.Verify CA Basic L3 Call    ue_mode=NSA
#    ...                                   ul_throughput=100M
#    ...                                   dl_throughput=2000MKbits/sec
#    ...                                   protocol=tcp
#    ...                                   notbarred_cell_index=all
#    ...                                   exp_status=barred
#    ...                                   whether_do_lte_barred_action=${True}
#    ...                                   whether_check_scell_addition=${False}
#    ...                                   start_keep_on_duration=4200
#    ...                                   tput_collect_duration=90
#    ...                                   ignore_time=15sec
#    ...                                   dl_process_num=${5}
#    # Below for MTK70/SA-CA
#    Multi-UE_Case_Setup    ue_index=${2}
#    ${ue_type2}    translate_power_ue_type_from_testline    ue_index=${2}
#    Procedures.Verify CA Basic L3 Call    ue_index=${2}
#    ...                                   ue_type=${ue_type2}
#    ...                                   ul_throughput=150M
#    ...                                   dl_throughput=1800MKbits/sec
#    ...                                   protocol=tcp
#    ...                                   whether_need_ue_log=${False}
#    ...                                   notbarred_cell_index=${PCELL_INDEX_2}
#    ...                                   b1_select_cell_index=${PCELL_INDEX_2}
#    ...                                   expect_addition_scell_indexs=${SCELL_INDEX_LIST_2}
#    ...                                   start_keep_on_duration=4200
#    ...                                   whether_do_ue_prepare=${True}
#    ...                                   ignore_time=15sec
#    ...                                   tput_collect_duration=90
#    ...                                   pcell_mapping=${PCELL_MAPPING_2}
#    ...                                   scell_mapping=${SCELL_MAPPING_2}
#    ...                                   dl_process_num=${5}
#    # Below for SDX55/SA_Non-CA
#    Multi-UE_Case_Setup    ue_index=${3}
#    ${ue_type3}    translate_power_ue_type_from_testline    ue_index=${3}
#    Run Keyword If    '${ue_type3}'=='qct_dx50'    Change Network Mode Between SA And NSA    ue_type=${ue_type3}
#    ...                                                                                      ue_index=${3}
#    ...                                                                                      is_prepare_ue_needed=${True}
#    ...                                                                                      prefer_5g_nr_mode=SA
#    Procedures.Verify CA Basic L3 Call    ue_index=${3}
#    ...                                   ue_type=${ue_type3}
#    ...                                   ul_throughput=150M
#    ...                                   dl_throughput=1500MKbits/sec
#    ...                                   protocol=tcp
#    ...                                   whether_need_ue_log=${False}
#    ...                                   whether_check_scell_addition=${False}
#    ...                                   check_scell_tput=${False}
#    ...                                   notbarred_cell_index=${PCELL_INDEX_3}
#    ...                                   b1_select_cell_index=${PCELL_INDEX_3}
#    ...                                   expect_addition_scell_indexs=${SCELL_INDEX_LIST_3}
#    ...                                   start_keep_on_duration=4200
#    ...                                   whether_do_ue_prepare=${True}
#    ...                                   ignore_time=15sec
#    ...                                   tput_collect_duration=90
#    ...                                   pcell_mapping=${PCELL_MAPPING_3}
#    ...                                   scell_mapping=${SCELL_MAPPING_3}
#    ...                                   dl_process_num=${5}
#    # Comment: Need to check check tupt via TTI
#
#
#    [Teardown]    Run Keywords    Run Keyword And Ignore Error    TMO_Common_Case_Teardown
#    ...                    AND    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${2}    ue_type=${ue_type2}
#    ...                    AND    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${3}    ue_type=${ue_type3}
#
#5603085_TOL_case_85_Intra_frequency_ANR_trigger_HO_NSA
#    [Tags]    TA_NOT_START
#    [Setup]    TMO_Common_Case_Setup
##    Update DrxLongCycle Of All 5G Cell    drxLongCycle=320ms
#    @{cell_list}    Create List     ${PCELL_INDEX}     ${HO_PCELL_INDEX}
#    FOR   ${cell}   IN   @{cell_list}
#           Update Target Param b1ThresholdNrRsrp Value In ENDCDMEASCONF     cell_index=${cell}
#    END
#    Update values of some ANR parameters    pcell_index=${PCELL_INDEX}    ho_pcell_index=${HO_PCELL_INDEX}
#    ...                                     drxLongCycle_value=640ms     drxOnDurationTimer_value=20ms
#    ...                                     ue_mode=NSA     a2ThresholdhoSsbRsrp_value=54
#    Get NRREL Config For Intra Frequency    source_cell_idx=${PCELL_INDEX}    target_cell_idx=${HO_PCELL_INDEX}
#    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#    ${attach_info}    Procedures.Verify CA Basic L3 Call    whether_start_dl_call=${False}
#    ...                                                     whether_start_ul_call=${False}
#    ...                                                     whether_check_tupt=${False}
#    ...                                                     ue_mode=NSA
#    ...                                                     whether_check_scell_addition=${False}
#    ...                                                     whether_change_fren=${False}
#    ...                                                     notbarred_cell_index=all
#    ...                                                     exp_status=barred
#    ...                                                     enb_index=${fdd_enb_index}
#    ${handover_wireshark}    Procedures.Verify CA Basic Handover Test    ue_mode=NSA    source_pa_value=50    target_pa_value=10
#    ...           whether_check_scell_addition=${False}
#    Message_Flow_Check.Intra Frequency Handover Process    source_ho_cpif_log_path=${handover_wireshark}
#    ...                                                    target_ho_cpif_log_path=${handover_wireshark}
#    ...                                                    addition_cpif_log_path=${attach_info['cpif_log_path']}
#    ...                                                    mode=NSA
#    ...                                                    source_pci=${PCELL_MAPPING['physicalCellId']}
#    ...                                                    target_pci=${HO_PCELL_MAPPING['physicalCellId']}
#    ...                                                    whether_check_contain=${True}
#    Check CGI For ANR From Wireshark    log_path=${handover_wireshark}     drxLongCycle_value=640ms     drxOnDurationTimer_value=20ms
#    ...                                 ue_mode=NSA
#    Wait Until Keyword Succeeds    2 min    5 sec    Check The Lcrid For Special NRREL    source_cell_idx=${PCELL_INDEX}
#    ...                                                                                   target_cell_idx=${HO_PCELL_INDEX}
#    [Teardown]    Run Keywords    Common_setup_and_teardown.Common Suite Setup    scf_name=${tl_prefix}_gNB_${stream_version}.xml
#    ...       is_commission=True      is_fdd_enb_commission=True      fdd_enb_scf_name=${tl_prefix}_FDDeNB_${stream_version}.xml
#    ...       AND    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${0}    ue_type=${ue_type}
#
#5603088_TOL_case_88_22R4_CB008239_Inter-RAT_NR-LTE_ANR_trigger_HO
#    [Documentation]    TL813:UE0-SDX65, handover from 5gcell_301 to ltecell_11 .
#    [Tags]    TA_ongoing
#    [Setup]    TMO_Common_Case_Setup
#    Update values of some ANR parameters    pcell_index=${PCELL_INDEX}    ho_pcell_index=${LTE_CELL_INDEX}
#    ...    drxLongCycle_value=640ms     drxOnDurationTimer_value=10ms
#    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#    ${eutranCellId}    ${physicalCellId}    ${earfcnDL}    Get Some Related Parameters Of LTE Cell    cell_index=${LTE_CELL_INDEX}
#    ...                                   enb_index=${fdd_enb_index}
#    Get NRRELE And NRADJECELL Config For Inter-RAT_NR-LTE_ANR HO    source_cell_idx=${PCELL_INDEX}
#    ...                                                             target_cell_idx=${LTE_CELL_INDEX}
#    ...                                                             target_cell_pci=${physicalCellId}
#    Update Values Of Some Parameters    cell_index=${PCELL_INDEX}    lte_cell_earfcnDL=${earfcnDL}
#    ...                                 a2ThresholdhoSsbRsrpSA_value=76     b2Threshold2hoRsrp_value=50
#    Change cellBarred Parameter Value Of Lte Cells    exp_status=barred    list_cell_ids=all    enb_index=${fdd_enb_index}
#    ${attach_info}    Procedures.Verify CA Basic L3 Call    whether_start_dl_call=${False}
#    ...                                                     whether_start_ul_call=${False}
#    ...                                                     whether_check_tupt=${False}
#    ...                                                     whether_need_ue_log=${False}
#    ...                                                     whether_check_scell_addition=${False}
#    ...                                                     enb_index=${fdd_enb_index}
#    Run Keyword And Continue On Failure    Start CP-IF Log Collection
#    ...    tcpdump_collector_name=sa_ho_lte
#    ...    asik_connection_alias=ASIK Master
#    ...    gnb_index=${0}
#    ...    options=-i any '((sctp) and ((port 38472) or (port 38412) or (port 38462) or (port 36422) or (port 38422)))' -s 0
#    FOR    ${attenuator}    IN    @{attenuator_list}
#        Run Keyword If    '${attenuator}'=='pa'    Modify PA Value Setting For Required RU    modify_ru_id=${PCELL_MAPPING['ru_index_mapping']}
#        ...                                                                                   ue_index=${0}
#        ...                                                                                   pa_off_value=50
#        ...    ELSE IF    '${attenuator}'=='mcs'
#        ...                                        Set Case Related MCS Port Value    att_value=30
#        ...                                                                           ue_index=${0}
#        ...                                                                           whether_do_Angles=${False}
#        ...                                                                           whether_do_mcs_setup=${False}
#        ...    ELSE    Log To Console     ${\n}INFO: --Use the wrong attenuator type(${attenuator}), need to check TMO_Data.py--
#    END
#    Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=${LTE_CELL_INDEX}    enb_index=${fdd_enb_index}
#    Get RU Index Of LTE Cell    cell_index=${LTE_CELL_INDEX}    enb_index=${fdd_enb_index}
#    Modify PA Value Setting For Required RU    modify_ru_id=${NSA_PA_RU_INDEX}    ue_index=${0}      pa_off_value=0
#    Sleep     45sec
#    ${sa_ho_lte_wireshark}    Run Keyword And Continue On Failure    Stop tcpdump log collection    tcpdump_collector_name=sa_ho_lte
#    Check InterRAT HO To LTE Success    log_path=${sa_ho_lte_wireshark}    eutranCellId=${eutranCellId}    physicalCellId=${physicalCellId}
#    Check CGI For ANR From Wireshark    log_path=${sa_ho_lte_wireshark}    drxLongCycle_value=640ms    ue_mode=SA
#    ...                                 whether_nr_to_lte=${True}
#    Wait Until Keyword Succeeds    2 min    5 sec    Check The Lcrid For Special NRRELE And NRADJECELL    source_cell_idx=${PCELL_INDEX}
#    ...                                                                                                   target_cell_idx=${LTE_CELL_INDEX}
#    ...                                                                                                   target_cell_pci=${physicalCellId}
#    [Teardown]    Run Keywords    Common_setup_and_teardown.Common Suite Setup    scf_name=${tl_prefix}_gNB_${stream_version}.xml
#    ...       is_commission=True      is_fdd_enb_commission=True      fdd_enb_scf_name=${tl_prefix}_FDDeNB_${stream_version}.xml
#    ...       AND    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${0}    ue_type=${ue_type}
#
#5603082_TOL_case_82_Inter_frequency_ANR_trigger_HO_NSA
#    [Tags]    TA_NOT_START
#    [Setup]    TMO_Common_Case_Setup
#    @{cell_list}    Create List     ${PCELL_INDEX}     ${HO_PCELL_INDEX}
#    FOR   ${cell}   IN   @{cell_list}
#           Update Target Param b1ThresholdNrRsrp Value In ENDCDMEASCONF     cell_index=${cell}
#    END
##    Update DrxLongCycle Of All 5G Cell    drxLongCycle=160ms
#    Update values of some ANR parameters    pcell_index=${PCELL_INDEX}    ho_pcell_index=${HO_PCELL_INDEX}
#    ...                                     drxLongCycle_value=320ms     drxOnDurationTimer_value=10ms
#    ...                                     ue_mode=NSA
#    Get NRREL Config For Intra Frequency    source_cell_idx=${PCELL_INDEX}    target_cell_idx=${HO_PCELL_INDEX}
#    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#    ${attach_info}    Procedures.Verify CA Basic L3 Call    whether_start_dl_call=${False}
#    ...                                                     whether_start_ul_call=${False}
#    ...                                                     whether_check_tupt=${False}
#    ...                                                     ue_mode=NSA
#    ...                                                     whether_check_scell_addition=${False}
#    ...                                                     whether_change_fren=${False}
#    ...                                                     notbarred_cell_index=all
#    ...                                                     exp_status=barred
#    ...                                                     enb_index=${fdd_enb_index}
#    ${handover_wireshark}    Procedures.Verify CA Basic Handover Test    ue_mode=NSA    source_pa_value=50    target_pa_value=10
#    ...           whether_check_scell_addition=${False}
#    Message_Flow_Check.Inter Frequency Handover Process    source_ho_cpif_log_path=${handover_wireshark}
#    ...                                                    target_ho_cpif_log_path=${handover_wireshark}
#    ...                                                    addition_cpif_log_path=${attach_info['cpif_log_path']}
#    ...                                                    mode=NSA
#    ...                                                    A2_rrc_message_filter=${NSA_RRC_RECONFIGURE_FILTER_ATTACH}
##    ...                                                    A1_Addition_MR_triggered=${False}
#    Check CGI For ANR From Wireshark    log_path=${handover_wireshark}     ue_mode=NSA
#    Wait Until Keyword Succeeds    2 min    5 sec    Check The Lcrid For Special NRREL    source_cell_idx=${PCELL_INDEX}
#    ...                                                                                   target_cell_idx=${HO_PCELL_INDEX}
#    [Teardown]    Run Keywords    Common_setup_and_teardown.Common Suite Setup    scf_name=${tl_prefix}_gNB_${stream_version}.xml
#    ...       is_commission=True      is_fdd_enb_commission=True      fdd_enb_scf_name=${tl_prefix}_FDDeNB_${stream_version}.xml
#    ...       AND    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${0}    ue_type=${ue_type}
#
#5603027_TOL_case_12_SiSo_reset_GNBRAT
#    [Tags]    TA_NOT_NEEDED
#    [Setup]    TMO_Common_Case_Setup
#    ${aehc_nr_cell_list}    Get Cell List For Special RU    cell_type=nr    whether_get_first_ru_only=${True}
#    ${aehc_lte_cell_list}    Get Cell List For Special RU    cell_type=lte    whether_get_first_ru_only=${True}
#    ${aehc_lte_cell_list_length}     Get Length    ${aehc_lte_cell_list}
#    FOR    ${enb_index}    IN RANGE    ${enb_length}
#        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
#    END
#    # Below for verify L3 call (NSA,loop for SA,loop for 4G)
#    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#    Procedures.Verify CA Basic L3 Call    ue_mode=NSA
#    ...                                   ul_throughput=150M
#    ...                                   dl_throughput=2500MKbits/sec
#    ...                                   notbarred_cell_index=all
#    ...                                   b1_select_cell_index=${PCELL_INDEX}
#    ...                                   exp_status=barred
#    ...                                   whether_do_lte_barred_action=${True}
#    ...                                   whether_check_scell_addition=${False}
#    ...                                   tput_collect_duration=60
#    ...                                   ignore_time=15sec
#    ...                                   target_DL_avg_percent=0.1
#    ...                                   target_UL_avg_percent=0.1
#    ...                                   min_DL_percent=0.05
#    ...                                   min_UL_percent=0.05
#    ...                                   enb_index=${fdd_enb_index}
#    Verify Non-CA Basic L3 Call One By One    cell_list=${aehc_nr_cell_list}    ue_type=${ue_type}    ue_index=${0}
#    Run Keyword If    '${aehc_lte_cell_list_length}'!='${0}'      Verify 4G Non-CA Basic L3 Call One By One
#    ...     cell_list=${aehc_lte_cell_list}    ue_type=${ue_type}    ue_index=${0}    whether_do_barred_action=${True}
#    ## Below for operation
#    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl
#    coam.reset_rat     rat_type=NR    timeout=600    connection=GNB_OAM
#    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False}    Verify All Enbs Cell On Air
#    Sleep    60s
#    Check GNB On Air And Unexpect Alarm Should Not Exist
#    Check ENB On Air And Unexpect Alarm Should Not Exist
#    # Below for verify L3 call (NSA,loop for SA,loop for 4G)
#    Procedures.Verify CA Basic L3 Call    ue_mode=NSA
#    ...                                   ul_throughput=150M
#    ...                                   dl_throughput=2500MKbits/sec
#    ...                                   notbarred_cell_index=all
#    ...                                   b1_select_cell_index=${PCELL_INDEX}
#    ...                                   exp_status=barred
#    ...                                   whether_do_lte_barred_action=${True}
#    ...                                   whether_check_scell_addition=${False}
#    ...                                   tput_collect_duration=60
#    ...                                   ignore_time=15sec
#    ...                                   target_DL_avg_percent=0.1
#    ...                                   target_UL_avg_percent=0.1
#    ...                                   min_DL_percent=0.05
#    ...                                   min_UL_percent=0.05
#    ...                                   enb_index=${fdd_enb_index}
#    Verify Non-CA Basic L3 Call One By One    cell_list=${aehc_nr_cell_list}    ue_type=${ue_type}    ue_index=${0}
#    Run Keyword If    '${aehc_lte_cell_list_length}'!='${0}'      Verify 4G Non-CA Basic L3 Call One By One
#    ...     cell_list=${aehc_lte_cell_list}    ue_type=${ue_type}    ue_index=${0}    whether_do_barred_action=${True}
#    [Teardown]    Run Keyword And Ignore Error    TMO_Common_Case_Teardown
#
#5603076_TOL_case_76_SISO_lock_unlock_BBMOD
#    [Tags]    TA_NOT_NEEDED
#    [Setup]    TMO_Common_Case_Setup
#    ${aehc_nr_cell_list}    Get Cell List For Special RU    cell_type=nr    whether_get_first_ru_only=${True}
#    ${aehc_lte_cell_list}    Get Cell List For Special RU    cell_type=lte    whether_get_first_ru_only=${True}
#    ${aehc_lte_cell_list_length}     Get Length    ${aehc_lte_cell_list}
#    FOR    ${enb_index}    IN RANGE    ${enb_length}
#        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
#    END
#    # Below for verify L3 call (NSA,loop for SA,loop for 4G)
#    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#    Procedures.Verify CA Basic L3 Call    ue_mode=NSA
#    ...                                   ul_throughput=150M
#    ...                                   dl_throughput=2500MKbits/sec
#    ...                                   notbarred_cell_index=all
#    ...                                   b1_select_cell_index=${PCELL_INDEX}
#    ...                                   exp_status=barred
#    ...                                   whether_do_lte_barred_action=${True}
#    ...                                   whether_check_scell_addition=${False}
#    ...                                   tput_collect_duration=60
#    ...                                   ignore_time=15sec
#    ...                                   target_DL_avg_percent=0.1
#    ...                                   target_UL_avg_percent=0.1
#    ...                                   min_DL_percent=0.05
#    ...                                   min_UL_percent=0.05
#    ...                                   enb_index=${fdd_enb_index}
#    Verify Non-CA Basic L3 Call One By One    cell_list=${aehc_nr_cell_list}    ue_type=${ue_type}    ue_index=${0}
#    Run Keyword If    '${aehc_lte_cell_list_length}'!='${0}'      Verify 4G Non-CA Basic L3 Call One By One
#    ...     cell_list=${aehc_lte_cell_list}    ue_type=${ue_type}    ue_index=${0}    whether_do_barred_action=${True}
#    # Below for operation(locked 5G BBMOD)
#    Lock Or Unlock Or Reset BBMOD   cell_index=${PCELL_INDEX}   expect_bbmod_status=Locked   cell_type=nr
#    # Below to check after operation(rerun 4G call to verify no sleeping cell)
#    Run Keyword If    '${aehc_lte_cell_list_length}'!='${0}'      Verify 4G Non-CA Basic L3 Call One By One
#    ...     cell_list=${aehc_lte_cell_list}    ue_type=${ue_type}    ue_index=${0}    whether_do_barred_action=${True}
#    # Below for operation(unlocked 5G BBMOD)
#    Lock Or Unlock Or Reset BBMOD   cell_index=${PCELL_INDEX}   expect_bbmod_status=Unlocked   cell_type=nr
#    # Below for verify L3 call after operation(rerun NSA and SA)
#    Procedures.Verify CA Basic L3 Call    ue_mode=NSA
#    ...                                   ul_throughput=150M
#    ...                                   dl_throughput=2500MKbits/sec
#    ...                                   notbarred_cell_index=all
#    ...                                   b1_select_cell_index=${PCELL_INDEX}
#    ...                                   exp_status=barred
#    ...                                   whether_do_lte_barred_action=${True}
#    ...                                   whether_check_scell_addition=${False}
#    ...                                   tput_collect_duration=60
#    ...                                   ignore_time=15sec
#    ...                                   target_DL_avg_percent=0.1
#    ...                                   target_UL_avg_percent=0.1
#    ...                                   min_DL_percent=0.05
#    ...                                   min_UL_percent=0.05
#    ...                                   enb_index=${fdd_enb_index}
#    Verify Non-CA Basic L3 Call One By One    cell_list=${aehc_nr_cell_list}    ue_type=${ue_type}    ue_index=${0}
#    # Below for operation(locked 4G BBMOD)
#    Lock Or Unlock Or Reset BBMOD   cell_index=${aehc_lte_cell_list}[0]   expect_bbmod_status=Locked   cell_type=lte
#    # Below for verify L3 call after operation(rerun NSA and SA to check no sleepingcell)
#    Procedures.Verify CA Basic L3 Call    ue_mode=NSA
#    ...                                   ul_throughput=150M
#    ...                                   dl_throughput=2500MKbits/sec
#    ...                                   notbarred_cell_index=all
#    ...                                   b1_select_cell_index=${PCELL_INDEX}
#    ...                                   exp_status=barred
#    ...                                   whether_do_lte_barred_action=${True}
#    ...                                   whether_check_scell_addition=${False}
#    ...                                   tput_collect_duration=60
#    ...                                   ignore_time=15sec
#    ...                                   target_DL_avg_percent=0.1
#    ...                                   target_UL_avg_percent=0.1
#    ...                                   min_DL_percent=0.05
#    ...                                   min_UL_percent=0.05
#    ...                                   enb_index=${fdd_enb_index}
#    Verify Non-CA Basic L3 Call One By One    cell_list=${aehc_nr_cell_list}    ue_type=${ue_type}    ue_index=${0}
#    ## Below for operation(unlocked 4G BBMOD)
#    Lock Or Unlock Or Reset BBMOD   cell_index=${aehc_lte_cell_list}[0]   expect_bbmod_status=Unlocked   cell_type=lte
#    # Below for verify L3 call after operation(rerun NSA and SA adn 4G to check no sleepingcell)
#    Procedures.Verify CA Basic L3 Call    ue_mode=NSA
#    ...                                   ul_throughput=150M
#    ...                                   dl_throughput=2500MKbits/sec
#    ...                                   notbarred_cell_index=all
#    ...                                   b1_select_cell_index=${PCELL_INDEX}
#    ...                                   exp_status=barred
#    ...                                   whether_do_lte_barred_action=${True}
#    ...                                   whether_check_scell_addition=${False}
#    ...                                   tput_collect_duration=60
#    ...                                   ignore_time=15sec
#    ...                                   target_DL_avg_percent=0.1
#    ...                                   target_UL_avg_percent=0.1
#    ...                                   min_DL_percent=0.05
#    ...                                   min_UL_percent=0.05
#    ...                                   enb_index=${fdd_enb_index}
#    Verify Non-CA Basic L3 Call One By One    cell_list=${aehc_nr_cell_list}    ue_type=${ue_type}    ue_index=${0}
#    Run Keyword If    '${aehc_lte_cell_list_length}'!='${0}'      Verify 4G Non-CA Basic L3 Call One By One
#    ...     cell_list=${aehc_lte_cell_list}    ue_type=${ue_type}    ue_index=${0}    whether_do_barred_action=${True}
#    [Teardown]    Run Keyword And Ignore Error    TMO_Common_Case_Teardown
##
##5603086_TOL_case_86_CB006483_Trigger_Snapshot_on_eNB_when_LSS_unreachable
##    [Documentation]    without call
##    [Tags]    T813_OAM
##    [Setup]    TMO_Common_Case_Setup    whether_get_ca_info=${False}    whether_set_pa_value=${False}
##    Modify Lss IP Adsress Paremeters   enb_index=${1}
##    Check TMO Gnb Ready And All Cell On Air
##    Verify Whether FID10 Triggered On Enb   cell_index=${PCELL_INDEX}    enb_index=${1}
##    ${first_time_VmallocUsed_vlaue}   Execute Memory On ENB     enb_index=${1}
##    sleep   10min
##    ${second_time_VmallocUsed_vlaue}   Execute Memory On ENB    enb_index=${1}
##    ${deviation_status}   Evaluate   int(${second_time_VmallocUsed_vlaue})-int(${first_time_VmallocUsed_vlaue}) <= ${1000}
##    Should Be True    ${deviation_status}    msg=VmallocUsed deviation is more than 1000,memory maybe leak!
##    [Teardown]   Run Keyword And Ignore Error      Modify Lss IP Adsress Paremeters   lssIPaddress=10.57.177.22   enb_index=${1}
#
#5603037_TOL_case_32_Siso_all_RF_Module_Lock_and_unlock_from_gNB
#    [Documentation]    TL813:UE0-SDX65, AEHC0 5G SA call and 4G call.
#    [Tags]    TA_NOT_NEEDED
#    [Setup]    TMO_Common_Case_Setup    whether_get_ca_info=${False}    whether_set_pa_value=${False}
#    ${aehc_nr_cell_list}    Get Cell List For Special RU    cell_type=nr    whether_get_first_ru_only=${True}
#    ${aehc_lte_cell_list}    Get Cell List For Special RU    cell_type=lte    whether_get_first_ru_only=${True}
#    ${aehc_lte_cell_list_length}     Get Length    ${aehc_lte_cell_list}
#    Verify Non-CA Basic L3 Call One By One    cell_list=${aehc_nr_cell_list}    ue_type=${ue_type}    ue_index=${0}
#    Run Keyword If    '${aehc_lte_cell_list_length}'!='${0}'      Verify 4G Non-CA Basic L3 Call One By One
#    ...     cell_list=${aehc_lte_cell_list}    ue_type=${ue_type}    ue_index=${0}    whether_do_barred_action=${True}
#    ## Below for operation
#    ${enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#    Do All RU Locked Or Unlocked On Gnb   ru_status=Locked    enb_index=${enb_index}
#    sleep   1min
#    Do All RU Locked Or Unlocked On Gnb   ru_status=Unlocked    enb_index=${enb_index}
#    Check GNB On Air And Unexpect Alarm Should Not Exist
#    Check ENB On Air And Unexpect Alarm Should Not Exist
#    Verify Non-CA Basic L3 Call One By One    cell_list=${aehc_nr_cell_list}    ue_type=${ue_type}    ue_index=${0}
#    Run Keyword If    '${aehc_lte_cell_list_length}'!='${0}'      Verify 4G Non-CA Basic L3 Call One By One
#    ...     cell_list=${aehc_lte_cell_list}    ue_type=${ue_type}    ue_index=${0}    whether_do_barred_action=${True}
#    [Teardown]    Run Keyword And Ignore Error    TMO_Common_Case_Teardown
#
#5603075_TOL_case_75_SISO_reset_BBMOD
#     [Documentation]    TL813:UE0-SDX65, AEHC0 5G SA call(5gcell_301/311) and 4G call(ltecell_131/141).
#     [Tags]    TA_NOT_NEEDED
#     [Setup]    TMO_Common_Case_Setup    whether_get_ca_info=${False}    whether_set_pa_value=${False}
#     ${bbmod_distname_list}    Get BBMOD List For RU AEHC Or AZHL
#     ${aehc_nr_cell_list}    Get Cell List For Special RU    cell_type=nr    whether_get_first_ru_only=${True}
#     ${aehc_lte_cell_list}    Get Cell List For Special RU    cell_type=lte    whether_get_first_ru_only=${True}
#     ${aehc_lte_cell_list_length}     Get Length    ${aehc_lte_cell_list}
#     FOR    ${bbmod_distname}    IN    @{bbmod_distname_list}
#         Wait Until Keyword Succeeds    2 min    20 sec    Connect to gnb coam via ssl    connection=GNB_OAM0
#         ...                                                                              gnb_index=${0}
#         coam.reset_unit    dist_name=${bbmod_distname}    reset_type=Warm    force_radio_reset=${True}
#         ...                timeout=${720}    connection=GNB_OAM0
#         Check GNB On Air And Unexpect Alarm Should Not Exist
#         Check ENB On Air And Unexpect Alarm Should Not Exist
#         # L3 call for nrcell-301 and nrcell-401, lncell-131 and lncell-141
#         Verify Non-CA Basic L3 Call One By One    cell_list=${aehc_nr_cell_list}    ue_type=${ue_type}    ue_index=${0}
#         Run Keyword If    '${aehc_lte_cell_list_length}'!='${0}'      Verify 4G Non-CA Basic L3 Call One By One
#         ...     cell_list=${aehc_lte_cell_list}    ue_type=${ue_type}    ue_index=${0}    whether_do_barred_action=${True}
#     END
#     [Teardown]    Run Keyword And Ignore Error    TMO_Common_Case_Teardown