from pathlib import Path
b = Path('config/applications.json').read_bytes()
start = b.index(b'"description": "1Password')
print(b[start:start+200])
print([hex(x) for x in b[start+80:start+110]])
