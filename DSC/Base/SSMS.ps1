xRemoteFile SSMSSetup
{
    Uri = "https://download.microsoft.com/download/C/8/A/C8AE3D51-5AAD-4DCF-809C-667D691629E4/SSMS-Setup-ENU.exe"
    DestinationPath = "D:\Installers\SSMS-Setup-ENU.exe"
    MatchSource = $false
}
xPackage SSMS
{
    Ensure = 'Present'
    Name = 'SQL Server Management Studio (2016)'
    Path  = "D:\Installers\SSMS-Setup-ENU.exe"
    ProductId = ''
    Arguments = "/install /quiet /norestart"
    ReturnCode = 0
    DependsOn = "[xRemoteFile]SSMSSetup"
}
