*** Settings ***
Documentation    Auther:lei.jia@nokia-sbell.com

Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC001795/Resources/5GC001795_common.robot
Resource    taf/rfrl/common_resources/robot/coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot

*** Variables ***

*** Keywords ***
Start Qualcomm L3 Call With CA
    [Documentation]    Auther:lei.jia@nokia-sbell.com
    ...                Description：this keyword is used to perform ue attach, start ul&dl traffic and calculate throughput with power ue
    [Arguments]     ${ul_data_transfer}
    ...           ${dl_data_transfer}
    ...           ${expect_ul_tput}=${None}
    ...           ${expect_pcell_dl_tput}=${None}
    ...           ${expect_scell_dl_tput}=${None}
    ...           ${start_traffic_duration}=900
    ...           ${check_tput_duration}=240
    ...           ${reset_sol}=ue_reboot
    ...           ${asik_alais}=ASIK Master
    ...           ${connection}=GNB_OAM
    ...           ${4G_check}=True
    ...           ${iperf_type}=via_command
    ...           ${hw_slot}=${1}
    ...           ${is_askey_used}=False
    ...           ${ignore_time}=1min
    ...           ${target_avg_percent}=1.0
    ...           ${actCarrierAggregation}=${False}
    ...           ${list_all_cell_ids}=${False}
    ...           ${ue_index}=${0}
    ...           ${pcellid}=${None}
    ...           ${scellid}=${None}
    ...           ${stop_traffic}=${True}
    ...           ${is_do_require_ue}=${True}
    run keyword and ignore error    csn.disconnect    connection=${asik_alais}
    Run Keyword And Ignore Error    csn.disconnect      connection=cpc_${ue_index}
    connection_alias_store.Connect to Common Unit Master
    Run Keyword And Ignore Error    Start UE Attach With Power UE
    ...           reset_sol=${reset_sol}
    ...           ue_index=${ue_index}
    ...           4G_check=${4G_check}
    ...           is_askey_used=${is_askey_used}
    ...           is_do_require_ue=${is_do_require_ue}
    ${iperf_type}    Set Variable If    '${ue_type}' == 'samsung'     via_command    via_app
    Start L3 Call With Power UE
    ...            ul_data_transfer=${ul_data_transfer}
    ...            dl_data_transfer=${dl_data_transfer}
    ...            duration=${start_traffic_duration}
    ...            iperf_type=${iperf_type}
    ...            ue_index=${ue_index}
    ${pcell_list}    Run keyword if    '${pcellid}'!= '${None}'    Get NRCELLID based on CELLID
    ...    cellid=${pcellid}    connection=${connection}    list_all_cell_ids=${list_all_cell_ids}
    ${scell_list}    Run keyword if    '${scellid}'!= '${None}'    Get NRCELLID based on CELLID
    ...    cellid=${scellid}    connection=${connection}    list_all_cell_ids=${list_all_cell_ids}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${check_tput_duration}    ignore_time=${ignore_time}
    Run keyword if    '${pcellid}'!= '${None}'     Run Keyword And Continue On Failure    Power_ue.Check Bi Tput
    ...                ue_type=${ue_type}    cells=${pcell_list}    log=${tput_log}    target_avg_percent=${target_avg_percent}
    ...                ultarget_throughput=${expect_ul_tput}    dltarget_throughput=${expect_pcell_dl_tput}
    Run keyword if    '${scellid}'!= '${None}'     Run Keyword And Continue On Failure    power_ue.Check Tput
    ...               ue_type=${ue_type}    direction=DL    cells=${scell_list}    log=${tput_log}
    ...               target_throughput=${expect_scell_dl_tput}    target_avg_percent=${target_avg_percent}
    [Teardown]    Run keyword if    ${stop_traffic}    Run Keyword And Ignore Error    Stop Traffic With Power UE    ue_index=${ue_index}

Keep only Pcell notbarred for CA testing
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...    Keep only Pcell to not barred status, and set all other cells to barred status
    ...    step1: get pcell id and scell id from current configuration.
    ...    step2: bar all other cells, and set pcell notbarred before ue attach
    [Arguments]    ${connection}=GNB_OAM
    @{expected_pcell_list}    create list    ${PCELLID}
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${expected_pcell_list}    connection=${connection}

