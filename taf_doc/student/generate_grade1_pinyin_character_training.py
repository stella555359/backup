from __future__ import annotations

import asyncio
import json
import re
from pathlib import Path
from typing import Any

import fitz
from playwright.async_api import async_playwright

import generate_grade1_papers as base


ROOT = Path(__file__).resolve().parent
TRAINING_PDF = ROOT / "一年级拼音认字14天训练册.pdf"
CHECK_PDFS = {
    1: ROOT / "一年级拼音认字阶段检测_第1次.pdf",
    2: ROOT / "一年级拼音认字阶段检测_第2次.pdf",
}
ANSWER_PDF = ROOT / "一年级拼音认字训练_答案与家长指导.pdf"

PINYIN_RE = re.compile(r"^[a-zāáǎàēéěèīíǐìōóǒòūúǔùǖǘǚǜü]+$")


def char_entry(
    char: str,
    pinyin: str,
    wrong: str,
    word: str,
    *,
    icon: str | None = None,
) -> dict[str, str | None]:
    return {
        "char": char,
        "pinyin": pinyin,
        "wrong": wrong,
        "word": word,
        "icon": icon,
    }


CHARACTER_GROUPS: list[list[dict[str, str | None]]] = [
    [
        char_entry("五", "wǔ", "wú", "五个"),
        char_entry("鱼", "yú", "yǔ", "小鱼", icon="fish"),
        char_entry("雨", "yǔ", "yú", "下雨", icon="rain"),
        char_entry("月", "yuè", "yè", "月儿", icon="moon"),
        char_entry("云", "yún", "yùn", "白云", icon="cloud"),
        char_entry("我", "wǒ", "wó", "我们"),
    ],
    [
        char_entry("八", "bā", "pā", "八个"),
        char_entry("白", "bái", "pái", "白云"),
        char_entry("朋", "péng", "pén", "朋友"),
        char_entry("妈", "mā", "mǎ", "妈妈"),
        char_entry("米", "mǐ", "mī", "大米", icon="rice"),
        char_entry("风", "fēng", "fēn", "大风", icon="wind"),
    ],
    [
        char_entry("大", "dà", "tà", "大山"),
        char_entry("天", "tiān", "diān", "天上", icon="sky"),
        char_entry("土", "tǔ", "tù", "土地"),
        char_entry("你", "nǐ", "lǐ", "你们"),
        char_entry("牛", "niú", "liú", "小牛", icon="cow"),
        char_entry("立", "lì", "nì", "立正"),
    ],
    [
        char_entry("个", "gè", "kè", "一个"),
        char_entry("口", "kǒu", "gǒu", "门口", icon="mouth"),
        char_entry("开", "kāi", "gāi", "开门"),
        char_entry("火", "huǒ", "huó", "大火", icon="fire"),
        char_entry("河", "hé", "hē", "小河", icon="river"),
        char_entry("花", "huā", "fā", "花朵", icon="flower"),
    ],
    [
        char_entry("家", "jiā", "qiā", "回家", icon="home"),
        char_entry("九", "jiǔ", "jiū", "九个"),
        char_entry("七", "qī", "qí", "七个"),
        char_entry("去", "qù", "qǔ", "回去"),
        char_entry("小", "xiǎo", "qiǎo", "小鸟"),
        char_entry("下", "xià", "xiǎ", "下山", icon="down"),
    ],
    [
        char_entry("早", "zǎo", "zhǎo", "早上", icon="morning"),
        char_entry("草", "cǎo", "chǎo", "小草", icon="grass"),
        char_entry("三", "sān", "shān", "三个"),
        char_entry("四", "sì", "shì", "四本"),
        char_entry("子", "zǐ", "zhǐ", "儿子"),
        char_entry("在", "zài", "zhài", "正在"),
    ],
    [
        char_entry("中", "zhōng", "zōng", "中心"),
        char_entry("虫", "chóng", "cóng", "小虫", icon="bug"),
        char_entry("书", "shū", "sū", "书本", icon="book"),
        char_entry("手", "shǒu", "sǒu", "小手", icon="hand"),
        char_entry("人", "rén", "lén", "大人"),
        char_entry("日", "rì", "yì", "日月", icon="sun"),
    ],
]

CHAR_MAP = {
    entry["char"]: entry
    for group in CHARACTER_GROUPS
    for entry in group
}

DAY_FOCUS = [
    {"title": "整体认读音节与四声", "chars": "鱼雨月云五我", "support": 80},
    {"title": "b、p、m、f拼读", "chars": "八白朋妈米风", "support": 80},
    {"title": "d、t、n、l拼读", "chars": "大天土你牛立", "support": 80},
    {"title": "g、k、h拼读", "chars": "个口开火河花", "support": 60},
    {"title": "j、q、x拼读", "chars": "家九七去小下", "support": 60},
    {"title": "z、c、s平舌音", "chars": "早草三四子在", "support": 60},
    {"title": "zh、ch、sh、r翘舌音", "chars": "中虫书手人日", "support": 60},
    {"title": "平舌音和翘舌音对比", "chars": "早中草虫三书", "support": 40},
    {"title": "前鼻音和后鼻音对比", "chars": "云人天风朋中", "support": 40},
    {"title": "n、l与j、q、x辨音", "chars": "你牛立家七小", "support": 40},
    {"title": "在词语中认字", "chars": "个口开火河花", "support": 20},
    {"title": "在句子中认字", "chars": "家九七去小下", "support": 20},
    {"title": "部分注音短文认读", "chars": "早草三四子在", "support": 20},
    {"title": "脱离拼音综合复认", "chars": "中虫书手人日", "support": 20},
]

REVIEW_GROUPS_BY_DAY = {
    1: [],
    2: [1],
    3: [2],
    4: [3, 1],
    5: [4, 2],
    6: [5, 3],
    7: [6, 4],
    8: [7, 5, 1],
    9: [6, 2],
    10: [7, 3],
    11: [4, 1],
    12: [5, 2],
    13: [6, 3],
    14: [7, 4],
}

EXPECTED_REPETITIONS = {
    1: [2, 4, 8],
    2: [3, 5, 9],
    3: [4, 6, 10],
    4: [5, 7, 11],
    5: [6, 8, 12],
    6: [7, 9, 13],
    7: [8, 10, 14],
}

