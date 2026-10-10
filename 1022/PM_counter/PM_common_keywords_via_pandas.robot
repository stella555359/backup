*** Settings ***
Documentation    This is for PM counter via scout.
...              Please do not modify the file without notification to author
...              Author: lei.jia@nokia-sbell.com
Library    BuiltIn
Library    Collections
Library    OperatingSystem
Library    String
Library    DateTime
Library     taf.sw.scout    WITH NAME   scout
Library   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/PM_counter/KPI_report_with_pandas.py

*** Variables ***
${testline}         ${testline_name}


*** Keywords ***
Get KPI Report From Scout And Convert To Excel
    [Documentation]   lei.jia@nokia-sbell.com
    ...               Note: one scout count have one api key, please replace with your own api-keys during testing
    [Arguments]    ${start_time}    ${end_time}    ${template_id}=1565
    ...            ${file_path}=/home/ute/KPI_report/
    ...            ${api_key}=5954d576-f448-41ee-b3e1-73180ea6a0cb
    ...            ${scout_testline_name}=${testline}
    ...            ${report_name}=${scout_testline_name}_kpi_report
    ...            ${stream_version}=24R2
    ...            ${try_index}=0
    ...            ${scf_version}=24R2
    ...            ${sw_version}=${None}
    ${timestamp}    Get current date    result_format=%Y%m%dT%H%M%S
    ${report}    Generate KPI Report From Scout    start_time=${start_time}
    ...                                       end_time=${end_time}
    ...                                       template_id=${template_id}
    ...                                       api_key=${api_key}
    ...                                       report_name=${report_name}_${timestamp}
    ...                                       scout_testline_name=${scout_testline_name}
    ${kpi_output_file_path}    Join path    ${file_path}    ${report_name}_${timestamp}.xlsx
    Convert Genrated KPI Report To Excel    report=${report}    file_path=${kpi_output_file_path}
    ...                                     stream_version=${stream_version}
    ...                                     try_index=${try_index}
    ...                                     scf_version=${scf_version}
    ...                                     sw_version=${sw_version}
    [Return]    ${kpi_output_file_path}

Generate KPI Report From Scout
    [Documentation]   lei.jia@nokia-sbell.com
    ...               Param: the style of ${end_time} and ${start_time} like as "2022-03-29 04:10:00"
    ...                      Time delta between start and end must be above 15 minutes"
    ...                      ${end_time} and ${start_time}:  Date and time must be in past
    ...                      Use the pm xml file under the path "/ffs/run/uri/PERFMON_FILES/" of gnb
    ...                      if " -rw-r--r-- 1 root btssw  72682 Mar 31 11:35 PM.BTS-813.20220331.033500.ANY.xml.gz "
    ...                      so ${end_time} or ${start_time} use 20220331.033500 into "2022-03-31 03:35:00"
    ...               Param: ${template_id}---https://scout.nsn-rdnet.net/kpis-templates/382/, 382 is ${template_id}
    ...               Param: ${api_key}---scout for easy access from robot framework to Scout API
    ...                      Note: one scout count have one api key, please replace with your own api-keys during testing
    [Arguments]    ${start_time}
    ...            ${end_time}
    ...            ${template_id}=1565
    ...            ${api_key}=5954d576-f448-41ee-b3e1-73180ea6a0cb
     ...           ${timeout}=360
    ...            ${interval}=30 minutes
    ...            ${alias}=scout
    ...            ${scout_testline_name}=${testline}
    ...            ${report_name}=${scout_testline_name}_kpi_report
    # it takes 30 minutes for gnb to sync counters to scout.
    ${curr_time} = 	DateTime.Get Current Date 	time_zone=UTC     exclude_millis=yes
    ${added_end_time}    Add Time To Date    ${end_time}    ${interval}    exclude_millis=yes
    ${difference}  Subtract Date From Date    ${added_end_time}    ${curr_time}
    ...    timer    exclude_millis=True
    Run Keyword If  '${difference}'>'00:00:01'
    ...    Run Keywords    Log  Sleep for ${difference} until scout sync finished  console=true
    ...             AND    Sleep  ${difference}
    scout.setup_scout    scout_testline_name=${scout_testline_name}    api_key=${api_key}    timeout=${timeout}    alias=${alias}
    ${report}    scout.generate kpi report    report_name=${report_name}
    ...                                       template_id=${template_id}
    ...                                       start_time=${start_time}
    ...                                       end_time=${end_time}
    ...                                       alias=${alias}
    [Return]    ${report}
    [Teardown]    Run Keyword And Ignore Error    scout.teardown_scout_api    alias=${alias}

