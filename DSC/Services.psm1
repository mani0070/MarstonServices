Configuration Services
{
    param(
        $TeamCityVersion
    )
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName xNetworking
    Import-DscResource -ModuleName xSystemSecurity
    Import-DscResource -ModuleName PackageManagementProviderResource
        
    Node Frontend
    {
        @include "/Base/Windows/Defender"
        @include "/Base/Windows/DotNet"
        @include "/Base/Windows/IIS"

        @include "/Base/ExternalCache"
        @include "/Base/UrlRewrite2"
        @include "/Base/ARRv3"
        @include "/Base/IEEnchancedSecurity"
        
        @include "/Software/7Zip"
        @include "/Software/AzCopy"
        @include "/Software/AzureRM"
        @include "/Software/JDK"
        @include "/Software/VisualStudioCode"

        @include "/TeamCity/Archive"
        @include "/TeamCity/BuildAgent"
        @include "/TeamCity/Server"

        @include "/ProGet/ProGet"

        @include "/Octopus/OctopusServer"
        @include "/Octopus/OctopusTentacle"

        xFirewall HTTPFirewall
        {
            Name                  = "HTTP"
            DisplayName           = "HTTP"
            Ensure                = "Present"
            Enabled               = "True"
            Action                = "Allow"
            Profile               = "Any"
            Direction             = "InBound"
            LocalPort             = "80"
            Protocol              = "TCP"
        }
        xFirewall HTTPSFirewall
        {
            Name                  = "HTTPS"
            DisplayName           = "HTTPS"
            Ensure                = "Present"
            Enabled               = "True"
            Action                = "Allow"
            Profile               = "Any"
            Direction             = "InBound"
            LocalPort             = "443"
            Protocol              = "TCP"
        }
    }
} 