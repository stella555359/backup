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
TRAINING_PDF = ROOT / "一年级心算脱稿15天训练册_凑十破十示例同款版.pdf"
ANSWER_PDF = ROOT / "一年级心算脱稿15天_凑十破十示例同款版_答案与家长指导.pdf"


def calc(expression: str, answer: int, strategy: str) -> dict[str, Any]:
    return {"expression": expression, "answer": answer, "strategy": strategy}


def bond(total: int, left: int, right: int) -> dict[str, int]:
    return {"total": total, "left": left, "right": right}


DAYS: list[dict[str, Any]] = [
    {
        "day": 1,
        "phase": "摸底",
        "title": "先看清起点，不催速度",
        "goal": "允许使用原来的方法，真实记录哪些题需要草稿。",
        "support": "今天不撤草稿",
        "sections": [
            {
                "title": "口头热身：说出10的朋友",
                "instruction": "家长指一个数，孩子只说与它合成10的数，不写。",
                "kind": "complements",
                "numbers": [1, 9, 2, 8, 3, 7, 4, 6, 5],
            },
            {
                "title": "完成10道摸底题",
                "instruction": "不会时可以打草稿；每用一次完整草稿，就在题后小方框里打“√”。",
                "kind": "calculations",
                "mode": "baseline",
                "scored": True,
                "items": [
                    calc("2＋5", 7, "基础"),
                    calc("9－3", 6, "基础"),
                    calc("4＋4", 8, "双数"),
                    calc("10－6", 4, "补十"),
                    calc("9＋5", 14, "凑十"),
                    calc("8＋7", 15, "凑十"),
                    calc("12－5", 7, "破十"),
                    calc("15－8", 7, "破十"),
                    calc("7＋6", 13, "凑十"),
                    calc("13－4", 9, "破十"),
                ],
            },
        ],
        "challenge": [
            calc("3＋2", 5, "基础"),
            calc("8－2", 6, "基础"),
            calc("5＋5", 10, "双数"),
        ],
        "example": {"kind": "baseline"},
    },
    {
        "day": 2,
        "phase": "心算底座",
        "title": "把数拆开，也能合回去",
        "goal": "看到6—10，能较快说出两部分。",
        "support": "十格图＋分合",
        "sections": [
            {
                "title": "口头热身：看数说补数",
                "instruction": "看到前面的数，马上说“还差几到10”。",
                "kind": "complements",
                "numbers": [6, 7, 8, 9, 5, 4, 3, 2],
            },
            {
                "title": "填一填数的分与合",
                "instruction": "先在心里合一合，再把缺少的数写进大框。",
                "kind": "bonds",
                "items": [
                    bond(6, 1, 5),
                    bond(6, 2, 4),
                    bond(7, 2, 5),
                    bond(7, 3, 4),
                    bond(8, 3, 5),
                    bond(8, 2, 6),
                    bond(9, 4, 5),
                    bond(10, 3, 7),
                ],
            },
        ],
        "challenge": [
            calc("10－8", 2, "补十"),
            calc("10－7", 3, "补十"),
            calc("10－6", 4, "补十"),
            calc("10－9", 1, "补十"),
        ],
        "example": {"kind": "complement", "number": 7},
    },
    {
        "day": 3,
        "phase": "心算底座",
        "title": "用熟悉的题带出新题",
        "goal": "用加1、加2、双数和相邻双数，替代从1开始数。",
        "support": "说方法，不逐个数",
        "sections": [
            {
                "title": "口头热身：双数朋友",
                "instruction": "读一遍：2＋2、3＋3、4＋4、5＋5，并说出得数。",
                "kind": "calculations",
                "items": [
                    calc("2＋2", 4, "双数"),
                    calc("3＋3", 6, "双数"),
                    calc("4＋4", 8, "双数"),
                    calc("5＋5", 10, "双数"),
                ],
            },
            {
                "title": "直接写得数",
                "instruction": "先找它属于“加1、加2、双数、双数多1”中的哪一类。",
                "kind": "calculations",
                "items": [
                    calc("2＋1", 3, "加1"),
                    calc("5＋1", 6, "加1"),
                    calc("7＋1", 8, "加1"),
                    calc("3＋2", 5, "加2"),
                    calc("6＋2", 8, "加2"),
                    calc("8＋2", 10, "加2"),
                    calc("3＋4", 7, "相邻双数"),
                    calc("4＋5", 9, "相邻双数"),
                ],
            },
        ],
        "challenge": [
            calc("6＋1", 7, "加1"),
            calc("5＋2", 7, "加2"),
            calc("4＋4", 8, "双数"),
            calc("4＋5", 9, "相邻双数"),
        ],
        "example": {"kind": "near_double", "left": 4, "right": 5},
    },
    {
        "day": 4,
        "phase": "心算底座",
        "title": "一组数，想出四道题",
        "goal": "把10以内减法和数的分合联系起来。",
        "support": "看分合想加减",
        "sections": [
            {
                "title": "口头热身：由加法想减法",
                "instruction": "家长读“3＋4＝7”，孩子接着说“7－3＝4，7－4＝3”。",
                "kind": "fact_families",
                "items": [bond(7, 3, 4)],
                "oral": True,
            },
            {
                "title": "根据三个数写出得数",
                "instruction": "同一张卡片里的四道题是一家人，不需要重新数。",
                "kind": "fact_families",
                "items": [
                    bond(7, 2, 5),
                    bond(8, 2, 6),
                    bond(9, 4, 5),
                ],
            },
        ],
        "challenge": [
            calc("8－2", 6, "分合"),
            calc("8－6", 2, "分合"),
            calc("9－4", 5, "分合"),
            calc("9－5", 4, "分合"),
        ],
        "example": {"kind": "family", "total": 8, "left": 2, "right": 6},
    },
    {
        "day": 5,
        "phase": "第1次检查",
        "title": "10以内心算检查",
        "goal": "正确率达到90%，并尽量不用完整草稿。",
        "support": "不提示方法",
        "sections": [
            {
                "title": "独立完成10道题",
                "instruction": "不催速度。完成后填写本页记录，再由家长核对答案。",
                "kind": "calculations",
                "mode": "checkpoint",
                "scored": True,
                "items": [
                    calc("10－8", 2, "补十"),
                    calc("10－6", 4, "补十"),
                    calc("3＋5", 8, "基础"),
                    calc("9－4", 5, "分合"),
                    calc("4＋4", 8, "双数"),
                    calc("7＋2", 9, "加2"),
                    calc("2＋7", 9, "交换"),
                    calc("10－3", 7, "补十"),
                    calc("6－2", 4, "分合"),
                    calc("5＋5", 10, "双数"),
                ],
            },
        ],
        "challenge": [
            calc("7－5", 2, "分合"),
            calc("3＋6", 9, "交换"),
            calc("10－4", 6, "补十"),
        ],
        "example": {"kind": "checkpoint", "stage": 1},
    },
    {
        "day": 6,
        "phase": "凑十入门",
        "title": "9加几：9只差1",
        "goal": "会把第二个加数分成1和另一个数。",
        "support": "完整凑十脚手架",
        "sections": [
            {
                "title": "照着步骤填一填",
                "instruction": "每题都先说“9还差1到10”，再填写。",
                "kind": "guided_make",
                "items": [(9, 2), (9, 4), (9, 6), (9, 8)],
            },
            {
                "title": "只写得数",
                "instruction": "可以看上面的步骤，但不再抄完整过程。",
                "kind": "calculations",
                "items": [
                    calc("9＋3", 12, "凑十"),
                    calc("9＋5", 14, "凑十"),
                    calc("9＋7", 16, "凑十"),
                    calc("9＋9", 18, "凑十"),
                ],
            },
        ],
        "challenge": [
            calc("9＋2", 11, "凑十"),
            calc("9＋6", 15, "凑十"),
            calc("9＋8", 17, "凑十"),
        ],
        "example": {"kind": "make", "left": 9, "right": 6},
    },
    {
        "day": 7,
        "phase": "凑十入门",
        "title": "8加几：8只差2",
        "goal": "会从第二个加数中拿出2，先和8凑成10。",
        "support": "图示→拆分",
        "sections": [
            {
                "title": "照着步骤填一填",
                "instruction": "拆开的两个数要能重新合成原来的第二个加数。",
                "kind": "guided_make",
                "items": [(8, 3), (8, 5), (8, 7), (8, 9)],
            },
            {
                "title": "只写得数",
                "instruction": "先在心里说“拿出2，还剩几”。",
                "kind": "calculations",
                "items": [
                    calc("8＋4", 12, "凑十"),
                    calc("8＋6", 14, "凑十"),
                    calc("8＋8", 16, "凑十"),
                    calc("8＋9", 17, "凑十"),
                ],
            },
        ],
        "challenge": [
            calc("8＋3", 11, "凑十"),
            calc("8＋5", 13, "凑十"),
            calc("8＋7", 15, "凑十"),
        ],
        "example": {"kind": "make", "left": 8, "right": 7},
    },
    {
        "day": 8,
        "phase": "凑十进阶",
        "title": "7、6加几：先找“还差几”",
        "goal": "不死背拆法，先根据第一个加数找补数。",
        "support": "同类分组练习",
        "sections": [
            {
                "title": "照着步骤填一填",
                "instruction": "7差3，6差4；先找差几，再拆第二个加数。",
                "kind": "guided_make",
                "items": [(7, 4), (7, 6), (6, 5), (6, 7)],
            },
            {
                "title": "直接写得数",
                "instruction": "每道题只在心里完成一次拆分。",
                "kind": "calculations",
                "items": [
                    calc("7＋5", 12, "凑十"),
                    calc("7＋8", 15, "凑十"),
                    calc("7＋9", 16, "凑十"),
                    calc("6＋6", 12, "凑十"),
                    calc("6＋8", 14, "凑十"),
                    calc("6＋9", 15, "凑十"),
                ],
            },
        ],
        "challenge": [
            calc("7＋4", 11, "凑十"),
            calc("7＋7", 14, "凑十"),
            calc("6＋5", 11, "凑十"),
            calc("6＋8", 14, "凑十"),
        ],
        "example": {"kind": "make", "left": 7, "right": 6},
    },
    {
        "day": 9,
        "phase": "凑十脱稿",
        "title": "草稿只留一次拆分",
        "goal": "不写完整算式链，只写“第二个加数分成几和几”。",
        "support": "最小草稿",
        "sections": [
            {
                "title": "只写一次拆分，再写得数",
                "instruction": "小草稿中只能出现两个拆分数，不写“先算、再算”的完整过程。",
                "kind": "minimal_make",
                "items": [
                    (9, 5),
                    (8, 6),
                    (7, 5),
                    (6, 8),
                    (9, 7),
                    (8, 5),
                    (7, 8),
                    (6, 9),
                    (8, 7),
                    (7, 7),
                ],
            },
        ],
        "challenge": [
            calc("9＋3", 12, "凑十"),
            calc("8＋4", 12, "凑十"),
            calc("7＋6", 13, "凑十"),
            calc("6＋7", 13, "凑十"),
        ],
        "example": {"kind": "make", "left": 8, "right": 7},
    },
    {
        "day": 10,
        "phase": "第2次检查",
        "title": "凑十法脱稿检查",
        "goal": "10题中至少9题正确，完整草稿不超过2题。",
        "support": "前5题可拆分，后5题不用纸",
        "sections": [
            {
                "title": "前5题：只允许写一次拆分",
                "instruction": "可以使用题旁的小草稿，不写完整步骤。",
                "kind": "minimal_make",
                "scored": True,
                "items": [(9, 6), (8, 5), (7, 4), (6, 7), (8, 9)],
            },
            {
                "title": "后5题：先口述，再直接写得数",
                "instruction": "把草稿纸盖住；卡住时家长只问“还差几到10”。",
                "kind": "calculations",
                "mode": "checkpoint",
                "scored": True,
                "items": [
                    calc("9＋8", 17, "凑十"),
                    calc("8＋6", 14, "凑十"),
                    calc("7＋7", 14, "凑十"),
                    calc("6＋5", 11, "凑十"),
                    calc("7＋9", 16, "凑十"),
                ],
            },
        ],
        "challenge": [
            calc("8＋3", 11, "凑十"),
            calc("7＋5", 12, "凑十"),
            calc("6＋6", 12, "凑十"),
        ],
        "example": {"kind": "checkpoint_make", "left": 7, "right": 9},
    },
    {
        "day": 11,
        "phase": "破十入门",
        "title": "十几减几：先把十几看成10和几",
        "goal": "理解“先从10里减，再把个位数加回来”。",
        "support": "完整破十脚手架",
        "sections": [
            {
                "title": "照着步骤填一填",
                "instruction": "若学校尚未学习退位减法，请回练第6—10天，不要求今天限时完成。",
                "kind": "guided_break",
                "items": [(11, 2), (12, 5), (13, 6), (14, 7)],
            },
            {
                "title": "只写得数",
                "instruction": "先说“十减几得几，再加个位数”。",
                "kind": "calculations",
                "items": [
                    calc("11－4", 7, "破十"),
                    calc("12－3", 9, "破十"),
                    calc("13－5", 8, "破十"),
                    calc("14－6", 8, "破十"),
                ],
            },
        ],
        "challenge": [
            calc("11－3", 8, "破十"),
            calc("12－4", 8, "破十"),
            calc("13－5", 8, "破十"),
        ],
        "example": {"kind": "break", "total": 13, "sub": 6},
    },
    {
        "day": 12,
        "phase": "破十脱稿",
        "title": "草稿只留“10减几”",
        "goal": "不再抄完整破十过程，只保留最容易忘的一步。",
        "support": "最小草稿",
        "sections": [
            {
                "title": "写一个小草稿，再写得数",
                "instruction": "小草稿只算“10－减数”，个位数在心里加回来。",
                "kind": "minimal_break",
                "items": [
                    (11, 3),
                    (11, 5),
                    (12, 4),
                    (12, 7),
                    (13, 4),
                    (13, 8),
                    (14, 5),
                    (14, 8),
                    (14, 9),
                    (13, 7),
                ],
            },
        ],
        "challenge": [
            calc("12－5", 7, "破十"),
            calc("13－6", 7, "破十"),
            calc("14－7", 7, "破十"),
            calc("14－9", 5, "破十"),
        ],
        "example": {"kind": "break", "total": 14, "sub": 8},
    },
    {
        "day": 13,
        "phase": "破十脱稿",
        "title": "先口述，再静默心算",
        "goal": "前几题小声说步骤，后几题把步骤放到心里。",
        "support": "口述→静默",
        "sections": [
            {
                "title": "直接写得数",
                "instruction": "前4题小声说方法；第5题开始不说、不写过程，直接作答。",
                "kind": "calculations",
                "items": [
                    calc("11－6", 5, "破十"),
                    calc("12－5", 7, "破十"),
                    calc("13－6", 7, "破十"),
                    calc("14－7", 7, "破十"),
                    calc("15－8", 7, "破十"),
                    calc("16－9", 7, "破十"),
                    calc("17－8", 9, "破十"),
                    calc("18－9", 9, "破十"),
                    calc("15－7", 8, "破十"),
                    calc("16－8", 8, "破十"),
                ],
            },
        ],
        "challenge": [
            calc("13－5", 8, "破十"),
            calc("15－6", 9, "破十"),
            calc("17－9", 8, "破十"),
        ],
        "example": {"kind": "break", "total": 16, "sub": 9},
    },
    {
        "day": 14,
        "phase": "综合运用",
        "title": "先判断方法，再开始计算",
        "goal": "凑十、破十混合时不串方法，两步题按从左往右计算。",
        "support": "少量混合",
        "sections": [
            {
                "title": "凑十、破十各4题",
                "instruction": "先看运算符号：加法想“还差几到10”，减法想“10减几”。",
                "kind": "calculations",
                "items": [
                    calc("9＋4", 13, "凑十"),
                    calc("8＋7", 15, "凑十"),
                    calc("7＋6", 13, "凑十"),
                    calc("6＋8", 14, "凑十"),
                    calc("13－5", 8, "破十"),
                    calc("14－8", 6, "破十"),
                    calc("15－7", 8, "破十"),
                    calc("16－9", 7, "破十"),
                ],
            },
            {
                "title": "两步题从左往右算",
                "instruction": "每算完一步，把结果当成新的起点；今天只做2题。",
                "kind": "chains",
                "items": [
                    calc("8＋6－4", 10, "两步"),
                    calc("15－7＋6", 14, "两步"),
                ],
            },
        ],
        "challenge": [
            calc("9＋5－4", 10, "两步"),
            calc("14－6＋5", 13, "两步"),
            calc("7＋8－5", 10, "两步"),
        ],
        "example": {"kind": "chain", "expression": "15－7＋6", "steps": ["15－7＝8", "8＋6＝14"]},
    },
    {
        "day": 15,
        "phase": "最终复测",
        "title": "和第1天比一比",
        "goal": "正确率不下降，完整草稿明显减少，用时自然缩短。",
        "support": "独立完成",
        "sections": [
            {
                "title": "完成10道复测题",
                "instruction": "题型与第1天相当、数字不同。不要翻看旧题，完成后再比较记录。",
                "kind": "calculations",
                "mode": "final",
                "scored": True,
                "items": [
                    calc("3＋4", 7, "基础"),
                    calc("8－2", 6, "基础"),
                    calc("5＋5", 10, "双数"),
                    calc("10－7", 3, "补十"),
                    calc("9＋6", 15, "凑十"),
                    calc("8＋5", 13, "凑十"),
                    calc("13－6", 7, "破十"),
                    calc("14－8", 6, "破十"),
                    calc("7＋5", 12, "凑十"),
                    calc("12－3", 9, "破十"),
                ],
            },
        ],
        "challenge": [
            calc("8＋7－5", 10, "两步"),
            calc("15－8＋6", 13, "两步"),
            calc("9＋6－7", 8, "两步"),
        ],
        "example": {"kind": "final"},
    },
]


