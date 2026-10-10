from __future__ import annotations

import asyncio
import json
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Iterable

import fitz
from playwright.async_api import async_playwright

import generate_grade1_papers as base


ROOT = Path(__file__).resolve().parent
TRAINING_PDF = ROOT / "一年级空间思维15天训练册_彩色打印版.pdf"
ANSWER_PDF = ROOT / "一年级空间思维15天_答案图解与家长指导_彩色打印版.pdf"

Coord = tuple[int, int, int]

PALETTE = ("#3A86FF", "#FF9F1C", "#2EC4B6", "#9B5DE5")
MARK_COLOR = "#F04444"
HIDDEN_COLOR = "#FF7A00"
DIRECTION_COLORS = {
    "front": "#E63946",
    "side": "#277DA1",
    "top": "#2A9D58",
}
DIRECTION_LABELS = {
    "front": "正面",
    "side": "侧面",
    "top": "上面",
}


@dataclass
class BlockModel:
    name: str
    cubes: frozenset[Coord]
    colors: dict[Coord, str] = field(default_factory=dict)
    marks: dict[Coord, str] = field(default_factory=dict)


def normalize_mapping(
    cubes: Iterable[Coord],
    colors: dict[Coord, str] | None = None,
    marks: dict[Coord, str] | None = None,
) -> tuple[frozenset[Coord], dict[Coord, str], dict[Coord, str]]:
    cube_list = list(cubes)
    if not cube_list:
        raise ValueError("立体模型不能为空。")
    min_x = min(coord[0] for coord in cube_list)
    min_y = min(coord[1] for coord in cube_list)
    min_z = min(coord[2] for coord in cube_list)

    def shifted(coord: Coord) -> Coord:
        return coord[0] - min_x, coord[1] - min_y, coord[2] - min_z

    normalized = frozenset(shifted(coord) for coord in cube_list)
    normalized_colors = {
        shifted(coord): color for coord, color in (colors or {}).items()
    }
    normalized_marks = {
        shifted(coord): mark for coord, mark in (marks or {}).items()
    }
    return normalized, normalized_colors, normalized_marks


def model_from_heights(
    name: str,
    rows: tuple[tuple[int, ...], ...],
    *,
    marker: Coord | None = None,
    color_mode: str = "position",
) -> BlockModel:
    cubes: set[Coord] = set()
    colors: dict[Coord, str] = {}
    marks: dict[Coord, str] = {}
    for y, row in enumerate(rows):
        for x, height in enumerate(row):
            for z in range(height):
                coord = (x, y, z)
                cubes.add(coord)
                if color_mode == "layer":
                    colors[coord] = PALETTE[z % len(PALETTE)]
                elif color_mode == "uniform":
                    colors[coord] = PALETTE[0]
                else:
                    colors[coord] = PALETTE[(x + 2 * y + z) % len(PALETTE)]
    if marker is not None:
        if marker not in cubes:
            raise ValueError(f"{name}的标记位置不在模型中：{marker}")
        colors[marker] = MARK_COLOR
        marks[marker] = "●"
    normalized, normalized_colors, normalized_marks = normalize_mapping(
        cubes, colors, marks
    )
    return BlockModel(name, normalized, normalized_colors, normalized_marks)


def rotate_model(model: BlockModel, turns: int, *, name: str | None = None) -> BlockModel:
    turns %= 4
    cubes = set(model.cubes)
    colors = dict(model.colors)
    marks = dict(model.marks)
    for _ in range(turns):
        max_x = max(coord[0] for coord in cubes)

        def rotated(coord: Coord) -> Coord:
            x, y, z = coord
            return y, max_x - x, z

        cubes = {rotated(coord) for coord in cubes}
        colors = {rotated(coord): color for coord, color in colors.items()}
        marks = {rotated(coord): mark for coord, mark in marks.items()}
        normalized, colors, marks = normalize_mapping(cubes, colors, marks)
        cubes = set(normalized)
    return BlockModel(name or f"{model.name}_转{turns * 90}度", frozenset(cubes), colors, marks)


def model_signature(
    model: BlockModel,
    *,
    include_colors: bool,
) -> tuple[Any, ...]:
    if include_colors:
        return tuple(
            sorted(
                (
                    coord,
                    model.colors.get(coord, PALETTE[0]),
                    model.marks.get(coord, ""),
                )
                for coord in model.cubes
            )
        )
    return tuple(sorted(model.cubes))


def canonical_rotation_signature(
    model: BlockModel,
    *,
    include_colors: bool,
) -> tuple[Any, ...]:
    signatures = [
        model_signature(rotate_model(model, turns), include_colors=include_colors)
        for turns in range(4)
    ]
    return min(signatures)


def is_stable(model: BlockModel) -> bool:
    return all(
        z == 0 or (x, y, z - 1) in model.cubes
        for x, y, z in model.cubes
    )


def layer_counts(model: BlockModel) -> list[int]:
    max_z = max(coord[2] for coord in model.cubes)
    return [
        sum(1 for coord in model.cubes if coord[2] == z)
        for z in range(max_z + 1)
    ]


def model_size(model: BlockModel) -> tuple[int, int, int]:
    return (
        max(coord[0] for coord in model.cubes) + 1,
        max(coord[1] for coord in model.cubes) + 1,
        max(coord[2] for coord in model.cubes) + 1,
    )


def visible_faces(model: BlockModel, coord: Coord) -> tuple[bool, bool, bool]:
    x, y, z = coord
    cubes = model.cubes
    top = (x, y, z + 1) not in cubes
    right = (x + 1, y, z) not in cubes
    left = (x, y + 1, z) not in cubes
    return top, right, left


def visible_cubes(model: BlockModel) -> frozenset[Coord]:
    return frozenset(
        coord for coord in model.cubes if any(visible_faces(model, coord))
    )


def hidden_cubes(model: BlockModel) -> frozenset[Coord]:
    return frozenset(model.cubes.difference(visible_cubes(model)))


def view_cells(
    model: BlockModel,
    direction: str,
) -> tuple[int, int, dict[tuple[int, int], str]]:
    max_x, max_y, max_z = (value - 1 for value in model_size(model))
    cells: dict[tuple[int, int], str] = {}

    if direction == "front":
        width, height = max_x + 1, max_z + 1
        for x in range(max_x + 1):
            for z in range(max_z + 1):
                candidates = [
                    coord
                    for coord in model.cubes
                    if coord[0] == x and coord[2] == z
                ]
                if candidates:
                    nearest = max(candidates, key=lambda coord: coord[1])
                    cells[(x, z)] = model.colors.get(nearest, PALETTE[0])
    elif direction == "side":
        width, height = max_y + 1, max_z + 1
        for y in range(max_y + 1):
            for z in range(max_z + 1):
                candidates = [
                    coord
                    for coord in model.cubes
                    if coord[1] == y and coord[2] == z
                ]
                if candidates:
                    nearest = max(candidates, key=lambda coord: coord[0])
                    cells[(y, z)] = model.colors.get(nearest, PALETTE[0])
    elif direction == "top":
        width, height = max_x + 1, max_y + 1
        for x in range(max_x + 1):
            for y in range(max_y + 1):
                candidates = [
                    coord
                    for coord in model.cubes
                    if coord[0] == x and coord[1] == y
                ]
                if candidates:
                    nearest = max(candidates, key=lambda coord: coord[2])
                    cells[(x, y)] = model.colors.get(nearest, PALETTE[0])
    else:
        raise ValueError(f"未知观察方向：{direction}")
    return width, height, cells


def view_signature(
    model: BlockModel,
    direction: str,
    *,
    include_colors: bool = False,
) -> tuple[Any, ...]:
    width, height, cells = view_cells(model, direction)
    entries = (
        tuple(sorted((position, color) for position, color in cells.items()))
        if include_colors
        else tuple(sorted(cells))
    )
    return width, height, entries


def build_model_bank() -> dict[str, BlockModel]:
    return {
        "A": model_from_heights(
            "四块拐角楼", ((2, 1), (1, 0)), marker=(0, 0, 1)
        ),
        "A_plain": model_from_heights(
            "四块拐角楼", ((2, 1), (1, 0)), color_mode="layer"
        ),
        "A_alt": model_from_heights(
            "四块双柱", ((2, 2),), marker=(0, 0, 1)
        ),
        "B": model_from_heights(
            "五块小台阶", ((2, 1), (1, 1)), marker=(0, 0, 1)
        ),
        "B_plain": model_from_heights(
            "五块小台阶", ((2, 1), (1, 1)), color_mode="layer"
        ),
        "B_alt": model_from_heights(
            "五块高塔", ((3, 1), (1, 0)), marker=(0, 0, 2)
        ),
        "C": model_from_heights(
            "六块双台阶", ((2, 2), (1, 1)), color_mode="layer"
        ),
        "C_mark": model_from_heights(
            "六块双台阶", ((2, 2), (1, 1)), marker=(1, 0, 1)
        ),
        "D": model_from_heights(
            "六块长台阶", ((2, 1, 1), (1, 1, 0)), color_mode="position"
        ),
        "D_mark": model_from_heights(
            "六块长台阶", ((2, 1, 1), (1, 1, 0)), marker=(0, 0, 1)
        ),
        "E": model_from_heights(
            "六块三层塔", ((3, 1), (1, 1)), color_mode="layer"
        ),
        "F": model_from_heights(
            "七块三柱台", ((2, 2), (2, 1)), color_mode="position"
        ),
        "G": model_from_heights(
            "七块高低台", ((3, 2), (1, 1)), color_mode="layer"
        ),
        "H": model_from_heights(
            "八块双层平台", ((2, 2, 1), (1, 1, 1)), color_mode="position"
        ),
        "I": model_from_heights(
            "八块方平台", ((2, 2), (2, 2)), color_mode="layer"
        ),
        "J": model_from_heights(
            "七块长高塔", ((3, 1, 1), (1, 1, 0)), color_mode="position"
        ),
        "K": model_from_heights(
            "七块双塔", ((2, 1, 2), (1, 1, 0)), color_mode="position"
        ),
        "L": model_from_heights(
            "八块错层台", ((2, 2, 1), (2, 0, 1)), color_mode="layer"
        ),
    }


