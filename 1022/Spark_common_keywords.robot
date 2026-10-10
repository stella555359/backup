*** Settings ***
Documentation    SigSpark common keyword
...              Author: Chen Jun
...              Contact: jun.8.chen@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

*** Variables ***
${ue_logpath}     None
${ue_logname}     TA_LOG
#${logpc_ip}       ${tl.ues[4].ssh_connection_details.addr}
#${logpc_usrname}    ${tl.ues[4].ssh_connection_details.username}
#${logpc_passwd}    ${tl.ues[4].ssh_connection_details.password}
${exportReport_pc_logpath_tmp}      C:/KPI

*** Keywords ***
Start Prepare UE
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_type}=huawei_sigspark    ${ue_index}=${0}    ${ue_num_input}=${None}
    power_ue.Prepare UE    ue_type=${ue_type}
    ...                    ue_index=${ue_index}
    ...                    ue_num_input=${ue_num_input}

Restart App
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    ...                Documentation:Restart Spark APP and disable data service
    [Arguments]    ${ue_index}=${0}
    ...            ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...            ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...            ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...            ${alias}=cpc_tmp
    Wait Until Keyword Succeeds    5min    20s    csn.connect_to    hostname=${cpc_ip}    username=${cpc_usrname}
    ...    password=${cpc_passwd}    alias=${alias}
    ${output1}    csn.execute    command=taskkill /f /im SSSRXX.exe    connection=${alias}
    ${output2}    csn.execute    command=taskkill /f /im adb.exe    connection=${alias}
    ${output3}    csn.execute    command=taskkill /f /im Spark.exe    connection=${alias}
    ${output4}    csn.execute    command=schtasks /end /tn spark    connection=${alias}
    ${output5}    csn.execute    command=schtasks /delete /tn spark /f    connection=${alias}
#    ${output6}    csn.execute
#    ...    command=schtasks /create /tn spark /sc once /tr '${tl.ues[${ue_index}].server_dir}' /st 00:00 /RL highest /f
#    ...    connection=${alias}
#    ${output7}    csn.execute    command=schtasks /run /tn spark    connection=${alias}
#    Sleep    60 sec
    [Teardown]    csn.disconnect    connection=${alias}

Start UE Attach
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    spark.power_off    ue_alias=${ue_alias}
    Sleep    5s
    spark.power_on    ue_alias=${ue_alias}

Start UE Attach And Enable Data Service
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    spark.power_off    ue_alias=${ue_alias}
    Sleep    5s
    spark.power_on    ue_alias=${ue_alias}
    spark.enable_ue_data_service    ue_alias=${ue_alias}

Spark Start UE Log
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    spark.start_log    ue_alias=${ue_alias}

Start L3 Traffic
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_type}=huawei_sigspark    ${ul_throughput}=5MKbits/sec    ${dl_throughput}=10MKbits/sec
    ...            ${duration}=600    ${ue_index}=${0}    ${apn_address}=wap2nokiacom    ${ue_mode}=SA
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}
    ...    duration=${duration}    dt_name=DT_ul    apn_address=${apn_address}    ue_mode=${ue_mode}  ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}
    ...    duration=${duration}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}  ue_index=${ue_index}

Start DL Traffic
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_type}=huawei_sigspark    ${dl_throughput}=5MKbits/sec    ${duration}=5
    ...            ${ue_index}=${0}    ${apn_address}=wap2nokiacom    ${ue_mode}=SA
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}
    ...    duration=${duration}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}

Stop L3 Traffic
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_type}=huawei_sigspark    ${ue_index}=${0}    ${apn_address}=wap2nokiacom    ${ue_mode}=SA
    Run Keyword And Continue On Failure    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    dt_name=DT_ul
    ...        apn_address=${apn_address}    ue_mode=${ue_mode}     ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}
    ...                      ue_index=${ue_index}

Stop DL Traffic
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_type}=huawei_sigspark    ${ue_index}=${0}    ${apn_address}=wap2nokiacom    ${ue_mode}=SA
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}

Start UE Detach
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    spark.power_off    ue_alias=${ue_alias}

