*** Settings ***
Documentation    This is for TMO KPI report case generate and record keywords.
...              Please do not modify the file without notification to author
...              Author: stella.lin@nokia-sbell.com

Resource  ./TMO_common_keywords.robot

*** Variables ***
${excel_kpi_download_path}    /home/ute/KPI_Report/Excel_KPI
${report_path_on_ute}    /home/ute/KPI_Report/Scout_KPI_Report
#${comparator_report_path_on_ute}    /home/ute/KPI_Report/Comparator_Report

*** Keywords ***
KPI_Report_Case.Test Procedures For Multi Rounds
    [Arguments]    ${case_test_procedure_kw}=TestCase.Reproduce_5605004
    ...            ${rounds}=1
    ...            ${gnb_index}=${0}
    ...            ${connection}=GNB_OAM${gnb_index}
    ...            ${need_to_check_status}=${True}
    ${btsName}    ${gnb_version}     Get BtsName and SwVersion    gnb_id=${gnb_index}    connection=${connection}
    Set Test Variable    ${btsName}
    Set Test Variable    ${gnb_version}
    ${scf_version}    ${stream_version}    Get scf stream and sw stream    scf_name=${btsName}    sw_version=${gnb_version}
    ${report_start_time}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${report_timestamps}      Create List
    ${empty_list}     Create List
    FOR    ${round}    IN RANGE    ${rounds}
        log to console    start to call round-${round}
        ${status}     Run Keyword And Return Status    ${case_test_procedure_kw}
