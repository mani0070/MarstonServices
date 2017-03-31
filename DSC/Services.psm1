Configuration Services
{
    param(
        $TeamCityVersion,
        $AzureStorageAccountName,
        $AzureStorageAccountKey,
        $OctopusConnectionString,
        $OctopusMasterKey
    )
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName xNetworking
    Import-DscResource -ModuleName xSystemSecurity
    Import-DscResource -ModuleName PackageManagementProviderResource
        
    Node Frontend
    {
        @include "/Base/Windows/Defender"
        @include "/Base/Windows/DotNet"
        @include "/Base/Windows/IEEnchancedSecurity"
        @include "/Base/Windows/InternationalSettings"
        
        @include "/Base/IIS/WindowsFeatures"
        @include "/Base/IIS/ExternalCache"
        @include "/Base/IIS/UrlRewrite2"
        @include "/Base/IIS/ARRv3"
        
        @include "/Base/NewServiceAccount"

        @include "/Software/7Zip"
        @include "/Software/AzCopy"
        @include "/Software/AzureRM"
        @include "/Software/JDK"
        @include "/Software/VisualStudioCode"

        @include "/TeamCity/Archive"
        @include "/TeamCity/BuildAgent"
        @include "/TeamCity/Server"

        @include "/ProGet/ProGet"

        @include "/Octopus/OctopusServer"
        @include "/Octopus/OctopusTentacle"

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

        # Script OctopusDeployment
        # {
        #     SetScript = {
        #         function Invoke-Octopus {
        #             param($Uri, $Body = $null, $Method = 'Get')
        #             Invoke-WebRequest -Uri "http://localhost:1986/$Uri" -Method $Method -Body ($Body | ConvertTo-Json) -Headers @{ "X-Octopus-ApiKey" = 'API-CPC5WKFFPGXSNOKDYRSDND1BDWE' } -UseBasicParsing -ErrorAction Stop | % Content | ConvertFrom-Json
        #         }
        #         $environmentId = Invoke-Octopus /api/Environments/All  | % GetEnumerator | ? Name -eq 'Microsoft Azure' | % Id
        #         Write-Verbose "EnvironmentId: $environmentId"
        #         $releaseId Invoke-Octopus /api/projects/all | % GetEnumerator | ? Name -eq '4 - Services - Deployment' | % Links | % Self | % { Invoke-Octopus "$_/releases" } | % Items | Select-Object -First 1 | % Id
        #         Write-Verbose "ReleaseId: $releaseId"
        #         $tenantId = Invoke-Octopus /api/tenants/all?name=$(${env:COMPUTERNAME}.Substring(11)) |% GetEnumerator | % Id
        #         Write-Verbose "TenantId: $tenantId"
        #         Invoke-Octopus -Uri 'api/deployments' -Method Post -Body @{
        #             ReleaseId = $releaseId
        #             EnvironmentId = $environmentId
        #             TenantId = $tenantId
        #         } | Out-String | Write-Verbose
        #     }
        #     TestScript = { $null -ne (Get-ScheduledTask -TaskName 'Octopus Watchdog Tentacle' -ErrorAction Ignore) }
        #     GetScript = { @{} }
        #     DependsOn = @("[Service]OctopusDeployTentacle",'[Service]OctopusDeploy')
        # }
    }
} 