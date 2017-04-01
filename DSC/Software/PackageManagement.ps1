PackageManagementSource PSGallery
{
    Ensure              = "Present"
    Name                = "PSGallery"
    ProviderName        = "PowerShellGet"
    SourceUri           = "https://www.powershellgallery.com/api/v2/"  
    InstallationPolicy  = "Trusted"
}
PackageManagementSource NuGet
{
    Ensure              = "Present"
    Name                = "NuGet"
    ProviderName        = "NuGet"
    SourceUri           = "https://api.nuget.org/v3/index.json"  
    InstallationPolicy  = "Trusted"
} 
PackageManagementSource Chocolatey
{
    Ensure              = "Present"
    Name                = "Chocolatey"
    ProviderName        = "Chocolatey"
    SourceUri           = "http://chocolatey.org/api/v2/"  
    InstallationPolicy  = "Trusted"
} 