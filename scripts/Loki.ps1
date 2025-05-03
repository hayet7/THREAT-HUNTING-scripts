# Définir les paramètres
$downloadUrl = "https://github.com/Neo23x0/Loki/releases/download/v0.51.0/loki_0.51.0.zip"
$downloadPath = "$env:USERPROFILE\Downloads\loki.zip"
$extractBasePath = "$env:USERPROFILE\Downloads"
$lokiPath = "$extractBasePath\loki"
$lokiExe = "$lokiPath\loki.exe"

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

# Télécharger Loki
Write-Host "[+] Téléchargement de Loki depuis GitHub..."
Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath

# Supprimer ancien dossier si besoin
if (Test-Path -Path $lokiPath) {
    Write-Host "[+] Suppression de l'ancien dossier Loki..."
    Remove-Item -Path $lokiPath -Recurse -Force
}

# Extraire directement sous Downloads (pour avoir Downloads\loki\)
Write-Host "[+] Extraction de l'archive Loki..."
Expand-Archive -Path $downloadPath -DestinationPath $extractBasePath -Force

# Définir les chemins pour signature-base
$signatureSource = "$lokiPath\signature-base"
$signatureDestination = "$lokiPath\signature-base"

# Copier signature-base si nécessaire
if (-not (Test-Path -Path $signatureDestination)) {
    Write-Host "[+] Copie du dossier 'signature-base' vers le dossier Loki..."
    $sourceCandidate = Get-ChildItem -Path $extractBasePath -Recurse -Directory -Filter "signature-base" | Select-Object -First 1
    if ($sourceCandidate) {
        Copy-Item -Path $sourceCandidate.FullName -Destination $signatureDestination -Recurse -Force
    } else {
        Write-Host "[✗] Erreur : Dossier 'signature-base' introuvable dans l'archive extraite."
    }
} else {
    Write-Host "[+] Le dossier 'signature-base' est déjà en place."
}

# Vérifier si Loki.exe existe
if (Test-Path -Path $lokiExe) {
    # Exécuter Loki
    Write-Host "[+] Exécution de Loki..."
    Start-Process -FilePath $lokiExe -ArgumentList "--noindicator" -NoNewWindow -Wait
    Write-Host "[+] Analyse terminée."
} else {
    Write-Host "[✗] Erreur : Loki.exe introuvable après extraction."
}

# Nettoyage (Optionnel)
# Write-Host "[+] Nettoyage des fichiers temporaires..."
# Remove-Item -Path $downloadPath -Force