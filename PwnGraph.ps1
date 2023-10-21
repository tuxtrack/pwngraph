[cmdletbinding()]

Param(
    
  [Parameter (Mandatory = $true, Position = 0)]
  [string] $appSecret,
  [Parameter (Mandatory = $true, Position = 1)]
  [string] $azureApplicationID,
  [Parameter (Mandatory = $true, Position = 2)]
  [string] $azureTenantID
    
)

function Init {

  if (-not (Get-Module -Name Az -ListAvailable)) {
    Install-Module -Name Az -AllowClobber -Force -Scope CurrentUser
  }

  $azurePassword = ConvertTo-SecureString $appSecret -AsPlainText -Force
  $psCred = New-Object System.Management.Automation.PSCredential($azureApplicationID, $azurePassword)
  
  try {
    Connect-AzAccount -Credential $psCred -TenantID $azureTenantID -ServicePrincipal -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
  }
  catch {
    $desc = $_.Exception.Message
    if ($desc -like "*Access has been blocked by Conditional Access policies*") {
      Write-Host "  [+] Your access has been blocked by Conditional Access policies." -ForegroundColor Yellow
    }
    elseif ($desc -like "*was not found in the directory*") {
      Write-Host "  [+] Identity not found in the directory." -ForegroundColor Yellow
    }
    Exit
  }
  
  $msGraphToken = (Get-AzAccessToken -ResourceTypeName MSGraph).Token
  
  $msGraphEndpoint = "https://graph.microsoft.com/v1.0"
  $httpAuthHeader = @{ Authorization = ("Bearer " + $msGraphToken) }
  $mainServicePrincipalId = (Get-AzADServicePrincipal -ApplicationId $azureApplicationID).Id
  
  #API permissions for each module

  $getOneNoteContentPermission = @(
    'Notes.Read.All',
    'User.Read.All'
  )
  $getSearchPermission = @(
    'Files.Read.All',
    'Sites.Read.All'
  )
  $addGraphAPIRolePermission = @(
    'AppRoleAssignment.ReadWrite.All'
  )
  $addAzGARolePermission = @(
    'RoleManagement.ReadWrite.Directory'
  )
  $addAzUserPermission = @(
    'User.ReadWrite.All',
    'Directory.ReadWrite.All'
  )
  $addAzSPToGroupPermission = @(
    'Group.Read.All'
  )
  $AddIntuneDeviceManagementScriptsPermission = @(
    'DeviceManagementConfiguration.ReadWrite.All'
  )
  $AddAzApplicationManipulationPermission = @(
    'Application.ReadWrite.All'
  )
  $getTeamsMembershipPermission = @(
    'TeamMember.Read.All',
    'ChannelMember.Read.All',
    'Group.Read.All',
    'User.Read.All'
  )
  $addAzConditionalAccessPolicyPermissions = @(
    'Policy.Read.All'
  )

  Menu

}
# Permissions checks
function Menu {
  #Clear-Host
  Write-host "+========================================================================================+" -ForegroundColor Blue
  Write-Host @("
  ██████  ██     ██ ███    ██  ██████  ██████   █████  ██████  ██   ██ 
  ██   ██ ██     ██ ████   ██ ██       ██   ██ ██   ██ ██   ██ ██   ██ ") -ForegroundColor White
  Write-host @("  ██████  ██  █  ██ ██ ██  ██ ██   ███ ██████  ███████ ██████  ███████ ") -ForegroundColor DarkMagenta
  Write-Host @("  ██      ██ ███ ██ ██  ██ ██ ██    ██ ██   ██ ██   ██ ██      ██   ██ 
  ██       ███ ███  ██   ████  ██████  ██   ██ ██   ██ ██      ██   ██                                                                  
") -ForegroundColor Blue
  Write-host "+========================================================================================+" -ForegroundColor Blue

  Write-Host "[+] Application Name: " -ForegroundColor Cyan -NoNewline
  (Parse-JWTtoken $msGraphToken).app_displayname

  Write-Host "[+] Application Service Principal ID: " -ForegroundColor Cyan -NoNewline
  $mainServicePrincipalId

  [array]$roleList = (Parse-JWTtoken $msGraphToken).roles | Sort-Object 
  Write-Host "[+] The current Graph API roles are:" -ForegroundColor Cyan
  for ($i = 0; $i -lt $roleList.Length; $i++) {
    Write-Host "    [*]" $roleList[$i] -ForegroundColor Magenta
  } 

  Write-host "+======================================================================================+" -ForegroundColor Blue
  
  Write-Host "[+] You can perform different actions based on the permissions granted for the application:" -ForegroundColor Cyan

  # Permission prioritization

  if ($roleList -contains "User.ReadWrite.All") {
    $getOneNoteContentPermission = $getOneNoteContentPermission -replace 'User.Read.All', 'User.ReadWrite.All'
    $getTeamsMembershipPermission = $getTeamsMembershipPermission -replace 'User.Read.All', 'User.ReadWrite.All'
  }
  if ($roleList -contains "Group.ReadWrite.All") {
    $addAzSPToGroupPermission = $addAzSPToGroupPermission -replace 'Group.Read.All', 'Group.ReadWrite.All'
  }
  if ($roleList -contains "GroupMember.ReadWrite.All") {
    $addAzSPToGroupPermission = $addAzSPToGroupPermission -replace 'Group.Read.All', 'GroupMember.ReadWrite.All'
  }
  if ($roleList -contains "Files.ReadWrite.All") {
    $getSearchPermission = $getSearchPermission -replace 'Files.Read.All', 'Files.ReadWrite.All'
  }
  if ($roleList -contains "Sites.ReadWrite.All") {
    $getSearchPermission = $getSearchPermission -replace 'Sites.Read.All', 'Sites.ReadWrite.All'
  }
  if ($roleList -contains "ChannelMember.ReadWrite.All") {
    $getTeamsMembershipPermission = $getTeamsMembershipPermission -replace 'ChannelMember.Read.All', 'ChannelMember.ReadWrite.All'
  }
  if ($roleList -contains "Policy.ReadWrite.ConditionalAccess") {
    $addAzConditionalAccessPolicyPermissions += 'Policy.ReadWrite.ConditionalAccess'
  }
  if ($roleList -contains "TeamMember.ReadWrite.All") {
    $getTeamsMembershipPermission = $getTeamsMembershipPermission -replace 'TeamMember.Read.All', 'TeamMember.ReadWrite.All'
  }
  
  $getOneNoteCountCheck = $getOneNoteContentPermission | Where-Object -FilterScript { $_ -in $roleList }
  if ($getOneNoteCountCheck.Count -eq $getOneNoteContentPermission.Count) {
    Write-Host "    [1] Retrieve OneNote user content." 
    $getOnoNoteContent = $true
  }

  $getSearchPermissionCountCheck = $getSearchPermission | Where-Object -FilterScript { $_ -in $roleList }
  if ($getSearchPermissionCountCheck.Count -eq $getSearchPermission.Count) {
    Write-Host "    [2] You can conduct a keyword search across OneDrive, SharePoint drives, and Teams chat documents." 
    $getSearch = $true
  }

  $addGraphAPIRolePermissionCountCheck = $addGraphAPIRolePermission | Where-Object -FilterScript { $_ -in $roleList }
  if ($addGraphAPIRolePermissionCountCheck.Count -eq $addGraphAPIRolePermission.Count) {
    Write-Host "    [3] You can add and assign any Graph API role to this application." 
    $addGraphRole = $true
  }

  $addAzGARolePermissionCountCheck = $addAzGARolePermission | Where-Object -FilterScript { $_ -in $roleList }
  if ($addAzGARolePermissionCountCheck.Count -eq $addAzGARolePermission.Count) {
    Write-Host "    [4] Promote a regular User to Global Administrator." 
    $addAzGARole = $true
  }

  $addAzUserPermissionCountCheck = $addAzUserPermission | Where-Object -FilterScript { $_ -in $roleList }
  if ($addAzUserPermissionCountCheck.Count -eq $addAzUserPermission.Count) {
    Write-Host "    [5] Add a new user to the Tenant." 
    $addAzUser = $true
  }

  $addAzSPToGroupPermissionCountCheck = $addAzSPToGroupPermission | Where-Object -FilterScript { $_ -in $roleList }
  if ($addAzSPToGroupPermissionCountCheck.Count -eq $addAzSPToGroupPermission.Count) {
    Write-Host "    [6] List and modify (if it has permission) groups memberships and teams memberships." 
    $addAzSPToGroup = $true
  }

  $AddIntuneDeviceManagementScriptsPermissionCountCheck = $AddIntuneDeviceManagementScriptsPermission | Where-Object -FilterScript { $_ -in $roleList }
  if ($AddIntuneDeviceManagementScriptsPermissionCountCheck.Count -eq $AddIntuneDeviceManagementScriptsPermission.Count) {
    Write-Host "    [7] Intune device management script manipulation." 
    $addIntuneDeviceManagementScripts = $true
  }

  $AddAzApplicationManipulationPermissionCountCheck = $AddAzApplicationManipulationPermission | Where-Object -FilterScript { $_ -in $roleList }
  if ($AddAzApplicationManipulationPermissionCountCheck.Count -eq $AddAzApplicationManipulationPermission.Count) {
    Write-Host "    [8] List and switch to other applications (App Lateral Movement)." 
    $AddAzApplicationManipulation = $true
  }

  $getTeamsMembershipPermissionCountCheck = $getTeamsMembershipPermission | Where-Object -FilterScript { $_ -in $roleList }
  if ($getTeamsMembershipPermissionCountCheck.Count -eq $getTeamsMembershipPermission.Count) {
    Write-Host "    [9] List all teams channels and members" 
    $getTeamsMembership = $true
  }

  $addAzConditionalAccessPolicyPermissionsCountCheck = $addAzConditionalAccessPolicyPermissions | Where-Object -FilterScript { $_ -in $roleList }
  if ($addAzConditionalAccessPolicyPermissionsCountCheck.Count -eq $addAzConditionalAccessPolicyPermissions.Count) {
    Write-Host "    [10] List and modify (if possible) Conditional Access Policy" 
    $addAzConditionalAccessPolicy = $true
  }
  
  Write-Host "[*] Press 0 to exit [*]" -ForegroundColor Cyan
  $initOpt = Read-Host "[+] PWN - Insert the option number" 

  switch ($initOpt) {
    0 { Disconnect-AzAccount | Out-Null; Exit } 
    1 { if ($getOnoNoteContent -eq $true) { Invoke-Expression -Command ".\Modules\Get-OneNoteContent.ps1" } } 
    2 { if ($getSearch -eq $true) { Invoke-Expression -Command ".\Modules\Get-KeywordSearch.ps1" } }
    3 { if ($addGraphRole -eq $true) { Invoke-Expression -Command ".\Modules\Add-GraphAPIRole.ps1" } }
    4 { if ($addAzGARole -eq $true) { Invoke-Expression -Command ".\Modules\Add-AzGARole.ps1" } }
    5 { if ($addAzUser -eq $true) { Invoke-Expression -Command ".\Modules\Add-AzUser.ps1" } }
    6 { if ($addAzSPToGroup -eq $true) { Invoke-Expression -Command ".\Modules\Add-AzSPToGroup.ps1" } }
    7 { if ($addIntuneDeviceManagementScripts -eq $true) { Invoke-Expression -Command ".\Modules\Add-IntuneDeviceManagementScript.ps1" } }
    8 { if ($AddAzApplicationManipulation -eq $true) { Invoke-Expression -Command ".\Modules\Add-AzApplicationManipulation.ps1" } }
    9 { if ($getTeamsMembership -eq $true) { Invoke-Expression -Command ".\Modules\Get-TeamsMembership.ps1" } }
    10 { if ($addAzConditionalAccessPolicy -eq $true) { Invoke-Expression -Command ".\Modules\Add-AzConditionalAccessPolicy.ps1" } }
    Default {
      Menu
    }
  }  
}

function Parse-JWTtoken {
  <#
    .DESCRIPTION
    Decodes a JWT token. This was taken from link below. Thanks to Vasil Michev.
    .LINK
    https://www.michev.info/Blog/Post/2140/decode-jwt-access-and-id-tokens-via-powershell
    #>
  [cmdletbinding()]
  param(
    [Parameter(Mandatory = $True)]
    [string]$Token
  )
  
  #Validate as per https://tools.ietf.org/html/rfc7519
  #Access and ID tokens are fine, Refresh tokens will not work
  if (-not $Token.Contains(".") -or -not $Token.StartsWith("eyJ")) {
    Write-Error "Invalid token" -ErrorAction Stop
  }
  
  #Header
  $tokenheader = $Token.Split(".")[0].Replace('-', '+').Replace('_', '/')
  
  #Fix padding as needed, keep adding "=" until string length modulus 4 reaches 0
  while ($tokenheader.Length % 4) {
    Write-Verbose "Invalid length for a Base-64 char array or string, adding ="
    $tokenheader += "="
  }
  
  Write-Verbose "Base64 encoded (padded) header: $tokenheader"
  
  #Convert from Base64 encoded string to PSObject all at once
  Write-Verbose "Decoded header:"
  $header = ([System.Text.Encoding]::ASCII.GetString([system.convert]::FromBase64String($tokenheader)) | convertfrom-json)
  
  #Payload
  $tokenPayload = $Token.Split(".")[1].Replace('-', '+').Replace('_', '/')
  
  #Fix padding as needed, keep adding "=" until string length modulus 4 reaches 0
  while ($tokenPayload.Length % 4) {
    Write-Verbose "Invalid length for a Base-64 char array or string, adding ="
    $tokenPayload += "="
  }
    
  Write-Verbose "Base64 encoded (padded) payoad: $tokenPayload"
  
  $tokenByteArray = [System.Convert]::FromBase64String($tokenPayload)
  
  
  $tokenArray = ([System.Text.Encoding]::ASCII.GetString($tokenByteArray) | ConvertFrom-Json)
  
  #Converts $header and $tokenArray from PSCustomObject to Hashtable so they can be added together.
  #I would like to use -AsHashTable in convertfrom-json. This works in pwsh 6 but for some reason Appveyor isnt running tests in pwsh 6.
  $headerAsHash = @{}
  $tokenArrayAsHash = @{}
  $header.psobject.properties | ForEach-Object { $headerAsHash[$_.Name] = $_.Value }
  $tokenArray.psobject.properties | ForEach-Object { $tokenArrayAsHash[$_.Name] = $_.Value }
  $output = $headerAsHash + $tokenArrayAsHash
  
  Write-Output $output
}

Init