Convert Genrated KPI Report To Excel
    [Documentation]   lei.jia@nokia-sbell.com
    [Arguments]    ${report}
    ...            ${file_path}=/home/ute/KPI_report/${testline}_kpi_report.xlsx
    ...            ${stream_version}=24R2
    ...            ${try_index}=0
    ...            ${scf_version}=24R2
    ...            ${sw_version}=${None}
    KPI_report_with_pandas.generate_excel_report    file_path=${file_path}
    ...                                 scout_report=${report}
    ...                                 stream_version=${stream_version}
    ...                                 try_index=${try_index}
    ...                                 scf_version=${scf_version}
    ...                                 sw_version=${sw_version}

Caculate timeToSleep Before Next Counters Period
    [Documentation]    Author:lei.jia
    ...        This function calculates the time to sleep before the start of the next PM counters period
    ...    ${counterPeriod} defined the PM counter Period in mins: either 5min or 15min.
    ...    ${offset}        defined the minimum time (in seconds) before the start of the next PM counters period
    ...    return: the time to sleep (in seconds) before the next PM counters period
    [Arguments]    ${counter_period}=5    ${offset}=30
    ${currTime}     robot.libraries.DateTime.Get Current Date
    ${currTime}     robot.libraries.DateTime.Convert Date    ${currTime}     epoch
    ${getNextTimeSlot}     Evaluate   (int((${currTime} / (int(${counter_period}) * 60))) + 1) * (int(${counter_period}) * 60)
    ${timeToSleep}     Evaluate    int(${getNextTimeSlot} - ${currTime}) + 1
    ${tempTime}    Evaluate    ${timeToSleep}+ int(${counter_period}) * 60
    ${timeToSleep}    Set Variable If    ${timeToSleep} < int(${offset})
    ...        ${tempTime}    ${timeToSleep}
    ${timeToSleep}    Evaluate     ${timeToSleep} + 60
    [Return]    ${timeToSleep}


KPI.Generate kpi report in Scout
    [Documentation]   stella.lin@nokia-sbell.com
    ...               Param: ${scout_testline_name} is "TL73_gNB" or "TL813_gNB", scout_testline_name in scout, type: str
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
    ...            ${comments}=PZ4_SG06_KPI_Report
    ...            ${template_name}=KPI_24R1_TMO_SA_SG6
    ...            ${check_out_entry}=false
    ...            ${gnb_index}=${0}
    ...            ${connection}=GNB_OAM${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${sw_version}     coam.get_sw_version    connection=GNB_OAM${gnb_index}
    ${report_time}  DateTime.Get Current Date  result_format=%Y-%m-%d %H:%M:%S
    ${report_date}    Get Substring    ${report_time}    0    10
    ${kpi_report_name}   Catenate    SEPARATOR=_   PZ4_SG06    ${report_date}   ${tl_name}   ${sw_version}
    ${report_id}    generate_new_report_on_compass
    ...    report_name=${kpi_report_name}
    ...    tl_id=${tl_name}
    ...    package_version=${sw_version}
    ...    start_time=${start_time}
    ...    end_time=${end_time}
    ...    comments=${comments}
    ...    template_name=${template_name}
    ...    check_out_entry=${check_out_entry}
    Set Test Variable    ${report_id}
    Run keyword If    '${report_id}'=='${None}'     fail    msg=failed to get scout report id.
    ${excel_file_name}    download_kpi_file    report_id=${report_id}    path=${excel_kpi_download_path}
    [Return]    ${excel_file_name}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}