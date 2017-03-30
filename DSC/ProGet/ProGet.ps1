xRemoteFile ProGetArchive
{
    Uri = 'http://cdn.inedo.com/downloads/proget/ProGetSetup4.7.8_Manual.zip'
    DestinationPath = 'D:\ProGetSetup_Manual.zip'
    MatchSource = $false
}
Script ProGetExtract
{
    SetScript = {
        & "${env:ProgramFiles}\7-Zip\7z.exe" x "D:\ProGetSetup_Manual.zip" -o"D:\"
        & "${env:ProgramFiles}\7-Zip\7z.exe" x "D:\ProGet-Service.zip" -o"C:\ProGet\Service"
        & "${env:ProgramFiles}\7-Zip\7z.exe" x "D:\ProGet-WebApp.zip" -o"C:\ProGet\WebApp"
        & "${env:ProgramFiles}\7-Zip\7z.exe" x "D:\ProGet-DbChangeScripter.zip" -o"C:\ProGet\DbChangeScripter"
        Move-Item -Path 'D:\Extensions\*' -Destination 'C:\ProgramData\ProGet\Extensions\ExtensionsPath' -Force 
    }
    TestScript = { (Test-Path "C:\ProGet\Service") -and (Test-Path "C:\ProGet\WebApp") }
    GetScript = { @{} }
    DependsOn = @('[xRemoteFile]ProGetArchive','[Package]SevenZip')
}
New-ServiceAccount (Get-AutomationPSCredential -Name ProGet)
