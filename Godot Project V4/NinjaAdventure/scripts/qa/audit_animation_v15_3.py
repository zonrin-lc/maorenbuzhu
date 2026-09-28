from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
errors=[]

def req(path, text):
    p=ROOT/path
    if not p.exists():
        errors.append(f"missing {path}"); return
    s=p.read_text()
    if text not in s:
        errors.append(f"{path}: missing {text}")

req(Path('scripts/actors/animation_feedback_driver.gd'), 'class_name AnimationFeedbackDriver')
req(Path('scripts/actors/animation_feedback_driver.gd'), 'base_position')
req(Path('scripts/actors/animation_feedback_driver.gd'), 'State.DEATH')
text_driver = (ROOT/'scripts/actors/animation_feedback_driver.gd').read_text()
if '_flash_hit()' in text_driver:
    errors.append('stale _flash_hit() call remains')
for f in ['cat_controller.gd','ninja_controller.gd','guard_controller.gd','dog_controller.gd','boss_controller.gd']:
    req(Path('scripts/actors')/f, 'AnimationFeedbackDriver')

text=(ROOT/'scripts/actors/animation_feedback_driver.gd').read_text()
expected=['State.IDLE','State.MOVE','State.CARRY','State.ALERT','State.EMOTE','State.ACTION','State.HIT','State.VICTORY','State.DEATH']
for item in expected:
    if text.count(item) < 2:
        errors.append(f'driver coverage low for {item}')

print('ANIMATION_AUDIT_V1.5.3')
print('errors=', len(errors))
for e in errors: print('ERROR', e)
raise SystemExit(1 if errors else 0)
