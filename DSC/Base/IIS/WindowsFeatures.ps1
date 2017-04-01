WindowsFeature WebWebServer
{
    Ensure = 'Present'
    Name = 'Web-WebServer'
}
WindowsFeature WebCommonHttp
{
    Ensure = 'Present'
    Name = 'Web-Common-Http'
    IncludeAllSubFeature = $true
    DependsOn = '[WindowsFeature]WebWebServer'
}
WindowsFeature  WebPerformance
{
    Ensure = 'Present'
    Name = 'Web-Performance'
    IncludeAllSubFeature = $true
    DependsOn = '[WindowsFeature]WebWebServer'
}
WindowsFeature WebNetExt
{
    Ensure = 'Present'
    Name = 'Web-Net-Ext'
    DependsOn = '[WindowsFeature]WebWebServer'
}
WindowsFeature WebNetExt45
{
    Ensure = 'Present'
    Name = 'Web-Net-Ext45'
    DependsOn = '[WindowsFeature]WebWebServer'
}
WindowsFeature WebAppInit
{
    Ensure = 'Present'
    Name = 'Web-AppInit'
    DependsOn = '[WindowsFeature]WebWebServer'
}
WindowsFeature WebAspNet
{
    Ensure = 'Present'
    Name = 'Web-Asp-Net'
    DependsOn = '[WindowsFeature]WebWebServer'
}
WindowsFeature WebAspNet45
{
    Ensure = 'Present'
    Name = 'Web-Asp-Net45'
    DependsOn = '[WindowsFeature]WebWebServer'
}
WindowsFeature WebISAPIExt
{
    Ensure = 'Present'
    Name = 'Web-ISAPI-Ext'
    DependsOn = '[WindowsFeature]WebWebServer'
}
WindowsFeature WebISAPIFilter
{
    Ensure = 'Present'
    Name = 'Web-ISAPI-Filter'
    DependsOn = '[WindowsFeature]WebWebServer'
}
WindowsFeature WebWebSockets
{
    Ensure = 'Present'
    Name = 'Web-WebSockets'
    DependsOn = '[WindowsFeature]WebWebServer'
}
WindowsFeature WebMgmtTools
{
    Ensure = 'Present'
    Name = 'Web-Mgmt-Tools'
    IncludeAllSubFeature = $true 
    DependsOn = '[WindowsFeature]WebWebServer'
}