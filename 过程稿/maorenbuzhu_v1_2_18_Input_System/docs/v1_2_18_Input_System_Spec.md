# 《猫忍不住》v1.2.18 Input System Spec

## 1. 设计目标

输入系统只暴露 Gameplay Action，不允许 Gameplay 脚本直接读取 WASD、Shift、E、Q、F、Ctrl 等物理按键。

统一链路：

```text
Physical Input
↓
InputMap / Input Action
↓
InputManager
↓
Gameplay / UI / Tutorial
```

这样可以让：

- 键鼠与手柄共享逻辑
- 玩家重绑键位后教程自动更新
- UI 显示当前实际绑定
- 后续移动端虚拟按键只需映射 Action

## 2. Action 列表

| Action | 默认键鼠 | 默认手柄 | Gameplay |
|---|---|---|---|
| move_up | W | Left Stick Up | 移动 |
| move_down | S | Left Stick Down | 移动 |
| move_left | A | Left Stick Left | 移动 |
| move_right | D | Left Stick Right | 移动 |
| sprint | Shift | Right Trigger | 疾跑 |
| interact | E | South / A | 咬/推/拍 |
| carry | Q | West / X | 叼取/放下 |
| meow | F | East / B | 喵叫 |
| emote | Ctrl | North / Y | 卖萌 |
| jump | Space | Left Shoulder | 跳跃/攀爬 |
| pause | Esc | Start | 暂停 |
| retry | R | Select / Back | 重开 |
| confirm | Enter | South / A | 确认 |
| cancel | Esc | East / B | 取消 |

> 注：具体手柄物理键名由 Godot Joypad 映射层解释；文档中的 A/B/X/Y 以玩家常见命名表达，不绑定某一厂商字母布局。

## 3. Gameplay 读取规范

推荐：

```gdscript
Input.is_action_pressed("move_up")
Input.is_action_just_pressed("interact")
```

禁止：

```gdscript
Input.is_key_pressed(KEY_W)
Input.is_key_pressed(KEY_E)
```

禁止把物理键码写入关卡逻辑。

## 4. 输入优先级

```text
System Modal
>
Pause
>
Settlement / Dialog
>
Tutorial Modal
>
Gameplay
```

暂停时 Gameplay Action 必须完全冻结。

UI 可以继续消费：
- confirm
- cancel
- pause

## 5. Pause

Pause 采用：

```gdscript
get_tree().paused = true
```

Gameplay 节点处理模式必须默认为 `Pausable`。
Pause UI 使用 `When Paused`，保证暂停菜单仍可操作。

暂停时：
- Ninja 不移动
- Cat 不移动
- Event timer 停止
- Suspicion timer 停止
- Boss timer 停止
- Audio 不强制暂停，由音频设置决定是否降低或保持

## 6. Rebind

重绑定只允许修改以下玩家可配置 Action：

```text
move_up/down/left/right
sprint
interact
carry
meow
emote
jump
pause
retry
```

`confirm / cancel` 可保留，但 UI 导航提供安全默认键，防止玩家把自己锁死。

## 7. 冲突处理

保存前检查：

- 同一设备同一键绑定冲突
- 一个 Action 是否被清空
- 是否尝试删除最后一个移动方向
- 是否删除 pause

处理方式：

```text
新绑定与旧 Action 冲突
→ UI 弹确认
→ 替换 / 取消
```

不自动静默覆盖。

## 8. UI 按键显示

Tutorial / InteractionPrompt 不直接显示字母。

必须请求：

```gdscript
InputDisplay.get_binding_label("interact")
```

结果可能是：

```text
E
A
Mouse1
自定义键名
```

UI 永远显示玩家当前绑定。

## 9. 设备切换

检测最近输入来源：

```text
KEYBOARD_MOUSE
GAMEPAD
TOUCH
```

UI 根据最近输入设备切换图标组。

切换不重置 Action。

## 10. 手柄要求

必须支持：
- 左摇杆移动
- 肩键/扳机执行操作
- Start 暂停
- B/East 取消
- A/South 确认

所有 Gameplay 行为必须与键鼠路径一致。

## 11. 移动端兼容层

v1.2.18 不直接重做移动端 UI，只定义兼容接口：

```text
VirtualMove → move_* Action
VirtualButton → interact/carry/meow/emote/sprint/jump
```

以后 H5 / Mobile 可复用 Gameplay，不修改事件逻辑。

## 12. 无障碍

- 所有可重绑动作可恢复默认
- UI 提供“恢复默认”
- 不依赖颜色表示当前设备
- 手柄和键鼠逻辑一致
- Pause 时不发生隐形 Gameplay 计时

## 13. QA Gate

### 输入
- [ ] 键鼠默认操作全通
- [ ] 手柄默认操作全通
- [ ] 重绑后 Gameplay 正常
- [ ] 重绑后 Tutorial 显示正确
- [ ] 冲突弹窗可处理
- [ ] 恢复默认有效
- [ ] Pause 完全冻结 Gameplay
- [ ] Resume 不丢状态
- [ ] Retry 不残留旧输入
- [ ] UI 导航不会把 Gameplay Action 穿透

### 三关专项
- [ ] L01 E/F/Ctrl
- [ ] L05 Q + 手柄映射
- [ ] L09-L12 Sprint / Jump / Pause
- [ ] Boss Phase 2 不因 UI 输入阻塞

## 14. 生产原则

```text
Gameplay 读 Action
UI 显示 Action
Tutorial 读 Action
Mobile 映射 Action

物理按键只存在于 InputMap / Rebind 层
```
