from __future__ import annotations

import asyncio
import json
import re
from pathlib import Path
from typing import Any

from playwright.async_api import async_playwright

import generate_grade1_papers as base


ROOT = Path(__file__).resolve().parent
ANSWER_PDF = ROOT / "一年级20以内凑十破十综合练习_规范排版版_答案与详细图解.pdf"
PAPER_COUNT = 5
PAPER_PAGES = 3

LEVELS = [
    "基础入门",
    "基础进阶",
    "综合运用",
    "思维提升",
    "拓展挑战",
]

CARRY_BANK: list[list[tuple[int, int]]] = [
    [(9, 2), (8, 3), (7, 4), (6, 5), (9, 3)],
    [(8, 4), (7, 5), (6, 6), (9, 4), (8, 5)],
    [(7, 6), (6, 7), (9, 5), (8, 6), (7, 7)],
    [(6, 8), (9, 6), (8, 7), (7, 8), (6, 9)],
    [(9, 7), (8, 8), (7, 9), (9, 8), (9, 9)],
]

BORROW_BANK: list[list[tuple[int, int]]] = [
    [(11, 2), (12, 3), (13, 5), (14, 6), (15, 7)],
    [(12, 5), (13, 4), (14, 8), (15, 6), (16, 7)],
    [(13, 6), (14, 5), (15, 9), (16, 8), (17, 9)],
    [(14, 7), (15, 8), (16, 9), (17, 8), (18, 9)],
    [(11, 5), (12, 6), (13, 7), (14, 9), (18, 8)],
]

NUMBER_PATTERNS = [
    {
        "full": [2, 4, 6, 8, 10, 12],
        "shown": [2, 4, 6, 8, None, None],
        "rule": "每次加2",
        "explanation": "2到4加2，4到6也加2，所以继续用“加2”：8＋2＝10，10＋2＝12。",
    },
    {
        "full": [20, 17, 14, 11, 8, 5],
        "shown": [20, 17, 14, 11, None, None],
        "rule": "每次减3",
        "explanation": "相邻两个数都相差3，所以11－3＝8，8－3＝5。",
    },
    {
        "full": [2, 3, 5, 6, 8, 9],
        "shown": [2, 3, 5, 6, None, None],
        "rule": "依次加1、加2，重复进行",
        "explanation": "2＋1＝3，3＋2＝5，5＋1＝6；接下来应先加2得8，再加1得9。",
    },
    {
        "full": [5, 7, 6, 8, 7, 9],
        "shown": [5, 7, 6, 8, None, None],
        "rule": "依次加2、减1，重复进行",
        "explanation": "5＋2＝7，7－1＝6，6＋2＝8；继续减1得7，再加2得9。",
    },
    {
        "full": [2, 5, 4, 7, 6, 9],
        "shown": [2, 5, 4, 7, None, None],
        "rule": "依次加3、减1，重复进行",
        "explanation": "2＋3＝5，5－1＝4，4＋3＝7；继续减1得6，再加3得9。",
    },
]

SHAPE_PATTERNS = [
    ["circle", "square", "circle", "square", "circle", "square"],
    ["triangle", "triangle", "circle", "triangle", "triangle", "circle", "triangle", "triangle"],
    ["circle", "square", "square", "circle", "square", "square", "circle", "square"],
    ["triangle", "circle", "square", "triangle", "circle", "square", "triangle", "circle"],
    ["circle", "circle", "square", "triangle", "circle", "circle", "square", "triangle"],
]

SHAPE_RULES = [
    "圆、正方形两个一组，重复排列。",
    "三角形、三角形、圆三个一组，重复排列。",
    "圆、正方形、正方形三个一组，重复排列。",
    "三角形、圆、正方形三个一组，重复排列。",
    "圆、圆、正方形、三角形四个一组，重复排列。",
]

ADD_TEMPLATES = [
    ("篮子里原有{a}个苹果，又放进{b}个，现在共有多少个苹果？", "个", "苹果"),
    ("书架上原有{a}本故事书，又放上{b}本，现在共有多少本？", "本", "故事书"),
    ("图画上先画了{a}颗星，又画了{b}颗，一共画了多少颗？", "颗", "星"),
    ("停车场原有{a}辆玩具车，又开来{b}辆，现在有多少辆？", "辆", "玩具车"),
    ("花坛里原有{a}朵花，又开了{b}朵，现在共有多少朵？", "朵", "花"),
]

SUB_TEMPLATES = [
    ("树上原有{total}只小鸟，飞走了{sub}只，还剩多少只？", "只", "小鸟"),
    ("教室里有{total}个气球，拿走了{sub}个，还剩多少个？", "个", "气球"),
    ("盘子里有{total}块饼干，吃了{sub}块，还剩多少块？", "块", "饼干"),
    ("池塘里有{total}只小鸭，游走了{sub}只，还剩多少只？", "只", "小鸭"),
    ("文具盒里有{total}支铅笔，用掉了{sub}支，还剩多少支？", "支", "铅笔"),
]

MIXED_PROBLEMS = [
    {
        "text": "公交车上原有7人，到站上来6人，又下去4人。车上现在有多少人？",
        "numbers": [7, 6, 4],
        "ops": ["+", "-"],
        "unit": "人",
        "labels": ["原有7人", "上来6人", "下去4人"],
    },
    {
        "text": "阅读角原有8本书，同学还回5本，又借走3本。现在有多少本？",
        "numbers": [8, 5, 3],
        "ops": ["+", "-"],
        "unit": "本",
        "labels": ["原有8本", "还回5本", "借走3本"],
    },
    {
        "text": "操场上原有6个小朋友，又来了8个，后来走了5个。现在有多少个？",
        "numbers": [6, 8, 5],
        "ops": ["+", "-"],
        "unit": "个",
        "labels": ["原有6个", "来了8个", "走了5个"],
    },
    {
        "text": "鱼缸里原有9条小鱼，又放入7条，送走6条。现在有多少条？",
        "numbers": [9, 7, 6],
        "ops": ["+", "-"],
        "unit": "条",
        "labels": ["原有9条", "放入7条", "送走6条"],
    },
    {
        "text": "小雨原有5张贴纸，又得到9张，送给同学7张。现在有多少张？",
        "numbers": [5, 9, 7],
        "ops": ["+", "-"],
        "unit": "张",
        "labels": ["原有5张", "得到9张", "送出7张"],
    },
]

