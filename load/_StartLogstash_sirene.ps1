#set-executionpolicy remotesigned
Set-Location -Path $PSScriptRoot
$params = Get-Content "..\configuration.json" | ConvertFrom-Json
$donnees = "sirene"
#$donneesVersion = "_201705_L_M"
#$donneesSha = "b3bd05068291ebf6c7ff46c4385cecabb93dc114d6ba566e3a8e917354699c32"
$donneesVersion = "_201706_L_M"
$donneesSha = "274470c5551975ff65c36240e35064fc69c538810fd6babe92582a02669624cb"
$donneesUrl = "http://files.data.gouv.fr/sirene/$donnees$donneesVersion.zip"
Write-Host "Loading $donnees" -ForeGround Green
$stackVersion = $params.stack.version
$javaHome = $params.java.home
$env:JAVA_HOME = "$javaHome"
$installLocation = $params.stack.install
$logstashLocation = "$installLocation\logstash-$stackVersion"
$dataLocation = "$installLocation\data"
$donneesConf = "$PSScriptRoot\$donnees.conf"
$donneesTmpl = "$PSScriptRoot\$donnees.tmpl"
$donneesZip = "$dataLocation\$donnees$donneesVersion.zip"
$donneesCsv = "$dataLocation\$donnees$donneesVersion"
$donneesSdb = "$donneesJson.sincedb"
$env:DATA = $donnees
$env:TMPL = "$donneesTmpl" -replace "\\","/"
$env:SINCEDB = "$donneesSdb" -replace "\\","/"
$env:CSV = "$donneesCsv\*.csv" -replace "\\","/"
if (!(Test-Path $dataLocation)){
	$install = New-Item $dataLocation -type directory
}
if ((Test-Path $donneesSdb)){
	Remove-Item $donneesSdb
}
if (!(Test-Path $donneesZip)){
	Invoke-WebRequest -Uri $donneesUrl -OutFile $donneesZip
	if ((Get-FileHash -Path $donneesZip -Algorithm SHA256).Hash -ne $donneesSha){
		Write-Host "SHA256 verification failed" -ForeGround Red
		Exit(1)
	}
}
if (!(Test-Path $donneesCsv)){
	Expand-Archive -Path $donneesZip -DestinationPath $donneesCsv
}
Set-Location -Path $logstashLocation
bin\logstash -f $donneesConf --path.data $dataLocation\$donnees --path.logs $dataLocation\$donnees