CHINESE_NUMERALS = ["一", "二", "三", "四", "五"]


def evaluate_expression(expression: str) -> int:
    tokens = re.findall(r"\d+|[＋－]", expression)
    if not tokens or not tokens[0].isdigit() or len(tokens) % 2 == 0:
        raise ValueError(f"无法计算表达式：{expression}")
    value = int(tokens[0])
    for operator, number_text in zip(tokens[1::2], tokens[2::2]):
        number = int(number_text)
        value = value + number if operator == "＋" else value - number
    return value


def section_calculations(section: dict[str, Any]) -> list[dict[str, Any]]:
    kind = section["kind"]
    if kind in {"calculations", "chains"}:
        return list(section["items"])
    if kind in {"guided_make", "minimal_make"}:
        return [
            calc(f"{left}＋{right}", left + right, "凑十")
            for left, right in section["items"]
        ]
    if kind in {"guided_break", "minimal_break"}:
        return [
            calc(f"{total}－{sub}", total - sub, "破十")
            for total, sub in section["items"]
        ]
    return []


def validate_curriculum(days: list[dict[str, Any]]) -> None:
    if len(days) != 15 or [day["day"] for day in days] != list(range(1, 16)):
        raise ValueError("训练内容必须完整包含第1—15天。")

    for day in days:
        if not day["sections"]:
            raise ValueError(f'第{day["day"]}天缺少训练内容。')
        scored_count = 0
        for section in day["sections"]:
            if section.get("scored"):
                scored_count += len(section_calculations(section))
            for item in section_calculations(section):
                actual = evaluate_expression(item["expression"])
                if actual != item["answer"]:
                    raise ValueError(
                        f'第{day["day"]}天答案错误：{item["expression"]}，'
                        f'标注{item["answer"]}，实际{actual}'
                    )
                if not 0 <= actual <= 20:
                    raise ValueError(f'第{day["day"]}天结果超出20以内：{item["expression"]}')

            if section["kind"] == "complements":
                if any(number < 1 or number > 9 for number in section["numbers"]):
                    raise ValueError("补十训练数字应在1—9。")
            if section["kind"] == "bonds":
                for item in section["items"]:
                    if item["left"] + item["right"] != item["total"]:
                        raise ValueError(f"数的分合不正确：{item}")
            if section["kind"] == "fact_families":
                for item in section["items"]:
                    if item["left"] + item["right"] != item["total"]:
                        raise ValueError(f"算式家庭不正确：{item}")
            if section["kind"] in {"guided_make", "minimal_make"}:
                for left, right in section["items"]:
                    need = 10 - left
                    if not 0 < need < right or left + right > 20:
                        raise ValueError(f"不适合凑十训练：{left}＋{right}")
            if section["kind"] in {"guided_break", "minimal_break"}:
                for total, sub in section["items"]:
                    ones = total - 10
                    if not 11 <= total <= 18 or sub <= ones or total - sub < 0:
                        raise ValueError(f"不适合破十训练：{total}－{sub}")

        for item in day["challenge"]:
            if evaluate_expression(item["expression"]) != item["answer"]:
                raise ValueError(f'脱稿挑战答案错误：{item["expression"]}')
        if day["day"] in {1, 5, 10, 15} and scored_count != 10:
            raise ValueError(f'第{day["day"]}天应有10道计分题，实际{scored_count}道。')


