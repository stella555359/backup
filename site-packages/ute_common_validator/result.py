# -*- coding: utf-8 -*-
"""Module for ValidationResult

:author: Bartłomiej Idzikowski, Juergen Richter
:contact: bartlomiej.idzikowski@nsn.com, juergen.richter@nsn.com
"""


class ValidationResult(object):
    """Class for storing value, result, message."""

    def __init__(self, value, result, message):
        """
        :param object value: Validated value.
        :param boolean result: Validation result.
        :param string message: Validation message.

        :return: Validation result.
        :rtype: boolean

        .. code-block:: python

           validation_result = ValidationResult(10, True, 'Is value the number type')
           print validation_result           # will print 'Is value the number type'
        """
        self.value = value
        self.result = result
        self.message = message

    def __str__(self):
        return self.message
