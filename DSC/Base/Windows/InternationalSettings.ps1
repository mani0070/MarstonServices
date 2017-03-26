Script InternationalSettings
{
    SetScript = {
        Import-Module International

        $enGb = [System.Globalization.CultureInfo]::GetCultureInfo('en-GB')
        Set-Culture -CultureInfo $enGb
        Set-WinHomeLocation -GeoId 242
        Set-WinSystemLocale -SystemLocale $enGb
        Set-WinUserLanguageList -LanguageList ([Microsoft.InternationalSettings.Commands.WinUserLanguage]::new('en-GB')) -Force
        $global:DSCMachineStatus = 1
    }
    TestScript = {
        Import-Module International

        $null -ne (Get-Culture | ? Name -eq 'en-GB') -and `
        $null -ne (Get-WinHomeLocation | ? HomeLocation -eq 'United Kingdom') -and `
        $null -ne (Get-WinSystemLocale | ? Name -eq 'en-GB') -and `
        $null -ne (Get-WinUserLanguageList | % GetEnumerator | ? LanguageTag -eq 'en-GB')
    }
    GetScript = { @{} }
}