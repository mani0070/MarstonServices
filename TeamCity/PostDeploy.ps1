# ARR Proxy
Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/proxy" -Name "enabled" -value "True"
Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/proxy" -Name "reverseRewriteHostInResponseHeaders" -value "True"


# Server Allowed Variables
Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/allowedServerVariables/add[@name='HTTP_X_FORWARDED_SCHEMA']" -Name "name" -Value "HTTP_X_FORWARDED_HOST"
Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/allowedServerVariables/add[@name='HTTP_X_FORWARDED_SCHEMA']" -Name "name" -Value "HTTP_X_FORWARDED_PROTO"
Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/allowedServerVariables/add[@name='HTTP_X_FORWARDED_SCHEMA']" -Name "name" -Value "HTTP_X_FORWARDED_SCHEMA"

# TeamCity Rule
Add-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/globalRules" -Name "." -Value @{
    enabled         = 'True'
    name            = 'TeamCity'
    patternSyntax   = 'Wildcard'
    stopProcessing  = 'True'
}

Add-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/conditions" -Name "." -Value @{
    input       = '{HTTP_HOST}'
    pattern     = 'teamcity.services.marston.me'
}
Add-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/conditions" -Name "." -Value @{
    input       = '{HTTPS}'
    pattern     = 'ON'
}

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
Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/action" -Name "url" -Value "http://TeamCity/{R:0}"
