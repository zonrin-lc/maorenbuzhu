# 《猫忍不住》游戏设计文档 · 整合版 v1.4.8

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
> | v1_2_9_Chapter02_Integration_Spec | v1.2.9 | 第二章连续试玩链 + L05–L08 白盒 Gate |
> | v1_2_10_Chapter03_Integration_Spec | v1.2.10 | 第三章连续试玩链 + L12 Boss / Emergency 白盒 Gate |
> | v1_2_11_Unified_Event_Architecture | v1.2.11 | 统一事件架构：UnifiedLevelManager / EventBehaviorRegistry / EventGroup |
> | v1_2_12_DataDriven_Event_Authoring（含实现包） | v1.2.12 | EventBehaviorData / EventEffectData，事件完全数据化（46 事件 / 11 类型） |
> | v1_2_13_L01-L12_Production_Cards / Level_Production_Template | v1.2.13 | 12 关生产卡 + 关卡生产管线方法论 |
> | v1_2_14_Global_UI_HUD_Spec（含实现包） | v1.2.14 | GlobalUI 组件树 / 怀疑猫眼映射 / 失败诊断 / 暂停 / 无障碍 |
> | maorenbuzhu_v1_2_15_Meta_Progress | v1.2.15 | 存档 schema、解锁规则、猫技艺阈值、Meta 页面数据源 |
> | v1_2_16_Izakaya_Settlement_Spec（含实现包） | v1.2.16 | 结算状态机 / BoastGenerator / Banter Schema |
> | maorenbuzhu_v1_2_17_Audio_System | v1.2.17 | GlobalAudioManager / BGM 状态机 / 动态音乐 / 猫叫变体 |
> | v1_2_18_Input_System_Spec（含实现包） | v1.2.18 | Input Action 层 / 手柄默认映射 / 重绑定 / 设备切换 |
> | v1_2_19_Settings_Spec（含实现包） | v1.2.19 | 设置系统五页 / settings.cfg 与 save.cfg 分离 |
> | maorenbuzhu_v1_2_20_Main_Flow | v1.2.20 | 主流程：Boot → 主菜单 → 章节/关卡选择，Continue 规则 |
> | maorenbuzhu_v1_2_21_Result_Flow | v1.2.21 | 结算回写链「先存档再结算」+ 结算页四出口 |
> | v1_2_22_Debug_QA_Spec（含实现包） | v1.2.22 | Debug Console / Overlay、LevelValidator 12 条合同、QA 自动化 |
> | v1_2_23_Playtest_Balance_Matrix | v1.2.23 | 12 关时长基线 / 单关平衡卡 / 采样字段 / 冻结门槛 |
> | v1_2_24_Balance_Sheet_v1 | v1.2.24 | 纸面平衡修正（L08→L09 断层）/ 逐关调参杠杆 / 8 人 × 3 轮协议 |
> | v1_2_25_ThreeRoute_Playtest_Spec | v1.2.25 | SAFE / BALANCED / RISKY 三路线验收 / 调参决策树 |
> | v1_2_26_Playtest_Tracker_Pack + summarize_playtest.py | v1.2.26 | 试玩采集管线（xlsx 8 表 + 自动统计脚本） |
>
> **冲突仲裁原则：版本新者优先（v1.2.x > v1.1 > v1.0 > v0.3）；同版本冲突在本文 §15.2 记录裁定。** 原始文件保留作历史归档，不再单独维护。
>
> **素材约束：美术与音频严格限于 Ninja Adventure Asset Pack——素材零缺口（v1.5.8 起，猫叫见 §9.3）。**
>
> v1.3.1 修订（2026-09-24）：按《GDD_v1.3_审查报告》修复 P0×3 / P1×5 / P2×4，详见审查报告与 §15.2。
>
> v1.4 修订（2026-09-26）：整合 v1.2.9–v1.2.26 全部新文档与实现包——第二/三章连续集成、统一事件架构、数据驱动事件 Authoring、关卡生产管线、GlobalUI、Meta 进度、居酒屋结算管线、音频系统、输入系统、设置系统、主流程、结果流、Debug/QA 合同、试玩平衡体系（Matrix/Balance Sheet/三路线/采集管线）。修订 §2/§5/§7/§8/§9/§11/§12/§13，新增冲突仲裁见 §15.2。
>
> v1.4.1 修订（2026-09-28）：融合 v1.5.1 首轮平衡体验修整版——三星时间线以实现版为准（§5.2）、新增 BalanceDirector 节奏反馈（§8.1）、结算数据扩展（§7.4）、仲裁记录追加（§15.2）。
>
> v1.4.2 修订（2026-09-28）：融合 v1.5.2 反馈品质 / v1.5.3 动画层级 / v1.5.4 音效同步三个表现层版本（§3.5、§8.2、§9.2）。
>
> v1.4.3 修订（2026-09-28）：融合 v1.5.5 UI/居酒屋结算、v1.5.6 三端输入、v1.5.7 视觉层级与读图演出（§2.1、§2.2、§7.1、§15.1）。
>
> v1.4.4 修订（2026-09-28）：融合 v1.5.8 猫叫素材补全版——唯一素材缺口关闭（§9.3、§15.1）。
>
> v1.4.5 修订（2026-09-28）：融合 v1.6.0 美术资产替换与场景精修版——项目进入正式美术层（§10 素材映射后新增美术状态段）。
>
> v1.4.6 修订（2026-09-28）：实现审查裁定落地——chain_rescue 定义收紧（§7.4）、L11 Cliff→Gate（§6.3）、L10 事件 ID 去重（§15.2）、新增实现债登记（§15.3）。详见《猫忍不住》_v1.6.0_实现审查记录.md。
>
> v1.4.7 修订（2026-09-28）：开发迁移至本机（Godot 4.7.2）；实现债 ①⑤⑨⑩ 修复落地，⑥⑦ 部分落地（§15.3）；顺带修复 input_manager.gd 的 InputEventMouseWheel 不存在类引用与 class_name/autoload 同名冲突两个历史编译错误。
>
> v1.4.8 修订（2026-09-28）：实现债 ③④⑦⑪ 落地——VariantData×12 + HardMode LevelModifier + EventLog FAILED + GitHub Actions CI（§15.3）；实现说明见工程 docs/VARIANT_HARDMOD_IMPL.md。

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

**读图演出与事件视觉层级（v1.5.7）：** 读图阶段每个 MAIN 事件按忍者路线依次聚焦，当前关注点带脉冲光环，路线与分区清晰显示；读图结束后布局说明层淡至低存在感，不挡玩法。事件颜色分级：CRITICAL=暖金高亮 / STANDARD=蓝色高亮 / OPTIONAL=绿色高亮；当前活动事件加柔和脉冲与顶部小标记；已解决事件保持绿色成功态。不改变事件判定、路线、输入、评分与结算逻辑。

**单局节奏（目标单局 1–2 分钟（target_time 55–125s，见 §5.2），含读图与结算约 2–3 分钟）：**

| 阶段 | 时长 | 体验 |
|---|---|---|
| 读图 | ~10 秒 | 紧张前的安静，玩家规划解法顺序 |
| 前段 | 20–40 秒 | 单点威胁，建立信心与笑点 |
| 中段 | 30–50 秒 | 威胁联动，排序解题，首次紧张峰值 |
| 尾段 | 15–30 秒 | 忍者"状态绝佳"走路加快，玩家疲于奔命（喜剧高潮） |
| 结算 | 首次通关 15–25 秒（v1.2.16）；重复挑战压缩至 8–12 秒 | 吹牛 + 评分，情绪释放 |

**失败条件：**
- 忍者死亡（坠崖直接死；陷阱/守卫/中毒累计扣 3 颗心）→ 任务失败
- 怀疑值满 100 → 他吓得弃任务回家（"这猫不对劲！"）

**失败重试：** 立即回到读图阶段，事件点状态全部重置；死亡演出控制在 3 秒内，重试零加载（R 键）。失败本身带笑点（见 §4 各威胁"失败演出"）。

**失败诊断文案原则（v1.0 §32）：** 告诉玩家"错在哪里"，不告诉"唯一正确答案"。示例：L01"你晚了一步。"／换岗关"换岗已经发生，你还在这里。"／L12"Boss 已进入终结节奏，而你的救场机关还没准备。"这些属于诊断，不属于攻略。

