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
Function Get-OneNoteContent {
    Clear-Host 
    Write-host "+======================================================================================+" -ForegroundColor Blue
    
    Write-Host @("              
            !???????????????????????. 
            !?777777777777777777777?. 
    .JYYY555PGGGGGGG5?7777777777777?. 
    :BBBBPPBBBBPGBBBGJ?777777?YYYYYY. 
    :BBBB. :G#5 7#BBBJ?777777?YYYYYY: 
    :BBBB .~ YP 7#B#BJ?777777?YYYYYY:") -ForegroundColor Magenta -NoNewline
    Write-Host "    [*] Get notes from Microsoft OneNote [*]" -ForegroundColor Yellow -NoNewline
    Write-Host @(" 
    :BBBB :#J ^ 7###BJ?777777JPPPPPP: 
    :#BBB.^##G: J###BJ?777777JPPPPPG: 
    ^##########B####BJ?777777JPPPPPG: 
     7??????GBBBBBBBPJ?777777YBBBBBB: 
            ?YYYYYYJ??7777777YBBBBB#^ 
            !???????????????75######:                                            
    ") -ForegroundColor Magenta

    Write-host "+======================================================================================+" -ForegroundColor Blue

    if (-not (Get-Module -Name PSParseHTML -ListAvailable)) {
        Install-Module -Name PSParseHTML -AllowClobber -Force -Scope CurrentUser
    }

    $msGraphEndpoint = "https://graph.microsoft.com/v1.0"
    $consistencyLevelHeader = @{ ConsistencyLevel = "eventual" }

    $userName = Read-Host "[+] Please insert the username"

    $userEndpoint = "/users?$count=true&`$search=`"mail:$userName`"&`$select=id,displayName,mail"

    try {
        $userId = (Invoke-RestMethod -Uri ($msGraphEndpoint + $userEndpoint) -Method Get -Headers ($httpAuthHeader + $consistencyLevelHeader)).value
    }
    catch {
        Write-Warning $Error[0]
    }

    if (-not ($userId)) {
        Write-Host " [+] User not found!" -ForegroundColor Yellow
        $reDo = Read-Host "[+] To search notes from a new user, please type `"Yes`". To return to the main menu, simply press Enter/Return."
        if ($reDo -eq 'Yes') {
            Get-OneNoteContent
        }
        else {
            Clear-Host
            Menu
        }
    }

    $pagesEndpoint = "/users/$($userId.id)/onenote/pages"

    try {
        $pagesId = (Invoke-RestMethod -Uri ($msGraphEndpoint + $pagesEndpoint) -Method Get -Headers $httpAuthHeader).value
    }
    catch {
        Write-Warning $Error[0]
    }
    foreach ($pageId in $pagesId.id) {
        $pagesContentEndpoint = "/users/$($userId.id)/onenote/pages/$pageId/content"
        $pageName = (Invoke-RestMethod -Uri ($msGraphEndpoint + "/users/$($userId.id)/onenote/pages/$pageId") -Method Get -Headers $httpAuthHeader).title
        try {
            $pageContent = (Invoke-RestMethod -Uri ($msGraphEndpoint + $pagesContentEndpoint) -Method Get -Headers $httpAuthHeader)
        }
        catch {
            Write-Error $Error[0]
        }
        
        Write-Host "=---------------------------------------[+] OneNote content [+]---------------------------------------=" -ForegroundColor Blue
        Write-Host "[+] Note name:" $pageName -ForegroundColor Yellow
        $pageContent | Select-Object InnerXml | Convert-HTMLToText
        
    }
    
    Write-host "+======================================================================================+" -ForegroundColor Blue
    $reDo = Read-Host "[+] To search notes from a new user, please type `"Yes`". To return to the main menu, simply press Enter/Return."
    if ($reDo -eq 'Yes') {
        Get-OneNoteContent
    }
    else {
        Clear-Host
        Menu
    }
}
Get-OneNoteContent