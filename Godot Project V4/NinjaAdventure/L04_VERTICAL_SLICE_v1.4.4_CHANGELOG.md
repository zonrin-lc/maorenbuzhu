# 《猫忍不住》L04 垂直切片 v1.4.4

目标：把第一章高潮《村口大事故》从线性三事件白盒升级为“顺序题 + 双主路线”可玩切片。

## 本轮实现

- L04 主事件由 3 个补齐为 4 个：Guard → Tripwire → Crate → Watergap。
- 前半段允许 Guard / Tripwire 任意先后处理，支持 GDD 指定的 Route A / Route B。
- Route A：Guard → Tripwire → Crate(Q 叼取) → Watergap(E 放置)。
- Route B：Tripwire → Guard → CatTunnel Shortcut → Watergap(E 处理)。
- 两条路线在 E04 Watergap 汇合，均不绕过 Ninja 的主路线。
- Ninja 在 Guard + Tripwire 完成后会真实等待“箱子 / 捷径”分叉条件，不会直接穿过分叉点。
- 使用 Route B 捷径后会主动释放等待中的 Ninja。
- L04 Watergap 在 Route A 要求携带 CRATE，在 Route B 使用 SHORTCUT 后不要求携带物。
- EventLog 写入 caused_event_id / world_changes，并在分叉处给出无答案式反馈。
- 删除旧的重复 L04_03_WATERGAP.tres，避免资源歧义。

## QA 重点

1. Route A：Guard → Tripwire → Crate → Watergap → Goal。
2. Route B：Tripwire → Guard → Shortcut → Watergap → Goal。
3. 先处理 Tripwire 时 Ninja 不软锁，随后仍可处理 Guard。
4. 先处理 Guard 时仍可正常进入 Crate 路线。
5. 两处前置完成但未选择 Crate/Shortcut 时，Ninja 在 Watergap 前等待。
6. Shortcut 在前置完成后使用会释放 Ninja；Watergap 立即可处理。
7. Reset 后 L04_* flags 清空，不能把上一局路线带入下一局。

## 未运行项

当前环境没有 Godot 4 Runtime，因此不宣称编辑器/实机运行通过；本轮为源码、资源引用、流程逻辑静态回归。
