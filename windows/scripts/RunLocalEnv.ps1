if (-not $institucionalFolder) {
    Write-Host "institucionalFolder var not defined"
    exit 1
}

if (-not $algoAdapterFolder) {
    Write-Host "algoAdapterFolder var not defined"
    exit 1
}

& Join-Path $institucionalFolder "Src\ATG.Bats\runWithFalcon.bat"
& Join-Path $algoAdapterFolder "Scripts\Run.bat"
