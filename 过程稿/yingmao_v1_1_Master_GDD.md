# 《影猫》v1.1 制作执行包 · Master GDD

> 状态：Production Candidate 基线
>
> 来源：v1.1 Release Candidate / 修订冻结版
>
> 目的：把已经冻结的玩法规则转成团队统一的“产品真相”，并定义其与 Godot 实现文档的边界。

---

## 0. 文档定位

本文件只回答四件事：

1. 《影猫》是什么。
2. v1.1 必须交付什么。
3. 哪些规则不可漂移。
4. 四份执行文档如何分工。

实现细节以 `System Spec` 为准，关卡空间与事件以 `Level Bible` 为准，任务、测试、资产与发布以 `Production & QA` 为准。

### 0.1 设计真相原则

```text
Master GDD
  ↓ 定义“为什么 / 必须是什么”
System Spec
  ↓ 定义“怎么在 Godot 里实现”
Level Bible
  ↓ 定义“每一关具体放什么”
Production & QA
  ↓ 定义“谁做、怎么验、何时锁”
```

> Godot 落地约定是执行层新增内容，不改变 v1.1 已冻结的玩法规则。

---

# 1. 产品定义

## 1.1 一句话

> **大名鼎鼎的忍者出任务，其实一路都是他的猫在暗中替他扫平一切——而他对此一无所知。**

## 1.2 正式类型

**俯视角 · 实时路线调度 × 事件解谜 × 反向护送 × 喜剧叙事**

## 1.3 核心体验

玩家不是台上的英雄。

忍者是台上英雄。

猫负责：

- 提前处理危险
- 改变 NPC 位置
- 调整环境
- 搬运物品
- 制造事件链
- 在最后时刻救场

### 三条最高设计戒律

1. **功劳永远归他，乐趣永远归你。**
2. **蠢要可预测。**
3. **玩家失败后必须知道自己为什么失败。**

---

# 2. v1.1 范围冻结

## 2.1 CORE

以下内容一项都不能删：

| ID | 系统 | 必须 | Owner |
|---|---|---:|---|
| CORE-01 | 猫移动 | 是 | Gameplay |
| CORE-02 | 疾跑 | 是 | Gameplay |
| CORE-03 | E 互动 | 是 | Gameplay |
| CORE-04 | Q 叼取/放置 | 是 | Gameplay |
| CORE-05 | F 喵叫 | 是 | Gameplay |
| CORE-06 | Ctrl 卖萌 | 是 | Gameplay |
| CORE-07 | JumpPoint | 是 | Level |
| CORE-08 | CatTunnel | 是 | Level |
| CORE-09 | 忍者固定路线 | 是 | Gameplay |
| CORE-10 | EventPoint | 是 | Gameplay |
| CORE-11 | WorldState | 是 | Gameplay |
| CORE-12 | NPC 状态机 | 是 | Gameplay |
| CORE-13 | 怀疑系统 | 是 | Gameplay |
| CORE-14 | 三猫爪评分 | 是 | UI/Gameplay |
| CORE-15 | 快速失败/重试 | 是 | UX |
| CORE-16 | 三个正式关卡 | 是 | Level |
| CORE-17 | Boss 战 | 是 | Level/Gameplay |
| CORE-18 | 居酒屋基础结算 | 是 | Meta |

## 2.2 RC REQUIRED

- 忍者动态吹牛
- 三关平衡参数
- 失败诊断
- 15 个以内系统成就
- 5 套猫外观
- 鱼干收集
- Hard Mode
- 完整 UI/HUD
- 手柄支持
- Save/Load
- LevelValidator
- Debug Build
- Audio 分层
- Accessibility 基础项

## 2.3 RC OPTIONAL

资源不足时只能从这里砍：

- Replay 事件剪辑
- 分享卡
- 第三关以外的额外彩蛋
- 居酒屋完整扩展演出
- 第 2 套以后忍者性格
- 额外剧本变体

---

# 3. 三阶段制作状态

```text
v1.1 Gameplay Freeze
    ↓
v1.1 Production Candidate
    ↓
v1.1 Release Candidate
```

### Gameplay Freeze

核心规则、操作、评分、事件因果已冻结。

### Production Candidate

场景、脚本接口、Data Resource、主要资产进入锁定。

### Release Candidate

全部 P0/P1 检查完成，真实设备与新手 Gate 通过。

---

# 4. 三关产品结构

| 关卡 | 名称 | 设计关键词 | 玩家能力 | 核心教学 |
|---|---|---|---|---|
| L01 | 初出茅庐 | 行动 | 提前赶场 | 先跑到前面 |
| L02 | 月夜码头 | 规划 | 排序/联动 | A 会改变 B |
| L03 | 天守阁 | 操纵 | 多线程管理 | Boss 战中继续处理场地 |

### 内容生产标准

```text
第一关 = 行动
第二关 = 规划
第三关 = 操纵
```

