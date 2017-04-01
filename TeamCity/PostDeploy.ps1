# ARR Proxy
Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/proxy" -Name "enabled" -value "True"
Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/proxy" -Name "reverseRewriteHostInResponseHeaders" -value "True"

# Server Allowed Variables

Add-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/allowedServerVariables" -Name "." -Value @{name='HTTP_X_FORWARDED_SCHEMA'}
Add-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/allowedServerVariables" -Name "." -Value @{name='HTTP_X_FORWARDED_SCHEMA'}
Add-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/allowedServerVariables" -Name "." -Value @{name='HTTP_X_FORWARDED_SCHEMA'}

# TeamCity Rule
Add-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/globalRules" -Name "." -Value @{
    enabled         = 'True'
    name            = 'TeamCity'
    patternSyntax   = 'Wildcard'
    stopProcessing  = 'True'
}

Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/match" -name "url" -value "*"

Add-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/conditions" -Name "." -Value @{
    input       = '{HTTP_HOST}'
    pattern     = 'teamcity.services.marston.me'
}
Add-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/conditions" -Name "." -Value @{
    input       = '{HTTPS}'
    pattern     = 'ON'
}
Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/conditions" -Name "logicalGrouping" -Value "MatchAll"

Add-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/serverVariables" -Name "." -Value @{
    name    = 'HTTP_X_FORWARDED_HOST'
    value   = '{HTTP_HOST}'
}
Add-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/serverVariables" -Name "." -Value @{
    name    = 'HTTP_X_FORWARDED_PROTO'
    value   = 'https'
}
Add-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/serverVariables" -Name "." -Value @{
    name    = 'HTTP_X_FORWARDED_SCHEMA'
    value   = 'https'
}

Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/action" -Name "type" -Value "Rewrite"
Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/action" -Name "url" -Value "http://localhost:8111/{R:0}"
