# === Configuration ===
$hoarderRepo = "https://github.com/DFIRKuiper/Hoarder.git"
$cheminProjet = "$env:USERPROFILE\Downloads\Hoarder"
$cheminReleases = "$cheminProjet\releases"
$uploadUrl = "http://localhost:8000/upload_resultat/"  # À adapter si besoin

# === Étape 1 : Cloner Hoarder s'il n'existe pas ===
if (-Not (Test-Path $cheminProjet)) {
    Write-Host "[+] Clonage du dépôt Hoarder..."
    git clone $hoarderRepo $cheminProjet
} else {
    Write-Host "[✓] Le dépôt Hoarder existe déjà."
}

# === Étape 2 : Exécuter hoarder.exe ===
if (Test-Path "$cheminReleases\hoarder.exe") {
    Write-Host "[+] Exécution de Hoarder..."
    Set-Location $cheminReleases
    .\hoarder.exe --PowerShellHistory  -vv
} else {
    Write-Host "[✗] Erreur : hoarder.exe introuvable dans releases/"
    exit
}

# === Étape 3 : Trouver le fichier ZIP généré ===
$zipFile = Get-ChildItem -Path $cheminReleases -Filter *.zip |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if (-Not $zipFile) {
    Write-Host "[✗] Aucun fichier ZIP généré par Hoarder trouvé."
    exit
}

Write-Host "[✓] Fichier ZIP trouvé : $($zipFile.FullName)"

# === Étape 4 : Lire le fichier en binaire ===
$fileBytes = [System.IO.File]::ReadAllBytes($zipFile.FullName)
$fileName = [System.IO.Path]::GetFileName($zipFile.FullName)
$boundary = [System.Guid]::NewGuid().ToString()
$LF = "`r`n"

# Construction manuelle du body multipart/form-data
$bodyLines = (
    "--$boundary",
    "Content-Disposition: form-data; name=`"fichier`"; filename=`"$fileName`"",
    "Content-Type: application/zip$LF",
    [System.Text.Encoding]::GetEncoding("iso-8859-1").GetString($fileBytes),
    "--$boundary--$LF"
) -join $LF

$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyLines)

# === Étape 5 : Envoyer la requête HTTP ===
$headers = @{
    "Content-Type" = "multipart/form-data; boundary=$boundary"
}

Write-Host "[>] Envoi du fichier à $uploadUrl ..."
try {
    $response = Invoke-WebRequest -Uri $uploadUrl -Method Post -Body $bodyBytes -Headers $headers
    Write-Host "[✓] Fichier envoyé avec succès."
    Write-Host "Réponse : $($response.Content)"
} catch {
    Write-Host "[✗] Erreur lors de l'envoi : $_"
}
