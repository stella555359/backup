"""Direct Python SBTS cell handover by PA/attenuation control.

Goal:
Trigger UE handover from a source SBTS cell to a target SBTS cell by changing
source/target PA attenuation values, while collecting gNB Wireshark/pcap data.

UTE TAF MCP evidence used by this draft:
- taf.hw.rf_attenuator
  - setup_attenuator
  - set_linear_fading_scenario
  - set_ports_fading_attenuation
  - JFW supports linear fading scenarios
- taf.hw.azimuth.channel_emulator.api
  - DirectedLink.set_link_atten
- taf.collectors.ip_traffic_capturing
  - create_vcu_ip_traffic_capturing_file_collector
- taf.collectors.core
  - setup_collectors / start_collectors / stop_collectors / collect_collectors
    / teardown_collectors
- taf.gnb.oam.coam.cu
  - start_ip_traffic_capture / stop_ip_traffic_capture

Important:
The MCP server confirms function names and parameters, but exact Python import
paths can differ between TAF package versions. Verify imports in the target TAF
virtualenv before using this script on a real testline.
"""

from __future__ import annotations

import argparse
import logging
import time
from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import Any, Literal


LOGGER = logging.getLogger(__name__)

PaType = Literal["jfw_rf_attenuator", "generic_rf_attenuator", "azimuth_channel_emulator"]


@dataclass(frozen=True)
class CellPaConfig:
    """PA/attenuator mapping for one logical cell path."""

    cell_name: str
    pa_type: PaType
    alias: str
    ports: list[int]
    # Generic setup fields for taf.hw.rf_attenuator. If your testline already
    # provides attenuator objects, use testline_object_ref instead.
    vendor: str | None = None
    model: str | None = None
    ip_addr: str | None = None
    management_port: int | None = None
    min_attenuation: int = 0
    max_attenuation: int = 95
    testline_object_ref: str | None = None
    # Azimuth-specific fields.
    azimuth_link_name: str | None = None
    azimuth_direction: str | None = None


@dataclass(frozen=True)
class HandoverProfile:
    """Attenuation profile used to force source -> target handover."""

    source_start_db: int = 10
    source_end_db: int = 80
    target_start_db: int = 80
    target_end_db: int = 10
    ramp_interval_seconds: int = 10
    settle_seconds_after_ramp: int = 20


@dataclass(frozen=True)
class GnbCaptureConfig:
    """gNB Wireshark/pcap capture configuration."""

    mode: Literal["collector_vcu", "cu_api", "dry_run"] = "collector_vcu"
    host: str = "CU_OR_VCU_OAM_HOST"
    username: str = "Nemuadmin"
    password: str = "CHANGE_ME"
    port: str = "443"
    secure: bool = True
    cu_version: str | None = None
    measurement_point: str = "NE_Terminated"
    capture_type: str = "plane"
    plane_types: list[str] | None = None
    pod_names: list[str] | None = None
    collector_name: str = "vcu_ip_traffic_capturing"
    timeout: int = 120


