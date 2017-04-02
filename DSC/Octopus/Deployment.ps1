Script OctopusDeployment
{
    SetScript = {
        function Invoke-Octopus {
            param($Uri, $Body = $null, $Method = 'Get')
            Invoke-WebRequest -Uri "http://localhost:1986/$Uri" -Method $Method -Body ($Body | ConvertTo-Json) -Headers @{ "X-Octopus-ApiKey" = 'API-CPC5WKFFPGXSNOKDYRSDND1BDWE' } -UseBasicParsing -ErrorAction Stop | % Content | ConvertFrom-Json
        }
        $environmentId = Invoke-Octopus /api/Environments/All  | % GetEnumerator | ? Name -eq 'Microsoft Azure' | % Id
        Write-Verbose "EnvironmentId: $environmentId"
        $project = Invoke-Octopus /api/projects/all | % GetEnumerator | ? Name -eq '4 - Application Deployment'
        $releaseId = Invoke-Octopus "$($project.Links.Self)/releases" | % Items | Select-Object -First 1 | % Id
        Write-Verbose "ReleaseId: $releaseId"
        Invoke-Octopus "/api/tenants/all?projectid=$($project.Id)" | % GetEnumerator | % Id | % {
            Invoke-Octopus -Uri 'api/deployments' -Method Post -Body @{
                ReleaseId = $releaseId
                EnvironmentId = $environmentId
                TenantId = $_
            } | Out-String | Write-Verbose
        }
        Set-Content -Path 'C:\Octopus\deployment' -Value (Get-Date -Format u)
    }
    TestScript = { Test-Path 'C:\Octopus\deployment' }
    GetScript = { @{} }
    DependsOn = @("[Service]OctopusDeployTentacle",'[Service]OctopusDeploy')
}