xFirewall TeamCityAgentFirewall
{
    Name                  = "TeamCityAgent"
    DisplayName           = "TeamCity Agent"
    Ensure                = "Present"
    Enabled               = "True"
    Action                = "Allow"
    Profile               = "Any"
    Direction             = "InBound"
    LocalPort             = "9090"
    Protocol              = "TCP"
}

File TeamCityAgentInstall
{
    DestinationPath = "$($env:SystemDrive)\buildAgent"
    Recurse = $true
    SourcePath = 'D:\TeamCity\buildAgent'
    Type = 'Directory'
    MatchSource = $false
    DependsOn = '[Script]TeamCityExtract'
}

Script TeamCityAgentConfig
{
    SetScript = {
        & "$($env:SystemDrive)\buildAgent\launcher\bin\TeamCityAgentService-windows-x86-32.exe" -i "$($env:SystemDrive)\buildAgent\launcher\conf\wrapper.conf" *>&1 | Write-Verbose
        if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from TeamCity Agent Configuration: TeamCityAgentService-windows-x86-64.exe" }

        $sc = Join-Path -Resolve ([System.Environment]::SystemDirectory) 'sc.exe'
        Write-Verbose "Found $sc"

        & $sc config TCBuildAgent start= delayed-auto type= own *>&1 | Write-Verbose
        if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from TeamCity Agent Configuration: sc.exe" }
    }
    TestScript = { $null -ne (Get-Service TCBuildAgent -ErrorAction Ignore) }
    GetScript = { @{} }
    DependsOn = '[File]TeamCityAgentInstall'
}