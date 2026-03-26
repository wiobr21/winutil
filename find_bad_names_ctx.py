from pathlib import Path
text = Path('xaml/inputXML.xaml').read_text(encoding='utf-8', errors='surrogateescape')
lines = text.splitlines()
for target in [
    '自动ThemeMenuItem','深色ThemeMenuItem','浅色ThemeMenuItem',
    'FontScaling重置Button','FontScaling应用Button','导入MenuItem','导出MenuItem',
    '关于MenuItem','文档MenuItem','WPFClear调整Selection','WPFGet安装ed调整',
    'WPF调整button','WPF更新default','WPF更新security','WPF更新disable',
    'WPFWin11ISO浏览Button','WPFWin11ISOClean重置Button','WPFWin11ISO刷新USBButton'
]:
    for i,l in enumerate(lines,1):
        if target in l:
            print(i, l)
            break
