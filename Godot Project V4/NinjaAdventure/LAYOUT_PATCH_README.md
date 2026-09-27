# 《猫忍不住》关卡布局更新

本补丁基于工程内《猫忍不住》v1.3 白盒布局规范，把 L01–L12 的路线锚点、事件落点和出生点重新对齐到设计图的空间顺序。

## 本次修改

- 更新 `data/routes/L01_Ninja_Main.tres` ~ `L12_Ninja_Main.tres` 的 NinjaRoute Waypoints。
- 更新现有 EventPoint 的 `route_index`，使事件落点对应设计图中的路线阶段。
- 统一每关 Cat 出生位置与 Route N00。
- 为第二、三章关卡修正 Dog 的白盒出生区域。
- 新增 `scripts/gameplay/layout_design.gd`，运行时以低对比度显示区域边界与 Ninja 主路线，位于角色/事件反馈之后。
- 不新增随机地图；路线仍为手工确定性数据。

## 注意

本环境没有 Godot 4 编辑器/运行时，因此没有在这里重新导出 `.pck` / `.app`，也没有声称做过 runtime smoke test。请用 Godot 4 打开 `Godot Project V4/NinjaAdventure/project.godot` 后运行 12 关，重点检查路线转角与事件交互半径。
