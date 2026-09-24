# 《猫忍不住》v1.2.12 · Data-Driven Events

基于 v1.2.11 Unified Event Architecture。

本版把 EventBehavior 与通用 EventEffect 从代码常量/事件类型分支进一步迁移为 Resource 数据资产。

核心结果：新增普通事件原则上只需要 `.tres` 数据，不需要新增章节 Manager 或 EventPoint 脚本。

## 目录
- `data/event_behaviors/` 行为定义
- `data/event_effects/` 通用副作用
- `data/events/` 12 关全部事件数据
- `data/event_point_template.tres.template` 新事件模板
- `tools/audit_events.py` 静态审计
- `docs/v1_2_12_DataDriven_Event_Authoring.md` 制作说明

## 运行边界
当前环境无 Godot 可执行程序；本包提供静态工程与数据结构，不声称 Runtime smoke test 已完成。
