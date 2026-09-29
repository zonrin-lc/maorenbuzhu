"""Workflow YAML 静态校验（防止 GitHub Actions 再次 0-job 失败）。

背景：2026-09-29 连续 5 次 GitHub Actions run 以 `failure` + `jobs=[]` 收场，
根因是 godot-ci.yml 中某个 step 的 name 含未加引号的 `: `（形如
`name: Player-behavior regression (real input: move/interact, ...)`），
YAML 会把冒号+空格解析成嵌套 mapping，导致整个工作流在「解析期」被拒——
job 根本不会被创建，因此没有任何 step 日志，表现为 0 job failure。

本脚本用 PyYAML 解析 .github/workflows/*.yml，任何语法/结构问题立即失败。
建议接入 CI 的第一个 step，或作为 pre-commit / 本地门禁。
"""
from __future__ import annotations
import glob
import os
import sys

try:
    import yaml
except ImportError:
    print("PyYAML 未安装，跳过工作流校验（pip install pyyaml）")
    raise SystemExit(0)

WF_DIR = r"D:\MUSI\renzhe\MAORENBUZHU\.github\workflows"
errors: list[str] = []
checked = 0

for p in sorted(glob.glob(os.path.join(WF_DIR, "*.yml")) +
                glob.glob(os.path.join(WF_DIR, "*.yaml"))):
    name = os.path.basename(p)
    raw = open(p, "rb").read()
    if raw[:3] == b"\xef\xbb\xbf":
        errors.append(f"{name}: 含 UTF-8 BOM")
    try:
        txt = raw.decode("utf-8")
    except UnicodeDecodeError as e:
        errors.append(f"{name}: 非 UTF-8 编码 ({e})")
        continue
    if b"\t" in raw:
        errors.append(f"{name}: 含 TAB 缩进（YAML 禁止）")
    try:
        doc = yaml.safe_load(txt)
    except yaml.YAMLError as e:
        mark = getattr(e, "problem_mark", None)
        line = mark.line + 1 if mark else "?"
        errors.append(f"{name}: YAML 解析失败 (line {line}): {getattr(e, 'problem', e)}")
        continue

    if not isinstance(doc, dict):
        errors.append(f"{name}: 顶层不是 mapping")
        continue
    # PyYAML(YAML1.1) 把裸 on 解析成布尔 True；GitHub 按字符串 'on' 处理，二者等价
    triggers = doc.get("on", doc.get(True))
    if triggers is None:
        errors.append(f"{name}: 缺少触发器 on:")
    jobs = doc.get("jobs")
    if not isinstance(jobs, dict) or not jobs:
        errors.append(f"{name}: 缺少 jobs 或 jobs 为空")
        continue
    for jn, jb in jobs.items():
        if not isinstance(jb, dict):
            errors.append(f"{name}: job '{jn}' 结构非法")
            continue
        if "runs-on" not in jb:
            errors.append(f"{name}: job '{jn}' 缺少 runs-on")
        steps = jb.get("steps")
        if not isinstance(steps, list) or not steps:
            errors.append(f"{name}: job '{jn}' 缺少 steps")
            continue
        for i, s in enumerate(steps):
            if not isinstance(s, dict):
                errors.append(f"{name}: job '{jn}' step[{i}] 非 mapping")
            elif "uses" not in s and "run" not in s:
                errors.append(f"{name}: job '{jn}' step[{i}] 既无 uses 也无 run")
    checked += 1

print(f"WORKFLOWS_CHECKED={checked}")
print(f"ERRORS={len(errors)}")
for e in errors:
    print(e)
sys.exit(1 if errors else 0)
