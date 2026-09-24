# 《影猫》游戏设计文档
## v1.1 · Release Candidate / 修订冻结版

> 基于《影猫》v1.0 Release Candidate 与 v1.0 审查报告修订。
>
> **本版目标：解决上一版的 P0 设计问题，并把“产品范围、评分、Boss 主动性、试玩 Gate、素材生产清单”正式冻结。**
>
> 原始设计核心继续保留：反向护送、猫不能战斗、忍者固定路线、“可预测的蠢”、事件驱动、EventLog、居酒屋结算。fileciteturn0file0L11-L23

---

# 0. v1.1 修订结论

v1.0 最大的问题不是缺少玩法，而是：

1. **发行范围口径没有真正冻结。**
2. **高风险玩法与最高评价之间存在冲突。**
3. **Boss 有变成“提前准备完 → 观看战斗”的风险。**
4. **试玩验收语言过于模糊。**
5. **Asset Manifest 没有成为单一生产入口。**

v1.1 对这五项全部给出正式规则。

本版之后，核心 Gameplay 规则不再因为外围内容修改而漂移。

---

# 1. 产品定义

## 1.1 一句话

> **大名鼎鼎的忍者出任务，其实一路都是他的猫在暗中替他扫平一切——而他对此一无所知。**

## 1.2 正式类型

**俯视角 · 实时路线调度 × 事件解谜 × 反向护送 × 喜剧叙事**

## 1.3 核心幻想

玩家永远不是台上的英雄。

忍者是台上英雄。

猫负责：

- 提前处理危险
- 改变 NPC 位置
- 调整环境
- 搬运物品
- 制造事件链
- 在最后时刻救场

结算时忍者把功劳全部归到自己身上。

## 1.4 三条最高设计戒律

### 戒律 1：功劳永远归他，乐趣永远归你。

### 戒律 2：蠢要可预测。

### 戒律 3：玩家失败后必须知道自己为什么失败。

---

# 2. v1.1 发行范围正式冻结

本版不再使用“首发包含”与“资源不足可砍”两套口径。

## 2.1 CORE 必须完成

以下是 **Gameplay Core**：

- 猫移动
- 疾跑
- E 互动
- Q 叼取 / 放置
- F 喵叫
- Ctrl 卖萌
- JumpPoint
- CatTunnel
- 忍者固定路线
- EventPoint
- WorldState
- NPC 状态机
- 怀疑系统
- 三猫爪评分
- 快速失败 / 重试
- 三个正式关卡
- Boss 战
- 居酒屋基础结算

**CORE 缺一不可。**

## 2.2 RC REQUIRED 必须进入发布候选版

- 忍者动态吹牛
- 三关平衡参数
- 失败诊断
- 15 个以内系统成就
- 5 套猫外观
- 鱼干收集
- Hard Mode
- 完整 UI / HUD
- 手柄支持
- Save / Load
- LevelValidator
- Debug Build
- Audio 分层
- Accessibility 基础项

## 2.3 RC OPTIONAL 可砍

以下不影响核心版本验收：

- Replay 事件剪辑
- 分享卡
- 第三关以外的额外彩蛋
- 居酒屋完整扩展演出
- 第 2 套以后忍者性格
- 额外剧本变体

如果开发资源不足，优先砍 OPTIONAL，不得砍 CORE。

---

# 3. 三个版本状态

为了避免“GDD 名义上的 v1.0 与实际制作状态不一致”，正式采用：

```text
v1.1 Gameplay Freeze
    ↓
v1.1 Production Candidate
    ↓
v1.1 Release Candidate
```

## Gameplay Freeze

核心玩法已冻结。

## Production Candidate

资产、关卡、音频、动画进入锁定。

## Release Candidate

全部 P0 / P1 Bug 清理完成并通过玩家体验 Gate。

---

# 4. 三关正式结构

## 第一关《初出茅庐》

关键词：

> **行动**

玩家必须学会：

> 提前赶场。

## 第二关《月夜码头》

关键词：

> **规划**

玩家必须学会：

> 排序和联动。