SPECIAL_CSS = base.PRINT_CSS + """
.mental-page {
  padding: 8mm 13mm 11mm;
  font-size: 11.6pt;
  line-height: 1.38;
}
.mental-page .paper-title {
  font-size: 20pt;
  letter-spacing: .04em;
}
.day-banner {
  display: grid;
  grid-template-columns: 25mm 1fr 35mm;
  align-items: center;
  gap: 3mm;
  margin: 2mm 0;
  padding: 2mm 3mm;
  border: 1.2pt solid #444;
  background: #f2f2f2;
}
.day-number { font-size: 14pt; font-weight: 800; }
.day-title { text-align: center; font-size: 13.5pt; font-weight: 800; }
.support-chip {
  padding: 1mm;
  border: 1pt solid #555;
  border-radius: 2mm;
  background: #fff;
  text-align: center;
  font-size: 9pt;
}
.mental-fields {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 5mm;
  margin: 1.5mm 0;
  font-size: 10.5pt;
}
.short-line {
  display: inline-block;
  width: 32mm;
  height: 5mm;
  border-bottom: 1pt solid #555;
  vertical-align: bottom;
}
.goal-box {
  margin: 1mm 0;
  padding: 1.3mm 2.5mm;
  border-left: 4pt solid #333;
  background: #fafafa;
  font-size: 10.5pt;
}
.mental-page .section { margin-top: 1.8mm; }
.mental-page .section h2 {
  margin-bottom: .8mm;
  padding: .9mm 2mm;
  font-size: 13.5pt;
}
.mental-page .instruction {
  margin-bottom: .8mm;
  font-size: 10pt;
}
.answer-square {
  display: inline-flex;
  width: 10mm;
  height: 10mm;
  align-items: center;
  justify-content: center;
  border: 1.3pt solid #222;
  background: #fff;
  vertical-align: middle;
}
.answer-square.small {
  width: 8.5mm;
  height: 8.5mm;
}
.complement-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 2mm;
}
.complement-card {
  padding: 2mm 1mm;
  border: 1pt dashed #888;
  text-align: center;
  font-size: 14pt;
  font-weight: 700;
}
.bond-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 2mm 5mm;
}
.bond-card {
  min-height: 13mm;
  padding: 1.5mm 3mm;
  border: 1pt solid #888;
  font-size: 15pt;
  font-weight: 700;
}
.calc-grid-mental {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 2mm 5mm;
}
.calc-grid-mental.five-col { grid-template-columns: repeat(5, 1fr); }
.calc-card {
  min-height: 12mm;
  padding: 1.3mm 1mm;
  border-bottom: 1pt dashed #aaa;
  font-size: 14pt;
  font-weight: 700;
  white-space: nowrap;
}
.draft-check {
  display: block;
  margin-top: .6mm;
  color: #555;
  font-size: 8.5pt;
  font-weight: 400;
}
.family-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 3mm;
}
.family-grid.oral-grid { grid-template-columns: 1fr; }
.family-card {
  padding: 2mm;
  border: 1.1pt solid #666;
  border-radius: 2mm;
  text-align: center;
  break-inside: avoid;
}
.family-numbers { margin-bottom: 1mm; font-size: 12pt; font-weight: 800; }
.family-equations {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1mm;
  font-size: 11.5pt;
}
.method-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2mm 5mm;
}
.guided-card {
  min-height: 45mm;
  padding: 1.2mm 2.5mm;
  border: 1pt solid #777;
  border-radius: 2mm;
  font-size: 11.2pt;
}
.guided-expression {
  font-size: 15pt;
  font-weight: 800;
  white-space: nowrap;
}
.vertical-method {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-start;
  text-align: center;
}
.split-tree {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 42mm;
  margin: .4mm auto;
}
.split-source {
  display: inline-flex;
  min-width: 9mm;
  min-height: 8mm;
  align-items: center;
  justify-content: center;
  font-size: 14pt;
  font-weight: 800;
}
.split-v {
  display: block;
  width: 32mm;
  height: 7mm;
  margin: -1mm auto 0;
}
.split-v path {
  fill: none;
  stroke: #222;
  stroke-width: 2.4;
  stroke-linecap: round;
}
.split-parts {
  display: flex;
  width: 38mm;
  align-items: center;
  justify-content: space-between;
  margin-top: -.7mm;
}
.split-value {
  display: inline-flex;
  min-width: 9mm;
  min-height: 8mm;
  align-items: center;
  justify-content: center;
  font-size: 13pt;
  font-weight: 800;
}
.vertical-down {
  height: 6mm;
  font-size: 15pt;
  font-weight: 800;
  line-height: 6mm;
}
.vertical-equation {
  min-height: 9mm;
  font-size: 12.5pt;
  font-weight: 700;
  white-space: nowrap;
}
.answer-vertical-method {
  width: 90mm;
  margin: 1mm auto;
  padding: 1.5mm 3mm;
  border: 1pt solid #999;
  background: #fff;
}
.answer-vertical-method .guided-expression { font-size: 16pt; }
.answer-vertical-method .vertical-equation { font-size: 14pt; }
.mini-vertical-method {
  display: inline-flex;
  flex-direction: column;
  align-items: center;
  min-width: 35mm;
  margin-left: 4mm;
  vertical-align: middle;
}
.mini-vertical-method .split-tree {
  width: 31mm;
  margin: 0;
}
.mini-vertical-method .split-source {
  min-height: 5mm;
  font-size: 10pt;
}
.mini-vertical-method .split-v {
  width: 24mm;
  height: 5mm;
}
.mini-vertical-method .split-parts {
  width: 30mm;
}
.mini-vertical-method .split-value {
  min-height: 6mm;
  font-size: 10pt;
}
.mini-vertical-method .answer-square.small {
  width: 7.5mm;
  height: 7.5mm;
}
.flow-diagram {
  display: block;
  width: 68mm;
  height: 42.5mm;
  margin: 0 auto;
}
.mini-flow-diagram {
  width: 49.6mm;
  height: 31mm;
}
.answer-flow-diagram {
  width: 96mm;
  height: 60mm;
}
.flow-line {
  fill: none;
  stroke: #222;
  stroke-width: 2.5;
  stroke-linecap: square;
  stroke-linejoin: miter;
}
.flow-box {
  fill: #fff;
  stroke: #222;
  stroke-width: 1.8;
}
.flow-diagram text {
  fill: #111;
  font-family: "Microsoft YaHei", "SimSun", sans-serif;
  text-anchor: middle;
}
.flow-number {
  font-size: 23px;
  font-weight: 800;
}
.flow-operator {
  font-size: 22px;
  font-weight: 800;
}
.flow-box-value {
  font-size: 21px;
  font-weight: 800;
}
.minimal-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2mm 6mm;
}
.minimal-card {
  min-height: 32mm;
  padding: .3mm 1mm;
  border-bottom: 1pt dashed #999;
  font-size: 14pt;
  font-weight: 700;
}
.mini-draft {
  display: block;
  margin-top: 1mm;
  color: #555;
  font-size: 9.5pt;
  font-weight: 400;
}
.chain-grid-mental {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 4mm;
}
.chain-card {
  min-height: 23mm;
  padding: 3mm;
  border: 1.2pt solid #555;
  font-size: 17pt;
  font-weight: 800;
}
.challenge-box {
  margin-top: 2mm;
  padding: 1.5mm 2.5mm;
  border: 1.3pt dashed #555;
  background: #fafafa;
}
.challenge-title { font-weight: 800; }
.challenge-items {
  display: flex;
  justify-content: space-around;
  gap: 3mm;
  margin-top: 1mm;
  font-size: 13pt;
  font-weight: 700;
}
.record-box {
  margin-top: 2mm;
  padding: 2mm 3mm;
  border: 1.4pt solid #333;
  background: #fff;
  font-size: 10pt;
}
.record-row {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  gap: 2mm 5mm;
}
.record-line {
  display: inline-block;
  min-width: 12mm;
  height: 4mm;
  border-bottom: 1pt solid #444;
  vertical-align: bottom;
}
.ten-frame {
  display: grid;
  grid-template-columns: repeat(5, 9mm);
  grid-template-rows: repeat(2, 9mm);
  width: 45mm;
  border-left: 1pt solid #333;
  border-top: 1pt solid #333;
  background: #fff;
}
.ten-cell {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  border-right: 1pt solid #333;
  border-bottom: 1pt solid #333;
}
.ten-dot,
.loose-dot {
  position: relative;
  display: inline-block;
  width: 5.5mm;
  height: 5.5mm;
  border: 1.2pt solid #111;
  border-radius: 50%;
  background: #fff;
}
.ten-dot.original { background: #222; }
.ten-dot.moved { background: #bbb; }
.ten-dot.crossed { background: #eee; }
.ten-dot.crossed::before,
.ten-dot.crossed::after {
  position: absolute;
  top: 2.2mm;
  left: -.6mm;
  width: 6.5mm;
  height: 1.2pt;
  content: "";
  background: #111;
  transform: rotate(45deg);
}
.ten-dot.crossed::after { transform: rotate(-45deg); }
.method-visual {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 5mm;
  margin: 1.5mm 0;
}
.loose-group {
  display: flex;
  flex-wrap: wrap;
  width: 34mm;
  gap: 2mm;
  align-items: center;
  justify-content: center;
}
.visual-label { text-align: center; font-size: 9.5pt; color: #444; }
.compact-flow {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: center;
  gap: 1.5mm;
  margin: 1.5mm 0;
}
.compact-node {
  padding: 1.5mm 2.5mm;
  border: 1pt solid #666;
  background: #fff;
  font-weight: 700;
}
.compact-arrow { font-size: 14pt; font-weight: 800; }
.bond-visual {
  width: 80mm;
  margin: 2mm auto;
  text-align: center;
}
.bond-total,
.bond-part {
  display: inline-flex;
  width: 17mm;
  height: 13mm;
  align-items: center;
  justify-content: center;
  border: 1.3pt solid #222;
  border-radius: 50%;
  background: #fff;
  font-size: 14pt;
  font-weight: 800;
}
.bond-branches {
  width: 48mm;
  height: 9mm;
  margin: 0 auto;
  border-left: 1.2pt solid #444;
  border-right: 1.2pt solid #444;
  border-top: 1.2pt solid #444;
}
.bond-parts {
  display: flex;
  justify-content: space-between;
  width: 65mm;
  margin: 0 auto;
}
.answer-page,
.guide-page {
  padding: 9mm 14mm 11mm;
  font-size: 10.5pt;
  line-height: 1.38;
}
.answer-page h1,
.guide-page h1 {
  margin: 0 0 2mm;
  padding-bottom: 1.5mm;
  border-bottom: 2pt solid #222;
  font-size: 20pt;
}
.answer-page h2,
.guide-page h2 {
  margin: 2.8mm 0 1.2mm;
  padding: 1mm 2mm;
  border-left: 4pt solid #222;
  background: #ededed;
  font-size: 14pt;
}
.answer-key-card {
  margin: 1mm 0;
  padding: 1.4mm 2.5mm;
  border: 1pt solid #aaa;
  background: #fff;
}
.answer-key-card p { margin: .5mm 0; }
.explain-card {
  padding: 2mm 3mm;
  border: 1.2pt solid #555;
  background: #f8f8f8;
  break-inside: avoid;
}
.diagnosis-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2mm 4mm;
}
.diagnosis-card {
  padding: 2mm 2.5mm;
  border: 1pt dashed #777;
  background: #fafafa;
}
.error-tag {
  display: inline-block;
  min-width: 18mm;
  margin-right: 1mm;
  padding: .4mm 1.5mm;
  border: 1pt solid #555;
  border-radius: 2mm;
  font-weight: 800;
  text-align: center;
}
.score-band {
  margin: 1mm 0;
  padding: 1.5mm 2.5mm;
  border: 1pt dashed #777;
}
.thinking-steps {
  margin: 1mm 0;
  padding-left: 7mm;
}
.thinking-steps li { margin: .8mm 0; }
.mental-answer-cover {
  padding: 30mm 24mm;
  text-align: center;
}
.mental-answer-cover h1 {
  margin: 36mm 0 4mm;
  font-size: 28pt;
}
.mental-answer-cover h2 {
  margin: 0;
  font-size: 17pt;
  font-weight: 500;
}
.cover-note {
  margin-top: 25mm;
  padding: 6mm;
  border: 1.2pt solid #444;
  background: #f5f5f5;
  text-align: left;
  font-size: 11pt;
  line-height: 1.6;
}
.schedule-list {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.5mm 4mm;
}
.schedule-item {
  padding: 1.2mm 2mm;
  border-bottom: 1pt dashed #aaa;
}
"""


