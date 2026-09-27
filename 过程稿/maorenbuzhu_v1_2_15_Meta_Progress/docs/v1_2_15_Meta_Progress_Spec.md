# 《猫忍不住》v1.2.15 · Meta / Save / Progress Specification

## 1. 目标

把“12 个主线关卡”从一次性流程变成可持续保存的完整游戏进度。

数据关系：

```text
Gameplay Result
    ↓
ProgressManager
    ↓
SaveData
    ↓
SaveManager
    ↓
MainMenu / ChapterSelect / Collection / ResultPanel
```

## 2. SaveData

```text
schema_version
selected_skin
selected_difficulty
completed_levels[12]
best_paws[12]
best_time_ms[12]
best_max_suspicion[12]
fish_collected[12][3]
unlocked_skins[]
unlocked_talents[]
talent_counters{}
tutorial_seen[]
hard_mode_unlocked
hard_plus_unlocked
last_level_id
```

### 不保存

```text
player_should_do_X
current_runtime_world_state
live_ninja_position
live_event_state
```

关卡瞬时状态只存在 Runtime；存档只记录 Meta 事实。

## 3. 12关解锁规则

```text
L01 永久开放
完成 L01 → L02
完成 L02 → L03
...
完成 L11 → L12
完成 L12 → Chapter 03 Clear
```

每关只需要“完成”即可解锁下一关；猫爪不参与主线锁。

## 4. 章节状态

```text
Chapter01Open = true
Chapter01Clear = L04 complete
Chapter02Open = L04 complete
Chapter02Clear = L08 complete
Chapter03Open = L08 complete
Chapter03Clear = L12 complete
```

## 5. Hard Mode

```text
all 12 completed → Hard Mode
```

Hard Mode 不改变存档中的 Normal 最佳成绩；每个难度拥有独立成绩页：

```text
best_paws[level_id][difficulty]
best_time_ms[level_id][difficulty]
best_max_suspicion[level_id][difficulty]
```

## 6. Hard+

```text
all 12 levels have 3 paws on Normal → Hard+
```

Hard+ 仍不新增核心操作；只提高时间、因果要求、剧本压力。

## 7. 猫皮肤

本轮采用以下“内容解锁”规则（实现层新约定）：

| Skin | 解锁 |
|---|---|
| Black | 默认 |
| Orange | 完成 L04 |
| White | 完成 L08 |
| Gray | 完成 L12 |
| Cyclop | Normal 全 12 关 3 猫爪 |

皮肤只影响外观、彩蛋台词，不改变速度、体力、怀疑值等 Gameplay 参数。

## 8. 鱼干

每关 3 个，共 36 个。

规则：

- 只能在猫可达区域收集。
- 不影响主线完成。
- 不改变猫基础数值。
- 收集后立即写入 Meta；重复进入已收集位置不重复计数。

## 9. 猫技艺

猫技艺继续作为玩家履历，不作为强力数值成长。

```text
极限拆绳
借狗之势
不留痕迹
猫步
幕后操盘
最后一秒
```

推荐计数来源：EventLog 聚合器，不由关卡脚本直接写“解锁”。

### 建议阈值

| Talent | Counter / 条件 |
|---|---|
| 极限拆绳 | 3 次 `late_success_window <= 1.0s` |
| 借狗之势 | 5 次 `DOG -> GUARD` 联动成功 |
| 不留痕迹 | 3 个不同关卡 `max_suspicion < 20` |
| 猫步 | 1 关完成且 sprint_time = 0 |
| 幕后操盘 | 3 次 `dependency_depth >= 3` |
| 最后一秒 | 1 次 Emergency Rescue |

这些阈值是 v1.2.15 的 Meta 实现约定，不修改 v1.1 的核心评分规则。

## 10. Save 写入时机

只允许以下时机写入：

```text
Level Complete
Fish Collected
Skin Selected
Talent Unlocked
Tutorial Seen
Difficulty Unlock
```

禁止每帧写盘。

## 11. Save API

```gdscript
SaveManager.load_game()
SaveManager.save_game()
SaveManager.reset_save()
SaveManager.get_data()
SaveManager.mark_level_complete(level_id, result)
SaveManager.collect_fish(level_id, fish_index)
SaveManager.unlock_skin(skin_id)
SaveManager.unlock_talent(talent_id)
SaveManager.mark_tutorial_seen(tutorial_id)
```

## 12. 原子保存

建议：

```text
user://save.tmp
→ flush
→ rename
→ user://save.cfg
```

写入失败时不得覆盖旧存档。

## 13. Migration

`schema_version` 初始为 1。

升级规则：

```text
unknown higher version → refuse write, preserve file
older version → migrate in memory → save new schema
```

## 14. Meta 页面

### ChapterSelect

显示：

- 章节是否解锁
- 每章完成度
- 猫爪总数
- 鱼干总数

### Collection

显示：

- 猫皮肤
- 鱼干
- 猫技艺
- 玩家统计

### DifficultySelect

显示：

- Normal
- Hard（全部 12 关完成后）
- Hard+（Normal 全 12 关 3 猫爪后）

## 15. 玩家统计

只展示事实：

```text
完成关卡数
累计猫爪
收集鱼干
累计高风险救场
累计怀疑峰值最低纪录
已解锁猫技艺
```

不要给玩家一个单一“综合评分”去覆盖不同玩法风格。

## 16. QA

必须覆盖：

- 首次启动创建默认存档
- 完成 L01 自动解锁 L02
- L04 完成解锁 Chapter02
- L08 完成解锁 Chapter03
- L12 完成解锁 Hard
- Normal 全三星解锁 Hard+
- 鱼干去重
- 皮肤去重
- 猫技艺阈值边界
- Save 重启恢复
- Save 损坏恢复旧文件
- 版本迁移
- Reset Save
- 暂停时不写入中间 Runtime 状态
