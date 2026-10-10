# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Lei Jia
:contact: lei.jia@nokia-sbell.com
"""
import base64
import json
import os.path
import re
import openpyxl
from openpyxl.styles import Border, Side, PatternFill, Alignment, Font
import os
import logging
from set_pandas import *
import time
import paramiko
import requests
import yaml
from collections import OrderedDict
from openpyxl import load_workbook



pd = None
np = None
plt = None


REPRODUCE_KPI_NAME_LIST = [
    "NR_5057e",
    "SCOUT_NR_1418",
    "SCOUT_NR_1419a",
    "M55124C03006",
    "M55125C09029",
    "M55124C00505",
    "M55351C00001",
    "M55351C00002",
    "M55124C03001",
    "M55124C03002",
    "M55118C07003",
    "M55125C09005",
    "M55118C07004",
    "M55129C00004",
    "M55129C00003",
    "NR_5108e",
    "M55150C00035",
]


class DownloadKpiFile:
    def __init__(
        self,
        compass_url="http://compass.dyn.nesc.nokia.net:8080/kpi/generate_kpi_report/",
        compare_url="http://compass.dyn.nesc.nokia.net:8080/kpi/scout_comparator_report/"
        "generate_comparator_report/",
    ):
        self.compass_generate_kpi_report_url = compass_url
        self.compass_generate_comparator_report_url = compare_url
        self.common_user_agent = (
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) "
            "Chrome/120.0.0.0 Safari/537.36"
        )

    @staticmethod
    def get_time():
        """
        Get the current time.
        :return: the current time
        """
        return time.strftime("%Y-%m-%d %H:%M", time.localtime())

    @staticmethod
    def get_parameter_info(file_path):
        """
        Get the parameters from the yaml file.
        FYI: testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/kpi_report_releated_parameters.yml
        :param file_path: the path of the yaml file
        :return: the data in the yaml file
        """
        with open(file_path, "r") as f:
            data = yaml.safe_load(f)
        return data
    def generate_new_report(
        self,
        report_name,
        tl_id,
        package_version,
        template_name,
        start_time,
        end_time,
        comments="",
        check_out_entry="false",
    ):
        """
        Generate a new report on Compass.
        :param report_name: the name of the report
        :param tl_id: the test line id e.g. 335
        :param package_version: the package version
        :param template_name: the template name
        :param start_time: the start time of the report
        :param end_time: the end time of the report
        :param comments: the comments of the report
        :param check_out_entry: the check out entry value "true" or "false", so that to generate chart
        :return: the report id
        """
        headers = {"cookie": f"name=m1shi; sessionid=kwm3keqgqn9if8bc1io1wm5g2rlom9el"}
        data = {
            "report_name": report_name,
            "test_line": f"{tl_id}",
            "package_version": package_version,
            "template_name": template_name,
            "start_time": start_time,
            "end_time": end_time,
            "comments": comments,
            "check_out_entry": str(check_out_entry),
        }
        """
        resp.json()
        {"success": true, "error": "", "data": {"id": "68722", "name": "test_2024-06-21T06:13:18.993134",
        "package": "2.0", "start_time": "2024-06-19 16:29:00", "end_time": "2024-06-20 17:00:00",
        "kpi_template_id": "1698", "comments": "test1", "kpi_template__name": "CHZ_SG3_TMO_SA_KPI",
        "testlines": "7_5_UTE5G402T335", "testline_ids": "TL_5085"}}
        """
        for i in range(5):
            try:
                resp=requests.post(url=self.compass_generate_kpi_report_url, headers=headers, data=data)
                if resp.status_code == 200:
                    logging.debug("resp for report id is {}".format(resp.json()))
                    if str(resp.json()["success"]) == "True":
                        print("Generate kpi report successfully.")
                        kpi_report_id = int(resp.json()["data"]["id"])
                        break
                    elif str(resp.json()["success"]) == "false":
                        print(
                            f"Failed to generate new report. error reason. error reason: {resp.json()['error']}"
                        )
                        time.sleep(30)
                        logging.debug(
                            "wait for 30sec for try to generate kpi report again"
                        )
                        kpi_report_id = None
            except Exception as e:
                print("Connection refused by the server..")
                time.sleep(15)
                print("Was a nice sleep, now let me continue...")
        return kpi_report_id

    def generate_comparator_report(
        self,
        test_line_id,
        test_line_name,
        report_name,
        template_names_list,
        template_id_list,
        first_description,
        first_start_time,
        first_end_time,
        second_description,
        second_start_time,
        second_end_time,
        alpha_factor=0.05,
        comments=" ",
    ):
        """
        Generate a new report on Compass.
        :param report_name: the name of the report
        :param tl_id: the test line id e.g. 335
        :param package_version: the package version
        :param template_name: the template name
        :param start_time: the start time of the report
        :param end_time: the end time of the report
        :param comments: the comments of the report
        :param check_out_entry: the check out entry value "true" or "false", so that to generate chart
        :return: the report id
        """
        headers = {"cookie": f"name=m1shi; sessionid=kwm3keqgqn9if8bc1io1wm5g2rlom9el"}
        data = {
            "test_line_id": test_line_id,
            "test_line_name": test_line_name,
            "report_name": report_name,
            "template_names": template_names_list,
            "template_id_list": template_id_list,
            "first_period_description": first_description,
            "first_start_time": first_start_time,
            "first_end_time": first_end_time,
            "second_period_description": second_description,
            "second_start_time": second_start_time,
            "second_end_time": second_end_time,
            "alpha": float(alpha_factor),
            "comments": comments,
        }
        for i in range(5):
            try:
                resp=requests.post(url=self.compass_generate_comparator_report_url, headers=headers, data=data)
                if resp.status_code == 200:
                    logging.debug("resp for report id is {}".format(resp.json()))
                    if str(resp.json()["success"]) == "True":
                        print("Generate kpi report successfully.")
                        kpi_report_id = int(resp.json()["data"]["comparator_report_id"])
                        break
                    elif str(resp.json()["success"]) == "false":
                        print(
                            f"Failed to generate new comparator report. error reason: {resp.json()['error']}"
                        )
                        time.sleep(30)
                        logging.debug(
                            "wait for 30sec for try to generate kpi report again"
                        )
                        kpi_report_id = None
            except Exception as e:
                print("Connection refused by the server..")
                time.sleep(15)
                print("Was a nice sleep, now let me continue...")
        return kpi_report_id

    def get_scout_token(self, username, password):
        """
        Get the Scout token.
        :param username: the username
        :param password: the password
        :return: the Scout token
        """
        url = "https://scout.nsn-rdnet.net/future/api/v1/api_token_obtain/"
        data = {
            "data": {
                "type": "obtain_json_web_token",
                "attributes": {"username": username, "password": password},
            }
        }
        headers = {
            "User-Agent": self.common_user_agent,
            "Accept": "application/vnd.api+json",
            "Content-Type": "application/vnd.api+json",
        }
        with requests.post(url=url, json=data, headers=headers) as resp:
            return resp.json()["data"]["attributes"]["token"]

    def get_kpi_report(self, response, path):
        """
        Get the KPI report.
        :param response: the response of the request
        :param path: the path to save the KPI report
        """
        headers_2 = {
            "User-Agent": self.common_user_agent,
        }
        pattern = re.compile(r"(?P<url>https://.*?\.xlsx)")
        excel_url = (
            re.search(pattern, response.json()["errors"][0]["detail"])
            .group("url")
            .strip()
        )
        print(excel_url)
        with requests.get(url=excel_url, headers=headers_2) as resp_2:
            print(resp_2.status_code)
            filename = excel_url.split("/")[-1]
            excel_file_name = os.path.join(path, filename)
            if resp_2.status_code == 200:
                with open(excel_file_name, "wb") as f:
                    f.write(resp_2.content)
        return excel_file_name

    def download_kpi_result_file(self, report_id, path, is_compare_kpi=False):
        """
        Download the KPI result file.
        :param report_id: the report id
        :param path: the path to save the KPI result file
        """
        authorization = self.get_scout_token(
            username=base64.b64decode(b"bTFzaGk=").decode("utf-8"),
            password=base64.b64decode(b"UWF6d3N4ZWRjcmZ2dGdiNg==").decode("utf-8"),
        )
        report_url = f"https://scout.nsn-rdnet.net/future/api/v1/kpis_reports/{report_id}/export_to_excel/"
        compare_url = f"https://scout.nsn-rdnet.net/future/api/v1/comparator_reports/{report_id}/export_to_excel/"
        if is_compare_kpi:
            url = compare_url
        else:
            url = report_url
        headers = {
            "User-Agent": self.common_user_agent,
            "Authorization": f"JWT {authorization}",
            # "Authorization": "JWT eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjox"
            #                  "NzMwMDk0NTIxLCJpYXQiOjE3Mjk0ODk3MjEsImp0aSI6IjUwZDVlMWJjZTY5NDRiNWRiNDM3OTk4N2I5Z"
            #                  "DRlM2M2IiwidXNlcm5hbWUiOiJzdGxpbiIsImVtYWlsIjoic3RlbGxhLmxpbkBub2tpYS1zYmVsbC5jb2"
            #                  "0iLCJpZCI6MzM3MCwiZGlzcGxheV9uYW1lIjoiU3RlbGxhIExpbiAoTlNCKSJ9.5ph7XrhzXtP9GTmv3t"
            #                  "eZLEKI-dDHt6JAXs_oFcfuqgQ",
        }
        """
        resp.json()
        1. {'data': 'Scout is preparing your KPI report. Details will be sent to ming.shi@nokia-sbell.com'}
        2. {'errors': [{'detail': "You're KPI report already exist as excel file in our storage.
        If you want you can download this file from :
        https://es-si-s3-z2.eecloud.nsn-net.net/scout.reports/2024-06-20/test_2024-06-20T093229638119.xlsx",
        'status': '400', 'source': {'pointer': '/data'}}]}
        """
        for i in range(12):
            with requests.get(url=url, headers=headers) as resp:
                print(resp.json())
                if list(resp.json().keys())[0] == "errors" and (
                    "You're KPI report already exist as excel file in our "
                    "storage" in resp.json()["errors"][0]["detail"]
                ):
                    excel_file_name = self.get_kpi_report(response=resp, path=path)
                    break
                else:
                    print("waif for 300s to get the KPI report.")
                    time.sleep(300)
        return excel_file_name


def round_to_3decimal(value):
    """
    author: jun.8.chen@nokia-sbell.com
    """
    try:
        return round(value, 3)
    except TypeError:
        return "N/A"


def get_data_from_scout_reports(kpis, x):
    """
    author: lei.jia@nokia-sbell.com
    """
    group_name = kpis[x]["group_name"]
    code = kpis[x]["code"]
    name = kpis[x]["name"]
    entry_name = "[" + code + "]" + " " + name
    value = kpis[x]["global_result"]["value"]
    unit = kpis[x].get("unit")
    rounded_value = round_to_3decimal(value)
    return group_name, entry_name, unit, rounded_value


def generate_excel_data(
    scout_report, file_path=None, stream_version=None, scf_version=None, try_index=0
):
    """
    author: lei.jia@nokia-sbell.com
    Generate excel data from scout KPI report.
    :param scout_report: scout KPI report
    :param file_path: path of created file. If None file is created in robot logs path.
    :param stream_version: for example 24R2
    :param scf_version: 24R1/24R2 and so on
    :param try_index: it is first, second or third try. Each turn try three times.
    :return: None
    """
    data_dict = {}
    group_name_list = []
    unit_name_list = []
    entry_name_list = []
    rounded_value_list = []
    value_column_name = (
        "SW" + stream_version + "_SCF" + scf_version + "_try" + str(try_index)
    )

    KPIs = scout_report[0]["report"]
    start_time = scout_report[0]["start_time"]
    end_time = scout_report[0]["end_time"]
    len_of_KPIs = len(KPIs)
    for x in range(len_of_KPIs):
        group_name, entry_name, unit_value, rounded_value = get_data_from_scout_reports(
            KPIs, x
        )
        group_name_list.append(group_name)
        entry_name_list.append(entry_name)
        unit_name_list.append(unit_value)
        rounded_value_list.append(rounded_value)
    data_dict["Group name"] = group_name_list
    data_dict["Entry name"] = entry_name_list
    data_dict["Unit"] = unit_name_list
    data_dict[value_column_name] = rounded_value_list
    return data_dict, start_time, end_time


def generate_excel_report(
    scout_report,
    file_path=None,
    sw_version=None,
    stream_version=None,
    scf_version=None,
    try_index=0,
):
    """
    author: lei.jia@nokia-sbell.com
    Generate excel from scout KPI report.
    :param scout_report: scout KPI report
    :param file_path: path of created file. If None file is created in robot logs path.
    :param sw_version: gnb active sw version
    :param stream_version: for example 24R2
    :param scf_version: 24R1/24R2 and so on
    :param try_index: it is first, second or third try. Each turn try three times.
    :return: None
    """
    init_pandas()
    data_dict, start_time, end_time = generate_excel_data(
        scout_report=scout_report,
        file_path=file_path,
        stream_version=stream_version,
        scf_version=scf_version,
        try_index=try_index,
    )

    df_the_dict = pd.DataFrame(data_dict)
    # adding a row for start time
    df_the_dict.loc[-1] = [None, None, None, "start_time: " + start_time]
    df_the_dict.index = df_the_dict.index + 1  # shifting index
    # adding a row for sw version
    df_the_dict.loc[-1] = [None, None, None, sw_version]
    df_the_dict.index = df_the_dict.index + 1  # shifting index
    df_the_dict = df_the_dict.sort_index()
    dir_name = os.path.dirname(file_path)
    if not os.path.exists(dir_name):
        os.makedirs(dir_name)
    df_the_dict.to_excel(file_path, index=False)


def concatenates_excel_report(
    input_file_paths, output_file_path, source_stream=None, target_stream=None
):
    """
    author: lei.jia@nokia-sbell.com
    concatenates all input Excel files into one and generate avg KPI data for source streams and target stream.
    :param input_file_paths: path for all input excels.
    :param output_file_path: output Excel file.
    :param source_stream: 24R1/24R2/24R3 before gnb upgrade
    :param target_stream: 24R2/24R3 after gnb upgrade
    :return: None
    """
    init_pandas()
    output_df = pd.DataFrame()
    for index, infile in enumerate(input_file_paths):
        input_df = pd.read_excel(infile)
        if index == 0:
            output_df = pd.concat([output_df, input_df], ignore_index=True)
        else:
            output_df = pd.concat([output_df, input_df.iloc[:, -1:]], axis=1)
    # generate 3 times avg KPI report: (before upgrade)source_stream_with_source_scf
    #                                  (after_upgrade)target_stream_source_scf
    #                                  (after_upgrade_load_new_scf)target_stream_target_scf
    generate_avg_kpi_data_based_on_stream_version(
        df=output_df, stream_version=source_stream, scf_version=source_stream
    )
    generate_avg_kpi_data_based_on_stream_version(
        df=output_df, stream_version=target_stream, scf_version=source_stream
    )
    generate_avg_kpi_data_based_on_stream_version(
        df=output_df, stream_version=target_stream, scf_version=target_stream
    )
    output_df.to_excel(output_file_path)


def generate_avg_kpi_data_based_on_stream_version(
    df=None, stream_version=None, scf_version=None
):
    """
    author: lei.jia@nokia-sbell.com
    calculate avg KPI data based on try0/1/2 for one stream
    :param df: df = pd.read_excel(file_path)
    :param stream_version: 24R1/24R2/24R3
    :param scf_version: 24R1/24R2/24R3
    :return: None
    """
    # df = pd.read_excel(file_path)
    check_string = "SW" + stream_version + "_SCF" + scf_version
    stream_cols = [col for col in df.columns if check_string in col]
    # col_index_list = [df.columns.get_loc(c) for c in stream_cols]
    avg_column_name = "avg_" + check_string
    df[avg_column_name] = df[stream_cols].iloc[2:].mean(axis=1)
    # df.to_excel(file_path)


def compare_avg_kpi_data(file_path):
    """
    author: lei.jia@nokia-sbell.com
    compare avg KPI data for 2 streams: for example avg_kpi_data from previous stream, avg_kpi_data after gnb upgrade.
    :param file_path: path of created file. If None file is created in robot logs path.
    :return: None
    """
    init_pandas()
    df = pd.read_excel(file_path)
    check_string = "avg"
    avg_col_name_list = [col for col in df.columns if check_string in col]
    col_index_list = [df.columns.get_loc(c) for c in avg_col_name_list]
    for index, column_index in enumerate(col_index_list):
        if index == len(col_index_list) - 1:
            continue
        else:
            new_column_name = (
                avg_col_name_list[index + 1][4:] + "_VS_" + avg_col_name_list[index][4:]
            )
            df[new_column_name] = (
                df.iloc[:, col_index_list[index + 1]]
                - df.iloc[:, col_index_list[index]]
            ) / df.iloc[:, col_index_list[index]]
    df.to_excel(file_path, index=False)


def set_font_color_for_kpi_date(file_path):
    """
    author: lei.jia@nokia-sbell.com
    set font for compared results, red for <-0.1, green for >-0.1.
    using openpyxl due to df.style.apply need pandas version for about 3.0
    :param file_path: path of created file. If None file is created in robot logs path.
    :return: None
    """
    wb = openpyxl.load_workbook(file_path)
    ws = wb.active
    red_Font = Font(color="c00000")
    green_Font = Font(color="00FF00")
    black_Font = Font(color="000000")
    max_col_end = ws.max_column
    max_row_end = ws.max_row
    # get column index for including "VS"
    rows = ws.iter_rows(min_row=1, max_row=1)  # returns a generator of rows
    first_row = next(rows)  # get the first row
    heading_list = [c.value for c in first_row]  # extract the values from the cells
    for col_name in heading_list[1:]:
        if "VS" in col_name:
            vs_col_index = heading_list.index(col_name)

    # set header wrap text
    for row in ws.iter_rows(min_row=1, max_row=2, min_col=None, max_col=None):
        for cell in row:
            cell.alignment = Alignment(wrap_text=True)

    # set compared KPI data(column like "SW24R2_SCF24R2_VS_SW24R2_SCF24R1") with font red or green
    for row in ws.iter_rows(
        min_row=4, max_row=max_row_end, min_col=vs_col_index, max_col=max_col_end
    ):
        for cell in row:
            if isinstance(cell.value, (float, int)):
                if cell.value <= -0.1:
                    cell.font = red_Font
                else:
                    cell.font = green_Font
                # change to 100% percentage
                cell.value = cell.value * 100
                cell.value = round(cell.value, 2)
            else:
                cell.font = black_Font
    wb.save(file_path)


def concatenates_excel_report_and_compare_kpi_data(
    input_file_paths, output_file_path, source_stream=None, target_stream=None
):
    concatenates_excel_report(
        input_file_paths=input_file_paths,
        output_file_path=output_file_path,
        source_stream=source_stream,
        target_stream=target_stream,
    )
    compare_avg_kpi_data(file_path=output_file_path)
    set_font_color_for_kpi_date(file_path=output_file_path)


def download_kpi_file(report_id, path, is_compare_kpi=False):
    dpf = DownloadKpiFile()
    excel_file_name = dpf.download_kpi_result_file(
        report_id=report_id, path=path, is_compare_kpi=is_compare_kpi
    )
    return excel_file_name


def generate_new_report_on_compass(
    report_name,
    tl_id,
    package_version,
    start_time,
    end_time,
    comments="",
    template_name="KPI_24R1_TMO_SA_SG6",
    check_out_entry="false",
):
    # template_name = DownloadKpiFile.get_parameter_info(file_path=file_path)["template_name"]
    # if template_name is None:
    #     print("Failed to get the template name.")
    #     raise Exception("Failed to get the template name. please check yaml file")
    dpf = DownloadKpiFile()
    report_id = dpf.generate_new_report(
        report_name=report_name,
        tl_id=tl_id,
        package_version=package_version,
        template_name=template_name,
        start_time=start_time,
        end_time=end_time,
        comments=comments,
        check_out_entry=check_out_entry,
    )
    return report_id


def generate_new_comparator_report_on_compass(
    test_line_id,
    test_line_name,
    report_name,
    template_names_list,
    template_id_list,
    first_description,
    first_start_time,
    first_end_time,
    second_description,
    second_start_time,
    second_end_time,
    alpha_factor=0.05,
    comments=" ",
):
    # template_name = DownloadKpiFile.get_parameter_info(file_path=file_path)["template_name"]
    # if template_name is None:
    #     print("Failed to get the template name.")
    #     raise Exception("Failed to get the template name. please check yaml file")
    dpf = DownloadKpiFile()
    report_id = dpf.generate_comparator_report(
        report_name=report_name,
        test_line_id=test_line_id,
        test_line_name=test_line_name,
        template_names_list=template_names_list,
        template_id_list=template_id_list,
        first_description=first_description,
        first_start_time=first_start_time,
        first_end_time=first_end_time,
        second_description=second_description,
        second_start_time=second_start_time,
        second_end_time=second_end_time,
        alpha_factor=alpha_factor,
        comments=comments,
    )
    return report_id


def generate_kpi_report_based_on_scout_report(
    sw_version,
    scf_name,
    scout_report_time,
    excel_report_path,
    output_report_path,
    filter_distnames=[],
    group_name=None,
):
    """
    author: stella.lin@nokia-sbell.com
    compare avg KPI data for 2 streams: for example avg_kpi_data from previous stream, avg_kpi_data after gnb upgrade.
    :param file_path: path of created file. If None file is created in robot logs path.
    :return: None
    """
    init_pandas()
    df_empty = pd.DataFrame()
    logging.debug("file is {}".format(output_report_path))
    output_report_dir = "/".join(output_report_path.split("/")[0:6])
    logging.debug("dir is {}".format(output_report_dir))
    if os.path.exists(output_report_path):
        pass
    else:
        if os.path.exists(output_report_dir):
            with pd.ExcelWriter(output_report_path) as writer:
                df_empty.to_excel(
                    writer,
                    sheet_name="bts",
                    index=False,
                    engine="xlsxwriter",
                )
        else:
            os.makedirs(os.path.dirname(output_report_path))
            with pd.ExcelWriter(output_report_path) as writer:
                df_empty.to_excel(
                    writer,
                    sheet_name="bts",
                    index=False,
                    engine="xlsxwriter",
                )
    df_details = pd.read_excel(excel_report_path, sheet_name="Chart Data")
    reproduce_kpi_values_dict = {}
    if group_name is not None:
        df_details = df_details[df_details.GroupName.str.contains(group_name)]
    for filter_disname in filter_distnames:
        try:
            df_original = pd.read_excel(output_report_path, sheet_name=filter_disname)
            original_counter_name_list = list(df_original.columns)
        except Exception as e:
            original_counter_name_list = []
        res = {
            "ReportTime": [scout_report_time],
            "SwVersion": [sw_version],
            "ScfName": [scf_name],
        }
        df_summary_new = pd.DataFrame(data=res)
        wb = load_workbook(output_report_path, read_only=False)
        if filter_disname in wb.sheetnames:
            df_summary_orig = pd.read_excel(
                output_report_path, sheet_name=filter_disname
            )
        else:
            wb.create_sheet(filter_disname)
            wb.save(output_report_path)
            df_summary_orig = pd.read_excel(
                output_report_path, sheet_name=filter_disname
            )
        filter_df_with_dist_name = df_details[
            df_details.DistName.str.contains(filter_disname)
        ]
        counter_name_list = filter_df_with_dist_name["EntryName"].values
        counter_name_list = list(set(counter_name_list))
        for counter_name in counter_name_list:
            couter_prefix = counter_name.split("[")[-1].split("]")[0]
            filter_df_counter = filter_df_with_dist_name[
                filter_df_with_dist_name.EntryName.str.contains(couter_prefix)
            ]
            counter_sum = filter_df_counter["Value"].sum()
            if couter_prefix in REPRODUCE_KPI_NAME_LIST:
                logging.debug(
                    "{} vaues is {}".format(couter_prefix, filter_df_counter["Value"])
                )
                # if couter_prefix == "NR_5108e":
                #     logging.debug(
                #         "NR_5108e value list is{}".format(filter_df_counter["Value"])
                #     )
                #     counter_sum = filter_df_counter["Value"][3:5].sum()
                reproduce_kpi_values_dict[couter_prefix] = float(counter_sum)
            counter_sum_list = [counter_sum]
            couter_prefix_full = couter_prefix + "]"
            index = [
                i
                for i, e in enumerate(original_counter_name_list)
                if couter_prefix_full in e
            ]
            if len(index) == 0:
                counter_name_new = counter_name
                logging.debug("counter name new is {}".format(counter_name_new))
            else:
                counter_name_new = original_counter_name_list[index[0]]
            context = {counter_name_new: counter_sum_list}
            df_add_counter = pd.DataFrame(data=context)
            df_summary_new = pd.concat([df_summary_new, df_add_counter], axis=1)
        df_summary_final = pd.concat(
            [df_summary_orig, df_summary_new], ignore_index=True
        )
        df_summary_final = df_summary_final.round(2)
        with pd.ExcelWriter(
            output_report_path, mode="a", engine="openpyxl", if_sheet_exists="replace"
        ) as writer:
            df_summary_final.to_excel(writer, sheet_name=filter_disname, index=False)
    return reproduce_kpi_values_dict


def generate_kpi_data_to_testcase_path(
    kpi_info_list,
    output_report_path,
    filter_distnames=[],
    group_name=None,
):
    init_pandas()
    dfs = []
    for kpi_info in kpi_info_list:
        swbuild_info = kpi_info["swbuild_info"]
        report_period = kpi_info["report_period"]
        report_period = str(report_period)
        logging.debug("report_period is {}".format(report_period))
        excel_report_path = kpi_info["excel_report_path"]
        for report in excel_report_path:
            df_details = pd.read_excel(report, sheet_name="Chart Data")
            if group_name is not None:
                df_details = df_details[df_details.GroupName.str.contains(group_name)]
            timestamp_list = df_details["TimeStamp"].values
            # timestamp_list = list(set(timestamp_list))
            timestamp_list = list(OrderedDict.fromkeys(timestamp_list))
            timestamp_list.append("SUM")
            logging.debug("timestamp_list is {}".format(timestamp_list))
            report_info_list = [swbuild_info for x in timestamp_list]
            report_period_list = [report_period for x in timestamp_list]
            df_summary = pd.DataFrame()
            df_frame_list = []
            for filter_disname in filter_distnames:
                logging.debug("filter_disname is {}".format(filter_disname))
                df_summary_new = pd.DataFrame()
                filter_df_with_dist_name = df_details[
                    df_details.DistName.str.contains(filter_disname)
                ]
                # logging.debug(
                #     "filter_df_with_dist_name is {}".format(filter_df_with_dist_name)
                # )
                counter_name_list = filter_df_with_dist_name["EntryName"].values
                counter_name_list = list(set(counter_name_list))
                # logging.debug(
                #     "all counter under {} is {}".format(filter_disname, counter_name_list)
                # )
                for counter_name in counter_name_list:
                    couter_prefix = counter_name.split("[")[-1].split("]")[0]
                    logging.debug("couter_prefix is {}".format(couter_prefix))
                    couter_prefix = couter_prefix + "]"
                    filter_df_counter = filter_df_with_dist_name[
                        filter_df_with_dist_name.EntryName.str.contains(couter_prefix)
                    ]
                    # logging.debug(
                    #     "filter_df_counter for {} is {}".format(
                    #         counter_name, filter_df_counter
                    #     )
                    # )
                    counter_timestamp_values = filter_df_counter["Value"]
                    counter_sum = filter_df_counter["Value"].sum()
                    context = {counter_name: counter_timestamp_values}
                    df_add_counter = pd.DataFrame(data=context)
                    df_add_counter = pd.concat(
                        [df_add_counter, pd.DataFrame({counter_name: [counter_sum]})],
                        ignore_index=True,
                    )
                    df_summary_new = pd.concat([df_summary_new, df_add_counter], axis=1)
                    logging.debug("df_summary_new  is {}".format(df_summary_new))
                df_frame_list.append(df_summary_new)
            df_summary = pd.concat(df_frame_list, axis=1, keys=filter_distnames)
            logging.debug("df_summary is {}".format(df_summary))
            df_summary.insert(2, "TimeStamps", timestamp_list, True)
            df_summary.insert(1, "SwBuild", report_info_list, True)
            df_summary.insert(0, "ReportPeriod", report_period_list, True)
            df_summary = df_summary.set_index(["ReportPeriod", "SwBuild", "TimeStamps"])
            dfs.append(df_summary)
    startrow = 0
    with pd.ExcelWriter(output_report_path) as writer:
        for df in dfs:
            logging.debug("df is {}".format(df))
            df.to_excel(
                writer,
                sheet_name="summary",
                index=True,
                startrow=startrow,
                engine="xlsxwriter",
            )
            startrow += df.shape[0] + 6


def combine_two_excel_result(first_excel, second_excel):
    init_pandas()
    df_1 = pd.read_excel(first_excel, sheet_name="Sheet")
    df_2 = pd.read_excel(second_excel, sheet_name="Sheet")
    frames = [df_1, df_2]
    result = pd.concat(frames)
    result.to_excel(first_excel, sheet_name="Sheet", index=False)


# def plot_kpi(report_path):
#     init_pandas()
#     df_data = pd.read_excel(report_path, sheet_name="output")
#     df_24R1=df_data[
#             df_data.SwBuild.str.contains('SBTS24R1')]
#     df_24R2=df_data[
#             df_data.SwBuild.str.contains('SBTS24R2')]
#     column_names = df_data.columns
#     logging.debug("column_names is {}".format(column_names))
#     df_24R1.set_index('StartTime')
#     x = df_24R1['StartTime'].values
#     y = df_24R1['[M55351C00001] Maximum number of UEs with active Power Saving BWP'].values
#     x1 = df_24R2['StartTime'].values
#     y1 = df_24R2['[M55351C00001] Maximum number of UEs with active Power Saving BWP'].values
#     # plt.xlim(0.00001, 5)
#     # plt.ylim(0.8, 1.4)
#     plt.plot(x, y, marker='o', linestyle='--', color='r',
#              label='24R1')
#     plt.plot(x, y1, marker='o', linestyle='--',color='g', label='24R2')
#     plt.xlabel('test_time')
#     plt.ylabel('counter_value')
#     plt.legend()
#     plt.title('M55351C00001')
#     plt.savefig('/home/ute/KPI_Report/test.png')

# def filter_data_from_excel_kpi_scout_report(
#     kpi_name,
#     sw_version,
#     tl_name,
#     start_time,
#     end_time,
#     excel_report_path,
#     output_report_path,
# ):
#     """
#     author: stella.lin@nokia-sbell.com
#     compare avg KPI data for 2 streams: for example avg_kpi_data from previous stream, avg_kpi_data after gnb upgrade.
#     :param file_path: path of created file. If None file is created in robot logs path.
#     :return: None
#     """
#     init_pandas()
#     df_details = pd.read_excel(excel_report_path, sheet_name="Chart Data")
#     df_orig = pd.read_excel(output_report_path, sheet_name="output")
#     res = {"StartTime": [start_time], "Testline": [tl_name], "SwBuild": [sw_version]}
#     df_new = pd.DataFrame(data=res)
#     for counter_item in kpi_name:
#         entry_name = counter_item.split(",")[0]
#         logging.debug("entry_name is {}".format(entry_name))
#         distname = counter_item.split(",")[1]
#         logging.debug("distname is {}".format(distname))
#         filter_df_1 = df_details[
#             df_details.EntryName.str.contains(entry_name)
#             & df_details.DistName.str.contains(distname)
#         ]
#         logging.debug("filter_df_1 is {}".format(filter_df_1))
#         # filter_df = filter_df_1[start_time <= filter_df_1.TimeStamp <= end_time]
#         filter_df = filter_df_1[filter_df_1.TimeStamp >= start_time]
#         logging.debug("filter_df is {}".format(filter_df))
#         filter_df = filter_df[filter_df.TimeStamp <= end_time]
#         logging.debug("filter_df is {}".format(filter_df))
#         # counter_full_name = filter_df["EntryName"][0]
#         counter_full_name = filter_df["EntryName"].values[0]
#         logging.debug("counter_full_name {}".format(counter_full_name))
#         counter_value = filter_df["Value"].sum()
#         logging.debug("sum value for {} is {}".format(entry_name, counter_value))
#         counter_value_list = [counter_value]
#         df_new[counter_full_name] = counter_value_list
#     df_final = pd.concat([df_orig, df_new], ignore_index=True)
#     # plot = df_final.plot(title="KPI_560005")
#     logging.debug("ori is {}".format(df_orig))
#     logging.debug("new is {}".format(df_new))
#     logging.debug("final is {}".format(df_final))
#     df_final.to_excel(output_report_path, sheet_name="output", index=False)


