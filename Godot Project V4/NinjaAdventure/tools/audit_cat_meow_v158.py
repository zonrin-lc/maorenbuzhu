from pathlib import Path
import wave
ROOT = Path(__file__).resolve().parents[1]
files = [ROOT/'audio/sfx/cat_meow_short.wav', ROOT/'audio/sfx/cat_meow_bright.wav', ROOT/'audio/sfx/cat_meow_low.wav']
for f in files:
    assert f.exists(), f"missing: {f}"
    with wave.open(str(f), 'rb') as wf:
        assert wf.getnchannels() == 1
        assert wf.getframerate() == 44100
        assert wf.getsampwidth() == 2
        assert wf.getnframes() > 1000
manifest = (ROOT/'tools/audio_manifest.csv').read_text(encoding='utf-8')
assert 'SFX_MEOW,Action,SFX,audio/sfx/cat_meow_short.wav;audio/sfx/cat_meow_bright.wav;audio/sfx/cat_meow_low.wav,Yes,Ready-Original-Generated' in manifest
manager = (ROOT/'scripts/audio/global_audio_manager.gd').read_text(encoding='utf-8')
assert 'CAT_MEOW_VARIANTS' in manager and 'func play_cat_meow()' in manager and 'SFX_MEOW 素材缺失' not in manager
level = (ROOT/'scripts/gameplay/unified_level_manager.gd').read_text(encoding='utf-8')
assert 'GlobalAudioManager.play_cat_meow()' in level
print('CAT_MEOW_AUDIT PASS: 3 dedicated original cat-meow variants wired to F')