Spark Stop UE Log
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    ...            ${log_name}=${TS_CASE_LOG_PATH}/uelog_sigspark_UE${ue_index}.xml    ${filter}=Event_Auto
    spark.stop_log    ue_alias=${ue_alias}    logname=${log_name}    filter=${filter}

Create PDU Session
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...                Description: Create single PDU.
    [Arguments]    ${ue_index}=${0}    ${apn}=${tl.core.pdns[0].apn}
    Log To Console    INFO:-- start to create PDU --
    ${ue_pdu1_ip}    spark.create_pdu_session    ue_alias=UE_${ue_index}    id=1    apn=${apn}
    [Return]    ${ue_pdu1_ip}

Release PDU Session
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...                Description: Release single PDU.
    [Arguments]    ${ue_index}=${0}
    Log To Console    INFO:-- start to release PDU --
    spark.release_pdu_session    ue_alias=UE_${ue_index}    id=1

Create Multi PDU Session
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...                Description: Create Multi PDUs.
    [Arguments]    ${ue_index}=${0}
    Log To Console    INFO:-- start to create PDU_1 --
    Run Keyword And Continue On Failure    spark.enable_ue_data_service    ue_alias=UE_${ue_index}
    Log To Console    INFO:-- start to create PDU_2 --
    ${ue_pdu2_ip}    Run Keyword And Continue On Failure    spark.create_pdu_session    ue_alias=UE_${ue_index}    id=2
    ...    apn=${tl.core.pdns[1].apn}
    [Return]    ${ue_pdu2_ip}

Release Multi PDU Session
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...                Description: Release Multi PDUs.
    [Arguments]    ${ue_index}=${0}
    Log To Console    INFO:-- start to release PDU_2 --
    Run Keyword And Continue On Failure    spark.release_pdu_session    ue_alias=UE_${ue_index}    id=2
    Log To Console    INFO:-- start to release PDU_1 --
    Run Keyword And Continue On Failure    spark.disable_ue_data_service    ue_alias=UE_${ue_index}

Prepare UEs
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_range}
    FOR    ${ue_no}    IN RANGE    ${ue_range}
        Start Prepare UE    ue_index=${ue_no}
    END

UEs Attach
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_range}
    FOR    ${ue_no}    IN RANGE    ${ue_range}
        Log To Console    INFO:-- statr UE_${ue_no} attach --
        Run Keyword And Continue On Failure    Start UE Attach    ue_index=${ue_no}
        Run Keyword And Continue On Failure    spark.enable_ue_data_service    ue_alias=UE_${ue_no}
    END

Get Parameter Value
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    ...                Param ${param}: <list>, like as ["NR SSB RSRP[dBm]"]
    [Arguments]    ${param}    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    ${rsrp}    spark.get_parm_value_on_ue    param=${param}    ue_alias=${ue_alias}
    [Return]    ${rsrp}

Send AT Command
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    ...                command ${command}: <str>, like as AT+CGDCONT?
    [Arguments]    ${command}    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    ${apn}    spark.send_at_command_on_ue    command=${command}    ue_alias=${ue_alias}
    [Return]    ${apn}

Modify APN
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${apn_address}=${tl.core.pdns[0].apn}    ${except_apn}=mdrb.nokia.com
    ...            ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    ${status}    Run Keyword And Return Status    Should Contain    ${apn_address}    nokiacom
    ${wap_name}    Run Keyword If    ${status}    Get Substring    ${apn_address}    0    4
    ${apn_address}    Set Variable If    ${status}    ${wap_name}.nokia.com    ${apn_address}
    ${status}    Run Keyword And Return Status    Should Contain    ${except_apn}    nokiacom
    ${wap_name}    Run Keyword If    ${status}    Get Substring    ${except_apn}    0    4
    ${except_apn}    Set Variable If    ${status}    ${wap_name}.nokia.com    ${except_apn}
    ${origin_apn}    Send AT Command    command=AT+CGDCONT?    ue_index=${ue_index}
    Should Contain    ${origin_apn}    OK
    ${output}    Split String    ${origin_apn}    \r\n
    FOR    ${i}    IN    @{output}
        ${apn_id}    Set Variable    ${i.split(': ')[-1].split(',')[0]}
        ${ip_type}    Set Variable    ${i.split(',')[1]}
        Run Keyword If    '${apn_address}' in '${i}'    Exit For Loop
    END
    ${cmd}    Set Variable   AT+CGDCONT=${apn_id},${ip_type},"${except_apn}"
    ${new_apn}    Send AT Command    command=${cmd}    ue_index=${ue_index}
    Should Contain    ${new_apn}    OK
    ${verify_apn}    Send AT Command    command=AT+CGDCONT?    ue_index=${ue_index}
    Should Contain    ${verify_apn}    ${except_apn}

