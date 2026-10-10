# -*- coding: utf-8 -*-
"""
Author: Zhang Haijun
Contacts: haijun.zhang@nokia-sbell.com
Squard: HGZ SG1
Description: SigSpark and Pioneer keywords with Nokia TA interface auto API.

"""
import sys
import os
import socket
import time
import json
import logging
import taf.transport.ssh as ssh
import re
from robot.libraries.BuiltIn import BuiltIn
import xml.etree.ElementTree as ET
from datetime import datetime, timedelta
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.dingli import PioneerClient


class sparkxml:
    """
    spark L3 message log parse function
    """

    def __init__(self):
        pass

    def open(self, logname):
        """
        open log and format to dict
        """
        root = ET.parse(logname)
        msgs = root.findall("OneMessage")
        self.message = {}
        for message in msgs:
            msgname = message.get("Name").strip()
            if msgname in self.message:
                self.message[msgname].append(message)
            else:
                self.message[msgname] = [message]

    def find(self, msg, path=None, type="last"):
        """
        get expect val form spark L3 message log
        """
        if msg in self.message:
            if type == "last":
                trees = [self.message[msg][-1]]
            elif type == "all":
                trees = self.message[msg]
            else:
                trees = [self.message[msg][0]]
            if path is not None:
                value = []
                for msgtree in trees:
                    res = self._find_val_by_path(msgtree, path)
                    if res is not None:
                        value = value + res
                if len(value) == 0:
                    return None
                elif len(value) == 1:
                    return value[0]
                else:
                    return value
            else:
                return msg
        else:
            return None

    def check(self, msg, expression):
        """
        check expression form spark L3 message log
        """
        if msg not in self.message:
            raise Exception('Can not find message : "{}"'.format(msg))
        trees = self.message[msg]
        eps = expression.split("&&")
        for ep in eps:
            kv = ep.split("=")
            if len(kv) != 2:
                raise Exception("Error expression format!")
            path = kv[0].strip()
            value = kv[1].strip()
            for msgtree in trees:
                res = self._find_val_by_path(msgtree, path)
                if res is not None and value in res:
                    break
            else:
                raise Exception('Check failed : "{}"'.format(ep))

    def _find_val_by_path(self, msgtree, path):
        """
        get expect val form spark xml tree
        """
        path = path.split(".")
        trees = [msgtree]
        for name in path:
            tmp = []
            for tree in trees:
                res = tree.findall(".//{}".format(name))
                if len(res) > 0:
                    tmp = tmp + res
            if len(tmp) == 0:
                return None
            else:
                trees = tmp
        res = []
        for msgtree in trees:
            value = self._format_val(msgtree)
            res.append(value)
        return res

    def _format_val(self, msgtree):
        """
        format value from xml format
        """
        if len(list(msgtree)) > 0:
            if len(list(msgtree)) > 1:
                msginfo = ET.tostring(msgtree)
            else:
                msginfo = ET.tostring(list(msgtree)[0])
            rule = re.compile(r"<\/[^>]*>")
            # For python3 adaption
            msginfo = msginfo.decode("utf-8")
            msginfo = rule.sub("", msginfo)
            msginfo = (
                msginfo.replace("/>", "").replace("<", "").replace(">", ":").strip()
            )
            return msginfo
        else:
            return msgtree.text


class sparkcsv:
    """
    spark IE data parse function
    """

    def __init__(self):
        pass

    def open(self, logname):
        """
        open log and format to dict
        """
        f = open(logname)
        lines = f.readlines()
        f.close()
        data = {}
        title = lines[0].strip().split(",")
        del lines[0]
        for line in lines:
            line = re.sub(
                '(".*)(,)(.*")', lambda x: x.group(1) + " and" + x.group(3), line
            )
            for i in range(0, len(title)):
                linedata = line.strip().split(",")
                if title[i] not in data:
                    data[title[i]] = []
                if title[i] == "Time":
                    linedata[i] = datetime.strptime(
                        linedata[i][0:-4], "%Y-%m-%d %H:%M:%S"
                    )
                    linedata[i] = int(time.mktime(linedata[i].timetuple()))
                data[title[i]].append(linedata[i])
        self.data = data

    def find(self, ie, starttime=None, endtime=None):
        """
        get IE value list during starttime to endtime
        """
        if starttime is None:
            starttime = self.data["Time"][0]
        else:
            starttime = int(starttime)
        if endtime is None:
            endtime = self.data["Time"][-1]
        else:
            endtime = int(endtime)
        for i in range(0, len(self.data["Time"])):
            if self.data["Time"][i] >= starttime:
                startindex = i
                break
        for i in range(0, len(self.data["Time"])):
            if self.data["Time"][len(self.data["Time"]) - i - 1] <= endtime:
                endindex = len(self.data["Time"]) - i
                break
        return self.data[ie][startindex:endindex]


class ADBClient:

    def setup_adb_connect(self, alias):
        """
        Setup ssh connection for adb command
        :param alias: connection alias
        :return: None
        """
        sshconn = ssh.ssh()
        sshconn.connect_to(
            self.ue_config["host"],
            self.ue_config["username"],
            self.ue_config["password"],
            alias=alias,
            timeout=120,
        )

    def send_adb_command(self, command, alias, timeout=30, interval=2):
        """
        Send adb command via ssh connection with UE control PC
        :param command: ADB command
        :param alias: connection alias
        :param timeout: waittime unitl action successful
        :param interval: retry action interval
        :return: None
        """
        pass

    def operate_ue_dataservice(self, action="enable"):
        """
        Open/close UE data
        :param action: enable/disable
        :return: None
        """
        self.setup_adb_connect(alias="sigspark")
        cmd = "svc data {}".format(action)
        self.send_adb_command(command=cmd, alias="sigspark")

    def restart_uemanager(self):
        """
        Restart Uemanager
        :return: None
        """
        pass

    def _adb_select_setting_menu_cmds(self, menu_num):
        """
        Format adb command to switch to menu
        :param menu_num: <list> index of eachh menu list page
        :return: adb commands
        """
        cmds = []
        for num in menu_num:
            cmds.append("input roll 0 -100")
            cmds.append("input roll 0 {}".format(num))
            cmds.append("input keyevent 66")
        return cmds

    def _adb_delkey_cmds(self, length):
        """
        Format adb input delete keyevent
        :param length: <int> length of text
        :return: adb commands
        """
        cmd = "input keyevent"
        for num in range(length):
            cmd = cmd + " 67"
        return [cmd]

    def _apn_adb_command(self, apn, model="EVR-AN00"):
        """
        Format set apn adb commands. Only supports HuaWei Mate 20X(EVR-AN00)
        :param apn: apn that set on UE
        :param model: Model of UE.
        :return: support UEs retrun commands, else return None
        """
        commands = {
            "EVR-AN00": [
                [
                    "input keyevent 224",
                    "input keyevent 3",
                    "input swipe 300 1000 300 500",
                ],
                ["am start com.android.phone/.MSimMobileNetworkSettings"],
                self._adb_select_setting_menu_cmds([3, 1, 1]),
                self._adb_delkey_cmds(60),
                ["input text {}".format(apn)],
                ["input keyevent 61 61", "input keyevent 66"],
                ["input tap 1000 100"],
                [
                    "input roll 0 -100",
                    "input keyevent 61 61",
                    "input roll 0 1",
                    "input keyevent 66",
                ],
                ["input keyevent 3"],
            ]
        }
        if model in commands:
            return commands[model]
        else:
            return None

    def _depleyment_adb_command(self, depleyment=1, model="EVR-AN00"):
        """
        Format set depleyment adb commands. Only supports HuaWei Mate 20X(EVR-AN00)
        :param depleyment: 0:NSA 1:SA 2:NSA+SA
        :param model: Model of UE.
        :return: support UEs retrun commands, else return None
        """
        commands = {
            "EVR-AN00": [
                [
                    "input keyevent 224",
                    "input keyevent 3",
                    "input swipe 300 1000 300 500",
                ],
                ["am start com.android.settings"],
                self._adb_select_setting_menu_cmds([100, 10, 23]),
                [
                    "input roll 0 -100",
                    "input roll 0 {}".format(depleyment),
                    "input keyevent 66",
                ],
            ]
        }
        if model in commands:
            return commands[model]
        else:
            return None

    def set_apn(self, apn):
        """
        Set APN on UE via adb command
        :param apn: APN address
        :return: None
        """
        self.setup_adb_connect(alias="sigspark")
        cmd = "getprop ro.product.model"
        model = self.send_adb_command(command=cmd, alias="sigspark")
        model = model.split("\n")
        model = model[0].strip()
        steps = self._apn_adb_command(apn, model)
        if steps is None:
            logging.info("Can not set APN for '{}'".format(model))
        else:
            for step in steps:
                for cmd in step:
                    self.send_adb_command(command=cmd, alias="sigspark")

    def set_depleyment(self, depleyment=1):
        """
        Set APN on UE via adb command, UE will auto reboot
        :param depleyment: 0:NSA 1:SA 2:NSA+SA
        :return: None
        """
        self.setup_adb_connect(alias="sigspark")
        cmd = "getprop ro.product.model"
        model = self.send_adb_command(command=cmd, alias="sigspark")
        model = model.split("\n")
        model = model[0].strip()
        steps = self._depleyment_adb_command(depleyment, model)
        if steps is None:
            logging.info("Can not set APN for '{}'".format(model))
        else:
            for step in steps:
                for cmd in step:
                    self.send_adb_command(command=cmd, alias="sigspark")
        logging.info("waitting 60s for UE reboot")
        time.sleep(60)
        self.restart_uemanager()
        self.detach()


class InitClient:

    def init_config(self, index=0, get_spark_license=True, **kwargs):
        """
        Init ue config from ROBOTFRAMEWORK BuiltIn
        :param index: ue index of ${tl.ues} , count from 0
        :param **kwargs: ue config from input
               :config port: socket port default 30999
               :config host: controlpc host ip
               :config username: controlpc ssh username
               :config password: controlpc ssh password
               :config apppath: software install path on controlpc
               :config imsi: ue imsi
               :config appserver: DL/UL appserver
        :return: None
        """
        try:
            varstr = "${tl.ues[" + str(index) + "]}"
            ueobj = BuiltIn().get_variable_value(varstr)
            self.ue_config = {
                "port": 30999,
                "host": ueobj.ssh_connection_details.addr,
                "username": ueobj.ssh_connection_details.username,
                "password": ueobj.ssh_connection_details.password,
                "apppath": ueobj.server_dir,
                "imsi": ueobj.imsi,
                "sn": ueobj.serial_number,
                "appserver": ueobj.iperf_details,
            }
            if get_spark_license:
                self.ue_config["licenseusername"] = ueobj.licensekeeper.username
                self.ue_config["licensepassword"] = ueobj.licensekeeper.password
        except BaseException as error:
            logging.info(
                "init config from robot testline failed : {}".format(str(error))
            )
            self.ue_config = kwargs
        logging.info(self.ue_config)
        return (self.ue_config["host"], self.ue_config["apppath"])

    def startapp(self, dur=10, timeout=300, reset=False):
        """
        Start App by schtasks cmd
        :param dur: check app setup interval time (s)
        :param timeout: check app setup timeout (s)
        :reset: force reset app tag
        :return None
        """
        pass

    def setup(
        self,
        conn=None,
        get_spark_license=True,
        ue_num_input=None,
        required_spark_license_time=2,
        force_check_ue=False,
        eq_index=None,
    ):
        """
        Setup connection with sigspark TA client and connect ues
        """
        self.store = {}
        num = 5
        for i in range(num):
            try:
                if conn is None:
                    self.conn = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                    self.conn.settimeout(60)
                    self.conn.connect((self.ue_config["host"], self.ue_config["port"]))
                else:
                    self.conn = conn
                if get_spark_license:
                    self._get_spark_license(
                        required_spark_license_time=required_spark_license_time
                    )
                self._connect_ues(
                    ue_num_input=ue_num_input,
                    force_check_ue=force_check_ue,
                    eq_index=eq_index,
                )
                break
            except socket.error as msg:
                print("=====Connect to server failed with Error: {}=====".format(msg))
                time.sleep(5)
        if i >= (num - 1):
            raise Exception("=====Socket failed after retry 5 times=====")
        return self.conn

    def teardown(self):
        """
        Close connection with sigspark TA client and disconnect ues
        """
        self._disconnect_ues()
        r = self.conn.close()

    def _send_msg(self, cmd, param=None, index=None):
        """
        Send message to sigspark client with EQIndex
        :param cmd: command define by sigspark api
        :param param: param define by sigspark api
        :param index: EQIndex define by sigspark api , count from 1
        :return None
        """
        msg = {"CMD": cmd}
        msg["EQIndex"] = self.ueindex
        if index:
            msg["EQIndex"] = index
        if param:
            msg["Param"] = param
        msg = json.dumps(msg)
        msg = msg.encode("utf-8")
        logging.info('Send "{}" to control pc'.format(msg))
        self.conn.send(msg)

    def _send_common_msg(self, cmd, param=None):
        """
        Send message to sigspark client without EQIndex
        :param cmd: command define by sigspark api
        :param param: param define by sigspark api
        Example: {"CMD": "GetParamMAC", "EQIndex": 1}
        :return None
        """
        msg = {"CMD": cmd}
        if param:
            msg["Param"] = param
        msg = json.dumps(msg)
        msg = msg.encode("utf-8")
        logging.info('Send "{}" to control pc'.format(msg))
        self.conn.send(msg)

    def _send_msg_with_clear_tasks(self, cmd, param=None, index=None):
        """
        Send message to sigspark client with EQIndex
        :param cmd: command define by sigspark api
        :param param: param define by sigspark api
        :param index: EQIndex define by sigspark api , count from 1
        :return None
        """
        msg = {"CMD": cmd}
        msg["EQIndex"] = self.ueindex
        msg["ClearOldTasks"] = "true"
        if index:
            msg["EQIndex"] = index
        if param:
            msg["Param"] = param
        msg = json.dumps(msg)
        msg = msg.encode("utf-8")
        logging.info('Send "{}" to control pc'.format(msg))
        self.conn.send(msg)

    def _receive_msg(self, timeout=None, buflen=1024):
        """
        Get message from sigspark client
        :return <dict>
        Example: {"CMD":"Attach","EQIndex":1,"Param":{"State":0}}
        """
        self.conn.settimeout(timeout)
        recv = self.conn.recv(buflen)
        time.sleep(1)
        logging.info('Receive "{}"'.format(recv))
        recv = json.loads(recv)
        return recv

    def _get_msg(self, cmd, index=None, retry=5, timeout=60):
        """
        Filter message from sigspark client with retry
        :param cmd: command define by sigspark api
        :param retry: get needed message retry times
        :return <dict>
        Example: {"State":0,"MACDL":11325064,"MACUL":5622736}
        """
        while retry > 0:
            try:
                recv = self._receive_msg(timeout)
                if recv["CMD"] == cmd:
                    if "EQIndex" in recv:
                        if index is None:
                            index = self.ueindex
                        if recv["EQIndex"] == index:
                            break
                    else:
                        break
            except socket.timeout:
                print("receive response timeout, try again")
            retry = retry - 1
            if retry == 0:
                raise Exception("Can't get response with '{}' !".format(cmd))
        if recv["Param"]["State"] == -1:
            raise Exception("Execute {} failed!".format(recv["CMD"]))
        else:
            return recv["Param"]

    def _get_events_msg(self, cmd, retry=2, buflen=102400, timeout=180):
        """
        Filter message from sigspark client with retry
        :param cmd: command define by sigspark api
        :param retry: get needed message retry times
        :return <dict>
        Example: {"State":0,"MACDL":11325064,"MACUL":5622736}
        """
        while retry > 0:
            try:
                recv = self._receive_msg(timeout, buflen)
                if recv["Param"]["LastEventIndex"] == recv["Param"]["EventCount"]:
                    break
            except socket.timeout:
                print("receive response timeout, try again")
            retry = retry - 1
            print("retry value is: ", retry)
            if retry == 0:
                raise Exception("Can get response with '{}' !".format(recv["CMD"]))
        if recv["Param"]["State"] == -1:
            raise Exception("Execute {} failed!".format(recv["CMD"]))
        else:
            return recv

    def _get_events_data(self, cmd, retry=2, buflen=102400, timeout=180):
        """
        large number of event segmentation support test ok
        Filter message from sigspark client with retry
        :param cmd: command define by sigspark api
        :param retry: get needed message retry times
        :return <dict>
        Example: {"State":0,"MACDL":11325064,"MACUL":5622736}
        """
        recv1 = b""
        while retry > 0:
            try:
                logging.info("\nretry value is::")
                logging.info(retry)
                retry = retry - 1
                self.conn.settimeout(timeout)
                recv0 = self.conn.recv(buflen)
                time.sleep(1)
                logging.info("\nget recv size:")
                logging.info(sys.getsizeof(recv0))
                logging.info('Receive events msg: "{}"'.format(recv0))
                recv1 = recv1 + recv0
                logging.info("\njson loads, retry value:")
                logging.info(retry)
                recv = json.loads(recv1)
                if recv["Param"]["LastEventIndex"] == recv["Param"]["EventCount"]:
                    return recv
            except Exception as err:
                logging.info("\nException err:")
                logging.info(err)
                continue
        #            if retry == 0:
        #                raise Exception("Can get response with '{}' !".format(recv['CMD']))
        if recv["Param"]["State"] == -1:
            raise Exception("Execute {} failed!".format(recv["CMD"]))
        else:
            return recv


