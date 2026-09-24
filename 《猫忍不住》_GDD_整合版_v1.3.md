# 《猫忍不住》游戏设计文档 · 整合版 v1.3.1

> **副标题：忍者在明处，猫在幕后。**
>
> 本文档是《猫忍不住》设计文档的**唯一权威入口**，整合了以下全部历史文档：
>
> | 源文件 | 版本 | 地位 |
> |---|---|---|
> | 影猫_游戏设计文档.md（= 09977217-…md） | v0.3 | 原始 GDD：玩法细节、台词池、威胁设计卡、素材映射 |
> | yingmao_gdd_v1_0_release_candidate.md / review_report | v1.0 | Gameplay 冻结版 + 评审（数值表、FTUE、反馈层级、设计原则） |
> | yingmao_v1_1_Master_GDD / System_Spec / Level_Bible / Production_QA / release_candidate | v1.1 | Production Candidate：三层范围冻结、评分公式 A–G、猫技艺、Asset Manifest |
> | maorenbuzhu_v1_2_CHANGELOG / Master_GDD / Level_Bible / System_Spec / Production_QA | v1.2 | 改名《猫忍不住》、3 关扩为 3 章 × 4 关 = 12 关 |
> | maorenbuzhu_v1_2_1_Level_Implementation_Spec | v1.2.1 | 12 关白盒实施颗粒度 |
> | maorenbuzhu_v1_2_1_Production_Addendum | v1.2.1 | Sprint A/B/C 与每关 DoD 五问 |
> | maorenbuzhu_v1_2_2/3/4_Chapter01/02/03_Whitebox_Blueprint | v1.2.2–4 | 三章白盒蓝图 |
> | maorenbuzhu_v1_2_5_DataResource_Spec / Examples | v1.2.5 | Data Resource 规范与 .tres 示例 |
> | v1_2_6_Vertical_Slice_Spec | v1.2.6 | L01 垂直切片 |
> | v1_2_7_L01_Implementation_Spec | v1.2.7 | L01 教学关实施 |
> | v1_2_8_Chapter01_Integration_Spec | v1.2.8 | 第一章连续试玩集成 |
>
> **冲突仲裁原则：版本新者优先（v1.2.x > v1.1 > v1.0 > v0.3）；同版本冲突在本文 §15.2 记录裁定。** 原始文件保留作历史归档，不再单独维护。
>
> **素材约束：美术与音频严格限于 Ninja Adventure Asset Pack（唯一缺口：猫叫声效，见 §9.3）。**
>
> v1.3.1 修订（2026-09-24）：按《GDD_v1.3_审查报告》修复 P0×3 / P1×5 / P2×4，详见审查报告与 §15.2。

---

# 第一部分 · 产品定义

## 1.1 名称

- 中文正式名：**《猫忍不住》**（旧名《影猫》，v1.2 起全面迁移：商店名、启动标题、GDD、UI、结算、成就、Logo 统一新名；Godot `application/config/name = "猫忍不住"`；新增资源用 `maorenbuzhu_` 前缀；旧目录名与 Git 分支暂保留避免路径风险）。

## 1.2 一句话

> **大名鼎鼎的忍者出任务，其实一路都是他的猫在暗中替他扫平一切——而他对此一无所知。**

## 1.3 类型

**俯视角 · 实时路线调度 × 事件解谜 × 反向护送 × 喜剧叙事**（Reverse Escort）

## 1.4 核心幻想

玩家不是台上的英雄，忍者是。猫负责：提前处理危险、改变 NPC 位置、调整环境、搬运物品、制造事件链、最后一秒救场。结算时忍者把功劳全部归给自己。

**反转点：** "护送任务"是玩家最恨的任务类型——本作把仇恨对象反转成爽点：那个蠢 AI 是你的"作品"，你就是让一切顺利的幕后黑手。

## 1.5 设计戒律与原则

**三条最高设计戒律（一切取舍的仲裁标准）：**

1. **功劳永远归他，乐趣永远归你。**
2. **蠢要可预测。**（挫败感应来自"我没算到"，不是"他随机发病"）
3. **失败后玩家必须知道自己为什么失败。**

**六条最终设计原则（v1.0 §61）：**

1. 不要增加按钮解决深度，深度来自关系
2. 不要用随机解决重复，重复来自不同组合
3. 不要用高伤害制造紧张，紧张来自多个窗口之间的冲突
4. 不要用复杂 UI 解释系统，让世界自己告诉玩家
5. 不要让 Boss 抢走猫的主角地位
6. 不要用大量台词替代笑点，玩家做的事情才是笑点来源

**喜剧结构公式（v1.0 §52）：** 玩家真实行为 → 忍者看到结果 → 错误归因 → 玩家知道真相。所有核心笑点都必须有玩家行为作为因。

## 1.6 产品范围冻结（v1.1 建立，v1.2 更新）

**CORE 必须完成：**
- 猫移动 / 疾跑 / E 互动 / Q 叼取放置 / F 喵叫 / Ctrl 卖萌
- JumpPoint / CatTunnel
- 忍者固定路线 + 状态机 + Scripted Branch
- EventPoint / WorldState / NPC State Machine / Suspicion
- 三猫爪评分 / Retry / Save & Load
- **12 个正式主线关卡（3 章 × 4 关）**
- 第三章末尾 Boss
- 基础居酒屋结算

**RC REQUIRED：** 12 关基础平衡、3 章独立进度、12 关 LevelValidator、章节完成结算、15 个以内成就、5 套猫外观、鱼干收集、Hard Mode / Hard+、完整 HUD / 手柄 / Accessibility、Audio 分层、Debug Build。

**RC OPTIONAL：** Replay、分享卡、额外忍者人格、第四章节内容、第 2 套以后 Boss。

**优先级：`Gameplay > Settlement > Meta > Replay > Share`**

## 1.7 最终产品句

> **《猫忍不住》是一款让玩家永远没有功劳，却永远掌控局面的反向护送游戏。**
>
> 忍者在台上。猫在台下。玩家知道所有真相。忍者不知道。

**品牌识别三点（v1.0 §54）：** 视觉：忍者在上/猫在下；音频：猫得手签名音；结算：忍者吹牛 + 猫舔爪。

---

# 第二部分 · 核心玩法

## 2.1 核心循环

```
读图观察（10 秒镜头巡游：忍者路线 + 沿途威胁依次高亮）
   ↓
忍者出发，沿固定路线行动（会犯蠢：踩陷阱/撞视野/悬崖边犹豫）
   ↓
你（猫）抢在他前面清扫障碍：咬绳 / 引怪 / 推物 / 投喂
   ↓
同时不能被他看见你干坏事——在他视野外行动，或卖萌蒙混
   ↓
他安全抵达终点 → 结算：居酒屋吹牛 + 三猫爪评价
```

**单局节奏（目标单局 1–2 分钟（target_time 55–125s，见 §5.2），含读图与结算约 2–3 分钟）：**

| 阶段 | 时长 | 体验 |
|---|---|---|
| 读图 | ~10 秒 | 紧张前的安静，玩家规划解法顺序 |
| 前段 | 20–40 秒 | 单点威胁，建立信心与笑点 |
| 中段 | 30–50 秒 | 威胁联动，排序解题，首次紧张峰值 |
| 尾段 | 15–30 秒 | 忍者"状态绝佳"走路加快，玩家疲于奔命（喜剧高潮） |
| 结算 | ~30 秒（重复挑战压缩至 8–12 秒） | 吹牛 + 评分，情绪释放 |

**失败条件：**
- 忍者死亡（坠崖直接死；陷阱/守卫/中毒累计扣 3 颗心）→ 任务失败
- 怀疑值满 100 → 他吓得弃任务回家（"这猫不对劲！"）

**失败重试：** 立即回到读图阶段，事件点状态全部重置；死亡演出控制在 3 秒内，重试零加载（R 键）。失败本身带笑点（见 §4 各威胁"失败演出"）。

**失败诊断文案原则（v1.0 §32）：** 告诉玩家"错在哪里"，不告诉"唯一正确答案"。示例：L01"你晚了一步。"／换岗关"换岗已经发生，你还在这里。"／L12"Boss 已进入终结节奏，而你的救场机关还没准备。"这些属于诊断，不属于攻略。

## 2.2 玩家能力（猫）

| 能力 | 按键 | 说明 |
|---|---|---|
| 移动 | WASD / 左摇杆 | 四方向移动 |
| 疾跑 | Shift | 短时间加速，消耗体力，有残影 |
| 跳跃/攀爬 | Space（关卡内）/ JumpPoint | 跳上屋顶、树、箱子——立体机动是核心优势 |
| 互动（咬/推/拍） | E | 情境交互：咬断绳、推箱子/桶、拍飞小物件；咬绳 0.8s 进度条，可被打断 |
| 叼取/放置 | Q | 叼起小道具（解毒药、鱼肉），放到指定位置；叼取移速 ×0.85 |
| 喵叫 | F | 引开守卫/动物（对忍者无效——他只会说"哪来的猫"）；不产生怀疑 |
| 卖萌 | Ctrl | 原地躺下翻肚皮：怀疑值清零，冷却 20s |
| 重开 | R | 失败/完成后重载场景 |
| 下一关/回首关 | Space / Enter | 通关后 Space 进下一关；章节结算后 Enter 回 L01。**结算画面首 1 秒屏蔽输入**，防止关卡内跳跃惯性误跳结算演出 |

**设计要点：**
- **猫不能战斗。** 只能"做手脚"——保住"忍者的功劳簿上不能有伤口"的喜剧前提。视觉语言：无攻击锁定 UI，动作全是拍/推/咬/拨。
- **体型优势：** 钻桌底、篱笆缝、狗洞（CatTunnel）、JumpPoint——忍者过不去的捷径，让猫总能绕到他前面。
- **皮肤 5 套（数值完全相同）：** 黑猫（默认）、橘猫、白猫、灰猫、独眼猫。独眼猫 = Hard+ 解锁（全 12 关 3 猫爪，见 §15.2 仲裁）。

## 2.3 全局数值表（唯一数值源，v1.1 冻结 + v0.3 手感参数）

```text
CAT_SPEED = 90 px/s          CAT_SPRINT_SPEED = 160 px/s
CAT_STAMINA_MAX = 100        CAT_SPRINT_COST = 25/s
CAT_STAMINA_REGEN = 20/s     CARRY_SPEED_MULT = 0.85
MEOW_RADIUS = 120 px         MEOW_LURE_RADIUS(守卫/声响) = 150 px
EMOTE_COOLDOWN = 20 s        EMOTE_RANGE = 150 px（须在忍者 150px 内且视线内）
NINJA_BASE_SPEED = 60 px/s   NINJA_PROUD_SPEED = 66 px/s（得意忘形 +10%）
NINJA_SEARCH_TIMEOUT = 3 s
NINJA_HP = 3
DEFAULT_EVENT_TIMEOUT = 5–8 s
BOSS_PREPARE_TIME = 8 s      EMERGENCY_RESCUE_WINDOW = 1.5–2.0 s

SUSPICION_MAX = 100
SUSPICION_NOTICE = 25 / ALERT = 50 / HIGH = 80
阈值消费：≥25 忍者视锥开始摆动（"他在找那只猫"前兆）；≥50 猫眼表盘半睁（= Paw3-B 阈值）；≥80 触发一级危机反馈（= Paw2 上限）

互动耗时/方式：咬绳 0.8s（进度条可打断）/ 推箱：按住 E 以 40 px/s 持续推动，推到目标锚点完成（L01 E03 推距折算参考时长约 1.2s）/ 拍飞单件 0.3s / 推桶同推箱
忍者犹豫窗口：2–5s（绊绳 0s / 蒺藜 2s / 守卫 3s / 恶狗 3s / 毒雾 4s / 悬崖 5s / 教学关统一 3.2s）
守卫：巡逻周期 8s / 被引开 6s 后回岗 / 第三章回位基准 6s
恶狗：感知圈 80 px / 鱼肉吸引半径 200 px / 鱼肉拴住 20s
炸药桶：爆炸半径 48 px（猫在半径内被气浪掀飞 1s，不扣血）
毒雾：中毒每 5s -1 心 / 药瓶滚速 100 px/s
悬崖：箱子垫脚 ×2 / 猫站箱上可跳更高
```

