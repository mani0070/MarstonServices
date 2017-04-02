xRemoteFile VSCodeDownloader
{
    Uri = 'https://go.microsoft.com/fwlink/?LinkID=623230'
    DestinationPath = 'D:\Installers\VSCodeSetup.exe'
    MatchSource = $false
}
xPackage VisualStudioCode
{
    Ensure = 'Present'
    Name = 'Microsoft Visual Studio Code'
    Path  = 'D:\Installers\VSCodeSetup.exe'
    ProductId = ''
    Arguments = "/verysilent /suppressmsgboxes /mergetasks=!runCode,desktopicon,addcontextmenufiles,addcontextmenufolders /log=`"D:\Installers\VSCodeSetup.log`""
    ReturnCode =  @(0, 3010, 1641)
    DependsOn = "[xRemoteFile]VSCodeDownloader"
}
