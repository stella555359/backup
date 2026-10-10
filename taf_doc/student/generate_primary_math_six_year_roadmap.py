from __future__ import annotations

import asyncio
import json
from pathlib import Path
from typing import Any

import fitz
from playwright.async_api import async_playwright

import generate_grade1_papers as base


ROOT = Path(__file__).resolve().parent
ROADMAP_PDF = ROOT / "小学数学一至六年级培养路线_家长规划手册_彩色打印版.pdf"
CYCLE_PDF = ROOT / "一年级数学思维首个8周执行计划_彩色打印版.pdf"


STRANDS = [
    {
        "id": "number",
        "name": "数与运算",
        "short": "数感·运算",
        "color": "#2F6FED",
        "question": "数表示什么？结果大约是多少？有没有更灵活的算法？",
    },
    {
        "id": "symbol",
        "name": "概念与符号",
        "short": "概念·符号",
        "color": "#7B4BB7",
        "question": "符号背后的数量关系是什么？能否从实物过渡到算式？",
    },
    {
        "id": "space",
        "name": "图形与空间",
        "short": "图形·空间",
        "color": "#168A72",
        "question": "换方向、拆分或变形以后，哪些关系仍然不变？",
    },
    {
        "id": "reasoning",
        "name": "推理与问题解决",
        "short": "推理·解题",
        "color": "#E16C00",
        "question": "条件之间怎样连接？能否画图、枚举、倒推或分类？",
    },
    {
        "id": "data",
        "name": "数据与建模",
        "short": "数据·建模",
        "color": "#2D7A9A",
        "question": "现实问题中哪些量值得记录，怎样用数学表示和判断？",
    },
    {
        "id": "reflection",
        "name": "表达与反思",
        "short": "表达·反思",
        "color": "#C33E64",
        "question": "能否讲清为什么，并利用估算、反例或逆运算检查？",
    },
]


GRADE_PLANS: list[dict[str, Any]] = [
    {
        "grade": 1,
        "stage": "建立数学直觉",
        "headline": "先把数量、图形和语言连起来，不以做题速度代替理解。",
        "home_time": "每周45—60分钟，拆成3次短练",
        "focus": ["20以内数感与加减意义", "数量关系图解", "空间操作", "完整表达"],
        "strands": {
            "number": {
                "goal": "理解数的组成、顺序、大小和加减意义；逐步把20以内计算从逐个数过渡到凑十、拆分和想加算减。",
                "activity": "十格阵摆数、数轴跳格、扑克牌找朋友、购物凑整；比较不同算法。",
                "evidence": "能说出8和5怎样组成13；会估计答案范围；计算错误后能用实物自查。",
            },
            "symbol": {
                "goal": "理解“＝”表示两边同样多，认识整体与部分、已知与未知；能把生活故事写成算式。",
                "activity": "天平式等号卡、遮住一个部分猜数、给算式编故事、判断7＋3＝6＋4。",
                "evidence": "未知数换位置仍能理解；不会把等号只读成“写答案”。",
            },
            "space": {
                "goal": "辨认常见平面和立体图形，理解上下、前后、左右；能拼搭、旋转和从不同方向观察简单模型。",
                "activity": "七巧板、4—6块积木搭建、图形分类、路线游戏、实物旋转后找同形。",
                "evidence": "换颜色或换方向仍能认出同一结构；能说出判断依据而非只凭感觉。",
            },
            "reasoning": {
                "goal": "学会比较、分类、找简单规律、一一对应和不重复地列举少量可能。",
                "activity": "按两种标准分类、接图形规律、两件上衣与两条裤子配搭、简单倒推。",
                "evidence": "能说明分类标准；枚举时知道怎样避免重复和遗漏。",
            },
            "data": {
                "goal": "从真实活动中收集、分类和计数，用简单图表表达；建立长度、时间和钱币的初步量感。",
                "activity": "记录一周天气、统计水果、用手掌和尺测桌面、模拟商店付款。",
                "evidence": "能从图表回答“最多、最少、相差多少”；会先估再测。",
            },
            "reflection": {
                "goal": "读题后复述“知道什么、求什么”，用图、动作或完整句子解释方法。",
                "activity": "每天讲一道题、给错误答案找原因、把同一道题用实物和图各表示一次。",
                "evidence": "能连续说出两步理由；做错后愿意保留原答案并订正。",
            },
        },
        "olympiad": "只做趣味思维：规律、分类、简单枚举、等量代换、图形拼搭和空间想象；不背专题公式。",
        "avoid": "大量限时口算、提前学复杂竖式谜、鸡兔同笼公式或用排名刺激速度。",
        "checkpoint": "20以内加减能解释方法；能画图表示一道应用题；能搭建并辨认简单积木结构；面对陌生题愿意尝试。",
    },
    {
        "grade": 2,
        "stage": "形成基本结构",
        "headline": "把加减、乘除、测量和图形放进真实关系中理解。",
        "home_time": "每周60分钟，保持3次短练",
        "focus": ["100以内运算", "乘除意义", "单位与测量", "两步问题"],
        "strands": {
            "number": {
                "goal": "稳固100以内加减，发展估算；理解乘法是同数连加、除法是平均分或按份分，并熟悉基本乘法事实。",
                "activity": "成组摆物、点阵图、跳着数、口算拆分、先估后笔算。",
                "evidence": "能用点阵解释3×4；能区分12÷3的两种现实含义；会检查结果数量级。",
            },
            "symbol": {
                "goal": "用算式表示两步数量关系，理解括号的必要性和简单未知量关系。",
                "activity": "同一故事写两种综合算式、给错误算式配反例、方框代数。",
                "evidence": "会说明先算什么以及为什么；能把图、语言和算式互相转换。",
            },
            "space": {
                "goal": "认识长度单位、角和简单对称；发展方向、路线、平移和图形分割组合意识。",
                "activity": "校园测量、折纸找对称、方格纸走路线、七巧板一图多拼。",
                "evidence": "能选合理单位并估量；能依据边角或对称关系描述图形。",
            },
            "reasoning": {
                "goal": "解决简单两步问题，学习画示意图、列表和按顺序枚举。",
                "activity": "购物两步题、简单间隔问题、移火柴验证、路线不重复枚举。",
                "evidence": "能指出中间问题；列举结果有固定顺序，不随意猜。",
            },
            "data": {
                "goal": "读取和制作简单统计表或条形表示，比较数据；继续建立时间、质量和长度量感。",
                "activity": "统计阅读时间、称量物品、设计班级投票表、比较两组数据。",
                "evidence": "能根据数据提出并回答问题；知道测量结果可能有小误差。",
            },
            "reflection": {
                "goal": "学会用逆运算、重新计算和情境合理性检查；能比较两种方法。",
                "activity": "小老师讲题、互换乘除检查、给不合理答案举例。",
                "evidence": "不只说“因为老师这样教”；能指出方法相同处和不同处。",
            },
        },
        "olympiad": "每周一道轻量挑战：周期规律、图形计数、简单搭配、和差关系、移火柴；仍以操作和画图为主。",
        "avoid": "把乘法表速度当成全部能力；未经理解直接背植树、年龄等题型套路。",
        "checkpoint": "乘除意义清楚；两步题能找到中间量；能按顺序枚举；能选单位并解释估测结果。",
    },
    {
        "grade": 3,
        "stage": "建立通用方法",
        "headline": "从具体算术走向图示、列表、运算律和初步抽象。",
        "home_time": "每周60—90分钟，学校任务重时维持60分钟",
        "focus": ["多位数运算", "分数小数初步", "线段图与枚举", "周长面积"],
        "strands": {
            "number": {
                "goal": "理解多位数乘除的位值原理，发展估算；认识分数和小数是新的数，而不是两个整数拼写。",
                "activity": "面积模型解释乘法、分物解释余数、纸条折分数、数轴标小数。",
                "evidence": "能解释竖式每一步；分数比较会借助单位“1”和数轴；会判断余数是否合理。",
            },
            "symbol": {
                "goal": "用括号、算式和简单字母或方框表达多步关系，初步感受运算律和等量关系。",
                "activity": "把长算式拆成关系图、用方框表示未知量、用面积模型发现分配律。",
                "evidence": "能从关系图还原算式；会选择简便运算而不是机械凑整。",
            },
            "space": {
                "goal": "理解周长与面积是不同属性，掌握常见图形测量；认识平移、旋转和轴对称。",
                "activity": "同周长不同面积围图、方格覆盖、剪拼转化、制作对称图案。",
                "evidence": "不会混用长度和面积单位；能用分割或补形解释面积。",
            },
            "reasoning": {
                "goal": "系统学习线段图、列表枚举、倒推和分类讨论，解决三步以内的问题。",
                "activity": "和差图、日历规律、按条件排座位、树状或表格式列举。",
                "evidence": "能说明枚举是否完整；遇到复杂文字会主动转成图或表。",
            },
            "data": {
                "goal": "阅读多种图表，理解数据比较依赖标准；用数学解决测量、预算和时间安排。",
                "activity": "家庭小预算、运动数据记录、同一数据画两种图、设计测量方案。",
                "evidence": "能从数据得出有依据的结论；不会只凭个别数据下判断。",
            },
            "reflection": {
                "goal": "形成错因分类：读题、概念、计算、表示或检查；开始书写完整解题步骤。",
                "activity": "错题只留一种典型题、改编条件、同题多解、口头预估答案。",
                "evidence": "能说出错在何处以及下次检查点；会用另一方法验证。",
            },
        },
        "olympiad": "可引入线段图、枚举、倒推、简单奇偶和数阵，但每个专题先解释原理，再做少量迁移题。",
        "avoid": "用成人方程替代儿童对数量关系的理解；一道题连续刷十几个同模板变式。",
        "checkpoint": "多位数运算可解释；分数有单位“1”意识；周长面积不混淆；能用图表处理陌生问题。",
    },
    {
        "grade": 4,
        "stage": "形成方法体系",
        "headline": "在运算、图形和数量关系中形成可迁移的方法，并进行第一次奥数分流。",
        "home_time": "每周60—90分钟；通过分流后可增加20—30分钟",
        "focus": ["运算律与大数", "小数与数量关系", "几何关系", "分类和不变量"],
        "strands": {
            "number": {
                "goal": "熟练多位数四则运算并理解运算律，稳固小数意义和估算，关注算法效率与适用条件。",
                "activity": "比较算法成本、错竖式诊断、生活价格估算、用模型解释运算律。",
                "evidence": "能在口算、笔算、估算中合理选择；简便运算能说明依据。",
            },
            "symbol": {
                "goal": "用字母、等式或关系图概括变化关系，理解未知量可参与运算。",
                "activity": "图形周长用字母表示、输入输出机、用等式表达和差倍关系。",
                "evidence": "给定关系能写表达式；换数后仍理解结构而非重新猜。",
            },
            "space": {
                "goal": "理解角、平行与垂直、图形变换和面积关系，发展作图与几何推理。",
                "activity": "尺规作平垂线、剪拼面积、旋转图案、同底等高直观实验。",
                "evidence": "会用性质而非“看起来像”判断；能通过补形、割补说明面积变化。",
            },
            "reasoning": {
                "goal": "掌握假设、分类讨论、简单不变量和有依据的归纳；解决信息较多的综合问题。",
                "activity": "真假条件筛选、最短方案、奇偶染色、按边界分类计数。",
                "evidence": "能给出完整分类；知道一个例子不能证明普遍结论。",
            },
            "data": {
                "goal": "理解平均数及统计图的表达作用，能设计简单调查并分析数据。",
                "activity": "班级运动调查、平均数平衡模型、比较不同刻度图表、预算优化。",
                "evidence": "知道平均数不一定是某个真实数据；会质疑误导性图表。",
            },
            "reflection": {
                "goal": "用“条件—表示—推理—结论—检查”组织书面过程，开始用反例检验猜想。",
                "activity": "一页数学报告、给错误命题找反例、互评解题说明。",
                "evidence": "步骤完整且关键理由清楚；能主动修正不充分的结论。",
            },
        },
        "olympiad": "进行第一次分流。符合门槛者可用20%—30%时间学习数论初步、组合枚举、几何构造与行程模型；其余继续趣味挑战。",
        "avoid": "因为同伴或证书压力直接进入高强度竞赛班；把会套行程、工程公式误当成建模能力。",
        "checkpoint": "基础正确且能解释；陌生题愿意尝试10—15分钟；会画图列表；对挑战有本人意愿，才升级奥数。",
    },
    {
        "grade": 5,
        "stage": "发展抽象与建模",
        "headline": "把分数、小数、方程、几何和真实问题连接起来，为初中代数作准备。",
        "home_time": "主线每周60—90分钟；奥数支线另加不超过45分钟",
        "focus": ["分数小数运算", "方程意识", "面积体积", "数论组合初步"],
        "strands": {
            "number": {
                "goal": "理解小数与分数运算、因数倍数及其联系，重视单位和运算结果的意义。",
                "activity": "数轴统一表示、面积模型算分数、因数配对、估算检验分数结果。",
                "evidence": "会解释通分和约分；能在分数、小数表示间灵活转换。",
            },
            "symbol": {
                "goal": "理解方程是等量关系的表达，能用字母表示一般规律和变化关系。",
                "activity": "天平模型解方程、由表找关系式、几何公式变式、用字母概括数列。",
                "evidence": "先找等量关系再列方程；解后会代回情境检查。",
            },
            "space": {
                "goal": "掌握多边形面积、长方体正方体表面积和体积，理解公式来自测量、分割与重组。",
                "activity": "剪拼推公式、展开图、单位立方体搭建、优化包装。",
                "evidence": "不混淆周长面积体积；能画辅助线并解释转化。",
            },
            "reasoning": {
                "goal": "综合运用假设、对应、归纳、数形结合和简单证明；开始处理开放问题。",
                "activity": "一题多解、构造反例、最值尝试、规则游戏策略分析。",
                "evidence": "能区分猜想与证明；会说明解法为何覆盖全部情况。",
            },
            "data": {
                "goal": "用平均数、统计图和简单可能性解决问题，识别数据选择对结论的影响。",
                "activity": "实验频率、两组数据比较、旅行预算、设计公平游戏。",
                "evidence": "能解释数据结论的限制；知道随机结果不等于每次平均出现。",
            },
            "reflection": {
                "goal": "形成个人方法库和错因档案，能选择最简洁、最稳妥的表示方式。",
                "activity": "每月解题报告、三种方法排序、同伴讲解、条件变化追踪。",
                "evidence": "新题能调用旧方法并调整；书面表达接近初中规范。",
            },
        },
        "olympiad": "若已通过分流，可系统学习整除与余数、组合计数、几何割补、行程和工程建模；挑战占课外数学时间不超过40%。",
        "avoid": "奥数题会做但校内分数、单位、方程和书写持续出错；以难题数量替代专题理解。",
        "checkpoint": "分数小数概念统一；能列方程；面积体积可推导；专题题能迁移且情绪、睡眠和校内学习稳定。",
    },
    {
        "grade": 6,
        "stage": "衔接初中数学",
        "headline": "形成可靠运算、代数意识、几何直观、推理表达和自主复盘能力。",
        "home_time": "根据校内负担保持60—120分钟，竞赛不是必选项",
        "focus": ["比率百分数", "代数关系", "综合几何", "模型与论证"],
        "strands": {
            "number": {
                "goal": "贯通整数、分数、小数、百分数、比和比例，理解运算一致性与数量级。",
                "activity": "同一问题多种数表示、比例尺、折扣税率、用估算审查复杂计算。",
                "evidence": "能根据情境选择表示；复杂计算前后都有合理性判断。",
            },
            "symbol": {
                "goal": "用字母和方程描述变量关系，理解相等、变化和函数对应的初步思想。",
                "activity": "速度时间图表、比例关系式、图形变化规律、等式变形解释。",
                "evidence": "能从文字、表格、图形转成关系式；变形每一步有等量依据。",
            },
            "space": {
                "goal": "理解圆、比例尺、立体图形及表面积体积综合问题，能够作辅助图和空间展开。",
                "activity": "圆周测量、立体切割、展开图验证、地图比例设计。",
                "evidence": "能从二维图想象三维关系；会用已知图形转化未知图形。",
            },
            "reasoning": {
                "goal": "处理多条件综合题，形成从猜想、验证到论证的完整过程；能识别隐含条件。",
                "activity": "开放探究、反例与边界、最值问题、跨专题建模。",
                "evidence": "不依赖题型标签也能启动；结论有条件范围，能回应质疑。",
            },
            "data": {
                "goal": "综合使用统计图、平均数、百分率和简单随机性，理解模型假设与现实误差。",
                "activity": "调查报告、抽样体验、方案比较、复利或增长直观。",
                "evidence": "能解释数据来源、指标和局限；会根据证据作选择。",
            },
            "reflection": {
                "goal": "独立制定学习计划、整理知识网络、诊断错因并清晰书写，为初中证明与代数学习准备。",
                "activity": "主题知识图、限时与非限时双复盘、给低年级学生讲题。",
                "evidence": "能自主选择复习重点；面对新题保持尝试、记录和修正。",
            },
        },
        "olympiad": "第二次分流：若兴趣、基础和抗挫持续稳定，可衔接初中竞赛思维；否则回归高质量综合题和初中衔接，不追证书。",
        "avoid": "抢学整套初中课程导致概念夹生；为了竞赛牺牲睡眠、阅读、运动和校内稳定性。",
        "checkpoint": "计算可靠、概念清楚、会画图建模、能处理陌生题、能说明理由并自主检查，即达到坚实初中基础。",
    },
]


