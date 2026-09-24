# 《猫忍不住》v1.2.19 — Settings System

本包建立正式设置层，目标是把 Input / Audio / Accessibility / Display / Data Management 统一纳入设置页面，并与 Gameplay Meta Save 分离。

## 结构
- `scripts/settings/settings_manager.gd`：运行时设置管理与持久化
- `scripts/settings/settings_data.gd`：设置 Resource 类型
- `scenes/settings/settings_menu.tscn`：基础设置页面骨架
- `data/settings/settings_data.tres.template`：设计师/程序模板
- `tools/audit_settings.py`：静态结构审计
- `docs/v1_2_19_Settings_Spec.md`：实现规范

## 存储边界
- 设置：`user://settings.cfg`
- 游戏进度：`user://save.cfg`
- 设置恢复默认不会删除游戏进度。
- 清除游戏进度必须单独进入“数据管理”执行。

## Runtime 验证
当前环境没有 Godot 可执行程序，本包只进行静态结构审计，未宣称 Runtime Smoke Test 已通过。
