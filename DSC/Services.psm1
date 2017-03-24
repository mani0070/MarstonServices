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
        @include "/Base/IEEnchancedSecurity"
        
        @include "/Software/7Zip"
        @include "/Software/AzCopy"
        @include "/Software/AzureRM"
        @include "/Software/JDK"
        @include "/Software/VisualStudioCode"

        @include "/Windows/Defender"
        @include "/Windows/DotNet"
        @include "/Windows/IIS"

        @include "/TeamCity/Archive"
        @include "/TeamCity/BuidAgent"
        @include "/TeamCity/Server"

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