def validate_grade_matrix() -> None:
    expected_ids = [strand["id"] for strand in STRANDS]
    if [plan["grade"] for plan in GRADE_PLANS] != list(range(1, 7)):
        raise ValueError("年级矩阵必须按一至六年级完整排列。")
    for plan in GRADE_PLANS:
        if list(plan["strands"]) != expected_ids:
            raise ValueError(f'{plan["grade"]}年级能力主线不完整或顺序错误。')
        for strand_id, detail in plan["strands"].items():
            for field_name in ("goal", "activity", "evidence"):
                if len(detail[field_name]) < 18:
                    raise ValueError(
                        f'{plan["grade"]}年级{strand_id}的{field_name}内容过短。'
                    )
        if len(plan["focus"]) != 4:
            raise ValueError(f'{plan["grade"]}年级必须有4个年度重点。')


GATE_DIMENSIONS: list[dict[str, Any]] = [
    {
        "id": "foundation",
        "name": "基础稳定",
        "weight": "硬门槛",
        "levels": {
            0: "当前校内概念或计算经常依赖提示，典型错误反复出现。",
            1: "常规题基本会做，但混合题、单位或检查仍不稳定。",
            2: "当前内容理解清楚、计算可靠，并能说明主要步骤。",
        },
        "observe": "查看近4周作业和口头讲题，不以一次考试分数代替。",
    },
    {
        "id": "representation",
        "name": "表示与迁移",
        "weight": "核心能力",
        "levels": {
            0: "离开示例或题型名称就不知道从哪里开始。",
            1: "在提醒下会画图、列表或举例，但迁移到新情境较慢。",
            2: "能主动选择图、表、算式或实物，并把方法迁移到变式题。",
        },
        "observe": "给一道未见过但知识范围相同的问题，观察启动方式。",
    },
    {
        "id": "reasoning",
        "name": "推理表达",
        "weight": "核心能力",
        "levels": {
            0: "只能说答案或背口诀，无法解释为什么。",
            1: "能描述步骤，但关键关系或分类完整性说不清。",
            2: "能说明依据、检查遗漏，并回应“换一个条件会怎样”。",
        },
        "observe": "每周让孩子完整讲一道题，家长只追问理由。",
    },
    {
        "id": "persistence",
        "name": "陌生题耐受",
        "weight": "保护门槛",
        "levels": {
            0: "两三分钟无思路就明显焦躁、猜答案或立即索要方法。",
            1: "能尝试5—10分钟，但需要家长分步提醒。",
            2: "愿意独立尝试10—15分钟，能记录失败方法后再调整。",
        },
        "observe": "选可操作但不能一眼看出套路的问题，不进行时间施压。",
    },
    {
        "id": "interest",
        "name": "自主兴趣",
        "weight": "必要条件",
        "levels": {
            0: "主要由家长推动，孩子持续回避挑战题。",
            1: "在题目有趣或同伴参与时愿意做，偶尔主动提问。",
            2: "会主动寻找更难问题、比较解法或要求继续探索。",
        },
        "observe": "记录8周内孩子主动选择挑战的次数，不用奖励诱导。",
    },
    {
        "id": "wellbeing",
        "name": "学习健康",
        "weight": "一票否决",
        "levels": {
            0: "已影响睡眠、运动、阅读、亲子关系或出现明显数学焦虑。",
            1: "偶有疲惫或抵触，减少任务后可以恢复。",
            2: "校内学习和生活稳定，挑战后情绪能自行恢复。",
        },
        "observe": "以连续4周状态判断；任何持续焦虑都优先降级。",
    },
]


OLYMPIAD_TRACKS = [
    {
        "id": "A",
        "name": "主干＋趣味思维",
        "ratio": "挑战内容占0%—15%",
        "for_whom": "一至六年级默认路线，或尚未满足系统奥数门槛。",
        "content": "每周一道开放题、逻辑游戏、空间拼搭或一题多解；不按专题刷题。",
        "review": "每8周观察兴趣和迁移，不需要参加竞赛。",
    },
    {
        "id": "B",
        "name": "主干＋轻量奥数",
        "ratio": "挑战内容占20%—30%",
        "for_whom": "四年级门槛通过后，先试行8周。",
        "content": "每次一个通用方法：画图、枚举、倒推、数论或几何构造；每专题只做少量基础、变式和解释题。",
        "review": "连续两个8周周期稳定，才考虑增加时间或难度。",
    },
    {
        "id": "C",
        "name": "系统专题／竞赛思维",
        "ratio": "挑战内容占30%—40%",
        "for_whom": "通常五年级以后，B路线连续稳定且孩子本人主动选择。",
        "content": "数论、组合、几何、行程工程等专题形成方法网络，同时保留校内主线和综合建模。",
        "review": "每8周检查基础、迁移、情绪和生活；证书不作为继续理由。",
    },
]


