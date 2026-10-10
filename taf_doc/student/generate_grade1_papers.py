from __future__ import annotations

import asyncio
import html
import json
import re
import sys
from pathlib import Path
from typing import Any

from playwright.async_api import async_playwright


ROOT = Path(__file__).resolve().parent
ANSWER_PDF = ROOT / "一年级上册语文数学_答案与详细图解.pdf"

PINYIN_BANK = [
    ("山", "shān", "shāng"),
    ("水", "shuǐ", "suǐ"),
    ("月", "yuè", "yè"),
    ("火", "huǒ", "hǒu"),
    ("天", "tiān", "diān"),
    ("人", "rén", "yén"),
    ("口", "kǒu", "tǒu"),
    ("手", "shǒu", "sǒu"),
    ("日", "rì", "yì"),
    ("田", "tián", "dián"),
    ("小", "xiǎo", "xiào"),
    ("大", "dà", "tà"),
    ("木", "mù", "nù"),
    ("土", "tǔ", "dǔ"),
    ("上", "shàng", "sàng"),
    ("下", "xià", "xiè"),
    ("云", "yún", "yóng"),
    ("雨", "yǔ", "yǚ"),
    ("鸟", "niǎo", "liǎo"),
    ("虫", "chóng", "cóng"),
    ("书", "shū", "sū"),
    ("本", "běn", "běng"),
    ("早", "zǎo", "zhǎo"),
    ("中", "zhōng", "zōng"),
    ("牛", "niú", "liú"),
    ("羊", "yáng", "ráng"),
    ("竹", "zhú", "zú"),
    ("石", "shí", "sí"),
    ("风", "fēng", "fōng"),
    ("花", "huā", "fā"),
    ("星", "xīng", "xīn"),
    ("船", "chuán", "cuán"),
    ("江", "jiāng", "qiāng"),
    ("南", "nán", "lán"),
    ("冬", "dōng", "tōng"),
    ("春", "chūn", "cūn"),
    ("红", "hóng", "hén"),
    ("蓝", "lán", "nán"),
    ("明", "míng", "mín"),
    ("光", "guāng", "kuāng"),
]

WRITING_BANK = [
    ("rén kǒu", "人口"),
    ("dà shǒu", "大手"),
    ("rì yuè", "日月"),
    ("shān shuǐ", "山水"),
    ("shàng shān", "上山"),
    ("tiān dì", "天地"),
    ("mù tóu", "木头"),
    ("huǒ shān", "火山"),
    ("tián dì", "田地"),
    ("ěr mù", "耳目"),
    ("wǔ gè", "五个"),
    ("dà xiǎo", "大小"),
    ("rì zi", "日子"),
    ("ér zi", "儿子"),
    ("dōng xi", "东西"),
    ("sì fāng", "四方"),
    ("kě kǒu", "可口"),
    ("kāi mén", "开门"),
    ("nǚ ér", "女儿"),
    ("zì jǐ", "自己"),
    ("shū běn", "书本"),
    ("tóng xué", "同学"),
    ("míng tiān", "明天"),
    ("bái yún", "白云"),
    ("xiǎo niǎo", "小鸟"),
    ("xià yǔ", "下雨"),
    ("huí lái", "回来"),
    ("gōng chǎng", "工厂"),
    ("zhú zi", "竹子"),
    ("shí tou", "石头"),
    ("duō shao", "多少"),
    ("zǎo shang", "早上"),
    ("shuǐ tián", "水田"),
    ("zhōng xīn", "中心"),
    ("lì zhèng", "立正"),
    ("běn lái", "本来"),
    ("xiǎo yǔ", "小雨"),
    ("niú yáng", "牛羊"),
    ("dà shān", "大山"),
    ("hǎo rén", "好人"),
]

STROKE_BANK = [
    ("山", 3),
    ("水", 4),
    ("火", 4),
    ("月", 4),
    ("日", 4),
    ("田", 5),
    ("木", 4),
    ("人", 2),
    ("口", 3),
    ("手", 4),
]

RADICAL_BANK = [
    ("明", "日字旁"),
    ("妈", "女字旁"),
    ("江", "三点水"),
    ("树", "木字旁"),
    ("花", "草字头"),
    ("们", "单人旁"),
    ("问", "门字框"),
    ("猫", "反犬旁"),
    ("打", "提手旁"),
    ("闪", "门字框"),
]

ANTONYM_BANK = [
    ("大", "小"),
    ("上", "下"),
    ("多", "少"),
    ("来", "去"),
    ("开", "关"),
    ("正", "反"),
    ("早", "晚"),
    ("长", "短"),
    ("前", "后"),
    ("左", "右"),
    ("里", "外"),
    ("有", "无"),
    ("高", "低"),
    ("白", "黑"),
    ("男", "女"),
    ("天", "地"),
    ("东", "西"),
    ("南", "北"),
    ("冷", "热"),
    ("快", "慢"),
]

QUANTIFIER_BANK = [
    ("书", "本"),
    ("鸟", "只"),
    ("花", "朵"),
    ("牛", "头"),
    ("鱼", "条"),
    ("树叶", "片"),
    ("雨伞", "把"),
    ("星星", "颗"),
    ("小船", "只"),
    ("铅笔", "支"),
    ("白云", "朵"),
    ("小马", "匹"),
    ("衣服", "件"),
    ("石头", "块"),
    ("书包", "个"),
    ("红旗", "面"),
    ("大树", "棵"),
    ("杯子", "个"),
    ("鸭子", "只"),
    ("彩虹", "道"),
]

SENTENCE_PROFILES = [
    {
        "order": [
            (["我", "爱", "读书"], "我爱读书。"),
            (["天上", "飘着", "白云"], "天上飘着白云。"),
        ],
        "complete": [
            ("我在学校里______。", "我在学校里认真读书。"),
            ("______像______。", "弯弯的月儿像小船。"),
        ],
    },
    {
        "order": [
            (["小鸟", "在", "唱歌"], "小鸟在唱歌。"),
            (["我们", "一起", "上学"], "我们一起上学。"),
        ],
        "complete": [
            ("早上，我______。", "早上，我背着书包去上学。"),
            ("______真______！", "校园真美丽！"),
        ],
    },
    {
        "order": [
            (["月儿", "弯弯的", "像", "小船"], "弯弯的月儿像小船。"),
            (["小鱼", "在", "水里", "游"], "小鱼在水里游。"),
        ],
        "complete": [
            ("水里有______。", "水里有快乐的小鱼。"),
            ("我喜欢______，因为______。", "我喜欢秋天，因为天气很凉快。"),
        ],
    },
    {
        "order": [
            (["秋天", "来了", "树叶", "黄了"], "秋天来了，树叶黄了。"),
            (["我", "有", "一个", "小书包"], "我有一个小书包。"),
        ],
        "complete": [
            ("书包里有______。", "书包里有书本和铅笔。"),
            ("放学后，我______。", "放学后，我先写作业。"),
        ],
    },
    {
        "order": [
            (["小鸡", "在", "雪地里", "画", "竹叶"], "小鸡在雪地里画竹叶。"),
            (["妈妈", "给我", "讲故事"], "妈妈给我讲故事。"),
        ],
        "complete": [
            ("冬天，______。", "冬天，雪花落下来了。"),
            ("我会自己______。", "我会自己整理书包。"),
        ],
    },
    {
        "order": [
            (["雨点儿", "从", "云彩里", "落下来"], "雨点儿从云彩里落下来。"),
            (["我", "和", "同学", "做游戏"], "我和同学做游戏。"),
        ],
        "complete": [
            ("下雨了，______。", "下雨了，我撑起小雨伞。"),
            ("我和同学一起______。", "我和同学一起读书。"),
        ],
    },
    {
        "order": [
            (["红红的", "太阳", "升起来了"], "红红的太阳升起来了。"),
            (["弟弟", "会", "自己", "穿衣服"], "弟弟会自己穿衣服。"),
        ],
        "complete": [
            ("太阳像______。", "太阳像一个大火球。"),
            ("我学会了______。", "我学会了自己穿衣服。"),
        ],
    },
    {
        "order": [
            (["江南", "有", "美丽的", "荷花"], "江南有美丽的荷花。"),
            (["小猫", "在", "窗边", "睡觉"], "小猫在窗边睡觉。"),
        ],
        "complete": [
            ("荷叶______。", "荷叶圆圆的、绿绿的。"),
            ("小猫喜欢______。", "小猫喜欢在阳光下睡觉。"),
        ],
    },
    {
        "order": [
            (["国旗", "在", "风中", "飘扬"], "国旗在风中飘扬。"),
            (["我们", "要", "爱护", "小树"], "我们要爱护小树。"),
        ],
        "complete": [
            ("升国旗时，我们______。", "升国旗时，我们立正敬礼。"),
            ("我爱______。", "我爱我们的祖国。"),
        ],
    },
    {
        "order": [
            (["春天", "小草", "绿了"], "春天，小草绿了。"),
            (["乌鸦", "想办法", "喝到了", "水"], "乌鸦想办法喝到了水。"),
        ],
        "complete": [
            ("春天来了，______。", "春天来了，花儿开放了。"),
            ("遇到困难时，我要______。", "遇到困难时，我要认真想办法。"),
        ],
    },
]

