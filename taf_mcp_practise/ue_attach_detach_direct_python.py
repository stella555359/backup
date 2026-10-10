"""Direct Python UE attach/detach practice flow.

This file is intentionally different from the Robot Framework examples:
it models the UE lifecycle in Python and calls TAF UE functions directly.

UTE TAF MCP findings used by this draft:
- Android library: taf.ue.android
- Functions: require_ue, attach_ue, detach_ue
- Android require_ue supports starting_cell
- attach_ue / detach_ue support timeout, validation, top_cmd_only
- iPhone / AT docs expose similar attach_ue / detach_ue functions, but
  starting_cell is documented as NOT SUPPORTED for those UE types

Important:
The exact import path can differ between TAF package versions. Treat the
imports below as the first thing to verify in your real TAF virtualenv.
"""

from __future__ import annotations

import argparse
import logging
from dataclasses import dataclass
from typing import Callable


LOGGER = logging.getLogger(__name__)


@dataclass(frozen=True)
class UeTypeConfig:
    """Runtime configuration for one UE type."""

    ue_type: str
    alias: str
    capability: str
    supports_starting_cell: bool


@dataclass(frozen=True)
class UeApi:
    """Python callables for one UE access library."""

    require_ue: Callable[..., None]
    attach_ue: Callable[..., None]
    detach_ue: Callable[..., None]
    log_ue_info: Callable[..., object] | None = None


DEFAULT_UE_TYPES = [
    UeTypeConfig(
        ue_type="android",
        alias="ANDROID_UE",
        capability="ANDROID_UE_1",
        supports_starting_cell=True,
    ),
    UeTypeConfig(
        ue_type="iphone",
        alias="IPHONE_UE",
        capability="IPHONE_UE_1",
        supports_starting_cell=False,
    ),
    UeTypeConfig(
        ue_type="at",
        alias="AT_UE",
        capability="AT_UE_1",
        supports_starting_cell=False,
    ),
]


def load_ue_api(ue_type: str) -> UeApi:
    """Load direct Python APIs for the selected UE type.

    The MCP documentation confirms the function names, but your installed TAF
    version decides the exact import path. Verify this function first in the
    target TAF virtualenv.
    """

    if ue_type == "android":
        from taf.ue.android import attach_ue, detach_ue, require_ue  # type: ignore

        return UeApi(require_ue=require_ue, attach_ue=attach_ue, detach_ue=detach_ue)

    if ue_type == "iphone":
        from taf.ue.iphone import attach_ue, detach_ue, require_ue  # type: ignore

        return UeApi(require_ue=require_ue, attach_ue=attach_ue, detach_ue=detach_ue)

    if ue_type == "at":
        from taf.ue.at import attach_ue, detach_ue, require_ue  # type: ignore

        return UeApi(require_ue=require_ue, attach_ue=attach_ue, detach_ue=detach_ue)

    raise ValueError(f"Unsupported UE type: {ue_type}")


def collect_failure_evidence(
    ue_type: str,
    ue_alias: str,
    phase: str,
    error: Exception,
) -> None:
    """Placeholder for project-specific UE evidence collection."""

    LOGGER.exception(
        "UE failure evidence hook: type=%s alias=%s phase=%s error=%s",
        ue_type,
        ue_alias,
        phase,
        error,
    )
    LOGGER.warning(
        "Collect recommended evidence: robot.html/config, ute_ue logs, "
        "taf.ue.proxy logs, moler logs for AT, proxy_mngr.log, Android logcat."
    )


def require_ue_for_cell(
    api: UeApi,
    config: UeTypeConfig,
    target_cell: str,
) -> None:
    """Reserve a UE and assign the alias used by attach/detach calls."""

    LOGGER.info(
        "Reserving UE: type=%s alias=%s capability=%s target_cell=%s",
        config.ue_type,
        config.alias,
        config.capability,
        target_cell,
    )

    if config.supports_starting_cell:
        api.require_ue(
            ue_alias=config.alias,
            capabilities=config.capability,
            starting_cell=target_cell,
        )
    else:
        LOGGER.warning(
            "UE type %s does not support starting_cell according to MCP docs; "
            "reserving by capability only.",
            config.ue_type,
        )
        api.require_ue(
            ue_alias=config.alias,
            capabilities=config.capability,
        )