def answer_square(*, small: bool = False) -> str:
    class_name = "answer-square small" if small else "answer-square"
    return f'<span class="{class_name}"></span>'


def ten_frame(cells: list[str]) -> str:
    rendered = []
    for state in cells:
        dot = f'<span class="ten-dot {state}"></span>' if state else ""
        rendered.append(f'<span class="ten-cell">{dot}</span>')
    return f'<div class="ten-frame">{"".join(rendered)}</div>'


def complement_visual(number: int) -> str:
    states = ["original" if index < number else "" for index in range(10)]
    need = 10 - number
    return f"""
      <div class="explain-card">
        <strong>图解：{number}还差几到10？</strong>
        <div class="method-visual">
          <div>{ten_frame(states)}<div class="visual-label">已有{number}个，空着{need}格</div></div>
          <div class="compact-flow">
            <span class="compact-node">{number}</span>
            <span class="compact-arrow">＋</span>
            <span class="compact-node">{need}</span>
            <span class="compact-arrow">＝</span>
            <span class="compact-node">10</span>
          </div>
        </div>
        <p>不要从{number}继续一个一个数。看十格图的空格，直接知道还差<strong>{need}</strong>。</p>
      </div>
    """


def split_tree_html(
    source: int,
    left_html: str,
    right_html: str,
    *,
    compact: bool = False,
) -> str:
    class_name = "split-tree compact-split-tree" if compact else "split-tree"
    return f"""
      <div class="{class_name}">
        <div class="split-source">{source}</div>
        <svg class="split-v" viewBox="0 0 100 30" aria-hidden="true">
          <path d="M50 1 L22 29 M50 1 L78 29"></path>
        </svg>
        <div class="split-parts">
          <span class="split-value">{left_html}</span>
          <span class="split-value">{right_html}</span>
        </div>
      </div>
    """