**数值纪律：** 数值调节必须通过 Data Resource 修改，禁止直接改脚本；`target_time` 等是首轮调平参数，正式值由首轮 8 人试玩冻结。

## 2.4 隐蔽 / 怀疑系统（Suspicion）

**冻结语义（v1.1，v1.2 §10 确认）：**

```text
猫被看见              = 正常，不涨怀疑（你是他的猫）
猫做事被看到          = 怀疑增加（动作帧判定）
猫离开暴露区域        = 停止继续累积（已有怀疑保留，不随时间衰减）
Ctrl 卖萌             = 清除已有怀疑（20s 冷却，须在他视线内）
怀疑值 = 100          = 失败
```

**判定细则：**
- 忍者视野 = 前方 90° 视锥（半径 100 px）+ 周身 24 px 全向感知。
- 涨怀疑的是"通人性的行为"瞬间：推箱、咬绳、叼着道具、拍飞物件的**动作帧**落在视锥内才累积。
- 视锥边缘 +30/次；视锥中心持续 1 秒 +60。
- 卖萌限制：必须在他视线内使用才有效；使用瞬间若叼着道具，道具掉落原地（喜剧细节：他看到的最后画面是猫从嘴里吐出一瓶药）。
- 垂直切片期允许近似判定（距离 ≤120px 且朝向猫），生产版由 SuspicionSystem 组件替换为完整 90° 视锥。
- 12 关允许通过 `LevelModifier.suspicion_gain_mult` 轻量调整，**不允许修改阈值语义**。

**边界裁定 FAQ（程序判定依据）：**

| 情况 | 裁定 |
|---|---|
| 猫挡在忍者行进路线上 | 停下："让让，小东西。"等 2 秒猫不走，绕半步继续。不涨怀疑，但浪费犹豫窗口——软性惩罚 |
| 猫在忍者正脚下推箱子 | 涨怀疑（动作帧判定），箱子推不动（他踩着） |
| 卖萌冷却中被看见干坏事 | 怀疑照常累积；跑出视野后他"疑惑自我消解"：怀疑值不变但暂停累积 3 秒（他忙着说服自己） |
| 忍者犹豫时猫在他眼前卖萌 | 疑惑暂停延长 2 秒，爱心气泡："今天你也这么黏人。"——卖萌可当拖时间工具，一次事件点限一次 |
| 叼着道具被狗抓到 | 道具掉在原地，需回去捡；猫被叼着甩两下扔到远处（损失 2 秒） |
| 忍者死亡瞬间猫在视锥内 | 不追加怀疑（他已经死了），死亡演出照常 |
| 喵叫 | 不产生怀疑（猫叫很正常） |

**其他目击者：** 守卫、村民对猫无反应。**狗会追猫**（天敌机制），狗叫（`Dog.wav`）会吸引守卫——可被反向利用。

## 2.5 事件窗口与多线程标准（v1.0 §13/14）

- 事件统一四阶段：`PREVIEW → WARN → TRIGGER → RECOVERY`
- 窗口时间标准：正常 2–5 秒 / 紧迫 1–2 秒 / 极限 0.5–1 秒 / 少于 0.5 秒只允许作为已知熟练操作的隐藏挑战。
- **核心难度来自：多个合理窗口同时存在。而不是：单个窗口极短。**
- 同时进入 HIGH_PRESSURE 的事件最多 2 个（两个事件 = 排序思考；三个以上 = 手速压力）。
- 动画节奏（v1.0 §23）：关键动作序列 `动作开始 → Gameplay Marker → 世界状态变化 → SFX → FX → Ninja Reaction`；关键反馈 0.8–1.2 秒内完成；失败演出约 3 秒内结束并可重试；Boss Phase 切换 ≤0.7 秒。

---

# 第三部分 · NPC 忍者（本作真正的"主角"）

## 3.1 行为模型

忍者不是随机蠢，而是**可预测的蠢**——玩家要读懂他的剧本才能提前布局。

```
出发 → 沿 waypoint 固定路线移动 → 进入【事件点】触发固定蠢反应（含犹豫窗口）
     → 若威胁已被玩家处理：得意反应 + 记入事件日志
     → 若未处理：踩坑 → 扣血/死亡 → 惊吓/疼痛演出
     → 继续 → 抵达目标
```

**技术铁律：** 固定路线 + 离散状态机 + WorldState 驱动预设分支。禁止自由寻路、随机路线、随机危险反应；允许 AlternativeRoute（如 `bridge_open=false → 走 PoisonFork`）和 Personality Modifier。**蠢是演出，不是模拟。**

## 3.2 情绪状态机（喜剧表现的发动机）

| 状态 | 表情（Ui/Emote） | 触发 | 行为效果 |
|---|---|---|---|
| 自信 | 得意脸 | 默认/通过威胁后 | 无 |
| 疑惑 | 问号 | 发现断绳/莫名的箱子/地上的药 | 停顿 2 秒，自我消解台词 |
| 惊吓 | 感叹号+汗 | 被玩家救下的惊险瞬间 | 冷汗粒子，后退半步 |
| 得意忘形 | 闪光 | 连续 3 个威胁顺利通过 | **移速 +10%（66 px/s），下一事件点犹豫窗口 -1 秒**——顺风反而更危险，难度自平衡 |
| 怀疑 | 眼睛图标 | 看见猫干坏事 | 怀疑值累积中，视锥轻微摆动（他在找那只猫） |

**关键设计：他的疑惑永远自我消解。** 一切归功自己——这是结算吹牛的素材来源。

## 3.3 台词池（每类随机抽取，避免重复笑点衰减；困难剧本换新池）

**顺利通过（得意）：**
- "哼，这种程度也想拦我？"
- "感觉到了吗，这顺畅的查克拉流动。"
- "今天的我，无可挑剔。"

**疑惑自我消解（核心笑点）：**
- （看到断绳）"绳子自己断了……定是被我的杀气震断的。"
- （看到垫脚箱）"悬崖边恰好有箱子？呵，连老天都站在我这边。"
- （看到脚边的药）"哦？补给？看来村里人偷偷仰慕我。"
- （守卫莫名走开）"算他识相。"
- （喵叫引开守卫后）"方才那声猫叫……莫非是我的守护灵？"
- （看到掉进水里漂走的炸药桶）"炸药桶自己掉水里了？受潮的东西也配挡我。"
- （看到被拨到草丛里的铁蒺藜）"蒺藜都长歪了，这路修得不行。"

**惊吓（被救下的瞬间）：**
- "刚、刚才那阵风……是错觉吧。"
- "后背一凉……一定是昨夜没睡好。"

**得意忘形（连过 3 事件后）：**
- "状态绝佳！！今夜没有人能拦我！"
- "要不要……干脆从正门进去？"（危险发言，下一事件点他不再犹豫）

**发现猫干坏事（怀疑累积）：**
- "嗯？？那猫刚才是不是推了个箱子？"
- "不可能……猫怎么会叼着药瓶……"
- "我一定是太累了。"（自我消解，怀疑值暂停累积 3 秒）

**死亡/失败：**
- （坠崖）"呜哇啊啊啊——任务、还没——"
- （怀疑值满）"那猫绝对有问题！！今天不宜出行！！"（抱头跑回起点）

**挡路：**
- "让让，小东西。"
- "别闹，办完正事给你带小鱼干。"

**章节通关吹牛句：** 第二章末"我一到码头，连海风都顺着我吹。"；第三章末"那武士见我就跪了，大概是被我的气势震的。"

**皮肤彩蛋：** 独眼猫过关——"总觉得家里的猫眼神犀利了许多……错觉。"

## 3.4 血量与容错

- 3 颗心。踩陷阱 -1，被守卫砍 -1，中毒每 5 秒 -1，坠崖直接死。
- 容错服务于"差一点没救到"的紧张喜剧，不是硬核折磨。
- 扣血演出要有喜剧性（被渔网吊起来晃、被守卫追砍绕树跑三圈后逃脱），**"惨而不死"比直接死亡更好笑**，也给玩家补救窗口。

## 3.5 忍者无文字动作库

喜剧演出的一半来自台词（§3.3），另一半来自动作。全部用现有 SpriteSheet 帧 + 位移/缩放实现，不新增素材：自信=叉腰/甩披风；疑惑=挠头/原地环顾；惊吓=后跳半步/扶帽；得意忘形=摆 pose/整理衣领；怀疑=蹲下打量猫/眯眼扫视；失败或狼狈后=背对镜头偷偷整理形象再继续走。

---

# 第四部分 · 威胁设计卡（事件点规格库）

统一设计卡模板：**触发 / 犹豫窗口（hesitation_time，忍者停下犹豫的时长）/ 触发窗口（trigger_window，事件可被处理的总时长）/ 解法 / 失败演出 / 成功演出 / 参数 / 素材**。所有素材均在素材包内。事件等级：CRITICAL（核心学习）/ STANDARD（普通推进）/ OPTIONAL（鱼干/彩蛋）。

## 4.1 绊绳 Tripwire

- **触发：** 忍者踩绳 → 被渔网吊起，-1 心，吊 5 秒后挣脱
- **犹豫窗口：** 无（他直接踩）——玩家须在他到达前处理
- **解法：** 咬断绳子（E，0.8s 进度条）
- **失败演出：** 吊在半空晃，挣扎，忍具掉一地："谁！谁干的！（心虚四顾）没人看见吧……"
- **成功演出：** 走过断绳时疑惑气泡 → 自我消解台词 → 得意
- **参数：** 断绳后遗留绳头可被猫叼走藏进草丛（完美主义加分项，不强制）
- **素材：** 绳用 Line2D 程序化绘制；网 `Backgrounds/Vehicles/FishNet.png`；咬断瞬间 `FX/Slash/SpriteSheetSlash01.png`

## 4.2 巡逻守卫 Guard

- **触发：** 忍者撞进守卫视锥 → 被追砍，绕树跑三圈后逃脱，-1 心
- **犹豫窗口：** 3 秒（他先观察巡逻节奏，然后自信走进去——观察了个寂寞）
- **解法：** 喵叫引开 / 拍飞陶罐制造声响 / 鱼肉引狗去吠守卫（高级连锁）
- **失败演出：** 被追得绕树三圈，帽子被削掉，逃跑时顺手捡回帽子
- **成功演出：** 从守卫背后 2 米处大摇大摆走过："他连我的影子都摸不到。"
- **参数：** 巡逻周期 8s；声响吸引半径 150 px；被引开 6s 后回岗（回归时间点构成排序压力）
- **素材：** `Actor/Character/SamuraiBlue` / `SamuraiRed`；声响 `FX/Smoke/SmokeCircular`；陶罐碎裂 `FX/Particle/Vase.png`

