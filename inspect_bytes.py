from pathlib import Path
data = Path('config/applications.json').read_bytes()
print(data[220:260])
print(list(data[220:260]))
