# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Pawel Chomicki
:contact: pawel.chomicki@nokia.com
"""
from functools import wraps


class StateAllowed(object):

    CURRENT_STATE = {}
    INIT = 0
    STARTED = 1
    ANY = 2

    def __init__(self, *allowed_states):
        self.allowed_states = []
        for each in allowed_states:
            self.allowed_states.append(getattr(StateAllowed, each))

    def __call__(self, func):
        def wrapper(*args, **kwargs):
            wraps(func)(self)
            alias = args[0].alias
            if StateAllowed.ANY in self.allowed_states or StateAllowed.CURRENT_STATE[alias] in self.allowed_states:
                return func(*args, **kwargs)
        return wrapper

    @classmethod
    def set_state(cls, new_state, alias=None):
        """Sets current state for specified alias."""
        cls.CURRENT_STATE[alias] = getattr(cls, new_state)
