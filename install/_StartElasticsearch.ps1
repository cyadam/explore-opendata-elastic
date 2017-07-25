#set-executionpolicy remotesigned
Write-Host "Starting Elasticsearch" -ForeGround Green
Set-Location -Path $PSScriptRoot
$params = Get-Content "..\configuration.json" | ConvertFrom-Json
$installLocation = $params.stack.install
$stackVersion = $params.stack.version
$javaHome = $params.java.home
$env:JAVA_HOME = "$javaHome"
Set-Location -Path "$installLocation\elasticsearch-$stackVersion"
bin\elasticsearch
