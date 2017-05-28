#set-executionpolicy remotesigned
$installLocation = "C:\elastic"
$stackVersion = "5.4.0"
$javaHome = "C:\Java\jdk1.8.0_65"
$env:JAVA_HOME = "$javaHome"
Set-Location -Path "$installLocation\elasticsearch-$stackVersion"
Write-Host "Starting elasticsearch" -ForeGround Red
Start-Process bin\elasticsearch
