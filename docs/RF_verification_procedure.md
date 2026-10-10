
Epics: [UTS-15151](https://jiradc.ext.net.nokia.com/browse/UTS-15151), [UTS-18040](https://jiradc.ext.net.nokia.com/browse/UTS-18040)

Ticket: [UTETAF-4621](https://jiradc.ext.net.nokia.com/browse/UTETAF-4621)

# Intro
As the TAF team, we can only ensure that UTE environment, that is, libraries, agents, and services are compatible with Robot Framework v3.1.2, v3.2.2, v4.1.3, and v.5.0.1.

The RF artifacts such as test scripts and resources that are stored in **robotws** and **robotlte** test repositories have to be verified and adapted if needed by their authors/maintainers regarding backward incompatible changes described in release notes till RF v5.0.1. These changes are listed in [UTETAF-4620](https://jiradc.ext.net.nokia.com/browse/UTETAF-4620) and [UTS-18040](https://jiradc.ext.net.nokia.com/browse/UTS-18040). Special attention should be given to the following changes:

  - [Changes to recognizing and evaluating variables](https://github.com/robotframework/robotframework/blob/master/doc/releasenotes/rf-3.2.rst#changes-to-recognizing-and-evaluating-variables)
  - [Stricter for loop separator syntax](https://github.com/robotframework/robotframework/blob/master/doc/releasenotes/rf-3.2.rst#stricter-for-loop-separator-syntax)
  - [Old :FOR loop syntax is not supported anymore](https://github.com/robotframework/robotframework/blob/master/doc/releasenotes/rf-4.0.rst#old-for-loop-syntax-is-not-supported-anymore)
  - [Meaning of \@\{var\}\[item\] and &\{var\}\[item\] syntax has changed](https://github.com/robotframework/robotframework/blob/master/doc/releasenotes/rf-4.0.rst#meaning-of-var-item-and-var-item-syntax-has-changed)


# Verification procedure

1. Clone test repository with your files or pull the latest changes if it is already cloned.
2. Prepare a Python virtual environment (venv) and activate it
  - for **Python 2**: 
	`pip install virtualenv; virtualenv -p $(which python2) robot_venv; source robot_venv/bin/activate`
  - for **Python 3**: 
	`python3 -m venv robot_venv; source robot_venv/bin/activate`
3. Upgrade `pip`: 
	`pip install -U pip`
4. Install dependencies from a repository's `dependencies.py*.lock` matching Python version in your venv:
  - `pip install -U -r <repository_source_directory>/dependencies.py2.lock`
  or
  - `pip install -U -r <repository_source_directory>/dependencies.py3.lock`
5. Upgrade `robotframework` package: 
	`pip install -U robotframework==4.1.3`
6. Execute dryrun on a selected Robot suite or a whole directory
    `cd <repository_source_directory>`
  - in **robotws**:
	`robot --dryrun -V dummy_config.py testsuite/.../<directory_or_robot_suite>`
  - in **robotlte**:
	`robot --dryrun testsuite/.../<directory_or_robot_suite>`

7. Analyze the results and fix issues related to Robot Framework syntax.
8. If need be, prepare an MR with updated files.

> !!! Robot Framework 5.0 is only compatible with Python >= 3.6 so in steps 4. and 5. you'll have to install from `dependencies.py3.lock`, `dependencies.py39.lock` or `dependencies.py310.lock` and then run `pip install -U robotframework==5.0.1`.


## NOTES

Please note that in VMs reserved via Cloud Manager (CM), `robot` command is an alias: 

`alias robot='source /home/ute/test_repo/bin/activate; robot'`
	
so you can skip creating your own venv and just activate `test_repo`. But please check `python --version` in this venv before you proceed.

If you, however, still want to work in your own venv, you'll have to use a slightly modified `python -m robot --dryrun ...` command.


## Common issues

#TODO

# About Python resources in test repositories

**Compatible imports (non-exhaustive list):**

	from robot.api import logger
	from robot.api import TestSuiteBuilder
	from robot.errors import ExecutionFailed
	from robot.libraries.BuiltIn import BuiltIn
	from robot.libraries.BuiltIn import RobotNotRunningError
	from robot.libraries.DateTime import convert_time
	from robot.utils.robottypes import is_truthy
	from robot.utils.robottime import timestr_to_secs

**Incompatible imports (non-exhaustive list):**

    from robot.parsing.model import TestData
    from robot.parsing.model import ResourceFile


If you use these, you might be interested in 

    from robot.running.builder import TestSuiteBuilder, ResourceFileBuilder

as suggested [here](https://github.com/robotframework/robotframework/blob/master/doc/releasenotes/rf-3.2.rst#parsing-apis-have-been-rewritten).
