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
    ProductId = '267B9530-1A47-4BF7-98BF-B37CC49B0C3D'
    Arguments = "/quiet /l*v `"D:\OctopusDeployTentacle.log`""
    ReturnCode = 0
    DependsOn = "[xRemoteFile]OctopusDeployTentacle"
}
Script OctopusDeployTentacleConfiguration
{
    SetScript = {
        function Invoke-OctopusTentacle {
            param(
                [Parameter(Position=0, Mandatory)][ValidateSet('create-instance','new-certificate','configure','register-with','service','watchdog')]$Command,
                [Parameter(Position=1, Mandatory)]$Arguments
            )
            $tentacle = Join-Path $env:ProgramFiles 'Octopus Deploy\Tentacle\Tentacle.exe' -Resolve

            & $tentacle $Command --console --instance Tentacle @Arguments *>&1 | Write-Verbose
            if ($LASTEXITCODE -ne 0) {
                throw "Tentacle $Command exit code $LASTEXITCODE"
            }
        }

        Invoke-OctopusTentacle create-instance @('--config', "$($env:SystemDrive)\Octopus\Tentacle.config")
        Invoke-OctopusTentacle new-certificate @('--if-blank')
        Invoke-OctopusTentacle configure @( '--home', 'C:\Octopus', 
                                            '--app', 'C:\Octopus\Applications',
                                            '--port', '10933',
                                            '--noListen', 'False')
        Invoke-OctopusTentacle configure @( '--reset-trust')
        Invoke-OctopusTentacle configure @( '--trust', '4793C33E7629917F9289FA64EE4F1FFFD63E751E')
        Invoke-OctopusTentacle register-with @( '--server', "http://localhost:1986/",
                                                '--apikey', "API-CPC5WKFFPGXSNOKDYRSDND1BDWE",
                                                '--name', "Services Web",
                                                '--environment', "Microsoft Azure",
                                                '--role', "Service Server",
                                                '--role', "Azure Automation",
                                                '--tenanttag', "Deployment Style/Environment Deployment",
                                                '--tenanttag', "Deployment Style/Tenant Deployment", 
                                                '--comms-style', "TentaclePassive",
                                                '--force')
        Invoke-OctopusTentacle service @('--install', '--reconfigure', '--stop')
    }
    TestScript = { $null -ne (Get-Service 'OctopusDeploy Tentacle' -ErrorAction Ignore) }
    GetScript = { @{} }
    DependsOn = @('[xPackage]OctopusDeployTentacle')
}
Service OctopusDeployTentacle
{
    Name        = 'OctopusDeploy Tentacle'
    State       = 'Running'
    DependsOn   = @('[Script]OctopusDeployTentacleConfiguration','[Service]OctopusDeploy')
}
Script OctopusDeployTentacleWatchdog
{
    SetScript = {
        & (Join-Path $env:ProgramFiles 'Octopus Deploy\Tentacle\Tentacle.exe') watchdog --console --create --instances * --interval=5 *>&1 | Write-Verbose
        if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from Octopus Watchdog" }
    }
    TestScript = { $null -ne (Get-ScheduledTask -TaskName 'Octopus Watchdog Tentacle' -ErrorAction Ignore) }
    GetScript = { @{} }
    DependsOn = "[Service]OctopusDeployTentacle"
}
