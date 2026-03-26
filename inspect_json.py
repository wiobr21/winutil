from pathlib import Path
text = Path('config/applications.json').read_text(encoding='utf-8')
start = text.index('"1password"')
print(text[start:start+400])
