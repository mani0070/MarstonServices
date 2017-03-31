
& C:\ProGet\DbChangeScripter\bmdbupdate.exe UPDATE /init=false /conn="#{ConnectionString}"
& C:\ProGet\Service\ProGet.Service.exe install
iis
transform 2 config
service