def rotation_task(
    prompt: str,
    base_model: BlockModel,
    options: list[BlockModel],
    *,
    turns: int | None,
    answer: int,
    include_colors: bool,
    explanation: str,
) -> dict[str, Any]:
    return {
        "kind": "rotation",
        "prompt": prompt,
        "base": base_model,
        "options": options,
        "turns": turns,
        "answer": answer,
        "include_colors": include_colors,
        "explanation": explanation,
    }


def build_task(
    prompt: str,
    model: BlockModel,
    *,
    explanation: str,
) -> dict[str, Any]:
    return {
        "kind": "build",
        "prompt": prompt,
        "model": model,
        "answer_layers": layer_counts(model),
        "answer_total": len(model.cubes),
        "explanation": explanation,
    }


def view_task(
    prompt: str,
    model: BlockModel,
    direction: str,
    options: list[tuple[BlockModel, str]],
    *,
    answer: int,
    explanation: str,
) -> dict[str, Any]:
    return {
        "kind": "view",
        "prompt": prompt,
        "model": model,
        "direction": direction,
        "options": options,
        "answer": answer,
        "explanation": explanation,
    }


def reverse_task(
    prompt: str,
    target: BlockModel,
    directions: tuple[str, str],
    options: list[BlockModel],
    *,
    answer: int,
    explanation: str,
) -> dict[str, Any]:
    return {
        "kind": "reverse",
        "prompt": prompt,
        "target": target,
        "directions": directions,
        "options": options,
        "answer": answer,
        "explanation": explanation,
    }


def hidden_task(
    prompt: str,
    model: BlockModel,
    *,
    explanation: str,
) -> dict[str, Any]:
    hidden = hidden_cubes(model)
    return {
        "kind": "hidden",
        "prompt": prompt,
        "model": model,
        "answer_visible": len(visible_cubes(model)),
        "answer_hidden": len(hidden),
        "answer_total": len(model.cubes),
        "explanation": explanation,
    }


def build_lessons() -> list[dict[str, Any]]:
    models = build_model_bank()
    a = models["A"]
    b = models["B"]
    d_mark = models["D_mark"]

    lessons: list[dict[str, Any]] = [
        {
            "day": 1,
            "phase": "旋转入门",
            "title": "跟着红色标记转一转",
            "goal": "整体转动时，积木之间的连接关系不会改变。",
            "material": "4块正方体积木；用磁力片或贴纸标记红色积木。",
            "tasks": [
                build_task(
                    "照图搭好模型，说一说红色积木在第几层。",
                    a,
                    explanation="先搭底层3块，再把红色积木放在拐角上方。",
                ),
                rotation_task(
                    "把左图向右转90°，圈出转动后的样子。",
                    a,
                    [models["A_alt"], rotate_model(a, 1), rotate_model(a, 3)],
                    turns=1,
                    answer=1,
                    include_colors=True,
                    explanation="红色积木仍压在同一块积木上；只是方向改变，连接关系没有改变。",
                ),
            ],
            "speech": "你怎样知道它只是转动，并没有拆开重搭？",
        },
        {
            "day": 2,
            "phase": "旋转入门",
            "title": "转半圈以后在哪里",
            "goal": "追踪标记积木旋转180°后的位置。",
            "material": "5块正方体积木；保留红色标记。",
            "tasks": [
                rotation_task(
                    "把模型转180°，圈出正确图片。",
                    b,
                    [rotate_model(b, 1), models["B_alt"], rotate_model(b, 2)],
                    turns=2,
                    answer=2,
                    include_colors=True,
                    explanation="转180°等于连续向右转两次；红色积木会到对角方向。",
                ),
                rotation_task(
                    "把模型向右转90°，哪幅图中的红色积木位置正确？",
                    a,
                    [rotate_model(a, 2), rotate_model(a, 1), models["A_alt"]],
                    turns=1,
                    answer=1,
                    include_colors=True,
                    explanation="先看红色积木下面是谁，再看它旁边是哪两块，三条关系都要保持。",
                ),
            ],
            "speech": "转180°可以分成哪两次转动？",
        },
        {
            "day": 3,
            "phase": "旋转进阶",
            "title": "长模型也能整体转",
            "goal": "模型变长后，仍能追踪最高块和缺角。",
            "material": "6块积木；桌面留出转动空间。",
            "tasks": [
                build_task(
                    "从底层开始，照图搭出六块长台阶。",
                    d_mark,
                    explanation="先摆底层的5块，再把红色积木放到指定位置上方。",
                ),
                rotation_task(
                    "把模型向右转90°，圈出正确图片。",
                    d_mark,
                    [rotate_model(d_mark, 3), rotate_model(d_mark, 1), models["C_mark"]],
                    turns=1,
                    answer=1,
                    include_colors=True,
                    explanation="长边会换方向，但最高块、缺角和相邻关系都不能改变。",
                ),
            ],
            "speech": "你先追踪红色积木，还是先追踪缺角？为什么？",
        },
        {
            "day": 4,
            "phase": "旋转判断",
            "title": "只是转动，还是结构变了",
            "goal": "不依赖固定方向，比较模型的连接结构。",
            "material": "6块积木；今天可以不使用颜色标记。",
            "tasks": [
                rotation_task(
                    "下面只有一幅图能由左图整体转动得到，把它圈出来。",
                    models["C"],
                    [models["E"], rotate_model(models["C"], 1), models["D"]],
                    turns=None,
                    answer=1,
                    include_colors=False,
                    explanation="数每根柱子的高度，并比较高柱之间是否相邻；方向可以变，结构不能变。",
                ),
                build_task(
                    "搭出左图，再试着转动实物核对你的选择。",
                    models["C"],
                    explanation="用实物验证不是偷看答案，而是在脑中判断后检查空间表象。",
                ),
            ],
            "speech": "哪个地方一旦改变，就说明不是同一个模型？",
        },
        {
            "day": 5,
            "phase": "第1次检查",
            "title": "旋转与结构检查",
            "goal": "三次判断中至少独立做对两次。",
            "material": "先看图完成，全部作答后再用积木验证。",
            "checkpoint": True,
            "tasks": [
                rotation_task(
                    "① 向右转90°。",
                    a,
                    [rotate_model(a, 1), rotate_model(a, 2), models["A_alt"]],
                    turns=1,
                    answer=0,
                    include_colors=True,
                    explanation="核对红色积木和缺角位置。",
                ),
                rotation_task(
                    "② 转180°。",
                    b,
                    [models["B_alt"], rotate_model(b, 2), rotate_model(b, 1)],
                    turns=2,
                    answer=1,
                    include_colors=True,
                    explanation="连续转两次90°，不是只换一次方向。",
                ),
                rotation_task(
                    "③ 只判断结构是否相同。",
                    models["C"],
                    [models["D"], models["E"], rotate_model(models["C"], 3)],
                    turns=None,
                    answer=2,
                    include_colors=False,
                    explanation="逐柱比较高度和相邻关系。",
                ),
            ],
            "speech": "哪一道最难？你用什么线索检查？",
        },
        {
            "day": 6,
            "phase": "看图搭建",
            "title": "从底层一层一层搭",
            "goal": "根据彩色立体图确定每层块数。",
            "material": "准备6块积木；每搭完一层先停下来核对。",
            "tasks": [
                build_task(
                    "照图搭六块长台阶，并在空格中记录每层数量。",
                    models["D"],
                    explanation="底层有5块，第二层有1块，共6块。",
                ),
                build_task(
                    "照图搭三层小塔，按第一层、第二层、第三层记录。",
                    models["E"],
                    explanation="从底向上分别是4块、1块、1块，共6块。",
                ),
            ],
            "speech": "为什么搭建时要先找底层，而不是先搭最高的积木？",
        },
        {
            "day": 7,
            "phase": "方向视图",
            "title": "小人站在正面看",
            "goal": "固定红色正面方向，把立体模型压成平面格子图。",
            "material": "用一个小人或红色磁力片放在模型正面。",
            "tasks": [
                view_task(
                    "从红色“正面”方向看，圈出看到的图。",
                    models["C"],
                    "front",
                    [
                        (models["C"], "side"),
                        (models["C"], "front"),
                        (models["A_plain"], "top"),
                    ],
                    answer=1,
                    explanation="正面看时，前后重合的积木只占同一列，按每列最高处画格子。",
                ),
                view_task(
                    "从绿色“上面”方向看，圈出看到的图。",
                    models["D"],
                    "top",
                    [
                        (models["D"], "front"),
                        (models["D"], "top"),
                        (models["D"], "side"),
                    ],
                    answer=1,
                    explanation="上面看只关心哪些位置放了积木，不看每根柱子有多高。",
                ),
            ],
            "speech": "为什么从上面看时，两层高的柱子仍只画一个格子？",
        },
        {
            "day": 8,
            "phase": "方向视图",
            "title": "换到侧面再看一次",
            "goal": "区分正面、侧面和上面三个观察位置。",
            "material": "观察者不动，只转动模型并保持方向箭头。",
            "tasks": [
                view_task(
                    "从蓝色“侧面”方向看，圈出正确图。",
                    models["E"],
                    "side",
                    [
                        (models["E"], "top"),
                        (models["D"], "front"),
                        (models["E"], "side"),
                    ],
                    answer=2,
                    explanation="侧面看会把左右方向上的积木重合起来，再比较每列高度。",
                ),
                view_task(
                    "从红色“正面”方向看七块模型。",
                    models["F"],
                    "front",
                    [
                        (models["F"], "front"),
                        (models["A_plain"], "top"),
                        (models["E"], "front"),
                    ],
                    answer=0,
                    explanation="先找到正面箭头，再从左到右比较最高层数。",
                ),
            ],
            "speech": "正面图和侧面图为什么有时会相同？",
        },
        {
            "day": 9,
            "phase": "视图反推",
            "title": "看两张平面图找模型",
            "goal": "同时使用两个观察方向排除错误模型。",
            "material": "先不搭积木；选完后再搭模型验证。",
            "tasks": [
                reverse_task(
                    "根据正面图和上面图，圈出对应的模型。",
                    models["D"],
                    ("front", "top"),
                    [models["E"], models["D"], models["C"]],
                    answer=1,
                    explanation="上面图决定底面位置，正面图再决定每列至少要多高。",
                ),
                reverse_task(
                    "根据侧面图和上面图，圈出对应的模型。",
                    models["G"],
                    ("side", "top"),
                    [models["F"], models["J"], models["G"]],
                    answer=2,
                    explanation="先用上面图排除底面形状不同的模型，再用侧面高度确定答案。",
                ),
            ],
            "speech": "只看一张视图为什么可能不够？",
        },
        {
            "day": 10,
            "phase": "第2次检查",
            "title": "搭建与视图检查",
            "goal": "三道大题至少完整做对两道。",
            "material": "先独立判断，最后统一用积木复核。",
            "checkpoint": True,
            "tasks": [
                view_task(
                    "① 从正面看。",
                    models["C"],
                    "front",
                    [
                        (models["A_plain"], "top"),
                        (models["C"], "front"),
                        (models["C"], "side"),
                    ],
                    answer=1,
                    explanation="先固定正面箭头，再比较每列高度。",
                ),
                view_task(
                    "② 从上面看。",
                    models["D"],
                    "top",
                    [
                        (models["D"], "side"),
                        (models["D"], "front"),
                        (models["D"], "top"),
                    ],
                    answer=2,
                    explanation="上面图只记录占地位置。",
                ),
                reverse_task(
                    "③ 根据正面图和上面图选模型。",
                    models["E"],
                    ("front", "top"),
                    [models["D"], models["E"], models["C"]],
                    answer=1,
                    explanation="两张图必须同时符合，不能只核对其中一张。",
                ),
            ],
            "speech": "你最容易把哪两个方向混在一起？",
        },
        {
            "day": 11,
            "phase": "隐藏积木",
            "title": "上面有积木，下面要有支撑",
            "goal": "按层计数，主动补出看不见的支撑块。",
            "material": "准备8块积木；先猜，再拆成一层一层验证。",
            "tasks": [
                hidden_task(
                    "搭成图中的方平台。看不见的支撑块有几块？一共几块？",
                    models["I"],
                    explanation="按层数：底层4块、第二层4块；其中有支撑块被外层挡住。",
                ),
                hidden_task(
                    "搭成错层平台，分别写出看得见、藏住和总块数。",
                    models["H"],
                    explanation="不能只数画出来的顶面；上层每一块下面都必须有支撑。",
                ),
            ],
            "speech": "哪一块虽然看不到，却一定存在？",
        },
        {
            "day": 12,
            "phase": "隐藏积木",
            "title": "至少需要多少块",
            "goal": "利用支撑关系求完整模型的最少块数。",
            "material": "先圈出上层积木，再逐个检查它们下面。",
            "tasks": [
                hidden_task(
                    "要搭成图中的双层平台，至少需要多少块？",
                    models["H"],
                    explanation="先数底层，再数第二层；被遮住不等于不存在。",
                ),
                hidden_task(
                    "要搭成方平台，最少需要多少块？藏住了几块？",
                    models["I"],
                    explanation="四根柱子都高2层，因此每根柱子需要2块。",
                ),
            ],
            "speech": "“看到几个面”和“用了几块积木”为什么不是一回事？",
        },
        {
            "day": 13,
            "phase": "旋转与视图",
            "title": "模型转了，视图也会变",
            "goal": "先完成旋转，再从固定方向观察。",
            "material": "用7块积木搭模型；红色正面小人保持不动。",
            "tasks": [
                rotation_task(
                    "把模型向右转90°，圈出正确图。",
                    models["G"],
                    [models["F"], rotate_model(models["G"], 1), rotate_model(models["G"], 2)],
                    turns=1,
                    answer=1,
                    include_colors=False,
                    explanation="模型整体转动后，柱高关系不变，但它们相对正面的左右位置改变。",
                ),
                view_task(
                    "上题模型转90°后，从正面看是哪幅图？",
                    rotate_model(models["G"], 1),
                    "front",
                    [
                        (models["G"], "front"),
                        (rotate_model(models["G"], 1), "front"),
                        (models["G"], "top"),
                    ],
                    answer=1,
                    explanation="必须先在脑中完成转动，再从不动的红色正面方向观察。",
                ),
            ],
            "speech": "是观察者转了，还是模型转了？这会怎样影响答案？",
        },
        {
            "day": 14,
            "phase": "综合推理",
            "title": "两张视图和隐藏块一起想",
            "goal": "把视图反推与按层计数结合起来。",
            "material": "准备8块积木；选择后搭出来并拆层计数。",
            "tasks": [
                reverse_task(
                    "根据正面图和上面图，圈出对应模型。",
                    models["H"],
                    ("front", "top"),
                    [models["L"], models["H"], models["I"]],
                    answer=1,
                    explanation="先用上面图确定6个占地位置，再用正面图确定两根高柱。",
                ),
                hidden_task(
                    "模型选对后，再写出藏住和总块数。",
                    models["H"],
                    explanation="反推模型后仍要按层计数，不能把视图中的格子数当成立体块数。",
                ),
            ],
            "speech": "哪张视图帮助你确定位置，哪张帮助你确定高度？",
        },
        {
            "day": 15,
            "phase": "最终复测",
            "title": "空间思维综合检查",
            "goal": "独立完成旋转、视图反推和隐藏计数。",
            "material": "三道题全部完成后再使用积木验证。",
            "checkpoint": True,
            "tasks": [
                rotation_task(
                    "① 向右转90°。",
                    models["D_mark"],
                    [rotate_model(models["D_mark"], 2), rotate_model(models["D_mark"], 1), models["C_mark"]],
                    turns=1,
                    answer=1,
                    include_colors=True,
                    explanation="同时追踪红色积木、最高层和缺角。",
                ),
                reverse_task(
                    "② 根据侧面图和上面图选模型。",
                    models["G"],
                    ("side", "top"),
                    [models["K"], models["G"], models["F"]],
                    answer=1,
                    explanation="两张视图必须同时符合。",
                ),
                hidden_task(
                    "③ 写出藏住和总块数。",
                    models["H"],
                    explanation="按层数，并检查每个上层积木的支撑。",
                ),
            ],
            "speech": "与第1天相比，你现在会先看哪些空间线索？",
        },
    ]
    return lessons