EXTENSIONS = [
    {
        "question": "□＋6＝14。先求出□里的数，再用这个数计算：□＋3－5＝？",
        "answer": 6,
        "box_answer": 8,
        "steps": [
            "先想8＋6＝14，所以第一个□里填8。",
            "把8带入第二个算式：8＋3－5。",
            "从左往右算：8＋3＝11，11－5＝6。",
        ],
        "flow": ["□＋6＝14", "□＝8", "8＋3＝11", "11－5＝6"],
    },
    {
        "question": "9＋7－□＝10，□里应填几？",
        "answer": 6,
        "steps": [
            "先用凑十法算9＋7：把7分成1和6，9＋1＝10，10＋6＝16。",
            "现在变成16－□＝10。",
            "想“16减几等于10”，所以□里填6。",
        ],
        "flow": ["9＋7＝16", "16－□＝10", "□＝6"],
    },
    {
        "question": "从18开始，连续减3次4，最后得到多少？请写出连减算式。",
        "answer": 6,
        "steps": [
            "“连续减3次4”表示算式里要写三个“－4”，不能只减一次。",
            "从左往右：18－4＝14，14－4＝10，10－4＝6。",
            "连减算式是18－4－4－4＝6。",
        ],
        "flow": ["18", "－4得14", "－4得10", "－4得6"],
    },
    {
        "question": "一个数加8，再减5，结果是12。这个数是多少？",
        "answer": 9,
        "steps": [
            "用□表示原来的数，题意是□＋8－5＝12。",
            "倒着想：最后减了5，减之前应是12＋5＝17。",
            "再想“几加8等于17”，用17－8＝9，所以原来的数是9。",
            "检查：9＋8＝17，17－5＝12，符合题意。",
        ],
        "flow": ["结果12", "倒推＋5得17", "倒推－8得9", "检查9＋8－5＝12"],
    },
    {
        "question": "从2、4、6、8中选三个不同的数，填成“□＋□－□”，怎样填结果最大？最大是多少？",
        "answer": 12,
        "expression": "8＋6－2＝12",
        "steps": [
            "想让结果最大，加号前面应放较大的数，减号后面应放最小的数。",
            "选8和6相加，选2来减：8＋6－2。",
            "先算8＋6＝14，再算14－2＝12。",
            "4没有使用；每个选中的数只用一次，符合题目要求。",
        ],
        "flow": ["选最大的8和6相加", "选最小的2来减", "8＋6＝14", "14－2＝12"],
    },
]


SPECIAL_CSS = base.PRINT_CSS + """
.special-page { font-size: 12.1pt; line-height: 1.42; }
.special-page .paper-title { font-size: 19.5pt; }
.level-chip {
  display: inline-block;
  margin-left: 2mm;
  padding: .3mm 2mm;
  border: 1pt solid #555;
  border-radius: 2mm;
  font-size: 9.5pt;
  font-weight: 500;
  vertical-align: middle;
}
.picture-pair {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 4mm;
}
.picture-card {
  padding: 2mm 2.5mm;
  border: 1.2pt solid #555;
  border-radius: 2mm;
  break-inside: avoid;
}
.picture-title { margin-bottom: 1mm; font-weight: 700; }
.twenty-frame {
  display: grid;
  grid-template-columns: repeat(10, 7mm);
  grid-template-rows: repeat(2, 7mm);
  width: 70mm;
  margin: 1mm auto;
  border-left: 1pt solid #333;
  border-top: 1pt solid #333;
}
.dot-cell {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  border-right: 1pt solid #333;
  border-bottom: 1pt solid #333;
}
.picture-dot {
  position: relative;
  display: inline-block;
  width: 4.5mm;
  height: 4.5mm;
  border: 1.2pt solid #111;
  border-radius: 50%;
}
.picture-dot.original { background: #222; }
.picture-dot.added { background: #bbb; }
.picture-dot.removed { background: #eee; }
.picture-dot.removed::before,
.picture-dot.removed::after {
  position: absolute;
  top: 1.7mm;
  left: -.6mm;
  width: 5.5mm;
  height: 1.2pt;
  content: "";
  background: #111;
  transform: rotate(45deg);
}
.picture-dot.removed::after { transform: rotate(-45deg); }
.picture-legend {
  min-height: 5mm;
  text-align: center;
  font-size: 9pt;
}
.legend-sample {
  display: inline-block;
  width: 3.5mm;
  height: 3.5mm;
  margin: 0 .5mm 0 1.5mm;
  border: 1pt solid #111;
  border-radius: 50%;
  vertical-align: middle;
}
.legend-sample.black { background: #222; }
.legend-sample.gray { background: #bbb; }
.picture-equation { margin-top: 1.5mm; text-align: center; font-size: 14pt; }
.big-answer-box {
  display: inline-block;
  width: 11mm;
  height: 10mm;
  margin: 0 1mm;
  border: 1.4pt solid #222;
  background: #fff;
  vertical-align: middle;
}
.calc-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 2mm 4mm;
}
.calc-item {
  min-height: 10mm;
  padding: 1mm 0;
  font-size: 14pt;
  font-weight: 700;
  white-space: nowrap;
}
.method-practice-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1.2mm;
}
.method-practice {
  min-height: 13mm;
  padding: 1.5mm 2mm;
  border: 1pt dashed #777;
  font-size: 12.5pt;
  white-space: nowrap;
}
.chain-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2.5mm 9mm;
}
.chain-item {
  min-height: 14mm;
  padding: 1.5mm 2mm;
  border-bottom: 1pt dashed #999;
  font-size: 15pt;
  font-weight: 700;
}
.pattern-card {
  margin: 2mm 0;
  padding: 2mm 3mm;
  border: 1pt solid #777;
  break-inside: avoid;
}
.pattern-sequence {
  display: flex;
  align-items: center;
  gap: 1.5mm;
  margin-top: 1.5mm;
  font-size: 14pt;
  font-weight: 700;
}
.pattern-number,
.pattern-blank {
  display: inline-flex;
  width: 10mm;
  height: 10mm;
  align-items: center;
  justify-content: center;
  border-bottom: 1.2pt solid #222;
}
.pattern-blank { border: 1.2pt solid #222; }
.pattern-icon,
.pattern-icon-blank {
  display: inline-flex;
  width: 11mm;
  height: 11mm;
  align-items: center;
  justify-content: center;
}
.pattern-icon-blank { border: 1pt solid #555; }
.pattern-svg { width: 9mm; height: 9mm; }
.judge-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2mm 8mm;
}
.judge-item {
  min-height: 14mm;
  padding: 1.5mm 2mm;
  border: 1pt dashed #888;
}
.app-problem {
  min-height: 48mm;
  margin: 2mm 0;
  padding: 2.5mm 3mm;
  border: 1.2pt solid #555;
  border-radius: 2mm;
  break-inside: avoid;
}
.app-problem p { margin: 0 0 2mm; }
.work-line {
  height: 9mm;
  border-bottom: 1pt solid #777;
}
.answer-sentence { margin-top: 2mm; }
.extension-box {
  min-height: 54mm;
  padding: 3mm;
  border: 1.8pt solid #222;
  background: #fafafa;
}
.extension-box .work-line { height: 10mm; }
.break-ten-layout {
  display: grid;
  grid-template-columns: 75mm 1fr;
  gap: 5mm;
  align-items: center;
}
.break-visual {
  display: flex;
  align-items: center;
  gap: 3mm;
}
.crossed-ten-dot { position: relative; background: #eee; }
.crossed-ten-dot::before,
.crossed-ten-dot::after {
  position: absolute;
  width: 7mm;
  height: 1.2pt;
  content: "";
  background: #111;
  transform: rotate(45deg);
}
.crossed-ten-dot::after { transform: rotate(-45deg); }
.loose-ones {
  display: flex;
  flex-wrap: wrap;
  width: 19mm;
  gap: 1mm;
}
.loose-one {
  display: inline-block;
  width: 5mm;
  height: 5mm;
  border: 1.2pt solid #111;
  border-radius: 50%;
  background: #222;
}
.answer-grid-2 {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 3mm;
}
.mini-answer-card {
  padding: 2mm 2.5mm;
  border: 1pt solid #777;
  break-inside: avoid;
}
.chain-answer {
  margin: 1.5mm 0;
  padding: 2mm 2.5mm;
  border-left: 3pt solid #555;
  background: #f8f8f8;
  break-inside: avoid;
}
.operation-flow {
  display: flex;
  align-items: stretch;
  justify-content: center;
  gap: 1mm;
  margin: 2mm 0;
  break-inside: avoid;
}
.operation-node {
  display: flex;
  min-width: 29mm;
  min-height: 14mm;
  align-items: center;
  justify-content: center;
  padding: 1mm 2mm;
  border: 1pt solid #555;
  background: #fff;
  text-align: center;
  font-size: 10pt;
  font-weight: 700;
}
.operation-arrow {
  display: flex;
  align-items: center;
  font-size: 15pt;
  font-weight: 800;
}
.answer-picture { max-width: 86mm; }
.answer-method-line {
  margin: 1mm 0;
  font-size: 12.2pt;
  font-weight: 700;
}
.page-break { page-break-before: always; break-before: page; }
"""


