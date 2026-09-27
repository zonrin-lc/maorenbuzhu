# 《影猫》v1.1 制作执行包 · Production & QA

> 状态：Production Candidate 基线
>
> 目标：把四大内容域拆成可领取、可追踪、可验收的制作任务，并建立从素材、代码、Data Resource、关卡到 Release Candidate 的统一 QA 门槛。

---

# 0. 任务编号规则

```text
PRD  = 产品/设计
SYS  = 系统代码
DAT  = Data Resource
LVL  = 关卡
ART  = 美术接入
AUD  = 音频
UI   = UI
QA   = 测试
OPS  = 工程/构建
```

示例：

`SYS-CAT-001` = 猫移动系统。

`LVL-L02-014` = 第二关第 14 项制作任务。

---

# 1. 总制作阶段

```text
P0 工程骨架
↓
P1 核心系统闭环
↓
P2 L01 Vertical Slice
↓
P3 L02 / L03 内容化
↓
P4 UI / Audio / Save
↓
P5 Blind Playtest
↓
P6 Bug Burn-down
↓
P7 Release Candidate
```

禁止在 P5 前加入大量新玩法。

---

# 2. P0 工程骨架任务

## OPS-001 Project Tree

- 创建 `scenes/`
- 创建 `scripts/`
- 创建 `data/`
- 创建 `tests/`

DoD：路径统一、命名规则统一。

## OPS-002 Autoload

实现：

- GameState
- EventBus
- AudioManager
- SaveManager
- DebugService

DoD：启动、切场、退出不报错。

## OPS-003 Debug Build

必须提供：

```text
F1 Toggle Debug HUD
F2 Restart Level
F3 Force Event Success
F4 Force Event Failure
F5 Add Suspicion
F6 Clear Suspicion
F7 Damage Ninja
F8 Complete Boss Mechanic
```

Debug 快捷键只在 Debug Build 生效。

---

# 3. SYS 系统制作任务

| Task | 目标 | Scene | Script | Data |
|---|---|---|---|---|
| SYS-CAT-001 | 猫移动 | Cat.tscn | cat_controller.gd | CatData |
| SYS-CAT-002 | 疾跑/体力 | Cat.tscn | stamina_component.gd | CatData |
| SYS-CAT-003 | 互动 | Cat.tscn | interaction_controller.gd | InteractionProfile |
| SYS-CAT-004 | 叼取放置 | Carryable.tscn | carryable.gd | CarryableData |
| SYS-CAT-005 | 喵叫 | Cat.tscn | meow_controller.gd | MeowData |
| SYS-CAT-006 | 卖萌 | Cat.tscn | emote_controller.gd | EmoteData |
| SYS-CAT-007 | JumpPoint | JumpPoint.tscn | jump_point.gd | JumpData |
| SYS-CAT-008 | CatTunnel | CatTunnel.tscn | cat_tunnel.gd | TunnelData |
| SYS-NIN-001 | 路线 | Ninja.tscn | ninja_controller.gd | RouteData |
| SYS-NIN-002 | 状态机 | Ninja.tscn | ninja_state_machine.gd | NinjaData |
| SYS-NPC-001 | Guard FSM | Guard.tscn | npc_guard.gd | GuardData |
| SYS-NPC-002 | Dog FSM | Dog.tscn | npc_dog.gd | DogData |
| SYS-EVT-001 | EventPoint | EventPoint.tscn | event_point.gd | EventData |
| SYS-WLD-001 | WorldState | GameRoot.tscn | world_state.gd | WorldStateData |
| SYS-SUS-001 | 怀疑 | GameRoot.tscn | suspicion_system.gd | SuspicionProfile |
| SYS-SCR-001 | 猫爪 | GameRoot.tscn | score_system.gd | ScoreRuleData |
| SYS-LOG-001 | EventLog | GameRoot.tscn | event_log.gd | EventLogSchema |
| SYS-BOS-001 | Boss FSM | Boss.tscn | boss_controller.gd | BossData |
| SYS-SET-001 | 吹牛 | IzakayaResult.tscn | settlement_controller.gd | BoastTemplateData |

---

# 4. DAT Data Resource 制作任务

## DAT-001 CatData

字段：

```text
move_speed = 90
sprint_speed = 160
stamina_max = 100
sprint_cost_per_sec = 25
stamina_regen_per_sec = 20
carry_speed_mult = 0.85
meow_radius = 120
```

## DAT-002 NinjaData

```text
base_speed = 60
proud_speed = 66
search_timeout = 3
max_hp = 3
```

## DAT-003 SuspicionProfile

