"""
hran_pacman's configuration is based on
single global wrapper of configuration file.

Default name of configuration file is config.cfg
Default configuration values are platform-depended.

There are two important configuration values kept in .cfg file:
**LOCAL_ROOT** - final destination of downloaded package.
**REMOTE_ROOT** - path of shared resources, it can be conditionally
source or destination path for package.
"""
try:
    from ConfigParser import RawConfigParser
except ImportError:  # pragma: no cover
    from configparser import RawConfigParser

import sys
from os import path

print(sys.platform.lower())

if "win" in sys.platform.lower():
    LOCAL_ROOT = r"C:\btsauto"
    REMOTE_ROOT = r"\\10.154.10.13\iav_wcdma/07_Automation\packages"
elif "linux" in sys.platform.lower():
    LOCAL_ROOT = r"/home/ute/btsauto"
    REMOTE_ROOT = r"/media/burak/07_Automation/packages"
else:
    raise SystemError("System " + sys.platform + " was not recognized as Windows or Linux")

CFG_FILENAME = "config.cfg"


class PacManConfig(object):
    """Higher abstraction adapter of
    ConfigParser functionality from Python's standard library.

    Manages and wraps over configuration file to ensure
    it existence, validity, and default values on creation.

    Stands as interface for abstract write/read
    interaction with global configuration.
    """

    def __init__(self):
        self._reload()

    def _reload(self):
        self.config = RawConfigParser()

        cfg_file_is_valid = False
        if self._check_existence():
            with open(CFG_FILENAME) as cfg_file:
                self.config.readfp(cfg_file)
                if self.config.has_section("Paths"):
                    cfg_file_is_valid = True

        if not cfg_file_is_valid:
            self._make_new_file()

    def _check_existence(self):
        return path.exists(CFG_FILENAME)

    def _make_new_file(self):
        self.config.add_section("Paths")
        self.set_local_path(LOCAL_ROOT)
        self.set_remote_path(REMOTE_ROOT)
        self._save_file()

    def _save_file(self):
        with open(CFG_FILENAME, "w") as cfg_file:
            self.config.write(cfg_file)

    def get_local_path(self):
        """
        :return: Local destination path of the package
        """
        return self.config.get("Paths", "Local_root_path")

    def get_remote_path(self):
        """
        :return: Remote, shared resource path, often mounter medium.
        """
        return self.config.get("Paths", "Remote_root_path")

    def set_local_path(self, local_root_path):
        """
        :param local_root_path: new local packages path
        """
        self.config.set("Paths", "Local_root_path", local_root_path)
        self._save_file()

    def set_remote_path(self, remote_root_path):
        """
        :param remote_root_path: new remote storage path
        """
        self.config.set("Paths", "Remote_root_path", remote_root_path)
        self._save_file()


config = PacManConfig()
