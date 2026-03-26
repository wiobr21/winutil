import json
import time
from pathlib import Path
from googletrans import Translator

SOURCE = Path('config/applications.json')
translator = Translator()
MAX_PER_RUN = 40

def has_chinese(text: str) -> bool:
    return any('\u4e00' <= ch <= '\u9fff' for ch in text)

data = json.load(SOURCE.open(encoding='utf-8'))
remaining = [k for k, v in data.items() if v.get('description') and not has_chinese(v['description'])]
total = len(data)
print(f'translating up to {MAX_PER_RUN} of {len(remaining)} remaining entries (total {total})...')
count = 0
failed = []
for key in remaining:
    if count >= MAX_PER_RUN:
        break
    entry = data[key]
    desc = entry['description']
    try:
        translation = translator.translate(desc, dest='zh-cn').text
    except Exception as exc:
        failed.append((key, str(exc)))
        print(f'failed {key}: {exc}')
        time.sleep(1)
        continue
    entry['description'] = translation
    count += 1
    if count % 20 == 0:
        print(f'  translated {count} so far')
    time.sleep(0.25)
print(f'finished this run translating {count} entries, {len(failed)} failed')
SOURCE.write_text(json.dumps(data, ensure_ascii=False, indent=4), encoding='utf-8')
if failed:
    Path('config/translation_failed.txt').write_text('\n'.join(f"{k}: {e}" for k, e in failed), encoding='utf-8')
