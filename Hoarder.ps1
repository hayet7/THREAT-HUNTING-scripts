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

# Attendre quelques secondes pour être sûr que le fichier soit généré
Start-Sleep -Seconds 3

# Chercher le dernier fichier ZIP généré dans le dossier releases
$fichierGenere = Get-ChildItem -Path $cheminReleases -Filter *.zip -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($null -eq $fichierGenere) {
    Write-Host "Aucun fichier généré trouvé dans le dossier 'releases'."
    exit
}

# Envoyer le fichier à Django (URL de ton API)
$destinationDjango = "http://127.0.0.1:8000/api/upload_resultat/"

# Envoi du fichier à Django via HTTP POST
$response = Invoke-WebRequest -Uri $destinationDjango `
    -Method Post `
    -Form @{
        "fichier" = Get-Item $fichierGenere.FullName
    }

Write-Host "✅ Fichier $($fichierGenere.Name) envoyé à Django avec succès."
Write-Host "Réponse du serveur Django : $($response.Content)"
