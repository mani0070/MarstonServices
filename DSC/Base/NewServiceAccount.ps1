function New-ServiceAccount {
    param($AutomationCredentialName)

    $serviceCredentials = Get-AutomationPSCredential -Name $AutomationCredentialName
    $serviceCredentialsUsername = $serviceCredentials.UserName
    User "${AutomationCredentialName}ServiceAccount"
    {
        UserName                = $serviceCredentialsUsername
        Password                = $serviceCredentials
        PasswordChangeRequired  = $false
        PasswordNeverExpires    = $true
    }
    Script "Set${AutomationCredentialName}UserGroups"
    {
        SetScript = {
            $user = Get-LocalUser -Name $using:serviceCredentialsUsername
            try { Add-LocalGroupMember -Name Users -Member $user -ErrorAction Stop } catch [Microsoft.PowerShell.Commands.MemberExistsException] {}
            try { Add-LocalGroupMember -Name Administrators -Member $user -ErrorAction Stop } catch [Microsoft.PowerShell.Commands.MemberExistsException] {}
        }
        TestScript = {
            $user = Get-LocalUser -Name $using:serviceCredentialsUsername
            (($null -ne (Get-LocalGroupMember -Name Users -Member $user -ErrorAction Ignore)) -and ($null -ne (Get-LocalGroupMember -Name Administrators -Member $user -ErrorAction Ignore)))
        }
        GetScript = { @{} }
        DependsOn = "[User]${AutomationCredentialName}ServiceAccount"
    }
}