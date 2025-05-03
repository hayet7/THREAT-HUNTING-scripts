# Paramètres

\$repoUrl = "[https://github.com/Yamato-Security/hayabusa/releases/download/v3.0.1/hayabusa-3.0.1-win-x64.zip](https://github.com/Yamato-Security/hayabusa/releases/download/v3.0.1/hayabusa-3.0.1-win-x64.zip)"
\$downloadPath = "\$env\:USERPROFILE\Downloads\hayabusa.zip"
\$extractPath = "\$env\:USERPROFILE\Downloads\hayabusa"
\$hayabusaExe = "\$extractPath\hayabusa-3.0.1-win-x64.exe"  # << Correct ici

# Fonction pour s'assurer que Expand-Archive est disponible

function Ensure-ExpandArchiveAvailable {
if (-not (Get-Command Expand-Archive -ErrorAction SilentlyContinue)) {
Write-Host "Le module Expand-Archive est manquant. Installation du module 'Microsoft.PowerShell.Archive'..."
Install-Module -Name 'Microsoft.PowerShell.Archive' -Force -Scope CurrentUser
Import-Module 'Microsoft.PowerShell.Archive'
}
}

# Vérifier la présence d'Expand-Archive

Ensure-ExpandArchiveAvailable

# Supprimer anciens fichiers s'ils existent

if (Test-Path -Path \$extractPath) {
Write-Host "\[+] Suppression de l'ancien dossier Hayabusa..."
Remove-Item -Path \$extractPath -Recurse -Force
}
if (Test-Path -Path \$downloadPath) {
Write-Host "\[+] Suppression de l'ancien ZIP Hayabusa..."
Remove-Item -Path \$downloadPath -Force
}

# Télécharger Hayabusa

Write-Host "\[+] Téléchargement de Hayabusa depuis GitHub..."
Invoke-WebRequest -Uri \$repoUrl -OutFile \$downloadPath

# Créer le dossier d'extraction

if (-Not (Test-Path -Path \$extractPath)) {
New-Item -Path \$extractPath -ItemType Directory | Out-Null
}

# Extraire le ZIP

Write-Host "\[+] Extraction de l'archive Hayabusa..."
Expand-Archive -Path \$downloadPath -DestinationPath \$extractPath -Force

# Vérifier si hayabusa-3.0.1-win-x64.exe existe

if (Test-Path -Path \$hayabusaExe) {
\# Aller dans le dossier hayabusa et exécuter hayabusa-3.0.1-win-x64.exe
Set-Location -Path \$extractPath
Write-Host "\[+] Exécution de Hayabusa..."
Start-Process -FilePath ".\hayabusa-3.0.1-win-x64.exe" -ArgumentList 'csv-timeline --no-wizard -d "C:\Windows\System32\winevt\Logs" --output sec.csv --profile standard --rules rules/' -NoNewWindow -Wait
Write-Host "\[+] Analyse terminée."
} else {
Write-Host "\[✗] Erreur : hayabusa-3.0.1-win-x64.exe introuvable après extraction."
}
