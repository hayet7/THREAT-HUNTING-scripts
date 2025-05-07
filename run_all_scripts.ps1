# Exécuter Hoarder.ps1
Write-Host "Exécution de Hoarder..."
& "C:\Users\$env:USERNAME\THREAT-HUNTING-scripts\Hoarder.ps1"

# Exécuter Loki.ps1
Write-Host "Exécution de Loki..."
& "C:\Users\$env:USERNAME\THREAT-HUNTING-scripts\Loki.ps1"

# Exécuter Hayabusa.ps1
Write-Host "Exécution de Hayabusa..."
& "C:\Users\$env:USERNAME\THREAT-HUNTING-scripts\Hayabusa.ps1"

Write-Host "Tous les scripts ont été exécutés."
