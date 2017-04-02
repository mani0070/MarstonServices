Write-Host "#{ConnectionString}"
& C:\ProGet\DbChangeScripter\bmdbupdate.exe UPDATE /init=false /conn="#{ConnectionString}"
if ($LASTEXITCODE -ne 0) { throw "bmdbupdate.exe $LASTEXITCODE" }
& C:\ProGet\Service\ProGet.Service.exe install
if ($LASTEXITCODE -ne 0) { throw "bmdbupdate.exe $LASTEXITCODE" }
Start-Service INEDOPROGETSVC -Verbose