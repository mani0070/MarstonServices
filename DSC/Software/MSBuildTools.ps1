# "release": {
#     "buildtools": "https://download.microsoft.com/download/C/3/7/C37763CB-E533-4290-BE34-1DF89C218CFE/vs_BuildTools.exe",
#     "community": "https://download.microsoft.com/download/5/2/1/521C52A7-EFCC-46CE-A890-4F317732ABA3/vs_Community.exe",
#     "enterprise": "https://download.microsoft.com/download/A/A/3/AA372A6A-C137-474D-95B6-865AF23DF0E1/vs_Enterprise.exe",
#     "feedbackclient": "https://download.microsoft.com/download/D/4/4/D4444368-C717-4BD5-A09A-3AB8EA918A9E/vs_FeedbackClient.exe",
#     "professional": "https://download.microsoft.com/download/C/5/0/C5092724-4FFE-4DD3-9EE7-0AE31BF17620/vs_Professional.exe",
#     "testagent": "https://download.microsoft.com/download/B/C/2/BC222F87-4D85-4EF0-9C83-E5E1F7D2EA75/vs_TestAgent.exe",
#     "testcontroller": "https://download.microsoft.com/download/8/1/9/819B1892-8D12-425F-B677-916E924A7948/vs_TestController.exe",
#     "testprofessional": "https://download.microsoft.com/download/8/6/F/86F52AAB-5DAE-41DD-8A44-E9766F96177C/vs_TestProfessional.exe",
#     "teamexplorer": "https://download.microsoft.com/download/F/A/4/FA4E97C5-C37D-4B9F-AA88-7FF9B67E0E80/vs_TeamExplorer.exe"
# },
xRemoteFile VSBuildTools
{
    Uri = 'https://download.microsoft.com/download/C/3/7/C37763CB-E533-4290-BE34-1DF89C218CFE/vs_BuildTools.exe'
    DestinationPath = 'D:\vs_BuildTools.exe'
    MatchSource = $false
}
xPackage VSBuildTools
{
    Ensure = 'Present'
    Name = 'Microsoft Visual Studio 2017'
    Path  = 'D:\vs_BuildTools.exe'
    ProductId = ''
    Arguments = "--all --includeRecommended --includeOptional  --quiet --norestart --wait"
    ReturnCode =  0
    DependsOn = "[xRemoteFile]VSBuildTools"
}