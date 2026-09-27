# 《猫忍不住》v1.5 首轮整合版

## 目标

v1.4.1–v1.4.12 的 12 个关卡垂直切片合并后的发布前基线。此版本不新增关卡，重点是统一流程、数据契约和首轮 QA。

## 本版实际改动

1. 修复 `L11_E07_GATE` 的 `PASSIVE` 行为资源缺失：新增 `data/event_behaviors/passive.tres`。
2. 清理 `UnifiedLevelManager.is_ninja_at_blocking_event()` 中重复的 L10 分支。
3. `AppFlow.RESULT` 与 `ResultFlow.RESULT_SCENE` 统一指向真正使用的居酒屋结算场景。
4. 主菜单显示 `完成关卡 / 猫爪 / 鱼` 三项总进度。
5. 新增 `tools/audit_release_v15.py`，检查 12 关 LevelData / Route / Score、结算场景、Passive 行为、关键流程常量及 Python QA 工具。

## 固定发布流程

`MainMenu → LevelSelect → Level → Goal/Fail → Settlement → Next/Retry → Save`

游戏中的正式关卡结算由 `SettlementContext + izakaya_settlement.tscn` 承担；`ResultFlow` 保留为统一流程 API，并已与正式结算场景对齐。

## 12 关人工试玩顺序

- L01：基础互动、猫洞/跳点、三爪
- L02：连续赶场、提前规划、快捷路
- L03：视线/怀疑/卖萌
- L04：双路线
- L05：守卫换岗、狗、毒雾、搬运
- L06：狗队友
- L07：顺序分支
- L08：第二章组合关
- L09：雷雨压力
- L10：炸药→守卫→狗→蒺藜/毒雾连锁
- L11：双线程压力
- L12：Boss 三机关/应急

## 验收说明

当前环境没有 Godot 4 Runtime，因此自动验收属于静态资源/脚本检查；最终发布前仍需要本地 Godot 4 实机运行、碰撞和 UI 操作验证。
