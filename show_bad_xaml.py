from pathlib import Path
text = Path('xaml/inputXML.xaml').read_text(encoding='utf-8', errors='surrogateescape')
lines = text.splitlines()
for i in [955,1028,1058,1097,1113,1126,1173,1178,1184,1237,1240,1242,1263,1343,1501,1554,1582,1595,1601,1675]:
    if i-1 < len(lines):
        print(i, repr(lines[i-1]))