## 第三关《天守阁》

关键词：

> **操纵**

玩家必须学会：

> 同时管理普通事件与 Boss 战。

---

# 5. 第一关最终目标

## 5.1 学习结果

玩家第一次完整通关后，应理解：

```text
忍者会按路线走
↓
我可以提前跑到前面
↓
我处理危险
↓
他就会安全通过
```

并且第一次体验：

```text
被看到没关系
↓
做坏事被看到才有怀疑
↓
卖萌可以化解
```

## 5.2 第一关事件

1. 绊绳
2. 巡逻守卫
3. 水沟 / 木箱

## 5.3 时间

| 指标 | v1.1 |
|---|---:|
| 新玩家 | 35–70s |
| 熟练玩家 | 25–40s |
| 三猫爪目标 | ≤60s |

---

# 6. 第二关最终目标

关键词：

> **先后顺序**

必须让玩家认识到：

> 处理 A 会改变 B。

## 6.1 事件

- Guard A
- Dog
- Guard B
- Caltrop
- Crate / Bridge
- Poison

## 6.2 核心关系

```text
A 离岗
↓
B 换岗
↓
玩家改变 Dog
↓
Guard 改变位置
↓
Bridge / Caltrop 窗口改变
↓
Antidote 运输
↓
Goal
```

---

# 7. 第三关最终目标

关键词：

> **多线程系统操纵**

玩家已经会：

- 提前准备
- 排顺序
- 利用 NPC
- 利用资源
- 利用捷径

第三关要求：

> 一边处理 Boss，一边继续管理场地。

---

# 8. 核心数值冻结

```text
CAT_SPEED = 90
CAT_SPRINT_SPEED = 160
CAT_STAMINA_MAX = 100
CAT_SPRINT_COST = 25/s
CAT_STAMINA_REGEN = 20/s

CARRY_SPEED_MULT = 0.85

MEOW_RADIUS = 120

SUSPICION_MAX = 100
SUSPICION_NOTICE = 25
SUSPICION_ALERT = 50
SUSPICION_HIGH = 80

EMOTE_COOLDOWN = 20

NINJA_BASE_SPEED = 60
NINJA_PROUD_SPEED = 66

NINJA_SEARCH_TIMEOUT = 3

DEFAULT_EVENT_TIMEOUT = 5–8

BOSS_PREPARE_TIME = 8

EMERGENCY_RESCUE_WINDOW = 1.5–2
```

关卡不能直接修改这些参数。

必须使用：

```text
LevelModifier
```

并写入 LevelData。

---

# 9. 怀疑系统最终定义

## 9.1 空间语言

```text
猫出现
= 正常

猫做事
= 可疑

猫持续做事
= 高危

卖萌
= 误解

离开行动区域
= 当前动作停止累积
```

## 9.2 阈值

| 值 | 状态 | 表现 |
|---:|---|---|
| 0–24 | Normal | 无 |
| 25–49 | Notice | 问号 |
| 50–79 | Alert | 回头 |
| 80–99 | High Alert | 搜索 |
| 100 | Broken Cover | 失败 |

## 9.3 重要修正

“猫离开”只意味着：

> **当前暴露动作停止新增怀疑。**

不代表已经累积的怀疑值会自动减少。

因此：

```text
离开 = 停止继续犯错
卖萌 = 真正清除已有怀疑
```

这样怀疑系统不会因为跑两步就失去资源管理意义。

---

# 10. 高风险玩法与评分正式解耦

这是 v1.1 最重要的修改之一。

上一版存在：

> 鼓励极限救场，但最高评价仍然偏安全路线。

v1.1 改为：

> **三猫爪不是单一答案，而是表现条件集合。**

---

# 11. 三猫爪最终规则

## 猫爪 1

只要：

```text
mission_complete = true
```

即可。

---

## 猫爪 2

必须同时满足：

```text
mission_complete
AND ninja_hp >= 2
AND max_suspicion < 80
```

---

## 猫爪 3

必须满足基础资格：

```text
mission_complete
AND ninja_hp >= 2
```

然后以下 6 项中满足 **4 项**：

