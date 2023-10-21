
Function Get-KeywordSearch {

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
    Write-Host "    [*] Keyword Search [*]" -ForegroundColor Yellow
    Write-host @("        @@@@##JP#@@@@@@@@@@@!         
        G@@@@.   :7&@@@@@@@@@#G#@G   :
        .&@@@^     .^?5&@@@@@@@@@@. . 
        .#@@@Y.      ^&@@@@@@@@@P .  
           ?@@@B    ~Y@@@@@@@@@@@?.   
             7B@? ?#@@@@@@@@@@@B7.    
               .~~P#&&@@&&#GJ^.       
        ")
    Write-host "+======================================================================================+" -ForegroundColor Blue

    $keyword = Read-Host "[+] Please insert the keyword"
    $searchEndpoint = "/search/query"
    
    $body = @("
    {
      'requests': [
          {
              'entityTypes': [
                  'site',
                  'driveItem',
                  'listItem',
                  'list'
              ],
              'query': {
                  'queryString': '$keyword'
              },
              'from': 0,
              'size': 501,
              'region': 'location'
          }
      ]
    }
    ")
    try {
        (Invoke-RestMethod -Uri ($msGraphEndpoint + $searchEndpoint) -Method 'Post' -Body $body -Headers $HttpAuthHeader -ContentType 'application/json').value
    }
    catch {
        $regionResponse = $_.ErrorDetails.Message
    }

    $pattern = 'are(.*?)."'
    $regionCode = ([regex]::Match($regionResponse, $pattern).Groups[1].value).Replace(" ", "")
    $body = $body -replace "location", $regionCode

    try {
        $searchResult = (Invoke-RestMethod -Uri ($msGraphEndpoint + $searchEndpoint) -Method 'Post' -Body $body -Headers $HttpAuthHeader -ContentType 'application/json').value
    }
    catch {
        $regionResponse = $_.ErrorDetails.Message
    }

    if ($searchResult.hitsContainers.hits.hitId.count -lt 1) {
        Write-Host "    [+] Unfortunately, no documents related to the search were found." -ForegroundColor Yellow

    }

    elseif ($searchResult.hitsContainers.hits.hitId.count -gt 1) {

        for ($i = 0; $i -lt $searchResult.hitsContainers.hits.hitId.count; $i++) {

            Write-Host "    [*] File Name: " -ForegroundColor Yellow -NoNewline
            Write-Host $searchResult.hitsContainers.hits.resource.name[$i] -ForegroundColor Green
            Write-Host "    [*] Created by: " -ForegroundColor Yellow -NoNewline
            Write-Host $searchResult.hitsContainers.hits.resource.createdBy.user.displayName[$i] -ForegroundColor Green
            Write-Host "    [*] Sumary: " -ForegroundColor Yellow -NoNewline
            Write-Host $searchResult.hitsContainers.hits.summary[$i] -ForegroundColor Green
            Write-Host "    [*] Web URL: " -ForegroundColor Yellow -NoNewline
            Write-Host $searchResult.hitsContainers.hits.resource.webUrl[$i] -ForegroundColor Green
        
            $siteId = $searchResult.hitsContainers.hits.resource.parentReference.siteId[$i].Split(",")[1]
            $listId = $searchResult.hitsContainers.hits.resource.parentReference.sharepointIds.listId[$i]
            $itemId = $searchResult.hitsContainers.hits.resource.parentReference.sharepointIds.listItemUniqueId[$i]
            $fileName = $searchResult.hitsContainers.hits.resource.name[$i]
            
            $itemEndpoint = "/sites/$siteId/lists/$listId/items/$itemID/driveItem/?select=id,@microsoft.graph.downloadUrl"
            $fileURL = (Invoke-RestMethod -Uri ($msGraphEndpoint + $itemEndpoint) -Method Get -Headers $HttpAuthHeader).'@microsoft.graph.downloadUrl'
            $ProgressPreference = 'SilentlyContinue'
            Invoke-WebRequest -URI $fileURL -OutFile ./Downloads/$fileName | Out-Null

            Write-Host "    [+] File $($fileName) saved at: " -ForegroundColor Yellow -NoNewline
            Write-Host "$(Get-Location)/Downloads/$($fileName)"  -ForegroundColor Green
            Write-Host "[+]--------------------------------------------------------------------------------------------------------[+]" 
        }
    }
    
    else {

        Write-Host "    [*] File Name: " -ForegroundColor Yellow -NoNewline
        Write-Host $searchResult.hitsContainers.hits.resource.name -ForegroundColor Green
        Write-Host "    [*] Created by: " -ForegroundColor Yellow -NoNewline
        Write-Host $searchResult.hitsContainers.hits.resource.createdBy.user.displayName -ForegroundColor Green
        Write-Host "    [*] Sumary: " -ForegroundColor Yellow -NoNewline
        Write-Host $searchResult.hitsContainers.hits.summary -ForegroundColor Green
        Write-Host "    [*] Web URL: " -ForegroundColor Yellow -NoNewline
        Write-Host $searchResult.hitsContainers.hits.resource.webUrl -ForegroundColor Green
        
        $siteId = $searchResult.hitsContainers.hits.resource.parentReference.siteId.Split(",")[1]
        $listId = $searchResult.hitsContainers.hits.resource.parentReference.sharepointIds.listId
        $itemId = $searchResult.hitsContainers.hits.resource.parentReference.sharepointIds.listItemUniqueId
        $fileName = $searchResult.hitsContainers.hits.resource.name

        $itemEndpoint = "/sites/$siteId/lists/$listId/items/$itemID/driveItem/?select=id,@microsoft.graph.downloadUrl"
        $fileURL = (Invoke-RestMethod -Uri ($msGraphEndpoint + $itemEndpoint) -Method Get -Headers $HttpAuthHeader).'@microsoft.graph.downloadUrl'
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -URI $fileURL -OutFile ./Downloads/$fileName

        Write-Host "    [+] File $($fileName) saved at: " -ForegroundColor Yellow -NoNewline
        Write-Host "$(Get-Location)/Downloads/$($fileName)"  -ForegroundColor Green
        Write-Host "[+]--------------------------------------------------------------------------------------------------------[+]" 
        
    }
    
    $reDo = Read-Host "[+] To initiate a new search, type "Yes". If you wish to return to the main menu, simply press the Enter or Return key."
    if ($reDo -eq 'Yes') {
        Get-KeywordSearch
    }
    else {
        Clear-Host
        Menu
    }
}
Get-KeywordSearch