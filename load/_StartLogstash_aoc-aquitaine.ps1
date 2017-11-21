#set-executionpolicy remotesigned
Set-Location -Path $PSScriptRoot
$params = Get-Content "..\configuration.json" | ConvertFrom-Json
$donnees = "aoc-aquitaine"
Write-Host "Loading $donnees" -ForeGround Green
$donneesUrl = "https://datacat.datalocale.fr/distribution/491516/raw/liste-csv-sites-produits-AOC-aquitaine.csv"
$stackVersion = $params.stack.version
$javaHome = $params.java.home
$env:JAVA_HOME = "$javaHome"
$installLocation = $params.stack.install
$logstashLocation = "$installLocation\logstash-$stackVersion"
$dataLocation = "$installLocation\data"
$donneesConf = "$PSScriptRoot\$donnees.conf"
$donneesTmpl = "$PSScriptRoot\$donnees.tmpl"
$donneesCsv = "$dataLocation\$donnees.csv"
$donneesSdb = "$donneesCsv.sincedb"
$env:DATA = $donnees
$env:TMPL = "$donneesTmpl" -replace "\\","/"
$env:SINCEDB = "$donneesSdb" -replace "\\","/"
$env:CSV = "$donneesCsv" -replace "\\","/"
if (!(Test-Path $dataLocation)){
	$install = New-Item $dataLocation -type directory
}
if ((Test-Path $donneesSdb)){
	Remove-Item $donneesSdb
}
if (!(Test-Path $donneesCsv)){
	Invoke-WebRequest -Uri $donneesUrl -OutFile $donneesCsv
}
Set-Location -Path $logstashLocation
bin\logstash -f $donneesConf --path.data $dataLocation\$donnees --path.logs $dataLocation\$donnees
