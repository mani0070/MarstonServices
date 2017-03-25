WindowsFeature WindowsDefenderFeatures
{
    Ensure = 'Absent'
    Name = 'Windows-Defender-Features'
    IncludeAllSubFeature = $true 
}