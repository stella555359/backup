#*** Settings ***
#Documentation    Author: tingting.1.liu@nokia-sbell.com
#Suite Setup      UUF_Common_Suite_Setup   is_commission=${False}
#Suite Teardown    robot_common_operations.Common Suite Teardown
#Test Teardown    robot_common_operations.Common Case Teardown
#Force Tags    5G_SISO    SG_06
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_common_keywords.robot
#
#
#*** Variables ***
#${search_text}   	Operational state
##ssh gNB
#${asik_addr}        ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
#${asik_username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
#${asik_password}    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
#${SW_build_path}    /home/ute/Downloads
#${target_version}
#${SBTS00_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS00_packages/
#${SBTS21B_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS21B_packages/
#${SBTS22R1_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS22R1_packages/
#${SBTS22R2_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS22R2_packages/
#${SBTS22R3_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS22R3_packages/
#${SBTS22R4_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS22R4_packages/
#${SBTS23R1_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS23R1_packages/
#${package_link}     https://esisoj70.emea.nsn-net.net/artifactory/mnp5g-central-public/System_Release/
#${package_version_1525-CA}      ${target_version}
#${enb_target_version}           SBTS24R1_ENB_0000_000682_000009
#
#*** Test Cases ***
#[1]E2E_gNB_SW_Upgrade_loops_with_WebUI
#    [Documentation]    Author:lei.jia@nokia-sbell.com
#    ...                2024.02.19: update with gnb sw upgrade only
#    [Tags]    T073_QC    T816_QC    T813_QC    T080_QC
#    [Setup]    Check TMO Gnb Ready And All Cell On Air
#    Gnb Upgrade Only
#    sleep  5min
#    Check TMO Gnb Ready And All Cell On Air
#    Gnb Rallback Only
#    sleep  5min
#    Check TMO Gnb Ready And All Cell On Air
#    [Teardown]   run keyword and ignore error    COAM Teardown gnb connections
#
##[1]E2E_gNB_SW_Upgrade_loops_with_WebUI_RFS
##    [Documentation]    Author:xiangsheng.chu@nokia-sbell.com
##    ...                update with gnb/enb sw upgrade
##    ...                enb only upgrade to ${enb_target_version}
##    [Tags]     T813_QC    T284_QC
##    [Setup]    Check TMO Gnb Ready And All Cell On Air
##    COAM Create log directory
##    Set Test Variable    ${upgrade_package_path}    /home/ute/${package_version_1525-CA}_release_BTSSM_downloadable_A54.zip
##    Set Test Variable    ${enb_upgrade_package_path}    /home/ute/${enb_target_version}_release_BTSSM_downloadable_A54.zip
##    log to console    --- start to download sw build from artifactory---
##    Run Keyword And Continue On Failure      Download SW Build from artifactory
##    Run Keyword And Continue On Failure      Download SW Build from artifactory     target_version=${enb_target_version}
##    FOR    ${enb_id}    IN RANGE    ${enb_length}
##        Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_id}    connection=enblte_${enb_id}
##        coam.update_software    sw_package=${enb_upgrade_package_path}    timeout=7200    connection=enblte_${enb_id}
##        Run Keyword And Ignore Error    Enblte close down    connection=enblte_${enb_id}
##        sleep  5min
##        Check GNB On Air And Unexpect Alarm Should Not Exist
##        Check ENB On Air And Unexpect Alarm Should Not Exist
##    END
##    wait until keyword succeeds     5 min   10 sec     Connect to gnb coam via ssl
##    coam.update_software    sw_package=${upgrade_package_path}    timeout=7200    connection=GNB_OAM
##    Run Keyword And Ignore Error    COAM Teardown gnb connections
##    sleep  5min
##    Check GNB On Air And Unexpect Alarm Should Not Exist
##    Check ENB On Air And Unexpect Alarm Should Not Exist
##    log to console    --- start to rallback---
##    Gnb And All Enb Rallback
##    sleep  5min
##    Check GNB On Air And Unexpect Alarm Should Not Exist
##    Check ENB On Air And Unexpect Alarm Should Not Exist
##    [Teardown]   run keyword and ignore error    COAM Teardown gnb connections
#
##[1]E2E_gNB_SW_Upgrade_loops_with_WebUI
##    [Tags]    T073_QC    T816_QC    T813_QC    T080_QC
##    [Setup]    Check TMO Gnb Ready And All Cell On Air
##    Set Test Variable    ${upgrade_package_path}    /home/ute/${package_version_1525-CA}_release_BTSSM_downloadable_A54.zip
##    log to console    --- start to upgrade---
##    wait until keyword succeeds     5 min   10 sec     Connect to gnb coam via ssl
##    coam.update_software    sw_package=${upgrade_package_path}    timeout=7200    connection=GNB_OAM
##    Run Keyword And Ignore Error    COAM Teardown gnb connections
##    FOR    ${enb_id}    IN RANGE    ${enb_length}
##        Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_id}    connection=enblte_${enb_id}
##        coam.update_software    sw_package=${upgrade_package_path}    timeout=7200    connection=enblte_${enb_id}
##        Run Keyword And Ignore Error    Enblte close down    connection=enblte_${enb_id}
##    END
##    sleep  10min
##    Check TMO Gnb Ready And All Cell On Air
##    log to console    --- start to rallback---
##    wait until keyword succeeds     5 min   10 sec     Connect to gnb coam via ssl
##    coam.rollback_software    timeout=7200    connection=GNB_OAM
##    Run Keyword And Ignore Error    COAM Teardown gnb connections
##    FOR    ${enb_id}    IN RANGE    ${enb_length}
##        Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_id}    connection=enblte_${enb_id}
##        coam.rollback_software    timeout=7200    connection=enblte_${enb_id}
##        Run Keyword And Ignore Error    Enblte close down    connection=enblte_${enb_id}
##    END
##    sleep  10min
##    Check TMO Gnb Ready And All Cell On Air
##    [Teardown]   Run Keywords    run keyword and ignore error    COAM Teardown gnb connections   AND
##    ...    Run Keyword And Ignore Error    Enblte close down    connection=${0}   AND
##    ...    Run Keyword And Ignore Error    Enblte close down    connection=${1}
