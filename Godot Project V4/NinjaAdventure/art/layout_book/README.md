# 《猫忍不住》Level Design Bible

本目录保存自动生成的关卡设计图。

## 页面规格

- 1600 × 1000 PNG
- 中央地图：真实关卡 Scene 渲染
- 主线：真实 LevelData / RouteData 的 Ninja Route
- 备用线：设计标注，用于路线对照
- 猫捷径：设计标注，用于猫专属高机动路线
- 事件点：真实 EventPointData
- 机关物：来自当前 SceneArtBuilder 的正式场景道具
- 垂直分层：用于策划 / 美术 / 程序沟通的生产层约定
- 16 × 16 px：当前关卡白盒网格基准

## 输出

GitHub Actions 工作流 `Level Layout Book` 会在关卡场景、路线、事件或渲染器发生变化时重新生成 L01–L12。

生成文件：

`art/layout_book/rendered/L01_scene_layout.png` … `L12_scene_layout.png`

## 运行

在 `Godot Project V4/NinjaAdventure` 目录：

```text
godot --path . --scene res://tools/layout_book_renderer.tscn -- L05
```

CI 使用 `xvfb` + Noto CJK，保证中文标题和机制标签在无窗口环境下仍可读。

## 数据边界

本工具是文档渲染器。它不会写入或修改 LevelData、RouteData、EventPointData，也不会改变运行时碰撞、事件坐标或 Ninja 固定路线。
