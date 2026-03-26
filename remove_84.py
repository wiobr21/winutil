from pathlib import Path
path = Path('config/applications.json')
b = path.read_bytes()
if b.count(b'\x84'):
    b = b.replace(b'\x84', b'')
    path.write_bytes(b)
    print('removed 0x84, new length', len(b))
else:
    print('no 0x84 found')
