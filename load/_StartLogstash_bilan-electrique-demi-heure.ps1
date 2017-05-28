#set-executionpolicy remotesigned
$stackVersion = "5.4.0"
$javaHome = "C:\Java\jdk1.8.0_65"
$env:JAVA_HOME = "$javaHome"
$installLocation = "C:\elastic\logstash-$stackVersion"
$dataLocation = "C:\elastic\data"
$confLocation = "$installLocation\config"
$donnees = "bilan-electrique-demi-heure"
$donneesConf = "$donnees.conf"
$donneesTmpl = "$donnees.tmpl"
$donneesCsv = "$dataLocation\$donnees.csv"
$donneesSdb = "$donneesCsv.sincedb"
$donneesUrl = "https://data.enedis.fr/explore/dataset/bilan-electrique-demi-heure/download/?format=csv&timezone=Europe/Berlin&use_labels_for_header=true"
if (!(Test-Path $dataLocation)){
	$install = New-Item $dataLocation -type directory
}
if ((Test-Path $donneesSdb)){
	Remove-Item $donneesSdb
}
if (!(Test-Path $donneesCsv)){
	Invoke-WebRequest -Uri $donneesUrl -OutFile $donneesCsv
}
Set-Location -Path "$installLocation"
Copy-Item "$PSScriptRoot\$donneesConf" $confLocation
Copy-Item "$PSScriptRoot\$donneesTmpl" $dataLocation
bin\logstash -f "$confLocation\$donneesConf"
