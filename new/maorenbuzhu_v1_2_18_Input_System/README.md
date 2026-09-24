# 《猫忍不住》v1.2.18 Input System

本版本将键鼠、手柄、可重绑定、UI 按键显示、暂停与兼容层统一到同一套 Input Action。

目标：Gameplay 永远读取 Action，不读取具体物理键；教程/UI 同样读取 Action 的当前绑定。

## 核心动作

- move_up / move_down / move_left / move_right
- sprint
- interact
- carry
- meow
- emote
- jump
- pause
- retry
- confirm / cancel

## 文件

- docs/v1_2_18_Input_System_Spec.md
- scripts/input/input_manager.gd
- scripts/input/rebind_manager.gd
- scripts/input/pause_controller.gd
- scripts/input/input_display.gd
- data/input/input_action_manifest.csv
- data/input/default_bindings.json
- scenes/ui/rebind_panel.tscn
- tools/audit_input.py
