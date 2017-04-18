@{
    AllNodes = @(
        @{
            NodeName = 'Web'
            PSDscAllowPlainTextPassword = $true
        },
        @{
            NodeName = 'CloudAgent'
            PSDscAllowPlainTextPassword = $true
        }
    )
}