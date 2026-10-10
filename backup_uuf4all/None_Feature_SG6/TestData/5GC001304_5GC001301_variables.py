import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_CELL_NAME = MR_NR_BTS_NAME + '/NRCELL-301'
MR_NR_CELL2_NAME = MR_NR_BTS_NAME + '/NRCELL-302'
MR_NR_CELL3_NAME = MR_NR_BTS_NAME + '/NRCELL-303'
PDCCH_CONFIG_DEDICATED = MR_NR_BTS_NAME + '/BWP_PROFILE-43/PDCCH-1/PDCCH_CONFIG_DEDICATED-1'
PDCCH_CONFIG_COMMON = MR_NR_BTS_NAME + '/BWP_PROFILE-43/PDCCH-1/PDCCH_CONFIG_COMMON-1'

# ------------ modify parameter ------------ #
MODIFY_PARA_CHBW_40M = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='chBw',
        value='40MHz'),
    dict(
        dist_name=MR_NR_CELL2_NAME,
        parameter='chBw',
        value='40MHz'),
    dict(
        dist_name=MR_NR_CELL3_NAME,
        parameter='chBw',
        value='40MHz'),
    dict(
        dist_name=PDCCH_CONFIG_DEDICATED,
        parameter='coresetDedicated',
        value=[{'size': '96'}]),
    dict(
        dist_name=PDCCH_CONFIG_DEDICATED,
        parameter='searchSpaceDedicated',
        value=[{'numOfPdcchCandidatesInAL4': 'n2'},
               {'numOfPdcchCandidatesInAL4': 'n4'}])
]

MODIFY_PARA_CHBW_100M = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='chBw',
        value='100MHz'),
    dict(
        dist_name=MR_NR_CELL2_NAME,
        parameter='chBw',
        value='100MHz'),
    dict(
        dist_name=MR_NR_CELL3_NAME,
        parameter='chBw',
        value='100MHz'),
    dict(
        dist_name=PDCCH_CONFIG_DEDICATED,
        parameter='coresetDedicated',
        value=[{'size': '120'}]),
    dict(
        dist_name=PDCCH_CONFIG_DEDICATED,
        parameter='searchSpaceDedicated',
        value=[{'numOfPdcchCandidatesInAL4': 'n2'},
               {'numOfPdcchCandidatesInAL4': 'n5'}])
]

MODIFY_PARA_CHBW_50M = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='chBw',
        value='50MHz'),
    dict(
        dist_name=MR_NR_CELL2_NAME,
        parameter='chBw',
        value='50MHz'),
    dict(
        dist_name=MR_NR_CELL3_NAME,
        parameter='chBw',
        value='50MHz'),
    dict(
        dist_name=PDCCH_CONFIG_DEDICATED,
        parameter='coresetDedicated',
        value=[{'size': '120'}]),
    dict(
        dist_name=PDCCH_CONFIG_COMMON,
        parameter='searchSpaceCommon',
        value=[{'numOfPdcchCandidatesInAL4': 'n4'},
               {'numOfPdcchCandidatesInAL4': 'n4'},
               {'numOfPdcchCandidatesInAL4': 'n4'}]),
    dict(
        dist_name=PDCCH_CONFIG_DEDICATED,
        parameter='searchSpaceDedicated',
        value=[{'numOfPdcchCandidatesInAL4': 'n4'},
               {'numOfPdcchCandidatesInAL4': 'n5'}])
]

MODIFY_PARA_CHBW_20M = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='chBw',
        value='20MHz'),
    dict(
        dist_name=MR_NR_CELL2_NAME,
        parameter='chBw',
        value='20MHz'),
    dict(
        dist_name=MR_NR_CELL3_NAME,
        parameter='chBw',
        value='20MHz'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='type0CoresetConfigurationIndex',
        value='10'),
    dict(
        dist_name=MR_NR_CELL2_NAME,
        parameter='type0CoresetConfigurationIndex',
        value='10'),
    dict(
        dist_name=MR_NR_CELL3_NAME,
        parameter='type0CoresetConfigurationIndex',
        value='10'),
    dict(
        dist_name=PDCCH_CONFIG_DEDICATED,
        parameter='coresetDedicated',
        value=[{'size': '48'}]),
    dict(
        dist_name=PDCCH_CONFIG_COMMON,
        parameter='searchSpaceCommon',
        value=[{'numOfPdcchCandidatesInAL4': 'n4'},
               {'numOfPdcchCandidatesInAL4': 'n2'},
               {'numOfPdcchCandidatesInAL4': 'n4'}]),
    dict(
        dist_name=PDCCH_CONFIG_DEDICATED,
        parameter='searchSpaceDedicated',
        value=[{'numOfPdcchCandidatesInAL4': 'n2'},
               {'numOfPdcchCandidatesInAL4': 'n2'}])
]

