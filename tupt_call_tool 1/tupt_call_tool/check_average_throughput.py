import os
import string
from os import path
import datetime
from time import sleep
import logging
import decimal
import collections
import re


__all__ = ["get_tput_info_for_l2lo", "calculate_time_interval"]


def convert_l2lo_tput_format(tput_value, time_interval):
    """
    Description: Convert tput value captured from journal log to mbits/sec unit
    :param tput_value:
    :param time_interval: time_interval for log print. In seconds unit
    :return:
    """
    tput_with_mbit_format = round(float(8 * decimal.Decimal(tput_value) / 1000 / 1000 / time_interval), 3)
    return tput_with_mbit_format


def _get_nrCellIdentity_from_one_line(line_info, direction):
    """
    Description: Get nrCellIdentity from one line
    :param line_info:
    :param direction: ul/dl
    :return:
    """
    nrCellIdentity = None
    if direction == 'dl':
        if line_info.find("DataPdu") != -1:
            nrCellIdentity = int(re.split(pattern=r'\[|\s',
                                          string=line_info.split("nrCellId ")[-1])[0].strip())
    else:
        if line_info.find("nrCellIdentity") != -1:
            nrCellIdentity = int(re.split(pattern=r'#|\s',
                                          string=line_info.split("nrCellIdentity ")[-1].strip())[0].strip())
    return nrCellIdentity


def _get_time_stamp_from_one_line_based_on_nrCellIdentity(line_info, direction, nrCellIdentity):
    """
    Description: Get time stamp value from one line based on nrCellIdentity
    :param line_info:
    :param direction: ul/dl
    :param nrCellIdentity:
    :return: Get timestamp value with datetime format
    """
    timestamp = None
    if direction == 'dl':
        filter_row = "ttisFromUpdate"
        filter_cell = "nrCellId " + str(nrCellIdentity)
    else:
        filter_row = "nrCellIdentity"
        filter_cell = "nrCellIdentity " + str(nrCellIdentity)
    if line_info.find(filter_row) != -1 and line_info.find(filter_cell) != -1:
        pattern = re.compile(r'<(\d+-\d+-\w+:\d+:\d+.\w+)>')
        timestamp_str = pattern.findall(line_info)[-1]
        timestamp = datetime.datetime.strptime(timestamp_str, "%Y-%m-%dT%H:%M:%S.%fZ")
    else:
        logging.debug("Skip this row, as not able to find {} and {} from this row for {}, will remain timestamp as "
                      "None".format(filter_row, filter_cell, direction))
    return timestamp


def get_time_stamp_records_for_one_cell(tput_file, direction, record_count=10):
    """
    Description: Get timestamp value for one cell, will return with 10 records at most
    :param tput_file: file_paths on cluster returned from start_tput_log_capturing
                      Format like bellow: /XXX/XXX/Tput_UL_L2LO_20191126110505.txt
    :param direction: Available values are: None, ul, dl
                      if tput_file format is not the same format as above, then direction value must be ul/dl
    :param record_count: max record num
    :return:
    """
    record_count = int(record_count)
    try:
        with open(tput_file, "r", encoding="UTF-8", errors="ignore") as f:
            lines = f.readlines()
            first_nrCellIdentity = None
            list_time_stamp_for_first_nrCellIdentity = []
            for line in lines:
                # print("line_info:{}".format(line))
                if first_nrCellIdentity is None:
                    # print("nrCellIdentity does not exist, will get the first nrCellIdentity from tput_file")
                    first_nrCellIdentity = _get_nrCellIdentity_from_one_line(line_info=line, direction=direction)
                    time_stamp = _get_time_stamp_from_one_line_based_on_nrCellIdentity(
                        line_info=line, direction=direction, nrCellIdentity=first_nrCellIdentity)
                else:
                    time_stamp = _get_time_stamp_from_one_line_based_on_nrCellIdentity(
                        line_info=line, direction=direction, nrCellIdentity=first_nrCellIdentity)
                # print("first_nrCellIdentity:{}, time_stamp={}".format(first_nrCellIdentity, time_stamp))
                if time_stamp is not None:
                    list_time_stamp_for_first_nrCellIdentity.append(time_stamp)
                if len(list_time_stamp_for_first_nrCellIdentity) == record_count:
                    print("Will check for {} records in max".format(record_count))
                    break
                else:
                    continue
    except IOError as err:
        raise IOError("File Error: {}".format(err))
    else:
        f.close()
    return list_time_stamp_for_first_nrCellIdentity


def calculate_time_interval(tput_file, direction):
    """
    Description: Calculate time interval.
    Will select one cell for calculate the time interval. The max row count for calculation will be 10.
    If records in file is less than 2, then exception will be raised
    :param tput_file:
    :param direction: ul/dl
    :return: time interval for seconds
    """
    time_interval = None
    print("Start to calculate time interval from file {} for {}".format(tput_file, direction))
    list_time_stamp = get_time_stamp_records_for_one_cell(tput_file=tput_file, direction=direction)
    print("list_time_stamp:{}".format(list_time_stamp))
    count = len(list_time_stamp)
    if count >= 2:
        for i in range(1, count):
            temp_time_interval = int(round((list_time_stamp[i]-list_time_stamp[i-1]).total_seconds(), 0))
            time_interval = temp_time_interval if time_interval is None else time_interval
            if temp_time_interval < time_interval:
                time_interval = temp_time_interval
        print("time_interval for {} is: {}".format(direction, time_interval))
        return time_interval
    else:
        raise Exception("Only {} records found from {} for {}, not able to calculate time interval value".format(
            count, tput_file, direction
        ))