def svg_value_box(
    x: int,
    y: int,
    value: int | None,
    *,
    width: int = 48,
    height: int = 34,
) -> str:
    value_text = (
        f'<text class="flow-box-value" x="{x + width / 2:g}" '
        f'y="{y + height * 0.7:g}">{value}</text>'
        if value is not None
        else ""
    )
    return (
        f'<rect class="flow-box" x="{x}" y="{y}" width="{width}" height="{height}" rx="3"></rect>'
        f"{value_text}"
    )


def make_flow_svg(
    left: int,
    right: int,
    *,
    filled: bool,
    compact: bool = False,
) -> str:
    need = 10 - left
    rest = right - need
    result = left + right
    class_name = "flow-diagram mini-flow-diagram" if compact else "flow-diagram"
    if filled:
        class_name += " answer-flow-diagram"
    part_need = need if filled else None
    part_rest = rest if filled else None
    final_value = result if filled else None
    return f"""
      <svg class="{class_name}" viewBox="0 0 320 200" role="img"
           aria-label="{left}加{right}凑十计算关系图">
        <path class="flow-line" d="M125 36 L101 65 M125 36 L164 65"></path>
        <path class="flow-line" d="M55 37 V112 H70 V125 M101 99 V112 H78 V125"></path>
        <path class="flow-line" d="M70 159 V168 H126 M164 99 V168 H126"></path>
        <path class="flow-line" d="M126 168 V190 H281 V23 H253"></path>

        <text class="flow-number" x="55" y="31">{left}</text>
        <text class="flow-operator" x="91" y="31">＋</text>
        <text class="flow-number" x="125" y="31">{right}</text>
        <text class="flow-operator" x="180" y="31">＝</text>
        {svg_value_box(205, 6, final_value)}

        {svg_value_box(78, 65, part_need, width=46)}
        {svg_value_box(141, 65, part_rest, width=46)}
        <text class="flow-operator" x="89" y="108">＋</text>
        {svg_value_box(48, 125, 10, width=44)}
        <text class="flow-operator" x="115" y="163">＋</text>
      </svg>
    """


def break_flow_svg(
    total: int,
    sub: int,
    *,
    filled: bool,
    compact: bool = False,
    show_parts: bool = False,
) -> str:
    ones = total - 10
    ten_rest = 10 - sub
    result = total - sub
    class_name = "flow-diagram mini-flow-diagram" if compact else "flow-diagram"
    if filled:
        class_name += " answer-flow-diagram"
    left_part = ones if filled or show_parts else None
    right_part = 10 if filled or show_parts else None
    middle_value = ten_rest if filled else None
    final_value = result if filled else None
    return f"""
      <svg class="{class_name}" viewBox="0 0 320 200" role="img"
           aria-label="{total}减{sub}破十计算关系图">
        <path class="flow-line" d="M55 36 L42 65 M55 36 L104 65"></path>
        <path class="flow-line" d="M104 99 V112 H126 V125 M125 36 V112"></path>
        <path class="flow-line" d="M42 99 V168 H126 M126 159 V168"></path>
        <path class="flow-line" d="M126 168 V190 H281 V23 H253"></path>

        <text class="flow-number" x="55" y="31">{total}</text>
        <text class="flow-operator" x="91" y="31">－</text>
        <text class="flow-number" x="125" y="31">{sub}</text>
        <text class="flow-operator" x="180" y="31">＝</text>
        {svg_value_box(205, 6, final_value)}

        {svg_value_box(19, 65, left_part, width=46)}
        {svg_value_box(81, 65, right_part, width=46)}
        <text class="flow-operator" x="145" y="108">－</text>
        {svg_value_box(103, 125, middle_value, width=46)}
        <text class="flow-operator" x="88" y="163">＋</text>
      </svg>
    """


def make_ten_visual(left: int, right: int) -> str:
    return f"""
      <div class="explain-card">
        <strong>凑十简图</strong>
        {make_flow_svg(left, right, filled=True)}
      </div>
    """


def break_ten_visual(total: int, sub: int) -> str:
    return f"""
      <div class="explain-card">
        <strong>破十简图</strong>
        {break_flow_svg(total, sub, filled=True)}
      </div>
    """


def bond_visual(total: int, left: int, right: int) -> str:
    return f"""
      <div class="explain-card">
        <strong>数的分合图：总数与两部分</strong>
        <div class="bond-visual">
          <div class="bond-total">{total}</div>
          <div class="bond-branches"></div>
          <div class="bond-parts">
            <span class="bond-part">{left}</span>
            <span class="bond-part">{right}</span>
          </div>
        </div>
        <div class="compact-flow">
          <span class="compact-node">{left}＋{right}＝{total}</span>
          <span class="compact-node">{right}＋{left}＝{total}</span>
          <span class="compact-node">{total}－{left}＝{right}</span>
          <span class="compact-node">{total}－{right}＝{left}</span>
        </div>
      </div>
    """


def flow_visual(nodes: list[str], title: str) -> str:
    flow = '<span class="compact-arrow">→</span>'.join(
        f'<span class="compact-node">{base.esc(node)}</span>' for node in nodes
    )
    return f"""
      <div class="explain-card">
        <strong>{base.esc(title)}</strong>
        <div class="compact-flow">{flow}</div>
      </div>
    """


def render_complements(section: dict[str, Any]) -> str:
    cards = "".join(
        f'<div class="complement-card">{number}＋{answer_square()}＝10</div>'
        for number in section["numbers"]
    )
    return f'<div class="complement-grid">{cards}</div>'


def render_bonds(section: dict[str, Any]) -> str:
    cards = "".join(
        f'<div class="bond-card">{item["total"]}＝{item["left"]}＋{answer_square()}</div>'
        for item in section["items"]
    )
    return f'<div class="bond-grid">{cards}</div>'


