$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$auraSdk = @(
    $env:AURA_SERVICE_LIB,
    (Join-Path $projectRoot 'AuraServiceLib.dll')
) | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1
if (-not $auraSdk) {
    throw 'Set AURA_SERVICE_LIB to the official AuraServiceLib.dll path supplied with the ASUS Aura SDK.'
}

Copy-Item -LiteralPath $auraSdk -Destination (Join-Path $projectRoot 'AuraServiceLib.dll') -Force
$compiler = @(
    'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe',
    'C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe'
) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $compiler) { throw '.NET Framework C# compiler was not found.' }

& $compiler /nologo /target:exe /out:(Join-Path $projectRoot 'AuraReceiver.exe') /reference:(Join-Path $projectRoot 'AuraServiceLib.dll') (Join-Path $projectRoot 'AuraReceiver.cs')
if ($LASTEXITCODE -ne 0) { throw 'AuraReceiver compilation failed.' }

Push-Location $projectRoot
try {
    pnpm install --frozen-lockfile
    pnpm exec electron-builder --win portable
} finally { Pop-Location }
