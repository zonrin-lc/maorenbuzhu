# v1.2.15 Meta UI Flow

```text
Title
 ↓
Continue
 ↓
Chapter Select
 ├─ Chapter 01
 ├─ Chapter 02
 └─ Chapter 03

Collection
 ├─ Skins
 ├─ Fish
 └─ Talents

Difficulty
 ├─ Normal
 ├─ Hard
 └─ Hard+
```

## Result → Save

```text
ResultPanel
→ ProgressManager.on_level_result()
→ TalentTracker.ingest_event()
→ SaveManager.mark_level_complete()
→ refresh UI
```

关卡场景不得直接访问 Control 节点，也不得自己决定皮肤、Hard、Hard+ 解锁。
