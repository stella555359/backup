*** Settings ***
Documentation    This is for PM counter via scout.
...              Please do not modify the file without notification to author
...              Author: jun.8.chen@nokia-sbell.com
Library     taf.sw.scout    WITH NAME   scout
Library   ./KPI_report.py


*** Keywords ***
Get Time List Of PM Files From Gnb
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               get the pm xml files under the path "/ffs/run/uri/PERFMON_FILES/" of gnb
    [Arguments]    ${gnb_index}=${0}    ${connection}=ASIK Master0
    Connect to Common Unit Master    alias=${connection}    gnb_index=${gnb_index}
    ${output}    csn.execute    command=cd /ffs/run/uri/PERFMON_FILES;ls -l |awk '{print $9}'    connection=${connection}
    ${output}    Split String    ${output}    \r\n
    ${output}    Get Slice From List    ${output}    1    -3
    ${pm_time_list}    Create List
    FOR    ${element}    IN    @{output}
        ${time}    Catenate    SEPARATOR=.    ${element.split('.')[2]}    ${element.split('.')[3]}
        Append To List    ${pm_time_list}    ${time}
    END
    [Return]    ${pm_time_list}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=${connection}

Get Last KPI Update Time From Scout
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               Param: ${tl_name} is "TL73_gNB" or "TL813_gNB", scout_testline_name in scout, type: str
    ...               Param: Use the pm xml file under the path "/ffs/run/uri/PERFMON_FILES/" of gnb
    ...                      if " -rw-r--r-- 1 root btssw  72682 Mar 31 11:35 PM.BTS-813.20220331.033500.ANY.xml.gz "
    ...                      so Return: '2022-03-31T03:35:00Z'
    [Arguments]    ${tl_name}    ${alias}=scout
    scout.setup_scout    scout_testline_name=${tl_name}    alias=${alias}
    ${time}    scout.get_last_kpi_update_time    alias=${alias}
    [Return]    ${time}
    [Teardown]    Run Keyword And Ignore Error    scout.teardown_scout_api    alias=${alias}

Get KPI Report From Scout
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               Param: ${tl_name} is "TL73_gNB" or "TL813_gNB", scout_testline_name in scout, type: str
    ...               Param: the style of ${end_time} and ${start_time} like as "2022-03-29 04:10:00"
    ...                      Time delta between start and end must be above 15 minutes"
    ...                      ${end_time} and ${start_time}:  Date and time must be in past
    ...                      Use the pm xml file under the path "/ffs/run/uri/PERFMON_FILES/" of gnb
    ...                      if " -rw-r--r-- 1 root btssw  72682 Mar 31 11:35 PM.BTS-813.20220331.033500.ANY.xml.gz "
    ...                      so ${end_time} or ${start_time} use 20220331.033500 into "2022-03-31 03:35:00"
    ...               Param: ${template_id}---https://scout.nsn-rdnet.net/kpis-templates/382/, 382 is ${template_id}
    ...               Param: ${api_key}---scout for easy access from robot framework to Scout API
    [Arguments]    ${tl_name}
    ...            ${start_time}
    ...            ${end_time}
    ...            ${template_id}=382
    ...            ${kpi_report_name}=${tl_name}_kpi_report
    ...            ${api_key}=7393d8bd000d4564aa146beae67328b4
    ...            ${alias}=scout
    scout.setup_scout    scout_testline_name=${tl_name}    api_key=${api_key}    alias=${alias}
    ${report}    scout.generate kpi report    report_name=${kpi_report_name}
    ...                                       template_id=${template_id}
    ...                                       start_time=${start_time}
    ...                                       end_time=${end_time}
    ...                                       alias=${alias}
    [Return]    ${report}
    [Teardown]    Run Keyword And Ignore Error    scout.teardown_scout_api    alias=${alias}


Convert Time To Another Style
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               Convert time "2022-03-31 08:14:06.282" to "20220331.081406"
    [Arguments]    ${timestamp}
    ${date}    Set Variable    ${timestamp.split(' ')[0]}
    ${time}    Set Variable    ${timestamp.split(' ')[-1].split('.')[0]}
    ${time1}    Catenate    SEPARATOR=    ${date.split('-')[0]}   ${date.split('-')[1]}  ${date.split('-')[-1]}
    ${time2}    Catenate    SEPARATOR=    ${time.split(':')[0]}   ${time.split(':')[1]}  ${time.split(':')[-1]}
    ${time}    Catenate    SEPARATOR=.    ${time1}    ${time2}
    [Return]    ${time}

