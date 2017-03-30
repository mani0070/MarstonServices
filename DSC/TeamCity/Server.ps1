Environment TeamCityDataDir
{
    Ensure = "Present" 
    Name = "TEAMCITY_DATA_PATH"
    Value = "\\${AzureStorageAccountName}.file.core.windows.net\teamcity"
}
File TeamCityServerInstall
{
    DestinationPath = "$($env:SystemDrive)\TeamCity"
    Recurse = $true
    SourcePath = 'D:\TeamCity'
    Type = 'Directory'
    MatchSource = $false
    DependsOn = '[Script]TeamCityExtract'
}

$teamcityServiceCredential = Get-AutomationPSCredential -Name TeamCity
New-ServiceAccount $teamcityServiceCredential

Script TeamCityServerConfig
{
    SetScript = {
        Get-Content -Path "${env:SystemDrive}\TeamCity\conf\server.xml" -Raw |
            % Replace ' port="8111" ' ' port="80" ' |
            Set-Content -Path "${env:SystemDrive}\TeamCity\conf\server.xml" -Encoding ASCII

        & "${env:SystemDrive}\TeamCity\bin\teamcity-server.bat" service install /runAsSystem *>&1 | Write-Verbose
        if ($LASTEXITCODE -ne 0) { throw "teamcity-server.bat exit code $LASTEXITCODE" }
    }
    TestScript = { $null -ne (Get-Service TeamCity -ErrorAction Ignore) }
    GetScript = { @{} }
    PsDscRunAsCredential = $teamcityServiceCredential
    DependsOn = '[File]TeamCityServerInstall'
}
Service TeamCity
{
    Name        = 'TeamCity'
    Credential  = $teamcityServiceCredential
    StartupType = 'Automatic'
    State       = 'Running'
    DependsOn = @('[User]TeamCityServiceAccount','[Script]TeamCityServerConfig')
} 