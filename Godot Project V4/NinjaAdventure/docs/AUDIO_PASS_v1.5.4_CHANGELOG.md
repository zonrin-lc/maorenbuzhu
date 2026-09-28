# 《猫忍不住》v1.5.4 音效层级与动作同步变更记录

## 已完成
- 新增 8 个音效资源，全部复用工程内现有本地音频，不引入外部素材。
- 猫互动开始、拾取、放置、快捷移动、路线改变、忍者掉心、Boss 阶段、Boss 击败分别接入独立音效 cue。
- 事件成功音效改为按事件类型/动作选择 cue，避免所有事件都使用同一个 success 声。
- SFX 加入 80–450ms 同类冷却，四路播放器全部忙时不强抢占。
- Boss Phase 切换时，如果音乐资源相同，不再重新 start，避免阶段切换造成音乐跳回开头。
- F 喵叫继续保留 GDD 标注的素材缺口，没有把错误音效冒充猫叫。

## 静态验收
- Python compileall: PASS
- Audio feedback audit: PASS
- Audio layer audit: PASS
- 关键 hook: PASS
