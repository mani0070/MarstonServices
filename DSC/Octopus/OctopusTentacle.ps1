xFirewall OctopusDeployTentacle
{
    Name                  = "OctopusTentacle"
    DisplayName           = "Octopus Deploy Tentacle"
    Ensure                = "Present"
    Enabled               = "True"
    Action                = "Allow"
    Profile               = "Any"
    Direction             = "InBound"
    LocalPort             = "10933"
    Protocol              = "TCP"
}
xRemoteFile OctopusDeployTentacle
{
    Uri = 'https://octopus.com/downloads/latest/WindowsX64/OctopusTentacle'
    DestinationPath = 'D:\OctopusDeployTentacle.msi'
    MatchSource = $false
}
xPackage OctopusDeployTentacle
{
    Ensure = 'Present'
    Name = 'Octopus Deploy Tentacle'
    Path  = 'D:\OctopusDeployTentacle.msi'
    ProductId = 'DF4D8B4C-A3CD-42EF-B33D-B611027C505D'
    Arguments = "/quiet /l*v `"D:\OctopusDeployTentacle.log`""
    ReturnCode = 0
    DependsOn = "[xRemoteFile]OctopusDeployTentacle"
}
Script OctopusTentacleWatchdog
{
    SetScript = {
        & (Join-Path $env:ProgramFiles 'Octopus Deploy\Tentacle\Tentacle.exe') watchdog --create --instances * --interval=5 *>&1 | Write-Verbose
        if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from Octopus Watchdog" }
    }
    TestScript = { $null -ne (Get-ScheduledTask -TaskName 'Octopus Watchdog Tentacle' -ErrorAction Ignore) }
    GetScript = { @{} }
    DependsOn = "[xPackage]OctopusDeployTentacle"
}
# $octopusConfigStateFile = Join-Path $octopusDeployRoot 'config.statefile'
# $octopusConfigLogFile = Join-Path $octopusDeployRoot "OctopusTentacle.config.log"
# Script OctopusDeployConfiguration
# {
#     SetScript = {
#         $octopusTentacleExe = Join-Path $env:ProgramFiles 'Octopus Deploy\Tentacle\Tentacle.exe'

#         & $octopusTentacleExe create-instance --console --instance "Tentacle" --config "C:\Octopus\Tentacle.config" *>&1 | Tee-Object -Append -FilePath $using:octopusConfigLogFile
#         if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from Octopus Tentacle: create-instance" }
#         & $octopusTentacleExe new-certificate --console --instance "Tentacle" *>&1 | Tee-Object -Append -FilePath $using:octopusConfigLogFile
#         if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from Octopus Tentacle: new-certificate" }
#         & $octopusTentacleExe configure --console --instance "Tentacle" --reset-trust *>&1 | Tee-Object -Append -FilePath $using:octopusConfigLogFile
#         if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from Octopus Tentacle: reset-trust" }
#         & $octopusTentacleExe configure --console --instance "Tentacle" --home "C:\Octopus" --app "C:\Octopus\Applications" --port "10933" --noListen "False" *>&1 | Tee-Object -Append -FilePath $using:octopusConfigLogFile
#         if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from Octopus Tentacle: configure" }
#         & $octopusTentacleExe register-with --console --instance "Tentacle" --server $using:TentacleRegistrationUri --apikey="$($using:TentacleRegistrationApiKey)"  --role="$($using:Node.Octopus.Role)" --environment="$($using:Node.Octopus.Environment)" --name="$($using:Node.Octopus.Name)" --comms-style TentaclePassive --Force *>&1 | Tee-Object -Append -FilePath $using:octopusConfigLogFile
#         if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from Octopus Tentacle: register-with" }
#         & $octopusTentacleExe service --console --instance "Tentacle" --install --start *>&1 | Tee-Object -Append -FilePath $using:octopusConfigLogFile
#         if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from Octopus Tentacle: service" }
        
#         [System.IO.FIle]::WriteAllText($using:octopusConfigStateFile, $LASTEXITCODE,[System.Text.Encoding]::ASCII)
#     }
#     TestScript = {
#         ((Test-Path $using:octopusConfigStateFile) -and ([System.IO.FIle]::ReadAllText($using:octopusConfigStateFile).Trim()) -eq '0')
#     }
#     GetScript = { @{} }
#     DependsOn = @('[xFirewall]OctopusDeployTentacle','[Script]OctopusTentacleInstall')
# }

# $watchdogExe = Join-Path $env:ProgramFiles 'Octopus Deploy\Tentacle\Tentacle.exe'
# #include <Octopus\OctopusWatchdog>

# #include <Octopus\ServiceAccount>

# Service Tentacle
# {
#     Name        =  'OctopusDeploy Tentacle'
#     Credential  = $octopusServiceAccount
#     StartupType = 'Automatic'
#     DependsOn = @('[User]OctopusServiceAccount','[Script]OctopusDeployConfiguration')
# }

# xFileSystemAccessRule OctopusConfigFile {
#     Path = "$($env:SystemDrive)\Octopus\"
#     Identity = $octopusServiceAccountUsername
#     Rights = @("FullControl")
#     DependsOn = @('[User]OctopusServiceAccount','[Script]OctopusDeployConfiguration')
# }

# $octopusServiceStartedStateFile = Join-Path $octopusDeployRoot 'service.statefile'
# Script OctopusTentacleServiceStart
# {
#     SetScript = {
#         Stop-Service 'OctopusDeploy Tentacle' -Force -Verbose | Write-Verbose
#         if ((Get-Service 'OctopusDeploy Tentacle' | % Status) -eq "Running") {
#             Stop-Process -Name Tentacle -Force -Verbose | Write-Verbose
#         }
#         Start-Service 'OctopusDeploy Tentacle' -Verbose | Write-Verbose

#         [System.IO.FIle]::WriteAllText($using:octopusServiceStartedStateFile, (Get-Service 'OctopusDeploy Tentacle' | % Status),[System.Text.Encoding]::ASCII)
#     }
#     TestScript = {
#         ((Test-Path $using:octopusServiceStartedStateFile) -and ([System.IO.FIle]::ReadAllText($using:octopusServiceStartedStateFile).Trim()) -eq 'Running')
#     }
#     GetScript = { @{} }
#     DependsOn = @('[xFirewall]OctopusDeployTentacle','[Service]Tentacle','[Script]OctopusDeployConfiguration','[User]OctopusServiceAccount','[Script]SetOctopusUserGroups','[xFileSystemAccessRule]OctopusConfigFile')
# }