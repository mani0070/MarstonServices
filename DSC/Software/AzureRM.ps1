PSModule AzureRM
{
    Name              = "AzureRM"
    Repository        = "PSGallery"
    InstallationPolicy= "Trusted"   
    DependsOn         = "[PackageManagementSource]PSGallery"  
}   