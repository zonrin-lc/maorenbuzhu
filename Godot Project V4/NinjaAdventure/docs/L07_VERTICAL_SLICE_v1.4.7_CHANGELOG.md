# L07《谁先走》v1.4.7

本版依据 GDD 整合版 v1.3 的第二章白盒要求制作。

- 依赖链：Guard A 离岗 → 8s → Guard B 换岗 → Dog 改路线 → Bridge 窗口 → Poison 窗口。
- 五个主线事件：E01 Guard A / E02 Guard B / E03 Dog / E04 Bridge / E05 Poison。
- Guard B 在 8s 前被处理不会直接 Game Over；记录 `FAIL_WRONG_ORDER` 诊断并切换到“毒雾优先”脚本路线。
- L07 使用脚本化路线分支，不使用自由寻路。
- 风险分支仍可恢复通关，且 `shortcut_mastery` 只记录真实猫洞使用。
- 新增 Fish / Antidote 两个 CarryPoint；一次仅携带一个 Carryable。
- CatTunnel：猫可提前赶到桥侧，不改变 Ninja 路线。
- Debug HUD 观察 Guard B 8s、路线分支、Dog route 状态。

运行时说明：当前制作环境未提供 Godot 4 Runtime，本版已做静态引用/逻辑一致性检查，但未声明实机运行通过。