## 4.3 悬崖/断桥 Cliff / BrokenBridge

- **触发：** 忍者到崖边犹豫 5 秒 → 硬跳 → 50% 概率摔死（读图时标注，必解项）
- **犹豫窗口：** 5 秒（最长操作窗口，安排给最复杂解法）
- **解法：** 推 2 个木箱垫脚（箱子在 30–60 px 外，规划推箱路线避开他的视线）
- **失败演出：** 跳下，惨叫，屏幕下边缘伸出一只手扒住崖壁又滑下去
- **成功演出：** 踩着箱子轻盈跃过："悬崖边恰好有箱子？"→ 自我消解
- **参数：** 箱子推速 40 px/s；猫站箱子上可跳更高（兼作玩家立体机动道具）
- **素材：** `Items/Object/CrateEmpty.png`；悬崖 `Backgrounds/Tilesets/TilesetRelief.png` / `TilesetHole.png`

## 4.4 毒雾/毒沼泽 Poison

- **触发：** 忍者深吸一口气硬闯 → 中毒，每 5 秒 -1 心
- **犹豫窗口：** 4 秒
- **解法：** 把解毒药叼到他必经之路显眼处（他会"哦？补给？"捡起收好——注意他**不会主动吃**，需再拍一下药瓶滚到他脚边触发弯腰捡）
- **失败演出：** 脸色发绿（调色 shader），边跑边呕，找到水缸狂灌水解毒
- **成功演出：** 屏息冲过毒雾，出来后："闭气功夫，天下第一。"
- **参数：** 叼药移速 ×0.85；药瓶滚速 100 px/s
- **素材：** 毒雾 `FX/Environment/Fog.png` 染绿 / 流沙 `Backgrounds/Animated/QuickSand/QuickSand32x32.png` 染紫；药瓶 `Items/Potion/LifePot.png`（备选 `MilkPot.png`）

## 4.5 恶狗 Dog

- **触发：** 忍者怕狗！见到狗会绕远路——而绕远路必然撞进另一个威胁（组合拳）
- **犹豫窗口：** 3 秒（原地跺脚："可、可恶的畜生……"）
- **解法：** 鱼肉引到反方向（拴住 20s）/ 猫自己当诱饵引狗绕场（高风险高笑点）
- **失败演出：** 绕远路，撞进隔壁铁蒺藜阵
- **成功演出：** 从打呼的狗旁边走过，忍者踮脚走猫步（喜剧镜像）
- **参数：** 感知圈 80 px；鱼肉吸引半径 200 px；拴住 20s；狗必须使用离散路线（`Pen→SmellFish→Follow→BarkStop→Return`），禁止 NavigationAgent 自由追猫——"狗蠢"必须可预测
- **素材：** `Actor/Animal/Dog*` 6 种；`Items/Food/Fish.png`；`Audio/Sounds/Creature/Dog.wav`

## 4.6 炸药桶 Dynamite

- **触发：** 忍者路过手贱敲一敲 → 引线震开 → 爆炸，-1 心，炸成黑脸
- **犹豫窗口：** 无（手贱是即时的）——须提前处理
- **解法：** 推进旁边水里（受潮哑弹漂走）/ 咬断引线变无害摆件
- **失败演出：** 轰！黑脸忍者从烟雾里走出来，抖了抖，继续走（假装无事发生）
- **成功演出：** 路过水里漂着的炸药桶："受潮的东西也配挡我。"
- **参数：** 爆炸半径 48 px（猫在半径内被气浪掀飞 1 秒，不扣血——喜剧风险）
- **素材：** `Items/Projectile/CrateDynamite.png`、`Dynamite.png`；爆炸 `FX/Elemental/Explosion`；引线 Line2D + `FX/Particle/Spark.png`；气浪 `FX/Smoke/SmokeCircular`

## 4.7 铁蒺藜阵 Caltrop

- **触发：** 忍者自信走过散落一地的铁蒺藜 → 扎脚，-1 心，单脚跳 10 秒
- **犹豫窗口：** 2 秒（他蹲下研究了一下，结论："摆错位置了，伤不到我。"）
- **解法：** 猫把蒺藜一颗颗拨/拍到路边草丛（每颗 0.3s，共 4–6 颗，"耗时型"解法，考验时间管理）/ 或推木板/空箱盖上去当桥
- **失败演出：** 嗷的一声蹦起来，单脚跳，蒺藜挂在脚底，走两步抖一下
- **成功演出：** 走过干净路面："我说了吧，摆错位置了。"
- **参数：** 草丛藏身点复用可破坏草
- **素材：** `Items/Projectile/Caltrop.png`；拍飞 `FX/Attack/Claw` / `ClawDouble`（猫爪特效，正好切题）

## 4.8 守门武士 Boss 三机关（L12 专用，详见 §6.3）

猫无法伤害 Boss。三机关：**A 吊车货箱**（战前咬绳，`boss_crane_ready`，-40 HP）/ **B 酒葫芦下药**（战前拍药进葫芦，`boss_gourd_ready`，Boss 开场离席 10s）/ **C 蒺藜撒冲锋线**（**Phase 2 战中实时处理**，`boss_caltrop_ready`，-30 HP）。

- 全做完（A+B+C）：忍者满血一剑收尾，吹牛素材拉满
- 任意 2 个：常规胜利，忍者 ≥2 心
- 任意 1 个：险胜（忍者 1–2 心），吹牛变"我让了他三招"
- 0 个：必须提供明确失败或触发 Emergency Rescue

**部分完成演出规则：** 忍者苦战险胜时，吹牛台词自动降级为"我让了他三招"（由 EventLog 惊险度驱动）。

---

# 第五部分 · 关卡总览（3 章 × 4 关 = 12 关）

## 5.1 12 关总表

| 章节 | 关卡 | 名称 | 核心关键词 | 玩家学到什么 | 主路线标签 |
|---|---|---|---|---|---|
| 第一章·村庄（行动） | L01 | 第一份差事 | 教学 | 提前处理 | ACTION_BASIC |
| | L02 | 他总是踩同一个坑 | 赶场 | 连续事件 | ACTION_RUSH |
| | L03 | 谁在看猫 | 怀疑 | 被看见 ≠ 怀疑 | SUSPICION |
| | L04 | 村口大事故 | 小型联动 | 事件顺序 | ORDER_BASIC |
| 第二章·码头（规划） | L05 | 月夜码头 | 搬运 | 东西要在正确位置 | CARRY |
| | L06 | 狗也能当队友 | NPC 联动 | 利用第三方 | NPC_LINK |
| | L07 | 谁先走 | 因果链 | A 改变 B | DEPENDENCY |
| | L08 | 最后一班船 | 多线程 | 顺序 + 资源冲突 | MULTI_THREAD |
| 第三章·天守阁（操纵） | L09 | 雷雨夜 | 压力 | 场景噪声下读路线 | PRESSURE |
| | L10 | 炸药不能乱碰 | 连锁事故 | 看事件之后 | CHAIN_REACTION |
| | L11 | 越靠近城门越忙 | 多线程 | 提前准备 + 中途补救 | MULTI_THREAD_HARD |
| | L12 | 守门武士 | Boss | 战前准备 + 战中操作 | BOSS |

**玩家心态曲线：**

```text
第一章：学会行动  → "我得跑快点。"（从"跟着忍者走"变成"跑到他前面"）
第二章：学会规划  → "我得先做对的事。"（"让整个码头替自己工作"）
第三章：学会操纵  → "我得让整个场面按我的顺序发生。"
最终：            "我知道整个舞台什么时候会发生什么。"
```

**扩关原则：** 不靠新增按键或随机关卡，靠旧机制重组、事件顺序、NPC 联动、资源冲突、连锁事故、固定 Variant B、章节挑战。内容生产公式：**1 个新关系 + 2 个旧机制重组 + 1 个高风险方案 + 1 个新的忍者误解 + 1 个结算笑点**。目标内容量：约 1 套核心操作 + 8~10 种核心事件组件 + 12 套事件组合 + 12 个 Variant B + 3 个章节挑战。

## 5.2 初始时间基线（首轮调平起点，8 人试玩后冻结）

> 以下取 v1.2.5 DataResource 配置表（较新）为当前基线；v1.2 Level Bible 给出的数值部分关卡高 5–15s（L01/L05/L08 两表持平），两者都非最终冻结值。

| 关卡 | L01 | L02 | L03 | L04 | L05 | L06 | L07 | L08 | L09 | L10 | L11 | L12 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 事件数 | 3 | 3 | 4 | 4 | 6 | 5 | 5 | 6 | 4 | 4 | 7 | 3+Boss |
| Target | 60s | 55s | 65s | 70s | 85s | 80s | 95s | 110s | 90s | 100s | 120s | 125s |

口径：事件数不含 Goal，为白盒基线（以 §6 详设为准）；制作中调整事件数必须同步更新 LevelData 与本表。

## 5.3 Variant B 规范

Variant B 是**确定性脚本变体，不是随机地图**。只允许改变：Route 分支 / NPC 起始位置 / Event 时间窗口 / 资源初始位置 / 一条依赖关系。禁止改变：操作方式、核心失败语义、三猫爪公式、EventLog schema。命名：`L01_VA / L01_VB … L12_VA / L12_VB`。

## 5.4 章节挑战（只给称号/结算徽章/额外台词，不给强力数值）

- **CH1《不慌》**：整章不使用疾跑
- **CH2《借力打力》**：整章至少完成 3 次 NPC 联动
- **CH3《还得是我》**：Boss 战后半程至少 1 次战中机关操作，且不触发 Emergency Rescue

## 5.5 进度与重玩

```text
L01-L04 → Chapter 1 Clear → L05-L08 → Chapter 2 Clear → L09-L12 → Final Clear
Hard Mode：完成全部 12 个主线关解锁
Hard+：全部 12 关获得 3 猫爪解锁
```

Hard Mode 参数（LevelModifier）：`Ninja +10% / 犹豫 -0.5s / Boss Prepare -2s / 怀疑收益 +10% / 提示减少`。**Hard Mode 不增加新操作**；如果 Hard 的难点只能解释成"手速更快"，则需要返工。

每关至少提供：稳健解 / 风险解或捷径解 / 1 个明显可优化的路线点。不使用随机地图。

---

# 第六部分 · 关卡详设（白盒蓝图）

**统一白盒规则：**
- 坐标 `G(x,y)` = TileGrid 格坐标，原点左上角；第三章以 px 标注（Tile 32×32）
- 场景固定层级：`LevelRoot ├ Environment ├ Navigation(CatWalkable/CatTunnel/JumpPoints) ├ NinjaRoute(RoutePoint_00..N) ├ EventPoints ├ Actors ├ Carryables ├ Collectibles ├ Audio ├ Cameras ├ Debug`
- 忍者不用自由寻路：白盒直接放置 RoutePoint 锚点，EventPoint 与 RoutePoint 用引用关联
- **每关至少 1 条 CatTunnel（L08 两个）；捷径只缩短猫的移动，不改变 Ninja Route，不直接给出答案；禁止用 JumpPoint 绕过所有事件**
- 图例：`S 出生 / N 路线锚点 / E 事件点 / C 可搬运 / T 猫洞 / J 跳跃点 / G 终点 / V 守卫视线 / D 狗 / P 毒雾 / # 墙 / . 地面 / ~ 水 / * 风险路径`
- 白盒阶段禁止：先做精美背景/复杂特效/完整 UI/大量台词/为"看起来丰富"加按钮。生产顺序：`路线→事件→依赖→时间→失败→Reset→Gate→Art→Audio→Settlement`