def apply_op(left: int, op: str, right: int) -> int:
    if op == "+":
        return left + right
    if op == "-":
        return left - right
    raise ValueError(f"不支持的运算符：{op}")


def evaluate_chain(numbers: list[int], ops: list[str]) -> tuple[int, list[int]]:
    if len(numbers) != len(ops) + 1:
        raise ValueError("数字个数与运算符个数不匹配。")
    current = numbers[0]
    values = [current]
    for op, number in zip(ops, numbers[1:]):
        current = apply_op(current, op, number)
        values.append(current)
    return current, values


def expression_text(numbers: list[int], ops: list[str]) -> str:
    parts = [str(numbers[0])]
    for op, number in zip(ops, numbers[1:]):
        parts.extend(["＋" if op == "+" else "－", str(number)])
    return "".join(parts)


def make_chain_items(index: int) -> list[dict[str, Any]]:
    specs = [
        ([2 + index, 3 + index % 2, 4], ["+", "+"]),
        ([5, 4 + index % 3, 2 + index % 2], ["+", "+"]),
        ([18 - index, 2 + index % 3, 3], ["-", "-"]),
        ([20, 4 + index, 2], ["-", "-"]),
        ([8 + index % 2, 3 + index, 2 + index % 3], ["+", "-"]),
        ([15 + index % 3, 6 + index % 2, 4], ["-", "+"]),
        ([3 + index % 3, 7, 5, 2], ["+", "-", "+"]),
        ([20, 5 + index % 3, 2 + index % 2, 3], ["-", "+", "-"]),
    ]
    items: list[dict[str, Any]] = []
    for numbers, ops in specs:
        answer, values = evaluate_chain(numbers, ops)
        items.append(
            {
                "numbers": numbers,
                "ops": ops,
                "text": expression_text(numbers, ops),
                "answer": answer,
                "values": values,
            }
        )
    return items


def make_method_items(additions: list[tuple[int, int]], subtractions: list[tuple[int, int]]) -> list[dict[str, Any]]:
    items: list[dict[str, Any]] = []
    for left, right in additions[:2]:
        need = 10 - left
        rest = right - need
        items.append(
            {
                "kind": "make",
                "left": left,
                "right": right,
                "need": need,
                "rest": rest,
                "answer": left + right,
                "test": f"{left}＋{right}＝{left}＋（□＋□）＝10＋□＝□",
                "box_answers": [need, rest, rest, left + right],
            }
        )
    for total, sub in subtractions[:2]:
        ones = total - 10
        ten_rest = 10 - sub
        items.append(
            {
                "kind": "break",
                "total": total,
                "sub": sub,
                "ones": ones,
                "ten_rest": ten_rest,
                "answer": total - sub,
                "test": f"{total}－{sub}＝（10－□）＋{ones}＝□＋{ones}＝□",
                "box_answers": [sub, ten_rest, total - sub],
            }
        )
    return items