```text
A. ninja_hp = 3
B. max_suspicion < 50
C. elapsed_time <= target_time
D. high_risk_rescue >= 1
E. chain_rescue >= 1
F. shortcut_or_dependency_mastery = true
```

第三关额外增加：

```text
G. boss_mechanics_success >= 2
```

第三关从 A–G 中满足 4 项即可。

## 11.1 保护机制

高风险玩法不能通过“故意让忍者受伤”刷分。

因此：

```text
Ninja HP < 2
```

永远不允许 3 猫爪。

## 11.2 结果

现在存在至少三种满评价思路：

### 稳健型

无伤 + 低怀疑 + 时间。

### 调度型

零伤 + 联动 + 捷径 + 时间。

### 极限型

少量风险 + 高风险救场 + 联动 + 快速完成。

这样重玩才有真正的策略空间。

---

# 12. Risk Style 正式作用

Risk Style 不再单纯作为一句文案。

它用于：

- 结算台词
- 成就统计
- 猫技艺记录
- Replay 选择

不直接提供额外数值奖励。

三个等级：

```text
SAFE
BALANCED
RISKY
```

---

# 13. 猫技艺系统

这是 v1.1 新增的轻量长期重玩系统。

它不是角色成长。

它是：

> **玩家自己的操作履历。**

## 13.1 技艺示例

### 极限拆绳

累计 3 次在最后 1 秒内完成绊绳。

### 借狗之势

累计 5 次使用：

```text
Dog → Bark → Guard
```

### 不留痕迹

三关最高怀疑都 < 20。

### 猫步

完成一关且疾跑时间 = 0。

### 幕后操盘

通过至少 3 层因果链完成任务。

### 最后一秒

完成 1 次 Emergency Rescue。

## 13.2 功能

解锁：

- 结算徽章
- 个人统计
- 额外台词
- 猫的称号

不解锁强力数值。

---

# 14. Boss 战 P0 修正

Boss 不允许成为：

```text
提前把 3 个东西做完
↓
站旁边看
```

## 14.1 三个机关

### A 吊车

提前准备。

### B 蒺藜

**Boss 战过程中处理最有价值。**

### C 酒葫芦

提前准备。

这样 Boss 战永远至少存在一个实时操作任务。

---

# 15. Boss 战最终状态

```text
BOSS_INTRO
↓
BOSS_PREPARE
↓
BOSS_PHASE_1
↓
BOSS_PHASE_2
↓
BOSS_PHASE_3
↓
BOSS_DEFEATED / RETREAT
```

## 15.1 Phase 1

Boss 试探。

吊车可触发。

## 15.2 Phase 2

Boss 冲锋。

此时：

> 蒺藜进入最佳处理窗口。

玩家必须赶过去：

```text
发现冲锋路线
↓
抄捷径
↓
撒蒺藜
↓
Boss 冲锋
↓
触发
```

## 15.3 Phase 3

根据 Boss HP 判断结尾。

---

# 16. Boss 玩家主动性 Gate

第三关 Boss 测试时：

至少：

```text
60% 测试玩家
```

应在 Boss 已开始行动后继续主动移动处理机关。

如果低于：

> Boss 战返工。

这不是数值问题，而是结构问题。

---

# 17. Boss 三机关最终平衡

| 机关 | 准备 | 最佳触发 | HP 影响 | 玩家定位 |
|---|---|---|---:|---|
| 吊车 | Boss 前 | Phase 1 | -40 | 提前计划 |
| 蒺藜 | 可提前 | Phase 2 | -30 | 战中救场 |
| 酒葫芦 | Boss 前 | Intro | 延迟 10s | 保底资源 |

---

# 18. Emergency Rescue 正式定位

Emergency Rescue：

> **不是第四个 Boss 机关。**

它只是：

> Fail-safe。

## 18.1 触发条件

只有在：

```text
Boss Finish
AND Ninja HP <= 1
```

时出现。

## 18.2 玩家行为

拍下木门横杆。

时间：

> 1.5–2 秒。

## 18.3 结果