def validate_curriculum(lessons: list[dict[str, Any]]) -> None:
    if len(lessons) != 15 or [item["day"] for item in lessons] != list(range(1, 16)):
        raise ValueError("训练内容必须完整包含第1—15天。")
    if [item["day"] for item in lessons if item.get("checkpoint")] != [5, 10, 15]:
        raise ValueError("阶段检查必须安排在第5、10、15天。")

    for lesson in lessons:
        if not 2 <= len(lesson["tasks"]) <= 3:
            raise ValueError(f'第{lesson["day"]}天题目数量不适合一页：{len(lesson["tasks"])}')
        for task in lesson["tasks"]:
            models: list[BlockModel] = []
            if task["kind"] == "rotation":
                models = [task["base"], *task["options"]]
                include_colors = task["include_colors"]
                if task["turns"] is None:
                    target_signature = canonical_rotation_signature(
                        task["base"], include_colors=include_colors
                    )
                    matches = [
                        canonical_rotation_signature(option, include_colors=include_colors)
                        == target_signature
                        for option in task["options"]
                    ]
                else:
                    expected = rotate_model(task["base"], task["turns"])
                    expected_signature = model_signature(
                        expected, include_colors=include_colors
                    )
                    matches = [
                        model_signature(option, include_colors=include_colors)
                        == expected_signature
                        for option in task["options"]
                    ]
                if matches.count(True) != 1 or not matches[task["answer"]]:
                    raise ValueError(
                        f'第{lesson["day"]}天旋转题答案不唯一或标注错误：{matches}'
                    )
            elif task["kind"] == "build":
                models = [task["model"]]
                if task["answer_layers"] != layer_counts(task["model"]):
                    raise ValueError("分层答案不一致。")
                if task["answer_total"] != len(task["model"].cubes):
                    raise ValueError("搭建总块数答案不一致。")
            elif task["kind"] == "view":
                models = [task["model"], *(item[0] for item in task["options"])]
                target = view_signature(task["model"], task["direction"])
                option_signatures = [
                    view_signature(model, direction)
                    for model, direction in task["options"]
                ]
                matches = [signature == target for signature in option_signatures]
                if matches.count(True) != 1 or not matches[task["answer"]]:
                    raise ValueError(
                        f'第{lesson["day"]}天视图题答案不唯一或标注错误：{matches}'
                    )
            elif task["kind"] == "reverse":
                models = [task["target"], *task["options"]]
                target = tuple(
                    view_signature(task["target"], direction)
                    for direction in task["directions"]
                )
                matches = [
                    tuple(view_signature(model, direction) for direction in task["directions"])
                    == target
                    for model in task["options"]
                ]
                if matches.count(True) != 1 or not matches[task["answer"]]:
                    raise ValueError(
                        f'第{lesson["day"]}天反推题答案不唯一或标注错误：{matches}'
                    )
            elif task["kind"] == "hidden":
                models = [task["model"]]
                if task["answer_hidden"] != len(hidden_cubes(task["model"])):
                    raise ValueError("隐藏块答案不一致。")
                if task["answer_visible"] + task["answer_hidden"] != task["answer_total"]:
                    raise ValueError("可见块、隐藏块和总数不一致。")
            else:
                raise ValueError(f'未知题型：{task["kind"]}')

            for model in models:
                if not is_stable(model):
                    raise ValueError(f"模型存在悬空积木：{model.name}")
                if not 3 <= len(model.cubes) <= 8:
                    raise ValueError(f"模型块数不适合一年级：{model.name}，{len(model.cubes)}块")


def _hex_to_rgb(color: str) -> tuple[int, int, int]:
    color = color.lstrip("#")
    return int(color[0:2], 16), int(color[2:4], 16), int(color[4:6], 16)


def _mix_color(color: str, target: str, ratio: float) -> str:
    source_rgb = _hex_to_rgb(color)
    target_rgb = _hex_to_rgb(target)
    mixed = tuple(
        round(source + (destination - source) * ratio)
        for source, destination in zip(source_rgb, target_rgb)
    )
    return "#" + "".join(f"{value:02X}" for value in mixed)


def _fmt_point(point: tuple[float, float]) -> str:
    return f"{point[0]:.1f},{point[1]:.1f}"


def _polygon(points: Iterable[tuple[float, float]]) -> str:
    return " ".join(_fmt_point(point) for point in points)