class BaseClient(InitClient, ADBClient):

    def _auto_check(self, cmd="AutoCheck"):
        """
        Auto check sigspark UEs connect on controlpc
        :param cmd: AutoCheck define by sigspark api
        :return <int> number of UEs
        """
        self._send_common_msg(cmd)
        res = self._get_msg(cmd)
        return res["Count"]

    def _connect_ues(
        self, cmd="ConnectEQ", ue_num_input=None, force_check_ue=False, eq_index=None
    ):
        """
        Connect all UEs on controlpc
        :param cmd: ConnectEQ define by sigspark api
        cc
        :return None
        """
        if eq_index is not None:
            logging.info("eq_index indicated, will check if imsi is match directly")
            eq_index = int(eq_index)
            self._send_common_msg(cmd)
            self._get_msg(cmd=cmd, timeout=600)
            self.ueindex = eq_index
            time.sleep(10)
            self.send_at_command(command="AT+CFUN=1", index=eq_index)
            imsi = self.get_imsi_by_AT(index=eq_index)
            if imsi == self.ue_config["imsi"]:
                logging.info("UE found and real EQI is: {}".format(self.ueindex))
            elif force_check_ue and imsi != self.ue_config["imsi"]:
                self.teardown()
                raise Exception(
                    "Verify imsi failed for {}. No UE find on PC!".format(
                        self.ue_config["imsi"]
                    )
                )
            else:
                logging.warn(
                    "No UE find on PC as imsi verify failed, since force_check_ue is skipped, "
                    "will continue on testing with specified EQI: {}".format(eq_index)
                )
        else:
            if ue_num_input:
                ue_num = int(ue_num_input)
            else:
                ue_num = self._auto_check()
                ue_num = int(ue_num)
            if ue_num > 0:
                self._send_common_msg(cmd)
                self._get_msg(cmd=cmd, timeout=600)
                self.ueindex = 0
                time.sleep(10)
                for i in range(1, ue_num + 1):
                    self.send_at_command(command="AT+CFUN=1", index=i)
                    imsi = self.get_imsi_by_AT(index=i)
                    logging.info(imsi)
                    if imsi == self.ue_config["imsi"]:
                        self.ueindex = i
                        break
                if self.ueindex == 0 and force_check_ue is True:
                    self.teardown()
                    raise Exception(
                        "Verify imsi failed for {}. No UE find on PC!".format(
                            self.ue_config["imsi"]
                        )
                    )
                elif self.ueindex == 0 and force_check_ue is False:
                    self.ueindex = 1
                    logging.warn(
                        "No UE find on PC, since force_check_ue is skipped, will use ue 1 to continue the test"
                    )
                else:
                    logging.info("UE found and real EQI is: {}".format(self.ueindex))
            else:
                self.teardown()
                raise Exception("No UE find on PC!")

    def _disconnect_ues(self, cmd="DisConnectEQ"):
        """
        Disconnect all UEs on controlpc
        :param cmd: DisConnectEQ define by sigspark api
        :return None
        """
        self._send_common_msg(cmd)
        self._get_msg(cmd)

    def start_log(self, logname="TA_LOG", logpath=None, cmd="StartLog"):
        """
        Start sigspark log on controlpc
        :param logpath: Log path on controlpc
        :param logname: Log name for saving
        :param cmd: StartLog define by sigspark api
        :return None
        """
        if logpath is None:
            logpath = "C:/tmp/uelog/AUTO/{}".format(int(time.time()))
        param = {"LogName": logname, "LogPath": logpath}
        self._send_common_msg(cmd, param=param)
        self._get_msg(cmd)
        return [logpath, logname]

    def stop_log(self, cmd="StopLog"):
        """
        Stop sigspark log on controlpc
        :param cmd: StopLog define by sigspark api
        :return None
        """
        self._send_common_msg(cmd)
        self._get_msg(cmd)

    def start_ul_traffic(
        self,
        protocol="UDP",
        testtime="120",
        bandwidth=1000,
        buffersize=1024,
        packetsize=1400,
        multidrb_QoS_dest=None,
        iperf_port=None,
        connectiontype="app",
        apnaddress="wap1nokiacom",
        ue_mode="SA",
        cmd="StartULtraffic",
    ):
        """
        Start UL traffic on UE
        :param cmd: Attach define by sigspark api
        :param protocol: "UDP", //  means default protocol UDP
        :param testtime: "120",    //Test time.
        :param bandwidth: 1000,    //Kbps.
        :param buffersize: 1024,     //KB
        :param packetsize: 1400     //Byte
        :param multidrb_QoS_dest: <option> multidrb QoS rule server ipaddr
        :param iperf_port: port value of traffic, it can be get from __int__.py file or TCs eg: 50001
        :return None
        """
        self.ue_config["ue_mode"] = ue_mode
        if ue_mode == "SA":
            ueip = self.get_pdu_ip(apnaddress=apnaddress)
        elif ue_mode == "MultiUE_SA":
            ueip = self.get_MultiUE_pdu_ip_by_AT(id=1)
        elif ue_mode == "LTE":
            ueip = self.get_eps_info(apnaddress=apnaddress)
        else:
            ueip = self.get_pdu_ip_by_AT(id=1)

        logging.info(ueip)
        if multidrb_QoS_dest is None:
            dest = self.ue_config["appserver"].network_interface_address
        else:
            dest = multidrb_QoS_dest
        param = {
            "Protocol": protocol,
            "Address": dest,
            "Port": iperf_port,
            "TestTime": testtime,
            "Bandwidth": bandwidth,
            "BufferSize": buffersize,
            "PacketSize": packetsize,
        }
        self._send_msg(cmd, param=param)
        self._get_msg(cmd)

    def stop_ul_traffic(self, cmd="StopULtraffic"):
        """
        Stop UL traffic on UE
        :return None
        """
        self._send_msg(cmd)
        self._get_msg(cmd)

    def create_test_plan(
        self, taskname="Test", times=1, interval=10, content={}, cmd="CreateTestPlan"
    ):
        """
        Create test plan
        :param taskname: task name
        :param times: test times
        :param interval: sleep time before replay
        :param content: <dict>, test content define by vendor
        :return None
        """
        param = {
            "TestPlans": [
                {
                    "TaskName": taskname,
                    "TestTimes": int(times),
                    "TestInterval": int(interval),
                    "TestContent": content,
                }
            ]
        }
        self._send_msg(cmd, param=param)
        self._get_msg(cmd)

    def start_test(self, cmd="StartTest"):
        """
        Excute testplan
        :param cmd: StartTest define by sigspark api
        :return None
        """
        self._send_msg(cmd)
        self._get_msg(cmd)

    def stop_test(self, cmd="StopTest"):
        """
        Stop testplan
        :param cmd: StopTest define by sigspark api
        :return None
        """
        self._send_msg(cmd)
        self._get_msg(cmd)

    def attach(self, ue_mode, cmd="Attach"):
        """
        Attach UE (attach and setup pdu)
        :param ue_mode: attach mode,"4G" or "5G_SA" or "5G_NSA"
        :param cmd: Attach define by sigspark api
        :return <int> attach state
        """
        param = {"UEMode": ue_mode, "Timeout": 60000}
        self._send_msg(cmd, param=param)
        attach_resp = self._get_msg(cmd)
        return attach_resp["State"]

    def detach(self, cmd="Detach"):
        """
        Dttach UE
        :param cmd: Detach define by sigspark api
        :return None
        """
        self._send_msg(cmd)
        self._get_msg(cmd)

    def power_on(self, cmd="PowerOn"):
        """
        Open RF on UE (not reboot)
        :param cmd: PowerOn define by sigspark api
        :return None
        """
        self._send_msg(cmd)
        self._get_msg(cmd)

    def power_off(self, cmd="PowerOff"):
        """
        Shutdown RF on UE (not reboot)
        :param cmd: PowerOff define by sigspark api
        :return None
        """
        self._send_msg(cmd)
        self._get_msg(cmd)

    def lock_band(self, band, cmd="LockBand"):
        """
        Lock band on UE
        :param band: <str> "1,3,5" means lock Band1, Band3 and Band5, and so forth
        :return None
        """
        param = {"BandStr": band}
        self._send_msg(cmd, param=param)
        self._get_msg(cmd)

    def unlock_band(self, cmd="UnlockBand"):
        """
        UnlockBand the bands specified by “LockBand” cmd
        :return None
        """
        self._send_msg(cmd)
        self._get_msg(cmd)

    def config_5g_deployment(self, nettype, cmd="Config5GDeployment"):
        """
        Configure the UE 5G deployment
        :param nettype: <int> 0:"AUTO", 8:"NSA", 20:"SA+NSA"
        :return None
        """
        param = {"NetType": int(nettype)}
        self._send_msg(cmd, param=param)
        self._get_msg(cmd)

    def get_mac_tp(self, cmd="GetParamMAC"):
        """
        Get throughput on UE
        :param cmd: GetParamMAC define by sigspark api
        :return <tuple> (ul , dl)  (byte)
        """
        self._send_msg(cmd)
        res = self._get_msg(cmd)
        ul = float(res["MACUL"])
        dl = float(res["MACDL"])
        return (ul, dl)

    def get_imsi(self, cmd="GetParamIMSI"):
        """
        Get IMSI and IP on UE
        :return <str> imsi
        """
        self._send_msg(cmd)
        res = self._get_msg(cmd)
        imsi = res["IMSI"]
        return imsi

    def get_pdu_ip(self, apnaddress, cmd="GetPDUInfo", timeout=30):
        """
        Get IMSI and IP on UE
        :param pduid: GetParamIMSI define by sigspark api
        :return <str> imsi
        """
        endtime = time.time() + timeout
        while endtime > time.time():
            param = {"APN": apnaddress}
            self._send_msg(cmd, param=param)
            try:
                res = self._get_msg(cmd)
                if res["IP"] != "":
                    print(res["IP"])
                    PDU_IP = res["IP"].split(":")[-1]
                    return PDU_IP
            #                    return res['IP']
            except BaseException:
                pass
            time.sleep(2)
        else:
            raise Exception("Get ueip timeout!")

    def export_message_detail(
        self, logpath, localpath, localname, cmd="ExportMessageDetail"
    ):
        """
        export L3 message detail and download to UTE
        :param logpath: log full path for saving on UTE
        :return None
        """
        localfile = "{}/{}.xml".format(localpath, localname)
        localsaf = "{}/{}-{}.saf".format(localpath, localname, self.ueindex)
        param = {"ExportFileName": localfile, "Logfile": localsaf}
        self._send_common_msg(cmd, param=param)
        res = self._get_msg(cmd)
        sshconn = ssh.ssh()
        sshconn.connect_to(
            self.ue_config["host"],
            self.ue_config["username"],
            self.ue_config["password"],
            alias="sigspark",
            timeout=120,
        )
        sshconn.download_file(localfile, logpath, connection="sigspark")
        sshconn.disconnect(connection="sigspark")

    def export_log_file(
        self, logpath, localpath, localname, template="auto_test", cmd="ExportLogfile"
    ):
        """
        export filter log file to csv and download to UTE
        :param logpath: log full path for saving on UTE
        :param template: filter template name on spark
        :return None
        """
        localfile = "{}/{}.csv".format(localpath, localname)
        localsaf = "{}/{}-{}.saf".format(localpath, localname, self.ueindex)
        param = {
            "TemplateName": template,
            "ExportFileName": localfile,
            "Logfile": localsaf,
        }
        self._send_common_msg(cmd, param=param)
        res = self._get_msg(cmd)
        sshconn = ssh.ssh()
        sshconn.connect_to(
            self.ue_config["host"],
            self.ue_config["username"],
            self.ue_config["password"],
            alias="sigspark",
            timeout=120,
        )
        sshconn.download_file(localfile, logpath, connection="sigspark")

    def setup_pdu(
        self, id=1, type="IP", apn="wap1.nokia.com", ssc=0, slice=None, cmd="SetupPDU"
    ):
        """
        Setup PDU session
             Use 'AT command' like 'AT+CGDCONT=2,"IP","wap2.nokia.com"'
             and 'AT+CGACT=1,2'
        :param id: <int,str> PDU cofing,context id
        :param type: <str> PDU cofing, IP/IPV4V6
        :param apn: <str> PDU cofing,APN
        :param ssc: <str> SSC_mode,0 or 1
        :param slice: <str> S_NSSAI like "1.123456;2F.654321"
        :return response of udp command
        """
        if slice is None:
            param = {"Type": type, "APN": apn, "ID": id}
        else:
            param = {
                "Type": type,
                "APN": apn,
                "ID": id,
                "SSC_mode": ssc,
                "S_NSSAI": slice,
            }
        self._send_msg(cmd, param=param)
        res = self._get_msg(cmd)
        return res

    def release_pdu(self, cmd="ReleasePDU", id=id):
        """
        Release PDU session
             Use 'AT command' like 'AT+CGACT=0,2'
        :id: <int,str> PDU cofing,context id
        :return None
        """
        param = {"ID": id}
        self._send_msg(cmd, param=param)
        res = self._get_msg(cmd)
        return res

    def configure_apn(self, apn, mcc="460", mnc="02", cmd="ConfigureAPN"):
        """
        Update or insert APN on UE
        :param apnname: <str> apnname dispaly on UE,if apn name existed,update this apn,else insert apn
        :param apn: <str> apn address
        :param mcc: <str> mcc mode, '460' default
        :param mnc: <str> mnc mode, '02' default
        :return None
        """
        param = {"APN": apn}
        self._send_msg(cmd, param=param)
        res = self._get_msg(cmd)

    def get_imsi(self, command="AT", timeout=5000, cmd="SendAT", index=None):
        """
        Send ATCOMMAND via sigspark
        :param command: ATCOMMAND define on 3gpp
        :param timeout: Get return timeout
        :param cmd: SendAT define by sigspark api
        :return <str> response of ATCOMMAND
        """
        param = {"Command": command, "Timeout": timeout, "SuccStr": "\r\n\r\nOK"}
        if index is None:
            self._send_msg(cmd, param=param)
        else:
            self._send_msg(cmd, index=index, param=param)
        if index is None:
            res = self._get_msg(cmd=cmd, timeout=5)
        else:
            res = self._get_msg(cmd=cmd, index=index, timeout=5)
        return res["Back"].strip()

    def send_at_command(
        self, command="AT", timeout=5000, cmd="SendAT", index=None, SuccStr=None
    ):
        """
        Send ATCOMMAND via sigspark
        :param command: ATCOMMAND define on 3gpp
        :param timeout: Get return timeout
        :param cmd: SendAT define by sigspark api
        :return <str> response of ATCOMMAND
        """
        if command == "AT+CGPADDR":
            param = {"Command": command, "Timeout": timeout, "SuccStr": SuccStr}
        else:
            param = {"Command": command, "Timeout": timeout}
        if index is None:
            self._send_msg(cmd, param=param)
        else:
            self._send_msg(cmd, index=index, param=param)
        if index is None:
            res = self._get_msg(cmd=cmd, timeout=5)
        else:
            res = self._get_msg(cmd=cmd, index=index, timeout=5)
        return res["Back"].strip()

    def get_pdu_ip_by_AT(self, id=1, timeout=30):
        """
        Get ueip via ATCOMMAND
        :param id: ATCOMMAND pdu id
        :return <str> ueip
        """
        endtime = time.time() + timeout
        ueip = ""
        while endtime > time.time():
            try:
                res = self.send_at_command(command="AT+CGPADDR", SuccStr="+CGPADDR")
                res = re.findall(r"\+CGPADDR: " + str(id) + r',"?((\d+\.?){4})"?', res)
                if len(res) > 0:
                    return res[0][0]
            except BaseException as error:
                logging.info("get ueip failed with error :{}".format(str(error)))
            time.sleep(2)
        else:
            raise Exception("Get ueip timeout!")

    def get_MultiUE_pdu_ip_by_AT(self, cmd="SendAT", id=1, timeout=50):
        """
        Get ueip via ATCOMMAND for MultiUE
        :param id: ATCOMMAND pdu id
        :return <str> ueip
        """
        endtime = time.time() + timeout
        ueip = ""
        param = {"Command": "AT+CGPADDR", "Timeout": 5000, "SuccStr": "\r\n\r\nOK"}
        while endtime > time.time():
            try:
                self._send_msg(cmd=cmd, param=param)
                time.sleep(2)
                res = self._get_msg(cmd=cmd, timeout=5)
                res = res["Back"].strip()
                res = re.findall(r"\+CGPADDR: " + str(id) + r',"?((\d+\.?){4})"?', res)
                if len(res) > 0:
                    return res[0][0]
            except BaseException as error:
                logging.info("get ueip failed with error :{}".format(str(error)))
            time.sleep(2)
        else:
            raise Exception("Get ueip timeout!")

    def get_imsi_by_AT(self, index=None, timeout=30):
        """
        Get imsi via ATCOMMAND
        :return <str> imsi
        """
        endtime = time.time() + timeout
        while endtime > time.time():
            try:
                res = self.send_at_command(command="AT+CIMI", index=index)
                res = re.findall(r"(\d+)".format(id), res)
                if len(res) > 0 and len(res[0]) > 13:
                    return res[0]
                else:
                    res = self.get_imsi(command="AT+CIMI", index=index)
                    res = re.findall(r"(\d+)".format(id), res)
                    if len(res) > 0 and len(res[0]) > 13:
                        return res[0]
            except BaseException as error:
                logging.info("get imsi failed with error :{}".format(str(error)))
            time.sleep(2)
        else:
            print("get ue{}'s imsi failed, Go to next ue".format(index))

    def _appserver_connect(self, conn):
        """
        Connect to appserver by ssh
        :param conn: conn alias
        :return ssh connection
        """
        hostname = self.ue_config["appserver"].ssh_connection_details.addr
        username = self.ue_config["appserver"].ssh_connection_details.username
        password = self.ue_config["appserver"].ssh_connection_details.password
        sshconn = ssh.ssh()
        sshconn.connect_to(
            hostname=hostname,
            username=username,
            password=password,
            alias=conn,
            timeout=60,
        )
        return sshconn

    def start_dl_traffic(
        self,
        iperf_port,
        tp="10M",
        dur=120,
        taskname="UL test",
        timeout=30,
        apnaddress="wap1nokiacom",
        ue_mode="SA",
        buffer_size="1024B",
        process_num="1",
    ):
        """
        Start DL traffic
        :param iperf_port: port value of traffic, eg: 50001, if None, read from configuration file
                           if not None, read from TCs
        :param tp:<str> DL traffic throughput , 10M , 10K, 10G
        :param dur: DL traffic execute duration
        :param taskname: ssh connection alias
        :param taskname: check ue ip timeout
        :return None
        """
        self.ue_config["ue_mode"] = ue_mode
        if ue_mode == "SA":
            ueip = self.get_pdu_ip(apnaddress=apnaddress, timeout=timeout)
        elif ue_mode == "MultiUE_SA":
            ueip = self.get_MultiUE_pdu_ip_by_AT(id=1)
        elif ue_mode == "LTE":
            ueip = self.get_eps_info(apnaddress=apnaddress, timeout=timeout)
        else:
            ueip = self.get_pdu_ip_by_AT(id=1)
        sshconn = self._appserver_connect(taskname)
        port = iperf_port
        iperf_path = self.ue_config["appserver"].iperf_path
        cmd = "{} -c {} -u -t {} -i 1 -p {} -P {} -f m -b {} -l {} -T 64".format(
            iperf_path, ueip, dur, port, process_num, tp, buffer_size
        )
        sshconn.send_command(command=cmd, connection=taskname)
        sshconn.disconnect(connection=taskname)

    def get_ue_ip(self, timeout=200, apnaddress="wap1nokiacom", ue_mode="SA"):
        """
        Get UE ip
        :param timeout: 200
        :param apnaddress:should get rid of dot, e.g.:'wap1.nokia.com' should be set as 'wap1nokiacom'
        :param ue_mode: "SA", "LTE", ...
        :return ueip
        """
        self.ue_config["ue_mode"] = ue_mode
        ueip = ""
        if ue_mode == "SA":
            ueip = self.get_pdu_ip(apnaddress=apnaddress, timeout=timeout)
        elif ue_mode == "MultiUE_SA":
            ueip = self.get_MultiUE_pdu_ip_by_AT(id=1)
        elif ue_mode == "LTE":
            ueip = self.get_eps_info(apnaddress=apnaddress, timeout=timeout)
        else:
            ueip = self.get_pdu_ip_by_AT(id=1)
        return ueip

    def stop_dl_traffic(self, iperf_port, apnaddress="wap1nokiacom", ue_mode="SA"):
        """
        Stop DL traffic
        :param iperf_port: port value of traffic, it can be get from __int__.py file or TCs eg: 50001
        :param apnaddress: apn address of PDU, only used when ue mode is SA
        :ue_mode: SA or NSA
        :return None
        """
        if ue_mode == "SA":
            ueip = self.get_pdu_ip(apnaddress=apnaddress, timeout=200)
        elif ue_mode == "MultiUE_SA":
            ueip = self.get_MultiUE_pdu_ip_by_AT(id=1)
        elif ue_mode == "LTE":
            ueip = self.get_eps_info(apnaddress=apnaddress)
        else:
            ueip = self.get_pdu_ip_by_AT(id=1)
        sshconn = self._appserver_connect("killdl")
        port = iperf_port
        iperf_path = self.ue_config["appserver"].iperf_path
        cmd_check_iperf_process = "ps aux |grep iperf |grep " + str(port)
        output = sshconn.execute(command=cmd_check_iperf_process, connection="killdl")
        logging.debug(
            "Check DL process on app server for port:{} before kill. Output is:{}".format(
                port, output
            )
        )
        cmd = (
            "ps aux |grep iperf |grep "
            + str(ueip)
            + " |grep "
            + str(port)
            + " |awk '{print $2}' | xargs kill -9"
        )
        sshconn.send_command(command=cmd, connection="killdl")
        sshconn.disconnect(connection="killdl")

    def get_parm_value(self, param, cmd="GetParamValue", timeout=5):
        """
        Get param value on UE
        :param cmd: GetParamValue define by sigspark api
        :param param: <list> param with sigspark format
        :return <STR> (RSRP , SINR , PCI)
        """
        endtime = time.time() + timeout
        while endtime > time.time():
            self._send_msg(cmd, param=param)
            try:
                res = self._get_msg(cmd)
                if res["Values"] != "":
                    print(res["Values"])
                    param_value = res["Values"]
                    return param_value
                else:
                    raise Exception(
                        "Get param_value failed, param_value should not be none!"
                    )
            except BaseException:
                pass
            time.sleep(2)
        else:
            raise Exception("Get param_value failed!")

    def get_IMS_PDU_status(self, param, cmd="GetEvents", timeout=10):
        """
        Get param value on UE
        :param cmd: GetParamValue define by sigspark api
        :param param: <list> param with sigspark format
        :return IMS PDU session status
        """
        endtime = time.time() + timeout
        while endtime > time.time():
            self._send_msg(cmd, param=param)
            try:
                res = self._get_events_msg(cmd)
                if res["CMD"] == cmd:
                    Events_list = res["Param"]["EventList"]
                    Events_conut = res["Param"]["EventCount"]
                    for i in range(0, Events_conut):
                        Event_name = Events_list[i]["Name"]
                        IMS_PDU = "SIP Register Complete"
                        if Event_name == IMS_PDU:
                            print("IMS PDU Establish accept")
                            IMS_PDU_Establish_Accept = 1
                            break
                        else:
                            print("IMS PDU Establish fail")
                            IMS_PDU_Establish_Accept = 0
                    print(IMS_PDU_Establish_Accept)
                    if IMS_PDU_Establish_Accept == 1:
                        return True
                    else:
                        return False
                else:
                    raise Exception("IMS PDU Establish fail, Event should not be none!")
            except BaseException:
                pass
            time.sleep(2)
        else:
            raise Exception("IMS PDU Establish fail!")

    def get_Vonr_call_status(self, param, cmd="GetEvents", timeout=10):
        """
        Get param value on UE
        :param cmd: GetParamValue define by sigspark api
        :param param: <list> param with sigspark format
        :return vonr call status
        """
        endtime = time.time() + timeout
        while endtime > time.time():
            self._send_msg(cmd, param=param)
            try:
                res = self._get_events_msg(cmd)
                if res["CMD"] == cmd:
                    Events_list = res["Param"]["EventList"]
                    Events_conut = res["Param"]["EventCount"]
                    for i in range(0, Events_conut):
                        Event_name = Events_list[i]["Name"]
                        Vonr_call = "SIP MO Call Established"
                        if Event_name == Vonr_call:
                            print("SIP MO Call Established")
                            Vonr_call_Establish_Accept = 1
                            break
                        else:
                            print("SIP MO Call Establish fail")
                            Vonr_call_Establish_Accept = 0
                    print(Vonr_call_Establish_Accept)
                    if Vonr_call_Establish_Accept == 1:
                        return True
                    else:
                        return False
                else:
                    raise Exception(
                        "SIP MO Call Establish fail, Event should not be none!"
                    )
            except BaseException:
                pass
            time.sleep(2)
        else:
            raise Exception("SIP MO Call Establish fail!")

    def get_Vonr_call_release_status(self, param, cmd="GetEvents", timeout=10):
        """
        Get param value on UE
        :param cmd: GetParamValue define by sigspark api
        :param param: <list> param with sigspark format
        :return vonr call status
        """
        endtime = time.time() + timeout
        while endtime > time.time():
            self._send_msg(cmd, param=param)
            try:
                res = self._get_events_msg(cmd)
                time.sleep(3)
                if res["CMD"] == cmd:
                    Events_list = res["Param"]["EventList"]
                    Events_conut = res["Param"]["EventCount"]
                    for i in range(0, Events_conut):
                        Event_name = Events_list[i]["Name"]
                        Vonr_call = "SIP MO Call End"
                        if Event_name == Vonr_call:
                            print("SIP MO Call release fail")
                            Vonr_call_Establish_Accept = 1
                            break
                        else:
                            print("SIP MO Call release fail")
                            Vonr_call_Establish_Accept = 0
                    print(Vonr_call_Establish_Accept)
                    if Vonr_call_Establish_Accept == 1:
                        return True
                    else:
                        return False
                else:
                    raise Exception(
                        "SIP MO Call release fail, Event should not be none!"
                    )
            except BaseException:
                pass
            time.sleep(2)
        else:
            raise Exception("SIP MO Call release fail!")

    def get_Data_PDU_status(self, param, cmd="GetEvents", timeout=10):
        """
        Get param value on UE
        :param cmd: GetParamValue define by sigspark api
        :param param: <list> param with sigspark format
        :return vonr call status
        """
        endtime = time.time() + timeout
        while endtime > time.time():
            self._send_msg(cmd, param=param)
            try:
                res = self._get_events_msg(cmd)
                if res["CMD"] == cmd:
                    Events_list = res["Param"]["EventList"]
                    Events_conut = res["Param"]["EventCount"]
                    for i in range(0, Events_conut):
                        Event_name = Events_list[i]["Name"]
                        Data_PDU = "SA PDU Establish Accept"
                        if Event_name == Data_PDU:
                            Event_detail = Events_list[i]["Detail"]
                            Event_data_detail = Event_detail.split(" ")
                            Event_DATA_PDU = Event_data_detail[3]
                            print(Event_DATA_PDU)
                            DNN = "DNN:wap2nokiacom"
                            if Event_DATA_PDU == DNN:
                                print("DATA PDU Establish Accept")
                                DATA_PDU_Establish_Accept = 1
                                break
                            else:
                                print("DATA PDU Establish fail")
                                DATA_PDU_Establish_Accept = 0
                        else:
                            DATA_PDU_Establish_Accept = 0
                    print(DATA_PDU_Establish_Accept)
                    if DATA_PDU_Establish_Accept == 1:
                        return True
                    else:
                        return False
                else:
                    raise Exception(
                        "DATA PDU Establish fail, Event should not be none!"
                    )
            except BaseException:
                pass
            time.sleep(2)
        else:
            raise Exception("DATA PDU Establish fail!")

    def start_stop_check_vonr_AT(self, param, timeout=5, cmd="SendAT"):
        """
        :param cmd: GetParamValue define by sigspark api
        :param param: <str> , vonr call command like:ATD004488;
        """
        endtime = time.time() + timeout
        param_value = {"Command": param, "Timeout": 50000, "SuccStr": "OK"}
        while endtime > time.time():
            self._send_msg(cmd, param=param_value)
            try:
                res = self._get_msg(cmd)
                if (
                    res["Back"] == "\r\nOK\r\n\r\nNO CARRIER\r\n"
                    or res["Back"] == "\r\nOK\r\n"
                ):
                    print(param, " command send ok")
                    break
                else:
                    raise Exception("command send fail")
            except BaseException:
                raise Exception("command send fail!")
            time.sleep(2)

    def send_at_command_with_succStr(
        self, command="AT", timeout=50000, cmd="SendAT", index=None
    ):
        """
        Send ATCOMMAND via sigspark
        :param command: ATCOMMAND define on 3gpp
        :param timeout: Get return timeout
        :param cmd: SendAT define by sigspark api
        :return <str> response of ATCOMMAND
        """
        param = {"Command": command, "Timeout": timeout, "SuccStr": ""}
        if index is None:
            self._send_msg(cmd, param=param)
        else:
            self._send_msg(cmd, index=index, param=param)
        if index is None:
            res = self._get_msg(cmd=cmd, timeout=5)
        else:
            res = self._get_msg(cmd=cmd, index=index, timeout=5)
        return res["Back"].strip()

    def get_eps_info(self, apnaddress, cmd="GetEPSInfo", timeout=30):
        """
        Get IP on UE
        :param apnaddress: APN address
        :return <str> ue ip
        """
        endtime = time.time() + timeout
        while endtime > time.time():
            param = {"APN": apnaddress}
            self._send_msg(cmd, param=param)
            try:
                res = self._get_msg(cmd)
                if res["IP"] != "":
                    print(res["IP"])
                    ue_ip = res["IP"].split(":")[-1]
                    return ue_ip
            except BaseException:
                print("Get ue ip fail, retry!")
            time.sleep(2)
        else:
            raise Exception("Get ueip timeout!")

    def ExportReport(
        self,
        ReportName,
        ReportGenerationPath,
        OpenReportResult,
        Logfiles,
        cmd="ExportReport",
    ):
        """
        Start sigspark log on controlpc
        :param ReportName: Report path on controlpc
        :param ReportGenerationPath: Report Generation Path on controlpc
        :param OpenReportResult: Report Result paht on controlpc
        :param Logfiles: ue log on controlpc
        :param cmd: StartLog define by sigspark api
        :return None
        """
        param = {
            "ReportName": ReportName,
            "ReportGenerationPath": ReportGenerationPath,
            "OpenReportResult": OpenReportResult,
            "Logfiles": Logfiles,
        }
        self._send_common_msg(cmd, param=param)
        self._get_msg(cmd)

    def start_log_special_UE(self, logname="TA_LOG", logpath=None, cmd="StartOneLog"):
        """
        Start sigspark log on controlpc
        :param logpath: Log path on controlpc
        :param logname: Log name for saving
        :param cmd: StartLog define by sigspark api
        :return None
        """
        if logpath is None:
            logpath = "C:/tmp/uelog/AUTO/{}".format(int(time.time()))
        param = {"LogName": logname, "LogPath": logpath}
        self._send_msg(cmd, param=param)
        self._get_msg(cmd)
        return [logpath, logname]

    def stop_log_special_UE(self, cmd="StopOneLog"):
        """
        Stop sigspark log on controlpc
        :param cmd: StopLog define by sigspark api
        :return None
        """
        self._send_msg(cmd)
        self._get_msg(cmd)


