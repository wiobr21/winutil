import re
from pathlib import Path
text = Path('xaml/inputXML.xaml').read_text(encoding='utf-8', errors='surrogateescape')
attrs = ['Content','Header','Text','ToolTip','Title']
pattern = re.compile(r'(?:' + '|'.join(attrs) + r')="([^"]+)"')
vals = set()
for m in pattern.finditer(text):
    v = m.group(1)
    if re.search(r'[A-Za-z]', v):
        vals.add(v)
inner = re.findall(r'<TextBlock[^>]*>([^<]+)</TextBlock>', text)
for v in inner:
    if re.search(r'[A-Za-z]', v):
        vals.add(v.strip())
print('\n'.join(sorted(vals)))