不符合这三层递进的关卡，应回到设计审查，而不是只调难度。

---

# 5. 核心规则真相表

| 主题 | 冻结规则 |
|---|---|
| 猫 | 不能直接战斗 |
| 忍者 | 固定路线 + 状态机 + 脚本分支 |
| 随机性 | 核心关卡不依赖随机地图；可用手工制作确定性剧本变体 |
| 怀疑 | 被看到不等于可疑；人类式行动被看到才增加怀疑 |
| 离开 | 停止继续累积，不自动清除历史怀疑 |
| 卖萌 | 清除已累积怀疑 |
| Boss | 至少存在一项 Boss 战中实时处理的机制 |
| Emergency Rescue | 仅保底，不提高评价 |
| EventLog | 只保存 Gameplay Facts |
| WorldState | 只保存事实，不保存攻略 |
| 数据层 | 设计师通过 Data Resource 驱动内容 |
| 脚本层 | 脚本负责行为与运行时状态机 |

---

# 6. 核心数值基线

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

关卡不得直接篡改上述全局基线。所有关卡差异通过 `LevelModifier` 进入 `LevelData`。

---

# 7. 三猫爪评分

## 7.1 猫爪 1

```text
mission_complete = true
```

## 7.2 猫爪 2

```text
mission_complete
AND ninja_hp >= 2
AND max_suspicion < 80
```

## 7.3 猫爪 3

基础资格：

```text
mission_complete
AND ninja_hp >= 2
```

然后满足以下条件中的 4 项：

```text
A. ninja_hp = 3
B. max_suspicion < 50
C. elapsed_time <= target_time
D. high_risk_rescue >= 1
E. chain_rescue >= 1
F. shortcut_or_dependency_mastery = true
```

第三关加入：

```text
G. boss_mechanics_success >= 2
```

第三关从 A–G 满足 4 项即可。

### 保护规则

`Ninja HP < 2` 永远不能获得 3 猫爪。

---

# 8. 怀疑系统

| 区间 | 状态 | 玩家反馈 |
|---:|---|---|
| 0–24 | Normal | 无 |
| 25–49 | Notice | 问号 |
| 50–79 | Alert | 回头 |
| 80–99 | High Alert | 搜索 |
| 100 | Broken Cover | 失败 |

### 语义

```text
猫出现 = 正常
猫做事 = 可疑
猫持续做事 = 高危
卖萌 = 清除怀疑
离开行动区域 = 停止当前动作继续累积
```

重要：离开不衰减历史怀疑。

---

# 9. Boss 真相

Boss 三机关：

| 机关 | 设计职责 |
|---|---|
| 吊车 | Boss 前准备 |
| 蒺藜 | Boss Phase 2 战中操作 |
| 酒葫芦 | Boss 前/Intro 保底资源 |

Boss 状态：

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

`Emergency Rescue` 不是第四个机关，只在 Boss Finish 且 Ninja HP <= 1 时出现；完成仍只有 1 猫爪。

---

# 10. 重玩层

第一层：更快。

第二层：更低怀疑。

第三层：更高风险但更漂亮。

第四层：猫技艺与收集。

### 确定性剧本变体

允许 A/B 手工变体，但不使用不可预测随机地图。

例如：

```text
L01 Route A / Route B
L02 Dock A / Dock B
L03 Castle A / Castle B
```

所有变体数据驱动。

---

# 11. 居酒屋结算

首次完成：

```text
忍者进店
→ 拍桌
→ 吹牛
→ 幕后蒙太奇
→ 猫舔爪
→ 猫爪
```

重复挑战默认 8–12 秒，可主动展开。

动态吹牛：

```text
EventLog
→ Importance
→ Tags
→ Template
→ Fill Params
→ Play
```

不得纯随机抽台词。

---

# 12. 玩家体验 Gate

### 第一关

8 名新玩家中至少：

- 6 人无提示找到第一个危险
- 5 人主动跑到忍者前方
- 5 人理解“被看到本身没关系”
- 4 人尝试卖萌
- 6 人能解释“猫在暗中帮助忍者”

### 第二关

- 5 人使用 NPC 联动
- 5 人搬运
- 5 人使用至少两次捷径
- 4 人失败后改变顺序
- 4 人解释一条因果链

### 第三关

- 5 人 Boss 前主动准备
- 5 人 Boss 战中继续移动
- 4 人主动处理 Phase 2 蒺藜
- 4 人解释至少一个 Boss 伤害来源
- 4 人理解 Emergency 是最后补救

### 失败理解

每关抽 5 次失败，至少 4/5 能说出下一次会改变的具体行为。

---

# 13. 失败编码

```text
FAIL_TOO_LATE
FAIL_WRONG_ORDER
FAIL_SUSPICION
FAIL_NINJA_DEATH
FAIL_BOSS_FINISHER
FAIL_ROUTE_BLOCKED
FAIL_TIMEOUT
```

玩家 UI 显示自然语言；Debug Build 显示 `FAIL_CODE`。

