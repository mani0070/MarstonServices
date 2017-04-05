Configuration Services
{
    param(
        $TeamCityVersion,
        $AzureStorageAccountName,
        $AzureStorageAccountKey,
        $OctopusConnectionString,
        $OctopusMasterKey
    )
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName xNetworking
    Import-DscResource -ModuleName xSystemSecurity
    Import-DscResource -ModuleName PackageManagementProviderResource
        
    @include "/Nodes/Web"
}