class GnbCaptureSession:
    """Start/stop/collect gNB Wireshark data around the handover window."""

    def __init__(self, config: GnbCaptureConfig, dry_run: bool = False) -> None:
        self.config = config
        self.dry_run = dry_run
        self._cu_connection: Any | None = None

    def __enter__(self) -> "GnbCaptureSession":
        self.start()
        return self

    def __exit__(self, exc_type: object, exc: object, tb: object) -> None:
        self.stop_and_collect()

    def start(self) -> None:
        if self.dry_run or self.config.mode == "dry_run":
            LOGGER.info("[dry-run] Would start gNB capture: %s", self.config)
            return

        if self.config.mode == "collector_vcu":
            self._start_with_collector_vcu()
            return

        if self.config.mode == "cu_api":
            self._start_with_cu_api()
            return

        raise ValueError(f"Unsupported capture mode: {self.config.mode}")

    def stop_and_collect(self) -> None:
        if self.dry_run or self.config.mode == "dry_run":
            LOGGER.info("[dry-run] Would stop and collect gNB capture")
            return

        if self.config.mode == "collector_vcu":
            self._stop_collect_teardown_collectors()
            return

        if self.config.mode == "cu_api":
            self._stop_with_cu_api()
            return

        raise ValueError(f"Unsupported capture mode: {self.config.mode}")

    def _start_with_collector_vcu(self) -> None:
        """Use taf.collectors.ip_traffic_capturing to collect pcap files."""

        from taf.collectors import core  # type: ignore
        from taf.collectors import ip_traffic_capturing  # type: ignore

        webservice = {
            "host": self.config.host,
            "user": self.config.username,
            "password": self.config.password,
        }
        if self.config.cu_version:
            webservice["release"] = self.config.cu_version

        ip_traffic_capturing.create_vcu_ip_traffic_capturing_file_collector(
            name=self.config.collector_name,
            webservice=webservice,
            measurement_point=self.config.measurement_point,
            capture_type=self.config.capture_type,
            plane_types=self.config.plane_types,
            pod_names=self.config.pod_names,
            timeout=self.config.timeout,
        )
        core.setup_collectors(names=self.config.collector_name)
        core.start_collectors(names=self.config.collector_name)
        LOGGER.info("Started VCU IP traffic capturing collector: %s", self.config.collector_name)

    def _stop_collect_teardown_collectors(self) -> None:
        from taf.collectors import core  # type: ignore

        LOGGER.info("Stopping VCU IP traffic capturing collector: %s", self.config.collector_name)
        core.stop_collectors(names=self.config.collector_name)
        core.collect_collectors(names=self.config.collector_name)
        core.teardown_collectors(names=self.config.collector_name)

    def _start_with_cu_api(self) -> None:
        """Use CU ADMIN API start/stop capture methods directly."""

        from taf.gnb.oam.coam import cu  # type: ignore

        self._cu_connection = cu.connect_to(
            host=self.config.host,
            port=self.config.port,
            username=self.config.username,
            password=self.config.password,
            cu_version=self.config.cu_version,
            secure=self.config.secure,
            alias="handover_cu_capture",
            timeout=self.config.timeout,
        )
        cu.start_ip_traffic_capture(
            capture_type=self.config.capture_type,
            measurement_point=self.config.measurement_point,
            plane_type=self.config.plane_types,
            pod_names=self.config.pod_names,
            timeout=self.config.timeout,
            connection=self._cu_connection,
        )
        LOGGER.info("Started CU API IP traffic capture")

    def _stop_with_cu_api(self) -> None:
        from taf.gnb.oam.coam import cu  # type: ignore

        LOGGER.info("Stopping CU API IP traffic capture")
        cu.stop_ip_traffic_capture(
            timeout=self.config.timeout,
            connection=self._cu_connection,
        )


class PaController(ABC):
    """Abstract attenuation controller for one source/target cell path."""

    def __init__(self, config: CellPaConfig, dry_run: bool = False) -> None:
        self.config = config
        self.dry_run = dry_run

    @abstractmethod
    def setup(self) -> None:
        """Prepare connection to the PA/attenuator."""

    @abstractmethod
    def set_static_attenuation(self, value_db: int) -> None:
        """Set all configured ports to a static attenuation value."""

    @abstractmethod
    def fade_attenuation(self, start_db: int, end_db: int, interval_seconds: int) -> None:
        """Ramp attenuation from start_db to end_db."""

    def teardown(self) -> None:
        """Close connection if the implementation supports it."""