Keep only Scell notbarred for Non-CA testing
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...    Keep only Scell to not barred status, and set all other cells to barred status
    ...    step1: get pcell id and scell id from current configuration.
    ...    step2: bar all other cells, and set scell notbarred before ue attach
    [Arguments]    ${connection}=GNB_OAM
    @{expected_pcell_list}    create list    ${SCELLID}
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${expected_pcell_list}    connection=${connection}

Get PcellID and SCELLID from scf
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...    Get TDD cells ids and FDD cell ids, Pscell and Scell ID from scf configuration
    [Arguments]    ${connection}=GNB_OAM
    @{pcell_scell_ids}    create list
    ${dict_cell_ids_tech}    get_cell_ids_based_on_cell_technology    connection_alias=${connection}
    set suite variable    ${TDD_cell_list}    ${dict_cell_ids_tech['TDD']}
    set suite variable    ${FDD_cell_list}    ${dict_cell_ids_tech['FDD']}
    ${ca_pcell_type}    Get CA Pcell type From SCF    connection=${connection}
    FOR    ${item}    IN    @{ca_pcell_type}
        ${pcell_cell_list}    set variable if    'Fdd'=='${item}'    ${FDD_cell_list}     ${TDD_cell_list}
        ${pcell_scell_id_dict}    Get Pcell and Scell ID In Pair    cell_lists=${pcell_cell_list}    connection=${connection}
        append to list    ${pcell_scell_ids}    ${pcell_scell_id_dict}
    END
    ${pcell_no}    get length    ${pcell_scell_ids}
    run keyword if      ${pcell_no} > 1    Get expected CA Pcell id    pcell_scell_ids=${pcell_scell_ids}    used_pcell_id=${ca_used_pcell_id}
    log to console    PCELL_ID:${pcell_scell_id_dict['pcellid']}, SCELL_ID:${pcell_scell_id_dict['scellid']}
    set suite variable    ${PCELLID}    ${pcell_scell_id_dict['pcellid']}
    set suite variable    ${SCELLID}    ${pcell_scell_id_dict['scellid']}

Get expected CA Pcell id
    [Arguments]     ${pcell_scell_ids}
    ...              ${used_pcell_id}
    FOR    ${pcell_scell_id_dict}    IN    @{pcell_scell_ids}
        Run Keyword If   '${used_pcell_id}'== ${pcell_scell_id_dict['pcellid']}
        ...    log to console  PCELL_ID:${used_pcell_id}, SCELL_ID:${pcell_scell_id_dict['scellid']}
    END

Get Pcell and Scell ID In Pair
    [Arguments]     ${cell_lists}
    ...              ${connection}=GNB_OAM
    ...              ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...              ${MRBTS_id}=${tl.gnbs[0].instance_id}
    ...              ${NRREL_id}=1
    @{PCELL_IDS}    create list
    ${pcell_scell_id_dict}    Create Dictionary
    FOR    ${cellid}    IN    @{cell_lists}
        ${sCellAdditionMethod}    Get Parameter Value From SCF    parameter=sCellAdditionMethod
        ...                                                       dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cellid}/NRREL-${NRREL_id}
        ...                                                       connection=${connection}
        Run Keyword If   '${sCellAdditionMethod}'== 'blind'    append to list    ${PCELL_IDS}    ${cellid}
    END
    FOR    ${cellid}    IN    @{PCELL_IDS}
        ${scellid}    Get Parameter Value From SCF    parameter=lcrId
        ...                                           dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cellid}/NRREL-${NRREL_id}
        ...                                           connection=${connection}
        set to dictionary    ${pcell_scell_id_dict}    pcellid=${cellid}    scellid=${scellid}
    END
    [Return]    ${pcell_scell_id_dict}

