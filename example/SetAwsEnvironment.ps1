###
# Sets the AWS environment variables using your current PowerShell session AWS credentials or provided credentials
# Useful to run before running Terraform for tests
###

Param(
    $Credential = $null
)

$ErrorActionPreference = "Stop"

if ($Credential -eq $null) {
    $Credential = (Get-AWSCredential)
}

if ($Credential -eq $null) {
    throw "No AWS credentials provided or found in your PowerShell session"
}

$credObj = $Credential.GetCredentials()

$env:AWS_ACCESS_KEY_ID = $credObj.AccessKey
$env:AWS_SECRET_ACCESS_KEY = $credObj.SecretKey

if ($credObj.UseToken) {
    $env:AWS_SESSION_TOKEN = $credObj.Token
} else {
    $env:AWS_SESSION_TOKEN = ""
}