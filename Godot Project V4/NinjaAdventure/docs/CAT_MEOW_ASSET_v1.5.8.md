# 《猫忍不住》v1.5.8｜猫叫素材补全

## 状态

`SFX_MEOW` 已从 Missing 改为 `Ready-Original-Generated`。

本次加入 3 个独立的原创程序合成猫叫 WAV：

- `audio/sfx/cat_meow_short.wav`：短促、偏明亮。
- `audio/sfx/cat_meow_bright.wav`：较长、音高更高。
- `audio/sfx/cat_meow_low.wav`：较低沉。

这些文件均为本工程专用的原创程序合成声音，不使用狗叫、鸟叫、忍者 Voice 或其他错误素材冒充猫叫。

## 播放规则

F 键触发 `CatController.meow_triggered` 后，由 `GlobalAudioManager.play_cat_meow()` 从三种猫叫中轮换选择；最短重复间隔为 350ms，并加入轻微音高随机，减少连续按键时的机械重复。

## 验收

- WAV：PCM16 / Mono / 44.1kHz。
- 资源文件完整，可直接被 Godot 4 导入。
- `SFX_MEOW` manifest 已更新。
- 旧的“素材缺口”警告已移除。