def _raw_cube_faces(
    coord: Coord,
) -> dict[str, tuple[tuple[float, float], ...]]:
    x, y, z = coord
    width = 48.0
    depth = 24.0
    cube_height = 36.0
    center_x = (x - y) * width / 2
    top_y = (x + y) * depth / 2 - z * cube_height

    top_point = (center_x, top_y)
    right_point = (center_x + width / 2, top_y + depth / 2)
    bottom_point = (center_x, top_y + depth)
    left_point = (center_x - width / 2, top_y + depth / 2)
    lower_bottom = (center_x, top_y + depth + cube_height)
    lower_right = (center_x + width / 2, top_y + depth / 2 + cube_height)
    lower_left = (center_x - width / 2, top_y + depth / 2 + cube_height)
    return {
        "top": (top_point, right_point, bottom_point, left_point),
        "right": (right_point, bottom_point, lower_bottom, lower_right),
        "left": (left_point, bottom_point, lower_bottom, lower_left),
    }


def _iso_transform(model: BlockModel) -> tuple[float, float, float]:
    points = [
        point
        for coord in model.cubes
        for face in _raw_cube_faces(coord).values()
        for point in face
    ]
    min_x = min(point[0] for point in points)
    max_x = max(point[0] for point in points)
    min_y = min(point[1] for point in points)
    max_y = max(point[1] for point in points)
    source_width = max(max_x - min_x, 1)
    source_height = max(max_y - min_y, 1)
    scale = min(252 / source_width, 142 / source_height, 1.35)
    offset_x = 150 - (min_x + max_x) * scale / 2
    offset_y = 84 - (min_y + max_y) * scale / 2
    return scale, offset_x, offset_y


def _transform_face(
    points: Iterable[tuple[float, float]],
    transform: tuple[float, float, float],
) -> tuple[tuple[float, float], ...]:
    scale, offset_x, offset_y = transform
    return tuple(
        (point[0] * scale + offset_x, point[1] * scale + offset_y)
        for point in points
    )


def _arrow_svg(
    start: tuple[float, float],
    end: tuple[float, float],
    color: str,
    label: str,
    label_at: tuple[float, float],
) -> str:
    start_x, start_y = start
    end_x, end_y = end
    dx = end_x - start_x
    dy = end_y - start_y
    length = max((dx * dx + dy * dy) ** 0.5, 1)
    unit_x = dx / length
    unit_y = dy / length
    side_x = -unit_y
    side_y = unit_x
    tip = (end_x, end_y)
    base_center = (end_x - unit_x * 10, end_y - unit_y * 10)
    p2 = (base_center[0] + side_x * 5, base_center[1] + side_y * 5)
    p3 = (base_center[0] - side_x * 5, base_center[1] - side_y * 5)
    return (
        f'<line x1="{start_x}" y1="{start_y}" x2="{end_x - unit_x * 5:.1f}" '
        f'y2="{end_y - unit_y * 5:.1f}" stroke="{color}" stroke-width="4" '
        'stroke-linecap="round"/>'
        f'<polygon points="{_polygon((tip, p2, p3))}" fill="{color}"/>'
        f'<text x="{label_at[0]}" y="{label_at[1]}" text-anchor="middle" '
        f'font-size="13" font-weight="700" fill="{color}">{base.esc(label)}</text>'
    )


def isometric_svg(
    model: BlockModel,
    *,
    size: str = "medium",
    show_directions: bool = True,
    reveal_hidden: bool = False,
    label: str | None = None,
) -> str:
    transform = _iso_transform(model)
    pieces: list[str] = [
        f'<svg class="iso-svg {size}" viewBox="0 0 300 210" '
        'xmlns="http://www.w3.org/2000/svg" role="img" '
        f'aria-label="{base.esc(label or model.name)}">'
    ]
    pieces.append(
        '<path d="M34 150 H266" stroke="#D7E1EE" stroke-width="1.2" '
        'stroke-dasharray="5 5"/>'
    )

    draw_order = sorted(
        model.cubes,
        key=lambda coord: (coord[0] + coord[1] + coord[2], coord[2], coord[1], coord[0]),
    )
    for coord in draw_order:
        top_visible, right_visible, left_visible = visible_faces(model, coord)
        face_points = {
            name: _transform_face(points, transform)
            for name, points in _raw_cube_faces(coord).items()
        }
        color = model.colors.get(coord, PALETTE[0])
        top_color = _mix_color(color, "#FFFFFF", 0.35)
        right_color = _mix_color(color, "#FFFFFF", 0.08)
        left_color = _mix_color(color, "#000000", 0.18)
        if left_visible:
            pieces.append(
                f'<polygon points="{_polygon(face_points["left"])}" '
                f'fill="{left_color}" stroke="#172033" stroke-width="1.5" '
                'stroke-linejoin="round"/>'
            )
        if right_visible:
            pieces.append(
                f'<polygon points="{_polygon(face_points["right"])}" '
                f'fill="{right_color}" stroke="#172033" stroke-width="1.5" '
                'stroke-linejoin="round"/>'
            )
        if top_visible:
            pieces.append(
                f'<polygon points="{_polygon(face_points["top"])}" '
                f'fill="{top_color}" stroke="#172033" stroke-width="1.5" '
                'stroke-linejoin="round"/>'
            )
            if coord in model.marks:
                center_x = sum(point[0] for point in face_points["top"]) / 4
                center_y = sum(point[1] for point in face_points["top"]) / 4
                pieces.append(
                    f'<circle cx="{center_x:.1f}" cy="{center_y:.1f}" r="5.5" '
                    'fill="#FFFFFF" stroke="#9D1C25" stroke-width="1.5"/>'
                )

    if reveal_hidden:
        for coord in sorted(hidden_cubes(model)):
            face_points = {
                name: _transform_face(points, transform)
                for name, points in _raw_cube_faces(coord).items()
            }
            for face in ("left", "right", "top"):
                pieces.append(
                    f'<polygon points="{_polygon(face_points[face])}" '
                    f'fill="{HIDDEN_COLOR}" fill-opacity="0.18" '
                    f'stroke="{HIDDEN_COLOR}" stroke-width="2.2" '
                    'stroke-dasharray="6 4" stroke-linejoin="round"/>'
                )

    if show_directions:
        pieces.append(
            _arrow_svg(
                (36, 190),
                (106, 154),
                DIRECTION_COLORS["front"],
                "正面",
                (38, 207),
            )
        )
        pieces.append(
            _arrow_svg(
                (264, 190),
                (194, 154),
                DIRECTION_COLORS["side"],
                "侧面",
                (262, 207),
            )
        )
        pieces.append(
            _arrow_svg(
                (274, 40),
                (244, 66),
                DIRECTION_COLORS["top"],
                "上面",
                (268, 28),
            )
        )
    if label:
        pieces.append(
            f'<text x="150" y="205" text-anchor="middle" font-size="12" '
            f'font-weight="700" fill="#344054">{base.esc(label)}</text>'
        )
    pieces.append("</svg>")
    return "".join(pieces)


def view_grid_svg(
    model: BlockModel,
    direction: str,
    *,
    size: str = "small",
    show_label: bool = True,
) -> str:
    width, height, cells = view_cells(model, direction)
    cell_size = min(34, 88 / max(width, height))
    grid_width = width * cell_size
    grid_height = height * cell_size
    origin_x = (150 - grid_width) / 2
    origin_y = 58 - grid_height / 2
    color = DIRECTION_COLORS[direction]
    pieces = [
        f'<svg class="view-svg {size}" viewBox="0 0 150 116" '
        'xmlns="http://www.w3.org/2000/svg" role="img" '
        f'aria-label="{DIRECTION_LABELS[direction]}视图">'
    ]
    if show_label:
        pieces.append(
            f'<rect x="47" y="2" width="56" height="22" rx="11" '
            f'fill="{color}" fill-opacity="0.13" stroke="{color}"/>'
            f'<text x="75" y="17" text-anchor="middle" font-size="13" '
            f'font-weight="700" fill="{color}">{DIRECTION_LABELS[direction]}视图</text>'
        )
    for row in range(height):
        for column in range(width):
            source_y = height - 1 - row
            fill = cells.get((column, source_y), "#FFFFFF")
            x = origin_x + column * cell_size
            y = origin_y + row * cell_size + 18
            pieces.append(
                f'<rect x="{x:.1f}" y="{y:.1f}" width="{cell_size:.1f}" '
                f'height="{cell_size:.1f}" fill="{fill}" '
                'stroke="#172033" stroke-width="1.6"/>'
            )
            if fill == MARK_COLOR:
                pieces.append(
                    f'<circle cx="{x + cell_size / 2:.1f}" '
                    f'cy="{y + cell_size / 2:.1f}" r="{cell_size * 0.13:.1f}" '
                    'fill="#FFFFFF" stroke="#9D1C25" stroke-width="1"/>'
                )
    if direction == "top":
        y = origin_y + grid_height + 25
        pieces.append(
            f'<line x1="{origin_x:.1f}" y1="{y:.1f}" '
            f'x2="{origin_x + grid_width:.1f}" y2="{y:.1f}" '
            f'stroke="{DIRECTION_COLORS["front"]}" stroke-width="2.5"/>'
            f'<text x="75" y="{y + 12:.1f}" text-anchor="middle" '
            f'font-size="10" font-weight="700" fill="{DIRECTION_COLORS["front"]}">'
            "红线这一边朝正面</text>"
        )
    pieces.append("</svg>")
    return "".join(pieces)


