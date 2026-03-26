$raw = Get-Content 'config\applications.json' -Raw -Encoding UTF8
$raw | ConvertFrom-Json | Out-Null
Write-Output 'ok'
