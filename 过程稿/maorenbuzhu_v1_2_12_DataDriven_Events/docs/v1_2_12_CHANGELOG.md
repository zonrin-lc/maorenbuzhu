# 《猫忍不住》v1.2.12 ChangeLog

## 架构
- EventBehavior 从 Registry 硬编码迁移为 `data/event_behaviors/*.tres`。
- EventEffect 从事件类型分支迁移为 `data/event_effects/*.tres`。
- UnifiedLevelManager 改为遍历 `success_effects[]` 并按 effect_type 执行通用副作用。
- 保留 `success_flags[]` 作为 WorldState 事实写入。

## 数据
- 12 关共 46 个 EventData 全部补齐 `success_effects` 字段。
- Dog 事件配置 `consume_carry_item = FISH`。
- Poison 事件配置 `consume_carry_item = ANTIDOTE`。
- 修正 L08 `CALTROP` 历史拼写错误 `CALTRAP`。

## 工具
- 新增 `data/event_point_template.tres.template`。
- 新增 `tools/audit_events.py`。
- 新增 `docs/v1_2_12_DataDriven_Event_Authoring.md`。

## 未完成
- 没有本地 Godot Runtime，未执行实际运行时 smoke test。
- Effect 类型未来仍可继续扩展，但必须优先保持数据化，不新增章节 Manager。
