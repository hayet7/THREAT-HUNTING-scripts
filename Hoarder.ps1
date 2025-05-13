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
.\hoarder.exe --PowerShellHistory -vv

# Envoi du fichier ZIP généré par Hoarder vers le serveur Django

# URL du serveur Django (à adapter si besoin)
$url = "http://localhost:8000/upload_resultat/"

# Trouver le fichier ZIP généré
$zipPath = Get-ChildItem -Path $cheminReleases -Filter *.zip | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($zipPath) {
    Write-Host "[+] Fichier ZIP trouvé : $($zipPath.FullName)"

    $fileBytes = [System.IO.File]::ReadAllBytes($zipPath.FullName)
    $fileName = [System.IO.Path]::GetFileName($zipPath.FullName)
    $boundary = [System.Guid]::NewGuid().ToString()
    $LF = "`r`n"

    $bodyLines = (
        "--$boundary",
        "Content-Disposition: form-data; name=`"fichier`"; filename=`"$fileName`"",
        "Content-Type: application/zip$LF",
        [System.Text.Encoding]::ASCII.GetString($fileBytes),
        "--$boundary--$LF"
    ) -join $LF

    $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyLines)

    $headers = @{
        "Content-Type" = "multipart/form-data; boundary=$boundary"
    }

    try {
        $response = Invoke-WebRequest -Uri $url -Method Post -Body $bodyBytes -Headers $headers
        Write-Host "[+] ZIP envoyé avec succès au serveur Django."
    } catch {
        Write-Host "[✗] Erreur lors de l'envoi du ZIP. Détails : $_"
    }
} else {
    Write-Host "[✗] Aucun fichier ZIP trouvé à envoyer."
}
