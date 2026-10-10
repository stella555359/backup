*** Settings ***
Documentation    TMO Automation for SISO without L3 call cases
...              Author: xiangsheng.chu@nokia-sbell.com
Suite Setup    UUF_Common_Suite_Setup
#Test Teardown    robot_common_operations.Common Suite Teardown
Suite Teardown    UUF_Common_Suite_Teardown
Force Tags    5G_SISO    SG_06     CA_VRF_HAZ4
...    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_common_keywords.robot

*** Variables ***
${Perform Special RU Reset with OAM KPI}         Perform Special RU Reset with OAM KPI
${Perform BBMOD From All RU Reset with OAM KPI}       Perform BBMOD From All RU Reset with OAM KPI
${Perform Lock Or Unlock Single Cell On Special RU with OAM KPI}       Perform Lock Or Unlock Single Cell On Special RU with OAM KPI
${Perform Block Or Unblock Single Cell On Special RU with OAM KPI}     Perform Block Or Unblock Single Cell On Special RU with OAM KPI
${Perform Reset with HWF deletion}         Perform Reset with HWF deletion
${Perform Reset with HWF deletion On LTE}         Perform Reset with HWF deletion On LTE
${Perform Reset With HWF Deletion Energy Saving Phase}    Perform Reset With HWF Deletion Energy Saving Phase
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
${enb_target_sw}    ${enb_target_ver}

*** Test Cases ***
[1]E2E_TL_Capacity_Module_Reset_with_OAM_KPI
     [Tags]    T080_QC_trunk    T813_QC     T073_QC   T816_QC     T080_QC_24R1
     [Setup]    TMO_Common_Case_Setup_OAM    is_commission=${False}
     CSV4ALL_Common_Keywords.E2E_TL_Capacity_Module_Reset_with_OAM_KPI
     [Teardown]    Run Keywords    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
     ...                           Run Keyword If Test Failed    Collect Snapshot Log in gnb and enb    timeout=${2400}

[1]E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
     [Tags]    T080_QC_trunk     T073_QC    T816_QC    T080_QC_24R1
     [Setup]    TMO_Common_Case_Setup_OAM    swconfig_flag=special_flag
     CSV4ALL_Common_Keywords.E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
     [Teardown]     Run Keywords    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
     ...                            Run Keyword If Test Failed    Collect Snapshot Log in gnb and enb    timeout=${2400}    AND
     ...                            Backup And Delete Parameter Of Swconfig File    swconfig_modify=@{delete_flag}

[1]E2E_TL_RU_Reset_with_OAM_KPI
     [Tags]    T080_QC_trunk    T813_QC     T073_QC   T816_QC
     [Setup]    TMO_Common_Case_Setup_OAM
     CSV4ALL_Common_Keywords.E2E_TL_RU_Reset_with_OAM_KPI
     [Teardown]    Run Keywords    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
     ...                    Run Keyword If Test Failed    Collect Snapshot Log in gnb and enb    timeout=${2400}

[1]E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
     [Tags]    T080_QC_trunk    T813_QC       T073_QC  T816_QC
     [Setup]    TMO_Common_Case_Setup_OAM
     CSV4ALL_Common_Keywords.E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
     [Teardown]    Run Keywords    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
     ...                           Run Keyword If Test Failed    Collect Snapshot Log in gnb and enb    timeout=${2400}

[1]E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
     [Tags]    T080_QC_trunk    T813_QC     T073_QC   T816_QC
     [Setup]    TMO_Common_Case_Setup_OAM
     CSV4ALL_Common_Keywords.E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
     [Teardown]    Run Keywords    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
     ...                           Run Keyword If Test Failed    Collect Snapshot Log in gnb and enb    timeout=${2400}

[1]E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
     [Tags]    T080_QC_trunk     T073_QC     T816_QC
     [Setup]    TMO_Common_Case_Setup_OAM
     CSV4ALL_Common_Keywords.E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
     [Teardown]    Run Keywords    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
     ...                          Run Keyword If Test Failed    Collect Snapshot Log in gnb and enb    timeout=${2400}

[1]E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
     [Tags]    T080_QC_trunk     T073_QC     T816_QC
     [Setup]    TMO_Common_Case_Setup_OAM
     CSV4ALL_Common_Keywords.E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
     [Teardown]    Run Keywords    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
     ...                           Run Keyword If Test Failed    Collect Snapshot Log in gnb and enb    timeout=${2400}

