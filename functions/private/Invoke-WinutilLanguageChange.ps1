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
            Tweaks = @{
                Recommended = "推荐选项："
                Standard = "标准"
                Minimal = "最小"
                Clear = "清除"
                GetInstalled = "获取已安装调整"
                Run = "运行调整"
                Undo = "撤销所选调整"
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
            Tweaks = @{
                Recommended = "Recommended Selections:"
                Standard = "Standard"
                Minimal = "Minimal"
                Clear = "Clear"
                GetInstalled = "Get Installed Tweaks"
                Run = "Run Tweaks"
                Undo = "Undo Selected Tweaks"
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

    # Tweaks tab quick buttons
    Set-UiProp "WPFstandard" "Content" (" " + $lang.Tweaks.Standard + " ")
    Set-UiProp "WPFminimal" "Content" (" " + $lang.Tweaks.Minimal + " ")
    Set-UiProp "WPFClearTweaksSelection" "Content" (" " + $lang.Tweaks.Clear + " ")
    Set-UiProp "WPFGetInstalledTweaks" "Content" (" " + $lang.Tweaks.GetInstalled + " ")
    Set-UiProp "WPFTweaksbutton" "Content" $lang.Tweaks.Run
    Set-UiProp "WPFUndoall" "Content" $lang.Tweaks.Undo

    # Update category labels using available configs for chosen language
    $tweaksConfig = if ($language -eq "en-US" -and $sync.configs.'tweaks.en') { $sync.configs.'tweaks.en' } else { $sync.configs.tweaks }
    $featureConfig = if ($language -eq "en-US" -and $sync.configs.'feature.en') { $sync.configs.'feature.en' } else { $sync.configs.feature }
    $appnavConfig = if ($language -eq "en-US" -and $sync.configs.'appnavigation.en') { $sync.configs.'appnavigation.en' } else { $sync.configs.appnavigation }

    $tweaksCategoryMapEnToZh = @{
        'Essential Tweaks' = '基础调整'
        'Advanced Tweaks - CAUTION' = '高级调整 - 注意'
        'Security Tweaks' = '安全调整'
        'Undo Tweaks' = '撤销调整'
        'Dev Tweaks' = '开发者调整'
        'Privacy Tweaks' = '隐私调整'
        'Updates Tweaks' = '更新调整'
    }
    $tweaksCategoryMapZhToEn = @{}
    foreach ($k in $tweaksCategoryMapEnToZh.Keys) { $tweaksCategoryMapZhToEn[$tweaksCategoryMapEnToZh[$k]] = $k }

    $featureCategoryMapEnToZh = @{
        'Features' = '系统功能'
        'Advanced Features' = '高级功能'
    }
    $featureCategoryMapZhToEn = @{}
    foreach ($k in $featureCategoryMapEnToZh.Keys) { $featureCategoryMapZhToEn[$featureCategoryMapEnToZh[$k]] = $k }

    $appnavCategoryMapEnToZh = @{
        '____Actions' = '操作'
        '__Package Manager' = '包管理器'
        '__Selection' = '选择'
    }
    $appnavCategoryMapZhToEn = @{}
    foreach ($k in $appnavCategoryMapEnToZh.Keys) { $appnavCategoryMapZhToEn[$appnavCategoryMapEnToZh[$k]] = $k }

    foreach ($entry in $tweaksConfig.PSObject.Properties) {
        $item = $entry.Value
        if ($sync.ContainsKey($entry.Name)) {
            Set-UiProp $entry.Name "Content" $item.Content
            Set-UiProp $entry.Name "ToolTip" $item.Description
        }
        if ($item.category) {
            if ($sync.ContainsKey($item.category)) {
                Set-UiProp $item.category "Content" ($item.category -replace ".*__", "")
            } elseif ($tweaksCategoryMapEnToZh.ContainsKey($item.category) -and $sync.ContainsKey($tweaksCategoryMapEnToZh[$item.category])) {
                Set-UiProp $tweaksCategoryMapEnToZh[$item.category] "Content" $item.category
            } elseif ($tweaksCategoryMapZhToEn.ContainsKey($item.category) -and $sync.ContainsKey($tweaksCategoryMapZhToEn[$item.category])) {
                Set-UiProp $tweaksCategoryMapZhToEn[$item.category] "Content" $item.category
            }
        }
    }

    foreach ($entry in $featureConfig.PSObject.Properties) {
        $item = $entry.Value
        if ($sync.ContainsKey($entry.Name)) {
            Set-UiProp $entry.Name "Content" $item.Content
            Set-UiProp $entry.Name "ToolTip" $item.Description
        }
        if ($item.category) {
            if ($sync.ContainsKey($item.category)) {
                Set-UiProp $item.category "Content" ($item.category -replace ".*__", "")
            } elseif ($featureCategoryMapEnToZh.ContainsKey($item.category) -and $sync.ContainsKey($featureCategoryMapEnToZh[$item.category])) {
                Set-UiProp $featureCategoryMapEnToZh[$item.category] "Content" $item.category
            } elseif ($featureCategoryMapZhToEn.ContainsKey($item.category) -and $sync.ContainsKey($featureCategoryMapZhToEn[$item.category])) {
                Set-UiProp $featureCategoryMapZhToEn[$item.category] "Content" $item.category
            }
        }
    }

    foreach ($entry in $appnavConfig.PSObject.Properties) {
        $item = $entry.Value
        if ($sync.ContainsKey($entry.Name)) {
            Set-UiProp $entry.Name "Content" $item.Content
            Set-UiProp $entry.Name "ToolTip" $item.Description
        }
        if ($item.Category) {
            if ($sync.ContainsKey($item.Category)) {
                Set-UiProp $item.Category "Content" ($item.Category -replace ".*__", "")
            } elseif ($appnavCategoryMapEnToZh.ContainsKey($item.Category) -and $sync.ContainsKey($appnavCategoryMapEnToZh[$item.Category])) {
                Set-UiProp $appnavCategoryMapEnToZh[$item.Category] "Content" ($item.Category -replace ".*__", "")
            } elseif ($appnavCategoryMapZhToEn.ContainsKey($item.Category) -and $sync.ContainsKey($appnavCategoryMapZhToEn[$item.Category])) {
                Set-UiProp $appnavCategoryMapZhToEn[$item.Category] "Content" $item.Category
            }
        }
    }
}
