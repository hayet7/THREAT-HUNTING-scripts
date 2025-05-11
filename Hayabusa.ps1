# Paramètres
$repoUrl = "https://github.com/Yamato-Security/hayabusa/releases/download/v3.0.1/hayabusa-3.0.1-win-x64.zip"
$downloadPath = "$env:USERPROFILE\Downloads\hayabusa.zip"
$extractPath = "$env:USERPROFILE\Downloads\hayabusa"
$hayabusaExe = "$extractPath\hayabusa-3.0.1-win-x64.exe"

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
if (Test-Path -Path $extractPath) {
    Write-Host "[+] Suppression de l'ancien dossier Hayabusa..."
    Remove-Item -Path $extractPath -Recurse -Force
}
if (Test-Path -Path $downloadPath) {
    Write-Host "[+] Suppression de l'ancien ZIP Hayabusa..."
    Remove-Item -Path $downloadPath -Force
}

# Télécharger Hayabusa
Write-Host "[+] Téléchargement de Hayabusa depuis GitHub..."
Invoke-WebRequest -Uri $repoUrl -OutFile $downloadPath

# Créer le dossier d'extraction s'il n'existe pas
if (-Not (Test-Path -Path $extractPath)) {
    New-Item -Path $extractPath -ItemType Directory | Out-Null
}

# Extraire le ZIP
Write-Host "[+] Extraction de l'archive Hayabusa..."
Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force

# Vérifier si hayabusa-3.0.1-win-x64.exe existe
if (Test-Path -Path $hayabusaExe) {
    Set-Location -Path $extractPath
    Write-Host "[+] Exécution de Hayabusa..."
    Start-Process -FilePath ".\hayabusa-3.0.1-win-x64.exe" -ArgumentList 'csv-timeline --no-wizard -d "C:\Windows\System32\winevt\Logs" --output sec.csv --profile standard --rules rules/' -NoNewWindow -Wait
    Write-Host "[+] Analyse terminée."
} else {
    Write-Host "[✗] Erreur : hayabusa-3.0.1-win-x64.exe introuvable après extraction."
    exit
}

# Chemin vers le fichier CSV
$csvFilePath = "$extractPath\sec.csv"

# Vérifier si le fichier CSV existe
if (Test-Path -Path $csvFilePath) {
    Write-Host "[+] Le fichier CSV a été trouvé, envoi en cours..."

    # URL de l'endpoint Django
    $url = "http://localhost:8000/upload_resultat/"  # À adapter

    # ---- Bloc compatible PowerShell 5.1 (multipart/form-data) ----
    $fileBytes = [System.IO.File]::ReadAllBytes($csvFilePath)
    $fileName = [System.IO.Path]::GetFileName($csvFilePath)
    $boundary = [System.Guid]::NewGuid().ToString()
    $LF = "`r`n"

    $bodyLines = (
        "--$boundary",
        "Content-Disposition: form-data; name=`"fichier`"; filename=`"$fileName`"",
        "Content-Type: text/csv$LF",
        [System.Text.Encoding]::ASCII.GetString($fileBytes),
        "--$boundary--$LF"
    ) -join $LF

    $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyLines)

    $headers = @{
        "Content-Type" = "multipart/form-data; boundary=$boundary"
    }

    try {
        $response = Invoke-WebRequest -Uri $url -Method Post -Body $bodyBytes -Headers $headers
        Write-Host "[+] Fichier téléchargé avec succès."
    } catch {
        Write-Host "[✗] Erreur lors de l'envoi du fichier. Détails : $_"
    }
} else {
    Write-Host "[✗] Erreur : Le fichier CSV n'a pas été trouvé à l'emplacement spécifié."
}