# def generate_kpi_report_based_on_scout_report(
#     sw_version,
#     scf_name,
#     scout_report_time,
#     operation_timestamps,
#     excel_report_path,
#     output_report_path,
#     filter_cell_index=301,
# ):
#     """
#     author: stella.lin@nokia-sbell.com
#     compare avg KPI data for 2 streams: for example avg_kpi_data from previous stream, avg_kpi_data after gnb upgrade.
#     :param file_path: path of created file. If None file is created in robot logs path.
#     :return: None
#     """
#     init_pandas()
#     df_base = pd.read_excel(excel_report_path, sheet_name="Base Report")
#     all_counter_names = df_base["EntryName"].values
#     df_details = pd.read_excel(excel_report_path, sheet_name="Chart Data")
#     df_summary_orig = pd.read_excel(output_report_path, sheet_name="summary")
#     df_original_orig = pd.read_excel(output_report_path, sheet_name="original")
#     res = {
#         "ReportTime": [scout_report_time],
#         "SwVersion": [sw_version],
#         "ScfName": [scf_name],
#     }
#     df_summary_new = pd.DataFrame(data=res)
#     # df_original_new = pd.DataFrame(data=res)
#     df_original_new = pd.DataFrame()
#     # ---filter with cell index---#
#     filter_df_with_cell_index = df_details[
#         df_details.DistName.str.contains("NRCELL-{}".format(filter_cell_index))
#     ]
#     filter_df_with_timestamp = pd.DataFrame()
#     # ---filter with operation timestamps---#
#     for timestamp in operation_timestamps:
#         filter_tmp = filter_df_with_cell_index[
#             filter_df_with_cell_index.TimeStamp >= timestamp[0]
#         ]
#         filter_tmp = filter_tmp[
#             filter_tmp.TimeStamp <= timestamp[1]
#         ]
#         logging.debug("filter_tmp is {}".format(filter_tmp))
#         filter_df_with_timestamp = pd.concat(
#             [filter_tmp, filter_df_with_timestamp], ignore_index=True
#         )
#     logging.debug("filter_df_with_timestamp is {}".format(filter_df_with_timestamp))
#     for counter in all_counter_names:
#         couter_prefix=counter.split('[')[-1].split(']')[0]
#         logging.debug("couter_prefix is {}".format(couter_prefix))
#         filter_df_counter = filter_df_with_timestamp[
#             filter_df_with_timestamp.EntryName.str.contains(couter_prefix)
#         ]
#         logging.debug("filter_df_counter for {} is {}".format(counter,filter_df_counter))
#         counter_sum = filter_df_counter["Value"].sum()
#         logging.debug("counter_sum for {} is {}".format(counter, counter_sum))
#         counter_details = filter_df_counter["Value"].values
#         counter_timestamp = filter_df_counter["TimeStamp"].values
#         logging.debug("counter_details for {} is {}".format(counter, counter_details))
#         logging.debug("counter_TimeStamp for {} is {}".format(counter, counter_timestamp))
#         counter_sum_list = [counter_sum]
#         df_summary_new[counter] = counter_sum_list
#         df_original_new["TimeStamp"] = counter_timestamp
#         df_original_new[counter] = counter_details
#         df_summary_final = pd.concat(
#             [df_summary_orig, df_summary_new], ignore_index=True
#         )
#         df_original_final = pd.concat(
#             [df_original_orig, df_original_new], ignore_index=True
#         )
#         # df_summary_final.to_excel(output_report_path, sheet_name="summary", index=False)
#         # df_original_final.to_excel(
#         #     output_report_path, sheet_name="original", index=False
#         # )
#         with pd.ExcelWriter(output_report_path, mode="a", engine="openpyxl",if_sheet_exists="replace") as writer:
#             df_summary_final.to_excel(writer, sheet_name="summary",index=False)
#         with pd.ExcelWriter(output_report_path, mode="a", engine="openpyxl",if_sheet_exists="replace") as writer:
#             df_original_final.to_excel(writer, sheet_name="original",index=False)


