# L07《谁先走》试玩检查表 v1.4.7

## 标准路线

Guard A → 等待 8 秒 → Guard B → Dog → Bridge → Poison → Goal

预期：不产生 `FAIL_WRONG_ORDER`；桥在 Dog 改线后开放。

## 风险路线

Guard A → Dog → Guard B → CatTunnel → Bridge → Poison → Goal

预期：可以完成；Shortcut 写入 `L07_SHORTCUT_USED`；不改变 Ninja 的目标顺序，只缩短猫到位距离。

## 错序恢复

Guard B → A

预期：不直接 Game Over；EventLog 写入 `FAIL_WRONG_ORDER`；WorldState 出现 `L07_BRIDGE_BLOCKED / L07_POISON_FIRST`；Ninja 切换到 Poison → Bridge 脚本路线。

## 可诊断性

试玩结束后 Debug HUD 应能看到：

- A 是否离岗
- B 是否完成 8 秒稳定换岗
- 当前是“桥→毒雾”还是“毒雾→桥”
- Dog 是否已经改线

## Reset

按 R：

- Ninja 回起点
- Guard A/B 回初始位置
- Dog 回初始位置
- Fish / Antidote 重新出现
- WorldState 清空 L07 标记
- 路线恢复标准线
- shortcut / event log / suspicion 清零

## 注意

当前制作环境没有 Godot 4 Runtime，因此上述项目文件已经过静态检查与数据/脚本引用检查，但不宣称已在运行时实机通过。