## 6.1 第一章·村庄篇（L01–L04）

### L01《第一份差事》 — 教学关（26×14 tile）

**关卡职责：只回答一个问题——"为什么我必须跑到忍者前面？"** 第一次玩家无需文字帮助就能发现第一个危险。

- **区域：** Start G(2,6)~G(6,10) → 绊绳巷 G(7,4)~G(11,10) → 守卫广场 G(12,3)~G(18,10) → 小水沟 G(19,5)~G(23,10) → Goal G(24,6)~G(25,9)
- **路线：** N00 Start → N01 巷口 → N02 绊绳 → N03 广场 → N04 守卫 → N05 水沟 → N06 Goal
- **事件：** E01 Tripwire（咬断 / 风险解 LAST_SECOND_BITE）→ E02 Guard（喵叫引开 / 风险解贴身绕行，守卫初始视线朝右）→ E03 Watergap（推箱 / 风险解临界跳跃）
- **时间线（白盒初值）：** T+00 出发 → T+12 绊绳危险 → T+18 守卫危险 → T+30~33 水沟犹豫 → T+40~50 Goal
- **教学事件规格：** E01 无犹豫窗口，猫 48px 内 E 交互 0.8s，失败 `FAIL_TOO_LATE`；E02 忍者等 3.2s，F 喵叫立即解决（喵叫不产生怀疑）；E03 等 3.2s，推箱至锚点（推距折算约 1.2s）
- **失败出口：** `FAIL_TOO_LATE / FAIL_NINJA_DEATH / FAIL_TIMEOUT`
- **演出节拍：** 开场忍者抱猫举高"等我的好消息"，放下时猫翻白眼（第一个笑点）；读图字幕"他看不见的危险，都归你管。"；终点猫跳上屋檐俯视，夕阳
- **L01 不允许出现：** 第二条等价主路线 / 多个可搬运物争抢 / 多名守卫 / Dog / Poison / Caltrop / Boss

### L02《他总是踩同一个坑》 — 赶场（30×14 tile）

**关卡职责：第一次让玩家发现"跟着忍者跑，必然来不及"。**

- **结构：** Start → Narrow Alley → Plaza → Waterline → Goal，含 Shortcut（JumpPoint + CatTunnel）
- **事件链：** E01 Tripwire →（6~8s）→ E02 Guard →（5~7s）→ E03 Watergap；E01 处理后忍者立即继续，不给安全休息时间
- **Variant B：** 只改 Guard 起始位置 / 路线方向 / E02 触发偏移；禁止新增事件
- **QA 关键：** 观察测试者是否"跟着忍者跑 → 发现来不及 → 第二次主动提前跑"。若大量玩家贴忍者跑且不认为有问题，调整 E01→E02 距离与忍者节奏，**而不是给文字提示**
- **失败出口：** `FAIL_TOO_LATE / FAIL_WRONG_ORDER / FAIL_NINJA_DEATH`

### L03《谁在看猫》 — 怀疑教学（32×16 tile）

**关卡职责：单独建立 Suspicion 心智模型。** 不以敌人杀伤制造压力，以"暴露管理"制造压力。

- **区域：** Start → Guard Vision Yard → Crate Yard → Emote Shelter → Watergap → Goal
- **事件：** E01 GUARD_PASSIVE（安全走过视线，证明"看到猫"≠怀疑）→ E02 STEAL_CRATE（箱子在守卫视线边缘：偷箱→怀疑+→跑出视线→停止累积→卖萌→清零）→ E03 EMOTE_CHECK（安全卖萌位，让玩家自己发现"卖萌是资源"）→ E04 WATERGAP
- **QA 五态矩阵（必测）：** 被看见没做事=不加 / 被看见搬箱=加 / 搬完马上离开=停止累积 / 离开后不卖萌=保留 / 离开后卖萌=清除
- **Godot 锚点：** SuspicionEmitterVolume / SuspicionObserver / EmoteSafeZone 三节点独立于 Guard Actor，以便换 NPC 不改关卡逻辑
- **必测行为：** 至少一半测试玩家主动尝试一次卖萌

### L04《村口大事故》 — 第一章高潮（34×18 tile）

**关卡职责：第一次真正解"顺序题"。**

- **事件依赖：** Guard A → Tripwire → Crate → Watergap（改变 Guard 位置会改变后两个事件窗口）
- **两条有效主路线（都必须能通关，不把 B 标成"正确答案"）：**
  - Route A 稳健：E01 Guard → E02 Tripwire → E03 Crate → E04 Watergap（风险低/时间正常）
  - Route B 快捷：E02 Tripwire → E01 Guard → Cat Shortcut → E04 Watergap（移动压力高/时间更快）
- **失败设计：** 禁止"错误顺序 = 永久 Softlock"；允许"错误顺序 → 当前事件失败 → 忍者 HP 受损或路线变化 → 玩家理解原因 → Reset"
- **章节结算：** L04 完成后触发第一章总结（居酒屋吹牛 + 统计"提前处理次数/险中救场次数/怀疑最高值" → 解锁第二章），不加额外强力数值

**第一章通过标准：** Ninja Route 无自由寻路依赖 / EventPoint 可独立测试 / Reset 无残留 / 玩家可提前赶场 / 失败原因可解释 / 无不可逆 Softlock / L04 双主路线成立 / L03 怀疑五态矩阵全通过 / Blind Test 达标 / LevelValidator 全绿。

## 6.2 第二章·码头篇（L05–L08）

本章新空间对象：CarryPoint / DogRoute / GuardRoute / DependencyLink / SafePocket / CatTunnel。**不增加新玩家按键，"新鲜感"来自关系和顺序。** 第二章统一 WorldState 词表：`guard_a_departed / guard_b_active / dog_fed / dog_distracted / dog_returning / fish_taken / fish_consumed / bridge_open / bridge_blocked / poison_route_safe / antidote_placed / caltrop_ready / ship_window_open`。

### L05《月夜码头》 — 搬运教学（42×24 tile）

**核心问题："我有东西，但我要把它送到正确的位置。"** 首次正式学习 Q 叼取/放置。

- **区域：** Dock Start → Fish Crate Yard → Guard A Pier → Dog Yard → Broken Bridge → Poison Marsh → Guard B Jetty → Goal Boat
- **因果链：** FishPicked → DogDistracted → Guard A 路线保持畅通 → 到桥 → Antidote delivered
- **事件：** E01 FishPickup（Q，叼取后 ×0.85）/ E02 GuardA（F 喵叫）/ E03 Dog（鱼引开；风险解猫当诱饵）/ E04 BrokenBridge（需 CratePlaced=true）/ E05 Poison（明显的毒雾视觉+药瓶交互，不用数字 UI 告诉答案）/ E06 GuardB（白盒必须有 Route_A/Route_B 两段）
- **资源约束：一次只允许携带一个 Carryable**——本关首次产生可感知的资源占用
- **目标体验：** 第一次完成时玩家可能只会逐个解决；通关后应意识到"下次我应该先拿东西"
- **QA：** 猫能拿 Fish / Q 后减速 / Dog 进 Distracted / Guard A 可变位 / Bridge 由 WorldState 打开 / 毒雾成败可重复 / Guard B 不自由寻路 / 猫捷径忍者不可入 / Reset 清 Flag

### L06《狗也能当队友》 — NPC 联动（46×26 tile）

**核心：NPC 可以成为工具。** 狗从"障碍"转成"移动工具"。

- **标准解：** 拿鱼 → 喂狗 → 狗离开守卫主线 → Guard 位置稳定 → Ninja 通过
- **风险解：** 不喂狗 → 猫进 Guard 区制造干扰 → 狗追猫 → Guard 被吸引 → Ninja 另一侧通过（`high_risk=true, risk_style=RISKY`）
- **铁律：两条路线都必须能完成任务，风险解不得成为唯一优解**；SAFE/BALANCED/RISKY 由玩家操作生成，不是关卡贴标签
- **事件：** E01 FISH_SOURCE / E02 DOG_PEN / E03 GUARD_A / E04 GUARD_B / E05 BRIDGE_FORK / E06 GOAL
- **评分注意：** 高风险解可触发 `high_risk_rescue`，但**不允许靠故意让忍者低血刷 3 猫爪**
- **QA Gate：** 新玩家多数应尝试一次 Fish→Dog，否则说明狗的"可利用性"读图不足

### L07《谁先走》 — 因果链（48×26 tile）

**核心问题："不是我会不会处理，而是我先处理谁。"** 第二章核心逻辑关。

- **依赖链：** Guard A 离岗 →（+8s）→ Guard B 换岗 → Dog 路线改变 → Bridge 窗口改变 → Poison 窗口改变
- **事件图：** E01 GuardA →（W01 guard_a_departed）→ E02 GuardB →（W02 guard_b_active）→ E03 Bridge →（W03 bridge_open）→ E04 Poison
- **地图要求：** 每个事件之间必须让玩家能看到下一个事件区域——"解谜答案不许藏在视野之外"
- **错误必须"合理"：** 先处理 Guard B 不弹"顺序错了"，而是世界产生后果（Guard B 提前站位 → Bridge 被堵 → Ninja 改走 Poison 路线 → 进入危险），玩家自己从结果推断顺序。**允许做错一次，通过明确后果理解，不直接 Softlock**
- **标准解：** Guard A → Guard B → Bridge → Poison → Goal；**风险解：** Guard A → Dog → Guard B → Shortcut → Bridge
- **QA：** 测试者失败后必须能回答"我为什么要先处理 Guard A？"——可以用自己的语言，但必须指出后续状态变化

### L08《最后一班船》 — 第二章高潮（54×28 tile，首个横向多线程地图）

**目标：同时面对 资源有限 + NPC 联动 + 事件顺序 + 时间窗口 + 风险选择。**

- **区域：** Start / Fish&Crate Yard / Guard A Pier / Dog Yard / Broken Bridge / Poison Marsh / Guard B Jetty / Caltrop Dock / Final Boat
- **三条工作线最后汇合：** 守卫线（Guard A→B）/ 动物线（Fish→Dog→Guard Position）/ 运输线（Crate→Bridge→Poison→Goal）
- **资源冲突：** 关键道具各只有 1 个刷新点（Fish×1 / Crate×1 / Antidote×1），Antidote 可服务两个用途但只能选一个——**必须确保另一种用途仍有替代解，否则是假多解**。核心体验："我现在拿的这个东西，会影响十秒后的决定。"
- **船离港计时器：** `SHIP_WINDOW = 90~120s`，只控制 Goal 可进入窗口，**不直接倒计时致死**（避免被理解成传统限时跑酷）
- **蒺藜在本关只是 STANDARD：** 迫使玩家留意忍者下一阶段路线，不做成复杂机制
- **章节终关演出：** 忍者到船边，船夫看过来 → 忍者摆 pose，风吹起斗篷 → 猫蹲在货箱上。"我一到码头，连海风都顺着我吹。"猫："……"
- **目标：** 玩家完成后应能说出"我刚才不是在做七件事，是在安排七件事"

