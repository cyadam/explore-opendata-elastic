#set-executionpolicy remotesigned
Write-Host "Installation started" -ForeGround Green
Set-Location -Path $PSScriptRoot
$installLocation = "C:\elastic"
$stackVersion = "5.4.1"
$cerebroVersion = "0.6.5"
$javaHome = "C:\Java\jdk1.8.0_65"
$env:JAVA_HOME = "$javaHome"
$baseUrl = "https://artifacts.elastic.co/downloads"
$cerebroUrl = "https://github.com/lmenezes/cerebro/releases/download"

###############################
if (!(Test-Path $installLocation)){
	$install = New-Item $installLocation -type directory
}
if (!(Test-Path "$installLocation\binaries")){
	$install = New-Item "$installLocation\binaries" -type directory
}
########################LOGSTASH######################
$logstashZip = "$installLocation\binaries\logstash-$stackVersion.zip"
Write-Host "Getting Logstash $stackVersion" -ForeGround Yellow
if (!(Test-Path $logstashZip)){
	Invoke-WebRequest -Uri "$baseUrl/logstash/logstash-$stackVersion.zip" -OutFile $logstashZip
}
if (!(Test-Path "$logstashZip.sha1")){
	Invoke-WebRequest -Uri "$baseUrl/logstash/logstash-$stackVersion.zip.sha1" -OutFile "$logstashZip.sha1"
}
Write-Host "Uncompressing Logstash $stackVersion" -ForeGround Yellow
$logstashZip = Get-Item "$installLocation\binaries\logstash-$stackVersion.zip"
if ((Get-FileHash -Path $logstashZip -Algorithm SHA1).Hash -ne (Get-Content "$logstashZip.sha1")){
	Write-Host "SHA1 verification failed" -ForeGround Red
	Exit(1)
}
if (!(Test-Path "$installLocation\logstash-$stackVersion")){
	Expand-Archive -Path $logstashZip -DestinationPath $installLocation
}
$pluginElasticsearchFilter = "logstash-filter-elasticsearch"
$logstashElasticsearchFilterZip = "$installLocation\binaries\$pluginElasticsearchFilter-$stackVersion.zip"
Write-Host "Getting plugin $pluginElasticsearchFilter" -ForeGround Yellow
Set-Location -Path "$installLocation\logstash-$stackVersion"
if (!(Test-Path $logstashElasticsearchFilterZip)){
	bin/logstash-plugin install $pluginElasticsearchFilter
	bin/logstash-plugin prepare-offline-pack --output $logstashElasticsearchFilterZip $pluginElasticsearchFilter
	bin/logstash-plugin remove $pluginElasticsearchFilter
}
Write-Host "Installing plugin $pluginElasticsearchFilter" -ForeGround Yellow
$pluginLocation = $logstashElasticsearchFilterZip -replace "\\","/"
bin/logstash-plugin install file:///$pluginLocation
if(!($?)){
	Write-Host "Failed to install" -ForeGround Red
	Exit(1)
}
Set-Location -Path $PSScriptRoot
########################ELASTICSEARCH######################
$elasticZip = "$installLocation\binaries\elasticsearch-$stackVersion.zip"
Write-Host "Getting Elasticsearch $stackVersion" -ForeGround Yellow
if (!(Test-Path $elasticZip)){
	Invoke-WebRequest -Uri "$baseUrl/elasticsearch/elasticsearch-$stackVersion.zip" -OutFile $elasticZip
}
if (!(Test-Path "$elasticZip.sha1")){
	Invoke-WebRequest -Uri "$baseUrl/elasticsearch/elasticsearch-$stackVersion.zip.sha1" -OutFile "$elasticZip.sha1"
}
Write-Host "Uncompressing Elasticsearch $stackVersion" -ForeGround Yellow
$elasticZip = Get-Item "$installLocation\binaries\elasticsearch-$stackVersion.zip"
if ((Get-FileHash -Path $elasticZip -Algorithm SHA1).Hash -ne (Get-Content "$elasticZip.sha1")){
	Write-Host "SHA1 verification failed" -ForeGround Red
	Exit(1)
}
if (!(Test-Path "$installLocation\elasticsearch-$stackVersion")){
	Expand-Archive -Path $elasticZip -DestinationPath $installLocation
	Add-Content $installLocation\elasticsearch-$stackVersion\config\elasticsearch.yml "node.max_local_storage_nodes: 5"
	Add-Content $installLocation\elasticsearch-$stackVersion\config\elasticsearch.yml "xpack.graph.enabled: true"
	Add-Content $installLocation\elasticsearch-$stackVersion\config\elasticsearch.yml "xpack.ml.enabled: true"
	Add-Content $installLocation\elasticsearch-$stackVersion\config\elasticsearch.yml "xpack.monitoring.enabled: false"
	Add-Content $installLocation\elasticsearch-$stackVersion\config\elasticsearch.yml "xpack.security.enabled: false"
	Add-Content $installLocation\elasticsearch-$stackVersion\config\elasticsearch.yml "xpack.watcher.enabled: false"
}
########################CEREBRO######################
$cerebroZip = "$installLocation\binaries\cerebro-$cerebroVersion.zip"
Write-Host "Getting Cerebro $cerebroVersion" -ForeGround Yellow
if (!(Test-Path $cerebroZip)){
	Invoke-WebRequest -Uri "$cerebroUrl/v$cerebroVersion/cerebro-$cerebroVersion.zip" -OutFile $cerebroZip
}
Write-Host "Uncompressing Cerebro $cerebroVersion" -ForeGround Yellow
$cerebroZip = Get-Item "$installLocation\binaries\cerebro-$cerebroVersion.zip"
if (!(Test-Path "$installLocation\cerebro-$cerebroVersion")){
	Expand-Archive -Path $cerebroZip -DestinationPath $installLocation
}
########################KIBANA######################
$kibanaZip = "$installLocation\binaries\kibana-$stackVersion-windows-x86.zip"
Write-Host "Getting Kibana $stackVersion" -ForeGround Yellow
if (!(Test-Path $kibanaZip)){
	Invoke-WebRequest -Uri "$baseUrl/kibana/kibana-$stackVersion-windows-x86.zip" -OutFile $kibanaZip
}
if (!(Test-Path "$kibanaZip.sha1")){
	Invoke-WebRequest -Uri "$baseUrl/kibana/kibana-$stackVersion-windows-x86.zip.sha1" -OutFile "$kibanaZip.sha1"
}
Write-Host "Uncompressing Kibana $stackVersion" -ForeGround Yellow
$kibanaZip = Get-Item "$installLocation\binaries\kibana-$stackVersion-windows-x86.zip"
if ((Get-FileHash -Path $kibanaZip -Algorithm SHA1).Hash -ne (Get-Content "$kibanaZip.sha1")){
	Write-Host "SHA1 verification failed" -ForeGround Red
	Exit(1)
}
if (!(Test-Path "$installLocation\kibana-$stackVersion-windows-x86")){
	Expand-Archive -Path $kibanaZip -DestinationPath $installLocation
	Add-Content $installLocation\kibana-$stackVersion-windows-x86\config\kibana.yml "xpack.graph.enabled: true"
	Add-Content $installLocation\kibana-$stackVersion-windows-x86\config\kibana.yml "xpack.ml.enabled: true"
	Add-Content $installLocation\kibana-$stackVersion-windows-x86\config\kibana.yml "xpack.monitoring.enabled: false"
	Add-Content $installLocation\kibana-$stackVersion-windows-x86\config\kibana.yml "xpack.reporting.enabled: false"
	Add-Content $installLocation\kibana-$stackVersion-windows-x86\config\kibana.yml "xpack.security.enabled: false"
}
########################X-PACK######################
$xpackElasticsearchZip = "$installLocation\binaries\elasticsearch-x-pack-$stackVersion.zip"
Write-Host "Getting Elasticsearch X-Pack $stackVersion" -ForeGround Yellow
if (!(Test-Path $xpackElasticsearchZip)){
	Invoke-WebRequest -Uri "$baseUrl/elasticsearch-plugins/x-pack/x-pack-$stackVersion.zip" -OutFile $xpackElasticsearchZip
}
if (!(Test-Path "$xpackElasticsearchZip.sha1")){
	Invoke-WebRequest -Uri "$baseUrl/elasticsearch-plugins/x-pack/x-pack-$stackVersion.zip.sha1" -OutFile "$xpackElasticsearchZip.sha1"
}
Write-Host "Installing Elasticsearch X-Pack $stackVersion" -ForeGround Yellow
$pluginLocation = $xpackElasticsearchZip -replace "\\","/"
Set-Location -Path "$installLocation\elasticsearch-$stackVersion"
bin/elasticsearch-plugin install file:///$pluginLocation
if(!($?)){
	Write-Host "Failed to install" -ForeGround Red
	Exit(1)
}
$xpackKibanaZip = "$installLocation\binaries\kibana-x-pack-$stackVersion.zip"
Write-Host "Getting Kibana X-Pack $stackVersion" -ForeGround Yellow
if (!(Test-Path $xpackKibanaZip)){
	Invoke-WebRequest -Uri "$baseUrl/kibana-plugins/x-pack/x-pack-$stackVersion.zip" -OutFile $xpackKibanaZip
}
if (!(Test-Path "$xpackKibanaZip.sha1")){
	Invoke-WebRequest -Uri "$baseUrl/kibana-plugins/x-pack/x-pack-$stackVersion.zip.sha1" -OutFile "$xpackKibanaZip.sha1"
}
Write-Host "Installing Kibana X-Pack $stackVersion" -ForeGround Yellow
$pluginLocation = $xpackKibanaZip -replace "\\","/"
Set-Location -Path "$installLocation\kibana-$stackVersion-windows-x86"
bin/kibana-plugin install file:///$pluginLocation
if(!($?)){
	Write-Host "Failed to install" -ForeGround Red
	Exit(1)
}
Set-Location -Path $PSScriptRoot
Write-Host "Installation completed" -ForeGround Green
