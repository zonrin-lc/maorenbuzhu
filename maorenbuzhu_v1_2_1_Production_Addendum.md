# 《猫忍不住》v1.2.1 · Production Addendum

> 本补充件用于把 v1.2 Production & QA 进一步切成可执行 Sprint。

## 1. Sprint 顺序

### Sprint A · Chapter 1

目标：L01-L04 Whitebox + First Session Gate。

交付：

```text
4 .tscn
4 LevelData
4 RouteData
16~20 EventData
4 Variant B
LevelValidator 覆盖
```

### Sprint B · Chapter 2

目标：L05-L08 Whitebox + Carry/NPC Link/Cause Chain。

重点风险：

- 搬运与路线的资源冲突
- NPC 联动死循环
- 顺序错误后的恢复

### Sprint C · Chapter 3

目标：L09-L12 Whitebox + Boss Active Gate。

重点风险：

- 雷雨环境可读性
- 连锁事故可追踪
- Boss Phase 2 主动窗口

## 2. 每关 Definition of Done

```text
Design
[ ] Beat Sheet 已确认
[ ] Event Graph 已确认
[ ] Route 已确认

Data
[ ] LevelData
[ ] RouteData
[ ] EventData
[ ] Variant B

Godot
[ ] Scene 可运行
[ ] Reset 正常
[ ] Debug Jump 正常
[ ] LevelValidator 通过

QA
[ ] 标准解
[ ] 风险解
[ ] 最晚成功
[ ] 标准失败
[ ] Save/Load
[ ] Variant B

Experience
[ ] 玩家能解释失败
[ ] 无无意义等待
[ ] 猫始终有下一件事可做
```

## 3. 关卡生产负责人检查

每关完成时必须回答五个问题：

1. 玩家为什么要提前行动？
2. 玩家现在为什么不能直接解决全部问题？
3. 哪个事件会因为前一个事件而改变？
4. 哪个地方产生风险与收益交换？
5. 忍者最后会如何错误归因？

五问中任一问题答不上来，关卡回到 Whitebox。
