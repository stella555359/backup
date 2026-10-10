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
TRAINING_PDF = ROOT / "一年级阅读写作21天训练册.pdf"
CHECK_PDFS = {
    1: ROOT / "一年级阅读写作阶段检测_第1次.pdf",
    2: ROOT / "一年级阅读写作阶段检测_第2次.pdf",
    3: ROOT / "一年级阅读写作阶段检测_第3次.pdf",
}
ANSWER_PDF = ROOT / "一年级阅读写作训练_答案解析与家长指导.pdf"

STAGE_RANGES = {
    1: {"days": range(1, 8), "chars": (20, 40), "sentences": (2, 3), "questions": 2},
    2: {"days": range(8, 15), "chars": (40, 70), "sentences": (4, 6), "questions": 3},
    3: {"days": range(15, 22), "chars": (60, 105), "sentences": (6, 8), "questions": 4},
}


def question(
    prompt: str,
    answer: str,
    evidence: str,
    method: str,
    *,
    kind: str = "direct",
    options: list[str] | None = None,
) -> dict[str, Any]:
    return {
        "prompt": prompt,
        "answer": answer,
        "evidence": evidence,
        "method": method,
        "kind": kind,
        "options": options or [],
    }


def writing_task(
    prompt: str,
    sample: str,
    *,
    min_sentences: int,
    scaffold: str = "",
    word_bank: list[str] | None = None,
    criteria: list[str] | None = None,
    scene: str | None = None,
) -> dict[str, Any]:
    return {
        "prompt": prompt,
        "sample": sample,
        "min_sentences": min_sentences,
        "scaffold": scaffold,
        "word_bank": word_bank or [],
        "criteria": criteria or ["人物清楚", "事情完整", "句末有标点"],
        "scene": scene,
    }


def lesson(
    day: int,
    title: str,
    text: str,
    questions: list[dict[str, Any]],
    writing: dict[str, Any],
    *,
    stage: int,
    skill: str,
) -> dict[str, Any]:
    return {
        "day": day,
        "stage": stage,
        "title": title,
        "text": text,
        "questions": questions,
        "writing": writing,
        "skill": skill,
    }