def extract_compare_data_from_scout(
    compare_report_id, excel_report_path, output_report_prefix, filter_distnames=[]
):
    url = "https://scout.nsn-rdnet.net/future/api/v1/comparator_reports/{}/".format(
        compare_report_id
    )
    init_pandas()
    df_all = pd.read_excel(excel_report_path, sheet_name="Base Report")
    all_entry_names_list = df_all["EntryName"].values
    # logging.debug("all_entry_names_list is {}".format(all_entry_names_list))
    dpf = DownloadKpiFile()
    authorization = dpf.get_scout_token(
        username=base64.b64decode(b"bTFzaGk=").decode("utf-8"),
        password=base64.b64decode(b"UWF6d3N4ZWRjcmZ2dGdiNg==").decode("utf-8"),
    )
    headers = {
        "User-Agent": dpf.common_user_agent,
        "Authorization": f"JWT {authorization}",
    }
    # for i in range(15):
    #     report_resp = requests.get(url=url, headers=headers)
    #     report_data = json.loads(report_resp.content)
    #     logging.debug("status_code is {}".format(report_resp.status_code))
    #     data = report_data["data"]["attributes"]["report"]
    #     logging.debug("key for data is {}".format(data.keys()))
    #     if len(data.keys()) != 0:
    #         break
    #     # if report_resp.status_code == 200:
    #     #     break
    #     else:
    #         logging.debug("waif for 60s to get the comparator KPI report data.")
    #         time.sleep(60)
    for i in range(12):
        with requests.get(url=url, headers=headers) as report_resp:
            report_data = json.loads(report_resp.content)
            time.sleep(30)
            # logging.debug("data is {}".format(report_data))
            try:
                data = report_data["data"]["attributes"]["report"]
            except Exception as e:
                data = {}
            logging.debug("key for data is {}".format(data.keys()))
            if len(data.keys()) != 0:
                break
            else:
                logging.debug("waif for 90s to get the comparator KPI report data.")
                time.sleep(90)
    # report_data = json.loads(report_resp.content)
    first_build = report_data["data"]["attributes"]["first_period_description"]
    second_build = report_data["data"]["attributes"]["second_period_description"]
    # data = report_data["data"]["attributes"]["report"]
    total_list = []
    for index, (counter_type, context) in enumerate((data.items())):
        logging.debug("counter_type is {}".format(counter_type))
        # logging.debug("counter_type is {}".format(context.items()))
        for index, (counter_name, values) in enumerate(context.items()):
            for index, (object, context) in enumerate(values["data"].items()):
                # logging.debug("context is {}".format(context))
                round_list = []
                build_info = [first_build, second_build]
                round_list.append(build_info)
                # logging.debug("counter_name is {}".format(counter_name))
                round_list.append(counter_name)
                index = [
                    i for i, e in enumerate(all_entry_names_list) if counter_name in e
                ]
                full_name = all_entry_names_list[index][0]
                # logging.debug("full name is {}".format(full_name))
                full_counter_name = full_name.split("]")[-1]
                # logging.debug("counter full name is {}".format(full_counter_name))
                round_list.append(full_counter_name)
                if "/" in object:
                    object = object.split("/")[-1]
                round_list.append(object)
                round_list.append(context["calculations"]["status"])
                try:
                    first_data_value = [x[0] for x in context["first_period"]["data"]]
                except Exception as e:
                    first_data_value = "null"
                try:
                    second_data_value = [x[0] for x in context["second_period"]["data"]]
                except Exception as e:
                    second_data_value = "null"
                Values = [first_data_value, second_data_value]
                round_list.append(Values)
                try:
                    first_period_count = context["first_period"]["count"]
                except Exception as e:
                    first_period_count = "null"
                try:
                    second_period_count = context["second_period"]["count"]
                except Exception as e:
                    second_period_count = "null"
                count = [first_period_count, second_period_count]
                round_list.append(count)
                try:
                    first_period_min = context["first_period"]["min"]
                except Exception as e:
                    first_period_min = "null"
                try:
                    second_period_min = context["second_period"]["min"]
                except Exception as e:
                    second_period_min = "null"
                min = [first_period_min, second_period_min]
                round_list.append(min)
                try:
                    first_period_max = context["first_period"]["max"]
                except Exception as e:
                    first_period_max = "null"
                try:
                    second_period_max = context["second_period"]["max"]
                except Exception as e:
                    second_period_max = "null"
                max = [first_period_max, second_period_max]
                round_list.append(max)
                try:
                    first_period_average = context["first_period"]["average"]
                except Exception as e:
                    first_period_average = "null"
                try:
                    second_period_average = context["second_period"]["average"]
                except Exception as e:
                    second_period_average = "null"
                average = [first_period_average, second_period_average]
                round_list.append(average)
                try:
                    first_period_median = context["first_period"]["median"]
                except Exception as e:
                    first_period_median = "null"
                try:
                    second_period_median = context["second_period"]["median"]
                except Exception as e:
                    second_period_median = "null"
                median = [first_period_median, second_period_median]
                round_list.append(median)
                total_list.append(round_list)
    comparator_report_path_on_ute = "/home/ute/KPI_Report/Comparator_Report"
    report_time = excel_report_path.split(".")[0].split("_")[-1]
    output_report_path = "{}/{}-{}-{}.xlsx".format(
        comparator_report_path_on_ute, output_report_prefix, first_build, report_time
    )
    # logging.debug(total_list)
    df = pd.DataFrame(
        total_list,
        columns=[
            "Comparator_Builds",
            "Code",
            "Name",
            "DistName",
            "Status",
            "Values",
            "Count",
            "Min",
            "Max",
            "Average",
            "Median",
        ],
    )
    df = df.round(2)
    logging.debug("file is {}".format(output_report_path))
    output_report_dir = "/".join(output_report_path.split("/")[0:5])
    logging.debug("dir is {}".format(output_report_dir))
    if os.path.exists(output_report_dir):
        pass
    else:
        logging.debug("add dir")
        os.makedirs(os.path.dirname(output_report_path))
    with pd.ExcelWriter(output_report_path) as writer:
        # logging.debug("df is {}".format(df))
        df.to_excel(
            writer,
            sheet_name="ALL",
            index=False,
            engine="xlsxwriter",
        )
    for filter_disname in filter_distnames:
        logging.debug("filter_disname is {}".format(filter_disname))
        filter_df_with_dist_name = df[df.DistName.str.contains(filter_disname)]
        filter_df_with_dist_name = filter_df_with_dist_name.round(2)
        with pd.ExcelWriter(
            output_report_path,
            mode="a",
            engine="openpyxl",
            if_sheet_exists="replace",
        ) as writer:
            filter_df_with_dist_name.to_excel(
                writer, sheet_name=filter_disname, index=False
            )
    return output_report_path



def upload_files_to_remote_server(local_path, remote_path):
    hostname = "10.70.226.9"
    username = "hz4sg6"
    password = "Hz412Sg6()34"
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh_client.connect(hostname=hostname, username=username, password=password)
    sftp_client = ssh_client.open_sftp()
    sftp_client.put(local_path, remote_path)
    sftp_client.close()
    ssh_client.close()
