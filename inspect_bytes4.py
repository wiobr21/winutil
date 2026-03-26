from pathlib import Path
b = Path('config/applications.json').read_bytes()
start = b.index(b'"description": "1Password')
print([hex(x) for x in b[start+70:start+120]])
print([hex(x) for x in b[start+120:start+160]])
