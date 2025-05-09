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
$HoarderFolder = "$env:USERPROFILE\Downloads\Hoarder\releases"  # Utilisation de la variable d'environnement USERPROFILE

# Trouver le fichier ZIP généré dans le dossier Hoarder
$FichierPath = Get-ChildItem -Path $HoarderFolder -Filter *.zip | Sort-Object LastWriteTime -Descending | Select-Object -First 1

# Vérifie si un fichier ZIP a été trouvé
if ($FichierPath) {
    Write-Host "Fichier trouvé : $($FichierPath.FullName)"
    
    # Lire le fichier en binaire
    $Fichier = Get-Content -Path $FichierPath.FullName -Encoding Byte

    # Créer l'objet multipart/form-data pour envoyer le fichier
    $Body = @{
        fichier = [System.IO.MemoryStream]::new($Fichier)
    }

    # Envoyer le fichier à Django
    try {
        $response = Invoke-RestMethod -Uri $Uri -Method Post -ContentType "multipart/form-data" -Body $Body
        Write-Host "Réponse du serveur Django : $($response)"
    } catch {
        Write-Host "Erreur lors de l'envoi du fichier : $_"
    }
} else {
    Write-Host "Aucun fichier ZIP trouvé dans le dossier Hoarder"
}
