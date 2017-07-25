#set-executionpolicy remotesigned
Write-Host "Starting Kibana" -ForeGround Green
Set-Location -Path $PSScriptRoot
$params = Get-Content "..\configuration.json" | ConvertFrom-Json
$installLocation = $params.stack.install
$stackVersion = $params.stack.version
$os = $params.stack.os
Set-Location -Path "$installLocation\kibana-$stackVersion-$os"
bin\kibana