- Ninja 保住 1 心
- Boss 撤退
- Mission Complete
- Paws = 1
- Emergency Rescue = true

## 18.4 禁止利用

故意不做所有机关，不会获得更高奖励。

Emergency：

- 不加猫爪
- 不加资源奖励
- 只产生特殊成就 / 结算文案

---

# 19. 重玩结构

固定地图不是问题。

问题是：

> 玩家有没有重新组合的理由。

因此 v1.1 将重玩动机分成四层。

## 第一层

更快。

## 第二层

更低怀疑。

## 第三层

更高风险但更漂亮。

## 第四层

完成不同猫技艺。

---

# 20. 确定性剧本变体

不引入随机地图。

允许加入：

> **手工制作、可预测的剧本变体。**

例如：

### 第一关

`Route Variant A`

绊绳位置固定。

`Route Variant B`

守卫巡逻方向改变。

### 第二关

`Dock Variant A`

Guard B 正常补位。

`Dock Variant B`

Dog 起始位置改变。

### 第三关

`Castle Variant A`

Boss 标准顺序。

`Castle Variant B`

Boss Phase 2 更早。

所有变体：

- 由数据驱动
- 有明确规则
- 不随机

---

# 21. 居酒屋结算最终规则

## 首次完成

完整结算：

```text
忍者进店
↓
拍桌
↓
吹牛
↓
幕后蒙太奇
↓
猫舔爪
↓
猫爪
```

## 重复挑战

默认压缩：

```text
吹牛一句
↓
猫舔爪
↓
猫爪
```

长度：

> 8–12 秒。

玩家可主动展开完整结算。

---

# 22. 吹牛生成器

正式采用：

```text
EventLog
↓
Importance
↓
Tags
↓
Compatible Template
↓
Fill Params
↓
Play
```

## 22.1 禁止

模板不得仅按随机数抽取。

## 22.2 优先级

```text
Emergency
>
Near Death
>
Boss
>
Chain
>
Route Change
>
普通成功
```

---

# 23. Replay 最终定位

Replay 为：

> **RC Optional。**

如果时间有限：

> 直接砍。

如果保留：

只记录：

- 最高风险事件
- 最长因果链
- Boss 最精彩操作

总时长：

> 8–10 秒。

任何 Replay Bug：

> 不得影响 Gameplay。

---

# 24. 关卡事件分类

为了控制测试工作量，所有 EventPoint 分成三个等级。

## CRITICAL

核心学习 / 核心关卡题。

要求：

- 至少 2 个解法
- 高风险解
- 因果关系
- 完整 QA

## STANDARD

普通推进事件。

要求：

- 1 个稳定标准解
- 1 个高风险解或捷径解
- 完整失败出口

## OPTIONAL

收藏 / 彩蛋。

要求：

- 不影响主线
- 不影响忍者存活
- 不进入主评分核心

这样避免“每个事件都必须做两套完整解法”导致内容生产债务。

---

# 25. 三关事件分级

## 第一关

```text
Tripwire = CRITICAL
Guard = CRITICAL
Watergap = CRITICAL
Pot = OPTIONAL
Fish = OPTIONAL
```

## 第二关

```text
Guard A = CRITICAL
Guard B = CRITICAL
Dog = CRITICAL
Bridge = CRITICAL
Poison = CRITICAL
Caltrop = STANDARD
Fish = OPTIONAL
```

## 第三关

```text
Tripwire = STANDARD
Dynamite = CRITICAL
Guard A = CRITICAL
Dog = CRITICAL
Caltrop = CRITICAL
Cliff = STANDARD
Poison = CRITICAL
Guard B = STANDARD
Boss 3 Mechanics = CRITICAL
```

---

# 26. EventLog 最终结构

核心 EventLog 只保存 Gameplay Facts：

```text
timestamp
level_id
event_id
actor_id
event_type
action
success
risk_level
high_risk
player_position
ninja_position
ninja_hp_before
ninja_hp_after
suspicion_before
suspicion_after
world_changes
caused_event_id
route_change
shortcut_used
carry_item
carry_duration
emergency_window
mood
```

