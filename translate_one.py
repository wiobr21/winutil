import json
import urllib.request
import urllib.parse
from pathlib import Path

path = Path('config/applications.json')
data = json.load(path.open(encoding='utf-8'))
key = '1password'
t = data[key]['description']
print('before:', t)
query = urllib.parse.quote(t)
url = f'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=zh-CN&dt=t&q={query}'
segments = json.load(urllib.request.urlopen(url))[0]
result = ''.join(seg[0] for seg in segments if seg and seg[0])
print('translated:', result)
print('bytes', result.encode('utf-8'))
print('hex tail', [hex(ord(ch)) for ch in result[-5:]])
data[key]['description'] = result
path.write_text(json.dumps(data, ensure_ascii=False, indent=4), encoding='utf-8')
print('file bytes at tail', Path('config/applications.json').read_bytes()[200:250])