def build_applications(index: int, additions: list[tuple[int, int]], subtractions: list[tuple[int, int]]) -> list[dict[str, Any]]:
    add_a, add_b = additions[3]
    add_template, add_unit, add_noun = ADD_TEMPLATES[index]
    add_total = add_a + add_b
    add_problem = {
        "kind": "add",
        "text": add_template.format(a=add_a, b=add_b),
        "unit": add_unit,
        "noun": add_noun,
        "numbers": [add_a, add_b],
        "ops": ["+"],
        "equation": f"{add_a}＋{add_b}＝{add_total}",
        "answer": add_total,
        "model": {
            "total": add_total,
            "parts": [add_a, add_b],
            "labels": ["原有", "增加"],
        },
    }

    sub_total, sub_number = subtractions[3]
    sub_template, sub_unit, sub_noun = SUB_TEMPLATES[index]
    sub_answer = sub_total - sub_number
    sub_problem = {
        "kind": "sub",
        "text": sub_template.format(total=sub_total, sub=sub_number),
        "unit": sub_unit,
        "noun": sub_noun,
        "numbers": [sub_total, sub_number],
        "ops": ["-"],
        "equation": f"{sub_total}－{sub_number}＝{sub_answer}",
        "answer": sub_answer,
        "model": {
            "total": sub_total,
            "parts": [sub_answer, sub_number],
            "labels": ["剩下", "去掉"],
        },
    }

    mixed_source = MIXED_PROBLEMS[index]
    mixed_answer, mixed_values = evaluate_chain(mixed_source["numbers"], mixed_source["ops"])
    mixed_problem = {
        **mixed_source,
        "kind": "mixed",
        "equation": f'{expression_text(mixed_source["numbers"], mixed_source["ops"])}＝{mixed_answer}',
        "answer": mixed_answer,
        "values": mixed_values,
    }
    return [add_problem, sub_problem, mixed_problem]


def build_paper_sets() -> list[dict[str, Any]]:
    paper_sets: list[dict[str, Any]] = []
    for index in range(PAPER_COUNT):
        additions = CARRY_BANK[index]
        subtractions = BORROW_BANK[index]
        calculations: list[dict[str, Any]] = []
        for add_pair, sub_pair in zip(additions, subtractions):
            left, right = add_pair
            calculations.append(
                {
                    "kind": "make",
                    "text": f"{left}＋{right}",
                    "answer": left + right,
                    "left": left,
                    "right": right,
                }
            )
            total, sub = sub_pair
            calculations.append(
                {
                    "kind": "break",
                    "text": f"{total}－{sub}",
                    "answer": total - sub,
                    "total": total,
                    "sub": sub,
                }
            )

        operator_add = additions[2]
        operator_sub = subtractions[2]
        wrong_add = additions[4]
        wrong_sub = subtractions[4]
        judge_items = [
            {
                "kind": "operator",
                "test": f"{operator_add[0]} □ {operator_add[1]}＝{sum(operator_add)}",
                "answer": "＋",
                "reason": "右边比左边两个数都大，应把两个数合起来，所以填加号。",
            },
            {
                "kind": "operator",
                "test": f"{operator_sub[0]} □ {operator_sub[1]}＝{operator_sub[0] - operator_sub[1]}",
                "answer": "－",
                "reason": "从总数中去掉一部分，结果变小，所以填减号。",
            },
            {
                "kind": "correction",
                "test": f"{wrong_add[0]}＋{wrong_add[1]}＝{wrong_add[0] + wrong_add[1] - 1}（　）",
                "answer": f"×，应改为{wrong_add[0]}＋{wrong_add[1]}＝{wrong_add[0] + wrong_add[1]}",
                "reason": "用凑十法重新计算后，比题目中的结果多1。",
            },
            {
                "kind": "correction",
                "test": f"{wrong_sub[0]}－{wrong_sub[1]}＝{wrong_sub[0] - wrong_sub[1] + 1}（　）",
                "answer": f"×，应改为{wrong_sub[0]}－{wrong_sub[1]}＝{wrong_sub[0] - wrong_sub[1]}",
                "reason": "用破十法重新计算后，比题目中的结果少1。",
            },
        ]

        paper_sets.append(
            {
                "number": index + 1,
                "level": LEVELS[index],
                "picture_add": {
                    "left": additions[0][0],
                    "right": additions[0][1],
                    "answer": sum(additions[0]),
                },
                "picture_sub": {
                    "total": subtractions[0][0],
                    "sub": subtractions[0][1],
                    "answer": subtractions[0][0] - subtractions[0][1],
                },
                "calculations": calculations,
                "methods": make_method_items(additions, subtractions),
                "chains": make_chain_items(index),
                "number_pattern": NUMBER_PATTERNS[index],
                "shape_pattern": {
                    "full": SHAPE_PATTERNS[index],
                    "shown_count": len(SHAPE_PATTERNS[index]) - 2,
                    "rule": SHAPE_RULES[index],
                },
                "judge_items": judge_items,
                "applications": build_applications(index, additions, subtractions),
                "extension": EXTENSIONS[index],
            }
        )
    return paper_sets


def validate_blueprints(paper_sets: list[dict[str, Any]]) -> None:
    if len(paper_sets) != PAPER_COUNT:
        raise ValueError(f"应生成{PAPER_COUNT}套试题。")

    direct_expressions: list[str] = []
    for paper in paper_sets:
        if len(paper["calculations"]) != 10:
            raise ValueError("每套应有10道直接计算题。")
        if len(paper["methods"]) != 4 or len(paper["chains"]) != 8:
            raise ValueError("方法填空或连算题数量不正确。")
        if len(paper["applications"]) != 3 or len(paper["judge_items"]) != 4:
            raise ValueError("应用题或判断改错题数量不正确。")

        for item in paper["calculations"]:
            direct_expressions.append(item["text"])
            if not 0 <= item["answer"] <= 20:
                raise ValueError(f'直接计算超出20以内：{item["text"]}')

        for item in paper["chains"]:
            answer, values = evaluate_chain(item["numbers"], item["ops"])
            if answer != item["answer"] or values != item["values"]:
                raise ValueError(f'连算答案不一致：{item["text"]}')
            if any(value < 0 or value > 20 for value in values):
                raise ValueError(f'连算中间结果超出0—20：{item["text"]}，{values}')

        for problem in paper["applications"]:
            answer, values = evaluate_chain(problem["numbers"], problem["ops"])
            if answer != problem["answer"]:
                raise ValueError(f'应用题答案不一致：{problem["text"]}')
            if any(value < 0 or value > 20 for value in values):
                raise ValueError(f'应用题计算超出0—20：{problem["text"]}')

        if sum([12, 20, 16, 16, 10, 8, 12, 6]) != 100:
            raise ValueError("分值总和不是100分。")

    if len(direct_expressions) != len(set(direct_expressions)):
        duplicates = sorted({text for text in direct_expressions if direct_expressions.count(text) > 1})
        raise ValueError(f"5套直接计算题存在重复：{duplicates}")


def paper_pdf_path(number: int) -> Path:
    return ROOT / f"一年级20以内凑十破十综合练习_规范排版版_第{number:02d}套.pdf"


