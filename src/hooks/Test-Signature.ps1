<#PSScriptInfo

.VERSION 1.1

.GUID 351b3edb-00d3-4907-a3d6-8ca9336e63bd

.AUTHOR Johannes Schöpp

.LICENSEURI https://github.com/jschpp/PowershellGitHooks/blob/master/LICENSE

.PROJECTURI https://github.com/jschpp/PowershellGitHooks/

.RELEASENOTES https://github.com/jschpp/PowershellGitHooks/releases

#>

<#

.DESCRIPTION
 Tests Powershell script files for signature

#>

# Parameter
$RequireSignature = $true # Every powershell scripts needs a signature
$CheckForSigErrors = $true # Check powershell scripts for signature errors
$RequireTimestamp = $true # Does the powershell script need a timestamp signature

$rootDirectory = Join-Path -Path (Split-Path -Parent -Path $MyInvocation.MyCommand.Path) -ChildPath "\..\..\" -Resolve
$PowershellScripts = Get-ChildItem -Path $rootDirectory -Recurse -Filter "*.ps*1" -File

$errSwitch = $false

foreach ($psscript in $PowershellScripts) {
    $sig = Get-AuthenticodeSignature -FilePath $psscript.FullName
    if (($sig.Status -ne "Valid") -and $RequireSignature) {
        $errSwitch = $true
        Write-Output -InputObject "Signature on file: $($psscript.FullName.Replace($rootDirectory, '.\')) is not valid. Status: $($sig.Status)"
    }
    if (-not (($sig.Status -eq "Valid") -xor ($sig.Status -eq "NotSigned")) -and $CheckForSigErrors) {
        $errSwitch = $true
        Write-Output -InputObject "Signature on file: $($psscript.FullName.Replace($rootDirectory, '.\')) is signed but faulty. Status: $($sig.Status)"
    }
    if ($sig -and (!$sig.TimeStamperCertificate -and $RequireTimestamp)) {
        $errSwitch = $true
        Write-Output -InputObject "Signature on file: $($psscript.FullName.Replace($rootDirectory, '.\')) has no timestamp certificate."
    }
}

if ($errSwitch) {
    EXIT 1
}
else {
    EXIT 0
}