Make Vonr Call For Model
    [Documentation]   tingting.1.liu@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}     ${ue_alias}=UE_${ue_index}
    spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=ATD004488;

Hang Up Vonr Call For Model
    [Documentation]   tingting.1.liu@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}     ${ue_alias}=UE_${ue_index}
    spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=ATH

Make Vonr Call From UE1 To UE2
    [Documentation]   tingting.1.liu@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}     ${ue_alias}=UE_${ue_index}   ${ue_phone_number}=ATD008618001006180;
    spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=${ue_phone_number}

UE_Answer_Vonr_call
    [Documentation]   tingting.1.liu@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}     ${ue_alias}=UE_${ue_index}
    spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=ata

Start UE Attach in X65 multi UE x65
    [Documentation]    Author:xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    Run Keyword And Ignore Error    spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+CFUN=0
    Sleep    5s
    Run Keyword And Ignore Error    spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+CFUN=1
    Sleep    5s

Start UL Traffic with spark UE
    [Documentation]    Author:xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${ue_type}=huawei_sigspark    ${ul_throughput}=5MKbits/sec    ${dl_throughput}=10MKbits/sec
    ...            ${duration}=600    ${ue_index}=${0}    ${apn_address}=wap2nokiacom    ${ue_mode}=SA    ${buffer_size}=1024
    ...            ${ue_alias}=UE_${ue_index}
    ...            ${protocol}=UDP    ${multidrb_QoS_dest}=${None}
    ...            ${connection_type}=app
    ${protocol}=    Convert To Uppercase    ${protocol}
    ${default_port}    set variable    ${tl.ues[${ue_index}].iperf_details.port}
    spark.start_data_transfer    ue_alias=${ue_alias}    direction=ul     dt_name=DT_ul
    ...                          duration=${duration}    throughput=${ul_throughput}  iperf_port=${default_port}
    ...                          protocol=${protocol}    multidrb_QoS_dest=${multidrb_QoS_dest}
    ...                          connectiontype=${connection_type}     apn_address=${apn_address}
    ...                          ue_mode=${ue_mode}    buffer_size=${buffer_size}

Spark Start multi UE Log
    [Documentation]    Author:xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${logpath}=${ue_logpath}    ${logname}=${ue_logname}      ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    sparkMultiUE.start_all_ues_log   ue_alias=${ue_alias}    logpath=${logpath}    logname=${logname}

Spark Stop multi UE Log
    [Documentation]    Author:xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    sparkMultiUE.stop_all_ues_log    ue_alias=${ue_alias}

Spark multiUE ExportReport with Logfiles
    [Documentation]    Author:xiangsheng.chu@nokia-sbell.com
    [Arguments]      ${ue_logname}      ${ue_logpath}   ${ReportName}    ${ReportGenerationPath}
    ...              ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    ...             ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...             ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...             ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    ${output}    csn.execute    command=cd /cygdrive/c/tmp/uelog/AUTO/${ue_logname};ls -l
    ...          connection=cpc_${ue_index}
    ${ue_log_name}    Get Regexp Matches    ${output}    (\\S+).saf
    ${ue_log_list}    create list
    FOR    ${ue_log_tmp}    IN    @{ue_log_name}
        ${ue_log_list_tmp}    Catenate    SEPARATOR=/    ${ue_logpath}     ${ue_log_tmp}
        append to list    ${ue_log_list}    ${ue_log_list_tmp}
    END
    sparkMultiUE.ExportReport     ue_alias=UE_${ue_index}    ReportName=${ReportName}    ReportGenerationPath=${ReportGenerationPath}
    ...                           OpenReportResult=false      Logfiles=${ue_log_list}
    [Return]    ${ue_log_list}
    [Teardown]  Run Keyword And Ignore Error    csn.disconnect   connection=cpc_${ue_index}

