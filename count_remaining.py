import json
from pathlib import Path

def has_chinese(text: str) -> bool:
    return any('\u4e00' <= ch <= '\u9fff' for ch in text)

data = json.load(Path('config/applications.json').open(encoding='utf-8'))
remaining = [k for k, v in data.items() if v.get('description') and not has_chinese(v['description'])]
print('remaining english', len(remaining))
