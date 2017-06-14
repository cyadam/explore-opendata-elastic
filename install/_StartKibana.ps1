#set-executionpolicy remotesigned
$installLocation = "C:\elastic"
$stackVersion = "5.4.1"
Set-Location -Path "$installLocation\kibana-$stackVersion-windows-x86"
Write-Host "Starting kibana" -ForeGround Red
Start-Process bin\kibana
