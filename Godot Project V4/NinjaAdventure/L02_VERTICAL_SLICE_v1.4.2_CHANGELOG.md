# 《猫忍不住》v1.4.2 · L02 第二垂直切片

## 本轮目标

把 L02《他总是踩同一个坑》做成第一章第二个完整可玩的节奏样板：第一次让玩家发现“跟着忍者跑，必然来不及”。

## 已落地

1. **Ninja 赶场节奏**：L02 路线速度调整为 52 px/s。按当前主路线，E01→E02 约 6–8 秒、E02→E03 约 5–7 秒，保留连续事件压力。
2. **真实 CatTunnel**：Start Side → Plaza Backside，只缩短猫移动距离，不改变 Ninja Route。
3. **真实 JumpPoint**：CatTunnel 出口 → Plaza Backside，Space 触发；不跳过 E01/E02/E03。
4. **E03 Watergap 反馈**：成功后箱体按 `resolved_offset` 数据落位，继续沿用白盒真实视觉反馈。
5. **事件因果日志**：L02 E01→E02、E02→E03 写入 `caused_event_id`，同时记录 `world_changes / route_change`。

## 保持不变

- 事件数量：3 个，Tripwire → Guard → Watergap。
- 主线顺序与 Ninja 固定路线。
- 失败采用忍者 HP 容错体系，耗尽 3 心才真正失败。
- Variant B 仍未启用；本轮先锁主版本体验。

## 运行时验证

当前工作环境没有可用 Godot 4 Runtime，因此本轮只做源码、资源引用与关卡时序静态检查；本地 Godot 4 运行时应重点验证：

`L02 开场读图 → E01 → 连续赶场 → E02 → E03 → Goal → 结算 → R 重开`