```text
max = 100
notice = 25
alert = 50
high = 80
emote_cooldown = 20
```

## DAT-004 ScoreRuleData

存储：

- Paw 1 rule
- Paw 2 rule
- Paw 3 rule
- target_time
- third-level boss requirement

## DAT-005 EventData

每个事件独立 Resource。

## DAT-006 RouteData

禁止写玩家攻略。

## DAT-007 LevelData

每关一个。

## DAT-008 LevelModifier

Hard Mode / 变体只通过此资源修改。

## DAT-009 BoastTemplateData

支持 tags 与 importance。

## DAT-010 AudioMap

建立事件 → SFX / Voice / BGM 的映射。

---

# 5. L01 Production Checklist

## Whitebox

```text
[ ] Spawn
[ ] Ninja start
[ ] Ninja goal
[ ] Route path
[ ] Tripwire zone
[ ] Guard zone
[ ] Watergap zone
[ ] Goal zone
[ ] JumpPoint
[ ] CatTunnel
```

## Gameplay

```text
[ ] Tripwire timing
[ ] Guard suspicion
[ ] Emote clear
[ ] Carry crate
[ ] Watergap success
[ ] Retry
```

## Data

```text
[ ] l01_village.tres
[ ] l01_main_route.tres
[ ] l01_variant_a.tres
[ ] l01_variant_b.tres
[ ] e01_tripwire
[ ] e02_guard
[ ] e03_watergap
[ ] score rules
[ ] validation rules
```

## UX

```text
[ ] Player can identify Ninja
[ ] Player can identify next danger
[ ] Player knows available action
[ ] Suspicion has no number
[ ] Failure explains why
```

---

# 6. L02 Production Checklist

## Whitebox

```text
[ ] Dock route
[ ] Guard A
[ ] Dog
[ ] Guard B
[ ] Bridge
[ ] Poison
[ ] Caltrop
[ ] Antidote path
[ ] 2+ shortcuts
```

## Cause Chain

```text
[ ] GuardA → GuardB
[ ] Dog → GuardB
[ ] GuardB → Bridge timing
[ ] Poison → Antidote
[ ] Carry → timing trade-off
```

## Failure

```text
[ ] Too late
[ ] Wrong order
[ ] Suspicion
[ ] Route blocked
[ ] Ninja death
```

## Data

```text
[ ] l02_dock.tres
[ ] route
[ ] events
[ ] world flags
[ ] variant A/B
[ ] score
[ ] validator
```

---

# 7. L03 Production Checklist

## Normal Events

```text
[ ] Tripwire
[ ] Dynamite
[ ] Guard A
[ ] Dog
[ ] Caltrop
[ ] Cliff
[ ] Poison
[ ] Guard B
```

## Boss

```text
[ ] Intro
[ ] Prepare 8s
[ ] Phase 1
[ ] Crane
[ ] Phase 2
[ ] Caltrop active window
[ ] Phase 3
[ ] Gourd
[ ] Retreat
[ ] Emergency Rescue
```

## Boss QA

必须测试：

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

所有组合必须明确结束或明确失败，不得 Soft Lock。

---

# 8. Asset Manifest 执行表

| AssetID | Path | UsedBy | Required | Fallback | 状态 |
|---|---|---|---:|---|---|
| CAT_BLACK | `Actor/Animal/CatBlack/SpriteSheetYellow.png` | Cat | 是 | 无 | Ready |
| NINJA_BLUE | `Actor/Character/NinjaBlue` | Ninja | 是 | NinjaGreen | Ready |
| DOG | `Actor/Animal/Dog*` | Dog | 是 | 其他 Dog | Ready |
| CRATE | `Items/Object/CrateEmpty.png` | Bridge/Boss | 是 | 工程 crate | Ready |
| DYNAMITE | `Items/Projectile/CrateDynamite.png` | Castle | 是 | 无 | Ready |
| CALTROP | `Items/Projectile/Caltrop.png` | Dock/Boss | 是 | 无 | Ready |
| POTION | `Items/Potion/LifePot.png` | Poison/Gourd | 是 | MilkPot | Ready |
| GOURD | `Items/Object/Gourd.png` | Boss | 是 | 无 | Ready |
| FISH | `Items/Food/Fish.png` | Dog/Collect | 是 | 无 | Ready |
| CRANE | `Backgrounds/Vehicles/Crane.png` | Boss | 是 | 无 | Ready |
| SCROLL | `Items/Scroll/Scroll.png` | Goal | 是 | 无 | Ready |
| EMOTE | `Ui/Emote/emote1~30.png` | Ninja | 是 | 无 | Ready |
| ARROW | `Ui/Arrow.png` | HUD | 是 | 无 | Ready |
| TUTO | `Ui/Input/Tuto.png` | Tutorial | 是 | 无 | Ready |
| LIFEBAR | `Ui/Receptacle/LifeBarMini*.png` | HUD | 是 | 无 | Ready |
| THUNDER | `FX/Elemental/Thunder` | Castle | 是 | 无 | Ready |
| RAIN | `FX/Particle/Rain.png` | Castle | 是 | 无 | Ready |