MODIFY_PARA_1304_02 = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='chBw',
        value='60MHz'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='prachConfigurationIndex',
        value='158'),
    dict(
        dist_name=MR_NR_CELL2_NAME,
        parameter='chBw',
        value='60MHz'),
    dict(
        dist_name=MR_NR_CELL2_NAME,
        parameter='prachConfigurationIndex',
        value='158'),
    dict(
        dist_name=MR_NR_CELL3_NAME,
        parameter='chBw',
        value='60MHz'),
    dict(
        dist_name=MR_NR_CELL3_NAME,
        parameter='prachConfigurationIndex',
        value='158'),
    dict(
        dist_name=PDCCH_CONFIG_DEDICATED,
        parameter='coresetDedicated',
        value=[{'size': '120'}]),
    dict(
        dist_name=PDCCH_CONFIG_DEDICATED,
        parameter='searchSpaceDedicated',
        value=[{'numOfPdcchCandidatesInAL4': 'n4'},
               {'numOfPdcchCandidatesInAL4': 'n5'}])
]

MODIFY_PARA_1301_05 = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='chBw',
        value='60MHz'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='prachConfigurationIndex',
        value='206'),
    dict(
        dist_name=MR_NR_CELL2_NAME,
        parameter='chBw',
        value='60MHz'),
    dict(
        dist_name=MR_NR_CELL2_NAME,
        parameter='prachConfigurationIndex',
        value='206'),
    dict(
        dist_name=MR_NR_CELL3_NAME,
        parameter='chBw',
        value='60MHz'),
    dict(
        dist_name=MR_NR_CELL3_NAME,
        parameter='prachConfigurationIndex',
        value='206'),
    dict(
        dist_name=PDCCH_CONFIG_DEDICATED,
        parameter='coresetDedicated',
        value=[{'size': '120'}]),
    dict(
        dist_name=PDCCH_CONFIG_DEDICATED,
        parameter='searchSpaceDedicated',
        value=[{'numOfPdcchCandidatesInAL4': 'n4'},
               {'numOfPdcchCandidatesInAL4': 'n5'}])
]

MODIFY_PARA_To_trigger_sleeping_cell = [
    dict(
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/TRBLCADM-1',
        parameter='autRachBasedSlCellDetHCheckFreq',
        value='120'),
    dict(
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/TRBLCADM-1',
        parameter='autRachBasedSlCellRecPh1Timer',
        value='180'),
    dict(
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/TRBLCADM-1',
        parameter='autRachBasedSlCellRachAtmpThr',
        value='0'),
    dict(
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/TRBLCADM-1',
        parameter='autRachBasedSlCellRachMsg3Thr',
        value='5'),
    dict(
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/TRBLCADM-1',
        parameter='autRachBasedSlCellRecPhase1Act',
        value='true'),
    dict(
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/FEATCADM-1',
        parameter='actAutRachBasedSlCellDetRec',
        value='true')
]

MODIFY_PARA_To_cancel_sleeping_cell = [
    dict(
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/TRBLCADM-1',
        parameter='autRachBasedSlCellDetHCheckFreq',
        value='120'),
    dict(
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/TRBLCADM-1',
        parameter='autRachBasedSlCellRecPh1Timer',
        value='180'),
    dict(
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/TRBLCADM-1',
        parameter='autRachBasedSlCellRachAtmpThr',
        value='1000'),
    dict(
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/TRBLCADM-1',
        parameter='autRachBasedSlCellRachMsg3Thr',
        value='5'),
    dict(
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/TRBLCADM-1',
        parameter='autRachBasedSlCellRecPhase1Act',
        value='true'),
    dict(
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/FEATCADM-1',
        parameter='actAutRachBasedSlCellDetRec',
        value='true')
]

MODIFY_PARA_Activate_2197 = [
    dict(
        dist_name=MR_NR_BTS_NAME,
        parameter='tmpParam7',
        value='1')
]

MODIFY_PARA_Deactivate_2197 = [
    dict(
        dist_name=MR_NR_BTS_NAME,
        parameter='tmpParam7',
        value='0')
]
