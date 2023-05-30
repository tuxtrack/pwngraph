function Add-AzUser {

    Clear-Host 
    Write-host "+======================================================================================+" -ForegroundColor Blue
    
    Write-Host = @("
    :::::::::.......:::::::::
    :::::::.:7Y5P5J!:.:::::::
    :::::::?#@@@@@@@#?:::::::
    :::::.!@@@@@@@@@@&~.:::::
    :::::.?@@@@@@@@@@@7.:::::
    :::::::5@@@@@@@@&Y:::::::") -ForegroundColor Blue -NoNewline
    Write-Host "    [*] Add Azure User [*]" -ForegroundColor Yellow -NoNewline
    Write-Host @(" 
    ::::..^~!YGB#BGY!~^..::::
    :::.~5@@@@@@@@@@@@@5~.::: 
    :::?&@@@@@@@@@@@@@@@&?.::
    :.7@@@@@@@@@@@@@@@@@@&!.:
    :.7#@@@@@@@@@@@@@@@@@#7.:
    ::.^?G&@@@@@@@@@@@&P?^.::
    :::...^!J5PGGGP5J!^..::::
    ::::::.............::::::
    ") -ForegroundColor Blue
    Write-host "+======================================================================================+" -ForegroundColor Blue

    $user = Read-Host "[+] Please insert the User Name"
    $domain = Read-Host "[+] Please insert the AZ domain"

    $userPassword = -Join ("ABCDEFGHIJKLMNOPQRSTUVXWYZabcdefhijklmnopqrstuvxwyz!@#$%ˆ&*()1234567890".tochararray() | Get-Random -Count 15 | % { [char]$_ })

    $body = @("
    {
        'accountEnabled': 'true',
        'displayName': '$user',
        'mailNickname': '$user',
        'userPrincipalName': '$user@$domain.onmicrosoft.com',
        'passwordProfile' : {
          'forceChangePasswordNextSignIn': 'false',
          'password': '$userPassword'
        }
      }
    ")

    $userEndpoint = "/users"
    
    try {
        $addUserResponse = (Invoke-RestMethod -Uri ($msGraphEndpoint + $userEndpoint) -Method Post -Body $body -Headers $HttpAuthHeader -ContentType 'application/json')
    }
    catch {
        Write-Error $Error[0]
    }

    Write-Host "    [+] $user Id:"  $addUserResponse.id -ForegroundColor Yellow
    Write-Host "    [+] $user User Principal Name :"  $addUserResponse.userPrincipalName -ForegroundColor Yellow
    Write-Host "    [+] $user Password :"  $userPassword -ForegroundColor Yellow

    $reDo = Read-Host "[+] Insert Yes to add a new user or press Enter/Return to exit to main menu."
    if ($reDo -eq 'Yes') {
        Add-AzUser
    }
    else {
        Clear-Host
        Menu
    }
}
Add-AzUser