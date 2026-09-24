# 《猫忍不住》v1.2.12 · Data-Driven Event Authoring

## 目标
以后新增事件，原则上只新增或复制 `.tres` 数据，不新增 `xxx_event_point.gd`。

## 三层结构

```text
EventBehaviorData
  ↓  定义这个事件“怎么交互”
EventPointData
  ↓  定义它“在这一关什么时候出现/是否阻挡/成功后写什么事实”
EventEffectData[]
  ↓  定义成功后产生的通用副作用
WorldState / EventLog / ScoreSystem
```

## EventBehaviorData
字段：`event_type / default_action / suspicion / default_interaction_time`。

现有 12 种行为已全部迁移到 `data/event_behaviors/`。

## EventPointData
核心字段保持 v1.2.11；v1.2.12 新增：

- `consume_carry_item`
- `success_effects[]`

`success_flags[]` 仍用于写入世界事实；不要把 UI 提示写进 Flag。

## EventEffectData
当前标准 effect：

| Effect | 作用 |
|---|---|
| `GUARD_DISTRACT` | 将守卫拉离当前位置 |
| `DOG_LURE` | 将狗引向猫附近 |
| `BOSS_PREPARE_DAMAGE` | 战前给 Boss 累积机关伤害 |
| `BOSS_COMBAT_DAMAGE` | 指定 Phase 内给 Boss 造成伤害 |

新增 effect 时，优先扩展 `EventEffectData` + `_apply_effect()`，禁止新建章节 Manager。

## 标准新事件流程

1. 复制 `data/event_behaviors/<type>.tres`。
2. 创建对应 `EventPointData`。
3. 配置 `event_group / activation_phase / activation_flag`。
4. 配置 `success_flags / success_effects`。
5. 用 `LevelData.events[]` 挂入关卡。
6. 跑静态审计。
7. 在 Godot 中做 runtime smoke test。

## 禁止

- 在 `UnifiedLevelManager` 里按 `event_type` 不断增加业务分支。
- 为单个关卡复制新的 LevelManager。
- 将“玩家应该怎么做”写入 WorldState。

## 当前事件行为资产

```text
TRIPWIRE → BITE
GUARD → MEOW
WATERGAP → PUSH
BRIDGE → PUSH
DOG → FEED
POISON → PLACE_ANTIDOTE
CALTROP → CLEAR_CALTROP
DYNAMITE → PUSH_TO_WATER
CLIFF → PUSH_CRATE
BOSS_CRANE → CUT_CRANE
BOSS_GOURD → DRUG_GOURD
BOSS_CALTROP → CALTROP_DURING_PHASE2
```

## 兼容策略
现有旧 `.tres` 缺少 `success_effects` 时仍可加载；v1.2.12 已将当前 12 关事件资产全部补齐到新格式。