LESSONS: list[dict[str, Any]] = [
    lesson(
        1,
        "小猫晒太阳",
        "早上，小猫来到窗边。它趴在软软的垫子上，眯着眼睛晒太阳。",
        [
            question("谁来到窗边？", "小猫来到窗边。", "小猫来到窗边", "先圈出题目中的“谁”，再回到第一句找相同的人物。"),
            question("小猫在做什么？", "小猫在晒太阳。", "眯着眼睛晒太阳", "找到“小猫”后，继续看它后面的动作。"),
        ],
        writing_task(
            "照样子写一个完整句：谁在哪里做什么？",
            "小鸟在树枝上唱歌。",
            min_sentences=1,
            scaffold="______在______。",
            word_bank=["小鸟", "树枝上", "唱歌"],
            scene="cat_sun",
        ),
        stage=1,
        skill="找人物和动作，写完整句",
    ),
    lesson(
        2,
        "上学路上",
        "早上，小明背着书包去上学。路上，他看见老师，主动向老师问好。",
        [
            question("小明什么时候去上学？", "小明早上去上学。", "早上，小明", "题目问时间，先找表示时间的词“早上”。"),
            question("小明看见老师后做了什么？", "小明主动向老师问好。", "主动向老师问好", "在第二句中找到“看见老师”后面的动作。"),
        ],
        writing_task(
            "写一写：你在上学路上会做什么？",
            "早上，我背着书包去上学。",
            min_sentences=1,
            scaffold="早上，我______。",
            word_bank=["背着书包", "去上学", "向老师问好"],
            scene="school_walk",
        ),
        stage=1,
        skill="找时间，按题意完整回答",
    ),
    lesson(
        3,
        "雨停了",
        "一场小雨停了。树叶上挂着亮晶晶的水珠，小草也变得更绿了。",
        [
            question("树叶上挂着什么？", "树叶上挂着亮晶晶的水珠。", "亮晶晶的水珠", "题目中的“树叶上”在第二句开头，答案就在它后面。"),
            question("小草有什么变化？", "小草变得更绿了。", "小草也变得更绿了", "找到“小草”，把表示变化的部分完整读出来。"),
        ],
        writing_task(
            "雨后还有什么变化？写一个完整句。",
            "雨后，天空变得更蓝了。",
            min_sentences=1,
            scaffold="雨后，______变得______。",
            word_bank=["天空", "花朵", "干净", "明亮"],
            scene="rain_leaf",
        ),
        stage=1,
        skill="找事物的变化，学习扩写",
    ),
    lesson(
        4,
        "妈妈做早餐",
        "妈妈在厨房做早餐。她先煮鸡蛋，再把牛奶倒进杯子里。",
        [
            question("妈妈在哪里做早餐？", "妈妈在厨房做早餐。", "妈妈在厨房做早餐", "题目问地点，找到“在”后面的词“厨房”。"),
            question("妈妈先做什么，再做什么？", "妈妈先煮鸡蛋，再把牛奶倒进杯子里。", "先煮鸡蛋，再把牛奶倒进杯子里", "找到“先”和“再”，按原来的顺序回答。"),
        ],
        writing_task(
            "用“先……再……”写一件你会做的事。",
            "我先打开书包，再拿出语文书。",
            min_sentences=1,
            scaffold="我先______，再______。",
            word_bank=["洗手", "擦干", "打开书包", "拿出书本"],
            scene="breakfast",
            criteria=["顺序正确", "动作清楚", "逗号和句号正确"],
        ),
        stage=1,
        skill="找地点和先后顺序",
    ),
    lesson(
        5,
        "快乐的操场",
        "下课了，同学们来到操场。有的跳绳，有的拍球，大家玩得很开心。",
        [
            question("同学们来到哪里？", "同学们来到操场。", "同学们来到操场", "找到人物“同学们”，它后面的地点就是答案。"),
            question("同学们在操场上做什么？", "同学们有的跳绳，有的拍球。", "有的跳绳，有的拍球", "找到两个“有的”，把两种活动都写出来。"),
        ],
        writing_task(
            "用“有的……有的……”写操场上的活动。",
            "操场上，有的同学跑步，有的同学踢球。",
            min_sentences=1,
            scaffold="操场上，有的______，有的______。",
            word_bank=["跑步", "踢球", "做游戏", "跳绳"],
            scene="playground",
        ),
        stage=1,
        skill="找并列信息，仿写句式",
    ),
    lesson(
        6,
        "鱼缸里的小鱼",
        "鱼缸里有三条小鱼。它们一会儿游到水草边，一会儿躲到石头后面。",
        [
            question("鱼缸里有几条小鱼？", "鱼缸里有三条小鱼。", "三条小鱼", "题目问数量，圈出表示数量的“三条”。"),
            question("小鱼会游到哪里？", "小鱼会游到水草边。", "游到水草边", "找到“游到”，它后面的地点就是答案。"),
        ],
        writing_task(
            "观察一种小动物，写它在哪里、在做什么。",
            "小鸟在树上跳来跳去。",
            min_sentences=1,
            scaffold="______在______。",
            word_bank=["小鸟", "小狗", "树上", "草地上", "跑来跑去"],
            scene="fish_tank",
        ),
        stage=1,
        skill="找数量和地点，观察动物",
    ),
    lesson(
        7,
        "一起撑伞",
        "放学时下雨了。小红没有带伞，小军和她一起撑伞回家。",
        [
            question("谁没有带伞？", "小红没有带伞。", "小红没有带伞", "题目问“谁”，在第二句中直接找到人物。"),
            question("小红怎样回家？", "小红和小军一起撑伞回家。", "小军和她一起撑伞回家", "“她”指小红，把人物名字换回来再完整回答。"),
        ],
        writing_task(
            "看图写1—2句话，说清谁在什么天气里做什么。",
            "放学时下雨了。两个小朋友一起撑伞回家。",
            min_sentences=2,
            scaffold="______。______。",
            word_bank=["放学", "下雨", "小朋友", "一起", "撑伞"],
            scene="umbrella",
            criteria=["天气写清楚", "人物和动作完整", "每句话有标点"],
        ),
        stage=1,
        skill="理解“他、她”，看图写两句",
    ),
    lesson(
        8,
        "认真洗手",
        "午饭前，小乐去洗手。他先打开水龙头，把小手淋湿。接着，他抹上肥皂认真搓洗。最后，他冲干净泡沫，关好水龙头。",
        [
            question("小乐什么时候去洗手？", "小乐午饭前去洗手。", "午饭前，小乐去洗手", "先找时间词“午饭前”。"),
            question("小乐抹上肥皂后做什么？", "小乐抹上肥皂后认真搓洗。", "抹上肥皂认真搓洗", "在“接着”所在的句子里找动作。"),
            question("洗手的最后一步是什么？", "最后，他冲干净泡沫，关好水龙头。", "最后，他冲干净泡沫，关好水龙头", "找到表示末尾顺序的“最后”。", kind="order"),
        ],
        writing_task(
            "用“先、接着、最后”写洗手的过程。",
            "我先打开水龙头。接着，我认真洗手。最后，我关好水龙头。",
            min_sentences=2,
            scaffold="我先______。接着，______。最后，______。",
            word_bank=["打开", "搓洗", "冲干净", "关好"],
            scene="wash_hands",
            criteria=["三步顺序正确", "动作完整", "连接词使用正确"],
        ),
        stage=2,
        skill="按顺序找信息并表达",
    ),
    lesson(
        9,
        "种小树",
        "春天，爷爷和我在院子里种下一棵小树。我每天给它浇水。因为阳光充足，泥土湿润，小树长出了嫩绿的叶子。我高兴地给它挂上一块小牌子。",
        [
            question("谁在院子里种树？", "爷爷和“我”在院子里种树。", "爷爷和我在院子里种下一棵小树", "圈出“谁”和“在哪里”。"),
            question("小树为什么长出了嫩叶？", "因为阳光充足，泥土湿润。", "因为阳光充足，泥土湿润", "题目问“为什么”，寻找“因为”后面的原因。", kind="reason"),
            question("“我”看到嫩叶后做了什么？", "“我”给小树挂上一块小牌子。", "给它挂上一块小牌子", "答案在最后一句。"),
        ],
        writing_task(
            "用“因为……所以……”写小树长大的原因和结果。",
            "因为我每天浇水，所以小树长出了嫩叶。看到嫩叶，我很高兴。",
            min_sentences=2,
            scaffold="因为______，所以______。看到______，我______。",
            word_bank=["每天浇水", "阳光充足", "长出嫩叶", "慢慢长高"],
            scene="plant_tree",
            criteria=["原因合理", "结果清楚", "关联词完整"],
        ),
        stage=2,
        skill="寻找原因和结果",
    ),
    lesson(
        10,
        "小鸟学飞",
        "树枝上住着一只小鸟。每天，鸟妈妈都带它练习飞行。刚开始，它飞得不远，常常落在低低的树枝上。后来，它勇敢地一次次练习，终于飞过了小河。",
        [
            question("文中的“它”指谁？", "“它”指小鸟。", "树枝上住着一只小鸟", "代词通常指前面已经出现的人或动物。", kind="pronoun"),
            question("小鸟刚开始飞得怎样？", "小鸟刚开始飞得不远。", "刚开始，它飞得不远", "找到“刚开始”后面的表现。"),
            question("小鸟后来为什么能飞过小河？", "因为它勇敢地一次次练习。", "勇敢地一次次练习", "从结果“终于飞过”往前找原因。", kind="reason"),
        ],
        writing_task(
            "用“刚开始……后来……”写一件通过练习学会的事。",
            "刚开始，我不会跳绳。后来，我天天练习，终于学会了。我特别开心。",
            min_sentences=3,
            scaffold="刚开始，______。后来，______。最后，______。",
            word_bank=["不会", "练习", "一次次", "终于学会"],
            scene="bird_fly",
            criteria=["前后变化清楚", "写出练习过程", "至少3句话"],
        ),
        stage=2,
        skill="理解代词和前后变化",
    ),
    lesson(
        11,
        "整理书桌",
        "星期天，小雨发现书桌很乱。彩笔躺在本子上，故事书放在椅子边。她先把彩笔装进笔盒，再把书一本本放回书架。整理以后，书桌变得又干净又整齐。",
        [
            question("书桌原来是什么样的？", "书桌原来很乱。", "书桌很乱", "答案在第一句，找到表示样子的词“乱”。"),
            question("小雨先整理什么，再整理什么？", "她先把彩笔装进笔盒，再把书放回书架。", "先把彩笔装进笔盒，再把书一本本放回书架", "用“先、再”按原文顺序回答。", kind="order"),
            question("整理后书桌有什么变化？", "书桌变得又干净又整齐。", "书桌变得又干净又整齐", "最后一句写的是整理后的结果。"),
        ],
        writing_task(
            "看图写2—3句话，写清整理前、整理时和整理后。",
            "书桌原来很乱。我把书放回书架，把彩笔装进笔盒。书桌变得整齐了。",
            min_sentences=3,
            scaffold="原来______。我先______，再______。最后______。",
            word_bank=["很乱", "放回", "装进", "干净整齐"],
            scene="tidy_desk",
            criteria=["写出前后变化", "整理顺序清楚", "至少3句话"],
        ),
        stage=2,
        skill="比较前后变化，按过程写话",
    ),
    lesson(
        12,
        "秋天的树叶",
        "秋天到了，校园里的树叶变黄了。一阵风吹来，几片叶子轻轻落下。小朋友捡起不同形状的叶子，把它们夹进本子里。大家想做一本美丽的树叶画册。",
        [
            question("秋天，树叶有什么变化？", "秋天，树叶变黄了。", "树叶变黄了", "第一句写树叶颜色的变化。"),
            question("“它们”指什么？", "“它们”指不同形状的叶子。", "不同形状的叶子，把它们夹进本子里", "往“它们”前面找复数事物。", kind="pronoun"),
            question("大家捡叶子想做什么？", "大家想做一本美丽的树叶画册。", "想做一本美丽的树叶画册", "答案在最后一句。"),
        ],
        writing_task(
            "观察秋天的图，写2—3句话，可以写颜色、动作和感受。",
            "秋天到了，树叶变黄了。风一吹，叶子轻轻落下来。我觉得秋天真美。",
            min_sentences=3,
            scaffold="秋天到了，______。风一吹，______。我觉得______。",
            word_bank=["金黄", "轻轻落下", "捡树叶", "真美"],
            scene="autumn",
            criteria=["写出秋天特点", "有一个动作", "有一句感受"],
        ),
        stage=2,
        skill="理解指代，观察并描写",
    ),
    lesson(
        13,
        "分享萝卜",
        "小兔收到了许多萝卜。它挑出两个又大又红的萝卜，送给住在山坡下的小羊。小羊开心地说：“谢谢你！”小兔笑着说：“好朋友应该互相分享。”",
        [
            question("小兔送给小羊什么？", "小兔送给小羊两个又大又红的萝卜。", "两个又大又红的萝卜", "把数量和样子一起写出来，回答更完整。"),
            question("小羊收到萝卜后说了什么？", "小羊说：“谢谢你！”", "小羊开心地说：“谢谢你！”", "找到小羊说话的引号内容。"),
            question("小兔为什么把萝卜送给小羊？", "因为好朋友应该互相分享。", "好朋友应该互相分享", "最后一句说明了分享的原因。", kind="reason"),
        ],
        writing_task(
            "写2—3句小对话，注意冒号和引号。",
            "小明把彩笔借给小红。小红说：“谢谢你！”小明说：“不用谢！”",
            min_sentences=3,
            scaffold="______说：“______！”______说：“______！”",
            word_bank=["谢谢你", "不用谢", "请你用", "一起分享"],
            scene="share",
            criteria=["人物说话清楚", "冒号和引号正确", "对话有礼貌"],
        ),
        stage=2,
        skill="读取对话，学习写人物说话",
    ),
    lesson(
        14,
        "班级图书角",
        "周五下午，同学们一起整理图书角。小文给书本分类，小青擦干净书架，小东把书摆整齐。大家忙了一会儿，图书角变得整洁又明亮。老师表扬他们会合作。",
        [
            question("小文负责做什么？", "小文负责给书本分类。", "小文给书本分类", "找到人物“小文”，读他后面的动作。"),
            question("整理后图书角变得怎样？", "图书角变得整洁又明亮。", "图书角变得整洁又明亮", "第三句写整理后的结果。"),
            question("老师为什么表扬大家？", "因为大家会合作。", "老师表扬他们会合作", "最后一句直接说明原因。", kind="reason"),
        ],
        writing_task(
            "看图写3—4句话，写清大家怎样合作完成一件事。",
            "同学们一起整理教室。有人扫地，有人擦桌子，还有人摆好书本。教室很快变干净了。大家都很开心。",
            min_sentences=4,
            scaffold="大家一起______。有人______，有人______。最后______。大家______。",
            word_bank=["扫地", "擦桌子", "摆书", "干净", "开心"],
            scene="library",
            criteria=["至少写两个人的动作", "结果清楚", "至少4句话"],
        ),
        stage=2,
        skill="提取人物分工，写合作过程",
    ),
    lesson(
        15,
        "公园里的春天",
        "周末，我和爸爸去公园找春天。柳树抽出了嫩芽。小草从泥土里探出头。几只燕子从湖面上飞过。花坛里，红花和黄花开得正热闹。我们坐在长椅上，把看到的春天画进图画本。回家时，我觉得今天的公园格外美。",
        [
            question("短文写的是哪个季节？", "短文写的是春天。", "去公园找春天", "第一句直接点明季节。"),
            question("短文写了哪两种植物的变化？", "短文写了柳树抽芽、小草探出头。", "柳树抽出了嫩芽。小草从泥土里探出头", "连续两句都在写植物。"),
            question("“我们”把什么画进图画本？", "“我们”把看到的春天画进图画本。", "把看到的春天画进图画本", "在倒数第二句找答案。"),
            question("下面哪个题目最合适？", "《公园里的春天》最合适。", "柳树抽出了嫩芽", "全文都在写公园里的春天，不只写一种花草。", kind="title", options=["公园里的春天", "我的图画本", "一只燕子"]),
        ],
        writing_task(
            "看图写4—6句话，写出春天的植物、动物、人物和感受。",
            "春天到了，公园变美了。柳树长出了嫩芽，小草绿了。燕子在湖面上飞。小朋友在花坛边画画。大家都喜欢春天。",
            min_sentences=4,
            scaffold="春天到了，______。______。______。最后写一写感受。",
            word_bank=["嫩绿", "开花", "飞过", "画画", "真美"],
            scene="spring_park",
            criteria=["植物和动物各写一种", "人物动作清楚", "有结尾感受", "4—6句话"],
        ),
        stage=3,
        skill="概括主要内容，选择题目",
    ),
    lesson(
        16,
        "蚂蚁搬东西",
        "午后，天空忽然暗了下来。小明看见一群蚂蚁排着长队搬东西。有的衔着小土粒，有的拖着食物。它们不停地向高处爬。小明想，可能快要下雨了。他赶紧收起院子里的图画。没过多久，大雨真的落了下来。",
        [
            question("天空发生了什么变化？", "天空忽然暗了下来。", "天空忽然暗了下来", "第一句写天气变化。"),
            question("蚂蚁怎样搬东西？", "蚂蚁有的衔土粒，有的拖食物。", "有的衔着小土粒，有的拖着食物", "把两种动作都写出来。"),
            question("小明为什么收起图画？", "因为他想到可能快要下雨了。", "可能快要下雨了。他赶紧收起", "把“想到下雨”和“收图画”联系起来。", kind="inference"),
            question("小明的判断对吗？为什么？", "他的判断对，因为后来真的下了大雨。", "大雨真的落了下来", "用最后一句的结果证明判断。", kind="inference"),
        ],
        writing_task(
            "看图写4—6句话：先写发现，再写猜想、行动和结果。",
            "天空变暗了，蚂蚁排队向高处爬。我想可能要下雨了，就赶快收衣服。过了一会儿，大雨落下来。幸好衣服没有淋湿。",
            min_sentences=4,
            scaffold="我发现______。我想______。于是______。后来______。",
            word_bank=["天空变暗", "蚂蚁搬家", "可能下雨", "赶快收好"],
            scene="ants_rain",
            criteria=["发现和猜想有关联", "行动合理", "写出结果", "4—6句话"],
        ),
        stage=3,
        skill="根据线索进行简单推断",
    ),
    lesson(
        17,
        "受伤的小鸟",
        "早晨，小丽在楼下发现一只小鸟。小鸟的翅膀受伤了，不能飞。小丽找来一个纸盒，轻轻把它放进去。她又请爸爸联系救助站。工作人员很快赶来，带走了小鸟。几天后，小丽知道小鸟已经康复，心里特别高兴。",
        [
            question("小鸟为什么不能飞？", "因为小鸟的翅膀受伤了。", "小鸟的翅膀受伤了，不能飞", "“受伤”是“不能飞”的原因。"),
            question("小丽先后做了哪两件事？", "她先把小鸟放进纸盒，又请爸爸联系救助站。", "找来一个纸盒，轻轻把它放进去。她又请爸爸联系救助站", "按第三、四句的顺序概括。", kind="order"),
            question("几天后，小丽为什么高兴？", "因为小鸟已经康复了。", "小鸟已经康复，心里特别高兴", "“高兴”前面写了原因。", kind="reason"),
            question("你觉得小丽是个怎样的孩子？", "小丽是个爱护小动物、愿意帮助别人的孩子。", "轻轻把它放进去", "从她轻轻照顾小鸟并联系救助站的行动来判断。", kind="inference"),
        ],
        writing_task(
            "看图写4—6句话，写一次帮助小动物的经过。",
            "我在草地上发现一只受伤的小鸟。它不能飞，我很着急。我找来纸盒，把它轻轻放进去。爸爸帮我联系了救助站。希望小鸟快点好起来。",
            min_sentences=4,
            scaffold="我发现______。它______。我先______，又______。我希望______。",
            word_bank=["受伤", "轻轻", "帮助", "联系", "快点康复"],
            scene="rescue_bird",
            criteria=["问题写清楚", "帮助过程有顺序", "有一句感受或希望", "4—6句话"],
        ),
        stage=3,
        skill="根据行动判断人物特点",
    ),
    lesson(
        18,
        "水壶在哪里",
        "体育课结束后，小刚发现水壶不见了。他先回到操场寻找，可是没有找到。接着，他去问同学，也没人看见。小刚想起自己课前去过图书角。于是，他跑到图书角，果然在窗台上找到了水壶。他把水壶擦干净，开心地回到教室。",
        [
            question("小刚先到哪里找水壶？", "小刚先到操场找水壶。", "先回到操场寻找", "找到“先”后面的地点。"),
            question("他接着用了什么办法？", "他接着去问同学。", "接着，他去问同学", "第二个办法由“接着”引出。"),
            question("小刚为什么想到去图书角？", "因为他想起课前去过图书角。", "想起自己课前去过图书角", "“想起”提供了新的线索。", kind="reason"),
            question("水壶最后在哪里找到？", "水壶最后在图书角的窗台上找到。", "在窗台上找到了水壶", "把前面的地点“图书角”和“窗台上”合起来回答。"),
        ],
        writing_task(
            "写4—6句话：丢了东西后，你会怎样一步步寻找？",
            "我发现铅笔盒不见了。我先看书包里，没有找到。接着，我问了同桌。后来，我想起把它放在讲台上。我跑过去，果然找到了。",
            min_sentences=4,
            scaffold="我发现______。我先______。接着______。后来我想起______。最后______。",
            word_bank=["寻找", "询问", "想起", "果然", "找到"],
            scene="lost_bottle",
            criteria=["至少写三步", "顺序连接词正确", "结果完整", "4—6句话"],
        ),
        stage=3,
        skill="提取解决问题的步骤",
    ),
    lesson(
        19,
        "小种子长大了",
        "一颗小种子睡在泥土里。春雨来了，它喝足了水。太阳出来了，它觉得暖暖的。过了几天，小种子顶开泥土，长出两片嫩叶。风吹过来，小苗轻轻摇摆。它每天都努力向上长。后来，小苗开出了一朵黄色的小花。",
        [
            question("春雨来了，小种子怎样了？", "小种子喝足了水。", "它喝足了水", "在“春雨来了”后面找变化。"),
            question("小种子先长出什么，后来开出什么？", "小种子先长出两片嫩叶，后来开出一朵黄色的小花。", "长出两片嫩叶", "把第四句和最后一句按顺序合起来。", kind="order"),
            question("文中的“它”先后指什么？", "前面的“它”指小种子，后面的“它”指小苗。", "一颗小种子", "代词要根据前一句最近出现的事物判断。", kind="pronoun"),
            question("短文主要写了什么？", "短文主要写小种子发芽、长叶、开花的过程。", "小种子顶开泥土", "把几次主要变化连起来概括。", kind="summary"),
        ],
        writing_task(
            "根据图中三个阶段，写4—6句话介绍种子怎样长大。",
            "春天，我把种子种进泥土里。我每天给它浇水。过了几天，种子发芽了。小苗慢慢长高，长出了叶子。后来，它开出了一朵小花。",
            min_sentences=4,
            scaffold="先写种下种子，再写发芽、长叶，最后写开花。",
            word_bank=["种进", "浇水", "发芽", "长叶", "开花"],
            scene="seed_growth",
            criteria=["三个生长阶段完整", "顺序正确", "动词使用准确", "4—6句话"],
        ),
        stage=3,
        skill="概括事物变化过程",
    ),
    lesson(
        20,
        "互相帮助",
        "午餐时，小安发现同桌忘带水果了。他把自己的苹果切成两半，分给同桌一半。同桌连声说谢谢。下午美术课，同桌把彩纸借给了小安。小安顺利完成了一幅漂亮的画。放学路上，两个人有说有笑。他们明白，互相帮助会让大家都快乐。",
        [
            question("午餐时，小安怎样帮助同桌？", "小安分给同桌半个苹果。", "分给同桌一半", "找到午餐时小安的动作。"),
            question("下午，同桌怎样帮助小安？", "同桌把彩纸借给小安。", "同桌把彩纸借给了小安", "答案在第四句。"),
            question("两个人放学时心情怎样？", "两个人很开心。", "两个人有说有笑", "“有说有笑”说明他们心情愉快。", kind="inference"),
            question("短文告诉我们什么道理？", "互相帮助会让大家都快乐。", "互相帮助会让大家都快乐", "最后一句直接写出道理。", kind="summary"),
        ],
        writing_task(
            "写4—6句话，讲一次你和同学互相帮助的事情。",
            "美术课上，我忘带彩笔了。同桌把他的彩笔借给我，我完成了图画。后来，他不会折纸，我耐心地教他。我们互相帮助，都很开心。",
            min_sentences=4,
            scaffold="我遇到______。同学______。后来同学______，我______。我们______。",
            word_bank=["忘带", "借给", "教会", "互相帮助", "开心"],
            scene="share_apple",
            criteria=["两次帮助都写到", "人物关系清楚", "有结尾感受", "4—6句话"],
        ),
        stage=3,
        skill="概括故事道理，联系生活写话",
    ),
    lesson(
        21,
        "雪地里的脚印",
        "清晨，地上铺着一层白雪。小雨穿好外套，跑到院子里。她发现雪地上有一串小脚印，就沿着脚印慢慢找。脚印来到树下便停住了。小雨抬头一看，原来是一只小猫躲在树枝间。她轻轻叫小猫的名字。小猫跳下来，跟着她一起回家。",
        [
            question("清晨，地上是什么样的？", "清晨，地上铺着一层白雪。", "地上铺着一层白雪", "第一句描写了地面。"),
            question("小雨怎样找到小猫？", "小雨沿着雪地上的脚印找到了小猫。", "沿着脚印慢慢找", "把“发现脚印”和“沿着找”连起来回答。"),
            question("小猫躲在哪里？", "小猫躲在树枝间。", "一只小猫躲在树枝间", "答案在第五句。"),
            question("给短文选一个合适的题目。", "《雪地里的脚印》最合适。", "雪地上有一串小脚印", "脚印是小雨找到小猫的主要线索。", kind="title", options=["雪地里的脚印", "一件新外套", "高高的大树"]),
        ],
        writing_task(
            "看图独立写4—6句话，要有开头、寻找经过、结果和感受。",
            "下雪了，院子里白白的。我发现地上有一串小脚印，就沿着脚印寻找。脚印一直来到树下。原来，小猫躲在树枝间。我叫它下来，和它一起回家。我觉得这件事真有趣。",
            min_sentences=4,
            scaffold="先观察时间和景物，再写发现、寻找、结果，最后写感受。",
            word_bank=["清晨", "白雪", "脚印", "沿着", "原来", "有趣"],
            scene="snow_cat",
            criteria=["开头交代清楚", "寻找经过有顺序", "结果完整", "有感受", "4—6句话"],
        ),
        stage=3,
        skill="综合阅读，独立看图写话",
    ),
]


