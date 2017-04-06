xFirewall OctopusDeployServer
{
    Name                  = "OctopusServer"
    DisplayName           = "Octopus Deploy Server"
    Ensure                = "Present"
    Enabled               = "True"
    Action                = "Allow"
    Profile               = "Any"
    Direction             = "InBound"
    LocalPort             = "10943"
    Protocol              = "TCP"
}

$octopusDeployServiceCredential = Get-AutomationPSCredential -Name OctopusDeploy
New-ServiceAccount $octopusDeployServiceCredential

xRemoteFile OctopusDeployServer
{
    Uri = 'https://octopus.com/downloads/latest/WindowsX64/OctopusServer'
    DestinationPath = 'D:\Installers\OctopusDeployServer.msi'
    MatchSource = $false
}
xPackage OctopusDeployServer
{
    Ensure = 'Present'
    Name = 'Octopus Deploy Server'
    Path  = 'D:\Installers\OctopusDeployServer.msi'
    ProductId = ''
    Arguments = "/quiet /l*v `"D:\Installers\OctopusDeployServer.log`""
    ReturnCode = 0
    DependsOn = "[xRemoteFile]OctopusDeployServer"
}

Script OctopusDeployConfiguration
{
    SetScript = {
        function Invoke-OctopusServer {
            param(
                [Parameter(Position=0, Mandatory)][ValidateSet('create-instance','configure','path','license','service')]$Command,
                [Parameter(Position=1, Mandatory)]$Arguments
            )
            $octopusServer = Join-Path $env:ProgramFiles 'Octopus Deploy\Octopus\Octopus.Server.exe' -Resolve

            & $octopusServer $Command --console --instance OctopusServer @Arguments *>&1 | Write-Verbose
            if ($LASTEXITCODE -ne 0) {
                throw "Octopus Server $Command exit code $LASTEXITCODE"
            }
        }
        & netsh.exe --% http delete sslcert ipport=0.0.0.0:443
        & netsh.exe --% http add sslcert ipport=0.0.0.0:443 appid={E2096A4C-2391-4BE1-9F17-E353F930E7F1} certhash=1051675930C82BFFA18281E8D8EA70EB993267D0 certstorename=My
        if ($LASTEXITCODE -ne 0) {
            throw "netsh.exe exit code $LASTEXITCODE"
        }

        Invoke-OctopusServer create-instance @('--config', "$($env:SystemDrive)\Octopus\OctopusServer.config")
        Invoke-OctopusServer configure @(   '--home', 'C:\Octopus', 
                                            '--storageConnectionString', $using:OctopusConnectionString, 
                                            '--upgradeCheck', 'True', `
                                            '--upgradeCheckWithStatistics', 'True', `
                                            '--webAuthenticationMode', 'UsernamePassword', `
                                            '--webForceSSL', 'False', `
                                            '--webListenPrefixes', 'https://octopus.services.marston.me,http://localhost:1986', `
                                            '--commsListenPort', '10943', `
                                            '--serverNodeName', 'Services Web', `
                                            '--masterKey', $using:OctopusMasterKey)
        Invoke-OctopusServer path @('--artifacts', "\\$($using:AzureStorageAccountName).file.core.windows.net\octopusdeploy\Artifacts")
        Invoke-OctopusServer path @('--taskLogs', "\\$($using:AzureStorageAccountName).file.core.windows.net\octopusdeploy\TaskLogs")
        Invoke-OctopusServer path @('--nugetRepository', "\\$($using:AzureStorageAccountName).file.core.windows.net\octopusdeploy\Packages")
        Invoke-OctopusServer license @('--licenseBase64', [System.Convert]::ToBase64String(((New-Object System.Text.UTF8Encoding($false)).GetBytes((Invoke-WebRequest -UseBasicParsing -Uri "https://octopusdeploy.com/api/licenses/trial" -Method Post -Body @{
            FullName=$env:USERNAME
            Organization=$env:USERDOMAIN
            EmailAddress="${env:USERNAME}@${env:USERDOMAIN}.onmicrosoft.com"
            Source="azure"
        }).Content))))
        Invoke-OctopusServer service @('--install', '--reconfigure', '--stop')
    }
    TestScript = { $null -ne (Get-Service OctopusDeploy -ErrorAction Ignore) }
    GetScript = { @{} }
    PsDscRunAsCredential = $octopusDeployServiceCredential
    DependsOn = '[xPackage]OctopusDeployServer'
}
Service OctopusDeploy
{
    Name        = 'OctopusDeploy'
    Credential  = $octopusDeployServiceCredential
    StartupType = 'Automatic'
    State       = 'Running'
    DependsOn = @('[Script]SetOctopusDeployUserGroups','[Script]OctopusDeployConfiguration','[Script]SetOctopusDeployAzureFileshareCmdkey')
} 
Script OctopusServerWatchdog
{
    SetScript = {
        & (Join-Path $env:ProgramFiles 'Octopus Deploy\Octopus\Octopus.Server.exe') watchdog --console --create --instances * --interval=5 *>&1 | Write-Verbose
        if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from Octopus Watchdog" }
    }
    TestScript = { $null -ne (Get-ScheduledTask -TaskName 'Octopus Watchdog OctopusServer' -ErrorAction Ignore) }
    GetScript = { @{} }
    DependsOn = '[Service]OctopusDeploy'
}