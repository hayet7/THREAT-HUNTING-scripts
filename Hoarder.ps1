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

# Trouver le dernier fichier ZIP
$FichierPath = Get-ChildItem -Path $HoarderFolder -Filter *.zip |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

# Vérifie si un fichier ZIP a été trouvé
if ($FichierPath) {
    Write-Host "[✓] Fichier trouvé : $($FichierPath.FullName)"

    # URL de l'endpoint Django
    $Uri = "http://localhost:8000/upload_resultat/"

    # Construction du formulaire (multipart/form-data automatique)
    $Form = @{
        "fichier" = Get-Item $FichierPath.FullName
    }

    # Envoi avec Invoke-WebRequest
    try {
        $response = Invoke-WebRequest -Uri $Uri -Method Post -Form $Form
        Write-Host "[✓] Réponse du serveur Django : $($response.StatusCode) $($response.StatusDescription)"
        Write-Host $response.Content
    } catch {
        Write-Host "[✗] Erreur lors de l'envoi : $_"
    }
} else {
    Write-Host "[✗] Aucun fichier ZIP trouvé dans $HoarderFolder"
}
