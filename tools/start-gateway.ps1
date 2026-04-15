param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$PassthroughArgs
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$target = Join-Path (Resolve-Path (Join-Path $scriptDir "..\scripts")).Path "start-gateway.ps1"

if (-not (Test-Path -LiteralPath $target)) {
    throw "Script alvo não encontrado: $target"
}

& $target @PassthroughArgs
exit $LASTEXITCODE