def render_calculations(section: dict[str, Any]) -> str:
    draft_mode = section.get("mode") in {"baseline", "final"}
    cards = "".join(
        f"""
        <div class="calc-card">
          {base.esc(item["expression"])}＝{answer_square()}
          {'<span class="draft-check">用了完整草稿：□</span>' if draft_mode else ''}
        </div>
        """
        for item in section["items"]
    )
    column_class = " five-col" if len(section["items"]) in {5, 10} else ""
    return f'<div class="calc-grid-mental{column_class}">{cards}</div>'


def render_fact_families(section: dict[str, Any]) -> str:
    cards = []
    for item in section["items"]:
        left, right, total = item["left"], item["right"], item["total"]
        cards.append(
            f"""
            <div class="family-card">
              <div class="family-numbers">三个数：{left}、{right}、{total}</div>
              <div class="family-equations">
                <span>{left}＋{right}＝{answer_square(small=True)}</span>
                <span>{right}＋{left}＝{answer_square(small=True)}</span>
                <span>{total}－{left}＝{answer_square(small=True)}</span>
                <span>{total}－{right}＝{answer_square(small=True)}</span>
              </div>
            </div>
            """
        )
    oral_class = " oral-grid" if section.get("oral") else ""
    return f'<div class="family-grid{oral_class}">{"".join(cards)}</div>'


def render_guided_make(section: dict[str, Any]) -> str:
    cards = []
    for left, right in section["items"]:
        cards.append(
            f"""
            <div class="guided-card">
              {make_flow_svg(left, right, filled=False)}
            </div>
            """
        )
    return f'<div class="method-grid">{"".join(cards)}</div>'


def render_guided_break(section: dict[str, Any]) -> str:
    cards = []
    for total, sub in section["items"]:
        cards.append(
            f"""
            <div class="guided-card">
              {break_flow_svg(total, sub, filled=False)}
            </div>
            """
        )
    return f'<div class="method-grid">{"".join(cards)}</div>'


def render_minimal_make(section: dict[str, Any]) -> str:
    cards = []
    for left, right in section["items"]:
        cards.append(
            f"""
            <div class="minimal-card">
              {make_flow_svg(left, right, filled=False, compact=True)}
            </div>
            """
        )
    return f'<div class="minimal-grid">{"".join(cards)}</div>'


def render_minimal_break(section: dict[str, Any]) -> str:
    cards = []
    for total, sub in section["items"]:
        cards.append(
            f"""
            <div class="minimal-card">
              {break_flow_svg(total, sub, filled=False, compact=True, show_parts=True)}
            </div>
            """
        )
    return f'<div class="minimal-grid">{"".join(cards)}</div>'


def render_chains(section: dict[str, Any]) -> str:
    cards = "".join(
        f'<div class="chain-card">{base.esc(item["expression"])}＝{answer_square()}</div>'
        for item in section["items"]
    )
    return f'<div class="chain-grid-mental">{cards}</div>'


def render_section_content(section: dict[str, Any]) -> str:
    renderers = {
        "complements": render_complements,
        "bonds": render_bonds,
        "calculations": render_calculations,
        "fact_families": render_fact_families,
        "guided_make": render_guided_make,
        "guided_break": render_guided_break,
        "minimal_make": render_minimal_make,
        "minimal_break": render_minimal_break,
        "chains": render_chains,
    }
    return renderers[section["kind"]](section)


def scored_item_count(day: dict[str, Any]) -> int:
    return sum(
        len(section_calculations(section))
        for section in day["sections"]
        if section.get("scored")
    )


def render_challenge(day: dict[str, Any]) -> str:
    items = "　".join(
        f'{base.esc(item["expression"])}＝{answer_square(small=True)}'
        for item in day["challenge"]
    )
    return f"""
      <div class="challenge-box">
        <div class="challenge-title">脱稿小挑战：盖住上面的草稿区，只在心里算</div>
        <div class="challenge-items">{items}</div>
      </div>
    """


def render_record(day: dict[str, Any]) -> str:
    scored = scored_item_count(day)
    score_label = f"计分题正确：____ / {scored}" if scored else "今天独立做对：____题"
    return f"""
      <div class="record-box">
        <div class="record-row">
          <span><strong>训练记录</strong></span>
          <span>{score_label}</span>
          <span>完整草稿：<span class="record-line"></span>题</span>
          <span>用时：<span class="record-line"></span>分<span class="record-line"></span>秒</span>
        </div>
        <div class="record-row" style="margin-top:1mm">
          <span>第一步：□能独立说　□提示后能说　□暂时不会</span>
          <span>今天感受：□轻松　□刚刚好　□有点难</span>
          <span>家长签字：____________</span>
        </div>
      </div>
    """


def render_daily_page(day: dict[str, Any]) -> str:
    sections = []
    for index, section in enumerate(day["sections"]):
        sections.append(
            f"""
            <div class="section">
              <h2>{CHINESE_NUMERALS[index]}、{base.esc(section["title"])}</h2>
              <p class="instruction">{base.esc(section["instruction"])}</p>
              {render_section_content(section)}
            </div>
            """
        )
    return f"""
    <section class="page mental-page">
      <h1 class="paper-title">一年级心算脱稿15天训练</h1>
      <div class="day-banner">
        <span class="day-number">第{day["day"]:02d}天</span>
        <span class="day-title">{base.esc(day["title"])}</span>
        <span class="support-chip">{base.esc(day["support"])}</span>
      </div>
      <div class="mental-fields">
        <div>姓名：<span class="short-line"></span></div>
        <div>日期：<span class="short-line"></span></div>
        <div>开始时间：<span class="short-line"></span></div>
      </div>
      <div class="goal-box"><strong>今日目标：</strong>{base.esc(day["goal"])}</div>
      {"".join(sections)}
      {render_challenge(day)}
      {render_record(day)}
      <div class="page-footer">
        <span>每天12—15分钟 · 正确优先 · 草稿逐步减少</span>
        <span>第{day["day"]:02d}天 / 共15天</span>
      </div>
    </section>
    """


def render_training_html(days: list[dict[str, Any]]) -> str:
    pages = "".join(render_daily_page(day) for day in days)
    return f"""<!doctype html>
    <html lang="zh-CN">
      <head>
        <meta charset="utf-8">
        <title>一年级心算脱稿15天训练册</title>
        <style>{SPECIAL_CSS}</style>
      </head>
      <body>{pages}</body>
    </html>"""


def section_answer_text(section: dict[str, Any]) -> str:
    kind = section["kind"]
    if kind == "complements":
        return "；".join(f"{number}的补数是{10 - number}" for number in section["numbers"])
    if kind == "bonds":
        return "；".join(
            f'{item["total"]}＝{item["left"]}＋{item["right"]}'
            for item in section["items"]
        )
    if kind == "fact_families":
        families = []
        for item in section["items"]:
            left, right, total = item["left"], item["right"], item["total"]
            families.append(
                f"{left}＋{right}＝{total}，{right}＋{left}＝{total}，"
                f"{total}－{left}＝{right}，{total}－{right}＝{left}"
            )
        return "；".join(families)
    if kind in {"guided_make", "minimal_make"}:
        answers = []
        for left, right in section["items"]:
            need = 10 - left
            rest = right - need
            answers.append(
                f"{left}＋{right}＝{left + right}（{right}→{need}、{rest}）"
            )
        return "；".join(answers)
    if kind in {"guided_break", "minimal_break"}:
        answers = []
        for total, sub in section["items"]:
            ones = total - 10
            ten_rest = 10 - sub
            answers.append(
                f"{total}－{sub}＝{total - sub}（10－{sub}＝{ten_rest}，"
                f"{ten_rest}＋{ones}＝{total - sub}）"
            )
        return "；".join(answers)
    return "；".join(
        f'{item["expression"]}＝{item["answer"]}' for item in section["items"]
    )


def checkpoint_bands(stage: int) -> str:
    focus = "10以内基础" if stage == 1 else "凑十法"
    return f"""
      <div class="score-band"><strong>10题对9—10题：</strong>{focus}达到本轮要求，可以继续。</div>
      <div class="score-band"><strong>10题对8题：</strong>增加1—2天同类型训练，再进入下一阶段。</div>
      <div class="score-band"><strong>10题对7题及以下：</strong>暂不计时，回到图示或分合练习。</div>
      <div class="score-band"><strong>正确但草稿超过2题：</strong>方法会用，提取还不熟；继续练“最小草稿→口述”。</div>
    """