READING_PROFILES = [
    {
        "title": "小松鼠",
        "text": "秋天到了。小松鼠捡来许多松果，把它们藏在树洞里。冬天来了，它就不怕找不到食物了。",
        "questions": [
            ("短文共有几句话？", "3句话", "数一数句号，一共有3个完整句子。"),
            ("小松鼠在秋天捡什么？", "松果", "第二句话直接写了“小松鼠捡来许多松果”。"),
            ("它把松果藏在哪里？", "树洞里", "在第二句话中找到地点“树洞里”。"),
            ("小松鼠为什么冬天不怕找不到食物？", "因为它提前藏好了松果。", "联系前后两句，秋天储存食物是为冬天做准备。"),
        ],
    },
    {
        "title": "校园的早晨",
        "text": "太阳升起来了。老师站在校门口微笑，同学们背着书包走进校园。小鸟在树上唱歌，新的一天开始了。",
        "questions": [
            ("短文共有几句话？", "3句话", "三个句号表示3个完整句子。"),
            ("谁站在校门口？", "老师", "第二句话的开头写的是“老师站在校门口”。"),
            ("同学们背着什么？", "书包", "从“同学们背着书包”可以找到答案。"),
            ("校园的早晨给你什么感觉？", "示例：快乐、热闹。", "根据微笑、唱歌和新的一天等词语概括，意思合理即可。"),
        ],
    },
    {
        "title": "雨后的彩虹",
        "text": "雨停了，天空亮起来。东边出现了一道彩虹，红、橙、黄、绿、青、蓝、紫，真好看！小朋友们抬头看，开心地笑了。",
        "questions": [
            ("短文共有几句话？", "3句话", "句号和感叹号都表示一句话结束，共3句。"),
            ("彩虹出现在什么方向？", "东边", "第二句话明确写了“东边”。"),
            ("请圈出文中的两个颜色词。", "示例：红、黄（任意两个均可）", "颜色词共有红、橙、黄、绿、青、蓝、紫，任选两个。"),
            ("小朋友们看到彩虹后怎么样？", "开心地笑了。", "最后一句直接写出了小朋友们的表现。"),
        ],
    },
    {
        "title": "小河边",
        "text": "小河清清的，慢慢地向前流。两只鸭子在水里游，一条小鱼从荷叶下钻出来。河边的柳树轻轻摇着绿色的枝条。",
        "questions": [
            ("短文共有几句话？", "3句话", "数三个句号即可。"),
            ("水里有几只鸭子？", "两只", "第二句话中有数量词“两只”。"),
            ("小鱼从哪里钻出来？", "荷叶下", "从“小鱼从荷叶下钻出来”找到地点。"),
            ("短文写了哪些小动物？", "鸭子和小鱼", "找出文中表示动物的词语。"),
        ],
    },
    {
        "title": "整理书包",
        "text": "晚上，小米把第二天要用的书本放进书包。她又削好铅笔，装好水杯。妈妈夸她是个会整理的好孩子。",
        "questions": [
            ("短文共有几句话？", "3句话", "三个句号对应3句话。"),
            ("小米什么时候整理书包？", "晚上", "第一句话开头给出了时间。"),
            ("她还准备了哪两样东西？", "铅笔和水杯", "第二句话写了削铅笔、装水杯。"),
            ("妈妈为什么夸小米？", "因为她会自己整理学习用品。", "根据小米的行动概括原因。"),
        ],
    },
    {
        "title": "冬日的小麻雀",
        "text": "雪停了，屋顶白白的。几只小麻雀落在窗台上，轻轻啄着米粒。吃饱后，它们拍拍翅膀飞走了。",
        "questions": [
            ("短文共有几句话？", "3句话", "每个句号结束一句，共3句。"),
            ("屋顶是什么颜色的？", "白色", "第一句话写了“屋顶白白的”。"),
            ("小麻雀在窗台上吃什么？", "米粒", "第二句话中有“啄着米粒”。"),
            ("吃饱后，小麻雀做了什么？", "拍拍翅膀飞走了。", "答案在最后一句。"),
        ],
    },
    {
        "title": "小蚂蚁搬米",
        "text": "一只小蚂蚁发现了一粒大米。它搬不动，就回去叫来伙伴。大家一起用力，终于把大米搬回了家。",
        "questions": [
            ("短文共有几句话？", "3句话", "短文有3个句号。"),
            ("小蚂蚁发现了什么？", "一粒大米", "第一句话直接给出答案。"),
            ("它搬不动时想了什么办法？", "回去叫来伙伴一起搬", "第二句话说明了办法。"),
            ("你从小蚂蚁身上学到了什么？", "示例：遇到困难可以合作。", "结合大家一起搬米的结果回答，意思合理即可。"),
        ],
    },
    {
        "title": "月夜",
        "text": "夜晚，弯弯的月儿挂在天上。星星一闪一闪，像许多明亮的小眼睛。小院里安安静静，只有虫儿轻轻地唱歌。",
        "questions": [
            ("短文共有几句话？", "3句话", "三个句号表示3句话。"),
            ("月儿是什么样子的？", "弯弯的", "第一句话用“弯弯的”描写月儿。"),
            ("星星像什么？", "许多明亮的小眼睛", "第二句话中“像”后面的内容就是答案。"),
            ("小院里为什么不完全安静？", "因为虫儿在轻轻唱歌。", "最后一句写了唯一的声音。"),
        ],
    },
    {
        "title": "小树长大了",
        "text": "春天，我在院子里种下一棵小树。每天，我给它浇水。到了秋天，小树长高了，还长出了许多叶子。",
        "questions": [
            ("短文共有几句话？", "3句话", "短文中有3个句号。"),
            ("“我”在什么季节种树？", "春天", "第一句话开头写明了季节。"),
            ("“我”每天为小树做什么？", "浇水", "第二句话直接给出答案。"),
            ("到了秋天，小树有什么变化？", "长高了，还长出了许多叶子。", "从最后一句找出两处变化。"),
        ],
    },
    {
        "title": "互相帮助",
        "text": "美术课上，小文忘了带彩笔。小乐把自己的彩笔分给他用。下课后，小文认真地说：“谢谢你！”",
        "questions": [
            ("短文共有几句话？", "3句话", "句号和感叹号表示3句话结束。"),
            ("谁忘了带彩笔？", "小文", "第一句话说明了人物。"),
            ("小乐是怎样帮助小文的？", "把自己的彩笔分给小文用。", "第二句话写出了帮助的方法。"),
            ("得到帮助后应该怎么做？", "示例：真诚地说谢谢。", "联系最后一句回答，意思合理即可。"),
        ],
    },
]

EXPRESSION_PROFILES = [
    ("我最喜欢的季节", "用2—3句话写一写你最喜欢哪个季节，以及为什么。", "我最喜欢秋天。秋天很凉快，树叶变黄了。我还可以和爸爸妈妈去公园散步。"),
    ("我的书包", "用2—3句话介绍你的书包里有什么。", "我有一个蓝色的书包。里面有语文书、数学书和铅笔盒。我每天都会把它整理好。"),
    ("可爱的小动物", "用2—3句话写一种你喜欢的小动物。", "我喜欢小兔子。它有长长的耳朵和短短的尾巴。它吃东西的样子很可爱。"),
    ("放学以后", "用2—3句话写一写你放学后会做什么。", "放学后，我先回家洗手。休息一会儿后，我认真完成作业。做完作业我会读课外书。"),
    ("下雨天", "用2—3句话写一写下雨时你看到了什么。", "下雨了，雨点落在窗户上。路上的人们撑起了雨伞。我听见雨点沙沙地唱歌。"),
    ("我会做家务", "用2—3句话写一件你会做的家务。", "我会自己整理书桌。我把书放整齐，把铅笔装进笔盒。看到干净的书桌，我很开心。"),
    ("我的好朋友", "用2—3句话介绍你的好朋友。", "我的好朋友叫小安。我们常常一起读书、画画。遇到困难时，我们会互相帮助。"),
    ("校园一角", "用2—3句话写一写校园里你喜欢的地方。", "我喜欢学校的小花园。那里有绿绿的小树和红红的花。下课时，我会去看一看。"),
    ("快乐的周末", "用2—3句话写一写周末做过的一件开心事。", "周末，我和家人去公园。我们看了美丽的花，还一起放风筝。我觉得很快乐。"),
    ("我的新愿望", "用2—3句话写一个你的愿望。", "我希望自己每天都能认真读书。我还想学会游泳。我要一步一步努力。"),
]

SHAPE_COUNTS = [
    {"球": 2, "正方体": 1, "圆柱": 3, "长方体": 1},
    {"球": 1, "正方体": 3, "圆柱": 2, "长方体": 1},
    {"球": 4, "正方体": 1, "圆柱": 2, "长方体": 2},
    {"球": 1, "正方体": 2, "圆柱": 1, "长方体": 4},
    {"球": 2, "正方体": 4, "圆柱": 1, "长方体": 3},
    {"球": 3, "正方体": 2, "圆柱": 4, "长方体": 1},
    {"球": 2, "正方体": 1, "圆柱": 3, "长方体": 4},
    {"球": 4, "正方体": 3, "圆柱": 1, "长方体": 2},
    {"球": 1, "正方体": 4, "圆柱": 3, "长方体": 2},
    {"球": 3, "正方体": 1, "圆柱": 2, "长方体": 4},
]