Get CA Pcell type From SCF
    [Arguments]     ${connection}=GNB_OAM
    ...              ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...              ${MRBTS_id}=${tl.gnbs[0].instance_id}
    ...              ${dist_name}=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRDU-1
    ${actInterNumerologyCa}    Get Parameter Value From SCF    parameter=actInterNumerologyCa
    ...                                                        dist_name=${dist_name}
    ...                                                        connection=${connection}
    ${ca_pcell_type}    Run keyword if    '${actInterNumerologyCa}'== 'true'    Get CASupportList From SCF    connection=${connection}
    [Return]    ${ca_pcell_type}

Get Parameter Value From SCF
    [Arguments]     ${parameter}
    ...              ${dist_name}
    ...              ${connection}=GNB_OAM
    ...              ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...              ${MRBTS_id}=${tl.gnbs[0].instance_id}
    ${parameter_value}    coam_parameter.get_single_value_from_scf_file    parameter=${parameter}
    ...              dist_name=${dist_name}
    ...              connection=${connection}
    [Return]    ${parameter_value}

Get CASupportList From SCF
    [Arguments]     ${connection}=GNB_OAM
    ...              ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...              ${MRBTS_id}=${tl.gnbs[0].instance_id}
    ...              ${dist_name}=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRDU-1
    @{caSupportList_param}    create list
    @{ca_pcell_type_list}    create list
    &{carrierAggregationSupportList_dict}    Create Dictionary    dist_name=${dist_name}
    ...                                                           parameter=carrierAggregationSupportList
    ...                                                           value=none
    Append To List    ${caSupportList_param}    ${carrierAggregationSupportList_dict}
    ${carrierAggregationSupportList}    coam_parameter.get_list_values_from_scf_file    parameters=${caSupportList_param}
    ...                                                                                 connection=${connection}
    ${casupportlist_value}    set variable    ${carrierAggregationSupportList[0]['value']}
    FOR    ${item}    IN    @{casupportlist_value}
        ${ca_pcell_type}   Set Variable If
        ...   'ca_Fdd' in '${item}'    Fdd
        ...   'ca_Fr1Tdd' in '${item}'    Tdd
        append to list    ${ca_pcell_type_list}    ${ca_pcell_type}
    END
    ${ca_pcell_type}      remove duplicates      ${ca_pcell_type_list}
    [Return]    ${ca_pcell_type}

Stop Traffic and Restore Att Value
    [Documentation]    Auther: stella.lin@nokia-sbell.com
    [Arguments]    ${is_stop_traffic_needed}=${True}
    Run Keyword If    '${is_stop_traffic_needed}'=='True'    run keywords
    ...    Run Keyword And Ignore Error    Stop Traffic With Power UE     AND
    ...    Run Keyword And Ignore Error    Modify NR Signal    value=0    AND
    ...    Run Keyword And Ignore Error    Modify LTE Signal    value=15    AND
    ...    Run Keyword And Ignore Error    csn.execute    command=killall tcpdump    connection=ASIK Master

Modify NR Signal
    [Documentation]    Auther: stella.lin@nokia-sbell.com
    [Arguments]    ${value}
    ${nr_port_numbers}    create list    3    4    5    6
    attenuator.setup_attenuator
    ...    ip_addr=${ATTENUATOR_ADDR}
    ...    port=${attenuation_port}
    ...    attenuation_port_numbers=${nr_port_numbers}
    ...    vendor=HBTE
    ${channels_to_modify}    Create Dictionary    3=${value}    4=${value}    5=${value}    6=${value}
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=${channels_to_modify}

Modify LTE Signal
    [Documentation]    Auther: stella.lin@nokia-sbell.com
    [Arguments]    ${value}
     ${value}    convert to integer     ${value}
    ${lte_port_numbers}    create list    10
    attenuator.setup_attenuator
    ...    ip_addr=${ATTENUATOR_ADDR}
    ...    port=${attenuation_port}
    ...    attenuation_port_numbers=${lte_port_numbers}
    ...    vendor=HBTE
    wait until keyword succeeds   5 min   5 sec   attenuator.set_attenuation
    ...    port=${10}    value=${value}    confirm=${True}