class SigSparkClient(BaseClient):

    def _get_spark_license(
        self,
        cmd="LoginAuth",
        license_server_ip="10.101.36.4",
        license_server_port=3002,
        required_spark_license_time=2,
    ):
        """
        :param cmd: get spark license
        :return: None
        """
        param = {
            "IP": license_server_ip,
            "Port": license_server_port,
            "Account": self.ue_config["licenseusername"],
            "Password": self.ue_config["licensepassword"],
        }
        total_num = 5
        num = 0
        while num < total_num:
            num = num + 1
            self._send_common_msg(cmd, param=param)
            try:
                res = self._get_msg(cmd)
            except Exception as e:
                print(e)
                time.sleep(60)
                continue
            res_state = res["State"]
            if res_state == 0:
                print("Get spark license success!")
                break
            elif res_state == 1:
                raise Exception("Login failed. The dog ID is not exist!")
            elif res_state == 2:
                print(
                    "Login failed, try again! The number of online users exceeded the limit!"
                )
            elif res_state == 4:
                raise Exception("Login failed. The password or account is error!")
            elif res_state == 5:
                raise Exception("Login failed. The Account is not exist!")
            elif res_state == 6:
                raise Exception(
                    "Login failed. all of the account password and dog ID should not be empty"
                )
            elif res_state == 7:
                raise Exception(
                    "Login failed. some invalid value, please check your configuration"
                )
            time.sleep(60)
        if num >= total_num:
            raise Exception("Get spark license failed after try 5 times!")
        else:
            expire_time = datetime.strptime(res["ExpireTime"], "%Y-%m-%d %H:%M:%S")
            current_time = datetime.now()
            time_difference = expire_time - current_time
            if time_difference < timedelta(hours=int(required_spark_license_time)):
                print(
                    "spark license will expire in {}, extend it".format(time_difference)
                )
                self._extend_license()

    def _release_license(self, cmd="LogoutAuth"):
        """
        :param cmd: log out license
        :return: None
        """
        self._send_common_msg(cmd)
        self._get_msg(cmd)

    def _extend_license(self, cmd="RefreshAuth"):
        """
        :param cmd: extend license to get longer expiry time
        :return: None
        """
        total_num = 5
        num = 0
        while num < total_num:
            num = num + 1
            self._send_common_msg(cmd)
            try:
                res = self._get_msg(cmd)
            except Exception as e:
                print(e)
                time.sleep(60)
                continue
            res_state = res["State"]
            if res_state == 0:
                print("Extend spark license success!")
                break
            else:
                print("extend spark license failed for {} times".format(num))
            time.sleep(60)
        if num >= total_num:
            print("Extend spark license failed after try 5 times!")

    def send_adb_command(self, command, alias, timeout=30, interval=2):
        """
        Send adb command via ssh connection with UE control PC
        :param command: ADB command
        :param alias: connection alias
        :param timeout: waittime unitl action successful
        :param interval: retry action interval
        :return: None
        """
        adbpath = self.ue_config["apppath"].replace("Spark.exe", "adb.exe")
        cmd = "'{}' -s {} shell {}".format(adbpath, self.ue_config["sn"], command)
        sshconn = ssh.ssh()
        endtime = time.time() + timeout
        while time.time() < endtime:
            logging.info("Send ADB: {}".format(cmd))
            res = sshconn.execute(command=cmd, connection="sigspark")
            ansi_escape = re.compile(r"\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])")
            res = ansi_escape.sub("", res)
            res = res.strip()
            logging.info("Response ADB: {}".format(res))
            if "error:" not in res:
                return res
            time.sleep(interval)
        else:
            raise RuntimeError("Execute ADB cmd failed!")

    def startapp(self, dur=10, timeout=300, reset=False):
        """
        Start App by schtasks cmd
        :param dur: check TA port setup interval time (s)
        :param timeout: check TA port setup timeout (s)
        :reset: force reset spark tag
        :return <boolean> True means socket connection not reset
        """
        dur = int(dur)
        timeout = int(timeout)
        sshconn = ssh.ssh()
        try:
            res = sshconn.connect_to(
                self.ue_config["host"],
                self.ue_config["username"],
                self.ue_config["password"],
                alias="sigspark",
                timeout=120,
            )
            print("SSH to Control PC success:{}".format(str(res)))
        except BaseException as error:
            print("SSH to Control PC Error : {}".format(str(error)))
            pingcmd = "ping -c 4 {} >ping.txt".format(self.ue_config["host"])
            print(pingcmd)
            os.system(pingcmd)
            try:
                f = open("ping.txt", "r")
                print(f.read())
            finally:
                if f:
                    f.close()
        ta_status_cmd = "netstat -ano|findstr :{}".format(self.ue_config["port"])
        check_app_status = "tasklist | findstr Spark.exe"
        endtime = time.time() + 10
        while endtime > time.time() and reset is False:
            res = sshconn.execute(command=ta_status_cmd, connection="sigspark")
            if ":{}".format(self.ue_config["port"]) in res or reset:
                app_status = sshconn.execute(
                    command=check_app_status, connection="sigspark"
                )
                if "Spark.exe" in app_status:
                    sshconn.disconnect(connection="sigspark")
                    return True
        else:
            restart_cmds = [
                "taskkill /f /im SSSRXX.exe",
                "taskkill /f /im adb.exe",
                "taskkill /f /im Spark.exe",
                "schtasks /end /tn spark",
                "schtasks /delete /tn spark /f",
                "schtasks /create /tn spark /sc once /tr \"'{}'\" /st 00:00 /it /RL highest /f".format(
                    self.ue_config["apppath"]
                ),
                "schtasks /run /tn spark",
            ]
            for cmd in restart_cmds:
                sshconn.execute(command=cmd, connection="sigspark")
                time.sleep(2)
            while timeout >= 0:
                res = sshconn.execute(command=ta_status_cmd, connection="sigspark")
                if ":{}".format(self.ue_config["port"]) in res:
                    break
                else:
                    time.sleep(dur)
                    timeout = timeout - dur
                    if timeout <= 0:
                        raise Exception(
                            "Check TA port {} timeout".format(self.ue_config["port"])
                        )
            sshconn.disconnect(connection="sigspark")
            return False

    def restart_uemanager(self):
        """
        Restart Uemanager
        :return: None
        """
        self.setup_adb_connect(alias="sigspark")
        cmd = "am force-stop com.ue.dmanager"
        self.send_adb_command(command=cmd, alias="sigspark")
        cmd = (
            "am start -a android.intent.action.MAIN -c "
            "android.intent.category.LAUNCHER -n com.ue.dmanager/com.box.test.MainActivity"
        )
        self.send_adb_command(command=cmd, alias="sigspark")

    def _case_ul_tp(
        self,
        dest,
        dur="120",
        tp=5120,
        pr="UDP",
        port=5001,
        connectiontype="app",
        taskname="UL Test",
    ):
        """
        Format a UL test case with sigspark templete
        :param dest: ul appserver ip address
        :param dur: ul triffic duration
        :param tp: ul triffic throughput (bit)
        :param pr: ul triffic Protocol
        :param taskname: test case name
        :param connectiontype: connect type
        :return <dict> : sigspark templete
        """
        ul_tp = {
            "TaskName": taskname,
            "TaskEnable": True,
            "TaskType": "iperf",
            "TestTimes": 1,
            "TestInterval": 10,
            "CyclePeriod": 180,
            "TestContent": {
                "ConnectionSetup": {"ConnectionType": connectiontype},
                "Protocol": pr,
                "ProtocolVer": 3,
                "TestType": "UL",
                "Address": dest,
                "Port": port,
                "TestTime": dur,
                "UDPBandwidth": tp,
                "UDPBufferSize": 1024,
                "UDPPacketSize": 14000,
                "Thread": 1,
            },
        }
        return ul_tp

    def _get_imsi_and_ip(self, index=1, cmd="GetParamIMSI"):
        """
        Get IMSI and IP on UE
        :param cmd: GetParamIMSI define by sigspark api
        :return <tuple> (imsi, ip)
        """
        self._send_msg(cmd, index=index)
        res = self._get_msg(cmd, index=index)
        if "IMSI" in res:
            imsi = res["IMSI"]
        else:
            imsi = None
        ip = res["IP"]
        return (imsi, ip)

    def _create_task(self, cases):
        """
        Format a testplan with cases
        :param cases: <dict> return from _case_ul_tp
        :return <dict> : sigspark templete
        """
        testplan = {"TestPlans": [{"TestTasks": []}]}
        for case in cases:
            testplan["TestPlans"][0]["TestTasks"].append(case)
        return testplan

    def _update_task(self, param, cmd="UpdateTask"):
        """
        Shutdown RF on UE (not reboot)
        :param param: <dict> testplan with sigspark format
        :param cmd: UpdateTask define by sigspark api
        :return <dict>
        Example: {"State":0}
        """
        self._send_msg(cmd, param=param)
        res = self._get_msg(cmd)
        return res

    def stop_ul_traffic(self, cmd="StopTest"):
        """
        Stop UL traffic on UE
        :return None
        """
        self._send_msg(cmd)
        self._get_msg(cmd)

    def create_test_plan(
        self, taskname="Test", times=1, interval=10, content={}, cmd="CreateTestPlan"
    ):
        """
        Create test plan
        :param taskname: task name
        :param times: test times
        :param interval: sleep time before replay
        :param content: <dict>, test content define by vendor
        :return None
        """
        pass

    def start_test(self, cmd="StartTest"):
        """
        Excute testplan
        :param cmd: StartTest define by sigspark api
        :return None
        """
        pass

    def stop_test(self, cmd="StopTest"):
        """
        Stop testplan
        :param cmd: StopTest define by sigspark api
        :return None
        """
        pass

    def setup_pdu(
        self, id=1, type="IP", apn="wap1.nokia.com", ssc=0, slice=None, cmd="SetupPDU"
    ):
        """
        Setup PDU session
             Use 'AT command' like 'AT+CGDCONT=2,"IP","wap2.nokia.com"'
             and 'AT+CGACT=1,2'
        :id: <int,str> PDU cofing,context id
        :type: <str> PDU cofing, IP/IPV4V6
        :apn: <str> PDU cofing,APN
        :ssc: <str> SSC_mode,0 or 1
        :slice: <str> S_NSSAI like "1.123456;2F.654321"
        :return response of udp command
        """
        if slice is None:
            param = {"Type": type, "APN": apn, "ID": id}
        else:
            param = {
                "Type": type,
                "APN": apn,
                "ID": id,
                "SSC_mode": ssc,
                "S_NSSAI": slice,
            }
            cmd = "SetupS_NSSAI"
        self._send_msg(cmd, param=param)
        res = self._get_msg(cmd)
        return res

    def get_SA_RRC_setup_complete_time(self, index, cmd="GetEvents", timeout=15):
        """
        Get param value on UE
        :param cmd: GetParamValue define by sigspark api
        :param param: <list> param with sigspark format
        :return setup complete time
        """
        endtime = time.time() + timeout
        lastEventIndex = 0
        param = {"LastEventIndex": lastEventIndex}
        while endtime > time.time():
            self._send_msg(cmd, index=index, param=param)
            try:
                res = self._get_events_data(cmd)
                print(res)
                time.sleep(3)
                if res["CMD"] == cmd:
                    events_list = res["Param"]["EventList"]
                    events_count = res["Param"]["EventCount"]
                    lastEventIndex = res["Param"]["LastEventIndex"]
                    setup_complete = "SA RRC Setup Complete"
                    for event in events_list:
                        event_name = event["Name"]
                        if event_name == setup_complete:
                            print("SA RRC Setup Complete Found")
                            event_detail = event["Detail"]
                            complete_time = event_detail[0:-2]
                            return complete_time
                    print("RRC Setup didn't complete")
                else:
                    raise Exception("Event should not be none!")
            except BaseException:
                pass
            time.sleep(2)
        else:
            raise Exception("RRC Setup didn't complete")

    def get_event_time(self, index, event_name, cmd="GetEvents", timeout=15):
        """
        Get event time value on UE
        :param: index, ue index
        :param: event_name with sigspark format,e.g. "NR5G RACH Begin","NR5G RACH Complete"
        :param cmd: GetEvents
        :return event occurrence time
        """
        endtime = time.time() + timeout
        lastEventIndex = 0
        param = {"LastEventIndex": lastEventIndex}
        while endtime > time.time():
            self._send_msg(cmd, index=index, param=param)
            try:
                res = self._get_events_data(cmd)
                print(res)
                time.sleep(3)
                if res["CMD"] == cmd:
                    events_list = res["Param"]["EventList"]
                    lastEventIndex = res["Param"]["LastEventIndex"]
                    for event in events_list:
                        evt_name = event["Name"]
                        if evt_name == event_name:
                            print("event found")
                            event_time = event["Time"]
                            return event_time
                    print("event didn't found")
                else:
                    raise Exception("event should not be none!")
            except BaseException:
                pass
            time.sleep(2)
        else:
            raise Exception("event didn't found")

    def _get_event_count(self, index, event_name_list, cmd="GetEvents", timeout=150):
        """
        Get event count with specified event_name on UE
        :param: index, ue index
        :param: event_name,e.g. "SA HO Success","SA HO Request"
        :return event count
        """
        endtime = time.time() + timeout
        lastEventIndex = 0
        param = {"LastEventIndex": lastEventIndex}
        event_name_num = len(event_name_list)
        print(event_name_num)
        event_count_list = [0 for i in range(event_name_num)]
        self._send_msg(cmd, index=index, param=param)
        while endtime > time.time():
            try:
                res = self._get_events_data(cmd=cmd, retry=8, buflen=102400, timeout=30)
                time.sleep(3)
                res_cmd = res["CMD"]

                if str(res_cmd) == str(cmd):
                    events_list = res["Param"]["EventList"]
                    events_count = res["Param"]["EventCount"]
                    lastEventIndex = res["Param"]["LastEventIndex"]
                    for event in events_list:
                        ev_name = event["Name"]
                        for i in range(event_name_num):
                            if ev_name == event_name_list[i]:
                                event_count_list[i] += 1
                    print("event_count_list:")
                    print(event_count_list)
                    return event_count_list
                else:
                    raise Exception("Event should not be none!")
            except Exception as err:
                print(err)
            time.sleep(2)
            # return event_count
        else:
            raise Exception("get event count timeout")

    def _Update_test_plan(
        self,
        cmd_repeat_num="1",
        Synchronize_type="",
        repeat_num="1",
        service_name="CallMO",
        service_id="0x0500",
        call_type="0",
        CallMSNO="2",
        CallNumber="+6688",
        Duration="30",
        Interval="15",
        TestMOS="0",
        POLQAAlgorithm="0",
        SamplingRate="0",
        SortIndex="7",
        cmd="UpdateTaskXML",
    ):
        param = """<CommandList Repeat=\"{}\">
<Synchronize type=\"{}\">
<Command Repeat=\"{}\">
<name>{}</name>
<ID>{}</ID>
<CallType>{}</CallType>
<CallMSNO>{}</CallMSNO>
<CallNumber>{}</CallNumber>
<Duration >{}</Duration>
<Interval>{}</Interval>
<TestMOS>{}</TestMOS>
<POLQAAlgorithm>{}</POLQAAlgorithm>
<SamplingRate>{}</SamplingRate>
<SortIndex>{}</SortIndex>
</Command>
</Synchronize>
</CommandList>""".format(
            cmd_repeat_num,
            Synchronize_type,
            repeat_num,
            service_name,
            service_id,
            call_type,
            CallMSNO,
            CallNumber,
            Duration,
            Interval,
            TestMOS,
            POLQAAlgorithm,
            SamplingRate,
            SortIndex,
        )
        self._send_msg(cmd, param=param)
        self._get_msg(cmd)

    def _Update_test_plan_callmt(
        self,
        cmd_repeat_num="1",
        Synchronize_type="",
        repeat_num="1",
        service_name="CallMT",
        service_id="0x0501",
        call_type="3",
        TestMOS="0",
        SortIndex="8",
        cmd="UpdateTaskXML",
    ):
        param = """<CommandList Repeat=\"{}\">
<Synchronize type=\"{}\">
<Command Repeat=\"{}\">
<name>{}</name>
<ID>{}</ID>
<CallType>{}</CallType>
<TestMOS>{}</TestMOS>
<SortIndex>{}</SortIndex>
</Command>
</Synchronize>
</CommandList>""".format(
            cmd_repeat_num,
            Synchronize_type,
            repeat_num,
            service_name,
            service_id,
            call_type,
            TestMOS,
            SortIndex,
        )
        self._send_msg(cmd, param=param)
        self._get_msg(cmd)

    def _Update_test_plan_attach(
        self,
        cmd_repeat_num="1",
        synchronize_type="",
        repeat_num="1",
        service_name="Attach",
        service_id="0x0602",
        cmd_type="Power",
        interval="5",
        keeptime="10",
        timeout="15",
        wait_time="15",
        sort_index="1",
        cmd="UpdateTaskXML",
    ):
        param = """<CommandList Repeat=\"{}\">
<Synchronize type=\"{}\">
<Command Repeat=\"{}\">
<name>{}</name>
<ID>{}</ID>
<CMDType>{}</CMDType>
<Interval>{}</Interval>
<Keeptime>{}</Keeptime>
<TimeOut>{}</TimeOut>
<WaitTime>{}</WaitTime>
<SortIndex>{}</SortIndex>
</Command>
</Synchronize>
</CommandList>""".format(
            cmd_repeat_num,
            synchronize_type,
            repeat_num,
            service_name,
            service_id,
            cmd_type,
            interval,
            keeptime,
            timeout,
            wait_time,
            sort_index,
        )
        self._send_msg(cmd, param=param)
        self._get_msg(cmd)

    def _Update_test_plan_ping(
        self,
        cmd_repeat_num="1",
        synchronize_type="",
        repeat_num="1",
        service_name="PING",
        service_id="0x0604",
        netlink="1",
        ip="10.57.191.248",
        package_size="50",
        interval="20",
        timeout="15",
        testmode="NormalPing",
        sort_index="1",
        cmd="UpdateTaskXML",
    ):
        param = """<CommandList Repeat=\"{}\">
<Synchronize type=\"{}\">
<Command Repeat=\"{}\">
<name>{}</name>
<ID>{}</ID>
<NetLink>{}</NetLink>
<IP>{}</IP>
<Packagesize>{}</Packagesize>
<Interval>{}</Interval>
<TimeOut>{}</TimeOut>
<TestMode>{}</TestMode>
<SortIndex>{}</SortIndex>
</Command>
</Synchronize>
</CommandList>""".format(
            cmd_repeat_num,
            synchronize_type,
            repeat_num,
            service_name,
            service_id,
            netlink,
            ip,
            package_size,
            interval,
            timeout,
            testmode,
            sort_index,
        )
        self._send_msg(cmd, param=param)
        self._get_msg(cmd)

    def _Update_test_plan_bandwidth_test(
        self,
        cmd_repeat_num="1",
        synchronize_type="",
        repeat_num="10",
        service_name="BWT-UDP",
        service_id="0x0620",
        netlink="10",
        remote_host="8.8.8.8",
        port="50001",
        passive="1",
        download="0",
        bandwidth="12000",
        buffersize="1024",
        packetsize="1000",
        transfer_time="180",
        interval="5",
        sort_index="1",
        cmd="UpdateTaskXML",
    ):
        param = """<CommandList Repeat=\"{}\">
<Synchronize type=\"{}\">
<Command Repeat=\"{}\">
<name>{}</name>
<ID>{}</ID>
<NetLink>{}</NetLink>
<RemoteHost>{}</RemoteHost>
<Port>{}</Port>
<Passive>{}</Passive>
<Download>{}</Download>
<BandWidth>{}</BandWidth>
<BufferSize>{}</BufferSize>
<PacketSize>{}</PacketSize>
<transferTime>{}</transferTime>
<Interval>{}</Interval>
<SortIndex>{}</SortIndex>
</Command>
</Synchronize>
</CommandList>""".format(
            cmd_repeat_num,
            synchronize_type,
            repeat_num,
            service_name,
            service_id,
            netlink,
            remote_host,
            port,
            passive,
            download,
            bandwidth,
            buffersize,
            packetsize,
            transfer_time,
            interval,
            sort_index,
        )
        self._send_msg(cmd, param=param)
        self._get_msg(cmd)

    def _Update_test_plan_ftp_test(
        self,
        cmd_repeat_num="1",
        synchronize_type="",
        repeat_num="10",
        service_name="FTPDownload",
        service_id="0x060C",
        download="1",
        remote_host="10.57.179.240",
        port="22",
        account="ute",
        password="Ut3pa5s#ff97",
        passive="1",
        download_schema="file",
        remote_file="/home/ute/13.jpg",
        download_time="10",
        interval="20",
        threadNum="1",
        timeout="30",
        nodata_timeout="20",
        maxFTPland="2",
        sort_index="1",
        SendBufferSize="512",
        RecvBufferSize="4096",
        cmd="UpdateTaskXML",
    ):
        param = """<CommandList Repeat=\"{}\">
<Synchronize type=\"{}\">
<Command Repeat=\"{}\">
<name>{}</name>
<ID>{}</ID>
<Download>{}</Download>
<RemoteHost>{}</RemoteHost>
<Port>{}</Port>
<Account>{}</Account>
<Password>{}</Password>
<Passive>{}</Passive>
<DownloadSchema>{}</DownloadSchema>
<RemoteFile>{}</RemoteFile>
<DownloadTime>{}</DownloadTime>
<Interval>{}</Interval>
<ThreadNum>{}</ThreadNum>
<TimeOut>{}</TimeOut>
<NoDataTimeout>{}</NoDataTimeout>
<MaxFTPland>{}</MaxFTPland>
<SortIndex>{}</SortIndex>
<SendBufferSize>{}</SendBufferSize>
<RecvBufferSize>{}</RecvBufferSize>
</Command>
</Synchronize>
</CommandList>""".format(
            cmd_repeat_num,
            synchronize_type,
            repeat_num,
            service_name,
            service_id,
            download,
            remote_host,
            port,
            account,
            password,
            passive,
            download_schema,
            remote_file,
            download_time,
            interval,
            threadNum,
            timeout,
            nodata_timeout,
            maxFTPland,
            sort_index,
            SendBufferSize,
            RecvBufferSize,
        )
        self._send_msg(cmd, param=param)
        self._get_msg(cmd)

    def _Start_test_plan(self, cmd="StartTestByName", task_name="CallMO"):
        """
        {
        "CMD": "StartTestByName",
        "EQIndex": 4,
        "Param": { "TaskName": ["CallMO"] }
        }
        """
        param = {"TaskName": [task_name]}
        self._send_msg(cmd, param=param)
        self._get_msg(cmd)

    def _import_test_task(self, cmd="ImportTask", task_file="C:\\TA\\test.task"):
        """
        {
        "CMD": "ImportTask",
        "EQIndex": 4,
        "Param": { "TaskFile": task_file }
        }
        """
        param = {"TaskFile": task_file}
        self._send_msg_with_clear_tasks(cmd, param=param)
        self._get_msg(cmd)