def chinese_char_count(text: str) -> int:
    return len(re.findall(r"[\u4e00-\u9fff]", text))


def sentence_count(text: str) -> int:
    return len(re.findall(r"[。！？]", text))


def validate_lessons(lessons: list[dict[str, Any]]) -> None:
    if len(lessons) != 21:
        raise ValueError("训练应包含21天。")
    if [item["day"] for item in lessons] != list(range(1, 22)):
        raise ValueError("训练日期编号不连续。")

    titles: set[str] = set()
    texts: set[str] = set()
    for item in lessons:
        day = item["day"]
        stage = item["stage"]
        rule = STAGE_RANGES[stage]
        if day not in rule["days"]:
            raise ValueError(f"第{day}天阶段编号错误。")
        chars = chinese_char_count(item["text"])
        sentences = sentence_count(item["text"])
        if not rule["chars"][0] <= chars <= rule["chars"][1]:
            raise ValueError(
                f"第{day}天短文字数{chars}不在{rule['chars']}范围内。"
            )
        if not rule["sentences"][0] <= sentences <= rule["sentences"][1]:
            raise ValueError(
                f"第{day}天句数{sentences}不在{rule['sentences']}范围内。"
            )
        if len(item["questions"]) != rule["questions"]:
            raise ValueError(
                f"第{day}天应有{rule['questions']}道阅读题。"
            )
        for q_item in item["questions"]:
            if q_item["evidence"] not in item["text"]:
                raise ValueError(
                    f'第{day}天证据不在原文中：{q_item["evidence"]}'
                )
            if q_item["options"] and q_item["answer"].replace("《", "").replace("》最合适。", "") not in q_item["options"]:
                raise ValueError(f'第{day}天选择题答案不在选项中。')

        minimum = item["writing"]["min_sentences"]
        if sentence_count(item["writing"]["sample"]) < minimum:
            raise ValueError(
                f"第{day}天写作示例少于{minimum}句话。"
            )
        if item["title"] in titles or item["text"] in texts:
            raise ValueError(f"第{day}天标题或短文重复。")
        titles.add(item["title"])
        texts.add(item["text"])