OBJECTS = [
    ("苹果", "个"),
    ("铅笔", "支"),
    ("小鸟", "只"),
    ("气球", "个"),
    ("图书", "本"),
    ("小花", "朵"),
    ("糖果", "颗"),
    ("积木", "块"),
    ("树叶", "片"),
    ("贝壳", "个"),
    ("饼干", "块"),
    ("星星贴纸", "张"),
    ("玩具车", "辆"),
    ("橘子", "个"),
    ("小红旗", "面"),
    ("水杯", "个"),
    ("小鱼", "条"),
    ("鸭子", "只"),
    ("风筝", "只"),
    ("卡片", "张"),
    ("玻璃球", "颗"),
    ("贴画", "张"),
    ("蜡笔", "支"),
    ("西红柿", "个"),
    ("梨", "个"),
    ("蘑菇", "个"),
    ("纽扣", "颗"),
    ("玩具熊", "个"),
    ("纸船", "只"),
    ("灯笼", "个"),
    ("松果", "颗"),
    ("香蕉", "根"),
    ("橡皮", "块"),
    ("练习本", "本"),
    ("红花", "朵"),
    ("白兔", "只"),
    ("彩旗", "面"),
    ("彩球", "个"),
    ("竹叶", "片"),
    ("雨点", "滴"),
]

ACTORS = ["小明", "小红", "小安", "小乐", "小米", "小文", "东东", "南南", "月月", "星星"]

THINKING_PROFILES = [
    ("把5个苹果分在两个盘子里，一个盘子有2个，另一个盘子有几个？", "5－2＝3（个），另一个盘子有3个。", "总数减去一个盘子里的数量，就是另一个盘子的数量。"),
    ("小乐有4支红铅笔和同样多的蓝铅笔。他一共有几支铅笔？", "4＋4＝8（支），一共有8支。", "“同样多”表示蓝铅笔也是4支，所以把两个4相加。"),
    ("□＋4＝10，□＋2等于多少？", "□＝6，6＋2＝8。", "先用10－4求出方框里的数是6，再计算6＋2。"),
    ("一盒球拿走3个后还剩7个，盒里原来有几个球？", "7＋3＝10（个），原来有10个。", "原来的数量由“剩下的”和“拿走的”两部分组成，要用加法。"),
    ("9块积木分给两个小组，第一组有4块，第二组有几块？", "9－4＝5（块），第二组有5块。", "从总数9里去掉第一组的4块。"),
    ("小雨第一次跳了6下，第二次比第一次多跳2下。第二次跳了几下？", "6＋2＝8（下），第二次跳了8下。", "“多2下”是在6的基础上再加2。"),
    ("两盒彩笔，每盒有5支，一共有几支？", "5＋5＝10（支），一共有10支。", "两盒的数量相同，把两个5合起来。"),
    ("树上原来有几只鸟不知道，飞来3只后共有11只。原来有几只？", "11－3＝8（只），原来有8只。", "从现在的总数中去掉后来飞来的3只。"),
    ("小文有8张卡片，送出2张，又得到5张，现在有几张？", "8－2＋5＝11（张），现在有11张。", "按事情发生的顺序先减2，再加5。"),
    ("篮子里有7个红果子和6个黄果子，吃了3个红果子。还剩几个果子？", "7＋6－3＝10（个），还剩10个。", "先求原来共有13个，再减去吃掉的3个。"),
]

THINKING_STEPS = [
    ["画出5个圆点表示全部苹果。", "圈出已知的2个苹果。", "数一数没有被圈住的圆点，得到3。"],
    ["“同样多”表示蓝铅笔也是4支。", "把红铅笔和蓝铅笔两部分合起来。", "列式4＋4＝8。"],
    ["先看□＋4＝10，用10－4求出□＝6。", "把6放进第二个算式。", "计算6＋2＝8。"],
    ["把原来的总数看成“拿走的3个”和“剩下的7个”。", "求原来一共有多少，要把两部分合起来。", "列式3＋7＝10。"],
    ["9块是总数，4块是第一组。", "总数减去第一组，就是第二组。", "列式9－4＝5。"],
    ["第一次是6下，第二次“多2下”。", "“多”表示在6的基础上再加2。", "列式6＋2＝8。"],
    ["第一盒5支，第二盒也是5支。", "两盒合起来用加法。", "列式5＋5＝10。"],
    ["现在的11只由“原来的”和“飞来的3只”组成。", "从现在的总数中去掉后来飞来的。", "列式11－3＝8。"],
    ["先从8张里送出2张：8－2＝6。", "再把得到的5张加上：6＋5＝11。", "按事情发生的先后顺序计算。"],
    ["先求红果子和黄果子的总数：7＋6＝13。", "再减去吃掉的3个：13－3＝10。", "两步计算要按题意依次完成。"],
]


def esc(value: Any) -> str:
    return html.escape(str(value), quote=True)


def relation(left: int, right: int) -> str:
    if left < right:
        return "＜"
    if left > right:
        return "＞"
    return "＝"


def make_chinese(index: int) -> dict[str, Any]:
    pinyin_items = []
    for offset, (character, correct, wrong) in enumerate(PINYIN_BANK[index * 4 : index * 4 + 4]):
        options = [correct, wrong]
        if (index + offset) % 2:
            options.reverse()
        answer_letter = "A" if options[0] == correct else "B"
        pinyin_items.append(
            {
                "character": character,
                "options": options,
                "answer": f"{answer_letter}. {correct}",
            }
        )

    return {
        "pinyin": pinyin_items,
        "writing": [
            {"pinyin": pinyin, "answer": answer}
            for pinyin, answer in WRITING_BANK[index * 4 : index * 4 + 4]
        ],
        "stroke": {"character": STROKE_BANK[index][0], "answer": STROKE_BANK[index][1]},
        "radical": {"character": RADICAL_BANK[index][0], "answer": RADICAL_BANK[index][1]},
        "antonyms": [
            {"word": word, "answer": answer}
            for word, answer in ANTONYM_BANK[index * 2 : index * 2 + 2]
        ],
        "quantifiers": [
            {"noun": noun, "answer": answer}
            for noun, answer in QUANTIFIER_BANK[index * 2 : index * 2 + 2]
        ],
        "sentences": SENTENCE_PROFILES[index],
        "reading": READING_PROFILES[index],
        "expression": {
            "title": EXPRESSION_PROFILES[index][0],
            "prompt": EXPRESSION_PROFILES[index][1],
            "sample": EXPRESSION_PROFILES[index][2],
        },
    }


def make_calculations(index: int) -> list[dict[str, Any]]:
    s = index
    carry_pairs = [
        (left, right)
        for left in range(2, 10)
        for right in range(2, 10)
        if 10 <= left + right <= 18
    ]
    selected_pairs = carry_pairs[s * 4 : s * 4 + 4]
    simple_base, simple_addend = (11, s) if s < 9 else (12, 1)
    entries = [
        (f"{1 + s % 5}＋{2 + (s * 2) % 4}", (1 + s % 5) + (2 + (s * 2) % 4)),
        (f"{20 - s}－{1 + s % 5}", (20 - s) - (1 + s % 5)),
        (f"10－{s % 10}", 10 - s % 10),
        (f"{1 + s}＋0", 1 + s),
        (f"{simple_base}＋{simple_addend}", simple_base + simple_addend),
        (f"10＋{s + 1}", 10 + s + 1),
        (f"{selected_pairs[0][0]}＋{selected_pairs[0][1]}", sum(selected_pairs[0])),
        (f"{selected_pairs[1][0]}＋{selected_pairs[1][1]}", sum(selected_pairs[1])),
        (f"{selected_pairs[2][0]}＋{selected_pairs[2][1]}", sum(selected_pairs[2])),
        (f"{selected_pairs[3][0]}＋{selected_pairs[3][1]}", sum(selected_pairs[3])),
        (
            f"{3 + s % 4}＋{2 + s % 3}－{1 + s % 2}",
            (3 + s % 4) + (2 + s % 3) - (1 + s % 2),
        ),
        (
            f"10－{1 + s % 4}＋{2 + s % 5}",
            10 - (1 + s % 4) + (2 + s % 5),
        ),
    ]
    return [{"text": text, "answer": answer} for text, answer in entries]


