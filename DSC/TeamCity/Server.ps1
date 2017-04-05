Environment TeamCityDataDir
{
    Ensure = "Present" 
    Name = "TEAMCITY_DATA_PATH"
    Value = 'D:\TeamCityData'
}
File TeamCityServerInstall
{
    DestinationPath = "$($env:SystemDrive)\TeamCity"
    Recurse = $true
    SourcePath = 'D:\Installers\TeamCity'
    Type = 'Directory'
    MatchSource = $false
    DependsOn = '[Script]TeamCityExtract'
}

$teamcityServiceCredential = Get-AutomationPSCredential -Name TeamCity
New-ServiceAccount $teamcityServiceCredential
Script TeamCityDataDirCopy
{
    SetScript = {
        & robocopy.exe "\\$($using:AzureStorageAccountName).file.core.windows.net\teamcity" 'D:\TeamCityData' /MIR /MT /NP /NFL *>&1 | Write-Verbose
        if ($LASTEXITCODE -ne 0) { throw "robocopy.exe exit code $LASTEXITCODE" }
    }
    TestScript = { Test-Path 'D:\TeamCityData' }
    GetScript = { @{} }
    PsDscRunAsCredential = $teamcityServiceCredential
    DependsOn = '[Script]SetTeamCityAzureFileshareCmdkey'
}
Script TeamCityServerConfig
{
    SetScript = {
        & "${env:SystemDrive}\TeamCity\bin\teamcity-server.bat" service install /runAsSystem *>&1 | Write-Verbose
        if ($LASTEXITCODE -ne 0) { throw "teamcity-server.bat exit code $LASTEXITCODE" }
    }
    TestScript = { $null -ne (Get-Service TeamCity -ErrorAction Ignore) }
    GetScript = { @{} }
    DependsOn = @('[File]TeamCityServerInstall','[Script]TeamCityDataDirCopy')
}
Service TeamCity
{
    Name        = 'TeamCity'
    Credential  = $teamcityServiceCredential
    StartupType = 'Automatic'
    State       = 'Running'
    DependsOn   = @('[Script]TeamCityServerConfig','[Script]SetTeamCityUserGroups','[Script]SetTeamCityAzureFileshareCmdkey','[Script]TeamCityDataDirCopy')
}