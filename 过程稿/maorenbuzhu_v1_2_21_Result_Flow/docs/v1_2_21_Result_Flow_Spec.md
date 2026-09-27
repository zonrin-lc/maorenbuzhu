# 《猫忍不住》v1.2.21 · Result Flow 实施规格

## 目标
把“Gameplay 完成 → 结算 → Save 回写 → 解锁下一关 → 下一关 / 重玩 / 关卡选择 / 主菜单”闭成单一状态链。

## 正式状态链

```text
Gameplay
  ↓
ScoreResult
  ↓
AppFlow.complete_level()
  ↓
SaveManager.mark_level_complete()
  ↓
ProgressManager / SaveData
  ↓
ResultFlow.pending_result
  ↓
Result Scene
  ├─ 重玩本关
  ├─ 下一关
  ├─ 关卡选择
  └─ 主菜单
```

## 回写规则

完成关卡时，必须先保存，再进入结算页。

失败不写“完成关卡”，只允许通过现有失败诊断返回 Retry。

## Next 规则

- L01→L02 … L11→L12：若下一关已解锁，直接进入下一关。
- L12：进入第三章完成态 / 章节选择，不制造 L13。
- 若未来加入非线性解锁，`next_level()` 仍只负责候选顺序，`can_start()` 负责最终权限。

## Retry

Retry 使用当前 `level_id`，不得复用上一局的 ScoreResult 数值。

## Level Select

从结算页进入关卡选择时，必须重新从 SaveData 读取猫爪和解锁状态，不缓存结算前状态。

## Save 安全

结算页只是读取 pending result；进度真值始终以 SaveData 为准。

## 防重复提交

同一次结算只允许调用一次 `complete_level()`。重复点击按钮不得重复改变最佳成绩之外的统计。

## 验收表

| Case | Expected |
|---|---|
| L01 首通 | L02 解锁 |
| L05 首通 | L06 解锁 |
| L08 首通 | L09 解锁 |
| L12 首通 | 全流程完成，不出现 L13 |
| 重玩已完成关 | 不改变解锁，只更新更好成绩 |
| 结算→关卡选择 | 显示最新猫爪 |
| 结算→主菜单→Continue | 从最新进度计算 Continue |
| 连点 Next | 只能进入一次目标场景 |
| Save 失败 | 结算 UI 不能伪造“已保存”提示 |
