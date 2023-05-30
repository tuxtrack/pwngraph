
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
    $region = Read-Host "[+] Please insert the Azure location"
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
                  'queryString': '$keyword AND isDocument=true'
              },
              'fields': [
              ],
              'from': 0,
              'size': 999,
              'region': '$region'
          }
      ]
    }
    ")
  
    $searchResult = (Invoke-RestMethod -Uri ($msGraphEndpoint + $searchEndpoint) -Method 'Post' -Body $body -Headers $HttpAuthHeader -ContentType 'application/json').value
    $searchResult.hitsContainers.hits | Select-Object summary, resource | Format-List

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