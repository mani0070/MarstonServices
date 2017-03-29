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

New-ServiceAccount OctopusDeploy

# $OctopusUrlAcl = 'https://octopus.services.marston.me:443/'
# $octopusDeployServiceCredentialUsername = $octopusDeployServiceCredential.UserName
# Script OctopusDeployUrlAcl
# {
#     SetScript = {
#         $username = '{0}\{1}' -f [System.Environment]::MachineName, $using:octopusDeployServiceCredentialUsername
#         & $netsh http add urlacl url='https://octopus.services.marston.me:443/' user=$username *>&1 |  Write-Verbose
#         if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from netsh add urlacl" }
#     }
#     TestScript = { $null -ne (& netsh.exe http show urlacl 'https://octopus.services.marston.me:443/' | ? { $_ -like "*Reserved URL* ${using:OctopusUrlAcl}*" }) }
#     GetScript = { @{} }
#     DependsOn = '[User]OctopusServiceAccount'
# }

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
    ProductId = 'E4B740A5-B2E1-45EB-AB43-DA071BEFC579'
    Arguments = "/quiet /l*v `"D:\OctopusDeployServer.log`""
    ReturnCode = 0
    DependsOn = "[xRemoteFile]OctopusDeployServer"
}

$octopusDeployServiceCredential = Get-AutomationPSCredential -Name OctopusDeploy
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

        Invoke-OctopusServer create-instance @('--config', "$($env:SystemDrive)\Octopus\OctopusServer.config")
        Invoke-OctopusServer configure @(   '--home', 'C:\Octopus', 
                                            '--storageConnectionString', $using:OctopusConnectionString, 
                                            '--upgradeCheck', 'True', `
                                            '--upgradeCheckWithStatistics', 'True', `
                                            '--webAuthenticationMode', 'UsernamePassword', `
                                            '--webForceSSL', 'True', `
                                            '--webListenPrefixes', 'https://octopus.services.marston.me,http://localhost:1942', `
                                            '--commsListenPort', '10943', `
                                            '--serverNodeName', $env:COMPUTERNAME, `
                                            '--masterKey', $using:OctopusMasterKey)
        Invoke-OctopusServer path @('--artifacts', "\\${using:AzureStorageAccountName}.file.core.windows.net\octopusdeploy\Artifacts")
        Invoke-OctopusServer path @('--taskLogs', "\\${using:AzureStorageAccountName}.file.core.windows.net\octopusdeploy\TaskLogs")
        Invoke-OctopusServer path @('--nugetRepository', "\\${using:AzureStorageAccountName}.file.core.windows.net\octopusdeploy\Packages")
        Invoke-OctopusServer license @('--licenseBase64', [System.Convert]::ToBase64String(((New-Object System.Text.UTF8Encoding($false)).GetBytes((Invoke-WebRequest -UseBasicParsing -Uri "https://octopusdeploy.com/api/licenses/trial" -Method Post -Body @{
            FullName=$env:USERNAME
            Organization=$env:USERDOMAIN
            EmailAddress="${env:USERNAME}@${env:USERDOMAIN}.onmicrosoft.com"
            Source="azure"
        }).Content))))
        Invoke-OctopusServer service @( '--install', '--reconfigure', '--stop')
    }
    TestScript = { $null -ne (Get-Service OctopusDeploy -ErrorAction Ignore) }
    GetScript = { @{} }
    PsDscRunAsCredential = $octopusDeployServiceCredential
    DependsOn = @('[xPackage]OctopusDeployServer')#,'[Script]OctopusDeployUrlAcl')
}
Service OctopusDeploy
{
    Name        = 'OctopusDeploy'
    Credential  = $octopusDeployServiceCredential
    StartupType = 'Automatic'
    State       = 'Running'
    DependsOn = @('[User]OctopusServiceAccount','[Script]OctopusDeployConfiguration')
} 
Script OctopusServerWatchdog
{
    SetScript = {
        & (Join-Path $env:ProgramFiles 'Octopus Deploy\Octopus\Octopus.Server.exe') watchdog --create --instances * --interval=5 *>&1 | Write-Verbose
        if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from Octopus Watchdog" }
    }
    TestScript = { $null -ne (Get-ScheduledTask -TaskName 'Octopus Watchdog OctopusServer' -ErrorAction Ignore) }
    GetScript = { @{} }
    DependsOn = @('[Script]OctopusDeployConfiguration','[Service]OctopusDeploy')
}