def layer_grid_svg(
    model: BlockModel,
    layer: int,
    *,
    filled: bool,
    size: str = "small",
) -> str:
    width, depth, _ = model_size(model)
    cell_size = min(32, 82 / max(width, depth))
    grid_width = width * cell_size
    grid_height = depth * cell_size
    origin_x = (140 - grid_width) / 2
    origin_y = 31
    pieces = [
        f'<svg class="layer-svg {size}" viewBox="0 0 140 120" '
        'xmlns="http://www.w3.org/2000/svg" role="img" '
        f'aria-label="第{layer + 1}层方格图">'
        f'<text x="70" y="17" text-anchor="middle" font-size="13" '
        f'font-weight="700" fill="#344054">第{layer + 1}层</text>'
    ]
    for y in range(depth):
        for x in range(width):
            coord = (x, y, layer)
            fill = (
                model.colors.get(coord, "#FFFFFF")
                if filled and coord in model.cubes
                else "#FFFFFF"
            )
            cell_x = origin_x + x * cell_size
            cell_y = origin_y + y * cell_size
            pieces.append(
                f'<rect x="{cell_x:.1f}" y="{cell_y:.1f}" '
                f'width="{cell_size:.1f}" height="{cell_size:.1f}" '
                f'fill="{fill}" stroke="#172033" stroke-width="1.4"/>'
            )
            if filled and coord in model.marks:
                pieces.append(
                    f'<circle cx="{cell_x + cell_size / 2:.1f}" '
                    f'cy="{cell_y + cell_size / 2:.1f}" r="{cell_size * 0.13:.1f}" '
                    'fill="#FFFFFF" stroke="#9D1C25" stroke-width="1"/>'
                )
    front_y = origin_y + grid_height + 7
    pieces.append(
        f'<line x1="{origin_x:.1f}" y1="{front_y:.1f}" '
        f'x2="{origin_x + grid_width:.1f}" y2="{front_y:.1f}" '
        f'stroke="{DIRECTION_COLORS["front"]}" stroke-width="2.4"/>'
        f'<text x="70" y="{front_y + 13:.1f}" text-anchor="middle" '
        f'font-size="10" font-weight="700" fill="{DIRECTION_COLORS["front"]}">'
        "正面</text></svg>"
    )
    return "".join(pieces)


SPATIAL_CSS = r"""
.spatial-page,
.answer-day,
.guide-page,
.cover-page {
  padding: 8mm 10mm 8mm;
  color: #172033;
  font-size: 10.2pt;
  line-height: 1.32;
  background:
    radial-gradient(circle at 92% 4%, rgba(58,134,255,.09), transparent 34mm),
    #fff;
}
.spatial-page { display: flex; flex-direction: column; }
.day-header {
  display: grid;
  grid-template-columns: 22mm 1fr auto;
  align-items: center;
  gap: 3mm;
  padding: 2.2mm 3mm;
  border: 1.2pt solid #3A86FF;
  border-radius: 4mm;
  background: linear-gradient(100deg, #EDF5FF, #FFFFFF);
}
.day-number {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 20mm;
  height: 20mm;
  border-radius: 50%;
  color: #fff;
  background: #3A86FF;
  font-weight: 800;
  line-height: 1.05;
}
.day-number strong { font-size: 17pt; }
.day-number span { font-size: 8pt; }
.day-title h1 {
  margin: 0;
  color: #173B70;
  font-size: 17pt;
  line-height: 1.15;
  letter-spacing: .03em;
}
.day-title p { margin: 1mm 0 0; color: #475467; font-size: 9pt; }
.phase-chip {
  padding: 1.3mm 2.6mm;
  border-radius: 999px;
  color: #173B70;
  background: #D9E9FF;
  font-size: 9pt;
  font-weight: 700;
  white-space: nowrap;
}
.routine-strip {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 1mm;
  margin: 2mm 0 0;
  font-size: 7.8pt;
  text-align: center;
}
.routine-strip span {
  padding: .8mm .5mm;
  border-radius: 2mm;
  color: #344054;
  background: #F2F4F7;
}
.routine-strip span:nth-child(1) { background: #EAF2FF; }
.routine-strip span:nth-child(2) { background: #E8F8F4; }
.routine-strip span:nth-child(3) { background: #FFF3E1; }
.routine-strip span:nth-child(4) { background: #F4ECFF; }
.routine-strip span:nth-child(5) { background: #FFEDEF; }
.goal-material {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2mm;
  margin-top: 2mm;
}
.goal-box,
.material-box {
  min-height: 12mm;
  padding: 1.5mm 2mm;
  border-radius: 2.5mm;
  font-size: 8.8pt;
}
.goal-box { border-left: 3pt solid #2EC4B6; background: #EAF9F5; }
.material-box { border-left: 3pt solid #FF9F1C; background: #FFF4E5; }
.goal-box b,
.material-box b { display: inline-block; margin-right: 1mm; color: #172033; }
.task-stack {
  display: flex;
  flex: 1 1 auto;
  flex-direction: column;
  justify-content: space-evenly;
  gap: 2mm;
  min-height: 0;
  margin-top: 2mm;
}
.task-card {
  position: relative;
  padding: 1.8mm 2.2mm 1.6mm;
  border: 1pt solid #98A2B3;
  border-radius: 3mm;
  background: rgba(255,255,255,.96);
  break-inside: avoid;
}
.task-card.compact { padding: 1mm 1.5mm; }
.task-prompt {
  margin: 0 0 1mm;
  color: #172033;
  font-size: 10pt;
  font-weight: 700;
  line-height: 1.28;
}
.task-tag {
  display: inline-block;
  margin-right: 1.4mm;
  padding: .6mm 1.4mm;
  border-radius: 999px;
  color: #fff;
  background: #3A86FF;
  font-size: 7.8pt;
  vertical-align: 1px;
}
.task-card[data-kind="build"] .task-tag { background: #2A9D58; }
.task-card[data-kind="view"] .task-tag { background: #277DA1; }
.task-card[data-kind="reverse"] .task-tag { background: #7950B6; }
.task-card[data-kind="hidden"] .task-tag { background: #E76F00; }
.rotation-layout {
  display: grid;
  grid-template-columns: 40mm 14mm 1fr;
  align-items: center;
  gap: 1mm;
}
.rotation-before,
.model-panel {
  text-align: center;
}
.turn-symbol {
  color: #3A86FF;
  font-size: 23pt;
  font-weight: 800;
  line-height: .9;
  text-align: center;
}
.turn-symbol small {
  display: block;
  margin-top: 1mm;
  color: #475467;
  font-size: 7pt;
  line-height: 1.1;
}
.option-row {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1mm;
  align-items: stretch;
}
.diagram-option {
  position: relative;
  display: flex;
  min-width: 0;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: .6mm;
  border: 1pt solid #D0D5DD;
  border-radius: 2mm;
  background: #fff;
}
.diagram-option.correct {
  border: 2pt solid #2A9D58;
  background: #EDFAF3;
}
.choice-letter {
  position: absolute;
  top: 1mm;
  left: 1mm;
  z-index: 2;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 6mm;
  height: 6mm;
  border: 1.2pt solid #344054;
  border-radius: 50%;
  background: #fff;
  font-size: 8pt;
  font-weight: 700;
}
.correct .choice-letter {
  color: #fff;
  border-color: #2A9D58;
  background: #2A9D58;
}
.correct-check {
  position: absolute;
  top: .8mm;
  right: 1mm;
  color: #167A45;
  font-size: 11pt;
  font-weight: 900;
}
.build-layout {
  display: grid;
  grid-template-columns: 51mm 1fr;
  align-items: center;
  gap: 2mm;
}
.layer-row {
  display: flex;
  align-items: center;
  justify-content: space-around;
  gap: .6mm;
}
.count-row {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 1mm 4mm;
  margin-top: .3mm;
  font-size: 9pt;
}
.answer-blank {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 11mm;
  height: 7mm;
  margin: 0 .8mm;
  border: 1.2pt solid #667085;
  border-radius: 1.2mm;
  background: #fff;
  color: #167A45;
  font-size: 12pt;
  font-weight: 800;
  vertical-align: middle;
}
.view-layout {
  display: grid;
  grid-template-columns: 49mm 1fr;
  align-items: center;
  gap: 2mm;
}
.view-options,
.reverse-options {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1mm;
}
.reverse-layout {
  display: grid;
  grid-template-columns: 56mm 1fr;
  align-items: center;
  gap: 2mm;
}
.given-views {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: .5mm;
}
.hidden-layout {
  display: grid;
  grid-template-columns: 67mm 1fr;
  align-items: center;
  gap: 3mm;
}
.hidden-fields {
  display: grid;
  gap: 2mm;
  font-size: 10pt;
}
.hidden-fields div {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1.2mm 2mm;
  border-radius: 2mm;
  background: #FFF7ED;
}
.layer-formula {
  margin-top: 1.4mm;
  padding: 1.2mm 2mm;
  border: 1pt dashed #FF9F1C;
  border-radius: 2mm;
  background: #FFF9EF;
  color: #7A3E00;
  font-size: 8.8pt;
}
.explanation {
  margin-top: 1mm;
  padding: 1mm 1.6mm;
  border-left: 3pt solid #2A9D58;
  border-radius: 0 1.5mm 1.5mm 0;
  background: #EDFAF3;
  color: #24513B;
  font-size: 8.6pt;
  line-height: 1.28;
}
.thinking-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2mm;
  margin-top: 2mm;
}
.thinking-card {
  min-height: 15mm;
  padding: 1.5mm 2mm;
  border-radius: 2.5mm;
  background: #F4ECFF;
  font-size: 8.8pt;
}
.reason-card {
  min-height: 15mm;
  padding: 1.5mm 2mm;
  border: 1pt dashed #7950B6;
  border-radius: 2.5mm;
  background: #FBF8FF;
  font-size: 8.8pt;
}
.writing-line {
  display: block;
  height: 5mm;
  margin-top: 1mm;
  border-bottom: 1pt solid #98A2B3;
}
.training-record {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 2mm;
  margin-top: 2mm;
  padding: 1.4mm 2mm;
  border: 1pt solid #F4A261;
  border-radius: 2.5mm;
  background: #FFF7ED;
  font-size: 8.5pt;
}
.check-box {
  display: inline-block;
  width: 4.5mm;
  height: 4.5mm;
  margin: 0 .6mm 0 1.5mm;
  border: 1.2pt solid #344054;
  vertical-align: -1mm;
}
.page-footer {
  position: absolute;
  right: 10mm;
  bottom: 4mm;
  color: #667085;
  font-size: 7.5pt;
}
.iso-svg,
.view-svg,
.layer-svg { display: block; margin: 0 auto; }
.iso-svg.large { width: 72mm; height: 50mm; }
.iso-svg.medium { width: 58mm; height: 40mm; }
.iso-svg.small { width: 43mm; height: 30mm; }
.iso-svg.tiny { width: 32mm; height: 23mm; }
.view-svg.medium { width: 42mm; height: 32mm; }
.view-svg.small { width: 34mm; height: 27mm; }
.view-svg.tiny { width: 27mm; height: 21mm; }
.layer-svg.small { width: 30mm; height: 25mm; }
.layer-svg.tiny { width: 25mm; height: 21mm; }
.task-card.compact .iso-svg.small { width: 35mm; height: 24mm; }
.task-card.compact .iso-svg.tiny { width: 25mm; height: 18mm; }
.task-card.compact .view-svg.small { width: 27mm; height: 21mm; }
.task-card.compact .view-svg.tiny { width: 23mm; height: 18mm; }
.task-card.compact .task-prompt { margin-bottom: .5mm; font-size: 8.8pt; }
.task-card.compact .rotation-layout { grid-template-columns: 31mm 11mm 1fr; }
.task-card.compact .turn-symbol { font-size: 18pt; }
.task-card.compact .explanation { font-size: 7.7pt; }
.answer-day {
  display: flex;
  flex-direction: column;
  background:
    linear-gradient(180deg, rgba(42,157,88,.06), transparent 45mm),
    #fff;
}
.answer-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 2mm 3mm;
  border-bottom: 2pt solid #2A9D58;
}
.answer-header h1 { margin: 0; color: #17623A; font-size: 17pt; }
.answer-header p { margin: 0; color: #475467; font-size: 9pt; }
.answer-task-stack {
  display: flex;
  flex: 1 1 auto;
  flex-direction: column;
  justify-content: space-evenly;
  gap: 1.5mm;
  min-height: 0;
  margin-top: 2mm;
}
.parent-note {
  margin-top: 1.5mm;
  padding: 1.5mm 2mm;
  border: 1pt solid #3A86FF;
  border-radius: 2.5mm;
  background: #EFF6FF;
  color: #173B70;
  font-size: 8.5pt;
}
.checkpoint-box {
  margin-top: 1.5mm;
  padding: 1.5mm 2mm;
  border: 1.2pt solid #E76F00;
  border-radius: 2.5mm;
  background: #FFF5E8;
  color: #713A00;
  font-size: 8.5pt;
}
.cover-page {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: space-between;
  padding: 16mm 14mm 14mm;
  text-align: center;
  background:
    radial-gradient(circle at 15% 12%, rgba(46,196,182,.22), transparent 45mm),
    radial-gradient(circle at 86% 28%, rgba(58,134,255,.20), transparent 55mm),
    linear-gradient(160deg, #F8FBFF, #FFFFFF 60%, #FFF8EB);
}
.cover-kicker {
  display: inline-block;
  padding: 1.5mm 4mm;
  border-radius: 999px;
  color: #173B70;
  background: #DDEBFF;
  font-size: 10pt;
  font-weight: 700;
}
.cover-page h1 {
  margin: 6mm 0 2mm;
  color: #173B70;
  font-size: 29pt;
  line-height: 1.22;
  letter-spacing: .05em;
}
.cover-page h2 { margin: 0; color: #2A9D58; font-size: 16pt; }
.cover-model-row {
  display: grid;
  grid-template-columns: 75mm 1fr;
  align-items: center;
  gap: 5mm;
  width: 100%;
  padding: 5mm;
  border: 1.5pt solid #B9CCE6;
  border-radius: 7mm;
  background: rgba(255,255,255,.84);
}
.cover-view-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1mm;
}
.cover-points {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 2mm;
  width: 100%;
}
.cover-point {
  padding: 3mm 1.5mm;
  border-radius: 3mm;
  font-size: 10pt;
  font-weight: 700;
}
.cover-point:nth-child(1) { background: #E8F1FF; color: #225CA8; }
.cover-point:nth-child(2) { background: #E8F8F4; color: #176B54; }
.cover-point:nth-child(3) { background: #FFF2DF; color: #8A4B00; }
.cover-point:nth-child(4) { background: #F3EAFF; color: #654098; }
.cover-use {
  width: 100%;
  padding: 3mm;
  border-radius: 3mm;
  background: #172033;
  color: #fff;
  font-size: 10pt;
}
.guide-page h1 {
  margin: 0 0 3mm;
  padding-bottom: 2mm;
  border-bottom: 2pt solid #3A86FF;
  color: #173B70;
  font-size: 21pt;
}
.guide-section {
  margin-top: 3mm;
  padding: 2.5mm 3mm;
  border: 1pt solid #D0D5DD;
  border-radius: 3mm;
  background: rgba(255,255,255,.94);
}
.guide-section h2 { margin: 0 0 1.5mm; color: #173B70; font-size: 13pt; }
.guide-section p { margin: 1mm 0; }
.scaffold {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 1.5mm;
  margin-top: 2mm;
}
.scaffold-step {
  position: relative;
  min-height: 31mm;
  padding: 3mm 2mm 2mm;
  border-radius: 3mm;
  background: #EFF6FF;
  text-align: center;
  font-size: 9pt;
}
.scaffold-step b {
  display: block;
  margin-bottom: 1.5mm;
  color: #173B70;
  font-size: 11pt;
}
.legend-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 2mm;
}
.legend-card {
  min-height: 22mm;
  padding: 2mm;
  border-radius: 2.5mm;
  background: #F8FAFC;
}
.legend-swatch {
  display: inline-block;
  width: 12mm;
  height: 4mm;
  margin-right: 2mm;
  vertical-align: middle;
}
.error-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 2mm;
}
.error-card {
  padding: 2.3mm;
  border-left: 4pt solid #E76F00;
  border-radius: 2mm;
  background: #FFF7ED;
}
.error-card h3 { margin: 0 0 1mm; color: #713A00; font-size: 11pt; }
.error-card p { margin: .5mm 0; font-size: 9pt; }
.standards {
  width: 100%;
  border-collapse: collapse;
  font-size: 9pt;
}
.standards th,
.standards td { padding: 2mm; border: 1pt solid #98A2B3; vertical-align: top; }
.standards th { color: #173B70; background: #EAF2FF; }
@media print {
  .spatial-page,
  .answer-day,
  .guide-page,
  .cover-page {
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
  }
}
"""