def header_html(paper: dict[str, Any]) -> str:
    return f"""
      <h1 class="paper-title">
        一年级20以内凑十法与破十法综合练习（第{paper["number"]:02d}套）
        <span class="level-chip">{base.esc(paper["level"])}</span>
      </h1>
      <div class="student-fields">
        <div>班级：<span class="field-line"></span></div>
        <div>姓名：<span class="field-line"></span></div>
        <div>日期：<span class="field-line"></span></div>
      </div>
    """


def footer_html(paper: dict[str, Any], page_number: int) -> str:
    return f"""
      <div class="page-footer">
        <span>认真读题 · 按从左往右的顺序计算 · 写清过程</span>
        <span>第{paper["number"]:02d}套 {page_number}/{PAPER_PAGES}</span>
      </div>
    """


def replace_boxes(text: str, class_name: str = "big-answer-box") -> str:
    return base.esc(text).replace("□", f'<span class="{class_name}" aria-label="答题框"></span>')


def picture_frame_html(
    *,
    total: int,
    original: int | None = None,
    removed: int = 0,
    compact: bool = False,
) -> str:
    cells: list[str] = []
    removed_start = total - removed
    for index in range(20):
        dot = ""
        if index < total:
            if removed and index >= removed_start:
                dot = '<span class="picture-dot removed"></span>'
            elif original is not None and index >= original:
                dot = '<span class="picture-dot added"></span>'
            else:
                dot = '<span class="picture-dot original"></span>'
        cells.append(f'<span class="dot-cell">{dot}</span>')
    extra_class = " answer-picture" if compact else ""
    return f'<div class="twenty-frame{extra_class}">{"".join(cells)}</div>'


def picture_add_card(item: dict[str, int], *, answer: bool = False) -> str:
    equation = (
        f'{item["left"]}＋{item["right"]}＝<strong>{item["answer"]}</strong>'
        if answer
        else '<span class="big-answer-box"></span>＋<span class="big-answer-box"></span>'
        '＝<span class="big-answer-box"></span>'
    )
    return f"""
      <div class="picture-card">
        <div class="picture-title">图①：先有一组黑点，又添上一组灰点。</div>
        {picture_frame_html(total=item["answer"], original=item["left"], compact=answer)}
        <div class="picture-legend">
          <span class="legend-sample black"></span>先有
          <span class="legend-sample gray"></span>添上
        </div>
        <div class="picture-equation">{equation}</div>
      </div>
    """


def picture_sub_card(item: dict[str, int], *, answer: bool = False) -> str:
    equation = (
        f'{item["total"]}－{item["sub"]}＝<strong>{item["answer"]}</strong>'
        if answer
        else '<span class="big-answer-box"></span>－<span class="big-answer-box"></span>'
        '＝<span class="big-answer-box"></span>'
    )
    return f"""
      <div class="picture-card">
        <div class="picture-title">图②：叉掉的圆点表示去掉。</div>
        {picture_frame_html(total=item["total"], removed=item["sub"], compact=answer)}
        <div class="picture-legend">数一数：原有多少、去掉多少、还剩多少。</div>
        <div class="picture-equation">{equation}</div>
      </div>
    """


def pattern_icon(shape: str) -> str:
    if shape == "circle":
        content = '<circle cx="20" cy="20" r="13" fill="white" stroke="black" stroke-width="2.5"/>'
        label = "圆"
    elif shape == "square":
        content = '<rect x="7" y="7" width="26" height="26" fill="white" stroke="black" stroke-width="2.5"/>'
        label = "正方形"
    else:
        content = '<polygon points="20,5 35,33 5,33" fill="white" stroke="black" stroke-width="2.5"/>'
        label = "三角形"
    return (
        f'<span class="pattern-icon"><svg class="pattern-svg" viewBox="0 0 40 40" '
        f'role="img" aria-label="{label}">{content}</svg></span>'
    )


def number_pattern_html(pattern: dict[str, Any], *, answer: bool = False) -> str:
    values = pattern["full"] if answer else pattern["shown"]
    cells: list[str] = []
    for value in values:
        if value is None:
            cells.append('<span class="pattern-blank"></span>')
        else:
            cells.append(f'<span class="pattern-number">{value}</span>')
    return '<div class="pattern-sequence">' + '<span>→</span>'.join(cells) + "</div>"


def shape_pattern_html(pattern: dict[str, Any], *, answer: bool = False) -> str:
    shown_count = len(pattern["full"]) if answer else pattern["shown_count"]
    cells = [pattern_icon(shape) for shape in pattern["full"][:shown_count]]
    if not answer:
        cells.extend('<span class="pattern-icon-blank"></span>' for _ in range(2))
    return '<div class="pattern-sequence">' + '<span>→</span>'.join(cells) + "</div>"


def render_paper_page_one(paper: dict[str, Any]) -> str:
    calculations = "".join(
        f'<div class="calc-item">{base.esc(item["text"])}＝<span class="big-answer-box"></span></div>'
        for item in paper["calculations"]
    )
    methods = "".join(
        f'<div class="method-practice">{replace_boxes(item["test"])}</div>'
        for item in paper["methods"]
    )
    return f"""
    <section class="page special-page">
      {header_html(paper)}
      <div class="score-strip"><span>满分：100分</span><span>本页：看图、口算、方法填空</span><span>得分：________</span></div>

      <div class="section">
        <h2>一、看图写算式（12分）</h2>
        <div class="picture-pair">
          {picture_add_card(paper["picture_add"])}
          {picture_sub_card(paper["picture_sub"])}
        </div>
      </div>

      <div class="section">
        <h2>二、直接写得数（20分）</h2>
        <div class="calc-grid">{calculations}</div>
      </div>

      <div class="section">
        <h2>三、按凑十法或破十法填一填（16分）</h2>
        <p class="instruction">先看清是“加”还是“减”，每个框都要填写。</p>
        <div class="method-practice-grid">{methods}</div>
      </div>
      {footer_html(paper, 1)}
    </section>
    """


