# 《猫忍不住》v1.2.14 · Global UI / HUD + Tutorial Implementation Spec

## 0. 目标

把 L01-L12 的共用信息统一到一套 UI 层：

```text
GlobalUI
├─ TopBar
│  ├─ NinjaMoodBubble
│  └─ NinjaLocator
├─ SuspicionEye
├─ BottomBar
│  ├─ Stamina
│  ├─ CarryItem
│  ├─ InteractPrompt
│  ├─ MeowButton
│  └─ EmoteButton
├─ TutorialDirector
├─ FailureDiagnostic
├─ ResultPanel
└─ PauseOverlay
```

UI 只表达事实与当前可用操作，不显示“正确答案”。

## 1. 信息分层

### 常驻

- NinjaLocator：忍者方向与距离级别（Near / Mid / Far），不显示精确坐标。
- SuspicionEye：猫眼瞳孔状态，对应 Normal / Notice / Alert / High / BrokenCover。
- Stamina：当前体力。
- CarryItem：当前叼取物。

### 情境化

- InteractPrompt：只有存在合法交互目标时出现。
- NinjaMoodBubble：由 NinjaController 状态触发。
- TutorialToast：首次教学事件触发一次。
- FailureDiagnostic：失败后显示原因和“下一次可改变的行为”。
- ResultPanel：完成后显示猫爪、时间、怀疑峰值、风险风格。

## 2. 禁止信息

HUD 不得显示：

```text
先做 A
正确路线
最优解
事件答案
```

## 3. SuspicionEye

映射：

| 数值 | 状态 | UI |
|---:|---|---|
| 0-24 | Normal | 瞳孔放松 |
| 25-49 | Notice | 轻微收缩 + 小问号 |
| 50-79 | Alert | 明显收缩 + 回头提示 |
| 80-99 | High | 强烈收缩 + 搜索波纹 |
| 100 | Broken | 眼睛闭合/警报演出 |

不显示数字。

## 4. NinjaLocator

屏幕边缘方向箭头：

```text
NinjaController.global_position
→ GlobalUI
→ 屏幕边缘 Anchor
```

距离不必显示数字，只显示：

```text
Near / Mid / Far
```

情绪只改变箭头动画节奏，不改变方向判断。

## 5. InteractionPrompt

统一支持：

```text
E 互动
Q 叼取/放置
F 喵叫
Ctrl 卖萌
Space 跳跃/攀爬
Shift 疾跑
```

提示仅在“当前操作在当前目标上合法”时出现。

## 6. TutorialDirector

第一章逐步教学：

```text
L01：E / F / 推动
L03：怀疑 / Ctrl
L05：Q / 搬运
其余：不新增按钮，只减少文字提示
```

每个 TutorialID 默认只展示一次，并写入 SaveData。

教程卡结构：

```text
TutorialData
- tutorial_id
- trigger_event
- input_action
- title
- body
- icon
- duration
- once_only
```

禁止教程直接描述最优方案；它只能说明“能做什么”。

## 7. FailureDiagnostic

失败面板只提供：

```text
发生了什么
↓
对应 FAIL_CODE
↓
玩家下一次可以改变什么行为
```

映射：

| FAIL_CODE | 文案方向 |
|---|---|
| FAIL_TOO_LATE | 可以更早赶到事件点 |
| FAIL_WRONG_ORDER | 某个事件状态改变了后续路线 |
| FAIL_SUSPICION | 这次动作被忍者看到了 |
| FAIL_NINJA_DEATH | 忍者在事件前没有得到保护 |
| FAIL_BOSS_FINISHER | Boss 最后的终结动作没有被化解 |
| FAIL_ROUTE_BLOCKED | 路线上的关键空间状态没有打开 |
| FAIL_TIMEOUT | 本局没有在时间窗口内完成 |

## 8. ResultPanel

完成后：

```text
猫爪 1-3
↓
完成时间
↓
最大怀疑状态
↓
Risk Style
↓
一条动态吹牛台词
```

不在主结果画面展示复杂统计；详细 EventLog 留给 Debug / Meta 页面。

## 9. Pause

暂停必须：

- 完全冻结 Gameplay
- 停止计时
- 停止 Ninja / NPC 状态变化
- 停止怀疑值变化
- 恢复后继续

## 10. Accessibility

关键状态不能只依赖颜色：

- Suspicion：图标 + 动画 + 声音
- Ninja 方向：箭头 + 位置信息
- 交互：图标 + 按键
- 失败：图标 + 文案

支持可重绑定输入。

## 11. 12关统一原则

所有关卡只能通过：

```text
UIState / Signal / Data
```

驱动 UI，不允许关卡脚本直接操作具体 Control 节点。

推荐：

```text
LevelManager
→ Signals
→ UIManager
```

而不是：

```text
L07.gd
→ $CanvasLayer/HUD/.../Label
```
