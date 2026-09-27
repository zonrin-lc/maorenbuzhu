# 《猫忍不住》v1.2.17 Audio System Spec

## 1. 音频层级

```text
GlobalAudioManager
├─ Music
│  ├─ Chapter BGM
│  ├─ Tension Layer
│  └─ Boss Layer
├─ SFX
│  ├─ Cat Action
│  ├─ Event Feedback
│  ├─ NPC Reaction
│  ├─ Damage / Impact
│  └─ Environment
├─ Voice
│  ├─ Ninja Reaction
│  └─ Izakaya Boast
├─ UI
│  ├─ Tutorial
│  ├─ Result
│  └─ Meta
└─ Ambient
   ├─ Rain
   ├─ Dock
   └─ Castle
```

## 2. AudioBus

```text
Master
├─ Music
├─ SFX
├─ Voice
├─ UI
└─ Ambient
```

所有 Bus 默认允许在设置页独立调节。

## 3. BGM 状态

### Village
- `VILLAGE_CALM`
- `VILLAGE_TENSION`

### Dock
- `DOCK_CALM`
- `DOCK_TENSION`

### Castle
- `CASTLE_CALM`
- `CASTLE_TENSION`
- `BOSS_PREPARE`
- `BOSS_PHASE_1`
- `BOSS_PHASE_2`
- `BOSS_PHASE_3`
- `BOSS_DEFEAT`

## 4. 状态切换原则

Gameplay 只发事实 Signal：

```text
level_started
suspicion_state_changed
ninja_hp_changed
boss_phase_changed
event_high_risk
mission_completed
mission_failed
```

Audio Manager 根据这些事实切换声音。

禁止：

```text
LevelManager.play_music("xxx.ogg")
```

推荐：

```text
WorldState.emit_signal("boss_phase_changed", 2)
GlobalAudioManager 响应
```

## 5. 动态音乐规则

### 怀疑

Normal：无额外层。

Notice：高频轻打击层淡入。

Alert：紧张层继续增加。

High Alert：紧张层达到上限，但不循环加入新的旋律，避免噪音化。

### 忍者受伤

只触发短 SFX；不立即切换整首 BGM。

### 高风险救场

进入 `RISK_WINDOW` 时：
- 暂时降低 BGM 低频占比
- 提升节奏层
- 成功后快速释放

## 6. Boss 音频

```text
BOSS_PREPARE
    ↓
BOSS_PHASE_1
    ↓
BOSS_PHASE_2
    ↓
BOSS_PHASE_3
    ↓
BOSS_DEFEAT
```

Phase 2 必须让玩家听出“现在要处理蒺藜了”的节奏变化，但不能提供“正确答案”提示。

## 7. 猫叫

独立 Action SFX：

```text
cat_meow_01
cat_meow_02
cat_meow_03
```

规则：
- F 每次触发播放一个变体
- 最短重复间隔 0.35s
- 同一关不连续播放相同变体超过 2 次
- 音量进入 SFX Bus

## 8. Ninja Voice

忍者语气音不是完整对白。

分类：

```text
CONFIDENT
CONFUSED
SURPRISED
PROUD
PANIC
SETTLEMENT
```

声音只承担情绪，不替代字幕。

## 9. 事件反馈音

每类事件至少需要：

```text
PREPARED
SUCCESS
FAIL
NEAR_MISS
RESET
```

CRITICAL 事件必须至少有 SUCCESS + FAIL + NEAR_MISS 三档反馈。

## 10. Accessibility

- 所有关键 gameplay 声音必须有视觉对应。
- Boss Phase 不允许只用声音通知。
- Audio Settings 提供 Music / SFX / Voice / UI / Ambient 五个滑杆。
- 一键静音不暂停 Gameplay。

## 11. 音频抢占规则

优先级：

```text
System Error
>
Mission Fail
>
Boss Phase
>
High Risk / Near Miss
>
Event Success
>
NPC Voice
>
Ambient
```

同类 SFX 可抢占低优先级同类 SFX，但 Voice 不得被普通 UI 音频打断。

## 12. 参考素材映射

### BGM
- Village: `Musics/23 - Road.ogg`
- Village Alt: `Musics/26 - Lost Village.ogg`
- Dock: `Musics/18 - Aquatic.ogg`
- Castle: `Musics/10 - Dark Castle.ogg`
- Boss Tension: `Musics/28 - Tension.ogg`

### Voice / SFX
- Ninja: `Audio/Sounds/Voice/Voice1~10.wav`
- Dog: `Audio/Sounds/Creature/Dog.wav`
- Success: `Audio/Jingles/Success1~4.wav`
- Meow: 外部原创音频

## 13. First-Pass Mix Targets

仅作为原型混音起点，最终以真实设备试听为准：

```text
Music   0 dB reference
SFX    -3 dB
Voice  -2 dB
UI     -6 dB
Ambient -8 dB
```

禁止把这些值视为最终发布数值。