Get PM Time After Action
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               Param: ${pm_time_list}---get the pm xml files under the path "/ffs/run/uri/PERFMON_FILES/" of gnb
    [Arguments]    ${action_time}    ${pm_time_list}
    FOR    ${element}    IN    @{pm_time_list}
        ${index}    Get Index From List    ${pm_time_list}    ${element}
        ${next_index}    Evaluate    ${index}+1
        ${next_element}    Set Variable    ${pm_time_list}[${next_index}]
        ${status}    Evaluate    '${element}' <= '${action_time}' <= '${next_element}'
        Exit For Loop If    "${status}"=="True"
    END
    ${start_time}    DateTime.Convert Date    date=${next_element}    exclude_millis=yes
    ${end_time}    DateTime.Add Time To Date    date=${start_time}    time=15 mins
    ${end_time}    Set Variable    ${end_time.split('.')[0]}
    [Return]    ${start_time}    ${end_time}

Convert KPI Report To Excel
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               Param: ${tl_name} is "TL73_gNB" or "TL813_gNB", scout_testline_name in scout, type: str
    [Arguments]    ${report}
    ...            ${tl_name}
    ...            ${start_time}
    ...            ${end_time}
    ...            ${file_path}=/tmp/${tl_name}_kpi_report.xlsx
    ${group_name_list}    KPI_report.get_group_name    report=${report}
    ${kpi_report}    KPI_report.get_data    report=${report}
    ...                                     group_name_list=${group_name_list}
    KPI_report.create_workbook_sheets    group_name_list=${group_name_list}
    ...                                  file_path=${file_path}
    KPI_report.write_data_to_xlsx    file_path=${file_path}
    ...                              kpi_report=${kpi_report}
    ...                              start_time=${start_time}
    ...                              end_time=${end_time}

Append A Col Data To Excel
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${report}
    ...            ${tl_name}
    ...            ${start_time}
    ...            ${end_time}
    ...            ${file_path}=/tmp/${tl_name}_kpi_report.xlsx
    ${group_name_list}    KPI_report.get_group_name    report=${report}
    ${kpi_report}    KPI_report.get_data    report=${report}
    ...                                     group_name_list=${group_name_list}
    ${col_no}    KPI_report.get_col_num    file_path=${file_path}    sheet=${group_name_list}[0]
    KPI_report.append_col_to_xlsx    file_path=${file_path}
    ...                              kpi_report=${kpi_report}
    ...                              start_time=${start_time}
    ...                              end_time=${end_time}
    ...                              location=${col_no}

Get KPI Report And Convert To Excel
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${timestamp}    ${tl_name_in_scout}    ${template_id}=382    ${file_path}=/tmp/${tl_name}_kpi_report.xlsx
    ${time}    Convert Time To Another Style    timestamp=${timestamp}
    ${pm_time_list}    Get Time List Of PM Files From Gnb
    ${start_time}    ${end_time}    Get PM Time After Action    action_time=${time}    pm_time_list=${pm_time_list}
    ${report}    Get KPI Report From Scout    tl_name=${tl_name_in_scout}    start_time=${start_time}    end_time=${end_time}
    ...                                       template_id=${template_id}
    Convert KPI Report To Excel    report=${report}    tl_name=${tl_name_in_scout}
    ...    start_time=${start_time}    end_time=${end_time}    file_path=${file_path}

Get KPI Report And Append Related Data To Excel
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${timestamp}    ${tl_name_in_scout}    ${file_path}=/tmp/${tl_name}_kpi_report.xlsx
    ${time}    Convert Time To Another Style    timestamp=${timestamp}
    ${pm_time_list}    Get Time List Of PM Files From Gnb
    ${start_time}    ${end_time}    Get PM Time After Action    action_time=${time}    pm_time_list=${pm_time_list}
    ${report}    Get KPI Report From Scout    tl_name=${tl_name_in_scout}    start_time=${start_time}    end_time=${end_time}
    Append A Col Data To Excel    report=${report}    tl_name=${tl_name_in_scout}
    ...    start_time=${start_time}    end_time=${end_time}    file_path=${file_path}

