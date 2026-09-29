from pathlib import Path
import csv, json, re, sys

ROOT = Path(__file__).resolve().parents[1]
errors=[]
required=[
    ROOT/'scripts/debug/debug_console.gd',
    ROOT/'scripts/debug/debug_overlay.gd',
    ROOT/'scripts/qa/qa_test_runner.gd',
    ROOT/'scenes/debug/debug_console_demo.tscn',
    ROOT/'data/qa/qa_contract.json',
    ROOT/'data/qa/qa_matrix.csv',
    ROOT/'docs/v1_2_22_Debug_QA_Spec.md',
]
for p in required:
    if not p.exists(): errors.append(f'missing:{p.relative_to(ROOT)}')

# 唯一事实源：data/events/*.tres 实际文件数
actual_event_count = len(list((ROOT/'data/events').glob('*.tres')))

contract=json.loads((ROOT/'data/qa/qa_contract.json').read_text(encoding='utf-8'))
if contract['level_count'] != 12: errors.append('level_count')
# 一致性检查：合同声明的事件数必须等于实际文件数，漂移直接报红
if contract['expected_event_count'] != actual_event_count:
    errors.append(f'expected_event_count_drift:contract={contract["expected_event_count"]}:actual={actual_event_count}')
if len(contract['fail_codes']) != 7: errors.append('fail_codes')

matrix=list(csv.DictReader((ROOT/'data/qa/qa_matrix.csv').open(encoding='utf-8')))
if len(matrix) < 20: errors.append('qa_matrix_too_small')
for row in matrix:
    for k in ('Suite','Case','Action','Expected','Priority'):
        if not row.get(k): errors.append(f'blank:{row.get("Case","")}:{k}')
# 矩阵里的 EVT_001 期望计数也必须与实际文件数一致
evt_rows=[r for r in matrix if r.get('Case')=='EVT_001']
if not evt_rows: errors.append('matrix_missing:EVT_001')
elif str(actual_event_count) not in evt_rows[0].get('Expected',''):
    errors.append(f'matrix_evt_001_drift:{evt_rows[0].get("Expected","")}:actual={actual_event_count}')

console=(ROOT/'scripts/debug/debug_console.gd').read_text(encoding='utf-8')
for cmd in ['help','level','win','fail','hp','suspicion','world','boss','event','validate','pause_sim','resume_sim','reset']:
    if f'"{cmd}"' not in console: errors.append(f'command_missing:{cmd}')

spec=(ROOT/'docs/v1_2_22_Debug_QA_Spec.md').read_text(encoding='utf-8')
for token in ['12',str(actual_event_count),'Emergency Rescue','DebugConsole','QATestRunner','FAIL_TOO_LATE','FAIL_BOSS_FINISHER']:
    if token not in spec: errors.append(f'spec_missing:{token}')

print(f'REQUIRED_FILES={len(required)}')
print(f'QA_CASES={len(matrix)}')
print(f'LEVELS={contract["level_count"]}')
print(f'EXPECTED_EVENTS={contract["expected_event_count"]}')
print(f'ACTUAL_EVENTS={actual_event_count}')
print(f'ERRORS={len(errors)}')
for e in errors: print(e)
sys.exit(1 if errors else 0)
