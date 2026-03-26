from pathlib import Path
path = Path('config/applications.json')
lines = path.read_text(encoding='utf-8').splitlines()
fixed = []
for line in lines:
    if '"description": "' in line:
        stripped = line.rstrip()
        if not stripped.endswith('",') and not stripped.endswith('"'):
            if stripped.endswith(','):
                stripped = stripped[:-1] + '",'
            else:
                stripped = stripped + '"'
            line = stripped
    fixed.append(line)
path.write_text('\n'.join(fixed) + '\n', encoding='utf-8')
print('description quotes fixed')
