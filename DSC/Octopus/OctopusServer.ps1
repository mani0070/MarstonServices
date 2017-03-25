xFirewall OctopusDeployServer
{
    Name                  = "OctopusServer"
    DisplayName           = "Octopus Deploy Server"
    Ensure                = "Present"
    Enabled               = "True"
    Action                = "Allow"
    Profile               = "Any"
    Direction             = "InBound"
    LocalPort             = ("80", "10943")
    Protocol              = "TCP"
}
xRemoteFile OctopusDeployServer
{
    Uri = 'https://octopus.com/downloads/latest/WindowsX64/OctopusServer'
    DestinationPath = 'D:\OctopusDeployServer.msi'
    MatchSource = $false
}
xPackage OctopusDeployServer
{
    Ensure = 'Present'
    Name = 'Octopus Deploy Server'
    Path  = 'D:\OctopusDeployServer.msi'
    ProductId = ''
    Arguments = "/quiet /l*v `"D:\OctopusDeployServer.log`""
    ReturnCode = 0
    DependsOn = "[xRemoteFile]OctopusDeployServer"
}

#         $octopusConfigStateFile = Join-Path $octopusDeployRoot 'configuration.statefile'
#         $octopusConfigLogFile = Join-Path $octopusDeployRoot "OctopusServer.$OctopusVersionToInstall.config.log"
#         Script OctopusDeployConfiguration
#         {
#             SetScript = {
#                 $hostHeader = 'http://{0}/' -f $using:OctopusHostName
#                 $octopusServerExe = Join-Path $env:ProgramFiles 'Octopus Deploy\Octopus\Octopus.Server.exe'

#                 & $octopusServerExe create-instance --console --instance OctopusServer --config "$($env:SystemDrive)\Octopus\OctopusServer.config" *>&1 | Tee-Object -Append -FilePath $using:octopusConfigLogFile
#                 if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from Octopus Server: create-instance" }
#                 & $octopusServerExe configure --console --instance OctopusServer --home "C:\Octopus" --storageConnectionString $using:OctopusConnectionString --upgradeCheck "True" --upgradeCheckWithStatistics "True" --webAuthenticationMode "UsernamePassword" --webForceSSL "False" --webListenPrefixes $hostHeader --commsListenPort "10943" --serverNodeName $using:OctopusNodeName *>&1 | Tee-Object -Append -FilePath $using:octopusConfigLogFile
#                 if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from Octopus Server: configure" }
#                 & $octopusServerExe database --console --instance OctopusServer --create *>&1 | Tee-Object -Append -FilePath $using:octopusConfigLogFile
#                 if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from Octopus Server: database" }
                
#                 $response = Invoke-WebRequest -UseBasicParsing -Uri "https://octopusdeploy.com/api/licenses/trial" -Method POST -Body @{ FullName=$env:USERNAME; Organization=$env:USERDOMAIN; EmailAddress="${env:USERNAME}@${env:USERDOMAIN}.onmicrosoft.com"; Source="azure" } -Verbose
#                 $licenseBase64 = [System.Convert]::ToBase64String(((New-Object System.Text.UTF8Encoding($false)).GetBytes($response.Content)))
#                 & $octopusServerExe license --console --instance OctopusServer --licenseBase64 $licenseBase64 *>&1 | Tee-Object -Append -FilePath $using:octopusConfigLogFile
#                 if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from Octopus Server: license" }

#                 & $octopusServerExe service --console --instance OctopusServer --install --reconfigure --stop *>&1 | Tee-Object -Append -FilePath $using:octopusConfigLogFile
#                 if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from Octopus Server: service" }

#                 [System.IO.FIle]::WriteAllText($using:octopusConfigStateFile, $LASTEXITCODE,[System.Text.Encoding]::ASCII)
#             }
#             TestScript = {
#                 ((Test-Path $using:octopusConfigStateFile) -and ([System.IO.FIle]::ReadAllText($using:octopusConfigStateFile).Trim()) -eq '0')
#             }
#             GetScript = { @{} }
#             DependsOn = '[Script]OctopusDeployInstall'
        # }

        # $watchdogExe = Join-Path $env:ProgramFiles 'Octopus Deploy\Octopus\Octopus.Server.exe'