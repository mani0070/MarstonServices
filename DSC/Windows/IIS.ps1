WindowsFeature WebDefaultDoc
{
    Ensure = 'Present'
    Name = 'Web-Default-Doc'
}
WindowsFeature WebHttpErrors
{
    Ensure = 'Present'
    Name = 'Web-Http-Errors'
}
WindowsFeature WebStaticContent
{
    Ensure = 'Present'
    Name = 'Web-Static-Content'
}
WindowsFeature WebHttpRedirect
{
    Ensure = 'Present'
    Name = 'Web-Http-Redirect'
}
WindowsFeature  WebPerformance
{
    Ensure = 'Present'
    Name = 'Web-Performance'
    IncludeAllSubFeature = $true 
}
WindowsFeature WebNetExt
{
    Ensure = 'Present'
    Name = 'Web-Net-Ext'
}
WindowsFeature WebNetExt45
{
    Ensure = 'Present'
    Name = 'Web-Net-Ext45'
}
WindowsFeature WebAppInit
{
    Ensure = 'Present'
    Name = 'Web-AppInit'
}
WindowsFeature WebAspNet
{
    Ensure = 'Present'
    Name = 'Web-Asp-Net'
}
WindowsFeature WebAspNet45
{
    Ensure = 'Present'
    Name = 'Web-Asp-Net45'
}
WindowsFeature WebISAPIExt
{
    Ensure = 'Present'
    Name = 'Web-ISAPI-Ext'
}
WindowsFeature WebISAPIFilter
{
    Ensure = 'Present'
    Name = 'Web-ISAPI-Filter'
}
WindowsFeature WebWebSockets
{
    Ensure = 'Present'
    Name = 'Web-WebSockets'
}
WindowsFeature WebPerformance
{
    Ensure = 'Present'
    Name = 'Web-Mgmt-Tools'
    IncludeAllSubFeature = $true 
}
   