def attach_and_detach_ue(
    api: UeApi,
    config: UeTypeConfig,
    timeout: int,
    validation: bool,
    top_cmd_only: bool,
) -> None:
    """Attach and detach one reserved UE alias."""

    try:
        LOGGER.info("Attaching UE: type=%s alias=%s", config.ue_type, config.alias)
        if config.ue_type == "android":
            api.attach_ue(
                ue_alias=config.alias,
                timeout=timeout,
                validation=validation,
                top_cmd_only=top_cmd_only,
            )
        else:
            api.attach_ue(
                ue_alias=config.alias,
                validation=validation,
            )
        LOGGER.info("Attach succeeded: type=%s alias=%s", config.ue_type, config.alias)
    except Exception as error:
        collect_failure_evidence(config.ue_type, config.alias, "attach", error)
        raise

    try:
        LOGGER.info("Detaching UE: type=%s alias=%s", config.ue_type, config.alias)
        if config.ue_type == "android":
            api.detach_ue(
                ue_alias=config.alias,
                timeout=timeout,
                validation=validation,
                top_cmd_only=top_cmd_only,
            )
        else:
            api.detach_ue(
                ue_alias=config.alias,
                validation=validation,
            )
        LOGGER.info("Detach succeeded: type=%s alias=%s", config.ue_type, config.alias)
    except Exception as error:
        collect_failure_evidence(config.ue_type, config.alias, "detach", error)
        raise


def run_attach_detach_flow(
    target_cell: str,
    ue_types: list[UeTypeConfig],
    timeout: int,
    validation: bool,
    top_cmd_only: bool,
) -> None:
    """Run attach/detach flow for each configured UE type."""

    for config in ue_types:
        LOGGER.info("Starting UE flow for type=%s", config.ue_type)
        api = load_ue_api(config.ue_type)
        try:
            require_ue_for_cell(api=api, config=config, target_cell=target_cell)
            attach_and_detach_ue(
                api=api,
                config=config,
                timeout=timeout,
                validation=validation,
                top_cmd_only=top_cmd_only,
            )
        except Exception:
            LOGGER.exception("UE flow failed for type=%s alias=%s", config.ue_type, config.alias)
            raise


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Direct Python UE attach/detach practice flow."
    )
    parser.add_argument(
        "--target-cell",
        required=True,
        help="Cell alias or E-UTRAN cell identifier for Android starting_cell.",
    )
    parser.add_argument(
        "--ue-types",
        default="android,iphone,at",
        help="Comma-separated UE types to run. Supported by this draft: android,iphone,at.",
    )
    parser.add_argument("--timeout", type=int, default=60)
    parser.add_argument("--no-validation", action="store_true")
    parser.add_argument("--top-cmd-only", action="store_true")
    return parser.parse_args()


def select_ue_types(names: list[str]) -> list[UeTypeConfig]:
    configs_by_name = {config.ue_type: config for config in DEFAULT_UE_TYPES}
    selected: list[UeTypeConfig] = []
    for name in names:
        normalized = name.strip().lower()
        if not normalized:
            continue
        try:
            selected.append(configs_by_name[normalized])
        except KeyError as error:
            raise ValueError(f"Unsupported UE type requested: {name}") from error
    return selected


def main() -> None:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(name)s - %(message)s",
    )
    args = parse_args()
    selected_ue_types = select_ue_types(args.ue_types.split(","))
    run_attach_detach_flow(
        target_cell=args.target_cell,
        ue_types=selected_ue_types,
        timeout=args.timeout,
        validation=not args.no_validation,
        top_cmd_only=args.top_cmd_only,
    )


if __name__ == "__main__":
    main()