CONTEXT_ITEMS = [
    [
        {"text": "天上有白（　）。", "options": ["云", "月"], "answer": "云", "clue": "yún"},
        {"text": "池塘里有小（　）。", "options": ["鱼", "雨"], "answer": "鱼", "clue": "yú"},
    ],
    [
        {"text": "（　）妈在做饭。", "options": ["妈", "米"], "answer": "妈", "clue": "mā"},
        {"text": "今天刮大（　）。", "options": ["风", "朋"], "answer": "风", "clue": "fēng"},
    ],
    [
        {"text": "（　）上有白云。", "options": ["天", "土"], "answer": "天", "clue": "tiān"},
        {"text": "地里有小（　）。", "options": ["牛", "你"], "answer": "牛", "clue": "niú"},
    ],
    [
        {"text": "小（　）边开着花。", "options": ["河", "火"], "answer": "河", "clue": "hé"},
        {"text": "请把门（　）。", "options": ["开", "花"], "answer": "开", "clue": "kāi"},
    ],
    [
        {"text": "我回（　）了。", "options": ["家", "七"], "answer": "家", "clue": "jiā"},
        {"text": "小鸟飞（　）来了。", "options": ["下", "去"], "answer": "下", "clue": "xià"},
    ],
    [
        {"text": "我（　）学校里读书。", "options": ["在", "子"], "answer": "在", "clue": "zài"},
        {"text": "（　）上好！", "options": ["早", "草"], "answer": "早", "clue": "zǎo"},
    ],
    [
        {"text": "我爱看（　）。", "options": ["书", "手"], "answer": "书", "clue": "shū"},
        {"text": "田里有小（　）。", "options": ["虫", "中"], "answer": "虫", "clue": "chóng"},
    ],
    [
        {"text": "（　）国", "options": ["中", "虫"], "answer": "中", "clue": "zhōng"},
        {"text": "小（　）", "options": ["虫", "中"], "answer": "虫", "clue": "chóng"},
    ],
    [
        {"text": "大（　）吹来，树叶动了。", "options": ["风", "朋"], "answer": "风", "clue": "fēng"},
        {"text": "天上有白（　）。", "options": ["云", "人"], "answer": "云", "clue": "yún"},
    ],
    [
        {"text": "（　）们一起读书。", "options": ["你", "立"], "answer": "你", "clue": "nǐ"},
        {"text": "桌上有（　）本书。", "options": ["七", "家"], "answer": "七", "clue": "qī"},
    ],
    [
        {"text": "门（　）站着一个人。", "options": ["口", "河"], "answer": "口", "clue": ""},
        {"text": "请（　）门。", "options": ["开", "花"], "answer": "开", "clue": ""},
    ],
    [
        {"text": "放学后，我回（　）。", "options": ["家", "九"], "answer": "家", "clue": ""},
        {"text": "小鸟从天上飞（　）来。", "options": ["下", "小"], "answer": "下", "clue": ""},
    ],
    [
        {"text": "（　）上，小草上有水珠。", "options": ["早", "草"], "answer": "早", "clue": ""},
        {"text": "小明（　）认真读书。", "options": ["在", "子"], "answer": "在", "clue": ""},
    ],
    [
        {"text": "小（　）在叶子上。", "options": ["虫", "中"], "answer": "虫", "clue": ""},
        {"text": "我用小（　）翻书。", "options": ["手", "书"], "answer": "手", "clue": ""},
    ],
]

PICTURE_ITEMS = [
    [
        {"icon": "fish", "options": ["鱼", "雨"], "answer": "鱼"},
        {"icon": "moon", "options": ["月", "云"], "answer": "月"},
    ],
    [
        {"icon": "rice", "options": ["米", "妈"], "answer": "米"},
        {"icon": "wind", "options": ["风", "朋"], "answer": "风"},
    ],
    [
        {"icon": "cow", "options": ["牛", "你"], "answer": "牛"},
        {"icon": "sky", "options": ["天", "土"], "answer": "天"},
    ],
    [
        {"icon": "fire", "options": ["火", "河"], "answer": "火"},
        {"icon": "flower", "options": ["花", "开"], "answer": "花"},
    ],
    [
        {"icon": "home", "options": ["家", "九"], "answer": "家"},
        {"icon": "down", "options": ["下", "小"], "answer": "下"},
    ],
    [
        {"icon": "grass", "options": ["草", "早"], "answer": "草"},
        {"icon": "morning", "options": ["早", "在"], "answer": "早"},
    ],
    [
        {"icon": "bug", "options": ["虫", "中"], "answer": "虫"},
        {"icon": "book", "options": ["书", "手"], "answer": "书"},
    ],
    [
        {"icon": "grass", "options": ["草", "虫"], "answer": "草"},
        {"icon": "bug", "options": ["虫", "中"], "answer": "虫"},
    ],
    [
        {"icon": "wind", "options": ["风", "朋"], "answer": "风"},
        {"icon": "cloud", "options": ["云", "人"], "answer": "云"},
    ],
    [
        {"icon": "cow", "options": ["牛", "立"], "answer": "牛"},
        {"icon": "home", "options": ["家", "七"], "answer": "家"},
    ],
    [
        {"icon": "mouth", "options": ["口", "河"], "answer": "口"},
        {"icon": "river", "options": ["河", "火"], "answer": "河"},
    ],
    [
        {"icon": "home", "options": ["家", "下"], "answer": "家"},
        {"icon": "down", "options": ["下", "小"], "answer": "下"},
    ],
    [
        {"icon": "grass", "options": ["草", "早"], "answer": "草"},
        {"icon": "morning", "options": ["早", "在"], "answer": "早"},
    ],
    [
        {"icon": "hand", "options": ["手", "书"], "answer": "手"},
        {"icon": "book", "options": ["书", "日"], "answer": "书"},
    ],
]

READINGS = {
    11: {
        "segments": [
            ("门口", "mén kǒu"),
            ("的小河边，开着红花。大人和小朋友一起看花。", None),
        ],
        "question": "谁和小朋友一起看花？",
        "answer": "大人。",
    },
    12: {
        "segments": [
            ("我和小伙伴回家去。路上，我们看见小鸟从", None),
            ("天上", "tiān shàng"),
            ("飞下来。", None),
        ],
        "question": "小鸟从哪里飞下来？",
        "answer": "天上。",
    },
    13: {
        "segments": [
            ("早上，小草上有水珠。", None),
            ("太阳", "tài yáng"),
            ("出来了，水珠亮亮的。", None),
        ],
        "question": "水珠什么时候亮亮的？",
        "answer": "太阳出来后。",
    },
    14: {
        "segments": [
            ("中午，我在家里看书。小虫飞到书本上，我用小手轻轻赶走它。", None),
        ],
        "question": "小虫飞到了哪里？",
        "answer": "书本上。",
    },
}

ORAL_TASKS = [
    "读一读：小鱼、下雨、白云、月儿。读完后盖住拼音再读一次。",
    "读一读：八个、白云、朋友、妈妈、大米、大风。",
    "读一读：大山、天上、土地、你们、小牛、立正。",
    "读一读：一个、门口、开门、大火、小河、花朵。",
    "读一读：回家、九个、七个、回去、小鸟、下山。",
    "把“早、草、三、四、子、在”读给家长听，注意舌头不要翘起来。",
    "把“中、虫、书、手、人、日”读给家长听，注意翘舌音。",
    "交替读：早—中、草—虫、三—书。读慢一点，分清平舌和翘舌。",
    "读一读：白云、大风、朋友、天上、中心，听清最后的鼻音。",
    "读一读：你们、小牛、立正、回家、七个、小鸟。",
    "先读词，再说一句话：门口、开门、小河、花朵。",
    "用“回家、小鸟、下山”中的两个词说一句完整的话。",
    "把今天的小短文读两遍，第二遍尽量不看注音。",
    "盖住本页所有拼音，把会认的字和短文读给家长听。",
]


def rotate(values: list[Any], offset: int) -> list[Any]:
    if not values:
        return []
    offset %= len(values)
    return values[offset:] + values[:offset]


