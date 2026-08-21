param(
    [switch]$Force
)

$source = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$destinationRoot = [IO.Path]::GetFullPath((Join-Path $env:USERPROFILE '.codex\skills'))
$destination = [IO.Path]::GetFullPath((Join-Path $destinationRoot 'portable-project-handover'))

if (-not $destination.StartsWith($destinationRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to install outside the Codex skills directory: $destination"
}
if ($source.TrimEnd('\') -eq $destination.TrimEnd('\')) {
    Write-Output "Skill is already installed at $destination"
    exit 0
}

if ((Test-Path -LiteralPath $destination) -and -not $Force) {
    throw "Skill already exists at $destination. Re-run with -Force to replace it."
}

New-Item -ItemType Directory -Path $destinationRoot -Force | Out-Null
if (Test-Path -LiteralPath $destination) {
    Remove-Item -LiteralPath $destination -Recurse -Force
}
Copy-Item -LiteralPath $source -Destination $destination -Recurse -Force
Write-Output "Installed portable-project-handover to $destination"
