# 《猫忍不住》v1.2.15 · Save / Progress / Meta Implementation Pack

本轮把 12 关白盒内容接到“完整游戏进度”层：章节解锁、Save/Load、猫皮肤、鱼干、猫技艺、Hard / Hard+ 解锁、Meta 页面数据源。

## 本轮边界

Gameplay 规则不新增核心操作；Meta 不改变猫的基础数值，不影响关卡公平。

## 运行入口

建议把 `scripts/save/save_manager.gd` 作为 Autoload：`SaveManager`。

`ProgressManager` 只消费/解释 SaveData，不直接写文件。

## 静态检查

执行：

```bash
python3 tools/validate_meta_pack.py
```

当前包不包含 Godot runtime；`ERRORS = 0` 仅表示文件、数据字段与解锁规则的静态一致性通过。
