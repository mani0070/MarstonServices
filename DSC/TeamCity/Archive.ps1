xRemoteFile TeamCityDownload
{
    Uri = "https://download.jetbrains.com/teamcity/TeamCity-$($TeamCityVersion).tar.gz"
    DestinationPath = "D:\Installers\TeamCity-$($TeamCityVersion).tar.gz"
    MatchSource = $false
}
Script TeamCityExtract
{
    SetScript = {
        & "${env:ProgramFiles}\7-Zip\7z.exe" e "D:\Installers\TeamCity-$($using:TeamCityVersion).tar.gz" -o"D:\Installers\"
        & "${env:ProgramFiles}\7-Zip\7z.exe" x "D:\Installers\TeamCity-$($using:TeamCityVersion).tar" -o"D:\Installers\"  
    }
    TestScript = {
        (Test-Path "D:\Installers\TeamCity")
    }
    GetScript = { @{} }
    DependsOn = @('[xRemoteFile]TeamCityDownload','[Package]SevenZip')
}
