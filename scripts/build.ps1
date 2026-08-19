$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$auraSdk = @(
    $env:AURA_SERVICE_LIB,
    (Join-Path $projectRoot 'AuraServiceLib.dll')
) | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1
if (-not $auraSdk) {
    throw 'Set AURA_SERVICE_LIB to the official AuraServiceLib.dll path supplied with the ASUS Aura SDK.'
}

$localInterop = Join-Path $projectRoot 'AuraServiceLib.dll'
if ([IO.Path]::GetFullPath($auraSdk) -ne [IO.Path]::GetFullPath($localInterop)) {
    Copy-Item -LiteralPath $auraSdk -Destination $localInterop -Force
}
$compiler = @(
    'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe',
    'C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe'
) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $compiler) { throw '.NET Framework C# compiler was not found.' }

$receiverOutput = Join-Path $projectRoot 'AuraReceiver.exe'
$interopAssembly = Join-Path $projectRoot 'AuraServiceLib.dll'
$receiverSource = Join-Path $projectRoot 'AuraReceiver.cs'
& $compiler /nologo /target:exe "/out:$receiverOutput" "/reference:$interopAssembly" $receiverSource
if ($LASTEXITCODE -ne 0) { throw 'AuraReceiver compilation failed.' }

Push-Location $projectRoot
try {
    pnpm install --frozen-lockfile
    pnpm exec electron-builder --win portable
} finally { Pop-Location }
