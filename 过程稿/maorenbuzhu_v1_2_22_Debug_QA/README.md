# 《猫忍不住》v1.2.22 · Debug / QA Pack

这是开发与 QA 用的独立模板包。

本包不是完整游戏工程，而是可移植的 Debug / QA 层骨架。

## 快速接入

1. 将 `scripts/debug/` 与 `scripts/qa/` 合并到项目。
2. 将 `DebugConsole` / `QATestRunner` 作为 Debug Build 专用 Autoload。
3. 把 `DebugOverlay` 实例加入开发场景。
4. 将 `qa_contract.json` 与 `qa_matrix.csv` 放进项目的数据/测试目录。
5. 让正式 LevelManager / Event System 提供 Debug API。

## 重要

当前环境没有 Godot Runtime，因此本包只做文件、脚本语法级检查和 QA 合同检查；不能宣称实际启动测试通过。
