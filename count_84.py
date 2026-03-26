from pathlib import Path
b = Path('config/applications.json').read_bytes()
print('count 0x84', b.count(b'\x84'))
