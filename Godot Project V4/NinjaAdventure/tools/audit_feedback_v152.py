from pathlib import Path
import re, sys

ROOT = Path(__file__).resolve().parents[1]
errors = []
checks = []

def must(pattern: str, path: str, label: str):
    text = (ROOT / path).read_text(encoding="utf-8")
    ok = re.search(pattern, text, re.S) is not None
    checks.append((label, ok))
    if not ok:
        errors.append(f"{label}: missing pattern")

must(r'class_name FeedbackDirector', 'scripts/feedback/feedback_director.gd', 'FeedbackDirector class')
must(r'func show_event_resolved', 'scripts/feedback/feedback_director.gd', 'event success feedback')
must(r'func show_event_failed', 'scripts/feedback/feedback_director.gd', 'event fail feedback')
must(r'func show_ninja_damage', 'scripts/feedback/feedback_director.gd', 'ninja damage feedback')
must(r'func show_route_change', 'scripts/feedback/feedback_director.gd', 'route change feedback')
must(r'func show_boss_phase', 'scripts/feedback/feedback_director.gd', 'boss phase feedback')
must(r'feedback_director = FeedbackDirector\.new\(\)', 'scripts/gameplay/unified_level_manager.gd', 'feedback director hookup')
must(r'feedback_director\.show_event_resolved', 'scripts/gameplay/unified_level_manager.gd', 'event success hookup')
must(r'feedback_director\.show_event_failed', 'scripts/gameplay/unified_level_manager.gd', 'event fail hookup')
must(r'feedback_director\.show_ninja_damage', 'scripts/gameplay/unified_level_manager.gd', 'ninja damage hookup')
must(r'feedback_director\.show_route_change', 'scripts/gameplay/unified_level_manager.gd', 'route change hookup')
must(r'GlobalAudioManager\.play_event_sfx\("success"\)', 'scripts/ui/result_panel.gd', 'result audio feedback')

print('FEEDBACK AUDIT v1.5.2')
for label, ok in checks:
    print(f"{'PASS' if ok else 'FAIL'}  {label}")
print(f"Errors: {len(errors)}")
if errors:
    for e in errors:
        print(e)
    sys.exit(1)