不再继续把 UI / 动画数据塞进核心协议。

Replay / Boast 从核心日志派生。

---

# 27. 世界状态

只保存事实：

```text
guard_a_departed
guard_b_active
dog_fed
bridge_open
poison_route_safe
boss_crane_ready
boss_caltrop_ready
boss_gourd_ready
boss_phase
boss_retreat
```

禁止保存：

```text
player_should_do_X
```

避免把攻略信息污染 Gameplay。

---

# 28. NinjaController

忍者行为仍然：

```text
固定路线
+
状态机
+
脚本分支
```

## 28.1 禁止

- 自由寻路
- 随机决定路线
- 随机决定危险反应
- 随机攻击

## 28.2 允许

- WorldState 驱动预设分支
- AlternativeRoute
- Personality Modifier
- 固定情绪

---

# 29. Ninja Personality

v1.1 首发正式人格：

> **NinjaBlue / 自恋型**

行为：

- 高自信
- 容易硬闯
- 喜欢自我解释
- 越成功越得意

其余人格：

> Post-Launch Candidate。

不进入 v1.1 Core。

---

# 30. 猫的“不能战斗”视觉规则

必须通过视觉统一表达：

- 猫没有攻击锁定 UI。
- 猫不能锁定敌人。
- 猫所有动作目标都是“环境”。
- 猫的攻击表现为拍、推、咬、拨。
- 即便影响 Boss，也是通过环境机关。

这样玩家无需读说明也知道：

> 猫不是战斗单位。

---

# 31. UI 最终原则

HUD 只回答：

```text
我在哪？
忍者在哪？
忍者安全吗？
我现在能做什么？
```

禁止回答：

```text
我要先做谁？
正确答案是什么？
```

## 31.1 怀疑

不显示数字。

用：

- 猫眼
- 问号
- 回头
- 搜索

表达。

---

# 32. 首局体验 Gate

### 测试样本

建议第一轮：

> **8 名此前没有体验过该游戏的玩家。**

## Gate A

至少 6 / 8：

> 无口头提示找到第一个危险。

## Gate B

至少 5 / 8：

> 主动跑到忍者前方处理事件。

## Gate C

至少 5 / 8：

> 理解猫出现本身不会产生怀疑。

## Gate D

至少 4 / 8：

> 主动尝试卖萌。

## Gate E

至少 6 / 8：

> 通关后能准确解释“自己在暗中帮助忍者”。

未达到任一 P0 Gate：

> 第一关不进入最终美术锁定。

---

# 33. 第二关 Gate

8 名新玩家中：

至少：

- 5 人使用至少一次 NPC 联动。
- 5 人搬运至少一次。
- 5 人使用至少两次猫捷径。
- 4 人失败后主动改变事件顺序。
- 4 人能解释至少一条因果链。

如果多数人反馈是：

> “东西太多。”

而不是：

> “我顺序弄错了。”

则复杂度过高。

---

# 34. 第三关 Gate

8 名测试者：

至少：

- 5 人在 Boss 前主动准备。
- 5 人在 Boss 战中仍移动操作。
- 4 人主动处理 Phase 2 蒺藜。
- 4 人能解释 Boss 至少一个伤害来源。
- 4 人理解 Emergency Rescue 是最后补救，而不是最佳路线。

---

# 35. 失败理解 Gate

每关抽取至少 5 次失败记录。

每次询问：

> “你下一次会改什么？”

至少 4 / 5：

> 能说出具体行为。

例如：

> “我应该早点叫狗。”

或者：

> “我应该先去拿药。”

若回答：

> “我不知道为什么死。”

则相关事件必须返工。

---

# 36. 平衡测试

每个核心事件至少进行：

- 标准成功
- 标准失败
- 最晚成功
- 被发现
- 重复触发
- Reset
- NPC 同时进入其他状态

每个 Boss 组合至少：

```text
A+B+C
A+B
A+C
B+C
A
B
C
None
```

均必须得到明确结果。

---

# 37. 失败原因编码

为了便于 QA，每次失败生成：