资产状态只能使用：

```text
Missing
InProgress
Ready
Locked
```

---

# 9. Audio Manifest

| 用途 | 文件 | 必须 |
|---|---|---:|
| Village BGM | `Musics/23 - Road.ogg` | 是 |
| Village Alt | `Musics/26 - Lost Village.ogg` | 否 |
| Dock BGM | `Musics/18 - Aquatic.ogg` | 是 |
| Castle BGM | `Musics/10 - Dark Castle.ogg` | 是 |
| Boss Tension | `Musics/28 - Tension.ogg` | 是 |
| Ninja Voice | `Audio/Sounds/Voice/Voice1~10.wav` | 是 |
| Dog | `Audio/Sounds/Creature/Dog.wav` | 是 |
| Success | `Audio/Jingles/Success1~4.wav` | 是 |
| Meow | 外部原创 | 是 |

猫叫是明确的外部音频缺口；临时原型可用包内 Voice 替代，但不能进入最终版交付。

---

# 10. UI 生产任务

| Task | 内容 | DoD |
|---|---|---|
| UI-001 | HUD | 信息只回答位置/安全/可行动作 |
| UI-002 | Ninja marker | 清楚但不遮挡路线 |
| UI-003 | Suspicion | 不显示数字 |
| UI-004 | Action Prompt | 只显示当前可做动作 |
| UI-005 | Goal | 不变成攻略箭头 |
| UI-006 | Result | 猫爪与核心数据清晰 |
| UI-007 | Pause | 真暂停 |
| UI-008 | Input Rebind | 键位保存有效 |
| UI-009 | Controller | 手柄全流程可玩 |

---

# 11. Accessibility QA

必须验证：

```text
[ ] 关键危险不是只靠颜色
[ ] 关键危险有动画/图标
[ ] 关键危险有声音
[ ] 可重绑定
[ ] 手柄支持
[ ] Pause 完全暂停
[ ] 无连续按键 QTE
```

---

# 12. QA 功能测试矩阵

每个核心事件：

| Case | 通过条件 |
|---|---|
| Standard Success | 标准解稳定成功 |
| Standard Fail | 标准错误稳定失败 |
| Last Moment | 最晚成功窗口正确 |
| Seen | 被发现语义正确 |
| Repeat | 重复触发不破坏状态 |
| Reset | Restart 后状态清零 |
| NPC Overlap | NPC 同时进入另一状态可处理 |

每个 Boss 机制：

```text
Prep
ActiveWindow
LateTrigger
WrongOrder
Fail
Reset
Save/Load
```

---

# 13. Automated Validation

## LevelValidator

必须每次打包前跑。

输出：

```text
Level / Rules / Asset / Route / Event / Score / Boss
```

任何 CRITICAL FAIL：

> Build Blocker

## SaveValidator

检查：

```text
fresh save
mid-level save
completed level
hard mode unlock
settings
input bindings
```

---

# 14. Playtest Gate

## Gate A First Session

8 名新玩家：

```text
>=6 找到第一危险
>=5 提前跑到忍者前方
>=5 理解被看到没关系
>=4 尝试卖萌
>=6 能解释核心玩法
```

## Gate B Dock

```text
>=5 NPC linkage
>=5 Carry
>=5 2+ shortcuts
>=4 failure 后改变顺序
>=4 能解释因果链
```

## Gate C Boss

```text
>=5 Boss 前准备
>=5 Boss 中继续移动
>=4 Phase2 Caltrop
>=4 解释 Boss 伤害
>=4 理解 Emergency = last resort
```

## Gate D Failure Understanding

每关 5 次失败。

```text
>=4/5 能说出下一次具体改变
```

---

# 15. 平衡测试计划

核心事件必须记录：

```text
first_clear_time
best_clear_time
median_clear_time
max_suspicion
ninja_hp_end
paw_count
high_risk_count
chain_rescue_count
shortcut_count
fail_code_frequency
```

### 首轮平衡目标