def _collect_l2lo_tput_data_from_file(tput_file, direction):
    """
    Description: Collect tput data from the file collected from journal/aasys log
    time_interval must be calculated for ul and dl. For ul it's static to 1s now,
    for dl it's the time gap got from log. If time_interval also need to be calculated form log, then it can call
    function calculate_time_interval the same way as dl. this function also supported for UL
    :param tput_file:
    :param direction: valid value can be: ul, dl
    :return: a dict with format: {nrCellIdentity1:[tput1, tput2], nrCellIdentity2:[tput1, tput2]}
            Example output: {16385: [0.0, 0.0], 16386: [0.0, 0.0]}
    """
    dict_tput_for_cells = collections.defaultdict(list)
    if direction == 'ul':
        time_interval = 1
        print("Time interval for ul is now static to {}, if also need to get it from log, "
              "then it must be changed".format(time_interval))
    else:
        time_interval = calculate_time_interval(tput_file=tput_file, direction=direction)
    try:
        with open(tput_file, "r", encoding="UTF-8", errors="ignore") as f:
            lines = f.readlines()

            for line in lines:
                line = line[4:]
                if line != lines[-1]:
                    if direction == 'ul':
                        if line.find("nrCellIdentity ") != -1:
                            nrCellIdentity = int(
                                re.split(pattern=r'#|\s', string=line.split("nrCellIdentity ")[-1].strip())[0].strip())
                            tput_value_str = line.split("(")[-1].split(" ")[0].strip()
                            tput_value = convert_l2lo_tput_format(tput_value=tput_value_str,
                                                                  time_interval=time_interval)
                            dict_tput_for_cells[nrCellIdentity].append(tput_value)
                    elif direction == 'dl':
                        if line.find("DataPdu") != -1:
                            nrCellIdentity = int(re.split(pattern=r'\[|\s',
                                                          string=line.split("nrCellId ")[-1])[0].strip())
                            tput_value_str = line.split("DataPdu:")[-1].split('|')[3].split(']')[0].strip()
                            tput_value = convert_l2lo_tput_format(tput_value=tput_value_str,
                                                                  time_interval=time_interval)
                            dict_tput_for_cells[nrCellIdentity].append(tput_value)
                    else:
                        raise Exception("Unsupported input of direction {}, supported values are: ul, dl".format(
                            direction))
                else:
                    logging.info("Skip last line in file in case the captured log is incomplete.")
    except IOError as err:
        raise IOError("File Error: {}".format(err))
    else:
        f.close()
    return dict_tput_for_cells


def get_tput_info_for_l2lo(tput_file, direction=None):
    """
    Description: Added average tput calculation to tput info for each cell
    The log decoder is based on 19A, 19B
    :param tput_file: tput log file path for ul/dl
    :param direction: Available values are: None, ul, dl
                      if tput_file format is not the same format as above, then direction value must be ul/dl
    :return: A dict with bellow format:
        {nrCellIdentity:{'average_tput':value, 'detail_tput_info':[value1, value2,...]}}
    Example output:
        {16385: {'average_tput': 0.0, 'detail_tput_info': [0.0, 0.0, 0.0, 0.0, 0.0]},
         16386: {'average_tput': 0.0, 'detail_tput_info': [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]}
    """
    print("direction: {}".format(direction))
    dict_tput_for_cells = _collect_l2lo_tput_data_from_file(tput_file=tput_file, direction=direction)
    dict_tput_with_average_tput_info = {}
    if dict_tput_for_cells:
        for nrCellIdentity in dict_tput_for_cells.keys():
            dict_tput_info_per_cell = {}
            # dict_tput_info_per_cell = {"detail_tput_info": dict_tput_for_cells[nrCellIdentity]}
            if len(dict_tput_for_cells[nrCellIdentity]) == 0:
                average_tput_per_cell = "No data"
            else:
                average_tput_per_cell = round(sum(dict_tput_for_cells[nrCellIdentity]) /
                                              len(dict_tput_for_cells[nrCellIdentity]), 3)
                max_value = max(dict_tput_for_cells[nrCellIdentity])
                min_value = min(dict_tput_for_cells[nrCellIdentity])
            if average_tput_per_cell != 0:
                dict_tput_info_per_cell["average_tput"] = average_tput_per_cell
                dict_tput_info_per_cell["max_tput"] = max_value
                dict_tput_info_per_cell["min_tput"] = min_value
                dict_tput_with_average_tput_info[nrCellIdentity] = dict_tput_info_per_cell
        return dict_tput_with_average_tput_info
    else:
        raise Exception("No throughput data info found from file {}".format(tput_file))
