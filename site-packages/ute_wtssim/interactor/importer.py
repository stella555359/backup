# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Pawel Chomicki
:contact: pawel.chomicki@nokia.com
"""

from importlib import import_module


class NonDotClientImporter(object):
    """Class to import library without dot in the name."""

    def import_client(self, module_name):
        """Import library based on provided name.

        :param string module_name: Module or package name to import.
        """
        module = import_module(module_name)
        if hasattr(module, module_name):
            return getattr(module, module_name)()
        return module


class DotClientImporter(object):
    """Class to import library with dot in the name.

    :note: This importer is useful to import sub-package, sub-module or class."""

    def import_client(self, path):
        """Import library based on provided name.

        :param string path: Package, module or class name to import.
        """
        module_part, class_part = path.rsplit('.', 1)
        try:
            module = import_module(path)
            if hasattr(module, class_part):
                return getattr(module, class_part)()
            return module
        except ImportError:
            module = import_module(module_part)
            if hasattr(module, class_part):
                return getattr(module, class_part)()