**统一失败码（FAIL_CODE，v1.2.14 / v1.2.22 冻结，全 7 枚）：** 玩家看自然语言诊断，Debug 显示 Code。

| FAIL_CODE | 含义 | 诊断文案方向 |
|---|---|---|
| FAIL_TOO_LATE | 未在窗口内赶到/完成 | 可更早赶到事件点 |
| FAIL_WRONG_ORDER | 处理顺序改变了后续世界状态 | 事件状态改变了后续路线（仅作诊断/日志码，不作"顺序错了"直接弹窗——玩家应从后果推断，见 §15.2 仲裁） |
| FAIL_SUSPICION | 怀疑值满 100 | 动作被忍者看到 |
| FAIL_NINJA_DEATH | 忍者死亡 | 事件前未保护忍者 |
| FAIL_BOSS_FINISHER | Boss 终结动作未化解 | Boss 终结动作未化解 |
| FAIL_ROUTE_BLOCKED | 关键空间状态未打开 | 关键空间状态未打开 |
| FAIL_TIMEOUT | 超时间窗口 | 未在时间窗口内完成 |

## 2.2 玩家能力（猫）

**输入铁律（v1.2.18）：** Gameplay/UI/教学只读取 Input Action，禁止直接读物理键码；物理键只存在于 InputMap/重绑定层。键鼠与手柄首发同步支持（关闭 §15.1 待决策 #1），全部 Action 可重绑（confirm/cancel 保安全默认键除外）。

| 能力 | Action | 键鼠 | 手柄 | 说明 |
|---|---|---|---|---|
| 移动 | `move_up/down/left/right` | WASD | 左摇杆 | 四方向移动 |
| 疾跑 | `sprint` | Shift | RB | 短时间加速，消耗体力，有残影 |
| 跳跃/攀爬 | `jump` | Space | LB | 跳上屋顶、树、箱子（关卡内）/ JumpPoint——立体机动是核心优势 |
| 互动（咬/推/拍） | `interact` | E | A | 情境交互：咬断绳、推箱子/桶、拍飞小物件；咬绳 0.8s 进度条，可被打断 |
| 叼取/放置 | `carry` | Q | X | 叼起小道具（解毒药、鱼肉），放到指定位置；叼取移速 ×0.85 |
| 喵叫 | `meow` | F | B | 引开守卫/动物（对忍者无效——他只会说"哪来的猫"）；不产生怀疑 |
| 卖萌 | `emote` | Ctrl | Y | 原地躺下翻肚皮：怀疑值清零，冷却 20s |
| 暂停 | `pause` | Esc | Start | 完全冻结 Gameplay（见 §8.5） |
| 重开 | `retry` | R | LS | 失败/完成后重载场景 |
| 确认 / 取消 | `confirm` / `cancel` | Enter / Esc | A / B | UI 层；**结算画面"下一关"走 `confirm`**（v1.2.18 起 Space 固定为跳跃，见 §15.2 仲裁）；章节结算后 Enter 回 L01。**结算画面首 1 秒屏蔽输入**，防止关卡内跳跃惯性误跳结算演出 |

**输入优先级栈：** `System Modal > Pause > Settlement/Dialog > Tutorial Modal > Gameplay`。Esc 同时是 `pause` 与 `cancel` 的默认键——Pause 层级优先消费，属有意的层级区分。

**手柄默认映射（v1.5.6 已实现）：** A=互动/确定，X=叼取/放置，B=喵叫/取消，Y=卖萌，LB=跳跃，RB=疾跑，START=暂停，LS=重开。**触控：** 横屏自适应，左侧虚拟摇杆 + 右侧 2×3 六按钮，按钮尺寸按短边比例缩放。由 GameInputManager 自动检测键鼠/手柄/触控，HUD 操作提示随最近输入设备切换，玩法代码不感知具体设备。

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

**动画优先级（v1.5.3，`animation_feedback_driver.gd`）：** `DEATH > VICTORY > HIT > ACTION > EMOTE > ALERT > CARRY > MOVE > IDLE`。高优先级动作到期自动恢复基础状态；胜利跳跃保存并恢复 Sprite 基础坐标；受击闪白在驱动器内部应用不被主循环覆盖；动物素材只有两帧时用轻微 scale/rotation/offset 制造反馈，不伪造不存在的动作帧。猫接入 MOVE/CARRY/ACTION/EMOTE；忍者接入 ALERT/MOVE/HIT/DEATH/VICTORY；守卫 ACTION/MOVE/IDLE；狗 ACTION/EMOTE/MOVE/IDLE；Boss ACTION/HIT/DEATH/VICTORY。

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

> 当前基线 = **v1.5.1 实现版**（已锁定；下一次变更必须来自 ≥8 人同关卡试玩数据：完成率 / 三星率 / 首次失败点 / 平均最高怀疑 / 平均掉心）。历史值见 §15.2 仲裁记录。

| 关卡 | L01 | L02 | L03 | L04 | L05 | L06 | L07 | L08 | L09 | L10 | L11 | L12 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 事件数 | 3 | 3 | 4 | 4 | 6 | 5 | 5 | 6 | 4 | 4 | 7 | 3+Boss |
| Target（三爪目标 ≤） | 60s | 55s | 65s | 70s | 80s | 90s | 100s | 115s | 100s | 105s | 125s | 150s |
| 首通预期 | 55–85 | 55–80 | 65–90 | 70–100 | 85–115 | 90–130 | 105–145 | 125–170 | 110–150 | 115–160 | 140–190 | 170–230 |

口径：事件数不含 Goal，为白盒基线（以 §6 详设为准）；制作中调整事件数必须同步更新 LevelData 与本表。L09 压力靠"雷雨 + 忍者 +10% 速度 + 事件间距缩短"实现——**压力形态变化，不是难度倒退**。每关只允许 1 个"第一调参变量"（逐关杠杆表见 §13.8）。

> 忍者路线速度（v1.5.1 实现）：L02 = 52 px/s（教学减速），第三章 L09–L12 = 66 px/s（得意忘形压力），其余 = 60 px/s。

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
- **事件（7 个）：** E11_GA CRITICAL / E11_GB STANDARD / E11_DOG CRITICAL / E11_DY1 CRITICAL / E11_CAL CRITICAL / E11_POI CRITICAL / E11_GATE 城门通行检查点 STANDARD（PASSIVE 行为；v1.4.6 裁定替代 Cliff，见 §15.2）

> 注（v1.4.6）：Cliff 自 L11 移除，悬崖机制保留在威胁库（§4.3）供后续关卡/变体使用。
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

**居酒屋结算实现结构（v1.5.5）：** 视觉统一为深色木色底 + 金色强调 + 圆角信息卡。布局：Header=任务完成+关卡标题 / CenterCard=忍者吹牛+猫吐槽 / ResultCard=猫爪+用时+三星线+最高怀疑+应急说明 / Bottom=操作提示。演出顺序：忍者淡入 → 吹牛 → 猫出现 → 吐槽 → 猫爪揭示 → 操作可用。结算输入：Enter/Jump 下一关、R 重玩、Esc 主菜单。主菜单同风格：标题/副标题分层 + 进度卡（已完成关卡/猫爪/鱼）。

**重复挑战压缩规则：** 默认压缩为"吹牛一句 → 猫舔爪 → 猫爪"，长度 8–12 秒；玩家可主动展开完整结算。首次通关完整演出 15–25 秒（v1.2.16）。结算状态机、Banter 数据格式与存档回写纪律见 §7.5。

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

> **chain_rescue 定义收紧（v1.4.6）：** 仅当"前一事件的完成通过 caused_event_id 依赖链改变了后一事件的可用性/窗口"时才计数；无因果依赖的连续完成不计入。实现侧 `if previous_event_id != &"": chain_rescue += 1` 的写法属于违约，须改为沿 caused_event_id 链判定。

**保护规则：** `ninja_hp < 2` 永不可得 3 爪（防止靠故意卖血刷高风险救场）。唯一允许的关卡差异：target_time / 事件标签 / Boss 额外条件。

