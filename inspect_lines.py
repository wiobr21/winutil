from pathlib import Path
text = Path('config/applications.json').read_text(encoding='utf-8')
print(text.split('\n')[0:10])