```text
FAIL_CODE
```

例如：

```text
FAIL_TOO_LATE
FAIL_WRONG_ORDER
FAIL_SUSPICION
FAIL_NINJA_DEATH
FAIL_BOSS_FINISHER
FAIL_ROUTE_BLOCKED
FAIL_TIMEOUT
```

结算 / Debug 可显示。

玩家只看到自然语言。

---

# 38. 关卡可维护性

每个关卡必须有：

```text
LevelData
RouteData
EventPointData[]
ShortcutData[]
WorldFlagData
ScoreRuleData
Banters
AudioMap
ValidationRules
```

设计师不直接改脚本。

原则：

> **数据控制内容，脚本控制行为。**

---

# 39. Asset Manifest

v1.1 正式要求维护唯一资产清单。

字段：

```text
AssetID
Path
UsedBy
Required
Fallback
Status
```

## 39.1 示例

| AssetID | Path | UsedBy | Required | Fallback | Status |
|---|---|---|---|---|---|
| CAT_BLACK | `Actor/Animal/CatBlack/SpriteSheetYellow.png` | Cat | 是 | 无 | Ready |
| NINJA_BLUE | `Actor/Character/NinjaBlue` | Ninja | 是 | NinjaGreen | Ready |
| DOG | `Actor/Animal/Dog*` | Dog | 是 | 其他 Dog | Ready |
| CRATE | `Items/Object/CrateEmpty.png` | Bridge / Boss | 是 | 工程 crate | Ready |
| DYNAMITE | `Items/Projectile/CrateDynamite.png` | Castle | 是 | 无 | Ready |
| CALTROP | `Items/Projectile/Caltrop.png` | Dock / Boss | 是 | 无 | Ready |
| POTION | `Items/Potion/LifePot.png` | Poison / Gourd | 是 | MilkPot | Ready |
| GOURD | `Items/Object/Gourd.png` | Boss | 是 | 无 | Ready |
| FISH | `Items/Food/Fish.png` | Dog / Collect | 是 | 无 | Ready |
| CRANE | `Backgrounds/Vehicles/Crane.png` | Boss | 是 | 无 | Ready |
| SCROLL | `Items/Scroll/Scroll.png` | Goal | 是 | 无 | Ready |
| EMOTE | `Ui/Emote/emote1~30.png` | Ninja | 是 | 无 | Ready |
| ARROW | `Ui/Arrow.png` | HUD | 是 | 无 | Ready |
| TUTO | `Ui/Input/Tuto.png` | Tutorial | 是 | 无 | Ready |
| LIFEBAR | `Ui/Receptacle/LifeBarMini*.png` | HUD | 是 | 无 | Ready |
| THUNDER | `FX/Elemental/Thunder` | Castle | 是 | 无 | Ready |
| RAIN | `FX/Particle/Rain.png` | Castle | 是 | 无 | Ready |

---

# 40. 音频 Manifest

来源继续优先采用现有素材包。

| 用途 | 文件 | 必须 |
|---|---|---|
| Village BGM | `Musics/23 - Road.ogg` | 是 |
| Village Alt | `Musics/26 - Lost Village.ogg` | 否 |
| Dock BGM | `Musics/18 - Aquatic.ogg` | 是 |
| Castle BGM | `Musics/10 - Dark Castle.ogg` | 是 |
| Boss Tension | `Musics/28 - Tension.ogg` | 是 |
| Ninja Voice | `Audio/Sounds/Voice/Voice1~10.wav` | 是 |
| Dog | `Audio/Sounds/Creature/Dog.wav` | 是 |
| Success | `Audio/Jingles/Success1~4.wav` | 是 |
| Meow | 外部原创 | 是 |

## 40.1 猫叫

仍是唯一明确外部音频缺口。

Fallback：

> 暂时使用包内 Voice 做临时原型，不进入最终版。

---

# 41. Accessibility

v1.1 基础要求：

## 视觉

重要信息不能只依赖颜色。

必须：

- 图标
- 动画
- 声音

至少两种同时表达关键危险。

## 操作