Get KPI Report from gnb and enb
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${log_prefix}=xml.gz    ${gnb_index}=0    ${du_index}=0    ${local_log_path}=/ffs/run/uri/PERFMON_FILES/
    ...    ${connection}=ASIK Master    ${folder_index}=0
    ${remote_log_path}    OperatingSystem.Join Path    ${TS_CASE_LOG_PATH}    ${folder_index}
    OperatingSystem . Create Directory    ${remote_log_path}
    Set Test Variable     ${remote_log_path}
    @{list_log_names}    ssh_common_commands.get_file_names_under_directory    directory=${local_log_path}   connection=${connection}
    ...    file_indicator=*${log_prefix}*
    should not be empty  ${list_log_names}    msg=No measurement reprot found under asik ${local_log_path} folder
    FOR  ${log_name}  IN  @{list_log_names}
      Wait Until Keyword Succeeds   2 min  5 sec   ssh.Download file
      ...                                                 remote_path=${local_log_path}/${log_name}
      ...                                                 local_path=${remote_log_path}/${log_name}
      ...                                                 connection=${connection}
    END

Download Excel File From Test VM
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${alias}=test_pc
    ...            ${remot_log_path}=/tmp/${tl_name}_kpi_report.xlsx
    ...            ${test_pc_ip}=${tl.test_pc.default_ssh_connection_details.addr}
    ...            ${test_pc_name}=${tl.test_pc.default_ssh_connection_details.username}
    ...            ${test_pc_password}=${tl.test_pc.default_ssh_connection_details.password}
    csn.Connect to    hostname=${test_pc_ip}    username=${test_pc_name}    password=${test_pc_password}    alias=${alias}
    ${status}    Run Keyword And Return Status    csn.download_file    remote_path=${remot_log_path}
    ...                                                                local_path=${TS_CASE_LOG_PATH}/kpi_report.xlsx
    ...                                                                connection=${alias}
    Run Keyword If    ${status}    csn.execute    command=rm ${remot_log_path}    connection=${alias}
    [Teardown]    csn.disconnect    connection=${alias}

Get start time for KPI
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    ...               Convert time "2022-03-31 08:14:06.282" to "20220331.081406"
    [Arguments]    ${timestamp}    ${time_1}=59    ${time_2}=14     ${time_3}=29     ${time_4}=44
    ${date}    Set Variable    ${timestamp.split(' ')[0]}
    ${time}    Set Variable    ${timestamp.split(' ')[-1].split('.')[0]}
    ${start_time}    Catenate    SEPARATOR=    ${time.split(':')[1]}
    ${result}    Run Keyword And Return Status    Should Contain Any   ${start_time}    ${time_1}    ${time_2}     ${time_3}    ${time_4}
    [Return]    ${result}

