# Paramètres
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
Ensure-ExpandArchiveAvailable

# Supprimer ancien dossier Loki
if (Test-Path -Path $lokiPath) {
    Write-Host "[+] Suppression de l'ancien dossier Loki..."
    Remove-Item -Path $lokiPath -Recurse -Force
}

# Supprimer ancien ZIP
if (Test-Path -Path $downloadPath) {
    Remove-Item -Path $downloadPath -Force
}

# Télécharger Loki
Write-Host "[+] Téléchargement de Loki depuis GitHub..."
Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath

# Extraction
Write-Host "[+] Extraction de l'archive Loki..."
Expand-Archive -Path $downloadPath -DestinationPath $extractBasePath -Force

# Vérification de l'exécutable
if (Test-Path -Path $lokiExe) {
    Write-Host "[+] Exécution de Loki..."
    Start-Process -FilePath $lokiExe -ArgumentList "--noindicator" -NoNewWindow -Wait
    Write-Host "[+] Analyse terminée."
} else {
    Write-Host "[✗] Erreur : Loki.exe introuvable après extraction."
    exit
}

# Chercher le fichier de rapport généré automatiquement (dans USERPROFILE)
Write-Host "[+] Recherche du fichier de rapport Loki généré..."
$reportFile = Get-ChildItem -Path "$env:USERPROFILE" -Filter "loki_*.txt" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($reportFile -ne $null) {
    Write-Host "[+] Rapport trouvé : $($reportFile.FullName)"
    
    # Préparation pour envoi à Django
    $url = "http://localhost:8000/upload_resultat/"  # À adapter

    $fileBytes = [System.IO.File]::ReadAllBytes($reportFile.FullName)
    $fileName = $reportFile.Name
    $boundary = [System.Guid]::NewGuid().ToString()
    $LF = "`r`n"

    $bodyLines = (
        "--$boundary",
        "Content-Disposition: form-data; name=`"fichier`"; filename=`"$fileName`"",
        "Content-Type: text/plain$LF",
        [System.Text.Encoding]::ASCII.GetString($fileBytes),
        "--$boundary--$LF"
    ) -join $LF

    $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyLines)

    $headers = @{
        "Content-Type" = "multipart/form-data; boundary=$boundary"
    }

    try {
        $response = Invoke-WebRequest -Uri $url -Method Post -Body $bodyBytes -Headers $headers
        Write-Host "[+] Rapport envoyé avec succès."
    } catch {
        Write-Host "[✗] Erreur lors de l'envoi du rapport. Détails : $_"
    }
} else {
    Write-Host "[✗] Erreur : Aucun rapport Loki *.txt trouvé dans le profil utilisateur."
}
