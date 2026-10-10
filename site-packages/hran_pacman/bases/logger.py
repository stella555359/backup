import logging


def setup_logger():
    logger = logging.getLogger("pacman")
    handler = logging.StreamHandler()
    logger.setLevel(logging.DEBUG)
    handler.setFormatter(logging.Formatter("%(asctime)s - %(levelname)s - %(message)s"))
    logger.addHandler(handler)
    return logger


LOGGER = setup_logger()