CHECKS: list[dict[str, Any]] = [
    {
        "number": 1,
        "title": "第1阶段检测（第1—7天）",
        "subtitle": "读懂完整句 · 回答完整 · 写清一件事",
        "readings": [
            {
                "title": "爱捡球的小狗",
                "text": "小狗叼着皮球来到草地。小东把球扔出去，小狗飞快地跑去捡回来。",
                "questions": [
                    question("谁叼着皮球？", "小狗叼着皮球。", "小狗叼着皮球", "找人物。"),
                    question("小狗来到哪里？", "小狗来到草地。", "来到草地", "找地点。"),
                    question("小东扔球后，小狗做了什么？", "小狗飞快地跑去捡球。", "飞快地跑去捡回来", "找人物后面的动作。"),
                ],
            },
            {
                "title": "认真值日",
                "text": "放学后，小兰留下来值日。她先扫地，再擦桌子，教室很快变干净了。",
                "questions": [
                    question("小兰什么时候值日？", "小兰放学后值日。", "放学后", "找时间。"),
                    question("小兰先做什么，再做什么？", "小兰先扫地，再擦桌子。", "先扫地，再擦桌子", "找“先、再”。", kind="order"),
                    question("教室最后变得怎样？", "教室最后变干净了。", "教室很快变干净了", "找结果。"),
                ],
            },
        ],
        "writing": writing_task(
            "看图写2—3句话：同学们在教室里做什么？结果怎样？",
            "放学后，同学们一起打扫教室。有人扫地，有人擦桌子。教室变得很干净。",
            min_sentences=2,
            scaffold="放学后，______。有人______，有人______。最后______。",
            word_bank=["扫地", "擦桌子", "整理书本", "干净"],
            scene="clean_classroom",
            criteria=["人物和地点清楚", "至少两种动作", "写出结果", "标点正确"],
        ),
        "rubric": [
            ("内容完整", 15),
            ("句子完整", 10),
            ("顺序清楚", 5),
            ("标点正确", 7),
            ("书写整洁", 3),
        ],
    },
    {
        "number": 2,
        "title": "第2阶段检测（第8—14天）",
        "subtitle": "找顺序和原因 · 连续写3—4句",
        "readings": [
            {
                "title": "送雨伞",
                "text": "下午忽然下起雨来。小美想到妈妈没有带伞，就拿着两把伞来到车站。妈妈看见她，开心地笑了。母女俩一起撑伞回家。",
                "questions": [
                    question("小美为什么去车站？", "因为妈妈没有带伞。", "妈妈没有带伞", "找行动前面的原因。", kind="reason"),
                    question("小美带了几把伞？", "小美带了两把伞。", "拿着两把伞", "找数量。"),
                    question("妈妈看见小美后怎样了？", "妈妈开心地笑了。", "开心地笑了", "找人物的表现。"),
                ],
            },
            {
                "title": "松鼠准备过冬",
                "text": "秋天到了，小松鼠开始收集松果。它先在树下寻找，再把松果一个个运回树洞。每天忙完，它都认真数一数。树洞里的松果越来越多，小松鼠安心地笑了。",
                "questions": [
                    question("小松鼠为什么收集松果？", "小松鼠收集松果准备过冬。", "秋天到了", "根据季节和储存食物推断。", kind="inference"),
                    question("它先做什么，再做什么？", "它先寻找松果，再把松果运回树洞。", "先在树下寻找，再把松果一个个运回树洞", "找顺序词。", kind="order"),
                    question("小松鼠最后为什么安心？", "因为树洞里的松果越来越多。", "树洞里的松果越来越多", "结果前面就是原因。", kind="reason"),
                ],
            },
        ],
        "writing": writing_task(
            "看图写3—4句话：小朋友怎样给小树浇水？小树后来怎样？",
            "春天，小朋友种下一棵小树。他先松土，再给小树浇水。过了一段时间，小树长出了嫩叶。小朋友开心地笑了。",
            min_sentences=3,
            scaffold="春天，______。他先______，再______。后来______。他______。",
            word_bank=["种树", "松土", "浇水", "嫩叶", "开心"],
            scene="plant_tree",
            criteria=["时间和人物清楚", "过程有顺序", "写出变化和感受", "3—4句话"],
        ),
        "rubric": [
            ("内容完整", 12),
            ("顺序清楚", 12),
            ("句子通顺", 8),
            ("标点正确", 5),
            ("书写整洁", 3),
        ],
    },
    {
        "number": 3,
        "title": "第3阶段检测（第15—21天）",
        "subtitle": "证据定位与简单推断 · 独立写4—6句",
        "readings": [
            {
                "title": "雨后的彩虹",
                "text": "傍晚，雨慢慢停了。小云走到阳台上，发现天边出现了一道彩虹。彩虹像一座弯弯的小桥，红、橙、黄、绿几种颜色排在一起。弟弟也跑来看，兴奋地拍起手来。太阳渐渐落下，彩虹变淡了。姐弟俩把美丽的景象画在纸上。",
                "questions": [
                    question("彩虹是什么时候出现的？", "彩虹在傍晚雨停后出现。", "傍晚，雨慢慢停了", "合并时间和天气线索。"),
                    question("弟弟看见彩虹后有什么表现？", "弟弟兴奋地拍起手来。", "兴奋地拍起手来", "找人物动作。"),
                    question("姐弟俩为什么把景象画下来？", "因为他们觉得雨后的彩虹很美。", "美丽的景象画在纸上", "由“美丽”和“画下来”推断。", kind="inference"),
                ],
            },
            {
                "title": "会发光的窗户",
                "text": "晚上，小区忽然停电了。楼道里黑黑的，奶奶不敢下楼。小亮找来手电筒，站在楼梯口为奶奶照路。他一直把奶奶送到楼下。来电以后，奶奶夸小亮像一扇会发光的窗户。小亮听了，心里暖暖的。",
                "questions": [
                    question("奶奶为什么不敢下楼？", "因为楼道里黑黑的。", "楼道里黑黑的，奶奶不敢下楼", "原因就在结果前面。", kind="reason"),
                    question("小亮怎样帮助奶奶？", "小亮用手电筒照路，并把奶奶送到楼下。", "站在楼梯口为奶奶照路", "合并第三、四句的行动。"),
                    question("奶奶为什么说小亮像会发光的窗户？", "因为小亮给奶奶照亮道路，也带来了温暖。", "为奶奶照路", "从“照亮”和“帮助”两层意思推断。", kind="inference"),
                ],
            },
        ],
        "writing": writing_task(
            "看图独立写4—6句话：停电后，小朋友怎样帮助老人？",
            "晚上，小区停电了，楼道里很黑。老奶奶站在门口不敢下楼。小明拿来手电筒，为奶奶照亮台阶。他慢慢把奶奶送到楼下。奶奶连声道谢。小明觉得帮助别人很快乐。",
            min_sentences=4,
            scaffold="交代时间和困难，再写帮助过程、结果和感受。",
            word_bank=["停电", "手电筒", "照亮", "慢慢", "道谢", "快乐"],
            scene="flashlight_help",
            criteria=["开头交代困难", "帮助过程有细节", "结果和感受完整", "4—6句话"],
        ),
        "rubric": [
            ("内容完整", 12),
            ("过程有顺序", 10),
            ("细节具体", 8),
            ("句子和标点", 7),
            ("书写整洁", 3),
        ],
    },
]


