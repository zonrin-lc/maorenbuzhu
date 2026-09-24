# 《猫忍不住》v1.2.10 · 第三章连续试玩 + Boss 集成规格

## 1. 目标

把 L09-L12 接入与前两章一致的运行框架，并完成 Boss 的三个主动机制与 Emergency Rescue 的白盒状态链。

## 2. 运行链

L09 雷雨夜 → L10 炸药不能乱碰 → L11 越靠近城门越忙 → L12 守门武士 → Chapter03_Clear

## 3. 关卡职责

| 关卡 | 训练内容 | 事件量 |
|---|---|---:|
| L09 | 高压环境 + 单线程危险 | 4 |
| L10 | 炸药连锁 + NPC 改线 | 5 |
| L11 | 双守卫 + 狗 + 毒雾 + 蒺藜多线程 | 6 |
| L12 | Boss 战前准备 → Phase 2 战中处理 → 保底救场 | 3 个战前事件 + 1 个 Boss 战中事件 |

## 4. Boss 结构

### 战前
- 吊车：准备完成后 Boss 开战时造成 -40 HP。
- 酒葫芦：准备完成后 Boss 开战时造成 -30 HP。

### Phase 1
Boss 进入场地，玩家开始观察冲锋线路。

### Phase 2
`Boss_Caltrop` 不参与普通路线阻挡，只在 Boss 已启动且 Phase 2 冲锋窗口开放时生效。玩家到达事件点按 E，造成 -30 HP。

### Phase 3
Boss 进入收尾状态。如果玩家至少成功一个 Boss 机制，则 Boss 可正常撤退/结束；若完全没有成功，进入 Emergency Rescue 入口。

## 5. Emergency Rescue

触发白盒条件：Boss 完成致命动作且无 Boss 机关成功。Ninja HP 固定进入 1 心保底状态，玩家需赶到 `EMERGENCY_POS = (930, 290)` 附近按 E。成功后任务完成，但猫爪固定为 1，不给正向资源奖励。

## 6. 数据结构

第三章继续使用：

- `LevelData`
- `RouteData`
- `EventPointData`
- `WorldState`
- `EventLog`
- `ScoreSystem`
- `LevelValidator`

L12 的 `BOSS_CALTROP` 虽然仍是 `EventPointData`，但从普通 `event_nodes` 中分离，避免 Boss 尚未启动就把忍者路线挡住。

## 7. Godot 映射

- `scenes/levels/L09_thunder_night.tscn`
- `scenes/levels/L10_dont_touch_dynamite.tscn`
- `scenes/levels/L11_getting_busier.tscn`
- `scenes/levels/L12_gatekeeper_boss.tscn`
- `scripts/gameplay/castle_level_manager.gd`
- `scripts/gameplay/castle_event_point.gd`
- `scripts/actors/boss_controller.gd`
- `data/levels/ch03_castle/*.tres`
- `data/events/L09_* ~ L12_*.tres`

## 8. QA Gate

- L09-L11 事件顺序可重复，失败原因明确。
- L12 战前吊车/酒葫芦可准备并在 Boss 启动后结算。
- L12 Phase 2 蒺藜不能在 Boss 开始前解决。
- Boss 启动后玩家必须仍有移动任务。
- Boss 无玩家操作不能直接判定为正常胜利。
- 完全不处理 Boss 机关时可进入 Emergency Rescue。
- Emergency Rescue 只产生 1 猫爪。
- R 重开清除 Boss HP / Phase / emergency 状态。
- Space 仅在关卡完成后进入下一场景。

## 9. 已知限制

当前工作环境没有 Godot 可执行程序，因此本包只进行了工程文件、文本资源路径、引用 ID 和数据/场景配对的静态检查，未宣称完成 Runtime smoke test。
