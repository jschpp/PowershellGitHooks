function Get-PSHook {
    <#
    .SYNOPSIS
    Returns all available hooks

    .DESCRIPTION
    Reads all ps1 files contained in the hooks directory of the Module.
    After that it parses the ScriptInfo of the hooks and extracts the Description of the Hook.
    Returns a list of CustomObjects containing the Description, LiteralPath and Name of the Hook.

    .PARAMETER Name
    Name of the hook

    .INPUTS
    None. You cannot pipe objects to Get-PSHook.

    .OUTPUTS
    System.Management.Automation.PSCustomObject[]. Get-PSHook returns a list of objects containing the Name, LiteralPath, and Description of the hook as NoteProperties

    .EXAMPLE
    C:\PS> Get-PSHook
    LiteralPath                              Name           Description
    --------                                 ----           -----------
    C:\<ModulePath>\hooks\Test-Signature.ps1 Test-Signature Tests Powershell script files for signature

    .LINK
    https://github.com/jschpp/PowershellGitHooks

    #>
    param (
        [parameter(Mandatory = $false, Position = 0)]
        [string]$Name
    )

    $hook = @{
        Name        = ""
        LiteralPath = ""
        Description = ""
    }
    $result = @()
    foreach ($file in (Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath "hooks") -Filter "*.ps1")) {
        $info = Test-ScriptFileInfo $file.FullName -ErrorAction SilentlyContinue
        $hook.Name = $file.BaseName
        $hook.LiteralPath = $file.FullName
        $hook.Description = $info.Description
        if ($Name -eq $hook.Name) {
            return $(New-Object -TypeName PSObject -Property $hook)
        }
        $result += $(New-Object -TypeName PSObject -Property $hook)
    }
    return $result
}


function _testHookName {
    param (
        [parameter(Mandatory = $true, Position = 0)]
        [string]$HookName
    )
    $hooks = Get-PSHook
    return $hooks.Name -contains $HookName
}


function Install-GitHook {
    <#
    .SYNOPSIS
    Returns all available hooks

    .DESCRIPTION
    Reads all ps1 files contained in the hooks directory of the Module.
    After that it parses the ScriptInfo of the hooks and extracts the Description of the Hook.
    Returns a list of CustomObjects containing the Description, LiteralPath and Name of the Hook.

    .INPUTS
    None. You cannot pipe objects to Install-GitHook.

    .OUTPUTS
    None.

    .PARAMETER PSHookName
    The Name of the Hook which shall be installed.
    Available Hooks can be viewed with Get-PSHook

    .PARAMETER RepositoryPath
    Path to the Repository in which the hook should be installed.

    .PARAMETER GitHook
    Which Hook to modify. For available Hooks please take a look at https://git-scm.com/docs/githooks

    .PARAMETER NoClobber
    Don't overwrite the existing hook

    .PARAMETER Append
    Append the hook to an existing hook

    .EXAMPLE
    C:\PS> Install-GitHook -PSHookName "Test-Signature" -RepositoryPath "C:\MyAwesomeRepo" -Githook "pre-commit"

    .LINK
    https://github.com/jschpp/PowershellGitHooks

    #>
    [CmdletBinding(SupportsShouldProcess = $True)]
    param (
        [parameter(Mandatory = $true, Position = 0)]
        [ValidateScript( {_testHookName -HookName $_})]
        [string]$PSHookName,
        [parameter(Mandatory = $true, Position = 1)]
        [ValidateScript( {(Test-Path -Path $_) -and (Test-Path $(Join-Path $_ ".git"))})]
        [string]$RepositoryPath,
        [parameter(Mandatory = $true, Position = 2)]
        [ValidateSet("applypatch-msg", "pre-applypatch", "post-applypatch",
            "pre-commit", "prepare-commit-msg", "commit-msg", "post-commit",
            "pre-rebase", "post-checkout", "post-merge", "pre-push",
            "pre-receive", "update", "post-receive", "post-update",
            "push-to-checkout", "pre-auto-gc", "post-rewrite", "rebase",
            "sendemail-validate", "fsmonitor-watchman")] # see https://git-scm.com/docs/githooks
        [string]$GitHook,
        [parameter(Mandatory = $false)]
        [switch]$NoClobber,
        [parameter(Mandatory = $false)]
        [switch]$Append
    )
}

Export-ModuleMember -Function Get-PSHook, Install-GitHook