def validate_checks(checks: list[dict[str, Any]]) -> None:
    if len(checks) != 3:
        raise ValueError("应有3次阶段检测。")
    for check in checks:
        if len(check["readings"]) != 2:
            raise ValueError("每次检测应有两篇阅读。")
        for reading in check["readings"]:
            if len(reading["questions"]) != 3:
                raise ValueError("每篇检测阅读应有3道题。")
            for q_item in reading["questions"]:
                if q_item["evidence"] not in reading["text"]:
                    raise ValueError(
                        f'{check["title"]}证据不在原文：{q_item["evidence"]}'
                    )
        if sum(score for _, score in check["rubric"]) != 40:
            raise ValueError(f'{check["title"]}写作评分不是40分。')
        if 30 + 30 + 40 != 100:
            raise ValueError("阶段检测总分不是100分。")


SPECIAL_CSS = base.PRINT_CSS + """
.rw-page,
.rw-check-page {
  font-size: 11.5pt;
  line-height: 1.45;
}
.rw-main-title {
  margin: 0;
  text-align: center;
  font-size: 20.5pt;
  letter-spacing: .05em;
}
.rw-banner {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 3mm;
  margin: 1.4mm 0;
}
.rw-chip {
  display: inline-block;
  padding: .7mm 2.5mm;
  border: 1pt solid #555;
  border-radius: 2mm;
  background: #f6f6f6;
  font-size: 9.5pt;
  font-weight: 700;
}
.rw-day {
  padding: 1mm 3mm;
  border: 1.5pt solid #222;
  border-radius: 3mm;
  font-size: 12.5pt;
  font-weight: 800;
}
.rw-fields {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 6mm;
  padding: 1.4mm 0 2mm;
  border-bottom: 1pt solid #555;
  font-size: 10.5pt;
}
.rw-field {
  display: inline-block;
  width: 29mm;
  height: 4.5mm;
  border-bottom: 1pt solid #555;
  vertical-align: bottom;
}
.rw-page .section,
.rw-check-page .section { margin-top: 1.6mm; }
.rw-page .section h2,
.rw-check-page .section h2 {
  margin-bottom: .8mm;
  padding: .9mm 2mm;
  font-size: 13.5pt;
}
.passage-box {
  padding: 2mm 3mm;
  border: 1.2pt solid #555;
  background: #fafafa;
  line-height: 1.75;
  text-indent: 2em;
}
.passage-title {
  margin-bottom: 1mm;
  text-align: center;
  font-weight: 800;
}
.keyword-tip {
  margin: 0 0 .8mm;
  color: #444;
  font-size: 9.8pt;
}
.rw-question {
  padding: 1.1mm 1mm;
  border-bottom: 1pt dashed #aaa;
  break-inside: avoid;
}
.rw-question-prompt { font-weight: 600; }
.rw-options {
  display: inline-flex;
  flex-wrap: wrap;
  gap: 1mm 5mm;
  margin-left: 3mm;
}
.answer-rule {
  height: 7mm;
  border-bottom: 1pt solid #777;
}
.writing-layout {
  display: grid;
  grid-template-columns: 58mm 1fr;
  gap: 4mm;
  align-items: center;
  padding: 1.5mm 2mm;
  border: 1pt solid #666;
}
.scene-svg {
  width: 56mm;
  height: 39mm;
  border: .8pt solid #aaa;
  background: white;
}
.writing-prompt p { margin: 0 0 1mm; }
.scaffold {
  padding: 1mm 2mm;
  border-left: 3pt solid #777;
  background: #f5f5f5;
  font-size: 10.5pt;
}
.word-bank {
  margin-top: 1mm;
  font-size: 9.8pt;
}
.writing-lines { margin-top: 1mm; }
.writing-line {
  height: 8mm;
  border-bottom: 1pt solid #888;
}
.self-check {
  display: flex;
  flex-wrap: wrap;
  gap: 2mm 5mm;
  margin-top: 1.2mm;
  padding: 1mm 2mm;
  border: 1pt dashed #888;
  font-size: 9.5pt;
}
.rw-score-strip {
  display: flex;
  justify-content: space-between;
  margin: 1.6mm 0;
  padding: 1.2mm 3mm;
  border: 1pt solid #666;
  background: #f2f2f2;
}
.check-reading {
  margin-bottom: 2mm;
  padding: 2mm 3mm;
  border: 1pt solid #666;
}
.check-reading h3 {
  margin: 0 0 1mm;
  text-align: center;
  font-size: 13pt;
}
.check-writing-scene {
  width: 100%;
  height: 68mm;
  border: 1pt solid #777;
}
.rubric-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 1mm;
  margin-top: 2mm;
}
.rubric-cell {
  padding: 1.5mm 1mm;
  border: 1pt solid #777;
  text-align: center;
  font-size: 9pt;
}
.evidence-card {
  margin: 1.5mm 0;
  padding: 2mm 2.5mm;
  border: 1pt solid #777;
  break-inside: avoid;
}
.evidence-quote {
  margin: 1mm 0;
  padding: 1mm 2mm;
  border-left: 3pt solid #555;
  background: #f4f4f4;
}
.answer-method {
  color: #444;
  font-size: 10.3pt;
}
.writing-sample {
  padding: 2mm 3mm;
  border: 1.2pt solid #555;
  background: #fafafa;
  line-height: 1.65;
}
.rubric-list {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.5mm 4mm;
}
.rubric-item {
  padding: 1.5mm 2mm;
  border: 1pt dashed #777;
}
.error-tag {
  display: inline-block;
  margin-right: 2mm;
  padding: .4mm 2mm;
  border: 1pt solid #777;
  border-radius: 2mm;
  font-size: 9.2pt;
  font-weight: 700;
}
"""

SPECIAL_CSS += """
.score-band {
  margin: 1.5mm 0;
  padding: 2mm 3mm;
  border: 1pt dashed #777;
}
"""


def person(x: int, y: int, scale: float = 1.0) -> str:
    return f"""
      <circle cx="{x}" cy="{y}" r="{7 * scale}" fill="white" stroke="black" stroke-width="2"/>
      <path d="M{x} {y + 7 * scale} V{y + 30 * scale}
               M{x} {y + 14 * scale} L{x - 13 * scale} {y + 23 * scale}
               M{x} {y + 14 * scale} L{x + 13 * scale} {y + 23 * scale}
               M{x} {y + 30 * scale} L{x - 10 * scale} {y + 45 * scale}
               M{x} {y + 30 * scale} L{x + 10 * scale} {y + 45 * scale}"
            fill="none" stroke="black" stroke-width="2"/>
    """


def tree(x: int, y: int, scale: float = 1.0) -> str:
    return f"""
      <rect x="{x - 4 * scale}" y="{y + 24 * scale}" width="{8 * scale}" height="{30 * scale}" fill="#ddd" stroke="black"/>
      <circle cx="{x}" cy="{y + 18 * scale}" r="{22 * scale}" fill="white" stroke="black" stroke-width="2"/>
    """


def cat(x: int, y: int, scale: float = 1.0) -> str:
    return f"""
      <circle cx="{x}" cy="{y}" r="{12 * scale}" fill="white" stroke="black" stroke-width="2"/>
      <polygon points="{x - 10 * scale},{y - 8 * scale} {x - 6 * scale},{y - 20 * scale} {x},{y - 10 * scale}" fill="white" stroke="black"/>
      <polygon points="{x + 10 * scale},{y - 8 * scale} {x + 6 * scale},{y - 20 * scale} {x},{y - 10 * scale}" fill="white" stroke="black"/>
      <ellipse cx="{x}" cy="{y + 27 * scale}" rx="{18 * scale}" ry="{14 * scale}" fill="white" stroke="black" stroke-width="2"/>
      <circle cx="{x - 4 * scale}" cy="{y - 1 * scale}" r="{1.5 * scale}"/><circle cx="{x + 4 * scale}" cy="{y - 1 * scale}" r="{1.5 * scale}"/>
    """


