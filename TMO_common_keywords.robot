*** Settings ***
Documentation    This is for TMO common keywords.
...              Please do not modify the file without notification to author
...              Author: jun.8.chen@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/syslog_validation.robot
Resource    taf/rfrl/uuf4all/uuf4all_test_cases.robot
Variables   ./TMO_Data.py
Library   ./4GL3call.py
Library     taf.rfrl.uuf4all.resources.python.uuf_rfrl_oam_kpi
Library    taf.sw.syslog    WITH NAME    sw_syslog
Variables   ./spark_TL73_multi_UE_config_lowTP_lowRSRP.py
Variables   ./spark_TL284_multi_UE_config_lowTP_lowRSRP.py
Variables   ./spark_TL80_multi_UE_config_lowTP_lowRSRP.py

*** Variables ***
${BASIC_SCF}    tmo_basic.xml
@{customers}             TMO US
${testline}         ${testline_name}
${ca}    VRF_HAZ4
${qc_domain}        MN_RAN
${qc_project}       RAN_VRF
${qc_set_name}    CB007835-5G-A - Key customer scenario testing - TMO TDD AEHC- Hangzhou
${case_name}    [1][1.0] 5603052_AEHC_cell_edge_case005_SA_RSRP_near_mid_far condition KPI_comparison_with RACHindex9_RACHindex206
${BTS_HOST_IP}    192.168.255.129  #  IP used in admin setup
@{wireshark_flag}    0x890073=0
@{SWCONFIG_special_flag}    0x4F0214=0
@{delete_flag}    0x4F0214

*** Keywords ***
#--- Setup And TearDown---#
TMO_Common_Suite_Setup
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${is_commission}=${False}    ${whether_do_prepare_ue}=${True}  ${upload_swconfig}=${True}
    ...            ${ue_index}=${0}    ${ute_space}=20    ${prefer_5g_nr_mode}=SA    ${gnb_scf_name}=None
    ...            ${turn_off_pa}=${True}
    csn.reset_cache
    Clearup UTE Space while keep syslog
    ${stream_version}    Common_setup_and_teardown.Get Active SW Version Based On Stream Version
    Set Suite Variable    ${stream_version}
    ## get how many UEs
    ${ue_length}    Get Length    ${tl.ues}
    Set Suite Variable    ${ue_length}
    ## get tl_prefix, such as T813/T073
    Set Suite Variable    ${tl_prefix}    ${testline_name.split('_')[-1][-4:]}
#    ${SCOUT_TL_NAME}=  Set Variable If    '${tl_prefix}'=='T813' or '${tl_prefix}'=='T284'
#    ...    ${testline_name}_5G    ${testline_name}
#    Set Suite Variable    ${SCOUT_TL_NAME}
    ## get how many ENBs
    ${enb_length}    Get Length    ${tl.enbs}
    Set Suite Variable    ${enb_length}
    ${dict_enb_Technology_index}    Get LTE Technology Value
    Set Suite Variable    ${DICT_ENB_TECHNOLOGY_INDEX}    ${dict_enb_Technology_index}
    Suite Log Path Create
    Run Keyword If    ${upload_swconfig}     Uplaod Default Swconfig File Before Commission
    log to console    --- start to commission---
    ${gnb_scf_name}    Set Variable If    '${gnb_scf_name}'!='${None}'
    ...    ${tl_prefix}_gNB_${stream_version}_${gnb_scf_name}.xml    ${tl_prefix}_gNB_${stream_version}.xml
    Set Suite Variable    ${BASIC_SCF}    ${SCF_PATH_ON_UTE}/${gnb_scf_name}
    Run Keyword And Continue On Failure    Common_setup_and_teardown.Common Suite Setup    scf_name=${gnb_scf_name}
    ...    is_commission=${is_commission}
    ...    timeout_for_commission=20 min
#    Update BasedPCellSwitchEnabled Status
#    Verify TMO Gnb Ready And All Cell On Air
#    ${delete_nrrel_param_list}    ${add_nrrel_param_list}   Get The Parameter List Of NRREL Config
#    Set Suite Variable    ${DELETE_NRREL_PARAM_LIST}    ${delete_nrrel_param_list}
#    Set Suite Variable    ${ADD_NRREL_PARAM_LIST}    ${add_nrrel_param_list}
#    Verify All Enbs Cell On Air
    Run Keyword If    ${turn_off_pa}    Trun Off All PA Ports
    ${ue_index}=  Get Variable Value    ${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}    ${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Suite Variable    ${ue_type}
    Kill Adb App    ue_index=${ue_index}
    ${whether_do_prepare_ue}    Set Variable If    'spark' in '${ue_type}'
    ...    ${False}     ${whether_do_prepare_ue}
#     turn off airphon mode and clear ELT space for MTK UE
    Run Keyword If    '${ue_type}' == 'mtk'     Clear Temp File Of ELT For MTK
    Run keyword if    '${ue_type}' == 'mtk'    Run Keyword And Ignore Error
    ...    MTK_common_keywords.Get UE Airmode status and Turnoff Airplane Mode    ue_index=${ue_index}
    Run Keyword If    ${whether_do_prepare_ue} and '${ue_type}' != 'mtk'    Procedures.Start UE Prepare    ue_index=${ue_index}
    ...               ue_type=${ue_type}
    ...    ELSE IF    ${whether_do_prepare_ue} and '${ue_type}' == 'mtk'    Procedures.Start UE Prepare MTK80    ue_index=${ue_index}
    ...               ue_type=${ue_type}
    Run Keyword And Continue On Failure    Run Keyword If    '${ue_type}'=='qct_dx50' and '${whether_do_prepare_ue}'=='${True}'
    ...    Procedures.Check network mode    ue_index=${ue_index}
    &{fault_4203}     Create Dictionary     faultId=${4203}
    &{fault_4459}     Create Dictionary     faultId=${4459}
    &{fault_8000}     Create Dictionary     faultId=${8000}
    &{fault_1932}     Create Dictionary     faultId=${1932}
    &{fault_1933}     Create Dictionary     faultId=${1933}
    &{fault_1934}     Create Dictionary     faultId=${1934}
    &{fault_61631}     Create Dictionary     faultId=${61631}
    &{fault_1838}     Create Dictionary     faultId=${1838}
    &{fault_4741}     Create Dictionary     faultId=${4741}
    &{fault_4681}     Create Dictionary     faultId=${4681}
    &{fault_4334}     Create Dictionary     faultId=${4334}
    &{fault_7311}     Create Dictionary     faultId=${7311}
    &{fault_4293}     Create Dictionary     faultId=${4293}
    &{fault_4203}     Create Dictionary     faultId=${4203}
    &{fault_4775}     Create Dictionary     faultId=${4775}
    &{fault_7319}     Create Dictionary     faultId=${7319}
    &{fault_4297}     Create Dictionary     faultId=${4297}
    &{fault_4420}     Create Dictionary     faultId=${4420}
    ${GNB_ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_4203}    ${fault_4459}   ${fault_1932}   ${fault_1934}
    ...                    ${fault_1838}     ${fault_4741}    ${fault_1933}    ${fault_4681}    ${fault_4334}    ${fault_7311}
    ...                    ${fault_4293}     ${fault_4297}    ${fault_7319}     ${fault_4420}    ${fault_4775}
    Set Suite Variable    ${GNB_ALLOWED_FAULT}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_61631}   ${fault_1838}   ${fault_4741}    ${fault_4459}
    ...     ${fault_4775}
    Set Suite Variable    ${ALLOWED_HISTORY_FAULT}
    robot_common_operations.Common Suite Setup
    Suite Log Path Create

Uplaod Default Swconfig File Before Commission
    [Documentation]    Author:lei.jia@nokia-sbell.com
    Connect to Common Unit Master
    ${scf_base_path}    String.Fetch From Left    ${CURDIR}    testsuite
    swconf.delete_parameter_of_swConfig_file    parametersList=${delete_flag}
    ...                                         filePath=${scf_base_path}commissionings/HGZ/${testline_name}/swconfig.txt
    swconf.Upload swConfig file to asik and crasign    localFilePath=${scf_base_path}commissionings/HGZ/${testline_name}/swconfig.txt
    ...    asik_alias=ASIK Master
    [Teardown]    csn.disconnect    connection=ASIK Master

TMO_Common_Case_Setup
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${whether_get_ca_info}=${True}
    ...            ${whether_set_pa_value}=${True}    ${3CC_support}=${False}
    ...            ${scf_name}=None    ${is_commission}=False    ${is_pdl_checking_needed}=${True}
    ...            ${swconfig_flag}=${None}
    Common_setup_and_teardown.Common Case Setup    scf_name=${scf_name}    is_commission=${is_commission}
    ...    timeout_for_commission=20 min
    Create Case Log Path
    Run Keyword If    '${swconfig_flag}'!='${None}'
    ...     Run Keywords    Backup and Modify swconfig file    swconfig_modify=@{SWCONFIG_${swconfig_flag}}    AND
    ...                     Perform gNB Reset site and Wait Onair
    Set Test Variable    ${test_case_id}    ${TEST NAME.split('_')[0]}
    Set Test Variable    ${case_params}    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']}
    Set Test Variable    ${PCELL_INDEX}    ${case_params.get('pcell_idx')}
    Set Test Variable    ${attenuator_list}    ${case_params.get('attenuator')}
    Set Test Variable    ${ca_technology}    ${case_params.get('ca_technology')}
    ${ca_technology_status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${case_params}    ca_technology
    Run Keyword If    ${ca_technology_status}    Set Test Variable    ${scell_technology}
    ...                                                               ${case_params.get('ca_technology').split('+')[-1]}
    Set Test Variable    ${LTE_CELL_INDEX}    ${case_params.get('lte_cell_idx')}
#    Set Test Variable    ${NSA_PA_RU_INDEX}    ${case_params.get('nsa_pa_ru_idx')}
    Set Test Variable    ${HO_PCELL_INDEX}    ${case_params.get('after_ho_pcell_idx')}
    ${ho_ca_technology_status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${case_params}    ho_ca_technology
    Run Keyword If    ${ho_ca_technology_status}    Set Test Variable    ${HO_SCELL_TECHNOLOGY}
    ...                                                                  ${case_params.get('ho_ca_technology').split('+')[-1]}
    Run Keyword If    ${whether_get_ca_info} and ${3CC_support}==${False}    Get CA Related Infomation    pcell_index=${PCELL_INDEX}
    ...    ELSE IF    ${whether_get_ca_info} and ${3CC_support}    Get 3CC Related Infomation    pcell_index=${PCELL_INDEX}
#    Run Keyword If    ${3CC_support}    Run Keyword And Continue On Failure    Update The Flag Whether Support 3CC
#    ...   3CC_flag=${True}    is_pdl_checking_needed=${is_pdl_checking_needed}
#    ...    ELSE    Update The Flag Whether Support 3CC    is_pdl_checking_needed=${is_pdl_checking_needed}
    Run Keyword If    ${whether_set_pa_value}    Set Case PA Or MCS Port Value    attenuator_list=${attenuator_list}    ue_index=${ue_index}
    Verify TMO Gnb Ready And All Cell On Air
    Verify All Enbs Cell On Air
    ${lte_whether_in_gnb}    Check LTE Whether In Gnb
    Set Test Variable    ${LTE_WHETHER_IN_GNB}    ${lte_whether_in_gnb}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    robot_common_operations.Common Case Setup

TMO_Common_Case_Setup_OAM
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${swconfig_flag}=${None}    ${is_commission}=${True}
    Common_setup_and_teardown.Common Case Setup
    Create Case Log Path
    Run Keyword If    '${swconfig_flag}'!='${None}'    Backup and Modify swconfig file    swconfig_modify=@{SWCONFIG_${swconfig_flag}}
    log to console    --- start to commission---
    ${is_commission}    Set Variable If    '${btsName_in_gnb}'=='${btsName_in_scf}'    ${False}    ${is_commission}
    Common_setup_and_teardown.Common Suite Setup    scf_name=${tl_prefix}_gNB_${stream_version}.xml    is_commission=${is_commission}
    ...    timeout_for_commission=20 min
    Verify TMO Gnb Ready And All Cell On Air
    Verify All Enbs Cell On Air
    Set Test Variable    ${test_case_id}    ${TEST NAME.split('_')[0]}
    ${case_params}    Set Variable    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']}
    Set Test Variable    ${PCELL_INDEX}    ${case_params.get('pcell_idx')}
    ${lte_whether_in_gnb}    Check LTE Whether In Gnb
    Set Test Variable    ${LTE_WHETHER_IN_GNB}    ${lte_whether_in_gnb}
    robot_common_operations.Common Case Setup

TMO_Common_Case_Setup_SISO
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${scf_name}=${None}    ${is_commission}=${True}
    ${scf_name_case}    Set Variable If    ${scf_name}!=${None}    ${scf_name}    ${tl_prefix}_gNB_${stream_version}.xml
    Common_setup_and_teardown.Common Case Setup    scf_name=${scf_name_case}    is_commission=${is_commission}
    ...    timeout_for_commission=20 min
    Create Case Log Path
    Verify TMO Gnb Ready And All Cell On Air
    Verify All Enbs Cell On Air
    robot_common_operations.Common Case Setup

TMO_Common_Case_Teardown
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${3CC_support}=${True}    ${ue_type}=${ue_type}    ${is_power_ue_code}=${False}
    ...            ${is_save_snapshot}=${True}   ${apn_address}=${tl.core.pdns[0].apn}    ${power_reset}=False
    ...            ${is_history_alarm_check}=${True}
    Run Keyword If    '${ue_type}'=='huawei_sigspark'    Run Keyword And Ignore Error
    ...    Spark_common_keywords.Spark Stop UE Log    ue_index=${ue_index}
    Procedures.Stop TMO L3 Call And Detach    ue_index=${ue_index}    ue_type=${ue_type}
    ...                                       is_power_ue_code=${is_power_ue_code}
    ...                                       apn_address=${apn_address}    power_reset=${power_reset}
    Run Keyword And Ignore Error    Stop Aasyslog And Download To TestPC    log_prefix=aasyslog
    Run Keyword And Ignore Error    Common Case Teardown    is_save_snapshot=${is_save_snapshot}
    Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_type=${mcs_type}
    Unexpect Alarm and History Alarm Should Not Exist    is_history_alarm_check=${is_history_alarm_check}
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error     Recover Collect Syslog On Control PC

TMO_Suite_Teardown
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
#    Run Keyword And Continue On Failure    Update The Flag Whether Support 3CC    3CC_flag=${True}
    robot_common_operations.Common Suite Teardown

TMO_AZHL_case_setup
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    Common_setup_and_teardown.Common Case Setup
    Wait Until Keyword Succeeds    5 min    5 sec    connection_alias_store.Connect to Common Unit Master
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
#    COAM Create log directory
    Common_setup_and_teardown.Create Case Log Path   
    Verify Gnb Type Cells Should Be Onair
    ${lte_whether_in_gnb}    Check LTE Whether In Gnb
    Set Test Variable    ${LTE_WHETHER_IN_GNB}    ${lte_whether_in_gnb}
#    COAM Wait For Gnb Ready And Cell Setup    timeout=15 min
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${GNB_ALLOWED_FAULT}
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    ${cell_list}    Get Cell Index List   cell_type=lte    enb_index=${fdd_enb_index}
    Set Test Variable    ${LTE_CELL_LIST}    ${cell_list}
    run keyword and ignore error    COAM Teardown gnb connections
    robot_common_operations.Common Case Setup

Multi-UE_Case_Setup
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${1}    ${connection}=GNB_OAM0    ${gnb_id}=${0}    ${timeout}=${600}    ${specified_scell_index}=${None}
    ...            ${first_beam_begin_output_port}=${13}
    ...            ${first_beam_end_output_port}=${14}
    ...            ${second_beam_begin_output_port}=${15}
    ...            ${second_beam_end_output_port}=${16}
    ...            ${first_beam_horizontal_angle}=${7}
    ...            ${second_beam_horizontal_angle}=${22}
    ...            ${vertical_angle}=${-6}
    Run Keyword If    '${tl_prefix}'=='T073' and ${ue_index}==${1}    Turn off TL283 AEHC0 PA ports
    ${case_params_1}    Set Variable    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']['UEs_info'][${ue_index}]}
    ${cell_index}    Set Variable    PCELL_INDEX_${ue_index}
    ${lte_cell_index}    Set Variable    LTE_CELL_INDEX_${ue_index}
    Set Test Variable    ${${cell_index}}    ${case_params_1.get('pcell_idx')}
    Set Test Variable    ${${lte_cell_index}}    ${case_params_1.get('lte_cell_idx')}
    Set Test Variable    ${attenuator_list_1}        ${case_params_1.get('attenuator')}
    Set Test Variable    ${scell_technology_1}        ${case_params_1.get('ca_technology').split('+')[-1]}
    ${cell_list_info}    Get CA Related Infomation For Multi-UE    pcell_index=${${cell_index}}    scell_technology=${scell_technology_1}
    ...    specified_scell_index=${specified_scell_index}
    ${scell_index_list_name}    Set Variable    SCELL_INDEX_LIST_${ue_index}
    Set Test Variable    ${${scell_index_list_name}}    ${cell_list_info['scell_index_list']}
    ${all_scell_list_name}    Set Variable    ALL_SCELL_LIST_${ue_index}
    Set Test Variable    ${${all_scell_list_name}}    ${cell_list_info['all_scell_list']}
    ${pcell_ru_index_name}    Set Variable    pcell_ru_index_${ue_index}
    Set Test Variable    ${${pcell_ru_index_name}}    ${cell_list_info['pcell_ru_index']}
    ${scell_ru_index_list_name}    Set Variable    scell_ru_index_list_${ue_index}
    Set Test Variable    ${${scell_ru_index_list_name}}    ${cell_list_info['scell_ru_index_list']}
    ${pcell_mapping_name}    Set Variable    PCELL_MAPPING_${ue_index}
    Set Test Variable    ${${pcell_mapping_name}}    ${cell_list_info['pcell_mapping']}
    ${scell_mapping_name}    Set Variable    SCELL_MAPPING_${ue_index}
    Set Test Variable    ${${scell_mapping_name}}    ${cell_list_info['scell_mapping']}
    Modify WeightForSCellSelection Parameter Value On Gnb    scell_list_used_in_fact=${${scell_index_list_name}}
    ...                                                      scell_list_supported=${${all_scell_list_name}}
    ...                                                      connection=${connection}
    ...                                                      gnb_id=${gnb_id}
    ...                                                      timeout=${timeout}
    FOR    ${attenuator}    IN    @{attenuator_list_1}
        Run Keyword If    '${attenuator}'=='pa'
        ...    Run Keywords    Modify PA Value Setting For Required RU    modify_ru_id=${${pcell_ru_index_name}}    ue_index=${ue_index}
        ...             AND    Modify PA Value Setting For Required RU    modify_ru_id=${${scell_ru_index_list_name}}    ue_index=${ue_index}
        ...    ELSE IF    '${attenuator}'=='mcs'    Set Case Related MCS Port Value    ue_index=${ue_index}    whether_do_mcs_setup=${False}
        ...    first_beam_begin_output_port=${first_beam_begin_output_port}
        ...    first_beam_end_output_port=${first_beam_end_output_port}
        ...    second_beam_begin_output_port=${second_beam_begin_output_port}
        ...    second_beam_end_output_port=${second_beam_end_output_port}
        ...    first_beam_horizontal_angle=${first_beam_horizontal_angle}
        ...    second_beam_horizontal_angle=${second_beam_horizontal_angle}
        ...    ELSE    Log To Console     ${\n}INFO: --Use the wrong attenuator type(${attenuator}), need to check TMO_Data.py--
    END

TMO_Sleeping_Cell_Suite_Setup
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${is_commission}=${False}    ${whether_do_prepare_ue}=${True}
    ...            ${ue_index}=${0}    ${ute_space}=20
#    ${stream_version}    gnb_classical_hangzhou.Get program version based on stream version
    ${stream_version}    Common_setup_and_teardown.Get Active SW Version Based On Stream Version
    Set Suite Variable    ${stream_version}
    Set Suite Variable    ${tl_prefix}    ${testline_name.split('_')[-1][-4:]}
#    ${SCOUT_TL_NAME}=  Set Variable If    '${tl_prefix}'=='T813'    ${testline_name}_5G    ${testline_name}
#    Set Suite Variable    ${SCOUT_TL_NAME}
    ${ue_index}    Set Variable If    '${tl_prefix}'=='T080'    ${0}
    ...                               '${tl_prefix}'=='T816'   ${2}    ${0}
    Set Suite Variable    ${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Suite Variable    ${ue_type}
#     get tl_prefix, such as T813/T073
#    Run Keyword If    '${tl_prefix}'=='T080'     Clear Temp File Of ELT For MTK
#     get how many ENBs
    ${enb_length}    Get Length    ${tl.enbs}
    Set Suite Variable    ${enb_length}
    ${dict_enb_Technology_index}    Get LTE Technology Value
    Set Suite Variable    ${DICT_ENB_TECHNOLOGY_INDEX}    ${dict_enb_Technology_index}
    Suite Log Path Create
    Backup And Delete Parameter Of Swconfig File    swconfig_modify=@{delete_flag}
    Perform gNB Reset site and Wait Onair
    Common_setup_and_teardown.Common Suite Setup    scf_name=${tl_prefix}_gNB_${stream_version}.xml    is_commission=${is_commission}
    ...    timeout_for_commission=20 min
#    Verify TMO Gnb Ready And All Cell On Air
    Verify All Enbs Cell On Air
    Trun Off All PA Ports
    Check And Clear TestPC Space    ute_space=${ute_space}
    Kill Adb App    ue_index=${ue_index}
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    Run Keyword If    ${whether_do_prepare_ue}    Procedures.Start UE Prepare    ue_index=${ue_index}    ue_type=${ue_type}
    &{fault_4203}     Create Dictionary     faultId=${4203}
    &{fault_4459}     Create Dictionary     faultId=${4459}
    &{fault_1932}     Create Dictionary     faultId=${1932}
    &{fault_1934}     Create Dictionary     faultId=${1934}
    &{fault_61631}     Create Dictionary     faultId=${61631}
    &{fault_1838}     Create Dictionary     faultId=${1838}
    &{fault_4741}     Create Dictionary     faultId=${4741}
    &{fault_4293}     Create Dictionary     faultId=${4293}
    &{fault_1898}     Create Dictionary     faultId=${1898}
    &{fault_4297}     Create Dictionary     faultId=${4297}
    &{fault_7319}     Create Dictionary     faultId=${7319}
    ${GNB_ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_4203}    ${fault_4459}   ${fault_1932}   ${fault_1934}
    ...                    ${fault_1838}     ${fault_4741}    ${fault_4293}    ${fault_4297}    ${fault_7319}
    Run Keyword If    '${tl_prefix}'=='T813' or '${tl_prefix}'=='T284'         append to list    ${GNB_ALLOWED_FAULT}    ${fault_1898}
    Set Suite Variable    ${GNB_ALLOWED_FAULT}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_61631}   ${fault_1838}   ${fault_4741}    ${fault_4459}
    Set Suite Variable    ${ALLOWED_HISTORY_FAULT}
    robot_common_operations.Common Suite Setup

TMO_Common_Case_Setup_Kpi
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${whether_get_ca_info}=${True}    ${whether_set_pa_value}=${True}
    Common_setup_and_teardown.Common Case Setup
    Set Test Variable    ${test_case_id}    ${TEST NAME.split('_')[0]}
    ${case_params}    Set Variable    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']}
    Set Test Variable    ${PCELL_INDEX}    ${case_params.get('pcell_idx')}
    Set Test Variable    ${attenuator_list}    ${case_params.get('attenuator')}
    Set Test Variable    ${ca_technology}    ${case_params.get('ca_technology')}
    ${ca_technology_status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${case_params}    ca_technology
    Run Keyword If    ${ca_technology_status}    Set Test Variable    ${scell_technology}
    ...                                                               ${case_params.get('ca_technology').split('+')[-1]}
    Set Test Variable    ${LTE_CELL_INDEX}    ${case_params.get('lte_cell_idx')}
#    Set Test Variable    ${NSA_PA_RU_INDEX}    ${case_params.get('nsa_pa_ru_idx')}
    Set Test Variable    ${HO_PCELL_INDEX}    ${case_params.get('after_ho_pcell_idx')}
    ${ho_ca_technology_status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${case_params}    ho_ca_technology
    Run Keyword If    ${ho_ca_technology_status}    Set Test Variable    ${HO_SCELL_TECHNOLOGY}
    ...                                                                  ${case_params.get('ho_ca_technology').split('+')[-1]}
#    Run Keyword If    '${tl_prefix}'=='T080'    Update_TMO_3CC_Configration    3CC_support=${True}
#    Run Keyword If    '${tl_prefix}'=='T073'    Update_TMO_3CC_Configration    3CC_support=${False}
#    Run Keyword If    '${tl_prefix}'=='T284'    Update_TMO_3CC_Configration    3CC_support=${False}
#    Run Keyword If    '${tl_prefix}'=='T283'    Update_TMO_3CC_Configration    3CC_support=${False}
#    Run Keyword If    ${whether_set_pa_value}    Set Case PA Or MCS Port Value    attenuator_list=${attenuator_list}    ue_index=${ue_index}
#    Verify TMO Gnb Ready And All Cell On Air
#    Verify All Enbs Cell On Air
    ${lte_whether_in_gnb}    Check LTE Whether In Gnb
    Set Test Variable    ${LTE_WHETHER_IN_GNB}    ${lte_whether_in_gnb}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    robot_common_operations.Common Case Setup

Update_TMO_3CC_Configration
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${whether_get_ca_info}=${True}    ${3CC_support}=${False}
    Run Keyword If    ${whether_get_ca_info} and ${3CC_support}==${False}    Get CA Related Infomation    pcell_index=${PCELL_INDEX}
    ...    ELSE IF    ${whether_get_ca_info} and ${3CC_support}    Get 3CC Related Infomation    pcell_index=${PCELL_INDEX}
    Run Keyword If    ${3CC_support}    Run Keyword And Continue On Failure    Update The Flag Whether Support 3CC    3CC_flag=${True}

TMO_Common_Case_Teardown_kpi
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${power_reset}=False    ${apn_address}=${tl.core.pdns[0].apn}
    Run Keyword If    '${ue_type}'=='huawei_sigspark'    Run Keyword And Ignore Error
    ...    Spark_common_keywords.Spark Stop UE Log    ue_index=${ue_index}
    Procedures.Stop TMO L3 Call And Detach    ue_index=${ue_index}    ue_type=${ue_type}
    ...                                       apn_address=${apn_address}    power_reset=${power_reset}
    Run Keyword And Ignore Error    Stop Aasyslog And Download To TestPC    log_prefix=aasyslog
    Run Keyword And Ignore Error    Common Case Teardown    is_save_snapshot=False
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error     Recover Collect Syslog On Control PC

#--- Common keywords for tools---#
Clearup UTE Space while keep syslog
    [Documentation]  Author: lei.jia@nokia-sbell.com
    [Arguments]    ${alias}=test_pc
    ...            ${test_pc_ip}=${tl.test_pc.default_ssh_connection_details.addr}
    ...            ${test_pc_name}=${tl.test_pc.default_ssh_connection_details.username}
    ...            ${test_pc_password}=${tl.test_pc.default_ssh_connection_details.password}
    #--- clear gnb release software under /home/ute ---#
    Log To Console    ${\n}INFO:-- start to check and clear testPC space --
    csn.Connect to     hostname=${test_pc_ip}    username=${test_pc_name}    password=${test_pc_password}    alias=${alias}
    ${sw_build_output}    csn.execute
    ...    command=find /home/ute -name \"*release_BTSSM_downloadable_A54.zip\"
    ...    connection=${alias}
    ${sw_build_output}    Set Variable    ${sw_build_output.split('\r\n')}
    Remove From List    ${sw_build_output}    -1
    FOR    ${i}    IN    @{sw_build_output}
        csn.send command    command=rm -rf ${i}    connection=${alias}
    END
    #--- clear logs under /opt/transformers.dynamic.nsn-net.net/workspace, for 24 hours ago ---#
    csn.execute
    ...    command=cd /opt/transformers.dynamic.nsn-net.net/workspace
    ...    connection=${alias}
    ${workspace_dir}    csn.execute
    ...    command=find /opt/transformers.dynamic.nsn-net.net/workspace/ -name *5G_PZ_HZ_6_SG*
    ...    connection=${alias}
    ${workspace_dirs}   Split String    ${workspace_dir}   \r\n
    Remove From List    ${workspace_dirs}    -1
    @{WebTrigger_folders}    create list
    FOR    ${folder}    IN    @{workspace_dirs}
        ${parent_folder}    csn.execute    command=cd ${folder}/..;pwd     connection=${alias}
        ${parent_folder}     Split String    ${parent_folder}   \r\n
        append to list     ${WebTrigger_folders}    ${parent_folder[0]}
    END
    ${WebTrigger_folders}    Remove Duplicates   ${WebTrigger_folders}
    FOR    ${WebTrigger_folder}    IN    @{WebTrigger_folders}
         Compare Jenkins log modified time with current time    WebTrigger_folder=${WebTrigger_folder}
    END
    #--- clear "SYSLOG.tgz" under /home/ute ---#
    ${syslog_error_output}    csn.execute
    ...    command=find /home/ute -name "SYSLOG.tgz"
    ...    connection=${alias}
    ${syslog_error_output}    Set Variable    ${syslog_error_output.split('\r\n')}
    Remove From List    ${syslog_error_output}    -1
    FOR    ${folder}    IN    @{syslog_error_output}
         csn.send command    command=rm -rf ${folder}    connection=${alias}
    END
    #--- clear logs under /home/ute/Downloads ---#
    ${check_downloads_exist}    csn.execute
    ...    command=ls /home/ute/Downloads
    ...    connection=${alias}
    ${downloads_exist}    Run Keyword And Return Status    Should Not Contain    ${check_downloads_exist}    No such file or directory
    Run Keyword If    ${downloads_exist}    csn.execute
    ...    command=cd /home/ute/Downloads; rm -rf *
    ...    connection=${alias}

Compare Jenkins log modified time with current time
    [Documentation]    author: lei.jia@nokia-sbell.com
    [Arguments]    ${WebTrigger_folder}    ${alias}=test_pc
    # get current time, clear log before 24 hours
    ${currenttime}    DateTime.Get Current Date    result_format=%Y-%m-%d%H:%M:%S
    ${start_time} = 	DateTime.Get Current Date 	local 	- 24 hours     result_format=timestamp
    ${start_time} = 	DateTime.Convert Date 	${start_time}    epoch

    ${folder_under_WebTrigger} = 	OperatingSystem.List Directories In Directory    ${WebTrigger_folder}
    FOR    ${log_folder}    IN    @{folder_under_WebTrigger}
        ${log_modtime} = 	OperatingSystem.Get Modified Time 	${WebTrigger_folder}/${log_folder}    epoch
        Run Keyword If    ${log_modtime} < ${start_time}    csn.send command
        ...    command=rm -rf ${WebTrigger_folder}/${log_folder}    connection=${alias}
    END


Get Syslog Start Time
    ${currenttime}    robot.libraries.DateTime.Get current date    result_format=%Y-%m-%d%H:%M:%S
    ${syslog_start_time} = 	robot.libraries.DateTime.Get Current Date 	local    result_format=timestamp
    ${syslog_start_time} = 	robot.libraries.DateTime.Convert Date 	${syslog_start_time}    epoch
    Set Test Variable    ${SYSLOG_START_TIME}    ${syslog_start_time}

Select ENB Index based on LTE Technology
    [Documentation]    Author: lie.jia@nokia-sbell.com
    ...     dict1 {'TDD':${0}, 'FDD':${1}}, if 'TDD' is used, return ${0}. if 'FDD' is used, return ${1}
    ...     dict2 {'FDD':${1}}, if 'TDD' is used, return ${False}. if 'FDD' is used, return ${1}
    [Arguments]    ${used_enb_technology}=FDD
    ${selected_enb_index}    Set Variable   ${DICT_ENB_TECHNOLOGY_INDEX.get('${used_enb_technology}', ${False})}
    ${enb_index}    Set Variable If
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${selected_enb_index}'!='${False}'    ${selected_enb_index}     ${0}
    [Return]    ${enb_index}

Get LTE Technology Value
    [Documentation]    Author: lie.jia@nokia-sbell.com
    ...                get lte technology value, for example: TDD/FDD/mixed_FDD_TDD
    ...                Return enb Technology and enb index dict {'TDD':${0}, 'FDD':${1}}
    [Arguments]    ${timeout}=300    ${gnb_connection}=GNB_OAM    ${gnb_index}=0    ${cell_type}=lte
    &{enb_Technology_index_dict} = 	Create Dictionary
    ${lte_whether_in_gnb}    Check LTE Whether In Gnb    gnb_id=${gnb_index}    gnb_connection=${gnb_connection}
    Return From Keyword If    ${lte_whether_in_gnb}==${True}    ${enb_Technology_index_dict}
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}
        ...                            connection=enblte_${enb_index}
        ${mrbts_id}    ${lnbts_id}    Get MRbtsID and LNbtsID Value Of Lte Cells
        ...                           enb_index=${enb_index}    timeout=${timeout}    cell_type=${cell_type}
        ${supportedCellTechnology}    coam_parameter.get_single_value_from_scf_file    parameter=supportedCellTechnology
        ...                                                                   dist_name=MRBTS-${mrbts_id}/LNBTS-${lnbts_id}
        ...                                                                   connection=enblte_${enb_index}
        ...                                                                   timeout=${timeout}
        Set To Dictionary 	${enb_Technology_index_dict} 	${supportedCellTechnology}=${enb_index}
    END
    [Return]    ${enb_Technology_index_dict}
    [Teardown]    Teardown GNB and ENB Connections

Teardown GNB and ENB Connections
    [Documentation]    Author: lie.jia@nokia-sbell.com
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM
    ${enb_length}    Get Length    ${tl.enbs}
    FOR    ${enb_index}    IN RANGE    ${enb_length}
         Run Keyword And Ignore Error    Enblte close down    connection=enblte_${enb_index}
    END

Get MRbtsID and LNbtsID Value Of Lte Cells
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}    ${cell_type}=lte    ${timeout}=300
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${enb_connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    @{all_cell_ids}    Create List
    FOR    ${cell}    IN    @{cell_list}
        ${cell_idx}    Set Variable    ${cell.split('-')[-1]}
        Append To List    ${all_cell_ids}    ${cell_idx}
    END
    ${mrbts_id}    Set Variable    ${cell_list[0].split('/')[0].split('-')[-1]}
    ${lnbts_id}    Set Variable    ${cell_list[0].split('/')[1].split('-')[-1]}
    [Return]    ${mrbts_id}    ${lnbts_id}

Trun Off All PA Ports
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${value}=${127}
    @{attenuator_num}    Set Variable    ${tl.attenuators}
    ${attenuator_length}    Get Length    ${attenuator_num}
    FOR    ${attenuator_id}    IN RANGE    ${attenuator_length}
        ${vendor}    set variable    ${tl.attenuators[${attenuator_id}].vendor}
        Run Keyword If    '${vendor}'=='RADIORACK'    Disable All PA Port For RadioRack    attenuator_index=${attenuator_id}
        ...    ELSE    Initial PA Value Setting For Whole PA    attenuator_index=${attenuator_id}    value=${value}
    END

Disable All PA Port For RadioRack
    [Documentation]   stella.lin@nokia-sbell.com
    [Arguments]    ${attenuator_index}=${0}
    @{channels}    Set Variable    ${tl.attenuators[${attenuator_index}].attenuator_ports}
    ${ip_addr}    set variable     ${tl.attenuators[${attenuator_index}].ip_addr}
    ${port}    set variable     ${tl.attenuators[${attenuator_index}].port}
    ${vendor}    set variable    ${tl.attenuators[${attenuator_index}].vendor}
    ${model}    set variable     ${tl.attenuators[${attenuator_index}].model}
    ${configured_attenuator}    attenuator.setup_attenuator
    ...    ip_addr=${ip_addr}
    ...    port=${port}
    ...    attenuation_port_numbers=${channels}
    ...    vendor=${vendor}
    ...    model=${model}
    FOR    ${index}    IN RANGE    1    17
        ${index}    Convert To Integer    ${index}
        ${value}    Evaluate    float(110)
        Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    5X    5sec   attenuator.set_attenuation
        ...    port=${index}   value=${value}   attenuator_device=${configured_attenuator}    confirm=True
        sleep   5sec
    END

Turn off TL283 AEHC0 PA ports
    [Documentation]   lei.jia@nokia-sbell.com
    ...               ue1 is shared between TL073 and TL283, thus it should be turn off while TL073 running
    ...               10.68.88.179 is used by TTL283 UE1
    [Arguments]    ${value}=${63}
    @{attenuation_port_numbers}    create list    1    2    3   4
    @{values}    Create List    ${value}    ${value}    ${value}    ${value}
    ${configured_attenuator}    attenuator.setup_attenuator
    ...    ip_addr=${tl.attenuator[2].ip_addr}
    ...    port=${tl.attenuator[2].port}
    ...    attenuation_port_numbers=${attenuation_port_numbers}
    ...    vendor=${tl.attenuators[2].vendor}
    attenuator.set_ports_attenuation
    ...    ports=${attenuation_port_numbers}   values=${values}   confirm=True
    ...    attenuator_device=${configured_attenuator}
    @{new_values}    attenuator.read_ports_attenuation     ports=${attenuation_port_numbers}
    Lists Should Be Equal    ${new_values}    ${values}    msg=Attenuation set failed.
    Log To Console    \n change attenuation to ${value}

Modify Attenuation Vaule
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${modify_ru_id}=0    ${ue_index}=${0}    ${pa_off_value}=${None}
    ${attenuator_id}    Get Dictionary Keys    ${${tl_prefix}_PA_VALUE_MAPPING[${ue_index}]['${modify_ru_id}']}
    ${channels_dic}    Set Variable    ${${tl_prefix}_PA_VALUE_MAPPING[${ue_index}]['${modify_ru_id}'][${attenuator_id[0]}]}
    attenuator.setup_attenuator    attenuator=${tl.attenuators[${attenuator_id[0]}]}
    @{channels}    Get Dictionary Keys    ${channels_dic}
    @{ports}    Create List
    @{values}    Create List
    FOR    ${channel}    IN    @{channels}
        ${base_up_value}    Set Variable
        ...    ${${tl_prefix}_PA_VALUE_MAPPING[${ue_index}]['${modify_ru_id}'][${attenuator_id[0]}]['${channel}']}
        ${base_down_value}    Set Variable    ${pa_off_value}
        ${base_value}    Set Variable If    ${pa_off_value}==${None}    ${base_up_value}    ${base_down_value}
        ${channel}    Convert To Integer    ${channel}
        ${value}    Evaluate    float(${base_value})
        Append To List    ${ports}    ${channel}
        Append To List    ${values}    ${value}
    END
    Wait Until Keyword Succeeds   5min   5sec   attenuator.set_ports_attenuation   ports=${ports}   values=${values}   confirm=True
    @{new_values}    attenuator.read_ports_attenuation     ports=${ports}
    Lists Should Be Equal    ${new_values}    ${values}    msg=Attenuation set failed.
    Log To Console    \n change attenuation to ${value}

Modify PA Value Setting For Required RU
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${modify_ru_id}=0    ${ue_index}=${0}    ${pa_off_value}=${None}
    ${modify_ru_id_type}    Evaluate    type(${modify_ru_id}).__name__
    ${convert_modify_ru_id_to_list}    Create List    ${modify_ru_id}
    ${modify_ru_id_list}    Set Variable If    'list' in '${modify_ru_id_type}'    ${modify_ru_id}    ${convert_modify_ru_id_to_list}
    FOR    ${ru_index}    IN    @{modify_ru_id_list}
        ${ru_index_list}    Get Dictionary Keys    ${${tl_prefix}_PA_VALUE_MAPPING[${ue_index}]}
        ${status}    Run Keyword And Return Status    List Should Contain Value    ${ru_index_list}    ${ru_index}
        Run Keyword If    ${status}    Modify Attenuation Vaule    modify_ru_id=${ru_index}
        ...                                                        ue_index=${ue_index}
        ...                                                        pa_off_value=${pa_off_value}
    END

Set Case Related PA Port Value
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${pa_off_value}=${None}
    ${pcell_ru_index}    Set Variable    ${PCELL_MAPPING['ru_index_mapping']}
    ${scell_ru_index_list}    Create List
    FOR  ${scell_index}  IN    @{SCELL_INDEX_LIST}
        ${scell_ru_index}    Set Variable    ${SCELL_MAPPING[${scell_index}]['all_cell_info']['ru_index_mapping']}
        Append To List    ${scell_ru_index_list}    ${scell_ru_index}
    END
    Modify PA Value Setting For Required RU    modify_ru_id=${pcell_ru_index}    ue_index=${ue_index}    pa_off_value=${pa_off_value}
    Modify PA Value Setting For Required RU    modify_ru_id=${scell_ru_index_list}    ue_index=${ue_index}    pa_off_value=${pa_off_value}

Set Case Related MCS Port Value
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${att_value}=0
    ...            ${mcs_index}=${0}
    ...            ${mcs_alias}=MCS_${mcs_index}
    ...            ${ue_index}=${0}
    ...            ${server_ip}=${tl.mcses[${mcs_index}].ip_addr}
    ...            ${server_port}=${tl.mcses[${mcs_index}].port}
    ...            ${vendor}=${tl.mcses[${mcs_index}].vendor}
    ...            ${model}=${tl.mcses[${mcs_index}].model}
    ...            ${frequency}=2600_1_ALL
    ...            ${vertical_distance}=${2.1}
    ...            ${horizontal_distance}=${0.5}
    ...            ${whether_do_Angles}=${True}
    ...            ${whether_do_mcs_setup}=${True}
    ...            ${mcs_pc_index}=${5}
    ...            ${hostname}=${tl.ues[${mcs_pc_index}].ssh_connection_details.addr}
    ...            ${first_beam_begin_output_port}=${9}
    ...            ${first_beam_end_output_port}=${10}
    ...            ${second_beam_begin_output_port}=${11}
    ...            ${second_beam_end_output_port}=${12}
    ...            ${first_beam_horizontal_angle}=${-7}
    ...            ${second_beam_horizontal_angle}=${-22}
    ...            ${vertical_angle}=${-6}
    ...            ${begin_input_port}=${1}
    ...            ${end_input_port}=${32}
    Log To Console     ${\n}INFO: -- Start to set mcs value --
    Kill mcs process    ue_index=${mcs_pc_index}   hostname=${hostname}
    ${vendor}    Convert To Lower Case    ${vendor}
    ${mcs_type}    Run keyword If    '${vendor}' == 'topyoung' and 'MCS' in '${model}'   set variable    topyoung
    ...                   ELSE IF    '${vendor}' == 'topyoung' and 'Radio' in '${model}'    set variable    haojin
    ...                   ELSE       '${vendor}' == 'hbte'    set variable    hbte
    Set Suite Variable    ${mcs_type}
    Run Keyword If    ${whether_do_mcs_setup}    mcs_common.Setup MCS    mcs_type=${mcs_type}
    ...                     server_ip=${server_ip}
    ...                     server_port=${server_port}
    ...                     vendor=${vendor}
    ...                     model=${model}
    ...                     frequency=${frequency}
    Run Keyword If    ${whether_do_Angles}    mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_type=${mcs_type}
    ...               begin_output_port=${first_beam_begin_output_port}
    ...               end_output_port=${first_beam_end_output_port}
    ...               begin_input_port=${begin_input_port}
    ...               end_input_port=${end_input_port}
    ...               vertical_angle=${vertical_angle}
    ...               horizontal_angle=${first_beam_horizontal_angle}
    ...               vertical_distance=${vertical_distance}
    ...               horizontal_distance=${horizontal_distance}
    Run Keyword If    ${whether_do_Angles}    mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_type=${mcs_type}
    ...               begin_output_port=${second_beam_begin_output_port}
    ...               end_output_port=${second_beam_end_output_port}
    ...               begin_input_port=${begin_input_port}
    ...               end_input_port=${end_input_port}
    ...               vertical_angle=${vertical_angle}
    ...               horizontal_angle=${second_beam_horizontal_angle}
    ...               vertical_distance=${vertical_distance}
    ...               horizontal_distance=${horizontal_distance}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value}
    ...               begin_output_port=${first_beam_begin_output_port}
    ...               end_output_port=${second_beam_end_output_port}
    ...               begin_input_port=${1}    end_input_port=${64}


#--- Common keywords for gnb/enb ---#
Verify TMO Gnb Ready And All Cell On Air
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                Check ALL cells on air include: "lte", "wcdma", "gsm", "nr".
    [Arguments]    ${gnb_id}=0    ${connection}=GNB_OAM
    Wait Gnb Ready And Cell On Air    gnb_id=${gnb_id}    timeout=30 min    connection=${connection}
    Wait until keyword succeeds    2 min    20 sec    Verify Gnb Type Cells Should Be Onair    cell_type=lte    connection=${connection}
    Wait until keyword succeeds    2 min    20 sec    Verify Gnb Type Cells Should Be Onair    cell_type=wcdma    connection=${connection}
    Wait until keyword succeeds    12 min    20 sec    Verify Gnb Type Cells Should Be Onair    cell_type=gsm    connection=${connection}

Verify Gnb Type Cells Should Be Onair
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    ...                :param str cell_technology: "TDD", "FDD", "ALL". Default: "ALL".
    [Arguments]    ${cell_type}=lte    ${connection}=GNB_OAM    ${gnb_id}=${0}    ${timeout}=30    ${cell_technology}=ALL
    Log to console    ${\n}----Verify all ${cell_type} cells are on air----
    ${result}    Run Keyword And Return Status    Should Contain Any    ${stream_version}    12.400    14.400    22R1    22R2    21B
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_id}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        ${technology}    Set Variable    ${item.get('technology')}
        Run Keyword If    '${cell_technology}'!='ALL' and '${technology}'=='${cell_technology}'
        ...                   Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
        ...    ELSE IF    '${cell_technology}'=='ALL'    Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR  ${cell}  IN   @{cell_list}
        Run Keyword If    ${result}    Run Keyword And Continue On Failure
        ...    Should Be Equal As Strings    ${cell_list_info['${cell}']['availabilityStatus']}    Online
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['operationalState']}     ${enabled}
    END
    [Return]    ${cell_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Verify All Enbs Cell On Air
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    Log to console    ${\n}----Verify all cells of enbs are on air----
    ${enb_length}    Get Length    ${tl.enbs}
    FOR    ${enb_id}    IN RANGE    ${enb_length}
        Wait Until Keyword Succeeds    3 min    20 sec    Verify Enb All Cell On Air    enb_index=${enb_id}
    END

Verify Enb All Cell On Air
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${enb_index}=${0}    ${connection}=enblte_${enb_index}    ${timeout}=300
    Connect to eNB via ssl    enb_index=${enb_index}    connection=${connection}
	${output}    enblte.get_bts_info    connection=${connection}
    @{rat_type_list}    Create List
    ${ratState_list}    Get Dictionary Keys    ${output['ratState']}
    FOR    ${item}    IN    @{ratState_list}
        ${value}    Get From Dictionary    ${output['ratState']}    ${item}
        Run Keyword If    '${value}' != 'NO_CELLS'    Append To List    ${rat_type_list}    ${item}
    END
    FOR    ${rat_type}    IN    @{rat_type_list}
        Verify Enb Type Cells Should Be Onair    cell_type=${rat_type}    connection=${connection}    timeout=${timeout}
    END
	[Teardown]    Run Keyword And Ignore Error    Enblte close down    connection=${connection}

Verify Enb Type Cells Should Be Onair
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm".
    [Arguments]    ${cell_type}    ${connection}    ${timeout}=30
    ${result}    Run Keyword And Return Status    Should Contain Any    ${stream_version}    12.400    14.400    22R1    22R2    21B
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR    ${cell}    IN    @{cell_list}
        Run Keyword If    ${result}    Run Keyword And Continue On Failure
        ...    Should Be Equal As Strings    ${cell_list_info['${cell}']['availabilityStatus']}    Online
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['operationalState']}    ${enabled}
    END

Get Cell Index List
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${cell_type}=nr    ${timeout}=120    ${gnb_id}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${1}    ${enb_connection}=enblte_${enb_index}    ${technology}=TDD
    ${4g_whether_in_gnb}    Check LTE Whether In Gnb    gnb_id=${gnb_id}    gnb_connection=${gnb_connection}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_id}
    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${cell_type}'!='nr'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${4g_whether_in_gnb}    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${cell_type}'=='nr'    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${cell_type}'!='nr'    ${enb_connection}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    @{cell_list}    Create List
    FOR    ${item}    IN    @{cell_info}
        ${cell_id}    Set Variable    ${item['id']['configuration'].split('-')[-1]}
        ${technology_vlaue}    Set Variable    ${item['technology']}
        Run Keyword If    '${technology_vlaue}'=='${technology}' and '${cell_type}'!='nr'    Append To List    ${cell_list}    ${cell_id}
        ...    ELSE    Append To List    ${cell_list}    ${cell_id}
    END
    [Return]    ${cell_list}
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}   AND
    ...    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${cell_type}'!='nr'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Reset NR RAT
    [Arguments]    ${connection}=GNB_OAM
    ...            ${gnb_index}=${0}
    ...            ${url}=https://${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...            ${download_dir}=${TS_CASE_LOG_PATH}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}    username=${username}    password=${password}    download_dir=${download_dir}
    selenium_coam.disable_message_box
    selenium_coam.reset_nr
    Sleep    180s
    Verify TMO Gnb Ready And All Cell On Air
    [Teardown]    COAM selenium logout

Reset LTE RAT
    [Arguments]    ${connection}=GNB_OAM
    ...            ${gnb_index}=${0}
    ...            ${url}=https://${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}    username=${username}    password=${password}    download_dir=${download_dir}
    selenium_coam.disable_message_box
    selenium_coam.reset_lte
    Sleep    180s
    Verify TMO Gnb Ready And All Cell On Air
    [Teardown]    COAM selenium logout

Reset RAT
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param str rat_type: RAT name - 5G, LTE, WCDMA or GSM
    [Arguments]    ${rat_type}=5G    ${timeout}=300    ${gnb_id}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${1}    ${enb_connection}=enblte_${enb_index}
    ${4g_whether_in_gnb}    Check LTE Whether In Gnb    gnb_id=${gnb_id}    gnb_connection=${gnb_connection}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_id}
    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${rat_type}'!='5G'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${4g_whether_in_gnb}    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${rat_type}'=='5G'    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${rat_type}'!='5G'    ${enb_connection}
    coam.rat_reset    rat_type=${rat_type}    timeout=${timeout}    connection=${connection}
    Sleep    180s
    ${cell_type}    Set Variable If    '${rat_type}'=='5G'    nr    lte
    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${rat_type}'!='5G'
    ...            Verify Enb Type Cells Should Be Onair    cell_type=${cell_type}    connection=${connection}    timeout=${timeout}
    ...    ELSE    Wait Gnb Ready And Cell On Air    gnb_id=${gnb_id}    timeout=20 min    connection=${connection}
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}   AND
    ...    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${rat_type}'!='5G'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Block RAT
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param string rat_type: RAT to block. ["NR"|"LTE"|"WCDMA"|"GSM"]
    [Arguments]    ${rat_type}=NR    ${timeout}=300    ${gnb_id}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${1}    ${enb_connection}=enblte_${enb_index}
    ${4g_whether_in_gnb}    Check LTE Whether In Gnb    gnb_id=${gnb_id}    gnb_connection=${gnb_connection}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_id}
    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${rat_type}'!='NR'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${4g_whether_in_gnb}    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${rat_type}'=='NR'    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${rat_type}'!='NR'    ${enb_connection}
    coam.block_rat    rat=${rat_type}    timeout=${timeout}    connection=${connection}
    Sleep    60s
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}   AND
    ...    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${rat_type}'!='NR'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Unblock RAT
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param string rat_type: RAT to unblock. ["NR"|"LTE"|"WCDMA"|"GSM"]
    [Arguments]    ${rat_type}=NR    ${timeout}=300    ${gnb_id}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${1}    ${enb_connection}=enblte_${enb_index}
    ${4g_whether_in_gnb}    Check LTE Whether In Gnb    gnb_id=${gnb_id}    gnb_connection=${gnb_connection}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_id}
    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${rat_type}'!='NR'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${4g_whether_in_gnb}    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${rat_type}'=='NR'    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${rat_type}'!='NR'    ${enb_connection}
    coam.unblock_rat    rat=${rat_type}    timeout=${timeout}    connection=${connection}
    Sleep    60s
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}   AND
    ...    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${rat_type}'!='NR'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Verify RAT Should Be Blocked
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param string rat_type: RAT to block. ["NR"|"LTE"|"WCDMA"|"GSM"]
    [Arguments]    ${rat_type}=NR    ${timeout}=300    ${gnb_connection}=GNB_OAM    ${gnb_id}=0
    ...            ${enb_index}=${1}    ${enb_connection}=enblte_${enb_index}
    Log to console    ${\n}----Verify ${rat_type} RAT are blocked----
    ${cell_type}   Convert To Lower Case   ${rat_type}
    ${4g_whether_in_gnb}    Check LTE Whether In Gnb    gnb_id=${gnb_id}    gnb_connection=${gnb_connection}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_id}
    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${cell_type}'!='nr'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${4g_whether_in_gnb}    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${cell_type}'=='nr'    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${cell_type}'!='nr'    ${enb_connection}
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    Run Keyword And Return Status    Should Contain Any    ${sw_version}    12.400    14.400    22R1    22R2    21B
    ${disabled}    Set Variable If    ${result}    Disabled    disabled
    ${offline}    Set Variable If    ${result}    Offline    off line
    ${blockingState}     Set Variable If    ${result}    Blocked    Blocked
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR  ${cell}  IN   @{cell_list}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['availabilityStatus']}    ${offline}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['operationalState']}    ${disabled}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['blockingState']}    ${blockingState}
    END
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}   AND
    ...    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${cell_type}'!='nr'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Get Pcell And Scell Mapping Info
    [Documentation]   Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${pcell_index}    ${source_gnb_id}=0
    Get Pcell Mapping Info    pcell_index=${pcell_index}    source_gnb_id=${source_gnb_id}
    Connect To Multi gNb Coam
    ${scell_mapping}    mbca.get_scell_mapping_for_pcell_for_tmo
    ${tdd_scell_mapping}    mbca.get_tdd_scell_mapping    all_scell_info=${scell_mapping}
    ${fdd_scell_mapping}    mbca.get_fdd_scell_mapping    all_scell_info=${scell_mapping}
    Set Test Variable    ${SCELL_MAPPING}    ${scell_mapping}
    Set Test Variable    ${TDD_SCELL_MAPPING}    ${tdd_scell_mapping}
    Set Test Variable    ${FDD_SCELL_MAPPING}    ${fdd_scell_mapping}
    [Teardown]    Teardown Multi gNb Connections

Get Pcell Mapping Info
    [Documentation]   Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${pcell_index}    ${source_gnb_id}=0
    Connect To Multi gNb Coam
    mbca.set_pcell_index    value=${pcell_index}
    mbca.set_gnb_id    value=${source_gnb_id}
    mbca.set_gnb_operation_object
    ${pcell_mapping}    mbca.get_pcell_mapping_for_tmo
    Set Test Variable    ${PCELL_MAPPING}     ${pcell_mapping}
    [Return]    ${pcell_mapping}
    [Teardown]    Teardown Multi gNb Connections

Get Swap Scell Configured Status
    [Documentation]   Author: stella.lin@nokia-sbell.com
    [Arguments]    ${pcell_index}    ${swap_scell_index}    ${source_gnb_id}=0
    Connect To Multi gNb Coam
    mbca.set_pcell_index    value=${pcell_index}
    mbca.set_gnb_id    value=${source_gnb_id}
    mbca.set_gnb_operation_object
    ${swap_scell_configured_status}    mbca.get_swap_scell_config_status    swap_cell_index=${swap_scell_index}
    [Return]    ${swap_scell_configured_status}
    [Teardown]    Teardown Multi gNb Connections

Get CA Related Infomation For Multi-UE
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${pcell_index}=${PCELL_INDEX}
    ...            ${connection}=GNB_OAM0
    ...            ${gnb_id}=${0}
    ...            ${timeout}=${600}
    ...            ${scell_technology}=${scell_technology}
    ...            ${specified_scell_index}=${None}
    Connect To Multi gNb Coam
    mbca.set_pcell_index    value=${pcell_index}
    mbca.set_gnb_id    value=${gnb_id}
    mbca.set_gnb_operation_object
    ${pcell_mapping_1}    mbca.get_pcell_mapping_for_tmo
    ${scell_mapping_1}    mbca.get_scell_mapping_for_pcell_for_tmo
    ${tdd_scell_mapping_1}    mbca.get_tdd_scell_mapping    all_scell_info=${scell_mapping_1}
    ${fdd_scell_mapping_1}    mbca.get_fdd_scell_mapping    all_scell_info=${scell_mapping_1}
    ${all_scell_list}    Get Dictionary Keys   ${scell_mapping_1}
    ${tdd_scell_list}    Get Dictionary Keys   ${tdd_scell_mapping_1}
    ${fdd_scell_list}    Get Dictionary Keys   ${fdd_scell_mapping_1}
    ${scell_list}    Set Variable If    '${scell_technology}'=='TDD'    ${tdd_scell_list}    ${fdd_scell_list}
    ${chbw_param_name}    Set Variable If    '${scell_technology}'=='TDD'    chBw    chBwDl
    ${scell_chbw_value}    Set Variable    ${0}
    ${scell_index}    Set Variable    ${0}
    FOR    ${scell}    IN    @{scell_list}
        ${scell_chbw}    Set Variable    ${scell_mapping_1[${scell}]['all_cell_info']['detail_cells_info']['${chbw_param_name}']}
        ${scell_chbw}    Set Variable    ${scell_chbw.split('M')[0]}
        ${scell_chbw}    Evaluate    int(${scell_chbw})
        ${scell_index}    Set Variable If     ${scell_chbw}>=${scell_chbw_value}    ${scell}    ${scell_index}
        ${scell_chbw_value}    Set Variable If     ${scell_chbw}>=${scell_chbw_value}    ${scell_chbw}    ${scell_chbw_value}
    END
    ${scell_index}    set variable if    ${specified_scell_index}!=${None}    ${specified_scell_index}    ${scell_index}
    @{scell_index_list}    Create List    ${scell_index}
    &{cell_list_info}    Create Dictionary
    Set To Dictionary      ${cell_list_info}     scell_index_list    ${scell_index_list}
    Set To Dictionary      ${cell_list_info}     all_scell_list    ${all_scell_list}
    ${pcell_ru_index}    Set Variable    ${pcell_mapping_1['ru_index_mapping']}
    ${scell_ru_index_list}    Create List
    FOR  ${scell_index}  IN    @{scell_index_list}
        ${scell_ru_index}    Set Variable    ${scell_mapping_1[${scell_index}]['all_cell_info']['ru_index_mapping']}
        Append To List    ${scell_ru_index_list}    ${scell_ru_index}
    END
    Set To Dictionary      ${cell_list_info}     pcell_ru_index    ${pcell_ru_index}
    Set To Dictionary      ${cell_list_info}     scell_ru_index_list    ${scell_ru_index_list}
    Set To Dictionary      ${cell_list_info}     pcell_mapping    ${pcell_mapping_1}
    Set To Dictionary      ${cell_list_info}     scell_mapping    ${scell_mapping_1}
    [Return]    ${cell_list_info}
    [Teardown]    Teardown Multi gNb Connections

Get CA Related Infomation
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${pcell_index}=${PCELL_INDEX}
    ...            ${connection}=GNB_OAM0
    ...            ${gnb_id}=${0}
    ...            ${timeout}=${600}
    Get Pcell And Scell Mapping Info    pcell_index=${pcell_index}    source_gnb_id=${gnb_id}
    ${all_scell_list}    Get Dictionary Keys   ${SCELL_MAPPING}
    ${tdd_scell_list}    Get Dictionary Keys   ${TDD_SCELL_MAPPING}
    ${fdd_scell_list}    Get Dictionary Keys   ${FDD_SCELL_MAPPING}
    ${scell_list}    Set Variable If    '${scell_technology}'=='TDD'    ${tdd_scell_list}    ${fdd_scell_list}
    ${chbw_param_name}    Set Variable If    '${scell_technology}'=='TDD'    chBw    chBwDl
    ${scell_chbw_value}    Set Variable    ${0}
    ${scell_index}    Set Variable    ${0}
    FOR    ${scell}    IN    @{scell_list}
        ${scell_chbw}    Set Variable    ${scell_mapping[${scell}]['all_cell_info']['detail_cells_info']['${chbw_param_name}']}
        ${scell_chbw}    Set Variable    ${scell_chbw.split('M')[0]}
        ${scell_chbw}    Evaluate    int(${scell_chbw})
        ${scell_index}    Set Variable If     ${scell_chbw}>=${scell_chbw_value}    ${scell}    ${scell_index}
        ${scell_chbw_value}    Set Variable If     ${scell_chbw}>=${scell_chbw_value}    ${scell_chbw}    ${scell_chbw_value}
    END
    @{scell_index_list}    Create List    ${scell_index}
    ${specified_scell_exist}    Run Keyword And Return Status
    ...    Set Variable    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']['scell_idx_list']}
    ${scell_index_list}    Set Variable If    ${specified_scell_exist}
    ...                    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']['scell_idx_list']}
    ...                    ${scell_index_list}
    Modify WeightForSCellSelection Parameter Value On Gnb    scell_list_used_in_fact=${scell_index_list}
    ...                                                      scell_list_supported=${all_scell_list}
    ...                                                      connection=${connection}
    ...                                                      gnb_id=${gnb_id}
    ...                                                      timeout=${timeout}
    @{scell_pci_list}    Create List
    FOR    ${item}    IN    @{scell_index_list}
        ${scell_pci}    Set Variable    ${SCELL_MAPPING[${item}]['all_cell_info']['physicalCellId']}
        ${scell_pci}    Convert To String    ${scell_pci}
        Append to List    ${scell_pci_list}    ${scell_pci}
    END
    Set Test Variable    ${SCELL_INDEX_LIST}    ${scell_index_list}
    Set Test Variable    ${SCELL_PCI_LIST}    ${scell_pci_list}

Get DL and UL tput for pcell and scell lists
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${cell_list}=${None}
    ...            ${tput_columns}=${None}
    ...            ${tput_report_before_upgrade}=${None}
    ...            ${tput_report_after_upgrade}=${None}
    ...            ${tput_report_after_upgrade_load_scf}=${None}
    ...            ${scell_pcell_mapping_dict}=${None}
    ...            ${tput_before_upgrade}=${None}
    ...            ${tput_after_upgrade}=${None}
    ...            ${tput_after_upgrade_with_new_scf}=${None}
    Get tput for pcell and scell lists for only one direction
    ...            cell_list=${cell_list}
    ...            tput_columns=${tput_columns}
    ...            tput_report_before_upgrade=${tput_report_before_upgrade}
    ...            tput_report_after_upgrade=${tput_report_after_upgrade}
    ...            tput_report_after_upgrade_load_scf=${tput_report_after_upgrade_load_scf}
    ...            scell_pcell_mapping_dict=${scell_pcell_mapping_dict}
    ...            tput_before_upgrade=${tput_before_upgrade}
    ...            tput_after_upgrade=${tput_after_upgrade}
    ...            tput_after_upgrade_with_new_scf=${tput_after_upgrade_with_new_scf}
    ...            direction=DL
    Get tput for pcell and scell lists for only one direction
    ...            cell_list=${cell_list}
    ...            tput_columns=${tput_columns}
    ...            tput_report_before_upgrade=${tput_report_before_upgrade}
    ...            tput_report_after_upgrade=${tput_report_after_upgrade}
    ...            tput_report_after_upgrade_load_scf=${tput_report_after_upgrade_load_scf}
    ...            scell_pcell_mapping_dict=${scell_pcell_mapping_dict}
    ...            tput_before_upgrade=${tput_before_upgrade}
    ...            tput_after_upgrade=${tput_after_upgrade}
    ...            tput_after_upgrade_with_new_scf=${tput_after_upgrade_with_new_scf}
    ...            direction=UL


Get tput for pcell and scell lists for only one direction
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${cell_list}=${None}
    ...            ${tput_columns}=${None}
    ...            ${tput_report_before_upgrade}=${None}
    ...            ${tput_report_after_upgrade}=${None}
    ...            ${tput_report_after_upgrade_load_scf}=${None}
    ...            ${scell_pcell_mapping_dict}=${None}
    ...            ${tput_before_upgrade}=${None}
    ...            ${tput_after_upgrade}=${None}
    ...            ${tput_after_upgrade_with_new_scf}=${None}
    ...            ${direction}=DL
    FOR    ${cell_index}    IN    @{cell_list}
        Log To Console    ${\n}Get ${direction} tput from aasyslog for cell-${cell_index}
        ${TPUT_result_before_upgrade}    Run Keyword And Continue On Failure    Check Tput from aasyslog file
        ...    cellid=${cell_index}
        ...    tput_log=${tput_before_upgrade['${scell_pcell_mapping_dict['${cell_index}']}']}
        ...    direction=${direction}
        ${TPUT_result_after_upgrade}    Run Keyword And Continue On Failure    Check Tput from aasyslog file
        ...    cellid=${cell_index}
        ...    tput_log=${tput_after_upgrade['${scell_pcell_mapping_dict['${cell_index}']}']}
        ...    direction=${direction}
        ${TPUT_result_with_newscf}    Run Keyword And Continue On Failure    Check Tput from aasyslog file
        ...    cellid=${cell_index}
        ...    tput_log=${tput_after_upgrade_with_new_scf['${scell_pcell_mapping_dict['${cell_index}']}']}
        ...    direction=${direction}
        ${before_upgrade_tput_exp}    evaluate    ${TPUT_result_before_upgrade} * 0.9
        Run Keyword And Continue On Failure    Should Be True    ${TPUT_result_after_upgrade} >= ${before_upgrade_tput_exp}
        ${after_upgrade_tput_exp}    evaluate    ${TPUT_result_after_upgrade} * 0.9
        Run Keyword And Continue On Failure    Should Be True    ${TPUT_result_with_newscf} >= ${after_upgrade_tput_exp}
        # generate tput in excel
        Append To List 	 ${tput_columns} 	Cell${cell_index}_${direction}
        Append To List    ${tput_report_before_upgrade}    ${TPUT_result_before_upgrade}
        Append To List    ${tput_report_after_upgrade}    ${TPUT_result_after_upgrade}
        Append To List    ${tput_report_after_upgrade_load_scf}    ${TPUT_result_with_newscf}
    END

Get scell and pcell mapping dict
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${pcell_index}=${PCELL_INDEX}
    ...            ${gnb_id}=${0}
    ...            ${ue_index}=${0}
    ...            ${scell_pcell_mapping_dict}=${None}
    Get Pcell And Scell Mapping Info    pcell_index=${pcell_index}    source_gnb_id=${gnb_id}
    ${SCELL_INDEX_LIST}    Get Dictionary Keys    ${SCELL_MAPPING}
    ${pcell_ru_index}    Set Variable    ${PCELL_MAPPING['ru_index_mapping']}
    ${scell_ru_index_list}    Create List
    FOR  ${scell_index}  IN    @{SCELL_INDEX_LIST}
        ${scell_ru_index}    Set Variable    ${SCELL_MAPPING[${scell_index}]['all_cell_info']['ru_index_mapping']}
        Append To List    ${scell_ru_index_list}    ${scell_ru_index}
        ${scell_index}    convert to string    ${scell_index}
        Set To Dictionary 	${scell_pcell_mapping_dict} 	${scell_index}=${pcell_index}
    END
    Set To Dictionary 	${scell_pcell_mapping_dict} 	${pcell_index}=${pcell_index}
    [Return]   ${SCELL_INDEX_LIST}

Set PA value based on pcell index
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${pcell_index}=${PCELL_INDEX}
    ...            ${gnb_id}=${0}
    ...            ${ue_index}=${0}
    ...            ${pa_off_value}=${None}
    Get Pcell And Scell Mapping Info    pcell_index=${pcell_index}    source_gnb_id=${gnb_id}
    ${SCELL_INDEX_LIST}    Get Dictionary Keys    ${SCELL_MAPPING}
    ${pcell_ru_index}    Set Variable    ${PCELL_MAPPING['ru_index_mapping']}
    ${scell_ru_index_list}    Create List
    FOR  ${scell_index}  IN    @{SCELL_INDEX_LIST}
        ${scell_ru_index}    Set Variable    ${SCELL_MAPPING[${scell_index}]['all_cell_info']['ru_index_mapping']}
        Append To List    ${scell_ru_index_list}    ${scell_ru_index}
    END
    Modify PA Value Setting For Required RU    modify_ru_id=${pcell_ru_index}    ue_index=${ue_index}    pa_off_value=${pa_off_value}
    Modify PA Value Setting For Required RU    modify_ru_id=${scell_ru_index_list}    ue_index=${ue_index}    pa_off_value=${pa_off_value}


Get 3CC Related Infomation
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${pcell_index}=${PCELL_INDEX}
    ...            ${connection}=GNB_OAM0
    ...            ${gnb_id}=${0}
    ...            ${timeout}=${600}
    Get Pcell And Scell Mapping Info    pcell_index=${pcell_index}    source_gnb_id=${gnb_id}
    ${all_scell_list}    Get Dictionary Keys   ${SCELL_MAPPING}
    @{scell_index_list}    Set Variable    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']['scell_idx_list']}
    Modify WeightForSCellSelection Parameter Value On Gnb    scell_list_used_in_fact=${scell_index_list}
    ...                                                      scell_list_supported=${all_scell_list}
    ...                                                      connection=${connection}
    ...                                                      gnb_id=${gnb_id}
    ...                                                      timeout=${timeout}
    Set Test Variable    ${SCELL_INDEX_LIST}    ${scell_index_list}

Generate coam cells update Parameter Values
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${cell_list}
    ...            ${params_for_update}
    ...            ${gnb_id}=${0}
    ...            ${parameter}=weightForSCellSelection
    ...            ${value}=100
    FOR    ${cell_index}    IN    @{cell_list}
        ${dist_name}    Set Variable    NRBTS-${tl.gnbs[${gnb_id}].global_bts_id}/NRCELL-${cell_index}
        ${param}    Create Dictionary    dist_name=${dist_name}    parameter=${parameter}    value=${value}
        Append To List    ${params_for_update}    ${param}
    END
    [Return]    ${params_for_update}

COAM Create Updated parameters Delta File
    [Documentation]  Author: lei.jia@nokia-sbell.com
    [Arguments]    ${cell_list}    ${timeout}=${600}    ${connection}=GNB_OAM
    # generate update parameters
    @{params_for_update}    Create List
    Generate coam cells update Parameter Values    cell_list=${cell_list}
    ...    parameter=weightForSCellSelection
    ...    value=1
    ...    params_for_update=${params_for_update}
    ${params_for_scellweight}    Generate coam cells update Parameter Values    cell_list=${cell_list}
    ...    parameter=actMacBSRIndexAlign
    ...    value=false
    ...    params_for_update=${params_for_update}
    @{params_for_lockcell}    Create List
    ${cell_locked_param}     Generate coam cells update Parameter Values        cell_list=${cell_list}
    ...            parameter=administrativeState
    ...            value=Locked
    ...            params_for_update=${params_for_lockcell}
    @{params_for_unlockcell}    Create List
    ${cell_unlocked_param}     Generate coam cells update Parameter Values       cell_list=${cell_list}
    ...            parameter=administrativeState
    ...            value=Unlocked
    ...            params_for_update=${params_for_unlockcell}
    @{params_for_update2}    Create List
    Generate coam cells update Parameter Values    cell_list=${cell_list}
    ...    params_for_update=${params_for_update2}
    ...    parameter=weightForSCellSelection
    ...    value=100
    ${params_for_scellweight2}    Generate coam cells update Parameter Values    cell_list=${cell_list}
    ...    parameter=actMacBSRIndexAlign
    ...    value=true
    ...    params_for_update=${params_for_update2}
    # create delta file for parameters
    ${para_file_scellweight}    coam_parameter.create_update_parameters_delta
    ...    parameters=${params_for_scellweight}
    ...    connection=${connection}
    ...    timeout=${timeout}
    ${para_file_cell_locked}    coam_parameter.create_update_parameters_delta
    ...    parameters=${cell_locked_param}
    ...    connection=${connection}
    ...    timeout=${timeout}
    ${para_file_cell_unlocked}    coam_parameter.create_update_parameters_delta
    ...    parameters=${cell_unlocked_param}
    ...    connection=${connection}
    ...    timeout=${timeout}
    ${para_file_scellweight100}    coam_parameter.create_update_parameters_delta
    ...    parameters=${params_for_scellweight2}
    ...    connection=${connection}
    ...    timeout=${timeout}
    [Return]    ${para_file_scellweight}    ${para_file_cell_locked}    ${para_file_cell_unlocked}    ${para_file_scellweight100}


COAM perform scf delta commission
    [Documentation]  Author: lei.jia
    [Arguments]    ${para_file}    ${timeout}=${600}    ${connection}=GNB_OAM    ${should_activate}=${True}
    ...    ${skip_parameter_relation_errors}=True
    ${update_via_api_status}    coam_parameter.perform_scf_delta_commission
    ...    delta_file=${para_file['updated']}
    ...    timeout=${timeout}
    ...    connection=${connection}
    ...    should_activate=${should_activate}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}



Modify WeightForSCellSelection Parameter Value On Gnb
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${scell_list_used_in_fact}
    ...            ${scell_list_supported}
    ...            ${connection}=GNB_OAM0
    ...            ${gnb_id}=${0}
    ...            ${timeout}=${600}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}
    ...                                                                             gnb_index=${gnb_id}
    ${rest_scell_list}    Evaluate    list(set(${scell_list_supported})-set(${scell_list_used_in_fact}))
    @{params_for_update}    Create List
    Log To Console    ${\n}Modify weight value to 100 of ${scell_list_used_in_fact} on GNB: ${gnb_id}
    Generate coam cells update Parameter Values    cell_list=${scell_list_used_in_fact}    value=100
    ...    params_for_update=${params_for_update}    parameter=weightForSCellSelection
    Log To Console    ${\n}Modify weight value to 1 of ${rest_scell_list} on GNB: ${gnb_id}
    Generate coam cells update Parameter Values    cell_list=${rest_scell_list}    value=1
    ...    params_for_update=${params_for_update}    parameter=weightForSCellSelection
    Log To Console    ${\n}Update weight value on GNB: ${gnb_id}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}    timeout=${timeout}
    ...    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get RU Index In Init Via Cell Index
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${pell_index}    ${sell_index_list}
    Source COAM Login Page Via WebUI
    ${pcell_rmod_index}    Set Variable    ${PCELL_MAPPING['rmod_index']}
    ${serial_number}    Get Serial Number Via Rmod Index On Gnb    rmod_index=${pcell_rmod_index}
    ${pcell_ru_index}    Get RU Index In Init Via Serial Number Of RU On Gnb    serial_number=${serial_number}
    ${scell_ru_index_list}    Create List
    FOR  ${scell_index}  IN    @{SCELL_INDEX_LIST}
        ${scell_rmod_index}    Set Variable    ${SCELL_MAPPING[${scell_index}]['all_cell_info']['rmod_index']}
        ${serial_number}    Get Serial Number Via Rmod Index On Gnb    rmod_index=${scell_rmod_index}
        ${scell_ru_index}    Get RU Index In Init Via Serial Number Of RU On Gnb    serial_number=${serial_number}
        Append To List    ${scell_ru_index_list}    ${scell_ru_index}
    END
    [Return]    ${pcell_ru_index}    ${scell_ru_index_list}
    [Teardown]    Run Keyword And Ignore Error    COAM selenium logout

Get Serial Number Via Rmod Index On Gnb
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${rmod_index}
    ${output_ru}      selenium_coam.get_ru_info    ru_index=${rmod_index}
    ${serial_number}    Set Variable    ${output_ru['Serial number']}
    [Return]    ${serial_number}

Get RU Index In Init Via Serial Number Of RU On Gnb
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${serial_number}
    ${all_ru_list_in_init}    Set Variable    ${tl.gnbs[0].dus[0].rus}
    FOR    ${ru_in_init}    IN    @{all_ru_list_in_init}
        ${ru_index}    Get Index From List    ${all_ru_list_in_init}    ${ru_in_init}
        ${sn_of_ru}    Set Variable    ${tl.gnbs[0].dus[0].rus[${ru_index}].serial_number}
        ${status}    Evaluate    "${serial_number}"=="${sn_of_ru}"
        Exit For Loop If    "${status}"=="True"
    END
    [Return]    ${ru_index}

Check RU Whether Connect Mcs
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ru_index}    ${ue_index}=${0}
    ${ru_index_list}    Get Dictionary Keys    ${${tl_prefix}_PA_VALUE_MAPPING[${ue_index}]}
    ${ru_whether_connect_mcs}    Run Keyword And Return Status    List Should Not Contain Value    ${ru_index_list}    ${ru_index}
    [Return]    ${ru_whether_connect_mcs}

Set Case PA Or MCS Port Value
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${attenuator_list}    ${ue_index}=${0}   ${whether_do_mcs_setup}=${True}    ${pa_off_value}=${None}
    FOR    ${attenuator}    IN    @{attenuator_list}
        Run Keyword If    '${attenuator}'=='pa'    Set Case Related PA Port Value    ue_index=${ue_index}    pa_off_value=${pa_off_value}
        ...    ELSE IF    '${attenuator}'=='mcs'    Set Case Related MCS Port Value    ue_index=${ue_index}
        ...                                            whether_do_mcs_setup=${whether_do_mcs_setup}
        ...    ELSE    Log To Console     ${\n}INFO: --Use the wrong attenuator type(${attenuator}), need to check TMO_Data.py--
    END

Update The Prach Index
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                This keyword just for 5G cell.
    [Arguments]    ${cell_index}    ${prach_index}=158    ${connection}=GNB_OAM    ${gnb_index}=0    ${timeout}=300
    ${dist_name}    Set Variable    MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${cell_index}
#    ${dist_name2}    Set Variable
#    ...     MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${401}
    ${dist_name2}     Set Variable If   '${tl_prefix}'=='T813'
    ...     MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${311}
    ${param}    Create Dictionary    dist_name=${dist_name}    parameter=prachConfigurationIndex    value=${prach_index}
    ${param2}    Create Dictionary    dist_name=${dist_name2}    parameter=prachConfigurationIndex    value=${prach_index}
    @{param_list}    Run Keyword If     '${tl_prefix}'=='T813'     Create List    ${param}    ${param2}
    ...                   ELSE     Create List    ${param}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}
    ...                                            timeout=${timeout}
    Wait Gnb Ready And Cell On Air    gnb_id=${gnb_index}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Update AMF Status
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                ${administrativeState}: Value can be "Unlocked" or "Locked"
    [Arguments]    ${administrativeState}=Locked    ${connection}=GNB_OAM    ${gnb_index}=0    ${timeout}=300
    ${dist_name}    Set Variable    MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/SERVEDAMF-1
    ${param}    Create Dictionary    dist_name=${dist_name}    parameter=administrativeState    value=${administrativeState}
    @{param_list}    Create List    ${param}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    timeout=${timeout}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Verify SERVEDAMF Status On GNB
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                When AMF is lock, gnb and enb is no expect alarm, so need to check point is check unexpect alarm
    ...                ${administrativeState}: Value can be "Unlocked" or "Locked"
    ...                ${ngLinkStatus}: Value can be "Active" or "Inactive"
    [Arguments]    ${connection}=GNB_OAM
    ...            ${enb_connection}=enblte
    ...            ${gnb_index}=${0}
    ...            ${enb_index}=${1}
    ...            ${administrativeState}=Unlocked
    ...            ${ngLinkStatus}=Active
    ...            ${target_amf_number}=${1}
    ...            ${ru_type}=AHFIG
    ...            ${cell_type}=nr
    ...            ${expected_value}=Unlocked
    ...            ${allowed_faults}=${GNB_ALLOWED_FAULT}
    Log To Console    ${\n}Check SERVEDAMF status from GNB
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
    ...                 Connect to eNB via ssl    connection=${enb_connection}    enb_index=${enb_index}
    @{SERVEDAMF_A}    coam.get_managed_objects    class_name=SERVEDAMF_A    connection=${connection}
    @{SERVEDAMF_L}    coam.get_managed_objects    class_name=SERVEDAMF_L    connection=${connection}
    @{direction_serverAMF_A}    Create List
    @{direction_serverAMF_L}    Create List
    FOR   ${SERVERAMF}   IN   @{SERVEDAMF_A}
         ${amf_number}  Set Variable    ${SERVERAMF['distName'].split('-')[-1]}
         Run Keyword If   '${amf_number}'=='${target_amf_number}'
         ...                    Append To List    ${direction_serverAMF_A}    ${SERVERAMF}
    END
    FOR   ${SERVERAMF}   IN   @{SERVEDAMF_L}
         ${amf_number}  Set Variable    ${SERVERAMF['distName'].split('-')[-1]}
         Run Keyword If   '${amf_number}'=='${target_amf_number}'
         ...                    Append To List    ${direction_serverAMF_L}    ${SERVERAMF}
    END
    &{dict_amfStatus}    coam.get_parameters    dist_name=${direction_serverAMF_A[0]['distName']}    pattern=administrativeState
    ...                                                                                    connection=${connection}
    &{dict_ngLinkStatus}    coam.get_parameters    dist_name=${direction_serverAMF_L[0]['distName']}    pattern=ngLinkStatus
    ...                                                                                       connection=${connection}
    Should Be Equal As Strings    ${dict_amfStatus['administrativeState']}    ${administrativeState}    msg=AMF is not ${administrativeState}
    ...                                                                                                 ignore_case=${True}
    Should Be Equal As Strings    ${dict_ngLinkStatus['ngLinkStatus']}    ${ngLinkStatus}    msg=AMF is not ${ngLinkStatus}
    ...                                                                                      ignore_case=${True}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}    connection=${connection}
    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'       Run Keyword And Continue On Failure
    ...                 Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}    connection=${enb_connection}
    Run Keyword If    '${expected_value}'=='Locked'    Wait Until Keyword Succeeds    10 min    20 sec
    ...    Check All Cells Should Be On Air Except Special RU Related Cells
    ...  connection=${connection}    ru_type=${ru_type}    cell_type=${cell_type}
    Run Keyword If    '${expected_value}'=='Unlocked'    Wait Until Keyword Succeeds    10 min    20 sec
    ...    Verify TMO Gnb Ready And All Cell On Air    connection=${connection}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}    AND
    ...           Run Keyword If    '${LTE_WHETHER_IN_GNB}'=='${False}'   Run Keyword And Ignore Error
    ...                                                   Enblte close down    connection=${enb_connection}

Get Pcell And Scell Mapping Info After Handover
    [Documentation]   Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ho_pcell_index}    ${source_gnb_id}=0    ${connection}=GNB_OAM0
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${source_gnb_id}
    mbca.set_pcell_index    value=${ho_pcell_index}
    mbca.set_gnb_id    value=${source_gnb_id}
    mbca.set_gnb_operation_object
    ${ho_pcell_mapping}    mbca.get_pcell_mapping_for_tmo
    ${ho_scell_mapping}    mbca.get_scell_mapping_for_pcell_for_tmo
    ${ho_tdd_scell_mapping}    mbca.get_tdd_scell_mapping    all_scell_info=${ho_scell_mapping}
    ${ho_fdd_scell_mapping}    mbca.get_fdd_scell_mapping    all_scell_info=${ho_scell_mapping}
    Set Test Variable    ${HO_PCELL_MAPPING}     ${ho_pcell_mapping}
    Set Test Variable    ${HO_SCELL_MAPPING}    ${ho_scell_mapping}
    Set Test Variable    ${HO_TDD_SCELL_MAPPING}    ${ho_tdd_scell_mapping}
    Set Test Variable    ${HO_FDD_SCELL_MAPPING}    ${ho_fdd_scell_mapping}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get Pcell And Scell Mapping Info For Pcell Change
    [Documentation]   Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ho_pcell_index}    ${gnb_id}=0    ${connection}=GNB_OAM0    ${timeout}=${600}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_id}
    mbca.set_pcell_index    value=${ho_pcell_index}
    mbca.set_gnb_id    value=${gnb_id}
    mbca.set_gnb_operation_object
    ${ho_pcell_mapping}    mbca.get_pcell_mapping_for_tmo
    ${ho_scell_mapping}    mbca.get_scell_mapping_for_pcell_for_tmo
    ${ho_tdd_scell_mapping}    mbca.get_tdd_scell_mapping    all_scell_info=${ho_scell_mapping}
    ${ho_fdd_scell_mapping}    mbca.get_fdd_scell_mapping    all_scell_info=${ho_scell_mapping}
    Set Test Variable    ${HO_PCELL_MAPPING}     ${ho_pcell_mapping}
    Set Test Variable    ${HO_SCELL_MAPPING}    ${ho_scell_mapping}
    Set Test Variable    ${HANDOVER_PCELL_MAPPING}     ${ho_pcell_mapping}
    Set Test Variable    ${HO_TDD_SCELL_MAPPING}    ${ho_tdd_scell_mapping}
    Set Test Variable    ${HO_FDD_SCELL_MAPPING}    ${ho_fdd_scell_mapping}
    ${ho_all_scell_list}    Get Dictionary Keys   ${HO_SCELL_MAPPING}
    ${ho_tdd_scell_list}    Get Dictionary Keys   ${HO_TDD_SCELL_MAPPING}
    ${ho_fdd_scell_list}    Get Dictionary Keys   ${HO_FDD_SCELL_MAPPING}
    ${ho_scell_list}    Set Variable If    '${HO_SCELL_TECHNOLOGY}'=='TDD'    ${ho_tdd_scell_list}    ${ho_fdd_scell_list}
    ${ho_chbw_param_name}    Set Variable If    '${HO_SCELL_TECHNOLOGY}'=='TDD'    chBw    chBwDl
    ${ho_scell_chbw_value}    Set Variable    ${0}
    ${scell_index}    Set Variable    ${0}
    FOR    ${scell}    IN    @{ho_scell_list}
        ${scell_chbw}    Set Variable    ${HO_SCELL_MAPPING[${scell}]['all_cell_info']['detail_cells_info']['${ho_chbw_param_name}']}
        ${scell_chbw}    Set Variable    ${scell_chbw.split('M')[0]}
        ${scell_chbw}    Evaluate    int(${scell_chbw})
        ${scell_index}    Set Variable If     ${scell_chbw}>=${ho_scell_chbw_value}    ${scell}    ${scell_index}
        ${ho_scell_chbw_value}    Set Variable If     ${scell_chbw}>=${ho_scell_chbw_value}    ${scell_chbw}    ${ho_scell_chbw_value}
    END
    @{ho_scell_index_list}    Create List    ${scell_index}
    Modify WeightForSCellSelection Parameter Value On Gnb    scell_list_used_in_fact=${ho_scell_index_list}
    ...                                                      scell_list_supported=${ho_all_scell_list}
    ...                                                      connection=${connection}
    ...                                                      gnb_id=${gnb_id}
    ...                                                      timeout=${timeout}
    @{ho_scell_pci_list}    Create List
    FOR    ${item}    IN    @{ho_scell_index_list}
        ${scell_pci}    Set Variable    ${HO_SCELL_MAPPING[${item}]['all_cell_info']['physicalCellId']}
        ${scell_pci}    Convert To String    ${scell_pci}
        Append to List    ${ho_scell_pci_list}    ${scell_pci}
    END
    Set Test Variable    ${HO_SCELL_INDEX_LIST}    ${ho_scell_index_list}
    Set Test Variable    ${HO_SCELL_PCI_LIST}    ${ho_scell_pci_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Do All Type Cells Action And Verify Status
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    ...                ${cell_action}:value can be "locked"  or "unlocked"
    ...                ${cell_id}: value can be "None" means for all cells, if not "None" means for special cell
    [Arguments]    ${cell_action}=locked    ${cell_type}=nr    ${timeout}=300
    ...            ${gnb_id}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${1}    ${enb_connection}=enblte_${enb_index}
    ...            ${is_connect_coam_needed}=${True}    ${cell_id}=None
    Do All Type Cells Lock Or Unlock    cell_action=${cell_action}
    ...                                 cell_type=${cell_type}
    ...                                 timeout=${timeout}
    ...                                 gnb_id=${gnb_id}
    ...                                 gnb_connection=${gnb_connection}
    ...                                 enb_index=${enb_index}
    ...                                 enb_connection=${enb_connection}
    ...                                 is_connect_coam_needed=${is_connect_coam_needed}
    ...                                 cell_id=${cell_id}
    Run Keyword If    '${cell_action}'=='locked'    Wait Until Keyword Succeeds    ${timeout} sec    10 sec
    ...                                             Verify All Type Cells Should Be locked    cell_type=${cell_type}
    ...                                                                                       timeout=${timeout}
    ...                                                                                       gnb_id=${gnb_id}
    ...                                                                                       gnb_connection=${gnb_connection}
    ...                                                                                       enb_index=${enb_index}
    ...                                                                                       enb_connection=${enb_connection}
    ...                                                                                       is_connect_coam_needed=${is_connect_coam_needed}
    ...                                                                                       cell_id=${cell_id}
    ...    ELSE IF    '${cell_action}'=='unlocked'    Wait Until Keyword Succeeds    ${timeout} sec    10 sec
    ...                                               Verify All Type Cells Should Be unlocked    cell_type=${cell_type}
    ...                                                                                           timeout=${timeout}
    ...                                                                                           gnb_id=${gnb_id}
    ...                                                                                           gnb_connection=${gnb_connection}
    ...                                                                                           enb_index=${enb_index}
    ...                                                                                           enb_connection=${enb_connection}
    ...                                                                                           is_connect_coam_needed=${is_connect_coam_needed}
    ...                                                                                           cell_id=${cell_id}
    ...    ELSE    Log To Console     ${\n}INFO: --Use the wrong cell action(${cell_action}), need to check--

Do All Type Cells Lock Or Unlock
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    ...                ${cell_action}:value can be "locked"  or "unlocked"
    [Arguments]    ${cell_action}=locked    ${cell_type}=nr    ${timeout}=300
    ...            ${gnb_id}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${1}    ${enb_connection}=enblte_${enb_index}
    ...            ${is_connect_coam_needed}=${True}    ${cell_id}=None
    Log to console    ${\n}----Do all ${cell_type} cells ${cell_action}----
    Run Keyword If    ${is_connect_coam_needed}    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl
    ...                                                                                                connection=${gnb_connection}
    ...                                                                                                gnb_index=${gnb_id}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and ${is_connect_coam_needed} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${LTE_WHETHER_IN_GNB}    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'=='nr'    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'!='nr'    ${enb_connection}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    @{params_for_update}    Create List
    ${action}    Run Keyword If    '${cell_type}'=='nr' and '${cell_action}'=='locked'    Set Variable    Locked
    ...                 ELSE IF    '${cell_type}'=='nr' and '${cell_action}'=='unlocked'    Set Variable    Unlocked
    ...                 ELSE IF    '${cell_type}'=='lte' and '${cell_action}'=='locked'    Set Variable    locked
    ...                 ELSE IF    '${cell_type}'=='lte' and '${cell_action}'=='unlocked'    Set Variable    unlocked
    FOR   ${cell_dist_name}    IN     @{cell_list}
         ${cell_index}    Set Variable    ${cell_dist_name.split('-')[-1]}
         ${param}    Create Dictionary    dist_name=${cell_dist_name}    parameter=administrativeState    value=${action}
         Run Keyword If    '${cell_id}'=='None'    Append To List    ${params_for_update}    ${param}
         ...    ELSE IF    '${cell_id}'!='None' and '${cell_index}'=='${cell_id}'    Append To List    ${params_for_update}    ${param}
    END
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    [Teardown]    Run Keywords
    ...    Run Keyword If    ${is_connect_coam_needed}
    ...                          Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}   AND
    ...    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and ${is_connect_coam_needed} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Verify All Type Cells Should Be locked
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    [Arguments]    ${cell_type}=nr    ${timeout}=300    ${gnb_connection}=GNB_OAM    ${gnb_id}=0
    ...            ${enb_index}=${1}    ${enb_connection}=enblte_${enb_index}
    ...            ${is_connect_coam_needed}=${True}    ${cell_id}=None
    Log to console    ${\n}----Verify all ${cell_type} cells are locked----
    Run Keyword If    ${is_connect_coam_needed}    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl
    ...                                                                                                connection=${gnb_connection}
    ...                                                                                                gnb_index=${gnb_id}
    ${result}    Run Keyword And Return Status    Should Contain Any    ${stream_version}    12.400    14.400    22R1    22R2    21B
    ${disabled}    Set Variable If    ${result}    Disabled    disabled
    ${offline}    Set Variable If    ${result}    Offline    off line
    ${locked}     Set Variable If    ${result}    Locked    locked
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and ${is_connect_coam_needed} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${LTE_WHETHER_IN_GNB}    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'=='nr'    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'!='nr'    ${enb_connection}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR  ${cell}  IN   @{cell_list}
        ${cell_index}    Set Variable    ${cell.split('-')[-1]}
        Run Keyword If    '${cell_id}'!='None' and '${cell_index}'!='${cell_id}'    Continue For Loop
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['availabilityStatus']}    ${offline}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['operationalState']}    ${disabled}
        Run Keyword If   '${cell_type}'=='nr'   Run Keyword And Continue On Failure
        ...                 Should Be Equal As Strings    ${cell_list_info['${cell}']['administrativeState']}    Locked
        Run Keyword If   '${cell_type}'=='lte'   Run Keyword And Continue On Failure
        ...                 Should Be Equal As Strings    ${cell_list_info['${cell}']['administrativeState']}    ${locked}
    END
    [Teardown]    Run Keywords
    ...    Run Keyword If    ${is_connect_coam_needed}
    ...                          Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}   AND
    ...    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and ${is_connect_coam_needed} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Verify All Type Cells Should Be unlocked
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    [Arguments]    ${cell_type}=nr    ${timeout}=300    ${gnb_connection}=GNB_OAM    ${gnb_id}=0
    ...            ${enb_index}=${1}    ${enb_connection}=enblte_${enb_index}
    ...            ${is_connect_coam_needed}=${True}    ${cell_id}=None
    Log to console    ${\n}----Verify all ${cell_type} cells are unlocked----
    Run Keyword If    ${is_connect_coam_needed}    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl
    ...                                                                                                connection=${gnb_connection}
    ...                                                                                                gnb_index=${gnb_id}
    ${result}    Run Keyword And Return Status    Should Contain Any    ${stream_version}    12.400    14.400    22R1    22R2    21B
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${unlocked}     Set Variable If    ${result}    Unlocked    unlocked
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and ${is_connect_coam_needed} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${LTE_WHETHER_IN_GNB}    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'=='nr'    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'!='nr'    ${enb_connection}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR  ${cell}  IN   @{cell_list}
        ${cell_index}    Set Variable    ${cell.split('-')[-1]}
        Run Keyword If    '${cell_id}'!='None' and '${cell_index}'!='${cell_id}'    Continue For Loop
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['operationalState']}    ${enabled}
        Run Keyword If   '${cell_type}'=='nr'   Run Keyword And Continue On Failure
        ...                Should Be Equal As Strings    ${cell_list_info['${cell}']['administrativeState']}    Unlocked
        Run Keyword If   '${cell_type}'=='lte'   Run Keyword And Continue On Failure
        ...                 Should Be Equal As Strings    ${cell_list_info['${cell}']['administrativeState']}    ${unlocked}
        run keyword if    ${result}    Run Keyword And Continue On Failure
        ...    Should Be Equal As Strings    ${cell_list_info['${cell}']['availabilityStatus']}    Online
    END
    [Teardown]    Run Keywords
    ...    Run Keyword If    ${is_connect_coam_needed}
    ...                          Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}   AND
    ...    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and ${is_connect_coam_needed} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Do All TDD-LTE Cells Action
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
        ...            ${cell_action}:value can be "locked" or "unlocked"
    [Arguments]    ${cell_action}=locked    ${timeout}=300
    ...            ${gnb_index}=${0}    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    Log to console    ${\n}----Get all TDD-LTE cells and do ${cell_action} action----
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False}
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If    ${LTE_WHETHER_IN_GNB}    ${gnb_connection}    ${enb_connection}
    ${cell_info}   coam.get_cells_info    cell_type=lte    timeout=${timeout}    connection=${connection}
    @{tdd_lte_cell_list}    Create List
    FOR    ${item}    IN    @{cell_info}
        ${cell_technology}    Set variable    ${item['technology']}
        Run Keyword If    '${cell_technology}'=='TDD'    Append To List    ${tdd_lte_cell_list}    ${item['id']['configuration']}
    END
    @{params_for_update}    Create List
    FOR   ${tdd_lte_cell}    IN     @{tdd_lte_cell_list}
         ${param}    Create Dictionary    dist_name=${tdd_lte_cell}    parameter=administrativeState    value=${cell_action}
         Append To List    ${params_for_update}    ${param}
    END
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}    AND
    ...    Run Keyword If   ${LTE_WHETHER_IN_GNB}==${False}   Run Keyword And Ignore Error   Enblte close down   connection=${enb_connection}

Verify All TDD-LTE Cells Should Be Locked
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${timeout}=300    ${gnb_index}=${0}    ${gnb_connection}=GNB_OAM    ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    Log to console    ${\n}----Verify all TDD-LTE Cells are locked----
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False}
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If    ${LTE_WHETHER_IN_GNB}    ${gnb_connection}    ${enb_connection}
    ${result}    Run Keyword And Return Status    Should Contain Any    ${stream_version}    12.400    14.400    22R1    22R2    21B
    ${disabled}    Set Variable If    ${result}    Disabled    disabled
    ${offline}    Set Variable If    ${result}    Offline    off line
    ${cell_info}   coam.get_cells_info    cell_type=lte    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        ${cell_technology}    Set variable    ${item['technology']}
        Run Keyword If    '${cell_technology}'=='TDD'    Set To Dictionary    ${cell_list_info}
        ...                                                                   ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR  ${cell}  IN   @{cell_list}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['operationalState']}    ${disabled}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['administrativeState']}    locked
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['availabilityStatus']}    ${offline}
    END
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}    AND
    ...    Run Keyword If   ${LTE_WHETHER_IN_GNB}==${False}   Run Keyword And Ignore Error   Enblte close down   connection=${enb_connection}

Verify All TDD-LTE Cells Should Be Unlocked
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${timeout}=300    ${gnb_index}=${0}    ${gnb_connection}=GNB_OAM    ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    Log to console    ${\n}----Verify all TDD-LTE Cells are unlocked----
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False}
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If    ${LTE_WHETHER_IN_GNB}    ${gnb_connection}    ${enb_connection}
    ${result}    Run Keyword And Return Status    Should Contain Any    ${stream_version}    12.400    14.400    22R1    22R2    21B
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${cell_info}   coam.get_cells_info    cell_type=lte    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        ${cell_technology}    Set variable    ${item['technology']}
        Run Keyword If    '${cell_technology}'=='TDD'    Set To Dictionary    ${cell_list_info}
        ...                                                                   ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR  ${cell}  IN   @{cell_list}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['operationalState']}    ${enabled}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['administrativeState']}    unlocked
        Run Keyword If    ${result}    Should Be Equal As Strings    ${cell_list_info['${cell}']['availabilityStatus']}    Online
    END
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}    AND
    ...    Run Keyword If   ${LTE_WHETHER_IN_GNB}==${False}   Run Keyword And Ignore Error   Enblte close down   connection=${enb_connection}

Update The DmrsTypeAPosition Value Of Cell
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=${0}    ${timeout}=600
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${MOs}    coam.get_managed_objects    class_name=NRCELL_A    connection=${connection}    timeout=${timeout}
    &{cell_dmrsTypeAPosition_mapping_list}    Create Dictionary
    FOR    ${mo}    IN    @{MOs}
        Set To Dictionary    ${cell_dmrsTypeAPosition_mapping_list}    ${mo['distName'].split('-')[-1]}=${mo['parameters']['dmrsTypeAPosition']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_dmrsTypeAPosition_mapping_list}
    @{params_for_update}    Create List
    FOR   ${cell}    IN     @{cell_list}
         ${dist_name}    Set Variable
         ...    MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${cell}
         ${value}    Set Variable If    '${cell_dmrsTypeAPosition_mapping_list['${cell}']}'=='pos2'    pos3    pos2
         ${param}    Create Dictionary    dist_name=${dist_name}    parameter=dmrsTypeAPosition    value=${value}
         Append To List    ${params_for_update}    ${param}
    END
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    Wait Gnb Ready And Cell On Air    gnb_id=${gnb_index}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Verify Specific RU Should Be Power Action
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param ${cell_type}: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    ...                :param ${ru_type}:value like: "AEHC"
    [Arguments]    ${ru_type}=AEHC    ${cell_type}=nr    ${action}=power_off    ${timeout}=300    ${gnb_index}=0
    ...            ${gnb_connection}=GNB_OAM    ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    Log to console    ${\n}----Verify all ${cell_type} cells For Special RU ${ru_type} Should Be Power Action----
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${LTE_WHETHER_IN_GNB}    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'=='nr'    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'!='nr'    ${enb_connection}
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    @{aehc_ru_list}    Create List
    FOR    ${ru}    IN    @{list_RUs}
        ${rmod_info}   Set variable   ${ru['id']['configuration']}
        ${rmod_index}   Set variable    ${rmod_info.split('RMOD-')[-1]}
        Append To List    ${aehc_ru_list}    ${rmod_index}
    END
    ${aehc_ru_list}    Remove Duplicates    ${aehc_ru_list}
    FOR    ${aehc_ru}    IN    @{aehc_ru_list}
        Run Keyword If    '${action}'=='power_off'
        ...        Wait Until Keyword Succeeds    15 min    10 sec    RU Should Be Power Off    ru_index=${aehc_ru}    connection=${connection}
        ...    ELSE IF    '${action}'=='power_on'
        ...        Wait Until Keyword Succeeds    15 min    10 sec    RU Should Be Online    ru_index=${aehc_ru}    connection=${connection}
    END
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}    AND
    ...    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Perform Special RU Reset
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${ru_type}=AEHC    ${cell_type}=nr    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${False}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${LTE_WHETHER_IN_GNB}    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'=='nr'    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'!='nr'    ${enb_connection}
    ${sn_of_first_ru}    Set Variable    ${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}].serial_number}
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    @{aehc_ru_list}    Create List
    FOR    ${ru}    IN    @{list_RUs}
        ${rmod_info}   Set variable   ${ru['id']['internal']}
        ${serialNumber}   Set variable    ${ru['serialNumber']}
        Run Keyword If    ${whether_get_first_ru_only}==${False} and '${ru['productName']}'=='${ru_type}'
        ...                             Append To List    ${aehc_ru_list}    ${rmod_info}
        ...    ELSE IF    ${whether_get_first_ru_only} and '${ru['productName']}'=='${ru_type}' and '${serialNumber}'=='${sn_of_first_ru}'
        ...                             Append To List    ${aehc_ru_list}    ${rmod_info}
        ...    ELSE IF    ${whether_get_first_ru_only}==${False} and '${ru_type}'=='all'
        ...                             Append To List    ${aehc_ru_list}    ${rmod_info}
    END
    FOR    ${ru_index}    IN    @{aehc_ru_list}
        Run Keyword And Ignore Error    coam.reset_unit    dist_name=${ru_index}     reset_type=Warm
        ...         force_radio_reset=${True}   connection=${connection}   timeout=${timeout}
    END
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}    AND
    ...    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Get Cell List For Special RU
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param ${cell_type}: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    ...                :param ${ru_type}:value like: "AEHC"
    ...                :param ${ru_index}: 0 means first AEHC, 1 means second AEHC, etc...
    [Arguments]    ${ru_type}=AEHC    ${cell_type}=nr    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${False}
    Log to console    ${\n}----Get all ${cell_type} cells For Special RU ${ru_type}----
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${LTE_WHETHER_IN_GNB}    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'=='nr'    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'!='nr'    ${enb_connection}
    ${sn_of_first_ru}    Set Variable    ${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}].serial_number}
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    @{aehc_ru_list}    Create List
    FOR    ${ru}    IN    @{list_RUs}
        ${rmod_info}   Set variable   ${ru['id']['configuration']}
        ${rmod_index}   Set variable    ${rmod_info.split('RMOD-')[-1]}
        ${serialNumber}   Set variable    ${ru['serialNumber']}
        ${productName}   Set variable    ${ru['productName']}
        ${actual_ru_type}    Set Variable If    '${ru_type}'=='AEHC' and '${productName}'=='AVHA'    AVHA    ${ru_type}
        Run Keyword If    ${whether_get_first_ru_only}==${False} and '${productName}'=='${actual_ru_type}'
        ...                             Append To List    ${aehc_ru_list}    ${rmod_index}
        ...    ELSE IF    ${whether_get_first_ru_only} and '${productName}'=='${actual_ru_type}' and '${serialNumber}'=='${sn_of_first_ru}'
        ...                             Append To List    ${aehc_ru_list}    ${rmod_index}
    END
    ${aehc_ru_list}    Remove Duplicates    ${aehc_ru_list}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    @{aehc_cell_list}    Create List
    FOR    ${item}    IN    @{cell_info}
        ${rmod_info}    Get From List    ${item['carrierList']}    0
        ${rmod_id}    Get Regexp Matches    ${rmod_info['antennaLineId']['configuration']}    RMOD-(\\d+)    1
        ${cell_id}    Set variable    ${item['id']['configuration'].split('-')[-1]}
        ${cell_technology}    Set variable    ${item['technology']}
        ${status}    Run Keyword And Return Status    List Should Contain Value    ${aehc_ru_list}    ${rmod_id}[0]
        Run Keyword If    '${cell_technology}' != 'NB-IoT-FDD' and ${status}     Append To List    ${aehc_cell_list}    ${cell_id}
    END
    [Return]    ${aehc_cell_list}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}    AND
    ...    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Get The CA Support List Value
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                get the value of carrierAggregationSupportList on GNB
    [Arguments]    ${timeout}=300    ${connection}=GNB_OAM    ${gnb_index}=0
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${CA_support_list}    coam_parameter.get_single_value_from_scf_file    parameter=carrierAggregationSupportList
    ...                                                                    dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRDU-1
    ...                                                                    connection=${connection}
    ...                                                                    timeout=300
	[Return]    ${CA_support_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get The Flexible CA Mode Value
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                get the value of flexibleCAMode on GNB
    [Arguments]    ${timeout}=300    ${connection}=GNB_OAM    ${gnb_index}=0
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${flexibleCAMode}    coam_parameter.get_single_value_from_scf_file    parameter=flexibleCAMode
    ...                                                                   dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRDU-1
    ...                                                                   connection=${connection}
    ...                                                                   timeout=300
	[Return]    ${flexibleCAMode}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Update The CA Support List Value
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                Update the value of carrierAggregationSupportList and flexibleCAMode on GNB
    [Arguments]    ${carrierAggregationSupportList}=none
    ...            ${flexibleCAMode}=BasicCAMode
    ...            ${timeout}=300
    ...            ${connection}=GNB_OAM
    ...            ${gnb_index}=0
    ${status}    Run Keyword And Return Status    Evaluate    type(${carrierAggregationSupportList}).__name__
    ${carrierAggregationSupportList_to_list}    Run Keyword If    ${status}==${False}    Create List    ${carrierAggregationSupportList}
    ${ca_support_list}    Set Variable If    ${status}==${False}    ${carrierAggregationSupportList_to_list}
    ...                                                             ${carrierAggregationSupportList}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${flexibleCAMode}    Create Dictionary    dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRDU-1
    ...                                       parameter=flexibleCAMode
    ...                                       value=${flexibleCAMode}
    ${carrierAggregationSupportList}    Create Dictionary    dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRDU-1
    ...                                                      parameter=carrierAggregationSupportList
    ...                                                      value=${ca_support_list}
    @{param_list}    Create List    ${flexibleCAMode}    ${carrierAggregationSupportList}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    connection=${connection}    timeout=${timeout}
    Verify TMO Gnb Ready And All Cell On Air
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check RU Calibration Status And Power on Specifc RU
    [Documentation]  Author: tingting.1.liu@nokia-sbell.com
    [Arguments]  ${connection}=GNB_OAM    ${asik_connection}=ASIK Master
    ...    ${retry_time}=3    ${ru_index}=1    ${dual_alias}=MultiRAT GNB Master
    ...    ${dualcore_hostname}=fct4s0icom.local    ${is_right_bbmod}=${True}   ${connection_right}=ASIK Right
    run keyword and ignore error    csn.disconnect    connection=${asik_connection}
    run keyword and ignore error    COAM Teardown gnb connections
    connection_alias_store.Connect to Common Unit Master    alias=${asik_connection}
    ${multiRAT}    Check if multiRAT BTS
    ${mutiRAT_amia_right}    If GNB In Right Side Of AMIA    connection=${asik_connection}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    run keyword if    ${multiRAT} and ${mutiRAT_amia_right}    Connect To MultiRAT GNB Common Unit Master
    run keyword if   '${multiRAT}'=='${False}' and ${is_right_bbmod}    csn.connect to
    ...               hostname=fct-4a
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${connection_right}
    ...               proxy=${asik_connection}
    ${asik_connection}    set variable if    ${multiRAT}    ${dual_alias}    ${connection_right}
    ${container_id}    set variable if    ${multiRAT}    ${0x1018}    ${0x2018}
    ${rmod_index}    Set Variable    ${PCELL_MAPPING['rmod_index']}
    ${pcell_ru_index}   Set Variable    ${PCELL_MAPPING['ru_index_mapping']}
    Connect to RU With Allocated IP    ru_index=${rmod_index}   ru_alias=RU${rmod_index}
    ...    ru_username=${tl.gnbs[0].dus[0].rus[${pcell_ru_index}].default_ssh_connection_details.username}
    ...    ru_password=${tl.gnbs[0].dus[0].rus[${pcell_ru_index}].default_ssh_connection_details.password}
    ...    asik_alias=${asik_connection}   connection=${connection}    container_id=${container_id}
    Run Keyword And Continue On Failure    Wait until keyword succeeds    ${retry_time}X    30 s
    ...    Check RU Calibration Status For TMO    ru_alias=RU${rmod_index}
    csn.Disconnect  connection=RU${rmod_index}
   [Teardown]  COAM Teardown gnb connections

Check RU Calibration Status For TMO
    [Documentation]  Author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${ru_alias}    ${carrier_name}=NR
    ${calibration_output}    csn.execute    command=bfcali -stat    connection=${ru_alias}
    @{nr_calibration}    create list
    @{calibrations}    split string    ${calibration_output}    \r\n\r\n
    FOR    ${latest_cali}    IN    @{calibrations}
           ${status}    run keyword and return status    should contain    ${latest_cali}    ${carrier_name}
           run keyword if    '${status}'=='${True}'    append to list      ${nr_calibration}    ${latest_cali}
    END
    FOR    ${each_cali}    IN    @{nr_calibration}
           ${attempt_regexp}    set variable    Calibration attempts: (\\d+)
           ${success_regexp}    set variable    Successful calibrations: (\\d+)
           ${attempt_count}    Get Regexp Matches    ${each_cali}    ${attempt_regexp}    1
           ${success_count}    Get Regexp Matches    ${each_cali}    ${success_regexp}    1
           ${couter_value}    Evaluate    ${attempt_count[0]}-${success_count[0]}
           should be true    (${couter_value}==0) | (${couter_value}==1)
    END

Set Fiber Switch Into Link Failure Or Link Up
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    ...       para:${link_status} can be "down" or "up"
    ...       Connects to optical switch and sets switch into link failure position for given radio.
    [Arguments]    ${channel_numbers}   ${link_status}
    ...             ${ru_id}=0
    ...             ${gnb_id}=0
    ...             ${du_id}=0
    ...             ${dummy_output_channel}=00
    &{linkup_setting}       create dictionary
    &{link_failure_settings}    create dictionary
    FOR    ${n}    IN    @{channel_numbers}
         ${module_no}    set variable     ${tl.gnbs[${gnb_id}].dus[${du_id}].rus[${ru_id}].optical_switch_channels[${n}].switch_module.module_no}
         ${channel_no}    set variable     ${tl.gnbs[${gnb_id}].dus[${du_id}].rus[${ru_id}].optical_switch_channels[${n}].channel_no}
         ${in_port}    Convert To String    ${module_no}
         ${out_port}    Convert To String    ${channel_no}
         Run Keyword If    '${link_status}'=='down'   Set To Dictionary
         ...                                             ${link_failure_settings}    ${in_port}=${dummy_output_channel}
         ...    ELSE IF   '${link_status}'=='up'      Set To Dictionary    ${linkup_setting}    ${in_port}=${out_port}
    END
    ${connection}    Set Variable If    '${link_status}'=='down'     ${link_failure_settings}    ${linkup_setting}
    Switch RU And Verify Connection State    connection=${connection}

Update The Flag Whether Support 3CC
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                update the flag Of 3CC------'ca_Fdd_Any_Sa for CB002640' and 'ca_Fr1Tdd_Any_Sa for CB006138'
    [Arguments]    ${3CC_flag}=${False}    ${connection}=GNB_OAM    ${gnb_index}=0
    ...            ${timeout_for_commission}=1200    ${wait_gnb_up_timeout}=20 min
    ...            ${timeout}=300    ${is_pdl_checking_needed}=${True}
    ${flexibleCAMode}    Get The Flexible CA Mode Value
    ${ca_list}    Get The CA Support List Value
    ${tmp_list}    Create List    ca_Fdd_Any_Sa    ca_Fr1Tdd_Any_Sa
    ${status}    Run Keyword And Return Status    List Should Contain Sub List    ${ca_list}    ${tmp_list}
    ${operation}    Set Variable If    ${3CC_flag}    add    delete
    ${maxNumScellsDlFr1_param}    Set Variable If    ${3CC_flag}    maxNumScellsDlFr1=3    maxNumScellsDlFr1
#    ${result}    Run Keyword And Return Status    Should Contain Any    ${stream_version}    23R2    23R3    23R4    master
    ${result}    Set Variable If    '${stream_version}'=='23R1'    ${False}    ${True}
    ${ca_support_list1}    Catenate    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Fdd_Sa,
    ...                                ca_Fr1Tdd_Fdd_Nsa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fr1Tdd_Fdd_Sa_WithUl
    ${ca_support_list2}    Set Variable
    ...  ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Fdd_Nsa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa
    ${ca_support_3cc}    Set Variable If    ${result}    ${ca_support_list1}    ${ca_support_list2}
    ${ca_support_list3}    Catenate
    ...  ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,
    ...  ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Fdd_Nsa,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fr1Tdd_Fdd_Sa_WithUl
    ${ca_support_list4}    Set Variable
    ...  ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Fdd_Nsa
    ${ca_support_2cc}    Set Variable If    ${result}    ${ca_support_list3}    ${ca_support_list4}
    ${support_list}    Set Variable If    ${3CC_flag}    ${ca_support_3cc}    ${ca_support_2cc}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${cell_info}   coam.get_cells_info    cell_type=nr    timeout=${timeout}    connection=${connection}
    @{param_list}    Create List
    FOR    ${item}    IN    @{cell_info}
        ${maxNumScellsDlFr1_value}    coam_parameter.get_single_value_from_scf_file    parameter=maxNumScellsDlFr1
        ...                                                                            dist_name=${item['id']['configuration']}
        ...                                                                            connection=${connection}
        ...                                                                            timeout=300
        ${list_length}    Get Length    ${maxNumScellsDlFr1_value}
        Run Keyword If    ${list_length}!=${0} and '${operation}'=='delete'    Append To List
        ...    ${param_list}    ${operation}:${item['id']['configuration']}:${maxNumScellsDlFr1_param}
        Run Keyword If    ${list_length}==${0} and '${operation}'=='add'    Append To List
        ...    ${param_list}    ${operation}:${item['id']['configuration']}:${maxNumScellsDlFr1_param}
    END
#    Run Keyword If    '${flexibleCAMode}'!='ConfigurationIndependent'    Append To List
#    ...    ${param_list}    modify:NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRDU-1:flexibleCAMode=ConfigurationIndependent
    Run Keyword If    ${3CC_flag} and ${status}==${False}    Append To List
    ...    ${param_list}    modify:NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRDU-1:carrierAggregationSupportList=${support_list}
    Run Keyword If    ${3CC_flag}==${False} and ${status}    Append To List
    ...    ${param_list}    modify:NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRDU-1:carrierAggregationSupportList=${support_list}
    ${param_list_length}    Get Length    ${param_list}
    ${update_scf_with_case_params}    Run Keyword If    ${param_list_length}!=${0}
    ...    perform_update_scf_params_for_current_scf    update_params=${param_list}    connection=${connection}
    Run Keyword If    ${param_list_length}!=${0}    Perform Commission    scf_file_path=${update_scf_with_case_params}
    ...                                                                   gnb_index=${gnb_index}
    ...                                                                   timeout_for_commission=${timeout_for_commission}
    ...                                                                   wait_gnb_up_timeout=${wait_gnb_up_timeout}
    ...                                                                   is_pdl_checking_needed=${is_pdl_checking_needed}
    Run Keyword If    ${param_list_length}!=${0}    Verify TMO Gnb Ready And All Cell On Air
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Add Or Delete Scell Of All NR Cells
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                add or delete the parameter "sCellAdditionMethod" for all cell
    [Arguments]    ${param_list}    ${connection}=GNB_OAM0    ${gnb_index}=0
    ...            ${timeout_for_commission}=900    ${wait_gnb_up_timeout}=20 min
    ...            ${timeout}=300    ${is_pdl_checking_needed}=${True}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${update_scf_with_case_params}    perform_update_scf_params_for_current_scf
    ...                               update_params=${param_list}
    ...                               connection=${connection}
    Perform Commission    scf_file_path=${update_scf_with_case_params}
    ...                   gnb_index=${gnb_index}
    ...                   timeout_for_commission=${timeout_for_commission}
    ...                   wait_gnb_up_timeout=${wait_gnb_up_timeout}
    ...                   is_pdl_checking_needed=${is_pdl_checking_needed}
    Verify TMO Gnb Ready And All Cell On Air
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get The Parameter List Of NRREL Config
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM0    ${gnb_index}=0
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${nrrel_mos}    gnbaction.get_nrrel_config
    @{delete_param_list}    Create List
    @{add_param_list}    Create List
    FOR    ${mo}    IN    @{nrrel_mos}
        ${nrcell_id}    Set Variable    ${mo['distName'].split('/')[-2].split('-')[-1]}
        ${nrrel_id}    Set Variable    ${mo['distName'].split('/')[-1].split('-')[-1]}
        ${dist_name}    Set Variable    NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${nrcell_id}/NRREL-${nrrel_id}
        ${sCellAdditionMethod_status}    Run Keyword And Return Status
        ...    Should Contain Any    ${mo['parameters']['sCellAdditionMethod']}    covBasedA1    blind
        Run Keyword If    ${sCellAdditionMethod_status}    Run Keywords
        ...    Append To List    ${delete_param_list}    delete:${dist_name}:sCellAdditionMethod    AND
        ...    Append To List    ${add_param_list}    add:${dist_name}:sCellAdditionMethod=${mo['parameters']['sCellAdditionMethod']}
        ${sCellOperationalMode_status}    Run Keyword And Return Status
        ...    Should Contain Any    ${mo['parameters']['sCellOperationalMode']}    dlOnly    dlandUl
        Run Keyword If    ${sCellOperationalMode_status}    Run Keywords
        ...    Append To List    ${delete_param_list}    delete:${dist_name}:sCellOperationalMode    AND
        ...    Append To List    ${add_param_list}    add:${dist_name}:sCellOperationalMode=${mo['parameters']['sCellOperationalMode']}
    END
    [Return]    ${delete_param_list}    ${add_param_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Do All RU Locked Or Unlocked On Gnb
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    ...    para:${ru_status}  value can be "Locked or Unlocked"
    [Arguments]     ${ru_status}   ${connection}=GNB_OAM    ${timeout}=600   ${enb_connection}=enblte   ${enb_index}=${1}
    ...             ${gnb_id}=${0}
    ${lte_whether_in_gnb}    Check LTE Whether In Gnb
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    &{fault_1931}     Create Dictionary     faultId=${1931}
    ${ENB_ALLOWED_FAULT}    Create List    @{GNB_ALLOWED_FAULT}    ${fault_1931}
    @{ru_list}    Create List
    ${hw_info}    coam.get_detected_hw_info    connection=GNB_OAM
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    @{ru_list}    Create List
    FOR  ${ru}  IN  @{list_RUs}
        log to console   ${ru}
        ${rmod_index}   Set variable   ${ru['id']['configuration']}
        ${ru_index}   Set variable    ${rmod_index.split('RMOD-')[-1]}
        Append To List    ${ru_list}    ${ru_index}
    END
    FOR    ${ru_init_index}    IN    @{ru_list}
        ${ru_index}    Evaluate    int(${ru_init_index})
        Run Keyword If   '${ru_status}'=='Locked'    coam.lock    connection=${connection}
        ...    dist_name=MRBTS-${tl.gnbs[${gnb_id}].global_bts_id}/EQM-1/APEQM-1/RMOD-${ru_index}   timeout=${timeout}
        Run Keyword If   '${ru_status}'=='Unlocked'  coam.unlock   connection=${connection}
        ...    dist_name=MRBTS-${tl.gnbs[${gnb_id}].global_bts_id}/EQM-1/APEQM-1/RMOD-${ru_index}   timeout=${timeout}
        &{status}    Run Keyword If   '${LTE_WHETHER_IN_GNB}'=='${False}'   COAM get ru detial info by ru index
        ...                         ru_index=${ru_index}   connection=${connection}
        Run Keyword If   '${LTE_WHETHER_IN_GNB}'=='${False}' and '${ru_status}'=='Locked'
        ...              Should be equal as strings    ${status['status']['administrativeState']}    Locked
        Run Keyword If   '${LTE_WHETHER_IN_GNB}'=='${False}' and '${ru_status}'=='Unlocked'
        ...              Should be equal as strings    ${status['status']['administrativeState']}    Unlocked
        Run Keyword If   '${ru_status}'=='Locked'    run keyword and continue on failure    Wait Until Keyword Succeeds
        ...    180 sec    3 sec    RU Should Be Locked    ru_index=${ru_index}    connection=${connection}
        Run Keyword If   '${ru_status}'=='Unlocked'   run keyword and continue on failure    Wait Until Keyword Succeeds
        ...    400 sec    3 sec    RU Should Be Unlocked    ru_index=${ru_index}    connection=${connection}
        Run Keyword And Continue On Failure      Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}
    END
    Run Keyword If    '${LTE_WHETHER_IN_GNB}'=='${False}'    Connect to eNB via ssl    connection=${enb_connection}
    ...                                                         enb_index=${enb_index}
    Run Keyword If   '${LTE_WHETHER_IN_GNB}'=='${False}' and '${ru_status}'=='Locked'    Run Keyword And Continue On Failure
        ...    Unexpect Alarm Should Not Exist    allowed_faults=${ENB_ALLOWED_FAULT}    connection=${enb_connection}
    Run Keyword If   '${LTE_WHETHER_IN_GNB}'=='${False}' and '${ru_status}'=='Unlocked'    Run Keyword And Continue On Failure
    ...    Unexpect Alarm Should Not Exist    allowed_faults=${ENB_ALLOWED_FAULT}    connection=${enb_connection}
#    Run Keyword If    '${LTE_WHETHER_IN_GNB}'=='${False}'    Connect to eNB via ssl    connection=${enb_connection}
#    ...                                                         enb_index=${enb_index}
    Run Keyword If    '${LTE_WHETHER_IN_GNB}'=='${False}' and '${ru_status}'=='Locked'    Run Keyword And Continue On Failure
    ...    Wait For Expect Fault Present  faultId=${1931}  timeout=${timeout}  connection=${enb_connection}
    ...                                   is_need_to_setup_gnb_connection=${False}
    Run Keyword If   '${LTE_WHETHER_IN_GNB}'=='${False}' and '${ru_status}'=='Unlocked'    Run Keyword And Continue On Failure
    ...    Wait For Expect Fault To Disappear   faultId=${1931}  timeout=${timeout}    connection=${enb_connection}
    ...                                         is_need_to_setup_gnb_connection=${False}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}   AND
    ...           Run Keyword If    '${LTE_WHETHER_IN_GNB}'=='${False}'   Run Keyword And Ignore Error
    ...                                                   Enblte close down    connection=${enb_connection}

TOL PCell Locked or Unlock on gNB
    [Documentation]  Author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=120    ${cell_idx}=1    ${cell_perform}=lock
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    300 sec    5 sec    Connect to gnb coam via ssl
    ${cellgrp_id}    Get Cell Group From Cell    cell_id=${cell_idx}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist
                             ...    allowed_faults=@{ALLOWED_FAULT}    connection=${connection}
    Run Keyword If   '${cell_perform}'=='lock'    Perform cell lock via rest api    cell_idx=${cell_idx}    timeout=${timeout}
    Run Keyword If   '${cell_perform}'=='lock'    Wait Until Keyword Succeeds    90 sec    3 sec    Cell Should Be Locked
                                 ...    cell_idx=${cell_idx}    cell_group_idx=${cellgrp_id}
                                 ...    connection=${connection}
    Run Keyword If   '${cell_perform}'=='unlock'   Perform cell unlock via rest api    cell_idx=${cell_idx}    timeout=${timeout}
    Run Keyword If   '${cell_perform}'=='unlock'   Wait Until Keyword Succeeds    600 sec    3 sec    Cell Should Be Unlocked
                                 ...    cell_idx=${cell_idx}
                                 ...    cell_group_idx=${cellgrp_id}
                                 ...    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

Lock Or Unlock Or Reset BBMOD
    [Documentation]    tingting.1.liu@nokia-sbell.com
    [Arguments]         ${cell_index}    ${expect_bbmod_status}   ${gnb_connection}=GNB_OAM0
    ...     ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}   ${cell_type}=nr   ${timeout}=300
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl   connection=${gnb_connection}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='0'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'=='lte'
    ...    ${enb_connection}    ${gnb_connection}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        ${rmod_info}    Get From List    ${item['carrierList']}    0
        ${rmod_id}    Get Regexp Matches    ${rmod_info['antennaLineId']['configuration']}    RMOD-(\\d+)    1
        ${cell_id}    Set variable    ${item['id']['configuration'].split('-')[-1]}
        Set To Dictionary    ${cell_list_info}    ${cell_id}=${rmod_id}[0]
    END
    ${cell_index}    Convert To string    ${cell_index}
    ${cell_rmod_index}   get from dictionary   ${cell_list_info}   ${cell_index}
    ${rmod_mapping}    coam.get_detected_hw_info   connection=${connection}
    ${rmod_bbmod_mapping}   get from dictionary   ${rmod_mapping}   cables
    &{rmod_bbmod_list_info}    Create Dictionary
    &{bbmod_linkmode_list_info}    Create Dictionary
    FOR  ${bbmod}   IN  @{rmod_bbmod_mapping}
        ${rmod_port_id}    Get Regexp Matches    ${bbmod['secondEndPointId']['configuration']}   RMOD-(\\d+)    1
        ${bbmod_port_id}   Get Regexp Matches    ${bbmod['firstEndPointId']['configuration']}    BBMOD-(\\d+)    1
        ${bbmod_port_num}   Get Length  ${bbmod_port_id}
        Run Keyword If    '${bbmod_port_num}'!='0'
        ...                       Set To Dictionary    ${rmod_bbmod_list_info}    ${rmod_port_id}[0]=${bbmod_port_id}[0]
    END
    ${expect_bbmod}   get from dictionary   ${rmod_bbmod_list_info}   ${cell_rmod_index}
    FOR  ${bbmod}   IN  @{rmod_bbmod_mapping}
        ${bbmod_port_id}   Get Regexp Matches    ${bbmod['firstEndPointId']['configuration']}    BBMOD-(\\d+)    1
        ${bbmod_port_id_length}    Get Length    ${bbmod_port_id}
        ${linkmode_status}   Set Variable       ${bbmod['linkMode']['configuration']}
        Run Keyword If    '${linkmode_status}'=='True' and '${bbmod_port_id_length}'!='${0}'
        ...          Set To Dictionary    ${bbmod_linkmode_list_info}    ${bbmod_port_id}[0]=${linkmode_status}
    END
    ${whether_linkmode_contain_mplane}   Run Keyword And Return Status    get from dictionary   ${bbmod_linkmode_list_info}   ${expect_bbmod}
    ${bbmod_linkmode_status}   Set Variable If      ${whether_linkmode_contain_mplane}      True      false
    ${output}   coam.get_fbb_info   connection=${connection}
    @{bbmod_list_lockunlock}   Create List
    @{bbmod_list_reset}   Create List
    FOR  ${bbmod_info}   IN  @{output}
        ${bbmod_number}   Set Variable   ${bbmod_info['id']['configuration'].split('-')[-1]}
        &{bbmod_number_dict}   create dictionary   ${bbmod_number}=${bbmod_info['id']['runtime']}
        Append To List    ${bbmod_list_lockunlock}    ${bbmod_number_dict}
    END
    FOR  ${bbmod_info}   IN  @{output}
        ${bbmod_number}   Set Variable   ${bbmod_info['id']['configuration'].split('-')[-1]}
        &{bbmod_number_dict}   create dictionary   ${bbmod_number}=${bbmod_info['id']['internal']}
        Append To List    ${bbmod_list_reset}    ${bbmod_number_dict}
    END
    ${bbmod_list}    Set Variable If       '${expect_bbmod_status}'=='reset'   ${bbmod_list_reset}    ${bbmod_list_lockunlock}
    FOR   ${bbmod}  IN   @{bbmod_list}
        ${bbmod_configuration_name_list}   Get Dictionary Keys   ${bbmod}
        ${bbmod_configuration_name}   Set Variable   ${bbmod_configuration_name_list[0]}
        ${bbmod_runtime_name_list}   get dictionary values   ${bbmod}
        ${bbmod_runtime_name}   Set Variable   ${bbmod_runtime_name_list[0]}
        Run Keyword If   '${bbmod_configuration_name}'=='${expect_bbmod}'   Run Keywords
        ...   Set Test Variable   ${dict_name}   ${bbmod_runtime_name}   AND  Exit For Loop
    END
    Run Keyword If   '${expect_bbmod_status}'=='Locked'     Wait Until Keyword Succeeds    20 min    5 sec    coam.lock
    ...                                         dist_name=${dict_name}   connection=${connection}
    ...   ELSE IF   '${expect_bbmod_status}'=='Unlocked'    Wait Until Keyword Succeeds    20 min    5 sec    coam.unlock
    ...                                         dist_name=${dict_name}   connection=${connection}
    ...   ELSE IF   '${expect_bbmod_status}'=='reset'       coam.reset_unit    dist_name=${dict_name}
    ...                                         reset_type=Warm   connection=${connection}   timeout=${timeout}
    ${output2}   coam.get_fbb_info   connection=${connection}
    &{bbmod_status_dict}   create dictionary
    FOR  ${bbmod_info}   IN  @{output2}
        Run Keyword If  '${bbmod_info['id']['runtime']}'=='${dict_name}'    Set To Dictionary   ${bbmod_status_dict}
        ...             administrativeState=${bbmod_info['status']['administrativeState']}
        ...             operationalState=${bbmod_info['status']['operationalState']}
        ...             usageState=${bbmod_info['status']['usageState']}
#        Run Keyword If  '${bbmod_info['id']['internal']}'=='${dict_name}'    Set To Dictionary   ${bbmod_status_dict}
#        ...             administrativeState=${bbmod_info['status']['administrativeState']}
#        ...             operationalState=${bbmod_info['status']['operationalState']}
#        ...             usageState=${bbmod_info['status']['usageState']}
    END
    run keyword if   '${expect_bbmod_status}'=='Locked'    Wait Until Keyword Succeeds    10 min    5 sec
    ...      Should Be Equal As Strings    ${bbmod_status_dict['administrativeState']}    Locked
    ...    ELSE IF   '${expect_bbmod_status}'=='Unlocked'    Wait Until Keyword Succeeds    10 min    5 sec
    ...      Should Be Equal As Strings    ${bbmod_status_dict['administrativeState']}    Unlocked
#    ...    ELSE IF   '${expect_bbmod_status}'=='reset'    Wait Until Keyword Succeeds    10 min    5 sec
#    ...      Should Be Equal As Strings    ${bbmod_status_dict['operationalState']}       disabled
    [Return]     ${bbmod_linkmode_status}
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}   AND
    ...    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='0'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

COAM get ru cable port number and linkmode type
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...                get ru opt id and linkmode for each ru, for example:
    ...                OPT_IF4: configuration, OPT_IF3: data, OPT_IF2: data, OPT_IF1: data
    [Arguments]    ${ru_index}=1    ${connection}=GNB_OAM
    ${hw_info_mapping}    coam.get_detected_hw_info   connection=${connection}
    ${cables_mapping}   get from dictionary   ${hw_info_mapping}   cables
    &{rmod_linkmode_list_info}    Create Dictionary
    FOR  ${cable}   IN  @{cables_mapping}
        ${rmod_port_id}    Get Regexp Matches    ${cable['secondEndPointId']['configuration']}   RMOD-(\\d+)    1
        ${bbmod_port_id}   Get Regexp Matches    ${cable['firstEndPointId']['configuration']}    BBMOD-(\\d+)    1
        Run Keyword If    '${rmod_port_id}[0]'=='${ru_index}'    COAM get cable linkmode type
        ...            cable=${cable}    connection=${connection}     rmod_linkmode_list_info=${rmod_linkmode_list_info}
    END
    [Return]    ${rmod_linkmode_list_info}


Get fiber switch port for linkmode type data
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...                for example:
    ...                OPT_IF4: configuration, OPT_IF3: data, OPT_IF2: data, OPT_IF1: data
    [Arguments]    ${rmod_linkmode_list_info}
    ${opt_index_list}    Get Dictionary Keys    ${rmod_linkmode_list_info}
    ${rmod_data_cables_used_channel}    Create List
    FOR    ${opt_index}    IN    @{opt_index_list}
        ${fiber_switch_no_list}    Set Variable
        ...        ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']['OPT${opt_index}_fiber_switch_channel']}
        ${rmod_data_cables_used_channel} 	Run Keyword If    '${rmod_linkmode_list_info['${opt_index}']}'=='data'
        ...    Combine Lists    ${rmod_data_cables_used_channel} 	${fiber_switch_no_list}
        ...    ELSE    Set Variable    ${rmod_data_cables_used_channel}
    END
    [Return]    ${rmod_data_cables_used_channel}

COAM get cable linkmode type
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...                get ru linkmode type for each ru, for example:
    ...                configuration, data
    [Arguments]    ${cable}    ${rmod_linkmode_list_info}    ${connection}=GNB_OAM
    ${linkmode_status}   Set Variable       ${cable['linkMode']['configuration']}
    ${rmod_opt_port_num}   Get Regexp Matches    ${cable['secondEndPointId']['configuration']}   OPT_IF(\\d+)    1
    ${linkmode}    Set Variable If    '${linkmode_status}'=='True'    configuration    data
    Set To Dictionary    ${rmod_linkmode_list_info}    ${rmod_opt_port_num}[0]=${linkmode}

Get BBMOD List For RU AEHC Or AZHL
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM0    ${gnb_index}=${0}    ${du_index}=${0}
    ${ru_list}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus}
    ${sn_list_of_special_ru}    Create List
    FOR    ${ru}    IN    @{ru_list}
        ${ru_index}    Get Index From List    ${ru_list}    ${ru}
        ${sn}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].serial_number}
        ${status}    Run Keyword And Return Status   Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type.value}
        ${ru_type}    Set Variable If    ${status}    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type.value}
        ...                                           ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type}
        Run Keyword If    '${ru_type}'=='AEHC' or '${ru_type}'=='AZHL'    Append To List    ${sn_list_of_special_ru}    ${sn}
    END
    Wait Until Keyword Succeeds    2 min    20 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${rmod_sn_mapping}    gnbaction.get_rmod_sn_mapping
    ${rmod_index_list}    Get Dictionary Keys    ${rmod_sn_mapping}
    ${rmod_list_of_special_ru}    Create List
    FOR    ${rmod_index}    IN    @{rmod_index_list}
        ${serial_number}    Set Variable    ${rmod_sn_mapping['${rmod_index}']}
        ${status}    Run Keyword And Return Status    List Should Contain Value    ${sn_list_of_special_ru}    ${serial_number}
        Run Keyword If    ${status}    Append To List    ${rmod_list_of_special_ru}    ${rmod_index}
    END
    ${rmod_bbmod_mapping}    gnbaction.get_rmod_bbmod_mapping
    ${bbmod_list_of_special_ru}    Create List
    FOR    ${rmod}    IN    @{rmod_list_of_special_ru}
        ${vlaue_list}    Get From Dictionary    ${rmod_bbmod_mapping}    ${rmod}
        ${bbmod_list_of_special_ru}    Combine Lists    ${bbmod_list_of_special_ru}    ${vlaue_list}
        ${bbmod_list_of_special_ru}    Remove Duplicates    ${bbmod_list_of_special_ru}
    END
    ${bbmod_distname_list}    Create List
    ${output}   coam.get_fbb_info   connection=${connection}
    FOR  ${bbmod_info}   IN  @{output}
        ${bbmod_number}   Set Variable   ${bbmod_info['id']['configuration'].split('-')[-1]}
        ${status}    Run Keyword And Return Status    List Should Contain Value    ${bbmod_list_of_special_ru}    ${bbmod_number}
        Run Keyword If    ${status}    Append To List    ${bbmod_distname_list}    ${bbmod_info['id']['internal']}
    END
    [Return]     ${bbmod_distname_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get BBMOD List For All FDD RU
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM0    ${gnb_index}=${0}    ${du_index}=${0}
    ${ru_list}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus}
    ${sn_list_of_special_ru}    Create List
    FOR    ${ru}    IN    @{ru_list}
        ${ru_index}    Get Index From List    ${ru_list}    ${ru}
        ${sn}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].serial_number}
        ${status}    Run Keyword And Return Status   Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type.value}
        ${ru_type}    Set Variable If    ${status}    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type.value}
        ...                                           ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type}
        Run Keyword If    '${ru_type}'!='AEHC' and '${ru_type}'!='AZHL'    Append To List    ${sn_list_of_special_ru}    ${sn}
    END
    Wait Until Keyword Succeeds    2 min    20 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${rmod_sn_mapping}    gnbaction.get_rmod_sn_mapping
    ${rmod_index_list}    Get Dictionary Keys    ${rmod_sn_mapping}
    ${rmod_list_of_special_ru}    Create List
    FOR    ${rmod_index}    IN    @{rmod_index_list}
        ${serial_number}    Set Variable    ${rmod_sn_mapping['${rmod_index}']}
        ${status}    Run Keyword And Return Status    List Should Contain Value    ${sn_list_of_special_ru}    ${serial_number}
        Run Keyword If    ${status}    Append To List    ${rmod_list_of_special_ru}    ${rmod_index}
    END
    ${rmod_bbmod_mapping}    gnbaction.get_rmod_bbmod_mapping
    ${bbmod_list_of_special_ru}    Create List
    FOR    ${rmod}    IN    @{rmod_list_of_special_ru}
        ${vlaue_list}    Get From Dictionary    ${rmod_bbmod_mapping}    ${rmod}
        ${bbmod_list_of_special_ru}    Combine Lists    ${bbmod_list_of_special_ru}    ${vlaue_list}
        ${bbmod_list_of_special_ru}    Remove Duplicates    ${bbmod_list_of_special_ru}
    END
    ${bbmod_distname_list}    Create List
    ${output}   coam.get_fbb_info   connection=${connection}
    FOR  ${bbmod_info}   IN  @{output}
        ${bbmod_number}   Set Variable   ${bbmod_info['id']['configuration'].split('-')[-1]}
        ${status}    Run Keyword And Return Status    List Should Contain Value    ${bbmod_list_of_special_ru}    ${bbmod_number}
        Run Keyword If    ${status}    Append To List    ${bbmod_distname_list}    ${bbmod_info['id']['internal']}
    END
    [Return]     ${bbmod_distname_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get RMOD List For Special RU
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ru_type}=AEHC    ${connection}=GNB_OAM0    ${gnb_index}=${0}    ${du_index}=${0}
    Wait Until Keyword Succeeds    2 min    20 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${rmod_distname_list}    Create List
    ${output}   coam.get_frm    timeout=60    connection=${connection}
    FOR  ${rmod_info}   IN  @{output}
        ${productName}   Set Variable   ${rmod_info['productName']}
        Run Keyword If    '${productName}'=='${ru_type}'    Append To List    ${rmod_distname_list}    ${rmod_info['id']['configuration']}
    END
    [Return]     ${rmod_distname_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check Unexpect Alarm And Trunk Roll
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM0
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${0}
    ${status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}
    ...                                                                              connection=${connection}
    Run Keyword If    not ${status}    Run Keywords
    ...    Common_keywords.Collect Snapshot Log    connection=${connection}    gnb_index=${0}    timeout=${2400}    AND
    ...    Fail    msg=Collected snapshot logs because of unexpect alarm happened.
    Check Truck Roll Alarm And Stop Robot Testing    connection=${connection}
    [Return]     ${status}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check GNB On Air And Unexpect Alarm Should Not Exist
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM0    ${is_check_cell_onAir}=${True}
    ${status}    Run Keyword If    ${is_check_cell_onAir}    Run Keyword And Return Status    Verify TMO Gnb Ready And All Cell On Air
    Run Keyword If    ${is_check_cell_onAir} and not ${status}    Run Keywords
    ...    Common_keywords.Collect Snapshot Log    connection=${connection}    gnb_index=${0}    timeout=${2400}    AND
    ...    Fail    msg=Collected snapshot logs because of cells not on air.
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${0}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}
    ...                                                                              connection=${connection}
#    Run Keyword If    not ${status}    Run Keywords
#    ...    Common_keywords.Collect Snapshot Log    connection=${connection}    gnb_index=${0}    timeout=${2400}    AND
#    ...    Fail    msg=Collected snapshot logs because of unexpect alarm happened.
    Check Truck Roll Alarm And Stop Robot Testing    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check ENB On Air And Unexpect Alarm Should Not Exist
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=enblte    ${is_check_cell_onAir}=${True}
    ${enb_length}    Get Length    ${tl.enbs}
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Run Keyword If    ${is_check_cell_onAir}    Wait Until Keyword Succeeds    10 min    20 sec
        ...    Verify Enb All Cell On Air    enb_index=${enb_index}
        Wait Until Keyword Succeeds    2 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${connection}
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}
        ...                                                                              connection=${connection}
#        Run Keyword If    not ${status}    Run Keywords
#        ...    Common_keywords.Collect Enb Snapshot Log    enb_index=${enb_index}    connection=${connection}    timeout=${2400}    AND
#        ...    Fail    msg=Collected snapshot logs because of unexpect alarm happened.
        Check Truck Roll Alarm And Stop Robot Testing    connection=${connection}
        Run Keyword And Ignore Error    Enblte close down    connection=${connection}
    END
    [Teardown]    Run Keyword And Ignore Error    Enblte close down    connection=${connection}

Check Truck Roll Alarm And Stop Robot Testing
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM0
    @{fault}    Create List    ${10}    ${16}    ${1806}    ${1868}    ${4341}    ${4352}    ${4383}
    ${active_alarms}    coam.get_active_alarms    connection=${connection}
    FOR   ${active_alarm}    IN   @{active_alarms}
        ${roll}    Run Keyword And Return Status    List Should not Contain Value    ${fault}    ${active_alarm['faultId']}
        Run Keyword If    not ${roll}    Fatal Error    msg=Fault ${active_alarm['faultId']}, possible truck roll issue, case failed!!!!!
    END

Lock Or Unlock NG Links In vCU
    [Documentation]    tingting.1.liu@nokia-sbell.com
    ...     para:  ${expected_value} should be 'Locked' or 'Unlocked'
    [Arguments]    ${gnb_index}=0    ${connection}=GNB_OAM
    ...            ${expected_value}=Locked   ${timeout}=300
    ...            ${ru_type}=AHFIG
    ...            ${cell_type}=nr
    ...            ${allowed_faults}=${GNB_ALLOWED_FAULT}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    @{SERVEDAMF_A}    coam.get_managed_objects    class_name=SERVEDAMF_A    connection=${connection}
    ${amf_numbers}    Get Length     ${SERVEDAMF_A}
    Run keyword and ignore error    COAM Teardown gnb connections
    FOR    ${amf_num}   IN RANGE    1      ${amf_numbers}+1
        Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
        Run Keyword If    '${expected_value}'=='Locked'   Wait Until Keyword Succeeds    3 min    5 sec    coam.lock_ng_link
        ...      dist_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/SERVEDAMF-${amf_num}
        ...      timeout=${timeout}   connection=${connection}
        ...    ELSE IF    '${expected_value}'=='Unlocked'   Wait Until Keyword Succeeds    3 min    5 sec    coam.unlock_ng_link
        ...      dist_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/SERVEDAMF-${amf_num}
        ...      timeout=${timeout}   connection=${connection}
        ${ngLinkStatus}    Set Variable If     '${expected_value}'=='Locked'     Inactive    Active
        Run Keyword And Continue On Failure        Verify SERVEDAMF Status On GNB
        ...          administrativeState=${expected_value}    target_amf_number=${amf_num}   ngLinkStatus=${ngLinkStatus}
        ...          ru_type=${ru_type}    cell_type=${cell_type}    expected_value=${expected_value}
        ...          allowed_faults=${allowed_faults}
    END
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Perform BBMOD From AEHC Or AZHL Reset
    [Documentation]    tingting.1.liu@nokia-sbell.com
    ${bbmod_distname_list}    Get BBMOD List For RU AEHC Or AZHL
    FOR    ${bbmod_distname}    IN    @{bbmod_distname_list}
        Wait Until Keyword Succeeds    2 min    20 sec    Connect to gnb coam via ssl    connection=GNB_OAM0
        ...                                                                              gnb_index=${0}
        coam.reset_unit    dist_name=${bbmod_distname}    reset_type=Warm    force_radio_reset=${True}
        ...                timeout=${300}    connection=GNB_OAM0
        Check GNB On Air And Unexpect Alarm Should Not Exist
        Check ENB On Air And Unexpect Alarm Should Not Exist
    END
    [Teardown]   Teardown GNB and ENB Connections

#--- Common Procedures KW ---#
Convert Dl Tput based on Process num
    [Documentation]  author: lei.jia@nokia-sbell.com.
    ...    2024.05.06: due to appserver issue, cannot send traffic larger than 1800M, using -P=2 instead
    ...    if ${process_num}=1, ${dl_throughput}=2500M, -P 1 -f m -b 2500M
    ...    if ${process_num}=2, ${dl_throughput}=2500M, -P 2 -f m -b 1250M
    [Arguments]        ${process_num}=${2}    ${dl_throughput}=2500MKbits/sec
    ${tput_value}    Get Regexp Matches    ${dl_throughput}    (\\d+\.?\\d)    1
    ${used_tput_value}    Evaluate       int(int(${tput_value[0]})/${process_num})
    ${tputstring}    Fetch From Right    ${dl_throughput}    ${tput_value[0]}
    ${dl_throughput}    Set Variable    ${used_tput_value}${tputstring}
    [Return]    ${dl_throughput}

Procedures.Verify CA Basic L3 Call
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    ...            ${ue_type}=${ue_type}
    ...            ${ue_mode}=SA
    ...            ${gnb_index}=${0}
    ...            ${du_index}=0
    ...            ${hwcheck_index}=${1}
    ...            ${detach_request}=${true}
    ...            ${power_reset}=False
    ...            ${5Gstatus}=PASS
    ...            ${scell_addition_method}=A1
    ...            ${ul_throughput}=150M
    ...            ${dl_throughput}=2500MKbits/sec
    ...            ${protocol}=udp
    ...            ${start_keep_on_duration}=1200
    ...            ${tput_collect_duration}=180
    ...            ${check_pcell_tput_type}=peak
    ...            ${check_scell_tput_type}=peak
    ...            ${check_ul_pcell_tput_type}=peak
    ...            ${target_DL_avg_percent}=0.9
    ...            ${target_UL_avg_percent}=0.9
    ...            ${min_DL_percent}=0.5
    ...            ${min_UL_percent}=0.5
    ...            ${whether_check_scell_addition}=${False}
    ...            ${whether_do_barred_action}=${True}
    ...            ${whether_check_on_air}=${True}
    ...            ${whether_do_ue_prepare}=${False}
    ...            ${whether_check_tupt}=${True}
    ...            ${expect_tp_percent}=1
    ...            ${notbarred_cell_index}=${PCELL_INDEX}
    ...            ${b1_select_cell_index}=${PCELL_INDEX}
    ...            ${expect_addition_scell_indexs}=${SCELL_INDEX_LIST}
    ...            ${pcell_mapping}=${PCELL_MAPPING}
    ...            ${scell_mapping}=${SCELL_MAPPING}
    ...            ${exp_status}=notBarred
    ...            ${apn_address}=${tl.core.pdns[0].apn}
    ...            ${whether_need_ue_log}=${True}
    ...            ${ignore_time}=1min
    ...            ${whether_do_lte_barred_action}=${False}
    ...            ${lte_exp_status}=notBarred
    ...            ${enb_wireshark_log_prefix}=enb_wireshark_log
    ...            ${enb_index}=${1}
    ...            ${common_unit_index}=${0}
    ...            ${sleep_interval}=35 sec
    ...            ${check_pcell_tput}=${True}
    ...            ${check_scell_tput}=${True}
    ...            ${whether_start_dl_call}=${True}
    ...            ${whether_start_ul_call}=${True}
    ...            ${ue_iperf_path}=/data/local/tmp/iperf
    ...            ${dl_process_num}=${2}
    ...            ${list_cell_ids}=${LTE_CELL_INDEX}
    ...            ${whether_do_lte_cell_locked}=${False}
    ...            ${min_scell_percent}=0.05
    ...            ${whether_change_fren}=${True}
    ...            ${whether_DL_nonGBR}=${False}
    ...            ${whether_check_scell_ul_tupt}=${False}
    ...            ${special_scell_index_for_UL}=None
    ...            ${get_spark_license}=${true}
    ${dl_throughput}    Convert Dl Tput based on Process num    process_num=${dl_process_num}    dl_throughput=${dl_throughput}
    Run Keyword If   '${ue_mode}'=='NSA'    Get RU Index Of LTE Cell    cell_index=${list_cell_ids}
    ...                                                                 gnb_id=${gnb_index}
    ...                                                                 enb_index=${enb_index}
    Run Keyword If   '${ue_mode}'=='NSA'    Modify PA Value Setting For Required RU    modify_ru_id=${NSA_PA_RU_INDEX}
    ...                                                                                ue_index=${ue_index}
    Run Keyword If   '${LTE_WHETHER_IN_GNB}'=='${False}' and '${ue_mode}'=='NSA'    Change cellBarred Parameter Value Of Lte Cells
    ...    list_cell_ids=all    exp_status=barred    enb_index=${0}
    Run Keyword If    ${whether_do_lte_barred_action}    Change cellBarred Parameter Value Of Lte Cells
    ...                                                      list_cell_ids=${list_cell_ids}
    ...                                                      exp_status=${lte_exp_status}
    ...                                                      enb_index=${enb_index}
    Run Keyword If    ${whether_do_barred_action}    Change cellBarred Parameter Value On Gnb    pcell_index=${notbarred_cell_index}
    ...                                                                                          exp_status=${exp_status}
    Run Keyword If   '${ue_mode}'=='NSA' and ${whether_change_fren}
    ...               Update Priority Of NR Frequency Band In ENDCDMEASCONF    cell_index=${b1_select_cell_index}
    ...                                                                        enb_index=${enb_index}
    Run Keyword If    ${whether_check_on_air}    Verify TMO Gnb Ready And All Cell On Air
    Run Keyword If    ${whether_do_lte_cell_locked} and '${tl_prefix}'=='T813'      Do All TDD-LTE Cells Action
    ${power_reset}    Set Variable If    'spark' in '${ue_type}'    true    ${power_reset}
    Run Keyword If    ${whether_do_ue_prepare}    Procedures.Start UE Prepare    ue_index=${ue_index}    ue_type=${ue_type}
    ...                                           detach_request=${detach_request}      power_reset=${power_reset}
    ...                                           get_spark_license=${get_spark_license}
    Run Keyword If    ${whether_need_ue_log} and '${ue_type}'=='huawei_sigspark'    Run Keyword And Continue On Failure
    ...    Spark_common_keywords.Spark Start UE Log    ue_index=${ue_index}
    ${4G_check}    Set Variable If    '${ue_mode}'=='NSA'    True    False
    ${attach_info}    Procedures.Start TMO Attach    ue_mode=${ue_mode}
    ...                                              ue_type=${ue_type}
    ...                                              ue_index=${ue_index}
    ...                                              enb_wireshark_log_prefix=${enb_wireshark_log_prefix}
    ...                                              enb_index=${enb_index}
    ...                                              common_unit_index=${common_unit_index}
    ...                                              sleep_interval=${sleep_interval}
    ...                                              gnb_index=${gnb_index}
    ...                                              du_index=${du_index}
    ...                                              4G_check=${4G_check}
    ...                                              5Gstatus=${5Gstatus}
    ...                                              hwcheck_index=${hwcheck_index}
    ...                                              power_reset=${power_reset}
    ${attach_cell_index}    Set Variable If    '${ue_mode}'=='NSA'    ${b1_select_cell_index}    ${notbarred_cell_index}
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${attach_info['attach_cell_index']}    ${attach_cell_index}
    ${addition_scell_index_list}    Run Keyword If    ${whether_check_scell_addition}
    ...    Run Keyword And Continue On Failure    Procedures.Check TMO Scell Addition
    ...                                               attach_info=${attach_info}
    ...                                               ue_mode=${ue_mode}
    ...                                               expect_addition_scell_indexs=${expect_addition_scell_indexs}
    ...                                               scell_addition_method=${scell_addition_method}
    ...                                               pcell_mapping=${pcell_mapping}
    ...                                               scell_mapping=${scell_mapping}
    ${attach_wireshark}    Set Variable If    '${ue_mode}'=='NSA'
    ...    ${attach_info['enb_wireshark_log_path']}
    ...    ${attach_info['cpif_log_path']}
    Procedures.Start TMO L3 Call    cpif_log_path=${attach_wireshark}
    ...                             ue_mode=${ue_mode}
    ...                             ue_index=${ue_index}
    ...                             protocol=${protocol}
    ...                             start_keep_on_duration=${start_keep_on_duration}
    ...                             ul_throughput=${ul_throughput}
    ...                             dl_throughput=${dl_throughput}
    ...                             apn_address=${apn_address}
    ...                             whether_start_dl_call=${whether_start_dl_call}
    ...                             whether_start_ul_call=${whether_start_ul_call}
    ...                             iperf_path=${ue_iperf_path}
    ...                             dl_process_num=${dl_process_num}
    ...                             ue_type=${ue_type}
    ...                             whether_DL_nonGBR=${whether_DL_nonGBR}
    ${check_ul_pcell_tput_type}    Set Variable If    '${ue_mode}'=='NSA' or '${ue_type}'=='samsung'    layer1    ${check_ul_pcell_tput_type}
    Run Keyword If    ${whether_check_tupt}    Procedures.Check TMO Throughput    ue_index=${ue_index}
    ...                                                                           addition_scell_index_list=${expect_addition_scell_indexs}
    ...                                                                           tput_collect_duration=${tput_collect_duration}
    ...                                                                           expect_tp_percent=${expect_tp_percent}
    ...                                                                           ignore_time=${ignore_time}
    ...                                                                           check_pcell_tput_type=${check_pcell_tput_type}
    ...                                                                           check_scell_tput_type=${check_scell_tput_type}
    ...                                                                           check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                                                                           check_pcell_tput=${check_pcell_tput}
    ...                                                                           check_scell_tput=${check_scell_tput}
    ...                                                                           ue_type=${ue_type}
    ...                                                                           pcell_mapping=${pcell_mapping}
    ...                                                                           scell_mapping=${scell_mapping}
    ...                                                                           target_DL_avg_percent=${target_DL_avg_percent}
    ...                                                                           target_UL_avg_percent=${target_UL_avg_percent}
    ...                                                                           min_DL_percent=${min_DL_percent}
    ...                                                                           min_UL_percent=${min_UL_percent}
    ...                                                                           min_scell_percent=${min_scell_percent}
    ...                                                                           whether_check_scell_ul_tupt=${whether_check_scell_ul_tupt}
    ...                     	                                                  special_scell_index_for_UL=${special_scell_index_for_UL}
    [Return]    ${attach_info}
    [Teardown]    Run Keywords    Run Keyword If    ${whether_need_ue_log} and '${ue_type}'=='huawei_sigspark'    Run Keyword And Ignore Error
    ...    Spark_common_keywords.Spark Stop UE Log    ue_index=${ue_index}   AND
    ...    Run Keyword And Ignore Error     Recover Collect Syslog On Control PC     AND
    ...    Run Keyword If    ${whether_do_lte_cell_locked} and '${tl_prefix}'=='T813'    Run Keyword And Ignore Error
    ...    Do All TDD-LTE Cells Action    cell_action=unlocked

Procedures.Verify CA Basic Handover Test
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${ho_pcell_index}=${HO_PCELL_INDEX}    ${ue_index}=${0}    ${ue_mode}=SA    ${timeout}=${600}
    ...            ${source_pa_value}=25    ${target_pa_value}=15    ${scell_addition_method}=A1
    ...            ${gnb_id}=0    ${connection}=GNB_OAM0    ${asik_alias}=ASIK Master0    ${whether_check_tupt}=${False}
    ...            ${whether_check_scell_addition}=${True}
    Get Pcell And Scell Mapping Info For Pcell Change    ho_pcell_index=${ho_pcell_index}
    ...                                                  gnb_id=${gnb_id}
    ...                                                  connection=${connection}
    ...                                                  timeout=${timeout}
    ${ru_whether_connect_mcs}    Check RU Whether Connect Mcs    ru_index=${PCELL_MAPPING['ru_index_mapping']}
    ${ho_ru_whether_connect_mcs}    Check RU Whether Connect Mcs    ru_index=${HO_PCELL_MAPPING['ru_index_mapping']}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
    ...    tcpdump_collector_name=handover
    ...    asik_connection_alias=${asik_alias}
    ...    gnb_index=${gnb_id}
    Sleep    30sec
    FOR    ${attenuator}    IN    @{attenuator_list}
        Run Keyword If    '${attenuator}'=='pa'    Modify PA Value Setting For Required RU    modify_ru_id=${HO_PCELL_MAPPING['ru_index_mapping']}
        ...                                                                                   ue_index=${ue_index}
        ...                                                                                   pa_off_value=${target_pa_value}
        ...    ELSE IF    '${attenuator}'=='mcs' and ${ho_ru_whether_connect_mcs}
        ...                                        Set Case Related MCS Port Value    att_value=${target_pa_value}
        ...                                                                           ue_index=${ue_index}
        ...                                                                           whether_do_Angles=${False}
        ...                                                                           whether_do_mcs_setup=${False}
        ...    ELSE    Log To Console     ${\n}INFO: --Use the wrong attenuator type(${attenuator}), need to check TMO_Data.py--
    END
    Sleep    2sec
    FOR    ${attenuator}    IN    @{attenuator_list}
        Run Keyword If    '${attenuator}'=='pa'    Modify PA Value Setting For Required RU    modify_ru_id=${PCELL_MAPPING['ru_index_mapping']}
        ...                                                                                   ue_index=${ue_index}
        ...                                                                                   pa_off_value=${source_pa_value}
        ...    ELSE IF    '${attenuator}'=='mcs' and ${ru_whether_connect_mcs}
        ...                                        Set Case Related MCS Port Value    att_value=${source_pa_value}
        ...                                                                           ue_index=${ue_index}
        ...                                                                           whether_do_Angles=${False}
        ...                                                                           whether_do_mcs_setup=${False}
        ...    ELSE    Log To Console     ${\n}INFO: --Use the wrong attenuator type(${attenuator}), need to check TMO_Data.py--
    END
    Sleep    45sec
    ${handover_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection    tcpdump_collector_name=handover
    ${handover_addition_scell_index_list}    Run Keyword If    ${whether_check_scell_addition}
    ...               Run Keyword And Continue On Failure    Check Scell Addition Success
    ...                                      cpif_log_path=${handover_wireshark}
    ...                                      mode=${ue_mode}
    ...                                      addition_method=${scell_addition_method}
    ...                                      scell_mapping=${HO_SCELL_MAPPING}
    ...                                      expect_addition_scell_indexs=${HO_SCELL_INDEX_LIST}
    Run Keyword If    ${whether_check_tupt}    Run Keyword And Continue On Failure
    ...                                           Procedures.Check TMO Throughput    ue_index=${ue_index}
    ...                                                                              addition_scell_index_list=${HO_SCELL_INDEX_LIST}
    ...                                                                              pcell_mapping=${HO_PCELL_MAPPING}
    ...                                                                              scell_mapping=${HO_SCELL_MAPPING}
    ...                                                                              tput_collect_duration=180
    ...                                                                              ignore_time=5sec
    [Return]    ${handover_wireshark}

Procedures.Verify Non-CA Basic L3 Call
    [Documentation]   tingting.1.liu@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    ...            ${ue_type}=${ue_type}
    ...            ${ue_mode}=SA
    ...            ${ul_throughput}=150MKbits/sec
    ...            ${dl_throughput}=1500MKbits/sec
    ...            ${expect_dl_tput}=1000
    ...            ${expect_ul_tput}=60
    ...            ${start_keep_on_duration}=1200
    ...            ${tput_collect_duration}=180
    ...            ${whether_do_barred_action}=${True}
    ...            ${whether_do_lte_cell_barred}=${True}
    ...            ${whether_check_on_air}=${True}
    ...            ${whether_do_ue_prepare}=${False}
    ...            ${whether_check_tupt}=${True}
    ...            ${whether_check_attach_cell}=${True}
    ...            ${whether_start_traffic}=${True}
    ...            ${whether_start_uelog}=${True}
    ...            ${whether_stop_uelog}=${True}
    ...            ${expect_tp_percent}=1
    ...            ${notbarred_cell_index}=${301}
    ...            ${apn_address}=${tl.core.pdns[1].apn}
    ...            ${connection}=GNB_OAM
    ...            ${ignore_time}=1min
    ...            ${4G_check}=True
    ...            ${exp_status}=notBarred
    ...            ${attach_mode}=5G_${ue_mode}
    ...            ${ue_alias}=UE_${ue_index}
    ...            ${is_power_ue_code}=${False}
    ...            ${ue_iperf_path}=/data/local/tmp/iperf
    ...            ${enb_index}=${1}
    ${direction_component_list}=  Create List    UL_L2LO    DL_L2LO
    Set Test Variable    ${direction_component_list}
    Run Keyword If    ${whether_do_lte_cell_barred}    Change cellBarred Parameter Value Of Lte Cells
    ...                     list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    Run Keyword If    ${whether_do_barred_action}    Change cellBarred Parameter Value On Gnb    pcell_index=${notbarred_cell_index}
    ...                                                                                          exp_status=${exp_status}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}
    Run Keyword If    ${whether_check_on_air}    Verify TMO Gnb Ready And All Cell On Air    timeout=15 min
    Run Keyword If    ${whether_do_ue_prepare}    Procedures.Start UE Prepare    ue_index=${ue_index}    ue_type=${ue_type}
    Run Keyword If    ${whether_start_uelog} and '${ue_type}'=='huawei_sigspark'    Spark_common_keywords.Spark Start UE Log
    ...                                                                                 ue_index=${ue_index}
    ${attach_info}    Procedures.Start TMO Attach    ue_mode=${ue_mode}    ue_index=${ue_index}    ue_type=${ue_type}
    ...               4G_check=${4G_check}    ue_alias=${ue_alias}       enb_index=${enb_index}
    ...               attach_mode=${attach_mode}    is_power_ue_code=${is_power_ue_code}
    Run Keyword If    ${whether_check_attach_cell}     Run Keyword And Continue On Failure
    ...                    Should Be Equal As Integers    ${attach_info['attach_cell_index']}    ${notbarred_cell_index}

    ${attach_wireshark}    Set Variable If    '${ue_mode}'=='NSA'
    ...    ${attach_info['enb_wireshark_log_path']}    ${attach_info['cpif_log_path']}
#    Run Keyword If    ${whether_start_traffic}
#    ...    Run Keyword And Continue On Failure    Procedures.Start Data Transfer
#    ...                                    cpif_log_path=${attach_wireshark}
#    ...                                    ue_mode=${ue_mode}
#    ...                                    ue_index=${ue_index}
#    ...                                    start_keep_on_duration=${start_keep_on_duration}
#    ...                                    ul_throughput=${ul_throughput}
#    ...                                    dl_throughput=${dl_throughput}
#    ...                                    iperf_path=${ue_iperf_path}
#    ...                                    ue_type=${ue_type}
#    ...                                    apn_address=${apn_address}
#    ...                                    is_power_ue_code=${is_power_ue_code}
#    Sleep    30s
    Run Keyword If    ${whether_start_traffic}     Spark_common_keywords.Start L3 Traffic
    ...                             ue_mode=${ue_mode}
    ...                             ue_index=${ue_index}
    ...                             duration=${start_keep_on_duration}
    ...                             ul_throughput=${ul_throughput}
    ...                             dl_throughput=${dl_throughput}
    ...                             apn_address=${apn_address}
    Sleep    30s
    Run Keyword If    ${whether_check_tupt}    Check Tput With Power UE
    ...                                 cellid=${notbarred_cell_index}
    ...                                 direction_component_list=${direction_component_list}
    ...                                 expect_ul_tput=${expect_ul_tput}
    ...                                 expect_dl_tput=${expect_dl_tput}
    ...                                 target_avg_percent=0.9
    ...                                 duration=${tput_collect_duration}
    ...                                 is_ulbler_calcu=${False}
    ...                                 check_source=aasyslog
    ...                                 ignore_time=${ignore_time}
    Run Keyword If    ${whether_stop_uelog} and '${ue_type}'=='huawei_sigspark'    Run Keyword And Ignore Error
    ...     Spark_common_keywords.Spark Stop UE Log    ue_index=${ue_index}


#--- Common keywords for L3 Call---#
Procedures.Check network mode
    [Documentation]   author: lei.jia@nokia-sbell.com
    ...               preferred_network_mode:
    ...               0:'WCDMA_preferred',1:'GSM_only', 2:'WCDMA_only', 3:'GSM_WCDMA_auto', 4:'CDMA_EvDo',
    ...               5:'CDMA_only', 6:'EvDo_only', 7:'Global', 8:'LTE_CDMA_EvDo',9:'LTE_GSM_WCDMA',10:'LTE_CDMA_EvDo_GSM_WCDMA',
    ...               11:'LTE_only',12:'LTE_WCDMA',13:'TD_SCDMA_only',14:'TD_SCDMA_WCDMA',15:'TD_SCDMA_LTE',16:'TD_SCDMA_GSM',
    ...               17:'TD_SCDMA_GSM_LTE',18:'TD_SCDMA_GSM_WCDMA',19:'TD_SCDMA_WCDMA_LTE',20:'TD_SCDMA_GSM_WCDMA_LTE',
    ...               21:'TD_SCDMA_GSM_WCDMA_CDMA_EvDo',22:'TD_SCDMA_LTE_CDMA_EvDo_GSM_WCDMA',23:'NR_only',24:'NR_LTE',
    ...               25:'NR_LTE_CDMA_EVDO',26:'NR_LTE_GSM_WCDMA',27:'NR_LTE_CDMA_EVDO_GSM_WCDMA',28:'NR_LTE_WCDMA',29:'NR_LTE_TDSCDMA',
    ...               30:'NR_LTE_TDSCDMA_GSM',31:'NR_LTE_TDSCDMA_WCDMA',32:'NR_LTE_TDSCDMA_GSM_WCDMA',33:'NR_LTE_TDSCDMA_CDMA_EVDO_GSM_WCDMA'
    [Arguments]    ${ue_index}=${0}
    ...            ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...            ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...            ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...            ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    csn.send_command    command=adb -s ${serial_number} shell settings list global|grep preferred_network_mode    connection=cpc_${ue_index}
    Sleep    1sec
    ${output}    csn.read_output    connection=cpc_${ue_index}
    ${preferred_network_mode_list}    Get Regexp Matches    ${output}    preferred_network_mode=(\\d+)    1
    ${preferred_network_mode_id}    Convert To Integer    ${preferred_network_mode_list[0]}
    Should Be True    ${preferred_network_mode_id} >= 24
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

Procedures.Start UE Prepare
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${get_spark_license}=${true}
    ...            ${detach_request}=${true}      ${power_reset}=False
    Log To Console     ${\n}INFO: --Start UE Prepare
    Run keyword if    '${ue_type}' == 'mtk'    MTK_common_keywords.Prepare UE    ue_index=${ue_index}
    ...    ELSE    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    get_spark_license=${get_spark_license}
    ...                                  detach_request=${detach_request}      power_reset=${power_reset}

Procedures.Start TMO Attach
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               Modify:Stella.lin@nokia-sbell.com
    [Arguments]    ${wireshark_log_prefix}=cpif_attach
    ...            ${ue_type}=${ue_type}
    ...            ${ue_mode}=SA
    ...            ${apn_address}=${tl.core.pdns[0].apn}
    ...            ${coam_connection}=GNB_OAM
    ...            ${ue_index}=${0}
    ...            ${gnb_index}=${0}
    ...            ${asik_connection_alias}=ASIK Master
    ...            ${enb_wireshark_log_prefix}=enb_wireshark_log
    ...            ${enb_index}=${1}
    ...            ${common_unit_index}=${0}
    ...            ${sleep_interval}=15 sec
    ...            ${du_index}=0
    ...            ${hwcheck_index}=${1}
    ...            ${power_reset}=False
    ...            ${4G_check}=True
    ...            ${5Gstatus}=PASS
    ...            ${attach_mode}=5G_${ue_mode}
    ...            ${ue_alias}=UE_${ue_index}
    ...            ${is_power_ue_code}=${False}
    ...            ${enb_host}=${None}
    ...            ${enb_user}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            ${enb_password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${is_multi_rat}    Check LTE Whether In Gnb    gnb_id=${gnb_index}    gnb_connection=${coam_connection}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${wireshark_log_name}    Set Variable    ${wireshark_log_prefix}_${timestamp}
    ${enb_wireshark_log_name}    Set Variable    ${enb_wireshark_log_prefix}_${timestamp}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log    tcpdump_collector_name=${wireshark_log_name}
    ...    asik_connection_alias=${asik_connection_alias}
    ...    gnb_index=${gnb_index}
    ${enb_in_init_file_existence}    ${output}    Run Keyword And Ignore Error    Set Variable    ${tl.enbs[0]}
    ${enb_ip}    Run Keyword If    '${ue_mode}'=='NSA' and '${is_multi_rat}'=='${False}' and '${enb_in_init_file_existence}'=='FAIL'
    ...    Get ENB IPaddress From GNB    gnb_index=${gnb_index}
    ...    ELSE IF   '${ue_mode}'=='NSA' and '${is_multi_rat}'=='${False}' and '${enb_in_init_file_existence}'=='PASS'
    ...    Set Variable    ${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ${enb_host}    Set Variable If     '${ue_mode}'=='NSA' and '${is_multi_rat}'=='${False}'    ${enb_ip}    ${enb_host}
    Run Keyword If    '${ue_mode}'=='NSA'
    ...    Run Keyword And Continue On Failure    Start tcpdump Log On Enb     tcpdump_collector_name=${enb_wireshark_log_name}
    ...                                                                        enb_index=${enb_index}
    ...                                                                        common_unit_index=${common_unit_index}
    ...                                                                        is_multi_rat=${is_multi_rat}
    ...                                                                        gnb_index=${gnb_index}
    ...                                                                        enb_host=${enb_host}
    ...                                                                        enb_user=${enb_user}
    ...                                                                        enb_password=${enb_password}
    Sleep    ${sleep_interval}
    Log To Console    ${\n}INFO:-- start to attach --
    ${5Grach_ed}    Run Keyword If    '${ue_type}'=='mtk'    MTK_common_keywords.Do UE Attach    ue_index=${ue_index}
#    ...    ELSE IF    '${ue_type}'=='huawei_sigspark' and '${is_power_ue_code}'=='${False}'
#    ...                Spark_common_keywords.Start UE Attach And Enable Data Service
#    ...                ue_index=${ue_index}
    ...    ELSE    power_ue.UE Attach    ue_type=${ue_type}
    ...                                  ue_index=${ue_index}
    ...                                  gnb_index=${gnb_index}
    ...                                  hwcheck_index=${hwcheck_index}
    ...                                  du_index=${du_index}
    ...                                  power_reset=${power_reset}
    ...                                  ue_alias=${ue_alias}
    ...                                  attach_mode=${attach_mode}
#    Run Keyword If    '${tl_prefix}'=='T073'    Sleep    45sec
    Sleep    30sec
    Run Keyword If     '${ue_type}'=='huawei_sigspark'
    ...                Spark_common_keywords.Start UE Attach in X65 multi UE x65   ue_index=${ue_index}
    Sleep    30sec
    Run Keyword If    '${ue_type}'!='mtk'    power_ue.Verify attach    ue_type=${ue_type}
    ...                                                                ue_index=${ue_index}
    ...                                                                gnb_index=${gnb_index}
    ...                                                                du_index=${du_index}
    ...                                                                5Grach_ed=${5Grach_ed}
    ...                                                                4G_check=${4G_check}
    ...                                                                5Gstatus=${5Gstatus}
    ${attach_time}    DateTime.Get Current Date    result_format=%Y-%m-%d%H:%M:%S
    Sleep    ${sleep_interval}
    ${cpif_attach_log_on_testPC}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=${wireshark_log_name}
    ${enb_wireshark_log_path_on_testPC}    Run Keyword If   '${ue_mode}'=='NSA'
    ...    Run Keyword And Continue On Failure    Stop tcpdump log collection    tcpdump_collector_name=${enb_wireshark_log_name}
    ${attach_cell_index}    Get Attach Cell Index From Wireshark    cpif_log_path=${cpif_attach_log_on_testPC}
    ...                                                             connection=${coam_connection}
    ...                                                             gnb_index=${gnb_index}
    ...                                                             mode=${ue_mode}
    ${attach_info}    Run Keyword If    '${ue_mode}'=='NSA'
    ...            Create Dictionary    cpif_log_path=${cpif_attach_log_on_testPC}
    ...                                 attach_cell_index=${attach_cell_index}
    ...                                 enb_wireshark_log_path=${enb_wireshark_log_path_on_testPC}
    ...    ELSE    Create Dictionary    cpif_log_path=${cpif_attach_log_on_testPC}    attach_cell_index=${attach_cell_index}
    [Return]     ${attach_info}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    core.stop_collectors    names=${wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=${wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.stop_collectors    names=${enb_wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=${enb_wireshark_log_name}

Procedures.Check TMO Scell Addition
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${attach_info}
    ...            ${ue_mode}=SA
    ...            ${expect_addition_scell_indexs}=${None}
    ...            ${scell_addition_method}=A1
    ...            ${scell_mapping}=${SCELL_MAPPING}
    ...            ${pcell_mapping}=${PCELL_MAPPING}
    Log To Console    ${\n}INFO:-- start to check scell addition --
    ${addition_scell_index_list}    Run Keyword If    '${scell_addition_method}'=='A1'
    ...                                               Message_Flow_Check.A1 Addition Process
    ...                                               addition_cpif_log_path=${attach_info['cpif_log_path']}
    ...                                               mode=${ue_mode}
    ...                                               expect_addition_scell_indexs=${expect_addition_scell_indexs}
    ...                                               pcell_mapping=${pcell_mapping}
    ...                                               scell_mapping=${scell_mapping}
    ...    ELSE    Check Scell Addition Success    cpif_log_path=${attach_info['cpif_log_path']}
    ...                                            mode=${ue_mode}
    ...                                            expect_addition_scell_indexs=${expect_addition_scell_indexs}
    ...                                            scell_mapping=${scell_mapping}
    [Return]    ${addition_scell_index_list}

Procedures.Start TMO L3 Call
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...              for mtk and samsung ue, default iperf_path is '/data/local/tmp/iperf'; for qxc_dx50, default iperf_path is 'iperf'
    [Arguments]    ${cpif_log_path}    ${ue_mode}=SA    ${ue_index}=${0}    ${apn_address}=${tl.core.pdns[0].apn}
    ...            ${ul_throughput}=150M    ${dl_throughput}=2500MKbits/sec    ${start_keep_on_duration}=1200
    ...            ${buffer_size}=1400B    ${appserver}=APPserver    ${protocol}=udp    ${iperf_path}=iperf
    ...            ${ul_process_num}=${1}    ${dl_process_num}=${2}    ${seg_size}=${1350}    ${window}=16M
    ...            ${whether_start_dl_call}=${True}    ${whether_start_ul_call}=${True}    ${ue_type}=${ue_type}
    ...            ${whether_DL_nonGBR}=${False}    ${dl_port}=${tl.ues[${ue_index}].iperf_details.port}
    Log To Console    ${\n}INFO:-- start to L3 call --
    ${iperf_path}    Set Variable If    '${ue_type}'=='mtk' or '${ue_type}'=='samsung'    ${iperf_path}    iperf
    Run Keyword If    ${whether_start_dl_call}    Run Keyword And Continue On Failure
    ...    Procedures.Start DL Call    cpif_log_path=${cpif_log_path}
    ...                                ue_type=${ue_type}
    ...                                ue_mode=${ue_mode}
    ...                                ue_index=${ue_index}
    ...                                apn_address=${apn_address}
    ...                                dl_throughput=${dl_throughput}
    ...                                start_keep_on_duration=${start_keep_on_duration}
    ...                                buffer_size=${buffer_size}
    ...                                appserver=${appserver}
    ...                                protocol=${protocol}
    ...                                process_num=${dl_process_num}
    ...                                seg_size=${seg_size}
    ...                                window=${window}
    ...                                whether_DL_nonGBR=${whether_DL_nonGBR}
    ...                                dl_port=${dl_port}
    ${ul_throughput_spark}    Replace String    ${ul_throughput}    M    MKbits/sec
    ${ul_throughput}    Set Variable If    '${ue_type}'=='huawei_sigspark'    ${ul_throughput_spark}    ${ul_throughput}
    Run Keyword If    '${protocol}'=='udp' and '${ue_type}'=='huawei_sigspark' and ${whether_start_ul_call}
    ...    Spark_common_keywords.Start UL Traffic with spark UE   ul_throughput=${ul_throughput}
    ...             duration=${start_keep_on_duration}
    ...             apn_address=${apn_address}
    ...             ue_mode=${ue_mode}
    ...             ue_index=${ue_index}
    ...    ELSE IF   ${whether_start_ul_call} and '${ue_type}'!='huawei_sigspark'
    ...    traffic_via_iperf.Start UL traffic via iperf from andriod UE
    ...        ue_index=${ue_index}
    ...        ul_time=${start_keep_on_duration}
    ...        ul_port=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ...        ul_throughput=${ul_throughput}
    ...        ul_length=${buffer_size}
    ...        appserver=${appserver}
    ...        protocol=${protocol}
    ...        iperf_path=${iperf_path}
    ...        process_num=${ul_process_num}

Procedures.Start DL Call
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${cpif_log_path}    ${ue_mode}=SA    ${ue_index}=${0}    ${apn_address}=${tl.core.pdns[0].apn}
    ...            ${dl_throughput}=2500MKbits/sec    ${start_keep_on_duration}=1200
    ...            ${buffer_size}=1400B    ${appserver}=APPserver    ${protocol}=udp    ${whether_DL_nonGBR}=${False}
    ...            ${process_num}=${2}    ${seg_size}=${1372}    ${window}=2M    ${ue_type}=${ue_type}
    ...            ${dl_port}=${tl.ues[${ue_index}].iperf_details.port}
    Log To Console    ${\n}INFO:-- start to DL call --
    ${ue_ip_dict}    Run Keyword If   ${whether_DL_nonGBR}==${False}   Get ALL PDU IP Address From Wireshark
    ...    cpif_log_path=${cpif_log_path}    mode=${ue_mode}
    ...    ELSE    Get mutiple nonGBR PDU IP Address From Wireshark    cpif_log_path=${cpif_log_path}    mode=${ue_mode}
    ${dl_throughput}    Replace String    ${dl_throughput}    MKbits/sec    M
#    ${dl_throughput}    Run Keyword If    '${ue_type}'!='huawei_sigspark'    Replace String    ${dl_throughput}    MKbits/sec    M
#    Run Keyword If    '${protocol}'=='udp' and '${ue_type}'=='huawei_sigspark'
#    ...                                       Spark_common_keywords.Start DL Traffic    dl_throughput=${dl_throughput}
#    ...                                                                                 duration=${start_keep_on_duration}
#    ...                                                                                 apn_address=${apn_address}
#    ...                                                                                 ue_mode=${ue_mode}
#    ...                                                                                 ue_index=${ue_index}
#    ...    ELSE    Start DL traffic via iperf on Appserver    ue_addr=${ue_ip_dict['data']}
#    ...                                                       dl_time=${start_keep_on_duration}
#    ...                                                       dl_port=${tl.ues[${ue_index}].iperf_details.port}
#    ...                                                       dl_throughput=${dl_throughput}
#    ...                                                       dl_length=${buffer_size}
#    ...                                                       appserver=${appserver}
#    ...                                                       protocol=${protocol}
#    ...                                                       ue_index=${ue_index}
#    ...                                                       process_num=${process_num}
#    ...                                                       seg_size=${seg_size}
#    ...                                                       window=${window}
    Start DL traffic via iperf on Appserver    ue_addr=${ue_ip_dict['data']}
    ...                                                       dl_time=${start_keep_on_duration}
    ...                                                       dl_port=${dl_port}
    ...                                                       dl_throughput=${dl_throughput}
    ...                                                       dl_length=${buffer_size}
    ...                                                       appserver=${appserver}
    ...                                                       protocol=${protocol}
    ...                                                       ue_index=${ue_index}
    ...                                                       process_num=${process_num}
    ...                                                       seg_size=${seg_size}
    ...                                                       window=${window}

Procedures.Collect the Throughput
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]     ${ue_type}    ${ue_index}=${0}    ${cell_type}=nr
    ...             ${gnb_index}=0    ${du_index}=0    ${gnb_connection}=GNB_OAM    ${enb_index}=${0}
    ...             ${tput_collect_duration}=180    ${ignore_time}=1min    ${check_source}=aasyslog
    Log To Console    ${\n}INFO:-- start to collect tupt --
    ${4g_whether_in_gnb}    Check LTE Whether In Gnb    gnb_id=${gnb_index}    gnb_connection=${gnb_connection}
    ${host}    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${cell_type}'!='nr'
    ...    Set Variable    ${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ${tput_file_1}    Run Keyword If    ${4g_whether_in_gnb}    power_ue.Collect Tput    ue_type=${ue_type}
    ...                                                                                gnb_index=${gnb_index}
    ...                                                                                du_index=${du_index}
    ...                                                                                duration=${tput_collect_duration}
    ...                                                                                ignore_time=${ignore_time}
    ...                                                                                ue_index=${ue_index}
    ...                                                                                check_source=${check_source}
    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${cell_type}'!='nr'    Run Keywords
    ...    Start To Capture Aasyslog    gnb_index=${gnb_index}    du_index=${du_index}    host=${host}    AND
    ...    Sleep    ${tput_collect_duration} sec
    ${tput_file_2}    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${cell_type}'!='nr'
    ...    Stop To Capture And Download Aasyslog    host=${host}
    ${tput_file}   Set Variable If     ${4g_whether_in_gnb}      ${tput_file_1}     ${tput_file_2}
    [Return]    ${tput_file}

Procedures.Check TMO Throughput
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               If ${whether_collect_tput}=${False}, the parameter ${tput_file_use_collested} must not be ${None}
    ...               Need to collect tput first, then set the vlaue of ${tput_file_use_collested} is the existed file.
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${gnb_index}=${0}    ${addition_scell_index_list}=${None}
    ...            ${tput_collect_duration}=300    ${check_pcell_tput_type}=peak    ${check_scell_tput_type}=peak
    ...            ${target_DL_avg_percent}=0.9    ${target_UL_avg_percent}=0.9    ${check_ul_pcell_tput_type}=peak
    ...            ${min_DL_percent}=0.85    ${min_UL_percent}=0.85    ${min_scell_percent}=0.85    ${expect_tp_percent}=1
    ...            ${pcell_mapping}=${PCELL_MAPPING}    ${scell_mapping}=${SCELL_MAPPING}
    ...            ${whether_collect_tput}=${True}    ${tput_file_use_collected}=${None}
    ...            ${check_source}=aasyslog    ${ignore_time}=1min
    ...            ${check_pcell_tput}=${True}    ${check_scell_tput}=${True}
    ...            ${whether_check_scell_ul_tupt}=${False}     ${special_scell_index_for_UL}=None
    Log To Console    ${\n}INFO:-- start to check CA tupt --
    Check Tput For CA Group    ue_type=${ue_type}
    ...                        gnb_index=${gnb_index}
    ...                        duration=${tput_collect_duration}
    ...                        addition_scell_index_list=${addition_scell_index_list}
    ...                        check_pcell_tput_type=${check_pcell_tput_type}
    ...                        check_scell_tput_type=${check_scell_tput_type}
    ...                        target_DL_avg_percent=${target_DL_avg_percent}
    ...                        target_UL_avg_percent=${target_UL_avg_percent}
    ...                        min_DL_percent=${min_DL_percent}
    ...                        min_UL_percent=${min_UL_percent}
    ...                        min_scell_percent=${min_scell_percent}
    ...                        expect_tp_percent=${expect_tp_percent}
    ...                        check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                        pcell_mapping=${pcell_mapping}
    ...                        scell_mapping=${scell_mapping}
    ...                        whether_collect_tput=${whether_collect_tput}
    ...                        tput_file_use_collected=${tput_file_use_collected}
    ...                        check_source=${check_source}
    ...                        ignore_time=${ignore_time}
    ...                        check_pcell_tput=${check_pcell_tput}
    ...                        check_scell_tput=${check_scell_tput}
    ...                        whether_check_scell_ul_tupt=${whether_check_scell_ul_tupt}
    ...                        special_scell_index_for_UL=${special_scell_index_for_UL}


Procedures.Stop TMO L3 Call And Detach
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${is_power_ue_code}=${False}
    ...                                ${apn_address}=${tl.core.pdns[0].apn}     ${power_reset}=False
    Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${ue_index}
    ...    iperf_port=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${tl.ues[${ue_index}].iperf_details.port}
    Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${ue_index}
    ...                                                                      iperf_port=${tl.ues[${ue_index}].iperf_details.port}
    Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    Run Keyword If    '${ue_type}'=='huawei_sigspark'    Run Keyword And Ignore Error
    ...    power_ue.Stop traffic   ue_type=${ue_type}    direction=ul    ue_index=${ue_index}    apn_address=${apn_address}
    ${power_reset}    Set Variable If    'spark' in '${ue_type}'    true    ${power_reset}
    Run Keyword If    '${ue_type}'!='mtk'    Run Keyword And Ignore Error
    ...   power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=${power_reset}
    Run Keyword If    '${ue_type}'=='mtk'    Run Keyword And Ignore Error    MTK_common_keywords.Do UE Detach    ue_index=${ue_index}


Procedures.Adb Reboot UE And Verify
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Suite Variable    ${ue_type}
    Run Keyword If    '${ue_type}'=='qct_dx50'    Run Keywords
    ...    Connect to control pc enhanced    ${ue_index}    AND
    ...    csn.execute    command=adb -s ${serial_number} reboot   connection=cpc_${ue_index}    AND
    ...    Sleep    10s    AND
    ...    Wait Until Keyword Succeeds    3 min    10s    Connect ADB devices    alias=cpc_${ue_index}    serial_number=${serial_number}
    [Teardown]    Run Keyword If    '${ue_type}'=='qct_dx50'    Run Keyword And Ignore Error    csn.disconnect   connection=cpc_${ue_index}


Procedures.Start UE Prepare MTK80
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}
    Run keyword if    '${ue_type}' == 'mtk'    MTK_common_keywords.Prepare UE For MTK80    ue_index=${ue_index}
    ...    ELSE    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}

## Procedures for 4G L3 call
Procedures.Verify 4G L3 Call
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${notbarred_cell_index}=${PCELL_INDEX}
    ...            ${ue_index}=${0}
    ...            ${ue_type}=${ue_type}
    ...            ${cell_type}=lte
    ...            ${gnb_index}=${0}
    ...            ${du_index}=0
    ...            ${hwcheck_index}=${1}
    ...            ${power_reset}=False
    ...            ${dl_throughput}=1000MKbits/sec
    ...            ${start_keep_on_duration}=900
    ...            ${expect_dl_tput}=150
    ...            ${expect_ul_tput}=10
    ...            ${whether_check_on_air}=${True}
    ...            ${whether_do_ue_prepare}=${False}
    ...            ${whether_need_ue_log}=${False}
    ...            ${ignore_time}=1min
    ...            ${enb_index}=${0}
    ...            ${common_unit_index}=${0}
    ...            ${sleep_interval}=35 sec
    ...            ${whether_do_lte_barred_action}=${True}
    ...            ${whether_do_barred_action}=${True}
    ...            ${tput_collect_duration}=120
    ...            ${iperf_path}=/data/local/tmp/iperf
    ...            ${apn_address}=${tl.core.pdns[0].apn}
    ...            ${ul_throughput}=50M
    ...            ${ue_mode}=NSA
    ...            ${process_num}=${2}
    ${dl_throughput}    Convert Dl Tput based on Process num    process_num=${process_num}    dl_throughput=${dl_throughput}
    Run Keyword If    ${whether_do_lte_barred_action}    Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=${notbarred_cell_index}
    ...                                                                                                    exp_status=notBarred
    ...                                                                                                    enb_index=${enb_index}
    Run Keyword If    ${whether_do_barred_action}    Change cellBarred Parameter Value On Gnb    pcell_index=all
    ...                                                                                          exp_status=barred
    Run Keyword If    ${whether_check_on_air}    Verify TMO Gnb Ready And All Cell On Air
    Run Keyword If    ${whether_check_on_air}    Wait Until Keyword Succeeds    2 min    20 sec    Verify Enb All Cell On Air
    ...                                                                                                enb_index=${enb_index}
    Run Keyword If    ${whether_do_ue_prepare}    Procedures.Start UE Prepare    ue_index=${ue_index}    ue_type=${ue_type}
    Run Keyword If    ${whether_need_ue_log} and '${ue_type}'=='huawei_sigspark'    Run Keyword And Continue On Failure
    ...    Spark_common_keywords.Spark Start UE Log    ue_index=${ue_index}
    Run Keyword If    '${ue_type}'=='huawei_sigspark' and '${tl_prefix}'!='T284'   Run Keyword And Continue On Failure
    ...    Change Network Mode Between SA And NSA For 8UE Module    ue_mode=${ue_mode}    ue_index=${ue_index}
    Run Keyword If    '${ue_type}'=='huawei_sigspark' and '${tl_prefix}'=='T284'   Run Keyword And Continue On Failure
    ...    Change Network Mode Between SA And NSA and LTE For 8UE X65 Module    ue_mode=LTE    ue_index=${ue_index}
    ${attach_info}    Procedures.Start 4G Attach    ue_type=${ue_type}
    ...                                             ue_index=${ue_index}
    ...                                             enb_index=${enb_index}
    ...                                             common_unit_index=${common_unit_index}
    ...                                             sleep_interval=${sleep_interval}
    ...                                             gnb_index=${gnb_index}
    ...                                             du_index=${du_index}
    ...                                             cell_type=${cell_type}
    ...                                             hwcheck_index=${hwcheck_index}
    ...                                             power_reset=${power_reset}
    ...                                             ue_mode=${ue_mode}
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${attach_info['attach_cell_index']}    ${notbarred_cell_index}
    ${ue_ip_dict}    Wait Until Keyword Succeeds    3X    10sec    Get ALL PDU IP Address From Wireshark
    ...    cpif_log_path=${attach_info['cpif_log_path']}    mode=${ue_mode}
    ${dl_throughput}       Replace String    ${dl_throughput}    MKbits/sec    M
    ${ul_throughput}   Run Keyword If    '${ue_type}'=='huawei_sigspark'
    ...                                  Replace String      ${ul_throughput}      M        MKbits/sec
    ...                ELSE   Set Variable   ${ul_throughput}
    ${iperf_path}    Set Variable If    '${ue_type}'=='mtk' or '${ue_type}'=='samsung'    ${iperf_path}    iperf
    Run Keyword If    '${ue_type}'=='huawei_sigspark'   power_ue.Start traffic
    ...                                                      ue_type=${ue_type}
    ...                                                      direction=ul
    ...                                                      throughput=${ul_throughput}
    ...                                                      duration=${start_keep_on_duration}
    ...                                                      dt_name=DT_ul
    ...                                                      apn_address=${apn_address}
    ...                                                      ue_mode=${ue_mode}
    ...                                                      ue_index=${ue_index}
    ...   ELSE         traffic_via_iperf.Start UL traffic via iperf from andriod UE
    ...                                        ue_index=${ue_index}
    ...                                        ul_time=${start_keep_on_duration}
    ...                                        ul_port=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ...                                        ul_throughput=${ul_throughput}
    ...                                        ul_length=1400B
    ...                                        appserver=APPserver
    ...                                        protocol=udp
    ...                                        iperf_path=${iperf_path}
    ...                                        process_num=${1}
    Start DL traffic via iperf on Appserver    ue_addr=${ue_ip_dict['data']}
    ...                                        dl_time=${start_keep_on_duration}
    ...                                        dl_port=${tl.ues[${ue_index}].iperf_details.port}
    ...                                        dl_throughput=${dl_throughput}
    ...                                        dl_length=1400B
    ...                                        appserver=APPserver
    ...                                        protocol=udp
    ...                                        ue_index=${ue_index}
    ...                                        process_num=${process_num}
    ...                                        seg_size=${1350}
    ...                                        window=2M
    Run Keyword And Continue On Failure    Check 4G Tput With Power UE
    ...                               expect_dl_tput=${expect_dl_tput}
    ...                               expect_ul_tput=${expect_ul_tput}
    ...                               ue_type=${ue_type}
    ...                               ue_index=${ue_index}
    ...                               cell_type=${cell_type}
    ...                               tput_collect_duration=${tput_collect_duration}
    ...                               ignore_time=${ignore_time}
    ...                               enb_index=${enb_index}
    [Teardown]   Run Keyword If    ${whether_need_ue_log} and '${ue_type}'=='huawei_sigspark'
    ...    Run Keyword And Ignore Error   Spark_common_keywords.Spark Stop UE Log    ue_index=${ue_index}
    ...    ELSE IF    '${ue_type}'=='huawei_sigspark' and '${tl_prefix}'!='T284'
    ...                Change Network Mode Between SA And NSA For 8UE Module    ue_mode=SA    ue_index=${ue_index}
    ...    ELSE IF   '${ue_type}'=='huawei_sigspark' and '${tl_prefix}'=='T284'   Run Keyword And Ignore Error
    ...    Change Network Mode Between SA And NSA and LTE For 8UE X65 Module    ue_mode=SA    ue_index=${ue_index}

Check 4G Tput With Power UE
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    ...                Param： When ${whether_need_collect}=${False}, ${tput_log_path} must be given
    [Arguments]    ${expect_dl_tput}    ${expect_ul_tput}   ${ue_type}=${ue_type}    ${ue_index}=${0}
    ...            ${gnb_index}=0    ${du_index}=0    ${cell_type}=lte
    ...            ${tput_collect_duration}=180    ${ignore_time}=1min    ${check_source}=aasyslog
    ...            ${whether_need_collect}=${True}    ${tput_log_path}=${None}
    ...            ${gnb_connection}=GNB_OAM    ${enb_index}=${0}    ${log_dir_ute}=${TS_CASE_LOG_PATH}
    ${tput_log}    Run Keyword If    ${whether_need_collect}    Procedures.Collect the Throughput
    ...                                                             ue_type=${ue_type}
    ...                                                             ue_index=${ue_index}
    ...                                                             cell_type=${cell_type}
    ...                                                             gnb_index=${gnb_index}
    ...                                                             du_index=${du_index}
    ...                                                             gnb_connection=${gnb_connection}
    ...                                                             enb_index=${enb_index}
    ...                                                             tput_collect_duration=${tput_collect_duration}
    ...                                                             ignore_time=${ignore_time}
    ...                                                             check_source=${check_source}
    ...    ELSE    Set Variable    ${tput_log_path}
    ${log_name}    Set Variable    4G_dl_Aasyslog_tupt.txt
    ${ul_log_name}    Set Variable    4G_ul_Aasyslog_tupt.txt
    ${log_full_path_ute}     join path    ${log_dir_ute}    ${log_name}
    ${ul_log_full_path_ute}     join path    ${log_dir_ute}    ${ul_log_name}
    OperatingSystem.Run   command=cat ${tput_log} | grep -a "INF/PDCP/STATS/DL: DRB S1" > ${log_full_path_ute}
    OperatingSystem.Run   command=cat ${tput_log} | grep -a "INF/PDCP/STATS/UL: DataPDU" > ${ul_log_full_path_ute}
    ${real_DL_tput}    4GL3call.check_4G_dl_throughput    log_file=${log_full_path_ute}
    ${real_UL_tput}    4GL3call.check_4G_ul_throughput    log_file=${ul_log_full_path_ute}
    ${expect_dl_tput}    Evaluate    int(${expect_dl_tput})
    ${expect_ul_tput}    Evaluate    int(${expect_ul_tput})
    ${dl_status}    Evaluate    ${real_DL_tput} >= ${expect_dl_tput}
    ${ul_status}    Evaluate    ${real_UL_tput} >= ${expect_ul_tput}
    Should Be True    ${dl_status}    msg=4G DL average throughput ${real_DL_tput} is lower than ${expect_dl_tput}
    Should Be True    ${ul_status}    msg=4G UL average throughput ${real_UL_tput} is lower than ${expect_ul_tput}

Get 4G Attach Cell Index From Wireshark
    [Arguments]    ${cpif_log_path}    ${cell_type}=lte
    ...            ${alias}=parser    ${timeout}=${600}
    ...            ${gnb_index}=${0}    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${1}    ${enb_connection}=enblte_${enb_index}
    ${4g_whether_in_gnb}    Check LTE Whether In Gnb    gnb_id=${gnb_index}    gnb_connection=${gnb_connection}
    Convert CPIF Pcap To Pdml    file_path=${cpif_log_path}    filter=s1ap    alias=${alias}
    ${cell_lte_identity_on_wireshark}    pcap.get_field_value_by_xpath    xpath=.//s1ap.CellIdentity
    ...                                                                   attribute_name=show
    ...                                                                   pcap_parser=${alias}
    ${cell_lte_identity_on_wireshark}    Get Substring     ${cell_lte_identity_on_wireshark[0]}    0   10
    ${cell_lte_identity_on_wireshark}    Convert To Binary    ${cell_lte_identity_on_wireshark}    base=16
    ${cell_lte_identity}    Convert To Integer    ${cell_lte_identity_on_wireshark}    base=2
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    Run Keyword If    ${4g_whether_in_gnb}==${False}
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If    ${4g_whether_in_gnb}==${False}    ${enb_connection}    ${gnb_connection}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    '${item['globalCellId']}'=${item['eutranCellId']}
    END
    ${cell_index_list}    Get Dictionary Keys    ${cell_list_info}
    ${eutranCellId_list}    Get Dictionary Values    ${cell_list_info}
    ${cellid_index}    Get Index From List    ${eutranCellId_list}    ${cell_lte_identity}
    Set Test Variable   ${attach_cell_index}   ${cell_index_list[${cellid_index}]}
    ${attach_cell_index}    Evaluate    int(${attach_cell_index})
    [Return]    ${attach_cell_index}
    [Teardown]    Teardown GNB and ENB Connections

Procedures.Start 4G Attach
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_type}=${ue_type}
    ...            ${ue_index}=${0}
    ...            ${gnb_index}=${0}
    ...            ${asik_connection_alias}=ASIK Master
    ...            ${enb_wireshark_log_prefix}=enb_wireshark_log
    ...            ${enb_index}=${1}
    ...            ${common_unit_index}=${0}
    ...            ${sleep_interval}=5 sec
    ...            ${du_index}=0
    ...            ${hwcheck_index}=${1}
    ...            ${power_reset}=False
    ...            ${cell_type}=lte
    ...            ${alias}=parser
    ...            ${timeout}=${600}
    ...            ${gnb_connection}=GNB_OAM
    ...            ${enb_connection}=enblte_${enb_index}
    ...            ${wireshark_log_prefix}=cpif_attach
    ...            ${ue_mode}=NSA
    ...            ${enb_host}=${None}
    ...            ${enb_user}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            ${enb_password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${is_multi_rat}    Check LTE Whether In Gnb    gnb_id=${gnb_index}    gnb_connection=${gnb_connection}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${wireshark_log_name}    Set Variable    ${wireshark_log_prefix}_${timestamp}
    ${enb_wireshark_log_name}    Set Variable    ${enb_wireshark_log_prefix}_${timestamp}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log     tcpdump_collector_name=${wireshark_log_name}
    ...    asik_connection_alias=${asik_connection_alias}
    ...    gnb_index=${gnb_index}
    ${enb_in_init_file_existence}    ${output}    Run Keyword And Ignore Error    Set Variable    ${tl.enbs[0]}
    ${enb_ip}    Run Keyword If    '${ue_mode}'=='NSA' and '${is_multi_rat}'=='${False}' and '${enb_in_init_file_existence}'=='FAIL'
    ...    Get ENB IPaddress From GNB    gnb_index=${gnb_index}
    ...    ELSE IF   '${ue_mode}'=='NSA' and '${is_multi_rat}'=='${False}' and '${enb_in_init_file_existence}'=='PASS'
    ...    Set Variable    ${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ${enb_host}    Set Variable If     '${ue_mode}'=='NSA' and '${is_multi_rat}'=='${False}'    ${enb_ip}    ${enb_host}
    Run Keyword If    '${ue_mode}'=='NSA'
    ...    Run Keyword And Continue On Failure    Start tcpdump Log On Enb     tcpdump_collector_name=${enb_wireshark_log_name}
    ...                                                                        enb_index=${enb_index}
    ...                                                                        common_unit_index=${common_unit_index}
    ...                                                                        is_multi_rat=${is_multi_rat}
    ...                                                                        gnb_index=${gnb_index}
    ...                                                                        enb_host=${enb_host}
    ...                                                                        enb_user=${enb_user}
    ...                                                                        enb_password=${enb_password}
    Sleep    ${sleep_interval}
    Log To Console    ${\n}INFO:-- start to attach --
    ${power_reset}    Set Variable If    'spark' in '${ue_type}'    true    ${power_reset}
    Run Keyword If    '${ue_type}'=='mtk'    MTK_common_keywords.Do UE Attach    ue_index=${ue_index}
    ...    ELSE    power_ue.UE Attach    ue_type=${ue_type}
    ...                                  ue_index=${ue_index}
    ...                                  gnb_index=${gnb_index}
    ...                                  hwcheck_index=${hwcheck_index}
    ...                                  du_index=${du_index}
    ...                                  power_reset=${power_reset}
    ${attach_time}    DateTime.Get Current Date    result_format=%Y-%m-%d%H:%M:%S
    Sleep    15sec
    ${wireshark_log_path_on_testPC}    Run Keyword And Continue On Failure    Stop tcpdump log collection
    ...    tcpdump_collector_name=${enb_wireshark_log_name}
    ${attach_cell_index}    Get 4G Attach Cell Index From Wireshark    cpif_log_path=${wireshark_log_path_on_testPC}
    ...                                                                cell_type=${cell_type}
    ...                                                                alias=${alias}
    ...                                                                timeout=${timeout}
    ...                                                                gnb_index=${gnb_index}
    ...                                                                enb_index=${enb_index}
    ...                                                                gnb_connection=${gnb_connection}
    ...                                                                enb_connection=${enb_connection}
    ${attach_info}    Create Dictionary    cpif_log_path=${wireshark_log_path_on_testPC}    attach_cell_index=${attach_cell_index}
    [Return]     ${attach_info}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    core.stop_collectors    names=${enb_wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=${enb_wireshark_log_name}


#--- Common keywords for Spark Tupt via mac tp---#
Check Tupt Via Spark App
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :Param:sleep_time---get tupt via keyword "get_mac_tp" every one sec.
    ...                :Param:get_times---how many times do get tupt via keyword "get_mac_tp"
    [Arguments]    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}    ${sleep_time}=1sec    ${get_times}=180
    ${ul_tupt_list}    Create List
    ${dl_tupt_list}    Create List
    FOR    ${i}    IN RANGE    ${get_times}
        ${tupt}    spark.check_throughput_on_ue    ue_alias=${ue_alias}
        Append To List    ${ul_tupt_list}    ${tupt[0]}
        Append To List    ${dl_tupt_list}    ${tupt[1]}
        Sleep    ${sleep_time}
    END
    ${ul_tupt_avg}    Evaluate    (sum(${ul_tupt_list})/len(${ul_tupt_list}))/1000/1000
    ${dl_tupt_avg}    Evaluate    (sum(${dl_tupt_list})/len(${dl_tupt_list}))/1000/1000
    ${avg_tupt}    Create List    ${ul_tupt_avg}    ${dl_tupt_avg}
    [Return]    ${avg_tupt}

Disable actDlSrsBm and releated params via Admin API
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...                Disable 8247 for N41+N71+N25 3CC, as N25 tput will degrade
    [Arguments]    ${cell_index}=${PCELL_INDEX}     ${value}=false     ${actDlMuMimoEnh_value}=false
    ...            ${dist_name}=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${cell_index}
    @{params_need_to_modify}    create list
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[0].global_bts_id}
    #cell level parameters
    &{actDlSrsBm_dict}    Create Dictionary    dist_name=${dist_name}
    ...                    parameter=actDlSrsBm    value=${value}
    &{actDlMuMimoEnh_dict}    Create Dictionary    dist_name=${dist_name}
    ...                    parameter=actDlMuMimoEnh    value=${actDlMuMimoEnh_value}
    &{actDlRankProbing_dict}    Create Dictionary    dist_name=${dist_name}
    ...                    parameter=actDlRankProbing    value=${value}
    &{actPdschBeamPowerBalance_dict}    Create Dictionary    dist_name=${dist_name}
    ...                    parameter=actPdschBeamPowerBalance    value=${value}
    &{actMuAwareTdSch_dict}    Create Dictionary
    ...              dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${cell_index}/NRDLMUMIMO-1
    ...              parameter=actMuAwareTdSch    value=${value}
    &{actSrsBeamFallbackByRetrx_dict}    Create Dictionary    dist_name=${dist_name}
    ...                    parameter=actSrsBeamFallbackByRetrx    value=${value}
    &{actDlSrsSubbandBm_dict}    Create Dictionary    dist_name=${dist_name}
    ...                    parameter=actDlSrsSubbandBm    value=${value}
    &{actDlSrsForCA_dict}    Create Dictionary    dist_name=${dist_name}
    ...                 parameter=actDlSrsForCA    value=${value}
    #bts level parameters
    &{actTddCsiRsOpt_dict}    Create Dictionary    dist_name=MRBTS-${MRBTS_ID} /NRBTS-${NRBTS_ID}
    ...                 parameter=actTddCsiRsOpt   value=${value}
    &{actTddCsiImRm_dict}    Create Dictionary    dist_name=MRBTS-${MRBTS_ID} /NRBTS-${NRBTS_ID}
    ...                 parameter=actTddCsiImRm   value=${value}
    #all cell level parameters
    ${all_cell_index}     create list    301   302  303   311   312   313
    FOR   ${cell_index}    IN    @{all_cell_index}
        &{actCsiRsMuting_dict}    Create Dictionary    dist_name=MRBTS-${MRBTS_ID} /NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
        ...                 parameter=actCsiRsMuting  value=${value}
        Append To List    ${params_need_to_modify}    ${actCsiRsMuting_dict}
        &{actSubTRSRateMatch_dict}    Create Dictionary    dist_name=MRBTS-${MRBTS_ID} /NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
        ...                 parameter=actSubTRSRateMatch   value=${value}
        Append To List    ${params_need_to_modify}     ${actSubTRSRateMatch_dict}
    END
    Append To List    ${params_need_to_modify}    ${actDlSrsBm_dict}    ${actDlMuMimoEnh_dict}    ${actMuAwareTdSch_dict}
    ...               ${actDlRankProbing_dict}    ${actPdschBeamPowerBalance_dict}
    ...               ${actSrsBeamFallbackByRetrx_dict}    ${actDlSrsSubbandBm_dict}    ${actDlSrsForCA_dict}
    ...               ${actTddCsiRsOpt_dict}    ${actTddCsiImRm_dict}
    Update Params Via RestApi    params_need_to_modify=${params_need_to_modify}    timeout=600

Get actDlSrsBm Param Value
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...                get the value of actDlSrsBm on GNB
    [Arguments]    ${cell_index}=${PCELL_INDEX}    ${timeout}=300    ${connection}=GNB_OAM    ${gnb_index}=0
    ...            ${dist_name}=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${cell_index}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${actDlSrsBm_value}    coam_parameter.get_single_value_from_scf_file    parameter=actDlSrsBm
    ...                                                                    dist_name=${dist_name}
    ...                                                                    connection=${connection}
    ...                                                                    timeout=300
    ${actDlMuMimoEnh_value}    coam_parameter.get_single_value_from_scf_file    parameter=actDlMuMimoEnh
    ...                                                                    dist_name=${dist_name}
    ...                                                                    connection=${connection}
    ...                                                                    timeout=300
    ${actMuAwareTdSch_value}    coam_parameter.get_single_value_from_scf_file    parameter=actMuAwareTdSch
    ...          dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${cell_index}/NRDLMUMIMO-1
    ...                                                                    connection=${connection}
    ...                                                                    timeout=300
    ${actDlRankProbing_value}    coam_parameter.get_single_value_from_scf_file    parameter=actDlRankProbing
    ...                                                                    dist_name=${dist_name}
    ...                                                                    connection=${connection}
    ...                                                                    timeout=300
    ${actDlSrsSubbandBm_value}    coam_parameter.get_single_value_from_scf_file    parameter=actDlSrsSubbandBm
    ...                                                                    dist_name=${dist_name}
    ...                                                                    connection=${connection}
    ...                                                                    timeout=300
    ${actPdschBeamPowerBalance_value}    coam_parameter.get_single_value_from_scf_file    parameter=actPdschBeamPowerBalance
    ...                                                                    dist_name=${dist_name}
    ...                                                                    connection=${connection}
    ...                                                                    timeout=300
    ${actSrsBeamFallbackByRetrx_value}    coam_parameter.get_single_value_from_scf_file    parameter=actSrsBeamFallbackByRetrx
    ...                                                                    dist_name=${dist_name}
    ...                                                                    connection=${connection}
    ...                                                                    timeout=300
	[Return]    ${actDlSrsBm_value}     ${actDlMuMimoEnh_value}    ${actMuAwareTdSch_value}    ${actDlRankProbing_value}
	...         ${actDlSrsSubbandBm_value}    ${actPdschBeamPowerBalance_value}    ${actSrsBeamFallbackByRetrx_value}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Lock AHFII FDD cells
    [Documentation]    author: lei.jia@nokia-sbell.com
    [Arguments]    ${ru_type}=AHFII    ${cell_type}=lte    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM    ${action}=block
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${True}
    ${lte_cell_list}    Get Cell List For Special RU    cell_type=${cell_type}
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    enb_index=${enb_index}
    ...    ru_type=${ru_type}    ru_index=${ru_index}
    FOR    ${lte_cell_index}    IN    @{lte_cell_list}
        Lock Or Unlock Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=${action}
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=${action}
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
    END


Lock AEHC FDD and NR Cells
    [Documentation]    author: lei.jia@nokia-sbell.com
    [Arguments]    ${ru_type}=AEHC    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM    ${action}=lock
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${True}
    ${lte_cell_list}    Get Cell List For Special RU    cell_type=lte
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type}
    ...    ru_index=${ru_index}
    ${nr_cell_list}    Get Cell List For Special RU    cell_type=nr
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type}
    ...    ru_index=${ru_index}
    ${used_nr_cell}    Convert to String     ${PCELL_INDEX}
    Remove Values From List 	${nr_cell_list} 	${used_nr_cell}
    FOR    ${cell_index}    IN    @{lte_cell_list}
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=lte    action=${action}
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=lte    action=${action}
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Sleep    10sec
    END
    FOR    ${cell_index}    IN    @{nr_cell_list}
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=nr    action=${action}
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=nr    action=${action}
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Sleep    10sec
    END

#--- Common keywords for Cases---#
Start To Capture Aasyslog
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${type}=MCU
    ...            ${log_ip}=127.0.0.1    ${gnb_path}=/tmp/    ${log_name}=Aasys_CCS_MCU.txt
    ...            ${aa_sys_mode}=2    ${aa_sys_addr}=0x7F000001    ${aa_sys_udp_port}=0xC738
    ...            ${filter}=${EMPTY}    ${host}=${EMPTY}    ${timeout}=15m
    ...            ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${host}   Run Keyword If   '${host}'==''   aasyslog.Get Host IP from gNB   gnb_index=${gnb_index}   du_index=${du_index}
    ...    ELSE   Set Variable   ${host}
    aasyslog.Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    ...                                             host=${host}    username=${username}    password=${password}
    aasyslog.Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}    type=${type}
    ...                               aa_sys_mode=${aa_sys_mode}    aa_sys_addr=${aa_sys_addr}    aa_sys_udp_port=${aa_sys_udp_port}
    ...                               host=${host}    username=${username}    password=${password}
    aasyslog.Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=${filter}
    ...                                          gnb_path=${gnb_path}    log_name=${log_name}
    ...                                          host=${host}    username=${username}    password=${password}
    ...                                          log_ip=${log_ip}    timeout=${timeout}
    [Return]    ${host}

Stop To Capture And Download Aasyslog
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${host}    ${gnb_index}=0    ${du_index}=0    ${Teardown_after_finished}=${True}
    ...            ${gnb_path}=/tmp/    ${log_name}=Aasys_CCS_MCU.txt
    ...            ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    aasyslog.Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    ...                                             host=${host}    username=${username}    password=${password}
    ${current_time}    DateTime.Get Current Date    result_format=%Y-%m-%d_%H:%M:%S
    ${local_path}    set variable    ${OUTPUT_DIR}/${current_time}_${log_name}
    aasyslog.Download Aasyslog File From GNB    log_path=${gnb_path}${log_name}    local_path=${local_path}
    ...                                         gnb_index=${gnb_index}    du_index=${du_index}
    ...                                         host=${host}    username=${username}    password=${password}
    [Return]    ${local_path}
    [Teardown]    Run Keyword If    '${Teardown_after_finished}'=='${True}'
    ...           aasyslog.Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    ...                                                           host=${host}    username=${username}    password=${password}

Update Values Of Some Parameters
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                For caseID: 5603009
    [Arguments]    ${cell_index}
    ...            ${lte_cell_earfcnDL}
    ...            ${nrhoirDNList_value}=${None}
    ...            ${measurement_time}=5min
    ...            ${b2Threshold1hoRsrp_value}=76
    ...            ${b2Threshold2hoRsrp_value}=50
    ...            ${a2ThresholdhoSsbRsrpSA_value}=76
    ...            ${a1ThresholdhoSsbRsrpSA_value}=78
    ...            ${actInterRatHoSADlDataForward_value}=true
    ...            ${a1ThresholdSCellAddSsbRsrpTDD_value}=100
    ...            ${a1ThresholdSCellAddSsbRsrpFDD_value}=100
    ...            ${connection}=GNB_OAM
    ...            ${gnb_index}=0
    ...            ${timeout}=300
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${MOs}    coam.get_managed_objects    class_name=NRHOIR_A    connection=${connection}    timeout=${timeout}
    FOR    ${mo}    IN    @{MOs}
        ${nrhoir_id}    Set Variable    ${mo['distName'].split('/')[-1].split('-')[-1]}
        ${nrhoir_dist_name}    Set Variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRHOIR-${nrhoir_id}
        ${earfcnValue}    Set Variable    ${mo['parameters']['earfcnValue']}
        Run Keyword If    '${earfcnValue}'=='${lte_cell_earfcnDL}' and ('${nrhoir_dist_name}' in ${nrhoirDNList_value})    Exit For Loop
    END
    ${cell_index}    Evaluate    str(${cell_index})
    ${miNrNRPFW}    Create Dictionary    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRPMRNL-1
    ...                                  parameter=miNrNRPFW
    ...                                  value=${measurement_time}
    &{a1ThresholdSCellAddSsbRsrp}   Create Dictionary    a1ThresholdSCellAddSsbRsrpFDD=${a1ThresholdSCellAddSsbRsrpFDD_value}
    ...                                                  a1ThresholdSCellAddSsbRsrpTDD=${a1ThresholdSCellAddSsbRsrpTDD_value}
    ${actInterRatHoSADlDataForward}    Create Dictionary    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ...                                                     parameter=actInterRatHoSADlDataForward
    ...                                                     value=${actInterRatHoSADlDataForward_value}
    ${b2Threshold1hoRsrp}    Create Dictionary    dist_name=${nrhoir_dist_name}
    ...                                           parameter=b2Threshold1hoRsrp
    ...                                           value=${b2Threshold1hoRsrp_value}
    &{b2Threshold2hoRsrp_param}    Create Dictionary    b2Threshold2hoRsrp=${b2Threshold2hoRsrp_value}
    ${b2Threshold2hoRsrp}    Evaluate
    ...    {'dist_name': '${nrhoir_dist_name}', 'parameter': 'eutraB2MeashoRsrp','value':[&{b2Threshold2hoRsrp_param}]}
    ${a2ThresholdhoSsbRsrpSA_dist_name}    Set Variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${cell_index}
    &{a2ThresholdhoSsbRsrpSA_param}    Create Dictionary    a2ThresholdhoSsbRsrpSA=${a2ThresholdhoSsbRsrpSA_value}
    ${a2ThresholdhoSsbRsrpSA}    Evaluate
    ...    {'dist_name': '${a2ThresholdhoSsbRsrpSA_dist_name}', 'parameter': 'a2MeashoSsbRsrpSA','value':[&{a2ThresholdhoSsbRsrpSA_param}]}
    &{a1ThresholdhoSsbRsrpSA_param}    Create Dictionary    a1ThresholdhoSsbRsrpSA=${a1ThresholdhoSsbRsrpSA_value}
    ${a1ThresholdhoSsbRsrpSA}    Evaluate
    ...    {'dist_name': '${a2ThresholdhoSsbRsrpSA_dist_name}', 'parameter': 'a1MeashoSsbRsrpSA','value':[&{a1ThresholdhoSsbRsrpSA_param}]}
    &{a1MeasSsbRsrp}    Evaluate
    ...    {'dist_name': '${a2ThresholdhoSsbRsrpSA_dist_name}','parameter': 'a1MeasSCellAddSsbRsrp','value':[&{a1ThresholdSCellAddSsbRsrp}]}
    @{param_list}    Create List    ${miNrNRPFW}    ${actInterRatHoSADlDataForward}    ${b2Threshold1hoRsrp}
    ...                             ${b2Threshold2hoRsrp}    ${a2ThresholdhoSsbRsrpSA}    ${a1MeasSsbRsrp}    ${a1ThresholdhoSsbRsrpSA}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    connection=${connection}    timeout=${timeout}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Update values of some ANR parameters
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    ...                For caseID: 5603090
    [Arguments]    ${pcell_index}
    ...            ${ho_pcell_index}
    ...            ${ue_mode}=SA
    ...            ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...            ${MRBTS_id}=${tl.gnbs[0].instance_id}
    ...            ${drxLongCycle_value}=320ms
    ...            ${drxOnDurationTimer_value}=10ms
    ...            ${cellBarred_value}=notBarred
    ...            ${a2ThresholdhoSsbRsrpSA_value}=76
    ...            ${a2ThresholdhoSsbRsrp_value}=76
    ...            ${a1ThresholdhoSsbRsrp_value}=78
    ...            ${a1ThresholdhoSsbRsrpSA_value}=78
    ...            ${a2MeasReleaseEnabled_value}=none
    ...            ${a3MeasEnabled}=rsrp
    ...            ${a3HysteresisSsbRsrp}=2
    ...            ${a3OffsetSsbRsrp}=8
    ...            ${connection}=GNB_OAM
    ...            ${gnb_index}=0
    ...            ${timeout}=300
    @{param_list}    Create List
    ${pcell_nrhoif_dist_name}    Get expected NRHOIF Value for specified cell
    ...                pcell_index=${pcell_index}    scell_index=${ho_pcell_index}
    ...                gnb_index=${gnb_index}    timeout=${timeout}    connection=${connection}
    ${a3MeasEnabled}    Create Dictionary    dist_name=${pcell_nrhoif_dist_name}
    ...                                                parameter=a3MeasEnabled
    ...                                                value=${a3MeasEnabled}
    &{a3SsbRsrp_param}    Create Dictionary    a3HysteresisSsbRsrp=${a3HysteresisSsbRsrp}
    ...                                        a3OffsetSsbRsrp=${a3OffsetSsbRsrp}
    ${a3SsbRsrp}    Evaluate
    ...    {'dist_name': '${pcell_nrhoif_dist_name}', 'parameter': 'a3MeasSsbRsrp','value':[&{a3SsbRsrp_param}]}
    Append To List    ${param_list}      ${a3SsbRsrp}
    @{cell_list}    Create List     ${pcell_index}     ${ho_pcell_index}
    FOR    ${cell}   IN    @{cell_list}
        ${cellBarred}     Create Dictionary      dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                      parameter=cellBarred
        ...                                      value=${cellBarred_value}
        ${a2MeasReleaseEnabled}    Create Dictionary      dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                                parameter=a2MeasReleaseEnabled
        ...                                                value=${a2MeasReleaseEnabled_value}
        &{a2ThresholdhoSsbRsrpSA_param}    Create Dictionary     a2ThresholdhoSsbRsrpSA=${a2ThresholdhoSsbRsrpSA_value}
        &{a2ThresholdhoSsbRsrp_param}    Create Dictionary     a2ThresholdhoSsbRsrp=${a2ThresholdhoSsbRsrp_value}
        ${dist_name}    Set Variable    MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ${a2ThresholdhoSsbRsrpSA}    Evaluate
        ...    {'dist_name': '${dist_name}', 'parameter': 'a2MeashoSsbRsrpSA','value':[&{a2ThresholdhoSsbRsrpSA_param}]}
        &{drxProfile_values}    Create Dictionary    drxLongCycle=${drxLongCycle_value}
        ...                                            drxOnDurationTimer=${drxOnDurationTimer_value}
        ${drxLongCycle}    Evaluate    {'dist_name': '${dist_name}', 'parameter': 'drxProfileNrAnr','value':[&{drxProfile_values}]}
        ${a2ThresholdhoSsbRsrp}      Evaluate
        ...    {'dist_name': '${dist_name}', 'parameter': 'a2MeashoSsbRsrp','value':[&{a2ThresholdhoSsbRsrp_param}]}
        &{a1ThresholdhoSsbRsrpSA_param}    Create Dictionary    a1ThresholdhoSsbRsrpSA=${a1ThresholdhoSsbRsrpSA_value}
        ${a1ThresholdhoSsbRsrpSA}    Evaluate
        ...    {'dist_name': '${dist_name}', 'parameter': 'a1MeashoSsbRsrpSA','value':[&{a1ThresholdhoSsbRsrpSA_param}]}
        &{a1ThresholdhoSsbRsrp_param}    Create Dictionary    a1ThresholdhoSsbRsrp=${a1ThresholdhoSsbRsrp_value}
        ${a1ThresholdhoSsbRsrp}    Evaluate
        ...    {'dist_name': '${dist_name}', 'parameter': 'a1MeashoSsbRsrp','value':[&{a1ThresholdhoSsbRsrp_param}]}
        Append To List    ${param_list}    ${drxLongCycle}    ${cellBarred}
        Run Keyword If   '${ue_mode}'=='NSA'     Append To List    ${param_list}      ${a2ThresholdhoSsbRsrp}     ${a2MeasReleaseEnabled}
        ...                                                                           ${a1ThresholdhoSsbRsrp}
        ...   ELSE IF    '${ue_mode}'=='SA'      Append To List    ${param_list}      ${a2ThresholdhoSsbRsrpSA}    ${a1ThresholdhoSsbRsrpSA}
    END
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    connection=${connection}   timeout=${timeout}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Create maxCsirsNumber parameters
    [Arguments]      ${cell_idx}=${PCELL_INDEX}
    ...              ${maxCsirsNumber}=none
    ...              ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...              ${MRBTS_id}=${tl.gnbs[0].instance_id}
    ...              ${dist_name}=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_idx}
    ${maxCsirsNumber_params}    create dictionary    maxCsirsNumber=${maxCsirsNumber}
    ${maxCsirsNumber_params_list}    create list    ${maxCsirsNumber_params}
    ${maxCsirsNumber_mo}    create dictionary    dist_name=${dist_name}    value=${maxCsirsNumber_params_list}
    ...    parameter=periodicCsiAcquisition
    ${maxCsirsNumber_mo_list}    create list    ${maxCsirsNumber_mo}
    [Return]    ${maxCsirsNumber_mo_list}

Get maxCsirsNumber value From SCF
    [Arguments]      ${cell_idx}=${PCELL_INDEX}
    ...              ${connection}=GNB_OAM
    ...              ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...              ${MRBTS_id}=${tl.gnbs[0].instance_id}
    Connect to gnb coam via ssl
    ${modify_params}    Create maxCsirsNumber parameters    cell_idx=${cell_idx}
    ${periodicCsiAcquisition_values}    coam_parameter.get_list_values_from_scf_file
    ...    parameters=${modify_params}
    ...    connection=${connection}
    ${maxCsirsNumber}    Set Variable    ${periodicCsiAcquisition_values[0]['value'][0]['maxCsirsNumber']}
    [Return]    ${maxCsirsNumber}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Get and Modify actCsirsMultiplexing via Admin API
    [Documentation]   lei.jia@nokia-sbell.com
    ...           This keyword is used to modify paramters online via admin CLI.
    [Arguments]      ${timeout}=15 min
    Connect to gnb coam via ssl    connection=GNB_OAM
    ${dist_name}    set variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${PCELL_INDEX}
    ${cur_para_value}    coam_parameter.get_single_value_from_scf_file    parameter=actCsirsMultiplexing
    ...                                                                   dist_name=${dist_name}    connection=GNB_OAM
    ...                                                                   timeout=300
    ${value}    Set Variable If    '${cur_para_value}'=='false'    true    false
    Update actCsirsMultiplexing via Admin API    dist_name=${dist_name}    value=${value}

Update actCsirsMultiplexing via Admin API
    [Arguments]    ${dist_name}=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${PCELL_INDEX}    ${value}=true
    @{params_need_to_modify}    create list
    &{para_dict}    Create Dictionary    dist_name=${dist_name}
    ...                                  parameter=actCsirsMultiplexing    value=${value}
    Append To List    ${params_need_to_modify}    ${para_dict}
    Update Params Via RestApi    params_need_to_modify=${params_need_to_modify}

Update maxCsirsNumber via Admin API
    [Arguments]    ${maxCsirsNumber}=4
    ${maxCsirsNumber_mo_list}    Create maxCsirsNumber parameters    maxCsirsNumber=${maxCsirsNumber}
    Update Params Via RestApi    params_need_to_modify=${maxCsirsNumber_mo_list}

Update BasedPCellSwitchEnabled Status
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                Update a1BasedPCellSwitchEnabled and a2BasedPCellSwitchEnabled of all cells status
    [Arguments]    ${a1BasedPCellSwitchEnabled_value}=false
    ...            ${a2BasedPCellSwitchEnabled_value}=false
    ...            ${class_name}=NRHOIF_A
    ...            ${timeout}=300
    ...            ${connection}=GNB_OAM
    ...            ${gnb_index}=0
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${MOs}    coam.get_managed_objects    class_name=${class_name}    connection=${connection}    timeout=${timeout}
    @{param_list}    Create List
    FOR    ${mo}    IN    @{MOs}
        ${mrbts_id}    Set Variable    ${mo['distName'].split('/')[-4].split('-')[-1]}
        ${nrbts_id}    Set Variable    ${mo['distName'].split('/')[-3].split('-')[-1]}
        ${nrcell_id}    Set Variable    ${mo['distName'].split('/')[-2].split('-')[-1]}
        ${nrhoif_id}    Set Variable    ${mo['distName'].split('/')[-1].split('-')[-1]}
        ${dist_name}    Set Variable    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-${nrhoif_id}
        ${a1BasedPCellSwitchEnabled}    Create Dictionary    dist_name=${dist_name}
        ...                                                  parameter=a1BasedPCellSwitchEnabled
        ...                                                  value=${a1BasedPCellSwitchEnabled_value}
        ${a2BasedPCellSwitchEnabled}    Create Dictionary    dist_name=${dist_name}
        ...                                                  parameter=a2BasedPCellSwitchEnabled
        ...                                                  value=${a2BasedPCellSwitchEnabled_value}
        Append To List    ${param_list}    ${a1BasedPCellSwitchEnabled}    ${a2BasedPCellSwitchEnabled}
    END
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    connection=${connection}    timeout=${timeout}
	[Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get Some Related Parameters Of LTE Cell
    [Documentation]   Author:jun.8.chen@nokia-sbell.com
    ...               Get eutranCellId, physicalCellId and earfcnDL Of LTE Cell
    [Arguments]    ${cell_index}    ${timeout}=120
    ...            ${gnb_id}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${1}    ${enb_connection}=enblte_${enb_index}
    Log to console    ${\n}----Get eutranCellId, physicalCellId and earfcnDL Of LTE Cell----
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_id}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}'
    ...    ${enb_connection}    ${gnb_connection}
    ${cell_info}   coam.get_cells_info    cell_type=lte    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        ${eutranCellId}    Set Variable    ${item['eutranCellId']}
        ${physicalCellId}    Set Variable    ${item['physicalCellId']}
        ${earfcnDL}    Set Variable    ${item['earfcnDownlink']}
        Run Keyword If    'LNCEL-${cell_index}' in '${item['id']['configuration']}'    Exit For Loop
    END
    [Return]    ${eutranCellId}    ${physicalCellId}    ${earfcnDL}
    [Teardown]    Teardown GNB and ENB Connections

Modify Pcell Change Based On A1 Related Paremeters
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${pcell_index}
    ...            ${scell_index}
    ...            ${actConnectedModeMobilityCA}=true
    ...            ${a1BasedPCellSwitchEnabled}=true
    ...            ${a2MeasSCellRelEnabled}=rsrp
    ...            ${a2HysteresisSCellRelSsbRsrp}=0
    ...            ${a2ThresholdSCellRelSsbRsrp}=34
    ...            ${a1MeasPCellSwitchEnabled}=rsrp
    ...            ${a1HysteresisPCellSwitchSsbRsrp}=0
    ...            ${a1ThresholdPCellSwitchSsbRsrp}=80
    ...            ${a1MeashoEnabledSA}=none
    ...            ${a2MeashoEnabledSA}=none
    ...            ${connection}=GNB_OAM
    ...            ${gnb_index}=0
    ...            ${timeout}=300
    ${actConnectedModeMobilityCA}    Create Dictionary    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRDU-1
    ...                                                   parameter=actConnectedModeMobilityCA
    ...                                                   value=${actConnectedModeMobilityCA}
#    ${arfcnSsbPbch}    Get The ArfcnSsbPbch Value Of Cell    cell_index=${scell_index}    gnb_index=${gnb_index}    timeout=${timeout}
#    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
#    ${MOs}    coam.get_managed_objects    class_name=NRHOIF_A    connection=${connection}    timeout=${timeout}
#    FOR    ${mo}    IN    @{MOs}
#        ${mrbts_id}    Set Variable    ${mo['distName'].split('/')[-4].split('-')[-1]}
#        ${nrbts_id}    Set Variable    ${mo['distName'].split('/')[-3].split('-')[-1]}
#        ${nrcell_id}    Set Variable    ${mo['distName'].split('/')[-2].split('-')[-1]}
#        ${nrhoif_id}    Set Variable    ${mo['distName'].split('/')[-1].split('-')[-1]}
#        ${dist_name}    Set Variable    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-${nrhoif_id}
#        ${ssbFrequency}    Set Variable    ${mo['parameters']['ssbFrequency']}
#        Run Keyword If    '${ssbFrequency}'=='${arfcnSsbPbch}' and '${nrcell_id}'=='${pcell_index}'    Exit For Loop
#    END
    ${dist_name}    Get expected NRHOIF Value for specified cell
    ...                pcell_index=${pcell_index}    scell_index=${scell_index}
    ...                gnb_index=${gnb_index}    timeout=${timeout}    connection=${connection}
    ${a1BasedPCellSwitchEnabled}    Create Dictionary    dist_name=${dist_name}
    ...                                                  parameter=a1BasedPCellSwitchEnabled
    ...                                                  value=${a1BasedPCellSwitchEnabled}
    ${pcell_distname}    Set Variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${pcell_index}
    ${a2MeasSCellRelEnabled}    Create Dictionary    dist_name=${pcell_distname}
    ...                                              parameter=a2MeasSCellRelEnabled
    ...                                              value=${a2MeasSCellRelEnabled}
    &{a2MeasSCellRelSsbRsrp_param}    Create Dictionary    a2HysteresisSCellRelSsbRsrp=${a2HysteresisSCellRelSsbRsrp}
    ...                                                    a2ThresholdSCellRelSsbRsrp=${a2ThresholdSCellRelSsbRsrp}
    ${a2MeasSCellRelSsbRsrp}    Evaluate
    ...    {'dist_name': '${pcell_distname}', 'parameter': 'a2MeasSCellRelSsbRsrp','value':[&{a2MeasSCellRelSsbRsrp_param}]}
    ${scell_distname}    Set Variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${scell_index}
    ${a1MeasPCellSwitchEnabled}    Create Dictionary    dist_name=${scell_distname}
    ...                                                 parameter=a1MeasPCellSwitchEnabled
    ...                                                 value=${a1MeasPCellSwitchEnabled}
    ${a1MeashoEnabledSA}    Create Dictionary    dist_name=${scell_distname}    parameter=a1MeashoEnabledSA    value=${a1MeashoEnabledSA}
    ${a2MeashoEnabledSA}    Create Dictionary    dist_name=${scell_distname}    parameter=a2MeashoEnabledSA    value=${a2MeashoEnabledSA}
    &{a1MeasPCellSwitchSsbRsrp_param}    Create Dictionary    a1HysteresisPCellSwitchSsbRsrp=${a1HysteresisPCellSwitchSsbRsrp}
    ...                                                       a1ThresholdPCellSwitchSsbRsrp=${a1ThresholdPCellSwitchSsbRsrp}
    ${a1MeasPCellSwitchSsbRsrp}    Evaluate
    ...    {'dist_name': '${scell_distname}', 'parameter': 'a1MeasPCellSwitchSsbRsrp','value':[&{a1MeasPCellSwitchSsbRsrp_param}]}
    @{param_list}    Create List    ${actConnectedModeMobilityCA}    ${a1BasedPCellSwitchEnabled}
    ...                             ${a2MeasSCellRelEnabled}    ${a2MeasSCellRelSsbRsrp}
    ...                             ${a1MeasPCellSwitchEnabled}    ${a1MeasPCellSwitchSsbRsrp}
    ...                             ${a1MeashoEnabledSA}    ${a2MeashoEnabledSA}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    connection=${connection}    timeout=${timeout}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get expected NRHOIF Value for specified cell
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]        ${pcell_index}    ${scell_index}
    ...                ${gnb_index}=${0}    ${timeout}=300    ${connection}=GNB_OAM
    ${arfcnSsbPbch}    Get The ArfcnSsbPbch Value Of Cell    cell_index=${scell_index}    gnb_index=${gnb_index}    timeout=${timeout}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${MOs}    coam.get_managed_objects    class_name=NRHOIF_A    connection=${connection}    timeout=${timeout}
    FOR    ${mo}    IN    @{MOs}
        ${mrbts_id}    Set Variable    ${mo['distName'].split('/')[-4].split('-')[-1]}
        ${nrbts_id}    Set Variable    ${mo['distName'].split('/')[-3].split('-')[-1]}
        ${nrcell_id}    Set Variable    ${mo['distName'].split('/')[-2].split('-')[-1]}
        ${nrhoif_id}    Set Variable    ${mo['distName'].split('/')[-1].split('-')[-1]}
        ${NRHOIF_dist_name}    Set Variable    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-${nrhoif_id}
        ${ssbFrequency}    Set Variable    ${mo['parameters']['ssbFrequency']}
        Run Keyword If    '${ssbFrequency}'=='${arfcnSsbPbch}' and '${nrcell_id}'=='${pcell_index}'    Exit For Loop
    END
    [Return]    ${NRHOIF_dist_name}



Modify Pcell Change Based On A2 Related Paremeters
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${pcell_index}
    ...            ${scell_index}
    ...            ${actInterMeNBMobility}=true
    ...            ${actInterFreqHoSA}=true
    ...            ${a2BasedPCellSwitchEnabled}=true
    ...            ${thresholdPCellSwitchTargetRsrp}=50
    ...            ${thresholdPCellSwitchTargetRsrq}=40
    ...            ${a2MeasPCellSwitchEnabled}=rsrp
    ...            ${a2HysteresisPCellSwitchSsbRsrp}=0
    ...            ${a2ThresholdPCellSwitchSsbRsrp}=76
    ...            ${a2ThresholdhoSsbRsrpSA}=66
    ...            ${connection}=GNB_OAM
    ...            ${gnb_index}=0
    ...            ${timeout}=300
    ${actInterMeNBMobility}    Create Dictionary    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ...                                             parameter=actInterMeNBMobility
    ...                                             value=${actInterMeNBMobility}
    ${actInterFreqHoSA}    Create Dictionary    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ...                                         parameter=actInterFreqHoSA
    ...                                         value=${actInterFreqHoSA}
#    ${arfcnSsbPbch}    Get The ArfcnSsbPbch Value Of Cell    cell_index=${scell_index}    gnb_index=${gnb_index}    timeout=${timeout}
#    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
#    ${MOs}    coam.get_managed_objects    class_name=NRHOIF_A    connection=${connection}    timeout=${timeout}
#    FOR    ${mo}    IN    @{MOs}
#        ${mrbts_id}    Set Variable    ${mo['distName'].split('/')[-4].split('-')[-1]}
#        ${nrbts_id}    Set Variable    ${mo['distName'].split('/')[-3].split('-')[-1]}
#        ${nrcell_id}    Set Variable    ${mo['distName'].split('/')[-2].split('-')[-1]}
#        ${nrhoif_id}    Set Variable    ${mo['distName'].split('/')[-1].split('-')[-1]}
#        ${dist_name}    Set Variable    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-${nrhoif_id}
#        ${ssbFrequency}    Set Variable    ${mo['parameters']['ssbFrequency']}
#        Run Keyword If    '${ssbFrequency}'=='${arfcnSsbPbch}' and '${nrcell_id}'=='${pcell_index}'    Exit For Loop
#    END
    ${dist_name}    Get expected NRHOIF Value for specified cell
    ...                pcell_index=${pcell_index}    scell_index=${scell_index}
    ...                gnb_index=${gnb_index}    timeout=${timeout}    connection=${connection}
    ${a2BasedPCellSwitchEnabled}    Create Dictionary    dist_name=${dist_name}
    ...                                                  parameter=a2BasedPCellSwitchEnabled
    ...                                                  value=${a2BasedPCellSwitchEnabled}
    ${thresholdPCellSwitchTargetRsrp}    Create Dictionary    dist_name=${dist_name}
    ...                                                       parameter=thresholdPCellSwitchTargetRsrp
    ...                                                       value=${thresholdPCellSwitchTargetRsrp}
    ${thresholdPCellSwitchTargetRsrq}    Create Dictionary    dist_name=${dist_name}
    ...                                                       parameter=thresholdPCellSwitchTargetRsrq
    ...                                                       value=${thresholdPCellSwitchTargetRsrq}
    ${pcell_distname}    Set Variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${pcell_index}
    ${a2MeasPCellSwitchEnabled}    Create Dictionary    dist_name=${pcell_distname}
    ...                                                 parameter=a2MeasPCellSwitchEnabled
    ...                                                 value=${a2MeasPCellSwitchEnabled}
    &{a2MeasPCellSwitchSsbRsrp_param}    Create Dictionary    a2HysteresisPCellSwitchSsbRsrp=${a2HysteresisPCellSwitchSsbRsrp}
    ...                                                       a2ThresholdPCellSwitchSsbRsrp=${a2ThresholdPCellSwitchSsbRsrp}
    ${a2MeasPCellSwitchSsbRsrp}    Evaluate
    ...    {'dist_name': '${pcell_distname}', 'parameter': 'a2MeasPCellSwitchSsbRsrp','value':[&{a2MeasPCellSwitchSsbRsrp_param}]}
    &{a2MeashoSsbRsrpSA_param}    Create Dictionary    a2ThresholdhoSsbRsrpSA=${a2ThresholdhoSsbRsrpSA}
    ${a2MeashoSsbRsrpSA}    Evaluate
    ...    {'dist_name': '${pcell_distname}', 'parameter': 'a2MeashoSsbRsrpSA','value':[&{a2MeashoSsbRsrpSA_param}]}
    @{param_list}    Create List    ${actInterMeNBMobility}    ${actInterFreqHoSA}
    ...                             ${a2BasedPCellSwitchEnabled}    ${thresholdPCellSwitchTargetRsrp}    ${thresholdPCellSwitchTargetRsrq}
    ...                             ${a2MeasPCellSwitchEnabled}    ${a2MeasPCellSwitchSsbRsrp}    ${a2MeashoSsbRsrpSA}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    connection=${connection}    timeout=${timeout}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check InterRAT HO To LTE Success
    [Documentation]   Auther:jun.8.chen@nokia-sbell.com
    ...               Check 911 call success via wireshark log
    [Arguments]    ${log_path}    ${eutranCellId}    ${physicalCellId}    ${filter}=e1ap||f1ap||ngap||nr-rrc||xnap    ${alias}=parser
    #---fileter the Handover Required---#
    Convert CPIF Pcap To Pdml    file_path=${log_path}    filter=${filter}    alias=${alias}
    ${cellIdentity_value}    Get Field Value From Pdml    filter_expression=ngap.procedureCode == 12 && s1ap.CellIdentity
    ...                                                   xpath=.//s1ap.CellIdentity
    ...                                                   attribute_name=show
    ${cellIdentity_value}    Get Substring     ${cellIdentity_value[0]}    0   10
    ${cellIdentity_value}    Convert To Binary    ${cellIdentity_value}    base=16
    ${cellIdentity_value}    Convert To Integer    ${cellIdentity_value}    base=2
    Should Be Equal    ${cellIdentity_value}    ${eutranCellId}    msg=InterRAT_HO_LTE is not successful

    #---fileter the required MR of EUTRA ho---#
    Convert CPIF Pcap To Pdml    file_path=${log_path}    filter=nr-rrc.MeasResultEUTRA_element    alias=${alias}
    ${eutra_PhysCellId}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.MeasResultEUTRA_element/nr-rrc.eutra_PhysCellId
    ...                                                     pcap_parser=${alias}
    ${eutra_PhysCellId}    Remove Duplicates    ${eutra_PhysCellId}
    ${eutra_PhysCellId_length}    Get Length    ${eutra_PhysCellId}
    run keyword if  not '${eutra_PhysCellId_length}'=='1'    Fail    msg=mr abnormal!!!
    ${physicalCellId}    Evaluate    str(${physicalCellId})
    Should Be Equal    ${eutra_PhysCellId}[0]    ${physicalCellId}    msg=InterRAT_HO_LTE is not successful

Check Pcell Change Success
    [Documentation]   Auther:jun.8.chen@nokia-sbell.com
    ...               Check Pcell Change Success in wireshark
    ...               A1 for TDD, A2 for FDD, all for scell
    [Arguments]    ${attach_info}
    ...            ${pcell_change_wireshark_log}
    ...            ${event_type}
    ...            ${scell_index}
    ...            ${after_change_scell_index}
    ...            ${rrc_message_filter}=${SA_RRC_RECONFIGURE_FILTER_ATTACH}
    ...            ${filter}=e1ap||f1ap||ngap||nr-rrc||xnap
    ...            ${alias}=parser
    ...            ${mode}=SA
    ...            ${addition_method}=A1
    #---from cell index change into pci---#
    ${pcell_pci}    Evaluate    str(${PCELL_MAPPING['physicalCellId']})
    ${scell_pci}    Evaluate    str(${SCELL_MAPPING[${scell_index}]['all_cell_info']['physicalCellId']})
    ${after_change_scell_pci}    Evaluate    str(${HO_SCELL_MAPPING[${after_change_scell_index}]['all_cell_info']['physicalCellId']})
    ${rrc_message_filter}    Set Variable If    '${mode}'=='SA'    ${${mode}_RRC_RECONFIGURE_FILTER_SCELL_ADDITION}
    ...                                                            ${${mode}_RRC_RECONFIGURE_FILTER_SCELL_ADDITION_${addition_method}}
    ${meas_info_in_rrc}    Get Info From RRC Reconfiguration    cpif_log_path=${attach_info['cpif_log_path']}
    ...                                                         message_filter_expression=${rrc_message_filter}
    ...                                                         alias=${alias}
    Convert CPIF Pcap To Pdml    file_path=${attach_info['cpif_log_path']}
    ...                          filter=f1ap.procedureCode == 12 && nr-rrc.measObjectId && nas-5gs
    ...                          alias=${alias}
    ${measObjectId}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.MeasObjectToAddMod_element/nr-rrc.measObjectId    pcap_parser=${alias}
    ${ssbfrequency}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.measObjectNR_element/nr-rrc.ssbFrequency    pcap_parser=${alias}
    ${meas_list}    Get Dictionary Keys    ${meas_info_in_rrc['add_meas_info']}
    FOR    ${meas}    IN    @{meas_list}
        ${mesObj}    Set Variable    ${meas_info_in_rrc['add_meas_info']['${meas}']['mesObj']}
        Run Keyword If    '${mesObj}'=='${measObjectId}[0]'    Set To Dictionary    ${meas_info_in_rrc['add_meas_info']['${meas}']}
        ...    ssbfrequency    ${ssbfrequency}[0]
    END
    ${ssbfreq_regex}    Set Variable If    '${event_type}'=='A2'
    ...                                    x[1]['ssbfrequency']=='${PCELL_MAPPING['ssbfrequency']}'
    ...                                    '${event_type}'=='A1'
    ...                                    x[1]['ssbfrequency']=='${SCELL_MAPPING[${scell_index}]['all_cell_info']['ssbfrequency']}'
    ${event_regex}    Set Variable    x[1]['event_type']=='${event_type}'
    ${lambda_expression}    Set Variable    x:${ssbfreq_regex} and ${event_regex}
    ${meas_info_mapping}    Evaluate    list(filter(lambda ${lambda_expression},${meas_info_in_rrc['add_meas_info']}.items()))
    ${meas_id_length}    Get Length    ${meas_info_mapping}
    Run Keyword If    ${meas_id_length}==${0}    Fail    msg=event type ${event_type} is not configured
    Should Be Equal   ${meas_id_length}    ${1}    msg=more than one measid for event type ${event_type} is filter out,not a valid result.
    ${add_meas_id_in_rrc}    Set Variable    ${meas_info_mapping[0][0]}

    Convert CPIF Pcap To Pdml    file_path=${pcell_change_wireshark_log}
    ...                          filter=nr-rrc.measurementReport_element && nr-rrc.measId
    ...                          alias=${alias}
    ${measId_list}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.measId    pcap_parser=${alias}
    List Should Contain Value    ${measId_list}    ${add_meas_id_in_rrc}    msg=Measurement Report For ${event_type} is not triggered.

    #---fileter the required Measurement Report---#
    Convert CPIF Pcap To Pdml    file_path=${pcell_change_wireshark_log}
    ...                          filter=f1ap.procedureCode==13 && nr-rrc.measResultServingMOList && nr-rrc.measId==${add_meas_id_in_rrc}
    ...                          alias=${alias}
    ${pci_list_before_change}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.physCellId    pcap_parser=${alias}
    Should Be Equal    ${pci_list_before_change}[0]    ${pcell_pci}
    Should Be Equal    ${pci_list_before_change}[-1]    ${scell_pci}
    #---fileter the required pci of ho_pcell in rrc reconfiguration after pcell change---#
    Convert CPIF Pcap To Pdml    file_path=${pcell_change_wireshark_log}
    ...                          filter=f1ap.procedureCode==12 && nr-rrc.spCellConfigCommon_element
    ...                          alias=${alias}
    ${pcell_pci_after_change}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.physCellId    pcap_parser=${alias}
    Should Be Equal    ${pcell_pci_after_change}[0]    ${scell_pci}
    #---fileter the required pci of ho_scell in rrc reconfiguration after pcell change---#
    Convert CPIF Pcap To Pdml    file_path=${pcell_change_wireshark_log}
    ...                          filter=f1ap.procedureCode==12 && nr-rrc.sCellToAddModList
    ...                          alias=${alias}
    ${scell_pci_after_change}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.physCellId    pcap_parser=${alias}
    Should Be Equal    ${scell_pci_after_change}[0]    ${after_change_scell_pci}

Check Mutiple NonGBR Success
    [Documentation]   Auther:jun.8.chen@nokia-sbell.com
    [Arguments]    ${wireshark_log}
    ...            ${apn}=mdrb.nokia.com
    ...            ${drb_ToAddModList_value}=2
    ...            ${alias}=parser
    Convert CPIF Pcap To Pdml    file_path=${wireshark_log}
    ...                          filter=nr-rrc.rrcReconfiguration_element && nas_5gs.pdu_session_id && nas_5gs.cmn.dnn==${apn}
    ...                          alias=${alias}
    ${drb_ToAddModList}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.drb_ToAddModList    pcap_parser=${alias}
    Should Be Equal    ${drb_ToAddModList}[0]    ${drb_ToAddModList_value}

Modify PA Value By Steps For LA
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               Before use this keword must run the keyword "Spark_common_keywords.Spark Start UE Log"
    [Arguments]    ${origin_value}=6    ${times}=${0}    ${modify_ru_id}=0
    ...            ${ue_index}=${0}    ${step}=${1}    ${range}=70    ${sleep_duration}=2
    ${modify_times}    Set Variable    ${times}
    FOR    ${round}    IN RANGE    1    ${range}
        ${interval}    Evaluate    ${round}*${step}
        ${modify_value}    Evaluate    ${origin_value}+${interval}
        Modify PA Value Setting For Required RU    modify_ru_id=${modify_ru_id}    ue_index=${ue_index}    pa_off_value=${modify_value}
        Sleep    ${sleep_duration}sec
        ${modify_times}    Evaluate    ${modify_times}+${step}
        ${NR_RSRP}    Create List    NR SSB RSRP[dBm]
        ${rsrp}    Get Parameter Value    param=${NR_RSRP}
        ${status}    Run Keyword If    ${step}==${1}    Evaluate    ${rsrp}[0]<=-124
        ...          ELSE IF    ${step}==${-1}    Evaluate    ${modify_times}==${0}
        Exit For Loop If    "${status}"=="True"
    END
    [Return]    ${modify_value}    ${modify_times}

Modify MCS Value By Steps For LA
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               Before use this keword must run the keyword "Spark_common_keywords.Spark Start UE Log"
    [Arguments]    ${origin_value}=0    ${times}=${0}    ${ue_index}=${0}    ${step}=${1}    ${range}=70    ${sleep_duration}=2
    ${modify_times}    Set Variable    ${times}
    FOR    ${round}    IN RANGE    1    ${range}
        ${interval}    Evaluate    ${round}*${step}
        ${modify_value}    Evaluate    ${origin_value}+${interval}
        Set Case Related MCS Port Value    att_value=${modify_value}    ue_index=${ue_index}    whether_do_Angles=${False}
        Sleep    ${sleep_duration}sec
        ${modify_times}    Evaluate    ${modify_times}+${step}
        ${NR_RSRP}    Create List    NR SSB RSRP[dBm]
        ${rsrp}    Get Parameter Value    param=${NR_RSRP}
        ${status}    Run Keyword If    ${step}==${1}    Evaluate    ${rsrp}[0]<=-124
        ...          ELSE IF    ${step}==${-1}    Evaluate    ${modify_times}==${0}
        Exit For Loop If    "${status}"=="True"
    END
    [Return]    ${modify_value}    ${modify_times}

#--- Common keywords for CMAS ---#
Get The Numeber Of Beams From Cellgroup
    [Documentation]   Auther: tingting.1.liu@nokia-sbell.com
    ...               Description: Get the numeber of beams and return.
    [Arguments]    ${cell_id}=1    ${gnb_id}=${0}   ${connection}=GNB_OAM
    Set Test Variable    ${cell_group_id}   ${cell_id}
    ${beamset_para_value}    coam_parameter.get_single_value_from_scf_file
    ...    dist_name=MRBTS-${tl.gnbs[${gnb_id}].instance_id}/NRBTS-${tl.gnbs[${gnb_id}].global_bts_id}/NRCELLGRP-${cell_group_id}
    ...    parameter=numberOfTransmittedSsBlocks
    ...    connection=${connection}
    ...    timeout=300
    ${beamnumber_para_value}    Fetch From Left    string=${beamset_para_value}    marker=${SPACE}
    ${number_of_beam}    Convert To Integer    ${beamnumber_para_value}
    [Return]    ${number_of_beam}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get Current AMF info
    [Arguments]
    Set Test Variable   &{tang_amf}    connect_hostname=10.110.227.31
    Set Test Variable   &{feng_amf}    connect_hostname=10.110.194.163
    Set Test Variable   &{han_amf}    connect_hostname=10.107.180.36
    Set Test Variable   &{zhou_amf}    connect_hostname=10.110.90.92
    Set Test Variable   &{zheng_amf}    connect_hostname=10.110.133.97
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${amf_info}    get_amf_info
    ${amf_info}    Set Variable    ${amf_info['AMF primary IP address']}
    ${current_amf}    Set Variable If    '${amf_info}' == '10.110.90.68'    ${zhou_amf}
    ...                                  '${amf_info}' == '10.110.227.5'    ${tang_amf}
    ...                                  '${amf_info}' == '10.107.180.5'    ${han_amf}
    ...                                  '${amf_info}' == '10.110.133.68'    ${zheng_amf}
    ...                                  '${amf_info}' == '10.110.194.134'    ${feng_amf}
    Set Test Variable   ${current_amf}
    [Teardown]   COAM selenium logout

Trigger CMAS Notification and Capture Logs
    [Arguments]    ${amf}
    ...            ${tac}
    ...            ${nr_phy_cell_ids}
    ...            ${warning_area_list_id}
    ...            ${gnb_id}=${0}
    ...            ${connection}=cbctest
    ...            ${cbctest_ip}=10.9.202.153
    ...            ${cbctest_usr}=cbctest
    ...            ${cbctest_psw}=cbctest
    ...            ${wireshark_log_prefix}=cpif_CMAS
    ...            ${gnb_index}=${0}
    ...            ${asik_connection_alias}=ASIK Master
    ...            ${timer}=900
    ...            ${message_identifier}=${default_message_identifier}
    ...            ${serial_number}=${default_serial_number}
    ...            ${repetition_period}=${default_repetition_period}
    ...            ${number_of_broadcasts_requested}=${default_number_of_broadcasts_requested}
    ...            ${content_idx}=${1}
    ...            ${timer}=20
    ...            ${mcc}=${tl.core.mcc}
    ...            ${mnc}=${tl.core.mnc}
    Precondition for CMAS Notification    timer=${timer}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log     tcpdump_collector_name=${wireshark_log_prefix}
    ...    asik_connection_alias=${asik_connection_alias}
    ...    gnb_index=${gnb_index}
    Run Keyword And Continue On Failure
    ...    Collect Interface Mirroring Bip Collector    nr_phy_cell_ids=${nr_phy_cell_ids}
    Trigger CMAS Notification    amf=${amf}    tac=${tac}    warning_area_list_id=${warning_area_list_id}
    ...                          message_identifier=${message_identifier}    serial_number=${serial_number}
    ...                          repetition_period=${repetition_period}
    ...                          number_of_broadcasts_requested=${number_of_broadcasts_requested}
    ...                          connection=${connection}
    ...                          content_idx=${content_idx}
    ...                          timer=${timer}
    ...                          mcc=${mcc}
    ...                          mnc=${mnc}
    ${bip_log_list}    Run Keyword And Continue On Failure
    ...    Run Keyword And Continue On Failure    Get Bip Log Via Interface Mirroring Collector
    ${cpif_CMAS_log}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=${wireshark_log_prefix}
    [Return]    ${bip_log_list[0]}   ${cpif_CMAS_log}

Precondition for CMAS Notification
    [Arguments]    ${download_dir}=${TS_CASE_LOG_PATH}   ${timer}=${900}   ${connection}=GNB_OAM   ${gnb_id}=${0}
    Connect to gnb coam via ssl    connection=${connection}
    ${dist_name}    Set Variable    MRBTS-${tl.gnbs[${gnb_id}].instance_id}/NRBTS-${tl.gnbs[${gnb_id}].global_bts_id}
    ${dict_gnb_length}    coam_parameter.get_single_value_from_scf_file    dist_name=${dist_name}   parameter=gNbIdLength
    ...                                                                 connection=${connection}
    ...                                                                 timeout=300
    Set Test Variable    ${nr_of_bits_g_node_b_id}    ${dict_gnb_length}
    ${gnb_info}    coam.get_bts_info    connection=${connection}
    Set Test Variable    ${gnodeb_id}   ${gnb_info['mrbtsID']}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get BtsName From Gnb
    [Documentation]    author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${timeout}=${900}   ${gnb_id}=${0}    ${connection}=GNB_OAM${gnb_id}
    Connect to gnb coam via ssl    gnb_index=${gnb_id}    connection=${connection}
    ${dist_name}    Set Variable    MRBTS-${tl.gnbs[${gnb_id}].instance_id}/NRBTS-${tl.gnbs[${gnb_id}].global_bts_id}
    ${gnb_info}    coam.get_bts_info    connection=${connection}    timeout=${timeout}
    ${btsName}    Set Variable    ${gnb_info['name']}
    [Return]    ${btsName}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get BtsName and SwVersion
    [Documentation]    author: lei.jia@nokia-sbell.com
    [Arguments]    ${timeout}=${900}   ${gnb_id}=${0}    ${connection}=GNB_OAM${gnb_id}
    Connect to gnb coam via ssl    gnb_index=${gnb_id}    connection=${connection}
    ${dist_name}    Set Variable    MRBTS-${tl.gnbs[${gnb_id}].instance_id}/NRBTS-${tl.gnbs[${gnb_id}].global_bts_id}
    ${gnb_info}    coam.get_bts_info    connection=${connection}    timeout=${timeout}
    ${btsName}    Set Variable    ${gnb_info['name']}
    ${swVersion}    Set Variable    ${gnb_info['swInfo']['swVersion']}
    [Return]    ${btsName}    ${swVersion}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get scf stream and sw stream
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${scf_name}    ${sw_version}
    # get stream version from sw version
    ${version_splitted}    Split String    ${sw_version}    _
#    ${tmp_program_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
#    ${is_trunk}    Run Keyword And Return Status    Should Contain Any    ${sw_version}    _9999_    _9990_
#    ${stream_version}    Set Variable If    ${is_trunk}    master    ${tmp_program_version}

    # get scf version from sw name
    ${stream_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
    ${part_scf_name}    Fetch From Right    ${scf_name}    ${tl_prefix}_gNB_
    ${scf_version}    Fetch From Left    ${part_scf_name}    _
	[Return]    ${scf_version}    ${stream_version}

Start BIP Capture and Download File with Interface Mirroring Collector
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    [Arguments]    ${log_prefix}=l1l2bip_log
    ...            ${nr_phy_cell_ids}=None
    Collect Interface Mirroring Bip Collector    target_file_name=${log_prefix}    nr_phy_cell_ids=${nr_phy_cell_ids}
    Sleep    3 sec
    ${bip_log_list}    Get Bip Log Via Interface Mirroring Collector    target_file_name=${log_prefix}
    [Return]    ${bip_log_list[0]}

Trigger CMAS Notification
    [Arguments]    ${amf}
    ...            ${tac}
    ...            ${warning_area_list_id}
    ...            ${message_identifier}=${default_message_identifier}
    ...            ${serial_number}=${default_serial_number}
    ...            ${repetition_period}=${default_repetition_period}
    ...            ${number_of_broadcasts_requested}=${default_number_of_broadcasts_requested}
    ...            ${content_idx}=${0}
    ...            ${cbctest_ip}=10.9.202.153
    ...            ${cbctest_usr}=cbctest
    ...            ${cbctest_psw}=cbctest
    ...            ${connection}=cbctest
    ...            ${timer}=30
    ...            ${mcc}=${tl.core.mcc}
    ...            ${mnc}=${tl.core.mnc}
    ${cmd_local}   Run Keyword If  '${tl_prefix}'=='T283'   catenate    /tmp/cit/testcase /home/cbctest/test_amf_cit_ltt.py
    ...                         ${amf}[connect_hostname] ${tl.core.mcc} ${tl.core.mnc}
    ...                         ${tac} ${gnodeb_id} ${nr_of_bits_g_node_b_id}
    ...                         ${message_identifier} ${serial_number} ${repetition_period}
    ...                         ${number_of_broadcasts_requested} ${warning_area_list_id} ${content_idx}
         ...    ELSE    catenate    /tmp/cit/testcase /home/cbctest/test_amf_tmoe2e_gnb80.py
    ...                             ${amf}[connect_hostname] ${mcc} ${mnc}
    ...                             ${tac} ${gnodeb_id} ${nr_of_bits_g_node_b_id}
    ...                             ${message_identifier} ${serial_number} ${repetition_period}
    ...                             ${number_of_broadcasts_requested} ${warning_area_list_id} ${content_idx}
    csn.connect to    hostname=${cbctest_ip}
    ...               username=${cbctest_usr}
    ...               password=${cbctest_psw}
    ...               alias=${connection}
    Log To Console     ${\n}INFO: -- Start to send command on CMAS: ${cmd_local}
    csn.send_command    command=${cmd_local}    connection=${connection}
    Sleep    ${timer}s
    csn.read_output    connection=${connection}

Check Complete Procedure for CMAS Broadcasting
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${cpif_CMAS_log_path}
    ...            ${bip_log_path}
    ...            ${cellid}=${0}
    ...            ${alias}=parser
    ...            ${filter}=e1ap||f1ap||ngap||nr-rrc||xnap
    ...            ${serial_number}=${default_serial_number}
    ...            ${message_identifier}=${default_message_identifier}
    ...            ${repetition_period}=${default_repetition_period}
    ...            ${number_of_broadcasts_requested}=${default_number_of_broadcasts_requested}
    ...            ${last_segment_repeat_times}=${default_last_segment_repeat_times}
    ${string}    Convert To Hex    ${serial_number}    length=4
    ${string}    Convert To String    ${string}
    ${substring_0}    Get Substring    ${string}    0    2
    ${substring_1}    Get Substring    ${string}    2
    ${serial_number}    Set Variable    ${substring_0}:${substring_1}
    ${ngap_WRWReq_filter_expression}    catenate    ngap.WriteReplaceWarningRequest_element and ngap.procedureCode == 51
    ...                                             and ngap.SerialNumber == ${serial_number}
    ...                                             and ngap.MessageIdentifier == ${message_identifier}
    ...                                             and ngap.RepetitionPeriod == ${repetition_period}
    ...                                             and ngap.NumberOfBroadcastsRequested == ${number_of_broadcasts_requested}
    Convert CPIF Pcap To Pdml    file_path=${cpif_CMAS_log_path}    filter=f1ap||nr-rrc||ngap
    ...                          alias=${alias}
    ${output1}  pcap.Filter Packets By Expression    filter_expression=${ngap_WRWReq_filter_expression}  pcap_parser=${alias}
    ${values1}    pcap.get_field_value_by_xpath    xpath=.//ngap.initiatingMessage_element/ngap.procedureCode    pcap_parser=${alias}
    should not be empty    ${values1}
    ${wmc}    pcap.get_field_value_by_name    field_name=ngap.WarningMessageContents    pcap_parser=${alias}
    ${wac}    pcap.get_field_value_by_name    field_name=ngap.WarningAreaCoordinates   pcap_parser=${alias}
    ${output2}  pcap.Filter Packets By Expression    filter_expression=f1ap.WriteReplaceWarningRequest_element  pcap_parser=${alias}
    ${values2}    pcap.get_field_value_by_xpath    xpath=.//f1ap.initiatingMessage_element/f1ap.procedureCode   pcap_parser=${alias}
    should not be empty    ${values2}
    ${output3}  pcap.Filter Packets By Expression    filter_expression=f1ap.WriteReplaceWarningResponse_element and f1ap.id == 146
    ...                                              pcap_parser=${alias}
    ${values3}    pcap.get_field_value_by_xpath    xpath=.//f1ap.successfulOutcome_element/f1ap.procedureCode   pcap_parser=${alias}
    should not be empty    ${values3}
    Run Keyword And Ignore Error    pcap.Filter Packets By Expression
    ...          filter_expression=ngap.WriteReplaceWarningResponse_element and ngap.procedureCode == 51 and ngap.id == 13
    ...                                              pcap_parser=${alias}
    ${status}   ${value}   Run Keyword And Ignore Error   pcap.get_field_value_by_name
    ...                                             field_name=ngap.NRCellIdentity   pcap_parser=${alias}
    Run Keyword And Ignore Error   should not be empty    ${value}
    run keyword if  not '${status}' == 'PASS'   Run Keywords   pcap.Filter Packets By Expression
    ...          filter_expression=ngap.WriteReplaceWarningResponse_element and ngap.procedureCode == 51 and ngap.id == 13
    ...                                              pcap_parser=${alias}
    ...   AND   pcap.get_field_value_by_xpath
       ...              xpath=.//_[1]/ngap.CellIDBroadcastNR_Item_element/ngap.nR_CGI_element/ngap.NRCellIdentity
       ...              pcap_parser=${alias}
    ${bip_sib8_wmc_filter_expression}    catenate    nr-rrc.serialNumber == ${serial_number}
    ...                                              and nr-rrc.messageIdentifier == ${message_identifier}
    ...                                              and nr-rrc.sib_TypeAndInfo_item == 6
    ${bip_sib8_datacodingscheme_filter_expression}   catenate    nr-rrc.serialNumber == ${serial_number}
    ...                                              and nr-rrc.messageIdentifier == ${message_identifier}
    ...                                              and nr-rrc.warningMessageSegmentNumber==0
    ...                                              and nr-rrc.dataCodingScheme == 04
    ...                                              and nr-rrc.sib_TypeAndInfo_item == 6
#    ${sib8_periodicity}    Check SIB8 Scheduling in SIB1    bip_log=${bip_log_path}
    Convert CPIF Pcap To Pdml     file_path=${bip_log_path}
    ...                          filter=nr-rrc.sib_TypeAndInfo_item == 6
    ...                          alias=${alias}
    pcap.filter_packets_by_expression    filter_expression=${bip_sib8_wmc_filter_expression}   pcap_parser=${alias}
    ${warningMessageSegmentType}    pcap.get_field_value_by_name    field_name=nr-rrc.warningMessageSegmentType
    ...                                                             pcap_parser=${alias}
    ${last_segment_cnt}    Get Count    ${warningMessageSegmentType}    1
    ${real_number_of_lastsegment}    Evaluate    ${last_segment_repeat_times} * ${number_of_broadcasts_requested}
    ${status}  Set Variable If   ${last_segment_cnt}>=${real_number_of_lastsegment}   ${True}   ${False}
    Should Be True   '${status}' == 'True'
    ${values}    pcap.get_field_value_by_name    field_name=nr-rrc.warningMessageSegment    pcap_parser=${alias}
    should not be empty    ${values}
    Convert CPIF Pcap To Pdml     file_path=${bip_log_path}
    ...                          filter=nr-rrc.sib_TypeAndInfo_item == 6
    ...                          alias=${alias}
    pcap.filter_packets_by_expression    filter_expression=${bip_sib8_datacodingscheme_filter_expression}    pcap_parser=${alias}
    ${values}    pcap.get_field_value_by_name    field_name=nr-rrc.warningAreaCoordinatesSegment    pcap_parser=${alias}
    should not be empty    ${values}
    Compare WMC and WAC in SIB8    bip_log=${bip_log_path}
    ...                            filter_expression=${bip_sib8_wmc_filter_expression}
    ...                            wmc=${wmc[0]}
    ...                            wac=${wac[0]}
    [Return]    ${wmc[0]}    ${wac[0]}

Check SIB8 Scheduling in SIB1
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${bip_log}    ${cellid}=${0}
    ...            ${filter}=nr-rrc
    ...            ${alias}=parser
    ...            ${connection}=GNB_OAM
    Convert CPIF Pcap To Pdml       file_path=${bip_log}    filter=${filter}    alias=${alias}
    ${value}    Get Field Value From Pdml
    ...    xpath=.//_[1]/nr-rrc.SchedulingInfo_element/nr-rrc.sib_MappingInfo/_[1]/nr-rrc.SIB_TypeInfo_element/nr-rrc.type
    ...    filter_expression=nr-rrc.c1 == 1 and nr-rrc.type == 6
    should not be empty    ${value}
    ${sib_periodicity}   Get Field Value From Pdml   xpath=.//_[2]/nr-rrc.SchedulingInfo_element/nr-rrc.si_Periodicity
    ...    filter_expression=nr-rrc.c1 == 1 and nr-rrc.type == 6
    ${sib_periodicity}    Convert To Integer    ${sib_periodicity[0]}
    @{periodicity_para_list}    create list
    @{periodicity_value_list}    create list
    @{periodicity_value_list1}    create list
    @{periodicity_value_list2}    create list
    @{periodicity_value_list3}    create list
    @{periodicity_value_list4}    create list
    &{periodicitydict}    Create Dictionary    sibType=sibType2    sibPeriodicity=None
    &{periodicitydict1}    Create Dictionary    sibType=sibType3    sibPeriodicity=None
    &{periodicitydict2}    Create Dictionary    sibType=sibType4    sibPeriodicity=None
    &{periodicitydict3}    Create Dictionary    sibType=sibType5    sibPeriodicity=None
    &{periodicitydict4}    Create Dictionary    sibType=sibType8    sibPeriodicity=None
    Append To List   ${periodicity_value_list}   ${periodicitydict}  ${periodicitydict1}  ${periodicitydict2}
    ...                                          ${periodicitydict3}  ${periodicitydict4}
    &{sibPeriodicityList_dict}    Create Dictionary
    ...                  dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRSYSINFO_PROFILE-1
    ...                  parameter=sibSchedulingList
    ...                  value=${periodicity_value_list}
    Append To List   ${periodicity_para_list}   ${sibPeriodicityList_dict}
    Connect to gnb coam via ssl    connection=${connection}
    ${status}   ${sibPeriodicity_list}   Run keyword and ignore error   coam_parameter.get_list_values_from_scf_file
    ...                   parameters=${periodicity_para_list}
    ...                   connection=${connection}
    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    @{sib8_periodicity_list}    Create List    8    16    32    64
    Set Test Variable   ${sibPeriodicity_value}   ${sibPeriodicity_list[0]}[value]
    Set Test Variable   ${coam_periodicity}  ${sibPeriodicity_value[4]}[sibPeriodicity]
    Should be Equal    rf${sib8_periodicity_list}[${sib_periodicity}]    ${coam_periodicity}
    [Return]    ${sib8_periodicity_list}[${sib_periodicity}]

Compare WMC and WAC in SIB8
    [Arguments]    ${bip_log}    ${filter_expression}    ${wmc}    ${wac}   ${alias}=parser
    Convert CPIF Pcap To Pdml   file_path=${bip_log}   filter=nr-rrc.sib_TypeAndInfo_item == 6
    pcap.filter_packets_by_expression    filter_expression=${filter_expression}   pcap_parser=${alias}
    @{segment_num}    pcap.get_field_value_by_name    field_name=nr-rrc.warningMessageSegmentNumber   pcap_parser=${alias}
    Sort List    ${segment_num}
    ${segment_num}    Convert To Integer    ${segment_num}[-1]
    ${segment_num}    Evaluate    ${segment_num} + 1
    FOR  ${item}  IN RANGE  ${segment_num}
        Convert CPIF Pcap To Pdml    file_path=${bip_log}   filter=nr-rrc.sib_TypeAndInfo_item == 6
        pcap.filter_packets_by_expression    filter_expression=${filter_expression} and nr-rrc.warningMessageSegmentNumber==${item}
        ...                                  pcap_parser=${alias}
        ${value_wmc}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.warningMessageSegment   pcap_parser=${alias}
        ${value_wac}    pcap.get_field_value_by_name    field_name=nr-rrc.warningAreaCoordinatesSegment   pcap_parser=${alias}
        ${status}    ${value}    Run Keyword And Ignore Error    Should Not Be Empty    ${value_wac}
        ${sib8_wmc}    Set Variable If    ${item} == 0    ${value_wmc[0]}    ${sib8_wmc}:${value_wmc[0]}
        Run Keyword If    '${status}' == 'FAIL'    Continue For Loop
        ${sib8_wac}    Set Variable If    ${item} == 0    ${value_wac[0]}    ${sib8_wac}:${value_wac[0]}
    END
    Should be Equal    ${sib8_wmc}    ${wmc}
    Should be Equal    ${sib8_wac}    ${wac}

Check UE Log for SIB8
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${wmc}
    ...            ${wac}
    ...            ${ue_index}=${0}
    ...            ${serial_number}=${default_serial_number}
    ...            ${message_identifier}=${default_message_identifier}
    ${wmc}    Remove String    ${wmc}    :
    ${wac}    Remove String    ${wac}    :
    spark.read_log    logname=${TS_CASE_LOG_PATH}/uelog_sigspark_UE${ue_index}.xml
    ${spark_messageIdentifier}    spark.get_expected_val    msg=NR SystemInformationBlocks    expression=messageIdentifier
    ${spark_messageIdentifier}    Convert To Integer    ${spark_messageIdentifier}
    ${spark_messageIdentifier}    Convert To String    ${spark_messageIdentifier}
    ${message_identifier}    Convert To Binary    ${message_identifier}
    ${spark_serialnumber}    spark.get_expected_val    msg=NR SystemInformationBlocks    expression=serialNumber
    ${spark_serialnumber}    Convert To Integer    ${spark_serialnumber}
    ${spark_serialnumber}    Convert To String    ${spark_serialnumber}
    ${serial_number}    Convert To Binary    ${serial_number}
    ${spark_segment_num}    spark.get_expected_val    msg=NR SystemInformationBlocks    expression=warningMessageSegmentNumber    type=all
    Sort List    ${spark_segment_num}
    ${spark_segment_num}    Convert To Integer    ${spark_segment_num}[-1]
    ${spark_segment_num}    Evaluate    ${spark_segment_num} + 1
    ${spark_segment}    spark.get_expected_val    msg=NR SystemInformationBlocks    expression=warningMessageSegment    type=all
    ${spark_segment}    Remove Duplicates    ${spark_segment}
    ${spark_wmc}    Set Variable
    ${spark_area}    spark.get_expected_val    msg=NR SystemInformationBlocks    expression=warningAreaCoordinatesSegment    type=all
    ${spark_area}    Remove Duplicates    ${spark_area}
    ${spark_area_num}    Get Length    ${spark_area}
    ${spark_wac}    Set Variable
    FOR  ${item}  IN RANGE  ${spark_segment_num}
        ${segment}    Remove String    ${spark_segment[${item}]}    \n
        ${segment}    Remove String    ${segment}    ${SPACE}
        ${spark_wmc}    Set Variable    ${spark_wmc}${segment}
    END
    FOR  ${item}  IN RANGE  ${spark_area_num}
        ${area}    Remove String    ${spark_area[${item}]}    ${SPACE}
        ${spark_wac}    Set Variable    ${spark_wac}${area}
    END
    ${spark_wmc}    Convert To Lower Case    ${spark_wmc}
    ${spark_wac}    Convert To Lower Case    ${spark_wac}
    ${spark_wmc}  Evaluate  '${spark_wmc.replace('\n', '')}'
    ${spark_wac}  Evaluate  '${spark_wac.replace('\n', '')}'
    Should be Equal    ${spark_wmc}    ${wmc}
    Should be Equal    ${spark_wac}    ${wac}
    Should be Equal    ${spark_messageIdentifier}    ${message_identifier}
    Should be Equal    ${spark_serialnumber}    ${serial_number}


#--- keywords for case steps---#
TOL_case_RRM_SA_1UE_LinkAdaption_TCP
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ul_throughput}=150M
    ...            ${dl_throughput}=1500MKbits/sec
    ...            ${tput_collect_duration}=120
    ...            ${whether_need_ue_log}=${False}
    ...            ${whether_check_scell_addition}=${True}
    ...            ${whether_start_ul_call}=${True}
    ...            ${whether_start_dl_call}=${True}
    ...            ${start_keep_on_duration}=2400
    ...            ${whether_check_tupt}=${False}
    ...            ${log_name}=tcp_LA
    ...            ${check_ul_pcell_tput_type}=not_peak
    ...            ${check_pcell_tput_type}=not_peak
    ...            ${check_scell_tput_type}=not_peak
    ...            ${min_DL_percent}=0.85
    ...            ${min_UL_percent}=0.85
    ...            ${min_scell_percent}=0.85
    ...            ${check_ul_pcell_tput_type_after_la}=not_peak
    ...            ${check_pcell_tput_type_after_la}=not_peak
    ...            ${check_scell_tput_type_after_la}=not_peak
    Log To Console    ${\n}INFO:-- start to do attach and start L3 call --
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    Run Keyword And Continue On Failure    Procedures.Verify CA Basic L3 Call    ul_throughput=${ul_throughput}
    ...                                                                          dl_throughput=${dl_throughput}
    ...                                                                          protocol=tcp
    ...                                                                          tput_collect_duration=${tput_collect_duration}
    ...                                                                          whether_need_ue_log=${whether_need_ue_log}
    ...                                                                          whether_check_scell_addition=${whether_check_scell_addition}
    ...                                                                          whether_start_ul_call=${whether_start_ul_call}
    ...                                                                          whether_start_dl_call=${whether_start_dl_call}
    ...                                                                          start_keep_on_duration=${start_keep_on_duration}
    ...                                                                          whether_check_tupt=${whether_check_tupt}
    ...                                                                          enb_index=${fdd_enb_index}
    FOR    ${i}    IN RANGE    ${2}
        Log To Console    ${\n}INFO:-- start to do time_${i} LA action --
        TOL_case_SA_LinkAdaption_TCP_For_CA_And_Non_CA    log_name=${log_name}_${i}
        ...                                               check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
        ...                                               check_pcell_tput_type=${check_pcell_tput_type}
        ...                                               check_scell_tput_type=${check_scell_tput_type}
        ...                                               min_DL_percent=${min_DL_percent}
        ...                                               min_UL_percent=${min_UL_percent}
        ...                                               min_scell_percent=${min_scell_percent}
        ...                                               check_ul_pcell_tput_type_after_la=${check_ul_pcell_tput_type_after_la}
        ...                                               check_pcell_tput_type_after_la=${check_pcell_tput_type_after_la}
        ...                                               check_scell_tput_type_after_la=${check_scell_tput_type_after_la}
    END

TOL_case_SA_LinkAdaption_TCP_For_CA_And_Non_CA
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${log_name}=tcp_LA
    ...            ${check_ul_pcell_tput_type}=not_peak
    ...            ${check_pcell_tput_type}=not_peak
    ...            ${check_scell_tput_type}=not_peak
    ...            ${min_DL_percent}=0.85
    ...            ${min_UL_percent}=0.85
    ...            ${min_scell_percent}=0.85
    ...            ${check_ul_pcell_tput_type_after_la}=not_peak
    ...            ${check_pcell_tput_type_after_la}=not_peak
    ...            ${check_scell_tput_type_after_la}=not_peak
    Run Keyword And Continue On Failure    Procedures.Check TMO Throughput    ue_index=${0}
    ...                                                                       addition_scell_index_list=${SCELL_INDEX_LIST}
    ...                                                                       check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                                                                       check_pcell_tput_type=${check_pcell_tput_type}
    ...                                                                       check_scell_tput_type=${check_scell_tput_type}
    ...                                                                       tput_collect_duration=120
    ...                                                                       ignore_time=10sec
    ${host}   Start To Capture Aasyslog    gnb_index=${0}    du_index=${0}
    Sleep    5sec
    Run Keyword And Continue On Failure    Spark_common_keywords.Spark Start UE Log    ue_index=${0}
    ${ru_whether_connect_mcs}    Check RU Whether Connect Mcs    ru_index=${PCELL_MAPPING['ru_index_mapping']}
    FOR    ${attenuator}    IN    @{attenuator_list}
        ${modify_value}    ${modify_times}    Run Keyword If    '${attenuator}'=='pa'
        ...                    Modify PA Value By Steps For LA    origin_value=6    modify_ru_id=0    step=${1}
        ...    ELSE IF    '${attenuator}'=='mcs' and ${ru_whether_connect_mcs}
        ...                   Modify MCS Value By Steps For LA    origin_value=0    step=${1}
    END
    Sleep    3sec
    FOR    ${attenuator}    IN    @{attenuator_list}
        ${modify_value}    ${modify_times}    Run Keyword If    '${attenuator}'=='pa'
        ...        Modify PA Value By Steps For LA    origin_value=${modify_value}    times=${modify_times}    modify_ru_id=0    step=${-1}
        ...    ELSE IF    '${attenuator}'=='mcs' and ${ru_whether_connect_mcs}
        ...        Modify MCS Value By Steps For LA    origin_value=${modify_value}    times=${modify_times}    step=${-1}
    END
    Run Keyword And Ignore Error    Spark_common_keywords.Spark Stop UE Log    ue_index=${0}
    ...    log_name=${TS_CASE_LOG_PATH}/${log_name}.xml
    ${tupt_file_path}    Stop To Capture And Download Aasyslog    host=${host}
    Procedures.Check TMO Throughput    ue_index=${0}
    ...                                addition_scell_index_list=${SCELL_INDEX_LIST}
    ...                                whether_collect_tput=${False}
    ...                                tput_file_use_collected=${tupt_file_path}
    ...                                check_ul_pcell_tput_type=${check_ul_pcell_tput_type_after_la}
    ...                                check_pcell_tput_type=${check_pcell_tput_type_after_la}
    ...                                check_scell_tput_type=${check_scell_tput_type_after_la}
    ...                                min_DL_percent=${min_DL_percent}
    ...                                min_UL_percent=${min_UL_percent}
    ...                                min_scell_percent=${min_scell_percent}

General_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                The purpose of this test case is to collect Snapshot logs in WebUI
    ...                And check if RFSW logs from Radio Unit are included in Snapshot.
    [Arguments]    ${alais}=ASIK Master    ${connection}=GNB_OAM0    ${gnb_index}=${0}
    ...            ${snapshot_path}=${TS_CASE_LOG_PATH}    ${timeout}=900    ${is_get_snapshot_via_selenium}=${False}
    Wait Until Keyword Succeeds    2 min    20 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    Connect to Common Unit Master    alias=${alais}    gnb_index=${gnb_index}
    ${snapshot_log_path}    COAM Save snapshot via rest api    connection=${connection}    log_path=${snapshot_path}    timeout=1800
    ${rmod_index_list}  Get All RU Index    connection=${connection}
    ${rmod_bbmod_mapping}    gnbaction.get_rmod_bbmod_linkmode_mapping
    ${rmod_sn_mapping}    gnbaction.get_rmod_sn_mapping
    ${sn_ru_index_in_int_mapping}    gnbaction.get_sn_ru_index_in_int_mapping
    FOR    ${rmod_index}    IN    @{rmod_index_list}
        ${serial_number}    Set Variable    ${rmod_sn_mapping['${rmod_index}']}
        ${ru_index}    Set Variable    ${sn_ru_index_in_int_mapping['${serial_number}']}
        Connect to RU Via Allocated IP    rmod_bbmod_mapping=${rmod_bbmod_mapping}
        ...    rmod_index=${rmod_index}    ru_index=${ru_index}
        ...    ru_alias=RU_${ru_index}    asik_alias=${alais}    connection=${connection}
        ...    ru_username=${tl.gnbs[0].dus[0].rus[${ru_index}].default_ssh_connection_details.username}
        ...    ru_password=${tl.gnbs[0].dus[0].rus[${ru_index}].default_ssh_connection_details.password}
        Verify RU Log Include In Snapshot    snapshot_path=${snapshot_log_path}    ru_index=${rmod_index}    ru_alias=RU_${ru_index}
        ...                                  connection=${connection}    unzip_path=${snapshot_path}    timeout=${timeout}
        csn.disconnect  connection=RU_${ru_index}
    END
    [Teardown]  Run Keywords    Run Keyword And Ignore Error    csn.disconnect  connection=${alais}
    ...                  AND    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get RU IP Address Via File FRIps and remove incorrect ones
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    ...               Description: Get RU IP Address from log in ASIK : /rom/config/FRIps.txt
    [Arguments]   ${ru_serial_number}    ${connection}=ASIK Master
    ${get_ru_ip_command}   Set Variable   cat /rom/config/FRIps.txt
    ${output}   csn.execute   command=${get_ru_ip_command}  connection=${connection}
    @{ips}=  Split string    ${output}
    ${contained_ip_lines}    set variable
    FOR  ${item}  IN  @{ips}
      ${contains_ip}=     Run Keyword And Return Status       Should Not Contain 	${item} 	0.0.0.0
      ${contains_ru_no}    Run Keyword And Return Status
      ...    Run Keyword if   '${contains_ip}'=='${True}'    should contain    ${item}    ${ru_serial_number}
      ${contained_ip_lines}    Set Variable If    '${contains_ip}'=='${True}' and '${contains_ru_no}'=='${True}'    ${item}    ${output}
      Exit For Loop IF    '${contains_ip}'=='${True}' and '${contains_ru_no}'=='${True}'
    END
#    ${contained_ip_lines}   Get Lines Containing String   ${output}  ${ru_serial_number}   case-insensitive=${True}
    ${ru_ip_addr}  Set Variable    ${contained_ip_lines.split(';')}[2]
    [Return]   ${ru_ip_addr}

Connect to RU Via Allocated IP
    [Documentation]   Auther: jun.8.chen@nokia-sbell.com
    ...               Description: Get RU IP address In ASIK : Get RU IP Address from log in ASIK : /rom/config/FRIps.txt
    ...               2023.11.10 update Jia Lei for 0.0.0.0 in /rom/config/FRIps.txt
    [Arguments]    ${rmod_bbmod_mapping}    ${rmod_index}    ${ru_index}=${1}   ${ru_alias}=RU   ${connection}=GNB_OAM0
    ...            ${container_id}=0x1018    ${container_alias}=Container    ${fhnet_host_ip}=192.168.255.254
    ...            ${asik_alias_right}=ASIK Master Right   ${asik_alias}=ASIK Master
    ...            ${ru_username}=${tl.gnbs[0].dus[0].rus[${ru_index}].default_ssh_connection_details.username}
    ...            ${ru_password}=${tl.gnbs[0].dus[0].rus[${ru_index}].default_ssh_connection_details.password}
    ${ru_bbmod_mapping_lenget}    Get Length     ${rmod_bbmod_mapping['${rmod_index}']}
    ${target_rmod_index}      Set Variable If    ${ru_bbmod_mapping_lenget}==${1}     ${rmod_bbmod_mapping['${rmod_index}'][0]}
    ...                                          ${ru_bbmod_mapping_lenget}==${2}     ${rmod_bbmod_mapping['${rmod_index}'][-1]}
    ${status}    Evaluate    int(${target_rmod_index}) >= 4
#    ${status}    Evaluate    ${rmod_bbmod_mapping['${rmod_index}']} >= 4
    Run Keyword If    ${status}    ssh.Connect to    hostname=fct-4a
    ...                                              username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                                              password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                                              proxy=${asik_alias}
    ...                                              alias=${asik_alias_right}
    ${alias}    Set Variable If    ${status}    ${asik_alias_right}    ${asik_alias}
	${container_id}    Get FHNET Container ID    asik_alias=${alias}
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${rmod_index}   connection=${connection}
    ${ru_ip_addr}  Get RU IP Address Via File FRIps and remove incorrect ones    ru_serial_number=${ru_info['serialNumber']}
    ...                                                                          connection=${alias}
    ${output}    csn.execute    lxc-ls    connection=${alias}
    ${feature_1834_opened}    Run Keyword And Return Status    Should Contain    ${output}    ${container_id}
    Run Keyword If    ${feature_1834_opened}
    ...    Connect To RU Via FHNET Container    ru_ip_addr=${ru_ip_addr}
    ...                                         container_id=${container_id}
    ...                                         container_alias=${container_alias}
    ...                                         ru_alias=${ru_alias}
    ...                                         asik_alias=${alias}
    ...                                         fhnet_host_ip=${fhnet_host_ip}
    ...                                         ru_username=${ru_username}
    ...                                         ru_password=${ru_password}
    ...                                         ru_index=${rmod_index}
    ...                                         coam_connection=${connection}
    ...    ELSE    csn.connect to    hostname=${ru_ip_addr}
    ...                              username=${ru_username}
    ...                              password=${ru_password}
    ...                              alias=${ru_alias}
    ...                              proxy=${alias}

Verify RU Log Include In Snapshot
    [Documentation]   Auther: jun.8.chen@nokia-sbell.com
    ...    is_get_snapshot_via_selenium: if set to ${True} use selenium for collect, if ${False} use rest api
    [Arguments]   ${snapshot_path}    ${ru_index}=${1}    ${ru_alias}=RU    ${connection}=GNB_OAM    ${timeout}=900
    ...           ${unzip_path}=${TS_CASE_LOG_PATH}
    ${log_on_ru}    Get RFSW Log File List On RU   connection=${ru_alias}    download_dir=${unzip_path}    timeout=${timeout}
    ${log_on_snapshot}    Get RU Log File List On Snapshot    snapshot_path=${snapshot_path}    ru_index=${ru_index}
    ...                                                       unzip_path=${unzip_path}    connection=${connection}
    ...                                                       timeout=${timeout}
    ${not_include_list}    Create List
    FOR  ${item}  IN  @{log_on_ru}
       ${status}  Run Keyword And Return Status  Should Contain Match   ${log_on_snapshot}   regexp=.*${item}.*
       Run Keyword If  ${status}==${False}     Append to List    ${not_include_list}     ${item}
    END
    ${white_list}    Set Variable    ${RU_LOGS_NOT_IN_SNAPSHOT_WHITE_LIST}
    ${flilter_lists}    Create List
    FOR  ${item}  IN   @{white_list}
        ${flilter_list}    Evaluate   [y for y in ${not_include_list} if '${item}' in y]
        ${flilter_lists}    combine lists    ${flilter_lists}    ${flilter_list}
    END
    ${not_include_list}    Evaluate    list(set(${not_include_list})-set(${flilter_lists}))
    ${length}    Get Length    ${not_include_list}
    Run   rm -rf ${snapshot_unzip_file_path}
    Should Be Equal As Integers   ${length}   ${0}   msg=Item ${not_include_list} not include in snapshot logs

Get RU Log File List On Snapshot
    [Documentation]   Auther: jun.8.chen@nokia-sbell.com
    [Arguments]   ${snapshot_path}    ${ru_index}=${1}    ${unzip_path}=${TS_CASE_LOG_PATH}    ${connection}=GNB_OAM    ${timeout}=600
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${serial_number}  Set Variable    ${ru_info['serialNumber']}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_unzip_file_path}    Join Path    ${unzip_path}    snapshot_${timestamp}
    Set Test Variable    ${snapshot_unzip_file_path}
    Run   rm -rf ${snapshot_unzip_file_path}
    extract zip file    ${snapshot_path}    ${snapshot_unzip_file_path}
    ${output}   OperatingSystem.get file    ${snapshot_unzip_file_path}/snapshot_file_list.txt
    ${rfsw_log_names}   Get Regexp Matches   ${output}   BTS\\_${serial_number}\\_.*
    [Return]    ${rfsw_log_names}

Update Special Apn
    [Documentation]   Auther: jun.8.chen@nokia-sbell.com
    [Arguments]    ${apn_address}=${tl.core.pdns[0].apn}    ${except_apn}=mdrb.nokia.com    ${ue_index}=${0}    ${ue_type}=${ue_type}
    ...            ${plmn}=${tl.core.mcc}${tl.core.mnc}    ${mcc}=${tl.core.mcc}     ${mnc}=${tl.core.mnc}
    ...            ${except_name}=drb    ${apn_type}=default
    Run Keyword If    '${ue_type}'=='huawei_sigspark'
    ...                       Modify APN    apn_address=${apn_address}    except_apn=${except_apn}    ue_index=${ue_index}
    ...    ELSE IF    '${ue_type}'=='qct_dx50'
    ...                       Change_netword_mode.Switch Apn   apn_address=${except_apn}    ue_index=${ue_index}
    ...    ELSE IF    '${ue_type}'=='mtk'
    ...                       Change MTK APN    apn_address=${apn_address}    plmn=${plmn}    mcc=${mcc}    mnc=${mnc}    apn_type=${apn_type}
    ...                       except_name=${except_name}    except_apn=${except_apn}    ue_index=${ue_index}

Change MTK APN
    [Documentation]   Auther:xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    ...            ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...            ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...            ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...            ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...            ${apn_address}=${tl.core.pdns[0].apn}
    ...            ${plmn}=${tl.core.mcc}${tl.core.mnc}    ${mcc}=${tl.core.mcc}     ${mnc}=${tl.core.mnc}
    ...            ${except_name}=drb    ${except_apn}=mdrb.nokia.com
    ...            ${apn_type}=default,mms,supl,hipri,fota,cbs,xcap
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    ${delete_apn}    Catenate    adb -s ${serial_number} shell content delete --uri
    ...                          content://telephony/carriers --where "numeric=${plmn}"
    csn.send_command    command=${delete_apn}    connection=cpc_${ue_index}
    Sleep    3sec
    ${add_apn}    Catenate	adb -s ${serial_number} shell content insert --uri content://telephony/carriers --bind name:s:"${except_name}"
    ...						--bind numeric:s:"${plmn}" --bind type:s:"${apn_type}" --bind mcc:i:${mcc}
    ...						--bind mnc:s:"${mnc}" --bind apn:s:"${except_apn}"  --bind user:s:"" --bind password:s:""
    csn.send_command    command=${add_apn}     connection=cpc_${ue_index}
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

Get NRRELE And NRADJECELL Config For Inter-RAT_NR-LTE_ANR HO
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${source_cell_idx}    ${target_cell_idx}    ${target_cell_pci}    ${connection}=GNB_OAM0
    ...            ${gnb_index}=0    ${timeout}=${60}    ${should_activate}=${True}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${nrrele_mos}    gnbaction.get_nrrele_config
    @{delete_param_list}    Create List
    FOR    ${mo}    IN    @{nrrele_mos}
        ${nrcell_id}    Set Variable    ${mo['distName'].split('/')[-2].split('-')[-1]}
        ${nrrele_id}    Set Variable    ${mo['distName'].split('/')[-1].split('-')[-1]}
        ${lcrId}    Set Variable    ${mo['parameters']['lcrId']}
        ${dist_name}    Set Variable    NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${source_cell_idx}/NRRELE-${nrrele_id}
        ${cellid_status}    Evaluate    "${nrcell_id}"=="${source_cell_idx}"
        ${lcrId_status}    Evaluate    "${lcrId}"=="${target_cell_idx}"
        ${param}    Evaluate    {'dist_name': '${dist_name}'}
        Run Keyword If    ${cellid_status} and ${lcrId_status}    Append To List    ${delete_param_list}    ${param}
        Exit For Loop If    ${cellid_status} and ${lcrId_status}
    END
    ${nradjecell_mos}    gnbaction.get_nradjecell_config
    FOR    ${mo}    IN    @{nradjecell_mos}
        ${nradjecell_id}    Set Variable    ${mo['distName'].split('-')[-1]}
        ${lcrId}    Set Variable    ${mo['parameters']['lcrId']}
        ${pci}    Set Variable    ${mo['parameters']['physCellId']}
        ${dist_name}    Set Variable    NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRADJECELL-${nradjecell_id}
        ${pci_status}    Evaluate    "${pci}"=="${target_cell_pci}"
        ${lcrId_status}    Evaluate    "${lcrId}"=="${target_cell_idx}"
        ${param}    Evaluate    {'dist_name': '${dist_name}'}
        Run Keyword If    ${pci_status} and ${lcrId_status}    Append To List    ${delete_param_list}    ${param}
        Exit For Loop If    ${pci_status} and ${lcrId_status}
    END
    COAM Delete Several Object Via Rest Api    parameters_to_update_via_api=${delete_param_list}
    ...                                        timeout=${timeout}
    ...                                        connection=${connection}
    ...                                        should_activate=${should_activate}
    [Return]    ${delete_param_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check The Lcrid For Special NRRELE And NRADJECELL
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${source_cell_idx}    ${target_cell_idx}    ${target_cell_pci}    ${nrrele_index}=256
    ...            ${nradjecell_index}=5000    ${timeout}=300    ${connection}=GNB_OAM    ${gnb_index}=0
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${lcrId_value}    coam_parameter.get_single_value_from_scf_file
    ...                      parameter=lcrId
    ...                      dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${source_cell_idx}/NRRELE-${nrrele_index}
    ...                      connection=${connection}
    ...                      timeout=300
    ${target_cell_idx}    Evaluate    str(${target_cell_idx})
    Should Be Equal    ${lcrId_value}    ${target_cell_idx}
    ${lcrId_value1}    coam_parameter.get_single_value_from_scf_file
    ...                      parameter=lcrId
    ...                      dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRADJECELL-${nradjecell_index}
    ...                      connection=${connection}
    ...                      timeout=300
    ${pci_value1}    coam_parameter.get_single_value_from_scf_file
    ...                      parameter=physCellId
    ...                      dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRADJECELL-${nradjecell_index}
    ...                      connection=${connection}
    ...                      timeout=300
    ${target_cell_pci}    Evaluate    str(${target_cell_pci})
    Should Be Equal    ${lcrId_value1}    ${target_cell_idx}
    Should Be Equal    ${pci_value1}    ${target_cell_pci}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get NRREL Config For Intra Frequency
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${source_cell_idx}    ${target_cell_idx}    ${connection}=GNB_OAM0
    ...            ${gnb_index}=0    ${timeout}=${600}    ${should_activate}=${True}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${nrrel_mos}    gnbaction.get_nrrel_config
    @{delete_param_list}    Create List
    FOR    ${mo}    IN    @{nrrel_mos}
        ${nrcell_id}    Set Variable    ${mo['distName'].split('/')[-2].split('-')[-1]}
        ${nrrel_id}    Set Variable    ${mo['distName'].split('/')[-1].split('-')[-1]}
        ${lcrId}    Set Variable    ${mo['parameters']['lcrId']}
        ${dist_name}    Set Variable    NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${source_cell_idx}/NRREL-${nrrel_id}
        ${cellid_status}    Evaluate    "${nrcell_id}"=="${source_cell_idx}"
        ${lcrId_status}    Evaluate    "${lcrId}"=="${target_cell_idx}"
        ${param}    Evaluate    {'dist_name': '${dist_name}'}
        Run Keyword If    ${cellid_status} and ${lcrId_status}    Run Keywords
        ...    Append To List    ${delete_param_list}    ${param}    AND
        ...    COAM Delete Several Object Via Rest Api    parameters_to_update_via_api=${delete_param_list}
        ...                                               timeout=${timeout}
        ...                                               connection=${connection}
        ...                                               should_activate=${should_activate}
        Exit For Loop If    ${cellid_status} and ${lcrId_status}
    END
    [Return]    ${delete_param_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check The Lcrid For Special NRREL
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${source_cell_idx}    ${target_cell_idx}    ${nrrel_index}=256
    ...            ${timeout}=300    ${connection}=GNB_OAM    ${gnb_index}=0
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${lcrId_value}    coam_parameter.get_single_value_from_scf_file
    ...                      parameter=lcrId
    ...                      dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${source_cell_idx}/NRREL-${nrrel_index}
    ...                      connection=${connection}
    ...                      timeout=300
    ${target_cell_idx}    Evaluate    str(${target_cell_idx})
    Should Be Equal    ${lcrId_value}    ${target_cell_idx}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Update Nrarfcn And Gscn Of All AEHC
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                Source config: nrarfcn--527202//gscn: 6588, target config: nrarfcn--530700//gscn: 6633
    [Arguments]    ${nrarfcn}=530700    ${gscn}=6633    ${connection}=GNB_OAM    ${gnb_index}=0    ${timeout}=600
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${cell_info}   coam.get_cells_info    cell_type=nr    timeout=${timeout}    connection=${connection}
    @{param_list}    Create List
    FOR    ${cell}    IN    @{cell_info}
        ${dist_name}    Set Variable    ${cell['id']['configuration']}
        ${cell_nrarfcn}    Set Variable    ${cell.get('nrarfcn')}
        ${gscnOrSsPbchArfcn}     coam_parameter.get_single_value_from_scf_file    parameter=gscnOrSsPbchArfcn
        ...                                                                       dist_name=${dist_name}
        ...                                                                       connection=${connection}
        ...                                                                       timeout=300
        ${nrarfcn_param}    Evaluate    {'dist_name': '${dist_name}', 'parameter': 'nrarfcn','value': '${nrarfcn}'}
        ${gscn_param}    Evaluate    {'dist_name': '${dist_name}', 'parameter': 'gscnOrSsPbchArfcn','value': '${gscn}'}
        Run Keyword If    '${cell_nrarfcn}'!='None' and '${cell_nrarfcn}'=='527202'
        ...    Run Keywords    Append To List    ${param_list}    ${nrarfcn_param}    AND
        ...                    Append To List    ${param_list}    ${gscn_param}
    END
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    timeout=${timeout}
    Wait Gnb Ready And Cell On Air    gnb_id=${gnb_index}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Update DrxLongCycle Of All 5G Cell
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${drxLongCycle}=160ms    ${connection}=GNB_OAM    ${gnb_index}=0    ${timeout}=300
    ${nr_cell_list}    Get Cell Index List    cell_type=nr    gnb_id=${gnb_index}    gnb_connection=${connection}
    @{param_list}    Create List
    &{drxLongCycle_value}    Create Dictionary    drxLongCycle=${drxLongCycle}
    FOR    ${nr_cell}    IN    @{nr_cell_list}
        ${dist_name}    Set Variable    NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${nr_cell}
        ${param}    Evaluate    {'dist_name': '${dist_name}', 'parameter': 'drxProfileAnrNrIntraFreq','value':[&{drxLongCycle_value}]}
        Append To List    ${param_list}    ${param}
    END
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    timeout=${timeout}
    Wait Gnb Ready And Cell On Air    gnb_id=${gnb_index}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Verify Non-CA Basic L3 Call One By One
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${cell_list}    ${ue_type}    ${ue_mode}=SA    ${ue_index}=${0}    ${enb_index}=${1}
    ...            ${dl_throughput}=2500MKbits/sec    ${ul_throughput}=100M
    ...            ${start_keep_on_duration}=300    ${ignore_time}=10sec    ${tput_collect_duration}=60
    ...            ${expect_addition_scell_indexs}=${None}    ${scell_mapping}=${None}
    ...            ${whether_do_barred_action}=${False}    ${exp_status}=notBarred    ${whether_do_Angles}=${True}
    ...            ${whether_do_lte_barred_action}=${False}    ${whether_do_close_all_ports}=${True}
    ...            ${whether_do_stop_call}=${True}    ${whether_do_case_prepare}=${True}    ${whether_do_mcs_setup}=${False}
    Log To Console    ${\n}INFO:-- start to do Non-CA Basic L3 Call One By One --
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    FOR    ${cell}    IN    @{cell_list}
        Run Keyword If    ${whether_do_case_prepare}    Non-CA Case Prepare For Multi-UE    cell_index=${cell}    cell_type=nr
        ...                                                 ue_index=${ue_index}    whether_do_close_all_ports=${whether_do_close_all_ports}
        ...                                                 whether_do_mcs_setup=${whether_do_mcs_setup}
        ...                                                 whether_do_Angles=${whether_do_Angles}
        Change cellBarred Parameter Value On Gnb    pcell_index=${cell}    gnb_id=${0}
        Procedures.Verify CA Basic L3 Call    ue_index=${ue_index}
        ...                                   ue_type=${ue_type}
        ...                                   ue_mode=${ue_mode}
        ...                                   ul_throughput=${ul_throughput}
        ...                                   dl_throughput=${dl_throughput}
        ...                                   whether_need_ue_log=${False}
        ...                                   whether_check_scell_addition=${False}
        ...                                   whether_do_barred_action=${whether_do_barred_action}
        ...                                   expect_addition_scell_indexs=${expect_addition_scell_indexs}
        ...                                   pcell_mapping=${PCELL_MAPPING}
        ...                                   scell_mapping=${scell_mapping}
        ...                                   whether_check_on_air=${False}
        ...                                   check_scell_tput=${False}
        ...                                   target_DL_avg_percent=0.1
        ...                                   target_UL_avg_percent=0.1
        ...                                   min_DL_percent=0.0
        ...                                   min_UL_percent=0.0
        ...                                   notbarred_cell_index=${PCELL_INDEX}
        ...                                   exp_status=${exp_status}
        ...                                   start_keep_on_duration=${start_keep_on_duration}
        ...                                   ignore_time=${ignore_time}
        ...                                   tput_collect_duration=${tput_collect_duration}
        ...                                   whether_do_lte_barred_action=${whether_do_lte_barred_action}
        ...                                   enb_index=${enb_index}
        Run Keyword If    ${whether_do_stop_call}    Procedures.Stop TMO L3 Call And Detach    ue_index=${ue_index}    ue_type=${ue_type}
    END

Verify 4G Non-CA Basic L3 Call One By One
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${cell_list}    ${ue_type}    ${ue_index}=${0}    ${enb_index}=${0}
    ...            ${dl_throughput}=300MKbits/sec    ${ul_throughput}=100M
    ...            ${start_keep_on_duration}=300    ${ignore_time}=10sec
    ...            ${tput_collect_duration}=60    ${expect_dl_tput}=5
    ...            ${whether_do_stop_call}=${True}     ${expect_ul_tput}=1
    ...            ${whether_do_close_all_ports}=${True}
    ...            ${whether_do_barred_action}=${False}
    ...            ${whether_do_ue_prepare}=${False}    ${process_num}=${2}
    Log To Console    ${\n}INFO:-- start to do 4G Non-CA Basic L3 Call One By One --
    FOR    ${cell}    IN    @{cell_list}
        Verify 4G Non-CA Basic L3 Call    cell_index=${cell}
        ...                               ue_type=${ue_type}
        ...                               ue_index=${ue_index}
        ...                               enb_index=${enb_index}
        ...                               dl_throughput=${dl_throughput}
        ...                               ul_throughput=${ul_throughput}
        ...                               start_keep_on_duration=${start_keep_on_duration}
        ...                               ignore_time=${ignore_time}
        ...                               tput_collect_duration=${tput_collect_duration}
        ...                               expect_dl_tput=${expect_dl_tput}
        ...                               expect_ul_tput=${expect_ul_tput}
        ...                               whether_do_stop_call=${whether_do_stop_call}
        ...                               whether_do_close_all_ports=${whether_do_close_all_ports}
        ...                               whether_do_barred_action=${whether_do_barred_action}
        ...                               whether_do_ue_prepare=${whether_do_ue_prepare}
    END

Verify 4G Non-CA Basic L3 Call
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${cell_index}    ${ue_type}    ${ue_index}=${0}    ${enb_index}=${0}
    ...            ${dl_throughput}=300MKbits/sec    ${ul_throughput}=100M
    ...            ${start_keep_on_duration}=300    ${ignore_time}=10sec
    ...            ${tput_collect_duration}=60    ${expect_dl_tput}=5
    ...            ${whether_do_stop_call}=${True}     ${expect_ul_tput}=1
    ...            ${whether_do_close_all_ports}=${True}
    ...            ${whether_do_case_prepare}=${True}
    ...            ${whether_do_barred_action}=${False}
    ...            ${whether_do_ue_prepare}=${False}
    Log To Console    ${\n}INFO:-- start to do 4G Non-CA Basic L3 Call--
    Run Keyword If    ${whether_do_case_prepare}    Non-CA Case Prepare For Multi-UE    cell_index=${cell_index}    cell_type=lte
    ...                   ue_index=${ue_index}    enb_index=${enb_index}    whether_do_close_all_ports=${whether_do_close_all_ports}
    Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=${cell_index}    enb_index=${enb_index}
    Procedures.Verify 4G L3 Call    whether_do_lte_barred_action=${False}
    ...                             whether_do_barred_action=${whether_do_barred_action}
    ...                             whether_check_on_air=${False}
    ...                             notbarred_cell_index=${cell_index}
    ...                             ue_index=${ue_index}
    ...                             ue_type=${ue_type}
    ...                             dl_throughput=${dl_throughput}
    ...                             start_keep_on_duration=${start_keep_on_duration}
    ...                             ignore_time=${ignore_time}
    ...                             tput_collect_duration=${tput_collect_duration}
    ...                             enb_index=${enb_index}
    ...                             expect_dl_tput=${expect_dl_tput}
    ...                             expect_ul_tput=${expect_ul_tput}
    ...                             whether_do_ue_prepare=${whether_do_ue_prepare}
    Run Keyword If    ${whether_do_stop_call}    Procedures.Stop TMO L3 Call And Detach    ue_index=${ue_index}    ue_type=${ue_type}

Non-CA Case Prepare For Multi-UE
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :Param: ${cell_type}, "nr" or "lte"
    [Arguments]    ${cell_index}    ${cell_type}=nr    ${ue_index}=${0}
    ...            ${gnb_index}=${0}    ${enb_index}=${0}
    ...            ${connection}=GNB_OAM0    ${timeout}=120    ${whether_do_Angles}=${True}
    ...            ${whether_do_close_all_ports}=${True}    ${whether_do_mcs_setup}=${False}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'!='nr'
    ...            Wait Until Keyword Succeeds   1 min   5 sec   Connect to eNB via ssl   enb_index=${enb_index}   connection=${connection}
    ...    ELSE    Wait Until Keyword Succeeds   1 min   5 sec   Connect to gnb coam via ssl   connection=${connection}   gnb_index=${gnb_index}
    Run Keyword If    ${whether_do_close_all_ports}    Trun Off All PA Ports
    ${attenuator_list}    Set Variable If    '${ue_index}'!='${0}'
    ...    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']['UEs_info'][${ue_index}]['attenuator']}
    ...    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']['attenuator']}
    ${pcell_ru_index}   Run Keyword If    '${cell_type}'=='nr'    Get 5G Related Info Of Cell   cell_index=${cell_index}
    ...                                                                                         gnb_index=${gnb_index}
    ...    ELSE    Get 4G Related Info Of Cell   cell_index=${cell_index}    connection=${connection}    timeout=${timeout}
    FOR    ${attenuator}    IN    @{attenuator_list}
        Run Keyword If    '${attenuator}'=='pa'
        ...        Modify PA Value Setting For Required RU    modify_ru_id=${pcell_ru_index}    ue_index=${ue_index}
        ...    ELSE IF    '${attenuator}'=='mcs'    Set Case Related MCS Port Value
        ...                                         ue_index=${ue_index}   whether_do_mcs_setup=${whether_do_mcs_setup}
        ...                                         whether_do_Angles=${whether_do_Angles}
        ...    ELSE    Log To Console     ${\n}INFO: --Use the wrong attenuator type(${attenuator}), need to check TMO_Data.py--
    END
    [Teardown]    Teardown GNB and ENB Connections

Get 5G Related Info Of Cell
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                Just for non-ca
    [Arguments]    ${cell_index}    ${gnb_index}=${0}
    mbca.set_pcell_index    value=${cell_index}
    mbca.set_gnb_id    value=${gnb_index}
    mbca.set_gnb_operation_object
    ${pcell_mapping}    mbca.get_pcell_mapping_for_tmo
    Set Test Variable    ${PCELL_MAPPING}     ${pcell_mapping}
    Set Test Variable    ${PCELL_INDEX}    ${cell_index}
    ${pcell_ru_index}    Set Variable    ${PCELL_MAPPING['ru_index_mapping']}
    [Return]    ${pcell_ru_index}

Get 4G Related Info Of Cell
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                Just for non-ca
    [Arguments]    ${cell_index}    ${connection}=GNB_OAM0    ${timeout}=120
    ${cell_info}   coam.get_cells_info    cell_type=lte    timeout=${timeout}    connection=${connection}
    FOR    ${item}    IN    @{cell_info}
        ${rmod_info}    Get From List    ${item['carrierList']}    0
        ${rmod_id}    Get Regexp Matches    ${rmod_info['antennaLineId']['configuration']}    RMOD-(\\d+)    1
        ${cell_id}    Set Variable    ${item['id']['configuration'].split('-')[-1]}
		${status}    Evaluate    "${cell_id}"=="${cell_index}"
        ${rmod_index}    Run Keyword If    ${status}    Set Variable    ${rmod_id}
		Exit For Loop If    "${status}"=="True"
    END
    ${rmod_sn_mapping}    gnbaction.get_rmod_sn_mapping
    ${sn_ru_index_in_int_mapping}    gnbaction.get_sn_ru_index_in_int_mapping
	${serial_number}    Set Variable    ${rmod_sn_mapping['${rmod_index}[0]']}
    ${pcell_ru_index}    Set Variable    ${sn_ru_index_in_int_mapping['${serial_number}']}
    ${pcell_ru_index}    Evaluate    str(${pcell_ru_index})
    [Return]    ${pcell_ru_index}

Get RU Index Of LTE Cell
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${cell_index}    ${timeout}=120    ${gnb_id}=0   ${gnb_index}=${0}    ${enb_index}=${1}    ${connection}=GNB_OAM0
    ${4g_whether_in_gnb}    Check LTE Whether In Gnb    gnb_id=${gnb_id}    gnb_connection=${connection}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False}
    ...            Wait Until Keyword Succeeds   1 min   5 sec   Connect to eNB via ssl   enb_index=${enb_index}   connection=${connection}
    ...    ELSE    Wait Until Keyword Succeeds   1 min   5 sec   Connect to gnb coam via ssl   gnb_index=${gnb_index}   connection=${connection}
    ${cell_info}   coam.get_cells_info    cell_type=lte    timeout=${timeout}    connection=${connection}
    FOR    ${item}    IN    @{cell_info}
        ${rmod_info}    Get From List    ${item['carrierList']}    0
        ${rmod_id}    Get Regexp Matches    ${rmod_info['antennaLineId']['configuration']}    RMOD-(\\d+)    1
        ${cell_id}    Set Variable    ${item['id']['configuration'].split('-')[-1]}
		${status}    Evaluate    "${cell_id}"=="${cell_index}"
        ${rmod_index}    Run Keyword If    ${status}    Set Variable    ${rmod_id}
		Exit For Loop If    "${status}"=="True"
    END
    ${rmod_sn_mapping}    gnbaction.get_rmod_sn_mapping
    ${sn_ru_index_in_int_mapping}    gnbaction.get_sn_ru_index_in_int_mapping
	${serial_number}    Set Variable    ${rmod_sn_mapping['${rmod_index}[0]']}
    ${ru_index}    Set Variable    ${sn_ru_index_in_int_mapping['${serial_number}']}
    ${ru_index}    Evaluate    str(${ru_index})
    Set Test Variable    ${NSA_PA_RU_INDEX}    ${ru_index}
    [Teardown]    Teardown GNB and ENB Connections

Perform Special RU Power Action
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                Param: ${action}--'power_off' or 'power_on'
    [Arguments]    ${action}=power_off    ${special_ru}=AEHC    ${gnb_index}=${0}    ${du_index}=${0}
    ${ru_list}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus}
    FOR    ${ru}    IN    @{ru_list}
        ${ru_index}    Get Index From List    ${ru_list}    ${ru}
        ${model}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].pdu_port.pdu.__class__.__name__}
        ${ru_pdu_ip}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].pdu_port.pdu.addr}
        ${ru_pdu_port}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].pdu_port.port_no}
        ${status}    Run Keyword And Return Status   Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type.value}
        ${ru_type}    Set Variable If    ${status}    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type.value}
        ...                                           ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type}
        Run Keyword If    '${action}'=='power_off'    Run Keywords
        ...        pdu.setup_pdu    model=${model}   host=${ru_pdu_ip}    alias=ru_pdu_${ru_index}    AND
        ...        pdu.power_off    port=${ru_pdu_port}    pdu_device=ru_pdu_${ru_index}
        ...    ELSE IF    '${action}'=='power_on'    Run Keywords
        ...        pdu.setup_pdu    model=${model}   host=${ru_pdu_ip}    alias=ru_pdu_${ru_index}    AND
        ...        pdu.power_on    port=${ru_pdu_port}    pdu_device=ru_pdu_${ru_index}
    END

Perform Lock Or Unlock Single Cell On Special RU and Make Non-CA L3 call
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${ru_type}=AEHC   ${cell_type}=nr    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM    ${ue_index}=${0}
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${True}
    ${cell_list}    Get Cell List For Special RU    cell_type=${cell_type}
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type}
    ...    ru_index=${ru_index}
    FOR    ${cell_index}    IN    @{cell_list}
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=lock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=lock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Sleep    10sec
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unlock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unlock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Connect to gnb coam via ssl    connection=GNB_OAM
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${GNB_ALLOWED_FAULT}
        Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'    Check ENB On Air And Unexpect Alarm Should Not Exist
        Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'    Change cellBarred Parameter Value Of Lte Cells
        ...    list_cell_ids=all    exp_status=barred    enb_index=${0}
        ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
        @{nr_cell_list}    create list    ${cell_index}
        Verify Non-CA Basic L3 Call One By One    cell_list=${nr_cell_list}    ue_type=${ue_type}    ue_index=${ue_index}
        ...    enb_index=${fdd_enb_index}
    END

Perform Block Or Unblock Single Cell On Special RU and Make Non-CA L3 call
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${ru_type}=AEHC   ${cell_type}=nr    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM     ${ue_index}=${0}
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${True}
    ${cell_list}    Get Cell List For Special RU    cell_type=${cell_type}
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type}
    ...    ru_index=${ru_index}
    FOR    ${cell_index}    IN    @{cell_list}
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=block
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=block
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Sleep    10sec
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unblock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unblock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Connect to gnb coam via ssl    connection=GNB_OAM
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${GNB_ALLOWED_FAULT}
        Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'    Check ENB On Air And Unexpect Alarm Should Not Exist
        Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'    Change cellBarred Parameter Value Of Lte Cells
        ...    list_cell_ids=all    exp_status=barred    enb_index=${0}
        ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
        @{nr_cell_list}    create list    ${cell_index}
        Verify Non-CA Basic L3 Call One By One    cell_list=${nr_cell_list}    ue_type=${ue_type}    ue_index=${ue_index}
        ...    enb_index=${fdd_enb_index}
    END


Perform Lock Or Unlock LTE Cell On Special RU and Make LTE L3 call
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${ru_type}=AEHC   ${cell_type}=lte    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${True}
    ...            ${dl_throughput}=2500MKbits/sec     ${ue_index}=0
    ${lte_cell_list}    Get Cell List For Special RU    cell_type=${cell_type}
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type}
    ...    ru_index=${ru_index}     enb_index=${enb_index}
    FOR    ${lte_cell_index}    IN    @{lte_cell_list}
        Lock Or Unlock Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=lock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=lock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Sleep    10sec
        Lock Or Unlock Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=unlock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=unlock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Connect to gnb coam via ssl    connection=GNB_OAM
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${GNB_ALLOWED_FAULT}
        Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'    Check ENB On Air And Unexpect Alarm Should Not Exist
        Change status for parameter cellBarred on GNB    exp_status=barred   list_cell_ids=all    timeout=${timeout}
        @{lte_cell_list}    create list    ${lte_cell_index}
        Verify 4G Non-CA Basic L3 Call One By One    cell_list=${lte_cell_list}   ue_type=${ue_type}   enb_index=${0}
        ...    whether_do_barred_action=${True}    dl_throughput=${dl_throughput}       ue_index=${ue_index}
    END

Perform Block Or Unblock LTE Cell On Special RU and Make LTE L3 call
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${ru_type}=AEHC   ${cell_type}=lte    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${True}
    ...            ${dl_throughput}=2500MKbits/sec       ${ue_index}=0
    ${lte_cell_list}    Get Cell List For Special RU    cell_type=${cell_type}
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type}
    ...    ru_index=${ru_index}     enb_index=${enb_index}
    FOR    ${lte_cell_index}    IN    @{lte_cell_list}
        Lock Or Unlock Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=block
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=block
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Sleep    10sec
        Lock Or Unlock Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=unblock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=unblock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Connect to gnb coam via ssl    connection=GNB_OAM
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${GNB_ALLOWED_FAULT}
        Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'    Check ENB On Air And Unexpect Alarm Should Not Exist
        Change status for parameter cellBarred on GNB    exp_status=barred   list_cell_ids=all    timeout=${timeout}
        @{lte_cell_list}    create list    ${lte_cell_index}
        Verify 4G Non-CA Basic L3 Call One By One    cell_list=${lte_cell_list}   ue_type=${ue_type}   enb_index=${0}
        ...    whether_do_barred_action=${True}    dl_throughput=${dl_throughput}       ue_index=${ue_index}
    END

Perform Lock Or Unlock LTE Cell On Special RU and Make NSA L3 call
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${ru_type}=AEHC   ${cell_type}=lte    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM     ${ue_index}=${0}
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${True}
    ...            ${dl_throughput}=2500MKbits/sec    ${whether_do_stop_call}=${True}
    ${lte_cell_list}    Get Cell List For Special RU    cell_type=${cell_type}
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type}
    ...    ru_index=${ru_index}
    FOR    ${lte_cell_index}    IN    @{lte_cell_list}
        Lock Or Unlock Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=lock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=lock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Sleep    10sec
        Lock Or Unlock Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=unlock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=unlock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Connect to gnb coam via ssl    connection=GNB_OAM
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${GNB_ALLOWED_FAULT}
        Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'    Check ENB On Air And Unexpect Alarm Should Not Exist
        ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
        Procedures.Verify CA Basic L3 Call    ue_mode=NSA
        ...                                   ul_throughput=150M
        ...                                   dl_throughput=2500MKbits/sec
        ...                                   notbarred_cell_index=all
        ...                                   b1_select_cell_index=${PCELL_INDEX}
        ...                                   list_cell_ids=${lte_cell_index}
        ...                                   exp_status=barred
        ...                                   whether_do_lte_barred_action=${True}
        ...                                   whether_check_scell_addition=${False}
        ...                                   tput_collect_duration=60
        ...                                   ignore_time=15sec
        ...                                   target_DL_avg_percent=0.01
        ...                                   target_UL_avg_percent=0.0
        ...                                   min_DL_percent=0.0
        ...                                   min_UL_percent=0.0
        ...                                   check_scell_tput=${False}
        ...                                   scell_mapping=${None}
        ...                                   ue_index=${ue_index}
        ...                                   enb_index=${fdd_enb_index}
        Run Keyword If    ${whether_do_stop_call}    Procedures.Stop TMO L3 Call And Detach    ue_index=${ue_index}    ue_type=${ue_type}
    END


Perform Block Or Unblock LTE Cell On Special RU and Make NSA L3 call
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${ru_type}=AEHC   ${cell_type}=lte    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM       ${ue_index}=${0}
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${True}
    ...            ${dl_throughput}=2500MKbits/sec    ${whether_do_stop_call}=${True}
    ${lte_cell_list}    Get Cell List For Special RU    cell_type=${cell_type}
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type}
    ...    ru_index=${ru_index}
    FOR    ${lte_cell_index}    IN    @{lte_cell_list}
        Lock Or Unlock Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=block
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=block
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Sleep    10sec
        Lock Or Unlock Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=unblock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=unblock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Connect to gnb coam via ssl    connection=GNB_OAM
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${GNB_ALLOWED_FAULT}
        Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'    Check ENB On Air And Unexpect Alarm Should Not Exist
        ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
        Run Keyword And Continue On Failure    Procedures.Verify CA Basic L3 Call    ue_mode=NSA
        ...                                   ul_throughput=150M
        ...                                   dl_throughput=2500MKbits/sec
        ...                                   notbarred_cell_index=all
        ...                                   b1_select_cell_index=${PCELL_INDEX}
        ...                                   list_cell_ids=${lte_cell_index}
        ...                                   exp_status=barred
        ...                                   whether_do_lte_barred_action=${True}
        ...                                   whether_check_scell_addition=${False}
        ...                                   tput_collect_duration=60
        ...                                   ignore_time=15sec
        ...                                   target_DL_avg_percent=0.01
        ...                                   target_UL_avg_percent=0.0
        ...                                   min_DL_percent=0.00
        ...                                   min_UL_percent=0.00
        ...                                   check_scell_tput=${False}
        ...                                   scell_mapping=${None}
        ...                                   ue_index=${ue_index}
        ...                                   enb_index=${fdd_enb_index}
        Run Keyword If    ${whether_do_stop_call}    Procedures.Stop TMO L3 Call And Detach    ue_index=${ue_index}     ue_type=${ue_type}
    END

Unlock Cells On Special RU
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${ru_type}=AEHC   ${cell_type}=nr    ${timeout}=300    ${action}=unlock
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${True}
    ${cell_list}    Get Cell List For Special RU    cell_type=${cell_type}    whether_get_first_ru_only=${whether_get_first_ru_only}
    ...      ru_type=${ru_type}      ru_index=${ru_index}
    FOR    ${cell_index}    IN    @{cell_list}
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=${action}
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=${action}
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
    END

Lock Or Unlock Single Cell
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                Jia Lei: 20230217 add block and unblock status
    [Arguments]    ${cell_index}    ${cell_type}=nr    ${action}=lock    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ${4g_whether_in_gnb}    Check LTE Whether In Gnb    gnb_id=${gnb_index}    gnb_connection=${gnb_connection}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${cell_type}'!='nr'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${4g_whether_in_gnb}    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${cell_type}'=='nr'    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${cell_type}'!='nr'    ${enb_connection}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR   ${cell_dist_name}    IN     @{cell_list}
         ${cell}    Set Variable    ${cell_dist_name.split('/')[-1]}
         ${cell_idx}    Set Variable    ${cell.split('-')[-1]}
         ${distname}     Set Variable If    '${cell_index}' in '${cell_idx}'    ${cell_dist_name}    ${None}
         Exit For Loop If 	'${distname}' != '${None}'
    END
    Run Keyword If    '${action}'=='lock'
    ...        coam.lock    dist_name=${distname}    timeout=${timeout}    connection=${connection}
    ...    ELSE IF    '${action}'=='block'
    ...        coam.block    dist_name=${distname}    timeout=${timeout}    connection=${connection}
    ...    ELSE IF    '${action}'=='unlock'
    ...        coam.unlock    dist_name=${distname}    timeout=${timeout}    connection=${connection}
    ...    ELSE IF    '${action}'=='unblock'
    ...        coam.unblock_cell    dist_name=${distname}    timeout=${timeout}    connection=${connection}
    Sleep    60s
    [Teardown]    Teardown GNB and ENB Connections

Verify The Status Of Single Cell
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                Jia Lei: 20230217 add block and unblock status
    [Arguments]    ${cell_index}    ${cell_type}=nr    ${action}=lock    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ${4g_whether_in_gnb}    Check LTE Whether In Gnb    gnb_id=${gnb_index}    gnb_connection=${gnb_connection}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${cell_type}'!='nr'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${4g_whether_in_gnb}    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${cell_type}'=='nr'    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${cell_type}'!='nr'    ${enb_connection}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR   ${cell_dist_name}    IN     @{cell_list}
         ${distname}     Set Variable If    '${cell_index}' in '${cell_dist_name}'    ${cell_dist_name}    ${None}
         Exit For Loop If 	'${distname}' != '${None}'
    END
    ${result}    Run Keyword And Return Status    Should Contain Any    ${stream_version}    12.400    14.400    22R1    22R2    21B
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${disabled}    Set Variable If    ${result}    Disabled    disabled
    ${unlocked}    Set Variable If    '${cell_type}'=='nr' or '${cell_type}'=='gsm'    Unlocked    unlocked
    ${locked}    Set Variable If    '${cell_type}'=='nr' or '${cell_type}'=='gsm'    Locked    locked
    ${operationalState}    Set Variable If    '${action}'=='lock' or '${action}'=='block'    ${disabled}    ${enabled}
    ${administrativeState}    Set Variable If    '${action}'=='lock'    ${locked}    ${unlocked}
    ${blockingState}    Set Variable If    '${action}'=='block'    Blocked    Unblocked
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    FOR    ${item}    IN    @{cell_info}
        ${cell_status}    Run Keyword If    '${item['id']['configuration']}'=='${distname}'    Set Variable    ${item['status']}
        Exit For Loop If    '${item['id']['configuration']}'=='${distname}'
    END
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_status['operationalState']}    ${operationalState}
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_status['administrativeState']}    ${administrativeState}
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_status['blockingState']}    ${blockingState}
    [Teardown]    Teardown GNB and ENB Connections

Get All NR And LTE CellID List Of One Special RU
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param ${ru_type}:value like: "AEHC"
    ...                :param ${ru_index}: 0 means first AEHC, 1 means second AEHC, etc...
    [Arguments]    ${ru_index}=0    ${ru_type}=AEHC
    ${nr_cell_list}    Get Cell List For Special RU    cell_type=nr    ru_type=${ru_type}
    ...                                                ru_index=${ru_index}    whether_get_first_ru_only=${True}
    ${lte_cell_list}    Get Cell List For Special RU    cell_type=lte    ru_type=${ru_type}
    ...                                                 ru_index=${ru_index}    whether_get_first_ru_only=${True}
    Sort List    ${nr_cell_list}
    Sort List    ${lte_cell_list}
    [Return]    ${nr_cell_list}    ${lte_cell_list}

Do Type Cell Action Then Verify Status And Alarm
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    ...                ${cell_action}:value can be "locked"  or "unlocked"
    ...                ${cell_index}: value can be "None" means for all cells, if not "None" means for special cell
    [Arguments]    ${cell_index}    ${cell_action}=locked    ${cell_type}=nr
    ...            ${gnb_id}=0    ${enb_index}=${0}    ${is_check_cell_onAir}=${False}
    Do All Type Cells Action And Verify Status    cell_type=${cell_type}    gnb_id=${gnb_id}    enb_index=${enb_index}
    ...                                           cell_id=${cell_index}    cell_action=${cell_action}
    Check GNB On Air And Unexpect Alarm Should Not Exist    is_check_cell_onAir=${is_check_cell_onAir}
    Check ENB On Air And Unexpect Alarm Should Not Exist    is_check_cell_onAir=${is_check_cell_onAir}

Loop For Do Type Cell Action Then Verify Status And Alarm
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${cell_list}    ${list_index}    ${cell_action}=locked    ${cell_type}=nr
    ...            ${gnb_id}=0    ${enb_index}=${0}    ${is_check_cell_onAir}=${False}
    ${length}    Get Length    ${cell_list}
    FOR    ${i}    IN RANGE    ${length}
        ${cell_id}    Remove From List    ${cell_list}    ${list_index}
        Do Type Cell Action Then Verify Status And Alarm    cell_index=${cell_id}    cell_action=${cell_action}
        ...                                                 cell_type=${cell_type}    gnb_id=${gnb_id}
        ...                                                 enb_index=${enb_index}    is_check_cell_onAir=${is_check_cell_onAir}
    END

Check All Cells Should Be On Air Except One Locked Cell
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${cell_id}    ${gnb_id}=0    ${connection}=GNB_OAM
    Wait Until Keyword Succeeds    3min    2sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_id}
    Wait Until Keyword Succeeds    20min    2sec    COAM Check GNB ABIL status    connection=${connection}
    Wait Until Keyword Succeeds    20min    2sec    COAM Check GNB ASIK status    connection=${connection}
    Wait Until Keyword Succeeds    20min    2sec    COAM Check GNB RU status    connection=${connection}
    Wait Until Keyword Succeeds    20min    2sec    Verify all cells should be onair Except One Cell
    ...    cell_id=${cell_id}    connection=${connection}
    ${gnb_type}    Get gNbType SA or NSA via rest api    connection=${connection}
    Run Keyword If    'NSA' in '${gnb_type}'
    ...    Wait Until Keyword Succeeds    20min    2sec    COAM Check X2 link status from GNB    connection=${connection}
    Wait Until Keyword Succeeds    20min    2sec    Verify Gnb Type Cells Should Be Onair    cell_type=lte    connection=${connection}
    Wait Until Keyword Succeeds    20min    2sec    Verify Gnb Type Cells Should Be Onair    cell_type=wcdma    connection=${connection}
    Wait Until Keyword Succeeds    20min    2sec    Verify Gnb Type Cells Should Be Onair    cell_type=gsm    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Verify all cells should be onair Except One Cell
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${cell_id}    ${cell_type}=nr    ${connection}=GNB_OAM
    Log To Console    Verify all cells are on air except ${cell_id}
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${unlocked}    Set Variable If    ${result}==${False} and '${cell_type}'=='lte'    unlocked    ${unlocked}
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        ${cell_index}    Set Variable    ${cell['id']['configuration'].split('-')[-1]}
        ${admin_state}    Set Variable If    '${cell_index}'=='${cell_id}'    Locked     ${unlocked}
        ${opera_state}    Set Variable If    '${cell_index}'=='${cell_id}'    disabled     ${enabled}
        Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['administrativeState']}     ${admin_state}
        Run keyword and continue on failure    Should be equal as strings    ${cell['status']['operationalState']}    ${opera_state}
        run keyword if    ${result}    Run keyword and continue on failure
        ...    Should Be Equal As Strings    ${cell['status']['availabilityStatus']}   Online
    END

Check All Cells Should Be On Air Except Special RU Related Cells
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${ru_type}=AHFIG    ${cell_type}=nr     ${gnb_id}=0    ${connection}=GNB_OAM
    ${special_nr_cell_list}    Get Cell List For Special RU    cell_type=${cell_type}    ru_type=${ru_type}
    Wait Until Keyword Succeeds    3min    2sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_id}
    Wait Until Keyword Succeeds    20min    2sec    COAM Check GNB ABIL status    connection=${connection}
    Wait Until Keyword Succeeds    20min    2sec    COAM Check GNB ASIK status    connection=${connection}
    Wait Until Keyword Succeeds    20min    2sec    COAM Check GNB RU status    connection=${connection}
    Wait Until Keyword Succeeds    20min    2sec    Verify all cells should be onair Except Special RU Related Cells
    ...    special_nr_cell_list=${special_nr_cell_list}    connection=${connection}
    ${gnb_type}    Get gNbType SA or NSA via rest api    connection=${connection}
    Run Keyword If    'NSA' in '${gnb_type}'
    ...    Wait Until Keyword Succeeds    20min    2sec    COAM Check X2 link status from GNB    connection=${connection}
    Wait Until Keyword Succeeds    20min    2sec    Verify Gnb Type Cells Should Be Onair    cell_type=lte    connection=${connection}
    Wait Until Keyword Succeeds    20min    2sec    Verify Gnb Type Cells Should Be Onair    cell_type=wcdma    connection=${connection}
    Wait Until Keyword Succeeds    20min    2sec    Verify Gnb Type Cells Should Be Onair    cell_type=gsm    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Verify all cells should be onair Except Special RU Related Cells
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${special_nr_cell_list}    ${cell_type}=nr    ${connection}=GNB_OAM
    Log To Console    Verify all cells are on air except ${special_nr_cell_list}
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    FOR    ${cell}    IN    @{cells_info}
        ${cell_index}    Set Variable    ${cell['id']['configuration'].split('-')[-1]}
        ${status}    Run Keyword And Return Status    List Should Contain Value    ${special_nr_cell_list}    ${cell_index}
        ${opera_state}    Set Variable If    ${status}     disabled     ${enabled}
        Run keyword and continue on failure    Should be equal as strings    ${cell['status']['operationalState']}    ${opera_state}
    END

######2023.11.14  copy from 8360 for Guanghetong chips
Deployment SA And NSA Mode For 2UE Module
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...    para:${ue_mode}  value can be "NSA or SA"
    ...    please note, for SA mode, select ${nettpye}=SA+NSA; for NSA mode, select ${nettpye}=NSA
    [Arguments]    ${ue_mode}=SA      ${ue_index}=${0}
    ...            ${apn_address}=dxdata1
    ${nettpye}    Set Variable If    '${ue_mode}'=='NSA'     NSA    SA+NSA
    Log To Console    \nStart to deployment UE${ue_index} to ${ue_mode} Mode.
    spark.config_5g_deployment    nettype=${nettpye}    ue_alias=UE_${ue_index}

Change Network Mode Between SA And NSA For 2UE Module
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...    para:${ue_mode}  value can be "NSA or SA"
    [Arguments]    ${ue_mode}    ${ue_index}=${0}     ${ue_alias}=UE_${ue_index}
    Run Keyword If   '${ue_mode}'=='NSA'    Run Keywords
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTSET="5GSACTR",0    AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTACT=17    AND
    ...               Sleep    5s    AND
    ...               run keyword and ignore error    spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=at+cfun=0    AND
    ...               Sleep    5s     AND
    ...               run keyword and ignore error    spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=at+cfun=1    AND
    ...               Sleep    20s    AND
    ...               run keyword and ignore error    spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=at$qcrmcall=1,1    AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTAUTOCONNECT=0        AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+CGATT=0    AND
    ...               Sleep    5s
    Run Keyword If   '${ue_mode}'=='SA'    Run Keywords
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTSET="5GSACTR",1    AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTACT=14    AND
    ...               Sleep    5s    AND
    ...               run keyword and ignore error    spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=at+cfun=0    AND
    ...               Sleep    5s     AND
    ...               run keyword and ignore error    spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=at+cfun=1    AND
    ...               Sleep    20s    AND
    ...               run keyword and ignore error    spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=at$qcrmcall=1,1    AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTAUTOCONNECT=0        AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+CGATT=0    AND
    ...               Sleep    5s

# common keyword for 8UE module
Change Network Mode Between SA And NSA For 8UE Module
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    ...    para:${ue_mode}  value can be "NSA or SA"
    [Arguments]    ${ue_mode}  ${ue_index}=${0}     ${ue_alias}=UE_${ue_index}
    Run Keyword If   '${ue_mode}'=='NSA'    Run Keywords
    ...               spark.power_off    ue_alias=${ue_alias}    AND
    ...               Sleep    5s     AND
    ...               spark.power_on    ue_alias=${ue_alias}    AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTSET="5GSACTR",0    AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTACT=10    AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTACT=17    AND
    ...               Sleep    5s     AND
    ...               spark.power_off    ue_alias=${ue_alias}    AND
    ...               Sleep    5s     AND
    ...               spark.power_on    ue_alias=${ue_alias}    AND
    ...               Sleep    5s
    Run Keyword If   '${ue_mode}'=='SA'    Run Keywords
    ...               spark.power_off    ue_alias=${ue_alias}    AND
    ...               Sleep    5s     AND
    ...               spark.power_on    ue_alias=${ue_alias}    AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTSET="5GSACTR",1    AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTACT=10    AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTACT=14    AND
    ...               Sleep    5s     AND
    ...               spark.power_off    ue_alias=${ue_alias}    AND
    ...               Sleep    5s     AND
    ...               spark.power_on    ue_alias=${ue_alias}    AND
    ...               Sleep    5s

Change Network Mode Between SA And NSA and LTE For 8UE X65 Module
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    ...    para:${ue_mode}  value can be "NSA or SA"
    [Arguments]    ${ue_mode}  ${ue_index}=${0}     ${ue_alias}=UE_${ue_index}
    Run Keyword If   '${ue_mode}'=='NSA'    Run Keywords
    ...               spark.power_off    ue_alias=${ue_alias}    AND
    ...               Sleep    5s     AND
    ...               spark.power_on    ue_alias=${ue_alias}    AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+QNWPREFCFG="mode_pref",LTE:NR5G    AND
    ...               Sleep    5s     AND
    ...               spark.power_off    ue_alias=${ue_alias}    AND
    ...               Sleep    5s
    Run Keyword If   '${ue_mode}'=='SA'    Run Keywords
    ...               spark.power_off    ue_alias=${ue_alias}    AND
    ...               Sleep    5s     AND
    ...               spark.power_on    ue_alias=${ue_alias}    AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+QNWPREFCFG="mode_pref",NR5G    AND
    ...               Sleep    5s     AND
    ...               spark.power_off    ue_alias=${ue_alias}    AND
    ...               Sleep    5s
    Run Keyword If   '${ue_mode}'=='LTE'    Run Keywords
    ...               spark.power_off    ue_alias=${ue_alias}    AND
    ...               Sleep    5s     AND
    ...               spark.power_on    ue_alias=${ue_alias}    AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+QNWPREFCFG="mode_pref",LTE    AND
    ...               Sleep    5s     AND
    ...               spark.power_off    ue_alias=${ue_alias}    AND
    ...               Sleep    5s


##--- 4G keywords for case steps---#
#Procedures.Verify Non-CA 4G L3 Call
#    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
#    [Arguments]   ${not_barried_lte_cell}   ${expect_dl_tput}=100   ${ignore_time}=15sec   ${ue_index}=${0}
#    ...           ${dl_throughput}=2500MKbits/sec   ${gnb_index}=0   ${du_index}=0   ${timeout}=${300}
#    ...           ${connection}=GNB_OAM    ${start_keep_on_duration}=1200   ${tput_collect_duration}=300
#    ...           ${ul_throughput}=50M     ${iperf_path}=/data/local/tmp/iperf      ${expect_ul_tput}=10
#    ...           ${process_num}=${2}     ${detach_request}=${true}    ${power_reset}=False
#    ${dl_throughput}    Convert Dl Tput based on Process num    process_num=${process_num}    dl_throughput=${dl_throughput}
#    Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=${not_barried_lte_cell}    exp_status=notBarred
#    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
#    ${gnb_nr_cell_id_mapping}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids    connection_alias=${connection}
#    ${all_cell_ids}    Get dictionary keys    ${gnb_nr_cell_id_mapping}
#    @{params_for_update}    Create list
#    FOR    ${cell_index}    IN    @{all_cell_ids}
#        ${dist_name}    set variable    MRBTS-${tl.gnbs[${0}].instance_id}/NRBTS-${tl.gnbs[${0}].global_bts_id}/NRCELL-${cell_index}
#        ${param}    create dictionary    dist_name=${dist_name}    parameter=cellBarred    value=barred
#        Append to list    ${params_for_update}    ${param}
#    END
#    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}    timeout=${timeout}
#    ...    connection=${connection}
#    Procedures.Start UE Prepare    ue_index=${ue_index}    detach_request=${true}      power_reset=true
#    Run Keyword And Ignore Error    spark.send_AT_command_CPE     ue_alias=UE_${ue_index}   param=AT+CFUN=0
#    Run Keyword And Ignore Error    spark.send_AT_command_CPE     ue_alias=UE_${ue_index}   param=AT+CFUN=1
#    Run Keyword And Continue On Failure      Change Network Mode Between SA And NSA For 8UE Module
#    ...                                         ue_mode=NSA   ue_index=${ue_index}
#    &{master_config}   create dictionary
#    ...    host=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
#    ...    user=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
#    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
#    Set Test Variable    ${executor_oam_vm}    ${master_config}
#    Set Test Variable    ${tcpdump_collector_name}    cpif_tcpdump
#    tcpdump.create_tcpdump_collector    name=${tcpdump_collector_name}
#    ...                                 options=-i any
#    ...                                 executor=${executor_oam_vm}
#    ...                                 container=CPIF
#    tcpdump.Set Suite Alias    ${tcpdump_collector_name}
#    core.setup_collectors    names=${tcpdump_collector_name}
#    core.start_collectors    names=${tcpdump_collector_name}
#    Log to console   start to attach
#    Procedures.Start UE Prepare    ue_index=${ue_index}    detach_request=${true}      power_reset=true
#    power_ue.UE Attach    ue_index=${ue_index}    power_reset=true
#    ${attach_time}    DateTime.Get Current Date    result_format=%Y-%m-%d%H:%M:%S
#    Sleep    15sec
#    ${cpif_attach_log_on_testPC}    Run Keyword And Continue On Failure    Stop tcpdump log collection
#    ...    tcpdump_collector_name=${tcpdump_collector_name}
#    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#    ${attach_cell_index}   Get 4G Attach Cell Index From Wireshark   cpif_log_path=${cpif_attach_log_on_testPC}
#    ...                    enb_index=${fdd_enb_index}
#    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${attach_cell_index}    ${not_barried_lte_cell}
#    ${ue_ip_dict}    Wait Until Keyword Succeeds    3X    10sec    Get ALL PDU IP Address From Wireshark
#    ...    cpif_log_path=${cpif_attach_log_on_testPC}    mode=NSA
#    ${ul_throughput}   Run Keyword If    '${ue_type}'=='huawei_sigspark'
#    ...                                  Replace String      ${ul_throughput}      M        MKbits/sec
#    ...                ELSE   Set Variable   ${ul_throughput}
#    ${iperf_path}    Set Variable If    '${ue_type}'=='mtk' or '${ue_type}'=='samsung'    ${iperf_path}    iperf
#    Run Keyword If    '${ue_type}'=='huawei_sigspark'   power_ue.Start traffic
#    ...                                                      ue_type=${ue_type}
#    ...                                                      direction=ul
#    ...                                                      throughput=${ul_throughput}
#    ...                                                      duration=${start_keep_on_duration}
#    ...                                                      dt_name=DT_ul
#    ...                                                      apn_address=${apn_address}
#    ...                                                      ue_mode=NSA
#    ...                                                      ue_index=${ue_index}
#    ...     ELSE     traffic_via_iperf.Start UL traffic via iperf from andriod UE
#    ...                                        ue_index=${ue_index}
#    ...                                        ul_time=${start_keep_on_duration}
#    ...                                        ul_port=${56583}
#    ...                                        ul_throughput=${ul_throughput}
#    ...                                        ul_length=1400B
#    ...                                        appserver=APPserver
#    ...                                        protocol=udp
#    ...                                        iperf_path=${iperf_path}
#    ...                                        process_num=${1}
#    Start DL traffic via iperf on Appserver    ue_addr=${ue_ip_dict['data']}
#    ...                                                       dl_time=${start_keep_on_duration}
#    ...                                                       dl_port=${56883}
#    ...                                                       dl_throughput=${dl_throughput}
#    ...                                                       dl_length=1400B
#    ...                                                       appserver=APPserver
#    ...                                                       protocol=udp
#    ...                                                       ue_index=${ue_index}
#    ...                                                       process_num=${process_num}
#    ...                                                       seg_size=${1372}
#    ...                                                       window=2M
#    Check 4G Tput With Power UE    expect_dl_tput=${expect_dl_tput}
#    ...                            expect_ul_tput=${expect_ul_tput}
#    ...                            ignore_time=${ignore_time}
#    ...                            duration=${tput_collect_duration}
#    [Teardown]    Run keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections   AND
#    ...                           Run Keyword And Ignore Error    Csn.disconnect      connection=ASIK Master  AND
#    ...    Run Keyword And Ignore Error   Change Network Mode Between SA And NSA For 8UE Module   ue_mode=SA   ue_index=${ue_index}

Verify Whether FID10 Triggered On Enb
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    ...    In config.ini: need to  activate 'Monitoring_stop_with_file = stop_mon.log'
    [Arguments]    ${cell_index}=${12}
    ...            ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...            ${gnb_index}=0
    ...            ${enb_index}=0
    ...            ${du_index}=0
    ...            ${connection}=GNB_OAM
    ...            ${timeout}=600
    ...            ${target_dir}=/home/ute/syslog
    Log To Console    \***start to collect syslog***\
    ${enb_ip}    Set Variable    ${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
#    ${gnb_ip}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    ssh.send command    command=cd ${gnb_logs_script_path}/run&&rm syslog.tar.gz   connection=ute
#    ssh.send command    command=cd ${target_dir}&&rm syslog.tar.gz   connection=ute
    ${start_capture_command}     Catenate    ./gnb_logs ${enb_ip} -s -c5
#    ${start_capture_command}     Catenate    ./gnb_logs ${gnb_ip} -s -c5
    ssh.send command    command=cd ${gnb_logs_script_path}&&./${start_capture_command}   connection=ute
    sleep    10s
    Log To Console    \***start to one FDD RU in gnb***\
    Generate Pcell Mapping Info    pcell_index=${cell_index}
    ${ru_index}    Set Variable    ${PCELL_MAPPING['ru_index_mapping']}
    ${model}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].pdu_port.pdu.__class__.__name__}
    ${ru_pdu_ip}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].pdu_port.pdu.addr}
    ${ru_pdu_port}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].pdu_port.port_no}
    ${status}    Run Keyword And Return Status   Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type.value}
    ${ru_type}    Set Variable If    ${status}    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type.value}
    ...                                           ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type}
    pdu.setup_pdu    model=${model}   host=${ru_pdu_ip}    alias=ru_pdu_${ru_index}
    pdu.power_off    port=${ru_pdu_port}    pdu_device=ru_pdu_${ru_index}
    sleep  200s
    pdu.setup_pdu    model=${model}   host=${ru_pdu_ip}    alias=ru_pdu_${ru_index}
    pdu.power_on    port=${ru_pdu_port}    pdu_device=ru_pdu_${ru_index}
    Verify TMO Gnb Ready And All Cell On Air
    Log To Console    \***stop collect syslog***\
    ssh.send command    command=cd ${gnb_logs_script_path}&&touch ./stop_mon.log   connection=ute
    ssh.send command    command=cd ${gnb_logs_script_path}/run&&tar czvf syslog.tar.gz BTS_SYSLOG   connection=ute
#    ssh.send command    command=cp ${gnb_logs_script_path}/run/syslog.tar.gz ${target_dir}    connection=ute
#    Copy Files    ${gnb_logs_script_path}/run/syslog.tar.gz    ${target_dir}
    sleep    30s
    Log To Console    \***start to check sysylog***\
    ${bts_gz_command} =  set variable
        ...   gunzip -c ${gnb_logs_script_path}/run/syslog.tar.gz | grep -i 'CONNECTION_CHECK_DEST_UNREACHABLE'
    ${syslog_check_output}   RUN    ${bts_gz_command}
    ${status}    run keyword and return status    Should Not Be Empty    ${syslog_check_output}    FID 10 not triggered on enb
    Should Be True    ${status}    msg=FID 10 not find in sysylog
    [Teardown]    Run keywords    Run Keyword And Ignore Error    ssh.disconnect    connection=ute   AND
    ...        run keyword and ignore error    COAM Teardown gnb connections

Execute Memory On ENB
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${enb_index}=${0}
    ssh.Connect to    hostname=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...               username=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=ENB_${enb_index}
    ${output}    ssh.execute    command=date;cat /proc/meminfo |grep VmallocUsed     connection=ENB_${enb_index}
    ${valid_lines}    Get Lines Matching Regexp    ${output}    VmallocUsed    partial_match=true
    ${valid_lines_last}    Set variable    ${valid_lines.split(':')[-1]}
    ${VmallocUsed_value}     Set variable    ${valid_lines_last.split(' ')[-2]}
    [Return]     ${VmallocUsed_value}
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=ENB_${enb_index}

Modify Lss IP Adsress Paremeters
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${enb_index}=${0}
    ...            ${connection}=enblte
    ...            ${diagSnapDestination}=lss
    ...            ${actDefaultFaultSnapTriggers}=true
    ...            ${lssIPaddress}=10.38.198.54
    ...            ${timeout}=300
    Wait Until Keyword Succeeds   1 min   5 sec   Connect to eNB via ssl   enb_index=${enb_index}   connection=${connection}
    ${output}   coam.get_parameters_for_all    class_name=BTS    connection=${connection}
    ${btsid}    Set Variable   ${output[0]['btsId']}
    ${diagSnapDestination}    Create Dictionary    dist_name=MRBTS-${btsid}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                             parameter=diagSnapDestination
    ...                                             value=${diagSnapDestination}
    ${actDefaultFaultSnapTriggers}    Create Dictionary    dist_name=MRBTS-${btsid}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                                    parameter=actDefaultFaultSnapTriggers
    ...                                                    value=${actDefaultFaultSnapTriggers}
    &{value}   Create Dictionary   lssIPaddress=${lssIPaddress}
    ${lssIPaddress}     Evaluate
    ...    {'dist_name': 'MRBTS-${btsid}/MNL-1/MNLENT-1/TRBLCADM-1', 'parameter': 'lssConfig','value':[&{value}]}
    @{param_list}    Create List    ${diagSnapDestination}    ${actDefaultFaultSnapTriggers}   ${lssIPaddress}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    connection=${connection}    timeout=${timeout}
    [Teardown]    Run Keyword And Ignore Error    Enblte close down    connection=${connection}

Recover Collect Syslog On Control PC
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    ...   after L3 call, execute  keyword to recover collecting syslog on control pc
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${type}=MCU
    ...    ${aa_sys_mode}=5    ${aa_sys_addr}=0xC0A8FF7E    ${aa_sys_udp_port}=0xC738
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${0}].f1_m_ip_addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${response}    Wait until keyword succeeds    60s    500ms    aasyslog realtime output configuration
    ...    host=${host}    username=${username}    password=${password}    type=${type}
    ...    aa_sys_mode=${aa_sys_mode}    aa_sys_addr=${aa_sys_addr}    aa_sys_udp_port=${aa_sys_udp_port}
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect   connection=${connection}


#--- Kpi Caluate for OAM case---#
Case Status Init
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    Set Test Variable    ${CaseAVGLoop}     ${0}
    Set Test Variable    ${CaseSUM}         ${0}

Case Status Caluate
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${duration}=${0}    ${max}=${0}
    ${CaseSUM}    Run Keyword If    ${duration}<=${max}    Evaluate    ${CaseSUM}+${duration}
    ...    ELSE    Set Variable    ${CaseSUM}
    ${CaseAVGLoop}    Run Keyword If    ${duration}<=${max}    Evaluate    ${CaseAVGLoop}+${1}
     ...    ELSE    Set Variable    ${CaseAVGLoop}
    Set Test Variable    ${CaseSUM}     ${CaseSUM}
    Set Test Variable    ${CaseAVGLoop}         ${CaseAVGLoop}

Case Status Finnal
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${duration_time_list}    ${target_value}=${930}
    ${avg}    Run Keyword If     ${CaseAVGLoop}>0   Evaluate    ${CaseSUM}/${CaseAVGLoop}
    ...    ELSE    Fail    0 loop pass
    Append Case Result To File    index=Avg_value    target_value=${target_value}    result_value=${avg}
    Sort List    ${duration_time_list}
    Append Case Result To File    index=Max_value    target_value=${target_value}    result_value=${duration_time_list}[-1]

Copy File And Verify Whether Exist
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${source_file_path}    ${dest_file_path}=/home/ute/KPI_report    ${connection}=GNB_OAM    ${gnb_index}=${0}
    Wait Until Keyword Succeeds    3min    2sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${sw_version}     coam.get_sw_version    connection=${connection}
	${time}   DateTime.Get Current Date
	${time_start}    Fetch From Left     ${time}    ${SPACE}
    ${time_end}    Fetch From Right     ${time}    ${SPACE}
    Create Directory    ${dest_file_path}
    ${file_name}    Fetch From Right    ${source_file_path}    /
	${file_name}    Fetch From Left     ${file_name}    .
    ${dest_file_path}    Join Path    ${dest_file_path}    ${file_name}_${sw_version}_${time_start}_${time_end}.csv
    Run    cp ${source_file_path} ${dest_file_path}
    File Should Not Be Empty    ${dest_file_path}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Create Kpi Csv File
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    Set Test Variable    ${case_result_save_path}    ${TS_CASE_LOG_PATH}/${TEST NAME}_${tl_prefix}_${stream_version}.csv
    Create File    ${case_result_save_path}
    ${file_head}    Catenate    SEPARATOR=,    Index    Ru_type    Ru_index
    ...    Target_value    Result_value    Case_result\n
    Append To File    ${case_result_save_path}    ${file_head}

Append Case Result To File
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]   ${index}=NA    ${ru_type}=NA    ${ru_index}=NA
    ...           ${target_value}=NA   ${result_value}=NA    ${case_result}=NA
    ${check_kpi_value}    Run Keyword If
    ...    '${result_value}'!='NA' and '${target_value}'!='NA' and ${result_value}<=${target_value} and ${result_value}>${0}
    ...    Set Variable    pass
    ...    ELSE    Set Variable    fail
    ${target_value}    DateTime.Convert Date    ${target_value}    result_format=%Mmin%Ssec
    ${result_value}    DateTime.Convert Date    ${result_value}    result_format=%Mmin%Ssec
    ${data}    Run Keyword If    '${case_result}'!='NA'
    ...   Catenate    SEPARATOR=,    ${index}    ${ru_type}
    ...   ${ru_index}    ${target_value}    ${result_value}    ${case_result}\n
    ...   ELSE    Catenate    SEPARATOR=,    ${index}    ${ru_type}
    ...   ${ru_index}    ${target_value}    ${result_value}    ${check_kpi_value}\n
    Append To File    ${case_result_save_path}    ${data}

Loop For Site Reset Via WEBUI
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${gnb_index}=0    ${connection}=GNB_OAM
    Wait Until Keyword Succeeds    2min    20sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${timestartTmp}   DateTime.Get Current Date
    ${timestart}    DateTime.Convert Date    ${timestartTmp}    epoch
    coam.reset_site    timeout=${1800}    connection=${connection}
    ${reset_status_Tmp}    Run Keyword And Return Status    Check All Cells Should Be On Air
    ${timeendTmp}    DateTime.Get Current Date
    ${timeend}    DateTime.Convert Date    ${timeendTmp}     epoch
    ${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    ${reset_status}	   Set Variable If	  "${reset_status_Tmp}"=="True" and ${duration_time_tmp}<1800 	  Pass    Fail
    [Return]    ${reset_status}   ${duration_time_tmp}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Loop For RU Reset Via WEBUI
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ru_index}
    ...            ${download_dir}=${TS_CASE_LOG_PATH}
    ...            ${log_timeout}=${60}
    ...            ${gnb_index}=${0}
    ...            ${url}=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...            ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
    Wait Until Keyword Succeeds    2min    20sec    COAM Navigate to login page via webUI    download_dir=${download_dir}
    ...    timeout=${log_timeout}    gnb_index=${gnb_index}    url=${url}    username=${username}    password=${password}
    ${timestartTmp}   DateTime.Get Current Date
    ${timestart}    DateTime.Convert Date    ${timestartTmp}    epoch
    selenium_coam.reset_ru_from_site_view    ru_index=${ru_index}
    Wait Until Keyword Succeeds    5min    5sec    Check RU Whether Should Be Offline    ru_index=${ru_index}    gnb_index=${gnb_index}
    ${reset_status_Tmp}    Run Keyword And Return Status    Check All Cells Should Be On Air
    ${timeendTmp}    DateTime.Get Current Date
    ${timeend}    DateTime.Convert Date    ${timeendTmp}     epoch
    ${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    ${reset_status}	   Set Variable If	  "${reset_status_Tmp}"=="True" and ${duration_time_tmp}<1800 	  Pass    Fail
    [Return]    ${reset_status}   ${duration_time_tmp}
    [Teardown]    Run Keyword And Ignore Error    COAM selenium logout

Check RU Whether Should Be Offline
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ru_index}    ${gnb_index}=0    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    RU Should Be Offline    ru_index=${ru_index}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Make RU Reset With Retry
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ru_index}    ${reset_time}    ${max}    ${duration_time_list}    ${timeout}=${2400}
    FOR    ${i}    IN RANGE    ${reset_time}
        Run Keyword And Ignore Error    Run    command=rm /tmp/btslog2/* -rf
        Run Keyword And Ignore Error    Start To Collect Btslog    btslog_collector_name=btslog_${i+1}
        ${res}    Run Keyword And Ignore Error    Loop For RU Reset Via WEBUI    ru_index=${ru_index}
        ${reset_status}         Set Variable If    '${res[0]}'=='FAIL'      fail    ${res[1][0]}
        ${duration_time_tmp}    Set Variable If    '${res[0]}'=='FAIL'      1800    ${res[1][1]}
        Case Status Caluate    duration=${duration_time_tmp}    max=${max}
        Run Keyword If   ${duration_time_tmp}<=${max}    Append To List    ${duration_time_list}    ${duration_time_tmp}
        Log To Console     Case loop ${i+1} END
        Append Case Result To File    index=${i+1}    ru_type=AEHC    ru_index=${ru_index}
        ...    target_value=${max}    result_value=${duration_time_tmp}
        Run Keyword And Ignore Error    Stop Btslog Collection    btslog_collector_name=btslog_${i+1}
        ${unexpect_alarm_should_not_exist}    Check Unexpect Alarm And Trunk Roll
        Run Keyword If   ${unexpect_alarm_should_not_exist} and ${duration_time_tmp}>${max}
        ...    Run Keyword And Ignore Error    Common_keywords.Collect Snapshot Log    timeout=${timeout}
        ...    ELSE    Sleep    1min
    END

Check All Cells Should Be On Air
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
     Wait Until Keyword Succeeds    30min    2sec    Wait Gnb Ready And Cell On Air For Kpi

Wait Gnb Ready And Cell On Air For Kpi
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${gnb_id}=0    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_id}
    COAM Check GNB ABIL status    connection=${connection}
    COAM Check GNB ASIK status    connection=${connection}
    COAM Check GNB RU status    connection=${connection}
    Verify all cells should be onair    connection=${connection}
    ${gnb_type}    Get gNbType SA or NSA via rest api    connection=${connection}
    Run Keyword If    'NSA' in '${gnb_type}'    COAM Check X2 link status from GNB    connection=${connection}
    Verify Gnb Type Cells Should Be Onair    cell_type=lte    connection=${connection}
    Verify Gnb Type Cells Should Be Onair    cell_type=wcdma    connection=${connection}
    Verify Gnb Type Cells Should Be Onair    cell_type=gsm    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check Counter Value For ANR
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    ...                Description: for case 5603104, check counter: M55124C05002、M55147C01002、M55147C01001 at the same time
    [Arguments]  ${cell_index}    ${connection}=GNB_OAM    ${change_interval}=1min
    ...          ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...          ${MRBTS_id}=${tl.gnbs[0].instance_id}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}
    Log to console    Gathering value of counter: "M55124C05002"
    ${counters_info} =    coam.get_counters_info    connection=${connection}    timeout=120
    ${counter_groups} =    Get From Dictionary    ${counters_info}    BTS
    ${M55124C05002_path}    set variable if    '${stream_version}' == '24R1' or '${stream_version}' == '23R4'
    ...    CELLS/NRCELL-${cell_index}/NRRCC/NRRCC_NRCGI_REPORT_RECV
    ...    MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_index}/NRRCC/NRRCC_NRCGI_REPORT_RECV
    ${M55147C01002_path}    set variable if    '${stream_version}' == '24R1' or '${stream_version}' == '23R4'
    ...    CELLS/NRCELL-${cell_index}/NMOCU/NMOCU_ANR_NRREL_OVER_LIMIT
    ...    MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_index}/NMOCU/NMOCU_ANR_NRREL_OVER_LIMIT
    ${M55147C01001_path}    set variable if    '${stream_version}' == '24R1' or '${stream_version}' == '23R4'
    ...    CELLS/NRCELL-${cell_index}/NMOCU/NMOCU_ANR_NRREL_ADD
    ...    MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_index}/NMOCU/NMOCU_ANR_NRREL_ADD
    ${M55124C05002_counter_group_keys} =    Split String    ${M55124C05002_path}     /
    ${M55147C01002_counter_group_keys} =    Split String    ${M55147C01002_path}   /
    ${M55147C01001_counter_group_keys} =    Split String    ${M55147C01001_path}   /
    ${M55124C05002_counter_groups_length} =    Get Length    ${M55124C05002_counter_group_keys}
    ${M55147C01002_counter_groups_length} =    Get Length    ${M55147C01002_counter_group_keys}
    ${M55147C01001_counter_groups_length} =    Get Length    ${M55147C01001_counter_group_keys}
    Remove From List    ${M55124C05002_counter_group_keys}    ${M55124C05002_counter_groups_length-1}
    Remove From List    ${M55147C01002_counter_group_keys}    ${M55147C01002_counter_groups_length-1}
    Remove From List    ${M55147C01001_counter_group_keys}    ${M55147C01001_counter_groups_length-1}
    ${cells_counter_groups} =    run keyword if    '${stream_version}' == '24R1' or '${stream_version}' == '23R4'
    ...    Get From Dictionary    ${counter_groups}    CELLS
    ${mrbts_counter_groups} =    run keyword if    '${stream_version}' != '24R1' and '${stream_version}' != '23R4'
    ...    Get From Dictionary    ${counter_groups}    MRBTS-${MRBTS_id}
    ${nrbts_counter_groups} =    run keyword if    '${stream_version}' != '24R1' and '${stream_version}' != '23R4'
    ...    Get From Dictionary    ${mrbts_counter_groups}    NRBTS-${nr_bts_id}
    ${counter_groups}    set variable if    '${stream_version}' == '24R1' or '${stream_version}' == '23R4'
    ...    ${cells_counter_groups}     ${nrbts_counter_groups}
    ${counter_groups} =    Get From Dictionary    ${counter_groups}    NRCELL-${cell_index}
    ${M55124C05002_counter_groups} =    Get From Dictionary    ${counter_groups}    ${M55124C05002_counter_group_keys[-1]}
    ${M55147C01002_counter_groups} =    Get From Dictionary    ${counter_groups}    ${M55147C01002_counter_group_keys[-1]}
    ${M55147C01001_counter_groups} =    Get From Dictionary    ${counter_groups}    ${M55147C01001_counter_group_keys[-1]}
    ${M55124C05002_counter_values} =    Get From Dictionary    ${M55124C05002_counter_groups}    M55124C05002
    ${M55124C05002_key_list} =     Get Dictionary Keys    ${M55124C05002_counter_values}
    Reverse List    ${M55124C05002_key_list}
    ${M55124C05002_latest_value} =    Get From Dictionary    ${M55124C05002_counter_values}    ${M55124C05002_key_list[0]}
    ${M55124C05002_value}    convert to integer     ${M55124C05002_latest_value}
    Should Be True    ${M55124C05002_value} == 1
    Log to console    Gathering value of counter: "M55147C01002"
    ${M55147C01002_counter_values} =    Get From Dictionary    ${M55147C01002_counter_groups}    M55147C01002
    ${M55147C01002_key_list} =     Get Dictionary Keys    ${M55147C01002_counter_values}
    Reverse List    ${M55147C01002_key_list}
    ${M55147C01002_latest_value} =    Get From Dictionary    ${M55147C01002_counter_values}    ${M55147C01002_key_list[0]}
    ${M55147C01002_value}    convert to integer     ${M55147C01002_latest_value}
    Should Be True    ${M55147C01002_value} == 0
    Log to console    Gathering value of counter: "M55147C01001"
    ${status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${M55147C01001_counter_groups}    M55147C01001
    ${M55147C01001_counter_values} =  Run Keyword If   ${status}
    ...           Get From Dictionary    ${M55147C01001_counter_groups}    M55147C01001
    ${M55147C01001_key_list} =     Run Keyword If   ${status}
    ...           Get Dictionary Keys    ${M55147C01001_counter_values}
    Run Keyword If   ${status}     Reverse List    ${M55147C01001_key_list}
    ${M55147C01001_latest_value} =    Run Keyword If   ${status}
    ...           Get From Dictionary    ${M55147C01001_counter_values}    ${M55147C01001_key_list[0]}
    ${M55147C01001_value}    Run Keyword If   ${status}     convert to integer     ${M55147C01001_latest_value}
    Run Keyword If   ${status}    Should Be True    ${M55147C01001_value} == 0
    [Teardown]    Run Keyword And Ignore Error     COAM Teardown gnb connections    connection=${connection}

Get cellBwpList Length From SCF
    [Arguments]      ${cell_id}=1
    ...              ${connection}=GNB_OAM
    ...              ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...              ${MRBTS_id}=${tl.gnbs[0].instance_id}
    ...              ${dist_name}=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_id}
    wait until keyword succeeds     5 min   10 sec     Connect to gnb coam via ssl
    @{cellBwpList_param}    create list
    @{BWP_PROFILE_list}    create list
    &{cellBwpList_dict}    Create Dictionary    dist_name=${dist_name}
    ...                                                           parameter=cellBwpList
    ...                                                           value=none
    Append To List    ${cellBwpList_param}    ${cellBwpList_dict}
    ${cellBwpList}    coam_parameter.get_list_values_from_scf_file    parameters=${cellBwpList_param}
    ...                                                               connection=${connection}
    ...                                                               timeout=300
    ${cellBwpList_value}    set variable    ${cellBwpList[0]['value']}
    FOR    ${item}    IN    @{cellBwpList_value}
        ${status}    Run Keyword And Return Status    Should Contain     ${item}    BWP_PROFILE
        run keyword if    ${status}    append to list    ${BWP_PROFILE_list}    ${item}
    END
    ${BWP_PROFILE_length}      Get Length    ${BWP_PROFILE_list}
    [Return]    ${BWP_PROFILE_length}


Get nrhoirDNList value From SCF
    [Arguments]      ${cell_id}=301
    ...              ${connection}=GNB_OAM
    ...              ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...              ${MRBTS_id}=${tl.gnbs[0].instance_id}
    ...              ${dist_name}=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_id}
    wait until keyword succeeds     5 min   10 sec     Connect to gnb coam via ssl
    @{nrhoirDNList_list}    create list
    &{nrhoirDNList_dict}    Create Dictionary    dist_name=${dist_name}
    ...                                          parameter=nrhoirDNList
    ...                                          value=none
    Append To List    ${nrhoirDNList_list}    ${nrhoirDNList_dict}
    ${nrhoirDNList_value}    coam_parameter.get_list_values_from_scf_file    parameters=${nrhoirDNList_list}
    ...                                                               connection=${connection}
    ...                                                               timeout=300
    [Return]   ${nrhoirDNList_value[0]['value']}


Modify chBW And Related Parameters via WebUI
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...     for case:5603105, all default values are used for 80MHz configuration
    [Arguments]     ${cell_list}
    ...             ${configuration_type}=80MHz
    ...             ${bwpdn0_profile}=187
    ...             ${bwpdn1_profile}=217
    ...             ${bwpdn2_profile}=233
    ...             ${bwpdn3_profile}=87
    ...             ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...             ${MRBTS_id}=${tl.gnbs[0].instance_id}
    ...             ${cellchBW_value}=80MHz
    ...             ${nrarfcn_value}=510024
    ...             ${csirsPower_value}=17
    ...             ${cSRS_value}=23
    ...             ${maxCsirsNumber_value}=1
    ...             ${actMultipleDedicatedBWPs_value}=true
    ...             ${actEnhMultipleDedicatedBWPs_value}=true
    ...             ${actPowerSavingBWP_value}=true
    ...             ${actDynPdcchTd_value}=false
    ...             ${gscnOrSsPbchArfcn_value}=6303
    ...             ${msg1FrequencyStart_value}=28
    ...             ${reqMinNumPuschPrb_value}=189
    ...             ${ssPbchBlockPower_value}=14
    ...             ${pMax_value}=32.7
    ...             ${connection}=GNB_OAM
    ...             ${gnb_index}=0
    ...             ${timeout}=300
    ...             ${actDynPdcchTdMode}=disabled
    ...             ${actInitialBWPFlexibility_value}=false
#    ...             ${actNrRim_value}=RI detection and mitigation
    ...             ${globalF0ForRs_value}=510024
    @{update_param_list}    Create List
    @{value_list}    Create List
    @{delete_param_list}    Create List
    @{add_param_list}    Create List
    @{cellBwpList_added}    Run Keyword If    '${configuration_type}'=='80MHz'    Create list    ${0}    ${1}    ${2}    ${3}
    ...      ELSE      Create list    ${0}    ${1}
    ${actMultipleDedicatedBWPs}     Create Dictionary      dist_name=NRBTS-${nr_bts_id}
    ...                                   abbr=actMultipleDedicatedBWPs
    ...                                   filter_param=Activate multiple dedicated bandwidth parts (BWPs)
    ...                                   new_value=${actMultipleDedicatedBWPs_value}
    Append To List    ${update_param_list}    ${actMultipleDedicatedBWPs}
    FOR    ${cell}   IN    @{cell_list}
        ${dist_name}    Set Variable    NRCELL-${cell}
        ${dist_name_for_globalF0ForRs}    Set Variable    NRCELL-${cell}/NRRIM_PROFILE-1
        ${csirsPower}     Create Dictionary     dist_name=${dist_name}
        ...                                   abbr=csirsPower
        ...                                   filter_param=CSI-RS power
        ...                                   new_value=${csirsPower_value}
        ${maxCsirsNumber}     Create Dictionary     dist_name=${dist_name}
        ...                                   abbr=maxCsirsNumber
        ...                                   filter_param=Maximum CSI-RS number
        ...                                   new_value=${maxCsirsNumber_value}
        ${cSRS}     Create Dictionary         dist_name=${dist_name}
        ...                                   abbr=cSRS
        ...                                   filter_param=SRS bandwidth configuration
        ...                                   new_value=${cSRS_value}
        ${cellchBW}     Create Dictionary     dist_name=${dist_name}
        ...                                   abbr=chBw
        ...                                   filter_param=Channel bandwidth
        ...                                   new_value=${cellchBW_value}
        ${actInitialBWPFlexibility_value} = 	Set Variable If    '${stream_version}'=='23R4'
        ...                                     ${actInitialBWPFlexibility_value}      ${actPowerSavingBWP_value}
        ${actInitialBWPFlexibility}     Create Dictionary     dist_name=${dist_name}
        ...                                   abbr=actInitialBWPFlexibility
        ...                                   filter_param=Activate flexible setting of initial bandwidth part
        ...                                   new_value=${actInitialBWPFlexibility_value}
        ${actULSchedInactiveBwp}        Create Dictionary     dist_name=${dist_name}
        ...                                   abbr=actULSchedInactiveBwp
        ...                                   filter_param=Activate UL scheduling for inactive BWP
        ...                                   new_value=${actPowerSavingBWP_value}
        ${nrarfcn}     Create Dictionary      dist_name=${dist_name}
        ...                                   abbr=nrarfcn
        ...                                   filter_param=NR Absolute radio frequency channel number
        ...                                   new_value=${nrarfcn_value}
        ${globalF0ForRs}     Create Dictionary      dist_name=${dist_name_for_globalF0ForRs}
        ...                                         abbr=globalF0ForRs
        ...                                         filter_param=Global F0 for RIM-RS
        ...                                         new_value=${globalF0ForRs_value}
        ${actEnhMultipleDedicatedBWPs}     Create Dictionary      dist_name=${dist_name}
        ...                                   abbr=actEnhMultipleDedicatedBWPs
        ...                                   filter_param=Activate enhanced multiple dedicated bandwidth parts (BWPs)
        ...                                   new_value=${actEnhMultipleDedicatedBWPs_value}
        ${actPowerSavingBWP}     Create Dictionary      dist_name=${dist_name}
        ...                                   abbr=actPowerSavingBWP
        ...                                   filter_param=Activate power saving bandwidth part
        ...                                   new_value=${actPowerSavingBWP_value}
        ${actLAForHiReliab}     Create Dictionary     dist_name=${dist_name}
        ...                                  abbr=actLAForHiReliab
        ...                                  filter_param=Activate link adaptation for high reliability DRB
        ...                                  new_value=false
        ${gscnOrSsPbchArfcn}     Create Dictionary      dist_name=${dist_name}
        ...                                   abbr=gscnOrSsPbchArfcn
        ...                                   filter_param=Synchronization channel number
        ...                                   new_value=${gscnOrSsPbchArfcn_value}
        ${msg1FrequencyStart}     Create Dictionary      dist_name=${dist_name}
        ...                                   abbr=msg1FrequencyStart
        ...                                   filter_param=PRACH Frequency start
        ...                                   new_value=${msg1FrequencyStart_value}
        ${pMax}     Create Dictionary         dist_name=${dist_name}
        ...                                   abbr=pMax
        ...                                   filter_param=Maximum output power
        ...                                   new_value=${pMax_value}
        ${reqMinNumPuschPrb}     Create Dictionary      dist_name=${dist_name}
        ...                                   abbr=reqMinNumPuschPrb
        ...                                   filter_param=Requested minimum number of PUSCH PRBs
        ...                                   new_value=${reqMinNumPuschPrb_value}
        ${ssPbchBlockPower}     Create Dictionary      dist_name=${dist_name}
        ...                                   abbr=ssPbchBlockPower
        ...                                   filter_param=SS PBCH Block Power
        ...                                   new_value=${ssPbchBlockPower_value}
#        ${actNrRim}    Create Dictionary    dist_name=${dist_name}
#        ...                                 abbr=actNrRim
#        ...                                 filter_param=Activate NR remote interference management
#        ...                                 new_value=${actNrRim_value}
        Generate remove element for bwpDN    cell_id=${cell}    delete_param_list=${delete_param_list}
        Generate add element for bwpDN    cell=${cell}    add_param_list=${add_param_list}    cellBwpList_added=${cellBwpList_added}
        ...         bwpdn0_profile=${bwpdn0_profile}
        ...         bwpdn1_profile=${bwpdn1_profile}
        ...         bwpdn2_profile=${bwpdn2_profile}
        ...         bwpdn3_profile=${bwpdn3_profile}
        ${dynPdcchTdMgt_23R3}     Create Dictionary     dist_name=${dist_name}
        ...                                  abbr=dynPdcchTdMgt
        ...                                  filter_param=CActivate dynamic PDCCH time domain
        ...                                  new_value=${actDynPdcchTd_value}
        ${dynPdcchTdMgt_trunk}     Create Dictionary     dist_name=${dist_name}
        ...                                  abbr=actDynPdcchTdMode
        ...                                  filter_param=Active dynamic PDCCH time domain mode
        ...                                  new_value=${actDynPdcchTdMode}
        ${dynPdcchTdMgt}    Set Variable If      '${stream_version}'=='23R3'     ${dynPdcchTdMgt_23R3}    ${dynPdcchTdMgt_trunk}
        Append To List    ${update_param_list}    ${cellchBW}     ${nrarfcn}    ${globalF0ForRs}     ${actEnhMultipleDedicatedBWPs}
        ...               ${actPowerSavingBWP}    ${gscnOrSsPbchArfcn}    ${msg1FrequencyStart}    ${pMax}    ${actLAForHiReliab}
#        ...               ${reqMinNumPuschPrb}    ${ssPbchBlockPower}    ${actNrRim}    ${cSRS}   ${actULSchedInactiveBwp}
        ...               ${reqMinNumPuschPrb}    ${ssPbchBlockPower}    ${cSRS}   ${actULSchedInactiveBwp}
        ...               ${csirsPower}   ${maxCsirsNumber}    ${dynPdcchTdMgt}    ${actInitialBWPFlexibility}
    END
    ${delete_param_list}    Set Variable    ${delete_param_list}
    ${add_param_list}    Set Variable    ${add_param_list}
    ${update_param_list}    Set Variable    ${update_param_list}
    log to console    --- start to update bwp related params via WEBUI---
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
	${active_version}    coam.get_sw_version    timeout=60    connection=${connection}
	${version_splitted}    Split String    ${active_version}    _
    ${sw_version}    Strip string    ${version_splitted[0]}
    Selenium Login And Disable Screen Lock    browser=Chrome    version=${sw_version}
    WEBUI Remove Element For bwpDN    deleted_params=${delete_param_list}
    WEBUI Add Element For bwpDN    added_params=${add_param_list}
    WEBUI Update Param For bwpDN    updated_params=${update_param_list}
    log to console    --- start to validate and activate plan---
    selenium_coam.validate_plan
    Run Keyword And Continue On Failure    COAM check validation errors from webui    is_need_to_check_validation_errors=${True}
    selenium_coam.activate_plan   download_plan_without_activation=${False}    activate_plan_despite_errors=${True}
    ...   execute=${True}   timeout=600
    sleep  30s
    Close Start Up View    timeout=60
    [Teardown]    run keyword and ignore error    selenium logout and close browser

WEBUI Remove Element For bwpDN
    [Arguments]    ${deleted_params}
    ${paramdel_len}    get length    ${deleted_params}
    FOR  ${i}  IN RANGE  ${paramdel_len}
        ${new_value}    Set Variable    ${deleted_params[${i}].get('new_value', ${None})}
        ${new_value}    Set Variable if    '${new_value}'=='FALSE' or '${new_value}'=='TRUE'    ${new_value.lower()}    ${new_value}
        ${node_index}    Set Variable    ${deleted_params[${i}].get('node_index', ${None})}
        ${abbr}    Set Variable    ${deleted_params[${i}].get('abbr', ${None})}
        ${dist_name}    Set Variable    ${deleted_params[${i}]['dist_name']}
        log to console    “try ${i}, delete ${abbr} for ${deleted_params[${i}]['dist_name']}”
        WEBUI Remove Element
        ...   dist_name=${dist_name}
        ...   filter_param=${deleted_params[${i}]['filter_param']}
        ...   abbr=${abbr}
        ...   new_value=${new_value}
        ...   node_index=${node_index}
    END

WEBUI Update Param For bwpDN
    [Arguments]    ${updated_params}
    ${paramlist_len}    get length   ${updated_params}
    FOR  ${i}  IN RANGE  ${paramlist_len}
        ${new_value}    Set Variable    ${updated_params[${i}].get('new_value', ${None})}
        ${new_value}    Set Variable if    '${new_value}'=='FALSE' or '${new_value}'=='TRUE'    ${new_value.lower()}    ${new_value}
        ${node_index}    Set Variable    ${updated_params[${i}].get('node_index', ${None})}
        ${abbr}    Set Variable    ${updated_params[${i}].get('abbr', ${None})}
        ${dist_name}    Set Variable If    'NRCELL' in '${updated_params[${i}]['dist_name']}'
        ...    ${updated_params[${i}]['dist_name'].split('/')[-1]}    ${updated_params[${i}]['dist_name']}
        ${dist_name_for_globalF0ForRs}    Set Variable    ${updated_params[${i}]['dist_name']}
        ${dist_name}    Set Variable If    '${abbr}'=='globalF0ForRs'    ${dist_name_for_globalF0ForRs}    ${dist_name}
        log to console    “try ${i}, modify ${abbr} to ${new_value} for ${updated_params[${i}]['dist_name']}”
        WEBUI Set Param Value
        ...   dist_name=${dist_name}
        ...   filter_param=${updated_params[${i}]['filter_param']}
        ...   abbr=${abbr}
        ...   new_value=${new_value}
        ...   node_index=${node_index}
    END

WEBUI Remove Element
    [Arguments]   ${dist_name}   ${filter_param}   ${abbr}   ${new_value}    ${node_index}=${0}
    run keyword if   '${new_value}'=='${None}'    selenium_coam.remove_element
     ...   dist_name=${dist_name}
     ...   filter_param=${filter_param}
     ...   abbr=${abbr}
     ...   node_index=${node_index}


WEBUI Set Param Value
    [Arguments]   ${dist_name}   ${filter_param}   ${abbr}   ${new_value}    ${node_index}=${0}
    run keyword if   '${new_value}'!='${None}'     selenium_coam.set_parameter_value
    ...   dist_name=${dist_name}
    ...   filter_param=${filter_param}
    ...   abbr=${abbr}
    ...   new_value=${new_value}
    ...   node_index=${node_index}
    ...   timeout=${600}

WEBUI Add Element For bwpDN
    [Documentation]   only for adding bwpDN and set parameter value
    [Arguments]   ${added_params}
    ${paramadd_len}    get length    ${added_params}
    FOR  ${index}  IN RANGE  ${paramadd_len}
        ${added_param_cell}    Set Variable    ${added_params[${index}]}
        WEBUI Add BwpDN For each cell    added_param_cell=${added_param_cell}
    END

WEBUI Add BwpDN For each cell
    [Documentation]   only for adding bwpDN and set parameter value
    [Arguments]   ${added_param_cell}
    ${cell_len}    get length    ${added_param_cell}
    FOR  ${i}  IN RANGE  ${cell_len}
        WEBUI Add BwpDN Operation    added_param_cell_per_bwpdn=${added_param_cell[${i}]}
    END

WEBUI Add BwpDN Operation
    [Documentation]   only for adding bwpDN and set parameter value
    [Arguments]   ${added_param_cell_per_bwpdn}
    ${paramadd_len}    get length    ${added_param_cell_per_bwpdn}
    selenium_coam.add_element
    ...    dist_name=${added_param_cell_per_bwpdn[${0}]['dist_name']}    filter_param=Cell bandwidth part list
    FOR  ${i}  IN RANGE  ${paramadd_len}
        ${new_value}    Set Variable    ${added_param_cell_per_bwpdn[${i}].get('new_value', ${None})}
        ${new_value}    Set Variable if    '${new_value}'=='FALSE' or '${new_value}'=='TRUE'    ${new_value.lower()}    ${new_value}
        ${node_index}    Set Variable    ${added_param_cell_per_bwpdn[${i}].get('node_index', ${0})}
        ${abbr}    Set Variable    ${added_param_cell_per_bwpdn[${i}].get('abbr', ${None})}
        ${dist_name}     Set Variable    ${added_param_cell_per_bwpdn[${i}]['dist_name']}
        log to console    “try ${i}, add ${abbr} to ${new_value} for ${added_param_cell_per_bwpdn[${i}]['dist_name']}”
        Run Keyword If    '${dist_name}'=='${added_param_cell_per_bwpdn[${0}]['dist_name']}'    WEBUI Set Param Value
        ...   dist_name=${dist_name}
        ...   filter_param=${added_param_cell_per_bwpdn[${i}]['filter_param']}
        ...   abbr=${abbr}
        ...   new_value=${new_value}
        ...   node_index=${node_index}
    END

Generate remove element for bwpDN
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...     remove element in WebUI: bwpDN
    [Arguments]    ${cell_id}    ${delete_param_list}
    ${cellBwpList_length}    Get CellBwpList Length From SCF    cell_id=${cell_id}
    FOR    ${bwpdn_id}    IN RANGE    ${cellBwpList_length}
        ${bwpdn_param_delete}    Create Dictionary     dist_name=NRCELL-${cell_id}
        ...   filter_param=Bandwidth Part Profile distinguished name
        ...   abbr=bwpDN
        ...   node_index=${bwpdn_id}
        Append To List    ${delete_param_list}     ${bwpdn_param_delete}
    END


Generate add element for bwpDN
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...     add element in WebUI: bwpDN
    [Arguments]    ${cell}    ${add_param_list}    ${cellBwpList_added}
    ...             ${bwpdn0_profile}=187
    ...             ${bwpdn1_profile}=217
    ...             ${bwpdn2_profile}=233
    ...             ${bwpdn3_profile}=87
    @{add_bwpdn_per_cell}    create list
    ${cellBwpList_length}    Get CellBwpList Length From SCF    cell_id=${cell}
    FOR    ${node_index}    IN   @{cellBwpList_added}
        @{cellBwpList}    create list
        ${node_index0}    Evaluate    ${cellBwpList_length}+${node_index}
        ${node_index1}    Evaluate    ${cellBwpList_length}+${1}
        ${node_index2}    Evaluate    ${cellBwpList_length}+${2}
        ${node_index3}    Evaluate    ${cellBwpList_length}+${3}
        ${bwpDN_0}     Create Dictionary     dist_name=NRCELL-${cell}
        ...                                  abbr=bwpDN
        ...                                  filter_param=Bandwidth Part Profile distinguished name
        ...                                  new_value=BWP_PROFILE-${bwpdn0_profile}
        ...                                  node_index=${cellBwpList_length}
        ${bwpDN_1}     Create Dictionary     dist_name=NRCELL-${cell}
        ...                                  abbr=bwpDN
        ...                                  filter_param=Bandwidth Part Profile distinguished name
        ...                                  new_value=BWP_PROFILE-${bwpdn1_profile}
        ...                                  node_index=${node_index1}
        ${bwpDN_2}     Create Dictionary     dist_name=NRCELL-${cell}
        ...                                  abbr=bwpDN
        ...                                  filter_param=Bandwidth Part Profile distinguished name
        ...                                  new_value=BWP_PROFILE-${bwpdn2_profile}
        ...                                  node_index=${node_index2}
        ${bwpDN_3}     Create Dictionary     dist_name=NRCELL-${cell}
        ...                                  abbr=bwpDN
        ...                                  filter_param=Bandwidth Part Profile distinguished name
        ...                                  new_value=BWP_PROFILE-${bwpdn3_profile}
        ...                                  node_index=${node_index3}
        ${cellBwpId}     Create Dictionary     dist_name=NRCELL-${cell}
        ...                                  abbr=cellBwpId
        ...                                  filter_param=Cell bandwidth part Identifier
        ...                                  new_value=str(${node_index})
        ...                                  node_index=${node_index0}
        ${pdcchResourcePreference}     Create Dictionary     dist_name=NRCELL-${cell}
        ...                                  abbr=pdcchResourcePreference
        ...                                  filter_param=PDCCH resource preference mode
        ...                                  new_value=peakRate
        ...                                  node_index=${node_index0}
        ${actPdcchCceFragmentControl}     Create Dictionary     dist_name=NRCELL-${cell}
        ...                                  abbr=actPdcchCceFragmentControl
        ...                                  filter_param=Activate PDCCH CCE fragment control
        ...                                  new_value=false
        ...                                  node_index=${node_index0}
        ${actUpperThrAckNackFiltering}     Create Dictionary     dist_name=NRCELL-${cell}
        ...                                  abbr=actUpperThrAckNackFiltering
        ...                                  filter_param=Activate upper ACK/NACK filtering threshold
        ...                                  new_value=false
        ...                                  node_index=${node_index0}
        ${actUpperThrAckNackHrFiltering}     Create Dictionary     dist_name=NRCELL-${cell}
        ...                                  abbr=actUpperThrAckNackHrFiltering
        ...                                  filter_param=Activate upper ACK/NACK filtering threshold for high reliability DRB
        ...                                  new_value=false
        ...                                  node_index=${node_index0}
        Append To List    ${cellBwpList}     ${cellBwpId}    ${bwpDN_${node_index}}
        Append To List    ${add_bwpdn_per_cell}     ${cellBwpList}
    END
    Append To List    ${add_param_list}     ${add_bwpdn_per_cell}


Modify chBW And Related Parameters
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    ...     for case:5603105, all default values are used for 80MHz configuration
    [Arguments]     ${cell_list}
    ...             ${configuration_type}=80MHz
    ...             ${bwpdn0_profile}=187
    ...             ${bwpdn1_profile}=217
    ...             ${bwpdn2_profile}=233
    ...             ${bwpdn3_profile}=87
    ...             ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...             ${MRBTS_id}=${tl.gnbs[0].instance_id}
    ...             ${cellchBW_value}=80MHz
    ...             ${nrarfcn_value}=510024
    ...             ${csirsPower_value}=17
    ...             ${maxCsirsNumber_value}=1
    ...             ${actMultipleDedicatedBWPs_value}=true
    ...             ${actEnhMultipleDedicatedBWPs_value}=true
    ...             ${actPowerSavingBWP_value}=true
    ...             ${actDynPdcchTd_value}=false
    ...             ${gscnOrSsPbchArfcn_value}=6303
    ...             ${msg1FrequencyStart_value}=28
    ...             ${reqMinNumPuschPrb_value}=189
    ...             ${ssPbchBlockPower_value}=14
    ...             ${pMax_value}=327
    ...             ${connection}=GNB_OAM
    ...             ${gnb_index}=0
    ...             ${timeout}=300
    ...             ${actDynPdcchTdMode}=disabled
    @{param_list}    Create List
    @{value_list}    Create List
    @{delete_param_list}    Create List
    @{add_param_list}    Create List
    ${bwpDN_0}     Create Dictionary    bwpDN=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/BWP_PROFILE-${bwpdn0_profile}
    ...                                 cellBwpId=0
    ${bwpDN_0_23R4}     Create Dictionary    bwpDN=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/BWP_PROFILE-${bwpdn0_profile}
    ...                                 cellBwpId=0
    ...                                 actPdcchCceFragmentControl=false
    ...                                 pdcchResourcePreference=peakRate
    ${bwpDN_0_master}     Create Dictionary    bwpDN=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/BWP_PROFILE-${bwpdn0_profile}
    ...                                 cellBwpId=0
    ...                                 actPdcchCceFragmentControl=false
    ...                                 pdcchResourcePreference=peakRate
    ...                                 actUpperThrAckNackFiltering=false
    ...                                 actUpperThrAckNackHrFiltering=false
    ${bwpDN_1}     Create Dictionary    bwpDN=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/BWP_PROFILE-${bwpdn1_profile}
    ...                                 cellBwpId=1
    ${bwpDN_1_23R4}     Create Dictionary    bwpDN=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/BWP_PROFILE-${bwpdn1_profile}
    ...                                 cellBwpId=1
    ...                                 actPdcchCceFragmentControl=false
    ...                                 pdcchResourcePreference=peakRate
    ${bwpDN_1_master}     Create Dictionary    bwpDN=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/BWP_PROFILE-${bwpdn1_profile}
    ...                                 cellBwpId=1
    ...                                 actPdcchCceFragmentControl=false
    ...                                 pdcchResourcePreference=peakRate
    ...                                 actUpperThrAckNackFiltering=false
    ...                                 actUpperThrAckNackHrFiltering=false
    ${bwpDN_2}     Create Dictionary    bwpDN=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/BWP_PROFILE-${bwpdn2_profile}
    ...                                 cellBwpId=2
    ${bwpDN_2_23R4}     Create Dictionary    bwpDN=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/BWP_PROFILE-${bwpdn2_profile}
    ...                                 cellBwpId=2
    ...                                 actPdcchCceFragmentControl=false
    ...                                 pdcchResourcePreference=peakRate
    ${bwpDN_2_master}     Create Dictionary    bwpDN=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/BWP_PROFILE-${bwpdn2_profile}
    ...                                 cellBwpId=2
    ...                                 actPdcchCceFragmentControl=false
    ...                                 pdcchResourcePreference=peakRate
    ...                                 actUpperThrAckNackFiltering=false
    ...                                 actUpperThrAckNackHrFiltering=false
    ${bwpDN_3}     Create Dictionary    bwpDN=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/BWP_PROFILE-${bwpdn3_profile}
    ...                                 cellBwpId=3
    ${bwpDN_3_23R4}     Create Dictionary    bwpDN=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/BWP_PROFILE-${bwpdn3_profile}
    ...                                 cellBwpId=3
    ...                                 actPdcchCceFragmentControl=false
    ...                                 pdcchResourcePreference=peakRate
    ${bwpDN_3_master}     Create Dictionary    bwpDN=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/BWP_PROFILE-${bwpdn3_profile}
    ...                                 cellBwpId=3
    ...                                 actPdcchCceFragmentControl=false
    ...                                 pdcchResourcePreference=peakRate
    ...                                 actUpperThrAckNackFiltering=false
    ...                                 actUpperThrAckNackHrFiltering=false
    ${bwpDN_0} = 	Set Variable If
    ... 	       '${stream_version}'=='master' or '${stream_version}'=='24R1'    ${bwpDN_0_master}
    ... 	       '${stream_version}'=='23R4' 	    ${bwpDN_0_23R4}
    ... 	       '${stream_version}'=='23R3'      ${bwpDN_0}
    ${bwpDN_1} = 	Set Variable If
    ... 	       '${stream_version}'=='master' or '${stream_version}'=='24R1' 	${bwpDN_1_master}
    ... 	       '${stream_version}'=='23R4' 	    ${bwpDN_1_23R4}
    ... 	       '${stream_version}'=='23R3'      ${bwpDN_1}
    ${bwpDN_2} = 	Set Variable If
    ... 	       '${stream_version}'=='master' or '${stream_version}'=='24R1' 	${bwpDN_2_master}
    ... 	       '${stream_version}'=='23R4' 	    ${bwpDN_2_23R4}
    ... 	       '${stream_version}'=='23R3'      ${bwpDN_2}
    ${bwpDN_3} = 	Set Variable If
    ... 	       '${stream_version}'=='master' or '${stream_version}'=='24R1' 	${bwpDN_3_master}
    ... 	       '${stream_version}'=='23R4' 	    ${bwpDN_3_23R4}
    ... 	       '${stream_version}'=='23R3'      ${bwpDN_3}
    Run Keyword If    '${configuration_type}'=='80MHz'       Append To List    ${value_list}
    ...             ${bwpDN_0}    ${bwpDN_1}    ${bwpDN_2}    ${bwpDN_3}
    ...      ELSE      Append To List    ${value_list}      ${bwpDN_0}     ${bwpDN_1}
    &{periodicCsiAcquisition_param}    Create Dictionary     csirsPower=${csirsPower_value}
    ...                                                      maxCsirsNumber=${maxCsirsNumber_value}
    &{dynPdcchTdMgt_param}    Create Dictionary     actDynPdcchTd=${actDynPdcchTd_value}
    ${actMultipleDedicatedBWPs}     Create Dictionary      dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}
    ...                                   parameter=actMultipleDedicatedBWPs
    ...                                   value=${actMultipleDedicatedBWPs_value}
    Append To List    ${param_list}    ${actMultipleDedicatedBWPs}
    FOR    ${cell}   IN    @{cell_list}
        ${cellchBW}     Create Dictionary     dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                   parameter=chBw
        ...                                   value=${cellchBW_value}
        ${nrarfcn}     Create Dictionary      dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                   parameter=nrarfcn
        ...                                   value=${nrarfcn_value}
        ${actEnhMultipleDedicatedBWPs}     Create Dictionary      dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                   parameter=actEnhMultipleDedicatedBWPs
        ...                                   value=${actEnhMultipleDedicatedBWPs_value}
        ${actPowerSavingBWP}     Create Dictionary      dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                   parameter=actPowerSavingBWP
        ...                                   value=${actPowerSavingBWP_value}
        ${gscnOrSsPbchArfcn}     Create Dictionary      dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                   parameter=gscnOrSsPbchArfcn
        ...                                   value=${gscnOrSsPbchArfcn_value}
        ${msg1FrequencyStart}     Create Dictionary      dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                   parameter=msg1FrequencyStart
        ...                                   value=${msg1FrequencyStart_value}
        ${pMax}     Create Dictionary      dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                   parameter=pMax
        ...                                   value=${pMax_value}
        ${reqMinNumPuschPrb}     Create Dictionary      dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                   parameter=reqMinNumPuschPrb
        ...                                   value=${reqMinNumPuschPrb_value}
        ${ssPbchBlockPower}     Create Dictionary      dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                   parameter=ssPbchBlockPower
        ...                                   value=${ssPbchBlockPower_value}
        ${cellBwpList}     Create Dictionary     dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                   parameter=cellBwpList
        ...                                   value=${value_list}
        ${cellBwpList_delete}    Create Dictionary     dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                   parameter=cellBwpList
        Append To List    ${delete_param_list}     ${cellBwpList_delete}
        ${dist_name}    Set Variable    MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ${periodicCsiAcquisition}    Evaluate
        ...    {'dist_name': '${dist_name}', 'parameter': 'periodicCsiAcquisition','value':[&{periodicCsiAcquisition_param}]}
        ${dynPdcchTdMgt_23R3}    Evaluate
        ...    {'dist_name': '${dist_name}', 'parameter': 'dynPdcchTdMgt','value':[&{dynPdcchTdMgt_param}]}
        ${dynPdcchTdMgt_trunk}     Create Dictionary      dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                   parameter=actDynPdcchTdMode
        ...                                   value=${actDynPdcchTdMode}
        ${dynPdcchTdMgt}    Set Variable If      '${stream_version}'=='23R3'     ${dynPdcchTdMgt_23R3}    ${dynPdcchTdMgt_trunk}
        Append To List    ${param_list}    ${cellchBW}     ${nrarfcn}     ${actEnhMultipleDedicatedBWPs}
        ...               ${actPowerSavingBWP}    ${gscnOrSsPbchArfcn}    ${msg1FrequencyStart}    ${pMax}
        ...               ${reqMinNumPuschPrb}    ${ssPbchBlockPower}
        ...               ${periodicCsiAcquisition}   ${dynPdcchTdMgt}
        Append To List    ${add_param_list}     ${cellBwpList}
    END
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM delete parameters via rest api        parameters_to_delete_via_api=${delete_param_list}
    ...                                        timeout=${timeout}
    ...                                        connection=${connection}
    sleep    60s
    COAM add several parameters via rest api     parameters_to_add_via_api=${add_param_list}
    ...                                          timeout=${timeout}
    ...                                          connection=${connection}
    sleep    60s
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    connection=${connection}   timeout=${timeout}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}



Get TDD large chbw cells
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...     get 100M AEHC cells
    [Arguments]    ${aehc_nr_cell_list}
    ${large_chbw_nrcells_list}     Create List
    FOR    ${cell_index}    IN    @{aehc_nr_cell_list}
        Wait Until Keyword Succeeds    1 min    5 sec  Connect to gnb coam via ssl
        ${chbw}    coam_parameter.get_single_value_from_scf_file    parameter=chBw
        ...                                                         dist_name=NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${cell_index}
        ...                                                         connection=GNB_OAM
        ...                                                         timeout=300
        Run Keyword if    "${chbw}"=="100MHz"    Append to list    ${large_chbw_nrcells_list}    ${cell_index}
    END
    [Return]    ${large_chbw_nrcells_list}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Start L3 call and Record tput with aasyslog
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...     start sa l3 call and record tput with aasyslog, wo checking tput
    [Arguments]    ${cell_list}    ${ue_index}=${0}   ${gnb_index}=${0}    ${du_index}=${0}
    ...            ${cell_type}=nr    ${ul_throughput}=220M    ${dl_throughput}=3000MKbits/sec
    ...            ${whether_do_ue_prepare}=${False}    ${whether_need_ue_log}=${False}
    ...            ${get_spark_license}=${true}
    &{tput_file_for_upgrade}     Create Dictionary
    FOR    ${cell_index}    IN    @{cell_list}
        Wait Until Keyword Succeeds    1 min    5 sec  Connect to gnb coam via ssl
        Set Test Variable    ${test_case_id}    ${TEST NAME.split('_')[0]}
        Trun Off All PA Ports
        Set PA value based on pcell index    pcell_index=${cell_index}    ue_index=${ue_index}
        ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
        Procedures.Verify CA Basic L3 Call
        ...    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}
        ...    whether_check_tupt=${False}
        ...    notbarred_cell_index=${cell_index}
        ...    b1_select_cell_index=${cell_index}
        ...    expect_addition_scell_indexs=${None}
        ...    pcell_mapping=${None}
        ...    scell_mapping=${None}
        ...    list_cell_ids=all
        ...    enb_index=${fdd_enb_index}
        ...    whether_do_ue_prepare=${whether_do_ue_prepare}
        ...    whether_need_ue_log=${whether_need_ue_log}
        ...    ue_index=${ue_index}
        ...    get_spark_license=${get_spark_license}
        sleep    30sec
        ${host}   Start To Capture Aasyslog    gnb_index=${gnb_index}    du_index=${du_index}
        Sleep    180sec
        ${tupt_file_path}    Stop To Capture And Download Aasyslog    host=${host}
        Procedures.Stop TMO L3 Call And Detach    ue_index=${ue_index}    ue_type=${ue_type}
        Set To Dictionary    ${tput_file_for_upgrade}    ${cell_index}=${tupt_file_path}
    END
    [Return]    ${tput_file_for_upgrade}

Check Tput from aasyslog file
    [Documentation]    Auther:lei.jia@nokia-sbell.com
    ...                Descrition: Verify throughput from aasyslog file
    [Arguments]    ${tput_log}
    ...            ${expect_tput}=0
    ...            ${cellid}=1
    ...            ${connection}=GNB_OAM
    ...            ${target_avg_percent}=0.8
    ...            ${min_percent}=0
    ...            ${actCarrierAggregation}=${False}
    ...            ${list_all_cell_ids}=${False}
    ...            ${check_source}=spark
    ...            ${direction}=UL
    ${ue_type}    Set Variable If   'spark' in '${ue_type}'    qct_dx50    ${ue_type}
    Wait Until Keyword Succeeds    1 min    5 sec  Connect to gnb coam via ssl
    ${list_nrcell_ids}    check_android_ue_l3_call_process.Get NRCELLID based on CELLID
    ...    cellid=${cellid}    connection=${connection}    list_all_cell_ids=${list_all_cell_ids}
    ${aasyslog_TPUT}    Run Keyword And Continue On Failure    Power_ue.Check Tput    ue_type=${ue_type}    direction=${direction}
    ...                                                           log=${tput_log}    cells=${list_nrcell_ids}
    ...                                                           target_throughput=${expect_tput}
    ...                                                           target_avg_percent=${target_avg_percent}
    ...                                                           actCarrierAggregation=${actCarrierAggregation}
    ...                                                           check_source=${check_source}
    ...                                                           min_percent=${min_percent}
    ${tput_result}    Evaluate    int(${aasyslog_TPUT[0]['average']})
    [Return]    ${tput_result}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections


Verify Test In Loop
    [Documentation]
    ...   Perform test verification in loop:
    ...   - check bts proper state before test,
    ...   - provide syslog collection,
    ...   - run test, then check for crashes in syslog and get test result,
    ...   - uuf_rfrl_common_keywords.Gather Snapshot if iteration failed,
    ...   - recover hardware if needed,
    ...   - provide report to Reporting portal,
    ...   - get PASS to FAIL ratio.
    [Arguments]    ${iteration_number}  ${should_be_reported}  ${test_keyword}
    @{loop_results}=    Create List
    Set Test Variable  ${LOOP_RESULTS}
    @{fails_after_test}=    Create List
    &{kpis}=    Create Dictionary
    Set Test Variable  ${KPIS}  ${kpis}
    Set Test Variable  ${PASS_ITERATION}  ${0}
    FOR    ${i}    IN RANGE    1    ${iteration_number}+1
        Set Test Variable  ${i}
        uuf_rfrl_common_keywords.Get Iteration Start Time
        Log    ${\n}Iteration_${i} of ${test_keyword} started : ${START_TIME}    console=yes
        ${iteration_result}    ${error}=    Run Keyword And Ignore Error    ${test_keyword}  i=${i}
        Run Keyword If  "${iteration_result}"=="FAIL"  Log  Loop_${i} Failed due to Error:${\n}${error}  ERROR  console=yes
        ${test_run_status}=  uuf_rfrl_common.Evaluate Test Run Results  ${iteration_result}
        Append To List    ${loop_results}    ${test_run_status}
        uuf_rfrl_common_keywords.Get Iteration End Time
        Run Keyword If  "${should_be_reported}" == "True"  uuf_rfrl_common_keywords.Report To Reporting Portal  ${test_run_status}
        Exit For Loop If    "${iteration_result}" == "FAIL"
    END
    uuf_rfrl_common_keywords.Pass Ratio    ${loop_results}
    List Should Not Contain Value    ${loop_results}    failed
    [Teardown]    Run Keywords
    ...  Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Report Success Ratio
    ...  AND      Run Keyword If  "${should_be_reported}" == "True"  Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Report Kpi Results
    ...  ELSE     Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Log Kpi Results
    ...  AND      Run Keyword If  "${should_be_reported}" == "True"  Run Keyword And Ignore Error  uuf_rfrl_common.Log Reports


Perform Lock Or Unlock Single Cell On Special RU with OAM KPI
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${i}    ${ru_type}=AEHC   ${cell_type}=nr    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${True}
    ${cell_list}    Get Cell List For Special RU    cell_type=${cell_type}
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type}
    ...    ru_index=${ru_index}
    ${loop_num}     Set Variable     1
    FOR    ${cell_index}    IN    @{cell_list}
        ${test_lock_phase}     Set Variable      Loop_lock_${i}_${loop_num}
        uuf_rfrl_common_keywords.Get Iteration Start Time
        uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=lock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=lock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
		uuf_rfrl_common_keywords.Get Iteration End Time
		uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_lock_phase} Lock
        sleep   10s
        ${test_unlock_phase}     Set Variable      Loop_unlock_${i}_${loop_num}
        uuf_rfrl_common_keywords.Get Iteration Start Time
        uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unlock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unlock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        ${gnb_state}    ${gnb_error_log}=     Run Keyword And Ignore Error
        ...             Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
		${test_result}    uuf_rfrl_common.Verify Iteration   ${test_unlock_phase}   ${gnb_state}
		uuf_rfrl_common_keywords.Get Iteration End Time
		uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_unlock_phase} Unlock
        ${loop_num}   Convert To Integer     ${loop_num}
		${loop_num}    Evaluate     ${loop_num}+1
		Run Keyword If   '${test_result}'=='False'   Common_keywords.Collect Snapshot Log    timeout=${2400}
		Run Keyword If   '${test_result}'=='False'   Fail    unlock cell Failed - ${test_unlock_phase}
    END

Perform BBMOD From All RU Reset with OAM KPI
    [Documentation]    xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${i}
    ${bbmod_distname_list}    Get BBMOD List For All RU
    ${loop_num}     Set Variable     1
    FOR    ${bbmod_distname}    IN    @{bbmod_distname_list}
		${test_phase}     Set Variable      Loop_${i}_${loop_num}
		uuf_rfrl_common_keywords.Get Iteration Start Time
		uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
		Wait Until Keyword Succeeds    2 min    20 sec    Connect to gnb coam via ssl    connection=GNB_OAM
		...                                                                              gnb_index=${0}
		Run Keyword And Ignore Error     coam.reset_unit    dist_name=${bbmod_distname}    reset_type=Warm    force_radio_reset=${True}
		 ...                timeout=${600}    connection=GNB_OAM
		Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM
		${gnb_state}    ${gnb_error_log}=   Run Keyword And Ignore Error
		...             Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
		${enb_state}    ${enb_error_log}=   Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
		...                                  Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
		${test_result}    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
        ...               uuf_rfrl_common.Verify Iteration     ${test_phase}   ${enb_state}   ${gnb_state}
        ...               ELSE    uuf_rfrl_common.Verify Iteration    ${test_phase}   ${gnb_state}
		uuf_rfrl_common_keywords.Get Iteration End Time
		uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_phase}
		${loop_num}   Convert To Integer     ${loop_num}
		${loop_num}    Evaluate     ${loop_num}+1
		Run Keyword If   '${test_result}'=='False'   Collect Snapshot Log in gnb and enb    timeout=${2400}
		Run Keyword If   '${test_result}'=='False'   Fail    BBMOD RESET Failed - ${test_phase}
    END
    [Teardown]   Teardown GNB and ENB Connections

Get BBMOD List For All RU
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM0    ${gnb_index}=${0}    ${du_index}=${0}
    ${ru_list}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus}
    ${sn_list_of_special_ru}    Create List
    FOR    ${ru}    IN    @{ru_list}
        ${ru_index}    Get Index From List    ${ru_list}    ${ru}
        ${sn}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].serial_number}
        ${status}    Run Keyword And Return Status   Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type.value}
        ${ru_type}    Set Variable If    ${status}    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type.value}
        ...                                           ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type}
        Append To List    ${sn_list_of_special_ru}    ${sn}
    END
    Wait Until Keyword Succeeds    2 min    20 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${rmod_sn_mapping}    gnbaction.get_rmod_sn_mapping
    ${rmod_index_list}    Get Dictionary Keys    ${rmod_sn_mapping}
    ${rmod_list_of_special_ru}    Create List
    FOR    ${rmod_index}    IN    @{rmod_index_list}
        ${serial_number}    Set Variable    ${rmod_sn_mapping['${rmod_index}']}
        ${status}    Run Keyword And Return Status    List Should Contain Value    ${sn_list_of_special_ru}    ${serial_number}
        Run Keyword If    ${status}    Append To List    ${rmod_list_of_special_ru}    ${rmod_index}
    END
    ${rmod_bbmod_mapping}    gnbaction.get_rmod_bbmod_mapping
    ${bbmod_list_of_special_ru}    Create List
    FOR    ${rmod}    IN    @{rmod_list_of_special_ru}
        ${vlaue_list}    Get From Dictionary    ${rmod_bbmod_mapping}    ${rmod}
        ${bbmod_list_of_special_ru}    Combine Lists    ${bbmod_list_of_special_ru}    ${vlaue_list}
        ${bbmod_list_of_special_ru}    Remove Duplicates    ${bbmod_list_of_special_ru}
    END
    ${bbmod_distname_list}    Create List
    ${output}   coam.get_fbb_info   connection=${connection}
    FOR  ${bbmod_info}   IN  @{output}
        ${bbmod_productName}   Set Variable   ${bbmod_info['productName']}
        ${bbmod_number}   Set Variable   ${bbmod_info['id']['configuration'].split('-')[-1]}
        ${status}    Run Keyword And Return Status    List Should Contain Value    ${bbmod_list_of_special_ru}    ${bbmod_number}
        Run Keyword If    ${status}    Append To List    ${bbmod_distname_list}    ${bbmod_info['id']['internal']}
        Run Keyword If  '${bbmod_productName}'=='ABIA AirScale Capacity'
        ...             Remove From List   ${bbmod_distname_list}    -1
    END
    [Return]     ${bbmod_distname_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}


Perform Special RU Reset with OAM KPI
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${i}   ${ru_type}=all    ${cell_type}=nr    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${False}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${LTE_WHETHER_IN_GNB}    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'=='nr'    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'!='nr'    ${enb_connection}
    ${sn_of_first_ru}    Set Variable    ${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}].serial_number}
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    @{aehc_ru_list}    Create List
    FOR    ${ru}    IN    @{list_RUs}
        ${rmod_info}   Set variable   ${ru['id']['internal']}
        ${serialNumber}   Set variable    ${ru['serialNumber']}
        Run Keyword If    ${whether_get_first_ru_only}==${False} and '${ru['productName']}'=='${ru_type}'
        ...                             Append To List    ${aehc_ru_list}    ${rmod_info}
        ...    ELSE IF    ${whether_get_first_ru_only} and '${ru['productName']}'=='${ru_type}' and '${serialNumber}'=='${sn_of_first_ru}'
        ...                             Append To List    ${aehc_ru_list}    ${rmod_info}
        ...    ELSE IF    ${whether_get_first_ru_only}==${False} and '${ru_type}'=='all'
        ...                             Append To List    ${aehc_ru_list}    ${rmod_info}
    END
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    ${loop_num}     Set Variable     1
    FOR    ${ru_index}    IN    @{aehc_ru_list}
        ${test_phase}     Set Variable      Loop_${i}_${loop_num}
        uuf_rfrl_common_keywords.Get Iteration Start Time
        uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
        Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
        Run Keyword And Ignore Error    coam.reset_unit    dist_name=${ru_index}     reset_type=Warm
        ...         force_radio_reset=${True}   connection=${connection}   timeout=${timeout}
        Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
		${gnb_state}    ${gnb_error_log}=    Run Keyword And Ignore Error
		...             Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
		${enb_state}    ${enb_error_log}=    Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
		...                                   Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
        ${test_result}    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
        ...               uuf_rfrl_common.Verify Iteration     ${test_phase}   ${enb_state}    ${gnb_state}
        ...               ELSE    uuf_rfrl_common.Verify Iteration    ${test_phase}   ${gnb_state}
		uuf_rfrl_common_keywords.Get Iteration End Time
		uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_phase}
		${loop_num}   Convert To Integer     ${loop_num}
		${loop_num}    Evaluate     ${loop_num}+1
		Run Keyword If   '${test_result}'=='False'   Collect Snapshot Log in gnb and enb    timeout=${2400}
		Run Keyword If   '${test_result}'=='False'   Fail    RU RESET Failed - ${test_phase}
		Exit For Loop If    "${test_result}" == "FAIL"
    END
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}    AND
    ...    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Perform Block Or Unblock Single Cell On Special RU with OAM KPI
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${i}    ${ru_type_tmo}=AEHC   ${cell_type}=nr    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${True}
    ${cell_list}    Get Cell List For Special RU    cell_type=${cell_type}
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type_tmo}
    ...    ru_index=${ru_index}
    ${loop_num}     Set Variable     1
    FOR    ${cell_index}    IN    @{cell_list}
        ${test_lock_phase}     Set Variable      Loop_lock_${i}_${loop_num}
        uuf_rfrl_common_keywords.Get Iteration Start Time
        uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=block
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=block
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
		uuf_rfrl_common_keywords.Get Iteration End Time
		uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_lock_phase} block
        sleep   10s
        ${test_unlock_phase}     Set Variable      Loop_unlock_${i}_${loop_num}
        uuf_rfrl_common_keywords.Get Iteration Start Time
        uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unblock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unblock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        ${gnb_state}    ${gnb_error_log}=   Run Keyword And Ignore Error     Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
		${test_result}    uuf_rfrl_common.Verify Iteration   ${test_unlock_phase}   ${gnb_state}
		uuf_rfrl_common_keywords.Get Iteration End Time
		uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_unlock_phase} unblock
        ${loop_num}   Convert To Integer     ${loop_num}
		${loop_num}    Evaluate     ${loop_num}+1
		Run Keyword If   '${test_result}'=='False'   Common_keywords.Collect Snapshot Log    timeout=${2400}
		Run Keyword If   '${test_result}'=='False'   Fail    unblock Cell Failed - ${test_unlock_phase}
    END

Perform Reset with HWF deletion
    [Documentation]    author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${i}
    ${test_phase}    Set Variable    loop_${i}
#    COAM Create log directory
    Common_setup_and_teardown.Create Case Log Path
#    ${swconfig_list}=   Create List    0x4F0214=0
#    Modify Swconfig File   para_update=${swconfig_list}
    run keyword and ignore error    COAM Teardown gnb connections
    uuf_rfrl_common_keywords.Get Iteration Start Time
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
    Wait Until Keyword Succeeds    1 min    5 sec   Connect to gnb coam via ssl
    Run Keyword And Ignore Error    coam.reset_site    wait_for_reconnection=${True}    connection=GNB_OAM    timeout=600
    sleep   2min
    ${gnb_status_status}   ${gnb_error_log}=    Run Keyword And Ignore Error    Verify TMO Gnb Ready And All Cell On Air
    Check Gnb Startup Log
    ${gnb_state}   ${gnb_error_log}=   Run Keyword And Ignore Error
    ...            Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
    ${enb_state}   ${enb_error_log}=   Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
    ...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
    ${test_result}    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
    ...               uuf_rfrl_common.Verify Iteration     ${test_phase}   ${enb_state}    ${gnb_status_status}   ${gnb_state}
    ...               ELSE    uuf_rfrl_common.Verify Iteration    ${test_phase}    ${gnb_status_status}   ${gnb_state}
    uuf_rfrl_common_keywords.Get Iteration End Time
	uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_phase}
	Run Keyword If   '${test_result}'=='False'   Collect Snapshot Log in gnb and enb    timeout=${2400}
#	FOR    ${enb_id}    IN RANGE    ${enb_length}
#        Connect to eNB via ssl   enb_index=${enb_id}    connection=enblte_${enb_id}
#        coam.reset_site    connection=enblte_${enb_id}
#        sleep   5min
#        Wait until keyword succeeds    5 min    20 sec   Verify Enb All Cell On Air    enb_index=${enb_id}
#        Connect to eNB via ssl   enb_index=${enb_id}    connection=enblte_${enb_id}
#        Run Keyword And Continue On Failure
#        ...   Unexpect Alarm Should Not Exist   allowed_faults=@{GNB_ALLOWED_FAULT}  connection=enblte_${enb_id}
#        Run Keyword And Continue On Failure
#        ...  Unexpect History Alarm Should Not Exist  allowed_faults=@{ALLOWED_HISTORY_FAULT}   connection=enblte_${enb_id}
#    END
    Run Keyword If   '${test_result}'=='False'   Fail    Site Reset Failed - ${test_phase}
    [Teardown]      Run Keyword And Ignore Error    COAM Teardown gnb connections

Perform Lock Or Unlock LTE Single Cell On Special RU with OAM KPI
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${i}    ${ru_type}=AEHC   ${cell_type}=lte    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${True}
    ${ru_type}      Set Variable If    '${tl_prefix}'=='T816'         AZHL     ${ru_type}
    ${cell_list}    Get Cell List For Special RU    cell_type=${cell_type}
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type}
    ...    ru_index=${ru_index}
    ${loop_num}     Set Variable     1
    FOR    ${cell_index}    IN    @{cell_list}
        ${test_lock_phase}     Set Variable      Loop_lock_${i}_${loop_num}
        uuf_rfrl_common_keywords.Get Iteration Start Time
        uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=lock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=lock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
		uuf_rfrl_common_keywords.Get Iteration End Time
		uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_lock_phase} Lock
        sleep   10s
        ${test_unlock_phase}     Set Variable      Loop_unlock_${i}_${loop_num}
        uuf_rfrl_common_keywords.Get Iteration Start Time
        uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unlock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unlock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        ${enb_state}   ${enb_error_log}=   Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
        ...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
		${test_result}    uuf_rfrl_common.Verify Iteration   ${test_unlock_phase}    ${enb_state}
		uuf_rfrl_common_keywords.Get Iteration End Time
		uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_unlock_phase} Unlock
        ${loop_num}   Convert To Integer     ${loop_num}
		${loop_num}    Evaluate     ${loop_num}+1
		Run Keyword If   '${test_result}'=='False'   Common_keywords.Collect Enb Snapshot Log    timeout=${2400}
		Run Keyword If   '${test_result}'=='False'   Fail    unlock Cell Failed - ${test_unlock_phase}
    END

Perform Block Or Unblock LTE Single Cell On Special RU with OAM KPI
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${i}   ${ru_type}=AEHC   ${cell_type}=lte    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${True}
    ${ru_type}      Set Variable If    '${tl_prefix}'=='T816'         AZHL     ${ru_type}
    ${cell_list}    Get Cell List For Special RU    cell_type=${cell_type}
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type}
    ...    ru_index=${ru_index}
    ${loop_num}     Set Variable     1
    FOR    ${cell_index}    IN    @{cell_list}
        ${test_lock_phase}     Set Variable      Loop_lock_${i}_${loop_num}
        uuf_rfrl_common_keywords.Get Iteration Start Time
        uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=block
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=block
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
		uuf_rfrl_common_keywords.Get Iteration End Time
		uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_lock_phase} block
        sleep   10s
        ${test_unlock_phase}     Set Variable      Loop_unlock_${i}_${loop_num}
        uuf_rfrl_common_keywords.Get Iteration Start Time
        uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unblock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unblock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        ${enb_state}    ${enb_error_log}=    Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
        ...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
        ${test_result}   uuf_rfrl_common.Verify Iteration     ${test_unlock_phase}   ${enb_state}
		uuf_rfrl_common_keywords.Get Iteration End Time
		uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_unlock_phase} unblock
        ${loop_num}   Convert To Integer     ${loop_num}
		${loop_num}    Evaluate     ${loop_num}+1
		Run Keyword If   '${test_result}'=='False'   Common_keywords.Collect Enb Snapshot Log    timeout=${2400}
		Run Keyword If   '${test_result}'=='False'   Fail    unblock Cell Failed - ${test_unlock_phase}
    END

Unexpect Alarm and History Alarm Should Not Exist
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM0    ${is_history_alarm_check}=${True}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${0}
    Run Keyword And Continue On Failure      Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}
    ...       connection=${connection}
    Run Keyword If    ${is_history_alarm_check}    Run Keyword And Continue On Failure
    ...    Unexpect History Alarm Should Not Exist   allowed_faults=${ALLOWED_HISTORY_FAULT}
    ...       connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}


Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM0
    Run Keyword And Continue On Failure        Verify TMO Gnb Ready And All Cell On Air
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${0}
    Run Keyword And Continue On Failure      Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}
    ...       connection=${connection}
#    Run Keyword And Continue On Failure     Unexpect History Alarm Should Not Exist   allowed_faults=@{ALLOWED_HISTORY_FAULT}
#    ...       connection=${connection}
    Check Truck Roll Alarm And Stop Robot Testing    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]
    FOR    ${enb_id}    IN RANGE    ${enb_length}
        Connect to eNB via ssl   enb_index=${enb_id}    connection=enblte_${enb_id}
        Run Keyword And Continue On Failure     Wait Until Keyword Succeeds    5 min    20 sec    Verify Enb All Cell On Air    enb_index=${enb_id}
        Connect to eNB via ssl   enb_index=${enb_id}    connection=enblte_${enb_id}
        Run Keyword And Continue On Failure
        ...   Unexpect Alarm Should Not Exist   allowed_faults=${GNB_ALLOWED_FAULT}  connection=enblte_${enb_id}
#        Run Keyword And Continue On Failure
#        ...  Unexpect History Alarm Should Not Exist  allowed_faults=@{ALLOWED_HISTORY_FAULT}   connection=enblte_${enb_id}
        Run Keyword And Ignore Error    Enblte close down    connection=enblte_${enb_id}
    END
    [Teardown]    Run Keyword And Ignore Error    Enblte close down    connection=${connection}

Delta Commissioning With NR Rat Reset Required with OAM KPI
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
     [Arguments]    ${i}
    ${test_phase}     Set Variable      Loop_${i}
    ${cur_actBeamControlImprovement1}    Get actBeamControlImprovement1 parameters in Gnb
    uuf_rfrl_common_keywords.Get Iteration Start Time
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
    Update actBeamControlImprovement1 parameters with different value in Gnb   cur_actBeamControlImprovement1=${cur_actBeamControlImprovement1}
	${gnb_state_diff}  ${gnb_error_log1}=  Run Keyword And Ignore Error
	...                Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
	${enb_state_diff}  ${enb_error_log1}=  Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
	...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
	uuf_rfrl_common_keywords.Get Iteration End Time
	uuf_rfrl_common_keywords.Get Iteration Start Time
	Update actBeamControlImprovement1 parameters with origin value in Gnb    cur_actBeamControlImprovement1=${cur_actBeamControlImprovement1}
	${gnb_state_ori}  ${gnb_error_log2}=  Run Keyword And Ignore Error
	...               Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
	${enb_state_ori}  ${enb_error_log2}=  Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
	...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
    ${test_result}    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
    ...       uuf_rfrl_common.Verify Iteration     ${test_phase}   ${enb_state_diff}    ${gnb_state_diff}    ${gnb_state_ori}    ${enb_state_ori}
    ...       ELSE    uuf_rfrl_common.Verify Iteration    ${test_phase}   ${gnb_state_diff}     ${gnb_state_ori}
	uuf_rfrl_common_keywords.Get Iteration End Time
    Run Keyword If   '${test_result}'=='False'   Collect Snapshot Log in gnb and enb   timeout=${2400}
    Run Keyword If   '${test_result}'=='False'   Fail    Commissioning With Site Reset Failed - ${test_phase}

Get actBeamControlImprovement1 parameters in Gnb
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]        ${connection}=GNB_OAM    ${MRBTS_id}=${tl.gnbs[0].instance_id}    ${nr_bts_id}=${tl.gnbs[0].global_bts_id}    ${timeout}=120
    Set Test Variable    ${gnb_dist_name}    MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}
    Connect to gnb coam via ssl    connection=GNB_OAM
    ${cur_actBeamControlImprovement1_value}    coam_parameter.get_single_value_from_scf_file    parameter=actBeamControlImprovement1
    ...                                 dist_name=${gnb_dist_name}    connection=GNB_OAM     timeout=${timeout}
    [Return]    ${cur_actBeamControlImprovement1_value}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Update actBeamControlImprovement1 parameters with origin value in Gnb
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]       ${cur_actBeamControlImprovement1}        ${connection}=GNB_OAM     ${timeout}=600
    @{params_for_update}   create list
    ${param}    Create Dictionary    dist_name=${gnb_dist_name}    parameter=actBeamControlImprovement1   value=${cur_actBeamControlImprovement1}
    Append To List    ${params_for_update}    ${param}
    Connect to gnb coam via ssl    connection=GNB_OAM
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Update actBeamControlImprovement1 parameters with different value in Gnb
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]       ${cur_actBeamControlImprovement1}    ${actBeamControlImprovement1}=false    ${connection}=GNB_OAM     ${timeout}=600
    ${modify_actBeamControlImprovement1}     set variable if   '${cur_actBeamControlImprovement1}'=='${actBeamControlImprovement1}'
    ...                              true    ${actBeamControlImprovement1}
    @{params_for_update}   create list
    ${param}    Create Dictionary    dist_name=${gnb_dist_name}    parameter=actBeamControlImprovement1    value=${modify_actBeamControlImprovement1}
    Append To List    ${params_for_update}    ${param}
    Connect to gnb coam via ssl    connection=GNB_OAM
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections


Delta Commissioning With Online Parameter Modification with OAM KPI
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
     [Arguments]    ${i}    ${cell_idx}=${PCELL_INDEX}    ${exp_status}=notBarred    ${connection}=GNB_OAM    ${gnb_index}=0    ${timeout}=${600}
    ${test_phase}     Set Variable      Loop_${i}
    ${dist_name}    set variable    MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${cell_idx}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${cell_status}    coam_parameter.get_single_value_from_scf_file    parameter=cellBarred    dist_name=${dist_name}
    ...                                                               connection=${connection}      timeout=${timeout}
    ${exp_status}    Set Variable If    '${cell_status}'=='barred'    notBarred     barred
    ${params}    create dictionary    dist_name=${dist_name}    parameter=cellBarred    value=${exp_status}
    @{params_for_update}    create list
    Append to list      ${params_for_update}     ${params}
    uuf_rfrl_common_keywords.Get Iteration Start Time
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}    timeout=${timeout}
    ...    connection=${connection}
    ${gnb_state}  ${gnb_error_log}=   Run Keyword And Ignore Error     Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
    uuf_rfrl_common_keywords.Get Iteration End Time
	${test_result}    uuf_rfrl_common.Verify Iteration   ${test_phase}    ${gnb_state}
    Run Keyword If   '${test_result}'=='False'   Common_keywords.Collect Snapshot Log    timeout=${2400}
    Run Keyword If   '${test_result}'=='False'   Fail    Commissioning With online Failed - ${test_phase}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Delta Commissioning With GSM Rat Reset Required with OAM KPI
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${i}
    ${test_phase}     Set Variable      Loop_${i}
    ${cur_perTrxPower_value}    Get perTrxPower parameters in GSM cell
    uuf_rfrl_common_keywords.Get Iteration Start Time
    Update perTrxPower parameters with different value     cur_perTrxPower=${cur_perTrxPower_value}
	${gnb_state_diff}  ${gnb_log_diff}=  Run Keyword And Ignore Error
	...                Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
	${enb_state_diff}  ${enb_log_diff}=  Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
	...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
	uuf_rfrl_common_keywords.Get Iteration End Time
	uuf_rfrl_common_keywords.Get Iteration Start Time
	Update perTrxPower parameters with origin value    cur_perTrxPower=${cur_perTrxPower_value}
    ${gnb_state_origin}  ${gnb_error_origin}=  Run Keyword And Ignore Error
    ...                Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
	${enb_state_origin}  ${enb_error_origin}=  Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
	...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
	uuf_rfrl_common_keywords.Get Iteration End Time
	${test_result}    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
    ...     uuf_rfrl_common.Verify Iteration    ${test_phase}   ${gnb_state_diff}    ${gnb_state_origin}    ${enb_state_diff}   ${enb_state_origin}
    ...     ELSE    uuf_rfrl_common.Verify Iteration    ${test_phase}   ${gnb_state_diff}     ${gnb_state_origin}
    Run Keyword If   '${test_result}'=='False'   Collect Snapshot Log in gnb and enb   timeout=${2400}
    Run Keyword If   '${test_result}'=='False'   Fail    Commissioning With GSM Reset Failed - ${test_phase}

Get perTrxPower parameters in GSM cell
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]        ${connection}=GNB_OAM      ${MRBTS_id}=${tl.gnbs[0].instance_id}     ${timeout}=120
    ${gsm_case_params}    Set Variable    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']}
    Set Test Variable    ${GSM_cell_INDEX}    ${gsm_case_params.get('gsm_cell_idx')}
    Set Test Variable    ${GSM_bts_INDEX}    ${gsm_case_params.get('gsm_bts_id')}
    Set Test Variable    ${GSM_bcf_INDEX}    ${gsm_case_params.get('gsm_bcf_id')}
    Set Test Variable    ${gsm_dist_name}    MRBTS-${MRBTS_id}/GNBTS-${GSM_bts_INDEX}/GNBCF-${GSM_bcf_INDEX}/GNCEL-${GSM_cell_INDEX}
    Connect to gnb coam via ssl    connection=GNB_OAM
    ${cur_perTrxPower_value}    coam_parameter.get_single_value_from_scf_file    parameter=perTrxPower
    ...                                 dist_name=${gsm_dist_name}    connection=GNB_OAM     timeout=${timeout}
    [Return]    ${cur_perTrxPower_value}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Update perTrxPower parameters with origin value
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]       ${cur_perTrxPower}        ${connection}=GNB_OAM     ${timeout}=600
    @{params_for_update}   create list
    ${param}    Create Dictionary    dist_name=${gsm_dist_name}    parameter=perTrxPower    value=${cur_perTrxPower}
    Append To List    ${params_for_update}    ${param}
    Connect to gnb coam via ssl    connection=GNB_OAM
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Update perTrxPower parameters with different value
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]       ${cur_perTrxPower}    ${perTrxPower}=393     ${connection}=GNB_OAM     ${timeout}=600
    ${modify_perTrxPower}     set variable if   '${cur_perTrxPower}'=='${perTrxPower}'      391      ${perTrxPower}
    @{params_for_update}   create list
    ${param}    Create Dictionary    dist_name=${gsm_dist_name}    parameter=perTrxPower    value=${modify_perTrxPower}
    Append To List    ${params_for_update}    ${param}
    Connect to gnb coam via ssl    connection=GNB_OAM
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Delta Commissioning With LTE Rat Reset Required with OAM KPI
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${i}
    ${test_phase}     Set Variable      Loop_${i}
    ${cur_actTransportSeparationLte_value}    Get actTransportSeparationLte parameters in LTE
    uuf_rfrl_common_keywords.Get Iteration Start Time
    Update actTransportSeparationLte parameters with different value in LTE    cur_actTransportSeparationLte=${cur_actTransportSeparationLte_value}
	${gnb_state}  ${gnb_error_log}=  Run Keyword And Ignore Error
	...                Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
	${enb_state}  ${enb_error_log}=  Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
	...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
	uuf_rfrl_common_keywords.Get Iteration End Time
	uuf_rfrl_common_keywords.Get Iteration Start Time
	Update actTransportSeparationLte parameters with origin value in LTE  cur_actTransportSeparationLte=${cur_actTransportSeparationLte_value}
    ${gnb_state}  ${gnb_error_log}=  Run Keyword And Ignore Error
    ...           Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
	${enb_state}  ${enb_error_log}=  Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
	...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
	uuf_rfrl_common_keywords.Get Iteration End Time
	${test_result}    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
    ...               uuf_rfrl_common.Verify Iteration     ${test_phase}   ${enb_state}    ${gnb_state}
    ...               ELSE    uuf_rfrl_common.Verify Iteration    ${test_phase}   ${gnb_state}

    Run Keyword If   '${test_result}'=='False'   Collect Snapshot Log in gnb and enb   timeout=${2400}
    Run Keyword If   '${test_result}'=='False'   Fail    Commissioning With Site Reset Failed - ${test_phase}

Get actTransportSeparationLte parameters in LTE
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]        ${connection}=GNB_OAM      ${MRBTS_id}=${tl.gnbs[0].instance_id}    ${timeout}=120
    ${LTE_case_params}    Set Variable    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']}
    Set Test Variable    ${LTE_bts_INDEX}    ${LTE_case_params.get('LTE_bts_id')}
    Set Test Variable    ${LTE_dist_name}    MRBTS-${MRBTS_id}/LNBTS-${LTE_bts_INDEX}
    Connect to gnb coam via ssl    connection=GNB_OAM
    ${cur_actTransportSeparationLte_value}    coam_parameter.get_single_value_from_scf_file    parameter=actTransportSeparationLte
    ...                                     dist_name=${LTE_dist_name}    connection=GNB_OAM    timeout=${timeout}
    [Return]    ${cur_actTransportSeparationLte_value}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Update actTransportSeparationLte parameters with origin value in LTE
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]       ${cur_actTransportSeparationLte}        ${connection}=GNB_OAM     ${timeout}=600
    @{params_for_update}   create list
    ${param}    Create Dictionary    dist_name=${LTE_dist_name}    parameter=actTransportSeparationLte    value=${cur_actTransportSeparationLte}
    Append To List    ${params_for_update}    ${param}
    Connect to gnb coam via ssl    connection=GNB_OAM
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Update actTransportSeparationLte parameters with different value in LTE
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]       ${cur_actTransportSeparationLte}    ${actTransportSeparationLte}=true     ${connection}=GNB_OAM     ${timeout}=600
    ${modify_actTransportSeparationLte}     set variable if   '${cur_actTransportSeparationLte}'=='${actTransportSeparationLte}'    fasle    true
    @{params_for_update}   create list
    ${param}    Create Dictionary    dist_name=${LTE_dist_name}    parameter=actTransportSeparationLte    value=${modify_actTransportSeparationLte}
    Append To List    ${params_for_update}    ${param}
    Connect to gnb coam via ssl    connection=GNB_OAM
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Delta Commissioning With Site Reset Required with OAM KPI
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${i}
    ${test_phase}     Set Variable      Loop_${i}
#    ${cur_tuningProfile_value}    Get tuningProfile parameters in Gnb
    ${cur_totalDelayFromSHM_value}    Get totalDelayFromSHM parameter in Gnb
    uuf_rfrl_common_keywords.Get Iteration Start Time
    Update totalDelayFromSHM parameter with different value in Gnb    cur_totalDelayFromSHM_value=${cur_totalDelayFromSHM_value}
#    Update tuningProfile parameters with different value in Gnb     cur_tuningProfile=${cur_tuningProfile_value}
	${gnb_state}  ${gnb_error_log}=  Run Keyword And Ignore Error
	...                Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
	${enb_state}  ${enb_error_log}=  Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
	...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
	uuf_rfrl_common_keywords.Get Iteration End Time
	uuf_rfrl_common_keywords.Get Iteration Start Time
#	Update tuningProfile parameters with origin value in Gnb     cur_tuningProfile=${cur_tuningProfile_value}
	Update totalDelayFromSHM parameter with origin value in Gnb    cur_totalDelayFromSHM_value=${cur_totalDelayFromSHM_value}
    ${gnb_state}  ${gnb_error_log}=  Run Keyword And Ignore Error
    ...                Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
	${enb_state}  ${enb_error_log}=  Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
	...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
	uuf_rfrl_common_keywords.Get Iteration End Time
	${test_result}    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
    ...               uuf_rfrl_common.Verify Iteration     ${test_phase}   ${enb_state}    ${gnb_state}
    ...               ELSE    uuf_rfrl_common.Verify Iteration    ${test_phase}   ${gnb_state}
    Run Keyword If   '${test_result}'=='False'   Collect Snapshot Log in gnb and enb   timeout=${2400}
    Run Keyword If   '${test_result}'=='False'   Fail    Commissioning With Site Reset Failed - ${test_phase}

Get tuningProfile parameters in Gnb
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]        ${connection}=GNB_OAM      ${MRBTS_id}=${tl.gnbs[0].instance_id}   ${nr_bts_id}=${tl.gnbs[0].global_bts_id}    ${timeout}=120
    Set Test Variable    ${gnb_dist_name}    MRBTS-${MRBTS_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
    Connect to gnb coam via ssl    connection=GNB_OAM
    ${cur_tuningProfile_value}    coam_parameter.get_single_value_from_scf_file    parameter=tuningProfile
    ...                                dist_name=${gnb_dist_name}    connection=GNB_OAM     timeout=${timeout}
    [Return]    ${cur_tuningProfile_value}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Update tuningProfile parameters with origin value in Gnb
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]       ${cur_tuningProfile}        ${connection}=GNB_OAM     ${timeout}=600
    @{params_for_update}   create list
    ${param}    Create Dictionary    dist_name=${gnb_dist_name}    parameter=tuningProfile    value=${cur_tuningProfile}
    Append To List    ${params_for_update}    ${param}
    Connect to gnb coam via ssl    connection=GNB_OAM
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Update tuningProfile parameters with different value in Gnb
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]       ${cur_tuningProfile}    ${tuningProfile}=Normal    ${connection}=GNB_OAM     ${timeout}=600
    ${modify_tuningProfile}     set variable if   '${cur_tuningProfile}'=='${tuningProfile}'   Custom    ${tuningProfile}
    @{params_for_update}   create list
    ${param}    Create Dictionary    dist_name=${gnb_dist_name}    parameter=tuningProfile    value=${modify_tuningProfile}
    Append To List    ${params_for_update}    ${param}
    Connect to gnb coam via ssl    connection=GNB_OAM
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Get totalDelayFromSHM parameter in Gnb
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]        ${connection}=GNB_OAM    ${MRBTS_id}=${tl.gnbs[0].instance_id}    ${timeout}=120
    Set Test Variable    ${gnb_dist_name}    MRBTS-${MRBTS_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    Wait until keyword succeeds    2min    20 sec    Connect to gnb coam via ssl    connection=GNB_OAM
    ${cur_totalDelayFromSHM_value}    coam_parameter.get_single_value_from_scf_file    parameter=totalDelayFromSHM
    ...                                                                                dist_name=${gnb_dist_name}
    ...                                                                                connection=GNB_OAM
    ...                                                                                timeout=${timeout}
    [Return]    ${cur_totalDelayFromSHM_value}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Update totalDelayFromSHM parameter with different value in Gnb
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]       ${cur_totalDelayFromSHM_value}    ${totalDelayFromSHM_value}=200    ${connection}=GNB_OAM    ${timeout}=600
    ${cur_totalDelayFromSHM_value_type}    Evaluate    type(${cur_totalDelayFromSHM_value}).__name__
    ${convert_cur_totalDelayFromSHM_value}    Create List    ${cur_totalDelayFromSHM_value}
    ${cur_totalDelayFromSHM_value_list}    Set Variable If    'list' in '${cur_totalDelayFromSHM_value_type}'
    ...    ${cur_totalDelayFromSHM_value}    ${convert_cur_totalDelayFromSHM_value}
    ${value_length}    Get Length    ${cur_totalDelayFromSHM_value}
    ${modify_totalDelayFromSHM}    Set Variable If
    ...    ${value_length}==${0}    ${totalDelayFromSHM_value}
    ...    ${value_length}!=${0} and '${cur_totalDelayFromSHM_value[0]}'=='${totalDelayFromSHM_value}'    210
    ...    ${totalDelayFromSHM_value}
    ${param}    Create Dictionary    dist_name=${gnb_dist_name}    parameter=totalDelayFromSHM    value=${modify_totalDelayFromSHM}
    ${params_for_update}    Evaluate    [${param}]
    Wait until keyword succeeds    2min    20 sec    Connect to gnb coam via ssl    connection=GNB_OAM
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Update totalDelayFromSHM parameter with origin value in Gnb
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]       ${cur_totalDelayFromSHM_value}    ${connection}=GNB_OAM    ${timeout}=600
    ${cur_totalDelayFromSHM_value_type}    Evaluate    type(${cur_totalDelayFromSHM_value}).__name__
    ${convert_cur_totalDelayFromSHM_value}    Create List    ${cur_totalDelayFromSHM_value}
    ${cur_totalDelayFromSHM_value_list}    Set Variable If    'list' in '${cur_totalDelayFromSHM_value_type}'
    ...    ${cur_totalDelayFromSHM_value}    ${convert_cur_totalDelayFromSHM_value}
    ${value_length}    Get Length    ${cur_totalDelayFromSHM_value}
    ${param}    Run Keyword If    ${value_length}==${0}    Create Dictionary    dist_name=${gnb_dist_name}
    ...                                                                         parameter=totalDelayFromSHM
    ...    ELSE IF    ${value_length}!=${0}    Create Dictionary    dist_name=${gnb_dist_name}
    ...    parameter=totalDelayFromSHM    value=${cur_totalDelayFromSHM_value[0]}
    ${params_for_update}    Evaluate    [${param}]
    Wait until keyword succeeds    2min    20 sec    Connect to gnb coam via ssl    connection=GNB_OAM
    Run Keyword If    ${value_length}!=${0}    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                                                                       timeout=${timeout}
    ...                                                                                       connection=${connection}
    ...    ELSE    COAM delete parameters via rest api    parameters_to_delete_via_api=${params_for_update}
    ...                                                   timeout=${timeout}
    ...                                                   connection=${connection}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Collect Snapshot Log in gnb and enb
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${gnb_index}=${0}    ${connection}=GNB_OAM    ${log_path}=${TS_CASE_LOG_PATH}     ${timeout}=${1200}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}
    ...                                                                             gnb_index=${gnb_index}
    ${snapshot_file_path}    COAM Save snapshot via rest api    connection=${connection}
    ...                                                         log_path=${log_path}
    ...                                                         timeout=${timeout}
    FOR    ${enb_id}    IN RANGE    ${enb_length}
        Wait Until Keyword Succeeds    1 min    5 sec   Connect to eNB via ssl   enb_index=${enb_id}    connection=enblte_${enb_id}
        ${snapshot_file_path}    COAM Save snapshot via rest api    connection=enblte_${enb_id}
        ...                                                         log_path=${log_path}
        ...                                                         timeout=${timeout}
        Run Keyword And Ignore Error    Enblte close down    connection=${connection}
    END
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

SW_Upgrade_Rollback_with_OAM_KPI
    [Documentation]    Auther:xiangsheng.chu@nokia-sbell.com
    [Arguments]     ${connection}=GNB_OAM
    ...          ${gnb_index}=0
    ...          ${test_iteration}=2
#    ...          ${custom_alarms}=@{EMPTY}
    ...          ${remote_vm_ip}=${None}
    ...          ${remote_mplane}=${None}
    ...          ${label}=${None}
    ...          ${hostname}=${None}
    ...          ${critical_faults}=@{EMPTY}
    ...          ${should_be_reported}=${True}
    ...          ${report_sw}=${None}
    ...          ${customers_list}=${customers}
#    ...          ${5g_source_sw}=${None}
#    ...          ${5g_target_sw}=${None}
#    ...          ${5g_target_sw_path}=${None}
    ...          ${4g_source_sw}=${None}
    ...          ${4g_target_sw}=${None}
    ...          ${4g_target_sw_path}=${None}
    ...          ${use_test_packages}=${False}
    ...          ${use_builds_storage}=${False}
    ...          ${restore_to_target_sw}=${False}
    ...          ${remote_node_update}=${False}
    ...          ${use_remote_node}=${True}
    ...          ${download_path}=${None}
    ...          ${local_node_attach_test_keyword}=${None}
    ...          ${remote_node_attach_test_keyword}=${None}
    ...          ${perform_uboot_downgrade}=${False}
    ...          ${disable_syslog_check}=${False}
    ...          ${user_suspicious_prints}=@{EMPTY}
    ...          ${report_comment}=${None}
    ...          ${qc_domain}=MN_RAN
    ...          ${qc_project}=RAN_VRF
    ...          ${qc_id}=664023
    ${custom_alarms}      Create List     ${4203}   ${4459}    ${8000}    ${1932}   ${1933}    ${1934}    ${61631}    ${4293}
    Set Test Variable       ${custom_alarms}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
	${gnb_current_version}    coam.get_sw_version    timeout=60    connection=${connection}
    ${new_sw_version}   Evaluate    "_".join(["SBTS00", "${gnb_current_version.split("_", 1)[1]}"])
    ${is_trunk}    Run Keyword And Return Status    Should Contain Any    ${gnb_current_version}    9999    9990
    ${gnb_current_version}    Set Variable If    ${is_trunk}    ${new_sw_version}    ${gnb_current_version}
	Set Test Variable    ${5g_source_sw}        ${gnb_current_version}
    Set Test Variable    ${5g_target_sw_path}    /home/ute/${package_version_1525-CA}_release_BTSSM_downloadable_A54.zip
    Set Test Variable    ${5g_target_sw}        ${package_version_1525-CA}
    Download SW Build from artifactory
    Run keyword and ignore error    COAM Teardown gnb connections
    uuf_rfrl_common_keywords.Common Test Setup   ${custom_alarms}  ${remote_vm_ip}  ${label}  ${hostname}
    ...  ${critical_faults}  ${should_be_reported}  ${customers_list}  ${remote_mplane}  ${use_remote_node}
    ...  ${disable_syslog_check}  ${user_suspicious_prints}  ${report_comment}  ${qc_domain}  ${qc_project}  ${qc_id}
    uuf_rfrl_common_keywords.Update Rollback Test Setup  ${5g_source_sw}  ${5g_target_sw}  ${5g_target_sw_path}
    ...  ${4g_source_sw}  ${4g_target_sw}  ${4g_target_sw_path}  ${use_builds_storage}  ${remote_node_update}
    ...  ${download_path}  ${use_test_packages}  ${perform_uboot_downgrade}  ${report_sw}
    Attach Test Setup   ${local_node_attach_test_keyword}  ${remote_node_attach_test_keyword}
    uuf_rfrl_common_keywords.Verify Test In Loop  ${test_iteration}
    ...  ${should_be_reported}  uuf_rfrl_common_keywords.Upgrade Test
    [Teardown]  Run Keywords  Run Keyword If  ${restore_to_target_sw}  uuf_rfrl_common_keywords.Restore To Target SW
    ...  AND  Run Keyword And Ignore Error  admin.Teardown All Aliases For Admin  AND
    ...  Run Keyword If  ${MUMIN}  uuf_rfrl_common.Mumin Teardown  AND
    ...  uuf_rfrl_common.Log Update Results

Local_node_attach_test_keyword
    [Documentation]    Auther:xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${cell_used_in_test}=${False}   ${remote}=${False}
#    COAM Create log directory
    Common_setup_and_teardown.Create Case Log Path
    ${aehc_nr_cell_list}    Get Cell List For Special RU    cell_type=nr   whether_get_first_ru_only=True
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    Set Test Variable    ${ue_index}    ${0}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    Multi-UE_Case_Setup    ue_index=${ue_index}
    ${ue_type1}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    Procedures.Verify CA Basic L3 Call    ue_index=${ue_index}
    ...                                   ue_type=${ue_type1}
    ...                                   ul_throughput=250M
    ...                                   dl_throughput=2000MKbits/sec
    ...                                   whether_need_ue_log=${False}
    ...                                   notbarred_cell_index=${PCELL_INDEX_0}
    ...                                   b1_select_cell_index=${PCELL_INDEX_0}
    ...                                   expect_addition_scell_indexs=${SCELL_INDEX_LIST_0}
    ...                                   start_keep_on_duration=1200
    ...                                   whether_do_ue_prepare=${True}
    ...                                   ignore_time=1min
    ...                                   tput_collect_duration=120
    ...                                   pcell_mapping=${PCELL_MAPPING_0}
    ...                                   scell_mapping=${SCELL_MAPPING_0}
    ...                                   target_DL_avg_percent=0.1
    ...                                   target_UL_avg_percent=0.1
    ...                                   min_DL_percent=0.1
    ...                                   min_UL_percent=0.1
    ...                                   list_cell_ids=${None}
    ...                                   check_scell_tput=${False}
    ...                                   enb_index=${fdd_enb_index}
    [Teardown]   Run Keywords
    ...    run keyword and ignore error    Procedures.Stop TMO L3 Call And Detach    ue_index=${ue_index}    ue_type=${ue_type}    AND
    ...    Teardown GNB and ENB Connections

Perform Block Or Unblock GSM Single Cell On Special RU with OAM KPI
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${i}   ${ru_type}=AHFII   ${cell_type}=gsm    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${True}
    ${ru_type}      Set Variable If    '${tl_prefix}'=='T816'        AHFIG
    ...                                '${tl_prefix}'=='T073'       AHFIB     ${ru_type}
    ${cell_list}    Get GSM Cell List For Special RU    cell_type=${cell_type}
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type}
    ...    ru_index=${ru_index}
    ${loop_num}     Set Variable     1
    FOR    ${cell_index}    IN    @{cell_list}
        ${test_lock_phase}     Set Variable      Loop_lock_${i}_${loop_num}
        uuf_rfrl_common_keywords.Get Iteration Start Time
        uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=block
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=block
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
		uuf_rfrl_common_keywords.Get Iteration End Time
		uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_lock_phase} block
        sleep   10s
        ${test_unlock_phase}     Set Variable      Loop_unlock_${i}_${loop_num}
        uuf_rfrl_common_keywords.Get Iteration Start Time
        uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unblock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unblock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        ${enb_state}    ${enb_error_log}=    Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
        ...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
        ${test_result}   uuf_rfrl_common.Verify Iteration     ${test_unlock_phase}   ${enb_state}
		uuf_rfrl_common_keywords.Get Iteration End Time
		uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_unlock_phase} unblock
        ${loop_num}   Convert To Integer     ${loop_num}
		${loop_num}    Evaluate     ${loop_num}+1
		Run Keyword If   '${test_result}'=='False'   Common_keywords.Collect Enb Snapshot Log    timeout=${2400}
		Run Keyword If   '${test_result}'=='False'   Fail    unblock Cell Failed - ${test_unlock_phase}
    END

Get GSM Cell List For Special RU
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    ...                :param ${cell_type}: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    ...                :param ${ru_type}:value like: "AEHC"
    ...                :param ${ru_index}: 0 means first AEHC, 1 means second AEHC, etc...
    [Arguments]    ${ru_type}=AEHC    ${cell_type}=nr    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${False}
    Log to console    ${\n}----Get all ${cell_type} cells For Special RU ${ru_type}----
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${LTE_WHETHER_IN_GNB}    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'=='nr'    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'!='nr'    ${enb_connection}
    ${sn_of_first_ru}    Set Variable    ${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}].serial_number}
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    @{aehc_ru_list}    Create List
    FOR    ${ru}    IN    @{list_RUs}
        ${rmod_info}   Set variable   ${ru['id']['configuration']}
        ${rmod_index}   Set variable    ${rmod_info.split('RMOD-')[-1]}
        ${serialNumber}   Set variable    ${ru['serialNumber']}
        Run Keyword If    ${whether_get_first_ru_only}==${False} and '${ru['productName']}'=='${ru_type}'
        ...                             Append To List    ${aehc_ru_list}    ${rmod_index}
        ...    ELSE IF    ${whether_get_first_ru_only} and '${ru['productName']}'=='${ru_type}' and '${serialNumber}'=='${sn_of_first_ru}'
        ...                             Append To List    ${aehc_ru_list}    ${rmod_index}
    END
    ${aehc_ru_list}    Remove Duplicates    ${aehc_ru_list}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    @{aehc_cell_list}    Create List
    FOR    ${item}    IN    @{cell_info}
        ${rmod_info}    Get From List    ${item['carrierList']}    0
        ${rmod_id}    Get Regexp Matches    ${rmod_info['antennaLineId']['configuration']}    RMOD-(\\d+)    1
        ${cell_id}    Set variable    ${item['id']['configuration'].split('-')[-1]}
        Append To List    ${aehc_cell_list}    ${cell_id}
    END
    [Return]    ${aehc_cell_list}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}    AND
    ...    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Get mutiple nonGBR PDU IP Address From Wireshark
    [Documentation]   Auther:xiangsheng.chu@nokia-sbell.com
    ...               get pdu ip addr in message <InitialContextSetupRequest,DL NAS transport,pdu session establishment accept>
    [Arguments]    ${cpif_log_path}    ${is_multi_pdu}=${False}    ${alias}=parser    ${mode}=SA
    ${pdu_ip_message_filter}    Set Variable If     '${mode}'=='SA'    ngap.procedureCode == 29 && nas_5gs.sm.pdu_addr_inf_ipv4
    ...                                                                       s1ap.procedureCode == 19 && nas_eps.esm.pdn_ipv4
    ${pdu_ip_xpath}    Set Variable If     '${mode}'=='SA'    .//_[4]/nas_5gs.sm.pdu_addr_inf_ipv4   .//nas_eps.esm.pdn_ipv4
    ${dnn_xpath}    Set Variable If     '${mode}'=='SA'    .//nas_5gs.cmn.dnn    .//nas_eps.esm.qci
    ${pdu_ip_dnn_dict}    Create Dictionary
    ${cmd}    Set Variable    /usr/bin/tshark -r {pcap_file} -o nas-5gs.null_decipher:TRUE -Y \"${pdu_ip_message_filter}\" -T pdml
    pcap.load_pcap_file    pcap_file=${cpif_log_path}    command_template=${cmd}    alias=${alias}
    ${pdu_ip}     pcap.get_field_value_by_xpath    xpath=${pdu_ip_xpath}     pcap_parser=${alias}
    ${dnn_value}    pcap.get_field_value_by_xpath    xpath=${dnn_xpath}     pcap_parser=${alias}
    ${pdu_ip_dnn_pair}    Evaluate    list(zip(${pdu_ip},${dnn_value}))
    FOR  ${item}  IN  @{pdu_ip_dnn_pair}
      ${ip_type}    Set Variable If    '${item[-1]}'=='ims' or '${item[-1]}'=='5'    ims    data
      Set To Dictionary    ${pdu_ip_dnn_dict}     ${ip_type}    ${item[0]}
    END
    Log to console    All pdu ip address are : ${pdu_ip_dnn_dict}
    run keyword if  not ${pdu_ip_dnn_dict}    Fail    msg=fail to get ue ip from wireshark。
    [Return]    ${pdu_ip_dnn_dict}

Get KPI Report with difference RSRP in 15min
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    [Arguments]     ${spark_ue_logpath}    ${folder_index}=1   ${start_L3_call}=True    ${good}=good    ${mid}=mid    ${bad}=bad
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
	${start_L3_call}    Get time to start L3 call
	${call_start_fisrt}     ${call_end_fisrt}    Run Keyword If    ${start_L3_call}
	...                  Get KPI Report with difference RSRP and TP in 15min    logpath=${spark_ue_logpath}
	...                  logname=run_${folder_index}_1
	...                  enb_index=${fdd_enb_index}    good=${good}    mid=${mid}    bad=${bad}    whether_do_ue_prepare=True
    ${start_L3_call}    Get time to start L3 call
	${call_start_second}     ${call_end_second}    Run Keyword If    ${start_L3_call}
	...                  Get KPI Report with difference RSRP and TP in 15min    logpath=${spark_ue_logpath}
	...    logname=run_${folder_index}_2
	...    enb_index=${fdd_enb_index}    good=${good}    mid=${mid}    bad=${bad}
	${start_L3_call}    Get time to start L3 call
	${call_start_third}     ${call_end_third}    Run Keyword If    ${start_L3_call}
	...                  Get KPI Report with difference RSRP and TP in 15min    logpath=${spark_ue_logpath}
	...    logname=run_${folder_index}_3
	...    enb_index=${fdd_enb_index}    good=${good}    mid=${mid}    bad=${bad}
    Get time to start L3 call
    sleep   361s
    Run Keyword And Continue On Failure    Get KPI Report from gnb and enb    folder_index=${folder_index}
    Get start time and end time with call in 15min    call_start_fisrt=${call_start_fisrt}
    ...                             call_end_fisrt=${call_end_fisrt}
    ...                             call_start_second=${call_start_second}
    ...                             call_end_second=${call_end_second}
    ...                             call_start_third=${call_start_third}
    ...                             call_end_third=${call_end_third}
    Common_keywords.Collect Snapshot Log    log_path=${remote_log_path}


Get KPI Report with difference RSRP and TP in 15min
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${logpath}=${None}       ${logname}=${None}    ${ue_index}=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
    ...            ${ue_type}=${ue_type}    ${ue_mode}=SA
    ...            ${du_index}=0	 ${hwcheck_index}=${1} 	${power_reset}=False	${5Gstatus}=PASS     ${scell_addition_method}=A1
    ...            ${protocol}=udp    ${start_keep_on_duration}=640     ${whether_check_scell_addition}=${False}
    ...            ${whether_do_ue_prepare}=${True}
    ...            ${expect_addition_scell_indexs}=${SCELL_INDEX_LIST}   ${pcell_mapping}=${PCELL_MAPPING}
    ...            ${scell_mapping}=${SCELL_MAPPING}
    ...            ${apn_address}=${tl.core.pdns[0].apn}    ${whether_need_ue_log}=${True}     ${whether_do_lte_barred_action}=${False}
    ...            ${enb_wireshark_log_prefix}=enb_wireshark_log     ${enb_index}=${1}    ${common_unit_index}=${0}
    ...            ${sleep_interval}=5 sec      ${check_pcell_tput}=${True}    ${check_scell_tput}=${True}
    ...            ${ue_iperf_path}=/data/local/tmp/iperf    ${dl_process_num}=${2}
    ...            ${list_cell_ids}=${LTE_CELL_INDEX}      ${whether_do_lte_cell_locked}=${False}   ${min_scell_percent}=0.05
    ...            ${whether_change_fren}=${True}          ${gnb_index}=${0}
    ...            ${DL_Peak_TP}=DL_Peak_TP      ${UL_Peak_TP}=UL_Peak_TP    ${DL_mid_TP}=DL_mid_TP        ${UL_mid_TP}=UL_mid_TP
    ...            ${DL_bad_TP}=DL_bad_TP        ${UL_bad_TP}=UL_bad_TP
    ...            ${b1_select_cell_index}=${PCELL_INDEX}
    ...            ${notbarred_cell_index}=${PCELL_INDEX}
    ...            ${wireshark_log_prefix}=cpif_attach
    ...            ${coam_connection}=GNB_OAM
    ...            ${asik_connection_alias}=ASIK Master
    ...            ${common_unit_index}=${0}
    ...            ${hwcheck_index}=${1}
    ...            ${detach_request}=${true}
    ...            ${power_reset}=False
    ...            ${4G_check}=True      ${get_spark_license}=${false}
    ...            ${buffer_size}=1400B    ${appserver}=APPserver        ${buffer_size_ul}=2048
    ...            ${process_num}=${2}    ${seg_size}=${1372}    ${window}=2M      ${ul_process_num}=${1}
    ...            ${good}=good    ${mid}=mid    ${bad}=bad      ${UTC_timezone}=${False}
#    ${whether_do_ue_prepare}     Set Variable If   '${tl_prefix}'=='T284'    True     False
    ${get_spark_license}     Set Variable If   '${tl_prefix}'!='T284'    True     False
    # prepare ue
    ${power_reset}    Set Variable If    'spark' in '${ue_type}'    true    ${power_reset}
    Run Keyword If    ${whether_do_ue_prepare}    Run Keyword And Continue On Failure    Procedures.Start UE Prepare
    ...    ue_index=${ue_index}    ue_type=${ue_type}      get_spark_license=${get_spark_license}
    ...   detach_request=${detach_request}      power_reset=${power_reset}
    Run Keyword If    ${whether_need_ue_log} and '${ue_type}'=='huawei_sigspark'    Run Keyword And Continue On Failure
    ...    Spark_common_keywords.Spark Start special UE Log    ue_index=${ue_index}    logpath=${logpath}    logname=${logname}
#    Run Keyword If    '${tl_prefix}'=='T080' and ${whether_do_ue_prepare}    Lock UE band n41 in X75
#    ...                ue_index=${ue_index}
    ${4G_check}    Set Variable If    '${ue_mode}'=='NSA'    True    False
    ${call_start_time}=    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${is_multi_rat}    Check LTE Whether In Gnb    gnb_id=${gnb_index}    gnb_connection=${coam_connection}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${wireshark_log_name}    Set Variable    ${wireshark_log_prefix}_${timestamp}
    ${enb_wireshark_log_name}    Set Variable    ${enb_wireshark_log_prefix}_${timestamp}
    kill DL iperf port     dl_port=${tl.ues[${ue_index}].iperf_details.port}
#    Close the iperf in UE      ue_index=${ue_index}     ul_port=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    Modify Attenuation Vaule For KPI    attenuator_list=${attenuator_list}    ue_index=${ue_index}    RSPR_PA=${good}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log     tcpdump_collector_name=${wireshark_log_name}
    ...    asik_connection_alias=${asik_connection_alias}
    ...    gnb_index=${gnb_index}
    Run Keyword If    '${ue_mode}'=='NSA'
    ...    Run Keyword And Continue On Failure    Start tcpdump Log On Enb     tcpdump_collector_name=${enb_wireshark_log_name}
    ...                                                                        enb_index=${enb_index}
    ...                                                                        common_unit_index=${common_unit_index}
    ...                                                                        is_multi_rat=${is_multi_rat}
    ...                                                                        gnb_index=${gnb_index}
    Sleep    ${sleep_interval}
    Log To Console    ${\n}INFO:-- start to attach --
    ${curr_time}=    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d_%H:%M:%S
    ${timeToSleep}    Caculate timeToSleep Before Next Counters Period
    sleep     ${timeToSleep}
    ${call_attach_time}=    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${call_attach_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${5Grach_ed}    Run Keyword If    '${ue_type}'=='mtk'    MTK_common_keywords.Do UE Attach    ue_index=${ue_index}
    ...    ELSE    power_ue.UE Attach    ue_type=${ue_type}
    ...                                  ue_index=${ue_index}
    ...                                  gnb_index=${gnb_index}
    ...                                  hwcheck_index=${hwcheck_index}
    ...                                  du_index=${du_index}
    ...                                  power_reset=${power_reset}
    Sleep    30sec
    Run Keyword If     '${ue_type}'=='huawei_sigspark'
    ...                Spark_common_keywords.Start UE Attach in X65 multi UE x65   ue_index=${ue_index}
    Sleep    30sec
    ${DL_max_TP}    Set Variable    ${KPI_PA['${tl_prefix}']['${DL_Peak_TP}']}
    ${UL_max_TP}    Set Variable    ${KPI_PA['${tl_prefix}']['${UL_Peak_TP}']}
    Run Keyword If   '${tl_prefix}'=='T080'     sleep    2s
    Run Keyword If   '${tl_prefix}'=='T080'     Set test Variable    ${ue_ip_address}    172.250.164.56
    Run Keyword If   '${tl_prefix}'=='T284'     Set test Variable    ${ue_ip_address}    172.250.164.52
    Run Keyword If   '${tl_prefix}'=='T283'     Set test Variable    ${ue_ip_address}    172.250.164.26
    Run Keyword If   '${tl_prefix}'=='T813'     Set test Variable    ${ue_ip_address}    172.250.164.37
    ${dl_throughput}    Convert Dl Tput based on Process num    process_num=${process_num}    dl_throughput=${DL_max_TP}
    ${iperf_path}    Set Variable If    '${ue_type}'=='mtk' or '${ue_type}'=='samsung'    ${ue_iperf_path}    iperf
    ${cpif_attach_log_on_testPC}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=${wireshark_log_name}
    Procedures.Start TMO L3 Call    cpif_log_path=${cpif_attach_log_on_testPC}
    ...                             ue_mode=${ue_mode}
    ...                             ue_index=${ue_index}
    ...                             protocol=${protocol}
    ...                             start_keep_on_duration=${start_keep_on_duration}
    ...                             ul_throughput=${UL_max_TP}
    ...                             dl_throughput=${DL_max_TP}
    ...                             apn_address=${apn_address}
    ...                             iperf_path=${iperf_path}
    ...                             dl_process_num=${process_num}
    ...                             ue_type=${ue_type}
    sleep     120s
    Modify Attenuation Vaule For KPI    attenuator_list=${attenuator_list}    ue_index=${ue_index}    RSPR_PA=${mid}
    sleep     120s
    Modify Attenuation Vaule For KPI    attenuator_list=${attenuator_list}    ue_index=${ue_index}    RSPR_PA=${bad}
    sleep     120s
    Modify Attenuation Vaule For KPI    attenuator_list=${attenuator_list}    ue_index=${ue_index}    RSPR_PA=${mid}
    sleep     120s
    Modify Attenuation Vaule For KPI    attenuator_list=${attenuator_list}    ue_index=${ue_index}    RSPR_PA=${good}
    sleep     120s
    Run Keyword And Continue On Failure    Procedures.Stop TMO L3 Call And Detach
    ...    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
#    ${call_end_time}=    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${timeToSleep}    Caculate timeToSleep Before Next Counters Period
    Run Keyword If    ${UTC_timezone}    sleep     ${timeToSleep}
    ${call_end_time}=    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${call_end_time_UTC}=    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${enb_wireshark_log_path_on_testPC}    Run Keyword If   '${ue_mode}'=='NSA'
    ...    Run Keyword And Continue On Failure    Stop tcpdump log collection    tcpdump_collector_name=${enb_wireshark_log_name}
    ${attach_cell_index_first}    Get Attach Cell Index From Wireshark    cpif_log_path=${cpif_attach_log_on_testPC}
    ...                                                             connection=${coam_connection}
    ...                                                             gnb_index=${gnb_index}
    ...                                                             mode=${ue_mode}
    ${attach_info}    Run Keyword If    '${ue_mode}'=='NSA'
    ...            Create Dictionary    cpif_log_path=${cpif_attach_log_on_testPC}
    ...                                 attach_cell_index=${attach_cell_index_first}
    ...                                 enb_wireshark_log_path=${enb_wireshark_log_path_on_testPC}
    ...    ELSE    Create Dictionary    cpif_log_path=${cpif_attach_log_on_testPC}    attach_cell_index=${attach_cell_index_first}
    ${attach_cell_index}    Set Variable If    '${ue_mode}'=='NSA'    ${b1_select_cell_index}    ${notbarred_cell_index}
    ${Pcell_attach}    run keyword and return status    Should Be Equal As Integers    ${attach_info['attach_cell_index']}
    ...   ${attach_cell_index}
    ${L3_call_succesful}    Set Variable If   '${Pcell_attach}'=='True'    True    False
    ${call_attach_time}      Set Variable If   ${UTC_timezone}    ${call_attach_time_UTC}     ${call_attach_time}
    ${call_end_time}      Set Variable If   ${UTC_timezone}    ${call_end_time_UTC}     ${call_end_time}
    [Return]    ${L3_call_succesful}    ${call_attach_time}     ${call_end_time}
    [Teardown]    Run Keywords    Run Keyword If    ${whether_need_ue_log} and '${ue_type}'=='huawei_sigspark'
    ...    Run Keyword And Ignore Error
    ...    Spark_common_keywords.Spark Stop special UE Log    ue_index=${ue_index}   AND
    ...    Run Keyword And Ignore Error     Recover Collect Syslog On Control PC


Modify Attenuation Vaule For KPI
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${attenuator_list}    ${ue_index}=${0}  ${RSPR_PA}=${good}
    FOR    ${attenuator}    IN    @{attenuator_list}
        Run Keyword If    '${attenuator}'=='pa'    Modify PA Attenuation Vaule For KPI    ue_index=${ue_index}    RSPR_PA=${RSPR_PA}
        ...    ELSE IF    '${attenuator}'=='mcs'    Modify MCS Attenuation Vaule For KPI    ue_index=${ue_index}   RSPR_PA=${RSPR_PA}
        ...    ELSE IF    '${attenuator}'=='radiorack'    Modify Radiorack Attenuation Vaule For KPI
        ...    ue_index=${ue_index}   RSPR_PA=${RSPR_PA}
        ...    ELSE    Log To Console     ${\n}INFO: --Use the wrong attenuator type(${attenuator}), need to check TMO_Data.py--
    END

Modify PA Attenuation Vaule For KPI
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${modify_ru_id}=0    ${ue_index}=${0}    ${pa_off_value}=${None}   ${RSPR_PA}=${good}
    ${pcell_ru_index}    Set Variable    ${PCELL_MAPPING['ru_index_mapping']}
    ${attenuator_KPI}    Set Variable    ${KPI_PA['${tl_prefix}']}
    ${attenuator_id}    Get Dictionary Keys    ${${tl_prefix}_PA_VALUE_MAPPING[${ue_index}]['${pcell_ru_index}']}
    attenuator.setup_attenuator    attenuator=${tl.attenuators[${attenuator_id[0]}]}
    ${channels_num}     Get Dictionary Keys    ${KPI_PA['${tl_prefix}']['${RSPR_PA}']}
    @{ports}    Create List
    @{values}    Create List
    FOR    ${channel}    IN    @{channels_num}
        ${PA_value}    Set Variable    ${KPI_PA['${tl_prefix}']['${RSPR_PA}']['${channel}']}
        ${channel}    Convert To Integer    ${channel}
        ${value}    Evaluate    float(${PA_value})
        Append To List    ${ports}    ${channel}
        Append To List    ${values}    ${value}
    END
    Wait Until Keyword Succeeds   5min   5sec   attenuator.set_ports_attenuation   ports=${ports}   values=${values}   confirm=True
    @{new_values}    attenuator.read_ports_attenuation     ports=${ports}
    Lists Should Be Equal    ${new_values}    ${values}    msg=Attenuation set failed.
    Log To Console    \n change attenuation to ${value}


Modify Radiorack Attenuation Vaule For KPI
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${modify_ru_id}=0    ${ue_index}=${0}    ${pa_off_value}=${None}   ${RSPR_PA}=${good}
    ${pcell_ru_index}    Set Variable    ${PCELL_MAPPING['ru_index_mapping']}
    ${attenuator_KPI}    Set Variable    ${KPI_PA['${tl_prefix}']}
    ${attenuator_id}    Get Dictionary Keys    ${${tl_prefix}_PA_VALUE_MAPPING[${ue_index}]['${pcell_ru_index}']}
    ${ip_addr}    set variable     ${tl.attenuator[${attenuator_id[0]}].ip_addr}
    ${port}    set variable     ${tl.attenuator[${attenuator_id[0]}].port}
    ${vendor}    set variable    ${tl.attenuator[${attenuator_id[0]}].vendor}
    ${model}    set variable     ${tl.attenuator[${attenuator_id[0]}].model}
    @{channels}    Set Variable    ${tl.attenuator[${attenuator_id[0]}].attenuator_ports}
    ${channels_num}     Get Dictionary Keys    ${KPI_PA['${tl_prefix}']['${RSPR_PA}']}
    @{ports}    Create List
    @{values}    Create List
    FOR    ${channel}    IN    @{channels_num}
        ${PA_value}    Set Variable    ${KPI_PA['${tl_prefix}']['${RSPR_PA}']['${channel}']}
        ${channel}    Convert To Integer    ${channel}
        ${value}    Evaluate    float(${PA_value})
        Append To List    ${ports}    ${channel}
        Append To List    ${values}    ${value}
    END
    ${configured_attenuator}    attenuator.setup_attenuator
    ...    ip_addr=${ip_addr}
    ...    port=${port}
    ...    attenuation_port_numbers=${channels}
    ...    vendor=${vendor}
    ...    model=${model}
    FOR    ${port}    IN    @{ports}
        ${port}    Convert To Integer    ${port}
        ${value}    Evaluate    float(${value})
        Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    5X    5sec   attenuator.set_attenuation
        ...    port=${port}   value=${value}   attenuator_device=${configured_attenuator}    confirm=True
    END
    FOR    ${port}    IN    @{ports}
        ${new_value}    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    5X    5sec   attenuator.read_attenuation
        ...    port=${port}   attenuator_device=${configured_attenuator}
        Lists Should Be Equal    ${new_value}    ${value}    msg=Attenuation set failed
    END

Modify MCS Attenuation Vaule For KPI
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    [Arguments]     ${ue_index}=${0}    ${RSPR_PA}=${good}
    ${channels_num}     Get Dictionary Keys    ${KPI_PA['${tl_prefix}']['${RSPR_PA}']}
    ${channel_0}    Set Variable    ${channels_num[0]}
    ${att_value}    Set Variable    ${KPI_PA['${tl_prefix}']['${RSPR_PA}']['${channel_0}']}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value}
    ...                                                begin_output_port=${1}    end_output_port=${4}
    ...                                                begin_input_port=${1}    end_input_port=${64}

TMO_Common_Suite_Setup_KPI
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${whether_do_prepare_ue}=${True}
    ...            ${ue_index}=${0}    ${ute_space}=20    ${prefer_5g_nr_mode}=SA
#    ${stream_version}    gnb_classical_hangzhou.Get program version based on stream version
    ${stream_version}    Common_setup_and_teardown.Get Active SW Version Based On Stream Version
    Set Suite Variable    ${stream_version}
    # get tl_prefix, such as T813/T073
    Set Suite Variable    ${tl_prefix}    ${testline_name.split('_')[-1][-4:]}
#    ${SCOUT_TL_NAME}=  Set Variable If    '${tl_prefix}'=='T813' or '${tl_prefix}'=='T284'    ${testline_name}_5G    ${testline_name}
#    Set Suite Variable    ${SCOUT_TL_NAME}
    ${ue_index}    Set Variable     ${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Suite Variable    ${ue_type}
    # get how many UEs
    ${ue_length}    Get Length    ${tl.ues}
    Set Suite Variable    ${ue_length}
    # get how many ENBs
    ${enb_length}    Get Length    ${tl.enbs}
    Set Suite Variable    ${enb_length}
    ${dict_enb_Technology_index}    Get LTE Technology Value
    Set Suite Variable    ${DICT_ENB_TECHNOLOGY_INDEX}    ${dict_enb_Technology_index}
    ${lte_whether_in_gnb}    Check LTE Whether In Gnb
    Check And Clear TestPC Space    ute_space=${ute_space}
    Kill Adb App    ue_index=${ue_index}
    &{fault_4203}     Create Dictionary     faultId=${4203}
    &{fault_4459}     Create Dictionary     faultId=${4459}
    &{fault_8000}     Create Dictionary     faultId=${8000}
    &{fault_1932}     Create Dictionary     faultId=${1932}
    &{fault_1933}     Create Dictionary     faultId=${1933}
    &{fault_1934}     Create Dictionary     faultId=${1934}
    &{fault_61631}     Create Dictionary     faultId=${61631}
    &{fault_1838}     Create Dictionary     faultId=${1838}
    &{fault_4741}     Create Dictionary     faultId=${4741}
    &{fault_4681}     Create Dictionary     faultId=${4681}
    &{fault_4334}     Create Dictionary     faultId=${4334}
    &{fault_7311}     Create Dictionary     faultId=${7311}
    &{fault_4298}     Create Dictionary     faultId=${4298}
    &{fault_4293}     Create Dictionary     faultId=${4293}
    &{fault_1898}     Create Dictionary     faultId=${1898}
    &{fault_251}     Create Dictionary     faultId=${251}
    &{fault_4475}     Create Dictionary     faultId=${4475}
    &{fault_4476}     Create Dictionary     faultId=${4476}
    &{fault_4476}     Create Dictionary     faultId=${4476}
    &{fault_4297}     Create Dictionary     faultId=${4297}
    ${GNB_ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_4203}    ${fault_4459}   ${fault_1932}
    ...    ${fault_1934}    ${fault_4298}
    ...    ${fault_1838}     ${fault_4741}    ${fault_1933}    ${fault_4681}    ${fault_4334}    ${fault_7311}
    ...    ${fault_4293}   ${fault_1898}   ${fault_251}   ${fault_4475}   ${fault_4476}   ${fault_4297}
    Set Suite Variable    ${GNB_ALLOWED_FAULT}
    robot_common_operations.Common Suite Setup
    Suite Log Path Create
    Backup And Delete Parameter Of Swconfig File    swconfig_modify=@{delete_flag}
    Perform gNB Reset site and Wait Onair

Commission SCF with gnb version
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    ${scf_stream_version}    Common_setup_and_teardown.Get Active SW Version Based On Stream Version
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=/home/ute/SCF/${tl_prefix}_gNB_${scf_stream_version}.xml
    ...                                     connection=GNB_OAM
    ...                                     timeout=900
    ...                                     is_pdl_checking_needed=${True}
#    Run Keyword If    '${tl_prefix}'=='T284'     Connect to eNB via ssl    enb_index=0   connection=enblte_0
#    ${enb_SW_Info}=   Run Keyword If    '${tl_prefix}'=='T284'    coam.get_software_info    timeout=300    connection=enblte_0
#    ${enb_scf_version_tmp}=     Run Keyword If    '${tl_prefix}'=='T284'    Get from dictionary    ${enb_SW_Info}    Active SW version
#    ${enb_scf_version_tmp}    Split String    ${enb_scf_version_tmp}    _
#    ${enb_scf_version}    Replace String Using Regexp    string=${enb_scf_version_tmp[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
#    Run Keyword If    '${tl_prefix}'=='T284'     COAM Commission with scf file
#    ...                                     scf_file_path=/home/ute/SCF/${tl_prefix}_FDDeNB_${enb_scf_version}.xml
#    ...                                     connection=enblte_0
#    ...                                     timeout=900
#    ...                                     is_pdl_checking_needed=${True}
#    Run Keyword And Ignore Error    Enblte close down    connection=enblte_0
    Sleep    10min
    Verify TMO Gnb Ready And All Cell On Air
    Run Keyword And Continue On Failure    Verify All Enbs Cell On Air

Update Parameter to prepare L3 call
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM   ${para_value}=true     ${qRxLevMin}=-60    ${gnb_index}=0
    ...          ${ulTReassemblyIBCA}=40
    ...            ${whether_check_scell_addition}=${True}
    ...            ${whether_do_barred_action}=${True}
    ...            ${whether_check_on_air}=${True}
    ...            ${whether_do_ue_prepare}=${False}
    ...            ${ue_mode}=SA
    ...            ${whether_do_lte_cell_locked}=${False}
    ...            ${b1_select_cell_index}=${PCELL_INDEX}
    ...            ${notbarred_cell_index}=${PCELL_INDEX}
    ...            ${exp_status}=notBarred
    ...            ${lte_exp_status}=notBarred
    ...            ${whether_do_lte_barred_action}=${False}
    ...            ${enb_index}=${1}
    ...            ${whether_change_fren}=${True}
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    ${modify_param}    Create List
	&{actRedirect_param}    Create Dictionary    dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}
	...                                                      parameter=actRedirect    value=${para_value}
	Append To List    ${modify_param}    ${actRedirect_param}
	&{actNormVCFallback_param}    Create Dictionary    dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}
	...                                                      parameter=actNormVCFallback    value=${para_value}
	Append To List    ${modify_param}    ${actNormVCFallback_param}
    &{qRxLevMin_param}    Create Dictionary    dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${PCELL_INDEX}
	...                                                      parameter=qRxLevMin    value=${qRxLevMin}
	Append To List    ${modify_param}    ${qRxLevMin_param}
	&{ulTReassemblyIBCA1_param}    Create Dictionary
	...                             dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRDRB_RLC_AM-1
	...                             parameter=ulTReassemblyIBCA    value=${ulTReassemblyIBCA}
	Append To List    ${modify_param}    ${ulTReassemblyIBCA1_param}
	&{ulTReassemblyIBCA2_param}    Create Dictionary
	...                             dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRDRB_RLC_AM-2
	...                             parameter=ulTReassemblyIBCA    value=${ulTReassemblyIBCA}
	Append To List    ${modify_param}    ${ulTReassemblyIBCA2_param}
	&{ulTReassemblyIBCA3_param}    Create Dictionary
	...								dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRDRB_RLC_AM-3
	...                             parameter=ulTReassemblyIBCA    value=${ulTReassemblyIBCA}
	Append To List    ${modify_param}    ${ulTReassemblyIBCA3_param}
    COAM Update Several Parameters Via Rest Api    parameters_to_update_via_api=${modify_param}    timeout=900
    Wait until keyword succeeds    10 min    20 sec   verify all cells should be onair
    Run Keyword If   '${ue_mode}'=='NSA'    Get RU Index Of LTE Cell    cell_index=${list_cell_ids}
    ...                                                                 gnb_id=${gnb_index}
    ...                                                                 enb_index=${enb_index}
    Run Keyword If   '${ue_mode}'=='NSA'    Modify PA Value Setting For Required RU    modify_ru_id=${NSA_PA_RU_INDEX}
    ...                                                                                ue_index=${ue_index}
    Run Keyword If   '${LTE_WHETHER_IN_GNB}'=='${False}' and '${ue_mode}'=='NSA'    Change cellBarred Parameter Value Of Lte Cells
    ...    list_cell_ids=all    exp_status=barred    enb_index=${0}
    Run Keyword If    ${whether_do_lte_barred_action}    Change cellBarred Parameter Value Of Lte Cells
    ...                                                      list_cell_ids=${list_cell_ids}
    ...                                                      exp_status=${lte_exp_status}
    ...                                                      enb_index=${enb_index}
    Run Keyword If    ${whether_do_barred_action}    Change cellBarred Parameter Value On Gnb    pcell_index=${notbarred_cell_index}
    ...                                                                                          exp_status=${exp_status}
    Run Keyword If   '${ue_mode}'=='NSA' and ${whether_change_fren}
    ...               Update Priority Of NR Frequency Band In ENDCDMEASCONF    cell_index=${b1_select_cell_index}
    Run Keyword If    ${whether_check_on_air}    Verify TMO Gnb Ready And All Cell On Air
    Run Keyword If    ${whether_do_lte_cell_locked} and '${tl_prefix}'=='T813'      Do All TDD-LTE Cells Action
    [Teardown]  run keyword and ignore error   COAM Teardown gnb connections

kill DL iperf port
    [Documentation]  xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${dl_port}     ${appserver}=APPserver
    run keyword if    '${appserver}'=='APPserver'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
    ...    ELSE IF    '${appserver}'=='APPserversim'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserversim
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}' |xargs kill -9    connection=APPserver
    [Teardown]    csn.disconnect    connection=APPserver

Close the iperf in UE
    [Documentation]  xiangsheng.chu@nokia-sbell.com
    ...              This keyword connect to android control pc and start the iperf data.
    [Arguments]    ${ue_index}    ${ul_port}     ${appserver}=APPserver
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}     ${iperf_index}=${2}
    ...    ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${ul_port}    serial_number=${serial_number}
    ...                                      iperf_index=${iperf_index}
    ...                                      cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}

start DL with static IP
    [Documentation]  xiangsheng.chu@nokia-sbell.com
    [Arguments]     ${ue_addr}    ${dl_time}    ${dl_port}    ${dl_throughput}    ${dl_length}
    ...    ${appserver}=APPserver    ${protocol}=udp    ${ue_index}=${0}    ${process_num}=${2}
    ...    ${seg_size}=${1180}    ${window}=2M
    run keyword if    '${appserver}'=='APPserver'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
    ${command}    Catenate    iperf -c ${ue_addr} -u -t ${dl_time} -i 1 -p ${dl_port} -P ${process_num} -f m -b
    ...    ${dl_throughput} -l ${dl_length} -T 64 &
    run keyword if    '${protocol}'=='udp'    csn.send command
    ...    command=${command}
    ...    connection=APPserver
    sleep    1s
    Check the iperf progress exist    connection=APPserver    port=${dl_port}
    [Teardown]    csn.disconnect    connection=APPserver

Start UL in UE
    [Documentation]     xiangsheng.chu@nokia-sbell.com
    ...                 This keyword connect to android control pc and start the iperf data.
    [Arguments]    ${ue_index}    ${ul_time}    ${ul_port}    ${ul_throughput}    ${ul_length}    ${iperf_path}=iperf
    ...    ${appserver}=APPserver    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${protocol}=udp     ${process_num}=${1}   ${iperf_index}=${2}
    ${cmd_ul_traffic}=    run keyword if    '${appserver}'=='APPserver'       catenate    adb -s ${serial_number} shell
    ...     ${iperf_path} -c ${appserver_addr} -u -t ${ul_time} -i 1 -p ${ul_port} -P 1 -f m -b ${ul_throughput} -l ${ul_length} -T 64 &
    run keyword if    '${protocol}'=='udp'    csn.send_command    command=${cmd_ul_traffic}    connection=cpc_${ue_index}
    sleep    3s
    Check the iperf progress exist    connection=cpc_${ue_index}    port=${ul_port}    ue_sn=${serial_number}
    ...   iperf_index=${iperf_index}
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

MultiUE Prepare UE
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    [Arguments]       ${ue_index}=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
    ...               ${low_RSRP}=False    ${MultiUECFGLOWRSRPTP}=MultiUECFGLOWRSRPTP
    ${RSRP_low_peak}    Set Variable If   ${low_RSRP}==True      low     good
    Modify Attenuation Vaule For KPI    attenuator_list=${attenuator_list}    ue_index=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
    ...            RSPR_PA=${RSRP_low_peak}
    log to console      "Prepare UE"
    Run Keyword If    '${tl_prefix}'=='T284'    power_ue.Prepare UE
    ...                      ue_type=sigspark_multiUE
    ...    multiue_traffic_config=${TL284CommonConfiglowRSRPlowTP["${MultiUECFGLOWRSRPTP}"]}
    ...        ELSE IF    '${tl_prefix}'=='T073'    Run Keyword And Ignore Error    power_ue.Prepare UE
    ...                      ue_type=sigspark_multiUE
    ...    multiue_traffic_config=${TL73CommonConfiglowRSRPlowTP["${MultiUECFGLOWRSRPTP}"]}
    ...        ELSE IF    '${tl_prefix}'=='T080'    power_ue.Prepare UE
    ...                      ue_type=sigspark_multiUE
    ...    multiue_traffic_config=${TL80CommonConfiglowRSRPlowTP["${MultiUECFGLOWRSRPTP}"]}

MultiUE Prepare UE For Spark
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    [Arguments]       ${ue_index}=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
    ...               ${MultiUECFGLOWRSRPTP}=MultiUECFGLOWRSRPTP
    log to console      "Prepare UE"
    Run Keyword If    '${tl_prefix}'=='T284'    power_ue.Prepare UE
    ...                      ue_type=sigspark_multiUE    multiue_traffic_config=${TL284CommonConfiglowRSRPlowTP["${MultiUECFGLOWRSRPTP}"]}
    ...        ELSE IF    '${tl_prefix}'=='T073'    power_ue.Prepare UE
    ...                      ue_type=sigspark_multiUE    multiue_traffic_config=${TL73CommonConfiglowRSRPlowTP["${MultiUECFGLOWRSRPTP}"]}
    ...        ELSE IF    '${tl_prefix}'=='T080'    power_ue.Prepare UE
    ...                      ue_type=sigspark_multiUE    multiue_traffic_config=${TL80CommonConfiglowRSRPlowTP["${MultiUECFGLOWRSRPTP}"]}

MultiUE Attach KPI without prepare UE for 8311
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    [Arguments]       ${logpath}    ${logname}       ${ue_index}=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    ...            ${start_keep_on_duration}=10    ${buffer_size}=1350B
    ...            ${appserver}=APPserver     ${protocol}=udp    ${low_RSRP}=False   ${peak_TP}=True
    ...            ${DL_400M_8311}=DL_400M_8311      ${DL_10M_8311}=DL_10M_8311
    ...            ${process_num}=${2}    ${seg_size}=${1372}    ${window}=2M      ${ul_process_num}=${1}
    Run Keyword And Continue On Failure       Spark_common_keywords.Spark Start multi UE Log    logpath=${logpath}
    ...    logname=${logname}
    log to console      "UE Attach"
    power_ue.UE Attach     ue_type=sigspark_multiUE
    ${DL_400M}    Set Variable     ${KPI_PA['${tl_prefix}']['${DL_400M_8311}']}
    ${DL_10M}    Set Variable     ${KPI_PA['${tl_prefix}']['${DL_10M_8311}']}
    Kill multiUE DL iperf port
    Start mutltiUE DL with static IP     dl_time=${start_keep_on_duration}
    ...                                  dl_throughput=${DL_400M}
    ...                                  dl_length=${buffer_size}
    ...                                  appserver=${appserver}
    ...                                  protocol=${protocol}
    ...                                  ue_index=${ue_index}
    ...                                  process_num=${process_num}
    ...                                  seg_size=${seg_size}
    ...                                  window=${window}
    sleep    30s
    Start mutltiUE DL with static IP     dl_time=${start_keep_on_duration}
    ...                                  dl_throughput=${DL_10M}
    ...                                  dl_length=${buffer_size}
    ...                                  appserver=${appserver}
    ...                                  protocol=${protocol}
    ...                                  ue_index=${ue_index}
    ...                                  process_num=${process_num}
    ...                                  seg_size=${seg_size}
    ...                                  window=${window}
    sleep    10s
    power_ue.UE Detach        ue_type=sigspark_multiUE
    Run Keyword And Ignore Error      Spark_common_keywords.Spark Stop multi UE Log

Start mutltiUE DL with static IP
    [Documentation]  xiangsheng.chu@nokia-sbell.com
    [Arguments]     ${dl_time}   ${dl_throughput}    ${dl_length}
    ...    ${appserver}=APPserver    ${protocol}=udp    ${ue_index}=${0}    ${process_num}=${2}
    ...    ${seg_size}=${1180}    ${window}=2M
    ${ue2_ip_address}    Set Variable if    '${tl_prefix}'=='T284'    172.250.164.52
    ...                                     '${tl_prefix}'=='T080'    10.64.21.89
    ...                                     '${tl_prefix}'=='T073'    172.250.164.132
    ${ue3_ip_address}    Set Variable if    '${tl_prefix}'=='T284'    172.250.164.38
    ...                                     '${tl_prefix}'=='T080'    10.64.21.81
    ...                                     '${tl_prefix}'=='T073'    172.250.164.135
    ${ue4_ip_address}    Set Variable if    '${tl_prefix}'=='T284'    172.250.164.58
    ...                                     '${tl_prefix}'=='T080'    10.64.21.109
    ...                                     '${tl_prefix}'=='T073'    172.250.164.138
    ${ue5_ip_address}    Set Variable if    '${tl_prefix}'=='T284'    172.250.164.60
    ...                                     '${tl_prefix}'=='T080'    10.64.21.105
    ...                                     '${tl_prefix}'=='T073'    172.250.164.141
    ${ue6_ip_address}    Set Variable if    '${tl_prefix}'=='T284'    172.250.164.48
    ...                                     '${tl_prefix}'=='T080'    10.64.21.101
    ...                                     '${tl_prefix}'=='T073'    172.250.164.144
    ${ue7_ip_address}    Set Variable if    '${tl_prefix}'=='T284'    172.250.164.35
    ...                                     '${tl_prefix}'=='T080'    10.64.21.97
    ...                                     '${tl_prefix}'=='T073'    172.250.164.147
    ${ue8_ip_address}    Set Variable if    '${tl_prefix}'=='T284'    172.250.164.63
    ...                                     '${tl_prefix}'=='T080'    10.64.21.93
    ...                                     '${tl_prefix}'=='T073'    172.250.164.150
    ${ue9_ip_address}    Set Variable if    '${tl_prefix}'=='T284'    172.250.164.30
    ...                                     '${tl_prefix}'=='T080'    10.64.21.85
    ...                                     '${tl_prefix}'=='T073'    172.250.164.153
    run keyword if    '${appserver}'=='APPserver'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
    ...    ELSE IF    '${appserver}'=='APPserversim'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserversim
    FOR    ${i}    IN RANGE    2    10
            ${dl_port}       Set Variable If    '${tl_prefix}'=='T284'       56${i}84
            ...                                 '${tl_prefix}'=='T080'       56${i}80
            ...                                 '${tl_prefix}'=='T073'       56${i}73
            ${ue_addr}       Set Variable       ${ue${i}_ip_address}
            ${command}    Catenate    iperf -c ${ue_addr} -u -t ${dl_time} -i 1 -p ${dl_port} -P ${process_num} -f m -b
            ...    ${dl_throughput} -l ${dl_length} -T 64 &
            run keyword if    '${protocol}'=='udp'    csn.send command
			...    command=${command}
			...    connection=APPserver
			...    ELSE IF    '${protocol}'=='tcp'    Start the tcp DL data via iperf    ue_index=${ue_index}
			...    dl_time=${dl_time}    ue_addr=${ue_addr}    dl_port=${dl_port}    process_num=${process_num}
			...    seg_size=${seg_size}
			...    window=${window}
			sleep    1s
            Run Keyword And Continue On Failure   Check the iperf progress exist    connection=APPserver    port=${dl_port}
    END
    [Teardown]    csn.disconnect    connection=APPserver

Kill multiUE DL iperf port
    [Documentation]  xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${appserver}=APPserver
    run keyword if    '${appserver}'=='APPserver'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
    ...    ELSE IF    '${appserver}'=='APPserversim'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserversim
    FOR    ${i}    IN RANGE    2    10
         ${dl_port}     Set Variable    56${i}84
         csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}' |xargs kill -9
         ...    connection=APPserver
    END
    [Teardown]    csn.disconnect    connection=APPserver

Report Result To Reporting Portal
    [Documentation]  xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${test_result}     ${qc_lab_path}    ${qc_id}    ${alias}=default
    &{links}   Create Dictionary
    ute_reporting_portal.report_to_rp    ca=${ca}
    ...                build=${package_version_1525-CA}
    ...                links=${links}
    ...                tool=Robot
    ...                result=${test_result}
    ...                qc_test_set_name=${qc_set_name}
    ...                qc_testlab_path=${qc_lab_path}
    ...                qc_domain=${qc_domain}
    ...                qc_project=${qc_project}
    ...                qc_id=${qc_id}
    ...                testline=${testline}
    ...                name=${case_name}

CA.Trigger A6 Scell Swap
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    ...               Modify the expected scell swap source and target PA,trigger the Specific scell swap
    [Arguments]    ${ue_index}=${0}
    ...            ${gnb_id}=${0}
    ...            ${rounds}=${1}
    ...            ${source_swap_pa_value}=25
    ...            ${target_swap_pa_value}=25
    ${source_swap_scell}    Set Variable    ${case_params.get('swap_scell_index').get('source_scell')}
    ${target_swap_scell}    Set Variable    ${case_params.get('swap_scell_index').get('target_scell')}
    ${source_swap_scell}   Convert To Integer    ${source_swap_scell}
    ${target_swap_scell}    Convert To Integer    ${target_swap_scell}
    ${source_swap_scell_ru_index}    Set Variable    ${SCELL_MAPPING[${source_swap_scell}]['all_cell_info']['ru_index_mapping']}
    ${target_swap_scell_ru_index}    Set Variable    ${SCELL_MAPPING[${target_swap_scell}]['all_cell_info']['ru_index_mapping']}
    ${source_swap_scell_pci}    Set Variable    ${SCELL_MAPPING[${source_swap_scell}]['all_cell_info']['physicalCellId']}
    ${target_swap_scell_pci}    Set Variable    ${SCELL_MAPPING[${target_swap_scell}]['all_cell_info']['physicalCellId']}
    Connect to Common Unit Master     alias=ASIK Master   gnb_index=${gnb_id}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
    ...    tcpdump_collector_name=ca_scell_swap_cell${source_swap_scell}_to_cell${target_swap_scell}_rounds${rounds}
    ...    asik_connection_alias=ASIK Master
    ...    gnb_index=${gnb_id}
    ...    du_index=0
    Sleep    30sec
    Modify PA Value Setting For Required RU    modify_ru_id=${target_swap_scell_ru_index}
    ...    ue_index=${ue_index}
    ...    pa_off_value=${target_swap_pa_value}
    FOR    ${round}    IN RANGE    ${rounds}
        log to console  start to trigger A6 swap for round-${round}
        Modify PA Value Setting For Required RU    modify_ru_id=${source_swap_scell_ru_index}
        ...    ue_index=${ue_index}
        ...    pa_off_value=${source_swap_pa_value}
        Sleep    8sec
        Modify PA Value Setting For Required RU    modify_ru_id=${source_swap_scell_ru_index}
        ...    ue_index=${ue_index}
        ...    pa_off_value=${None}
    END
    Sleep    40sec
    ${ca_scell_swap_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=ca_scell_swap_cell${source_swap_scell}_to_cell${target_swap_scell}_rounds${rounds}
    ...    target_dir=${TS_CASE_LOG_PATH}
    ${scell_condition_expression}    Catenate    (nr-rrc.sCellToAddModList == 1) && (f1ap.procedureCode == 12)
    ${scell_swap_mr_expression}    Catenate    (f1ap.procedureCode == 13) && (nr-rrc.measResultNeighCells == 0)
    pcap.setup    infile=${ca_scell_swap_wireshark}    display_filter=${scell_swap_mr_expression}    alias=test0
    pcap.get_packets    filter=${scell_swap_mr_expression}   pcap_parser=test0
    ${swap_scell_pci_list}    pcap.get_field_value    field_name=nr-rrc.physCellId
    ...    filter=${scell_swap_mr_expression}
    ...    pcap_parser=test0
    ${swap_scell_pci_list}    Evaluate    [x[-1] for x in ${swap_scell_pci_list}]
    pcap.setup    infile=${ca_scell_swap_wireshark}    display_filter=${scell_condition_expression}    alias=test0
    pcap.get_packets    filter=${scell_condition_expression}   pcap_parser=test0
    ${scell_addition_pci_list}    pcap.get_field_value    field_name=nr-rrc.physCellId
    ...    filter=${scell_condition_expression}
    ...    pcap_parser=test0
    ${scell_addition_pci_list}    Evaluate    [x[0] for x in ${scell_addition_pci_list}]
    ${scell_pci_invalid_filter}    Catenate    int(x)!=int(${source_swap_scell_pci}) and int(x)!=int(${target_swap_scell_pci})
    ${invalid_swap_scell_pci}    Evaluate    [x for x in ${swap_scell_pci_list} if ${scell_pci_invalid_filter}]
    ${invalid_scell_adition_pci}    Evaluate    [x for x in ${scell_addition_pci_list} if ${scell_pci_invalid_filter}]
    Run Keyword And Continue On Failure    Should Be Empty    ${invalid_swap_scell_pci}
    ...    msg=swap scell is not correct in A6 MR Measurement,invalid pci is ${invalid_swap_scell_pci}
    Run Keyword And Continue On Failure    Should Be Empty    ${invalid_scell_adition_pci}
    ...    msg=addition scell is not correct in RRC Reconfiguration,invalid pci is ${invalid_scell_adition_pci}
    Lists Should Be Equal    ${scell_addition_pci_list}    ${swap_scell_pci_list}
    ...    msg=swap scell in MR is not same as in rrc reconfiguraiton.${scell_addition_pci_list},${swap_scell_pci_list}.
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   csn.execute    command=killall tcpdump    connection=ASIK Master
    ...    AND    Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master

Start Ping Traffic
    [Arguments]   ${ue_index}=${1}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell killall ping
    ${appserver_addr}    Set Variable   ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.addr}
    csn.send_command    command=adb shell ping ${appserver_addr} &    connection=cygwin
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell ps -ef |grep ping |grep -v grep |awk '{print $2}'    connection=cygwin
    ${output}    csn.read_output    size=1000    connection=cygwin
    ${ping_pid}    evaluate    ${output.strip()}
    should be true    ${ping_pid} > ${0}    msg=ping traffic is not success.
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect      connection=cygwin

Stop Ping Traffic
    [Arguments]   ${ue_index}=${1}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell ps -ef |grep ping |grep -v grep |awk '{print $2}'    connection=cygwin
    ${output}    csn.read_output    size=1000    connection=cygwin
    ${ping_pid}    evaluate    ${output.strip()}
    should be true    ${ping_pid} > ${0}    msg=ping traffic is stopped unnormally.
    csn.send_command    command=adb -s ${serial_number} shell kill -9 ${ping_pid}    connection=cygwin
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    csn.send_command
    ...    command=adb -s ${serial_number} shell killall ping    connection=cygwin    AND
    ...    Run Keyword And Ignore Error    csn.disconnect      connection=cygwin

Clear Ping Traffic
    [Arguments]   ${ue_index}=${1}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell killall ping
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect      connection=cygwin

Start Ping Traffic For Spark
    [Arguments]   ${ue_ip}=10.64.21.89    ${ue_index}=4    ${serial_number}=${tl.ues[${ue_index}].serial_number}
#    Connect to control pc via cygwin    ue_index=${ue_index}
    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
#    csn.send_command    command=ps -ef |grep ping |grep -v grep |awk '{print $2}'    connection=cygwin
    ${output}   csn.execute   command=ps -ef |grep ping |grep -v grep |awk '{print $2}'    connection=APPserver
    ${status}    ${ping_pid_before}    Run Keyword And Ignore Error    evaluate    ${output.strip()}
    Run Keyword And Ignore Error    csn.send_command    command=kill -9 ${ping_pid_before}    connection=APPserver
#    ${appserver_addr}    Set Variable   ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.addr}
#    csn.send_command    command=ping ${appserver_addr} -S ${ue_ip} -t &    connection=cygwin
    csn.send_command    command=ping ${ue_ip} &    connection=APPserver
#    sleep   5s
#    ${output}   csn.execute   command=ps -ef |grep ping |grep -v grep |awk '{print $2}'    connection=APPserver
#    ${ping_pid}    evaluate    ${output.strip()}
#    should be true    ${ping_pid} > ${0}    msg=ping traffic is not success.
#    sleep   5s
#    ${output}   csn.execute   command=ps -ef |grep ping |grep -v grep |awk '{print $2}'    connection=APPserver
#    ${ping_pid}    evaluate    ${output.strip()}
#    should be true    ${ping_pid} > ${0}    msg=ping traffic is not success.
#    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=APPserver

Stop Ping Traffic For Spark
    [Arguments]   ${ue_index}=${4}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
#    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
    ${output}   csn.execute   command=ps -ef |grep ping |grep -v grep |awk '{print $2}'    connection=APPserver
    ${ping_pid}    evaluate    ${output.strip()}
    should be true    ${ping_pid} > ${0}    msg=ping traffic is stopped unnormally.
    csn.send_command    command=kill -9 ${ping_pid}    connection=APPserver
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=APPserver

PA Value Setting For Required RU Required gNB
    [Documentation]   stella.lin@nokia-sbell.com
    [Arguments]    ${modify_ru_id}=0    ${gnb_id}=0    ${pa_value}=${63}
    ${modify_ru_id_type}    Evaluate    type(${modify_ru_id}).__name__
    ${convert_modify_ru_id_to_list}    Create List    ${modify_ru_id}
    ${modify_ru_id_list}    Set Variable If    'list' in '${modify_ru_id_type}' or 'tuple' in '${modify_ru_id_type}'
    ...      ${modify_ru_id}    ${convert_modify_ru_id_to_list}
    FOR    ${ru_index}    IN    @{modify_ru_id_list}
        ${attenuation_ports}    Set Variable    ${tl.gnbs[${gnb_id}].dus[0].rus[${ru_index}].attenuation_ports}
        Run Keyword If    '${attenuation_ports}'!='None'    Wait Until Keyword Succeeds    5X    5sec
        ...    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU
        ...    value=${pa_value}   RU_id=${ru_index}    gnb_id=${gnb_id}
    END

Update Params Through RestApi
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    ...               param:${params_need_to_modify}, List
    [Arguments]    ${params_need_to_modify}    ${gnb_index}=0    ${connection}=GNB_OAM${gnb_index}   ${timeout}=300
    ...    ${skip_parameter_relation_errors}=False
    ...    ${is_verify_onair}=${True}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    Connect to gnb coam via ssl    bts_host=${bts_host}    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_need_to_modify}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    ...                                            skip_parameter_relation_errors=${skip_parameter_relation_errors}
    Run Keyword If    ${is_verify_onair}    Verify TMO Gnb Ready And All Cell On Air    gnb_id=${gnb_index}
    ...    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Delete Params Through RestApi
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    ...               param:${params_need_to_modify}, List
    [Arguments]    ${parameters_to_delete_via_api}    ${gnb_index}=0    ${connection}=GNB_OAM${gnb_index}    ${timeout}=300
    ...    ${is_verify_onair}=${True}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM delete parameters via rest api    parameters_to_delete_via_api=${parameters_to_delete_via_api}
    ...                                 timeout=${timeout}
    ...                                 connection=${connection}
    Run Keyword If    ${is_verify_onair}     Verify TMO Gnb Ready And All Cell On Air    gnb_id=${gnb_index}
    ...    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Add Params Through RestApi
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    ...               param:${params_need_to_modify}, List
    [Arguments]    ${parameters_to_add_via_api}    ${gnb_index}=0    ${connection}=GNB_OAM${gnb_index}   ${timeout}=300
    ...    ${is_verify_onair}=${True}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM add several parameters via rest api       parameters_to_add_via_api=${parameters_to_add_via_api}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    Run Keyword If    ${is_verify_onair}     Verify TMO Gnb Ready And All Cell On Air    gnb_id=${gnb_index}
    ...    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}


Perform gNB Reset site and Wait Onair
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${gnb_index}=0    ${connection}=GNB_OAM${gnb_index}     ${timeout}=30min
    Connect to gnb coam via ssl    connection=${connection}   gnb_index=${gnb_index}
    coam.reset_site         connection=${connection}
    sleep    30s
    Verify TMO Gnb Ready And All Cell On Air    gnb_id=${gnb_index}    connection=${connection}

HO.Check A5A3 Measurement Report
    [Arguments]    ${cpif_log_path}   ${exp_source_pci}=771    ${exp_target_pci}=772   ${rounds}=${3}
    ${filter_expression}    Catenate    nr-rrc.measResultNeighCells == 0
    pcap.setup    infile=${cpif_log_path}    display_filter=${filter_expression}    alias=test0
    pcap.get_packets    filter=${filter_expression}   pcap_parser=test0
    ${actual_pci}    pcap.get_field_value    field_name=nr-rrc.physCellId
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
#    ${ho_rounds}    Get Length    ${actual_pci}
#    Run Keyword And Continue On Failure     Should Be Equal As Integers    ${ho_rounds}    ${rounds}
#    ...   msg=handover success rounds is only ${ho_rounds}times triggered success, totally is ${rounds}times.
    ${pci_valid_filter}    Catenate    int(x[0])==int(${exp_source_pci}) and int(x[1])==int(${exp_target_pci})
    ${valid_mr_pci}    Evaluate    [x for x in ${actual_pci} if ${pci_valid_filter}]
    ${mr_vaild}    Get Length    ${valid_mr_pci}
    Run Keyword And Continue On Failure     Should Be True    ${mr_vaild}>=${rounds}
    ...   msg=A3/A5 MR is not triggered properly,actual is triggered ${mr_vaild} times.

HO.Check RRC Reconfigure And RRC Reconfigure Complete For Inter-gnb
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    [Arguments]    ${source_cpif_log_path}    ${target_cpif_log_path}    ${rounds}=${3}
#    ${filter_expression}    Catenate    ((f1ap.procedureCode == 12 )&& (nr-rrc.ssbFrequency == ${ssbfrequency})) && (nr-rrc.gapUE == 0)
    ${filter_expression}    Catenate    ((nr-rrc.reportConfigId ) && (f1ap.procedureCode == 7) && nr-rrc) && !(f1ap.C_RNTI)
    pcap.setup    infile=${source_cpif_log_path}     display_filter=${filter_expression}    alias=test0
    pcap.get_packets    filter=${filter_expression}   pcap_parser=test0
    ${rrc_transaction_identifier}    pcap.get_field_value    field_name=nr-rrc.rrc_TransactionIdentifier
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
#    ${rrc_reconfigure_rounds}    Get Length    ${rrc_transaction_identifier}
#    Run Keyword And Continue On Failure     Should Be Equal As Integers    ${rrc_reconfigure_rounds}    ${rounds}
#    ...   msg=RRC Reconfigure success only ${rrc_reconfigure_rounds}times,totally is ${rounds}times.
    ${rrc_reconfiguration_complete_success_time}    Set Variable    ${0}
    FOR   ${message}    IN    @{rrc_transaction_identifier}
        ${complete_filter_expression}    Catenate    nr-rrc.rrcReconfigurationComplete_element &&
        ...                                          nr-rrc.rrc_TransactionIdentifier==${message[0]}
        pcap.setup    infile=${target_cpif_log_path}    display_filter=${complete_filter_expression}    alias=test1
        pcap.get_packets    filter=${complete_filter_expression}   pcap_parser=test1
        ${rrc_transaction_identifier_complete}    pcap.get_field_value    field_name=nr-rrc.rrc_TransactionIdentifier
        ...    filter=${complete_filter_expression}
        ...    pcap_parser=test1
        ${status}    Run Keyword And Return Status    Should Not Be Empty    ${rrc_transaction_identifier_complete}
        ...    msg=RRC Reconfiguration Complete message not triggered success.
        ${rrc_reconfiguration_complete_success_time}    Run Keyword If    '${status}'=='${True}'    Evaluate
        ...    ${rrc_reconfiguration_complete_success_time}+1
    END
    Run Keyword And Continue On Failure    Should Be True    ${rrc_reconfiguration_complete_success_time}>=${rounds}
    ...   msg=RRC Reconfigure success only ${rrc_reconfiguration_complete_success_time}times,should be ${rounds}times.

HO.Check RRC Reestablishment
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    [Arguments]    ${cpif_log_path}
    ${filter_expression}    Catenate    nr-rrc.rrcReestablishmentRequest_element
    pcap.setup    infile=${cpif_log_path}    display_filter=${filter_expression}    alias=test0
    ${status}    Run Keyword And Return Status    pcap.get_packets    filter=${filter_expression}   pcap_parser=test0
    ${pci}    Run Keyword If    '${status}'=='${True}'     pcap.get_field_value    field_name=nr-rrc.physCellId
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
    Run Keyword If    '${status}'=='${True}'    Fail    msg=cell with pci ${pci} have RRC Reestablishment happend.

Disable 9531 Function
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    [Arguments]    ${disable_cells_list}=${${301},${311}}    ${connection}=GNB_OAM    ${gnb_index}=0
    ${disable_cells_list_type}    Evaluate    type(${disable_cells_list}).__name__
    ${convert_disable_cells_to_list}    Create List    ${disable_cells_list}
    ${disable_cells_list}    Set Variable If    'list' in '${disable_cells_list_type}' or 'tuple' in '${disable_cells_list_type}'
    ...      ${disable_cells_list}     ${convert_disable_cells_to_list}
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[0].global_bts_id}
    ${update_params}    Create List
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    FOR    ${cell_index}    IN    @{disable_cells_list}
        ${actDrxRetransTimerSupport}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
        ...    'parameter':'actDrxRetransTimerSupport','value':'false'}
#        ${drxProfile2}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
#        ...    'parameter':'drxProfile2',
#        ...    'value':[{'drxHarqRttTimerDl':'0slot','drxHarqRttTimerUl':'0slot',
#        ...    'drxHarqRttTimerDl':'0symbols','drxHarqRttTimerUl':'0symbols'}]}
        ${nonGbrNrDrxDN_mo}    get_single_value_from_scf_file    parameter=nonGbrNrDrxDN
        ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
        ...    connection=${connection}    timeout=60
        ${voNRNrDrxDN_mo}    get_single_value_from_scf_file    parameter=voNRNrDrxDN
        ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
        ...    connection=${connection}    timeout=60
        ${fiveQiDrbDrx_mo}    get_single_value_from_scf_file    parameter=nrDrxDN    list_name=fiveQiDrbDrxList
        ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
        ...    connection=${connection}    timeout=60
        ${nonGbrNrDrxDN}   catenate   {'dist_name':'${nonGbrNrDrxDN_mo}','parameter':'drxHarqRttTimerDl','value':'0symbols'},
        ...                            {'dist_name':'${nonGbrNrDrxDN_mo}','parameter':'drxHarqRttTimerUl','value':'0symbols'},
        ...                            {'dist_name':'${nonGbrNrDrxDN_mo}','parameter':'drxRetransTimerDl','value':'0slot'},
        ...                            {'dist_name':'${nonGbrNrDrxDN_mo}','parameter':'drxRetransTimerUl','value':'0slot'}
        ${voNRNrDrxDN}    Run Keyword If    '${voNRNrDrxDN_mo}'!='${None}'
        ...    catenate   {'dist_name':'${voNRNrDrxDN_mo}','parameter':'drxHarqRttTimerDl','value':'0symbols'},
        ...                            {'dist_name':'${voNRNrDrxDN_mo}','parameter':'drxHarqRttTimerUl','value':'0symbols'},
        ...                            {'dist_name':'${voNRNrDrxDN_mo}','parameter':'drxRetransTimerDl','value':'0slot'},
        ...                            {'dist_name':'${voNRNrDrxDN_mo}','parameter':'drxRetransTimerUl','value':'0slot'}
        ${fiveQiDrbDrx}    Run Keyword If    '${fiveQiDrbDrx_mo}'!='${None}'
        ...    catenate   {'dist_name':'${fiveQiDrbDrx_mo}','parameter':'drxHarqRttTimerDl','value':'0symbols'},
        ...                            {'dist_name':'${fiveQiDrbDrx_mo}','parameter':'drxHarqRttTimerUl','value':'0symbols'},
        ...                            {'dist_name':'${fiveQiDrbDrx_mo}','parameter':'drxRetransTimerDl','value':'0slot'},
        ...                            {'dist_name':'${fiveQiDrbDrx_mo}','parameter':'drxRetransTimerUl','value':'0slot'}
#        ${update_param}    Evaluate    [${actDrxRetransTimerSupport},${drxProfile2},${nonGbrNrDrxDN},${voNRNrDrxDN},${fiveQiDrbDrx}]
        ${update_param}    Run Keyword If    '${voNRNrDrxDN_mo}'=='${None}'
        ...    Evaluate    [${actDrxRetransTimerSupport},${nonGbrNrDrxDN},${fiveQiDrbDrx}]
        ...    ELSE IF    '${fiveQiDrbDrx_mo}'=='${None}'
        ...    Evaluate    [${actDrxRetransTimerSupport},${nonGbrNrDrxDN},${voNRNrDrxDN}]
        ...    ELSE
        ...    Evaluate    [${actDrxRetransTimerSupport},${nonGbrNrDrxDN},${voNRNrDrxDN},${fiveQiDrbDrx}]
        ${update_params}    Combine Lists   ${update_params}    ${update_param}
    END
    Update Params Through RestApi    params_need_to_modify=${update_params}    connection=${connection}    gnb_index=${gnb_index}

Disable 9531 Function For 24R2
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    [Arguments]    ${disable_cells_list}=${${301},${311}}    ${connection}=GNB_OAM    ${gnb_index}=0
    ${disable_cells_list_type}    Evaluate    type(${disable_cells_list}).__name__
    ${convert_disable_cells_to_list}    Create List    ${disable_cells_list}
    ${disable_cells_list}    Set Variable If    'list' in '${disable_cells_list_type}' or 'tuple' in '${disable_cells_list_type}'
    ...      ${disable_cells_list}     ${convert_disable_cells_to_list}
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[0].global_bts_id}
    ${update_params}    Create List
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    FOR    ${cell_index}    IN    @{disable_cells_list}
        ${actDrxRetransTimerSupport}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
        ...    'parameter':'actDrxRetransTimerSupport','value':'false'}
       ${drxProfile1}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
        ...    'parameter':'drxProfile1',
        ...    'value':[{'drxHarqRttTimerDl':'0symbols','drxHarqRttTimerUl':'14symbols',
        ...    'drxRetransTimerDl':'0slot','drxRetransTimerUl':'16slot'}]}
        ${drxProfile2}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
        ...    'parameter':'drxProfile2',
        ...    'value':[{'drxHarqRttTimerDl':'0symbols','drxHarqRttTimerUl':'0symbols',
        ...    'drxRetransTimerDl':'0slot','drxRetransTimerUl':'0slot'}]}
        ${update_param}    Evaluate    [${actDrxRetransTimerSupport},${drxProfile1},${drxProfile2}]
        ${update_params}    Combine Lists   ${update_params}    ${update_param}
    END
    Update Params Through RestApi    params_need_to_modify=${update_params}    connection=${connection}    gnb_index=${gnb_index}

Enable RedCap Function
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=0
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[0].global_bts_id}
    ${actRedCapUeSupport}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-301',
        ...    'parameter':'actRedCapUeSupport','value':'true'}
    ${maxNumOfRrcSARedCap}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-301',
        ...    'parameter':'maxNumOfRrcSARedCap','value':'200'}
    ${cellBarredRedCap}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-301',
    ...    'parameter':'cellBarredRedCap','value':'no barring'}
    ${update_param}    Evaluate    [${actRedCapUeSupport},${maxNumOfRrcSARedCap},${cellBarredRedCap}]
    Update Params Through RestApi    params_need_to_modify=${update_param}    connection=${connection}    gnb_index=${gnb_index}

Modify weightForSCellSelection
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    [Arguments]    ${disable_cells_list}=${${1},${2},${3},${21},${22},${23}}
    ...    ${value}=100    ${connection}=GNB_OAM    ${gnb_index}=0
    ${disable_cells_list_type}    Evaluate    type(${disable_cells_list}).__name__
    ${convert_disable_cells_to_list}    Create List    ${disable_cells_list}
    ${disable_cells_list}    Set Variable If    'list' in '${disable_cells_list_type}' or 'tuple' in '${disable_cells_list_type}'
    ...      ${disable_cells_list}     ${convert_disable_cells_to_list}
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[0].global_bts_id}
    ${update_params}    Create List
    FOR    ${cell_index}    IN    @{disable_cells_list}
        ${weightForSCellSelection}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
        ...    'parameter':'weightForSCellSelection','value':'${value}'}
        ${update_param}    Evaluate    [${weightForSCellSelection}]
        ${update_params}    Combine Lists   ${update_params}    ${update_param}
    END
    Update Params Through RestApi    params_need_to_modify=${update_params}    connection=${connection}    gnb_index=${gnb_index}

Configure Relation Cells
    [Documentation]   Author: stella.lin@nokia-sbell.com
    [Arguments]    ${source_gnb_id}=0
    Connect To Multi gNb Coam
    mbca.set_pcell_index    value=${PCELL_INDEX}
    mbca.set_gnb_id    value=${source_gnb_id}
    mbca.set_gnb_operation_object
    ${inter_gnb_ho_cell}    Set Variable    ${case_params.get('inter_gnb_ho_cell')}
    ${intra_gnb_ho_cell}    Set Variable    ${case_params.get('intra_gnb_ho_cell')}
    ${scell_indexs}    Set Variable    ${case_params.get('scell_idx_list')}
    ${swap_scell_index}    Set Variable    ${case_params.get('swap_scell_index')}
    ${swap_scell_index}    Set Variable If    ${swap_scell_index}==${None}    ${swap_scell_index}
    ...                                       ${swap_scell_index['target_scell']}
    ${res}    Catenate    {'inter_gnb_ho_cell':${inter_gnb_ho_cell}},{'intra_gnb_ho_cell':${intra_gnb_ho_cell}},
    ...                   {'scell_indexs':${scell_indexs}},{'swap_scell_index':${swap_scell_index}}
    ${relation_cells_info}    Evaluate    [${res}]
    ${source_cell_mapping}    ${target_cell_mapping}   ${scell_mapping}    config_relation_cells
    ...    relation_cells_info=${relation_cells_info}
    Set Test Variable    ${SOURCE_CELL_MAPPING}    ${source_cell_mapping}
    Set Test Variable    ${TARGET_CELL_MAPPING}    ${target_cell_mapping}
    Set Test Variable    ${PCELL_MAPPING}    ${source_cell_mapping[${PCELL_INDEX}]}
    Set Test Variable    ${SCELL_MAPPING}    ${scell_mapping}
    LOG    ${SCELL_MAPPING}
    [Teardown]    Teardown Multi gNb Connections

Update actSCellReleaseForInactiveSCell in gnb
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    ...                This keyword just for 5G cell.
    [Arguments]    ${vaule}=timer_based_Fr1    ${connection}=GNB_OAM    ${gnb_index}=0    ${timeout}=300
    ${dist_name}    Set Variable    MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}
    ${param}    Create Dictionary    dist_name=${dist_name}    parameter=actSCellReleaseForInactiveSCell    value=${vaule}
    @{param_list}    Create List    ${param}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}
    ...                                            timeout=${timeout}
    Wait Gnb Ready And Cell On Air    gnb_id=${gnb_index}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

MultiUE Attach without check TP in UE
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    [Arguments]       ${logpath}    ${logname}       ${ue_index}=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    ...            ${start_keep_on_duration}=20    ${buffer_size}=1350B
    ...            ${appserver}=APPserver     ${protocol}=udp    ${low_RSRP}=False   ${peak_TP}=True
    ...            ${DL_200M_8311}=DL_200M_8311      ${DL_10M_8311}=DL_10M_8311
    ...            ${process_num}=${2}    ${seg_size}=${1372}    ${window}=2M      ${ul_process_num}=${1}    ${save_ue_log}=True
    Run Keyword And Ignore Error    run keyword if    '${save_ue_log}'=='True'    Spark_common_keywords.Spark Start multi UE Log
    ...           logpath=${logpath}    logname=${logname}
    log to console      "UE Attach"
    power_ue.UE Attach     ue_type=sigspark_multiUE
    ${DL_200M}    Set Variable     ${KPI_PA['${tl_prefix}']['${DL_200M_8311}']}
    ${DL_10M}    Set Variable     ${KPI_PA['${tl_prefix}']['${DL_10M_8311}']}
    Kill multiUE DL iperf port
    Start mutltiUE DL with static IP     dl_time=${start_keep_on_duration}
    ...                                  dl_throughput=${DL_200M}
    ...                                  dl_length=${buffer_size}
    ...                                  appserver=${appserver}
    ...                                  protocol=${protocol}
    ...                                  ue_index=${ue_index}
    ...                                  process_num=${process_num}
    ...                                  seg_size=${seg_size}
    ...                                  window=${window}
    sleep    10s
    power_ue.UE Detach        ue_type=sigspark_multiUE
    Run Keyword And Ignore Error      Spark_common_keywords.Spark Stop multi UE Log

Save Current SCF And Save Snapshot
    [Arguments]    ${gnb_index}=${0}    ${connection}=GNB_OAM${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    Run Keyword And Ignore Error    coam_gnb_classical.COAM Download scf from cluster
    ...    scf_dir_path=${TS_CASE_LOG_PATH}    connection=${connection}
    Run Keyword And Ignore Error    COAM Save snapshot via rest api    connection=${connection}    timeout=900
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Update lssIPaddress Via RestAPI
    [Arguments]    ${value}=10.57.177.22
    ${lssIPaddress}    catenate   {'dist_name':'MRBTS-11213/MNL-1/MNLENT-1/TRBLCADM-1',
    ...    'parameter':'lssConfig','value':[{'lssIPaddress':'${value}'}]}
    ${update_param}    Evaluate    [${lssIPaddress}]
    Connect to eNB via ssl
    COAM Update several parameters via rest api    parameters_to_update_via_api=${update_param}
    ...                                            timeout=${120}
    ...                                            connection=enblte
    ...                                            skip_parameter_relation_errors=${False}
    [Teardown]    Enblte close down

UE With ADB Reboot
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.execute    command=adb -s ${tl.ues[${ue_index}].serial_number} reboot   connection=cpc_${ue_index}
    Sleep    10s
    Wait Until Keyword Succeeds    3 min    10s    Connect ADB devices    alias=cpc_${ue_index}
    ...                                                                   serial_number=${tl.ues[${ue_index}].serial_number}
    [Teardown]  Run Keyword And Ignore Error    csn.disconnect   connection=cpc_${ue_index}

Delete NRREL Objects Based On Technology
    [Arguments]    ${pcell_index}=${PCELL_INDEX}    ${gnb_index}=${0}    ${connection}=GNB_OAM${gnb_index}   ${technology}=FDD
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[${gnb_index}].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[${gnb_index}].global_bts_id}
    Get Pcell And Scell Mapping Info    pcell_index=${pcell_index}    source_gnb_id=${gnb_index}
    ${filter_scell_mapping}    Set Variable If    '${technology}'=='FDD'     ${FDD_SCELL_MAPPING}
    ...         '${technology}'=='TDD'     ${TDD_SCELL_MAPPING}
    ${dict_values}    Get Dictionary Values    ${filter_scell_mapping}
    ${NRREL_indexs}     Evaluate     [x['nrrel_id'] for x in ${dict_values}]
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${empty_list}    Create List
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    FOR    ${nrrel_index}     IN     @{NRREL_indexs}
        ${dist_name}     Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${pcell_index}/NRREL-${nrrel_index}
        coam.perform_object_recommissioning    dist_name=${dist_name}    parameter=${empty_list}    operation=delete
        ...     skip_parameter_relation_errors=False    should_activate=True    timeout=240    connection=${connection}
    END
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}


Reproduce_5605005.Start Brust DL UDP Traffic
    [Arguments]    ${ue_num}=8    ${sh_file_path}=/home/cmw_sg6/5605005
    ${app_ip}    Set Variable    ${tl.ues[${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}].iperf_details.ssh_connection_details.addr}
    ${app_user}    Set Variable    ${tl.ues[${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}].iperf_details.ssh_connection_details.username}
    ${app_pwd}    Set Variable    ${tl.ues[${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}].iperf_details.ssh_connection_details.password}
    csn.connect to    hostname=${app_ip}    username=${app_user}    password=${app_pwd}    alias=appserver
    Log To Console    start to start ue-0
    ${command_ret}    Catenate    sh ${sh_file_path}/${tl_prefix}/${tl_prefix}_SDX65_UDP_UE0.sh &
    ...    sh ${sh_file_path}/${tl_prefix}/${tl_prefix}_SDX65_UDP_UE1.sh &
    ...    sh ${sh_file_path}/${tl_prefix}/${tl_prefix}_SDX65_UDP_UE2.sh &
    ...    sh ${sh_file_path}/${tl_prefix}/${tl_prefix}_SDX65_UDP_UE3.sh &
    ...    sh ${sh_file_path}/${tl_prefix}/${tl_prefix}_SDX65_UDP_UE4.sh &
    ...    sh ${sh_file_path}/${tl_prefix}/${tl_prefix}_SDX65_UDP_UE5.sh &
    ...    sh ${sh_file_path}/${tl_prefix}/${tl_prefix}_SDX65_UDP_UE6.sh &
    ...    sh ${sh_file_path}/${tl_prefix}/${tl_prefix}_SDX65_UDP_UE7.sh &
    ...    sh ${sh_file_path}/${tl_prefix}/${tl_prefix}_killer_test.sh &
    csn.send command
    ...    command=${command_ret}
    ...    connection=appserver

Reproduce_5605005.Stop Brust DL UDP Traffic
    [Arguments]    ${ue_num}=8    ${sh_file_path}=/home/cmw_sg6/5605005
    ${app_ip}    Set Variable    ${tl.ues[${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}].iperf_details.ssh_connection_details.addr}
    ${app_user}    Set Variable    ${tl.ues[${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}].iperf_details.ssh_connection_details.username}
    ${app_pwd}    Set Variable    ${tl.ues[${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}].iperf_details.ssh_connection_details.password}
    csn.connect to    hostname=${app_ip}    username=${app_user}    password=${app_pwd}    alias=appserver
    FOR    ${ue_index}    IN RANGE    ${ue_num}
        Log To Console    start to kill ue-${ue_index}
        csn.send command
        ...    command=ps -ef |grep ${sh_file_path}/${tl_prefix}/${tl_prefix}_SDX65_UDP_UE${ue_index}.sh |awk '{print $2}'|xargs kill -9
        ...    connection=appserver
    END
    csn.send command
    ...    command=ps -ef |grep ${tl_prefix}_killer_test.sh |awk '{print $2}'|xargs kill -9
    ...    connection=appserver
    [Teardown]    Csn.disconnect    connection=appserver

Reproduce_5605005.PA Value Setting FOR TL282
    [Documentation]   stella.lin@nokia-sbell.com
    [Arguments]    ${attenuator_index}=${3}
    @{channels}    Set Variable    ${tl.attenuators[${attenuator_index}].attenuator_ports}
    ${ip_addr}    set variable     ${tl.attenuators[${attenuator_index}].ip_addr}
    ${port}    set variable     ${tl.attenuators[${attenuator_index}].port}
    ${vendor}    set variable    ${tl.attenuators[${attenuator_index}].vendor}
    ${model}    set variable     ${tl.attenuators[${attenuator_index}].model}
    ${configured_attenuator}    attenuator.setup_attenuator
    ...    ip_addr=${ip_addr}
    ...    port=${port}
    ...    attenuation_port_numbers=${channels}
    ...    vendor=${vendor}
    ...    model=${model}
    FOR    ${index}    IN RANGE    1    13
        ${index}    Convert To Integer    ${index}
        ${value}    Evaluate    float(10)
        Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    5X    5sec   attenuator.set_attenuation
        ...    port=${index}   value=${value}   attenuator_device=${configured_attenuator}    confirm=True
        sleep   5sec
    END

Reproduce_5605005.PA Value Setting
    Run Keyword If    '${tl_prefix}'=='T080'    Reproduce_5605005.PA Value Setting FOR TL282
    Run Keyword If    '${tl_prefix}'=='T284'    Run Keywords    Modify PA Value Setting For Required RU    modify_ru_id=0
    ...    ue_index=${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}    AND
    ...    Modify PA Value Setting For Required RU    modify_ru_id=1
    ...    ue_index=${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}    AND
    ...    Modify PA Value Setting For Required RU    modify_ru_id=2   ue_index=${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}
    Run Keyword If    '${tl_prefix}'=='T073'    Run Keywords    Modify PA Value Setting For Required RU    modify_ru_id=0
    ...    ue_index=${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}    AND
    ...    Modify PA Value Setting For Required RU    modify_ru_id=3
    ...    ue_index=${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}    AND
    ...    Modify PA Value Setting For Required RU    modify_ru_id=6
    ...    ue_index=${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}


RepCase_5605005_CaseSetUp
    Run Keyword If    '${tl_prefix}'=='T073'    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}
    ...    ue_index=${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}
    ...    is_commission_for_first_gnb=${False}
    Run Keyword If    '${tl_prefix}'=='T080'    SetUp.TMO Case Common SetUp    is_second_gnb_used=${True}
    ...    ue_index=${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}
    ...    gnb_scf_name_for_second_gnb=5605005.xml    is_commission_for_second_gnb=${True}
    Run Keyword If    '${tl_prefix}'=='T284'    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}
    ...    ue_index=${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}
    ...    gnb_scf_name_for_first_gnb=5605005.xml    is_commission_for_first_gnb=${True}

RepCase_5605005_CaseTeardown
    Run Keyword If    '${tl_prefix}'=='T073'   Run Keyword And Continue On Failure
    ...    SetUp.Precondition For First gNB   is_commission=${False}    check_rollback_is_needed=${False}
    Run Keyword If    '${tl_prefix}'=='T080'     Run Keyword And Continue On Failure
    ...    SetUp.Precondition For Second gNB   is_commission=${True}    check_rollback_is_needed=${False}
    Run Keyword If    '${tl_prefix}'=='T284'     Run Keyword And Continue On Failure
    ...    SetUp.Precondition For First gNB   is_commission=${True}    check_rollback_is_needed=${False}

RepCase_5605005_rollback_commission
    Run Keyword If    '${tl_prefix}'=='T073'    Run Keyword And Continue On Failure
    ...    SetUp.Precondition For First gNB   is_commission=${False}
    ...    check_rollback_is_needed=${False}
    Run Keyword If    '${tl_prefix}'=='T080'     Run Keyword And Continue On Failure
    ...    SetUp.Precondition For Second gNB   is_commission=${True}    gnb_scf_name=5605005.xml
    ...    check_rollback_is_needed=${False}
    Run Keyword If    '${tl_prefix}'=='T284'     Run Keyword And Continue On Failure
    ...    SetUp.Precondition For First gNB   is_commission=${True}    gnb_scf_name=5605005.xml
    ...    check_rollback_is_needed=${False}

SetUp.Precondition For Second gNB
    [Documentation]   stella.lin@nokia0sbell.com
    [Arguments]     ${gnb_scf_name}=${None}
    ...             ${connection}=GNB_OAM1
    ...             ${is_commission}=False
    ...             ${timeout_for_commission}=900
    ...             ${is_pdl_checking_needed}=${True}
    ...             ${active_sw_flag}=High
    ...             ${check_rollback_is_needed}=${True}
    Run Keyword If    ${check_rollback_is_needed}    Check Rollback is needed before sw upgrade
    ...                                              active_sw_flag=${active_sw_flag}
    ...                                              gnb_connection=${connection}
    ...                                              gnb_index=${1}
    ${version}    Common_setup_and_teardown.Get Active SW Version Based On Stream Version    connection=${connection}
    ...    gnb_index=${1}
    ${gnb_scf_name}    Set Variable If    '${gnb_scf_name}'!='${None}'    ${gnb_scf_name}    ${tl_prefix}_gNB1_${version}.xml
    log to console    start to commssion scf ${gnb_scf_name}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${1}
    Run Keyword If    ${is_commission}
    ...    COAM Commission with scf file    scf_file_path=${SCF_PATH_ON_UTE}/${gnb_scf_name}
    ...                                     connection=${connection}
    ...                                     timeout=${timeout_for_commission}
    ...                                     is_pdl_checking_needed=${is_pdl_checking_needed}
    Verify TMO Gnb Ready And All Cell On Air    gnb_id=${1}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

SetUp.Precondition For First gNB
    [Documentation]    Author: stella.lin@nokia-sbell.com
    [Arguments]    ${gnb_scf_name}=${None}
    ...            ${connection}=GNB_OAM0
    ...            ${is_commission}=False
    ...            ${timeout_for_commission}=900
    ...            ${is_pdl_checking_needed}=${True}
    ...            ${active_sw_flag}=High
    ...            ${check_rollback_is_needed}=${True}
    Run Keyword If    ${check_rollback_is_needed}    Check Rollback is needed before sw upgrade
    ...                                              active_sw_flag=${active_sw_flag}
    ...                                              gnb_connection=${connection}
    ...                                              gnb_index=${0}
    ${version}    Common_setup_and_teardown.Get Active SW Version Based On Stream Version    connection=${connection}
    ...    gnb_index=${0}
    ${gnb_scf_name}    Set Variable If    '${gnb_scf_name}'!='${None}'    ${gnb_scf_name}    ${tl_prefix}_gNB_${version}.xml
    log to console    start to commssion scf ${gnb_scf_name}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${0}
    Run Keyword If    ${is_commission}
    ...    COAM Commission with scf file    scf_file_path=${SCF_PATH_ON_UTE}/${gnb_scf_name}
    ...                                     connection=${connection}
    ...                                     timeout=${timeout_for_commission}
    ...                                     is_pdl_checking_needed=${is_pdl_checking_needed}
    Verify TMO Gnb Ready And All Cell On Air    gnb_id=${0}    connection=${connection}

SetUp.Case Common Operation
    [Arguments]    ${ue_index}=${0}    ${whether_set_pa_value}=False    ${all_pa_trun_off}=${True}
    robot_common_operations.Common Case Setup
    Set Test Variable    ${test_case_id}    ${TEST NAME.split('_')[0]}
    Set Test Variable    ${case_params}    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']}
    Set Test Variable    ${PCELL_INDEX}    ${case_params.get('pcell_idx')}
    Set Test Variable    ${attenuator_list}    ${case_params.get('attenuator')}
    Set Test Variable    ${ca_technology}    ${case_params.get('ca_technology')}
    ${ca_technology_status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${case_params}    ca_technology
    Run Keyword If    ${ca_technology_status}    Set Test Variable    ${scell_technology}
    ...                                                               ${case_params.get('ca_technology').split('+')[-1]}
    Set Test Variable    ${LTE_CELL_INDEX}    ${case_params.get('lte_cell_idx')}
    ${lte_whether_in_gnb}    Check LTE Whether In Gnb
    Set Test Variable    ${LTE_WHETHER_IN_GNB}    ${lte_whether_in_gnb}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    Run Keyword If    ${all_pa_trun_off}    Trun Off All PA Ports
    Run Keyword If    ${whether_set_pa_value}    Set Case PA Or MCS Port Value    attenuator_list=${attenuator_list}
    ...    ue_index=${ue_index}

SetUp.TMO Case Common SetUp
    [Arguments]    ${is_first_gnb_used}=${False}
    ...            ${is_second_gnb_used}=${False}
    ...            ${is_commission_for_first_gnb}=${False}
    ...            ${is_commission_for_second_gnb}=${False}
    ...            ${active_sw_flag}=High
    ...            ${ue_index}=${0}
    ...            ${whether_set_pa_value}=${False}
    ...            ${gnb_scf_name_for_first_gnb}=${None}
    ...            ${gnb_scf_name_for_second_gnb}=${None}
    ...            ${all_pa_trun_off}=${True}
    Create Case Log Path
#    Run Keyword If    ${is_first_gnb_used}    SetUp.Precondition For First gNB    gnb_scf_name=${gnb_scf_name_for_first_gnb}
#    ...    is_commission=${is_commission_for_first_gnb}    active_sw_flag=${active_sw_flag}
#    Run Keyword If    ${is_second_gnb_used}    SetUp.Precondition For Second gNB    gnb_scf_name=${gnb_scf_name_for_second_gnb}
#    ...    is_commission=${is_commission_for_second_gnb}    active_sw_flag=${active_sw_flag}
    SetUp.Case Common Operation    ue_index=${ue_index}    whether_set_pa_value=${whether_set_pa_value}
    ...    all_pa_trun_off=${all_pa_trun_off}
    ${currenttime}    robot.libraries.DateTime.Get current date    result_format=%Y-%m-%d%H:%M:%S
    Set Test Variable    ${TEST_EXECUTION_TIME}    ${currenttime}

#--------  Test Case Steps -------#
TestCase.Reproduce_5605004
    Modify weightForSCellSelection
    Log to console    INFO:--start to config relation cells--
    Configure Relation Cells
    Log to console    INFO:--start to disable 9531 function--
    ${version}    Common_setup_and_teardown.Get Active SW Version Based On Stream Version
    Run Keyword If    '${version}'=='24R2' or '${version}'=='24R1'    Disable 9531 Function For 24R2
    ...    ELSE    Disable 9531 Function
#    Backup and Modify swconfig file    swconfig_modify=@{wireshark_flag}
#    Perform gNB Reset site and Wait Onair
    log to console  INFO:--generate source cell and target cell info--
    ${source_cell}    Set Variable    ${PCELL_INDEX}
    ${target_cell}    Set Variable    ${case_params.get('inter_gnb_ho_cell')}
    ${source_cell_info}     Set Variable    ${SOURCE_CELL_MAPPING[${source_cell}]}
    ${target_cell_info}     Set Variable    ${TARGET_CELL_MAPPING[${target_cell}]}
    ${source_cell_ru_index}    Set Variable    ${source_cell_info['ru_index_mapping']}
    ${target_cell_ru_index}    Set Variable    ${target_cell_info['ru_index_mapping']}
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${PCELL_INDEX}
    ...    connection=GNB_OAM    timeout=300
    Connect to gnb coam via ssl    connection=GNB_OAM1    gnb_index=1
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${target_cell}
    ...    connection=GNB_OAM1    timeout=300
    Run Keyword And Continue On Failure    Run Keyword If    '${ue_type}'=='qct_dx50'
    ...    Procedures.Check network mode    ue_index=${used_ue_index}
    log to console  INFO:--start to set PA value for source and target cell--
    Modify PA Value Setting For Required RU    modify_ru_id=${source_cell_ru_index}
    ...                                        ue_index=${used_ue_index}
    PA Value Setting For Required RU Required gNB    modify_ru_id=${target_cell_ru_index}
    ...                                              gnb_id=${1}
    ...                                              pa_value=${110}
    log to console  INFO:--start trigger inter-gnb handover process for 3 rounds--
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Connect to Common Unit Master     alias=ASIK Master0   gnb_index=${0}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
    ...    cprt_collector_name=source_cprt_${timestamp}
    ...    tcpdump_collector_name=source_cell_wireshark_${timestamp}
    ...    asik_connection_alias=ASIK Master0
    ...    gnb_index=${0}
    ...    du_index=0
    Sleep  10sec
    Connect to Common Unit Master     alias=ASIK Master1   gnb_index=${1}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
    ...    cprt_collector_name=target_cprt_${timestamp}
    ...    tcpdump_collector_name=target_cell_wireshark_${timestamp}
    ...    asik_connection_alias=ASIK Master1
    ...    gnb_index=${1}
    ...    du_index=0
    Sleep  10sec
    Procedures.Start UE Prepare    ue_index=${used_ue_index}   ue_type=${ue_type}    get_spark_license=${False}
#    ${target_pa_value}     Set Variable If    '${tl_prefix}'=='T073'    ${10}
#    ...                                       '${tl_prefix}'=='T080'    ${10}
#    PA Value Setting For Required RU Required gNB    modify_ru_id=${target_cell_ru_index}
#    ...                                              gnb_id=${1}
#    ...                                              pa_value=${target_pa_value}
#    Sleep    5min
    ${sleep_seconds}    Caculate timeToSleep Before Next Counters Period
    log to console    INFO:-- need to sleep ${sleep_seconds} before next counter start --
    Sleep    ${sleep_seconds}sec
    ${call_start_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_start_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${call_start_time}    Add Time To Date    ${call_start_time}    -301    exclude_millis=true
    FOR    ${round}    IN RANGE    ${3}
        log to console  INFO:-- start to attach for UE-1 ROUND-${round} --
        log to console  INFO:--restore PA value ROUND-${round} --
#        PA Value Setting For Required RU Required gNB    modify_ru_id=${target_cell_ru_index}
#        ...                                              gnb_id=${1}
#        ...                                              pa_value=110
        Modify PA Value Setting For Required RU    modify_ru_id=${source_cell_ru_index}
        ...                                        ue_index=${used_ue_index}
        Run Keyword If    '${tl_prefix}'=='T073'    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${used_ue_index}
        ...    ELSE IF    '${tl_prefix}'=='T080'    Spark_common_keywords.Start UE Attach in X65 multi UE x65
        ...                                         ue_index=${used_ue_index}
#        Sleep  2sec
        log to console  INFO:--start to ping traffic ROUND-${round}--
        Run Keyword If    '${tl_prefix}'=='T073'    Start Ping Traffic    ue_index=${used_ue_index}
        ...    ELSE IF    '${tl_prefix}'=='T080'    Start Ping Traffic For Spark    ue_index=${used_ue_index}
        Sleep   8sec
        log to console  INFO:--trigger inter-gnb handover ROUND-${round}--
        ${target_pa_value}     Set Variable If    '${tl_prefix}'=='T073'    ${10}
        ...                                       '${tl_prefix}'=='T080'    ${10}
        PA Value Setting For Required RU Required gNB    modify_ru_id=${target_cell_ru_index}
        ...                                              gnb_id=${1}
        ...                                              pa_value=${target_pa_value}
        Sleep  3sec
        ${souce_pa_value}     Set Variable If    '${tl_prefix}'=='T073'    ${25}
        ...                                      '${tl_prefix}'=='T080'    ${15}
        Modify PA Value Setting For Required RU    modify_ru_id=${source_cell_ru_index}
        ...                                        ue_index=${used_ue_index}
        ...                                        pa_off_value=${souce_pa_value}
        Sleep  4sec
        log to console  INFO:--stop ping traffic ROUND-${round} --
        Run Keyword If    '${tl_prefix}'=='T073'    Stop Ping Traffic    ue_index=${used_ue_index}
        ...    ELSE IF    '${tl_prefix}'=='T080'    Stop Ping Traffic For Spark    ue_index=${used_ue_index}
        log to console  INFO:--detach ROUND-${round} --
        power_ue.UE Detach    ue_type=${ue_type}    ue_index=${used_ue_index}
    END
    Sleep  30sec
    ${source_cell_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    cprt_collector_name=source_cprt_${timestamp}
    ...    tcpdump_collector_name=source_cell_wireshark_${timestamp}
    ...    target_dir=${TS_CASE_LOG_PATH}
    ...    asik_connection_alias=ASIK Master0
    ${target_cell_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    cprt_collector_name=target_cprt_${timestamp}
    ...    tcpdump_collector_name=target_cell_wireshark_${timestamp}
    ...    target_dir=${TS_CASE_LOG_PATH}
    ...    asik_connection_alias=ASIK Master1
#    Sleep    10min
    ${call_end_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_end_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
#    ${call_end_time}    Add Time To Date    ${call_end_time}    600    exclude_millis=true
    ${diff_time}    Subtract Date From Date    ${call_end_time}   ${call_start_time}
    log to console    ${diff_time}
    ${call_end_time}    Run Keyword If    ${diff_time}<=900    Add Time To Date    ${call_start_time}   900
    ...    exclude_millis=true
    ...    ELSE    Set Variable    ${call_end_time}
    Set Test Variable    ${call_start_time}
    Set Test Variable    ${call_end_time}
    log to console  INFO:--check attach and handover success--
    ${attach_cell_index}    Run Keyword And Continue On Failure    Get Attach Cell Index From Wireshark
    ...    cpif_log_path=${source_cell_wireshark}
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${attach_cell_index}    ${PCELL_INDEX}
    ...    msg=attach ERROR,target cell is ${PCELL_INDEX},actual is ${attach_cell_index}
    ${A3A5_status}    Run Keyword And Return Status    HO.Check A5A3 Measurement Report    cpif_log_path=${source_cell_wireshark}
    ...    exp_source_pci=${source_cell_info['physicalCellId']}
    ...    exp_target_pci=${target_cell_info['physicalCellId']}
    ...    rounds=${3}
    ${RRC_Reconfigured_Status}    Run Keyword And Return Status    HO.Check RRC Reconfigure And RRC Reconfigure Complete For Inter-gnb
    ...    source_cpif_log_path=${source_cell_wireshark}
    ...    target_cpif_log_path=${target_cell_wireshark}
    ...    rounds=${3}
    ${RRC_Reestablishment_source}    Run Keyword And Return Status    HO.Check RRC Reestablishment
    ...    cpif_log_path=${source_cell_wireshark}
    ${RRC_Reestablishment_target}    Run Keyword And Return Status    HO.Check RRC Reestablishment
    ...    cpif_log_path=${target_cell_wireshark}
    ${test_valid_status}    Evaluate
    ...    ${A3A5_status} and ${RRC_Reconfigured_Status} and ${RRC_Reestablishment_source} and ${RRC_Reestablishment_target}
#    ${test_valid_status}    Evaluate
#    ...    ${A3A5_status} and ${RRC_Reconfigured_Status}
    run keyword if  not ${test_valid_status}    Fail    msg=handover is not success for 3 times.
    Sleep    20min
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error     Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=source_cell_wireshark_${timestamp}
    ...    target_dir=${TS_CASE_LOG_PATH}    AND
    ...    Run Keyword And Ignore Error     Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=target_cell_wireshark_${timestamp}
    ...    target_dir=${TS_CASE_LOG_PATH}   AND
    ...    Run Keyword And Ignore Error   Stop Ping Traffic    ue_index=${used_ue_index}    AND
    ...    Run Keyword And Ignore Error   Stop Ping Traffic For Spark    ue_index=${used_ue_index}    AND
    ...    Run Keyword And Ignore Error   csn.execute    command=killall tcpdump    connection=ASIK Master0    AND
    ...    Run Keyword And Ignore Error   csn.execute    command=killall tcpdump    connection=ASIK Master1    AND
    ...    Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master0    AND
    ...    Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master1    AND
    ...    Run Keyword And Ignore Error    Connect to gnb coam via ssl    connection=GNB_OAM0    gnb_index=${0}    AND
    ...    Run Keyword And Ignore Error    COAM Save snapshot via rest api
    ...                                    connection=GNB_OAM0
    ...                                    timeout=900     AND
    ...    Run Keyword And Ignore Error    Connect to gnb coam via ssl    connection=GNB_OAM1    gnb_index=${1}    AND
    ...    Run Keyword And Ignore Error    COAM Save snapshot via rest api
    ...                                    connection=GNB_OAM1
    ...                                    timeout=900



TestCase.Reproduce_5603052
    [Documentation]   lei.jia@nokia-sbell.com
    [Arguments]      ${start_L3_call}=True    ${good}=good    ${mid}=mid    ${bad}=bad    ${enb_index}=${1}
    # L3 call one turn, start SA l3 call with good -> mid -> bad -> mid -> good -> stop l3 call
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    Log To Console    ${\n}INFO:-- modify CA configuration 2CC --
    Update Parameter to prepare L3 call    para_value=false
    ...                                   enb_index=${fdd_enb_index}
    Update_TMO_3CC_Configration    ue_index=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
    Change cellBarred Parameter Value On Gnb    pcell_index=${PCELL_INDEX}    exp_status=notBarred
    Run Keyword And Continue On Failure    Run Keyword If   '${tl_prefix}'=='T080'    Lock Or Unlock Single Cell
    ...                                    cell_index=3    cell_type=nr    action=block
    Run Keyword And Continue On Failure    Run Keyword If   '${tl_prefix}'=='T080'    Lock Or Unlock Single Cell
    ...                                    cell_index=23    cell_type=nr    action=block
    ${L3_call_succesful}    ${call_start_try0}     ${call_end_try0}
    ...                  Get KPI Report with difference RSRP and TP in 15min    whether_need_ue_log=${False}
    ...                                   enb_index=${enb_index}    good=${good}    mid=${mid}    bad=${bad}    UTC_timezone=${False}
    ${L3_call_succesful1}    ${call_start_try1}     ${call_end_try1}    Run Keyword If    ${L3_call_succesful}=='False'
    ...                  Get KPI Report with difference RSRP and TP in 15min     whether_need_ue_log=${False}
    ...                                   enb_index=${enb_index}    good=${good}    mid=${mid}    bad=${bad}    UTC_timezone=${False}
    ${call_start_time}    Set Variable If   '${L3_call_succesful}'=='True'    ${call_start_try0}    ${call_end_try0}
    ${call_end_time}      Set Variable If   '${L3_call_succesful}'=='True'    ${call_end_try0}      ${call_end_try1}
    ${diff_time}    Subtract Date From Date    ${call_end_time}    ${call_start_time}
    log to console    ${diff_time}
    ${call_end_time}    Run Keyword If    ${diff_time}<=900    Add Time To Date    ${call_start_time}    901
    ...    exclude_millis=true
    ...    ELSE    Set Variable    ${call_end_time}
    log to console    ${call_end_time}
    Set Test Variable    ${call_end_time}
    Set Test Variable    ${call_start_time}

TestCase.Reproduce_5605002
    ${remote_log_path}    OperatingSystem.Join Path    ${TS_CASE_LOG_PATH}    8311_kpi
    OperatingSystem.Create Directory    ${remote_log_path}
    Set Test Variable     ${remote_log_path}
    ${case_time}=    Get Current Date    result_format=%Y%m%d%H%M%S
    ${spark_ue_logpath} =   Catenate    SEPARATOR=_   ${spark_ue_logpath}   ${case_time}
    ${spark_ue_logname} =   Catenate    SEPARATOR=_   ${target_version}   ${case_time}
    Set Test Variable   ${spark_ue_logname}
    Set Test Variable   ${spark_ue_logpath}
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    Update_TMO_3CC_Configration    ue_index=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
    Update Parameter to prepare L3 call    para_value=false
    ...                                   enb_index=${fdd_enb_index}
    Update The Prach Index    cell_index=${PCELL_INDEX}    prach_index=9
    Change cellBarred Parameter Value On Gnb    pcell_index=${PCELL_INDEX}    exp_status=notBarred
    Run Keyword And Ignore Error    MultiUE Prepare UE     low_RSRP=True
    ${call_start_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_start_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${fail_time}    Set Variable    ${0}
    FOR    ${i}    IN RANGE    1    191
           log to console      "UE Attach_${i}"
           ${success_status}    Run Keyword And Return Status    MultiUE Attach without check TP in UE
           ...    logpath=${spark_ue_logpath}    logname=run_1_${i}    save_ue_log=False
           ...    DL_200M_8311=DL_10M_8311
           sleep   2s
           ${fail_time}     Run Keyword If    '${success_status}'=='${False}'    Evaluate    ${fail_time}+${1}
           ...    ELSE     Evaluate    ${fail_time}+${0}
    END
    Get Syslog Start Time
    FOR    ${i}    IN RANGE    1    11
           log to console      "UE Attach_no_tp_${i}"
           ${success_status}    Run Keyword And Return Status    MultiUE Attach without check TP in UE
           ...    logpath=${spark_ue_logpath}    logname=run_1_${i}    DL_200M_8311=DL_10M_8311
           sleep   2s
           ${fail_time}     Run Keyword If    '${success_status}'=='${False}'    Evaluate    ${fail_time}+${1}
           ...    ELSE     Evaluate    ${fail_time}+${0}
    END
    ${call_end_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_end_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Set Test Variable    ${call_end_time}
    Set Test Variable    ${call_start_time}
    Run Keyword And Ignore Error    power_ue.UE Attach     ue_type=sigspark_multiUE
    Set Test Variable    ${FAIL_TIME}    ${fail_time}

TestCase.Reproduce_5605005
    ${remote_log_path}    OperatingSystem.Join Path    ${TS_CASE_LOG_PATH}    8311_kpi
    OperatingSystem.Create Directory    ${remote_log_path}
    Set Test Variable     ${remote_log_path}
    ${case_time}=    Get Current Date    result_format=%Y%m%d%H%M%S
    ${spark_ue_logpath} =   Catenate    SEPARATOR=_   ${spark_ue_logpath}   ${case_time}
    ${spark_ue_logname} =   Catenate    SEPARATOR=_   ${target_version}   ${case_time}
    Set Test Variable   ${spark_ue_logname}
    Set Test Variable   ${spark_ue_logpath}
    Connect to gnb coam via ssl    connection=GNB_OAM${used_gnb_index}    gnb_index=${used_gnb_index}
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${PCELL_INDEX}
    ...    connection=GNB_OAM${used_gnb_index}    timeout=300
    Run Keyword And Ignore Error    MultiUE Prepare UE For Spark    ue_index=${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Connect to Common Unit Master     alias=ASIK Master0   gnb_index=${used_gnb_index}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
    ...    cprt_collector_name=source_cprt_${timestamp}
    ...    tcpdump_collector_name=source_cell_wireshark_${timestamp}
    ...    asik_connection_alias=ASIK Master0
    ...    gnb_index=${used_gnb_index}
    ...    du_index=0
    power_ue.UE Attach     ue_type=sigspark_multiUE
    Sleep    45sec
    ${source_cell_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    cprt_collector_name=source_cprt_${timestamp}
    ...    tcpdump_collector_name=source_cell_wireshark_${timestamp}
    ...    target_dir=${TS_CASE_LOG_PATH}
    ...    asik_connection_alias=ASIK Master0
    ${attach_cell_index}    Run Keyword And Continue On Failure    Get Attach Cell Index From Wireshark
    ...    cpif_log_path=${source_cell_wireshark}    connection=GNB_OAM${used_gnb_index}    gnb_index=${used_gnb_index}
    Should Be Equal As Integers    ${attach_cell_index}    ${PCELL_INDEX}
    ...    msg=attach ERROR,target cell is ${PCELL_INDEX},actual is ${attach_cell_index}
#    ${sleep_seconds}    Caculate timeToSleep Before Next Counters Period
#    log to console    INFO:-- need to sleep ${sleep_seconds} before next counter start --
#    Sleep    ${sleep_seconds}sec
    ${call_start_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_start_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    FOR    ${round}    IN RANGE    5
        Run Keyword And Continue On Failure    Reproduce_5605005.Start Brust DL UDP Traffic
        Sleep    28min
        Run Keyword And Continue On Failure    Reproduce_5605005.Stop Brust DL UDP Traffic
        Sleep    10sec
    END
    Get Syslog Start Time
    Reproduce_5605005.Start Brust DL UDP Traffic
    Sleep    10min
    ${call_end_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_end_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Set Test Variable    ${call_end_time}
    Set Test Variable    ${call_start_time}
    FOR    ${i}    IN RANGE    1    11
           log to console      "UE Attach_no_tp_${i}"
           ${success_status}    Run Keyword And Return Status    MultiUE Attach without check TP in UE
           ...    logpath=${spark_ue_logpath}    logname=run_1_${i}    DL_200M_8311=DL_10M_8311
           sleep   2s
    END
    #----Check Error Log in syslog for about 10minutes
    ${error_file}    Run Keyword And Continue On Failure    Find Syslog Errors During A Specific Period of Time
    ...    syslog_start_time=${SYSLOG_START_TIME}    gnb_index=${used_gnb_index}   if_syslog_in_remote_pc=${True}
    ...    remote_pc=${tl.ues[-1].ssh_connection_details.addr}    if_original_syslog_need_return=${True}
    ${total_syslog}    Set Variable    ${error_file[1]}
    ${error_ue_context}    run  zgrep "adding UE failed" ${total_syslog}
    ${error_uegroup_context}    run  zgrep "The UE group is full" ${total_syslog}
    Run Keyword And Continue On Failure    Should Be Empty    ${error_ue_context}    msg=ERR/adding UE failed exist.
    Run Keyword And Continue On Failure    Should Be Empty    ${error_uegroup_context}    msg=ERR/UE group is full exist.
    [Teardown]    Run Keywords    Reproduce_5605005.Stop Brust DL UDP Traffic    AND
    ...    Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master${used_gnb_index}    AND
    ...    Run Keyword And Ignore Error    Connect to gnb coam via ssl    connection=GNB_OAM${used_gnb_index}
    ...    gnb_index=${used_gnb_index}    AND
    ...    Run Keyword And Ignore Error    COAM Save snapshot via rest api    connection=GNB_OAM${used_gnb_index}
    ...                                    timeout=900



TestCase.Reproduce_5605501
    ${btsName}    ${gnb_version}     Get BtsName and SwVersion    gnb_id=${0}    connection=GNB_OAM0
    Set Test Variable    ${btsName}
    Set Test Variable    ${gnb_version}
    ${scf_version}    ${stream_version}    Get scf stream and sw stream    scf_name=${btsName}    sw_version=${gnb_version}
    #lock AMF
    Update AMF Status     administrativeState=Locked
    Sleep    1sec
    #change params for NRCELL-301/302/303/311/312/313
    ${delete_enforcePrimaryPathOverLte}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-301',
    ...    'parameter':'enforcePrimaryPathOverLte'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-302',
    ...    'parameter':'enforcePrimaryPathOverLte'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-303',
    ...    'parameter':'enforcePrimaryPathOverLte'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-311',
    ...    'parameter':'enforcePrimaryPathOverLte'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-312',
    ...    'parameter':'enforcePrimaryPathOverLte'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-313',
    ...    'parameter':'enforcePrimaryPathOverLte'}
    ${delete_params}    Evaluate   [${delete_enforcePrimaryPathOverLte}]
    Delete Params Through RestApi    parameters_to_delete_via_api=${delete_params}    is_verify_onair=${False}
    #change params for NRCELL-1/2/3
    ${update_enforcePrimaryPathOverLte}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1',
    ...    'parameter':'enforcePrimaryPathOverLte','value':'true'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2',
    ...    'parameter':'enforcePrimaryPathOverLte','value':'true'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3',
    ...    'parameter':'enforcePrimaryPathOverLte','value':'true'}
    ${update_ulTransPrecodeCtl}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1',
    ...    'parameter':'ulTransPrecodeCtl','value':[{'ulTransPrecodeOffSinrThresh':'-30','ulTransPrecodeOnSinrThresh':'-80'}]},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2',
    ...    'parameter':'ulTransPrecodeCtl','value':[{'ulTransPrecodeOffSinrThresh':'-30','ulTransPrecodeOnSinrThresh':'-80'}]},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3',
    ...    'parameter':'ulTransPrecodeCtl','value':[{'ulTransPrecodeOffSinrThresh':'-30','ulTransPrecodeOnSinrThresh':'-80'}]}
    ${update_params_list}    Evaluate    [${update_enforcePrimaryPathOverLte},${update_ulTransPrecodeCtl}]
    Update Params Through RestApi    params_need_to_modify=${update_params_list}    is_verify_onair=${False}
    #unlock AMF
    Sleep    10sec
    Update AMF Status     administrativeState=Unlocked
    Verify TMO Gnb Ready And All Cell On Air
#    check counter M55150C00035 more than 2 measurement period
    ${report_timestamps_round0}      Create List
    ${report_timestamps_round1}      Create List
    ${call_start_time_UTC_round0}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_start_time_round0}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Sleep    15min
    ${call_end_time_UTC_round0}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_end_time_round0}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${call_timestamp_round0}    Create List    ${call_start_time_round0}    ${call_end_time_round0}
    Append To List    ${report_timestamps_round0}    ${call_timestamp_round0}
    #lock AMF
    Update AMF Status     administrativeState=Locked
    Sleep  1sec
    #change params for NRCELL-301/302/303/311/312/313
    ${add_enforcePrimaryPathOverLte}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-301',
    ...    'parameter':'enforcePrimaryPathOverLte','value':'false'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-302',
    ...    'parameter':'enforcePrimaryPathOverLte','value':'false'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-303',
    ...    'parameter':'enforcePrimaryPathOverLte','value':'false'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-311',
    ...    'parameter':'enforcePrimaryPathOverLte','value':'false'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-312',
    ...    'parameter':'enforcePrimaryPathOverLte','value':'false'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-313',
    ...    'parameter':'enforcePrimaryPathOverLte','value':'false'}
    ${add_params}    Evaluate   [${add_enforcePrimaryPathOverLte}]
    Add Params Through RestApi    parameters_to_add_via_api=${add_params}    is_verify_onair=${False}
    #change params for NRCELL-1/2/3
    ${update_enforcePrimaryPathOverLte}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1',
    ...    'parameter':'enforcePrimaryPathOverLte','value':'false'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2',
    ...    'parameter':'enforcePrimaryPathOverLte','value':'false'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3',
    ...    'parameter':'enforcePrimaryPathOverLte','value':'false'}
    ${update_ulTransPrecodeCtl}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1',
    ...    'parameter':'ulTransPrecodeCtl','value':[{'ulTransPrecodeOffSinrThresh':'40','ulTransPrecodeOnSinrThresh':'0'}]},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2',
    ...    'parameter':'ulTransPrecodeCtl','value':[{'ulTransPrecodeOffSinrThresh':'40','ulTransPrecodeOnSinrThresh':'0'}]},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3',
    ...    'parameter':'ulTransPrecodeCtl','value':[{'ulTransPrecodeOffSinrThresh':'40','ulTransPrecodeOnSinrThresh':'0'}]}
    ${update_params_list}    Evaluate    [${update_enforcePrimaryPathOverLte},${update_ulTransPrecodeCtl}]
    Update Params Through RestApi    params_need_to_modify=${update_params_list}    is_verify_onair=${False}
    #unlock AMF
    Sleep    10sec
    Update AMF Status     administrativeState=Unlocked
    Verify TMO Gnb Ready And All Cell On Air
#    check counter M55150C00035 more than 2 measurement period
    ${call_start_time_UTC_round1}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_start_time_round1}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Sleep    15min
    ${call_end_time_UTC_round1}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_end_time_round1}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${call_timestamp_round1}    Create List    ${call_start_time_round1}    ${call_end_time_round1}
    Append To List    ${report_timestamps_round1}    ${call_timestamp_round1}
    Sleep    30min
    [Return]    ${report_timestamps_round0}    ${report_timestamps_round1}
    [Teardown]   Run Keyword And Ignore Error     Save Current SCF And Save Snapshot


TestCase.Reproduce_5603153
    log to console    \n--- step1: start l3 call before upgrade---
    Disable actDlSrsBm and releated params via Admin API
#    Backup and Modify swconfig file    swconfig_modify=@{wireshark_flag}
#    Perform gNB Reset site and Wait Onair
    ${btsName_before_upgrade}    ${gnb_version_before_upgrade}     Get BtsName and SwVersion
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    ${timestamp_before_upgrade}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d-%H%M%S
    ${tput_before_upgrade}    Start L3 call and Record tput with aasyslog    cell_list=${large_chbw_nrcells_list}
    ...    ue_index=${ue_index}    whether_do_ue_prepare=${False}    get_spark_license=${False}
    [Return]     ${tput_before_upgrade}    ${timestamp_before_upgrade}    ${btsName_before_upgrade}    ${gnb_version_before_upgrade}


TMO.Start BIP Capture
    [Arguments]    ${nr_phy_cell_ids}=813    ${capture_time}=10
    ...            ${target_file_name}=l1l2bip_log    ${gnb_index}=0    ${target_dir}=${TS_CASE_LOG_PATH}
    ${trace_timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    ${target_file_name}    Set Variable    ${target_file_name}_${trace_timestamp}
    Collect Interface Mirroring Bip Collector    target_file_name=${target_file_name}
    ...                                          nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                          gnb_index=${gnb_index}
    sleep    ${capture_time}
    ${bip_log_path}    Get Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}
    ...                                                                 target_dir=${target_dir}
    [Return]    ${bip_log_path[0]}
    [Teardown]    Run Keyword And Ignore Error    Stop Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}

RepCase_5605006.Get PatternId Range From Syslog
    [Arguments]    ${syslog_start_time}    ${syslog_end_time}    ${syslog_path}=/tmp/btslog2
    ${syslog_start_time}  	DateTime.Convert Date 	${syslog_start_time}     epoch
    ${syslog_end_time}  	DateTime.Convert Date 	${syslog_end_time}     epoch
    @{syslog_files_for_case}   Create List
    ${string_files} = 	Run 	cd ${syslog_path}&&find -name "SYSLOG_*.LOG"
    ${files}   Split String    ${string_files}   \n
    FOR    ${file}    IN    @{files}
        ${syslog_modtime} = 	OperatingSystem.Get Modified Time 	${syslog_path}//${file}    epoch
        Run Keyword If    ${syslog_end_time} > ${syslog_modtime} > ${syslog_start_time}    Copy Files
        ...    ${syslog_path}//${file}   	${TS_CASE_LOG_PATH}
        Run Keyword If    ${syslog_end_time} > ${syslog_modtime} > ${syslog_start_time}
        ...    Append To List     ${syslog_files_for_case}    ${syslog_path}//${file}
    END
    ${all_patter_in_syslog}     Create List
    FOR    ${syslog_item}    IN    @{syslog_files_for_case}
        ${empty_list}    Create List
#        ${output}    run    grep -n 'SCellParametersReq' ${syslog_item}
#        ${status}    Run Keyword And Return Status     Should Not Be Empty    ${output}
#        ${output}    Get File    ${syslog_item}
        ${output}    run    grep -n 'CellParametersReq' ${syslog_item}
        ${status}    Run Keyword And Return Status     Should Not Be Empty    ${output}
        ${patter}    Run Keyword If    ${status}    Get Regexp Matches    ${output}    "patternIdMin":(\\d+),"patternIdMax":(\\d+)   1    2
        ${all_patter_in_syslog}    Run Keyword If    ${status}    combine lists   ${all_patter_in_syslog}    ${patter}
        ...    ELSE    combine lists    ${all_patter_in_syslog}    ${empty_list}
    END
    ${all_patter_in_syslog}    Remove Duplicates    ${all_patter_in_syslog}
    log to console   all patter in syslog is : ${all_patter_in_syslog}
    Should Not Be Empty    ${all_patter_in_syslog}    msg=failed to get pattern id range from syslog
    [Return]    ${all_patter_in_syslog}


RepCase_5605006.Get PatternId From BIP
    [Arguments]    ${file_path}    ${physical_id}=813
    Setup Pcap File   file_path=${file_path}    filter=dldata_pdschsendreq
    ${filter_exp}    catenate    3gpp.dmrsScramblingSequenceInt == ${physical_id} && 3gpp.rnti != 65535 &&
    ...    DlData_PdschGrant.modulationOrder != 2
    ${patternId_values_list}    Get Field Value From PCAP    field_name=DlData_PdschGrant.patternId_item
    ...    filter_expression=${filter_exp}
    ${patternId_values_length}    Get Length    ${patternId_values_list}
    Should Be True    ${patternId_values_length}>${1}    msg=no valid data filter out.please check the bip log.
    ${patternId_values_list}     Remove Duplicates    ${patternId_values_list}
    log to console    ${patternId_values_list}
    [Return]    ${patternId_values_list}

RepCase_5605006.Get Pattern Range
    [Arguments]    ${patternId_values_list_in_bip}    ${all_patter_in_syslog}
    ${max_pattern_id}    Evaluate    [max(x) for x in ${patternId_values_list_in_bip}]
    ${min_pattern_id}    Evaluate    [min(x) for x in ${patternId_values_list_in_bip}]
    ${all_pattern_id}    combine lists    ${max_pattern_id}    ${min_pattern_id}
    ${max_pattern_id}    Evaluate    max(${all_pattern_id})
    ${min_pattern_id}    Evaluate    min(${all_pattern_id})
    log to console    ${max_pattern_id}
    log to console    ${min_pattern_id}
    ${condition}    Set Variable    int(${max_pattern_id})<=int(item[1]) and int(${min_pattern_id})>=int(item[0])
    ${range_index}    Evaluate    [index for (index, item) in enumerate(${all_patter_in_syslog}) if ${condition}]
    log to console   ${range_index}
    [Return]    ${range_index}

RepCase_5605006.Check Pattern Id In Same Range
    [Arguments]    ${syslog_start_time}
    ...            ${syslog_end_time}
    ...            ${patternId_values_list_in_bip_step2}
    ...            ${patternId_values_list_in_bip_step4}
    ...            ${syslog_path}=/tmp/btslog2
    ${patter_in_syslog}    Run Keyword And Continue On Failure     RepCase_5605006.Get PatternId Range From Syslog
    ...    syslog_start_time=${syslog_start_time}
    ...    syslog_end_time=${syslog_end_time}
    ...    syslog_path=${syslog_path}
#    ${patter_in_syslog}    catenate    ('6', '10'),('21', '30'),('101', '130'),('1024', '1451'),('1452', '1879'),
#    ...    ('1880', '2284'),('2285', '2500'),('2906', '3310'),('3311', '3738'),('3739', '4166'),
#    ...    ('4167', '4571'),('4572', '4787'),('5193', '5597')
#    ${patter_in_syslog}    Run Keyword And Continue On Failure    Evaluate    [${patter_in_syslog}]
    ${patter_in_bip_step2}    Run Keyword And Continue On Failure    RepCase_5605006.Get PatternId From BIP
    ...    file_path=${patternId_values_list_in_bip_step2}
    ${patter_in_bip_step4}    Run Keyword And Continue On Failure    RepCase_5605006.Get PatternId From BIP
    ...    file_path=${patternId_values_list_in_bip_step4}
    ${range_index_step2}    RepCase_5605006.Get Pattern Range     patternId_values_list_in_bip=${patter_in_bip_step2}
    ...    all_patter_in_syslog=${patter_in_syslog}
    ${range_index_step4}    RepCase_5605006.Get Pattern Range     patternId_values_list_in_bip=${patter_in_bip_step4}
    ...    all_patter_in_syslog=${patter_in_syslog}
    Lists Should Be Equal    ${range_index_step2}    ${range_index_step4}
    ...    msg=pattern changed. step2 is ${patter_in_syslog[${range_index_step2}[0]]},step4 is ${patter_in_syslog[${range_index_step4}[0]]}

RepCase_5603147.Stop Traffic And Detach
    Run Keyword And Ignore Error    M60_RedCap.Stop Traffic    ue_index=${14}    dl_port=${redcap_ue_dl_port}
    Run Keyword And Ignore Error    M60_RedCap.Stop Traffic    ue_index=${15}    dl_port=${normal_ue_dl_port}
    Run Keyword And Ignore Error    M60_RedCap.UE Detach     ue_index=${14}
    Run Keyword And Ignore Error    M60_RedCap.UE Detach     ue_index=${15}    ue_type=${normal_ue_type}

RepCase_5603147.Check Tput And Bler Per UE
    [Arguments]    ${pcell_tti_trace}     ${scell_tti_trace}
    ${ues_ul_tputs}    Run Keyword And Continue On Failure     calculate_ubler_and_ultput_for_ues
    ...    file_path=${pcell_tti_trace}
    ${ues_dl_tputs}    Run Keyword And Continue On Failure     calculate_dlbler_and_dltput_for_ues
    ...    file_path=${pcell_tti_trace}
    ${scell_ue_dl_tputs}    Run Keyword And Continue On Failure     calculate_dlbler_and_dltput_for_ues
    ...    file_path=${scell_tti_trace}
    ${pcell_ul_ues}    Get Dictionary Keys    ${ues_ul_tputs}
    ${ul_ues_length}    Get Length    ${pcell_ul_ues}
    Should Be True    '${ul_ues_length}'>='${2}'    msg=ul ues are not include 2 ues. actual is ${ul_ues_length} UEs.
    ${pcell_dl_ues}    Get Dictionary Keys    ${ues_dl_tputs}
    ${dl_ues_length}    Get Length    ${pcell_dl_ues}
    Should Be True    '${dl_ues_length}'>='${2}'    msg=dl ues are not include 2 ues. actual is ${ul_ues_length} UEs.
    ${pcell_ul_dict_values}    Get Dictionary Values    ${ues_ul_tputs}
    ${ues_ul_tput}     Evaluate     [float(x['tput']) for x in ${pcell_ul_dict_values}]
    sort list     ${ues_ul_tput}
    ${normal_ue_ul_tput}    Set Variable    ${ues_ul_tput[-1]}
    ${redcap_ue_ul_tput}    Set Variable    ${ues_ul_tput[-2]}
    ${ues_ul_bler}     Evaluate     [float(x['bler']) for x in ${pcell_ul_dict_values}]
    ${ul_bler}    Evaluate    max(${ues_ul_bler})
    ${ues_ul_ibler}     Evaluate     [float(x['ibler']) for x in ${pcell_ul_dict_values}]
    ${ul_ibler}    Evaluate    max(${ues_ul_ibler})
    ${pcell_dl_dict_values}    Get Dictionary Values    ${ues_dl_tputs}
    ${ues_dl_tput}     Evaluate     [float(x['tput']) for x in ${pcell_dl_dict_values}]
    sort list     ${ues_dl_tput}
    ${ues_dl_bler}     Evaluate     [float(x['bler']) for x in ${pcell_dl_dict_values}]
    ${ues_dl_ibler}     Evaluate     [float(x['ibler']) for x in ${pcell_dl_dict_values}]
    ${normal_ue_dl_tput}    Set Variable   ${ues_dl_tput[-1]}
    ${redcap_ue_dl_tput}    Set Variable   ${ues_dl_tput[-2]}
    ${scell_dict_values}    Get Dictionary Values     ${scell_ue_dl_tputs}
    ${scell_tput}     Evaluate     [float(x['tput']) for x in ${scell_dict_values}]
    ${scell_bler}     Evaluate     [float(x['bler']) for x in ${scell_dict_values}]
    ${scell_ibler}     Evaluate     [float(x['ibler']) for x in ${scell_dict_values}]
    sort list     ${scell_tput}
    ${scell_tput}    Set Variable    ${scell_tput[-1]}
    ${scell_bler}    Evaluate    max(${scell_bler})
    ${scell_ibler}    Evaluate    max(${scell_ibler})
    Run Keyword And Continue On Failure    Should Be True    ${normal_ue_dl_tput}>=${1150}
    ...    msg=cell 301 dl tput for normal ue is lower than 1150Mbps.
    Run Keyword And Continue On Failure    Should Be True    ${redcap_ue_dl_tput}>=${133}
    ...    msg=cell 301 dl tput for normal ue is lower than 135Mbps.
    Run Keyword And Continue On Failure    Should Be True    ${normal_ue_ul_tput}>=${122}
    ...    msg=cell 301 ul tput for redcap ue is lower than 122Mbps.
    Run Keyword And Continue On Failure    Should Be True    ${redcap_ue_ul_tput}>=${11}
    ...    msg=cell 301 ul tput for redcap ue is lower than 11Mbps.
    Run Keyword And Continue On Failure    Should Be True    ${ul_bler}<=${0.02}    msg=pcell 301 bler is more than 2%
    Run Keyword And Continue On Failure    Should Be True    ${ul_ibler}<=${0.02}    msg=pcell 301 ibler is more than 2%
    Run Keyword And Continue On Failure    Should Be True    ${scell_tput}>=${1130}    msg=scell 311 tput is lower than 1130Mbps.
    Run Keyword And Continue On Failure    Should Be True    ${scell_bler}<=${0.02}    msg=scell 311 bler is more than 2%
    Run Keyword And Continue On Failure    Should Be True    ${scell_ibler}<=${0.02}    msg=scell 311 ibler is more than 2%



Create LNADJGNB On ENB Side
    [Arguments]   ${dist_name}=MRBTS-284284/LNBTS-284284/LNADJGNB-80
    ...           ${adjGnbId}=80
    ...           ${adjGnbIdLength}=24
    ...           ${administrativeState}=unlocked
    ...           ${cPlaneIpAddr}=10.71.200.130
    ...           ${cPlaneIpAddrCtrl}=oamControlled
    ...           ${mcc}=460
    ...           ${mnc}=2
    ...           ${mncLength}=2
    ...           ${enb_index}=0
    ...           ${connection}=enblte_${enb_index}
    Connect to eNB via ssl    connection=${connection}    enb_index=${enb_index}
    ${adjGnbId_dict}    Create Dictionary    dist_name=${dist_name}    parameter=adjGnbId    value=${adjGnbId}
    ${adjGnbIdLength_dict}    Create Dictionary    dist_name=${dist_name}    parameter=adjGnbIdLength    value=${adjGnbIdLength}
    ${administrativeState_dict}    Create Dictionary    dist_name=${dist_name}    parameter=administrativeState
    ...    value=${administrativeState}
    ${cPlaneIpAddr_dict}    Create Dictionary    dist_name=${dist_name}    parameter=cPlaneIpAddr    value=${cPlaneIpAddr}
    ${cPlaneIpAddrCtrl_dict}    Create Dictionary    dist_name=${dist_name}    parameter=cPlaneIpAddrCtrl    value=${cPlaneIpAddrCtrl}
    ${plmn_context}    Create Dictionary    mcc=${mcc}    mnc=${mnc}    mncLength=${mncLength}
    ${plmn_context}    Create List     ${plmn_context}
    ${plmnId_dict}    Create Dictionary    dist_name=${dist_name}    parameter=plmnId    value=${plmn_context}
    ${object_list}   Create List   ${adjGnbId_dict}   ${adjGnbIdLength_dict}   ${administrativeState_dict}   ${cPlaneIpAddr_dict}
    ...   ${plmnId_dict}    ${cPlaneIpAddrCtrl_dict}
    ${output}    coam_parameter.create_objects_delta    parameters=${object_list}     connection=${connection}
    perform_scf_delta_commission    delta_file=${output["updated"]}
    ...                             skip_parameter_relation_errors=False
    ...                             timeout=240
    ...                             connection=${connection}
    [Teardown]    Enblte close down    connection=${connection}


Delete LNADJGNB On ENB Side
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    [Arguments]   ${dist_name}=MRBTS-284284/LNBTS-284284/LNADJGNB-80
    ...           ${enb_index}=0
    ...           ${connection}=enblte_${enb_index}
    Connect to eNB via ssl    connection=${connection}    enb_index=${enb_index}
    ${empty_list}    Create List
    coam.perform_object_recommissioning    dist_name=${dist_name}    parameter=${empty_list}    operation=delete
    ...     skip_parameter_relation_errors=False    should_activate=True    timeout=240    connection=${connection}
    [Teardown]    Enblte close down    connection=${connection}

Lock And Unlock LNADJGNB ON ENB
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    [Arguments]     ${status}=unlocked
    ...             ${dist_name}=MRBTS-11213/LNBTS-11213/LNADJGNB-80
    ...             ${enb_index}=0
    ...             ${connection}=enblte_${enb_index}
    Connect to eNB via ssl    connection=${connection}    enb_index=${enb_index}
    enblte.perform_parameter_recommissioning       dist_name=${dist_name}
    ...                                            parameter=administrativeState
    ...                                            operation=update
    ...                                            value=${status}
    ...                                            connection=${connection}
    [Teardown]    Enblte close down    connection=${connection}

Check LTEENB Status On Gnb Side
    [Arguments]   ${eNodeBId}=284284
    ...           ${gnb_index}=0
    ...           ${connection}=GNB_OAM${gnb_index}
    ...           ${timeout}=600
    ...           ${status}=available
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    Log to console    Check X2 link status from GNB
    @{MOs_lteenb_a}    coam.get_managed_objects    class_name=LTEENB_A    connection=${connection}    timeout=${timeout}
    @{MOs_lteenb_r}    coam.get_managed_objects    class_name=LTEENB_R    connection=${connection}    timeout=${timeout}
    ${target_lteenb_a}     Evaluate    [x for x in ${MOs_lteenb_a} if x['parameters']['eNodeBId']==${eNodeBId}]
    ${target_lteenb_r}     Evaluate    [x for x in ${MOs_lteenb_r} if x['parameters']['eNodeBId']==${eNodeBId}]
#    Run Keyword And Continue On Failure    should be equal as strings    ${target_lteenb_a[0]['parameters']['x2LinkLock']}    unlocked
#    ...    msg=x2LinkLock is not in unlocked status in gnb side    ignore_case=${True}
    should be equal as strings    ${target_lteenb_r[0]['parameters']['x2LinkStatus']}    ${status}
    ...    msg=x2LinkStatus is not in ${status} status in gnb side    ignore_case=${True}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check LNADJGNB Status On Gnb Side
    [Arguments]   ${adjGnbId}=80
    ...           ${gnb_index}=0
    ...           ${connection}=GNB_OAM${gnb_index}
    ...           ${timeout}=600
    ...           ${status}=available
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    Log to console    Check X2 link status from GNB
    @{MOs_lteenb_a}    coam.get_managed_objects    class_name=LNADJGNB_A    connection=${connection}    timeout=${timeout}
    @{MOs_lteenb_r}    coam.get_managed_objects    class_name=LNADJGNB_R    connection=${connection}    timeout=${timeout}
    ${target_lteenb_a}     Evaluate    [x for x in ${MOs_lteenb_a} if x['parameters']['adjGnbId']==${adjGnbId}]
#    ${target_lteenb_r}     Evaluate    [x for x in ${MOs_lteenb_r} if x['parameters']['eNodeBId']==${eNodeBId}]
#    Run Keyword And Continue On Failure    should be equal as strings    ${target_lteenb_a[0]['parameters']['x2LinkLock']}    unlocked
#    ...    msg=x2LinkLock is not in unlocked status in gnb side    ignore_case=${True}
    should be equal as strings    ${target_lteenb_a[0]['parameters']['x2ToGnbLinkStatus']}    ${status}
    ...    msg=x2LinkStatus is not in ${status} status in gnb side    ignore_case=${True}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check all x2link Status On Gnb Side
    [Arguments]   ${gnb_index}=0
    ...           ${connection}=GNB_OAM${gnb_index}
    ...           ${timeout}=600
    ...           ${status}=available
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    Log to console    Check X2 link status from GNB
    @{MOs_lteenb_a}    coam.get_managed_objects    class_name=LTEENB_A    connection=${connection}    timeout=${timeout}
    @{MOs_lteenb_r}    coam.get_managed_objects    class_name=LTEENB_R    connection=${connection}    timeout=${timeout}
    ${target_lteenb_r}     Evaluate    [x for x in ${MOs_lteenb_r} if x['parameters']['x2LinkStatus']=='${status}']
    ${eNodeBId_list}    Evaluate    [x['parameters']['eNodeBId'] for x in ${target_lteenb_r}]
    [Return]    ${eNodeBId_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check x2link Status On Enb Side
    [Arguments]   ${adjGnbId}=80
    ...           ${enb_index}=0
    ...           ${connection}=enblte_${enb_index}
    ...           ${timeout}=600
    ...           ${status}=available
    Connect to eNB via ssl    connection=${connection}    enb_index=${enb_index}
    Log to console    Check X2 link status from ENB
    @{MOs_lteenb_a}    coam.get_managed_objects    class_name=LNADJGNB_A    connection=${connection}    timeout=${timeout}
    ${target_lteenb_a}     Evaluate    [x for x in ${MOs_lteenb_a} if x['parameters']['adjGnbId']==${adjGnbId}]
#    Run Keyword And Continue On Failure    should be equal as strings
#    ...    ${target_lteenb_a[0]['parameters']['administrativeState']}    unlocked
#    ...    msg=x2LinkLock is not in unlocked status in enb side    ignore_case=${True}
    Run Keyword And Continue On Failure    should be equal as strings
    ...    ${target_lteenb_a[0]['parameters']['x2ToGnbLinkStatus']}    ${status}
    ...    msg=x2LinkStatus is not in ${status} status in enb side    ignore_case=${True}
    [Teardown]    Enblte close down    connection=${connection}

Modify Parameter maxNumX2Links
    [Arguments]     ${value}=256    ${gnb_index}=0    ${connection}=GNB_OAM${gnb_index}
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[0].global_bts_id}
    ${param}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
        ...    'parameter':'maxNumX2Links','value':'${value}'}
    ${update_params}    Evaluate    [${param}]
    Update Params Through RestApi    params_need_to_modify=${update_params}    gnb_index=${gnb_index}   connection=${connection}
    ...    skip_parameter_relation_errors=${True}

Get Enb Upgrade Flag For Target SW Version
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${sw_version}
	${version_splitted}    Split String    ${sw_version}    _
	${tmp_program_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
	${is_trunk}    Run Keyword And Return Status    Should Contain Any    ${sw_version}    _9999_    _9990_
	${branch}    Set Variable If    ${is_trunk}    master    ${tmp_program_version}
    ${branch_num}    Run Keyword If    '${branch}'!='master'    Set Variable    ${branch.split("R")[0]}
    ${upgrade_flag}    Set Variable If    '${branch}'=='master'    true
    ...                                   '${branch}'!='master' and '${branch_num}'=='25'    true
    ...                                   '${branch}'!='master' and '${branch_num}'=='24'    false
    [Return]    ${upgrade_flag}