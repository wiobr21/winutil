import re
from pathlib import Path
text = Path('xaml/inputXML.xaml').read_text(encoding='utf-8')
attrs = ['Text','Content','Header','ToolTip','Title']
values = set()
for attr in attrs:
    for match in re.finditer(fr'{attr}="(.*?)"', text, re.S):
        val = match.group(1)
        if '{' in val or '}' in val or val.strip() == '' or val.strip().startswith('{Binding'):
            continue
        values.add(val)
print(len(values))
for val in sorted(values):
    print(val)
