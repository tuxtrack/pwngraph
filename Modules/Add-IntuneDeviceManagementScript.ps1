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
function Add-IntuneDeviceManagementScript {

    Clear-Host

    $banner01 = @("
        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        ?7~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!7P
        7^                               7Y
        ?^             .::.              75
        ?^          .^^~~~~^^:.         .?5
        J~         ^7!!~~~~7J55         .?5
        Y~         ^7777!J5PPPP         .JP
        Y!         :7777!YPPPPJ         .YP")
    $banner02 = @("        5!           .:~!YY7^.          .YG
        P!               .              .5G
        P?..............................^5G
        &#############GG  GGB#############&
        @@@@@@@@@@@@@@G    G#@@@@@@@@@@@@@@
        @@@@@@@@@@@@@#      G@@@@@@@@@@@@@@
        @@@@@@@@@@@&           &@@@@@@@@@@@
        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        ")

    Write-host "+======================================================================================+" -ForegroundColor Blue
    Write-Host "$($banner01)" -NoNewline -ForegroundColor Cyan
    Write-Host "        [*] Intune Device Managemente Scripts [*]" -ForegroundColor Yellow
    Write-Host "$($banner02)" -ForegroundColor Cyan
    Write-host "+======================================================================================+" -ForegroundColor Blue
    
    Write-Host "    [+] Insert 1 to list current scripts." -ForegroundColor Yellow
    Write-Host "    [+] Insert 2 to load and update current scripts." -ForegroundColor Yellow
    Write-Host "    [+] Insert 3 to add a new script." -ForegroundColor Yellow
    $option = Read-Host "[+] Option"

    function Get-ListIntuneDeviceManagementScript {

        Clear-Host

        Write-host "+======================================================================================+" -ForegroundColor Blue
        Write-Host "$($banner01)" -NoNewline -ForegroundColor Cyan
        Write-Host "        [*] Intune Device Managemente Scripts [*]" -ForegroundColor Yellow
        Write-Host "$($banner02)" -ForegroundColor Cyan
        Write-host "+======================================================================================+" -ForegroundColor Blue
        
        $acceptHeader = @{ Accept = "application/json" }
        $intuneDeviceManagementScriptsListEndpoint = "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts/"

        try {
            $scriptListId = (Invoke-RestMethod -Uri ($intuneDeviceManagementScriptsListEndpoint) -Method Get -Headers ($httpAuthHeader + $acceptHeader)).value
        }
        catch {
            Write-Warning $Error[0]
        }

        foreach ($scriptId in $scriptListId.id) {

            try {
                $scriptList = (Invoke-RestMethod -Uri ($intuneDeviceManagementScriptsListEndpoint + $scriptId) -Method Get -Headers ($httpAuthHeader + $acceptHeader))
            }
            catch {
                Write-Wa
                rning $Error[0]
            } 

            Write-Host "[+] Intune device management script list:" -ForegroundColor Yellow
            Write-Host "    [+] Script Name: " -ForegroundColor Yellow -NoNewline
            Write-Host $scriptList.displayName -ForegroundColor Green
            Write-Host "    [+] Description: " -ForegroundColor Yellow -NoNewline
            Write-Host $scriptList.description -ForegroundColor Green
            Write-Host "    [+] Script ID: " -ForegroundColor Yellow -NoNewline
            Write-Host $scriptList.id -ForegroundColor Green
            Write-Host "    [+] Script code: " -ForegroundColor Yellow
            $scriptContent = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($scriptList.scriptContent))
            Write-Host $scriptContent -ForegroundColor Cyan
            Write-Host "    [+] File Name: " -ForegroundColor Yellow -NoNewline
            Write-Host $scriptList.fileName -ForegroundColor Green
            Write-Host "    [+] Enforce signature check: " -ForegroundColor Yellow -NoNewline
            Write-Host $scriptList.enforceSignatureCheck -ForegroundColor Green
            Write-Host "    [+] Run as 32 Bit: " -ForegroundColor Yellow -NoNewline
            Write-Host $scriptList.runAs32Bit -ForegroundColor Green
            Write-Host "    [+] Created date time: " -ForegroundColor Yellow -NoNewline
            Write-Host $scriptList.createdDateTime -ForegroundColor Green
            Write-Host "    [+] Run as account: " -ForegroundColor Yellow -NoNewline
            Write-Host $scriptList.runAsAccount -ForegroundColor Green

            Write-host "+======================================================================================+" -ForegroundColor Blue

        }
        
        $reDo = Read-Host "[+] Insert 0 to back to Intune Device Menu our press enter to main menu"
        if ($reDo -eq '0') {
            Add-IntuneDeviceManagementScript
        }
        else {
            Clear-Host
            Menu
        }
    }

    function Get-LoadEditIntuneDeviceManagementScript {

        Clear-Host

        Write-host "+======================================================================================+" -ForegroundColor Blue
        Write-Host "$($banner01)" -NoNewline -ForegroundColor Blue
        Write-Host "        [*] Intune Device Managemente Scripts [*]" -ForegroundColor Yellow
        Write-Host "$($banner02)" -ForegroundColor Blue
        Write-host "+======================================================================================+" -ForegroundColor Blue
        
        $acceptHeader = @{ Accept = "application/json" }
        $intuneDeviceManagementScriptsListEndpoint = "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts"

        try {
            $scriptList = (Invoke-RestMethod -Uri ($intuneDeviceManagementScriptsListEndpoint) -Method Get -Headers ($httpAuthHeader + $acceptHeader)).value
        }
        catch {
            Write-Warning $Error[0]
        }
        
        $scriptList | Select-Object displayName, description, id | Format-List

        Write-host "+======================================================================================+" -ForegroundColor Blue

        $scriptId = Read-Host "[+] Insert the script ID"
        $newPowershellContentPath = Read-Host "[+] Insert the path for the new PS Script"
        $psContent = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((Get-Content -Path $newPowershellContentPath -Raw -Encoding UTF8)))

        try {
            $scriptDetails = (Invoke-RestMethod -Uri ($intuneDeviceManagementScriptsListEndpoint + "/" + $scriptId) -Method Get -Headers ($httpAuthHeader + $acceptHeader))
        }
        catch {
            Write-Warning $Error[0]
        }

        $psDisplayName = $scriptDetails.displayName
        $psDescription = $scriptDetails.description
        $psFileName = $scriptDetails.fileName

        $body = @("
        {
            '@odata.type': '#microsoft.graph.deviceManagementScript',
            'displayName': '$psDisplayName',
            'description': '$psDescription', 
            'scriptContent': '$psContent',
            'runAsAccount': 'system',
            'enforceSignatureCheck': 'false',
            'fileName': '$psFileName',
            'roleScopeTagIds': [
              '0'
            ],
            'runAs32Bit': 'true'
        }
        ")

        try {
            $updateScript = (Invoke-RestMethod -Uri ($intuneDeviceManagementScriptsListEndpoint + "/" + $scriptId) -Method Patch -Headers ($httpAuthHeader + $acceptHeader) -Body $body -ContentType 'application/json') 
        }
        catch {
            Write-Warning $Error[0]
        }
        $updateScript

        $main = Read-Host "[+] Press any key to main menu"
        if ($main -eq '') { Menu }
    }

    function Add-NewIntuneDeviceManagementScript {

        Clear-Host

        Write-host "+======================================================================================+" -ForegroundColor Blue
        Write-Host "$($banner01)" -NoNewline -ForegroundColor Blue
        Write-Host "        [*] Intune Device Managemente Scripts [*]" -ForegroundColor Yellow
        Write-Host "$($banner02)" -ForegroundColor Blue
        Write-host "+======================================================================================+" -ForegroundColor Blue
        
        $acceptHeader = @{ Accept = "application/json" }
        $intuneDeviceManagementScriptsListEndpoint = "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts"
    
        $newPowershellContentPath = Read-Host "[+] Insert the path for the new PS Script"
        $psContent = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((Get-Content -Path $newPowershellContentPath -Raw -Encoding UTF8)))
        $psDisplayName = Read-Host "[+] Insert the script display name"
        $psDescription = Read-Host "[+] Insert the script description"
        $psFileName = $psDisplayName + ".ps1"

        $body = @("
        {
            '@odata.type': '#microsoft.graph.deviceManagementScript',
            'displayName': '$psDisplayName',
            'description': '$psDescription', 
            'scriptContent': '$psContent',
            'runAsAccount': 'system',
            'enforceSignatureCheck': 'false',
            'fileName': '$psFileName',
            'roleScopeTagIds': [
              '0'
            ],
            'runAs32Bit': 'true'
        }
        ")

        try {
            $updateScript = (Invoke-RestMethod -Uri ($intuneDeviceManagementScriptsListEndpoint) -Method Post -Headers ($httpAuthHeader + $acceptHeader) -Body $body -ContentType 'application/json') 
        }
        catch {
            Write-Warning $Error[0]
        }
        
        $assingScriptId = $updateScript.id

        $params = @("
        {'deviceManagementScriptAssignments':[{'target':{'@odata.type':'#microsoft.graph.allDevicesAssignmentTarget'}}]}
        ")

        $assignActionEnpoint = "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts/$assingScriptId/assign"

        Write-Host "[+] Assigning the new script to all machines" -ForegroundColor Yellow
        try {
            (Invoke-RestMethod -Uri ($assignActionEnpoint) -Method Post -Headers ($httpAuthHeader + $acceptHeader) -Body $params -ContentType 'application/json')
        }
        catch {
            Write-Warning $Error[0]
        }

        Read-Host "[+] Press any key to main menu"
        Menu
    }

    switch ($option) {
        1 { Get-ListIntuneDeviceManagementScript } 
        2 { Get-LoadEditIntuneDeviceManagementScript }
        3 { Add-NewIntuneDeviceManagementScript }
        Default {
            Menu
        }
    } 
}
Add-IntuneDeviceManagementScript