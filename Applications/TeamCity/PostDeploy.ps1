function New-WebConfigProperty {
    param($Filter, $Value)

    try {
        Add-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter:$Filter -Name '.' -Value:$Value -ErrorAction Stop
    }
    catch {
        if ($_.Exception.HResult -eq -2147024713) { Write-Warning $_.Exception.Message } # Already added
        else { throw }
    }
}
function Set-WebConfigProperty {
    param($Filter, $Name, $Value)

    Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter:$Filter -Name:$Name -Value:$Value -ErrorAction Stop
}
# ARR Proxy
Set-WebConfigProperty -Filter "system.webServer/proxy" -Name "enabled" -Value "True"
Set-WebConfigProperty -Filter "system.webServer/proxy" -Name "reverseRewriteHostInResponseHeaders" -Value "True"

# Server Allowed Variables
New-WebConfigProperty -Filter "system.webServer/rewrite/allowedServerVariables" -Value @{name='HTTP_X_FORWARDED_HOST'}
New-WebConfigProperty -Filter "system.webServer/rewrite/allowedServerVariables" -Value @{name='HTTP_X_FORWARDED_PROTO'}
New-WebConfigProperty -Filter "system.webServer/rewrite/allowedServerVariables" -Value @{name='HTTP_X_FORWARDED_SCHEMA'}

# TeamCity Rule
New-WebConfigProperty -Filter "system.webServer/rewrite/globalRules" -Value @{
    enabled         = 'True'
    name            = 'TeamCity'
    patternSyntax   = 'Wildcard'
    stopProcessing  = 'True'
}
Set-WebConfigProperty -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/match" -name "url" -value "*"
Set-WebConfigProperty -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/conditions" -Name "logicalGrouping" -Value "MatchAll"
New-WebConfigProperty -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/conditions" -Value @{
    input       = '{HTTP_HOST}'
    pattern     = 'teamcity.services.marston.me'
}
New-WebConfigProperty -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/conditions" -Value @{
    input       = '{HTTPS}'
    pattern     = 'ON'
}
New-WebConfigProperty -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/serverVariables" -Value @{
    name    = 'HTTP_X_FORWARDED_HOST'
    value   = '{HTTP_HOST}'
}
New-WebConfigProperty -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/serverVariables" -Value @{
    name    = 'HTTP_X_FORWARDED_PROTO'
    value   = 'https'
}
New-WebConfigProperty -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/serverVariables" -Value @{
    name    = 'HTTP_X_FORWARDED_SCHEMA'
    value   = 'https'
}
Set-WebConfigProperty -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/action" -Name "type" -Value "Rewrite"
Set-WebConfigProperty -Filter "system.webServer/rewrite/globalRules/rule[@name='TeamCity']/action" -Name "url" -Value "http://localhost:8111/{R:0}"