GRADE4_GATE = {
    "name": "四年级末第一次分流",
    "rule": (
        "先完成8周观察。基础稳定和学习健康必须达到2分，自主兴趣至少1分；"
        "六项合计至少9分，才能从A路线进入B路线试行。不能从A直接跳到C。"
    ),
    "trial": (
        "B路线先试行8周：每周只增加20—30分钟，专题训练后必须完成一道变式解释题；"
        "周期结束重新评分。"
    ),
    "outcomes": [
        "达到门槛：进入B路线8周试行，不报名高压竞赛。",
        "接近门槛：维持A路线，每周一道趣味题，8周后再看。",
        "基础或健康未达标：暂停专题升级，修复概念、作息或数学焦虑。",
    ],
}


GRADE6_GATE = {
    "name": "六年级末第二次分流",
    "rule": (
        "先确认小学主干目标达成，再评估是否衔接初中竞赛思维。基础稳定、表示迁移、"
        "推理表达和学习健康均须达到2分；总分至少10分，且孩子明确愿意继续。"
    ),
    "outcomes": [
        "进入初中竞赛思维：保持校内主线，挑战时间不超过课外数学时间的一半。",
        "进入高质量初中衔接：做代数、几何、建模综合题，不参加竞赛也完全符合目标。",
        "主线仍有缺口：利用暑期修复分数、比例、方程、几何或表达，不抢学整册初中内容。",
    ],
}


UPGRADE_RULES = [
    "连续两个8周周期基础、迁移和情绪都稳定，才增加每周20—30分钟或提升一个难度层级。",
    "每个专题按“理解例题—独立基础题—陌生变式—口头解释”完成；任何一步缺失都不继续堆新专题。",
    "升级看孩子的自主选择和迁移表现，不看做题总量、班级排名或证书。",
]


STEP_DOWN_RULES = [
    {
        "signal": "基础概念或校内计算连续两周明显退步",
        "action": "立即减半挑战时间，回到当前校内单元的实物、图示和混合复习。",
    },
    {
        "signal": "只会识别题型和背口诀，换情境就失效",
        "action": "暂停新专题，用一题多解、改条件和讲理由恢复迁移。",
    },
    {
        "signal": "需要家长不断催促，连续两次训练明显抵触",
        "action": "退回A路线至少4周，只保留游戏化问题，不用奖励换完成。",
    },
    {
        "signal": "影响睡眠、运动、阅读、亲子关系或出现数学焦虑",
        "action": "立即停止竞赛支线；先恢复生活和学习安全感，必要时寻求教师或专业支持。",
    },
    {
        "signal": "竞赛证书成为唯一目标，孩子不再关心方法",
        "action": "取消以名次为反馈，改为记录表示方法、迁移和解释质量。",
    },
]


def validate_olympiad_gates() -> None:
    expected_ids = {
        "foundation",
        "representation",
        "reasoning",
        "persistence",
        "interest",
        "wellbeing",
    }
    if {item["id"] for item in GATE_DIMENSIONS} != expected_ids:
        raise ValueError("奥数分流维度不完整。")
    for dimension in GATE_DIMENSIONS:
        if sorted(dimension["levels"]) != [0, 1, 2]:
            raise ValueError(f'{dimension["name"]}必须定义0、1、2三级。')
    if [track["id"] for track in OLYMPIAD_TRACKS] != ["A", "B", "C"]:
        raise ValueError("奥数路线必须按A、B、C三级排列。")
    if len(STEP_DOWN_RULES) < 4 or len(UPGRADE_RULES) < 3:
        raise ValueError("奥数升级或退出规则不足。")


CYCLE_LEVELS = [
    {
        "id": "support",
        "name": "支持档",
        "signal": "10以内组成或加减仍需逐个数，读应用题容易丢条件。",
        "adjust": "数字先缩小到10以内，允许全程摆实物；每次只完成核心题，不加挑战。",
    },
    {
        "id": "standard",
        "name": "标准档",
        "signal": "10以内稳定，20以内能用凑十或拆分，但还需要图示。",
        "adjust": "按本册完整执行；先独立想，再用十格阵、数轴或积木验证。",
    },
    {
        "id": "extension",
        "name": "拓展档",
        "signal": "20以内计算稳定，能独立画图并愿意解释陌生题。",
        "adjust": "不提高计算数域，改为隐藏一个条件、增加一种解法或要求说明全部可能。",
    },
]


