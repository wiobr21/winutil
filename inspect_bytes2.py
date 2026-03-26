from pathlib import Path
b = Path('config/applications.json').read_bytes()
start = b.index(b'"description": "1Password')
print(b[start:start+60])
print([hex(x) for x in b[start:start+80]])
