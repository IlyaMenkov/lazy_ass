#!/usr/bin/env python

import logging
import os
import sys
import traceback
import warnings

if sys.version_info[0] == 3:
    str_cls = str
else:
    str_cls = eval('unicode')


def filename(string):
    if not os.path.exists(string):
        msg = "%r is not exists" % string
        raise argparse.ArgumentTypeError(msg)
    if not os.path.isfile(string):
        msg = "%r is not a file" % string
        raise argparse.ArgumentTypeError(msg)
    return string

def parse_args(args):
    defaults = {
        'TESTRAIL_URL': 'https://mirantis.testrail.com',
        'TESTRAIL_USER': 'user@example.com',
        'TESTRAIL_PASSWORD': 'password',
        'TESTRAIL_PROJECT': 'Mirantis OpenStack',
        'TESTRAIL_MILESTONE': '9.0',
        'TESTRAIL_TEST_SUITE': '[{0.testrail_milestone}] MOSQA',
        'XUNIT_REPORT': 'report.xml',
        'OUTPUT_XUNIT_REPORT': 'output_report.xml',
        'XUNIT_NAME_TEMPLATE': '{id}',
        'TESTRAIL_NAME_TEMPLATE': '{custom_report_label}',
        'ISO_ID': None,
        'TESTRAIL_PLAN_NAME': None,
        'ENV_DESCRIPTION': '',
        'TEST_RESULTS_LINK': '',
        'PASTE_BASE_URL': None
    }
    defaults = {k: os.environ.get(k, v) for k, v in defaults.items()}

    parser = argparse.ArgumentParser(description='xUnit to testrail reporter')
    parser.add_argument(
        'xunit_report',
        type=filename,
        default=defaults['XUNIT_REPORT'],
        help='xUnit report XML file')

    parser.add_argument(
        '--output-xunit-report',
        type=str_cls,
        default=defaults['OUTPUT_XUNIT_REPORT'],
        help='Output xUnit report XML file after update')