- 键位可重绑定
- 手柄支持
- 暂停完全暂停
- 不需要连续按键 QTE

---

# 42. Hard Mode 最终调整

Hard Mode 不再要求：

> 三关全部 3 猫爪。

改为：

```text
完成三关
→ Hard Mode

三关全部 3 猫爪
→ Hard+ / 特殊挑战
```

## Hard Mode

- Ninja +10%
- 犹豫 -0.5s
- Boss Prepare -2s
- 怀疑收益 +10%
- 提示减少

## Hard+

可以使用：

- 剧本变体
- 更高因果要求
- 更严格目标时间

但仍不新增核心操作。

---

# 43. Replay / 分享优先级

## P0

不需要。

## P1

Replay。

## P2

分享卡。

因此：

```text
Gameplay > Settlement > Meta > Replay > Share
```

---

# 44. 性能

保持：

- EventPoint 不全量高频轮询。
- Replay Buffer 固定大小。
- EventLog 轻量。
- 粒子可降级。
- Debug 不进入 Release。
- 关键事件避免大量动态 Allocation。

FPS 最终值在真实目标硬件上确认，不在 GDD 中虚构。

---

# 45. 发布 Bug 标准

## P0 = 0

包括：

- 无法通关
- 无限循环
- NPC 卡死
- 输入失效
- Save 损坏
- Boss 无法结束
- LevelValidator 漏掉致命问题

## P1

必须全部有明确 Workaround。

## P2

可以进入 Patch。

---

# 46. Release Gate

必须全部：

```text
[ ] Core Gameplay Lock
[ ] 3关可完整通关
[ ] Boss 主动操作成立
[ ] 三猫爪逻辑稳定
[ ] 失败原因可理解
[ ] 首局 Gate 通过
[ ] 第二关 Gate 通过
[ ] 第三关 Gate 通过
[ ] LevelValidator 全绿
[ ] Save / Load 正常
[ ] Input / Controller 正常
[ ] Audio 正常
[ ] Accessibility 基础项完成
[ ] P0 Bug = 0
[ ] P1 Bug 收敛
[ ] Asset Manifest 全部 Ready
```

---

# 47. v1.1 审查后的真正风险

经过 P0 修订后，最大风险已经从：

> “玩法不成立”

转变成：

> **“内容量不足以支撑重复游玩。”**

因此后续重点不是新增核心系统，而是：

- 剧本变体
- 猫技艺
- 不同风险打法
- 更丰富的行为驱动结算
- 更短的重复结算流程

---

# 48. 最终内容生产策略

以后每增加一项内容，必须先回答：

### Q1

它是否产生新的决策？

### Q2

它是否重新组合旧机制？

### Q3

它是否产生新的玩家行为？

至少满足：

> Q1 / Q2 / Q3 中两项。

否则不加入核心内容。

---

# 49. 最终三关生产公式

## 第一关

```text
新规则 1
+
基础规则 2
+
一次赶场
```

## 第二关

```text
旧规则 3
+
1 条因果链
+
资源冲突
+
多线程
```

## 第三关

```text
旧规则 5+
+
Boss
+
实时补救
+
最终救场
```

---

# 50. v1.1 最终设计判断

现在可以正式把：

```text
第一关 = 行动
第二关 = 规划
第三关 = 操纵
```

作为《影猫》的内容生产标准。

只要一关不符合这三层递进：

> 就不是简单“难度没调好”，而是关卡定位错误。

---

# 51. 最终玩家体验

第一次：

> “原来我是猫。”

第二次：

> “我应该早点跑。”

第三次：

> “这里可以先不处理。”

熟练之后：

> “我可以用狗改变守卫。”

Boss：

> “他开始打了，我还得赶过去！”

结算：

> “哈哈，他又以为是自己干的。”

---

# 52. 最终产品句

> **《影猫》是一款让玩家永远没有功劳，却永远掌控局面的反向护送游戏。**

忍者在台上。

猫在台下。

玩家知道所有真相。

忍者不知道。

每一次通关都应该让玩家产生：

> **“这局也是我救回来的。”**

