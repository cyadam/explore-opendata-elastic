#set-executionpolicy remotesigned
$installLocation = "C:\elastic"
$cerebroVersion = "0.6.5"
Set-Location -Path "$installLocation\cerebro-$cerebroVersion"
if (Test-Path "$installLocation\cerebro-$cerebroVersion"){
    Remove-Item RUNNING_PID
}
Write-Host "Starting cerebro" -ForeGround Red
Start-Process bin\cerebro