**结算数据扩展（v1.5.1）：** 结算 payload 增加 `target_time` 与 `time_ratio`；结算面板与居酒屋场景显示"三星线内 / 超过三星线"状态。

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

**三猫爪验收补充（v1.2.25）：** 每关须记录 SAFE / BALANCED / RISKY 三种风格的满评价路径，且三种均须真实可复现；每关 ≥2 种不同的 3 猫爪路线。

## 7.5 结算管线实现规范（v1.2.16 / v1.2.21）

**结算状态机：**

```text
SETTLEMENT_ENTER → BOAST_ANALYZE → BOAST_LINE_01 → (BOAST_LINE_02 可选)
→ CAT_REACTION → PAW_REVEAL → META_COMMIT → EXIT
重复挑战：跳过 LINE_02 与 CAT_REACTION（8–12s 压缩版）
```

**BoastGenerator 纪律（硬性禁止：随机选句 / 引用未发生事件 / 结算阶段重算猫爪）：**

- Importance 优先级：`EMERGENCY > NEAR_DEATH > BOSS > CHAIN > ROUTE_CHANGE > STANDARD_SUCCESS`；首句取最高，次句 Tag 不重复。
- **标准 Tag（18 个）：** `TRIPWIRE / GUARD / DOG / POISON / BRIDGE / CALTROP / DYNAMITE / BOSS_CRANE / BOSS_GOURD / BOSS_CALTROP / EMERGENCY / NEAR_DEATH / CHAIN / ROUTE_CHANGE / HIGH_RISK / SHORTCUT / ZERO_SUSPICION / NO_DAMAGE`（结算吹牛链推荐 8 个高级 Tags：`last_second / high_risk / chain / shortcut / npc_link / boss / near_death / clean_clear`，v1.2.13）。
- **Banter 模板字段（BanterData）：** `banter_id / priority / required_tags / forbidden_tags / level_scope / difficulty_scope / text_template / cat_response / voice_id / weight`（weight 只用于兼容模板间轮换；§7.2 的"连续三次不重复"约束仍为目标，需在轮换逻辑中落实）。
- **猫反应四档：** NORMAL 舔爪 / GOOD 抬眼一次 / RIDICULOUS 停顿 0.5s 后舔爪 / EMERGENCY 先喘气再舔爪。
- 老板娘捧场/拆台台词池保留（§7.2，品牌记忆点）；v1.2.16 实现包暂未包含，待补（§15.2 仲裁）。

**存档回写纪律（v1.2.21，"先存档、再结算"）：**

```text
Gameplay → ScoreResult → AppFlow.complete_level() → SaveManager.mark_level_complete()
→ ResultFlow.pending_result（一次性消费）→ Result Scene
```

- 失败不写完成，只走 Retry 诊断；Retry 用当前 level_id 重开，**不得复用上一局 ScoreResult**。
- 结算页四出口（按钮制）：重玩本关 / 下一关 / 关卡选择 / 主菜单。Next 线性 L01→L12，须 `can_start()` 已解锁才直进，否则跳关卡选择；L12 后进第三章完成态，**不生成 L13**。
- **防重复提交：** 一次结算只调一次 `complete_level()`；重玩只刷新最佳成绩、不改解锁；Save 失败显示"本次进度未保存"，不阻塞流程。
- **Meta 提交顺序：** ScoreSystem finalize → BoastGenerator snapshot → ResultPanel show → ProgressManager commit → SaveManager save。
- **ResultPanel 只读：** 只展示 ScoreResult 九字段（paws / mission_complete / ninja_hp / max_suspicion / elapsed_time / 4 项风格指标），禁止重算；解锁展示只列本次新增（猫爪/鱼干/皮肤/猫技艺/Hard/Hard+）；详细 EventLog 只进 Debug/Meta。
- 结算场景分工：`izakaya_settlement.tscn`（居酒屋演出，v1.2.16）为皮，`scenes/flow/result.tscn`（流程壳，v1.2.21）为骨；§12.3 旧名 `IzakayaResult.tscn` 以实现为准对齐（§15.2）。

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

**节奏时间线提示（BalanceDirector，v1.5.1 已实现）：** HUD 显示本关三星时间线与当前节奏状态，四档：0–69% `节奏舒适` / 70–89% `三星冲刺` / 90–99% `三星临界` / ≥100% `已超过三星线`。只影响信息反馈，不改变三猫爪计算，不绕过 ScoreSystem。

**HUD 禁令（HUD 告诉事实，不告诉答案）：** 禁止"建议先处理 / 请前往 / 正确解法 / 危险排序提示"。

**GlobalUI 实现规范（v1.2.14）：** 统一全局 UI 层 `global_ui.tscn`：`TopBar / SuspicionEye / NinjaLocator / BottomBar / InteractionPrompt / TutorialDirector / FailureDiagnostic / ResultPanel / PauseOverlay`。架构铁律：关卡只能通过 UIState/Signal/Data 驱动 UI（LevelManager → Signals → UIManager），**禁止关卡脚本直接操作 Control 节点**。

**SuspicionEye 五段映射（不显示数字，阈值与 §2.3 一致）：**

| 怀疑值 | 状态 | 表现 |
|---|---|---|
| 0–24 | Normal | 瞳孔放松 |
| 25–49 | Notice | 轻收缩 + 小问号 |
| 50–79 | Alert | 明显收缩 + 回头提示 |
| 80–99 | High | 强收缩 + 搜索波纹 |
| 100 | Broken | 闭眼 / 警报演出 |

**NinjaLocator：** 屏幕边缘箭头距离只分 Near / Mid / Far 三档；情绪改**箭头动画节奏**而非颜色（颜色仅作辅助，无障碍要求，§15.2 仲裁）。交互提示仅在操作对当前目标合法时出现，按键图标必须调 `InputDisplay.get_binding_label()` 动态显示当前绑定（v1.2.18）。

## 8.2 反馈层级制（信息重要性 = 反馈强度）

- **一级（危机）：** 忍者濒死 / Boss Finish / 怀疑 80+ / Emergency
- **二级（关键变化）：** 受伤 / Boss HP / Route Change / WorldState 变化
- **三级（普通）：** 机关成功 / 收集
- **四级（装饰）：** 雨 / 灰尘 / 水面

**装饰永远不能抢玩法反馈。**

**反馈层实现状态（v1.5.2）：** 事件成功=顶部结果横幅+世界反馈闪光+左下事件徽记；事件失败=危险横幅+红色闪光+失败原因；忍者掉心=红色屏幕脉冲+剩余心数；怀疑跨过 25/50/80=眼睛提示徽记；猫动作（叼取/喂狗/派狗/喵叫/卖萌）=即时动作徽记；捷径成功=独立捷径横幅；L07/L10 路线切换=显式"忍者改线"提示；Boss Phase=阶段切换横幅+轻度屏闪；结算卡片=淡入上移+猫爪缩放揭示。反馈层只提升可读性，不改变玩法判定。

## 8.3 教学 / FTUE 细则

- **30 秒内必须完成：** 看到猫 / 看到忍者 / 获得移动 / 看到第一个危险 / 主动前往危险点
- 第一次成功拆绳必须马上获得：清晰 SFX + 绳断动画 + 忍者继续前进 + 自我吹牛
- 第一次怀疑必须演示"被看到 ≠ 死"：问号 → Ctrl 卖萌 → 怀疑归零，而不是第一次被看到就失败
- 第一次结算不先显示数字，先告诉玩家：**"他以为是自己做的。"** 再显示猫爪
- **不做传统教程菜单。** 所有教学都通过：情境 + 单句提示 + 实际操作完成。第 1 章教完全部猫能力（咬/叫/推/卖萌），第 2 章教叼取，第 3 章不教新东西只加压力

**TutorialDirector（v1.2.14）：** 教学排期 L01 教 E/F/推、L03 教怀疑/Ctrl、L05 教 Q/搬运，其后不加新按钮只减文字；每个 `tutorial_id` 只显示一次并写入 SaveData（`tutorial_seen`）。`TutorialData` 字段：`tutorial_id / trigger_event / input_action / title / body / icon / duration(3.0) / once_only(true)`。

## 8.4 失败诊断与暂停规范（v1.2.14 / v1.2.18）