[1]E2E_TL_Delta_Commissioning_With_Site_Reset_Required
     [Tags]    T080_QC_trunk    T813_QC     T073_QC    T816_QC
     [Setup]    TMO_Common_Case_Setup_OAM
     CSV4ALL_Common_Keywords.E2E_TL_Delta_Commissioning_With_Site_Reset_Required
     [Teardown]    Run Keywords    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
     ...                           Run Keyword If Test Failed    Collect Snapshot Log in gnb and enb    timeout=${2400}


[1]E2E_TL_Delta_Commissioning_With_GSM_Rat_Reset
     [Tags]    T080_QC_trunk      T073_QC
     [Setup]    TMO_Common_Case_Setup_OAM
     E2E_TL_Delta_Commissioning_With_GSM_Rat_Reset
     [Teardown]     Run Keywords    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
     ...                            Run Keyword If Test Failed    Collect Snapshot Log in gnb and enb    timeout=${2400}


[1]E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
     [Tags]    T080_QC_trunk    T073_QC
     [Setup]    TMO_Common_Case_Setup_OAM    is_commission=${False}
     CSV4ALL_Common_Keywords.E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
     [Teardown]     Run Keywords    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
     ...                            Run Keyword If Test Failed    Collect Snapshot Log in gnb and enb    timeout=${2400}

[1]E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
     [Tags]    T080_QC_trunk    T813_QC       T073_QC   T816_QC
     [Setup]    TMO_Common_Case_Setup_OAM
     CSV4ALL_Common_Keywords.E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
     [Teardown]     Run Keywords    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
     ...                            Run Keyword If Test Failed    Collect Snapshot Log in gnb and enb    timeout=${2400}


[1]E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
     [Tags]    T080_QC_trunk    T813_QC     T073_QC    T816_QC
     [Setup]    TMO_Common_Case_Setup_OAM
     E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
     [Teardown]    Run Keywords    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
     ...                           Run Keyword If Test Failed    Collect Snapshot Log in gnb and enb    timeout=${2400}

[1]E2E_TL_Cell_Block_Unblock_GSM_with_OAM_KPI
     [Tags]    T080_QC_trunk     T073_QC     T816_QC
     [Setup]    TMO_Common_Case_Setup_OAM
     CSV4ALL_Common_Keywords.E2E_TL_Cell_Block_Unblock_GSM_with_OAM_KPI
     [Teardown]    Run Keywords    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
     ...                           Run Keyword If Test Failed    Collect Snapshot Log in gnb and enb    timeout=${2400}

[1]E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_WebUI
     [Tags]    T080_QC_trunk_upgrade    T073_QC_upgrade     T080_QC_24R1_upgrade
     [Setup]    TMO_Common_Case_Setup_OAM    
     CSV4ALL_Common_Keywords.E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_WebUI
     [Teardown]    Run Keywords   Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown
     ...    AND    run keyword and ignore error    COAM Teardown gnb connections
     ...    AND    run keyword and ignore error    Run Keyword If Test Failed    Collect Snapshot Log in gnb and enb    timeout=${2400}

[1]E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_WebUI_and_L3_call
     [Tags]    T080_QC_trunk_upgrade   T073_QC_upgrade
     [Setup]    TMO_Common_Case_Setup_OAM
     CSV4ALL_Common_Keywords.E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_WebUI_and_L3_call
     [Teardown]    Run Keywords   Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown
     ...    AND    run keyword and ignore error    COAM Teardown gnb connections
     ...    AND    run keyword and ignore error    Run Keyword If Test Failed    Collect Snapshot Log in gnb and enb    timeout=${2400}

5603156_E2E_TL_Site_Reset_without_HWF_with_OAM_KPI_energy_saving_phase
     [Tags]    T080_QC_trunk     T073_QC    T816_QC    T080_QC_24R1    Energy_saving
     [Setup]    TMO_Common_Case_Setup_OAM    swconfig_flag=special_flag
     CSV4ALL_Common_Keywords.5603156_E2E_TL_Site_Reset_without_HWF_with_OAM_KPI_energy_saving_phase
     [Teardown]     Run Keywords    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
     ...                            Run Keyword If Test Failed    Collect Snapshot Log in gnb and enb    timeout=${2400}    AND
     ...                            Backup And Delete Parameter Of Swconfig File    swconfig_modify=@{delete_flag}

5603157_gNB_enb_SW_Upgrade_loops_with_WebUI_RFS_after_cells_enter_energysaving_gNB_1st
    [Tags]    T080_QC_trunk     T073_QC    T816_QC    T080_QC_24R1    Energy_saving
    [Setup]    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    gNB_enb_SW_Upgrade_loops_with_WebUI_RFS_Precondition
    Run    '/opt/btslog/btslog_launcher' stop_udplog
    FOR    ${i}    IN RANGE    ${1}
         Log To Console    ${\n}INFO:-- start to upgrade gnb/enb time_${i}--
         gNB_enb_SW_Upgrade_loops_with_WebUI_RFS_after_cells_enter_energysaving
    END
    [Teardown]   Run Keywords    Run    '/opt/btslog/btslog_launcher' start_udplog    AND
    ...    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
    ...                          run keyword and ignore error    COAM Teardown gnb connections    AND
    ...                          run keyword and ignore error    Run Keyword If Test Failed    Collect Snapshot Log in gnb and enb
    ...                                                                                            timeout=${2400}

