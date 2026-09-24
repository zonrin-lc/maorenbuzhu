# 《猫忍不住》v1.2.13 · Level Production Template

## 1. 新关卡标准生产链

```text
Level Brief
  ↓
Production Card
  ↓
LevelData / RouteData / EventPointData
  ↓
Whitebox Scene
  ↓
Static Validation
  ↓
Godot Runtime Smoke Test
  ↓
8人 Blind Playtest
  ↓
Balance / Banter / Audio
  ↓
Art Lock
```

## 2. 一关必须回答的 10 个问题

1. 玩家这一关新学到什么？
2. 忍者路线是什么？
3. 核心事件是什么？
4. 事件之间有什么因果关系？
5. 标准解是什么？
6. 高风险/捷径解是什么？
7. 失败出口是什么？
8. 这一关为什么值得重玩？
9. 结算时忍者会误解什么？
10. LevelValidator 怎么判断“这关能过且没有死状态”？

## 3. 事件预算

| 类型 | 推荐数量 | 说明 |
|---|---:|---|
| CRITICAL | 2–4 | 核心题目；至少一条因果关系 |
| STANDARD | 1–3 | 推进事件；可以只有稳定解 + 风险解 |
| OPTIONAL | 0–2 | 鱼干/彩蛋；不影响主线 |

单关总 EventPoint 推荐 4–8 个。教学关允许少于 4 个，Boss 关允许略高于 8 个，但必须通过 Playtest 证明节奏没有变慢。

## 4. 关卡数据最小集合

```text
LevelData
RouteData
EventPointData[]
WorldFlagData[]
ShortcutData[]
ScoreRuleData
VariantData (可选)
BanterSet
AudioMap
ValidationRules
```

## 5. EventPointData 最小集合

```text
event_id
event_type
event_group
activation_phase
activation_flag
block_ninja
ninja_reaction
interaction_action
interaction_time
interaction_radius
success_flags[]
success_effects[]
consume_carry_item
failure_code
high_risk
critical
```

禁止写入：

```text
player_should_do_X
correct_answer
hint_solution
```

## 6. 路线设计规则

- Ninja Route 必须可视化、可预测。
- 至少保留一个“玩家提前赶场”的空间。
- 核心事件不要全部堆在直线终点。
- 至少一个事件应允许通过空间捷径节省时间。
- NPC 的路线变化必须由 WorldState 或固定脚本分支驱动，不用随机寻路。

## 7. 双解法规则

CRITICAL 事件必须至少有：

```text
标准解 + 高风险解
```

高风险解可以是：

- 更晚处理
- 更长移动距离
- 暴露在忍者视线中
- 需要 NPC 联动
- 需要放弃低风险资源位置

不要为了“两个解”硬造完全不同的新系统。

## 8. 节奏规则

一关的基本节拍：

```text
观察
→ 处理
→ 等待/赶场
→ 事件反馈
→ 下一选择
→ 小高潮
→ 结算
```

连续两个以上事件都要求玩家原地等待超过 2 秒，需要重新检查路线或 EventPoint 的时间窗。

## 9. 失败设计规则

每个主线失败必须能映射到一个 `FAIL_CODE`：

```text
FAIL_TOO_LATE
FAIL_WRONG_ORDER
FAIL_SUSPICION
FAIL_NINJA_DEATH
FAIL_BOSS_FINISHER
FAIL_ROUTE_BLOCKED
FAIL_TIMEOUT
```

测试时玩家回答“下一次改什么”应当对应这些具体行为，而不是泛化成“操作差”。

## 10. Replay / Boast 标签

事件完成时只记录 Gameplay Facts；结算由：

```text
EventLog
→ Importance
→ Tags
→ Banter Template
```

生成吹牛内容。

推荐 Tags：

```text
last_second
high_risk
chain
shortcut
npc_link
boss
near_death
clean_clear
```

## 11. Variant B 规则

Variant B 必须：

- 手工制作
- 可预测
- 不改变操作键位
- 不破坏核心因果关系
- 只改变路线、时序、起始位置或一个状态条件

Variant B 不允许依赖真正随机种子。

## 12. 新关卡验收门槛

### 内容
- 新决策至少 1 个
- 旧机制重组至少 1 次
- 高风险解至少 1 个
- 新的行为笑点至少 2 个

### 技术
- Static Validator 0 error
- 所有 EventPointData 可解析
- RouteData 有 Start / Goal
- 所有 MAIN Event 有 failure_code
- 没有悬空 WorldState flag
- 没有未注册 event_type

### 体验
- 首次观察能理解 Ninja Route
- 玩家能找到第一处主动操作机会
- 失败原因可描述
- 通关后能说出这一关与上一关不同在哪里

## 13. L13+ 快速创建流程

```text
1. 复制 LevelData 模板
2. 复制 RouteData 模板
3. 复制 4–8 个 EventPointData
4. 只选择现有 event_type
5. 配置 success_flags / success_effects
6. 配置 Shortcut
7. 创建 .tscn
8. 挂 UnifiedLevelManager
9. 运行 audit
10. Runtime smoke test
```

原则：

> 先证明“同一套系统能产生新选择”，再考虑是否真的值得新增系统。