Verify Data Continues On LTE
    [Documentation]    Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${data_switch_time}    ${expect_data_amount}    ${dl_ul_type}=DL
    ${counter_string}    Set Variable If    '${dl_ul_type}'=='DL'
    ...                  {'M8012C76': '[LSP01034B11] CELLS/LNCEL-${anchore_enb_cellid}/LTE_Cell_Throughput/MAC_SDU_VOL_DL_DTCH'}
    ...                  {'M8012C71': '[LSP01034B11] CELLS/LNCEL-${anchore_enb_cellid}/LTE_Cell_Throughput/MAC_SDU_VOL_UL_DTCH'}
    ${ul_dl_tput_counter}    Evaluate    [${counter_string}]
#    Verify Counter Added As Expected    counter_info_dict_list=${ul_dl_tput_counter}
#    ...                                 counter_generatd_time=${data_switch_time}
#    ...                                 expect_added_value=${expect_data_amount}
#    ...                                 gnb_enb_type=enb
#    ...                                 counter_duration=15
    ${required_counter_values}    Get Required Counter Values    counter_info_dict_list=${ul_dl_tput_counter}
    ...                                                          counter_generatd_time=${data_switch_time}
    ...                                                          gnb_enb_type=enb
    ...                                                          counter_duration=15
    Log    counter info: ${required_counter_values}, effective duration ${available_duration}.
    ${counter_value}    Get Dictionary Values    ${required_counter_values}
    ${expect_data_amount}     Convert To Number    ${expect_data_amount}
    ${counter_value}    Convert To Number    ${counter_value[0]}
    Should Be True    ${counter_value}>=${expect_data_amount}    msg=Data switched to LTE is not meet the requirement.

Verify SIB In MIB Message On gNB Side
    [Documentation]    Auther: stella.lin@nokia-sbell.com
    [Arguments]    ${bip_log}
    cap.Read Cap    cap_file=${bip_log}    X=lua_script:${luashark_path}
#    ${sib_exist_status}    cap.Get Element Value    element_expression=mib.mib_pdcch_ConfigSIB1
    ${sib_exist_status}    cap.Get Element Value    element_expression=nr-rrc.pdcch_ConfigSIB1_element
    ...    element_idx=${0}
    ...    default_value=${True}
    ${sib_exist_status}    Get Length    ${sib_exist_status}
    Should Be True    ${sib_exist_status}>${0}    msg=SIB Message is not in MIB message send on gnb side.

Verify ACK NACK With BIP
    [Documentation]    Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${bip_log}    ${ack_nack_type}=ACK
    cap.Read Cap    cap_file=${bip_log}    display_filter=uldata_pucchreceiverespharqd    X=lua_script:${LUASHARK_PATH}
    ${ackNack_vlaue}    cap.Get element value    element_expression=UlData_PucchReceiveRespHarqD.ackNack.ackNack_item_0
    ${count_ackNack}    Get Length    ${ackNack_vlaue}
    ${count_ackNack}    Convert To Number    ${count_ackNack}
    ${count_80}    Get Match Count    ${ackNack_vlaue}    80
    ${count_c0}    Get Match Count    ${ackNack_vlaue}    c0
    ${count_f0}    Get Match Count    ${ackNack_vlaue}    f0
    ${count_f8}    Get Match Count    ${ackNack_vlaue}    f8
    ${ack_sum}    Evaluate    ${count_80}+${count_c0}+${count_f0}+${count_f8}
    ${ack_sum}    Convert To Number    ${ack_sum}
    ${ack_ratio}    Run Keyword If    '${ack_nack_type}'=='ACK'    Evaluate    ${ack_sum}/${count_ackNack}
    Run Keyword If    '${ack_nack_type}'=='ACK'    Should Be True    ${ack_ratio}>=0.9    msg=ack is not working properly.
    ...        ELSE    Should Be Equal    ${ack_sum}    ${0}    msg=NACK is not working properly.

