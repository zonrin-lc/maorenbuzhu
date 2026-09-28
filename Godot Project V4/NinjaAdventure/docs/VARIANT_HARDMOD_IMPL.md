# Hard Mode（LevelModifier）与 Variant B 实现说明

对应 GDD：§5.3 Variant B 规范、Hard Mode 参数、§13.5 Release Gate（"12 个 Variant B 可加载" / "Hard Mode 解锁正常"）。

## 新文件清单

| 文件 | 说明 |
|---|---|
| `scripts/data/level_modifier.gd` | `LevelModifier extends Resource`：ninja_speed_mult / hesitation_delta / suspicion_gain_mult / event_timeout_mult / boss_prepare_delta，默认值均为"不改变" |
| `scripts/data/variant_data.gd` | `VariantData extends Resource`：variant_id / route_overrides / event_overrides / npc_overrides / timer_overrides / suspicion_modifier / is_hard |
| `data/modifiers/hard_mode.tres` | Hard Mode 参数实例：忍者速度 ×1.1、犹豫 -0.5s、怀疑收益 ×1.1、事件窗口 ×1.0、Boss 战前准备 -2.0s |
| `data/variants/l01_variant_b.tres` … `l12_variant_b.tres` | 12 个 Variant B（variant_id = L01_VB … L12_VB） |
| `docs/VARIANT_HARDMOD_IMPL.md` | 本文档 |

## 修改文件清单

- `scripts/data/level_data.gd`：新增 `@export var variant: VariantData`
- `scripts/flow/save_data.gd`：新增 `hard_mode_enabled: bool = false`（含 to_dict/from_dict；解锁逻辑沿用既有 `_refresh_unlocks()`：完成 12 关 → `hard_mode_unlocked = true`）
- `scripts/flow/global_flow_memory.gd`：新增 `static var variant_b_selected: Dictionary`（level_id → bool，会话内记录每关是否以 B 进入）
- `scripts/flow/level_select.gd`：困难模式开关 + 每关 "B" 切换（见下）
- `scripts/gameplay/unified_level_manager.gd`：`_prepare_level_data()` / `_apply_variant()` / `_apply_level_modifier()`，`_apply_suspicion` 乘 `_suspicion_gain_mult`，`_build_events` 应用 variant 的事件 position 覆盖
- `scripts/actors/boss_controller.gd`：Phase 1 时长 3.0s 提取为 `prepare_time`，供 boss_prepare_delta 调整
- `data/levels/**/L*.tres`（12 个）：新增 variant ext_resource 并指向对应 Variant B

## 数据流

1. 选关界面写开关：困难模式 → `save.hard_mode_enabled`（`save_manager.save_game()` 持久化）；Variant B → `GlobalFlowMemory.variant_b_selected[level_id]`。
2. 关卡 `_ready()` 开头调用 `_prepare_level_data()`（Reset / R 重开走 `reload_current_scene()`，同样重新经过此入口，状态一致）：
   - 两者都未开启 → **直接返回，默认路径与原行为完全一致**（不复制、不改数）。
   - 需要修饰 → `level_data = level_data.duplicate(true)` 深拷贝运行时副本（RouteData / EventPointData / ScoreRuleData 一并拷贝），**磁盘 .tres 不被污染**。
   - 先应用 Variant（若该关在选关界面选了 B 且 LevelData.variant 存在），再叠加 Hard Mode（若已解锁且已开启）。
3. 生效点：
   - `ninja_route.move_speed *= ninja_speed_mult`（ninja.setup 之前完成）
   - 每个事件：`hesitation_time = max(0, +delta)`；`timeout *= event_timeout_mult`（下限 0.5s）；hard 的 hesitation_delta<0 时同步 `timeout += hesitation_delta`（犹豫是事件总窗口的前段，犹豫缩短 = 总窗口变紧；`hesitation_time` 字段本身目前不被 gameplay 消费，此换算保证 -0.5s 有实际效果）
   - `_apply_suspicion`：正收益 `amount *= _suspicion_gain_mult`（modifier 与 variant 的 suspicion 系数相乘叠加）
   - Variant `timer_overrides`：`"target_time"`（绝对值）或 `"target_time_mult"`，同时写入 level_data.target_time 与 score_rules.target_time（BalanceDirector 优先读 score_rules）；`"event_timeout_mult"` 作用于全部事件窗口
   - Variant `event_overrides`：按 event_id 覆盖 `timeout` / `hesitation_time`（数据层），`position`（在 `_build_events` 内覆盖事件点位置，晚于 L10/L11/L12 的硬编码摆位）
   - Boss：`boss.prepare_time = max(0.5, 3.0 + boss_prepare_delta)`（L12 之外无 boss 节点，自然不生效）

## 开关位置（UI）

`scenes/flow/level_select.tscn`（`scripts/flow/level_select.gd`）：
- "困难模式" CheckButton 在关卡列表顶部，仅当 `save.hard_mode_unlocked` 时创建；切换写回 `hard_mode_enabled` 并立即 `save_game()`。
- 每关按钮旁 "B" CheckButton，仅当该关已通关（`completed_levels`）且 `res://data/variants/lNN_variant_b.tres` 存在时出现；状态存于 `GlobalFlowMemory.variant_b_selected`，按开始进入。

## 12 个 Variant B 设计依据（初值，待试玩调整）

注：.tres 文本格式不支持注释（`#` 会导致解析错误），设计依据集中记录在此。

| 变体 | 内容 | 依据 |
|---|---|---|
| L01_VB | target_time ×0.9 | 教学关只收时间窗口 |
| L02_VB | L02_02_GUARD：hesitation 2.0→1.5、timeout 2.2→2.6（触发偏移）；npc_overrides 记录守卫起始位置偏移（待接入） | GDD §6.1 L02："只改 Guard 起始位置 / 路线方向 / E02 触发偏移" |
| L03_VB | suspicion_modifier 1.1 | "谁在看猫"——视线主题 |
| L04_VB | target_time ×0.9 | 村口大事故收紧三星线 |
| L05_VB | event_timeout_mult 0.9 | 码头全窗口 -10% |
| L06_VB | suspicion_modifier 1.1 | 狗队友关卡提高暴露代价 |
| L07_VB | event_timeout_mult 0.9 | 顺序关全窗口 -10% |
| L08_VB | target_time ×0.9 | 末班船收紧三星线 |
| L09_VB | event_timeout_mult 0.9 | 雷雨夜窗口再短一档 |
| L10_VB | L10_E01_DYNAMITE_A：position (270,410)→(300,410)、timeout 2.8→2.5 | GDD §6.3 L10："仅改炸药起始位置，因果关系不变" |
| L11_VB | event_timeout_mult 0.9 | 多线程关全窗口 -10% |
| L12_VB | target_time ×0.9 | Boss 关收紧三星线 |

## 已知限制（TODO）

- `route_overrides` / `npc_overrides` 只读入并挂在运行时 `active_variant` 上，**尚未深度应用**（忍者路线分支、NPC 起始位置覆盖未接入；代码内已标 TODO）。L02 的守卫起始位置偏移因此暂以 npc_overrides 备注形式存在。
- Variant B 选择是会话内状态（GlobalFlowMemory 静态变量），不持久化到存档。
- `boss_prepare_delta` 作用于 BossController Phase 1 时长（`prepare_time`，默认 3.0s）；GDD BossData 中的 `gourd_delay=10.0` 等更细的战前准备计时尚未实现，此处取现有唯一 Boss 准备计时点。
- `is_hard` 字段已按规范建立，当前未被读取（Hard+ 留给后续）。
