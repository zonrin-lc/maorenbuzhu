# 《猫忍不住》v1.2.6
## Godot 第一条可运行垂直切片规格

## 1. 目标

以 L01《第一份差事》验证：

`Data Resource → Scene → Controller → EventPoint → WorldState → EventLog → Score`

形成真正可运行闭环。

## 2. Scene

```text
L01_FirstJob (Node2D)
├─ Cat (CharacterBody2D)
│  └─ CollisionShape2D
├─ Ninja (CharacterBody2D)
│  └─ CollisionShape2D
├─ Events (Node2D)
└─ UI (CanvasLayer)
```

## 3. Script 对照

| 类 | 文件 | 职责 |
|---|---|---|
| LevelManager | `scripts/gameplay/level_manager.gd` | 加载关卡、推进事件、结算 |
| CatController | `scripts/actors/cat_controller.gd` | 猫移动、疾跑 |
| NinjaController | `scripts/actors/ninja_controller.gd` | 固定路线 |
| EventPoint | `scripts/gameplay/event_point.gd` | 事件触发/解决/失败 |
| WorldState | `scripts/gameplay/world_state.gd` | 保存世界事实 |
| EventLog | `scripts/gameplay/event_log.gd` | Gameplay Facts |
| ScoreSystem | `scripts/gameplay/score_system.gd` | 猫爪评分 |
| LevelValidator | `scripts/gameplay/level_validator.gd` | 数据校验 |

## 4. Data Resource

```text
LevelData
 ├─ RouteData
 ├─ EventPointData[]
 └─ ScoreRuleData
```

L01 实例：

```text
L01_first_job.tres
L01_Ninja_Main.tres
L01_E01_TRIPWIRE.tres
L01_Score.tres
```

## 5. L01 验收

### Gate A — 能运行

- 游戏启动无脚本错误
- LevelValidator 返回 0 errors

### Gate B — 路线

- Ninja 从起点沿 4 个 waypoint 前进
- Ninja 到达事件点会停住
- Event Resolve 后继续

### Gate C — 事件

- 猫靠近事件点
- E 持续交互
- 0.8 秒后 EventPoint resolved
- EventLog 写入成功记录
- WorldState 写入 `L01_TRIPWIRE_SAFE`

### Gate D — 失败

- 猫不处理
- 超过 5 秒
- `FAIL_TOO_LATE`
- Ninja HP -1
- R 可以重新开始

### Gate E — 结算

- 忍者到终点后 mission_complete
- ScoreSystem 返回 1–3 猫爪
- UI 显示结果

## 6. 本阶段工程原则

- Scene 负责节点组合
- Script 负责行为
- Resource 负责关卡事实和参数
- WorldState 只记录事实，不记录攻略
- EventLog 只记录 Gameplay Facts

## 7. 不在本 Slice 内解决

- 完整艺术资源
- 最终动画
- 最终音频
- 怀疑系统
- Guard / Dog
- Q / F / Ctrl
- Boss
- Save / Load

这些进入后续 Sprint。
