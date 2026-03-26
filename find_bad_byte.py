from pathlib import Path
b = Path('config/applications.json').read_bytes()
try:
    b.decode('utf-8')
except UnicodeDecodeError as e:
    print('pos', e.start, b[e.start-5:e.start+5])
