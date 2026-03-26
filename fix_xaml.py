from pathlib import Path
import re
path = Path('xaml/inputXML.xaml')
text = path.read_text(encoding='utf-8', errors='surrogateescape')

# Fix corrupted text fragments
replacements = {
    '离线模式 - 无网络连\udce6\udc8e?': '离线模式 - 无网络连接',
    '\udce6\udc8c?Ctrl+F 并输入应用名称以过滤下方列表。按 Esc 重置筛\udce9\udc80?': '按 Ctrl+F 并输入应用名称以过滤下方列表。按 Esc 重置筛选',
    'Content="\udce6\udc97?': 'Content="&#xE713;"',
    '为辅助功能调整字体缩\udce6\udc94?': '为辅助功能调整字体缩放',
    '<TextBlock Text="\udce5\udcb0?': '<TextBlock Text="小"',
    '<TextBlock Text="\udce5\udca4?': '<TextBlock Text="大"',
    '配置\udce3\udc80?': '配置。',
    '剪贴板\udce3\udc80?': '剪贴板。',
    'Header="赞助\udce8\udc80?': 'Header="赞助者"',
    '推荐选项\udcef\udcbc?': '推荐选项：',
    'Content=" 最\udce5\udcb0?': 'Content=" 最小"',
    'Content=" 获取已安装调\udce6\udc95?': 'Content=" 获取已安装调整"',
    'Content="撤销所选调\udce6\udc95?': 'Content="撤销所选调整"',
    'Content="禁用所有更\udce6\udc96?': 'Content="禁用所有更新"',
    'install.wim \udce4\udcb8?boot.wim，推荐用\udce4\udcba?NVMe 或网络控制器不受支持的系统\udce3\udc80?': 'install.wim 与 boot.wim，推荐用于 NVMe 或网络控制器不受支持的系统。',
    '创建\udce5\udc99?': '创建器',
    '第 1 \udce6\udcad?': '第 1 步',
    '保存\udce4\udcb8?ISO 文件': '保存为 ISO 文件',
    '驱动器\udcef\udcbc?': '驱动器）',
    '请选择一\udce4\udcb8?Windows': '请选择一个 Windows',
    '准备就绪。请选择一\udce4\udcb8?Windows 11 ISO 开始\udce3\udc80?': '准备就绪。请选择一个 Windows 11 ISO 开始。',
}
for old, new in replacements.items():
    text = text.replace(old, new)

# Fix malformed attribute lines
text = re.sub(r'Text="&#x26A0;[^\n]*?Foreground="White"', 'Text="&#x26A0; 离线模式 - 无网络连接" Foreground="White"', text)
text = re.sub(r'ToolTip="[^\n]*Ctrl\+F[^\n]*', 'ToolTip="按 Ctrl+F 并输入应用名称以过滤下方列表。按 Esc 重置筛选"', text)

# Restore control Name attributes (must be ASCII for bindings)
name_fixes = {
    '自动ThemeMenuItem': 'AutoThemeMenuItem',
    '深色ThemeMenuItem': 'DarkThemeMenuItem',
    '浅色ThemeMenuItem': 'LightThemeMenuItem',
    'FontScaling重置Button': 'FontScalingResetButton',
    'FontScaling应用Button': 'FontScalingApplyButton',
    '导入MenuItem': 'ImportMenuItem',
    '导出MenuItem': 'ExportMenuItem',
    '关于MenuItem': 'AboutMenuItem',
    '文档MenuItem': 'DocumentationMenuItem',
    'WPFClear调整Selection': 'WPFClearTweaksSelection',
    'WPFGet安装ed调整': 'WPFGetInstalledTweaks',
    'WPF调整button': 'WPFtweaksbutton',
    'WPF更新default': 'WPFUpdatesdefault',
    'WPF更新security': 'WPFUpdatessecurity',
    'WPF更新disable': 'WPFUpdatesdisable',
    'WPFWin11ISO浏览Button': 'WPFWin11ISOBrowseButton',
    'WPFWin11ISOClean重置Button': 'WPFWin11ISOCleanResetButton',
    'WPFWin11ISO刷新USBButton': 'WPFWin11ISORefreshUSBButton',
}
for old, new in name_fixes.items():
    text = text.replace(f'Name="{old}"', f'Name="{new}"')

# English -> Chinese text
eng_map = {
    'Step 1 - Select Windows 11 ISO': '步骤 1 - 选择 Windows 11 ISO',
    'Step 2 - 挂载 &amp; 验证 ISO': '步骤 2 - 挂载 &amp; 验证 ISO',
    'Step 3 - Modify install.wim': '步骤 3 - 修改 install.wim',
    'Step 4 - Output: What would you like to do with the modified image?': '步骤 4 - 输出：你想如何处理修改后的镜像？',
    'Status Log': '状态日志',
    'Select Edition:': '选择版本：',
    '!!WARNING!! You must use an official Microsoft ISO': '!!警告!! 必须使用微软官方 ISO',
    'Download the Windows 11 ISO directly from Microsoft.com.': '请直接从 Microsoft.com 下载 Windows 11 ISO。',
    'Third-party, pre-modified, or unofficial images are not supported': '不支持第三方、预修改或非官方镜像',
    'and may produce broken results.': '可能导致生成结果不可用。',
    'On the Microsoft download page, choose:': '在微软下载页面请选择：',
    '- Edition  : Windows 11': '- 版本：Windows 11',
    '- Language : your preferred language': '- 语言：你偏好的语言',
    '- Architecture : 64-bit (x64)': '- 架构：64 位（x64）',
    'Mount the ISO and confirm it contains a valid Windows 11': '挂载 ISO 并确认其中包含有效的 Windows 11',
    'install.wim before any modifications are made.': 'install.wim，然后再进行任何修改。',
    'The ISO contents will be extracted to a temporary working directory,': 'ISO 内容将被解压到临时工作目录，',
    'install.wim will be modified (components removed, tweaks applied),': 'install.wim 将被修改（移除组件、应用调整），',
    'and the result will be repackaged. This process may take several minutes': '然后重新打包生成结果。此过程可能需要几分钟',
    'depending on your hardware.': '取决于你的硬件性能。',
    'Browse to your locally saved Windows 11 ISO file. Only official ISOs': '浏览并选择你本地保存的 Windows 11 ISO 文件。仅支持',
    'downloaded from Microsoft are supported.': '从微软下载的官方 ISO。',
    '!! All data on the selected USB drive will be permanently erased !!': '!! 选中的 USB 驱动器上的所有数据将被永久清除 !!',
    'Select a removable USB drive below, then click Erase &amp; Write.': '选择下面的可移动 USB 驱动器，然后点击“擦除并写入”。',
}
for old, new in eng_map.items():
    text = text.replace(old, new)

# Remove any remaining surrogate escapes and trailing ? after them
text = re.sub(r'[\udc80-\udcff]\?', '', text)
text = ''.join(ch for ch in text if not (0xDC80 <= ord(ch) <= 0xDCFF))

path.write_text(text, encoding='utf-8')
print('xaml fixed')