Spark signal Ue ExportReport with Logfiles
    [Documentation]    Author:xiangsheng.chu@nokia-sbell.com
    [Arguments]      ${ue_logname}      ${ue_logpath}   ${ReportName}    ${ReportGenerationPath}
    ...              ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    ...             ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...             ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...             ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    ${output}    csn.execute    command=cd /cygdrive/c/tmp/uelog/AUTO/${ue_logname};ls -l
    ...          connection=cpc_${ue_index}
    ${ue_log_name}    Get Regexp Matches    ${output}    (\\S+).saf
    ${ue_log_list}    create list
    FOR    ${ue_log_tmp}    IN    @{ue_log_name}
        ${ue_log_list_tmp}    Catenate    SEPARATOR=/    ${ue_logpath}     ${ue_log_tmp}
        append to list    ${ue_log_list}    ${ue_log_list_tmp}
    END
    spark.ExportReport     ue_alias=UE_${ue_index}    ReportName=${ReportName}    ReportGenerationPath=${ReportGenerationPath}
    ...                           OpenReportResult=false      Logfiles=${ue_log_list}
    [Return]    ${ue_log_list}
    [Teardown]  Run Keyword And Ignore Error    csn.disconnect   connection=cpc_${ue_index}

#Create result file path to server PC
#    [Documentation]    Author:xiangsheng.chu@nokia-sbell.com
#    [Arguments]     ${pc_logpath}    ${test_id}=5603052
#    ...             ${ute_ip}=${tl.test_pc.default_ssh_connection_details.addr}
#    ...             ${ute_name}=${tl.test_pc.default_ssh_connection_details.username}
#    ...             ${ute_password}=${tl.test_pc.default_ssh_connection_details.password}
#    Connect to control pc    cpc_ip=${logpc_ip}    cpc_usrname=${logpc_usrname}    cpc_passwd=${logpc_passwd}    alias=logpc
#    ${current_stream_version}    Common_setup_and_teardown.Get Active SW Version Based On Stream Version
#    ${current_stream_version}    Set Variable If    '${current_stream_version}'=='master'     24R3       ${current_stream_version}
#    ${pc_logpath_23R4_GA}    Catenate    SEPARATOR=/    ${pc_logpath}     24R1GA
#    ${pc_logpath_cu_version_0_tmp}    Catenate    SEPARATOR=_    ${current_stream_version}     0
#    ${pc_logpath_cu_version_1_tmp}    Catenate    SEPARATOR=_    ${current_stream_version}     1
#    ${pc_logpath_cu_version_0}    Catenate    SEPARATOR=/    ${pc_logpath}     ${pc_logpath_cu_version_0_tmp}
#    ${pc_logpath_cu_version_1}    Catenate    SEPARATOR=/    ${pc_logpath}     ${pc_logpath_cu_version_1_tmp}
#    csn.execute    command=mkdir ${pc_logpath}     connection=logpc
#    Run keyword If    '${test_id}'=='5603052' or '${test_id}'=='5603152'    csn.execute    command=mkdir ${pc_logpath_23R4_GA}
#    ...               connection=logpc
#    Run keyword If    '${test_id}'=='5603052' or '${test_id}'=='5603152'     csn.execute    command=mkdir ${pc_logpath_cu_version_0}
#    ...               connection=logpc
#    Run keyword If    '${test_id}'=='5603052' or '${test_id}'=='5603152'     csn.execute    command=mkdir ${pc_logpath_cu_version_1}
#    ...               connection=logpc
#    [Return]    ${pc_logpath_23R4_GA}      ${pc_logpath_cu_version_0}      ${pc_logpath_cu_version_1}
#    [Teardown]    Run Keyword and Ignore Error    csn.disconnect    connection=logpc

