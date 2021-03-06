xRemoteFile ExternalCache
{
    Uri = "http://download.microsoft.com/download/C/A/5/CA5FAD87-1E93-454A-BB74-98310A9C523C/ExternalDiskCache_amd64.msi"
    DestinationPath = "D:\Installers\ExternalDiskCache_amd64.msi"
    MatchSource = $false
}
Script ExternalCache
{
    SetScript = {
        & "D:\Installers\ExternalDiskCache_amd64.msi"
    }
    TestScript = { (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\IIS Extensions\External Disk Cache\' -Name Install -ErrorAction Ignore | % Install) -eq 1 }
    GetScript = { @{} }
    DependsOn = @('[xRemoteFile]ExternalCache','[WindowsFeature]WebWebServer','[WindowsFeature]WebStaticContent')
}
