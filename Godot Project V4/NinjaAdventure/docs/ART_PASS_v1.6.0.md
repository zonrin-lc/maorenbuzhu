# 《猫忍不住》v1.6.0 实际美术资产替换与场景精修

本轮以 v1.5.8 猫叫补全工程为基线，进入实际美术层。

## 目标
- 保留现有 12 关的碰撞、事件点、固定 Ninja 路线和评分逻辑。
- 用工程内现有 Ninja Adventure 素材制作章节级正式背景。
- 隐藏白盒布局可视化，只保留真实碰撞。
- 用实际道具贴图强化关键事件与任务目标。

## 三章视觉主题
- CH01：村庄 / 草地 / 土路 / 房屋 / 树木；暖色、开放。
- CH02：夜间码头 / 木栈桥 / 水面 / 渔具 / 起重机；冷色、潮湿。
- CH03：城堡夜景 / 暗石板 / 城墙 / 雷雨氛围 / Boss 机关；高压。

## 资产来源
均来自当前工程已有资源：
- assets/tilesets/field.png
- assets/tilesets/floor.png
- assets/tilesets/nature.png
- assets/tilesets/house.png
- assets/tilesets/dungeon.png
- assets/tilesets/water_ripples.png
- assets/props/*.png

本轮没有加入外部商业素材，也没有修改事件逻辑以迁就美术。

## 场景结构
`UnifiedLevelManager._setup_floor()` 仅创建统一底色。
`UnifiedLevelManager._setup_decorations()` 创建 `SceneArt`：
- 章节背景 PNG
- 关卡关键道具
- 终点卷轴

`LayoutGeometry` 在运行时隐藏其白盒绘制，但其 StaticBody2D 碰撞保留。

## 验收
- 12 个关卡共用三章正式背景主题。
- 三张背景均为 1104×490，对应当前 1100×680 游戏画布内的主要 1100×490 区域。
- 关键道具使用真实工程 PNG，而非替代占位图。
- `tools/audit_art_pass_v16.py` 用于后续美术改版回归。
