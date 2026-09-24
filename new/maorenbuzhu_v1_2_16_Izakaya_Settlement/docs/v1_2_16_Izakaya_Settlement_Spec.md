# 《猫忍不住》v1.2.16 · 居酒屋结算与动态吹牛规范

## 1. 目标

建立统一的关卡结束表现层：

Gameplay Result
↓
EventLog snapshot
↓
Importance classification
↓
Template compatibility
↓
Parameter fill
↓
Ninja boast line
↓
Cat reaction
↓
Paw result
↓
Meta save

设计目标：
- 首次通关有完整演出。
- 重玩压缩至 8–12 秒默认结算。
- 吹牛必须来自玩家本局真实发生的 Gameplay Facts。
- 不能让随机模板产生与本局事实矛盾的台词。
- 结算不能反向改变本局评分结果。

## 2. 结算状态机

```text
SETTLEMENT_ENTER
↓
BOAST_ANALYZE
↓
BOAST_LINE_01
↓
BOAST_LINE_02(optional)
↓
CAT_REACTION
↓
PAW_REVEAL
↓
META_COMMIT
↓
SETTLEMENT_EXIT
```

重复挑战默认：

```text
BOAST_ANALYZE
↓
BOAST_LINE_01
↓
PAW_REVEAL
↓
META_COMMIT
```

完整结算可由玩家展开。

## 3. BoastGenerator

正式流程固定为：

```text
EventLog
↓
Importance
↓
Tags
↓
Compatible Template
↓
Fill Params
↓
Play
```

禁止：
- 只按 random index 选台词。
- 引用本局没有发生的事件。
- 把玩家未完成的动作写成已完成。
- 在结算阶段计算新的猫爪结果。

## 4. Importance 优先级

```text
EMERGENCY
>
NEAR_DEATH
>
BOSS
>
CHAIN
>
ROUTE_CHANGE
>
STANDARD_SUCCESS
```

只取最高优先级事件作为第一句；第二句可取次高优先级且 Tag 不重复。

## 5. Banter Template 数据

字段：

```text
banter_id
priority
required_tags
forbidden_tags
level_scope
difficulty_scope
text_template
cat_response
voice_id
weight
```

其中 `weight` 只用于同等兼容模板之间的轮换；不用于决定“发生了什么”。

## 6. 标准 Tag

```text
TRIPWIRE
GUARD
DOG
POISON
BRIDGE
CALTROP
DYNAMITE
BOSS_CRANE
BOSS_GOURD
BOSS_CALTROP
EMERGENCY
NEAR_DEATH
CHAIN
ROUTE_CHANGE
HIGH_RISK
SHORTCUT
ZERO_SUSPICION
NO_DAMAGE
```

## 7. 模板示例

### Emergency

条件：`EMERGENCY`

忍者：
> “最后那一下？我故意留给敌人的。”

猫：
> “……”

### Boss + Caltrop

条件：`BOSS_CALTROP`

忍者：
> “那家伙刚冲过来，我只用气势就让他脚底打滑。”

### Chain

条件：`CHAIN`

忍者：
> “我早就算到他们会一个接一个犯错。”

### Route Change

条件：`ROUTE_CHANGE`

忍者：
> “我临时换路，正好避开他们的埋伏。”

## 8. 猫反应

猫的反应不能抢走忍者功劳，保持静默喜剧：

- `NORMAL`：舔爪子。
- `GOOD`：抬眼一次。
- `RIDICULOUS`：停顿 0.5s 后舔爪。
- `EMERGENCY`：先喘气，再舔爪。

## 9. 猫爪结果

ResultPanel 只读取已经算好的 ScoreResult：

```text
paws
mission_complete
ninja_hp
max_suspicion
elapsed_time
high_risk_rescue
chain_rescue
shortcut_or_dependency_mastery
boss_mechanics_success
```

禁止 ResultPanel 自己重算。

## 10. 首次 / 重复结算

### 首次通关

- 关卡标题
- 忍者进入居酒屋
- 2~3 句吹牛
- 猫反应
- 1→2→3 猫爪揭示
- 新解锁提示

目标 15–25 秒。

### 重复挑战

- 1 句动态吹牛
- 猫反应
- 猫爪
- 新记录/解锁提示

目标 8–12 秒。

## 11. Meta 提交顺序

```text
ScoreSystem finalize
↓
BoastGenerator snapshot
↓
ResultPanel show
↓
ProgressManager commit
↓
SaveManager save
```

若 Save 失败，结算画面仍可完成；需要显示“本次进度未保存”而不是阻塞玩家。

## 12. 解锁展示

只展示本次新变化：
- 新猫爪记录
- 新鱼干
- 新皮肤
- 新猫技艺
- Hard / Hard+ 解锁

不要在每次重复挑战都展示全部收藏。
