cd c:\\chef

$env=type env-value
$roles=type roles-value
$cookbook=type artifactory-value
$cookbookname=type cookbook-value
$UN="djin-chef-zero"
$PW="AKCp2UPfPwAfd5cPnTs2zT7M8ThH3Ro4M9Ye4MWTPbKoLZRNwynvzJSbL44hAPQ5xgFpSFqLs"

#gets creds for artifactory
$webclient = new-object System.Net.WebClient
$credCache = new-object System.Net.CredentialCache
$creds = new-object System.Net.NetworkCredential($UN,$PW)
$credCache.Add($cookbook, "Basic", $creds)
$webclient.Credentials = $credCache

$webclient.DownloadFile($cookbook, "C:\chef\cookbooks.tar.gz") | echo
tar xzvf 'cookbooks.tar.gz'

# get json in powershell objects
$JSONFileRoles = ConvertFrom-Json "$(get-content "cookbooks\$cookbookname\roles\$roles.json")"
$JSONFileEnvironment = ConvertFrom-Json "$(get-content "cookbooks\$cookbookname\environments\$env.json")"

# Merge roles and env in powershell
$JSONFileEnvironment | Add-Member -MemberType NoteProperty -Name run_list -Value $JSONFileRoles.run_list
$MergedAttribs = $JSONFileEnvironment | ConvertTo-Json

# Create file:
$MergedAttribs | Set-Content 'json_attribs.json'

#run chef and log out
chef-client -c client.rb
Write-Host "chef-max run completed. Please check c:\chef\client.log for logs."
