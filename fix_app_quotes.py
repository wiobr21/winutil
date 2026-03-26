from pathlib import Path
path = Path('config/applications.json')
lines = path.read_text(encoding='utf-8', errors='surrogateescape').splitlines()
fixed = []
for line in lines:
    quote_count = line.count('"')
    if quote_count % 2 == 1 and '"' in line:
        stripped = line.rstrip()
        if stripped.endswith(','):
            stripped = stripped[:-1] + '",'
        else:
            stripped = stripped + '"'
        line = stripped
    fixed.append(line)
path.write_text('\n'.join(fixed) + '\n', encoding='utf-8')
print('applications.json quote fix done')
