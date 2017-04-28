xRemoteFile ProGetArchive
{
    Uri = "http://cdn.inedo.com/downloads/proget/ProGetSetup$($ProGetVersion)_Manual.zip"
    DestinationPath = 'D:\Installers\ProGetSetup_Manual.zip'
    MatchSource = $false
}
Script ProGetExtract
{
    SetScript = {
        & "${env:ProgramFiles}\7-Zip\7z.exe" x "D:\Installers\ProGetSetup_Manual.zip" -o"D:\Installers\"
        & "${env:ProgramFiles}\7-Zip\7z.exe" x "D:\Installers\ProGet-Service.zip" -o"C:\ProGet\Service"
        & "${env:ProgramFiles}\7-Zip\7z.exe" x "D:\Installers\ProGet-WebApp.zip" -o"C:\ProGet\WebApp"
        & "${env:ProgramFiles}\7-Zip\7z.exe" x "D:\Installers\ProGet-DbChangeScripter.zip" -o"C:\ProGet\DbChangeScripter"
        $extensionsPath = 'C:\ProgramData\ProGet\Extensions\ExtensionsPath'
        if (!(Test-Path $extensionsPath)) { New-Item -Path $extensionsPath -ItemType Directory }
        Move-Item -Path 'D:\Installers\Extensions\*' -Destination $extensionsPath -Force 
    }
    TestScript = { (Test-Path "C:\ProGet\Service") -and (Test-Path "C:\ProGet\WebApp") }
    GetScript = { @{} }
    DependsOn = @('[xRemoteFile]ProGetArchive','[Package]SevenZip')
}
New-ServiceAccount (Get-AutomationPSCredential -Name ProGet)
