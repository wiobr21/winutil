import re
from pathlib import Path
text = Path('xaml/inputXML.xaml').read_text(encoding='utf-8', errors='surrogateescape')
for m in re.finditer(r'Name="([^"]+)"', text):
    name = m.group(1)
    if any(ord(ch) > 127 for ch in name):
        print(name)