def render_example(day: dict[str, Any]) -> str:
    example = day["example"]
    kind = example["kind"]
    if kind == "baseline":
        return """
        <div class="explain-card">
          <strong>第1天只做诊断，不按快慢评价</strong>
          <p>把10道题分成“基础、凑十、破十”三类。哪一类完整草稿最多，后面就重点观察哪一类。
          如果答错但能自己发现并改正，记录为“自我纠正”，不要算成完全不会。</p>
        </div>
        """
    if kind == "complement":
        return complement_visual(example["number"])
    if kind == "near_double":
        left, right = example["left"], example["right"]
        return flow_visual(
            [f"{left}＋{left}＝{left * 2}", f"再加1", f"{left}＋{right}＝{left + right}"],
            f"相邻双数：{left}＋{right}",
        )
    if kind == "family":
        return bond_visual(example["total"], example["left"], example["right"])
    if kind == "checkpoint":
        return f"""
        <div class="explain-card">
          <strong>第{example["stage"]}次检查怎么看</strong>
          {checkpoint_bands(example["stage"])}
          <p>升级要同时看正确率和草稿数，不能只看用时。</p>
        </div>
        """
    if kind == "make":
        return make_ten_visual(example["left"], example["right"])
    if kind == "checkpoint_make":
        return make_ten_visual(example["left"], example["right"]) + checkpoint_bands(2)
    if kind == "break":
        return break_ten_visual(example["total"], example["sub"])
    if kind == "chain":
        return flow_visual(example["steps"], f'两步题：{example["expression"]}')
    if kind == "final":
        return """
        <div class="explain-card">
          <strong>最终比较只看自己的变化</strong>
          <ol class="thinking-steps">
            <li>先比较正确数：第15天不能因为追求速度而错得更多。</li>
            <li>再比较完整草稿数：比第1天减少，说明方法正在内化。</li>
            <li>最后比较用时：在正确率稳定的前提下缩短才有意义。</li>
          </ol>
        </div>
        """
    raise ValueError(f"未知示例类型：{kind}")


def diagnosis_for_day(day_number: int) -> tuple[str, list[str]]:
    if day_number == 1:
        return (
            "先找薄弱类型",
            [
                "基础题也逐个数：优先回练第2—4天。",
                "凑十题会写过程但很慢：重点完成第6—10天。",
                "破十题漏加个位数：重点观察第11—13天。",
            ],
        )
    if day_number <= 2:
        return (
            "补数提取不熟",
            [
                "把错的补数做成一对卡片，例如“8—2”。",
                "当天隔10分钟再口答一次，第二天开始前再答一次。",
                "答不出时先看十格图，不要求机械背诵整张表。",
            ],
        )
    if day_number <= 4:
        return (
            "仍在逐个计数",
            [
                "先找加1、加2、双数或同一组分合，不从1开始数。",
                "同一组数只保留一道错题，口头说出另外三道算式。",
                "第二天先复习3道错题，不整页重做。",
            ],
        )
    if day_number == 5:
        return (
            "第1阶段检查",
            [
                "9—10题正确：进入第6天。",
                "8题正确：加练1—2天10以内同类题。",
                "7题及以下：回到第2—4天对应薄弱项，不开始限时。",
            ],
        )
    if day_number <= 8:
        return (
            "凑十第一步不稳定",
            [
                "先问“第一个数还差几到10”，不要直接问最终答案。",
                "检查第二个加数拆开的两部分能否重新合回去。",
                "只重做一种开头的题，如只练8加几，不把9、8、7混在一起。",
            ],
        )
    if day_number <= 10:
        return (
            "完整过程会写，但还不能脱稿",
            [
                "把草稿缩成一次拆分，不突然拿走纸笔。",
                "先口述一题，再静默做一题，交替进行。",
                "正确率低于80%时恢复图示，不继续压缩时间。",
            ],
        )
    if day_number <= 13:
        return (
            "破十步骤占用工作记忆",
            [
                "固定说法：“十减几得几，再加个位数”。",
                "如果漏加个位数，只重做最后一步，不抄整条算式。",
                "同一天固定一种算法，不在破十法和平十法之间频繁切换。",
            ],
        )
    if day_number == 14:
        return (
            "混合时方法串线",
            [
                "先圈运算符，再说凑十或破十，最后计算。",
                "两步题每次只算一步，把中间结果当成新起点。",
                "若单步题错得多，暂停两步题，回到对应专项。",
            ],
        )
    return (
        "按结果决定下一轮",
        [
            "正确率达90%、完整草稿不超过2题：进入日常保持，每天5分钟即可。",
            "正确但草稿多：再练第9、12、13天的脱稿环节。",
            "某一方法连续错2题以上：回到对应图示日，不继续加量。",
        ],
    )


def render_daily_answer(day: dict[str, Any]) -> str:
    answer_cards = "".join(
        f"""
        <div class="answer-key-card">
          <strong>{CHINESE_NUMERALS[index]}、{base.esc(section["title"])}</strong>
          <p>{base.esc(section_answer_text(section))}。</p>
        </div>
        """
        for index, section in enumerate(day["sections"])
    )
    challenge_answers = "；".join(
        f'{item["expression"]}＝{item["answer"]}' for item in day["challenge"]
    )
    diagnosis_title, correction_steps = diagnosis_for_day(day["day"])
    corrections = "".join(f"<li>{base.esc(step)}</li>" for step in correction_steps)
    return f"""
    <section class="page answer-page">
      <h1>第{day["day"]:02d}天答案与指导</h1>
      <div class="goal-box"><strong>{base.esc(day["phase"])}：</strong>{base.esc(day["title"])}</div>

      <h2>标准答案</h2>
      {answer_cards}
      <div class="answer-key-card"><strong>脱稿小挑战：</strong>{base.esc(challenge_answers)}。</div>

      <h2>重点方法与图解</h2>
      {render_example(day)}

      <h2>错题怎么订正</h2>
      <div class="diagnosis-card">
        <span class="error-tag">{base.esc(diagnosis_title)}</span>
        <ol class="thinking-steps">{corrections}</ol>
      </div>
      <div class="page-footer">
        <span>只订正典型错题 · 不抄整页 · 第二天先复习3分钟</span>
        <span>答案第{day["day"]:02d}天</span>
      </div>
    </section>
    """


