function New-WebConfigurationProperty {
    param($PSPath, $Filter, $Name, $Value)
    try {
        Add-WebConfigurationProperty -PSPath:$PSPath  -Filter:$Filter -Name:$Name -Value:$Value -ErrorAction Stop
    }
    catch {
        if ($_.Exception.HResult -eq -2147024713) { Write-Warning $_.Exception.Message }
        else { throw }
    }
}
# ARR Proxy
Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/proxy" -Name "enabled" -value "True"
Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/proxy" -Name "reverseRewriteHostInResponseHeaders" -value "True"

# Server Allowed Variables

New-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/allowedServerVariables" -Name "." -Value @{name='HTTP_X_FORWARDED_HOST'}
New-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/allowedServerVariables" -Name "." -Value @{name='HTTP_X_FORWARDED_PROTO'}
New-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/allowedServerVariables" -Name "." -Value @{name='HTTP_X_FORWARDED_SCHEMA'}

# TeamCity Rule
New-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/globalRules" -Name "." -Value @{
    enabled         = 'True'
    name            = 'TeamCity'
    patternSyntax   = 'Wildcard'
    stopProcessing  = 'True'
}

Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/match" -name "url" -value "*"

New-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/conditions" -Name "." -Value @{
    input       = '{HTTP_HOST}'
    pattern     = 'teamcity.services.marston.me'
}
New-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/conditions" -Name "." -Value @{
    input       = '{HTTPS}'
    pattern     = 'ON'
}
Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/conditions" -Name "logicalGrouping" -Value "MatchAll"

New-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/serverVariables" -Name "." -Value @{
    name    = 'HTTP_X_FORWARDED_HOST'
    value   = '{HTTP_HOST}'
}
New-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/serverVariables" -Name "." -Value @{
    name    = 'HTTP_X_FORWARDED_PROTO'
    value   = 'https'
}
New-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/serverVariables" -Name "." -Value @{
    name    = 'HTTP_X_FORWARDED_SCHEMA'
    value   = 'https'
}

Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/action" -Name "type" -Value "Rewrite"
Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST'  -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/action" -Name "url" -Value "http://localhost:8111/{R:0}"