def _choice_letter(index: int) -> str:
    return chr(ord("A") + index)


def _answer_value(value: int | str, answer: bool) -> str:
    return base.esc(str(value)) if answer else ""


def _task_tag(kind: str) -> str:
    return {
        "rotation": "看图选一选",
        "build": "动手搭一搭",
        "view": "看图选一选",
        "reverse": "闭眼想一想",
        "hidden": "动手数一数",
    }[kind]


def _option_wrapper(content: str, index: int, *, correct: bool) -> str:
    return (
        f'<div class="diagram-option{" correct" if correct else ""}">'
        f'<span class="choice-letter">{_choice_letter(index)}</span>'
        f'{"<span class=\"correct-check\">✓</span>" if correct else ""}'
        f"{content}</div>"
    )


def render_rotation_task(
    task: dict[str, Any],
    *,
    answer: bool,
) -> str:
    options = "".join(
        _option_wrapper(
            isometric_svg(
                option,
                size="tiny",
                show_directions=False,
                label=None,
            ),
            index,
            correct=answer and index == task["answer"],
        )
        for index, option in enumerate(task["options"])
    )
    turns = task["turns"]
    turn_text = "同一结构" if turns is None else f"{turns * 90}°"
    arrow = "↻" if turns is not None else "⇄"
    return (
        '<div class="rotation-layout">'
        f'<div class="rotation-before">{isometric_svg(task["base"], size="small", show_directions=False)}</div>'
        f'<div class="turn-symbol">{arrow}<small>{turn_text}</small></div>'
        f'<div class="option-row">{options}</div>'
        "</div>"
    )


def render_build_task(
    task: dict[str, Any],
    *,
    answer: bool,
) -> str:
    model = task["model"]
    layers = task["answer_layers"]
    layer_diagrams = "".join(
        layer_grid_svg(model, index, filled=answer, size="small")
        for index in range(len(layers))
    )
    counts = "".join(
        f'<span>第{index + 1}层'
        f'<span class="answer-blank">{_answer_value(count, answer)}</span>块</span>'
        for index, count in enumerate(layers)
    )
    return (
        '<div class="build-layout">'
        f'<div class="model-panel">{isometric_svg(model, size="small", show_directions=True)}</div>'
        '<div>'
        f'<div class="layer-row">{layer_diagrams}</div>'
        f'<div class="count-row">{counts}'
        f'<span>一共<span class="answer-blank">{_answer_value(task["answer_total"], answer)}</span>块</span>'
        "</div></div></div>"
    )


def render_view_task(
    task: dict[str, Any],
    *,
    answer: bool,
) -> str:
    options = "".join(
        _option_wrapper(
            view_grid_svg(model, direction, size="small", show_label=False),
            index,
            correct=answer and index == task["answer"],
        )
        for index, (model, direction) in enumerate(task["options"])
    )
    return (
        '<div class="view-layout">'
        f'<div class="model-panel">{isometric_svg(task["model"], size="small", show_directions=True)}</div>'
        f'<div class="view-options">{options}</div>'
        "</div>"
    )


def render_reverse_task(
    task: dict[str, Any],
    *,
    answer: bool,
) -> str:
    given_views = "".join(
        view_grid_svg(task["target"], direction, size="tiny", show_label=True)
        for direction in task["directions"]
    )
    options = "".join(
        _option_wrapper(
            isometric_svg(model, size="tiny", show_directions=False),
            index,
            correct=answer and index == task["answer"],
        )
        for index, model in enumerate(task["options"])
    )
    return (
        '<div class="reverse-layout">'
        f'<div class="given-views">{given_views}</div>'
        f'<div class="reverse-options">{options}</div>'
        "</div>"
    )


def render_hidden_task(
    task: dict[str, Any],
    *,
    answer: bool,
) -> str:
    model = task["model"]
    counts = layer_counts(model)
    formula = "＋".join(f"第{index + 1}层{count}块" for index, count in enumerate(counts))
    return (
        '<div class="hidden-layout">'
        f'<div class="model-panel">{isometric_svg(model, size="medium", show_directions=True, reveal_hidden=answer)}</div>'
        '<div>'
        '<div class="hidden-fields">'
        f'<div><span>看得见的积木</span><span class="answer-blank">{_answer_value(task["answer_visible"], answer)}</span>块</div>'
        f'<div><span>橙色虚线藏住</span><span class="answer-blank">{_answer_value(task["answer_hidden"], answer)}</span>块</div>'
        f'<div><span>完整模型一共</span><span class="answer-blank">{_answer_value(task["answer_total"], answer)}</span>块</div>'
        "</div>"
        f'{"<div class=\"layer-formula\">按层核对：" + base.esc(formula) + "。</div>" if answer else ""}'
        "</div></div>"
    )


