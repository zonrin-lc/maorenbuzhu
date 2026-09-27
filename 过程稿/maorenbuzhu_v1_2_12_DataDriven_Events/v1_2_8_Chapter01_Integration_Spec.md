# 《猫忍不住》v1.2.8 · Chapter 01 Integration Spec

## 目标
把 L01–L04 从独立原型串成第一章连续试玩路径。

## 章节流程
```text
L01 第一份差事
  ↓ Space
L02 他总是踩同一个坑
  ↓ Space
L03 谁在看猫
  ↓ Space
L04 村口大事故
  ↓ Space / Chapter Clear
第一章结算
```

## 统一输入
- WASD：猫移动
- Shift：疾跑
- E：互动
- F：喵叫
- Ctrl：卖萌
- R：重开
- Space：通关后进入下一关
- Enter：章节结束后回到 L01

## L02
教学重点：连续赶场。三个事件仍然使用已有机制，但窗口压缩，迫使玩家提前离开当前事件点。

## L03
教学重点：被看见与暴露动作的区别。通过 Guard 事件、互动动作和卖萌，检验玩家是否开始主动管理怀疑。

## L04
教学重点：事件顺序。Guard → Tripwire → Watergap 构成第一章综合题；程序层面仍保持固定路线、离散事件状态，不引入自由 AI。

## Godot 资产约定
```text
scenes/levels/L01_first_job.tscn
scenes/levels/L02_same_old_trap.tscn
scenes/levels/L03_who_is_watching.tscn
scenes/levels/L04_village_accident.tscn
scenes/levels/Chapter01_Clear.tscn

data/levels/ch01_village/*.tres
data/routes/L01-L04_Ninja_Main.tres
data/events/L01-L04_*.tres
data/score/L01-L04_Score.tres
```

## 本版边界
这是第一章白盒连续试玩版本，不是最终美术成品。Guard 多实例、复杂搬运、复杂 NPC 联动和居酒屋正式结算仍按后续 System/Level Sprint 接入。

## QA Gate
1. L01 通关后 Space 必须进入 L02。
2. L02 → L03、L03 → L04、L04 → Chapter01 Clear。
3. 每关 R 均可回到该关初始状态。
4. EventPoint 顺序、Ninja Route、ScoreSystem、WorldState 不得因切场失效。
5. LevelValidator 对四关均返回 0 个错误。
6. Chapter Clear Enter 可回到 L01。
