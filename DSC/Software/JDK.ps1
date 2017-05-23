Script JDKDownloader
{
    SetScript = {
        $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
        $cookie = New-Object System.Net.Cookie 
        $cookie.Name = "oraclelicense"
        $cookie.Value = "accept-securebackup-cookie"
        $cookie.Domain = ".oracle.com"
        $session.Cookies.Add($cookie);
        $uri = 'http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-windows-i586.exe '
        Invoke-WebRequest -Uri $uri -UseBasicParsing -WebSession $session -OutFile 'D:\Installers\JDKInstall.exe'
    }
    TestScript = {
        $hash = '66B505E5AE2D9335622494200E3A81463D026732'
        ((Test-Path 'D:\Installers\JDKInstall.exe') -and (Get-FileHash -Path 'D:\Installers\JDKInstall.exe' -Algorithm SHA1 | % Hash) -eq $hash)
    }
    GetScript = { @{} }
}
$javaInstallPath = 'C:\jdk8'
$id = "180131"
xPackage Java
{
    Ensure = 'Present'
    Name = "Java SE Development Kit 8 Update 131"
    Path = "D:\Installers\JDKInstall.exe"
    ProductID = "32A3A4F4-B792-11D6-A78A-00B0D0${id}"
    Arguments = "/s ADDLOCAL=`"ToolsFeature,PublicjreFeature`" INSTALLDIR=$javaInstallPath INSTALL_SILENT=Enable REBOOT=Disable /L D:\Installers\JDKInstall.log"
    ReturnCode =  @(0)
    DependsOn = "[Script]JDKDownloader"
}

Environment JavaHome
{
    Ensure = "Present" 
    Name = "JAVA_HOME"
    Value = $javaInstallPath
    DependsOn = "[xPackage]Java"
}