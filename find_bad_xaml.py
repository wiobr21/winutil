from pathlib import Path
text = Path('xaml/inputXML.xaml').read_text(encoding='utf-8', errors='surrogateescape')
lines = text.splitlines()
for i,l in enumerate(lines,1):
    if any(0xDC80 <= ord(ch) <= 0xDCFF for ch in l):
        print(i, l)