#        ${call_timestamp}    Run Keyword If    ${status}     Create List    ${call_start_time}
#        ...    ${call_end_time}
#        Run Keyword If    ${status}    Append To List    ${report_timestamps}    ${call_timestamp}
        ${call_timestamp}    Create List    ${call_start_time}    ${call_end_time}
        Run Keyword If    ${need_to_check_status} and ${status}    Append To List    ${report_timestamps}    ${call_timestamp}
        ...    ELSE IF    ${need_to_check_status} and '${status}'=='${False}'    Append To List    ${report_timestamps}    ${empty_list}
        ...    ELSE    Append To List    ${report_timestamps}    ${call_timestamp}
    END
    ${test_procedure_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${diff_time}    Subtract Date From Date    ${test_procedure_time}    ${call_end_time}
    ${duration}    Evaluate   2100-${diff_time}
    ${sleep_time}   Set Variable If   ${diff_time}>=1800    300      ${duration}
    log to console    sleep for wait for scout report : ${sleep_time}
    log    test timestamps for ${rounds} rounds is ${report_timestamps}
    ${report_end_time}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${timestamps_length}    Get Length    ${report_timestamps}
    Run keyword If    '${timestamps_length}'=='${0}'    fail    msg=${case_test_procedure_kw} test for ${rounds}rounds all failed.
    log to console    start to wait ${sleep_time}
    Sleep    ${sleep_time}sec
    [Return]    ${report_timestamps}

KPI_Report_Case.Test Procedures
    [Arguments]    ${case_test_procedure_kw}=TestCase.Reproduce_5605004
    ...            ${gnb_index}=${0}
    ...            ${connection}=GNB_OAM${gnb_index}
    ${btsName}    ${gnb_version}     Get BtsName and SwVersion    gnb_id=${gnb_index}    connection=${connection}
    Set Test Variable    ${btsName}
    Set Test Variable    ${gnb_version}
    ${scf_version}    ${stream_version}    Get scf stream and sw stream    scf_name=${btsName}    sw_version=${gnb_version}
    ${report_start_time}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${report_timestamps}      Create List
    ${empty_list}     Create List
    Run Keyword    ${case_test_procedure_kw}
    ${call_timestamp}    Create List    ${call_start_time}    ${call_end_time}
    Append To List    ${report_timestamps}    ${call_timestamp}
    ${test_procedure_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${diff_time}    Subtract Date From Date    ${test_procedure_time}    ${call_end_time}
    ${duration}    Evaluate   2100-${diff_time}
    ${sleep_time}   Set Variable If   ${diff_time}>=1800    300      ${duration}
    log to console    sleep for wait for scout report : ${sleep_time}
    Sleep    ${sleep_time}sec
    [Return]    ${report_timestamps}

Generate And Record KPI Report To Compass And UTE PC
    [Arguments]   ${report_timestamps}
    ...           ${filter_distnames}=bts,NRCELL-301
    ...           ${comments}=PZ4_SG06_case_5605004_overall
    ...           ${template_name}=KPI_24R1_TMO_SA_SG6
    ...           ${output_excel_name}=KPI_5605004.xlsx
    ...           ${check_out_entry}=false
    ...           ${gnb_index}=${0}
    ...           ${connection}=GNB_OAM${gnb_index}
    ...           ${group_name}=${None}
    ${output_excel_name_flag}    Set Variable    ${output_excel_name.split('.xls')[0]}
    ${backup_excel_name}    Set Variable    ${output_excel_name_flag}_backup.xlsx
    OperatingSystem.Copy File    ${report_path_on_ute}/${output_excel_name}    ${report_path_on_ute}/Backup/${backup_excel_name}
    ${filter_distnames}    Set Variable    ${filter_distnames.split(',')}
    ${scout_name}    Set Variable If    '${tl_prefix}'=='T284'    7_5_UTE402T284
    ...     '${tl_prefix}'=='T080' and '${gnb_index}'=='${0}'    7_5_UTE5G402T080
    ...     '${tl_prefix}'=='T080' and '${gnb_index}'=='${1}'    7_5_UTE5G402T282
    ...     '${tl_prefix}'=='T073'    7_5_CLOUD402T073
    ...     '${tl_prefix}'=='T283'    7_5_UTE5G402T283
    ...     '${tl_prefix}'=='T813'    7_5_UTE5G402T813
    log to console    start to generate kpi report on compass for ${scout_name}
    ${excel_report_path_on_ute}    Create List
    FOR   ${timestamp}    IN    @{report_timestamps}
       ${status}   ${excel_report}    Run Keyword And Ignore Error    KPI.Generate kpi report in Scout    tl_name=${scout_name}
       ...    start_time=${timestamp[0]}
       ...    end_time=${timestamp[1]}
       ...    comments=${comments}
       ...    template_name=${template_name}
       ...    check_out_entry=${check_out_entry}
       ...    gnb_index=${gnb_index}
       ...    connection=${connection}
       Run Keyword If    '${status}'=='PASS'    Append To List    ${excel_report_path_on_ute}    ${excel_report}
    END
    log    ${excel_report_path_on_ute}
    log    ${report_timestamps}
    ${report_length}    Get Length    ${excel_report_path_on_ute}
    Run keyword If    '${report_length}'=='${0}'    fail    msg=no available report get from this round test.
    log to console    start to record kpi report on ute
    ${reproduce_kpi_values_list}    Create List
    FOR    ${excel_report}    IN    @{excel_report_path_on_ute}
       ${report_time}    Set Variable    ${excel_report.split('.')[0].split('/')[-1].split('_')[-1]}
       ${reproduce_kpi_values_dict}    Run Keyword And Continue On Failure
       ...    generate_kpi_report_based_on_scout_report
       ...    sw_version=${gnb_version}
       ...    scf_name=${btsName}
       ...    scout_report_time=${report_time}
       ...    excel_report_path=${excel_report}
       ...    output_report_path=${report_path_on_ute}/${output_excel_name}
       ...    filter_distnames=${filter_distnames}
       ...    group_name=${group_name}
       Append To List    ${reproduce_kpi_values_list}    ${reproduce_kpi_values_dict}
   END
   [Return]    ${reproduce_kpi_values_list}




Generate KPI Report And Record To Compass
    [Arguments]   ${report_timestamps}
    ...           ${comments}=PZ4_SG06_case_5605004_overall
    ...           ${template_name}=KPI_24R1_TMO_SA_SG6
    ...           ${check_out_entry}=false
    ...           ${gnb_index}=${0}
    ...           ${connection}=GNB_OAM${gnb_index}
    ${scout_name}    Set Variable If    '${tl_prefix}'=='T284'    7_5_UTE402T284
    ...     '${tl_prefix}'=='T080' and '${gnb_index}'=='${0}'    7_5_UTE5G402T080
    ...     '${tl_prefix}'=='T080' and '${gnb_index}'=='${1}'    7_5_UTE5G402T282
    ...     '${tl_prefix}'=='T073'    7_5_CLOUD402T073
    ...     '${tl_prefix}'=='T283'    7_5_UTE5G402T283
    ...     '${tl_prefix}'=='T813'    7_5_UTE5G402T813
    log to console    start to generate kpi report on compass for ${scout_name}
    ${excel_report_path_on_ute}    Create List
    FOR   ${timestamp}    IN    @{report_timestamps}
       ${status}   ${excel_report}    Run Keyword And Ignore Error    KPI.Generate kpi report in Scout    tl_name=${scout_name}
       ...    start_time=${timestamp[0]}
       ...    end_time=${timestamp[1]}
       ...    comments=${comments}
       ...    template_name=${template_name}
       ...    check_out_entry=${check_out_entry}
       ...    gnb_index=${gnb_index}
       ...    connection=${connection}
       Run Keyword If    '${status}'=='PASS'    Append To List    ${excel_report_path_on_ute}    ${excel_report}
       ${report_name}    Run Keyword If    '${status}'=='PASS'    Set Variable    ${excel_report.split('/')[-1]}
       ${test_case_id}    Set Variable    ${TEST NAME.split('_')[0]}
       Run Keyword And Ignore Error    Run Keyword If    '${status}'=='PASS'    upload_files_to_remote_server
       ...    local_path=${excel_report}
       ...    remote_path=/home/hz4sg6/shared_dir/SG6/01_RepTest/${test_case_id}/${test_case_id}_${tl_prefix}/Excel_KPI/${report_name}
    END
    log    ${excel_report_path_on_ute}
    log    ${report_timestamps}
    ${report_length}    Get Length    ${excel_report_path_on_ute}
    Run keyword If    '${report_length}'=='${0}'    fail    msg=no available report get from this round test.
   [Return]    ${excel_report_path_on_ute}

Record KPI Report To UTE PC
    [Arguments]   ${excel_report_path_on_ute}
    ...           ${filter_distnames}=bts,NRCELL-301
    ...           ${group_name}=${None}
    ...           ${gnb_index}=${0}
    ...           ${connection}=GNB_OAM${gnb_index}
    ...           ${output_excel_name}=KPI_5605004.xlsx
    ${filter_distnames}    Set Variable    ${filter_distnames.split(',')}
#    ${btsName}    ${gnb_version}     Get BtsName and SwVersion    gnb_id=${gnb_index}    connection=${connection}
    log to console    start to record kpi report for ${gnb_version} on ute
    ${test_case_id}    Set Variable    ${TEST NAME.split('_')[0]}
    ${output_report_path}    Set Variable    ${report_path_on_ute}/${test_case_id}/${tl_prefix}_${output_excel_name}
    ${reproduce_kpi_values_list}    Create List
    FOR    ${excel_report}    IN    @{excel_report_path_on_ute}
       ${report_time}    Set Variable    ${excel_report.split('.')[0].split('/')[-1].split('_')[-1]}
       ${reproduce_kpi_values_dict}    Run Keyword And Continue On Failure
       ...    generate_kpi_report_based_on_scout_report
       ...    sw_version=${gnb_version}
       ...    scf_name=${btsName}
       ...    scout_report_time=${report_time}
       ...    excel_report_path=${excel_report}
       ...    output_report_path=${output_report_path}
       ...    filter_distnames=${filter_distnames}
       ...    group_name=${group_name}
       Append To List    ${reproduce_kpi_values_list}    ${reproduce_kpi_values_dict}
   END
#   Run Keyword And Ignore Error    OperatingSystem.Copy File    ${output_report_path}    ${report_path_on_ute}/Backup/
   ${remote_server_store_path}    Catenate
   ...    /home/hz4sg6/shared_dir/SG6/01_RepTest/${test_case_id}/${test_case_id}_${tl_prefix}/Scout_KPI_Report/
   ...    ${tl_prefix}_${output_excel_name}
   Run Keyword And Ignore Error    upload_files_to_remote_server
       ...    local_path=${output_report_path}
       ...    remote_path=${remote_server_store_path}
   [Return]    ${reproduce_kpi_values_list}

Generate And Record Total KPI Report To Compass And UTE
    [Arguments]   ${report_timestamps}
    ...           ${total_template_name}=List1_KPI_TMO_24R1_SA_SG6
    ...           ${comments}=5605005
    ...           ${filter_distnames}=bts,NRCELL-301
    ...           ${gnb_index}=${0}
    ${total_excel_report_path}    Generate KPI Report And Record To Compass
    ...                           report_timestamps=${report_timestamps}
    ...                           comments=PZ4_SG06_${comments}_${total_template_name}
    ...                           template_name=${total_template_name}
    ...                           gnb_index=${gnb_index}
    ${reproduce_kpi_values}    Run Keyword And Continue On Failure    Record KPI Report To UTE PC
    ...                        excel_report_path_on_ute=${total_excel_report_path}
    ...                        filter_distnames=${filter_distnames}
    ...                        output_excel_name=${comments}_${total_template_name}.xlsx
    ...                        gnb_index=${gnb_index}
    ${total_kpi_info}    Create Dictionary    swbuild_info=${gnb_version}_${btsName}
    ...                                       report_period=${report_timestamps}
    ...                                       excel_report_path=${total_excel_report_path}
    ...                                       reproduce_kpi_values=${reproduce_kpi_values}
    [Return]    ${total_kpi_info}

Generate And Record Reproduce KPI Report To Compass And UTE
    [Arguments]   ${report_timestamps}
    ...           ${rep_template_name}=List5_KPI_TMO_Reproduction_CRT_241125
    ...           ${comments}=5605005
    ...           ${filter_distnames}=bts,NRCELL-301
    ...           ${gnb_index}=${0}
    ...           ${group_name}=PR03841043
    ${reproduce_excel_report_path}    Generate KPI Report And Record To Compass
    ...                               report_timestamps=${report_timestamps}
    ...                               comments=PZ4_SG06_${comments}_${rep_template_name}
    ...                               template_name=${rep_template_name}
    ...                               gnb_index=${gnb_index}
    ${reproduce_kpi_values}    Run Keyword And Continue On Failure    Record KPI Report To UTE PC
    ...                        excel_report_path_on_ute=${reproduce_excel_report_path}
    ...                        filter_distnames=${filter_distnames}
    ...                        output_excel_name=${comments}_${rep_template_name}.xlsx
    ...                        gnb_index=${gnb_index}
    ...                        group_name=${group_name}
    ${reproduce_kpi_info}    Create Dictionary    swbuild_info=${gnb_version}_${btsName}
    ...                                           report_period=${report_timestamps}
    ...                                           excel_report_path=${reproduce_excel_report_path}
    ...                                           reproduce_kpi_values=${reproduce_kpi_values}
    [Return]    ${reproduce_kpi_info}

Generate And Record Energy Saving KPI Report To Compass And UTE
    [Arguments]   ${report_timestamps}
    ...           ${rep_template_name}=List4_KPI_TMO_Energy_Saving_Bundle_SG6
    ...           ${comments}=5605006
    ...           ${filter_distnames}=bts,NRCELL-301
    ...           ${gnb_index}=${0}
    ${reproduce_excel_report_path}    Generate KPI Report And Record To Compass
    ...                               report_timestamps=${report_timestamps}
    ...                               comments=PZ4_SG06_${comments}_${rep_template_name}
    ...                               template_name=${rep_template_name}
    ...                               gnb_index=${gnb_index}
    ${reproduce_kpi_values}    Run Keyword And Continue On Failure    Record KPI Report To UTE PC
    ...                        excel_report_path_on_ute=${reproduce_excel_report_path}
    ...                        filter_distnames=${filter_distnames}
    ...                        output_excel_name=${comments}_${rep_template_name}.xlsx
    ...                        gnb_index=${gnb_index}
    ${reproduce_kpi_info}    Create Dictionary    swbuild_info=${gnb_version}_${btsName}
    ...                                           report_period=${report_timestamps}
    ...                                           excel_report_path=${reproduce_excel_report_path}
    ...                                           reproduce_kpi_values=${reproduce_kpi_values}
    [Return]    ${reproduce_kpi_info}

Generate And Record New Lis 1025 To Compass And UTE
    [Arguments]   ${report_timestamps}
    ...           ${rep_template_name}=List2_KPI_TMO_new_24R2_24R3
    ...           ${comments}=5605004
    ...           ${filter_distnames}=bts,NRCELL-301
    ...           ${gnb_index}=${0}
    ${reproduce_excel_report_path}    Generate KPI Report And Record To Compass
    ...                               report_timestamps=${report_timestamps}
    ...                               comments=PZ4_SG06_${comments}_${rep_template_name}
    ...                               template_name=${rep_template_name}
    ...                               gnb_index=${gnb_index}
    ${reproduce_kpi_values}    Run Keyword And Continue On Failure    Record KPI Report To UTE PC
    ...                        excel_report_path_on_ute=${reproduce_excel_report_path}
    ...                        filter_distnames=${filter_distnames}
    ...                        output_excel_name=${comments}_${rep_template_name}.xlsx
    ...                        gnb_index=${gnb_index}
    ${reproduce_kpi_info}    Create Dictionary    swbuild_info=${gnb_version}_${btsName}
    ...                                           report_period=${report_timestamps}
    ...                                           excel_report_path=${reproduce_excel_report_path}
    ...                                           reproduce_kpi_values=${reproduce_kpi_values}
    [Return]    ${reproduce_kpi_info}


Generate And Record Interference To Compass And UTE
    [Arguments]   ${report_timestamps}
    ...           ${rep_template_name}=List3_KPI_TMO_Interference
    ...           ${comments}=5605004
    ...           ${filter_distnames}=bts,NRCELL-301
    ...           ${gnb_index}=${0}
    ${reproduce_excel_report_path}    Generate KPI Report And Record To Compass
    ...                               report_timestamps=${report_timestamps}
    ...                               comments=PZ4_SG06_${comments}_${rep_template_name}
    ...                               template_name=${rep_template_name}
    ...                               gnb_index=${gnb_index}
    ${reproduce_kpi_values}    Run Keyword And Continue On Failure    Record KPI Report To UTE PC
    ...                        excel_report_path_on_ute=${reproduce_excel_report_path}
    ...                        filter_distnames=${filter_distnames}
    ...                        output_excel_name=${comments}_${rep_template_name}.xlsx
    ...                        gnb_index=${gnb_index}
    ${reproduce_kpi_info}    Create Dictionary    swbuild_info=${gnb_version}_${btsName}
    ...                                           report_period=${report_timestamps}
    ...                                           excel_report_path=${reproduce_excel_report_path}
    ...                                           reproduce_kpi_values=${reproduce_kpi_values}
    [Return]    ${reproduce_kpi_info}

Generate And Record Slice To Compass And UTE
    [Arguments]   ${report_timestamps}
    ...           ${rep_template_name}=List7_KPI_TMO_Slice_SG6
    ...           ${comments}=5605004
    ...           ${filter_distnames}=bts,NRCELL-301
    ...           ${gnb_index}=${0}
    ${reproduce_excel_report_path}    Generate KPI Report And Record To Compass
    ...                               report_timestamps=${report_timestamps}
    ...                               comments=PZ4_SG06_${comments}_${rep_template_name}
    ...                               template_name=${rep_template_name}
    ...                               gnb_index=${gnb_index}
#    ${reproduce_kpi_values}    Run Keyword And Continue On Failure    Record KPI Report To UTE PC
#    ...                        excel_report_path_on_ute=${reproduce_excel_report_path}
#    ...                        filter_distnames=${filter_distnames}
#    ...                        output_excel_name=${comments}_${rep_template_name}.xlsx
#    ...                        gnb_index=${gnb_index}
#    ${reproduce_kpi_info}    Create Dictionary    swbuild_info=${gnb_version}_${btsName}
#    ...                                           report_period=${report_timestamps}
#    ...                                           excel_report_path=${reproduce_excel_report_path}
#    ...                                           reproduce_kpi_values=${reproduce_kpi_values}
#    [Return]    ${reproduce_kpi_info}

Record KPI Data To TestCase Path
    [Arguments]     ${kpi_info_list}
    ...             ${output_report_name}=total_kpi_result.xlsx
    ...             ${filter_distnames}=bts,NRCELL-301
    ...             ${group_name}=${None}
    ${filter_distnames}    Set Variable    ${filter_distnames.split(',')}
    generate_kpi_data_to_testcase_path   kpi_info_list=${kpi_info_list}
    ...                                  output_report_path=${TS_CASE_LOG_PATH}/${output_report_name}
    ...                                  filter_distnames=${filter_distnames}
    ...                                  group_name=${group_name}

Record Comparator KPI Report To UTE
    [Arguments]   ${compare_report_id}
    ...           ${excel_report_path_on_ute}
    ...           ${filter_distnames}=BTS,NRCELL-301
    ...           ${output_report_prefix}=5605004_reproduce
    ${filter_distnames}    Set Variable    ${filter_distnames.split(',')}
    log to console    start to record comparator kpi report for ${output_report_prefix} template on ute
    ${output_report_path}    extract_compare_data_from_scout
    ...    compare_report_id=${compare_report_id}
    ...    excel_report_path=${excel_report_path_on_ute}
    ...    output_report_prefix=${output_report_prefix}
    ...    filter_distnames=${filter_distnames}
    ${report_name}     Set Variable    ${output_report_path.split('/')[-1]}
    ${remote_server_store_path}    Catenate
    ...    /home/hz4sg6/shared_dir/SG6/01_RepTest/${test_case_id}/${test_case_id}_${tl_prefix}/Comparator_Report/${report_name}
    Run Keyword And Ignore Error    upload_files_to_remote_server
    ...    local_path=${output_report_path}
    ...    remote_path=${remote_server_store_path}



Generate And Record Comparator Report On Compass And UTE
    [Arguments]    ${excel_report_path_on_ute}
    ...            ${filter_distnames}
    ...            ${output_report_prefix}
    ...            ${first_description}
    ...            ${first_start_time}
    ...            ${first_end_time}
    ...            ${second_description}
    ...            ${second_start_time}
    ...            ${second_end_time}
    ...            ${template_names_list}=SG6_KPI_TMO_Reproduction_CRT
    ...            ${template_id_list}=1036
    ...            ${alpha_factor}=0.005
    ...            ${comments}=" "
    ...            ${gnb_index}=${0}
    ${compare_report_id}    KPI.Generate Comparator Report On Compass
    ...            first_description=${first_description}
    ...            first_start_time=${first_start_time}
    ...            first_end_time=${first_end_time}
    ...            second_description=${second_description}
    ...            second_start_time=${second_start_time}
    ...            second_end_time= ${second_end_time}
    ...            template_names_list=${template_names_list}
    ...            template_id_list=${template_id_list}
    ...            alpha_factor=${alpha_factor}
    ...            comments=${comments}
    ...            gnb_index=${gnb_index}
    Record Comparator KPI Report To UTE    compare_report_id=${compare_report_id}
    ...    excel_report_path_on_ute=${excel_report_path_on_ute}
    ...    output_report_prefix=${output_report_prefix}
    ...    filter_distnames=${filter_distnames}