EIGHT_WEEK_CYCLE: list[dict[str, Any]] = [
    {
        "week": 1,
        "title": "建立基线：先看孩子怎样想",
        "strands": ["number", "reflection", "space"],
        "objective": "不教学、不计总分，观察数感、表示、语言、空间和面对陌生题的反应。",
        "materials": "0—20数字卡、10个小物件、纸笔、4块正方体积木。",
        "sessions": [
            {
                "name": "A 数感画像",
                "minutes": 20,
                "flow": ["5分钟：摆出7、13和比10多3的数", "10分钟：说8＋5可以怎样算", "5分钟：估一估9＋8比15大还是小"],
                "prompt": "不要纠正算法，只追问：“你为什么这样摆？还有别的方法吗？”",
                "answer": "13是10和3；8＋5＝13，可凑十或拆分；9＋8＝17，比15大。",
                "easier": "改为5、8和7＋2，全程允许摆物件。",
                "harder": "比较8＋7与9＋6，不计算也先判断是否相等。",
                "observe": "是否逐个数、能否拆数、是否先估后算。",
            },
            {
                "name": "B 故事和图",
                "minutes": 20,
                "flow": ["5分钟：听故事复述条件", "10分钟：画图并列式", "5分钟：把“求总数”改成“求原来”"],
                "prompt": "盒里原有8颗珠子，又放进5颗。现在几颗？如果现在13颗、放进5颗，原来几颗？",
                "answer": "8＋5＝13；13－5＝8。重点看孩子能否理解未知量位置变化。",
                "easier": "使用真实珠子，数字改为5和3。",
                "harder": "让孩子自己编一道答案也是13、但运算不同的故事。",
                "observe": "能否复述“知道什么、求什么”，是否主动画图。",
            },
            {
                "name": "C 空间和陌生题",
                "minutes": 20,
                "flow": ["5分钟：底层摆3块成拐角", "10分钟：角上再放1块并整体转动", "5分钟：遮住实物描述最高块和缺角"],
                "prompt": "模型转了以后，怎样证明它没有被拆开重搭？",
                "answer": "最高块仍压在同一块上，旁边两块和缺角的连接关系不变。",
                "easier": "只摆3块L形，不叠高。",
                "harder": "转180°后请孩子画出俯视位置。",
                "observe": "追踪颜色还是追踪连接关系；陌生时是否愿意动手试。",
            },
        ],
        "family_note": "本周只建立画像。记录“孩子用了什么方法”，不要记录排名或贴能力标签。",
        "pass_signal": "能在至少两类任务中说出方法；允许使用实物，不要求全部独立。",
    },
    {
        "week": 2,
        "title": "凑十与整体部分",
        "strands": ["number", "symbol", "reflection"],
        "objective": "把“看见两个数”变成“先找离10还差多少”，理解拆分不改变总数。",
        "materials": "十格阵、双色圆片、数字卡、纸笔。",
        "sessions": [
            {
                "name": "A 凑十可视化",
                "minutes": 20,
                "flow": ["5分钟：用圆片摆8和5", "10分钟：移2个给8凑十", "5分钟：比较凑十与接着数"],
                "prompt": "依次完成8＋5、9＋6、7＋5，每题都指出“谁需要几个凑成10”。",
                "answer": "13、15、12；分别从5拿2、从6拿1、从5拿3。",
                "easier": "只做8＋3和9＋2。",
                "harder": "不摆圆片，解释6＋8为什么可以把8先凑十。",
                "observe": "能否主动找10；拆走后是否记得剩余部分。",
            },
            {
                "name": "B 从图到故事",
                "minutes": 20,
                "flow": ["5分钟：摆8＋6", "10分钟：编公交车上车故事并画图", "5分钟：交换两个加数解释结果"],
                "prompt": "车上有8人，又上来6人。怎样让图一眼看出10和4？",
                "answer": "8＋6＝14；把6分成2和4，先8＋2＝10，再10＋4＝14。",
                "easier": "改成7＋3，重点只说整体和两部分。",
                "harder": "把问题改成“又上来几人后有14人”，求未知部分。",
                "observe": "图是否表达数量关系，而不是只画装饰图。",
            },
            {
                "name": "C 等号挑战",
                "minutes": 20,
                "flow": ["5分钟：用天平卡理解两边一样多", "10分钟：填8＋□＝10＋3", "5分钟：寻找两种不同填法使两边都等于12"],
                "prompt": "等号两边都要算，不把等号读成“答案来了”。",
                "answer": "8＋5＝10＋3；12可表示为7＋5、8＋4、9＋3等。",
                "easier": "使用实物比较5＋2与4＋3。",
                "harder": "填写□＋4＝7＋△，找出三组答案。",
                "observe": "是否比较两边；是否知道开放题可能有多个答案。",
            },
        ],
        "family_note": "本周不追求口算速度。每次只要孩子能把“凑十的2从哪里来”说清楚，就算达标。",
        "pass_signal": "三道20以内进位加法中至少两道能用凑十并解释拆分。",
    },
    {
        "week": 3,
        "title": "破十、想加算减与逆向关系",
        "strands": ["number", "symbol", "reasoning"],
        "objective": "理解减法既可以破十，也可以利用加减互逆，不把退位步骤当口诀。",
        "materials": "两条十格阵、20个圆片、数轴、算式卡。",
        "sessions": [
            {
                "name": "A 破十有支撑",
                "minutes": 20,
                "flow": ["5分钟：摆13并圈出10和3", "10分钟：拿走5，先拿3再拿2", "5分钟：比较13－5的另一种算法"],
                "prompt": "完成13－5、15－7、12－4，说清先拆谁。",
                "answer": "8、8、8；可破十，也可想5＋8＝13等加法事实。",
                "easier": "改为12－2、12－3。",
                "harder": "比较14－6、15－7、16－8为什么答案相同。",
                "observe": "是否理解剩余2从10中减，而不是机械背步骤。",
            },
            {
                "name": "B 三种未知位置",
                "minutes": 20,
                "flow": ["5分钟：总数未知", "10分钟：拿走数量未知", "5分钟：原来数量未知"],
                "prompt": "分别表示：8只鸟又来5只；13只鸟飞走几只剩8只；一些鸟飞走5只剩8只。",
                "answer": "8＋5＝13；13－8＝5；8＋5＝13或13－5＝8。",
                "easier": "全部用圆片表演后再列式。",
                "harder": "三个故事都只给算式，让孩子判断未知量在哪个位置。",
                "observe": "是否根据关系选运算，而不是看见“飞走”就一律减。",
            },
            {
                "name": "C 算式家族",
                "minutes": 20,
                "flow": ["5分钟：摆8、5、13整体部分图", "10分钟：写四道相关算式", "5分钟：遮住一个数倒推"],
                "prompt": "用8、5、13写出两加两减，并说明每个算式中的整体是谁。",
                "answer": "8＋5＝13，5＋8＝13，13－8＝5，13－5＝8。",
                "easier": "使用3、4、7。",
                "harder": "给出9＋6＝15，自己编一道减法故事并画图。",
                "observe": "是否理解互逆关系；遮数后是否先找整体。",
            },
        ],
        "family_note": "如果破十和想加算减都能做，让孩子自己选择更顺手的方法，不规定唯一算法。",
        "pass_signal": "能用实物或图解释一道退位减法，并根据未知量位置正确选运算。",
    },
    {
        "week": 4,
        "title": "应用题语言与关系图",
        "strands": ["symbol", "reasoning", "reflection"],
        "objective": "区分合并、变化和比较三类关系，先表示关系再列算式。",
        "materials": "纸条、彩笔、小物件、三类关系卡。",
        "sessions": [
            {
                "name": "A 比较不是合并",
                "minutes": 20,
                "flow": ["5分钟：摆8个与12个物件", "10分钟：对齐后找多出的部分", "5分钟：写比较关系图"],
                "prompt": "小红有8张卡，小明有12张。小明比小红多几张？",
                "answer": "12－8＝4；图上共同的8对齐，剩余4才是相差。",
                "easier": "改成5与8并用实物一一对应。",
                "harder": "已知小明12张、比小红多4张，求小红。",
                "observe": "能否找“同样多”的部分；是否误用合并加法。",
            },
            {
                "name": "B 从剩下倒推原来",
                "minutes": 20,
                "flow": ["5分钟：表演拿走过程", "10分钟：画变化前后图", "5分钟：用加法和减法互相检查"],
                "prompt": "原来有一些苹果，吃了5个，还剩8个。原来有多少个？",
                "answer": "8＋5＝13；检查13－5＝8。",
                "easier": "数字改为3和4。",
                "harder": "再增加条件“又买来2个”，让孩子判断发生顺序。",
                "observe": "是否因“吃了”二字机械用减法；能否倒推。",
            },
            {
                "name": "C 一题多表示",
                "minutes": 20,
                "flow": ["5分钟：看算式14－6", "10分钟：编一个拿走故事和一个比较故事", "5分钟：分别画图说明"],
                "prompt": "同一个减法为什么能表示两种不同故事？",
                "answer": "都包含整体14与部分6、8，但一个表示变化后的剩余，一个表示两量相差。",
                "easier": "改用9－4并让家长先示范一种故事。",
                "harder": "再编一个“已知总数和一部分，求另一部分”的静态故事。",
                "observe": "能否把算式、故事和图保持一致。",
            },
        ],
        "family_note": "不圈关键词决定运算。每题都先问：这是合起来、发生变化，还是两组比较？",
        "pass_signal": "三类关系至少能区分两类；原来未知的题不再因“拿走”直接做减法。",
    },
    {
        "week": 5,
        "title": "量感：先估再测",
        "strands": ["number", "space", "data"],
        "objective": "理解测量需要统一单位，建立长度直觉，并用数据比较而非凭眼睛猜。",
        "materials": "直尺、回形针或同样长的小积木、记录纸、3件家中物品。",
        "sessions": [
            {
                "name": "A 为什么单位要统一",
                "minutes": 20,
                "flow": ["5分钟：分别用手掌和回形针量桌边", "10分钟：比较结果为何不同", "5分钟：改用同一种单位重测"],
                "prompt": "同一张桌子为什么会得到两个数字？怎样让别人也能复现？",
                "answer": "所用单位大小不同；统一单位并首尾相接，结果才可比较。",
                "easier": "只用相同积木测一本书。",
                "harder": "故意留下空隙或重叠，让孩子诊断测量错误。",
                "observe": "是否理解数字必须带单位；积木能否首尾相接。",
            },
            {
                "name": "B 估计与厘米",
                "minutes": 20,
                "flow": ["5分钟：先估铅笔、橡皮和书宽", "10分钟：用尺测量记录", "5分钟：比较估计误差"],
                "prompt": "铅笔约12厘米、橡皮约4厘米时，铅笔大约长多少？相差多少？",
                "answer": "铅笔长度约是橡皮3倍；相差约8厘米。实际数据以测量为准。",
                "easier": "只比较谁长，不计算差。",
                "harder": "找一件长度最接近15厘米的物品，并解释选择过程。",
                "observe": "是否从0刻度开始；估计是否逐渐接近实际。",
            },
            {
                "name": "C 路线长度挑战",
                "minutes": 20,
                "flow": ["5分钟：画两条折线路径", "10分钟：分别记录各段长度", "5分钟：比较3＋5与4＋4"],
                "prompt": "一条路线长3格再5格，另一条长4格再4格，谁更长？形状不同会改变总长度吗？",
                "answer": "两条都长8格；形状不同，但各段长度相加相同。",
                "easier": "用小车沿两条积木路线实际走。",
                "harder": "自己设计第三条也是8格、但形状不同的路线。",
                "observe": "能否区分路线形状与总长度；是否会分段记录。",
            },
        ],
        "family_note": "量感不是背1米等于多少厘米，而是看到物品能给出合理范围并愿意测量验证。",
        "pass_signal": "会先估后测、统一单位、从正确刻度开始，并能解释一次误差。",
    },
    {
        "week": 6,
        "title": "空间：搭建、旋转与隐藏支撑",
        "strands": ["space", "reasoning", "reflection"],
        "objective": "从实物搭建过渡到脑中旋转和按层计数，颜色只作提示、不作唯一线索。",
        "materials": "6—8块正方体积木、《一年级空间思维15天训练册》对应页面。",
        "sessions": [
            {
                "name": "A 搭建和旋转",
                "minutes": 20,
                "flow": ["5分钟：完成空间训练册第1天第一题", "10分钟：实物右转90°再选图", "5分钟：说最高块、下面和旁边是谁"],
                "prompt": "先在脑中选，再转实物验证；不要边转边猜。",
                "answer": "以训练册第1天答案图解核对，核心是连接关系保持不变。",
                "easier": "只使用3块L形积木。",
                "harder": "连续转两次90°后再画顶面位置。",
                "observe": "能否追踪连接关系；是否先想后验证。",
            },
            {
                "name": "B 固定方向看视图",
                "minutes": 20,
                "flow": ["5分钟：固定红色正面小人", "10分钟：完成空间训练册第7天一题", "5分钟：换到上面再比较"],
                "prompt": "观察者站在哪里？前后重合后，每一列最高有几格？",
                "answer": "按训练册第7天答案核对；正面看列高，上面看占地位置。",
                "easier": "先用单层模型，只判断占地。",
                "harder": "不给选项，让孩子在方格纸画正面图。",
                "observe": "是否先确认方向；是否把上面图当正面图。",
            },
            {
                "name": "C 看不见也要支撑",
                "minutes": 20,
                "flow": ["5分钟：搭两层小平台", "10分钟：遮住一侧预测总块数", "5分钟：按层拆开核对"],
                "prompt": "上层有一块时，它下面为什么一定有一块？",
                "answer": "积木不能悬空；总数应按第一层、第二层分别数，再相加。",
                "easier": "只搭2×2底层并在角上加1块。",
                "harder": "完成空间训练册第11天隐藏计数题。",
                "observe": "是否只数看见的面；会不会主动按层计数。",
            },
        ],
        "family_note": "实物验证安排在孩子作答之后。先想后搭，才能训练空间表象，而不只是模仿。",
        "pass_signal": "能固定观察方向、说出至少两条结构线索，并理解上层积木需要支撑。",
    },
    {
        "week": 7,
        "title": "规律与不重复枚举",
        "strands": ["reasoning", "symbol", "data"],
        "objective": "发现变化规则，并通过固定顺序列出全部可能，不靠随机试。",
        "materials": "彩笔、衣裤图片卡、1元和2元代币、表格纸。",
        "sessions": [
            {
                "name": "A 说清规律",
                "minutes": 20,
                "flow": ["5分钟：观察2、5、8、11", "10分钟：补后两项并说明变化", "5分钟：自己编一条有两步循环的图形规律"],
                "prompt": "不能只说“我看出来了”，要说每次改变了什么。",
                "answer": "每次加3，后两项是14、17；自编规律需能唯一延续。",
                "easier": "使用1、3、5、7。",
                "harder": "给出20、17、14、11并说明向前和向后的规则。",
                "observe": "能否区分重复图案和数值变化；表达是否明确。",
            },
            {
                "name": "B 搭配不遗漏",
                "minutes": 20,
                "flow": ["5分钟：摆2件上衣和3条裤子", "10分钟：固定一件上衣逐条配", "5分钟：用表格核对"],
                "prompt": "一共有多少种穿法？怎样让别人看出没有重复和遗漏？",
                "answer": "2×3＝6种；一年级不要求写乘法，完整列出6种即可。",
                "easier": "2件上衣和2条裤子，共4种。",
                "harder": "增加2顶帽子，先只讨论怎样分层记录，不要求心算总数。",
                "observe": "是否有固定顺序；能否用图或表留下记录。",
            },
            {
                "name": "C 代币组合",
                "minutes": 20,
                "flow": ["5分钟：只用1元和2元凑5元", "10分钟：按2元代币数量从0开始列", "5分钟：解释为什么没有第四种"],
                "prompt": "不考虑代币排列顺序，有几种不同组合？",
                "answer": "3种：5个1元；3个1元＋1个2元；1个1元＋2个2元。",
                "easier": "凑4元，共3种。",
                "harder": "凑6元并按同样顺序列举，共4种。",
                "observe": "是否把排列不同误算成新组合；能否说明枚举结束条件。",
            },
        ],
        "family_note": "枚举的价值不在答案大，而在“固定谁、变化谁、何时结束”三件事说清楚。",
        "pass_signal": "能用固定顺序列出2×3搭配和凑5元组合，并解释没有遗漏。",
    },
    {
        "week": 8,
        "title": "综合复测：看见八周变化",
        "strands": ["number", "reasoning", "reflection"],
        "objective": "用与第1周结构相似的新题复测方法、表达、迁移和抗挫，不追求满分。",
        "materials": "十格阵、纸笔、6块积木、第1周记录。",
        "sessions": [
            {
                "name": "A 运算策略复测",
                "minutes": 20,
                "flow": ["5分钟：先估答案范围", "10分钟：完成9＋7、15－6、8＋5－3", "5分钟：任选一题讲两种方法"],
                "prompt": "先独立作答，再选择是否用十格阵验证。",
                "answer": "16、9、10；重点比较是否比第1周更主动使用凑十、互逆和检查。",
                "easier": "改为8＋4、13－5、6＋4－2。",
                "harder": "比较9＋7－4与9＋(7－4)为什么相同。",
                "observe": "算法是否更灵活；能否先估、后算、再检查。",
            },
            {
                "name": "B 关系与表示复测",
                "minutes": 20,
                "flow": ["5分钟：复述两步故事", "10分钟：画图列式", "5分钟：改变未知量位置"],
                "prompt": "盒里有8个红球和6个蓝球，送出5个，还剩几个？如果还剩9个，原来送出几个？",
                "answer": "8＋6－5＝9；第二问送出5个。图中应先合并总数14，再表示变化。",
                "easier": "只做第一问并用实物表演。",
                "harder": "让孩子改变一个条件，使答案变成10。",
                "observe": "能否找中间量14；图、算式和语言是否一致。",
            },
            {
                "name": "C 陌生题与自评",
                "minutes": 20,
                "flow": ["5分钟：用6块积木自由搭稳定模型", "10分钟：画顶面图并让家长按图复搭", "5分钟：比较第1周，完成自评"],
                "prompt": "哪一步最难？你先做了什么？如果重来会怎样检查？",
                "answer": "模型必须稳定；顶面图记录占地位置。家长是否成功复搭用于检验表达。",
                "easier": "只用4块并允许模型放在旁边画。",
                "harder": "再画一个正面视图，讨论两张图是否足够唯一复搭。",
                "observe": "能否计划、表达和修正；遇到失败是否继续尝试。",
            },
        ],
        "family_note": "把第8周与第1周的方法作比较：能否更主动表示、更清楚解释、更平静面对陌生题，比总分更重要。",
        "pass_signal": "基础、表示、推理、兴趣四项中至少三项有可观察进步，即可进入下一周期。",
    },
]


