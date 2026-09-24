# 《猫忍不住》v1.2.13 · Level Production Template Pack

目标：把新增关卡的制作流程标准化为“复制模板 → 填数据 → 搭白盒 → 静态审计 → Runtime smoke test → Playtest”。

本包不新增核心操作，不改变 v1.2 已冻结的玩法规则。它解决的是后续内容量产效率与一致性。

## 目录

- `docs/v1_2_13_Level_Production_Template.md`：正式关卡制作模板与评审规范。
- `docs/v1_2_13_L01-L12_Production_Cards.md`：12 个现有关卡的量产卡片。
- `templates/LevelData.tres.template`
- `templates/EventPointData.tres.template`
- `templates/RouteData.tres.template`
- `templates/ShortcutData.tres.template`
- `templates/VariantData.tres.template`
- `data_templates/level_authoring_matrix.csv`
- `tools/validate_level_authoring.py`
