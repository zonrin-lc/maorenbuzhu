# 《猫忍不住》v1.2.20 — Main Menu / Chapter / Level Select Flow

## 1. 目标

将游戏入口统一为：

```text
Boot
 ↓
Settings Load
 ↓
Save Load
 ↓
Main Menu
 ├─ Continue
 ├─ Chapter Select
 │   └─ Level Select
 └─ Settings
```

## 2. Continue 规则

1. 无进度：L01。
2. 当前关已完成：进入下一关。
3. 当前关未完成：继续当前关。
4. L12 完成后 Continue 回到 L12 / 章节完成态，不自动循环。

## 3. Chapter Unlock

- Chapter 01：默认开放。
- Chapter 02：完成 L04。
- Chapter 03：完成 L08。

## 4. Level Unlock

- L01：默认开放。
- L02–L12：完成前一关后开放。
- Level Select 禁止绕过解锁条件直接启动。

## 5. Level Select 展示

每个关卡按钮至少显示：

- LevelID
- 中文关卡名
- 当前 Normal 最佳猫爪
- 锁定 / 解锁状态

不在选择界面显示“正确解法”。

## 6. 设置边界

Main Flow 可以跳转 Settings，但不得直接修改 Settings；由 v1.2.19 SettingsManager 接管。

## 7. Scene Contract

```text
MainMenu
ChapterSelect
LevelSelect
Result
```

各页面不直接实现 Gameplay；只负责导航和读取 SaveData。

## 8. 后续接入

真实 12 个关卡 Scene 到位后，`LevelCatalog.scene_path()` 直接指向：

```text
res://scenes/levels/L01.tscn
...
res://scenes/levels/L12.tscn
```

关卡结束后统一回到 ResultPanel，再由 ResultPanel 根据 `next_scene_path` 返回 Main/Chapter/Level Select。

## 9. QA

### Fresh Save
- 首次启动 → Main Menu。
- Continue → L01。

### Progressive Unlock
- 完成 L01 → L02 解锁。
- 完成 L04 → Chapter 02 解锁。
- 完成 L08 → Chapter 03 解锁。
- 完成 L12 → 全流程结束状态。

### Save Isolation
- 设置恢复默认不影响章节 / 关卡进度。
- 清除存档不改变设置。

### Navigation
- 所有页面可返回。
- Locked Level 不可进入。
- Continue 与 Chapter Select 对当前存档状态一致。