def bird(x: int, y: int, scale: float = 1.0) -> str:
    return f"""
      <ellipse cx="{x}" cy="{y}" rx="{13 * scale}" ry="{9 * scale}" fill="white" stroke="black" stroke-width="2"/>
      <circle cx="{x + 11 * scale}" cy="{y - 7 * scale}" r="{7 * scale}" fill="white" stroke="black"/>
      <polygon points="{x + 18 * scale},{y - 7 * scale} {x + 26 * scale},{y - 3 * scale} {x + 18 * scale},{y}" fill="#ddd" stroke="black"/>
      <path d="M{x - 4 * scale} {y} Q{x + 2 * scale} {y - 12 * scale} {x + 8 * scale} {y}" fill="none" stroke="black"/>
    """


def cloud(x: int, y: int, *, rain: bool = False) -> str:
    drops = (
        f'<path d="M{x - 18} {y + 17} l-5 12 M{x} {y + 17} l-5 12 M{x + 18} {y + 17} l-5 12" stroke="black" stroke-width="2"/>'
        if rain
        else ""
    )
    return f"""
      <path d="M{x - 32} {y + 10} Q{x - 40} {y} {x - 25} {y - 4}
               Q{x - 18} {y - 22} {x - 2} {y - 10}
               Q{x + 12} {y - 26} {x + 23} {y - 8}
               Q{x + 40} {y - 5} {x + 34} {y + 10} Z"
            fill="white" stroke="black" stroke-width="2"/>
      {drops}
    """


def book(x: int, y: int, scale: float = 1.0) -> str:
    return f"""
      <path d="M{x - 25 * scale} {y - 15 * scale} Q{x - 10 * scale} {y - 20 * scale} {x} {y - 9 * scale}
               V{y + 20 * scale} Q{x - 12 * scale} {y + 12 * scale} {x - 25 * scale} {y + 16 * scale} Z
               M{x + 25 * scale} {y - 15 * scale} Q{x + 10 * scale} {y - 20 * scale} {x} {y - 9 * scale}
               V{y + 20 * scale} Q{x + 12 * scale} {y + 12 * scale} {x + 25 * scale} {y + 16 * scale} Z"
            fill="white" stroke="black" stroke-width="2"/>
    """


def house(x: int, y: int, scale: float = 1.0) -> str:
    return f"""
      <polygon points="{x - 28 * scale},{y} {x},{y - 24 * scale} {x + 28 * scale},{y}" fill="#eee" stroke="black" stroke-width="2"/>
      <rect x="{x - 22 * scale}" y="{y}" width="{44 * scale}" height="{34 * scale}" fill="white" stroke="black" stroke-width="2"/>
      <rect x="{x - 6 * scale}" y="{y + 13 * scale}" width="{12 * scale}" height="{21 * scale}" fill="#eee" stroke="black"/>
    """


def plant(x: int, y: int, scale: float = 1.0) -> str:
    return f"""
      <path d="M{x} {y + 25 * scale} V{y - 8 * scale}
               M{x} {y + 4 * scale} Q{x - 16 * scale} {y - 7 * scale} {x - 21 * scale} {y + 5 * scale}
               M{x} {y - 1 * scale} Q{x + 16 * scale} {y - 12 * scale} {x + 21 * scale} {y}"
            fill="none" stroke="black" stroke-width="2"/>
      <path d="M{x - 21 * scale} {y + 5 * scale} Q{x - 11 * scale} {y + 11 * scale} {x} {y + 4 * scale}
               M{x + 21 * scale} {y} Q{x + 11 * scale} {y + 7 * scale} {x} {y - 1 * scale}"
            fill="none" stroke="black"/>
    """


def scene_svg(name: str, *, large: bool = False) -> str:
    ground = '<path d="M5 88 H175" stroke="black" stroke-width="1.5"/>'
    scenes = {
        "cat_sun": f'<circle cx="145" cy="18" r="11" fill="white" stroke="black"/>{cat(82, 48, .9)}<rect x="38" y="18" width="95" height="66" fill="none" stroke="black" stroke-width="2"/>',
        "school_walk": f'{house(140, 42, .8)}{person(55, 38, .9)}<rect x="63" y="51" width="11" height="17" fill="#ddd" stroke="black"/>',
        "rain_leaf": f'{cloud(42, 25, rain=True)}<path d="M92 62 Q120 26 158 43 Q133 74 92 62 Z" fill="white" stroke="black" stroke-width="2"/><circle cx="118" cy="50" r="4" fill="white" stroke="black"/>',
        "breakfast": f'{person(35, 34, .8)}<path d="M75 55 H163 M87 55 V84 M151 55 V84" stroke="black" stroke-width="2"/><ellipse cx="105" cy="50" rx="13" ry="7" fill="white" stroke="black"/><rect x="130" y="38" width="16" height="17" fill="white" stroke="black"/>',
        "playground": f'{person(35, 34, .7)}{person(90, 34, .7)}{person(145, 34, .7)}<circle cx="111" cy="72" r="10" fill="white" stroke="black"/><path d="M22 60 Q35 40 48 60" fill="none" stroke="black"/>',
        "fish_tank": '<rect x="20" y="16" width="140" height="67" fill="white" stroke="black" stroke-width="2"/><ellipse cx="62" cy="43" rx="18" ry="9" fill="white" stroke="black"/><polygon points="44,43 32,34 32,52" fill="#ddd" stroke="black"/><ellipse cx="120" cy="59" rx="16" ry="8" fill="white" stroke="black"/><polygon points="104,59 93,51 93,67" fill="#ddd" stroke="black"/><path d="M75 82 Q78 56 87 40 M135 82 Q141 58 151 47" stroke="black"/>',
        "umbrella": f'<path d="M47 40 Q90 3 133 40 Z" fill="white" stroke="black" stroke-width="2"/><path d="M90 40 V80 Q90 88 82 83" fill="none" stroke="black" stroke-width="2"/>{person(72, 45, .65)}{person(108, 45, .65)}{cloud(28, 16, rain=True)}',
        "wash_hands": f'{person(45, 39, .7)}<path d="M100 27 H145 V42 H125 M145 27 V18 H128" fill="none" stroke="black" stroke-width="4"/><path d="M122 45 l-4 15 M132 45 l-4 15" stroke="black"/><ellipse cx="125" cy="68" rx="28" ry="8" fill="white" stroke="black"/>',
        "plant_tree": f'{person(40, 37, .75)}{plant(117, 46, 1.2)}<path d="M90 76 Q118 62 146 76" fill="none" stroke="black" stroke-width="2"/><path d="M59 58 Q76 52 82 68" fill="none" stroke="black" stroke-width="3"/>',
        "bird_fly": f'{tree(35, 34, .8)}{bird(84, 29, .7)}{bird(132, 46, .7)}<path d="M83 83 Q115 70 158 83" fill="none" stroke="black" stroke-width="2"/>',
        "tidy_desk": f'{person(35, 38, .7)}<path d="M72 52 H165 M82 52 V84 M153 52 V84" stroke="black" stroke-width="3"/>{book(104, 44, .55)}{book(135, 39, .45)}',
        "autumn": f'{tree(55, 27, 1.0)}{person(128, 40, .7)}<circle cx="105" cy="35" r="4" fill="white" stroke="black"/><circle cx="123" cy="23" r="4" fill="white" stroke="black"/><circle cx="87" cy="56" r="4" fill="white" stroke="black"/>',
        "share": f'{person(48, 39, .75)}{person(132, 39, .75)}<circle cx="90" cy="48" r="12" fill="white" stroke="black"/><path d="M60 55 L80 50 M120 55 L100 50" stroke="black" stroke-width="2"/>',
        "library": f'<rect x="92" y="12" width="73" height="70" fill="white" stroke="black" stroke-width="2"/><path d="M92 35 H165 M92 58 H165" stroke="black"/><path d="M100 15 V33 M111 15 V33 M124 15 V33 M103 38 V56 M118 38 V56 M133 38 V56 M105 61 V80 M121 61 V80 M142 61 V80" stroke="black" stroke-width="4"/>{person(40, 39, .75)}',
        "spring_park": f'{tree(45, 29, .85)}{person(126, 43, .65)}{bird(105, 18, .45)}{plant(78, 65, .45)}{plant(102, 66, .45)}<circle cx="155" cy="16" r="10" fill="white" stroke="black"/>',
        "ants_rain": f'{cloud(143, 20, rain=True)}<path d="M20 70 Q55 45 95 68" fill="none" stroke="black"/><circle cx="37" cy="66" r="4"/><circle cx="50" cy="61" r="4"/><circle cx="64" cy="59" r="4"/><circle cx="79" cy="62" r="4"/>{person(115, 41, .6)}',
        "rescue_bird": f'{person(42, 38, .75)}{bird(108, 40, .6)}<rect x="90" y="56" width="45" height="27" fill="white" stroke="black" stroke-width="2"/><path d="M57 57 L87 62" stroke="black" stroke-width="2"/>',
        "lost_bottle": f'{person(42, 38, .75)}<rect x="118" y="20" width="42" height="53" fill="none" stroke="black" stroke-width="2"/><path d="M118 46 H160" stroke="black"/><path d="M137 37 V60 M131 37 H143 M133 28 H141 V37 H133 Z" fill="white" stroke="black"/>',
        "seed_growth": f'{plant(35, 62, .35)}{plant(90, 50, .75)}{plant(145, 36, 1.15)}<path d="M52 55 H70 M107 45 H124" stroke="black" marker-end="url(#arrow)"/><defs><marker id="arrow" markerWidth="6" markerHeight="6" refX="5" refY="3" orient="auto"><path d="M0 0 L6 3 L0 6 Z"/></marker></defs>',
        "share_apple": f'{person(48, 38, .75)}{person(132, 38, .75)}<circle cx="90" cy="48" r="12" fill="white" stroke="black" stroke-width="2"/><path d="M90 36 V60 M60 54 L80 49 M120 54 L100 49" stroke="black"/>',
        "snow_cat": f'{tree(140, 29, .8)}{cat(130, 31, .45)}{person(42, 42, .65)}<circle cx="73" cy="73" r="3"/><circle cx="87" cy="68" r="3"/><circle cx="101" cy="61" r="3"/><path d="M5 84 Q90 72 175 84" fill="none" stroke="black"/>',
        "clean_classroom": f'{person(35, 39, .65)}{person(83, 39, .65)}{person(132, 39, .65)}<path d="M50 56 L58 82 M50 56 L42 80 M98 63 H164 M108 63 V84 M152 63 V84" stroke="black" stroke-width="2"/>',
        "flashlight_help": f'{person(45, 36, .7)}{person(125, 35, .75)}<path d="M58 53 L104 42 L104 65 Z" fill="#eee" stroke="black"/><path d="M105 82 H170 M115 70 H170 M125 58 H170" stroke="black"/>',
    }
    content = scenes.get(name)
    if content is None:
        raise ValueError(f"未知写作场景：{name}")
    css_class = "check-writing-scene" if large else "scene-svg"
    return (
        f'<svg class="{css_class}" viewBox="0 0 180 100" role="img" '
        f'aria-label="{base.esc(name)}">{ground}{content}</svg>'
    )