#Verify Counter Added As Expected
#    [Documentation]   Stella.lin@nokia-sbell.com
#    ...               Verify counter is added as expected.
#    [Arguments]    ${counter_info_dict_list}
#    ...            ${counter_generatd_time}
#    ...            ${expect_added_value}=1
#    ...            ${gnb_enb_type}=gnb
#    ...            ${counter_duration}=05
#    ...            ${timeout}=60
#    ${counters_result_dict}    Get Multi BTS Counters Info Via Webui    counter_info_dict_list=${counter_info_dict_list}
#    ...                                                                 gnb_enb_type=${gnb_enb_type}    timeout=${timeout}
#    Log    ${counters_result_dict}
#    ${counter_items}    Get Dictionary Items    @{counter_info_dict_list}[0]
#    ${timestamps}    Set Variable    ${counters_result_dict['@{counter_items}[0]']}
#    ${counter_belonged_to_timestamp}    Get Timestamp For Generated Counter    counter_info=${timestamps}
#    ...                                 counter_generatd_time=${counter_generatd_time}
#    ...                                 duration=${counter_duration}
#    ${target_duration}    Get Available Duration For Counter    counter_belonged_to_timestamp=${counter_belonged_to_timestamp}
#    ...                                                  counter_generatd_time=${counter_generatd_time}
#    ...                                                  counter_duration=${counter_duration}
#    Set Test Variable    ${target_duration}
#    :FOR    ${counter_item}    IN    @{counter_info_dict_list}
#    \    ${counter_id}    Get Dictionary Keys    ${counter_item}
#    \    ${counter_timestamps}     Set Variable    ${counters_result_dict['@{counter_id}[0]']}
#    \    ${counter_value}    Set Variable    ${counter_timestamps['${counter_belonged_to_timestamp}']}
#    \    Should Be True    ${counter_value}>=${expect_added_value}    msg=Counter @{counter_id}[0] is not added as expected.

Get Required Counter Values
    [Documentation]   Stella.lin@nokia-sbell.com
    ...               Verify counter is added as expected.
    [Arguments]    ${counter_info_dict_list}
    ...            ${counter_generatd_time}
    ...            ${gnb_enb_type}=gnb
    ...            ${counter_duration}=05
    ...            ${timeout}=60
    ${counters_result_dict}    Get Multi BTS Counters Info Via Webui    counter_info_dict_list=${counter_info_dict_list}
    ...                                                                 gnb_enb_type=${gnb_enb_type}    timeout=${timeout}
    Log    ${counters_result_dict}
    ${counter_items}    Get Dictionary Items    ${counter_info_dict_list}[0]
    ${timestamps}    Set Variable    ${counters_result_dict['${counter_items}[0]']}
    ${counter_belonged_to_timestamp}    Get Timestamp For Generated Counter    counter_info=${timestamps}
    ...                                 counter_generatd_time=${counter_generatd_time}
    ...                                 duration=${counter_duration}
    ${available_duration}    Get Available Duration For Counter    counter_belonged_to_timestamp=${counter_belonged_to_timestamp}
    ...                                                  counter_generatd_time=${counter_generatd_time}
    ...                                                  counter_duration=${counter_duration}
    Set Test Variable    ${available_duration}
    ${required_counter_values}    Create Dictionary
    FOR    ${counter_item}    IN    @{counter_info_dict_list}
        ${counter_id}    Get Dictionary Keys    ${counter_item}
        ${counter_timestamps}     Set Variable    ${counters_result_dict['${counter_id}[0]']}
        ${counter_value}    Set Variable    ${counter_timestamps['${counter_belonged_to_timestamp}']}
        Set To Dictionary    ${required_counter_values}    ${counter_id[0]}=${counter_value}
    END
    [Return]    ${required_counter_values}

