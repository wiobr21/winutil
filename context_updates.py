from pathlib import Path
text=Path('xaml/inputXML.xaml').read_text(encoding='utf-8', errors='surrogateescape')
lines=text.splitlines()
for i in range(1288,1350):
    if 'WPF' in lines[i]:
        print(i+1, lines[i])
