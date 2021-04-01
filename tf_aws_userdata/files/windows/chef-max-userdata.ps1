
$user = "djin-chef-zero"
$pass = "AKCp2UPfPwAfd5cPnTs2zT7M8ThH3Ro4M9Ye4MWTPbKoLZRNwynvzJSbL44hAPQ5xgFpSFqLs"
$secpasswd = ConvertTo-SecureString $pass -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($user, $secpasswd)
$version = (Get-CimInstance Win32_OperatingSystem).Caption
$chef_role = "${chef_role}"
$chef_env = "${chef_env}"
$chef_cookbook = "${chef_cookbook}"
$input_version = "${chef_cookbook_version}"

If ($${chef_cookbook_version} -match 'latest')
{
$input_version = "%5BRELEASE%5D"
}
else {
$input_version = "${chef_cookbook_version}"
}

If ($version -match '2012')
{
$source = "https://artifactory.dowjones.io/artifactory/djin-chef-local/utils/chef-max-v2-2008.ps1"
}
ElseIf($version -match '2008')
{
$source = "https://artifactory.dowjones.io/artifactory/djin-chef-local/utils/chef-max-v2-2012.ps1"
}
else
{
$source = "https://artifactory.dowjones.io/artifactory/djin-chef-local/utils/chef-max-v2-2012.ps1"
}

$destination = "c:\\cfn\\runchef.ps1"
$Arch = (Get-Process -Id $PID).StartInfo.EnvironmentVariables['PROCESSOR_ARCHITECTURE']
$ChefUpgrade = "https://artifactory.dowjones.io/artifactory/djin-chef-local/installation/chef-client-12.12.15-1-x86.msi"

$chefUpgradeDestination = "c:\\chef\\chef-client-upgrade.msi"
Invoke-WebRequest -uri $ChefUpgrade -OutFile $chefUpgradeDestination -Credential $credential
$chefversion = $(chef-client --version)
If ($chefversion -like 'Chef: 11*') {
Start-Process "c:\\chef\\chef-client-upgrade.msi" /qn -Wait
}
Invoke-WebRequest -uri $source -OutFile $destination -Credential $credential
Invoke-Expression "$destination  -CHEF_RUNLIST $${chef_role} -CHEF_ENV $${chef_env} -CHEF_COOKBOOK $${chef_cookbook} -VERSION $${input_version} -INTERVAL $${chef_interval}"
