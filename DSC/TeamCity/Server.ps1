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

Script "TeamCityAzureFileshareCmdkey"
{
    SetScript = {
        Write-Verbose "Running set-script as: ${env:USERNAME}"
        & cmdkey.exe /add:$($using:AzureStorageAccountName).file.core.windows.net /user:$($using:AzureStorageAccountName) /pass:$($using:AzureStorageAccountKey) *>&1 |  Write-Verbose
        if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from cmdkey.exe" }
    }
    TestScript = {
        Write-Verbose "Running test-script as: ${env:USERNAME}"
        $foundEntry = & cmdkey.exe /list:Domain:target=$($using:AzureStorageAccountName).file.core.windows.net | ? { $_ -like "*User: $($using:AzureStorageAccountName)*" }
        return ($null -ne $foundEntry)
    }
    GetScript = { @{} }
    PsDscRunAsCredential = $teamcityServiceCredential
    DependsOn = "[User]TeamCityServiceAccount"
}

Script TeamCityServerConfig
{
    SetScript = {
        Set-Content -Path "${env:SystemDrive}\TeamCity\conf\server.xml" -Value (Get-Content -Path "${env:SystemDrive}\TeamCity\conf\server.xml" -Raw | % Replace ' port="8111" ' ' port="80" ') -Encoding ASCII

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
    DependsOn = @('[User]TeamCityServiceAccount','[Script]TeamCityServerConfig','[Script]TeamCityAzureFileshareCmdkey')
} 