EIGHT_WEEK_REVIEW = {
    "dimensions": [
        {
            "name": "基础准确性",
            "questions": "20以内策略是否比第1周稳定？错误是概念、计算还是粗心？",
            "next": "若概念不稳，下一周期继续十格阵和整体部分，不扩大数域。",
        },
        {
            "name": "表示方法",
            "questions": "遇到应用题会不会主动摆、画、列表或写关系？",
            "next": "若只会口头猜，减少题量，每次强制保留一张关系图。",
        },
        {
            "name": "推理表达",
            "questions": "能否连续说出两步理由，知道怎样避免遗漏？",
            "next": "若答案对但说不清，每周保留一次“小老师讲题”。",
        },
        {
            "name": "迁移能力",
            "questions": "题目换情境、换未知量或换方向后还能启动吗？",
            "next": "若依赖模板，同一知识只做1道原题＋1道结构变式。",
        },
        {
            "name": "兴趣与抗挫",
            "questions": "是否愿意独立尝试5—10分钟？订正后情绪能恢复吗？",
            "next": "若连续抵触，下一周期只保留游戏和实物活动，不增加奥数。",
        },
    ],
    "branches": [
        "支持档：10以内或应用题语言仍不稳，重复第2—4周的核心活动，数字缩小。",
        "标准档：多数目标达成，进入新的8周周期，保持每周1小时。",
        "拓展档：基础稳定且主动挑战，只增加开放条件和多解，不急着超前学二年级计算。",
    ],
}


def validate_eight_week_cycle() -> None:
    if [week["week"] for week in EIGHT_WEEK_CYCLE] != list(range(1, 9)):
        raise ValueError("首个周期必须完整包含第1—8周。")
    strand_ids = {strand["id"] for strand in STRANDS}
    used_strands: set[str] = set()
    for week in EIGHT_WEEK_CYCLE:
        if len(week["sessions"]) != 3:
            raise ValueError(f'第{week["week"]}周必须安排3次训练。')
        total_minutes = sum(session["minutes"] for session in week["sessions"])
        if total_minutes > 60:
            raise ValueError(f'第{week["week"]}周超过60分钟：{total_minutes}')
        if not set(week["strands"]).issubset(strand_ids):
            raise ValueError(f'第{week["week"]}周包含未知能力主线。')
        used_strands.update(week["strands"])
        for session in week["sessions"]:
            if session["minutes"] != 20 or len(session["flow"]) != 3:
                raise ValueError(f'第{week["week"]}周{session["name"]}结构不符合20分钟模板。')
            for field_name in ("prompt", "answer", "easier", "harder", "observe"):
                if not session[field_name]:
                    raise ValueError(
                        f'第{week["week"]}周{session["name"]}缺少{field_name}。'
                    )
    if used_strands != strand_ids:
        raise ValueError(f"8周计划未覆盖全部能力主线：{strand_ids - used_strands}")