- **FailureDiagnostic：** 按 §2.1 统一 FAIL_CODE 表出自然语言诊断——告诉"错在哪里"，不告诉"唯一正确答案"。
- **Pause：** `get_tree().paused = true`；Gameplay 节点默认 `Pausable`，Pause UI 用 `When Paused`；暂停时忍者/猫/事件/怀疑/Boss 计时全停，音频不强制停；暂停中开设置，退出恢复原暂停态。
- **输入优先级栈：** `System Modal > Pause > Settlement/Dialog > Tutorial Modal > Gameplay`（见 §2.2）。

## 8.5 输入系统（v1.2.18）

- **Action 层铁律：** Gameplay/UI/教学只读 Input Action；物理键只在 InputMap/重绑层（Action 表见 §2.2）。
- **重绑规则：** 保存前检查同设备同键冲突、Action 被清空、删最后一个移动方向、删 pause；冲突弹确认（替换/取消），不静默覆盖。
- **设备检测：** `KEYBOARD_MOUSE / GAMEPAD / TOUCH`，UI 图标组随最近输入设备切换，切换不重置 Action；移动端虚拟键预留兼容接口。
- **QA Gate：** 10 项通用 + 三关专项（L01 E/F/Ctrl、L05 Q、L09–L12 Sprint/Jump/Pause、Boss Phase 2 不被 UI 输入阻塞）。

## 8.6 主流程与选关（v1.2.20 / v1.2.21）

```text
Boot → Settings Load → Save Load → Main Menu
  { Continue | Chapter Select → Level Select | Settings }
```

- **Continue 规则：** 无进度 → L01；当前关已完成 → 下一关；未完成 → 继续当前关；L12 完成后回章节完成态，**不自动循环**（依赖 `last_level_id`）。
- **解锁规则：** 章节 Ch01 默认开放，Ch02 需完成 L04，Ch03 需完成 L08；关卡 L01 默认开放，L02–L12 完成前一关解锁；Level Select **禁止绕过锁定直接启动**（`can_start()` 双保险）。
- **Level Select 展示：** 每关至少显示 LevelID、中文名、当前 Normal 最佳猫爪、锁定状态；**禁止显示"正确解法"**。
- **设置边界：** 主流程只跳转设置页，修改权归 SettingsManager（§12.12）；设置与存档互不影响。
- **QA：** Fresh Save（首启 Continue → L01）/ 递进解锁 / Save Isolation / Navigation（全部页面可返回、Locked 不可进、Continue 与章节选择一致）。

---

# 第九部分 · 音频设计

## 9.1 Bus 与优先级

```text
Master
├─ Music     （原 BGM，v1.2.17 起改名）
├─ SFX
├─ Voice
├─ UI
└─ Ambient   （原 Environment）
```

五组 Bus 均可在设置页独立调音量（键名 `music/sfx/voice/ui/ambient_volume` + `mute_all`，见 §12.12）。

抢占优先级（v1.2.17）：`System Error > Mission Fail > Boss Phase > High Risk / Near Miss > Event Success > NPC Voice > Ambient`；Voice 不得被 UI 音打断。

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
| 猫叫（喵叫 F） | `audio/sfx/cat_meow_*.wav` ×3 轮换（v1.5.8 原创合成） |
| 卖萌成功 | `Audio/Jingles/Secret2.wav`（叮——） |
| 自我消解台词 | 配一声 `Audio/Sounds/Bonus/Bonus.wav`"恍然大悟"音 |
| **得手签名（只有玩家听得到）** | `Audio/Sounds/Bonus/PowerUp1.wav` 音量压到 20% |
| 忍者扣血/踩坑 | `Audio/Sounds/Hit & Impact` + `Alert` 系列 |
| 爆炸 | `Audio/Sounds/Elemental` 爆炸音 |
| 评分弹出 | `Audio/Jingles/Success1~4.wav`（按星级递进） |
| 雷雨氛围 | `Audio/Sounds/Ambient` + Thunder One-Shot + Rain Loop |

**音频喜剧原则：** 得手签名音是《猫忍不住》的声音识别点——"全场只有玩家知道真相"。

**音效触发链（v1.5.4，全部复用素材包音频，无外部新增）：** 互动开始 `SFX_INTERACT`（动作开始即触发）/ 叼取 `SFX_PICKUP` / 放置与事件成功 `SFX_PLACE`（按事件类型选 cue，不再全事件共用一个 success 声）/ 猫洞跳点 `SFX_SHORTCUT`（位移完成后）/ 忍者掉心 `SFX_DAMAGE` / 路线切换 `SFX_ROUTE_CHANGE` / Boss Phase `SFX_BOSS_PHASE` / Boss 击败 `SFX_VICTORY`。防噪：同类音效 80–450ms 冷却，四路 SFX 全忙时不强抢占；Boss 阶段切换若音乐资源相同不重新 start。F 喵叫在 v1.5.4 时仍为缺口、不拿错误音效冒充；v1.5.8 已由原创合成猫叫补全（见 §9.3）。

## 9.3 ~~唯一素材缺口~~ 已关闭（v1.5.8）

**猫叫声效（F 喵叫）已由 v1.5.8 关闭：** 3 个原创程序合成猫叫 WAV（`audio/sfx/cat_meow_short.wav` / `cat_meow_bright.wav` / `cat_meow_low.wav`，PCM16/Mono/44.1kHz，本工程专用原创合成，不拿狗叫/鸟叫/Voice 冒充）。播放规则：F 触发后从三种猫叫轮换，最短重复间隔 350ms，加轻微音高随机防止机械重复。SFX_MEOW manifest 状态：Missing → Ready-Original-Generated。**至此美术与音频素材零缺口。**

## 9.4 音频运行时架构（v1.2.17）

- **唯一入口 `GlobalAudioManager`（Autoload）：** Gameplay 只发事实信号，音频系统自行决定表现；**禁止关卡脚本直接 `play_music()`**。
- **事实信号：** `level_started / suspicion_state_changed / ninja_hp_changed / boss_phase_changed / event_high_risk / mission_completed / mission_failed`。
- **接口：** `set_music_state(state) / play_event_sfx(key) / play_ninja_voice(tag) / play_cat_meow()` + 信号 `music_state_changed`；Save/Load 不保存正在播放的音频状态。
- **AudioData Resource：** `audio_id / bus / volume_db / pitch / loop / priority`（并入 §12.4 Resource 规范）。

## 9.5 BGM 状态机与动态音乐

- **村庄/码头：** 各 `CALM + TENSION` 两态；**城堡七态：** `CASTLE_CALM / CASTLE_TENSION → BOSS_PREPARE → PHASE_1 → PHASE_2 → PHASE_3 → BOSS_DEFEAT`。
- **动态规则：** 怀疑 Notice = 高频打击层淡入 → Alert 加层 → High 封顶不加新旋律；忍者受伤只发短 SFX 不换 BGM；`RISK_WINDOW` 降 BGM 低频 + 提节奏层。

## 9.6 猫叫 / 忍者 Voice / 事件反馈音

- **猫叫：** 3 变体 `cat_meow_short/bright/low`，最短间隔 **0.35s**，同关同一变体不连续 >2 次，走 SFX Bus。
- **忍者语气音六类标签：** `CONFIDENT / CONFUSED / SURPRISED / PROUD / PANIC / SETTLEMENT`，不替代字幕。
- **事件反馈音分档：** 每类事件至少 `PREPARED / SUCCESS / FAIL / NEAR_MISS / RESET`；CRITICAL 必含 SUCCESS + FAIL + NEAR_MISS。

## 9.7 音频无障碍与混音起点

关键玩法声音必须有视觉对应；Boss Phase 切换不得只发声音；一键静音不暂停游戏。混音起点（原型参考，非发布值）：Music 0dB / SFX -3 / Voice -2 / UI -6 / Ambient -8。

---

# 第十部分 · 美术素材映射（Asset Manifest，唯一入口）

**约束：全部取自 `Ninja Adventure - Asset Pack/`，不为每关制作新素材，优先重新组合 + 环境调色；由包内素材拼制的衍生物（如 v1.6.0 章节背景 PNG）视同包内素材。** 资产状态枚举：`Missing / InProgress / Ready / Locked`。

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