def build_daily_lessons() -> list[dict[str, Any]]:
    lessons: list[dict[str, Any]] = []
    for day, meta in enumerate(DAY_FOCUS, start=1):
        focus_entries = [CHAR_MAP[char] for char in meta["chars"]]
        choices = []
        for index, entry in enumerate(focus_entries):
            options = [entry["pinyin"], entry["wrong"]]
            if (day + index) % 2:
                options.reverse()
            choices.append(
                {
                    "char": entry["char"],
                    "options": options,
                    "answer": entry["pinyin"],
                    "diagnosis": "声母、韵母或声调辨认",
                }
            )

        match_entries = focus_entries[:4]
        match_chars = rotate(
            [entry["char"] for entry in match_entries],
            1 + day % 3,
        )
        review_entries = [
            entry
            for group_number in REVIEW_GROUPS_BY_DAY[day]
            for entry in CHARACTER_GROUPS[group_number - 1]
        ]
        lessons.append(
            {
                "day": day,
                "title": meta["title"],
                "support": meta["support"],
                "focus_entries": focus_entries,
                "choices": choices,
                "match": {
                    "pinyins": [entry["pinyin"] for entry in match_entries],
                    "chars": match_chars,
                    "answers": {
                        entry["pinyin"]: entry["char"]
                        for entry in match_entries
                    },
                },
                "pictures": PICTURE_ITEMS[day - 1],
                "contexts": CONTEXT_ITEMS[day - 1],
                "review_groups": REVIEW_GROUPS_BY_DAY[day],
                "review_entries": review_entries,
                "reading": READINGS.get(day),
                "oral": ORAL_TASKS[day - 1],
            }
        )
    return lessons


def validate_curriculum(lessons: list[dict[str, Any]]) -> None:
    if len(lessons) != 14:
        raise ValueError("训练周期应为14天。")

    all_entries = [entry for group in CHARACTER_GROUPS for entry in group]
    all_chars = [entry["char"] for entry in all_entries]
    if len(all_chars) != 42 or len(set(all_chars)) != 42:
        raise ValueError("应有42个不重复的核心认读字。")

    for entry in all_entries:
        for field in ("pinyin", "wrong"):
            value = str(entry[field])
            if not PINYIN_RE.fullmatch(value):
                raise ValueError(f'拼音格式不正确：{entry["char"]} {field}={value}')
        if entry["pinyin"] == entry["wrong"]:
            raise ValueError(f'正确读音与干扰项相同：{entry["char"]}')

    for group_number, expected_days in EXPECTED_REPETITIONS.items():
        actual_days = [
            day
            for day, groups in REVIEW_GROUPS_BY_DAY.items()
            if group_number in groups
        ]
        if actual_days[:3] != expected_days:
            raise ValueError(
                f"第{group_number}组复现日错误：{actual_days}，期望{expected_days}"
            )

    for lesson in lessons:
        if len(lesson["choices"]) != 6:
            raise ValueError(f'第{lesson["day"]}天拼音选择题数量不正确。')
        if len(lesson["contexts"]) != 2 or len(lesson["pictures"]) != 2:
            raise ValueError(f'第{lesson["day"]}天语境题或看图题数量不正确。')
        for item in lesson["contexts"]:
            if item["answer"] not in item["options"]:
                raise ValueError(f'语境题答案不在选项中：{item["text"]}')
        for item in lesson["pictures"]:
            if item["answer"] not in item["options"]:
                raise ValueError(f'看图题答案不在选项中：{item}')

    if [lesson["support"] for lesson in lessons] != [
        80,
        80,
        80,
        60,
        60,
        60,
        60,
        40,
        40,
        40,
        20,
        20,
        20,
        20,
    ]:
        raise ValueError("拼音提示比例递减顺序不正确。")


def pinyin_choice(char: str, order_seed: int) -> dict[str, Any]:
    entry = CHAR_MAP[char]
    options = [entry["pinyin"], entry["wrong"]]
    if order_seed % 2:
        options.reverse()
    return {
        "char": char,
        "options": options,
        "answer": entry["pinyin"],
    }


def make_match(chars: str, offset: int) -> dict[str, Any]:
    entries = [CHAR_MAP[char] for char in chars]
    return {
        "pinyins": [entry["pinyin"] for entry in entries],
        "chars": rotate([entry["char"] for entry in entries], offset),
        "answers": {
            entry["pinyin"]: entry["char"]
            for entry in entries
        },
    }


def build_stage_checks() -> list[dict[str, Any]]:
    check_one = {
        "number": 1,
        "title": "第1阶段检测（第1—7天）",
        "subtitle": "拼准音节 · 建立音字联系",
        "choices": [
            pinyin_choice(char, index)
            for index, char in enumerate("鱼雨妈风天牛草书")
        ],
        "match": make_match("月云八白口花", 2),
        "pictures": [
            {"icon": "fish", "options": ["鱼", "雨"], "answer": "鱼"},
            {"icon": "wind", "options": ["风", "朋"], "answer": "风"},
            {"icon": "cow", "options": ["牛", "你"], "answer": "牛"},
            {"icon": "book", "options": ["书", "手"], "answer": "书"},
        ],
        "contexts": [
            {"text": "天上有白（　）。", "options": ["云", "月"], "answer": "云"},
            {"text": "妈妈买了大（　）。", "options": ["米", "朋"], "answer": "米"},
            {"text": "地里有小（　）。", "options": ["牛", "你"], "answer": "牛"},
            {"text": "小（　）边开着花。", "options": ["河", "火"], "answer": "河"},
            {"text": "我（　）学校里读书。", "options": ["在", "子"], "answer": "在"},
            {"text": "田里有小（　）。", "options": ["虫", "中"], "answer": "虫"},
        ],
        "classify": {
            "prompt": "把下面的字送到正确的拼音小屋。",
            "items": ["早", "草", "三", "中", "虫", "书"],
            "buckets": [
                {"label": "平舌音 z、c、s", "answers": ["早", "草", "三"]},
                {"label": "翘舌音 zh、ch、sh", "answers": ["中", "虫", "书"]},
            ],
        },
        "reading": {
            "segments": [
                ("早上，妈妈带我去", None),
                ("公园", "gōng yuán"),
                ("。天上有白云，河边开着花，小虫在草里。", None),
            ],
            "questions": [
                {"text": "天上有什么？", "answer": "白云。"},
                {"text": "小虫在哪里？", "answer": "草里。"},
            ],
        },
    }

    check_two = {
        "number": 2,
        "title": "第2阶段检测（第8—14天）",
        "subtitle": "辨清近音 · 进入词句 · 脱离拼音",
        "choices": [
            pinyin_choice(char, index + 1)
            for index, char in enumerate("早中草虫三书你立")
        ],
        "match": make_match("风朋云人七小", 3),
        "pictures": [
            {"icon": "grass", "options": ["草", "早"], "answer": "草"},
            {"icon": "bug", "options": ["虫", "中"], "answer": "虫"},
            {"icon": "home", "options": ["家", "下"], "answer": "家"},
            {"icon": "hand", "options": ["手", "书"], "answer": "手"},
        ],
        "contexts": [
            {"text": "（　）国有很多美丽的地方。", "options": ["中", "虫"], "answer": "中"},
            {"text": "今天刮大（　）。", "options": ["风", "朋"], "answer": "风"},
            {"text": "（　）们一起读书。", "options": ["你", "立"], "answer": "你"},
            {"text": "放学后，我回（　）。", "options": ["家", "九"], "answer": "家"},
            {"text": "小明（　）认真写字。", "options": ["在", "子"], "answer": "在"},
            {"text": "我用小（　）翻开书本。", "options": ["手", "书"], "answer": "手"},
        ],
        "classify": {
            "prompt": "读一读，把下面的字按鼻音特点分类。",
            "items": ["云", "人", "天", "风", "朋", "中"],
            "buckets": [
                {"label": "前鼻音", "answers": ["云", "人", "天"]},
                {"label": "后鼻音", "answers": ["风", "朋", "中"]},
            ],
        },
        "reading": {
            "segments": [
                ("中午，我和朋友在小河边看书。风来了，书页轻轻动。我们用小手按住书，接着读。", None),
            ],
            "questions": [
                {"text": "“我”和朋友在哪里看书？", "answer": "小河边。"},
                {"text": "风来后，我们怎样做？", "answer": "用小手按住书，接着读。"},
            ],
        },
    }
    return [check_one, check_two]


