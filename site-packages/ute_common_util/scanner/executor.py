# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Pawel Chomicki
:contact: pawel.chomicki@nokia.com
"""
import subprocess
import signal

from ute_common_util.timeout import Timeout
from .exception import ScannerExecutionTimeout


class CmdExecutor(object):
    """Command line executor."""

    def __init__(self, timeout):
        """
        :param float timeout: Execution timeout.
        """
        self._timeout = timeout

    def execute_command(self, cmd):
        """Execute given command via shell.

        :param string cmd: Execution command.

        :return: Received stdout, stderr, rc.
        :raise: ScannerExecutionException if scanner is not able to scan network before timeout.
        """
        proc = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
        return self._wait_for_execution_result(proc)

    def _wait_for_execution_result(self, proc):
        timeout = Timeout(self._timeout)
        while timeout.is_not_reached():
            if self._is_process_working(proc):
                continue
            return self._read_process_data(proc)
        proc.send_signal(signal.SIGINT)
        proc.send_signal(signal.SIGQUIT)
        raise ScannerExecutionTimeout("It was not possible to execute command")

    def _is_process_working(self, proc):
        rc = proc.poll()
        return True if rc is None else False

    def _read_process_data(self, proc):
        stdout, stderr = proc.communicate()
        rc = proc.poll()
        return stdout, stderr, rc
