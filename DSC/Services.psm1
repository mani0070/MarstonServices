Configuration Services
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName xNetworking
    Import-DscResource -ModuleName xSystemSecurity
    Import-DscResource -ModuleName PackageManagementProviderResource
        
    Node Frontend
    {
        @include "/Base/IEEnchancedSecurity"
        
        @include "/Software/7Zip"
        @include "/Software/AzCopy"
        @include "/Software/AzureRM"
        @include "/Software/JDK"
        @include "/Software/VisualStudioCode"

        @include "/Windows/Defender.ps1"
        @include "/Windows/DotNet.ps1"
        @include "/Windows/IIS.ps1"
    }
}