def validate_stage_checks(checks: list[dict[str, Any]]) -> None:
    if len(checks) != 2:
        raise ValueError("应生成两次阶段检测。")
    for check in checks:
        if len(check["choices"]) != 8:
            raise ValueError("每次检测应有8道拼音选择题。")
        if len(check["match"]["pinyins"]) != 6:
            raise ValueError("每次检测应有6组音字连线题。")
        if len(check["pictures"]) != 4 or len(check["contexts"]) != 6:
            raise ValueError("阶段检测看图题或语境题数量不正确。")
        if sum([16, 12, 16, 18, 18, 20]) != 100:
            raise ValueError("阶段检测分值不是100分。")
        for item in check["choices"]:
            if item["answer"] not in item["options"]:
                raise ValueError(f'检测读音答案不在选项中：{item}')
        for item in check["pictures"] + check["contexts"]:
            if item["answer"] not in item["options"]:
                raise ValueError(f'检测题答案不在选项中：{item}')


SPECIAL_CSS = base.PRINT_CSS + """
.training-page,
.check-page {
  font-size: 11.8pt;
  line-height: 1.4;
}
.training-main-title,
.check-main-title {
  margin: 0;
  text-align: center;
  font-size: 20pt;
  letter-spacing: .05em;
}
.day-banner,
.check-banner {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4mm;
  margin: 1.5mm 0;
  font-weight: 700;
}
.day-number {
  padding: 1mm 3mm;
  border: 1.5pt solid #222;
  border-radius: 3mm;
  font-size: 13pt;
}
.support-chip {
  padding: .7mm 2.5mm;
  border: 1pt solid #777;
  border-radius: 2mm;
  background: #f6f6f6;
  font-size: 9.5pt;
  font-weight: 500;
}
.training-fields {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 6mm;
  padding: 1.5mm 0 2mm;
  border-bottom: 1pt solid #555;
  font-size: 10.5pt;
}
.short-field {
  display: inline-block;
  width: 29mm;
  height: 4.5mm;
  border-bottom: 1pt solid #555;
  vertical-align: bottom;
}
.training-page .section { margin-top: 1.7mm; }
.training-page .section h2,
.check-page .section h2 {
  margin-bottom: .8mm;
  padding: .9mm 2mm;
  font-size: 13.5pt;
}
.choice-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1mm 5mm;
}
.choice-item {
  min-height: 11mm;
  padding: 1.2mm 2mm;
  border-bottom: 1pt dashed #aaa;
  white-space: nowrap;
}
.focus-char {
  display: inline-block;
  min-width: 9mm;
  font-size: 16pt;
  font-weight: 800;
}
.pinyin-option {
  margin-left: 2mm;
  font-family: "Microsoft YaHei", sans-serif;
}
.match-card {
  padding: 1.5mm 2mm;
  border: 1pt solid #777;
  break-inside: avoid;
}
.match-row {
  display: flex;
  justify-content: space-around;
  align-items: center;
}
.match-chip {
  display: inline-flex;
  min-width: 20mm;
  height: 9mm;
  align-items: center;
  justify-content: center;
  padding: 0 2mm;
  border: 1pt solid #555;
  background: #fff;
  font-size: 13pt;
  font-weight: 700;
}
.match-gap {
  height: 9mm;
  border-left: 1pt dotted #bbb;
  border-right: 1pt dotted #bbb;
}
.picture-choice-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 3mm;
}
.picture-choice-card {
  display: grid;
  grid-template-columns: 32mm 1fr;
  min-height: 29mm;
  align-items: center;
  padding: 1.2mm 2mm;
  border: 1pt solid #777;
}
.object-svg {
  width: 28mm;
  height: 23mm;
}
.picture-options {
  display: flex;
  flex-direction: column;
  gap: 1.5mm;
}
.picture-option {
  display: inline-block;
  padding: .7mm 1.5mm;
  border-bottom: 1pt solid #777;
  font-size: 13pt;
}
.tiny-pinyin {
  margin-left: 2mm;
  color: #444;
  font-size: 9pt;
}
.context-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2mm 5mm;
}
.context-item {
  min-height: 14mm;
  padding: 1.5mm 2mm;
  border: 1pt dashed #888;
}
.clue {
  display: inline-block;
  margin-left: 2mm;
  color: #444;
  font-size: 9.5pt;
}
.review-box {
  padding: 1.5mm 2mm;
  border: 1.4pt solid #444;
  background: #fafafa;
}
.review-strip {
  display: flex;
  flex-wrap: wrap;
  gap: 1.5mm;
  margin-top: 1mm;
}
.review-char {
  display: inline-flex;
  width: 9mm;
  height: 9mm;
  align-items: center;
  justify-content: center;
  border: 1pt solid #777;
  background: #fff;
  font-size: 14pt;
  font-weight: 700;
}
.oral-box {
  display: grid;
  grid-template-columns: 1fr 48mm;
  gap: 3mm;
  padding: 1.5mm 2mm;
  border: 1pt dashed #777;
  font-size: 10.5pt;
}
.parent-check {
  display: flex;
  align-items: center;
  justify-content: center;
  border-left: 1pt dashed #999;
  text-align: center;
}
.mini-reading {
  padding: 2mm 3mm;
  border: 1pt solid #666;
  background: #fafafa;
  line-height: 1.75;
}
.mini-reading p { margin: 0 0 1mm; }
ruby { ruby-position: over; }
rt { font-size: 7.5pt; font-weight: 500; }
.check-score {
  display: flex;
  justify-content: space-between;
  margin: 2mm 0 1.5mm;
  padding: 1.3mm 3mm;
  border: 1pt solid #555;
  background: #f2f2f2;
}
.check-page .choice-item { min-height: 12mm; }
.check-page .picture-choice-card { min-height: 34mm; }
.classify-source {
  display: flex;
  justify-content: center;
  gap: 5mm;
  margin: 2mm 0;
  font-size: 17pt;
  font-weight: 700;
}
.classify-buckets {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 5mm;
}
.classify-bucket {
  min-height: 38mm;
  padding: 2mm;
  border: 1.2pt solid #555;
  text-align: center;
}
.bucket-lines {
  height: 22mm;
  margin-top: 2mm;
  border-top: 1pt dashed #aaa;
  border-bottom: 1pt dashed #aaa;
}
.reading-question {
  min-height: 14mm;
  padding: 1.5mm 0;
  border-bottom: 1pt dashed #999;
}
.answer-key-row {
  margin: 1mm 0;
  padding: 1.5mm 2mm;
  border-left: 3pt solid #555;
  background: #f8f8f8;
}
.diagnosis-card {
  margin: 2mm 0;
  padding: 2.5mm 3mm;
  border: 1pt solid #777;
  break-inside: avoid;
}
.diagnosis-tag {
  display: inline-block;
  margin-right: 2mm;
  padding: .4mm 2mm;
  border: 1pt solid #777;
  border-radius: 2mm;
  font-size: 9.5pt;
  font-weight: 700;
}
.score-band {
  margin: 1.5mm 0;
  padding: 2mm 3mm;
  border: 1pt dashed #777;
}
"""


