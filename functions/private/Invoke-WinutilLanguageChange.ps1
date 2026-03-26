function Invoke-WinutilLanguageChange {
    param(
        [Parameter(Mandatory)]
        [ValidateSet("zh-CN", "en-US")]
        [string]$language
    )

    $sync.preferences.language = $language
    Set-Preferences -save

    $strings = @{
        "zh-CN" = @{
            Menu = @{
                Import = "导入"
                Export = "导出"
                About = "关于"
                Documentation = "文档"
                Sponsor = "赞助"
                Language = "语言"
                LanguageZH = "简体中文（默认）"
                LanguageEN = "English"
            }
            Tabs = @{
                WPFTab1BT = "安装"
                WPFTab2BT = "调整"
                WPFTab3BT = "配置"
                WPFTab4BT = "更新"
                WPFTab5BT = "Win11 创建器"
                WPFTab1 = "安装"
                WPFTab2 = "调整"
                WPFTab3 = "配置"
                WPFTab4 = "更新"
                WPFTab5 = "Win11 创建器"
            }
            Categories = @{
                "____Actions" = "操作"
                "__Package Manager" = "包管理器"
                "__Selection" = "选择"
            }
            AppNav = @{
                WPFInstall = "安装/升级应用"
                WPFUninstall = "卸载应用"
                WPFInstallUpgrade = "升级所有应用"
                WPFCollapseAllCategories = "折叠全部分类"
                WPFExpandAllCategories = "展开全部分类"
                WPFClearInstallSelection = "清除选择"
                WPFGetInstalled = "显示已安装应用"
                WPFselectedAppsButton = "已选应用：{0}"
                WPFToggleFOSSHighlight = "高亮 FOSS"
            }
            Tooltips = @{
                WPFInstall = "安装或升级所选应用"
                WPFUninstall = "卸载所选应用"
                WPFInstallUpgrade = "升级全部应用至最新版本"
                WPFCollapseAllCategories = "折叠所有应用分类"
                WPFExpandAllCategories = "展开所有应用分类"
                WPFClearInstallSelection = "清除已选择的应用"
                WPFGetInstalled = "显示已安装的应用"
                WPFselectedAppsButton = "查看当前已选择的应用"
                WPFToggleFOSSHighlight = "切换开源软件高亮显示"
            }
            Search = @{
                ToolTip = "按 Ctrl+F 并输入应用名称以过滤下方列表。按 Esc 重置筛选"
            }
        }
        "en-US" = @{
            Menu = @{
                Import = "Import"
                Export = "Export"
                About = "About"
                Documentation = "Documentation"
                Sponsor = "Sponsors"
                Language = "Language"
                LanguageZH = "简体中文 (Default)"
                LanguageEN = "English"
            }
            Tabs = @{
                WPFTab1BT = "Install"
                WPFTab2BT = "Tweaks"
                WPFTab3BT = "Config"
                WPFTab4BT = "Updates"
                WPFTab5BT = "Win11 Creator"
                WPFTab1 = "Install"
                WPFTab2 = "Tweaks"
                WPFTab3 = "Config"
                WPFTab4 = "Updates"
                WPFTab5 = "Win11 Creator"
            }
            Categories = @{
                "____Actions" = "Actions"
                "__Package Manager" = "Package Manager"
                "__Selection" = "Selection"
            }
            AppNav = @{
                WPFInstall = "Install/Upgrade Applications"
                WPFUninstall = "Uninstall Applications"
                WPFInstallUpgrade = "Upgrade all Applications"
                WPFCollapseAllCategories = "Collapse All Categories"
                WPFExpandAllCategories = "Expand All Categories"
                WPFClearInstallSelection = "Clear Selection"
                WPFGetInstalled = "Show Installed Apps"
                WPFselectedAppsButton = "Selected Apps: {0}"
                WPFToggleFOSSHighlight = "Highlight FOSS"
            }
            Tooltips = @{
                WPFInstall = "Install or upgrade the selected applications"
                WPFUninstall = "Uninstall the selected applications"
                WPFInstallUpgrade = "Upgrade all applications to the latest version"
                WPFCollapseAllCategories = "Collapse all application categories"
                WPFExpandAllCategories = "Expand all application categories"
                WPFClearInstallSelection = "Clear the selection of applications"
                WPFGetInstalled = "Show installed applications"
                WPFselectedAppsButton = "Show the selected applications"
                WPFToggleFOSSHighlight = "Toggle the green highlight for FOSS applications"
            }
            Search = @{
                ToolTip = "Press Ctrl+F and type an app name to filter. Press Esc to reset."
            }
        }
    }

    $lang = $strings[$language]
    if (-not $lang) { return }

    function Set-UiProp {
        param(
            [string]$Name,
            [string]$Property,
            [string]$Value
        )
        if ($sync.ContainsKey($Name) -and $null -ne $sync[$Name]) {
            try {
                $sync[$Name].$Property = $Value
            } catch {
                # ignore
            }
        }
    }

    # Menu items
    Set-UiProp "ImportMenuItem" "Header" $lang.Menu.Import
    Set-UiProp "ExportMenuItem" "Header" $lang.Menu.Export
    Set-UiProp "AboutMenuItem" "Header" $lang.Menu.About
    Set-UiProp "DocumentationMenuItem" "Header" $lang.Menu.Documentation
    Set-UiProp "SponsorMenuItem" "Header" $lang.Menu.Sponsor
    Set-UiProp "LanguageMenuItem" "Header" $lang.Menu.Language
    Set-UiProp "LanguageZHMenuItem" "Header" $lang.Menu.LanguageZH
    Set-UiProp "LanguageENMenuItem" "Header" $lang.Menu.LanguageEN

    if ($sync.ContainsKey("LanguageZHMenuItem")) { $sync["LanguageZHMenuItem"].IsChecked = ($language -eq "zh-CN") }
    if ($sync.ContainsKey("LanguageENMenuItem")) { $sync["LanguageENMenuItem"].IsChecked = ($language -eq "en-US") }

    # Tabs
    foreach ($k in $lang.Tabs.Keys) {
        if ($k -like "WPFTab*BT") {
            Set-UiProp $k "Content" $lang.Tabs[$k]
        } else {
            Set-UiProp $k "Header" $lang.Tabs[$k]
        }
    }

    # Categories (labels stored by category key)
    foreach ($k in $lang.Categories.Keys) {
        Set-UiProp $k "Content" $lang.Categories[$k]
    }

    # App navigation buttons/toggles
    foreach ($k in $lang.AppNav.Keys) {
        $value = $lang.AppNav[$k]
        if ($k -eq "WPFselectedAppsButton") {
            $count = if ($sync.selectedApps) { $sync.selectedApps.Count } else { 0 }
            $value = [string]::Format($value, $count)
        }
        Set-UiProp $k "Content" $value
        if ($lang.Tooltips.ContainsKey($k)) {
            Set-UiProp $k "ToolTip" $lang.Tooltips[$k]
        }
    }

    # Search bar tooltip
    Set-UiProp "SearchBar" "ToolTip" $lang.Search.ToolTip
}