5603157_gNB_enb_SW_Upgrade_loops_with_WebUI_RFS_after_cells_enter_energysaving_LTE_1st
    [Tags]    T080_QC_trunk     T073_QC    T816_QC    T080_QC_24R1    Energy_saving
    [Setup]    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    ${whether_do_lte_first}    Set Variable    ${True}
    gNB_enb_SW_Upgrade_loops_with_WebUI_RFS_Precondition    whether_do_lte_first=${whether_do_lte_first}
    Run    '/opt/btslog/btslog_launcher' stop_udplog
    FOR    ${i}    IN RANGE    ${1}
         Log To Console    ${\n}INFO:-- start to upgrade gnb/enb time_${i}--
         gNB_enb_SW_Upgrade_loops_with_WebUI_RFS_after_cells_enter_energysaving    whether_do_lte_first=${whether_do_lte_first}
    END
    [Teardown]   Run Keywords    Run    '/opt/btslog/btslog_launcher' start_udplog    AND
    ...    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
    ...                          run keyword and ignore error    COAM Teardown gnb connections    AND
    ...                          run keyword and ignore error    Run Keyword If Test Failed    Collect Snapshot Log in gnb and enb
    ...                                                                                            timeout=${2400}

5603158_gNB_enb_SW_Upgrade_loops_with_WebUI_after_cells_enter_energysaving
     [Tags]    T080_QC_trunk_upgrade    T073_QC_upgrade     T080_QC_24R1_upgrade
     [Setup]    TMO_Common_Case_Setup_OAM
     CSV4ALL_Common_Keywords.5603158_gNB_enb_SW_Upgrade_loops_with_WebUI_after_cells_enter_energysaving
     [Teardown]    Run Keywords
     ...    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
     ...    run keyword and ignore error    COAM Teardown gnb connections    AND
     ...    run keyword and ignore error    Run Keyword If Test Failed    Collect Snapshot Log in gnb and enb    timeout=${2400}    AND
     ...    run keyword and ignore error    Update Related Parameters For Energy Saving    Duration=10    Hour=${recover_hour}
     ...                                        Minute=${recover_minute}    lbpsCellList_num=${recover_lbpsCellList_num}
     ...                                        lbpsCellPeriodList_num=${recover_lbpsCellPeriodList_num}    AND
     ...    run keyword and ignore error    Check TMO Gnb Ready And All Cell On Air

5603154_E2E_TL_Site_Reset_without_HWF_with_OAM_KPI_on_LTE
     [Tags]    T813     T284    T282
     [Setup]    TMO_Common_Case_Setup_OAM    is_commission=${False}
     Check TMO Gnb Ready And All Cell On Air
     Verify All Enbs Cell On Air
     Check GNB Whether Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}
     Check ENB Whether Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}
     log to console    --- start to commission---
     ${is_commission_gnb}    ${is_commission_enb}    ${version_in_gnb}    ${version_in_enb}
     ...    Check GNB And Enb Whether Need To Load SCF
     UUF_common_keywords.Need To Do SCF Commission    scf_name=${tl_prefix}_gNB_${version_in_gnb}.xml
     ...                                              is_commission=${is_commission_gnb}
     ...                                              tdd_enb_scf_name=${tl_prefix}_FDDeNB_${version_in_enb}.xml
     ...                                              is_tdd_enb_commission=${is_commission_enb}
     ...                                              timeout_for_commission=20 min
     Run Keyword If    ${is_commission_gnb}    Check GNB Whether Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}
     Run Keyword If    ${is_commission_enb}    Check ENB Whether Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}
     ENB Backup and Modify swconfig file    swconfig_modify=@{SWCONFIG_special_flag}
     TMO_common_keywords_part_two.Verify Test In Loop     should_be_reported=False
     ...                test_keyword=${Perform Reset with HWF deletion On LTE}
     ...                iteration_number=1
     [Teardown]     Run Keywords    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
     ...                            Run Keyword If Test Failed    Collect Snapshot Log in gnb and enb    timeout=${2400}    AND
     ...                            ENB Backup And Delete Parameter Of Swconfig File    swconfig_modify=@{delete_flag}
