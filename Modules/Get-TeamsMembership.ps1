function Get-TeamsMembership() {
  Clear-Host
  Write-host "+======================================================================================+" -ForegroundColor Blue
  Write-Host @("
              .:---:.          
            :-------:   .:-:  
            ---------  -+++++ 
-===========++++=---   -++++= 
++++=======++++=:..     .:::  
++++-:. .::+++++-::::::-=====-") -ForegroundColor Cyan -NoNewline
  Write-Host "    [*] List all Teams channels and members [*]" -ForegroundColor Yellow -NoNewline
  Write-Host @("++++++: :++++++*=------=++++++
++++++: :++++++*=------=++++++
++++++: :++++++*=------=++++++
++++++++++++****=------=++++++
-=======+*******=------=+++++:
         =+++++=--------==-:  
          :----------:           
  ") -ForegroundColor Cyan
  Write-host "+======================================================================================+" -ForegroundColor Blue

  $teamsEndpoint = "/groups?`$filter=resourceProvisioningOptions/Any(x:x eq 'Team')"
  $teamsId = ((Invoke-RestMethod -Uri ($msGraphEndpoint + $TeamsEndpoint) -Headers $HttpAuthHeader).value).Id

  foreach ($id in $teamsId) {   
        
    $msTeamsEndpoint = "/teams/$id"
    try {
      $TeamsGroups = (Invoke-RestMethod -Uri ($msGraphEndpoint + $msTeamsEndpoint) -Headers $HttpAuthHeader)
    }
    catch {
      Write-Warning $Error[0]
    }
        
    Write-Host "=------------------------------ MICROSOFT TEAMS -------------------------------=" -ForegroundColor Cyan
    Write-Host "[+] Microsoft Teams information from:" ($TeamsGroups).displayName -ForegroundColor Yellow 
    Write-host "[+] Visibility:" ($TeamsGroups | Select-Object -ExpandProperty visibility)
    Write-Host ""

    $msTeamsChannelEndpoint = "/teams/$id/Channels"
    try {
      $teamsChannel = (Invoke-RestMethod -Uri ($msGraphEndpoint + $msTeamsChannelEndpoint) -Headers $HttpAuthHeader).value
    }
    catch {
      Write-Warning $Error[0]
    }


    foreach ($channelId in ($TeamsChannel).id) {    
      $teamsChannelEndpoint = "/teams/$id/channels/$channelId"
      try {
        $teamsChannelMembers = (Invoke-RestMethod -Uri ($msGraphEndpoint + $teamsChannelEndpoint) -Headers $HttpAuthHeader)
      }
      catch {
        Write-Warning $Error[0]
      }
      foreach ($chanid in $teamsChannelMembers) {   
        Write-Host "  [+] Members and roles from channel:" $teamsChannelMembers.displayName -ForegroundColor Yellow
        $teamsChannelEndpoint = "/teams/$id/channels/$channelId/members"
        try {
          $teamsChannelMembersList = (Invoke-RestMethod -Uri ($msGraphEndpoint + $TeamsChannelEndpoint) -Headers $HttpAuthHeader).value
        }
        catch {
          Write-Warning $Error[0]
        }
        foreach ($teamUser in $teamsChannelMembersList) {
          Write-Host ""
          Write-Host "    [+] Member Name: " -ForegroundColor Cyan -NoNewline
          $teamUser.displayName
          Write-Host "    [+] User email account: " -ForegroundColor Cyan -NoNewline
          $teamUser.email
          Write-Host "    [+] Member Role: " -ForegroundColor Cyan -NoNewline
          Write-Host $teamUser.roles
          Write-Host ""
        }
      }    
    }             
  }
  Read-Host "[+] Press any key to main menu"
  Menu
}
Get-TeamsMembership