def make_math(index: int) -> dict[str, Any]:
    blank_patterns = [
        (1, 3),
        (0, 2),
        (2, 4),
        (1, 4),
        (0, 3),
        (2, 3),
        (0, 4),
        (1, 2),
        (3, 4),
        (0, 1),
    ]
    first_values = list(range(index, index + 5))
    second_values = list(range(20 - index, 15 - index, -1))
    first_blanks = blank_patterns[index]
    second_blanks = blank_patterns[(index + 4) % 10]

    small_target = 5 + index % 6
    small_known = 1 + index % 3
    second_target = 8 + index % 3
    second_known = 2 + index % 4
    large_total = 12 + index % 7
    large_result = 5 + index % 5
    unknown_total = 11 + index % 8
    subtractor = 1 + index % 5

    compositions = [
        {
            "text": f"{small_known}＋□＝{small_target}",
            "answer": small_target - small_known,
            "reason": f"{small_target}－{small_known}＝{small_target - small_known}",
        },
        {
            "text": f"□＋{second_known}＝{second_target}",
            "answer": second_target - second_known,
            "reason": f"{second_target}－{second_known}＝{second_target - second_known}",
        },
        {
            "text": f"{large_total}－□＝{large_result}",
            "answer": large_total - large_result,
            "reason": f"{large_total}－{large_result}＝{large_total - large_result}",
        },
        {
            "text": f"□－{subtractor}＝{unknown_total - subtractor}",
            "answer": unknown_total,
            "reason": f"{unknown_total - subtractor}＋{subtractor}＝{unknown_total}",
        },
    ]

    comparison_pairs = [
        (str(3 + index), 3 + index, str(4 + index), 4 + index),
        (str(10 - index % 4), 10 - index % 4, str(7 + index % 4), 7 + index % 4),
        (
            f"{2 + index % 3}＋{3 + index % 4}",
            (2 + index % 3) + (3 + index % 4),
            str(7 + index % 3),
            7 + index % 3,
        ),
        (
            str(12 + index % 5),
            12 + index % 5,
            f"{15 + index % 4}－{2 + index % 3}",
            (15 + index % 4) - (2 + index % 3),
        ),
        (
            f"9＋{2 + index % 6}",
            9 + (2 + index % 6),
            f"8＋{3 + index % 6}",
            8 + (3 + index % 6),
        ),
        (
            f"{18 - index % 4}－{4 + index % 3}",
            (18 - index % 4) - (4 + index % 3),
            f"{10 + index % 5}－{1 + index % 3}",
            (10 + index % 5) - (1 + index % 3),
        ),
    ]
    comparisons = [
        {
            "left": left,
            "right": right,
            "left_value": left_value,
            "right_value": right_value,
            "answer": relation(left_value, right_value),
        }
        for left, left_value, right, right_value in comparison_pairs
    ]

    final_a = 12 + index % 7
    missing_entries = [
        (f"□＋{2 + index % 5}＝{8 + index}", (8 + index) - (2 + index % 5)),
        (f"{3 + index % 5}＋□＝{10 + index % 6}", (10 + index % 6) - (3 + index % 5)),
        (f"{15 + index % 5}－□＝{8 + index % 4}", (15 + index % 5) - (8 + index % 4)),
        (f"□－{2 + index % 4}＝{7 + index % 5}", (7 + index % 5) + (2 + index % 4)),
        (f"9＋□＝{12 + index % 7}", (12 + index % 7) - 9),
        (f"□＋{1 + index % 6}＝{final_a}", final_a - (1 + index % 6)),
    ]
    missing = [{"text": text, "answer": answer} for text, answer in missing_entries]

    shape_counts = SHAPE_COUNTS[index]
    shape_names: list[str] = []
    for shape_name, count in shape_counts.items():
        shape_names.extend([shape_name] * count)
    rotation = index % len(shape_names)
    shape_names = shape_names[rotation:] + shape_names[:rotation]
    shape_max = max(shape_counts, key=shape_counts.get)

    objects = OBJECTS[index * 4 : index * 4 + 4]
    actor = ACTORS[index]
    first = 3 + index % 6
    added = 2 + (index * 2) % 5
    total = first + added
    second_total = 11 + index % 8
    removed = 2 + index % 5
    remaining = second_total - removed
    came = 2 + index % 4
    now = 9 + index % 7
    original = now - came
    before = 5 + index % 6
    after = 13 + index % 7
    made = after - before
    calculations = make_calculations(index)
    carry_item = next(
        item
        for item in calculations
        if (match := re.fullmatch(r"(\d+)＋(\d+)", item["text"]))
        and int(match.group(1)) < 10
        and int(match.group(2)) < 10
        and item["answer"] > 10
    )
    carry_match = re.fullmatch(r"(\d+)＋(\d+)", carry_item["text"])
    if carry_match is None:
        raise ValueError("未找到凑十法示例。")
    carry_left = max(int(carry_match.group(1)), int(carry_match.group(2)))
    carry_right = min(int(carry_match.group(1)), int(carry_match.group(2)))
    carry_need = 10 - carry_left

    application_problems = [
        {
            "text": f"{actor}有{first}{objects[0][1]}{objects[0][0]}，又得到{added}{objects[0][1]}。现在有多少{objects[0][1]}？",
            "equation": f"{first}＋{added}＝{total}（{objects[0][1]}）",
            "answer": total,
            "unit": objects[0][1],
            "reason": "求合起来的总数，用加法。",
            "model": {"total": total, "parts": [first, added], "labels": ["原有", "又得到"]},
        },
        {
            "text": f"一组图卡上有{second_total}{objects[1][1]}{objects[1][0]}，拿走{removed}{objects[1][1]}。还剩多少{objects[1][1]}？",
            "equation": f"{second_total}－{removed}＝{remaining}（{objects[1][1]}）",
            "answer": remaining,
            "unit": objects[1][1],
            "reason": "从原有数量中去掉一部分，用减法。",
            "model": {"total": second_total, "parts": [remaining, removed], "labels": ["剩下", "拿走"]},
        },
        {
            "text": f"画纸上原来画了一些{objects[2][0]}，又画上{came}{objects[2][1]}，现在共有{now}{objects[2][1]}。原来画了多少{objects[2][1]}？",
            "equation": f"{now}－{came}＝{original}（{objects[2][1]}）",
            "answer": original,
            "unit": objects[2][1],
            "reason": "现在的总数减去后来增加的数量，就是原来的数量。",
            "model": {"total": now, "parts": [original, came], "labels": ["原来", "又画"]},
        },
        {
            "text": f"{actor}的作品中原来画了{before}{objects[3][1]}{objects[3][0]}，又画了一些后共有{after}{objects[3][1]}。又画了多少{objects[3][1]}？",
            "equation": f"{after}－{before}＝{made}（{objects[3][1]}）",
            "answer": made,
            "unit": objects[3][1],
            "reason": "最后的总数减去原有数量，就是增加的数量。",
            "model": {"total": after, "parts": [before, made], "labels": ["原有", "又画"]},
        },
    ]

    return {
        "sequences": [
            {"values": first_values, "blank_indices": first_blanks},
            {"values": second_values, "blank_indices": second_blanks},
        ],
        "compositions": compositions,
        "comparisons": comparisons,
        "calculations": calculations,
        "method_examples": {
            "part_whole": {
                "total": small_target,
                "known": small_known,
                "missing": small_target - small_known,
            },
            "make_ten": {
                "left": carry_left,
                "right": carry_right,
                "need": carry_need,
                "rest": carry_right - carry_need,
                "total": carry_item["answer"],
            },
        },
        "missing": missing,
        "shapes": {
            "sequence": shape_names,
            "counts": shape_counts,
            "most": shape_max,
        },
        "applications": application_problems,
        "thinking": {
            "question": THINKING_PROFILES[index][0],
            "answer": THINKING_PROFILES[index][1],
            "reason": THINKING_PROFILES[index][2],
            "steps": THINKING_STEPS[index],
        },
    }


def build_paper_sets() -> list[dict[str, Any]]:
    levels = ["基础巩固"] * 3 + ["标准综合"] * 4 + ["综合提升"] * 3
    return [
        {
            "number": index + 1,
            "level": levels[index],
            "chinese": make_chinese(index),
            "math": make_math(index),
        }
        for index in range(10)
    ]


def validate_blueprints(paper_sets: list[dict[str, Any]]) -> None:
    if len(paper_sets) != 10:
        raise ValueError("必须生成10套试卷。")

    writing_answers: list[str] = []
    calculation_questions: list[str] = []
    reading_titles: set[str] = set()
    expression_titles: set[str] = set()
    for expected_number, paper_set in enumerate(paper_sets, start=1):
        if paper_set["number"] != expected_number:
            raise ValueError("试卷编号不连续。")
        chinese = paper_set["chinese"]
        math_data = paper_set["math"]
        if len(chinese["pinyin"]) != 4 or len(chinese["writing"]) != 4:
            raise ValueError(f"第{expected_number}套语文基础题数量不正确。")
        writing_answers.extend(item["answer"] for item in chinese["writing"])
        reading_titles.add(chinese["reading"]["title"])
        expression_titles.add(chinese["expression"]["title"])
        for item in chinese["pinyin"]:
            if item["answer"][3:] not in item["options"]:
                raise ValueError(f"第{expected_number}套拼音答案不在选项中。")

        if len(math_data["calculations"]) != 12 or len(math_data["comparisons"]) != 6:
            raise ValueError(f"第{expected_number}套数学题数量不正确。")
        for item in math_data["calculations"]:
            if not 0 <= item["answer"] <= 20:
                raise ValueError(f"第{expected_number}套存在超范围计算：{item}")
            calculation_questions.append(item["text"])
        for item in math_data["comparisons"]:
            expected = relation(item["left_value"], item["right_value"])
            if item["answer"] != expected:
                raise ValueError(f"第{expected_number}套比较题答案错误：{item}")
        for item in math_data["missing"]:
            if not 0 <= item["answer"] <= 20:
                raise ValueError(f"第{expected_number}套填数题答案超范围：{item}")
        maximum = max(math_data["shapes"]["counts"].values())
        if list(math_data["shapes"]["counts"].values()).count(maximum) != 1:
            raise ValueError(f"第{expected_number}套立体图形最多项不唯一。")

    if len(set(writing_answers)) != 40:
        raise ValueError("10套看拼音写词语存在重复。")
    if len(set(calculation_questions)) != 120:
        raise ValueError("10套直接写得数题存在重复。")
    if len(reading_titles) != 10 or len(expression_titles) != 10:
        raise ValueError("阅读或表达主题存在重复。")