def object_svg(name: str) -> str:
    drawings = {
        "fish": '<ellipse cx="42" cy="29" rx="22" ry="12" fill="white" stroke="black" stroke-width="2"/><polygon points="20,29 5,17 5,41" fill="#ddd" stroke="black" stroke-width="2"/><circle cx="52" cy="25" r="2.5"/>',
        "rain": '<path d="M17 30 Q10 20 23 20 Q27 8 39 16 Q50 7 58 20 Q73 19 70 31 Z" fill="white" stroke="black" stroke-width="2"/><path d="M22 37 l-4 10 M38 37 l-4 10 M54 37 l-4 10 M68 37 l-4 10" stroke="black" stroke-width="2"/>',
        "moon": '<path d="M51 7 A24 24 0 1 0 62 48 A20 20 0 0 1 51 7" fill="#eee" stroke="black" stroke-width="2"/>',
        "cloud": '<path d="M16 40 Q7 37 12 28 Q14 20 23 23 Q26 11 38 17 Q49 8 57 20 Q70 20 70 31 Q69 40 58 40 Z" fill="white" stroke="black" stroke-width="2"/>',
        "rice": '<path d="M15 28 H68 Q65 50 42 52 Q19 50 15 28" fill="white" stroke="black" stroke-width="2"/><path d="M20 27 Q25 12 31 27 M34 27 Q39 9 44 27 M48 27 Q54 13 59 27" fill="none" stroke="black" stroke-width="2"/>',
        "wind": '<path d="M8 18 H56 Q68 18 66 9 Q64 4 57 8 M8 29 H67 Q77 29 74 39 Q72 45 65 41 M8 41 H49" fill="none" stroke="black" stroke-width="2.5"/>',
        "cow": '<path d="M23 18 L12 8 M61 18 L72 8" stroke="black" stroke-width="3"/><rect x="20" y="14" width="44" height="36" rx="16" fill="white" stroke="black" stroke-width="2"/><circle cx="34" cy="28" r="2.5"/><circle cx="51" cy="28" r="2.5"/><ellipse cx="42" cy="41" rx="12" ry="7" fill="#eee" stroke="black"/>',
        "sky": '<circle cx="59" cy="16" r="9" fill="white" stroke="black" stroke-width="2"/><path d="M8 46 Q15 34 25 42 Q31 28 43 39 Q53 37 60 46" fill="none" stroke="black" stroke-width="2"/>',
        "mouth": '<path d="M12 29 Q42 8 72 29 Q42 53 12 29 Z" fill="white" stroke="black" stroke-width="2"/><path d="M18 29 Q42 36 66 29" fill="none" stroke="black"/>',
        "fire": '<path d="M42 5 Q55 18 48 28 Q61 24 63 38 Q62 54 42 55 Q22 54 21 39 Q21 25 32 18 Q30 30 40 33 Q47 23 42 5 Z" fill="#eee" stroke="black" stroke-width="2"/>',
        "river": '<path d="M5 15 Q20 5 35 15 T65 15 T80 15 M5 29 Q20 19 35 29 T65 29 T80 29 M5 43 Q20 33 35 43 T65 43 T80 43" fill="none" stroke="black" stroke-width="2"/>',
        "flower": '<circle cx="42" cy="24" r="6" fill="#ddd" stroke="black"/><circle cx="42" cy="11" r="8" fill="white" stroke="black"/><circle cx="55" cy="24" r="8" fill="white" stroke="black"/><circle cx="42" cy="37" r="8" fill="white" stroke="black"/><circle cx="29" cy="24" r="8" fill="white" stroke="black"/><path d="M42 44 V57" stroke="black" stroke-width="2"/>',
        "home": '<polygon points="10,28 42,5 74,28" fill="#eee" stroke="black" stroke-width="2"/><rect x="18" y="28" width="48" height="29" fill="white" stroke="black" stroke-width="2"/><rect x="36" y="38" width="13" height="19" fill="#eee" stroke="black"/>',
        "down": '<path d="M42 6 V42 M24 29 L42 48 L60 29" fill="none" stroke="black" stroke-width="5"/>',
        "grass": '<path d="M10 51 Q15 26 23 12 Q22 33 30 50 M30 50 Q37 22 46 8 Q44 31 49 50 M49 50 Q58 26 70 17 Q61 37 62 50" fill="none" stroke="black" stroke-width="2.5"/>',
        "morning": '<path d="M9 43 H75 M26 42 A16 16 0 0 1 58 42 M42 8 V18 M18 21 L25 28 M66 21 L59 28" fill="none" stroke="black" stroke-width="2.5"/>',
        "bug": '<ellipse cx="42" cy="33" rx="16" ry="20" fill="white" stroke="black" stroke-width="2"/><path d="M42 13 V53 M27 28 H57 M27 40 H57 M31 16 L23 7 M53 16 L61 7 M26 26 L14 19 M58 26 L70 19 M26 43 L14 50 M58 43 L70 50" stroke="black" stroke-width="1.8"/>',
        "book": '<path d="M8 13 Q26 8 42 18 V52 Q25 42 8 47 Z M76 13 Q58 8 42 18 V52 Q59 42 76 47 Z" fill="white" stroke="black" stroke-width="2"/><path d="M42 18 V52" stroke="black"/>',
        "hand": '<path d="M29 54 V29 Q29 23 34 24 V11 Q34 6 39 8 V24 H42 V8 Q42 3 47 6 V24 H50 V11 Q50 6 55 9 V28 H58 V17 Q58 12 63 15 V37 Q63 53 48 57 Z" fill="white" stroke="black" stroke-width="2"/>',
        "sun": '<circle cx="42" cy="29" r="14" fill="white" stroke="black" stroke-width="2"/><path d="M42 4 V11 M42 47 V55 M17 29 H9 M75 29 H67 M24 11 L29 16 M60 11 L55 16 M24 47 L29 42 M60 47 L55 42" stroke="black" stroke-width="2"/>',
    }
    content = drawings.get(name)
    if content is None:
        raise ValueError(f"未知图片类型：{name}")
    return (
        f'<svg class="object-svg" viewBox="0 0 84 60" role="img" '
        f'aria-label="{base.esc(name)}">{content}</svg>'
    )


def render_ruby_segments(segments: list[tuple[str, str | None]]) -> str:
    parts: list[str] = []
    for text, pinyin in segments:
        if pinyin:
            parts.append(
                f"<ruby>{base.esc(text)}<rt>{base.esc(pinyin)}</rt></ruby>"
            )
        else:
            parts.append(base.esc(text))
    return "".join(parts)


def training_header(lesson: dict[str, Any]) -> str:
    return f"""
      <h1 class="training-main-title">一年级拼音认字14天训练</h1>
      <div class="day-banner">
        <span class="day-number">第{lesson["day"]:02d}天</span>
        <span>{base.esc(lesson["title"])}</span>
        <span class="support-chip">拼音提示约{lesson["support"]}%</span>
      </div>
      <div class="training-fields">
        <div>姓名：<span class="short-field"></span></div>
        <div>日期：<span class="short-field"></span></div>
        <div>用时：<span class="short-field"></span></div>
      </div>
    """


def page_footer(label: str) -> str:
    return f"""
      <div class="page-footer">
        <span>每天15分钟 · 先拼准，再认字，最后盖住拼音复认</span>
        <span>{base.esc(label)}</span>
      </div>
    """


def render_choice_grid(items: list[dict[str, Any]]) -> str:
    return '<div class="choice-grid">' + "".join(
        f"""
        <div class="choice-item">
          <span class="focus-char">{base.esc(item["char"])}</span>
          <span class="pinyin-option">○ {base.esc(item["options"][0])}</span>
          <span class="pinyin-option">○ {base.esc(item["options"][1])}</span>
        </div>
        """
        for item in items
    ) + "</div>"