def render_guide_pages(days: list[dict[str, Any]]) -> str:
    schedule = "".join(
        f'<div class="schedule-item"><strong>第{day["day"]:02d}天</strong>　{base.esc(day["title"])}</div>'
        for day in days
    )
    page_one = f"""
    <section class="page guide-page">
      <h1>家长使用说明（一）</h1>
      <h2>每天12—15分钟怎样安排</h2>
      <ol class="thinking-steps">
        <li><strong>2分钟口头热身：</strong>只说答案，不抄题。</li>
        <li><strong>5—7分钟当天主练：</strong>先保证方法正确，再逐步撤掉图和草稿。</li>
        <li><strong>2分钟脱稿挑战：</strong>盖住草稿区，完成3—4道熟悉题。</li>
        <li><strong>2—3分钟记录与订正：</strong>只选一道典型错题，说清第一步。</li>
      </ol>

      <h2>草稿不是一下子拿走的</h2>
      <div class="compact-flow">
        <span class="compact-node">十格图或实物</span>
        <span class="compact-arrow">→</span>
        <span class="compact-node">只写一次拆分</span>
        <span class="compact-arrow">→</span>
        <span class="compact-node">口述步骤</span>
        <span class="compact-arrow">→</span>
        <span class="compact-node">静默心算</span>
      </div>
      <p>突然禁止草稿会同时增加计算和记忆负担。训练目标是让草稿越来越短，而不是让孩子在不会时硬猜。</p>

      <h2>家长只问关键问题</h2>
      <div class="diagnosis-grid">
        <div class="diagnosis-card"><span class="error-tag">凑十</span>第一个数还差几到10？这几个从哪里拿？拿走后还剩几？</div>
        <div class="diagnosis-card"><span class="error-tag">破十</span>十几可以看成10和几？10减几是多少？哪个个位数还要加回来？</div>
        <div class="diagnosis-card"><span class="error-tag">两步</span>第一步算什么？第一步的结果是多少？新的起点是什么？</div>
        <div class="diagnosis-card"><span class="error-tag">卡住</span>等待3—5秒，只提示第一步，不直接报最终答案。</div>
      </div>

      <h2>15天进度</h2>
      <div class="schedule-list">{schedule}</div>
      <div class="page-footer">
        <span>正确优先 · 方法稳定 · 最后才提高速度</span>
        <span>家长指导 1/2</span>
      </div>
    </section>
    """
    page_two = """
    <section class="page guide-page">
      <h1>家长使用说明（二）</h1>
      <h2>每天记录三项，比只看用时更有效</h2>
      <div class="diagnosis-grid">
        <div class="diagnosis-card"><span class="error-tag">A 正确</span>10题做对几题；自我纠正可以另做记号。</div>
        <div class="diagnosis-card"><span class="error-tag">D 草稿</span>有几题需要完整草稿；只写一次拆分不算完整草稿。</div>
        <div class="diagnosis-card"><span class="error-tag">F 第一步</span>能否独立说出第一步；这比偶然答对更能说明方法是否稳定。</div>
        <div class="diagnosis-card"><span class="error-tag">T 用时</span>最后比较，不设统一硬指标；熟悉题每题3—5秒仅作参考。</div>
      </div>

      <h2>第5、10、15天如何决定是否继续</h2>
      <div class="score-band"><strong>9—10题正确，完整草稿不超过2题：</strong>进入下一阶段。</div>
      <div class="score-band"><strong>8题正确：</strong>增加1—2天同类型训练，再继续。</div>
      <div class="score-band"><strong>7题及以下：</strong>退回图示或拆分，不开始限时。</div>
      <div class="score-band"><strong>明显紧张、猜答或错误突然增多：</strong>当天停止，第二天减半题量。</div>

      <h2>四类常见错误</h2>
      <div class="diagnosis-grid">
        <div class="diagnosis-card"><span class="error-tag">C 补数</span>8还差几到10不能快速提取。回练第2天。</div>
        <div class="diagnosis-card"><span class="error-tag">M 方法</span>不知道拆谁，或拆开的数合不回去。回练第6—8天。</div>
        <div class="diagnosis-card"><span class="error-tag">R 还原</span>破十后忘记把个位数加回来。回练第11天图解。</div>
        <div class="diagnosis-card"><span class="error-tag">W 记忆</span>步骤会说但一心算就丢失。使用第9、12天的最小草稿。</div>
      </div>

      <h2>不要这样训练</h2>
      <ul class="thinking-steps">
        <li>不要说“这么简单怎么还要写”，也不要突然禁止手指和草稿。</li>
        <li>不要同一天大量混练凑十、破十和三步题。</li>
        <li>不要用错误率换速度；连续错2题时应停下来查第一步。</li>
        <li>不要整页罚抄。只保留一道典型错题，隔10分钟和第二天各重做一次。</li>
        <li>若学校尚未学习20以内退位减法，第11—13天只看图理解，不做限时要求。</li>
      </ul>

      <h2>15天后的保持方法</h2>
      <p>达标后每天5分钟即可：1分钟补十、2分钟6道混合题、1分钟一道两步题、1分钟复习昨天错题。
      若某类题的完整草稿重新增多，回到对应的图示日训练2天。</p>
      <div class="page-footer">
        <span>比较第15天和第1天，不与同学比较</span>
        <span>家长指导 2/2</span>
      </div>
    </section>
    """
    return page_one + page_two


def render_answer_html(days: list[dict[str, Any]]) -> str:
    cover = """
    <section class="page mental-answer-cover">
      <h1>一年级心算脱稿15天训练</h1>
      <h2>答案、图解与家长指导</h2>
      <div class="cover-note">
        <p><strong>训练路径：</strong>十格图或实物 → 只写一次拆分 → 口述步骤 → 静默心算。</p>
        <p><strong>评价顺序：</strong>先看正确率，再看完整草稿题数，最后才比较用时。</p>
        <p><strong>使用要求：</strong>孩子先独立完成当天一页，家长再查看对应答案；
        不边做边报答案，不要求整页重抄。</p>
        <p><strong>进度提醒：</strong>15天用于建立稳定方法和减少草稿，不承诺所有算式都在15天内自动化。
        检查日未达到要求时，应增加1—2天同类练习。</p>
      </div>
      <div class="page-footer">
        <span>适合一年级 · 20以内心算 · 黑白A4打印</span>
        <span>答案册</span>
      </div>
    </section>
    """
    guides = render_guide_pages(days)
    answers = "".join(render_daily_answer(day) for day in days)
    return f"""<!doctype html>
    <html lang="zh-CN">
      <head>
        <meta charset="utf-8">
        <title>一年级心算脱稿15天答案与家长指导</title>
        <style>{SPECIAL_CSS}</style>
      </head>
      <body>{cover}{guides}{answers}</body>
    </html>"""


async def build_pdfs(days: list[dict[str, Any]]) -> None:
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
            render_training_html(days),
            TRAINING_PDF,
            expect_fixed_pages=True,
        )
        print(f"generated {TRAINING_PDF.name}: {TRAINING_PDF.stat().st_size:,} bytes")

        await base.render_pdf(
            page,
            render_answer_html(days),
            ANSWER_PDF,
            expect_fixed_pages=True,
        )
        print(f"generated {ANSWER_PDF.name}: {ANSWER_PDF.stat().st_size:,} bytes")
        await browser.close()


def pdf_report(path: Path) -> tuple[int, bool, str, int, int]:
    document = fitz.open(path)
    try:
        is_a4 = all(
            abs(page.rect.width - 595.276) < 1
            and abs(page.rect.height - 841.89) < 1
            for page in document
        )
        text = "".join(page.get_text() for page in document)
        drawings = sum(len(page.get_drawings()) for page in document)
        outside_blocks = 0
        for page in document:
            for block in page.get_text("blocks"):
                x0, y0, x1, y1 = block[:4]
                if (
                    x0 < -1
                    or y0 < -1
                    or x1 > page.rect.width + 1
                    or y1 > page.rect.height + 1
                ):
                    outside_blocks += 1
        return len(document), is_a4, text, drawings, outside_blocks
    finally:
        document.close()


def validate_outputs(days: list[dict[str, Any]]) -> None:
    for path in (TRAINING_PDF, ANSWER_PDF):
        if not path.exists():
            raise RuntimeError(f"缺少PDF文件：{path.name}")
        if path.read_bytes()[:5] != b"%PDF-":
            raise RuntimeError(f"不是有效PDF：{path.name}")
        if path.stat().st_size < 20_000:
            raise RuntimeError(f"PDF文件过小，可能生成失败：{path.name}")

    training_pages, training_a4, training_text, training_drawings, training_outside = pdf_report(TRAINING_PDF)
    if training_pages != 15 or not training_a4 or training_outside:
        raise RuntimeError(
            f"训练册页面异常：页数={training_pages}，A4={training_a4}，越界={training_outside}"
        )
    for day in days:
        marker = f'第{day["day"]:02d}天'
        if marker not in training_text:
            raise RuntimeError(f"训练册缺少{marker}。")
    for marker in ("完整草稿", "脱稿小挑战", "第一步", "家长签字"):
        if training_text.count(marker) < 15:
            raise RuntimeError(f"训练册每日结构不完整：{marker}")

    answer_pages, answer_a4, answer_text, answer_drawings, answer_outside = pdf_report(ANSWER_PDF)
    if answer_pages != 18 or not answer_a4 or answer_outside:
        raise RuntimeError(
            f"答案册页面异常：页数={answer_pages}，A4={answer_a4}，越界={answer_outside}"
        )
    for marker in ("家长使用说明（一）", "家长使用说明（二）", "凑十简图", "破十简图"):
        if marker not in answer_text:
            raise RuntimeError(f"答案册缺少关键内容：{marker}")
    for day in days:
        marker = f'第{day["day"]:02d}天答案与指导'
        if marker not in answer_text:
            raise RuntimeError(f"答案册缺少{marker}。")

    print(
        json.dumps(
            {
                "training_days": len(days),
                "training": {
                    "file": TRAINING_PDF.name,
                    "pages": training_pages,
                    "drawings": training_drawings,
                },
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
    validate_curriculum(DAYS)
    await build_pdfs(DAYS)
    validate_outputs(DAYS)


if __name__ == "__main__":
    asyncio.run(main())
