# -*- coding: utf-8 -*-
"""
:author: Pawel Chomicki
:contact: pawel.chomicki@nsn.com
"""
from ute_core.exception import CoreException


class ValidatorException(CoreException):
    """Base exception for other validator exception"""


class EmptyValidatorListError(ValidatorException):
    """Exception raised if multi-validator is created without sub-validators."""


class ValueNotValid(ValidatorException):
    """Exception raised when validate result is False."""