def render_match_card(match: dict[str, Any]) -> str:
    pinyin_row = "".join(
        f'<span class="match-chip">{base.esc(pinyin)}</span>'
        for pinyin in match["pinyins"]
    )
    char_row = "".join(
        f'<span class="match-chip">{base.esc(char)}</span>'
        for char in match["chars"]
    )
    return f"""
      <div class="match-card">
        <div class="match-row">{pinyin_row}</div>
        <div class="match-gap"></div>
        <div class="match-row">{char_row}</div>
      </div>
    """


def render_picture_choices(
    items: list[dict[str, Any]],
    *,
    show_pinyin: bool,
) -> str:
    cards: list[str] = []
    for item in items:
        options = []
        for char in item["options"]:
            pinyin = (
                f'<span class="tiny-pinyin">{base.esc(str(CHAR_MAP[char]["pinyin"]))}</span>'
                if show_pinyin
                else ""
            )
            options.append(
                f'<span class="picture-option">□ {base.esc(char)}{pinyin}</span>'
            )
        cards.append(
            f"""
            <div class="picture-choice-card">
              {object_svg(item["icon"])}
              <div class="picture-options">{"".join(options)}</div>
            </div>
            """
        )
    return f'<div class="picture-choice-grid">{"".join(cards)}</div>'


def render_contexts(items: list[dict[str, Any]]) -> str:
    return '<div class="context-grid">' + "".join(
        f"""
        <div class="context-item">
          {base.esc(item["text"])}
          <span class="clue">
            {f'提示：{base.esc(item["clue"])}' if item.get("clue") else "先读句子再选择"}
          </span><br>
          选字：{"　".join(f"○{base.esc(option)}" for option in item["options"])}
        </div>
        """
        for item in items
    ) + "</div>"


def render_daily_page(lesson: dict[str, Any]) -> str:
    review_entries = lesson["review_entries"] or lesson["focus_entries"]
    review_chars = "".join(
        f'<span class="review-char">{base.esc(str(entry["char"]))}</span>'
        for entry in review_entries
    )
    reading_html = ""
    if lesson["reading"]:
        reading_html = f"""
        <div class="section">
          <h2>五、读一小段，再回答</h2>
          <div class="mini-reading">
            <p>{render_ruby_segments(lesson["reading"]["segments"])}</p>
            <div>{base.esc(lesson["reading"]["question"])} <span class="blank long"></span></div>
          </div>
        </div>
        """
        review_number = "六"
        oral_number = "七"
    else:
        review_number = "五"
        oral_number = "六"

    return f"""
    <section class="page training-page">
      {training_header(lesson)}

      <div class="section">
        <h2>一、读一读，圈出正确的拼音</h2>
        {render_choice_grid(lesson["choices"])}
      </div>

      <div class="section">
        <h2>二、拼音和汉字手拉手</h2>
        {render_match_card(lesson["match"])}
      </div>

      <div class="section">
        <h2>三、看图选字</h2>
        {render_picture_choices(lesson["pictures"], show_pinyin=lesson["support"] >= 60)}
      </div>

      <div class="section">
        <h2>四、读句子，选合适的字</h2>
        {render_contexts(lesson["contexts"])}
      </div>

      {reading_html}

      <div class="section">
        <h2>{review_number}、盖住拼音，快速认字</h2>
        <div class="review-box">
          <div>按顺序读一遍，再打勾：　□全会　□有点慢　□需要帮助</div>
          <div class="review-strip">{review_chars}</div>
        </div>
      </div>

      <div class="section">
        <h2>{oral_number}、读给家长听</h2>
        <div class="oral-box">
          <div>{base.esc(lesson["oral"])}</div>
          <div class="parent-check">家长签字：____________</div>
        </div>
      </div>
      {page_footer(f'第{lesson["day"]:02d}天 / 共14天')}
    </section>
    """


def render_training_html(lessons: list[dict[str, Any]]) -> str:
    pages = "".join(render_daily_page(lesson) for lesson in lessons)
    return f"""<!doctype html>
    <html lang="zh-CN">
      <head>
        <meta charset="utf-8">
        <title>一年级拼音认字14天训练册</title>
        <style>{SPECIAL_CSS}</style>
      </head>
      <body>{pages}</body>
    </html>"""


def check_header(check: dict[str, Any]) -> str:
    return f"""
      <h1 class="check-main-title">一年级拼音认字阶段检测</h1>
      <div class="check-banner">
        <span class="day-number">{base.esc(check["title"])}</span>
        <span>{base.esc(check["subtitle"])}</span>
      </div>
      <div class="training-fields">
        <div>姓名：<span class="short-field"></span></div>
        <div>日期：<span class="short-field"></span></div>
        <div>用时：<span class="short-field"></span></div>
      </div>
    """


def render_check_page_one(check: dict[str, Any]) -> str:
    return f"""
    <section class="page check-page">
      {check_header(check)}
      <div class="check-score"><span>满分：100分</span><span>认真拼读 · 独立完成</span><span>得分：________</span></div>

      <div class="section">
        <h2>一、为汉字圈出正确读音（16分）</h2>
        {render_choice_grid(check["choices"])}
      </div>

      <div class="section">
        <h2>二、把拼音和汉字连起来（12分）</h2>
        {render_match_card(check["match"])}
      </div>

      <div class="section">
        <h2>三、看图选择合适的字（16分）</h2>
        {render_picture_choices(check["pictures"], show_pinyin=check["number"] == 1)}
      </div>
      {page_footer(f'第{check["number"]}次阶段检测 1/2')}
    </section>
    """


def render_check_contexts(items: list[dict[str, Any]]) -> str:
    return '<div class="context-grid">' + "".join(
        f"""
        <div class="context-item">
          {base.esc(item["text"])}<br>
          选字：{"　".join(f"○{base.esc(option)}" for option in item["options"])}
        </div>
        """
        for item in items
    ) + "</div>"


def render_classify_task(classify: dict[str, Any]) -> str:
    source = "".join(
        f'<span>{base.esc(char)}</span>'
        for char in classify["items"]
    )
    buckets = "".join(
        f"""
        <div class="classify-bucket">
          <strong>{base.esc(bucket["label"])}</strong>
          <div class="bucket-lines"></div>
        </div>
        """
        for bucket in classify["buckets"]
    )
    return f"""
      <p class="instruction">{base.esc(classify["prompt"])}</p>
      <div class="classify-source">{source}</div>
      <div class="classify-buckets">{buckets}</div>
    """


def render_check_reading(reading: dict[str, Any]) -> str:
    questions = "".join(
        f'<div class="reading-question">{base.esc(item["text"])} <span class="blank long"></span></div>'
        for item in reading["questions"]
    )
    return f"""
      <div class="mini-reading">
        <p>{render_ruby_segments(reading["segments"])}</p>
      </div>
      {questions}
    """


def render_check_page_two(check: dict[str, Any]) -> str:
    return f"""
    <section class="page check-page">
      {check_header(check)}

      <div class="section">
        <h2>四、读句子，选择合适的字（18分）</h2>
        {render_check_contexts(check["contexts"])}
      </div>

      <div class="section">
        <h2>五、分清容易混淆的读音（18分）</h2>
        {render_classify_task(check["classify"])}
      </div>

      <div class="section">
        <h2>六、读短文，回答问题（20分）</h2>
        {render_check_reading(check["reading"])}
      </div>
      {page_footer(f'第{check["number"]}次阶段检测 2/2')}
    </section>
    """


def render_check_html(check: dict[str, Any]) -> str:
    pages = render_check_page_one(check) + render_check_page_two(check)
    return f"""<!doctype html>
    <html lang="zh-CN">
      <head>
        <meta charset="utf-8">
        <title>{base.esc(check["title"])}</title>
        <style>{SPECIAL_CSS}</style>
      </head>
      <body>{pages}</body>
    </html>"""


