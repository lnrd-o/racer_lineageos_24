[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$ScriptName,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$RemainingArgs
)

# Resolve project root directory dynamically
$ProjectRoot = if (Test-Path (Join-Path $PSScriptRoot "manifests/racer.xml")) {
    $PSScriptRoot
} elseif (Test-Path (Join-Path $PSScriptRoot "../manifests/racer.xml")) {
    (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
} elseif (Test-Path "$PWD/manifests/racer.xml") {
    $PWD.Path
} else {
    $PSScriptRoot
}

$ForwardSlashPath = $ProjectRoot -replace '\\', '/'
$WslProjectRoot = (wsl -d Ubuntu wslpath -u "$ForwardSlashPath").Trim()

$ArgumentsStr = if ($RemainingArgs) { " " + ($RemainingArgs -join " ") } else { "" }

Write-Host "[WSL Bridge] Project Directory: $WslProjectRoot" -ForegroundColor Cyan
Write-Host "[WSL Bridge] Running: ./scripts/$ScriptName$ArgumentsStr" -ForegroundColor Cyan

wsl -d Ubuntu bash -c "cd '$WslProjectRoot' && bash './scripts/$ScriptName'$ArgumentsStr"
