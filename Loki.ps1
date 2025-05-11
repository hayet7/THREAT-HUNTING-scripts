# Paramètres
$lokiUrl = "https://github.com/Neo23x0/Loki/releases/download/v0.51.0/loki_0.51.0.zip"
$signatureBaseUrl = "https://github.com/Neo23x0/signature-base/archive/refs/heads/master.zip"

$downloadPathLoki = "$env:USERPROFILE\Downloads\loki.zip"
$downloadPathSignature = "$env:USERPROFILE\Downloads\signature-base.zip"

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

# Nettoyage des anciennes versions
if (Test-Path -Path $lokiPath) {
    Write-Host "[+] Suppression de l'ancien dossier Loki..."
    Remove-Item -Path $lokiPath -Recurse -Force
}
if (Test-Path -Path $downloadPathLoki) { Remove-Item $downloadPathLoki -Force }
if (Test-Path -Path $downloadPathSignature) { Remove-Item $downloadPathSignature -Force }

# Télécharger Loki
Write-Host "[+] Téléchargement de Loki..."
Invoke-WebRequest -Uri $lokiUrl -OutFile $downloadPathLoki

# Extraire Loki
Write-Host "[+] Extraction de Loki..."
Expand-Archive -Path $downloadPathLoki -DestinationPath $extractBasePath -Force

# Télécharger signature-base
Write-Host "[+] Téléchargement de signature-base..."
Invoke-WebRequest -Uri $signatureBaseUrl -OutFile $downloadPathSignature

# Extraire signature-base temporairement
$tempSigPath = "$extractBasePath\signature-base-master"
Expand-Archive -Path $downloadPathSignature -DestinationPath $extractBasePath -Force

# Copier le contenu dans le dossier attendu par Loki
$signatureDestination = "$lokiPath\signature-base"
if (Test-Path -Path $signatureDestination) {
    Remove-Item -Path $signatureDestination -Recurse -Force
}
Copy-Item -Path "$tempSigPath" -Destination $signatureDestination -Recurse

# Nettoyer le dossier temporaire
Remove-Item -Path $tempSigPath -Recurse -Force

# Vérification de Loki.exe
if (Test-Path -Path $lokiExe) {
    Write-Host "[+] Exécution de Loki..."
    Start-Process -FilePath $lokiExe -ArgumentList "--noindicator" -NoNewWindow -Wait
    Write-Host "[+] Analyse terminée."
} else {
    Write-Host "[✗] Erreur : Loki.exe introuvable."
    exit
}

# Récupérer le rapport texte généré (dans USERPROFILE)
$reportFile = Get-ChildItem -Path "$env:USERPROFILE" -Filter "loki_*.txt" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($reportFile -ne $null) {
    Write-Host "[+] Rapport trouvé : $($reportFile.FullName)"

    # URL du endpoint Django
    $url = "http://localhost:8000/upload_resultat/"

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
        Invoke-WebRequest -Uri $url -Method Post -Body $bodyBytes -Headers $headers
        Write-Host "[+] Rapport envoyé avec succès."
    } catch {
        Write-Host "[✗] Erreur lors de l'envoi : $_"
    }
} else {
    Write-Host "[✗] Rapport Loki *.txt introuvable."
}