**美术精修状态（v1.6.0，项目从白盒进入正式美术层）：** 三章视觉主题——CH01 村庄暖色开放 / CH02 夜间码头冷色潮湿 / CH03 城堡夜景高压（雷雨）；章节背景各一张 1104×490 PNG（`assets/scene_art/chapter_*_bg.png`，全部由工程内素材拼制，零外部素材）。场景结构：`_setup_floor()` 统一底色 + `_setup_decorations()` 挂 SceneArt（章节背景 + 关键道具 + 终点卷轴）；LayoutGeometry 运行时隐藏白盒绘制、保留碰撞。12 关碰撞/事件点/路线/评分逻辑一律不变——美术不为玩法让路，也不改变玩法。回归审计：`tools/audit_art_pass_v16.py`。

---

# 第十一部分 · Meta 与进度

## 11.1 皮肤与收集

- **皮肤 5 套，数值完全相同，纯外观 + 彩蛋台词（v1.2.15 冻结解锁条件）：**

| 皮肤 | 解锁条件 |
|---|---|
| 黑猫（默认） | 初始开放 |
| 橘猫 | 完成 L04 |
| 白猫 | 完成 L08 |
| 灰猫 | 完成 L12 |
| 独眼猫（CatCyclop） | Hard+ 解锁（Normal 全 12 关 3 猫爪，§15.2 仲裁） |
- **收集品：小鱼干**（`Items/Food/Fish.png`）——每关藏 3 条，共 36 条（§15.2 仲裁），藏在只有猫能钻的洞里；纯装饰成就，不影响通关。
- **彩蛋：** 特定皮肤过关触发忍者隐藏台词。

## 11.2 成就（≤15 个）

覆盖：首次通关 / 零伤 / 低怀疑 / 高风险救场 / 狗联动 / 不疾跑 / 三猫爪 / Boss 三机关 / Emergency Rescue / 全收集 等。

## 11.3 猫技艺（玩家操作履历，不是角色成长）

不解锁强力数值，只解锁结算徽章/个人统计/额外台词/猫的称号：

**与章节挑战（§5.4）的关系：** 章节挑战 = 章节级一次性称号；猫技艺 = 跨关累计的个人操作履历。两者行为相似但统计口径不同，奖励互不冲突。

**阈值表（v1.2.15 冻结，EventLog 聚合，关卡脚本不直接写解锁；与旧口径的仲裁见 §15.2）：**

| 猫技艺 | 阈值 |
|---|---|
| 极限拆绳 | 累计 3 次 `late_success_window ≤ 1.0s` 完成绊绳 |
| 借狗之势 | 累计 5 次 Dog → Bark → Guard 联动成功 |
| 不留痕迹 | 3 个不同关卡 `max_suspicion < 20` |
| 猫步 | 1 关完成且 `sprint_time = 0`（区别于 CH1《不慌》的整章一次性挑战） |
| 幕后操盘 | 累计 3 次 `dependency_depth ≥ 3` 完成任务 |
| 最后一秒 | 完成 1 次 Emergency Rescue |

## 11.4 Risk Style（只影响结算文案，不影响基础奖励）

- **SAFE**：大量提前准备 / 怀疑低
- **BALANCED**：有准备有少量抢救
- **RISKY**：多次最后窗口处理 / 高频疾跑 / 多次近距离操作

用途：结算台词、成就统计、猫技艺记录、Replay 选择。

## 11.5 存档结构（SaveData schema_version=1，`user://save.cfg`，v1.2.15 / v1.2.20 / v1.2.21 冻结）

```gdscript
# 进度存档 user://save.cfg（JSON，tmp + backup 原子写）
schema_version: int = 1
selected_skin: String           # 当前皮肤
selected_difficulty: String     # NORMAL / HARD / HARD_PLUS
completed_levels: Array         # 已完成关卡（L01 永久开放，完成 Lxx 解锁下一关）
best_paws: Dictionary           # 键 "难度:关卡"，分难度独立记录
best_time_ms: Dictionary
best_max_suspicion: Dictionary
fish_collected: Dictionary      # 每关 3 条 bitmask，共 36，去重即时写入
unlocked_skins: Array
unlocked_talents: Array         # 猫技艺（§11.3）
talent_counters: Dictionary     # 技艺计数（EventLog 聚合）
tutorial_seen: Array            # 教程已读（§8.3 TutorialDirector）
hard_mode_unlocked: bool        # 12 关全部完成
hard_plus_unlocked: bool        # Normal 全 12 关 3 猫爪
last_level_id: String = "L01"   # Continue 依据（§8.6）
```

**不保存：** 关卡瞬时 Runtime 状态（忍者位置、事件状态等）、正在播放的音频状态、任何 `player_should_do_X`。**成就**（§11.2）以 `unlocked_talents` + 计数体系承载；旧 schema 的 `settings / input_bindings` 字段移出进度存档，归入 `user://settings.cfg`（v1.2.19，见 §12.12；仲裁见 §15.2）。

## 11.6 存档工程规则（v1.2.15 / v1.2.21）

- **写入仅限 6 个时机：** Level Complete / Fish / Skin / Talent / Tutorial / Difficulty Unlock；禁止每帧写盘；一次结算只调一次 `complete_level()`。
- **原子保存：** `save.tmp → flush → rename → save.cfg`，失败不覆盖旧档；Save 失败显示"本次进度未保存"，不阻塞结算。
- **Migration：** 高版本存档拒绝写入并保留文件；低版本内存迁移后按新 schema 保存。
- **职责：** `SaveManager`（Autoload，唯一写盘入口）→ `ProgressManager`（只消费 SaveData，不写文件）→ `TalentTracker`（EventLog 聚合）；关卡脚本不得直接访问 UI 或自行决定皮肤/Hard 解锁。
- **数据流：** `ResultPanel → ProgressManager.on_level_result() → TalentTracker.ingest_event() → SaveManager.mark_level_complete() → 刷新 UI`。
- 玩家统计只列事实，不给单一综合评分。

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
| 结算 | `izakaya_settlement.tscn`（演出）+ `scenes/flow/result.tscn`（流程壳） | `result_flow.gd` + `boast_generator.gd` | `banter_data.tres` + `settlement_flow_data.tres` |
| 关卡运行单入口（v1.2.11） | 12 关统一 Scene | `unified_level_manager.gd` + `unified_event_point.gd` + `event_behavior_registry.gd` | LevelData 全套（§12.4）；旧 `level_manager / dock_* / castle_*` 为兼容 shim |
| 全局 UI（v1.2.14） | `global_ui.tscn` | `ui_manager / suspicion_eye / ninja_locator / interaction_prompt / failure_diagnostic / result_panel / tutorial_director.gd` | `TutorialData` |
| 音频（v1.2.17） | — | `global_audio_manager.gd`（Autoload）+ `cat_meow_player.gd` | `AudioData` + `audio_manifest.csv` |
| 输入（v1.2.18） | `rebind_panel.tscn` | `input_manager / rebind_manager / pause_controller / input_display.gd` | 键位 manifest CSV + 默认绑定 JSON |
| 设置（v1.2.19） | `settings_menu.tscn` | `settings_manager.gd` | `settings_data.gd` → `user://settings.cfg` |
| 主流程 / 结果流（v1.2.20/21） | `scenes/flow/` main_menu / chapter_select / level_select / settings_menu / result | `app_flow.gd` + `save_manager / progress_manager / settings_manager.gd` | `level_catalog` + SaveData |
| Meta（v1.2.15） | ChapterSelect / Collection / DifficultySelect | `save_manager / progress_manager / talent_tracker.gd` | `save_data / skin_data / meta_config.tres` |
| Debug / QA（v1.2.22） | `scripts/debug/` + demo 场景 | Debug Console / Overlay / `qa_test_runner` | `qa_contract.json` + `qa_matrix.csv` |

> 上表 Level / EventPoint 行的 `level_controller.gd / event_point.gd` 命名已被 v1.2.11 统一入口取代（见 §12.10 与 §15.2 仲裁）。

## 12.4 Data Resource 规范（要点）

