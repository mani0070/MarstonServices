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
File TeamCityDataDirCopy
{
    DestinationPath = "D:\TeamCityData.zip"
    SourcePath = "\\$($AzureStorageAccountName).file.core.windows.net\teamcity\TeamCity.zip"
    Type = 'File'
    MatchSource = $false
    PsDscRunAsCredential = $teamcityServiceCredential
    DependsOn = '[Script]SetTeamCityAzureFileshareCmdkey'
}

$teamcityServiceCredential = Get-AutomationPSCredential -Name TeamCity
New-ServiceAccount $teamcityServiceCredential
Script TeamCityDataDirExtract
{
    SetScript = {
        & "${env:ProgramFiles}\7-Zip\7z.exe" x "D:\TeamCityData.zip" -o"D:`xs"
        if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne 1) { throw "7z.exe exit code $LASTEXITCODE" }
    }
    TestScript = { Test-Path 'D:\TeamCityData' }
    GetScript = { @{} }
    DependsOn = @('[File]TeamCityDataDirCopy')
}
Script TeamCityServerConfig
{
    SetScript = {
        & "${env:SystemDrive}\TeamCity\bin\teamcity-server.bat" service install /runAsSystem *>&1 | Write-Verbose
        if ($LASTEXITCODE -ne 0) { throw "teamcity-server.bat exit code $LASTEXITCODE" }
    }
    TestScript = { $null -ne (Get-Service TeamCity -ErrorAction Ignore) }
    GetScript = { @{} }
    DependsOn = @('[File]TeamCityServerInstall','[Script]TeamCityDataDirExtract')
}
Service TeamCity
{
    Name        = 'TeamCity'
    Credential  = $teamcityServiceCredential
    StartupType = 'Automatic'
    State       = 'Running'
    DependsOn   = @('[Script]TeamCityServerConfig','[Script]SetTeamCityUserGroups','[Script]SetTeamCityAzureFileshareCmdkey','[Script]TeamCityDataDirExtract')
}