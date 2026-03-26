Get-ChildItem 'config' | Where-Object {$_.Extension -eq '.json'} | ForEach-Object {
    $json = Get-Content $_.FullName -Raw -Encoding UTF8
    $jsonAsObject = $json | ConvertFrom-Json
    $json = @"
$($jsonAsObject | ConvertTo-Json -Depth 3)
"@
    try {
        $json | ConvertFrom-Json | Out-Null
        Write-Output "OK: $($_.Name)"
    } catch {
        Write-Output "FAIL: $($_.Name) -> $($_.Exception.Message)"
    }
}