# class PioneerClient(BaseClient):
#
#     def release_spark_license(self, ue_alias):
#         """ "
#         :param ue_alias:  <str> store ue by ue_alias
#         :return: None
#         """
#         self.store[ue_alias]._release_license()
#
#     def send_adb_command(self, command, alias, timeout=30, interval=2):
#         """
#         Send adb command via ssh connection with UE control PC
#         :param command: ADB command
#         :param alias: connection alias
#         :param timeout: waittime unitl action successful
#         :param interval: retry action interval
#         :return: None
#         """
#         adbpath = self.ue_config['apppath'].replace(
#             "Pioneer.exe", "ADB/adb.exe")
#         cmd = "'{}' -s {} shell {}".format(adbpath,
#                                            self.ue_config['sn'], command)
#         sshconn = ssh.ssh()
#         endtime = time.time() + timeout
#         while time.time() < endtime:
#             logging.info("Send ADB: {}".format(cmd))
#             res = sshconn.execute(command=cmd, connection='sigspark')
#             ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
#             res = ansi_escape.sub('', res)
#             res = res.strip()
#             logging.info("Response ADB: {}".format(res))
#             if "error:" not in res:
#                 return res
#             time.sleep(interval)
#         else:
#             raise RuntimeError("Execute ADB cmd failed!")
#
#     def startapp(self, dur=10, timeout=300, reset=False):
#         """
#         Start App by schtasks cmd
#         :param dur: check TA port setup interval time (s)
#         :param timeout: check TA port setup timeout (s)
#         :reset: force reset spark tag
#         :return <boolean> True means socket connection not reset
#         """
#         dur = int(dur)
#         timeout = int(timeout)
#         sshconn = ssh.ssh()
#         sshconn.connect_to(
#             self.ue_config['host'],
#             self.ue_config['username'],
#             self.ue_config['password'],
#             alias='sigspark')
#         ta_status_cmd = "tasklist |findstr Pioneer"
#         endtime = time.time() + 10
#         while endtime > time.time() and reset is False:
#             res = sshconn.execute(command=ta_status_cmd, connection='sigspark')
#             if "Pioneer.exe" in res:
#                 sshconn.disconnect(connection='sigspark')
#                 return True
#             time.sleep(1)
#         else:
#             restart_cmds = [
#                 "taskkill /f /im adb.exe",
#                 "taskkill /f /im Pioneer.exe",
#                 "schtasks /delete /tn dingli /f",
#                 "schtasks /create /tn dingli /sc once /tr '{}' /st 00:00 /RL highest /f".format(
#                     self.ue_config['apppath']),
#                 "schtasks /run /tn dingli"]
#             for cmd in restart_cmds:
#                 sshconn.execute(command=cmd, connection='sigspark')
#                 time.sleep(2)
#             while timeout >= 0:
#                 res = sshconn.execute(
#                     command=ta_status_cmd, connection='sigspark')
#                 if "Pioneer.exe" in res and "LogoPioneer.exe" not in res:
#                     break
#                 time.sleep(dur)
#             else:
#                 raise Exception("Start Pioneer failed in 300s")
#             sshconn.disconnect(connection='sigspark')
#             return False
#
#     def restart_uemanager(self):
#         """
#         Restart Uemanager
#         :return: None
#         """
#         self.setup_adb_connect(alias='sigspark')
#         cmd = "am force-stop com.dingli.pioneer"
#         self.send_adb_command(command=cmd, alias='sigspark')
#         cmd = (
#             "am start -a android.intent.action.MAIN -c "
#             "android.intent.category.LAUNCHER -n com.dingli.pioneer/.MainActivity")
#         self.send_adb_command(command=cmd, alias='sigspark')
#
#     def create_test_plan(self, testplanslocation=None, cmd="CreateTestPlan"):
#         """
#         Create test plan
#         :param testplanslocation: file location .dlp is project plan and .tpl is test plan
#         :return None
#         """
#         param = {"TestPlansLocation": testplanslocation}
#         self._send_msg(cmd, param)
#         self._get_msg(cmd)
#
#     def start_test(self, cmd="StartTest"):
#         """
#         Excute testplan
#         :param cmd: StartTest define by pioneer
#         :return None
#         """
#         self._send_msg(cmd)
#         self._get_msg(cmd)
#
#     def stop_test(self, cmd="StopTest"):
#         """
#         Stop testplan
#         :param cmd: StopTest define by pioneer
#         :return None
#         """
#         self._send_msg(cmd)
#         self._get_msg(cmd)
#
#     def lock_band(self, band, cmd="LockBand"):
#         """
#         Lock band on UE
#         :param band: <str> "1,3,5" means lock Band1, Band3 and Band5, and so forth
#         :return None
#         """
#         pass
#
#     def unlock_band(self, cmd="UnlockBand"):
#         """
#         UnlockBand the bands specified by “LockBand” cmd
#         :return None
#         """
#         pass
#
#     def export_message_detail(
#             self,
#             logpath,
#             localpath,
#             localname,
#             cmd="ExportMessageDetail"):
#         """
#         export L3 message detail and download to UTE
#         :param logpath: log full path for saving on UTE
#         :return None
#         """
#         sshconn = ssh.ssh()
#         sshconn.connect_to(
#             self.ue_config['host'],
#             self.ue_config['username'],
#             self.ue_config['password'],
#             alias='sigspark')
#         for i in range(1, self.ueindex + 1):
#             localfile_l = "{}{}UE{}.xml".format(localpath, localname, i)
#             localfile_w = localfile_l.replace("/", "\\")
#             localsaf_l = sshconn.execute(command="ls {}{}*UE{}*.rcu".format(localpath, localname, i),
#                                          connection='sigspark').split()
#             localsaf_w = localsaf_l[0].replace("/", "\\")
#             param = {"ExportFileName": localfile_w, "Logfile": localsaf_w}
#             self._send_common_msg(cmd, param=param)
#             res = self._get_msg(cmd, timeout=360)
#             logpath1 = "{}UE{}.xml".format(logpath, i)
#             sshconn.download_file(localfile_l, logpath1, connection='sigspark')
#         sshconn.disconnect(connection='sigspark')
#
#     def export_log_file(
#             self,
#             logpath,
#             localpath,
#             localname,
#             template='auto_test',
#             cmd="ExportLogfile"):
#         """
#         export filter log file to csv and download to UTE
#         :param logpath: log full path for saving on UTE
#         :param template: filter template name on spark
#         :return None
#         """
#         sshconn = ssh.ssh()
#         sshconn.connect_to(
#             self.ue_config['host'],
#             self.ue_config['username'],
#             self.ue_config['password'],
#             alias='sigspark')
#         for i in range(1, self.ueindex + 1):
#             localfile_l = "{}{}UE{}.csv".format(localpath, localname, i)
#             localfile_w = localfile_l.replace("/", "\\")
#             localsaf_l = sshconn.execute(command="ls {}{}*UE{}*.rcu".format(localpath, localname, i),
#                                          connection='sigspark').split()
#             localsaf_w = localsaf_l[0].replace("/", "\\")
#             param = {"TemplateName": template, "ExportFileName": localfile_w, "Logfile": localsaf_w}
#             self._send_common_msg(cmd, param=param)
#             res = self._get_msg(cmd)
#             logpath1 = "{}UE{}.csv".format(logpath, i)
#             sshconn.download_file(localfile_l, logpath1, connection='sigspark')
#         sshconn.disconnect(connection='sigspark')
#
#     def configure_apn(
#             self,
#             apn,
#             mcc="460",
#             mnc="02",
#             cmd="ConfigureAPN"):
#         """
#         Release PDU session
#         :param apnname: <str> apnname dispaly on UE
#         :param apn: <str> apn address
#         :param mcc: <str> '460' default
#         :param mnc: <str> '02' default
#         :return None
#         """
#         pass
#
#     def start_log(self, logname="LOG", logpath=None, cmd="StartLog"):
#         """
#         Start pioneer log on controlpc
#         :param logpath: Log path on controlpc
#         :param logname: Log name for saving
#         :param cmd: StartLog define by pioneer
#         :return None
#         """
#         if logpath is None:
#             logpath = "C:/tmp/{}/".format(int(time.time()))
#         param = {"LogName": logname, "LogPath": logpath}
#         self._send_common_msg(cmd, param=param)
#         self._get_msg(cmd)
#         return [logpath, logname]