**总原则：** Resource 只描述事实和参数（`route_id / trigger_event_id / caused_event_id / window_start / window_end`），**不记录攻略答案**（禁止 `player_should_go_here / correct_solution / best_route`）。WorldState 只存世界事实（禁止 `player_should_do_X`）。事件依赖用 `caused_event_ids` 表示，脚本只负责"读事实 → 写 Flag → 触发下一事件允许状态"。

**核心 Resource 类：**

- **LevelData：** `level_id / chapter_id / display_name / scene_path / intro_time / target_time / ninja_route / events[] / shortcuts[] / world_flags[] / score_rules / variant / audio_map_id / banter_set_id / difficulty_modifier / validator_rules`
- **RouteData：** `route_id / actor_id / waypoints[] / loop / move_speed / stop_points[] / branch_rules[] / return_delay / variant_routes[]`（每关唯一 route_id；Variant B 通过不同 RouteData/BranchRule 实现，不复制 NinjaController）
- **EventPointData（v1.2.11/12 扩展，以实现为准）：** `event_id / event_type / event_group(MAIN/BOSS_PREP/BOSS_COMBAT/OPTIONAL) / classification(CRITICAL/STANDARD/OPTIONAL) / actor_id / trigger_radius / hesitation_time / timeout / interaction_time / interaction_radius / interaction_action / block_ninja / ninja_reaction / activation_phase / activation_flag / non_blocking / consume_carry_item / fail_code / success_flags[] / success_effects[] / failure_flags[] / caused_event_ids[] / risk_level / high_risk / allow_standard_solution / allow_risky_solution / banter_tags[]`（旧 `required_item` 语义由 `consume_carry_item` 取代；禁写 `player_should_do_X / correct_answer / hint_solution`）
- **EventBehaviorData（v1.2.12 新增）：** `event_type / default_action / suspicion(默认 10.0) / default_interaction_time(0.8) / default_event_group / default_non_blocking`——事件行为与默认操作的数据化，新增事件类型只增 Resource 不加脚本（§12.11）
- **EventEffectData（v1.2.12 新增）：** `effect_type / amount / phase_required / flag / item_id / toast`——标准 effect：`GUARD_DISTRACT / DOG_LURE / BOSS_PREPARE_DAMAGE(crane=40) / BOSS_COMBAT_DAMAGE(caltrop=30, phase_required=2)`
- **TutorialData（v1.2.14）：** `tutorial_id / trigger_event / input_action / title / body / icon / duration(3.0) / once_only(true)`
- **AudioData（v1.2.17）：** `audio_id / bus / volume_db / pitch / loop / priority`
- **SettingsData（v1.2.19）：** @export Resource，五页设置键（§12.12）
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

## 12.10 统一事件架构（v1.2.11）

全部 12 关收敛为单一运行栈：`UnifiedLevelManager → UnifiedEventPoint → EventBehaviorRegistry → EventPointData → WorldState / EventLog / ScoreSystem`。**单一入口：** 全部关卡场景引用 `res://scripts/gameplay/unified_level_manager.gd`；旧 `level_manager / dock_level_manager / castle_level_manager.gd` 降级为兼容 shim，保留 2 个版本周期、禁加新逻辑，smoke test 后删除（迁移 Phase A 改引用 → B shim 冻结 → C 删除）。

**EventGroup 四类：**

| Group | 语义 | L12 映射 |
|---|---|---|
| MAIN | 阻挡忍者的主线事件 | DYNAMITE |
| BOSS_PREP | 不阻挡，Boss 战前准备 | BOSS_CRANE / BOSS_GOURD |
| BOSS_COMBAT | 不阻挡，Boss 战中实时（不参与普通路线阻挡） | BOSS_CALTROP（Phase 2） |
| OPTIONAL | 收集/彩蛋 | 鱼干等 |

**职责切分：** UnifiedEventPoint＝激活/交互距离/E 进度/MAIN 超时/成败 signal；EventBehaviorRegistry＝event_type → 默认 action、怀疑增量、Boss/Combat 判定；UnifiedLevelManager＝节点发现/路线/事件生成/WorldState/怀疑/副作用/评分/章节流转/Boss/Emergency。

## 12.11 数据驱动事件 Authoring（v1.2.12）

事件行为与副作用彻底数据化：**新增事件只复制 `.tres`，不新增脚本或章节 Manager**。三层结构 `EventBehaviorData → EventPointData → EventEffectData[]`，落盘 `WorldState / EventLog / ScoreSystem`。

**12 种行为 → 默认操作：** TRIPWIRE→BITE / GUARD→MEOW / WATERGAP·BRIDGE→PUSH / DOG→FEED / POISON→PLACE_ANTIDOTE / CALTROP→CLEAR_CALTROP / DYNAMITE→PUSH_TO_WATER / CLIFF→PUSH_CRATE / BOSS_CRANE→CUT_CRANE / BOSS_GOURD→DRUG_GOURD / BOSS_CALTROP→CALTROP_DURING_PHASE2。

**配置约定：** Dog 事件 `consume_carry_item=FISH`；Poison 事件 `=ANTIDOTE`；新增 effect 只扩展 `EventEffectData + _apply_effect()`。**新事件 7 步流程：** 复制行为 tres → 建 EventPointData → 配 group/phase/flag → 配 success_flags/effects → 挂 LevelData.events[] → 静态审计（`audit_events.py`）→ runtime smoke test。当前实现包静态审计 46 events / 11 types / 0 errors；**runtime smoke test 未执行**（v1.2.11 Phase C 前置条件，记入 §13.5 Gate）。

**禁止：** UnifiedLevelManager 按 event_type 堆分支 / 为单关复制 LevelManager / 把"玩家应该怎么做"写进 WorldState / UI 提示写进 Flag。

## 12.12 设置系统（v1.2.19）

- **双文件铁律：** 玩家偏好存 `user://settings.cfg`，游戏进度存 `user://save.cfg`；恢复设置默认绝不动存档，清存档须二次确认且不动设置。
- **五页：** Input / Audio / Accessibility / Display / Data Management。所有读写经 `SettingsManager`，UI 不直接碰 ConfigFile；菜单禁触 EventLog/WorldState/ScoreSystem/LevelData。
- **默认值：** music/ambient=0.8，其余音量=1.0；subtitles=true；vsync=true；fullscreen=false；其余 false。
- **启动序：** `Boot → load() → Apply Display → Audio → Input → UI a11y → Load SaveData → Main Menu`。
- **无障碍键（Release Gate 落地项）：** `subtitles_enabled / reduce_flashing / reduce_screen_shake / large_ui / high_contrast_ui`；只改呈现不改事件规则，危险信息不得只靠颜色。
- **保存策略：** 修改即时应用；关页/切页时 save()；关键项改后立即存盘。

## 12.13 Debug / QA 合同（v1.2.22，扩充 §12.7）

- **Debug Console 命令：** `help / level L01 / win / fail <CODE> / hp 1 / suspicion 80 / world <flag> <v> / boss PHASE_2 / event <id> / validate / pause_sim / resume_sim / reset`。
- **Overlay 必显：** Level ID、Ninja HP、Suspicion、Boss Phase、WorldState Flags、最近 EventLog、当前 Fail Code；一键 Reset / Restart Event / Force Success·Failure / Teleport（后四项 `debug_only`）。
- **LevelValidator P0 合同（12 条）：** LevelData/RouteData/EventPointData 存在、required EventBehavior、Start/Goal、Route 非空、WorldState 默认值、ScoreRule、ResultFlow 合法、Boss Phase 迁移规则、Emergency Rescue 仅 HP≤1、Debug 不入 SaveData；硬指标 `levels=12, expected_events=46`（工程合同值，见 §15.2）。
- **Boss 阶段枚举**以 §6.3 全枚举（`BOSS_INTRO → BOSS_PREPARE → PHASE_1 → PHASE_2 → PHASE_3 → DEFEATED / RETREAT`）为准，`qa_contract.json` 的 `NONE/PREPARE/…/DEFEAT` 作兼容映射（§15.2）。
- **Release 剥离 5 条：** Console/QARunner disabled、Overlay 缺失、作弊输入缺失、Debug 存档字段缺失；Debug 层不进入正式玩家系统、不写正式 SaveData。
- **机器可读合同：** `qa_contract.json` + `qa_matrix.csv`（24 条用例：每个 CRITICAL 事件 7 态；Boss 机关组合 8 态）。

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

