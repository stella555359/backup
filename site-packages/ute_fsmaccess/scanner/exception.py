# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Pawel Chomicki
:contact: pawel.chomicki@nokia.com
"""
from ute_common_util.exception import UtilException


class ScannerException(UtilException):
    """Base exception for scanner package."""


class NoHostFound(ScannerException):
    """Exception is raised when scanner is not able to find any host."""


class ScannerExecutionError(ScannerException):
    """Exception is raised when executor finished with error code."""
    def __init__(self, msg, out, err):
        out = "+++ OUTPUT +++\n{}\n".format(out)
        err = "+++ ERROR +++\n{}\n".format(err)
        msg = "{}\n{}\n{}\n".format(msg, out, err)
        super(ScannerExecutionError, self).__init__(msg)


class ScannerExecutionTimeout(ScannerException):
    """Exception is raised when execution timeout appears."""


class ScannerExecutionResultError(ScannerException):
    """Exception is raised when result format is incorrect."""


class HostStillFound(ScannerException):
    """Exception is raised if a given host is still available."""