def render_paper_page_two(paper: dict[str, Any]) -> str:
    chains = "".join(
        f'<div class="chain-item">{base.esc(item["text"])}＝</div>'
        for item in paper["chains"]
    )
    operator_items = "".join(
        f'<div class="judge-item">{replace_boxes(item["test"])}</div>'
        for item in paper["judge_items"][:2]
    )
    correction_items = "".join(
        f'<div class="judge-item">{replace_boxes(item["test"])}</div>'
        for item in paper["judge_items"][2:]
    )
    return f"""
    <section class="page special-page">
      {header_html(paper)}

      <div class="section">
        <h2>四、计算下面各题（16分）</h2>
        <p class="instruction">从左往右算；遇到9加几、8加几可以先凑十，遇到十几减几可以先破十。</p>
        <div class="chain-grid">{chains}</div>
      </div>

      <div class="section">
        <h2>五、找规律，接着填或画（10分）</h2>
        <div class="pattern-card">
          <strong>1. 数字小火车：</strong>
          {number_pattern_html(paper["number_pattern"])}
        </div>
        <div class="pattern-card">
          <strong>2. 图形队伍：</strong>请在最后两个方框里画出合适的图形。
          {shape_pattern_html(paper["shape_pattern"])}
        </div>
      </div>

      <div class="section">
        <h2>六、想一想，填一填（8分）</h2>
        <p class="instruction"><strong>（1）在框里填“＋”或“－”。</strong></p>
        <div class="judge-grid">{operator_items}</div>
        <p class="instruction" style="margin-top:2mm"><strong>（2）判断并改错。对的画“√”，错的画“×”并改正。</strong></p>
        <div class="judge-grid">{correction_items}</div>
      </div>
      {footer_html(paper, 2)}
    </section>
    """


def render_paper_page_three(paper: dict[str, Any]) -> str:
    applications = "".join(
        f"""
        <div class="app-problem">
          <p><strong>{index}.</strong> {base.esc(problem["text"])}</p>
          <div>列式：<span class="blank long"></span></div>
          <div class="work-line"></div>
          <div class="answer-sentence">答：<span class="blank long"></span></div>
        </div>
        """
        for index, problem in enumerate(paper["applications"], start=1)
    )
    return f"""
    <section class="page special-page">
      {header_html(paper)}

      <div class="section">
        <h2>七、解决问题（12分）</h2>
        <p class="instruction">圈出有用的数，想清楚“合起来”用加法，“去掉、剩下”用减法；两件事要分两步算。</p>
        {applications}
      </div>

      <div class="section">
        <h2>八、拓展思维（6分）</h2>
        <div class="extension-box">
          <strong>{base.esc(paper["extension"]["question"])}</strong>
          <div class="work-line"></div>
          <div class="work-line"></div>
          <div class="work-line"></div>
        </div>
      </div>
      {footer_html(paper, 3)}
    </section>
    """


def render_paper_html(paper: dict[str, Any]) -> str:
    pages = render_paper_page_one(paper) + render_paper_page_two(paper) + render_paper_page_three(paper)
    return f"""<!doctype html>
    <html lang="zh-CN">
      <head>
        <meta charset="utf-8">
        <title>一年级凑十破十综合练习第{paper["number"]:02d}套</title>
        <style>{SPECIAL_CSS}</style>
      </head>
      <body>{pages}</body>
    </html>"""


def break_ten_diagram(item: dict[str, int]) -> str:
    total = item["total"]
    sub = item["sub"]
    ones = total - 10
    ten_rest = 10 - sub
    answer = total - sub
    cells: list[str] = []
    for index in range(10):
        if index < sub:
            dot = '<span class="ten-dot crossed-ten-dot"></span>'
        else:
            dot = '<span class="ten-dot original"></span>'
        cells.append(f'<span class="ten-cell">{dot}</span>')
    loose_ones = "".join('<span class="loose-one"></span>' for _ in range(ones))
    return f"""
      <div class="method-card">
        <div class="method-title">破十法图解：{total}－{sub}</div>
        <div class="break-ten-layout">
          <div>
            <div class="break-visual">
              <div class="ten-frame">{"".join(cells)}</div>
              <strong>＋</strong>
              <div class="loose-ones">{loose_ones}</div>
            </div>
            <div class="dot-legend">左边把“10”中的{sub}个叉掉，右边保留原来的{ones}个。</div>
          </div>
          <ol class="method-steps">
            <li>先把{total}分成<strong>10和{ones}</strong>。</li>
            <li>先从10里面减{sub}：10－{sub}＝<strong>{ten_rest}</strong>。</li>
            <li>再把没有动的{ones}加回来：{ten_rest}＋{ones}＝<strong>{answer}</strong>。</li>
          </ol>
        </div>
        <p class="compact"><strong>所以：{total}－{sub}＝（10－{sub}）＋{ones}＝{ten_rest}＋{ones}＝{answer}。</strong></p>
      </div>
    """


def make_ten_example(item: dict[str, int]) -> dict[str, int]:
    left = item["left"]
    right = item["right"]
    need = 10 - left
    return {
        "left": left,
        "right": right,
        "need": need,
        "rest": right - need,
        "total": left + right,
    }


def operation_flow_html(labels: list[str]) -> str:
    nodes = '<span class="operation-arrow">→</span>'.join(
        f'<span class="operation-node">{base.esc(label)}</span>' for label in labels
    )
    return f'<div class="operation-flow">{nodes}</div>'


def chain_reason(item: dict[str, Any]) -> str:
    first = item["numbers"][0]
    pieces: list[str] = []
    current = first
    for op, number in zip(item["ops"], item["numbers"][1:]):
        next_value = apply_op(current, op, number)
        sign = "＋" if op == "+" else "－"
        pieces.append(f"{current}{sign}{number}＝{next_value}")
        current = next_value
    return "，再算".join(pieces)


def render_picture_answers(paper: dict[str, Any]) -> str:
    add = paper["picture_add"]
    sub = paper["picture_sub"]
    return f"""
      <h2>一、看图写算式</h2>
      <div class="answer-grid-2">
        {picture_add_card(add, answer=True)}
        {picture_sub_card(sub, answer=True)}
      </div>
      <div class="answer-callout">
        <strong>读图方法：</strong>图①把黑点和灰点合起来，所以用加法；
        图②从原有圆点中叉掉一部分，问还剩多少，所以用减法。先看图意，再选运算，不能只凭数字猜。
      </div>
    """


def render_calculation_answers(paper: dict[str, Any]) -> str:
    answer_text = "；".join(f'{item["text"]}＝{item["answer"]}' for item in paper["calculations"])
    make_item = next(item for item in paper["calculations"] if item["kind"] == "make")
    break_item = next(item for item in paper["calculations"] if item["kind"] == "break")
    return f"""
      <h2>二、直接写得数</h2>
      <p class="answer-method-line">{base.esc(answer_text)}。</p>
      <p class="reason">
        加法题可以把其中一个加数拆开，先凑成10；减法题可以把十几拆成10和几个，
        先从10里面减，再把剩下的几个加回来。下面各示范一题。
      </p>
      {base.make_ten_diagram(make_ten_example(make_item))}
      {break_ten_diagram(break_item)}
    """