> 状态更新（v1.6.0）：12 关白盒已全部完成并锁定，美术精修已按本章原则启动。

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
[ ] 统一事件架构 runtime smoke test 通过（v1.2.11 Phase C 前置）
```

## 13.6 章节连续集成 Gate（v1.2.9 / v1.2.10）

**运行链：** L01–L04 → `Chapter01_Clear` → L05–L08 → `Chapter02_Unlock` → L09–L12 → `Chapter03_Clear`（节点命名以实现为准；每关由 `LevelData / RouteData / EventPointData[] / ScoreRuleData` 驱动）。

**第二章白盒 Gate（WorldState 最小集 5 键：`guard_a_departed / guard_b_active / dog_fed / bridge_open / poison_route_safe`；全量以 §6.2 的 13 词表为准）：**

| 关 | Gate |
|---|---|
| L05 | 一章正常切入；Q/F/E 均有可观察结果；事件后 Ninja Route 不丢失 |
| L06 | 完整喂狗 ≥1 次；道具消耗后 `carry_item` 回空；R 恢复初始状态（风险解"猫当诱饵"白盒只保状态接口，不加追逐物理） |
| L07 | Guard A/B 状态可被 Debug HUD 观察；错误顺序产生明确后果并记录 `FAIL_WRONG_ORDER`（仅诊断码，见 §15.2 仲裁） |
| L08 | ≥2 个 WorldState 同时变化；完成后进 `Chapter02_Unlock` |

**第三章 / Boss QA Gate（v1.2.10，9 条）：** 事件顺序可重复 / 吊车·酒葫芦可结算 / 蒺藜不可提前解决 / Boss 启动后玩家必须有移动任务 / 无操作不得判正常胜利 / 全不做可进 Emergency / Emergency 只产 1 爪 / R 重开清 Boss 状态 / Space 仅通关后进下一场景。Emergency 触发点 `EMERGENCY_POS=(930,290)`，按 E 触发；`BOSS_CALTROP` 从普通 `event_nodes` 分离（EventGroup=BOSS_COMBAT，§12.10）。工程修复记录：v1.2.9 修复 v1.2.8 中 L04 `scene_path` 文件名重复 `L` 的问题。

## 13.7 关卡生产管线（v1.2.13）

**9 步生产链：** Level Brief → 事件图 → 路线 → 白盒 Scene → Data Resource → 双解法 → 失败/Reset → Validator → Art Lock。**事件预算：** CRITICAL 2–4 / STANDARD 1–3 / OPTIONAL 0–2，单关总 EventPoint 4–8（教学关可 <4，Boss 关可略高）。**数据最小集合：** LevelData / RouteData / EventPointData[] / WorldFlagData[] / ShortcutData[] / ScoreRuleData / VariantData（可选）/ BanterSet / AudioMap / ValidationRules（模板与 `validate_level_authoring.py` 见 v1.2.13 实现包）。

**高风险解五类形态：** 更晚窗口 / 更远路线 / 暴露操作 / NPC 联动 / 放弃资源位。**节奏红线：** 连续 2+ 事件原地等待 >2 秒需复查。**验收门槛：** 内容（≥1 新决策 / ≥1 旧机制重组 / ≥1 高风险解 / ≥2 新笑点）+ 技术（Validator 0 error 等 6 条）+ 体验 4 条。**跨关能力递进基线：** L01 理解规则 → … → L12 综合考试（逐关生产卡见 v1.2.13 Production Cards）。L13+ 快速创建：复制模板 → 走同一管线，不绕过验收门槛。

## 13.8 试玩平衡基线（v1.2.23 / v1.2.24）

- **时长基线：** 见 §5.2（v1.2.24 修正版）；每关"主失败类型"指定：L01/L02/L05/L09=`FAIL_TOO_LATE`，L03=`FAIL_SUSPICION`，L04/L06–L08/L10/L11=`FAIL_WRONG_ORDER`，L12=`FAIL_BOSS_FINISHER`。
- **逐关调参杠杆（节选）：** L03=怀疑累积速率 / L05=搬运距离（搬运有效速度 90×0.85=76.5 px/s，首轮不提 `CARRY_SPEED_MULT`）/ L07=守卫 8s 巡逻·6s 回岗的可读节奏 / L08=三线程空间距离 / L12=Phase 2 蒺藜操作窗口。失败率过高先改主杠杆，不同时改 3 个以上变量；多处明示"不动猫移速 / 不加新机制"。
- **单关平衡卡：** 教学目标 + 过难/过易信号 + 主失败类型（v1.2.23 全表）。
- **试玩协议：** 8 名无经验玩家 × 3 轮（自然首通 → 重玩 → 追三爪），分离"看不懂 / 不熟 / 优化不出"三类问题；第二轮可加 4 名熟练玩家（v1.2.25）。
- **设计 Gate（v1.2.24 §9）：** 失败后能说出修改行为 ≥80%；重玩明显提速 ≥60%；同关 ≥2 种成功路线 ≥50%；L06 识别狗联动 / L07 识别换岗因果 / L08 描述三线程 / L12 Phase 2 主动处理蒺藜各 ≥50%。
- **冻结门槛（10 条）：** 12 关各有目标时长/主失败类型/首通 Gate、三章 Blind Gate 通过、Boss 主动操作 Gate、采样字段完整、三 Risk Style 各出一次满评价等（v1.2.23 checklist）。
- **风险排名：** L08 多线程过密 > L12 Boss 看戏 > L07 因果可读性 > L03 怀疑反馈 > L09 环境遮挡 > L05 搬运只剩慢 > L10 炸药只剩禁碰 > L04 双路线差异不足。

## 13.9 三路线试玩与采集管线（v1.2.25 / v1.2.26）

**三路线验收（每关，8 名新玩家 + 4 名熟练玩家）：**

| 验收项 | 标准 |
|---|---|
| 理解 Gate | ≥6/8 能说出主决策 |
| 行为 Gate | ≥5/8 第二次主动改策略 |
| 多解 Gate | ≥3/8 无提示找到第二解 |
| 失败 Gate | 抽 5 次失败，≥4/5 能说出下一步改变 |
| SAFE 成立 | ≥6/8 新玩家完成 |
| BALANCED 成立 | ≥4/8 自然产生（0–1 人 = 反馈不足） |
| RISKY 成立 | 熟练玩家 ≥2/4 主动尝试 |

**调参决策树：** 看不懂→修视觉/反馈；来不及→调时间杠杆；只会一解→加状态依赖/Shortcut；三爪只奖安全解→修 ScoreRule；**禁止"失败→加时间"作为第一反应**（与 §14 五层顺序互补：试玩归因用本决策树，改什么用五层）。

**采集管线（v1.2.26）：** xlsx 8 表（README / Run_Log / Event_Log / Level_Summary / Failure_Summary / Route_Summary / Dashboard / Post_Test_Feedback）+ `summarize_playtest.py` 自动统计。Run Log 21 字段、Event Log 19 字段；规模 8 人 × 12 关 = 96 条主记录，重试追加 AttemptNo 不覆盖。路线编码 SAFE / BALANCED / RISKY / **UNKNOWN**（无法判断必填 UNKNOWN，不许猜）。**采集伦理：** 不提前告知三路线存在；只记录实际行为；不使用虚构玩家数据。**5 条复核信号：** Clear%<50% 先查可读性 / 中位时长超首通上界查路线与等待 / RouteObserved 长期单一查三路线差异 / ChangedStrategy 低+Retry 高 = 知失败不知改法 / UnderstoodCore 低回查教程。**最终美术锁定 10 项清单**（v1.2.25 §10）并入 §13.5 Release Gate 前置。

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

1. ~~操作设备~~ **已定**：移动端优先（触屏虚拟摇杆为第一操作形态），键鼠/手柄经同一 Action 层兼容；v1.5.6 已实现三套输入自动切换（GameInputManager），手柄映射见 §2.2。
2. **卖萌冷却：** 20s 初值，垂直切片实测调整。
3. **吹牛台词生成：** 已定纯模板拼接，不接 LLM（v1.2.16 重申：禁止随机选句）。
4. ~~猫叫声效来源~~ **已定（v1.5.8）**：原创程序合成猫叫 ×3 + 轮换播放，见 §9.3。
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
| 酒葫芦伤害（二次冲突） | v1.2.10"开战 -30 HP" vs 上条既有仲裁 | **维持既有仲裁：仅延迟、无伤害**；v1.2.10 相关表述作废 |
| Boss 阶段枚举 | §6.3 `BOSS_INTRO…BOSS_RETREAT` vs v1.2.22 qa_contract `NONE/PREPARE/…/DEFEAT` | 以 §6.3 全枚举为准，Validator 兼容映射 |
| 关卡运行入口命名 | §12.3 `level_controller.gd / event_point.gd` vs v1.2.11 `unified_level_manager.gd / unified_event_point.gd` | **以 v1.2.11 为准**；旧章节 Manager 为兼容 shim，2 个版本周期后删除 |
| EventPointData 字段 | §12.4 旧字段 `required_item / validator_rules[]` vs v1.2.12 `consume_carry_item / success_effects[]` | **以 v1.2.12 实现为准**（§12.4 已更新字段清单） |
| 怀疑数值口径 | §2.4 视锥判定（边缘 +30/次、中心 60/s）vs v1.2.12 `EventBehaviorData.suspicion`（默认 10.0、guard 15.0） | 视锥判定为玩家可见语义不变；`suspicion` 为行为级默认增量的实现参数，垂直切片近似期使用，生产版回归视锥口径 |
| 存档结构与存储位置 | §11.5 旧单文件（含 settings/input_bindings）vs v1.2.15/19/20/21 双文件 | **双文件**：进度 `save.cfg` + 设置 `settings.cfg`；§11.5 已重写 |
| 关卡场景路径 | §15.2 既有仲裁 `scenes/levels/ch01_village/L01_first_job.tscn` vs v1.2.20/21 实现 `res://scenes/levels/L01.tscn` | **维持 snake_case 章节目录仲裁**，实现侧 LevelCatalog 需修正 |
| L09/L11 场景命名 | v1.2.10 `thunder_night / getting_busier` vs 既有仲裁 `storm_night / busy_gate` | 维持既有仲裁命名 |
| L07 依赖链 | §6.2 Guard A→B→Dog→Bridge→Poison vs v1.2.9 Guard A→B→Poison→Bridge（无 Dog） | 以 §6.2 为准；v1.2.9 为白盒简化链 |
| L07 错误顺序处理 | §6.2"不弹顺序错了，世界产生后果" vs v1.2.9 Gate 要求明确 `FAIL_WRONG_ORDER` | `FAIL_WRONG_ORDER` 仅作诊断/日志码，不作直接失败弹窗；玩家从后果推断 |
| L05 教学定位 | §6.2"L05 首次正式学 Q" vs v1.2.9 L05 观察链（Q 移入 L06） | 维持 GDD：L05 教 Q（§8.3 TutorialDirector 排期同为 L05） |
| 结算时长 | §2.1 旧"~30 秒" vs v1.2.16 首次 15–25s | **首次 15–25s / 重复 8–12s**（§2.1 已更新） |
| 老板娘角色 | §7.1/§7.2 有老板娘 vs v1.2.16 实现包无 | **保留老板娘**（品牌记忆点），实现包待补 |
| 箭头情绪表达 | §8.1"颜色随心情变化" vs v1.2.14"动画节奏 + 无障碍" | 以动画节奏为主、颜色仅辅助 |
| 猫技艺阈值 | §11.3 旧口径（三章<20 / 3 关零疾跑 / 单次 3 层因果）vs v1.2.15（3 关<20 / 1 关零疾跑 / 累计 3 次） | **以 v1.2.15 阈值表为准**（§11.3 已更新） |
| 调参顺序表述 | §14 五层（空间→时间→操作→认知→内容）vs v1.2.23/26 四层（可读性→时间→风险→表现） | 二者互补：试玩归因用四层决策树，"改什么"用五层顺序；首查可读性 |
| Space/Enter 职责 | §2.2 旧"Space 进下一关" vs v1.2.18 Space=`jump`、Enter=`confirm` | Space 固定为跳跃；结算"下一关"走 `confirm`；结算首 1 秒屏蔽输入仍成立 |
| 事件总数合同 | GDD 无出处 vs v1.2.22 `expected_events=46` | 采纳为工程合同值（12 关 46 事件，LevelValidator 硬指标） |
| 12 关 target_time | 三阶段演变：v1.2.5 表（L05–L12 = 85/80/95/110/90/100/120/125）→ v1.2.24 Balance Sheet（80/90/100/115/100/105/125/150）→ v1.5.1 实现版（与 v1.2.24 相同） | **以 v1.5.1 实现版为当前基线**——实现侧已锁定，下一次变更须来自 ≥8 人同关卡试玩数据；GDD §5.2 已同步 |
| 手柄映射 | v1.2.18 设计稿（疾跑 RT / 重开 Select）vs v1.5.6 实现（疾跑 RB / 重开 LS） | **以 v1.5.6 实现为准**——已进代码且通过输入整合验收；§2.2 表已同步 |
| L11 第七事件 | GDD 设计 Cliff vs 实现 GATE（城门检查点，PASSIVE） | **以实现为准：L11 采用 GATE**——悬崖玩法已被 L04/L09 覆盖，Gate 提供章节收口的流程控制；Cliff 保留在威胁库 |
| L10 事件 ID 冲突 | `L10_E04_CALTROP` 与 `L10_E04_POISON` 同号并存 | **POISON 重编号为 `L10_E05_POISON`**；命名规则补充：同关 E## 序号唯一，EventLog/回放/QA/统计均依赖此唯一性 |

