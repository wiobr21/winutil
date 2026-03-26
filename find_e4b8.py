from pathlib import Path
text = Path('config/applications.json').read_text(encoding='utf-8', errors='surrogateescape')
lines = text.splitlines()
for i,l in enumerate(lines,1):
    if '\udce4\udcb8?' in l:
        print(i, l.encode('unicode_escape'))
