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

# VSTS Rule
New-WebConfigProperty -Filter "system.webServer/rewrite/globalRules" -Value @{
    enabled         = 'True'
    name            = 'VSTS'
    patternSyntax   = 'Wildcard'
    stopProcessing  = 'True'
}
Set-WebConfigProperty -Filter "system.webServer/rewrite/globalRules/rule[@name='VSTS']/match" -name "url" -value "*"
Set-WebConfigProperty -Filter "system.webServer/rewrite/globalRules/rule[@name='VSTS']/conditions" -Name "logicalGrouping" -Value "MatchAll"
New-WebConfigProperty -Filter "system.webServer/rewrite/globalRules/rule[@name='VSTS']/conditions" -Value @{
    input       = '{HTTP_HOST}'
    pattern     = 'vsts.services.marston.me'
}
New-WebConfigProperty -Filter "system.webServer/rewrite/globalRules/rule[@name='VSTS']/conditions" -Value @{
    input       = '{HTTPS}'
    pattern     = 'ON'
}
Set-WebConfigProperty -Filter "system.webServer/rewrite/globalRules/rule[@name='VSTS']/action" -Name "type" -Value "Redirect"
Set-WebConfigProperty -Filter "system.webServer/rewrite/globalRules/rule[@name='VSTS']/action" -Name "appendQuerySting" -Value "False"
Set-WebConfigProperty -Filter "system.webServer/rewrite/globalRules/rule[@name='VSTS']/action" -Name "redirectType" -Value "Permanent"
Set-WebConfigProperty -Filter "system.webServer/rewrite/globalRules/rule[@name='VSTS']/action" -Name "url" -Value "https://marstonme.visualstudio.com/Home/_home"