def filled_context(text: str, answer: str) -> str:
    return text.replace("（　）", f"（{answer}）")


def daily_diagnosis(lesson: dict[str, Any]) -> tuple[str, list[str]]:
    day = lesson["day"]
    if day <= 3:
        return (
            "声母、韵母或声调还不稳",
            [
                "先让孩子看清完整音节，不急着猜汉字。",
                "用手指在空中画声调走势，再把正确音节慢读3遍。",
                "最后遮住拼音，只看汉字读1遍；仍不会的字第二天先复习。",
            ],
        )
    if day <= 7:
        return (
            "拼音能读，但音字联系不牢",
            [
                "把错字和正确拼音写在两张小卡片上，重新配对。",
                "把字放回本页词语中读，如“河—小河”，不要只背单字。",
                "隔10分钟盖住拼音复认，再在第二天开始前复认一次。",
            ],
        )
    if day <= 10:
        return (
            "容易混淆相近读音",
            [
                "先慢读两个对比音节，指出不同的是声母、韵母还是鼻音。",
                "平舌音舌尖靠前，翘舌音舌尖微翘；前后鼻音要听清结尾。",
                "交替读正确字和干扰字各3次，再放进词语中判断。",
            ],
        )
    return (
        "有拼音会认，进入词句后或去掉拼音会卡住",
        [
            "先读完整词语和句子，根据意思猜一猜，再核对拼音。",
            "用小纸条遮住拼音读两遍；卡住时只露出第一个音节提示。",
            "让孩子用目标词再说一句话，建立“字形—读音—意思”的联系。",
        ],
    )


def render_daily_answer(lesson: dict[str, Any]) -> str:
    choices = "；".join(
        f'{item["char"]}—{item["answer"]}'
        for item in lesson["choices"]
    )
    matches = "；".join(
        f"{pinyin}—{char}"
        for pinyin, char in lesson["match"]["answers"].items()
    )
    pictures = "；".join(
        f'{item["answer"]}（{CHAR_MAP[item["answer"]]["pinyin"]}）'
        for item in lesson["pictures"]
    )
    contexts = "；".join(
        filled_context(item["text"], item["answer"]).rstrip("。！？")
        for item in lesson["contexts"]
    )
    review_entries = lesson["review_entries"] or lesson["focus_entries"]
    reviews = "　".join(
        f'{entry["char"]}（{entry["pinyin"]}）'
        for entry in review_entries
    )
    reading = ""
    if lesson["reading"]:
        reading = f"""
        <div class="answer-key-row">
          <strong>短文题：</strong>{base.esc(lesson["reading"]["answer"])}
          <span class="reason">先回到短文中找到题目中的关键词，再读完整句子。</span>
        </div>
        """
    diagnosis, steps = daily_diagnosis(lesson)
    correction_steps = "".join(f"<li>{base.esc(step)}</li>" for step in steps)
    return f"""
    <section class="answer-set">
      <h1>第{lesson["day"]:02d}天答案与订正指导</h1>
      <h2>标准答案</h2>
      <div class="answer-key-row"><strong>一、正确读音：</strong>{base.esc(choices)}。</div>
      <div class="answer-key-row"><strong>二、音字连线：</strong>{base.esc(matches)}。</div>
      <div class="answer-key-row"><strong>三、看图选字：</strong>{base.esc(pictures)}。</div>
      <div class="answer-key-row"><strong>四、句中选字：</strong>{base.esc(contexts)}。</div>
      {reading}
      <div class="answer-key-row"><strong>快速复认读音：</strong>{base.esc(reviews)}。</div>

      <h2>错题怎么看</h2>
      <div class="diagnosis-card">
        <span class="diagnosis-tag">{base.esc(diagnosis)}</span>
        <p>如果“正确读音”错得多，先查拼音；如果连线或看图题错得多，说明音字没有绑牢；
        如果句中选字错，说明还没有利用词义和句意；如果快速复认卡住，说明仍依赖拼音。</p>
        <ol class="thinking-steps">{correction_steps}</ol>
      </div>

      <h2>家长5分钟复习法</h2>
      <div class="answer-callout">
        先随机指3个字让孩子读；再把这3个字放进词语中读；最后盖住拼音重新读。
        只记录真正卡住的字，不要求整页重做。第二天开始前复认这些错字即可。
      </div>
    </section>
    """


def render_check_answer(check: dict[str, Any]) -> str:
    choices = "；".join(
        f'{item["char"]}—{item["answer"]}'
        for item in check["choices"]
    )
    matches = "；".join(
        f"{pinyin}—{char}"
        for pinyin, char in check["match"]["answers"].items()
    )
    pictures = "；".join(item["answer"] for item in check["pictures"])
    contexts = "；".join(
        filled_context(item["text"], item["answer"]).rstrip("。！？")
        for item in check["contexts"]
    )
    classifications = "；".join(
        f'{bucket["label"]}：{"、".join(bucket["answers"])}'
        for bucket in check["classify"]["buckets"]
    )
    reading = "；".join(
        f'{item["text"]}{item["answer"]}'
        for item in check["reading"]["questions"]
    )
    return f"""
    <section class="answer-set">
      <h1>第{check["number"]}次阶段检测答案</h1>
      <div class="answer-key-row"><strong>一、正确读音：</strong>{base.esc(choices)}。</div>
      <div class="answer-key-row"><strong>二、音字连线：</strong>{base.esc(matches)}。</div>
      <div class="answer-key-row"><strong>三、看图选字：</strong>{base.esc(pictures)}。</div>
      <div class="answer-key-row"><strong>四、句中选字：</strong>{base.esc(contexts)}。</div>
      <div class="answer-key-row"><strong>五、读音分类：</strong>{base.esc(classifications)}。</div>
      <div class="answer-key-row"><strong>六、短文阅读：</strong>{base.esc(reading)}。</div>

      <h2>分数说明与下一步</h2>
      <div class="score-band"><strong>90—100分：</strong>音字联系较稳。继续下一阶段，并坚持盖住拼音复认。</div>
      <div class="score-band"><strong>75—89分：</strong>整体达标。把错题按“拼音、音字、语境”分组，各复习5分钟。</div>
      <div class="score-band"><strong>60—74分：</strong>支架撤得稍快。回做最近3天训练，先恢复拼音提示，再逐步遮住。</div>
      <div class="score-band"><strong>60分以下：</strong>暂不追求速度。每天只练6个核心字，确保能拼、能认、能组词后再继续。</div>

      <h2>错误类型定位</h2>
      <ul class="thinking-steps">
        <li>第一题错：优先复习声母、韵母和四声。</li>
        <li>第二、三题错：拼音会读，但没有稳定对应到汉字。</li>
        <li>第四题错：需要在词语和句子中理解字义。</li>
        <li>第五题错：相近音辨析不稳，需要成对慢读。</li>
        <li>第六题错：逐字认读尚可，但连续阅读和提取信息需要加强。</li>
      </ul>
    </section>
    """