ROADMAP_CSS = r"""
.roadmap-page,
.cycle-page,
.roadmap-cover,
.cycle-cover {
  padding: 8mm 10mm 8mm;
  color: #182230;
  font-size: 9pt;
  line-height: 1.32;
  background:
    radial-gradient(circle at 94% 4%, rgba(47,111,237,.08), transparent 40mm),
    #fff;
}
.roadmap-cover,
.cycle-cover {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  padding: 15mm 14mm 13mm;
  background:
    radial-gradient(circle at 12% 12%, rgba(22,138,114,.19), transparent 50mm),
    radial-gradient(circle at 88% 27%, rgba(47,111,237,.18), transparent 57mm),
    linear-gradient(160deg, #F8FBFF, #FFFFFF 60%, #FFF8EC);
}
.cover-kicker {
  display: inline-block;
  padding: 1.5mm 4mm;
  border-radius: 999px;
  color: #194B9B;
  background: #DCE9FF;
  font-size: 9.5pt;
  font-weight: 700;
}
.cover-title {
  margin: 6mm 0 2mm;
  color: #173F7A;
  font-size: 28pt;
  line-height: 1.2;
  letter-spacing: .04em;
}
.cover-subtitle {
  margin: 0;
  color: #168A72;
  font-size: 15pt;
}
.cover-thesis {
  padding: 4mm 5mm;
  border: 1.2pt solid #AFC7EA;
  border-radius: 5mm;
  background: rgba(255,255,255,.88);
  color: #27364A;
  font-size: 11pt;
  line-height: 1.55;
}
.cover-thesis b { color: #173F7A; }
.six-strand-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 2.5mm;
}
.strand-tile {
  min-height: 28mm;
  padding: 3mm;
  border: 1pt solid #D5DCE6;
  border-top-width: 4pt;
  border-radius: 3mm;
  background: rgba(255,255,255,.9);
}
.strand-tile b {
  display: block;
  margin-bottom: 1.2mm;
  font-size: 11pt;
}
.strand-tile p { margin: 0; color: #526071; font-size: 8.5pt; }
.route-ribbon {
  display: grid;
  grid-template-columns: 1fr 12mm 1fr 12mm 1fr;
  align-items: center;
  gap: 1mm;
}
.route-stage {
  min-height: 33mm;
  padding: 3mm;
  border-radius: 3mm;
  text-align: center;
}
.route-stage b { display: block; margin-bottom: 1.5mm; font-size: 11pt; }
.route-stage.a { background: #E9F1FF; color: #194B9B; }
.route-stage.b { background: #EBF8F4; color: #126A56; }
.route-stage.c { background: #F4ECFF; color: #694095; }
.route-arrow { color: #98A2B3; font-size: 22pt; text-align: center; }
.cover-footer {
  padding: 2.5mm;
  border-radius: 2.5mm;
  color: #fff;
  background: #182230;
  text-align: center;
  font-size: 9.5pt;
}
.page-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 3mm;
  padding-bottom: 2mm;
  border-bottom: 2pt solid #2F6FED;
}
.page-head h1 { margin: 0; color: #173F7A; font-size: 20pt; line-height: 1.15; }
.page-head p { margin: .8mm 0 0; color: #526071; font-size: 9pt; }
.page-chip {
  padding: 1.2mm 2.6mm;
  border-radius: 999px;
  color: #194B9B;
  background: #E3EDFF;
  font-size: 8.5pt;
  font-weight: 700;
  white-space: nowrap;
}
.section-card {
  margin-top: 3mm;
  padding: 2.5mm 3mm;
  border: 1pt solid #D0D5DD;
  border-radius: 3mm;
  background: rgba(255,255,255,.95);
}
.section-card h2 {
  margin: 0 0 1.8mm;
  color: #173F7A;
  font-size: 13pt;
}
.principle-flow {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 1.5mm;
}
.principle-step {
  min-height: 35mm;
  padding: 3mm 2mm;
  border-radius: 3mm;
  background: #F3F7FD;
  text-align: center;
}
.principle-step strong {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 8mm;
  height: 8mm;
  margin: 0 auto 1.5mm;
  border-radius: 50%;
  color: #fff;
  background: #2F6FED;
  font-size: 11pt;
}
.principle-step b { display: block; margin-bottom: 1mm; color: #173F7A; }
.weekly-template {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 2mm;
}
.weekly-card {
  padding: 3mm;
  border-radius: 3mm;
  background: #F8FAFC;
  border-left: 4pt solid #2F6FED;
}
.weekly-card:nth-child(2) { border-left-color: #168A72; }
.weekly-card:nth-child(3) { border-left-color: #E16C00; }
.weekly-card b { display: block; margin-bottom: 1mm; font-size: 10.5pt; }
.grade-page { display: flex; flex-direction: column; }
.grade-head {
  display: grid;
  grid-template-columns: 24mm 1fr auto;
  align-items: center;
  gap: 3mm;
  padding: 2.3mm 3mm;
  border: 1.2pt solid #2F6FED;
  border-radius: 4mm;
  background: linear-gradient(100deg, #EDF4FF, #fff);
}
.grade-number {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 21mm;
  height: 21mm;
  border-radius: 50%;
  color: #fff;
  background: #2F6FED;
  line-height: 1;
}
.grade-number strong { font-size: 18pt; }
.grade-number span { margin-top: 1mm; font-size: 7pt; }
.grade-title h1 { margin: 0; color: #173F7A; font-size: 17pt; }
.grade-title p { margin: 1mm 0 0; color: #526071; font-size: 8.5pt; }
.grade-time {
  padding: 1.4mm 2mm;
  border-radius: 2mm;
  color: #126A56;
  background: #E6F7F1;
  font-size: 8pt;
  font-weight: 700;
  text-align: center;
}
.focus-chips {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1.2mm;
  margin-top: 2mm;
}
.focus-chips span {
  padding: 1mm .8mm;
  border-radius: 2mm;
  background: #F2F4F7;
  text-align: center;
  font-size: 8pt;
  font-weight: 700;
}
.strand-matrix {
  display: flex;
  flex: 1 1 auto;
  flex-direction: column;
  justify-content: space-evenly;
  gap: 1.2mm;
  min-height: 0;
  margin-top: 2mm;
}
.strand-row {
  display: grid;
  grid-template-columns: 24mm 1.15fr 1fr 1fr;
  gap: 1.5mm;
  align-items: stretch;
  padding: 1.5mm;
  border: 1pt solid #D8DEE8;
  border-left-width: 4pt;
  border-radius: 2.5mm;
  background: #fff;
  font-size: 7.6pt;
  line-height: 1.28;
}
.strand-name {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  font-weight: 800;
}
.strand-name small { margin-top: .8mm; color: #667085; font-size: 6.8pt; font-weight: 400; }
.matrix-cell { padding: .6mm 1mm; border-radius: 1.5mm; background: #F8FAFC; }
.matrix-cell b { display: block; margin-bottom: .5mm; color: #344054; font-size: 7.2pt; }
.grade-bottom {
  display: grid;
  grid-template-columns: 1.2fr 1fr 1.2fr;
  gap: 1.5mm;
  margin-top: 2mm;
}
.grade-note {
  min-height: 25mm;
  padding: 2mm;
  border-radius: 2.5mm;
  font-size: 7.7pt;
}
.grade-note b { display: block; margin-bottom: .8mm; font-size: 8.5pt; }
.grade-note.olympiad { background: #F3ECFF; color: #603789; }
.grade-note.avoid { background: #FFF0ED; color: #8C332A; }
.grade-note.checkpoint { background: #EAF7F2; color: #176B54; }
.gate-dimension-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1.6mm;
}
.gate-dimension {
  padding: 2mm;
  border: 1pt solid #D8DEE8;
  border-radius: 2.5mm;
  background: #fff;
  font-size: 7.8pt;
}
.gate-dimension h3 { margin: 0 0 1mm; color: #173F7A; font-size: 10pt; }
.level-line { margin: .7mm 0; }
.level-dot {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 5mm;
  height: 5mm;
  margin-right: 1mm;
  border-radius: 50%;
  color: #fff;
  background: #667085;
  font-size: 7pt;
  font-weight: 700;
}
.track-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 2mm;
}
.track-card {
  padding: 2.5mm;
  border: 1pt solid #C8D3E1;
  border-radius: 3mm;
  background: #F8FAFC;
}
.track-card h3 { margin: 0 0 1mm; color: #173F7A; font-size: 11pt; }
.track-card .ratio {
  display: inline-block;
  margin-bottom: 1mm;
  padding: .7mm 1.5mm;
  border-radius: 999px;
  background: #E4EDFC;
  font-size: 7.5pt;
  font-weight: 700;
}
.gate-rule {
  margin-top: 2mm;
  padding: 2.2mm 3mm;
  border-left: 4pt solid #E16C00;
  border-radius: 2mm;
  background: #FFF5E8;
  color: #754000;
}
.rules-list { display: grid; gap: 1.5mm; }
.rule-item {
  padding: 2mm 2.5mm;
  border-radius: 2.5mm;
  background: #F5F7FA;
}
.stepdown-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1.5mm;
}
.stepdown-card {
  padding: 2mm;
  border-left: 4pt solid #C43D4B;
  border-radius: 2mm;
  background: #FFF1F3;
  font-size: 8pt;
}
.stepdown-card b { display: block; margin-bottom: .8mm; color: #8C2430; }
.mini-check-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 1mm;
}
.mini-check {
  min-height: 28mm;
  padding: 2mm;
  border-radius: 2.5mm;
  background: #F3F7FD;
  font-size: 7.5pt;
}
.mini-check b { display: block; margin-bottom: 1mm; color: #173F7A; font-size: 8.5pt; }
.page-footer {
  position: absolute;
  right: 10mm;
  bottom: 4mm;
  color: #758195;
  font-size: 7pt;
}
.cycle-cover { text-align: left; }
.level-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 2mm;
}
.level-card {
  min-height: 40mm;
  padding: 3mm;
  border-radius: 3mm;
  background: rgba(255,255,255,.92);
  border-top: 4pt solid #2F6FED;
}
.level-card:nth-child(2) { border-top-color: #168A72; }
.level-card:nth-child(3) { border-top-color: #7B4BB7; }
.level-card h3 { margin: 0 0 1mm; font-size: 12pt; }
.week-page { display: flex; flex-direction: column; }
.week-head {
  display: grid;
  grid-template-columns: 23mm 1fr auto;
  align-items: center;
  gap: 3mm;
  padding: 2mm 3mm;
  border: 1.2pt solid #2F6FED;
  border-radius: 4mm;
  background: linear-gradient(100deg, #EDF4FF, #fff);
}
.week-number {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 20mm;
  height: 20mm;
  border-radius: 50%;
  color: #fff;
  background: #2F6FED;
  line-height: 1;
}
.week-number strong { font-size: 17pt; }
.week-number span { margin-top: 1mm; font-size: 6.8pt; }
.week-title h1 { margin: 0; color: #173F7A; font-size: 16pt; }
.week-title p { margin: 1mm 0 0; color: #526071; font-size: 8pt; }
.strand-chip-row { display: flex; flex-wrap: wrap; gap: 1mm; justify-content: flex-end; }
.strand-chip {
  padding: .8mm 1.5mm;
  border-radius: 999px;
  color: #fff;
  font-size: 6.8pt;
  font-weight: 700;
}
.week-info {
  display: grid;
  grid-template-columns: 1.2fr 1fr;
  gap: 1.5mm;
  margin-top: 2mm;
}
.week-info div {
  padding: 1.5mm 2mm;
  border-radius: 2mm;
  font-size: 8pt;
}
.week-objective { border-left: 3pt solid #168A72; background: #EAF8F4; }
.week-material { border-left: 3pt solid #E16C00; background: #FFF4E5; }
.session-stack {
  display: flex;
  flex: 1 1 auto;
  flex-direction: column;
  justify-content: space-evenly;
  gap: 1.5mm;
  min-height: 0;
  margin-top: 2mm;
}
.session-card {
  padding: 1.8mm 2.2mm;
  border: 1pt solid #D0D5DD;
  border-radius: 3mm;
  background: #fff;
}
.session-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1mm;
}
.session-head h2 { margin: 0; color: #173F7A; font-size: 10.5pt; }
.time-chip {
  padding: .6mm 1.5mm;
  border-radius: 999px;
  color: #126A56;
  background: #E5F7F0;
  font-size: 7pt;
  font-weight: 700;
}
.session-main {
  display: grid;
  grid-template-columns: .95fr 1.4fr;
  gap: 1.5mm;
}
.flow-list {
  margin: 0;
  padding: 1.5mm 2mm 1.5mm 6mm;
  border-radius: 2mm;
  background: #F5F7FA;
  font-size: 7.5pt;
}
.flow-list li { margin: .6mm 0; }
.prompt-box {
  padding: 1.5mm 2mm;
  border-left: 3pt solid #2F6FED;
  border-radius: 2mm;
  background: #EEF4FF;
  font-size: 7.7pt;
}
.answer-box {
  margin-top: 1mm;
  padding: 1.1mm 1.8mm;
  border-left: 3pt solid #168A72;
  border-radius: 2mm;
  background: #EAF8F4;
  color: #175C4D;
  font-size: 7.5pt;
}
.adjust-row {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 1mm;
  margin-top: 1mm;
}
.adjust-item {
  padding: 1mm 1.5mm;
  border-radius: 1.8mm;
  background: #FAF7FF;
  font-size: 6.9pt;
}
.adjust-item:nth-child(2) { background: #FFF7ED; }
.adjust-item:nth-child(3) { background: #F3F7FD; }
.week-bottom {
  display: grid;
  grid-template-columns: 1.5fr 1fr;
  gap: 1.5mm;
  margin-top: 2mm;
}
.family-note,
.pass-signal {
  padding: 1.5mm 2mm;
  border-radius: 2.5mm;
  font-size: 7.7pt;
}
.family-note { background: #F4ECFF; color: #603789; }
.pass-signal { background: #EAF8F4; color: #175C4D; }
.week-record {
  display: flex;
  justify-content: space-between;
  margin-top: 1.5mm;
  padding: 1.2mm 2mm;
  border: 1pt solid #F2A45D;
  border-radius: 2mm;
  background: #FFF7ED;
  font-size: 7.5pt;
}
.check-square {
  display: inline-block;
  width: 4mm;
  height: 4mm;
  margin: 0 .5mm 0 1mm;
  border: 1pt solid #475467;
  vertical-align: -1mm;
}
.review-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 1mm;
}
.review-card {
  min-height: 52mm;
  padding: 2mm;
  border: 1pt solid #D8DEE8;
  border-radius: 2.5mm;
  background: #fff;
  font-size: 7.3pt;
}
.review-card h3 { margin: 0 0 1mm; color: #173F7A; font-size: 9pt; }
.rating-row { margin-top: 2mm; font-size: 8pt; }
.branch-list {
  display: grid;
  gap: 1.5mm;
}
.branch-item {
  padding: 2.2mm 3mm;
  border-left: 4pt solid #2F6FED;
  border-radius: 2mm;
  background: #EEF4FF;
}
.branch-item:nth-child(2) { border-left-color: #168A72; background: #EAF8F4; }
.branch-item:nth-child(3) { border-left-color: #7B4BB7; background: #F4ECFF; }
@media print {
  .roadmap-page,
  .cycle-page,
  .roadmap-cover,
  .cycle-cover {
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
  }
}
"""


def _strand_by_id(strand_id: str) -> dict[str, str]:
    return next(strand for strand in STRANDS if strand["id"] == strand_id)


def _html_document(title: str, pages: str) -> str:
    return (
        '<!doctype html><html lang="zh-CN"><head><meta charset="utf-8">'
        f"<title>{base.esc(title)}</title>"
        f"<style>{base.PRINT_CSS}{ROADMAP_CSS}</style></head><body>{pages}</body></html>"
    )


def render_roadmap_cover() -> str:
    strands = "".join(
        f'<div class="strand-tile" style="border-top-color:{strand["color"]};">'
        f'<b style="color:{strand["color"]};">{base.esc(strand["name"])}</b>'
        f'<p>{base.esc(strand["question"])}</p></div>'
        for strand in STRANDS
    )
    return f"""
<section class="page roadmap-cover" data-page-kind="roadmap-cover">
  <div>
    <span class="cover-kicker">一至六年级整体设计 · 课内扎实＋思维拓展＋可选奥数通道</span>
    <h1 class="cover-title">小学数学六年培养路线</h1>
    <h2 class="cover-subtitle">家长规划手册 · 彩色打印版</h2>
  </div>
  <div class="cover-thesis">
    <b>核心目标：</b>六年后不是“提前学了多少”，而是孩子计算可靠、概念清楚、会画图建模、
    能处理陌生问题、能说明理由并自主检查。奥数始终是可进可退的支线。
  </div>
  <div class="six-strand-grid">{strands}</div>
  <div class="route-ribbon">
    <div class="route-stage a"><b>A 主干＋趣味思维</b>一至三年级默认路线<br>每周一道开放挑战</div>
    <div class="route-arrow">→</div>
    <div class="route-stage b"><b>B 主干＋轻量奥数</b>四年级门槛通过后<br>先试行8周</div>
    <div class="route-arrow">→</div>
    <div class="route-stage c"><b>C 系统专题</b>通常五年级以后<br>本人主动且连续稳定</div>
  </div>
  <div class="cover-footer">当前起步：一年级 · 每周1小时以内 · 每8周根据证据动态调整</div>
  <div style="text-align:center;color:#667085;font-size:8pt;">依据《义务教育数学课程标准（2022年版）》核心素养框架设计</div>
</section>
"""


