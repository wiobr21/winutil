from pathlib import Path
import json
import re

config_dir = Path('config')
files = sorted(p for p in config_dir.glob('*.json'))

for path in files:
    text = path.read_text(encoding='utf-8', errors='surrogateescape')
    # common punctuation fixes
    text = text.replace('\udce3\udc80?', '¡£')
    text = text.replace('\udce2\udc80?', '')
    # remove surrogate bytes and the trailing ? marker
    text = re.sub(r'[\udc80-\udcff]\?', '', text)
    text = ''.join(ch for ch in text if not (0xDC80 <= ord(ch) <= 0xDCFF))
    path.write_text(text, encoding='utf-8')

# validate json
failed = []
for path in files:
    try:
        json.loads(path.read_text(encoding='utf-8'))
    except Exception as exc:
        failed.append((path.name, str(exc)))

if failed:
    print('JSON parse failures:')
    for name, err in failed:
        print(name, err)
else:
    print('all config json valid')
