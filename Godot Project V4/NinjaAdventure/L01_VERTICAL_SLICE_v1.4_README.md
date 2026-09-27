# 《猫忍不住》v1.4.1 · L01 Vertical Slice

本版本把 L01 的白盒教学从“事件可触发”推进到“空间 + 捷径 + 事件反馈可实际游玩”。

## 本轮实现

- `CatTunnel`：真实 Area2D 入口、猫专用穿越、忍者不会触发；本轮只在 L01 启用。
- `JumpPoint`：Space 触发的木箱捷径，L01 只设置 1 个，且不绕过 E01-E03 的主线事件结构。
- `shortcut_mastery`：只在实际使用 CatTunnel / JumpPoint 后计入，不再被 MEOW / FEED 误触发。
- `EventPointData.resolved_offset`：允许 Watergap / Bridge / Cliff 的白盒道具在成功后按数据移动到目标落位。
- L01 E01/E03：猫交互距离按教学规格调整为 48px；E03 的被看见交互按教学规格精确增加 30 怀疑。
- L01 E03：成功后箱体向水沟落位方向移动，保留原先成功动画。

## 验收重点

1. L01 开局读图后，猫可自由移动。
2. L01 E01 仍为 BITE / 0.8s。
3. L01 E02 仍为 MEOW，喵叫不增加怀疑。
4. L01 E03 仍为 PUSH；成功后箱体真实移动。
5. 在 L01 木箱捷径点按 Space 可执行 JumpPoint，并在 EventLog 写入 `SHORTCUT`。
6. 经过 CatTunnel 后写入 `SHORTCUT`，完成评分条件 F 的基础证据。
7. Ninja 不会进入 CatTunnel / JumpPoint。

## 说明

当前环境未安装可用 Godot 4 运行时，因此本包通过源码/资源静态检查；请在本地 Godot 4 Editor 做一次运行时验收。
