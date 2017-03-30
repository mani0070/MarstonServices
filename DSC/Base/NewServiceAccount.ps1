function New-ServiceAccount {
    param($Credential)

    $username = $Credential.UserName
    User "${username}ServiceAccount"
    {
        UserName                = $username
        Password                = $Credential
        PasswordChangeRequired  = $false
        PasswordNeverExpires    = $true
    }
    Script "Set${username}UserGroups"
    {
        SetScript = {
            $user = Get-LocalUser -Name $using:username
            try { Add-LocalGroupMember -Name Users -Member $user -ErrorAction Stop } catch [Microsoft.PowerShell.Commands.MemberExistsException] {}
            try { Add-LocalGroupMember -Name Administrators -Member $user -ErrorAction Stop } catch [Microsoft.PowerShell.Commands.MemberExistsException] {}
        }
        TestScript = {
            $user = Get-LocalUser -Name $using:username
            (($null -ne (Get-LocalGroupMember -Name Users -Member $user -ErrorAction Ignore)) -and ($null -ne (Get-LocalGroupMember -Name Administrators -Member $user -ErrorAction Ignore)))
        }
        GetScript = { @{} }
        DependsOn = "[User]${username}ServiceAccount"
    }
}