**第二章完成定义：** L05 理解搬运 / L06 理解 NPC 可利用 / L07 理解事件顺序 / L08 能同时管理至少两条工作线 / Dog 全状态稳定 / Guard A/B 路线稳定 / Bridge/Poison 状态稳定 / 所有失败产生 FAIL_CODE / Reset 正常 / Variant B 可重复 / LevelValidator 全绿 / Playtest Gate 通过。

## 6.3 第三章·天守阁篇（L09–L12）

统一规范：Tile 32×32；主路线宽 96–128 px，猫捷径 48–64 px，EventTrigger 宽 64–96 px，边界 32 px 缓冲。忍者第三章基础可用得意状态 66 px/s + 更短犹豫窗口作为压力来源。本章统一 WorldState 词表：`dynamite_a_safe / dynamite_b_safe / guard_a_departed / guard_b_active / dog_fed / poison_route_safe / caltrop_cleared / boss_crane_ready / boss_caltrop_ready / boss_gourd_ready / boss_phase / boss_retreat / emergency_available`。

### L09《雷雨夜》 — 环境压力（1536×896 px）

**核心：环境压力第一次明显提升。不教新操作，只提高读取节奏。**

- **区域：** 南侧入口 → 雨巷 → 木箱堆场 → 炸药区 → 北门守卫区 → 内城入口
- **事件：** E09_TW 绊绳 STANDARD（窗口 1.5s——trigger_window；绊绳 hesitation_time 恒为 0，见 §4.1）/ E09_DY 炸药桶 CRITICAL（0s）/ E09_GA 守卫 CRITICAL（2.0s）/ E09_DOG 狗 STANDARD（2.5s）/ E09_GOAL 北门取卷轴
- **核心因果链：** 炸药未处理 → 忍者敲桶 → 爆炸 → Guard A 警觉改巡逻 → Ninja 进入 Dog 路线
- **稳健解：** 先炸药 → 引开 Guard A → 鱼喂狗 → 终点；**风险解：** 最后一刻推桶入水，借爆炸声诱导 Guard A（风险解必须有明确收益，不得成为唯一正解）
- **捷径：** S09_01 CatTunnel 雨棚下；S09_02 JumpPoint 木箱堆垛
- **表现红线：** 雷雨（Rain/Thunder Flash/Darkness Tint）不得遮挡 Ninja / EventPoint / Cat；**玩家不应因为纯视野恶化而失败**

### L10《炸药不能乱碰》 — 连锁事故（1664×960 px）

**核心：第一次认真预测"我处理这个事件之后，谁会改变状态？"**

- **事件链：** 炸药 → Guard A 换位 → Dog 受惊 → Ninja 改线 → 蒺藜窗口提前
- **第二条链（"正确处理 A 反而关闭 B"）：** 狗被鱼吸引离开 → Guard A 不再被狗声吸引 → 保持岗位 → Ninja 被迫进入 Poison 路线
- **解 A 稳定：** 先炸药 → Guard A 离岗 → 鱼引狗 → 提前放解毒药 → 过 Poison；**解 B 高风险：** 不提前解毒，Ninja 触发 Poison 前 4 秒叼药高速赶路滚药，与 Guard A 回位时间错峰
- **EventLog 必须写入：** `caused_event_id / world_changes / route_change`（如 `E02.caused_event_id = E03`）——失败必须可追溯因果
- **捷径：** S10_01 RoofJump（炸药仓顶部 → Dog 院，猫专用）
- **Variant B：** 仅改炸药起始位置，因果关系不变

### L11《越靠近城门越忙》 — 多线程压力测试（1920×1088 px）

**核心：Boss 前最后一关，验证同时处理三条任务线。这一关不应该比 L12 更难——任务是让玩家进 Boss 前已经习惯多线程。**

- **三线程：** 守卫线（Guard A→B→Goal，地标=城墙/门）/ 动物线（Dog→Guard Noise→路线偏移，地标=庭院/犬舍）/ 环境线（Dynamite→Caltrop/Bridge→Poison，地标=箱区/毒雾）
- **事件（7 个）：** E11_GA CRITICAL / E11_GB STANDARD / E11_DOG CRITICAL / E11_DY1 CRITICAL / E11_CAL CRITICAL / E11_POI CRITICAL / E11_CLI STANDARD
- **设计核心：** 玩家一次只能持续操作一个事件，必须学会"处理 A 一半 → 放弃 → 赶去 B → 再回来完成 A"——**首次验证"互动可打断"的实际价值**
- **三阶段节奏：** Phase A 准备 → Phase B 移动中补救 → Phase C 入口冲刺；**不能要求玩家提前把全部事情处理干净**——至少保留 1 个中途事件 + 1 个最后窗口事件，确保一直"赶场"
- **捷径：** CatTunnel 排水沟 / JumpPoint 西屋顶 / FenceGap 猫专用小缝
- **解法：** 稳健（Dynamite→GuardA→Dog→Poison→GuardB→Goal）/ 调度（Guard A 声引→立刻转 Dog→回来完成炸药→利用 Guard B 窗口走 Poison）/ 极限（故意让普通事件进临界，最后一秒补救拿 `high_risk_rescue` 压缩总时长）

### L12《守门武士》 — Boss 最终考试（1792×1024 px）

**核心：不是新系统展示，而是验证 提前准备 + 事件排序 + 空间捷径 + 战中补救。**

- **Arena 分区：** R0 Approach / R1 Gourd Platform / R2 Crane Platform / R3 Boss Intro / R4 Charge Lane / R5 Caltrop Storage / R6 Ninja Combat Zone / R7 Emergency Door
- **Boss 状态机：** `BOSS_INTRO → BOSS_PREPARE → BOSS_PHASE_1 → BOSS_PHASE_2 → BOSS_PHASE_3 → BOSS_DEFEATED / BOSS_RETREAT`
- **三机关：**

| 机关 | 处理时机 | 效果 | 数据 |
|---|---|---|---|
| A 吊车 | 战前准备（咬绳 0.8s） | Phase 1 触发，Boss HP -40 | `crane_damage=40, prepare_only=true, phase_trigger=BOSS_PHASE_1` |
| B 酒葫芦 | 战前准备（拍药进葫芦） | Boss 开场离席 10s，忍者获得安全输出窗口 | `gourd_delay=10.0, prepare_only=true, phase_trigger=BOSS_INTRO` |
| C 蒺藜 | **Phase 2 战中实时**（Boss 冲锋准备 → 猫移动到蒺藜堆 → 撒到冲锋线 → Boss 踩中） | Boss HP -30 | `caltrop_damage=30, phase2_caltrop_window=3.0, validator=BOSS_PHASE2_ACTION` |

- **铁律：B03 不得在 Boss 前就完全失去价值；Phase 2 必须由玩家主动移动处理蒺藜**——防止"提前准备完就看戏"
- **Phase 3：** Boss HP ≤30 → 忍者收尾动画；HP >30 → 苦战可能扣至 2 心；条件失败 → Emergency/Retreat
- **Emergency Rescue（Fail-safe，不是第四机关，不产生额外资源奖励）：** Boss Finisher 前且忍者 HP ≤1 → Emergency Door 开启 → 玩家 1.5–2.0s 窗口触发 → 忍者保 1 HP → Mission Complete → 只给 1 猫爪
- **组合测试矩阵（必须全覆盖）：** A+B+C / A+B / A+C / B+C / A / B / C / None / Emergency。结果：A+B+C=满血完胜；任意 2=常规胜利（≥2 心）；任意 1=险胜（1–2 心，可补救）；0=明确失败或 Emergency
- **Boss Gate：** 至少 60% 测试玩家在 Boss 已开始行动后继续主动移动；若玩家普遍变成"把机关全弄完然后看 Boss"，**Boss 结构返工，而不是继续调数值**

---

# 第七部分 · 结算：居酒屋吹牛（招牌画面）

## 7.1 演出时间轴

```text
忍者进门 → 拍桌 → 动态吹牛 → 老板娘反应 → 幕后蒙太奇（可选回放小窗）
→ 镜头下移：猫在桌下/柜台舔爪，头顶"……"气泡
→ 猫爪评价弹出 + 固定吐槽字幕"他信了。他们又都信了。"
→ 表现标签（Risk Style）→ 下一关（Space）/ 重玩（R）
```

**重复挑战压缩规则：** 默认压缩为"吹牛一句 → 猫舔爪 → 猫爪"，长度 8–12 秒；玩家可主动展开完整结算。

**品牌记忆点：** 第三章（最终关）结算固定一句——**"他还是不知道。"**

## 7.2 吹牛生成管线（纯模板拼接，不接 LLM）

```text
EventLog 事件记录
→ Importance 分级
→ Tags 匹配（banter_tags）
→ Compatible Template 选择
→ 填充参数（数量/威胁名/夸张动作/荒谬结果）
```

- 每个被玩家暗中处理掉的威胁 → 一条吹牛句式。**程度副词由"惊险度"决定：处理得越晚越惊险，他吹得越离谱。**
- 模板示例：`"那{数量}重{威胁名}阵？我{夸张动作}它就{荒谬结果}。"` → "那三重陷阱阵？我一个眼神它就自己散了。"
- 模板优先级：`Emergency > Near Death > Boss > Chain > Route Change > Normal Success`
- 老板娘固定捧场/拆台台词池："哎哟，大人好厉害～"（棒读）
- **重复率控制：** 同一关连续三次通关，不得连续出现完全相同的：忍者开场语句 / 主要吹牛模板 / 老板娘反馈 / 最终吐槽。模板池按 事件类型 + 风险等级 + 忍者 Personality + 本局行为 选择。

## 7.3 回放与分享（RC OPTIONAL）

- **回放小窗：** 右上角静音循环播放本关玩家操作 10 秒剪辑——他吹牛的每句话旁边对照你实际干的事。短视频传播核心画面，预留 GIF 导出接口。
- **分享卡格式：** 评价 ★★★ / 忍者吹牛引文 / "幕后真相：猫完成了 7 次救场 / 最高怀疑：43 / 最后一秒救场：1 次" / 8 秒关键回放——目标"让别人一眼看懂到底哪里好笑"。

## 7.4 三猫爪评分公式（12 关统一，不允许每关重写算法）

- **Paw 1：** `mission_complete`
- **Paw 2：** `mission_complete AND ninja_hp >= 2 AND max_suspicion < 80`
- **Paw 3：** 基础资格 `mission_complete AND ninja_hp >= 2`，另需普通关 A–F 满足 4 项 / Boss 关 A–G 满足 4 项：

```text
A = ninja_hp == 3
B = max_suspicion < 50
C = elapsed_time <= target_time
D = high_risk_rescue >= 1
E = chain_rescue >= 1
F = shortcut_or_dependency_mastery == true
G = boss_mechanics_success >= 2        （仅 L12）
```

**保护规则：** `ninja_hp < 2` 永不可得 3 爪（防止靠故意卖血刷高风险救场）。唯一允许的关卡差异：target_time / 事件标签 / Boss 额外条件。

### 7.4.1 12 关 Paw3 条件启用表