def render_principles_page() -> str:
    strand_tiles = "".join(
        f'<div class="strand-tile" style="min-height:24mm;border-top-color:{strand["color"]};">'
        f'<b style="font-size:10pt;color:{strand["color"]};">{base.esc(strand["name"])}</b>'
        f'<p>{base.esc(strand["question"])}</p></div>'
        for strand in STRANDS
    )
    return f"""
<section class="page roadmap-page" data-page-kind="principles">
  <header class="page-head">
    <div><h1>总原则：把知识变成可迁移的能力</h1>
      <p>每个新主题都经历同一条学习链；只会套公式不算真正掌握。</p></div>
    <span class="page-chip">六年共同方法</span>
  </header>
  <div class="section-card">
    <h2>五步学习链</h2>
    <div class="principle-flow">
      <div class="principle-step"><strong>1</strong><b>实物操作</b>先经历数量、测量、拼搭或变化。</div>
      <div class="principle-step"><strong>2</strong><b>画图表示</b>用线段图、点阵、表格或方格图留下关系。</div>
      <div class="principle-step"><strong>3</strong><b>数学符号</b>把图和语言压缩成算式、等式或字母关系。</div>
      <div class="principle-step"><strong>4</strong><b>变式迁移</b>换情境、换未知量、换方向，检验是否真懂。</div>
      <div class="principle-step"><strong>5</strong><b>口头解释</b>说依据、检查遗漏，并比较不同方法。</div>
    </div>
  </div>
  <div class="section-card">
    <h2>六条能力主线不是六门分开的课</h2>
    <div class="six-strand-grid">{strand_tiles}</div>
  </div>
  <div class="section-card">
    <h2>当前每周1小时的稳定结构</h2>
    <div class="weekly-template">
      <div class="weekly-card"><b>第1次 · 20分钟</b>5分钟数感或口算＋10分钟核心概念＋5分钟让孩子讲方法。</div>
      <div class="weekly-card"><b>第2次 · 20分钟</b>一道有思考空间的应用题，用实物、图或表表示，并尝试变式。</div>
      <div class="weekly-card"><b>第3次 · 20分钟</b>空间游戏、逻辑或轻量挑战＋订正本周一个典型错误。</div>
    </div>
  </div>
  <div class="section-card">
    <h2>家长只记录六类证据</h2>
    <div class="mini-check-grid">
      <div class="mini-check"><b>准确性</b>基础错误属于概念、计算还是读题？</div>
      <div class="mini-check"><b>灵活性</b>能否选择适合的算法或表示？</div>
      <div class="mini-check"><b>解释</b>能否连续说出两步理由？</div>
      <div class="mini-check"><b>迁移</b>题目换情境后还能启动吗？</div>
      <div class="mini-check"><b>兴趣与抗挫</b>愿意尝试并能从错误恢复吗？</div>
    </div>
  </div>
  <div class="gate-rule"><b>边界：</b>动画只作2—3分钟引入；看完必须复述、实物演示并做一道变式。睡眠、运动、阅读和正常校内学习优先于任何竞赛支线。</div>
  <div class="page-footer">小学数学六年培养路线 · 总原则</div>
</section>
"""


def render_grade_page(plan: dict[str, Any]) -> str:
    focus = "".join(f"<span>{base.esc(item)}</span>" for item in plan["focus"])
    rows: list[str] = []
    for strand in STRANDS:
        detail = plan["strands"][strand["id"]]
        rows.append(
            f'<div class="strand-row" style="border-left-color:{strand["color"]};">'
            f'<div class="strand-name" style="color:{strand["color"]};">'
            f'{base.esc(strand["short"])}<small>{base.esc(strand["name"])}</small></div>'
            f'<div class="matrix-cell"><b>年度目标</b>{base.esc(detail["goal"])}</div>'
            f'<div class="matrix-cell"><b>典型活动</b>{base.esc(detail["activity"])}</div>'
            f'<div class="matrix-cell"><b>达标表现</b>{base.esc(detail["evidence"])}</div>'
            "</div>"
        )
    return f"""
<section class="page roadmap-page grade-page" data-page-kind="grade" data-grade="{plan["grade"]}">
  <header class="grade-head">
    <div class="grade-number"><strong>{plan["grade"]}</strong><span>年级</span></div>
    <div class="grade-title"><h1>{base.esc(plan["stage"])}</h1>
      <p>{base.esc(plan["headline"])}</p></div>
    <div class="grade-time">{base.esc(plan["home_time"])}</div>
  </header>
  <div class="focus-chips">{focus}</div>
  <main class="strand-matrix">{''.join(rows)}</main>
  <div class="grade-bottom">
    <div class="grade-note olympiad"><b>奥数边界</b>{base.esc(plan["olympiad"])}</div>
    <div class="grade-note avoid"><b>避免</b>{base.esc(plan["avoid"])}</div>
    <div class="grade-note checkpoint"><b>年末达标观察</b>{base.esc(plan["checkpoint"])}</div>
  </div>
  <div class="page-footer">小学数学六年培养路线 · {plan["grade"]}年级</div>
</section>
"""


def render_gate_page() -> str:
    tracks = "".join(
        f'<div class="track-card"><h3>{track["id"]} · {base.esc(track["name"])}</h3>'
        f'<span class="ratio">{base.esc(track["ratio"])}</span>'
        f'<p><b>适合：</b>{base.esc(track["for_whom"])}</p>'
        f'<p><b>内容：</b>{base.esc(track["content"])}</p>'
        f'<p><b>复查：</b>{base.esc(track["review"])}</p></div>'
        for track in OLYMPIAD_TRACKS
    )
    dimensions = []
    for dimension in GATE_DIMENSIONS:
        levels = "".join(
            f'<div class="level-line"><span class="level-dot">{score}</span>'
            f'{base.esc(description)}</div>'
            for score, description in dimension["levels"].items()
        )
        dimensions.append(
            f'<div class="gate-dimension"><h3>{base.esc(dimension["name"])}'
            f' <small style="font-weight:400;color:#667085;">{base.esc(dimension["weight"])}</small></h3>'
            f"{levels}<div style=\"margin-top:1mm;color:#667085;\"><b>怎样观察：</b>"
            f'{base.esc(dimension["observe"])}</div></div>'
        )
    outcomes = "".join(f"<li>{base.esc(item)}</li>" for item in GRADE4_GATE["outcomes"])
    return f"""
<section class="page roadmap-page" data-page-kind="olympiad-gate">
  <header class="page-head">
    <div><h1>奥数不是“学或不学”，而是可进可退的支线</h1>
      <p>先选强度，再用连续证据决定升级；证书和一次高分都不是门槛。</p></div>
    <span class="page-chip">四年级第一次分流</span>
  </header>
  <div class="section-card">
    <h2>三条路线</h2>
    <div class="track-grid">{tracks}</div>
  </div>
  <div class="section-card" style="margin-top:2mm;">
    <h2>六维观察表：每项0—2分</h2>
    <div class="gate-dimension-grid">{''.join(dimensions)}</div>
  </div>
  <div class="gate-rule">
    <b>{base.esc(GRADE4_GATE["name"])}：</b>{base.esc(GRADE4_GATE["rule"])}
    <br><b>试行：</b>{base.esc(GRADE4_GATE["trial"])}
    <ul style="margin:1mm 0 0;padding-left:5mm;">{outcomes}</ul>
  </div>
  <div class="page-footer">小学数学六年培养路线 · 奥数分流</div>
</section>
"""


def render_safety_page() -> str:
    upgrade = "".join(
        f'<div class="rule-item"><b>升级规则{index}</b>　{base.esc(rule)}</div>'
        for index, rule in enumerate(UPGRADE_RULES, start=1)
    )
    stepdowns = "".join(
        f'<div class="stepdown-card"><b>信号：{base.esc(item["signal"])}</b>'
        f'处理：{base.esc(item["action"])}</div>'
        for item in STEP_DOWN_RULES
    )
    grade6_outcomes = "".join(
        f"<li>{base.esc(item)}</li>" for item in GRADE6_GATE["outcomes"]
    )
    return f"""
<section class="page roadmap-page" data-page-kind="safety-and-review">
  <header class="page-head">
    <div><h1>升级、退出与六年级衔接</h1>
      <p>真正安全的进阶路线必须同时写清楚“什么时候增加”和“什么时候退回”。</p></div>
    <span class="page-chip">动态调整</span>
  </header>
  <div class="section-card">
    <h2>升级规则</h2>
    <div class="rules-list">{upgrade}</div>
  </div>
  <div class="section-card">
    <h2>出现以下信号立即降级，不等到学期结束</h2>
    <div class="stepdown-grid">{stepdowns}</div>
  </div>
  <div class="section-card">
    <h2>{base.esc(GRADE6_GATE["name"])}</h2>
    <p style="margin:0 0 1.5mm;">{base.esc(GRADE6_GATE["rule"])}</p>
    <ul style="margin:0;padding-left:5mm;">{grade6_outcomes}</ul>
  </div>
  <div class="section-card">
    <h2>六年结束时真正值得带进初中的能力</h2>
    <div class="mini-check-grid">
      <div class="mini-check"><b>计算可靠</b>知道算法依据，会估算和检查数量级。</div>
      <div class="mini-check"><b>概念清楚</b>分数、比率、方程和几何不靠死记。</div>
      <div class="mini-check"><b>会表示</b>能把文字转成图、表、式或模型。</div>
      <div class="mini-check"><b>能推理</b>面对陌生题会分类、举例、反推和验证。</div>
      <div class="mini-check"><b>会自学</b>能诊断错因、调整方法并清楚表达。</div>
    </div>
  </div>
  <div class="gate-rule">
    <b>政策边界：</b>教育部竞赛管理办法明确竞赛结果不作为中小学招生依据。
    是否继续奥数只看孩子能力发展、兴趣和学习健康，不以证书数量决定。
  </div>
  <div class="page-footer">小学数学六年培养路线 · 升级与退出</div>
</section>
"""


def render_roadmap_html() -> str:
    pages = (
        render_roadmap_cover()
        + render_principles_page()
        + "".join(render_grade_page(plan) for plan in GRADE_PLANS)
        + render_gate_page()
        + render_safety_page()
    )
    return _html_document("小学数学一至六年级培养路线", pages)


def render_cycle_cover() -> str:
    levels = "".join(
        f'<div class="level-card"><h3>{base.esc(level["name"])}</h3>'
        f'<p><b>判断：</b>{base.esc(level["signal"])}</p>'
        f'<p><b>调整：</b>{base.esc(level["adjust"])}</p></div>'
        for level in CYCLE_LEVELS
    )
    return f"""
<section class="page cycle-cover" data-page-kind="cycle-cover">
  <div>
    <span class="cover-kicker">一年级当前起步 · 每周3次 · 每次20分钟</span>
    <h1 class="cover-title">数学思维首个8周执行计划</h1>
    <h2 class="cover-subtitle">数感、应用题、量感、空间与枚举的低负担起步</h2>
  </div>
  <div class="cover-thesis">
    <b>使用原则：</b>本周期不是提前学二年级内容，而是观察孩子怎样想、怎样表示、怎样面对陌生题。
    每周总时长不超过60分钟；学校任务变重时可只保留前两次。
  </div>
  <div>
    <h2 style="color:#173F7A;font-size:14pt;">第1周完成后选择执行档位</h2>
    <div class="level-grid">{levels}</div>
  </div>
  <div class="principle-flow">
    <div class="principle-step"><strong>1</strong><b>先独立想</b>保留孩子的第一方法。</div>
    <div class="principle-step"><strong>2</strong><b>实物或图</b>需要时再提供支架。</div>
    <div class="principle-step"><strong>3</strong><b>说出理由</b>答案之外必须有依据。</div>
    <div class="principle-step"><strong>4</strong><b>一道变式</b>检验是否真正迁移。</div>
    <div class="principle-step"><strong>5</strong><b>记录证据</b>记方法和情绪，不排名。</div>
  </div>
  <div class="route-ribbon">
    <div class="route-stage a"><b>第1—2周</b>基线、凑十与等号</div>
    <div class="route-arrow">→</div>
    <div class="route-stage b"><b>第3—5周</b>减法、应用题与量感</div>
    <div class="route-arrow">→</div>
    <div class="route-stage c"><b>第6—8周</b>空间、枚举与综合复测</div>
  </div>
  <div class="cover-footer">每周60分钟是上限，不是必须完成的任务量；理解和情绪优先。</div>
  <div style="text-align:center;color:#667085;font-size:8pt;">家长执行册 · 含题目、核对提示、降阶和拓展方法</div>
</section>
"""


