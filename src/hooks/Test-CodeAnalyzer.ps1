<#PSScriptInfo

.VERSION 1.0

.GUID bfcb4f6e-46ed-4978-aea2-f5f6104974bb

.AUTHOR Johannes Schöpp

.LICENSEURI https://github.com/jschpp/PowershellGitHooks/blob/master/LICENSE

.PROJECTURI https://github.com/jschpp/PowershellGitHooks/

.EXTERNALMODULEDEPENDENCIES PSScriptAnalyzer

.RELEASENOTES https://github.com/jschpp/PowershellGitHooks/releases

.PRIVATEDATA 

#>

<# 

.DESCRIPTION 
 Invokes ScriptAnalyzer and interpretes the result 

#> 

# Parameter
$Severity = "Error", "Warning"
$CustomRules = @()

$rootDirectory = Join-Path -Path (Split-Path -Parent -Path $MyInvocation.MyCommand.Path) -ChildPath "\..\..\" -Resolve
