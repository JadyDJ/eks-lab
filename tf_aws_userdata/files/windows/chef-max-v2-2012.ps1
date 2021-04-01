# Process command line arguments
[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)]
    [string]$REGION,

    [Parameter(Mandatory=$True)]
    [string]$STACK_NAME,

    [Parameter(Mandatory=$True)]
    [string]$STACK_ID,

    [Parameter(Mandatory=$True)]
    [string]$LC_NAME,

    [Parameter(Mandatory=$True)]
    [string]$CHEF_RUNLIST,

    [Parameter(Mandatory=$True)]
    [string]$CHEF_ENV,

    [Parameter(Mandatory=$True)]
    [string]$CHEF_COOKBOOK,

    [Parameter(Mandatory=$True)]
    [string]$VERSION,

    [Parameter(Mandatory=$True)]
    [string]$INTERVAL
)

# Imports
Initialize-AWSDefaults -Region $REGION

##### Setting up username and password (readonly-apikey)
$ARTIFACTORY="https://artifactory.dowjones.io/artifactory/djin-chef-local"
$UN="djin-chef-zero"
$PW="AKCp2UPfPwAfd5cPnTs2zT7M8ThH3Ro4M9Ye4MWTPbKoLZRNwynvzJSbL44hAPQ5xgFpSFqLs"

# Setup chef client.rb
$InstanceId = (New-Object System.Net.WebClient).DownloadString("http://169.254.169.254/latest/meta-data/instance-id")
$TagFilter1 = New-Object Amazon.EC2.Model.Filter
$TagFilter1.Name="resource-id"
$TagFilter1.Value="$InstanceId"
$TagFilter2 = New-Object Amazon.EC2.Model.Filter
$TagFilter2.Name="key"
$TagFilter2.Value="Name"
$InstanceName = (Get-EC2Tag -filter $TagFilter1,$TagFilter2).Value
$ChefNodeName = $InstanceName + "--" + $InstanceId
Write-Host "Setting chef node name: " $ChefNodeName

new-item -Path c:\chef -ItemType file -Name client.rb -Force -Value @"
log_level               :info
log_location            "c:/chef/client.log"
lockfile		            "c:/chef/local-mode-cache/cache/lock"
run_lock_timeout   	    1200
local_mode              true
json_attribs            "c:/chef/json_attribs.json"
chef_repo_path          "c:/chef"
exit_status	      	    :enabled
"@

####### Setup cookbooks
$Cookbooks="${ARTIFACTORY}/cookbooks/${CHEF_COOKBOOK}/${CHEF_COOKBOOK}.${VERSION}.tar.gz"
$webclient = new-object System.Net.WebClient
$credCache = new-object System.Net.CredentialCache
$creds = new-object System.Net.NetworkCredential($UN,$PW)
$credCache.Add($Cookbooks, "Basic", $creds)
$webclient.Credentials = $credCache
$webclient.DownloadFile($Cookbooks, "C:\chef\cookbooks.tar.gz") | echo

cd "C:\chef"
tar xzvf 'cookbooks.tar.gz'

####### get chef-max.ps1
$chefMax="${ARTIFACTORY}/utils/chef-max.ps1"
$webclient = new-object System.Net.WebClient
$credCache = new-object System.Net.CredentialCache
$creds = new-object System.Net.NetworkCredential($UN,$PW)
$credCache.Add($chefMax, "Basic", $creds)
$webclient.Credentials = $credCache
$webclient.DownloadFile($chefMax, "C:\chef\chef-max.ps1") | echo


##### add bat file to run ps1 in a wrapper.
new-item -Path c:\chef -ItemType file -Name chef-max.bat -Force -Value @"
@ECHO OFF
PowerShell.exe -Command "& '%~dpn0.ps1'"
"@

#### adding to path
setx PATH "$env:path;C:\chef" -m

$JSONFileRoles = ConvertFrom-Json "$(get-content "C:\chef\cookbooks\${CHEF_COOKBOOK}\roles\${CHEF_RUNLIST}.json")"
$JSONFileEnvironment = ConvertFrom-Json "$(get-content "C:\chef\cookbooks\${CHEF_COOKBOOK}\environments\${CHEF_ENV}.json")"

# Merge roles and env in powershell
$JSONFileEnvironment | Add-Member -MemberType NoteProperty -Name run_list -Value $JSONFileRoles.run_list
$MergedAttribs = $JSONFileEnvironment | ConvertTo-Json

# Create file:
$MergedAttribs | Set-Content 'c:\chef\json_attribs.json'

#create deps for chef-max
$artEndpoint="${ARTIFACTORY}/cookbooks/${CHEF_COOKBOOK}/${CHEF_COOKBOOK}.${VERSION}.tar.gz"
$artEndpoint >> 'C:\chef\\artifactory-value'
$CHEF_ENV >> 'C:\\chef\\env-value'
$CHEF_RUNLIST >> 'C:\\chef\\roles-value'
$CHEF_COOKBOOK >> 'C:\\chef\\cookbook-value'

if($INTERVAL -eq 0){
   # Delete chef-max service and run chef-max once.
   sc.exe delete chef-client -ErrorAction SilentlyContinue
   # Adding back to path
   setx PATH "$env:path;C:\chef" -m
   C:\chef\chef-max.ps1
} else{
   Write-Host "Chef-Max will run in daemon mode every ${INTERVAL} second"
   # Create/Update chef service to run on cron
   Add-Content C:\chef\\client.rb "`ninterval    $INTERVAL"
   $service=Set-Service -PassThru -Name chef-client -StartupType Automatic
   Write-Host $service
   sc.exe failure $service.name reset= 30000 actions= restart/5000 | echo
   $service=Set-Service -PassThru -Name chef-client -Status Running
   Write-Host $service
}