def render_task(
    task: dict[str, Any],
    index: int,
    *,
    answer: bool,
    compact: bool,
) -> str:
    kind = task["kind"]
    renderer = {
        "rotation": render_rotation_task,
        "build": render_build_task,
        "view": render_view_task,
        "reverse": render_reverse_task,
        "hidden": render_hidden_task,
    }[kind]
    explanation = (
        f'<div class="explanation"><b>图解思路：</b>{base.esc(task["explanation"])}</div>'
        if answer
        else ""
    )
    return (
        f'<section class="task-card{" compact" if compact else ""}" '
        f'data-kind="{kind}" data-task-index="{index}">'
        f'<p class="task-prompt"><span class="task-tag">{_task_tag(kind)}</span>'
        f'{base.esc(task["prompt"])}</p>'
        f"{renderer(task, answer=answer)}"
        f"{explanation}</section>"
    )


def render_daily_page(lesson: dict[str, Any]) -> str:
    compact = len(lesson["tasks"]) == 3
    tasks = "".join(
        render_task(task, index, answer=False, compact=compact)
        for index, task in enumerate(lesson["tasks"], start=1)
    )
    checkpoint = (
        '<span><b>检查日：</b>完整做对 '
        '<span class="answer-blank"></span> 道</span>'
        if lesson.get("checkpoint")
        else '<span>用时 <span class="answer-blank"></span> 分钟</span>'
    )
    return f"""
<section class="page spatial-page" data-page-kind="training" data-day="{lesson["day"]}">
  <header class="day-header">
    <div class="day-number"><span>DAY</span><strong>{lesson["day"]}</strong></div>
    <div class="day-title">
      <h1>{base.esc(lesson["title"])}</h1>
      <p>{base.esc(lesson["goal"])}</p>
    </div>
    <span class="phase-chip">{base.esc(lesson["phase"])}</span>
  </header>
  <div class="routine-strip">
    <span>① 动手搭一搭</span><span>② 看图选一选</span><span>③ 闭眼想一想</span>
    <span>④ 说出理由</span><span>⑤ 训练记录</span>
  </div>
  <div class="goal-material">
    <div class="goal-box"><b>今日目标</b>{base.esc(lesson["goal"])}</div>
    <div class="material-box"><b>准备</b>{base.esc(lesson["material"])}</div>
  </div>
  <main class="task-stack">{tasks}</main>
  <div class="thinking-row">
    <div class="thinking-card"><b>闭眼想一想</b><br>遮住图片，在脑中转动或换方向看一次，再打开核对。</div>
    <div class="reason-card"><b>说出理由</b>　{base.esc(lesson["speech"])}
      <span class="writing-line"></span>
    </div>
  </div>
  <div class="training-record">
    <span><b>训练记录</b><i class="check-box"></i>独立完成<i class="check-box"></i>实物验证<i class="check-box"></i>需要回练</span>
    {checkpoint}
    <span>家长签字：____________</span>
  </div>
  <div class="page-footer">空间思维15天训练 · 第{lesson["day"]}天</div>
</section>
"""


def render_training_html(lessons: list[dict[str, Any]]) -> str:
    pages = "".join(render_daily_page(lesson) for lesson in lessons)
    return (
        '<!doctype html><html lang="zh-CN"><head><meta charset="utf-8">'
        "<title>一年级空间思维15天训练册</title>"
        f"<style>{base.PRINT_CSS}{SPATIAL_CSS}</style></head><body>{pages}</body></html>"
    )


def task_short_answer(task: dict[str, Any]) -> str:
    if task["kind"] in {"rotation", "view", "reverse"}:
        return f"选{_choice_letter(task['answer'])}"
    if task["kind"] == "build":
        layer_text = "、".join(
            f"第{index + 1}层{count}块"
            for index, count in enumerate(task["answer_layers"])
        )
        return f"{layer_text}，共{task['answer_total']}块"
    if task["kind"] == "hidden":
        return (
            f"看得见{task['answer_visible']}块，藏住{task['answer_hidden']}块，"
            f"共{task['answer_total']}块"
        )
    raise ValueError(f"未知题型：{task['kind']}")


def parent_note_for_day(day: int) -> str:
    if day <= 5:
        return (
            "先让孩子指出“最高块、缺角、标记块下面是谁”三条关系，再转动实物核对；"
            "不要用“向左一点、向右一点”直接提示答案。"
        )
    if day <= 10:
        return (
            "把红色正面小人固定在桌面上。孩子若混淆方向，让小人移动到指定位置，"
            "再把看到的每一列用手指从下往上划一遍。"
        )
    if day <= 12:
        return (
            "不要直接告诉孩子有隐藏块。只问：“这块上层积木会悬在空中吗？”"
            "让孩子补支撑后拆成一层一层重新数。"
        )
    return (
        "要求孩子按“先确定方向—再看每列高度—最后按层计数”的顺序说理由；"
        "说不清时允许重新搭建，但先保留原答案再比较。"
    )


def checkpoint_guidance(day: int) -> str:
    if day == 5:
        return (
            "升级标准：3道全对或做对2道，可进入第6天；只对0—1道，回练第1天和第4天，"
            "重点比较“整体转动”和“拆开重搭”。"
        )
    if day == 10:
        return (
            "升级标准：3道全对或做对2道，可进入第11天；只对0—1道，先回练第7天，"
            "再回练第9天，不必把前10天全部重做。"
        )
    if day == 15:
        return (
            "后续建议：3道全对，可增加到8—10块自由搭建；错旋转题回练第3、13天，"
            "错视图题回练第8、9天，错隐藏题回练第11、12天。"
        )
    return ""


def render_answer_day(lesson: dict[str, Any]) -> str:
    compact = len(lesson["tasks"]) == 3
    task_answers = "".join(
        render_task(task, index, answer=True, compact=compact)
        for index, task in enumerate(lesson["tasks"], start=1)
    )
    summary = "；".join(
        f"第{index}题：{task_short_answer(task)}"
        for index, task in enumerate(lesson["tasks"], start=1)
    )
    checkpoint = (
        f'<div class="checkpoint-box"><b>本次检查与回练：</b>'
        f'{base.esc(checkpoint_guidance(lesson["day"]))}</div>'
        if lesson.get("checkpoint")
        else ""
    )
    return f"""
<section class="page answer-day" data-page-kind="answer" data-day="{lesson["day"]}">
  <header class="answer-header">
    <div><h1>第{lesson["day"]}天　{base.esc(lesson["title"])}</h1>
      <p>{base.esc(lesson["phase"])} · 彩色图解答案</p></div>
    <div class="phase-chip">答案与思路</div>
  </header>
  <div class="parent-note"><b>答案速查：</b>{base.esc(summary)}</div>
  <main class="answer-task-stack">{task_answers}</main>
  <div class="parent-note"><b>家长提问方式：</b>{base.esc(parent_note_for_day(lesson["day"]))}</div>
  {checkpoint}
  <div class="page-footer">答案图解与家长指导 · 第{lesson["day"]}天</div>
</section>
"""


def render_cover_page() -> str:
    model = build_model_bank()["H"]
    views = "".join(
        view_grid_svg(model, direction, size="small", show_label=True)
        for direction in ("front", "side", "top")
    )
    return f"""
<section class="page cover-page" data-page-kind="answer-cover">
  <div>
    <span class="cover-kicker">适合一年级 · 每天10—15分钟 · 6—8块以内</span>
    <h1>一年级空间思维15天</h1>
    <h2>答案图解与家长指导</h2>
  </div>
  <div class="cover-model-row">
    <div>{isometric_svg(model, size="large", show_directions=True, reveal_hidden=True)}</div>
    <div>
      <div style="font-size:13pt;font-weight:800;color:#173B70;margin-bottom:2mm;">同一模型，三种观察方向</div>
      <div class="cover-view-grid">{views}</div>
      <p style="margin:2mm 0 0;font-size:9pt;color:#475467;">
        橙色虚线表示被外层挡住、但为了支撑上层必须存在的积木。
      </p>
    </div>
  </div>
  <div class="cover-points">
    <div class="cover-point">旋转辨认</div>
    <div class="cover-point">看图搭建</div>
    <div class="cover-point">三向视图</div>
    <div class="cover-point">隐藏计数</div>
  </div>
  <div class="cover-use">
    使用顺序：孩子先独立完成训练页 → 家长按图解提问 → 用实物重新搭建验证
  </div>
  <div style="font-size:9pt;color:#667085;">彩色A4打印版 · 与15天训练册逐页对应</div>
</section>
"""


def render_guide_page_one() -> str:
    model = build_model_bank()["A"]
    return f"""
<section class="page guide-page" data-page-kind="parent-guide" data-guide-page="1">
  <h1>家长指导（一）　怎样逐步撤掉帮助</h1>
  <div class="guide-section">
    <h2>每天固定使用这5步，不追求一次全对</h2>
    <div class="scaffold">
      <div class="scaffold-step"><b>1 实物</b>孩子照图搭好，家长只检查是否悬空。</div>
      <div class="scaffold-step"><b>2 对图</b>模型放在图旁，逐块找对应位置。</div>
      <div class="scaffold-step"><b>3 遮实物</b>拿纸挡住模型，再完成选择或计数。</div>
      <div class="scaffold-step"><b>4 脑中想</b>闭眼说出最高块、缺角和方向。</div>
      <div class="scaffold-step"><b>5 重搭验证</b>保留原答案，用实物验证后自己订正。</div>
    </div>
  </div>
  <div class="guide-section">
    <h2>方向必须先固定</h2>
    <div style="display:grid;grid-template-columns:65mm 1fr;gap:4mm;align-items:center;">
      {isometric_svg(model, size="large", show_directions=True)}
      <div>
        <p><b style="color:{DIRECTION_COLORS["front"]};">红色＝正面</b>：小人站在红箭头一边看。</p>
        <p><b style="color:{DIRECTION_COLORS["side"]};">蓝色＝侧面</b>：小人移动到蓝箭头一边看。</p>
        <p><b style="color:{DIRECTION_COLORS["top"]};">绿色＝上面</b>：像小鸟从上往下看。</p>
        <p>训练中颜色是提示，黑色轮廓、箭头、层号和占地形状才是核对依据。</p>
      </div>
    </div>
  </div>
  <div class="guide-section">
    <h2>材料与时间</h2>
    <div class="legend-grid">
      <div class="legend-card"><b>正方体积木</b><br>主材料，最好准备同样大小的8块。积木颜色不同没有关系。</div>
      <div class="legend-card"><b>磁力片或贴纸</b><br>只用来标记红色积木、正面或观察小人，不代替立体搭建。</div>
      <div class="legend-card"><b>建议节奏</b><br>看图2分钟、动手5分钟、闭眼想2分钟、说理由2分钟、订正2分钟。</div>
      <div class="legend-card"><b>停止信号</b><br>连续两次烦躁或反复猜答案时，当天只完成实物搭建，次日再做纸面题。</div>
    </div>
  </div>
  <div class="parent-note"><b>关键原则：</b>先让孩子说“我看到了什么”，再问“你怎样知道”；不要把成人的空间方向语言直接替孩子说完。</div>
  <div class="page-footer">家长指导 · 第1页</div>
</section>
"""


