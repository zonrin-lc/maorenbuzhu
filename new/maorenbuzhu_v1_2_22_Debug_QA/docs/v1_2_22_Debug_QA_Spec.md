# 《猫忍不住》v1.2.22 · Debug / LevelValidator / QA Console

## 1. 目标

把 12 个主线关卡、事件、Boss、评分、Save、Flow、Input、Audio、UI 统一纳入开发测试面板。

Debug 层只服务开发与 QA，不成为正式玩家系统。

## 2. Debug Console

### 核心命令

```text
help
level L01
win
fail FAIL_TOO_LATE
hp 1
suspicion 80
world guard_a_departed 1
boss PHASE_2
event <event_id>
validate
pause_sim
resume_sim
reset
```

### 原则

- 任何命令只改变 Debug Runtime State。
- 不直接绕过正式 Gameplay API。
- 不允许 Debug 状态写入正式 SaveData。
- Release Build 不注册 DebugConsole / QATestRunner Autoload。

## 3. Debug Overlay

必须显示：

```text
Level ID
Ninja HP
Suspicion
Boss Phase
WorldState Flags
最近 EventLog
当前 Fail Code
```

允许一键：

```text
Reset Level
Restart Current Event
Force Success
Force Failure
Teleport Cat
Teleport Ninja
```

其中后四项必须走 `debug_only` 分支，Release 禁用。

## 4. LevelValidator

### P0 合同

1. LevelData 存在
2. RouteData 存在
3. EventPointData 全部可加载
4. required EventBehavior 存在
5. Start / Goal 存在
6. Route 不为空
7. WorldState 默认值完整
8. ScoreRule 存在
9. ResultFlow destination 合法
10. Boss 关必须存在 Phase 迁移规则
11. Emergency Rescue 只能在 HP <= 1 条件下出现
12. Debug 状态不能进入 SaveData

### 关卡级硬条件

```text
levels = 12
expected_events = 46
```

实际工程应从目录 / Resource registry 枚举，而不是手写计数。

## 5. Event QA Matrix

每个 CRITICAL Event 至少跑：

```text
normal success
normal fail
latest success
suspicion exposed
reset
repeat trigger
NPC conflicting state
```

每个 Boss 组合至少覆盖：

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

## 6. Failure Diagnostics

以下 7 个 Fail Code 为正式统一枚举：

```text
FAIL_TOO_LATE
FAIL_WRONG_ORDER
FAIL_SUSPICION
FAIL_NINJA_DEATH
FAIL_BOSS_FINISHER
FAIL_ROUTE_BLOCKED
FAIL_TIMEOUT
```

玩家看到自然语言；Debug 显示 Fail Code。

## 7. Release 防护

Release Build 必须满足：

```text
DebugConsole = disabled
QATestRunner = disabled
Debug overlay = absent
Cheat input = absent
Debug-only save fields = absent
```

## 8. 主要验收链

```text
Boot
→ Load Settings
→ Load Save
→ Main Flow
→ Level
→ EventLog
→ ScoreResult
→ Result
→ Save
→ Next / Retry / Level Select
```

Boss 额外：

```text
Prepare
→ Phase 1
→ Phase 2
→ Phase 3
→ Defeat / Retreat
```

## 9. 代码边界

```text
Gameplay scripts
    不依赖 Debug UI

DebugConsole
    只调用公开 Debug API

LevelValidator
    只读数据 + Runtime state

QA Test Runner
    不修改正式 SaveData
```