PRINT_CSS = """
@page { size: A4; margin: 0; }
* { box-sizing: border-box; }
html, body {
  margin: 0;
  padding: 0;
  color: #111;
  background: #fff;
  font-family: "Microsoft YaHei", "SimSun", "Noto Sans CJK SC", sans-serif;
}
.page {
  position: relative;
  width: 210mm;
  height: 297mm;
  padding: 10mm 13mm 11mm;
  overflow: hidden;
  page-break-after: always;
  break-after: page;
  font-size: 12.6pt;
  line-height: 1.48;
}
.page:last-child { page-break-after: auto; break-after: auto; }
.paper-title {
  margin: 0;
  text-align: center;
  font-size: 21pt;
  letter-spacing: .08em;
}
.paper-subtitle {
  margin: 1.5mm 0 2.5mm;
  text-align: center;
  font-size: 10.5pt;
  color: #444;
}
.student-fields {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 6mm;
  margin-top: 4mm;
  padding: 2mm 0 2.5mm;
  border-bottom: 1.2pt solid #222;
  font-size: 11.5pt;
}
.field-line {
  display: inline-block;
  min-width: 29mm;
  height: 5mm;
  border-bottom: 1pt solid #555;
  vertical-align: bottom;
}
.score-strip {
  display: flex;
  justify-content: space-between;
  margin: 2mm 0 1.5mm;
  padding: 1.2mm 2.5mm;
  border: 1pt solid #777;
  background: #f2f2f2;
  font-size: 10pt;
}
.section { margin-top: 2.2mm; }
.section h2 {
  margin: 0 0 1.2mm;
  padding: 1.1mm 2mm;
  border-left: 4pt solid #222;
  background: #ededed;
  font-size: 14.5pt;
  line-height: 1.3;
}
.instruction {
  margin: 0 0 1.3mm;
  color: #333;
  font-size: 10.8pt;
}
.two-col {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.2mm 7mm;
}
.three-col {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.5mm 5mm;
}
.four-col {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1.7mm 4mm;
}
.question {
  min-height: 7mm;
  padding: .7mm 0;
}
.option { margin-right: 4mm; white-space: nowrap; }
.writing-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 3mm;
}
.writing-cell {
  text-align: center;
  padding: 1.5mm 1mm 2.5mm;
  border: 1pt solid #999;
  min-height: 18mm;
}
.pinyin {
  display: block;
  margin-bottom: 2.5mm;
  font-size: 11pt;
  letter-spacing: .06em;
}
.blank {
  display: inline-block;
  min-width: 14mm;
  height: 5.5mm;
  border-bottom: 1pt solid #222;
  vertical-align: bottom;
}
.blank.small { min-width: 8mm; }
.blank.long { min-width: 58mm; }
.word-task-box {
  padding: 1.5mm 2mm;
  border: 1pt dashed #888;
  min-height: 18mm;
}
.word-chips span {
  display: inline-block;
  margin: 0 1.5mm 1mm 0;
  padding: .5mm 2mm;
  border: 1pt solid #777;
  border-radius: 2mm;
  background: #fafafa;
}
.sentence-item {
  margin-bottom: 2.3mm;
  padding-bottom: 1.5mm;
  border-bottom: 1pt dashed #bbb;
}
.response-rule {
  height: 7mm;
  border-bottom: 1pt solid #777;
}
.reading-box {
  margin: 1.3mm 0 1.8mm;
  padding: 2.4mm 3mm;
  border: 1.2pt solid #555;
  background: #fafafa;
  text-indent: 2em;
  line-height: 1.65;
}
.reading-q {
  margin: 1.2mm 0;
  font-size: 11.7pt;
}
.expression-lines .response-rule { height: 8.5mm; }
.sequence {
  display: flex;
  align-items: center;
  gap: 1.2mm;
  margin: 1.3mm 0;
  padding: 1.5mm 2mm;
  border: 1pt dashed #888;
  font-size: 15pt;
  font-weight: 700;
}
.number-box {
  display: inline-flex;
  width: 9mm;
  height: 9mm;
  align-items: center;
  justify-content: center;
  border-bottom: 1.2pt solid #222;
}
.math-grid .question {
  font-size: 13.5pt;
  font-weight: 600;
}
.math-answer-box {
  display: inline-block;
  width: 9mm;
  height: 9mm;
  margin: 0 1mm;
  border: 1.4pt solid #222;
  background: #fff;
  vertical-align: middle;
}
.shape-row {
  display: flex;
  flex-wrap: wrap;
  align-items: end;
  justify-content: center;
  gap: 2mm;
  padding: 2mm;
  border: 1pt dashed #888;
}
.shape-icon { width: 14mm; height: 12mm; }
.shape-answer {
  margin-top: 2mm;
  text-align: center;
  font-size: 11.5pt;
}
.application {
  margin: 1.4mm 0;
  padding: 1.3mm 2mm 2mm;
  border-bottom: 1pt dashed #aaa;
}
.application p { margin: 0; }
.equation-line {
  margin-top: 1mm;
  padding-left: 7mm;
}
.thinking-box {
  padding: 2mm 2.5mm;
  border: 1.4pt solid #333;
  background: #fafafa;
}
.page-footer {
  position: absolute;
  left: 13mm;
  right: 13mm;
  bottom: 5mm;
  display: flex;
  justify-content: space-between;
  padding-top: 1mm;
  border-top: .7pt solid #999;
  color: #555;
  font-size: 8.8pt;
}
.answer-document {
  padding: 0;
  font-size: 11.5pt;
  line-height: 1.55;
}
.answer-cover {
  width: 210mm;
  min-height: 297mm;
  padding: 32mm 24mm;
  page-break-after: always;
  break-after: page;
}
.answer-cover h1 {
  margin-top: 45mm;
  text-align: center;
  font-size: 28pt;
}
.answer-cover h2 {
  text-align: center;
  font-size: 17pt;
  font-weight: 500;
}
.answer-note {
  margin-top: 25mm;
  padding: 6mm;
  border: 1.2pt solid #444;
  background: #f5f5f5;
}
.answer-set {
  padding: 12mm 15mm 14mm;
  page-break-before: always;
  break-before: page;
}
.answer-set h1 {
  margin: 0 0 3mm;
  padding-bottom: 2mm;
  border-bottom: 2pt solid #222;
  font-size: 22pt;
}
.answer-set h2 {
  margin: 4mm 0 2mm;
  padding: 1.3mm 2mm;
  background: #e9e9e9;
  border-left: 4pt solid #222;
  font-size: 16pt;
  break-after: avoid;
}
.answer-set h3 {
  margin: 3mm 0 1mm;
  font-size: 13pt;
  break-after: avoid;
}
.answer-list {
  margin: 1mm 0 2mm;
  padding-left: 6mm;
}
.answer-list li { margin: 1.1mm 0; }
.reason {
  color: #444;
  font-size: 10.5pt;
}
.answer-callout {
  padding: 2mm 3mm;
  border: 1pt dashed #777;
  background: #fafafa;
  break-inside: avoid;
}
.method-card {
  margin: 2mm 0 3mm;
  padding: 3mm;
  border: 1.2pt solid #555;
  border-radius: 2mm;
  background: #f7f7f7;
  break-inside: avoid;
}
.method-title {
  margin-bottom: 2mm;
  font-size: 12.5pt;
  font-weight: 800;
}
.step-flow {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 2mm;
  flex-wrap: wrap;
}
.flow-step {
  min-width: 27mm;
  padding: 1.5mm 2mm;
  border: 1pt solid #666;
  background: #fff;
  text-align: center;
  font-weight: 700;
}
.flow-arrow { font-size: 16pt; font-weight: 800; }
.part-whole {
  width: 72mm;
  margin: 1mm auto;
  text-align: center;
}
.part-total,
.part-node {
  display: inline-flex;
  width: 17mm;
  height: 13mm;
  align-items: center;
  justify-content: center;
  border: 1.5pt solid #222;
  border-radius: 50%;
  background: #fff;
  font-size: 14pt;
  font-weight: 800;
}
.part-lines {
  position: relative;
  width: 50mm;
  height: 11mm;
  margin: 0 auto;
  border-left: 1.2pt solid #444;
  border-right: 1.2pt solid #444;
  border-top: 1.2pt solid #444;
}
.part-nodes {
  display: flex;
  justify-content: space-between;
}
.ten-method {
  display: grid;
  grid-template-columns: 70mm 1fr;
  gap: 5mm;
  align-items: center;
}
.ten-frame {
  display: grid;
  grid-template-columns: repeat(5, 11mm);
  grid-template-rows: repeat(2, 11mm);
  width: 55mm;
  border-left: 1.2pt solid #333;
  border-top: 1.2pt solid #333;
  background: #fff;
}
.ten-cell {
  display: flex;
  align-items: center;
  justify-content: center;
  border-right: 1.2pt solid #333;
  border-bottom: 1.2pt solid #333;
}
.ten-dot {
  width: 6mm;
  height: 6mm;
  border: 1.2pt solid #111;
  border-radius: 50%;
}
.ten-dot.original { background: #222; }
.ten-dot.moved { background: #aaa; }
.dot-legend {
  margin-top: 1mm;
  font-size: 9.5pt;
}
.legend-dot {
  display: inline-block;
  width: 3.5mm;
  height: 3.5mm;
  margin: 0 1mm 0 2mm;
  border: 1pt solid #111;
  border-radius: 50%;
  vertical-align: middle;
}
.legend-dot.original { background: #222; }
.legend-dot.moved { background: #aaa; }
.rest-dots {
  display: inline-flex;
  gap: 1mm;
  margin-left: 2mm;
  vertical-align: middle;
}
.rest-dot {
  display: inline-block;
  width: 5mm;
  height: 5mm;
  border: 1.2pt solid #222;
  border-radius: 50%;
  background: #fff;
}
.method-steps {
  margin: 0;
  padding-left: 6mm;
}
.method-steps li { margin: 1mm 0; }
.compare-model { margin-top: 1.5mm; }
.compare-row {
  display: grid;
  grid-template-columns: 28mm 1fr 12mm;
  align-items: center;
  gap: 2mm;
  margin: 1mm 0;
}
.compare-track {
  height: 7mm;
  border: 1pt solid #555;
  background: #fff;
}
.compare-fill {
  height: 100%;
  background: #777;
}
.bar-model {
  margin: 2mm 0 1mm;
  break-inside: avoid;
}
.bar-total {
  margin-bottom: 1mm;
  text-align: center;
  font-size: 10pt;
  font-weight: 700;
}
.bar-parts {
  display: flex;
  min-height: 10mm;
  border: 1.2pt solid #333;
}
.bar-part {
  display: flex;
  min-width: 18mm;
  align-items: center;
  justify-content: center;
  padding: 1mm;
  border-right: 1.2pt solid #333;
  background: #fff;
  font-size: 9.5pt;
  text-align: center;
}
.bar-part:last-child {
  border-right: 0;
  background: #ddd;
}
.thinking-steps {
  margin: 2mm 0 0;
  padding-left: 7mm;
}
.thinking-steps li { margin: 1mm 0; }
.compact { margin: .7mm 0; }
"""