Get time to start L3 call
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    ...             start L3 call in KPI start time
    [Arguments]    ${time_1}=59    ${time_2}=14     ${time_3}=29     ${time_4}=44    ${sleep_time}=20s
    FOR    ${i}    IN RANGE    1    ${180}
          ${current_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
          ${result}    Get start time for KPI    timestamp=${current_time}
          ...                time_1=${time_1}    time_2=${time_2}    time_3=${time_3}    time_4=${time_4}
          ${start_L3_call}   set variable if   "${result}" == "${True}"   True     False
          Exit For Loop IF    "${result}" == "${True}"
          sleep    ${sleep_time}
    END
    [Return]    ${start_L3_call}

Get time to start call for 8311 kpi
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    ...             start L3 call in KPI start time
    [Arguments]    ${sleep_time}=20s
    FOR    ${i}    IN RANGE    1    ${180}
          ${current_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
          ${result}    Get start time for 8311 kpi   timestamp=${current_time}
          ${start_L3_call}   set variable if   "${result}" == "${True}"   True     False
          Exit For Loop IF    "${result}" == "${True}"
          sleep    ${sleep_time}
    END
    [Return]    ${start_L3_call}

Get counter special value
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${special_counter_groups}   ${counter_id}    ${counter_version}     ${connection}=GNB_OAM
    Log to console    Gathering value of counter: "${counter_id}"
    ${counter_values} =    Get From Dictionary    ${special_counter_groups}    ${counter_id}
    ${key_list} =     Get Dictionary Keys    ${counter_values}
    Reverse List    ${key_list}
    ${counter_0} =    Get From Dictionary    ${counter_values}    ${key_list[0]}
    ${counter_1} =    Get From Dictionary    ${counter_values}    ${key_list[1]}
    ${counter_2} =    Get From Dictionary    ${counter_values}    ${key_list[2]}
    ${counter_3} =    Get From Dictionary    ${counter_values}    ${key_list[3]}
    ${counter_4} =    Get From Dictionary    ${counter_values}    ${key_list[4]}
    ${sum_counter_values}    Evaluate    ${counter_0}+${counter_1}+${counter_2}+${counter_3}+${counter_4}
    Append to file   ${remote_log_path}/8311_counter_${counter_version}.txt
    ...                   ${counter_id}_list=${counter_0}_${counter_1}_${counter_2}_${counter_3}_${counter_4}\r\n
    [Return]    ${sum_counter_values}


Get start time for 8311 kpi
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    ...               Convert time "2022-03-31 08:14:06.282" to "20220331.081406"
    [Arguments]    ${timestamp}
    ${date}    Set Variable    ${timestamp.split(' ')[0]}
    ${time}    Set Variable    ${timestamp.split(' ')[-1].split('.')[0]}
    ${start_time}    Catenate    SEPARATOR=    ${time.split(':')[1]}
    ${result}    Run Keyword And Return Status    Should Contain Any   ${start_time}    00   05   10   15  20   25   30   35   40   45   50   55
    [Return]    ${result}

Get start time and end time with call in 15min
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${call_start_fisrt}    ${call_end_fisrt}    ${call_start_second}
    ...   ${call_end_second}  ${call_start_third}   ${call_end_third}
    ...   ${connection}=GNB_OAM     ${gnb_index}=0
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
	${active_version}    coam.get_sw_version    timeout=60    connection=${connection}
	${decription}  Set Variable     ‘KPI start_time'
    create_file    ${remote_log_path}/KPI_start_end_time.txt
    Append to file   ${remote_log_path}/KPI_start_end_time.txt   decription=${decription}\r\n
    Append to file   ${remote_log_path}/KPI_start_end_time.txt   gnb_version=${tl_prefix}_${active_version}\r\n
    Append to file   ${remote_log_path}/KPI_start_end_time.txt   call_start_fisrt=${call_start_fisrt}\r\n
    Append to file   ${remote_log_path}/KPI_start_end_time.txt   call_end_fisrt=${call_end_fisrt}\r\n
    Append to file   ${remote_log_path}/KPI_start_end_time.txt   call_start_second=${call_start_second}\r\n
    Append to file   ${remote_log_path}/KPI_start_end_time.txt   call_end_second=${call_end_second}\r\n
    Append to file   ${remote_log_path}/KPI_start_end_time.txt   call_start_third=${call_start_third}\r\n
    Append to file   ${remote_log_path}/KPI_start_end_time.txt   call_end_third=${call_end_third}\r\n
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get KPI call start end time
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${good_time_start}    ${good_time_end_mid_time_start}    ${mid_time_end_bad_time_start}
    ...   ${bad_time_end_mid_time_start}  ${mid_time_end_good_time_start}   ${good_time_end}
    ...   ${bad_time_start_rach_206}=2023-00-00_00:00:00     ${bad_time_end_rach_206}=2023-00-00_00:00:00
    ...   ${connection}=GNB_OAM     ${gnb_index}=0
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
	${active_version}    coam.get_sw_version    timeout=60    connection=${connection}
	${decription}  Set Variable     'Due to the delay in TA command execution, the time difference was approximately 5 seconds.
	...                              So subtracting 5 seconds from the acquired time is the correct time.'
    create_file    ${remote_log_path}/KPI_start_end_time.txt
    Append to file   ${remote_log_path}/KPI_start_end_time.txt   decription=${decription}\r\n
    Append to file   ${remote_log_path}/KPI_start_end_time.txt   gnb_version=${active_version}\r\n
    Append to file   ${remote_log_path}/KPI_start_end_time.txt   good_fist_start=${good_time_start}\r\n
    Append to file   ${remote_log_path}/KPI_start_end_time.txt   good_time_end_mid_time_start=${good_time_end_mid_time_start}\r\n
    Append to file   ${remote_log_path}/KPI_start_end_time.txt   mid_time_end_bad_time_start=${mid_time_end_bad_time_start}\r\n
    Append to file   ${remote_log_path}/KPI_start_end_time.txt   bad_time_end_mid_time_start=${bad_time_end_mid_time_start}\r\n
    Append to file   ${remote_log_path}/KPI_start_end_time.txt   mid_time_end_good_time_start=${mid_time_end_good_time_start}\r\n
    Append to file   ${remote_log_path}/KPI_start_end_time.txt   good_time_end=${good_time_end}\r\n
    Append to file   ${remote_log_path}/KPI_start_end_time.txt   bad_time_start_rach_206=${bad_time_start_rach_206}\r\n
    Append to file   ${remote_log_path}/KPI_start_end_time.txt   bad_time_end_rach_206=${bad_time_end_rach_206}\r\n
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}


