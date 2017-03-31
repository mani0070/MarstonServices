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
    
    Script "Set${username}AzureFileshareCmdkey"
    {
        SetScript = {
            Write-Verbose "Running set-script as: $($using:username) ${env:USERNAME}"
            & cmdkey.exe /add:$($using:AzureStorageAccountName).file.core.windows.net /user:$($using:AzureStorageAccountName) /pass:$($using:AzureStorageAccountKey) *>&1 |  Write-Verbose
            if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE from cmdkey.exe" }
        }
        TestScript = {
            Write-Verbose "Running test-script as: $($using:username) ${env:USERNAME}"
            $foundEntry = & cmdkey.exe /list:Domain:target=$($using:AzureStorageAccountName).file.core.windows.net | ? { $_ -like "*User: $($using:AzureStorageAccountName)*" }
            return ($null -ne $foundEntry)
        }
        GetScript = { @{} }
        PsDscRunAsCredential = $Credential
        DependsOn = "[User]${username}ServiceAccount"
    }
}