**规则：** 每关启用条件数必须 ≥ paw3_required_count(4) + 1，由 LevelValidator 强制检查。

| 关卡 | 启用的 Paw3 条件 | 说明 |
|---|---|---|
| L01 | A, B, C, D, F | 白盒需新增 1 个 JumpPoint 木箱捷径以启用 F，不改变教学结构 |
| L02 | A, B, C, D, F | E（chain_rescue）不可达 |
| L03 | A, B, C, D, F | E 不可达 |
| L04 | A, B, C, D, E, F | 全启用 |
| L05–L11 | A, B, C, D, E, F | 全启用 |
| L12 | A, B, C, D, E, G | G 仅 L12；F 可选（若竞技场加捷径则启用） |

条件图例照抄 §7.4 的 A–G 定义。

---

# 第八部分 · UI / HUD 与教学

## 8.1 HUD 五要素（常驻只有这些）

```
┌──────────────────────────────────┐
│ [忍者情绪气泡]        [怀疑·猫眼表盘] │
│                                  │
│            （游戏画面）            │
│                                  │
│ [疾跑体力]  [口中道具]  [喵叫][卖萌]│
└──────────────────────────────────┘
```

1. **忍者方向**——屏幕边缘箭头（`Ui/Arrow.png`），颜色随心情变化；玩家要随时知道"他走到哪了、心情如何"
2. **忍者情绪**——情绪气泡（`Ui/Emote`）
3. **怀疑猫眼**——不用数字条："半睁的猫眼"瞳孔随怀疑值开合（shader 程序化绘制，保持喜剧调性）
4. **疾跑体力**——`Ui/Receptacle/LifeBarMini*.png`
5. **情境操作**——交互提示 `Items/Action/Interact.png` 在可互动物上浮现；按键图标用 `Ui/Input/Keyboard`

**HUD 禁令（HUD 告诉事实，不告诉答案）：** 禁止"建议先处理 / 请前往 / 正确解法 / 危险排序提示"。

## 8.2 反馈层级制（信息重要性 = 反馈强度）

- **一级（危机）：** 忍者濒死 / Boss Finish / 怀疑 80+ / Emergency
- **二级（关键变化）：** 受伤 / Boss HP / Route Change / WorldState 变化
- **三级（普通）：** 机关成功 / 收集
- **四级（装饰）：** 雨 / 灰尘 / 水面

**装饰永远不能抢玩法反馈。**

## 8.3 教学 / FTUE 细则

- **30 秒内必须完成：** 看到猫 / 看到忍者 / 获得移动 / 看到第一个危险 / 主动前往危险点
- 第一次成功拆绳必须马上获得：清晰 SFX + 绳断动画 + 忍者继续前进 + 自我吹牛
- 第一次怀疑必须演示"被看到 ≠ 死"：问号 → Ctrl 卖萌 → 怀疑归零，而不是第一次被看到就失败
- 第一次结算不先显示数字，先告诉玩家：**"他以为是自己做的。"** 再显示猫爪
- **不做传统教程菜单。** 所有教学都通过：情境 + 单句提示 + 实际操作完成。第 1 章教完全部猫能力（咬/叫/推/卖萌），第 2 章教叼取，第 3 章不教新东西只加压力

---

# 第九部分 · 音频设计

## 9.1 Bus 与优先级

```text
Master
├─ BGM
├─ SFX
├─ Voice
├─ UI
└─ Environment
```

优先级：`MISSION FAIL > CRITICAL WARNING > NINJA HURT > SUSPICION > EVENT SUCCESS > VOICE > ENVIRONMENT`

## 9.2 曲目与音效指派（全部素材包现成）

| 场景/事件 | 音轨/音效 |
|---|---|
| 第一章·村庄 | `Musics/23 - Road.ogg`（备选 `26 - Lost Village.ogg`） |
| 第二章·码头 | `Musics/18 - Aquatic.ogg` |
| 第三章·天守阁 | `Musics/10 - Dark Castle.ogg` |
| Boss 段 | `Musics/28 - Tension.ogg` |
| 居酒屋结算 | `Musics/20 - Good Time.ogg` 或 `27 - Chill.ogg` |
| 读图阶段 | 音乐渐弱 + `Audio/Jingles/Secret1.wav`（"要开始了"） |
| 忍者语气音（哼/嗯？/呜哇） | `Audio/Sounds/Voice/Voice1~10.wav` 按需分配 |
| 狗叫 | `Audio/Sounds/Creature/Dog.wav` |
| 卖萌成功 | `Audio/Jingles/Secret2.wav`（叮——） |
| 自我消解台词 | 配一声 `Audio/Sounds/Bonus/Bonus.wav`"恍然大悟"音 |
| **得手签名（只有玩家听得到）** | `Audio/Sounds/Bonus/PowerUp1.wav` 音量压到 20% |
| 忍者扣血/踩坑 | `Audio/Sounds/Hit & Impact` + `Alert` 系列 |
| 爆炸 | `Audio/Sounds/Elemental` 爆炸音 |
| 评分弹出 | `Audio/Jingles/Success1~4.wav`（按星级递进） |
| 雷雨氛围 | `Audio/Sounds/Ambient` + Thunder One-Shot + Rain Loop |

**音频喜剧原则：** 得手签名音是《猫忍不住》的声音识别点——"全场只有玩家知道真相"。

## 9.3 唯一素材缺口

**猫叫声效（F 喵叫）。** 包内 Creature 只有 Bird/Dog/Duck/Wings。选项：freesound 免费音效外补 / 录音合成 / `Voice*.wav` 变调凑合（最省钱但效果存疑）。见 §15.1 待决策。

---

# 第十部分 · 美术素材映射（Asset Manifest，唯一入口）

**约束：全部取自 `Ninja Adventure - Asset Pack/`，不为每关制作新素材，优先重新组合 + 环境调色。** 资产状态枚举：`Missing / InProgress / Ready / Locked`。

| 用途 | 素材路径 | 备注 |
|---|---|---|
| 玩家猫（默认） | `Actor/Animal/CatBlack/SpriteSheetYellow.png` | CAT_BLACK |
| 猫皮肤 ×4 | `Cat` / `CatOrange` / `CatWhite` / `CatCyclop` | 数值相同 |
| NPC 忍者 | `Actor/Character/NinjaBlue`（备选 `CharacterAnimated/NinjaGreen`） | |
| 忍者人格变体（后续章节） | `Actor/Character/NinjaRed`、`NinjaGreen` 等 14 种 | RC OPTIONAL |
| 守卫 | `Actor/Character/SamuraiBlue` / `SamuraiRed` | |
| Boss | `Actor/Boss/GiantBlueSamurai`（备选 `TenguRed`） | |
| 恶狗 | `Actor/Animal/Dog*` 6 种 | |
| 老板娘 | `Actor/Character/Woman` / `OldWoman` | |
| 渔网（绊绳的网） | `Backgrounds/Vehicles/FishNet.png` | 绳用 Line2D |
| 木箱 | `Items/Object/CrateEmpty.png` | |
| 炸药桶 | `Items/Projectile/CrateDynamite.png`、`Dynamite.png` | |
| 铁蒺藜 | `Items/Projectile/Caltrop.png` | |
| 解毒药/泻药 | `Items/Potion/LifePot.png`（备选 `MilkPot.png`） | |
| 酒葫芦 | `Items/Object/Gourd.png` | |
| 鱼肉/小鱼干收集品 | `Items/Food/Fish.png` | |
| 吊车（Boss 机关） | `Backgrounds/Vehicles/Crane.png` | |
| 任务卷轴 | `Items/Scroll/Scroll.png` | |
| 情绪气泡 | `Ui/Emote/emote1~30.png` | 编号实现时指派 |
| 方向箭头 | `Ui/Arrow.png` | |
| 交互提示 | `Items/Action/Interact.png`、`Hit.png` | |
| 教学按键图标 | `Ui/Input/Keyboard`、`Tuto.png`（手柄 `Ui/Input/Gamepad`） | |
| 体力条 | `Ui/Receptacle/LifeBarMini*.png` | |
| 对话框 | `Ui/Dialog/DialogBox*.png` | |
| 字体 | `Ui/Font/NormalFont.ttf` | |
| 居酒屋场景 | `Backgrounds/Tilesets/Interior` + `Items/Food` 摆桌（寿司/烤串） | |
| 悬崖地形 | `Backgrounds/Tilesets/TilesetRelief.png` / `TilesetHole.png` | |
| 雷雨（第三章） | `FX/Elemental/Thunder` + `FX/Particle/Rain.png` | |
| 毒雾/流沙 | `FX/Environment/Fog.png` 染绿 + `Backgrounds/Animated/QuickSand` 染紫 | |
| 猫爪特效 | `FX/Attack/Claw` / `ClawDouble` | |
| 爆炸/烟雾/引线火花 | `FX/Elemental/Explosion` / `FX/Smoke/SmokeCircular` / `FX/Particle/Spark.png` | |
| 村庄/码头/城堡地块 | `Backgrounds/Tilesets/TilesetVillageAbandoned` / `TilesetWater` / `TilesetDungeon` 等 | |

**程序化图形许可（不违反素材约束）：** 绊绳/吊绳用 Line2D；怀疑值"猫眼"表盘用 shader；毒雾/中毒调色 shader。

---

# 第十一部分 · Meta 与进度

## 11.1 皮肤与收集

- **皮肤 5 套，数值完全相同：** 黑/橘/白/灰/独眼猫（CatCyclop）。独眼猫 = Hard+ 解锁（§15.2 仲裁）。
- **收集品：小鱼干**（`Items/Food/Fish.png`）——每关藏 3 条，共 36 条（§15.2 仲裁），藏在只有猫能钻的洞里；纯装饰成就，不影响通关。
- **彩蛋：** 特定皮肤过关触发忍者隐藏台词。

## 11.2 成就（≤15 个）

覆盖：首次通关 / 零伤 / 低怀疑 / 高风险救场 / 狗联动 / 不疾跑 / 三猫爪 / Boss 三机关 / Emergency Rescue / 全收集 等。

## 11.3 猫技艺（玩家操作履历，不是角色成长）

不解锁强力数值，只解锁结算徽章/个人统计/额外台词/猫的称号：

**与章节挑战（§5.4）的关系：** 章节挑战 = 章节级一次性称号；猫技艺 = 跨关累计的个人操作履历。两者行为相似但统计口径不同，奖励互不冲突。

- **极限拆绳**——累计 3 次在最后 1 秒内完成绊绳
- **借狗之势**——累计 5 次使用 Dog → Bark → Guard 联动
- **不留痕迹**——三章最高怀疑都 < 20
- **猫步**——累计 3 关疾跑时间为 0（跨关累计，区别于 CH1《不慌》的整章一次性挑战）
- **幕后操盘**——通过至少 3 层因果链完成任务
- **最后一秒**——完成 1 次 Emergency Rescue

## 11.4 Risk Style（只影响结算文案，不影响基础奖励）

- **SAFE**：大量提前准备 / 怀疑低
- **BALANCED**：有准备有少量抢救
- **RISKY**：多次最后窗口处理 / 高频疾跑 / 多次近距离操作

用途：结算台词、成就统计、猫技艺记录、Replay 选择。

## 11.5 存档结构（SaveData v1.2，`user://`）