class RfAttenuatorController(PaController):
    """Controller for taf.hw.rf_attenuator based PA devices."""

    def __init__(self, config: CellPaConfig, dry_run: bool = False) -> None:
        super().__init__(config=config, dry_run=dry_run)
        self._attenuator_device: Any | None = None
        self._att_module: Any | None = None

    def setup(self) -> None:
        if self.dry_run:
            LOGGER.info("[dry-run] Would setup rf attenuator: %s", self.config)
            return

        from taf.hw import rf_attenuator as att  # type: ignore

        self._att_module = att
        if self.config.testline_object_ref:
            # In a real testline you may resolve this from taf.config.testline,
            # for example tl.attenuators[0]. This script keeps the reference as
            # documentation because testline loading differs per environment.
            raise NotImplementedError(
                "Resolve testline_object_ref to a real attenuator object in your environment."
            )

        self._attenuator_device = att.setup_attenuator(
            alias=self.config.alias,
            ip_addr=self.config.ip_addr,
            port=self.config.management_port,
            attenuation_port_numbers=self.config.ports,
            min_attenuation=self.config.min_attenuation,
            max_attenuation=self.config.max_attenuation,
            vendor=self.config.vendor,
            model=self.config.model,
        )
        LOGGER.info("Configured rf attenuator: %s", self.config.alias)

    def set_static_attenuation(self, value_db: int) -> None:
        if self.dry_run:
            LOGGER.info(
                "[dry-run] Would set %s ports %s to %s dB",
                self.config.alias,
                self.config.ports,
                value_db,
            )
            return

        assert self._att_module is not None
        # MCP examples show both set_attenuation for one port and
        # set_ports_attenuation for all ports. Use set_ports when available.
        values = [value_db] * len(self.config.ports)
        self._att_module.set_ports_attenuation(
            ports=self.config.ports,
            values=values,
            attenuator_device=self._attenuator_device,
        )

    def fade_attenuation(self, start_db: int, end_db: int, interval_seconds: int) -> None:
        if self.dry_run:
            LOGGER.info(
                "[dry-run] Would fade %s ports %s from %s dB to %s dB in %ss",
                self.config.alias,
                self.config.ports,
                start_db,
                end_db,
                interval_seconds,
            )
            return

        assert self._att_module is not None
        scenarios = [
            self._att_module.set_linear_fading_scenario(
                port=port,
                start_value=start_db,
                end_value=end_db,
                interval=interval_seconds,
                unit="S",
                attenuator_device=self._attenuator_device,
            )
            for port in self.config.ports
        ]
        self._att_module.set_ports_fading_attenuation(
            set_fading_scenarios=scenarios,
            attenuator_device=self._attenuator_device,
            timeout=interval_seconds + 30,
        )

    def teardown(self) -> None:
        if self.dry_run:
            LOGGER.info("[dry-run] Would disconnect rf attenuator: %s", self.config.alias)
            return
        if self._att_module is not None:
            self._att_module.disconnect(attenuator_device=self._attenuator_device)


class AzimuthChannelEmulatorController(PaController):
    """Controller for taf.hw.azimuth.channel_emulator.api links."""

    def __init__(self, config: CellPaConfig, dry_run: bool = False) -> None:
        super().__init__(config=config, dry_run=dry_run)
        self._directed_link: Any | None = None

    def setup(self) -> None:
        if self.dry_run:
            LOGGER.info("[dry-run] Would setup Azimuth directed link: %s", self.config)
            return

        raise NotImplementedError(
            "Create/load DirectedLink for your Azimuth channel emulator, then assign "
            "it to self._directed_link. MCP confirms DirectedLink.set_link_atten(vallist)."
        )

    def set_static_attenuation(self, value_db: int) -> None:
        if self.dry_run:
            LOGGER.info("[dry-run] Would set Azimuth link %s to %s dB", self.config.alias, value_db)
            return
        assert self._directed_link is not None
        self._directed_link.set_link_atten([value_db])

    def fade_attenuation(self, start_db: int, end_db: int, interval_seconds: int) -> None:
        step = 1 if end_db >= start_db else -1
        values = range(start_db, end_db + step, step)
        sleep_per_step = max(interval_seconds / max(abs(end_db - start_db), 1), 0.1)
        for value in values:
            self.set_static_attenuation(value)
            time.sleep(sleep_per_step)


def create_pa_controller(config: CellPaConfig, dry_run: bool) -> PaController:
    if config.pa_type in {"jfw_rf_attenuator", "generic_rf_attenuator"}:
        return RfAttenuatorController(config=config, dry_run=dry_run)
    if config.pa_type == "azimuth_channel_emulator":
        return AzimuthChannelEmulatorController(config=config, dry_run=dry_run)
    raise ValueError(f"Unsupported PA type: {config.pa_type}")


