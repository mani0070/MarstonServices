xRemoteFile ARRv3
{
    Uri = "http://download.microsoft.com/download/E/9/8/E9849D6A-020E-47E4-9FD0-A023E99B54EB/requestRouter_amd64.msi"
    DestinationPath = "D:\requestRouter_amd64.msi"
    MatchSource = $false
}
Script ARRv3
{
    SetScript = {
        & "${env:SystemRoot}\System32\net.exe" stop was /y
        & "${env:SystemRoot}\System32\net.exe" stop wmsvc
        
        & "D:\requestRouter_amd64.msi"

        & "${env:SystemRoot}\System32\net.exe" start was
        & "${env:SystemRoot}\System32\net.exe" start w3svc
        & "${env:SystemRoot}\System32\net.exe" start wmsvc
    }
    TestScript = { (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\IIS Extensions\Application Request Routing\' -Name Install -ErrorAction Ignore | % Install) -eq 1 }
    GetScript = { @{} }
    DependsOn = @('[xRemoteFile]ARRv3','[Script]UrlRewrite2','[Script]ExternalCache')
}