def render_method_answers(paper: dict[str, Any]) -> str:
    cards: list[str] = []
    for index, item in enumerate(paper["methods"], start=1):
        if item["kind"] == "make":
            filled = (
                f'{item["left"]}＋{item["right"]}＝{item["left"]}＋'
                f'（{item["need"]}＋{item["rest"]}）＝10＋{item["rest"]}＝{item["answer"]}'
            )
            reason = (
                f'{item["left"]}离10还差{item["need"]}，所以把{item["right"]}分成'
                f'{item["need"]}和{item["rest"]}。先凑成10，再加剩下的{item["rest"]}。'
            )
        else:
            filled = (
                f'{item["total"]}－{item["sub"]}＝（10－{item["sub"]}）＋{item["ones"]}'
                f'＝{item["ten_rest"]}＋{item["ones"]}＝{item["answer"]}'
            )
            reason = (
                f'把{item["total"]}看成10和{item["ones"]}。先算10－{item["sub"]}'
                f'＝{item["ten_rest"]}，再加回{item["ones"]}。'
            )
        cards.append(
            f"""
            <div class="mini-answer-card">
              <strong>{index}. {filled}</strong>
              <p class="reason">{reason}</p>
            </div>
            """
        )
    return f"""
      <h2>三、按凑十法或破十法填一填</h2>
      <div class="answer-grid-2">{"".join(cards)}</div>
      <div class="answer-callout">
        <strong>检查小窍门：</strong>拆开的两个数必须还能合回原来的数。例如把6分成1和5，就要检查1＋5＝6；
        破十后也要检查“先减后的数＋个位数”是否等于最后答案。
      </div>
    """


def render_chain_answers(paper: dict[str, Any]) -> str:
    cards = "".join(
        f"""
        <div class="chain-answer">
          <strong>{base.esc(item["text"])}＝{item["answer"]}</strong><br>
          <span class="reason">从左往右：{base.esc(chain_reason(item))}。</span>
          {operation_flow_html(
              [str(item["numbers"][0])]
              + [
                  f'{"加" if op == "+" else "减"}{number}得{value}'
                  for op, number, value in zip(item["ops"], item["numbers"][1:], item["values"][1:])
              ]
          )}
        </div>
        """
        for item in paper["chains"]
    )
    return f"""
      <h2>四、计算下面各题</h2>
      <div class="answer-callout">
        <strong>关键规则：</strong>只有加号和减号时，一年级按<strong>从左往右</strong>计算。
        每算完一步，把结果当成下一步的新起点。不能先挑后面的加法或减法来算。
      </div>
      {cards}
    """


def render_pattern_answers(paper: dict[str, Any]) -> str:
    number_pattern = paper["number_pattern"]
    shape_pattern = paper["shape_pattern"]
    return f"""
      <h2>五、找规律</h2>
      <div class="method-card">
        <div class="method-title">1. 数字规律：{base.esc(number_pattern["rule"])}</div>
        {number_pattern_html(number_pattern, answer=True)}
        <p>{base.esc(number_pattern["explanation"])}</p>
        <p class="reason">找规律时至少检查前面两次变化，不能只看最后两个数。</p>
      </div>
      <div class="method-card">
        <div class="method-title">2. 图形规律</div>
        {shape_pattern_html(shape_pattern, answer=True)}
        <p>{base.esc(shape_pattern["rule"])}</p>
        <p class="reason">先用竖线在心里分组，再把完整的一组照样重复，最后两个图形如上图所示。</p>
      </div>
    """


def render_judge_answers(paper: dict[str, Any]) -> str:
    operator_items = "".join(
        f"""
        <li>
          <strong>{base.esc(item["test"].replace("□", item["answer"]))}</strong><br>
          <span class="reason">思路：{base.esc(item["reason"])}</span>
        </li>
        """
        for item in paper["judge_items"][:2]
    )
    correction_items = "".join(
        f"""
        <li>
          <strong>{base.esc(item["answer"])}</strong><br>
          <span class="reason">思路：{base.esc(item["reason"])}</span>
        </li>
        """
        for item in paper["judge_items"][2:]
    )
    return f"""
      <h2>六、想一想，填一填</h2>
      <h3>（1）填运算符</h3>
      <ul class="answer-list">{operator_items}</ul>
      <h3>（2）判断并改错</h3>
      <ul class="answer-list">{correction_items}</ul>
      <div class="answer-callout">
        <strong>改错三步：</strong>①自己重新算；②比较两个结果；③不仅写“×”，还要把正确算式完整写出来。
      </div>
    """


def application_reason(problem: dict[str, Any]) -> str:
    if problem["kind"] == "add":
        return "“又增加”和“共有”表示把两部分合起来，所以用加法。"
    if problem["kind"] == "sub":
        return "“飞走、拿走、用掉”和“还剩”表示从总数中去掉一部分，所以用减法。"
    return "事情按“原有→增加→减少”的顺序发生，所以先加再减，并且从左往右算。"


def render_application_model(problem: dict[str, Any]) -> str:
    if problem["kind"] in {"add", "sub"}:
        return base.bar_model_diagram(problem)
    labels = [
        problem["labels"][0],
        f'{problem["labels"][1]}，得{problem["values"][1]}{problem["unit"]}',
        f'{problem["labels"][2]}，得{problem["answer"]}{problem["unit"]}',
    ]
    return operation_flow_html(labels)


def render_application_answers(paper: dict[str, Any]) -> str:
    cards: list[str] = []
    for index, problem in enumerate(paper["applications"], start=1):
        if problem["kind"] == "mixed":
            detail = chain_reason(problem)
        else:
            detail = f'{problem["equation"]}'
        cards.append(
            f"""
            <div class="method-card">
              <div class="method-title">{index}. {base.esc(problem["text"])}</div>
              <p><strong>列式：{base.esc(problem["equation"])}，答：{problem["answer"]}{base.esc(problem["unit"])}。</strong></p>
              <p class="reason">判断：{base.esc(application_reason(problem))}</p>
              {render_application_model(problem)}
              <p class="reason">计算过程：{base.esc(detail)}。</p>
            </div>
            """
        )
    return f"""
      <h2>七、解决问题</h2>
      {"".join(cards)}
      <div class="answer-callout">
        <strong>应用题检查：</strong>答案应包含“算式、得数、单位、答句”。
        算完后把答案放回故事里读一遍：增加后不应无故变少，去掉后不应变多。
      </div>
    """


