# 《猫忍不住》L10「炸药不能乱碰」v1.4.10

本版以 GDD v1.3 的“连锁事故”核心为基线。

## 主要落地
- 4 个 MAIN：炸药 A → 守卫 A → 恶狗 → 毒雾。
- 1 个 OPTIONAL：提前开的蒺藜，真实阻挡 Ninja，但不计入主线事件数。
- 炸药成功会改变守卫 A 位置，并记录 `caused_event_id`。
- 守卫 A 成功离岗，狗事件完成后才释放 Ninja。
- Dog 抵达后切换为标准线；若 Guard A 失败留岗，则固定切到 POISON_FORCED 线。
- 标准线开启提前蒺藜窗口，2.5 秒未处理则 Ninja 硬闯并掉 1 心。
- 毒雾前提供标准解毒药；毒雾事件激活时出现迟到解毒药，拾取计 high-risk rescue。
- 增加 L10 RoofJump。
- Ninja 速度为 66 px/s。
- 修复基线工程中 L07 event_resolved 的误插 return 逻辑，避免把查询函数逻辑混进 void 信号处理。

## 静态验收
- 4 MAIN + 1 OPTIONAL：PASS
- 无旧 L10_E04_DYNAMITE_B：PASS
- 无旧 L10_E05_POISON：PASS
- L10 route 66 px/s：PASS
- Dog arrival route switch：PASS
- Caltrop blocker：PASS
- Late antidote：PASS
- L07 event_resolved void 流程：PASS
- Godot 4 Runtime 当前环境不可用，未声明实机运行通过。
