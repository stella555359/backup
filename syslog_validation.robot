*** Settings ***
Library    OperatingSystem
Library    Process
Library    BuiltIn
Library    Collections
Library    String
Library    DateTime
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/syslog_parser/syslog_parser.py
Resource    ./TMO_common_keywords.robot

*** Keywords ***
Find Syslog Errors During A Specific Period of Time
    [Documentation]    author: lei.jia@nokia-sbell.com
    ...    this keyword is used to check errors and warnings of SYSLOG.LOG files under /tmp/btslog2 folder.
    ...    ${start_flag}: start_flat should be set to True once gnb is restarted
    ...    If start_flag is TRUE starts only after fist occurence of "OnAirDone"
    ...    ${ignorefname}: If ignorefname is given then ignore all error lines which
    ...    containes strings defined in this file.
    ...    you can define one in your case based on testline issue.
    ...    ${errordeffname}: error_array get from this file. you can pick to check errors or "errors and warnings"
    ...    ERR/ -> only check errors in syslog
    ...    ERR/    WRN/-> check both errors and warnings in syslog
    ...    ${syslog_path}: folder to store syslog, usually /tmp/btslog2 
    ...    ${output_error_log_path}: folder to store syslog error file
    ...    ${syslog_start_time}: syslog start capture time, if ${None}, will check syslog within 30 minuts.
    [Arguments]    ${syslog_path}=/tmp/btslog2
    ...    ${syslog_start_time}=${None}
    ...    ${ignorefname}=${CURDIR}/SYSLOG_EXCEPTION_TMO.TXT
    ...    ${errordeffname}=${CURDIR}/../../../robot/syslog_parser/SYSLOG_ERR_ARRAY.TXT
    ...    ${start_flag}=${None}
    ...    ${output_error_log_path}=/home/ute/tmp_syslog    ${is_set_to_test_case_level}=${True}
    ...    ${gnb_index}=${0}
    ...    ${connection}=GNB_OAM${gnb_index}
    ...    ${syslog_restore_path}=${TS_CASE_LOG_PATH}
    ...    ${if_syslog_in_remote_pc}=${False}
    ...    ${remote_pc}=${None}
    ...    ${if_original_syslog_need_return}=${False}
    log to console    --- start to check syslog error---
    ${syslog_inputfile}    Run Keyword If    ${if_syslog_in_remote_pc}
    ...    Get latest modified syslog file and Compress File For Remote PC
    ...    remote_pc_ip=${remote_pc}
    ...    syslog_path=${syslog_path}
    ...    output_error_log_path=${output_error_log_path}
    ...    syslog_start_time=${syslog_start_time}
    ...    is_set_to_test_case_level=${is_set_to_test_case_level}
    ...    ELSE    Get latest modified syslog file and Compress File
    ...    syslog_path=${syslog_path}
    ...    output_error_log_path=${output_error_log_path}
    ...    syslog_start_time=${syslog_start_time}
    ...    is_set_to_test_case_level=${is_set_to_test_case_level}
    ${error_file}=    find_errors_and_warnings_in_logfile_and_write_them_into_resultfile
    ...    inputfile=${syslog_inputfile}
    ...    ignorefname=${ignorefname}
    ...    errordeffname=${errordeffname}
    ...    start_flag=${start_flag}
    ${btsName}    ${gnb_version}     Run Keyword And Continue On Failure    Get BtsName and SwVersion
    ...    gnb_id=${gnb_index}    connection=${connection}
    ${timestamp}    DateTime.Get Current Date    result_format=%Y-%m-%d%H:%M:%S
    ${error_file_prefix}    Set Variable    ${error_file.split('/')[-2]}
    ${err_file_path}    Set Variable    /home/ute/tmp_syslog/${error_file_prefix}/${gnb_version}_${btsName}_SYSLOG_${timestamp}.ERRORS
    Run Keyword And Continue On Failure    OperatingSystem.Move File    ${error_file}    ${err_file_path}
    Run Keyword And Continue On Failure    OperatingSystem.File Should Be Empty  ${err_file_path}
    ${error_file_exist}    Run Keyword And Return Status    OperatingSystem.File Should Be Empty  ${err_file_path}
    Run Keyword If    '${error_file_exist}'=='${False}'    Run Keyword And Continue On Failure
    ...    OperatingSystem.Copy File    ${err_file_path}    ${syslog_restore_path}/${gnb_version}_${btsName}_SYSLOG_${timestamp}.ERRORS
    Run Keyword And Ignore Error    OperatingSystem.Copy File    ${syslog_inputfile}    ${syslog_restore_path}/SYSLOG.tgz
    ${return_value}    Run Keyword If    ${if_original_syslog_need_return}     Create List    ${err_file_path}
    ...    ${syslog_restore_path}/SYSLOG.tgz
    ...    ELSE    Set Variable       ${err_file_path}
    [Return]    ${return_value}
    [Teardown]    Run Keyword And Ignore Error      Run 	rm -rf ${syslog_inputfile}


