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
    Script "Set${AutomationCredentialName}AzureFileshareCmdkey"
    {
        SetScript = {
             Write-Verbose "Running set-script as: ${env:USERNAME}"
            & cmdkey.exe /add:${using:AzureStorageAccountName}.file.core.windows.net /user:${using:AzureStorageAccountName} /pass:${using:AzureStorageAccountKey} *>&1 |  Write-Verbose
            if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from cmdkey.exe" }
        }
        TestScript = {
            Write-Verbose "Running test-script as: ${env:USERNAME}"
            $foundEntry = & cmdkey.exe /list:Domain:target=${using:AzureStorageAccountName}.file.core.windows.net | ? { $_ -like "*User: ${using:AzureStorageAccountName}*" }
            return ($null -ne $foundEntry)
        }
        GetScript = { @{} }
        PsDscRunAsCredential = $serviceCredentials
        DependsOn = "[Script]Set${AutomationCredentialName}UserGroups"
    }
}