def paper_header(paper_set: dict[str, Any], subject: str) -> str:
    number = paper_set["number"]
    return f"""
      <h1 class="paper-title">一年级上册{esc(subject)}练习卷（第{number:02d}套）</h1>
      <div class="student-fields">
        <div>班级：<span class="field-line"></span></div>
        <div>姓名：<span class="field-line"></span></div>
        <div>日期：<span class="field-line"></span></div>
      </div>
    """


def page_footer(paper_set: dict[str, Any], subject: str, page_number: int, total: int = 2) -> str:
    return f"""
      <div class="page-footer">
        <span>家庭巩固练习 · 请保持轻松、认真书写</span>
        <span>第{paper_set["number"]:02d}套 {esc(subject)} {page_number}/{total}</span>
      </div>
    """


def render_chinese_page_one(paper_set: dict[str, Any]) -> str:
    chinese = paper_set["chinese"]
    pinyin_html = "".join(
        f"""
        <div class="question">{idx}. {esc(item["character"])}
          <span class="option">A. {esc(item["options"][0])}</span>
          <span class="option">B. {esc(item["options"][1])}</span>
        </div>
        """
        for idx, item in enumerate(chinese["pinyin"], start=1)
    )
    writing_html = "".join(
        f"""
        <div class="writing-cell">
          <span class="pinyin">{esc(item["pinyin"])}</span>
          <span class="blank"></span>
        </div>
        """
        for item in chinese["writing"]
    )
    antonym_html = "　".join(
        f'{esc(item["word"])}—（　　）' for item in chinese["antonyms"]
    )
    quantifier_html = "　".join(
        f'一（　　）{esc(item["noun"])}' for item in chinese["quantifiers"]
    )
    return f"""
    <section class="page">
      {paper_header(paper_set, "语文")}
      <div class="score-strip"><span>满分：100分</span><span>建议分两次轻松完成</span><span>得分：________</span></div>

      <div class="section">
        <h2>一、拼音小站（12分）</h2>
        <p class="instruction">读一读，为下面的字选择正确的拼音，把序号圈起来。（每题3分）</p>
        <div class="two-col">{pinyin_html}</div>
      </div>

      <div class="section">
        <h2>二、看拼音写词语（16分）</h2>
        <p class="instruction">拼读音节，把词语工整地写在横线上。（每词4分）</p>
        <div class="writing-grid">{writing_html}</div>
      </div>

      <div class="section">
        <h2>三、字词乐园（24分）</h2>
        <div class="two-col">
          <div class="word-task-box">
            <strong>1. 数笔画、认偏旁（8分）</strong><br>
            “{esc(chinese["stroke"]["character"])}”共（　）画。<br>
            “{esc(chinese["radical"]["character"])}”的偏旁是（　　　　）。
          </div>
          <div class="word-task-box">
            <strong>2. 写反义词（8分）</strong><br>
            <div style="margin-top:2mm">{antonym_html}</div>
          </div>
        </div>
        <div class="word-task-box" style="margin-top:2mm">
          <strong>3. 选择合适的量词填空（8分）</strong>
          <span style="margin-left:5mm">{quantifier_html}</span>
        </div>
      </div>
      {page_footer(paper_set, "语文", 1)}
    </section>
    """


def render_chinese_page_two(paper_set: dict[str, Any]) -> str:
    chinese = paper_set["chinese"]
    order_html = "".join(
        f"""
        <div class="sentence-item">
          {idx}. <span class="word-chips">{"".join(f"<span>{esc(word)}</span>" for word in words)}</span>
          <div class="response-rule"></div>
        </div>
        """
        for idx, (words, _) in enumerate(chinese["sentences"]["order"], start=1)
    )
    complete_html = "".join(
        f"""
        <div class="sentence-item">{idx}. {esc(prompt).replace("______", '<span class="blank long"></span>')}</div>
        """
        for idx, (prompt, _) in enumerate(chinese["sentences"]["complete"], start=3)
    )
    reading_questions = "".join(
        f'<div class="reading-q">{idx}. {esc(question)} <span class="blank long"></span></div>'
        for idx, (question, _, _) in enumerate(chinese["reading"]["questions"], start=1)
    )
    return f"""
    <section class="page">
      {paper_header(paper_set, "语文")}
      <div class="section">
        <h2>四、句子训练营（20分）</h2>
        <p class="instruction">1—2题把词语排成通顺的句子；3—4题把句子补充完整。（每题5分）</p>
        {order_html}
        {complete_html}
      </div>

      <div class="section">
        <h2>五、快乐阅读（20分）</h2>
        <div style="text-align:center;font-weight:700">{esc(chinese["reading"]["title"])}</div>
        <div class="reading-box">{esc(chinese["reading"]["text"])}</div>
        {reading_questions}
      </div>

      <div class="section">
        <h2>六、我会表达（8分）</h2>
        <p class="instruction"><strong>{esc(chinese["expression"]["title"])}：</strong>{esc(chinese["expression"]["prompt"])}</p>
        <div class="expression-lines">
          <div class="response-rule"></div>
          <div class="response-rule"></div>
          <div class="response-rule"></div>
        </div>
      </div>
      {page_footer(paper_set, "语文", 2)}
    </section>
    """


def sequence_html(sequence: dict[str, Any]) -> str:
    blank_indices = set(sequence["blank_indices"])
    cells = []
    for index, value in enumerate(sequence["values"]):
        content = "" if index in blank_indices else str(value)
        cells.append(f'<span class="number-box">{content}</span>')
    return '<div class="sequence">' + "<span>→</span>".join(cells) + "</div>"


def math_markup(text: str) -> str:
    return esc(text).replace(
        "□",
        '<span class="math-answer-box" aria-label="答题框"></span>',
    )


def shape_svg(shape_name: str) -> str:
    if shape_name == "球":
        content = """
          <circle cx="24" cy="20" r="15" fill="white" stroke="black" stroke-width="2"/>
          <path d="M14 11 Q24 6 33 13" fill="none" stroke="#777" stroke-width="1.5"/>
        """
    elif shape_name == "正方体":
        content = """
          <polygon points="10,12 29,7 39,14 20,20" fill="white" stroke="black" stroke-width="2"/>
          <polygon points="10,12 20,20 20,36 10,28" fill="#eee" stroke="black" stroke-width="2"/>
          <polygon points="20,20 39,14 39,30 20,36" fill="white" stroke="black" stroke-width="2"/>
        """
    elif shape_name == "圆柱":
        content = """
          <ellipse cx="24" cy="10" rx="14" ry="6" fill="white" stroke="black" stroke-width="2"/>
          <path d="M10 10 V31 M38 10 V31" stroke="black" stroke-width="2"/>
          <ellipse cx="24" cy="31" rx="14" ry="6" fill="white" stroke="black" stroke-width="2"/>
        """
    else:
        content = """
          <polygon points="7,14 31,9 41,15 17,21" fill="white" stroke="black" stroke-width="2"/>
          <polygon points="7,14 17,21 17,34 7,28" fill="#eee" stroke="black" stroke-width="2"/>
          <polygon points="17,21 41,15 41,28 17,34" fill="white" stroke="black" stroke-width="2"/>
        """
    return f'<svg class="shape-icon" viewBox="0 0 48 42" role="img" aria-label="{esc(shape_name)}">{content}</svg>'


def render_math_page_one(paper_set: dict[str, Any]) -> str:
    math_data = paper_set["math"]
    composition_html = "".join(
        f'<div class="question">{math_markup(item["text"])}</div>'
        for item in math_data["compositions"]
    )
    comparison_html = "".join(
        f'<div class="question">{esc(item["left"])}<span class="math-answer-box" aria-label="答题框"></span>{esc(item["right"])}</div>'
        for item in math_data["comparisons"]
    )
    calculation_html = "".join(
        f'<div class="question">{esc(item["text"])}＝</div>'
        for item in math_data["calculations"]
    )
    missing_html = "".join(
        f'<div class="question">{math_markup(item["text"])}</div>'
        for item in math_data["missing"]
    )
    return f"""
    <section class="page">
      {paper_header(paper_set, "数学")}
      <div class="score-strip"><span>满分：100分</span><span>认真读题 · 写清算式</span><span>得分：________</span></div>

      <div class="section">
        <h2>一、数的认识与组成（16分）</h2>
        <div class="two-col">
          <div>{sequence_html(math_data["sequences"][0])}</div>
          <div>{sequence_html(math_data["sequences"][1])}</div>
        </div>
        <div class="four-col math-grid">{composition_html}</div>
      </div>

      <div class="section">
        <h2>二、在□里填“＞”“＜”或“＝”（12分）</h2>
        <div class="three-col math-grid">{comparison_html}</div>
      </div>

      <div class="section">
        <h2>三、直接写得数（24分）</h2>
        <div class="four-col math-grid">{calculation_html}</div>
      </div>

      <div class="section">
        <h2>四、在□里填合适的数（12分）</h2>
        <div class="three-col math-grid">{missing_html}</div>
      </div>
      {page_footer(paper_set, "数学", 1)}
    </section>
    """