| 指标 | L01 | L02 | L03 |
|---|---:|---:|---:|
| 新玩家完成 | 35–70s | 80–150s | 120–240s |
| 熟练玩家 | 25–40s | 55–100s | 90–160s |
| 三猫爪目标 | <=60s | 目标待首轮数据后锁定 | 目标待 Boss 数据后锁定 |

> L02/L03 时间在首轮 8 人数据后正式冻结，不在 GDD 中虚构最终值。

---

# 16. Bug Severity

## P0

包括：

- 无法通关
- 无限循环
- NPC 卡死
- 输入失效
- Save 损坏
- Boss 无法结束
- LevelValidator 漏掉致命问题

目标：**0**

## P1

必须有明确 Workaround，并在 RC 前关闭或证明不影响核心体验。

## P2

允许进入 Patch。

---

# 17. Bug Report 模板

```text
BUG ID:
BUILD:
LEVEL:
EVENT:
REPRO STEPS:
EXPECTED:
ACTUAL:
FAIL CODE:
WORLD STATE:
NINJA HP:
SUSPICION:
SEVERITY:
REPRO RATE:
SCREENSHOT/VIDEO:
OWNER:
FIX BUILD:
REGRESSION TEST:
```

---

# 18. Regression Smoke Test

每次测试 Build 都必须完成：

```text
[ ] 启动
[ ] 新游戏
[ ] L01 通关
[ ] L01 Retry
[ ] L02 通关
[ ] L02 Retry
[ ] L03 Boss 通关
[ ] L03 Emergency Rescue
[ ] Save
[ ] Load
[ ] Hard Mode
[ ] Input Rebind
[ ] Controller
[ ] Pause
[ ] Audio
[ ] Result
```

---

# 19. Release Gate

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

# 20. 制作看板建议

推荐列：

```text
BACKLOG
→ READY
→ IN PROGRESS
→ REVIEW
→ QA
→ VERIFIED
→ LOCKED
```

每个任务卡至少填写：

```text
ID
Owner
Source Doc
Scene
Script
Data
Dependencies
DoD
QA Case
```

---

# 21. 第一批实际开工顺序

## Sprint 01 · 工程骨架

```text
OPS-001
OPS-002
OPS-003
SYS-CAT-001
SYS-NIN-001
SYS-EVT-001
SYS-WLD-001
```

目标：猫、忍者、事件点形成最小闭环。

## Sprint 02 · 核心规则

```text
SYS-CAT-002~008
SYS-NIN-002
SYS-NPC-001~002
SYS-SUS-001
SYS-SCR-001
SYS-LOG-001
```

目标：第一关所有 Gameplay Core 成立。

## Sprint 03 · L01

```text
LVL-L01-001~XXX
DAT-L01-001~XXX
QA-L01-001~XXX
```

先白盒、后 Gate、再美术。

## Sprint 04 · L02

完成 NPC 因果链、Carry、2+ Shortcut。

## Sprint 05 · L03

先普通事件，再 Boss FSM，再 Boss Activity Gate。

## Sprint 06 · RC Systems

- Settlement
- Save/Load
- Controller
- Audio
- Accessibility
- Achievements
- Cat Skills
- Hard Mode

## Sprint 07 · QA Burn-down

全部 Gate + Regression +真实设备。

---

# 22. 最终锁定顺序

```text
Gameplay Rule Lock
↓
System API Lock
↓
Data Schema Lock
↓
L01 Lock
↓
L02 Lock
↓
L03 Lock
↓
UI Lock
↓
Audio Lock
↓
Save Lock
↓
Blind Playtest Lock
↓
P0=0 / P1收敛
↓
Release Candidate
```

---

# 23. 团队每日验收问题

每天结束前回答：

1. 今天是否新增/修改了冻结规则？
2. 今天完成的功能是否有 Data Resource？
3. 今天新增的关卡事件是否有成功与失败出口？
4. 今天是否留下不可复现 Bug？
5. 下一次构建是否能自动验证它？

只要第 1 项为“是”，必须回到 Master GDD 审查。

---

# 24. Production & QA 总完成定义

```text
[ ] 4 份执行文档一致
[ ] Godot Node / Script / Data 三层可追踪
[ ] 三关可由数据驱动装载
[ ] 所有 CRITICAL Event 有完整 QA
[ ] Boss 八组合测试通过
[ ] 首局 Gate 通过
[ ] Failure Understanding Gate 通过
[ ] LevelValidator 全绿
[ ] Asset Manifest Ready
[ ] P0 = 0
[ ] P1 收敛
[ ] RC Build 可重复构建
```
