#set-executionpolicy remotesigned
$donnees = "resultats_electoraux"
$donneesUrl = "https://opendata.paris.fr/explore/dataset/resultats_electoraux/download/?format=csv&timezone=Europe/Berlin&use_labels_for_header=true"
$stackVersion = "5.4.0"
$javaHome = "C:\Java\jdk1.8.0_65"
$env:JAVA_HOME = "$javaHome"
$installLocation = "C:\elastic\logstash-$stackVersion"
$dataLocation = "C:\elastic\data"
$confLocation = "$installLocation\config"
$donneesConf = "$donnees.conf"
$donneesTmpl = "$donnees.tmpl"
$donneesCsv = "$dataLocation\$donnees.csv"
$donneesSdb = "$donneesCsv.sincedb"
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
