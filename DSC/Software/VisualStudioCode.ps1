xRemoteFile VSCodeDownloader
{
    Uri = 'https://go.microsoft.com/fwlink/?LinkID=623230'
    DestinationPath = 'D:\VSCodeSetup.exe'
    MatchSource = $false
}
xPackage VisualStudioCode
{
    Ensure = 'Present'
    Name = 'Microsoft Visual Studio Code'
    Path  = 'D:\VSCodeSetup.exe'
    ProductId = ''
    Arguments = "/verysilent /suppressmsgboxes /mergetasks=!runCode,desktopicon,addcontextmenufiles,addcontextmenufolders /log=`"D:\VSCodeSetup.log`""
    ReturnCode =  @(0, 3010, 1641)
    DependsOn = "[xRemoteFile]VSCodeDownloader"
}