def perform_handover_by_pa(
    source_pa: PaController,
    target_pa: PaController,
    profile: HandoverProfile,
) -> None:
    """Make source weaker and target stronger to trigger source -> target handover."""

    LOGGER.info("Setting initial PA attenuation values")
    source_pa.set_static_attenuation(profile.source_start_db)
    target_pa.set_static_attenuation(profile.target_start_db)

    LOGGER.info("Starting PA ramp to trigger handover")
    source_pa.fade_attenuation(
        start_db=profile.source_start_db,
        end_db=profile.source_end_db,
        interval_seconds=profile.ramp_interval_seconds,
    )
    target_pa.fade_attenuation(
        start_db=profile.target_start_db,
        end_db=profile.target_end_db,
        interval_seconds=profile.ramp_interval_seconds,
    )

    LOGGER.info("Waiting %s seconds after PA ramp", profile.settle_seconds_after_ramp)
    time.sleep(profile.settle_seconds_after_ramp)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Trigger SBTS cell handover by PA attenuation and capture gNB pcap."
    )
    parser.add_argument("--dry-run", action="store_true", help="Log actions without calling TAF APIs.")
    parser.add_argument("--source-cell", default="SOURCE_CELL")
    parser.add_argument("--target-cell", default="TARGET_CELL")
    parser.add_argument("--source-pa-type", default="jfw_rf_attenuator", choices=[
        "jfw_rf_attenuator",
        "generic_rf_attenuator",
        "azimuth_channel_emulator",
    ])
    parser.add_argument("--target-pa-type", default="jfw_rf_attenuator", choices=[
        "jfw_rf_attenuator",
        "generic_rf_attenuator",
        "azimuth_channel_emulator",
    ])
    parser.add_argument("--source-pa-ip", default=None)
    parser.add_argument("--target-pa-ip", default=None)
    parser.add_argument("--source-pa-ports", default="1,2")
    parser.add_argument("--target-pa-ports", default="3,4")
    parser.add_argument("--source-start-db", type=int, default=10)
    parser.add_argument("--source-end-db", type=int, default=80)
    parser.add_argument("--target-start-db", type=int, default=80)
    parser.add_argument("--target-end-db", type=int, default=10)
    parser.add_argument("--ramp-interval-seconds", type=int, default=10)
    parser.add_argument("--settle-seconds", type=int, default=20)
    parser.add_argument("--capture-mode", default="collector_vcu", choices=["collector_vcu", "cu_api", "dry_run"])
    parser.add_argument("--cu-host", default="CU_OR_VCU_OAM_HOST")
    parser.add_argument("--cu-user", default="Nemuadmin")
    parser.add_argument("--cu-password", default="CHANGE_ME")
    parser.add_argument("--plane-types", default="cplane,uplane")
    return parser.parse_args()


def parse_ports(value: str) -> list[int]:
    return [int(item.strip()) for item in value.split(",") if item.strip()]


def parse_plane_types(value: str) -> list[str]:
    return [item.strip() for item in value.split(",") if item.strip()]


def main() -> None:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(name)s - %(message)s",
    )
    args = parse_args()

    source_config = CellPaConfig(
        cell_name=args.source_cell,
        pa_type=args.source_pa_type,
        alias="source_pa",
        ports=parse_ports(args.source_pa_ports),
        vendor="JFW" if args.source_pa_type == "jfw_rf_attenuator" else None,
        model="50P-0033" if args.source_pa_type == "jfw_rf_attenuator" else None,
        ip_addr=args.source_pa_ip,
        management_port=30000 if args.source_pa_ip else None,
    )
    target_config = CellPaConfig(
        cell_name=args.target_cell,
        pa_type=args.target_pa_type,
        alias="target_pa",
        ports=parse_ports(args.target_pa_ports),
        vendor="JFW" if args.target_pa_type == "jfw_rf_attenuator" else None,
        model="50P-0033" if args.target_pa_type == "jfw_rf_attenuator" else None,
        ip_addr=args.target_pa_ip,
        management_port=30000 if args.target_pa_ip else None,
    )
    profile = HandoverProfile(
        source_start_db=args.source_start_db,
        source_end_db=args.source_end_db,
        target_start_db=args.target_start_db,
        target_end_db=args.target_end_db,
        ramp_interval_seconds=args.ramp_interval_seconds,
        settle_seconds_after_ramp=args.settle_seconds,
    )
    capture_config = GnbCaptureConfig(
        mode="dry_run" if args.dry_run else args.capture_mode,
        host=args.cu_host,
        username=args.cu_user,
        password=args.cu_password,
        capture_type="plane",
        plane_types=parse_plane_types(args.plane_types),
    )

    source_pa = create_pa_controller(source_config, dry_run=args.dry_run)
    target_pa = create_pa_controller(target_config, dry_run=args.dry_run)

    try:
        source_pa.setup()
        target_pa.setup()
        with GnbCaptureSession(capture_config, dry_run=args.dry_run):
            perform_handover_by_pa(
                source_pa=source_pa,
                target_pa=target_pa,
                profile=profile,
            )
    finally:
        source_pa.teardown()
        target_pa.teardown()


if __name__ == "__main__":
    main()