## 15.3 实现债登记（v1.4.6 起）

设计合同与实现的偏差在此登记，按处理优先级排序（详情见《猫忍不住》_v1.6.0_实现审查记录.md）：

1. **[已落地]** chain_rescue 判定改为沿 caused_event_id 链（§7.4）（沿 caused_event_id 链判定，unified_level_manager.gd）
2. **[已落地]** L11 Gate 裁定在数据层落地（§6.3）（`L11_E07_GATE.tres` 已在数据层，GDD §6.3 已同步裁定）
3. **[已落地]** 建立 VariantData + 12 个 Variant B 资源（Release Gate 要求"12 个 Variant B 可加载"，当前不存在 variants 数据资产）（VariantData + 12 个 VB 资源 + LevelData.variant + 选关 B 开关；route/npc 深层覆盖标 TODO）
4. **[已落地]** 建立 HardMode LevelModifier 体系（当前只有解锁状态，无 Ninja +10% / 犹豫 -0.5s / 怀疑收益 +10% 的实际执行层）（LevelModifier + hard_mode.tres + 存档开关 + 选关开关；犹豫窗口经 timeout 联动实现）
5. **[已落地]** Boss `phase_changed` 仅在 phase 实际变化时 emit
6. **[部分]** 清理 Legacy 脚本栈（`level_manager.gd / dock_*/castle_*` 并行旧栈；`dock_event_point.gd` 直读物理键 KEY_F/KEY_E 绕过 Action 层，手柄/触控在该路径失效）（dock_event_point.gd 已改走 Action 层 InputMap；旧栈拆分仍在）
7. **[已落地]** EventLog 区分 `ACTION_START / RESOLVED / FAILED` 三阶段，仅 RESOLVED 允许写 success=true（ACTION_START / RESOLVED / FAILED 三阶段标记全部落地）
8. UnifiedLevelManager（2198 行）拆分 + SceneArt 独立成 L01–L12 Art Scene
9. **[已落地]** 接入 Ninja Voice（Voice1~10.wav，`play_ninja_voice()` 当前为 pass）（Voice1~10 已接入 play_ninja_voice，hurt/confused/proud/scared 四组轮换 + 600ms 冷却 + 音高随机）
10. **[已落地]** export_presets 版本号跟随实现版本（当前滞留 0.1.0）（已升 1.6.0）
11. **[已落地]** GitHub Actions + Godot smoke test（发布前必须；静态通过 ≠ 运行通过）（.github/workflows/godot-ci.yml：导入+编译检查+30 帧冒烟）

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