Get Multi BTS Counters Info Via Webui
    [Documentation]   Stella.lin@nokia-sbell.com
    [Arguments]    ${counter_info_dict_list}    ${gnb_enb_type}=gnb    ${timeout}=60
    Run Keyword If    '${gnb_enb_type}'=='gnb'     COAM Navigate to login page via webUI
    ...         ELSE    eNB Login Page Via WebUI
    ${counters_result_dict}    Create Dictionary
    FOR    ${item}    IN    @{counter_info_dict_list}
        ${counter_id_and_full_path}    Get Dictionary Items    ${item}
        ${counter_result}    selenium_coam.get_bts_counters_info    counter_id=${counter_id_and_full_path}[0]
    ...                       full_path=${counter_id_and_full_path}[1]
    ...                       timeout_for_loading_available_counters=${timeout}
        Set To Dictionary    ${counters_result_dict}    ${counter_id_and_full_path}[0]=${counter_result}
    END
    [Return]    ${counters_result_dict}
    [Teardown]    selenium_coam.logout

Get Timestamp For Generated Counter
    [Documentation]   Stella.lin@nokia-sbell.com
    [Arguments]    ${counter_info}    ${counter_generatd_time}   ${duration}=05
    ${started_counter_timestamps}    Get Dictionary Keys    ${counter_info}
    ${counter_generatd_time}    DateTime.Convert Date    ${counter_generatd_time}    result_format=%Y-%m-%d %H:%M:%S
    FOR    ${started_counter_timestamp}   IN    @{started_counter_timestamps}
         ${ended_conuter_timestamp}    DateTime.Add Time To Date    ${started_counter_timestamp}    00:${duration}:00
         ${status}    Run Keyword And Return Status    Should Be True
        ...          '${started_counter_timestamp}' <= '${counter_generatd_time}' <= '${ended_conuter_timestamp}'
         Return From Keyword If     ${status}    ${started_counter_timestamp}
    END

Get Available Duration For Counter
    [Documentation]   Stella.lin@nokia-sbell.com
    [Arguments]    ${belonged_counter_timestamp}    ${counter_generatd_time}    ${counter_duration}=05
    ${ended_conuter_timestamp}    DateTime.Add Time To Date    ${belonged_counter_timestamp}    00:${counter_duration}:00
    ${duration}    Subtract Date From Date    ${ended_conuter_timestamp}    ${counter_generatd_time}
    [Return]    ${duration}

eNB Login Page Via WebUI
    [Documentation]    Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${download_dir}=${TS_CASE_LOG_PATH}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
    ...                    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...                    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...                    download_dir=${download_dir}
    selenium_coam.disable_message_box


Modify UL Leg Switch Case Related Parameters
    [Documentation]    Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${nrcell_id}=${cellid}
    ${parameter_string}   Catenate
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${nrcell_id}', 'parameter': 'actDynUlDataSplitMode','value': 'true'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${nrcell_id}', 'parameter': 'pucchDataDtxNumOfSamples','value': '10'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${nrcell_id}', 'parameter': 'puschDataDtxNumOfSamples','value': '10'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${nrcell_id}', 'parameter': 'rloDtxRatioThreshold','value': '1'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${nrcell_id}', 'parameter': 'rloConsecDtxThreshold','value': '1'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${nrcell_id}', 'parameter': 'rloSinrThreshold','value': '10'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${nrcell_id}', 'parameter': 'rlResumeSinrThreshold','value': '14'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${nrcell_id}', 'parameter': 'rlResumePathLossThreshold','value': '95'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRPMRNL-1', 'parameter': 'miNrRadBearer','value': '5min'}
    ${parameter_to_modify}    Evaluate    [${parameter_string}]
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameter_to_modify}
    ...                                            timeout=${180}


