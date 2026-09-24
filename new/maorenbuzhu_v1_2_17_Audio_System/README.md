# 《猫忍不住》v1.2.17 — Audio System Pack

本包把 v1.2 的音频从 Manifest 提升为统一运行系统。

## 目标
- GlobalAudioManager 统一管理 BGM / SFX / Voice
- 基于 Gameplay State 切换音乐层，不让关卡脚本直接播放背景音乐
- EventLog / WorldState 只提供事实，音频系统自己决定表现
- 猫叫保持独立 SFX 入口
- Boss 音乐支持 Prepare / Phase 1 / Phase 2 / Phase 3 / Defeat
- Audio Bus 支持 Music / SFX / Voice / UI / Ambient 五组
- Save / Load 不保存正在播放的音频状态

## 当前限制
本环境没有 Godot Runtime，因此本包完成的是工程结构、资源映射、代码接口与静态审计；未宣称实际运行时声音已验证。
