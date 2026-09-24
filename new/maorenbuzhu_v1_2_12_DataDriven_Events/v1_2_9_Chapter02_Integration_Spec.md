# 《猫忍不住》v1.2.9 · 第二章连续试玩整合

## 目标

在 v1.2.8 第一章连续流程的基础上，接入 L05–L08，并把第二章的关键关系变成可运行白盒：双守卫、Dog、Q 叼取、桥、毒雾、蒺藜，以及固定换岗窗口。

## 连续流程

```text
L04
 ↓
Chapter01 Clear
 ↓
L05 月夜码头
 ↓
L06 狗也能当队友
 ↓
L07 谁先走
 ↓
L08 最后一班船
 ↓
Chapter02 Unlock
```

## 输入

```text
WASD  移动
Shift 疾跑
E    互动/处理事件
Q    叼取/放下白盒道具
F    喵叫
Ctrl 卖萌
R    重开
Space 下一关
```

## L05

教学目标：第一次在同一地图里观察 Guard / Dog / Bridge。

```text
Guard A
  ↓ 喵声
离岗窗口
  ↓
Dog
  ↓
Bridge
```

## L06

教学目标：Dog 从“风险源”转成“可利用资源”。

标准路径：

```text
Q 叼鱼
→ E 喂狗
→ 狗离开路线
→ Ninja 通过
```

风险路径预留给正式版：

```text
猫当诱饵
→ Dog 追猫
→ Guard 被牵动
```

当前白盒先保证状态接口，不强制加入复杂追逐物理。

## L07

教学目标：事件顺序。

```text
Guard A 离岗
→ 固定窗口
→ Guard B 补位
→ Poison 路线状态变化
→ Bridge
```

所有行为使用固定状态机，不使用随机路线。

## L08

教学目标：多线程整合。

```text
Dog
+
Guard
+
Antidote
+
Caltrop
+
Bridge
```

玩家需要在“运输道具”和“赶场”之间分配时间。

## WorldState

```text
guard_a_departed
guard_b_active
dog_fed
bridge_open
poison_route_safe
```

## 数据约定

每关仍由：

```text
LevelData
RouteData
EventPointData[]
ScoreRuleData
```

驱动，Scene 只负责节点组成。

## 第二章连续试玩 Gate

### L05
- 可从第一章正常切入。
- Q / F / E 均能在对应白盒事件里产生可观察结果。
- 事件完成后 Ninja Route 不丢失。

### L06
- 至少一次完整完成 Dog 喂食流程。
- 道具被消耗后 `carry_item` 回到空。
- 失败后 R 恢复初始状态。

### L07
- Guard A / Guard B 状态可被 Debug HUD 观察。
- 错误顺序能进入明确 `FAIL_WRONG_ORDER`。

### L08
- 至少两个不同 WorldState 同时发生变化。
- 完成后 Space 进入 Chapter02 Unlock。

## 静态检查

本包沿用 v1.2.8 工程模板，并修复其中 L04 `scene_path` 重复 `L` 的文件名问题。

当前环境没有 Godot 可执行程序，因此不宣称 Runtime Smoke Test 已通过。
