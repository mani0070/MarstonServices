.include "/Base/IIS/WindowsFeatures"
.include "/Base/IIS/ExternalCache"
.include "/Base/IIS/UrlRewrite2"
.include "/Base/IIS/ARRv3"

.include "/Base/SSMS"

.include "/TeamCity/Archive"
.include "/TeamCity/BuildAgent"
.include "/TeamCity/Server"

.include "/ProGet/ProGet"

.include "/Octopus/OctopusServer"

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