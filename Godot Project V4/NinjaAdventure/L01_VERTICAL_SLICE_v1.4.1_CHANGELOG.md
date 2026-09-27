# 《猫忍不住》v1.4.1 · L01 收口变更

## 本轮变更

1. 新增真实 `CatTunnel`：L01 启用 1 个猫洞，只有 CatController 可以触发，穿越后记录 `SHORTCUT`。
2. 新增真实 `JumpPoint`：L01 木箱捷径使用 Space 触发，落点仍在 E01 之前，不绕过主线事件。
3. 修正 `shortcut_mastery`：只有真实使用猫洞/跳点才计入，MEOW/FEED 不再伪计为捷径。
4. `EventPointData` 新增 `suspicion_override`，L01 E03 按教学规格使用 +30 怀疑。
5. L01 E01/E03 交互半径统一为 48px。
6. `EventPointData` 新增 `resolved_offset / resolved_motion_time`，L01 E03 成功后箱体按数据真正移动到落位方向。

## 未改动

- Ninja 固定路线与速度逻辑。
- L01 三事件顺序：Tripwire → Guard → Watergap。
- 3 HP 容错与正式结算/存档链路。
- 其他 11 关的真实 CatTunnel 行为，本轮不提前开启。

## 验证说明

当前工作环境没有可用 Godot 4 Runtime，因此只做源码/资源静态检查；不能把静态检查写成运行时通过。请在本地 Godot 4 Editor 打开并运行 L01 完成最终运行时确认。
