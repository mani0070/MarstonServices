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

Service TeamCity
{
    Name        = 'TeamCity'
    Credential  = $teamcityServiceCredential
    Description = 'JetBrains TeamCity server service'
    DisplayName = 'TeamCity Server'
    Ensure      = 'Present'
    Path        = "`"C:\TeamCity\bin\TeamCityService.exe`" jetservice `"/settings=C:\TeamCity\conf\teamcity-server-service.xml`" `"/LogFile=C:\TeamCity\logs\teamcity-winservice.log`""
    StartupType = 'Automatic'
    State       = 'Running'
    DependsOn   = @('[File]TeamCityServerInstall','[Script]SetTeamCityUserGroups','[Script]SetTeamCityAzureFileshareCmdkey')
}