def rw_footer(label: str) -> str:
    return f"""
      <div class="page-footer">
        <span>先回原文找证据 · 再用完整句回答 · 最后迁移写话</span>
        <span>{base.esc(label)}</span>
      </div>
    """


def lesson_header(item: dict[str, Any]) -> str:
    stage_names = {
        1: "第一阶段：一句读懂，一句写清",
        2: "第二阶段：段落找信息，按顺序表达",
        3: "第三阶段：短文理解，独立看图写话",
    }
    return f"""
      <h1 class="rw-main-title">一年级阅读写作21天训练</h1>
      <div class="rw-banner">
        <span class="rw-day">第{item["day"]:02d}天</span>
        <span class="rw-chip">{base.esc(stage_names[item["stage"]])}</span>
        <span>{base.esc(item["skill"])}</span>
      </div>
      <div class="rw-fields">
        <div>姓名：<span class="rw-field"></span></div>
        <div>日期：<span class="rw-field"></span></div>
        <div>用时：<span class="rw-field"></span></div>
      </div>
    """


def render_questions(
    questions: list[dict[str, Any]],
    *,
    compact: bool = False,
) -> str:
    items: list[str] = []
    for index, item in enumerate(questions, start=1):
        options = ""
        if item["options"]:
            options = '<span class="rw-options">' + "".join(
                f'<span>□ {base.esc(option)}</span>'
                for option in item["options"]
            ) + "</span>"
        answer_rule = '<div class="answer-rule"></div>'
        if not compact and item["kind"] == "summary":
            answer_rule += '<div class="answer-rule"></div>'
        items.append(
            f"""
            <div class="rw-question">
              <span class="rw-question-prompt">（{index}）{base.esc(item["prompt"])}</span>
              {options}
              {answer_rule}
            </div>
            """
        )
    return "".join(items)


def writing_line_count(stage: int) -> int:
    return {1: 4, 2: 5, 3: 6}[stage]


def render_writing_task(
    task: dict[str, Any],
    *,
    stage: int,
    check_mode: bool = False,
) -> str:
    word_bank = (
        f'<div class="word-bank"><strong>词语小帮手：</strong>{"、".join(base.esc(word) for word in task["word_bank"])}</div>'
        if task["word_bank"]
        else ""
    )
    scaffold = (
        f'<div class="scaffold"><strong>表达支架：</strong>{base.esc(task["scaffold"])}</div>'
        if task["scaffold"]
        else ""
    )
    visual = scene_svg(task["scene"], large=check_mode) if task["scene"] else ""
    line_total = 9 if check_mode else writing_line_count(stage)
    lines = "".join('<div class="writing-line"></div>' for _ in range(line_total))
    checklist = "".join(
        f'<span>□ {base.esc(item)}</span>'
        for item in task["criteria"]
    )
    if check_mode:
        return f"""
          {visual}
          <div class="writing-prompt">
            <p><strong>{base.esc(task["prompt"])}</strong></p>
            {scaffold}
            {word_bank}
          </div>
          <div class="writing-lines">{lines}</div>
          <div class="self-check">{checklist}</div>
        """
    return f"""
      <div class="writing-layout">
        {visual}
        <div class="writing-prompt">
          <p><strong>{base.esc(task["prompt"])}</strong></p>
          {scaffold}
          {word_bank}
        </div>
      </div>
      <div class="writing-lines">{lines}</div>
      <div class="self-check"><strong>写完自查：</strong>{checklist}</div>
    """


def render_daily_page(item: dict[str, Any]) -> str:
    return f"""
    <section class="page rw-page">
      {lesson_header(item)}

      <div class="section">
        <h2>一、读短文，圈出关键词</h2>
        <p class="keyword-tip">先读两遍；再圈出题目会问到的人物、时间、地点、动作或结果。</p>
        <div class="passage-title">{base.esc(item["title"])}</div>
        <div class="passage-box">{base.esc(item["text"])}</div>
      </div>

      <div class="section">
        <h2>二、回到原文，用完整句回答</h2>
        {render_questions(item["questions"])}
      </div>

      <div class="section">
        <h2>三、从阅读走向写话</h2>
        {render_writing_task(item["writing"], stage=item["stage"])}
      </div>
      {rw_footer(f'第{item["day"]:02d}天 / 共21天')}
    </section>
    """


def render_training_html(lessons: list[dict[str, Any]]) -> str:
    pages = "".join(render_daily_page(item) for item in lessons)
    return f"""<!doctype html>
    <html lang="zh-CN">
      <head>
        <meta charset="utf-8">
        <title>一年级阅读写作21天训练册</title>
        <style>{SPECIAL_CSS}</style>
      </head>
      <body>{pages}</body>
    </html>"""


def check_header(check: dict[str, Any]) -> str:
    return f"""
      <h1 class="rw-main-title">一年级阅读写作阶段检测</h1>
      <div class="rw-banner">
        <span class="rw-day">{base.esc(check["title"])}</span>
        <span class="rw-chip">{base.esc(check["subtitle"])}</span>
      </div>
      <div class="rw-fields">
        <div>姓名：<span class="rw-field"></span></div>
        <div>日期：<span class="rw-field"></span></div>
        <div>用时：<span class="rw-field"></span></div>
      </div>
    """


def render_check_reading(
    reading: dict[str, Any],
    number: int,
) -> str:
    return f"""
      <div class="check-reading">
        <h3>阅读{number}：{base.esc(reading["title"])}</h3>
        <div class="passage-box">{base.esc(reading["text"])}</div>
        {render_questions(reading["questions"], compact=True)}
      </div>
    """


def render_check_page_one(check: dict[str, Any]) -> str:
    readings = "".join(
        render_check_reading(reading, index)
        for index, reading in enumerate(check["readings"], start=1)
    )
    return f"""
    <section class="page rw-check-page">
      {check_header(check)}
      <div class="rw-score-strip"><span>阅读：60分</span><span>写话：40分</span><span>总分：________</span></div>
      <div class="section">
        <h2>一、阅读短文，完成练习（每题10分，共60分）</h2>
        {readings}
      </div>
      {rw_footer(f'第{check["number"]}次阶段检测 1/2')}
    </section>
    """