```gdscript
levels_completed: Array[String]
level_results: Dictionary
chapter_results: Dictionary
hard_mode_unlocked: bool
hard_plus_unlocked: bool
unlocked_cat_skins: Array[String]
fish_collected: Dictionary
achievements: Array[String]
cat_skills: Dictionary
settings: Dictionary
input_bindings: Dictionary
```

---

# 第十二部分 · 技术架构（Godot 4）

## 12.1 实现边界

```text
Data 控内容 / Script 控行为 / Scene 控组成
EventBus 控广播 / EventLog 控 Gameplay Facts / WorldState 控世界事实
```

**不得因为 12 关而在每关复制核心行为脚本。**

## 12.2 工程目录（命名统一仲裁见 §15.2）

```text
res://
├─ scenes/
│  ├─ boot/  core/  actors/  interactables/  ui/  meta/
│  └─ levels/
│     ├─ ch01_village/  L01_first_job.tscn … L04_village_accident.tscn
│     ├─ ch02_dock/     L05_moonlit_dock.tscn … L08_last_boat.tscn
│     └─ ch03_castle/   L09_storm_night.tscn … L12_gatekeeper_boss.tscn
├─ scripts/
│  ├─ core/  actors/  gameplay/  systems/  ui/  meta/  debug/
├─ data/
│  ├─ levels/  chapters/  events/  routes/  shortcuts/  world_flags/
│  ├─ score/  variants/  boss/  banter/  audio/  achievements/
└─ tests/
```

## 12.3 Scene / Script / Data 总表

| 功能 | Scene | Script | Data Resource |
|---|---|---|---|
| GameRoot | `GameRoot.tscn` | `game_root.gd` | `game_settings.tres` |
| Level | `LevelRoot.tscn` | `level_controller.gd` | `level_data.tres` |
| 猫 | `Cat.tscn` | `cat_controller.gd` | `cat_data.tres` |
| 忍者 | `Ninja.tscn` | `ninja_controller.gd` | `ninja_data.tres` |
| 守卫 / 狗 | `Guard.tscn` / `Dog.tscn` | `npc_guard.gd` / `npc_dog.gd` | `guard_data.tres` / `dog_data.tres` |
| EventPoint | `EventPoint.tscn` | `event_point.gd` | `event_point_data.tres` |
| 可搬运物 | `Carryable.tscn` | `carryable.gd` | `carryable_data.tres` |
| JumpPoint / CatTunnel | `JumpPoint.tscn` / `CatTunnel.tscn` | 同名 `.gd` | `jump_data` / `tunnel_data` |
| 怀疑 / 评分 | Core 节点 | `suspicion_system.gd` / `score_system.gd` | `suspicion_profile` / `score_rule_data` |
| EventLog | Core Service | `event_log.gd` | schema only |
| Boss | `BossArena.tscn` | `boss_controller.gd` + `crane/gourd/caltrop/emergency` 四 mechanic | `boss_data.tres` |
| 结算 | `IzakayaResult.tscn` | `settlement_controller.gd` | `boast_template_data.tres` |

## 12.4 Data Resource 规范（要点）

**总原则：** Resource 只描述事实和参数（`route_id / trigger_event_id / caused_event_id / window_start / window_end`），**不记录攻略答案**（禁止 `player_should_go_here / correct_solution / best_route`）。WorldState 只存世界事实（禁止 `player_should_do_X`）。事件依赖用 `caused_event_ids` 表示，脚本只负责"读事实 → 写 Flag → 触发下一事件允许状态"。

**核心 Resource 类：**

- **LevelData：** `level_id / chapter_id / display_name / scene_path / intro_time / target_time / ninja_route / events[] / shortcuts[] / world_flags[] / score_rules / variant / audio_map_id / banter_set_id / difficulty_modifier / validator_rules`
- **RouteData：** `route_id / actor_id / waypoints[] / loop / move_speed / stop_points[] / branch_rules[] / return_delay / variant_routes[]`（每关唯一 route_id；Variant B 通过不同 RouteData/BranchRule 实现，不复制 NinjaController）
- **EventPointData：** `event_id / event_type / classification(CRITICAL/STANDARD/OPTIONAL) / actor_id / trigger_radius / hesitation_time / timeout / interaction_time / required_item / fail_code / success_flags[] / failure_flags[] / caused_event_ids[] / risk_level / high_risk / allow_standard_solution / allow_risky_solution / banter_tags[] / validator_rules[]`
- **ShortcutData：** `shortcut_id / entrance_marker / exit_marker / required_ability / time_saving / visibility_risk / usable_when[] / mastery_tag`
- **WorldFlagData：** `flag_id / default_value / reset_on_retry / persistent / debug_label`
- **ScoreRuleData：** `target_time / paw2_hp_min / paw2_suspicion_max / paw3_base_hp_min / paw3_required_count / condition_ids[] / boss_condition_ids[]`
- **VariantData：** `variant_id / route_overrides / event_overrides / npc_overrides / timer_overrides / suspicion_modifier / is_hard`（手工制作、可预测、数据驱动、不随机改变地图答案）
- **BossData（仅 L12）：** `boss_id / max_hp=100 / phase_durations / crane_damage=40 / caltrop_damage=30 / gourd_delay=10.0 / emergency_window=1.75 / emergency_enabled=true / phase2_caltrop_window=3.0 / retreat_on_emergency=true`
- **BanterSetData：** `set_id / template_ids[] / required_tags[] / priority / fallback_template`
- **ChapterData：** `chapter_id / display_name / level_ids[] / challenge_id / unlock_condition`（`ch01=[L01-L04] / ch02=[L05-L08] / ch03=[L09-L12]`）
- **LevelCatalog（`data/levels/level_catalog.tres`）：** 章节→关卡映射、显示名、解锁顺序、Variant 列表、Debug 跳关；不保存运行时 Node

**命名规则：** 事件 `L01_E01_TRIPWIRE`（LEVEL + E## + TYPE）；路线 `L01_ROUTE_NINJA_MAIN / L07_ROUTE_GUARD_A / L12_ROUTE_BOSS_CHARGE`；Variant `L01_VA/L01_VB`。WorldState 关卡特例前缀：`l04_gate_* / l07_dock_* / l10_castle_* / l12_boss_*`。

**加载与依赖方向（避免循环依赖）：**

```text
LevelManager → LevelData ├ RouteData ├ EventPointData[] ├ ShortcutData[]
                         ├ WorldFlagData[] ├ ScoreRuleData └ VariantData
load LevelData → load RouteData → register EventPointData → apply WorldFlagData
→ bind ScoreRuleData → load VariantData → spawn Scene
```

**LevelLoader 职责：** 从 LevelCatalog 取 level_id → 加载 LevelData → 实例化 .tscn → 注入 WorldState 初始值 → 注入 LevelModifier → 启动 EventLog → 初始化 UI。**禁止关卡脚本自己决定"下一关是谁"**（由 LevelCatalog 决定）。

**关键脚本接口：**

```gdscript
# LevelManager
func load_level(data: LevelData) -> void
func reset_level() -> void
func complete_level() -> void
# EventPoint
func configure(data: EventPointData) -> void
func activate() -> void
func resolve(action_id: StringName) -> void
func fail(code: StringName) -> void
# WorldState
func set_flag(flag_id: StringName, value: bool) -> void
func get_flag(flag_id: StringName) -> bool
func reset() -> void
# ScoreSystem / LevelValidator
func evaluate(result: RunResult) -> int
func validate(level_data: LevelData) -> ValidationReport
```

**编辑器友好：** 关键字段加 `@export_category`（Identity / Timing / Gameplay / Scoring / QA），设计师打开 .tres 即可编辑，不进脚本。

## 12.5 LevelValidator（每次提交自动跑 12 关）

```text
[ ] LevelData / RouteData / Goal / AudioMap / ScoreRule 存在
[ ] Level/Event/Route/Flag ID 唯一
[ ] 引用合法（caused_event / required_item / Shortcut marker / scene_path 存在）
[ ] success/fail 出口存在；CRITICAL 事件至少一个标准解 + 一个风险解
[ ] WorldState key 合法；Restart 清理无残留
[ ] 每关 Paw3 启用条件数 ≥ paw3_required_count + 1
L12 额外：[ ] Boss Exit [ ] Boss Phase Transition [ ] Emergency Rescue Exit [ ] Boss Mechanic >= 3
```

输出目标：`TOTAL 12 / PASS 12 / FAIL 0 / WARN <= 2`。

## 12.6 扩容禁止事项

禁止：每关复制核心脚本 / Level Script 硬编码大量 Event ID / 关卡脚本直接改 GameState / 用随机数决定忍者路线 / 用 UI 文案充当 Gameplay state / 靠"加血/减速/无限资源"硬撑难度。允许：新 LevelData / RouteData / EventData / VariantData / 新环境组合 / 新结算台词。

## 12.7 Debug 工具（Release 隐藏）

Debug Overlay 显示：`[Route] 锚点 / [Events] / [WorldState] flags / [Timing] Ninja·Event·Player ETA / [Suspicion] 当前/峰值/状态 / [Score] 三猫爪条件 / [Dependency] 事件链`。热键：`F1 Overlay / F2 强制下一事件 / F3 切换路线显示 / F4 事件范围 / F5 Reset / F6 检查点重开 / F7 触发 Variant B`。Debug Build 支持直接跳 L01–L12。

## 12.8 系统联调顺序

`Cat 移动 → Ninja 路线 → EventPoint → WorldState → NPC 状态机 → Suspicion → Score → Chapter/LevelLoader → Boss → Settlement → Save/Load → Audio → Accessibility → Polish`

## 12.9 第一条垂直切片（L01，v1.2.6）

验证闭环：`Data Resource → Scene → Controller → EventPoint → WorldState → EventLog → Score`。

- **Gate A 能运行：** 启动无脚本错误，LevelValidator 0 errors
- **Gate B 路线：** 忍者沿 waypoint 前进，到事件点停住，Resolve 后继续
- **Gate C 事件：** 猫靠近按 E 持续 0.8s → resolved → EventLog 写入 → WorldState 写入 `L01_TRIPWIRE_SAFE`
- **Gate D 失败：** 不处理超 5s → `FAIL_TOO_LATE` → 忍者 HP-1 → R 重开
- **Gate E 结算：** 到终点 mission_complete → ScoreSystem 返回 1–3 猫爪 → UI 显示
- **本 Slice 不解决：** 完整美术/动画/音频、怀疑系统、Guard/Dog、Q/F/Ctrl、Boss、Save/Load（后续 Sprint）

两者是先后关系：先按 v1.2.6 跑通不含 Q/F/Ctrl 的最小切片（Gate A–E），再由 v1.2.7 补全三事件教学闭环（含喵叫/卖萌）。L01 完整教学关（v1.2.7）追加：E01 咬绳 0.8s（48px 内）/ E02 喵叫立即解决 / E03 推箱至锚点（推距折算约 1.2s） / 怀疑近似判定（≤120px 且朝向）/ 卖萌 150px 内清零 / QA Smoke Test 7 步。第一章集成（v1.2.8）：L01→L04 Space 串联 + Chapter01_Clear 结算场景 + Enter 回 L01；QA Gate：切场不失效、R 重置、LevelValidator 四关 0 错误。

---

# 第十三部分 · 生产计划与 QA

