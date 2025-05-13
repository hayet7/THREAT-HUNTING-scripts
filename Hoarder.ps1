# Télécharger Hoarder depuis GitHub (si ce n'est pas déjà fait)
$cheminProjet = "$env:USERPROFILE\Downloads\Hoarder"
if (-Not (Test-Path $cheminProjet)) {
    git clone https://github.com/DFIRKuiper/Hoarder.git $cheminProjet
}

# Dossier où Hoarder est situé
$cheminReleases = "$cheminProjet\releases"

# Aller dans le dossier releases
Set-Location $cheminReleases

# Exécuter Hoarder
Write-Host "Exécution de Hoarder..."
.\hoarder.exe -vv

# URL du serveur Django pour recevoir le fichier
$Uri = "http://localhost:8000/upload_resultat/"

# Chemin vers le dossier où Hoarder génère le fichier ZIP
$HoarderFolder = "$env:USERPROFILE\Downloads\Hoarder\releases"

# Trouver le fichier ZIP généré dans le dossier Hoarder
$FichierPath = Get-ChildItem -Path $HoarderFolder -Filter *.zip | Sort-Object LastWriteTime -Descending | Select-Object -First 1

# Vérifie si un fichier ZIP a été trouvé
if ($FichierPath) {
    Write-Host "Fichier trouvé : $($FichierPath.FullName)"
    
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
