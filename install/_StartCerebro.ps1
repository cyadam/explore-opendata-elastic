#set-executionpolicy remotesigned
Write-Host "Starting Cerebro" -ForeGround Green
Set-Location -Path $PSScriptRoot
$params = Get-Content "..\configuration.json" | ConvertFrom-Json
$installLocation = $params.stack.install
$cerebroVersion = $params.cerebro.version
Set-Location -Path "$installLocation\cerebro-$cerebroVersion"
bin\cerebro