def render_math_page_two(paper_set: dict[str, Any]) -> str:
    math_data = paper_set["math"]
    shapes_html = "".join(shape_svg(name) for name in math_data["shapes"]["sequence"])
    applications_html = "".join(
        f"""
        <div class="application">
          <p>{idx}. {esc(problem["text"])}</p>
          <div class="equation-line">列式：<span class="blank long"></span>　答：<span class="blank"></span>{esc(problem["unit"])}</div>
        </div>
        """
        for idx, problem in enumerate(math_data["applications"], start=1)
    )
    return f"""
    <section class="page">
      {paper_header(paper_set, "数学")}

      <div class="section">
        <h2>五、认识立体图形（8分）</h2>
        <p class="instruction">数一数下面的图形，再填空。</p>
        <div class="shape-row">{shapes_html}</div>
        <div class="shape-answer">
          球（　）个　正方体（　）个　圆柱（　）个　长方体（　）个；（　　　　）最多。
        </div>
      </div>

      <div class="section">
        <h2>六、解决问题（20分）</h2>
        {applications_html}
      </div>

      <div class="section">
        <h2>七、思维小挑战（8分）</h2>
        <div class="thinking-box">
          {esc(math_data["thinking"]["question"])}
          <div class="response-rule"></div>
          <div class="response-rule"></div>
        </div>
      </div>
      {page_footer(paper_set, "数学", 2)}
    </section>
    """


def render_paper_html(paper_set: dict[str, Any]) -> str:
    pages = (
        render_chinese_page_one(paper_set)
        + render_chinese_page_two(paper_set)
        + render_math_page_one(paper_set)
        + render_math_page_two(paper_set)
    )
    return f"""<!doctype html>
    <html lang="zh-CN">
      <head><meta charset="utf-8"><title>第{paper_set["number"]:02d}套语文数学练习卷</title><style>{PRINT_CSS}</style></head>
      <body>{pages}</body>
    </html>"""


def step_flow_html(steps: list[str]) -> str:
    return '<div class="step-flow">' + '<span class="flow-arrow">→</span>'.join(
        f'<span class="flow-step">{esc(step)}</span>' for step in steps
    ) + "</div>"


def part_whole_diagram(example: dict[str, int]) -> str:
    return f"""
      <div class="method-card">
        <div class="method-title">图解：把总数分成两个部分</div>
        <div class="part-whole">
          <div class="part-total">{example["total"]}</div>
          <div class="part-lines"></div>
          <div class="part-nodes">
            <div class="part-node">{example["known"]}</div>
            <div class="part-node">？</div>
          </div>
        </div>
        <p class="compact">
          总数是<strong>{example["total"]}</strong>，已经知道一部分是<strong>{example["known"]}</strong>，
          另一部分就是 {example["total"]}－{example["known"]}＝<strong>{example["missing"]}</strong>。
        </p>
      </div>
    """


def make_ten_diagram(example: dict[str, int]) -> str:
    cells = []
    for index in range(10):
        if index < example["left"]:
            dot = '<span class="ten-dot original"></span>'
        elif index < example["left"] + example["need"]:
            dot = '<span class="ten-dot moved"></span>'
        else:
            dot = ""
        cells.append(f'<span class="ten-cell">{dot}</span>')
    rest_dots = "".join('<span class="rest-dot"></span>' for _ in range(example["rest"]))
    return f"""
      <div class="method-card">
        <div class="method-title">凑十法图解：{example["left"]}＋{example["right"]}</div>
        <div class="ten-method">
          <div>
            <div class="ten-frame">{"".join(cells)}</div>
            <div class="dot-legend">
              <span class="legend-dot original"></span>原来的{example["left"]}
              <span class="legend-dot moved"></span>拿来凑十的{example["need"]}
            </div>
            <div style="margin-top:1.5mm">
              凑十后还剩：<span class="rest-dots">{rest_dots}</span>（{example["rest"]}个）
            </div>
          </div>
          <ol class="method-steps">
            <li>{example["left"]}离10还差<strong>{example["need"]}</strong>。</li>
            <li>把{example["right"]}分成<strong>{example["need"]}</strong>和<strong>{example["rest"]}</strong>。</li>
            <li>{example["left"]}＋{example["need"]}＝10。</li>
            <li>10＋{example["rest"]}＝<strong>{example["total"]}</strong>。</li>
          </ol>
        </div>
        <p class="compact"><strong>所以：{example["left"]}＋{example["right"]}＝{example["total"]}。</strong></p>
      </div>
    """


def comparison_diagram(item: dict[str, Any]) -> str:
    maximum = max(item["left_value"], item["right_value"], 1)
    left_width = item["left_value"] / maximum * 100
    right_width = item["right_value"] / maximum * 100
    return f"""
      <div class="method-card">
        <div class="method-title">图解：先算两边，再比较长短</div>
        <div class="compare-model">
          <div class="compare-row">
            <span>{esc(item["left"])}＝{item["left_value"]}</span>
            <span class="compare-track"><span class="compare-fill" style="display:block;width:{left_width:.1f}%"></span></span>
            <strong>{item["left_value"]}</strong>
          </div>
          <div class="compare-row">
            <span>{esc(item["right"])}＝{item["right_value"]}</span>
            <span class="compare-track"><span class="compare-fill" style="display:block;width:{right_width:.1f}%"></span></span>
            <strong>{item["right_value"]}</strong>
          </div>
        </div>
        <p class="compact">较长的条表示数更大，所以填“<strong>{item["answer"]}</strong>”。</p>
      </div>
    """


def bar_model_diagram(problem: dict[str, Any]) -> str:
    model = problem["model"]
    total = max(model["total"], 1)
    parts = "".join(
        f'<span class="bar-part" style="flex:{part / total:.4f}">{esc(label)} {part}</span>'
        for part, label in zip(model["parts"], model["labels"])
    )
    return f"""
      <div class="bar-model">
        <div class="bar-total">整条表示总数：{model["total"]}{esc(problem["unit"])}</div>
        <div class="bar-parts">{parts}</div>
      </div>
    """


def render_chinese_answers(paper_set: dict[str, Any]) -> str:
    chinese = paper_set["chinese"]
    pinyin_answers = "".join(
        f'<li><strong>{esc(item["character"])}：</strong>{esc(item["answer"])}。'
        f'<span class="reason">思路：先读准声母、韵母，再看声调位置。</span></li>'
        for item in chinese["pinyin"]
    )
    writing_answers = "；".join(
        f'{esc(item["pinyin"])}—{esc(item["answer"])}' for item in chinese["writing"]
    )
    antonym_answers = "；".join(
        f'{esc(item["word"])}—{esc(item["answer"])}' for item in chinese["antonyms"]
    )
    quantifier_answers = "；".join(
        f'一{esc(item["answer"])}{esc(item["noun"])}' for item in chinese["quantifiers"]
    )
    order_answers = "".join(
        f'<li>{esc(answer)}<span class="reason">检查：谁做什么，句末加标点。</span></li>'
        for _, answer in chinese["sentences"]["order"]
    )
    complete_answers = "".join(
        f'<li>{esc(sample)}<span class="reason">这是示例，句子通顺、意思完整即可。</span></li>'
        for _, sample in chinese["sentences"]["complete"]
    )
    reading_answers = "".join(
        f'<li><strong>{esc(answer)}</strong><br><span class="reason">{esc(reason)}</span></li>'
        for _, answer, reason in chinese["reading"]["questions"]
    )
    return f"""
      <h2>语文答案与解析</h2>
      <h3>一、拼音小站（12分）</h3>
      <ol class="answer-list">{pinyin_answers}</ol>
      <div class="method-card">
        <div class="method-title">拼音选择三步法</div>
        {step_flow_html(["看清汉字", "拼声母和韵母", "核对声调"])}
        <p class="compact">不要只看第一个字母；要把整个音节读出来，再比较两个选项哪里不同。</p>
      </div>

      <h3>二、看拼音写词语（16分）</h3>
      <p class="compact"><strong>答案：</strong>{writing_answers}。</p>
      <div class="method-card">
        <div class="method-title">看拼音写词语流程</div>
        {step_flow_html(["完整拼读", "想出词语", "逐字书写", "检查笔画"])}
        <p class="compact">例如先把两个音节连起来读成一个词，再想每个字的样子，不要读一个字写一个字后就忘记检查。</p>
      </div>

      <h3>三、字词乐园（24分）</h3>
      <ol class="answer-list">
        <li>“{esc(chinese["stroke"]["character"])}”共<strong>{chinese["stroke"]["answer"]}</strong>画；“{esc(chinese["radical"]["character"])}”的偏旁是<strong>{esc(chinese["radical"]["answer"])}</strong>。<span class="reason">数笔画时按规范书写顺序一笔一笔数。</span></li>
        <li><strong>{antonym_answers}</strong>。<span class="reason">反义词表示意思相反或相对。</span></li>
        <li><strong>{quantifier_answers}</strong>。<span class="reason">量词要和后面的事物搭配自然。</span></li>
      </ol>

      <h3>四、句子训练营（20分）</h3>
      <p class="compact"><strong>词语排序：</strong></p>
      <ol class="answer-list">{order_answers}</ol>
      <p class="compact"><strong>补充句子示例：</strong></p>
      <ol class="answer-list" start="3">{complete_answers}</ol>

      <h3>五、快乐阅读（20分）</h3>
      <ol class="answer-list">{reading_answers}</ol>
      <div class="method-card">
        <div class="method-title">阅读题答题路线</div>
        {step_flow_html(["先读完整短文", "圈出题目关键词", "回原文找句子", "用完整话回答"])}
        <p class="compact">问“谁、什么、哪里”时，答案通常能从原文直接找到；问“为什么”时，要把前后两句话联系起来。</p>
      </div>

      <h3>六、我会表达（8分）</h3>
      <div class="answer-callout">
        <strong>参考示例：</strong>{esc(chinese["expression"]["sample"])}<br>
        <span class="reason">评分建议：围绕题目写2—3句，句子通顺、意思连贯、标点基本正确。示例不是唯一答案。</span>
      </div>
      <div class="method-card">
        <div class="method-title">表达题可以按这个顺序写</div>
        {step_flow_html(["写清对象", "写样子或事情", "写自己的感受"])}
        <p class="compact">每说完一个完整意思就加句号。写完后轻声读一遍，看看有没有漏字或重复。</p>
      </div>
    """