#Upload result file from ute to server PC
#    [Documentation]    Author:xiangsheng.chu@nokia-sbell.com
#    [Arguments]     ${filepath_in_ute}=None
#    ...             ${cpc_ip}=10.57.150.11
#    ...             ${cpc_usrname}=MN5GRAN
#    ...             ${cpc_passwd}=nokia123@
#    ...             ${ute_ip}=${tl.test_pc.default_ssh_connection_details.addr}
#    ...             ${ute_name}=${tl.test_pc.default_ssh_connection_details.username}
#    ...             ${filepath_in_ute_3052_0}=None
#    ...             ${filepath_in_ute_3052_1}=None
#    ...             ${filepath_in_ute_3052_2}=None
#    ...             ${pc_logpath}=None
#    ...             ${pc_logpath_23R4_GA}=None
#    ...             ${pc_logpath_cu_version_0}=None
#    ...             ${pc_logpath_cu_version_1}=None
#    ...             ${test_id}=5603052
#    Connect to control pc    cpc_ip=${logpc_ip}    cpc_usrname=${logpc_usrname}    cpc_passwd=${logpc_passwd}    alias=logpc
#    ${scp_cmd}    set variable    scp -r ${ute_name}@${ute_ip}:${filepath_in_ute} ${pc_logpath} &
#    ${scp_cmd_3052_0}    set variable    scp -r ${ute_name}@${ute_ip}:${filepath_in_ute_3052_0} ${pc_logpath_23R4_GA} &
#    ${scp_cmd_3052_1}    set variable    scp -r ${ute_name}@${ute_ip}:${filepath_in_ute_3052_1} ${pc_logpath_cu_version_0} &
#    ${scp_cmd_3052_2}    set variable    scp -r ${ute_name}@${ute_ip}:${filepath_in_ute_3052_2} ${pc_logpath_cu_version_1} &
#    Run keyword If    '${test_id}'!='5603052'      ssh.send_command    command=${scp_cmd}    connection=logpc
#    sleep    5s    reason= scp start!!
#    Run keyword If    '${test_id}'=='5603052' or '${test_id}'=='5603152'   ssh.send_command   command=${scp_cmd_3052_0}    connection=logpc
#    sleep    5s    reason= scp start!!
#    Run keyword If    '${test_id}'=='5603052' or '${test_id}'=='5603152'   ssh.send_command   command=${scp_cmd_3052_1}    connection=logpc
#    sleep    5s    reason= scp start!!
#    Run keyword If    '${test_id}'=='5603052' or '${test_id}'=='5603152'   ssh.send_command   command=${scp_cmd_3052_2}    connection=logpc
#    sleep    5s    reason= scp start!!
#    FOR    ${i}    IN RANGE    1    ${50}
#          ssh.send_command    command=ps -ef | grep scp    connection=logpc
#          ${scp_process}    ssh.read_output    connection=logpc
#          ${result}     run keyword and return status  should not contain    ${scp_process}    scp
#          Exit For Loop IF    "${result}" == "${True}"
#          sleep    20s
#    END
#    [Teardown]    Run Keyword and Ignore Error    csn.disconnect    connection=logpc

Spark Start UE Log with special logpath
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${logpath}=${ue_logpath}    ${logname}=${ue_logname}      ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    spark.start_log_with_special_logpath    ue_alias=${ue_alias}      logpath=${logpath}    logname=${logname}

Create ExportReport logpath in UE control PC
    [Documentation]    Author:xiangsheng.chu@nokia-sbell.com
    [Arguments]     ${test_id}=5603052
    ...             ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    ...             ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...             ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...             ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    Connect to control pc    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}    alias=uepc
    ${case_time}=    Get Current Date    result_format=%Y%m%d%H%M%S
