#set-executionpolicy remotesigned
Set-Location -Path $PSScriptRoot
$params = Get-Content "..\configuration.json" | ConvertFrom-Json
$donnees = "sirene"
#$donneesVersion = "_201706_L_M"
#$donneesSha = "274470c5551975ff65c36240e35064fc69c538810fd6babe92582a02669624cb"
#$donneesUrl = "http://files.data.gouv.fr/sirene/$donnees$donneesVersion.zip"
$donneesUrl = "https://public.opendatasoft.com/explore/dataset/sirene/download/?format=csv&timezone=Europe/Berlin&use_labels_for_header=true"
Write-Host "Loading $donnees" -ForeGround Green
$stackVersion = $params.stack.version
$javaHome = $params.java.home
$env:JAVA_HOME = "$javaHome"
$installLocation = $params.stack.install
$logstashLocation = "$installLocation\logstash-$stackVersion"
$dataLocation = "$installLocation\data"
$donneesConf = "$PSScriptRoot\$donnees.conf"
$donneesTmpl = "$PSScriptRoot\$donnees.tmpl"
#"SIREN": {"type": "keyword"},"NIC": {"type": "keyword"},"L1_NORMALISEE": {"type": "keyword"},"L2_NORMALISEE": {"type": "keyword"},"L3_NORMALISEE": {"type": "keyword"},"L4_NORMALISEE": {"type": "keyword"},"L5_NORMALISEE": {"type": "keyword"},"L6_NORMALISEE": {"type": "keyword"},"L7_NORMALISEE": {"type": "keyword"},"L1_DECLAREE": {"type": "keyword"},"L2_DECLAREE": {"type": "keyword"},"L3_DECLAREE": {"type": "keyword"},"L4_DECLAREE": {"type": "keyword"},"L5_DECLAREE": {"type": "keyword"},"L6_DECLAREE": {"type": "keyword"},"L7_DECLAREE": {"type": "keyword"},"NUMVOIE": {"type": "keyword"},"INDREP": {"type": "keyword"},"TYPVOIE": {"type": "keyword"},"LIBVOIE": {"type": "keyword"},"CODPOS": {"type": "keyword"},"CEDEX": {"type": "keyword"},"RPET": {"type": "keyword"},"LIBREG": {"type": "keyword"},"DEPET": {"type": "keyword"},"ARRONET": {"type": "keyword"},"CTONET": {"type": "keyword"},"COMET": {"type": "keyword"},"LIBCOM": {"type": "keyword"},"DU": {"type": "keyword"},"TU": {"type": "keyword"},"UU": {"type": "keyword"},"EPCI": {"type": "keyword"},"TCD": {"type": "keyword"},"ZEMET": {"type": "keyword"},"SIEGE": {"type": "keyword"},"ENSEIGNE": {"type": "keyword"},"IND_PUBLIPO": {"type": "keyword"},"DIFFCOM": {"type": "keyword"},"AMINTRET": {"type": "keyword"},"NATETAB": {"type": "keyword"},"LIBNATETAB": {"type": "keyword"},"APET700": {"type": "keyword"},"LIBAPET": {"type": "keyword"},"DAPET": {"type": "keyword"},"TEFET": {"type": "keyword"},"LIBTEFET": {"type": "keyword"},"EFETCENT": {"type": "keyword"},"DEFET": {"type": "keyword"},"ORIGINE": {"type": "keyword"},"DCRET": {"type": "keyword"},"DDEBACT": {"type": "keyword"},"ACTIVNAT": {"type": "keyword"},"LIEUACT": {"type": "keyword"},"ACTISURF": {"type": "keyword"},"SAISONAT": {"type": "keyword"},"MODET": {"type": "keyword"},"PRODET": {"type": "keyword"},"PRODPART": {"type": "keyword"},"AUXILT": {"type": "keyword"},"NOMEN_LONG": {"type": "keyword"},"SIGLE": {"type": "keyword"},"NOM": {"type": "keyword"},"PRENOM": {"type": "keyword"},"CIVILITE": {"type": "keyword"},"RNA": {"type": "keyword"},"NICSIEGE": {"type": "keyword"},"RPEN": {"type": "keyword"},"DEPCOMEN": {"type": "keyword"},"ADR_MAIL": {"type": "keyword"},"NJ": {"type": "keyword"},"LIBNJ": {"type": "keyword"},"APEN700": {"type": "keyword"},"LIBAPEN": {"type": "keyword"},"DAPEN": {"type": "keyword"},"APRM": {"type": "keyword"},"ESS": {"type": "keyword"},"DATEESS": {"type": "keyword"},"TEFEN": {"type": "keyword"},"LIBTEFEN": {"type": "keyword"},"EFENCENT": {"type": "keyword"},"DEFEN": {"type": "keyword"},"CATEGORIE": {"type": "keyword"},"DCREN": {"type": "keyword"},"AMINTREN": {"type": "keyword"},"MONOACT": {"type": "keyword"},"MODEN": {"type": "keyword"},"PRODEN": {"type": "keyword"},"ESAANN": {"type": "keyword"},"TCA": {"type": "keyword"},"ESAAPEN": {"type": "keyword"},"ESASEC1N": {"type": "keyword"},"ESASEC2N": {"type": "keyword"},"ESASEC3N": {"type": "keyword"},"ESASEC4N": {"type": "keyword"},"VMAJ": {"type": "keyword"},"VMAJ1": {"type": "keyword"},"VMAJ2": {"type": "keyword"},"VMAJ3": {"type": "keyword"},"DATEMAJ": {"type": "date"}
#$donneesZip = "$dataLocation\$donnees$donneesVersion.zip"
#$donneesCsv = "$dataLocation\$donnees$donneesVersion"
#$donneesSdb = "$donneesJson.sincedb"
$donneesCsv = "$dataLocation\$donnees.csv"
$donneesSdb = "$donneesCsv.sincedb"
$env:DATA = $donnees
$env:TMPL = "$donneesTmpl" -replace "\\","/"
$env:SINCEDB = "$donneesSdb" -replace "\\","/"
#$env:CSV = "$donneesCsv\*.csv" -replace "\\","/"
$env:CSV = "$donneesCsv" -replace "\\","/"
if (!(Test-Path $dataLocation)){
	$install = New-Item $dataLocation -type directory
}
if ((Test-Path $donneesSdb)){
	Remove-Item $donneesSdb
}
#if (!(Test-Path $donneesZip)){
#	Invoke-WebRequest -Uri $donneesUrl -OutFile $donneesZip
#	if ((Get-FileHash -Path $donneesZip -Algorithm SHA256).Hash -ne $donneesSha){
#		Write-Host "SHA256 verification failed" -ForeGround Red
#		Exit(1)
#	}
if (!(Test-Path $donneesCsv)){
	Invoke-WebRequest -Uri $donneesUrl -OutFile $donneesCsv
}
#if (!(Test-Path $donneesCsv)){
#	Expand-Archive -Path $donneesZip -DestinationPath $donneesCsv
#}
Set-Location -Path $logstashLocation
bin\logstash -f $donneesConf --path.data $dataLocation\$donnees --path.logs $dataLocation\$donnees
