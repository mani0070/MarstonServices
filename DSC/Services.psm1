Configuration Services
{
    param(
        $TeamCityVersion,
        $AzureStorageAccountName,
        $AzureStorageAccountKey,
        $OctopusConnectionString,
        $OctopusMasterKey,
        $OctopusCertThumbprint,
        $ProGetVersion
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName xNetworking
    Import-DscResource -ModuleName xSystemSecurity
    Import-DscResource -ModuleName PackageManagementProviderResource

    Node Web
    { 
        .include "/Nodes/Web"
    }
    Node CloudAgent
    { 
        .include "/Nodes/CloudAgent"
    }
}