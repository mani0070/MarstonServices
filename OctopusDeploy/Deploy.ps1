user account
shared drive for artifacts foldr

run configure commands for server + tentacle
--home to share drive
--masterkey
storageconnectionstringw
weblistenprefix
webforcessl
bindings

Octopus.Server.exe path --artifacts \\Octoshared\OctopusData\Artifacts
Octopus.Server.exe path --taskLogs \\Octoshared\OctopusData\TaskLogs
Octopus.Server.exe path --nugetRepository \\Octoshared\OctopusData\Packages