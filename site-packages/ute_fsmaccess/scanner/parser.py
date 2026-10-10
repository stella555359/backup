# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Pawel Chomicki
:contact: pawel.chomicki@nokia.com
"""


class NmapParser(object):
    """Class to read and parse nmap output."""

    def find_hosts(self, out):
        """Finds hosts in nmap output.

        :param string out: Output from nmap application.

        :return: Hosts displayed by nmap application.
        :rtype: list
        """
        if not out:
            return []
        lines = self._split_into_lines(out.decode() if not isinstance(out, str) else out)
        return self._read_hosts(lines)

    def _split_into_lines(self, out):
        return [each for each in out.split('\n') if 'Host' in each and 'Status' in each]

    def _read_hosts(self, lines):
        return [each.split(' ')[1].strip() for each in lines]
