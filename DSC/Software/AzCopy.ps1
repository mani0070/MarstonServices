xRemoteFile AzCopyDownloader
{
    Uri = 'http://aka.ms/downloadazcopy'
    DestinationPath = 'D:\Installers\azcopy.msi'
    MatchSource = $false
}
xPackage AzCopy
{
    Ensure = 'Present'
    Name = 'Microsoft Azure Storage Tools - v6.1.0'
    Path  = 'D:\Installers\azcopy.msi'
    ProductId = '1D24B7AC-AFB4-44D4-928B-5CB14ABF4839'
    Arguments = "/quiet"
    DependsOn = "[xRemoteFile]AzCopyDownloader"
}