Get latest modified syslog file and Compress File
    [Documentation]
    ...    It returns the latest modified file from syslog and compress in gz file
    [Arguments]    ${syslog_path}=/tmp/btslog2    ${output_error_log_path}=/home/ute/tmp_syslog
    ...            ${syslog_start_time}=${None}    ${is_set_to_test_case_level}=${True}
    ${string}    Set Variable If    ${is_set_to_test_case_level}    ${TEST NAME}    ${SUITE NAME}
    ${tc_name}=    Replace String    string=${string}    search_for=${SPACE}    replace_with=_
    ${syslog_log_path}    Join path    ${output_error_log_path}    TC_${tc_name}
    Create Directory    ${syslog_log_path}

    # if syslog start time is not transferred by case start up, set it as 30 mins ago
    ${currenttime}    DateTime.Get Current Date    result_format=%Y-%m-%d%H:%M:%S
    ${start_time} = 	DateTime.Get Current Date 	local 	- 30 mins     result_format=timestamp
    ${start_time} = 	DateTime.Convert Date 	${start_time}    epoch

    ${check_syslog_time}    Set Variable If    ${syslog_start_time} is not ${None}    ${syslog_start_time}    ${start_time}

    @{syslog_files_for_case}   Create List
    ${string_files} = 	Run 	cd ${syslog_path}&&find -name "SYSLOG_*.LOG"
    ${files}   Split String    ${string_files}   \n
    FOR    ${file}    IN    @{files}
        ${syslog_modtime} = 	OperatingSystem.Get Modified Time 	${syslog_path}//${file}    epoch
        Run Keyword If    ${syslog_modtime} > ${check_syslog_time}    Copy Files 	${syslog_path}//${file} 	${syslog_log_path}
    END
    Run 	cd ${syslog_log_path}; tar zcvf SYSLOG.tgz SYSLOG_*.LOG
    Run 	cd ${syslog_log_path}; rm -rf SYSLOG_*.LOG
    ${syslog_files}=  OperatingSystem.List Files In Directory   ${syslog_log_path}  *.tgz
    ${num_of_files}=  get length  ${syslog_files}
    Run keyword if  ${num_of_files}<1    Log to console    No syslog_files.tgz available
    [Return]    ${syslog_log_path}/SYSLOG.tgz
    [Teardown]    Run Keyword And Ignore Error      Run 	cd ${syslog_log_path}; rm -rf SYSLOG_*.LOG
    
Get latest modified syslog file and Compress File For Remote PC 
    [Documentation]
    ...    It returns the latest modified file from syslog and compress in gz file
    [Arguments]    ${remote_pc_ip}
    ...            ${remote_user_name}=${tl.test_pc.default_ssh_connection_details.username}
    ...            ${remote_pwd}=${tl.test_pc.default_ssh_connection_details.password}
    ...            ${syslog_path}=/tmp/btslog2    ${output_error_log_path}=/home/ute/tmp_syslog
    ...            ${syslog_start_time}=${None}    ${is_set_to_test_case_level}=${True}
    wait until keyword succeeds    1min   10s
    ...    csn.Connect To   hostname=${remote_pc_ip}   username=${remote_user_name}   password=${remote_pwd}   alias=server
    ${string}    Set Variable If    ${is_set_to_test_case_level}    ${TEST NAME}    ${SUITE NAME}
    ${tc_name}=    Replace String    string=${string}    search_for=${SPACE}    replace_with=_
    ${syslog_log_path}    Join path    ${output_error_log_path}    TC_${tc_name}
    #create remote path
    csn.Execute    command=mkdir -p ${syslog_log_path}  connection=server
    #create local path
    Create Directory    ${syslog_log_path}
    # if syslog start time is not transferred by case start up, set it as 30 mins ago
    ${currenttime}    DateTime.Get Current Date    result_format=%Y-%m-%d%H:%M:%S
    ${start_time} = 	DateTime.Get Current Date 	local 	- 30 mins     result_format=timestamp
    ${start_time} = 	DateTime.Convert Date 	${start_time}    epoch
    ${check_syslog_time}    Set Variable If    ${syslog_start_time} is not ${None}    ${syslog_start_time}    ${start_time}
    @{syslog_files_for_case}   Create List
    ${string_files}    csn.Execute    command=cd ${syslog_path}&&find -name "SYSLOG_*.LOG"    connection=server
    ${files}   Split String    ${string_files}   \r\n
    FOR    ${file}    IN    @{files}[:-1]
        ${file}    Set Variable    ${file.split('/')[1]}
        ${command}    Set Variable    stat --format='%Y' ${syslog_path}/${file}
        ${syslog_modtime} = 	csn.Execute    command=${command}    connection=server
        ${syslog_modtime}   Split String    ${syslog_modtime}   \r\n
        Run Keyword If    ${syslog_modtime[0]} > ${check_syslog_time}   csn.send_command
        ...    command=sudo cp ${syslog_path}/${file} ${syslog_log_path}    connection=server
    END
    ${expect_files}    csn.Execute    command=cd ${syslog_log_path}&&find -name "SYSLOG_*.LOG"    connection=server
    ${expect_files}   Split String    ${expect_files}   \r\n
    FOR    ${file}    IN    @{expect_files}[:-1]
        csn.download_file   remote_path=${syslog_log_path}/${file}   local_path=${syslog_log_path}/${file}   connection=server
    END
    Run 	cd ${syslog_log_path}; tar zcvf SYSLOG.tgz SYSLOG_*.LOG
    Run 	cd ${syslog_log_path}; rm -rf SYSLOG_*.LOG
    ${syslog_files}=  OperatingSystem.List Files In Directory   ${syslog_log_path}  *.tgz
    ${num_of_files}=  get length  ${syslog_files}
    Run keyword if  ${num_of_files}<1    Log to console    No syslog_files.tgz available
    [Return]    ${syslog_log_path}/SYSLOG.tgz
    [Teardown]    Run Keywords     Run Keyword And Ignore Error
    ...    csn.send_command    command=rm -rf ${syslog_log_path}/SYSLOG_*.LOG    connection=server    AND
    ...    Run Keyword And Ignore Error      Run 	cd ${syslog_log_path}; rm -rf SYSLOG_*.LOG    AND
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=server