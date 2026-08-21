param(
    [Parameter(Mandatory)]
    [string]$ProjectRoot,
    [switch]$Force
)

$source = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$resolvedProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path
$destinationRoot = [IO.Path]::GetFullPath((Join-Path $resolvedProjectRoot '.codex\skills'))
$destination = [IO.Path]::GetFullPath((Join-Path $destinationRoot 'portable-project-handover'))
$projectPrefix = $resolvedProjectRoot.TrimEnd('\') + [IO.Path]::DirectorySeparatorChar

if (-not $destination.StartsWith($projectPrefix, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to install outside the project directory: $destination"
}
if ($source.TrimEnd('\') -eq $destination.TrimEnd('\')) {
    Write-Output "Skill is already installed in this project at $destination"
    exit 0
}
if ((Test-Path -LiteralPath $destination) -and -not $Force) {
    throw "Project-local Skill already exists at $destination. Re-run with -Force to replace it."
}

New-Item -ItemType Directory -Path $destinationRoot -Force | Out-Null
if (Test-Path -LiteralPath $destination) {
    Remove-Item -LiteralPath $destination -Recurse -Force
}
Copy-Item -LiteralPath $source -Destination $destination -Recurse -Force
Write-Output "Installed portable-project-handover to $destination"
