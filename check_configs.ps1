Get-ChildItem config -Filter *.json | ForEach-Object {
    try {
        $content = Get-Content $_.FullName -Raw -Encoding UTF8
        $content | ConvertFrom-Json | Out-Null
        Write-Output "OK: $($_.Name)"
    } catch {
        Write-Output "FAIL: $($_.FullName) -> $($_.Exception.Message)"
    }
}
