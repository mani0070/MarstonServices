xRemoteFile SevenZipDownloader
{
    Uri = 'http://www.7-zip.org/a/7z1604-x64.msi'
    DestinationPath = 'D:\Installers\7z1604-x64.msi'
    MatchSource = $false
}
Package SevenZip
{
    Ensure = 'Present'
    Path = 'D:\Installers\7z1604-x64.msi'
    Name = '7-Zip 16.04 (x64 edition)'
    Arguments = "/qn /l*v `"D:\Installers\7ZipInstall.log`""
    ProductId = '23170F69-40C1-2702-1604-000001000000'
    DependsOn = "[xRemoteFile]SevenZipDownloader"
}