## 13.1 总阶段与 Sprint

```text
P0 Project/System Backbone → P1 Data+Level Tooling → P2 第一章 L01-L04
→ P3 第二章 L05-L08 → P4 第三章 L09-L12 → P5 Hard/Meta → P6 Full QA → P7 RC
```

```text
Sprint 01  工程改名 + LevelCatalog + ChapterData
Sprint 02  L01-L02        Sprint 03  L03-L04
Sprint 04  L05-L06        Sprint 05  L07-L08
Sprint 06  L09-L10        Sprint 07  L11-L12
Sprint 08  Variant B + Chapter Challenges
Sprint 09  Hard / Hard+
Sprint 10  Full QA / Balance / Polish
```

按章推进（Sprint A=第一章+First Session Gate / B=第二章+Carry·NPC 联动·因果链 / C=第三章+Boss Active Gate）。**一章一章锁定，不十二关一起堆资源；先把 12 关白盒全做出来，再做第二轮美术精修。** 最小目标顺序：`能玩 → 能看懂 → 能失败 → 能重试 → 能找到更优解 → 最后才是好看`。

## 13.2 每关 Definition of Done

```text
Design   [ ] Beat Sheet 已确认 [ ] Event Graph 已确认 [ ] Route 已确认
Data     [ ] LevelData [ ] RouteData [ ] EventData [ ] Variant B
Godot    [ ] Scene 可运行 [ ] Reset 正常 [ ] Debug Jump 正常 [ ] LevelValidator 通过
QA       [ ] 标准解 [ ] 风险解 [ ] 最晚成功 [ ] 标准失败 [ ] Save/Load [ ] Variant B
Experience [ ] 玩家能解释失败 [ ] 无无意义等待 [ ] 猫始终有下一件事可做
```

**关卡负责人五问（答不上任何一条 → 回 Whitebox）：**
1. 玩家为什么要提前行动？
2. 玩家现在为什么不能直接解决全部问题？
3. 哪个事件会因为前一个事件而改变？
4. 哪个地方产生风险与收益交换？
5. 忍者最后会如何错误归因？

## 13.3 试玩 Gate（8 人样本数字化）

**Chapter 1 Gate：** ≥6 人找到首个危险 / ≥5 人主动跑到忍者前面 / ≥5 人理解被看到本身不是失败 / ≥4 人尝试卖萌 / ≥6 人能解释"猫在暗中帮忍者"。

**Chapter 2 Gate：** ≥5 人使用 Carry / ≥5 人使用 NPC 联动 / ≥5 人使用至少两次猫捷径 / ≥4 人失败后改变顺序 / ≥4 人能解释一条因果链。若普遍反馈"东西太多"而非"我顺序弄错了"——减少同屏并发事件，而不是延长时间。

**Chapter 3 Gate：** ≥5 人 Boss 前主动准备 / ≥5 人 Boss 战中持续移动 / ≥4 人主动处理 Phase 2 蒺藜 / ≥4 人能说出至少一个 Boss 伤害来源 / ≥4 人理解 Emergency 是补救不是主路线。

**试玩三问（v1.0 §43）：** 你刚才什么时候最紧张？/ 你第一次失败时觉得哪里出了问题？/ 你觉得自己刚才做了什么？

## 13.4 QA 矩阵

**每关必测：** 标准成功 / 标准失败 / 最晚成功 / 风险解 / 被发现 / 重复触发 / Reset / Save→Load / Variant B。**L07/L08 追加六种顺序排列**（A→B→C 等全排列，不必都可通关，但必须得到明确、稳定、可诊断的结果）。**L12 追加机关组合 8 + Emergency。** SaveValidator：12 关完成状态/最佳分、3 章状态、Hard/Hard+、成就、皮肤、鱼干。

**Bug 分级：** P0 = 主线关无法完成 / 无限循环 / 忍者卡死 / Boss 无法结束 / Save 损坏 / 任一输入失效 / Validator 漏致命问题；P1 = 可 Workaround 绕过 / 影响评分/Variant/结算；P2 = 视觉/音频/彩蛋/非关键 HUD。

## 13.5 Release Gate（v1.2 完成定义）

```text
[ ] Project 名称已改为《猫忍不住》
[ ] L01-L12 可完整通关 / Retry 正常 / Save/Load 正常 / Score 正常 / EventLog 正常
[ ] 12 关 LevelValidator 全绿 / 12 个 Variant B 可加载
[ ] 3 章进度正常 / 3 个 Chapter Challenge 可完成
[ ] Hard Mode / Hard+ 解锁正常
[ ] L12 Boss Active Gate 通过（Boss 战中仍有实时操作）
[ ] Accessibility 基础项完成
[ ] P0 = 0 / P1 已收敛
```

---

# 第十四部分 · 设计风险与对策

| 风险 | 对策 |
|---|---|
| "看戏"比例过高，清完障碍干等 | 犹豫窗口永远留"就差一点"的压迫；得意忘形加速让后半程紧张；关卡时长压死在目标时间内 |
| 笑点衰减 | 台词池每类 ≥5 条 + EventLog 组合生成 + 重复率控制；困难剧本换新台词池 |
| 解法唯一导致卡关 | 每个威胁至少 2 种解法（标准解 + 高风险高笑点解） |
| 忍者 AI 不可控 | 事件点全部脚本化离散状态机，**禁用连续物理决策**；蠢是演出不是模拟 |
| 隐蔽判定太严/太松 | 原型期做调试面板实时调：视锥、累积速率、卖萌冷却 |
| 单手操作负担 | 叼取/放置合并 Q 单键；卖萌 Ctrl 可改键；手柄映射同逻辑 |
| 素材复用感过强 | 环境调色（夜晚/雷雨/沼泽）；同一素材跨场景复用（吊车白天是布景、L12 变 Boss 机关） |
| Boss 退化成看戏 | 蒺藜固定 Phase 2 战中处理；Boss Active Gate ≥60% 战中移动；普遍"全弄完看 Boss"则结构返工不调数值 |
| 评分压制高风险玩法 | 三猫爪 A–G 满足 4 项的多路线设计 + `ninja_hp<2` 永不得 3 爪保护 |
| 试玩指标模糊 | 全部 Gate 数字化为 8 人样本可判定标准 |

**平衡调整五层顺序（不要乱序，不要同时大改多个变量）：** 空间（事件距离→捷径→站位）→ 时间（忍者速度→犹豫→事件窗口）→ 操作（交互时长→推速→疾跑经济）→ 认知（视觉→音频→怀疑反馈）→ 内容（台词→彩蛋→收藏）。**不要用台词去修一个空间问题。**

**关卡审查评分卡（10 项，少于 8 项不进最终美术）：** 可读性 / 可调度 / 时间感 / 联动 / 多解 / 风险 / 喜剧 / 失败 / 重玩 / 技术。

**砍内容三级优先：** 第一优先保玩法递进——绝不为保留外围功能牺牲 L01→L12 的递进结构。

---

# 第十五部分 · 仲裁记录与待决策

## 15.1 待决策事项

1. **操作设备：** 键鼠优先，手柄映射同键位（`Ui/Input/Gamepad` 图标现成）——待确认是否首发同步适配。
2. **卖萌冷却：** 20s 初值，垂直切片实测调整。
3. **吹牛台词生成：** 已定纯模板拼接，不接 LLM。
4. **猫叫声效（唯一素材缺口）：** freesound 外补 / 录音合成 / Voice*.wav 变调凑合——三选一。
5. **第四章及以后：** 换忍者人格（NinjaRed 自负 / NinjaGreen 胆小，素材现成）做"蠢法"变体——RC 之后根据试玩反馈定。

## 15.2 整合冲突仲裁记录

| 冲突 | 各方 | 裁定 |
|---|---|---|
| 独眼猫解锁条件 | v0.3"三星全收集" vs v1.0"通关最终居酒屋" | **Hard+ 解锁（全 12 关 3 猫爪）**——与"三星全收集"精神一致且匹配 12 关规模 |
| 小鱼干数量 | v0.3"每关 3 条" vs v1.0"全游戏共 6 个" | **每关 3 条，共 36 条**（12 关规模） |
| 怀疑语义 | v0.3"不随时间衰减" vs v1.1"离开停止累积、卖萌清除" | **以 v1.1 冻结语义为准**（v1.2 System Spec §10 已确认）：做事被看见→增加；离开→停止继续累积；卖萌→清除 |
| 评分公式 | v0.3 简单三星 vs v1.1 A–G 条件式 | **A–G 公式**（含 ninja_hp<2 不得 3 爪保护） |
| 12 关 target_time | Level Bible（65–140s）vs DataResource Spec（55–125s） | **取 v1.2.5 DataResource 表为当前基线**，两者均待首轮 8 人试玩冻结 |
| 场景/资源命名 | 各文档 `chapter_01_village/L01_FirstJob.tscn`、`ch01_village/L01_first_job.tres`、`scenes/levels/L01_first_job.tscn` 混用 | **统一 snake_case：** `scenes/levels/ch01_village/L01_first_job.tscn`、`data/levels/ch01_village/L01_first_job.tres`；英文名统一：L01 first_job / L02 same_old_trap / L03 who_is_watching / L04 village_accident / L05 moonlit_dock / L06 dog_ally / L07 who_goes_first / L08 last_boat / L09 storm_night / L10 dont_touch_dynamite / L11 busy_gate / L12 gatekeeper_boss |
| 禅问：Emergency Rescue 是否算第四机关 | v1.1 review | **否**——它是 Fail-safe，不给额外资源，固定 1 猫爪 |
| 酒葫芦机制 | v0.3"-30% 血 + 离席 10s" vs v1.2.5 BossData"仅 gourd_delay=10.0" | **仅延迟、无伤害**（BossData 无 gourd_damage 字段；Boss HP 数学 100-40-30=30 恰达 Phase 3 收尾阈值，依赖此口径） |

---

# 附录 · 白盒验收清单汇总

**单关 Whitebox → Art 前必须：**
```text
[ ] Ninja Route 能完整跑通（无自由寻路依赖）
[ ] 每个 CRITICAL Event 有成功出口 + 失败出口
[ ] 至少一条 Shortcut / 至少一条 Risky Solution
[ ] Reset 后状态全部恢复 / Save/Load 不破坏 WorldState
[ ] Variant B 可加载 / LevelValidator 通过
[ ] 新玩家知道下一步危险在哪
```

**每关标准生产表必填字段：** LevelID / Scene / LevelData / RouteData / Event 数 / 主路线 / Shortcut / 标准解 / 风险解 / 失败出口 / Variant B / 目标时间初值 / 三猫爪适配 / 结算笑点 / QA Case。

**Resource 制作顺序：** L01 全套 Data Resource → L01 Playable → 复制模板到 L02-L04 → Chapter 01 Gate → 复制到 L05-L08 → Chapter 02 Gate → 复制到 L09-L12 → Boss Gate。**不要同时独立创建 12 套 Resource。**

**程序工作包优先级：** P0 = LevelData / RouteData / EventPointData / WorldFlagData / ScoreRuleData / VariantData / LevelManager / LevelValidator；P1 = ShortcutData / BossData / BanterSetData / DebugDataOverlay；P2 = ReplayData / ShareCardData。

---

> 文档结束。历史版本文件保留在本目录作归档，不再单独维护；后续修改请直接改本文档并递增版本号。