class SigSpark:

    def __init__(self):
        self.store = {}
        self.client = {}

    def _update_socket_conn(self, serverip, conn):
        """
        Update client socket connection when restart socket client
        :param serverip: Controlpc ip
        :param conn: socket connection object
        """
        for alias in self.store:
            if self.store[alias].ue_config["host"] == serverip:
                self.store[alias].conn = conn

    def require_platform(
        self,
        ue_alias,
        index=0,
        reset_sol=None,
        get_spark_license=True,
        ue_num_input=None,
        required_spark_license_time=2,
        force_check_ue=False,
        eq_index=None,
    ):
        """
        Require platform to prepare like sigspark or Pioneer to start and remote connecting create
        :param ue_alias:<str> store ue by ue_alias
        :param index: ue index of ${tl.ues} , count from 0
        :param reset_sol: if not None ,Restart UEmanager on UE
        :return client
        """
        try:
            varstr = "${tl.ues[" + str(index) + "]}"
            ueobj = BuiltIn().get_variable_value(varstr)
            apppath = ueobj.server_dir
            serverip = ueobj.ssh_connection_details.addr
        except BaseException as error:
            logging.info(str(error))

        if "Spark.exe" in apppath:
            client = SigSparkClient()
        elif "Pioneer.exe" in apppath:
            client = PioneerClient()
        else:
            raise Exception("This UE not in support list!")
        client.init_config(index=index, get_spark_license=get_spark_license)
        res = client.startapp()
        print("============ssh Done=============")
        if serverip in self.client and res:
            print("============socket ready=============")
            client.setup(
                self.client[serverip]["conn"],
                get_spark_license=get_spark_license,
                ue_num_input=ue_num_input,
                required_spark_license_time=required_spark_license_time,
                force_check_ue=force_check_ue,
                eq_index=eq_index,
            )
        else:
            print("============socket new=============")
            conn = client.setup(
                get_spark_license=get_spark_license,
                ue_num_input=ue_num_input,
                required_spark_license_time=required_spark_license_time,
                force_check_ue=force_check_ue,
                eq_index=eq_index,
            )
            self._update_socket_conn(serverip, conn)
            self.client[serverip] = {"conn": conn, "log": {"state": 0}}
        print("============socket Done=============")
        if reset_sol != "none" and reset_sol is not None:
            client.restart_uemanager()
        self.store[ue_alias] = client
        return client

    def require_ue(
        self,
        ue_alias,
        power_reset,
        detach_request,
        get_spark_license=True,
        index=0,
        reset_sol=None,
        capabilities=None,
        starting_cell=None,
        starting_enb=None,
        starting_phy_cell=None,
        ue_num_input=None,
        required_spark_license_time=2,
        force_check_ue=False,
        eq_index=None,
    ):
        """
        Require UE
        :param ue_alias:<str> store ue by ue_alias
        :param index: ue index of ${tl.ues} , count from 0
        :param reset_sol: if not None ,Restart UEmanager on UE
        :param capabilities: not used, adapt to MTK api
        :param starting_cell: not used, adapt to MTK api
        :param starting_enb: not used, adapt to MTK api
        :param starting_phy_cell: not used, adapt to MTK api
        :param force_check_ue: True/False. will verify ue imsi when connect to UE. Default is not to verify.
               if verify ue failed, will continue to use UE 1 to continue the testing. This flag is used to keep the
               original behavior, if you want to make sure UE is correctly used, please set it to True
        :param eq_index: UE index start from 1. if None, will search one by one based on ue_num on spark.
                         if not none, then will verify IMSI, if passed, will set ueindex to eq_index. If you would
                         like to improve the efficiency for require_ue, you can directly specify this eq_index
        :return None
        """
        client = self.require_platform(
            ue_alias=ue_alias,
            index=index,
            reset_sol=reset_sol,
            get_spark_license=get_spark_license,
            ue_num_input=ue_num_input,
            required_spark_license_time=required_spark_license_time,
            force_check_ue=force_check_ue,
            eq_index=eq_index,
        )
        try:
            client.operate_ue_dataservice(action="disable")
        except BaseException:
            pass
        try:
            client.stop_log()
        except BaseException:
            pass
        try:
            client.stop_ul_traffic()
        except BaseException:
            pass
        try:
            if detach_request is True and power_reset.lower() == "true":
                print("use power_off")
                client.power_off()
            if detach_request is True and power_reset.lower() == "false":
                print("use detach")
                client.detach()
        except BaseException:
            pass
        self.store[ue_alias] = client

    def attach_ue(self, ue_alias, attach_mode="5G_SA", power_reset="False", timeout=-1):
        """
        Attach UE
        :param ue_alias:<str> store ue by ue_alias
        :param attach_mode:<str> 5G_SA 5G_NSA use to check whether 4G attach success or 5G attach success
        :param power_reset: <str> true or false, if true, attach_ue will use power on
        :param timeout: not used, adapt to MTK api
        :return None
        """
        if power_reset.lower() == "true":
            self.store[ue_alias].power_on()
            return None
        else:
            re = self.store[ue_alias].attach(ue_mode=attach_mode)
            time.sleep(30)
            print("it's already sleep 30 seconds")
            return re

    def detach_ue(self, ue_alias, power_reset="False", timeout=-1):
        """
        Detach UE
        :param ue_alias:<str> store ue by ue_alias
        :param power_reset: <str> true or false, if true, detach ue will use power off
        :param timeout: not used, adapt to MTK api
        :return None
        """
        if power_reset.lower() == "true":
            self.store[ue_alias].power_off()
        else:
            self.store[ue_alias].detach()
            time.sleep(30)
            print("it's already sleep 30 seconds")

    def start_data_transfer(
        self,
        ue_alias,
        direction,
        iperf_port,
        ue_mode="SA",
        dt_name="UL Test",
        duration="120",
        throughput="100Kbits/sec",
        bearer_alias="UeAutomatic",
        protocol="UDP",
        multidrb_QoS_dest=None,
        connectiontype="app",
        apn_address="wap1nokiacom",
        buffer_size="1024B",
        buffer_size_ul="1024",
        process_num="1",
        **kwargs_protocol_details
    ):
        """
        Start traffic
        :param ue_alias: <str> store ue by ue_alias
        :param direction: ul/dl
        :param iperf_port: the port value of traffic
        :param ue_mode: SA or NSA
        :param dt_name: test case name on ul , ssh connection alias on dl
        :param duration: traffic execute duration
        :param throughput: "100Kbits/sec", MKbits/sec, MKByte/sec ...
        :param bearer_alias: not used, adapt to MTK api
        :param protocol: ul triffic protocl
        :param multidrb_QoS_dest: <option> multidrb QoS rule server ipaddr
                                  multidrb_QoS_dest is a optional input
                                  for UL triffic dest ipaddr for multidrb testing
        :param connectiontype: connection type
        :param apn_address: apn address of PDU session, only used when ue mode is SA
        :param process_num: works for dl traffic
        :param **kwargs_protocol_details: not used, adapt to MTK api
        :return None
        """
        """
        EXPLANATION
        sigpark still use adb command to disable/enable mobile data because of some ues do not
        support spark command TurnOffMobileData/TurnOnMobileData, such as Qualcomm/spark modle
        so sigspark.py use a temp solution adb to adapt different kinds of UEs
        """
        self.store[ue_alias].operate_ue_dataservice(action="enable")
        time.sleep(10)
        tp, unit = re.match(r"(\d+)([@-~]*)/sec", throughput).groups()
        tp = int(tp)
        if "Bytes" in unit:
            tpstr = "{}K".format(tp)
            tp = tp * 8
        if "K" in unit:
            tpstr = "{}K".format(tp)
            tp = tp
        if "M" in unit:
            tpstr = "{}M".format(tp)
            tp = tp * 1024
        if "G" in unit:
            tpstr = "{}G".format(tp)
            tp = tp * 1024 * 1024
        if direction == "ul":
            self.store[ue_alias].start_ul_traffic(
                testtime=duration,
                bandwidth=tp,
                protocol=protocol,
                multidrb_QoS_dest=multidrb_QoS_dest,
                iperf_port=iperf_port,
                connectiontype=connectiontype,
                apnaddress=apn_address,
                buffersize=buffer_size_ul,
                ue_mode=ue_mode,
            )
        elif direction == "dl":
            self.store[ue_alias].start_dl_traffic(
                taskname=dt_name,
                dur=duration,
                tp=tpstr,
                iperf_port=iperf_port,
                process_num=process_num,
                apnaddress=apn_address,
                ue_mode=ue_mode,
                buffer_size=buffer_size,
            )

    def stop_data_transfer(
        self,
        direction,
        ue_alias,
        iperf_port,
        apn_address="wap1nokiacom",
        ue_mode="SA",
        dt_name="default",
    ):
        """
        stop traffic
        :param ue_alias: <str> store ue by ue_alias
        :param direction: ul/dl
        :param  iperf_port: port value of traffic, it can be get from __int__.py file or TCs eg: 50001
        :param apn_address: apn address of pdu session, only used when ue mode is SA
        :param ue_mode: SA or NSA
        :param dt_name: not used, adapt to MTK api
        :return None
        """
        if direction == "ul":
            self.store[ue_alias].stop_ul_traffic()
        elif direction == "dl":
            self.store[ue_alias].stop_dl_traffic(
                iperf_port, apnaddress=apn_address, ue_mode=ue_mode
            )

    def check_throughput_on_ue(self, ue_alias):
        """
        Check throughput on ue
        :param ue_alias: <str> store ue by ue_alias
        :return <tuple> (ul , dl)  (byte)
        """
        if isinstance(self.store[ue_alias], SigSparkClient):
            if self.store[ue_alias].ue_config["ue_mode"] == "LTE":
                param = "['LTE PHY Thr. DL [Mbps]','LTE PHY Thr. UL [Mbps]']"
                res = self.store[ue_alias].get_parm_value(param)
                ul_through_put = float(res[1]) * 1000000
                dl_through_put = float(res[0]) * 1000000
                res = (ul_through_put, dl_through_put)
            else:
                res = self.store[ue_alias].get_mac_tp()
        else:
            res = self.store[ue_alias].get_mac_tp()
        return res

    def enable_ue_data_service(self, ue_alias):
        """
        Enable UE data service
        :param ue_alias: <str> store ue by ue_alias
        :return None
        """
        self.store[ue_alias].operate_ue_dataservice(action="enable")

    def disable_ue_data_service(self, ue_alias):
        """
        Disable UE data service
        :param ue_alias: <str> store ue by ue_alias
        :return None
        """
        self.store[ue_alias].operate_ue_dataservice(action="disable")

    def create_pdu_session(
        self,
        ue_alias,
        id=1,
        type="IP",
        apn="wap1.nokia.com",
        timeout=30,
        slice=None,
        ssc=0,
        verify=True,
    ):
        """
        Create PDU session
            First PDU use 'adb shell svc data enable'
            second PDU
                Use 'AT command' like 'AT+CGDCONT=2,"IP","wap2.nokia.com"'
                and 'AT+CGACT=1,2'
        :param ue_alias: <str> store ue by ue_alias
        :id: <int,str> PDU cofing,context id
        :type: <str> PDU cofing, IP/IPV4V6
        :apn: <str> PDU cofing,APN
        :timeout:<boolean> timeout of get pdu ip
        :ssc: <str> SSC_mode,0 or 1 for specific PDU session
        :slice: <str> S_NSSAI like "1.123456;2F.654321" for specific PDU session
        :verify:<boolean> if True , try to get pdu ip within timeout
        :return None
        """
        if id == 1:
            self.store[ue_alias].operate_ue_dataservice(action="enable")
        else:
            self.store[ue_alias].setup_pdu(
                id=id, type=type, apn=apn, slice=slice, ssc=ssc
            )
        ueip = ""
        if verify:
            apnaddress = apn.replace(".", "")
            ueip = self.store[ue_alias].get_pdu_ip(apnaddress=apnaddress)
        return ueip

    def release_pdu_session(self, ue_alias, id=1):
        """
        Release PDU session
            First PDU use 'adb shell svc data disable'
            second PDU Use 'AT command' like 'AT+CGACT=0,2'
        :param ue_alias: <str> store ue by ue_alias
        :id: <int,str> PDU cofing,context id
        :return None
        """
        id = int(id)
        if id == 1:
            self.store[ue_alias].operate_ue_dataservice(action="disable")
        else:
            self.store[ue_alias].release_pdu(id=id)

    def start_log(self, ue_alias):
        """
        Start capture log on spark
            Logpath is in spark install path,
            such as "C:/Program Files (x86)/Spark/Data/Auto/1587435380"
        :param ue_alias: <str> store ue by ue_alias
        :return None
        """
        serverip = self.store[ue_alias].ue_config["host"]
        if self.client[serverip]["log"]["state"] == 0:
            loginfo = self.store[ue_alias].start_log()
            self.client[serverip]["log"]["state"] = 1
            self.client[serverip]["log"]["logpath"] = loginfo[0]
            self.client[serverip]["log"]["logname"] = loginfo[1]
        else:
            logging.info(
                "Nothing to do, Log process is already started! Localfile:{}/{}".format(
                    self.client[serverip]["log"]["logpath"],
                    self.client[serverip]["log"]["logname"],
                )
            )

    def stop_log(self, ue_alias, logname, filter=None, cmd="ExportMessageDetail"):
        """
        Stop capture log on spark, export and downlaod to UTE
        :param ue_alias: <str> store ue by ue_alias
        :logname:<str> logname for saving on UTE
        :filter:<str> filter template name on spark(need set on spark)
        :return None
        """
        serverip = self.store[ue_alias].ue_config["host"]
        localpath = self.client[serverip]["log"]["logpath"]
        localname = self.client[serverip]["log"]["logname"]
        if self.client[serverip]["log"]["state"] == 1:
            logging.info("Stopping log process!")
            self.store[ue_alias].stop_log()
            self.client[serverip]["log"]["state"] = 0
        else:
            logging.info(
                "Log process already stopped! Localfile:{}/{}".format(
                    localpath, localname
                )
            )
        self.store[ue_alias].export_message_detail(
            logpath=logname, localpath=localpath, localname=localname, cmd=cmd
        )
        if filter is not None:
            csvname = logname.replace(".xml", ".csv")
            self.store[ue_alias].export_log_file(
                logpath=csvname,
                template=filter,
                localpath=localpath,
                localname=localname,
            )

    def read_log(self, logname):
        """
        open spark log file and format
        :logname:<str> logname for saving on UTE(xml file)
             will try to open .csv
        :return None
        """
        if logname[-4:].lower() == ".xml":
            self.xmlreader = sparkxml()
            self.xmlreader.open(logname)
            try:
                self.csvreader = sparkcsv()
                self.csvreader.open(logname.replace(".xml", ".csv"))
            except Exception as error:
                logging.info("read csv error: {}".format(error))
        elif logname[-4:].lower() == ".csv":
            self.csvreader = sparkcsv()
            self.csvreader.open(logname)
        else:
            raise Exception("Error type log input!")

    def get_expected_val(self, msg, expression=None, type="last"):
        """
        get expect val form spark L3 message log
        :msg:<str> L3 message name that display on spark UI
        :expression:<str> deep path of split by '.'
        :type:<str> default 'last'
            'last' for get match expression on the last msg
            'all' for get match expression on all msg
            other for get match expression on first msg
        :return <str,list>
            if expression is None, return message name or None
            else return expected value/list or None
        """
        return self.xmlreader.find(msg=msg, path=expression, type=type)

    def check_expected_val(self, msg, expression):
        """
        get expect val form spark L3 message log
        :msg:<str> L3 message name that display on spark UI
        :expression:<str> expression like "path1 = value1 && path2 = value2";
            path is deep path of split by '.'
        :return None
        """
        self.xmlreader.check(msg=msg, expression=expression)

    def get_IE_list(self, ie, starttime=None, endtime=None):
        """
        get IE value list during starttime to endtime
        :ie:<str> IE that setting templete of spark UI
        :starttime:<int> timestamp of second
        :endtime:<int> timestamp of second
        :return:<list> expected value list
        """
        return self.csvreader.find(ie=ie, starttime=starttime, endtime=endtime)

    def restartapp(self, index=0, get_spark_license=True):
        """
        Restart app on control pc
        :param index: ue index of ${tl.ues} , count from 0
        :return: None
        """
        client = BaseClient()
        serverip, apppath = client.init_config(index=index)
        if "Spark.exe" in apppath:
            client = SigSparkClient()
        elif "Pioneer.exe" in apppath:
            client = PioneerClient()
        else:
            raise Exception("This UE not in support list!")
        client.init_config(index=index)
        client.startapp(reset=True)
        conn = client.setup(get_spark_license=get_spark_license)
        self._update_socket_conn(serverip, conn)
        self.client[serverip] = {"conn": conn, "log": {"state": 0}}

    def set_apn_on_ue(self, ue_alias, apn):
        """
        Set APN on UE, only adapt for Mate20 X
        :param ue_alias: <str> store ue by ue_alias
        :param apn: <str> APN address
        :return None
        """
        self.store[ue_alias].set_apn(apn)

    def set_depleyment_on_ue(self, ue_alias, depleyment=1):
        """
        Set 5G depleyment on UE, UE will auto reboot, only adapt for Mate20 X
        :param ue_alias: <str> store ue by ue_alias
        :param depleyment: 0:NAS 1:SA 2:Both
        :return None
        """
        self.store[ue_alias].set_depleyment(depleyment)

    def teardown(self, ue_alias):
        """
        Disconnect all UEs on control PC stored in ue_alias,
        Teardown socket connection between ute to control PC,
        Don't use this function with multi UEs on same control PC
        :param ue_alias: <str> store ue by ue_alias
        :return None
        """
        logging.warning("Don't use this function with multi UEs on same control PC")
        self.store[ue_alias].teardown()

    def power_on(self, ue_alias, timeout=-1):
        """
        power on UE
        :param ue_alias:<str> store ue by ue_alias
        :param timeout: not used, adapt to MTK api
        :return None
        """
        self.store[ue_alias].power_on()

    def power_off(self, ue_alias, timeout=-1):
        """
        power off UE
        :param ue_alias:<str> store ue by ue_alias
        :param timeout: not used, adapt to MTK api
        :return None
        """
        self.store[ue_alias].power_off()

    def config_5g_deployment(self, ue_alias, nettype):
        """
        Configure the UE 5G deployment
        :param ue_alias: <str> store ue by ue_alias
        :param nettype: <str> 'NSA' or 'SA+NSA' or 'AUTO'
        :return:None
        """
        if nettype == "NSA":
            nettype = 8
        elif nettype == "SA+NSA":
            nettype = 20
        elif nettype == "AUTO":
            nettype = 0
        self.store[ue_alias].config_5g_deployment(nettype=nettype)

    def configure_apn(self, ue_alias, apn, mcc="460", mnc="02"):
        """
        Update or insert APN on UE
        :param ue_alias: <str> store ue by ue_alias
        :param apnname:<str> apnname dispaly on UE,if apn name existed,update this apn,else insert apn
        :param apn: <str> apn address
        :param mcc: <str> mcc mode, '460' default
        :param mnc: <str> mnc mode, '02' default
        :return: None
        """
        self.store[ue_alias].configure_apn(apn, mcc, mnc)

    def start_test(self, ue_alias):
        """
        Start test plan on pioneer
        :param ue_alias: <str> store ue by ue_alias
        :return None
        """
        self.store[ue_alias].start_test()

    def stop_test(self, ue_alias):
        """
        Stop test plan on pioneer
        :param ue_alias: <str> store ue by ue_alias
        :return None
        """
        self.store[ue_alias].stop_test()

    def create_test_plan(self, ue_alias, testplanslocation):
        """
        create test plan on pioneer
        :param ue_alias: <str> store ue by ue_alias .dlp is create project .tlp is create testplan
        :return None
        """
        self.store[ue_alias].create_test_plan(testplanslocation)

    def disconnect_ues(self, ue_alias):
        """
        disconnect ue
        :param ue_alias: <str> store ue by ue_alias
        :return None
        """
        self.store[ue_alias]._disconnect_ues()

    def connect_ues(self, ue_alias):
        """
        disconnect ue
        :param ue_alias: <str> store ue by ue_alias
        :return None
        """
        self.store[ue_alias]._connect_ues()

    def get_parm_value_on_ue(self, param, ue_alias):
        """
        get param value on ue
        :param ue_alias: <str> store ue by ue_alias
        :return <list>
        """
        res = self.store[ue_alias].get_parm_value(param)
        return res

    def get_IMS_PDU_status_on_ue(self, param, ue_alias):
        """
        Get Events on UE
        :param cmd: GetEvents define by sigspark api
        :param param: <list> param with sigspark format
        :return events list
        """
        res = self.store[ue_alias].get_IMS_PDU_status(param)
        return res

    def get_Vonr_call_status_on_ue(self, param, ue_alias):
        """
        Get Events on UE
        :param cmd: GetEvents define by sigspark api
        :param param: <list> param with sigspark format
        :return vonr call status
        """
        res = self.store[ue_alias].get_Vonr_call_status(param)
        return res

    def get_Vonr_call_release_status_on_ue(self, param, ue_alias):
        """
        Get Events on UE
        :param cmd: GetEvents define by sigspark api
        :param param: <list> param with sigspark format
        :return vonr call release status
        """
        res = self.store[ue_alias].get_Vonr_call_release_status(param)
        return res

    def get_Data_PDU_status_on_ue(self, param, ue_alias):
        """
        Get Events on UE
        :param cmd: GetEvents define by sigspark api
        :param param: <list> param with sigspark format
        :return Data PDU status
        """
        res = self.store[ue_alias].get_Data_PDU_status(param)
        return res

    def get_pdu_ip(self, apnaddress, ue_alias):
        """
        Get IP on UE
        :param pduid: GetParamIMSI define by sigspark api
        :return <str> ip
        """
        res = self.store[ue_alias].get_pdu_ip(apnaddress)
        return res

    def get_pdu_ip_by_AT(self, ue_alias, id=1):
        """
        Get IP on UE
        :return <str> ip
        """
        res = self.store[ue_alias].get_pdu_ip_by_AT(id)
        return res

    def send_AT_command_CPE(self, ue_alias, param):
        """
        start vonr call by AT command
        :param ue_alias: <str> store ue by ue_alias
        :return <list>
        """
        res = self.store[ue_alias].start_stop_check_vonr_AT(param)
        return res

    def send_at_command_on_ue(self, command, ue_alias):
        """
        Send ATCOMMAND via sigspark
        :param ue_alias: <str> store ue by ue_alias
        :return <str> response of ATCOMMAND
        """
        res = self.store[ue_alias].send_at_command_with_succStr(command)
        return res

    def release_spark_license(self, ue_alias):
        """ "
        :param ue_alias:  <str> store ue by ue_alias
        :return: None
        """
        self.store[ue_alias]._release_license()

    def get_SA_RRC_setup_complete_time_on_ue(self, index, ue_alias):
        """
        Get Events on UE
        :param cmd: GetEvents define by sigspark api
        :param index: ue number
        :param param: <list> param with sigspark format
        :return setup complete time
        """
        res = self.store[ue_alias].get_SA_RRC_setup_complete_time(index)
        return res

    def get_event_count_on_ue(self, index, event_name, ue_alias, timeout=150):
        """
        Get Events on UE
        Get event count with specified event_name on UE
        :param: index, ue index
        :param: event_name,e.g. "SA HO Success","SA HO Request"
        :return event count
        """
        res = self.store[ue_alias]._get_event_count(
            index=index, event_name_list=event_name, timeout=timeout
        )
        return res

    def get_event_time_on_ue(self, index, event_name, ue_alias, timeout=150):
        """
        Get Event occurrence time on UE
        :param: index, ue index
        :param: event_name,e.g. "NR5G RACH Begin","NR5G RACH Complete"
        :return event occurrence time
        """
        res = self.store[ue_alias].get_event_time(
            index=index, event_name=event_name, timeout=timeout
        )
        return res

    def get_ue_ip_on_ue(
        self, ue_alias, timeout=200, apnaddress="wap1nokiacom", ue_mode="SA"
    ):
        """
        Get Events on UE
        Get event count with specified event_name on UE
        :param: index, ue index
        :param: event_name,e.g. "SA HO Success","SA HO Request"
        :return event count
        """
        res = self.store[ue_alias].get_ue_ip(
            timeout=timeout, apnaddress=apnaddress, ue_mode=ue_mode
        )
        return res

    def Update_test_plan(
        self,
        ue_alias,
        cmd_repeat_num="1",
        Synchronize_type="",
        repeat_num="1",
        service_name="CallMO",
        service_id="0x0500",
        call_type="0",
        CallMSNO="2",
        CallNumber="+6688",
        Duration="20",
        Interval="15",
        TestMOS="0",
        POLQAAlgorithm="0",
        SamplingRate="0",
        SortIndex="7",
        cmd="UpdateTaskXML",
    ):
        res = self.store[ue_alias]._Update_test_plan(
            cmd_repeat_num=cmd_repeat_num,
            Synchronize_type=Synchronize_type,
            repeat_num=repeat_num,
            service_name=service_name,
            service_id=service_id,
            call_type=call_type,
            CallMSNO=CallMSNO,
            CallNumber=CallNumber,
            Duration=Duration,
            Interval=Interval,
            TestMOS=TestMOS,
            POLQAAlgorithm=POLQAAlgorithm,
            SamplingRate=SamplingRate,
            SortIndex=SortIndex,
            cmd=cmd,
        )
        return res

    def Update_test_plan_callmt(
        self,
        ue_alias,
        cmd_repeat_num="1",
        Synchronize_type="",
        repeat_num="1",
        service_name="CallMT",
        service_id="0x0501",
        call_type="3",
        TestMOS="0",
        SortIndex="8",
        cmd="UpdateTaskXML",
    ):
        res = self.store[ue_alias]._Update_test_plan_callmt(
            cmd_repeat_num=cmd_repeat_num,
            Synchronize_type=Synchronize_type,
            repeat_num=repeat_num,
            service_name=service_name,
            service_id=service_id,
            call_type=call_type,
            TestMOS=TestMOS,
            SortIndex=SortIndex,
            cmd=cmd,
        )
        return res

    def Start_test_plan(self, ue_alias, cmd="StartTestByName", task_name="CallMO"):
        res = self.store[ue_alias]._Start_test_plan(cmd=cmd, task_name=task_name)
        return res

    def Import_test_plan(
        self, ue_alias, cmd="ImportTask", task_file="C:\\TA\\test.task"
    ):
        res = self.store[ue_alias]._import_test_task(cmd=cmd, task_file=task_file)
        return res

    def start_log_with_special_logpath(self, ue_alias, logname="TA_LOG", logpath=None):
        """
        Start capture log on spark
            Logpath is in spark install path,
            such as "C:/Program Files (x86)/Spark/Data/Auto/1587435380"
        :param ue_alias: <str> store ue by ue_alias
        :return None
        """
        serverip = self.store[ue_alias].ue_config["host"]
        if self.client[serverip]["log"]["state"] == 0:
            loginfo = self.store[ue_alias].start_log(logname=logname, logpath=logpath)
            self.client[serverip]["log"]["state"] = 1
            self.client[serverip]["log"]["logpath"] = loginfo[0]
            self.client[serverip]["log"]["logname"] = loginfo[1]
        else:
            logging.info(
                "Nothing to do, Log process is already started! Localfile:{}/{}".format(
                    self.client[serverip]["log"]["logpath"],
                    self.client[serverip]["log"]["logname"],
                )
            )

    def ExportReport(
        self, ue_alias, ReportName, ReportGenerationPath, OpenReportResult, Logfiles
    ):
        """
        Start sigspark log on controlpc
        :param ReportName: Report path on controlpc
        :param ReportGenerationPath: Report Generation Path on controlpc
        :param OpenReportResult: Report Result path on controlpc
        :param Logfiles: ue log path on controlpc
        :param cmd: StartLog define by sigspark api
        :return None
        """
        res = self.store[ue_alias].ExportReport(
            ReportName=ReportName,
            ReportGenerationPath=ReportGenerationPath,
            OpenReportResult=OpenReportResult,
            Logfiles=Logfiles,
        )
        return res

    def start_log_special_UE(self, ue_alias, logname="TA_LOG", logpath=None):
        """
        Start capture log on spark
            Logpath is in spark install path,
            such as "C:/Program Files (x86)/Spark/Data/Auto/1587435380"
        :param ue_alias: <str> store ue by ue_alias
        :return None
        """
        serverip = self.store[ue_alias].ue_config["host"]
        if self.client[serverip]["log"]["state"] == 0:
            loginfo = self.store[ue_alias].start_log_special_UE(
                logname=logname, logpath=logpath
            )
            self.client[serverip]["log"]["state"] = 1
            self.client[serverip]["log"]["logpath"] = loginfo[0]
            self.client[serverip]["log"]["logname"] = loginfo[1]
        else:
            logging.info(
                "Nothing to do, Log process is already started! Localfile:{}/{}".format(
                    self.client[serverip]["log"]["logpath"],
                    self.client[serverip]["log"]["logname"],
                )
            )

    def stop_log_special_UE(
        self, ue_alias, logname, filter=None, cmd="ExportMessageDetail"
    ):
        """
        Stop capture log on spark, export and downlaod to UTE
        :param ue_alias: <str> store ue by ue_alias
        :logname:<str> logname for saving on UTE
        :filter:<str> filter template name on spark(need set on spark)
        :return None
        """
        serverip = self.store[ue_alias].ue_config["host"]
        localpath = self.client[serverip]["log"]["logpath"]
        localname = self.client[serverip]["log"]["logname"]
        if self.client[serverip]["log"]["state"] == 1:
            logging.info("Stopping log process!")
            self.store[ue_alias].stop_log_special_UE()
            self.client[serverip]["log"]["state"] = 0
        else:
            logging.info(
                "Log process already stopped! Localfile:{}/{}".format(
                    localpath, localname
                )
            )
        self.store[ue_alias].export_message_detail(
            logpath=logname, localpath=localpath, localname=localname, cmd=cmd
        )
        if filter is not None:
            csvname = logname.replace(".xml", ".csv")
            self.store[ue_alias].export_log_file(
                logpath=csvname,
                template=filter,
                localpath=localpath,
                localname=localname,
            )

    def Update_test_plan_attach(
        self,
        ue_alias,
        cmd_repeat_num="1",
        synchronize_type="",
        repeat_num="5",
        service_name="Attach",
        service_id="0x0602",
        cmd_type="Power",
        interval="5",
        keeptime="10",
        timeout="15",
        wait_time="15",
        sort_index="1",
        cmd="UpdateTaskXML",
    ):
        res = self.store[ue_alias]._Update_test_plan_attach(
            cmd_repeat_num=cmd_repeat_num,
            synchronize_type=synchronize_type,
            repeat_num=repeat_num,
            service_name=service_name,
            service_id=service_id,
            cmd_type=cmd_type,
            interval=interval,
            keeptime=keeptime,
            timeout=timeout,
            wait_time=wait_time,
            sort_index=sort_index,
            cmd=cmd,
        )
        return res

    def Update_test_plan_ping(
        self,
        ue_alias,
        cmd_repeat_num="1",
        synchronize_type="",
        repeat_num="1",
        service_name="PING",
        service_id="0x0604",
        netlink="1",
        ip="10.57.191.248",
        package_size="50",
        interval="20",
        timeout="15",
        testmode="NormalPing",
        sort_index="1",
        cmd="UpdateTaskXML",
    ):
        res = self.store[ue_alias]._Update_test_plan_ping(
            cmd_repeat_num=cmd_repeat_num,
            synchronize_type=synchronize_type,
            repeat_num=repeat_num,
            service_name=service_name,
            service_id=service_id,
            netlink=netlink,
            ip=ip,
            package_size=package_size,
            interval=interval,
            timeout=timeout,
            testmode=testmode,
            sort_index=sort_index,
            cmd=cmd,
        )
        return res

    def Update_test_plan_bandwidth_test(
        self,
        ue_alias,
        cmd_repeat_num="1",
        synchronize_type="",
        repeat_num="2",
        service_name="BWT-UDP",
        service_id="0x0620",
        netlink="10",
        remote_host="10.57.191.248",
        port="56073",
        passive="1",
        download="0",
        bandwidth="50000",
        buffersize="1024",
        packetsize="1400",
        transfer_time="60",
        interval="5",
        sort_index="1",
        cmd="UpdateTaskXML",
    ):
        res = self.store[ue_alias]._Update_test_plan_bandwidth_test(
            cmd_repeat_num=cmd_repeat_num,
            synchronize_type=synchronize_type,
            repeat_num=repeat_num,
            service_name=service_name,
            service_id=service_id,
            netlink=netlink,
            remote_host=remote_host,
            port=port,
            passive=passive,
            download=download,
            bandwidth=bandwidth,
            buffersize=buffersize,
            packetsize=packetsize,
            transfer_time=transfer_time,
            interval=interval,
            sort_index=sort_index,
            cmd=cmd,
        )
        return res

    def Update_test_plan_ftp_test(
        self,
        ue_alias,
        cmd_repeat_num="1",
        synchronize_type="",
        repeat_num="10",
        service_name="FTPDownload",
        service_id="0x060C",
        download="1",
        remote_host="10.57.179.240",
        port="22",
        account="ute",
        password="Ut3pa5s#ff97",
        passive="1",
        download_schema="file",
        remote_file="/home/ute/13.jpg",
        download_time="10",
        interval="20",
        threadNum="1",
        timeout="30",
        nodata_timeout="20",
        maxFTPland="2",
        sort_index="1",
        SendBufferSize="512",
        RecvBufferSize="4096",
        cmd="UpdateTaskXML",
    ):
        res = self.store[ue_alias]._Update_test_plan_ftp_test(
            cmd_repeat_num=cmd_repeat_num,
            synchronize_type=synchronize_type,
            repeat_num=repeat_num,
            service_name=service_name,
            service_id=service_id,
            download=download,
            remote_host=remote_host,
            port=port,
            account=account,
            password=password,
            passive=passive,
            download_schema=download_schema,
            remote_file=remote_file,
            download_time=download_time,
            interval=interval,
            threadNum=threadNum,
            timeout=timeout,
            nodata_timeout=nodata_timeout,
            maxFTPland=maxFTPland,
            sort_index=sort_index,
            SendBufferSize=SendBufferSize,
            RecvBufferSize=RecvBufferSize,
            cmd=cmd,
        )
        return res