def render_check_page_two(check: dict[str, Any]) -> str:
    rubric = "".join(
        f'<div class="rubric-cell">{base.esc(label)}<br>{score}分<br>得分____</div>'
        for label, score in check["rubric"]
    )
    stage = check["number"]
    return f"""
    <section class="page rw-check-page">
      {check_header(check)}
      <div class="section">
        <h2>二、看图写话（40分）</h2>
        {render_writing_task(check["writing"], stage=stage, check_mode=True)}
        <div class="rubric-grid">{rubric}</div>
      </div>
      {rw_footer(f'第{check["number"]}次阶段检测 2/2')}
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


ERROR_LABELS = {
    "direct": "E 证据定位",
    "order": "O 顺序",
    "reason": "C 原因结果",
    "pronoun": "P 指代",
    "title": "S 概括标题",
    "summary": "S 概括",
    "inference": "I 简单推断",
}


def render_question_answer(
    item: dict[str, Any],
    index: int,
) -> str:
    label = ERROR_LABELS.get(item["kind"], "E 证据定位")
    return f"""
      <div class="evidence-card">
        <div><span class="error-tag">{base.esc(label)}</span><strong>（{index}）{base.esc(item["prompt"])}</strong></div>
        <p><strong>答案：</strong>{base.esc(item["answer"])}</p>
        <div class="evidence-quote"><strong>原文证据：</strong>“{base.esc(item["evidence"])}”</div>
        <div class="answer-method"><strong>怎样找到：</strong>{base.esc(item["method"])}</div>
      </div>
    """


def stage_correction(stage: int) -> list[str]:
    if stage == 1:
        return [
            "让孩子重新读题，圈出“谁、哪里、做什么”等题眼。",
            "回原文找到相同词语，用直线连到题目旁边。",
            "把原文中的短答案补成完整句，再读一遍检查句号。",
        ]
    if stage == 2:
        return [
            "用不同符号圈出“先、接着、最后”和“因为、所以”。",
            "把有关句子按顺序口头说一遍，再写答案。",
            "写话只改一个重点：顺序、完整句或标点，不整段重抄。",
        ]
    return [
        "直接信息题先找原文；推断题要同时写出线索和结论。",
        "复述时只保留人物、主要事情、结果，不逐句背诵。",
        "写话先口头列出开头、经过、结果，再补一个动作或感受细节。",
    ]


def render_writing_answer(task: dict[str, Any]) -> str:
    word_bank = (
        f'<p><strong>可以替换的词：</strong>{"、".join(base.esc(word) for word in task["word_bank"])}</p>'
        if task["word_bank"]
        else ""
    )
    rubric = "".join(
        f'<div class="rubric-item">□ {base.esc(item)}</div>'
        for item in task["criteria"]
    )
    return f"""
      <h2>写话示例与评价</h2>
      <div class="writing-sample">
        <strong>基础示例：</strong>{base.esc(task["sample"])}
      </div>
      {word_bank}
      <p class="answer-method">示例不是唯一答案。孩子只要符合图意或题意、句子完整、顺序合理即可，不要求照抄。</p>
      <div class="rubric-list">{rubric}</div>
    """


def render_daily_answer(item: dict[str, Any]) -> str:
    question_cards = "".join(
        render_question_answer(q_item, index)
        for index, q_item in enumerate(item["questions"], start=1)
    )
    correction = "".join(
        f"<li>{base.esc(step)}</li>"
        for step in stage_correction(item["stage"])
    )
    return f"""
    <section class="answer-set">
      <h1>第{item["day"]:02d}天答案与解析</h1>
      <div class="answer-callout">
        <strong>今日能力：</strong>{base.esc(item["skill"])}　
        <strong>原文：</strong>{base.esc(item["title"])}
      </div>
      <h2>阅读答案：答案从哪里来</h2>
      {question_cards}
      {render_writing_answer(item["writing"])}
      <h2>家长5分钟订正</h2>
      <ol class="thinking-steps">{correction}</ol>
    </section>
    """


def render_parent_guide() -> str:
    return """
    <section class="answer-set">
      <h1>家长使用与批改说明</h1>
      <h2>每天怎样完成</h2>
      <ol class="thinking-steps">
        <li>孩子先朗读两遍，第二遍圈人物、时间、地点、动作或结果。</li>
        <li>每道题必须先在原文找到证据，再用完整句回答。</li>
        <li>写话前先口头说，确认顺序后再落笔；写完按自查框逐项检查。</li>
      </ol>

      <h2>六类错误怎么记</h2>
      <div class="evidence-card"><span class="error-tag">Q 题意</span>没有看清题目问“谁、哪里、为什么”中的哪一个。</div>
      <div class="evidence-card"><span class="error-tag">E 证据</span>没有回原文定位，凭印象作答。</div>
      <div class="evidence-card"><span class="error-tag">A 完整</span>只写一个词，没有组成完整回答句。</div>
      <div class="evidence-card"><span class="error-tag">O 顺序</span>先后过程颠倒，连接词使用不当。</div>
      <div class="evidence-card"><span class="error-tag">S 句子</span>人物或动作缺失，句子不通顺。</div>
      <div class="evidence-card"><span class="error-tag">M 标点</span>一句话结束没有句号，人物说话标点不正确。</div>

      <h2>批改顺序</h2>
      <p>先看内容是否符合题意，再看顺序和完整句，最后才改错字与标点。
      每次只选择最重要的一类问题订正，避免把孩子的表达全部改成成人范文。</p>
    </section>
    """


def render_check_answer(check: dict[str, Any]) -> str:
    reading_sections: list[str] = []
    for reading_index, reading in enumerate(check["readings"], start=1):
        cards = "".join(
            render_question_answer(q_item, q_index)
            for q_index, q_item in enumerate(reading["questions"], start=1)
        )
        reading_sections.append(
            f"""
            <h2>阅读{reading_index}：{base.esc(reading["title"])}</h2>
            {cards}
            """
        )
    rubric = "".join(
        f'<div class="rubric-item"><strong>{base.esc(label)}：</strong>{score}分</div>'
        for label, score in check["rubric"]
    )
    return f"""
    <section class="answer-set">
      <h1>{base.esc(check["title"])}答案与评分</h1>
      {"".join(reading_sections)}
      <h2>看图写话参考</h2>
      <div class="writing-sample">{base.esc(check["writing"]["sample"])}</div>
      <p class="answer-method">这是参考表达，不是唯一答案。按下面维度分别评分，不因个别错字否定整篇内容。</p>
      <div class="rubric-list">{rubric}</div>

      <h2>分数说明</h2>
      <div class="score-band"><strong>90—100分：</strong>证据定位和表达较稳，可继续下一阶段。</div>
      <div class="score-band"><strong>75—89分：</strong>整体达标，按错误标签回练最近3天。</div>
      <div class="score-band"><strong>60—74分：</strong>先减少题量，重点练完整句回答和写话顺序。</div>
      <div class="score-band"><strong>60分以下：</strong>回到本阶段前3天，每天只练一篇短文和一个完整句。</div>
    </section>
    """


def render_answer_html(
    lessons: list[dict[str, Any]],
    checks: list[dict[str, Any]],
) -> str:
    cover = """
    <section class="answer-cover">
      <h1>一年级阅读写作21天训练</h1>
      <h2>答案解析与家长指导</h2>
      <div class="answer-note">
        <p><strong>核心方法：</strong>读题 → 圈关键词 → 回原文找证据 → 完整句回答 → 迁移写话。</p>
        <p><strong>写话原则：</strong>先把人物、事情和顺序写清楚，再增加动作、样子和感受。</p>
        <p><strong>注意：</strong>写话示例不是唯一答案，不要求孩子背诵或照抄。</p>
      </div>
    </section>
    """
    guide = render_parent_guide()
    daily = "".join(render_daily_answer(item) for item in lessons)
    check_answers = "".join(render_check_answer(check) for check in checks)
    return f"""<!doctype html>
    <html lang="zh-CN">
      <head>
        <meta charset="utf-8">
        <title>一年级阅读写作训练答案解析与家长指导</title>
        <style>{SPECIAL_CSS}</style>
      </head>
      <body class="answer-document">{cover}{guide}{daily}{check_answers}</body>
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


def validate_outputs(
    lessons: list[dict[str, Any]],
    checks: list[dict[str, Any]],
) -> None:
    paths = [TRAINING_PDF, *(CHECK_PDFS[index] for index in range(1, 4)), ANSWER_PDF]
    missing = [path.name for path in paths if not path.exists()]
    if missing:
        raise RuntimeError(f"缺少PDF文件：{missing}")
    for path in paths:
        if path.read_bytes()[:5] != b"%PDF-":
            raise RuntimeError(f"不是有效PDF：{path.name}")
        if path.stat().st_size < 20_000:
            raise RuntimeError(f"PDF文件过小，可能生成失败：{path.name}")

    training_pages, training_a4, training_text, training_drawings, training_outside = pdf_report(TRAINING_PDF)
    if training_pages != 21 or not training_a4 or training_outside:
        raise RuntimeError(
            f"训练册页面异常：页数={training_pages}，A4={training_a4}，越界={training_outside}"
        )
    for day in range(1, 22):
        if f"第{day:02d}天" not in training_text:
            raise RuntimeError(f"训练册缺少第{day:02d}天。")
    for marker in ("圈出关键词", "回到原文", "从阅读走向写话", "写完自查"):
        if training_text.count(marker) < 21:
            raise RuntimeError(f"训练册每日结构不完整：{marker}")

    check_reports = []
    for check in checks:
        path = CHECK_PDFS[check["number"]]
        pages, is_a4, text, drawings, outside = pdf_report(path)
        if pages != 2 or not is_a4 or outside:
            raise RuntimeError(
                f"{path.name}页面异常：页数={pages}，A4={is_a4}，越界={outside}"
            )
        for marker in ("阅读短文", "看图写话", "总分"):
            if marker not in text:
                raise RuntimeError(f"{path.name}缺少内容：{marker}")
        check_reports.append(
            {"file": path.name, "pages": pages, "drawings": drawings}
        )

    answer_pages, answer_a4, answer_text, answer_drawings, answer_outside = pdf_report(ANSWER_PDF)
    if answer_pages < 26 or not answer_a4 or answer_outside:
        raise RuntimeError(
            f"答案册页面异常：页数={answer_pages}，A4={answer_a4}，越界={answer_outside}"
        )
    for marker in ("家长使用与批改说明", "原文证据", "写话示例与评价"):
        if marker not in answer_text:
            raise RuntimeError(f"答案册缺少内容：{marker}")
    for day in range(1, 22):
        if f"第{day:02d}天答案与解析" not in answer_text:
            raise RuntimeError(f"答案册缺少第{day:02d}天。")
    for number in range(1, 4):
        if f"第{number}阶段检测" not in answer_text:
            raise RuntimeError(f"答案册缺少第{number}阶段检测答案。")

    print(
        json.dumps(
            {
                "daily_lessons": len(lessons),
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
    validate_lessons(LESSONS)
    validate_checks(CHECKS)
    await build_pdfs(LESSONS, CHECKS)
    validate_outputs(LESSONS, CHECKS)


if __name__ == "__main__":
    asyncio.run(main())
