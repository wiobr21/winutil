from pathlib import Path
text = Path('xaml/inputXML.xaml').read_text(encoding='utf-8', errors='surrogateescape')
lines = text.splitlines()
for i in range(1092,1102):
    print(i+1, lines[i])
