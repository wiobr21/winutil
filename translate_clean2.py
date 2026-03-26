import json
import time
import unicodedata
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

SOURCE = Path('config/applications.json')
MAX_PER_RUN = 40


def has_chinese(text: str) -> bool:
    return any('\u4e00' <= ch <= '\u9fff' for ch in text)


def clean(text: str) -> str:
    return ''.join(ch for ch in text if unicodedata.category(ch)[0] != 'C')


def translate(text: str) -> str:
    if not text:
        return text
    query = urllib.parse.quote(text)
    url = f'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=zh-CN&dt=t&q={query}'
    for attempt in range(3):
        try:
            with urllib.request.urlopen(url, timeout=20) as response:
                data = json.load(response)
            segments = data[0]
            result = ''.join(segment[0] for segment in segments if segment and segment[0])
            return clean(result)
        except urllib.error.URLError as exc:
            if attempt == 2:
                raise
            time.sleep(0.5)
    return text


data = json.load(SOURCE.open(encoding='utf-8'))
remaining = [k for k, v in data.items() if v.get('description') and not has_chinese(v['description'])]
print(f'translating up to {MAX_PER_RUN} of {len(remaining)} remaining entries...')
count = 0
failed = []
for key in remaining:
    if count >= MAX_PER_RUN:
        break
    desc = data[key]['description']
    try:
        data[key]['description'] = translate(desc)
        count += 1
    except Exception as exc:
        failed.append((key, str(exc)))
        print(f'failed {key}: {exc}')
        time.sleep(1)
        continue
    if count % 20 == 0:
        print(f'  translated {count} so far')
    time.sleep(0.25)
print(f'finished this run translating {count} entries, {len(failed)} failed')
SOURCE.write_text(json.dumps(data, ensure_ascii=False, indent=4), encoding='utf-8')
if failed:
    Path('config/translation_failed.txt').write_text('\n'.join(f"{k}: {e}" for k, e in failed), encoding='utf-8')
