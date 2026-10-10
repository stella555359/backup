import importlib
import sys
import pandas_gate
from robot.libraries.BuiltIn import BuiltIn


def init_pandas():
    """
    Download/install (if needed) and import pandas and set it in all modules where is needed
    Each module that requires pandas should define a variable named pd and set it to None:
        pd = None
    If is not initialized to None, this keyword will not do anything to that module.
    It is only required to call this keyword once from the main robot script at the beginning
    """
    # get and install pandas and import also numpy
    pd = pandas_gate.install_and_import_pandas()
    # since pandas has a numpy dependency the above command should install numpy
    np = importlib.import_module("numpy")
    # # plt = importlib.import_module("matplotlib")
    # plt = importlib.import_module("matplotlib.pyplot")

    # find all loaded modules/libs
    modulenames_set = list(set(sys.modules))
    for modulename in modulenames_set:
        if not modulename == "pandas_gate":
            module = importlib.import_module(modulename)
            if hasattr(module, "pd") and module.pd is None:
                module.pd = pd
                BuiltIn().log_to_console("\nPandas set in %s Library\n" % modulename)
            if hasattr(module, "np") and module.np is None:
                module.np = np
                BuiltIn().log_to_console("\nNumpy set in %s Library\n" % modulename)
            # if hasattr(module, "plt") and module.plt is None:
            #     module.plt = plt
            #     BuiltIn().log_to_console(
            #         "\nMatplotlib set in %s Library\n" % modulename
            #     )