def render_week_page(week: dict[str, Any]) -> str:
    strand_chips = "".join(
        f'<span class="strand-chip" style="background:{_strand_by_id(strand_id)["color"]};">'
        f'{base.esc(_strand_by_id(strand_id)["short"])}</span>'
        for strand_id in week["strands"]
    )
    sessions = []
    for session in week["sessions"]:
        flow = "".join(f"<li>{base.esc(step)}</li>" for step in session["flow"])
        sessions.append(
            '<section class="session-card">'
            '<div class="session-head">'
            f'<h2>{base.esc(session["name"])}</h2>'
            f'<span class="time-chip">{session["minutes"]}分钟</span></div>'
            '<div class="session-main">'
            f'<ol class="flow-list">{flow}</ol>'
            f'<div class="prompt-box"><b>家长怎么问：</b>{base.esc(session["prompt"])}'
            f'<div class="answer-box"><b>核对与观察：</b>{base.esc(session["answer"])}</div>'
            "</div></div>"
            '<div class="adjust-row">'
            f'<div class="adjust-item"><b>需要降阶：</b>{base.esc(session["easier"])}</div>'
            f'<div class="adjust-item"><b>轻松可拓展：</b>{base.esc(session["harder"])}</div>'
            f'<div class="adjust-item"><b>本次观察：</b>{base.esc(session["observe"])}</div>'
            "</div></section>"
        )
    return f"""
<section class="page cycle-page week-page" data-page-kind="week" data-week="{week["week"]}">
  <header class="week-head">
    <div class="week-number"><strong>{week["week"]}</strong><span>WEEK</span></div>
    <div class="week-title"><h1>{base.esc(week["title"])}</h1>
      <p>本周共3次，每次20分钟；允许只完成核心步骤。</p></div>
    <div class="strand-chip-row">{strand_chips}</div>
  </header>
  <div class="week-info">
    <div class="week-objective"><b>本周目标</b>　{base.esc(week["objective"])}</div>
    <div class="week-material"><b>准备</b>　{base.esc(week["materials"])}</div>
  </div>
  <main class="session-stack">{''.join(sessions)}</main>
  <div class="week-bottom">
    <div class="family-note"><b>家长提醒：</b>{base.esc(week["family_note"])}</div>
    <div class="pass-signal"><b>进入下一周的信号：</b>{base.esc(week["pass_signal"])}</div>
  </div>
  <div class="week-record">
    <span><b>完成：</b><i class="check-square"></i>A<i class="check-square"></i>B<i class="check-square"></i>C</span>
    <span><b>档位：</b><i class="check-square"></i>支持<i class="check-square"></i>标准<i class="check-square"></i>拓展</span>
    <span><b>情绪：</b>轻松 / 适中 / 吃力　<b>家长记录：</b>________________</span>
  </div>
  <div class="page-footer">一年级数学思维8周执行计划 · 第{week["week"]}周</div>
</section>
"""


def render_cycle_review_page() -> str:
    review_cards = "".join(
        f'<div class="review-card"><h3>{base.esc(item["name"])}</h3>'
        f'<p><b>回看：</b>{base.esc(item["questions"])}</p>'
        f'<p><b>下一步：</b>{base.esc(item["next"])}</p>'
        '<div class="rating-row">明显进步 □　略有进步 □　需支持 □</div></div>'
        for item in EIGHT_WEEK_REVIEW["dimensions"]
    )
    branches = "".join(
        f'<div class="branch-item">{base.esc(item)}</div>'
        for item in EIGHT_WEEK_REVIEW["branches"]
    )
    return f"""
<section class="page cycle-page" data-page-kind="cycle-review">
  <header class="page-head">
    <div><h1>第8周复盘：决定下一个周期，而不是给孩子贴标签</h1>
      <p>把第8周与第1周的方法比较；总分不如“怎样想、怎样表示、怎样恢复”重要。</p></div>
    <span class="page-chip">8周动态评估</span>
  </header>
  <div class="section-card">
    <h2>五维证据记录</h2>
    <div class="review-grid">{review_cards}</div>
  </div>
  <div class="section-card">
    <h2>选择下一周期的起点</h2>
    <div class="branch-list">{branches}</div>
  </div>
  <div class="section-card">
    <h2>孩子自己的声音</h2>
    <p>我最喜欢的活动：____________________________________________________________</p>
    <p>我现在会用的新方法：________________________________________________________</p>
    <p>遇到难题时，我可以先：______________________________________________________</p>
  </div>
  <div class="section-card">
    <h2>家长只写一条下一步</h2>
    <p style="min-height:16mm;border-bottom:1pt solid #98A2B3;">
      下一周期我们保持／减少／增加 ________________________________________________
    </p>
    <p><b>是否增加奥数：</b>一年级默认不进入系统专题。若孩子主动喜欢挑战，仅保持每周一道趣味题；不因8周表现提前进入竞赛训练。</p>
  </div>
  <div class="gate-rule">
    <b>停止信号：</b>连续两次明显抵触、训练影响睡眠运动、家长需要不断催促时，
    下周期先减少挑战，恢复游戏和实物活动。暂停不是退步，而是保护长期学习能力。
  </div>
  <div class="page-footer">一年级数学思维8周执行计划 · 周期复盘</div>
</section>
"""


def render_cycle_html() -> str:
    pages = (
        render_cycle_cover()
        + "".join(render_week_page(week) for week in EIGHT_WEEK_CYCLE)
        + render_cycle_review_page()
    )
    return _html_document("一年级数学思维首个8周执行计划", pages)


async def build_pdfs() -> None:
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
            render_roadmap_html(),
            ROADMAP_PDF,
            expect_fixed_pages=True,
        )
        print(f"generated {ROADMAP_PDF.name}: {ROADMAP_PDF.stat().st_size:,} bytes")
        await base.render_pdf(
            page,
            render_cycle_html(),
            CYCLE_PDF,
            expect_fixed_pages=True,
        )
        print(f"generated {CYCLE_PDF.name}: {CYCLE_PDF.stat().st_size:,} bytes")
        await browser.close()


def _colored_sample_count(page: fitz.Page) -> int:
    pixmap = page.get_pixmap(matrix=fitz.Matrix(0.55, 0.55), alpha=False)
    samples = pixmap.samples
    channels = pixmap.n
    colored = 0
    for index in range(0, len(samples) - channels + 1, channels * 4):
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
    if not path.exists() or path.stat().st_size < 45_000:
        raise RuntimeError(f"{path.name}未生成或文件异常小。")
    document = fitz.open(path)
    if document.page_count != expected_pages:
        raise RuntimeError(
            f"{path.name}页数错误：应为{expected_pages}页，实际{document.page_count}页。"
        )
    all_text = ""
    page_reports: list[dict[str, Any]] = []
    for index, page in enumerate(document, start=1):
        width = float(page.rect.width)
        height = float(page.rect.height)
        if abs(width - 595.28) > 2 or abs(height - 841.89) > 2:
            raise RuntimeError(
                f"{path.name}第{index}页不是A4：{width:.2f}×{height:.2f}pt"
            )
        text = page.get_text("text")
        all_text += "\n" + text
        if len(text.strip()) < 80:
            raise RuntimeError(f"{path.name}第{index}页疑似空白或内容过少。")
        bad_blocks = []
        for block in page.get_text("blocks"):
            x0, y0, x1, y1 = (float(value) for value in block[:4])
            if x0 < -1 or y0 < -1 or x1 > width + 1 or y1 > height + 1:
                bad_blocks.append((x0, y0, x1, y1))
        if bad_blocks:
            raise RuntimeError(
                f"{path.name}第{index}页存在越界文字：{bad_blocks[:3]}"
            )
        drawings = page.get_drawings()
        if len(drawings) < 10:
            raise RuntimeError(f"{path.name}第{index}页矢量版式元素不足。")
        colored_samples = _colored_sample_count(page)
        if colored_samples < 100:
            raise RuntimeError(f"{path.name}第{index}页彩色元素不足。")
        page_reports.append(
            {
                "page": index,
                "text_chars": len(text.strip()),
                "drawings": len(drawings),
                "colored_samples": colored_samples,
                "size_pt": [round(width, 2), round(height, 2)],
            }
        )
    for marker in required_markers:
        if marker not in all_text:
            raise RuntimeError(f"{path.name}缺少关键内容：{marker}")
    document.close()
    return {
        "file": path.name,
        "bytes": path.stat().st_size,
        "pages": expected_pages,
        "page_reports": page_reports,
    }


def validate_outputs() -> dict[str, Any]:
    roadmap_markers = [
        "小学数学六年培养路线",
        "五步学习链",
        "四年级末第一次分流",
        "六年级末第二次分流",
        "一票否决",
        "竞赛结果不作为中小学招生依据",
    ]
    roadmap_markers.extend(plan["stage"] for plan in GRADE_PLANS)
    cycle_markers = [
        "数学思维首个8周执行计划",
        "支持档",
        "标准档",
        "拓展档",
        "凑十与整体部分",
        "空间：搭建、旋转与隐藏支撑",
        "综合复测：看见八周变化",
        "第8周复盘",
    ]
    report = {
        "grade_matrix": {"grades": len(GRADE_PLANS), "strands_per_grade": len(STRANDS)},
        "olympiad_gates": {
            "dimensions": len(GATE_DIMENSIONS),
            "tracks": [track["id"] for track in OLYMPIAD_TRACKS],
        },
        "cycle": {
            "weeks": len(EIGHT_WEEK_CYCLE),
            "minutes_each_week": [
                sum(session["minutes"] for session in week["sessions"])
                for week in EIGHT_WEEK_CYCLE
            ],
        },
        "roadmap_pdf": inspect_pdf(
            ROADMAP_PDF,
            expected_pages=10,
            required_markers=roadmap_markers,
        ),
        "cycle_pdf": inspect_pdf(
            CYCLE_PDF,
            expected_pages=10,
            required_markers=cycle_markers,
        ),
    }
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return report


async def main() -> None:
    validate_grade_matrix()
    validate_olympiad_gates()
    validate_eight_week_cycle()
    await build_pdfs()
    validate_outputs()
    print(f"完成：{ROADMAP_PDF}")
    print(f"完成：{CYCLE_PDF}")


if __name__ == "__main__":
    asyncio.run(main())