def render_guide_page_two() -> str:
    return """
<section class="page guide-page" data-page-kind="parent-guide" data-guide-page="2">
  <h1>家长指导（二）　常见错误与阶段标准</h1>
  <div class="error-grid">
    <div class="error-card">
      <h3>错误1：左右方向一转就乱</h3>
      <p><b>表现：</b>只追踪红色积木，不看它下面和旁边是谁。</p>
      <p><b>订正：</b>每次转动前说三句话：“它在第几层、下面是谁、旁边是谁”。</p>
    </div>
    <div class="error-card">
      <h3>错误2：把正面图当成上面图</h3>
      <p><b>表现：</b>直接数占地格子，不比较高度。</p>
      <p><b>订正：</b>让小人站到箭头处，手指从下往上划每一列；上面看才只数位置。</p>
    </div>
    <div class="error-card">
      <h3>错误3：只数看见的面</h3>
      <p><b>表现：</b>上层有积木，却漏掉下面的支撑块。</p>
      <p><b>订正：</b>问“它会不会悬空”，再把模型按层拆开，分别排成一行计数。</p>
    </div>
    <div class="error-card">
      <h3>错误4：只用一张视图猜模型</h3>
      <p><b>表现：</b>一张图符合就立刻作答。</p>
      <p><b>订正：</b>先用上面图查占地位置，再用正面或侧面图查每列高度。</p>
    </div>
  </div>
  <div class="guide-section">
    <h2>第5、10、15天只回练对应能力，不整本重做</h2>
    <table class="standards">
      <thead><tr><th>检查日</th><th>达到标准</th><th>未达到时回练</th></tr></thead>
      <tbody>
        <tr><td><b>第5天</b><br>旋转与结构</td><td>3道全对或做对2道，进入第6天。</td><td>只对0—1道：先做第1天的标记追踪，再做第4天的结构比较。</td></tr>
        <tr><td><b>第10天</b><br>搭建与视图</td><td>3道全对或做对2道，进入隐藏计数。</td><td>方向错回练第7、8天；两视图反推错回练第9天。</td></tr>
        <tr><td><b>第15天</b><br>综合复测</td><td>3道全对，可增加到8—10块自由搭建。</td><td>旋转错练第3、13天；视图错练第8、9天；隐藏错练第11、12天。</td></tr>
      </tbody>
    </table>
  </div>
  <div class="guide-section">
    <h2>怎样判断是真会了</h2>
    <p>✓ 不看实物也能先作答；　✓ 能指出至少两条空间线索；　✓ 用实物验证后能解释原答案哪里错；　✓ 换一种颜色仍能完成。</p>
    <p><b>不要求：</b>用“投影、坐标、轴”等术语。能用一年级语言说“前后叠住了”“上面这块下面要垫一块”就足够。</p>
  </div>
  <div class="parent-note"><b>记录建议：</b>只记录错误类型（方向、结构、视图、隐藏），不要只记分数。下一次从对应日期回练1页即可。</div>
  <div class="page-footer">家长指导 · 第2页</div>
</section>
"""


def render_answer_html(lessons: list[dict[str, Any]]) -> str:
    pages = (
        render_cover_page()
        + render_guide_page_one()
        + render_guide_page_two()
        + "".join(render_answer_day(lesson) for lesson in lessons)
    )
    return (
        '<!doctype html><html lang="zh-CN"><head><meta charset="utf-8">'
        "<title>一年级空间思维15天答案图解与家长指导</title>"
        f"<style>{base.PRINT_CSS}{SPATIAL_CSS}</style></head><body>{pages}</body></html>"
    )


async def build_pdfs(lessons: list[dict[str, Any]]) -> None:
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
        page = await browser.new_page(
            viewport={"width": 1440, "height": 1100},
            device_scale_factor=1,
        )
        await base.render_pdf(
            page,
            render_training_html(lessons),
            TRAINING_PDF,
            expect_fixed_pages=True,
        )
        print(f"generated {TRAINING_PDF.name}: {TRAINING_PDF.stat().st_size:,} bytes")
        await base.render_pdf(
            page,
            render_answer_html(lessons),
            ANSWER_PDF,
            expect_fixed_pages=True,
        )
        print(f"generated {ANSWER_PDF.name}: {ANSWER_PDF.stat().st_size:,} bytes")
        await browser.close()


def _colored_sample_count(page: fitz.Page) -> int:
    pixmap = page.get_pixmap(matrix=fitz.Matrix(0.55, 0.55), alpha=False)
    channels = pixmap.n
    samples = pixmap.samples
    colored = 0
    pixel_step = max(channels * 4, channels)
    for index in range(0, len(samples) - channels + 1, pixel_step):
        red, green, blue = samples[index], samples[index + 1], samples[index + 2]
        if max(red, green, blue) - min(red, green, blue) >= 18:
            colored += 1
    return colored


def inspect_pdf(
    path: Path,
    *,
    expected_pages: int,
    required_markers: list[str],
) -> dict[str, Any]:
    if not path.exists() or path.stat().st_size < 50_000:
        raise RuntimeError(f"{path.name}未生成或文件异常小。")
    document = fitz.open(path)
    if document.page_count != expected_pages:
        raise RuntimeError(
            f"{path.name}页数错误：应为{expected_pages}页，实际{document.page_count}页。"
        )

    page_reports: list[dict[str, Any]] = []
    all_text = ""
    for page_index, page in enumerate(document):
        width = float(page.rect.width)
        height = float(page.rect.height)
        if abs(width - 595.28) > 2 or abs(height - 841.89) > 2:
            raise RuntimeError(
                f"{path.name}第{page_index + 1}页不是A4：{width:.2f}×{height:.2f}pt"
            )

        text = page.get_text("text")
        all_text += "\n" + text
        if len(text.strip()) < 25:
            raise RuntimeError(f"{path.name}第{page_index + 1}页疑似空白。")

        bad_text_blocks: list[tuple[float, float, float, float]] = []
        for block in page.get_text("blocks"):
            x0, y0, x1, y1 = (float(value) for value in block[:4])
            if x0 < -1 or y0 < -1 or x1 > width + 1 or y1 > height + 1:
                bad_text_blocks.append((x0, y0, x1, y1))
        if bad_text_blocks:
            raise RuntimeError(
                f"{path.name}第{page_index + 1}页存在越界文字：{bad_text_blocks[:3]}"
            )

        drawings = page.get_drawings()
        if len(drawings) < 12:
            raise RuntimeError(
                f"{path.name}第{page_index + 1}页矢量图形过少：{len(drawings)}"
            )
        bad_drawings = []
        for drawing in drawings:
            rect = drawing.get("rect")
            if rect is None:
                continue
            if (
                rect.x0 < -1
                or rect.y0 < -1
                or rect.x1 > width + 1
                or rect.y1 > height + 1
            ):
                bad_drawings.append(tuple(round(value, 2) for value in rect))
        if bad_drawings:
            raise RuntimeError(
                f"{path.name}第{page_index + 1}页存在越界图形：{bad_drawings[:3]}"
            )

        colored_samples = _colored_sample_count(page)
        if colored_samples < 100:
            raise RuntimeError(
                f"{path.name}第{page_index + 1}页彩色像素不足：{colored_samples}"
            )
        page_reports.append(
            {
                "page": page_index + 1,
                "text_chars": len(text.strip()),
                "drawings": len(drawings),
                "colored_samples": colored_samples,
                "size_pt": [round(width, 2), round(height, 2)],
            }
        )

    for marker in required_markers:
        if marker not in all_text:
            raise RuntimeError(f"{path.name}缺少关键文字：{marker}")
    document.close()
    return {
        "file": path.name,
        "bytes": path.stat().st_size,
        "pages": expected_pages,
        "page_reports": page_reports,
    }


def validate_outputs(lessons: list[dict[str, Any]]) -> dict[str, Any]:
    training_markers = [
        "跟着红色标记转一转",
        "旋转与结构检查",
        "搭建与视图检查",
        "上面有积木，下面要有支撑",
        "空间思维综合检查",
        "训练记录",
    ]
    answer_markers = [
        "答案图解与家长指导",
        "家长指导（一）",
        "家长指导（二）",
        "橙色虚线",
        "答案速查",
        "后续建议",
    ]
    for lesson in lessons:
        training_markers.append(lesson["title"])
        answer_markers.append(lesson["title"])
    report = {
        "curriculum_days": len(lessons),
        "stable_models_checked": sum(
            1
            for lesson in lessons
            for task in lesson["tasks"]
            for _ in [task]
        ),
        "training": inspect_pdf(
            TRAINING_PDF,
            expected_pages=15,
            required_markers=training_markers,
        ),
        "answers": inspect_pdf(
            ANSWER_PDF,
            expected_pages=18,
            required_markers=answer_markers,
        ),
    }
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return report


async def main() -> None:
    lessons = build_lessons()
    validate_curriculum(lessons)
    await build_pdfs(lessons)
    validate_outputs(lessons)
    print(f"完成：{TRAINING_PDF}")
    print(f"完成：{ANSWER_PDF}")


if __name__ == "__main__":
    asyncio.run(main())
