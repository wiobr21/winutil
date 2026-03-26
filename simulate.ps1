$json = (Get-Content 'config\applications.json' -Raw -Encoding UTF8)
$jsonAsObject = $json | ConvertFrom-Json
$json = @"
$($jsonAsObject | ConvertTo-Json -Depth 3)
"@
try {
    $json | ConvertFrom-Json | Out-Null
    Write-Output 'convert success'
} catch {
    Write-Output 'convert failed'
    Write-Output $_.Exception.Message
}
