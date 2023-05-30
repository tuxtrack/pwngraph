function Add-AzConditionalAccessPolicy {
    
    Clear-Host
    Write-host "+======================================================================================+" -ForegroundColor Blue
    Write-Host @("
    @@@@@@@@@@@@@@&@@@@@@@@@@@@@@@
    @@@@@@@@@@@@@Y^7B@@@@@@@@@@@@@
    @@@@@@@@@@@P^:^!!?B@@@@@@@@@@@
    @@@@@@@@@B~::^^!7!!J#@@@@@@@@@
    @@@@@@@#7::^^^^!777775&@@@@@@@
    @@@@@&?::^^^^^^77??????P@@@@@@
    @@@&Y^::::::..:!7777????JG@@@@") -ForegroundColor Blue -NoNewline
    Write-Host "    [*] Conditional Access Policies [*]" -ForegroundColor Yellow
    Write-host @("    @@@Y:..........!!!!!!!!!7?G@@@
    B~!P#BY~.......!7!!!!7JG##GJJ#
    @#Y~^!5B#P!:...!!!?5B&#PJ?YG&@
    @@@@&P!^~JB#G?^?P#&B5??5B&@@@@
    @@@@@@@&G?^^7G#&GY?JP#@@@@@@@@
    @@@@@@@@@@@#J~^?YG&@@@@@@@@@@@
    @@@@@@@@@@@@@@#&@@@@@@@@@@@@@@
        ") -ForegroundColor Blue
    Write-host "+======================================================================================+" -ForegroundColor Blue

    Write-Host "[+] Insert 1 to list all Conditional Access Policy" -ForegroundColor Yellow
    Write-Host "[+] Insert 2 to remove all users from a CAP" -ForegroundColor Yellow
    Write-Host "[+] Insert 3 to list all the Named Locations" -ForegroundColor Yellow
    Write-Host "[+] Insert 4 to modify a Named Location " -ForegroundColor Yellow
    Write-Host "[+] Or press any other key to the main menu " -ForegroundColor Blue
    $ustOpt = Read-Host "[?] Option"

    if ($ustOpt -eq "") { Menu }

    elseif ($ustOpt -eq 1) {

        Clear-Host
        Write-host "+======================================================================================+" -ForegroundColor Blue
        Write-Host @("
    @@@@@@@@@@@@@@&@@@@@@@@@@@@@@@
    @@@@@@@@@@@@@Y^7B@@@@@@@@@@@@@
    @@@@@@@@@@@P^:^!!?B@@@@@@@@@@@
    @@@@@@@@@B~::^^!7!!J#@@@@@@@@@
    @@@@@@@#7::^^^^!777775&@@@@@@@
    @@@@@&?::^^^^^^77??????P@@@@@@
    @@@&Y^::::::..:!7777????JG@@@@") -ForegroundColor Blue -NoNewline
        Write-Host "    [*] List Conditional Access Policies [*]" -ForegroundColor Yellow
        Write-host @("    @@@Y:..........!!!!!!!!!7?G@@@
    B~!P#BY~.......!7!!!!7JG##GJJ#
    @#Y~^!5B#P!:...!!!?5B&#PJ?YG&@
    @@@@&P!^~JB#G?^?P#&B5??5B&@@@@
    @@@@@@@&G?^^7G#&GY?JP#@@@@@@@@
    @@@@@@@@@@@#J~^?YG&@@@@@@@@@@@
    @@@@@@@@@@@@@@#&@@@@@@@@@@@@@@
        ") -ForegroundColor Blue
        Write-host "+======================================================================================+" -ForegroundColor Blue
        
        $capEndpoint = "https://graph.microsoft.com/beta/identity/conditionalAccess/policies"

        Try {
            $capIdResponse = (Invoke-RestMethod -Uri ($capEndpoint) -Headers $httpAuthHeader -Method Get -ContentType "application/json" -UseBasicParsing).value
        }
        Catch {
            Write-Error $Error[0]
        }

        foreach ($capId in $capIdResponse.id) {

            $capEndpoint = "https://graph.microsoft.com/beta/identity/conditionalAccess/policies/" + $capId

            Try {
                $capResponse = (Invoke-RestMethod -Uri ($capEndpoint) -Headers $httpAuthHeader -Method Get -ContentType "application/json" -UseBasicParsing)
            }
            Catch {
                Write-Error $Error[0]
            }
            
            Write-Host "    [+] Conditional Access Policy Name: "  -ForegroundColor Green -NoNewline
            Write-Host $capResponse.displayName -ForegroundColor DarkCyan
            Write-Host "    [+] Conditional ID: "  -ForegroundColor Green -NoNewline
            Write-Host $capResponse.id -ForegroundColor DarkCyan
            Write-Host "    [+] Created Date Time: " -ForegroundColor Green -NoNewline
            Write-Host $capResponse.createdDateTime -ForegroundColor Yellow
            Write-Host "    [+] State: " -ForegroundColor Green -NoNewline
            Write-Host $capResponse.state -ForegroundColor Yellow
            Write-Host "    [+] Conditions" -ForegroundColor Green
            Write-Host "        [+] User Risk Levels: " -ForegroundColor Green -NoNewline
            Write-Host $capResponse.conditions.userRiskLevels -ForegroundColor Yellow
            Write-Host "        [+] Sign In Risk Levels: " -ForegroundColor Green -NoNewline
            Write-Host $capResponse.conditions.signInRiskLevels -ForegroundColor Yellow
            Write-Host "        [+] Client App Types: " -ForegroundColor Green -NoNewline
            Write-Host $capResponse.conditions.clientAppTypes -ForegroundColor Yellow
            Write-Host "        [+] Platforms: "  -ForegroundColor Green -NoNewline
            Write-Host $capResponse.conditions.platforms -ForegroundColor Yellow
            Write-Host "        [+] Devices: " -ForegroundColor Green -NoNewline
            Write-Host $capResponse.conditions.devices -ForegroundColor Yellow
            Write-Host "        [+] Client Applications: " -ForegroundColor Green -NoNewline
            Write-Host $capResponse.conditions.clientApplications -ForegroundColor Yellow
            Write-Host "        [+] Applications" -ForegroundColor Green
            Write-Host "            [+] Include Applications: " -ForegroundColor Green -NoNewline
            Write-Host $capResponse.conditions.Applications.includeApplications -ForegroundColor Yellow
            Write-Host "            [-] Exclude Applications: " -ForegroundColor Green -NoNewline
            Write-Host $capResponse.conditions.Applications.excludeApplications -ForegroundColor Yellow
            Write-Host "            [+] Include User Actions: " -ForegroundColor Green -NoNewline
            Write-Host $capResponse.conditions.Applications.includeUserActions -ForegroundColor Yellow
            Write-Host "            [+] Include Authentication Context Class References: " -ForegroundColor Green -NoNewline
            Write-Host $capResponse.conditions.Applications.includeAuthenticationContextClassReferences -ForegroundColor Yellow
            Write-Host "            [*] Application Filter: "  -ForegroundColor Green -NoNewline
            Write-Host $capResponse.conditions.Applications.applicationFilter -ForegroundColor Yellow
            Write-Host "        [+] Users" -ForegroundColor Green
            
 
            Write-Host "            [+] Include Users: " -ForegroundColor Green
            
            if ($capResponse.conditions.users.includeUsers -notcontains "None") {
                
                foreach ($includeUserId in $capResponse.conditions.users.includeUsers) {
                   
                    Try {
                        $IncludeuserInfo = (Invoke-RestMethod -Uri ($msGraphEndpoint + "/users/" + $includeUserId)  -Headers $httpAuthHeader -Method Get -UseBasicParsing)
                    }
                    Catch {
                        Write-Error $Error[0]
                    }
                }
                foreach ($includeUserName in $includeUserInfo) {
                    Write-Host "                [+]" $includeUserName.userPrincipalName -ForegroundColor Yellow 
                    Write-Host "                [+] ID:" $includeUserName.id -ForegroundColor Yellow
                }
            }
        
            ###################################################################################################
            $excludeUserIdInfo = $capResponse.conditions.users.excludeUsers
            Write-Host "            [-] Exclude Users: " -ForegroundColor Green
            foreach ($excludeUserId in $excludeUserIdInfo) {
                
                Try {
                    $excludeUserInfo = (Invoke-RestMethod -Uri ($msGraphEndpoint + "/users/" + $excludeUserId)  -Headers $httpAuthHeader -Method Get -UseBasicParsing)
                }
                Catch {
                    Write-Error $Error[0]
                }

            }
            foreach ($excludeUserName in $excludeUserInfo) {
                Write-Host "                [+]" $excludeUserInfo.userPrincipalName -ForegroundColor Yellow
                Write-Host "                [+] ID:" $excludeUserInfo.Id -ForegroundColor Yellow
            }
            
            ###################################################################################################
            Write-Host "            [+] Include Groups: " -ForegroundColor Green
        
            foreach ($capIncludeGId in $capResponse.conditions.users.includeGroups) {
                
                Try {
                    $capIncludeGroups = (Invoke-RestMethod -Uri ($msGraphEndpoint + "/groups/" + $capIncludeGId)  -Headers $httpAuthHeader -Method Get -UseBasicParsing)
                }
                Catch {
                    Write-Error $Error[0]
                }
                    
                Write-Host "                [+] Group Name: " -ForegroundColor Green -NoNewline
                Write-Host $capIncludeGroups.displayName -ForegroundColor Yellow
                Write-Host "                [+] Group ID: " -ForegroundColor Green -NoNewline
                Write-Host $capIncludeGroups.id -ForegroundColor Yellow
            }
                
            Write-Host "            [-] Exclude Groups: " -ForegroundColor Green
            foreach ($capExcludeGId in $capResponse.conditions.users.excludeGroups) {
            
                Try {
                    $capExcludeGroups = (Invoke-RestMethod -Uri ($msGraphEndpoint + "/groups/" + $capExcludeGId)  -Headers $httpAuthHeader -Method Get -UseBasicParsing)
                }
                Catch {
                    Write-Error $Error[0]
                }
                
                Write-Host "                [+] Group Name: " -ForegroundColor Green -NoNewline
                Write-Host $capExcludeGroups.displayName -ForegroundColor Yellow
                Write-Host "                [+] Group ID: " -ForegroundColor Green -NoNewline
                Write-Host $capExcludeGroups.id -ForegroundColor Yellow
            }

            Write-Host "            [+] Include Roles: " -ForegroundColor Green -NoNewline
            Write-Host $capResponse.conditions.users.includeRoles -ForegroundColor Yellow
            Write-Host "            [-] Exclude Roles: " -ForegroundColor Green -NoNewline
            Write-Host $capResponse.conditions.users.excludeRoles -ForegroundColor Yellow

            Write-Host "        [+] Locations" -ForegroundColor Green
            foreach ($includeLocationId in $capResponse.conditions.locations.includeLocations) {

                if ($includeLocationId -eq "All") {
                    Write-Host "            [+] Location:" -ForegroundColor Green -NoNewline
                    Write-Host $includeLocationId -ForegroundColor Yellow
                }
                elseif ($includeLocationId -eq "AllTrusted") {
                    Write-Host "            [+] Location:" -ForegroundColor Green -NoNewline
                    Write-Host $includeLocationId -ForegroundColor Yellow
                }
                else {
                    $includeNamedLocationInfoEndpoint = "https://graph.microsoft.com/beta/identity/conditionalAccess/namedLocations/" + $includeLocationId
                    Try {
                        $includeNamedLocationInfo = (Invoke-RestMethod -Uri $includeNamedLocationInfoEndpoint -Headers $httpAuthHeader -Method Get -UseBasicParsing)
                    }
                    Catch {
                        Write-Error $Error[0]
                    }

                    Write-Host "            [+] Include Locations: " -ForegroundColor Green
                    Write-Host "                [+] Location ID: " -ForegroundColor Green -NoNewline
                    Write-Host $includeNamedLocationInfo.id -ForegroundColor Yellow
                    Write-Host "                [+] Display Name: " -ForegroundColor Green -NoNewline
                    Write-Host $includeNamedLocationInfo.displayName -ForegroundColor Yellow
                    Write-Host "                [+] Countries and Regions: " -ForegroundColor Green -NoNewline
                    Write-Host $includeNamedLocationInfo.countriesAndRegions -ForegroundColor Yellow
                    Write-Host "                [+] Include Unknown Countries And Regions: " -ForegroundColor Green -NoNewline
                    Write-Host $includeNamedLocationInfo.includeUnknownCountriesAndRegions -ForegroundColor Yellow
                    Write-Host "                [+] Country Lookup Method: " -ForegroundColor Green -NoNewline
                    Write-Host $includeNamedLocationInfo.countryLookupMethod -ForegroundColor Yellow

                }

            }
            
            foreach ($excludeLocationId in $capResponse.conditions.locations.excludeLocations) {
            
                $excludeNamedLocationInfoEndpoint = "https://graph.microsoft.com/beta/identity/conditionalAccess/namedLocations/" + $excludeLocationId
                Try {
                    $excludeNamedLocationInfo = (Invoke-RestMethod -Uri $excludeNamedLocationInfoEndpoint -Headers $httpAuthHeader -Method Get -UseBasicParsing)
                }
                Catch {
                    Write-Error $Error[0]
                }
                Write-Host "            [+] Exclude Locations: " -ForegroundColor Green
                Write-Host "                [+] Location ID: " -ForegroundColor Green -NoNewline
                Write-Host $excludeNamedLocationInfo.id -ForegroundColor Yellow
                Write-Host "                [+] Display Name: " -ForegroundColor Green -NoNewline
                Write-Host $excludeNamedLocationInfo.displayName -ForegroundColor Yellow
                Write-Host "                [+] Countries and Regions: " -ForegroundColor Green -NoNewline
                Write-Host $excludeNamedLocationInfo.countriesAndRegions -ForegroundColor Yellow
                Write-Host "                [+] Include Unknown Countries And Regions: " -ForegroundColor Green -NoNewline
                Write-Host $excludeNamedLocationInfo.includeUnknownCountriesAndRegions -ForegroundColor Yellow
                Write-Host "                [+] Country Lookup Method: " -ForegroundColor Green -NoNewline
                Write-Host $excludeNamedLocationInfo.countryLookupMethod -ForegroundColor Yellow
               
            }
            Write-Host "    [+] Control Action" -ForegroundColor Green
            Write-Host "        [+] Built In Controls: " -ForegroundColor Green -NoNewline
            Write-Host $capResponse.grantControls.builtInControls -ForegroundColor Yellow
            Write-host "+======================================================================================+" -ForegroundColor Blue
        }
        Read-Host "[+] Press Enter/Return to exit to main menu."
        Menu
    }
    elseif ($ustOpt -eq 2) {

        Clear-Host
        Write-host "+======================================================================================+" -ForegroundColor Blue
        Write-Host @("
    @@@@@@@@@@@@@@&@@@@@@@@@@@@@@@
    @@@@@@@@@@@@@Y^7B@@@@@@@@@@@@@
    @@@@@@@@@@@P^:^!!?B@@@@@@@@@@@
    @@@@@@@@@B~::^^!7!!J#@@@@@@@@@
    @@@@@@@#7::^^^^!777775&@@@@@@@
    @@@@@&?::^^^^^^77??????P@@@@@@
    @@@&Y^::::::..:!7777????JG@@@@") -ForegroundColor Blue -NoNewline
        Write-Host "    [*] Manipulate Conditional Access Policies users [*]" -ForegroundColor Yellow
        Write-host @("    @@@Y:..........!!!!!!!!!7?G@@@
    B~!P#BY~.......!7!!!!7JG##GJJ#
    @#Y~^!5B#P!:...!!!?5B&#PJ?YG&@
    @@@@&P!^~JB#G?^?P#&B5??5B&@@@@
    @@@@@@@&G?^^7G#&GY?JP#@@@@@@@@
    @@@@@@@@@@@#J~^?YG&@@@@@@@@@@@
    @@@@@@@@@@@@@@#&@@@@@@@@@@@@@@
        ") -ForegroundColor Blue
        Write-host "+======================================================================================+" -ForegroundColor Blue

        $capPathEndpoint = "https://graph.microsoft.com/beta/identity/conditionalAccess/policies/"
        
        $body = @"
        {
            "conditions": {
                "users": {
                    "includeUsers": [
                        "None"
                    ]
                }
            }
        }
"@

        $capPatchId = Read-Host "Please insert the CAP ID"

        try {
            $removeUserRequest = (Invoke-RestMethod -Uri ($capPathEndpoint + $capPatchId) -Method Patch -Body $body -ContentType "application/json" -Headers $httpAuthHeader)
        }
        catch {
            Write-Warning $Error[0]
            Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        }
        $removeUserRequest
        Write-Host "    [+] All users removed!" -ForegroundColor Yellow
        Read-Host "[+] Press Enter/Return to exit to main menu"
        Menu
    }


    elseif ($ustOpt -eq 3) {
        Clear-Host
        Write-host "+======================================================================================+" -ForegroundColor Blue
        Write-host @("             
                .75GG###&&BPJ~        
            ..  !5YP&. .5@@@&~^       
           ^:  :B^^#@YG@@&@@B?!.  .   
         .!   ^..^JP@@@@@@@@#? ~^!?.  
        .#.   :G@@@@@@@@@@@@@^?Y5#5^. 
        G&.#&P@@@@@@@@@@@@@@&:      :.
        @@G7&@@@@@@@@@@@@@@@.        .") -NoNewline
        Write-Host "    [*] List Named Locations [*]" -ForegroundColor Yellow
        Write-host @("        @@@@##JP#@@@@@@@@@@@!         
        G@@@@.   :7&@@@@@@@@@#G#@G   :
        .&@@@^     .^?5&@@@@@@@@@@. . 
        .#@@@Y.      ^&@@@@@@@@@P .  
           ?@@@B    ~Y@@@@@@@@@@@?.   
             7B@? ?#@@@@@@@@@@@B7.    
               .~~P#&&@@&&#GJ^.       
        ")
        Write-host "+======================================================================================+" -ForegroundColor Blue
        $namedLocationEndpoint = "https://graph.microsoft.com/beta/identity/conditionalAccess/namedLocations/"
        Try {
            $NamedLocationIdInfo = (Invoke-RestMethod -Uri $namedLocationEndpoint -Headers $httpAuthHeader -Method Get -UseBasicParsing).value
        }
        Catch {
            Write-Error $Error[0]
        }

        foreach ($locationId in $NamedLocationIdInfo.id) {

            Try {
                $NamedLocationInfo = (Invoke-RestMethod -Uri ($namedLocationEndpoint + $locationId) -Headers $httpAuthHeader -Method Get -UseBasicParsing)
            }
            Catch {
                Write-Error $Error[0]
            }
  
            Write-Host "    [+] Location ID: " -ForegroundColor Green -NoNewline
            Write-Host $NamedLocationInfo.id -ForegroundColor Yellow
            Write-Host "    [+] Display Name: " -ForegroundColor Green -NoNewline
            Write-Host $NamedLocationInfo.displayName -ForegroundColor Yellow
            Write-Host "    [+] Countries and Regions: " -ForegroundColor Green -NoNewline
            Write-Host $NamedLocationInfo.countriesAndRegions -ForegroundColor Yellow
            Write-Host "    [+] Include Unknown Countries And Regions: " -ForegroundColor Green -NoNewline
            Write-Host $NamedLocationInfo.includeUnknownCountriesAndRegions -ForegroundColor Yellow
            Write-Host "    [+] Country Lookup Method: " -ForegroundColor Green -NoNewline
            Write-Host $NamedLocationInfo.countryLookupMethod -ForegroundColor Yellow
            Write-Host "    [+] Trusted location: " -ForegroundColor Green -NoNewline
            Write-Host $NamedLocationInfo.isTrusted -ForegroundColor Yellow
            Write-Host "    [+] IP Ranges: " -ForegroundColor Green -NoNewline
            Write-Host $NamedLocationInfo.ipRanges.cidrAddress -ForegroundColor Yellow
            Write-host "+======================================================================================+" -ForegroundColor Blue
        }
        Read-Host "[+] Press Enter/Return to exit to main menu"
        Menu
    }
    elseif ($ustOpt -eq 4) {

        Write-host "+======================================================================================+" -ForegroundColor Blue
        Write-host @("             
                .75GG###&&BPJ~        
            ..  !5YP&. .5@@@&~^       
           ^:  :B^^#@YG@@&@@B?!.  .   
         .!   ^..^JP@@@@@@@@#? ~^!?.  
        .#.   :G@@@@@@@@@@@@@^?Y5#5^. 
        G&.#&P@@@@@@@@@@@@@@&:      :.
        @@G7&@@@@@@@@@@@@@@@.        .") -NoNewline
        Write-Host "    [*] Modify a Named Location country and region [*]" -ForegroundColor Yellow
        Write-host @("        @@@@##JP#@@@@@@@@@@@!         
        G@@@@.   :7&@@@@@@@@@#G#@G   :
        .&@@@^     .^?5&@@@@@@@@@@. . 
        .#@@@Y.      ^&@@@@@@@@@P .  
           ?@@@B    ~Y@@@@@@@@@@@?.   
             7B@? ?#@@@@@@@@@@@B7.    
               .~~P#&&@@&&#GJ^.       
        ")
        Write-host "+======================================================================================+" -ForegroundColor Blue
        $namedLocationEndpoint = "https://graph.microsoft.com/beta/identity/conditionalAccess/namedLocations/"
        $updateNamedLocationId = Read-Host "[+] Please insert the named location ID"

        Try {
            $updateNamedLocationIdInfo = (Invoke-RestMethod -Uri ($namedLocationEndpoint + $updateNamedLocationId) -Headers $httpAuthHeader -Method Get -UseBasicParsing)
        }
        Catch {
            Write-Error $Error[0]
        }
        
        Write-Host "[+] The current countries and regions are: " -ForegroundColor Yellow -NoNewline
        Write-Host $updateNamedLocationIdInfo.countriesAndRegions -ForegroundColor Red

        Write-Host '[+] Please insert the two-letter countrie code specified by ISO 3166-2. Example: "BR", "US", "AL", "DE"' -ForegroundColor Yellow
        $newRegionValue = Read-Host '[*]'
        
        $body = @"
        {
            "@odata.type": "#microsoft.graph.countryNamedLocation",
            "countriesAndRegions": [
                $newRegionValue
            ],
            "includeUnknownCountriesAndRegions": false
        }
"@

        Try {
            $updateNamedLocationIdInfo = (Invoke-RestMethod -Uri ($namedLocationEndpoint + $updateNamedLocationId) -Headers $httpAuthHeader -Method Patch -Body $body -UseBasicParsing -ContentType "application/json")
        }
        Catch {
            Write-Error $Error[0]
        }


        Try {
            $updateNamedLocationIdInfo = (Invoke-RestMethod -Uri ($namedLocationEndpoint + $updateNamedLocationId) -Headers $httpAuthHeader -Method Get -UseBasicParsing)
        }
        Catch {
            Write-Error $Error[0]
        }
        
        Write-Host "[+] The new countries and regions are: " -ForegroundColor Yellow -NoNewline
        Write-Host $updateNamedLocationIdInfo.countriesAndRegions -ForegroundColor Red
        Write-Host "[+] Done!"

        Read-Host "[+] Press Enter/Return to exit to main menu"
        Menu
    }
}

Add-AzConditionalAccessPolicy