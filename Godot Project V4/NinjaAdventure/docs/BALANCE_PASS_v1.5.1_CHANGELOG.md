# 《猫忍不住》v1.5.1 变更记录

- 加入 BalanceDirector 时间线反馈：舒适 / 三星冲刺 / 三星临界 / 超过三星线。
- Gameplay HUD 显示本关三星时间线与当前节奏状态。
- 结算面板与居酒屋结算显示“三星线内/超过三星线”。
- 结算 payload 增加 target_time 与 time_ratio。
- 清理 8 个未被 12 个 LevelData 引用的旧事件资源，避免发布审计把遗留资源计入事件总量。
- 发布审计增加 referenced event resource hygiene 检查。
- 12 关当前实际被 LevelData 引用的事件资源总数：56。

## 参数冻结

本轮不修改已有三星时间参数；下一次参数变化应来自真实试玩数据。