def render_extension_answer(paper: dict[str, Any]) -> str:
    extension = paper["extension"]
    steps = "".join(f"<li>{base.esc(step)}</li>" for step in extension["steps"])
    expression = f'，一种填法是{extension["expression"]}' if "expression" in extension else ""
    return f"""
      <h2>八、拓展思维</h2>
      <div class="method-card">
        <div class="method-title">题目：{base.esc(extension["question"])}</div>
        {operation_flow_html(extension["flow"])}
        <ol class="thinking-steps">{steps}</ol>
        <p><strong>答案：{extension["answer"]}{base.esc(expression)}。</strong></p>
      </div>
    """


def render_answer_set(paper: dict[str, Any]) -> str:
    return f"""
    <section class="answer-set">
      <h1>第{paper["number"]:02d}套答案与图解 <span class="level-chip">{base.esc(paper["level"])}</span></h1>
      {render_picture_answers(paper)}
      {render_calculation_answers(paper)}
      {render_method_answers(paper)}
      {render_chain_answers(paper)}
      {render_pattern_answers(paper)}
      {render_judge_answers(paper)}
      {render_application_answers(paper)}
      {render_extension_answer(paper)}
    </section>
    """


def render_answer_html(paper_sets: list[dict[str, Any]]) -> str:
    cover = """
    <section class="answer-cover">
      <h1>一年级20以内凑十法与破十法综合练习</h1>
      <h2>答案、详细思路与图解</h2>
      <div class="answer-note">
        <p><strong>对应内容：</strong>第01—05套专项练习。</p>
        <p><strong>使用建议：</strong>孩子先独立完成，再用答案订正。订正时不要只抄得数，
        要说清“把谁分成几和几”“先算哪一步”“为什么用加法或减法”。</p>
        <p><strong>图解说明：</strong>黑点表示原有数量，灰点表示添上的数量，叉掉的圆点表示减去；
        条形图用“整条与部分”表示数量关系，箭头图表示事情或计算发生的先后顺序。</p>
      </div>
    </section>
    """
    answer_sets = "".join(render_answer_set(paper) for paper in paper_sets)
    return f"""<!doctype html>
    <html lang="zh-CN">
      <head>
        <meta charset="utf-8">
        <title>一年级凑十破十综合练习答案与详细图解</title>
        <style>{SPECIAL_CSS}</style>
      </head>
      <body class="answer-document">{cover}{answer_sets}</body>
    </html>"""


async def render_pdf(
    page: Any,
    html_content: str,
    output_path: Path,
    *,
    expect_fixed_pages: bool,
) -> None:
    await page.set_content(html_content, wait_until="load")
    await page.emulate_media(media="print")
    await page.evaluate("() => document.fonts.ready")
    if expect_fixed_pages:
        overflows = await page.locator(".page").evaluate_all(
            """pages => pages.map((item, index) => ({
              page: index + 1,
              scrollHeight: item.scrollHeight,
              clientHeight: item.clientHeight,
              scrollWidth: item.scrollWidth,
              clientWidth: item.clientWidth,
              overflow: item.scrollHeight > item.clientHeight + 1 || item.scrollWidth > item.clientWidth + 1
            }))"""
        )
        failed = [item for item in overflows if item["overflow"]]
        if failed:
            raise RuntimeError(f"{output_path.name} 页面内容溢出：{failed}")
    await page.pdf(
        path=str(output_path),
        format="A4",
        print_background=True,
        prefer_css_page_size=True,
        margin={"top": "0", "right": "0", "bottom": "0", "left": "0"},
    )


async def build_pdfs(paper_sets: list[dict[str, Any]]) -> None:
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
        for paper in paper_sets:
            output_path = paper_pdf_path(paper["number"])
            await render_pdf(
                page,
                render_paper_html(paper),
                output_path,
                expect_fixed_pages=True,
            )
            print(f"generated {output_path.name}: {output_path.stat().st_size:,} bytes")
        await render_pdf(
            page,
            render_answer_html(paper_sets),
            ANSWER_PDF,
            expect_fixed_pages=False,
        )
        print(f"generated {ANSWER_PDF.name}: {ANSWER_PDF.stat().st_size:,} bytes")
        await browser.close()


def count_pdf_pages(path: Path) -> int:
    return len(re.findall(rb"/Type\s*/Page\b", path.read_bytes()))


def validate_outputs(paper_sets: list[dict[str, Any]]) -> None:
    expected_paths = [paper_pdf_path(paper["number"]) for paper in paper_sets] + [ANSWER_PDF]
    missing = [path.name for path in expected_paths if not path.exists()]
    if missing:
        raise RuntimeError(f"缺少PDF文件：{missing}")

    for path in expected_paths:
        if path.read_bytes()[:5] != b"%PDF-":
            raise RuntimeError(f"不是有效PDF：{path.name}")
        if path.stat().st_size < 20_000:
            raise RuntimeError(f"PDF文件过小，可能生成失败：{path.name}")

    for paper in paper_sets:
        path = paper_pdf_path(paper["number"])
        pages = count_pdf_pages(path)
        if pages != PAPER_PAGES:
            raise RuntimeError(f"{path.name}应为{PAPER_PAGES}页，实际为{pages}页。")

    answer_pages = count_pdf_pages(ANSWER_PDF)
    if answer_pages < 16:
        raise RuntimeError(f"答案册页数过少，可能缺少详细图解：{answer_pages}页。")

    print(
        json.dumps(
            {
                "paper_count": len(paper_sets),
                "paper_pages_each": PAPER_PAGES,
                "answer_pages": answer_pages,
                "output_directory": str(ROOT),
                "paper_files": [paper_pdf_path(paper["number"]).name for paper in paper_sets],
                "answer_file": ANSWER_PDF.name,
            },
            ensure_ascii=False,
            indent=2,
        )
    )


async def main() -> None:
    paper_sets = build_paper_sets()
    validate_blueprints(paper_sets)
    await build_pdfs(paper_sets)
    validate_outputs(paper_sets)


if __name__ == "__main__":
    asyncio.run(main())
