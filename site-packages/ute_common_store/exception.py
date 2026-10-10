# -*- coding: utf-8 -*-
"""
:author: Pawel Chomicki
:contact: pawel.chomicki@nsn.com
"""
from ute_core.exception import CoreException


class StoreException(CoreException):
    """Store base exception"""


class NameIsProtected(StoreException):
    """Exception raised when key is tried to be overridden."""


class AliasError(StoreException):
    """Exception raised if alias doesn't exist."""
