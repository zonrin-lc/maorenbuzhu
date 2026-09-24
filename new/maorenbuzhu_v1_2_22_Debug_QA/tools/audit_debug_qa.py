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

contract=json.loads((ROOT/'data/qa/qa_contract.json').read_text())
if contract['level_count'] != 12: errors.append('level_count')
if contract['expected_event_count'] != 46: errors.append('expected_event_count')
if len(contract['fail_codes']) != 7: errors.append('fail_codes')

matrix=list(csv.DictReader((ROOT/'data/qa/qa_matrix.csv').open()))
if len(matrix) < 20: errors.append('qa_matrix_too_small')
for row in matrix:
    for k in ('Suite','Case','Action','Expected','Priority'):
        if not row.get(k): errors.append(f'blank:{row.get("Case","")}:{k}')

console=(ROOT/'scripts/debug/debug_console.gd').read_text()
for cmd in ['help','level','win','fail','hp','suspicion','world','boss','event','validate','pause_sim','resume_sim','reset']:
    if f'"{cmd}"' not in console: errors.append(f'command_missing:{cmd}')

spec=(ROOT/'docs/v1_2_22_Debug_QA_Spec.md').read_text()
for token in ['12','46','Emergency Rescue','DebugConsole','QATestRunner','FAIL_TOO_LATE','FAIL_BOSS_FINISHER']:
    if token not in spec: errors.append(f'spec_missing:{token}')

print(f'REQUIRED_FILES={len(required)}')
print(f'QA_CASES={len(matrix)}')
print(f'LEVELS={contract["level_count"]}')
print(f'EXPECTED_EVENTS={contract["expected_event_count"]}')
print(f'ERRORS={len(errors)}')
for e in errors: print(e)
sys.exit(1 if errors else 0)
