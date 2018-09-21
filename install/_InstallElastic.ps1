#set-executionpolicy remotesigned
Write-Host "Installation started" -ForeGround Green
Set-Location -Path $PSScriptRoot
$params = Get-Content "..\configuration.json" | ConvertFrom-Json
$installLocation = $params.stack.install
$binariesLocation = $installLocation+"\binaries"
$stackVersion = $params.stack.version
$cerebroVersion = $params.cerebro.version
$os = $params.stack.os
$javaHome = $params.java.home
$env:JAVA_HOME = "$javaHome"
$baseUrl = $params.stack.url
$cerebroUrl = $params.cerebro.url

###############################
if (!(Test-Path $installLocation)){
	$install = New-Item $installLocation -type directory
}
if (!(Test-Path $binariesLocation)){
	$install = New-Item "$binariesLocation" -type directory
}
########################LOGSTASH######################
$logstashZip = "$binariesLocation\logstash-$stackVersion.zip"
Write-Host "Getting Logstash $stackVersion" -ForeGround Yellow
if (!(Test-Path $logstashZip)){
	Invoke-WebRequest -Uri "$baseUrl/logstash/logstash-$stackVersion.zip" -OutFile $logstashZip
}
if (!(Test-Path "$logstashZip.sha512")){
	Invoke-WebRequest -Uri "$baseUrl/logstash/logstash-$stackVersion.zip.sha512" -OutFile "$logstashZip.sha512"
}
Write-Host "Uncompressing Logstash $stackVersion" -ForeGround Yellow
$logstashZip = Get-Item "$binariesLocation\logstash-$stackVersion.zip"
if ((Get-FileHash -Path $logstashZip -Algorithm SHA512).Hash -ne (Get-Content "$logstashZip.sha512").Split(" ")[0]){
	Write-Host "SHA512 verification failed" -ForeGround Red
	Exit(1)
}
if (!(Test-Path "$installLocation\logstash-$stackVersion")){
	Expand-Archive -Path $logstashZip -DestinationPath $installLocation
	if ($params.stack.xpack) {
		$xpackLogstashZip = "$binariesLocation\logstash-x-pack-$stackVersion.zip"
		Write-Host "Getting Logstash X-Pack $stackVersion" -ForeGround Yellow
		if (!(Test-Path $xpackLogstashZip)){
			Invoke-WebRequest -Uri "$baseUrl/logstash-plugins/x-pack/x-pack-$stackVersion.zip" -OutFile $xpackLogstashZip
		}
		if (!(Test-Path "$xpackLogstashZip.sha512")){
			Invoke-WebRequest -Uri "$baseUrl/logstash-plugins/x-pack/x-pack-$stackVersion.zip.sha512" -OutFile "$xpackLogstashZip.sha512"
		}
		Write-Host "Installing Logstash X-Pack $stackVersion" -ForeGround Yellow
		$pluginLocation = $xpackLogstashZip -replace "\\","/"
		Set-Location -Path "$installLocation\logstash-$stackVersion"
		bin/logstash-plugin install file:///$pluginLocation
		if(!($?)){
			Write-Host "Failed to install" -ForeGround Red
			Exit(1)
		}
	}
}
foreach ($pluginLogstash in $params.stack.plugins.logstash) {
	$pluginLogstashZip = "$binariesLocation\$pluginLogstash-$stackVersion.zip"
	Write-Host "Getting plugin $pluginLogstash" -ForeGround Yellow
	Set-Location -Path "$installLocation\logstash-$stackVersion"
	if (!(Test-Path $pluginLogstashZip)){
		bin/logstash-plugin install $pluginLogstash
		bin/logstash-plugin prepare-offline-pack --output $pluginLogstashZip $pluginLogstash
		bin/logstash-plugin remove $pluginLogstash
	}
	Write-Host "Installing plugin $pluginLogstash" -ForeGround Yellow
	$pluginLocation = $pluginLogstashZip -replace "\\","/"
	bin/logstash-plugin install file:///$pluginLocation
	if(!($?)){
		Write-Host "Failed to install" -ForeGround Red
		Exit(1)
	}
}
Set-Location -Path $PSScriptRoot
########################ELASTICSEARCH######################
$elasticZip = "$binariesLocation\elasticsearch-$stackVersion.zip"
Write-Host "Getting Elasticsearch $stackVersion" -ForeGround Yellow
if (!(Test-Path $elasticZip)){
	Invoke-WebRequest -Uri "$baseUrl/elasticsearch/elasticsearch-$stackVersion.zip" -OutFile $elasticZip
}
if (!(Test-Path "$elasticZip.sha512")){
	Invoke-WebRequest -Uri "$baseUrl/elasticsearch/elasticsearch-$stackVersion.zip.sha512" -OutFile "$elasticZip.sha512"
}
Write-Host "Uncompressing Elasticsearch $stackVersion" -ForeGround Yellow
$elasticZip = Get-Item "$binariesLocation\elasticsearch-$stackVersion.zip"
if ((Get-FileHash -Path $elasticZip -Algorithm SHA512).Hash -ne (Get-Content "$elasticZip.sha512").Split(" ")[0]){
	Write-Host "SHA512 verification failed" -ForeGround Red
	Exit(1)
}
if (!(Test-Path "$installLocation\elasticsearch-$stackVersion")){
	Expand-Archive -Path $elasticZip -DestinationPath $installLocation
	Add-Content $installLocation\elasticsearch-$stackVersion\config\elasticsearch.yml "node.max_local_storage_nodes: 5"
	if ($params.stack.xpack) {
		$xpackElasticsearchZip = "$binariesLocation\elasticsearch-x-pack-$stackVersion.zip"
		Write-Host "Getting Elasticsearch X-Pack $stackVersion" -ForeGround Yellow
		if (!(Test-Path $xpackElasticsearchZip)){
			Invoke-WebRequest -Uri "$baseUrl/elasticsearch-plugins/x-pack/x-pack-$stackVersion.zip" -OutFile $xpackElasticsearchZip
		}
		if (!(Test-Path "$xpackElasticsearchZip.sha512")){
			Invoke-WebRequest -Uri "$baseUrl/elasticsearch-plugins/x-pack/x-pack-$stackVersion.zip.sha512" -OutFile "$xpackElasticsearchZip.sha512"
		}
		Write-Host "Installing Elasticsearch X-Pack $stackVersion" -ForeGround Yellow
		$pluginLocation = $xpackElasticsearchZip -replace "\\","/"
		Set-Location -Path "$installLocation\elasticsearch-$stackVersion"
		bin/elasticsearch-plugin install --batch file:///$pluginLocation
		if(!($?)){
			Write-Host "Failed to install" -ForeGround Red
			Exit(1)
		}
		Add-Content $installLocation\elasticsearch-$stackVersion\config\elasticsearch.yml "xpack.graph.enabled: true"
		Add-Content $installLocation\elasticsearch-$stackVersion\config\elasticsearch.yml "xpack.ml.enabled: false"
		Add-Content $installLocation\elasticsearch-$stackVersion\config\elasticsearch.yml "xpack.monitoring.enabled: false"
		Add-Content $installLocation\elasticsearch-$stackVersion\config\elasticsearch.yml "xpack.security.enabled: false"
		Add-Content $installLocation\elasticsearch-$stackVersion\config\elasticsearch.yml "xpack.watcher.enabled: false"
	}
}
foreach ($pluginElasticsearch in $params.stack.plugins.elasticsearch) {
	$pluginElasticsearchZip = "$binariesLocation\$pluginElasticsearch-$stackVersion.zip"
	Write-Host "Getting plugin $pluginElasticsearch" -ForeGround Yellow
	if (!(Test-Path $pluginElasticsearchZip)){
		Invoke-WebRequest -Uri "$baseUrl/elasticsearch-plugins/$pluginElasticsearch/$pluginElasticsearch-$stackVersion.zip" -OutFile $pluginElasticsearchZip
	}
	if (!(Test-Path "$pluginElasticsearchZip.sha512")){
		Invoke-WebRequest -Uri "$baseUrl/elasticsearch-plugins/$pluginElasticsearch/$pluginElasticsearch-$stackVersion.zip.sha512" -OutFile "$pluginElasticsearchZip.sha512"
	}
	Write-Host "Installing Elasticsearch plugin $pluginElasticsearch $stackVersion" -ForeGround Yellow
	$pluginLocation = $pluginElasticsearchZip -replace "\\","/"
	Set-Location -Path "$installLocation\elasticsearch-$stackVersion"
	if (!(Test-Path "$installLocation\elasticsearch-$stackVersion\plugins\$pluginElasticsearch")){
		bin/elasticsearch-plugin install file:///$pluginLocation
		if(!($?)){
			Write-Host "Failed to install" -ForeGround Red
			Exit(1)
		}
	}
}
Set-Location -Path $PSScriptRoot
########################CEREBRO######################
$cerebroZip = "$binariesLocation\cerebro-$cerebroVersion.zip"
Write-Host "Getting Cerebro $cerebroVersion" -ForeGround Yellow
if (!(Test-Path $cerebroZip)){
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	Invoke-WebRequest -Uri "$cerebroUrl/v$cerebroVersion/cerebro-$cerebroVersion.zip" -OutFile $cerebroZip
}
Write-Host "Uncompressing Cerebro $cerebroVersion" -ForeGround Yellow
$cerebroZip = Get-Item "$binariesLocation\cerebro-$cerebroVersion.zip"
if (!(Test-Path "$installLocation\cerebro-$cerebroVersion")){
	Expand-Archive -Path $cerebroZip -DestinationPath $installLocation
}
########################KIBANA######################
$kibanaZip = "$binariesLocation\kibana-$stackVersion-$os.zip"
Write-Host "Getting Kibana $stackVersion" -ForeGround Yellow
if (!(Test-Path $kibanaZip)){
	Invoke-WebRequest -Uri "$baseUrl/kibana/kibana-$stackVersion-$os.zip" -OutFile $kibanaZip
}
if (!(Test-Path "$kibanaZip.sha512")){
	Invoke-WebRequest -Uri "$baseUrl/kibana/kibana-$stackVersion-$os.zip.sha512" -OutFile "$kibanaZip.sha512"
}
Write-Host "Uncompressing Kibana $stackVersion" -ForeGround Yellow
$kibanaZip = Get-Item "$binariesLocation\kibana-$stackVersion-$os.zip"
if ((Get-FileHash -Path $kibanaZip -Algorithm SHA512).Hash -ne (Get-Content "$kibanaZip.sha512").Split(" ")[0]){
	Write-Host "SHA512 verification failed" -ForeGround Red
	Exit(1)
}
if (!(Test-Path "$installLocation\kibana-$stackVersion-$os")){
	Expand-Archive -Path $kibanaZip -DestinationPath $installLocation
	Add-Content $installLocation\kibana-$stackVersion-$os\config\kibana.yml "tilemap.options.maxZoom: 18"
	if ($params.stack.xpack) {
		$xpackKibanaZip = "$binariesLocation\kibana-x-pack-$stackVersion.zip"
		Write-Host "Getting Kibana X-Pack $stackVersion" -ForeGround Yellow
		if (!(Test-Path $xpackKibanaZip)){
			Invoke-WebRequest -Uri "$baseUrl/kibana-plugins/x-pack/x-pack-$stackVersion.zip" -OutFile $xpackKibanaZip
		}
		if (!(Test-Path "$xpackKibanaZip.sha512")){
			Invoke-WebRequest -Uri "$baseUrl/kibana-plugins/x-pack/x-pack-$stackVersion.zip.sha512" -OutFile "$xpackKibanaZip.sha512"
		}
		Write-Host "Installing Kibana X-Pack $stackVersion" -ForeGround Yellow
		$pluginLocation = $xpackKibanaZip -replace "\\","/"
		Set-Location -Path "$installLocation\kibana-$stackVersion-$os"
		bin/kibana-plugin install file:///$pluginLocation
		if(!($?)){
			Write-Host "Failed to install" -ForeGround Red
			Exit(1)
		}
		Add-Content $installLocation\kibana-$stackVersion-$os\config\kibana.yml "xpack.graph.enabled: true"
		Add-Content $installLocation\kibana-$stackVersion-$os\config\kibana.yml "xpack.ml.enabled: false"
		Add-Content $installLocation\kibana-$stackVersion-$os\config\kibana.yml "xpack.monitoring.enabled: false"
		Add-Content $installLocation\kibana-$stackVersion-$os\config\kibana.yml "xpack.reporting.enabled: false"
		Add-Content $installLocation\kibana-$stackVersion-$os\config\kibana.yml "xpack.security.enabled: false"
	}
}
foreach ($pluginKibana in $params.stack.plugins.kibana) {
	$pluginKibanaZip = "$binariesLocation\$pluginKibana-$stackVersion.zip"
	Write-Host "Getting plugin $pluginKibana" -ForeGround Yellow
	if (!(Test-Path $pluginKibanaZip)){
		Invoke-WebRequest -Uri "$baseUrl/kibana-plugins/$pluginKibana/$pluginKibana-$stackVersion.zip" -OutFile $pluginKibanaZip
	}
	if (!(Test-Path "$pluginKibanaZip.sha512")){
		Invoke-WebRequest -Uri "$baseUrl/kibana-plugins/$pluginKibana/$pluginKibana-$stackVersion.zip.sha512" -OutFile "$pluginKibanaZip.sha512"
	}
	Write-Host "Installing Kibana plugin $pluginKibana $stackVersion" -ForeGround Yellow
	$pluginLocation = $pluginKibanaZip -replace "\\","/"
	Set-Location -Path "$installLocation\kibana-$stackVersion"
	bin/kibana-plugin install file:///$pluginLocation
	if(!($?)){
		Write-Host "Failed to install" -ForeGround Red
		Exit(1)
	}
}
Set-Location -Path $PSScriptRoot
Write-Host "Installation completed" -ForeGround Green