#    ${test_case_id}    Set Variable If     '${test_case_id}'=='TOL'     8311       ${test_case_id}
    ${pc_logname}    Catenate    SEPARATOR=_    ${package_version_1525-CA}     ${case_time}
    ${pc_logname}    Catenate    SEPARATOR=_    ${pc_logname}      ${test_id}
    ${exportReport_pc_logpath_cygwin}    Catenate    SEPARATOR=/    /cygdrive/c/KPI     ${pc_logname}
    csn.execute    command=mkdir ${exportReport_pc_logpath_cygwin}     connection=uepc
    ${exportReport_pc_logpath_windows}    Catenate    SEPARATOR=/    ${exportReport_pc_logpath_tmp}      ${pc_logname}
    [Return]    ${exportReport_pc_logpath_windows}      ${exportReport_pc_logpath_cygwin}
    [Teardown]  Run Keyword And Ignore Error    csn.disconnect   connection=uepc

#Spark multiUE ExportReport result to server PC
#    [Documentation]    Author:xiangsheng.chu@nokia-sbell.com
#    [Arguments]      ${ExportReport_path_cygwin}        ${ExportReport_path_windows}
#    ...              ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
#    ...             ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
#    ...             ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
#    ...             ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
#    ...             ${ute_ip}=${tl.test_pc.default_ssh_connection_details.addr}
#    ...             ${ute_name}=${tl.test_pc.default_ssh_connection_details.username}
#    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
#    ${output}    csn.execute    command=cd ${ExportReport_path_cygwin};ls    connection=cpc_${ue_index}
#    ${output}     Fetch From Left     ${output}    \r\n
#    ${ue_log_list_tmp}    Catenate    SEPARATOR=/    ${ExportReport_path_cygwin}     ${output}
#    csn.Download file
#    ...                                                 remote_path=${ue_log_list_tmp}
#    ...                                                 local_path=/tmp/${output}
#    ...                                                 connection=cpc_${ue_index}
#    Connect to control pc    cpc_ip=${logpc_ip}    cpc_usrname=${logpc_usrname}    cpc_passwd=${logpc_passwd}    alias=logpc
##    ${ExportReport_result_path_windows}    Catenate    SEPARATOR=/  ${ExportReport_path_windows}       ${output}
##    csn.upload_file     local_path=/tmp/${output}
##    ...                 remote_path=${ExportReport_result_path_windows}
##    ...                 connection=logpc
#    ${scp_cmd}    set variable    scp ${ute_name}@${ute_ip}:/tmp/${output} ${ExportReport_path_cygwin} &
#    ssh.send_command    command=${scp_cmd}    connection=logpc
#    sleep    5s    reason= scp start!!
#    ${delete_xlxs}    csn.execute    command=cd ${ExportReport_path_cygwin};rm -rf ${output}     connection=cpc_${ue_index}
#    [Teardown]  Run Keywords    Run Keyword And Ignore Error    csn.disconnect   connection=cpc_${ue_index}
#    ...         AND       Run Keyword And Ignore Error    csn.disconnect   connection=logpc

Start UE Attach in X65 with WA Restart UE
    [Documentation]    Author:stella.lin@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}    ${apn}=weistatic
    Run Keyword And Ignore Error    spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+CFUN=1,1
    Sleep    60s
    Run Keyword And Ignore Error    spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+CFUN=0
    Sleep    5s
    Run Keyword And Ignore Error    spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+CFUN=1
    Sleep    5s
    Run Keyword And Ignore Error    spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=at+CGDCONT=1,"IPV4V6","${apn}"
    Sleep    10s

Lock UE band n41 in X75
    [Documentation]    Author:xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    Run Keyword And Ignore Error    spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=at+QNWPREFCFG="nr5g_band",41
    Sleep    5s

Spark Start special UE Log
    [Documentation]    Author:xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${logpath}=${ue_logpath}    ${logname}=${ue_logname}      ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    spark.start_log_special_UE    ue_alias=${ue_alias}      logpath=${logpath}    logname=${logname}


Spark Stop special UE Log
    [Documentation]    Author:xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    ...            ${log_name}=${TS_CASE_LOG_PATH}/uelog_sigspark_UE${ue_index}.xml    ${filter}=Event_Auto
    spark.stop_log_special_UE    ue_alias=${ue_alias}    logname=${log_name}    filter=${filter}

Unlock UE band n41 in X75
    [Documentation]    Author:xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    Run Keyword And Ignore Error    spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=at+QNWPREFCFG="nr5g_band",25:41:71
    Sleep    5s

