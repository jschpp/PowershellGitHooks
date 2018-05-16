# PowershellGitHooks

This Module contains all of the Powershell Hooks I use as well as some functions which can be used to install the Hooks.

## Hooks

### Test-Signature

This hook checks the Authenticode Signature of the Powershell Script Files inside the Repository.

It contains 3 Variables which can be set to modify its behavior.

```powershell
$RequireSignature = $true # Every powershell scripts needs a signature
$CheckForSigErrors = $true # Check powershell scripts for signature errors
$RequireTimestamp = $true # Does the powershell script need a timestamp signature
```
