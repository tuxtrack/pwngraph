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
      $TeamsChannel = (Invoke-RestMethod -Uri ($msGraphEndpoint + $msTeamsChannelEndpoint) -Headers $HttpAuthHeader).value
    }
    catch {
      Write-Warning $Error[0]
    }
    foreach ($channelId in ($TeamsChannel).id) {    
      $TeamsChannelEndpoint = "/teams/$id/channels/$channelId"
      try {
        $TeamsChannelMembers = (Invoke-RestMethod -Uri ($msGraphEndpoint + $TeamsChannelEndpoint) -Headers $HttpAuthHeader)
      }
      catch {
        Write-Warning $Error[0]
      }
      foreach ($chanid in $TeamsChannelMembers) {   
        Write-Host "[+] Members and roles from channel:" $TeamsChannelMembers.displayName -ForegroundColor Yellow
        $TeamsChannelEndpoint = "/teams/$id/channels/$channelId/members"
        try {
          $TeamsChannelMembersList = (Invoke-RestMethod -Uri ($msGraphEndpoint + $TeamsChannelEndpoint) -Headers $HttpAuthHeader).value
        }
        catch {
          Write-Warning $Error[0]
        }
        $TeamsChannelMembersList | Select-Object displayName, roles | Format-Table
      }    
    }             
  }
  Read-Host "[+] Press any key to main menu"
  Menu
}
Get-TeamsMembership