---

# 14. Godot 总体落地架构

## 14.1 推荐目录

```text
res://
├─ scenes/
│  ├─ boot/
│  ├─ core/
│  ├─ actors/
│  ├─ interactables/
│  ├─ ui/
│  ├─ levels/
│  │  ├─ l01_village/
│  │  ├─ l02_dock/
│  │  └─ l03_castle/
│  └─ meta/
├─ scripts/
│  ├─ core/
│  ├─ gameplay/
│  ├─ actors/
│  ├─ systems/
│  ├─ ui/
│  ├─ meta/
│  └─ debug/
├─ data/
│  ├─ levels/
│  ├─ events/
│  ├─ routes/
│  ├─ actors/
│  ├─ scoring/
│  ├─ dialogue/
│  ├─ audio/
│  ├─ achievements/
│  └─ variants/
├─ art/
├─ audio/
└─ tests/
```

## 14.2 Autoload 建议

| Autoload | 职责 |
|---|---|
| `GameState` | 当前流程、存档槽、当前关卡结果 |
| `EventBus` | 全局事件广播 |
| `AudioManager` | BGM/SFX 分层与切换 |
| `SaveManager` | Save/Load |
| `DebugService` | Debug HUD、作弊、日志 |

> 以上是 Godot 实现建议，不增加新的玩法系统。

---

# 15. 场景/脚本/Data Resource 总表

| 功能 | Godot Scene | Script | Data Resource |
|---|---|---|---|
| 猫 | `Cat.tscn` | `cat_controller.gd` | `cat_data.tres` |
| 忍者 | `Ninja.tscn` | `ninja_controller.gd` | `ninja_data.tres` |
| 守卫 | `Guard.tscn` | `npc_guard.gd` | `guard_data.tres` |
| 狗 | `Dog.tscn` | `npc_dog.gd` | `dog_data.tres` |
| 事件点 | `EventPoint.tscn` | `event_point.gd` | `event_data.tres` |
| JumpPoint | `JumpPoint.tscn` | `jump_point.gd` | `jump_data.tres` |
| Tunnel | `CatTunnel.tscn` | `cat_tunnel.gd` | `tunnel_data.tres` |
| 可搬运物 | `Carryable.tscn` | `carryable.gd` | `carryable_data.tres` |
| 怀疑 | 无独立场景或 World 子节点 | `suspicion_system.gd` | `suspicion_profile.tres` |
| WorldState | Core 节点 | `world_state.gd` | `world_state_schema.tres` |
| 评分 | Core 节点 | `score_system.gd` | `score_rule_data.tres` |
| Boss | `BossArena.tscn` | `boss_controller.gd` | `boss_data.tres` |
| 居酒屋 | `IzakayaResult.tscn` | `settlement_controller.gd` | `boast_template_data.tres` |

---

# 16. 场景边界

设计师允许直接编辑：

- TileMap / TileMapLayer
- Marker2D / Path2D
- EventPoint 参数
- RouteData
- JumpPoint
- CatTunnel
- LevelModifier
- Boast Tags
- AudioMap

设计师不应直接改：

- 猫核心状态机
- 忍者核心状态机
- 怀疑阈值全局常量
- 评分算法
- Save/Load 协议
- EventLog schema

---

# 17. 变更控制

任何变更先判断：

```text
是否改变玩家决策？
是否改变失败条件？
是否改变三猫爪？
是否改变 Boss 主循环？
是否改变固定路线逻辑？
```

若任一为“是”，必须回到 Gameplay Review。

若只是：

- 文案
- 动画
- UI 动效
- 音效
- 美术表现

可以在不修改规则的前提下迭代。

---

# 18. 完成定义 Definition of Done

一个系统只有同时满足以下条件，才算“完成”：

```text
[ ] 代码完成
[ ] Data Resource 完成
[ ] Scene 可运行
[ ] 正常路径通过
[ ] 失败路径通过
[ ] Reset 可用
[ ] Save/Load 不破坏状态
[ ] Debug 可定位
[ ] 音频绑定
[ ] UI 反馈齐全
[ ] 无 P0
[ ] 对应文档条目完成
```

---

# 19. 本执行包四文档互相引用

```text
Master GDD
  ├─ 规则冻结
  ├─ 范围冻结
  └─ 产品体验

System Spec
  ├─ Node Tree
  ├─ Script API
  ├─ State Machine
  └─ Data Schema

Level Bible
  ├─ L01
  ├─ L02
  └─ L03

Production & QA
  ├─ 任务拆分
  ├─ 资产生产
  ├─ 测试矩阵
  └─ Release Gate
```

---

# 20. 最终产品句

> **《影猫》是一款让玩家永远没有功劳，却永远掌控局面的反向护送游戏。**

忍者在台上。

猫在台下。

玩家知道所有真相。

忍者不知道。

每一次通关都应该让玩家产生：

> **“这局也是我救回来的。”**
