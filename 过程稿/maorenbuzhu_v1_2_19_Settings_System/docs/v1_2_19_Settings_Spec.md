# 《猫忍不住》v1.2.19 — Settings System Spec

## 1. 目标

设置系统负责“玩家偏好”，不负责“游戏进度”。

```text
Settings
├─ Input
├─ Audio
├─ Accessibility
├─ Display
└─ Data Management

SaveData
├─ Level Progress
├─ Best Score
├─ Fish
├─ Skins
└─ Cat Talents
```

设置文件：`user://settings.cfg`
进度文件：`user://save.cfg`

## 2. Settings Action

所有选项由 `SettingsManager` 统一读写；UI 不直接写 ConfigFile。

### Input
- 按键重绑继续复用 v1.2.18 的 Action 名称。
- `restore_defaults` 只恢复输入默认，不清除进度。

### Audio
统一对应 v1.2.17 AudioBus：
- master_volume
- music_volume
- sfx_volume
- voice_volume
- ui_volume
- ambient_volume
- mute_all

范围建议 `0.0–1.0`。

### Accessibility
实现层默认提供：
- subtitles_enabled
- reduce_flashing
- reduce_screen_shake
- large_ui
- high_contrast_ui

关键危险信息仍不得只靠颜色表达；设置项只改变呈现，不改变事件规则。

### Display
- fullscreen
- vsync
- resolution_scale
- show_fps（Debug/开发用途）

`show_fps` 不应在 Release 默认开启。

### Data Management
提供：
- restore_settings_defaults
- clear_save_data

`clear_save_data` 必须与 `restore_settings_defaults` 两个动作分离，并要求二次确认。

## 3. 运行时职责

```text
SettingsMenu
  ↓
SettingsManager
  ↓
InputManager / GlobalAudioManager / GlobalUI / SaveManager
```

SettingsMenu 不直接操作：
- EventLog
- WorldState
- ScoreSystem
- LevelData

## 4. 启动流程

```text
Boot
↓
SettingsManager.load()
↓
Apply Display
↓
Apply Audio
↓
Apply Input bindings
↓
Apply UI accessibility
↓
Load SaveData
↓
Main Menu
```

## 5. 暂停规则

Pause 使用 v1.2.18 `PauseController`。

```text
Settings opened during pause
→ Gameplay remains frozen
→ UI remains interactive
```

离开设置后恢复原暂停状态。

## 6. 保存策略

- 滑杆/下拉修改后可即时应用。
- 设置页关闭或切换页面时调用 `save()`。
- 应用异常关闭时，不保证未提交到磁盘的最后一次修改；因此关键项可在修改后立即保存。

## 7. 默认值

| Key | Default |
|---|---|
| master_volume | 1.0 |
| music_volume | 0.8 |
| sfx_volume | 1.0 |
| voice_volume | 1.0 |
| ui_volume | 1.0 |
| ambient_volume | 0.8 |
| mute_all | false |
| subtitles_enabled | true |
| reduce_flashing | false |
| reduce_screen_shake | false |
| large_ui | false |
| high_contrast_ui | false |
| fullscreen | false |
| vsync | true |
| resolution_scale | 1.0 |
| show_fps | false |

## 8. QA

### Settings persistence
1. 修改设置。
2. 退出设置。
3. 重启游戏。
4. 确认设置保持。

### Isolation
1. 完成一个关卡并产生进度。
2. 恢复设置默认。
3. 确认关卡进度仍存在。

### Clear Save
1. 进入数据管理。
2. 执行清除存档。
3. 二次确认。
4. 回主菜单。
5. 确认所有进度回到初始状态，而输入/音频设置保持不变。

### Accessibility
- 关闭字幕后不出现重复字幕。
- 减少闪烁不影响事件逻辑。
- 减少屏幕震动不影响命中/失败判定。
- 大 UI 不遮挡 HUD 关键区域。
