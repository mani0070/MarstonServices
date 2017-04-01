WindowsFeature NETFrameworkFeatures
{
    Ensure = 'Present'
    Name = 'NET-Framework-Features'
    IncludeAllSubFeature = $true 
}
WindowsFeature NETFramework45Core
{
    Ensure = 'Present'
    Name = 'NET-Framework-45-Core'
}
WindowsFeature NETFramework45ASPNET
{
    Ensure = 'Present'
    Name = 'NET-Framework-45-ASPNET'
}
WindowsFeature WAS
{
    Ensure = 'Present'
    Name = 'WAS'
    IncludeAllSubFeature = $true 
}