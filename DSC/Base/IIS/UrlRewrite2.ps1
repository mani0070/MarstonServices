xRemoteFile UrlRewrite2
{
    Uri = "http://download.microsoft.com/download/C/9/E/C9E8180D-4E51-40A6-A9BF-776990D8BCA9/rewrite_amd64.msi"
    DestinationPath = "D:\Installers\rewrite_amd64.msi"
    MatchSource = $false
}
Script UrlRewrite2
{
    SetScript = {
        Stop-Service was -Verbose
        Stop-Service wmsvc -Verbose
        & "${env:SystemRoot}\System32\cmd.exe" /C reg.exe save "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5" "${env:TEMP}\__rewrite_netfx35_sp_level.txt" /y
        & "${env:SystemRoot}\System32\cmd.exe" /C reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5" /v SP /t REG_DWORD /d 0 /f

        & "D:\Installers\rewrite_amd64.msi"

        & "${env:SystemRoot}\System32\cmd.exe" /C reg.exe restore "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5" "${env:TEMP}\__rewrite_netfx35_sp_level.txt"
        Remove-Item -Path "${env:TEMP}\__rewrite_netfx35_sp_level.txt" -Force
        Start-Service w3svc -Verbose
        Start-Service wmsvc -Verbose
    }
    TestScript = { (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\IIS Extensions\URL Rewrite\' -Name Install -ErrorAction Ignore | % Install) -eq 1 }
    GetScript = { @{} }
    DependsOn = @('[xRemoteFile]UrlRewrite2','[WindowsFeature]WAS','[WindowsFeature]WebWebServer','[WindowsFeature]WebMgmtTools')
}