Get RxPower From BIP
    [Documentation]    Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${bip_log}
    cap.Read Cap    cap_file=${bip_log}    X=lua_script:${LUASHARK_PATH}
    ${pusch_rxpower}    cap.Get element value    element_expression=UlData_PuschReceiveRespPs.grants_item_15.rxPower
    ...                                          element_idx=${0}
    ...                                          default_value=${True}
    ${pusch_sum}    Set Variable    ${0}
    FOR    ${item}    IN    @{pusch_rxpower}
        ${pusch_sum}     Evaluate    ${pusch_sum} + ${item}
    END
    ${length}    Get Length    ${pusch_rxpower}
    ${pusch_rxpower_avg}    Evaluate    ${pusch_sum} /${length}
    ${pusch_rxpower_avg}    Convert To Number    ${pusch_rxpower_avg}
    ${pucch_rxpower}    cap.Get element value    element_expression=UlData_PucchReceiveRespPs.pucchResources_item_15.rxPower
    ...                                          element_idx=${0}
    ...                                          default_value=${True}
    ${pucch_sum}    Set Variable    ${0}
    FOR    ${item}    IN    @{pucch_rxpower}
        ${pucch_sum}     Evaluate    ${pucch_sum} + ${item}
    END
    ${length}    Get Length    ${pucch_rxpower}
    ${pucch_rxpower_avg}    Evaluate    ${pucch_sum} /${length}
    ${pucch_rxpower_avg}    Convert To Number    ${pucch_rxpower_avg}
    ${rxpower_dict}    Create Dictionary    pucch_rxpower=${pucch_rxpower_avg}    pusch_rxpower=${pusch_rxpower_avg}
    [Return]    ${rxpower_dict}

TOL Cell Lock Unlock on GNB
    [Documentation]  Author: lei.jia@nokia-sbell.com
    ...                Descrition：query cell number then lock&unlock cell one by one, Single cell in one cell_group
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=120
    ${cell_id_list}    COAM Get GNB Cells ID list    connection=${connection}
    ${cell_groupid_list}    Get Cell Group ID list via Admin CLI    connection=${connection}
    ${allowed_faults}    Create List    @{GNB_ALLOWED_FAULT}    ${fault_7319}    ${fault_7300}
    FOR    ${cell_idx}    IN    @{cell_id_list}
        ${cell_group_idx}    Get Index From List    ${cell_id_list}   ${cell_idx}
        ${cell_group_idx}    convert to integer    ${cell_group_idx}
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist
        ...    allowed_faults=${GNB_ALLOWED_FAULT}    connection=${connection}
        Perform cell lock via rest api    cell_idx=${cell_idx}    timeout=${timeout}
        Wait Until Keyword Succeeds    90 sec    3 sec    Cell Should Be Locked
        ...    cell_idx=${cell_idx}    cell_group_idx=${cell_groupid_list[${cell_group_idx}]}
        ...    connection=${connection}
    END
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${allowed_faults}    connection=${connection}
    FOR    ${cell_idx}    IN    @{cell_id_list}
        ${cell_group_idx}    Get Index From List    ${cell_id_list}   ${cell_idx}
        ${cell_group_idx}    convert to integer    ${cell_group_idx}
        Perform cell unlock via rest api    cell_idx=${cell_idx}    timeout=${timeout}
        Wait Until Keyword Succeeds    600 sec    3 sec    Cell Should Be Unlocked    cell_idx=${cell_idx}
        ...    cell_group_idx=${cell_groupid_list[${cell_group_idx}]}
        ...    connection=${connection}
    END
    Wait Until Keyword Succeeds    600 sec    5 sec    COAM Check GNB cell on air    connection=${connection}
    Wait Until Keyword Succeeds    300 sec   5 sec     Check Gnb Type Via Webui
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${GNB_ALLOWED_FAULT}    connection=${connection}
    COAM Wait for gnb ready and cell setup    timeout=10 min    connection=${connection}

Unlock all cells to recover env
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=120
    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ${cell_id_list}    COAM Get GNB Cells ID list    connection=${connection}
    ${cell_groupid_list}    Get Cell Group ID list via Admin CLI    connection=${connection}
    FOR    ${cell_idx}    IN    @{cell_id_list}
        ${cell_group_idx}    Get Index From List    ${cell_id_list}   ${cell_idx}
        ${cell_group_idx}    convert to integer    ${cell_group_idx}
        Perform cell unlock via rest api    cell_idx=${cell_idx}    timeout=${timeout}
        Perform cell group unlock via rest api    cellgrp_idx=${cell_groupid_list[${cell_group_idx}]}
    END
    COAM Wait for gnb ready and cell setup    timeout=10 min    connection=${connection}
    run keyword and ignore error    COAM Teardown gnb connections
    Run Keyword And Ignore Error   Connect to gnb coam via ssl