def render_parent_guide() -> str:
    return """
    <section class="answer-set">
      <h1>家长使用说明</h1>
      <h2>每天怎样练</h2>
      <ol class="thinking-steps">
        <li><strong>前3分钟：</strong>孩子自己拼，家长只听，不抢答。</li>
        <li><strong>中间8分钟：</strong>完成连线、看图和句中选字，先问“为什么”，再核对。</li>
        <li><strong>最后4分钟：</strong>盖住拼音复认，并把卡住的字记入当天错字栏。</li>
      </ol>

      <h2>不要这样做</h2>
      <ul class="thinking-steps">
        <li>不要给所有熟字长期标拼音，否则孩子会只看拼音、不看字形。</li>
        <li>不要把同音字脱离词句单独比较；没有语境时可能不止一个答案。</li>
        <li>不要把“会写”当成“会认”。本训练以读准、认出、理解为主。</li>
        <li>不要一次重抄整页。只复习真正卡住的3—6个字，效果更好。</li>
      </ul>

      <h2>四类错误记录</h2>
      <div class="diagnosis-card"><span class="diagnosis-tag">P 拼音</span>声母、韵母或声调读错。</div>
      <div class="diagnosis-card"><span class="diagnosis-tag">B 绑定</span>拼音会读，但找不到对应汉字。</div>
      <div class="diagnosis-card"><span class="diagnosis-tag">C 语境</span>单字会认，放进词句不会选。</div>
      <div class="diagnosis-card"><span class="diagnosis-tag">R 复认</span>有拼音会认，遮住拼音就卡住。</div>
      <p>每天只需在错字旁写一个字母标签。第7天和第14天检测后，看看哪类标签最多，再按答案册建议回练。</p>
    </section>
    """


def render_answer_html(
    lessons: list[dict[str, Any]],
    checks: list[dict[str, Any]],
) -> str:
    cover = """
    <section class="answer-cover">
      <h1>一年级拼音认字14天训练</h1>
      <h2>答案与家长指导</h2>
      <div class="answer-note">
        <p><strong>核心方法：</strong>拼准音节 → 对应汉字 → 放进词句 → 盖住拼音复认。</p>
        <p><strong>使用顺序：</strong>孩子先独立完成当天一页，家长再查看对应答案。
        不要边做边报答案，也不要只看最终对错。</p>
        <p><strong>训练目标：</strong>14天后不仅能看拼音认字，还能在常用词句和短文中脱离拼音认读。</p>
      </div>
    </section>
    """
    guide = render_parent_guide()
    daily_answers = "".join(render_daily_answer(lesson) for lesson in lessons)
    check_answers = "".join(render_check_answer(check) for check in checks)
    return f"""<!doctype html>
    <html lang="zh-CN">
      <head>
        <meta charset="utf-8">
        <title>一年级拼音认字训练答案与家长指导</title>
        <style>{SPECIAL_CSS}</style>
      </head>
      <body class="answer-document">{cover}{guide}{daily_answers}{check_answers}</body>
    </html>"""


async def build_pdfs(
    lessons: list[dict[str, Any]],
    checks: list[dict[str, Any]],
) -> None:
    edge_candidates = [
        Path(r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"),
        Path(r"C:\Program Files\Microsoft\Edge\Application\msedge.exe"),
    ]
    executable = next((path for path in edge_candidates if path.exists()), None)
    async with async_playwright() as playwright:
        launch_kwargs: dict[str, Any] = {"headless": True}
        if executable is not None:
            launch_kwargs["executable_path"] = str(executable)
        browser = await playwright.chromium.launch(**launch_kwargs)
        page = await browser.new_page(viewport={"width": 1440, "height": 1100})

        await base.render_pdf(
            page,
            render_training_html(lessons),
            TRAINING_PDF,
            expect_fixed_pages=True,
        )
        print(f"generated {TRAINING_PDF.name}: {TRAINING_PDF.stat().st_size:,} bytes")

        for check in checks:
            output_path = CHECK_PDFS[check["number"]]
            await base.render_pdf(
                page,
                render_check_html(check),
                output_path,
                expect_fixed_pages=True,
            )
            print(f"generated {output_path.name}: {output_path.stat().st_size:,} bytes")

        await base.render_pdf(
            page,
            render_answer_html(lessons, checks),
            ANSWER_PDF,
            expect_fixed_pages=False,
        )
        print(f"generated {ANSWER_PDF.name}: {ANSWER_PDF.stat().st_size:,} bytes")
        await browser.close()


def pdf_text(path: Path) -> tuple[int, bool, str, int]:
    document = fitz.open(path)
    try:
        is_a4 = all(
            abs(page.rect.width - 595.276) < 1
            and abs(page.rect.height - 841.89) < 1
            for page in document
        )
        text = "".join(page.get_text() for page in document)
        drawings = sum(len(page.get_drawings()) for page in document)
        return len(document), is_a4, text, drawings
    finally:
        document.close()


def validate_outputs(
    lessons: list[dict[str, Any]],
    checks: list[dict[str, Any]],
) -> None:
    paths = [TRAINING_PDF, CHECK_PDFS[1], CHECK_PDFS[2], ANSWER_PDF]
    missing = [path.name for path in paths if not path.exists()]
    if missing:
        raise RuntimeError(f"缺少PDF文件：{missing}")

    for path in paths:
        if path.read_bytes()[:5] != b"%PDF-":
            raise RuntimeError(f"不是有效PDF：{path.name}")
        if path.stat().st_size < 20_000:
            raise RuntimeError(f"PDF文件过小，可能生成失败：{path.name}")

    training_pages, training_a4, training_text, training_drawings = pdf_text(TRAINING_PDF)
    if training_pages != 14:
        raise RuntimeError(f"训练册应为14页，实际为{training_pages}页。")
    if not training_a4:
        raise RuntimeError("训练册存在非A4页面。")
    for day in range(1, 15):
        if f"第{day:02d}天" not in training_text:
            raise RuntimeError(f"训练册缺少第{day:02d}天。")
    if training_text.count("盖住拼音") < 14:
        raise RuntimeError("训练册未完整包含每日脱拼音复认任务。")

    check_reports = []
    for check in checks:
        path = CHECK_PDFS[check["number"]]
        pages, is_a4, text, drawings = pdf_text(path)
        if pages != 2 or not is_a4:
            raise RuntimeError(f"{path.name}应为2页A4。")
        for marker in ("正确读音", "拼音和汉字", "看图", "读句子", "读短文"):
            if marker not in text:
                raise RuntimeError(f"{path.name}缺少题型：{marker}")
        check_reports.append(
            {
                "file": path.name,
                "pages": pages,
                "drawings": drawings,
            }
        )

    answer_pages, answer_a4, answer_text, answer_drawings = pdf_text(ANSWER_PDF)
    if answer_pages < 18 or not answer_a4:
        raise RuntimeError(f"答案册页数或页面尺寸异常：{answer_pages}页。")
    for marker in ("家长使用说明", "四类错误记录", "第1次阶段检测答案", "第2次阶段检测答案"):
        if marker not in answer_text:
            raise RuntimeError(f"答案册缺少内容：{marker}")
    for day in range(1, 15):
        if f"第{day:02d}天答案" not in answer_text:
            raise RuntimeError(f"答案册缺少第{day:02d}天答案。")

    print(
        json.dumps(
            {
                "daily_lessons": len(lessons),
                "core_characters": sum(len(group) for group in CHARACTER_GROUPS),
                "training": {
                    "file": TRAINING_PDF.name,
                    "pages": training_pages,
                    "drawings": training_drawings,
                },
                "checks": check_reports,
                "answers": {
                    "file": ANSWER_PDF.name,
                    "pages": answer_pages,
                    "drawings": answer_drawings,
                },
                "output_directory": str(ROOT),
            },
            ensure_ascii=False,
            indent=2,
        )
    )


async def main() -> None:
    lessons = build_daily_lessons()
    checks = build_stage_checks()
    validate_curriculum(lessons)
    validate_stage_checks(checks)
    await build_pdfs(lessons, checks)
    validate_outputs(lessons, checks)


if __name__ == "__main__":
    asyncio.run(main())
