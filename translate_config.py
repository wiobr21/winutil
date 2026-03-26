import json
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

SOURCE = Path('config/applications.json')
MAX_BATCH = 20


def is_chinese(text: str) -> bool:
    return any('\u4e00' <= ch <= '\u9fff' for ch in text)


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
            return ''.join(segment[0] for segment in segments if segment and segment[0])
        except urllib.error.URLError as exc:
            if attempt == 2:
                raise
            time.sleep(0.5)
    return text


data = json.load(SOURCE.open(encoding='utf-8'))
print(f'translating {len(data)} entries (batch limit {MAX_BATCH})...')
count = 0
batch_count = 0
for key, entry in data.items():
    desc = entry.get('description')
    if not desc or is_chinese(desc):
        continue
    try:
        entry['description'] = translate(desc)
        count += 1
        batch_count += 1
    except Exception as exc:
        print(f'failed {key}: {exc}')
        continue
    if count % 20 == 0:
        print(f'  translated {count} descriptions so far')
    if batch_count >= MAX_BATCH:
        print('batch limit reached, pausing for next run')
        break
    time.sleep(0.2)
print(f'finished this run with {count} translations')
SOURCE.write_text(json.dumps(data, ensure_ascii=False, indent=4), encoding='utf-8')
