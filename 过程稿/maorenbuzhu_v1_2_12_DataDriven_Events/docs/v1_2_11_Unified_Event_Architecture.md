# 《猫忍不住》v1.2.11 · Unified Event Architecture

## 目标
将 12 关的关卡运行逻辑从“章节专用 Manager + 章节专用 EventPoint”收敛为：

```text
UnifiedLevelManager
        ↓
UnifiedEventPoint
        ↓
EventBehaviorRegistry
        ↓
EventPointData
        ↓
WorldState / EventLog / ScoreSystem
```

## 1. 单一运行入口

所有 L01-L12 场景统一引用：

```text
res://scripts/gameplay/unified_level_manager.gd
```

旧文件 `level_manager.gd / dock_level_manager.gd / castle_level_manager.gd` 保留为兼容 shim，不再承担新功能。

## 2. 事件职责

### UnifiedEventPoint
负责：
- 事件是否激活
- 猫交互距离
- E 交互进度
- MAIN 事件超时
- 成功/失败 signal
- 事件可视化白盒

### EventBehaviorRegistry
负责：
- event_type → 默认 action
- event_type → 怀疑增量
- Boss/Combat 类型判定

### UnifiedLevelManager
负责：
- 场景节点发现
- 忍者路线初始化
- 事件生成
- WorldState
- 怀疑
- 事件副作用
- 评分
- 章节流转
- Boss 状态
- Emergency Rescue

## 3. EventGroup

| EventGroup | 是否阻挡忍者 | 用途 |
|---|---|---|
| MAIN | 是 | 普通关卡主线事件 |
| BOSS_PREP | 否 | Boss 战前准备 |
| BOSS_COMBAT | 否 | Boss 战内实时事件 |
| OPTIONAL | 否 | 收集/彩蛋 |

### L12

```text
DYNAMITE = MAIN
BOSS_CRANE = BOSS_PREP
BOSS_GOURD = BOSS_PREP
BOSS_CALTROP = BOSS_COMBAT + Phase 2
```

这样 Boss 机关不会污染普通忍者路线。

## 4. 不变的玩法规则

- 猫不能直接战斗。
- Ninja 仍采用固定路线 + 状态机 + 脚本分支。
- 被看到不等于产生怀疑；“做事被看到”才增加怀疑。
- 离开只停止进一步累积，累计怀疑不会自动下降。
- Ctrl 卖萌才清除已有怀疑。
- Boss Phase 2 蒺藜必须在 Boss 已启动后才能处理。
- Emergency Rescue 只给 1 猫爪且不提供正向资源奖励。

这些规则沿用 v1.1/v1.2 已冻结设计，不因架构重构改变。

## 5. 迁移策略

### Phase A
所有 12 张 Scene 改引用 unified_level_manager.gd。

### Phase B
保留旧 Manager shim 2 个版本周期，禁止新增业务逻辑。

### Phase C
确认 Runtime smoke test 后删除旧 Manager 文件。

## 6. 新增 Data 字段

`EventPointData` 增加：

```text
event_group
activation_phase
activation_flag
consume_carry_item
non_blocking
```

默认值保证旧 `.tres` 无需立即全部重填。

## 7. 生产收益

以后新增事件类型主要修改：

```text
EventBehaviorRegistry
+ EventPointData
```

而不是新增：

```text
xxx_event_point.gd
xxx_level_manager.gd
```

## 8. 静态审计

本包完成：
- 12 张主线 Scene Manager 引用统一
- 旧 Manager 业务代码降级为兼容 shim
- 统一 EventPoint 入口
- L12 Boss Combat 数据隔离
- `.tres` 文本引用检查
- 文档与工程结构一致性检查

Runtime 仍需真实 Godot 环境 smoke test。
