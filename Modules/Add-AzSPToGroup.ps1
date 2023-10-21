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
function Add-AzUserToGroup {

    Clear-Host 
    Write-host "+======================================================================================+" -ForegroundColor Blue
    Write-Host @("
    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    @@@@@@@@@#BPP5PG#@@@@@@@@@@@@@@@@@@
    @@@@@@@GJ7!!!!!!7?P@@@@@@@@@@@@@@@@
    @@@@@@5!!777777777!Y@@@@&###&@@@@@@
    @@@@@#77777777777777B@BP55555P#@@@@
    @@@@@&J7????????????##555555555&@@@
    @@@@@@#Y????????J?JB@#55555555P&@@@") -ForegroundColor Cyan -NoNewline
    Write-Host "    [*] Add Azure user into groups [*]" -ForegroundColor Yellow -NoNewline
    Write-Host @(" 
    @@@@@@@BY7??JJJ?7YB@@@#5Y55YYP&@@@@
    @@@@BY?77!::::::~77?5555!^^^J5PG&@@
    @@#J777777!....~777777?55~.755555B@
    @G77777777?!..^77777777?YY75555555B
    #???????????~^???????????5555555555
    Y????????????????????????Y########&
    JJJJJJJJJJJJJJJJJJJJJJJJ?Y@@@@@@@@@
    &BGGGGGGGGGGGGGGGGGGGGGGG&@@@@@@@@@
    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    ") -ForegroundColor Cyan
    Write-host "+======================================================================================+" -ForegroundColor Blue

    Write-Host "    [+] Type 1 to list groups." -ForegroundColor Yellow
    if ($roleList -contains "Group.ReadWrite.All" -and "GroupMember.ReadWrite.All"){
        Write-Host "    [+] Type 2 to add a Security Principal into a group." -ForegroundColor Yellow
    }
    Write-host "+======================================================================================+" -ForegroundColor Blue
    $groupOpt = Read-Host "[+] Insert the option"
    Write-host "+======================================================================================+" -ForegroundColor Blue
    if ($groupOpt -eq 1) {

        $groupInfoEndpoint = "/groups"
        try {
            $groupId = (Invoke-RestMethod -Uri ($msGraphEndpoint + $groupInfoEndpoint) -Method Get -Headers $httpAuthHeader).value
        }
        catch {
            Write-Warning $Error[0]
        }

        $groups = ($groupId | Where-Object -Property onPremisesSyncEnabled -ne $true)

        foreach ($gid in $groups) {

            Write-Host "    [+] Group ID: " -ForegroundColor Yellow -NoNewline
            $gid.id
            Write-Host "    [+] Group name: " -ForegroundColor Yellow -NoNewline
            $gid.displayName
            if ($gid.Description) {
                Write-Host "    [+] Description: " -ForegroundColor Yellow -NoNewline
                $gid.Description
            }
            if ($gid.groupTypes -eq 'DynamicMembership') {
                Write-Host "    [+] Dinamic membership enable: " -ForegroundColor Yellow -NoNewline
                $true
                Write-Host "    [+] Group membership rule: " -ForegroundColor Yellow -NoNewline
                $gid.membershipRule
            }
            if ($gid.isAssignableToRole) {
                Write-Host "    [+] Role assigned : " -ForegroundColor Yellow -NoNewline
                $gid.isAssignableToRole
            }

            Write-Host "[*]------------------------------------------------------------------------------[*]" -ForegroundColor Cyan
        }

        $reDo = Read-Host "[+] Press Yes to back or Enter/Return to exit to main menu."
        if ($reDo -eq 'Yes' ) {
            Add-AzUserToGroup
        }
        else {
            Clear-Host
            Menu
        }
        
    }
    if ($groupOpt -eq 2 -and $roleList -contains "Group.ReadWrite.All" -and "GroupMember.ReadWrite.All") {

        $groupId = Read-Host "[+] Please insert the group ID"
        $securityPrincipalId = Read-Host "[+] Please insert the Security Principal ID"
        $addGroupMemberEndpoint = "/groups/$groupId/members/`$ref" 

        $body = @("
        {
            '@odata.id': 'https://graph.microsoft.com/v1.0/directoryObjects/$securityPrincipalId'
        }
        ")

        try {
            (Invoke-RestMethod -Uri ($msGraphEndpoint + $addGroupMemberEndpoint) -Method Post -Body $body -Headers $httpAuthHeader -ContentType 'application/json').value
        }
        catch {
            Write-Warning $Error[0]
        }

        for ($i = 1; $i -le 100; $i++ ) {
            Write-Progress -Activity " [+] Wait 30 seconds" -Status " $i% Complete:" -PercentComplete $i
            Start-Sleep -Milliseconds 300
        }

        $getGroupMembersEndpoint = "/groups/$groupId/members"

        try {
            $groupMembersList = (Invoke-RestMethod -Uri ($msGraphEndpoint + $getGroupMembersEndpoint) -Method Get -Headers $httpAuthHeader).Value
        }
        catch {
            Write-Warning $Error[0]
        }

        if ($groupMembersList | Where-Object -Property Id -EQ $userId) {
            Write-Host "    [+] The user with Id $userId is now member of the group." -ForegroundColor Yellow
        }
        else {
            Write-Host "    [-] Not possible!" -ForegroundColor Red
        }

        $reDo = Read-Host "[+] Press Yes to back or Enter/Return to exit to main menu."
        if ($reDo -eq 'Yes' ) {
            Add-AzUserToGroup
        }
        else {
            Clear-Host
            Menu
        }
    }
    else {
        Write-Host "    [-] Invalid option!" -ForegroundColor Red
        sleep 4
        Menu
    }
}
Add-AzUserToGroup