def render_math_answers(paper_set: dict[str, Any]) -> str:
    math_data = paper_set["math"]
    sequence_answers = "；".join(
        "、".join(str(value) for value in sequence["values"])
        for sequence in math_data["sequences"]
    )
    composition_answers = "".join(
        f'<li>{esc(item["text"])}，□＝<strong>{item["answer"]}</strong>。'
        f'<span class="reason">用加减法互逆关系：{esc(item["reason"])}。</span></li>'
        for item in math_data["compositions"]
    )
    comparison_answers = "".join(
        f'<li>{esc(item["left"])} <strong>{item["answer"]}</strong> {esc(item["right"])}。'
        f'<span class="reason">两边分别是{item["left_value"]}和{item["right_value"]}。</span></li>'
        for item in math_data["comparisons"]
    )
    calculation_answers = "　　".join(
        f'{esc(item["text"])}＝<strong>{item["answer"]}</strong>'
        for item in math_data["calculations"]
    )
    missing_answers = "".join(
        f'<li>{esc(item["text"])}，□＝<strong>{item["answer"]}</strong>。</li>'
        for item in math_data["missing"]
    )
    shape_counts = math_data["shapes"]["counts"]
    shape_text = "，".join(f"{name}{count}个" for name, count in shape_counts.items())
    application_answers = "".join(
        f'<li><div><strong>题意：</strong>{esc(problem["text"])}</div>'
        f'{bar_model_diagram(problem)}'
        f'<div><strong>列式：</strong>{esc(problem["equation"])}</div>'
        f'<div class="reason">{esc(problem["reason"])} 图中整条是总数，两小段是两个部分。答：{problem["answer"]}{esc(problem["unit"])}。</div></li>'
        for problem in math_data["applications"]
    )
    missing_example = math_data["missing"][0]
    missing_match = re.fullmatch(r"□＋(\d+)＝(\d+)", missing_example["text"])
    if missing_match is None:
        raise ValueError("填数示例格式不正确。")
    missing_known = int(missing_match.group(1))
    missing_total = int(missing_match.group(2))
    thinking_steps = "".join(
        f"<li>{esc(step)}</li>" for step in math_data["thinking"]["steps"]
    )
    return f"""
      <h2>数学答案与解析</h2>
      <h3>一、数的认识与组成（16分）</h3>
      <p><strong>完整数列：</strong>{sequence_answers}。</p>
      <ol class="answer-list">{composition_answers}</ol>
      <div class="method-card">
        <div class="method-title">数列填空三步</div>
        {step_flow_html(["看箭头方向", "判断每次加1或减1", "填完从头读一遍"])}
      </div>
      {part_whole_diagram(math_data["method_examples"]["part_whole"])}

      <h3>二、比较大小（12分）</h3>
      <ol class="answer-list">{comparison_answers}</ol>
      {comparison_diagram(math_data["comparisons"][2])}

      <h3>三、直接写得数（24分）</h3>
      <div class="answer-callout">{calculation_answers}</div>
      {make_ten_diagram(math_data["method_examples"]["make_ten"])}

      <h3>四、填合适的数（12分）</h3>
      <ol class="answer-list">{missing_answers}</ol>
      <div class="method-card">
        <div class="method-title">填数示例：{esc(missing_example["text"])}</div>
        {step_flow_html([
            f"总数{missing_total}",
            f"减去已知数{missing_known}",
            f"方框填{missing_example['answer']}",
            f"验算：{missing_example['answer']}＋{missing_known}＝{missing_total}",
        ])}
        <p class="compact">不能靠猜。把填好的数代回原算式，等号左边算出的结果必须和右边相同。</p>
      </div>

      <h3>五、认识立体图形（8分）</h3>
      <p><strong>{shape_text}；{esc(math_data["shapes"]["most"])}最多。</strong></p>
      <div class="method-card">
        <div class="method-title">看特征认图形</div>
        <div class="shape-row">
          {shape_svg("球")}<span>球：圆圆的，会滚动</span>
          {shape_svg("正方体")}<span>正方体：六个面一样大</span>
          {shape_svg("圆柱")}<span>圆柱：上下两个圆面</span>
          {shape_svg("长方体")}<span>长方体：有长方形的面</span>
        </div>
        <p class="compact">数图形时从左到右，每数一个做一个小记号，避免漏数或重复。</p>
      </div>

      <h3>六、解决问题（20分）</h3>
      <ol class="answer-list">{application_answers}</ol>

      <h3>七、思维小挑战（8分）</h3>
      <div class="answer-callout">
        <strong>答案：</strong>{esc(math_data["thinking"]["answer"])}<br>
        <strong>分步思考：</strong>
        <ol class="thinking-steps">{thinking_steps}</ol>
        <span class="reason">小结：{esc(math_data["thinking"]["reason"])}</span>
      </div>
    """


def render_answer_html(paper_sets: list[dict[str, Any]]) -> str:
    cover = """
      <section class="answer-cover">
        <h1>一年级上册语文数学<br>答案、思路与图解</h1>
        <h2>对应练习卷第01—10套</h2>
        <div class="answer-note">
          <strong>使用说明</strong>
          <ol>
            <li>本资料按一年级上册语文、数学教材内容编写。</li>
            <li>语文开放题与表达题答案不唯一，参考示例用于展示答题方向。</li>
            <li>数学应用题建议同时检查“算式、单位、答句”。</li>
            <li>小学一二年级不组织纸笔考试，建议作为家庭巩固材料，分科、分次、轻松使用。</li>
          </ol>
          <p><strong>教材口径：</strong>统编语文一年级上册（2024年修订）；人教版数学一年级上册（2024年修订）。</p>
        </div>
      </section>
    """
    answer_sets = "".join(
        f"""
        <section class="answer-set">
          <h1>第{paper_set["number"]:02d}套 · {esc(paper_set["level"])}</h1>
          {render_chinese_answers(paper_set)}
          {render_math_answers(paper_set)}
        </section>
        """
        for paper_set in paper_sets
    )
    return f"""<!doctype html>
    <html lang="zh-CN">
      <head><meta charset="utf-8"><title>一年级上册语文数学答案、思路与图解</title><style>{PRINT_CSS}</style></head>
      <body class="answer-document">{cover}{answer_sets}</body>
    </html>"""


def paper_pdf_path(number: int) -> Path:
    return ROOT / f"一年级上册语文数学练习卷_第{number:02d}套.pdf"


def count_pdf_pages(path: Path) -> int:
    data = path.read_bytes()
    return len(re.findall(rb"/Type\s*/Page\b", data))


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
            """pages => pages.map((page, index) => ({
              page: index + 1,
              scrollHeight: page.scrollHeight,
              clientHeight: page.clientHeight,
              scrollWidth: page.scrollWidth,
              clientWidth: page.clientWidth,
              overflow: page.scrollHeight > page.clientHeight + 1 || page.scrollWidth > page.clientWidth + 1
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


async def build_pdfs(paper_sets: list[dict[str, Any]], *, answers_only: bool = False) -> None:
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
        if not answers_only:
            for paper_set in paper_sets:
                output_path = paper_pdf_path(paper_set["number"])
                await render_pdf(
                    page,
                    render_paper_html(paper_set),
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


def validate_outputs(paper_sets: list[dict[str, Any]]) -> None:
    expected_paths = [paper_pdf_path(item["number"]) for item in paper_sets] + [ANSWER_PDF]
    missing = [path.name for path in expected_paths if not path.exists()]
    if missing:
        raise RuntimeError(f"缺少PDF文件：{missing}")

    for path in expected_paths:
        if path.stat().st_size < 20_000:
            raise RuntimeError(f"PDF文件过小，可能生成失败：{path.name}")
        if path.read_bytes()[:5] != b"%PDF-":
            raise RuntimeError(f"文件不是有效PDF：{path.name}")

    for paper_set in paper_sets:
        path = paper_pdf_path(paper_set["number"])
        page_count = count_pdf_pages(path)
        if page_count != 4:
            raise RuntimeError(f"{path.name} 应为4页，实际检测为{page_count}页。")

    answer_pages = count_pdf_pages(ANSWER_PDF)
    if answer_pages < 11:
        raise RuntimeError(f"答案册页数异常：{answer_pages}")
    print(
        json.dumps(
            {
                "papers": len(paper_sets),
                "paper_pages_each": 4,
                "answer_pages": answer_pages,
                "output_directory": str(ROOT),
            },
            ensure_ascii=False,
            indent=2,
        )
    )


async def main() -> None:
    paper_sets = build_paper_sets()
    validate_blueprints(paper_sets)
    await build_pdfs(paper_sets, answers_only="--answers-only" in sys.argv[1:])
    validate_outputs(paper_sets)


if __name__ == "__main__":
    asyncio.run(main())
